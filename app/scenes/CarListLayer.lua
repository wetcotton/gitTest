-- 战车列表
-- Author: Jun Jiang
-- Date: 2015-06-12 16:44:46
--
local CarListLayer = class("CarListLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
CarListLayer.Instance 	= nil
CarListLayer.params 	= nil
CarListLayer.sortList 	= nil --战车ID排序列表

function CarListLayer:ctor(params)
	
	RentMgr:Resort()
	--资源加载
	display.addSpriteFrames("Image/UICarList.plist", "Image/UICarList.png")
	self.params = params or {}

    local tmpNode, tmpSize, tmpCx, tmpCy

    --title
	local titleBg = display.newSprite("common2/com_titleBg.png")
		:align(display.CENTER_TOP, display.cx, display.height-10)
		:addTo(self)
	display.newTTFLabel{text = "战车列表",size = 40,color = cc.c3b(138,150,168)}
		:align(display.CENTER, titleBg:getContentSize().width/2, titleBg:getContentSize().height/2)
		:addTo(titleBg)
    --背景框
    tmpSize = cc.size(1100, 600)
    tmpCx = tmpSize.width/2
    tmpCy = tmpSize.height/2
    local bg = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,tmpSize,cc.rect(119, 127, 1, 1))
    			:align(display.CENTER, display.cx-50, display.cy-20)
				:addTo(self,1)
	self.bg = bg

	--关闭按钮
    cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height)
    	:addTo(self)
        :onButtonClicked(function(event)
            self:removeFromParent()
        end)

	

	--战车列表
	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(50, 22, 1000, 550),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(bg)

    --按钮
    local function TagOnPressed(event)
    	local nTag = event.target:getTag()
		self.tagWidget[nTag].text:setColor(cc.c3b(0,149,178))
    end
    local function TagOnRelease(event)
    	local nTag = event.target:getTag()
		self.tagWidget[nTag].text:setColor(cc.c3b(95,217,255))
    end
    local function TagOnClicked(event)
    	local nTag = event.target:getTag()
    	self:SelTag(nTag)
    	for i=1, #self.tagWidget do
    		self.tagWidget[i].btn:setLocalZOrder(0)
    	end
    	event.target:setLocalZOrder(1)
    end

    self.tagWidget = {
    	{label="己方战车",zorder = 1},
    	{label="租用战车",zorder = 0},
	}
	for i=1, #self.tagWidget do
	    self.tagWidget[i].btn = cc.ui.UIPushButton.new({normal="#carLiatBtn_01_down.png",pressed="#carLiatBtn_01_down.png",disabled="#carLiatBtn_01_up.png"})
							        :align(display.CENTER, display.cx+tmpSize.width/2-8, tmpSize.height-60-(i-1)*100)
							        :addTo(self, self.tagWidget[i].zorder)
							        :onButtonPressed(TagOnPressed)
							        :onButtonRelease(TagOnRelease)
							        :onButtonClicked(TagOnClicked)
		self.tagWidget[i].btn:setTag(i)
		self.tagWidget[i].text = display.newTTFLabel{text = self.tagWidget[i].label,size = 28}
									:align(display.CENTER, 15, 0)
									:addTo(self.tagWidget[i].btn)
								
	end

    --无车提示
    self.labTips = display.newTTFLabel({
						text="当前无可选战车",
						size=40,
						color=cc.c3b(186, 217, 212),
						align = cc.TEXT_ALIGNMENT_CENTER,
			            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
					})
					:align(display.CENTER, tmpCx, tmpCy)
					:addTo(bg)
	self.labTips:setVisible(false)

	self:AdjustUI()

end



function CarListLayer:SelTag(nTag)
	if nTag==2 then
		

	end

	local frame
	for i=1, #self.tagWidget do
		if nTag==i then
			self.tagWidget[i].btn:setButtonEnabled(false)
			self.tagWidget[i].text:setColor(cc.c3b(0,149,178))
		else
			self.tagWidget[i].btn:setButtonEnabled(true)
			self.tagWidget[i].text:setColor(cc.c3b(95,217,255))
		end
	end
	self.bIsRent = nTag==2
	
	self:InitSortList()
	self:ReloadCarList(nTag)
