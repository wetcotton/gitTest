
local worldBoss = class("worldBoss",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(40, 52, 58, 255))
    layer:setNodeEventEnabled(true)
    return layer
end)

worldBossInstance = nil
chatMsgList = {}

local c = cc
local Node = c.Node
function Node:red()
	if false then
		return self
	end
    self:setColor(cc.c3b(255,0,0))
    self:setOpacity(255)
    return self
end

local matchProcessType = {}
matchProcessType.none 		 	= 0		--没有开始任何匹配
matchProcessType.randSuccess 	= 1		--随机匹配完成
matchProcessType.legionIng   	= 2		--正在进行军团匹配
matchProcessType.legionSuccess  = 3		--军团匹配完成

matchProcessType.teamerLegionIng  = 4		--作为队友，接受邀请，进入队伍（但并不一定登记了战车）
matchProcessType.teamerLegionSuccess  = 5		--作为队友，队伍更新后人数达到3人

local tmpNode,tmpSize

function worldBoss:getTeamerNum()
	local teamerNum,carNum = 0,0
	for k,v in pairs(self.teamData) do
		if v.characterId ~=nil and v.characterId ~=0 then
			teamerNum = teamerNum + 1
		end
		if v.carTptId ~=nil and v.carTptId ~=0 then
			carNum = carNum + 1
		end
	end
	return teamerNum,carNum
end

function worldBoss:ctor()
	local colorBg = display.newSprite("common/colorbg.png")
	:addTo(self,-1)
	colorBg:setAnchorPoint(0,0)
	colorBg:setScaleX(display.width/colorBg:getContentSize().width)
	colorBg:setScaleY(display.height/colorBg:getContentSize().height)  

    self.enterMatch = false  --是否进入匹配界面中
	g_nCurChildModule = 1
	--bIsBossClose = false
	worldBossInstance = self
	display.addSpriteFrames("Image/UIWorldBoss.plist", "Image/UIWorldBoss.png")
	display.addSpriteFrames("Image/bossUIEffect.plist", "Image/bossUIEffect.png")

	display.newScale9Sprite("#bossImg_13.png",nil,nil,cc.size(display.width,272),cc.rect(100,0,1,272))
   				:addTo(self)
   				:align(display.CENTER_BOTTOM,display.cx,-24)

	--返回按钮
	cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height)
    	:addTo(self,3)
    	:onButtonClicked(function(event)
    		print("self.m_matchProcessType: "..self.m_matchProcessType)
    		print("self:getTeamerNum(): "..self:getTeamerNum())

    		local function _exitLayer()
    			self:removeSelf()
    			if FightSceneEnterType == EnterTypeList_2.WORLDBOSS_ENTER then
		    		FightSceneEnterType = EnterTypeList_2.NORMAL_ENTER
		    		print("-------------==================789--------FightSceneEnterType=="..FightSceneEnterType)
		    	end
    		end
    		--三人到齐了
    		if self.m_matchProcessType == matchProcessType.randSuccess or self.m_matchProcessType == matchProcessType.legionSuccess then
    			pauseCountDown(self.timeHandle)
    			pauseCountDown(self.timeHandle_90)
    			showMessageBox("匹配已完成，是否确认退出？",function ()
    				stopCountDown(self.timeHandle)
    				stopCountDown(self.timeHandle_90)
    				self:ReqExitTeam()
    				_exitLayer()
    			end,function ()
    				self.timeHandle = resumeCountDown(self.timeHandle)
    				self.timeHandle_90 = resumeCountDown(self.timeHandle_90)
    			end)
    		--队伍有两个人
    		elseif self.m_matchProcessType == matchProcessType.legionIng and self:getTeamerNum()>1 then
    			showMessageBox("组队尚未完成，是否确认退出？",function ()
    				self:ReqExitTeam()
    				_exitLayer()
    			end)
    		--作为队友参战，队长未进入布阵
    		elseif (self.m_matchProcessType == matchProcessType.teamerLegionSuccess or self.m_matchProcessType == matchProcessType.teamerLegionIng ) --[[and self.m_carTptId == 0]] then
    			showMessageBox("尚未完成援助，是否确认退出？",function ()
    				self:ReqExitTeam()
    				_exitLayer()
    			end)
    		--发出去的请求没人回应
    		elseif self.askCold>0 or (self.m_matchProcessType == matchProcessType.legionIng and self:getTeamerNum()==1 and table.nums(self.hasInvited)>0) then
    			pauseCountDown(self.timeHandle_cold)
    			showMessageBox("援助请求尚未获得回应，是否确认退出？",function ()
    				stopCountDown(self.timeHandle_cold)
    				self:ReqExitTeam()
    				_exitLayer()
    			end,function ( ... )
    				self.timeHandle_cold = resumeCountDown(self.timeHandle_cold)
    			end)
    		else
    			self:ReqExitTeam()
    			_exitLayer()
    		end
            
    	end)

    self.teamData = {{},{},{}}    --队伍里的三个人情况
    self.m_matchProcessType = matchProcessType.none 	--当前组队进度
    self.myHelpList = {}  --我向其发送请求的玩家characterId列表
    self.m_helpAskList = {} --向我发送请求的玩家列表
    self.m_legionMembers = {}  --军团成员列表
    self.askCold = 0			--组队的冷却时间
    self.m_carTptId = 0			--我登记的车辆
    self.hasInvited = {}        --我已经邀请过的人
    self.m_restCount = 0		--今日剩余挑战次数

