--
-- Author: liufei
-- Date: 2015-03-05 11:53:03
--
require("app.battle.BattleInfo")
require("app.battle.battleAI.ExclusivesAI")
local BufferAI = require("app.battle.battleAI.BufferAI")
local Progress = require("app.battle.battleUI.HpProgress")
local HurtNumber = require("app.battle.battleUI.HurtNumber")
local TalkNode = require("app.battle.battleUI.TalkNode")

 local MemberMonster = class("MemberMonster", function ()
 	  return display.newNode()
 end)

function MemberMonster:ctor(_monster,_level)
    self:initAllAttribute(_monster,_level)
	--设置精灵
    print("_monster.tptId",_monster["id"])
    print("monsterData[_monster.id]",monsterData[_monster.id])
    self.makeType = monsterData[_monster.id]["actType"] or ModelMakeType.kMake_Coco
    local resName = monsterData[tonumber(_monster["id"])]["resId"]
    if self.makeType == ModelMakeType.kMake_Coco then
        local manager = ccs.ArmatureDataManager:getInstance()
        manager:removeArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        manager:addArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        self.m_member = ccs.Armature:create("Monster_"..resName.."_")
        self:addChild(self.m_member)
    else
        local typeName = "Monster"
        self.m_member = sp.SkeletonAnimation:create("Battle/"..typeName.."/"..typeName.."_"..resName.."_.json","Battle/"..typeName.."/"..typeName.."_"..resName.."_.atlas",1)
        self:addChild(self.m_member)
    end
    
    self.m_bulletStr = _monster["bltResId"]
    self.m_bulletResNum = _monster["bltResNum"]
    if self.m_bulletResNum > 1 then
        display.addSpriteFrames("Battle/Bullet/"..self.m_bulletStr..".plist", "Battle/Bullet/"..self.m_bulletStr..".png")
        table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..self.m_bulletStr..".plist",pngStr = "Battle/Bullet/"..self.m_bulletStr..".png"})
    end

    --是否有技能受击
    if tonumber(monsterData[tonumber(self.m_attackInfo.tptId)]["sklBlow"]) == 1 then
        self.hasSkillHit = true
    else
        self.hasSkillHit = false
    end
    
    self.memberSize = self.m_member:getContentSize()
    --血条
    self.progress = Progress.new("Battle/xxxttu_d02-06.png", "Battle/xxxttu_d02-07.png")
    self.progress:setPosition(0, HpProgressHeight*tonumber(monsterData[self.m_attackInfo.tptId]["hppos"])*FightPosScale[self.fightPos]*BlockTypeScale)
    self.progress:setScaleX(1.2*BlockTypeScale)
    self.progress:setScaleY(1.3*BlockTypeScale)
    self.progress:setVisible(false)
    self:addChild(self.progress)
    --buffs
    self.buffShowing = {}
    
    self.m_scaleNum = monsterData[tonumber(self.m_attackInfo.tptId)]["scale"]
    --根据距离远近再次缩放
    self.m_scaleNum = FightPosScale[self.fightPos]*self.m_scaleNum
    --分辨率调整再次缩放
    self.m_scaleNum = BattleScaleValue*self.m_scaleNum*BlockTypeScale
    
    self.m_member:scale(self.m_scaleNum)

    --对话框
    self.m_talkNode = TalkNode.new()
    :align(display.BOTTOM_CENTER,0, self.progress:getPositionY() + display.width*0.04)
    :addTo(self)

    --加载弹道等资源
    self.curMonsterData = _monster
    self.m_attackEffectName = _monster["atkResId"]
    display.addSpriteFrames("Battle/Skill/"..self.m_attackEffectName..".plist", "Battle/Skill/"..self.m_attackEffectName..".png")
    table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/"..self.m_attackEffectName..".plist",pngStr = "Battle/Skill/"..self.m_attackEffectName..".png"})
    
    --受击点偏移量
    self.hitOffsetX = 0
    self.hitOffsetY = 0

    --魅惑击晕值
    self.m_stunNum = 0
    --沉默值
    self.m_gagNum = 0
    
    --BUFF
    self.buffControl = BufferAI.new()
    :addTo(self)

    --怪物类型
    self.m_monsterType = tonumber(monsterData[self.m_attackInfo.tptId]["type1"])

    --伤害吸收护盾
    self.m_allShields = {}

    --机械师变黑
    if tonumber(_monster["id"]) == 11015001 then
        self.m_member:setColor(cc.c3b(0,0,0))
    end
    --机械怪冒烟
    if self.m_monsterType == 2 then --机械怪
        local frames1 = display.newFrames("SmokeFrames_%02d.png", 0, 25)
        local animation1 = display.newAnimation(frames1, 1.5/25)
        local aniAction1 = cc.RepeatForever:create(cc.Animate:create(animation1))
        self.smokeEff = display.newSprite("#SmokeFrames_00.png")
        :align(display.CENTER_BOTTOM, self.progress:getPositionX(), self.progress:getPositionY()/18)
        :addTo(self)
        self.smokeEff:scale(3*BlockTypeScale)
        self.smokeEff:runAction(aniAction1)
        self.smokeEff:setVisible(false)
    end
