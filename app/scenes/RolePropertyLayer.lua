-- 人物属性界面
-- Author: Jun Jiang
-- Date: 2015-06-09 18:57:46
--
local RolePropertyLayer = class("RolePropertyLayer",function()
	local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)
RolePropertyLayer.Instance 		= nil
RolePropertyLayer.params 		= nil
RolePropertyLayer.sortList 		= {} 	--成员排序列表
RolePropertyLayer.nCurRoleIndex = nil 	--当前角色索引
RolePropertyLayer_Instance = nil
-- local roleIdx = 1
local curEqupIdx = 1 
local curRoleData ={}
local cur_value = {}
local cur_localValue = {}
local advNeedGold = 0 --进阶升级消耗的金币
local proLevcost_honor = 0 --职业提升消耗荣誉值
RoleFightBackTmpId = {}
function RolePropertyLayer:updateRoleData()
	curRoleData = RoleManager.roleIDKeyList[self.sortList[self.nCurRoleIndex]]
end
--获取选择装备的数据
function RolePropertyLayer:getCurValue(idx)
	
	local itemId = curRoleData["equip"][idx]
	cur_value = srv_carEquipment["memIt"][itemId]
	cur_localValue = itemData[cur_value.tmpId]
end

local function GetGrade(fNum)
	local strRet = ""
	if fNum<=0.59 then
		strRet = "D(" .. fNum .. ")"
	elseif fNum<=0.69 then
		strRet = "C(" .. fNum .. ")"
	elseif fNum<=0.79 then
		strRet = "B(" .. fNum .. ")"
	elseif fNum<=0.88 then
		strRet = "A(" .. fNum .. ")"
	elseif fNum<=0.95 then
		strRet = "S(" .. fNum .. ")"
	elseif fNum<=0.99 then
		strRet = "SS(" .. fNum .. ")"
	else
		strRet = "SSS(" .. fNum .. ")"
	end

	return strRet
end

