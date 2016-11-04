
require("cocos.cocostudio.DeprecatedCocoStudioClass")
require("pack")
require("app.battle.BattleInfo")
require("app.utils.GlobalFunc")
local HeroAI = require("app.battle.battleAI.HeroAI")
local MonsterAI = require("app.battle.battleAI.MonsterAI")
local BufferAI =require("app.battle.battleAI.BufferAI")
local LocalGameData = require("app.data.LocalGameData")
local Progress = require("app.battle.battleUI.HpProgress")
local ControlDesk = require("app.battle.battleUI.ControlDesk")
local BattleMessagePanel = require("app.battle.battleUI.BattleMessagePanel")
local PvpResultLayer = require("app.battle.PVP.PvpResultLayer")
local LegionOverLayer = require("app.battle.battleUI.LegionOverLayer")
local SpriteProgress = require("app.battle.battleUI.SpriteProgress")
local SpeStateNote = require("app.battle.battleUI.SpeStateNote")
local g_loadUtil = require("app.utils.asyncLoadUtils")

startFightBattleScene = class("startFightBattleScene", function()
	 local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

startFightStep = 1    --第一步，人战

_curDeffenceHp = {}  --记录敌方血量

curGuideBtn = nil

startFightBattleScene.Instance = nil

function startFightBattleScene:ctor()
  if g_IsDebug then
      local scalelab = display.newTTFLabel({text="", size=40, color=cc.c3b(255, 0, 0)})
                  :align(display.CENTER, display.cx, display.height-30)
                  :addTo(self,6666)
      cc.ui.UIPushButton.new({normal = "common/common_CloseBtn_1.png",pressed = "common/common_CloseBtn_2.png"})
      :onButtonClicked(function(event)
          local sharedScheduler = cc.Director:getInstance():getScheduler()
          local _float = sharedScheduler:getTimeScale()
          _float = _float/2
          sharedScheduler:setTimeScale(_float)
          scalelab:setString("当前TimeScale： ".._float)
      end)
      :pos(100, display.height-60)
      :addTo(self,6666)
      cc.ui.UIPushButton.new({normal = "common/common_add1.png",pressed = "common/common_add2.png"})
      :onButtonClicked(function(event)
          local sharedScheduler = cc.Director:getInstance():getScheduler()
          local _float = sharedScheduler:getTimeScale()
          _float = _float*2
          sharedScheduler:setTimeScale(_float)
          scalelab:setString("当前TimeScale： ".._float)
      end)
      :pos(200, display.height-60)
      :addTo(self,6666)
      local bol = true
      cc.ui.UIPushButton.new({normal = "common/common_add1.png",pressed = "common/common_add2.png"})
      :onButtonClicked(function(event)
          if bol then
            pauseTheBattle()
          else
            resumeTheBattle()
          end
          bol = not bol
      end)
      :pos(300, display.height-60)
      :addTo(self,6666)
  end

  startFightBattleScene.Instance = self
  GuideManager.IsFirstGuide = true
  print("startFightBattleScene:ctor()-------------------------begin")
  self:resetBattle()

  if startFightStep==1 then
    BattleID = 10000001
    GuideManager.NextStep=90101
    srv_userInfo.guideStep = 90101
  elseif startFightStep==2 then
    BattleID = 10000002
    GuideManager.NextStep=90102
    srv_userInfo.guideStep = 90102
  end
  
  --背景图片
  self.battlebg = display.newSprite()
  :addTo(self)
 
  CurBossID =  tonumber(blockData[BattleID]["type2"])

  bgStr = "Battle/BattleBg/scene_bg_1001.jpg"
  bgStr = "Battle/BattleBg/scene_bg_"..blockData[tonumber(BattleID)]["resId"]..".jpg"
  
  self.battlebg:setTexture(bgStr)
  self.battlebg:scale(1.333)
  self.battlebg:setPosition(display.width, display.cy)
  --新手引导底层
  self.guideBg = display.newLayer()
  :addTo(self,30)
  self.guideBg:setTouchEnabled(false)
  
     
       PlotBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPart"],"|")
       PlotDetailInfo = string.split(blockData[tonumber(BattleID)]["talkID"],"|")
       DialogBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPart2"],"|")
       DialogDetailInfo = string.split(blockData[tonumber(BattleID)]["talkID2"],"|")
       EvilBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPartEvil"],"|")
       EvilDetailInfo = string.split(blockData[tonumber(BattleID)]["talkIDEvil"],"|")

     AllBattleStep = 1
     CurBattleStep = 1
     
     --是否人物关卡
     if startFightStep==1 then
         IsMenBlock = true
         BlockTypeScale = MenBlockScale
     elseif startFightStep==2 then
         IsMenBlock = false
         BlockTypeScale = TankBlockScale
     end

     --是否有助战好友
     self.hasFriendHelp = false
     if BattleData["friCarTptId"] ~= nil then
         self.hasFriendHelp = true
     end

  --战斗成员
  self:initAllMember()
  --上层UI
  self:initAllUI()
  --加载特种弹
  if IsMenBlock == false and CurFightBattleType ~= FightBattleType.kType_PVP then
    self:addSeblts()
  end  
  print("GuideManager.NextStep:  "..GuideManager.NextStep.."wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    --能量恢复提示 仅新手引导第一关
  if string.sub(tostring(GuideManager.NextStep),1,5) == tostring(90101) then
      display.newSprite("Battle/xins_hermi-01.png")
      :pos(display.width*0.586, display.width*0.049)
      :addTo(self,26)
      display.newSprite("Battle/xins_hermi-02.png")
      :pos(display.width*0.5425, display.width*0.168)
      :addTo(self,26)
  end
  if string.sub(tostring(GuideManager.NextStep),1,5) == tostring(90102) then
      local note = display.newSprite("Battle/xins_hermi-02-01.png")
      :align(display.LEFT_BOTTOM,display.width*0.103, display.width*0.037)
      :addTo(self,26)
      --note:scale(0.85)
  end
  -- getPositionLayer.new()
  --               :addTo(self)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(...)
           self:update()
        end)
  self:scheduleUpdate()
  audio.stopMusic(true)
  audio.playMusic("audio/startAni/startAni_bgMusic_2.mp3", true)

  if startFightStep==2 then
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("Battle/Hero/Hero_1052_.ExportJson")
    manager:addArmatureFileInfo("Battle/Hero/Hero_1052_.ExportJson")
    self.redWolf = ccs.Armature:create("Hero_1052_")
    self.redWolf:addTo(self,100)
      :pos(120,200)
    self.redWolf:setScale(0.35)
    self.redWolf:setScaleX(-self.redWolf:getScaleX())
    self.redWolf:getAnimation():play(MemberAnimationType.kMemberAnimationDead)

  end

  self:addSceneEff()
  print("startFightBattleScene:ctor()-------------------------end")
end

function startFightBattleScene:addSceneEff()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("Battle/BattleEff/guafeng.ExportJson")
    manager:addArmatureFileInfo("Battle/BattleEff/guafeng.ExportJson")
    local sceneEff = ccs.Armature:create("guafeng")
    :pos(display.width*0.5,display.height*0.5)
    :addTo(self,38)
    sceneEff:getAnimation():play("Feng")
end

function startFightBattleScene:update(dt)
    if startFightStep==1 then   --当红狼血条见底时，记录boss血量，并进入下车战
        for k,v in pairs(MemberAttackList) do
            --print(v.m_attackInfo.tptName..",   curHp:  "..v.m_attackInfo.curHp.."    ,maxHp  :   "..v.m_attackInfo.maxHp)
            if v.m_attackInfo.curHp*100/v.m_attackInfo.maxHp<30 then
                for k,v in pairs(MemberDeffenceList) do
                    -- print(type(v.m_attackInfo))
                    if v.m_attackInfo~=nil then
                      _curDeffenceHp[v.fightPos] = v.m_attackInfo.curHp
                      -- print(v.m_attackInfo.tptName.."  _curDeffenceHp  : "..v.m_attackInfo.curHp)
                    end
                end
                self:unscheduleUpdate()
                self:runToTankWar()
              break
            end
        end
    elseif startFightStep==2 then  --当boss快死时，返回CG动画
        for k,v in pairs(MemberDeffenceList) do
            if v.m_attackInfo~=nil then
                if CurBossID == tonumber(v.m_attackInfo.tptId) then 
                  --print(v.m_attackInfo.tptName..",   curHp:  "..v.m_attackInfo.curHp.."    ,maxHp  :   "..v.m_attackInfo.maxHp)
                    if v.m_attackInfo.curHp*100/v.m_attackInfo.maxHp<20 then
                      self:unscheduleUpdate()
                      self:backToCGScene()
                    end
                end
            end
        end
    end
end


function startFightBattleScene:sebltCallBack(_event)
    if _event.callType == SpriteProgressCallType.kCall_Click then
        self:chooseSeBullet(_event.callId)
        print("选中")
    elseif _event.callType == SpriteProgressCallType.kCall_Ready then

        self.speNote:showSpeNode(_event.callId,SpeNoteState.Spe_Ready)
        local frames1 = display.newFrames("SeReadyFrames_%02d.png", 0, 15)
        local animation1 = display.newAnimation(frames1, 1/15)
        local aniAction1 = cc.Animate:create(animation1)
        self.sebltControls[_event.callId].okSp:setVisible(true)
        self.sebltControls[_event.callId].okSp:runAction(transition.sequence({
                                                                               aniAction1,
                                                                               cc.CallFunc:create(function()
                                                                                 self.sebltControls[_event.callId].okSp:setVisible(false)
                                                                               end)
                                                                             }))
        curGuideBtn = _event.callSp
        if  not getIsGuideClosed() and GuideManager.NextStep == 90103 then
          GuideManager:_addGuide_2(90103, self.guideBg,handler(self,self.caculateGuidePos),101)
          pauseTheBattle()
          _event.callSp:resumeCooling()
          print("暂停，90103")
          self.skillLayer:setVisible(false)
        end
    else
        print("sebltCallBack Error")
    end

end

function startFightBattleScene:addSeblts()
    --左侧提示框
    self.speNote = SpeStateNote.new()
    :pos(0,display.height*0.7)
    :addTo(self,40)
    self.chooseCircle = display.newSprite("Battle/sechoose.png")
    :addTo(self,40)
    self.chooseCircle:setVisible(false)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if self.chooseSeId == nil or self.chooseSeId == 0 then
          return true
        end
        if event.name == "began" then
            self.chooseCircle:setVisible(true)
            self.chooseCircle:setPosition(event.x, event.y)
        elseif event.name == "moved" then
            self.chooseCircle:setPosition(event.x, event.y)
            if event.x < display.width*0.5 or event.y > display.height*0.6 or event.y < display.height*0.28 then
                self.chooseCircle:setTexture("Battle/sechoose_gray.png")
            else
                self.chooseCircle:setTexture("Battle/sechoose.png")
            end
        elseif event.name == "ended" then
            if event.x < display.width*0.5 or event.y > display.height*0.6 or event.y < display.height*0.28 then
                print("无效的攻击区域")
                printTable(event)
                self.sebltControls[self.chooseSeId].chooseSp:setVisible(false)
                self.chooseSeId = 0
                self.chooseCircle:setVisible(false)
            else
                resumeTheBattle()
                GuideManager:removeGuideLayer()
                local useSeId = self.chooseSeId
                self.chooseSeId = 0
                self:showSeblt({x = event.x, y = event.y},useSeId)
                self.speNote:showSpeNode(useSeId,SpeNoteState.Spe_Fire)
                self.sebltControls[useSeId]:startCooling()
                self.sebltControls[useSeId].chooseSp:setVisible(false)
                self.chooseCircle:setVisible(false)
                self.sebltControls[useSeId]:afterUseSeblt()
            end
            
        end
        return true
    end)
    self.sebltControls = {}
    for i = 1,3 do
       local bulletid = BattleFormatInfo["matrix"][string.format("bullet%d",i)]
       if bulletid > -1 then
           BulleHasNums[i] = {id = 0, num = 0}
           for j = 1, #BattleFormatInfo["seBlts"] do
               if BattleFormatInfo["seBlts"][j]["id"] == bulletid then
                   if BattleFormatInfo["seBlts"][j]["count"] ~= 0 and tonumber(BattleFormatInfo["seBlts"][j]["templateId"]) ~= 1075007 and tonumber(BattleFormatInfo["seBlts"][j]["templateId"]) ~= 1075009 then                        
                        BulleHasNums[i] = {id = BattleFormatInfo["seBlts"][j]["templateId"], num = BattleFormatInfo["seBlts"][j]["count"]}
                   end
                 break
               end
           end
       end
    end
    local seBg = display.newSprite("Battle/battleImg_22.png")
    :pos(display.width*0.78,display.height*0.08)
    :addTo(self,25)
    local seBgSize = seBg:getContentSize()
    g_spriteProgress = {}
    for i=1,3 do
       display.newSprite("Battle/battleImg_21.png")
       :pos(seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.5)
       :addTo(seBg)
       if BulleHasNums[i] == nil then
          display.newSprite("Battle/battleImg_23.png")
          :pos(seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.5)
          :addTo(seBg)
       elseif BulleHasNums[i] ~= nil and BulleHasNums[i].id ~= 0 and  BulleHasNums[i].num > 0 then
          local sProgress = SpriteProgress.new("Battle/battleSeblt_"..BulleHasNums[i].id, itemData[BulleHasNums[i].id]["sklCD"], BulleHasNums[i].id,handler(self,self.sebltCallBack),BulleHasNums[i].num)
          :align(display.CENTER_BOTTOM,seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.15)
          :addTo(seBg)
          g_spriteProgress[BulleHasNums[i].id] = sProgress
          sProgress:startCooling()
          sProgress:performWithDelay(function()
            sProgress:pauseCooling()
          end, 0.01)
          sProgress.chooseSp = display.newSprite("Battle/SpeBullet/SeChoosed.png")
          :pos(sProgress:getContentSize().width*0.5, sProgress:getContentSize().height*0.5)
          :addTo(sProgress)
          sProgress.chooseSp:runAction(cc.RepeatForever:create(transition.sequence({
                                                                                      cc.FadeTo:create(0.3,50),
                                                                                      cc.FadeTo:create(0.3,255),
                                                                                   })))
          sProgress.chooseSp:setVisible(false)
          sProgress.okSp = display.newSprite("#SeReadyFrames_00.png")
          :pos(sProgress:getContentSize().width*0.5, sProgress:getContentSize().height*0.5)
          :addTo(sProgress)
          sProgress.okSp:setVisible(false)
          self.sebltControls[BulleHasNums[i].id] = sProgress
       end
    end
