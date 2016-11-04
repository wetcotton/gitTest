local legionManageLayer = require("app.scenes.legionScene.LegionManage")
g_legionFBLayer = require("app.scenes.legionScene.LegionFB")


local myLegionLayer=class("myLegionLayer", function()
    return display.newNode()
    end)

local CONTRI_DIAMOND = 25
local contriType = 0
myLegionInfo = nil
local cur_memIdx
local myIdx
local toPos

function myLegionLayer:ctor()
	local mlegionTop = borderHead
	local value = mLegionData.army

    local typeIcon = display.newSprite()
    :addTo(mlegionTop)
    :pos(110,mlegionTop:getContentSize().height/2-15)
    local IconBar
    if value.geType==1 then --善
        typeIcon:setTexture("common/common_good.png")
        IconBar = display.newSprite("common/common_good2.png")
        :addTo(typeIcon,2)
        :pos(typeIcon:getContentSize().width/2,0)
    else
        typeIcon:setTexture("common/common_bad.png")
        IconBar = display.newSprite("common/common_bad2.png")
        :addTo(typeIcon,2)
        :pos(typeIcon:getContentSize().width/2,0)
    end
	local path = "SingleImg/legion/legionIcon/Legion_"..value.icon..".png"
	self.mLegionIcon = display.newSprite(path)
	:addTo(typeIcon)
	:pos(typeIcon:getContentSize().width/2,typeIcon:getContentSize().height/2)

	--军团名字
	self.LegionName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
	:addTo(IconBar)
	:align(display.CENTER, IconBar:getContentSize().width/2, 35)
	self.LegionName:setString(value.name)
	
	--军团等级
	self.LegionLevel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18})
	:addTo(IconBar)
    :align(display.CENTER, IconBar:getContentSize().width/2, 15)
	self.LegionLevel:setString("LV:"..value.level)
	
    if value.geType==1 then --善
        self.LegionName:setColor(cc.c3b(255, 226, 184))
        self.LegionLevel:setColor(cc.c3b(255, 205, 48))
    else
        self.LegionName:setColor(cc.c3b(232, 63, 31))
        self.LegionLevel:setColor(cc.c3b(238, 122, 46))
    end

    --军团宣言
    local maniImg = display.newSprite("#legion_img48.png")
    :addTo(mlegionTop)
    :pos(mlegionTop:getContentSize().width/2-130,mlegionTop:getContentSize().height/2-40)

    self.maniContent = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(maniImg)
    :pos(50, maniImg:getContentSize().height - 5)
    self.maniContent:setString(value.manifesto)
    self.maniContent:setAnchorPoint(0,1)
    self.maniContent:setColor(cc.c3b(38, 53, 58))
    self.maniContent:setWidth(330)

    self.oldMani = self.maniContent:getString()
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            -- editbox:setText(self.maniLabel:getString())
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            if editbox:getText()~="" then
                local newMani = editbox:getText()
                editbox:setText("")
                self.maniContent:setString(newMani)
                startLoading()
                local sendData = {}
                sendData["manifesto"] = self.maniContent:getString()
                m_socket:SendRequest(json.encode(sendData), CMD_SETTING_LEGION, self, self.onSettingLegionResult)
            else
                editbox:setText("")
                self.maniContent:setString(self.oldMani)
            end
            
        elseif event == "return" then
            -- editbox:setText("")
            -- 从输入框返回
        end
    end
    --修改军团宣言
    local maniInput = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(40, 40)})
    :addTo(maniImg)
    :pos(maniImg:getContentSize().width-20,20)
    maniInput:setMaxLength(30)
    self.maniInput = maniInput


	--军团总战力
	local label = cc.ui.UILabel.new({UILabelType = 2, text = "总战力：", size = 30, color = cc.c3b(123, 163, 172)})
    :addTo(mlegionTop)
    :pos(630, 135)
	self.strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 30})
	:addTo(mlegionTop)
	:align(display.CENTER_LEFT, label:getPositionX() + label:getContentSize().width, label:getPositionY())
    local goldStr = value.strength..""
    local length = #goldStr
    for i=1,math.floor((length-1)/3) do
        local Lstr = string.sub(goldStr, 1, length-i*3)
        local Rstr = string.sub(goldStr, length-i*3+1)
        goldStr = Lstr..","..Rstr
    end
	self.strength:setString(goldStr)
	self.strength:setColor(cc.c3b(255, 192, 67))
	--军团成员
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "成员：", size = 25, color = cc.c3b(123, 163, 172)})
    :addTo(mlegionTop)
    :pos(630, 90)
	local maxNum = legionLevelData[value.level].maxMemNum
	self.mumberNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(mlegionTop)
	:align(display.CENTER_LEFT, label:getPositionX() + label:getContentSize().width, label:getPositionY())
	self.mumberNum:setString(value.memNum.."/"..maxNum)
	self.mumberNum:setColor(cc.c3b(193, 221, 221))
	--活跃值和建设值图标
	local star1 = cc.ui.UIPushButton.new("#legion_img29.png")
	:addTo(mlegionTop)
	:pos(650,45)
    :onButtonPressed(function(event)
        self:showEnergy(1)
        end)
    :onButtonRelease(function(event)
        self:closeEnergy(1)
        end)
    :onButtonClicked(function(event)
        end)
	local star2 = cc.ui.UIPushButton.new("#legion_img30.png")
	:addTo(mlegionTop)
	:pos(880,45)
    :onButtonPressed(function(event)
        self:showEnergy(2)
        end)
    :onButtonRelease(function(event)
        self:closeEnergy(2)
        end)
    :onButtonClicked(function(event)
        end)
	--活跃值
	self.active = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(mlegionTop)
	:pos(star1:getPositionX() + 25, star1:getPositionY()-2)
	self.active:setString(value.active)
	self.active:setColor(cc.c3b(193, 221, 221))
	self.active:setTouchEnabled(true)
    self.active:setTouchSwallowEnabled(false)
    self.active:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self.active:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if event.name == "began" then
        	self:showEnergy(1)
        elseif event.name == "moved" then
        elseif event.name == "ended" then
        	self:closeEnergy(1)
        end
        return true
    end)
	--建设值
	self.contri = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(mlegionTop)
	:pos(star2:getPositionX() + 25, star2:getPositionY()-2)
	self.contri:setString(value.contri)
	self.contri:setColor(cc.c3b(193, 221, 221))
	self.contri:setTouchEnabled(true)
    self.contri:setTouchSwallowEnabled(false)
    self.contri:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self.contri:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if event.name == "began" then
        	self:showEnergy(2)
        elseif event.name == "moved" then
        elseif event.name == "ended" then
        	self:closeEnergy(2)
        end
        return true
    end)

    --管理
    self.managerBt = cc.ui.UIPushButton.new("#legion_img36.png")
    :addTo(mlegionTop)
    :pos(890, 170)
    :onButtonPressed(function(event) event.target:setScale(1.1) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        legionManageLayer.new()
        :addTo(borderNode:getParent(),10,LEGIONMANAGE_TAG)
        end)
    self.managerBt:setVisible(false)

    cc.ui.UILabel.new({UILabelType = 2, text = "管理", size = 27, color = cc.c3b(139, 205, 216)})
    :addTo(self.managerBt)
    :pos(17, 0)

    --退团
    cc.ui.UIPushButton.new("#legion_img37.png")
    :addTo(mlegionTop)
    :pos(1030, 170)
    :onButtonPressed(function(event) event.target:setScale(1.1) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        showMessageBox("确定退出军团？", function(event)
            startLoading()
            local sendData = {}
            m_socket:SendRequest(json.encode(sendData), CMD_EXIT_LEGION, self, self.onExitLegion)
        end)
    end)
	

	--右侧
	local rightbar = display.newSprite("#legion_img25.png",borderSize.width-132, borderSize.height/2-95)
	:addTo(self)
	-- self:performWithDelay(function ()
		--军团副本
		local menu1 = cc.ui.UIPushButton.new("#legion_img35.png")
		:addTo(rightbar)
		:pos(rightbar:getContentSize().width/2, 355-9)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "军团\n副本", size = 27, color = cc.c3b(23, 56, 29)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():pos(25,0) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():pos(25,0) end)
		:onButtonClicked(function(event)
			-- if true then
			-- 	showTips("功能暂未开放")
			-- 	return 
			-- end
			startLoading()
	        local sendData = {}
	        m_socket:SendRequest(json.encode(sendData), CMD_LEGION_FB, self, self.onLegionFBResult)
			end)
        menu1:getButtonLabel():pos(25,0)
        display.newSprite("#legion_img31.png")
        :addTo(menu1)
        :pos(-35,0)

		--军团建设
		local menu2 = cc.ui.UIPushButton.new("#legion_img35.png")
		:addTo(rightbar)
		:pos(rightbar:getContentSize().width/2, 255-6)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "军团\n建设", size = 27, color = cc.c3b(23, 56, 29)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():pos(25,0) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():pos(25,0) end)
		:onButtonClicked(function(event)
			self:createLegionContriBox()
			end)
        menu2:getButtonLabel():pos(25,0)
        display.newSprite("#legion_img34.png")
        :addTo(menu2)
        :pos(-35,0)

		--军团商店
		local menu3 = cc.ui.UIPushButton.new("#legion_img35.png")
		:addTo(rightbar)
		:pos(rightbar:getContentSize().width/2, 155-3)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "军团\n商店", size = 27, color = cc.c3b(23, 56, 29)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():pos(25,0) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():pos(25,0) end)
		:onButtonClicked(function(event)
			local shop = shopLayer.new(3)
	        :addTo(borderNode:getParent(),10)
			end)
        menu3:getButtonLabel():pos(25,0)
        display.newSprite("#legion_img32.png")
        :addTo(menu3)
        :pos(-35,0)

		--军团租借
		local menu4 = cc.ui.UIPushButton.new("#legion_img35.png")
		:addTo(rightbar)
		:pos(rightbar:getContentSize().width/2, 55)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "军团\n租借", size = 27, color = cc.c3b(23, 56, 29)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) event.target:getButtonLabel():pos(25,0) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) event.target:getButtonLabel():pos(25,0) end)
		:onButtonClicked(function(event)
            RentMgr:ReqRentCarList(function ( ... )
                rentCarListLayer.new()
                    :addTo(borderNode:getParent(),10)
            end)
			
			end)
        menu4:getButtonLabel():pos(25,0)
        display.newSprite("#legion_img33.png")
        :addTo(menu4)
        :pos(-35,0)
	-- end,0.01)

	-- self.btnList = cc.ui.UIListView.new {
 --        bgColor = cc.c4b(200, 200, 200, 120),
 --        viewRect = cc.rect(15, 5, 200, 350),
 --        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
 --        }
 --        :addTo(rightbar)

	--成员列表
	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 220, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(10, 15, 830, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
    self:performWithDelay(function ()
    	self:updateListView()
        -- self:initBtnList()
    end,0.01)
end

function myLegionLayer:onEnter()
end

function sortLegionMenList()
	function sortfunc(a,b)
		if a.rank==b.rank then
			if a.level>b.level then
				return a.level>b.level
			end
		elseif a.rank>b.rank then
			return a.rank>b.rank
		end
	end
	table.sort(mLegionData.mem,sortfunc)
end
function myLegionLayer:updateListView()
	self.listView:removeAllItems()
	sortLegionMenList()
	local tmpTable = mLegionData.mem
    printTable(tmpTable)
    for i,value in pairs(tmpTable) do
    	if value.chaId == srv_userInfo.characterId then
            myLegionInfo = value
            myIdx = i
        end
        local item = self.listView:newItem()
        local content = display.newNode()

        local itemBar
        if i%2~=0 then
            itemBar = cc.ui.UIPushButton.new("#legion_img20.png")
        else
            itemBar = cc.ui.UIPushButton.new("#legion_img21.png")
        end
        itemBar:addTo(content)
        itemBar:onButtonClicked(function(event)
        	cur_memIdx = i
        	self:createMemMsgBox(value)
        	end)
        itemBar:setAnchorPoint(0.5,0.5)
        -- itemBar:setButtonSize(710, 110)
        itemBar:setTouchSwallowEnabled(false)
        headIdx = memberData[value.icon].resId
        --成员头像
        local head = display.newSprite("Head/headman_"..headIdx..".png")
        :addTo(itemBar)
        :pos(-340,7)
        head:setScale(0.95)
        --成员等级
		local Level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
		:addTo(itemBar)
		:align(display.CENTER_LEFT, 100-360, 20)
		Level:setString("LV:"..value.level)
		Level:setColor(cc.c3b(0, 183, 227))
		--成员名字
		local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
		:addTo(itemBar)
		:align(display.CENTER_LEFT, 210-360, 20)
		name:setString(value.name)
		name:setColor(cc.c3b(151, 190, 204))
		--成员战斗力
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 25, color =  cc.c3b(151, 190, 204)})
        :addTo(itemBar)
        :align(display.CENTER_LEFT, 100-360, -20-2)
		local strength = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
		:addTo(itemBar)
		:align(display.CENTER_LEFT, label:getPositionX()+label:getContentSize().width, label:getPositionY())
		strength:setString(value.strength)
		strength:setColor(cc.c3b(240, 133, 5))
		--职位
		if value.rank>0 then
			local pos = display.newSprite()
			:addTo(itemBar)
			
			local post
			if value.rank==1 then
				post = display.newSpriteFrame("legion_img23.png")
                pos:align(display.BOTTOM_LEFT, -394 , -49)
			elseif value.rank==2 then
				post = display.newSpriteFrame("legion_img24.png")
                pos:align(display.LEFT_TOP, -394 , 49)
			end
			pos:setSpriteFrame(post)
		end
		--成员建设
        local contriImg = display.newSprite()
            :addTo(itemBar)
            :pos(345, 8)
		local contri = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
		:addTo(itemBar)
		:align(display.CENTER_RIGHT, 360 , -25)
		local contriStr
        local imgFrame
		if value.contri==1 then
			contriStr = "今日已免费建设"
            contri:setColor(cc.c3b(198, 222, 235))
            imgFrame = display.newSpriteFrame("legion_img28.png")
		elseif value.contri==2 then
			contriStr = "今日已20钻石建设"
            contri:setColor(cc.c3b(118, 204, 243))
            imgFrame = display.newSpriteFrame("legion_img27.png")
		else
			if value.contri==0 then
				contriStr = "1天未建设"
			else
				contriStr = -value.contri.."天未建设"
			end
            contri:setColor(cc.c3b(234, 85, 20))
            imgFrame = display.newSpriteFrame("legion_img26.png")
		end
		contri:setString(contriStr)
        contriImg:setSpriteFrame(imgFrame)


        
        item:addContent(content)
        item:setItemSize(710,108)
        self.listView:addItem(item)
    end
    self.listView:reload()

    --普通成员没有军团管理按钮
    if myLegionInfo.rank==0 then
        self.managerBt:setVisible(false)
        self.maniInput:setTouchEnabled(false)
    else
        self.managerBt:setVisible(true)
        self.maniInput:setTouchEnabled(true)
    end
