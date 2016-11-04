-- @Author: anchen
-- @Date:   2016-06-22 17:16:02
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-06-27 18:03:19
LieBaoSDK = {}

local isLieBao = device.platform=="android" and gType_SDK == AllSdkType.Sdk_LieBao

function LieBaoSDK:login()
    if  not isLieBao then
        return
    end
    print("LieBaoSDK:login")
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForLieBao", {}, "()V")
end

function LieBaoSDK:submitUserData()
    if  not isLieBao then
        return
    end
    local roleId = tostring(srv_userInfo.characterId)
    local roleName = tostring(srv_userInfo.name)
    local roleLevel = tostring(srv_userInfo.level)
    local serverId = tostring(loginServerList.serverId)
    local serverName = tostring(loginServerList.serverName)
    local nomeyNum = tostring(srv_userInfo.gold)
    local uid = tostring(mUserId)
    local attach = "0"
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "submitUserData", 
        {"1", roleId, roleName, roleLevel, serverId, serverName, nomeyNum, uid, attach}, 
        "(Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String; Ljava/lang/String;)V")
end

function LieBaoSDK:logout()
    if  not isLieBao then
        return
    end
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLogoutForLieBao", {}, "()V")
end

--登录回调
function LieBaologinResult(retStr)
    luaLetUserLogin(retStr)
    startLoading()
end

--注销回调
function LieBaologoutResult()
    local function reLogin()
        DCAccount.logout()
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    end
    scheduler.performWithDelayGlobal(reLogin, 0.1)
end

function LieBaoSDK:exit()
    if  not isLieBao then
        return
    end
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaExitForLieBao", {}, "()V")
end