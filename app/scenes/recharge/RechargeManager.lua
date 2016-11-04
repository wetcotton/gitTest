-- Author: liufei
-- Date:   2015-11-18 17:23:27

RechargeManager = class("RechargeManager")
local httpNet = require("app.net.HttpNet")

--订单信息
local OrderInfo = {
                    OrderAccessToken = "",                                   --用户token
                    OrderQihooUserId = "",                                   --360账号ID
                    OrderMoney       = "",                                   --订单金额
                    OrderGoodsName   = "",                                   --商品名称
                    OrderGoodsId     = "",                                   --商品ID
                    OrderCallBackUrl = DIR_SERVER_URL.."/qihooPayCallback",  --支付结果回调的服务器URL
                    OrderGameName    = "战车世纪",                           --游戏名称
                    OrderUserName    = srv_userInfo.name,                    --游戏内用户昵称
                    OrderGameUserId  = tostring(mUserId),                    --全服用户ID
                    OrderCharacterId = tostring(srv_userInfo.characterId),   --单服角色ID
                    OrderServerId    = tostring(loginServerList.serverId),                  --服务器ID
                    OrderChnlId      = tostring(gType_Chnl),                 --渠道ID
                    OrderGoodsNum    = "",                                   --产品数量
                    OrderId          = "",                                   --订单号
                  }
local GoodsName = {
                    [1] = "60钻石",
                    [2] = "月卡",
                    [3] = "300钻石",
                    [4] = "980钻石",
                    [5] = "1980钻石",
                    [6] = "3280钻石",
                    [7] = "6480钻石",
                    [8] = "10钻石"
                  }
local DiamondNums = {
                    [1] = 60,
                    [2] = 250,
                    [3] = 300,
                    [4] = 980,
                    [5] = 1980,
                    [6] = 3280,
                    [7] = 6480,
                    [8] = 10
                }

if gType_SDK == AllSdkType.Sdk_360 then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/qihoo360/payCallback/1001"
elseif gType_SDK == AllSdkType.Sdk_360_2 then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/qihoo/payCallback/1001"
elseif gType_SDK == AllSdkType.Sdk_UC then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/uc/payCallback/1002"
elseif gType_SDK == AllSdkType.Sdk_OPPO then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/oppo/payCallback/1009"
elseif gType_SDK == AllSdkType.Sdk_OPPO2 then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/oppo2/payCallback/1062"
elseif gType_SDK == AllSdkType.Sdk_YYH then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/appchina/payCallback/1016"
elseif gType_SDK == AllSdkType.Sdk_KURUI then
    OrderInfo.OrderCallBackUrl = string.sub(DIR_SERVER_URL,1,string.len(DIR_SERVER_URL)-4).."8082".."/userver/pay/cooee/payCallback"
end

jifeidian = {}
if gType_SDK == AllSdkType.Sdk_LENOVO or gType_SDK == AllSdkType.Sdk_LENOVO2 then
    jifeidian = {
                    [1] = 37016,
                    [2] = 37017,
                    [3] = 37018,
                    [4] = 37019,
                    [5] = 37020,
                    [6] = 37021,
                    [7] = 37022,
                }
elseif gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD then
    jifeidian = {
                    [1] = 1,
                    [2] = 2,
                    [3] = 3,
                    [4] = 4,
                    [5] = 5,
                    [6] = 6,
                    [7] = 7,
                }
end



