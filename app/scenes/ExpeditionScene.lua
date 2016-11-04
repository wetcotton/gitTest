--
-- Author: liufei
-- Date: 2015-08-03 18:48:44
--
local HeroAI = require("app.battle.battleAI.HeroAI")
local MonsterAI = require("app.battle.battleAI.MonsterAI")
local ControlDesk = require("app.battle.battleUI.ControlDesk")
local SpriteProgress = require("app.battle.battleUI.SpriteProgress")
local SupplyBuyBox = require("app.battle.battleUI.SupplyBuyBox")
local PvpResultLayer = require("app.battle.PVP.PvpResultLayer")

local ExpeditionScene = class("ExpeditionScene", function()
    return display.newScene("ExpeditionScene")
end)

local EnermyFramesRecords = {}
local ExpeditionBlockType = {
                              kExpeditionBlock_Men     = 1, --人战关卡
                              kExpeditionBlock_Tank    = 2, --车战关卡
                            }
local MonsterLevelControl = {-5,-3,-1,1,2,3,6,8,10,12,15,20,25,30,35,40,45,50}

local reviveCost = {100,200,500}

local ControlSupplyType = {
                            kSupplyControl_Effect = 1,  --生效
                            kSupplyControl_UnEffect = 2,--移除
                          }

function ExpeditionScene:ctor(_expeditionData)

    self._isInit = true --是否由服务端初始化（区别于过关之后的调用）
    self.bgSceneOne = display.newSprite("Expedition/expeditionBg.jpg")
    :pos(display.width, display.cy)
    :addTo(self)
    self.bgSceneOne:scale(1.3333)
    self.bgSceneTwo = display.newSprite("Expedition/expeditionBg.jpg")
    :pos(display.width*3, display.cy)
    :addTo(self)
    self.bgSceneTwo:scale(1.3333)
    
    CurFightBattleType = FightBattleType.kType_Expedition
    IsPauseMemberBeforePlaySkl = true
    BattleSurplusTime = 180
    self.allControlDesk = {}
    EnermyFramesRecords = {}
    BlockTypeScale = TankBlockScale
    IsMenBlock = false
    BattleStar = 3
    IsOverTime = false
    self.curExpeditionId = tonumber(BattleData["nId"])
    self.curSupplyState = SupplyState.kSupply_Out
    self.IsFirstIn = true
    self.curBlockType = expeditionData[self.curExpeditionId]["type2"]
    self.curFightType = self.curBlockType
    self.reviveCnt = tonumber(BattleData["reviveCnt"])

    --背景位置调整 
    if self.curExpeditionId == 10002 or self.curExpeditionId == 10007 or self.curExpeditionId == 10012 or self.curExpeditionId == 10017 then
       self.bgSceneOne:setPosition(self.bgSceneOne:getPositionX() - display.width/2,self.bgSceneOne:getPositionY())
       self.bgSceneTwo:setPosition(self.bgSceneTwo:getPositionX() - display.width/2,self.bgSceneTwo:getPositionY())
    elseif self.curExpeditionId == 10003 or self.curExpeditionId == 10008 or self.curExpeditionId == 10013 or self.curExpeditionId == 10018 or self.curExpeditionId == 10006  or self.curExpeditionId == 10011  or self.curExpeditionId == 10016 then
       self.bgSceneOne:setPosition(self.bgSceneOne:getPositionX() - display.width,self.bgSceneOne:getPositionY())
       self.bgSceneTwo:setPosition(self.bgSceneTwo:getPositionX() - display.width,self.bgSceneTwo:getPositionY())
    elseif self.curExpeditionId == 10004 or self.curExpeditionId == 10009 or self.curExpeditionId == 10014 then
       self.bgSceneOne:setPosition(self.bgSceneOne:getPositionX() - display.width*1.5,self.bgSceneOne:getPositionY())
       self.bgSceneTwo:setPosition(self.bgSceneTwo:getPositionX() - display.width*1.5,self.bgSceneTwo:getPositionY())
    end
    
    self.allSupply = BattleData["supply"]
    self.allSupplyIcon = {}
    if BattleData["ogold"] ~= nil then
       self.allGold = tonumber(BattleData["ogold"])
       self.allPoints = tonumber(BattleData["opoint"])
    else
       self.allGold = 0
       self.allPoints = 0
    end
    if BattleData["orewardItems"] ~= nil then 
      self.allRewardItems = BattleData["orewardItems"]
    else
      self.allRewardItems = {}
    end

    self:initAllUI()
    self:addControlUnit()

    if self.curExpeditionId == 10006  or self.curExpeditionId == 10011  or self.curExpeditionId == 10016 then
        self.curSupplyState = SupplyState.kSupply_In
        self:addSupplyStation()
    else
        self:initMontsers()
    end
    printTable(BattleData)
    -- writeTabToLog(BattleData,"远征战场初始化","cao.txt",2)
end

--抖动
function ExpeditionScene:shakeBg(_level)
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
  self.bgSceneOne:runAction(transition.sequence{
                                                cc.MoveBy:create(times[1],cc.p(0,ranges[1])),
                                                cc.MoveBy:create(times[2],cc.p(0,ranges[2])),
                                                cc.MoveBy:create(times[3],cc.p(0,ranges[3])),
                                                cc.MoveBy:create(times[4],cc.p(0,ranges[4])),
                                             })
  self.bgSceneTwo:runAction(transition.sequence{
                                                cc.MoveBy:create(times[1],cc.p(0,ranges[1])),
                                                cc.MoveBy:create(times[2],cc.p(0,ranges[2])),
                                                cc.MoveBy:create(times[3],cc.p(0,ranges[3])),
                                                cc.MoveBy:create(times[4],cc.p(0,ranges[4])),
                                             })
end

function ExpeditionScene:addControlUnit()
    self:initAllMember()
    self:addControlDesk()
    
    if self.seBg then
       self.seBg:removeSelf()
       self.sebltControls = {}
       self.seBg = nil
    end
    printTable(BattleData)
    LaserGunAI:removeLaserGun()
    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
       self:addSeblts()
    else
       LaserGunAI:addLaserItem(self)
    end
    
    for k,v in pairs(self.allSupplyIcon) do
        v:removeSelf()
    end
    self.allSupplyIcon = {}
    --添加加成
    for k,v in pairs(self.allSupply) do
      self:controlSupply(tonumber(v), ControlSupplyType.kSupplyControl_Effect)
    end
end

