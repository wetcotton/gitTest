local settingLayer = require("app.scenes.legionScene.LegionManage_setting")
local applyLayer = require("app.scenes.legionScene.LegionManage_Apply")
local infoLayer = require("app.scenes.legionScene.LegionManage_Info")
local promoteLayer = require("app.scenes.legionScene.LegionManage_promote")
local LegionManage=class("LegionManage", function()
    return display.newNode()
    end)

function LegionManage:ctor()
	self.masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    self.masklayer:setOnTouchEndedEvent(func)

    local box = display.newSprite("SingleImg/messageBox/messageBox2.png")
	:addTo(self.masklayer,4)
	:pos(display.cx, display.cy-20)
	self.masklayer:addHinder(box)

	--关闭
	cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
	:addTo(box)
	:pos(box:getContentSize().width+30, box:getContentSize().height-38)
	:onButtonPressed(function(event) event.target:setScale(0.95) end)
	:onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)

		self:removeSelf()
		end)

	local dx = 60
	local dy = 265
    --入团申请
	self.menu1 = cc.ui.UIPushButton.new({
		normal = "#legion_img4.png",
		disabled = "#legion_img3.png"
		})
	:addTo(self.masklayer,5)
	:pos(260+dx, display.cy+dy)
	:onButtonRelease(function(event)
		end)
	:onButtonClicked(function(event)
		setMenuStatus(event.target)
		box:getChildByTag(101):setVisible(true)
		end)
	cc.ui.UILabel.new({UILabelType = 2, text = "入团申请", size = 27})
	:addTo(self.menu1, 0, 10)
	:align(display.CENTER, 0,-10)
	--成员信息
	self.menu2 = cc.ui.UIPushButton.new({
		normal = "#legion_img4.png",
		disabled = "#legion_img3.png"
		})
	:addTo(self.masklayer,2)
	:pos(445+dx, display.cy+dy)
	:onButtonClicked(function(event)
		setMenuStatus(event.target)
		box:getChildByTag(102):setVisible(true)
		end)
	cc.ui.UILabel.new({UILabelType = 2, text = "成员信息", size = 27})
	:addTo(self.menu2, 0, 10)
	:align(display.CENTER, 0,-10)
	--军团设置
	self.menu3 = cc.ui.UIPushButton.new({
		normal = "#legion_img4.png",
		disabled = "#legion_img3.png"
		})
	:addTo(self.masklayer,1)
	:pos(630+dx, display.cy+dy)
	:onButtonClicked(function(event)
		setMenuStatus(event.target)
		box:getChildByTag(103):setVisible(true)
		end)
	cc.ui.UILabel.new({UILabelType = 2, text = "军团设置", size = 27})
	:addTo(self.menu3, 0, 10)
	:align(display.CENTER, 0,-10)

	if myLegionInfo.rank==2 then --统帅才能军团提升
		--军团提升
		self.menu4 = cc.ui.UIPushButton.new({
			normal = "#legion_img4.png",
			disabled = "#legion_img3.png"
			})
		:addTo(self.masklayer,0)
		:pos(815+dx, display.cy+dy)
		:onButtonClicked(function(event)
			setMenuStatus(event.target)
			box:getChildByTag(104):setVisible(true)
			end)
		cc.ui.UILabel.new({UILabelType = 2, text = "军团提升", size = 27})
		:addTo(self.menu4, 0, 10)
		:align(display.CENTER, 0,-10)
	end
	
	function setMenuStatus(node)
		self.menu1:setButtonEnabled(true)
		self.menu1:setLocalZOrder(3)
		self.menu1:getChildByTag(10):setColor(cc.c3b(117, 134, 137))

		self.menu2:setButtonEnabled(true)
		self.menu2:setLocalZOrder(2)
		self.menu2:getChildByTag(10):setColor(cc.c3b(117, 134, 137))

		self.menu3:setButtonEnabled(true)
		self.menu3:setLocalZOrder(1)
		self.menu3:getChildByTag(10):setColor(cc.c3b(117, 134, 137))
		if self.menu4 then
			self.menu4:setButtonEnabled(true)
			self.menu4:setLocalZOrder(0)
			self.menu4:getChildByTag(10):setColor(cc.c3b(117, 134, 137))
		end

		box:getChildByTag(101):setVisible(false)
		box:getChildByTag(102):setVisible(false)
		box:getChildByTag(103):setVisible(false)
		if self.menu4 then
			box:getChildByTag(104):setVisible(false)
		end
		

		node:setButtonEnabled(false)
		node:setLocalZOrder(5)
		node:getChildByTag(10):setColor(cc.c3b(255, 221, 70))
	end

	applyLayer.new()
		:addTo(box,0,101)

	infoLayer.new()
		:addTo(box,0,102)

	self.setting = settingLayer.new()
		:addTo(box,0,103)

	if myLegionInfo.rank==2 then
		promoteLayer.new()
		:addTo(box,0,104)
	end
	

	setMenuStatus(self.menu1)
	box:getChildByTag(101):setVisible(true)
	
end

return LegionManage