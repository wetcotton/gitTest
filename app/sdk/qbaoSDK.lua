qbaoSDK = {}

local isQbaoValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_QBAO

local classPath = "org/cocos2dx/qbao/QbaoSDK"

function qbaoSDK:initAndLogin()
	if  not isQbaoValid then
		return
	end
	luaj.callStaticMethod(classPath, "initAndLogin", {}, "()V")
end

-- //登陆回调
-- 	//success,1为登录成功，2为失败,3为取消
-- 	//msg = uid+"|"+session,或者失败信息
function qbao_loginResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		local uid = msg
		local str = eGSLoginType.eGslt_QBAO.."|"..uid.."|"..""
        print(str)
        luaLetUserLogin(str)
        startLoading()

	elseif success==2 then
	elseif success==3 then
	end
end

function qbaoSDK:pay(payInfo)
	if  not isQbaoValid then
		return
	end
	luaj.callStaticMethod(classPath, "pay", {payInfo}, "(Ljava/lang/String;)V")
end

function qbao_payResult( ... )
	-- body
end
-- //支付回调
-- 	//success,1为支付成功，2为失败,3为取消
-- 	//msg为描述信息
function qbao_payResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"~")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		
	elseif success==2 then
	elseif success==3 then
	end
end

function qbaoSDK:exitSDK()
	if  not isQbaoValid then
		return
	end
	luaj.callStaticMethod(classPath, "exitSDK", {}, "()V")
end

function qbao_exitResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		if DCAgent then
	        DCAgent.onKillProcessOrExit()
	    end
	    applicationWillEnterForeground()
	    print("防止进入后台")
	    g_notAllowToBackGround = true
    	print("关闭程序")
    	cc.Director:getInstance():endToLua()
	    
		
	elseif success==2 then
	elseif success==3 then
	end
end