local xxx_ = {
	10122,
	10131,10000,
	10132,
	10133,
	10141,
	10142,
	10143,
	10144,}
    

    
    -- for i=1 ,10 do
    -- 	chatMsgList[#chatMsgList+1] = {senderName = "路人甲",msg = "路人甲你好，天王盖地虎，一二三四五",senderTmpId = xxx_[i],senderLevel = 12,senderVip = 13,time = "12:00"}
    -- end
    chatMsgList[#chatMsgList+1] = {senderName = "系统消息",msg = "欢迎进入世界boss",time = os.date("%H:%M:%S"),senderTmpId = 10000}

    self:initFirstPanel()
    self:initSecendPanel()
    self:initRankList()
end

function worldBoss:initRule()
	
	self.ruleMask = UIMasklayer.new()
			:addTo(self,4)
			:hide()
	local tmpNode = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
				:addTo(self.ruleMask)
				:pos(display.cx, display.cy)
	local tmpSize = tmpNode:getContentSize()
	self.ruleMask:addHinder(tmpNode)

	display.newSprite("#bossTag_10.png")
				:addTo(tmpNode)
				:align(display.CENTER,tmpSize.width/2,tmpSize.height-55)

	local ruleLayerSize = cc.size(700,400)

	self.ruleLayer = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 255, 0, 0))
			:pos(tmpSize.width/2-350, tmpSize.height/2-180-40)
	self.ruleLayer:setContentSize(ruleLayerSize.width, ruleLayerSize.height)

	self.ruleScroll = cc.ui.UIScrollView.new {
    	--bgColor = cc.c4b(255, 0, 0, 100),
    	viewRect=cc.rect(tmpSize.width/2-350, tmpSize.height/2-180-40, ruleLayerSize.width, ruleLayerSize.height),
    	direction=cc.ui.UIScrollView.DIRECTION_VERTICAL,
		}
		:addScrollNode(self.ruleLayer)
		:addTo(tmpNode)
		--:setBounceable(false)

	-- display.newScale9Sprite("#bossFrame_01.png", nil, nil,cc.size(ruleLayerSize.width,360) , cc.rect(45, 45, 4, 5))
	-- 				    :addTo(self.ruleLayer)
	-- 				    :pos(ruleLayerSize.width/2,ruleLayerSize.height-180)
	-- 				    :red()

	local _label = display.newTTFLabel({
	                        text = 109,
	                        size = 20,
	                        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	                        dimensions = cc.size(ruleLayerSize.width,360)
	                        })
	                        :addTo(self.ruleLayer)
					    	:pos(ruleLayerSize.width/2,ruleLayerSize.height-180)
    local str = [[1.每天的12:30-13:30,20:00-21:00为活动开启时间，其他时间不能开始挑战。
2.每天的任意时间都可以进行战车选定。
3.以3人小队形式进行挑战，每名玩家只能选定一辆战车参战，队长在战斗中可以控制3辆战车。
4.每人每天有3次队长机会，组队进行挑战。
5.每人每天作为队员助战次数不限制。
6.军团匹配，邀请在线军团成员进行助战，助战成员获得队长本次挑战伤害的5%。
7.随机匹配，系统根据战斗力分配队友助战，随机匹配的队友不能获得队长的伤害收益。
8.玩家活动时间内总伤害量计算为队长挑战的伤害与助战伤害收益之和。
9.活动结束后根据排名区间发放邮件奖励，若活动时间内BOSS被击杀，则所有参与玩家奖励有额外加成。


	    ]]
	_label:setString(str)

	local data_1 = {} --白天未击杀
	local data_3 = {} --晚上未击杀
	for k,v in pairs(worldBossRankRewardData) do
		if v.type == 1 then
			data_1[#data_1+1] = v
		elseif v.type == 3 then
			data_3[#data_3+1] = v
		end
	end

	local function _sort(val_1,val_2)
		return val_1.sorder < val_2.sorder
	end

	table.sort(data_1,_sort)
	table.sort(data_3,_sort)
	local startY = ruleLayerSize.height-360
	local ptY = startY-30
	for i=1,5 do
		local ptX = 20
		local value_1 = data_1[i]
		local value_3 = data_3[i]
		local str = value_1.sorder..""
		if value_1.sorder~= value_1.eorder then
			str = value_1.sorder.."-"..value_1.eorder
		end
		tmpNode = display.newTTFLabel{text = "第"..str.."名："}
			:addTo(self.ruleLayer)
			:align(display.LEFT_CENTER,ptX,ptY)

		ptX = ptX + 140
		GlobalGetSpecialItemIcon(GAINBOXTPLID_GOLD, value_1.gold, 0.7)
        :pos(ptX,ptY)
        :addTo(self.ruleLayer)

        ptX = ptX + 120
		GlobalGetSpecialItemIcon(GAINBOXTPLID_DIAMOND, value_1.diamond, 0.7)
        :pos(ptX,ptY)
        :addTo(self.ruleLayer)

        ptX = ptX + 200
		-- GlobalGetSpecialItemIcon(GAINBOXTPLID_GONGXUN, value_3.exploit, 0.7)
  --       :pos(ptX,ptY)
  --       :addTo(self.ruleLayer)
        local rewards = string.split(value_3.rewardItems,"|")

        local _arr = string.split(rewards[1],"#")
        createItemIcon(tonumber(_arr[1]),tonumber(_arr[2]))
        :pos(ptX,ptY)
        :addTo(self.ruleLayer)
        :scale(0.6)

        ptX = ptX + 120
        local _arr = string.split(rewards[2],"#")
        createItemIcon(tonumber(_arr[1]),tonumber(_arr[2]))
        :pos(ptX,ptY)
        :addTo(self.ruleLayer)
        :scale(0.6)

		ptY = ptY -80
	end
	local points = {
		{380,startY},
		{380,ptY+50}
	}
	display.newLine(points,{borderColor = cc.c4f(0.8,0.8,0.8,1),borderWidth = 2})
		:addTo(self.ruleLayer)

	display.newTTFLabel{text = "……"}
		:addTo(self.ruleLayer)
		:align(display.LEFT_CENTER,20,ptY)
end

function worldBoss:initRankList()
	self.rankNode = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
			:addTo(self,4)
			:hide()

	local bg = display.newSprite("SingleImg/worldBoss/bossImg_23.png")
				:addTo(self.rankNode)
				:pos(display.cx, display.cy)
	tmpSize = bg:getContentSize()

	cc.ui.UIPushButton.new({normal="common/common_CloseBtn_1.png",pressed="common/common_CloseBtn_2.png"})
        :align(display.CENTER, tmpSize.width-10, tmpSize.height-10)
        :addTo(bg)
        :onButtonClicked(function(event)
            self.rankNode:hide()
        end)

    local function selTab(index)
    	if index==1 then
    		self.tab1:setButtonEnabled(false)
    		self.tab2:setButtonEnabled(true)

    		self.tabNode_1:show()
    		self.tabNode_2:hide()
		else
			self.tab1:setButtonEnabled(true)
    		self.tab2:setButtonEnabled(false)

    		self.tabNode_1:hide()
    		self.tabNode_2:show()
		end
    end

    self.tab1 = cc.ui.UIPushButton.new({normal="#bossImg_17.png",pressed="#bossImg_16.png",disabled = "#bossImg_16.png"})
        :align(display.CENTER, 152, tmpSize.height-70)
        :addTo(bg)
        :onButtonClicked(function(event)
            selTab(1)
        end)
    display.newSprite("#bossTag_11.png")
    			:addTo(self.tab1)
    			:pos(-20,0)

    self.tab2 = cc.ui.UIPushButton.new({normal="#bossImg_17.png",pressed="#bossImg_16.png",disabled = "#bossImg_16.png"})
        :align(display.CENTER, 152+256, tmpSize.height-70)
        :addTo(bg)
        :onButtonClicked(function(event)
            selTab(2)
        end)
    display.newSprite("#bossTag_12.png")
    			:addTo(self.tab2)
    			:pos(-20,0)

   	self.tabNode_1 = display.newNode()
   			:addTo(bg)
   	self.tabNode_2 = display.newNode()
   			:addTo(bg)

   	display.newSprite("#bossImg_20.png")
   		:addTo(self.tabNode_1)
   		:align(display.CENTER_BOTTOM,tmpSize.width/2+10,35)

   	-- display.newScale9Sprite("#bossFrame_01.png", nil, nil,cc.size(700,330) , cc.rect(45, 45, 4, 5))
				-- 	    :addTo(bg)
				-- 	    :pos(tmpSize.width/2,tmpSize.height/2+10)
				-- 	    :red()
	self.tab_1_list = cc.ui.UIListView.new {
	        --bgColor = cc.c4b(200, 0, 0, 100),
	        scrollbarImgV = "common/jiaob_lapit-05.png",
	        scrollbarImgVBg = "common/jiaob_lapit-04.png",
	        viewRect = cc.rect(tmpSize.width/2-350, tmpSize.height/2-155, 710, 330),
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self.tabNode_1)

    display.newSprite("#bossImg_19.png")
    	:addTo(self.tabNode_1)
    	:pos(tmpSize.width/2-10,140)

    tmpNode = display.newSprite("#bossImg_20.png")
   		:addTo(self.tabNode_2)
   		:align(display.CENTER,tmpSize.width/2+10,tmpSize.height-155)
   	tmpNode:setScaleY(-1)

   	display.newTTFLabel{text = "总伤害：",size= 38,color = cc.c3b(201,154,82)}
   		:addTo(self.tabNode_2)
   		:align(display.LEFT_CENTER,80,tmpSize.height-155)
   	self.myTotalHurt_2 = display.newTTFLabel{font = "fonts/slicker.ttf",text = 1231544646,size= 38,color = cc.c3b(219,93,49)}
   		:addTo(self.tabNode_2)
   		:align(display.LEFT_CENTER,220,tmpSize.height-155)

   	display.newSprite("#bossTag_13.png")
   		:addTo(self.tabNode_2)
   		:align(display.LEFT_CENTER,90,tmpSize.height-230)

   	self.drawNode = display.newDrawNode()
    					:addTo(self.tabNode_2)

   	local rect = cc.rect(95, tmpSize.height-390, 680, 140)
	local points = {
        {rect.x,rect.y},
        {rect.x + rect.width, rect.y},
        {rect.x + rect.width, rect.y + rect.height},
        {rect.x, rect.y + rect.height}
    }
	self.drawNode = display.newPolygon(points,{fillColor = cc.c4f(0.1411,0.149,0.149,1), borderColor = cc.c4f(0.0431,0.047,0.047,1), borderWidth = 1.5},self.drawNode)

   	self.tab_2_list_1 = cc.ui.UIListView.new {
	        --bgColor = cc.c4b(255, 38, 38, 100),
	        scrollbarImgV = "common/jiaob_lapit-05.png",
	        scrollbarImgVBg = "common/jiaob_lapit-04.png",
	        viewRect = cc.rect(97, tmpSize.height-388, 678, 138),
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self.tabNode_2)
    display.newSprite("#bossTag_14.png")
   		:addTo(self.tabNode_2)
   		:align(display.LEFT_CENTER,95,220)
   	rect = cc.rect(95, 40, 680, 160)
	points = {
        {rect.x,rect.y},
        {rect.x + rect.width, rect.y},
        {rect.x + rect.width, rect.y + rect.height},
        {rect.x, rect.y + rect.height}
    }
	self.drawNode = display.newPolygon(points,{fillColor = cc.c4f(0.1411,0.149,0.149,1), borderColor = cc.c4f(0.0431,0.047,0.047,1), borderWidth = 1.5},self.drawNode)
   	self.tab_2_list_2 = cc.ui.UIListView.new {
	        --bgColor = cc.c4b(255, 38, 38, 100),
	        scrollbarImgV = "common/jiaob_lapit-05.png",
	        scrollbarImgVBg = "common/jiaob_lapit-04.png",
	        viewRect = cc.rect(97, 62, 678, 138),
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self.tabNode_2)

    display.newSprite("#bossImg_19.png")
    	:addTo(self.tabNode_2)
    	:pos(tmpSize.width/2+10,50)

   	selTab(1)
end

function worldBoss:refreshRankList()
	print("-----------------------------------")
	--排行榜
	local listview = self.tab_1_list
	listview:removeAllItems()
	local num = #self.rankInfo.rank
	for i=1,num do
		local _value = self.rankInfo.rank[i]
		local item = listview:newItem()
		local _size = cc.size(690,50) 
		local content = display.newNode()
		content:setContentSize(_size.width,_size.height)
		display.newSprite("#bossImg_18.png")
			:addTo(content)
			:align(display.CENTER_BOTTOM,_size.width/2,5)

		tmpNode = display.newTTFLabel({
								text = i,
				                size = 30,
				                color = cc.c3b(219,93,49)
						})
					:addTo(content)
					:align(display.CENTER,10,_size.height/2)

		tmpNode = display.newTTFLabel{text = "LV.",color = cc.c3b(201,154,82),size = 18}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+50,tmpNode:getPositionY())
		tmpNode:enableOutline(cc.c4f(201,154,82,1))
		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.lvl,color = cc.c3b(252,255,255),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = _value.name,size = 18,color = cc.c3b(186,175,149)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+60,tmpNode:getPositionY())

		display.newSprite("#bossImg_22.png")
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+246,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = "伤害量：",size = 18,color = cc.c3b(201,154,82)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+256,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.hurt,color = cc.c3b(196,84,68),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		item:addContent(content)
		item:setItemSize(_size.width,_size.height+2)
		listview:addItem(item)
	end
	listview:reload()

	do
		local _myRank = self.rankInfo.myRank
		local _value = {lvl = srv_userInfo.level,hurt = self.rankInfo.mine.wHurt,name = srv_userInfo.name}
		local tag = 1061
		if self.tabNode_1:getChildByTag(tag)~=nil then
			self.tabNode_1:removeChildByTag(tag)
		end

		local _size = cc.size(690,50) 
		local content = display.newNode()
				:addTo(self.tabNode_1,100,tag)
   				:align(display.CENTER_BOTTOM,_size.width/2+80,50)
		content:setContentSize(_size.width,_size.height)
		display.newSprite("#bossImg_18.png")
			:addTo(content)
			:align(display.CENTER_BOTTOM,_size.width/2,5)

		tmpNode = display.newTTFLabel({
								text = _myRank,
				                size = 30,
				                color = cc.c3b(219,93,49)
						})
					:addTo(content)
					:align(display.CENTER,30,_size.height/2)
		--ranklbl:setSkewX(5)

		tmpNode = display.newTTFLabel{text = "LV.",color = cc.c3b(201,154,82),size = 18}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+60,tmpNode:getPositionY())
		tmpNode:enableOutline(cc.c4f(201,154,82,1))
		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.lvl,color = cc.c3b(252,255,255),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = _value.name,size = 18,color = cc.c3b(186,175,149)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+60,tmpNode:getPositionY())

		display.newSprite("#bossImg_22.png")
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+246,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = "伤害量：",size = 18,color = cc.c3b(201,154,82)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+256,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.hurt,color = cc.c3b(196,84,68),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())
	
		self.myTotalHurt_2:setString(_value.hurt)
	end

	--我的伤害，队长挑战
	local listview = self.tab_2_list_1
	listview:removeAllItems()
	local leaderStr = self.rankInfo.mine.wHurtStr
	local _leaderArr = string.split(leaderStr,"|")
	local num = #_leaderArr
	for i=1,num do
		local item = listview:newItem()
		local _size = cc.size(670,40) 
		--local content = display.newScale9Sprite("common/common_Frame13.png", nil, nil,_size , cc.rect(20, 20, 4, 5))
		local content = display.newNode()
		content:setContentSize(_size.width,_size.height)
		display.newSprite("#bossImg_18.png")
			:addTo(content)
			:align(display.CENTER_BOTTOM,_size.width/2,5)
			:scale(0.95)

		tmpNode = display.newTTFLabel{text = "第"..i.."次",color = cc.c3b(201,154,82),size = 18}
			:addTo(content)
			:align(display.LEFT_CENTER,10,_size.height/2)

		tmpNode = display.newTTFLabel{text = srv_userInfo.name,size = 18,color = cc.c3b(186,175,149)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+100,tmpNode:getPositionY())

		display.newSprite("#bossImg_22.png")
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+246,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = "伤害量：",size = 18,color = cc.c3b(201,154,82)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+256,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _leaderArr[i],color = cc.c3b(196,84,68),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		item:addContent(content)
		item:setItemSize(_size.width,_size.height+2)
		listview:addItem(item)
	end
	listview:reload()

	--我的伤害，受邀挑战
	local listview = self.tab_2_list_2
	listview:removeAllItems()
	local invtArr = self.rankInfo.mine.invt
	local num = #invtArr
	for i=1,num do
		local _value = invtArr[i]
		local item = listview:newItem()
		local _size = cc.size(670,40) 
		--local content = display.newScale9Sprite("common/common_Frame13.png", nil, nil,_size , cc.rect(20, 20, 4, 5))
		local content = display.newNode()
		content:setContentSize(_size.width,_size.height)
		display.newSprite("#bossImg_18.png")
			:addTo(content)
			:align(display.CENTER_BOTTOM,_size.width/2,5)
			:scale(0.95)

		tmpNode = display.newTTFLabel{text = "LV.",color = cc.c3b(201,154,82),size = 18}
			:addTo(content)
			:align(display.LEFT_CENTER,10,_size.height/2)
		tmpNode:enableOutline(cc.c4f(201,154,82,1))
		display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.lvl,color = cc.c3b(252,255,255),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = _value.name,size = 18,color = cc.c3b(186,175,149)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+100,tmpNode:getPositionY())

		display.newSprite("#bossImg_22.png")
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+246,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{text = "伤害量：",size = 18,color = cc.c3b(201,154,82)}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+256,tmpNode:getPositionY())

		tmpNode = display.newTTFLabel{font = "fonts/slicker.ttf", text = _value.hurt,color = cc.c3b(196,84,68),size = 20}
			:addTo(content)
			:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())

		item:addContent(content)
		item:setItemSize(_size.width,_size.height+2)
		listview:addItem(item)
	end
	listview:reload()
