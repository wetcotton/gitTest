-- Author: liufei
-- Date:   2015-11-17 14:19:45

local WorldBossOverLayer = class("WorldBossOverLayer", function()
    return display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,210))
end)

function WorldBossOverLayer:ctor(_overData)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
      if event.name == "began" then
          app:enterScene("LoadingScene", {SceneType.Type_Main})
      end
    end)
    local bg = display.newSprite("SingleImg/teamLevel/teamLevelImg3.png")
    :pos(display.width*0.5, display.height*0.45)
    :addTo(self,2)
    bg:scale(1.3)
    display.newSprite("Battle/Settlement/jiesuan_20.png")
    :pos(display.width*0.5, bg:getPositionY() + bg:getContentSize().height*0.5 + display.height*0.12)
    :addTo(self)
    display.newSprite("Battle/legionTitle.png")
    :pos(display.width*0.5, bg:getPositionY() + bg:getContentSize().height*0.5 + display.height*0.12)
    :addTo(self)
    cc.ui.UILabel.new({UILabelType = 2, text = "BOSS进度:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.42)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = " +"..string.format("%.2f",_overData.allDamage*100/_overData.allHp).."%", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,72,18)})
    :pos(display.width*0.37, bg:getPositionY() + bg:getContentSize().height*0.42)
    :addTo(self,2)
    local fillBg = display.newSprite("Battle/Settlement/jiesuan_05.png")
    :pos(display.width*0.57, bg:getPositionY() + bg:getContentSize().height*0.42)
    :addTo(self,2)
    fillBg:setScaleX(0.7)
    local fill = display.newProgressTimer("Battle/Settlement/jiesuan_06.png", display.PROGRESS_TIMER_BAR)
    :pos(display.width*0.57, bg:getPositionY() + bg:getContentSize().height*0.42)
    :addTo(self,2)
    fill:setScaleX(0.7)
    fill:setMidpoint(cc.p(0, 0.5))
    fill:setBarChangeRate(cc.p(1.0, 0))
    fill:setPercentage((_overData.allHp-_overData.remainderHp)/_overData.allHp*100)
    cc.ui.UILabel.new({UILabelType = 2, text = string.format("%.2f",(_overData.allHp-_overData.remainderHp)*100/_overData.allHp).."%", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,241,0)})
    :pos(display.width*0.68, bg:getPositionY() + bg:getContentSize().height*0.42)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "总伤害:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.25)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = tostring(_overData.allDamage), size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,72,18)})
    :pos(display.width*0.33, bg:getPositionY() + bg:getContentSize().height*0.25)
    :addTo(self,2)

    cc.ui.UILabel.new({UILabelType = 2, text = "战利品: ", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.08)
    :addTo(self,2)
    --线和掉落
    display.newSprite("Battle/Settlement/jiesuan_13.png")
    :pos(display.width*0.5, display.height*0.4)
    :addTo(self,2)
    display.newSprite("Battle/Settlement/jiesuan_13.png")
    :pos(display.width*0.5, display.height*0.22)
    :addTo(self,2)
    self.awardList = cc.ui.UIListView.new {
            viewRect = cc.rect(340, display.height*0.2, 600, 180),
            direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        }
        :addTo(self,2)
    for i=1,#AllLegionRewards do
        local item = self.awardList:newItem()
        local oneSp = nil
        oneSp = GlobalGetItemIcon(AllLegionRewards[1]["id"])
        oneSp:setScale(0.7)
        local itemLabel = cc.ui.UILabel.new({UILabelType = 2, text = string.format("x%d", AllLegionRewards[i]["num"]), size = display.height/23, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
        :pos(12,-15)
        :addTo(oneSp)
        item:addContent(oneSp)
        item:setItemSize(112, 130)
        self.awardList:addItem(item)
    end
    self.awardList:reload()
    cc.ui.UILabel.new({UILabelType = 2, text = "点击屏幕继续", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
    :align(display.CENTER, display.width*0.5, bg:getPositionY() - bg:getContentSize().height*0.57)
    :addTo(self,2)
end

return WorldBossOverLayer