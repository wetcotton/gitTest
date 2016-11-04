-- 签到界面
-- Author: Huang Yuzhao
-- Date: 2015-08-14 14:27
--
SignInLayer = class("SignInLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
	layer:setNodeEventEnabled(true)
	return layer
end)
SignInLayer.Instance = nil 				--实例

local curGuideBtn = nil

local CURMONTHDAYS = 0
function getDayNumByMonth()
	local CURYEAR = 0
	local CURMONTH = 0  --当前是第几月
	CURYEAR = tonumber(os.date("%Y", os.time()))
	CURMONTH = tonumber(os.date("%m", os.time()))
	print("CURYEAR: "..CURYEAR)
	print("CURMONTH: "..CURMONTH)
	local k=28
	if (CURYEAR%100==0 and CURYEAR%400==0) or (CURYEAR%100~=0 and CURYEAR%4==0) then
		k=29
	end
	local arr = {31,k,31,30,31,30,31,31,30,31,30,31}
	CURMONTHDAYS = arr[CURMONTH]
	print("CURMONTHDAYS: "..CURMONTHDAYS)
end

function SignInLayer:ctor()
	setIgonreLayerShow(true)
	display.addSpriteFrames("Image/UISignIn.plist", "Image/UISignIn.png")
	--生成日常签到奖励表格

	local colorBg = display.newSprite("common/colorbg.png")
	:addTo(self,-1)
	colorBg:setAnchorPoint(0,0)
	colorBg:setScaleX(display.width/colorBg:getContentSize().width)
	colorBg:setScaleY(display.height/colorBg:getContentSize().height) 	
	
	getDayNumByMonth()
	
	self.dailySignInRewards = {}
	local nIndex
	if "null"~=taskData[105190001].rewardItems then
		local arr = string.split(taskData[105190001].rewardItems, "|")
		local subArr
		for i=1, #arr do
			self.dailySignInRewards[i] = {}
			subArr = string.split(arr[i], "#")
			table.insert(self.dailySignInRewards[i], {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
			nIndex = i
		end
	end
	if "null"~=taskData[105190001].rewardItems2 then
		local arr = string.split(taskData[105190001].rewardItems2, "|")
		local subArr
		for i=1, #arr do
			self.dailySignInRewards[nIndex+i] = {}
			subArr = string.split(arr[i], "#")
			table.insert(self.dailySignInRewards[nIndex+i], {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
	local tmpSize,tmpNode

	display.newSprite("#signImg_02.png")
		:addTo(self)
		:align(display.CENTER_TOP,display.cx,display.height-10)

	local imgBg = display.newSprite("#signFrame_01.png")
                        :align(display.CENTER, display.cx, display.cy-32)
                        :addTo(self)
    tmpSize = imgBg:getContentSize()


    local scrollBg = display.newScale9Sprite("#signImg_03.png", nil, nil, cc.size(737,435), cc.rect(30, 30, 10, 10))
                        :align(display.CENTER, tmpSize.width/2-100, tmpSize.height/2+15)
                        :addTo(imgBg)

	--关闭按钮
    self.closeBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height)
    	:addTo(self)
	    :onButtonClicked(function(event)
	    	local _scene = cc.Director:getInstance():getRunningScene()
	    	_scene:refreshTaskRedPoin()
	        self:removeFromParent()
	    end)

	-- tmpNode = display.newScale9Sprite("#signIn_frame6.png",nil,nil,cc.size(738,66),cc.rect(30,0,1,69))
	-- 			:align(display.CENTER_TOP, tmpSize.width/2-100, tmpSize.height-20)
	-- 			:addTo(imgBg)
	-- display.newSprite("#signIn_img17.png")
	-- 			:align(display.LEFT_BOTTOM, 0, 0)
	-- 			:addTo(tmpNode)

	self.totalSignInBg = display.newScale9Sprite("#signImg_03.png", nil, nil, cc.size(184,435), cc.rect(80, 80, 10, 10))
                        :align(display.CENTER, tmpSize.width-130, tmpSize.height/2+15)
                        :addTo(imgBg)
    display.newSprite("#signTag_01.png")
				:align(display.CENTER, self.totalSignInBg:getContentSize().width/2, self.totalSignInBg:getContentSize().height-10)
				:addTo(self.totalSignInBg)

	--规则按钮
	tmpNode = cc.ui.UIPushButton.new({normal="common2/com2_Btn_4_up.png"})
						:pos(tmpSize.width*0.7, 55)
						:addTo(imgBg)
						:scale(0.8)
						:onButtonPressed(function(event)
							event.target:setScale(0.96*0.8)
							end)
						:onButtonRelease(function(event)
							event.target:setScale(1.0*0.8)
							end)
						:onButtonClicked(function(event)
							self:ShowRule()
						end)
	display.newTTFLabel{text = "规则说明",size = 30,color = cc.c3b(49,53,50)}
				:addTo(tmpNode)


	--补签按钮
	tmpNode = cc.ui.UIPushButton.new({normal="common2/com2_Btn_3_up.png"})
						:pos(tmpSize.width-130, 55)
						:addTo(imgBg)
						:scale(0.9)
						:onButtonPressed(function(event)
							event.target:setScale(0.96*0.9)
							end)
						:onButtonRelease(function(event)
							event.target:setScale(1.0*0.9)
							end)
						:onButtonClicked(function(event)
							if srv_userInfo.reCheckInCnt<5 then
								local curDay = os.date("%d", os.time())
								curDay = tonumber(curDay)
								if nil~=self.srv_SignIn then
									local _diamondCost = SignCost[srv_userInfo.reCheckInCnt+1]
									if srv_userInfo.diamond<_diamondCost then
										showTips("钻石不足")
										return
									end
									if 0==srv_userInfo.checkInStatus then  --如果当天还没签过到，必须留一天用于签到
										curDay = curDay-1
									end
									if self.srv_SignIn.curcnt<curDay then
										showMessageBox("是否花费".._diamondCost.."钻石进行补签",function ()
											TaskMgr:ReqReSingIn()
											startLoading()
										end)
									else
										showMessageBox("不能越期签到")
									end
									
								end
							else
								showMessageBox("已达补签上限")
							end
						end)
	display.newTTFLabel{text = "补签",size = 27,color = cc.c3b(124,73,30)}
				:addTo(tmpNode)
				:pos(20,5)
	display.newSprite("#signIn_diamond1.png")
		:addTo(tmpNode)
		:pos(-30,5)
		:scale(0.6)

	local _lbl = display.newTTFLabel{text = "本月已累计签到",size = 26,color = cc.c3b(219, 218, 204),}
		:align(display.LEFT_CENTER,40,tmpSize.height-50)
		:addTo(imgBg)
	self.labSignInNum = display.newTTFLabel{text = "0",size = 26,color = cc.c3b(248, 197, 45),}
			    		:align(display.LEFT_CENTER, _lbl:getPositionX()+_lbl:getContentSize().width,_lbl:getPositionY())
			    		:addTo(imgBg)
	self.labSignInTag_ = display.newTTFLabel{text = "天,累计签到有奖哦",size = 26,color = cc.c3b(219, 218, 204),}
		:align(display.LEFT_CENTER, self.labSignInNum:getPositionX()+self.labSignInNum:getContentSize().width,self.labSignInNum:getPositionY())
		:addTo(imgBg)

	self.scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 200, 0, 0))
						:pos(9,9)
	self.scrollNode:setContentSize(770, 370)
    --签到滚动面板
    self.signInView = cc.ui.UIScrollView.new {
    	bgColor = cc.c4b(0, 200, 0, 0),
    	viewRect=cc.rect(9, 9, 720, 420),
    	direction=cc.ui.UIScrollView.DIRECTION_VERTICAL,
		}
		:addTo(scrollBg)
		:addScrollNode(self.scrollNode)


	

	
	self.btnDays = {}
	--初始化签到面板
	self:InitSignInPanel()
end

--初始化签到面板
function SignInLayer:InitSignInPanel()
	self.maskNodes = {}
	local nTotalDays = #self.dailySignInRewards
	local srv_SignIn, loc_SignIn
	local srv_SignInTotal, loc_SignInTotal = {}, {}
	local tplID = 105190001 	--签到任务模板ID
	local tplID_T = {105200001, 105210001, 105220001} 	--累计签到任务模板ID
	local tmpNode, tmpSize

	loc_SignIn = taskData[tplID]
	for i=1, #tplID_T do
		loc_SignInTotal[i] = taskData[tplID_T[i]]
	end

	for i=1, #TaskMgr.sortList[TaskTag.SignIn] do
		local key = TaskMgr.sortList[TaskTag.SignIn][i]
		local tmpInfo = TaskMgr.idKeyInfo[key]
		if nil~=tmpInfo then
			if tmpInfo.tptId==tplID then 	--每日签到
				srv_SignIn = tmpInfo
			elseif tmpInfo.tptId==tplID_T[1] then 	--累计签到（5次）
				srv_SignInTotal[1] = tmpInfo
			elseif tmpInfo.tptId==tplID_T[2] then 	--累计签到（15次）
				srv_SignInTotal[2] = tmpInfo
			elseif tmpInfo.tptId==tplID_T[3] then 	--累计签到（25次）
				srv_SignInTotal[3] = tmpInfo
			end
		end
	end

	if nil==srv_SignIn then
		printInfo("没有签到信息，Bug")
		return
	end
	
	local g_diamondImg = {"#signIn_diamond1.png","#signIn_diamond2.png","#signIn_diamond3.png"}
	local g_dyaNumImg = {"5天","15天","25天"}
	local g_taskId = {105200001,105210001,105220001}
	tmpSize = self.totalSignInBg:getContentSize()
	local g_point = {{tmpSize.width/2,(tmpSize.height-10)*0.75},{tmpSize.width/2,(tmpSize.height-10)*0.5-15},{tmpSize.width/2,(tmpSize.height-10)*0.25-30}}

	for i=1, 3 do
		local loc_task = taskData[g_taskId[i]]
		--响应按钮
		tmpNode = cc.ui.UIPushButton.new({normal="#signImg_05.png",pressed="#signImg_05.png"})
					--:size(117, 117)
					:align(display.CENTER, g_point[i][1], g_point[i][2])
					:addTo(self.totalSignInBg, 1,36+i)
					:onButtonClicked(function(event)
						if srv_SignInTotal[i].status==2 then
							showTips("奖励已领")
							return
						end
						self:GenerateRewardsTab(srv_SignInTotal[i].tptId)
						TaskMgr:ReqSubmit(srv_SignInTotal[i].id)
						startLoading()
						
					end)
		local _tag = display.newSprite("#signImg_05.png")
				:addTo(tmpNode,21,36)
				:opacity(80)
		_tag:setColor(cc.c3b(0,0,0))
		display.newSprite("#signTag_02.png")
				:addTo(_tag)
				:pos(_tag:getContentSize().width/2+20,_tag:getContentSize().height/2-10)

		display.newSprite(g_diamondImg[i])
				:addTo(tmpNode)
				:pos(-20,0)
		local _lbl = display.newTTFLabel{text = loc_task.diamond,size = 30,font = "fonts/slicker.ttf"}
			:addTo(tmpNode)
			:pos(-20,-30)
		_lbl:enableOutline(cc.c4f(0,0,0,255),1)

		display.newTTFLabel{text = g_dyaNumImg[i],size = 30,color = cc.c3b(106,57,6)}
				:addTo(tmpNode)
				:align(display.RIGHT_TOP,tmpNode.sprite_[1]:getContentSize().width/2-10,tmpNode.sprite_[1]:getContentSize().height/2-2)
	end
	for i=1,3 do
		if srv_SignInTotal==nil then
			break
		end
		local node = self.totalSignInBg:getChildByTag(36+i):getChildByTag(36)
		if node==nil then break end
		if srv_SignInTotal[i].status==2 then
			node:show()
		else
			node:hide()
		end
	end

	self.labSignInNum:setString(srv_SignIn.curcnt)
	self.labSignInTag_:setPositionX(self.labSignInNum:getPositionX()+self.labSignInNum:getContentSize().width)
	local function SignItemOnClick(event)
		local nTag = event.target:getTag()
		if nTag==srv_SignIn.curcnt+1 then
			if 0==srv_userInfo.checkInStatus then
				TaskMgr:ReqSignIn()
				startLoading()
			else
				showMessageBox("今天已经签到过了")
			end
		end
	end

	self.t_data = {}
	tmpSize = cc.size(126, 126)
	rect = cc.rect(0, 0, 126, 126)
	for i=1, CURMONTHDAYS do
		--底板
		local bg = display.newScale9Sprite("#signImg_03.png",nil,nil,cc.size(126,126),cc.rect(25,25,135,140))
		bg:setOpacity(0)
		self.t_data[i] = bg

		--图标
		--print("XX - ", i, self.dailySignInRewards[i][1].templateID)
		tmpNode = self:GetRewardsIcon(self.dailySignInRewards[i][1].templateID, self.dailySignInRewards[i][1].num)
		if tmpNode~=nil then
			tmpNode:align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
			:addTo(bg, 1, 1)
			--:scale(0.86)

			--遮罩
			tmpNode = display.newScale9Sprite("#signImg_03.png",nil,nil,cc.size(126,126),cc.rect(25,25,135,140))
						:addTo(bg,2,2)
						:align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
						:opacity(150)
			tmpNode:setColor(cc.c3b(0,0,0))
			display.newSprite("#signTag_02.png")
				:addTo(tmpNode)
				:align(display.RIGHT_BOTTOM, tmpSize.width-17, 0+17)
			self.maskNodes[i] = tmpNode
			

			--按钮
			tmpNode = cc.ui.UIPushButton.new()
						:size(tmpSize.width, tmpSize.height)
						:align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
						:addTo(bg, 0, 3)
						:onButtonClicked(SignItemOnClick)
			tmpNode:setTag(i)
			tmpNode:setTouchSwallowEnabled(false)
			self.btnDays[i] = tmpNode
			if i==1 then
				curGuideBtn = tmpNode
				
			end
		end
	end
	self:refreshMask()
	self.signInView:fill(self.t_data, {itemSize=tmpSize})
	S_XY(self.signInView:getScrollNode(),9,9+self.signInView:getViewRect().height-H(self.signInView:getScrollNode()))

	--记录，方便签到消息返回后的处理
	self.srv_SignIn = srv_SignIn
	self.loc_SignIn = loc_SignIn
	self.srv_SignInTotal = srv_SignInTotal
	self.loc_SignInTotal = loc_SignInTotal
end

function SignInLayer:refreshMask()
	local srv_SignIn = nil
	for k,v in pairs(TaskMgr.idKeyInfo) do
		if v.tptId==105190001 then
			srv_SignIn = v
			break
		end
	end

	if srv_SignIn==nil then
		return
	end

	for i=1, #self.maskNodes do
		self.maskNodes[i]:setVisible(true)
		if srv_SignIn.curcnt<i then
			if self.maskNodes[i]~=nil then
				self.maskNodes[i]:setVisible(false)
			end
		end
	end
	print(srv_SignIn.curcnt)
	if srv_SignIn.curcnt>=1 then
		local bg = self.maskNodes[(srv_SignIn.curcnt ) ]:getParent()
		print("------------------------")
		removeSignCircleAnimation(bg)
	end

	-- print("CURMONTHDAYS:",CURMONTHDAYS,"srv_SignIn.curcnt:",srv_SignIn.curcnt,"#self.maskNodes:",#self.maskNodes)
	if srv_SignIn.curcnt<=CURMONTHDAYS then
		local nextDay = (srv_SignIn.curcnt or 0) +1
		if nextDay<=CURMONTHDAYS then
			local bg = self.maskNodes[nextDay]:getParent()
			if 0==srv_userInfo.checkInStatus then
				signCircleAnimation(bg,bg:getContentSize().width/2, bg:getContentSize().height/2,2.5)		
			end
		end
	end

	for i=1,3 do
		if self.srv_SignInTotal==nil then
			break
		end
		local node = self.totalSignInBg:getChildByTag(36+i):getChildByTag(36)
		if node==nil then break end
		if self.srv_SignInTotal[i].status==2 then
			node:show()
		else
			node:hide()
		end
	end

end

--累计签到领奖返回
function SignInLayer:OnSubmitRet(cmd)
	if 1==cmd.result then

		if nil~=self.curRewards then
			GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)
            
			--奖励添加
			self:RewardsAdd(self.curRewards,3)
		end
		self:refreshMask()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--签到返回
function SignInLayer:OnSignInRet(cmd)
	if 1==cmd.result then
		local nCurNum = self.srv_SignIn.curcnt
		local node = self.t_data[nCurNum]
		local mask = node:getChildByTag(2)
		mask:setVisible(true)
		self.labSignInNum:setString(self.srv_SignIn.curcnt)
		self.labSignInTag_:setPositionX(self.labSignInNum:getPositionX()+self.labSignInNum:getContentSize().width)
		if nil~=self.dailySignInRewards[nCurNum] then
			local multipleNum = cmd.data.cir
			if multipleNum and multipleNum>1 then
				for k,v in pairs(self.dailySignInRewards[nCurNum]) do
					v.num = v.num*multipleNum
				end
			end
			GlobalShowGainBox({bAlwaysExist = true}, self.dailySignInRewards[nCurNum])
			--奖励添加
			self:RewardsAdd(self.dailySignInRewards[nCurNum],1)
		end
		self:refreshMask()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--补签返回
function SignInLayer:OnReSignInRet(cmd)
	print(":+++++++++++++++++++++++++++++++++++++++++++")
	if 1==cmd.result then
		local nCurNum = self.srv_SignIn.curcnt
		local node = self.t_data[nCurNum]
		local mask = node:getChildByTag(2)
		mask:setVisible(true)
		self.labSignInNum:setString(self.srv_SignIn.curcnt)
		self.labSignInTag_:setPositionX(self.labSignInNum:getPositionX()+self.labSignInNum:getContentSize().width)
		if nil~=self.dailySignInRewards[nCurNum] then
			local multipleNum = cmd.data.cir
			if multipleNum and multipleNum>1 then
				for k,v in pairs(self.dailySignInRewards[nCurNum]) do
					v.num = v.num*multipleNum
				end
			end
			GlobalShowGainBox({bAlwaysExist = true}, self.dailySignInRewards[nCurNum])
			--奖励添加
			self:RewardsAdd(self.dailySignInRewards[nCurNum],2)
		end
		self:refreshMask()
		mainscenetopbar:setDiamond()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--生成奖励表
function SignInLayer:GenerateRewardsTab(nTaskTplID)
	local loc_TaskData = taskData[nTaskTplID]
	self.curRewards = {}
	if 0~=loc_TaskData.gold then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_GOLD, num=loc_TaskData.gold})
	end
	if 0~=loc_TaskData.diamond then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=loc_TaskData.diamond})
	end
	if 0~=loc_TaskData.exp then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_EXP, num=loc_TaskData.exp})
	end
	if 0~=loc_TaskData.energy then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_EXP, num=loc_TaskData.energy})
	end
	if nil~=loc_TaskData.rewardItems and""~=loc_TaskData.rewardItems and "null"~=loc_TaskData.rewardItems then
		local arr = string.split(loc_TaskData.rewardItems, "|")
		local subArr
		for i=1, #arr do
			subArr = string.split(arr[i], "#")
			table.insert(self.curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
end

function SignInLayer:ShowRule()
	local layer = UIMasklayer.new()
	layer:setTouchCallback(function ( ... )
        layer:removeSelf()
    end)
	local tmpSize = cc.size(843, 555)
	local spr = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
					:addTo(layer)
					:pos(display.cx,display.cy)


	display.newTTFLabel{text = "签到规则",size = 40,color = cc.c3b(95,255,250)}
		:align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
		:addTo(spr)

	local _label = display.newTTFLabel({text = "你好",size = 30})
						:addTo(spr)
						:align(display.CENTER,spr:getContentSize().width/2,spr:getContentSize().height/2-50)
			local _singleLineHeight = _label:getContentSize().height
			_label:setWidth(spr:getContentSize().width-113)
			_label:setLineHeight(_singleLineHeight+4)

	local str = [[1,   每日签到奖励在每日00:00刷新奖励，当天未领取奖励隔天不可补领。
2,   每月累计签到天数，领取相应签到奖励。
3,   每月签到达到固定天数可以领取累计签到礼品。
4,   玩家可以使用钻石对当月未签到天数进行补签，每月补签次数不得超过五次，当月已签到次数和补签次数不得超过当月已进行自然日天数。

	    ]]
	_label:setString(str)

	layer:addHinder(spr)
	layer:setOnTouchEndedEvent(function()
		layer:removeFromParent()
	end)

	self:addChild(layer)
end

--奖励添加（除去道具）
function SignInLayer:RewardsAdd(tabRewards,tag)
	if nil==tabRewards then
		return
	end
	local strReason = {"签到奖励","补签奖励","累计签到"}
	tag = tag or 1
	for i=1, #tabRewards do
		if tabRewards[i].templateID==GAINBOXTPLID_GOLD then
			srv_userInfo.gold = srv_userInfo.gold+tabRewards[i].num
			mainscenetopbar:setGlod()
			DCCoin.gain(strReason[tag],"金币",tabRewards[i].num,srv_userInfo.gold)
		elseif tabRewards[i].templateID==GAINBOXTPLID_DIAMOND then
			srv_userInfo.diamond = srv_userInfo.diamond+tabRewards[i].num
			mainscenetopbar:setDiamond()
			DCCoin.gain(strReason[tag],"钻石",tabRewards[i].num,srv_userInfo.diamond)
		elseif tabRewards[i].templateID==GAINBOXTPLID_EXP then
			srv_userInfo.exp = srv_userInfo.exp+tabRewards[i].num
		else
			local dc_item = itemData[tabRewards[i].templateID]
			if loc_data~=nil then
				DCItem.get(tostring(dc_item.id), dc_item.name, tabRewards[i].num, strReason[tag])
			end
		end
	end
end

--获取奖励图标
function SignInLayer:GetRewardsIcon(nTplID, nNum)
	local sprRet = nil
	if nTplID==GAINBOXTPLID_GOLD or nTplID==GAINBOXTPLID_DIAMOND or nTplID==GAINBOXTPLID_EXP or nTplID==GAINBOXTPLID_STRENGTH then
		sprRet = GlobalGetSpecialItemIcon(nTplID, nNum, 1.18)
		-- :scale(1)
	else
        if nil~=itemData[nTplID] then
    		sprRet = createItemIcon(nTplID, nNum)
    	end
    end

    return sprRet
end

function SignInLayer:onEnter()
	setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
	SignInLayer.Instance = self
end

function SignInLayer:onExit()
	SignInLayer.Instance = nil

	display.removeSpriteFramesWithFile("Image/UISignIn.plist", "Image/UISignIn.png")

end


return SignInLayer