end
--成员信息框
function myLegionLayer:createMemMsgBox(value)
	self.msg_masklayer =  UIMasklayer.new()
    :addTo(borderNode:getParent(),10)
    local function  func()
        self.msg_masklayer:removeSelf()
    end
    self.msg_masklayer:setOnTouchEndedEvent(func)
	local msgBox = display.newScale9Sprite("SingleImg/messageBox/messageBox.png",display.cx, display.cy-30)
	:addTo(self.msg_masklayer)
	self.msg_masklayer:addHinder(msgBox)
    local tmpsize = msgBox:getContentSize()

    --标题
    cc.ui.UILabel.new({UILabelType = 2, text = "成员信息", size = 35, color = cc.c3b(255, 192, 67)})
    :addTo(msgBox)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height - 40)

	--成员头像
	headIdx = memberData[value.icon].resId
    local head = display.newSprite("Head/headman_"..headIdx..".png")
    :addTo(msgBox)
    :pos(150, tmpsize.height - 150)
    --名字
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(210, tmpsize.height - 130)
    name:setColor(cc.c3b(151, 190, 204))
    name:setString(value.name)
    --等级
    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(210, tmpsize.height - 180)
    level:setColor(cc.c3b(109, 197, 240))
    level:setString("LV:"..value.level)

    --底板
    local tmpPanel = display.newScale9Sprite("#legion_img8.png", nil, nil, cc.size(500, 130))
    :addTo(msgBox)
    :pos(tmpsize.width/2, tmpsize.height/2 - 50)

	--贡献值
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "七日贡献活跃：", size = 25, color = cc.c3b(151, 190, 204)})
    :addTo(tmpPanel)
    :pos(25, 90)
	local contri = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(tmpPanel)
    :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())
    contri:setColor(cc.c3b(234, 85, 20))
    contri:setString(value.active)
    --最后上线时间：
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "最后上线时间：", size = 25, color = cc.c3b(151, 190, 204)})
    :addTo(tmpPanel)
    :pos(25, 40)
    local lastonline = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(tmpPanel)
    :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())
    lastonline:setColor(cc.c3b(234, 85, 20))
    lastonline:setString(getLastOnLine(value.lastOnTime))
    if value.chaId==myLegionInfo.chaId then
    	return
    end
    if myLegionInfo.rank>0 then
    	if myLegionInfo.rank==2 then
    		--升为队长
            local text
            if value.rank==0 then
                text = "升为队长"
            else
                text = "降为成员"
            end
			local bt1 = createGreenBt(text)
			:addTo(msgBox)
			:pos(tmpsize.width/6+10,50)
			:onButtonClicked(function(event)
				if value.rank==1 then
                    showMessageBox("确定将该成员降为成员？", function(event)
                        toPos = 0
                        startLoading()
                        local sendData = {}
                        sendData.chaId = value.chaId
                        sendData.rank = toPos
                        m_socket:SendRequest(json.encode(sendData), CMD_APPOINT_POS, self, self.onAppointPosLegionResult)
                    end)
		            
		        else
                    showMessageBox("确定将该成员升为队长？", function(event)
                        toPos = 1
                        local sendData = {}
                        sendData.chaId = value.chaId
                        sendData.rank = toPos
                        m_socket:SendRequest(json.encode(sendData), CMD_APPOINT_POS, self, self.onAppointPosLegionResult)
                    end)
		            
		        end
		        
				end)
			--升为统帅
			local bt2 = createYellowBt("升为统帅")
			:addTo(msgBox)
			:pos(msgBox:getContentSize().width/2,50)
			:onButtonClicked(function(event)
                showMessageBox("确定将该成员任命为统帅？", function(event)
                    toPos = 2
                    startLoading()
                    local sendData = {}
                    sendData.chaId = value.chaId
                    sendData.rank = toPos
                    m_socket:SendRequest(json.encode(sendData), CMD_APPOINT_POS, self, self.onAppointPosLegionResult)
                        end)
				end)
            display.newSprite("#legion_img24.png")
            :addTo(bt2)
            :pos(-60,38)
    	end
        if myLegionInfo.rank>value.rank then
            --踢出军团
            local bt3 = createYellowRedBt("踢出军团")
            :addTo(msgBox)
            :pos(msgBox:getContentSize().width/6*5-10,50)
            :onButtonClicked(function(event)
                showMessageBox("确定将该成员踢出军团？", function(event)
                    startLoading()
                    local sendData = {}
                    sendData.kickChaId = value.chaId
                    m_socket:SendRequest(json.encode(sendData), CMD_KICK_MEMBER, self, self.onkickMemberLegionResult)
                    end)
                end)
        end
		
    end
	
