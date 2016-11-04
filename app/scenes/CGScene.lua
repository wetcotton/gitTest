--
-- Author: Jun Jiang
-- Date: 2015-05-15 10:41:20
--
-- local CGScene = class("CGScene", function()
-- 	return display.newColorLayer(cc.c4b(0, 0, 0, 255))
-- end)

-- local Steps = 
-- {
-- 	{talkId=1, posX=627, posY=561},
-- 	{talkId=2, posX=561, posY=528},
-- 	{talkId=3, posX=957, posY=528},
-- 	{talkId=4, posX=579, posY=528},
-- 	{talkId=5, posX=640, posY=528},
-- }

-- function CGScene:ctor(params)
-- 	if nil==params then
-- 		params = {}
-- 	end
-- 	local function default()
-- 		print("OnComplete")
-- 	end

-- 	self.OnComplete = params.OnComplete or default	--结束回调

-- 	self.bg = display.newSprite("CG/bg_1.jpg")
-- 				:align(display.CENTER, display.cx, display.cy)
-- 				:addTo(self)
-- 	self.talk = display.newSprite()
-- 					:addTo(self.bg)
-- 	self.bg:setVisible(false)
-- 	self.talk:setVisible(false)

-- 	self.wl = display.newColorLayer(cc.c4b(255, 255, 255, 255))
-- 				:addTo(self)
-- 	self.wl:setVisible(false)

-- 	self.lab = display.newTTFLabel({text="", size=40, color=cc.c3b(255, 0, 0)})
-- 				:align(display.CENTER, display.cx, display.cy)
-- 				:addTo(self)

-- 	self:AutoRun()
-- end

-- function CGScene:RunStep(nIndex)
-- 	if nil==nIndex or nil==Steps[nIndex] then
-- 		self.wl:setVisible(true)
-- 		self.lab:setString("啊啊！诶，这是怎么！小霸王吃人了哇！啊。。。")
-- 		self.lab:setOpacity(255)
-- 		self:performWithDelay(function()
-- 			self.OnComplete()
-- 			self:removeFromParent()
-- 		end, 2)
-- 		return
-- 	end
-- 	local stepCfg = Steps[nIndex]

-- 	local tmpPath = string.format("CG/talk_%d.png", stepCfg.talkId)
-- 	self.talk:setTexture(tmpPath)
-- 	self.talk:setPosition(stepCfg.posX, stepCfg.posY)
-- 	self.talk:setVisible(true)
-- end

-- function CGScene:AutoRun()
-- 	self.nCurStep = 1
-- 	self.bg:setVisible(true)
-- 	local seq = transition.sequence({
-- 		cc.CallFunc:create(function()
-- 			self:RunStep(self.nCurStep)
-- 			self.nCurStep = self.nCurStep+1
-- 		end),
-- 		cc.DelayTime:create(3.0)
-- 		})
-- 	local rep = cc.RepeatForever:create(seq)
-- 	self:runAction(rep)
-- end

-- return CGScene


local CGScene = class("CGScene", function()
	return display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 255))
end)

currentStep = 1 --是第一幕还是第二幕
-- CallBack = nil
_CGani = nil

function CGScene:_playAni()
	local aniStr = "startCG_1_1"
	local musictr = "audio/startAni/startAni_bgMusic_1.mp3"
    if currentStep==2 then
    	aniStr = "startCG_1_2"
    	musictr = "audio/startAni/startAni_bgMusic_3.mp3"
    end
    print("audio.playMusic(musictr, true)    "..musictr)

    audio.stopMusic(true)
    if currentStep==1 then
    	audio.playMusic(musictr, true)  
    elseif currentStep==2 then
		audio.playSound(musictr, false)  
    end
    if _CGani~=nil then
		_CGani:getAnimation():play(aniStr)
	end
end

function CGScene:ctor(params)
	startFightBattleScene_LoadResAsync()
	if nil==params then
		params = {}
	end
	local function default()
		print("OnComplete")
	end

	self.OnComplete = params.OnComplete or default	--结束回调
    
    print("start load Animation 1-========================")
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("startCG_1/startCG_1.ExportJson")
    _CGani = ccs.Armature:create("startCG_1")

    local function mCallback(_animation, _type, _name)
        self:movementCallback(_animation, _type, _name)
    end
    _CGani:getAnimation():setMovementEventCallFunc(mCallback)
    
    _CGani:addTo(self)
    		:align(display.CENTER,display.cx,display.cy)
    
    self:performWithDelay(function ()
    	self:onEnter()
    end,0.1)
    
    showLogLabel("进入cg动画，currentStep = "..currentStep)
    startFightBattleScene_addBattleFrameCache()
    
end

function CGScene:onEnter()
	self:_playAni()
	
end

function CGScene:onExit()
end

function CGScene:movementCallback(_animation, _type, _name)
	print("--===++")
	print(_animation)
	print(_type)
	print(_name)
	showLogLabel(_name)
	if _name=="startCG_1_1" then
		if _type==ccs.MovementEventType.complete then   --播放完第一幕
			--去战斗
			showLogLabel("第一幕播放完毕")
			currentStep = 2
			IsStartFight = true

			g_CGScene:_playAni()
			-- self:performWithDelay(function()
			-- 	local layer = display.newColorLayer(cc.c4b(0, 0, 0, 255))
   --                  :addTo(display.getRunningScene(),11)
	  --         	self.lab = display.newTTFLabel({
	  --           text="", 
	  --           size=40, 
	  --           color=cc.c3b(255, 255, 255),
	  --           align = cc.TEXT_ALIGNMENT_CENTER,
   --          	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	  --           --dimensions = cc.size(700, 80)
	  --           })
	  --             :align(display.CENTER_TOP, display.cx, display.cy)
	  --             :addTo(layer)
	  --         	self.lab:setString("在戈麦斯老巢营地……")
	  --         	local delaytime = 1
	  --         	local function callfunc()
	  --             	layer:removeFromParent()
	  --             	startFightBattleScene.new()
	  --               	:addTo(display.getRunningScene(),10)
	  --         	end
	  --         	layer:runAction(transition.sequence({ 
	  --                                             cc.DelayTime:create(delaytime),
	  --                                             cc.CallFunc:create(callfunc),
	  --                                           }))
			-- 	audio.stopMusic(true)
			-- end, 0.01)
		end
	elseif _name=="startCG_1_2" then
		if _type==ccs.MovementEventType.complete then   --播放完第二幕
			-- self.lab = display.newTTFLabel({text="", size=40, color=cc.c3b(255, 0, 0)})
			-- :align(display.CENTER, display.cx, display.cy)
			-- :addTo(self)
			-- self.lab:setString("啊啊！诶，这是怎么！小霸王吃人了哇！啊。。。")
			-- self.lab:setOpacity(255)
			-- self:performWithDelay(function()
				startFightBattleScene.Instance = nil
				IsStartFight = false
				self.OnComplete()
				self:removeFromParent()
			-- end, 1)
		end
	end
end

return CGScene