utilsInit                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")

local scheduler = require("framework.scheduler")

require("pack")
require("app.utils.Constants")
require("app.data.GameData")
require("app.scenes.regTalkScene")
local httpNet = require("app.net.HttpNet")
local globalFunc = require("app.utils.GlobalFunc")
local ComboxList = require("app.scenes.myComboxList")
local CGSceneTwo = require("app.scenes.CGSceneTwo")
require("app.MyInit")      

local loginFirstLayer = require("app.scenes.login.loginFirstLayer")
local loginLayer = require("app.scenes.login.loginLayer")
local regLayer = require("app.scenes.login.registerLayer")
local enterGameLayer = require("app.scenes.login.enterGameLayer")
local roleLayer = require("app.scenes.login.selectRoleLayer")



local regdata = {}
local logindata = {}
local isFastReg = false

roleLoginData = {}
local roleCreateData = {}
roleCreateData["templateId"]=10121 --默认值
roleCreateData.chnlId = gType_Chnl
--存放服务区列表数组
local serverList={}
--推荐或上次登陆服务区
-- recommendServer={}

local curCommand = CMD_ROLE_LOGIN
local bOpenRegsiter = true

--========================
--LoginScene Class
--========================
LoginScene = class("LoginScene",function()
    local scene = display.newScene(LoginScene)
    scene:setName("loginScene")
	return scene
end)

m_addSearchPath()
local rootPanel
local firstPanel
local loginPanel
local regPanel
local Login_body
local reg_box
local enterGamePanel
-- local selectAreaPanel
local noticePanel
local selectBg

local LoginServerLabel
local loginErrorLabel
local regErrorLabel
local msgLabel

local LoginServerStatus

local blickHandler
local m_blick=false
local nickNameList = {} --随机昵称
local nickNameIdx = 1 --第几个昵称了

