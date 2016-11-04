--
-- Author: Huang Yuzhao
-- Date: 2015-09-16 11:33
--
--累计消费
local totalConsume = class("totalConsume",function()
	--local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)

totalConsume_Instance = nil
local ACTIVITY_ID = 104001

function totalConsume:ctor()
	local activityType = "4"
	printTable(srv_userInfo.actInfo)
	ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType]
	totalConsume_Instance = self
	local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
	    :addTo(self)
	    :pos(display.cx, display.cy-20)

	display.newSprite("youhui/youhuiImg_08.png")
	    :addTo(bg)
	    :pos(bgSize.width/2, bgSize.height-150)
	local tmpNode,tmpSize = bg,bg:getContentSize()
	cc.ui.UIPushButton.new{normal = "common/common_CloseBtn_1.png",pressed = "common/common_CloseBtn_2.png"}
			:addTo(bg)
			:align(display.CENTER, tmpSize.width-7, tmpSize.height-7)
			:onButtonClicked(function ( ... )
				self:removeSelf()
			end)
	:hide()
	tmpNode = display.newSprite("youhui/youhuiTag_06.png")
		:addTo(bg)
    	:align(display.LEFT_CENTER,50, bgSize.height-90)

	tmpNode = display.newSprite("youhui/youhuiImg_11.png")
					:addTo(bg)
					:align(display.LEFT_CENTER,9,tmpSize.height-150)
	tmpNode:setScaleX(1.1)
	tmpNode:setScaleY(0.9)
	local lbl = display.newTTFLabel({
							text="当前您已累计消费：",
							size=22,
							color=cc.c3b(0,255,255),
						})
			:addTo(bg,0,1)
			:align(display.LEFT_CENTER,30,tmpSize.height-150)
	self.totalConsumeNum =  display.newTTFLabel({
							text="",
							size=22,
							color=cc.c3b(255,255,0),
						})
			:addTo(bg,0,2)
			:align(display.LEFT_CENTER, lbl:getPositionX()+lbl:getContentSize().width, lbl:getPositionY())

	self.diamongImg = display.newSprite("common/common_Diamond.png")
		:addTo(bg,0,3)
		:scale(0.6)
		:align(display.LEFT_CENTER, 10+self.totalConsumeNum:getPositionX()+self.totalConsumeNum:getContentSize().width, self.totalConsumeNum:getPositionY())

	tmpNode:setContentSize(tmpNode:getContentSize().width+self.totalConsumeNum:getContentSize().width-55,tmpNode:getContentSize().height)

	self.activityTime = display.newTTFLabel({
							text="活动时间：2015年11月10-16日",
							size=20,
							color=cc.c3b(0,255,255),
						})
			:addTo(bg,0,1)
			:align(display.RIGHT_CENTER, tmpSize.width-30, tmpSize.height-150)
	local datestr = "活动时间："
	local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
	datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
	startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
	self.activityTime:setString(datestr)

	self.scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 0, 200, 0))
						:pos(30,30)
	self.scrollNode:setContentSize(840, 390)

  --   self._scrollView = cc.ui.UIScrollView.new {
  --   	-- bgColor = cc.c4b(0, 200, 0, 100),
  --   	viewRect = cc.rect(30, 30, 840, 390),
  --   	direction=cc.ui.UIScrollView.DIRECTION_VERTICAL,
		-- }
		-- :addTo(bg)
		-- :addScrollNode(self.scrollNode)
	
		-- self:initList()

	self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 50),
        viewRect = cc.rect(30, 30, 840, 390),
    	direction=cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(bg)
	
end

function totalConsume:onEnter()
	self:performWithDelay(function ()
		self:ReqInit()
	end,0.1)
end