end


function worldBoss:initLeftPanel()
	-- body
end

function worldBoss:refreshLeftPanel(  )
	if self.leftNode ~=nil then
		self.leftNode:removeSelf()
		self.leftNode = nil
	end
	self.leftNode = display.newNode()
			:addTo(self)

	for i=1,3 do
		local tmpPath = "#bossImg_09.png"
		
		tmpNode = display.newSprite(tmpPath)
					:addTo(self.leftNode,3-i)
					:align(display.LEFT_CENTER,0,display.height-240-(i-1)*192)
		tmpSize = tmpNode:getContentSize()
		
		local xxx_arr = {"自己","队友1","队友2"}
		display.newTTFLabel({text = xxx_arr[i],size = 25,color = cc.c3b(156,167,168)})
	                    :addTo(tmpNode)
	                    :align(display.CENTER,33, 20)
	    if self.teamData[i].name then
		    local name = self.teamData[i].name
		    if i==1 then
		    	name = self.teamData[i].name
		    end
		    display.newTTFLabel({text = name,size = 25,color = cc.c3b(39,43,53)})
		                    :addTo(tmpNode)
		                    :align(display.LEFT_CENTER,80, 20)
	    end
	    if self.teamData[i].fightNum then
		    local _fightNum = display.newBMFontLabel({text = self.teamData[i].fightNum, font = "fonts/num_4.fnt"})
					    :align(display.RIGHT_TOP, tmpSize.width-15,tmpSize.height-10)
					    :addTo(tmpNode) 
					    :scale(1.5)   

			display.newSprite("common2/com_strengthTag.png")
						:addTo(tmpNode)
						:align(display.RIGHT_CENTER, _fightNum:getPositionX()-_fightNum:getContentSize().width*1.5,tmpSize.height-25)
						:scale(1.2)
		end
		
		if self.teamData[i].carTptId~=nil and self.teamData[i].carTptId~=0 then
			--战车模型
			local _scale = 0.6
		    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=self.teamData[i].carTptId})
								:pos(tmpSize.width/2,tmpSize.height*0.25)
							    :addTo(tmpNode)
			SetModelParams(carModel, {fScale=_scale})
			if self.teamData[i].characterId==srv_userInfo.characterId then
				local btn = cc.ui.UIPushButton.new()
						:align(display.CENTER_BOTTOM,tmpSize.width/2,tmpSize.height*0.25)
						:addTo(tmpNode)
						:onButtonClicked(function ( ... )
								local carlist = g_CarListLayer.new({openTag=OpenBy_worldBoss})
										:addTo(self, 10,100)
							end)
				local rect = carModel:getBoundingBox()

				btn:setContentSize(200,120)
			end
			-- display.newScale9Sprite("common/common_Frame7.png", nil, nil, cc.size(100,60), cc.rect(20,20,10,10))
			-- 			        :addTo(tmpNode)
			-- 			        :align(display.CENTER_BOTTOM,tmpSize.width/2+25,tmpSize.height/2-35)
			-- 			        :red()
		elseif self.teamData[i].characterId==srv_userInfo.characterId then
			-- tmpNode = cc.ui.UIPushButton.new{normal = "#bossBtn_01_0.png",pressed = "#bossBtn_01_1.png"}
			-- 			:addTo(tmpNode)
			-- 			:align(display.CENTER,tmpSize.width/2+55,tmpSize.height/2)
			-- 			:onButtonClicked(function ( ... )
			-- 				local carlist = g_CarListLayer.new({openTag=OpenBy_worldBoss})
			-- 						:addTo(self, 10,100)
			-- 			end)
			-- tmpSize = tmpNode:getContentSize()
			-- display.newSprite("#bossTag_05.png")
			-- 			:addTo(tmpNode)
			-- 			:align(display.CENTER,0,0)
			local tip = display.newTTFLabel{text = "选择上阵战车",size = 30,color = cc.c3b(138,238,250)}
				:addTo(tmpNode,0,1000)
				:pos(tmpSize.width/2,tmpSize.height/2)

			cc.ui.UIPushButton.new()
					:addTo(tmpNode,0,1001)
					:pos(tmpSize.width/2,tmpSize.height/2)
					:onButtonClicked(function (  )
						local carlist = g_CarListLayer.new({openTag=OpenBy_worldBoss})
											:addTo(self, 10,100)
					end)
					:setContentSize(tip:getContentSize().width,tip:getContentSize().height*3)
		end
	end
	--定时刷新（避免因为推送出问题，而导致人员不齐的情况，只有第一次生效）
	self:scheduleRefreshMyTeam()
end

function worldBoss:initSecendPanel()
	self:refreshLeftPanel()
	self.startBtnBg = display.newSprite("#bossTag_02.png")
		:addTo(self)
		:align(display.CENTER,display.cx,display.cy)
		:hide()
	self.startBtn = cc.ui.UIPushButton.new{normal = "#bossBtn_08.png"}
			:addTo(self.startBtnBg)
			:align(display.CENTER,self.startBtnBg:getContentSize().width/2,self.startBtnBg:getContentSize().height/2)
			:onButtonPressed(function(event)
				event.target:setScale(0.985)
				end)
			:onButtonRelease(function(event)
				event.target:setScale(1.0)
				end)
			:onButtonClicked(function ( ... )
				print("self.m_matchProcessType",self.m_matchProcessType)
				self:ReqEmbattleInfo()
			end)
	display.newSprite("#bossTag_09.png")
		:addTo(self.startBtn)
	--邀请列表
	tmpNode = display.newScale9Sprite("common2/com2_Img_6.png",nil,nil,cc.size(420,500),cc.rect(40,40,1,1))
				:addTo(self)
				:align(display.CENTER,display.cx-50,display.cy-25)
				:opacity(0)
				-- :hide()
    self.friendListBg_2 = tmpNode
	tmpSize = tmpNode:getContentSize()

	self.friendList_2 = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 0, 0, 50),
        viewRect = cc.rect(10, 10, 420, 480),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "#bossImg_10.png",
        }
        :addTo(tmpNode)

    tmpNode = cc.ui.UIPushButton.new{normal = "#bossBtn_05.png"}
    			:addTo(tmpNode)
    			:align(display.CENTER,tmpSize.width/2,-40)
    			:onButtonPressed(function(event)
					event.target:setScale(0.985)
					end)
				:onButtonRelease(function(event)
					event.target:setScale(1.0)
					end)
    			:onButtonClicked(function ()
    				if table.nums(self.myHelpList) >0 then
    					if self.askCold~=0 then
							showTips(self.askCold.."秒内不可重复发出邀请")
							return
						else
							if table.nums(self.myHelpList)<5 then
	    						showMessageBox("邀请人数不满5位，30秒内不可重复邀请，是否确定？",function ( ... )
	    							self:sendHelpMsg()
	    						end)
	    					else
			    				self:sendHelpMsg()
			    			end
						end
    					
	    			else
	    				showTips("请至少选择一个军团成员")
	    			end
    			end)
   
    display.newTTFLabel{text = "发送邀请",color = cc.c3b(14,17,13),size = 30}
    			:addTo(tmpNode)

    --聊天
	tmpSize = cc.size(480,575)
	local chatBg = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,tmpSize,cc.rect(119, 127, 1, 1))
 	    :addTo(self)
 	    :align(display.RIGHT_BOTTOM,display.width+23,5)
 	    --:hide()

 	local inputBg = display.newScale9Sprite("#bossImg_11.png",nil, nil,cc.size(310,54.5),cc.rect(20, 20, 1, 1))
 			:addTo(chatBg,1)
 			:pos(170,50)

 	self.chatInput = cc.ui.UIInput.new({image = "EditBoxBg.png",size = cc.size(310, 40)})
		    :addTo(inputBg)
			:align(display.CENTER,155,27.2)
    self.chatInput:setPlaceHolder("请输入聊天内容")
    self.chatInput:setPlaceholderFontSize(20)
    self.chatInput:setFontSize(20)
    self.chatInput:setEnabled(false)

	cc.ui.UIPushButton.new{normal = "common2/com2_Btn_1_up.png",pressed = "common2/com2_Btn_1_down.png"}
			:addTo(chatBg)
			:align(display.CENTER,390,50)
			:onButtonClicked(function ()
				self:sendChatMsg()
			end)
	-- display.newSprite("#bossTag_07.png")
	-- 			:addTo(chatBg)
	-- 		:align(display.CENTER,390,50)
	display.newTTFLabel{text = "发送",size = 23}
		:addTo(chatBg)
		:align(display.CENTER,390,47)
	

    self.chatListView = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 0, 0, 200),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        viewRect = cc.rect(30, 100, 420, 420),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(chatBg)
    self:refreshChatList()

end

function worldBoss:refreshChatList()
	self:performWithDelay(function ()
		self.chatListView:removeAllItems()
		local _height = 0
		for i=1,#chatMsgList do
			local chatMsg = chatMsgList[i]
			local _size
			local item = self.chatListView:newItem()
			local content = display.newNode()
			

			local head = getCHeadBox(chatMsg.senderTmpId) 
		        :addTo(content)

	        if chatMsg.senderTmpId==10000 then
		        _size = cc.size(420,75)
	    	else
		        _size = cc.size(420,100)
	    	end
	    	_height = _height+_size.height
	    	head:pos(50,_size.height/2)
	    	content:setContentSize(_size.width,_size.height)

			local _label = display.newTTFLabel{text = "     "..chatMsg.msg,size = 20}
						:addTo(content)
						:align(display.LEFT_BOTTOM,100,10)
			local _singleLineHeight = _label:getContentSize().height
			_label:setWidth(_size.width-113)
			_label:setLineHeight(_singleLineHeight)
			local tmpHeight = _label:getContentSize().height
			_size = cc.size(_size.width,_size.height+tmpHeight-_singleLineHeight)
			_label:pos(100,10)
			content:setContentSize(_size.width,_size.height)

			head:pos(50,_size.height/2)

	    	if chatMsg.senderTmpId==10000 then
	    		display.newTTFLabel{text = chatMsg.senderName,size = 20,color = cc.c3b(152,167,168)}
				    	:addTo(content)
					    :align(display.LEFT_CENTER,100,_size.height-26)
	    	else
	    		display.newTTFLabel{font = "fonts/slicker.ttf",text = "LV:"..chatMsg.senderLevel,size = 23,color = cc.c3b(138,238,250)}
		        	:addTo(content)
		        	:align(display.LEFT_CENTER,100,_size.height-26)

		        local img_V = display.newSprite("common/common_V.png")
				    :addTo(content)
				    :align(display.LEFT_CENTER,165,_size.height-26)
				    :scale(0.66)

			    local vipNum = cc.LabelAtlas:_create()
			                        :addTo(content)
				    				:align(display.LEFT_CENTER,185,_size.height-26)
			                        :scale(0.66)
			    vipNum:initWithString(chatMsg.senderVip,
			            "common/common_Num3.png",
			            22,
			            29,
			            string.byte(0))
			    local nameLbl = display.newTTFLabel{text = chatMsg.senderName,size = 20,color = cc.c3b(152,167,168)}
				    	:addTo(content)
					    :align(display.LEFT_CENTER,220,_size.height-26)
	    	end

	    	display.newTTFLabel{text = chatMsg.time,color = cc.c3b(152,167,168),size = 20}
	    		:addTo(content)
	    		:align(display.RIGHT_CENTER,_size.width-20,_size.height-26)

			local line = display.newSprite("#bossImg_15.png")
			        :addTo(content)
			        :pos(_size.width/2, 5)
			line:setScaleX(2.05)

			

			item:addContent(content)
            item:setItemSize(_size.width, _size.height)
            self.chatListView:addItem(item)
		end
		self.chatListView:reload()
		local posY = 420-_height
		if _height>420 then
			posY = 0
		end
		local pt,xx = self.chatListView:getContentPos()
		print("----------pt",pt,"xx",xx,"_height",_height)
		self.chatListView:setContentPos(0,posY)
	end,0.1)
