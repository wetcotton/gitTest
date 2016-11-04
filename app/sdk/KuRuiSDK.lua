-- @Author: anchen
-- @Date:   2016-01-06 22:51:50

KuRuiRoleInfoType = {
    KuRui_levelUp =  "levelUp",
    KuRui_createRole = "createRole",
    KuRui_enterServer = "enterServer",
}
KuRuiSDK = {}

function KuRuiSDK:KuRuiLogin()
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForKuRui", {eGSLoginType.eGslt_KURUI}, "(I)V")
end

function KuRuiSDK:pay(_tab)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaPayForKuRui", {_tab[1],_tab[2],_tab[3],_tab[4],_tab[5],_tab[6],_tab[7],_tab[8],_tab[9]}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function KuRuiSDK:KuRuiUpRoloInfo(_infotype)
    print("_infotype1:".._infotype)
    print("mUserId:"..mUserId)
    print("mUserName:"..srv_userInfo.name)
    print("srv_userInfo.level:"..srv_userInfo.level)
    print("mServerName:"..loginServerList.serverName)
    print("srv_userInfo.diamond:"..srv_userInfo.diamond)
    print("srv_userInfo.vip:"..srv_userInfo.vip)
    print("_infotype1:"..(srv_userInfo.armyName or "无帮派"))
    print("_infotype1:".._infotype)
    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaRoleInfoForKuRui", {_infotype, tostring(mUserId), srv_userInfo.name, tostring(srv_userInfo.level),"1", loginServerList.serverName, tostring(srv_userInfo.diamond), tostring(srv_userInfo.vip), srv_userInfo.armyName or "无帮派"}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    print("_infotype2:".._infotype)
end
