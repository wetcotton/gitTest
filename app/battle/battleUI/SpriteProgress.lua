--Author: anchen
--Date:   2015-08-12 10:21:33

SpriteProgressCallType = {
                            kCall_Click = 1,   --点击事件
                            kCall_Ready = 2,   --冷却到位
                         }

local SpriteProgress = class("SpriteProgress",function(_spriteFrame,_cd,_id,_eventCallBack,_num)
    local pSprite = display.newSprite(_spriteFrame..".png")
    pSprite.spriteFrame = _spriteFrame
    pSprite.cd = _cd
    pSprite.id = _id
    if _eventCallBack then
        pSprite.eventCallBack = _eventCallBack
    end
    pSprite.num = _num
    return pSprite
end)

function SpriteProgress:ctor()

    self.pSpriteGray = display.newProgressTimer(display.newSprite(self.spriteFrame.."_gray.png"), display.PROGRESS_TIMER_BAR)
    :pos(self:getContentSize().width/2, self:getContentSize().height/2)
    :addTo(self)
    self.pSpriteGray:setMidpoint(cc.p(0, 1))
    self.pSpriteGray:setBarChangeRate(cc.p(0, 1))
    self.pSpriteGray:setPercentage(100)

    self.occlusionGray = display.newSprite(self.spriteFrame.."_gray.png")
    :pos(self:getContentSize().width/2, self:getContentSize().height/2)
    :addTo(self)
    self.occlusionGray:setVisible(false)
    self.occlusionGray:setTouchEnabled(true)
   
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" and self.eventCallBack then
            self.eventCallBack({callSp = self,callType = SpriteProgressCallType.kCall_Click, callId = self.id})
        end
        return false
    end)
    
    if self.num ~= nil then
        local sSize = display.newSprite("Battle/battleSeblt_1075002.png"):getContentSize()
        local labelBg = display.newSprite("Battle/xinban_hengge-06-02.png")
        :pos(sSize.width*0.5,sSize.height*0.05)
        :addTo(self)
        labelBg:setScaleX(-0.8)
        self.numLabel = cc.ui.UILabel.new({UILabelType = 2, text = itemData[self.id]["name"].."*"..tostring(self.num), size = display.height*0.02, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(237,227,199)})
        :align(display.CENTER, sSize.width*0.5, sSize.height*0.05)
        :addTo(self)
    end
end

function SpriteProgress:startCooling()
    self:setTouchEnabled(false)
    self.pSpriteGray:setPercentage(100)
    if self.isGet then
        self:goProgress(tonumber(self.cd.m_attackInfo.mainCD),0)
    else
        self:goProgress(tonumber(self.cd),0)
    end
end

function SpriteProgress:setIsMainCDGet(_isGet)
    self.isGet = _isGet
end

function SpriteProgress:pauseCooling()
    if self.pSpriteGray:getPercentage() > 0 then
        self.pSpriteGray:pause()
    elseif self.eventCallBack then
        self.occlusionGray:setVisible(true)
    end
end

function SpriteProgress:resumeCooling()
    if self.pSpriteGray:getPercentage() > 0 then
        self.pSpriteGray:resume()
    elseif self.eventCallBack then
        self.occlusionGray:setVisible(false)
    end
end

function SpriteProgress:getPercent()
    return self.pSpriteGray:getPercentage()
end

function SpriteProgress:goProgress(_time, _percent)
    self.pSpriteGray:runAction(transition.sequence({
                                                     cc.ProgressTo:create(_time,_percent),
                                                     cc.CallFunc:create(function()
                                                         self:setTouchEnabled(true)
                                                         if self.eventCallBack then
                                                             self.eventCallBack({callSp = self,callType = SpriteProgressCallType.kCall_Ready, callId = self.id})
                                                         end
                                                     end)
                                                   }))
end

function SpriteProgress:afterUseSeblt()
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    self.num = self.num - 1
    if self.num <= 0 then
        g_instance.sebltControls[self.id] = nil
        g_spriteProgress[self.id] = nil
        self:removeSelf()

    else
        self.numLabel:setString(itemData[self.id]["name"].."*"..tostring(self.num))
    end
end

return SpriteProgress