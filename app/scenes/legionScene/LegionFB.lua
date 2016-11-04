local LegionFB=class("LegionFB", function()
    return display.newNode()
    end)

local areaIdx = nil

local ruleText = "1.团队副本从XX区开始，通关普通模式才可以进入\n2.团队副本的开启与重置都消耗一定的军团活跃值\n3.军团成员可以轮流挑战同一个副本，同一时间只允许一个人挑战\n4.关卡怪物血量不回复\n5.每个成员每天对每个大区有2次挑战机会，每次最多可以打通一个关卡，同一关卡内的进度递进，剩余时间不重置\n6.布阵时间不能超过1分钟，战斗时间不能超过3分钟\n7.每天凌晨3点至7点为休息时间，无法进行挑战\n8.挑战获得的功勋可以在军团商店进行购物\n9.每个大区通关时，全体成员都会获得一定的通关功勋奖励\n10.每次副本都记录每个成员贡献的总伤害，排名靠前的成员通关时能获得更多的功勋\n11.每个关卡完成最后一击的成员通关时会获得额外奖励\n12.团队副本掉落的战利品归军团所有，军团成员可以申请排队依次获得战利品\n13.每个玩家同时只能申请一件战利品，取消申请或者申请其他的战利品都将离开原队列，原排名不保留\n14.系统分配战利品时间为每天的10:00~23:00之间的整点时刻\n15.在战利品掉落之后才加入军团的成员暂时无法获得之前的战利品，系统在分配时自动跳过队列中加入军团时间过短的成员 \n16.成员的善/恶值、军团等级、军团职位等都会对团本战斗属性有一定加成影响\n"

function LegionFB:ctor()
	self.masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    self.masklayer:setOnTouchEndedEvent(func)

    --返回按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self.masklayer)
    :align(display.LEFT_TOP, 0, display.height )
    :onButtonClicked(function(event)
        self:removeSelf()
        end)


	--副本规则
	local menu = cc.ui.UIPushButton.new("#legion_img7.png")
	:addTo(self.masklayer)
	:pos(display.width - 270,display.height/2 + 260)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "?", size = 27, color = cc.c3b(142, 190, 192)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		self:addFBRuleBox()
		end)
	--分配记录
	local menu = cc.ui.UIPushButton.new({normal = "#legion_img7.png"},{scale9 = true})
	:addTo(self.masklayer)
    :pos(display.width - 130,display.height/2 + 260)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "分配记录", size = 27, color = cc.c3b(142, 190, 192)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		startLoading()
		local sendData={}
	    m_socket:SendRequest(json.encode(sendData), CMD_LEGION_RECORD, self, self.onLegionRecord)
		end)
    menu:setButtonSize(150, 73)
	-- --底板
	-- local bottomPart = display.newScale9Sprite("common/common_Frame7.png",msgBox:getContentSize().width/2, 
 --        msgBox:getContentSize().height/2-45,
 --        cc.size(945, 405),cc.rect(10,10,30,30))
 --    :addTo(msgBox)

    self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(40, display.height/2-270, display.width-80, 480),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(self.masklayer)
        self.listView:setBounceable(false)

    self:updateListView()
