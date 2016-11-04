--
-- Author: Huang YuZhao
-- Date: 2015-08-17 11:41
--

--计算坐标和大小，用于新手引导
--由于采用的宽度不变高度拉伸，所以以display.width为计量单位

getPositionLayer = class("getPositionLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 0))
    layer:setNodeEventEnabled(true)
    return layer
end)

function getPositionLayer:ctor()
	self:setLocalZOrder(10000)
	S_SIZE(self,display.width,display.height)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            return self:touchBegin(event)

        elseif event.name == "moved" then
            self:touchMoved(event)
        elseif event.name == "ended" then
            self:touchEnd(event)
        end

    end)

    self.drawNode = display.newDrawNode()
    					:addTo(self)

    display.newTTFLabel({
		    		text = "display.width: "..display.width.."   display.height  "..display.height,
		            size = 28,
		            align = cc.TEXT_ALIGNMENT_LEFT,
		            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		            color = cc.c3b(0, 255, 0),
		    		})
		    		:align(display.LEFT_CENTER, 30, display.height-40)
		    		:addTo(self,1)
    
    self._Str = "cc.rect(width*%0.3f,width*%0.3f = height*%0.3f,width*%0.3f,width*%0.3f)"
	self.Label_1 = display.newTTFLabel({
		    		text = string.format(self._Str,0,0,0,0,0),
		            size = 28,
		            align = cc.TEXT_ALIGNMENT_LEFT,
		            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		            color = cc.c3b(255, 255, 0),
		    		})
		    		:align(display.LEFT_CENTER, 30, display.height-70)
		    		:addTo(self,1)
		    		:hide()

	self.Label_2 = display.newTTFLabel({
		    		text = "",
		            size = 28,
		            align = cc.TEXT_ALIGNMENT_LEFT,
		            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		            color = cc.c3b(0, 255, 255),
		            dimensions = cc.size(1000,400)
		    		})
		    		:align(display.LEFT_TOP, 30, display.height-100)
		    		:addTo(self,1)
		    		:hide()
end

function getPositionLayer:touchBegin(event)
	local x,y = event.x,event.y
	self.beginPt = cc.p(x,y)
	return true
end

function getPositionLayer:drawRect(endPt)
	local x,y = endPt.x,endPt.y
	local _beginPt ,size = self.beginPt,cc.size(endPt.x-self.beginPt.x,endPt.y-self.beginPt.y)
	if x<_beginPt.x then
		_beginPt = endPt
		size = cc.size(self.beginPt.x-endPt.x,self.beginPt.y-endPt.y)
	end

	local rect = {x = _beginPt.x,y = _beginPt.y,width = size.width,height = size.height}
	local points = {
        {rect.x,rect.y},
        {rect.x + rect.width, rect.y},
        {rect.x + rect.width, rect.y + rect.height},
        {rect.x, rect.y + rect.height}
    }
    self.drawNode:clear()
	self.drawNode = display.newPolygon(points,{fillColor = cc.c4f(1,0,0,0.2), borderColor = cc.c4f(0,1,0,1), borderWidth = 1},self.drawNode)
	
	local midPt = cc.p((self.beginPt.x+x)/2,(self.beginPt.y+y)/2)

	local left_bottomPt = cc.p(0,0)
	left_bottomPt.x = self.beginPt.x
	left_bottomPt.y = self.beginPt.y
	if left_bottomPt.y>y then
		left_bottomPt.y = y
	end

	local xxx_1 = left_bottomPt.x/display.width
	local xxx_2 = left_bottomPt.y/display.width
	local xxx_3 = rect.width/display.width
	local xxx_4 = math.abs(rect.height/display.width)

	local xxx_5 = (midPt.x+30)/display.width
	local xxx_6 = (midPt.y-30)/display.width
	local xxx_7 = (midPt.y-30)/display.height

	local xxx_8 = left_bottomPt.y/display.height

	local formatStr = "_beginPt:\n  x: %0.3f     y: %0.3f\nmidPoint:\n  x: %0.3f = width*%0.2f  y: %0.3f = width*%0.2f = height*%0.2f\nsize: \n width:   %0.3f    height: %0.3f"

	self.Label_1:setString(string.format(self._Str,xxx_1,xxx_2,xxx_8,xxx_3,xxx_4))
	self.Label_2:setString(string.format(formatStr,_beginPt.x,_beginPt.y,midPt.x,xxx_5,midPt.y,xxx_6,xxx_7,size.width,math.abs(size.height)))

end

function getPositionLayer:touchMoved(event)
	self.Label_1:show()
	self.Label_2:show()
	local x,y = event.x,event.y
	local endPt = cc.p(x,y)

	self:drawRect(endPt)
end

function getPositionLayer:touchEnd(event)
	local x,y = event.x,event.y
	local endPt = cc.p(x,y)

	self:drawRect(endPt)
end





