--
-- Author: liufei
-- Date: 2015-03-05 11:49:31
--
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
local SettlementLayer = require("app.battle.battleUI.SettlementLayer")
local PvpResultLayer = require("app.battle.PVP.PvpResultLayer")
local LegionOverLayer = require("app.battle.battleUI.LegionOverLayer")
local WorldBossOverLayer = require("app.battle.battleUI.WorldBossOverLayer")
local SpriteProgress = require("app.battle.battleUI.SpriteProgress")

local SpeStateNote = require("app.battle.battleUI.SpeStateNote")


local BattleScene = class("BattleScene", function()
	  return display.newScene("BattleScene")
end)

function BattleScene:ctor()
  -- AllNAtkTime = {["atk"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}, ["def"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}}
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
  end

  GuideManager.IsFirstGuide = true
  if CurFightBattleType == FightBattleType.kType_WorldBoss then
      BattleID = tonumber(BattleData["boss"]["blockId"])
  else
      BattleID = block_idx
  end
  -- BattleID = 81001001
  self:resetBattle()


  
  --背景图片
  self.battlebg = display.newSprite()
  :addTo(self)
  local bgStr = nil
  if CurFightBattleType == FightBattleType.kType_PVP then
      bgStr = "Battle/BattleBg/scene_bg_1001.jpg"
  else
      --当前关卡BOSS的ID
      CurBossID =  tonumber(blockData[BattleID]["type2"])
      bgStr = "Battle/BattleBg/scene_bg_"..blockData[tonumber(BattleID)]["resId"]..".jpg"
      if tonumber(blockData[tonumber(BattleID)]["reverse"]) == 1 then
          self.battlebg:setScaleX(-1)
      end
  end
  self.battlebg:setTexture(bgStr)
  self.battlebg:scale(1.333)
  self.battlebg:setPosition(display.width, display.cy)
  
  --新手引导底层
  self.guideBg = display.newLayer()
  :addTo(self,30)
  self.guideBg:setTouchEnabled(false)
  --剧情信息
  if CurFightBattleType ~= FightBattleType.kType_PVP then
      if blockData[tonumber(BattleID)].type==1 or blockData[tonumber(BattleID)].type==2 then
        printInfo("------------DCLevels.begin")
        DCLevels.begin(blockData[tonumber(BattleID)].id..","..blockData[tonumber(BattleID)].name)
      end
      if getFightBlockStar() <= 0  then--未通关
          PlotBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPart"],"|")
          PlotDetailInfo = string.split(blockData[tonumber(BattleID)]["talkID"],"|")
          DialogBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPart2"],"|")
          DialogDetailInfo = string.split(blockData[tonumber(BattleID)]["talkID2"],"|")
          EvilBlockInfo = string.split(blockData[tonumber(BattleID)]["talkPartEvil"],"|")
          EvilDetailInfo = string.split(blockData[tonumber(BattleID)]["talkIDEvil"],"|")

          if 2==srv_userInfo.mainline and blockData.campType==1 then  --恶
             PlotBlockInfo = EvilBlockInfo
             PlotDetailInfo = EvilDetailInfo
          end
      end
     
     if tonumber(blockData[tonumber(BattleID)]["type3"]) == 0 then
         AllBattleStep = 1
     elseif tonumber(blockData[tonumber(BattleID)]["type3"]) == 1 then
         AllBattleStep = 3
     else
         AllBattleStep = 3
     end

     --是否人物关卡
     if tonumber(string.sub(tostring(BattleID),2,2)) == 1 then
          IsMenBlock = true
          BlockTypeScale = MenBlockScale
     else
          IsMenBlock = false
          BlockTypeScale = TankBlockScale
     end

     if EmbattleMgr.nCurBattleType == BattleType_Legion then
          IsMenBlock = false
          BlockTypeScale = TankBlockScale
     end

     if CurFightBattleType == FightBattleType.kType_WorldBoss then
          IsMenBlock = false
          BlockTypeScale = TankBlockScale
     end
     
     luaStartBlock(blockData[tonumber(BattleID)]["name"])

     --添加场景特效
     self:addSceneEff()
     
     --是否有助战好友
     self.hasFriendHelp = false
     if BattleData["friCarTptId"] ~= nil then
         self.hasFriendHelp = true
     end

     --3段背景音乐
     self.bgMusics = string.split(blockData[tonumber(BattleID)]["music"], "|")
     audio.playMusic("audio/battleMusic/"..self.bgMusics[CurBattleStep]..".mp3", true)
  else
     AllBattleStep = 1
     IsMenBlock = false
     BlockTypeScale = TankBlockScale
     if IsPlayback == false and tonumber(PVPData["leftCnt"]) >= 1 then
          PVPData["leftCnt"] = tonumber(PVPData["leftCnt"]) - 1
     end
  end
  --战斗成员
  self:initAllMember()
  --上层UI
  self:initAllUI()
  --加载特种弹
  if IsMenBlock == false and CurFightBattleType ~= FightBattleType.kType_PVP then
      self:addSeblts()
  end
  --加载激光炮
  if IsMenBlock == true then
      LaserGunAI:addLaserItem(self)
  end
  if EmbattleMgr.nCurBattleType == BattleType_Legion then
     self:initLegionBattle()
  elseif EmbattleMgr.nCurBattleType == BattleType_PVE then
     --开始燃油扣除
     local useEnergyFirst = 0
     if tonumber(string.sub(tostring(BattleID),1,1)) == 1 then
         useEnergyFirst = 1
     else
         useEnergyFirst = 2
     end
     SetEnergyAndCountDown(srv_userInfo["energy"] - useEnergyFirst)
  end

  self.hasDialogPlayed = {false,false,false}  --当前小节的对话是否已经播放
  -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

function BattleScene:addSceneEff()
    if blockData[tonumber(BattleID)]["eff"] ~= "null" then
        local effName = blockData[tonumber(BattleID)]["eff"]
        local manager = ccs.ArmatureDataManager:getInstance()
        manager:removeArmatureFileInfo("Battle/BattleEff/"..effName..".ExportJson")
        manager:addArmatureFileInfo("Battle/BattleEff/"..effName..".ExportJson")
        local sceneEff = ccs.Armature:create(effName)
        :pos(display.width*0.5,display.height*0.5)
        :addTo(self,38)
        sceneEff:getAnimation():play("Feng")
    end 
    
    if blockData[tonumber(BattleID)]["par"] ~= "null" then
        local parName = blockData[tonumber(BattleID)]["par"]
        local particle = cc.ParticleSystemQuad:create("Battle/BattleEff/particle/"..parName..".plist")
        self:addChild(particle)
    end
end

function BattleScene:onEnter()
    --加载资源缓存
    self:addBattleFrameCache()
    self:handleHaloSkill()
end
 
function BattleScene:sebltCallBack(_event)
    if _event.callType == SpriteProgressCallType.kCall_Click then
        self:chooseSeBullet(_event.callId)
    elseif _event.callType == SpriteProgressCallType.kCall_Ready then
        self.speNote:showSpeNode(_event.callId,SpeNoteState.Spe_Ready)
        local frames1 = display.newFrames("SeReadyFrames_%02d.png", 0, 15)
        local animation1 = display.newAnimation(frames1, 1/15)
        local aniAction1 = cc.Animate:create(animation1)
        self.sebltControls[_event.callId].okSp:setVisible(true)
        self.sebltControls[_event.callId].okStaySp:setVisible(true)
        self.sebltControls[_event.callId].okSp:runAction(transition.sequence({
                                                                               aniAction1,
                                                                               cc.CallFunc:create(function()
                                                                                 self.sebltControls[_event.callId].okSp:setVisible(false)
                                                                               end)
                                                                             }))
        curGuideBtn = _event.callSp
        print("GuideManager.NextStep: "..GuideManager.NextStep)
        if  not getIsGuideClosed() and GuideManager.NextStep == 10508 then
          GuideManager:_addGuide_2(10508, self.guideBg,handler(self,self.caculateGuidePos),101)
          pauseTheBattle()
          _event.callSp:resumeCooling()
          print("暂停，90103")
          self.skillLayer:setVisible(false)
        end
    else
        print("sebltCallBack Error")
    end
end

function BattleScene:addSeblts()
    --左侧提示框
    self.speNote = SpeStateNote.new()
    :pos(0,display.height*0.7)
    :addTo(self,40)
    --选定框
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
                for i,v in ipairs(BulleHasNums) do
                  if tonumber(v.id) == tonumber(useSeId) then
                     BulletUseNums[i] = BulletUseNums[i] + 1
                     break
                  end
                end
                -- self:showSeblt({x = event.x, y = event.y},useSeId)
                -- self:performWithDelay(function()
                self:showSeblt({x = event.x, y = event.y}, useSeId)
                -- end,0.3)
                self.speNote:showSpeNode(useSeId,SpeNoteState.Spe_Fire)
                self.sebltControls[useSeId]:startCooling()
                self.sebltControls[useSeId].chooseSp:setVisible(false)
                self.sebltControls[useSeId].okStaySp:setVisible(false)
                self.chooseCircle:setVisible(false)
                self.sebltControls[useSeId]:afterUseSeblt()
            end
            
        end
        return true
    end)
    self.sebltControls = {}
    BulleHasNums = {}
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
          sProgress.chooseSp:setScaleY(1.25)
          sProgress.okSp = display.newSprite("#SeReadyFrames_00.png")
          :pos(sProgress:getContentSize().width*0.5, sProgress:getContentSize().height*0.5)
          :addTo(sProgress)
          sProgress.okSp:setVisible(false)
          local frames1 = display.newFrames("SeReadyStayFrames_%02d.png", 0, 12)
          local animation1 = display.newAnimation(frames1, 1/12)
          local aniAction1 = cc.Animate:create(animation1)
          sProgress.okStaySp = display.newSprite("#SeReadyStayFrames_00.png")
          :pos(sProgress:getContentSize().width*0.5, sProgress:getContentSize().height*0.6)
          :addTo(sProgress)
          sProgress.okStaySp :setScaleX(1.2)
          sProgress.okStaySp:runAction(cc.RepeatForever:create(aniAction1))
          sProgress.okStaySp:setVisible(false)
          self.sebltControls[BulleHasNums[i].id] = sProgress
       end
    end
end

function BattleScene:chooseSeBullet(_seId)
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
    local scaleNum = effectRect*2/self.chooseCircle:getContentSize().width
    self.chooseCircle:scale(scaleNum)
end

function BattleScene:showSeblt(_targetPos,_useSeId)
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
    
    self.chooseCircle:runAction(transition.sequence({
                                        cc.DelayTime:create(moveTime+SpeEpoEffectDelay[tonumber(string.sub(tostring(_useSeId),6,7))]),
                                        cc.CallFunc:create(effectSkill)
                                      }))

end

function BattleScene:handleHaloSkill()
    for i=1,#AttackHaloSkillList do
        local addType = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["aplType"])
        local addP = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addPercent"])
        local add  = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["add"])
        local addPGF = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addPercentGF"])
        local addGF  = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addGF"])
        if addType == HaloBuffAddType.HaloMenAttack then
            for k,v in pairs(MemberAttackList) do
               if v ~= nil and v.m_isDead == false then
                   if v.m_memberType == MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = v.m_attackInfo.attackValue + v.m_attackInfo.attackValue*addP + add
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankMainAttack then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_mainAtk = v.m_mainAtk + v.m_mainAtk*addP + add

                      
                   end
              end
            end
        elseif addType == HaloBuffAddType.HaloTankNormalAttack then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = v.m_attackInfo.attackValue + v.m_attackInfo.attackValue*addP + add
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloDeffence then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue + v.m_attackInfo.defenceValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloHp then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.maxHp = math.floor(v.m_attackInfo.maxHp + v.m_attackInfo.maxHp*addP + add)
                v.m_attackInfo.curHp = math.floor(v.m_attackInfo.maxHp)
              end
            end
        elseif addType == HaloBuffAddType.HaloCrit then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.critValue = v.m_attackInfo.critValue + v.m_attackInfo.critValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloHit then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.hitValue = v.m_attackInfo.hitValue + v.m_attackInfo.hitValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloDodge then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.dodgeValue = v.m_attackInfo.dodgeValue + v.m_attackInfo.dodgeValue*addP + add
              end
            end
        end
    end

    for i=1,#DeffenceHaloSkillList do
        local addType = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["aplType"])
        local addP = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addPercent"])
        local add  = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["add"])
        local addPGF = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addPercentGF"])
        local addGF  = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addGF"])
        if addType == HaloBuffAddType.HaloMenAttack then
            for k,v in pairs(MemberDeffenceList) do
               if v ~= nil and v.m_isDead == false then
                   if v.m_memberType == MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = v.m_attackInfo.attackValue + v.m_attackInfo.attackValue*addP + add
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankMainAttack then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_mainAtk = v.m_mainAtk + v.m_mainAtk*addP + add
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankNormalAttack then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = v.m_attackInfo.attackValue + v.m_attackInfo.attackValue*addP + add
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloDeffence then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue + v.m_attackInfo.defenceValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloHp then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.maxHp = v.m_attackInfo.maxHp + v.m_attackInfo.maxHp*addP + add
                v.m_attackInfo.curHp = v.m_attackInfo.maxHp
              end
            end
        elseif addType == HaloBuffAddType.HaloCrit then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.critValue = v.m_attackInfo.critValue + v.m_attackInfo.critValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloHit then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.hitValue = v.m_attackInfo.hitValue + v.m_attackInfo.hitValue*addP + add
              end
            end
        elseif addType == HaloBuffAddType.HaloDodge then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil and v.m_isDead == false then
                v.m_attackInfo.dodgeValue = v.m_attackInfo.dodgeValue + v.m_attackInfo.dodgeValue*addP + add
              end
            end
        end
    end
