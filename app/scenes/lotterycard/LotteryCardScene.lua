
-- local mainSceneMenu = require("app.scenes.MainSceneMenu")

local LotteryCard=class("LotteryCard", function()
    local layer = display.newLayer("LotteryCard")
    layer:setNodeEventEnabled(true)
    return layer
    end)

local srv_restTime_diamond = 0
local lat_srv_time_diamond = nil
local srv_restTime_gold = 0
local lat_srv_time_gold = nil
local last_local_time = nil
local restTimes = 0 --剩余次数
local goldFreeTimes = 0
local timeHandle

local delayTime = 0
local idx = 1
local count = 0
local buyNum = 1
local cur_selectBox = 0
local ZHUAN_ACT_ID = 119001 --运营活动“转”道具,的活动ID

local rewardData = {}

local showRewards = {}

local LotCostType = {
                       kCost_gold = 1,
                       kCost_diamond = 2,
                    }

function LotteryCard:ctor()
    ZHUAN_ACT_ID = srv_userInfo.actInfo.actIds["19"]
    setIgonreLayerShow(true)
    --资源加载
    display.addSpriteFrames("Image/lotteryCard_img.plist", "Image/lotteryCard_img.png")
    
    MenuLayerFlag = 2

    self.costType = LotCostType.kCost_gold
    
    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)


    self.BackBt = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self)
    :pos(0, display.height )
    self.BackBt:setAnchorPoint(0,1)
    self.BackBt:onButtonClicked(function(evnet)
        setIgonreLayerShow(true)
        local _scene = cc.Director:getInstance():getRunningScene()
        _scene:addGuide_ani(10701)
        if (srv_restTime_gold < 1000 and goldFreeTimes < 5) or srv_restTime_diamond<1000 then
            self:getParent():refreshCardRedPt(true)
        else
            self:getParent():refreshCardRedPt(false)
        end
        self:removeSelf()
        setIgonreLayerShow(false)
        end)

    --抽卡的大框
    self.bgPanel = display.newSprite("#lotteryCard_img1.png")
    :addTo(self,2)
    :pos(display.cx, display.cy-30)
    local tmpSize = self.bgPanel:getContentSize()

    --剩余时间
    local bar = display.newSprite("#lotteryCard_img12.png")
    :addTo(self.bgPanel)
    :pos(tmpSize.width/2-117, 160)

    self.restTimeGold = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(59, 218, 255)})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2)

    --购买一个
    self.goldPurchase1 = cc.ui.UIPushButton.new({
        normal = "#lotteryCard_img7.png",
        pressed = "#lotteryCard_img8.png"
        })
    :addTo(self.bgPanel,1)
    :pos(tmpSize.width/2-117, 87)
    :onButtonPressed(function(event)
        event.target:getChildByTag(11):setPositionY(-30)
        event.target:getChildByTag(10):setVisible(false)
        end)
    :onButtonRelease(function(event)
        event.target:getChildByTag(11):setPositionY(0)
        event.target:getChildByTag(10):setVisible(true)
        end)
    :onButtonClicked(function(event)
        GuideManager:removeGuideLayer()
        self:purchaseGold(1)
        end)
    local topNode = display.newNode()
    :addTo(self.goldPurchase1, 0, 10)
    display.newSprite("common/common_GoldGet.png")
    :addTo(topNode)
    :pos(-50, -26)
    :scale(0.5)
    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "10000", size = 26, color = cc.c3b(255, 241, 100)})
    :addTo(topNode)
    :pos(-23, -29)
    
    local bottomNode = display.newNode()
    :addTo(self.goldPurchase1, 0, 11)
    local label =  cc.ui.UILabel.new({UILabelType = 2, text = "购买一个", size = 30, color = cc.c3b(255, 251, 203)})
    :addTo(bottomNode)
    :pos(-75, 20)
    setLabelStroke(label,30,cc.c3b(106, 57, 6),1,nil,nil,nil,nil, true)
    display.newSprite("Item/item_3013001.png")
    :addTo(bottomNode)
    :pos(62, 18)
    :scale(0.5)


    --购买十个（金币）
    self.goldPurchase10 = cc.ui.UIPushButton.new({
        normal = "#lotteryCard_img4.png",
        pressed = "#lotteryCard_img11.png"
        })
    :addTo(self.bgPanel,1)
    :pos(tmpSize.width/2-349, 87)
    :onButtonPressed(function(event)
        event.target:getChildByTag(11):setPositionY(-30)
        event.target:getChildByTag(10):setVisible(false)
        end)
    :onButtonRelease(function(event)
        event.target:getChildByTag(11):setPositionY(0)
        event.target:getChildByTag(10):setVisible(true)
        end)
    :onButtonClicked(function(event)
        if srv_userInfo.actInfo.actSts["19"] and srv_userInfo.actInfo.actSts["19"]==1 then
            self:selectCostStyle(1,
                function(event) self:purchaseGold(10) end,
                function(event) self:purchaseGold(10, 2) end)
        else
            self:purchaseGold(10)
        end
        
        end)
    local topNode = display.newNode()
    :addTo(self.goldPurchase10, 0, 10)
    display.newSprite("common/common_GoldGet.png")
    :addTo(topNode)
    -- :pos(-50, 25)
    :pos(-55, -26)
    :scale(0.5)
    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "90000", size = 26, color = cc.c3b(255, 241, 100)})
    :addTo(topNode)
    -- :pos(-23, 18)
    :pos(-25, -29)
    self.tenGoldlabel = label
    
    
    local bottomNode = display.newNode()
    :addTo(self.goldPurchase10, 0, 11)
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "购买十个", size = 30, color = cc.c3b(255, 251, 203)})
    :addTo(bottomNode)
    :pos(-80, 20)
    setLabelStroke(label,30,cc.c3b(106, 57, 6),1,nil,nil,nil,nil, true)
    
    -- :pos(-50, 25)
    display.newSprite("Item/item_3013001.png")
    :addTo(bottomNode)
    :pos(67, 18)
    -- :pos(-23, 18)
    :scale(0.6)

    --提示语
    self:showBuyTip2()



    --剩余时间
    local bar = display.newSprite("#lotteryCard_img12.png")
    :addTo(self.bgPanel)
    :pos(tmpSize.width/2+112, 160)

    self.restTimeDiamond = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(59, 218, 255)})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2)

    --购买一个
    self.diamondPurchase1 = cc.ui.UIPushButton.new({
        normal = "#lotteryCard_img9.png",
        pressed = "#lotteryCard_img10.png"
        })
    :addTo(self.bgPanel,1)
    :pos(tmpSize.width/2+112, 87)
    :onButtonPressed(function(event)
        event.target:getChildByTag(11):setPositionY(-30)
        event.target:getChildByTag(10):setVisible(false)
        end)
    :onButtonRelease(function(event)
        event.target:getChildByTag(11):setPositionY(0)
        event.target:getChildByTag(10):setVisible(true)
        end)
    :onButtonClicked(function(event)
        GuideManager:removeGuideLayer()
        self:purchaseDiamond(1)
        end)
    local topNode = display.newNode()
    :addTo(self.diamondPurchase1, 0, 10)
    display.newSprite("common/common_Diamond.png")
    :addTo(topNode)
    :pos(-50, -28)
    :scale(0.6)
    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "280", size = 26, color = cc.c3b(240, 144, 120)})
    :addTo(topNode)
    :pos(-23, -29)
    
    local bottomNode = display.newNode()
    :addTo(self.diamondPurchase1, 0, 11)
    cc.ui.UILabel.new({UILabelType = 2, text = "购买一个", size = 30, color = cc.c3b(255, 241, 100)})
    :addTo(bottomNode)
    :pos(-75, 20)
    display.newSprite("Item/item_5005501.png")
    :addTo(bottomNode)
    :pos(64, 20)
    :scale(0.5)


    local bar = display.newSprite("#lotteryCard_img12.png")
    :addTo(self.bgPanel)
    :pos(tmpSize.width/2+344, 160)
    local tmpNode = display.newNode()
    :addTo(bar)

    local clippingRect = display.newClippingRectangleNode(cc.rect(10, 0,176,50))
    :addTo(tmpNode)

    local buyTenLabel = cc.ui.UILabel.new({UILabelType = 2, text = "购买十个必得紫色完整道具（战车装备、镜片、改造材料）", size = 20, color = cc.c3b(59, 218, 255)})
    :addTo(clippingRect)
    buyTenLabel:pos(bar:getContentSize().width, bar:getContentSize().height/2)

    local actMoveTo = cc.MoveTo:create(10, cc.p(-buyTenLabel:getContentSize().width, bar:getContentSize().height/2))
    local seqAct = cc.Sequence:create(actMoveTo, 
        cc.CallFunc:create(function(event)
            buyTenLabel:setPositionX(bar:getContentSize().width)
        end))
    buyTenLabel:runAction(cc.RepeatForever:create(seqAct))
    --购买十个（钻石）
    self.diamondPurchase10 = cc.ui.UIPushButton.new({
        normal = "#lotteryCard_img5.png",
        pressed = "#lotteryCard_img6.png"
        })
    :addTo(self.bgPanel,1)
    :pos(tmpSize.width/2+344, 87)
    :onButtonPressed(function(event)
        event.target:getChildByTag(11):setPositionY(-30)
        event.target:getChildByTag(10):setVisible(false)
        end)
    :onButtonRelease(function(event)
        event.target:getChildByTag(11):setPositionY(0)
        event.target:getChildByTag(10):setVisible(true)
        end)
    :onButtonClicked(function(event)
        --“转”活动开启时候，可用道具十连抽
        if srv_userInfo.actInfo.actSts["19"] and srv_userInfo.actInfo.actSts["19"]==1 then
            self:selectCostStyle(2, 
                function(event) self:purchaseDiamond(10) end,
                function(event) self:purchaseDiamond(10, 2) end)
        else
            self:purchaseDiamond(10)
        end
        
        end)
    local topNode = display.newNode()
    :addTo(self.diamondPurchase10, 0, 10)
    display.newSprite("common2/com2_Img_9.png")
    :addTo(topNode)
    :pos(-50, -28)
    :scale(0.3)


    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "2600", size = 26, color = cc.c3b(240, 144, 120)})
    :addTo(topNode)
    :pos(-20, -29)
    --有打折活动
    if srv_userInfo.actInfo.actSts["15"] and srv_userInfo.actInfo.actSts["15"]==1 then
        label:setString(businessActivityData[srv_userInfo.actInfo.actIds["15"]].param)
    end
    self.tenDiamondlabel = label
    
    local bottomNode = display.newNode()
    :addTo(self.diamondPurchase10, 0, 11)
    cc.ui.UILabel.new({UILabelType = 2, text = "购买十个", size = 30, color = cc.c3b(255, 241, 100)})
    :addTo(bottomNode)
    :pos(-80, 20)
    display.newSprite("Item/item_5005501.png")
    :addTo(bottomNode)
    :pos(67, 20)
    :scale(0.6)

    -- --print(self:GetTimeStr(os.time()))
    timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
    -- self:showRestTimes()
    -- self:addShowRewards()
    self:onEnter()
    self:getItemTmpId()

    local tmpNode = display.newNode()
    :addTo(self.bgPanel)
    local clipnode = display.newClippingRectangleNode(cc.rect(90, 210, 880, 319))
    :addTo(tmpNode)

    -- self:setActionParams()
    self.IconNodes = {}
    self.scrollBar = {}

    local myTmpId = {1015031, 1025031, 1045031, 1055031, 1015041}
    for i=1,5 do
        self.scrollBar[i] = self:createScrollBar()
        :addTo(clipnode)
        :pos(165+(i-1)*175, self.bgPanel:getContentSize().height/2+35)

        -- self:NodeMoveAct(i)
        self:createNodes(i, false, myTmpId[i])
        -- self:createNodes(i, true)
         -- LotteryCardEff1(self.scrollBar[i],0,0)
    end

    
    self.rocker1 = display.newSprite("#lotteryCard_img13.png")
    :addTo(self.bgPanel)
    :pos(tmpSize.width+3, tmpSize.height/2-80)

    self.rocker2 = display.newSprite("#lotteryCard_img14.png")
    :addTo(self.bgPanel)
    :pos(tmpSize.width+3, tmpSize.height/2-80)
    self.rocker2:setVisible(false)
    GuideManager:_addGuide_2(10602, display.getRunningScene(),handler(self,self.caculateGuidePos))

    -- LotteryCardEff7(self.bgPanel,290,625)
    -- LotteryCardEff7(self.bgPanel,self.bgPanel:getContentSize().width-290,625,-1)
