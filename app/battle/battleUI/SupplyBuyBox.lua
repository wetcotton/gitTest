-- Author: liufei
-- Date:   2015-08-29 10:36:50
local SupplyBuyBox = class("SupplyBuyBox",function()
    return display.newScale9Sprite("Expedition/tazdw_gu-04-03-02.png", nil, nil, cc.size(427,541))
end)

SupplyCallType = {
                    Supply_OK = 1,
                    Supply_Cancel = 2
                 }

function SupplyBuyBox:ctor(_supplyId,_hasBuy,_allPoints,_eventCallBack)
    if _eventCallBack then
        self.eventCallBack = _eventCallBack
    end
    self.sId = _supplyId
    local bgSize = cc.size(427,541)
    --上横梁
    display.newSprite("Expedition/youhou_pusa-01.png")
    :pos(bgSize.width*0.5,bgSize.height)
    :addTo(self)
    
    --上底板
    local upBg = display.newScale9Sprite("Expedition/gous_shitb-05-01-02-01.png", nil, nil, cc.size(391,138))
    :pos(bgSize.width*0.5,bgSize.height*0.825)
    :addTo(self)
    --头像
    display.newSprite("Expedition/"..supplyData[_supplyId]["resId"]..".png")
    :pos(upBg:getContentSize().width*0.21,upBg:getContentSize().height*0.5)
    :addTo(upBg)
    --名称
    cc.ui.UILabel.new({
        UILabelType = 2, text = supplyData[_supplyId]["name"], size = upBg:getContentSize().height*0.18, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_GREEN})
    :align(display.CENTER_LEFT,upBg:getContentSize().width*0.41,upBg:getContentSize().height*0.68)
    :addTo(upBg)
    --生效次数
    cc.ui.UILabel.new({
        UILabelType = 2, text = "生效次数："..supplyData[_supplyId]["CD"], size = upBg:getContentSize().height*0.15, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_YELLOW})
    :align(display.CENTER_LEFT,upBg:getContentSize().width*0.41,upBg:getContentSize().height*0.32)
    :addTo(upBg)

    local midBg = display.newScale9Sprite("Expedition/gous_shitb-05-01-02-01.png", nil, nil, cc.size(391,184))
    :pos(bgSize.width*0.5,bgSize.height*0.5)
    :addTo(self)
    cc.ui.UILabel.new({
        UILabelType = 2, text = "使用效果：", size = upBg:getContentSize().height*0.15, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_GREEN})
    :align(display.CENTER_LEFT,midBg:getContentSize().width*0.05,midBg:getContentSize().height*0.8)
    :addTo(midBg)
    local desLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = supplyData[_supplyId]["res"], size = upBg:getContentSize().height*0.15, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_YELLOW})
    :align(display.LEFT_TOP,midBg:getContentSize().width*0.15,midBg:getContentSize().height*0.7)
    :addTo(midBg)
    desLabel:setDimensions(midBg:getContentSize().width*0.7, midBg:getContentSize().height*0.6)

    local downBg = display.newScale9Sprite("Expedition/youhou_pusa-02.png", nil, nil, cc.size(393,65))
    :pos(bgSize.width*0.5,bgSize.height*0.24)
    :addTo(self)
    
    cc.ui.UILabel.new({
        UILabelType = 2, text = "购买消耗：", size = upBg:getContentSize().height*0.15, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_GREEN})
    :align(display.CENTER_LEFT,downBg:getContentSize().width*0.07,downBg:getContentSize().height*0.5)
    :addTo(downBg)
    local useStr = ""
    local useNum = 0
    local useColor = display.COLOR_WIHTE
    local canBuy = true
    self.usePoint = 0
    self.useDiamond = 0
    if tonumber(supplyData[_supplyId]["diamond"]) ~= 0 then
        useStr = "common/common_Diamond.png"
        useNum = tonumber(supplyData[_supplyId]["diamond"])
        if useNum > srv_userInfo.diamond then
           useColor = display.COLOR_RED
           canBuy = false
        end
        self.useDiamond = useNum
    else
        useStr = "Expedition/youhou_pusa-03.png"
        useNum = tonumber(supplyData[_supplyId]["point"])
        if useNum > _allPoints then
           useColor = display.COLOR_RED
           canBuy = false
        end
        self.usePoint = useNum
    end
    
    local useSp = display.newSprite(useStr)
    :pos(downBg:getContentSize().width*0.4,downBg:getContentSize().height*0.5)
    :addTo(downBg)
    useSp:scale(0.8)
    local useLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = tostring(useNum), size = upBg:getContentSize().height*0.16, align = cc.ui.TEXT_ALIGN_LEFT ,color = useColor})
    :align(display.CENTER_LEFT,downBg:getContentSize().width*0.57,downBg:getContentSize().height*0.5)
    :addTo(downBg)

    if _hasBuy == true then
       useSp:setVisible(false)
       useLabel:setString("已购买")
       canBuy = false
    end

    --按钮
    local confirmItem = cc.ui.UIPushButton.new({normal = "common/redBt1.png",pressed = "common/redBt2.png"})
    :pos(bgSize.width*0.27, display.height*0.08)
    :addTo(self)
    :onButtonClicked(function()
        startLoading()
        local sendData = {}
        sendData["tptId"] = _supplyId
        m_socket:SendRequest(json.encode(sendData), CMD_EXPEDITION_BUYSUPPLY, self, self.afterBuySupply)
    end)
    display.newSprite("Expedition/youhou_pusa-04.png")
    :pos(0,0)
    :addTo(confirmItem,2)
    local cancelItem = cc.ui.UIPushButton.new({normal = "common/yellowBt1.png",pressed = "common/yellowBt2.png"})
    :pos(bgSize.width*0.73, display.height*0.08)
    :addTo(self)
    :onButtonClicked(function()
        if self.eventCallBack then
           local event = {}
           event.callType = SupplyCallType.Supply_Cancel
           self.eventCallBack(event)
        else
            self:removeSelf()
        end
    end)
    display.newSprite("Expedition/youhou_pusa-05.png")
    :pos(0,0)
    :addTo(cancelItem)

    if canBuy == false then
       confirmItem:setTouchEnabled(false)
       display.newGraySprite("common/redBt1.png")
       :pos(0,0)
       :addTo(confirmItem)
    end
end

function SupplyBuyBox:afterBuySupply(cmd)
    if cmd.result ~= 1 then
       showTips(cmd.msg)
       return
    end
    showTips(cmd.msg)
    if self.eventCallBack then
       local event = {}
       event.callType = SupplyCallType.Supply_OK
       event.sId = self.sId
       event.usePoint = self.usePoint
       event.useDiamond = self.useDiamond
       self.eventCallBack(event)
    else
       self:removeSelf()
    end
end

return SupplyBuyBox