end

function BattleScene:removeHaloSkill()
    for i=#AttackHaloSkillList,1,-1 do
        local addType = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["aplType"])
        local addP = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addPercent"])
        local add  = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["add"])
        local addPGF = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addPercentGF"])
        local addGF  = tonumber(skillData[tonumber(AttackHaloSkillList[i])]["addGF"])
        if addType == HaloBuffAddType.HaloMenAttack then
            for k,v in pairs(MemberAttackList) do
               if v ~= nil then
                   if v.m_memberType == MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = (v.m_attackInfo.attackValue - add)/(1+addP)
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankMainAttack then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_mainAtk = (v.m_mainAtk - add)/(1+addP)                    
                   end
              end
            end
        elseif addType == HaloBuffAddType.HaloTankNormalAttack then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = (v.m_attackInfo.attackValue - add)/(1+addP)
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloDeffence then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                v.m_attackInfo.defenceValue = (v.m_attackInfo.defenceValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloHp then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                v.m_attackInfo.maxHp = math.floor((v.m_attackInfo.maxHp - add)/(1+addP))
                v.m_attackInfo.curHp = v.m_attackInfo.maxHp
              end
            end
        elseif addType == HaloBuffAddType.HaloCrit then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                v.m_attackInfo.critValue = (v.m_attackInfo.critValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloHit then
            print("----------------------HaloHit skillId="..tonumber(AttackHaloSkillList[i]))
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                v.m_attackInfo.hitValue = (v.m_attackInfo.hitValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloDodge then
            for k,v in pairs(MemberAttackList) do
              if v ~= nil then
                v.m_attackInfo.dodgeValue = (v.m_attackInfo.dodgeValue - add)/(1+addP)
              end
            end
        end
    end

    for i=#DeffenceHaloSkillList,1,-1 do
        local addType = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["aplType"])
        local addP = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addPercent"])
        local add  = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["add"])
        local addPGF = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addPercentGF"])
        local addGF  = tonumber(skillData[tonumber(DeffenceHaloSkillList[i])]["addGF"])
        if addType == HaloBuffAddType.HaloMenAttack then
            for k,v in pairs(MemberDeffenceList) do
               if v ~= nil then
                   if v.m_memberType == MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = (v.m_attackInfo.attackValue - add)/(1+addP)
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankMainAttack then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_mainAtk = (v.m_mainAtk - add)/(1+addP)
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloTankNormalAttack then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                   if v.m_memberType ~= MemberAllType.kMemberHero then
                       v.m_attackInfo.attackValue = (v.m_attackInfo.attackValue - add)/(1+addP)
                   end
               end
            end
        elseif addType == HaloBuffAddType.HaloDeffence then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                 v.m_attackInfo.defenceValue = (v.m_attackInfo.defenceValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloHp then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                v.m_attackInfo.maxHp = math.floor((v.m_attackInfo.maxHp - add)/(1+addP))
                v.m_attackInfo.curHp = v.m_attackInfo.maxHp
              end
            end
        elseif addType == HaloBuffAddType.HaloCrit then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                v.m_attackInfo.critValue = (v.m_attackInfo.critValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloHit then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                v.m_attackInfo.hitValue = (v.m_attackInfo.hitValue - add)/(1+addP)
              end
            end
        elseif addType == HaloBuffAddType.HaloDodge then
            for k,v in pairs(MemberDeffenceList) do
              if v ~= nil then
                v.m_attackInfo.dodgeValue = (v.m_attackInfo.dodgeValue - add)/(1+addP)
              end
            end
        end
    end
end

function BattleScene:initAllUI()
   --计时条
  local timeBg = display.newSprite("Battle/zd_speid_d02-06.png")
  :pos(display.width*4/25, display.height*17/18)
  :addTo(self)
  local clockImage = display.newSprite("Battle/zd_speid_d02-05.png")
  :pos(timeBg:getContentSize().width*1/10, timeBg:getContentSize().height*4.5/9)
  :addTo(timeBg)
  --计时label
  self.timeLabel=cc.ui.UILabel.new({
        font = "fonts/slicker.ttf", UILabelType = 2, text = "01:30", size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :pos(timeBg:getContentSize().width*0.35, timeBg:getContentSize().height/2)
        :addTo(timeBg)
  
  self:performWithDelay(function()
    self:schedule(self.controlFightTime, 1)
  end,2)
  --技能遮挡框
  self.skillLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,150))
  :addTo(self,SkillOcclusionLevel)
  self.skillLayer:setVisible(false)

  -- blackBg:setVisible(false)

  --内容框
  -- self.meesageBox = BattleMessagePanel.new()
  -- :addTo(self,SkillOcclusionLevel+1)
  -- self.meesageBox:pos(display.width/360 + self.meesageBox:getContentSize().width/2, blackBg:getContentSize().height/16 + self.meesageBox:getContentSize().height/2)
  -- BattleMessageBox = self.meesageBox
  
  --操作框
  self:addControlDesk()

  if CurFightBattleType == FightBattleType.kType_PVE then
    --加速按钮
    self:addSpeed()
  end
  
  --自动按钮
  self.autoFightItem = cc.ui.UICheckBoxButton.new({off = "Battle/zd_speid_d02-33.png",on = "Battle/zd_speid_d02-34.png"})
  :pos(display.width*48/50, display.height*0.1)
  :onButtonClicked(function()
      if not g_isNewCreate and srv_userInfo.level < 10 then
          self.autoFightItem:setButtonSelected(false)
          showTips("10级后开放自动战斗")
          return
      end
      if self.autoFightItem:isButtonSelected() then
         IsAutoFight = true
         self.nextItem:setTouchEnabled(false)
         --下一关自动
         if self.nextItem:isVisible() == true then
           self:nextButtonClicked()
         else
           --技能自动
           for k,v in pairs(self.allControlDesk) do
              v:changeToAuto()
           end
         end
      else
         self.nextItem:setTouchEnabled(true)
         IsAutoFight = false
      end
  end)
  :addTo(self,30)
  if CurFightBattleType == FightBattleType.kType_PVP then
     self.autoFightItem:setButtonSelected(true)
     IsAutoFight = true
     self.autoFightItem:setTouchEnabled(false)

     local tipLabel = cc.ui.UILabel.new({text = "竞技场只能自动战斗", size = 15, color = _color or cc.c3b(255, 255, 255)})
             :addTo(self,30)
     local g_width = tipLabel:getContentSize().width+40
     tipLabel:align(display.CENTER,display.width*47/50-g_width/2-70, display.height*0.1)
     local tips = display.newScale9Sprite("SingleImg/chat/tipsBar.png",display.cx,display.cy, cc.size(g_width, 50),cc.rect(10,10,357,59))
              :addTo(self,29)
              :align(display.CENTER,display.width*47/50-g_width/2-70, display.height*0.1)

      display.newSprite("Battle/jjcvsbg.png")
      :addTo(self)
      :align(display.LEFT_TOP,display.cx,display.height)
    display.newSprite("Battle/jjcvsbg.png")
      :addTo(self)
      :align(display.LEFT_TOP,display.cx,display.height)
      :setScaleX(-1)
    display.newSprite("Battle/jjcvs.png")
      :addTo(self)
      :align(display.CENTER_TOP,display.cx,display.height)
    --右边名称
    local rightName = display.newTTFLabel{text = BattleData["eName"],size = 30}
      :addTo(self)
      :align(display.LEFT_CENTER,display.cx+60,display.height-38)
    --左边名称
    local leftName = display.newTTFLabel{text = srv_userInfo.name,size = 30}
      :addTo(self)
      :align(display.RIGHT_CENTER,display.cx-60,display.height-38)
    

    display.newSprite("common2/com_strengthTag.png")
      :addTo(self)
      :pos(display.cx-210,display.height-78)
      :scale(0.8)
    --左边战力
    local LeftlabelAtla = cc.LabelAtlas:_create()
                        :align(display.LEFT_CENTER, display.cx-200,display.height-78)
                        :addTo(self)
                        :scale(0.75)
        LeftlabelAtla:initWithString("",
            "common/common_Num2.png",
            27.3,
            39,
            string.byte(0))
    LeftlabelAtla:setString(BattleData["strength"])

    display.newSprite("common2/com_strengthTag.png")
      :addTo(self)
      :pos(display.cx+110,display.height-78)
      :scale(0.8)

    --右边战力
    RightlabelAtla = cc.LabelAtlas:_create()
                        :align(display.LEFT_CENTER, display.cx+120,display.height-78)
                        :addTo(self)
                        :scale(0.75)
        RightlabelAtla:initWithString("",
            "common/common_Num2.png",
            27.3,
            39,
            string.byte(0))
    RightlabelAtla:setString(BattleData["eStrength"])
    
    --是否回放
    if IsPlayback then
      rightName:setString(BattleData["defName"])
      leftName:setString(BattleData["eName"])
      LeftlabelAtla:setString(BattleData["strength"])
      RightlabelAtla:setString(BattleData["eStrength"])
      -- if BattleData.type==2 then --我是防守方
      --   rightName:setString(srv_userInfo.name)
      --   leftName:setString(BattleData["eName"])
      --   LeftlabelAtla:setString(BattleData["eStrength"])
      --   RightlabelAtla:setString(BattleData["strength"])
      -- elseif BattleData.type==1 then --我是进攻方
      --   rightName:setString(BattleData["eName"])
      --   leftName:setString(srv_userInfo.name)
      --   LeftlabelAtla:setString(BattleData["strength"])
      --   RightlabelAtla:setString(BattleData["eStrength"])
      -- end
    end
  end
  
  --下一关按钮
  self.nextItem = cc.ui.UIPushButton.new({normal = "Battle/zhandou_xia-01.png",pressed = "Battle/zhandou_xia-01.png"})
  :onButtonClicked(function()
      self:nextButtonClicked()
  end)
  :pos(display.width*44/50, display.height*0.5)
  :addTo(self,25)
  local seq = transition.sequence({
                        cc.MoveBy:create(0.45,cc.p(display.width/50,0)),
                        cc.MoveBy:create(0.45,cc.p(-display.width/50,0))
                     })
  self.nextItem:runAction(cc.RepeatForever:create(seq))
  self.nextItem:setVisible(false)
  
  

  --暂停layer
  local pauseLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,150))
  :addTo(self,100)
  pauseLayer:setVisible(false)
  --继续按钮
  local resumeItem = cc.ui.UIPushButton.new({normal = "Battle/bofang01-01.png",pressed = "Battle/bofang02-01.png"})
  :onButtonClicked(function()
      pauseLayer:setVisible(false)
      display.resume()
      g_bIsScenePaused = false
  end)
  :pos(display.width*2.6/7, display.height/2)
  :addTo(pauseLayer)

  local resumeTitle = display.newSprite("Battle/jiesz_shm-01.png")
  :pos(display.width*2.6/7, display.height*0.38)
  :addTo(pauseLayer)

  local backItem = cc.ui.UIPushButton.new({normal = "Battle/begin_shutdown.png",pressed = "Battle/begin_shutdown02.png"})
  :pos(display.width*4.4/7, display.height/2)
  :addTo(pauseLayer)
  :onButtonClicked(function()
      if EmbattleMgr.nCurBattleType == BattleType_Legion then
         comData={}
         comData["areaId"]= srv_userInfo.areaId
         m_socket:SendRequest(json.encode(comData), CMD_UNLOCK_LEGION)
      else
        if IsPlayback==false then
          modify_srv_blockData(BattleID,0)
        end
      end
      pauseLayer:setVisible(false)
      display.resume()
      g_bIsScenePaused = false
      if IsPlayback then
        app:enterScene("LoadingScene", {SceneType.Type_Main})
        -- comData={}
        -- comData["characterId"] = srv_userInfo.characterId
        -- m_socket:SendRequest(json.encode(comData), CMD_GETPVPINFO, self, self.OnGetPVPInfoRet)
      else
        DCLevels.fail(blockData[tonumber(BattleID)].id..","..blockData[tonumber(BattleID)].name,"玩家主动退出")
        app:enterScene("LoadingScene", {SceneType.Type_Block})
      end
  end)
  local backTitle = display.newSprite("Battle/jiesz_shm-02.png")
  :pos(display.width*4.4/7, display.height*0.38)
  :addTo(pauseLayer)

  --暂停按钮
  local pauseItem = cc.ui.UIPushButton.new({normal = "Battle/zanting01-01.png"})
  :onButtonClicked(function()
      pauseLayer:setVisible(true)
      display.pause()
      g_bIsScenePaused = true
  end)
  :pos(display.width/25, display.height*17/18)
  :addTo(self)
  pauseItem:scale(0.7)
  --新手教程隐藏按钮
  print("\n\n\n\n\n\n\nGuideManager.NextStep:",GuideManager.NextStep)
  if g_isNewCreate or not getIsGuideClosed() and tonumber(GuideManager.NextStep)~=0 and (tonumber(GuideManager.NextStep) < 12101 or tonumber(GuideManager.NextStep) == 22222 or tonumber(GuideManager:getCondition())~=0) then
    backItem:setVisible(false)
    backTitle:setVisible(false)
  end


  if CurFightBattleType == FightBattleType.kType_PVP then
    if not IsPlayback then
      timeBg:setPosition(display.width*2/25, display.height*17/18)
      pauseItem:setVisible(false)
    else
      timeBg:setPosition(display.width*4/25-15, display.height*17/18)
    end
    return
    --竞技场不用走后面代码
  end
  
  --金币和物品
  local goldBg = display.newSprite("Battle/zd_speid_d02-06.png")
  :pos(display.width*20/25, display.height*17/18)
  :addTo(self)
  local goldImage = display.newSprite("common/common_Gold.png")
  :pos(0, goldBg:getContentSize().height*0.5)
  :addTo(goldBg)
  local boxBg = display.newSprite("Battle/zd_speid_d02-06.png")
  :pos(display.width*23.5/25, display.height*17/18)
  :addTo(self)
  local boxImage = display.newSprite("Battle/dropbox.png")
  :pos(0, timeBg:getContentSize().height*0.5)
  :addTo(boxBg)
  if CurFightBattleType == FightBattleType.kType_WorldBoss then
    --boxImage:scale(2)
  end
  --金币label
  self.goldLabel=cc.ui.UILabel.new({
        font = "fonts/slicker.ttf", UILabelType = 2, text = "0", size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :align(display.CENTER,timeBg:getContentSize().width*0.5, timeBg:getContentSize().height/2)
        :addTo(goldBg)
  --宝箱label
  self.boxLabel=cc.ui.UILabel.new({
        font = "fonts/slicker.ttf", UILabelType = 2, text = "0", size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :align(display.CENTER,timeBg:getContentSize().width*0.5, timeBg:getContentSize().height/2)
        :addTo(boxBg)


  if AllBattleStep == 1 then
      return
  end
  --进度条
  self.stepProgressOne = Progress.new("Battle/blockprogressbg.png","Battle/blockprogressfill.png")
  :pos(display.width*6.8/16, display.height*135/144)
  :addTo(self)
  self.stepProgressOne:setScaleX(display.width/6.5/self.stepProgressOne:getContentSize().width)
  self.stepProgressOne:setProgress(0)
  self.stepProgressTwo = Progress.new("Battle/blockprogressbg.png","Battle/blockprogressfill.png")
  :pos(display.width*9.2/16, display.height*135/144)
  :addTo(self)
  self.stepProgressTwo:setScaleX(display.width/6.5/self.stepProgressTwo:getContentSize().width)
  self.stepProgressTwo:setProgress(0)

  self.stepOneMark = display.newSprite("Battle/guanka_hong-01.png")
  :pos(display.width*11/32, display.height*135/144)
  :addTo(self)
  self.stepTwoMark = display.newSprite("Battle/guanka_kong-01.png")
  :pos(display.width/2, display.height*135/144)
  :addTo(self)
  self.stepThreeMark = display.newSprite("Battle/guanka_kong-01.png")
  :pos(display.width*21/32, display.height*135/144)
  :addTo(self)
  --小坦克
  self.progressTank = display.newSprite("Battle/xiaotanke-01.png")
  :addTo(self)
  self.progressTank:setPosition(self.stepOneMark:getPositionX(),self.stepOneMark:getPositionY() + self.stepOneMark:getContentSize().height*0.5+3)
end

--抖动
function BattleScene:shakeBg(_level)
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
  self.shakeAction = self.battlebg:runAction(transition.sequence{
                                                cc.MoveBy:create(times[1],cc.p(0,ranges[1])),
                                                cc.MoveBy:create(times[2],cc.p(0,ranges[2])),
                                                cc.MoveBy:create(times[3],cc.p(0,ranges[3])),
                                                cc.MoveBy:create(times[4],cc.p(0,ranges[4])),
                                             })
end

--加载操作框
function BattleScene:addControlDesk()
    self.allControlDesk = {}
    g_allControlDesk = {}
    for k,v in pairs(MemberAttackList) do
        if v.m_memberType == MemberAllType.kMemberTankWithHero or v.m_memberType == MemberAllType.kMemberHero then
            local tempDesk = ControlDesk.new(v)
                :addTo(self,25)
            self.allControlDesk[v.fightPos] = tempDesk
            self.allControlDesk[v.fightPos].mType = v.m_memberType
            g_allControlDesk[v.fightPos] = tempDesk
        end
    end
    self:resetControlDesk()
end

--加速按钮
function BattleScene:addSpeed()
  local sharedScheduler = cc.Director:getInstance():getScheduler()
  self.curSpeed = 1.0

  local speedArr = {{spd = 1.0, img = "Battle/zdjb_r2-45.png"},
                    {spd = 1.5, img = "Battle/zdjb_r2-46.png"},
                    {spd = 2.0, img = "Battle/zdjb_r2-47.png"},
                    {spd = 1.5, img = "Battle/zdjb_r2-48.png"},}
  local idx = 1

  --从本地读取速度
  local speed = GameData.FightSpeed
  if speed==nil or speed==1.0 then
    print("aaaaaa")
    idx = 1
  elseif speed ==1.5 then
    print("bbbbbbbb")
    idx = 2
  elseif speed ==2.0 then
    print("cccccccccc")
    idx = 3
    if srv_userInfo.vip<3 then
      print("ddddddd")
      idx = 4
    end
  end
  sharedScheduler:setTimeScale(speedArr[idx].spd)


  local spdBt = cc.ui.UIPushButton.new({
    normal = speedArr[idx].img
    },{grayState=true})
  :addTo(self)
  :pos(display.width*48/50, display.height*0.2)
  :onButtonClicked(function(event)
    idx = idx + 1
    if idx>3 then
      idx = 1
    end
    self.curSpeed = speedArr[idx].spd
    event.target:setButtonImage("normal",speedArr[idx].img)
    event.target:setButtonImage("pressed",speedArr[idx].img)
    if self.curSpeed==2.0 and srv_userInfo.vip<3 then
      self.curSpeed = math.min(self.curSpeed, 1.5)
      showTips("VIP3开启2倍加速")
      event.target:setButtonImage("normal",speedArr[4].img)
      event.target:setButtonImage("pressed",speedArr[4].img)
    end
    sharedScheduler:setTimeScale(self.curSpeed)

    --保存本地
    GameData.FightSpeed = self.curSpeed
    GameState.save(GameData)
    end)
end

function BattleScene:resetControlDesk()
    local  controlNum = 0
    
    if IsMenBlock == false or CurFightBattleType == FightBattleType.kType_PVP then
        for k,v in pairs(self.allControlDesk) do
            if v.mType == MemberAllType.kMemberHero then
                v:align(display.CENTER, display.width*0.11 + controlNum*display.width*0.2,v:getContentSize().height*0.5)
                controlNum = controlNum + 1
            end
        end
        for k,v in pairs(self.allControlDesk) do
            if v.mType ~= MemberAllType.kMemberHero then
                v:align(display.CENTER, display.width*0.11 + controlNum*display.width*0.2,v:getContentSize().height*0.5)
                controlNum = controlNum + 1
            end
        end
    else
        local cIndex = 0
        for k,v in pairs(self.allControlDesk) do
            cIndex = cIndex + 1
            v:align(display.CENTER, display.width*0.11 + (cIndex-1)*display.width*0.205,v:getContentSize().height*0.5)
        end
    end
      
end

--初始化军团副本
function BattleScene:initLegionBattle()
    local function resetHeroPos()
        for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
               v:setPosition(v:getPositionX()+display.width/2, v:getPositionY())
          end
        end
    end
    --进度条设置
    if CurBattleStep == 2 then
        self.stepProgressOne:setProgress(100)
        self.stepOneMark:setTexture("Battle/guanka_hong-01.png")
        self.stepTwoMark:setTexture("Battle/guanka_hong-01.png")
        self.battlebg:setPosition(display.width, display.cy) 
        self.battlebg:runAction(cc.MoveBy:create(StartMoveTime*StartSpeedAdd, cc.p(-display.width/2,0)))
        self.progressTank:setPosition(display.width/2,  self.progressTank:getPositionY())
        resetHeroPos()
    elseif CurBattleStep == 3 then
        self.stepProgressOne:setProgress(100)
        self.stepProgressTwo:setProgress(100)
        self.stepOneMark:setTexture("Battle/guanka_hong-01.png")
        self.stepTwoMark:setTexture("Battle/guanka_hong-01.png")
        self.stepThreeMark:setTexture("Battle/guanka_hong-01.png")
        self.battlebg:setPosition(display.width*0.5, display.cy)
        self.battlebg:runAction(cc.MoveBy:create(StartMoveTime*StartSpeedAdd, cc.p(-display.width/2,0)))
        self.progressTank:setPosition(display.width*21/32,  self.progressTank:getPositionY())
        resetHeroPos()
    end
end
--初始化个成员
function BattleScene:initAllMember()
  --printTable(BattleData)
  -- local fullPath = cc.FileUtils:getInstance():fullPathForFilename("res/configRead/battleFormat.json")
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
    --print("--------------member pos="..testMemberData[i].pos)
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
  

  --初始化3个小关的怪物数据 或者对手数据
  if CurFightBattleType == FightBattleType.kType_PVP then --PVP
      IsPauseMemberBeforePlaySkl = false
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
      for i=1,table.getn(BattleData["enemys"]) do
          --print("--------------enemy pos="..BattleData["enemys"][i].pos)
          local hero = HeroAI.new(BattleData["enemys"][i],MemberPosType.defenceType)
          local pos = BattleData["enemys"][i].pos
          hero:setPosition((display.width - AttackPositions[pos][1]) + display.width/2, AttackPositions[pos][2])
          if tonumber(pos) == 5 then
              self:addChild(hero,15)
          else
              self:addChild(hero,BattleDisplayLevel[pos])
          end
          MemberDeffenceList[pos] = hero
          
      end
      if IsPlayback == true then
          print("---------------------pvp RandomSeed="..RandomSeed)
          math.randomseed(RandomSeed) --设回保存的种子

          -- for i,v in pairs(MemberAttackList) do
          --     print("Atk"..i..":"..RandomSeedPool["atk"][i])
          --     math.randomseed(RandomSeedPool["atk"][i])
          --     for i=1,2000 do --2000个种子
          --         v.m_randSeedPool[i] = math.random(10000)
          --     end
          -- end
          -- for i,v in pairs(MemberDeffenceList) do
          --     print("Def"..i..":"..RandomSeedPool["def"][i])
          --     math.randomseed(RandomSeedPool["def"][i])
          --     for i=1,2000 do --2000个种子
          --         v.m_randSeedPool[i] = math.random(10000)
          --     end
          -- end
      else
          -- RandomSeedPool["atk"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}
          -- RandomSeedPool["def"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}
          -- for i,v in pairs(MemberAttackList) do
          --     if v ~= nil then
          --        RandomSeedPool["atk"][i] = v.m_startSeed
          --     end
          -- end
          -- for i,v in pairs(MemberDeffenceList) do
          --     if v ~= nil then
          --        RandomSeedPool["def"][i] = v.m_startSeed
          --     end
          -- end
      end
  elseif EmbattleMgr.nCurBattleType == BattleType_Legion then --军团
      self:getAllMonster()
      local armyData = srv_blockArmyData["tempo"]
      if #string.split(armyData, "|") == 1 then
         self:initMontsers(CurBattleStep)
      else
         CurBattleStep = tonumber(string.split(armyData, "|")[2])
         self:initMontsers(CurBattleStep)
         local armyHpInfo = string.split(string.split(armyData, "|")[3],";")
         for k,v in pairs(MemberDeffenceList) do
            if v ~= nil then
              local hasDead = true
              for i=1,#armyHpInfo do
                local tmpHp = string.split(armyHpInfo[i],":")
                if tonumber(v.fightPos) == tonumber(tmpHp[3]) then
                  hasDead = false
                  v.m_attackInfo.curHp = tonumber(tmpHp[2])
                  v.progress:setProgress(v.m_attackInfo.curHp/v.m_attackInfo.maxHp*100)
                  break
                end
              end
              if hasDead == true then
                  v.m_isDead = true
                  v:removeSelf()
              end
            end
         end
      end
  elseif EmbattleMgr.nCurBattleType == BattleType_WorldBoss then --世界BOSS
      self:getAllMonster()
      self:initMontsers(CurBattleStep)
      for i=1,7 do
        if MemberDeffenceList[i] ~= nil then
            MemberDeffenceList[i].m_attackInfo.curHp = BattleData.boss.hp
            break
        end
      end
  else --PVE
    self:getAllMonster()
    --加载第一小关的怪物
    self:initMontsers(CurBattleStep)
  end
  for k,v in pairs(MemberAttackList) do
      if v.m_memberType ~=  MemberAllType.kMemberHero then
          local tmpSkls = string.split(carData[v.m_attackInfo.tptId]["sklOrder"],"#")
          for i=1,#tmpSkls do
              if tonumber(skillData[tonumber(tmpSkls[i])]["sklType"]) == 3 then
                  table.insert(AttackHaloSkillList, tmpSkls[i])
              end
          end
      end
  end
  if CurFightBattleType == FightBattleType.kType_PVP then
      for k,v in pairs(MemberDeffenceList) do
          if v.m_memberType ~=  MemberAllType.kMemberHero then
              local tmpSkls = string.split(carData[v.m_attackInfo.tptId]["sklOrder"],"#")
              for i=1,#tmpSkls do
                  if tonumber(skillData[tonumber(tmpSkls[i])]["sklType"]) == 3 then
                      table.insert(DeffenceHaloSkillList,tmpSkls[i])
                  end
              end
          end
      end
  end
end

function BattleScene:getAllMonster()
    self.rewardData = BattleData["rewardItems"]
    --三场战斗的怪物信息
    self.allMonsterInfo = {
      [1] = {},
      [2] = {},
      [3] = {}
    }
    self.golds = string.split(blockData[tonumber(BattleID)]["gold"],"|")
    local  monsterStrs = ""
    if 2==srv_userInfo.mainline and tonumber(blockData[tonumber(BattleID)]["campType"]) == 1 then  --恶
       monsterStrs = string.split(blockData[tonumber(BattleID)]["monstersEvil"],"|")
    else --善
       monsterStrs = string.split(blockData[tonumber(BattleID)]["monsters"],"|")
       -- printTable(monsterStrs)
       -- monsterStrs = {
       --                 [1] = "12011002:1:28:1",
       --                 [2] = "12012002:1:28:2",
       --                 [3] = "31008002:1:28:3",
       --                 [4] = "31008001:1:28:4",
       --                 [5] = "12012004:1:28:5",
       --                 [6] = "12001004:1:28:6",
       --                 [7] = "31011006:1:28:7",
       --                 [10] = "12011002:2:28:1",
       --              }
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
    -- self.allMonsterInfo[3] = {[1] = {[1] = 21014004, [2] = 2, [3] = 20, [4] = 1}}
    printTable(self.allMonsterInfo)
end

function BattleScene:GetResNum()
  local num = 8
  if CurFightBattleType ~= FightBattleType.kType_PVP then
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
  --加载英雄技能资源
  for k,v in pairs(BattleData["members"]) do
      local resSkillIDs = {}
      if v["mtype"] ~= MemberAllType.kMemberHero then
          local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
          resSkillIDs = string.split(skillIdsStr,"#")
          local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
          local hasStartEnergy = false
          if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
              local exclusive = string.split(exclusiveStr, "|")
              for i=1,#exclusive do
                  local oneAdd = string.split(exclusive[i],"#")
                  if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                      hasStartEnergy = true
                      break
                  end
              end
          end
          if hasStartEnergy == true then
              for sk,sv in pairs(resSkillIDs) do
                  if sv ~= nil and sv ~= 0 then
                      if cc.FileUtils:getInstance():isFileExist("Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist") then
                          num = num + 1
                      end
                      if skillData[tonumber(sv)]["buffId"] ~= "null" and tonumber(skillData[tonumber(sv)]["buffId"]) ~= 0 then
                          num = num + 1
                      end
                  end
              end
          end
      end
  end
  --加载敌人资源
  if CurFightBattleType == FightBattleType.kType_PVP then
    for k,v in pairs(BattleData["enemys"]) do
      local resSkillIDs = {}
        if v["mtype"] ~= MemberAllType.kMemberHero then
            local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
            resSkillIDs = string.split(skillIdsStr,"#")
            local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
            local hasStartEnergy = false
            if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
                local exclusive = string.split(exclusiveStr, "|")
                for i=1,#exclusive do
                    local oneAdd = string.split(exclusive[i],"#")
                    if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                        hasStartEnergy = true
                        break
                    end
                end
            end
            if hasStartEnergy == true then
                for sk,sv in pairs(resSkillIDs) do
                    if sv ~= nil and sv ~= 0 then
                        if cc.FileUtils:getInstance():isFileExist("Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist") then
                          num = num + 1
                        end
                        if skillData[tonumber(sv)]["buffId"] ~= "null" and tonumber(skillData[tonumber(sv)]["buffId"]) ~= 0 then
                          num = num + 1
                      end
                    end
                end
            end
        end
    end
  end
  return num
end
function BattleScene:LoadResAsync()
  if nil==g_LoadingScene or nil==g_LoadingScene.Instance then
    return
  end
  local instance = g_LoadingScene.Instance
  --加载死亡特效
  display.addSpriteFrames("Battle/Skill/DeadEff.plist", "Battle/Skill/DeadEff.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/DeadEff.plist",pngStr = "Battle/Skill/DeadEff.png"})
  --加载激光炮开火特效
  display.addSpriteFrames("Battle/Skill/LaserFireEff.plist", "Battle/Skill/LaserFireEff.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/LaserFireEff.plist",pngStr = "Battle/Skill/LaserFireEff.png"})
  --加载坦克尘土特效
  display.addSpriteFrames("Battle/Skill/dust_10001.plist", "Battle/Skill/dust_10001.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/dust_10001.plist",pngStr = "Battle/Skill/dust_10001.png"})
  --加载机械怪冒烟特效
  display.addSpriteFrames("Battle/Skill/SmokeFrames.plist", "Battle/Skill/SmokeFrames.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/SmokeFrames.plist",pngStr = "Battle/Skill/SmokeFrames.png"})
  --加载技能冷却到位的特效资源
  display.addSpriteFrames("Battle/Skill/SkillOkRes.plist", "Battle/Skill/SkillOkRes.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/SkillOkRes.plist",pngStr = "Battle/Skill/SkillOkRes.png"})
  --加载特种弹冷却到位资源
  display.addSpriteFrames("Battle/SpeBullet/SeReadyFrames.plist", "Battle/SpeBullet/SeReadyFrames.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/SpeBullet/SeReadyFrames.plist",pngStr = "Battle/SpeBullet/SeReadyFrames.png"})
  --主角技能套用资源不对  暂时强制加载3连击的受击资源  记得删除！
  display.addSpriteFrames("Battle/Skill/beAtkEff_1012.plist", "Battle/Skill/beAtkEff_1012.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/beAtkEff_1012.plist",pngStr = "Battle/Skill/beAtkEff_1012.png"})
  --主炮
  display.addSpriteFrames("Battle/Skill/MainEpoEff.plist", "Battle/Skill/MainEpoEff.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/MainEpoEff.plist",pngStr = "Battle/Skill/MainEpoEff.png"})

  --PVE主炮特种弹
  if CurFightBattleType ~= FightBattleType.kType_PVP then
    for i = 1,3 do
       local bulletid = BattleFormatInfo["matrix"][string.format("bullet%d",i)]
       if bulletid > -1 then
           for j = 1, #BattleFormatInfo["seBlts"] do
               if BattleFormatInfo["seBlts"][j]["id"] == bulletid then
                   local seTptId = BattleFormatInfo["seBlts"][j]["templateId"]
                   display.addSpriteFrames("Battle/SpeBullet/Skill"..seTptId..".plist", "Battle/SpeBullet/Skill"..seTptId..".png", handler(instance, instance.ImgDataLoaded))
                   table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/SpeBullet/Skill"..seTptId..".plist",pngStr = "Battle/SpeBullet/Skill"..seTptId..".png"})
                   if tonumber(seTptId) ~= 1095001 then
                       local buffResStr = buffData[itemData[seTptId]["buffId"]]["buffResId"]
                       display.addSpriteFrames("Battle/Bullet/"..buffResStr..".plist", "Battle/Bullet/"..buffResStr..".png", handler(instance, instance.ImgDataLoaded))
                       table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..buffResStr..".plist",pngStr = "Battle/Bullet/"..buffResStr..".png"})
                   end
                   break
               end
           end
       end
    end
  end
  --加载英雄技能资源
  for k,v in pairs(BattleData["members"]) do
      local resSkillIDs = {}
      if v["mtype"] ~= MemberAllType.kMemberHero then
          local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
          resSkillIDs = string.split(skillIdsStr,"#")
          local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
          local hasStartEnergy = false
          if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
              local exclusive = string.split(exclusiveStr, "|")
              for i=1,#exclusive do
                  local oneAdd = string.split(exclusive[i],"#")
                  if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                      hasStartEnergy = true
                      break
                  end
              end
          end
          if hasStartEnergy == true then
              for sk,sv in pairs(resSkillIDs) do
                  if sv ~= nil and sv ~= 0 then
                      display.addSpriteFrames("Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist", "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".png", handler(instance, instance.ImgDataLoaded))
                      table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist",pngStr = "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".png"})
                      if skillData[tonumber(sv)]["buffId"] ~= "null" and tonumber(skillData[tonumber(sv)]["buffId"]) ~= 0 then
                          local bufResID = buffData[tonumber(skillData[tonumber(sv)]["buffId"])]["buffResId"]
                          display.addSpriteFrames("Battle/Bullet/"..tostring(bufResID)..".plist", "Battle/Bullet/"..tostring(bufResID)..".png", handler(instance, instance.ImgDataLoaded))
                          table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..tostring(bufResID)..".plist",pngStr = "Battle/Bullet/"..tostring(bufResID)..".png"})
                      end
                  end
              end
          end
      end
  end
  --加载敌人资源
  if CurFightBattleType == FightBattleType.kType_PVP then
      for k,v in pairs(BattleData["enemys"]) do
          if CurFightBattleType == FightBattleType.kType_PVP then
            local resSkillIDs = {}
              if v["mtype"] ~= MemberAllType.kMemberHero then
                  local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
                  resSkillIDs = string.split(skillIdsStr,"#")
                  local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
                  local hasStartEnergy = false
                  if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
                      local exclusive = string.split(exclusiveStr, "|")
                      for i=1,#exclusive do
                          local oneAdd = string.split(exclusive[i],"#")
                          if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                              hasStartEnergy = true
                              break
                          end
                      end
                  end
                  if hasStartEnergy == true then
                      for sk,sv in pairs(resSkillIDs) do
                          if sv ~= nil and sv ~= 0 then
                              display.addSpriteFrames("Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist", "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".png", handler(instance, instance.ImgDataLoaded))
                              table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".plist",pngStr = "Battle/Skill/Skill"..tostring(skillData[tonumber(sv)]["resId"])..".png"})
                              if skillData[tonumber(sv)]["buffId"] ~= "null" and tonumber(skillData[tonumber(sv)]["buffId"]) ~= 0 then
                                  local bufResID = buffData[tonumber(skillData[tonumber(sv)]["buffId"])]["buffResId"]
                                  display.addSpriteFrames("Battle/Bullet/"..tostring(bufResID)..".plist", "Battle/Bullet/"..tostring(bufResID)..".png", handler(instance, instance.ImgDataLoaded))
                                  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..tostring(bufResID)..".plist",pngStr = "Battle/Bullet/"..tostring(bufResID)..".png"})
                              end
                          end
                      end
                  end
              end
          end
      end
  end
  --根据是否需要切换主城背景，判断是否需要释放当前背景图
  -- if lastTownId~=mapAreaId then
    
  -- end
