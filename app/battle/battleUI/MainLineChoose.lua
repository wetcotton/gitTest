-- Author: liufei
-- Date:   2015-08-30 15:50:37

local MainLineChoose = class("MainLineChoose", function()
     return display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,210))
end)

function MainLineChoose:ctor(_finishCallBack)
     self:addGoodChoose()
     self:addBadChoose()
     self.choose = 1
     self.finishCallBack = _finishCallBack
end

-- local goodWords = "善阵营，人善被人欺，人善被人骗，加入我们，你将成为活雷锋（做好事被电线杆砸死）。"
-- local badWords = "恶阵营，恶人随心所欲，恶人当道，朱门酒肉香，路有恶人挡，加入我们你将成为土豪。"
local goodWords = "善阵营，坚持初心，在这纷乱的世界中一路前行，期望有一天到达理想的彼岸"
local badWords = "恶阵营，披荆斩棘，我不入地狱谁入地狱，用自己的方式开辟一个新世界"

function MainLineChoose:addGoodChoose()
     local leftWave = display.newSprite("Battle/MainLine/the_fox-03.png")
     :pos(display.width*0.29,display.height*0.75)
     :addTo(self)
     local rightWave = display.newSprite("Battle/MainLine/the_fox-03.png")
     :pos(display.width*0.47,display.height*0.75)
     :addTo(self)
     rightWave:setScaleX(-1)
     local leftDai = display.newSprite("Battle/MainLine/the_fox-14.png")
     :pos(display.width*0.32,display.height*0.32)
     :addTo(self)
     local rightDai = display.newSprite("Battle/MainLine/the_fox-14.png")
     :pos(display.width*0.44,display.height*0.32)
     :addTo(self)
     rightDai:setScaleX(-1)
     local goodBg = display.newSprite("Battle/MainLine/the_fox-01.png")
     :pos(display.width*0.38,display.height*0.53)
     :addTo(self)
     local goodBgSize = goodBg:getContentSize()
     local headImg = display.newSprite("Battle/MainLine/the_fox-05.png")
     :pos(goodBgSize.width*0.38,goodBgSize.height*0.82)
     :addTo(goodBg)
     local goodLabel = cc.ui.UILabel.new({UILabelType = 2, text = " + 1", size = display.height*0.04, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_GREEN})
     :align(display.CENTER, goodBgSize.width*0.62, goodBgSize.height*0.82)
     :addTo(goodBg)
     local chooseButton = cc.ui.UIPushButton.new({normal = "Battle/MainLine/the_fox-04.png"})
     :pos(goodBgSize.width*0.5, goodBgSize.height*0.63)
     :addTo(goodBg)
     :onButtonClicked(function()
        self.choose = 1
        showMessageBox("你确定加入善阵营吗？",handler(self,self.makeChoice))
     end)
     local addLabel = cc.ui.UILabel.new({UILabelType = 2, text = "加入善", size = display.height*0.025, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
     :align(display.CENTER, 0, 0)
     :addTo(chooseButton)
     addLabel:enableOutline(cc.c4f(0,0,0,255),1)
     local goodDesLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = goodWords, size = display.height*0.025, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
     :align(display.LEFT_TOP,goodBgSize.width*0.12,goodBgSize.height*0.5)
     :addTo(goodBg)
     goodDesLabel:setDimensions(goodBgSize.width*0.76, goodBgSize.height*0.4)
     local leftJiao = display.newSprite("Battle/MainLine/the_fox-16.png")
     :pos(goodBgSize.width*0.07,goodBgSize.height*0.12)
     :addTo(goodBg)
     local rightJiao = display.newSprite("Battle/MainLine/the_fox-16.png")
     :pos(goodBgSize.width*0.93,goodBgSize.height*0.12)
     :addTo(goodBg)
     rightJiao:setScaleX(-1)
     local leftTiao = display.newSprite("Battle/MainLine/the_fox-12.png")
     :pos(goodBgSize.width*0.28,-goodBgSize.height*0.04)
     :addTo(goodBg)
     local rightTiao = display.newSprite("Battle/MainLine/the_fox-12.png")
     :pos(goodBgSize.width*0.72,-goodBgSize.height*0.04)
     :addTo(goodBg)
     rightTiao:setScaleX(-1)
     local round = display.newSprite("Battle/MainLine/the_fox-07.png")
     :pos(goodBgSize.width*0.5,goodBgSize.height*0.08)
     :addTo(goodBg)
     local wordSp = display.newSprite("Battle/MainLine/the_fox-08.png")
     :pos(goodBgSize.width*0.5,goodBgSize.height*0.08)
     :addTo(goodBg)
end

function MainLineChoose:addBadChoose()
     local leftDai = display.newSprite("Battle/MainLine/the_fox-15.png")
     :pos(display.width*0.56,display.height*0.32)
     :addTo(self)
     local rightDai = display.newSprite("Battle/MainLine/the_fox-15.png")
     :pos(display.width*0.68,display.height*0.32)
     :addTo(self)
     rightDai:setScaleX(-1)
     local badBg = display.newSprite("Battle/MainLine/the_fox-02.png")
     :pos(display.width*0.62,display.height*0.53)
     :addTo(self)
     local leftWave = display.newSprite("Battle/MainLine/the_fox-10.png")
     :pos(display.width*0.525,display.height*0.74)
     :addTo(self)
     local rightWave = display.newSprite("Battle/MainLine/the_fox-10.png")
     :pos(display.width*0.715,display.height*0.74)
     :addTo(self)
     rightWave:setScaleX(-1)
     local badBgSize = badBg:getContentSize()
     local upHead = display.newSprite("Battle/MainLine/the_fox-11.png")
     :pos(badBgSize.width*0.5,badBgSize.height)
     :addTo(badBg)
     local headImg = display.newSprite("Battle/MainLine/the_fox-06.png")
     :pos(badBgSize.width*0.38,badBgSize.height*0.82)
     :addTo(badBg)
     local badLabel = cc.ui.UILabel.new({UILabelType = 2, text = " + 1", size = display.height*0.04, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_RED})
     :align(display.CENTER, badBgSize.width*0.62, badBgSize.height*0.82)
     :addTo(badBg)
     local chooseButton = cc.ui.UIPushButton.new({normal = "Battle/MainLine/the_fox-04.png"})
     :pos(badBgSize.width*0.5, badBgSize.height*0.63)
     :addTo(badBg)
     :onButtonClicked(function()
        self.choose = 2
        showMessageBox("你确定加入恶阵营吗？",handler(self,self.makeChoice))
     end)
     local addLabel = cc.ui.UILabel.new({UILabelType = 2, text = "加入恶", size = display.height*0.025, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
     :align(display.CENTER, 0, 0)
     :addTo(chooseButton)
     addLabel:enableOutline(cc.c4f(0,0,0,255),1)
     local badDesLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = badWords, size = display.height*0.025, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
     :align(display.LEFT_TOP,badBgSize.width*0.12,badBgSize.height*0.5)
     :addTo(badBg)
     badDesLabel:setDimensions(badBgSize.width*0.76, badBgSize.height*0.4)
     local leftJiao = display.newSprite("Battle/MainLine/the_fox-17.png")
     :pos(badBgSize.width*0.02,badBgSize.height*0.1)
     :addTo(badBg)
     local rightJiao = display.newSprite("Battle/MainLine/the_fox-17.png")
     :pos(badBgSize.width*0.98,badBgSize.height*0.1)
     :addTo(badBg)
     rightJiao:setScaleX(-1)
     local leftTiao = display.newSprite("Battle/MainLine/the_fox-13.png")
     :pos(badBgSize.width*0.28,-badBgSize.height*0.04)
     :addTo(badBg)
     local rightTiao = display.newSprite("Battle/MainLine/the_fox-13.png")
     :pos(badBgSize.width*0.72,-badBgSize.height*0.04)
     :addTo(badBg)
     rightTiao:setScaleX(-1)
     local round = display.newSprite("Battle/MainLine/the_fox-07.png")
     :pos(badBgSize.width*0.5,badBgSize.height*0.08)
     :addTo(badBg)
     local wordSp = display.newSprite("Battle/MainLine/the_fox-09.png")
     :pos(badBgSize.width*0.5,badBgSize.height*0.08)
     :addTo(badBg)
end

function MainLineChoose:makeChoice()
    local sendData = {}
    sendData["mainline"] = self.choose
    startLoading()
    m_socket:SendRequest(json.encode(sendData), CMD_CHOOSE_GOODBAD, self, self.afterChoose)
end

function MainLineChoose:afterChoose(cmd)
    if cmd.result ~= 1 then
       showTips(cmd.msg)
       if self.finishCallBack then
           self.finishCallBack()
        end
        self:removeSelf()
       return
    end
    srv_userInfo.mainline = self.choose
    if self.finishCallBack then
       self.finishCallBack()
    end
    self:removeSelf()

    if self.choose==1 then
        srv_userInfo["goodEvil"] = 1
    else
        srv_userInfo["goodEvil"] = -1
    end
end

return MainLineChoose