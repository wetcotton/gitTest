
local activityMenuBar = class("activityMenuBar", function()
    local layer = display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)
function activityMenuBar:getMenuPos(nIdx)
	local menuPos = {x=display.cx- 60 + 92*(nIdx-1), y = display.height - 110}
	return menuPos
end

activityMenuLayerTag = {}
activityMenuLayerTag.signInTag = 139001
activityMenuLayerTag.taskTag = 139002
activityMenuLayerTag.achieveTag = 139003
g_OLHandle = nil --定时器handle
g_onlineLabel = nil --在线时间
g_OLretNode = nil
g_awardLabel = nil --领取
g_awardNode = nil


g_menuTab_top = {}

function activityMenuBar:ctor()
	self.onlineEff = nil

	menuPos = {
		{x=50, y = display.height/2+100},
		{x=50, y = display.height/2},
		{x=50, y = display.height/2-100},
	}
	--邮件
	self.mailBt = cc.ui.UIPushButton.new("#MainUI_img25.png")
	:addTo(self)
	:pos(menuPos[1].x, menuPos[1].y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		local layer = MailLayer.new()
        layer:addTo(display.getRunningScene(),51)
		end)

	--好友
	self.friendBt = cc.ui.UIPushButton.new("#MainUI_img26.png")
	:addTo(self)
	:pos(menuPos[2].x, menuPos[2].y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		local sendData = {}
		m_socket:SendRequest(json.encode(sendData), CMD_FRIEND_LIST, self, self.onFriendListResult)
		-- g_foundAct.new()
		-- :addTo(MainScene_Instance)
		end)

	--聊天
	self.chatBt = cc.ui.UIPushButton.new("#MainUI_img27.png")
	:addTo(self)
	:pos(menuPos[3].x, menuPos[3].y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		--聊天
	    chatBoxLayer = g_chatLayer.new()
	    :addTo(MainScene_Instance)
		end)
	

	--在线时间奖励（该功能已关闭）
	-- self.onlineActivity = cc.ui.UIPushButton.new("#MainUI_img21.png")
	-- :addTo(self)
	-- :pos(self:getMenuPos(0).x, self:getMenuPos(0).y)
	-- :onButtonPressed(function(event)
	-- 	event.target:setScale(0.95)
	-- 	end)
	-- :onButtonRelease(function(event)
	-- 	event.target:setScale(1.0)
	-- 	end)
	-- :onButtonClicked(function(event)
	-- 	local  srvData, locData =  self:getSrvOneWeekTask()
	-- 	local  srvData2, locData2 =  self:getSrvOneWeekTask2()
	-- 	if srvData~=nil then
	-- 		TaskMgr:ReqSubmit(srvData.id)
	-- 		self.onlineCurRewards = {}
	-- 		if locData.gold~=0 then
	-- 			table.insert(self.onlineCurRewards, {templateID=GAINBOXTPLID_GOLD, num=locData.gold})
	-- 		end
	-- 		local outputItems = locData.rewardItems
	-- 	    outputItems = lua_string_split(outputItems,"|")
	-- 	    for i=1,#outputItems do
	-- 	        local item = lua_string_split(outputItems[i],"#")
	-- 	        table.insert(self.onlineCurRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
	-- 	    end
	-- 	elseif srvData2~=nil then
	-- 		self.onlineCurRewards = {}
	-- 		if locData2.gold~=0 then
	-- 			table.insert(self.onlineCurRewards, {templateID=GAINBOXTPLID_GOLD, num=locData2.gold})
	-- 		end
	-- 		local outputItems = locData2.rewardItems
	-- 	    outputItems = lua_string_split(outputItems,"|")
	-- 	    for i=1,#outputItems do
	-- 	        local item = lua_string_split(outputItems[i],"#")
	-- 	        table.insert(self.onlineCurRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
	-- 	    end
	-- 		showItemListBox(self.onlineCurRewards)
	-- 	else
	-- 		showTips("未到领奖时间")
	-- 	end
	-- 	end)
	-- --在线奖励倒计时
	-- if not g_isOnlineSeqSend then
	-- 	self.onlineActivity:setVisible(false)
	-- else
	-- 	g_onlineLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 20})
	-- 	:addTo(self.onlineActivity,3)
	-- 	:align(display.CENTER, 0, -20)
	-- 	g_onlineLabel:setVisible(false)
	-- 	g_OLretNode = setLabelStroke(g_onlineLabel,20,nil,2,nil,nil,nil,"fonts/slicker.ttf")
	-- 	setLabelVisible(g_OLretNode, false)
	-- 	if g_ActOnLineListTs then
	-- 		g_onlineLabel:setString(GetTimeStr(g_ActOnLineListTs))
	-- 		setLabelStrokeString(g_onlineLabel, g_OLretNode)
	-- 		if g_OLHandle==nil then
	-- 			g_OLHandle = scheduler.scheduleGlobal(handler(self, self.OLonInterval), 1)
	-- 		end
	-- 	end

	-- 	g_awardLabel = cc.ui.UILabel.new({UILabelType = 2, text = "领取", size = 20})
	-- 	:addTo(self.onlineActivity,3)
	-- 	:align(display.CENTER, 0, -20)
	-- 	g_awardLabel:setVisible(false)

	-- 	g_awardNode = setLabelStroke(g_awardLabel,20,nil,2,nil,nil,nil,nil,true)
	-- 	setLabelVisible(g_awardNode, false)
	-- end

	--基金
	self.fundBt = cc.ui.UIPushButton.new("#MainUI_img21.png")
	:addTo(self)
	:pos(self:getMenuPos(0).x, self:getMenuPos(0).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		-- foundAct.new()
		-- :addTo(display.getRunningScene())
		g_fundLayer.new()
		:addTo(display.getRunningScene())
		end)

	

	--优惠
	self.discountBt = cc.ui.UIPushButton.new("#MainUI_img19.png")
	:addTo(self)
	:pos(self:getMenuPos(1).x, self:getMenuPos(1).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		--local xx,g_discountLayer = reloadLuaFile("app.scenes.discountLayer")
		g_discountLayer.new()
			:addTo(display.getRunningScene())
		end)
	youhuiEff(self.discountBt)
	--充值
	self.rechargeBt = cc.ui.UIPushButton.new("#MainUI_img18.png")
	:addTo(self)
	:pos(self:getMenuPos(2).x, self:getMenuPos(2).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		DCEvent.onEvent("主界面点击充值")
		g_recharge.new()
		:addTo(display.getRunningScene())
		-- gotoSkillScene()
		end)
	rechargeEff(self.rechargeBt)

	--签到
	self.signBt = cc.ui.UIPushButton.new("#MainUI_img16.png")
	:addTo(self)
	:pos(self:getMenuPos(3).x, self:getMenuPos(3).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		self.signInLayer = g_SignInLayer.new()
				:addTo(display.getRunningScene(),51,activityMenuLayerTag.signInTag)
		end)

	--通缉
	self.bountyBt = cc.ui.UIPushButton.new("#MainUI_img20.png")
	:addTo(self)
	:pos(self:getMenuPos(4).x, self:getMenuPos(4).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_bounty.new()
		:addTo(display.getRunningScene())
		end)

	--任务
	self.taskBt = cc.ui.UIPushButton.new("#MainUI_img15.png")
	:addTo(self)
	:pos(self:getMenuPos(5).x, self:getMenuPos(5).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
	    self.taskLayer = TaskLayer.new()
	    :addTo(display.getRunningScene(),0,activityMenuLayerTag.taskTag)
        bTaskLayerOpened = true
        DCEvent.onEvent("点击任务图标")
		end)
	--成就
	self.achievementBt = cc.ui.UIPushButton.new("#MainUI_img14.png")
	:addTo(self)
	:pos(self:getMenuPos(6).x, self:getMenuPos(6).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		self.achievementTree = achievementTree.new()
			:addTo(display.getRunningScene(),51,activityMenuLayerTag.achieveTag)
		DCEvent.onEvent("点击成就图标")
		end)

	--军团
	self.legionBt = cc.ui.UIPushButton.new("#MainUI_img13.png")
	:addTo(self)
	:pos(self:getMenuPos(7).x, self:getMenuPos(7).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		if srv_userInfo.level<28 then
            showTips("28级后开启军团功能")
            return
        end
        startLoading()
        local sendData = {}
        if srv_userInfo.armyName=="" then
            sendData["characterId"] = srv_userInfo["characterId"]
            sendData["No"] =  0
            m_socket:SendRequest(json.encode(sendData), CMD_LEGION_ENTER, MainScene_Instance, MainScene_Instance.onEnterLegionResult)
        else
            sendData["characterId"] = srv_userInfo["characterId"]
            m_socket:SendRequest(json.encode(sendData), CMD_MYLEGION_INFO, MainScene_Instance, MainScene_Instance.onMyLegionInfo)
        end
        GuideManager:removeGuideLayer()
		end)
	if srv_userInfo.level<28 then
		display.newSprite("common2/com_lock.png")
		:addTo(self.legionBt,0,11)
		:pos(30,30)
	end
	--排行
	self.rankBt = cc.ui.UIPushButton.new("#MainUI_img12.png")
	:addTo(self)
	:pos(self:getMenuPos(8).x, self:getMenuPos(8).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		MainScene_Instance:setTopBarVisible(false)
        local layer = rankLayer.new()
        MainScene_Instance:addChild(layer, 1)
		end)
	

	--开服活动
	self.startServerBt = cc.ui.UIPushButton.new("#MainUI_img38.png")
	:addTo(self)
	:pos(display.width - 60, display.cy)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_oneWeekReward.new()
		:addTo(display.getRunningScene(),50)
		end)
	--赠送VIP
	self.sendVIPBt = cc.ui.UIPushButton.new("#MainUI_img39.png")
	:addTo(self)
	:pos(display.width - 60, display.cy-100)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_pointReward.new()
		:addTo(display.getRunningScene())
		end)
	self.sendVIPBt:setVisible(false)