end

function worldBoss:initFirstPanel()
	self._firstNode = display.newNode()
				:addTo(self,2)
				-- :hide()
	display.newLayer() --display.newColorLayer(cc.c4b(200, 52, 58, 0))
		:addTo(self._firstNode,0,502)
	self.bg_up = display.newSprite("#bossImg_01.png")
			:addTo(self._firstNode)
			:align(display.CENTER_BOTTOM,display.cx,display.cy)
	self.bg_down = display.newSprite("#bossImg_01.png")
			:addTo(self._firstNode)
			:align(display.CENTER_BOTTOM,display.cx,display.cy)
	self.bg_down:setScaleY(-1)

	local tmpNode = display.newSprite("#bossImg_02.png")
    			:addTo(self,3)
    			:pos(display.cx+18,display.height-55)
    local tmpSize = tmpNode:getContentSize()

    self.titleImg = display.newSprite("#bossTag_08.png")
    		:addTo(tmpNode)
    		:align(display.CENTER,tmpSize.width/2,tmpSize.height*0.62)
    		-- :hide()
    self.countTag = display.newSprite("#bossImg_04.png")
    		:addTo(tmpNode)
    		:align(display.CENTER,tmpSize.width*0.32,tmpSize.height*0.63)
    		:hide()
    self.countDownLabel = display.newTTFLabel({
    						--font = "fonts/slicker.ttf", 
	                        text = "19",
	                        size = 36,
	                        color = cc.c3b(138,238,250)
	                        })
	                        :addTo(self.countTag)
	                        :align(display.LEFT_CENTER,40, 13)
	-- display.newTTFLabel{text = "内选定战车",size = 30,color = cc.c3b(138,238,250)}
	-- 			:addTo(self.countTag)
	-- 			:align(display.LEFT_CENTER,120, 15)
	self.tagMatching = display.newTTFLabel{text = "",size = 30,color = cc.c3b(138,238,250)}
							:addTo(tmpNode)
							:align(display.CENTER_BOTTOM,tmpSize.width/2, 5)
							--:hide()
	display.newTTFLabel{text = "今日剩余次数：",size = 26,color = cc.c3b(138,238,250)}
							:addTo(tmpNode)
							:align(display.LEFT_CENTER,tmpSize.width/2-100, 23)
	self.restCountLabel = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
	                        text = self.m_restCount,
	                        size = 30,color = cc.c3b(138,238,250)
	                        })
	                        :addTo(tmpNode)
	                        :align(display.LEFT_CENTER,tmpSize.width/2+70, 23)

	self:initRule()
	local btnPt = tmpNode:convertToWorldSpace(cc.p(tmpSize.width*0.15,tmpSize.height*0.33))
	local _btn = cc.ui.UIPushButton.new{normal = "#bossBtn_06.png"}
				:addTo(self,2)
				:align(display.CENTER,btnPt.x,btnPt.y)
				:onButtonPressed(function(event)
					event.target:setPositionY(btnPt.y-2)
					end)
				:onButtonRelease(function(event)
					event.target:setPositionY(btnPt.y)
					end)
				:onButtonClicked(function (event)
					self:ReqRankInfo()
				end)
	display.newTTFLabel({
	                        text = "排名",
	                        size = 25,
	                        })
				:addTo(_btn)
				:pos(0,-8)
				:opacity(180)
	btnPt = tmpNode:convertToWorldSpace(cc.p(tmpSize.width*0.85,tmpSize.height*0.33))
	_btn = cc.ui.UIPushButton.new{normal = "#bossBtn_07.png"}
				:addTo(self,2)
				:align(display.CENTER,btnPt.x,btnPt.y)
				:onButtonPressed(function(event)
					event.target:setPositionY(btnPt.y-2)
					end)
				:onButtonRelease(function(event)
					event.target:setPositionY(btnPt.y)
					end)
				:onButtonClicked(function (event)
					self.ruleMask:show()
				end)
	display.newTTFLabel({
	                        text = "规则",
	                        size = 25,
	                        })
				:addTo(_btn)
				:pos(0,-8)
				:opacity(180)

	local function _BtnClick(event)
		print("-----------bIsBossClose",bIsBossClose)
		-- if bIsBossClose and (not g_isBanShu) then
		-- 	showTips("现在不是挑战时间")
		-- 	return
		-- end
		if self.m_restCount<=0 then
			showTips("今日挑战次数已经用完")
			return
		end
		if self.m_matchProcessType == matchProcessType.teamerLegionSuccess or self.m_matchProcessType == matchProcessType.teamerLegionIng then
			showTips("当前为队友，不能另行组队")
			return
		end
        local _btn = event.target
        if _btn==self.btnMatch_1 then
        end
        

        local _btn = event.target
        
        local function confirm()
            local index
            if _btn==self.btnMatch_1 then   --随机匹配
                index = 1
            else                            --军团匹配
                index = 2
            end
            local _bol = false  --true表示匹配完成，false表示匹配未完成
            if self.m_matchProcessType == matchProcessType.legionSuccess or self.m_matchProcessType == matchProcessType.randSuccess then
                _bol = true
            end
            if _bol then
                local a,b = self:getTeamerNum()
                if b<3 then
                    showTips("有队员还没登记车辆，不能开始游戏")
                else
                    if self.m_matchProcessType == matchProcessType.randSuccess then
                        stopCountDown(self.timeHandle)
                        local layer = EmbattleScene.new({BattleType_WorldBoss, 0,self.formatInfo})
                        local scene = cc.Director:getInstance():getRunningScene()
                        scene:addChild(layer, 61,111)
                        self.chatInput:setEnabled(false)
                        FightSceneEnterType = EnterTypeList_2.WORLDBOSS_ENTER
                    else
                        self:ReqEmbattleInfo()
                    end
                end
                
            else
                if index ==1 then
                    self:ReqRandomMatch()
                else
                    self:ReqLegionMemberInfo()
                    
                end
            end
        end

        if _btn==self.btnMatch_1 then
            showMessageBox("确认是否进行随机匹配?确认后扣除1次挑战次数",confirm)
        else
            confirm()
        end
	end

	self.imgMatch_1_0 = display.newSprite("#bossTag_01.png")
				:addTo(self._firstNode,1)
				:align(display.CENTER,display.cx-305,display.cy)
	self.btnMatch_1 = cc.ui.UIPushButton.new{normal = "#bossBtn_02.png"}
								:addTo(self._firstNode,1)
								:align(display.CENTER,display.cx-305,display.cy)
								:onButtonClicked(_BtnClick)
								:onButtonPressed(function(event)
									event.target:setScale(0.985)
									end)
								:onButtonRelease(function(event)
									event.target:setScale(1.0)
									end)
	self.imgMatch_1 = display.newSprite("#bossTag_03.png")
				:addTo(self._firstNode,1)
				:align(display.CENTER,display.cx-305,display.cy)
	
	self.imgMatch_2_0 = display.newSprite("#bossTag_02.png")
				:addTo(self._firstNode,1)
				:align(display.CENTER,display.cx+315,display.cy)
	
	self.btnMatch_2 = cc.ui.UIPushButton.new{normal = "#bossBtn_03.png"}
								:addTo(self._firstNode,1)
								:align(display.CENTER,display.cx+315,display.cy)
								:onButtonClicked(_BtnClick)
								:onButtonPressed(function(event)
									event.target:setScale(0.985)
									end)
								:onButtonRelease(function(event)
									event.target:setScale(1.0)
									end)
	self.imgMatch_2 = display.newSprite("#bossTag_04.png")
				:addTo(self._firstNode,1)
				:align(display.CENTER,display.cx+315,display.cy)
	

	self.invoteMask = UIMasklayer.new()
    		:addTo(self._firstNode,2)
    		:hide()
	--受邀列表
	tmpNode = display.newScale9Sprite("common2/com2_Img_6.png",nil,nil,cc.size(420,570),cc.rect(40,40,1,1))
				:addTo(self._firstNode,2)
				:opacity(0)
				:align(display.RIGHT_BOTTOM,display.width+500,30)
	self.friendListBg_1 = tmpNode
	self.invoteMask:addHinder(tmpNode)
	self.invoteMask:setTouchCallback(function ()
		self.invoteMask:hide()

		self.friendListBg_1:pos(display.width,30)
		local _action = transition.sequence{cc.MoveBy:create(0.2,cc.p(500,0)),cc.Hide:create(),}
		self.friendListBg_1:runAction(_action)
	end)

				
	tmpSize = tmpNode:getContentSize()

	self.friendList_1 = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 0, 0, 200),
        viewRect = cc.rect(0, 0, 420, 570),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(tmpNode)

    

	self.helpTagBtn = cc.ui.UIPushButton.new{normal = "SingleImg/worldBoss/bossBtn_01.png"}
			:addTo(self._firstNode)
			:align(display.RIGHT_TOP,display.width-10,display.height-10)
			:onButtonPressed(function(event)
				event.target:setScale(0.985)
				end)
			:onButtonRelease(function(event)
				event.target:setScale(1.0)
				end)
			:onButtonClicked(function (event)
				self.invoteMask:show()
				self.friendListBg_1:pos(display.width+500,30)
				local _action = transition.sequence{cc.Show:create(),cc.MoveBy:create(0.2,cc.p(-500,0))}
				self.friendListBg_1:runAction(_action)
			end)
			:hide()

	display.newSprite("SingleImg/worldBoss/bossTag_06.png")
				:addTo(self.helpTagBtn)
				:pos(-110,100)

	tmpNode = display.newSprite("common2/com_tankBg.png")
				:addTo(self._firstNode)
				:align(display.CENTER_BOTTOM,display.cx,40)
	tmpSize = tmpNode:getContentSize()
	self.myCarNode = tmpNode
	
	local tip = display.newTTFLabel{text = "选择上阵战车",size = 30,color = cc.c3b(138,238,250)}
				:addTo(tmpNode,0,1000)
				:pos(tmpSize.width/2,tmpSize.height/2-30)

	cc.ui.UIPushButton.new()
			:addTo(tmpNode,0,1001)
			:pos(tmpSize.width/2,tmpSize.height/2-30)
			:onButtonClicked(function (  )
                print("2222222222222")
				local carlist = g_CarListLayer.new({openTag=OpenBy_worldBoss})
									:addTo(self, 10,100)
			end)
			:setContentSize(tip:getContentSize().width,tip:getContentSize().height*3)

	display.newTTFLabel{text = "滴答滴答滴答的",size = 25,color = cc.c3b(156,167,168)}
				:addTo(tmpNode,0,1002)
				:align(display.CENTER_TOP,tmpSize.width/2,tmpSize.height-8)

	tmpNode = display.newNode()
			:addTo(tmpNode,0,1003)
			:pos(tmpSize.width/2,tmpSize.height/2)
			--:hide()
	
	local numLbl = display.newBMFontLabel({text = "0", font = "fonts/num_4.fnt"})
					    :align(display.RIGHT_TOP, tmpSize.width/2-30,60)
					    :addTo(tmpNode,0,101) 
					    :scale(1.5)
	display.newSprite("common2/com_strengthTag.png")
				:addTo(tmpNode,0,102)
				:align(display.RIGHT_TOP, numLbl:getPositionX()-numLbl:getContentSize().width*1.5 ,58)
				:scale(1.2)

	local tag_ = display.newScale9Sprite("#bossImg_07.png",nil,nil,cc.size(254,17),cc.rect(10,8,128,6))
		:addTo(tmpNode)
		:align(display.LEFT_TOP,-tmpSize.width*0.34,-tmpSize.height*0.2)
	tag_:setScale(-1)
	tag_ = display.newScale9Sprite("#bossImg_07.png",nil,nil,cc.size(120,16),cc.rect(10,8,128,6))
		:addTo(tmpNode)
		:align(display.LEFT_TOP,-tmpSize.width*0.43,-tmpSize.height*0.21)
	tag_:setScaleX(-1)
	tag_ = display.newScale9Sprite("#bossImg_07.png",nil,nil,cc.size(254,17),cc.rect(10,8,128,6))
		:addTo(tmpNode)
		:align(display.LEFT_TOP,tmpSize.width*0.35,-tmpSize.height*0.2)
	tag_:setScaleY(-1)
	tag_ = display.newScale9Sprite("#bossImg_07.png",nil,nil,cc.size(120,16),cc.rect(10,8,128,6))
		:addTo(tmpNode)
		:align(display.LEFT_TOP,tmpSize.width*0.44,-tmpSize.height*0.21)
	tag_:setScale(1)

	self:refreshMyCar()

