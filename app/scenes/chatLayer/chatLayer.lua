
chatLayer=class("chatLayer", function()
	local layer = display.newLayer("chatLayer")
	layer:setNodeEventEnabled(true)
	layer:setTouchSwallowEnabled(false)
    return layer
    end)
local wordFreeLabel
local diamondImg
local lastSendTime = 0
local selectFlag = 1
tarFriendCId = nil

chatLayer.Instance = nil
function chatLayer:ctor()
	display.addSpriteFrames("Image/Chat_img.plist", "Image/Chat_img.png")

	if getLocalGameDataBykey("chatRecordList")~=nil then
		chatRecordList = getLocalGameDataBykey("chatRecordList")
		for i,value in ipairs(chatRecordList.World) do
			if value.senderTmpId and value.senderTmpId<10000 and value.senderTmpId>=20000 then
			table.remove(chatRecordList.World, i)
			end
		end
		for i,value in ipairs(chatRecordList.Legion) do
			if value.senderTmpId and value.senderTmpId<10000 and value.senderTmpId>=20000 then
			table.remove(chatRecordList.Legion, i)
			end
		end
		for i,value in ipairs(chatRecordList.Private) do
			if value.senderTmpId and value.senderTmpId<10000 and value.senderTmpId>=20000 then
			table.remove(chatRecordList.Private, i)
			end
		end

	end

	local boxSize = cc.size(642, 684)
	self.chatBox = display.newScale9Sprite("#Chat_img19.png",0, display.cy, boxSize)
	self.chatBox:addTo(self,1)
	self.chatBox:pos(0,display.cy)
	self.chatBox:setAnchorPoint(1,0.5)
	self.chatBox:setTouchEnabled(true)
	self.chatBox:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self.chatBox:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
	local x, y, prevX, prevY = event.x, event.y, event.prevX, event.prevY
	 
	    if event.name == "began" then
	        print("layer began")
	    elseif event.name == "moved" then
	        print("layer moved")
	    elseif event.name == "ended" then
	        print("layer ended")
	    end
	        return true
	    end)

	local chatBox = self.chatBox
	-- local boxTop = display.newSprite("SingleImg/chat/boxtop.png")
	-- :addTo(self.chatBox)
	-- :pos(self.chatBox:getContentSize().width/2, self.chatBox:getContentSize().height-5)
	local boxBottom = display.newScale9Sprite("#Chat_img18.png",self.chatBox:getContentSize().width/2, 
		self.chatBox:getContentSize().height/2 - 53, cc.size(639, 580))
	:addTo(self.chatBox)


	local ChatBt = cc.ui.UIPushButton.new("#Chat_img4.png")
	-- ChatBt:setButtonSize(240, 60)
	ChatBt:addTo(self)
	ChatBt:pos(0,display.cy)
	ChatBt:setAnchorPoint(0,0.5)
	ChatBt:onButtonClicked(function(event)
		transition.moveTo(ChatBt, {x = -100, time = 0.2,
			onComplete = function()
				self:removeSelf()
			end
			})
		transition.moveTo(self.chatBox, {x = -100, time = 0.2})
		mainscenetopbar:setLocalZOrder(50)
		end)
	display.newSprite("#Chat_img14.png")
	:addTo(ChatBt)
	:pos(39,0)

	transition.moveTo(ChatBt, {x = (self.chatBox:getContentSize().width-15), time = 0.2})
	transition.moveTo(self.chatBox, {x = self.chatBox:getContentSize().width, time = 0.2})
	chatType = 3
	mainscenetopbar:setLocalZOrder(0)
	self.ChatBt = ChatBt
	
	--世界聊天
	self.worldTabBt = cc.ui.UIPushButton.new({
		normal="#Chat_img3.png",
        pressed = "#Chat_img3.png",
        disabled = "#Chat_img2.png"
		})
	:addTo(chatBox)
	:align(display.CENTER_TOP, 127, 671)
	:onButtonClicked(function(event)
		chatType = 3
		self.worldTabBt:setButtonEnabled(false)
		self.legionTabBt:setButtonEnabled(true)
		self.privateTabBt:setButtonEnabled(true)
		self.worldTabBt:setLocalZOrder(1)
		self.legionTabBt:setLocalZOrder(0)
		self.privateTabBt:setLocalZOrder(0)
		self:updateFirstListBar(1)
		self:bPrivateChatUI(false)
		self:updateWorldListView()

		self.worldLabel:setColor(cc.c3b(204, 219, 226))
		self.legionLabel:setColor(cc.c3b(129, 149, 152))
		self.privateLabel:setColor(cc.c3b(129, 149, 152))
		end)
	self.worldTab = display.newSprite("#Chat_img7.png")
	:addTo(self.worldTabBt)
	:pos(-40,-35)
	self.worldLabel = cc.ui.UILabel.new({UILabelType = 2, text = "世界", size = 28, color = cc.c3b(204, 219, 226)})
	:addTo(self.worldTabBt)
	:align(display.CENTER_LEFT, -10, -35)
	--军团聊天
	self.legionTabBt = cc.ui.UIPushButton.new({
		normal="#Chat_img3.png",
        pressed = "#Chat_img3.png",
        disabled = "#Chat_img2.png"
		})
	:addTo(chatBox)
	:align(display.CENTER_TOP, boxSize.width/2, 671)
	:onButtonClicked(function(event)
		if srv_userInfo["armyName"]=="" then
			showTips("加入军团后才可以在军团频道发言")
			return
		end
		chatType = 2
		self.worldTabBt:setButtonEnabled(true)
		self.legionTabBt:setButtonEnabled(false)
		self.privateTabBt:setButtonEnabled(true)
		self.worldTabBt:setLocalZOrder(0)
		self.legionTabBt:setLocalZOrder(1)
		self.privateTabBt:setLocalZOrder(0)
		self:updateFirstListBar(2)
		self:bPrivateChatUI(false)
		self:updateLegionListView()

		self.worldLabel:setColor(cc.c3b(129, 149, 152))
		self.legionLabel:setColor(cc.c3b(204, 219, 226))
		self.privateLabel:setColor(cc.c3b(129, 149, 152))
		end)
	self.legionTab = display.newSprite("#Chat_img6.png")
	:addTo(self.legionTabBt)
	:pos(-40,-35)
	self.legionLabel = cc.ui.UILabel.new({UILabelType = 2, text = "军团", size = 28, color = cc.c3b(129, 149, 152)})
	:addTo(self.legionTabBt)
	:align(display.CENTER_LEFT, -10, -35)
	--私聊
	self.privateTabBt = cc.ui.UIPushButton.new({
		normal="#Chat_img3.png",
        pressed = "#Chat_img3.png",
        disabled = "#Chat_img2.png"
		})
	:addTo(chatBox)
	:align(display.CENTER_TOP, boxSize.width-127, 671)
	:onButtonClicked(function(event)
		chatType = 1
		self.worldTabBt:setButtonEnabled(true)
		self.legionTabBt:setButtonEnabled(true)
		self.privateTabBt:setButtonEnabled(false)
		self.worldTabBt:setLocalZOrder(0)
		self.legionTabBt:setLocalZOrder(0)
		self.privateTabBt:setLocalZOrder(1)
		self:updateFirstListBar(3)
		self:bPrivateChatUI(true)
		self.ListView:removeAllItems()
		
		chatOffLineMsg = {}
		local node = MainScene_Instance.activityMenuBar.chatBt
        local node2 = event.target
        node:removeChildByTag(10)
        node2:removeChildByTag(100)

        self.worldLabel:setColor(cc.c3b(129, 149, 152))
		self.legionLabel:setColor(cc.c3b(129, 149, 152))
		self.privateLabel:setColor(cc.c3b(204, 219, 226))
		
		--获取好友列表
		startLoading()
	   	local sendData = {}
	    m_socket:SendRequest(json.encode(sendData), CMD_FRIEND_LIST, self, self.onFriendListResult)
	end)
	self.privateTab = display.newSprite("#Chat_img5.png")
	:addTo(self.privateTabBt)
	:pos(-40,-35)
	self.privateLabel = cc.ui.UILabel.new({UILabelType = 2, text = "私聊", size = 28, color = cc.c3b(129, 149, 152)})
	:addTo(self.privateTabBt)
	:align(display.CENTER_LEFT, -10, -35)
	--私聊红点
	if #chatOffLineMsg>0 or MainScene_Instance.activityMenuBar.chatBt:getChildByTag(10) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(self.privateTabBt,10,100)
        :pos(50,-15)
	end


	self.firstListBar = display.newScale9Sprite("#Chat_img12.png",chatBox:getContentSize().width/2, 
		chatBox:getContentSize().height-129)
	:addTo(chatBox)
	self.firstListBar:setLocalZOrder(1)

	self.worldTabBt:setButtonEnabled(false)
	self.worldTabBt:setLocalZOrder(2)

	self.ListView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(22,30*display.width/1920,900*display.width/1920,725*display.width/1920),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- scrollbarImgV = "bar.png"
        }
        -- :onTouch(handler(self, self.touchListener))
        :addTo(chatBox,1)

    self.worldTabBt:setButtonEnabled(false)
	self.legionTabBt:setButtonEnabled(true)
	self.privateTabBt:setButtonEnabled(true)
	self.worldTabBt:setLocalZOrder(1)
	self.legionTabBt:setLocalZOrder(0)
	self.privateTabBt:setLocalZOrder(0)
	self:updateFirstListBar(1)
	self:updateWorldListView()