end

function startFightBattleScene:chooseSeBullet(_seId)
    for k,v in pairs(self.sebltControls) do
      if v ~= nil then
        v.chooseSp:setVisible(false)
      end
    end
    if self.chooseSeId == _seId then
        self.chooseSeId = 0
        return
    end
    self.sebltControls[_seId].chooseSp:setVisible(true)
    
    self.chooseSeId = _seId

    local effectRect = SpeEffectRect[tonumber(string.sub(tostring(_seId),6,7))] * display.width
    print(effectRect)
    local scaleNum = effectRect*2/self.chooseCircle:getContentSize().width
    print(scaleNum)
    self.chooseCircle:scale(scaleNum)
end

function startFightBattleScene:showSeblt(_targetPos,_useSeId)
  print("-----------------------showSeblt, _useSeId:  ".._useSeId)
    local startPos = {x = -display.width*0.06, y = display.height*0.92}
    local seblt = display.newSprite("#skillblt".._useSeId.."_00.png")
    :pos(startPos.x,startPos.y)
    :addTo(self,18)
    seblt:scale(0.5)
    local rotateNum = math.deg(math.atan(math.abs((startPos.y - _targetPos.y)/(startPos.x - _targetPos.x))))
    seblt:setRotation(rotateNum)

    local framesblt = display.newFrames("skillblt".._useSeId.."_%02d.png", 0, 2)
    local animationblt = display.newAnimation(framesblt, 0.3/3)
    local aniActionblt =  cc.RepeatForever:create(cc.Animate:create(animationblt))
    local distance = math.sqrt(math.pow(startPos.x - _targetPos.x, 2) + math.pow(startPos.y - _targetPos.y, 2))
    local moveTime = distance/(BulletMoveSpeed*2.5)
    local moveAction = cc.MoveTo:create(moveTime,cc.p(_targetPos.x,_targetPos.y))
    
    
    local speEpo,epoAction,speEpoUp,epoActionUp,speEpoDown,epoActionDown = nil
    if tonumber(_useSeId) ~= 1075005 and tonumber(_useSeId) ~= 1075006 and tonumber(_useSeId) ~= 1075008 then
        speEpo = display.newSprite("#skillepo".._useSeId.."_00.png")
        :addTo(self,18)
        speEpo:scale(1.5)
        speEpo:setVisible(false)
        local frameNum = SpeEpoFramesNum[tonumber(string.sub(tostring(_useSeId),6,7))]
        local epoframes = display.newFrames("skillepo".._useSeId.."_%02d.png", 1, frameNum)
        local epoanimation = display.newAnimation(epoframes, 0.05)
        epoAction = cc.Animate:create(epoanimation)
    else  --需要分层处理
        speEpoUp = display.newSprite("#skillepoup".._useSeId.."_00.png")
        :addTo(self,18)
        speEpoUp:scale(1.5)
        speEpoUp:setVisible(false)
        local frameNum = SpeEpoFramesNum[tonumber(string.sub(tostring(_useSeId),6,7))]
        local epoframesUp = display.newFrames("skillepoup".._useSeId.."_%02d.png", 1, frameNum)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown".._useSeId.."_00.png")
        :addTo(self,12)
        speEpoDown:scale(1.5)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown".._useSeId.."_%02d.png", 1, frameNum)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    end

    if tonumber(_useSeId) == 1075002 then
        speEpo:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.08)
    elseif tonumber(_useSeId) == 1075003 then
        speEpo:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.15)
    elseif tonumber(_useSeId) == 1075004 then
        speEpo:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.17)
    elseif tonumber(_useSeId) == 1075005 then
        speEpoUp:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.08)
        speEpoDown:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.08)
    elseif tonumber(_useSeId) == 1075006 then
        speEpoUp:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.13)
        speEpoDown:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.13)
    elseif tonumber(_useSeId) == 1075007 then
        speEpo:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.1)
    elseif tonumber(_useSeId) == 1075008 then
        speEpoUp:align(display.CENTER_BOTTOM,_targetPos.x - display.width*0.01,_targetPos.y-display.height*0.12)
        speEpoDown:align(display.CENTER_BOTTOM,_targetPos.x - display.width*0.01,_targetPos.y-display.height*0.12)
    elseif tonumber(_useSeId) == 1075009 then
        speEpo:align(display.CENTER_BOTTOM,_targetPos.x,_targetPos.y-display.height*0.1)
    end
    
    local function removeSkill()
        seblt:removeSelf()
        if tonumber(_useSeId) ~= 1075005 and tonumber(_useSeId) ~= 1075006 and tonumber(_useSeId) ~= 1075008 then
            speEpo:removeSelf()
        else
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
        end
        if _member ~= nil then
            _member:afterSkill()
        end
    end

    local function showEpoSp()
        seblt:setVisible(false)
        if tonumber(_useSeId) ~= 1075005 and tonumber(_useSeId) ~= 1075006 and tonumber(_useSeId) ~= 1075008 then
            speEpo:setVisible(true)
        else
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
    end
    local function effectSkill()
        local effectRect = SpeEffectRect[tonumber(string.sub(tostring(_useSeId),6,7))] * display.width

        for k,v in pairs(MemberDeffenceList) do
          if v ~= nil and v.m_isDead == false and math.sqrt(math.pow(v:getPositionX() - _targetPos.x, 2) + math.pow(v:getPositionY() - _targetPos.y, 2)) <= effectRect then
             v.buffControl:addBuffer(v,itemData[_useSeId]["buffId"])
          end
        end
    end
    seblt:runAction(cc.Spawn:create({
                                    aniActionblt,
                                    moveAction,
                                  }))
    if tonumber(_useSeId) ~= 1075005 and tonumber(_useSeId) ~= 1075006 and tonumber(_useSeId) ~= 1075008 then
        speEpo:runAction(transition.sequence({ 
                                        cc.DelayTime:create(moveTime),
                                        cc.CallFunc:create(showEpoSp),
                                        epoAction,
                                        cc.CallFunc:create(removeSkill)
                                      }))
    else
        speEpoUp:runAction(transition.sequence({ 
                                        cc.DelayTime:create(moveTime),
                                        cc.CallFunc:create(showEpoSp),
                                        epoActionUp,
                                        cc.CallFunc:create(removeSkill)
                                      }))
        speEpoDown:runAction(transition.sequence({ 
                                        cc.DelayTime:create(moveTime),
                                        epoActionDown,
                                      }))
    end
    
    self:runAction(transition.sequence({
                                        cc.DelayTime:create(moveTime+SpeEpoEffectDelay[tonumber(string.sub(tostring(_useSeId),6,7))]),
                                        cc.CallFunc:create(effectSkill)
                                      }))

