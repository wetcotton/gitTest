local FriendApplyList = class("FriendApplyList", function()
    return display.newNode()
end)

local cur_idx
local cur_value

function FriendApplyList:ctor()
	local parentSize = cc.size(880, 607)
    self.parentSize =  parentSize


	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(40, 30, 790, 520),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
    self:performWithDelay(function ()
    self:updateListView()
    end,0.01)
end

function FriendApplyList:updateListView()
	self.listView:removeAllItems()

    if #FriendApplyData==0 then
        display.newSprite("#friend_img9.png")
        :addTo(self)
        :pos(self.parentSize.width/2, self.parentSize.height/2)

        local text = "您没有好友申请"
        cc.ui.UILabel.new({UILabelType = 2, text = text, size = 22, color = cc.c3b(128, 136, 150)})
        :addTo(self)
        :align(display.CENTER, self.parentSize.width/2, self.parentSize.height/2-100)

        return
    end
    
	for i,value in ipairs(FriendApplyData) do
		local item = self.listView:newItem()
        local content = display.newNode()

        --条
        local itemBar = display.newScale9Sprite("common2/com2_Img_7.png",0, 
        0,
        cc.size(790, 120))
        :addTo(content)
        --成员头像
        local head = getCHeadBox(value.icon)
        :addTo(content,1)
        :pos(-330, 0)
        head:setTouchSwallowEnabled(false)
        --等级
        local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 22})
        :addTo(content)
        :pos(-270, 25)
        level:setString("LV."..value.level)
        level:setColor(cc.c3b(255, 167, 72))
        --成员名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
        :addTo(content)
        :align(display.CENTER_LEFT, -180, 25)
        name:setString(value.name)
        name:setColor(cc.c3b(199, 227, 234))
        --成员战斗力
        strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 25})
        :addTo(itemBar)
        :align(display.CENTER_LEFT, 120, 35)
        strengthLabel:setColor(MYFONT_COLOR)
        local strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :addTo(itemBar)
        :align(display.CENTER_LEFT, 120 + strengthLabel:getContentSize().width, 35)
        strength:setString(value.strength)
        strength:setColor(cc.c3b(255, 255, 0))
		--拒绝
		local refuseBt = cc.ui.UIPushButton.new("#friend_img11.png")
		:addTo(itemBar)
		:pos(itemBar:getContentSize().width - 270,itemBar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "拒绝", size = 27, color =cc.c3b(60, 5, 8)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
		:onButtonClicked(function(event)
			cur_idx = i
            cur_value= value
            startLoading()
            local sendData = {}
            sendData.appliantId = value.characterId
            sendData.result = 0
            m_socket:SendRequest(json.encode(sendData), CMD_DEAL_FRIEND, self, self.onDealFriendResult)
			end)

		--通过
		local passBt = cc.ui.UIPushButton.new("#friend_img10.png")
		:addTo(itemBar)
		:pos(itemBar:getContentSize().width - 100,itemBar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "同意", size = 27, color =cc.c3b(0, 71, 32)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
		:onButtonClicked(function(event)
			cur_idx = i
            cur_value= value
            startLoading()
            local sendData = {}
            sendData.appliantId = value.characterId
            sendData.result = 1
            m_socket:SendRequest(json.encode(sendData), CMD_DEAL_FRIEND, self, self.onDealFriendResult)
			end)



        item:addContent(content)
        item:setItemSize(790, 120)
        self.listView:addItem(item)
	end
	self.listView:reload()
end
--申请处理
function FriendApplyList:onDealFriendResult(result)
	endLoading()
    if result.result==1 then
        print("通过申请")
        cur_value.isOnline = 0
        table.insert(FriendListData,cur_value)
        table.remove(FriendApplyData, cur_idx)
        self:updateListView()
        if #FriendApplyData==0 then
        	self:getParent():getParent().menuTab2:getChildByTag(100):removeSelf()
    	end
    elseif result.result==2 then
        print("拒绝申请")
        table.remove(FriendApplyData, cur_idx)
        self:updateListView()
        if #FriendApplyData==0 then
        	self:getParent():getParent().menuTab2:getChildByTag(100):removeSelf()
    	end
    else
    	showTips(result.msg)
    end
end

return FriendApplyList