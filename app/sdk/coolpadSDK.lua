coolpadSDK = {}

local isCoolpadValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and 
	(gType_SDK == AllSdkType.Sdk_COOLPAD or gType_SDK == AllSdkType.Sdk_COOLPAD2)

function coolpadSDK:login()
	if  not isCoolpadValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/coolpad/coolpadSDK", "login", {}, "()V")
end

function coolpadSDK:loginNew()
	if  not isCoolpadValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/coolpad/coolpadSDK", "loginNew", {}, "()V")
end

function coolpad_loginResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		local authCode = msg
		local str = eGSLoginType.eGslt_COOLPAD.."|"..authCode.."|"..""
        print(str)
        luaLetUserLogin(str)
        startLoading()

	elseif success==2 then

	elseif success==3 then
	end
end

function coolpadSDK:showFLoatMenu(bIsShow)
	if  not isCoolpadValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/coolpad/coolpadSDK", "login", {bIsShow}, "(Z)V")
end

function coolpadSDK:logout()
	if  not isCoolpadValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/coolpad/coolpadSDK", "logout", {}, "()V")
end

function coolpad_changeAccResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		local sceneName = display.getRunningScene().name
		print("sceneName:----------------------------------------------- "..sceneName)
		if sceneName=="loginScene" then
			
		else
			DCAccount.logout()
	    	app:enterScene("LoginScene",{1})
	        display.removeUnusedSpriteFrames()
		end
	elseif success==2 then

	elseif success==3 then
	end
end

-- /*
-- 	 * cporderid  本次支付的订单号，需要保证在应用范围内唯一
-- 	 * accessToken
-- 	 * openId
-- 	 *  */
function coolpadSDK:pay(pramas)
	if  not isCoolpadValid then
		return
	end
	local appuserid,cporderid,accessToken,openId,price,waresid,cpprivateinfo = unpack(pramas)
	print("cporderid:",cporderid)
	print("accessToken:",accessToken)
	print("openId:",openId)
	luaj.callStaticMethod("org/cocos2dx/coolpad/coolpadSDK", "pay",pramas, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end