end

function startFightBattleScene:initAllUI()
  
  --技能遮挡框
  self.skillLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,150))
  :addTo(self,SkillOcclusionLevel)
  self.skillLayer:setVisible(false)
  
  --操作框
  self:addControlDesk()

  
end

--加载操作框
function startFightBattleScene:addControlDesk()
    self.allControlDesk = {}
    g_allControlDesk = {}
    for i=1,3 do
        if MemberAttackList[i] ~= nil then
          local tempDesk = ControlDesk.new(MemberAttackList[i],i)
          :addTo(self,25)
          self.allControlDesk[i] = tempDesk
          self.allControlDesk[i].mType = MemberAttackList[i].m_memberType
          g_allControlDesk[i] = tempDesk
        end
    end
    self:resetControlDesk()
end

function startFightBattleScene:resetControlDesk()
    local  controlNum = 0
    
    if IsMenBlock == false or CurFightBattleType == FightBattleType.kType_PVP then
       for k,v in pairs(self.allControlDesk) do
          if v.mType == MemberAllType.kMemberHero then
             v:align(display.CENTER, display.width*0.12 + controlNum*display.width*0.21,v:getContentSize().height*0.5)
             controlNum = controlNum + 1
          end
       end
       for k,v in pairs(self.allControlDesk) do
          if v.mType ~= MemberAllType.kMemberHero then
             v:align(display.CENTER, display.width*0.12 + controlNum*display.width*0.21,v:getContentSize().height*0.5)
             controlNum = controlNum + 1
          end
       end
    else
       for k,v in pairs(self.allControlDesk) do
          if v ~= nil then
             controlNum = controlNum + 1
          end
       end
       local cIndex = 0
       if controlNum == 1 then
          for k,v in pairs(self.allControlDesk) do
             v:align(display.CENTER, display.width*0.5,v:getContentSize().height*0.5)
          end
       elseif controlNum == 2 then
          for k,v in pairs(self.allControlDesk) do
             cIndex = cIndex + 1
             v:align(display.CENTER, display.width*0.395 + (cIndex-1)*display.width*0.21,v:getContentSize().height*0.5)
          end
       elseif controlNum == 3 then
          for k,v in pairs(self.allControlDesk) do
             cIndex = cIndex + 1
             v:align(display.CENTER, display.width*0.29 + (cIndex-1)*display.width*0.21,v:getContentSize().height*0.5)
          end
       end
    end
      
