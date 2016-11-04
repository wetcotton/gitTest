--
-- Author: Jun Jiang
-- Date: 2014-12-24 14:36:07
--
BarScene = class("BarScene",function()
	local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)
BarScene.Instance = nil
local armatureDataMgr = ccs.ArmatureDataManager:getInstance()

function BarScene:ctor()
    
    local tmpNode, tmpStr

    --资源加载
    display.addSpriteFrames("Image/UIBar/UIBar.plist", "Image/UIBar/UIBar.png")

    self.masklayer = UIMasklayer.new()
    self:addChild(self.masklayer, 97)
    self.masklayer.bIgnoreInvisible = true
    self.masklayer:setOnTouchEndedEvent(handler(self, self.onTouchEndedEvent))
    self.masklayer:setVisible(false)
    self.dialog = UIDialog.new()
    self:addChild(self.dialog, 98)
    self.dialog:setVisible(false)
    self:LoadBounty()
    self:LoadStoryUI()

    self.backBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height )
    	:addTo(self, 1)
    	:onButtonClicked(function(event)
    		self:removeFromParent()
            local _scene = cc.Director:getInstance():getRunningScene()
    	end)

    --酒吧场景
    local fScale = 2/3
    armatureDataMgr:addArmatureFileInfo("Image/UIBar/qwer3.ExportJson")
    local armature = ccs.Armature:create("qwer3")
    armature:addTo(self)
    armature:setScale(fScale)
    armature:align(display.CENTER, display.cx-15, display.cy)
    local animation = armature:getAnimation()
    animation:play("Standby", -1, -1)

    --客人甲、乙，女老板
    local path = {
        "Image/UIBar/qwer.ExportJson",
        "Image/UIBar/qwer1.ExportJson",
        "Image/UIBar/qwer2.ExportJson",
    }
    local name = {
        "qwer",
        "qwer1",
        "qwer2"
    }
    local armature2
    for i=1, #path do
        armatureDataMgr:addArmatureFileInfo(path[i])
        armature2 = ccs.Armature:create(name[i])
        animation = armature2:getAnimation()
        animation:play("Standby", -1, -1)

        bone = ccs.Bone:create(name[i])
        bone:addDisplay(armature2, 0)
        bone:changeDisplayWithIndex(0, true)
        bone:setIgnoreMovementBoneData(true)
        if 3==i then    --女老板
            bone:setLocalZOrder(1)
        else
            bone:setLocalZOrder(20)
        end
        armature:addBone(bone, "Layer27")
        bone:setPosition(-960, -720)
    end

    --赏金首
    self.bustBtn = cc.ui.UIPushButton.new()
        :align(display.CENTER, display.cx-150, display.cy+190)
        :size(230, 333)
        :addTo(self, 1)
        :onButtonClicked(function(event)
            -- self.masklayer:setVisible(true)
            -- if nil~=self.panelBounty then
            --     self.panelBounty:setVisible(true)
            -- end
            -- printTable(BarMgr.BarInfo)
        end)

    local loc_Area = areaData[srv_userInfo["areaId"]]
    if 0~=loc_Area.bossId then
        --赏金首头像
        tmpStr = string.format("Bust/bust_%d.png", loc_Area.bust)
        local arr = string.split(loc_Area.capInsets, "#")
        local cap = cc.rect(tonumber(arr[1]), tonumber(arr[2]), tonumber(arr[3]), tonumber(arr[4]))
        self.sprWanted = display.newSprite(tmpStr, 0, 0, {capInsets=cap})
                            :scale(loc_Area.scale*0.8)
                            :align(display.CENTER, display.cx-170, display.cy+181)
                            :addTo(self, 1)
                            :hide()
        --赏金
        arr = string.split(loc_Area.bounty, "|")
        self.labBounty = display.newTTFLabel({
                                text = arr[2],
                                size = 40,
                                color = cc.c3b(255, 0, 0),
                                align = cc.TEXT_ALIGNMENT_LEFT,
                                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                                -- dimensions = cc.size(180, 50)
                            })
                            :align(display.LEFT_CENTER, display.cx-250, display.cy+73)
                            :addTo(self, 1)
                            :hide()
    end

    --赏金首title
    display.newSprite("#UIBar_Text1.png")
        :align(display.CENTER, display.cx-250, display.cy+325)
        :addTo(self, 1)
        :hide()

    --剧情回顾
    cc.ui.UIPushButton.new()
        :align(display.CENTER, display.cx+490, display.cy+250)
        :size(240, 255)
        :addTo(self, 1)
        :onButtonClicked(function(event)
            self.masklayer:setVisible(true)
            if nil~=self.panelStory then
                self:ChooseStoryTab(1)
                self:ChooseStoryItem(-1)
                self.panelStory:setVisible(true)
            end
        end)

    --裁剪节点
    local viewRect = cc.rect(display.cx+382, display.cy+140, 160, 95)
    self.clipNode = cc.ClippingRegionNode:create(viewRect)
    self.clipNode:addTo(self, 1)

    --奔跑的文字
    self.runningText = {}
    self.runningText.nCurPosX, self.runningText.nCurPosY = viewRect.x+viewRect.width, viewRect.y+viewRect.height/2
    self.runningText.spr = display.newSprite("#UIBar_Text2.png")
                            :align(display.LEFT_CENTER, self.runningText.nCurPosX, self.runningText.nCurPosY)
                            :addTo(self.clipNode)
    self.runningText.nCurIndex = 2
    self.runningText.nMinPosX = viewRect.x-self.runningText.spr:getContentSize().width

    local function Callback(pSender)
        self.runningText.nCurPosX = self.runningText.nCurPosX-5
        if self.runningText.nCurPosX<=self.runningText.nMinPosX then
            self.runningText.nCurIndex = self.runningText.nCurIndex+1
            if self.runningText.nCurIndex>7 then
                self.runningText.nCurIndex = 2
            end
            self.runningText.nCurPosX = viewRect.x+viewRect.width
            local name = string.format("UIBar_Text%d.png", self.runningText.nCurIndex)
            local frame = display.newSpriteFrame(name)
            self.runningText.spr:setSpriteFrame(frame)
            self.runningText.nMinPosX = viewRect.x-self.runningText.spr:getContentSize().width
        end
        self.runningText.spr:setPosition(self.runningText.nCurPosX, self.runningText.nCurPosY)
    end

    local seq = transition.sequence({
                    cc.DelayTime:create(0.1),
                    cc.CallFunc:create(Callback),
                })
    transition.execute(self, cc.RepeatForever:create(seq))
    

    BarScene.Instance = self
    if nil~=BarMgr.BarInfo and BarMgr.BarInfo.styArId<srv_userInfo.areaId then
        local nID = srv_userInfo.areaId*1000+101
        self.dialog:TriggerDialog(nID, DialogType.BarPlot)
        BarMgr:ReqRecordStory(srv_userInfo.areaId)
        
    end
