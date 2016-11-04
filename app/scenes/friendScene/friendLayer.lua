local friendListNode = require("app.scenes.friendScene.friendList")
local addFriendNode = require("app.scenes.friendScene.addFriend")
local applyListNode = require("app.scenes.friendScene.FriendApplyList")

local friendLayer = class("friendLayer", function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

local msgBox

function friendLayer:ctor()
    display.addSpriteFrames("Image/friend_img.plist", "Image/friend_img.png")

	local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    local backBt =  cc.ui.UIPushButton.new({
    	normal = "common/common_BackBtn_1.png",
    	pressed = "common/common_BackBtn_2.png"
    	})
    :addTo(self,1)
    :pos(0,display.height )
    backBt:setAnchorPoint(0,1)
    backBt:onButtonClicked(function(event)
    	if #FriendApplyData==0 then
        	local node = self:getParent().activityMenuBar.friendBt
        	node:removeChildByTag(10)
    	end
        self:removeSelf()
    	end)

    msgBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-20,
        cc.size(870, 593),cc.rect(119, 127, 1, 1))
	:addTo(self,1)
 
	--好友列表
	self.menuTab = cc.ui.UIPushButton.new({
		normal = "common/common_nBt7_1.png",
		disabled = "common/common_nBt7_2.png"
		})
	:addTo(self,2)
	:pos(165, display.cy + msgBox:getContentSize().height/2 - 120)
	:onButtonClicked(function(event)
		setMenuState(event.target)
		friendListNode.new()
		:addTo(msgBox)
		end)
	self.menuTab:setButtonEnabled(false)
    cc.ui.UILabel.new({UILabelType = 2, text = "好友列表", size = 27, color = cc.c3b(95, 217, 255)})
    :addTo(self.menuTab,0,10)
    :align(display.CENTER, -20, 2)
	--添加好友
	self.menuTab1 = cc.ui.UIPushButton.new({
		normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
		})
	:addTo(self)
	:pos(165, display.cy + msgBox:getContentSize().height/2 - 200)
	:onButtonClicked(function(event)
		-- if next(RecomFriendData)==nil then
		-- 	startLoading()
	 --        local sendData = {}
	 --        m_socket:SendRequest(json.encode(sendData), CMD_RECOM_FRIEND, self, self.onFriendRecomResult)
	 --    else
	 --    	setMenuState(event.target)
		-- 	addFriendNode.new()
		-- 	:addTo(msgBox)
		-- end
        startLoading()
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_RECOM_FRIEND, self, self.onFriendRecomResult)
		
		end)
    cc.ui.UILabel.new({UILabelType = 2, text = "添加好友", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(self.menuTab1,0,10)
    :align(display.CENTER, -20, 2)
	--好友申请
	self.menuTab2 = cc.ui.UIPushButton.new({
		normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
		})
	:addTo(self)
	:pos(165, display.cy + msgBox:getContentSize().height/2 - 280)
	:onButtonClicked(function(event)
		startLoading()
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_FRIEND_APPLY, self, self.onFriendApplyResult)
		
		end)
    cc.ui.UILabel.new({UILabelType = 2, text = "申请列表", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(self.menuTab2,0,10)
    :align(display.CENTER, -20, 2)
	function setMenuState(node)
		self.menuTab:setButtonEnabled(true)
		self.menuTab1:setButtonEnabled(true)
		self.menuTab2:setButtonEnabled(true)
        self.menuTab:setLocalZOrder(0)
        self.menuTab1:setLocalZOrder(0)
        self.menuTab2:setLocalZOrder(0)
        self.menuTab:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        self.menuTab1:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        self.menuTab2:getChildByTag(10):setColor(cc.c3b(0, 149, 178))

		node:setButtonEnabled(false)
        node:setLocalZOrder(2)
        node:getChildByTag(10):setColor(cc.c3b(95, 217, 255))

		msgBox:removeAllChildren()
	end
	friendListNode.new()
		:addTo(msgBox)

	--红点
	if #FriendApplyData>0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(self.menuTab2,0,100)
        :pos(-74,25)
    end
end

function friendLayer:onFriendRecomResult(result)
	if result.result==1 then
		setMenuState(self.menuTab1)
		addFriendNode.new()
		:addTo(msgBox)
	else
		showTips(result.msg)
	end
end
function friendLayer:onFriendApplyResult(result)
	if result.result==1 then
		setMenuState(self.menuTab2)
		applyListNode.new()
		:addTo(msgBox)
	else
		showTips(result.msg)
	end
	
end

function friendLayer:onExit()
    display.removeSpriteFramesWithFile("Image/friend_img.plist", "Image/friend_img.png")
end

return friendLayer