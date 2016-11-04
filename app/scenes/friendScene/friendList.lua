local friendList = class("friendList", function()
    return display.newNode()
end)

local cur_idx = nil
local cur_value = nil

function friendList:ctor()
	self.parentSize = cc.size(880, 607)

	local friendNumLabel = cc.ui.UILabel.new({UILabelType = 2, text = "好友数量：", size = 25})
	:addTo(self)
	:pos(80,self.parentSize.height-90)
	friendNumLabel:setColor(cc.c3b(150, 165, 170))
	local friendNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(self)
	:pos(80 + friendNumLabel:getContentSize().width,friendNumLabel:getPositionY())
	friendNum:setString(#FriendListData.."/50")
    if #FriendListData<50 then
        friendNum:setColor(cc.c3b(46, 127, 224))
    else
        friendNum:setColor(cc.c3b(230, 0, 18))
    end
    self.friendNumLabel  = friendNumLabel
    self.friendNum = friendNum


	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(40, 30, 790, 450),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)

    self:performWithDelay(function ()
    self:updateListView()
    end,0.01)
end
function friendList:sortFriendList()
	function sortfunc(a,b)
		if a.isOnline==b.isOnline then
			if a.level>b.level then
				return a.level>b.level
			end
		elseif a.isOnline>b.isOnline then
			return a.isOnline>b.isOnline
		end
	end
	table.sort(FriendListData,sortfunc)
end
function friendList:updateListView()
	self.listView:removeAllItems()

    if #FriendListData==0 then
        display.newSprite("#friend_img9.png")
        :addTo(self)
        :pos(self.parentSize.width/2, self.parentSize.height/2)

        local text = "您还没有好友，您可以通过“添加好友”找到您的朋友"
        cc.ui.UILabel.new({UILabelType = 2, text = text, size = 22, color = cc.c3b(128, 136, 150)})
        :addTo(self)
        :align(display.CENTER, self.parentSize.width/2, self.parentSize.height/2-100)

        self.friendNumLabel:setVisible(false)
        self.friendNum:setVisible(false)
        return
    end
    
    self:sortFriendList()
	for i,value in ipairs(FriendListData) do
		local item = self.listView:newItem()
        local content = display.newNode()

        --条
        local itemBar = cc.ui.UIPushButton.new({normal = "common2/com2_Img_7.png"},{scale9=true})
        :addTo(content)
        itemBar:setButtonSize(790, 120)
        itemBar:setTouchSwallowEnabled(false)
        -- itemBar:onButtonPressed(function(event) event.target:setScale(0.95) end)
        -- itemBar:onButtonRelease(function(event) event.target:setScale(1.0) end)
        itemBar:onButtonClicked(function(event) 
            cur_idx = i
            cur_value = value
            startLoading()
            local sendData = {}
            sendData.friChaId = value.characterId
            m_socket:SendRequest(json.encode(sendData), CMD_FRIEND_CARINFO, self, self.onGetFriendInfo)
            
        end)
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
		:addTo(content)
		:align(display.CENTER_LEFT,-270, -25)
		strengthLabel:setColor(MYFONT_COLOR)
		local strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
		:addTo(content)
		:align(display.CENTER_LEFT, strengthLabel:getPositionX()+strengthLabel:getContentSize().width, -25)
		strength:setString(value.strength)
		strength:setColor(cc.c3b(255, 255, 0))
		--在线离线状态
        local bar = display.newSprite("#friend_img4.png")
        :addTo(content)
        :pos(20,10)
		if value.isOnline==0 then
			cc.ui.UILabel.new({UILabelType = 2, text = "离线", size = 25, color =cc.c3b(128, 136, 150)})
            :addTo(bar)
            :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
		else
			cc.ui.UILabel.new({UILabelType = 2, text = "在线", size = 25, color =cc.c3b(86, 242, 31)})
            :addTo(bar)
            :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
		end

		--私聊
		local moreBt = cc.ui.UIPushButton.new("#friend_img7.png")
		:addTo(content)
		:pos(220,0)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
		:onButtonClicked(function(event)
            if chatLayer.Instance==nil then
                chatBoxLayer = g_chatLayer.new()
                :addTo(MainScene_Instance)

                -- chatType = 1
                -- chatBoxLayer.worldTabBt:setButtonEnabled(true)
                -- chatBoxLayer.legionTabBt:setButtonEnabled(true)
                -- chatBoxLayer.privateTabBt:setButtonEnabled(false)
                -- chatBoxLayer.worldTabBt:setLocalZOrder(0)
                -- chatBoxLayer.legionTabBt:setLocalZOrder(0)
                -- chatBoxLayer.privateTabBt:setLocalZOrder(1)
                -- chatBoxLayer:updateFirstListBar(3)
                -- chatBoxLayer:bPrivateChatUI(true)
                -- chatBoxLayer.ListView:removeAllItems()
                
                -- chatOffLineMsg = {}
                -- local node = MainScene_Instance.activityMenuBar.chatBt
                -- local node2 = event.target
                -- node:removeChildByTag(10)
                -- node2:removeChildByTag(100)

                -- chatBoxLayer.worldLabel:setColor(cc.c3b(129, 149, 152))
                -- chatBoxLayer.legionLabel:setColor(cc.c3b(129, 149, 152))
                -- chatBoxLayer.privateLabel:setColor(cc.c3b(204, 219, 226))
                
                -- --获取好友列表
                -- startLoading()
                -- local sendData = {}
                -- m_socket:SendRequest(json.encode(sendData), CMD_FRIEND_LIST, chatLayer.Instance, chatLayer.Instance.onFriendListResult)
            end
			
			end)
		local img = display.newSprite("#friend_img8.png")
		:addTo(moreBt)

        --删除好友
        local delBt = cc.ui.UIPushButton.new({normal="#friend_img11.png"}, {scale9 = true})
        :addTo(content)
        :pos(330,0)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "删除", size = 27, color =cc.c3b(60, 5, 8)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            startLoading()
            local sendData = {}
            sendData.friChaId = value.characterId
            m_socket:SendRequest(json.encode(sendData), CMD_DEL_FRIEND, self, self.onDelFriendResult)
            end)
        delBt:setButtonSize(81,78)


        item:addContent(content)
        item:setItemSize(790, 120)
        self.listView:addItem(item)
	end
	self.listView:reload()
