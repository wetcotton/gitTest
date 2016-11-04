--
-- Author: Huang YuZhao
-- Date: 2015-10-14 16:12:38
--
luaUCGameSdk = {}

--错误信息级别，记录错误日志
luaUCGameSdk.LOGLEVEL_ERROR = 0;
--警告信息级别，记录错误和警告日志
luaUCGameSdk.LOGLEVEL_WARN = 1;
--调试信息级别，记录错误、警告和调试信息，为最详尽的日志级别
luaUCGameSdk.LOGLEVEL_DEBUG = 2;

--竖屏
luaUCGameSdk.ORIENTATION_PORTRAIT = 0;
--横屏
luaUCGameSdk.ORIENTATION_LANDSCAPE = 1;

--简版
luaUCGameSdk.LOGINFACETYPE_USE_WIDGET = 0;
--标准版
luaUCGameSdk.LOGINFACETYPE_USE_STANDARD = 1;

cc.PLATFORM_OS_ANDROID = 3

--local g_bLogin_UC = 1
local luaj = nil
print("当前： "..cc.Application:getInstance():getTargetPlatform())
print("安卓："..cc.PLATFORM_OS_ANDROID)
if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
	print("是安卓平台")
	luaj = require("framework.luaj")
	require("framework.debug")
else
	print("其他平台")
end

function applicationDidEnterBackground()
    cc.Director:getInstance():stopAnimation();
    cc.Director:getInstance():pause();
    if audio then
	    audio.pauseMusic();
	    audio.pauseAllSounds();
	end
    print("调用进入后台------------------------1111111111111")
end

function applicationWillEnterForeground()
  print("当前场景是否被主动暂停了？")
  print(g_bIsScenePaused)
    if not g_bIsScenePaused then
      cc.Director:getInstance():resume();
    end
    cc.Director:getInstance():startAnimation();

    if audio then
	    audio.resumeMusic();
	    audio.resumeAllSounds();
	end

    print("调用从后台恢复------------------------2222222222222")
end

--[[
	 *设置日志级别：
	 * @param logLevel
	 *   0=错误信息级别，记录错误日志，
	 *   1=警告信息级别，记录错误和警告日志，
	 *   2=调试信息级别，记录错误、警告和调试信息，为最详尽的日志级别。
	 *   Constants 中定义了用到的常量。
	 * @return
	 *
--]]
function luaUCGameSdk:setLogLevel(logLevel)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "setLogLevel", {logLevel}, "(I)V")
end
--[[
	 * 设置屏幕方向（0=竖屏，1=横屏），默认为竖屏（0）。
	 * @param orientation 屏幕方向，0=竖屏，1=横屏，Constants 中定义了用到的常量。
	 */
--]]
function luaUCGameSdk:setOrientation(orientation)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "setOrientation", {orientation}, "(I)V")
end
--[[
	 * 设置屏幕登录界面类型（0=简版，1=标准版），默认为（0）.
	 * @param loginFaceType 登录界面类型，0=简版，1=标准版
	 */
--]]
function luaUCGameSdk:setLoginUISwitch(loginFaceType)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "setLoginUISwitch", {loginFaceType}, "(I)V")
end


--[[
	 * 初始化SDK
	 * @param debugMode 是否联调模式， false=连接SDK的正式生产环境，true=连接SDK的测试联调环境
	 * @param logLevel 日志级别，
	 *   0=错误信息级别，记录错误日志，
	 *   1=警告信息级别，记录错误和警告日志，
	 *   2=调试信息级别，记录错误、警告和调试信息，为最详尽的日志级别
	 * @param cpId 游戏合作商ID，该ID由UC游戏中心分配，唯一标识一个游戏合作商
	 * @param gameId 游戏ID，该ID由UC游戏中心分配，唯一标识一款游戏
	 * @param serverId 游戏服务器（游戏分区）标识，由UC游戏中心分配
	 * @param serverName 游戏服务器（游戏分区）名称
	 * @param enablePayHistory 是否启用支付查询功能
	 * @param enableLogout 是否启用用户切换功能
	 *
	 */
--]]

function luaUCGameSdk:initSDK(pramas)
	local debugMode, logLevel, cpId, gameId,serverId, pszServerName, enablePayHistory,enableLogout = unpack(pramas)
	print("--------------------打印：")

	print("cpId: "..cpId.."gameId: "..gameId.." serverId: "..serverId.." pszServerName: "..pszServerName)
	print("enableLogout: ")
	print(enableLogout)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "initSDK", {debugMode, logLevel, cpId, 
		gameId,serverId, pszServerName, enablePayHistory,enableLogout}, "(ZIIIILjava/lang/String;ZZ)V")
