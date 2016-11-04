--
-- Author: Jun Jiang
-- Date: 2014-12-22 15:39:59
--
UIDialog = class("UIDialog",function()
    return display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 50))
end)
local nSex = 1

DialogType =
{
    BarPlot         = 1,    --酒吧剧情
    FightPlot       = 2,    --战斗剧情
    RegisterPlot    = 3,    --注册剧情
    mainGuidePlot   = 4,    --主线任务引导剧情
    zhixianPlot     = 5,    --支线任务
}

function UIDialog:ctor()
    --性别
    nSex = GlobalGetRoleSex()
    --当前对话ID
    self.nCurDialogID = nil
    --当前对话类型
    self.nCurType = nil
    --当前对话表格
    self.nCurDialogTab = nil
    --动画结束
    self.bAniFinished = true
    --触摸开关
    self.bEnableTouch = true
    --对话结束回调
    self.FinishCallback = nil
    --每段对话回调
    self.PerConversationCallback = nil

    self.hasCallTheFunc = false

    --事件
    S_SIZE(self,display.width,display.height)
    self:setTouchEnabled(true)
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

    local tmpSize = nil
    --对话框
    self.dialogBox = display.newScale9Sprite("common2/com2_Img_5.png",nil,nil,cc.size(1280,210),cc.rect(9,9,30,30))
                        :align(display.CENTER_BOTTOM, display.cx, 0)
                        :addTo(self)
                        :opacity(200)

    self.dialogBox:setColor(cc.c3b(0,0,0))
    --头像
    tmpSize = self.dialogBox:getContentSize()
    self.imgHead = display.newSprite()
                        :align(display.CENTER_BOTTOM, 165, 0)
                        :addTo(self.dialogBox)


    -- --名字背景
    -- local nameBg = display.newSprite("Bust/namebg.png")
    --                     :align(display.CENTER, 165, tmpSize.height)
    --                     :addTo(self.dialogBox)
    -- tmpSize = nameBg:getContentSize()

    --名字
    self.labName = display.newTTFLabel({text = "", size = 30, color = cc.c3b(237,186,95)})
                        :align(display.LEFT_BOTTOM, 100, 125)
                        :addTo(self)

    --文本框
    self.labDialog = display.newTTFLabel({
        text = "",
        size = 26,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        color = cc.c3b(190, 210, 211), 
        dimensions = cc.size(850, 0)
        })
        :align(display.LEFT_TOP, 100, 120)  --对齐方式与 FilpDialogBox(nTag) 相关联，勿随意更改
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


    self.g_btn = cc.ui.UIPushButton.new({normal = "common/guideJumpBtn.png"})
                            :align(display.LEFT_CENTER, display.cx+400, display.height-110)
                            :addTo(self)
                            :onButtonClicked(function (event)
                                print("跳过")
                                local npcs,hasNpc = self:getDialogpramas()
                                for k,v in pairs(npcs) do
                                    print("------------------------------------11111")
                                    self:callTheFunction({param1=v})
                                end
                                if not hasNpc then
                                    self.nCurDialogID = nil
                                    self.nCurType = nil
                                    self.labDialog:setString("")
                                    self.labName:setString("")
                                    self.bEnableTouch = true
                                    print("-----------=======-------112134")
                                    self:setVisible(false)
                                    if self.FinishCallback~=nil then
                                        self.FinishCallback()
                                    end
                                else
                                    print("跳过按钮回调，")
                                    self:setVisible(false)
                                    --延时是为了解决助战NPC控制台不冷却问题，原因不知道   
                                    if self.FinishCallback~=nil then
                                        -- self:performWithDelay(function () 
                                            self.FinishCallback()
                                            print("等待0.1秒后触发")
                                        -- end,0.01)
                                    end
                                end
                                
                                return
                            end)
    local g_sequence = transition.sequence({
            cc.FadeTo:create(1,50),
            cc.FadeTo:create(1,255),
        })
  self.g_btn:runAction(cc.RepeatForever:create(g_sequence))
    -- display.newSprite("common/text_jump.png")
    --     :addTo(self)
    --     :align(display.LEFT_CENTER, display.cx+500, display.height-110+2)