end
--军团建设框
function myLegionLayer:createLegionContriBox()
	self.contri_masklayer =  UIMasklayer.new()
    :addTo(borderNode:getParent(),10)
    local function  func()
        self.contri_masklayer:removeSelf()
    end
    self.contri_masklayer:setOnTouchEndedEvent(func)

    local legionLevelValue = legionLevelData[mLegionData.army.level]
    local energyArr = lua_string_split(legionLevelValue.energy,"|")

    --免费建设
    local contriBt1 = cc.ui.UIPushButton.new("#legion_img45.png")
    :addTo(self.contri_masklayer)
    :pos(display.cx-210, display.cy-20)
    :onButtonPressed(function(event) event.target:setScale(0.98) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if myLegionInfo.contri>0 then
            showTips("今天已经建设过了哦！")
            return
        end
        startLoading()
        contriType = 1
        local sendData = {}
        sendData.type = 1
        m_socket:SendRequest(json.encode(sendData), CMD_CONSTR_LEGION, self, self.onConstrLegionResult)
        end)
    self.contriBt1 = contriBt1

    cc.ui.UILabel.new({UILabelType = 2, text = "免费建设", size = 35, color = cc.c3b(204, 255, 77)})
    :addTo(contriBt1)
    :align(display.CENTER, 0, -115)

    --获得燃油
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "获得燃油：", size = 25, color = cc.c3b(23, 56, 29)})
    :addTo(contriBt1)
    :pos(-100, -20)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = energyArr[1], size = 25, color = cc.c3b(23, 56, 29)})
    :addTo(contriBt1)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())

    --工会建设值
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "工会建设值：", size = 25, color = cc.c3b(23, 56, 29)})
    :addTo(contriBt1)
    :pos(-100, -60)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "50", size = 25, color = cc.c3b(23, 56, 29)})
    :addTo(contriBt1)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())

    --钻石建设
    local contriBt2 = cc.ui.UIPushButton.new("#legion_img46.png")
    :addTo(self.contri_masklayer)
    :pos(display.cx+210, display.cy-20)
    :onButtonPressed(function(event) event.target:setScale(0.98) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if srv_userInfo.vip<9 then
            return showTips("vip等级9级后，开启军团钻石建设")
        end
        if myLegionInfo.contri>0 then
            showTips("今天已经建设过了哦！")
            return
        end
        if srv_userInfo["diamond"]<CONTRI_DIAMOND then
            showTips("钻石不足，请去充值！")
            return
        end
        startLoading()
        contriType = 2
        local sendData = {}
        sendData.type = 2
        m_socket:SendRequest(json.encode(sendData), CMD_CONSTR_LEGION, self, self.onConstrLegionResult)
    end)
    self.contriBt2 = contriBt2

    if myLegionInfo.contri>0 then
        local parentNode
        if myLegionInfo.contri==1 then
            parentNode = self.contriBt1
        elseif myLegionInfo.contri==2 then
            parentNode = self.contriBt2
        end
        local img = display.newSprite("#legion_img47.png")
        :addTo(parentNode, 10)
        -- :scale(1.5)
    end
    
    
    display.newSprite("common/common_Diamond.png")
    :addTo(contriBt2)
    :align(display.CENTER, -40, -115)

    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "25", size = 35, color = cc.c3b(102, 202, 255)})
    :addTo(contriBt2)
    :align(display.CENTER_LEFT, 5, -115)
    setLabelStroke(label,35,nil,nil,nil,nil,nil,"fonts/slicker.ttf", true)

    --获得燃油
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "获得燃油：", size = 25, color = cc.c3b(66, 51, 42)})
    :addTo(contriBt2)
    :pos(-100, -20)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = energyArr[2], size = 25, color = cc.c3b(66, 51, 42)})
    :addTo(contriBt2)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())

    --工会建设值
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "工会建设值：", size = 25, color = cc.c3b(66, 51, 42)})
    :addTo(contriBt2)
    :pos(-100, -60)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "100", size = 25, color = cc.c3b(66, 51, 42)})
    :addTo(contriBt2)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
