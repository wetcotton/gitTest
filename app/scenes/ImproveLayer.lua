-- 改造中心
-- Author: Jun Jiang
-- Date: 2015-06-16 11:20:00
--
local changeNode = require("app.scenes.carEquipments.changeLayer")
local improveCarLayer = require("app.scenes.improveCarLayer")

local ImproveLayer = class("ImproveLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
ImproveLayer.Instance 		= nil
ImproveLayer.params 		= nil
ImproveLayer.nCurSelCarID 	= nil 		--当做全局变量使用（使用方式：本文件-ImproveLayer.nCurSelCarID  其它文件-g_ImproveLayer.nCurSelCarID）
ImproveLayer.bCanOp 		= true 		--允许操作

ImproveLayer_Instance 		= nil

--属性倾向基准点坐标配置(五边形上方的点为1号点，顺时针依次为后续点)
--@name:属性名
--@talent:代表天赋
--@beginPosX, beginPosY:最小值点
--@endPosX, endPosY:最大值点
local tendencyCfg = {
	{name="主炮", talent=2, beginPosX=69, beginPosY=93, endPosX=70, endPosY=130},
	{name="副炮", talent=3, beginPosX=100, beginPosY=69, endPosX=137, endPosY=81},
	{name="闪避", talent=8, beginPosX=89, beginPosY=33, endPosX=112, endPosY=2},
	{name="命中", talent=7, beginPosX=50, beginPosY=33, endPosX=28, endPosY=2},
	{name="暴击", talent=6, beginPosX=38, beginPosY=70, endPosX=3, endPosY=81},
}

curCarData ={}
local curEquipments = {}
local cur_value = {}
local cur_localValue = {}
local curEqupmentIdx = 1

function ImproveLayer:updateCarData()
	curCarData = CarManager.carIDKeyList[ImproveLayer.nCurSelCarID]
	-- print("carID"..ImproveLayer.nCurSelCarID)
	curEquipments = getCarEquipments(ImproveLayer.nCurSelCarID)
	self.nTotalStar = getCarAllStars(ImproveLayer.nCurSelCarID)
	-- printTable(curEquipments)
	-- print("===========111")
end
--获取选择装备的数据
function ImproveLayer:getCurValue(idx)

	local itemId = curEquipments[idx+100]
	if itemId~=nil then
		cur_value = srv_carEquipment["item"][itemId]
		cur_localValue = itemData[cur_value.tmpId]
	else
		cur_value = {}
		cur_localValue = {}
	end
	self.cur_value = cur_value
	self.cur_localValue = cur_localValue

end
function ImproveLayer:InitSortList()
	self.sortList = {}
	for k, _ in pairs(CarManager.carIDKeyList) do
		if self.params.ignoreCar~=k then
			table.insert(self.sortList, k)
		end
	end

	--已乘战车->战车获得顺序
	local function SortFunc(val1, val2)
		local memberId1 = CarManager.carIDKeyList[val1].carMember.memberId
		local memberId2 = CarManager.carIDKeyList[val2].carMember.memberId
		if nil==memberId1 and nil==memberId2 then
			return val1<val2
		else
			if nil~=memberId1 and nil~=memberId2 then
				return val1<val2
			else
				return nil~=memberId1
			end
		end
	end

	table.sort(self.sortList, SortFunc)
end

--重置装备UI
local function resetEquipUI(rootNode, nThisID, bLocked)
	if nil==rootNode or nil==nThisID then
		return
	end

	rootNode:removeChildByTag(100)
	rootNode.sprIcon = nil

	local Name = {
			"主炮槽位",
			"副炮槽位",
			"SE槽位",
			"引擎槽位",
			"C装置槽位",
			"工具槽位",
		}


	local nStar = 0
	local name, level
	if nThisID<=#Name then
		name = Name[nThisID]
		-- boxPath = "#Improve_Box2.png"

		--图标刷新
		if bLocked then
			rootNode.sprIcon = createItemIcon(10000)
			:addTo(rootNode, 0, 100)
			:pos(10, 0)
			-- frame = display.newSpriteFrame("Improve_Img1.png")
			-- rootNode.sprIcon:setSpriteFrame(frame)
			-- rootNode.sprIcon:setVisible(true)
		else
			rootNode.sprIcon = display.newSprite("itemBox/item_box2.png")
			:addTo(rootNode, 0, 100)
			:pos(10, 0)
			-- rootNode.sprIcon:setVisible(false)
		end
	else
		local value = srv_carEquipment["item"][nThisID]
		if nil==value then
			return
		end
		local loc_Item = itemData[value.tmpId]
		if nil==loc_Item then
			return
		end

		nStar = tonumber(string.sub(value.tmpId, 4, 4))
		-- boxPath = string.format("#Improve_Box%d.png", nStar)
		name = loc_Item.name
		name = name
		level = " LV " .. value.advLvl
		-- rootNode.sprIcon:setTexture("Item/item_" .. loc_Item.resId .. ".png")
		-- rootNode.sprIcon:setVisible(true)
		rootNode.sprIcon = createItemIcon(value.tmpId)
		:addTo(rootNode, 0, 100)
		:pos(10, 0)

		if bItemCanAdvance(value.tmpId) then
			rootNode.redPt:setVisible(true)
            rootNode.redPt:setTexture("common/common_RedPoint.png")
        else
        	rootNode.redPt:setVisible(false)
        end
	end


	--底框刷新
	-- rootNode:setButtonImage("normal", boxPath)
	-- rootNode:setButtonImage("pressed", boxPath)
	-- rootNode:setButtonImage("disabled", boxPath)

	--名称刷新
	rootNode.labName:setString(name)
	-- rootNode.labLev:setPositionX(rootNode.labName:getPositionX()+rootNode.labName:getContentSize().width-5)
	rootNode.labLev:setString(level)

	--星级刷新
	for i=1, #rootNode.starWidget do
		if i<=nStar then
			rootNode.starWidget[i]:setVisible(true)
		else
			rootNode.starWidget[i]:setVisible(false)
		end
	end
end

--创建装备UI
local function createEquipUI(tmpId, bLocked, bButton, clickedEvent)
	-- if tmpId>3 then
	-- 	tmpId = tmpId +1
	-- end
	--底框
	local retNode = cc.ui.UIPushButton.new("#improve2_img12.png")
	if bButton then
		retNode:setButtonEnabled(true)
		if nil~=clickedEvent then
			retNode:onButtonClicked(clickedEvent)
		end
	else
		retNode:setButtonEnabled(false)
	end

	--类型
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "主\n炮", size = 20, color = cc.c3b(55, 234, 255)})
	:addTo(retNode)
	:pos(-79, 0)
	if tmpId==1 then
		label:setString("主\n炮")
		label:setLineHeight(25)
	elseif tmpId==2 then
		label:setString("副\n炮")
		label:setLineHeight(25)
	elseif tmpId==4 then
		label:setString("引\n擎")
		label:setLineHeight(25)
	elseif tmpId==5 then
		label:setString("C\n装\n置")
		label:setLineHeight(20)
	end

	local starBar = display.newSprite("#improve2_img11.png")
	:addTo(retNode, 2)
	:pos(0, -67)

	--可进阶红点
	retNode.redPt = display.newSprite()
	:addTo(retNode,10)
	:pos(80,85)

	--名字
	retNode.labName = display.newTTFLabel({
							text="",
							size=20,
							color=display.COLOR_BLACK,
							align = cc.TEXT_ALIGNMENT_CENTER,
					        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.CENTER, 0, 72)
						:addTo(retNode)
	retNode.labLev = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
							text="",
							size=18,
							color=cc.c3b(106, 57, 6),
						})
						:align(display.CENTER, 35, 51)
						:addTo(starBar)
	--图标
	-- retNode.sprIcon = display.newSprite()
	-- 					:align(display.CENTER, -94, 2)
	-- 					:addTo(retNode)

	--星级
	retNode.starWidget = {}
	for i=1, 5 do
		display.newSprite("#improve2_img14.png")
		:align(display.CENTER, 24+(i-1)*33, 25)
		:addTo(starBar)

		retNode.starWidget[i] = display.newSprite("#improve2_img13.png")
									:align(display.CENTER, 24+(i-1)*33, 25)
									:addTo(starBar)
		retNode.starWidget[i]:setVisible(false)
	end

	resetEquipUI(retNode, tmpId, bLocked)

	return retNode
end