end

function chatLayer:onEnter()
	chatLayer.Instance = self
	startLoading()
   	local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_CHAT_FREE_TIMES, self, self.onChatFreeTimes)
end

function chatLayer:updateFirstListBar(mType)
	self.firstListBar:removeAllChildren()
	if mType==1 then
		--输入框
		local input = cc.ui.UIInput.new({image = "EditBoxBg.png",listener = onEdit,size = cc.size(450, 45)})
	    :addTo(self.firstListBar)
	    :pos(240,self.firstListBar:getContentSize().height/2)
	    input:setMaxLength(20)
	    input:setTag(10)

		wordFreeLabel = cc.ui.UILabel.new({UILabelType = 2, text = "免费(20)", size = 25,color = cc.c3b(101, 120, 122)})
		:addTo(self.firstListBar)
		:align(display.CENTER_RIGHT ,470, 46)
		-- diamondImg = display.newSprite("common/common_Diamond.png")
		-- :addTo(freeBox)
		-- :pos(freeBox:getContentSize().width/2-20*display.width/1920, freeBox:getContentSize().height/2)
		-- diamondImg:setScale(0.7)
		-- diamondImg:setVisible(false)
		-- local diamondNum = cc.ui.UILabel.new({UILabelType = 2, text = "5", size = 20})
		-- :addTo(diamondImg)
		-- :pos(120*display.width/1920, diamondImg:getContentSize().height/2)
		-- diamondNum:setTag(10)
		-- diamondNum:setScale(1.4)
		if worldFreeTimes<=0 then
			-- diamondImg:setVisible(true)
			wordFreeLabel:setVisible(false)
		else
			-- diamondImg:setVisible(false)
			wordFreeLabel:setVisible(true)
			wordFreeLabel:setString("免费("..worldFreeTimes..")")
		end
		
		self:performWithDelay(function ()
			local sendMsgBt = cc.ui.UIPushButton.new({
				normal = "common/common_GBt1.png",
				pressed = "common/common_GBt2.png"})
			:addTo(self.firstListBar)
			:pos(self.firstListBar:getContentSize().width-90*display.width/1920-5, self.firstListBar:getContentSize().height/2-2)
			:onButtonPressed(function(event) event.target:getButtonLabel():setColor(cc.c3b(0, 69, 26)) end)
			:onButtonRelease(function(event) event.target:getButtonLabel():setColor(cc.c3b(116, 233, 128)) end)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "发送", size = 25,color = cc.c3b(116, 233, 128)}))
			:onButtonClicked(function(event)
				if srv_userInfo["level"] < 20 then
					showTips("战斗等级达到20级才能世界发言")
					return
				elseif input:getText()=="" then
					showTips("请输入要发送的文字")
					return
				elseif os.time() - lastSendTime<10 then
					showTips("说话太快，休息一会儿")
					return
				end
				lastSendTime = os.time()
				-- chatType = 3
			    local sendData = {}
			    sendData["msg"] = input:getText()
			    sendData["type"] = 3
			    m_socket:SendRequest(json.encode(sendData), CMD_SENT_CHATMSG, self, self.onSendChatMsg)
				end)
                           
            end, 0.01)
		
	elseif mType==2 then
		--输入框
		local input = cc.ui.UIInput.new({image = "EditBoxBg.png",listener = onEdit,size = cc.size(450, 45)})
	    :addTo(self.firstListBar)
	    :pos(240,self.firstListBar:getContentSize().height/2)
	    input:setMaxLength(20)
	    input:setTag(10)

	    self:performWithDelay(function ()
		local sendMsgBt = cc.ui.UIPushButton.new({
				normal = "common/common_GBt1.png",
				pressed = "common/common_GBt2.png"})
			:addTo(self.firstListBar)
			:pos(self.firstListBar:getContentSize().width-90*display.width/1920-5, self.firstListBar:getContentSize().height/2-2)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "发送", size = 25,color = cc.c3b(116, 233, 128)}))
			:onButtonPressed(function(event) event.target:getButtonLabel():setColor(cc.c3b(0, 69, 26)) end)
			:onButtonRelease(function(event) event.target:getButtonLabel():setColor(cc.c3b(116, 233, 128)) end)
		:onButtonClicked(function(event)
			if input:getText()=="" then
				showTips("请输入要发送的文字")
				return
			end
			-- chatType = 2
		    local sendData = {}
		    sendData["msg"] = input:getText()
		    sendData["type"] = 2
		    m_socket:SendRequest(json.encode(sendData), CMD_SENT_CHATMSG, self, self.onSendChatMsg)
			end)
		end,0.01)
	elseif mType==3 then
		selectFlag = 1
		self.privateObj = nil
		self:performWithDelay(function ()
			--输入框
			local input = cc.ui.UIInput.new({image = "EditBoxBg.png",listener = onEdit,size = cc.size(450, 45)})
		    :addTo(self.firstListBar)
		    :pos(240,self.firstListBar:getContentSize().height/2)
		    input:setMaxLength(20)
		    input:setTag(10)

			local sendMsgBt = cc.ui.UIPushButton.new({
				normal = "common/common_GBt1.png",
				pressed = "common/common_GBt2.png"})
			:addTo(self.firstListBar)
			:pos(self.firstListBar:getContentSize().width-90*display.width/1920-5, self.firstListBar:getContentSize().height/2-2)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "发送", size = 25,color = cc.c3b(116, 233, 128)}))
			:onButtonPressed(function(event) event.target:getButtonLabel():setColor(cc.c3b(0, 69, 26)) end)
			:onButtonRelease(function(event) event.target:getButtonLabel():setColor(cc.c3b(116, 233, 128)) end)
			:onButtonClicked(function(event)
				if tarFriendCId == nil then
					showTips("请选择聊天对象")
					return
				elseif input:getText()=="" then
					showTips("请输入要发送的文字")
					return
				else
					-- chatType = 1
				    local sendData = {}
				    sendData["msg"] = input:getText()
				    sendData["type"] = 1
				    sendData["tarCID"] = tarFriendCId
				    m_socket:SendRequest(json.encode(sendData), CMD_SENT_CHATMSG, self, self.onSendChatMsg)
				end
				
				end)

		end,0.01)
		
		

		

	end
