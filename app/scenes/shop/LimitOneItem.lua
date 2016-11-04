-- Author: liufei
-- Date:   2015-09-16 15:17:17

local LimitOneItem = class("LimitOneItem", function()
    return display.newSprite("youhui/youhuiImg_17.png")
end)

function LimitOneItem:ctor(_oneItem)
    local sSize = self:getContentSize()
    self.tptId = _oneItem.id
    self.buyTimes = _oneItem.buyTimes
    self.costTable = string.split(LimitConsumeData[self.tptId]["diamond"],"|")
    --头像
    createItemIcon(self.tptId,tonumber(LimitConsumeData[self.tptId]["num"]),true,true)
    :pos(sSize.width*0.25, sSize.height*0.67)
    :addTo(self)
    :scale(0.87)
    --名字
    local nameColor =  cc.c3b(225,225,225)
    local star  = getItemStar(self.tptId)
    if star == 2 then
        nameColor =  cc.c3b(225,225,225)
    elseif star == 3 then
        nameColor =  cc.c3b(24,255,0)
    elseif star == 4 then
        nameColor =  cc.c3b(31,191,225)
    elseif star == 5 then
        nameColor =  cc.c3b(232,50,240)
    end

    cc.ui.UILabel.new({UILabelType = 2, text = itemData[self.tptId]["name"], align = cc.ui.TEXT_ALIGN_CENTER, size = sSize.height*0.135, color = nameColor})
    :align(display.CENTER, sSize.width*0.71, sSize.height*0.79)
    :addTo(self)

    --剩余购买次数
    display.newTTFLabel({
                            text="剩余购买:    次",
                            size=22,
                            color=cc.c3b(18,186,229),
                        })
    :pos(sSize.width*0.7, sSize.height*0.60)
    :addTo(self)

    self.restTimeLabel = cc.ui.UILabel.new({text = "", size = sSize.height*0.12, color = cc.c3b(255,255,0)})
    :pos(sSize.width*0.77, sSize.height*0.60)
    :addTo(self)

    self.costSp = display.newTTFLabel({
                            text="现价: ",
                            size=22,
                            color=cc.c3b(127,79,33),
                        })
            :addTo(self)
            :align(display.LEFT_CENTER,90,36)
    self.costLabel =  display.newTTFLabel({
                            text="",
                            size=22,
                            color=cc.c3b(0,160,233),
                        })
            :addTo(self)
            :align(display.LEFT_CENTER, self.costSp:getPositionX()+self.costSp:getContentSize().width, self.costSp:getPositionY())

    self.costDiamond = display.newSprite("common/common_Diamond.png")
        :addTo(self)
        :scale(0.6)
        :align(display.LEFT_CENTER, 10+self.costLabel:getPositionX()+self.costLabel:getContentSize().width, self.costLabel:getPositionY())


    --免费Label
    self.freeLabel = cc.ui.UILabel.new({text = "本次免费！", size = 28, color = cc.c3b(127,79,33)})
    :pos(sSize.width*0.22, 36)
    :addTo(self)

    --左侧限时出售
    local tmpNode = display.newTTFLabel{text = "限时",color = cc.c3b(255,255,0),size=20}
        :addTo(self)
        :pos(40,48)
    tmpNode:setRotation(-30)
    tmpNode = display.newTTFLabel{text = "出售",color = cc.c3b(255,255,0),size=20}
        :addTo(self)
        :pos(50,30)
    tmpNode:setRotation(-30)
    
    --购买按钮
    self.buyItem = cc.ui.UIPushButton.new({normal="youhui/youhuiBnt_01.png"})
    :pos(sSize.width*0.815, sSize.height*0.28)
    :addTo(self)
    :scale(0.8)
    :onButtonPressed(function(event)
        event.target:setScale(0.965*0.8)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0*0.8)
        end)
    :onButtonClicked(function(event)
        self:sendBuy()
    end)

    display.newTTFLabel{text = "抢 购",size = 38,color = cc.c3b(255,255,255)}
        :addTo(self.buyItem)

    self:refreshItem()
end

function LimitOneItem:refreshItem()
    self.restTimeLabel:setString(tostring(5 - self.buyTimes))
    -- if self.buyTimes <= 0 then
    --     self.freeLabel:setVisible(true)
    --     self.costSp:setVisible(false)
    --     self.costLabel:setVisible(false)
    --     self.costDiamond:setVisible(false)
    if self.buyTimes >= 5 then
        self.freeLabel:setVisible(true)
        self.freeLabel:setString("已售罄")
        self.costSp:setVisible(false)
        self.costLabel:setVisible(false)
        self.costDiamond:setVisible(false)
        self.buyItem:setVisible(false)
    else
        self.freeLabel:setVisible(false)
        self.costSp:setVisible(true)
        self.costLabel:setVisible(true)
        self.costDiamond:setVisible(true)
        self.costLabel:setString(self.costTable[self.buyTimes + 1])
    end

    self.costDiamond:pos(5+self.costLabel:getPositionX()+self.costLabel:getContentSize().width, self.costLabel:getPositionY()+3)
end

function LimitOneItem:sendBuy()
    if srv_userInfo.diamond < tonumber(self.costTable[self.buyTimes + 1]) then
       showTips("钻石不足")
       return
    else
       self.curCost = tonumber(self.costTable[self.buyTimes + 1])
    end
    local sendData={}
    sendData["goodId"] = self.tptId
    sendData["shopType"] = 10
    startLoading()
    m_socket:SendRequest(json.encode(sendData), CMD_PURCHASE, self, self.onGetBuyLimitItemResult)
end

function LimitOneItem:onGetBuyLimitItemResult(cmd)
    if cmd.result == 1 then
        self.buyTimes = self.buyTimes + 1
        self:refreshItem()
        if self.curCost and self.curCost > 0 then
            srv_userInfo["diamond"] = srv_userInfo["diamond"]-self.curCost
            mainscenetopbar:setDiamond()
        end
        showTips("购买成功！")
        DCItem.buy(tostring(self.tptId),itemData[self.tptId]["name"],tonumber(LimitConsumeData[self.tptId]["num"]),self.curCost,"钻石")
        redPtTag[self.tptId] = false
        if discountInstance then
            discountInstance:refreshActivityRedPoint()
        end
    else
        showTips(cmd.msg)
    end
end

return LimitOneItem