end

function  MemberMonster:initAllAttribute(_monster,_level)  
   --战斗需要的属性
   --普通攻击相关

    self.m_attackInfo = {
      attackValue = (_monster["attack"] + _monster["atkGF"]*(_level-1))*(_level/49 + 1),  --攻击力
      maxHp = math.floor((_monster["hp"] + _monster["hpGF"]*(_level-1))*(math.floor(_level/11 + 1)/2)), --最大生命值
      curHp = math.floor((_monster["hp"] + _monster["hpGF"]*(_level-1))*(math.floor(_level/11 + 1)/2)), --当前生命
      defenceValue = _monster["defense"] + _monster["defGF"]*(_level-1), --防御力
      critValue = _monster["cri"] + _monster["criGF"]*(_level-1), -- 暴击 
      hitValue = _monster["hit"] + _monster["hitGF"]*(_level-1), -- 命中
      dodgeValue = _monster["miss"] + _monster["missGF"]*(_level-1), --闪避
      attackInterval = _monster["atkInt"], --攻击间隔
      attackRect = _monster["atkDis"], --攻击距离
      tptId = tonumber(_monster["id"]),
      tptName = _monster["name"], --模板名字
      level = _level,
      posType = self.m_posType,
      mainCD = 0,
    }

    --初始化随机数种子数组
    -- self.m_startSeed = tonumber(tostring(os.time()):reverse():sub(1,6))
    -- self.m_randSeedPool = {}
    -- math.randomseed(self.m_startSeed)
    -- for i=1,800 do --800个种子
    --     self.m_randSeedPool[i] = math.random(10000)
    -- end
    -- self.m_seedIndex = 1

    self.m_attackType = _monster["atkTyp"]

    --技能相关
    self.m_energySkills = {}
    if _monster["sklId1"] ~= "null" and  tonumber(_monster["sklId1"]) ~= 0 then
        self.m_energySkills[MemberSkillType.kSkillMonsterOne] = {id = 0, energy = 0, pos = "", bef = 0}
        self.m_energySkills[MemberSkillType.kSkillMonsterOne].id = tonumber(_monster["sklId1"])
        self.m_energySkills[MemberSkillType.kSkillMonsterOne].energy = tonumber(skillData[tonumber(_monster["sklId1"])]["sklCD"])
        self.m_energySkills[MemberSkillType.kSkillMonsterOne].pos = _monster["sklbslpos1"]
        self.m_energySkills[MemberSkillType.kSkillMonsterOne].bef = tonumber(_monster["befSkl1"])

    end
    if _monster["sklId2"] ~= "null" and  tonumber(_monster["sklId2"]) ~= 0 then
        self.m_energySkills[MemberSkillType.kSkillMonsterTwo] = {id = 0, energy = 0, pos = "", bef = 0}
        self.m_energySkills[MemberSkillType.kSkillMonsterTwo].id = tonumber(_monster["sklId2"])
        self.m_energySkills[MemberSkillType.kSkillMonsterTwo].energy = tonumber(skillData[tonumber(_monster["sklId2"])]["sklCD"])
        self.m_energySkills[MemberSkillType.kSkillMonsterTwo].pos = _monster["sklbslpos2"]
        self.m_energySkills[MemberSkillType.kSkillMonsterTwo].bef = tonumber(_monster["befSkl2"])
    end

    --准备技能音效
    for k,v in pairs(self.m_energySkills) do
        if tonumber(skillData[v.id]["sklsoundres"]) ~= 0 then
            audio.preloadSound("audio/musicEffect/skillEffect/"..skillData[v.id]["sklsoundres"]..".mp3")
        end
    end
    
    --逻辑相关
    self.m_memberType = MemberAllType.kMemberMonster
    self.m_isDead = false

    --能量回复
    self.m_energyRecovery = 3

    --施法前摇
    self.m_befSkill = _monster["befCas"]
    --攻击前摇
    self.m_befAttack = _monster["befAtk"]
    --子弹出发相对位置
    self.m_bltPos = _monster["balPos"]

    --掉落
    self.m_rewards = {}

    print("self.m_attackInfo.curHp:  "..self.m_attackInfo.curHp)
    print("self.m_attackInfo.maxHp:  "..self.m_attackInfo.maxHp)

    -- if self.m_attackInfo.tptId == 21014002 then
    --     self.m_attackInfo.curHp = 50000000
    --     self.m_attackInfo.maxHp = 50000000
    -- end
    -- if self.m_attackInfo.tptId == 11013007 then
    --     self.m_attackInfo.curHp = 800000000
    --     self.m_attackInfo.maxHp = 800000000
    -- end
