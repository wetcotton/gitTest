-- @Author: anchen
-- @Date:   2015-12-21 18:00:25
-- @Last Modified by:   anchen
-- @Last Modified time: 2015-12-21 19:02:52
OppoSDK = {}

function OppoSDK:OppoLogin()
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForOppo", {eGSLoginType.eGslt_OPPO}, "(I)V")
end

function OppoSDK:OppoExit()
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaExitForOppo", {}, "()V")
end

function OppoCallLuaExit()
    if DCAgent then
        DCAgent.onKillProcessOrExit()
    end
    cc.Director:getInstance():endToLua()
end

function OppoSDK:OppoUpRoloInfo(_level,_name,_server)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaRoleInfoForOppo", {_level,_name,_server}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function OppoSDK:pay(_tab)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForOppo", {_tab[5],_tab[2],_tab[3],_tab[4],_tab[1]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end