function RolePropertyLayer:ctor(params)
	RolePropertyLayer_Instance = self
	g_startTime = socket.gettime()
	--资源加载
	-- display.addSpriteFrames("Image/UIRoleProperty.plist", "Image/UIRoleProperty.png")
	-- display.addSpriteFrames("Image/UIRoleProperty1.plist", "Image/UIRoleProperty1.png")
	-- display.addSpriteFrames("Image/UIRoleProperty2.plist", "Image/UIRoleProperty2.png")
	-- display.addSpriteFrames("Image/UIRoleProperty.plist", "Image/UIRoleProperty.png")
	display.addSpriteFrames("Image/RoleProperty2.plist", "Image/RoleProperty2.png")
	-- print("属性界面耗时打印："..(socket.gettime()-g_startTime))
	
	local tmpNode, tmpSize, tmpCx, tmpCy, tmpTab
	self.params = params or {}

	self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
   	local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

	--关闭按钮
	self.closeBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.TOP_LEFT, 0,  display.height )
    	:addTo(self, 1)
    	:onButtonClicked(function(event)
    		setIgonreLayerShow(true)
    		GuideManager:removeGuideLayer()
    		local _scene = cc.Director:getInstance():getRunningScene()
    		GuideManager:_addGuide_2(11601, _scene,handler(_scene,_scene.caculateGuidePos))
    		GuideManager:_addGuide_2(20201, _scene,handler(_scene,_scene.caculateGuidePos))
    		if srv_userInfo.level>=10 then   --
	    		GuideManager:_addGuide_2(12101, _scene,handler(_scene,_scene.caculateGuidePos))
	    	end
    		self:removeFromParent()
    		setIgonreLayerShow(false)
    	end)

	--左面板
	tmpSize = cc.size(574, 559)
	self.lPanel = display.newScale9Sprite("#RoleProperty2_img1.png", nil, nil, tmpSize)
								:align(display.CENTER, display.cx-230, display.cy-40)
								:addTo(self, 10)
	--左面板背景图
	self.roleBg = display.newSprite("#RoleProperty2_img2.png")
	:addTo(self.lPanel)
	:pos(self.lPanel:getContentSize().width/2, self.lPanel:getContentSize().height/2+60)

	-- changeRoleEff(self.lPanel, self.lPanel:getContentSize().width/2, self.lPanel:getContentSize().height/2+60)

	--换装
	local changeEquipmentBt = cc.ui.UIPushButton.new("#RoleProperty2_img53.png")
	:addTo(self.lPanel, 10)
	:pos(tmpSize.width/2, 165)
	:onButtonPressed(function(event) event.target:setScale(0.95) end)
	:onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		if not self:isCanChangeEquipment() then
			showMessageBox("当前所有装备必须要进阶到最高等级，才可换装。")
			return
		end
		local equips = curRoleData.equip
		local srv_Item = srv_carEquipment["memIt"][equips[1]]
		local star = getItemStar(srv_Item.tmpId)
		printTable(RoleChangeEptLimitLvl)
		if srv_userInfo.level < RoleChangeEptLimitLvl[star-1] then
			local msg = "人物等级达到"..RoleChangeEptLimitLvl[star-1].."级后才能换装哦！"
			showTips(msg)
			return
		end
		startLoading()
		local tabMsg  = {}
		tabMsg["memId"] = curRoleData.id
    	m_socket:SendRequest(json.encode(tabMsg), CMD_CHANGE_EQUIPMENT, self, self.OnChangeEquipment)
		end)
	self.changeEquipmentBt = changeEquipmentBt
	

	--左右连接处
	display.newSprite("#RoleProperty2_img7.png")
	:addTo(self.lPanel)
	:pos(tmpSize.width-2, tmpSize.height/2+130)
	display.newSprite("#RoleProperty2_img7.png")
	:addTo(self.lPanel)
	:pos(tmpSize.width-2, tmpSize.height/2-130)

	--角色名
	tmpSize = self.lPanel:getContentSize()
	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2

	--等级、战力
	tmpNode = display.newSprite("#RoleProperty2_img15.png")
				:align(display.CENTER, tmpCx, 30)
				:addTo(self.lPanel,3)
	tmpSize = tmpNode:getContentSize()
	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2
	
	--等级战斗力
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "等级", size = 26, color = cc.c3b(46, 76, 75)})
	:addTo(tmpNode)
	:align(display.CENTER, 60, 88)
	-- setLabelStroke(label,29,cc.c3b(42, 74, 91),1,nil,nil,nil,nil,true)

	local label = cc.ui.UILabel.new({UILabelType = 2, text = "战力", size = 26, color = cc.c3b(46, 76, 75)})
	:addTo(tmpNode)
	:align(display.CENTER, 60, 45)
	-- setLabelStroke(label,29,cc.c3b(42, 74, 91),1,nil,nil,nil,nil,true)

	display.newSprite("#RoleProperty2_img19.png")
		:addTo(tmpNode)
		:pos(145,90)
	display.newSprite("#RoleProperty2_img19.png")
		:addTo(tmpNode)
		:pos(145,47)
	
	self.labLev = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
							text="",
							size=24,
							color=cc.c3b(255, 246, 207),
							align = cc.TEXT_ALIGNMENT_CENTER,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.CENTER_LEFT, tmpCx-108, tmpCy+16)
						:addTo(tmpNode)

	self.labFp = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
							text="",
							size=24,
							color=cc.c3b(255, 246, 207),
							align = cc.TEXT_ALIGNMENT_CENTER,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.CENTER_LEFT, tmpCx-108, tmpCy-28)
						:addTo(tmpNode)

	--提升按钮
	local btFlag = 1
	self.btnPromote = cc.ui.UIPushButton.new("common/common_nBt1.png")
							    	:align(display.CENTER, tmpCx+90, tmpCy-3)
							    	:addTo(tmpNode)
							    	:onButtonPressed(function(event) event.target:setScale(0.96) end)
							    	:onButtonRelease(function(event) event.target:setScale(1.0) end)
							    	:onButtonClicked(function(event)
							    		self:SelTag(4)
							    		-- self:ShowPDPanel(true)
							    		self:reloadProLevelData()
							    		
							    	end)
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "职业提升", size = 29, color = cc.c3b(228, 255, 249)})
	:addTo(self.btnPromote)
	:align(display.CENTER, 0, 4)
	setLabelStroke(label,29,cc.c3b(42, 74, 91),1,nil,nil,nil,nil,true)

	--右面板
	tmpSize = cc.size(445, 559)
	self.rPanel = display.newScale9Sprite("#RoleProperty2_img1.png", nil, nil, tmpSize)
								:align(display.CENTER, display.cx+275, display.cy-40)
								:addTo(self)
	--标签按钮（属性、装备）
	local function TagOnClicked(event)
		local nTag = event.target:getTag()
		self:SelTag(nTag)
	end
	tmpTab = {"#Role_Text1.png", "#Role_Text2.png", "#Role_Text7.png"}
	local tmpBtImg = {{normal="#RoleProperty2_img4.png", disabled="#RoleProperty2_img4.png"},
						{normal="#RoleProperty2_img5.png", disabled="#RoleProperty2_img6.png"},
						{normal="#RoleProperty2_img5.png", disabled="#RoleProperty2_img6.png"}}
	local size = cc.size(569, 516)
	local tmpBtPos = {
		cc.p(self.lPanel:getPositionX(), self.lPanel:getPositionY()+self.lPanel:getContentSize().height/2-10),
		cc.p(self.lPanel:getPositionX()-170, self.lPanel:getPositionY()+self.lPanel:getContentSize().height/2-10),
		cc.p(self.lPanel:getPositionX()+170, self.lPanel:getPositionY()+self.lPanel:getContentSize().height/2-10)}
	self.Tag = {}
	for i=#tmpTab, 1, -1 do
		self.Tag[i] = {}
		--标签按钮
		self.Tag[i].btn = cc.ui.UIPushButton.new(tmpBtImg[i])
					    	:align(display.CENTER_BOTTOM, tmpBtPos[i].x, tmpBtPos[i].y)
					    	:addTo(self)
					    	:onButtonClicked(TagOnClicked)
		self.Tag[i].btn:setTag(i)

		if i==1 then
			self.labName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 26, color = cc.c3b(169, 170, 151)})
			:addTo(self.Tag[i].btn)
			:align(display.CENTER, 0, 25)
		elseif i==2 then
			self.Tag[i].btnLab = cc.ui.UILabel.new({UILabelType = 2, text = "装备", size = 24, color = cc.c3b(116, 178, 175)})
			:addTo(self.Tag[i].btn)
			:align(display.CENTER, 0, 20)
		elseif i==3 then
			self.Tag[i].btnLab = cc.ui.UILabel.new({UILabelType = 2, text = "技能", size = 24, color = cc.c3b(116, 178, 175)})
			:addTo(self.Tag[i].btn)
			:align(display.CENTER, 0, 20)
		end
		-- display.newSprite(tmpTab[i])
		-- 	:align(display.CENTER, 70, 25)
		-- 	:addTo(self.Tag[i].btn)

		--对应标签面板
		self.Tag[i].panel = display.newNode()
								:addTo(self.rPanel)
	end
	self:ShowPDPanel()

	--前翻按钮
	tmpNode = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    	:align(display.CENTER, display.cx-570, display.cy-20)
    	:addTo(self)
    	:onButtonPressed(function(event)
    		event.target:setScale(1.1)
    	end)
    	:onButtonRelease(function(event)
    		event.target:setScale(1)
    	end)
    	:onButtonClicked(function(event)
    		self:ChangeRole(-1)
    	end)
    	-- tmpNode:setScale(1.2)
    local sequence1 = transition.sequence({
     transition.moveBy(tmpNode, {x = -20, y = 0, time = 1.0}),
     transition.moveBy(tmpNode, {x = 20, y = 0, time = 1.0})
     })
    tmpNode:runAction(cc.RepeatForever:create(sequence1))
    self.leftJiantou = tmpNode

    --后翻按钮
    tmpNode = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
		    	:align(display.CENTER, display.cx+550, display.cy-20)
		    	:addTo(self)
		    	:onButtonPressed(function(event)
		    		event.target:setScaleX(-1.1)
		    		event.target:setScaleY(1.1)
		    	end)
		    	:onButtonRelease(function(event)
		    		event.target:setScaleX(-1)
		    		event.target:setScaleY(1)
		    	end)
		    	:onButtonClicked(function(event)
		    		self:ChangeRole(1)
		    	end)
	tmpNode:setScaleX(-1)
	local sequence2 = transition.sequence({
     transition.moveBy(tmpNode, {x = 20, y = 0, time = 1.0}),
     transition.moveBy(tmpNode, {x = -20, y = 0, time = 1.0})
     })
    tmpNode:runAction(cc.RepeatForever:create(sequence2))
    self.rightJiantou = tmpNode
    self.leftJiantou:setVisible(false)
	self.rightJiantou:setVisible(false)

	---------------------------左面板组件---------------------------------------------------------
	tmpSize = self.lPanel:getContentSize()
	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2

	--角色装备组件
	self.EquipWidget = {
		{btn=nil, img=nil, posX=tmpCx-193, posY=tmpCy+190},
		{btn=nil, img=nil, posX=tmpCx-193, posY=tmpCy+40},
		{btn=nil, img=nil, posX=tmpCx-193, posY=tmpCy-110},
		{btn=nil, img=nil, posX=tmpCx+193, posY=tmpCy+190},
		{btn=nil, img=nil, posX=tmpCx+193, posY=tmpCy+40},
		{btn=nil, img=nil, posX=tmpCx+193, posY=tmpCy-110},
	}

	function self.EquipOnClicked(event)
		GuideManager:hideGuideEff()
		local nTag = event.target:getTag()
		print("EquipOnClicked" .. nTag)
		curEqupIdx = nTag
		self:getCurValue(curEqupIdx)
		self:SelTag(2)
		local _scene = cc.Director:getInstance():getRunningScene()
		
		if GuideManager.NextStep==11403 or GuideManager.NextStep==11503 then
			local value = cur_value
			local item = cur_localValue --本地数据Item
			if advancedData[item.id+1] == nil then --换装后才能继续进阶(说明数据错误了)
				GuideManager:removeGuideLayer()
				GuideManager.NextStep=0
				srv_userInfo.guideStep=-1
				GuideManager:forceSendFinishStep(-1,true)
			elseif value.advLvl==10 then --只能进阶（说明数据发生了问题）
				GuideManager:removeGuideLayer()
				GuideManager.NextStep=0
				srv_userInfo.guideStep=-1
				GuideManager:forceSendFinishStep(-1,true)
			else
				GuideManager:_addGuide_2(11503, _scene,handler(self,self.caculateGuidePos))
				GuideManager:_addGuide_2(11403,_scene ,handler(self,self.caculateGuidePos))
			end
		end
		GuideManager:_addGuide_2(20203,_scene ,handler(self,self.caculateGuidePos))

		--选中框处理
		for i=1, #self.EquipWidget do
			if i==nTag then
				self.EquipWidget[i].selectImg:setVisible(true)
			else
				self.EquipWidget[i].selectImg:setVisible(false)
			end
		end
	end

	for i=1, #self.EquipWidget do
		self.EquipWidget[i].btn = cc.ui.UIPushButton.new()
							    	:align(display.CENTER, self.EquipWidget[i].posX, self.EquipWidget[i].posY)
							    	:addTo(self.lPanel)
							    	:onButtonPressed(function(event)
							    		self.EquipWidget[i].selectImg:setVisible(true)
							    		end)
							    	:onButtonRelease(function(event)
							    		self.EquipWidget[i].selectImg:setVisible(false)
							    		end)
							    	:onButtonClicked(self.EquipOnClicked)
		self.EquipWidget[i].btn:setContentSize(133,133)
		self.EquipWidget[i].btn:setTag(i)

		self.EquipWidget[i].selectImg = display.newSprite("#Role_Text26.png")
		:addTo(self.lPanel,2)
		:align(display.CENTER, self.EquipWidget[i].posX, self.EquipWidget[i].posY)
		self.EquipWidget[i].selectImg:setVisible(false)
		if curEqupIdx~=i then
			self.EquipWidget[i].selectImg:setVisible(false)
		end
	end

	--角色模型切换动画按钮
	self.roleBtn = cc.ui.UIPushButton.new()
						:size(270, 350)
					    :align(display.BOTTOM_CENTER, tmpCx, tmpCy-100)
					    :addTo(self.lPanel)
					    :onButtonClicked(function()
					    	-- self.roleModel[curRoleData.id]:ShowOnceMoveMent()
					    	if nil~=self.roleModel then
					    		self.roleModel:ShowOnceMoveMent()
					    	end
					    end)
	----------------------------------------------------------------------------------------------

	local tmpPanel
	---------------------------属性面板组件(self.Tag[1].panel)------------------------------------
	tmpPanel = self.Tag[1].panel
	tmpSize = self.rPanel:getContentSize()
	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2
	self.attrWidget = {}

	--职业图标
	self.attrWidget.sprPro = display.newSprite("#RoleProperty2_img40.png")
								:align(display.CENTER, 90, tmpSize.height-40)
								:addTo(tmpPanel)
	cc.ui.UILabel.new({UILabelType = 2, text = "职业类别", size = 24, color = cc.c3b(144, 175, 174)})
	:addTo(self.attrWidget.sprPro)
	:pos(5, self.attrWidget.sprPro:getContentSize().height/2)

	--职业描述
	self.attrWidget.labPro = display.newTTFLabel({
								text="",
								size=23,
								color=cc.c3b(35, 24, 21),
								align = cc.TEXT_ALIGNMENT_LEFT,
				                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
				                dimensions = cc.size(380, 106),
							})
							:align(display.TOP_CENTER, tmpCx+10, tmpSize.height-65)
							:addTo(tmpPanel)

	--职业加成
	local tmp = display.newSprite("#RoleProperty2_img40.png")
		:align(display.CENTER, 90, tmpSize.height-155)
		:addTo(tmpPanel)
	cc.ui.UILabel.new({UILabelType = 2, text = "职业加成", size = 24, color = cc.c3b(144, 175, 174)})
	:addTo(tmp)
	:pos(5, tmp:getContentSize().height/2)

	--职业加成描述
	self.attrWidget.labProLabel1 = cc.ui.UILabel.new({
		UILabelType = 2, text = "", size = 24, 
		color = cc.c3b(35, 24, 21)})
	:pos(35, tmpSize.height-195)
	:addTo(tmpPanel)
	self.attrWidget.labProAdd = cc.ui.UILabel.new({
									font = "fonts/slicker.ttf",
									text="",
									size=24,
									color=cc.c3b(248, 210, 45),
								})
								-- :align(display.TOP_CENTER, tmpCx+10, tmpSize.height-205)
								:addTo(tmpPanel)
	self.attrWidget.labProLabel2 = cc.ui.UILabel.new({
		UILabelType = 2, text = "", size = 24, 
		color = cc.c3b(35, 24, 21)})
	:pos(tmpSize.width/2 + 10, tmpSize.height-195)
	:addTo(tmpPanel)
	self.attrWidget.labProAdd2 = cc.ui.UILabel.new({
									font = "fonts/slicker.ttf",
									text="",
									size=24,
									color=cc.c3b(248, 210, 45),
								})
								-- :align(display.TOP_CENTER, tmpCx+200, tmpSize.height-205)
								:addTo(tmpPanel)
	self.attrWidget.labProAdd:setPosition(
		120, 
		self.attrWidget.labProLabel1:getPositionY())
	
	self.attrWidget.labProAdd2:setPosition(
		340, 
		self.attrWidget.labProLabel2:getPositionY())

	self.attrWidget.ret1 = setLabelStroke(self.attrWidget.labProAdd,24,nil,1,nil,nil,nil,"fonts/slicker.ttf")
	self.attrWidget.ret2 = setLabelStroke(self.attrWidget.labProAdd2,24,nil,1,nil,nil,nil,"fonts/slicker.ttf")
	

	--武器技
	local tmp = display.newSprite("#RoleProperty2_img40.png")
		:align(display.CENTER, 90, tmpSize.height-235)
		:addTo(tmpPanel)
	cc.ui.UILabel.new({UILabelType = 2, text = "武器技能", size = 24, color = cc.c3b(144, 175, 174)})
	:addTo(tmp)
	:pos(5, tmp:getContentSize().height/2)
	self.attrWidget.labWeaponSkill = display.newTTFLabel({
										text="",
										size=24,
										color=cc.c3b(35, 24, 21),
										align = cc.TEXT_ALIGNMENT_LEFT,
						                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
									})
									:align(display.LEFT_CENTER, 35, tmpSize.height-275)
									:addTo(tmpPanel)

	--分割线
	local points = {{34, tmpSize.height-320}, {tmpSize.width-34, tmpSize.height-320}}
	display.newLine(points, lineParmas)
		:addTo(tmpPanel)

	--详细属性底板
	tmpSize = cc.size(388, 218)
	local bg = display.newSprite("#RoleProperty2_img51.png")
				:align(display.CENTER, tmpCx, 150)
				:addTo(tmpPanel)

	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2
	-- display.newSprite("#Role_Spr15.png")
	-- 	:align(display.CENTER, tmpCx-130, tmpCy)
	-- 	:addTo(bg)

	-- display.newSprite("#Role_Spr16.png")
	-- 	:align(display.CENTER, tmpCx+60, tmpCy+15)
	-- 	:addTo(bg)

	-- --能量恢复
	-- display.newSprite("common/energy_recovery.png")
	-- :addTo(bg)
	-- :pos(tmpCx+76, 28)

	

	tmpNode = {}
	local pos1Y = {tmpCy+70, tmpCy+32, tmpCy-5, tmpCy-43, tmpCy-83}	--进度条y坐标
	--文本坐标
	local pos2 = {
					{x=tmpCx-90, y=tmpCy+86},
					{x=tmpCx-90, y=tmpCy+47},
					{x=tmpCx-90, y=tmpCy+10},
					{x=tmpCx-75, y=tmpCy-26},
					{x=tmpCx-75, y=tmpCy-66},
				 }
	for i=1, 5 do
		tmpNode[i] = {}
		display.newSprite("#RoleProperty2_img37.png")
			:align(display.CENTER, tmpCx-70, pos1Y[i]+2)
			:addTo(bg)

		--数值
		tmpNode[i].labVal = display.newTTFLabel({
								font = "fonts/slicker.ttf", 
								text="",
								size=18,
								align = cc.TEXT_ALIGNMENT_LEFT,
				                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
							})
							:align(display.LEFT_CENTER, pos2[i].x, pos2[i].y)
							:addTo(bg)

		--进度条
		tmpNode[i].progressBar = display.newProgressTimer("#RoleProperty2_img39.png", display.PROGRESS_TIMER_BAR)
									:align(display.CENTER, tmpCx-70, pos1Y[i]+2)
									:addTo(bg)
		tmpNode[i].progressBar:setMidpoint(cc.p(0, 0.5))
	  	tmpNode[i].progressBar:setBarChangeRate(cc.p(1.0, 0))
	end
	self.attrWidget.STR  = tmpNode[1]
	self.attrWidget.AGL  = tmpNode[2]
	self.attrWidget.VIT  = tmpNode[3]
	self.attrWidget.DEF  = tmpNode[4]
	self.attrWidget.HP   = tmpNode[5]

	pos2 = {
				{x=tmpCx+115, y=tmpCy+81},
				{x=tmpCx+100, y=tmpCy+42},
				{x=tmpCx+100, y=tmpCy+7},
				{x=tmpCx+100, y=tmpCy-31},
				{x=tmpCx+137, y=tmpCy-71},
			 }
	for i=1, 5 do
		tmpNode[i] = {}
		display.newSprite("#RoleProperty2_img37.png")
			:align(display.CENTER, tmpCx+126, pos1Y[i]+4)
			:addTo(bg)

		--数值
		tmpNode[i].labVal = display.newTTFLabel({
								font = "fonts/slicker.ttf", 
								text="",
								size=18,
								align = cc.TEXT_ALIGNMENT_LEFT,
				                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
							})
							:align(display.LEFT_CENTER, pos2[i].x+7, pos2[i].y+6)
							:addTo(bg)

		--进度条
		tmpNode[i].progressBar = display.newProgressTimer("#RoleProperty2_img39.png", display.PROGRESS_TIMER_BAR)
									:align(display.CENTER, tmpCx+126, pos1Y[i]+4)
									:addTo(bg)
		tmpNode[i].progressBar:setMidpoint(cc.p(0, 0.5))
	  	tmpNode[i].progressBar:setBarChangeRate(cc.p(1.0, 0))
	end
	self.attrWidget.ATK  	= tmpNode[1]
	self.attrWidget.CRI  	= tmpNode[2]
	self.attrWidget.HIT  	= tmpNode[3]
	self.attrWidget.MISS 	= tmpNode[4]
	self.attrWidget.ENERGY 	= tmpNode[5]

	
	-----------------------------------------------------------------------------------------


	----------------------------装备信息面板组件(self.Tag[2].panel)--------------------------
	-----------------------------------------------------------------------------------------
    self:CreateSkillPanel()
	self:InitLocData()
	print("------------------------")
	print(self.params.seltag)
	self:SelTag(self.params.seltag or 1)
	--新手引导
	local _scene = cc.Director:getInstance():getRunningScene()
    GuideManager:_addGuide_2(11402,_scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11502,_scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(12102,_scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(20202,_scene,handler(self,self.caculateGuidePos))
end

--本地数据初始化
function RolePropertyLayer:InitLocData()
	self.nCurRoleIndex = 1
	
end

function RolePropertyLayer:SelTag(nIndex)
	if nil==nIndex then
		return
	end
	if nIndex==4 then --职业提升
		for i=1, #self.Tag do
			self.Tag[i].btn:setLocalZOrder(3-i)
			self.Tag[i].btn:setButtonEnabled(true)
			self.Tag[i].panel:setVisible(false)
		end
		self.lPanel2:setVisible(true)
		self.btnPromote:setButtonEnabled(false)
		return
	end

	for i=1, #self.Tag do
		if nIndex==i then
			self.Tag[i].btn:setLocalZOrder(4)
			self.Tag[i].btn:setButtonEnabled(false)
			self.Tag[i].panel:setVisible(true)
			if i~=1 then
				self.Tag[i].btnLab:setColor(cc.c3b(61, 102, 100))
			end
		else
			self.Tag[i].btn:setLocalZOrder(3-i)
			self.Tag[i].btn:setButtonEnabled(true)
			self.Tag[i].panel:setVisible(false)
			if i~=1 then
				self.Tag[i].btnLab:setColor(cc.c3b(116, 178, 175))
			end
		end
	end
	self.lPanel2:setVisible(false)
	self.btnPromote:setButtonEnabled(true)
	--装备的升级或进阶界面显示
	if nIndex==2 then
		self:refreshUpgradePanel()
	end

	print("点击"..nIndex)
	if nIndex==3 then
		GuideManager:_addGuide_2(12103, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
	end
end

--创建技能面板
function RolePropertyLayer:CreateSkillPanel()
	local panel = self.Tag[3].panel
	local tmpSize = self.rPanel:getContentSize()
	
end

--刷新左面板(默认为当前角色thisID)
function RolePropertyLayer:RefreshlPanel(nThisID)
	if nil==nThisID then
		nThisID = self.sortList[self.nCurRoleIndex]
	end

	local valTab = RoleManager.roleIDKeyList[nThisID]
	local srv_Item
	local tmpSize = self.lPanel:getContentSize()
	local tmpCx, tmpCy = tmpSize.width/2, tmpSize.height/2

	--角色名、等级、战斗力
	self.labName:setString(valTab.name)
	self.labLev:setString(RoleManager.srv_RoleProp.teamLevel)
	self.labFp:setString(math.floor(valTab.strength))


	
	-- for i,value in pairs(RoleManager.roleIDKeyList) do
	-- 	if value.id == nThisID then
	-- 		if nil~=self.roleModel[value.id] then
	-- 			self.roleModel[value.id]:removeFromParent()
	-- 			self.roleModel[value.id] = nil
	-- 		end
			
	-- 		self.roleModel[value.id] = ShowModel.new({modelType=ModelType.Hero, templateID=value.tmpId})
	-- 						:pos(tmpCx, tmpCy-150)
	-- 					    :addTo(self.lPanel, 1)
	-- 		self.roleModel[value.id]:setVisible(true)
	-- 		SetModelParams(self.roleModel[value.id], {fScale=1.3})
	-- 	else
	-- 		self.roleModel[value.id]:setVisible(false)
	-- 	end
	-- end
	--角色模型
	if nil~=self.roleModel then
		self.roleModel:removeFromParent()
		self.roleModel = nil
	end
	print("----------------")
	print(valTab.tmpId)
	self.roleModel = ShowModel.new({modelType=ModelType.Hero, templateID=valTab.tmpId})
						:pos(tmpCx, tmpCy-60)
					    :addTo(self.lPanel, 1)
	SetModelParams(self.roleModel, {fScale=1.0})

	self.eptIcon = {}
	self.eptIconIdx = {}
	self.changePro = 0
	for i=1, 6 do
		self.lPanel:removeChildByTag(1000+i)
		if self.eptIcon[i] then
			self.eptIcon[i] =nil
		end
	end
	--装备
	for i=1, #self.EquipWidget do
		local itemID = valTab.equip[i]
		if nil~=self.EquipWidget[i].img then
			self.EquipWidget[i].img:removeFromParent()
			self.EquipWidget[i].img = nil
		end

		if 0~=itemID and nil~=itemID then
			print(itemID)
			srv_Item = srv_carEquipment["memIt"][itemID]
			self.EquipWidget[i].img = createItemIcon(srv_Item.tmpId)
			self.EquipWidget[i].img:addTo(self.lPanel)
								   :align(display.CENTER, self.EquipWidget[i].posX, self.EquipWidget[i].posY)
			self:bItemCanUpgrade(self.EquipWidget[i].img, srv_Item.tmpId)

			local Eqlevel = string.sub(srv_Item.tmpId, 7, 7) - 1
			if Eqlevel>0 then
				local label = cc.ui.UILabel.new({
					font = "fonts/slicker.ttf", UILabelType = 2, text = "+"..(Eqlevel), size = 25, 
					color = cc.c3b(255, 219, 77)})
				:addTo(self.EquipWidget[i].img, 3)
				:pos(-47, -37)
				setLabelStroke(label,25,nil,nil,nil,nil,nil,"fonts/slicker.ttf", true)
				
			end
			--枪，帽子，衣服，手，鞋，背心图标
			-- print(srv_Item.tmpId)
			if advancedData[srv_Item.tmpId+1]==nil then
				self.eptIcon[#self.eptIcon] = display.newSprite("#RoleProperty2_img"..(19+i)..".png")
				:addTo(self.lPanel, 10, 1000+i)
				:pos(175+(i-1)*45 , 120)
				local tmpTab = {}
				self.changePro = self.changePro + 1
			else
				self.eptIcon[#self.eptIcon] = display.newGraySprite("#RoleProperty2_img"..(19+i)..".png")
				:addTo(self.lPanel, 10, 1000+i)
				:pos(175+(i-1)*45 , 120)
			end
		else
			--枪，帽子，衣服，手，鞋，背心图标
			self.eptIcon[#self.eptIcon] = display.newGraySprite("#RoleProperty2_img"..(19+i)..".png")
				:addTo(self.lPanel, 10, 1000+i)
				:pos(175+(i-1)*45 , 120)
		end
		self.eptIconIdx[#self.eptIconIdx+1] = self.eptIcon[#self.eptIcon]
	end

	--换装按钮进度
	-- print(#self.eptIconIdx/6)
	self.changeEquipmentBt:removeChildByTag(100)
	local img = cc.Sprite:create("common/common_nBt5.png",cc.rect(0,0,166*(self.changePro/6),57))
	:addTo(self.changeEquipmentBt, 0, 100)
	:align(display.CENTER_LEFT, -83, 0)

	local itemID = valTab.equip[1]
	local srv_Item = srv_carEquipment["memIt"][itemID]
	local star = math.modf(srv_Item.tmpId/1000)%10
	if self.changePro==6 then
		if star<6 then
			waitChangeAnimation(self.changeEquipmentBt, 0, 8)
		else
			self.changeEquipmentBt:removeChildByTag(100)
			removeWaitChangeAnimation()
		end
	else
		if star==6 then
			self.changeEquipmentBt:removeChildByTag(100)
		end
		
		removeWaitChangeAnimation()
	end
end

--刷新角色属性(默认为当前角色thisID)
function RolePropertyLayer:RefreshAttr(nThisID)
	if nil==nThisID then
		nThisID = self.sortList[self.nCurRoleIndex]
	end

	local valTab = RoleManager.roleIDKeyList[nThisID]
	local tab = self.attrWidget
	local loc_MemData = memberData[valTab.tmpId]
	local frame, tmpPath, tmpStr, tmpStr2, tmpVal

	-- if "主角"==loc_MemData.name or "女主角"==loc_MemData.name then 		--男女主角
	-- 	self.btnPromote:setVisible(true)
	-- else
	-- 	self.btnPromote:setVisible(false)
	-- end

	--职业图标
	if proType_Tanker==loc_MemData.proType then
		
		tmpStr = "主炮攻击+%.2f%%"
		tmpStr2 = "SE炮攻击+%.2f%%"
	elseif proType_Mechanic==loc_MemData.proType then
		tmpStr = "副炮攻击+%.2f%%"
		tmpStr2 = "生命+%.2f%%"
	else
		tmpStr = "生命+%.2f%%"
		tmpStr2 = "防御+%.2f%%"
	end

	--职业描述
	tab.labPro:setString(loc_MemData.des2)

	--职业加成
	--当前职业的职业养成数据
	-- print("当前职业的职业养成数据")
	local curProfDevData = {}
	for key,value in pairs(profDevData) do
		if value.type==loc_MemData.proType then
			curProfDevData[value.level] = value
		end
	end
	local tmpLab = {"", ""}
	local tmpStr = {"", ""}
 	local nInx = 0
	local curLev_proDevData = curProfDevData[valTab.proLevel]
	if curLev_proDevData.hp2~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "血量"
		tmpStr[nInx] = "+"..(curLev_proDevData.hp2*100).."%"
	end
	if curLev_proDevData.mainAtk~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "主炮攻击"
		tmpStr[nInx] = "+"..(curLev_proDevData.mainAtk*100).."%"
	end
	if curLev_proDevData.subAtk~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "副炮攻击"
		tmpStr[nInx] = "+"..(curLev_proDevData.subAtk*100).."%"
	end
	if curLev_proDevData.defense2~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "防御"
		tmpStr[nInx] = "+"..(curLev_proDevData.defense2*100).."%"
	end
	if curLev_proDevData.cri2~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "暴击"
		tmpStr[nInx] = "+"..(curLev_proDevData.cri2*100).."%"
	end
	if curLev_proDevData.hit2~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "命中"
		tmpStr[nInx] = "+"..(curLev_proDevData.hit2*100).."%"
	end
	if curLev_proDevData.miss2~=0 then
		nInx = nInx + 1
		tmpLab[nInx] = "避闪"
		tmpStr[nInx] = "+"..(curLev_proDevData.miss2*100).."%"
	end

	-- local addArr = string.split(loc_MemData.proTypeF, "|")
	-- local add1 = valTab.proLevel*tonumber(addArr[1])
	-- local add2 = valTab.proLevel*tonumber(addArr[2])
	-- tmpStr = string.format(tmpStr, add1)
	-- tmpStr2 = string.format(tmpStr2, add2)
	if tmpStr[1]=="" then
		tmpStr[1] = "无座驾加成"
	end
	self.attrWidget.labProLabel1:setString(tmpLab[1])
	self.attrWidget.labProLabel2:setString(tmpLab[2])

	tab.labProAdd:setString(tmpStr[1])
	tab.labProAdd2:setString(tmpStr[2])

	setLabelStrokeString(tab.labProAdd, tab.ret1)
	setLabelStrokeString(tab.labProAdd2, tab.ret2)

	--详细属性
	tab.STR.labVal:setString(string.format("%d", valTab.power))
	tab.STR.progressBar:setPercentage(valTab.power/500*100)

	tab.AGL.labVal:setString(string.format("%d", valTab.agility))
	tab.AGL.progressBar:setPercentage(valTab.agility/300*100)

	tab.VIT.labVal:setString(string.format("%d", valTab.energy))
	tab.VIT.progressBar:setPercentage(valTab.energy/600*100)

	tab.HP.labVal:setString(string.format("%d", valTab.hp))
	tab.HP.progressBar:setPercentage(valTab.hp/20000*100)

	tab.ATK.labVal:setString(string.format("%d", valTab.attack))
	tab.ATK.progressBar:setPercentage(valTab.attack/3000*100)

	tab.DEF.labVal:setString(string.format("%d", valTab.defense))
	tab.DEF.progressBar:setPercentage(valTab.defense/1000*100)

	tmpVal = valTab.cri/10
	tmpStr = string.format("%.2f%%", tmpVal)
	tab.CRI.labVal:setString(tmpStr)
	tab.CRI.progressBar:setPercentage(tmpVal)

	tmpVal = valTab.hit/10
	tmpStr = string.format("%.2f%%", tmpVal)
	tab.HIT.labVal:setString(tmpStr)
	tab.HIT.progressBar:setPercentage(tmpVal)

	tmpVal = valTab.miss/10
	tmpStr = string.format("%.2f%%", tmpVal)
	tab.MISS.labVal:setString(tmpStr)
	tab.MISS.progressBar:setPercentage(tmpVal)

	tmpVal = valTab.erecover/10*100
	tmpStr = string.format("%.2f%%", tmpVal)
	tab.ENERGY.labVal:setString(valTab.erecover)
	tab.ENERGY.progressBar:setPercentage(tmpVal)

	--武器技
	-- print("武器技")
	local itemId = curRoleData["equip"][1]
	local value = srv_carEquipment["memIt"][itemId]
	local localValue = itemData[value.tmpId]
	local lcl_skl = skillData[localValue.sklId]
	tab.labWeaponSkill:setString(lcl_skl.sklDes)
end

--刷新技能面板
function RolePropertyLayer:RefreshSkillPanel(nThisID)
	local panel = self.Tag[3].panel
	panel:removeAllChildren()
	local tmpSize = self.rPanel:getContentSize()
	local tmpCx = tmpSize.width/2
	local tmpCy = tmpSize.height/2

	local label = cc.ui.UILabel.new({UILabelType = 2, text = "剩余技能点：", size = 22, color = cc.c3b(61, 102, 100)})
	:addTo(panel)
	:pos(25, tmpSize.height - 40)
	self.labSkillPoints = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
									text="0",
									size=22,
									color=cc.c3b(217, 221, 192),
									align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, 25+label:getContentSize().width, tmpSize.height-40)
								:addTo(panel)
	self.retNodePoints = setLabelStroke(self.labSkillPoints,22,nil,1,nil,nil,nil,"fonts/slicker.ttf")
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "下一级增加：", size = 22, color = cc.c3b(61, 102, 100)})
	:addTo(panel)
	:pos(tmpCx+10, tmpSize.height - 40)

	self.nextLevSklPoints = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22, color=cc.c3b(61, 102, 100)})
	:addTo(panel)
	:pos(tmpCx+10+ label:getContentSize().width, tmpSize.height - 40)

	local sklPt = 3
	if srv_userInfo.level<=20 then
		sklPt = 3
	elseif srv_userInfo.level>20 and srv_userInfo.level<=40 then
		sklPt = 6
	elseif srv_userInfo.level>40 and srv_userInfo.level<=60 then
		sklPt = 8
	elseif srv_userInfo.level>60 then
		sklPt = 10
	end
	self.nextLevSklPoints:setString(sklPt)



    self.skillProBox = display.newSprite("#RoleProperty2_img35.png")
	:addTo(panel,0)
	:pos(tmpSize.width/2, tmpSize.height - 120-103)
	--技能描述
    self.skillDesLab = display.newTTFLabel({
									text="",
									size=22,
									color= cc.c3b(35, 24, 21),
									align = cc.ui.TEXT_ALIGN_LEFT,
						            -- valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            -- dimensions = cc.size(370, 115),
								})
								:align(display.TOP_CENTER, self.skillProBox:getContentSize().width/2, 90)
								:addTo(self.skillProBox)
								self.skillDesLab:setWidth(350)
								self.skillDesLab:setLineHeight(25)

	--技能加成描述
	self.skillProALab = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
	:addTo(self.skillProBox)
	:align(display.TOP_CENTER, self.skillProBox:getContentSize().width/2, 40)


	if nil==nThisID then
		nThisID = self.sortList[self.nCurRoleIndex]
	end
	local valTab = RoleManager.roleIDKeyList[nThisID]

	self.labSkillPoints:setString(srv_userInfo.sklPoint)
	setLabelStrokeString(self.labSkillPoints, self.retNodePoints)

	local bgPosY = {tmpSize.height - 120, tmpSize.height - 240, tmpSize.height - 360 }

	local function SkillOnClicked(event)
		local nTag = event.target:getTag()
		local loc_Skl = skillData[nTag]
		local curSklLvl = 0
		local clickIdx = 3
		for i=1, #valTab.skl do
			if event.target:getTag()==valTab.skl[i].id then
				clickIdx = i
				curSklLvl = valTab.skl[i].lvl
				self:addSkillNum(loc_Skl, curSklLvl)
				self.skillWidget[i].bg:setButtonEnabled(false)
				self.skillWidget[i].bg:setPositionY(bgPosY[i])
				self.skillProBox:setPositionY(bgPosY[i]-103)
			else
				self.skillWidget[i].bg:setButtonEnabled(true)
				if i>clickIdx then
					self.skillWidget[i].bg:setPositionY(bgPosY[i]-103)
				else
					self.skillWidget[i].bg:setPositionY(bgPosY[i])
				end
				
			end
		end
		
	end

	local function UpOnClicked(event)
		local nTag = event.target:getTag()
		RoleManager:ReqUpSkill(nThisID, self.skillWidget[nTag].skillId)
        
		GuideManager:_addGuide_2(12104, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
		startLoading()
		-- local clickIdx = 3
		for i=1, #valTab.skl do
			if self.skillWidget[nTag].skillId==valTab.skl[i].id then
				self.skillIdx = i
				-- clickIdx = i
				-- curSklLvl = valTab.skl[i].lvl
				-- self.skillWidget[i].bg:setButtonEnabled(false)
				-- self.skillWidget[i].bg:setPositionY(bgPosY[i])
				-- self.skillProBox:setPositionY(bgPosY[i]-103)
			else
				-- self.skillWidget[i].bg:setButtonEnabled(true)
				-- if i>clickIdx then
				-- 	self.skillWidget[i].bg:setPositionY(bgPosY[i]-103)
				-- else
				-- 	self.skillWidget[i].bg:setPositionY(bgPosY[i])
				-- end
				
			end
		end
		-- self.skillIdx = event.target:getTag()
	end

	self.skillWidget = {}
	self.skillIcon = {}
	
	for i=1, #valTab.skl do
		-- local item = listView:newItem()
		-- table.insert(self.item, item)
        -- local content = display.newNode()
        -- item:addContent(content)
        -- if i==1 then
        -- 	item:setItemSize(bgSize.width, bgSize.height+10+95)
        -- else
        -- 	item:setItemSize(bgSize.width, bgSize.height+10)
        -- end
        -- listView:addItem(item)
        -- local itW,itH = item:getItemSize()

        local skillId = valTab.skl[i].id
        local skillLev = valTab.skl[i].lvl
        local loc_Skl = skillData[skillId]

        local bg = cc.ui.UIPushButton.new({
        	normal = "common/common_Img2.png",
        	disabled = "common/common_Img1.png"
        	})
        			:addTo(panel, 1, 100+i)
        			:pos(tmpSize.width/2, tmpSize.height - 120 - (i-1)*120)
        			:onButtonClicked(SkillOnClicked)
        bg:setTag(skillId)
        bg:setTouchSwallowEnabled(false)
        -- table.insert(self.itembg, bg)


        if i==1 then
        	self:addSkillNum(loc_Skl, skillLev)
        	bg:setButtonEnabled(false)
        else
        	bg:setPositionY(bg:getPositionY() - 103)
        end
        

        local box = display.newSprite("itemBox/box_1.png")
        	:align(display.CENTER, -125, 2)
        	:addTo(bg)

        --技能图标
        -- print(skillId)
        self.skillIcon[i] = display.newSprite("SkillIcon/skillicon" .. skillData[tonumber(skillId)]["resId2"] .. ".png")
        	:align(display.CENTER, -125, 2)
        	:addTo(bg)
       	local bar = display.newSprite("#RoleProperty2_img8.png")
        :addTo(self.skillIcon[i])
        :pos(self.skillIcon[i]:getContentSize().width/2+5, 2)
        
								
        	
        if loc_Skl.type1<=3 then
        	--技能角标
	        display.newSprite("SkillIcon/skill_corner"..loc_Skl.type1..".png")
	        :addTo(self.skillIcon[i])
	        :pos(75, 75)
        end

        self.skillWidget[i] = {}
        self.skillWidget[i].bg = bg
        self.skillWidget[i].skillId = skillId
        --技能等级
        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "LV", size = 20,
			color = cc.c3b(216, 186, 57)})
		:addTo(bar)
		:pos(8, bar:getContentSize().height/2-1)
		self.skillWidget[i].labLev = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20,color=cc.c3b(221, 217, 204)})
			:addTo(bar)
			:align(display.CENTER, 45, bar:getContentSize().height/2-2)
			self.skillWidget[i].labLev:setString(skillLev)

        --技能名
        self.skillWidget[i].labName = display.newTTFLabel({
									text="",
									size=28,
									color = cc.c3b(28, 29, 33),
									align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, -70, 30)
								:addTo(bg)
		

		--升级按钮
		self.skillWidget[i].btnUp = cc.ui.UIPushButton.new("#RoleProperty2_img36.png")
						    	:align(display.CENTER, 120, bg:getContentSize().height/2)
						    	:addTo(bg)
						    	:onButtonPressed(function(event) event.target:setScale(0.95) end)
								:onButtonRelease(function(event) event.target:setScale(1.0) end)
						    	:onButtonClicked(UpOnClicked)
		self.skillWidget[i].btnUp:setTag(i)
		--未激活图标
		self.skillWidget[i].isActive = display.newSprite("SingleImg/BackPack/unactivate.png")
		:addTo(bg)
		:pos(120, 0)

		--升级消耗
		self.skillWidget[i].sprCost = display.newSprite("common/common_GoldGet.png")
												:align(display.CENTER, -45, -20)
												:addTo(bg)
												:scale(0.5)

		self.skillWidget[i].labCost = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
									text="",
									size=22,
									color=cc.c3b(255, 241, 0),
									align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, -15, -25-2)
								:addTo(bg)

		if nil~=loc_Skl then
			self.skillWidget[i].labName:setString(loc_Skl.sklName)
		end
		if skillLev<=-1 then
			bar:setVisible(false)
			local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
			:addTo(bg)
			:pos(-60,-25)
			if i==1 then
				label:setString("10级开启")
			elseif i==2 then
				label:setString("蓝装开启")
				label:setColor(cc.c3b(32, 48, 117))
			elseif i==3 then
				label:setString("紫装开启")
				label:setColor(cc.c3b(102, 14, 119))
			end
			self.skillWidget[i].btnUp:setVisible(false)
			self.skillWidget[i].sprCost:setVisible(false)
			self.skillWidget[i].labCost:setVisible(false)
			self.skillWidget[i].isActive:setVisible(true)
			
		else
			bar:setVisible(true)
			-- self.skillWidget[i].labLev:setString(skillLev)
			self.skillWidget[i].btnUp:setVisible(true)
			self.skillWidget[i].sprCost:setVisible(true)
			self.skillWidget[i].labCost:setString(skillLev*RoleSkillUpCostFactor[i])
			self.skillWidget[i].labCost:setVisible(true)
			self.skillWidget[i].isActive:setVisible(false)
		end

        
	end
	-- listView:reload()
