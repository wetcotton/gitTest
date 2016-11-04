-- 勇士中心
-- Author: Jun Jiang
-- Date: 2015-06-03 15:15:01
--
require("app.scenes.shop.shopLayer")

local WarriorsCenterLayer = class("WarriorsCenterLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
WarriorsCenterLayer.Instance = nil

local ChildModule = {
	[1] = g_worldBoss,
	[2] = g_RelicsLayer, 	--遗迹探测
	[3] = expeditionLayer,
}

bIsBossClose = false

g_nCurChildModule = 0

function WarriorsCenterLayer:ctor()
	mainscenetopbar:hide()
	--资源加载
	display.addSpriteFrames("Image/UIWarriorsCenter.plist", "Image/UIWarriorsCenter.png")
    
	local tmpNode, tmpSize, tmpCx, tmpCy, tmpCfg

	self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

	--返回按钮
	cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
	:align(display.LEFT_TOP, 0, display.height )
	:addTo(self)
	:onButtonClicked(function(event)
		print("用市中心，点击返回")
		self:removeFromParent()
	end)

	tmpSize = cc.size(1140, 610)

	--底框
	-- self.mainFrame = display.newScale9Sprite("common/common_Frame2.png", nil, nil, _size, cc.rect(135, 87, 93, 54))
	-- 					:align(display.CENTER, display.cx, display.cy-40)
	-- 					:addTo(self)
	self.mainFrame = display.newNode()
						:align(display.CENTER, display.cx, display.cy-40)
						:addTo(self)
	self.mainFrame:setContentSize(tmpSize.width,tmpSize.height)

	--标题
	display.newSprite("#WarriorsCenter_Text8.png")
		:align(display.CENTER, tmpSize.width/2, tmpSize.height+30)
		:addTo(self.mainFrame)

	display.newSprite("#WarriorsCenter_Spr2.png")
				:addTo(self.mainFrame)
				:align(display.CENTER_TOP,tmpSize.width/2,tmpSize.height-15)

	self.sprBright = {}
	--世界boss、遗迹探测、战车远征
	tmpCfg = {
		{
			bgSize=cc.size(380, 520), brightSize=cc.size(360, 500) , sprShow="#WarriorsCenter_Spr4.png", x=tmpSize.width/2-400, y=tmpSize.height/2,
			title="挑战诺亚", titleBgScaleX=-1,
			desBg="#WarriorsCenter_Spr7.png", desBgScaleX=1.25, desBgX=208, desBgY=100,
			des="", desSize=cc.size(300, 100)
		},
		{
			bgSize=cc.size(380, 520), brightSize=cc.size(360, 500) , sprShow="#WarriorsCenter_Spr5.png", x=tmpSize.width/2, y=tmpSize.height/2,
			title="遗迹探测", titleBgScaleX=-1,
			desBg="#WarriorsCenter_Spr3.png", desBgScaleX=-1, desBgX=142, desBgY=94,
			des="有机会探测到人物，金币或者战车材料", desSize=cc.size(300, 0)
		},
		{
			bgSize=cc.size(380, 520), brightSize=cc.size(360, 500) , sprShow="#WarriorsCenter_Spr5_1.png", x=tmpSize.width/2+400, y=tmpSize.height/2,
			title="战车远征", titleBgScaleX=1,
			desBg="#WarriorsCenter_Spr3.png", desBgScaleX=1, desBgX=466, desBgY=94,
			des="有机会探测到人物，金币或者战车材料", desSize=cc.size(300, 0)
		},
	}
	local function BtnOnPressed(event)
		local nTag = event.target:getTag()
		if nil~=self.sprBright[nTag] then
			self.sprBright[nTag]:setVisible(true)
		end
	end

	local function BtnOnRelease(event)
		local nTag = event.target:getTag()
		if nil~=self.sprBright[nTag] then
			self.sprBright[nTag]:setVisible(false)
		end
	end

	local function BtnOnClicked(event)
		local nTag = event.target:getTag()
		self:EnterChildModule(nTag)
		if nTag==2 then
    		GuideManager:forceSendFinishStep(128)
		end
		GuideManager:removeGuideLayer()
	end

	local frame
	for i=1, #tmpCfg do
		display.newSprite(tmpCfg[i].sprShow)
			:align(display.CENTER, tmpCfg[i].x, tmpCfg[i].y)
					:addTo(self.mainFrame)
		--底框
		frame = display.newScale9Sprite("#WarriorsCenter_Frame1.png", nil, nil, tmpCfg[i].bgSize,cc.rect(70,80,10,10))
					:align(display.CENTER, tmpCfg[i].x, tmpCfg[i].y)
					:addTo(self.mainFrame)
		tmpSize = frame:getContentSize()
		tmpCx = tmpSize.width/2
		tmpCy = tmpSize.height/2
		if i==1 then
			print("================================")
			self.bossBg = frame
		end
		--展示图片
		
		--亮框
		self.sprBright[i] = display.newScale9Sprite("#WarriorsCenter_Frame2.png", nil, nil, tmpCfg[i].brightSize)
								:align(display.CENTER, tmpCx-3, tmpCy)
								:addTo(frame, 1)
		self.sprBright[i]:setVisible(false)
		--按钮
		tmpNode = cc.ui.UIPushButton.new()
					:align(display.CENTER, tmpCx, tmpCy)
					:addTo(frame)
		tmpNode:setTag(i)
		tmpNode:setContentSize(tmpCfg[i].bgSize)
		tmpNode:onButtonPressed(BtnOnPressed)
			   :onButtonRelease(BtnOnRelease)
			   :onButtonClicked(BtnOnClicked)
		if i==2 then
			self.guideBtn = tmpNode
		elseif i==3 then
			self.guideBtn2 = tmpNode
		end

		display.newSprite("#WarriorsCenter_Spr3.png")
					:addTo(frame,1)
					:align(display.LEFT_TOP,0,tmpSize.height)

		--标题背景
		local titleBg = display.newSprite("#WarriorsCenter_Frame8.png")
							:align(display.LEFT_TOP,-5,tmpSize.height+10)
							:addTo(frame,1)


		--标题
		local title = display.newTTFLabel{text = tmpCfg[i].title,color = display.COLOR_RED,size = 30}
							:align(display.CENTER, titleBg:getContentSize().width/2-15,titleBg:getContentSize().height/2+5)
							:addTo(titleBg)

		--描述背景
		local desBg = display.newScale9Sprite("common/blueBt1.png", nil, nil, cc.size(tmpSize.width-20,100),cc.rect(50,30,10,10))
						:align(display.CENTER, tmpSize.width/2, tmpSize.height/2-150)
						:addTo(frame,1)
		desBg:setColor(cc.c3b(0,0,0))
		desBg:setOpacity(80)

		--描述
		display.newTTFLabel({
				text=tmpCfg[i].des,
				size=24,
				color=cc.c3b(186, 217, 212),
				align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				dimensions = tmpCfg[i].desSize,
			})
			:align(display.CENTER,tmpSize.width/2,50)
			:addTo(desBg)
	end

	GuideManager:_addGuide_2(12703,display.getRunningScene(),handler(self,self.caculateGuidePos))
	GuideManager:_addGuide_2(12803,display.getRunningScene(),handler(self,self.caculateGuidePos))
end

--进入子模块
function WarriorsCenterLayer:EnterChildModule(nIndex)
	print("g_worldBoss: ")
	print(g_worldBoss)
	print(nIndex)
	print(ChildModule[nIndex])
	if nil==ChildModule[nIndex] then
		showTips("该功能暂未开放")
	else
		if nIndex == 3 then
			DCEvent.onEvent("点击远征")
			if srv_userInfo.level < 25 then
	            showTips("25级解锁远征玩法")
	            return
            end
            self.nCurChildModule = nIndex
			g_nCurChildModule = nIndex
			ChildModule[nIndex].new()
			:addTo(self)
        elseif nIndex == 2 then
        	DCEvent.onEvent("点击遗迹探测")
        	if srv_userInfo.level < 20 then
	            showTips("20级解锁遗迹探测")
	            return
	        end
	        self.nCurChildModule = nIndex
			g_nCurChildModule = nIndex
			ChildModule[nIndex].new()
			:addTo(self)
            self.mainFrame:setVisible(false)
		elseif nIndex ==1 then
			DCEvent.onEvent("点击世界BOSS")
        	if srv_userInfo.level < 30 then
	            showTips("30级解锁世界BOSS")
	            return
	        end
	        if bIsBossClose then
	        	-- showTips("现在不是开启时间")
	        	-- return
	        end
			self.nCurChildModule = nIndex
			g_nCurChildModule = nIndex
			ChildModule[nIndex].new()
			:addTo(display.getRunningScene(),60)
		end		  
		 
	end
end

--退出子模块(self.nCurChildModule 有值的时候才能使用)
function WarriorsCenterLayer:ExitChildModule()
	if self.nCurChildModule then
		ChildModule[self.nCurChildModule].Instance:removeFromParent()
	end
	self.nCurChildModule = nil
	self.mainFrame:setVisible(true)
end

function WarriorsCenterLayer:onEnter()
	WarriorsCenterLayer.Instance = self
	self:sendGetServerTime()
end

function WarriorsCenterLayer:onExit()
	WarriorsCenterLayer.Instance = nil
	mainscenetopbar:show()
	stopCountDown(self.bossColdHandle)

	--资源释放
	display.removeSpriteFramesWithFile("Image/UIWarriorsCenter.plist", "Image/UIWarriorsCenter.png")
end

function WarriorsCenterLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 12703 ==_guideId or 12803 ==_guideId  then
    	if 12703==_guideId then
    		g_node = self.guideBtn
    	elseif 12803==_guideId then
    		g_node = self.guideBtn2
    	end
        
        size = g_node:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

--获取服务器时间，格式为：18:18:18
function WarriorsCenterLayer:sendGetServerTime()
	startLoading()
	local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_GETSERVER_TIME, self, self.OnGetServerTimeRet)