end

--sdk初始化完毕的回调函数
function sdkCallback_initResultCallback(retStr)--(code,msg)
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local msg = arr[2]
	if code == luaUCStatusCode.SUCCESS then
		luaUCSdkConstant.s_inited = true
		print("sdk初始化成功")
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
	else
		print("sdk初始化失败,code: "..code.."  msg: "..msg)
		print("-----------------------111")
		local lab = display.newTTFLabel({
	            text="当前没有网络，5秒之后退出游戏", 
	            size=30, 
	            color=cc.c3b(255, 255, 255),
	            })
	    lab:setPosition(display.cx, display.cy)
	    display.getRunningScene():addChild(lab,55)
	    local scheduler = require("framework.scheduler")
	    local handle = nil
	    local acc = 5
	    local function onInterval()
	    	acc = acc-1
	    	if acc == 0 then
	    		cc.Director:getInstance():endToLua()
	    		scheduler.unscheduleGlobal(handle)
	    	end
	    	lab:setString("当前没有网络，"..acc.."秒之后退出游戏")
	    end
	    handle = scheduler.scheduleGlobal(onInterval, 1)
	end
end

--[[
	 * 调用SDK的用户登录（可支持UC账号登录或游戏老账号登录）
	 * @param enableGameAccount 是否允许使用游戏老账号（游戏自身账号）登录
	 * @param gameAccountTitle 游戏老账号（游戏自身账号）的账号名称，如“三国号”、“风云号”等。
	 *         如果 enableGameAccount 为false，此参数的值设为空字符串即可。
	 * @param gameUserLoginOperation 游戏老账号登录操作对象，如果 enableGameAccount 为false，此参数设为空即可，如果 enableGameAccount 为true，此对象不可为空。
	 *
	 */
--]]
function luaUCGameSdk:login(enableGameAccount, pszGameAccountTitle)
	print("enableGameAccount: ")
	print(enableGameAccount)
	print("pszGameAccountTitle: "..pszGameAccountTitle)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "login", {enableGameAccount, pszGameAccountTitle}, "(ZLjava/lang/String;)V")
end

--登录结果的回调函数
function sdkCallback_loginResultCallback(retStr)--(code,msg)
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local msg = arr[2]
	if code == luaUCStatusCode.SUCCESS then
		print("sdk登录成功")
		luaUCSdkConstant.s_logined = true
		luaUCSdkConstant.s_sid = luaUCGameSdk:getSid()
		print("login succeeded: sid = "..luaUCSdkConstant.s_sid)
		luaUCGameSdk:createFloatButton()
		luaUCGameSdk:showFloatButton(0,30,true)
		--luaUCGameSdk:notifyZone("66区-风起云涌", "R29924", "Role-大漠孤烟")

		-- local httpNet = require("app.net.HttpNet")
		-- local logindata = {}
		-- logindata["userName"] = "asdfss"
  --       logindata["password"] = "asdfss"
  --       logindata.type = 1
  --       if device.platform == "ios" then
  --           logindata["mobileOS"] = 1
  --       elseif device.platform == "android" then
  --           logindata["mobileOS"] = 2
  --       else
  --           logindata["mobileOS"] = 0
  --       end
  --       httpNet.connectHTTPServer(handler(LoginSceneInstance, LoginSceneInstance.onLoginHttpResponse), "/login?data=", json.encode(logindata))
        
        local str = eGSLoginType.eGslt_UC.."|"..luaUCSdkConstant.s_sid.."|"..""
        print(str)
        luaLetUserLogin(str)
        startLoading()
	elseif code == luaUCStatusCode.LOGIN_EXIT then --登录界面退出，返回到游戏画面
		print("login UI exit, back to game UI")
	else
		print("sdk登录失败,code: "..code.."  msg: "..msg)
	end
end

--处理游戏老账号（游戏自身账号，非UC账号）登录验证逻辑的回调函数
--[[
/*
 * 定义游戏老账号登录验证处理的回调函数，如果游戏需要支持老账号登录，应实现此回调函数，接收用户名和密码，验证后把结果和从游戏服务器获得的 sid 返回给SDK。
 * @param pszUsername 	用户名
 * @param pszPassword 	用户输入的密码
 * @param lpSid			通过此参数将从游戏服务器获得的 sid 返回给 SDK
 * @resturn 			返回验证和登录的状态，参考 CUCStatusCode 中定义的常量（LOGIN_GAME_USER_*）
 */
 --]]
function sdkCallback_gameUserLoginCallback(retStr)--(pszUsername,pszPassword, lpSid)
	
