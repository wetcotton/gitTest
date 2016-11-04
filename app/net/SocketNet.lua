--
-- Author: xiaopao
-- Date: 2014-09-29 11:12:00
--

utilsInit = require("framework.cc.utils.init")
cc.net = require("framework.cc.net.init")

require("pack")
require("app.net.Commands")
require("app.utils.Constants")
require("app.net.parseGameData")

local scheduler = require("framework.scheduler")
local SEND_TIMEOUT_COMFIRM = 7
local SendingMsgTable = {}
local SendingSchedulerTable = {}
local IsReconnect = false
local DeviceId = device.getOpenUDID()
local mobileOS = 0
if device.platform == "ios" then
    mobileOS = 1
elseif device.platform == "android" then
    mobileOS = 2
else
    mobileOS = 0
end

--XXTEA密码
local MessageKey = "szn100szn"
--字符串处理方式 
local MessageHanleType = {
                             encryptMessage = 1, --加密
                             decryptMessage = 2, --解密
                         }
local Zlib = require("zlib")

local PacketBuffer = require("app.net.PacketBuffer")

local SocketNet = class("SocketNet")


function SocketNet:ctor(__host, __port)
    self.host = __host
    self.port = __port
	self.name = 'SocketTCP'
    self.cTime = 1
	self:initSocket()
end

function SocketNet:initSocket()
    self._socket = cc.net.SocketTCP.new(self.host , self.port , false)  
    self.packetBuf = PacketBuffer.new()
 
    self._socket:removeAllEventListeners()
    self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onSocketConnected))
    self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onSocketStatus))
    self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onSocketStatus))
    self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onSocketStatus))
    self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onSocketRevData))  

    --心跳检测
      if g_isSendBeat==false then
        g_isSendBeat = true
        scheduler.performWithDelayGlobal(HeartBeatCheck, 10)
      end
end

function SocketNet:connectSocketServer()
	if self._socket then
        self._socket:connect()
    end
end

function SocketNet:disconnectSocketServer()
    if self._socket then
        self._socket:disconnect()
    end
end

function SocketNet:onSocketStatus(__event)
    printInfo("SocketRequest: socket status: %s", __event.name)
    local function confirmClicked()
        showConnectPanel()
        self:reConnect()
    end
    local function goLoginScene()
        IsReconnect = false
        m_socket = nil
        SendingMsgTable = {}
        app:enterScene("LoginScene",{1})
    end
    if __event.name== "SOCKET_TCP_CONNECT_FAILURE" then
        showMessageBox("服务器连接失败，是否重连？\n关闭将退回登录界面",confirmClicked,goLoginScene, nil, 999999)
    end
    removeConnectPanel()
end


function SocketNet:onSocketConnected(__event)
    print("SocketRequest: Connect success!:"..__event.name .. "  Time:"..self.cTime)
    -- self.cTime = self.cTime + 1
    -- if self.cTime  >= 1000 then
    --     return
    -- end
    -- self._socket:disconnect()
    -- self._socket:connect()
    
    if IsReconnect == false then
        display.getRunningScene():onSocketConnected(__event)
    else
       removeConnectPanel()
       --检查连接后是否有没发完的请求
       for k,v in pairs(SendingMsgTable) do
          print("SocketRequest: Re Send:"..v.CommandId)
          print("SocketRequest: ReS Senddata Length----"..string.len(v.Message))
          startLoading()
          self._socket:send(v.Message)
          SendingSchedulerTable[v.CommandId] = scheduler.performWithDelayGlobal(handler(self,self.sendTimeOut), SEND_TIMEOUT_COMFIRM)
       end
    end
end


function SocketNet:reConnect()
    if self._socket then
        print("SocketRequest: ReConnect")
        self._socket:connect()
    else
        self:initSocket()
        self._socket:connect()
    end
end

function SocketNet:isConnected()
    return self._socket.isConnected
end

function SocketNet:handleMsg(msg)
    endLoading()
    local status, commandId, __msgs = self.packetBuf:parsePackets(msg)

    if status == PacketBuffer.STATUS_INSUFFIENT_DATA then
        return
    end
    if CMD_BROADCAST~=commandId then
        print("SocketRequest:  Recive commandId = "..commandId)
    end
    --从发送列表移除
    local requestCaller = nil
    local requestCallBack = nil
    if SendingMsgTable[commandId] ~= nil then
        requestCaller = SendingMsgTable[commandId].Caller
        requestCallBack = SendingMsgTable[commandId].Callback
        scheduler.unscheduleGlobal(SendingSchedulerTable[commandId])
        SendingMsgTable[commandId] = nil
        SendingSchedulerTable[commandId] = nil
    end

    --解密
    __msgs = self:cryptoMessageStr(__msgs, MessageHanleType.decryptMessage)
    --解压
    __msgs = self:unGzipMessage(__msgs)

    local result = json.decode(__msgs)
    if result~=nil then
        if CMD_BROADCAST~=commandId then
            print("SocketRequest:  Recive Data-----------------------")
            printTable(result)
        end
    else
        print("SocketRequest: Socket Result is Nil!!!")
    end

    --找不到用户
    if result["result"]==-444 then
        IsReconnect = false
        SendingMsgTable = {}
        if g_onlineHandle then
            scheduler.unscheduleGlobal(g_onlineHandle)
        end
        
        showMessageBox(result.msg, nil, nil, function()
            if device.platform ~= "android" then
                app:enterScene("LoginScene")
                if GuideManager.NextStep  ~= 0 then
                    GuideManager.NextStep  = 0
                end
                if GuideManager.NextLocalStep  ~= 0 then
                    GuideManager.NextLocalStep  = 0
                end
            else
                if getVersionCode() >= 3 then
                    restartTheApp()
                else
                    app:enterScene("LoginScene")
                    if GuideManager.NextStep  ~= 0 then
                        GuideManager.NextStep  = 0
                    end
                    if GuideManager.NextLocalStep  ~= 0 then
                        GuideManager.NextLocalStep  = 0
                    end
                end
            end
        end)
        return
    end
    --第一次处理
    if result["result"]==1 then
        parseSocketData(commandId,result)--解析服务器数据
    elseif commandId == CMD_BOSS_CHANGE_CAR_PUSH or commandId == CMD_BOSS_CHANGE_CAR then
      if worldBossInstance~=nil then
        worldBossInstance:OnUpdateCarRet(result)
      end
    end 

    --分发至各单元处理
    if requestCaller ~= nil then
        requestCallBack(requestCaller,result) 
    end

    if status == PacketBuffer.STATUS_EXCESS_DATA then --如果粘包，则再调用一次解析剩下的消息
        self:handleMsg("")
    end