end
function LegionFB:updateListView()
	self.listView:removeAllItems()
    -- printTable(legionFBData)
	 for i,value in pairs(legionFBData) do
	 	print(i)
        local item = self.listView:newItem()
        local content = display.newNode()

        local itemBar = display.newSprite()
        :addTo(content)
        local frames
        if value.percent~=-1 then
            frames = display.newSpriteFrame("legion_img1.png")
        else
            frames = display.newSpriteFrame("legion_img2.png")
        end
        itemBar:setSpriteFrame(frames)
        local tmpsize = itemBar:getContentSize()
        
        --大区名字
        local areaName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 33})
        :addTo(itemBar)
        :align(display.CENTER, tmpsize.width/2, tmpsize.height - 30)
        areaName:setColor(cc.c3b(143, 18, 24))
        areaName:setString(areaData[value.areaId].name)

        --消耗活跃值
        function costActValue()
            cc.ui.UILabel.new({UILabelType = 2, text = "消耗", size = 25, color= cc.c3b(151, 190, 204)})
            :addTo(itemBar)
            :pos(50,120)
            display.newSprite("#legion_img29.png")
            :addTo(itemBar)
            :pos(120,120)

            cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = areaData[value.areaId].active, size = 25, color= cc.c3b(255, 241, 0)})
            :addTo(itemBar)
            :pos(140,120)
        end
        --副本进度
        function FBProgress()
            local progress1 = display.newSprite("#legion_img14.png")
            :addTo(itemBar)
            :pos(tmpsize.width/2, 120)

            local progress2 = cc.ui.UILoadingBar.new({image = "#legion_img15.png",viewRect = cc.rect(0,0,230,23)})
            :addTo(progress1)
            progress2:setPercent(value.percent)

            cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = value.percent.."%", size = 22})
            :addTo(progress1)
            :align(display.CENTER, progress1:getContentSize().width/2, progress1:getContentSize().height/2-2)
        end
        --boss头像
        function bossHead(bLock)
            if areaData[value.areaId].bossId==0 then
                return
            end

            local resName =  monsterData[areaData[value.areaId].bossId].resId
            local boss = display.newSprite("monster/boss_"..resName..".png")
            :addTo(itemBar)
            :align(display.CENTER, itemBar:getContentSize().width/2, itemBar:getContentSize().height/2+50)

            -- local pos = {cc.p(240,110),cc.p(130,80),cc.p(180,-30),cc.p(180,-30)}
            -- local clippingRect = display.newClippingRectangleNode(cc.rect(37, 150,207,400))
            -- :addTo(itemBar)

            -- local manager = ccs.ArmatureDataManager:getInstance()
            -- local resName =  monsterData[areaData[value.areaId].bossId].resId
            -- -- print("resName:"..resName)
            -- manager:removeArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
            -- manager:addArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
            -- local boss = ccs.Armature:create("Monster_"..resName.."_")
            -- :addTo(clippingRect)
            -- :align(display.CENTER_BOTTOM, pos[i].x, pos[i].y)
            -- :scale(areaData[value.areaId].bossScale*1.2)
            -- if i==2 then
            --     boss:scale(areaData[value.areaId].bossScale*1.2*0.5)
            -- end
            -- boss:getAnimation():play("Standby")
            -- boss:getAnimation():gotoAndPlay(0)

            --上锁
            if bLock then
                display.newSprite("bounty/bounty2_img1.png")
                :addTo(itemBar, 0, 100)
                :pos(itemBar:getContentSize().width/2, itemBar:getContentSize().height/2+40)
                :setRotation(34)

                display.newSprite("bounty/bounty2_img1.png")
                :addTo(itemBar, 0, 101)
                :pos(itemBar:getContentSize().width/2, itemBar:getContentSize().height/2+40)
                :setRotation(-34)

                display.newSprite("#legion_img52.png")
                :addTo(itemBar, 0, 102)
                :pos(itemBar:getContentSize().width/2, itemBar:getContentSize().height/2+40)
            end
        end
		--挑战
        local menu,nodes
        local text
        if value.percent==-1 then
            text = "开启"
            menu,nodes = createGreenBt(text, 1.2)
            costActValue()
            if srv_userInfo.level>=areaData[value.areaId].level and canAreaEnter(value.areaId, 1) then --通关至该大区了
                bossHead(true)
            else
                -- bossHead(true)
                display.newSprite("bounty/bounty2_img3.png")
                :addTo(itemBar)
                :pos(itemBar:getContentSize().width/2, itemBar:getContentSize().height/2+50)
            end
        elseif value.percent==100 then
            text = "重置"
            menu,nodes = createYellowBt(text, 1.2)
            FBProgress()
            bossHead()
        else
            text = "挑战"
            menu = createYellowBt(text, 1.2)
            FBProgress()
            bossHead()
        end
		menu:addTo(itemBar)
		menu:pos(tmpsize.width/2,55)
		menu:onButtonClicked(function(event)
            self.curItemBar = itemBar

            if srv_userInfo.level<areaData[value.areaId].level then
                showTips("等级不足进入该大区")
                return
            elseif value.percent==-1 or value.percent==100 then
                areaIdx = i
                startLoading()
                local sendData={}
                sendData["areaId"]=value.areaId
                m_socket:SendRequest(json.encode(sendData), CMD_START_FB, self, self.onStartLegionFB)
            else
                areaIdx = i
                startLoading()
                local sendData={}
                sendData["areaId"]=value.areaId
                m_socket:SendRequest(json.encode(sendData), CMD_LEGION_BLOCK, self, self.onLegionBlockResult)
            end
            
			end)
        menu.grayState_ = true
        menu:getButtonLabel(disabled):setColor(cc.c3b(62, 58, 57))

        if myLegionInfo.rank==0 then --统帅和队长方可开启
            if value.percent==-1 or value.percent==100 then
                setLabelColor(menu, nodes, cc.c3b(200, 200, 200))
                menu:setButtonEnabled(false)
            end
        end
		

    	item:addContent(content)
        item:setItemSize((display.width-80)/4,480)
        self.listView:addItem(item)
    end
    self.listView:reload()