function ImproveLayer:ctor(params)
	ImproveLayer_Instance = self
	setIgonreLayerShow(true)
	self.params = params or {}
	self.bCanOp = true
	self.isFirstReq = true
	--资源加载
	-- display.addSpriteFrames("Image/UIImprove.plist", "Image/UIImprove.png")
    display.addSpriteFrames("Effect/Improve_Eff1.plist", "Effect/Improve_Eff1.png")
    display.addSpriteFrames("Image/improve2_img.plist", "Image/improve2_img.png")

	local tmpNode, tmpSize, tmpCx, tmpCy, tmpCfg

	self.actMgr = ccs.ActionManagerEx:getInstance()
	--返回按钮
	self.backBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height )
    	:addTo(self, 2)
    	:onButtonClicked(function(event)
    		GuideManager:removeGuideLayer()
    		local _scene = cc.Director:getInstance():getRunningScene()
        	GuideManager:_addGuide_2(11101, _scene,handler(_scene,_scene.caculateGuidePos))
        	
    		self:removeFromParent()
    		--主界面小红点更新
			display.getRunningScene():improveRedPoint()
    	end)

    local fScale = display.height/720
    self.widget = GUIReader:getInstance():widgetFromJsonFile("Image/gaizaozhongxin_1.ExportJson")
    self.widget:addTo(self, 0, 1)
			   :scale(fScale)
			   :align(display.CENTER, display.cx, display.cy)

	--特效
	self.sprEff = display.newSprite()
					:scale(2.5*fScale)
					:align(display.CENTER, display.cx, display.cy)
					:addTo(self, 1)

	--战车底座
	self.carBase = self.widget:getChildByTag(1)

	--光照
	self.light1 = display.newSprite("common2/improve2_img52.png")
	:addTo(self.carBase)
	:align(display.CENTER_RIGHT, self.carBase:getContentSize().width/2+90, self.carBase:getContentSize().height/2-40)

	self.light2 = display.newSprite("common2/improve2_img52.png")
	:addTo(self.carBase)
	:align(display.CENTER_RIGHT, self.carBase:getContentSize().width/2-90, self.carBase:getContentSize().height/2-40)
	:setScaleX(-1)


	--战车按钮
	self.carBtn = cc.ui.UIPushButton.new()
					:align(display.BOTTOM_CENTER, 640, 220)
					:addTo(self.carBase)
					:onButtonClicked(function(event)
						if self.bCanOp then
							g_CarListLayer.new({openTag=OpenBy_Improve})
								:addTo(self, 51)
						end
					end)
	self.carBtn:setContentSize(320, 250)

	
	-----------------------------UI层------------------------------------
	self.uiLayer = display.newNode()
					:addTo(self, 1)

	--属性面板
	local arrPanel = display.newSprite("#improve2_img6.png")
	:addTo(self)
	:align(display.CENTER_LEFT, 15, display.cy+30)
	local arrsize = arrPanel:getContentSize()

	local img = display.newSprite("#improve2_img5.png")
	:addTo(self)
	:align(display.CENTER_LEFT, 0, display.cy+220)

	cc.ui.UIPushButton.new("#improve2_img4.png")
	:addTo(img)
	:pos(img:getContentSize().width/2, img:getContentSize().height-24)
	:onButtonClicked(function(event)
		if arrPanel:isVisible() then
			arrPanel:setVisible(false)
			event.target:setScale(-1)
		else
			arrPanel:setVisible(true)
			event.target:setScale(1)
		end
		
		end)

	local attrPS = cc.size(1280, 170)
	local attrPCx = attrPS.width/2
	local attrPCy = attrPS.height/2
	self.attrPanel = arrPanel

	--左面板
	-- display.newSprite("#Improve_Img32.png")
	-- 	:align(display.BOTTOM_CENTER, display.cx-375, -5)
	-- 	:addTo(self.attrPanel)

	--右面板
	-- tmpNode = display.newSprite("#Improve_Img32.png")
	-- 			:align(display.BOTTOM_CENTER, display.cx+375, -5)
	-- 			:addTo(self.attrPanel)
	-- tmpNode:setScaleX(-1)

	--中面板
	-- self.CPanel = display.newSprite("#Improve_Img33.png")
	-- 				:align(display.BOTTOM_CENTER, display.cx, -5)
	-- 				:addTo(self.attrPanel, -1)
	-- tmpSize = self.CPanel:getContentSize()
	-- tmpCx = tmpSize.width/2
	-- tmpCy = tmpSize.height/2


	

    --中面板罩子
    -- self.leftMask = display.newSprite("#Improve_Img30.png")
    -- 					:align(display.CENTER, tmpCx-58, tmpCy-15)
    -- 					:addTo(self.CPanel)

    -- self.rightMask = display.newSprite("#Improve_Img30.png")
    -- 					:align(display.CENTER, tmpCx+58, tmpCy-15)
    -- 					:addTo(self.CPanel)
    -- self.rightMask:setScaleX(-1)

    -- self.sprRotate = display.newSprite("#Improve_Img31.png")
    -- 					:align(display.CENTER, tmpCx, tmpCy-15)
    -- 					:addTo(self.CPanel)

    --战车简介
	-- self.btnIntro = cc.ui.UIPushButton.new({normal="#Improve_Btn3_1.png", pressed="#Improve_Btn3_2.png"})
	-- 				:align(display.CENTER, display.width-100, display.height-60)
	-- 				:addTo(self.uiLayer)
	-- 				:onButtonClicked(function(event)
	-- 					if self.bCanOp then
	-- 						self:ShowIntroPanel()
	-- 					end
	-- 				end)


	--属性组件
	self.attrWidget = {}

	--主炮、副炮属性
	tmpSize = cc.size(141, 149)
	tmpCx = tmpSize.width/2
	tmpCy = tmpSize.height/2
	tmpCfg = {
		{img="#Improve_Img22.png", img1="#Improve_Img4.png", img2="#Improve_Img5.png", posX=tmpCx+18, bgPosX=display.cx-560},
		{img="#Improve_Img22.png", img1="#Improve_Img3.png", img2="#Improve_Img6.png", posX=tmpCx+18, bgPosX=display.cx-200},
	}
	for i=1, #tmpCfg do
		-- --底板
		-- tmpNode = display.newSprite("#Improve_Img29.png")
		-- 		:align(display.CENTER, tmpCfg[i].bgPosX, 80)
		-- 		:addTo(self.attrPanel)

		-- --主炮、副炮、SE炮文字图片
		-- display.newSprite(tmpCfg[i].img1)
		-- 	:align(display.CENTER, tmpCx, tmpCy+45)
		-- 	:addTo(tmpNode)

		-- --填装文字图片
		-- display.newSprite(tmpCfg[i].img)
		-- 	:align(display.CENTER, tmpCx, tmpCy-15)
		-- 	:addTo(tmpNode)

		-- --伤害文字图片
		-- display.newSprite(tmpCfg[i].img2)
		-- 	:align(display.LEFT_CENTER, tmpCx-55, tmpCy-45)
		-- 	:addTo(tmpNode)

		-- --进度条底板
		-- display.newSprite("#Improve_Img28.png")
		-- 	:align(display.CENTER, tmpCx, tmpCy-60)
		-- 	:addTo(tmpNode)

		tmpCfg[i].nodes = {}
		--CD
		tmpCfg[i].nodes.labCD = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
									text="",
									size=18,
									-- color=cc.c3b(237, 227, 199),
									align = cc.TEXT_ALIGNMENT_LEFT,
					                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, 130, arrsize.height/2+78-(i-1)*47)
								:addTo(arrPanel)

		--攻击力
		tmpCfg[i].nodes.labAtk = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
									text="",
									size=18,
									-- color=cc.c3b(237, 227, 199),
									align = cc.TEXT_ALIGNMENT_LEFT,
					                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, 130, arrsize.height/2+56-(i-1)*47)
								:addTo(arrPanel)

		-- tmpCfg[i].nodes.progressBar = display.newProgressTimer("#Improve_Img27.png", display.PROGRESS_TIMER_BAR)
		-- 								:align(display.CENTER, tmpCx, tmpCy-60)
		-- 								:addTo(tmpNode)
		-- tmpCfg[i].nodes.progressBar:setMidpoint(cc.p(0, 0.5))
	 --  	tmpCfg[i].nodes.progressBar:setBarChangeRate(cc.p(1.0, 0))
	end
	self.attrWidget.MainGun = tmpCfg[1].nodes
	self.attrWidget.SubGun 	= tmpCfg[2].nodes

	-- self:createTendencyPic(self.attrPanel, display.cx-380, 80)

    --其它属性
 --    display.newScale9Sprite("common/common_Frame14.png", display.cx+380, 130, cc.size(480, 50))
	-- 	:addTo(self.attrPanel)

	-- display.newScale9Sprite("common/common_Frame15.png", display.cx+380, 80, cc.size(450, 50))
	-- 	:addTo(self.attrPanel)

	-- display.newScale9Sprite("common/common_Frame14.png", display.cx+380, 30, cc.size(480, 50))
	-- 	:addTo(self.attrPanel)

	-- display.newSprite("#Improve_Img8.png")
	-- 	:align(display.CENTER, display.cx+260, 80)
	-- 	:addTo(self.attrPanel)

	-- display.newSprite("#Improve_Img9.png")
	-- 	:align(display.CENTER, display.cx+500, 105)
	-- 	:addTo(self.attrPanel)

	-- display.newSprite("common/energy_recovery.png")
	-- 	:align(display.CENTER, display.cx+480, 33)
	-- 	:addTo(self.attrPanel)

	--数值坐标、进度条坐标
	local dy = 15
    tmpCfg = {
    	{pos1X=115, pos1Y=229, pos2X=120, pos2Y=229-dy},
    	{pos1X=115, pos1Y=193, pos2X=120, pos2Y=193-dy},
    	{pos1X=100, pos1Y=157, pos2X=120, pos2Y=157-dy},
    	{pos1X=100, pos1Y=122, pos2X=120, pos2Y=122-dy},
    	{pos1X=100, pos1Y=85, pos2X=120, pos2Y=85-dy},
    	{pos1X=130, pos1Y=50, pos2X=120, pos2Y=50-dy},
	}
	for i=1, #tmpCfg do
		tmpCfg[i].nodes = {}
		--数值
		tmpCfg[i].nodes.labVal = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
									text="",
									size=18,
									-- color=cc.c3b(237, 227, 199),
									align = cc.TEXT_ALIGNMENT_LEFT,
					                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, tmpCfg[i].pos1X, tmpCfg[i].pos1Y-2)
								:addTo(arrPanel)

		--进度条
		tmpCfg[i].nodes.progressBar = display.newProgressTimer("#improve2_img33.png", display.PROGRESS_TIMER_BAR)
										:align(display.CENTER, tmpCfg[i].pos2X, tmpCfg[i].pos2Y)
										:addTo(arrPanel,1)
		tmpCfg[i].nodes.progressBar:setMidpoint(cc.p(0, 0.5))
	  	tmpCfg[i].nodes.progressBar:setBarChangeRate(cc.p(1.0, 0))

	  	--底条
		local nenergyBar = display.newSprite("#improve2_img32.png")
			:align(display.CENTER, tmpCfg[i].pos2X, tmpCfg[i].pos2Y)
			:addTo(arrPanel,0)
	end
	
	self.attrWidget.HP 		= tmpCfg[1].nodes
	self.attrWidget.DEF 	= tmpCfg[2].nodes
	self.attrWidget.HIT 	= tmpCfg[3].nodes
	self.attrWidget.CRI 	= tmpCfg[4].nodes
	self.attrWidget.MISS 	= tmpCfg[5].nodes
	self.attrWidget.ENERGY 	= tmpCfg[6].nodes
	---------------------------------------------------------------------
    --装备
    local function EquipmentOnClicked(event)
    	local nTag = event.target:getTag()
    	local nThisID = curCarData.holes[nTag]
    	curEqupmentIdx = nTag
		self:getCurValue(curEqupmentIdx)
		if 5==nTag and GuideManager:checkOpenFunction(10801) then
            showTips("暂未开放")
            return
        end
		if 3==nTag or 6==nTag then 	--SE、工具
			showTips("暂未开放，请期待")
			return
		end
    	if -1==nThisID then 	--未开孔
    		local tmpId = curCarData.TemId
    		print(tmpId)
    		local transform = transformData[tmpId]
    		local nCost = {transform.mainGold, transform.subGold, transform.seGold, transform.engGold, transform.cDevGold, transform.t1Gold}
    		local msg = string.format("是否花费%d金币开启槽位？", nCost[nTag])
    		self.holeDlg = showMessageBox(msg, function()
    			if srv_userInfo.gold<nCost[nTag] then
    				showTips("无法开孔，金币不足")
    			else
    				GuideManager:hideGuideEff()
	    			CarManager:ReqUnlock(ImproveLayer.nCurSelCarID, nTag)
	    			startLoading()
	    			
	    		end
    		end,nil,nil,100)
    		GuideManager:_addGuide_2(10803, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos),101)

		elseif 0==nThisID then 	--已开孔，未装备
			GuideManager:hideGuideEff()
			print("未装备 - " .. nTag)
			local changelayer = changeNode.new(value,curEqupmentIdx+100,
				function()
					CarManager:ReqCarProperty(srv_userInfo["characterId"])
					startLoading()
				end)
            :addTo(self,15)
            GuideManager:_addGuide_2(10903, cc.Director:getInstance():getRunningScene(),handler(changelayer,changelayer.caculateGuidePos))
		else 					--已装备
			print("已装备 - " .. nThisID)
			-- printTable(cur_value)
			--判断是否是套装
			local isSuit = false 
			if cur_localValue.suitID~=0 then
				isSuit = true
			end
			local strongDlg = g_carEquipmentLayer.new(cur_value,cur_localValue,nil,
				function()
					self:RefreshUI()
					-- resetEquipUI(self.equipments[nTag], cur_value.id, false)
				end,
				isSuit, curEquipments, self)
			:addTo(MainScene_Instance,50)
			GuideManager:_addGuide_2(10703, cc.Director:getInstance():getRunningScene(),handler(strongDlg,strongDlg.caculateGuidePos))
		end
		
    end
    self.equipments = {}
    local posX, posY
    for i=1, 4 do
    	-- if i<=3 then
    	-- 	posX = 160
    	-- 	posY = display.cy+190-(i-1)*140
    	-- else
    	-- 	posX = display.width-160
    	-- 	posY = display.cy+190-(i-4)*140
    	-- end
    	posX = display.cx - 300 + (i-1)*200
    	posY = 95
    	local j = i
    	if j>2 then
    		j = j + 1
    	end
    	self.equipments[j] = createEquipUI(j, true, true, EquipmentOnClicked)
    							:align(display.CENTER, posX, posY)
    							:addTo(self.uiLayer)
    	
    	self.equipments[j]:setTag(j)
    	-- self.equipments[i]:setVisible(false)
    end

    --金币，钻石
    local goldBar = display.newSprite("#improve2_img1.png")
    :addTo(self,50)
    :align(display.CENTER_TOP, display.cx-280, display.height-15)
    display.newSprite("common/common_Gold.png")
    :addTo(goldBar)
    :pos(-30, goldBar:getContentSize().height/2)
    self.goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
 	:addTo(goldBar,2)
 	:align(display.CENTER_LEFT, 15 , goldBar:getContentSize().height/2)
 	self.goldNumret = setLabelStroke(self.goldNum,22,nil,1,nil,nil,nil,"fonts/slicker.ttf")

    local diamondBar = display.newSprite("#improve2_img1.png")
    :addTo(self,50)
    :align(display.CENTER_TOP, display.cx+350, display.height-15)
    display.newSprite("common/common_Diamond.png")
    :addTo(diamondBar)
    :pos(-30, diamondBar:getContentSize().height/2)
    self.diamondNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
 	:addTo(diamondBar,2)
 	:align(display.CENTER_LEFT, 15 , diamondBar:getContentSize().height/2)
 	self.diamondNumret = setLabelStroke(self.diamondNum,22,nil,1,nil,nil,nil,"fonts/slicker.ttf")

 	self:setGoldDiamond()

    --墙
	local sprWall = self.widget:getChildByTag(2)


    --名字、战力
  --   cc.ui.UIPushButton.new("#improve2_img24.png")
  --   :addTo(sprWall)
  --   :pos(640, 560)
  --   :onButtonClicked(function(event)
  --   	if self.bCanOp then
		-- 	self:ShowIntroPanel()
		-- end
  --   	end)
    self.labName = display.newTTFLabel({
						text="",
						size=27,
						color=cc.c3b(55, 234, 255),
						align = cc.TEXT_ALIGNMENT_CENTER,
		                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
					})
					:align(display.CENTER_RIGHT, 708, 558)
					-- :align(display.CENTER, 640, 558)
					:addTo(sprWall,2)
	self.nameRet = setLabelStroke(self.labName, 27, cc.c3b(29, 32, 136), 2, nil, nil, nil, nil, false)

	local fightBar = display.newSprite("#improve2_img3.png")
		:addTo(self, 50)
		:align(display.CENTER_TOP, display.cx, display.height)
	display.newSprite("common2/com_strengthTag.png")
	:addTo(fightBar)
    :pos(80,fightBar:getContentSize().height/2+2)
	self.labFp = cc.LabelAtlas:_create()
            :addTo(fightBar)
            :align(display.CENTER_LEFT, 100,fightBar:getContentSize().height/2+2)
            self.labFp:initWithString("","common/common_Num2.png",27.3,39,string.byte(0))
	-- self.labFp = display.newTTFLabel({
	-- 					font = "fonts/slicker.ttf", 
	-- 					text="",
	-- 					size=24,
	-- 					color=cc.c3b(255, 255, 0),
	-- 					align = cc.TEXT_ALIGNMENT_LEFT,
	-- 	                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	-- 				})
	-- 				:pos(680, 540-2)
	-- 				:addTo(sprWall)
	-- 				self.labFp:setVisible(false)

	--战车等级
	self.carLevel = display.newSprite()
	:align(display.CENTER_LEFT, 708, 558)
	:addTo(sprWall)
	:scale(0.6)
	self.carLevelAdd = display.newSprite("common2/improve2_img42.png")
	:addTo(sprWall)
	:scale(0.6)
	self.carLevelAdd:setVisible(false)

	--SE
	-- self.SEbt = cc.ui.UIPushButton.new("#improve2_img45.png")
	-- 	    	:align(display.CENTER, display.cx+280, display.cy+257)
	-- 	    	:addTo(self)
	-- 	    	:onButtonPressed(function(event)
	-- 	    		local frame = display.newSpriteFrame("improve2_img47.png")
	-- 	    		self.seImg:setSpriteFrame(frame)
	-- 	    		end)
	-- 	    	:onButtonRelease(function(event)
	-- 	    		local frame = display.newSpriteFrame("improve2_img43.png")
	-- 	    		self.seImg:setSpriteFrame(frame)
	-- 	    		end)
	-- 	    	:onButtonClicked(function(event)
	-- 	    		showTips("暂未开放，敬请期待")
	-- 	    	end)
	-- self.SEbt:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 90)))
	-- self.seImg = display.newSprite("#improve2_img43.png")
	-- :align(display.CENTER, self.SEbt:getPositionX(), self.SEbt:getPositionY())
	-- :addTo(self)

	--战车进阶
	self.carAdvance = cc.ui.UIPushButton.new("#improve2_img46.png")
		    	:align(display.CENTER, display.cx+380, display.cy+257)
		    	:addTo(self)
		    	:onButtonPressed(function(event)
		    		local frame = display.newSpriteFrame("improve2_img48.png")
		    		self.caradImg:setSpriteFrame(frame)
		    		end)
		    	:onButtonRelease(function(event)
		    		local frame = display.newSpriteFrame("improve2_img44.png")
		    		self.caradImg:setSpriteFrame(frame)
		    		end)
		    	:onButtonClicked(function(event)
		    		-- if curCarData.level==10 then
		    		-- 	showTips("该战车已进阶到最高等级")
		    		-- 	return 
		    		-- end
		    		g_carAdvance.new(curCarData)
		    		:addTo(self,20)
		    	end)
	self.carAdvance:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 90)))
	self.caradImg = display.newSprite("#improve2_img44.png")
	:align(display.CENTER, self.carAdvance:getPositionX(), self.carAdvance:getPositionY())
	:addTo(self)

	--改装按钮
	self.btnAwake = cc.ui.UIPushButton.new("#improve2_img30.png")
				    	:align(display.CENTER, display.cx+480, display.cy+257)
		    			:addTo(self)
		    			:onButtonPressed(function(event)
				    		local frame = display.newSpriteFrame("improve2_img7.png")
				    		self.awakeBtImg:setSpriteFrame(frame)
				    		end)
				    	:onButtonRelease(function(event)
				    		local frame = display.newSpriteFrame("improve2_img9.png")
				    		self.awakeBtImg:setSpriteFrame(frame)
				    		end)
				    	:onButtonClicked(function(event)
				    		if false==self.bCanOp then
				    			return
				    		end
				    		local tmpId = curCarData.TemId
				    		local transform = transformData[tmpId]
				    		local toTmpId = transform.toId
				    		local loc_CarData = carData[tmpId]
				    		if 0==loc_CarData.wake then
				    			showTips("该车暂未开放改装")
				    			return
				    		end

				    		-- if tmpId==toTmpId then
				    		-- 	showTips("已改装至最高阶")
				    		-- else
				    			self.improCarLayer =  improveCarLayer.new()
				    			:addTo(self,20)
				    			-- local nCost = transform.ipvGold
					    		-- local nLevLimit = transform.level

					    		-- self:createRefitCarPanel(nCost,nLevLimit)
					    		-- GuideManager:_addGuide_2(12503, display.getRunningScene(),handler(self,self.caculateGuidePos))
					    		GuideManager:forceSendFinishStep(126)
					    		GuideManager:removeGuideLayer()
					    	-- end
				    	end)
	-- self.btnAwake:setButtonEnabled(false)
	self.btnAwake:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 90)))
	self.awakeBtImg = display.newSprite("#improve2_img9.png")
	:align(display.CENTER, self.btnAwake:getPositionX(), self.btnAwake:getPositionY())
	:addTo(self)

	--右侧技能，战车介绍技能
	local tmpBt = cc.ui.UIPushButton.new({normal = "#improve2_img52.png"})
	:addTo(self)
	:align(display.CENTER_RIGHT, display.width, display.height/2+90)
	:onButtonClicked(function(event)
		local tmpId = curCarData.TemId
		local loc_Car = carData[tmpId]
		if 0==loc_Car.sklOrder then
			showTips("该战车专属技能暂未开放")
		else
			self:performWithDelay(function ()
				self:ShowSkillPanel()
			end,0.01)
		end
		end)
	self:createBtLabel(tmpBt,"技能介绍", cc.c3b(0, 58, 92))


	local tmpBt = cc.ui.UIPushButton.new("#improve2_img53.png")
	:addTo(self)
	:align(display.CENTER_RIGHT, display.width, display.height/2-90)
	:onButtonClicked(function(event)
		self:ShowIntroPanel()
		end)
	self:createBtLabel(tmpBt,"改装属性", cc.c3b(133, 16, 19))

	--专属技能
	self.sklBt = cc.ui.UIPushButton.new("#improve2_img31.png")
		    	:align(display.CENTER, display.cx+580, display.cy+257)
		    	:addTo(self, 11)
		    	:onButtonPressed(function(event)
		    		local frame = display.newSpriteFrame("improve2_img8.png")
		    		self.sklBtImg:setSpriteFrame(frame)
		    		end)
		    	:onButtonRelease(function(event)
		    		local frame = display.newSpriteFrame("improve2_img10.png")
		    		self.sklBtImg:setSpriteFrame(frame)
		    		end)
		    	:onButtonClicked(function(event)
		    		local tmpId = curCarData.TemId
					local loc_Car = carData[tmpId]
					if 0==loc_Car.sklOrder then
						showTips("该战车专属技能暂未开放")
					else
						if self.skillPanel and self.skillPanel:isVisible() then
							transition.execute(self.skillPanel:getChildByTag(10), 
								cc.MoveTo:create(0.2, cc.p(display.width+539, display.cy-60)), 
								{
							    onComplete = function()
							        self.skillPanel:setVisible(false)
							    end,
							})
						else
							self:performWithDelay(function ()
								self:ShowSkillPanel()
							end,0.01)
						end
						GuideManager:_addGuide_2(11006, display.getRunningScene(),handler(self,self.caculateGuidePos))
					end
		    	end)
	self.sklBt:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 90)))
	self.sklBtImg = display.newSprite("#improve2_img10.png")
	:align(display.CENTER, self.sklBt:getPositionX(), self.sklBt:getPositionY())
	:addTo(self, 11)

	
	--判断是否需要小红点
	self.SklRedPoint = nil 

	--左滑动
    self.toLeft = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self.uiLayer)
    :pos(display.cx-235, display.cy-30)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
    	event.target:setScale(1.0)
        end)
    :onButtonClicked(function(evnet)
    	for i,value in ipairs(self.sortList) do
    		if value==ImproveLayer.nCurSelCarID then
    			idx = i-1
    			if idx<1 then idx=#self.sortList end
    			ImproveLayer.nCurSelCarID = self.sortList[idx]
    			self:updateCarData()
				self:RefreshUI()
				return
    		end
    	end
    	end)
    local seq = transition.sequence({
    	cc.FadeTo:create(1.5, 80),
	    cc.FadeTo:create(1.5, 255),
	})
    self.toLeft:runAction(cc.RepeatForever:create(seq))
    self.toLeft:setVisible(false)
    --右滑动
    self.toRight = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self.uiLayer)
    :pos(display.cx+235, display.cy-30)
    :onButtonPressed(function(event)
        event.target:setScaleX(-0.95)
        event.target:setScaleY(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScaleX(-1)
        event.target:setScaleY(1)
        end)
    :onButtonClicked(function(evnet)
    	for i,value in ipairs(self.sortList) do
    		if value==ImproveLayer.nCurSelCarID then
    			idx = i+1
    			if idx>#self.sortList then idx=1 end
    			ImproveLayer.nCurSelCarID = self.sortList[idx]
    			self:updateCarData()
				self:RefreshUI()
				return
    		end
    	end
    	end)
    self.toRight:setScaleX(-1)
    local seq = transition.sequence({
    	cc.FadeTo:create(1.5, 80),
	    cc.FadeTo:create(1.5, 255),
	})
    self.toRight:runAction(cc.RepeatForever:create(seq))
    self.toRight:setVisible(false)


	GuideManager:_addGuide_2(10702, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11002, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10802, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10902, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(12502, self,handler(self,self.caculateGuidePos))
end
--属性趋势图
function ImproveLayer:createTendencyPic(parentNode,posX,poY,scale)
	if scale==nil then
		scale = 1
	end
	--属性趋势图
	-- self.attrWidget.tendencyBg
	local tendencyBg = display.newSprite("#Improve_Img34.png")
									:align(display.CENTER, posX, poY)
									:addTo(parentNode,0,100)
									:scale(scale)

	local offset = {
		{0, 10},
		{20, 0},
		{20, 0},
		{-20, 0},
		{-20, 0},
	}
	for i=1, #tendencyCfg do
		display.newTTFLabel({
				text=tendencyCfg[i].name,
				size=16,
				color=cc.c3b(237, 227, 199),
				align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
			})
			:align(display.CENTER, tendencyCfg[i].endPosX+offset[i][1], tendencyCfg[i].endPosY+offset[i][2])
			:addTo(tendencyBg)
	end
end

function ImproveLayer:createRefitCarPanel(nCost,nLevLimit)
	local masklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 220))
    :addTo(display.getRunningScene(),51)
    -- local function  func()
    --     masklayer:removeSelf()
    -- end
    -- masklayer:setOnTouchEndedEvent(func)
    --关闭按钮
    cc.ui.UIPushButton.new({
    	normal = "common/common_CloseBtn_1.png",
    	pressed = "common/common_CloseBtn_2.png"
    	})
    :addTo(masklayer,2)
    :pos(display.cx+530,display.cy+310)
    :onButtonClicked(function(event)
    	masklayer:removeSelf()
    	end)
    --=========
    --左上框
    local left_topBox = display.newSprite("#Improve_Img36.png")
    :addTo(masklayer)
    :pos(display.cx-300,display.cy+180)
    --战车
    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=curCarData.TemId})
						:pos(170, left_topBox:getContentSize().height/2-50)
						:addTo(left_topBox)
						carModel:setScaleY(0.7*2*0.75)
						carModel:setScaleX(-0.7*2*0.75)
	--战车名字
	self.carName1 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
	:addTo(left_topBox)
	:align(display.CENTER, 170, 60)
	self.carName1:setString(carData[curCarData.TemId].name)


    --框
    local propertyBox1 = display.newSprite("#Improve_Img37.png")
    :addTo(left_topBox)
    :pos(left_topBox:getContentSize().width-110, left_topBox:getContentSize().height/2+5)
    --趋势图
    self:createTendencyPic(propertyBox1,propertyBox1:getContentSize().width/2, 150, 0.75)
    local talents = self:DrawTendency(propertyBox1,curCarData.TemId)
    --属性
    local talentNum1 = {}
    for i=1,#talents do
    	local singleTalent = string.split(talents[i], "#")
    	local talentName
    	for key,value in ipairs(tendencyCfg) do
    		if tonumber(singleTalent[1])==value.talent then
    			talentName = value.name
    			break 
    		end
    	end
    	cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = MYFONT_COLOR})
    	:addTo(propertyBox1)
    	:pos(15, 60 - (i-1)*37)
    	:setString(talentName.."：")
    	local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = MYFONT_COLOR})
    	:addTo(propertyBox1)
    	:pos(90, 60 - (i-1)*37-2)
    	talentNum1[i] = tonumber(singleTalent[2])*100
    	label:setString(talentNum1[i].."%")
    end
    
    --=========
    --中间箭头
    display.newSprite("#Improve_Img42.png")
    :addTo(masklayer)
    :pos(display.cx,display.cy+180)
    --=========
    --右上框
    local right_topBox = display.newSprite("#Improve_Img36.png")
    :addTo(masklayer)
    :pos(display.cx+300,display.cy+180)
    local toTmpId = transformData[curCarData.TemId].toId
    --战车
    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=toTmpId})
						:pos(170, right_topBox:getContentSize().height/2-50)
						:addTo(right_topBox)
						carModel:setScaleY(0.7*2*0.75)
						carModel:setScaleX(-0.7*2*0.75)
	--战车名字
	self.carName2 = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
	:addTo(right_topBox)
	:align(display.CENTER, 170, 60)
	self.carName2:setString(carData[toTmpId].name)
    --框
    local propertyBox2 = display.newSprite("#Improve_Img37.png")
    :addTo(right_topBox)
    :pos(right_topBox:getContentSize().width-110, right_topBox:getContentSize().height/2+5)
    --趋势图
    self:createTendencyPic(propertyBox2,propertyBox1:getContentSize().width/2, 150, 0.75)
    local talents = self:DrawTendency(propertyBox2, toTmpId)
    --属性
    talentNum2 = {}
    for i=1,#talents do
    	local singleTalent = string.split(talents[i], "#")
    	local talentName
    	for key,value in ipairs(tendencyCfg) do
    		if tonumber(singleTalent[1])==value.talent then
    			talentName = value.name
    			break 
    		end
    	end
    	cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = MYFONT_COLOR})
    	:addTo(propertyBox2)
    	:pos(15, 60 - (i-1)*37)
    	:setString(talentName.."：")
    	local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = MYFONT_COLOR})
    	:addTo(propertyBox2)
    	:pos(90, 60 - (i-1)*37-2)
    	talentNum2[i] = (tonumber(singleTalent[2])*100)
    	label:setString(talentNum2[i].."%")

    	if talentNum1[i]==nil or talentNum2[i]>talentNum1[i] then
    		label:setColor(cc.c3b(0, 255, 0))
    		display.newSprite("common/Improve_Img17.png")
    		:addTo(propertyBox2)
    		:pos(label:getPositionX()+label:getContentSize().width+10, 60 - (i-1)*37)
    	else
    		label:setColor(MYFONT_COLOR)
    	end
    end
    --=====================
    --弯条
    display.newSprite("#Improve_Img38.png")
    :addTo(left_topBox)
    :pos(left_topBox:getContentSize().width/2+60, -35)

    display.newSprite("#Improve_Img38.png")
    :addTo(right_topBox)
    :pos(left_topBox:getContentSize().width/2-60, -35)
    :setScaleX(-1)
    --改装条件
    display.newSprite("#Improve_Img41.png")
    :addTo(masklayer,2)
    :pos(display.cx, display.cy-53)
    --条件框
    local conditionBox = display.newScale9Sprite("#Improve_Img39.png",display.cx,display.cy-180,
    	cc.size(359, 195), cc.rect(40,40,47,32))
    :addTo(masklayer)
    --等级条件
    local bar = display.newScale9Sprite("#Improve_Img40.png",conditionBox:getContentSize().width/2, 135,
    	cc.size(337, 48), cc.rect(10,10,14,14))
    :addTo(conditionBox)
    display.newSprite("#Improve_Img43.png")
    :addTo(bar)
    :pos(70, bar:getContentSize().height/2)

    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(230, 0, 18)})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-2)
    level:setString(nLevLimit)
    if srv_userInfo.level<nLevLimit then
    	level:setColor(cc.c3b(230, 0, 18))
    else
    	level:setColor(cc.c3b(0, 255, 18))
    end
    --需要金币
    local bar = display.newScale9Sprite("#Improve_Img40.png",conditionBox:getContentSize().width/2, 75,
    	cc.size(337, 48), cc.rect(10,10,14,14))
    :addTo(conditionBox)
    display.newSprite("common/common_Gold.png")
    :addTo(bar)
    :pos(70, bar:getContentSize().height/2)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-2)
    :setString("X "..nCost)
    --确定按钮
    local okbt = cc.ui.UIPushButton.new({
    	normal = "common/commonBt3_1.png",
    	pressed = "common/commonBt3_2.png"
    	})
    :addTo(conditionBox)
    :pos(conditionBox:getContentSize().width/2, 0)
    :onButtonClicked(function(event)
    	if srv_userInfo.level<nLevLimit then
			showTips("无法改装，请先提升战队等级")
		-- elseif srv_userInfo.gold<nCost then
		-- 	showTips("无法改装，金币不足")
		-- 	if GuideManager.NextStep ==12504 then
		-- 		masklayer:removeSelf()
		-- 		GuideManager:forceSendFinishStep(126)
		-- 		GuideManager:_addGuide_2(12504,cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
		-- 	end
		else
			CarManager:ReqImprove(ImproveLayer.nCurSelCarID)
			startLoading()
			masklayer:removeSelf()
			
			GuideManager:_addGuide_2(12504,cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
		end
    	end)
    okbt:setScale(1.2)
    local img = display.newSprite("common/common_confirm.png")
    :addTo(okbt)
    self.guideBtn2 = okbt
    img:setScale(1/1.2)
end

--播放战车改造动画
function ImproveLayer:PlayAction1()
	self.light1:setVisible(false)
	self.light2:setVisible(false)
	self.bCanOp = false
	self.actMgr:playActionByName("gaizaozhongxin_1.ExportJson", "Animation1")
	local seq = transition.sequence({
			cc.Hide:create(),
			cc.DelayTime:create(4),
			cc.Show:create(),
		})
	transition.execute(self.uiLayer, seq, {onComplete=function()
		self.bCanOp = true
		self.light1:setVisible(true)
		self.light2:setVisible(true)
	end})
end

--播放进场动画
function ImproveLayer:PlayAction2()
	self.btnAwake:setButtonEnabled(false)

	transition.rotateTo(self.sprRotate, {rotate=180, time=0.5, onComplete=function()
		self.sprRotate:setVisible(false)
		transition.moveBy(self.leftMask, {x=-120, time=0.5, onComplete=function()
			self.btnAwake:setButtonEnabled(true)
		end})

		transition.moveBy(self.rightMask, {x=120, time=0.5})
	end})
end

--播放改造特效
function ImproveLayer:PlayAction3()
	if nil==self.sprEff then
		return
	end

	local frames = display.newFrames("ImproveEff1_%02d.png", 1, 44)
    local animation = display.newAnimation(frames, 2/44)
    transition.playAnimationOnce(self.sprEff, animation, nil, function()
    	self.sprEff:setVisible(false)
    end, 0.5)
end

--检测可改装状态
function ImproveLayer:CheckAwakeState()
	if nil==curCarData then
		return
	end

	local tmpId = curCarData.TemId
	local loc_CarData = carData[tmpId]
	if 0==loc_CarData.wake then
		self.leftMask:stopAllActions()
    	self.rightMask:stopAllActions()
		self.sprRotate:stopAllActions()
		self.btnAwake:setButtonEnabled(false)

		local tmpSize = self.CPanel:getContentSize()
		local tmpCx = tmpSize.width/2
		local tmpCy = tmpSize.height/2
		self.leftMask:setPosition(tmpCx-58, tmpCy-15)
    	self.rightMask:setPosition(tmpCx+58, tmpCy-15)
		self.sprRotate:setVisible(true)
		self.sprRotate:setRotation(0)
	else
		self:PlayAction2()
	end
end

--绘制趋势图
function ImproveLayer:DrawTendency(parentNode,carTmpId)
	if nil==ImproveLayer.nCurSelCarID then
		return
	end

	--self.attrWidget.tendencyNode
	local tendencyNode = parentNode:getChildByTag(100)
	if nil~=tendencyNode then
		tendencyNode:removeFromParent()
		tendencyNode = nil
	end
	-- local tptID = curCarData.TemId
	local tptID = carTmpId
	local loc_Car = carData[tptID]
	if nil==loc_Car then
		return
	end
	local talents = string.split(loc_Car.talent, "|")
	local arrTalent = {}

	if loc_Car.talent~="null" then
		for i=1, #talents do
			singleTalent = string.split(talents[i], "#")
			if singleTalent[1]==nil then
			end
			arrTalent[tonumber(singleTalent[1])] = tonumber(singleTalent[2])
		end
	end
	

	--初始坐标
	local points = {
	    {tendencyCfg[1].beginPosX, tendencyCfg[1].beginPosY},
	    {tendencyCfg[2].beginPosX, tendencyCfg[2].beginPosY},
	    {tendencyCfg[3].beginPosX, tendencyCfg[3].beginPosY},
	    {tendencyCfg[4].beginPosX, tendencyCfg[4].beginPosY},
	    {tendencyCfg[5].beginPosX, tendencyCfg[5].beginPosY},
	}

	local vector, factor
	for i=1, #tendencyCfg do
		factor = arrTalent[tendencyCfg[i].talent]
		if nil~=factor then
			factor = factor/0.5  --0.5为上限

			--计算相对于基础值改变的向量
			vector = {tendencyCfg[i].endPosX-tendencyCfg[i].beginPosX, tendencyCfg[i].endPosY-tendencyCfg[i].beginPosY}
			vector[1] = vector[1]*factor
			vector[2] = vector[2]*factor

			--最终点坐标
			points[i][1] = points[i][1]+vector[1]
			points[i][2] = points[i][2]+vector[2]
		end
	end

	local params = {fillColor=cc.c4f(0.09, 0.72, 0.93, 0.5), borderColor=cc.c4f(0.09, 0.72, 0.93, 0.5)}
	--self.attrWidget.tendencyNode
	local tendencyNode = display.newPolygon(points, params)
										:addTo(parentNode,0,100)
										:pos(45, parentNode:getContentSize().height-145)
										:scale(0.9)

	return talents
end

--战车信息返回
function ImproveLayer:OnCarPropertyRet(cmd)
	if 1==cmd.result then
		if self.isFirstReq then
			self.isFirstReq = false
			local nCars = #CarManager.srv_CarProp.cars
			if nCars>=1 then
				ImproveLayer.nCurSelCarID = CarManager.srv_CarProp.cars[1].id
				local mincarTemId = CarManager.srv_CarProp.cars[1].TemId
				--为了将主角车第一个显示，按战车模板Id比较
				for i=1, nCars do 
					-- if ImproveLayer.nCurSelCarID<CarManager.srv_CarProp.cars[i].id then
					-- 	ImproveLayer.nCurSelCarID = CarManager.srv_CarProp.cars[i].id
					-- end
					if mincarTemId>CarManager.srv_CarProp.cars[i].TemId then
						mincarTemId = CarManager.srv_CarProp.cars[i].TemId
						ImproveLayer.nCurSelCarID = CarManager.srv_CarProp.cars[i].id
					end
				end
			end
		end
		
		self:InitSortList()
		self:updateCarData()
		self:RefreshUI()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--开孔返回
function ImproveLayer:OnUnlockRet(cmd)
	if 1==cmd.result then
		self:RefreshEquipments()
		GuideManager:_addGuide_2(10902, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
	else
		showTips(cmd.msg)
		GuideManager:removeGuideLayer()
	end
	endLoading()
end

--提升返回
function ImproveLayer:OnImproveRet(cmd)
	if 1==cmd.result then
		self.improCarLayer:removeSelf()
		self:updateCarData()
		self:PlayAction1()
		self:PlayAction3()
		self:performWithDelay(handler(self, self.RefreshUI), 1.7)

		curCarData.stuffInten = "0|0|0|0"
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--刷新战车模型
function ImproveLayer:RefreshCarModel()
	if nil==ImproveLayer.nCurSelCarID then
		return
	end

	if self.carModel then
		self.carModel:removeFromParent()
		self.carModel = nil
	end
	self.carModel = ShowModel.new({modelType=ModelType.Tank, templateID=curCarData.TemId})
						:pos(640, 220)
						:addTo(self.carBase)
end

--刷新属性
function ImproveLayer:RefreshAttr()
	if nil==ImproveLayer.nCurSelCarID then
		return
	end

	--驾驶员信息
	local memberInfo, memberTab = curCarData.carMember, nil
	if nil~=memberInfo.tptId then
		memberTab = memberData[memberInfo.tptId]
	end

	--战车名字、攻击力
	self.labName:setString(curCarData.name)
	setLabelStrokeString(self.labName, self.nameRet)
	self.labFp:setString(curCarData.strength)


	local num = 36 + math.floor((curCarData.carLvl+1)/2)
	-- local frame = display.newSpriteFrame("common2/improve2_img"..num..".png")
	self.carLevel:setTexture("common2/improve2_img"..num..".png")
	self.carLevelAdd:align(display.CENTER_LEFT, self.carLevel:getContentSize().width*0.8+690, 563)
	if math.mod(curCarData.carLvl, 2)==0 then
		self.carLevelAdd:setVisible(true)
	else
		self.carLevelAdd:setVisible(false)
	end

	--装备信息
	local holes = curCarData.holes
	local equipmentInfo = {}
	for i=1, #holes do
		if -1~=holes[i] and 0~=holes[i] then
			equipmentInfo[i] = srv_carEquipment["item"][holes[i]]
		end
	end

	--道具配表信息
    local itemTab = {
    					addPower = 0,
    					addAgility = 0,
    					addEnergy = 0,
    					addHp 	= 0,
    					addDef 	= 0,
    					addCri 	= 0,
    					addMiss = 0,
    					addHit 	= 0,
    					addErecover = 0,
					}
	for i=1, 6 do
		if nil~=equipmentInfo[i] then
			itemTab[i] = itemData[equipmentInfo[i].tmpId]
		end
	end

	--装备的套装Id
	local suitIds = {}
	--技能配表信息
	local skillTab = {}
    for i=1, 6 do
    	if nil~=itemTab[i] then
    		skillTab[i] = skillData[itemTab[i].sklId]
    		suitIds[i] = itemTab[i].suitID
    	end
	end

	--计算套装属性
	local suitHp, suitMain, suitSub, suitDef, suitCri, suitHit, suitMiss, suitErecover = 0,0,0,0,0,0,0,0
	local isSuit = true
	local tmpSuitId
	for i,value in pairs(suitIds) do
		if value==0 then
			isSuit = false
			break
		elseif i==1 then
			tmpSuitId = value
		elseif tmpSuitId~=value then
			isSuit = false
			break
		end
	end
	--如果是套装
	if isSuit and tmpSuitId then
		print("套装生效")

		local tmpSuitData = suitData[tmpSuitId]
		suitHp = tmpSuitData.hp
		suitMain = tmpSuitData.mainAtk
		suitSub = tmpSuitData.subAtk
		suitDef = tmpSuitData.defense

		suitCri = tmpSuitData.cri
		suitHit = tmpSuitData.hit
		suitMiss = tmpSuitData.miss
		suitErecover = tmpSuitData.erecover
	else
		print("套装无效")
	end

	--计算道具增加属性
	for i=1, 6 do
		if nil~=itemTab[i] then
			local strengthenLev = equipmentInfo[i].advLvl-1
			itemTab.addPower 	= itemTab.addPower + (itemTab[i].power+itemTab[i].powerGF*strengthenLev)
			itemTab.addAgility 	= itemTab.addAgility + (itemTab[i].agility+itemTab[i].agilityGF*strengthenLev)
			itemTab.addEnergy 	= itemTab.addEnergy + (itemTab[i].energy+itemTab[i].energyGF*strengthenLev)
			itemTab.addHp  		= itemTab.addHp + (itemTab[i].hp+itemTab[i].hpGF*strengthenLev)
			itemTab.addDef 		= itemTab.addDef + (itemTab[i].defense+itemTab[i].defGF*strengthenLev)
			itemTab.addCri 		= itemTab.addCri + (itemTab[i].cri+itemTab[i].criGF*strengthenLev)
			itemTab.addMiss 	= itemTab.addMiss + (itemTab[i].miss+itemTab[i].missGF*strengthenLev)
			itemTab.addHit 		= itemTab.addHit + (itemTab[i].hit+itemTab[i].hitGF*strengthenLev)
			itemTab.addErecover = itemTab.addErecover + (itemTab[i].erecover+itemTab[i].erGF*strengthenLev)
		end
	end
	--装备附加属性（除了主炮和副炮）
	--战车装备不需要加体质、敏捷和力量
	itemTab.addHp = itemTab.addHp + itemTab.addEnergy*20
	itemTab.addDef = itemTab.addDef + itemTab.addAgility*1.5
	itemTab.addCri = itemTab.addCri + itemTab.addPower*0.1
	itemTab.addMiss = itemTab.addMiss + itemTab.addEnergy*0.1
	itemTab.addHit = itemTab.addHit + itemTab.addAgility*0.1

	--战车天赋（都没有加se炮的，需要的时候自己添加，接口有返回）
	local carMainTat, carSubTat, carHpTat, carDefTat, carCriTat, carHitTat, carMissTat = 0, 0, 0, 0, 0, 0, 0 
	carMainTat = curCarData.mainAttAdd
	carSubTat = curCarData.subAttAdd
	carHpTat = curCarData.hpAdd
	carDefTat = curCarData.defenseAdd
	carCriTat = curCarData.criAdd
	carHitTat = curCarData.hitAdd
	carMissTat = curCarData.missAdd

	--职业加成（没有加Se炮）
	local proMainAtkAdd, proSubAtkAdd, proHpAdd, proDefAdd, proCriAdd, proHitAdd, proMissAdd = 0, 0, 0, 0, 0, 0, 0
	--当前职业的职业养成本地数据
	if memberTab~=nil then --车上坐了人才需要计算
		local curProfDevData = {}
		for key,value in pairs(profDevData) do
			if value.type==memberTab.proType then
				curProfDevData[value.level] = value
			end
		end
		proMainAtkAdd = curProfDevData[memberInfo.proLevel].mainAtk
		proSubAtkAdd = curProfDevData[memberInfo.proLevel].subAtk
		proHpAdd = curProfDevData[memberInfo.proLevel].hp2
		proDefAdd = curProfDevData[memberInfo.proLevel].defense2
		proCriAdd = curProfDevData[memberInfo.proLevel].cri2
		proHitAdd = curProfDevData[memberInfo.proLevel].hit2
		proMissAdd = curProfDevData[memberInfo.proLevel].miss2
	end


	--被动技能固定值，被动技能百分比加成
	local sklMainAtkAdd, sklSubAtkAdd, sklDefAdd, sklHpAdd, sklCriAdd, sklHitAdd, sklMissAdd = 0, 0, 0, 0, 0, 0, 0
	local sklMainAtkAddPer, sklSubAtkAddPer, sklDefAddPer, sklHpAddPer, sklCriAddPer, sklHitAddPer, sklMissAddPer = 0, 0, 0, 0, 0, 0, 0
	local localCarData = carData[curCarData.TemId]
	local carSkillIds = localCarData.skillIds
	local skllArr = lua_string_split(carSkillIds, "|")
	if skllArr[2]~=nil then --有被动技能
		local passiveSkl = lua_string_split(skllArr[2], "#")
		for i,value in ipairs(curCarData.skl) do
			if value.sts==1 then --技能已激活
				for j=1,#passiveSkl do
					if value.id==tonumber(passiveSkl[j]) then
						local loc_Skl = skillData[tonumber(passiveSkl[j])]
						if nil~=loc_Skl then
							--1：人物攻击 2：主炮攻击 3：副炮攻击 4：防御 5：血量 6：暴击 7：命中 8：闪避
							if 2==loc_Skl.aplType then
								sklMainAtkAdd = sklMainAtkAdd+loc_Skl.add
								sklMainAtkAddPer = sklMainAtkAddPer+loc_Skl.addPercent
							elseif 3==loc_Skl.aplType then
								sklSubAtkAdd = sklSubAtkAdd+loc_Skl.add
								sklSubAtkAddPer = sklSubAtkAddPer+loc_Skl.addPercent
							elseif 4==loc_Skl.aplType then
								sklDefAdd = sklDefAdd+loc_Skl.add
								sklDefAddPer = sklDefAddPer+loc_Skl.addPercent
							elseif 5==loc_Skl.aplType then
								sklHpAdd = sklHpAdd+loc_Skl.add
								sklHpAddPer = sklHpAddPer+loc_Skl.addPercent
							elseif 6==loc_Skl.aplType then
								sklCriAdd = sklCriAdd+loc_Skl.add
								sklCriAddPer = sklCriAddPer+loc_Skl.addPercent
							elseif 7==loc_Skl.aplType then
								sklHitAdd = sklHitAdd+loc_Skl.add
								sklHitAddPer = sklHitAddPer+loc_Skl.addPercent
							elseif 8==loc_Skl.aplType then
								sklMissAdd = sklMissAdd+loc_Skl.add
								sklMissAddPer = sklMissAddPer+loc_Skl.addPercent
							end
						end
					end
				end
			end
		end
	end

	--战车觉醒增加属性
	local carTmpId = curCarData.TemId
    local carTmp = tonumber(string.sub(tostring(carTmpId),1,3))
	local CAR_ADTAB = CARLEVEL_TMPID[carTmp][curCarData.carLvl]
	-- print(CAR_ADTAB.mainAtkPro)

	local dataInfo = nil
	local tmpTab, tmpStr, tmpVal

	--主炮
	dataInfo = skillTab[1]
	tmpTab = self.attrWidget.MainGun
	if nil==dataInfo then
		tmpStr = "0"
		tmpTab.labCD:setString(tmpStr)
	else
		tmpStr = itemTab[1].sklCD
		tmpTab.labCD:setString(tmpStr)
	end
	local mainCD = tonumber(tmpStr)

	dataInfo = itemTab[1]
	if nil==dataInfo then
		tmpVal = 0
	else
		local strengthenLev = equipmentInfo[1].advLvl-1
		local atk = 0
		--主炮附加属性
		atk = atk + (dataInfo.power+dataInfo.powerGF*strengthenLev)*2 + (dataInfo.attack+dataInfo.atkGF*strengthenLev)
		tmpVal = atk*(1+carMainTat+proMainAtkAdd+sklMainAtkAddPer)+sklMainAtkAdd + suitMain + curCarData.mainAtk

		tmpVal = tmpVal*(1+ CAR_ADTAB.mainAtkPro/100)
	-- 	print("主炮每项属性值***************")
	-- print("atk:"..atk)
	-- print("carMainTat:"..carMainTat)
	-- print("proMainAtkAdd:"..sklMainAtkAddPer)
	-- print("sklMainAtkAddPer:"..sklMainAtkAddPer)
	-- print("sklMainAtkAdd:"..sklMainAtkAdd)
	-- print("suitMain:"..suitMain)
	-- print("curCarData.mainAtk:"..curCarData.mainAtk)


	end
	local mainTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%d", tmpVal)
	tmpTab.labAtk:setString(tmpStr)


	--副炮
	dataInfo = skillTab[2]
	tmpTab = self.attrWidget.SubGun
	if nil==dataInfo then
		tmpStr = "0"
		tmpTab.labCD:setString(tmpStr)
	else
		tmpStr = dataInfo.sklCD
		tmpTab.labCD:setString(tmpStr)
	end
	local subCD = tonumber(tmpStr)

	dataInfo = itemTab[2]
	if nil==dataInfo then
		tmpVal = 0
	else
		local strengthenLev = equipmentInfo[2].advLvl-1
		--副炮附加属性
		local atk = 0
		atk = atk + (dataInfo.power+dataInfo.powerGF*strengthenLev)*2 + (dataInfo.attack+dataInfo.atkGF*strengthenLev)
		tmpVal = atk*(1+carSubTat+proSubAtkAdd+sklSubAtkAddPer)+sklSubAtkAdd  + suitSub + curCarData.subAtk
		tmpVal = tmpVal*(1+ CAR_ADTAB.subAtkPro/100)
	end
	local subTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%d", tmpVal)
	tmpTab.labAtk:setString(tmpStr)

	--生命值
	tmpTab = self.attrWidget.HP
	
	tmpVal = itemTab.addHp*(1+carHpTat+proHpAdd+sklHpAddPer)+sklHpAdd + suitHp + curCarData.hp
	tmpVal = tmpVal*(1+ CAR_ADTAB.hpPro/100)
	-- print(itemTab.addHp)
	-- print(carHpTat+proHpAdd+sklHpAddPer)
	-- print(sklHpAdd)
	-- print(suitHp)
	-- print(curCarData.hp)
	-- print(CAR_ADTAB.hpPro)
	local hpTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%d", tmpVal)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/80000*100)

	--防御
	tmpTab = self.attrWidget.DEF
	tmpVal = itemTab.addDef*(1+carDefTat+proDefAdd+sklDefAddPer)+sklDefAdd + suitDef + curCarData.defense
	tmpVal = tmpVal*(1+ CAR_ADTAB.defensePro/100)
	local defTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%d", tmpVal)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/3000*100)

	--命中
	tmpTab = self.attrWidget.HIT
	tmpVal = memberInfo.hit or 0
	if tmpVal==0 then
		tmpVal = tmpVal*(1+carHitTat+sklHitAddPer)+sklHitAdd + suitHit + curCarData.hit
	end
	tmpVal = tmpVal*(1+ CAR_ADTAB.hitPro/100)
	tmpStr = string.format("%.2f%%", tmpVal/10)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/10)

	--暴击
	tmpTab = self.attrWidget.CRI
	tmpVal = memberInfo.cri or 0
	if tmpVal==0 then
		tmpVal = tmpVal*(1+carCriTat+sklCriAddPer)+sklCriAdd + suitCri + curCarData.cri
	end
	local criTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%.2f%%", tmpVal/10)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/10)

	
	--闪避
	tmpTab = self.attrWidget.MISS
	tmpVal = memberInfo.miss or 0
	if tmpVal==0 then
		tmpVal = (tmpVal+itemTab.addMiss)*(1+carMissTat+sklMissAddPer)+sklMissAdd + suitMiss + curCarData.miss
	end
	local missTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%.2f%%", tmpVal/10)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/10)

	--能量回复
	tmpTab = self.attrWidget.ENERGY
	tmpVal = carData[curCarData.TemId].erecover*(1+itemTab.addErecover)  + suitErecover
	local enTmpVal = tonumber(tmpVal)
	tmpStr = string.format("%.2f", tmpVal)
	tmpTab.labVal:setString(tmpStr)
	tmpTab.progressBar:setPercentage(tmpVal/10*100)


	--单位战斗力计算
	--有效伤害
	local effectiveDamage = subTmpVal*(1+criTmpVal*0.001*0.5)/subCD + mainTmpVal*(1+criTmpVal*0.001*0.5)*enTmpVal
	--有效血量
	local effectHp = hpTmpVal+ (missTmpVal*500)
	--技能激活加权
	local skillAdd = 0
	local tabSkill = curCarData.skl
	if tabSkill[1].sts>=0 then
		skillAdd = skillAdd + 1000
	end
	if tabSkill[2].sts>=0 then
		skillAdd = skillAdd + 1000
	end
	if tabSkill[3].sts>=0 then
		skillAdd = skillAdd + 1500
	end
	if tabSkill[4].sts>=0 then
		skillAdd = skillAdd + 2500
	end
	--单位战斗力
	local strength = effectiveDamage + defTmpVal + effectHp*0.1 + skillAdd
	strength = math.floor(strength)
	-- print(effectiveDamage)
	-- print(defTmpVal)
	-- print(effectHp)
	-- print(skillAdd)
	-- print(strength)
	self.labFp:setString(strength)
end

--刷新装备
function ImproveLayer:RefreshEquipments()
	if nil==ImproveLayer.nCurSelCarID then
		return
	end

	local holes = curCarData.holes
	local tmpId
	for j=1, #holes-2 do
		local i=j
		if i>2 then
			i = i +1
		end
		--=================
		--防错处理，处理装备丢失的问题,holes中有装备ID,但是在背包中不存在
		local value = srv_carEquipment["item"][holes[i]]
		if value==nil and holes[i]>0 then
			holes[i] = 0
		end
		--=================
		if -1==holes[i] then 		--未开孔
			resetEquipUI(self.equipments[i], i, true)
		elseif 0==holes[i] then 	--已开孔，未装备
			local tmptype = i+100
			if tmptype==103 or tmptype==106 then
				resetEquipUI(self.equipments[i], i, true)
			else
				resetEquipUI(self.equipments[i], i, false)
			end
		else 						--已装备
			local tmptype = i+100
			if tmptype==103 or tmptype==106 then
				resetEquipUI(self.equipments[i], i, true)
			else
				resetEquipUI(self.equipments[i], holes[i], false)
			end
		end
	end
end

--刷新界面UI
function ImproveLayer:RefreshUI()
	if nil==ImproveLayer.nCurSelCarID then
		return
	end

	self:RefreshCarModel()
	self:RefreshAttr()
	self:RefreshEquipments()
	self:DrawTendency(self.attrPanel,curCarData.TemId)
	-- self:CheckAwakeState()
	--技能小红点更新
	self:bHaveSklRedPoint()

	if #CarManager.srv_CarProp.cars>1 then
		self.toLeft:setVisible(true)
		self.toRight:setVisible(true)
	else
		self.toLeft:setVisible(false)
		self.toRight:setVisible(false)
	end
end

--选择战车
function ImproveLayer:SelCar(nThisID)
	if nThisID==ImproveLayer.nCurSelCarID then
		return
	end

	ImproveLayer.nCurSelCarID = nThisID
	self:updateCarData()
	self:RefreshUI()
end

--创建战车简介面板
function ImproveLayer:CreateIntroPanel()
	local tmpSize = cc.size(539, 533)
	local tmpCx = tmpSize.width/2
	local tmpCy = tmpSize.height/2
	local tmpNode

	self.introPanel = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
						:addTo(self, 12)
	self.introPanel:setTouchEnabled(true)
	self.introPanel:setTouchSwallowEnabled(true)
    self.introPanel:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            return true

        elseif event.name == "moved" then
        elseif event.name == "ended" then
            transition.execute(tmpNode, 
			cc.MoveTo:create(0.2, cc.p(display.width+tmpSize.width, display.cy-60)), 
			{
		    onComplete = function()
		        self.introPanel:setVisible(false)
		    end,
		})
        end

    end)

	tmpNode = display.newSprite("#improve2_img21.png")
						:align(display.CENTER_RIGHT, display.width+tmpSize.width, display.cy-60)
						:addTo(self.introPanel, 0, 10)

	local tmpBt = cc.ui.UIPushButton.new("#improve2_img23.png")
	:addTo(tmpNode)
	:pos(-5, tmpSize.height - 290)
	:onButtonClicked(function(event)
		transition.execute(tmpNode, 
			cc.MoveTo:create(0.2, cc.p(display.width+tmpSize.width, display.cy-60)), 
			{
		    onComplete = function()
		        self.introPanel:setVisible(false)
		    end,
		})
		end)


	local bar = display.newSprite("#improve2_img20.png")
    :addTo(tmpNode)
    :pos(90, tmpSize.height)
    cc.ui.UILabel.new({UILabelType = 2, text = "战车介绍", size = 23, color = cc.c3b(23, 43, 106)})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2)

   	self.introWidget = {}
   	--简介
   	-- self.introWidget.labDes = display.newTTFLabel({
				-- 				text="",
				-- 				size=24,
				-- 				color=cc.c3b(55, 234, 255),
				-- 				align = cc.TEXT_ALIGNMENT_LEFT,
				--                 valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
				--                 dimensions = cc.size(tmpSize.width-70, 0)
				-- 			})
				-- 			:align(display.TOP_CENTER, tmpCx, tmpSize.height-20)
				-- 			:addTo(tmpNode)
	self.introLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(18, 12, tmpSize.width-25, tmpSize.height-40),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(tmpNode)