end

--抖动
function startFightBattleScene:shakeBg(_level)
  local times = {}
  local ranges = {}
  if _level == nil or _level == 1 then
     times = {0.02,0.04,0.03,0.01}
     ranges = {-display.width*0.01,display.width*0.02,-display.width*0.015,display.width*0.005}
  elseif _level == 2 then
     times = {0.03,0.06,0.045,0.015}
     ranges = {-display.width*0.02,display.width*0.04,-display.width*0.03,display.width*0.01}
  else
     times = {0.04,0.08,0.06,0.02}
     ranges = {-display.width*0.04,display.width*0.08,-display.width*0.06,display.width*0.02}
  end
  self.battlebg:runAction(transition.sequence{
                                                cc.MoveBy:create(times[1],cc.p(0,ranges[1])),
                                                cc.MoveBy:create(times[2],cc.p(0,ranges[2])),
                                                cc.MoveBy:create(times[3],cc.p(0,ranges[3])),
                                                cc.MoveBy:create(times[4],cc.p(0,ranges[4])),
                                             })
end

--初始化个成员
function startFightBattleScene:initAllMember()
  testMemberData= BattleData["members"]
  --初始化并加载所有英雄
  MemberAttackList = {
                          [1] = nil,
                          [2] = nil,
                          [3] = nil,
                          [4] = nil,
                          [5] = nil,
                          [6] = nil,
                          [7] = nil,
                          [8] = nil,
                          [9] = nil,
                     }
	for i=1,table.getn(testMemberData) do
		local hero = HeroAI.new(testMemberData[i],MemberPosType.attackType)
		local pos = testMemberData[i].pos
		hero:setPosition(AttackPositions[pos][1]-display.width/2, AttackPositions[pos][2])
		if tonumber(pos) == 5 then
        self:addChild(hero,15)
    else
        self:addChild(hero,BattleDisplayLevel[pos])
    end
		MemberAttackList[pos] = hero
	end

  
    self:getAllMonster()
    --加载第一小关的怪物
    self:initMontsers(CurBattleStep)
  
  --加载资源缓存
  --startFightBattleScene_addBattleFrameCache()
end

function startFightBattleScene:getAllMonster()

    self.allMonsterInfo = {
      [1] = {},
      [2] = {},
      [3] = {}
    }
    local  monsterStrs = ""
    if 2==srv_userInfo.mainline and tonumber(blockData[tonumber(BattleID)]["campType"]) == 1 then  --恶
       monsterStrs = string.split(blockData[tonumber(BattleID)]["monstersEvil"],"|")
    else --善
       monsterStrs = string.split(blockData[tonumber(BattleID)]["monsters"],"|")
       
    end
    for i=1,table.getn(monsterStrs) do
      local oneMonsterStrs = string.split(monsterStrs[i],":")
      if tonumber(oneMonsterStrs[2]) == 1 then
        table.insert(self.allMonsterInfo[1],oneMonsterStrs)
      elseif tonumber(oneMonsterStrs[2]) == 2 then
        table.insert(self.allMonsterInfo[2],oneMonsterStrs)
      else
        table.insert(self.allMonsterInfo[3],oneMonsterStrs)
      end
    end
    -- print("[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[00000000000000")
    -- printTable(self.allMonsterInfo)
    -- print("[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[1111111111111")
