anzhiSDK = {}

local isAnzhiValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_ANZHI

function anzhiSDK:init()
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "init", {}, "()V")
end

--success==1，初始化成功
function anzhi_initResult( retStr )
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
	end
end

function anzhiSDK:login()
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "login", {}, "()V")
end

-- /*
-- 	 * 登陆回调
-- 	 * success:1登录成功，2登录失败
-- 	 * msg = uid+"|"+loginName+"|"+sid,或者失败信息
-- 	 */
function anzhi_loginResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"~")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		arr = string.split(msg,"|")
		local uid = arr[1]
		local loginName = arr[2]
		local sid = arr[3]
		local Nick = arr[4]
		print("uid",uid)
		print("loginName",loginName)
		print("sid",sid)
		print("Nick",Nick)

		local str = eGSLoginType.eGslt_ANZHI.."|"..uid.."|"..sid
        print(str)
        luaLetUserLogin(str)
        startLoading()

        anzhiSDK.uid = uid
        anzhiSDK.Nick = loginName

     --    local tab = {
	    --     1,
	    --     "测试订单名称",
	    --     "aaaaaaaasssssssssfghj",
	    -- }
	    -- anzhiSDK:pay(tab)
	elseif success==2 then
		print("sdk登录失败")
	end
end

-- /*
-- 	 * Nick，用户昵称
-- 	 * uid，登陆获取的uid
-- 	 * gameArea,游戏服务器区
-- 	 * roleLevel，玩家等级
-- 	 * roleName，玩家名称
-- 	 * remark，备注
-- 	 */
function anzhiSDK:submitGameInfo(pramas)
	local Nick,uid,gameArea,roleLevel,roleName,remark = unpack(pramas)
	print("Nick: ",Nick)
	print("uid: ",uid)
	print("gameArea: ",gameArea)
	print("roleLevel: ",roleLevel)
	print("roleName: ",roleName)
	print("remark: ",remark)
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "submitGameInfo", pramas, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function anzhiSDK:logout()
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "logout", {}, "()V")
end

-- /*
-- 	 * 登出回调
--   * success:1
-- 	 */
function anzhi_logoutResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		local sceneName = display.getRunningScene().name
		print("sceneName:----------------------------------------------- "..sceneName)
		if sceneName=="loginScene" then
			
		else
			local function reLogin()
		        DCAccount.logout()
		        display.removeUnusedSpriteFrames()
		        app:enterScene("LoginScene",{1})
		    end
		    scheduler.performWithDelayGlobal(reLogin, 0.1)
				
		end
	end
end

function anzhiSDK:showFLoatMenu(bIsShow)
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "showFloatMenu", {bIsShow}, "(Z)V")
end

function anzhiSDK:showUserCenter()
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "showUserCenter", {}, "()V")
end

-- /*
-- 	 * money,价格，单位元。float
-- 	 * orderName，订单名称，String
-- 	 * customInfo，回传信息，String
-- 	 */
function anzhiSDK:pay(pramas)
	if  not isAnzhiValid then
		return
	end
	local money,orderName,customInfo = unpack(pramas)
	print("money : ",money)
	print("orderName : ",orderName)
	print("customInfo : ",customInfo)
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "pay", pramas, "(FLjava/lang/String;Ljava/lang/String;)V")
end

-- /*
-- 	 * 支付回调
-- 	 * success=1
-- 	 * msg = desc+"|"+orderId+"|"+price+"|"+time
-- 	 */
function anzhi_payResult( retStr )
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
	end
end

function anzhiSDK:exitSDK()
	if  not isAnzhiValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/anzhi/anzhiSDK", "exitSDK", {}, "()V")
end

function anzhi_exitResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]

	if DCAgent then
        DCAgent.onKillProcessOrExit()
    end
	cc.Director:getInstance():endToLua()
end