end
function ImproveLayer:ShowIntroPanel()
	if nil==self.introPanel then
		self:CreateIntroPanel()
	end
	self.introPanel:setVisible(true)
	transition.execute(self.introPanel:getChildByTag(10), 
			cc.MoveTo:create(0.2, cc.p(display.width, display.cy-60)))

	local tmpId = curCarData.TemId
	local loc_Car = carData[tmpId]
	-- self.introWidget.labDes:setString("    " .. loc_Car.carDes)
	self:roloadIntroLv(tmpId)
end
function ImproveLayer:roloadIntroLv(carTmpId)
	self.introLv:removeAllItems()

	local item = self.introLv:newItem()
    local content = display.newNode()
	item:addContent(content)
    item:setItemSize(514, 110)
    self.introLv:addItem(item)

    local tmpId = tonumber(string.sub(carTmpId, 1,3))*10
    local locData = carData[tmpId]
    local des = cc.ui.UILabel.new({UILabelType = 2, text = locData.carDes, size = 23, color = cc.c3b(55, 234, 255)})
        :addTo(content)
        :align(display.CENTER_TOP, 0,50)
        des:setWidth(490)

    -- print("===========")
	for i=1,5 do
		local item = self.introLv:newItem()
        local content = display.newNode()
		item:addContent(content)
        item:setItemSize(514, 300)
        self.introLv:addItem(item)

        local tmpId = tonumber(string.sub(carTmpId, 1,3))*10 + i - 1

        -- print("战车模板ID")
        -- print(tmpId)
        local locData = carData[tmpId]
        if locData==nil then
        	showTips("坦克数据未配置")
        	return
        end

        

        local tankBg = display.newSprite("common2/com_tankBg.png")
        :addTo(content)
        local tmpsize= tankBg:getContentSize()

        local label = cc.ui.UILabel.new({UILabelType = 2, text = "改装"..(i-1), size = 22, color = cc.c3b(114, 113, 113)})
        :addTo(tankBg)
        :pos(52, tmpsize.height-22)
        if i==1 then
        	label:setString("原型")
        end


        cc.ui.UILabel.new({UILabelType = 2, text = locData.name, size = 22, color = cc.c3b(93, 147, 168)})
        :addTo(tankBg)
        :pos(112, tmpsize.height-22)

        if tmpId<=(carTmpId+1) then
        	--坦克
        	-- print("模型："..locData.id)
        	local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=locData.id})
                        :pos(tmpsize.width/2, tmpsize.height/2-90)
                        :addTo(tankBg)
                        carModel:setScaleY(0.7*2*0.75)
                        carModel:setScaleX(-0.7*2*0.75)
        else
        	display.newSprite("bounty/bounty2_img3.png")
        	:pos(tmpsize.width/2, tmpsize.height/2-20)
                        :addTo(tankBg)
                        :scale(0.8)
        end

        if locData.des2~="null" then
        	local bar = display.newScale9Sprite("#improve2_img18.png",nil,nil,cc.size(tmpsize.width-5, 40))
	        :addTo(tankBg)
	        :pos(tmpsize.width/2, 25)
	        cc.ui.UILabel.new({UILabelType = 2, text = locData.des2, size = 18, color = cc.c3b(55, 234, 255)})
	        :addTo(bar)
	        :align(display.CENTER, 150, bar:getContentSize().height/2)
	        :setWidth(tmpsize.width-10)
        end
        
        
	end
	self.introLv:reload()