end

--[[
	 * 返回用户登录后的会话标识，此标识会在失效时刷新，游戏在每次需要使用该标识时应从SDK获取
	 * @return 用户登录会话标识
	 *
	 */
--]]
function luaUCGameSdk:getSid()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	print("---------------------getSid------------11")
	local ok,ret = luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "getSid", {}, "()Ljava/lang/String;")
	print("---------------------getSid------------22")
	print(ok)
	print(ret)
	print("---------------------getSid------------33")
	if ok then
		return ret
	else
		print(ret)
		return ""
	end
end
--[[
	 * 退出当前登录的账号
	 *
--]]
function luaUCGameSdk:logout()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "logout", {}, "()V")
end

--登出通知的回调函数
function sdkCallback_logoutCallback(retStr)--(code,msg)
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local msg = arr[2]
	if code == luaUCStatusCode.SUCCESS then
		luaUCSdkConstant.s_inited = false
		luaUCSdkConstant.s_sid = ""
		print("sdk登出成功")
		local sceneName = display.getRunningScene().name
		print("sceneName:----------------------------------------------- "..sceneName)
		if sceneName=="loginScene" then
			luaUCGameSdk:login(false,"")
		else
			luaUCGameSdk:showFloatButton(0,30,false)
			DCAccount.logout()
	    	app:enterScene("LoginScene",{1})
	        display.removeUnusedSpriteFrames()
		end
	else
		print("sdk登出失败,code: "..code.."  msg: "..msg)
	end
end

--[[
/**
	 * 在当前 Activity 上创建九游的悬浮按钮
	 * @param floatMenuCallback 接收悬浮菜单打开或关闭SDK界面通知的回调函数
	 */
--]]
function luaUCGameSdk:createFloatButton()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "createFloatButton", {}, "()V")
end

--悬浮菜单打开或关闭SDK界面通知的回调函数
function sdkCallback_floatMenuCallback(retStr)--(code,msg)
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local msg = arr[2]
	if code == luaUCStatusCode.SDK_OPEN then
		luaUCSdkConstant.s_inited = true
		print("打开悬浮窗")
	elseif code == luaUCStatusCode.SDK_CLOSE then
		print("关闭悬浮窗")
	else
		print("sdk初始化失败,code: "..code.."  msg: "..msg)
	end
end

--[[
/**
	 * 显示/隐藏九游的悬浮按钮
	 * @param x 悬浮按钮显示位置的横坐标，单位：%，支持小数。该参数只支持 0 和 100，分别表示在屏幕最左边或最右边显示悬浮按钮。
	 * @param y 悬浮按钮显示位置的纵坐标，单位：%，支持小数。例如：80，表示悬浮按钮显示的位置距屏幕顶部的距离为屏幕高度的 80% 。
	 * @param visible true=显示 false=隐藏，隐藏时x,y的值忽略
	 */
--]]
function luaUCGameSdk:showFloatButton(x, y, visible)
	x = 0
	y = 30
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "showFloatButton", {x, y, visible}, "(FFZ)V")
end

--销毁当前 Activity 的九游悬浮按钮
function luaUCGameSdk:destroyFloatButton()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "destroyFloatButton", {}, "()V")
end
--[[
/**
	 * 提交玩家选择的游戏分区及角色信息
	 *
	 * @param pszZoneName 玩家实际登录的分区名称
	 * @param pszRoleId 角色编号
	 * @param pszRoleName 角色名称
	 */
--]]
function luaUCGameSdk:notifyZone(pszZoneName, pszRoleId,pszRoleName)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "notifyZone", {}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end
--[[
/**
	 * 执行充值下单操作，此操作会调出充值界面。
	 * @param allowContinuousPay 设置是否允许连接充值，true表示在一次充值完成后在充值界面中可以继续下一笔充值，false表示只能进行一笔充值即返回游戏。
	 * @param amount 充值金额。默认为0，如果不设或设为0，充值时用户从充值界面中选择或输入金额；如果设为大于0的值，表示固定充值金额，不允许用户选择或输入其它金额。
	 * @param serverId 当前充值的游戏服务器（分区）标识，此标识即UC分配的游戏服务器ID
	 * @param pszRoleId 当前充值用户在游戏中的角色标识
	 * @param pszRoleName 当前充值用户在游戏中的角色名称
	 * @param pszGrade 当前充值用户在游戏中的角色等级
	 * @param pszCustomInfo 充值自定义信息，此信息作为充值订单的附加信息，充值过程中不作任何处理，仅用于游戏设置自助信息，比如游戏自身产生的订单号、玩家角色、游戏模式等。
	 *    如果设置了自定义信息，UC在完成充值后，调用充值结果回调接口向游戏服务器发送充值结果时将会附带此信息，游戏服务器需自行解析自定义信息。
	 *    如果不需设置自定义信息，将此参数置为空字符串即可。
	 * @param notifyUrl支付回调地址
     * @param transactionNum自有交易号
     * 
	 */
--]]
function luaUCGameSdk:pay(pramas)
	printTable(pramas)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end

	local allowContinuousPay,amount, serverId, pszRoleId, pszRoleName, pszGrade, pszCustomInfo,pszNofityUrl, pszTransactionNum = unpack(pramas)

	print("allowContinuousPay   ",allowContinuousPay)
	print("amount   ",amount)
	print("serverId   ",serverId)
	print("pszRoleId   ",serverId)
	print("pszRoleName   ",pszRoleName)
	print("pszGrade   ",pszGrade)
	print("pszCustomInfo   ",pszCustomInfo)
	print("pszNofityUrl   ",pszNofityUrl)
	print("pszTransactionNum   ",pszTransactionNum)
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "pay", 
		{allowContinuousPay,amount, serverId, pszRoleId, pszRoleName, pszGrade, pszCustomInfo,pszNofityUrl, pszTransactionNum},
		 "(ZFILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