end

function chatLayer:updateWorldListView()
	self.ListView:removeAllItems()
	if chatRecordList==nil then
		-- print("aa")
		return
	else
		if #chatRecordList.World==0 then
			-- print("bb")
			return
		else
			-- printTable(chatRecordList.World)
		end
	end
	for i,value in ipairs(chatRecordList.World) do
		-- printTable(value)
		local item = self.ListView:newItem()
        local content = display.newNode()
        item:addContent(content)
        
        

        local line = display.newScale9Sprite("#Chat_img13.png", nil, nil, cc.size(600,5))
        :addTo(content)
        :pos(0, -85*display.width/1920)

        local head = getCHeadBox(value.senderTmpId) 
	        :addTo(content)
        if value.senderTmpId==10000 then
	        head:pos((80-450)*display.width/1920, 20)
    	else
	        head:pos((80-450)*display.width/1920, 0)
	        -- head:setScale(0.6)
	        head:onButtonClicked(function(event)
	        	self:createAddFriendBox(value)
	        	end)
    	end
        
        local level
        if value.senderTmpId~=10000 then
	        level=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "1", size = 23,color = cc.c3b(87, 194, 222)})
	        :addTo(content)
	        :pos(-180, 26)
	        level:setString("LV"..value.senderLevel)
    	end

        local time=cc.ui.UILabel.new({UILabelType = 2, text = "时间", size = 23, color = cc.c3b(129, 149, 152)})
        :addTo(content)
        :pos(390*display.width/1920, 26)
        time:setAnchorPoint(0.5,0.5)
        time:setString(string.sub(value.time, 12, 16))

        local name=cc.ui.UILabel.new({UILabelType = 2, text = "名字", size = 23, color = cc.c3b(129, 149, 152)})
        :addTo(content)
        :pos(-80, 26)
        if value.senderTmpId==10000 then
        	name:setPositionX(-180)
        	name:setString("系统")
        else
        	name:setPositionX(-80)
        	name:setString(value.senderName)
    	end

        if type(value.msg)=="string" then
	        local word=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	        :addTo(content)
	        :pos(-190, 3)
	        word:setAnchorPoint(0,1)
	        word:setWidth(450)
	        word:setString(value.msg)
	        word:setColor(MYFONT_COLOR)

	        local labHeight = word:getContentSize().height
	        item:setItemSize(600, 50+labHeight)
        	self.ListView:addItem(item)

        	local itWidth,itHeight = item:getItemSize()
        	head:setPositionY(0)
        	time:setPositionY(itHeight/2-20)
        	word:setPositionY(itHeight/2-40)
        	line:setPositionY(-itHeight/2)
        	if value.senderTmpId==10000 then
	        	name:setPositionY(itHeight/2-20)
	        else
	        	name:setPositionY(itHeight/2-20)
	        	level:setPositionY(itHeight/2-20)
        	end
        	
	    else
	    	local vsBarSize = cc.size(45,44)
	    	local vsBt = cc.ui.UIPushButton.new("common/common_box5.png",{scale9 = true})
	    	:addTo(content)
	    	:align(display.CENTER_LEFT, (120-450 + 65)*display.width/1920, -40*display.width/1920)
	    	-- vsBt:setAnchorPoint(0,0.5)
	    	vsBt:onButtonClicked(function(event)
	            comData={}
	            comData["characterId"] = srv_userInfo.characterId
	            comData["recId"] = value.msg.pvpId
	            comData["idx"] = value.msg.idx
	            m_socket:SendRequest(json.encode(comData), CMD_GET_PLAYBACK, self, self.OnPVPPlaybackRet)
	    		end)
	    	local camera = display.newSprite("#Chat_img15.png")
	    	:addTo(vsBt)
	    	:pos(30,0)
	    	local name1 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	    	:addTo(vsBt)
	        :pos(camera:getPositionX()+camera:getContentSize().width/2, -2)
	        name1:setAnchorPoint(0,0.5)
	        name1:setColor(cc.c3b(234, 85, 20))
	        name1:setString(value.msg.name)
	        local vsImg = display.newSprite("#Chat_img16.png")
	        :addTo(vsBt)
	        :pos(name1:getPositionX()+name1:getContentSize().width -12 , -2)
	        vsImg:setAnchorPoint(0,0.5)
	        local name2 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	    	:addTo(vsBt)
	        :pos(vsImg:getPositionX()+vsImg:getContentSize().width - 12, -2)
	        name2:setAnchorPoint(0,0.5)
	        name2:setColor(cc.c3b(234, 85, 20))
	        name2:setString(value.msg.eName)

	        
	        -- local scale = (name1:getContentSize().width+vsImg:getContentSize().width+name2:getContentSize().width+20)/(vsBarSize.width)
	        local width = camera:getContentSize().width + name1:getContentSize().width +
	        	vsImg:getContentSize().width + name2:getContentSize().width
	        vsBt:setButtonSize(width, vsBarSize.height)

	        item:setItemSize(600, 133)
        	self.ListView:addItem(item)
        end


		
    end
    self.ListView:reload()
