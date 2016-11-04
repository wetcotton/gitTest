local LegionManage_Apply=class("LegionManage_Apply", function()
    return display.newNode()
    end)

local cur_pos=nil

function LegionManage_Apply:ctor()
	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 20, 895, 460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)

    self:updateListView()
end
function LegionManage_Apply:updateListView()
	self.listView:removeAllItems()

	local aplList = mLegionData["army"]["aplInfo"]
	if #aplList==0 then
        local parentSize = cc.size(933,516)
        display.newSprite("common2/com2_Img_24.png")
        :addTo(self)
        :pos(parentSize.width/2, parentSize.height/2)

        local text = "目前没有人员申请加入军团"
        cc.ui.UILabel.new({UILabelType = 2, text = text, size = 22, color = cc.c3b(128, 136, 150)})
        :addTo(self)
        :align(display.CENTER, parentSize.width/2, parentSize.height/2-100)
		return 
	end


    for i,value in pairs(aplList) do
        local item = self.listView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(950,120)

        local itemW,itemH = item:getItemSize()
        local bottomLine = display.newSprite("Block/sweep/sweep_img8.png")
            :addTo(content)
            :pos(0, -(itemH/2-7))
        
        --成员头像
        headIdx = memberData[value.icon].resId
        local head = display.newSprite("Head/headman_"..headIdx..".png")
        :addTo(content)
        :pos(120-itemW/2, 12)
        -- head:setScale(0.9)
        --成员等级
		local Level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
		:addTo(content)
		:align(display.CENTER_LEFT, 180-itemW/2, 85-itemH/2)
		Level:setString("LV:"..value.level)
		Level:setColor(cc.c3b(0, 183, 227))
		--成员名字
		local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
		:addTo(content)
		:align(display.CENTER_LEFT, 290-itemW/2, 85-itemH/2)
		name:setString(value.name)
		name:setColor(cc.c3b(151, 190, 204))
		--成员战斗力
		strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 25})
		:addTo(content)
		:align(display.CENTER_LEFT, 180-itemW/2, 35-itemH/2)
		strengthLabel:setColor(cc.c3b(123, 163, 172))
		local strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
		:addTo(content)
		:align(display.CENTER_LEFT, 180 + strengthLabel:getContentSize().width-itemW/2, 35-itemH/2)
		strength:setString(value.strength)
		strength:setColor(cc.c3b(240, 133, 5))
		--拒绝
		local refuseBt = createYellowRedBt("拒绝")
		:addTo(content)
		:pos(600-itemW/2, 0)
		:onButtonClicked(function(event)
			cur_pos = i
			startLoading()
            local sendData = {}
            sendData["armyId"] = mLegionData["army"]["id"]
            sendData["aplChaId"] = value.id
            sendData["result"] = 2
            m_socket:SendRequest(json.encode(sendData), CMD_DEAL_APPLY, self, self.onDealApplyLegionResult)
			end)
		--通过
		local passBt = createGreenBt("通过")
		:addTo(content)
		:pos(800-itemW/2,  0)
		:onButtonClicked(function(event)
			cur_pos = i
			startLoading()
            local sendData = {}
            sendData["armyId"] = mLegionData["army"]["id"]
            sendData["aplChaId"] = value.id
            sendData["result"] = 1
            m_socket:SendRequest(json.encode(sendData), CMD_DEAL_APPLY, self, self.onDealApplyLegionResult)
			end)
        
        self.listView:addItem(item)
    end
    self.listView:reload()
end

function LegionManage_Apply:onDealApplyLegionResult(result)
	endLoading()
    if result.result==1 then
        print("通过")
        local size = #mLegionData.mem + 1
        mLegionData.mem[size] = mLegionData["army"]["aplInfo"][cur_pos]
        mLegionData.mem[size].active = 0
        mLegionData.mem[size].contri = -1
        mLegionData.mem[size].rank = 0
        mLegionData.mem[size].fCnt = 0
        table.remove(mLegionData["army"]["aplInfo"], cur_pos)
        self:updateListView()
        if g_myLegionLayer then
            mLegionData.army.memNum = mLegionData.army.memNum + 1
            g_myLegionLayer:updateListView()
            g_myLegionLayer:reloadThisLayerAllData()
        end

    elseif result.result==2 then
        print("拒绝")
        table.remove(mLegionData["army"]["aplInfo"], cur_pos)
        self:updateListView()
    else
    	showTips(result.msg)
    end
end

return LegionManage_Apply