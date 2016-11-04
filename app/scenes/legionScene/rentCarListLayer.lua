--
-- Author: Huang yu zhao
-- Date: 2015-07-29 11:38

local function showRentGotBox(gold,exploit,okListener,cancelListener,oneBtListener,zorder)
    if LoadLayer then
      endLoading()
    end
    
    if messageBoxLayer ~= nil then
        messageBoxLayer:removeSelf()
        messageBoxLayer = nil
    end

    messageBoxLayer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 100))
    :addTo(cc.Director:getInstance():getRunningScene(), zorder or 998)

    local messageBox = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(506,348),cc.rect(119, 127, 1, 1))
					    :addTo(messageBoxLayer,0,10)
					    :pos(display.cx, display.cy)

    display.newTTFLabel{text = "提 示",size = 30,color = cc.c3b(138,150,168)}
    			:addTo(messageBox)
    			:pos(messageBox:getContentSize().width/2, messageBox:getContentSize().height-40)

	local bg = display.newScale9Sprite("#rent_frame_3.png", nil, nil, cc.size(400,170), cc.rect(10, 10, 10, 10))
				:align(display.CENTER, 253, 180)
				:addTo(messageBox)

	display.newSprite("common/common_GoldGet.png")
			:pos(80, 65)
       		:addTo(bg)
       		:scale(0.7)

    display.newSprite("common/gongxun.png")
			:pos(270, 60)
       		:addTo(bg)
       		:scale(0.8)

    rentGotGold = display.newTTFLabel({
						text=gold,
						size=20,
					})
					:pos(150, 60)
					:addTo(bg)

	rentGotExploit = display.newTTFLabel({
						text=exploit,
						size=20,
					})
					:pos(340, 60)
					:addTo(bg)
	display.newTTFLabel({
						text="登记期间总收益",
						size=25,
					})
					:pos(bg:getContentSize().width/2, bg:getContentSize().height-40)
					:addTo(bg)


    --确定按钮（单个）
    local msgOKBt = cc.ui.UIPushButton.new({normal="common2/com2_Btn_5_up.png"})
					    :addTo(messageBox)
					    :scale(0.8)
					    :onButtonPressed(function(event)
							event.target:setScale(0.95*0.8)
							end)
						:onButtonRelease(function(event)
							event.target:setScale(1.0*0.8)
							end)
					    :pos(messageBox:getContentSize().width/2, 50)
    	                -- :scale(0.7)
    display.newTTFLabel{text = "确定",size = 30,color = cc.c3b(60,5,8)}
    			:addTo(msgOKBt)

      msgOKBt:onButtonClicked(function(event)
        if oneBtListener~=nil then
          oneBtListener()
        end
        messageBoxLayer:removeFromParent()
        messageBoxLayer = nil
      end)
    
