--
-- Author: liufei
-- Date: 2015-04-22 12:11:06
--
local LegionOverLayer = class("LegionOverLayer", function()
	 return display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,210))
end)

function LegionOverLayer:ctor(_overData)
	-- local overData = {
 --                            allHp = allHp,
 --                            remainderHp = remainderHp,
 --                            allDamage = AllDamageValue
 --                         }
    self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
      if event.name == "began" then
          app:enterScene("LoadingScene", {SceneType.Type_Block})
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
    
    cc.ui.UILabel.new({UILabelType = 2, text = "关卡进度:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.45)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "+"..string.format("%.2f",_overData.allDamage*100/_overData.allHp).."%", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,72,18)})
    :pos(display.width*0.35, bg:getPositionY() + bg:getContentSize().height*0.45)
    :addTo(self,2)
    local fillBg = display.newSprite("Battle/Settlement/jiesuan_05.png")
    :pos(display.width*0.55, bg:getPositionY() + bg:getContentSize().height*0.45)
    :addTo(self,2)
    fillBg:setScaleX(0.7)
    local fill = display.newProgressTimer("Battle/Settlement/jiesuan_06.png", display.PROGRESS_TIMER_BAR)
    :pos(display.width*0.55, bg:getPositionY() + bg:getContentSize().height*0.45)
    :addTo(self,2)
    fill:setScaleX(0.7)
    fill:setMidpoint(cc.p(0, 0.5))
    fill:setBarChangeRate(cc.p(1.0, 0))
    fill:setPercentage((_overData.allHp-_overData.remainderHp)/_overData.allHp*100)
    cc.ui.UILabel.new({UILabelType = 2, text = string.format("%.2f",(_overData.allHp-_overData.remainderHp)*100/_overData.allHp).."%", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,241,0)})
    :pos(display.width*0.67, bg:getPositionY() + bg:getContentSize().height*0.45)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "总伤害:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.3)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = tostring(_overData.allDamage), size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,72,18)})
    :pos(display.width*0.33, bg:getPositionY() + bg:getContentSize().height*0.3)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "金币:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY() + bg:getContentSize().height*0.15)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "+"..tostring(_overData.addGold), size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,72,18)})
    :pos(display.width*0.31, bg:getPositionY() + bg:getContentSize().height*0.15)
    :addTo(self,2)
    if srv_userInfo.goodEvil <= -5000 or srv_userInfo.goodEvil >= 5000 then
        _overData.addGE = "已达最大值"
    end
    cc.ui.UILabel.new({UILabelType = 2, text = "善恶值:", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.55, bg:getPositionY() + bg:getContentSize().height*0.15)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = tostring(_overData.addGE), size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,241,0)})
    :pos(display.width*0.64, bg:getPositionY() + bg:getContentSize().height*0.15)
    :addTo(self,2)
    cc.ui.UILabel.new({UILabelType = 2, text = "公会战利品: ", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(64,34,15)})
    :pos(display.width*0.25, bg:getPositionY())
    :addTo(self,2)
    --线和掉落
    display.newSprite("Battle/Settlement/jiesuan_13.png")
    :pos(display.width*0.5, display.height*0.4)
    :addTo(self,2)
    display.newSprite("Battle/Settlement/jiesuan_13.png")
    :pos(display.width*0.5, display.height*0.22)
    :addTo(self,2)
    for i=1,#AllLegionRewards do
        print("H1:"..AllLegionRewards[i]["id"])
        local itemSprite = GlobalGetItemIcon(AllLegionRewards[i]["id"])
        :pos(display.width*(6.2+(i-1)*1.9)/20,display.height*0.33)
        :addTo(self,2)
        itemSprite:setScale(0.7)
        local itemLabel = cc.ui.UILabel.new({UILabelType = 2, text = string.format("x%d", AllLegionRewards[i]["num"]), size = display.height*0.035, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
        :pos(display.width*(6+(i-1)*1.9)/20, display.height*0.25)
        :addTo(self,2) 
    end 
    cc.ui.UILabel.new({UILabelType = 2, text = "点击屏幕继续", size = display.height*0.035, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
    :align(display.CENTER, display.width*0.5, bg:getPositionY() - bg:getContentSize().height*0.57)
    :addTo(self,2)
end

return LegionOverLayer