end

function startFightBattleScene:GetResNum()
  -- printTable(BattleFormatInfo["matrix"])
  local num = 6
  if CurFightBattleType == FightBattleType.kType_PVP then
      num = num + 1
  else
      num = num + 1
    for i = 1,3 do
       local bulletid = BattleFormatInfo["matrix"][string.format("bullet%d",i)]
       if bulletid > -1 then
           for j = 1, #BattleFormatInfo["seBlts"] do
               if BattleFormatInfo["seBlts"][j]["id"] == bulletid then
                   num = num + 1
                   if tonumber(BattleFormatInfo["seBlts"][j]["templateId"]) ~= 1095001 then
                       num = num + 1
                   end
                   break
               end
           end
       end
    end
  end
  return num
end
function startFightBattleScene_LoadResAsync()
  do
    local _addspriteFrame = display.addSpriteFrames
    local acc= 0
    display.addSpriteFrames = function (png,plist,_callback)
        _callback = _callback or function ()
            acc = acc+1
            --print("acc: "..acc)
        end
        _addspriteFrame(png,plist,_callback)
    end
  --加载死亡特效
  display.addSpriteFrames("Battle/Skill/DeadEff.plist", "Battle/Skill/DeadEff.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/DeadEff.plist",pngStr = "Battle/Skill/DeadEff.png"})
  
  --加载机械怪冒烟特效
  _addspriteFrame("Battle/Skill/SmokeFrames.plist", "Battle/Skill/SmokeFrames.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/SmokeFrames.plist",pngStr = "Battle/Skill/SmokeFrames.png"})
   --加载技能冷却到位的特效资源
  display.addSpriteFrames("Battle/Skill/SkillOkRes.plist", "Battle/Skill/SkillOkRes.png" )
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/SkillOkRes.plist",pngStr = "Battle/Skill/SkillOkRes.png"})
  --加载特种弹冷却到位资源
  display.addSpriteFrames("Battle/SpeBullet/SeReadyFrames.plist", "Battle/SpeBullet/SeReadyFrames.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/SpeBullet/SeReadyFrames.plist",pngStr = "Battle/SpeBullet/SeReadyFrames.png"})

  --PVE主炮特种弹
  do
    --todo
    for i = 1,3 do
       local bulletid = BattleFormatInfo["matrix"][string.format("bullet%d",i)]
       if bulletid > -1 then
           for j = 1, #BattleFormatInfo["seBlts"] do
               if BattleFormatInfo["seBlts"][j]["id"] == bulletid then
                   local seTptId = BattleFormatInfo["seBlts"][j]["templateId"]
                   display.addSpriteFrames("Battle/SpeBullet/Skill"..seTptId..".plist", "Battle/SpeBullet/Skill"..seTptId..".png")
                   table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/SpeBullet/Skill"..seTptId..".plist",pngStr = "Battle/SpeBullet/Skill"..seTptId..".png"})
                   if tonumber(seTptId) ~= 1095001 then
                       local buffResStr = buffData[itemData[seTptId]["buffId"]]["buffResId"]
                       display.addSpriteFrames("Battle/Bullet/"..buffResStr..".plist", "Battle/Bullet/"..buffResStr..".png")
                       table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..buffResStr..".plist",pngStr = "Battle/Bullet/"..buffResStr..".png"})
                   end
                   break
               end
           end
       end
    end
  end
  --主角技能套用资源不对  暂时强制加载3连击的受击资源  记得删除！
  display.addSpriteFrames("Battle/Skill/beAtkEff_1012.plist", "Battle/Skill/beAtkEff_1012.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/beAtkEff_1012.plist",pngStr = "Battle/Skill/beAtkEff_1012.png"})
  --主炮
  display.addSpriteFrames("Battle/SpeBullet/Skill1095001.plist", "Battle/SpeBullet/Skill1095001.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/SpeBullet/Skill1095001.plist",pngStr = "Battle/SpeBullet/Skill1095001.png"})
  display.addSpriteFrames = _addspriteFrame
  end
end