end

function chatLayer:updateLegionListView()
	self.ListView:removeAllItems()
	if chatRecordList==nil then
		return
	else
		if #chatRecordList.Legion==0 then
			return
		else
			-- printTable(chatRecordList.Legion)
		end
	end
	for i,value in ipairs(chatRecordList.Legion)  do
		local item = self.ListView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(900*display.width/1920, 170*display.width/1920)
        self.ListView:addItem(item)

        local line = display.newScale9Sprite("#Chat_img13.png", nil, nil, cc.size(600,5))
        :addTo(content)
        :pos(0, -85*display.width/1920)

        local head = getCHeadBox(value.senderTmpId)
        :addTo(content)
        :pos((80-450)*display.width/1920, 0)
        -- head:setScale(0.6)
        head:onButtonClicked(function(event)
        	self:createAddFriendBox(value)
        	end)
        local level=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "1", size = 23,color = cc.c3b(87, 194, 222)})
        :addTo(content)
        :pos(-180, 26)
        level:setString("LV"..value.senderLevel)

        local time=cc.ui.UILabel.new({UILabelType = 2, text = "时间", size = 23, color = cc.c3b(129, 149, 152)})
        :addTo(content)
        :pos(390*display.width/1920, 26)
        time:setAnchorPoint(0.5,0.5)
        time:setString(string.sub(value.time, 12, 16))

        local name=cc.ui.UILabel.new({UILabelType = 2, text = "名字", size = 23, color = cc.c3b(129, 149, 152)})
        :addTo(content)
        :pos(-80, 26)
        name:setString(value.senderName)

        local word=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(content)
        :pos((120-450 + 65)*display.width/1920, 5*display.width/1920)
        word:setAnchorPoint(0,1)
        word:setString(value.msg)
        word:setWidth(700*display.width/1920)
        word:setHeight(100*display.width/1920)
        word:setColor(MYFONT_COLOR)

		
    end
    self.ListView:reload()
