--
-- Author: Huang Yuzhao
-- Date: 2015-09-16 11:33
--
--限时促销
local flashSale = class("flashSale",function()
	--local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)
local ACTIVITY_ID = 102001

g_flashSale_hasBuyDiamond = 0
g_flashSale_bHasGetReward = nil

function flashSale:ctor()
    local activityType = "2"
    printTable(srv_userInfo.actInfo)
    ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType]
	g_hasBuyDiamond = 0
	flashSale_ReqConsumeNum()
	
	local tmpSize = cc.size(896,621)
	local bgSize = tmpSize
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,tmpSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2, bgSize.height-150)

    display.newSprite("youhui/youhuiTag_10.png")
    :addTo(bg)
    :align(display.LEFT_CENTER,50, bgSize.height-90)

    local bust = display.newSprite("Bust/bust_20094.png")
		:addTo(bg)
		:align(display.CENTER, tmpSize.width-160, tmpSize.height-90)
	bust:setScaleX(-0.8)
	bust:setScaleY(0.8)

    local btn = cc.ui.UIPushButton.new{normal = "youhui/youhuiBnt_01.png"}
		:addTo(bg)
		:align(display.CENTER, tmpSize.width/2+100, tmpSize.height-90)
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

    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(bg)
    :hide()
    :pos(bgSize.width-10,bgSize.height-20)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

	self.activityTime = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(bg)
        :align(display.LEFT_BOTTOM,60,bgSize.height-180)

    local datestr = "活动时间："
	local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
	datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
	startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
	datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
	datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
	self.activityTime:setString(datestr)


	self:ReqCheckBuy()

	self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(10, 30, 880, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }
        :addTo(bg)
        -- :setBounceable(false)
    self:reloadListView()
end

function flashSale:reloadListView()
    self.listview:removeAllItems()

    local sortList = {}
    for k,v in pairs(limitConsumeRewardData) do
        if v.aid==ACTIVITY_ID then
        	sortList[#sortList+1] = v.id
        end
    end
    table.sort( sortList, function (val_1,val_2)
    	return val_1<val_2
    end )

    for i=1,#sortList do
    	local loc_item = limitConsumeRewardData[sortList[i]]
    	local content = display.newSprite("youhui/youhuiImg_12.png")
        local _size = content:getContentSize()

        local tmpNode = display.newSprite("youhui/youhuiImg_14.png")
        	:addTo(content)
        	:align(display.LEFT_CENTER,15,_size.height/2)
        tmpNode:setScaleX(1)

        display.newSprite("youhui/youhuiImg_06.png")
        	:addTo(content)
        	:align(display.LEFT_CENTER,0,_size.height/2+30)

        tmpNode = display.newTTFLabel{text = "惊爆",color = cc.c3b(255,255,0),size=20}
        	:addTo(content)
        	:pos(40,_size.height-20)
        tmpNode:setRotation(-30)
        tmpNode = display.newTTFLabel{text = "降价",color = cc.c3b(255,255,0),size=20}
        	:addTo(content)
        	:pos(50,_size.height-38)
        tmpNode:setRotation(-30)

        display.newTTFLabel{text = "原价:",size = 20,color = cc.c3b(114,65,28)}
        	:addTo(content)
        	:align(display.LEFT_CENTER,80,_size.height-43)

        display.newTTFLabel{text = loc_item.diamond1,size = 22,color = cc.c3b(235,119,0)}
        	:addTo(content)
        	:align(display.LEFT_CENTER,130,_size.height-43)

        display.newSprite("youhui/youhuiImg_15.png")
        	:addTo(content)
        	:pos(130,_size.height-43)

        display.newTTFLabel{text = "现价:",size = 23,color = cc.c3b(114,65,28)}
        	:addTo(content)
        	:align(display.LEFT_CENTER,20,30)

        tmpNode = display.newTTFLabel{text = loc_item.diamond,size = 25,color = cc.c3b(0,160,231)}
        	:addTo(content)
        	:align(display.LEFT_CENTER,70,30)

        display.newSprite("common/common_Diamond.png")
        	:addTo(content)
        	:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width+5,30+5)
        	:scale(0.8)
        
        local strRewards = loc_item.reItems
		local arr = string.split(strRewards,"|")
		local tab = {}
		for i=1,#arr do
			local arr2 = string.split(arr[i],":")
			tab[#tab+1] = {tptId = arr2[1],num = arr2[2]}
		end
		local offX = 0
		local startPt = cc.p(280, _size.height/2)
		for k,v in pairs(tab) do
			local node = createItemIcon(v.tptId,v.num,true,true,0)
				:addTo(content)
				:pos(startPt.x+offX,startPt.y)
				:scale(0.75)
			offX = offX+(node.sprite_[1] or node):getContentSize().width*0.75+5
		end

		btn = cc.ui.UIPushButton.new{normal = "firstRecharge/xxcx_btn2.png"}
			:addTo(content,0,sortList[i])
			:pos(_size.width-80,_size.height/2)
			:onButtonPressed(function(event)
				event.target:setScale(0.95)
			end)
			:onButtonRelease(function(event)
				event.target:setScale(1.0)
			end)
			:onButtonClicked(function (event)
				local index = event.target:getTag()
				print("---------index:",index)
				if srv_userInfo.diamond<limitConsumeRewardData[index].diamond then
					showTips("钻石不足")
					return
				end
				if self.canBuyList~=nil and table.nums(self.canBuyList) ~=0 then
					showMessageBox("确定购买礼包？",function ()
						self:ReqBuy(index)
					end)
				else
					showTips("已经买过了")
					return
				end
			end)
		btn:setTouchSwallowEnabled(false)

		local function ifCanBuy(id)
			if self.canBuyList==nil then
			 	return false
			end
			for k,v in pairs(self.canBuyList) do
				if v==id then
					return true
				end
			end
			return false
		end

		if not ifCanBuy(sortList[i]) then
			btn:hide()
			display.newSprite("youhui/youhuiTag_03.png")
				:addTo(content,0,sortList[i])
				:pos(_size.width-80,_size.height/2)
		end

		local item = self.listview:newItem()
        item:addContent(content)
        item:setItemSize(840, 130)
        self.listview:addItem(item)

    end
    self.listview:reload()

end
--请求活动期间购买钻石数量
function flashSale_ReqConsumeNum()
	-- local _handle = {}
	-- function _handle:OnConsumeNumRet(cmd)
	-- 	endLoading()
	-- 	if cmd.result==1 then
	--        	g_hasBuyDiamond = cmd.data.paidDia
	--        	g_flashSale_bHasGetReward = cmd.data.idList
	--        	print("g_hasBuyDiamond:"..g_hasBuyDiamond)
	--     else
	--         print(cmd.msg)
	--     end
	-- end
	-- local sendData={}
 --    m_socket:SendRequest(json.encode(sendData), CMD_ACTIVITY_CUXIAO_NUM, _handle, _handle.OnConsumeNumRet)
 --    startLoading()
end

--充值一定数量钻石，即可领取
function flashSale:ReqGetReward(loc_id)
	-- local sendData={rewardId = loc_id}
 --    m_socket:SendRequest(json.encode(sendData), CMD_ACTIVITY_CUXIAO_GETREWARD, self, self.OnGetRewardRet)
 --    startLoading()
end

function flashSale:OnGetRewardRet(cmd)
	-- if cmd.result==1 then
 --       	local data = cmd.data
 --       	GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)

 --    else
 --        showTips(cmd.msg)
 --    end
 --    endLoading()