end

--创建技能面板
function ImproveLayer:CreateSkillPanel()
	local tmpSize = cc.size(539, 533)
	local tmpCx = tmpSize.width/2
	local tmpCy = tmpSize.height/2
	local bg
	self.skillPanel = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
						:addTo(self, 10)
	-- self.skillPanel:setTouchEnabled(true)
	-- self.skillPanel:setTouchSwallowEnabled(true)
 --    self.skillPanel:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
 --        if event.name == "began" then
 --            return true

 --        elseif event.name == "moved" then
 --        elseif event.name == "ended" then
 --            transition.execute(bg, 
	-- 			cc.MoveTo:create(0.2, cc.p(display.width+tmpSize.width, display.cy-60)), 
	-- 			{
	-- 		    onComplete = function()
	-- 		        self.skillPanel:setVisible(false)
	--     			GuideManager:_addGuide_2(11006, display.getRunningScene(),handler(self,self.caculateGuidePos))
	-- 		    end,
	-- 		})
 --        end

 --    end)

	
	
	bg = display.newSprite("#improve2_img21.png")
						:align(display.CENTER_RIGHT, display.width+tmpSize.width, display.cy-60)
						:addTo(self.skillPanel,0,10)


	self.sklCloseBtn = cc.ui.UIPushButton.new("#improve2_img22.png")
	:addTo(bg)
	:pos(-5, tmpSize.height - 110)
	:onButtonClicked(function(event)
		transition.execute(bg, 
			cc.MoveTo:create(0.2, cc.p(display.width+tmpSize.width, display.cy-60)), 
			{
		    onComplete = function()
		        self.skillPanel:setVisible(false)
    			GuideManager:_addGuide_2(11006, display.getRunningScene(),handler(self,self.caculateGuidePos))
		    end,
		})
		end)

	-- self.sklCloseBtn = cc.ui.UIPushButton.new({normal="common/common_CloseBtn_1.png", pressed="common/common_CloseBtn_2.png"})
 --    	:align(display.CENTER, tmpSize.width-10, tmpSize.height-10)
 --    	:addTo(bg, 1)
 --    	:onButtonClicked(function(event)
 --    		self.skillPanel:setVisible(false)
 --    		GuideManager:_addGuide_2(11006, display.getRunningScene(),handler(self,self.caculateGuidePos))
 --    	end)

   	local bar = display.newScale9Sprite("#improve2_img20.png",nil,nil,cc.size(380, 28))
    :addTo(bg)
    :pos(200, tmpSize.height)

	display.newTTFLabel({
							text="装备星数达到要求才可以激活技能",
							size=24,
							color=cc.c3b(23, 42, 106),
							align = cc.TEXT_ALIGNMENT_CENTER,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.CENTER, bar:getContentSize().width/2-5, bar:getContentSize().height/2-1)
						:addTo(bar)

	self.skillList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(13, 12, tmpSize.width-25, tmpSize.height-40),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(bg)
        self.skillList:setBounceable(false)
end

--显示技能面板
function ImproveLayer:ShowSkillPanel()
	if nil==self.skillPanel then
		self:CreateSkillPanel()
	end
	self.skillPanel:setVisible(true)
    GuideManager:_addGuide_2(11003, display.getRunningScene(),handler(self,self.caculateGuidePos),10000)

    transition.execute(self.skillPanel:getChildByTag(10), 
			cc.MoveTo:create(0.2, cc.p(display.width, display.cy-60)), 
			{
		    onComplete = function()
		    end,
		})
	--技能ID
	local tabSkill = curCarData.skl
	local function SkillOnClicked(event)
		local nTag = event.target:getTag()
		print("SkillOnClicked - " .. nTag)
		if -1==tabSkill[nTag].sts then 			--未激活
			if nTag==4 and srv_userInfo.level<40 then
				showTips("40级开启该技能激活")
				return
			elseif self.nTotalStar>=CarSkillActStar[nTag] then
				if (nTag-1)>0 then
					for i=1,(nTag-1) do
						if tabSkill[i].sts==-1 then
							showTips("请按顺序激活技能")
							return
						end
					end
				end
				local msg = string.format("是否花费%d金币激活该技能？", CarSkillActCost[nTag])
				self.msgBox = showMessageBox(msg, function()
					GuideManager:hideGuideEff()
					CarManager:ReqActSkill(ImproveLayer.nCurSelCarID, tabSkill[nTag].id)
					startLoading()
				end)
				GuideManager:_addGuide_2(11004, display.getRunningScene(),handler(self,self.caculateGuidePos),3000)
			else
				print("星级不够")
			end
		elseif 0==tabSkill[nTag].sts then 		--激活、关闭
			--todo
		else 									--激活、开启
			--todo
		end
	end

	--item创建
	local listView = self.skillList
	listView:removeAllItems()   --清空

	self.skillWidget = {}
	local bgSize = cc.size(520, 120)
	for i=1, #tabSkill do
		local item = listView:newItem()
        local content = display.newNode()
        local skillId = tabSkill[i].id
        local loc_Skl = skillData[skillId]

        -- local bg = display.newScale9Sprite("common/common_Frame12.png", 0, 0, bgSize)
        -- 			:addTo(content)

        display.newSprite("#improve2_img26.png")
        	:align(display.CENTER, -200, 0)
        	:addTo(content)

        --技能图标
        local icon = display.newSprite("SkillIcon/skillicon" .. loc_Skl.resId2 .. ".png")
        	:align(display.CENTER, -200, 0)
        	:addTo(content)

        if loc_Skl.type1<=3 then
        	--技能角标
	        display.newSprite("SkillIcon/skill_corner"..loc_Skl.type1..".png")
	        :addTo(content)
	        :pos(-200+icon:getContentSize().width/2-10, icon:getContentSize().height/2-12)
        end

        self.skillWidget[i] = {}
        self.skillWidget[i].skillId = skillId
        --技能名
        self.skillWidget[i].labName = display.newTTFLabel({
									text=loc_Skl.sklName,
									size=24,
									color=cc.c3b(255, 219, 0),
									align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
								})
								:align(display.LEFT_CENTER, -140, 35)
								:addTo(content)
		--技能描述
		self.skillWidget[i].labDes = display.newTTFLabel({
									text=loc_Skl.sklDes,
									size=20,
									color=cc.c3b(55, 234, 255),
									align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            dimensions = cc.size(280, 100)
								})
								:align(display.LEFT_TOP, -140, 25)
								:addTo(content)

		--激活星级背景
		self.skillWidget[i].starBg = display.newSprite("#improve2_img25.png")
											:align(display.CENTER, 190, 0)
											:addTo(content)

		--激活星级
		-- self.skillWidget[i].labStar = display.newTTFLabel({
		-- 		text=CarSkillActStar[i].."星",
		-- 		size=24,
		-- 		color=cc.c3b(252, 99, 36),
		-- 		align = cc.TEXT_ALIGNMENT_CENTER,
	 --            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		-- 	})
		-- 	:align(display.CENTER, 190, 0)
		-- 	:addTo(content)

		--激活按钮
		self.skillWidget[i].btnAct = cc.ui.UIPushButton.new({
			normal="common/common_GBt1.png", 
			pressed="common/common_GBt2.png"
			},{scale9=true, grayState_=true})
			:align(display.CENTER, 190, 0)
			:addTo(content)
			:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "激活", size = 23, color = cc.c3b(204, 219, 226)}))
			:onButtonClicked(SkillOnClicked)
		self.skillWidget[i].btnAct:setTouchSwallowEnabled(false)
		self.skillWidget[i].btnAct:setTag(i)
		self.skillWidget[i].btnAct:setButtonSize(90, 70)

		self:RefreshSkillState(i)

        item:addContent(content)
        item:setItemSize(bgSize.width, bgSize.height)
        listView:addItem(item)
	end
	listView:reload()