end

--技能升级数据显示
function RolePropertyLayer:addSkillNum(loc_Skl, skillLev)
	local str = ""
	local proStr = ""
	if nil~=loc_Skl then
		str = loc_Skl.sklDes
		local addNum = 0
		local tmpstr = ""
		if skillLev<=0 then
    		proStr = ""
    	else
			if loc_Skl.add>0 or loc_Skl.addPercent>0 or 
			loc_Skl.addPercentGF>0 or loc_Skl.addGF>0 then --有技能伤害
				if loc_Skl.addGF==0 then
					addNum = loc_Skl.addPercentGF*100
					tmpstr = "%"
				else
					addNum = loc_Skl.addGF
				end
			else 					  --有buff伤害
				local loc_Buff = buffData[loc_Skl.buffId]
				if loc_Buff.valueGF==0 then
					addNum = loc_Buff.valuePercentGF*100
					tmpstr = "%"
				else
					addNum = loc_Buff.valueGF
				end
			end
			-- print(loc_Skl.sklDes2)
			-- print(tostring(addNum))
			addNum = math.abs(addNum*(skillLev-1))
			proStr = string.gsub(json.encode(loc_Skl.sklDes2),"#",tostring(addNum))
			proStr = string.sub(proStr, 2, #proStr-1)
			proStr = proStr..tmpstr
		end
	end
	self.skillDesLab:setString(str)
	self.skillProALab:setString(proStr)
end

--刷新技能项
function RolePropertyLayer:RefreshSkillItem(nThisID, nSkillID)
	if nil==nThisID then
		nThisID = self.sortList[self.nCurRoleIndex]
	end
	local valTab = RoleManager.roleIDKeyList[nThisID]

	for i=1, #valTab.skl do
        local skillId = valTab.skl[i].id
        if nSkillID==skillId then
        	printTable(valTab.skl[i])
	        local skillLev = valTab.skl[i].lvl
	        self.skillWidget[i].labLev:setString(skillLev)
	        self.skillWidget[i].labCost:setString(skillLev*RoleSkillUpCostFactor[i])
	        break
	    end
    end
end

--刷新全部UI(默认为当前角色thisID)
function RolePropertyLayer:RefreshUI(nThisID)
	if nil==nThisID then
		nThisID = self.sortList[self.nCurRoleIndex]
	end
	self:RefreshlPanel(nThisID)
	self:RefreshAttr(nThisID)
	self:performWithDelay(function()
		self:RefreshSkillPanel(nThisID)
	end, 0.1)

	if #self.sortList>1 then
		self.leftJiantou:setVisible(true)
		self.rightJiantou:setVisible(true)
		self.rightJiantou:setScaleX(-1)
	else
		self.leftJiantou:setVisible(false)
		self.rightJiantou:setVisible(false)
	end
	
end

--角色数据返回
function RolePropertyLayer:OnRolePropertyDataRet(cmd)
	print("人物界面加载 用时："..(socket.gettime()-g_startTime))
	endLoading()
	if 1==cmd.result then
		self:InitSortList()
		self:updateRoleData() --更新角色数据

		-- self.roleModel = {}
		-- --角色模型
		-- local tmpCx = self.lPanel:getContentSize().width/2
		-- local tmpCy = self.lPanel:getContentSize().height/2
		-- for i,value in pairs(RoleManager.roleIDKeyList) do
		-- 	self.roleModel[value.id] = ShowModel.new({modelType=ModelType.Hero, templateID=value.tmpId})
		-- 					:pos(tmpCx, tmpCy-150)
		-- 				    :addTo(self.lPanel, 1)
		-- 	self.roleModel[value.id]:setVisible(false)
		-- end

		self:RefreshUI()
		for i=1,6 do
			if curEqupIdx==i then
				self.EquipWidget[i].selectImg:setVisible(true)
			end
		end
		
	else
		showTips(cmd.msg)
	end
	
end

--提升技能返回
function RolePropertyLayer:OnUpSkillRet(cmd)
	if 1==cmd.result then
		local tabInfo = nil
		for key,value in ipairs(RoleManager.srv_RoleProp.members) do
			if value.id==curRoleData.id then
				tabInfo = value
				break
			end
		end
		tabInfo.strength = cmd.data.strength
		-- printTable(tabInfo)
		self:UpdateSingleRole(tabInfo)
		self:RefreshUI()

		self.labSkillPoints:setString(srv_userInfo.sklPoint)
		setLabelStrokeString(self.labSkillPoints, self.retNodePoints)
		self:RefreshSkillItem(nil, cmd.data.sklId)
		mainscenetopbar:setGlod()

		--技能升级特效
		local note = self.skillIcon[self.skillIdx]
		skillUpAnimation(note, note:getContentSize().width/2, note:getContentSize().height/2)

		--提升数据显示
		local loc_Skl = skillData[cmd.data.sklId]
		local skillLev
		for i=1, #curRoleData.skl do
			if cmd.data.sklId==curRoleData.skl[i].id then
				skillLev = curRoleData.skl[i].lvl
				break
			end
		end
		local addNum = 0
		local chaStr = ""
		local tmpStr = ""
		local proStr = ""
		local pAn = 0
		if loc_Skl.add>0 or loc_Skl.addGF>0 or
			loc_Skl.addPercent>0 or loc_Skl.addPercentGF>0 then --技能没有buff
			if loc_Skl.addGF==0 then
				addNum = loc_Skl.addPercentGF*100
				tmpStr = "%"
				pAn = loc_Skl.addPercent
			else
				addNum = loc_Skl.addGF
				pAn = loc_Skl.add
			end
			if pAn<=0 then
				chaStr = chaStr.."治疗"
			else
				chaStr = chaStr.."伤害"
			end
		else 					  --技能有buff
			local loc_Buff = buffData[loc_Skl.buffId]
			-- printTable(loc_Buff)
			if loc_Buff.valueGF==0 then
				addNum = loc_Buff.valuePercentGF*100
				tmpStr = "%"
			else
				addNum = loc_Buff.valueGF
			end
			chaStr = chaStr..SkillBuffType[loc_Buff.type]
		end

		local chaLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 24, color = cc.c3b(255, 255, 0)})
		:addTo(note,10)
		:align(display.CENTER_RIGHT, note:getContentSize().width/2-20, note:getContentSize().height)
		chaLabel:setString(chaStr)
		-- addNum = math.abs(initNum + addNum*(skillLev-1))
		proStr = "+"..addNum..tmpStr
		local proLable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
		:addTo(note,10)
		:align(display.CENTER_LEFT, note:getContentSize().width/2-10, note:getContentSize().height)
		proLable:setString(proStr)

		local moveAct = cc.MoveBy:create(1, cc.p(0, 50))
		local FadeOut = cc.FadeOut:create(2)
		local seq = transition.sequence({moveAct,
			cc.CallFunc:create(function()
				proLable:removeSelf()
				end)})
		proLable:runAction(FadeOut)
		proLable:runAction(seq)

		local moveAct = cc.MoveBy:create(1, cc.p(0, 50))
		local FadeOut = cc.FadeOut:create(2)
		local seq = transition.sequence({moveAct,
			cc.CallFunc:create(function()
				chaLabel:removeSelf()
				end)})
		chaLabel:runAction(FadeOut)
		chaLabel:runAction(seq)

		self:addSkillNum(loc_Skl, skillLev)
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--更改角色（nStep[1:后翻  -1:前翻]）
function RolePropertyLayer:ChangeRole(nStep)
	local nNum = #self.sortList
	self.nCurRoleIndex = self.nCurRoleIndex+nStep
	if self.nCurRoleIndex>nNum then
		self.nCurRoleIndex = 1
	elseif self.nCurRoleIndex<=0 then
		self.nCurRoleIndex = nNum
	end

	self:updateRoleData()  --切换角色时更新角色数据
	self:getCurValue(curEqupIdx)
	self:RefreshUI()
	self:refreshUpgradePanel()

	if self.lPanel2 then --切换角色更新职业提升界面，如果已经打开
		self:reloadProLevelData()
	end
	