end

function WarriorsCenterLayer:OnGetServerTimeRet(cmd)
	endLoading()
	if 1==cmd.result then
		local srvTimeStr = cmd.data.time
		print("服务器时间： "..srvTimeStr)
		print("本地时间： ",os.date("%H:%M:%S"))
		if srv_userInfo.level>=30 then
			print("------------------",self.bossBg)
			local tmpNode,tmpSize
			tmpSize = self.bossBg:getContentSize()
			tmpNode = display.newTTFLabel{text = "倒计时：",color = display.COLOR_RED,size = 25}
				:addTo(self.bossBg)
				:align(display.LEFT_CENTER,tmpSize.width/2-115,60)
				if g_isBanShu then
					tmpNode:hide()
				end
				
			local coldLbl = display.newTTFLabel{text = "12:00:00",color = display.COLOR_WHITE,size = 25}
					:addTo(self.bossBg)
					:align(display.LEFT_CENTER,tmpNode:getPositionX()+tmpNode:getContentSize().width,tmpNode:getPositionY())
					if g_isBanShu then
						coldLbl:hide()
					end

			local openLbl = display.newTTFLabel{text = "12:00".."开启",color = display.COLOR_WHITE,size = 32}
					:addTo(self.bossBg)
					:align(display.CENTER,tmpSize.width/2,120)
					if g_isBanShu then
						openLbl:hide()
					end

			local function _onTime(count,eventName)
				local min = count/60
				local sec = count%60
				local hour= min/60
				min = min%60

				coldLbl:setString(string.format("%02d:%02d:%02d",hour,min,sec))
			end

			
			local _secend_1 = getSecendFromNowTo_("12:30",srvTimeStr)
			local _secend_2 = getSecendFromNowTo_("13:30",srvTimeStr)
			local _secend_3 = getSecendFromNowTo_("20:00",srvTimeStr)
			local _secend_4 = getSecendFromNowTo_("21:00",srvTimeStr)

			local _secend_5 = getSecendFromNowTo_("24:00",srvTimeStr)
			if  _secend_1>0 then --不到12点半
				self.bossColdHandle = startCountDown(_secend_1,1,_onTime)
				openLbl:setString("12:30开启")
				bIsBossClose = true
			elseif _secend_2>0 then --不到13点半
				self.bossColdHandle = startCountDown(_secend_2,1,_onTime)
				openLbl:setString("13:30关闭")
				bIsBossClose = false
			elseif _secend_3>0 then --不到20点
				self.bossColdHandle = startCountDown(_secend_3,1,_onTime)
				openLbl:setString("20:00开启")
				bIsBossClose = true
				print("-----------bIsBossClose",bIsBossClose)
			elseif _secend_4>0 then --不到21点
				self.bossColdHandle = startCountDown(_secend_4,1,_onTime)
				openLbl:setString("21:00关闭")
				bIsBossClose = false
			elseif _secend_5>0 then --不到24点
				_secend_5 = _secend_5 + 12*3600
				self.bossColdHandle = startCountDown(_secend_5,1,_onTime)
				openLbl:setString("明天12:30开启")
				bIsBossClose = true
			end
		end
	else
		showTips(cmd.msg)
	end
end

return WarriorsCenterLayer