end

--@nIndex:nil刷新个人全部技能
function ImproveLayer:RefreshSkillState(nIndex)
	if nil==self.skillWidget then
		return
	end

	local tabSkill = curCarData.skl
	-- printTable(tabSkill)
	if nil==nIndex then
		for nIndex=1, #curCarData.skl do
			if self.nTotalStar<CarSkillActStar[nIndex] then  --未激活
				self.skillWidget[nIndex].starBg:setVisible(true)
				self.skillWidget[nIndex].btnAct:setVisible(true)
				self.skillWidget[nIndex].btnAct:setButtonEnabled(false)
				self.skillWidget[nIndex].btnAct:getButtonLabel():setString(CarSkillActStar[nIndex].."星")
			elseif -1==tabSkill[nIndex].sts then   			--可激活
				self.skillWidget[nIndex].starBg:setVisible(false)
				self.skillWidget[nIndex].btnAct:setVisible(true)
				self.skillWidget[nIndex].btnAct:setButtonEnabled(true)
				self.skillWidget[nIndex].btnAct:getButtonLabel():setString("激活")
			else 										--已激活
				self.skillWidget[nIndex].starBg:setVisible(true)
				self.skillWidget[nIndex].btnAct:setVisible(false)
			end
		end
	else
		if self.nTotalStar<CarSkillActStar[nIndex] then  --未激活
			self.skillWidget[nIndex].starBg:setVisible(false)
			self.skillWidget[nIndex].btnAct:setVisible(true)
			self.skillWidget[nIndex].btnAct:setButtonEnabled(false)
			self.skillWidget[nIndex].btnAct:getButtonLabel():setString(CarSkillActStar[nIndex].."星")
		elseif -1==tabSkill[nIndex].sts then   			--可激活
			self.skillWidget[nIndex].starBg:setVisible(false)
			self.skillWidget[nIndex].btnAct:setVisible(true)
			self.skillWidget[nIndex].btnAct:setButtonEnabled(true)
			self.skillWidget[nIndex].btnAct:getButtonLabel():setString("激活")
		else 										--已激活
			self.skillWidget[nIndex].starBg:setVisible(true)
			self.skillWidget[nIndex].btnAct:setVisible(false)
		end
	end