end


function worldBoss:refreshMyCar()
	-- self.m_strength
	-- self.m_restCount
	-- self.m_carTptId

	local tipLbl = self.myCarNode:getChildByTag(1000)		--选择上阵战车
	local tmpSize = self.myCarNode:getContentSize()
	local btn = self.myCarNode:getChildByTag(1001)		--按钮
	if self.m_carTptId~=0 then 
		tipLbl:hide()
		btn:hide()

		self.myCarNode:removeChildByTag(1010)
		self.myCarNode:removeChildByTag(1011)

		local _scale = 0.6
	    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=self.m_carTptId})
							:pos(tmpSize.width/2,tmpSize.height*0.12)
						    :addTo(self.myCarNode,10,1010)
		SetModelParams(carModel, {fScale=_scale})
			local btn = cc.ui.UIPushButton.new()
					:align(display.CENTER_BOTTOM,tmpSize.width/2,tmpSize.height*0.12)
					:addTo(self.myCarNode,10,1011)
					:onButtonClicked(function ()
							local carlist = g_CarListLayer.new({openTag=OpenBy_worldBoss})
									:addTo(self, 10,100)
						end)
			local rect = carModel:getBoundingBox()

			btn:setContentSize(200,120)
	end

	tmpNode = self.myCarNode:getChildByTag(1002)		--名字
	tmpNode:setString(srv_userInfo.name)

	tmpNode = self.myCarNode:getChildByTag(1003)		--节点
	local numLbl = tmpNode:getChildByTag(101)			--战力
	local tag = tmpNode:getChildByTag(102)			    --战力
	numLbl:setString(self.m_strength)
	tag:setPositionX(numLbl:getPositionX()-numLbl:getContentSize().width-40)
end

--1：播放随机匹配动画，2：播放军团匹配动画,3:接受请求
function worldBoss:playUIAnimation(tag)
	local _frameInterval = 1.0/24
	self._firstNode:getChildByTag(502):hide()
	if tag==1 then
		local frames = display.newFrames("bossUI_1_%02d.png", 0, 7)
		local animation = display.newAnimation(frames, _frameInterval)
		local animate = cc.Animate:create(animation)
		local spr = display.newSprite("#bossUI_1_00.png")
				:addTo(self,3)
				:align(display.CENTER,display.cx-305,display.cy)
				:scale(2)
		local function callRemove()
			spr:removeSelf()
		end
		spr:runAction(transition.sequence{cc.Hide:create(),cc.DelayTime:create(3*_frameInterval),cc.Show:create(),animate,cc.CallFunc:create(callRemove)})
		
		local sq = transition.sequence{
								cc.Place:create(cc.p(display.cx-305,display.cy)),
								cc.FadeIn:create(0),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy)),cc.RotateBy:create(20*_frameInterval,100)),
								cc.RotateBy:create(30*_frameInterval*1000,130*1000),
							}
		self.imgMatch_1_0:runAction(sq)
		
		sq = transition.sequence{
								cc.Place:create(cc.p(display.cx-305,display.cy)),
								cc.FadeIn:create(0),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy)),cc.RotateBy:create(20*_frameInterval,-100)),
								cc.RotateBy:create(30*_frameInterval*1000,-130*1000),
							}
		self.btnMatch_1:runAction(sq)

		sq = transition.sequence{
								cc.Place:create(cc.p(display.cx-305,display.cy)),
								cc.FadeIn:create(0),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy))),
								cc.DelayTime:create(30*_frameInterval),
							}
		self.imgMatch_1:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.imgMatch_2_0:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.btnMatch_2:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.imgMatch_2:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(0*_frameInterval),cc.Place:create(cc.p(display.cx,40)),
				cc.MoveBy:create(2*_frameInterval,cc.p(0,40)),cc.MoveBy:create(20*_frameInterval,cc.p(0,-display.width*0.5))}
		self.myCarNode:runAction(sq)

	elseif tag==2 then
		local frames = display.newFrames("bossUI_1_%02d.png", 0, 7)
		local animation = display.newAnimation(frames, _frameInterval)
		local animate = cc.Animate:create(animation)
		local spr = display.newSprite("#bossUI_1_00.png")
				:addTo(self,3)
				:align(display.CENTER,display.cx+305,display.cy)
				:scale(2)
		local function callRemove()
			spr:removeSelf()
		end
		spr:runAction(transition.sequence{cc.Hide:create(),cc.DelayTime:create(3*_frameInterval),cc.Show:create(),animate,cc.CallFunc:create(callRemove)})
		
		frames = display.newFrames("bossUI_2_%02d.png", 0, 20)
		animation = display.newAnimation(frames, _frameInterval)
		animate = cc.Animate:create(animation)
		local spr2 = display.newSprite("#bossUI_2_00.png")
				:addTo(self,2)
				:align(display.CENTER,display.cx,display.cy)
				:scale(4)
		local function callRemove()
			spr2:removeSelf()
		end
		spr2:runAction(transition.sequence{cc.Hide:create(),cc.DelayTime:create(26*_frameInterval),cc.Show:create(),animate,cc.CallFunc:create(callRemove)})


		local sq = transition.sequence{
								cc.Place:create(cc.p(display.cx+305,display.cy)),
								cc.FadeIn:create(0),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy)),cc.RotateBy:create(20*_frameInterval,100)),
								cc.RotateBy:create(10*_frameInterval,65),
								cc.Spawn:create(cc.RotateBy:create(20*_frameInterval,130),cc.FadeOut:create(20*_frameInterval))
							}
		self.imgMatch_2_0:runAction(sq)

		sq = transition.sequence{
								cc.Place:create(cc.p(display.cx+305,display.cy)),
								cc.FadeIn:create(0),
								cc.CallFunc:create(function ( ... )
									self.btnMatch_2:setTouchEnabled(true)
								end),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy)),cc.RotateBy:create(20*_frameInterval,-100)),
								cc.RotateBy:create(10*_frameInterval,65),
								cc.CallFunc:create(function ( ... )
									self.btnMatch_2:setTouchEnabled(false)
								end),
								cc.Spawn:create(cc.RotateBy:create(20*_frameInterval,130),cc.FadeOut:create(20*_frameInterval))
							}
		self.btnMatch_2:runAction(sq)

		sq = transition.sequence{
								cc.Place:create(cc.p(display.cx+305,display.cy)),
								cc.FadeIn:create(0),
								cc.ScaleTo:create(2*_frameInterval,0.95),
								cc.ScaleTo:create(4*_frameInterval,1.15),
								cc.ScaleTo:create(0*_frameInterval,1),
								cc.Spawn:create(cc.MoveTo:create(20*_frameInterval,cc.p(display.cx,display.cy))),
								cc.DelayTime:create(10*_frameInterval),
								cc.FadeOut:create(20*_frameInterval)
							}
		self.imgMatch_2:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.imgMatch_1_0:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.btnMatch_1:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.imgMatch_1:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(0*_frameInterval),cc.Place:create(cc.p(display.cx,40)),
				cc.MoveBy:create(2*_frameInterval,cc.p(0,40)),cc.MoveBy:create(20*_frameInterval,cc.p(0,-display.width*0.5))}
		self.myCarNode:runAction(sq)


		sq = transition.sequence{cc.Place:create(cc.p(display.cx,display.cy)),cc.DelayTime:create(20*_frameInterval),cc.MoveBy:create(4*_frameInterval,cc.p(0,-20)),cc.MoveBy:create(40*_frameInterval,cc.p(0,display.height*0.6))}
		self.bg_up:runAction(sq)
		sq = transition.sequence{cc.Place:create(cc.p(display.cx,display.cy)),cc.DelayTime:create(20*_frameInterval),cc.MoveBy:create(4*_frameInterval,cc.p(0,20)),cc.MoveBy:create(40*_frameInterval,cc.p(0,-display.height*0.6))}
		self.bg_down:runAction(sq)
	elseif tag==3 then		
		
		local sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.imgMatch_2_0:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.btnMatch_2:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx+305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(-30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(display.width*0.5,0))}
		self.imgMatch_2:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(0*_frameInterval),cc.Place:create(cc.p(display.cx,40)),
				cc.MoveBy:create(2*_frameInterval,cc.p(0,40)),cc.MoveBy:create(20*_frameInterval,cc.p(0,-display.width*0.5))}
		self.myCarNode:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.imgMatch_1_0:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.btnMatch_1:runAction(sq)
		sq = transition.sequence{cc.DelayTime:create(4*_frameInterval),cc.Place:create(cc.p(display.cx-305,display.cy)),
				cc.MoveBy:create(2*_frameInterval,cc.p(30,0)),cc.MoveBy:create(20*_frameInterval,cc.p(-display.width*0.5,0))}
		self.imgMatch_1:runAction(sq)

		sq = transition.sequence{cc.DelayTime:create(0*_frameInterval),cc.Place:create(cc.p(display.cx,40)),
				cc.MoveBy:create(2*_frameInterval,cc.p(0,40)),cc.MoveBy:create(20*_frameInterval,cc.p(0,-display.width*0.5))}
		self.myCarNode:runAction(sq)


		sq = transition.sequence{cc.Place:create(cc.p(display.cx,display.cy)),cc.DelayTime:create(20*_frameInterval),cc.MoveBy:create(4*_frameInterval,cc.p(0,-20)),cc.MoveBy:create(40*_frameInterval,cc.p(0,display.height*0.6))}
		self.bg_up:runAction(sq)
		sq = transition.sequence{cc.Place:create(cc.p(display.cx,display.cy)),cc.DelayTime:create(20*_frameInterval),cc.MoveBy:create(4*_frameInterval,cc.p(0,20)),cc.MoveBy:create(40*_frameInterval,cc.p(0,-display.height*0.6))}
		self.bg_down:runAction(sq)
	end

end


function worldBoss:initRightPanel()

end

