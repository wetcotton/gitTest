--累计充值

local totalRecharge = class("totalRecharge",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)
ACTIVITY_ID = 114001
totalRechage_Instance = nil
function totalRecharge:ctor(_actIdex)
	totalRechage_Instance = self
	local activityType = "14"
	ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType][_actIdex]
    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2, bgSize.height-150)

    display.newSprite("youhui/youhuiTag_13.png")
    :addTo(bg)
    :align(display.LEFT_CENTER,55, bgSize.height-110)

    display.newSprite("youhui/youhuiImg_10.png")
        :addTo(bg)
        :pos(bgSize.width/2-100,bgSize.height-100)

    local bust = display.newSprite("Bust/bust_20094.png")
		:addTo(bg)
		:align(display.CENTER, bgSize.width-160, bgSize.height-130)
	bust:setScaleX(-0.9)
	bust:setScaleY(0.9)

    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(bg)
    :pos(bg:getContentSize().width-10,bg:getContentSize().height-20)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)
    :hide()

    cc.ui.UILabel.new({UILabelType = 2, text = "累计充值，即可领取充值大礼包", size = 23, color = cc.c3b(0, 160, 233)})
    :addTo(bg)
    :pos(60,bgSize.height/2+130)

    -- local label = cc.ui.UILabel.new({UILabelType = 2, text = "活动时间：", size = 23, color = cc.c3b(0, 160, 233)})
    -- :addTo(bg)
    -- :pos(60,bgSize.height/2+90)

    -- cc.ui.UILabel.new({UILabelType = 2, text = "2015年12月24日-2015年12月27日", size = 23})
    -- :addTo(bg)
    -- :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())

    self.activityTime = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(bg)
        :align(display.LEFT_BOTTOM,60,bgSize.height/2+80)

    local datestr = "活动时间："
    print("ACTIVITY_ID: ",ACTIVITY_ID)
    -- printTable(ACTIVITY_ID)
	local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
	datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
	startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
	self.activityTime:setString(datestr)

	display.newTTFLabel({
							text="(注：月卡不计入此活动)",
							size=18,
							color=cc.c3b(200,200,200),
						})
			:addTo(bg,0,1)
			:align(display.LEFT_CENTER,80,bgSize.height/2+65)

    tmpNode = display.newSprite("youhui/youhuiImg_11.png")
					:addTo(bg)
					:align(display.LEFT_CENTER,9,bgSize.height/2+10)
	tmpNode:setScaleX(1.1)
	tmpNode:setScaleY(0.9)
	local lbl = display.newTTFLabel({
							text="活动期间已充值：",
							size=22,
							color=cc.c3b(0,255,255),
						})
			:addTo(bg,0,1)
			:align(display.LEFT_CENTER,30,tmpNode:getPositionY())
	self.totalRechageNum =  display.newTTFLabel({
							text="0",
							size=22,
							color=cc.c3b(255,255,0),
						})
			:addTo(bg,0,2)
			:align(display.LEFT_CENTER, lbl:getPositionX()+lbl:getContentSize().width, lbl:getPositionY())

    local btn = cc.ui.UIPushButton.new{normal = "youhui/youhuiBnt_01.png"}
		:addTo(bg)
		:align(display.CENTER, bgSize.width-160, bgSize.height-270)
		:scale(0.8)
		:onButtonPressed(function(event)
			event.target:setScale(0.95*0.8)
		end)
		:onButtonRelease(function(event)
			event.target:setScale(1.0*0.8)
		end)
		:onButtonClicked(function(event)
			g_recharge.new()
        		:addTo(display.getRunningScene())
		end)
	display.newTTFLabel{text = "充 值",size = 30}
			:addTo(btn)

	self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 50),
        viewRect = cc.rect(26, 30, 841, 238),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
        }
        :addTo(bg)
        -- :setBounceable(false)
    self:ReqInit()

end

function totalRecharge:onEnter()
    
end

function totalRecharge:onExit()
    totalRechage_Instance = nil
end