end

function CarListLayer:AdjustUI()
	local function hideTab()
		self.bg:setPositionX(display.cx)
		for i=1, #self.tagWidget do
			self.tagWidget[i].btn:setVisible(false)
		end
	end
	if self.params.openTag==OpenBy_Embattle then
		hideTab()
			if EmbattleMgr.nCurBattleType == BattleType_PVP then
				self:SelTag(1)
			else
				self:SelTag(2)
			end
	else
		hideTab()
	end
end

--初始化排序列表
function CarListLayer:InitSortList()
	RentMgr:Resort()
	self.sortList = {}
	self.srotListRent = {}
	if self.params.openTag==OpenBy_Embattle then
		for i=1, #self.params.idList do
			table.insert(self.srotListRent, self.params.idList[i])
		end
		if EmbattleMgr.nCurBattleType == BattleType_PVP then
			for k, _ in pairs(CarManager.carIDKeyList) do
				if self.params.ignoreCar~=k and _.carMember.tptId==nil then
					table.insert(self.sortList, k)
				end
			end
		end
	else
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

end

--刷新战车列表
function CarListLayer:ReloadCarList(_nTag)
	startLoading()
	self:performWithDelay(function ()
                       
         print("start----------------")
		local listView = self.listView
	    listView:removeAllItems()   --清空

	    _nTag = _nTag or 1
	    self.curList = {}
	    if _nTag==2 and self.params.openTag==OpenBy_Embattle then
	    	self.curList = self.srotListRent 
	    else
	    	self.curList = self.sortList 
	    end
	  
	    local function CarOnClicked(_idx)
	    	-- local nTag = event.target:getTag()
	    	local nCarId = self.curList[_idx]
	    	print(nCarId .."  is  touched       ,--------------------nTag :".._idx)
	    	if self.params.openTag==OpenBy_Drive then
		    	local opMem = self.params.opMem
		    	CarManager:ReqUpdateCarMember(nCarId, opMem)
		    	startLoading()
		    elseif self.params.openTag==OpenBy_worldBoss then
		    	if worldBossInstance~=nil then
		    		worldBossInstance:ReqUpdateCar(nCarId)
		    	end
		    elseif self.params.openTag==OpenBy_Improve then
		    	if nil~=g_ImproveLayer.Instance then
		    		g_ImproveLayer.Instance:SelCar(nCarId)
		    		self:removeFromParent()
		    	end

		    elseif self.params.openTag==OpenBy_Embattle then
	        	local nBattlePos = EmbattleMgr:CheckOnBattle(EmbattleGroup_Main, -nCarId)
	        	print("nBattlePos:",nBattlePos)
				if 0==nBattlePos then--0表示未上阵，即试图再上阵一辆新车
					if _nTag==2 then
						if EmbattleScene.Instance._rentInfo~=nil then
			        		showTips("只能租借一辆战车")
			        		return
			        	end
		        	end
				end

				local srv_Car
				local id_id
				if _nTag==2 and self.params.openTag==OpenBy_Embattle then
	    			srv_Car = RentMgr.rentInfo[nCarId]
	    			print("nCarId:"..nCarId.."   srv_Car.level: "..srv_Car.level.."    srv_userInfo.level:"..srv_userInfo.level)
	    			if srv_Car.level>srv_userInfo.level then
						showTips("等级不足",cc.c3b(252, 0, 0))
			        	return
					end

					if srv_Car.record~=nil and srv_Car.record>=3 then
						showTips("这辆车今日已经租借超过三次")
			        	return
					end
					id_id = srv_Car.tptId
				elseif _nTag==1 then
					srv_Car = CarManager.carIDKeyList[nCarId]
					id_id = srv_Car.TemId
	    	    end

				if 0==nBattlePos then
		    	    local id_id2
		    	    local ii
		    	    for ii=1,5 do
			    	    local key = "main"..ii
			    	    local srv_id = EmbattleMgr.curInfo.matrix[key]
				    	    if srv_id~=0 and srv_id~=-1 then
				    	    print(key.."   srv_id:"..srv_id)
				    	    local g_carInfo
				    	    if EmbattleScene.Instance.rentInfo~=nil and EmbattleScene.Instance.rentInfo._pos==ii then
				    	    	g_carInfo = RentMgr.rentInfo[srv_id]
				    	    	id_id2 = g_carInfo.tptId
				    	    else
				    	    	g_carInfo = EmbattleMgr.curInfo.members[srv_id]
				    	    	if g_carInfo~= nil then
					    	    	id_id2 = g_carInfo.TemId
					    	    end
				    	    end
				    	    if g_carInfo~=nil then
					    	    print("id_id"..id_id)
					    	    print("id_id2"..id_id2)
					    	    if id_id2==id_id then
					    	    	showTips("不能上阵统一型号车")
					    	    	return
					    	    end
					    	end
				    	end
			    	end
		    	end
		    	if EmbattleScene.Instance._rentInfo==nil then
		    		if EmbattleMgr:isMatrixIsFull() then
		                showTips("阵位已满，不能租车")
		                return
		            end
		    	end
	            local nType, nPos = EmbattleMgr:AutoOnOffBattle(EmbattleGroup_Main, -nCarId)

	            if 0~=nPos then
	                if EmbattleType_OnBattle==nType then
	                	GuideManager:_addGuide_2(11209, cc.Director:getInstance():getRunningScene(),handler(EmbattleScene.Instance,EmbattleScene.Instance.caculateGuidePos))
	                	print("去上阵,self.bIsRent:",self.bIsRent)
	                	print(nType.."    "..nPos.."    ".._idx)
	                    EmbattleScene.Instance:OnOffBattle(nType, EmbattleGroup_Main, _idx, nPos, self.bIsRent)
	                    EmbattleScene.Instance:SetStrength(math.floor(EmbattleMgr:GetStrength()))
	                elseif EmbattleType_OffBattle==nType then
	                    EmbattleScene.Instance:OnOffBattle(nType, EmbattleGroup_Main, nPos, _idx, self.bIsRent)
	                    EmbattleScene.Instance:SetStrength(math.floor(EmbattleMgr:GetStrength()))
	                end
	                self:removeFromParent()
	            else
	            	showTips("无有效牵引上阵位")
	            end

		    end
	    end

	    -- printTable(self.sortList)
	    local tmpSize, idx, tmpStr
	    
	    local nNum = #self.curList
	    local nItemNum = math.ceil(nNum/3)
	    local srv_Car, loc_Car, loc_Mem
	    for i=1, nItemNum do
	    	local item = listView:newItem()
	        local content = display.newNode()
            local tmpNode = nil
	        for count=1, 3 do
	            idx = (i-1)*3 + count
	            if idx<=nNum then
	            	if self.params.openTag==OpenBy_Embattle then
	            		if _nTag==1 then
	            			srv_Car = CarManager.carIDKeyList[self.curList[idx]]
	            			loc_Car = carData[srv_Car.TemId]
	            		elseif _nTag==2 then
		            		srv_Car = RentMgr.rentInfo[self.curList[idx]]
		            		loc_Car = carData[srv_Car.tptId]
	            	    end
	            	else
	            		srv_Car = CarManager.carIDKeyList[self.curList[idx]]
	            		loc_Car = carData[srv_Car.TemId]
	            	end
	            	--按钮
	            	local tIdx = idx
		            tmpNode = cc.ui.UIPushButton.new("common2/com_tankBg.png")
				                :align(display.CENTER, -350+(count-1)*350, 0)
				                :addTo(content)
				    tmpSize = tmpNode.sprite_[1]:getContentSize()
				    local g_btn = cc.ui.UIPushButton.new()
				                :onButtonClicked(function()
				                	CarOnClicked(tIdx)
				                end)
				                :align(display.CENTER, -350+(count-1)*350, 0)
				                :addTo(content,1)
				    g_btn:setContentSize(tmpSize)
				    tmpNode:setTouchSwallowEnabled(false)
				    g_btn:setTouchSwallowEnabled(false)
				    --print("idx:  "..idx)
				    if idx==1 then
				    	print("第一个车子")
				    	self.guideBtn = g_btn
				    	GuideManager:_addGuide_2(10403, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
				    end
				    --tmpNode:setContentSize(cc.size(303,228))
				    -- tmpNode:setTag(tIdx)
				    --print(loc_Car.id.." 车ID，-------tag:"..idx)

				    if _nTag==2 and self.params.openTag==OpenBy_Embattle then  --军团车
				    	local  _tmpId = loc_Car.id
				    	if _tmpId==11 then _tmpId = 1020 end
				    	if _tmpId==12 then _tmpId = 1040 end
				    	if _tmpId==13 then _tmpId = 1070 end
				    	display.newSprite("Head/head_".._tmpId..".png")
				    				:addTo(tmpNode)
				    				:scale(1.2)
				    				:align(display.CENTER_BOTTOM,0, -tmpSize.height/2+40)
				    else
					    --战车模型
					    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=loc_Car.id})
											:pos(0, -tmpSize.height/2+40)
										    :addTo(tmpNode)
						SetModelParams(carModel, {fScale=0.5})
					end

					if _nTag==2 then
						local lvlColor = cc.c3b(81, 205, 255)
						if srv_Car.level>srv_userInfo.level then
							lvlColor = cc.c3b(252, 0, 0)
						end 
						local driverLevel = display.newTTFLabel({
														font = "fonts/slicker.ttf",
														text="LV."..srv_Car.level,
														size=25,
														color=lvlColor,
													})
													:align(display.CENTER_LEFT, -tmpSize.width*0.32, tmpSize.height/2-23)
													:addTo(tmpNode)

						local goldBg = display.newSprite("#carListImg_01.png")
									:addTo(tmpNode)
									:pos(0,-tmpSize.height/2-22)
						local function getRentCost(carInfo)
						    local index,cost = 0,0
						    if carInfo.record==nil or carInfo.record==0 then
						        return 1,math.ceil(carInfo.strength*5.2)
						    elseif carInfo.record==1 then
						        return 2,30
						    elseif carInfo.record==2 then
						        return 2,50
						    elseif carInfo.record==3 then
						        return 3,"不可租用"
						    end
						    return index,cost
						end
						local first,secend = getRentCost(srv_Car)
						 --租车价格
					    local jiage = display.newTTFLabel({
					    	font = "fonts/slicker.ttf",
								text=secend,
								size=28,
								color=cc.c3b(250, 238, 0),
							})
							:align(display.CENTER, goldBg:getContentSize().width/2+14, goldBg:getContentSize().height/2-2)
						    	:addTo(goldBg)
						local sprPath
						if first == 3 then
							jiage:setColor(cc.c3b(255,0,0))
							jiage:setPositionX(0)
						else
							if first == 2 then
								sprPath = "common/common_Diamond.png"
							elseif first==1 then
								sprPath = "common/common_GoldGet.png"
							end
							display.newSprite(sprPath)
								:scale(0.43)
						    	:align(display.CENTER_RIGHT, jiage:getPositionX()-jiage:getContentSize().width/2, goldBg:getContentSize().height/2+2)
						    	:addTo(goldBg)
						end

					    
						--战车车主名
						if srv_Car.dName==nil then
							srv_Car.dName = "军团公车"
							srv_Car.carLvl = 1
						end
					    display.newTTFLabel({
								text=srv_Car.dName,
								size=20,
								color=lvlColor,
							})
							:align(display.CENTER, 30, tmpSize.height/2-23)
							:addTo(tmpNode)
					else
						 --战车名
					    display.newTTFLabel({
								text=loc_Car.name,
								size=25,
								color=cc.c3b(152, 167, 168),
							})
							:align(display.CENTER, 2, tmpSize.height/2-23)
							:addTo(tmpNode)
					end

				--坦克等级
			      local num = 36 + math.floor((srv_Car.carLvl+1)/2)
			      local level = display.newSprite("common2/improve2_img"..num..".png")
			      :addTo(tmpNode,1)
			      :align(display.CENTER, -120, 40)
			      :scale(0.7)

			      local carLevelAdd = display.newSprite("common2/improve2_img42.png")
			      :addTo(tmpNode,1)
			      :align(display.CENTER, -100, 50)
			      :scale(0.6)
			      if math.mod(srv_Car.carLvl, 2)==0 then
			          carLevelAdd:setVisible(true)
			      else
			          carLevelAdd:setVisible(false)
			      end

					if self.params.openTag~=OpenBy_Embattle then
						if nil~=srv_Car.carMember.tptId and 0~=srv_Car.carMember.tptId then
							loc_Mem = memberData[srv_Car.carMember.tptId]
							local manHeadBg = display.newSprite("common/common_HeadFrame2.png")
								:scale(0.5)
								:align(display.CENTER, 140-30, 60-10)
								:addTo(tmpNode)
							local nResID = tonumber(string.sub(srv_Car.carMember.tptId,1,4))
							tmpStr = string.format("Head/chead_%d.png", nResID)
							display.newSprite(tmpStr)
								:scale(1.1)
						    	:align(display.CENTER, manHeadBg:getContentSize().width/2, manHeadBg:getContentSize().height/2)
						    	:addTo(manHeadBg)
						end
					end

					if self.params.openTag==OpenBy_Embattle then
						local nPos = EmbattleMgr:CheckOnBattle(EmbattleGroup_Main, -self.curList[idx])
						if 0~=nPos then --已上阵
							display.newSprite("common2/com_hook.png")
								:align(display.CENTER, tmpSize.width/2-50, -tmpSize.height/2+50)
								:addTo(tmpNode, 1)
								:scale(0.8)
						end
					end
				end
	        end

	        item:addContent(content)
	        item:setItemSize(1000, 275)
	        if _nTag==2 then
	        	item:setItemSize(1000, 320)
	        end
	        listView:addItem(item)
	    end
	    listView:reload()

	    if nNum<=0 then
	    	self.labTips:setVisible(true)
	    else
	    	self.labTips:setVisible(false)
	    end
	    endLoading()
	    print("end----------------")
    end, 0.01)
	
