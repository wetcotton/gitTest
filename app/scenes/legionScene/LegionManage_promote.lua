
local LegionManage_promote=class("LegionManage_promote", function()
    return display.newNode()
    end)

function LegionManage_promote:ctor()
	self:reloadData()
end

function LegionManage_promote:reloadData()
	self:removeAllChildren()
	local oldValue = legionLevelData[mLegionData.army.level]
	local newValue = legionLevelData[mLegionData.army.level+1]
	if newValue==nil then
		showTips("已提升至最高等级。")
		return
	end

	local leftbar = display.newScale9Sprite("#legion_img8.png",280, 
		220,
		cc.size(472, 470),cc.rect(10,10,31,30))
	:addTo(self)
	--军团等级
	local dny = 70
	local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "军团等级：", size = 25})
	:addTo(leftbar)
	:pos(20,45+76*4+dny)
	label1:setColor(cc.c3b(128, 156, 170))
	local oldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(200,45+76*4+dny)
	oldNum:setColor(cc.c3b(128, 156, 170))
	oldNum:setString(oldValue.level)
	local newNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(380,45+76*4+dny)
	newNum:setColor(cc.c3b(117, 242, 31))
	newNum:setString(newValue.level)
	--成员上线
	local label2 = cc.ui.UILabel.new({UILabelType = 2, text = "成员上限：", size = 25})
	:addTo(leftbar)
	:pos(20,45+76*3+dny)
	label2:setColor(cc.c3b(128, 156, 170))
	local oldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(200,45+76*3+dny)
	oldNum:setColor(cc.c3b(128, 156, 170))
	oldNum:setString(oldValue.maxMemNum)
	local newNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(380,45+76*3+dny)
	newNum:setColor(cc.c3b(117, 242, 31))
	newNum:setString(newValue.maxMemNum)
	--字符串分割
	local oldEnergyArr = lua_string_split(oldValue.energy,"|")
	local newEnergyArr = lua_string_split(newValue.energy,"|")
	--免费建设燃油
	local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "免费建设燃油：", size = 25})
	:addTo(leftbar)
	:pos(20,45+76*2+dny)
	label3:setColor(cc.c3b(128, 156, 170))
	local oldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(200,45+76*2+dny)
	oldNum:setColor(cc.c3b(128, 156, 170))
	oldNum:setString(oldEnergyArr[1])
	local newNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(380,45+76*2+dny)
	newNum:setColor(cc.c3b(117, 242, 31))
	newNum:setString(newEnergyArr[1])
	--钻石建设燃油
	local label4 = cc.ui.UILabel.new({UILabelType = 2, text = "钻石建设燃油：", size = 25})
	:addTo(leftbar)
	:pos(20,45+76+dny)
	label4:setColor(cc.c3b(128, 156, 170))
	local oldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(200,45+76+dny)
	oldNum:setColor(cc.c3b(128, 156, 170))
	oldNum:setString(oldEnergyArr[2])
	local newNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(380,45+76+dny)
	newNum:setColor(cc.c3b(117, 242, 31))
	newNum:setString(newEnergyArr[2])
	--团本属性加成
	local label5 = cc.ui.UILabel.new({UILabelType = 2, text = "团本属性加成：", size = 25})
	:addTo(leftbar)
	:pos(20,45+dny)
	label5:setColor(cc.c3b(128, 156, 170))
	local oldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(200,45+dny)
	oldNum:setColor(cc.c3b(128, 156, 170))
	oldNum:setString(oldValue.level.."%")
	local newNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(leftbar)
	:pos(380,45+dny)
	newNum:setColor(cc.c3b(117, 242, 31))
	newNum:setString(newValue.level.."%")

	display.newSprite("#legion_img11.png")
	:addTo(leftbar)
	:pos(leftbar:getContentSize().width/2 + 70, 270)

	---------------------
	--右边
	local title = cc.ui.UILabel.new({UILabelType = 2, text = "升级消耗", size = 33})
	:addTo(self)
	:align(display.CENTER, borderSize.width/4*3-80, 380)
	title:setColor(cc.c3b(151, 190, 204))
	--活跃度
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "活跃度", size = 30})
	:addTo(self)
	:pos(570, 270)
	label:setColor(cc.c3b(151, 190, 204))
	display.newSprite("#legion_img29.png")
	:addTo(self)
	:pos(label:getPositionX() + 120, label:getPositionY())
	local bar = display.newScale9Sprite("#legion_img8.png",borderSize.width/4*3-15, 270,
		cc.size(179, 40))
	:addTo(self)
	local costNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(bar)
	:align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-2)
	costNum:setColor(cc.c3b(255, 221, 70))
	costNum:setString(oldValue.costActive)
	--建设值
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "建设值", size = 30})
	:addTo(self)
	:pos(570, 190)
	label:setColor(cc.c3b(151, 190, 204))
	display.newSprite("#legion_img30.png")
	:addTo(self)
	:pos(label:getPositionX() + 120, label:getPositionY())
	local bar = display.newScale9Sprite("#legion_img8.png",borderSize.width/4*3-15, 190,
		cc.size(179, 40))
	:addTo(self)
	local costNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(bar)
	:align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-2)
	costNum:setColor(cc.c3b(255, 221, 70))
	costNum:setString(oldValue.costContion)

	--确认修改
	local confirmBt = createGreenBt("确认提升")
	:addTo(self)
	:pos(borderSize.width/4*3-80,80)
	:onButtonClicked(function(event)
		startLoading()
		local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_PROMOTE_LEGION, self, self.onPromoteLegionResult)
		end)
end

function LegionManage_promote:onPromoteLegionResult(result)
	endLoading()
	if result.result==1 then
		showTips("提升成功！")
		mLegionData.army.level = mLegionData.army.level + 1
		self:reloadData()
		if g_myLegionLayer then
            g_myLegionLayer:reloadThisLayerAllData()
        end
	else
		showTips(result.msg)
	end

end

return LegionManage_promote