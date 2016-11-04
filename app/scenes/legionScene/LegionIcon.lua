
local LegionIcon=class("LegionIcon", function()
    return display.newLayer()
    end)
local masklayer
local mparentNode
local myFlag

function LegionIcon:ctor(parentNode,flag)
    myFlag = flag
	mparentNode = parentNode
	masklayer =  UIMasklayer.new()
	:addTo(parentNode,10)
	local function  func()
		masklayer:removeFromParent()
	end
	masklayer:setOnTouchEndedEvent(func)
	local legionIconBox = display.newScale9Sprite("common/common_Frame4.png",display.cx, 
        display.cy,
        cc.size(650, 350),cc.rect(20, 20, 63, 61))
	:addTo(masklayer)
    masklayer:addHinder(legionIconBox)
    self.masklayer = masklayer

    self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(15, 15, 620, 320),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(legionIconBox)
    self:updateListView()
end
function LegionIcon:updateListView()
	for i=1,1 do
        local item = self.listView:newItem()
        local content = display.newNode()
        for j=1,3 do
        	local icon = cc.ui.UIPushButton.new("SingleImg/legion/legionIcon/Legion_"..(j+10000)..".png")
        	:addTo(content)
        	:pos(-250+(j-1)*100,0)
        	:onButtonPressed(function(event)
        		event.target:setScale(0.95)
        		end)
        	:onButtonRelease(function(event)
        		event.target:setScale(1.0)
        		end)
        	:onButtonClicked(function(event)
        		masklayer:removeSelf()
                local path = "SingleImg/legion/legionIcon/Legion_"..(j+10000)..".png"
                local iconId = j+10000
                -- print(mparentNode:getChildByTag(LEGIONBOX_TAG):getChildByTag(INITLEGION_TAG))
                if myFlag==1 then
                    borderNode:getChildByTag(INITLEGION_TAG):selIconCallBack(path,iconId)
                elseif myFlag==2 then
                    borderNode:getChildByTag(LEGIONMANAGE_TAG):getChildByTag(103):selIconCallBack(path,iconId)
                end
        		end)
        	icon:setTouchSwallowEnabled(false)

        end
        item:addContent(content)
        item:setItemSize(620,100)
        self.listView:addItem(item)
    end
    self.listView:reload()
end


return LegionIcon