end

--更新单独角色
function RolePropertyLayer:UpdateSingleRole(tabInfo)
	if nil==tabInfo or nil==RoleManager.srv_RoleProp then
		return
	end

	local key, val
	for i=1, #RoleManager.srv_RoleProp.members do
		val = RoleManager.srv_RoleProp.members[i]
		key = val.id
		if key==tabInfo.id then
			RoleManager.srv_RoleProp.members[i] = tabInfo
			RoleManager.roleIDKeyList[key] = tabInfo
			break
		end
	end
end

--初始化排序列表
function RolePropertyLayer:InitSortList()
	if nil==RoleManager.roleIDKeyList then
		return
	end

	self.sortList = {}
	for k, _ in pairs(RoleManager.roleIDKeyList) do
		table.insert(self.sortList, k)
	end

	local function SortFunc(val1, val2)
		return val1<val2
	end
	table.sort(self.sortList, SortFunc)
end

--显示职业养成面板
function RolePropertyLayer:ShowPDPanel()
	self.lPanel2 =display.newNode()
	:addTo(self.rPanel)
	--再加一层
	--左面板
	tmpSize = self.rPanel:getContentSize()

	--箭头
	display.newSprite("#RoleProperty2_img29.png")
	:addTo(self.lPanel2)
	:pos(tmpSize.width/2 , tmpSize.height/2 + 100)

	local boxPos = {
		{posX = tmpSize.width/2-110,posY =tmpSize.height/2 + 80 },
		{posX = tmpSize.width/2+110,posY =tmpSize.height/2 + 80 },
	}
	local labelsTab = {}
	for i=1,#boxPos do
		labelsTab[i] = {}
		local tsBox = display.newNode()
		:addTo(self.lPanel2)
		:pos(boxPos[i].posX,boxPos[i].posY)

		local labelPos = {
			{x = tsBox:getContentSize().width/2, y = tsBox:getContentSize().height - 40},
			{x = tsBox:getContentSize().width/2, y = tsBox:getContentSize().height/2-52},
			{x = tsBox:getContentSize().width/2, y = 40},
		}
		local bar
		if i==1 then
			bar = display.newSprite("#RoleProperty2_img27.png")
		else
			bar = display.newSprite("#RoleProperty2_img28.png")
		end
		bar:addTo(tsBox)
		bar:pos(labelPos[1].x, labelPos[1].y+150)

		display.newSprite("#RoleProperty2_img30.png")
		:addTo(tsBox)
		:pos(labelPos[2].x, labelPos[2].y-20)


		--职业名称
		labelsTab[i].proName = cc.ui.UILabel.new({UILabelType = 2, text = "", 
			size = 25, color = cc.c3b(255, 255, 0)})
		:addTo(tsBox)
		:align(display.CENTER, labelPos[1].x, labelPos[1].y+150)
		if i==1 then
			labelsTab[i].proName:setColor(cc.c3b(106, 252, 255))
		else
			labelsTab[i].proName:setColor(cc.c3b(255, 242, 85))
		end

		--徽章
		labelsTab[i].badge = display.newSprite("#Role_Spr35.png")
		:addTo(tsBox)
		:pos(tsBox:getContentSize().width/2, tsBox:getContentSize().height/2+18)
		
		--底座加成
		--加成一
		labelsTab[i].label1 = cc.ui.UILabel.new({UILabelType = 2, text = "",
			size = 23, color = MYFONT_COLOR})
		:addTo(tsBox)
		:pos(-90, labelPos[2].y-5)
		labelsTab[i].proAdd1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", 
			size = 23, color = MYFONT_COLOR})
		:addTo(tsBox)
		:pos(-90, labelPos[2].y-5)
		if i==2 then
			print("加成一箭头")
			labelsTab[i].jiantou1 = display.newSprite("#RoleProperty2_img34.png")
			:addTo(tsBox)
			:pos(-90, labelPos[2].y-2)
		end
		
		--加成二
		labelsTab[i].label2 = cc.ui.UILabel.new({UILabelType = 2, text = "",
			size = 23, color = MYFONT_COLOR})
		:addTo(tsBox)
		:pos(-90, labelPos[3].y-135)
		labelsTab[i].proAdd2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", 
			size = 23, color = MYFONT_COLOR})
		:addTo(tsBox)
		:pos(-90, labelPos[3].y-135)
		if i==2 then
			labelsTab[i].jiantou2 = display.newSprite("#RoleProperty2_img34.png")
			:addTo(tsBox)
			:pos(-90, labelPos[3].y-132)
		end
	end
	self.labelsTab = labelsTab


	-- display.newSprite("#Role_Text19.png")
	-- :addTo(self.lPanel2)
	-- :pos(158, 150)
	-- local rightWan = display.newSprite("#Role_Text19.png")
	-- :addTo(self.lPanel2)
	-- :pos(self.lPanel2:getContentSize().width - 158, 150)
	-- rightWan:setScaleX(-1)

	--提升消耗，提升按钮
	local proLevUpBox =  display.newSprite("#RoleProperty2_img31.png")
	:addTo(self.lPanel2)
	:pos(self.rPanel:getContentSize().width/2, 185)
	self.proLevUpBox = proLevUpBox


	self.proTmpNode = {}
	--拥有
	cc.ui.UILabel.new({UILabelType = 2, text = "拥有：", size = 25, color = MYFONT_COLOR})
		:addTo(proLevUpBox)
		:align(display.CENTER_RIGHT, proLevUpBox:getContentSize().width/2-20,  proLevUpBox:getContentSize().height-20)
	display.newSprite("#RoleProperty2_img32.png")
	:addTo(proLevUpBox)
	:pos(proLevUpBox:getContentSize().width/2,  proLevUpBox:getContentSize().height-18)

	self.proTmpNode.haveLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
		:addTo(proLevUpBox)
		:pos(proLevUpBox:getContentSize().width/2 + 25, proLevUpBox:getContentSize().height-20)
		
	--消耗
	cc.ui.UILabel.new({UILabelType = 2, text = "消耗：", size = 25, color = cc.c3b(255, 255, 0)})
		:addTo(proLevUpBox)
		:align(display.CENTER_RIGHT, proLevUpBox:getContentSize().width/2-20,  proLevUpBox:getContentSize().height-55)
	display.newSprite("#RoleProperty2_img32.png")
	:addTo(proLevUpBox)
	:pos(proLevUpBox:getContentSize().width/2,  proLevUpBox:getContentSize().height-53)

	self.proTmpNode.costLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(230, 61, 18)})
		:addTo(proLevUpBox)
		:pos(proLevUpBox:getContentSize().width/2 + 25, proLevUpBox:getContentSize().height-55)
		

	--提升按钮
	local tsBt = cc.ui.UIPushButton.new("common/common_nBt2.png")
	:addTo(proLevUpBox)
	:pos(proLevUpBox:getContentSize().width/2, -50)
	:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "提升", size = 27, 
					color = cc.c3b(127, 79, 33)}))
	:onButtonPressed(function(event) event.target:setScale(0.95) end)
	:onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		if srv_userInfo.honor<proLevcost_honor then
			showTips("荣誉不足")
			return
		end
		-- self:showProfAddData()
		local nThisID = self.sortList[self.nCurRoleIndex]
		startLoading()
		local tabMsg  = {}
		tabMsg["memberId"] = nThisID
    	m_socket:SendRequest(json.encode(tabMsg), CMD_PROFESSION_DEVELOP, RoleManager, RoleManager.OnProfDevRet)
		end)
	setLabelStroke(tsBt:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)

	--获取按钮
	local bt = cc.ui.UIPushButton.new("#RoleProperty2_img32.png")
	:addTo(self.lPanel2)
	:pos(self.rPanel:getContentSize().width/2+100,40)
	:onButtonPressed(function(event) event.target:setScale(0.95) end)
	:onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		self.achievementTree = achievementTree.new()
			:addTo(display.getRunningScene(),51,activityMenuLayerTag.achieveTag)
		end)
	local label = cc.ui.UILabel.new({ UILabelType = 2, text = ">>获取", size = 25, color = cc.c3b(252, 238, 107)})
	:addTo(bt)
	:align(display.CENTER_RIGHT, -20,0)
	-- setLabelStroke(label,25,nil,nil,nil,nil,nil,nil, true)

	local label = cc.ui.UILabel.new({ UILabelType = 2, text = "荣誉点", size = 25, color = cc.c3b(252, 238, 107)})
	:addTo(bt)
	:align(display.CENTER_LEFT, 20,0)
	-- setLabelStroke(label,25,nil,nil,nil,nil,nil,nil, true)