function startFightBattleScene_addBattleFrameCache()
  --加载坦克尘土特效
  display.addSpriteFrames("Battle/Skill/dust_10001.plist", "Battle/Skill/dust_10001.png")
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/dust_10001.plist",pngStr = "Battle/Skill/dust_10001.png"})
  do
    local loadUtil = g_loadUtil.new()
    local _addspriteFrame = display.addSpriteFrames
    local acc= 0
    display.addSpriteFrames = function (plist,png,_callback)
        _callback = _callback or function ()
            acc = acc+1
            print("acc: "..acc)
        end
        --_addspriteFrame(plist,png,_callback)
        print(plist.."  ------  "..png)
        local a,b = string.find(png,".png")
        local format = string.sub(png,1,a-1)
        print("添加资源："..format)
        loadUtil:addRes(loadUtil.resType.plistType,format,1)
    end
    local g_battleId = 10000001
    local g_MemberAttackList = {}
    local g_MemberDeffenceList = {}
    do

          --初始化并加载所有英雄
          local tmp_batadata = BattleData
          for kk=1,2 do
              startFightBattleScene:initFightInfo(kk)
              testMemberData= BattleData["members"]
              for i=1,table.getn(testMemberData) do
                local hero = HeroAI.new(testMemberData[i],MemberPosType.attackType)
                local pos = testMemberData[i].pos
                hero:retain()
                --print(hero.m_attackInfo.tptName)
                g_MemberAttackList[#g_MemberAttackList+1] = hero
              end
          end
          print("startFightStep: ----------- "..startFightStep)
          startFightBattleScene:initFightInfo(startFightStep)
           local g_allMonsterInfo = {
            [1] = {},
            [2] = {},
            [3] = {}
          }
          local  monsterStrs = ""

          if 2==srv_userInfo.mainline and tonumber(blockData[tonumber(g_battleId)]["campType"]) == 1 then  --恶
             monsterStrs = string.split(blockData[tonumber(g_battleId)]["monstersEvil"],"|")
          else --善
             monsterStrs = string.split(blockData[tonumber(g_battleId)]["monsters"],"|")
             
          end
          for i=1,table.getn(monsterStrs) do
            local oneMonsterStrs = string.split(monsterStrs[i],":")
            if tonumber(oneMonsterStrs[2]) == 1 then
              table.insert(g_allMonsterInfo[1],oneMonsterStrs)
            elseif tonumber(oneMonsterStrs[2]) == 2 then
              table.insert(g_allMonsterInfo[2],oneMonsterStrs)
            else
              table.insert(g_allMonsterInfo[3],oneMonsterStrs)
            end
          end
            
          for i=1, #g_allMonsterInfo[1] do
              local oneMonsterStrs = g_allMonsterInfo[1][i]
              print("_index:  "..1 .. "the " .. i .."one")
              print("tonumber(oneMonsterStrs[1]):  "..tonumber(oneMonsterStrs[1]))
              local pos = tonumber(oneMonsterStrs[4])
              if startFightStep==1 or(startFightStep==2 and _curDeffenceHp[pos]~=nil)  then   --在人战没被打死的才能出现在车战
                  local monster = MonsterAI.new(monsterData[tonumber(oneMonsterStrs[1])],oneMonsterStrs[3],pos,MemberPosType.defenceType)
                  monster:retain()
                  g_MemberDeffenceList[#g_MemberDeffenceList+1] = monster
                  print("==---------------"..monster.m_attackInfo.tptName)
              end
          end
      
    end

    display.addSpriteFrames("Battle/Bullet/buff101002.plist", "Battle/Bullet/buff101002.png")
    table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/buff118001.plist",pngStr = "Battle/Bullet/buff118001.png"})
    local function addSkillCahe(_skillId)
        display.addSpriteFrames("Battle/Skill/Skill"..tostring(_skillId)..".plist", "Battle/Skill/Skill"..tostring(_skillId)..".png")
        table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/Skill"..tostring(_skillId)..".plist",pngStr = "Battle/Skill/Skill"..tostring(_skillId)..".png"})
    end
    local function addBuffCahe(_buffId)
        if _buffId ~= "null" and tonumber(_buffId) ~= 0 then
            local resID = buffData[_buffId]["buffResId"]
            display.addSpriteFrames("Battle/Bullet/"..tostring(resID)..".plist", "Battle/Bullet/"..tostring(resID)..".png")
            table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..tostring(resID)..".plist",pngStr = "Battle/Bullet/"..tostring(resID)..".png"})
        end
    end
    
       --加载英雄技能资源
      for k,v in pairs(g_MemberAttackList) do
        if v ~= nil then
          print("------------------------加载英雄 ："..v.m_attackInfo.tptName)
           for sk,sv in pairs(v.m_energySkills) do
             if sv.id ~= nil and sv.id ~= 0 then
               addSkillCahe(skillData[sv.id]["resId"])
               addBuffCahe(skillData[sv.id]["buffId"])
             end
           end
        end
      end
      --加载敌人资源
      for k,v in pairs(g_MemberDeffenceList) do
        if v ~= nil then
          print("------------------------加载敌人 ："..v.m_attackInfo.tptName)
               local monsterId = v.m_attackInfo.tptId
               local skillIDOne = monsterData[tonumber(monsterId)]["sklId1"]
               local skillIDTwo = monsterData[tonumber(monsterId)]["sklId2"]
               print("skillIDOne: "..skillIDOne)
               print("skillIDTwo: "..skillIDTwo)
               if skillIDOne ~= "null" and  tonumber(skillIDOne) ~= 0 then
                  print("resId: "..skillData[skillIDOne]["resId"].."   -------------------------------------234fr")

                   addSkillCahe(skillData[skillIDOne]["resId"])
                   addBuffCahe(skillData[skillIDOne]["buffId"])
               end
               if skillIDTwo ~= "null" and  tonumber(skillIDTwo) ~= 0 then
                   addSkillCahe(skillData[skillIDTwo]["resId"])
                   addBuffCahe(skillData[skillIDTwo]["buffId"])
               end
        end
      end
    
    


    for k,v in pairs(g_MemberDeffenceList) do
      v:release()
    end
    for k,v in pairs(g_MemberAttackList) do
      v:release()
    end
    g_MemberDeffenceList = {}
    g_MemberAttackList = {}

    display.addSpriteFrames = _addspriteFrame
    loadUtil:startLoad()
  end
end

function startFightBattleScene:initMontsers(_index)
    MemberDeffenceList = {
                            [1] = nil,
                            [2] = nil,
                            [3] = nil,
                            [4] = nil,
                            [5] = nil,
                            [6] = nil,
                            [7] = nil,
                            [8] = nil,
                            [9] = nil,
                         }

  -- printTable(monsetrdata)
  -- printTable(self.allMonsterInfo)
  
    for i=1, #self.allMonsterInfo[_index] do
        local oneMonsterStrs = self.allMonsterInfo[_index][i]
        print("_index:  ".._index .. "the " .. i .."one")
        print("tonumber(oneMonsterStrs[1]):  "..tonumber(oneMonsterStrs[1]))
        local pos = tonumber(oneMonsterStrs[4])
        if startFightStep==1 or(startFightStep==2 and _curDeffenceHp[pos]~=nil)  then   --在人战没被打死的才能出现在车战
            local monster = MonsterAI.new(monsterData[tonumber(oneMonsterStrs[1])],oneMonsterStrs[3],pos,MemberPosType.defenceType)
            if startFightStep==1 then
              monster:setPosition(DefencePositions[pos][1]+display.width/2, DefencePositions[pos][2])
            elseif startFightStep==2 then
              monster:setPosition(DefencePositions[pos][1], DefencePositions[pos][2])
              monster:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
            end
            
            self:addChild(monster,BattleDisplayLevel[pos])
            MemberDeffenceList[pos] = monster
        end
    end

end

function startFightBattleScene:GoToUIDialog()
    if self.dialog~=nil then
        print("self.dialog ~= nil ,return---------------")
        self.dialog:SetTouchState(true)
        return
    end
    print("GoToUIDialog,PlotBlockInfo[tonumber(CurBattleStep)] :  "..PlotBlockInfo[tonumber(CurBattleStep)])
    if tonumber(PlotBlockInfo[tonumber(CurBattleStep)]) == 1 then
        self:pause()
        self.dialog = UIDialog.new()
        :addTo(self,150)
        self.dialog:setVisible(true)
        self.dialog:TriggerDialog(tonumber(PlotDetailInfo[tonumber(CurBattleStep)]), DialogType.FightPlot)
        self.dialog:SetFinishCallback(handler(self,self.begainFight))
        self.dialog:SetPerConversationCallback(handler(self,self.perDialogCallBack))
    else
        self:begainFight()
    end
end


