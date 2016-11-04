
baiduSDK = {}

local isBaiduValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_BAIDU
	or gType_SDK == AllSdkType.Sdk_BAIDU2)

function baiduSDK:getAnnouncementInfo( )
	if  not isBaiduValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "getAnnouncementInfo", {}, "()V")
end

function baiduSDK:baiduLogin()
	if  not isBaiduValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "login", {}, "()V")
end

--登陆回调
--success,1为登录成功，2为失败，3为取消
--msg描述信息
function baidu_loginResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("百度登陆成功----------------------------")
		baiduSDK:showFloatButton(true)
		local uid = baiduSDK:getUid()
		local accessToken = baiduSDK:getAccessToken()
		print("uid: ",uid)
		print("accessToken: ",accessToken)

		local str = eGSLoginType.eGslt_BAIDU.."|"..uid.."|"..accessToken
        print(str)
        luaLetUserLogin(str)
        startLoading()

		-- local tab = {
		-- 	"sssssssssdeddddd",
		-- 	"商品名称ss",
		-- 	"2",
		-- 	"caonima",
		-- }
		-- baiduSDK:pay(tab)
		baiduSDK.isValid = true
	elseif success==2 then
		showTips("登录失败")
	elseif success==3 then
		showTips("取消登录")
	end
end

--登出
function baiduSDK:logout()
	if  not isBaiduValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "logout", {}, "()V")
end
function baiduSDK:exit()
	if  not isBaiduValid then
		return
	end
	if gType_SDK == AllSdkType.Sdk_BAIDU2 then
		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "exit", {}, "()V")
	end
	
end


function baiduSDK:getIsLogined()
	if  not isBaiduValid then
		return nil
	end
	local ok,ret = luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "isLogined", {}, "()Z")
	if ok then
		return ret
	else
		return nil
	end
end

--IsShow为真打开悬浮窗，为假关闭对话框
function baiduSDK:showFloatButton(IsShow)
	if  not isBaiduValid then
		return nil
	end
	luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "showFloatButton", {IsShow}, "(Z)V")
end

function baiduSDK:getUid()
	if  not isBaiduValid then
		return nil
	end
	local ok,ret = luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "getLoginUid", {}, "()Ljava/lang/String;")
	if ok then
		return ret
	else
		return nil
	end
end

function baiduSDK:getAccessToken()
	if  not isBaiduValid then
		return nil
	end
	local ok,ret = luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "getLoginAccessToken", {}, "()Ljava/lang/String;")
	if ok then
		return ret
	else
		return nil
	end
end

--切换账号回调
--success,1为切换成功，2为失败，3为取消
--msg为描述信息
function baidu_changeAccountCallback(retStr)
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

--以下全是字符串
--_cpOrderId,cp订单号
--_goodName，商品名称
--_totalAmount，支付金额
--_extInfo，额外信息
function baiduSDK:pay(pramas)
	if  not isBaiduValid then
		return
	end
	print("进入支付")
	local _cpOrderId,_goodName,_totalAmount,_extInfo = unpack(pramas)
	print("_cpOrderId: ",_cpOrderId)
	print("_goodName: ",_goodName)
	print("_totalAmount: ",_totalAmount)
	print("_extInfo: ",_extInfo)
	luaj.callStaticMethod("org/cocos2dx/baidu/baiduSDK", "pay", pramas, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

--支付回调
--success,1为支付成功，2为失败，3为取消,4为超时
--msg为描述信息
function baiduSDK:baidu_payCallback(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then

	elseif success==2 then

	elseif success==3 then
	end
end

--会话失败回调
function baidu_sessionInvalid(retStr)
	print("会话失败回调")
	baiduSDK.isValid = false
	local sceneName = display.getRunningScene().name
	print("sceneName:----------------------------------------------- "..sceneName)
	if sceneName=="loginScene" then
		
	else
		DCAccount.logout()
    	app:enterScene("LoginScene",{1})
        display.removeUnusedSpriteFrames()
	end
end

