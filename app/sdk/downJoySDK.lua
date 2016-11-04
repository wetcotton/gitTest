--
-- Author: Huang YuZhao
-- Date: 2015-12-2 10:22:38
--

downJoySDK = {}

function downJoySDK:initDownjoy()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "initDownjoy", {}, "()V")
end

--初始化成功
function downJoyCallback_initResult()
	
	--控制游戏是加载加密包还是原始文件
	GAME_RELEASE = false
	-- 清除fileCached 避免无法加载新的资源。
	cc.FileUtils:getInstance():purgeCachedEntries()
	if GAME_RELEASE then
		cc.LuaLoadChunksFromZIP("lib/launcher.zip") 
	end
	-- package.loaded["launcher.launcher"] = nil
	-- require("launcher.launcher")
	package.loaded["launcher.jsonUnzip"] = nil
    require("launcher.jsonUnzip")
	
end

function downJoySDK:downjoyLogin()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "downjoyLogin", {}, "()V")
end

--登陆回调
--success,1为登录成功，2为失败，3为取消
--msg为LoginInfo、错误信息、错误信息
function downJoyCallback_loginResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("sdk登录成功")

		--luaUCGameSdk:notifyZone("66区-风起云涌", "R29924", "Role-大漠孤烟")
		local _loginInfoStr = string.sub(msg,10,string.len(msg))
		print("_loginInfoStr: ",_loginInfoStr)

		print("开始解析")
		_loginInfoStr = "local xxx = ".._loginInfoStr.." return xxx"
		local fun = loadstring(_loginInfoStr)
        local ret, _loginInfo = pcall(fun)
        printTable(_loginInfo)
		print("---------------------\n")
		print("----------解析完毕")

        local _data = {token = _loginInfo.token,umid = _loginInfo.umid}
        local httpNet = require("app.net.HttpNet")

      	local jsonTab = {mid = _loginInfo.umid,token = _loginInfo.token}
      	downJoyMid = _loginInfo.umid
			        print("jsonTab,u8登录")
			        printTable(jsonTab)
			        local str = json.encode{jsonTab}
			        print("str---------11",str)
			        str=string.sub(str,2,string.len(str)-1)
			        print("str---------22",str)
			        luaLetUserLogin(str)
			        startLoading()
	elseif success==2 then

	elseif success==3 then

	end
end

function downJoySDK:downjoyExit()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "downjoyExit", {}, "()Z")
end

--success,1为退出成功，2为失败，msg没用
function downJoyCallback_ExitResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		if DCAgent then
            DCAgent.onKillProcessOrExit()
        end
		cc.Director:getInstance():endToLua()
	elseif success==2 then

	end
end

function downJoySDK:downjoyLogout()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "downjoyLogout", {}, "()Z")
end

--success,1为登出成功，2为失败，msg为失败信息
function downJoyCallback_logoutResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("sdk登出成功")
		local sceneName = display.getRunningScene().name
		print("sceneName:----------------------------------------------- "..sceneName)
		if sceneName=="loginScene" then
			self:downjoyLogin()
		else
			DCAccount.logout()
	    	app:enterScene("LoginScene",{1})
	        display.removeUnusedSpriteFrames()
		end
	elseif success==2 then

	end
end

--登出帐号
function downJoySDK:downjoyInfo()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "downjoyInfo", {}, "()V")
end

-- //获取用户信息回调
-- //success,1为获取用户信息成功，2为失败，
-- //msg为用户信息或失败信息
function downJoyCallback_userInfoResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then

	elseif success==2 then

	end
end

-- money  人民币，元，精确到小数点后两位
-- pszProductName   商品名称
-- pszBody  商品描述
-- pszTransNo  cp订单号，计费结果通知时原样返回，尽量不要使用除字母和数字之外的特殊字符。
-- pszServerName 记录订单产生的服务器，没有可传“”
-- pszPlayerName 记录订单产生的玩家名称，没有可传“”
function downJoySDK:downjoyPayment(pramas)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_DANGLE  then
		return
	end

	local money,pszProductName,pszBody,pszTransNo,pszServerName,pszPlayerName = unpack(pramas)
	print("money   ",money)
	print("pszProductName   ",pszProductName)
	print("pszBody   ",pszBody)
	print("pszTransNo   ",pszTransNo)
	print("pszServerName   ",pszServerName)
	print("pszPlayerName   ",pszPlayerName)

	luaj.callStaticMethod("org/cocos2dx/lua/downJoySDK", "downjoyPayment", pramas, "(FLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

-- //支付回调
-- //success,1为支付成功，2为失败，3为取消
-- //msg为订单号、错误信息、错误信息
function downJoyCallback_payResult(retStr)--(success,msg)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	print("当乐支付回调",retStr)
	luaDownJoyPayResult(success,msg)
	
end