end
--职业提升数据更新
function RolePropertyLayer:reloadProLevelData()
	local labelsTab = self.labelsTab
	local proLevUpBox = self.proLevUpBox

	local nThisID = self.sortList[self.nCurRoleIndex]
	local valTab = RoleManager.roleIDKeyList[nThisID]
	local loc_MemData = memberData[valTab.tmpId]
	local nCurProLev = valTab.proLevel
	--当前职业的职业养成数据
	local curProfDevData = {}
	for key,value in pairs(profDevData) do
		if value.type==loc_MemData.proType then
			curProfDevData[value.level] = value
		end
	end

	--底座加成
	local tmpStr = {"", ""}
	local tmpNum = {{0,0},{0,0}}
	local nIdx
	for i=1,#labelsTab do
		nIdx = 0
		local curLev_proDevData
		if nCurProLev==6 then
			curLev_proDevData = curProfDevData[nCurProLev]
		else
			curLev_proDevData = curProfDevData[nCurProLev+(i-1)]
		end
		self.curLev_proDevData = curLev_proDevData
		if curLev_proDevData.hp2~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "血量"
			tmpNum[i][nIdx] = (curLev_proDevData.hp2*100)
		end
		if curLev_proDevData.mainAtk~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "主炮攻击"
			tmpNum[i][nIdx] = (curLev_proDevData.mainAtk*100)
		end
		if curLev_proDevData.subAtk~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "副炮攻击"
			tmpNum[i][nIdx] = (curLev_proDevData.subAtk*100)
		end
		if curLev_proDevData.defense2~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "防御"
			tmpNum[i][nIdx] = (curLev_proDevData.defense2*100)
		end
		if curLev_proDevData.cri2~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "暴击"
			tmpNum[i][nIdx] = (curLev_proDevData.cri2*100)
		end
		if curLev_proDevData.hit2~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "命中"
			tmpNum[i][nIdx] = (curLev_proDevData.hit2*100)
		end
		if curLev_proDevData.miss2~=0 then
			nIdx = nIdx + 1
			tmpStr[nIdx] = "避闪"
			tmpNum[i][nIdx] = (curLev_proDevData.miss2*100)
		end
	end


	for i=1,#labelsTab do
		if nCurProLev==6 and i==2 then
			labelsTab[i].proName:setString("已到最高级")
			-- labelsTab[i].badge:setVisible(true)
			local frame = display.newSpriteFrame("Role_Spr40.png")
			labelsTab[i].badge:setSpriteFrame(frame)
		else
			--人物称号
			local pronameStr = RoleTitle[loc_MemData.proType][nCurProLev+(i-1)]

			labelsTab[i].proName:setString(pronameStr)

			-- labelsTab[i].badge:setVisible(true)
			local frame = display.newSpriteFrame("Role_Spr"..(33+nCurProLev+i)..".png")
			labelsTab[i].badge:setSpriteFrame(frame)
			
		end

		--加成一
		labelsTab[i].label1:setString(tmpStr[1])
		labelsTab[i].proAdd1:setString(tmpNum[i][1].."%")
		labelsTab[i].proAdd1:setPositionX(labelsTab[i].label1:getPositionX()+labelsTab[i].label1:getContentSize().width+10)
		labelsTab[i].proAdd1:setColor(MYFONT_COLOR)
		if i==2 then labelsTab[i].jiantou1:setVisible(false) end
		if tmpNum[2][1]>tmpNum[1][1] then
			labelsTab[2].proAdd1:setColor(cc.c3b(0, 255, 0))
			if i==2 then
				labelsTab[i].jiantou1:setVisible(true)
				labelsTab[i].jiantou1:setPositionX(labelsTab[i].proAdd1:getPositionX()+labelsTab[i].proAdd1:getContentSize().width+20)
			end
		end

		--加成二
		if nIdx==2 then
			labelsTab[i].label2:setString(tmpStr[2])
			labelsTab[i].proAdd2:setString(tmpNum[i][2].."%")
			labelsTab[i].proAdd2:setPositionX(labelsTab[i].label2:getPositionX()+labelsTab[i].label2:getContentSize().width+10)
			labelsTab[i].proAdd2:setColor(MYFONT_COLOR)
			if i==2 then labelsTab[i].jiantou2:setVisible(false) end
			if tmpNum[2][2]>tmpNum[1][2] then
				labelsTab[2].proAdd2:setColor(cc.c3b(0, 255, 0))
				if i==2 then
					labelsTab[i].jiantou2:setVisible(true)
					labelsTab[i].jiantou2:setPositionX(labelsTab[i].proAdd2:getPositionX()+labelsTab[i].proAdd2:getContentSize().width+20)
				end
			end
		end
			
	end
	--拥有
	self.proTmpNode.haveLabel:setString(srv_userInfo.honor)
	--消耗
	if nCurProLev==6 then
		proLevcost_honor = 0
		self.proTmpNode.costLabel:setString("0")
	else
		proLevcost_honor = curProfDevData[nCurProLev].honor
		self.proTmpNode.costLabel:setString(curProfDevData[nCurProLev].honor)
	end
	
