--
-- Author: Jun Jiang
-- Date: 2015-03-12 19:38:16
--
UISceneDlg = class("UISceneDlg",function()
    return display.newLayer()
end)
local nSex = 1

--解析"|"分割的字符串
local function Parse1(str, type)
    local tabRet = string.split(str, "|")
    if type=="number" then
        for i=1, #tabRet do
            tabRet[i] = tonumber(tabRet[i])
        end
    end

    return tabRet
end

--解析"|"(一级)和"#"(二级)分割的字符串
local function Parse2(str, type)
    local tabRet = string.split(str, "|")

    for i=1, #tabRet do
        local arr = string.split(tabRet[i], "#")

        if type=="number" then
            for j=1, #arr do
                arr[j] = tonumber(arr[j])
            end
        end

        tabRet[i] = arr
    end

    return tabRet
end

function UISceneDlg:ctor(params)
	if nil==params then
		params = {}
	end

    --性别
    nSex = GlobalGetRoleSex()

	--当前对话表格
    self.nCurDialogTab = nil
    --准许触摸
    self.bEnableTouch = false
    --对话结束回调
    self.FinishCallback = function( ... )
        print("Talking Finished!")
    end
    --模型
    self.models = nil	--{nTemplateID, nType, pModel}

	--设置层属性
    S_SIZE(self,display.width,display.height)
    self:setTouchSwallowEnabled(true)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            return self:onTouchBegan(cc.p(event.x,event.y))
        elseif event.name == "moved" then
            self:onTouchMoved(cc.p(event.x,event.y))
        elseif event.name == "ended" then
            self:onTouchEnded(cc.p(event.x,event.y))
        end

    end)

    --背景
    self.sprBg = display.newSprite()
                    :align(display.CENTER, display.cx, display.cy)
                    :addTo(self)

    local tmpSize = nil
    --对话框
    self.dialogBox = display.newSprite("Bust/dialogbox.png")
                        :align(display.CENTER_BOTTOM, display.cx, 0)
                        :addTo(self)

    --头像
    tmpSize = self.dialogBox:getContentSize()
    self.imgHead = display.newSprite()
                        :align(display.CENTER_BOTTOM, 165, tmpSize.height)
                        :addTo(self.dialogBox)

    --名字背景
    local nameBg = display.newSprite("Bust/namebg.png")
                        :align(display.CENTER, 165, tmpSize.height)
                        :addTo(self.dialogBox)
    tmpSize = nameBg:getContentSize()

    --名字
    self.labName = display.newTTFLabel({text = "", size = 26, color = cc.c3b(95,255,250)})
                        :align(display.CENTER, tmpSize.width/2-20, tmpSize.height/2)
                        :addTo(nameBg)

    --文本框
    self.labDialog = display.newTTFLabel({
        text = "",
        size = 26,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        color = cc.c3b(201, 188, 156), 
        dimensions = cc.size(924, 0)
        })
        :align(display.LEFT_TOP, display.cx-495, 120)  --对齐方式与 FilpDialogBox(nTag) 相关联，勿随意更改
        :addTo(self)

    --下句话箭头
    self.arrow = display.newSprite("Bust/arrow.png")
                    :align(display.CENTER, display.cx+475, 50)
                    :addTo(self)
    local seq = transition.sequence({
        cc.MoveBy:create(0.3, cc.p(0, -20)),
        cc.MoveBy:create(0.3, cc.p(0, 20)),
        })
    transition.execute(self.arrow, cc.RepeatForever:create(seq))

    --隐藏
    self:setVisible(false)
end

--翻转对话框及相关控件(1:正 -1:反)
function UISceneDlg:FilpDialogBox(nTag)
    if 1==nTag then
    elseif -1==nTag then
    else
        return
    end

    self.dialogBox:setScaleX(nTag)
    self.labName:setScaleX(nTag)
end

function UISceneDlg:onTouchBegan(point)
	return self.bEnableTouch
end

function UISceneDlg:onTouchMoved(point)
end

function UISceneDlg:onTouchEnded(point)
    if nil==self.nCurDialogID then
        return
    end

    self.nCurDialogID = self.nCurDialogID+1
    self:_ShowCurDialog()