function worldBoss:refreshFriendList(tag)
self:performWithDelay(function ()
	local _listview
		if tag==1 then 		--受邀列表
			_listview = self.friendList_1
			_listview:removeAllItems()
			if table.nums(self.m_helpAskList)==0 then
				self.friendListBg_1:hide()
				self.helpTagBtn:hide()
			end
			for k,v in pairs(self.m_helpAskList) do
				local _preTeamer = v
				
				local item = _listview:newItem()
				local content = display.newSprite("#bossImg_08.png")
				local _size = content:getContentSize()
				local _tmpId = _preTeamer.icon
				-- display.newSprite("Head/headman_"..memberData[_tmpId].resId..".png")
				-- 			:addTo(content)
				-- 			:scale(0.85)
				-- 			:align(display.LEFT_CENTER,8,_size.height/2)

				local _lvlLbl = display.newTTFLabel{font = "fonts/slicker.ttf",text = "LV:".._preTeamer.lvl,size = 23,color = cc.c3b(138,238,250)}
		        	:addTo(content)
		        	:align(display.LEFT_CENTER,20,_size.height-20)

		        local img_V = display.newSprite("common/common_V.png")
				    :addTo(content)
				    :align(display.LEFT_CENTER,100,_size.height-20)
				    :scale(0.66)

			    local vipNum = cc.LabelAtlas:_create()
			                        :addTo(content)
				    				:align(display.LEFT_CENTER,125,_size.height-20)
			                        :scale(0.66)
			    vipNum:initWithString(_preTeamer.vip,
			            "common/common_Num3.png",
			            22,
			            29,
			            string.byte(0))
			    local nameLbl = display.newTTFLabel{text = _preTeamer.name,size = 20,color = cc.c3b(152,167,168)}
				    	:addTo(content)
					    :align(display.LEFT_CENTER,180,_size.height-20)



				local fightNumTag = display.newSprite("common2/com_strengthTag.png")
							:addTo(content)
							:align(display.LEFT_CENTER,20,_size.height/2+5)
							:scale(1.15)

				local _fightNum = _preTeamer.strength
				display.newBMFontLabel({text = _fightNum, font = "fonts/num_4.fnt"})
				    :align(display.LEFT_CENTER, fightNumTag:getPositionX()+fightNumTag:getContentSize().width+7,fightNumTag:getPositionY()-6)
				    :addTo(content) 
				    :scale(1.2)

				local btn = cc.ui.UIPushButton.new({normal = "#bossBtn_04.png"})
						:addTo(content)
						:pos(_size.width-48,_size.height/2-30)
						:onButtonPressed(function(event)
							event.target:setScale(0.95)
							end)
						:onButtonRelease(function(event)
							event.target:setScale(1.0)
							end)
						:onButtonClicked(function (event)
							print("_preTeamer.cId:  ",_preTeamer.cId)
							if self.m_matchProcessType == matchProcessType.none then
								self:ReqAcceptTheHelpAsk(_preTeamer.cId)
							else
								showTips("只能接受一个人的邀请")
							end
						end)
				btn:setTouchSwallowEnabled(false)

				display.newTTFLabel{text = "接受",size = 28,color = cc.c3b(14,17,13)}
							:addTo(btn)

				item:addContent(content)
	            item:setItemSize(_size.width,_size.height+2)
	            _listview:addItem(item)
			end
			_listview:reload()
		elseif tag==2 then 	--邀请列表
			_listview = self.friendList_2
			_listview:removeAllItems()
			for k,v in pairs(self.m_legionMembers) do
				local _preTeamer = v
				local _size = cc.size(395,100)
				local item = _listview:newItem()
				local content = display.newSprite("#bossImg_14.png")

				local _btn = cc.ui.UIPushButton.new()
						:addTo(content,10)
						:pos(_size.width/2,_size.height/2)
						:onButtonClicked(function (event)
							print("-------xxx",v.name)
							local tag_1 = event.target:getChildByTag(101)
							local tag_2 = event.target:getChildByTag(102)
							if tag_1:isVisible() and tag_2:isVisible() then     --取消选择
								tag_1:hide()
								tag_2:hide()
								self.myHelpList[_preTeamer.cId] = nil
							else 												--选择
								if table.nums(self.myHelpList)==5 then
				            		showTips("一次最多邀请五位军团成员")
				            		return
				            	end
				            	tag_1:show()
								tag_2:show()
					            self.myHelpList[_preTeamer.cId] = 1
							end
						end)
				_btn:setContentSize(_size.width,_size.height)
				_btn:setTouchSwallowEnabled(false)
				display.newSprite("common2/com_hook.png")
					:addTo(_btn,0,101)
					:align(display.RIGHT_CENTER,_size.width-5,_size.height/2)
					:hide()
				display.newSprite("#bossTag_05.png")
					:addTo(_btn,0,102)
					:align(display.LEF_TOP,32,_size.height-25)
					:hide()

				local _tmpId = _preTeamer.icon
				local headBox = display.newSprite("common2/com2_Img_5.png")
							:addTo(content)
							:align(display.LEFT_CENTER,13,_size.height/2+3)
							:scale(1.13)
				display.newSprite("Head/headman_"..memberData[_tmpId].resId..".png")
							:addTo(headBox)
							:scale(0.65)
							:align(display.CENTER,headBox:getContentSize().width/2,headBox:getContentSize().height/2)

				display.newTTFLabel{text = "等级：",
	                        size = 17,color = cc.c3b(161,174,175)}
	                :addTo(content)
					:align(display.LEFT_CENTER,110,_size.height-40)
				local _level = _preTeamer.lvl
				local _lvlLbl = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
	                        text = _level,
	                        size = 17,
	                        --color = cc.c3b(161,174,175)
	                        })
					:addTo(content)
					:align(display.LEFT_CENTER,153,_size.height-40)

				local _name = _preTeamer.name
				display.newTTFLabel({
	                        text = _name,
	                        size = 17,
	                        color = cc.c3b(136,238,255)
	                        })
					:addTo(content)
					:align(display.LEFT_CENTER,110,_size.height-18)

				local fightNumTag = display.newSprite("common2/com_strengthTag.png")
							:addTo(content)
							:align(display.LEFT_CENTER,105,32)
							:scale(1.2)

				local _fightNum = _preTeamer.strength
				display.newBMFontLabel({text = _fightNum, font = "fonts/num_4.fnt"})
				    :align(display.LEFT_CENTER, fightNumTag:getPositionX()+fightNumTag:getContentSize().width+10,fightNumTag:getPositionY()-6)
				    :addTo(content)
				    :scale(1.3)

				item:addContent(content)
	            item:setItemSize(_size.width,_size.height+2)
	            _listview:addItem(item)
			end
			_listview:reload()
		end
end,0.1)
		
end

function worldBoss:onEnter()
	MainSceneEnterType = EnterTypeList.NORMAL_ENTER
	self:ReqInitInfo()
end

function worldBoss:onExit()
	worldBossInstance = nil
	display.removeSpriteFramesWithFile("Image/UIWorldBoss.plist", "Image/UIWorldBoss.png")
	display.removeSpriteFramesWithFile("Image/bossUIEffect.plist", "Image/bossUIEffect.png")
	scheduler.unscheduleGlobal(self._refreshHandle)
end
--请求初始化信息
function worldBoss:ReqInitInfo()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_INIT, self, self.OnInitInfoRet)
end
--初始化信息返回
function worldBoss:OnInitInfoRet(cmd)
	endLoading()
	if 1==cmd.result then
		self.m_helpAskList = cmd.data.aplInfo  --向我发送援助请求的人的列表

		-- self.m_helpAskList = {}
		-- for i=1 ,10 do
		-- 	self.m_helpAskList[#self.m_helpAskList+1] = {name = "少时诵诗书",icon = 10333,lvl = 98,vip = 14,cId = 1234567,strength = 96154}
		-- end

		if table.nums(self.m_helpAskList)>0 then  
			self.helpTagBtn:show()
			self:refreshFriendList(1)
		end
		self.m_strength = cmd.data.wStrength
		self.m_restCount = cmd.data.wCnt
		self.m_carTptId = cmd.data.carTmpId

		self.teamData[1] = {characterId = srv_userInfo.characterId,icon = cmd.data.icon,name = srv_userInfo.name,fightNum = self.m_strength,carTptId = self.m_carTptId}
		self.teamData[2] = {}
		self.teamData[3] = {}
		--self:initLeftPanel()
		self.restCountLabel:setString(self.m_restCount)
		self:refreshMyCar()
		self:refreshLeftPanel()
	else
		showTips(cmd.msg)
	end
end

--请求登记车辆
-- carSrvId    
-- isSet    是否在组队
-- cIdList  队友的characterId [1000221,1000331]，非组队可以不传
function worldBoss:ReqUpdateCar(_carSrvId)
	print("_carSrvId: ".._carSrvId)
	local tabMsg = {carId = _carSrvId}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_CHANGE_CAR, nil, nil)
end
--车辆登记返回(推送消息)
function worldBoss:OnUpdateCarRet(cmd)
	if 1==cmd.result then
		print("cmd.data.cId: "..cmd.data.cId)
		if cmd.data.cId==srv_userInfo.characterId then --如果是自己请求返回，关闭战车列表
			if self:getChildByTag(100)~=nil then
				self:removeChildByTag(100)
			end
			self.titleImg:show()
			self.countTag:hide()
			if self.countDownLabel then
		    	self.countDownLabel:setString("")
		    end
		    -- if self.tagMatching then
		    -- 	self.tagMatching:setString("")
		    -- end
			stopCountDown(self.timeHandle_120)
		end

		local index = nil
        printTable(self.teamData)
		for i=1,#self.teamData do
			if self.teamData[i].characterId==cmd.data.cId then
				index = i
				break
			end
		end
		assert(index,"车辆登记结果有问题，找不到对应characterId")
		self.teamData[index].characterId = cmd.data.cId
		self.teamData[index].carTptId = cmd.data.tmpId
		self.teamData[index].fightNum = cmd.data.strength
		self.m_carTptId = cmd.data.tmpId
		self.m_strength = cmd.data.strength
		self:refreshLeftPanel()
		self:refreshMyCar()
        printTable(self.teamData)

		if self.m_matchProcessType == matchProcessType.legionSuccess then
			local _teamerNum , _carNum = self:getTeamerNum()
			if _carNum==3 then --人和车都到位了，开启90秒定时器，计时结束自动进入布阵
				self.friendListBg_2:hide()
				self.startBtnBg:show()
				local function _call(count,event_type)
					if self.titleImg ==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."秒后进入布阵")
				    end
				    -- if self.tagMatching then
				    -- 	self.tagMatching:setString("")
				    -- end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqEmbattleInfo()
				    	self.titleImg:show()
						self.countTag:hide()
				    end
			    end
			    stopCountDown(self.timeHandle_90)
			    showTips("请在倒计时结束之前开始游戏")
				self.timeHandle_90 = startCountDown(90,1,_call,false)
			end
		end
	else
		showTips(cmd.msg)
	end
end
--发送聊天消息
function worldBoss:sendChatMsg()
	if self:getTeamerNum()<3 then
		-- showTips("队伍成员不足3位，不能发送聊天")
		-- return
	end
	local _msg = self.chatInput:getText()
	local tabMsg = {type=5,msg = _msg}
    m_socket:SendRequest(json.encode(tabMsg), CMD_SENT_CHATMSG, nil, nil)
end
--有人发送聊天消息
function worldBoss:onChatMsgRetPush(cmd)
	if 1==cmd.result then
		local _time = string.sub(cmd.data.time,12,string.len(cmd.data.time))
		print("_time",_time)
		chatMsgList[#chatMsgList+1] = {senderName = cmd.data.name,msg = cmd.data.msg,senderVip = cmd.data.vip,
						senderLevel = cmd.data.lvl,time = _time,senderTmpId = cmd.data.tmpId}
		self:refreshChatList()
	else

	end