end
function myLegionLayer:contriSuccess(parentNode, x, y)
    local img = display.newSprite("#legion_img47.png")
    :addTo(parentNode)
    :pos(x, y)
    :scale(1.5)

    local act1 = cc.FadeIn:create(0.2)
    local act2 = cc.ScaleTo:create(0.2, 1)
    img:runAction(act1)
    img:runAction(act2)
end

--显示活跃值，建设值说明
local energyText = {
	{
	title = "活跃值",
	content = "军团成员每消耗一点燃油，公会就会获得一点活跃值\n活跃值可用于重置团队副本与提升军团等级\n活跃值上限200000点，每个成员每天最多贡献600点\n你今日贡献活跃值："
	},
	{
	title = "建设值",
	content = "军团成员每天可进行一次军团建设，提升军团的\n建设值\n建设值可用于提升军团等级"
	},
}
function myLegionLayer:showEnergy(nFlag)
	self.energyMsgBox = display.newScale9Sprite("common/common_box3.png",display.cx+50, 
		300,
		cc.size(555, 180))
	:addTo(self,10)
	local title = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
	:addTo(self.energyMsgBox)
	:align(display.CENTER, self.energyMsgBox:getContentSize().width/2,self.energyMsgBox:getContentSize().height - 30)
	title:setString(energyText[nFlag].title)
	local content = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(self.energyMsgBox)
	:pos(20,self.energyMsgBox:getContentSize().height - 55)
	content:setColor(MYFONT_COLOR)
	content:setAnchorPoint(0,1)
	content:setString(energyText[nFlag].content)
	content:setLineHeight(25)
	if nFlag==1 then
		local actNum = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color=cc.c3b(0, 255, 0)})
		:addTo(self.energyMsgBox)
		:pos(220,35)
        :setString(mLegionData.mine.dayActive)
	end