end

function RolePropertyLayer:OnProfDevRet(cmd)
	endLoading()
	if 1==cmd.result then
		RoleManager.roleIDKeyList[cmd.data.memberInfo.id] = cmd.data.memberInfo
		srv_userInfo.honor = srv_userInfo.honor - proLevcost_honor
		self:RefreshUI()
		self:reloadProLevelData()
		self:showProfAddData()
	else
		showTips(cmd.msg)
	end
	endLoading()
end
--职业提升数据显示
function RolePropertyLayer:showProfAddData()
	local delayTime = 0.3
	local tmpSize = self.rPanel:getContentSize()
	--血量
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-15, 300)
	lable:setString("血量")
	transition.fadeOut(lable,{time = 1.0})
	transition.moveBy(lable, {time = 1, x=0, y=150, onComplete = function()
		lable:removeSelf()
		end})
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setString("+"..self.curLev_proDevData.hp1)
	transition.fadeOut(lable,{time = 1.0})
	transition.moveBy(lable, {time = 1, x=0, y=150, onComplete = function()
		lable:removeSelf()
		end})
	--攻击
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-20, 300)
	lable:setVisible(false)
	lable:setString("攻击")
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setVisible(false)
	lable:setString("+"..self.curLev_proDevData.atk1)
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	--防御
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-20, 300)
	lable:setVisible(false)
	lable:setString("防御")
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*2), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*2), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "+100", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setVisible(false)
	lable:setString("+"..self.curLev_proDevData.defense1)
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*2), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*2), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	--暴击
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-20, 300)
	lable:setVisible(false)
	lable:setString("暴击")
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*3), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*3), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "+100", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setVisible(false)
	lable:setString("+"..self.curLev_proDevData.cri1)
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*3), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*3), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	--命中
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-20, 300)
	lable:setVisible(false)
	lable:setString("命中")
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*4), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*4), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "+100", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setVisible(false)
	lable:setString("+"..self.curLev_proDevData.hit1)
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*4), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*4), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	--闪避
	local lable = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_RIGHT, tmpSize.width/2-20, 300)
	lable:setVisible(false)
	lable:setString("闪避")
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*5), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*5), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))
	local lable = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "+100", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.lPanel2,2)
	:align(display.CENTER_LEFT, tmpSize.width/2-10, 300)
	lable:setVisible(false)
	lable:setString("+"..self.curLev_proDevData.miss1)
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*5), 
		cc.CallFunc:create(function() lable:setVisible(true) end), cc.FadeOut:create(1.0)))
	lable:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*5), cc.MoveBy:create(1.0,cc.p(0,150)),
		cc.CallFunc:create(function() lable:removeSelf() end)
		))

end

function RolePropertyLayer:onEnter()
	RolePropertyLayer.Instance = self

	--请求最新数据
	g_startTime = socket.gettime()
	if RoleManager.isReqFlag then
		startLoading()
		RoleManager:ReqRolePropertyData(srv_userInfo["characterId"])
	else
		local cmd = {}
		cmd.result = 1
		cmd.data = RoleManager.srv_RoleProp
		self:OnRolePropertyDataRet(cmd)
	end
	
	
end

function RolePropertyLayer:onExit()
	RolePropertyLayer.Instance = nil
	RolePropertyLayer_Instance = nil
	--资源释放
	-- display.removeSpriteFramesWithFile("Image/UIRoleProperty.plist", "Image/UIRoleProperty.png")
	-- display.removeSpriteFramesWithFile("Image/UIRoleProperty1.plist", "Image/UIRoleProperty1.png")
	-- display.removeSpriteFramesWithFile("Image/UIRoleProperty2.plist", "Image/UIRoleProperty2.png")