end

--翻转对话框及相关控件(1:正 -1:反)
function UIDialog:FilpDialogBox(nTag)
    if 1==nTag then
        self.labDialog:setPositionX(300)
        self.labName:setPositionX(300)
        self.arrow:setPositionX(display.cx+475)
    elseif -1==nTag then
        self.labDialog:setPositionX(100)
        self.labName:setPositionX(100)
        self.arrow:setPositionX(display.cx-475)
    else
        return
    end

    self.dialogBox:setScaleX(nTag)
end

function UIDialog:onTouchBegan(point)
    print("UIDialog:onTouchBegan(point)")
    return self.bEnableTouch
end

function UIDialog:onTouchMoved(point)
end

function UIDialog:onTouchEnded(point)
    print("onTouchEnded(point)")
    if nil==self.nCurDialogID then
        return
    end

    if self.bAniFinished then
        self.nCurDialogID = self.nCurDialogID+1
        self:_ShowCurDialog(true)
    else
        self:_ShowCurDialog(false)
    end
end

--设置对话结束回调
function UIDialog:SetFinishCallback(func)
    if nil==func then
        return
    end

    self.FinishCallback = func
end

--设置每段对话结束回调
function UIDialog:SetPerConversationCallback(func)
    if nil==func then
        return
    end

    self.PerConversationCallback = func
end

--设置触摸开关
function UIDialog:SetTouchState(bEnabled)
    if nil==bEnabled then
        print("UIDialog:SetTouchState - nil param")
        return
    end
    self.bEnableTouch = bEnabled
end

--触发对话
function UIDialog:TriggerDialog(nDialogID, nType)
    print("TriggerDialog  .dialodId: "..nDialogID)
	self.nCurDialogID = nDialogID
    self.nCurType = nType

    local npcs,hasNpc = self:getDialogpramas()
    if hasNpc then
        self.g_btn:hide()
    end
    self:setVisible(true)
    self:_ShowCurDialog(true)
end