end

function SocketNet:onSocketRevData(__event)
    self:handleMsg(__event.data)
end

function SocketNet:SendRequest(_sendstr,_commandId,_caller,_callback)
    if SendingMsgTable[_commandId] ~= nil then
        print("SocketRequest: Same Request！")
        return
    end

    local HEAD_0 = string.char(78)
    local HEAD_1 = string.char(37)
    local HEAD_2 = string.char(38)
    local HEAD_3 = string.char(48)
    local ProtoVersion = string.char(9)
    local ServerVersion = 0
    local sendstr = _sendstr

    --统一添加用户ID
    local sendInfo = json.decode(sendstr)
    if sendInfo["userId"] == nil then
        sendInfo["userId"] = mUserId
    end
    sendInfo["devId"] = DeviceId
    sendInfo["mobileOS"] = mobileOS
    if sendInfo["characterId"] == nil and srv_userInfo["characterId"] ~= nil then
        sendInfo["characterId"] = srv_userInfo["characterId"]
    end
    sendstr = json.encode(sendInfo)
    print("SocketRequest: SendCommand----".._commandId)
    print("SocketRequest: Senddata-------"..sendstr)

    --压缩 
    if _commandId == CMD_UPDATE_PVPRESULT then
      sendstr, eof,  bytes_in, bytes_out = Zlib.deflate()(sendstr,"finish")
    end
    --加密
    sendstr = self:cryptoMessageStr(sendstr,MessageHanleType.encryptMessage)
    print("SocketRequest: Senddata Len---"..string.len(sendstr))
    
    local data = string.pack('>AAAAAiii',HEAD_0,HEAD_1,HEAD_2,
                       HEAD_3,ProtoVersion,ServerVersion,
                       string.len(sendstr)+4,_commandId)

    senddata = data..sendstr
    
    local SendingMessage = {
                             CommandId = _commandId,
                             Caller    = _caller,
                             Callback  = _callback,
                             Message   = senddata,
                           }
    SendingMsgTable[_commandId] = SendingMessage
    local timeOutNum = SEND_TIMEOUT_COMFIRM
    if _commandId==CMD_BACKPACK then
        timeOutNum = timeOutNum + 5 
    end
    local sendScheduler = scheduler.performWithDelayGlobal(handler(self,self.sendTimeOut), timeOutNum)
    SendingSchedulerTable[_commandId] = sendScheduler

    if self:isConnected() then
        self._socket:send(senddata)
    end
    
end

function SocketNet:sendTimeOut()
    print("SocketRequest: Time Out!")
    IsReconnect = true
    if self._socket ~= nil then
        self._socket:disconnect()
        for k,v in pairs(SendingSchedulerTable) do
             scheduler.unscheduleGlobal(v)
        end                                 
        local function confirmClicked()                     
           showConnectPanel()
           self:reConnect()
        end
        local function goLoginScene()
            IsReconnect = false
            m_socket = nil
            SendingMsgTable = {}
            app:enterScene("LoginScene",{1})
        end
        showMessageBox("网络连接超时，是否重连？\n关闭将退回登录界面",confirmClicked,goLoginScene)
        endRechargeLoading()
        return
    end
    print("SocketRequest: _socket is nil")
end

function SocketNet:unGzipMessage(str)
    local inflate, eof2,  bytes_in2, bytes_out2 = Zlib.inflate()(str)
    return inflate
end

function SocketNet:cryptoMessageStr(str, handleType)

    if handleType == MessageHanleType.encryptMessage then
        str=crypto.encryptXXTEA(str, MessageKey)
    elseif handleType == MessageHanleType.decryptMessage then
        str=crypto.decryptXXTEA(str, MessageKey)
    end
    return str 
end

function SocketNet:HeartBeatResult(result)
    if result.result == 1 then
        scheduler.performWithDelayGlobal(HeartBeatCheck, 10)
    end
end

return SocketNet