end

function LotteryCard:createScrollBar()
    local scrollNode = display.newNode()
    display.newSprite("#lotteryCard_img2.png")
    :addTo(scrollNode,1)

    local bar = display.newSprite("#lotteryCard_img3.png")
    :addTo(scrollNode, 0, 100)
    
    return scrollNode
end
--创建初始节点
function LotteryCard:createNodes(column, bLock, tmpId)
    self:setActionParams()
    self.IconNodes[column] = {}
    local bar = self.scrollBar[column]:getChildByTag(100)
    local tmpsize = bar:getContentSize()
    if bLock then
        for i=1,3 do
            self.IconNodes[column][i] = self:newIcon(10001)
            :addTo(bar)
            :pos(tmpsize.width/2,327-(i-1)*163+self.iconDy)
        end
    else
        for i=1,3 do
            if i==2 then
                self.IconNodes[column][i] = self:newIcon(tmpId)
                :addTo(bar)
                :pos(tmpsize.width/2,327-(i-1)*163+self.iconDy)
            else
                self.IconNodes[column][i] = self:newIcon()
                :addTo(bar)
                :pos(tmpsize.width/2,327-(i-1)*163+self.iconDy)
            end
            
        end
    end
end
function LotteryCard:removeNodes(column)
    local bar = self.scrollBar[column]:getChildByTag(100)
    local tmpsize = bar:getContentSize()

    for i=1,#self.rewardIcon do
        print(i)
        self.rewardIcon[i]:removeSelf()
        self.rewardIcon[i]=nil
    end
    bar:removeAllChildren()

    self.IconNodes[column] = {}