end
--请求随机匹配
function worldBoss:ReqRandomMatch()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_RAND_MATCH, self, self.OnRandomMatchRet)
end
--随机匹配消息返回
function worldBoss:OnRandomMatchRet(cmd)
	endLoading()
	if 1==cmd.result then
		self.formatInfo = cmd--布阵信息
		local arr = cmd.data.members
		for i=1,3 do
			local _teamer = arr[i]
			self.teamData[i] = {characterId = _teamer.cId,icon = _teamer.icon,name = _teamer.name,fightNum = _teamer.strength,carTptId = _teamer.carTptId}
		end
		self.m_restCount = self.m_restCount - 1
		--self:initLeftPanel()

		local function _call(count,event_type)
			if self.titleImg==nil then
				return
			end
			self.titleImg:hide()
			self.countTag:show()
			if self.countDownLabel then
		    	self.countDownLabel:setString("倒数"..count.."秒")
		    end
		    -- if self.tagMatching then
		    -- 	self.tagMatching:setString("匹配成功")
		    -- end
			if event_type == 1 or event_type ==2 then
		    	
		    elseif event_type==3 then
		    	local layer = EmbattleScene.new({BattleType_WorldBoss, 0,self.formatInfo})
		        local scene = cc.Director:getInstance():getRunningScene()
		        scene:addChild(layer, 61,111)
		        self.chatInput:setEnabled(false)
		        FightSceneEnterType = EnterTypeList_2.WORLDBOSS_ENTER
		        self.titleImg:show()
				self.countTag:hide()
		    end
	    end
	    self.timeHandle = startCountDown(5,1,_call)
	    printTable(self.timeHandle)

	    self.m_matchProcessType = matchProcessType.randSuccess

	    self:playUIAnimation(1)
	 --    self.btnMatch_1:setLocalZOrder(1)
		-- self.btnMatch_2:setLocalZOrder(0)
		-- self.btnMatch_1:runAction(cc.MoveTo:create(0.5,cc.p(display.cx+28,display.cy+80)))
		-- self.imgMatch_1:setSpriteFrame("bossTag_02.png")
		-- self.btnMatch_2:runAction(cc.Spawn:create{cc.MoveTo:create(0.5,cc.p(display.cx+28,display.cy+80)),cc.FadeOut:create(0.4)})
	else
		showTips(cmd.msg)
	end
    print("匹配消息返回")
end

--请求军团成员援助
function worldBoss:sendHelpMsg()
	if self.askCold~=0 then
		showTips(self.askCold.."秒内不可重复发出邀请")
		return
	end
	startLoading()
	local str = ""
	for k,v in pairs(self.myHelpList) do
		str = str..k.."|"
	end
	str = string.sub(str,1,string.len(str)-1)
	local tabMsg = {invtCIdStr = str}
	m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_MATCH_REQUEST, self, self.sendHelpMsgRet)
end

function worldBoss:sendHelpMsgRet(cmd)
	endLoading()	
	if 1==cmd.result then
		local tagSign = {}
		for k,v in pairs(self.m_legionMembers) do
			local _preTeamer = v
			if self.myHelpList[_preTeamer.cId]==1 then
				tagSign[#tagSign+1] = k
				print("-----------------ccccc k: "..k)
			end
			
		end

		for i=1,#tagSign do
			local _index = tagSign[i]
			printTable(self.m_legionMembers[_index])
			self.hasInvited[self.m_legionMembers[_index].cId] = self.m_legionMembers[_index]

			chatMsgList[#chatMsgList+1] = {senderName = "系统消息",msg = "正在邀请"..self.m_legionMembers[_index].name,time = os.date("%H:%M:%S"),senderTmpId = 10000}
			self:refreshChatList()

			self.m_legionMembers[_index] = nil
		end
		self.chatInput:setEnabled(true)
		self:refreshFriendList(2)
		self.myHelpList = {}

		self.askCold = 30

		

		local function Ontime(count,eventName)
			if self.m_matchProcessType == matchProcessType.legionSuccess then
				return
			end
			if self.titleImg==nil then
				return
			end
			self.titleImg:hide()
			self.countTag:show()
			if self.countDownLabel then
		    	self.countDownLabel:setString(count.."后继续邀请")
		    end
		    -- if self.tagMatching then
		    -- 	self.tagMatching:setString("请等待匹配")
		    -- end
			self.askCold = count
			if eventName == 3 then
				self.askCold = 0
				
				self.isRefresh = true
				self:ReqLegionMemberInfo()

			end
		end
		self.timeHandle_cold = startCountDown(30,1,Ontime,false)
	else
		showTips(cmd.msg)
	end
end
--世界BOSS收到组队请求
function worldBoss:receiveHelpMsgPush(cmd)
	if 1==cmd.result then
		table.insert(self.m_helpAskList,cmd.data)
		self:refreshFriendList(1)
		if self.m_matchProcessType == matchProcessType.none then
			self.invoteMask:show()
			self.friendListBg_1:pos(display.width+500,30)
			local _action = transition.sequence{cc.Show:create(),cc.MoveBy:create(0.2,cc.p(-500,0))}
			self.friendListBg_1:runAction(_action)
		end
	else
		showTips(cmd.msg)
	end
end

--有人回应了援助请求
function worldBoss:OnHelpMsgPushRet(cmd)
	if 1==cmd.result then
		local _teamerNum , _carNum = self:getTeamerNum()
		if _teamerNum==3 then
			return
		end
		local _teamer = cmd.data
		for i=1,3 do
			if self.teamData[i].characterId==nil then
				self.teamData[i] = {characterId = _teamer.cId,icon = _teamer.icon,name = _teamer.name,fightNum = _teamer.strength,carTptId = _teamer.carTmpId}
				print("i: "..i)
				break
			end
		end

		chatMsgList[#chatMsgList+1] = {senderName = "系统消息",msg = _teamer.name.."接受了邀请",time = os.date("%H:%M:%S"),senderTmpId = 10000}
			self:refreshChatList()

		local _teamerNum , _carNum = self:getTeamerNum()
		if self.m_matchProcessType == matchProcessType.legionIng and _teamerNum==3 then  --队长，从两个人变成3个人
			self.m_matchProcessType = matchProcessType.legionSuccess
			if _carNum==3 then --人和车都到位了，开启90秒定时器，计时结束自动进入布阵
				self.friendListBg_2:hide()
				self.startBtnBg:show()
				local function _call(count,event_type)
					if self.titleImg ==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."秒后进入布阵")
				    end
				    -- if self.tagMatching then
				    -- 	self.tagMatching:setString("")
				    -- end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqEmbattleInfo()
				    	self.titleImg:show()
						self.countTag:hide()
				    end
			    end
			    stopCountDown(self.timeHandle_90)
			    showTips("请在倒计时结束之前开始游戏")
				self.timeHandle_90 = startCountDown(90,1,_call,false)
			else
				--如果是我没有登记战车，开启120秒定时器，计时结束自动解散队伍
				if self.m_carTptId==0 then
					local function _call(count,event_type)
						if self.titleImg==nil then
							return
						end
						self.titleImg:hide()
						self.countTag:show()
						if self.countDownLabel then
					    	self.countDownLabel:setString(count.."内登记战车")
					    end
					    -- if self.tagMatching then
					    -- 	self.tagMatching:setString("请登记战车")
					    -- end
						if event_type == 1 or event_type ==2 then
					    	
					    elseif event_type==3 then
					    	self:ReqExitTeam()
					    	self:removeSelf()
					    end
				    end
				    stopCountDown(self.timeHandle_120)
				    showTips("请在倒计时结束之前选定战车")
					self.timeHandle_120 = startCountDown(120,1,_call,false)
				end
			end
		elseif self.m_matchProcessType == matchProcessType.teamerLegionIng and _teamerNum==3 then  --队员，从两个人变成3个人
			self.m_matchProcessType = matchProcessType.teamerLegionSuccess
			--如果我没有登记战车，120秒后自动脱对
			if self.m_carTptId==0 then
				local function _call(count,event_type)
					if self.titleImg==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."内登记战车")
				    end
				    -- if self.tagMatching then
					   --  	self.tagMatching:setString("请登记战车")
					   --  end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqExitTeam()
				    	self:removeSelf()
				    end
			    end
			    stopCountDown(self.timeHandle_120)
			    showTips("请在倒计时结束之前选定战车")
				self.timeHandle_120 = startCountDown(120,1,_call,false)
			end
		end
		--self:initLeftPanel()
		self:refreshLeftPanel()
	else

	end
end

--接受军团成员的援助请求
function worldBoss:ReqAcceptTheHelpAsk(captain)
	startLoading()
	self.curCattain = captain
	local tabMsg = {cId = captain}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_AGREE_ASK, self, self.OnAcceptTheHelpAskRet)
end

--接受请求的返回
function worldBoss:OnAcceptTheHelpAskRet(cmd)
	endLoading()
	if 1==cmd.result then
		local team1 = self.teamData[1]
		local team2 = self.teamData[2]
		local team3 = self.teamData[3]
		self.teamData = {}
		local arr = cmd.data
		for i=1,#arr do
			local _teamer = arr[i]
			self.teamData[i] = {characterId = _teamer.cId,icon = _teamer.icon,name = _teamer.name,fightNum = _teamer.strength,carTptId = _teamer.carTmpId}
			print("--------xx",_teamer.name)
		end
		if team1.characterId~=nil and team1.characterId~=0 then
			self.teamData[#self.teamData+1] = team1
		end
		if team2.characterId~=nil and team2.characterId~=0 then
			self.teamData[#self.teamData+1] = team2
		end
		if team3.characterId~=nil and team3.characterId~=0 then
			self.teamData[#self.teamData+1] = team3
		end

		for i=1,3 do
			if self.teamData[i]==nil then
				self.teamData[i]={}
			end
		end

		-- self:initLeftPanel()
		self:refreshLeftPanel()

		--我自己接受了请求
		local _teamerNum , _carNum = self:getTeamerNum()
		if _teamerNum==3 then  --我是最后一个接受请求的，
			self.m_matchProcessType = matchProcessType.teamerLegionSuccess
			--如果我没有登记战车，120秒后自动脱对
			if self.m_carTptId==0 then
				local function _call(count,event_type)
					if self.titleImg==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."内选定战车")
				    end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqExitTeam()
				    	self:removeSelf()
				    end
			    end
			    stopCountDown(self.timeHandle_120)
			    showTips("请在倒计时结束之前选定战车")
				self.timeHandle_120 = startCountDown(120,1,_call,false)
			end
		else
			self.m_matchProcessType = matchProcessType.teamerLegionIng 
		end

		for k,v in pairs(self.m_helpAskList) do
			if self.curCattain == v.cId then
				self.m_helpAskList[k] = nil
			end
		end
		self:refreshFriendList(1)
		self.friendListBg_1:hide()
		self.friendListBg_2:hide()

		self.invoteMask:hide()
		self.friendListBg_1:pos(display.width,30)
		local _action = transition.sequence{cc.Show:create(),cc.MoveBy:create(0.2,cc.p(500,0))}
		self.friendListBg_1:runAction(_action)
		self:playUIAnimation(3)
		self.chatInput:setEnabled(true)

	elseif -2 == cmd.result then
		showTips("该邀请已经过期")
		for k,v in pairs(self.m_helpAskList) do
			if self.curCattain == v.cId then
				self.m_helpAskList[k] = nil
			end
		end
		self:refreshFriendList(1)
	else
		showTips(cmd.msg)
	end
end

--请求排名信息
function worldBoss:ReqRankInfo()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_RANK_INFO, self, self.OnRankInfoRet)
end

function worldBoss:OnRankInfoRet(cmd)
	endLoading()
	if 1==cmd.result then
		self.rankInfo = cmd.data
		self.rankNode:show()
		self:refreshRankList()
	else
		showTips(cmd.msg)
	end
end

function worldBoss:ReqLegionMemberInfo()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_LEGION_MEMBER_INFO, self, self.OnLegionMemberInfoRet)
end