function  startFightBattleScene:showNormalDialog(_showTimeType)
    local function nextStep()
       if tonumber(DialogBlockInfo[1]) == 2 then
           self:showSceneDialog(DialogShowTime.DialogAfterFight)
       else
           print("926行，self:sendWin()")
           self:sendWin()
       end
    end
    print("showNormalDialog,PlotDetailInfo[tonumber(CurBattleStep)] :  ",PlotDetailInfo[tonumber(CurBattleStep)],"_showTimeType:",_showTimeType)
    if tonumber(PlotBlockInfo[tonumber(CurBattleStep)]) == 1 then
        print("有对话")
        self:pause()
        self.dialog = UIDialog.new()
        :addTo(self,150)
        self.dialog:setVisible(true)
        self.dialog:TriggerDialog(tonumber(PlotDetailInfo[tonumber(CurBattleStep)]), DialogType.FightPlot)
        self.dialog:SetPerConversationCallback(handler(self,self.perDialogCallBack))
        if _showTimeType == DialogShowTime.DialogBehindFight then
            self.dialog:SetFinishCallback(handler(self,self.begainFight))
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
            print("对话播放完毕，进入nextStep")
            self.dialog:SetFinishCallback(handler(self,nextStep))
        end
    else

        if _showTimeType == DialogShowTime.DialogBehindFight then
            self:begainFight()
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
          print("无对话，进入self:showSceneDialog(DialogShowTime.DialogAfterFight)")
            self:showSceneDialog(DialogShowTime.DialogAfterFight)
        end
    end
end

function startFightBattleScene:checkIsAllReady()
    for k,v in pairs(MemberAttackList) do
       if v ~= nil  and  v.m_isReady == false then
          return
       end
    end
    --加载BOSS血条
    local bossHpBg = display.newSprite("Battle/xxxttu_d02-03.png")
    :pos(display.width*0.5,display.height*0.93)
    :addTo(self)
    self.bossHpProgress = display.newProgressTimer("Battle/xxxttu_d02-04.png", display.PROGRESS_TIMER_BAR)
    :addTo(bossHpBg)
    self.bossHpProgress:setMidpoint(cc.p(1, 0))
    self.bossHpProgress:setBarChangeRate(cc.p(1, 0))
    self.bossHpProgress:setPosition(bossHpBg:getContentSize().width*0.425,bossHpBg:getContentSize().height*0.485)
    self.bossHpProgress:setPercentage(100)

    display.newSprite("Battle/xxxttu_d02-02.png")
    :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    :addTo(bossHpBg)
    display.newSprite("Head/round_"..tostring(CurBossID)..".png")
    :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    :addTo(bossHpBg)

    if startFightStep==2 then
      printTable(_curDeffenceHp)
      for k,v in pairs(MemberDeffenceList) do
        v.m_attackInfo.curHp = _curDeffenceHp[v.fightPos] or v.m_attackInfo.curHp
      
        local hpPercent = v.m_attackInfo.curHp*100/v.m_attackInfo.maxHp
        if CurBossID == tonumber(v.m_attackInfo.tptId) then --是BOSS   BOSS血条掉血
            self.bossHpProgress:setPercentage(hpPercent)
        end
      end
    end

    self:GoToUIDialog()
    
end

function startFightBattleScene:showSceneDialog(_showTimeType)
    local function nextStep()
       if tonumber(PlotBlockInfo[tonumber(CurBattleStep)]) == 1 then
           self:showNormalDialog(DialogShowTime.DialogBehindFight)
       else
           self:begainFight()
       end
    end
    local  dialogFinishCallBackFun = nil
    local  sceneStep = 0
    if _showTimeType == DialogShowTime.DialogBehindFight then
        dialogFinishCallBackFun = nextStep
        sceneStep = 1
    elseif _showTimeType == DialogShowTime.DialogAfterFight then
        dialogFinishCallBackFun = self.sendWin
        sceneStep = 2
    end
   

    if tonumber(DialogBlockInfo[1]) == sceneStep then
        self:pause() 
        self.sceneDialog = UISceneDlg.new()
        :addTo(self,150)
        self.sceneDialog:setVisible(true)
        self.sceneDialog:SetFinishCallback(handler(self,dialogFinishCallBackFun))
        self.sceneDialog:TriggerDialog(tonumber(DialogDetailInfo[1]),DialogType.FightPlot) 
    else
      print("进入showSceneDialog,  else ")
        if _showTimeType == DialogShowTime.DialogBehindFight then
            self:showNormalDialog(DialogShowTime.DialogBehindFight)
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
            self:sendWin()
        end
    end
end

function startFightBattleScene:perDialogCallBack(p)
      if p.param1 == nil or tonumber(p.param1) == 0 then
        return
      end
      local joinNpc = tonumber(p.param1)
      for i=1,3 do
        if MemberAttackList[i] == nil or MemberAttackList[i].m_isDead == true then
            --NPC
            print("joinNpc:"..joinNpc)
            joinNpcData[joinNpc].pos = i
            local hero = HeroAI.new(joinNpcData[joinNpc],MemberPosType.attackType)
            joinNpc = 0
            hero:setPosition(AttackPositions[i][1]-display.width/2, AttackPositions[i][2])
            self:addChild(hero,BattleDisplayLevel[i])
            MemberAttackList[i] = hero
            --startFightBattleScene_addBattleFrameCache(hero)
            --控制台
            local tempDesk = ControlDesk.new(MemberAttackList[i],i)
            :addTo(self,25)
            self.allControlDesk[i] = tempDesk
            self:resetControlDesk()
            g_allControlDesk[#g_allControlDesk+1]=tempDesk
            break
        end
      end
end


function startFightBattleScene:begainFight()
    if self.dialog~=nil then
        local npcs ,hasNpc= self.dialog:getDialogpramas()
        if not hasNpc then
            self.dialog:removeSelf()
            self.dialog = nil
        end
    end

    IsAllMonsterDead = false
    self:resume()
    for k,v in pairs(MemberAttackList) do
       if v ~= nil and v.m_isDead == false then
          v:goFight()
       end
    end
    for k,v in pairs(MemberDeffenceList) do
       if v ~= nil and v.m_isDead == false then
          v:goFight()
       end
    end
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:resumeCooling()
        end
    end
end

function startFightBattleScene:afterOneHeroDie(_hero)
    if _hero.m_posType == MemberPosType.defenceType then
       return
    end
    if self.allControlDesk[_hero.fightPos] ~= nil then
       self.allControlDesk[_hero.fightPos]:cleanDesk()
       self.allControlDesk[_hero.fightPos] = nil
       g_allControlDesk[_hero.fightPos] = nil
    end
    --星级
    if BattleStar > 1 then
       BattleStar = BattleStar - 1
    end
end

function startFightBattleScene:afterAllHeroDie()
    self.skillLayer:setVisible(false)
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           self.chooseSeId = 0
        end
        self.chooseCircle:setVisible(false)
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    self:pause()
end

function startFightBattleScene:runToTankWar()

    self.skillLayer:setVisible(false)
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           self.chooseSeId = 0
        end
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    self:pause()

    CurBattleStep = 2
    print("+++++++++++++++++++++++++++++++++,runToTankWar")
    self:showNormalDialog(DialogShowTime.DialogAfterFight)

end

function startFightBattleScene:afterAllMonsterDie()
    --self:backToCGScene()
    IsAllMonsterDead = true
    self.skillLayer:setVisible(false)
    skillResumeMembers()

    --暂停技能和战斗计时
    self:pause()--计时和军号
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           self.chooseSeId = 0
        end
    end

end

function startFightBattleScene:backToCGScene()
    IsAllMonsterDead = true
    self.skillLayer:setVisible(false)
    skillResumeMembers()

    self.skillLayer:setVisible(false)
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           self.chooseSeId = 0
        end
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    self:pause()
       --胜利
    CurBattleStep = 2
    print("================================,backToCGScene")
    self:showNormalDialog(DialogShowTime.DialogAfterFight)
    audio.stopAllSounds()
end

function startFightBattleScene:sendWin()
    if startFightStep==2 then
          print("返回CG")
          self:removeFromParent()
          audio.stopMusic(true)
          g_CGScene:_playAni()
    elseif startFightStep==1 then
        startFightStep = startFightStep +1
        if startFightStep==2 then
          self:setTouchEnabled(false)
          self:removeFromParent()
          
          local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 255))
                    :addTo(display.getRunningScene(),11)
          self.lab = display.newTTFLabel({
            text="", 
            size=40, 
            color=cc.c3b(255, 255, 255),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            --dimensions = cc.size(700, 60)
            })
              :align(display.CENTER_TOP, display.cx, display.cy)
              :addTo(layer)
          self.lab:setString("   就在此时……")
          
        
          local delaytime = 1
          local function callfunc()
              layer:removeFromParent()
              startFightBattleScene.new()
                :addTo(display.getRunningScene(),10)
          end
          layer:runAction(transition.sequence({ 
                                              cc.DelayTime:create(delaytime),
                                              cc.CallFunc:create(callfunc),
                                            }))

        end
    end
