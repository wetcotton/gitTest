-- @Author: anchen
-- @Date:   2016-05-19 14:28:55
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-23 14:44:44
fundLayer = class("fundLayer",function()
    local layer =  display.newLayer()
    -- local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

local fundsInfo = {
    {img = "youhui/discountBtn_13.png", pos = cc.p(200, display.cy+200), layer = g_newfund, fundId=100001,name = "新手基金"},
    {img = "youhui/discountBtn_12.png", pos = cc.p(200, display.cy+100), layer = g_newfund, fundId=200001,name = "猎人基金"},
    {img = "youhui/discountBtn_8.png", pos = cc.p(200, display.cy), layer = g_newfund, fundId=300001,name = "勇士基金"},
    {img = "youhui/discountBtn_14.png", pos = cc.p(200, display.cy-260), layer = g_foundAct,name = "城镇基金"},
}

fundLayer.instance = nil
function fundLayer:ctor()
    fundLayer.instance = self
    self.mainBg = getMainSceneBgImg(mapAreaId)
            :addTo(self)

    --关闭按钮
    self.closeBtn = cc.ui.UIPushButton.new({
        normal="common/common_BackBtn_1.png",
        pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height )
        :addTo(self)
        :onButtonClicked(function(event)
            self:removeSelf()
        end)

    local function setBtClicked(node,i)
        for i=1,#self.fundBt do
            self.fundBt[i]:setButtonEnabled(true)
        end
        node:setButtonEnabled(false)

        if self.m_node then
            self.m_node:removeSelf()
            self.m_node = nil
        end
        
        self.m_node = fundsInfo[i].layer.new(fundsInfo[i].fundId)
        :addTo(self)
        :pos(150,0)
    end

    --左侧基金按钮
    self.fundBt = {}
    for i=1,#fundsInfo do
        local content = cc.ui.UIPushButton.new({
        normal="firstRecharge/discountImg_1.png",
        disabled="firstRecharge/discountImg_2.png"
        })
        :scale(0.96)
        :onButtonClicked(function(event)
            setBtClicked(event.target, i)
        end)
        :addTo(self)
        :pos(fundsInfo[i].pos.x,fundsInfo[i].pos.y)
        local img = display.newSprite(fundsInfo[i].img)
            :addTo(content)
            :pos(-18,0)
        

        -- local label = cc.ui.UILabel.new({UILabelType = 2, text = fundsInfo[i].name, size = 32})
        --     :addTo(content,2)
        --     :align(display.CENTER,10,0)
        -- local retnode = setLabelStroke(label,32,display.COLOR_BLACK,nil,nil,nil,nil,nil, true)

        if i==#fundsInfo then
            img:setPositionY(8)
            content:setScaleY(1.4)
            img:setScaleY(1/1.4)
            -- label:setScaleY(1/1.4)
            -- setLabelVisible(retnode, 1, 1/1.4)
        end

        self.fundBt[i] = content
    end

    setBtClicked(self.fundBt[1], 1)


    self:btRedPoint()
    
end
function fundLayer:onExit()
    fundLayer.instance = nil
end

--按钮上的红点
function fundLayer:btRedPoint()
    --城镇基金红点
    local num = TaskMgr:GetCanSubNum(TaskTag.oldfund)
    print("old num :"..num)
    local node = self.fundBt[#fundsInfo]
    node:removeChildByTag(10)
    if num>0 then
        
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(60,30)
        RedPt:setScaleY(1/1.4)
    end

    local fundTaskNums = {0,0,0}
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].tgtType==49 then
            for j=1,#fundsInfo-1 do
                if taskData[value.tptId].params2==fundsInfo[j].fundId and value.status==1 then
                    fundTaskNums[j] = fundTaskNums[j] + 1
                end
            end
        end
    end
    --其他基金
    for i=1,#fundsInfo-1 do
        local num = fundTaskNums[i]
        local node = self.fundBt[i]
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end
    
end

return fundLayer