-- @Author: anchen
-- @Date:   2015-08-26 14:36:00
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-15 18:22:04
--开服活动
oneWeekReward = class("oneWeekReward",function()
    -- local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

oneWeekReward.Instance = nil
function oneWeekReward:ctor()
    local colorBg = display.newSprite("common/colorbg.png")
    :addTo(self,-1)
    colorBg:setAnchorPoint(0,0)
    colorBg:setScaleX(display.width/colorBg:getContentSize().width)
    colorBg:setScaleY(display.height/colorBg:getContentSize().height) 

    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
    :addTo(self)
    :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiTag_05.png")
        :addTo(bg)
        :align(display.LEFT_CENTER,50, bgSize.height-90)

    display.newSprite("youhui/youhuiImg_10.png")
        :addTo(bg)
        :pos(bgSize.width/2-100,bgSize.height-100)

    display.newSprite("youhui/youhuiImg_08.png")
        :addTo(bg)
        :pos(bgSize.width/2, bgSize.height-150)

    local str = ""
    self.tipLabel = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(bg)
        :align(display.LEFT_BOTTOM,60,bgSize.height-200)
    -- self:refreshActivityTime()
    --关闭按钮
    self.closeBtn = cc.ui.UIPushButton.new({
        normal="common/common_BackBtn_1.png",
        pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height )
        :addTo(self)
        :onButtonClicked(function(event)
            self:removeSelf()
        end)
    -- cc.ui.UIPushButton.new({
    --     normal = "common/common_CloseBtn_1.png",
    --     pressed = "common/common_CloseBtn_2.png"
    --     })
    -- :addTo(bg)
    -- :pos(bgSize.width-10,bgSize.height-20)
    -- :onButtonClicked(function(event)
    --     self:removeSelf()
    --     end)

    display.newSprite("youhui/youhuiTag_08.png")
        :addTo(bg)
        :pos(bgSize.width-160,bgSize.height-80)
        :scale(0.9)

    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(40, 30, 840, 430),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(bg)
    self:reloadListView()
end
function oneWeekReward:onEnter()
    oneWeekReward.Instance = self
end
function oneWeekReward:onExit()
    oneWeekReward.Instance = nil
end
--获取本地任务表中的开服登录奖励部分
function oneWeekReward:getOneWeekTask()
    local oneweekData = {}
    for i,value in pairs(taskData) do
        if value.type==9 then
            table.insert(oneweekData, value)
        end
    end
    function sortfunc(a,b)
        if a.id<b.id then
            return true
        else
            return false
        end
    end
    table.sort(oneweekData, sortfunc)

    return oneweekData
end
--获取服务端任务数据中的开服登录奖励部分
function oneWeekReward:getSrvOneWeekTask()
    local srvOneweekData = {}
    local minTaskTmpId = 0
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==9 then
            srvOneweekData[value.tptId] = value
            if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                minTaskTmpId = value.tptId
            end
        end
    end
    return srvOneweekData,minTaskTmpId
end
function oneWeekReward:reloadListView()
    self:performWithDelay(function ()
    self.lv:removeAllItems()

    local oneweekData = self:getOneWeekTask()
    self.oneweekData = oneweekData
    local srvOneweekData,minTaskTmpId = self:getSrvOneWeekTask()
    -- print(minTaskTmpId)
    for i=1,#oneweekData do
        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(840, 130)
        self.lv:addItem(item)

        local bar = display.newSprite("firstRecharge/rewardBar.png")
        :addTo(content)

        local dayImg = display.newSprite("firstRecharge/dayImg.png")
        :addTo(bar)
        :pos(80, bar:getContentSize().height/2)

        display.newSprite("firstRecharge/num"..i..".png")
        :addTo(dayImg)
        :pos(dayImg:getContentSize().width/2, dayImg:getContentSize().height/2)

        local idx = 0
        if oneweekData[i].diamond>0 then
            idx = idx + 1
            local icon = GlobalGetSpecialItemIcon(2, oneweekData[i].diamond, 1.05)
                :addTo(bar)
                icon:setPosition(220+120*(idx-1),bar:getContentSize().height/2)
        end
        if oneweekData[i].energy>0 then
            idx = idx + 1
            local icon = GlobalGetSpecialItemIcon(4, oneweekData[i].energy, 1.05)
                :addTo(bar)
                icon:setPosition(220+120*(idx-1),bar:getContentSize().height/2)
        end
        if oneweekData[i].rewardItems~="null" then
            local rewards = lua_string_split(oneweekData[i].rewardItems, "|")
            for i=1,#rewards do
                idx = idx + 1
                local rewardItem = lua_string_split(rewards[i],"#")
                local icon = createItemIcon(rewardItem[1],rewardItem[2],true,true)
                :addTo(bar)
                icon:setScale(0.9)
                icon:setPosition(220+120*(idx-1),bar:getContentSize().height/2)
            end
        end
        

        --签到按钮
        local srv_taskData = srvOneweekData[oneweekData[i].id]
        local receiveBt = cc.ui.UIPushButton.new({normal = "firstRecharge/receiveBt1.png"})
        :addTo(bar)
        :pos(bar:getContentSize().width - 120, bar:getContentSize().height/2)
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function(event)
            self.idx = i
            self.curTaskTptId = srv_taskData.tptId
            startLoading()
            TaskMgr:ReqSubmit(srv_taskData.id)

            end)
        if srv_taskData then
            print("有任务，",oneweekData[i].id,srv_taskData.status)
            if srv_taskData.status==0 then --未完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
                receiveBt:setTouchEnabled(false)
            elseif srv_taskData.status==1 then --已完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
                receiveBt:setTouchEnabled(true)
            elseif srv_taskData.status==2 then --已领取
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
                receiveBt:setTouchEnabled(false)
            end
        else
            print("没任务，",minTaskTmpId,oneweekData[i].id)
            if minTaskTmpId==0 or (oneweekData[i].id)<minTaskTmpId then --已领取
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
                receiveBt:setTouchEnabled(false)
            else  --未完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
                receiveBt:setTouchEnabled(false)
            end
            
        end

    end
    self.lv:reload()
    end,0.01)
end

--领取任务
function oneWeekReward:OnSubmitRet(cmd)
    endLoading()
    if cmd.result==1 then
        self:reloadListView()

        --奖励弹框
        local curRewards = {}
        if self.oneweekData[self.idx].diamond>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=self.oneweekData[self.idx].diamond})
            srv_userInfo.diamond = srv_userInfo.diamond + self.oneweekData[self.idx].diamond
            mainscenetopbar:setDiamond()
        end
        if self.oneweekData[self.idx].energy>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_STRENGTH, num=self.oneweekData[self.idx].energy})
            srv_userInfo.energy = srv_userInfo.energy + self.oneweekData[self.idx].energy
            mainscenetopbar:setEnergy()
        end
        if self.oneweekData[self.idx].rewardItems~="null" then
            local rewards = lua_string_split(self.oneweekData[self.idx].rewardItems, "|")
            for i=1,#rewards do
                local rewardItem = lua_string_split(rewards[i],"#")
                table.insert(curRewards, {templateID=tonumber(rewardItem[1]), num=tonumber(rewardItem[2])})
            end
        end
        
        GlobalShowGainBox(nil, curRewards)

        if self.curTaskTptId==109400007 then --七天礼最后一天领完后，隐藏主界面图标
            self:removeSelf()
        end
    else
        showTips(cmd.msg)
    end
    
end

return oneWeekReward