function totalConsume:reloadListView()
	self.listview:removeAllItems()

    local sortList = {}
    for k,v in pairs(totalConsumeData) do
    	--限时累计消费表里有不同的档位，对应不同的运营活动，通过运营活动开启情况个来确定
    	print("v.aid",v.aid,ACTIVITY_ID)
    	if v.aid==ACTIVITY_ID then
	    	sortList[#sortList+1] = v.id
	    end
    end
    table.sort( sortList, function (val_1,val_2)
    	return val_1<val_2
    end )
    printTable(sortList)
    local lineNum = math.ceil(#sortList/4)
    for j=1,lineNum do
    	local content = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,cc.size(840,220),cc.rect(60,0,1,621))
    			:opacity(0)
    	for k = 1,4 do
    		local i = (j-1)*4+k
    		if i<=#sortList then
    			local btnClick
		    	local loc_item = totalConsumeData[sortList[i]]
		    	local function ifCanBuy(id)
					if self.canGetList==nil then
					 	return false
					end
					for k,v in pairs(self.canGetList) do
						if v==id then
							return true
						end
					end
					return false
				end
				local posX = 100+(k-1)*210
				local posY = 100
		    	local _btn = cc.ui.UIPushButton.new{normal = "youhui/youhuiImg_05.png"}
					:scale(0.8)
					:addTo(content)
					:pos(posX,posY)
					:onButtonPressed(function(event)
						event.target:setScale(0.95*0.8)
						end)
					:onButtonRelease(function(event)
						event.target:setScale(1.0*0.8)
						end)
					:onButtonClicked(function (event)
						local index = event.target.kk_index
						local loc_item = totalConsumeData[index]
						local titleImg = "SingleImg/messageBox/tips.png"
						local canGet = false
						if ifCanBuy(index) and loc_item.diamond<=self.hasCost then --可领奖
							titleImg = "common/common_WordsGain.png"
							canGet = true
						end
						local function _handler()
							if canGet then 
								self:ReqBuy(index)
							else									--花得不够，不可领奖
								showTips("消费更多钻石更多才能领奖哦")
							end
						end
						self:GenerateRewardsTab(index)
						self:showBox(canGet,self.curRewards,titleImg,_handler)

					end)
				_btn.kk_index = sortList[i]
				_btn:setTouchSwallowEnabled(false)
				local _size = cc.size(_btn.sprite_[1]:getContentSize().width*0.8,_btn.sprite_[1]:getContentSize().height*0.8)
				
				display.newSprite("common2/com2_img_25.png")
						:addTo(_btn)
						:pos(0,20)
						:scale(1.5)

				local cost = display.newTTFLabel({text=loc_item.diamond,size=30,color=cc.c3b(255,255,0),font = "fonts/slicker.ttf"})
					:addTo(_btn)
					:align(display.CENTER,0,-113)

				display.newTTFLabel{text = "钻石累计消耗",size = 30}
					:addTo(_btn)
					:align(display.CENTER,0,-80)

				display.newTTFLabel{text = "达到",size = 30}
					:addTo(_btn)
					:align(display.RIGHT_CENTER,cost:getPositionX()-cost:getContentSize().width/2-5,cost:getPositionY())
				display.newTTFLabel{text = "额度",size = 30}
					:addTo(_btn)
					:align(display.LEFT_CENTER,cost:getPositionX()+cost:getContentSize().width/2+5,cost:getPositionY())

				local imgTag_1 = display.newSprite("youhui/youhuiImg_05.png")
					:addTo(_btn,0,1)
					:hide()
					:opacity(50)
				imgTag_1:setColor(cc.c3b(0,0,0))

				display.newSprite("youhui/youhuiTag_07.png")
						:addTo(imgTag_1)
						:pos(_size.width/2/0.8,_size.height/2/0.8+30)
						:scale(1.3)
				local imgTag_2 = display.newSprite("youhui/youhuiTag_09.png")
						:addTo(_btn,0,2)
						:align(display.LEFT_TOP,-_size.width/2/0.8-2,_size.height/2/0.8-0)
						:hide()
						:scale(1.3)

				if not ifCanBuy(sortList[i]) then--已经领过奖的
					-- _btn:setTouchEnabled(false)
					imgTag_1:show()
				else
					if loc_item.diamond<=self.hasCost then --可领奖
						imgTag_2:show()
					else									--花得不够，不可领奖

					end
				end
    		end
    	end

		local item = self.listview:newItem()
        item:addContent(content)
        item:setItemSize(840, 240)
        self.listview:addItem(item)
    end
    self.listview:reload()
end

function totalConsume:onExit()
	totalConsume_Instance = nil
end

function totalConsume:ReqInit()

	local sendData={}
    m_socket:SendRequest(json.encode(sendData), CMD_TOTALCONSUME_INIT, self, self.OnInitRet)
    startLoading()
end

function totalConsume:OnInitRet(cmd)
	if cmd.result==1 then
		self.hasCost = cmd.data.costDia
       	if self.totalConsumeNum then
	       	self.totalConsumeNum:setString(self.hasCost)
	       	self.diamongImg:setPositionX(10+self.totalConsumeNum:getPositionX()+self.totalConsumeNum:getContentSize().width)
       	end
       	self.canGetList = cmd.data.idList
       	if not self.reloadListView then
       		return
       	end
       	self:reloadListView()

		local node = self:getParent().activityBtns[1]
       	node:removeChildByTag(10)
       	if cmd.data.isReward==1 then
       		local RedPt = display.newSprite("common/common_RedPoint.png")
	            :addTo(node,0,10)
	            :pos(60,30)
       	end
    else
        showTips(cmd.msg)
    end
    endLoading()
end

function totalConsume:ReqBuy(_id)
	local sendData={rewardId = _id}
	self.curId = _id
    m_socket:SendRequest(json.encode(sendData), CMD_TOTALCONSUME_REWARD, self, self.OnBuyRet)
    startLoading()
end

--领奖返回
function totalConsume:OnBuyRet(cmd)
	if cmd.result==1 then
       	
       	GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)

       	for k,v in pairs(self.canGetList) do
       		if v==self.curId then
       			self.canGetList[k] = nil
       		end
       	end
       	self:reloadListView()

       	local node = self:getParent().activityBtns[1]
       	node:removeChildByTag(10)
       	for k,v in pairs(self.canGetList) do
       		if totalConsumeData[v].diamond<=self.hasCost then
       			local RedPt = display.newSprite("common/common_RedPoint.png")
		            :addTo(node,0,10)
		            :pos(60,30)
		        break
       		end
       	end
    else
        showTips(cmd.msg)
    end
    endLoading()
