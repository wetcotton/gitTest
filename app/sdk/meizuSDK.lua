meizuSDK = {}

local isMeiZuValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_MEIZU

local classPath = "org/cocos2dx/meizu/meizuSDK"

function meizuSDK:login()
	if  not isMeiZuValid then
		return
	end
	luaj.callStaticMethod(classPath, "login", {}, "()V")
end

-- //登陆回调
-- 	//success,1为登录成功，2为失败,3为取消
-- 	//msg = uid+"|"+session,或者失败信息
function meizu_loginResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"~")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		arr = string.split(msg,"|")
		local uid = arr[1]
		local session = arr[2]
		local str = eGSLoginType.eGslt_MEIZU.."|"..uid.."|"..session
        print(str)
        luaLetUserLogin(str)
        startLoading()

	elseif success==2 then
	elseif success==3 then
	end
end

function meizuSDK:pay(jsonStr)
	if  not isMeiZuValid then
		return
	end
	luaj.callStaticMethod(classPath, "pay", {jsonStr}, "(Ljava/lang/String;)V")
end

-- //支付回调
-- 	//success,1为支付成功，2为失败,3为取消
-- 	//msg为描述信息
function meizu_payResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"~")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		
	elseif success==2 then
	elseif success==3 then
	end
end