end

--设置对话结束回调
function UISceneDlg:SetFinishCallback(func)
    if nil==func then
        return
    end

    self.FinishCallback = func
end

--触发对话
function UISceneDlg:TriggerDialog(nDialogID)
	self.nCurDialogID = nDialogID
    self.bFirst = true  --触发第一条配置
    self:setVisible(true)

    self:_ShowCurDialog()
end

--生成模型
function UISceneDlg:CreateModels()
    --清空上次的模型
    self:ClearModels()

    local tabTplID = Parse1(self.nCurDialogTab.unit, "number")
    local tabType = Parse1(self.nCurDialogTab.unitType, "number")
    local tabPos = Parse2(self.nCurDialogTab.unitPos, "number")
    local tabFace = Parse1(self.nCurDialogTab.unitFace, "number")

    --模型动作回调
    local function AnimationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            if "Standby"~=movementID and "walk"~=movementID then
                local animation = armatureBack:getAnimation()
                animation:play("Standby")
                animation:gotoAndPlay(0)
                self.nRunningActions = self.nRunningActions-1
                self:CheckMovementStep()
            end
        end
    end

    --初始化本次模型
    self.models = {}
    local loc_MemData = nil
    for i=1, #tabTplID do
        self.models[i] = {}
        self.models[i].nTemplateID = tabTplID[i]
        loc_MemData = memberData[tabTplID[i]]
        if nil~=loc_MemData and "主角"==loc_MemData.name then   --主角模型，区分男女
            if 2==nSex then
                self.models[i].nTemplateID = self.models[i].nTemplateID+100
            end
        end
        self.models[i].nType = tabType[i]
        self.models[i].pModel = GlobalCreateModel(self.models[i].nType, self.models[i].nTemplateID)

        self.models[i].pModel:addTo(self)
        local nFace = tabFace[i]
        SetModelParams(self.models[i].pModel, {nFace=nFace})
        self.models[i].pModel:setPosition(tabPos[i][2]*display.width, tabPos[i][3]*display.height)
        local animation = self.models[i].pModel:getAnimation()
        animation:setMovementEventCallFunc(AnimationEvent)
        animation:play("Standby")
        animation:gotoAndPlay(0)
    end
end

--清理模型
function UISceneDlg:ClearModels()
    if nil~=self.models then
        for i=1, #self.models do
            if nil~=self.models[i].pModel then
                self.models[i].pModel:removeFromParent()
            end
        end
        self.models = nil
    end
end

--检测当前步骤是否完成，完成执行下一步
function UISceneDlg:CheckMovementStep()
    if self.nRunningActions<=0 then
        self.nRunningActions = 0
        self.nCurDialogID = self.nCurDialogID+1
        self:_ShowCurDialog()
    end
end

--模型动画处理
function UISceneDlg:_HandlerCurMovement()
    if "null"~=self.nCurDialogTab.des then
        return
    end

    --无单位执行动作
    if "null"==self.nCurDialogTab.unit then
        return
    end
    self.nRunningActions = 0   --进行中动画
    local tabIndex = Parse1(self.nCurDialogTab.unit, "number")

    --动作回调(MoveTo一类)
    local function Callback(pSender)
        self.nRunningActions = self.nRunningActions-1
        pSender:stopAllActions()
        local animation = pSender:getAnimation()
        animation:play("Standby")
        animation:gotoAndPlay(0)
        self:CheckMovementStep()
    end

    --位置设定或移动
    if "null"~=self.nCurDialogTab.unitPos then
        local tabPos = Parse2(self.nCurDialogTab.unitPos, "number")
        for i=1, #tabPos do
            if tabPos[i][1]==0 then
                self.models[tabIndex[i]].pModel:setPosition(tabPos[i][2]*display.width, tabPos[i][3]*display.height)
            else    --移动动画
                local sequence = transition.sequence({
                        cc.MoveTo:create(tabPos[i][1], cc.p(tabPos[i][2]*display.width, tabPos[i][3]*display.height)),
                        cc.CallFunc:create(Callback)
                    })
                self.models[tabIndex[i]].pModel:runAction(sequence)
                local animation = self.models[tabIndex[i]].pModel:getAnimation()
                animation:play("walk")
                animation:gotoAndPlay(0)
                self.nRunningActions = self.nRunningActions+1
            end
        end
    end

    --朝向设定
    if "null"~=self.nCurDialogTab.unitFace then
        local tabFace = Parse1(self.nCurDialogTab.unitFace, "number")
        for i=1, #tabFace do
            SetModelParams(self.models[tabIndex[i]].pModel, {nFace=tabFace[i]})
        end
    end

    --动作执行
    if "null"~=self.nCurDialogTab.unitMovement then
        for i=1, #tabIndex do
            local animation = self.models[tabIndex[i]].pModel:getAnimation()
            animation:play(self.nCurDialogTab.unitMovement)
            animation:gotoAndPlay(0)
            self.nRunningActions = self.nRunningActions+1
        end
    end

    self:CheckMovementStep()