end
function myLegionLayer:closeEnergy(nFlag)
	self.energyMsgBox:removeFromParent()
end

function getLastOnLine(date)
	-- print(date)
    local mDate = os.date("*t", os.time())
    -- print(mDate)
    local dYear = mDate.year - string.sub(date,1,4)
    local dMonth = mDate.month - string.sub(date,6,7)
    local dDay = mDate.day - string.sub(date,9,10)
    local mTime = string.sub(date,12,16)
    if dYear==1 and dMonth<0 then
    	dYear = 0
    	dMonth = dMonth + 12
    elseif dMonth==1 and dDay<0 then
    	dMonth = 0
    	dDay = dDay + 30
    end
    -- print("",dYear,dMonth,dDay,mTime)
    if dYear>=1 then
        return dYear.."年前"
    elseif dMonth>=1 then
        return dMonth.."月前"
    elseif dDay>1 then
    	return dDay.."天前"
    elseif dDay == 1 then
        return "昨天"..mTime
    elseif dDay == 0 then
        return "今天"..mTime
    else
    	return "未知"
    end
end
--军团建设
function myLegionLayer:onConstrLegionResult(result)
	endLoading()
    if result.result==1 then
    	local legionLevelValue = legionLevelData[mLegionData.army.level]
		local energyArr = lua_string_split(legionLevelValue.energy,"|")
        -- self.contri_masklayer:removeSelf()
        local Contri
        local addTili
        local addContri
        local needDiamond = 0
        if contriType==1 then
            Contri=1
            addTili=energyArr[1]+0
            addContri = 50
            
            freeLegionContriEff(self.contriBt1,nil,nil,nil,function(event)
                self:contriSuccess(self.contriBt1, 0, 0)
                end)
        elseif contriType==2 then
            Contri=2
            addTili=energyArr[2]+0
            addContri = 100
            needDiamond = 25
            
            diamondLegionContriEff(self.contriBt2,nil,nil,nil,function(event)
                self:contriSuccess(self.contriBt2, 0, 0)
                end)
        end
        myLegionInfo.contri = Contri
        srv_userInfo["energy"] = srv_userInfo["energy"] + addTili
        mLegionData["army"].contri = mLegionData["army"].contri + addContri
        srv_userInfo.diamond = srv_userInfo.diamond - needDiamond
        mainscenetopbar:setEnergy()
        mainscenetopbar:setDiamond()
        self.contri:setString(mLegionData.army.contri)
        self:performWithDelay(function ()
	    	self:updateListView()
	    end,0.01)

        --数据统计
        luaStatBuy("军团建设", BUY_TYPE_CONTR_ARMY, 1, "钻石", needDiamond)
    else
    	showTips(result.msg)
    end