end

function activityMenuBar:initMenutab_top()
	g_menuTab_top = {
		[1] = {self.rankBt,true},			--排行
		[2] = {self.legionBt,true},			--军团
		[3] = {self.achievementBt,true},	--成就
		[4] = {self.taskBt,true},			--任务
		[5] = {self.bountyBt,true},			--通缉令
		[6] = {self.signBt,true},			--签到
		[7] = {self.rechargeBt,true},		--充值
		[8] = {self.discountBt,true},		--优惠
		[9] = {self.onlineActivity,true},	--在线奖励
	}

	local guideStep = srv_userInfo.guideStep
	
	
	if guideStep<=103 then	--领第一个任务前，隐藏任务按钮和成就按钮
		g_menuTab_top[4][2] = false
		g_menuTab_top[3][2] = false
	end
	if guideStep<=126 then	--打竞技场前，隐藏排行榜按钮（还有竞技场按钮）
		g_menuTab_top[1][2] = false
	end
	if guideStep<=130 then	--开启军团前，隐藏军团按钮
		g_menuTab_top[2][2] = false
	end
	if guideStep<=112 then	--开启军团前，隐藏军团按钮
		g_menuTab_top[5][2] = false
	end

	
	--新需求要求按钮不隐藏，也不突然出现
	-- if srv_userInfo.guideStep==-1 or g_isGuideClose then
	-- 	return 
	-- end

	-- local j=0
	-- for i=1,#g_menuTab_top do
	-- 	if g_menuTab_top[i][2]==false then
	-- 		g_menuTab_top[i][1]:hide()
	-- 	else
	-- 		g_menuTab_top[i][1]:pos(display.width-60-j*92,display.height-110)
	-- 		j = j+1
	-- 	end
	-- end
