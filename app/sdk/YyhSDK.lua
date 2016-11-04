-- @Author: anchen
-- @Date:   2015-12-21 18:00:25
-- @Last Modified by:   anchen
-- @Last Modified time: 2015-12-25 15:34:31
YyhSDK = {}

function YyhSDK:YyhLogin()
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForYYH", {eGSLoginType.eGslt_YYH}, "(I)V")
end

function YyhSDK:pay(_tab)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForYYH", {_tab[1],_tab[2],_tab[3]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end