function worldBoss:OnLegionMemberInfoRet(cmd)
	endLoading()
	if 1==cmd.result then
        self.enterMatch = true
		self.m_legionMembers = {}
		if self.isRefresh then
			local function bIsTeanerInMyTeam(cId)
				local ret = false
				for i=1,3 do
					if self.teamData[i] and self.teamData[i].characterId==cId then
						ret = true
						break
					end
				end
				return ret
			end
			for k,v in pairs(cmd.data) do
				if not bIsTeanerInMyTeam(v.cId) then
					self.m_legionMembers[v.cId] = v
				end
			end

			self:refreshFriendList(2)
			self.titleImg:show()
			self.countTag:hide()

			self.isRefresh = false
		else
			self.m_matchProcessType = matchProcessType.legionIng
			for k,v in pairs(cmd.data) do
				self.m_legionMembers[v.cId] = v
			end

			self.helpTagBtn:hide()
			self.friendListBg_1:hide()
			self:refreshFriendList(2)
			self:playUIAnimation(2)
			
			self.chatInput:setEnabled(true)
		end
	else
		showTips(cmd.msg)
	end
end
--请求退出队伍
function worldBoss:ReqExitTeam()
	if self.m_matchProcessType == matchProcessType.none then
		return
	end
	print("退出世界BOSS队伍！")
	startLoading()
	local _isCap = 1
	if self.m_matchProcessType == matchProcessType.teamerLegionSuccess or self.m_matchProcessType == matchProcessType.teamerLegionIng then
		_isCap = 0
	end
	local tabMsg = {isCap = _isCap}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_EXIT_TEAM, self, self.OnExitTeamRet)
end

function worldBoss:OnExitTeamRet(cmd)
	endLoading()
	if 1==cmd.result then
		--do nothing
	else
		showTips(cmd.msg)
	end
end

function worldBoss:resetMyInfo()
	--组队数据清零
	self.m_matchProcessType = matchProcessType.none
	chatMsgList = {}
	self:refreshChatList()
	self._firstNode:getChildByTag(502):show()
	self:ReqInitInfo()
	
	self.bg_up:stopAllActions()
	self.bg_down:stopAllActions()
	self.imgMatch_1_0:stopAllActions()
	self.btnMatch_1:stopAllActions()
	self.imgMatch_1:stopAllActions()
	self.imgMatch_2_0:stopAllActions()
	self.btnMatch_2:stopAllActions()
	self.imgMatch_2:stopAllActions()

	self.bg_up:pos(display.cx,display.cy)
					:show()
				   	:opacity(255)
	self.bg_down:pos(display.cx,display.cy)
					:show()
				   	:opacity(255)


	self.imgMatch_1_0:pos(display.cx-305,display.cy)
					:show()
				   	:opacity(255)
	self.btnMatch_1:pos(display.cx-305,display.cy)
					:show()
				   	:opacity(255)
								
	self.imgMatch_1:pos(display.cx-305,display.cy)
					:show()
				   	:opacity(255)
	
	self.imgMatch_2_0:pos(display.cx+315,display.cy)
					:show()
				   	:opacity(255)
	
	self.btnMatch_2:pos(display.cx+315,display.cy)
					:show()
				   	:opacity(255)
								
	self.imgMatch_2:pos(display.cx+315,display.cy)
					:show()
				   	:opacity(255)

	self.myCarNode:pos(display.cx,40)

	self.countDownLabel:setString("")
	self.tagMatching:setString("")

	self.titleImg:show()
	self.countTag:hide()

	self.chatInput:setEnabled(false)
end

--有人退出了组队
function worldBoss:OnExitTeamPush(cmd)
	if 1==cmd.result then
		local _characterId = cmd.data.cId --退出的人的characterId
		local _isCap = cmd.data.isCap --是否为队长
		if _isCap==1 then  --队长解散队伍（身为队长，退出界面）
			showMessageBox("队长已解散队伍",nil,nil,function ()
				print("nothing")
			end)
			stopCountDown(self.timeHandle_90)
			stopCountDown(self.timeHandle_120)
			self:resetMyInfo()
		elseif _isCap==0 then  --有队员退出队伍
			self.friendListBg_2:show()
			self.startBtnBg:hide()
			for k,v in pairs(self.teamData) do
				if v.characterId == _characterId then
					showTips(v.name.."退出队伍")
					self.teamData[k] = {}
				end
			end
			stopCountDown(self.timeHandle_90)
			stopCountDown(self.timeHandle_120)
			local _teamerNum , _carNum = self:getTeamerNum()
			if self.m_matchProcessType == matchProcessType.legionSuccess and _teamerNum<3 then  --队长，有人脱对，3人变成两人
				self.m_matchProcessType = matchProcessType.legionIng
			elseif self.m_matchProcessType == matchProcessType.teamerLegionSuccess and _teamerNum<3 then --队员，有人脱对，3人变成两人
				self.m_matchProcessType = matchProcessType.teamerLegionIng
			end
			self._refreshHandle = nil
			self:refreshLeftPanel()
		end
	else
		showTips(cmd.msg)
	end
end

--请求布阵信息
function worldBoss:ReqEmbattleInfo()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_BOSS_EMBATLE_INFO, self, self.OnEmbattleInfoRet)
end

function worldBoss:OnEmbattleInfoRet(cmd)
	endLoading()
	if 1==cmd.result then
		self.m_restCount = self.m_restCount - 1
		self.restCountLabel:setString(self.m_restCount)
		local layer = EmbattleScene.new({BattleType_WorldBoss, 0,cmd})
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer, 61,111)
        self.chatInput:setEnabled(false)
        FightSceneEnterType = EnterTypeList_2.WORLDBOSS_ENTER
	else
		showTips(cmd.msg)
	end
end

--队员可以自由活动了
function worldBoss:OnHelpEndPush(cmd)
	showMessageBox("此次助战已圆满完成",nil,nil,function ()
				print("nothing")
			end)
	self:resetMyInfo()
end

--由于推送有可能出现问题，在这里主动请求当前最新战斗序列。
function worldBoss:scheduleRefreshMyTeam()
	local function ReqMyTeamer()
        if not self.enterMatch then
            return
        end
		local _teamerNum = 0
		for i=1,3 do
			if self.teamData and self.teamData[i] and self.teamData[i].characterId~=nil then
				_teamerNum = _teamerNum + 1
			end
		end
		--如果当前人数已经满了3人，就关闭这个定时器
		if _teamerNum==3 then
			scheduler.unscheduleGlobal(self._refreshHandle)
			self._refreshHandle = -1
		end
		local tabMsg = {}
		m_socket:SendRequest(json.encode(tabMsg), CMD_BOOSS_REFRESH_MYTEAM, self, self.OnMyTeamerRet)
	end
	--避免重复开定时器
	if self._refreshHandle==nil then
		self._refreshHandle = scheduler.scheduleGlobal(function ( ... )
			ReqMyTeamer()
		end, 5)
	end
end

function worldBoss:OnMyTeamerRet(cmd)
	if 1==cmd.result then
		local _teamerNum , _carNum = self:getTeamerNum()
		if _teamerNum==3 then
			return
		end
		self.teamData = {}
		local arr = cmd.data
		for i=1,#arr do
			local _teamer = arr[i]
			self.teamData[i] = {characterId = _teamer.cId,icon = _teamer.icon,name = _teamer.name,fightNum = _teamer.strength,carTptId = _teamer.carTmpId}
			print("--------xx",_teamer.name)
		end

		local _teamerNum = 3
		for i=1,3 do
			if self.teamData[i]==nil then
				self.teamData[i]={}
				_teamerNum = _teamerNum - 1
			end
		end
		if _teamerNum==0 then
			return
		end
		
		local function sortFunc(val_1,val_2)
			--首先把空白的排在后面
			if val_1.characterId~=nil and val_2.characterId==nil then
				return true
			end
			if val_1.characterId==nil and val_2.characterId~=nil then
				return false
			end
			--然后把自己排在前面
			if val_1.characterId==srv_userInfo.characterId then
				return true
			end
			if val_2.characterId==srv_userInfo.characterId then
				return false
			end
			return true
		end
		table.sort( self.teamData, sortFunc)
		print("\n\n\n\n\n\n\n\nself.teamData")
		printTable(self.teamData)
		self:refreshLeftPanel()

		local _teamerNum , _carNum = self:getTeamerNum()
		if self.m_matchProcessType == matchProcessType.legionIng and _teamerNum==3 then  --队长，从两个人变成3个人
			self.m_matchProcessType = matchProcessType.legionSuccess
			if _carNum==3 then --人和车都到位了，开启90秒定时器，计时结束自动进入布阵
				self.friendListBg_2:hide()
				self.startBtnBg:show()
				local function _call(count,event_type)
					if self.titleImg ==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."秒后进入布阵")
				    end
				    -- if self.tagMatching then
				    -- 	self.tagMatching:setString("")
				    -- end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqEmbattleInfo()
				    	self.titleImg:show()
						self.countTag:hide()
				    end
			    end
			    stopCountDown(self.timeHandle_90)
			    showTips("请在倒计时结束之前开始游戏")
				self.timeHandle_90 = startCountDown(90,1,_call,false)
			else
				--如果是我没有登记战车，开启120秒定时器，计时结束自动解散队伍
				if self.m_carTptId==0 then
					local function _call(count,event_type)
						if self.titleImg==nil then
							return
						end
						self.titleImg:hide()
						self.countTag:show()
						if self.countDownLabel then
					    	self.countDownLabel:setString(count.."内登记战车")
					    end
					    -- if self.tagMatching then
					    -- 	self.tagMatching:setString("请登记战车")
					    -- end
						if event_type == 1 or event_type ==2 then
					    	
					    elseif event_type==3 then
					    	self:ReqExitTeam()
					    	self:removeSelf()
					    end
				    end
				    stopCountDown(self.timeHandle_120)
				    showTips("请在倒计时结束之前选定战车")
					self.timeHandle_120 = startCountDown(120,1,_call,false)
				end
			end
		elseif self.m_matchProcessType == matchProcessType.teamerLegionIng and _teamerNum==3 then  --队员，从两个人变成3个人
			self.m_matchProcessType = matchProcessType.teamerLegionSuccess
			--如果我没有登记战车，120秒后自动脱对
			if self.m_carTptId==0 then
				local function _call(count,event_type)
					if self.titleImg==nil then
						return
					end
					self.titleImg:hide()
					self.countTag:show()
					if self.countDownLabel then
				    	self.countDownLabel:setString(count.."内登记战车")
				    end
				    -- if self.tagMatching then
					   --  	self.tagMatching:setString("请登记战车")
					   --  end
					if event_type == 1 or event_type ==2 then
				    	
				    elseif event_type==3 then
				    	self:ReqExitTeam()
				    	self:removeSelf()
				    end
			    end
			    stopCountDown(self.timeHandle_120)
			    showTips("请在倒计时结束之前选定战车")
				self.timeHandle_120 = startCountDown(120,1,_call,false)
			end
		end
	else
		showTips(cmd.msg)
	end
end

return worldBoss