end

function BarScene:onEnter()
    -- if nil==BarMgr.BarInfo then
    --     startLoading()
    -- end
    endLoading()
    audio.playMusic("audio/barBg.mp3", true)
end

function BarScene:onExit()
    BarScene.Instance = nil

    display.removeSpriteFramesWithFile("Image/UIBar/UIBar0.plist", "Image/UIBar/UIBar0.png")
    display.removeSpriteFramesWithFile("Image/UIBar/UIBar.plist", "Image/UIBar/UIBar.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_Arrest.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_ChapterBtn1.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_ChapterBtn2.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_ChapterBtnBg.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_QuestionMark.png")
    display.removeSpriteFramesWithFile(nil, "Image/UIBar/UIBar_Wanted.png")

    armatureDataMgr:removeArmatureFileInfo("Image/UIBar/qwer.ExportJson")
    armatureDataMgr:removeArmatureFileInfo("Image/UIBar/qwer1.ExportJson")
    armatureDataMgr:removeArmatureFileInfo("Image/UIBar/qwer2.ExportJson")
    armatureDataMgr:removeArmatureFileInfo("Image/UIBar/qwer3.ExportJson")

    display.removeSpriteFramesWithFile("Image/UIBar/qwer0.plist", "Image/UIBar/qwer0.png")
    display.removeSpriteFramesWithFile("Image/UIBar/qwer10.plist", "Image/UIBar/qwer10.png")
    display.removeSpriteFramesWithFile("Image/UIBar/qwer20.plist", "Image/UIBar/qwer20.png")
    display.removeSpriteFramesWithFile("Image/UIBar/qwer30.plist", "Image/UIBar/qwer30.png")
    display.removeSpriteFramesWithFile("Image/UIBar/qwer31.plist", "Image/UIBar/qwer31.png")

    audio.playMusic("audio/mainbg.mp3", true)
