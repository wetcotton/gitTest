--
-- Author: Jun Jiang
-- Date: 2015-05-11 12:03:14
--
local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)
LoadingScene.Instance = nil
SceneType = {
	Type_Main = 1,
	Type_Battle = 2,
	Type_Block = 3,
    Type_Expedition = 4,
    Type_PVP = 5,
}
local modules = {}
modules[SceneType.Type_Main] = {
	g_MainScene,
}

modules[SceneType.Type_Battle] = {
	g_BattleScene,
}

modules[SceneType.Type_Block] = {
    g_blockMap,
	g_MainScene,
}

modules[SceneType.Type_Expedition] = {
    g_ExpeditionScene,
}

modules[SceneType.Type_PVP] = {
    g_PVPScene,
}


function LoadingScene:goToTheScene()
	if IsStartFight==true then
		cc.Director:getInstance():popScene()
		cc.Director:getInstance():pushScene(self.gotoSceneName.new())
	else
		app:enterScene(self.gotoSceneName)
	end
end

function LoadingScene:ctor(...)
	local layer = display.newLayer()
			:addTo(self)
	layer:setNodeEventEnabled(true)
	-- math.randomseed(os.time())
	self.tmpModules = {}
	self.gotoSceneName = ""
	local params = {...}

    local _SceneType = params[1] or SceneType.Type_Main
    self.tmpModules = modules[_SceneType]
    
	if _SceneType == SceneType.Type_Battle then
		self.gotoSceneName = "BattleScene"
	elseif  _SceneType == SceneType.Type_Expedition then
        self.gotoSceneName = "ExpeditionScene"
    elseif _SceneType == SceneType.Type_PVP then
        self.gotoSceneName = "PVPScene"
    else
        self.gotoSceneName = "MainScene"
	end

	if IsStartFight==true then
		local scene = g_startFightBattleScene
		self.gotoSceneName = scene
	end

    
end