end

function ImproveLayer:OnActSkillRet(cmd)
	if 1==cmd.result then
		local srv_Car = CarManager.carIDKeyList[cmd.data.carId]
		for i=1, #srv_Car.skl do
			if srv_Car.skl[i].id==cmd.data.sklId then
				self:RefreshSkillState(i)
				self:RefreshUI()
				mainscenetopbar:setGlod()
				
				GuideManager:_addGuide_2(11005, display.getRunningScene(),handler(self,self.caculateGuidePos))
				break
			end
		end
		--技能红点更新
		self:bHaveSklRedPoint()

	else
		showTips(cmd.msg)
	end
end

--判断是否有可激活的技能，添加小红点
function ImproveLayer:bHaveSklRedPoint()
	local redPtFlag = false
	for i,value in ipairs(curCarData.skl) do
		if value.sts<1 and self.nTotalStar>=CarSkillActStar[i] then
			redPtFlag = true
			break
		end
	end
	--添加还是删除小红点
	if redPtFlag then
		if self.SklRedPoint==nil then
			self.SklRedPoint = display.newSprite("common/common_RedPoint.png")
			:addTo(self.sklBtImg)
			:pos(70,70)
		end
	else
		if self.SklRedPoint then
			self.SklRedPoint:removeSelf()
			self.SklRedPoint=nil
		end
	end