function LoginScene:ctor(params)
    if m_socket and params~="createRole" then
        -- m_socket:disconnect()
        m_socket = nil
    end
    
    -- UnzipFile("res/test/test.zip")

    -- display.newSprite("test/test.png")
    -- :addTo(self,100)
    -- :pos(display.cx, display.cy)

    --切换账号后之前账号的信息清空
    srv_userInfo = {}
    srv_blockData           = {} --服务器返回的关卡信息(修改后的，通过关卡ID索引的)
    srv_lastBlockData       = {} --上一次的关卡信息
    srv_nextBlockData       = {} --下一次的关卡信息
    legionFBData            = {} --军团信息
    

    self.params = params
    MainSceneEnterType = 0  --进入主界面类型置0
    LoginSceneInstance = self
    isFastReg = false
    audio.stopMusic()

    self.bg = display.newSprite("SingleImg/login_bg.jpg", display.cx, display.cy)
    :addTo(self)
    self.skeletonNode = sp.SkeletonAnimation:create("spine/11212313piao.json","spine/11212313.atlas",1)
    :pos(display.width*0.78,display.height*0.1)
    :addTo(self.bg,2)
    self.skeletonNode:setAnimation(0,"22",true)
    --首页
    firstPanel = loginFirstLayer.new()
    :addTo(self)

    --登录
    loginPanel = loginLayer.new()
    :addTo(self)
    loginPanel:setVisible(false)
    Login_body = loginPanel:getChildByTag(100)

    --注册
    regPanel = regLayer.new()
    :addTo(self)
    regPanel:setVisible(false)
    reg_box = regPanel:getChildByTag(100)

    --进入游戏
    enterGamePanel = enterGameLayer.new()
    :addTo(self)
    enterGamePanel:setVisible(false)
    areaNameBar = enterGamePanel:getChildByTag(101)
    LoginServerLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(areaNameBar)
    :pos(80, areaNameBar:getContentSize().height/2)


    local toFastLogin = firstPanel:getChildByTag(100):getChildByTag(103)
        :onButtonClicked(function(evelnt)
            if not bOpenRegsiter then
                showMessageBox("暂未开放游客模式！")
                return
            end
            --快速登录
            --firstPanel:setVisible(false)
            isFastReg = true

            -- if GameData.login_username ~= nil then
            --     logindata["username"] = GameData.login_username
            --     logindata["password"] = GameData.login_password
            if device.platform == "ios" then
                print("platform is ios")
                local ok, ret = luaoc.callStaticMethod("KeychainItemWrapper", "getUserData")
                if ok then
                    logindata["userName"] = ret["username"]
                    logindata["password"] = ret["password"]
                    logindata["appID"] = tonumber(g_U8AppId)
                    logindata["mobileOS"] = g_MobileOS
                    logindata["chnlId"] = gType_Chnl
                    
                    print("keychain username:"..ret["username"]..",password:"..ret["password"])
                    startLoading()
                    httpNet.connectHTTPServer(handler(self, self.onLoginHttpResponse),"/userver/user/login?data=",json.encode(logindata))
                else
                    print("keychain not ok")
                    startLoading()
                    httpNet.connectHTTPServer(handler(self, self.onRegHttpResponse), "/userver/user/quickRegister?data={\"mobileOS\":0,\"chnlId\":"..gType_Chnl.."}")
                end
                

            elseif device.platform == "android" then
                print("platform is android")
                showMessageBox("安卓版本还未处理游客模式!")
            elseif device.platform == "windows" then
                print("platform is windows")
                showMessageBox("windows版本不支持游客模式!")
            else
                print(device.platform)
                showMessageBox(device.platform.."平台暂不支持游客模式！")
            end

            
        end)

    local toLogin = firstPanel:getChildByTag(100):getChildByTag(101)
        :onButtonClicked(function(event)
            local AccountList={} 
            AccountList = getAccount()
            if AccountList==nil then
                firstPanel:setVisible(false)
                loginPanel:setVisible(true)
                return
            end

            isFastReg = false
            local loginPassword
            for k,value in ipairs(AccountList) do
                if value.username == curUserNameText:getString()then
                    loginPassword = value.password
                    break
                end
            end
            logindata["userName"] = curUserNameText:getString()
            logindata["password"] = loginPassword
            logindata["appID"] = tonumber(g_U8AppId)
            logindata["mobileOS"] = g_MobileOS
            logindata["chnlId"] = gType_Chnl
        
            httpNet.connectHTTPServer(handler(self, self.onLoginHttpResponse), "/userver/user/login?data=", json.encode(logindata))

            startLoading()
        end)
    local toregister = firstPanel:getChildByTag(100):getChildByTag(102)
        :onButtonClicked(function(event)
            if not bOpenRegsiter then
                showMessageBox("暂未开放注册功能！")
                return
            end
            firstPanel:setVisible(false)
            regPanel:setVisible(true)
        end)


    --登陆
    local loginUserName = Login_body:getChildByTag(12)
    local loginPassword = Login_body:getChildByTag(13)
    loginErrorLabel = Login_body:getChildByTag(14)


    local loginBtn = loginPanel:getChildByTag(100):getChildByTag(15)
    loginBtn:onButtonClicked(function(event)
        print("login")
        if loginPassword:getText()=="" then
            loginErrorLabel:setString("密码不能为空")
            return
        end
        isFastReg = false
        logindata["userName"] =string.gsub(loginUserName:getText(), " ", "")
        logindata["password"] = string.gsub(loginPassword:getText(), " ", "")
        logindata["appID"] = tonumber(g_U8AppId)
        logindata["mobileOS"] = g_MobileOS
        logindata["chnlId"] = gType_Chnl
        httpNet.connectHTTPServer(handler(self, self.onLoginHttpResponse), "/userver/user/login?data=", json.encode(logindata))

        startLoading()

    end)

    local loginClose = loginPanel:getChildByTag(100):getChildByTag(11)
        :onButtonClicked(function(event)
            firstPanel:setVisible(true)
            loginPanel:setVisible(false)
            loginErrorLabel:setString("")
            self.boxlist.jiantou:setRotation(0)
            self.boxlist.listView:setVisible(false)
            end)


    --下拉框
    local firstPanelBg = firstPanel:getChildByTag(100)
    self.boxlist = ComboxList.new()
    :addTo(self)
    self.boxlist:setTouchSwallowEnabled(false)
    self.boxlist:updateBoxList(firstPanelBg,function(event)
        firstPanel:setVisible(false)
        loginPanel:setVisible(true)
        loginUserName:setText("")
        loginPassword:setText("")
        end)


    --注册
    local reg_userName = reg_box:getChildByTag(101)
    local reg_password = reg_box:getChildByTag(102)
    local reg_ConfirmPwd = reg_box:getChildByTag(103)
    regErrorLabel = reg_box:getChildByTag(106)


    local function checkMailBox(e_mail)
        local pos = -1
        local i = 0
        while true do 
            i=string.find(e_mail,".",i+1)
            if i == nil then
                break
            end
            pos = i
        end

        local i,j = string.find(e_mail,"@")
        if i==nil then
            print("no @")
            return false
        end

        if pos < j then
            print(pos)
            return false
        end
        return true
    end

    local function checkUserName(username)

        if #username<5 or #username>16 then
            -- print("test1")
            return false
        end
        -- print(#username)

        local t
        for i=1,#username do
            t = string.sub(username,i,i)
            -- print(t)
            if not ((t>="0" and t<="9") or (t>="a" and t<="z") or (t>="A" and t<="Z")) then
                -- print("test2")
                return false
            end
        end
        return true
    end



    local regBtn = regPanel:getChildByTag(100):getChildByTag(104)
    regBtn:onButtonClicked(function(event)
        print("clicked register")
        isFastReg = false

        if reg_userName:getText()=="" or checkUserName(reg_userName:getText())==false then
            print("账号需由5-16位的数字或字母组成")
            regErrorLabel:setString("账号为5-16位的数字或字母组成")
            return
        elseif reg_password:getText()=="" then
            print("密码不能为空")
            regErrorLabel:setString("密码不能为空")
            return
        elseif reg_password:getText()~=reg_ConfirmPwd:getText() then
            print("两次密码输入不一致")
            regErrorLabel:setString("两次密码输入不一致")
            return
        -- elseif reg_MailBox:getText()=="" and false then
        --     print("邮箱不能为空")
        --     regErrorLabel:setString("邮箱不能为空")
        --     return
        -- elseif(not checkMailBox(reg_MailBox:getText())) and false then
        --     print("无效的邮箱地址")
        --     regErrorLabel:setString("无效的邮箱地址")
        --     return
        end


        regdata["userName"] = string.gsub(reg_userName:getText(), " ", "")
        regdata["password"] = string.gsub(reg_password:getText(), " ", "")
        regdata["mobileOS"] = g_MobileOS
        regdata["chnlId"] = gType_Chnl

        httpNet.connectHTTPServer(handler(self, self.onRegHttpResponse), "/userver/user/register?data=", json.encode(regdata))

        startLoading()

    end)


    local regCloseBtn = regPanel:getChildByTag(100):getChildByTag(100)
    regCloseBtn:onButtonClicked(function(event)
        firstPanel:setVisible(true)
        regPanel:setVisible(false)
        reg_userName:setText("")
        reg_password:setText("")
        reg_ConfirmPwd:setText("")
        -- reg_MailBox:setText("")
        regErrorLabel:setString("")

        self.boxlist.jiantou:setRotation(0)
        self.boxlist.listView:setVisible(false)
    end)


    --进入游戏界面
    selectBg = enterGamePanel:getChildByTag(103)
    local areaNameBar = enterGamePanel:getChildByTag(101)
    local selectAreaBt = enterGamePanel:getChildByTag(101):getChildByTag(10)
    local enterGameBt = enterGamePanel:getChildByTag(100)
    :onButtonClicked(function(event)--进入游戏
        for i,list in pairs(serverList) do
            if list["serverName"]==LoginServerLabel:getString() then
                loginServerList=list
                break
            end
        end
        if loginServerList.pause==1 and loginServerList.tm>0 then
            showMessageBox("服务器正在维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
            return
        elseif loginServerList.pause==2 and loginServerList.tm>0 then
            showMessageBox("服务器正在更新维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
            return
        end
        print("enterBt--------------------------------")
        if isUCLogin then
            luaUCGameSdk:login(false,"")
            return
        elseif isDownJoyLogin then
            downJoySDK:downjoyLogin()
            return
        elseif isGIONEELogin then
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForGionee", {eGSLoginType.eGslt_GIONEE}, "(I)V")
            return
        elseif isHUAWEILogin then
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForHuawei", {eGSLoginType.eGslt_HUAWEI}, "(I)V")
            return
        elseif isXIAOMILogin then
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginForXiaomi", {eGSLoginType.eGslt_HUAWEI}, "(I)V")
            return
        elseif isBaiDuLogin then
            baiduSDK:baiduLogin()
            return
        elseif isLenovoLogin then
            require("app.sdk.lenovoSDK")
            lenovoSDK:lenovoLogin()
            return
        elseif isWdjLogin then
            require("app.sdk.wdjSDK")
            wdjSDK:login()
            return
        elseif isAnzhiLogin then
            require("app.sdk.anzhiSDK")
            anzhiSDK:login()
        elseif isOPPOLogin then
            require("app.sdk.OppoSDK")
            startLoading()
            OppoSDK:OppoLogin()
            return
        elseif isZYLogin then
            require("app.sdk.ZYSdk")
            ZYSdk:ZYLogin()
        elseif isYYHLogin then
            require("app.sdk.YyhSDK")
            YyhSDK:YyhLogin()
        elseif isVIVOLogin then
            require("app.sdk.VivoSDK")
            VivoSDK:VivoLogin()
        elseif isCoolPadLogin then
            require("app.sdk.coolpadSDK")
            coolpadSDK:login()
        elseif isKURUILogin then
            require("app.sdk.KuRuiSDK")
            KuRuiSDK:KuRuiLogin()
        elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2)  then
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLoginFor360", {eGSLoginType.eGslt_360}, "(I)V")
        elseif isMEIZULogin then
            require("app.sdk.meizuSDK")
            meizuSDK:login()
        elseif isQBaoLogin then
            require("app.sdk.qbaoSDK")
            qbaoSDK:initAndLogin()
        elseif isXYLogin then
            --todo
        elseif isKUAIYONGLogin then
            require("app.sdk.kuaiyongSDK")
            kuaiyongSDK:initAndLogin()
        elseif isTONGBULogin then
            --todo
        elseif isPPLogin then
            --todo
        elseif isLieBaoLogin then
            require("app.sdk.LieBaoSDK")
            LieBaoSDK:login()
        elseif isLeshiLogin then
            require("app.sdk.leshiSDK")
            leshiSDK:login()
        else
            self:loginGame()
        end
        
    end)

    if isMSDKLogin then
        enterGameBt:setVisible(false)
        local QQLoginItem = cc.ui.UIPushButton.new({
            normal = "common/qqloginitem.png",
            })
        :addTo(enterGamePanel)
        :pos(display.width*0.39, display.height*0.12)
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function(event)
            for i,list in pairs(serverList) do
                if list["serverName"]==LoginServerLabel:getString() then
                    loginServerList=list
                end
            end
            if loginServerList.pause==1 and loginServerList.tm>0 then
                showMessageBox("服务器正在维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
                return
            elseif loginServerList.pause==2 and loginServerList.tm>0 then
                showMessageBox("服务器正在更新维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
                return
            end
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaMSDKLogin", {eGSLoginType.eGslt_QQ}, "(I)V")
        end)
        local WXLoginItem = cc.ui.UIPushButton.new({
            normal = "common/wxloginitem.png",
            })
        :addTo(enterGamePanel)
        :pos(display.width*0.61, display.height*0.12)
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function(event)
            for i,list in pairs(serverList) do
                if list["serverName"]==LoginServerLabel:getString() then
                    loginServerList=list
                end
            end
            if loginServerList.pause==1 and loginServerList.tm>0 then
                showMessageBox("服务器正在维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
                return
            elseif loginServerList.pause==2 and loginServerList.tm>0 then
                showMessageBox("服务器正在更新维护中,\n请您"..loginServerList.tm.."分钟后重新登录")
                return
            end
            local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaMSDKLogin", {eGSLoginType.eGslt_Weixin}, "(I)V")
        end)
    end


    LoginServerStatus = display.newSprite()
        :pos(50, areaNameBar:getContentSize().height/2)
        :addTo(areaNameBar)

    

    --QQ登陆
    local QQBt = firstPanel:getChildByTag(100):getChildByTag(105)
    :onButtonClicked(function(event)
        
    end)

    --微信登陆
    local MicroMsgBt = firstPanel:getChildByTag(100):getChildByTag(104)
    :onButtonClicked(function(event)
        
    end)

    if device.platform~="android" then
        QQBt:setVisible(false)
        MicroMsgBt:setVisible(false)
    end
    self:showVersion(bg)
end

function LoginScene:loginGame()

    for i,list in pairs(serverList) do
                if list["serverName"]==LoginServerLabel:getString() then
                    loginServerList=list
                    -- mServerName = list["serverName"]
                    -- mServerId = list["serverId"]
                    print("--------connect socket")
                    print("--------connect socket ip="..list["hostIp"])
                    print("--------connect socket port="..list["port"])

                    --判断大区是否爆满
                    -- if loginServerList.maxUserNum==0 then
                    --     showMessageBox("服务器维护或重启中，请稍后重新登录！")
                    --     return
                    -- elseif loginServerList.curUserNum>=loginServerList.maxUserNum then
                    --     showMessageBox("该大区已经爆满，请选择其他大区。")
                    --     return
                    -- end

                    -- U8getToken接口
                    UEgihtSdkLoginManager:sendTokenToU8(mUserName)
-- -- -- 
                    -- startLoading()
                    -- roleLoginData["userId"] = "8381"
                    -- roleLoginData["userName"] = "wx-oOfAUt2fad4fjcZF_DnBmakjTNQQ.tx"
                    -- roleLoginData["userId"] = "107811"
                    -- roleLoginData["userName"] = "qk86966.ios2"
                    -- roleLoginData["userId"] = "70758"
                    -- roleLoginData["userName"] = "zh81592.ios3"
                    -- roleLoginData["userId"] = "142062"
                    -- roleLoginData["userName"] = "yudechibang.ios2" --李毅
                    -- roleLoginData["userId"] = "142489"
                    -- roleLoginData["userName"] = "1260983368930.dl" --李毅                    
                    -- roleLoginData["mobileOS"] = g_MobileOS
                    -- roleLoginData["chnlId"] = Chnl_IOS2
                    -- mUserId = roleLoginData["userId"]
                    -- m_socket = nil
                    -- globalFunc.connectSocketServer("119.29.146.169",loginServerList["port"]) --ios
                    -- globalFunc.connectSocketServer("119.29.146.169",14009)
                    -- globalFunc.connectSocketServer("dir001.3birdsgame.com",loginServerList["port"])
                    -- globalFunc.connectSocketServer("120.132.53.47",10977)
                    -- globalFunc.connectSocketServer("192.168.11.108",loginServerList["port"])

                    -- --角色登录
                    -- startLoading()
                    -- roleLoginData["mobileOS"] = g_MobileOS
                    -- roleLoginData["chnlId"] = gType_Chnl
                    -- m_socket:SendRequest(json.encode(roleLoginData), CMD_ROLE_LOGIN, self, self.onRoleLoginResult)
                        
                    break
                end
            end
end

function LoginScene:onRegHttpResponse(event)

    local request = event.request
    printf("onRegHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local regResult = httpNet.getUnTeaResponseString(request)
            local jRegResult= json.decode(regResult)
            if jRegResult["result"] == 1 then --注册成功
                print("注册成功~")

                -- roleLoginData["userId"] = jRegResult["data"]["userId"]
                -- roleLoginData["userName"] = jRegResult["data"]["userName"]
                -- logindata["userName"] = jRegResult["data"]["userName"]
                -- mUserId = roleLoginData["userId"]
                --recommendServer.serverId = jRegResult["data"]["serverId"]

                -- roleCreateData["userId"] = jRegResult["data"]["userId"]


                if isFastReg then
                    -- srv_userInfo["mUserName"] = jRegResult["data"]["userName"]
                    -- srv_userInfo["mPassWord"] = jRegResult["data"]["password"]
                    regdata["userName"] = jRegResult["data"]["userName"]
                    regdata["password"] = jRegResult["data"]["password"]
                else

                    -- srv_userInfo["mUserName"] = regdata["username"]
                    -- srv_userInfo["mPassWord"] = regdata["password"]

                end

                --注册账号保存本地
                addAccount(regdata["userName"], regdata["password"])

                if isFastReg then
                    if device.platform=="ios" then
                        --local myargs = {username = userData["login_password"] , password = userData["login_password"]}
                        local myargs = {username = regdata["userName"] , password = regdata["password"]}
                        luaoc.callStaticMethod("KeychainItemWrapper", "saveUserData",myargs)
                    end
                    
                end
                if isUCLogin or isMSDLogin or isGIONEELogin or isDownJoyLogin or isHUAWEILogin or isXIAOMILogin or isBaiDuLogin or isOPPOLogin or isLenovoLogin or isVIVOLogin or isKURUILogin
                    or isWdjLogin or isZYLogin or isYYHLogin or isAnzhiLogin or isCoolPadLogin or isMEIZULogin or isQBaoLogin or isLiebaoLogin or isLeshiLogin then
                else
                    local getSerData = {
                                    ["mobileOS"] = g_MobileOS,
                                    ["areaType"] = g_AreaType,
                                    ["ver"] = g_Version,
                                    ["chnlId"] = gType_Chnl
                                 }
                    httpNet.connectHTTPServer(handler(self, self.onSerListHttpResponse),"/userver/common/getSerList?data=",json.encode(getSerData))
                end
                mUserName = regdata["userName"]
                -- mUserName = jRegResult["data"]["userName"]
                mPassWord = regdata["password"]
                --登录后播放音乐
                -- setMusicSwitch()
                -- audio.playMusic("audio/loginBg.mp3", true)
            else
                if jRegResult["result"] == 2 or jRegResult["result"] == -1 then  --用户名只能包含字母和数字,用户名为空
                    regErrorLabel:setString("用户名只能包含字母或数字")
                elseif jRegResult["result"] == 3 then --该用户名已被注册
                    regErrorLabel:setString("该用户名已被注册")
                elseif jRegResult["result"] == 4 then --注册失败
                    regErrorLabel:setString("注册失败")
                end
                print("error:"..jRegResult["msg"])

                endLoading()

                return 

            end

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        regErrorLabel:setString("网络连接失败")
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        endLoading()
    end

end

function LoginScene:onLoginHttpResponse(event)

    local request = event.request
    printf("onLoginHttpResponse - event.name = %s", event.name)
    --printLogForLua("-----------onLoginHttpResponse 44444")
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            --printLogForLua("-----------onLoginHttpResponse 55555")
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local loginResult = httpNet.getUnTeaResponseString(request)
            local jLoginResult= json.decode(loginResult)
            if jLoginResult["result"] == 8 then --不开放登录
                showMessageBox(jLoginResult["msg"],nil,nil,function ()
                    cc.Director:getInstance():endToLua()
                end)
            elseif jLoginResult["result"] == 1 then --登陆成功
                print("登陆成功")
                --printLogForLua("-----------onLoginHttpResponse 66666")
                -- roleLoginData["userId"] = jLoginResult["data"]["userId"]
                -- roleLoginData["userName"] = jLoginResult["data"]["userName"]
                logindata["userName"] = jLoginResult["data"]["userName"]
                -- mUserId = roleLoginData["userId"]
                
                -- recommendServer.serverId = jLoginResult["data"]["serverId"]

                roleCreateData["userId"] = jLoginResult["data"]["userId"]


                local tmpPw = logindata["password"]
                if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) and device.platform == "android" then
                    luaStop360Waiting()
                    luaStart360Waiting("正在获取分服列表...")
                    tmpPw = ""
                end
                addAccount(logindata["userName"], tmpPw)
                mUserName = jLoginResult["data"]["userName"]
                mPassWord = logindata["password"]
                -- print(GameData.login_username)
                if isMSDKLogin or isUCLogin or isGIONEELogin or isDownJoyLogin or isHUAWEILogin or isXIAOMILogin or isBaiDuLogin or isOPPOLogin  or isZYLogin or isYYHLogin or isVIVOLogin or isKURUILogin
                    or isLenovoLogin or isWdjLogin or isAnzhiLogin or isCoolPadLogin or isMEIZULogin or isQBaoLogin or isLieBaoLogin or isLeshiLogin then
                    self:loginGame()
                else
                    local getSerData = {
                                    ["mobileOS"] = g_MobileOS,
                                    ["areaType"] = g_AreaType,
                                    ["ver"] = g_Version,
                                    ["chnlId"] = gType_Chnl
                                 }
                    httpNet.connectHTTPServer(handler(self, self.onSerListHttpResponse),"/userver/common/getSerList?data=",json.encode(getSerData))
                end
                -- mUserName = logindata["userName"]
                
                --账户登录后播放音乐
                -- printTable(GameData)

                -- setMusicSwitch()
                -- audio.playMusic("audio/loginBg.mp3", true)
            else
                if jLoginResult["result"] == 2 or jLoginResult["result"] == -1 then --不存在的用户,用户名为空

                    if isFastReg then
                        
                    else
                        if loginPanel:isVisible() then
                            loginErrorLabel:setString("用户不存在")
                        else
                            showMessageBox("用户不存在")
                        end
                    end

                elseif jLoginResult["result"] == 3 then --密码错误
                    
                    if isFastReg or not loginPanel:isVisible() then
                        showMessageBox("密码错误")
                    else
                        loginErrorLabel:setString("密码错误")
                        endLoading()
                    end

                elseif jLoginResult["result"] == 4 then --账户被冻结
                    
                    if isFastReg or not loginPanel:isVisible() then
                        showMessageBox("账户被冻结")
                    else
                        loginErrorLabel:setString("账户被冻结")
                        endLoading()
                    end

                end

                print("error:"..jLoginResult["msg"])
                --printLogForLua("-----------onLoginHttpResponse 77777")
                endLoading()

                return


            end

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        if isFastReg then
            showMessageBox("网络连接失败")
        else
            loginErrorLabel:setString("网络连接失败")
            endLoading()
        end
    end

end



function LoginScene:onSerListHttpResponse(event)
    if isUCLogin or device.platform=="ios" then
        endLoading()
    end
    local request = event.request
    --printLogForLua("-----------onSerListHttpResponse 44444")
    printf("onSerListHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            --printLogForLua("-----------onSerListHttpResponse 55555")
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local serListResult = httpNet.getUnTeaResponseString(request)
            local jSerListResult= json.decode(serListResult)

            serverList = jSerListResult["data"]
            if serverList==nil or #serverList==0 then --列表数据为空时
                showTips("获取服务器列表异常")
                return 
            end
            
            
            
            if jSerListResult["result"] == 1 then --获取列表成功
                print("获取分服列表成功啊啊啊啊")


                local tmpserver = loginServerList
                loginServerList = serverList[1]
                for i,list in pairs(serverList) do
                    if list["serverId"] == tmpserver.serverId then
                        loginServerList = list
                        break
                    end
                end
                -- printTable(serverList)
                -- print("loginServerList:"..loginServerList)

                -- --暂时的
                -- self:enterServerList()
                -- self:initServerList()
                -- endLoading()
                
                --公告提示,类型1版本更新内容, 2停机公告
                local noticeData = {}
                noticeData["ver"] = self.curVersion
                -- noticeData["ver"] = "0.9.99998"
                noticeData.chnlId = gType_Chnl
                noticeData.mobileOS = g_MobileOS
                noticeData["isMain"] = 0
                
                httpNet.connectHTTPServer(handler(self, self.onNoticeHttpResponse), "/userver/common/getNotices?data=", json.encode(noticeData))
                
            else
                showTips("error:"..jSerListResult["msg"])
                print("error:"..jSerListResult["msg"])
                return 

            end

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
    end

end


function addServerStatus()
    local serverStatus = cc.ui.UIImage.new("SingleImg/shield.png")
        :align(display.LEFT_TOP, display.cx, display.cy - 285)
        :addTo(self)
end


function LoginScene:initServerList()
    print("initServerList")

    local serStateImg,serColor
    if loginServerList.pause~=0 then
        serStateImg = "SingleImg/login/server_state4.png"
        serColor = cc.c3b(255, 255, 255)
    elseif loginServerList.isNew==1 then
        serStateImg = "SingleImg/login/server_state1.png"
        serColor = cc.c3b(87, 255, 7)
    else
        serStateImg = "SingleImg/login/server_state3.png"
        serColor = cc.c3b(255, 0, 0)
    end
    

    local state = display.newSprite(serStateImg)
    :pos(-90, 0)
    local label = cc.ui.UILabel.new({text=loginServerList["serverName"], size = 25})
        :pos(-50, 0)
        label:setColor(serColor)
    if loginServerList["serverName"]==nil then --如果本地没有保存，证明是新玩家，推荐新区
        label:setString(serverList[1]["serverName"])
        for i=1,#serverList do
            if serverList.isNew==1 then
                label:setString(serverList[i]["serverName"])
                break
            end
        end
    end

    local firstServer = cc.ui.UIPushButton.new("SingleImg/login/recentlySerBar.png")
        :onButtonPressed(function(event)
            --event.target:getButtonLabel():setColor(display.COLOR_RED)
        end)
        :onButtonRelease(function(event)
            --event.target:getButtonLabel():setColor(display.COLOR_BLUE)
        end)
        :onButtonClicked(function(event)
            -- enterGamePanel:setVisible(true)
            selectBg:setVisible(false)
            LoginServerLabel:setString(label:getString())
            LoginServerLabel:setColor(label:getColor())
            LoginServerStatus:setTexture(state:getTexture())
        end)
        :pos(160,selectBg:getContentSize().height - 75)
        :addTo(selectBg)
        firstServer:addChild(label)
        firstServer:addChild(state)




    self.selectArea = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(30, 70, 805, 260),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(selectBg)

    -- add items
    --#serverList/3+1
    for i=1,math.floor(#serverList/3)+1 do
        local item = self.selectArea:newItem()
        local content
        content = display.newNode()
        for count = 1, 3 do
            local tmpList = serverList[(i-1)*3+count]
            if i==(math.floor(#serverList/3)+1)  and count > #serverList%3 then
                break
            end

            local serStateImg,serColor
            if tmpList.pause~=0 then
                serStateImg = "SingleImg/login/server_state4.png"
                serColor = cc.c3b(255, 255, 255)
            elseif tmpList.isNew==1 then
                serStateImg = "SingleImg/login/server_state1.png"
                serColor = cc.c3b(87, 255, 7)
            else
                serStateImg = "SingleImg/login/server_state3.png"
                serColor = cc.c3b(255, 0, 0)
            end

            local btLabel = cc.ui.UILabel.new({text=tmpList["serverName"], size = 25 , color = serColor})
                :align(display.CENTER_LEFT, -50, 0)

            local status_img = display.newSprite(serStateImg)
                :align(display.CENTER, -90, 0)

            local m_button = cc.ui.UIPushButton.new("SingleImg/login/recentlySerBar.png")
                :onButtonPressed(function(event)
                --event.target:getButtonLabel():setColor(display.COLOR_RED)
                end)
                :onButtonRelease(function(event)
                --event.target:getButtonLabel():setColor(display.COLOR_BLUE)

                end)
                :onButtonClicked(function(event)
                    selectBg:setVisible(false)

                    LoginServerLabel:setString(btLabel:getString())
                    LoginServerLabel:setColor(btLabel:getColor())
                    LoginServerStatus:setTexture(status_img:getTexture())

                end)
                :align(display.CENTER, 260*(count-2), 0)
                :addTo(content)
                m_button:setTouchSwallowEnabled(false)


                m_button:addChild(btLabel)
                m_button:addChild(status_img)


        end

        item:addContent(content)
        item:setItemSize(805, 65)

        self.selectArea:addItem(item)

    end
    self.selectArea:reload()

end


function LoginScene:enterServerList()
    firstPanel:setVisible(false)
    enterGamePanel:setVisible(true)
    loginPanel:setVisible(false)
    regPanel:setVisible(false)

    if loginServerList["serverName"] == nil then
        loginServerList = serverList[1]
    end
    LoginServerLabel:setString(loginServerList["serverName"])
    local serStateImg,serColor
    if loginServerList.pause~=0 then
        serStateImg = "SingleImg/login/server_state4.png"
        serColor = cc.c3b(255, 255, 255)
    elseif loginServerList.isNew==1 then
        serStateImg = "SingleImg/login/server_state1.png"
        serColor = cc.c3b(87, 255, 7)
    else
        serStateImg = "SingleImg/login/server_state3.png"
        serColor = cc.c3b(255, 0, 0)
    end
    LoginServerLabel:setColor(serColor)
    LoginServerStatus:setTexture(serStateImg)
end

function LoginScene:onSocketConnected(__event)
    print("LoginScene:onSocketConnected")--new一个socket的时候进入这里

    roleLoginData["chnlId"] = gType_Chnl
    roleLoginData["ver"] = g_Version
    printTable(roleLoginData)
    m_socket:SendRequest(json.encode(roleLoginData), CMD_ROLE_LOGIN, self, self.onRoleLoginResult)
    -- if curCommand == CMD_ROLE_LOGIN then
    --     roleLoginData["chnlId"] = gType_Chnl
    --     m_socket:SendRequest(json.encode(roleLoginData), CMD_ROLE_LOGIN, self, self.onRoleLoginResult)
    -- elseif curCommand == CMD_ROLE_CREATE then
    --     roleCreateData["userName"] = logindata["userName"]
    --     m_socket:SendRequest(json.encode(roleCreateData), CMD_ROLE_CREATE, self, self.onRoleCreateResult)
    -- end
end

function LoginScene:onRoleLoginResult(result)
    self.versionLabel:setVisible(false)
    print("onRoleLoginResult result="..result["result"]) 
    --result: -2:没有创建角色 -1:没有登录中心服务器 0:登录失败 1:登录成功 -9:账号被冻结
    if result["result"] == 1 then
        print("角色登陆成功")
        -- mUserId = result.data.userId
        startLoading()
        local sendData = {}
        sendData["characterId"]=srv_userInfo["characterId"]
        m_socket:SendRequest(json.encode(sendData), CMD_BACKPACK, self, self.onCarEquipmentResult)
        --app:enterScene("MainScene")
    elseif result["result"] == -2 then
        nickNameList = result.data.nameList --全局函数
        enterGamePanel:setVisible(false)
        endLoading()

        firstPanel:removeSelf()
        firstPanel = nil
        loginPanel:removeSelf()
        loginPanel = nil
        regPanel:removeSelf()
        regPanel = nil
        enterGamePanel:removeSelf()
        enterGamePanel = nil
        self.bg:removeSelf()
        self.bg = nil
        display.removeUnusedSpriteFrames()

        --初始化
        -- self:initRolePanel()
        -- if musicSwitch then
        --     audio.playMusic("audio/createBg.mp3", true)
        -- end
        if g_IsDebug then
            -- rolePanel:setVisible(true)
            self:initRolePanel()
        else
            currentStep = 1
            startFightStep = 1
            GuideManager.NextStep  = 0
            GuideManager.NextLocalStep = 0
            g_CGScene.new({OnComplete=function()
                -- self:initRolePanel()
                -- if musicSwitch then
                --     audio.playMusic("audio/createBg.mp3", true)
                -- end
                app:enterScene("regTalkScene",{10121})
            end})
            :addTo(self)
        end
        
    else
        if result["result"] == -1 then
            if m_socket then
                m_socket = nil
            end
            
        elseif result["result"] == 0 then
            --todo
        end
        endLoading()
        showTips(result.msg)
    end

end

function LoginScene:onRoleCreateResult(result)
    
    print("onRoleCreateResult result="..result["result"])    
    
    if result["result"] == 1 then
        endLoading()
        -- local tmpID = roleCreateData["templateId"]
        -- -- mUserId = result.data.userId

        -- if isKURUILogin then
        --     KuRuiSDK:KuRuiUpRoloInfo(KuRuiRoleInfoType.KuRui_createRole)
        -- end

        
        -- --第一段看电视动画
        -- currentStep = 1
        -- startFightStep = 1
        -- GuideManager.NextStep  = 0
        -- GuideManager.NextLocalStep = 0
        -- g_CGScene.new({OnComplete=function()
        --     --第二段他老爸动画
        --     -- CGSceneTwo.new({onComplete=function()
        --     --                   app:enterScene("regTalkScene",{tmpID})
        --     --                 end, 
        --     --                 heroTmpId = tmpID,
        --     --                })
        --     -- :addTo(self)
        --     app:enterScene("regTalkScene",{tmpID})
        -- end})
        -- :addTo(self)
        startLoading()
        local sendData = {}
        sendData["characterId"]=srv_userInfo["characterId"]
        m_socket:SendRequest(json.encode(sendData), CMD_BACKPACK, self, self.onCarEquipmentResult)
    else
        endLoading()
        -- if result["result"] == 2 then --连接失败
        --     print("连接失败")
        -- elseif result["result"] == 3 then --未连接
        --     print("未连接")
        -- elseif result["result"] == 4 then --角色昵称非法
        --     print("角色昵称非法")
        -- elseif result["result"] == 5 then --玩家已创建角色
        --     print("玩家已创建角色")
        -- elseif result["result"] == 6 then --角色昵称已存在
        --     print("角色昵称已存在")
        --     showMessageBox("角色昵称已存在！")
        -- elseif result["result"] == 7 then --数据库错误
        --     print("数据库错误")
        --     showMessageBox("数据库错误！")
        -- elseif result["result"] == -1 then --角色登陆失败
        --     print("角色登陆失败")
        --     showMessageBox("角色登陆失败，请重新登陆！")
        -- end
        showTips(result.msg)
    end
end

function LoginScene:onCarEquipmentResult(result) --获取背包信息
    endLoading()
    if result["result"]==1 then
        print("获取背包信息成功啊！")
        -- app:enterScene("MainScene")
        if gType_SDK == AllSdkType.Sdk_LieBao then
            LieBaoSDK:submitUserData()
        end
        app:enterScene("LoadingScene", {SceneType.Type_Main})
    end
    
end

function LoginScene:onGetNickName(result)
    endLoading()
    if result.result==1 then
        nickNameList = result.data.nameList
        self.rolename:setText(nickNameList[nickNameIdx])
    else
        showTips(result.msg)
    end
end


function LoginScene:connectTable(table1,table2)

    local tableStr=json.encode(table1)..","..json.encode(table2)
    tableStr = string.gsub(tableStr,"{","")
    tableStr = string.gsub(tableStr,"}","")
    tableStr = "{"..tableStr.."}"
    --print(tableStr)
    local tableData={}
    tableData = json.decode(tableStr)

    return tableData
end

function LoginScene:onNoticeHttpResponse(event)
    local request = event.request
    printf("onLoginHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local loginResult = httpNet.getUnTeaResponseString(request)
            local jLoginResult= json.decode(loginResult)
            if jLoginResult["result"] == 1 then --获取公告成功
                printTable(jLoginResult)
                local noticedata = jLoginResult.data.notices

                --显示进入游戏界面
                self:enterServerList()
                self:initServerList()
                endLoading()

                -- if isUCLogin then
                --     luaUCGameSdk:login(true,"COCO号")
                -- end

                --弹出公告框
                if #noticedata==0 or device.platform == "windows" or self.params=="createRole" then
                    return
                end
                self:createNoticePanel(noticedata)
            end

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        if isFastReg then
            showMessageBox("网络连接失败")
        else
            loginErrorLabel:setString("网络连接失败")
            endLoading()
        end
    end
end

function LoginScene:onEnter()
    --读取上次登录服务器信息
    print("=================================1234567,GameData.loginServerList:")
    if GameData.loginServerList and self.params ~= "createRole" then
        printTable(GameData.loginServerList)
        loginServerList = GameData.loginServerList

        
    end
    

    params = self.params
    
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
        if (gType_SDK == AllSdkType.Sdk_360 or gType_SDK == AllSdkType.Sdk_360_2) then
            firstPanel:setVisible(false)
            if params and params==1 then
                local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaSwitchAccountFor360", {eGSLoginType.eGslt_360}, "(I)V")
            else
                local getSerData = {
                                        ["mobileOS"] = g_MobileOS,
                                        ["areaType"] = g_AreaType,
                                        ["ver"] = g_Version,
                                        ["chnlId"] = gType_Chnl
                                     }
                httpNet.connectHTTPServer(handler(self, self.onSerListHttpResponse),"/userver/common/getSerList?data=",json.encode(getSerData))
                startLoading()
            end
        end
    
        if isUCLogin or isMSDKLogin or isGIONEELogin or isDownJoyLogin or isHUAWEILogin or isXIAOMILogin or isBaiDuLogin or isOPPOLogin or isZYLogin or isYYHLogin or isVIVOLogin or isKURUILogin
            or isLenovoLogin or isWdjLogin or isAnzhiLogin or isCoolPadLogin or isMEIZULogin or isQBaoLogin or isLieBaoLogin or isLeshiLogin then
            if isBaiDuLogin then
                require("app.sdk.baiduSDK")
                baiduSDK:getAnnouncementInfo()
            end
            if isLeshiLogin then
                require("app.sdk.leshiSDK")
            end
            firstPanel:setVisible(false)
            local getSerData = {
                                    ["mobileOS"] = g_MobileOS,
                                    ["areaType"] = g_AreaType,
                                    ["ver"] = g_Version,
                                    ["chnlId"] = gType_Chnl
                                 }
            httpNet.connectHTTPServer(handler(self, self.onSerListHttpResponse),"/userver/common/getSerList?data=",json.encode(getSerData))
            startLoading()
        end
    elseif device.platform == "ios" then
        if  isXYLogin or isKUAIYONGLogin or isTONGBULogin or isPPLogin then
            firstPanel:setVisible(false)
            local getSerData = {
                                    ["mobileOS"] = g_MobileOS,
                                    ["areaType"] = g_AreaType,
                                    ["ver"] = g_Version,
                                    ["chnlId"] = gType_Chnl
                                 }
            httpNet.connectHTTPServer(handler(self, self.onSerListHttpResponse),"/userver/common/getSerList?data=",json.encode(getSerData))
            startLoading()
        end
    else
    end
    
    --各种特效
    --加载死亡特效
    local function addMistEff()
        self.smokeEffLeft = display.newGraySprite("#fallSmokeImg1.png")
        :align(display.CENTER_BOTTOM,display.width*0.2,0)
        :addTo(self.bg,3)
        self.smokeEffLeft:scale(2.2)
        self.smokeEffRight = display.newGraySprite("#fallSmokeImg1.png")
        :align(display.CENTER_BOTTOM,display.width*0.6,0)
        :addTo(self.bg,3)
        self.smokeEffRight:scale(2.7)
        local frames = display.newFrames("fallSmokeImg%d.png", 1, 10)
        local animationleft = display.newAnimation(frames, 1.2 / 10)
        local animationright = display.newAnimation(frames, 1.5 / 10)
        local aniActionleft = cc.Animate:create(animationleft)
        local aniActionright = cc.Animate:create(animationright)
        self.smokeEffLeft:runAction(cc.RepeatForever:create(aniActionleft))
        self.smokeEffRight:runAction(cc.RepeatForever:create(aniActionright))
    end
    local function addEpoEff()
        self.epoEffUp = display.newSprite("#deadEffMachine_29.png")
        :align(display.CENTER_BOTTOM,display.width*0.93,display.height*0.58)
        :addTo(self.bg)
        self.epoEffUp:scale(1.6)
        self.epoEffDown = display.newSprite("#deadEffMachine_29.png")
        :align(display.CENTER_BOTTOM,display.width*0.58,display.height*0.35)
        :addTo(self.bg)
        self.epoEffDown:scale(2.5)
        local frames = display.newFrames("deadEffMachine_%02d.png", 0, 30)
        local animation = display.newAnimation(frames, 1.5/30)
        local aniAction = cc.Animate:create(animation)
        self.epoEffUp:runAction(cc.RepeatForever:create(transition.sequence({
                                                                                aniAction,
                                                                                cc.DelayTime:create(4),
                                                                            })))
        self.epoEffDown:runAction(cc.RepeatForever:create(transition.sequence({
                                                                                cc.DelayTime:create(3.5),
                                                                                aniAction,
                                                                                cc.DelayTime:create(0.5),
                                                                            })))
    end
    display.addSpriteFrames("Battle/Skill/DeadEff.plist", "Battle/Skill/DeadEff.png", addEpoEff)
    display.addSpriteFrames("area/areaEffects/fallSmokeImg.plist", "area/areaEffects/fallSmokeImg.png", addMistEff)
    -- CGSceneTwo.new({onComplete=function()
    --                       app:enterScene("regTalkScene",{heroTmpId =roleCreateData["templateId"]})
    --                     end, 
    --                     heroTmpId = roleCreateData["templateId"],
    --                    })
    -- :addTo(self)
    --startFightBattleScene_addBattleFrameCache()
    -- my.MyUtils:uncompressZip("cmd.zip",Launcher.writablePath)

    if params == "createRole" then
        self:initRolePanel()
    else
        --地址不良游戏
        -- local txt = "抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。"
        -- cc.ui.UILabel.new({UILabelType = 2, text = txt, size = 20})
        -- :addTo(self)
        -- :align(display.CENTER, display.cx, 15)
    end
end

function LoginScene:onExit()
    LoginSceneInstance = nil
    if IsStartFight==false then
        --audio.playMusic("audio/mainbg.mp3", true)
    end

    print("start unload Animation 1---------------------------")
    local strPath_1 = "startCG_1/startCG_1.ExportJson"
    --print("---------------------------------------------------------=======")
    --print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(strPath_1)
    for i=0,1 do
        local strPath_2 = "startCG_1/startCG_1"..i..".plist"
        local strPath_3 = "startCG_1/startCG_1"..i..".png"
        display.removeSpriteFramesWithFile(strPath_2, strPath_3)
    end
end

function addAccount(username, password)
    print("addAccount")
    if GameData.accountList==nil then
        GameData.accountList={}
    end
    local account={}
    account.username = username
    account.password = password
    account.musicSwitch = true
    account.soundSwitch = true
    -- printTable(GameData)
    for k,value in ipairs(GameData.accountList) do --已经存在的账户，添加后放到第一个（即删除之前的再插入到第一个）
        -- printTable(value)
        if value.username==account.username then
            --删除之前把音乐开关记录下来
            if value.musicSwitch~=nil then
                account.musicSwitch = value.musicSwitch
            end
            if value.soundSwitch~=nil then
                account.soundSwitch = value.soundSwitch
            end
            table.remove(GameData.accountList,k)
            break
        end
    end
    -- printTable(account)
    table.insert(GameData.accountList,1,account)
    if #GameData.accountList>=4 then --最多保存三个账号，多余的自动删除
        for i=4,#GameData.accountList do
            table.remove(GameData.accountList)
        end
        
    end

    -- printTable(GameData.accountList)
    GameState.save(GameData)
end
function delAccount(username)
    for k,value in ipairs(GameData.accountList) do
        if value.username==username then
            table.remove(GameData.accountList,k)
            break
        end
    end
    if #GameData.accountList==0 then
        GameData.accountList=nil
    end

    GameState.save(GameData)
end
function getAccount()
    if GameData.accountList~=nil and #GameData.accountList==0 then
        GameData.accountList=nil
    end
    -- printTable(GameData)
    return GameData.accountList
end
function LoginScene:showVersion()
    local path = cc.FileUtils:getInstance():getWritablePath() .. "upd/res/flist"
    local fileList = nil
    if cc.FileUtils:getInstance():isFileExist(path) then
        fileList = doFile(path)
    else
        fileList = doFile("flist")
    end
    --当前版本号
    self.curVersion = fileList.version
    g_Version = fileList.version
    self.versionLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "Version: "..self.curVersion, size = display.height/35, align = cc.ui.TEXT_ALIGN_RIGHT, color = display.COLOR_WHITE})
    :align(display.CENTER_RIGHT, display.width*0.98, display.height*0.98)
    :addTo(self, 30)
    self.versionLabel:setVisible(true)
end
function doFile(path)
    local fileData = cc.HelperFunc:getFileData(path)
    local fun = loadstring(fileData)
    local ret, flist = pcall(fun)
    if ret then
        return flist
    end
    return flist
end
function setMusicSwitch()
    -- printTable(GameData)
    --音乐
    musicSwitch= GameData.musicSwitch
    if musicSwitch==nil then musicSwitch=true end
    if musicSwitch then
        print("audio.setMusicVolume(1.0)")
        audio.setMusicVolume(1.0)
    else
        print("audio.setMusicVolume(0.0)")
        audio.setMusicVolume(0.0)
    end
    --音效
    soundSwitch= GameData.soundSwitch
    if soundSwitch==nil then soundSwitch=true end
    if soundSwitch  then
        audio.setSoundsVolume(1.0)
    else
        audio.setSoundsVolume(0.0)
    end
end

function LoginScene:createNoticePanel(noticedata)
    noticePanel = display.newLayer()
    :addTo(self,100)
    self:setTouchEnabled(true)

    local posY = { display.cy-77, }
    for i=1,4 do
        local bar = display.newSprite("common2/com2_Img_19.png")
        :addTo(noticePanel, 1,99)
        :pos(display.cx, (display.cy-238)+(i-1)*155)

        if i<4 then
            display.newSprite("common2/com2_Img_18.png")
            :addTo(bar,-1)
            :pos(35, bar:getContentSize().height)

            display.newSprite("common2/com2_Img_18.png")
            :addTo(bar,-1)
            :pos(bar:getContentSize().width - 35, bar:getContentSize().height)
        end
        
    end

    local img = display.newSprite("common2/com2_Img_20.png")
    :addTo(noticePanel, 1,100)
    :pos(display.cx, display.cy)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(30, 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(30,img:getContentSize().height - 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(img:getContentSize().width - 40, 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(img:getContentSize().width - 40, img:getContentSize().height - 30)

    --知道了按钮
    -- cc.ui.UIPushButton.new("SingleImg/messageBox/iknow.png")
    -- :addTo(noticePanel, 0,101)
    -- :pos(display.cx, display.cy-220)
    -- :onButtonPressed(function(event) event.target:setScale(0.95) end)
    -- :onButtonRelease(function(event) event.target:setScale(1.0) end)

    --关闭按钮
    createCloseBt()
    :addTo(noticePanel, 1,102)
    :pos(display.cx+505, display.cy+270)
    :onButtonClicked(function(event)
        if self.bCloseServerNotice then
            cc.Director:getInstance():endToLua()
            return
        end
        noticePanel:removeSelf()
        end)

    local webview
    local noticeMenus = {}
    local noticeId = 0
    local function setMenuStatus(event)
        print("点击公告栏")
        local ntag = event.target:getTag()
        noticeId = noticedata[ntag - 1000].id

        webview:removeSelf()
        webview = nil
        webview = ccexp.WebView:create()
        img:addChild(webview, 100)
        webview:setVisible(true)
        webview:setScalesPageToFit(true)
        local url = DIR_SERVER_URL.."/userver/common/getNotice?data="
        local data = "{\"nId\":"..noticeId..",\"chnlId\":"..gType_Chnl.."}"
        local data = encodeURI(data)
        url = url..data
        webview:loadURL(url)
        webview:setContentSize(cc.size(790,500)) -- 一定要设置大小才能显示
        webview:reload()
        webview:setPosition(img:getContentSize().width/2,img:getContentSize().height/2)


        for i=1,#noticedata do
            noticeMenus[i]:setButtonEnabled(true)
            noticeMenus[i]:setLocalZOrder(0)
            noticeMenus[i]:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        end
        event.target:setButtonEnabled(false)
        event.target:setLocalZOrder(2)
        event.target:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
    end
    for i=1,#noticedata do
        noticeMenus[i] = cc.ui.UIPushButton.new({
            normal = "common/common_nBt7_1.png",
            disabled = "common/common_nBt7_2.png"
            })
        :addTo(noticePanel,0, 1000+i)
        :pos(display.cx-520, (display.cy+220)-(i-1)*90)
        :onButtonClicked(setMenuStatus)

        cc.ui.UILabel.new({UILabelType = 2, text = noticedata[i].title, size = 20, color = cc.c3b(0, 149, 178)})
        :addTo(noticeMenus[i],0, 10)
        :align(display.CENTER, -15,0)

        if i==1 then
            noticeId = noticedata[1].id
            noticeMenus[i]:setButtonEnabled(false)
            noticeMenus[i]:setLocalZOrder(2)
            noticeMenus[i]:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
        end

        --停服公告
        if noticedata[i].type==2 then
            self.bCloseServerNotice = true
            break
        end
    end

    webview = ccexp.WebView:create()
        img:addChild(webview, 100)
        webview:setVisible(true)
        webview:setScalesPageToFit(true)
        local url = DIR_SERVER_URL.."/userver/common/getNotice?data="
        local data = "{\"nId\":"..noticeId..",\"chnlId\":"..gType_Chnl.."}"
        local data = encodeURI(data)
        url = url..data
        webview:loadURL(url)
        webview:setContentSize(cc.size(790,500)) -- 一定要设置大小才能显示
        webview:reload()
        webview:setPosition(img:getContentSize().width/2,img:getContentSize().height/2)

end

--初始化创建角色面板
function LoginScene:initRolePanel()
    if musicSwitch then
        audio.playMusic("audio/createBg.mp3", true)
    end
    if firstPanel then
        firstPanel:setVisible(false)
    end
    if self.bg then
        self.bg:setVisible(false)
    end
    
    
    display.removeUnusedSpriteFrames()
    --创建角色
    rolePanel = roleLayer.new()
    :addTo(self)

    --角色选择
    local maleBt,femaleBt
    -- local manager = ccs.ArmatureDataManager:getInstance()
    -- manager:removeArmatureFileInfo("Battle/Hero/Hero_1012_.ExportJson")
    -- manager:addArmatureFileInfo("Battle/Hero/Hero_1012_.ExportJson")
    -- local newRole = ccs.Armature:create("Hero_1012_")
    local newRole = sp.SkeletonAnimation:create("Battle/Hero/Hero_1012_.json","Battle/Hero/Hero_1012_.atlas",1)
    :addTo(rolePanel)
    :align(display.CENTER,rolePanel:getContentSize().width/2,rolePanel:getContentSize().height/2-140)
    newRole:setScale(1.5)
    newRole:setScaleX(-1.5)
    -- newRole:getAnimation():play("Standby")
    -- newRole:getAnimation():gotoAndPlay(0)
    newRole:setAnimation(0, "Standby", true)
    newRole:setTag(100)

    -- manager:removeArmatureFileInfo("Battle/Hero/Hero_1022_.ExportJson")
    -- manager:addArmatureFileInfo("Battle/Hero/Hero_1022_.ExportJson")
    -- local newRole2 = ccs.Armature:create("Hero_1022_")
    local newRole2 = sp.SkeletonAnimation:create("Battle/Hero/Hero_1022_.json","Battle/Hero/Hero_1022_.atlas",1)
    :addTo(rolePanel)
    :align(display.CENTER,rolePanel:getContentSize().width/2,rolePanel:getContentSize().height/2-130)
    newRole2:setScale(1.5)
    newRole2:setScaleX(-1.5)
    -- newRole2:getAnimation():play("Standby")
    -- newRole2:getAnimation():gotoAndPlay(0)
    newRole2:setAnimation(0, "Standby", true)
    newRole2:setTag(101)
    newRole2:setVisible(false)


    local roleInfo = rolePanel:getChildByTag(1000)
    local msgBox = roleInfo:getChildByTag(12)


    roleCreateData["templateId"]=10121
    --男性按钮
    maleBt = roleInfo:getChildByTag(11)
    :setButtonEnabled(false)
    maleBt:onButtonClicked(function(event)
        print("sex:male")
        event.target:setButtonEnabled(false)
        femaleBt:setButtonEnabled(true)
        local role = rolePanel:getChildByTag(100)

        rolePanel:getChildByTag(100):setVisible(true)
        rolePanel:getChildByTag(101):setVisible(false)
        
        roleCreateData["templateId"]=10121
        -- self.introduction_Text:setString("    "..memberData[roleCreateData["templateId"]].des)
   end)
    --女性按钮
    femaleBt = roleInfo:getChildByTag(10)
    femaleBt:onButtonClicked(function(event)
        print("sex:female")
        event.target:setButtonEnabled(false)
        maleBt:setButtonEnabled(true)
        local role = rolePanel:getChildByTag(100)

        rolePanel:getChildByTag(100):setVisible(false)
        rolePanel:getChildByTag(101):setVisible(true)

        roleCreateData["templateId"]=10221
        -- self.introduction_Text:setString("    "..memberData[roleCreateData["templateId"]].des)
   end)

    -- local roleInfo = cc.uiloader:seekNodeByName(roleInfo,"roleInfo")
    self.rolename = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(270, 40)})
    :addTo(roleInfo)
    :pos(1249/2-50, 65)
    self.rolename:setPlaceHolder("请输入昵称")
    self.rolename:setMaxLength(10)
    self.rolename:setText(nickNameList[1]) --初始化随机昵称
    self.rolename:setFontColor(cc.c3b(1, 76, 41))
    --文字描述
    -- self.introduction_Text = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    -- :addTo(msgBox)
    -- :pos(10,msgBox:getContentSize().height-50)
    -- self.introduction_Text:setAnchorPoint(0,1)
    -- self.introduction_Text:setColor(cc.c3b(100, 255, 255))
    -- self.introduction_Text:setWidth(260)
    -- self.introduction_Text:setLineHeight(28)
    -- self.introduction_Text:setString("    "..memberData[roleCreateData["templateId"]].des)
    --随机骰子
    self.saiziBt = roleInfo:getChildByTag(13)
    :onButtonClicked(function(event)
        nickNameIdx = nickNameIdx + 1
        if nickNameIdx==6 then
            startLoading()
            nickNameIdx = 1
            sendData={}
            m_socket:SendRequest(json.encode(sendData), CMD_GETNICKNAME, self, self.onGetNickName)
        else
            self.rolename:setText(nickNameList[nickNameIdx])
        end
        
        end)
    --进入游戏
    local startGameBt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_6_up.png",
        pressed = "common2/com2_Btn_6_down.png"
        })
    :addTo(roleInfo)
    :pos(900,65)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "进入游戏", size = 30, color = cc.c3b(94, 229, 101)}))
    :onButtonClicked(function(event)
        roleCreateData["roleName"] = self.rolename:getText()
        roleCreateData["userName"] = logindata["userName"]

        if self.rolename:getText()=="" then
            showMessageBox("请输入您的昵称！")
            return
        end

        --m_socket:send2SocketServer(m_socket:constructSendData(json.encode(roleCreateData), CMD_ROLE_CREATE))
        curCommand = CMD_ROLE_CREATE

        roleCreateData["mobileOS"] = g_MobileOS
        roleCreateData["ver"] = g_Version
        if not m_socket:isConnected() then
            globalFunc.connectSocketServer(loginServerList["hostIp"],loginServerList["port"])
        else
            m_socket:SendRequest(json.encode(roleCreateData), CMD_ROLE_CREATE, self, self.onRoleCreateResult)
        end
        startLoading()
    end)

end

return LoginScene