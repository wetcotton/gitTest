local roleMenuBar = class("roleMenuBar", function()
    local layer = display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)

function roleMenuBar:getMenuPos(nIdx)
	local menuPos = {x=60 + 115*(nIdx-1), y = 50}
	return menuPos
end

g_menuTab_bottom = {}

function roleMenuBar:ctor()
	local menuBar = display.newSprite("#MainUI_img2.png")
	:addTo(self)
	:align(display.BOTTOM_LEFT, 0, 0)
	self.menuBar = menuBar
	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(1).x, self:getMenuPos(1).y-27)
	--属性
	self.rolePropertyBt = cc.ui.UIPushButton.new("#MainUI_img4.png")
	:addTo(self)
	:pos(self:getMenuPos(1).x, self:getMenuPos(1).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_RolePropertyLayer.new()
        :addTo(display.getRunningScene(),1)
        
		end)

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(2).x, self:getMenuPos(2).y-27)
	--背包
	self.backpackBt = cc.ui.UIPushButton.new("#MainUI_img5.png")
	:addTo(self)
	:pos(self:getMenuPos(2).x, self:getMenuPos(2).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		self.backpack = backPackLayer.new()
        :addTo(display.getRunningScene())
        self.backpack:setTag(TAG_BACKPACK_LAYER)
        
		end)

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(3).x, self:getMenuPos(3).y-27)
	--抽卡
	self.lotterycardBt = cc.ui.UIPushButton.new("#MainUI_img6.png")
	:addTo(self)
	:pos(self:getMenuPos(3).x, self:getMenuPos(3).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		local lotteryCard = g_lotteryCardLayer.new()
        :addTo(display.getRunningScene())
        
		end)

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(4).x, self:getMenuPos(4).y-27)
	--改造中心
	self.improveBt = cc.ui.UIPushButton.new("#MainUI_img7.png")
	:addTo(self)
	:pos(self:getMenuPos(4).x, self:getMenuPos(4).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		if 0==srv_userInfo.hasCar then
            showMessageBox("当前战车数量为0")
        else
            g_ImproveLayer.new()
            :addTo(cc.Director:getInstance():getRunningScene(), 1)
        end
		end)

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(5).x, self:getMenuPos(5).y-27)
	--乘降
	self.chengjiangBt = cc.ui.UIPushButton.new("#MainUI_img8.png")
	:addTo(self)
	:pos(self:getMenuPos(5).x, self:getMenuPos(5).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_DriveLayer.new()
        :addTo(display.getRunningScene(), 1)
		end)


	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(6).x, self:getMenuPos(6).y-27)
	--商店
	self.shopBt = cc.ui.UIPushButton.new("#MainUI_img9.png")
	:addTo(self)
	:pos(self:getMenuPos(6).x, self:getMenuPos(6).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
        local shop = shopLayer.new(1)
        :addTo(MainScene_Instance)
		end)

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(7).x, self:getMenuPos(7).y-27)
	--竞技
	self.ArenaBt = cc.ui.UIPushButton.new("#MainUI_img10.png")
	:addTo(self)
	:pos(self:getMenuPos(7).x, self:getMenuPos(7).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		if srv_userInfo.level < 16 then
           showTips("等级达到16级解锁竞技场")
           return
        end
        startLoading()
        comData={}
        comData["characterId"] = srv_userInfo.characterId
        m_socket:SendRequest(json.encode(comData), CMD_GETPVPINFO, MainScene_Instance, MainScene_Instance.OnGetPVPInfoRet)
		end)
	if srv_userInfo.level<16 then
		display.newSprite("common2/com_lock.png")
		:addTo(self.ArenaBt,0,11)
		:pos(30,30)
	end

	--底
	display.newSprite("#MainUI_img3.png")
	:addTo(menuBar)
	:pos(self:getMenuPos(8).x, self:getMenuPos(8).y-27)
	--勇士
	self.WarCenterBt = cc.ui.UIPushButton.new("#MainUI_img11.png")
	:addTo(self)
	:pos(self:getMenuPos(8).x, self:getMenuPos(8).y)
	:onButtonPressed(function(event)
		event.target:setScale(0.95)
		end)
	:onButtonRelease(function(event)
		event.target:setScale(1.0)
		end)
	:onButtonClicked(function(event)
		g_WarriorsCenterLayer.new()
            :addTo(MainScene_Instance, 1)
		end)

end