end
function chatLayer:updatePrivateListView()
	self.ListView:removeAllItems()
	
	printTable(chatRecordList.Private)
	for i,value in ipairs(chatRecordList.Private) do
		if value.reptCId and (value.senderCId==srv_userInfo.characterId and value.reptCId==tarFriendCId)
			or (value.senderCId==tarFriendCId and value.reptCId==srv_userInfo.characterId)  then
			local item = self.ListView:newItem()
	        local content = display.newNode()
	        item:addContent(content)
	        item:setItemSize(249, 80)

	        local msgBar = display.newSprite("#Chat_img10.png")
	        :addTo(content)
	        :pos(5, 0)

	        local word = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	        :addTo(msgBar)
	        word:setString(value.msg)
	        word:setWidth(340)
	        word:setHeight(80)

	        if value.senderCId==srv_userInfo["characterId"] then
	        	msgBar:setOpacity(255*0.4)
	        	msgBar:setScaleX(-1)
	        	word:align(display.TOP_LEFT, msgBar:getContentSize().width - 10,msgBar:getContentSize().height - 8)
	        	word:setColor(cc.c3b(35, 44, 55))
	        	word:setScaleX(-1)
	    	else
		    	word:align(display.TOP_LEFT, 15,msgBar:getContentSize().height - 8)
	    	end
	    	self.ListView:addItem(item)
	    end
        
    end
    self.ListView:reload()