end

function friendList:showMoreBox(value,carsData)
	self.masklayer =  UIMasklayer.new()
    :addTo(self:getParent():getParent(),10)
    local function  func()
        self.masklayer:removeSelf()
    end
    self.masklayer:setOnTouchEndedEvent(func)
	local msgBox = display.newScale9Sprite("#friend_img12.png",display.cx, 
		display.cy,
		cc.size(582, 332))
	:addTo(self.masklayer)
	self.masklayer:addHinder(msgBox)
    local tmpsize = msgBox:getContentSize()

	--成员头像
    local head = getCHeadBox(value.icon)
    :addTo(msgBox,1)
    :pos(80, tmpsize.height-70)
    head:setTouchSwallowEnabled(false)
    --等级
    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 22})
    :addTo(msgBox)
    :pos(140, tmpsize.height-45)
    level:setString("LV."..value.level)
    level:setColor(cc.c3b(255, 167, 72))
    --成员名字
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    :addTo(msgBox)
    :align(display.CENTER_LEFT, 230, level:getPositionY())
    name:setString(value.name)
    name:setColor(cc.c3b(199, 227, 234))
    --成员战斗力
    strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 25})
    :addTo(msgBox)
    :align(display.CENTER_LEFT,140, tmpsize.height-95)
    strengthLabel:setColor(MYFONT_COLOR)
    local strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :align(display.CENTER_LEFT, strengthLabel:getPositionX()+strengthLabel:getContentSize().width, strengthLabel:getPositionY())
    strength:setString(value.strength)
    strength:setColor(cc.c3b(255, 255, 0))


	-- --开始聊天
 --    local chatBt = cc.ui.UIPushButton.new({
 --    	normal = "common/commonBt1_1.png",
 --    	pressed = "common/commonBt1_2.png"
 --    	})
 --    :addTo(msgBox)
 --    :pos(msgBox:getContentSize().width/2,190)
 --    :onButtonClicked(function(event)
 --    	if chatBoxLayer~=nil then
 --    		chatBoxLayer:setLocalZOrder(1)
 --            chatBoxLayer.btFlag = 2
 --            transition.moveTo(chatBoxLayer.ChatBt, {x = chatBoxLayer.chatBox:getContentSize().width-10, time = 0.2,
 --                onComplete = function()
 --                    chatBoxLayer.ChatBt:setButtonImage("normal", "SingleImg/chat/closeChatBt.png")
 --                    chatBoxLayer.ChatBt:setButtonImage("pressed", "SingleImg/chat/closeChatBt.png")
 --                end
 --                })
 --            transition.moveTo(chatBoxLayer.chatBox, {x = chatBoxLayer.chatBox:getContentSize().width-5, time = 0.2})
 --            chatType = 1
 --            chatBoxLayer.worldTabBt:setButtonEnabled(true)
 --            chatBoxLayer.legionTabBt:setButtonEnabled(true)
 --            chatBoxLayer.privateTabBt:setButtonEnabled(false)
 --            chatBoxLayer.worldTabBt:setLocalZOrder(0)
 --            chatBoxLayer.legionTabBt:setLocalZOrder(0)
 --            chatBoxLayer.privateTabBt:setLocalZOrder(1)
 --            chatBoxLayer:updateFirstListBar(3)
 --            chatBoxLayer:updatePrivateListView()

 --            tarFriendCId = value.characterId
 --            self:performWithDelay(function ()
 --            chatBoxLayer.privateObj:setString(value.name)
 --            end,0.01)
 --        end
 --        end)
 --    local btImg  = display.newSprite("friend/friend_txt9.png")
 --    :addTo(chatBt)
    local bar = display.newSprite("#friend_img13.png")
    :addTo(msgBox)
    :pos(tmpsize.width/2, 150)

    for i,value in ipairs(carsData) do
        display.newSprite("Head/head_"..value.tmpId..".png")
        :addTo(bar)
        :pos(60+(i-1)*100, bar:getContentSize().height/2)
        :scale(0.7)
    end

	--删除
    delBt = cc.ui.UIPushButton.new("common/common_nBt10.png")
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2,50)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "删除好友", size = 27, color =cc.c3b(60, 5, 8)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
    	startLoading()
        local sendData = {}
        sendData.friChaId = value.characterId
        m_socket:SendRequest(json.encode(sendData), CMD_DEL_FRIEND, self, self.onDelFriendResult)
        end)
	
end
function friendList:onDelFriendResult(result)
	endLoading()
    if result.result==1 then
        if self.masklayer then
            self.masklayer:removeSelf()
        end
    	
        table.remove(FriendListData, cur_idx)
        self:updateListView()
        showTips("删除成功！")

        self.friendNum:setString(#FriendListData.."/50")
    else
    	showTips(result.msg)
    end
end
--获取好友战车信息
function friendList:onGetFriendInfo(result)
    if result.result==1 then
        self:showMoreBox(cur_value,result.data.car)
    else
        showTips(result.msg)
    end
end

return friendList