function RechargeManager:buyGoods(_index)
    print("OrderServerId.........")
    print(loginServerList.serverId)
    OrderInfo.OrderMoney = tostring(rechargeData[_index].money)
    OrderInfo.OrderGoodsId = tostring(_index)
    OrderInfo.OrderWaresid = jifeidian[tonumber(_index)]--计费点，部分平台需要
    OrderInfo.OrderGoodsName = GoodsName[_index]
    OrderInfo.OrderUserName    = srv_userInfo.name
    OrderInfo.OrderGameUserId  = tostring(mUserId)
    OrderInfo.OrderCharacterId = tostring(srv_userInfo.characterId)
    OrderInfo.OrderServerId    = tostring(loginServerList.serverId)
    OrderInfo.OrderChnlId      = tostring(gType_Chnl)
    OrderInfo.OrderGoodsNum = tostring(DiamondNums[_index]/10)
    local getOrderData = {}
    if gType_SDK == AllSdkType.Sdk_MSDK then
        if self:checkNofinishedOrder() == true then
            showTips("正在处理上一笔订单 请稍候")
            return
        end
        if luaMSDKConstant.LoginInfo.logintype == 1 then
            getOrderData["type"] = 3
        else
            getOrderData["type"] = 2
        end
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "payFromLUA", {DiamondNums[tonumber(OrderInfo.OrderGoodsId)]}, "(I)V")
        return
    end
    if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
        getOrderData["type"] = 4
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_UC then
        getOrderData["type"] = 5
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_HUAWEI or gType_SDK == AllSdkType.Sdk_HUAWEI2 then
        getOrderData["type"] = 6
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_DANGLE then
        getOrderData["type"] = 7
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_XIAOMI then
        getOrderData["type"] = 8
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_GIONEE then
        getOrderData["type"] = 9
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_LENOVO then
        getOrderData["type"] = eGSLoginType.eGslt_LENOVO
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_BAIDU or gType_SDK == AllSdkType.Sdk_BAIDU2  then
        getOrderData["type"] = eGSLoginType.eGslt_BAIDU
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_OPPO or gType_SDK == AllSdkType.Sdk_OPPO2 then
        getOrderData["type"] = eGSLoginType.eGslt_OPPO
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_YYH then
        getOrderData["type"] = eGSLoginType.eGslt_YYH
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_WDJ then
        getOrderData["type"] = eGSLoginType.eGslt_WDJ
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_ANZHI then
        getOrderData["type"] = eGSLoginType.eGslt_ANZHI
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_VIVO then
        getOrderData["type"] = eGSLoginType.eGslt_VIVO
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_VIVO2 then
        getOrderData["type"] = eGSLoginType.eGslt_VIVO
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_ZY then
        getOrderData["type"] = eGSLoginType.eGslt_ZY
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD2 then
        getOrderData["type"] = eGSLoginType.eGslt_ZY
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_KURUI then
        getOrderData["type"] = eGSLoginType.eGslt_KURUI
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_MEIZU then
        getOrderData["type"] = eGSLoginType.eGslt_MEIZU
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_QBAO then
        getOrderData["type"] = eGSLoginType.eGslt_QBAO
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        return
    end
    if gType_SDK == AllSdkType.Sdk_LieBao then
        getOrderData["type"] = eGSLoginType.eGslt_LieBao
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        
        return
    end
    if gType_SDK == AllSdkType.Sdk_LESHI then
        getOrderData["type"] = eGSLoginType.eGslt_LESHI
        UEgihtSdkLoginManager:getOrderId(OrderInfo)
        
        return
    end

    httpNet.connectHTTPServer(handler(self, self.onGetOrderIdResponse),"/getOrderId?data=",json.encode(getOrderData))
end

function RechargeManager:onGetOrderIdResponse(event)
    local request = event.request
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("error code ", request:getResponseStatusCode())
            return
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local orderResult = httpNet.getUnTeaResponseString(request)
            local jOrderResult= json.decode(orderResult)
            if jOrderResult["result"] == 1 then
                OrderInfo.OrderId = tostring(jOrderResult["data"].orderId)
                printTable(OrderInfo)
                startRechargeLoading(5)
                if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
                    self:sendBuyToSDK(tostring(tonumber(OrderInfo.OrderMoney)*100),OrderInfo.OrderGoodsName,OrderInfo.OrderGoodsId,OrderInfo.OrderCallBackUrl,OrderInfo.OrderGameName,OrderInfo.OrderUserName,OrderInfo.OrderGameUserId,OrderInfo.OrderCharacterId,OrderInfo.OrderServerId,OrderInfo.OrderChnlId,OrderInfo.OrderId)
                elseif gType_SDK == AllSdkType.Sdk_UC then
                    print("--------------------================调用sdk充值")
                    local pszCustomInfoStr = OrderInfo.OrderCharacterId.."|"..OrderInfo.OrderGoodsId.."|"..OrderInfo.OrderGameUserId.."|"..OrderInfo.OrderServerId.."|"..OrderInfo.OrderChnlId
                    print("自定义字符串：  "..pszCustomInfoStr)

                    local _bol = false
                    local _money = OrderInfo.OrderMoney
                    local tab = {_bol,_money,
                        OrderInfo.OrderServerId,
                        OrderInfo.OrderCharacterId,
                        OrderInfo.OrderUserName,
                        srv_userInfo.level,
                        pszCustomInfoStr,
                        OrderInfo.OrderCallBackUrl,
                        OrderInfo.OrderId}
                    printTable(tab)
                    luaUCGameSdk:pay(tab)
                elseif gType_SDK == AllSdkType.Sdk_MSDK then
                    -- self:checkNofinishedOrder()
                elseif gType_SDK == AllSdkType.Sdk_DANGLE then
                    
                end
            else
                print("error:"..jSerListResult["msg"])
                return
            end
        end
    elseif event.name == "progress" then
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
            luaStop360Waiting()
        end
    end