end

--初始化信息返回
function BarScene:OnInitInfoRet(cmd)
	-- BarMgr:OnInitInfoRet(cmd)
    if 1==cmd.result then
        self:InitBountyList()
        self:InitBountyView(1)
        if BarMgr.BarInfo.styArId<srv_userInfo.areaId then
            print("还没来过，触发对话")
            local nID = srv_userInfo.areaId*1000+101
            self.dialog:TriggerDialog(nID, DialogType.BarPlot)
            BarMgr:ReqRecordStory(srv_userInfo.areaId)

            self.dialog:SetFinishCallback(function()
                print("剧情结束回调")
                
                self.dialog:SetFinishCallback(nil)
            end)
            GuideManager:removeGuideLayer()
        else
            print("不触发对话")
        
        end
    else
        showTips(cmd.msg)
    end
    endLoading()
end

--提交任务返回
function BarScene:OnSubmitTaskRet(cmd)
	BarMgr:OnSubmitTaskRet(cmd)
    if 1==cmd.result then
        self:InitBountyList()
        self:InitBountyView(self.curSelTab)
        mainscenetopbar:setDiamond()
        mainscenetopbar:setGlod()
    else
        showTips(cmd.msg)
    end
    endLoading()
end

--存储剧情返回
function BarScene:OnRecordStoryRet(cmd)
    BarMgr:OnRecordStoryRet(cmd)
    if 1==cmd.result then
    else
        showTips(cmd.msg)
    end
end

--加载赏金首界面
function BarScene:LoadBounty()
    if nil~=self.panelBounty then
        return
    end

    local rootNode = cc.uiloader:load("Image/UIBar/Bounty.ExportJson")
                        :addTo(self, 99)

    self.panelBounty = cc.uiloader:seekNodeByName(rootNode, "Panel_Bounty")

    local tmpNode = cc.uiloader:seekNodeByName(self.panelBounty, "Image_Bg")
    self.masklayer:addHinder(tmpNode)

    self.bountyView = cc.ui.UIScrollView.new(
        {viewRect=cc.rect(50, 50, 880, 540), direction=cc.ui.UIScrollView.DIRECTION_VERTICAL})
            :addTo(tmpNode)

    self.tabUnFinished = {}
    self.tabUnFinished.img = cc.uiloader:seekNodeByName(self.panelBounty, "Image_Tab1")
    self.tabUnFinished.btn = cc.uiloader:seekNodeByName(self.tabUnFinished.img, "Button_Tab")
                                :onButtonClicked(function()
                                    self:ChooseTab(1, true)
                                end)
    self.tabUnFinished.originalX, self.tabUnFinished.originalY = self.tabUnFinished.img:getPosition()
    self.masklayer:addHinder(self.tabUnFinished.img)

    self.tabFinished = {}
    self.tabFinished.img = cc.uiloader:seekNodeByName(self.panelBounty, "Image_Tab2")
    self.tabFinished.btn = cc.uiloader:seekNodeByName(self.tabFinished.img, "Button_Tab")
                                :onButtonClicked(function()
                                    self:ChooseTab(2, true)
                                end)
    self.tabFinished.originalX, self.tabFinished.originalY = self.tabFinished.img:getPosition()
    self.masklayer:addHinder(self.tabFinished.img)

    self:ChooseTab(1)
    self.panelBounty:setVisible(false)
    self:InitBountyList()
    self:InitBountyView(1)