end
--踢出成员
function myLegionLayer:onkickMemberLegionResult(result)
	endLoading()
    if result.result==1 then
        self.msg_masklayer:removeSelf()
        table.remove(mLegionData["mem"],cur_memIdx)
        self:performWithDelay(function ()
	    	self:updateListView()
	    end,0.01)

        mLegionData.army.memNum = mLegionData.army.memNum - 1
        self:reloadThisLayerAllData()
        showTips("踢出成功。")
    else
    	showTips(result.msg)
    end
end
--任命职位
function myLegionLayer:onAppointPosLegionResult(result)
	endLoading()
    if result.result==1 then
    	self.msg_masklayer:removeSelf()
        local tmpRank = mLegionData["mem"][cur_memIdx].rank
        mLegionData["mem"][cur_memIdx].rank = toPos
        if toPos==2 then
            mLegionData["mem"][myIdx].rank = tmpRank
        end
        self:updateListView()
        showTips("任命成功。")
    else
    	showTips(result.msg)
    end
end
--军团副本
function myLegionLayer:onLegionFBResult(result)
	endLoading()
    if result.result==1 then
        g_legionFBLayer.new()
		:addTo(borderNode:getParent(),10)
    else
    	showTips(result.msg)
    end
end

function myLegionLayer:initBtnList()
	self:performWithDelay(function ()
		local listview = self.btnList
		listview:removeAllItems()

		self.btnItems = {}
		local onClick = {
			function(event)
                if next(legionFBData)==nil then
                    startLoading()
                    local sendData = {}
                    m_socket:SendRequest(json.encode(sendData), CMD_LEGION_FB, self, self.onLegionFBResult)
                else
                    g_legionFBLayer.new()
                    :addTo(borderNode:getParent(),10)
                end
			end
			,
			function(event)
				self:createLegionContriBox()
			end
			,
			function(event)
				local shop = shopLayer.new(3)
		        	:addTo(borderNode:getParent(),10)
			end
			,
			function(event)
				self:removeSelf()
				legionManageLayer.new()
					:addTo(borderNode,0,LEGIONMANAGE_TAG)
			end
			,
			function(event)
		        rentCarListLayer.new()
		        	:addTo(borderNode:getParent(),10)
			end
		}

		local Imgs = {
		"legion/menuImg1.png",
		"legion/menuImg2.png",
		"legion/menuImg3.png",
		"legion/menuImg4.png",
		"legion/menuImg40.png",

	}

		local g_scale = 1.3

        local menuNum = 5
        if myLegionInfo.rank==0 then menuNum=4 end --普通成员不能军团管理
		for i = 1,menuNum do
            if menuNum==4 and i==4 then i=5 end

			local g_item = listview:newItem()
	        local g_content = cc.Node:create()

			local g_menu = cc.ui.UIPushButton.new({normal = "common/commonBt3_1.png",pressed = "common/commonBt3_2.png"})
							:addTo(g_content)
							:scale(g_scale)
							:onButtonClicked(onClick[i])
			g_menu:setTouchSwallowEnabled(false)
							
			local menuImg = display.newSprite(Imgs[i])
								:addTo(g_menu)
								:scale(1/g_scale)

			self.btnItems[i] = g_menu

			g_item:addContent(g_content)
	        g_item:setItemSize(180, 80)
	        listview:addItem(g_item)
		end
		listview:reload()
	end,0.01)