end
function RolePropertyLayer:refreshUpgradePanel()
	self.Tag[2].panel:removeAllChildren()
	local tmpPanel = self.Tag[2].panel
	tmpSize = self.rPanel:getContentSize()
	self.EquipInfoWidget = {}

	self:getCurValue(curEqupIdx)
	local value = cur_value
	local item = cur_localValue --本地数据Item
	local advanced = {}  --进阶表的一条数据
	
	--装备名字
	self.EquipInfoWidget.titleBottom = display.newSprite("#RoleProperty2_img11.png")
	:addTo(tmpPanel)
	:pos(tmpSize.width/2,tmpSize.height-40)
	self.EquipInfoWidget.name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	:addTo(self.EquipInfoWidget.titleBottom)
	:pos(self.EquipInfoWidget.titleBottom:getContentSize().width/2,self.EquipInfoWidget.titleBottom:getContentSize().height/2-2)
	self.EquipInfoWidget.name:setAnchorPoint(0.5,0.5)
	self.EquipInfoWidget.name:setString(item.name)
	setLabelStroke(self.EquipInfoWidget.name,25,nil,2,nil,nil,nil,nil, true)
	local star = getItemStar(cur_value.tmpId)
	if star==2 then
		self.EquipInfoWidget.name:setColor(cc.c3b(193, 105, 180))
	elseif star==3 then
		self.EquipInfoWidget.name:setColor(cc.c3b(107, 206, 82))
	elseif star==4 then
		self.EquipInfoWidget.name:setColor(cc.c3b(85, 171, 249))
	elseif star==5 then
		self.EquipInfoWidget.name:setColor(cc.c3b(204, 89, 252))
	end
	
	--装备图标
	self.EquipInfoWidget.icon = createItemIcon(value.tmpId)
	:addTo(tmpPanel)
	:pos(95,tmpSize.height-128)
	--装备等级
	self.EquipInfoWidget.levelImg = display.newSprite("#RoleProperty2_img8.png")
	:addTo(self.EquipInfoWidget.icon, 10)
	:pos(3, - 50)
	cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "LV", size = 20,
		color = cc.c3b(216, 186, 57)})
	:addTo(self.EquipInfoWidget.levelImg)
	:pos(8, self.EquipInfoWidget.levelImg:getContentSize().height/2-1)
	self.EquipInfoWidget.levelNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20})
	:addTo(self.EquipInfoWidget.levelImg)
	:pos(45,self.EquipInfoWidget.levelImg:getContentSize().height/2-1)
	self.EquipInfoWidget.levelNum:setAnchorPoint(0.5,0.5)
	self.EquipInfoWidget.levelNum:setString(value.advLvl)
	--装备技能
	self:addItemSkill(item)

	--升级进度条
	self.EquipInfoWidget.pressBar = display.newSprite("#RoleProperty2_img9.png")
	:addTo(tmpPanel)
	:pos(tmpSize.width/2, 230)
	-- print("value.advLvl:"..value.advLvl)
	for i=1,10 do
		local n = self.EquipInfoWidget.pressBar:getContentSize().width/10
		local pressPoint = display.newSprite("#RoleProperty2_img13.png")
			:addTo(self.EquipInfoWidget.pressBar)
			:pos(19+n*(i-1),self.EquipInfoWidget.pressBar:getContentSize().height/2)
		if i<=value.advLvl then
			local pressPoint = display.newSprite("#RoleProperty2_img12.png")
			:addTo(self.EquipInfoWidget.pressBar)
			:pos(19+n*(i-1),self.EquipInfoWidget.pressBar:getContentSize().height/2)
		end
	end

	--下面的底板
	self.EquipInfoWidget.bottomPanel = display.newSprite("#RoleProperty2_img14.png",tmpSize.width/2, 130)
	:addTo(tmpPanel)

	-- if true then
	-- 	return
	-- end
	--该装备已升到本星级最高，等待换装
	if advancedData[item.id+1]==nil then
		local txt = "需换装后才可继续进阶"
		local star = math.modf(item.id/1000)%10
        if star==6 then
        	txt = "武器装备已达顶阶"
        end

		self.stuffNote = {}
		self:addItemProperty(item,value,3)
		local maxLevel = cc.ui.UILabel.new({UILabelType = 2, text = txt, size = 25,
			color = cc.c3b(255, 255, 0),align = cc.ui.TEXT_ALIGN_CENTER})
		:addTo(tmpPanel)
		:pos(222,140)
		maxLevel:setAnchorPoint(0.5,0.5)
		maxLevel:setWidth(150)

		return
	end

	cc.ui.UILabel.new({UILabelType = 2, text = "所需材料", size = 25, color = cc.c3b(164, 188, 186)})
	:addTo(self.EquipInfoWidget.bottomPanel)
	:pos(7, 125)

	self.dcStuff = ""
	--判断材料是否足够
    self.isStuffEnough = true
    local stuffTab = {}
	local tmpStuff
	advanced = advancedData[item.id]
	if advanced==nil then
		return
	elseif value.advLvl==10 then 	--进阶

		tmpStuff = advanced.stuff
		self.dcStuff = tmpStuff
		if tmpStuff=="null" or tmpStuff==0 then
			self.stuffNote = {}
			self:addItemProperty(item,value,3)

			local maxLevel = cc.ui.UILabel.new({UILabelType = 2, text = "已升级到最高等级", size = 25})
			:addTo(tmpPanel)
			:pos(tmpSize.width/2,50)
			maxLevel:setAnchorPoint(0.5,0.5)
			return
		else
			item2 = itemData[advanced.toItemId]
			self:addItemProperty(item,value,2,item2)
			
			self:performWithDelay(function ()
				--进阶按钮
				local advanceBt = cc.ui.UIPushButton.new("common/common_nBt2.png")
				:addTo(tmpPanel)
				:pos(tmpSize.width/2, 10)
				:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "进阶", size = 27, 
					color = cc.c3b(127, 79, 33)}))
				:onButtonPressed(function(event) event.target:setScale(0.95) end)
				:onButtonRelease(function(event) event.target:setScale(1.0) end)
				:onButtonClicked(function(event)
		            local isDia = 0
			        if not self.isStuffEnough then
			            local needDiaNum = 0
			            for i,value in ipairs(stuffTab) do
			                needDiaNum = needDiaNum + itemData[value.tmpId].advDiamond*value.needNum
			            end
			            local msg = "是否消耗"..needDiaNum.."钻石代替材料进行进阶？"
			            showMessageBox(msg, function(event)
			                isDia = 1
			                local sendData = {}
						    sendData["characterId"] = srv_userInfo["characterId"]
						    sendData["itemId"] =  value["id"]
						    sendData["isDia"] = isDia
						    local g_step = GuideManager:getCondition()
							if g_step==202 then 
								GuideManager:resetCondition(sendData)
							end
						    m_socket:SendRequest(json.encode(sendData), CMD_ADVANCED, self, self.onAdvancedResult)
						    startLoading()
			                end)
			        else
			        	local sendData = {}
					    sendData["characterId"] = srv_userInfo["characterId"]
					    sendData["itemId"] =  value["id"]
					    sendData["isDia"] = isDia
					    local g_step = GuideManager:getCondition()
						if g_step==202 then 
							GuideManager:resetCondition(sendData)
						end
					    m_socket:SendRequest(json.encode(sendData), CMD_ADVANCED, self, self.onAdvancedResult)
					    startLoading()
			        end

				    advNeedGold = advanced.advGold --升级消耗
				end)
				setLabelStroke(advanceBt:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)
				self.advanceBt = advanceBt
			end,0.01)
			
		end
	else   							--升级
		tmpStuff = advanced.advStuff
		self.dcStuff = tmpStuff
		self:addItemProperty(item,value,1)

		self:performWithDelay(function ()
			--升级按钮
			local upgradeBt = cc.ui.UIPushButton.new("common/common_nBt2.png")
			:addTo(tmpPanel)
			:pos(tmpSize.width/4, 10)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "强化", size = 27, 
				color = cc.c3b(127, 79, 33)}))
			:onButtonPressed(function(event) event.target:setScale(0.95) end)
			:onButtonRelease(function(event) event.target:setScale(1.0) end)
			:onButtonClicked(function(event)
				GuideManager:hideGuideEff()
				local isDia = 0
		        if not self.isStuffEnough then
		            local needDiaNum = 0
		            for i,value in ipairs(stuffTab) do
		                needDiaNum = needDiaNum + itemData[value.tmpId].advDiamond*value.needNum
		            end
		            local msg = "是否消耗"..needDiaNum.."钻石代替材料进行进阶？"
		            showMessageBox(msg, function(event)
		                isDia = 1
		                local sendData = {}
					    sendData["characterId"] = srv_userInfo["characterId"]
					    sendData["itemId"] =  value["id"]
					    sendData["isDia"] = isDia
					    sendData["isAuto"] = 0
					    local g_step = nil
						g_step = GuideManager:tryToSendFinishStep(115) --弹弓升级
						sendData.guideStep = g_step
					    m_socket:SendRequest(json.encode(sendData), CMD_STRENGTHEN, self, self.onStrengthenResult)
					    startLoading()
		                end)
		        else
		        	local sendData = {}
				    sendData["characterId"] = srv_userInfo["characterId"]
				    sendData["itemId"] =  value["id"]
				    sendData["isAuto"] = 0
				    sendData["isDia"] = isDia
				    self.isAutoStr = 0
				    local g_step = nil
					g_step = GuideManager:tryToSendFinishStep(115) --弹弓升级
					sendData.guideStep = g_step
				    m_socket:SendRequest(json.encode(sendData), CMD_STRENGTHEN, self, self.onStrengthenResult)
				    startLoading()
		        end
		        advNeedGold = advanced.gold --进阶消耗

			end)
			setLabelStroke(upgradeBt:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)
			self.upgradeBt = upgradeBt
			
			--一键升级按钮
			local onekeyUpgradeBt = cc.ui.UIPushButton.new("common/common_nBt2.png")
			:addTo(tmpPanel)
			:pos(tmpSize.width/4*3, 10)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "一键强化", size = 27, 
				color = cc.c3b(127, 79, 33)}))
			:onButtonPressed(function(event) event.target:setScale(0.95) end)
			:onButtonRelease(function(event) event.target:setScale(1.0) end)
			:onButtonClicked(function(event)
				-- showTips("暂未开放")
				GuideManager:hideGuideEff()
				isDia = 0
				startLoading()
				local sendData={}
				sendData["characterId"] = srv_userInfo["characterId"]
		        sendData["itemId"] = value["id"]
		        sendData["isDia"] = isDia
		        sendData["isAuto"] = 1
		        self.isAutoStr = 1
		        local g_step = nil
				g_step = GuideManager:tryToSendFinishStep(116) --弹弓一键升级
				sendData.guideStep = g_step
		        m_socket:SendRequest(json.encode(sendData), CMD_STRENGTHEN, self, self.onStrengthenResult)

			end)
			setLabelStroke(onekeyUpgradeBt:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)
			self.onekeyUpgradeBt = onekeyUpgradeBt
		end,0.01)
		
	end

	local isCom
	--所需材料图标
	self:performWithDelay(function ()
		self.stuffNote = {}
		local bottomPanel = self.EquipInfoWidget.bottomPanel
		-- print(tmpStuff)
		local StuffArr=lua_string_split(tmpStuff,"|")
		
		if #StuffArr==1 then
			local Stuff=lua_string_split(StuffArr[1],"#")
			local StuffValue = get_SrvBackPack_Value(Stuff[1]+0)

			local stuffItem = createItemIcon(Stuff[1]+0, nil, true)
			:addTo(bottomPanel)
			:pos(110,bottomPanel:getContentSize().height/2-15)
			stuffItem:setScale(0.8)
			stuffItem:onButtonClicked(function(event)
				RoleFightBackTmpId = Stuff[1]+0
				g_combinationLayer.new(Stuff[1]+0,
					function()
						self:refreshUpgradePanel()
						self:RefreshUI()
					end
					,102)
    			:addTo(MainScene_Instance,50)
					end)

			local stuffNum,isCom=getComNumPer(Stuff[1]+0,Stuff[2]+0)
		        stuffNum:addTo(stuffItem)
		        stuffNum:pos(stuffItem:getContentSize().width/2, -40)
		    
		    if StuffValue==nil then --还没有材料判断
		       	self.isStuffEnough = false
		       	stuffTab[1] = {}
            	stuffTab[1].tmpId = tonumber(Stuff[1])
            	stuffTab[1].needNum = tonumber(Stuff[2])
		    else
		        stuffNum:setString(StuffValue.cnt.."/"..Stuff[2])
		        if StuffValue.cnt<tonumber(Stuff[2]) then
		        	self.isStuffEnough = false
		        	stuffTab[1] = {}
	            	stuffTab[1].tmpId = tonumber(Stuff[1])
	            	stuffTab[1].needNum = tonumber(Stuff[2]) - StuffValue.cnt
		        else
		        end
		    end
		    self.stuffNote[1] = stuffItem
		elseif #StuffArr==2 then
			for i=1,#StuffArr do
				local Stuff=lua_string_split(StuffArr[i],"#")
				local StuffValue = get_SrvBackPack_Value(Stuff[1]+0)

				local stuffItem = createItemIcon(Stuff[1]+0, nil, true)
				:addTo(bottomPanel)
				:pos(100*(i-1)+60,bottomPanel:getContentSize().height/2-15)
				stuffItem:setScale(0.8)
				stuffItem:onButtonClicked(function(event)
					-- print("aac")
					-- print(Stuff[1])
					RoleFightBackTmpId = Stuff[1]+0
					g_combinationLayer.new(Stuff[1]+0,
						function()
							self:refreshUpgradePanel()
							self:RefreshUI()
						end
						,102)
    				:addTo(MainScene_Instance,50)
						end)

				local stuffNum=getComNumPer(Stuff[1]+0,Stuff[2]+0)
			        stuffNum:addTo(stuffItem)
			        stuffNum:pos(stuffItem:getContentSize().width/2, -40)
			        stuffNum:setAnchorPoint(0.5,0.5)
			    if StuffValue==nil then --还没有材料判断
			       	self.isStuffEnough = false
			       	local idx = #stuffTab+1
			       	stuffTab[idx] = {}
	            	stuffTab[idx].tmpId = tonumber(Stuff[1])
	            	stuffTab[idx].needNum = tonumber(Stuff[2])
			    else
			        stuffNum:setString(StuffValue.cnt.."/"..Stuff[2])
			        if StuffValue.cnt<tonumber(Stuff[2]) then
			        	self.isStuffEnough = false
			        	local idx = #stuffTab+1
			        	stuffTab[idx] = {}
	            		stuffTab[idx].tmpId = tonumber(Stuff[1])
	            		stuffTab[idx].needNum = tonumber(Stuff[2]) - StuffValue.cnt
			        else
			        end
			    end
			    
			    self.stuffNote[i] = stuffItem
			end	
		end
    end, 0.01)
	
	--消耗金币
	if advanced~=nil or advanced.stuff==0 then
		local label = cc.ui.UILabel.new({UILabelType = 2, text = "消耗金币：", size = 20,
			color = cc.c3b(255, 241, 0)})
    	:addTo(self.EquipInfoWidget.bottomPanel)
    	:pos(170, 125)
    	local needGold = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20,
			color = cc.c3b(255, 241, 0)})
    	:addTo(self.EquipInfoWidget.bottomPanel)
    	:pos(170+label:getContentSize().width, 125)
    	if value.advLvl==10 then
	    	needGold:setString(advanced.gold)
	    else
	    	needGold:setString(advanced.advGold)
    	end
    end

end

