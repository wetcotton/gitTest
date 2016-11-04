--
-- Author: liufei
-- Date: 2014-12-05 15:50:51
--

local DropBox = class("DropBox", function()
	return display.newNode()
end)

function DropBox:ctor(_boxInfo,_index,_posX)
	 self.boxInfo = _boxInfo
	 self.index= _index
	 local randomX = {
	                        [1] = _posX*0.75,
                          [2] = _posX*0.8,
                          [3] = _posX*0.85,
                          [4] = _posX*0.9,
                          [5] = _posX*0.95,
                          [6] = _posX*1,
                          [7] = _posX*1.05,
                          [8] = _posX*1.1,
                          [9] = _posX*1.15,
	                 }
	 local randomY = {
	                      [1] = display.height*10.3/40,
                          [2] = display.height*11/40,
                          [3] = display.height*11.7/40,
	                 }
   local pX = randomX[math.random(9)]
   local pY = randomY[math.random(3)]
	 local targetPos = cc.p(pX, pY)
	 self:runAction(transition.sequence({
                                            cc.Spawn:create({
                                                              cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,display.height/40)), 5),
                                                              cc.ScaleTo:create(0.1,0.5)
                                                            }),
                                            cc.Spawn:create({
                                                              cc.EaseIn:create(cc.MoveTo:create(0.5, targetPos),5),
                                                              cc.ScaleTo:create(0.5,1)
                                                            }),
	 	                                }))
	 self.mBox = display.newSprite("Battle/dropbox.png")
	 self.mBox:setTouchEnabled(true)
   self.mBox:scale(1.5)
	 self.mBox:setTouchSwallowEnabled(true)
	 self.mBox:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	 	self:getBox()
        return true
     end)
	 self:setContentSize(self.mBox:getContentSize())
	 self.mBox:setPosition(self:getContentSize().width/2, self:getContentSize().height)
	 self:addChild(self.mBox)
end

function DropBox:getBox()
	 self:stopAllActions()
	 local function removeDropBox()
	 	local num = tonumber(cc.Director:getInstance():getRunningScene().boxLabel:getString()) + 1
	 	cc.Director:getInstance():getRunningScene().boxLabel:setString(tostring(num))
	 	AllDropBox[self.index] = nil
	 	self:removeSelf()
	 end
	 self:runAction(transition.sequence({   
                                            cc.Spawn:create({
                                                              cc.MoveTo:create(0.6, cc.p(display.width*23/25, display.height*17/18)),
                                                              cc.ScaleTo:create(0.6,0.4)
                                                            }),
                                            cc.CallFunc:create(removeDropBox)
	 	                                }))
end

return DropBox