end

function myLegionLayer:reloadThisLayerAllData()
    local value = mLegionData.army
    --名字
    self.LegionName:setString(value.name)
    --等级
    self.LegionLevel:setString("LV:"..value.level)
    --宣言
    self.maniContent:setString(value.manifesto)
    --战斗力
    local goldStr = value.strength..""
    local length = #goldStr
    for i=1,math.floor((length-1)/3) do
        local Lstr = string.sub(goldStr, 1, length-i*3)
        local Rstr = string.sub(goldStr, length-i*3+1)
        goldStr = Lstr..","..Rstr
    end
    self.strength:setString(goldStr)
    --成员数
    local maxNum = legionLevelData[value.level].maxMemNum
    self.mumberNum:setString(value.memNum.."/"..maxNum)
    --活跃值
    self.active:setString(value.active)
    --建设值
    self.contri:setString(value.contri)

    --刷新成员列表
    -- self:updateListView()
end

--退团
function myLegionLayer:onExitLegion(result)
    endLoading()
    if result.result==1 then
        srv_userInfo["armyName"]=""

        --退出军团后，保存的军团数据清空
        InitLegionList          = {} --符合条件的军团信息
        mLegionData             = {} --自己军团的信息
        armyId                  = nil--军团申请列表
        legionFBData            = {} --军团副本
        lgionFBResult           = nil --军团副本返回结果类型
        LegionFB_RecordData     = {} --军团分配记录
        findLegionData          = {} --查找军团数据
        LegionDamageRankData    = {} --军团伤害排名
        LegionSpoilsData        = {} --军团战利品信息
        --退出军团，便不能租车了
        RentMgr.rentInfo = {}
        RentMgr.sortList = {}
        RentMgr:InitWithLocalData()

        -- g_myLegionLayer:removeSelf()
        -- Initlayer.new()
        -- :addTo(borderNode,0,INITLEGION_TAG)
        LegionScene.Instance:removeSelf()
        display.getRunningScene():setTopBarVisible(true)
    else
        showTips(result.msg)
    end
end

--修改军团宣言
function myLegionLayer:onSettingLegionResult(result)
    endLoading()
    if result["result"]==1 then
        mLegionData.army.manifesto= self.maniContent:getString()
        showTips("修改成功！")

        if g_myLegionLayer then
            g_myLegionLayer:reloadThisLayerAllData()
        end
    else
        self.maniContent:setString(self.oldMani)
        showTips(result.msg)
    end
end

return myLegionLayer