end

--显示当前对话
function UISceneDlg:_ShowCurDialog()
    self.nCurDialogTab = scenePlotData[self.nCurDialogID]
    if nil==self.nCurDialogTab then
        self.nCurDialogID = nil
        self:setVisible(false)
        self.labDialog:setString("")
        self.labName:setString("")
        self.FinishCallback()
        self:ClearModels()
        return
    end

    local tmpPath
    --背景
    if "null"~=self.nCurDialogTab.bgId then
        tmpPath = string.format("Battle/BattleBg/scene_bg_%d.jpg", self.nCurDialogTab.bgId)
        self.sprBg:setTexture(tmpPath)
    end

    --翻转、名字、头像设置
    if 0==self.nCurDialogTab.headPos then
        self:FilpDialogBox(1)
    elseif 1==self.nCurDialogTab.headPos then
        self:FilpDialogBox(-1)
    end

    if "null"~=self.nCurDialogTab.headId then
        if self.nCurDialogTab.headId>=10121 and self.nCurDialogTab.headId<=10265 then   --主角半身像，分套装
            self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.templateId].resId..string.sub(self.nCurDialogTab.headId,5,5))
        elseif self.nCurDialogTab.headId>=10331 and self.nCurDialogTab.headId<=10365 then   --黄小海半身像，分套装
            self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.memTmpId1].resId..string.sub(self.nCurDialogTab.headId,5,5))
        elseif self.nCurDialogTab.headId>=10431 and self.nCurDialogTab.headId<=10465 then   --夏晓萌半身像，分套装
            self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.memTmpId2].resId..string.sub(self.nCurDialogTab.headId,5,5))
        end
        tmpPath = string.format("Bust/bust_%d.png", self.nCurDialogTab.headId)
        -- if self.nCurDialogTab.headId>=10001 and self.nCurDialogTab.headId<=10009 then   --主角半身像，分男女
        --     if 2==nSex then
        --         tmpPath = string.format("Bust/bust_%d.png", self.nCurDialogTab.headId+10)
        --     else
        --         tmpPath = string.format("Bust/bust_%d.png", self.nCurDialogTab.headId)
        --     end
        -- else
        --     tmpPath = string.format("Bust/bust_%d.png", self.nCurDialogTab.headId)
        -- end
	    self.imgHead:setTexture(tmpPath)
        if "主角"==self.nCurDialogTab.name then   --用实际主角名
            self.labName:setString(srv_userInfo.name)
        else
            self.labName:setString(self.nCurDialogTab.name)
        end
	end

    --内容显示
    if "null"~=self.nCurDialogTab.des then
	    self.labDialog:setString(self.nCurDialogTab.des)
	    self.bEnableTouch = true
	    self.dialogBox:setVisible(true)
        self.labDialog:setVisible(true)
        self.arrow:setVisible(true)
	else
		self.bEnableTouch = false
		self.dialogBox:setVisible(false)
        self.labDialog:setVisible(false)
        self.arrow:setVisible(false)
	end

	--动画处理
    if self.bFirst then
        self:CreateModels()
        self.bFirst = false
        self.nCurDialogID = self.nCurDialogID+1
        self:_ShowCurDialog()
    else
        self:_HandlerCurMovement()
    end
end