end

function CarListLayer:OnCarPropertyRet(cmd)
	if 1==cmd.result then
		self:InitSortList()
		self:ReloadCarList()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

function CarListLayer:onEnter()
	CarListLayer.Instance = self
	if self.params.openTag==OpenBy_Embattle then
		self:getAllTaxiRet()
	end

	if self.params.openTag==OpenBy_Drive or self.params.openTag==OpenBy_worldBoss then
		CarManager:ReqCarProperty(srv_userInfo["characterId"])
		startLoading()
    else
    	if self.params.openTag~=OpenBy_Embattle then
    		self:InitSortList()
			self:ReloadCarList()
		end
    end

end

function CarListLayer:getAllTaxiRet()
	self.params.idList = {}
	for i=1, #RentMgr.sortList do
        self.params.idList[i] = RentMgr.sortList[i]--可以租的车
    end
end

function CarListLayer:onExit()
	CarListLayer.Instance = nil

	--资源释放
	display.removeSpriteFramesWithFile("Image/UICarList.plist", "Image/UICarList.png")
end

function CarListLayer:caculateGuidePos(_guideId)
	print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10403 ==_guideId or 11208 ==_guideId then
    	if 10403==_guideId then
    		g_node = self.guideBtn
    		size = g_node:getContentSize()
    		midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    	elseif 11208==_guideId then
    		g_node = self.guideBtn
    		size = g_node:getContentSize()
    		midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    		print("指引hhhhh---------------")
    	end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return CarListLayer