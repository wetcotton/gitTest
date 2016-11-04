--
-- Author: liufei
-- Date: 2014-11-24 10:18:23
--

local TextSize = display.height/20

local HurtNumber = class("HurtNumber", function()
    return display.newNode()
end)                        

function HurtNumber:ctor(_number, _isCrit)
    local scaleNum = 1
	if _number > 0 then--伤害
        local fontName = ""
        local numSize = 0
        local w = 0
        local h = 0
        self.numLabel = cc.LabelAtlas:_create()
        :addTo(self)
        if _isCrit then
            fontName = "Battle/shuziheti_d02-04.png"
            w = 43
            h = 49
            scaleNum = 0.75
        else
            fontName = "Battle/shuziheti_d02-01.png"
            w = 21
            h = 25
            self.numLabel:setPositionX(self.numLabel:getPositionX() + display.width*0.03)
        end
        self.numLabel:initWithString(":"..tostring(_number),
        fontName,
        w,
        h,
        string.byte(0))
        -- self.numLabel:setSystemFontSize(numSize)
	elseif _number == 0 then--闪避
        self.numLabel = display.newSprite("Battle/xxxttu_d02-11.png")
        :addTo(self)
        self.numLabel:setPosition(display.width*0.065,display.width*0.015)
        scaleNum = 0.85
	else--治疗
        self.numLabel = cc.LabelAtlas:_create()
        :addTo(self)
        self.numLabel:initWithString(":"..tostring(_number),
        "Battle/shuziheti_d02-02.png",
        32,
        37,
        string.byte(0))
        scaleNum = 0.75
	end

    local fadein = cc.FadeIn:create(0.2)
    local scalein = cc.ScaleTo:create(0.2,1*scaleNum)
    local movebyin = cc.MoveBy:create(0.2,cc.p(0,TextSize/8))
    local spIn = cc.Spawn:create({fadein,scalein,movebyin})

    local delay = cc.DelayTime:create(0.2)

    local fadeout = cc.FadeOut:create(0.5)
    local scaleout = cc.ScaleTo:create(0.5,0.85*scaleNum)
    local movebyout = cc.MoveBy:create(0.5,cc.p(0,TextSize*2.2))
    local spOut = cc.Spawn:create({fadeout,scaleout,movebyout})
    
    local callback = cc.CallFunc:create(self.removeSelf)
    self.numLabel:runAction(transition.sequence({spIn,delay,spOut,callback}))
    
end

return HurtNumber 