end
--副本规则
function LegionFB:addFBRuleBox()
	local masklayer =  UIMasklayer.new()
    :addTo(borderNode:getParent(),11)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    local msgBox = display.newSprite("SingleImg/messageBox/messageBox.png",display.cx, display.cy)
	:addTo(masklayer)
    masklayer:addHinder(msgBox)
    local tmpsize = msgBox:getContentSize()

    --标题
    cc.ui.UILabel.new({UILabelType = 2, text = "副本规则", size = 35, color = cc.c3b(255, 192, 67)})
    :addTo(msgBox)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height - 40)
	
    local content = cc.ui.UILabel.new({UILabelType = 2, text = ruleText, size = 23, color = cc.c3b(103, 111, 119)})
    :pos(60, 35)
    content:setWidth(610)

    local scrollNode = cc.ui.UIScrollView.new({viewRect = cc.rect(60, 20, 615, 370)})
        :setDirection(cc.ui.UIScrollView.DIRECTION_VERTICAL)
        :addTo(msgBox)
        :addScrollNode(content)

end
--分配记录
function LegionFB:addRcordBox()
	local masklayer =  UIMasklayer.new()
    :addTo(borderNode:getParent(),11)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    local msgBox = display.newSprite("SingleImg/messageBox/messageBox2.png",display.cx, display.cy)
	:addTo(masklayer)
    masklayer:addHinder(msgBox)
    local tmpsize = msgBox:getContentSize()

    --标题
    cc.ui.UILabel.new({UILabelType = 2, text = "分配记录", size = 35, color = cc.c3b(255, 192, 67)})
    :addTo(msgBox)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height - 40)

	self.recordListView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 20, 895, 415),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(msgBox)
    self:updateRecordListView()
end
function LegionFB:updateRecordListView()
	self.recordListView:removeAllItems()
    -- LegionFB_RecordData = {}
    if #LegionFB_RecordData==0 then
        msgBox = self.recordListView:getParent()
        display.newSprite("common2/com2_Img_24.png")
        :addTo(msgBox)
        :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2)
        cc.ui.UILabel.new({UILabelType = 2, text = "目前没有分配记录", size = 25, color = cc.c3b(128, 136, 150)})
        :addTo(msgBox)
        :align(display.CENTER, msgBox:getContentSize().width/2, msgBox:getContentSize().height/2-100)
        return
    end
	 for i,value in pairs(LegionFB_RecordData) do
        local item = self.recordListView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(895,120)
        local itemW,itemH = item:getItemSize() 

        local bottomLine = display.newSprite("Block/sweep/sweep_img8.png")
            :addTo(content)
            :pos(0, -(itemH/2-7))

        --物品图标
	    local itemIcon = createItemIcon(value.tmpId)
	    :addTo(content)
	    :pos(60-itemW/2,5)
	    :scale(0.8)
        --物品名字
		local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
		:addTo(content)
		:pos(130-itemW/2, 30)
		name:setString(value.name)
		name:setColor(cc.c3b(151, 190, 204))
		--系统分配时间
		local label = cc.ui.UILabel.new({UILabelType = 2, text = "系统自动分配时间：", size = 22})
		:addTo(content)
		:pos(130-itemW/2, -25)
		label:setColor(cc.c3b(240, 133, 5))
		--具体时间
		local mDate = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
		:addTo(content)
		:pos(label:getPositionX()+label:getContentSize().width, -25)
		mDate:setColor(cc.c3b(240, 133, 5))
		-- local dateStr = string.sub(value.time, 1, 10)
		mDate:setString(value.time)
        

    	
        self.recordListView:addItem(item)
    end
    self.recordListView:reload()
end
--开启重置副本
function LegionFB:onStartLegionFB(result)
	endLoading()
	if result.result==1 then
		if legionFBData[areaIdx].percent==-1 then
            legionFBData[areaIdx].percent = 0
			showTips("开启成功")
            local itemBar = self.curItemBar
            print(itemBar:getContentSize().width/2)
            LegionUnlockEff(itemBar, itemBar:getContentSize().width/2, itemBar:getContentSize().height/2-10,
            function()
                itemBar:removeChildByTag(100)
                itemBar:removeChildByTag(101)
                itemBar:removeChildByTag(102)
                end,
            function()
                self:updateListView()
                end)
		else
			showTips("重置成功")
            legionFBData[areaIdx].percent = 0
            self:updateListView()
		end
		
	else
		showTips(result.msg)
	end
end
function LegionFB:onLegionBlockResult(result)
    endLoading()
    lgionFBResult = result.result
    if lgionFBResult==-2 then
        showTips("加入军团，才可挑战军团副本")
        return
    elseif lgionFBResult==-4 or lgionFBResult==-5 then
    	showTips(result.msg)
        return
    end
    srv_blockArmyData = result.data
    local ToAreaId = legionFBData[areaIdx].areaId
	local areamap = g_blockMap.new(ToAreaId, 31001001, 3)
    areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
    MainSceneEnterType = EnterTypeList.TEAM_ENTER
end
--分配记录
function LegionFB:onLegionRecord(result)
	endLoading()
	if result.result==1 then
		self:addRcordBox()
	else
		showTips(result.msg)
	end
end

return LegionFB