end

function RechargeManager:sendBuyToSDK(strMoney,strGoodsName,strGoodsId,strBackUrl,strGameName,strGameUsername,strGameUserId,strCharacterId,strServerId,strChnlID,strOrderId)
    if device.platform ~= "android" then
        return
    end

    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "lua360Order", {strMoney,strGoodsName,strGoodsId,strBackUrl,strGameName,strGameUsername,strGameUserId,strCharacterId,strServerId,strChnlID,strOrderId}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function luaUCPayResoult(code, pszOrderId,orderAmount,payWayId,pszPayWayName)
    endRechargeLoading()
    print("-------UC sdk支付回调")
    if code == luaUCStatusCode.SUCCESS then--获取订单成功，而并非支付成功

        print("UC---------获取订单成功")
        print("pszOrderId = ",pszOrderId)
        print("orderAmount = ",orderAmount)
        print("payWayId = ",payWayId)
        print("pszPayWayName = ",pszPayWayName)
        
    elseif code == luaUCStatusCode.PAY_USER_EXIT then--退出充值界面
        print("退出充值界面")
    else--支付失败
        --showTips("支付失败")
        print("支付失败")
    end
end

-- //支付回调
-- //success,1为支付成功，2为失败，3为取消
-- //msg为订单号、错误信息、错误信息
function luaDownJoyPayResult(code,msg)
    endRechargeLoading()
    if code==1 then
        print("downjoy支付成功")
    elseif code==2 then
        print("downjoy支付失败")
    elseif code==3 then
        print("downjoy支付取消")
    end
end


--360支付相关回调
function lua360PayResult(strState)
    local arr = string.split(strState, "|")
    if tonumber(arr[1]) == 0 then  --支付成功
        endRechargeLoading()
        showTips(arr[2])
        
        print("360---支付成功")

    elseif tonumber(arr[1]) == 1 then --支付失败
        endRechargeLoading()
        showTips(arr[2])
    elseif tonumber(arr[1]) == -1 then --支付取消
        endRechargeLoading()
        showTips(arr[2])
    else --其他错误
        endRechargeLoading()
        showTips(arr[2])
    end
end

--MSDK支付回调
function luaSendMSDKBuyOK(str)
    local arr = string.split(str, "|")
    if tonumber(arr[1]) == 0 then --支付成功
        startRechargeLoading()
        RechargeManager:sendMSDKSearchRequest(str, 1, true)
        
        print("msdk---支付成功")

    else
        endRechargeLoading()
        RechargeManager:sendMSDKSearchRequest(str, 1, false)
    end
end

function RechargeManager:sendMSDKSearchRequest(str, justPay, isSave)
    local arr = string.split(str, "|")
    if isSave then
        RechargeManager:saveMSDKOrder(str)
    end

    sendData={}
    sendData["retCode"] = tonumber(arr[1])
    sendData["justPay"] = justPay
    sendData["loginType"] = tonumber(arr[2])
    sendData["openId"] = arr[3]
    if sendData["loginType"] == 2 then
        sendData["pay_tocken"] = arr[4]
        sendData["accTocken"] = ""
    else
        sendData["accTocken"] = arr[4]
        sendData["pay_tocken"] = ""
    end
    sendData["pf"] = arr[5]
    sendData["pfkey"] = arr[6]
    sendData["amount"] = tonumber(arr[7])
    sendData["isDebug"] = luaMSDKConstant.LoginInfo.isdebug
    self.curAmount = sendData["amount"]
    m_socket:SendRequest(json.encode(sendData), CMD_MSDK_RECHARGE_SEARCH, RechargeManager,RechargeManager.onSendSearch)
end

function RechargeManager:onSendSearch(cmd)
    
    if cmd.result ~= 1 then
        endRechargeLoading()
        showTips(cmd.msg)
        return
    end

    if cmd.result == 1 and self.curAmount ~=nil and self.curAmount ~= 0 then
        RechargeManager:removeMSDKOrder()
    end
