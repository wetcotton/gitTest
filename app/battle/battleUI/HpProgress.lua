--
-- Author: liufei
-- Date: 2014-11-05 16:14:13
--
local HpProgress = class("Progress", function(background, fillImage)
        local progress = display.newSprite(background)
        local fill = display.newProgressTimer(fillImage, display.PROGRESS_TIMER_BAR)
        fill:setMidpoint(cc.p(0, 0.5))
        fill:setBarChangeRate(cc.p(1.0, 0))
        fill:setPosition(progress:getContentSize().width/2, progress:getContentSize().height/2)
        fill:setScaleX(progress:getContentSize().width/fill:getContentSize().width)
        progress:addChild(fill)
        fill:setPercentage(100)
        progress.fill = fill
        
        return progress
    end)

function HpProgress:ctor()
       
end

function HpProgress:setProgress(_progress)
    self.fill:setPercentage(_progress)
end

function HpProgress:goProgress(_time, _percent)
    self.fill:runAction(cc.ProgressTo:create(_time,_percent))
end

return HpProgress