end
--
rentCarListLayer = class("rentCarListLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)

rentCarListLayer.Instance      = nil       --实例


function rentCarListLayer:ctor(params)
	display.addSpriteFrames("Image/UICarList.plist", "Image/UICarList.png")
	rentCarListLayer.Instance = self
    local tmpNode, tmpSize, tmpCx, tmpCy

   --title
	local titleBg = display.newSprite("common2/com_titleBg.png")
		:align(display.CENTER_TOP, display.cx, display.height-10)
		:addTo(self)
	display.newTTFLabel{text = "租车大厅",size = 40,color = cc.c3b(138,150,168)}
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
    	{label="我的登记",zorder = 1},
    	{label="所有战车",zorder = 0},
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

	self.myCarBg = {}
	self.tipBg = {}
	self.myCarBg[1] = display.newSprite("common2/com_tankBg.png")
					        :addTo(self.bg)
					        :align(display.CENTER, tmpCx, tmpCy+60)
					        :scale(1.2)
	self.myCarBg[2] = display.newSprite("common2/com_tankBg.png")
					        :addTo(self.bg)
					        :align(display.CENTER, tmpCx, tmpCy+60)
					        :scale(1.2)
					        :hide()
	self.tipBg[1] = display.newScale9Sprite("common2/com2_Img_6.png", nil, nil, cc.size(666,120), cc.rect(40,40,5,5))
	        :addTo(self.bg)
	        :align(display.CENTER, tmpCx, tmpCy-175)
	        :opacity(255)
	self.tipBg[2] = display.newScale9Sprite("common2/com2_Img_6.png", nil, nil, cc.size(666,120), cc.rect(40,40,5,5))
	        :addTo(self.bg)
	        :align(display.CENTER, tmpCx, tmpCy-220)
	        :opacity(0)
	        :hide()

	self.rolePropertyBt = cc.ui.UIPushButton.new("#rent_addCar_Btn.png")
						:addTo(self.myCarBg[1])
						:scale(1/1.2)
						:pos(self.myCarBg[1]:getContentSize().width/2, self.myCarBg[1]:getContentSize().height/2)
						:onButtonPressed(function(event)
							event.target:setScale(0.95/1.2)
							end)
						:onButtonRelease(function(event)
							event.target:setScale(1.0/1.2)
							end)
						:onButtonClicked(function(event)
							self.listIndex = 1
							self:ReloadCarList()
							end)
	display.newSprite("#tag_record.png")
			:addTo(self.myCarBg[1])
			:scale(1/1.2)
			:pos(self.myCarBg[1]:getContentSize().width/2, self.myCarBg[1]:getContentSize().height/2-75)

	
	local msgLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25,color=cc.c3b(56, 191, 255), align = cc.ui.TEXT_ALIGN_LEFT, valign= cc.ui.TEXT_VALIGN_CENTER})
    :addTo(self.tipBg[1])
    :pos(self.tipBg[1]:getContentSize().width/2, self.tipBg[1]:getContentSize().height/2)
    msgLabel:setAnchorPoint(0.5,0.5)
    msgLabel:setString("等级的战车按时长获得金币收入，被军团成员租借后可获得军团币")
    msgLabel:setWidth(470)
    msgLabel:setLineHeight(30)

    			
	self.mtTankModel = ShowModel.new({modelType=ModelType.Tank, templateID=1070})
					:addTo(self.myCarBg[2])
					:pos(self.myCarBg[2]:getContentSize().width/2, self.myCarBg[2]:getContentSize().height/2-50)
	SetModelParams(self.mtTankModel, {fScale=0.7/1.2})

	self.myTankName = display.newTTFLabel{templateID = "破碎的德里克",size = 25,color=cc.c3b(119, 133, 146),}
			:addTo(self.myCarBg[2])
			:pos(self.myCarBg[2]:getContentSize().width/2, self.myCarBg[2]:getContentSize().height-23)

	local _btnRecyle = cc.ui.UIPushButton.new({normal="common2/com2_Btn_5_up.png"})
        :pos(self.myCarBg[2]:getContentSize().width/2, -26)
        :addTo(self.myCarBg[2])
        :scale(0.8)
        :onButtonPressed(function(event)
			event.target:setScale(0.96*0.8)
			end)
		:onButtonRelease(function(event)
			event.target:setScale(1.0*0.8)
			end)
        :onButtonClicked(function(event)
            self:ReqUnBookIn()
        end)

    display.newTTFLabel{text = "回收战车",size = 30,color = cc.c3b(60,5,8)}
    			:addTo(_btnRecyle)

    display.newTTFLabel({
						text="累计收入：",
						size=25,
						color=cc.c3b(119, 133, 146),
					})
					:align(display.CENTER, 100, self.tipBg[2]:getContentSize().height -30)
					:addTo(self.tipBg[2])

	display.newTTFLabel({
						text="累计时长：",
						size=25,
						color=cc.c3b(119, 133, 146),
					})
					:align(display.CENTER, 100, 30 )
					:addTo(self.tipBg[2])

    display.newSprite("common/common_GoldGet.png")
			:pos(210, self.tipBg[2]:getContentSize().height-25)
       		:addTo(self.tipBg[2])
       		:scale(0.6)

    display.newSprite("common/gongxun.png")
			:pos(420, self.tipBg[2]:getContentSize().height-30)
       		:addTo(self.tipBg[2])
       		:scale(0.8)

    self.rentGotGold = display.newTTFLabel({
						text="222222",
						size=25,
						color=cc.c3b(255, 238, 0),
						align = cc.TEXT_ALIGNMENT_LEFT,
			            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
					})
					:align(display.LEFT_CENTER,240, self.tipBg[2]:getContentSize().height-32)
					:addTo(self.tipBg[2])

	self.rentGotExploit = display.newTTFLabel({
						text="33333",
						size=25,
						color=cc.c3b(255, 238, 0),
						align = cc.TEXT_ALIGNMENT_LEFT,
			            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
					})
					:align(display.LEFT_CENTER,450, self.tipBg[2]:getContentSize().height-32)
					:addTo(self.tipBg[2])
	--累计时长
	self.rentAllTime = display.newTTFLabel({
						text="999小时999分钟",
						size=25,
						color=cc.c3b(119, 255, 36),
					})
					:align(display.LEFT_CENTER,187, 30)
					:addTo(self.tipBg[2])

	self:SelTag(1)
	self.calList = {
					  myCars = {},    --我自己所有的车
					  allCars = {}   --军团其他成员的车
	}   
    self.sortList = {
    					myCarsSort = {},  --
    					allCarsSort = {},  --
	}
	self.listIndex = 1
	self.hasRecordRent = false   --是否已经登记过车
	self.curMyTaxi = {id = -1,time = -1}          --当前要显示的车（已经登记了的）