end

--选择标签（1：未完成  2：已完成）
function BarScene:ChooseTab(nTag, bAni)
    local function setTabEnabled(tab, bEnabled)
        if nil==tab or nil==bEnabled then
            return
        end

        tab.btn:setVisible(bEnabled)
        if bEnabled then
            if bAni then
                tab.img:runAction(cc.MoveTo:create(0.1, cc.p(tab.originalX, tab.originalY)))
            else
                tab.img:setPosition(tab.originalX, tab.originalY)
            end
        elseif false==bEnabled then
            if bAni then
                tab.img:runAction(cc.MoveTo:create(0.1, cc.p(tab.originalX-40, tab.originalY)))
            else
                tab.img:setPosition(tab.originalX-40, tab.originalY)
            end
        end
    end

    if 1==nTag then
        self.curSelTab = 1
        setTabEnabled(self.tabUnFinished, false)
        setTabEnabled(self.tabFinished, true)
    elseif 2==nTag then
        self.curSelTab = 2
        setTabEnabled(self.tabUnFinished, true)
        setTabEnabled(self.tabFinished, false)
    end
    self:InitBountyView(self.curSelTab)
end

--初始化赏金首列表（1：未完成  2：已完成）
function BarScene:InitBountyView(nTag)
    if nil==self.bountyView or nil==self.unFinished or nil==self.finished then
        return
    end
    self.bountyView:removeAllChildren()
    self.bountyView.touchNode_ = nil

    local itemSize = cc.size(293,330)
    self.t_data = {}

    local offsetY = 0
    local tabList
    if 1==nTag then
        offsetY = 45
        tabList = self.unFinished
    elseif 2==nTag then
        offsetY = 0
        tabList = self.finished
    end

    local tmpStr = ""
    local fScale = 1
    for i = 1, #tabList do
        local monsterInfo = monsterData[tabList[i][1]]

        local root = display.newLayer() --cc.LayerColor:create(cc.c4b(160,160,160,0),itemSize.width,itemSize.height)
        root:setContentSize(itemSize.width,itemSize.height)        
        root:setTouchSwallowEnabled(false)
        --把layer当作精灵来处理
        root:ignoreAnchorPointForPosition(false)
        self.t_data[#self.t_data+1] = root

        local img = display.newSprite("#UIBar_Wanted.png")
                        :align(display.CENTER, itemSize.width/2, itemSize.height/2+offsetY)
                        :addTo(root)
        local imgSize = img:getContentSize()

        if nil~=monsterInfo then
            tmpStr = string.format("monster/monster_%d.png", monsterInfo.resId)
            fScale = 1.3
        else
            tmpStr = "#UIBar_QuestionMark.png"
            fScale = 1
        end
        local head = display.newSprite(tmpStr)
                        :scale(fScale)
                        :align(display.CENTER, imgSize.width/2, imgSize.height/2+30)
                        :addTo(img)

        if 1==nTag then
            local btn = cc.ui.UIPushButton.new({normal="common/blueBt1.png", pressed="common/blueBt2.png"})
                            :setButtonLabel(cc.ui.UILabel.new({text = "提交", size = 26, color = cc.c3b(0, 77, 52)}))
                            :align(display.CENTER, itemSize.width/2, 50)
                            :addTo(root,0,1011)
                            :onButtonClicked(function(event)
                                BarMgr:ReqSubmitTask(tabList[i][3])
                                startLoading()
                                GuideManager:removeGuideLayer()
                            end)
        elseif 2==nTag then
            local stamp = display.newSprite("#UIBar_Arrest.png")
                            :align(display.CENTER, imgSize.width/2, imgSize.height/2+30)
                            :addTo(img)
        end

        if nil~=monsterInfo then
            tmpStr = monsterInfo.name
        else
            tmpStr = ""
        end
        local labName = display.newTTFLabel({text = tmpStr, size = 20, color = cc.c3b(0,255,0)})
                        :align(display.CENTER, imgSize.width/2, imgSize.height/2-45)
                        :addTo(img)
        local labReward = display.newTTFLabel({
                                text = "显示方式待定",
                                size = 20,
                                color = cc.c3b(255, 0, 0), -- 使用纯红色
                                align = cc.TEXT_ALIGNMENT_LEFT,
                                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                                -- dimensions = cc.size(180, 50)
                            })
                            :align(display.CENTER, imgSize.width/2, imgSize.height/2-85)
                            :addTo(img)
    end
    if #self.t_data>0 then
        self.bountyView:fill(self.t_data, {itemSize = itemSize})
        S_XY(self.bountyView:getScrollNode(),50,50+self.bountyView:getViewRect().height-H(self.bountyView:getScrollNode()))
    end
end

--初始化赏金首列表数据(0:不可领取 1:可领取 2:已领取 3:头像不可见且不可领取)
function BarScene:InitBountyList()
    if nil==BarMgr.BarInfo or nil==BarMgr.bountyList then
        return
    end
    self.unFinished = {}
    self.finished = {}

    local val
    for i=1, #BarMgr.bountyList do
        local k = i+10000
        if k<=BarMgr.BarInfo.styArId or k<=srv_userInfo.areaId then      --已开启章节
            if nil==BarMgr.BarInfo.btyRed[k] then
                val = 0
            else
                val = BarMgr.BarInfo.btyRed[k]
            end

            if 2==val then
                table.insert(self.finished, {BarMgr.bountyList[i][1], val, k})
            else
                table.insert(self.unFinished, {BarMgr.bountyList[i][1], val, k})
            end
        else                                                            --未开启章节
            val = 3
            table.insert(self.unFinished, {BarMgr.bountyList[i][1], val, k})
        end
    end
end

--加载剧情回顾界面
function BarScene:LoadStoryUI()
    if nil~=self.panelStory then
        return
    end

    local rootNode = cc.uiloader:load("Image/UIBar/Story.ExportJson")
                        :addTo(self, 99)
    self.panelStory = cc.uiloader:seekNodeByName(rootNode, "Image_Bg")

    --剧情类型按钮
    self.btnStoryType = {}  --主线、支线、其它
    local function BtnTypeOnClick(event)
        local nTag = event.target:getTag()
        self:ChooseStoryTab(nTag)
    end

    self.btnStoryType[1] = cc.uiloader:seekNodeByName(self.panelStory, "Button_Main")
    self.btnStoryType[2] = cc.uiloader:seekNodeByName(self.panelStory, "Button_Sub")
    self.btnStoryType[3] = cc.uiloader:seekNodeByName(self.panelStory, "Button_Other")
    for i=1, #self.btnStoryType do
        self.btnStoryType[i]:setTag(i)
        self.btnStoryType[i]:onButtonClicked(BtnTypeOnClick)
    end

    --剧情回顾按钮、剧情名称、剧情简介
    local tmpNode = cc.uiloader:seekNodeByName(self.panelStory, "Image_Intro")
    self.btnStoryReview = cc.uiloader:seekNodeByName(tmpNode, "Button_Review")
                            :onButtonClicked(function(event)
                                if nil==self.nCurSelItemIndex or nil==self.storyList[self.nCurSelItemIndex] then
                                    return
                                end

                                self.masklayer:setVisible(false)
                                self.panelStory:setVisible(false)
                                self.dialog:TriggerDialog(self.storyList[self.nCurSelItemIndex], DialogType.BarPlot)
                            end)
    self.labStoryName = cc.uiloader:seekNodeByName(tmpNode, "Label_Name")
    self.labStoryIntro = cc.uiloader:seekNodeByName(tmpNode, "Label_Intro")

    --剧情列表
    tmpNode = cc.uiloader:seekNodeByName(self.panelStory, "Image_List")
    self.storyView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(22, 29, 240, 370),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(tmpNode)
    
    self.masklayer:addHinder(self.panelStory)
    self.panelStory:setVisible(false)
end

--选择剧情标签
function BarScene:ChooseStoryTab(nTag)
    for i=1, #self.btnStoryType do
        self.curSelStoryTab = nTag
        if i==nTag then
            self.btnStoryType[i]:setButtonEnabled(false)
        else
            self.btnStoryType[i]:setButtonEnabled(true)
        end
    end

    if 1==nTag then
        self.btnStoryReview:setVisible(true)
    else
        self.btnStoryReview:setVisible(false)
    end

    self:InitStoryList(nTag)
    self:InitStoryView()
end

--选择剧情item
--@nIndex(-1：选择最后一条)
--注：在ChooseStoryTab()之后调用
function BarScene:ChooseStoryItem(nIndex)
    if nil==nIndex then
        return
    end
    if -1==nIndex then
        nIndex = #self.storyItem
    end

    for i=1, #self.storyItem do
        if i==nIndex then
            self.storyItem[i].btn:setButtonEnabled(false)
            self.storyItem[i].bg:setVisible(true)
        else
            self.storyItem[i].btn:setButtonEnabled(true)
            self.storyItem[i].bg:setVisible(false)
        end
    end
    self.nCurSelItemIndex = nIndex
    self:InitStoryDesc(self.curSelStoryTab, nIndex)
end

--初始化剧情列表数据
function BarScene:InitStoryList(nType)
    self.storyList = {}
    if 1==nType then
        local nTotal = 5--BarMgr.BarInfo.styArId-10000
        local nID
        for i=1, nTotal do
            nID = (10000+i)*1000+201
            table.insert(self.storyList, nID)
        end
    elseif 2==nType then
        --todo
    elseif 3==nType then
        --todo
    end
end

--初始化剧情列表控件
function BarScene:InitStoryView()
    if nil==self.storyView or nil==self.storyList then
        return
    end
    self.storyView:removeAllItems()
    self.storyItem = {}

    for i=1, #self.storyList do
        local item = self.storyView:newItem()
        local content = cc.Node:create()

        self.storyItem[i] = {}
        self.storyItem[i].bg = display.newSprite("#UIBar_ChapterBtnBg.png")
                                :addTo(content, 0)
        self.storyItem[i].bg:setVisible(false)
        self.storyItem[i].btn = cc.ui.UIPushButton.new({normal="#UIBar_ChapterBtn1.png", pressed="#UIBar_ChapterBtn2.png", disabled="#UIBar_ChapterBtn2.png"})
                                :setButtonLabel(cc.ui.UILabel.new({text = mainPlotData[i+10000].title, size = 26}))
                                :addTo(content, 1, i)
                                :onButtonClicked(function(event)
                                    self:ChooseStoryItem(i)
                                end)
        self.storyItem[i].btn:setTouchSwallowEnabled(false)

        item:addContent(content)
        item:setItemSize(240, 70)
        self.storyView:addItem(item)
    end

    self.storyView:reload()
end

--初始化剧情描述
function BarScene:InitStoryDesc(nType, nIndex)
    if nil==nType or nil==nIndex then
        self.labStoryName:setString("")
        self.labStoryIntro:setString("")
        return
    end

    if 1==nType then
        self.labStoryName:setString(mainPlotData[nIndex+10000].name)
        self.labStoryIntro:setString(mainPlotData[nIndex+10000].des)
    elseif 2==nType then
    elseif 3==nType then
    end
end

--
function BarScene:onTouchEndedEvent()
    if nil~=self.panelBounty then
        if self.panelBounty:isVisible() then
            self.panelBounty:setVisible(false)
            print("点击背景区域")
        end
        self.panelStory:setVisible(false)
    end
end

return BarScene