end

function ImproveLayer:setGoldDiamond()
	print("jaingzhu2")
	--金币
	local goldStr = srv_userInfo["gold"]..""
	local length = #goldStr
	for i=1,math.floor((length-1)/3) do
		local Lstr = string.sub(goldStr, 1, length-i*3)
		local Rstr = string.sub(goldStr, length-i*3+1)
		goldStr = Lstr..","..Rstr
	end

	self.goldNum:setString(goldStr)
	setLabelStrokeString(self.goldNum, self.goldNumret)

	--钻石
	local diamondStr = srv_userInfo["diamond"]..""
	local length = #diamondStr
	for i=1,math.floor((length-1)/3) do
		local Lstr = string.sub(diamondStr, 1, length-i*3)
		local Rstr = string.sub(diamondStr, length-i*3+1)
		diamondStr = Lstr..","..Rstr
	end

	self.diamondNum:setString(diamondStr)
	setLabelStrokeString(self.diamondNum, self.diamondNumret)
end

function ImproveLayer:onEnter()
	
	ImproveLayer.Instance = self
	MainScene_Instance:setTopBarVisible(false)

	if CarManager.isReqFlag then
		startLoading()
		CarManager:ReqCarProperty(srv_userInfo["characterId"])
	else
		local cmd = {}
		cmd.result=1
		cmd.data = CarManager.srv_CarProp
		self:OnCarPropertyRet(cmd)
	end
	setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