local Attribute_pos = {
	{x=40,y=515-170},
	{x=240,y=515-170},
	{x=40,y=476-170},
	{x=40,y=432-170},

	{x=155,y=195+205},
	{x=155,y=125+225},
	-- {x=155,y=55+210}
}
function RolePropertyLayer:addItemSkill(item)
	local tmpPanel = self.Tag[2].panel
	tmpSize = self.rPanel:getContentSize()

	local msize = 23
	local pos = 0
	local color1 = cc.c3b(35, 24, 21)
	local color2 = cc.c3b(61, 102, 100)
	if item.sklId==0 then
		local Des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = msize, color = color1})
		:pos(Attribute_pos[1].x,Attribute_pos[1].y+10)
		:addTo(tmpPanel)
		Des:setAnchorPoint(0,1)
		Des:setString(item.des)
		Des:setWidth(380)
		Des:setLineHeight(25)

    else
    	pos = pos + 1
    	local label = cc.ui.UILabel.new({UILabelType = 2, text = "武器", size = msize, color = color2})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
    	local skilllabel1 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = msize, color = color1})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x+label:getContentSize().width + 10,label:getPositionY())
    	skilllabel1:setString(skillData[item.sklId].sklName)

    	pos = pos + 1
    	local label = cc.ui.UILabel.new({UILabelType = 2, text = "能量消耗", size = msize, color = color2})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
    	local skilllabel4 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = msize, color = color1})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x+label:getContentSize().width + 10,label:getPositionY())
    	skilllabel4:setString(skillData[item.sklId].sklCD.."点")

    	pos = pos + 1
    	local label = cc.ui.UILabel.new({UILabelType = 2, text = "技能效果", size = msize, color = color2})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
    	local skilllabel2 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = msize-2, color = color1})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x+label:getContentSize().width + 10,label:getPositionY())
    	skilllabel2:setString(skillData[item.sklId].sklDes)
    	skilllabel2:setWidth(290)

    	pos = pos + 1
    	local label = cc.ui.UILabel.new({UILabelType = 2, text = "伤害", size = msize, color = color2})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
    	local skilllabel3 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = msize, color = color1})
    	:addTo(tmpPanel)
    	:pos(Attribute_pos[pos].x+label:getContentSize().width + 10,label:getPositionY())
    	skilllabel3:setString((skillData[item.sklId].addPercent*100).."%")

    	
    end
end
function RolePropertyLayer:addItemProperty(item,value,mType,item2)
	local tmpPanel = self.Tag[2].panel
	tmpSize = self.rPanel:getContentSize()
	local bottomPanel = self.EquipInfoWidget.bottomPanel

	local pos = 4
	local dx = 15
	local ddx = 140
	local fontSize = 23
	local color1 = cc.c3b(35, 24, 21)
	local color2 = cc.c3b(0, 124, 0)
	if item.hp>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "血量", size = fontSize, 
        	color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.hp + (value["advLvl"]-1)*item.hpGF)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.hp + (value["advLvl"]-1)*item.hpGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.hp + (value["advLvl"])*item.hpGF)
	        elseif mType==2 then
	        	newNum:setString(item2.hp)
	        end
        end
    end
    if item.attack>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "攻击", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.attack + (value["advLvl"]-1)*item.atkGF)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.attack + (value["advLvl"]-1)*item.atkGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.attack + (value["advLvl"])*item.atkGF)
	        elseif mType==2 then
	        	newNum:setString(item2.attack)
	        end
        end
    end
    if item.defense>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "防御", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.defense + (value["advLvl"]-1)*item.defGF)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.defense + (value["advLvl"]-1)*item.defGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.defense + (value["advLvl"])*item.defGF)
	        elseif mType==2 then
	        	newNum:setString(item2.defense)
	        end
        end
    end
    if item.cri>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "暴击", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.cri + (value["advLvl"]-1)*item.criGF)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.cri + (value["advLvl"]-1)*item.criGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.cri + (value["advLvl"])*item.criGF)
	        elseif mType==2 then
	        	newNum:setString(item2.cri)
	        end
        end
    end
    if item.hit>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "命中", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.hit + (value["advLvl"]-1)*item.hitGF)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.hit + (value["advLvl"]-1)*item.hitGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.hit + (value["advLvl"])*item.hitGF)
	        elseif mType==2 then
	        	newNum:setString(item2.hit)
	        end
        end
    end
    if item.miss>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "闪避", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.miss + (value["advLvl"]-1)*item.missGF)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        num:setString(item.miss + (value["advLvl"]-1)*item.missGF)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	newNum:setString(item.miss + (value["advLvl"])*item.missGF)
	        elseif mType==2 then
	        	newNum:setString(item2.miss)
	        end
        end
    end
    if item.erecover>0 then
        pos = pos + 1
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "能量", size = fontSize, color =cc.c3b(61, 102, 100)})
        :addTo(bottomPanel)
        :pos(Attribute_pos[pos].x,Attribute_pos[pos].y)
        if mType==3 then
        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        local tmp = string.format("%0.1f%%",(item.erecover + (value["advLvl"]-1)*item.erGF)*100)
	        num:setString(tmp)
	        num:setAnchorPoint(0.5,0.5)
        else
        	local jiantou = display.newSprite("#RoleProperty2_img10.png")
        	:addTo(bottomPanel)
        	:pos(Attribute_pos[pos].x+ddx,label:getPositionY())

        	local num=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,
        		color = color1})
	        :pos(Attribute_pos[pos].x-dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        local tmp = string.format("%0.1f%%",(item.erecover + (value["advLvl"]-1)*item.erGF)*100)
	        num:setString(tmp)
	        num:setAnchorPoint(1,0.5)
	        local newNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = color2})
	        :pos(Attribute_pos[pos].x+dx+ddx,label:getPositionY())
	        :addTo(bottomPanel)
	        newNum:setAnchorPoint(0,0.5)
	        if mType==1 then
	        	local tmp = string.format("%0.1f%%",(item.erecover + (value["advLvl"])*item.erGF)*100)
	        	newNum:setString(tmp)
	        elseif mType==2 then
	        	local tmp = string.format("%0.1f%%",(item2.erecover)*100)
	        	newNum:setString(tmp)
	        end
        end
    end          
end

function RolePropertyLayer:onStrengthenResult(result) --强化
	endLoading()
    if result["result"]==1 then
        print("强化成功！")
        self:refreshUpgradePanel()
		local _scene = cc.Director:getInstance():getRunningScene()
        GuideManager:_addGuide_2(11504, _scene,handler(self,self.caculateGuidePos))
        GuideManager:_addGuide_2(11503, _scene,handler(self,self.caculateGuidePos))
        
        -- srv_userInfo.gold = srv_userInfo.gold - advNeedGold
        mainscenetopbar:setGlod()
        self:UpdateSingleRole(result.data.wareMemInfo)
        self:RefreshUI()

        --强化特效
        self:performWithDelay(function ()
	        for i=1,#self.stuffNote do
	        	print("stuffNote")
	        	local note = self.stuffNote[i]
	        	strengthAnimation(note,0,0)
	        	-- if self.isAutoStr == 0 and self.upgradeBt then
	        	-- 	advancedBtAnimation(self.upgradeBt,0 , 5)
	        	-- end
	        	-- if self.isAutoStr == 1 and self.onekeyUpgradeBt then
	        	-- 	advancedBtAnimation(self.onekeyUpgradeBt,0 , 5)
	        	-- end
	        	
	        end
        end,0.01)
        local note = self.EquipInfoWidget.icon
        advancedAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)

        if self.dcStuff~="" and self.dcStuff~=nil then
        	local arr1 = string.split(self.dcStuff,"|")
        	for i=1,#arr1 do
        		local arr2 = string.split(arr1[i],"#")
        		local dc_item = itemData[arr2[1]]
        		if dc_item then
	        		DCItem.consume(tostring(dc_item.id), dc_item.name, arr2[2], "装备强化消耗材料")
	        	end
        	end
        end
    else
    	showTips(result.msg)
    end
end
function RolePropertyLayer:onAdvancedResult(result) --进阶
	endLoading()
    if result["result"]==1 then
        print("进阶成功")
    
		local _scene = cc.Director:getInstance():getRunningScene()
		GuideManager:_addGuide_2(20204, _scene,handler(self,self.caculateGuidePos))
        self:refreshUpgradePanel()
        -- srv_userInfo.gold = srv_userInfo.gold - advNeedGold
        mainscenetopbar:setGlod()
        self:UpdateSingleRole(result.data.wareMemInfo)
        self:RefreshUI()
        --进阶特效
        self:performWithDelay(function ()
	        for i=1,#self.stuffNote do
	        	print("stuffNote")
	        	local note = self.stuffNote[i]
	        	strengthAnimation(note,0,0)
	        end
        end,0.01)
        local note = self.EquipInfoWidget.icon
        advancedAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)
        if self.dcStuff~="" and self.dcStuff~=nil then
        	local arr1 = string.split(self.dcStuff,"|")
        	for i=1,#arr1 do
        		local arr2 = string.split(arr1[i],"#")
        		local dc_item = itemData[arr2[1]]
        		if dc_item then
	        		DCItem.consume(tostring(dc_item.id), dc_item.name, arr2[2], "装备进阶消耗材料")
	        	end
        	end
        end

        --进阶,可换装的特效
        if advancedData[cur_localValue.id+1]==nil then
        	local star = math.modf(cur_localValue.id/1000)%10
        	if star<6 then
        		local i = cur_localValue.type - 200
				local parentNode = self.eptIconIdx[i]
				changeEqtAnimation(self.changeEquipmentBt, parentNode, i)
        	end
        	
        end
		
		
    else
    	showTips(result.msg)
    end
end
--换装数据返回
function RolePropertyLayer:OnChangeEquipment(result)
	if result.result==1 then
		showTips("换装成功。")
		self:UpdateSingleRole(result.data.wareMemInfo)
        self:RefreshUI()

        if math.floor(result.data.wareMemInfo.tmpId/100)==math.floor(srv_userInfo.templateId/100) then
        	srv_userInfo.templateId = result.data.wareMemInfo.tmpId
	        if MainScene_Instance~=nil then
	        	MainScene_Instance.headBt:setButtonImage("normal", 
	        		"Head/chead_"..memberData[srv_userInfo["templateId"]].resId..".png")
	        	MainScene_Instance.headBt:setButtonImage("pressed", 
	        		"Head/chead_"..memberData[srv_userInfo["templateId"]].resId..".png")
	        end
        end
        

        --换装特效
        changeRoleEff(self.lPanel, self.lPanel:getContentSize().width/2, self.lPanel:getContentSize().height/2+60)
	else
		showTips(result.msg) 
	end
end


function RolePropertyLayer:bItemCanUpgrade(node,tmpId)
	local advLocalItem = advancedData[tmpId]
	if advLocalItem==nil then
		return false
	end
	local value  = get_SrvBackPack_Value(tmpId)
	local stuffStr
	if value.advLvl==10 then
		stuffStr = advLocalItem.stuff
	else
		stuffStr = advLocalItem.advStuff
	end
	if stuffStr=="null" or stuffStr==0 then
		return false
	end
	stuffArr = lua_string_split(stuffStr,"|")
	for i=1,#stuffArr do
		stuffArr[i] = lua_string_split(stuffArr[i],"#")
		local stuffValue = get_SrvBackPack_Value(stuffArr[i][1]+0)
		if stuffValue==nil then
			return false
		elseif stuffValue.cnt<(stuffArr[i][2]+0) then
			return false
		end
	end

	local jiantou = display.newSprite("common/common_UpArrow.png")
	:addTo(node)
	:pos(30,-25)

	return true
end

function RolePropertyLayer:caculateGuidePos(_guideId)
	print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11402==_guideId or 11502==_guideId or 12102==_guideId or 20202==_guideId then
    	if 11402==_guideId or 11502==_guideId or 20202==_guideId then
    		print("指引升级武器---------------")
	    	g_node = self.EquipWidget[1].btn
	    	size = g_node:getContentSize()
	    elseif 12102==_guideId then
	    	g_node = self.Tag[3].btn
	    	size = g_node.sprite_[1]:getContentSize()
	    end
	    
        if g_node==nil then
        	print("g_node==nil,  return")
        	return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        if 12102==_guideId then
        	midPos = g_node:convertToWorldSpace(cc.p(0,size.height/2))
        end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    elseif 11403==_guideId or 11503==_guideId or 11504==_guideId  or 12103==_guideId or 12104==_guideId 
    	or 20203==_guideId or 20204==_guideId then
    	if 11403==_guideId then
	    	g_node = self.upgradeBt
	    elseif 11503==_guideId then
	    	g_node = self.onekeyUpgradeBt
	    elseif 11504==_guideId then
	    	g_node = self.closeBtn
	    elseif 12103==_guideId then
	    	g_node = self.skillWidget[1].btnUp
	    elseif 12104==_guideId or 20204==_guideId then
	    	g_node = self.closeBtn
	    elseif 20203==_guideId then
	    	g_node = self.advanceBt
	    end
	    if g_node==nil then
        	print("g_node==nil,  return")
        	return nil
        end
        size = g_node.sprite_[1]:getContentSize()
        
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 11504==_guideId or 12104==_guideId or 20204==_guideId then
	        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,-size.height/2))
	    end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end
--当前是否可以换装
function RolePropertyLayer:isCanChangeEquipment()
	local equips = curRoleData.equip
	for i=1, 6 do
		srv_Item = srv_carEquipment["memIt"][equips[i]]
		if advancedData[srv_Item.tmpId+1]~=nil then
			return false
		end
	end

	return true
end

return RolePropertyLayer