end

function LotteryCard:getItemTmpId()
    self.goldItem = {}
    self.diamondItem = {}
    for i,value in pairs(itemData) do
        if value.extPro~="null" then
            table.insert(self.diamondItem, value.id)
        end
        if value.golPro~="null" then
            table.insert(self.goldItem, value.id)
        end
    end
end

--新增图标
function LotteryCard:newIcon(tmpId)
    local bTarget = true
    if tmpId==nil then --没有指定模板ID就用问号创建，否则按指定的模板创建
        -- local randNum = math.random(#self.goldItem)
        -- tmpId = self.goldItem[randNum]
        tmpId = 10001
        bTarget = false
    end
    local icon = createItemIcon(tmpId)

    if bTarget and tmpId~=nil and tmpId~=10001 then
        local img = display.newSprite("#lotteryCard_img12.png")
        :addTo(icon)
        :pos(0, 75)
        :scale(0.7)

        local label = cc.ui.UILabel.new({UILabelType = 2, text = itemData[tmpId].name, size = 20, color = cc.c3b(59, 218, 255)})
        :addTo(img)
        :align(display.CENTER, img:getContentSize().width/2, img:getContentSize().height/2)
    end
    
    return icon
end

--开始抽卡的动作
function LotteryCard:NodeMoveAct(column)
    if g_isBanShu then
        self.shengyuBar:setVisible(false)
    end
    
    self.rocker1:setVisible(false)
    self.rocker2:setVisible(true)
    -- self.actTs = 0.06
    -- self.curReardIdx = 0
    -- self.rewardWenHao = {}
    -- self.rewardIcon = {}

    --移动第一阶段(第一个图标移出并删除，增加新的一个)
    -- printTable(self.IconNodes[column])
    for i=1,#self.IconNodes[column] do
        local delayAct = cc.DelayTime:create(1.0)
        local moveAct1 = cc.MoveTo:create(self.actTs, 
            cc.p(self.IconNodes[column][i]:getPositionX(), 265-(i-1)*163+self.iconDy)) --下降62
        local funcAct = cc.CallFunc:create(function(event)
                if i==3 then
                    local bar = self.scrollBar[column]:getChildByTag(100)
                    local icon = self:newIcon()
                    :pos(81,327+163-62+self.iconDy)
                    :addTo(bar)
                    table.insert(self.IconNodes[column], 1, icon)

                    self.IconNodes[column][#self.IconNodes[column]]:removeSelf()
                    table.remove(self.IconNodes[column])

                    self.IconNodes[column].cnt = 0
                    self:NodeMoveAct2(column)

                end
            end)
        self.IconNodes[column][i]:runAction(cc.Sequence:create(moveAct1, funcAct))
    end
    -- printTable(self.IconNodes[column]) 
end

function LotteryCard:setActionParams()
    self.actTs = 0.06
    self.cycleCnt = 20
    self.iconDy = -15
    self.curReardIdx = 0
    self.rewardWenHao = {} --存放获得的物品问号图标（未翻转之前的问号，用于记录它的翻转）
    self.rewardIcon = {} --存放获得的物品图标
    self.isFinished = false
end

function LotteryCard:NodeMoveAct2(column)
    --移动第二阶段（直接移出最前一个，并创建一个新的，之后可以循环这一阶段）
    self.IconNodes[column].cnt = self.IconNodes[column].cnt + 1
    for i=1,#self.IconNodes[column] do

        local toDy = 265-(i-1)*163+self.iconDy
        if self.IconNodes[column].cnt>self.cycleCnt then
            if buyNum==1 then
                toDy = 327-(i-1)*163+self.iconDy
            else
                toDy = 246-(i-1)*163+self.iconDy
            end
        end
        local moveAct2 = cc.MoveTo:create(self.actTs*2, 
            cc.p(self.IconNodes[column][i]:getPositionX(), toDy)) --下降225
        local funcAct2 = cc.CallFunc:create(function(event)
            if self.IconNodes[column].cnt>self.cycleCnt then
                --超过次数，终止动作
                if i==3 and self.isFinished==false then
                    self.isFinished = true
                    self.diamondPurchase1:setButtonEnabled(true)
                    self.diamondPurchase10:setButtonEnabled(true)
                    self.goldPurchase1:setButtonEnabled(true)
                    self.goldPurchase10:setButtonEnabled(true)
                    self.BackBt:setButtonEnabled(true)
                    GuideManager:_addGuide_2(10604, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                    --抽卡动作完成（暂时不用）
                    -- LotteryCardEff6(self.IconNodes[column][2],0,0)
                    -- if buyNum==10 then
                    --     LotteryCardEff6(self.IconNodes[column][1],0,0)
                    -- end
                    self:setRewardIconPos()
                end
                return
            end
            if self.IconNodes[column].cnt==1 then
                self.rocker1:setVisible(true)
                self.rocker2:setVisible(false)
            end

            if i==3 then   --此处判断是为了以下操作只执行一次
                --确定最终抽中的物品，放在最后一轮中
                local iconTmpId = nil
                if buyNum==1 then --抽一次，物品放在倒数第二轮创建
                    if self.IconNodes[column].cnt==self.cycleCnt-1 then
                        iconTmpId = rewardData[1].tmpId
                    end
                else              --抽十次，物品放在最后两轮创建
                    if self.IconNodes[column].cnt>=self.cycleCnt-1 then
                        self.curReardIdx = self.curReardIdx + 1
                        iconTmpId = rewardData[self.curReardIdx].tmpId
                    end
                end
                local bar = self.scrollBar[column]:getChildByTag(100)
                --本列上面新增一个图标
                local icon = self:newIcon()
                :pos(81,327+163-62+self.iconDy)
                :addTo(bar,1)
                table.insert(self.IconNodes[column], 1, icon)
                --同时删除本列最后一个图标
                self.IconNodes[column][#self.IconNodes[column]]:removeSelf()
                table.remove(self.IconNodes[column])

                --如果iconTmpId不为空，则这是最后的抽奖结果牌，需要创建对应的物品，以待翻牌使用
                if iconTmpId~=nil then
        
                    self.rewardWenHao[#self.rewardWenHao+1] = icon

                    self.rewardIcon[#self.rewardIcon+1] = self:newIcon(iconTmpId)
                    :pos(81,327+163-62+self.iconDy)
                    :addTo(bar)
                    local icon2 = self.rewardIcon[#self.rewardIcon]
                    icon2:setScaleX(0)

                end

                --做多少次循环
                -- print(self.IconNodes[column].cnt)
                if self.IconNodes[column].cnt>=(self.cycleCnt-3) then
                    self.actTs = self.actTs + 0.01
                end
                self:NodeMoveAct2(column)
            end
            end)
        self.IconNodes[column][i]:runAction(cc.Sequence:create(moveAct2, funcAct2))
    end
end
--抽卡结束后定位奖品坐标
function LotteryCard:setRewardIconPos()
    for i,value in ipairs(self.rewardWenHao) do
        local icon2 = self.rewardIcon[i]
        if buyNum==1 then
            toDy = 327-(2-1)*163+self.iconDy
        else
            if i<=5 then
                toDy = 246-(2-1)*163+self.iconDy
            else
                toDy = 246-(1-1)*163+self.iconDy
            end
        end
        icon2:setPositionY(toDy)
    end
    self.curFlipIdx = 1 --当前翻牌到第几个
    self:FlipRewardItems()
end

--一张牌翻牌动作
function LotteryCard:FlipRewardItems()
    if self.curFlipIdx>#rewardData then --所有都翻转完了
        if g_isBanShu and self.costType == 2 then
            self.shengyuBar:setVisible(true)
            self:showLestTimes(self.lotyCnt)
        end
        return
    end
    local flipTs = 0.05 --翻牌时间
    
    self.tmpFlipIdx = self.curFlipIdx
    if buyNum==10 then
        if self.curFlipIdx<=5 then
            self.tmpFlipIdx = self.curFlipIdx + 5
        else
            self.tmpFlipIdx = self.curFlipIdx - 5
        end
    end
    local icon = self.rewardWenHao[self.tmpFlipIdx]
    local icon2 = self.rewardIcon[self.tmpFlipIdx]
    local seq = cc.Sequence:create(cc.DelayTime:create(self.actTs*2), cc.ScaleTo:create(flipTs, 0, 1))
    icon:runAction(seq)
    local seq2 = cc.Sequence:create(cc.DelayTime:create(flipTs+self.actTs*2+0.1), cc.ScaleTo:create(flipTs, 1), 
        cc.CallFunc:create(function()
            self:isShowPurpleBox()
            end))
    icon2:runAction(seq2)
end
--根据条件是否显示弹出框
function LotteryCard:isShowPurpleBox()
    print(self.curFlipIdx)
    local value = rewardData[self.tmpFlipIdx]
    local star = getItemStar(value.tmpId)
    local itType = getItemType(value.tmpId)

    self.curFlipIdx = self.curFlipIdx + 1
    
    if buyNum==1 or 
        (star==5 and ((itType>=101 and itType<=106) or (itType>=801 and itType<=803)  or itType==306)) then
        print("获得紫色道具")
        self:showPurpleItemBox(value)
    else
        -- print("aaaaaa")
        self:FlipRewardItems()
        return
    end
end

local Attribute_pos = {
    {x=130,y=180},
    {x=130,y=140},
    {x=130,y=100},
    {x=130,y=60},
}
--创建紫色装备获得框
function LotteryCard:showPurpleItemBox(value)
    -- value.tmpId = 1043012
    local masklayer =  UIMasklayer.new()
    :addTo(self,100)
    local function  func()
        masklayer:removeSelf()
        self:FlipRewardItems()

    end
    masklayer:setOnTouchEndedEvent(func)

    
    

    --框
    local msgBox = display.newSprite("SingleImg/teamLevel/teamLevelImg3.png",display.cx, display.cy-30)
    :addTo(masklayer)
    :pos(display.cx, display.cy-70)
    masklayer:addHinder(msgBox)
    local tmpsize = msgBox:getContentSize()

    if buyNum==1 then
        if self.costType == LotCostType.kCost_gold then
            self:showBuyTip(1, 1, masklayer)
            msgBox:setPositionY(display.cy-100)
        else
            self:showBuyTip(1, 2, masklayer)
            msgBox:setPositionY(display.cy-100)
        end
        
    end

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("SingleImg/GainBox/GainBoxAni.ExportJson")
    local armature = ccs.Armature:create("GainBoxAni")
                        :addTo(msgBox,10)
                        :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height +20)

    local function playFlower()
        armature:getAnimation():play("titleFlower")
    end
    tmpAction = transition.sequence{
                                cc.Hide:create(),
                                cc.DelayTime:create(0.2),
                                cc.Show:create(),
                                cc.CallFunc:create(playFlower)
                            }

    armature:runAction(tmpAction)

    local title = display.newSprite("SingleImg/GainBox/title_1.png")
                    :addTo(msgBox,10)
                    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height +20)

    tmpAction = transition.sequence({           
                                cc.Hide:create(),
                                cc.DelayTime:create(0.3),
                                cc.Show:create(),
                                cc.ScaleTo:create(0  , 5.02 ,5.84),
                                cc.ScaleTo:create(0.1, 5.05 ,5.88),
                                cc.ScaleTo:create(0.1, 3.01 ,3.42),
                                cc.ScaleTo:create(0.1, 0.97 ,0.96),
                                cc.ScaleTo:create(0.1, 1 ,1)
                                    })
    title:runAction(tmpAction)

    local item = itemData[value.tmpId]
    --图标
    local icon = createItemIcon(value.tmpId)
    :addTo(msgBox)
    :pos(tmpsize.width/2-110, tmpsize.height-100)

    --星级
    local starNum = getItemStar(value.tmpId)
    for i=1,starNum do
        local star = display.newSprite("common/common_Star.png")
        :addTo(msgBox)
        :pos(tmpsize.width/2-50 + 34*i, tmpsize.height-100)
    end

    local itType = getItemType(value.tmpId)
    if itType>=101 and itType<=106 then
        --类型
        local bar = display.newSprite("equipment/equipmentImg3.png")
        :addTo(msgBox)
        :pos(222+80,msgBox:getContentSize().height - 65)

        local eqtType = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
        :addTo(bar)
        :pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
        eqtType:setAnchorPoint(0.5,0.5)
        eqtType:setString(itemTypeToString(value["tmpId"]))
        eqtType:setColor(cc.c3b(241, 171, 0))

        --名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(msgBox)
        :pos(270+80,msgBox:getContentSize().height - 65)
        name:setAnchorPoint(0,0.5)
        name:setString(item.name)
        name:setColor(cc.c3b(132, 0, 188))

        --等级
        self.level = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 25})
        :addTo(msgBox)
        :pos(260,msgBox:getContentSize().height - 140)
        self.level:setAnchorPoint(0,0.5)
        self.level:setColor(cc.c3b(64, 34, 15))

        self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "1", size = 25})
        :addTo(msgBox)
        :pos(self.level:getPositionX()+self.level:getContentSize().width,msgBox:getContentSize().height - 140)
        self.level:setAnchorPoint(0,0.5)

        --装载等级限制
        if item.minLvl>0 then
            local minLevel=cc.ui.UILabel.new({UILabelType = 2, text = "装载等级：", size = fontSize})
            :addTo(msgBox)
            :pos(130, tmpsize.height/2+20)
            minLevel:setColor(cc.c3b(238, 0, 0))
            local levelNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize, color = cc.c3b(238, 0, 0)})
            :pos(minLevel:getPositionX()+minLevel:getContentSize().width, minLevel:getPositionY())
            :addTo(msgBox)
            levelNum:setString(item.minLvl)
        end

        if item.sklId~=0 then
            local sklTab = skillData[item.sklId]
            self.sklNode = display.newNode()
            :addTo(msgBox)
            self.skl=cc.ui.UILabel.new({UILabelType = 2, text = "武器技能：", size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[1].x,Attribute_pos[1].y)
            :addTo(self.sklNode)
            self.skl:setColor(cc.c3b(64, 34, 15))
            self.sklName=cc.ui.UILabel.new({UILabelType = 2, text = sklTab.sklName, size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[1].x+self.skl:getContentSize().width, Attribute_pos[1].y)
            :addTo(self.sklNode)
            self.sklName:setColor(cc.c3b(255, 251, 182))


            self.hurt=cc.ui.UILabel.new({UILabelType = 2, text = "伤害系数：", size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[2].x,Attribute_pos[2].y)
            :addTo(self.sklNode)
            self.hurt:setColor(cc.c3b(64, 34, 15))
            self.hurtNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, 
                text = (sklTab.addPercent*100).."%", size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[2].x+self.hurt:getContentSize().width, Attribute_pos[2].y)
            :addTo(self.sklNode)
            self.hurtNum:setColor(cc.c3b(255, 251, 182))

            self.CD=cc.ui.UILabel.new({UILabelType = 2, text = "冷却时间：", size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[3].x,Attribute_pos[3].y)
            :addTo(self.sklNode)
            self.CD:setColor(cc.c3b(64, 34, 15))
            self.CDTime=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = fontSize})
            :addTo(self.sklNode)
            :align(display.CENTER_LEFT, Attribute_pos[3].x+self.CD:getContentSize().width, Attribute_pos[3].y)
            self.CDTime:setColor(cc.c3b(255, 251, 182))
            if itType==101 then
                self.CDTime:setString(item.sklCD.."秒")
            else
                self.CDTime:setString(sklTab.sklCD.."秒")
            end

            self.effect=cc.ui.UILabel.new({UILabelType = 2, text = "技能效果：", size = fontSize})
            :align(display.CENTER_LEFT, Attribute_pos[4].x,Attribute_pos[4].y)
            :addTo(self.sklNode)
            self.effect:setColor(cc.c3b(64, 34, 15))
            self.sklDes=cc.ui.UILabel.new({UILabelType = 2, text = sklTab.sklDes, size = fontSize})
            :addTo(self.sklNode)
            :align(display.TOP_LEFT, Attribute_pos[4].x+self.effect:getContentSize().width, Attribute_pos[4].y+12)
            self.sklDes:setDimensions(320,0)
            self.sklDes:setColor(cc.c3b(255, 251, 182))
        else
            local fontSize = 25
            pos = 0
            --属性显示
            if item.hp>0 then
                pos = pos + 1
                local HP=cc.ui.UILabel.new({UILabelType = 2, text = "血量：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                HP:setColor(cc.c3b(64, 34, 15))
                local HpNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+HP:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                HpNum:setString(item.hp)
            end
            if item.attack>0 then
                pos = pos + 1
                local Attack=cc.ui.UILabel.new({UILabelType = 2, text = "攻击：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Attack:setColor(cc.c3b(64, 34, 15))
                local AttackNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Attack:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                AttackNum:setString(item.attack)
            end
            if item.defense>0 then
                pos = pos + 1
                local Defense=cc.ui.UILabel.new({UILabelType = 2, text = "防御：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Defense:setColor(cc.c3b(64, 34, 15))
                local DefenseNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Defense:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                DefenseNum:setString(item.defense)
            end
            if item.cri>0 then
                pos = pos + 1
                local Cri=cc.ui.UILabel.new({UILabelType = 2, text = "暴击：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Cri:setColor(cc.c3b(64, 34, 15))
                local CriNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Cri:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                CriNum:setString(item.cri)

            end
            if item.hit>0 then
                pos = pos + 1
                local Hit=cc.ui.UILabel.new({UILabelType = 2, text = "命中：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Hit:setColor(cc.c3b(64, 34, 15))
                local HitNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Hit:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                HitNum:setString(item.hit)
            end
            if item.miss>0 then
                pos = pos + 1
                local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "闪避：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Miss:setColor(cc.c3b(64, 34, 15))
                local MissNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                MissNum:setString(item.miss)
            end
            if item.erecover>0 then
                pos = pos + 1
                local Erecover=cc.ui.UILabel.new({UILabelType = 2, text = "能量回复：", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
                :addTo(msgBox)
                Erecover:setColor(cc.c3b(64, 34, 15))
                local ErecoverNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
                :align(display.CENTER_LEFT, Attribute_pos[pos].x+Erecover:getContentSize().width,Attribute_pos[pos].y)
                :addTo(msgBox)
                local tmp = item.erecover
                tmp = string.format("%0.2f%%",(tmp*100))
                ErecoverNum:setString(tmp)
            end
        end
        
    else
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30})
        :addTo(msgBox)
        :pos(260,msgBox:getContentSize().height - 65)
        name:setAnchorPoint(0,0.5)
        name:setString(item.name)
        name:setColor(cc.c3b(132, 0, 188))

        local cur_value = get_SrvBackPack_Value(value.tmpId)
        local cnt
        if cur_value == nil then
            cnt = 0
        else
            cnt = cur_value.cnt
        end
        --拥有
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "拥有：", size = 25})
        :addTo(msgBox)
        :pos(260,msgBox:getContentSize().height - 140)
        label:setAnchorPoint(0,0.5)
        label:setColor(cc.c3b(64, 34, 15))
        local have = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :addTo(msgBox)
        :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
        have:setAnchorPoint(0,0.5)
        have:setString(cnt)

        --描述
        local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25,color=cc.c3b(64, 34, 15)})
        :addTo(msgBox)
        :pos(130,msgBox:getContentSize().height/2+20)
        des:setString(item["des"])
        des:setAnchorPoint(0,1)
        des:setWidth(320)
        des:setLineHeight(30)
    end
    --显示品质(战车装备或战车装备的碎片)
    local subNum = math.floor(value.tmpId/10000)
    if subNum>=101 and subNum<=106 then
        cc.ui.UILabel.new({UILabelType = 2, text = "（品质:"..item.score.."）", size = 25})
        :addTo(msgBox)
        :pos(34*starNum+260,msgBox:getContentSize().height - 103)
    end

    LotteryCardEff8(msgBox,tmpsize.width/2,tmpsize.height/2)
end

function LotteryCard:addShowRewards()
    local tSize = self.bgPanel:getContentSize()
    for i=1,#showRewards do
        local tReward = createItemIcon(showRewards[i],nil,true,true)
        :addTo(self.bgPanel)
        :pos(tSize.width*(0.32+ (i-1)*0.12), tSize.height*0.5)
        :scale(0.8)
    end
end

function LotteryCard:onInterval()
    if srv_restTime_diamond>=1000 then
        if self.restTimeDiamond then
            self.restTimeDiamond:setString(self:GetTimeStr(srv_restTime_diamond).." 后免费")
        end
        
        srv_restTime_diamond = srv_restTime_diamond - 1000
    else
        self.restTimeDiamond:setString("当前免费")
    end
    if srv_restTime_gold>=1000 and goldFreeTimes < 5 then
        self.restTimeGold:setString(self:GetTimeStr(srv_restTime_gold).." 后免费")
        srv_restTime_gold = srv_restTime_gold - 1000
    else
        if goldFreeTimes < 5 then
            self.restTimeGold:setString("当前免费 "..tostring(5 - goldFreeTimes).."/5")
        else
            self.restTimeGold:setString("今日免费次数已用完")
        end
    end
end
function LotteryCard:purchaseDiamond(num, butType)
    self.costType = LotCostType.kCost_diamond
    self.diamondPurchase1:setButtonEnabled(false)
    self.diamondPurchase10:setButtonEnabled(false)
    self.goldPurchase1:setButtonEnabled(false)
    self.goldPurchase10:setButtonEnabled(false)
    self.BackBt:setButtonEnabled(false)
    if num==1 then
        -- LotteryCardEff2(self.diamondPurchase1,-60,120, 2)
        if butType then
            self.butType=butType
        else
            self.butType = 1
            -- print(srv_restTime_diamond)
            if srv_restTime_diamond<1000 then --当前免费
                self.butType = 0
            end
        end
        
        buyNum = 1
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["buyType"] = self.butType
        sendData["num"] = buyNum
        local g_step = nil
        g_step = GuideManager:tryToSendFinishStep(107) --抽卡
        sendData.guideStep = g_step
        m_socket:SendRequest(json.encode(sendData), CMD_LOTTERY_CARD, self, self.onGetLotCardResult)
        startLoading()
    else
        -- LotteryCardEff3(self.diamondPurchase10,-50,130, 2)
        if butType then
            self.butType=butType
        else
            self.butType = 1
        end
        buyNum = 10
        local sendData = {}
        sendData["characterId"]=srv_userInfo["characterId"]
        sendData["buyType"] = self.butType
        sendData["num"] = buyNum
        m_socket:SendRequest(json.encode(sendData), CMD_LOTTERY_CARD, self, self.onGetLotCardResult)
        startLoading()
    end
end
function LotteryCard:purchaseGold(num, butType)
    self.costType = LotCostType.kCost_gold
    self.diamondPurchase1:setButtonEnabled(false)
    self.diamondPurchase10:setButtonEnabled(false)
    self.goldPurchase1:setButtonEnabled(false)
    self.goldPurchase10:setButtonEnabled(false)
    self.BackBt:setButtonEnabled(false)
    if num==1 then
        -- LotteryCardEff4(self.goldPurchase1,40,120, 2)
        if butType then
            self.butType=butType
        else
            self.butType = 1
            -- print(srv_restTime_diamond)
            if srv_restTime_gold<1000 and goldFreeTimes < 5 then --当前免费
                self.butType = 0
            end
        end

        buyNum = 1
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["buyType"] = self.butType
        sendData["num"] = buyNum
        m_socket:SendRequest(json.encode(sendData), CMD_LOTTERY_CARD_GOLD, self, self.onGetLotCardResult)
        startLoading()
    else
        -- LotteryCardEff5(self.goldPurchase10,35,120, 2)
        if butType then
            self.butType=butType
        else
            self.butType = 1
        end
        buyNum = 10
        local sendData = {}
        sendData["characterId"]=srv_userInfo["characterId"]
        sendData["buyType"] = self.butType
        sendData["num"] = buyNum
        m_socket:SendRequest(json.encode(sendData), CMD_LOTTERY_CARD_GOLD, self, self.onGetLotCardResult)
        startLoading()
    end
end


function LotteryCard:removeRewards()
    -- self.bgLight:setVisible(false)
    for i=1,10 do
        if self.itemBox[i]:getChildByTag(i+100) then
            self.itemBox[i]:removeChildByTag(i+100)
        end
        
    end
end

function LotteryCard:onEnter()
    startLoading()

    setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
    print("LotteryCard:enter")
    cur_selectBox = 0
    idx = 0

    local sendData = {}
    sendData["characterId"]=srv_userInfo["characterId"]
    m_socket:SendRequest(json.encode(sendData), CMD_GETLOTCARD_TIME, self, self.onGetLotCardRestTimeResult)
    -- display.addSpriteFrames("LotteryCard/card_bt.plist", "LotteryCard/card_bt.png")
    -- display.addSpriteFrames("LotteryCard/card_light.plist", "LotteryCard/card_light.png")
    -- display.addSpriteFrames("LotteryCard/card_out.plist", "LotteryCard/card_out.png")
end
function LotteryCard:onExit()
    scheduler.unscheduleGlobal(timeHandle)
    display.removeSpriteFramesWithFile("Image/lotteryCard_img.plist", "Image/lotteryCard_img.png")
end
function LotteryCard:GetTimeStr(nSec)
    -- if nSec<1000 then
    --     return "0"
    -- end
    nSec = nSec/1000
    local nHour, nMin
    nHour = math.floor(nSec/3600)
    nSec = nSec-nHour*3600
    nMin = math.floor(nSec/60)
    nSec = nSec-nMin*60
    if nSec==60 then
        nSec=0
    end

    local strRet = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
    return strRet
end

function LotteryCard:onGetLotCardRestTimeResult(result)
    if result["result"]==1 then
        srv_restTime_diamond = result["data"]["diffTS"]
        srv_restTime_gold = result["data"]["goldTS"]
        restTimes = result["data"]["times"]
        -- self:showRestTimes()
        last_local_time = os.time()*1000 
        lat_srv_time_diamond = srv_restTime_diamond
        lat_srv_time_gold = srv_restTime_gold
        showRewards = result["data"]["showIds"]
        goldFreeTimes = result["data"]["goldFreeCnt"]

        --购买万能碎片次数
        if g_isBanShu then
            self.lotyCnt = result["data"].lotyCnt
            self:showLestTimes(result["data"].lotyCnt)
        end
        
        -- self:addShowRewards()
        -- print(self:GetTimeStr(timeDif))
    end
    
end

function LotteryCard:onGetLotCardResult(result)
    if result["result"]==1 then
          
        self.lotyCnt = result["data"].lotyCnt


        rewardData = result.data.goods
        --打乱最后一个紫装的位置
        if buyNum==10 then
            local randNum = math.random(10)
            local tmpData = rewardData[randNum]
            rewardData[randNum] = rewardData[10]
            rewardData[10] = tmpData
        end
        

        for i,value in ipairs(rewardData) do
            local dc_item = itemData[value.tmpId]
            local reason = "金币抽卡"
            if self.costType == LotCostType.kCost_diamond then
                 reason = "钻石抽卡"
            end
            if dc_item then  --当奖励为道具时
                DCItem.get(tostring(dc_item.id), dc_item.name, value.cnt, reason)
            end
        end
        if self.costType == LotCostType.kCost_diamond then
            if data.num==1 then
                LotteryCardEff2(self.diamondPurchase1,-60,120, 2)
                --数据统计
                luaStatBuy("抽卡", "BUY_TYPE_LOTTERY", 1, "钻石", 280*self.butType)
                DCCoin.lost("钻石抽卡","钻石",280*self.butType,srv_userInfo.diamond)
            else
                LotteryCardEff3(self.diamondPurchase10,-50,130, 2)
                --数据统计
                luaStatBuy("抽卡", "BUY_TYPE_LOTTERY", 10, "钻石", 2600)
                DCCoin.lost("钻石十连抽","钻石",2600,srv_userInfo.diamond)
            end
        else
            if data.num==1 then
                LotteryCardEff4(self.goldPurchase1,40,120, 2)
                if self.butType == 0 then
                    goldFreeTimes = goldFreeTimes + 1
                end
                --数据统计
                luaStatBuy("抽卡", "BUY_TYPE_LOTTERY", 1, "金币", 10000*self.butType)
                DCCoin.lost("金币抽卡","金币",10000*self.butType,srv_userInfo.gold)
            else
                LotteryCardEff5(self.goldPurchase10,35,120, 2)
                --数据统计
                luaStatBuy("抽卡", "BUY_TYPE_LOTTERY", 10, "金币", 90000)
                DCCoin.lost("金币十连抽","金币",90000,srv_userInfo.gold)
            end
        end

        -- transition.fadeIn(self.light, {time = 0.2})
        
        if buyNum==1 then
            -- local frames = display.newFrames("color%d.png", 1, 5)
            -- self.topAnimation = display.newAnimation(frames, 0.5/5)
            -- local action = transition.playAnimationForever(self.topColor,self.topAnimation)
            
            if srv_restTime_diamond<1000 and self.costType == LotCostType.kCost_diamond then
                srv_restTime_diamond = 86400000
                lat_srv_time_diamond = srv_restTime_diamond
            end
            if srv_restTime_gold<1000 and self.costType == LotCostType.kCost_gold and goldFreeTimes < 5 then 
                srv_restTime_gold = 600000
                lat_srv_time_gold = srv_restTime_gold
            end
            for i=1,5 do
                if i==3 then
                    self:NodeMoveAct(3)
                else
                    self:removeNodes(i)
                    self:createNodes(i, true)
                end
            end
            -- self:NodeMoveAct(3)
            
        else
            for i=1,5 do
                self:removeNodes(i)
                self:createNodes(i, false)
                self:NodeMoveAct(i)
            end
            
        end
    else
        showTips(result.msg)
        self.diamondPurchase1:setButtonEnabled(true)
        self.diamondPurchase10:setButtonEnabled(true)
        self.goldPurchase1:setButtonEnabled(true)
        self.goldPurchase10:setButtonEnabled(true)
        self.BackBt:setButtonEnabled(true)
        -- self:onFinished()
        -- self:showRewardItem(10)
        -- self:createRewardBox(10)
    end
end

function LotteryCard:showRestTimes()
    
    if restTimes == 0 then
        self.restTimesLable:setString("")
        self.nextTime:setVisible(false)
        self.thisTime:setVisible(true)
    elseif restTimes == -1 then
        restTimes = 9
        self.restTimesLable:setString(restTimes)
        self.nextTime:setVisible(true)
        self.thisTime:setVisible(false)
    else
        self.restTimesLable:setString(restTimes)
        self.nextTime:setVisible(true)
        self.thisTime:setVisible(false)
    end
    
end



function LotteryCard:reloadRewardItemData()
    local rewardList={}
    for i,value in ipairs(rewardData) do
        if value.tmpId~=WANMENG_TMPID then
            rewardList[i] = value
        end
    end
    -- printTable(rewardList)
    return rewardList
end

function LotteryCard:caculateGuidePos(_guideId)
    print("caculateGuidePos-----------------  ".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10602==_guideId or 10603==_guideId or 10604==_guideId then
        if 10602==_guideId then
            g_node = self.diamondPurchase1
        elseif 10603==_guideId then
            g_node = self.confirm_1
        elseif 10604==_guideId then
            g_node = self.BackBt
            print("self.BackBt: ----------------------")
            printTable(g_node.sprite_[1]:getContentSize())
        end
        if g_node==nil then
            print("g_node==nil,  return")
            return nil
        end
        size = g_node.sprite_[1]:getContentSize()
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 10604==_guideId then
            midPos.x = midPos.x+50
            midPos.y = midPos.y-30
        end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end


--选择抽卡方式（活动期间可用道具）
function LotteryCard:selectCostStyle(mtype, callBack, callBack2)
    local masklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    :addTo(self,50)
    self.unLockMaskLayer = masklayer

    local panel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(700,460),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    local tmpsize = panel:getContentSize()

    --关闭按钮
    createCloseBt()
    :addTo(panel)
    :pos(tmpsize.width+30, tmpsize.height-50)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)

    local title = cc.ui.UILabel.new({UILabelType = 2, text = "提示", size = 28, color = cc.c3b(255, 241, 0)})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-50)

    local content = cc.ui.UILabel.new({UILabelType = 2, text = "新春转运活动期间，请选择一下两种抽卡方式，抽取结果是一样的哦！", size = 28})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height/2+30)
    content:setWidth(550)

    local costGold
    if mtype==1 then
        costGold =self.tenGoldlabel:getString()
    else
        costGold = self.tenDiamondlabel:getString()
    end
    --正常购买
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2-150, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = costGold.."   ", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        callBack()
        end)
    if mtype==1 then
        display.newSprite("common/common_GoldGet.png")
        :addTo(bt)
        :pos(55,0)
        :scale(0.5)
    else
        display.newSprite("common/common_Diamond.png")
        :addTo(bt)
        :pos(55,0)
        :scale(0.7)
    end
    

    --消耗道具抽卡
    local locParam = srv_userInfo.actInfo.actTime[tostring(ZHUAN_ACT_ID)].param
    local params = lua_string_split(locParam,"|")
    local srv_value = get_SrvBackPack_Value(tonumber(params[1]))
    local cnt
    if srv_value == nil then
        cnt = 0
    else
        cnt = srv_value.cnt
    end
    local needCnt
    if mtype==1 then
        needCnt = params[2]
    else
        needCnt = params[3]
    end
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2+150, 70)
    :onButtonClicked(function(event)
        if tonumber(cnt)<tonumber(needCnt) then
            showTips("道具不足")
            return
        end
        masklayer:removeSelf()
        callBack2()
        end)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = cc.c3b(44, 210, 255)})
    :addTo(bt)
    :align(display.CENTER_RIGHT,18, 0)
    label:setString(cnt.."/"..needCnt)

    createItemIcon(params[1])
    :addTo(bt)
    :pos(45,0)
    :scale(0.5)
end

function LotteryCard:showBuyTip(num, _type, parentNode)
    
    self.tipTmpNode = display.newNode()
    :addTo(parentNode,101)
    local str,path = "",""
    if num==1 then
        str = "购买一个"
    else
        str = "购买十个"
    end
    if _type==1 then
        path = 3013001
    else
        path = 5005501
    end
    local label = cc.ui.UILabel.new({UILabelType = 2, text = str, size = 30})
    :addTo(self.tipTmpNode)
    :pos(display.cx-190, display.cy+250)
    local icon = createItemIcon(path)
    :addTo(self.tipTmpNode)
    :pos(label:getPositionX()+label:getContentSize().width+25, label:getPositionY())
    :scale(0.4)
    local label2 = cc.ui.UILabel.new({UILabelType = 2, text = "，赠送以下道具：", size = 30})
    :addTo(self.tipTmpNode)
    :pos(label:getPositionX()+label:getContentSize().width + 50, label:getPositionY())
end
function LotteryCard:showBuyTip2()
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "购买", size = 24})
    :addTo(self,10)
    :pos(display.cx-310, display.cy+255)
    local icon = createItemIcon(3013001)
    :addTo(self,10)
    :pos(label:getPositionX()+label:getContentSize().width+25, label:getPositionY())
    :scale(0.4)
    local label2 = cc.ui.UILabel.new({UILabelType = 2, text = ",赠送普通材料道具", size = 24})
    :addTo(self,10)
    :pos(label:getPositionX()+label:getContentSize().width + 50, label:getPositionY())


    local label = cc.ui.UILabel.new({UILabelType = 2, text = "购买", size = 24})
    :addTo(self,10)
    :pos(display.cx+35, display.cy+255)
    local icon = createItemIcon(5005501)
    :addTo(self,10)
    :pos(label:getPositionX()+label:getContentSize().width+25, label:getPositionY())
    :scale(0.4)
    local label2 = cc.ui.UILabel.new({UILabelType = 2, text = ",赠送紫色道具", size = 24})
    :addTo(self,10)
    :pos(label:getPositionX()+label:getContentSize().width + 50, label:getPositionY())
end

function LotteryCard:showLestTimes(num)
    num = 20 - num

    if self.shengyuBar then
        self.shengyuBar:getChildByTag(100):setString(num)
        return 
    end

    local shengyuBar = display.newScale9Sprite("#lotteryCard_img12.png",nil,nil,cc.size(900,340))
    :addTo(self.bgPanel,10)
    :pos(self.bgPanel:getContentSize().width/2, self.bgPanel:getContentSize().height/2+40)
    self.shengyuBar = shengyuBar

    local lab = cc.ui.UILabel.new({UILabelType = 2, text = "万能碎片今日剩余购买次数：", size = 30, color = cc.c3b(255, 255, 0)})
    :addTo(shengyuBar)
    :align(display.CENTER, shengyuBar:getContentSize().width/2-20, shengyuBar:getContentSize().height/2)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = num, size = 30, color = cc.c3b(255, 255, 0)})
    :addTo(shengyuBar,0,100)
    :pos(lab:getPositionX() + lab:getContentSize().width/2, shengyuBar:getContentSize().height/2)
end

return LotteryCard