end


function ImproveLayer:onExit()
	MainScene_Instance:setTopBarVisible(true)
	ImproveLayer.Instance = nil
	ImproveLayer_Instance = nil
	--资源释放
	ccs.ActionManagerEx:destroyInstance()
	GUIReader:destroyInstance()
	-- display.removeSpriteFramesWithFile("Image/gaizaozhongxin0.plist", "Image/gaizaozhongxin0.png")
	-- display.removeSpriteFramesWithFile("Image/gaizaozhongxin1.plist", "Image/gaizaozhongxin1.png")
	-- display.removeSpriteFramesWithFile("Image/UIImprove.plist", "Image/UIImprove.png")
	-- display.removeSpriteFramesWithFile("Effect/Improve_Eff1.plist", "Effect/Improve_Eff1.png")
end

function ImproveLayer:createBtLabel(bt,txt, color)
	-- bt:setScaleX(3)
	local lab = cc.ui.UILabel.new({UILabelType = 2, text = txt, size = 22, color=cc.c3b(255, 255, 255)})
	:addTo(bt)
	:align(display.CENTER, -9, 0)
	lab:setWidth(12)
	-- lab:setScaleX(1/3)
end

function ImproveLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11002==_guideId or 11003==_guideId or 11004==_guideId or 11005==_guideId or 11006==_guideId 
    or 10802==_guideId or 10803==_guideId or 10902==_guideId or 12502==_guideId 
    or 12503==_guideId or 12504==_guideId or 10702==_guideId then
    	if 10702==_guideId then
    		g_node = self.equipments[1]
    	elseif 11006==_guideId or 12504==_guideId then
    		g_node = self.backBtn
    	elseif 11002==_guideId then
    		g_node = self.sklBt
    	elseif 11003==_guideId then
    		g_node = self.skillWidget[2].btnAct
    	elseif 11004==_guideId then
    		g_node = self.msgBox.msgOKBt
    	elseif 11005==_guideId then
    		g_node = self.sklBt
    	elseif 10802==_guideId or 10902==_guideId then
    		g_node = self.equipments[5]
    	elseif 10803==_guideId then
    		g_node = self.holeDlg.msgOKBt
    	elseif 12502==_guideId then
     		g_node = self.btnAwake
     	elseif 12503==_guideId then
    		g_node = self.guideBtn2
    	end
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 11006==_guideId or 12504==_guideId then
    		midPos = g_node:convertToWorldSpace(cc.p(size.width/2,-size.height/2))
        end
        if 11003==_guideId then
        	print("===================================================")
        	printTable(midPos)
        	printTable(size)
        	midPos = cc.p(display.width-size.width/2-30,display.height*0.653)
        end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return ImproveLayer