end

function totalConsume:GenerateRewardsTab(index)
	local loc_item = totalConsumeData[index]
	self.curRewards = {}
	if nil~=loc_item.rewardItems and""~=loc_item.rewardItems and "null"~=loc_item.rewardItems then
		local arr = string.split(loc_item.rewardItems, "|")
		local subArr
		for i=1, #arr do
			subArr = string.split(arr[i], "#")
			table.insert(self.curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
end


function totalConsume:showBox(canGet,tabItems, titleImg,_handler)
	local box = UIGainBox_old.new({bAlwaysExist = true,color = {0,0,0,128}},_handler)
    box:SetGainItem(tabItems, titleImg)
    box:addTo(self)
    	:pos(-150,0)
    local tmpSize = box:getContentSize()
    local closeBtn = cc.ui.UIPushButton.new{normal = "common/common_CloseBtn_1.png",pressed = "common/common_CloseBtn_2.png"}
			:addTo(box)
			:align(display.CENTER, tmpSize.width/2+260, tmpSize.height/2+175)
			:onButtonClicked(function (  )
				box:removeSelf()
			end)
	if not canGet then
		box.desPanel:size(813,455)
		for k,v in pairs(box.desPanel:getChildren()) do 
			v:pos(v:getPositionX(),v:getPositionY()-90)
		end
		box.bg2:size(757,398)
			:pos(box.bg2:getPositionX(),box.bg2:getPositionY()+40)
		box.confirmBtn:hide()
		closeBtn:pos(tmpSize.width/2+410, tmpSize.height/2+225)
    else
        box.desPanel:size(813,455)
        for k,v in pairs(box.desPanel:getChildren()) do 
            v:pos(v:getPositionX(),v:getPositionY()-90)
        end
        box.bg2:size(757,398)
            :pos(box.bg2:getPositionX(),box.bg2:getPositionY()+40)
        closeBtn:pos(tmpSize.width/2+410, tmpSize.height/2+225)
        box.confirmBtn:setPositionY(box.confirmBtn:getPositionY()+35)
	end
end

return totalConsume