end
function chatLayer:bPrivateChatUI(bPrivate)
	if bPrivate then
		self.ListView:setViewRect(cc.rect(249,30*display.width/1920,373,484))
		self.prichatPanel = display.newScale9Sprite("#Chat_img8.png",449,259, cc.size(383,500))
		:addTo(self.chatBox)

		self.friendListView = cc.ui.UIListView.new {
	        -- bgColor = cc.c4b(200, 200, 200, 120),
	        -- bg = "sunset.png",
	        bgScale9 = true,
	        viewRect = cc.rect(17,20*display.width/1920,240,490),
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	        -- scrollbarImgV = "bar.png"
	        }
	        :addTo(self.chatBox,2)
	        :onTouch(handler(self, self.friendLvTouchListener))
	else
		self.ListView:setViewRect(cc.rect(22,30*display.width/1920,900*display.width/1920,725*display.width/1920))
		if self.prichatPanel then
			self.prichatPanel:removeSelf()
			self.prichatPanel = nil
		end
		if self.friendListView then
			self.friendListView:removeSelf()
			self.friendListView = nil
		end
	end
end
function chatLayer:friendLvTouchListener(event)
	local listView = event.listView
    if "clicked" == event.name then
    	if self.selectBg then
    		self.selectBg:removeSelf()
    		self.selectBg = display.newSprite("#Chat_img11.png")
        	:addTo(event.item:getChildByTag(event.item.CONTENT_Z_ORDER))

        	local value = FriendListData[event.itemPos]
        	tarFriendCId = value.characterId

        	self:updatePrivateListView()
    	end
    else
        print("event name:" .. event.name)
    end