end

function startFightBattleScene:onEnter()
  print("onEnter  , startFightStep: "..startFightStep.."-------------------------")
end

function startFightBattleScene:onExit()
	-- body
  print("=========================================================onexit()")
  startFightBattleScene.Instance = nil
  --清除资源缓存
  if startFightStep==2 then
    for i,v in ipairs(AllAddedFramesCahe) do
      display.removeSpriteFramesWithFile(v.plstStr, v.pngStr)
    end
  end
  if startFightStep>2 then
    IsStartFight = false
    GuideManager.NextStep=10101
  end
  self:resetBattle()
  print("----------------=========================================end")
end

function startFightBattleScene:resetBattle()
  BugleWaitTime = 0
  BattleSurplusTime = 90
  CurBattleStep = 1
  IsAutoFight = false
  AllDamageValue = 0
  FriendHelpInterval = 20
  IsAllMonsterDead = false
  AllLegionRewards = {}
  AttackHaloSkillList = {}
  DeffenceHaloSkillList = {}
  BulleHasNums = {}
  g_spriteProgress = {}
  g_allControlDesk = {}
  BulletUseNums = {
                    [1] = 0,   --bullet1
                    [2] = 0,   --bullet2
                    [3] = 0,   --bullet3
                  }
  BattleStar = 3
  for i=1,20 do
    AllFlyBullet[i] = nil
  end
  for i=1,20 do
    AllDropBox[i] = nil
  end
  CurBossID = 0

  PlotBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  PlotDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  DialogBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  DialogDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}      
  EvilBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}     --恶剧情 
  EvilDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}   

  self:initFightInfo()   

end

function startFightBattleScene:scheduleRepeat(callback, interval, repeatTime, delay)
    local function doAction()
      local seq = transition.sequence({
        cc.DelayTime:create(interval),
        cc.CallFunc:create(callback),
      })
      local action = cc.Repeat:create(seq,repeatTime)
      self:runAction(action)
    end
    self:performWithDelay(doAction, delay)
end

function startFightBattleScene:initFightInfo(tmp)
    local tmp_step = startFightStep
    startFightStep = tmp or tmp_step
    if startFightStep==2 then--车战
        
        BattleData.members = {}
        local nums = {1002,1003,1004,1005,1006}
        for i = 1 ,#nums do
          local memberHero = startFightMemberData[nums[i]]
          local _data = {}
          local tmpId = nil
          if memberHero.mtype==2 then --人
            _data = memberData
            tmpId = memberHero.tptId
          elseif memberHero.mtype==1 or memberHero.mtype==3 then --车
            _data = carData
            tmpId = memberHero.carTptId
          end
          local sklStr = _data[tmpId].skillIds
          local arr = lua_string_split(sklStr,"#")
          local skl = {}
          for k,v in pairs(arr) do
            skl[#skl+1] = {id=v,sts = 1,lvl = 1}
          end
          memberHero.skl = skl
          memberHero.pos = i
          BattleData.members[#BattleData.members+1] = memberHero

        end

    elseif startFightStep==1 then   --人战
        BattleData.members = {}
        local nums = {1001}
        for i = 1 ,#nums do
          local memberHero = startFightMemberData[nums[i]]
          local _data = {}
          local tmpId = nil
          if memberHero.mtype==2 then
            _data = memberData
            tmpId = memberHero.tptId
          elseif memberHero.mtype==1 then
            _data = carData
            tmpId = memberHero.carTptId
          end
          local sklStr = _data[tmpId].skillIds
          local arr = lua_string_split(sklStr,"#")
          local skl = {}
          for k,v in pairs(arr) do
            skl[#skl+1] = {id=v,sts = 1,lvl = 1}
          end
          memberHero.skl = skl
          memberHero.pos = i
          BattleData.members[#BattleData.members+1] = memberHero

        end

    end
    startFightStep = tmp_step
    BattleFormatInfo = 
    {

        matrix = {

            bullet3 = 12107,

            bullet1 = 12109,

            bullet2 = 12106,

        },

        seBlts = {

            {

                id = 12106,

                templateId = 1075006,

                count = 60,

            },

            {

                id = 12107,

                templateId = 1075005,

                count = 383,

            },


            {

                id = 12109,

                templateId = 1075003,

                count = 110,

            },

        },

    }

end

function startFightBattleScene:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    local _targetPos = nil
    if 90103==_guideId then
        g_node = curGuideBtn
        size = g_node:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
        for i=1,7 do
          if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false then
             g_node = MemberDeffenceList[i]
             break
          end
       end
       _targetPos = g_node:convertToWorldSpace(cc.p(0,0))
       print("-------------------------------22222222222")
       printTable(_targetPos)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    curGuideBtn = nil
    return midPos, promptRect,_targetPos
end


startFightBattleScene:initFightInfo()

return startFightBattleScene