end

function rentCarListLayer:SelTag(nTag)
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
	
	if nTag == 2 then
		self.listIndex = 2
		self:ReloadCarList()
	elseif nTag==1 then
		self.labTips:setVisible(false)
		self.listIndex = 3
		if self.hasRecordRent then
			self:showMyRent()
		else
			self:showAddRentCar()
		end
	end
end


--初始化排序列表
function rentCarListLayer:InitSortList()
	
end

--刷新战车列表
function rentCarListLayer:ReloadCarList(onlyAllCars)
	print("self.listIndex : "..self.listIndex)
	print(onlyAllCars)
	if onlyAllCars then
		if self.listIndex~=2 then
			print("返回，不执行")
			return
		end
	end
	self:performWithDelay(function ()
		local listView = self.listView
		listView:setVisible(true)
	    listView:removeAllItems()   --清空

	    self.myCarBg[1]:setVisible(false)
		self.tipBg[1]:setVisible(false)
		self.myCarBg[2]:setVisible(false)
		self.tipBg[2]:setVisible(false)

	    local curList = {}
	    local curInfo = {}
	    if self.listIndex==2 then
	    	curList = self.sortList.allCarsSort 
	    	curInfo = self.calList.allCars
	    	--print("军团车，curList:")
	    	--printTable(curList)
	    elseif self.listIndex==1 then
	    	curList = self.sortList.myCarsSort 
	    	curInfo = self.calList.myCars
	    	--print("自己车，curList:")
	    	--printTable(curList)
	    else 
	    	return
	    end

	    local function CarOnClicked(event)
	    	local nTag = event.target:getTag()
	    	if self.listIndex==1 then
	    		local nCarId = self.sortList.myCarsSort[nTag]
	    		local myCar = self.calList.myCars[nCarId]
	    		local loc_Car = carData[myCar.tptId]
	    		showMessageBox("是否登记“"..loc_Car.name.."”为军团租车？",function ()
	    			self.curMyTaxi.id = nCarId
	    			print("self.curMyTaxi.id = nCarId"..nCarId)
	    			self:ReqBookIn(nCarId)
	    		end)
	    	end
	    end

	    local tmpNode, tmpSize, idx, tmpStr

	 --    curList = {curList[1]}
	 --    for j=1,2 do
		--     local _num = #curList
		--     for i=1,_num do
		--     	curList[#curList+1] = curList[i]
		--     end
		-- end
	    
	    local nNum = #curList
	    local nItemNum = math.ceil(nNum/3)
	    local srv_Car, loc_Car, loc_Mem
	    for i=1, nItemNum do
	    	local item = listView:newItem()
	        local content = display.newNode()

	        for count=1, 3 do
	            idx = (i-1)*3 + count
	            if idx<=nNum then
	            	local curTime = socket.gettime()
	        		srv_Car = curInfo[curList[idx]]
	        		loc_Car = carData[srv_Car.tptId]

	            	--按钮
		            tmpNode = cc.ui.UIPushButton.new("common2/com_tankBg.png")
				                :onButtonClicked(CarOnClicked)
				                :align(display.CENTER, -350+(count-1)*350, 0)
				                :addTo(content)
				    tmpSize = tmpNode.sprite_[1]:getContentSize()
				    tmpNode:setTouchSwallowEnabled(false)
				    tmpNode:setTag(idx)
				    
				    if self.listIndex==2 then  --军团车
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
					

					if self.listIndex==2 then
						local lvlColor = cc.c3b(81, 205, 255)
						-- if srv_Car.level>srv_userInfo.level then
						-- 	lvlColor = cc.c3b(252, 0, 0)
						-- end 
						local driverLevel = display.newTTFLabel({
														font = "fonts/slicker.ttf",
														text="LV."..srv_Car.level,
														size=25,
														color=lvlColor,
													})
													:align(display.CENTER_LEFT, -tmpSize.width*0.32, tmpSize.height/2-23)
													:addTo(tmpNode)
						
						local numLbl = display.newBMFontLabel({text = srv_Car.strength, font = "fonts/num_4.fnt"})
							    :align(display.RIGHT_TOP, tmpSize.width/2-30,60)
							    :addTo(tmpNode,0,101) 
							    :scale(1.5)
						display.newSprite("common2/com_strengthTag.png")
									:addTo(tmpNode,0,102)
									:align(display.RIGHT_TOP, numLbl:getPositionX()-numLbl:getContentSize().width*1.5 ,58)
									:scale(1.2)
						
						--战车车主名
						if srv_Car.dName~=nil then
						    display.newTTFLabel({
								text=srv_Car.dName,
								size=20,
								color=lvlColor,
							})
							:align(display.CENTER, 30, tmpSize.height/2-23)
							:addTo(tmpNode)
						end
					else
						 --战车名
					    display.newTTFLabel({
								text=loc_Car.name,
								size=20,
								color=cc.c3b(186, 217, 212),
								align = cc.TEXT_ALIGNMENT_CENTER,
				                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
							})
							:align(display.CENTER, 2, tmpSize.height/2-23)
							:addTo(tmpNode)

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
					print("加载间隔 "..idx.."  "..socket.gettime()-curTime)
				end
	        end

	        item:addContent(content)
	        item:setItemSize(1000, 275)
	        listView:addItem(item)
	    end
	    listView:reload()

	    if nNum<=0 then
	    	self.labTips:setVisible(true)
	    else
	    	self.labTips:setVisible(false)
	    end

    end, 0.01)
end

function rentCarListLayer:OnCarPropertyRet(cmd)
	
end

function rentCarListLayer:onEnter()
	self:getAllTaxiRet()
	self:ReqMyCars()
end

function rentCarListLayer:onExit()
	rentCarListLayer.Instance = nil
	display.removeSpriteFramesWithFile("Image/UICarList.plist", "Image/UICarList.png")
end

--显示添加等级车辆的面板
function rentCarListLayer:showAddRentCar()
	self.listView:setVisible(false)
	self.myCarBg[1]:setVisible(true)
	self.tipBg[1]:setVisible(true)
	self.myCarBg[2]:setVisible(false)
	self.tipBg[2]:setVisible(false)
end

--显示我已经登记的车辆
function rentCarListLayer:showMyRent()
	self.listView:setVisible(false)
	self.myCarBg[1]:setVisible(false)
	self.tipBg[1]:setVisible(false)
	self.myCarBg[2]:setVisible(true)
	self.tipBg[2]:setVisible(true)

	local car = self.calList.myCars[self.curMyTaxi.id]
	
	self.mtTankModel:removeFromParent()
	self.mtTankModel = ShowModel.new({modelType=ModelType.Tank, templateID=car.tptId})
					:addTo(self.myCarBg[2])
					:pos(self.myCarBg[2]:getContentSize().width/2, 40)
	SetModelParams(self.mtTankModel, {fScale=0.7/1.2})

	self.myTankName:setString(carData[car.tptId].name)

	print("srv_local_dts:"..srv_local_dts)
	local miao = os.time() - self.curMyTaxi.time -math.floor(srv_local_dts/1000 )
	print("os.time():"..os.time().."      self.curMyTaxi.time: "..self.curMyTaxi.time.."    srv_local_dts/1000:"..srv_local_dts/1000)
	print("miao:"..miao)

	if miao<0 then --由于网速原因，miao有可能为负数
		miao = 0
	end

	local h = math.floor(miao/3600)
	local m = math.floor((miao - h*3600)/60)

	self.rentAllTime:setString(h.."小时"..m.."分钟")

	-- local goldNum = (math.ceil(car.strength/120)+30)*(h*60+m)
    print("aaaaaaaa") 
    print(self.regGold)
    local goldNum = self.regGold
	local exploitNum = car.rentedCnt*20
	if exploitNum>100 then
		exploitNum = 100
	end

	self.rentGotGold:setString(""..goldNum)
	self.rentGotExploit:setString(""..exploitNum)

end

--请求我所有的车
function rentCarListLayer:ReqMyCars()
	local tabMsg = {characterId=srv_userInfo.characterId}
	local cmdKey = CMD_LEGION_ALLTAXI
	m_socket:SendRequest(json.encode(tabMsg), cmdKey, self, self.OnMyCarsRet)
end

function rentCarListLayer:OnMyCarsRet(cmd)
	if 1==cmd.result then
        self.regGold = 0
		for k,v in pairs(cmd.data.cars) do
			self.calList.myCars[v.id] = v
			if v.rent~=0 then
				self.hasRecordRent = true
				self.curMyTaxi.id = v.id
				self.curMyTaxi.time = v.regTs

                --租车金币
                self.regGold = v.regGold
			end
			table.insert(self.sortList.myCarsSort,v.id)
		end
		local function SortFunc(val1, val2)
			local data1 = self.calList.myCars[val1]
			local data2 = self.calList.myCars[val2]

			if data1.strength==data2.strength then
				return val1<val2
			else
				return data1.strength>data2.strength
			end
		end

	if self.hasRecordRent then          --显示我已经等级了的战车
		self:showMyRent()
	else                                --显示加号

	end
	table.sort(self.sortList.myCarsSort, SortFunc)

	print("-------------------66666666666666999999999999")
	printTable(self.calList.myCars)
	print("-------------------66666666666666999999999999")
	printTable(self.sortList.myCarsSort)
	print("-------------------66666666666666999999999999")

	else
		print(cmd.msg)
		showTips(cmd.msg)
	end
end

--登记我的车
function rentCarListLayer:ReqBookIn(srv_carID)
	print("请求登记:"..srv_carID)
	local tabMsg = {characterId=srv_userInfo.characterId,carId = srv_carID}
	local cmdKey = CMD_LEGION_BOOKIN
	m_socket:SendRequest(json.encode(tabMsg), cmdKey, self, self.OnBookInRet)
end

function rentCarListLayer:OnBookInRet(cmd)
	if 1==cmd.result then
		print("登记返回 time:"..cmd.data.ts)
		self.hasRecordRent = true
		self.curMyTaxi.time = cmd.data.ts
        
		self:showMyRent()
	else
		print(cmd.msg)
		showTips(cmd.msg)
	end
end
--取消登记
function rentCarListLayer:ReqUnBookIn()

	local car = self.calList.myCars[self.curMyTaxi.id]
	local miao = os.time() - self.curMyTaxi.time -srv_local_dts/1000
	local h = math.floor(miao/3600)
	local m = math.floor((miao - h*3600)/60)
	-- local goldNum = (math.ceil(car.strength/120)+30)*(h*60+m)
    local goldNum = self.regGold
	local exploitNum = car.rentedCnt*20
	if exploitNum>100 then
		exploitNum = 100
	end

	print("function rentCarListLayer:ReqUnBookIn()")
	showRentGotBox(goldNum,exploitNum,nil,nil,function ()
		print("发送取消登记")
		local tabMsg = {characterId=srv_userInfo.characterId,carId = self.curMyTaxi.id, gold = goldNum, ept = exploitNum}
		local cmdKey = CMD_LEGION_UNBOOKIN
		self.goldNum = goldNum
		self.exploitNum = exploitNum
		m_socket:SendRequest(json.encode(tabMsg), cmdKey, self, self.OnUnBookInRet)
	end)
end

function rentCarListLayer:OnUnBookInRet(cmd)
	if 1==cmd.result then
		self:showAddRentCar()
		self.hasRecordRent = false
		-- srv_userInfo.gold = self.goldNum + srv_userInfo.gold
        srv_userInfo.gold = cmd.data.gold
		srv_userInfo.exploit = self.exploitNum + srv_userInfo.exploit
		mainscenetopbar:setGlod()
		self.goldNum = nil
		self.exploitNum = nil

        --回收置为0
        self.regGold = 0
	else
		showTips(cmd.msg)
	end
end

function rentCarListLayer:getAllTaxiRet()
	self.calList.allCars = {}
	self.sortList.allCarsSort = {}
	for k,v in pairs(RentMgr.rentInfo) do
		--if v.driver~=nil then
			self.calList.allCars[v.id] = v
			table.insert(self.sortList.allCarsSort,v.id)
		--end
	end

	local function SortFunc(val1, val2)
		local data1 = self.calList.allCars[val1]
		local data2 = self.calList.allCars[val2]

		if data1.strength==data2.strength then
			return val1<val2
		else
			return data1.strength>data2.strength
		end
    end
	table.sort(self.sortList.allCarsSort, SortFunc)
--print("----------------00000000000000")
--printTable(self.calList.allCars)
--print("----------------00000000000000")
end

function rentCarListLayer:myTaxiIsRented(cmd)
	if 1==cmd.result then
		if self.calList.myCars[cmd.data.carId]~=nil then
			self.calList.myCars[cmd.data.carId].rentedCnt = cmd.data.rentedCnt
			print("收到最新租车次数，cmd.data.carId："..cmd.data.carId.."   cmd.data.rentedCnt: "..cmd.data.rentedCnt)
		else
			print("错了，cmd.data.carId："..cmd.data.carId.."   cmd.data.rentedCnt: "..cmd.data.rentedCnt)
		end
	else
		showTips(cmd.msg)
	end
end

return rentCarListLayer