end
function chatLayer:updateFriendList()
	self.friendListView:removeAllItems()

	for i,value in ipairs(FriendListData) do
		local item = self.friendListView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(240, 110)

        
        if i==1 then
        	tarFriendCId = value.characterId
        	self.selectBg = display.newSprite("#Chat_img11.png")
        	:addTo(content)
        end
        local head = getCHeadBox(value.icon)
        :addTo(content,1)
        :pos(-75, 0)
        head:setTouchSwallowEnabled(false)

        local level=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "1", size = 23,color = cc.c3b(87, 194, 222)})
        :addTo(content,1)
        :pos(-25, 26)
        level:setString("LV"..value.level)

        local bar = display.newSprite("common2/friend_img4.png")
        :addTo(content, 1)
        :pos(75,26)
		if value.isOnline==0 then
			cc.ui.UILabel.new({UILabelType = 2, text = "离线", size = 25, color =cc.c3b(128, 136, 150)})
            :addTo(bar)
            :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
		else
			cc.ui.UILabel.new({UILabelType = 2, text = "在线", size = 25, color =cc.c3b(86, 242, 31)})
            :addTo(bar)
            :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
		end

        local name=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 23, color = cc.c3b(129, 149, 152)})
        :addTo(content,1)
        :pos(-25, -10)
        name:setString(value.name)



        -- local time=cc.ui.UILabel.new({UILabelType = 2, text = "时间", size = 23, color = cc.c3b(129, 149, 152)})
        -- :addTo(content,1)
        -- :pos(390*display.width/1920, 26)
        -- time:setAnchorPoint(0.5,0.5)
        -- time:setString(string.sub(value.time, 12, 16))

        

		
        self.friendListView:addItem(item)
    end
    self.friendListView:reload()
end

-- function chatLayer:getCHeadBox(templateId)
-- 	if templateId==nil then
-- 		templateId = srv_userInfo["templateId"]
-- 	end
-- 	local headBox = cc.ui.UIPushButton.new("itemBox/cHeadBox.png")
--     local head = display.newSprite("Head/System_head_"..memberData[templateId].headResId..".png")
--     :addTo(headBox)
--     :pos(headBox:getContentSize().width/2, headBox:getContentSize().height/2)

--     return headBox
-- end

function chatLayer:onChatFreeTimes(result)
    if result.result==1 then
        print("世界聊天免费次数获得")
        worldFreeTimes = 20 - result.data
        if worldFreeTimes<=0 then
			-- diamondImg:setVisible(true)
			wordFreeLabel:setVisible(false)
		else
			-- diamondImg:setVisible(false)
			wordFreeLabel:setVisible(true)
			wordFreeLabel:setString("免费("..worldFreeTimes..")")
		end
    end
end

function chatLayer:onSendChatMsg(result)
	if result.result == 1 then
		print("发送成功")
		if chatType==3 then
			worldFreeTimes = worldFreeTimes-1
			if worldFreeTimes<=0 then
				-- diamondImg:setVisible(true)
				wordFreeLabel:setVisible(false)
				srv_userInfo["diamond"] = srv_userInfo["diamond"] - 5
				mainscenetopbar:setDiamond()
				--数据统计
    			luaStatBuy("聊天", BUY_TYPE_TALK, 1, "钻石", 5)
			else
				-- diamondImg:setVisible(false)
				wordFreeLabel:setVisible(true)
				wordFreeLabel:setString("免费("..worldFreeTimes..")")
			end
			
		end
		self.firstListBar:getChildByTag(10):setText("")
	else
		showTips("发送失败")
	end
end
local time = 0

function chatLayer:onPushWorldChat(result)
	if result.result==1 then
		print("收到世界消息！")
		if chatType==3 then
			self:updateWorldListView()
		end
		
	end
end
function chatLayer:onPushLegionChat(result)
	if result.result==1 then
		print("收到军团消息！")
		if chatType==2 then
			print("ccc")
			self:updateLegionListView()
		end
	end
end
function chatLayer:onPushPrivateChat(result)
	if result.result==1 then
		print("收到私聊消息！")
		if chatType==1 then
			self:updatePrivateListView()
		end
	end
end
function chatLayer:onPushVideoChat(result)
	if result.result==1 then
		print("收到视频分享消息！")
		
	end
