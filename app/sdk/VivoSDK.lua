-- @Author: anchen
-- @Date:   2015-12-28 14:37:51
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-06-29 19:23:17
VivoSDK = {}

function VivoSDK:VivoLogin()
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForVivo", {eGSLoginType.eGslt_VIVO}, "(I)V")
end

function VivoSDK:pay(_tab)
    printTable(_tab)
    if gType_SDK == AllSdkType.Sdk_VIVO then
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForVivo", {_tab[1],_tab[2],_tab[3],_tab[4],_tab[5],_tab[6],_tab[7],_tab[8],_tab[9]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    elseif gType_SDK == AllSdkType.Sdk_VIVO2 then
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForVivo", {_tab[1],_tab[2],_tab[3],_tab[4],_tab[5],_tab[6],_tab[7],_tab[8],_tab[9],_tab[10],_tab[11]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    end
    
end

function VivoSDK:VivoExit()
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaExitForVivo", {}, "()V")
end

function VivoSDK:VivoUpRoloInfo()
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaRoleInfoForVivo", {tostring(mUserId), srv_userInfo.name, tostring(srv_userInfo.level), loginServerList.serverId, loginServerList.serverName}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end