function totalRecharge:reloadListView()
	self.listview:removeAllItems()

    local sortList = {}
    for k,v in pairs(totalRechargeData) do
    	--限时累计充值表里有不同的档位，对应不同的运营活动，通过运营活动开启情况个来确定
    	if v.aid==ACTIVITY_ID then
	    	sortList[#sortList+1] = v.id
	    end
    end
    table.sort( sortList, function (val_1,val_2)
    	return val_1>val_2
    end )
    printTable(sortList)
    for i=1,#sortList do
        print(i)
    	local btnClick
    	local loc_item = totalRechargeData[sortList[i]]
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
    	local content = cc.ui.UIPushButton.new{normal = "youhui/youhuiImg_05.png"}
			:scale(0.8)
			:onButtonPressed(function(event)
				event.target:setScale(0.95*0.8)
				end)
			:onButtonRelease(function(event)
				event.target:setScale(1.0*0.8)
				end)
			:onButtonClicked(function (event)
				local index = event.target.kk_index
				print("index: ",index,"loc_item.rmb",loc_item.rmb,"self.hasPay",self.hasPay)
				local loc_item = totalRechargeData[index]

				local titleImg = "SingleImg/messageBox/tips.png"
				local canGet = false
				if ifCanBuy(index) and loc_item.rmb<=self.hasPay then --可领奖
					titleImg = "common/common_WordsGain.png"
					canGet = true
				end
				local function _handler()
					if canGet then 
						self:ReqBuy(index)
					else									--冲得不够，不可领奖
						showTips("充值更多才能领奖哦")
					end
				end
				self:GenerateRewardsTab(index)
				self:showBox(canGet,self.curRewards,titleImg,_handler)

			end)
		content.kk_index = sortList[i]
		content:setTouchSwallowEnabled(false)
		local _size = cc.size(content.sprite_[1]:getContentSize().width*0.8,content.sprite_[1]:getContentSize().height*0.8)
		
		display.newSprite("common2/com2_img_25.png")
				:addTo(content)
				:pos(0,20)
				:scale(1.5)

		local cost = display.newTTFLabel({text=loc_item.rmb,size=30,color=cc.c3b(255,255,0),font = "fonts/slicker.ttf"})
			:addTo(content)
			:align(display.CENTER,30,-90)

		display.newTTFLabel{text = "充值满",size = 30}
			:addTo(content)
			:align(display.RIGHT_CENTER,cost:getPositionX()-cost:getContentSize().width/2-5,cost:getPositionY())
		display.newTTFLabel{text = "元",size = 30}
			:addTo(content)
			:align(display.LEFT_CENTER,cost:getPositionX()+cost:getContentSize().width/2+5,cost:getPositionY())

		local imgTag_1 = display.newSprite("youhui/youhuiImg_05.png")
			:addTo(content,0,1)
			:hide()
			:opacity(50)
		imgTag_1:setColor(cc.c3b(0,0,0))

		display.newSprite("youhui/youhuiTag_07.png")
				:addTo(imgTag_1)
				:pos(_size.width/2/0.8,_size.height/2/0.8+30)
				:scale(1.3)
		local imgTag_2 = display.newSprite("youhui/youhuiTag_09.png")
				:addTo(content,0,2)
				:align(display.LEFT_TOP,-_size.width/2/0.8-2,_size.height/2/0.8-0)
				:hide()
				:scale(1.3)

		if not ifCanBuy(sortList[i]) then--已经领过奖的
			-- content:setTouchEnabled(false)
			imgTag_1:show()
		else
			if loc_item.rmb<=self.hasPay then --可领奖
				imgTag_2:show()
			else									--冲得不够，不可领奖

			end
		end

			

		local item = self.listview:newItem()
        item:addContent(content)
        item:setItemSize(_size.width+15, _size.height)
        self.listview:addItem(item)
    end
    self.listview:reload()
end

function totalRecharge:ReqInit()
	local sendData={}
    m_socket:SendRequest(json.encode(sendData), CMD_TOTALRECHARGE_INIT, self, self.OnInitRet)
    startLoading()
end

function totalRecharge:OnInitRet(cmd)
	if cmd.result==1 then
        local data = cmd.data[tostring(ACTIVITY_ID)]
       	self.hasPay = data.money
       	self.canGetList = data.idList
       	self.totalRechageNum:setString(self.hasPay)
       	self:reloadListView()

       	-- local node = self:getParent().activityBtns[9]
       	-- node:removeChildByTag(10)
       	-- if data.isReward==1 then
       	-- 	local RedPt = display.newSprite("common/common_RedPoint.png")
	       --      :addTo(node,0,10)
	       --      :pos(60,30)
       	-- end
    else
        showTips(cmd.msg)
    end
    endLoading()
end

function totalRecharge:ReqBuy(_id)
	local sendData={rewardId = _id}
	self.curId = _id
    m_socket:SendRequest(json.encode(sendData), CMD_TOTALRECHARGE_REWARD, self, self.OnBuyRet)
    startLoading()
end

--领奖返回
function totalRecharge:OnBuyRet(cmd)
	if cmd.result==1 then
        srv_userInfo.diamond  = cmd.data.diamond
        mainscenetopbar:setDiamond()
       	
       	GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)

       	for k,v in pairs(self.canGetList) do
       		if v==self.curId then
       			self.canGetList[k] = nil
       		end
       	end
       	self:reloadListView()

       	local node = self:getParent().activityBtns[9]
       	node:removeChildByTag(10)
       	for k,v in pairs(self.canGetList) do
       		if totalRechargeData[v].rmb<=self.hasPay then
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

function totalRecharge:GenerateRewardsTab(index)
	local loc_item = totalRechargeData[index]
	self.curRewards = {}
  	if nil~=loc_item.rewardItems and""~=loc_item.rewardItems and "null"~=loc_item.rewardItems then
		local arr = string.split(loc_item.rewardItems, "|")
		local subArr
		for i=1, #arr do
			subArr = string.split(arr[i], "#")
			table.insert(self.curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
    if loc_item.diamond and loc_item.diamond~="null" and loc_item.diamond>0 then
        table.insert(self.curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=tonumber(loc_item.diamond)})
    end
    
end

function totalRecharge:showBox(canGet,tabItems, titleImg,_handler)
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

return totalRecharge