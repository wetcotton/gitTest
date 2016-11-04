local globalFunc = require("app.utils.GlobalFunc")
UEgihtSdkLoginManager = class("UEgihtSdkLoginManager")
local httpNet = require("app.net.HttpNet")

local U8AppId =  "2"
local U8AppKey = "53deb15bd9e02d9bd42e7ea21bb793ad"
-- local U8serverLogin = "http://192.168.11.110:8082/userver/user/getToken?"
-- local U8serverOrder = "http://192.168.11.110:8082/userver/pay/getOrderID?"
local U8url = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082"
print("------------U8URL---",U8url)
--内部
local U8serverLogin = U8url.."/userver/user/getToken?"
local U8serverOrder = U8url.."/userver/pay/getOrderID?"

local function hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

local U8Info = {}

function UEgihtSdkLoginManager:sendTokenToU8(strParams)
    print("调用sendTokenToU8",strParams)
    self.arr = string.split(strParams, "|")
    local u8data = {}
    u8data["appID"] = U8AppId
    u8data["channelID"] = tostring(gType_Chnl)
    
    --酷睿特殊处理
    if gType_SDK == AllSdkType.Sdk_KURUI then
        local krData = {
                            ["u8AppID"] = tonumber(U8AppId),
                            ["u8ChannelID"] = tonumber(gType_Chnl),
                            ["ms_request"] = "check_login",
                            ["sign"] = crypto.md5(self.arr[4]..self.arr[6]..self.arr[5]),
                            ["udata"] = {
                                            ["id"] = self.arr[8],
                                            ["access_token"] = self.arr[3],
                                        },
                            ["cinfo"] = {
                                            ["appid"] = self.arr[4],
                                            ["cid"] = self.arr[6],
                                            ["cname"] = self.arr[7],
                                        },
                            ["mobileOS"] = g_MobileOS,
                            ["serverID"] = loginServerList.serverId
                       }
        printTable(krData)
        U8serverLogin = U8url.."/userver/user/cooee/getToken?"
        startLoading()
        local request = network.createHTTPRequest(function(event)
            self:afterGetLoginRet(event)
        end, U8serverLogin.."data="..json.encode(krData), "GET")
        request:start()
        return
    end

    if gType_SDK == AllSdkType.Sdk_HUAWEI or gType_SDK == AllSdkType.Sdk_HUAWEI2 then --华为
        local extTmp = self.arr[3]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_XIAOMI then
        local extTmp = "{".."\"sid\"=\""..self.arr[2].."\",".."\"token\"=\""..self.arr[3].."\"}"
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_GIONEE then
        local tokenInfo= json.decode(self.arr[3])
        printTable(tokenInfo)
        local extTmp = "{".."\"playerID\"=\""..self.arr[2].."\",".."\"n\"=\""..tokenInfo.n.."\",".."\"v\"=\""..tokenInfo.v.."\",".."\"h\"=\""..tokenInfo.h.."\",".."\"t\"=\""..tokenInfo.t.."\",".."\"username\"=\"".."\"".."}"
        u8data["extension"] = encodeURI(extTmp)
        print("EXT:"..extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_DANGLE then
        print("进入分支",strParams)
        local extTmp = strParams
        print("EXT:",extTmp)
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
        local extTmp = self.arr[3]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_UC then
        local extTmp = self.arr[2]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_OPPO or gType_SDK == AllSdkType.Sdk_OPPO2 then  --oppo
        local extTmp = "{".."\"ssoid\"=\""..self.arr[2].."\",".."\"token\"=\""..self.arr[3].."\"}"
        print("extTmp:"..extTmp)
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_LENOVO then 
        local extTmp = self.arr[2]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_BAIDU or gType_SDK == AllSdkType.Sdk_BAIDU2 then
        local extTmp = self.arr[3].."|"..g_Version
        print("extTmp:"..extTmp)
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_WDJ then 
        local extTmp = "{".."\"uid\"=\""..self.arr[2].."\",".."\"token\"=\""..self.arr[3].."\"}"
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_YYH then
        local extTmp = self.arr[3]
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_ANZHI then --需要联调修改
        local extTmp = "{".."\"uid\"=\""..self.arr[2].."\",".."\"sid\"=\""..self.arr[3].."\"}"
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_ZY then
        local extTmp = "{".."\"uid\"=\""..self.arr[2].."\",".."\"token\"=\""..self.arr[3].."\"}"
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_VIVO or gType_SDK == AllSdkType.Sdk_VIVO2 then
        local extTmp = "{".."\"openid\"=\""..self.arr[2].."\",".."\"token\"=\""..self.arr[3].."\",".."\"name\"=\""..self.arr[4].."\"}"
        u8data["extension"] = extTmp
        extTmp = decodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD2 then
        local extTmp = self.arr[2]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_MSDK then
        local extTmp = "{".."\"accountType\"=\""..self.arr[1].."\",".."\"openId\"=\""..self.arr[2].."\"}"
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_MEIZU then 
        local extTmp = "{".."\"uid\"=\""..self.arr[2].."\",".."\"session\"=\""..self.arr[3].."\"}"
        u8data["extension"] = extTmp
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_QBAO then
        local extTmp = self.arr[2]
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_LieBao then
        local extTmp = "{".."\"username\"=\""..self.arr[1].."\",".."\"logintime\"=\""..self.arr[2].."\"}"
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    elseif gType_SDK == AllSdkType.Sdk_LESHI then
        local extTmp = "{".."\"uid\"=\""..self.arr[1].."\",".."\"token\"=\""..self.arr[2].."\"}"
        u8data["extension"] = encodeURI(extTmp)
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    else
        local extTmp = self.arr[1]
        u8data["extension"] = self.arr[1]
        u8data["sign"] = crypto.md5("appID="..U8AppId.."channelID="..tostring(gType_Chnl).."extension="..extTmp..U8AppKey)
    end
    startLoading()

    print("loginServerList: ",loginServerList)
    printTable(loginServerList)


    local request = network.createHTTPRequest(function(event)
        self:afterGetLoginRet(event)
    end, U8serverLogin.."appID="..u8data["appID"].."&".."channelID="..u8data["channelID"].."&".."extension="..u8data["extension"].."&".."sign="..u8data["sign"].."&serverID="..loginServerList.serverId.."&mobileOS="..g_MobileOS, "GET")
    print("URL:".. U8serverLogin.."appID="..u8data["appID"].."&".."channelID="..u8data["channelID"].."&".."extension="..u8data["extension"].."&".."sign="..u8data["sign"].."&serverID="..loginServerList.serverId.."&mobileOS="..g_MobileOS)
    request:start()
end

function UEgihtSdkLoginManager:afterGetLoginRet(event)
    local request = event.request
    printf("onLoginHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        endLoading()
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())
       
        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            return
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", request:getResponseString())

            local loginResult = request:getResponseString()
            local jLoginResult= json.decode(loginResult)
            if jLoginResult.state == 1 then
                U8Info = jLoginResult.data
                local logindata = {}
                if device.platform == "ios" then
                    logindata["mobileOS"] = 1
                elseif device.platform == "android" then
                    logindata["mobileOS"] = 2
                else
                    logindata["mobileOS"] = 0
                end
                --printLogForLua("-----------luaLetUserLogin 33333")
                print("--------------------------=============111")
                printTable(jLoginResult.data)
                print("--------------------------=============222")
                logindata.type = tonumber(self.arr[1])
                logindata.openId = jLoginResult.data.sdkUserID
                if gType_SDK == AllSdkType.Sdk_DANGLE then
                    logindata.type = eGSLoginType.eGslt_DANGLE
                    logindata.openId = downJoyMid
                    print("downJoyMid: ",downJoyMid)
                elseif gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD2 then
                    coolpadSDK.accessToken = jLoginResult.data.extension
                    coolpadSDK.openId = jLoginResult.data.sdkUserID

                    print("===================================酷派：")
                    print("coolpadSDK.accessToken: ",coolpadSDK.accessToken)
                    print("coolpadSDK.openId: ",coolpadSDK.openId)
                end
                logindata.accToken = jLoginResult.data.token
                logindata.chnlId   = gType_Chnl
                logindata.userIP =  ""
                self.u8UserName = jLoginResult.data.sdkUserID

                print("U8接口返回成功")
                --角色登录
                startLoading()
                roleLoginData["userId"] = jLoginResult["data"]["userID"]
                roleLoginData["userName"] = jLoginResult["data"]["userName"]
                roleLoginData["mobileOS"] = g_MobileOS
                roleLoginData["chnlId"] = gType_Chnl
                mUserId = roleLoginData["userId"]
                setMusicSwitch()

                m_socket = nil
                globalFunc.connectSocketServer(loginServerList["hostIp"],loginServerList["port"])


                

                --上传ios-IDFA值
                if device.platform=="ios" and GameData.IDFA==nil then
                    local ok, ret = luaoc.callStaticMethod("RootViewController", "getIDFA")
                    if ok then
                        print("获取IDFA成功")
                        print("ret: "..ret)
                        if ret then
                            local url = "http://jk1.sh928.com/idfa/gsync.php?"
                            url = url.."appid="..jLoginResult.data.extension.."&"
                            url = url.."idfa="..ret
                            
                            g_idfa = ret

                            printf("http request url=%s", url)
                            -- printTable(dataInfo)
                            local request = network.createHTTPRequest(onIDFAResponse,url,"POST")
                            -- for key,value in pairs(dataInfo) do
                            --     request:addPOSTValue(key, value)
                            -- end
                            -- request:addPOSTValue("appid", jLoginResult.data.extension)
                            -- request:addPOSTValue("idfa", "[\""..dataInfo.idfa.."\"]")
                            
                            printf("REQUEST START")
                            request:start()
                        end
                        
                    else
                        print("获取IDFA失败")
                    end
                end
                
            else
                showTips(jLoginResult.msg)
                print("U8登录失败："..jLoginResult.state)
            end
        end
    elseif event.name == "progress" then
        
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        endLoading()
    end
end

function UEgihtSdkLoginManager:getOrderId(_orderInfo)
    self.u8OrderInfo = _orderInfo
    startLoading()
    print("U8INFO:-----------------")
    printTable(U8Info)
    print("_orderInfo:-----------------")
    printTable(_orderInfo)--
    print("BefMD5:"..tostring(U8Info.userID)..tostring(_orderInfo.OrderGoodsId).._orderInfo.OrderGoodsNum.._orderInfo.OrderGoodsNum..tostring(_orderInfo.OrderMoney)..tostring(_orderInfo.OrderCharacterId)..tostring(_orderInfo.OrderServerId)..tostring(_orderInfo.OrderServerId)..U8AppKey)

    local url = U8serverOrder.."userID="..tostring(U8Info.userID).."&".."productID="..tostring(_orderInfo.OrderGoodsId).."&".."productName=".._orderInfo.OrderGoodsNum.."&".."productDesc=".._orderInfo.OrderGoodsNum.."&".."money="..tostring(_orderInfo.OrderMoney).."&".."roleID="..tostring(_orderInfo.OrderCharacterId).."&".."roleName=".."".."&".."serverID="..encodeURI(tostring(_orderInfo.OrderServerId)).."&".."serverName="..encodeURI(tostring(_orderInfo.OrderServerId)).."&".."extension=".."".."&".."dirUserID="..tostring(mUserId).."&".."sign="..crypto.md5(tostring(U8Info.userID)..tostring(_orderInfo.OrderGoodsId).._orderInfo.OrderGoodsNum.._orderInfo.OrderGoodsNum..tostring(_orderInfo.OrderMoney)..tostring(_orderInfo.OrderCharacterId)..tostring(_orderInfo.OrderServerId)..tostring(_orderInfo.OrderServerId)..U8AppKey)
    local request = network.createHTTPRequest(function(event)
        self:afterGetOrderRet(event)
    end, url, "GET")
    print("url:"..url)
    request:start()
end


function UEgihtSdkLoginManager:afterGetOrderRet(event)
    local request = event.request
    printf("onLoginHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        endLoading()
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", request:getResponseString())

            local loginResult = request:getResponseString()
            local jLoginResult= json.decode(loginResult)
            printTable(jLoginResult)
            self.u8OrderInfo.OrderId = jLoginResult.data.orderID
            print("jLoginResult.data.orderID:"..jLoginResult.data.orderID)
            if jLoginResult.state == 1 then
                if gType_SDK == AllSdkType.Sdk_HUAWEI or gType_SDK == AllSdkType.Sdk_HUAWEI2 then
                    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForHuawei", {tostring(tonumber(self.u8OrderInfo.OrderMoney))..".00",self.u8OrderInfo.OrderGoodsName,self.u8OrderInfo.OrderGoodsId,jLoginResult.data.orderID}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
                elseif gType_SDK == AllSdkType.Sdk_XIAOMI then
                    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForXiaomi", {tostring(srv_userInfo.diamond),tostring(srv_userInfo.vip),tostring(srv_userInfo.level),srv_userInfo.armyName or "", srv_userInfo.name, tostring(mUserId),loginServerList.serverName,jLoginResult.data.orderID,tonumber(self.u8OrderInfo.OrderMoney)}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
                elseif gType_SDK == AllSdkType.Sdk_GIONEE then
                    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForGionee", {jLoginResult.data.orderID,jLoginResult.data.extension.submit_time}, "(Ljava/lang/String;Ljava/lang/String;)V")
                elseif gType_SDK == AllSdkType.Sdk_DANGLE then
                    local pszTransNo = jLoginResult.data.orderID
                    local _money = self.u8OrderInfo.OrderMoney
                    local tab = {
                            _money,
                            self.u8OrderInfo.OrderGoodsName,
                            self.u8OrderInfo.OrderGoodsName,
                            pszTransNo,
                            loginServerList.serverName,
                            self.u8OrderInfo.OrderUserName
                        }
                    printTable(tab)
                    downJoySDK:downjoyPayment(tab)
                elseif (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
                    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "lua360Order", {tostring(tonumber(self.u8OrderInfo.OrderMoney)*100),self.u8OrderInfo.OrderGoodsName,self.u8OrderInfo.OrderGoodsId,self.u8OrderInfo.OrderCallBackUrl,self.u8OrderInfo.OrderGameName,self.u8OrderInfo.OrderUserName,self.u8OrderInfo.OrderGameUserId,self.u8OrderInfo.OrderCharacterId,self.u8OrderInfo.OrderServerId,self.u8OrderInfo.OrderChnlId,jLoginResult.data.orderID}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
                elseif gType_SDK == AllSdkType.Sdk_UC then
                    local pszCustomInfoStr = jLoginResult.data.orderID

                    local _bol = false
                    local _money = self.u8OrderInfo.OrderMoney
                    local tab = {_bol,_money,
                        self.u8OrderInfo.OrderServerId,
                        self.u8OrderInfo.OrderCharacterId,
                        self.u8OrderInfo.OrderUserName,
                        srv_userInfo.level,
                        pszCustomInfoStr,
                        self.u8OrderInfo.OrderCallBackUrl,
                        jLoginResult.data.orderID}
                    printTable(tab)
                    luaUCGameSdk:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_OPPO or gType_SDK == AllSdkType.Sdk_OPPO2  then
                    local tab = {jLoginResult.data.orderID,
                                 tostring(tonumber(self.u8OrderInfo.OrderMoney)*100),
                                 self.u8OrderInfo.OrderGoodsName,
                                 self.u8OrderInfo.OrderGoodsName,
                                 self.u8OrderInfo.OrderCallBackUrl}
                    printTable(tab)
                    OppoSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_LENOVO then
                    local _cpprivateinfo = ""
                    local tab = {
                        self.u8OrderInfo.OrderWaresid,
                        jLoginResult.data.orderID,
                        tonumber(self.u8OrderInfo.OrderMoney)*100,
                        _cpprivateinfo,
                    }
                    lenovoSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_BAIDU or gType_SDK == AllSdkType.Sdk_BAIDU2 then
                    local _extInfo = ""
                    local tab = {
                        jLoginResult.data.orderID,
                        self.u8OrderInfo.OrderGoodsName,
                        tostring(tonumber(self.u8OrderInfo.OrderMoney)*100),
                        _extInfo,
                    }
                    baiduSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_WDJ then
                    local tab = {
                        self.u8OrderInfo.OrderGoodsName,
                        tonumber(self.u8OrderInfo.OrderMoney)*100,
                        jLoginResult.data.orderID,
                    }
                    wdjSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_ANZHI then
                    local customInfo = jLoginResult.data.orderID
                    local tab = {
                        tonumber(self.u8OrderInfo.OrderMoney),
                        self.u8OrderInfo.OrderGoodsName,
                        customInfo,
                    }
                    anzhiSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_YYH then
                    local tab = {
                        self.u8OrderInfo.OrderGoodsId,
                        self.u8OrderInfo.OrderCallBackUrl,
                        jLoginResult.data.orderID,
                    }
                    YyhSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_ZY then
                    local tab = {
                        self.u8OrderInfo.OrderMoney,
                        self.u8OrderInfo.OrderGoodsName,
                        jLoginResult.data.orderID,
                    }
                     ZYSdk:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_VIVO then
                    local tab = {
                        jLoginResult.data.extension.transNo,
                        jLoginResult.data.extension.accessKey,
                        self.u8OrderInfo.OrderGoodsName,
                        self.u8OrderInfo.OrderGoodsName,
                        tonumber(self.u8OrderInfo.OrderMoney)*100,
                        tostring(srv_userInfo.vip),
                        tostring(mUserId),
                        srv_userInfo.name,
                        tostring(loginServerList.serverName),
                    }
                     VivoSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_VIVO2 then
                    local tab = {
                        jLoginResult.data.extension.transNo,
                        jLoginResult.data.extension.accessKey,
                        self.u8OrderInfo.OrderGoodsName,
                        self.u8OrderInfo.OrderGoodsName,
                        tonumber(self.u8OrderInfo.OrderMoney)*100,
                        tostring(srv_userInfo.vip),
                        tostring(mUserId),
                        srv_userInfo.name,
                        tostring(loginServerList.serverName),
                        tostring(srv_userInfo.diamond),
                        tostring(srv_userInfo.level),
                    }
                     VivoSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD2 then
                    local cpprivateinfo = "nothing"
                    local tab = {
                        jLoginResult.data.extension,
                        coolpadSDK.accessToken,
                        coolpadSDK.openId,
                    }
                    coolpadSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_KURUI then
                    local tab = {
                        jLoginResult.data.orderID,
                        tostring(tonumber(self.u8OrderInfo.OrderMoney)*100),
                        self.u8OrderInfo.OrderGoodsName,
                        tostring(self.u8OrderInfo.OrderGoodsId),
                        self.u8OrderInfo.OrderCallBackUrl,
                        tostring(self.u8OrderInfo.OrderCharacterId),
                        srv_userInfo.name,
                        tostring(srv_userInfo.level),
                        tostring(srv_userInfo.diamond)
                    }
                    KuRuiSDK:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_MEIZU then
                    local _payInfo = jLoginResult.data.extension
                    local payInfoStr = json.encode(_payInfo)
                    meizuSDK:pay(payInfoStr)
                elseif gType_SDK == AllSdkType.Sdk_QBAO then
                    local _payInfo = jLoginResult.data.extension
                    qbaoSDK:pay(_payInfo)
                elseif gType_SDK == AllSdkType.Sdk_LieBao then
                    local roleId = tostring(srv_userInfo.characterId)
                    local roleName = tostring(srv_userInfo.name)
                    local roleLevel = tostring(srv_userInfo.level)
                    local serverId = tostring(loginServerList.serverId)
                    local serverName = tostring(loginServerList.serverName)
                    local productId = tostring(self.u8OrderInfo.OrderGoodsId)
                    local productName = tostring(self.u8OrderInfo.OrderGoodsName)
                    local productDesc = tostring(self.u8OrderInfo.OrderGoodsName)
                    local price = tostring(self.u8OrderInfo.OrderMoney)
                    local attach = tostring(jLoginResult.data.orderID)
                    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForLieBao", 
                        {roleId, roleName, roleLevel, serverId, serverName, productId, productName, productDesc, price, attach}, 
                        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
                end
            else
               print("U8获取订单号失败："..jLoginResult.state)
            end
        end
    elseif event.name == "progress" then
        
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        endLoading()
    end
end

function UEgihtSdkLoginManager:getU8UserName()
    return self.u8UserName
end

function onIDFAResponse(event)
    -- print("onIDFAResponse")
    local request = event.request

    printf("onIDFAResponse - event.name = %s", event.name)
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print("response:"..response)
            print("IDFA上报成功--------------------------------------------")

            --IDFA保存本地
            GameData.IDFA = g_idfa
            GameState.save(GameData)
            

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
    end

    -- local code = request:getResponseStatusCode()
    -- if code ~= 200 then
    --     -- 请求结束，但没有返回 200 响应代码
    --     print(code)
    --     return
    -- end
 
    


end