end

function RechargeManager:checkNofinishedOrder()
    local hasNoFinished = false
    if GameData.MSDKOrder == nil then
        return hasNoFinished
    end
    printTable(GameData.MSDKOrder)
    for k,v in pairs(GameData.MSDKOrder) do
        if k == tostring(mUserId..loginServerList.serverId) then
            for km,vm in pairs(v) do
                local arr = string.split(vm, "|")
                local tmpStr = "0".."|"..luaMSDKConstant.LoginInfo.logintype.."|"..luaMSDKConstant.LoginInfo.userid.."|"..luaMSDKConstant.LoginInfo.userkey.."|"..luaMSDKConstant.LoginInfo.pf.."|"..luaMSDKConstant.LoginInfo.pfkey.."|"..arr[7]
                RechargeManager:sendMSDKSearchRequest(tmpStr, 0)
                hasNoFinished = true
                break
            end
            break
        end
    end
    return hasNoFinished
end

function RechargeManager:saveMSDKOrder(str)
    if GameData.MSDKOrder == nil then
        GameData.MSDKOrder = {}
        GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] = {}
    end
    if GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] == nil then
        GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] = {}
    end
    table.insert(GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)],#GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] + 1, str)
    GameState.save(GameData)
end

function RechargeManager:removeMSDKOrder()
    if GameData.MSDKOrder == nil or GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] == nil then
        return
    end 
    GameData.MSDKOrder[tostring(mUserId..loginServerList.serverId)] = {}
    GameState.save(GameData)
end

function lua360ReLogin(str)
    DCAccount.logout()
    display.removeUnusedSpriteFrames()
    app:enterScene("LoginScene",{1})
end

function luaHuaweiReLogin(str)
    local function reLogin()
        DCAccount.logout()
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    end
    scheduler.performWithDelayGlobal(reLogin, 1)
end

--充值到账返回接口
function RechargeManager:rechargeRet(data)
    srv_userInfo.diamond = data.dia
    srv_userInfo.vip = data.vip
    srv_userInfo.paidDiad = data.paidDiad
    

    if mainscenetopbar then
        mainscenetopbar:setDiamond()
    end
    endRechargeLoading()
    showTips("您充值的"..data.amount.."元，"..data.addDia.."钻石已到账，请注意查收。",nil,
        display.cx, display.cy+230)
    --统计begin
    DCVirtualCurrency.paymentSuccess("空",OrderInfo.OrderGoodsId,tonumber(OrderInfo.OrderMoney),"CNY","android支付")
    local map = {
                    productId = OrderInfo.OrderGoodsId,
                    amount=OrderInfo.OrderMoney,
                    userNick = OrderInfo.OrderUserName,
                    characterId = OrderInfo.OrderCharacterId,
                    userId = OrderInfo.OrderGameUserId,
                    gainDiamond = data.addDia
            }
    printTable(map)
    if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
        DCEvent.onEvent("支付成功，360",map)
    elseif gType_SDK == AllSdkType.Sdk_UC then
        DCEvent.onEvent("支付成功，UC",map)
    elseif gType_SDK == AllSdkType.Sdk_MSDK then
        DCEvent.onEvent("支付成功，msdk",map)
    elseif gType_SDK == AllSdkType.Sdk_DANGLE then
        DCEvent.onEvent("支付成功，downJoy",map)
    end
    --统计end

    if rechargeLayer.Instance then
        rechargeLayer.Instance.rechargeRecordInfo.paidDiad = data.paidDiad
        --删除首充双倍记录
        for i,value in ipairs(rechargeLayer.Instance.rechargeRecordInfo.double) do
            if value==rechargeLayer.Instance.curValue.type then
                table.remove(rechargeLayer.Instance.rechargeRecordInfo.double, i)
                break
            end
        end
        rechargeLayer.Instance:reloadData()
        rechargeLayer.Instance:reloadGoodsUI()
        if tonumber(data.amount) == 25 then
            rechargeLayer.Instance.rechargeRecordInfo.validity = rechargeLayer.Instance.rechargeRecordInfo.validity + 30
        end
    end
    if MainScene_Instance then
        display.getRunningScene().vipNum:setString(srv_userInfo.vip)
    end
    DCCoin.gain("充值获得钻石","钻石",data.addDia,data.addDia+srv_userInfo.diamond)
end