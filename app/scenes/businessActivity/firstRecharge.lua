-- @Author: anchen
-- @Date:   2015-08-27 09:40:41
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-01-26 16:46:14
firstRecharge = class("firstRecharge",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

local FIRSTRECHARGEID = 109070001

--获取本地任务表中的首充
function firstRecharge:getFirstRechargeTask()
    local tmpData = {}
    for i,value in pairs(taskData) do
        if value.type==8 then
            tmpData = value
            break
        end
    end

    return tmpData
end

firstRecharge.Instance = nil
function firstRecharge:ctor()
    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2, bgSize.height-150)

    display.newSprite("youhui/youhuiTag_12.png")
    :addTo(bg)
    :align(display.LEFT_CENTER,100, bgSize.height-130)

    display.newSprite("youhui/youhuiImg_10.png")
        :addTo(bg)
        :pos(bgSize.width/2-100,bgSize.height-100)

    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(bg)
    :pos(bg:getContentSize().width-10,bg:getContentSize().height-20)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)
    :hide()

    local tipsBar = display.newSprite("youhui/youhuiImg_12.png")
    :addTo(bg)
    :pos(bg:getContentSize().width/2, bg:getContentSize().height-260)

    local bust = display.newSprite("Bust/bust_20094.png")
        :addTo(tipsBar)
        :align(display.BOTTOM_CENTER, tipsBar:getContentSize().width-210, tipsBar:getContentSize().height/2)
    bust:setScaleX(-0.9)
    bust:setScaleY(0.9)

    local str = [[首次充值任意金额
即可获得价值          元大礼]]
    display.newTTFLabel{text = str,size = 32}
        :addTo(tipsBar)
        :align(display.LEFT_BOTTOM,70,10)

    display.newTTFLabel{text = "888",color = cc.c3b(255,255,0),size = 44,font = "fonts/slicker.ttf", }
        :addTo(tipsBar)
        :align(display.LEFT_BOTTOM,267,8)

    --充值按钮
    local btn = cc.ui.UIPushButton.new("youhui/youhuiBnt_01.png")
    :addTo(tipsBar)
    :scale(1.2)
    :pos(tipsBar:getContentSize().width-210, tipsBar:getContentSize().height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.98*1.2)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0*1.2)
        end)
    :onButtonClicked(function(event)
        g_recharge.new()
        :addTo(display.getRunningScene())
        end)
    display.newTTFLabel{text = "充 值",size = 44}
        :addTo(btn)

    --奖励物品
    local rewardBar = display.newScale9Sprite("youhui/youhuiImg_19.png",nil,nil,cc.size(800,270),cc.rect(50,0,1,270))
    :addTo(bg)
    :pos(bg:getContentSize().width/2 , 170)

    display.newScale9Sprite("youhui/youhuiImg_20.png",nil,nil,cc.size(740,130),cc.rect(13,13,100,100))
        :addTo(rewardBar)
        :pos(rewardBar:getContentSize().width/2,rewardBar:getContentSize().height/2+25)

    --充值本地数据，就一条
    local lclData = self:getFirstRechargeTask()
    local rewards = lua_string_split(lclData.rewardItems, "|")
    local startPt = cc.p(120,rewardBar:getContentSize().height/2+25)
    local offX = 140
    for i=1,#rewards do
        local rewardItem = lua_string_split(rewards[i],"#")
        printTable(rewardItem)
         if tonumber(rewardItem[1])<10 then
            local icon = GlobalGetSpecialItemIcon(rewardItem[1],rewardItem[2],0.9)
            :addTo(rewardBar)
            -- icon:setScale(0.9)
            icon:setPosition(startPt.x+offX*(i-1),startPt.y)
        else
            local icon = createItemIcon(rewardItem[1],rewardItem[2],true,{sacle = 1/0.9})
            :addTo(rewardBar)
            icon:setScale(0.9)
            icon:setPosition(startPt.x+offX*(i-1),startPt.y)
        end
    end
    
    self.srvData = nil
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==8 then
            self.srvData = value
        end
    end
    -- printTable(self.srvData)
    --领奖按钮
    local scale = 0.7
    local receviceBt = cc.ui.UIPushButton.new("firstRecharge/receiveBt1.png")
    :addTo(rewardBar)
    :pos(rewardBar:getContentSize().width/2, 50)
    :scale(scale)
    :onButtonPressed(function(event)
        event.target:setScale(0.98*scale)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0*scale)
        end)
    :onButtonClicked(function(event)
        if self.srvData.status==0 then
            showMessageBox("充值后可领取！")
            return
        end
        if self.srvData then
            startLoading()
            TaskMgr:ReqSubmit(self.srvData.id)
        end
        
        end)
    self.receviced = display.newSprite("firstRecharge/receiveBt3.png")
    :addTo(rewardBar)
    :pos(rewardBar:getContentSize().width-110, 100)
    self.receviced:setVisible(false)

    self.receviceBt = receviceBt
    self:setBtStatus()
end

function firstRecharge:setBtStatus()
    local receviceBt= self.receviceBt
    if self.srvData==nil then
        receviceBt:setVisible(false)
        self.receviced:setVisible(true)
    elseif self.srvData.status==1 then
        receviceBt:setVisible(true)
        self.receviced:setVisible(false)
        receviceBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
        receviceBt:setTouchEnabled(true)
    elseif self.srvData.status==0 then
        receviceBt:setVisible(true)
        self.receviced:setVisible(false)
        receviceBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
        receviceBt:setTouchEnabled(true)
    else
        receviceBt:setVisible(false)
        self.receviced:setVisible(true)
    end
    -- if srv_userInfo.paidDiad>0 then
        
    -- else
    --     receviceBt:setVisible(true)
    --     self.receviced:setVisible(false)
    --     receviceBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
    --     receviceBt:setTouchEnabled(true)
    -- end
end

function firstRecharge:onEnter()
    firstRecharge.Instance = self
end
function firstRecharge:onExit()
    firstRecharge.Instance = nil 
end

--领取任务
function firstRecharge:OnSubmitRet(cmd)
    endLoading()
    if cmd.result==1 then
        showTips("领取成功")
        self.srvData.status=2
        self:setBtStatus(self.receviceBt)

        --领取奖励弹框
        local curRewards = {}
        local lclData = taskData[self.srvData.tptId]
        local rewards = lua_string_split(lclData.rewardItems, "|")
        for i=1,#rewards do
            local rewardItem = lua_string_split(rewards[i],"#")
            if tonumber(rewardItem[1])==1 then
                table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=golds})
            elseif tonumber(rewardItem[1])==2 then
                table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=diamond})
            else
                table.insert(curRewards, {templateID=tonumber(rewardItem[1]), num=tonumber(rewardItem[2])})
            end
        end
        GlobalShowGainBox(nil, curRewards)
        print("================================领取受宠奖品")
        discountInstance:closeActivity(5)
    else
        showTips(cmd.msg)
    end
end

return firstRecharge