end

function activityMenuBar:onEnter()
    self:initMenutab_top()
end

function activityMenuBar:showBountyBtn()
	print("srv_userInfo.maxBlockId:",srv_userInfo.maxBlockId)
	print("g_menuTab_top[5][2]:",g_menuTab_top[5][2])
	local num = tonumber(string.sub(tostring(srv_userInfo.maxBlockId), 4,8))
	if bToShowBountBtn==true then
		self:showMoveAction(nil,nil,5)
		g_menuTab_top[5][2]=true
		bToShowBountBtn = false
	end
end

function activityMenuBar:showMoveAction(_guideStep,_callback,_index)
	local _delayTime = 0

	if srv_userInfo.guideStep==-1 or g_isGuideClose then
		if _callback then
			self:performWithDelay(_callback,_delayTime)
		end
		return 
	end

	local function getFrontAndTailBtns(index)
		local front = {}
		local tail = {}
		for i=1,#g_menuTab_top do
			--if g_menuTab_top[i][2]==true then
				if i<index then
					front[#front+1] = g_menuTab_top[i][1]
				elseif i>index then
					tail[#tail+1] = g_menuTab_top[i][1]
				end
			--end
		end
		return front,tail
	end

	local tmp = GuideManager.NextStep
	if tonumber(tmp) == 0 then
        tmp = tonumber(tostring(srv_userInfo.guideStep).."01")
    end

	local index = -1
	if _guideStep==10301 and tmp == _guideStep then
		index = 4
		-- index = 3
		-- self:performWithDelay(function ( ... )
		-- 	self:showMoveAction(nil,nil,4)
		-- end,0.1)
	elseif _guideStep==12601 and tmp == _guideStep then
		index = 1
	elseif _guideStep==13001 and tmp == _guideStep then
		index = 2
	elseif _guideStep==11201 and tmp == _guideStep then
		index = 5
	end

	if index==-1 and tonumber(_index)~=nil then
		index = _index
	end

	if index~=-1 then
		_delayTime = 0.8
		g_menuTab_top[index][2] = true
		local front,tail = getFrontAndTailBtns(index)
		-- for k,v in pairs(tail) do
		-- 	v:runAction(cc.MoveBy:create(_delayTime,cc.p(-92,0)))
		-- end
		-- g_menuTab_top[index][1]:show()
		-- 	:pos(display.width-60-#front*92,display.height-110)
		-- 	:opacity(0)
		g_menuTab_top[index][1]:runAction(cc.FadeIn:create(_delayTime))
		display.addSpriteFrames("Effect/menuEff.plist", "Effect/menuEff.png")
	    local frames = display.newFrames("activityEff_%02d.png", 0, 8)
	    local animation = display.newAnimation(frames, _delayTime / 8)
	    local ani = cc.Animate:create(animation)
	    local sprite = display.newSprite("#rolemenuEff_00.png")
			    :addTo(self)
			    :pos(display.width-60-#front*92,display.height-110)
			    :scale(2)
		local sq = transition.sequence{ani,cc.FadeOut:create(0.2),cc.CallFunc:create(function ()
	    	sprite:removeSelf()
	    end)}
	    sprite:runAction(sq)
	end
	if _callback then
		self:performWithDelay(_callback,_delayTime)
	end
end

function activityMenuBar:onFriendListResult(result)
    if result.result==1 then
        --进入好友界面
        self.friend = friendLayer.new()
        :addTo(cc.Director:getInstance():getRunningScene())
        self.friend:setTag(TAG_FERIEND_LAYER)
        
    end
end

function activityMenuBar:OLonInterval()
	local num = TaskMgr:GetCanSubNum(TaskTag.Online)
	if num>0 then
		g_ActOnLineListTs = 0
		scheduler.unscheduleGlobal(g_OLHandle)
		g_OLHandle = nil
	end
	if g_ActOnLineListTs>1000 then
		g_ActOnLineListTs = g_ActOnLineListTs -1000
	else
		-- g_ActOnLineListTs = 0
		-- scheduler.unscheduleGlobal(g_OLHandle)
		-- g_OLHandle = nil
	end

	if MainScene_Instance then
		g_onlineLabel:setString(GetTimeStr(g_ActOnLineListTs))
		setLabelStrokeString(g_onlineLabel, g_OLretNode)
		local num = TaskMgr:GetCanSubNum(TaskTag.Online)
		if num>0 then
			g_awardLabel:setVisible(true)
			setLabelVisible(g_awardNode, true)
			g_onlineLabel:setVisible(false)
			setLabelVisible(g_OLretNode, false)
			self.onlineEff = onLineEff(self.onlineActivity)
			if g_ActOnLineListTs~=0 then
				g_ActOnLineListTs=10000
			end
		else
			g_awardLabel:setVisible(false)
			setLabelVisible(g_awardNode, false)
			g_onlineLabel:setVisible(true)
			setLabelVisible(g_OLretNode, true)

			if self.onlineEff then
				self.onlineEff:removeSelf()
				self.onlineEff = nil
			end
		end
	else
		g_onlineLabel = nil
		g_OLretNode = nil
	end
	-- print(GetTimeStr(g_ActOnLineListTs))
end
function activityMenuBar:showOnlineActReward()
	if self.onlineCurRewards then
		GlobalShowGainBox(nil, self.onlineCurRewards)
		self.onlineCurRewards = nil
		if g_OLHandle==nil then
			g_OLHandle = scheduler.scheduleGlobal(handler(self, self.OLonInterval), 1)
		end
	end
	
end
--获取服务端任务数据中的在线奖励
function activityMenuBar:getSrvOneWeekTask()
    local srvData = nil
    local locData = nil
    for i,value in pairs(TaskMgr.idKeyInfo) do
    	if taskData[value.tptId].type==11 and value.status==1 then
    		srvData = value
    		locData = taskData[value.tptId]
        end
    end
    return srvData, locData
end
--用于详情展示
function activityMenuBar:getSrvOneWeekTask2()
    local srvData = nil
    local locData = nil
    for i,value in pairs(TaskMgr.idKeyInfo) do
    	if taskData[value.tptId].type==11 and value.status==0 then
    		srvData = value
    		locData = taskData[value.tptId]
        end
    end
    return srvData, locData
end

return activityMenuBar