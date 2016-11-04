local systemLayer = class("systemLayer", function()
	local layer = display.newLayer()
        layer:setNodeEventEnabled(true)
        return layer
	end)

function systemLayer:ctor()
	local maskLayer =  UIMasklayer.new()
    :addTo(self)
    local function func()
        -- WindowsCloseAction(self.systemBox,nil,function()
        --     self:removeSelf()
        --     end)
        self:removeSelf()
    end
    maskLayer:setOnTouchEndedEvent(func)
	local systemBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
   		display.cy,
   		cc.size(800, 600),cc.rect(119, 127, 1, 1))
	:addTo(maskLayer)
    -- WindowsOpenAction(systemBox)
	maskLayer:addHinder(systemBox)
    self.systemBox = systemBox

	local boxSize = systemBox:getContentSize()

	--关闭
	local closeBt = cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
	:addTo(systemBox,2)
	:pos(boxSize.width-30, boxSize.height-30)
	:onButtonClicked(function(event)
        -- WindowsCloseAction(systemBox,nil,function()
        --     self:removeSelf()
        --     end)
		self:removeSelf()
		end)

	-- --头像
	local headBox = getCHeadBox(srv_userInfo.templateId)
	:addTo(systemBox)
	:pos(110, boxSize.height-110)
    :scale(1.5)
    :onButtonClicked(function(event)
        -- showTips("登录账号："..mUserName)
        end)
    -- local head = display.newSprite("Head/headman_"..memberData[srv_userInfo["templateId"]].resId..".png")
    -- :addTo(headBox)
    -- -- :scale(1.4)
    -- :pos(headBox:getContentSize().width/2, headBox:getContentSize().height/2)
    --名字
    local nameBar = display.newScale9Sprite("common/common_box5.png",systemBox:getContentSize().width/2 - 40, 
		systemBox:getContentSize().height-70,
		cc.size(250, 40))
    :addTo(systemBox)
    local name = cc.ui.UILabel.new({UILabelType = 2, text = srv_userInfo.name, size = 25})
    :addTo(nameBar)
    :align(display.CENTER, nameBar:getContentSize().width/2, nameBar:getContentSize().height/2)
    if srv_userInfo.vip>0 then
        name:setColor(cc.c3b(255, 219, 37))
    else
        name:setColor(cc.c3b(202, 202, 202))
    end
    self.name = name

    --改名按钮
    local modifyName = cc.ui.UIPushButton.new("common/common_nBt10.png")
    :addTo(systemBox)
    :pos(boxSize.width/2+170, boxSize.height-70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "改 名", size = 27, color = cc.c3b(106, 57, 6)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        showMessageBox("是否花费"..srv_userInfo.costDiaResetName.."钻石更改昵称？",
            function(event)
                self:exchangeNameBox()
                end)
        
        end)
 --    local inputName = cc.ui.UIInput.new({image = "EditBoxBg.png",
 --    	size = cc.size(230, 40)})
	-- :addTo(nameBar)
	-- :pos(nameBar:getContentSize().width/2,nameBar:getContentSize().height/2)
	-- inputName:setText(srv_userInfo.name)

    --公会
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "军团：", size = 25, color=cc.c3b(131, 164, 165)})
    :addTo(systemBox)
    :pos(200,boxSize.height-120)

    self.legionName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color=cc.c3b(255, 238, 80)})
    :addTo(systemBox)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
	if srv_userInfo["armyName"]~="" then
        self.legionName:setString(srv_userInfo["armyName"])
    else
        self.legionName:setString("无")
	end
    
    --战队等级
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "战队等级：", size = 25, color=cc.c3b(131, 164, 165)})
    :addTo(systemBox)
    :pos(200,boxSize.height-160)

    local teamLevel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(systemBox)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
    teamLevel:setColor(cc.c3b(143, 255, 82))
    teamLevel:setString(srv_userInfo.level)
    --战队经验
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "战队经验：", size = 25, color=cc.c3b(131, 164, 165)})
    :addTo(systemBox)
    :pos(50,boxSize.height*0.65)

    local pro1 = display.newSprite("system/system_img4.png")
    :addTo(systemBox)
    :pos(boxSize.width/2-35, label:getPositionY())

    local pro2 = cc.ui.UILoadingBar.new({image = "system/system_img5.png",viewRect = cc.rect(0,0,312,27)})
    :addTo(pro1)

    local per = (srv_userInfo.exp/memberLevData[srv_userInfo.level].exp)*100
    pro2:setPercent(math.min(math.max(per,0), 100))

    local teamExp = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(pro1,2)
    :align(display.CENTER, pro1:getContentSize().width/2, pro1:getContentSize().height/2)
    teamExp:setString(srv_userInfo.exp.."/"..memberLevData[srv_userInfo.level].exp)
    local retNode = setLabelStroke(teamExp,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)

    if srv_userInfo.level>=90 then
        pro2:setVisible(false)
        teamExp:setVisible(false)
        removeLabelStrokeString(retNode)
    end

    


    if not g_isBanShu then

    --善恶
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "善恶值：", size = 25, color=cc.c3b(131, 164, 165)})
    :addTo(systemBox)
    :pos(60,boxSize.height*0.57)

    local pro1 = display.newSprite("system/system_img1.png")
    :addTo(systemBox)
    :pos(boxSize.width/2-40, label:getPositionY())

    local bottomBar = display.newSprite("system/system_img2.png")
    :addTo(systemBox)
    :pos(boxSize.width/2-40, label:getPositionY())

    local per = 0.5-srv_userInfo["goodEvil"]/(5000*2)
    cc.ui.UILoadingBar.new({image = "system/system_img3.png", viewRect = cc.rect(0,0,292,27)})
    :addTo(bottomBar)
    :setPercent(math.min(math.max(per*100,0), 100))

    if per>1 then
        per=1
    end
    local img = display.newSprite("#MainUI_img34.png")
    :addTo(bottomBar)
    :pos(bottomBar:getContentSize().width/2+bottomBar:getContentSize().width*(per-0.5), bottomBar:getContentSize().height/2)

    --善恶数值
    if per==0.5 then
    elseif per<0.5 then --善
        cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 20, color = cc.c3b(127, 79, 33)})
        :addTo(bottomBar,2)
        :align(display.CENTER_LEFT, img:getPositionX()+25, img:getPositionY())
        :setString(srv_userInfo["goodEvil"])
    else
        cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 20, color = cc.c3b(43, 0, 0)})
        :addTo(bottomBar,2)
        :align(display.CENTER_RIGHT, img:getPositionX()-25, img:getPositionY())
        :setString((-srv_userInfo["goodEvil"]))
    end

    end

  --   local img5 = display.newSprite("system/text5.png")
  --   :addTo(bar)
  --   :pos(bar:getContentSize().width/2 + 40, bar:getContentSize().height/2)
  --   img5:setAnchorPoint(0,0.5)
  --   local teamTitle = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
  --   :addTo(bar)
  --   :pos(bar:getContentSize().width/2 + 50 + img5:getContentSize().width, bar:getContentSize().height/2-2)
  --   teamTitle:setColor(MYFONT_COLOR)
  --   teamTitle:setString(srv_userInfo["goodEvil"])
    --音乐
    local musicBt = cc.ui.UIPushButton.new({
    	normal = "system/text6.png",
    	pressed = "system/text12.png"
    	})
    :addTo(systemBox)
    :pos(100, boxSize.height*0.45)
    :onButtonClicked(function(event)
    	if musicSwitch then
    		musicSwitch = false
    		audio.setMusicVolume(0.0)
    		event.target:getChildByTag(10):setTexture("system/text7.png")
    	else
    		musicSwitch = true
    		audio.setMusicVolume(1.0)
    		event.target:getChildByTag(10):setTexture("system/text8.png")
    	end
    	
        -- for i,value in ipairs(GameData.accountList) do
        --     if value.username==mUserName then
        --         GameData.accountList[i].musicSwitch = musicSwitch
        --         break
        --     end
        -- end
        -- printTable(GameData.accountList)
        GameData.musicSwitch = musicSwitch
        GameState.save(GameData)
    	end)
    local img1
    if musicSwitch then
        img1 = display.newSprite("system/text8.png")
    else
        img1 = display.newSprite("system/text7.png")
    end
    img1:addTo(musicBt,0,10)
    --音效
    local soundBt = cc.ui.UIPushButton.new({
    	normal = "system/text6.png",
    	pressed = "system/text12.png"
    	})
    :addTo(systemBox)
    :pos(230, boxSize.height*0.45)
    :onButtonClicked(function(event)
    	if soundSwitch then
    		soundSwitch = false
    		audio.setSoundsVolume(0.0)
    		event.target:getChildByTag(10):setTexture("system/text10.png")
    	else
    		soundSwitch = true
    		audio.setSoundsVolume(1.0)
    		event.target:getChildByTag(10):setTexture("system/text9.png")
    	end
    	
        -- for i,value in ipairs(GameData.accountList) do
        --     if value.username==mUserName then
        --         GameData.accountList[i].soundSwitch = soundSwitch
        --         break
        --     end
        -- end
        GameData.soundSwitch = soundSwitch
        GameState.save(GameData)
    	end)
    local img1
    if soundSwitch then
        img1 = display.newSprite("system/text9.png")
    else
        img1 = display.newSprite("system/text10.png")
    end
    
    img1:addTo(soundBt,0,10)
    --兑换码
    local exchangeCode = cc.ui.UIPushButton.new("common/common_nBt8.png")
    :addTo(systemBox)
    :pos(boxSize.width/2+40, boxSize.height*0.45)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "礼品兑换", size = 27, color = cc.c3b(106, 57, 6)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():setPosition(15, 0) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():setPosition(15, 0) end)
    :onButtonClicked(function(event)
        self:exchangeCodeCenter()
    	end)
    exchangeCode:getButtonLabel():setPosition(15, 0)
    display.newSprite("system/system_img7.png")
    :addTo(exchangeCode)
    :pos(-53,0)

    if srv_userInfo.atcode==1 then
        exchangeCode:setVisible(true)
    else
        exchangeCode:setVisible(false)
    end

    --切换账号
    local exchangeAccount = cc.ui.UIPushButton.new("common/common_nBt10.png")
    :addTo(systemBox)
    :pos(boxSize.width-130, boxSize.height*0.45)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "切换账号", size = 27, color = cc.c3b(60, 5, 8)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():setPosition(15, 0) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():setPosition(15, 0) end)
    :onButtonClicked(function(event)
        -- m_socket:disconnect()
        m_socket = nil

        if isUCLogin then
            luaUCGameSdk:logout()
        elseif isDownJoyLogin then
            downJoySDK:downjoyLogout()
        elseif isHUAWEILogin then
            luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaLogoutForHuawei", {}, "()V")
            DCAccount.logout()
            app:enterScene("LoginScene",{1})
            display.removeUnusedSpriteFrames()
        elseif isBaiDuLogin then
            baiduSDK:logout()
            DCAccount.logout()
            app:enterScene("LoginScene",{1})
            display.removeUnusedSpriteFrames()
        elseif isWdjLogin then
            wdjSDK:logout()
            DCAccount.logout()
            app:enterScene("LoginScene",{1})
            display.removeUnusedSpriteFrames()
        elseif isAnzhiLogin then
            anzhiSDK:logout()
        elseif isCoolPadLogin then
            coolpad_changeAccResult(1,"")
        elseif isLieBaoLogin then
            LieBaoSDK:logout()
            --等SDK注销回调回来处理切换场景
        elseif isLeshiLogin then
            leshiSDK:switchUser()
            DCAccount.logout()
            app:enterScene("LoginScene",{1})
            display.removeUnusedSpriteFrames()
        else
            --以上的几个，会在切换账号的回调中切换场景
            DCAccount.logout()
            app:enterScene("LoginScene",{1})
            display.removeUnusedSpriteFrames()
        end

    end)
    exchangeAccount:getButtonLabel():setPosition(15, 0)
    display.newSprite("system/system_img8.png")
    :addTo(exchangeAccount)
    :pos(-52,0)

    --推送相关
    cc.ui.UILabel.new({UILabelType = 2, text = "12:00", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
    :align(display.CENTER_LEFT,  boxSize.width*0.06, boxSize.height*0.29)
    :addTo(systemBox)
    cc.ui.UILabel.new({UILabelType = 2, text = "午间免费汽油", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,221,95)})
    :align(display.CENTER_LEFT,  boxSize.width*0.16, boxSize.height*0.29)
    :addTo(systemBox)
    self.tag1200Item = cc.ui.UICheckBoxButton.new({on = "system/pushOn.png", off = "system/pushOff.png"})
    :setButtonLabel(cc.ui.UILabel.new({text = "关", size = display.height*0.05,  color = cc.c3b(128, 255, 63)}))
    :setButtonLabelOffset(0, 0) --设置文本显示的偏移位置
    :setButtonLabelAlignment(display.CENTER) --设置文本对齐方式
    :pos(boxSize.width*0.45, boxSize.height*0.29)
    :addTo(systemBox)
    self.tag1200Item:scale(0.8)

    cc.ui.UILabel.new({UILabelType = 2, text = "18:00", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
    :align(display.CENTER_LEFT,  boxSize.width*0.53, boxSize.height*0.29)
    :addTo(systemBox)
    cc.ui.UILabel.new({UILabelType = 2, text = "晚间免费汽油", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,221,95)})
    :align(display.CENTER_LEFT,  boxSize.width*0.63, boxSize.height*0.29)
    :addTo(systemBox)
    self.tag1800Item = cc.ui.UICheckBoxButton.new({on = "system/pushOn.png", off = "system/pushOff.png"})
    :setButtonLabel(cc.ui.UILabel.new({text = "关", size = display.height*0.05,  color = cc.c3b(128, 255, 63)}))
    :setButtonLabelOffset(0, 0) --设置文本显示的偏移位置
    :setButtonLabelAlignment(display.CENTER) --设置文本对齐方式
    :pos(boxSize.width*0.92, boxSize.height*0.29)
    :addTo(systemBox)
    self.tag1800Item:scale(0.8)

    cc.ui.UILabel.new({UILabelType = 2, text = "12:30", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
    :align(display.CENTER_LEFT,  boxSize.width*0.06, boxSize.height*0.14)
    :addTo(systemBox)
    cc.ui.UILabel.new({UILabelType = 2, text = "世界BOSS开启", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,221,95)})
    :align(display.CENTER_LEFT,  boxSize.width*0.16, boxSize.height*0.14)
    :addTo(systemBox)
    self.tag1230Item = cc.ui.UICheckBoxButton.new({on = "system/pushOn.png", off = "system/pushOff.png"})
    :setButtonLabel(cc.ui.UILabel.new({text = "关", size = display.height*0.05,  color = cc.c3b(128, 255, 63)}))
    :setButtonLabelOffset(0, 0) --设置文本显示的偏移位置
    :setButtonLabelAlignment(display.CENTER) --设置文本对齐方式
    :pos(boxSize.width*0.45, boxSize.height*0.14)
    :addTo(systemBox)
    self.tag1230Item:scale(0.8)

    cc.ui.UILabel.new({UILabelType = 2, text = "20:00", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
    :align(display.CENTER_LEFT,  boxSize.width*0.53, boxSize.height*0.14)
    :addTo(systemBox)
    cc.ui.UILabel.new({UILabelType = 2, text = "世界BOSS开启", size = display.height*0.032, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,221,95)})
    :align(display.CENTER_LEFT,  boxSize.width*0.63, boxSize.height*0.14)
    :addTo(systemBox)
    self.tag2000Item = cc.ui.UICheckBoxButton.new({on = "system/pushOn.png", off = "system/pushOff.png"})
    :setButtonLabel(cc.ui.UILabel.new({text = "关", size = display.height*0.05,  color = cc.c3b(128, 255, 63)}))
    :setButtonLabelOffset(0, 0) --设置文本显示的偏移位置
    :setButtonLabelAlignment(display.CENTER) --设置文本对齐方式
    :pos(boxSize.width*0.92, boxSize.height*0.14)
    :addTo(systemBox)
    self.tag2000Item:scale(0.8)
   
    self:initPushButtons()
    self.tag1200Item:onButtonStateChanged(function(event) --处理按钮状态变化
        self:updatePushButton(event.target)
    end)
    self.tag1800Item:onButtonStateChanged(function(event) --处理按钮状态变化
        self:updatePushButton(event.target)
    end)
    self.tag1230Item:onButtonStateChanged(function(event) --处理按钮状态变化
        self:updatePushButton(event.target)
    end)
    self.tag2000Item:onButtonStateChanged(function(event) --处理按钮状态变化
        self:updatePushButton(event.target)
    end)
end
--初始化各状态
function systemLayer:initPushButtons()
    if GameData.pushTags == nil then
        GameData.pushTags = {}
        GameData.pushTags.tag1200 = 1
        GameData.pushTags.tag1800 = 1
        GameData.pushTags.tag1230 = 1
        GameData.pushTags.tag2000 = 1
        self.tag1200Item:setButtonSelected(true)
        self.tag1800Item:setButtonSelected(true)
        self.tag1230Item:setButtonSelected(true)
        self.tag2000Item:setButtonSelected(true)
        GameState.save(GameData)
        return
    else
        if GameData.pushTags.Tag_1200 == 1 then 
            self.tag1200Item:setButtonSelected(true)
            self.tag1200Item:setButtonLabelString("开")
        else
            self.tag1200Item:setButtonSelected(false)
            self.tag1200Item:setButtonLabelString("关")
        end
        if GameData.pushTags.Tag_1800 == 1 then 
            self.tag1800Item:setButtonSelected(true)
            self.tag1800Item:setButtonLabelString("开")
        else
            self.tag1800Item:setButtonSelected(false)
            self.tag1800Item:setButtonLabelString("关")
        end
        if GameData.pushTags.Tag_1230 == 1 then 
            self.tag1230Item:setButtonSelected(true)
            self.tag1230Item:setButtonLabelString("开")
        else
            self.tag1230Item:setButtonSelected(false)
            self.tag1230Item:setButtonLabelString("关")
        end
        if GameData.pushTags.Tag_2000 == 1 then 
            self.tag2000Item:setButtonSelected(true)
            self.tag2000Item:setButtonLabelString("开")
        else
            self.tag2000Item:setButtonSelected(false)
            self.tag2000Item:setButtonLabelString("关")
        end
    end
end
function systemLayer:updatePushButton(_button)
    -- if _button:isButtonSelected() then
    --     _button:setButtonLabelString("开")
    -- else
    --     _button:setButtonLabelString("关")
    -- end
    
    -- if self.tag1200Item:isButtonSelected() then
    --     jpushSDK:addTag("Tag_1200")
    -- else
    --     jpushSDK:removeTag("Tag_1200")
    -- end
    -- if self.tag1800Item:isButtonSelected() then
    --     jpushSDK:addTag("Tag_1800")
    -- else
    --     jpushSDK:removeTag("Tag_1800")
    -- end
    -- if self.tag1230Item:isButtonSelected() then
    --     jpushSDK:addTag("Tag_1230")
    -- else
    --     jpushSDK:removeTag("Tag_1230")
    -- end
    -- if self.tag2000Item:isButtonSelected() then
    --     jpushSDK:addTag("Tag_2000")
    -- else
    --     jpushSDK:removeTag("Tag_2000")
    -- end

    -- GameData.pushTags = jpushTags
    -- GameState.save(GameData)
    -- jpushSDK:setTag()
end
function systemLayer:onEnter()
end
function systemLayer:onExitLegion(result)
    endLoading()
    if result.result==1 then
        srv_userInfo["armyName"]=""
        self.modifyName:setVisible(false)
        self.legionName:setString("无")
        --退出军团后，保存的数据清空
        InitLegionList          = {} --符合条件的军团信息
        mLegionData             = {} --自己军团的信息
        armyId                  = nil--军团申请列表
        legionFBData            = {} --军团副本
        lgionFBResult           = nil --军团副本返回结果类型
        LegionFB_RecordData     = {} --军团分配记录
        findLegionData          = {} --查找军团数据
        LegionDamageRankData    = {} --军团伤害排名
        LegionSpoilsData        = {} --军团战利品信息
        --退出军团，便不能租车了
        RentMgr.rentInfo = {}
        RentMgr.sortList = {}
        RentMgr:InitWithLocalData()
    else
        showTips(result.msg)
    end
end
function systemLayer:exchangeCodeCenter()
    local masklayer =  UIMasklayer.new()
    :addTo(self,10)
    local function  func()
        WindowsCloseAction(self.changeBox,nil,function()
            masklayer:removeSelf()
            end)
        -- masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)

    local box = display.newSprite("system/text18.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    masklayer:addHinder(box)
    WindowsOpenAction(box)
    self.changeBox = box

    display.newSprite("system/text19.png")
    :addTo(box)
    :pos(box:getContentSize().width/2, box:getContentSize().height - 36)

    local confirmBt = createGreenBt("确定")
    :addTo(box)
    :pos(box:getContentSize().width/2, 50)
    :onButtonClicked(function(event)
        --masklayer:removeSelf()
        box:exchangeCDKey()
        end)

    box.cdkeyInput = cc.ui.UIInput.new({image = "EditBoxBg.png",size = cc.size(403, 40)})
    :addTo(box)
    :pos(box:getContentSize().width/2, box:getContentSize().height - 96)
    box.cdkeyInput:setPlaceHolder("请输入兑换码")

    function box:exchangeCDKey()
        local str = box.cdkeyInput:getText()
        if str=="" then
            showTips("兑换码不能为空")
            return 
        end
        local sendData={code = str}
        m_socket:SendRequest(json.encode(sendData), CMD_CDKEY, box, box.OnExchangeCDKeyRet)
        startLoading()
    end

    function box:OnExchangeCDKeyRet(cmd)
        endLoading()
        if cmd.result==1 then
            local tptId = cmd.data.tptId
            local loc_data = cdKeyData[tptId]
            print("tptId: "..tptId)
            local rewards = {}
            local arr1 = string.split(loc_data.rewardItems,"|")
            for i = 1 ,#arr1 do
                local arr2 = string.split(arr1[i],"#")
                table.insert(rewards, {templateID=tonumber(arr2[1]), num=tonumber(arr2[2])})
                local dc_item = itemData[tonumber(arr2[1])]
                if dc_item then  --当奖励为道具时
                    DCItem.get(tostring(dc_item.id), dc_item.name, tonumber(arr2[2]), "激活码兑换")
                end
            end
            if loc_data.gold~=0 then
                table.insert(rewards, {templateID=GAINBOXTPLID_GOLD, num=loc_data.gold})
            end
            if loc_data.diamond~=0 then
                table.insert(rewards, {templateID=GAINBOXTPLID_DIAMOND, num=loc_data.diamond})
            end
            box.cdkeyInput:setVisible(false)
            GlobalShowGainBox({bAlwaysExist = true}, rewards,nil,function ()
                box.cdkeyInput:setVisible(true)
            end)
            srv_userInfo.gold = srv_userInfo.gold+loc_data.gold
            srv_userInfo.diamond = srv_userInfo.diamond+loc_data.diamond
            srv_userInfo.exp = srv_userInfo.exp+loc_data.exp
            srv_userInfo.energy = srv_userInfo.energy+loc_data.energy
            srv_userInfo.honor = srv_userInfo.honor+loc_data.honor
            mainscenetopbar:setGlod()
            mainscenetopbar:setDiamond()
            DCCoin.gain("激活码兑换","金币",loc_data.gold,srv_userInfo.gold)
            DCCoin.gain("激活码兑换","钻石",loc_data.diamond,srv_userInfo.diamond)
            --g_mainSceneTopBar:refreshBarData()
        else
            showTips(cmd.msg)
        end
    end

end

function systemLayer:exchangeNameBox()
    local masklayer =  UIMasklayer.new()
    :addTo(self,10)
    local function  func()
        WindowsCloseAction(self.changeBox,nil,function()
            masklayer:removeSelf()
            end)
        -- masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    self.chNameMask = masklayer

    local box = display.newSprite("system/text18.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    masklayer:addHinder(box)
    WindowsOpenAction(box)
    self.changeBox = box

    cc.ui.UILabel.new({UILabelType = 2, text = "改 名", size = 25})
    :addTo(box)
    :align(display.CENTER, box:getContentSize().width/2, box:getContentSize().height - 30)

    box.cdkeyInput = cc.ui.UIInput.new({image = "EditBoxBg.png",size = cc.size(403, 40)})
    :addTo(box)
    :pos(box:getContentSize().width/2, box:getContentSize().height - 96)
    box.cdkeyInput:setPlaceHolder("请输入名字")

    local confirmBt = createGreenBt("确定")
    :addTo(box)
    :pos(box:getContentSize().width/2, 50)
    :onButtonClicked(function(event)
        --masklayer:removeSelf()
        local str = box.cdkeyInput:getText()
        if str=="" then
            showTips("名字不能为空")
            return 
        end

        self.curName = str
        local sendData={name = str}
        m_socket:SendRequest(json.encode(sendData), CMD_CHANGENAME, self, self.OnExchangeNameRet)
        startLoading()
        end)


end

function systemLayer:OnExchangeNameRet(cmd)
        endLoading()
        if cmd.result==1 then
            print("改名成功")
            self.name:setString(self.changeBox.cdkeyInput:getText())
            srv_userInfo.diamond = srv_userInfo.diamond - srv_userInfo.costDiaResetName
            mainscenetopbar:setDiamond()
            srv_userInfo.costDiaResetName = srv_userInfo.costDiaResetName + 100

            srv_userInfo.name = self.curName
            display.getRunningScene().charactorName:setString(srv_userInfo.name)

            RoleManager.isReqFlag = true
            
        else
            showTips(cmd.msg)
        end

        self.chNameMask:removeSelf()
    end

return systemLayer