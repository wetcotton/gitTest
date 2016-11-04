--
-- Author: Jun Jiang
-- Date: 2014-12-05 16:10:39
--
UIMasklayer = class("UIMasklayer",function()
    return display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
end)

function UIMasklayer:ctor(params)

      local colorBg = display.newSprite("common/colorbg.png")
      :addTo(self,-1)
      colorBg:setAnchorPoint(0,0)
      colorBg:setScaleX(display.width/colorBg:getContentSize().width)
      colorBg:setScaleY(display.height/colorBg:getContentSize().height) 

    if nil==params then
        params = {}
    end
    --遮挡集合
    self._hinderList = params.hinderList or {}
    --忽略不可见节点
    self.bIgnoreInvisible = params.bIgnoreInvisible or false
    --永久存在
    self.bAlwaysExist = params.bAlwaysExist or false
    --颜色
    if nil~=params.color then
        self:setColor(params.color)
        self:setOpacity(params.color[4])
    end

    if params._touchCall~=nil and type(params._touchCall) == "function" then
        self._touchCall = params._touchCall
    else
        self._touchCall = function ()
            self:hide()
        end
    end

    --事件
    S_SIZE(self,display.width,display.height)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            if self:onTouchBegan(cc.p(event.x,event.y)) then
                return true
            end
            return false

        elseif event.name == "moved" then
            self:onTouchMoved(cc.p(event.x,event.y))
        elseif event.name == "ended" then
            self:onTouchEnded(cc.p(event.x,event.y))
        end

    end)
end

function UIMasklayer:onTouchBegan(point)
    if self.bAlwaysExist then
        return false
    end

    local function isCascadeVisible(pWnd)
        if false==pWnd:isVisible() then
            return false
        else
            local parent = pWnd:getParent()
            if nil==parent then
                return true
            else
                return isCascadeVisible(parent)
            end
        end
    end
    
	--遮盖物
    if self.bIgnoreInvisible then
        for i = 1,#(self._hinderList) do
            if self._hinderList[i] and isCascadeVisible(self._hinderList[i]) and self._hinderList[i]:MyHitTest(point) then
                return false
            end
        end
    else
        for i = 1,#(self._hinderList) do
            if self._hinderList[i] and self._hinderList[i]:MyHitTest(point) then
                return false
            end
        end
    end

    return true
end

function UIMasklayer:onTouchMoved(point)
	-- body
end

function UIMasklayer:onTouchEnded(point)
    self._touchCall()
    if nil~=self.onTouchEndedEvent then
        self.onTouchEndedEvent()
    end
end

function UIMasklayer:setOnTouchEndedEvent(fun)
    self.onTouchEndedEvent = fun
end

--清空全部遮挡
function UIMasklayer:removeHinderAll()
    self._hinderList = {}
end

--添加遮挡
function UIMasklayer:addHinder(hinder)
    self._hinderList[#self._hinderList+1] = hinder
end

function UIMasklayer:setAlwaysExist(bBool)
    self.bAlwaysExist = bBool
end

function UIMasklayer:setTouchCallback(_call)
    self._touchCall = _call
end