end

function BattleScene:addBattleFrameCache(_member)
  local loadUtil = g_loadUtil.new()
  local function addSkillCahe(_skillId)
      loadUtil:addRes(loadUtil.resType.plistType,"Battle/Skill/Skill"..tostring(_skillId),1)
      table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/Skill"..tostring(_skillId)..".plist",pngStr = "Battle/Skill/Skill"..tostring(_skillId)..".png"})
  end
  local function addBuffCahe(_buffId)
      if _buffId ~= "null" and tonumber(_buffId) ~= 0 then
          local resID = buffData[_buffId]["buffResId"]
          loadUtil:addRes(loadUtil.resType.plistType,"Battle/Bullet/"..tostring(resID),1)
          table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..tostring(resID)..".plist",pngStr = "Battle/Bullet/"..tostring(resID)..".png"})
      end
  end
  if IsMenBlock == true and LaserGunInfo.buffId ~= 0 then
      addBuffCahe(LaserGunInfo.buffId)
  end
  if _member ~= nil then
      for sk,sv in pairs(_member.m_energySkills) do
        if sv.id ~= nil and sv.id ~= 0 then
            addSkillCahe(skillData[sv.id]["resId"])
            addBuffCahe(skillData[sv.id]["buffId"])
        end
      end
      loadUtil:startLoad()
      return
  else
      --加载英雄技能资源
    for k,v in pairs(BattleData["members"]) do
        local resSkillIDs = {}
        if v["mtype"] == MemberAllType.kMemberHero then
            resSkillIDs = string.split(memberData[tonumber(v["tptId"])]["skillIds"],"#")
            table.insert(resSkillIDs,#resSkillIDs + 1,itemData[memberData[tonumber(v["tptId"])]["weaponTmpId"]]["sklId"])
            for sk,sv in pairs(resSkillIDs) do
                if sv ~= nil and sv ~= 0 then
                  addSkillCahe(skillData[tonumber(sv)]["resId"])
                  addBuffCahe(skillData[tonumber(sv)]["buffId"])
                end
            end
        else
            local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
            resSkillIDs = string.split(skillIdsStr,"#")
            local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
            local hasStartEnergy = false
            if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
                local exclusive = string.split(exclusiveStr, "|")
                for i=1,#exclusive do
                    local oneAdd = string.split(exclusive[i],"#")
                    if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                        hasStartEnergy = true
                        break
                    end
                end
            end
            if hasStartEnergy == false then
                for sk,sv in pairs(resSkillIDs) do
                    if sv ~= nil and sv ~= 0 then
                        addSkillCahe(skillData[tonumber(sv)]["resId"])
                        addBuffCahe(skillData[tonumber(sv)]["buffId"])
                    end
                end
            end
        end
    end
    --加载敌人资源
    if CurFightBattleType == FightBattleType.kType_PVP then
      for k,v in pairs(BattleData["enemys"]) do
        local resSkillIDs = {}
        if v["mtype"] == MemberAllType.kMemberHero then
            resSkillIDs = string.split(memberData[tonumber(v["tptId"])]["skillIds"],"#")
            for sk,sv in pairs(resSkillIDs) do
                if sv ~= nil and sv ~= 0 then
                 addSkillCahe(skillData[tonumber(sv)]["resId"])
                 addBuffCahe(skillData[tonumber(sv)]["buffId"])
                end
            end
        else
            local skillIdsStr = string.split(carData[tonumber(v["carTptId"])]["skillIds"],"|")[1]
            resSkillIDs = string.split(skillIdsStr,"#")
            local exclusiveStr = carData[tonumber(v["carTptId"])]["exclusive"]
            local hasStartEnergy = false
            if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
                local exclusive = string.split(exclusiveStr, "|")
                for i=1,#exclusive do
                    local oneAdd = string.split(exclusive[i],"#")
                    if tonumber(oneAdd[1]) == ExclusiveType.kStartEnergy then
                        hasStartEnergy = true
                        break
                    end
                end
            end
            if hasStartEnergy == false then
                for sk,sv in pairs(resSkillIDs) do
                    if sv ~= nil and sv ~= 0 then
                        addSkillCahe(skillData[tonumber(sv)]["resId"])
                        addBuffCahe(skillData[tonumber(sv)]["buffId"])
                    end
                end
            end
        end
      end
    else
      --PVE怪物资源
      local  monsterStrs = string.split(blockData[tonumber(BattleID)]["monsters"],"|")
      for i=1,table.getn(monsterStrs) do
         local oneMonsterStrs = string.split(monsterStrs[i],":")
         local monsterId = oneMonsterStrs[1]
         local skillIDOne = monsterData[tonumber(monsterId)]["sklId1"]
         local skillIDTwo = monsterData[tonumber(monsterId)]["sklId2"]
         if skillIDOne ~= "null" and  tonumber(skillIDOne) ~= 0 then
             addSkillCahe(skillData[skillIDOne]["resId"])
             addBuffCahe(skillData[skillIDOne]["buffId"])
         end
         if skillIDTwo ~= "null" and  tonumber(skillIDTwo) ~= 0 then
             addSkillCahe(skillData[skillIDTwo]["resId"])
             addBuffCahe(skillData[skillIDTwo]["buffId"])
         end
      end
    end
  end
  loadUtil:startLoad()
end

function BattleScene:initMontsers(_index)
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
    local pos = tonumber(oneMonsterStrs[4])
    local monster = MonsterAI.new(monsterData[tonumber(oneMonsterStrs[1])],oneMonsterStrs[3],pos,MemberPosType.defenceType)
    monster:setPosition(DefencePositions[pos][1]+display.width/2, DefencePositions[pos][2])
    self:addChild(monster,BattleDisplayLevel[pos])
    MemberDeffenceList[pos] = monster
  end
  

  --掉落分配
  for i = 1, #self.rewardData do
    --在客户端将重叠物品分开插入table
    local num = tonumber(self.rewardData[i]["num"])
    if num > 1 then
        self.rewardData[i]["num"] = 1
        local tmp = self.rewardData[i]
        for i=2,num do
          table.insert(self.rewardData, #self.rewardData + 1, tmp)
        end
    end
  end
  if EmbattleMgr.nCurBattleType ~= BattleType_Legion then --PVE掉落
    for i = 1, #self.rewardData do
     if tonumber(self.rewardData[i]["node"]) == _index then        
        local boxIndex = math.random(#self.allMonsterInfo[_index])
        local  boxPos = self.allMonsterInfo[_index][boxIndex][4]
        if MemberDeffenceList[tonumber(boxPos)] ~= nil then
           table.insert(MemberDeffenceList[tonumber(boxPos)].m_rewards, #(MemberDeffenceList[tonumber(boxPos)].m_rewards) + 1, self.rewardData[i])
        end
     end
    end
  else--军团副本掉落
    for i = 1, #self.rewardData do
     if tonumber(self.rewardData[i]["node"]) == _index then
        local  boxPos = self.rewardData[i]["position"]
        if MemberDeffenceList[tonumber(boxPos)] ~= nil then
           table.insert(MemberDeffenceList[tonumber(boxPos)].m_rewards, #(MemberDeffenceList[tonumber(boxPos)].m_rewards) + 1, self.rewardData[i])
        end
     end
    end
  end
end

--军号Buff的触发管理
function BattleScene:checkBugleBuffer()
    local function controlBugleWaitTime()
      BugleWaitTime = BugleWaitTime - 1
    end
    
    if BugleWaitTime<=0 and math.random(100)<=BugleTriggerChance then
       for k,v in pairs(MemberAttackList) do
         if v ~= nil and v.m_isDead == false then

         end
       end
       BugleWaitTime = 20
       self:scheduleRepeat(controlBugleWaitTime, 1, BugleWaitTime, 1)
    end
end
--好友助战控制
function BattleScene:controlFriendHelp()
    FriendHelpInterval = FriendHelpInterval - 1
    if FriendHelpInterval <= 0 then
        local lightframes = display.newFrames("FriendHead_%02d.png", 0, 17)
        local lightanimation = display.newAnimation(lightframes, 1.2/17)
        local headLightAction = cc.Animate:create(lightanimation)
        self.headLight:setVisible(true)
        self.headLight:runAction(headLightAction)
        local enermy = nil
        for i=1,9 do
          if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false then
              enermy = MemberDeffenceList[i]
              break
          end
        end
        local atkSp = display.newSprite("#FriendEpo_00.png")
        :addTo(self,BattleDisplayLevel[enermy.fightPos])
        atkSp:setPosition(enermy:getPositionX()-atkSp:getContentSize().width*0.2,enermy:getPositionY()+atkSp:getContentSize().height *0.25)
        local atkframes = display.newFrames("FriendEpo_%02d.png", 0, 21)
        local atkanimation = display.newAnimation(atkframes, 1.8/21)
        local atkAction = cc.Animate:create(atkanimation)
        atkSp:runAction(atkAction)
        atkSp:runAction(transition.sequence({
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(function()
                                                 if enermy ~= nil and enermy.m_isDead == false then
                                                     enermy:LiquidateDamage(math.floor(tonumber(BattleData["friMainAtk"])),false)
                                                     enermy:afterBeAttack()
                                                 end
                                              end),
                                              cc.DelayTime:create(1.5),
                                              cc.CallFunc:create(function()
                                                 self.headLight:setVisible(false)
                                                 atkSp:removeSelf()
                                              end),
                                            }))
        FriendHelpInterval = 20
        self:scheduleRepeat(self.controlFriendHelp, 1, FriendHelpInterval, 1)
    end
end

--战斗时间控制
function  BattleScene:controlFightTime()
    if g_isBattlePaused then --新手引导特种弹或者激光炮时，不算计时
      return
    end
    BattleSurplusTime  = BattleSurplusTime - 1
    if BattleSurplusTime < 0 then
      return
    end
    if BattleSurplusTime <= 0 then
      --被击败
      print("时间到 游戏失败")
      self.timeLabel:setString("00:00")
      BattleStar = 3
      IsOverTime = true
      IsBattleOver = true
      if CurFightBattleType == FightBattleType.kType_PVP then--PVP
          PVPResult = false
          self:afterPVPOver()
      elseif EmbattleMgr.nCurBattleType == BattleType_Legion then--军团
          self:legionOver()
      elseif EmbattleMgr.nCurBattleType == BattleType_WorldBoss then--世界BOSS
          self:worldBossOver()
      else--PVE
        --todo
          self:afterAllHeroDie()
      end
      return
    else
      local mStr = string.format("%02d", math.floor(BattleSurplusTime/60))
      local sStr = string.format("%02d", math.floor(BattleSurplusTime%60))
      self.timeLabel:setString(mStr..":"..sStr)
    end
end
--世界BOSS生命值推送
function BattleScene:upDateWorldBossHp(_result)
    if IsBattleOver == true or EmbattleMgr.nCurBattleType ~= BattleType_WorldBoss then
        return
    end
    for k,v in pairs(MemberDeffenceList) do
      if v.m_isDead == false and v.m_attackInfo.tptId == CurBossID then
          v.m_attackInfo.curHp = _result.data.hp - AllDamageValue
          self.bossHpProgress:setPercentage(v.m_attackInfo.curHp*100/v.m_attackInfo.maxHp)
      end
    end
end

--世界BOSS结算
function BattleScene:worldBossOver()
    self.skillLayer:setVisible(false)
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:doEvent("goWin")
       end
    end
    --计算伤害
    comData={}
    comData["characterId"] = srv_userInfo.characterId
    comData["blockId"] = BattleID
    comData["maxAtk"] = BattleVerify["maxAtk"]
    comData["maxDef" ] = BattleVerify["maxDef"]
    comData["maxCri"] = BattleVerify["maxCri"]
    comData["hurt"] = AllDamageValue
    if BattleData["fIndex"] ~= nil then
        comData["fIndex"] = BattleData["fIndex"]
    end
    if next(SklPlayCnt) ~= nil then
      comData["SklPlayCnt"] = SklPlayCnt      
    end
    comData["rewardItems"] = {}
    for i=1,#AllLegionRewards do
      comData["rewardItems"][i] = AllLegionRewards[i].id..":"..AllLegionRewards[i].num
    end
    for i,v in ipairs(BulletUseNums) do
      if v > 0 then
        comData[string.format("bullet%d", i)] = v
      end
    end
    startLoading()
    m_socket:SendRequest(json.encode(comData), CMD_BOSS_BATTLEOVER, self, self.OnBattleReportResult)
    --收集宝箱
    for i=1,20 do
      if AllDropBox[i] ~= nil then
          AllDropBox[i]:getBox()
          AllDropBox[i] = nil
      end
    end
end

--军团结算
function BattleScene:legionOver()
    self.skillLayer:setVisible(false)
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    LaserGunAI:pauseLaserGun()
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:doEvent("goWin")
       end
    end
    --计算伤害
    comData={}
    comData["characterId"] = srv_userInfo.characterId
    comData["blockId"] = BattleID
    comData["maxAtk"] = BattleVerify["maxAtk"]
    comData["maxDef" ] = BattleVerify["maxDef"]
    comData["maxCri"] = BattleVerify["maxCri"]
    comData["hurt"] = AllDamageValue
    if IsAutoFight == true then
        comData["fightType"] = 3
    else
        comData["fightType"] = 1
    end
    if BattleData["fIndex"] ~= nil then
        comData["fIndex"] = BattleData["fIndex"]
    end
    local legionDataStr 
    if CurBattleStep == 4 then
       legionDataStr = "1"
    else
       local index = 1
       legionDataStr = tostring(BattleID).."|"..tostring(CurBattleStep).."|"
       local  hasNoDie = true
       for k,v in pairs(MemberDeffenceList) do
         if v ~= nil and v.m_isDead == false then
           hasNoDie = false
           local oneMonster = ""
           if index ~= 1 then
             oneMonster = ";"
           end
           oneMonster = oneMonster..tostring(v.m_attackInfo.tptId)..":"..tostring(v.m_attackInfo.curHp)..":"..tostring(v.fightPos)
           index = index + 1
           legionDataStr = legionDataStr..oneMonster
         end
       end
       if hasNoDie == true then
         legionDataStr = "1"
       end
    end
    comData["areaTempo"] = legionDataStr
    
    comData["item"] = ""
    for k,v in pairs(AllLegionRewards) do
       if comData["item"] == "" then
          comData["item"] = v["id"]..":"..v["num"]
          print("O1:"..comData["item"])
       else
          comData["item"] = comData["item"].."|"..v["id"]..":"..v["num"]
          print("O2:"..comData["item"])
       end
    end
    for i,v in ipairs(BulletUseNums) do
      if v > 0 then
        comData[string.format("bullet%d", i)] = v
      end
    end
    startLoading()
    m_socket:SendRequest(json.encode(comData), CMD_FIGHT_REPORT, self, self.OnBattleReportResult)
    --收集宝箱 
    for i=1,20 do
      if AllDropBox[i] ~= nil then
          AllDropBox[i]:getBox()
          AllDropBox[i] = nil
      end
    end
end

--进入下一个小关
function BattleScene:nextButtonClicked()

    if not self.nextItem:isVisible() then
      return
    end

    self.nextItem:setVisible(false)

    GuideManager:removeGuideLayer()

    local moveTime = 0
    moveTime = StartMoveTime*StartSpeedAdd

    -- if self.battlebg:getNumberOfRunningActions() == 0 then
    --     self.battlebg:runAction(cc.MoveTo:create(moveTime, cc.p(display.width-display.width/2*(CurBattleStep-1),display.cy)))
    -- elseif  self.battlebg:getNumberOfRunningActions() >= 1 and self.shakeAction ~= nil and isNodeValue(self.shakeAction) and self.shakeAction:isDone() == false then        
    --     self.battlebg:runAction(cc.MoveTo:create(moveTime, cc.p(display.width-display.width/2*(CurBattleStep-1),display.cy)))
    -- else
    --     return
    -- end

    --上面注释掉的这几行，在isDone()方法中容易引起空针

    self.battlebg:runAction(cc.MoveTo:create(moveTime, cc.p(display.width-display.width/2*(CurBattleStep-1),display.cy)))

    --移除怪物的尸体
    for k,v in pairs(MemberDeffenceList) do
       if v ~= nil and v.m_isDead == false then
         v:clearBuff()
       end
    end

    for k,v in pairs(MemberDeffenceList) do
      if(v ~= nil and v.m_isRemoved == false) then
          v:removeSelf()  
      end
    end
    
    self:collectBox()
    --成员移动
    self:initMontsers(CurBattleStep)
    for k,v in pairs(MemberAttackList) do
       if v ~= nil  and  v.m_isDead == false then
    
          v:doEvent("goReady")
       end
    end
    
    if CurBossID ~= 0 and CurBattleStep == 3 then
        self.bossShowBg = display.newSprite("Battle/bossShowBg.png")
        :pos(display.width*0.5, display.height*0.5)
        :addTo(self,SkillMemmberLevel)
        self.bossShowBg:runAction(cc.RepeatForever:create(transition.sequence({
                                                      cc.FadeTo:create(0.3,50),
                                                      cc.FadeTo:create(0.3,255),
                                                  })))
        self.rightWarning = display.newSprite("Battle/bossWarning.png")
        :addTo(self.bossShowBg)
        self.leftWarning = display.newSprite("Battle/bossWarning.png")
        :addTo(self.bossShowBg)
        self.bossShowTitle = display.newSprite("Battle/bossShowTitle.png")
        :pos(display.width*0.5,display.height*0.55)
        :addTo(self.bossShowBg)
        self.rightWarning:setPosition(-self.rightWarning:getContentSize().width*0.5, display.height*0.55)
        self.leftWarning:setPosition(display.width + self.leftWarning:getContentSize().width*0.5, display.height*0.55)
        self.leftWarning:setScaleX(-1)
        self.rightWarning:runAction(cc.MoveBy:create(0.3, cc.p(self.rightWarning:getContentSize().width,0)))
        self.leftWarning:runAction(cc.MoveBy:create(0.3, cc.p(-self.rightWarning:getContentSize().width,0)))
        self.bossShowBg:performWithDelay(function()
          self.bossShowBg:removeSelf()
        end, moveTime*0.8)
    end
    
    if self.bgMusics[CurBattleStep] ~= self.bgMusics[CurBattleStep-1] then
        audio.playMusic("audio/battleMusic/"..self.bgMusics[CurBattleStep]..".mp3", true)
    end
    --上方进度指示
    if CurBattleStep == 2 then
       local function setStepTwoMark()
         if EmbattleMgr.nCurBattleType ~= BattleType_Legion then
            self.timeLabel:setString("01:30")
            BattleSurplusTime = 90
         end
         self.stepTwoMark:setTexture("Battle/guanka_hong-01.png")
       end
       local seq = transition.sequence({
                                          cc.MoveTo:create(moveTime,cc.p(display.width/2,  self.progressTank:getPositionY())),
                                          cc.CallFunc:create(setStepTwoMark)
                                      })
         self.progressTank:runAction(seq)
         self.stepProgressOne:goProgress(moveTime, 100)
    else
       local function setStepThreeMark()
          if EmbattleMgr.nCurBattleType ~= BattleType_Legion then
             self.timeLabel:setString("01:30")
             BattleSurplusTime = 90
          end
          self.stepThreeMark:setTexture("Battle/guanka_hong-01.png")
       end
       local seq = transition.sequence({
                                          cc.MoveTo:create(moveTime,cc.p(display.width*21/32, self.progressTank:getPositionY())),
                                          cc.CallFunc:create(setStepThreeMark)
                                      })
          self.progressTank:runAction(seq)
          self.stepProgressTwo:goProgress(moveTime, 100)
    end
end

function BattleScene:GoToUIDialog()
    print("---------------GoToUIDialog{}")
    if self.dialog~=nil then
        print("self.dialog ~= nil ,return---------------")
        self.dialog:SetTouchState(true)
        return
    elseif self.hasDialogPlayed[CurBattleStep] then
        return
    end
    if tonumber(PlotBlockInfo[tonumber(CurBattleStep)]) == 1 then
        self.hasDialogPlayed[CurBattleStep] = true
        -- self:pause()
        pauseTheBattle(true)
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

function BattleScene:addBossProgress()
    --移除原有的进度条
    if self.stepProgressOne then
        self.stepProgressOne:setVisible(false)
    end
    if self.stepProgressTwo then
        self.stepProgressTwo:setVisible(false)
    end
    if self.stepOneMark then
        self.stepOneMark:setVisible(false)
    end
    if self.stepTwoMark then
        self.stepTwoMark:setVisible(false)
    end
    if self.stepThreeMark then
        self.stepThreeMark:setVisible(false)
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
    if EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
        for k,v in pairs(MemberDeffenceList) do
            if v.m_attackInfo.tptId == CurBossID then
                self.bossHpProgress:setPercentage(v.m_attackInfo.curHp*100/v.m_attackInfo.maxHp)
            end
        end
    else
        self.bossHpProgress:setPercentage(100)
    end

    display.newSprite("Battle/xxxttu_d02-02.png")
    :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    :addTo(bossHpBg)
    display.newSprite("Head/round_"..monsterData[tonumber(CurBossID)]["resId"]..".png")
    :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    :scale(0.8)
    :addTo(bossHpBg)
end

function BattleScene:checkIsAllReady()
    for k,v in pairs(MemberAttackList) do 
        if v ~= nil  and  v.m_isReady == false then
            return
        end
    end

    if tonumber(CurBattleStep) == 1 then
        self:showSceneDialog(DialogShowTime.DialogBehindFight)
        if CurBossID ~= 0 and (AllBattleStep==1 or CurFightBattleType == FightBattleType.kType_WorldBoss) then --BOSS血条
            self:addBossProgress()
        end
    elseif tonumber(CurBattleStep) == 2 then
        self:GoToUIDialog()
    elseif tonumber(CurBattleStep) == 3 then
        if CurBossID ~= 0 then --BOSS血条
            self:addBossProgress()
        end
        self:GoToUIDialog()
    end

    -- if BattleID==10000001 then
    --   --移除原有的进度条
            
    --         --加载BOSS血条
    --         local bossHpBg = display.newSprite("Battle/xxxttu_d02-03.png")
    --         :pos(display.width*0.5,display.height*0.93)
    --         :addTo(self)
    --         self.bossHpProgress = display.newProgressTimer("Battle/xxxttu_d02-04.png", display.PROGRESS_TIMER_BAR)
    --         :addTo(bossHpBg)
    --         self.bossHpProgress:setMidpoint(cc.p(1, 0))
    --         self.bossHpProgress:setBarChangeRate(cc.p(1, 0))
    --         self.bossHpProgress:setPosition(bossHpBg:getContentSize().width*0.425,bossHpBg:getContentSize().height*0.485)
    --         self.bossHpProgress:setPercentage(100)

    --         display.newSprite("Battle/xxxttu_d02-02.png")
    --         :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    --         :addTo(bossHpBg)
    --         display.newSprite("Head/round_"..tostring(CurBossID)..".png")
    --         :pos(bossHpBg:getContentSize().width*0.89,bossHpBg:getContentSize().height*0.5)
    --         :addTo(bossHpBg)
    -- end
end

function BattleScene:showSceneDialog(_showTimeType)
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
        -- self:pause()
        pauseTheBattle(true)
        self.sceneDialog = UISceneDlg.new()
        :addTo(self,150)
        self.sceneDialog:setVisible(true)
        self.sceneDialog:SetFinishCallback(handler(self,dialogFinishCallBackFun))
        self.sceneDialog:TriggerDialog(tonumber(DialogDetailInfo[1]),DialogType.FightPlot) 
    else
        if _showTimeType == DialogShowTime.DialogBehindFight then
            self:showNormalDialog(DialogShowTime.DialogBehindFight)
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
            self:sendWin()
        end
    end
end

function BattleScene:perDialogCallBack(p)
      if p.param1 == nil or tonumber(p.param1) == 0 then
        return
      end
      local joinNpc = tonumber(p.param1)
      for i=3,1,-1 do
        if MemberAttackList[i] == nil or MemberAttackList[i].m_isDead == true then
            --NPC
            print("-------------joinNpc:"..joinNpc)
            joinNpcData[joinNpc].pos = i
            local hero = HeroAI.new(joinNpcData[joinNpc],MemberPosType.attackType)
            joinNpc = 0
            hero:setPosition(AttackPositions[i][1]-display.width/2, AttackPositions[i][2])
            self:addChild(hero,BattleDisplayLevel[i])
            MemberAttackList[i] = hero
            self:addBattleFrameCache(hero)
            --控制台
            local tempDesk = ControlDesk.new(MemberAttackList[i],i)
            :addTo(self,25)
            self.allControlDesk[i] = tempDesk
            self:resetControlDesk()
            g_allControlDesk[#g_allControlDesk+1]=tempDesk

            self.joinIndex = i
            break
        end
      end
end


function  BattleScene:showNormalDialog(_showTimeType)
    local function nextStep()
       if tonumber(DialogBlockInfo[1]) == 2 then
           self:showSceneDialog(DialogShowTime.DialogAfterFight)
       else
           self:sendWin()
       end
    end
    if self.dialog~=nil then
        print("self.dialog ~= nil ,return---------------")
        self.dialog:SetTouchState(true)
        return
    elseif self.hasDialogPlayed[CurBattleStep] then
        return
    end

    printTable(srv_blockData)
    if tonumber(PlotBlockInfo[tonumber(CurBattleStep)]) == 1 then
        --因为修改过第一大区一二关卡的ID,这里做个限制，如果第三都通过了，第一二关不出现对话
        if ((BattleID==11001001 or BattleID==11001002) and 
            srv_blockData[12001003] and srv_blockData[12001003].star>0) then
          --复制下面else内容
          if _showTimeType == DialogShowTime.DialogBehindFight then
              self:begainFight()
          elseif _showTimeType == DialogShowTime.DialogAfterFight then
              self:showSceneDialog(DialogShowTime.DialogAfterFight)
          end
          return
        end
        self.hasDialogPlayed[CurBattleStep] = true
        -- self:pause()
        pauseTheBattle(true)
        self.dialog = UIDialog.new()
        :addTo(self,150)
        self.dialog:setVisible(true)
        self.dialog:TriggerDialog(tonumber(PlotDetailInfo[tonumber(CurBattleStep)]), DialogType.FightPlot)
        self.dialog:SetPerConversationCallback(handler(self,self.perDialogCallBack))
        if _showTimeType == DialogShowTime.DialogBehindFight then
            self.dialog:SetFinishCallback(handler(self,self.begainFight))
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
            self.dialog:SetFinishCallback(handler(self,nextStep))
        end
    else
        if _showTimeType == DialogShowTime.DialogBehindFight then
            self:begainFight()
        elseif _showTimeType == DialogShowTime.DialogAfterFight then
            self:showSceneDialog(DialogShowTime.DialogAfterFight)
        end
    end
end

function BattleScene:begainFight()
    print("开始战斗了")
    if self.dialog~=nil then
      self.dialog:removeSelf()
      self.dialog = nil
    end

    IsAllMonsterDead = false
    self:resume()
    resumeTheBattle()
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
    LaserGunAI:resumeLaserGun()
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:resumeCooling()
           if v:getPercent() <= 0 then
              v.okStaySp:setVisible(true)
           end
        end
    end
end

function BattleScene:afterOneHeroDie(_hero)
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

function BattleScene:afterAllHeroDie()
    self.skillLayer:setVisible(false)
    IsBattleOver = true
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    LaserGunAI:pauseLaserGun()
    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           v.okStaySp:setVisible(false)
           self.chooseSeId = 0
        end
        self.chooseCircle:setVisible(false)
    end
    for k,v in pairs(MemberAttackList) do
         if v ~= nil and v.m_isDead == false then 
           v:clearBuff()
         end
    end
    for k,v in pairs(MemberDeffenceList) do
         if v ~= nil and v.m_isDead == false then 
           v:clearBuff()
         end
    end
    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:stopAction(v.m_moveAction)
           v:doEvent("goWin")
       end
    end
    self:pause()
    if EmbattleMgr.nCurBattleType == BattleType_Legion then
        self:legionOver()
    elseif EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
        self:worldBossOver()
    else
       local function showSettle()
          if not g_IsDebug then
            cc.Director:getInstance():getScheduler():setTimeScale(1)
          end
          if self.joinIndex ~= nil then
             MemberAttackList[self.joinIndex]:removeSelf()
             MemberAttackList[self.joinIndex] = nil 
          end
          if g_isNewCreate then
            
            addAwardLayer(display.getRunningScene(),{carID = 1010},function ( ... )
              app:enterScene("LoadingScene", {SceneType.Type_Main})
            end,11111)
          else
            local resultData = {}
            resultData["level"] = srv_userInfo["level"]
            resultData["maxExp"] = srv_userInfo["maxexp"]
            resultData["exp"] = srv_userInfo["exp"]
            local sLayer = SettlementLayer.new(false,nil,resultData)
            :pos(0,0)
            :addTo(self,80)
          end
       end
       self.autoFightItem:performWithDelay(showSettle, BattleOverDelay)
       if CurFightBattleType ~= FightBattleType.kType_PVP then
          modify_srv_blockData(BattleID,0)

          luaFailBlock(blockData[tonumber(BattleID)]["name"],"too weak")
          if blockData[tonumber(BattleID)].type==1 or blockData[tonumber(BattleID)].type==2 then
            if self.timeLabel:getString()=="00:00" then
              DCLevels.fail(blockData[tonumber(BattleID)].id..","..blockData[tonumber(BattleID)].name,"战斗超时")
            else
              DCLevels.fail(blockData[tonumber(BattleID)].id..","..blockData[tonumber(BattleID)].name,"英雄死光")
            end
          end
          printInfo("------------DCLevels.fail")
       end
    end
end

function BattleScene:afterAllMonsterDie()
    --IsAllMonsterDead = true
    if IsAllMonsterDead == false then
      IsAllMonsterDead = true  --在begainFight()中重置
    else
      return  --防止怪物同时挂掉处理多次
    end

    self.skillLayer:setVisible(false)
    skillResumeMembers()
    --上方进度指示
    if AllBattleStep == 3 then
        if CurBattleStep == 1 then
           self.stepOneMark:setTexture("Battle/guanka_hong-01.png")
        elseif CurBattleStep == 2 then
           self.stepTwoMark:setTexture("Battle/guanka_hong-01.png")
        else
           self.stepThreeMark:setTexture("Battle/guanka_hong-01.png")
        end
    end
    --暂停技能和战斗计时
    g_isBattlePaused = true
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end
    LaserGunAI:pauseLaserGun()
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win"then
           v:stopAction(v.m_moveAction)
           v:doEvent("goWin")
       end
    end

    if self.sebltControls then
        for k,v in pairs(self.sebltControls) do--技能
           v:pauseCooling()
           v.chooseSp:setVisible(false)
           v.okSp:setVisible(false)
           v.okStaySp:setVisible(false)
           self.chooseSeId = 0
        end
        self.chooseCircle:setVisible(false)
    end
    
    --金币显示
    local goldNum = tonumber(self.goldLabel:getString()) + tonumber(self.golds[CurBattleStep]) 
    self.goldLabel:setString(tostring(goldNum))
    
    CurBattleStep = CurBattleStep + 1
    for k,v in pairs(MemberAttackList) do
         if v ~= nil and v.m_isDead == false then
           v:clearBuff()
         end
    end

    if isBattleWin() then
      --胜利
      if AllBattleStep == 1 then
          CurBattleStep = 4
      end
      self:collectBox()
      self:showNormalDialog(DialogShowTime.DialogAfterFight)
    else
      --下一段
      self.nextItem:setVisible(true)
      --新手教程
      GuideManager:removeGuideLayer()
      local function checkIsAuto()
        if IsAutoFight then
          if self.nextItem:isVisible() == true then
              self:nextButtonClicked()
          end
        else
          self.nextItem:performWithDelay(function()
            if self.nextItem:isVisible() == true then 
                self:nextButtonClicked()
            end
          end, 1)
        end
      end
      self.nextItem:performWithDelay(checkIsAuto, 0.8)
    end
end

function BattleScene:collectBox()
    --收集宝箱
    for i=1,20 do
      if AllDropBox[i] ~= nil then
         AllDropBox[i]:getBox()
         AllDropBox[i] = nil
      end
    end
    for i=1,20 do
        AllDropBox[i] = nil
    end
end

function BattleScene:sendWin()
      -- if EmbattleMgr.nCurBattleType == BattleType_PVE and tonumber(BattleID) == 11006010 and getFightBlockStar() <= 0 then--善恶选择
      --    -- local chooseLayer = MainLineChoose.new(handler(self,self.settleWin))
      --    -- :addTo(self,45) 
      -- else
         self:settleWin()
      -- end
end

function BattleScene:settleWin()
    IsBattleOver = true
    if EmbattleMgr.nCurBattleType == BattleType_Legion then
        self:legionOver()
        return
    end
    if EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
        self:worldBossOver()
        return
    end
    comData={}
    comData["characterId"] = srv_userInfo.characterId
    comData["blockId"] = BattleID
    comData["star"] = BattleStar
    comData["maxAtk"] = BattleVerify["maxAtk"]
    comData["maxDef"] = BattleVerify["maxDef"]
    comData["maxCri"] = BattleVerify["maxCri"]
    if BattleData["fIndex"] ~= nil then
        comData["fIndex"] = BattleData["fIndex"]
    end
    local allHp = 0
    local lastHp = 0

    for k,v in pairs(MemberAttackList) do
       if v.m_isDead == false then
          lastHp = lastHp + v.m_attackInfo.maxHp
       end
       allHp = allHp + v.m_attackInfo.maxHp
    end

    comData["hpPer"] = string.format("%.2f", lastHp/allHp) 
    print("----------------:"..comData["hpPer"])
      
    for i,v in ipairs(BulletUseNums) do
      if v > 0 then
        comData[string.format("bullet%d", i)] = v
      end
    end

    if IsAutoFight == true then
        comData["fightType"] = 3
    else
        comData["fightType"] = 1
    end

    fight_isInGuide = true  --是否是新手引导
    local g_step = nil
    local g_step2 = nil
   --特殊关卡的特殊处理
   
   if BattleID == 11001001 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(102)
      GuideManager.NextStep = 10106
   elseif BattleID == 11001002 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(103)
      GuideManager.NextStep = 10206
   elseif BattleID == 12001003 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(106)
      GuideManager.NextStep = 10509
   elseif BattleID == 12001004 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(112)
      GuideManager.NextStep = 11109
      bToShowBountBtn = true
   elseif BattleID == 12001005 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(113)
      srv_userInfo.isFirstRent = 0
      GuideManager.NextStep = 11211
   elseif BattleID == 11001006 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(114)
      GuideManager.NextStep = 11309
   elseif BattleID == 11001007 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(117)
      GuideManager.NextStep = 11606
   elseif BattleID == 12002001 and srv_userInfo.guideStep ~= -1 and getFightBlockStar() <= 0 then
      g_step = GuideManager:sendFinishStep(121)
      GuideManager.NextStep = 12101
   elseif BattleID == 22001002 and getFightBlockStar() <= 0 then
      g_step2 = GuideManager:openConditionGuide(GuideManager.guideConditions.after_1_2_5)
  
   else
      fight_isInGuide = false
   end
   comData.guideStep = g_step
   comData.guideStep2 = g_step2
   print("1,fight_isInGuide: ")
   print(fight_isInGuide)
   if g_isNewCreate then
      self:OnBattleReportResult({result=1,data = {}})
   else
    startLoading()
    m_socket:SendRequest(json.encode(comData), CMD_FIGHT_REPORT, self, self.OnBattleReportResult) 
  end
end

function BattleScene:afterPVPOver()
    self.skillLayer:setVisible(false)
    for k,v in pairs(self.allControlDesk) do--技能
       v:pauseDesk()
    end

    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:stopAction(v.m_moveAction)
           v:doEvent("goWin")
       end
    end    

    for k,v in pairs(MemberDeffenceList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:stopAction(v.m_moveAction)
           v:doEvent("goWin")
       end            
    end

    self:pause()
    if IsPlayback == true then
      self:pause()
      CurFightBattleType = FightBattleType.kType_PVP
      IsPlayback = false
      local function showPvpOver()
         PvpResultLayer.new()
        :pos(0, 0)
        :addTo(self,70)
      end
      self.autoFightItem:performWithDelay(showPvpOver, BattleOverDelay)
    else
      self:pause()

      if IsPvpResultSend then --同归于尽情况下，光环技能属性回退试过会被处理2次，导致作弊校验出问题，加容错处理
        return
      else
        IsPvpResultSend = true
      end

      comData={}
      comData["characterId"] = srv_userInfo.characterId
      comData["eId"] = EnermyID

      local members = {} --把己方战斗成员的初始值上传服务端对比一下，看看有没有被作弊修改过
      local enemys = {} --把敌方成员的初始值上传服务端对比一下，看看有没有被作弊修改过

      for k,v in pairs(MemberAttackList) do
         if v ~= nil then
           v:clearBuff() --再clear一次，确保万无一失
         end
      end

      for k,v in pairs(MemberDeffenceList) do    
         if v~= nil then
           v:clearBuff() --再clear一次，确保万无一失
         end
      end

      --最后回退光环技能的属性加成，必须在上面的clear buff之后做
      self:removeHaloSkill() 

      members = self:getCheckMembers() 
      enemys = self:getCheckEnemys()                

      comData["members"] = members
      comData["enemys"] = enemys
      comData['btime'] = os.time() - BattleBeginTS  --战斗持续时间    

      if PVPResult == true then
          comData["win"] = 1
      else
          comData["win"] = 0
      end

      comData["fdetail"] = {}
      --增加双方的等级，之前都是用当前玩家的等级，是有bug的
      comData["fdetail"]["mylevel"] = srv_userInfo.level
      comData["fdetail"]["elevel"] =BattleData["elevel"]

      comData["fdetail"]["members"] = BattleData["members"]
      comData["fdetail"]["enemys"] = BattleData["enemys"]
      comData["fdetail"]["eName"] = BattleData["eName"]
      comData["fdetail"]["eStrength"] = BattleData["eStrength"]
      comData["fdetail"]["strength"] = BattleData["strength"]
      --comData["fdetail"]["randomSeeds"] = RandomSeedPool
      comData["fdetail"]["randomSeed"] = RandomSeed
      startLoading()
      m_socket:SendRequest(json.encode(comData), CMD_UPDATE_PVPRESULT, self, self.OnPVPResultRet)
    end
       
end

function BattleScene:getCheckMembers( )
  local members = {}
  for k,v in pairs(MemberAttackList) do
    if v~= nil then             
       local mem = {}
       mem['mtype'] = v.m_memberType
       if mem['mtype'] == MemberAllType.kMemberHero then        
          mem['attack'] = v.m_attackInfo.attackValue
       else
          mem['mainAtk'] = v.m_mainAtk
          mem['subAtk'] = v.m_attackInfo.attackValue
       end
       mem['hp'] = v.m_attackInfo.maxHp
       mem['def'] = v.m_attackInfo.defenceValue       
       mem['crit'] = v.m_attackInfo.critValue              
       mem['hit'] = v.m_attackInfo.hitValue
       mem['miss'] = v.m_attackInfo.dodgeValue       
       --mem['mainCD'] = v.m_attackInfo.mainCD
       mem['erecover'] = 1/v.recoverSpeed
       mem['sklPlayCnt'] = v.sklPlayCnt
       mem['avgEnergy'] = v.avgEnergy

       if v.m_exclusiveInfo[ExclusiveType.kStartEnergy] ~= nil then --初始能量
         mem['initEnergy'] = v.m_exclusiveInfo[ExclusiveType.kStartEnergy] 
       else
         mem['initEnergy'] = 0 
       end

       --print("----------------------mem sklPlayCnt.."..mem['sklPlayCnt'])
       mem['pos'] = k

       members[tostring(mem['pos'])] = mem 
    end    
  end 
  return members
end

function BattleScene:getCheckEnemys( )
  local enemys = {}
  for k,v in pairs(MemberDeffenceList) do   
     if v~= nil then
       local enemy = {}
       enemy['mtype'] = v.m_memberType
       if enemy['mtype'] == MemberAllType.kMemberHero then        
          enemy['attack'] = v.m_attackInfo.attackValue
       else
          enemy['mainAtk'] = v.m_mainAtk
          enemy['subAtk'] = v.m_attackInfo.attackValue
       end

       enemy['hp'] = v.m_attackInfo.maxHp
       enemy['def'] = v.m_attackInfo.defenceValue       
       enemy['crit'] = v.m_attackInfo.critValue              
       enemy['hit'] = v.m_attackInfo.hitValue
       enemy['miss'] = v.m_attackInfo.dodgeValue       
       --enemy['mainCD'] = v.m_attackInfo.mainCD
       enemy['erecover'] = 1/v.recoverSpeed
       enemy['sklPlayCnt'] = v.sklPlayCnt
       enemy['avgEnergy'] = v.avgEnergy

       if v.m_exclusiveInfo[ExclusiveType.kStartEnergy] ~= nil then --初始能量
         enemy['initEnergy'] = v.m_exclusiveInfo[ExclusiveType.kStartEnergy] 
       else
         enemy['initEnergy'] = 0 
       end

       --print("----------------------enemy sklPlayCnt.."..enemy['sklPlayCnt'])       
       enemy['pos'] = k

       enemys[tostring(enemy['pos'])] = enemy
     end       
  end
  return enemys
end

--上传战斗结果
function BattleScene:OnPVPResultRet(result)
    if tonumber(result["result"]) == 1 then
        print("pvp 战斗上报返回")
        PVPData["enemys"] = result["data"]["enemys"]
        PVPData["lastTs"] = result["data"]["lastTs"]
        PVPData["myOrder"] = result["data"]["order"]
        local function pvplastInterval()
            if PVPData["lastTs"] >= 1000 then
                PVPData["lastTs"] = PVPData["lastTs"] - 1000
            else
                scheduler.unscheduleGlobal(self.pvpLastTimeHandle)
            end
        end
        self.pvpLastTimeHandle = scheduler.scheduleGlobal(pvplastInterval, 1)
        local function showPvpOver()
            PvpResultLayer.new()
            :pos(0, 0)
            :addTo(self,70)
        end
        self.autoFightItem:performWithDelay(showPvpOver, BattleOverDelay)

        local data = result.data
        if data.rewordDia>0 then
          self:createRewardBox(data.oldMaxOrder, data.order, data.rewordDia)
          srv_userInfo.diamond = srv_userInfo.diamond + data.rewordDia
        end
        
    elseif tonumber(result["result"]) == -1 then --检测到作弊
        PVPData["enemys"] = result["data"]["enemys"]
        PVPData["lastTs"] = result["data"]["lastTs"]
        PVPData["myOrder"] = result["data"]["order"]
        local function pvplastInterval()
            if PVPData["lastTs"] >= 1000 then
                PVPData["lastTs"] = PVPData["lastTs"] - 1000
            else
                scheduler.unscheduleGlobal(self.pvpLastTimeHandle)
            end
        end
        self.pvpLastTimeHandle = scheduler.scheduleGlobal(pvplastInterval, 1)
        local function showPvpOver()
          showMessageBox(result["msg"], nil, nil, 
              function()
                if display.getRunningScene().pvpLastTimeHandle ~= nil then
                    scheduler.unscheduleGlobal(display.getRunningScene().pvpLastTimeHandle)
                end
                app:enterScene("LoadingScene", {SceneType.Type_Main})                  
              end)
        end
        self.autoFightItem:performWithDelay(showPvpOver, BattleOverDelay)  
        
    else
      print("Error:"..result["msg"])
    end
end

function BattleScene:OnBattleReportResult(result)
   if tonumber(result["result"]) ~= 1 then
      print("Error:"..result["msg"])
      showMessageBox(result["msg"],function()
        app:enterScene("LoadingScene", {SceneType.Type_Block})
      end)
      return
   end

   
   for i=1,3 do
    local value = BulleHasNums[i]
    local num = BulletUseNums[i]
    if value and num then
      local dc_item = itemData[value.id]
      if dc_item then
          DCItem.consume(tostring(dc_item.id), dc_item.name, num, "战斗消耗特种弹")
      end
    end
   end

   if EmbattleMgr.nCurBattleType == BattleType_Legion then
        local allHp = 0
        local remainderHp = 0
        for i=1,3 do
          for j=1, #self.allMonsterInfo[i] do
            local oneMonsterStrs = self.allMonsterInfo[i][j]
            local oneHp = math.floor(monsterData[tonumber(oneMonsterStrs[1])]["hp"] + monsterData[tonumber(oneMonsterStrs[1])]["hpGF"]*(tonumber(oneMonsterStrs[3])-1))*(math.floor(tonumber(oneMonsterStrs[3])/11 + 1)/2)
            allHp = allHp + oneHp
            if i > tonumber(CurBattleStep) then
              remainderHp = remainderHp + oneHp
            end
          end
        end
        for k,v in pairs(MemberDeffenceList) do
          if v ~= nil and v.m_isDead == false then
            remainderHp = remainderHp + v.m_attackInfo.curHp
          end
        end
        local overData = {
                            allHp = allHp,
                            remainderHp = remainderHp,
                            allDamage = AllDamageValue,
                            addGold = result.data.addGold,
                            addGE = result.data.addGE
                         }
        srv_userInfo.gold = result.data.gold
        srv_userInfo.goodEvil = result.data.goodEvil
        local function showLegionOver()
           local overLayer = LegionOverLayer.new(overData)
           :pos(0,0)
           :addTo(self,80)
        end
        self.autoFightItem:performWithDelay(showLegionOver, BattleOverDelay)

        --修改军团大区进度数值
        for i,value in ipairs(legionFBData) do
          if value.areaId==blockIdtoAreaId(BattleID) then
            legionFBData[i].percent = result.data.percent
            break
          end
        end
        printTable(legionFBData)
        return
   elseif EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
        local bossIndex = 1
        for i=1,7 do
            if MemberDeffenceList[i] ~= nil then
                bossIndex = i
                break
            end
        end
        local overData = {
                            allHp = MemberDeffenceList[bossIndex].m_attackInfo.maxHp,
                            remainderHp = MemberDeffenceList[bossIndex].m_attackInfo.curHp,
                            allDamage = AllDamageValue,
                         }
        local function showWorldBossOver()
           local overLayer = WorldBossOverLayer.new(overData)
           :pos(0,0)
           :addTo(self,80)
        end
        self.autoFightItem:performWithDelay(showWorldBossOver, BattleOverDelay)
        return
   end 
   local settleInfo = {}
   settleInfo.gold = 0
   for i=1,#self.golds do
     settleInfo.gold = settleInfo.gold + tonumber(self.golds[i])
   end
   if srv_userInfo["gold"]==nil then
    srv_userInfo["gold"] = 0
   end
   srv_userInfo["gold"] = srv_userInfo["gold"] + settleInfo.gold
   settleInfo.rewards = result["data"]["rewardItems"]
   
   
   local function showSettle()
    if not g_IsDebug then
      cc.Director:getInstance():getScheduler():setTimeScale(1)
    end
      if self.joinIndex ~= nil then
          MemberAttackList[self.joinIndex]:removeSelf()
          MemberAttackList[self.joinIndex] = nil 
      end
      if g_isNewCreate then
        srv_userInfo.hasCar = 1
        addAwardLayer(display.getRunningScene(),{carID = 1010},function ( ... )
          -- app:enterScene("LoadingScene", {SceneType.Type_Main})
          app:enterScene("LoginScene",{"createRole"})
        end,11111)
      else
        local sLayer = SettlementLayer.new(true, settleInfo,result["data"])
        :pos(0,0)
        :addTo(self,80)
        if CurFightBattleType ~= FightBattleType.kType_PVP then
            luaFinishBlock(blockData[tonumber(BattleID)]["name"])
            if blockData[tonumber(BattleID)].type==1 or blockData[tonumber(BattleID)].type==2 then
              DCLevels.complete(blockData[tonumber(BattleID)].id..","..blockData[tonumber(BattleID)].name)
              printInfo("------------DCLevels.complete")
            end
        end
      end
   end
   self.autoFightItem:performWithDelay(showSettle, BattleOverDelay)
   if not g_isNewCreate then
     modify_srv_blockData(BattleID,BattleStar)
   end
end

function BattleScene:onExit()
  LaserGunAI:setItemNil()
  GuideManager:removeGuideLayer()
  --清除资源缓存
  for i,v in ipairs(AllAddedFramesCahe) do
      display.removeSpriteFramesWithFile(v.plstStr, v.pngStr)
  end
  self:resetBattle()
  local sharedScheduler = cc.Director:getInstance():getScheduler()
  sharedScheduler:setTimeScale(1.0)
end

function BattleScene:resetBattle()
  BugleWaitTime = 0
  BattleSurplusTime = 90
  IsBattleOver = false
  CurBattleStep = 1
  IsAutoFight = false
  IsPauseMemberBeforePlaySkl = true
  IsPvpResultSend = false
  IsOverTime = false
  AllDamageValue = 0
  BattleStar = 3
  FriendHelpInterval = 20
  IsAllMonsterDead = false
  AllLegionRewards = {}
  AttackHaloSkillList = {}
  DeffenceHaloSkillList = {}
  g_allControlDesk = {}
  g_spriteProgress = {}
  BulleHasNums = {}
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
  SklPlayCnt = {}

  PlotBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  PlotDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  DialogBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
  DialogDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}      
  EvilBlockInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}     --恶剧情 
  EvilDetailInfo = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}      
end

function BattleScene:scheduleRepeat(callback, interval, repeatTime, delay)
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

--竞技场最高纪录奖励框
function BattleScene:createRewardBox(lastBestRank, curBestRank, rewDiamond)
  local masklayer =  UIMasklayer.new()
  :addTo(self,100)
  local function  func()
    masklayer:removeSelf()
  end
  masklayer:setOnTouchEndedEvent(func)
  --材料信息框
  local rewardBox = display.newScale9Sprite("common/common_box.png",display.cx, 
    display.cy,
    cc.size(500, 350))
  :addTo(masklayer)
  masklayer:addHinder(rewardBox)
  local tmpSize = rewardBox:getContentSize()


    local titleLbl = display.newTTFLabel{text = "历史最高",size = 30,color = cc.c3b(226,214,141)}
        :addTo(rewardBox)
        :pos(rewardBox:getContentSize().width/2, rewardBox:getContentSize().height-45)

  --历史最高排名
  cc.ui.UILabel.new({UILabelType = 2, text = "历史最高排名：", size = 25, color = MYFONT_COLOR})
  :addTo(rewardBox)
  :pos(50, tmpSize.height/2+70)
  local rankNum = cc.LabelAtlas:_create()
  :addTo(rewardBox)
  :align(display.CENTER_LEFT, 250, tmpSize.height/2+70)
  rankNum:initWithString("","Battle/shuziheti_d02-02.png",32,36,string.byte(0))
  rankNum:setString(lastBestRank)

  --当前排名
  cc.ui.UILabel.new({UILabelType = 2, text = "当前排名：", size = 25, color = MYFONT_COLOR})
  :addTo(rewardBox)
  :pos(50, tmpSize.height/2+20)
  local rankNum = cc.LabelAtlas:_create()
  :addTo(rewardBox)
  :align(display.CENTER_LEFT, 180, tmpSize.height/2+20)
  rankNum:initWithString("","Battle/shuziheti_d02-04.png",43,49,string.byte(0))
  rankNum:setString(curBestRank)

  --提升名称
  cc.ui.UILabel.new({UILabelType = 2, text = "提升       名，奖励：", size = 25, color = MYFONT_COLOR})
  :addTo(rewardBox)
  :pos(50, tmpSize.height/2-50)

  cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
  :addTo(rewardBox)
  :align(display.CENTER, 125, tmpSize.height/2-50)
  :setString(lastBestRank- curBestRank)

  display.newSprite("common/common_Diamond.png")
  :addTo(rewardBox)
  :pos(tmpSize.width/2+80, tmpSize.height/2-50)
  :scale(0.7)

  cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
  :addTo(rewardBox)
  :pos(tmpSize.width/2+120, tmpSize.height/2-50)
  :setString(rewDiamond)

  --确定按钮
  local bt = cc.ui.UIPushButton.new({
      normal="SingleImg/messageBox/tip_okBtn.png",
      })
    :addTo(rewardBox)
    :pos(rewardBox:getContentSize().width/2, 60)
    :onButtonPressed(function(event)
      event.target:setScale(0.95)
      end)
    :onButtonRelease(function(event)
      event.target:setScale(1.0)
      end)
  :onButtonClicked(function(event)
      masklayer:removeSelf()
      end)
  local tmpNode = display.newTTFLabel{text = "确  认",size = 40,color = cc.c3b(58,60,55)}
            :addTo(bt)
    tmpNode:enableOutline(cc.c4f(177,255,154,255),0.5)
end

-- function BattleScene:OnGetPVPInfoRet(result)
--     if tonumber(result["result"]) == 1 then
--         PVPData = result["data"]
--         app:enterScene("PVPScene")
--     else
--         -- addMessageBox(self, 80)
--         showMessageBox(result["msg"])
--     end
-- end

function BattleScene:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    local _targetPos = nil
    if 10508==_guideId then
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

function BattleScene:onSocketConnected(__event)
    roleLoginData["chnlId"] = gType_Chnl
    roleLoginData["ver"] = g_Version
    startLoading()
    m_socket:SendRequest(json.encode(roleLoginData), CMD_ROLE_LOGIN, self, self.onRoleLoginResult)
    
end

function BattleScene:onRoleLoginResult(result)
    endLoading()
    if result["result"] == 1 then
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    elseif result["result"] == -2 then
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    else
        
        showTips(result.msg)
    end

end

return BattleScene