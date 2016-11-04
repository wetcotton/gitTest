wdjSDK = {}

local isWdjValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_WDJ

--登录
function wdjSDK:login()
	if  not isWdjValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/wdj/wdjSDK", "login", {}, "()V")
end

-- //登陆回调
-- 	//success,1为登录成功,2为失败
-- 	//msg为id#token，或者失败信息
function wdj_loginResult( retStr )
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		arr = string.split(msg,"#")
		local id = arr[1]
		local token = arr[2]
		print("id:",id)
		print("token:",token)

		local str = eGSLoginType.eGslt_WDJ.."|"..id.."|"..token
        print(str)
        luaLetUserLogin(str)
        startLoading()

     --    local tab = {
	    --     "订单名称",
	    --     2,
	    --     "aaaaaaaaaaaaaaaassdffghh"
	    -- }
     --    wdjSDK:pay(tab)

	elseif success==2 then
		print("sdk登录失败")
		if LoginSceneInstance==nil then
			display.removeUnusedSpriteFrames()
        	app:enterScene("LoginScene",{1})
		end
	end
end

--注销
function wdjSDK:logout()
	if  not isWdjValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/wdj/wdjSDK", "logout", {}, "()V")
end

-- //注销回调
-- 	//success,1为注销成功,2为失败，3为取消
function wdj_logoutResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		
	elseif success==2 then
		print("sdk注销失败")
	elseif success==3 then
	end
end

-- /*
-- 	 * _orderName,订单名称,String
-- 	 * _moneyInFen，订单金额，单位分,long
-- 	 * _outTradeNo，订单号,String
-- 	 */
function wdjSDK:pay(pramas)
	if  not isWdjValid then
		return
	end
	print("进入支付")
	local _orderName,_moneyInFen,_outTradeNo = unpack(pramas)
	print("_orderName:",_orderName)
	print("_moneyInFen:",_moneyInFen)
	print("_outTradeNo:",_outTradeNo)
	luaj.callStaticMethod("org/cocos2dx/wdj/wdjSDK", "pay", pramas, "(Ljava/lang/String;ILjava/lang/String;)V")
end

-- //支付回调
-- 	//success,1为支付成功,2为失败
-- 	//msg为游戏订单号或错误信息
function wdj_payResult(retStr )
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then

	elseif success==2 then
		print("sdk支付失败")
	end
end