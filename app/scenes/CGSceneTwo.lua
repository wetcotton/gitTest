-- Author: liufei
-- Date:   2015-08-18 16:01:26

local AllWords = {
                   [1] = "头好痛！这是哪儿？难道我穿越了。。。",
                   [2] = "叫唤什么，成天做梦当什么勇士！",
                   [3] = "。。。",
                   [4] = "爸爸，不要发这么大的火嘛。",
                   [5] = "你闭嘴。我今天非揍他不可！",
                   [6] = "这个笨家伙，让外面的冷风好好吹吹他发昏的脑袋！",
                   [7] = "爸爸，弟弟还小，不懂事。你就原谅他一次嘛",
                 }


local CGSceneTwo = class("CGScene", function()
    return display.newLayer()
end)

function CGSceneTwo:ctor(params)
    if nil==params then
        params = {}
    end
    audio.stopMusic(true)
    audio.playMusic("audio/startAni/startAni_bgMusic_4.mp3", true)

    local function default()
        print("CG2 onComplete")
        self:removeSelf()
    end
    self.onComplete = params.onComplete or default  --结束回调

    self.bg = display.newSprite("CG/cg2_bg.png")
    :align(display.CENTER, display.cx, display.cy)
    :addTo(self)
    
    local bgSize = self.bg:getContentSize()

    local resName = ""
    local scale = 0.85
    local posX = 0
    local posY = 0
    if params.heroTmpId == 10121 then --男
        resName = "boy"
        posX = display.width*0.79
        posY = - display.height*0.07
        scale = 0.85
    else--女
        resName = "girl"
        posX = display.width*0.76
        posY = - display.height*0.14
        AllWords[5] = "你闭嘴。我今天非揍她不可！"
        AllWords[7] = "爸爸，妹妹还小，不懂事。你就原谅他一次嘛"
        scale = 0.6
    end
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("CG/cg2"..resName..".ExportJson")
    manager:addArmatureFileInfo("CG/cg2"..resName..".ExportJson")
    local user = ccs.Armature:create("cg2"..resName)
    :align(display.CENTER_BOTTOM, display.width*0.79, posY)
    :addTo(self.bg)
    user:scale(scale)

    manager:removeArmatureFileInfo("CG/cg2father.ExportJson")
    manager:addArmatureFileInfo("CG/cg2father.ExportJson")
    local father = ccs.Armature:create("cg2father")
    :align(display.CENTER_BOTTOM, display.width*0.08, 0)
    :addTo(self.bg)
    father:scale(0.85)

    manager:removeArmatureFileInfo("CG/cg2sister.ExportJson")
    manager:addArmatureFileInfo("CG/cg2sister.ExportJson")
    local sister = ccs.Armature:create("cg2sister")
    :align(display.CENTER_BOTTOM, 0, 0)
    :addTo(self.bg)
    sister:scale(0.85)
    
    --前景
    local forward = display.newSprite("CG/cg2_forward.png")
    :addTo(self)
    forward:setPosition(forward:getContentSize().width/2,forward:getContentSize().height/2)

    user:runAction(transition.sequence({
                                         cc.CallFunc:create(function()
                                            user:getAnimation():play("standup")
                                            self:showWord(user, AllWords[1], cc.p(-display.width*0.06, display.width*0.25*(0.85/scale)),3,0.85/scale)
                                         end),
                                         cc.DelayTime:create(2),
                                         cc.CallFunc:create(function()
                                            user:getAnimation():play("stand")
                                         end),
                                         cc.DelayTime:create(6.6),
                                         cc.CallFunc:create(function()
                                            user:getAnimation():play("behit")
                                         end),
                                         cc.DelayTime:create(4.3),
                                         cc.CallFunc:create(function()
                                            user:getAnimation():play("bekick")
                                         end),
                                       }))
    father:runAction(transition.sequence({
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("walk")
                                         end),
                                         cc.MoveTo:create(3,cc.p(display.width*0.57, display.height*0.04)),
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("abuse")
                                            self:showWord(father, AllWords[2],  cc.p(-display.width*0.06, display.width*0.28), 3)
                                         end),
                                         cc.DelayTime:create(1.5),
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("stand")
                                         end),
                                         cc.DelayTime:create(3.4),
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("hit")
                                            self:showWord(father, AllWords[5],  cc.p(-display.width*0.06, display.width*0.28), 3)
                                         end),
                                         cc.DelayTime:create(1.6),
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("stand")
                                         end),
                                         cc.DelayTime:create(3.4),
                                         cc.CallFunc:create(function()
                                            father:getAnimation():play("kick")
                                            self:showWord(father, AllWords[6],  cc.p(-display.width*0.06, display.width*0.28), 3)
                                         end),
                                       }))
    sister:runAction(transition.sequence({
                                         cc.CallFunc:create(function()
                                            sister:getAnimation():play("walk")
                                         end),
                                         cc.MoveTo:create(3,cc.p(display.width*0.49, display.height*0.04)),
                                         cc.CallFunc:create(function()
                                            sister:getAnimation():play("stand")
                                         end),
                                         cc.DelayTime:create(2),
                                         cc.CallFunc:create(function()
                                            self:showWord(sister, AllWords[4],  cc.p(-display.width*0.06, display.width*0.25), 3)
                                         end),
                                         cc.DelayTime:create(6),
                                         cc.CallFunc:create(function()
                                            self:showWord(sister, AllWords[7],  cc.p(-display.width*0.06, display.width*0.25), 3)
                                         end),
                                       }))
    self:performWithDelay(self.onComplete,14.7)
end

function CGSceneTwo:showWord(_tar, _words, _pos, _time, _scale)
    local function checkRemoveWord()
        if self.wordsBg then
          self.wordsBg:removeSelf()
          self.wordsBg = nil
        end
    end
    checkRemoveWord()

    self.wordsBg = display.newSprite("CG/cg2_wordbg.png")
    :align(display.CENTER_BOTTOM,_pos.x,_pos.y)
    :addTo(_tar)

    local sNum = 0.6
    if _scale ~= nil then
        sNum = sNum*_scale
    end
    self.wordsBg:scale(sNum)

    local wordLabel =  cc.ui.UILabel.new({UILabelType = 2, text = _words, size = self.wordsBg:getContentSize().height*0.16, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_BLACK})
    :align(display.CENTER_LEFT,self.wordsBg:getContentSize().width*0.04, self.wordsBg:getContentSize().height*0.57)
    :addTo(self.wordsBg)
    wordLabel:setDimensions(self.wordsBg:getContentSize().width*0.92, self.wordsBg:getContentSize().height*0.68)

    if AllWords[6] == _words then
      self.wordsBg:runAction(cc.MoveBy:create(1.5,cc.p(display.width*0.2,0)))
    end
    self.wordsBg:performWithDelay(checkRemoveWord,_time)
    
end

return CGSceneTwo