end
--获取回放信息
function chatLayer:OnPVPPlaybackRet(result)
    if tonumber(result["result"]) == 1 then
    	-- printTable(result)
        CurFightBattleType = FightBattleType.kType_PVP
        IsPlayback = true
        --RandomSeedPool = result["data"]["fdetail"]["randomSeeds"]
        RandomSeed = result["data"]["fdetail"]["randomSeed"]
        BattleData["members"] = {}
        BattleData["enemys"] = {}
        BattleData["defName"] = result["data"]["defName"]
        BattleData["eName"] = result["data"]["enemyName"]
        BattleData["eStrength"] = result["data"]["fdetail"]["eStrength"]
        BattleData["strength"] = result["data"]["fdetail"]["strength"]
        BattleData["members"] = result["data"]["fdetail"]["members"]
        BattleData["enemys"] = result["data"]["fdetail"]["enemys"]
        BattleData["type"] = result.data.type --type==1进攻方，type==2防守方
        app:enterScene("LoadingScene",{SceneType.Type_Battle})
    elseif result["result"]==-1 then
    	showTips("对战记录已过期")
    end 
end

function chatLayer:createAddFriendBox(value)
	self.friendMasklayer =  UIMasklayer.new()
    :addTo(display.getRunningScene(),52)
	local addFriendBox = display.newSprite("SingleImg/chat/addFriendBox.png", display.cx, display.cy)
	:addTo(self.friendMasklayer)
    local function  func()
    	self.friendMasklayer:removeSelf()
    end
    self.friendMasklayer:setOnTouchEndedEvent(func)
    self.friendMasklayer:addHinder(addFriendBox)

    local head = getCHeadBox(value.senderTmpId)
        :addTo(addFriendBox)
        :pos(140*display.width/1920, 285*display.width/1920)
        -- head:setScale(0.6)
    local level=cc.ui.UILabel.new({UILabelType = 2, text = "1", size = 25})
        :addTo(addFriendBox)
        :pos(317*display.width/1920, 247*display.width/1920)
        level:setAnchorPoint(0.5,0.5)
        level:setString(value.senderLevel)

    local name=cc.ui.UILabel.new({UILabelType = 2, text = "名字", size = 25})
        :addTo(addFriendBox)
        :pos(260*display.width/1920, 330*display.width/1920)
        name:setAnchorPoint(0,0.5)
        name:setString(value.senderName)
        name:setColor(cc.c3b(255, 255, 0))

    if value.senderCId == srv_userInfo["characterId"] or value.senderCId==1000000 then
		return
	end

    local addFriendBt = cc.ui.UIPushButton.new({
    	normal="SingleImg/chat/addFriendBt.png",
        pressed = "SingleImg/chat/addFriendBt_down.png",
    	})
    :addTo(addFriendBox)
    :pos(addFriendBox:getContentSize().width/2, 120*display.width/1920)
    :onButtonClicked(function(event)
        local sendData = {}
        sendData.friChaId = value.senderCId
        m_socket:SendRequest(json.encode(sendData), CMD_ADD_FRIEND, self, self.onAddFriendResult)
    	end)

    --私聊
  --  	local privateBt = cc.ui.UIPushButton.new({
  --   	normal="SingleImg/chat/privateChatBt.png",
  --       pressed = "SingleImg/chat/privateChatBt_down.png",
  --   	})
  --  	:addTo(addFriendBox)
  --  	:pos(addFriendBox:getContentSize().width-210*display.width/1920,120*display.width/1920)
  --  	:onButtonClicked(function(event)
  --  		self.worldTabBt:setButtonEnabled(true)
		-- self.legionTabBt:setButtonEnabled(true)
		-- self.privateTabBt:setButtonEnabled(false)
		-- self.worldTabBt:setLocalZOrder(0)
		-- self.legionTabBt:setLocalZOrder(0)
		-- self.privateTabBt:setLocalZOrder(1)
		-- self:updateFirstListBar(3)
		-- self:updatePrivateListView()
		-- self.friendMasklayer:removeSelf()
		-- -- self:performWithDelay(function ()
		-- -- 	self.privateObj:setString(value.senderName)
		-- -- 	end,0.01)
		-- tarFriendCId = value.senderCId
		-- chatType = 1
  --  		end)
end
--好友列表
function chatLayer:onFriendListResult(result)
	if result.result==1 then
		self:updateFriendList()
		self:updatePrivateListView()
	else
		showTips(result.msg)
	end
end
function chatLayer:onAddFriendResult(result)
    if result.result==1 then
        showTips("申请成功！")
        self.friendMasklayer:removeSelf()
    else
    	showTips(result.msg)
    end
end

function chatLayer:onExit()
	chatLayer.Instance = nil
	display.removeSpriteFramesWithFile("Image/Chat_img.plist", "Image/Chat_img.png")
end


return chatLayer