--显示当前对话
function UIDialog:_ShowCurDialog(bAni)
    if DialogType.BarPlot==self.nCurType then
        self.nCurDialogTab = barPlotData[self.nCurDialogID]
    elseif DialogType.FightPlot==self.nCurType then
        self.nCurDialogTab = fightPlotData[self.nCurDialogID]
    elseif DialogType.RegisterPlot==self.nCurType then
        self.nCurDialogTab = regTalkData[self.nCurDialogID]
    elseif DialogType.mainGuidePlot==self.nCurType then
        self.nCurDialogTab = mainLineTalkData[self.nCurDialogID]
    elseif DialogType.zhixianPlot==self.nCurType then
        self.nCurDialogTab = zhixianTalkData[self.nCurDialogID]
    else
        self.nCurDialogTab = nil
    end
    print("self.nCurDialogID :  "..self.nCurDialogID)
    if nil==self.nCurDialogTab then
        print("talkTab is nil")
        self.nCurDialogID = nil
        self.nCurType = nil
        self:setVisible(false)
        self.labDialog:setString("")
        self.labName:setString("")
        self.bEnableTouch = true

        if self.FinishCallback~=nil then
            self.FinishCallback()
        end
        
        return
    end

    --翻转、名字、头像设置
    if 0==self.nCurDialogTab.headPos then
        self:FilpDialogBox(1)
    else
        self:FilpDialogBox(-1)
    end

    --创建角色前的对话使用
    if srv_userInfo.templateId==nil then
        srv_userInfo.templateId = 10121
        srv_userInfo.name = "无知少年"
    end

    local headPath
    if self.nCurDialogTab.headId>=10121 and self.nCurDialogTab.headId<=10265 then   --主角半身像，分套装
        self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.templateId].resId..string.sub(self.nCurDialogTab.headId,5,5))
    elseif self.nCurDialogTab.headId>=10331 and self.nCurDialogTab.headId<=10365 then   --黄小海半身像，分套装
        if srv_userInfo.memTmpId1==0 then
            srv_userInfo.memTmpId1 = 10331
        end
        self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.memTmpId1].resId..string.sub(self.nCurDialogTab.headId,5,5))
    elseif self.nCurDialogTab.headId>=10431 and self.nCurDialogTab.headId<=10465 then   --夏晓萌半身像，分套装
        if srv_userInfo.memTmpId2==0 then
            srv_userInfo.memTmpId2 = 10431
        end
        self.nCurDialogTab.headId = tonumber(memberData[srv_userInfo.memTmpId2].resId..string.sub(self.nCurDialogTab.headId,5,5))
    end
    headPath = string.format("Bust/bust_%d.png", self.nCurDialogTab.headId)
    self.imgHead:setTexture(headPath)
    if "主角"==self.nCurDialogTab.name then   --用实际主角名
        self.labName:setString(srv_userInfo.name)
    else
        if "null"==self.nCurDialogTab.name then
            self.labName:setString("")
        else
            self.labName:setString(self.nCurDialogTab.name)
        end
    end

    --内容显示
    self:stopAllActions()
    if bAni then
        local bytes = GlobalGetWordsBytes(self.nCurDialogTab.des)
        local nCurBytes = 0
        local nWords = #bytes
        local nIndex = 0
        local subStr = ""
        local function Callback(pSender)
            nIndex = nIndex+1
            nCurBytes = nCurBytes+bytes[nIndex]
            subStr = string.sub(self.nCurDialogTab.des, 1, nCurBytes)
            self.labDialog:setString(subStr)

            if nIndex>=nWords then
                self:stopAllActions()
                self.bAniFinished = true
                if nil~=self.nCurDialogTab.param1 and self.nCurDialogTab.param1>0 then
                    self.bEnableTouch = false
                else
                    self.bEnableTouch = true
                end
                print("------------------------------------22222")
                self:callTheFunction({param1=self.nCurDialogTab.param1})
            end
        end

        local ani1 = cc.CallFunc:create(Callback)
        local ani2 = cc.DelayTime:create(0.1)
        local fin = cc.RepeatForever:create(cc.Sequence:create(ani1, ani2))
        self:runAction(fin)
        self.bAniFinished = false
    else
        self.labDialog:setString(self.nCurDialogTab.des)
        self.bAniFinished = true
        if nil~=self.nCurDialogTab.param1 and self.nCurDialogTab.param1>0 then
            self.bEnableTouch = false
        else
            self.bEnableTouch = true
        end
        print("------------------------------------33333")
        self:callTheFunction({param1=self.nCurDialogTab.param1})
    end
end

--获取此段对话中，后续是否有NPC入战的情况，如果有，返回table
function UIDialog:getDialogpramas()
    local curDialogId = self.nCurDialogID
    local npcs = {}
    local hasNpc = false
    local g_id = curDialogId
    local g_nCurDialogTab = nil
    if DialogType.FightPlot==self.nCurType then
        g_nCurDialogTab = fightPlotData[g_id]
    else
        g_nCurDialogTab = nil
    end
    while g_nCurDialogTab~=nil do
        print("g_id:  "..g_id)
        if DialogType.FightPlot==self.nCurType then
            g_nCurDialogTab = fightPlotData[g_id]
        else
            g_nCurDialogTab = nil
        end

        if g_nCurDialogTab~=nil and g_nCurDialogTab.param1~=0 then
            table.insert(npcs,g_nCurDialogTab.param1)
            hasNpc = true
            print("hasNpc = true    , npcId: "..g_nCurDialogTab.param1)
        end
        g_id = g_id+1
    end
    return npcs,hasNpc
end

function UIDialog:callTheFunction(tab)
    print("调用了回调 self.hasCallTheFunc：")
    print(self.hasCallTheFunc)
    printTable(tab) --tab.param1==0
    if self.PerConversationCallback~=nil and tab.param1~=nil and tab.param1~=0 then
        if not self.hasCallTheFunc then
            self.PerConversationCallback(tab)
            self.hasCallTheFunc = true
        end   
    end
    
end