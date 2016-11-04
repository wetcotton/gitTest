-- @Author: anchen
-- @Date:   2015-12-21 18:00:25
-- @Last Modified by:   anchen
-- @Last Modified time: 2015-12-25 17:54:27
ZYSdk = {}

function ZYSdk:ZYLogin()
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForZy", {eGSLoginType.eGslt_ZY}, "(I)V")
end

function ZYSdk:pay(_tab)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForZy", {_tab[1],_tab[2],_tab[3]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end