--[[
/*
 * 定义SDK充值下单结果回调函数
 * @param code 			状态码，参考 CUCStatusCode 中定义的常量
 * @param pszOrderId 	UC充值中心产生的订单号
 * @param orderAmount 	用户选择的充值金额（元）
 * @param payWayId		充值时用户选择的支付渠道ID
 * @param pszPayWayName 充值时用户选择的支付渠道名称
 */
 --]]
function sdkCallback_payCallback(retStr)--(code, pszOrderId,orderAmount,payWayId,pszPayWayName)
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local pszOrderId = arr[2]
	local orderAmount = tonumber(arr[3])
	local payWayId = tonumber(arr[4])
	local pszPayWayName = arr[5]
	
	luaUCPayResoult(code, pszOrderId,orderAmount,payWayId,pszPayWayName)
	
end

--[[
* 打开U点充值界面
--]]
function luaUCGameSdk:uPointCharge()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "uPointCharge", {}, "()V")
end

--U点充值界面关闭的回调函数
function sdkCallback_uPointChargeCallback(retStr)--(code,msg)
	
end

--[[
* 进入九游社区（用户中心）
--]]
function luaUCGameSdk:enterUserCenter()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "enterUserCenter", {}, "()V")
end

--九游社区（用户中心）界面关闭的回调函数
function sdkCallback_userCenterCallback(retStr)--(code,msg)
	
end
--[[
/**
	 * 进入SDK的某一指定界面
	 * @param business 业务标识
	 */
--]]
function luaUCGameSdk:enterUI(business)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "enterUI", {business}, "(Ljava/lang/String;)V")
end

--SDK界面打开或关闭通知的回调函数
function sdkCallback_enterUICallback(retStr)--(code,msg)
	print("received enterUI_callback: code= "..code..", msg= "..pszmsg )
end
--[[
/**
	 * 提交游戏扩展数据，在登录成功以后可以调用。具体的数据种类和数据内容定义，请参考“开发参考说明书”。
	 *
	 * @param dataType 数据种类
	 * @param dataStr 数据内容，是一个 JSON 字符串。
	 *
	 */
--]]
function luaUCGameSdk:submitExtendData(dataType, dataStr)
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "submitExtendData", {dataType, dataStr}, "(Ljava/lang/String;Ljava/lang/String;)V")
end
--[[
/**
	 * 退出SDK，游戏退出前必须调用此方法，以清理SDK占用的系统资源。如果游戏退出时不调用该方法，可能会引起程序错误。
	 *
	 */
--]]
function luaUCGameSdk:exitSDK()
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID or gType_SDK ~= AllSdkType.Sdk_UC  then
		return
	end
	luaj.callStaticMethod("cn/uc/gamesdk/jni/UCGameSdk", "exitSDK", {}, "()V")
end

--退出sdk的回调
function sdkCallback_exitCallback(retStr)--(code,msg)
	print("退出sdk的回调")
	local arr = string.split(retStr,"|")
	local code = tonumber(arr[1])
	local msg = arr[2]
	if code==-703 then --继续游戏
		print("继续游戏")
	elseif code==-702 then  --退出游戏
		if DCAgent then
            DCAgent.onKillProcessOrExit()
        end
		cc.Director:getInstance():endToLua()
	end
end