function ExpeditionScene:initAllUI()
  --计时条
  local timeBg = display.newSprite("Battle/zd_speid_d02-06.png")
  :pos(display.width*4/25, display.height*17/18)
  :addTo(self)
  local clockImage = display.newSprite("Battle/zd_speid_d02-05.png")
  :pos(timeBg:getContentSize().width*1/10, timeBg:getContentSize().height*4.5/9)
  :addTo(timeBg)
  --计时label
  self.timeLabel=cc.ui.UILabel.new({
        UILabelType = 2, text = "03:00", size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :pos(timeBg:getContentSize().width*0.35, timeBg:getContentSize().height/2)
        :addTo(timeBg)
  self:schedule(self.controlFightTime, 1)

  --技能遮挡框
  self.skillLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,150))
  :addTo(self,SkillOcclusionLevel)
  self.skillLayer:setVisible(false)
  
  --下一关按钮
  self.nextItem = cc.ui.UIPushButton.new({normal = "Battle/zhandou_xia-01.png",pressed = "Battle/zhandou_xia-01.png"})
  :onButtonClicked(function()
      self.nextItem:setVisible(false)
      self:nextButtonClicked()
  end)
  :pos(display.width*44/50, display.height*0.5)
  :addTo(self,40)
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
      pauseLayer:setVisible(false)
      display.resume()
      g_shouldBackToExpedition = true
      app:enterScene("LoadingScene", {SceneType.Type_Main})
  end)

  local backTitle = display.newSprite("Battle/jiesz_shm-02.png")
  :pos(display.width*4.4/7, display.height*0.38)
  :addTo(pauseLayer)
  
  --暂停按钮
  local pauseItem = cc.ui.UIPushButton.new({normal = "Battle/zanting01-01.png"})
  :onButtonClicked(function()
      pauseLayer:setVisible(true)
      display.pause()
  end)
  :pos(display.width/25, display.height*17/18)
  :addTo(self)
  pauseItem:scale(0.7)
  
  --金币和物品和战斗点
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
  local scoreBg = display.newSprite("Battle/zd_speid_d02-06.png")
  :pos(display.width*16.5/25, display.height*17/18)
  :addTo(self)
  local scoreImage = display.newSprite("Expedition/youhou_pusa-03.png")
  :pos(0, timeBg:getContentSize().height*0.5)
  :addTo(scoreBg)
  --金币label
  self.goldLabel=cc.ui.UILabel.new({
        UILabelType = 2, text = tostring(self.allGold), size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :align(display.CENTER,timeBg:getContentSize().width*0.5, timeBg:getContentSize().height/2)
        :addTo(goldBg)
  --宝箱label
  self.boxLabel=cc.ui.UILabel.new({
        UILabelType = 2, text = tostring(#self.allRewardItems), size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :align(display.CENTER,timeBg:getContentSize().width*0.5, timeBg:getContentSize().height/2)
        :addTo(boxBg)
  --战斗点Label
  self.scoreLabel=cc.ui.UILabel.new({
        UILabelType = 2, text = tostring(self.allPoints), size = timeBg:getContentSize().height*3/5, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(151,171,183)})
        :align(display.CENTER,timeBg:getContentSize().width*0.5, timeBg:getContentSize().height/2)
        :addTo(scoreBg)
  print("\n\n\n\n\n\n\n\n")
  printTraceback()
end

function ExpeditionScene:initAllMember()
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
    local hpStrs = {}
    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
        self:addSpeRes()
        hpStrs = string.split(BattleData["hpPerCar"],"|")
    else

        hpStrs = string.split(BattleData["hpPerMan"],"|")
        getLaserCannonAttri({BattleData["laser1"],BattleData["laser2"],BattleData["laser3"],BattleData["laser4"]})
    end
    local lastHpStates = {}
    for i=1,#hpStrs do
       local tmp = string.split(hpStrs[i],"#")
       if tmp[1] == nil or tmp[1] == "nil" or tmp[1] == "" then
          break
       end
       lastHpStates[tonumber(tmp[1])] = {}
       lastHpStates[tonumber(tmp[1])].curHp = tonumber(tmp[2])
       lastHpStates[tonumber(tmp[1])].maxHp = tonumber(tmp[3])
    end
    -- writeTabToLog({BattleData["hpPerCar"]},"hahahahaha","aaa.txt")
    -- writeTabToLog(lastHpStates,'lastHpStates',"xxc.txt")
    -- writeTabToLog(testMemberData,'testMemberData',"ccc.txt")
    for i=1,table.getn(testMemberData) do
        local pos = testMemberData[i].pos
        print("i:",i,"pos:",pos,"\nlastHpStates:",lastHpStates)
        if self._isInit and lastHpStates[tonumber(pos)] and lastHpStates[tonumber(pos)].curHp <=0 then --第一次初始化时，血量为0不作处理
        else
          local hero = HeroAI.new(testMemberData[i],MemberPosType.attackType)
          hero:setPosition(AttackPositions[pos][1]-display.width/2, AttackPositions[pos][2])
          if tonumber(pos) == 5 then
              self:addChild(hero,15)
          else
              self:addChild(hero,BattleDisplayLevel[pos])
          end
          print("hero:"..pos.."  curHp:"..hero.m_attackInfo.curHp.."  maxHp:"..hero.m_attackInfo.maxHp)
          MemberAttackList[pos] = hero
          if lastHpStates[tonumber(pos)] ~= nil then
              MemberAttackList[pos].m_attackInfo.curHp = lastHpStates[tonumber(pos)].curHp
              MemberAttackList[pos].m_attackInfo.maxHp = lastHpStates[tonumber(pos)].maxHp
              if MemberAttackList[pos].m_attackInfo.curHp <= 0 then
                 if _isInit then
                   MemberAttackList[pos] = nil
                 else
                   MemberAttackList[pos].m_isDead = true
                   MemberAttackList[pos]:setVisible(false)
                 end
                   
              end
          end
        end
          
    end
    self:addSelfFrames()
    _isInit = false
end

function ExpeditionScene:initMontsers()
  for i=1,20 do
      AllFlyBullet[i] = nil
  end
  for i=1,20 do
      AllDropBox[i] = nil
  end
  if self.battleProgressLabel then
      self.battleProgressLabel:setString(tostring(self.curExpeditionId%10000))
  else
      self.battleProgressLabel = cc.LabelAtlas:_create()
      :addTo(self)
      self.battleProgressLabel:initWithString(":"..tostring(self.curExpeditionId%10000),
      "Battle/shuziheti_d02-04.png",
      43,
      49,
      string.byte(0))
      self.battleProgressLabel:setPosition(display.width*0.37, display.height*0.92)
      self.battleProgressLabel:scale(0.8)
  end

  BulletUseNums = {
                    [1] = 0,   --bullet1
                    [2] = 0,   --bullet2
                    [3] = 0,   --bullet3
                  }
  local addX = 0
  if self.curSupplyState == SupplyState.kSupply_In then
     addX = display.width/2
  end
  --初始化怪物数据 或者对手数据
  if tonumber(expeditionData[self.curExpeditionId]["type1"]) == 2 then
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
      for i=1,table.getn(BattleData["emembers"]) do
         local hero = HeroAI.new(BattleData["emembers"][i],MemberPosType.defenceType)
         local pos = BattleData["emembers"][i].pos
         hero:setPosition((display.width/2 - AttackPositions[pos][1]) + display.width/2 + display.width/2 + addX, AttackPositions[pos][2])
         if tonumber(pos) == 5 then
              self:addChild(hero,15)
         else
              self:addChild(hero,BattleDisplayLevel[pos])
         end
         MemberDeffenceList[pos] = hero   
      end
  else --PVE
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
      for i=1, #BattleData["monsters"] do
         if tonumber(BattleData["monsters"][i]) ~= 11011009 then
         local monster = MonsterAI.new(monsterData[tonumber(BattleData["monsters"][i])], srv_userInfo.level + MonsterLevelControl[self.curExpeditionId%10000],i,MemberPosType.defenceType)
         monster:setPosition(DefencePositions[i][1]+display.width/2+addX, DefencePositions[i][2])
         self:addChild(monster,BattleDisplayLevel[i])
         MemberDeffenceList[i] = monster
         end
      end
      --掉落分配
      for i = 1, #BattleData["rewardItems"] do
          local boxIndex = math.random(#BattleData["monsters"])
          if MemberDeffenceList[tonumber(boxIndex)] ~= nil then
             table.insert(MemberDeffenceList[tonumber(boxIndex)].m_rewards, #(MemberDeffenceList[tonumber(boxIndex)].m_rewards) + 1, BattleData["rewardItems"][i])
          end
      end
  end
  self:addEnermyFrames()
end

function ExpeditionScene:addSelfFrames()
    local function addSkillCahe(_skillId)
      display.addSpriteFrames("Battle/Skill/Skill"..tostring(_skillId)..".plist", "Battle/Skill/Skill"..tostring(_skillId)..".png")
      table.insert(EnermyFramesRecords, #EnermyFramesRecords+1,{plistStr = "Battle/Skill/Skill"..tostring(_skillId)..".plist",pngStr = "Battle/Skill/Skill"..tostring(_skillId)..".png"})
    end
    local function addBuffCahe(_buffId)
      if _buffId ~= "null" and _buffId ~= nil and tonumber(_buffId) ~= 0 then
          local resID = buffData[_buffId]["buffResId"]
          display.addSpriteFrames("Battle/Bullet/"..tostring(resID)..".plist", "Battle/Bullet/"..tostring(resID)..".png")
          table.insert(EnermyFramesRecords, #EnermyFramesRecords+1,{plistStr = "Battle/Bullet/"..tostring(resID)..".plist",pngStr = "Battle/Bullet/"..tostring(resID)..".png"})
      end
    end
    if LaserGunInfo.buffId ~= 0 then
        addBuffCahe(LaserGunInfo.buffId)
    end
    for k,v in pairs(MemberAttackList) do
      if v ~= nil then
         for sk,sv in pairs(v.m_energySkills) do
           if sv.id ~= nil and sv.id ~= 0 then
             addSkillCahe(skillData[sv.id]["resId"])
             addBuffCahe(skillData[sv.id]["buffId"])
           end
         end
      end
    end
end

function ExpeditionScene:addEnermyFrames()
   local function addSkillCahe(_skillId)
      display.addSpriteFrames("Battle/Skill/Skill"..tostring(_skillId)..".plist", "Battle/Skill/Skill"..tostring(_skillId)..".png")
      table.insert(EnermyFramesRecords, #EnermyFramesRecords+1,{plistStr = "Battle/Skill/Skill"..tostring(_skillId)..".plist",pngStr = "Battle/Skill/Skill"..tostring(_skillId)..".png"})
   end
   local function addBuffCahe(_buffId)
      if _buffId ~= "null" and _buffId ~= nil and tonumber(_buffId) ~= 0 then
          local resID = buffData[_buffId]["buffResId"]
          display.addSpriteFrames("Battle/Bullet/"..tostring(resID)..".plist", "Battle/Bullet/"..tostring(resID)..".png")
          table.insert(EnermyFramesRecords, #EnermyFramesRecords+1,{plistStr = "Battle/Bullet/"..tostring(resID)..".plist",pngStr = "Battle/Bullet/"..tostring(resID)..".png"})
      end
   end
   if tonumber(expeditionData[self.curExpeditionId]["type1"]) == 2 then
      for k,v in pairs(MemberDeffenceList) do
        if v ~= nil then
           for sk,sv in pairs(v.m_energySkills) do
             if sv.id ~= nil and sv.id ~= 0 then
               addSkillCahe(skillData[sv.id]["resId"])
               addBuffCahe(skillData[sv.id]["buffId"])
             end
           end
        end
      end
   else
      for i=1,table.getn(BattleData["monsters"]) do
         local monsterId = BattleData["monsters"][i]
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

function ExpeditionScene:addSupplyStation()
    self.supplyStation = display.newSprite("Expedition/supplyStationRight.png")
    self.supplyStation:setPosition(self.bgSceneOne:getContentSize().width - self.supplyStation:getContentSize().width/2, self.bgSceneOne:getContentSize().height*0.65)
    if self.bgSceneOne:getPositionX() == display.width or self.bgSceneOne:getPositionX() == 0 then
        self.bgSceneOne:addChild(self.supplyStation)
    elseif self.bgSceneTwo:getPositionX() == display.width or self.bgSceneTwo:getPositionX() == 0 then
        self.bgSceneTwo:addChild(self.supplyStation)
    else
        self.supplyStation = nil
        return
    end

    local allSelledSupply = {}
    
    for i=1,#BattleData["allSupply"] do
        local hasBuy = false
        allSelledSupply[i] = {id = 0, hasBuy = false}
        for j=1,#self.allSupply do
            if BattleData["allSupply"][i] == self.allSupply[j] then
               hasBuy = true
               allSelledSupply[i].id = BattleData["allSupply"][i]
               allSelledSupply[i].hasBuy = true
               break
            end
        end
        if hasBuy == false then
           allSelledSupply[i].id = BattleData["allSupply"][i]
        end
    end
    
    local function showSupplyConfirm(_sId,_hasBuy)
        if self.supplyBox ~= nil then
           self.supplyBox:removeSelf()
           self.supplyBox = nil
        end
        self.supplyBox = SupplyBuyBox.new(_sId,_hasBuy,self.allPoints,handler(self,self.supplyCallBack))
        :pos(display.width*0.5,display.height*0.5)
        :addTo(self,42)
    end

    self.supplyStation.itemUnits = {}
    local sSize = self.supplyStation:getContentSize()
    for i=1,#allSelledSupply do
        local resId = supplyData[allSelledSupply[i].id]["resId"]
        local supplyItem = cc.ui.UIPushButton.new({normal = "Expedition/"..resId..".png"})
        :addTo(self.supplyStation)
        local supplyStayEff = display.newSprite("#supplyShow_"..string.sub(resId,8,12).."_00.png")
        :addTo(self.supplyStation)
        local framesStay = display.newFrames("supplyShow_"..string.sub(resId,8,12).."_%02d.png", 0, 9)
        local animationStay = display.newAnimation(framesStay, 1/10)
        local aniActionStay = cc.RepeatForever:create(cc.Animate:create(animationStay))
        local supplyClickEff = display.newSprite("#supplyClick_"..string.sub(resId,8,12).."_00.png")
        :addTo(self.supplyStation)
        supplyItem:onButtonPressed(function()
            local framesClick = display.newFrames("supplyClick_"..string.sub(resId,8,12).."_%02d.png", 0, 16)
            local animationClick = display.newAnimation(framesClick, 1/17)
            local aniActionClick = cc.Animate:create(animationClick)
            supplyClickEff:runAction(aniActionClick)
        end)
        supplyItem:onButtonClicked(function()
            showSupplyConfirm(allSelledSupply[i].id, allSelledSupply[i].hasBuy)
        end)
        if i<= 2 then
           supplyItem:setPosition(sSize.width*(0.537 + (i-1)*0.095),sSize.height*0.48)
           supplyStayEff:setPosition(sSize.width*(0.537 + (i-1)*0.095),sSize.height*0.48)
           supplyClickEff:setPosition(sSize.width*(0.537 + (i-1)*0.095),sSize.height*0.48)
        else
           supplyItem:setPosition(sSize.width*(0.76 + (i-3)*0.095),sSize.height*0.48)
           supplyStayEff:setPosition(sSize.width*(0.76 + (i-3)*0.095),sSize.height*0.48)
           supplyClickEff:setPosition(sSize.width*(0.76 + (i-3)*0.095),sSize.height*0.48)
        end

        if allSelledSupply[i].hasBuy == false then
            supplyStayEff:runAction(aniActionStay)
        else
            supplyStayEff:setVisible(false)
            supplyItem:setTouchEnabled(false)
        end
        self.supplyStation.itemUnits[allSelledSupply[i].id] = {}
        self.supplyStation.itemUnits[allSelledSupply[i].id].item = supplyItem
        self.supplyStation.itemUnits[allSelledSupply[i].id].stayEff = supplyStayEff
    end
end

function ExpeditionScene:offSupplyStation()
    if self.supplyStation ~= nil then
       self.bgSceneOne:performWithDelay(function()
         self.supplyStation:removeSelf()
         self.supplyStation = nil
       end, 6)
    else
       return
    end
    if self.supplyBox ~= nil then
        self.supplyBox:removeSelf()
        self.supplyBox = nil
    end
    for k,v in pairs(self.supplyStation.itemUnits) do
        v.item:setTouchEnabled(false)
        v.stayEff:setVisible(false)
    end
end

function ExpeditionScene:controlSupply(_supplyId, _controlType)
    if _controlType == nil then
       return
    end
    if _supplyId == 10001 or _supplyId == 10003 then     -- 1场攻击15%
        for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.attackValue = v.m_attackInfo.attackValue*1.15
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.attackValue = v.m_attackInfo.attackValue - (v.m_attackInfo.attackValue/1.15)*0.15
              end
          end 
        end
    elseif _supplyId == 10002 or _supplyId == 10004 then  -- 1场攻击10%
        for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.attackValue = v.m_attackInfo.attackValue*1.1
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.attackValue = v.m_attackInfo.attackValue - (v.m_attackInfo.attackValue/1.1)*0.1
              end
          end 
       end
    elseif _supplyId == 10005 then -- 2场防御15%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue*1.15
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue - (v.m_attackInfo.defenceValue/1.15)*0.15
              end
          end 
       end
    elseif _supplyId == 10006 then -- 2场防御10%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue*1.1
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.defenceValue = v.m_attackInfo.defenceValue - (v.m_attackInfo.defenceValue/1.1)*0.1
              end
          end 
       end
    elseif _supplyId == 10007 then -- 2场命中20%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.hitValue = v.m_attackInfo.hitValue + 200
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.hitValue = v.m_attackInfo.hitValue - 200
              end
          end 
       end
    elseif _supplyId == 10008 then -- 2场闪避20%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.dodgeValue = v.m_attackInfo.dodgeValue + 200
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.dodgeValue = v.m_attackInfo.dodgeValue - 200
              end
          end 
       end
    elseif _supplyId == 10009 then -- 2场暴击10%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.critValue = v.m_attackInfo.critValue + 100
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.critValue = v.m_attackInfo.critValue - 100
              end
          end 
       end
    elseif _supplyId == 10010 then -- 2场暴击5%
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead ~= true then
              if _controlType == ControlSupplyType.kSupplyControl_Effect then
                 v.m_attackInfo.critValue = v.m_attackInfo.critValue + 50
              elseif _controlType == ControlSupplyType.kSupplyControl_UnEffect then
                 v.m_attackInfo.critValue = v.m_attackInfo.critValue - 50
              end
          end 
       end
    elseif _supplyId == 10011 or _supplyId == 10014 then -- 1场血量恢复10%
       if _controlType == ControlSupplyType.kSupplyControl_Effect then
          for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead ~= true then
                  v.m_attackInfo.curHp = v.m_attackInfo.curHp + math.floor(v.m_attackInfo.maxHp*0.1)
                  if v.m_attackInfo.curHp > v.m_attackInfo.maxHp then
                      v.m_attackInfo.curHp = v.m_attackInfo.maxHp
                  end
              end 
          end
          for k,v in pairs(self.allControlDesk) do
              if v~= nil and v.energyProgress ~= nil then
                v:refreshHpProgress()
              end
          end
       end
    elseif _supplyId == 10012 or _supplyId == 10015 then -- 1场血量恢复20%
       if _controlType == ControlSupplyType.kSupplyControl_Effect then
          for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead ~= true then
                  v.m_attackInfo.curHp = v.m_attackInfo.curHp + math.floor(v.m_attackInfo.maxHp*0.2)
                  if v.m_attackInfo.curHp > v.m_attackInfo.maxHp then
                      v.m_attackInfo.curHp = v.m_attackInfo.maxHp
                  end
              end 
          end
          for k,v in pairs(self.allControlDesk) do
              if v~= nil and v.energyProgress ~= nil then
                v:refreshHpProgress()
              end
          end
       end
    elseif _supplyId == 10013 or _supplyId == 10016 then -- 1场血量恢复50%
       if _controlType == ControlSupplyType.kSupplyControl_Effect then
          for k,v in pairs(MemberAttackList) do
              if v ~= nil and v.m_isDead ~= true then
                  v.m_attackInfo.curHp = v.m_attackInfo.curHp + math.floor(v.m_attackInfo.maxHp*0.5)
                  if v.m_attackInfo.curHp > v.m_attackInfo.maxHp then
                      v.m_attackInfo.curHp = v.m_attackInfo.maxHp
                  end
              end 
          end
          for k,v in pairs(self.allControlDesk) do
              if v~= nil and v.energyProgress ~= nil then
                v:refreshHpProgress()
              end
          end
       end
    elseif _supplyId == 10017 or _supplyId == 10020 then -- 能量恢复10%
       for k,v in pairs(self.allControlDesk) do
            if v ~= nil and v.energyProgress ~= nil and _controlType == ControlSupplyType.kSupplyControl_Effect then
                local newEnergy =v.energyProgress:getPercentage() + 10
                if newEnergy > 100 then
                   newEnergy = 100
                end 
                v:setEnergyProgress(math.floor(newEnergy))
            end
       end
    elseif _supplyId == 10018 or _supplyId == 10021 then -- 能量恢复20%
       for k,v in pairs(self.allControlDesk) do
            if v ~= nil and v.energyProgress ~= nil and _controlType == ControlSupplyType.kSupplyControl_Effect then
                local newEnergy = v.energyProgress:getPercentage() + 20
                if newEnergy > 100 then
                   newEnergy = 100
                end 
                v:setEnergyProgress(math.floor(newEnergy))
            end
       end
    elseif _supplyId == 10019 or _supplyId == 10022 then -- 能量恢复40%
       for k,v in pairs(self.allControlDesk) do
            if v ~= nil and v.energyProgress ~= nil and _controlType == ControlSupplyType.kSupplyControl_Effect then
                local newEnergy = v.energyProgress:getPercentage() + 40
                if newEnergy > 100 then
                   newEnergy = 100
                end 
                v:setEnergyProgress(math.floor(newEnergy))
            end
       end
    else
       print("Uknow Suplly")
    end

    --添加左上Icon
    if _controlType == ControlSupplyType.kSupplyControl_Effect then
       if _supplyId == 10002 or _supplyId == 10003 or _supplyId == 10004 then
          _supplyId = 10001
       end
       if _supplyId == 10006 then
          _supplyId = 10005
       end
       if _supplyId == 10010 then
          _supplyId = 10009
       end
       if _supplyId == 10012 or _supplyId == 10013 or _supplyId == 10014 or _supplyId == 10015 or _supplyId == 10016 then
          _supplyId = 10011
       end
       if _supplyId == 10018 or _supplyId == 10019 or _supplyId == 10020 or _supplyId == 10021 or _supplyId == 10022 then
          _supplyId = 10017
       end
       local index = #self.allSupplyIcon
       local supplyIcon = display.newSprite("#supplyIcon"..tostring(_supplyId).."_00.png")
       :addTo(self)
       supplyIcon:setPosition( supplyIcon:getContentSize().width*(0.5 + index*0.6), display.height - display.height*0.2)
       local framesIcon = display.newFrames("supplyIcon"..tostring(_supplyId).."_%02d.png", 0, 11)
       local animationIcon = display.newAnimation(framesIcon, 1/12)
       local aniActionIcon = cc.RepeatForever:create(cc.Animate:create(animationIcon))
       supplyIcon:runAction(aniActionIcon)
       self.allSupplyIcon[index + 1] = supplyIcon
    end
    
end

function ExpeditionScene:supplyCallBack(_event)
    if _event.callType == SupplyCallType.Supply_OK then
        if self.supplyBox ~= nil then
            self.supplyBox:removeSelf()
            self.supplyBox = nil
        end
        if _event.usePoint ~= 0 then
            self.allPoints = self.allPoints - _event.usePoint
            self.scoreLabel:setString(tostring(self.allPoints))
        elseif _event.useDiamond ~= 0 then
            srv_userInfo.diamond = srv_userInfo.diamond - _event.useDiamond
        end
        local hasSameSupply = false
        for i=1,#BattleData["supply"] do
            if tonumber(BattleData["supply"][i]) == tonumber(_event.sId) then
                hasSameSupply = true
            end
        end
        if hasSameSupply == false then
           table.insert(BattleData["supply"],#BattleData["supply"]+1,_event.sId)
        end
        self:controlSupply(tonumber(_event.sId), ControlSupplyType.kSupplyControl_Effect)
        self.supplyStation.itemUnits[tonumber(_event.sId)].item:setTouchEnabled(false)
        self.supplyStation.itemUnits[tonumber(_event.sId)].stayEff:setVisible(false)
    elseif _event.callType == SupplyCallType.Supply_Cancel then
        if self.supplyBox ~= nil then
           self.supplyBox:removeSelf()
           self.supplyBox = nil
        end
    else 
        print("Supply: wrong call type!")  
    end
end
--加载操作框
function ExpeditionScene:addControlDesk()
    for k,v in pairs(self.allControlDesk) do
       v:removeSelf()
       v = nil
    end
    self.allControlDesk = {}
    g_allControlDesk = {}
    local enStrs = {}
    local enStrsTmp = {}
    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
        enStrsTmp = string.split(BattleData["ePerCar"],"|")
    else
        enStrsTmp = string.split(BattleData["ePerMan"],"|")
    end
    for i=1,#enStrsTmp do
        if enStrsTmp[i] == "" then
            break
        end
        local tmp = string.split(enStrsTmp[i],"#")
        enStrs[tonumber(tmp[1])] = tonumber(tmp[2])
    end
    g_allControlDesk = {}
    printTable(MemberAttackList)
    -- writeTabToLog(MemberAttackList)
    for k,v in pairs(MemberAttackList) do
        if v.m_memberType == MemberAllType.kMemberTankWithHero or v.m_memberType == MemberAllType.kMemberHero then
            local tempDesk = ControlDesk.new(v)
                :addTo(self,25)
            self.allControlDesk[v.fightPos] = tempDesk
            self.allControlDesk[v.fightPos].mType = v.m_memberType
            g_allControlDesk[v.fightPos] = tempDesk
            if enStrs[v.fightPos] ~= nil and enStrs[v.fightPos] ~= "nil" and enStrs[v.fightPos] ~= "" then
                if tonumber(enStrs[v.fightPos]) == -1 then
                    self.allControlDesk[v.fightPos]:cleanDesk()
                else
                    self.allControlDesk[v.fightPos]:setEnergyProgress(tonumber(enStrs[v.fightPos]))
                end
            end 
            if v.m_isDead == true then 
                self.allControlDesk[v.fightPos]:cleanDesk()
            end
        end
    end
    self:resetControlDesk()
end

function ExpeditionScene:resetControlDesk()
    local  controlNum = 0
    
    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
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

function ExpeditionScene:sebltCallBack(_event)
    if _event.callType == SpriteProgressCallType.kCall_Click then
        self:chooseSeBullet(_event.callId)
    elseif _event.callType == SpriteProgressCallType.kCall_Ready then

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
    else
        print("sebltCallBack Error")
    end
end

function ExpeditionScene:addSeblts()
    -- writeTabToLog(BattleData,"从服务端获取的远征战场信息","z001.txt")
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
                     BulleHasNums[i].num = BulleHasNums[i].num - 1
                     BulletUseNums[i] = BulletUseNums[i] + 1
                     break
                  end
                end
                self:showSeblt({x = event.x, y = event.y},useSeId)
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
       local bulletid = BattleData[string.format("bullet%d",i)]
       if bulletid > -1 then
            if BulleHasNums[i] == nil then
                BulleHasNums[i] = {id = 0, num = 0}
                for j = 1, #BattleData["seBlts"] do
                    if BattleData["seBlts"][j]["id"] == bulletid then
                        if BattleData["seBlts"][j]["count"] ~= 0 and tonumber(BattleData["seBlts"][j]["templateId"]) ~= 1075007 and tonumber(BattleData["seBlts"][j]["templateId"]) ~= 1075009 then                        
                              BulleHasNums[i] = {id = BattleData["seBlts"][j]["templateId"], num = BattleData["seBlts"][j]["count"]}
                        end
                        break
                    end
                end
            end
       end
    end
    self.seBg = display.newSprite("Battle/battleImg_22.png")
    :pos(display.width*0.78,display.height*0.08)
    :addTo(self,25)
    local seBgSize = self.seBg:getContentSize()
    for i=1,3 do
       display.newSprite("Battle/battleImg_21.png")
       :pos(seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.5)
       :addTo(self.seBg)
       if BulleHasNums[i] == nil then
          display.newSprite("Battle/battleImg_23.png")
          :pos(seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.5)
          :addTo(self.seBg)
       elseif BulleHasNums[i] ~= nil and BulleHasNums[i].id ~= 0 and  BulleHasNums[i].num > 0 then
          local sProgress = SpriteProgress.new("Battle/battleSeblt_"..BulleHasNums[i].id, itemData[BulleHasNums[i].id]["sklCD"], BulleHasNums[i].id,handler(self,self.sebltCallBack),BulleHasNums[i].num)
          :align(display.CENTER_BOTTOM,seBgSize.width*(0.2+(i-1)*0.3),seBgSize.height*0.15)
          :addTo(self.seBg)
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

function ExpeditionScene:chooseSeBullet(_seId)
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

function ExpeditionScene:showSeblt(_targetPos,_useSeId)
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

function ExpeditionScene:changeFightMember()
    for k,v in pairs(MemberAttackList) do
        v:removeSelf()
    end
    self:addControlUnit()
    self.curFightType = self.curBlockType
end

function ExpeditionScene:checkIsAllReady()
    for k,v in pairs(MemberAttackList) do
       if v ~= nil  and  v.m_isReady == false then
          return
       end
    end
    self:begainFight()
end

function ExpeditionScene:begainFight()
    --补给站情况
    if self.curSupplyState == SupplyState.kSupply_In then
       self:pause()
       self.nextItem:setVisible(true)
       for k,v in pairs(MemberAttackList) do
          if v ~= nil and v.m_isDead == false then
             v:doEvent("goWin")
          end
       end
       return
    end
    self.timeLabel:setString("03:00")
    BattleSurplusTime = 180
    --战斗人员切换情况
    if self.curFightType ~= self.curBlockType then
       self:changeFightMember()
       return
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
           if v:getPercent() <= 0 then
              v.okStaySp:setVisible(true)
           end
        end
    end
    LaserGunAI:resumeLaserGun()
end

function ExpeditionScene:afterAllMonsterDie()
    -- IsAllMonsterDead = true
    if IsAllMonsterDead == false then
      IsAllMonsterDead = true --在begainFight()中重置
    else
      return --防止怪物同时挂掉处理多次
    end    
    self.skillLayer:setVisible(false)
    skillResumeMembers()

    --暂停技能和战斗计时
    self:pause()--计时和军号
    for k,v in pairs(self.allControlDesk) do--技能
       if v.energyProgress ~= nil then
          v:pauseDesk()
       end
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
         if v.m_isDead == false then
           v:clearBuff()
         end
    end
    
    --移除加成
    for k,v in pairs(self.allSupply) do
      self:controlSupply(tonumber(v), ControlSupplyType.kSupplyControl_UnEffect)
    end
    for k,v in pairs(self.allSupplyIcon) do
        v:removeSelf()
    end
    self.allSupplyIcon = {}

    
    
    CurBattleStep = CurBattleStep + 1
    
    local sendData = {}
    sendData["win"] = 1
    local hpStr = ""
    for k,v in pairs(MemberAttackList) do
        if v ~= nil then
           if hpStr ~= "" then
              hpStr = hpStr.."|"
           end
           hpStr = hpStr..v.fightPos.."#"..v.m_attackInfo.curHp.."#"..v.m_attackInfo.maxHp
        end
    end
    local enStr = ""
    for k,v in pairs(self.allControlDesk) do
        if enStr ~= "" then
            enStr = enStr.."|"
        end
        enStr = enStr..tostring(k).."#"
        if v.energyProgress == nil then
            enStr = enStr.."-1"
        else
            enStr = enStr..v.energyProgress:getPercentage()
        end
    end

    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
       sendData["hpPerCar"] = hpStr
       sendData["ePerCar"] = enStr
    else
       sendData["hpPerMan"] = hpStr
       sendData["ePerMan"] = enStr
    end
    sendData["star"] = BattleStar
    sendData["sec"]  = 180 - BattleSurplusTime
    for i,v in ipairs(BulletUseNums) do
      if v > 0 then
        sendData[string.format("bullet%d", i)] = v
      end
    end
    if BattleData["fIndex"] ~= nil then
        sendData["fIndex"] = BattleData["fIndex"]
    end
    m_socket:SendRequest(json.encode(sendData), CMD_UPDATE_EXPEDITION, self, self.afterGetNextInfo)

    --清除资源缓存
    for i,v in ipairs(EnermyFramesRecords) do
        display.removeSpriteFramesWithFile(v.plstStr, v.pngStr)
    end
end

function ExpeditionScene:afterOneHeroDie(_hero)
    if _hero.m_posType == MemberPosType.defenceType then
       return
    end
    if self.allControlDesk[_hero.fightPos] ~= nil then
        self.allControlDesk[_hero.fightPos]:cleanDesk()
    end
    
    --星级
    if BattleStar > 1 then
       BattleStar = BattleStar - 1
    end
end

function ExpeditionScene:expeditionOver()
    local sendData = {}
    sendData["win"] = 0
    for i,v in ipairs(BulletUseNums) do
      if v > 0 then
        sendData[string.format("bullet%d", i)] = v
      end
    end
    if BattleData["fIndex"] ~= nil then
        sendData["fIndex"] = BattleData["fIndex"]
    end
    m_socket:SendRequest(json.encode(sendData), CMD_UPDATE_EXPEDITION, self, self.afterGetOverInfo)
end

function ExpeditionScene:afterAllHeroDie()
    self.skillLayer:setVisible(false)
    for k,v in pairs(MemberAttackList) do--技能
       if v ~= nil and v.m_isDead == false then
           v:doEvent("goWin")
       end
    end
    for k,v in pairs(self.allControlDesk) do--技能
       if v.energyProgress ~= nil then
          v:pauseDesk()
       end
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
    for k,v in pairs(MemberDeffenceList) do--技能
        if v ~= nil and v.m_isDead == false and v.m_fsm:getState() ~= "win" then
           v:stopAction(v.m_moveAction)
           v:doEvent("goWin")
        end
    end
    self:pause()
    
    if self.reviveCnt >= 3 then
        self:expeditionOver()
    else
        if srv_userInfo.diamond >= reviveCost[self.reviveCnt + 1] then
            showMessageBox("是否花费"..tostring(reviveCost[self.reviveCnt + 1]).."钻石满血复活？",function ()
              DCEvent.onEvent("远征复活")
              self:sendRevive()
            end,handler(self,self.expeditionOver))
        else
            self:expeditionOver()
        end
    end
end

function ExpeditionScene:sendRevive()
    local sendData = {}
    local hpStr = ""
    local enStr = ""
    for k,v in pairs(MemberAttackList) do
        if v ~= nil then
           if hpStr ~= "" then
              hpStr = hpStr.."|"
           end
           hpStr = hpStr..v.fightPos.."#"..v.m_attackInfo.maxHp.."#"..v.m_attackInfo.maxHp
        end
    end
    for k,v in pairs(self.allControlDesk) do
        if enStr ~= "" then
              enStr = enStr.."|"
        end
        enStr = enStr..tostring(k).."#".."50"
    end
    if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
       sendData["hpPerCar"] = hpStr
       sendData["ePerCar"] = enStr
    else
       sendData["hpPerMan"] = hpStr
       sendData["ePerMan"] = enStr
    end
    m_socket:SendRequest(json.encode(sendData), CMD_EXPEDITION_REVIVE, self, self.afterGetRevive)
end

function ExpeditionScene:afterGetRevive(cmd)

    if cmd.result == 1 then
      local enStr = ""
      self.reviveCnt = self.reviveCnt + 1
      srv_userInfo.diamond = srv_userInfo.diamond - reviveCost[self.reviveCnt]
      for k,v in pairs(self.allControlDesk) do
          if enStr ~= "" then
              enStr = enStr.."|"
          end
          enStr = enStr..tostring(k).."#".."50"
      end
      if self.curBlockType == ExpeditionBlockType.kExpeditionBlock_Tank then
          BattleData["ePerCar"] = enStr
          BattleData["hpPerCar"] = ""
      else
          BattleData["ePerMan"] = enStr
          BattleData["hpPerMan"] = ""
      end
      self:changeFightMember()
      for k,v in pairs(MemberDeffenceList) do
          if v ~= nil and v.m_isDead ~= true then
              v.m_targetIndex = 1
          end
      end
    else
       showTips(cmd.msg)
       self.expeditionOver()
    end
end

function ExpeditionScene:afterGetOverInfo(cmd)
    srv_userInfo.gold = srv_userInfo.gold + self.allGold
    srv_userInfo["expedition"] = cmd.data.expedition
    PVPResult = false
    PvpResultLayer.new()
    :pos(0, 0)
    :addTo(self,60)

    g_expeditionRewards = self.allRewardItems
    if #g_expeditionRewards > 0 then
       g_expeditionDialogIndex = 2
    else
       g_expeditionDialogIndex = 3
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
end

--进入下一个小关
function ExpeditionScene:nextButtonClicked()
    self.IsFirstIn = false
    GuideManager:removeGuideLayer()
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
    --移除怪物的尸体 
    for k,v in pairs(MemberDeffenceList) do
      if(v ~= nil and v.m_isRemoved == false) then
          if v.m_memberType == MemberAllType.kMemberMonster then
            v:removeSelf()  
          else
            v:setVisible(false)
          end
      end
    end
    --移除补给站
    self:offSupplyStation()

    self.curExpeditionId = tonumber(BattleData["nId"])
    self.curBlockType = expeditionData[self.curExpeditionId]["type2"]
    self.allSupply = BattleData["supply"]

    for k,v in pairs(self.allSupply) do
      self:controlSupply(tonumber(v), ControlSupplyType.kSupplyControl_UnEffect)
    end
    for k,v in pairs(self.allSupplyIcon) do
        v:removeSelf()
    end
    self.allSupplyIcon = {}
    --添加加成
    for k,v in pairs(self.allSupply) do
       self:controlSupply(tonumber(v), ControlSupplyType.kSupplyControl_Effect)
    end

    local function heroMove()
        --成员移动
        for k,v in pairs(MemberAttackList) do
           if v ~= nil  and  v.m_isDead == false then
              v:doEvent("goReady")
           end
        end
    end
    --补给站
    local bgMoveDistance = 0
    local moveTime = StartMoveTime
    print("self.curExpeditionId:"..self.curExpeditionId)
    print("self.curSupplyState:"..self.curSupplyState)
    if self.curExpeditionId == 10006 or self.curExpeditionId == 10011 or self.curExpeditionId == 10016 then
        if self.curSupplyState == SupplyState.kSupply_Out then
           self:addSupplyStation()
           self.curSupplyState = SupplyState.kSupply_In
           heroMove()
        elseif self.curSupplyState == SupplyState.kSupply_In then
           self:initMontsers()
           heroMove()
           self.curSupplyState = SupplyState.kSupply_Out
        end
        bgMoveDistance = cc.p(-display.width,0)
        moveTime = StartMoveTime*2
    else
        self:initMontsers()
        bgMoveDistance = cc.p(-display.width/2,0)
        heroMove()
    end

    local function resetBgPos()
       if self.bgSceneOne:getPositionX() <= -display.width then
          self.bgSceneOne:setPosition(display.width*3,display.cy)
       end
       if self.bgSceneTwo:getPositionX() <= -display.width then
          self.bgSceneTwo:setPosition(display.width*3,display.cy)
       end
    end
    self.bgSceneOne:runAction(cc.MoveBy:create(moveTime*StartSpeedAdd, bgMoveDistance))
    self.bgSceneTwo:runAction(transition.sequence({
        cc.MoveBy:create(moveTime*StartSpeedAdd, bgMoveDistance),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(resetBgPos),
    }))
end

function ExpeditionScene:afterGetNextInfo(_result)
    if _result.result == 1 then
        local oldBattleData = BattleData --保存当前小节的数据，该接口返回的为下一节的数据
        BattleData = _result.data
        --writeTabToLog(_result.data,"打完当前小节，进入"..tostring(self.curExpeditionId%10000).."小节","cao.txt")
        

        self.allGold = self.allGold + tonumber(BattleData["gold"])
        self.goldLabel:setString(tostring(self.allGold))
        DCCoin.gain("远征掉落","金币",BattleData["gold"],srv_userInfo.gold+BattleData["gold"])
        for k,v in pairs(BattleData["rewardItems"]) do
            table.insert(self.allRewardItems,#self.allRewardItems + 1,v)
        end
        print("---jevon--------------")
        printTable(self.allRewardItems)
        print("当前箱子个数："..tostring(#self.allRewardItems))
        --第一节结算的时候加上（因为服务端都是结算的时候才传掉落物品），或者对手是玩家的时候加上箱子数
        if self.curExpeditionId==10001 or (oldBattleData["monsters"] and #oldBattleData["monsters"]==0) then  
          print("对手是玩家关卡，结算的时候刷新箱子数")
          self.boxLabel:setString(tostring(#self.allRewardItems))
        end
        

        self.allPoints = self.allPoints + tonumber(BattleData["point"])

        self.scoreLabel:setString(tostring(self.allPoints))
        --下一段
        self.nextItem:setVisible(true)
    elseif _result.result == 2 then
        showTips(_result.msg)
        PVPResult = false
        PvpResultLayer.new()
        :pos(0, 0)
        :addTo(self,60)

        g_expeditionRewards = self.allRewardItems
        if #g_expeditionRewards > 0 then
           g_expeditionDialogIndex = 2
        else
           g_expeditionDialogIndex = 3
        end
    else
        showTips(_result.msg)
    end
    
end

--战斗时间控制
function  ExpeditionScene:controlFightTime()
    BattleSurplusTime  = BattleSurplusTime - 1
    if BattleSurplusTime < 0 then
      return
    end
    if BattleSurplusTime <= 0 then
      --被击败
      print("时间到 游戏失败")
      self.timeLabel:setString("00:00")
      IsOverTime = true
      self:afterAllHeroDie()
      return
    else
      local mStr = string.format("%02d", math.floor(BattleSurplusTime/60))
      local sStr = string.format("%02d", math.floor(BattleSurplusTime%60))
      self.timeLabel:setString(mStr..":"..sStr)
    end
end

function ExpeditionScene:GetResNum()
  local num = 10
  if CurFightBattleType ~= FightBattleType.kType_PVP then
    for i = 1,3 do
       local bulletid = BattleData[string.format("bullet%d",i)]
       if bulletid > -1 then
           for j = 1, #BattleData["seBlts"] do
               if BattleData["seBlts"][j]["id"] == bulletid then
                   num = num + 1
                   if tonumber(BattleData["seBlts"][j]["templateId"]) ~= 1095001 then
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

function ExpeditionScene:LoadResAsync()
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
  --加载补给站特效
  display.addSpriteFrames("Expedition/SupplyItemEff.plist", "Expedition/SupplyItemEff.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Expedition/SupplyItemEff.plist",pngStr = "Expedition/SupplyItemEff.png"})
  display.addSpriteFrames("Expedition/SupplyIconEff.plist", "Expedition/SupplyIconEff.png", handler(instance, instance.ImgDataLoaded))
  table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Expedition/SupplyIconEff.plist",pngStr = "Expedition/SupplyIconEff.png"})
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
       local bulletid = BattleData[string.format("bullet%d",i)]
       if bulletid > -1 then
           for j = 1, #BattleData["seBlts"] do
               if BattleData["seBlts"][j]["id"] == bulletid then
                   local seTptId = BattleData["seBlts"][j]["templateId"]
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
end

function ExpeditionScene:addSpeRes()
  for i = 1,3 do
      local bulletid = BattleData[string.format("bullet%d",i)]
      if bulletid > -1 then
          for j = 1, #BattleData["seBlts"] do
              if BattleData["seBlts"][j]["id"] == bulletid then
                  local seTptId = BattleData["seBlts"][j]["templateId"]
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

function ExpeditionScene:onExit()
  LaserGunAI:setItemNil()
  --清除资源缓存
  for i,v in ipairs(AllAddedFramesCahe) do
      display.removeSpriteFramesWithFile(v.plstStr, v.pngStr)
  end

end

return ExpeditionScene