end

function MemberMonster:getHitPosition()
    return {x = self:getPositionX() + self.hitOffsetX, y =self:getPositionY() + self.progress:getPositionY()*0.42 + self.hitOffsetY}
end

 function MemberMonster:playMonsterAnimation(_animation)
    if self.makeType == ModelMakeType.kMake_Coco then
        if _animation == "" or  _animation == "" then
            self.m_member:getAnimation():play(_animation,-1,0)
        else
            self.m_member:getAnimation():play(_animation)
        end
        --flash动画强行从0帧开始播放
        self.m_member:getAnimation():gotoAndPlay(0)
    else
        self.m_member:setToSetupPose()
        local ret = nil
        if _animation == "walk" or _animation == "Standby" then
            ret = self.m_member:setAnimation(0, _animation, true)
        else
            ret = self.m_member:setAnimation(0, _animation, false)
        end
    end
 end

 function MemberMonster:getAttackInfo()
     return self.m_attackInfo
 end

 function MemberMonster:CalculateBeAttacked(_attackerInfo)
     --计算最终伤害
     --是否命中
     if isTrigger(_attackerInfo.hitValue + 1000 - self.m_attackInfo.dodgeValue, 1000, self:getRandomSeed()) == false then
        self:LiquidateDamage(0, false)
        return 0
     end
     --伤害
     local damageValue = (_attackerInfo.attackValue - self.m_attackInfo.defenceValue)*damageRandom(self:getRandomSeed())
     --是否暴击
     local isCrit = false
     if isTrigger(_attackerInfo.critValue,1000, self:getRandomSeed()) == true then
        isCrit = true
        damageValue = damageValue*1.5
     end
     if damageValue < 1 then
         damageValue = 1
     end
     local trueDamage = self:LiquidateDamage(math.floor(damageValue),isCrit,_attackerInfo)
     --反作弊
     if damageValue > BattleVerify["maxAtk"] then
         BattleVerify["maxAtk"] = damageValue
     end

     return trueDamage
 end

 function MemberMonster:CalculateBeSkilled(_skillInfo, _attackInfo)
     --buff
     if _skillInfo.skillBuffID ~= 0 then
        self.buffControl:addBuffer(self, _skillInfo.skillBuffID,_skillInfo.skillSponsor, _skillInfo.skillSLevel)
     end
     
     --只带BUFF 无伤害的技能
     if _skillInfo.skillBaseDamage <= 0 then
        return
     end
     --计算最终伤害
     local damageValue = (_skillInfo.skillBaseDamage - self.m_attackInfo.defenceValue/_skillInfo.skillSection)*_skillInfo.skillCoefficient*damageRandom(self:getRandomSeed())
     --计算属性相克
     damageValue = _skillInfo.skillRestriction[self.m_monsterType] * damageValue
     local isCrit = false
     if isTrigger(_attackInfo.critValue, 1000, self:getRandomSeed()) == true then
        isCrit = true
        damageValue = damageValue*1.5
     end
     if damageValue < 1 then
         damageValue = 1
     end
     local trueDamage =  self:LiquidateDamage(math.floor(damageValue),isCrit,_attackInfo)
    --收集信息
    --反作弊
     if damageValue > BattleVerify["maxAtk"] then
         BattleVerify["maxAtk"] = damageValue
     end

     return trueDamage
 end

 --统一进行结算
 function MemberMonster:LiquidateDamage(_damageValue,_isCrit,_attackInfo)
     if IsBattleOver then
        return 0
     end
     local realDamageValue = 0
     _damageValue = math.floor(_damageValue)
     for k,v in pairs(self.m_allShields) do
       if v ~= nil and v.shieldHp > 0 then
           v.shieldHp = v.shieldHp - _damageValue
           print("v.shieldHp - _damageValue:"..v.shieldHp)
           if v.shieldHp <= 0 then
               self.buffControl:clearShield(self,k)
           end
           return realDamageValue
       end
     end
     if CurBossID ~= tonumber(self.m_attackInfo.tptId) then
        self.progress:stopAllActions()
        self.progress:setVisible(true)
        self.progress:performWithDelay(function()
            self.progress:setVisible(false)
        end, 2.5)
     end
     
     --最终伤害的加成处理
     if _damageValue > 1 and _attackInfo ~= nil then
        _damageValue = ExclusivesAI:getFinalDamage(_damageValue,_attackInfo,self.m_attackInfo,self.buffShowing)
     end
     self.m_attackInfo.curHp = self.m_attackInfo.curHp - _damageValue
     if self.m_attackInfo.curHp > self.m_attackInfo.maxHp then
         self.m_attackInfo.curHp = self.m_attackInfo.maxHp
     end
     if self.m_monsterType == 2 then --机械怪
        if self.m_attackInfo.curHp > self.m_attackInfo.maxHp*0.3 then
           self.smokeEff:setVisible(false)
        else
           self.smokeEff:setVisible(true)
        end
     end

     local damageNumber = HurtNumber.new(_damageValue,_isCrit)
     :pos(self.progress:getPositionX()-self.progress:getContentSize().width, self.progress:getPositionY()+display.width/90)
     :addTo(self)
     realDamageValue = _damageValue
     if self.m_attackInfo.curHp<=0 then
        realDamageValue = _damageValue - self.m_attackInfo.curHp
        self.m_isDead = true
        self.progress:setProgress(0)
        if CurBossID == tonumber(self.m_attackInfo.tptId) then --是BOSS   BOSS血条掉血
            if startFightBattleScene.Instance~=nil then
                startFightBattleScene.Instance.bossHpProgress:setPercentage(0)
            else
                display.getRunningScene().bossHpProgress:setPercentage(0)
            end
        end
     else
        local hpPercent = self.m_attackInfo.curHp/self.m_attackInfo.maxHp*100
        self.progress:setProgress(hpPercent)
        if CurBossID == tonumber(self.m_attackInfo.tptId) then --是BOSS   BOSS血条掉血
            if startFightBattleScene.Instance~=nil then
                startFightBattleScene.Instance.bossHpProgress:setPercentage(hpPercent)
            else
                display.getRunningScene().bossHpProgress:setPercentage(hpPercent)
            end
        end
     end
     AllDamageValue = AllDamageValue + realDamageValue
     if CurFightBattleType == FightBattleType.kType_WorldBoss then
        self:bossDamage(realDamageValue) 
     end
     return realDamageValue
 end
 
 function MemberMonster:stopMonsterAnimation()
      if self.makeType == ModelMakeType.kMake_Coco then
        self.m_member:getAnimation():stop()
    else
        self.m_member:stop()
    end
 end

 function MemberMonster:getAttackRect()
     return self.m_attackInfo.attackRect * display.width
 end

 function MemberMonster:getMemberAnimation()
     if self.makeType == ModelMakeType.kMake_Coco then
        return self.m_member:getAnimation()
     else
        return self.m_member
     end
 end

 function MemberMonster:getRandomSeed()
     -- self.m_seedIndex = self.m_seedIndex + 1
     -- if self.m_randSeedPool[self.m_seedIndex - 1] then
     --      return self.m_randSeedPool[self.m_seedIndex - 1]
     -- else
     --      return 100000
     -- end

     return 100000
     
 end

 return MemberMonster