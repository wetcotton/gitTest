local addFriend = class("addFriend", function()
    return display.newNode()
end)

-- local displayList = {}
-- local cur_idx = 1

function addFriend:ctor()
	local parentSize = cc.size(880, 607)

	-- local bottom1 = display.newScale9Sprite("common/common_Frame11.png",parentSize.width/2, 
	-- 	parentSize.height/2,
	-- 	cc.size(830, 550),cc.rect(10,10,31,30))
	-- :addTo(self)

	-- local bottom2 = display.newScale9Sprite("common/common_Frame13.png",parentSize.width/2, 
	-- 	parentSize.height/2 - 35,
	-- 	cc.size(810, 460),cc.rect(10,10,30,30))
	-- :addTo(self)

	local inputBar = display.newScale9Sprite("#friend_img1.png",nil,nil,cc.size(400,65))
	:addTo(self)
	:pos(parentSize.width/2-100 ,parentSize.height-70)

	self.findInput = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(380, 40)})
    :addTo(inputBar)
    :pos(inputBar:getContentSize().width/2,inputBar:getContentSize().height/2)
    self.findInput:setPlaceHolder("输入关键字查找")
    -- self.findInput:setFontColor(display.COLOR_BLACK)
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
        	if self.findInput:getText()=="" then
	    		self:updateListView(1)
	    	end
            -- 从输入框返回
        end
    end
    self:performWithDelay(function ()
    --查找
    local findBt = cc.ui.UIPushButton.new("#friend_img2.png")
    :addTo(self)
    :pos(570,parentSize.height-70)
    :onButtonPressed(function(event) event.target:setScale(1.1) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
    	if self.findInput:getText()=="" then
    		showTips("请输入要查找的好友名字")
    		return
    	end
    	startLoading()
        local sendData = {}
        sendData.name = self.findInput:getText()
        m_socket:SendRequest(json.encode(sendData), CMD_FIND_FRIEND, self, self.onFindFriendResult)
        end)

    --换一组
    self.createLegionBt = cc.ui.UIPushButton.new("#friend_img3.png")
    :addTo(self)
    :pos(690,parentSize.height-70)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
		startLoading()
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_RECOM_FRIEND, self, self.onFriendRecomResult)
        end)
    end,0.01)


    self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(40, 30, 790, 450),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
    self:performWithDelay(function ()
    self:updateListView(1)
    end,0.01)
end

function addFriend:getDisplayList() --换一批
    displayList = {}
    if #RecomFriendData<=10 then
         displayList = RecomFriendData
    else
        for i=cur_idx,cur_idx+9 do
            if i>#RecomFriendList then
                cur_idx=1
                return
            end
            displayList[i] = RecomFriendData[i]
        end
        cur_idx = cur_idx+10
    end
end

function addFriend:updateListView(nFlag)
	self.listView:removeAllItems()

	local tmpData = {}
	if nFlag==1 then
		tmpData = RecomFriendData
	elseif nFlag==2 then
		tmpData[1] = findFriendData
	end
    
	for i,value in ipairs(tmpData) do
		local item = self.listView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(790, 120)
        self.listView:addItem(item)

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
        -- --在线离线状态
        -- local bar = display.newSprite("#friend_img4.png")
        -- :addTo(content)
        -- :pos(20,10)
        -- if value.isOnline==0 then
        --     cc.ui.UILabel.new({UILabelType = 2, text = "离线", size = 25, color =cc.c3b(128, 136, 150)})
        --     :addTo(bar)
        --     :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
        -- else
        --     cc.ui.UILabel.new({UILabelType = 2, text = "在线", size = 25, color =cc.c3b(86, 242, 31)})
        --     :addTo(bar)
        --     :align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2-2)
        -- end
		--加为好友
		local addBt = cc.ui.UIPushButton.new("common/common_nBt9.png")
        :addTo(itemBar)
        :pos(itemBar:getContentSize().width- 100,itemBar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "加为好友", size = 25, color = cc.c3b(0, 71, 32)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
		:onButtonClicked(function(event)
            if value.isApl==1 then
                showTips("该好友已申请")
                return
            end
            self.curAddBt = event.target
			startLoading()
            local sendData = {}
            sendData.friChaId = value.characterId
            m_socket:SendRequest(json.encode(sendData), CMD_ADD_FRIEND, self, self.onAddFriendResult)
			end)

        if value.isApl==1 then
            addBt:getButtonLabel():setString("已申请")
        end
        
	end
	self.listView:reload()
end
--查找好友
function addFriend:onFindFriendResult(result)
	endLoading()
    if result.result==1 then
    	self:updateListView(2)
    else
    	showTips(result.msg)
    end
end
--换一批
function addFriend:onFriendRecomResult(result)
	if result.result==1 then
		self:updateListView(1)
	else
		showTips(result.msg)
	end
end
--添加好友
function addFriend:onAddFriendResult(result)
	endLoading()
    if result.result==1 then
        -- showTips("申请成功！")
        -- self:updateListView(1)
        self.curAddBt:getButtonLabel():setString("已申请")
    else
    	showTips(result.msg)
    end
end

return addFriend