function roleMenuBar:initMenutab_bottom()
	g_menuTab_bottom = {
		[1] = {self.rolePropertyBt,true},	--人物
		[2] = {self.backpackBt,true},		--仓库
		[3] = {self.lotterycardBt,true},	--抽奖
		[4] = {self.improveBt,true},		--车库
		[5] = {self.chengjiangBt,true},		--乘降
		[6] = {self.shopBt,true},			--商店(默认出现)
		[7] = {self.ArenaBt,true},			--竞技场
		[8] = {self.WarCenterBt,true},		--勇士中心
	}
	local guideStep = srv_userInfo.guideStep
	if guideStep<=104 then--一开始，隐藏乘降
		g_menuTab_bottom[5][2] = false
	end
	if guideStep<=107 then	--主炮升级前，隐藏车库按钮
		g_menuTab_bottom[4][2] = false
	end
	if guideStep<=106 then	--抽卡前，隐藏抽卡按钮、仓库按钮
		g_menuTab_bottom[2][2] = false
		g_menuTab_bottom[3][2] = false
	end
	if guideStep<=114 then	--弹弓升级前，隐藏人物按钮
		g_menuTab_bottom[1][2] = false
	end
	if guideStep<=126 then	--打竞技场前，隐藏竞技场按钮（还有排行榜按钮）
		g_menuTab_bottom[7][2] = false
	end
	if guideStep<=127 then	--打遗迹探测前，隐藏勇士中心按钮
		g_menuTab_bottom[8][2] = false
	end

	--新需求要求按钮不隐藏，也不突然出现
	-- if srv_userInfo.guideStep==-1 or g_isGuideClose then
	-- 	return 
	-- end
	-- local j=0
	-- for i=1,#g_menuTab_bottom do
	-- 	if g_menuTab_bottom[i][2]==false then
	-- 		g_menuTab_bottom[i][1]:hide()
	-- 	else
	-- 		g_menuTab_bottom[i][1]:pos(j*115+60,50)
	-- 		j = j+1
	-- 	end
	-- end
	-- self.menuBar:setPositionX((j-8)*115)
end

function roleMenuBar:showMoveAction(_guideStep,_callback,_index)
	local _delayTime = 0

	if srv_userInfo.guideStep==-1 or g_isGuideClose then
		if _callback then
			self:performWithDelay(_callback,_delayTime)
		end
		return 
	end

	local function getFrontAndTailBtns(index)
		local front = {}
		local tail = {}
		for i=1,#g_menuTab_bottom do
			--if g_menuTab_bottom[i][2]==true then
				if i<index then
					front[#front+1] = g_menuTab_bottom[i][1]
				elseif i>index then
					tail[#tail+1] = g_menuTab_bottom[i][1]
				end
			--end
		end
		return front,tail
	end

	local tmp = GuideManager.NextStep
	if tonumber(tmp) == 0 then
        tmp = tonumber(tostring(srv_userInfo.guideStep).."01")
    end

	local index = -1
	if _guideStep==10401 and tmp == _guideStep then
		index = 5
	elseif _guideStep==10701 and tmp == _guideStep then
		index = 4
	elseif _guideStep==10601 and tmp == _guideStep then
		index = 3
		-- self:showMoveAction(nil,nil,2)
	elseif _guideStep==11401 and tmp == _guideStep then
		index = 1
	elseif _guideStep==12601 and tmp == _guideStep then
		index = 7
	elseif _guideStep==12701 and tmp == _guideStep then
		index = 8
	end

	if index==-1 and tonumber(_index)~=nil then
		index = _index
	end

	if index~=-1 then
		_delayTime = 0.6
		g_menuTab_bottom[index][2] = true
		local front,tail = getFrontAndTailBtns(index)
		-- for k,v in pairs(tail) do
		-- 	local sq = transition.sequence{
		-- 			cc.EaseOut:create(cc.MoveBy:create(_delayTime*0.4,cc.p(115+20,0)),5),
		-- 			cc.MoveBy:create(_delayTime*0.2,cc.p(-20,0)),
		-- 	}
		-- 	v:runAction(sq)
		-- end
		g_menuTab_bottom[index][1]:show()
			:pos(#front*115+60,50)

		_delayTime = _delayTime
		local sq = transition.sequence{
						cc.EaseOut:create(cc.MoveBy:create(_delayTime/2,cc.p(0,200)),3),
						cc.EaseIn:create(cc.MoveBy:create(_delayTime/2,cc.p(0,-200)),3),
					}
		g_menuTab_bottom[index][1]:runAction(sq)

		display.addSpriteFrames("Effect/menuEff.plist", "Effect/menuEff.png")
	    local frames = display.newFrames("rolemenuEff_%02d.png", 0, 35)
	    local animation = display.newAnimation(frames, 0.8 / 35)
	    local ani = cc.Animate:create(animation)
	    local sprite = display.newSprite("#rolemenuEff_00.png")
			    :addTo(self)
			    :align(display.CENTER_BOTTOM,#front*115+60,10)
			    :scale(2)
	    sprite:runAction(transition.sequence{ani,cc.CallFunc:create(function ()
	    	sprite:removeSelf()
	    end)})

	    local bgOff = #front + #tail + 1 - 8
	    self.menuBar:setPositionX(bgOff*115)
	end

	if _callback then
		self:performWithDelay(_callback,_delayTime)
	end
end

function roleMenuBar:onEnter()
	self:initMenutab_bottom()
end

return roleMenuBar