end

--360测试版，花费钻石购买礼包
function flashSale:ReqBuy(loc_id)
	print("购买：",loc_id)
	local sendData={rewardId = loc_id}
	self.currentId = loc_id
    m_socket:SendRequest(json.encode(sendData), CMD_ACTIVITY_CUXIAO_BUY, self, self.OnBuyRet)
    startLoading()
end

function flashSale:OnBuyRet(cmd)
	if cmd.result==1 then
       	local data = cmd.data
        self:GenerateRewardsTab(self.currentId)

       	GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)
       	-- self:ReqCheckBuy()
       	srv_userInfo.diamond = srv_userInfo.diamond - limitConsumeRewardData[self.currentId].diamond
       	
       	for k,v in pairs(self.canBuyList) do
       		if v==self.currentId then
       			self.canBuyList[k] = nil
       		end
       	end
        self.currentId = nil
       	self:reloadListView()
        mainscenetopbar:setDiamond()
    else
        showTips(cmd.msg)
    end
    endLoading()
end

function flashSale:GenerateRewardsTab(nTaskTplID)
    local loc_TaskData = limitConsumeRewardData[nTaskTplID]
    self.curRewards = {}
    
    if nil~=loc_TaskData.reItems and""~=loc_TaskData.reItems and "null"~=loc_TaskData.reItems then
        local arr = string.split(loc_TaskData.reItems, "|")
        local subArr
        for i=1, #arr do
            subArr = string.split(arr[i], ":")
            table.insert(self.curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
        end
    end
end

function flashSale:ReqCheckBuy()
	local sendData={}
    m_socket:SendRequest(json.encode(sendData), CMD_ACTIVITY_CUXIAO_CHECKBUY, self, self.OnCheckBuyRet)
    startLoading()
end

function flashSale:OnCheckBuyRet(cmd)
	if cmd.result==1 then
       	self.canBuyList = cmd.data.idList   --可以买的礼包
       	if self.canBuyList~=nil and #self.canBuyList >0 then
			self:reloadListView()
		end
    else
        showTips(cmd.msg)
    end
    endLoading()
end

return flashSale