-- @Author: anchen
-- @Date:   2016-07-08 10:59:26
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-07-12 16:02:04
leshiSDK = {}

local isLeshiValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_LESHI

--登录
function leshiSDK:login()
    if  not isLeshiValid then
        return
    end
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "doLogin", {}, "()V")
end

--切换账号
function leshiSDK:switchUser()
    if  not isLeshiValid then
        return
    end
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "doSwitchUser", {}, "()V")
end

--登录和切换账号回调
function leshi_loginResult(retstr)
    if  not isLeshiValid then
        return
    end

    luaLetUserLogin(str)
    startLoading()
end

function leshiSDK:leshi_exit()
    if  not isLeshiValid then
        return
    end
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "onExit", {}, "()V")
end