function LoadingScene:addProgressUI()
	--资源加载
	-- display.addSpriteFrames("startAnimation/UIBird.plist", "startAnimation/UIBird.png")
    
	-- self.lab = display.newTTFLabel({text = "", size = 22, color = display.COLOR_WHITE})
	-- 			:align(display.CENTER, display.cx, display.height*0.35)
	-- 			:addTo(self,10)
    --进度条
    local blackBg = {}
    for i=1,50 do
        blackBg[i] = display.newSprite("loading/loadin_img2.png")
        :addTo(self)
        :align(display.CENTER_LEFT, (i-1)*31, 60)
    end
    local blackBgSize = cc.size(display.width, blackBg[1]:getContentSize().height)

    self._progressBar = cc.ui.UILoadingBar.new({image = "loading/loadin_img1.png", viewRect = cc.rect(0,0,1281, 31)})
    :addTo(self)
    :pos(0, 44)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "玩 命 加 载 中", size = 28})
    :addTo(self, 10 )
    :align(display.CENTER, display.width/2, 60)
    setLabelStroke(label,28,nil,nil,nil,nil,nil,nil, true)


    -- local blackBg = cc.Sprite:create("Launcher/youyu_gex-01.png")
    -- blackBg:setScale(0.8)
    -- blackBg:setPosition(display.cx, display.height*0.3)
    -- self:addChild(blackBg)
    
    -- local progressBarBg = cc.Sprite:create("Launcher/youyu_gex-04.png")
    -- progressBarBg:setPosition(blackBgSize.width*0.52, blackBgSize.height*0.48)
    -- blackBg:addChild(progressBarBg,5)

    -- local upDi = cc.Sprite:create("Launcher/youyu_gex-07.png")
    -- upDi:setPosition(blackBgSize.width*0.14, blackBgSize.height*0.64)
    -- blackBg:addChild(upDi)
    -- local downDi = cc.Sprite:create("Launcher/youyu_gex-06.png")
    -- downDi:setPosition(blackBgSize.width*0.14, blackBgSize.height*0.32)
    -- blackBg:addChild(downDi)
    -- local upC = cc.Sprite:create("Launcher/youyu_gex-08-01.png")
    -- upC:setPosition(blackBgSize.width*0.11, blackBgSize.height*0.64)
    -- blackBg:addChild(upC)
    -- upC:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,-360)))
    -- local upL = cc.Sprite:create("Launcher/youyu_gex-08-02.png")
    -- upL:setPosition(blackBgSize.width*0.11, blackBgSize.height*0.64)
    -- blackBg:addChild(upL)
    -- upC:setScale(0.6)
    -- upL:setScale(0.6)
    -- local downC = cc.Sprite:create("Launcher/youyu_gex-08-01.png")
    -- downC:setPosition(blackBgSize.width*0.06, blackBgSize.height*0.48)
    -- blackBg:addChild(downC,8)
    -- downC:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
    -- local downL = cc.Sprite:create("Launcher/youyu_gex-08-02.png")
    -- downL:setPosition(blackBgSize.width*0.06, blackBgSize.height*0.48)
    -- blackBg:addChild(downL,8)

    -- self._progressBar = cc.ProgressTimer:create(cc.Sprite:create("Launcher/youyu_gex-03.png"))
    -- self._progressBar:setType(display.PROGRESS_TIMER_BAR)
    -- self._progressBar:setMidpoint({x = 0, y = 0.5})
    -- self._progressBar:setBarChangeRate({x = 1.0, y = 0})
    -- self._progressBar:setPosition(blackBgSize.width*0.48, blackBgSize.height*0.48)
    -- blackBg[1]:addChild(self._progressBar,6)
    -- self._progressBarSize = self._progressBar:getContentSize()

    -- self._progressHead = cc.Sprite:create("Launcher/youyu_gex-02.png")
    -- self._progressHead:setPosition(-self._progressHead:getContentSize().width*0.36, self._progressBarSize.height*0.5)
    -- self._progressBar:addChild(self._progressHead)
    -- self._progressHead:setVisible(false)

    -- self._lightSp = cc.Sprite:create("Launcher/youyu_gex-08.png")
    -- self._lightSp:setPosition(blackBgSize.width*0.94, blackBgSize.height*0.48)
    -- blackBg:addChild(self._lightSp,10)
    -- self._lightSp:setVisible(false)

    --鸟
    -- local birds = {}
    -- for i=1, 3 do
    -- 	birds[i] = display.newSprite("#buq0001.png", display.cx+100-(i-1)*100, display.height*0.47)
    --     				:addTo(self)

    --     local frames = display.newFrames("buq%04d.png", 1, 25)
	   --  local animation = display.newAnimation(frames, 1/25)
	   --  transition.playAnimationForever(birds[i], animation, 0.1*i)
    -- end

 --    local cars = {}
 --    local tips = {}
 --    for i=1,#randTipsData do
 --    	if("null"~=randTipsData[i].car) then
 --    		table.insert(cars,randTipsData[i].car)
 --    	end
 --    	if("null"~=randTipsData[i].tips) then
 --    		table.insert(tips,randTipsData[i].tips)
 --    	end
 --    end
   
 --    math.random(1,2)--随机数还没搞明白，为什么第一次随机无效？
 --    local idx_tips = tips[math.random(1,#tips)]
 --    printTable(cars)
 --    local vv = math.random(1,#cars)
 --    print(vv)
 --    local idx_car = cars[vv]

 --    self.idx_car = idx_car
 --    --tips小提示
	-- local tipsLabel = display.newTTFLabel({
	-- 		    		text = idx_tips,
	-- 		            size = 20,
	-- 		            color = cc.c3b(255, 255, 0),
	-- 		            align = cc.TEXT_ALIGNMENT_CENTER,
	-- 		            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	-- 		    		})
	--                     :pos(display.cx-180, display.height*0.18)
	-- 		    		:align(display.LEFT_CENTER)
	-- 		    		:addTo(self)
 --    --车
 --    if idx_car == nil then
 --    	idx_car = 1010
 --    end
 --   -- idx_car = nil
 --    self.car = GlobalCreateModel(ModelType.Tank, idx_car, 1)
 --    if self.car==nil then
 --    	print("坦克创建失败，失败坦克ID："..idx_car)
 --    	self.car =GlobalCreateModel(ModelType.Tank, 1070, 1)
 --    end

	-- self.car:pos(display.cx-240, display.height*0.4)
	-- self.car:addTo(self)

	-- SetModelParams(self.car, {fScale=0.4})
	-- self.car:getAnimation():play("walk")

end

function LoadingScene:onEnter()
	LoadingScene.Instance = self
	display.removeUnusedSpriteFrames()
	self:addProgressUI()
	self:InitData()
	if self.resNum>0 then
		self:LoadResAsync()
	else
		-- self.lab:setString("")
		self:goToTheScene()
	end

    self:createLoadingBounty()
end

function LoadingScene:onExit()
	LoadingScene.Instance = nil
    print("onExit:  LoadingScene---------------------------")
	--资源释放
	-- display.removeSpriteFramesWithFile("startAnimation/UIBird.plist", "startAnimation/UIBird.png")

	-- local strPath_1 = "Battle/Tank/Tank_"..self.idx_car.."_.ExportJson"
	-- local strPath_2 = "Battle/Tank/Tank_"..self.idx_car.."_0.plist"
	-- local strPath_3 = "Battle/Tank/Tank_"..self.idx_car.."_0.png"

	--print("---------------------------------------------------------=======")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(strPath_1)
	display.removeSpriteFramesWithFile(strPath_2, strPath_3)
	
    --print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    --print("---------------------------------------------------------=======")
end

--图片资源异步加载回调
function LoadingScene:ImgDataLoaded(plist, image)
	self.loadedNum = self.loadedNum+1
	self.percent = self.loadedNum/self.resNum
    -- print("loading percent "..self.percent)
    -- self:ArmatureDataLoaded(percent)
	if self.percent>=1.0 then
		-- self.lab:setString("Loading...100%")
		self._progressBar:setPercent(100)
		-- self._lightSp:setVisible(true)
		-- if nil~=self.actMove then
		-- 	transition.removeAction(self.actMove)
		-- 	self.actMove = nil
		-- end
		-- self.actMove = transition.moveTo(self.car, {x=display.cx+240, time=0.1})
		-- transition.execute(self, cc.DelayTime:create(0.1), {onComplete = function()
		-- 	self:goToTheScene()
		-- end})
        self:performWithDelay(function ()
            self:goToTheScene()
            end,0.1)
        
	else
		local num = math.floor(self.percent*100)
		-- self.lab:setString("Loading..." .. num .. "%")
		self._progressBar:setPercent(num)
		-- if nil~=self.actMove then
  --           print("remove action")
		-- 	transition.removeAction(self.actMove)
		-- 	self.actMove = nil
		-- end
  --       print(self.car:getPositionX())
		-- self.actMove = transition.moveTo(self.car, {x=display.cx-240+480*self.percent, time=0.1},
  --           onComplete = 
  --           function()
  --               self.car:setPositionX(display.cx-240+480*self.percent)
  --               end)
        -- self.car:setPositionX(display.cx-240+480*self.percent)
        -- print(display.cx-240+480*self.percent)
	end
end

--骨骼动画异步加载回调
function LoadingScene:ArmatureDataLoaded(percent)
	self.loadedNum = self.loadedNum+1
	self.percent = self.loadedNum/self.resNum
	if self.percent>=1.0 then
		-- self.lab:setString("Loading...100%")
		self._progressBar:setPercent(100)
		-- self._lightSp:setVisible(true)
		-- if nil~=self.actMove then
		-- 	transition.removeAction(self.actMove)
		-- 	self.actMove = nil
		-- end
		-- self.actMove = transition.moveTo(self.car, {x=display.cx+240, time=0.1})
		-- transition.execute(self, cc.DelayTime:create(0.1), {onComplete = function()
		-- 	self:goToTheScene()
		-- end})
	else
		local num = math.floor(self.percent*100)
		-- self.lab:setString("Loading..." .. num .. "%")
		-- self._progressBar:setPercent(num)
		-- if nil~=self.actMove then
		-- 	transition.removeAction(self.actMove)
		-- 	self.actMove = nil
		-- end
		-- self.actMove = transition.moveTo(self.car, {x=display.cx-240+480*self.percent, time=0.1})
	end
end

--资源异步加载数据初始化
function LoadingScene:InitData()
	self.resNum = 0 		--待加载资源总数
	self.loadedNum = 0 		--已加载资源数
	self.percent = 0.0 	--加载百分比(0-1)
	-- self.lab:setString("0%")

	--计算待加载资源总
	for i=1, #self.tmpModules do
		if nil~=self.tmpModules[i] then
			self.resNum = self.resNum+self.tmpModules[i]:GetResNum()
		end
	end
end

--异步加载资源
function LoadingScene:LoadResAsync()
	for i=1, #self.tmpModules do
		if nil~=self.tmpModules[i] then
			self.tmpModules[i]:LoadResAsync()
		end
	end
end

--加载界面的通缉令
function LoadingScene:createLoadingBounty()
    local bossDataList = {} --有赏金首大区数据
    for i,value in pairs(areaData) do
        if value.bossId~=0 then
            local tmpdata = value
            table.insert(bossDataList,tmpdata)
        end
    end

    --赏金首框
    local bountyBox = display.newSprite("bounty/bounty2_img7.png")
    :addTo(self)
    :pos(display.cx, display.cy+50)

    --boss模型
    local randIdx = math.random(#bossDataList)
    local locArea = bossDataList[randIdx]
    local locBossData = monsterData[areaData[locArea.id].bossId]

    local dx = 260
    if locBossData.id==21014008 or locBossData.id==61014008 then
        dx = 340
    end
    
    local resName = monsterData[locBossData.id].resId
    local boss
    if monsterData[locBossData.id].actType==1 then --cocos动画
        local manager = ccs.ArmatureDataManager:getInstance()
        manager:removeArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        manager:addArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        boss = ccs.Armature:create("Monster_"..resName.."_")
        :addTo(bountyBox)
        :pos(dx,bountyBox:getContentSize().height/2)
        :scale(locArea.bossScale)
        boss:setAnchorPoint(0.5,0.5)
        boss:getAnimation():play("Standby")
        boss:getAnimation():gotoAndPlay(0)
    else
        boss = sp.SkeletonAnimation:create("Battle/Monster/Monster_"..resName.."_.json","Battle/Monster/Monster_"..resName.."_.atlas",1)
        :addTo(bountyBox)
        :pos(dx,bountyBox:getContentSize().height/2)
        :scale(locArea.bossScale)
        boss:setAnimation(0, "Standby", true)
        boss:performWithDelay(function ( ... )
            boss:setPositionY(bountyBox:getContentSize().height/2-boss:getBoundingBox().height*0.4)
        end,0)
        
        
    end
    

    --名字
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 35, color = cc.c3b(178, 8, 8)})
    :addTo(bountyBox)
    :align(display.CENTER, bountyBox:getContentSize().width/2 + 210, bountyBox:getContentSize().height-170)
    label:setString(locBossData.name)

    display.newSprite("bounty/bounty2_img11.png")
    :addTo(bountyBox)
    :pos(label:getPositionX()- (label:getContentSize().width/2 + 20), label:getPositionY())

    display.newSprite("bounty/bounty2_img11.png")
    :addTo(bountyBox)
    :pos(label:getPositionX()+ (label:getContentSize().width/2 + 20), label:getPositionY())
    :setScaleX(-1)

    --描述
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28, color = display.COLOR_BLACK})
    :addTo(bountyBox)
    :align(display.LEFT_TOP, bountyBox:getContentSize().width/2 + 40, bountyBox:getContentSize().height-200)
    label:setString(locBossData.des)
    label:setWidth(340)

    --悬赏金
    display.newSprite("bounty/bounty2_img9.png")
    :addTo(bountyBox)
    :pos(bountyBox:getContentSize().width/2 + 100, bountyBox:getContentSize().height/2-60)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(bountyBox)
    :pos(bountyBox:getContentSize().width/2 + 290, bountyBox:getContentSize().height/2-60)
    :setScaleX(0.9)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(bountyBox)
    :pos(bountyBox:getContentSize().width/2 - 270, 60)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(bountyBox)
    :pos(bountyBox:getContentSize().width/2 + 270, 60)

    display.newSprite("bounty/bounty2_img8.png")
    :addTo(bountyBox)
    :pos(bountyBox:getContentSize().width/2 , 60)

    local dx = 460
    local dy = 50
    local rewardsPos = {
    cc.p(100+dx,95+dy),
    cc.p(180+dx,95+dy),
    cc.p(260+dx,95+dy),
    cc.p(340+dx,95+dy),
    }

    self.rewardsIcon = {}
    local rewardIdx = 0
    local rewards = string.split(locArea.bounty, "|")
    --物品
    local items = string.split(rewards[1], ";")
    --金币
    local golds = tonumber(rewards[2]) 
    --钻石
    local diamond = tonumber(rewards[3])
    if golds>0 then
        rewardIdx = rewardIdx + 1
        self.rewardsIcon[rewardIdx] = GlobalGetSpecialItemIcon(GAINBOXTPLID_GOLD, golds,0.7)
        :addTo(bountyBox)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
        -- :scale(1.2)
    end
    if diamond>0 then
        rewardIdx = rewardIdx + 1
        self.rewardsIcon[rewardIdx] = GlobalGetSpecialItemIcon(GAINBOXTPLID_DIAMOND, diamond, 0.7)
        :addTo(bountyBox)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
        -- :scale(1.2)
    end
    for i=1,#items do
        rewardIdx = rewardIdx + 1
        local item = string.split(items[i], "#")
        -- printTable(item)
        self.rewardsIcon[rewardIdx] = createItemIcon(item[1],item[2])
        :addTo(bountyBox)
        :scale(0.6)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
    end
    
end

return LoadingScene