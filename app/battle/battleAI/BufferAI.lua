--
-- Author: liufei
-- Date: 2014-11-11 11:27:52
--
 require("app.battle.BattleInfo")

 local HurtNumber = require("app.battle.battleUI.HurtNumber")

  --BUFF的作用类型
 BuffEffType = {}
 BuffEffType.kBuffEff_Value  = 1  --改变属性值类型
 BuffEffType.kBuffEff_Damage = 2  --持续伤害类型
 BuffEffType.kBuffEff_Shield = 3  --吸收盾类型
 
 
 --所有的BUFF种类
 BufferType = {}
 -- BufferType.kBufferJunhaoDefence = 1099   --军号防御
 BufferType.kBufferStun              = 101001 --晕眩
 BufferType.kBufferFrozen            = 103001 --冰冻
 BufferType.kBufferParalysis         = 104001 --电磁麻痹
 BufferType.kBufferCorrosion         = 106001 --酸性腐蚀
 BufferType.kBufferBurn              = 107001 --火焰灼烧
 BufferType.kBufferBurnSeven         = 107007 --火焰灼烧
 BufferType.kBufferShield            = 108001 --吸收护盾
 BufferType.kBufferAttackReduce      = 109001 --减少攻击
 BufferType.kBufferAttackPromote     = 110001 --增加攻击
 BufferType.kBufferDeffenceReduce    = 111001 --减少防御
 BufferType.kBufferDeffencePromote   = 112001 --增加防御
 BufferType.kBufferSpeedPromote      = 113001 --增加攻速
 BufferType.kBufferHitReduce         = 114001 --减少命中
 BufferType.kBufferHitPromote        = 115001 --增加命中
 BufferType.kBufferDodgeReduce       = 116001 --减少闪避
 BufferType.kBufferDodgePromote      = 117001 --增加闪避
 BufferType.kBufferPoisonRain        = 818001 --毒雨
 BufferType.kBufferSkateboard        = 117002 --滑板鞋 提升闪避
 BufferType.kBufferEnginerShield     = 108002 --机械师吸收盾
 BufferType.kBufferFighterCharm      = 101002 --格斗家魅惑
 BufferType.kBufferTankStun          = 101003 --主角战车群体击晕
 BufferType.kBufferTankDodge         = 117003 --主角战车加闪避
 BufferType.kBufferJeepAttack        = 110003 --吉普车增加攻击
 BufferType.kBufferJeecpHit          = 115002 --吉普车增加命中
 BufferType.kBufferFighterCrit       = 119001 --格斗家 增加暴击
 BufferType.kTankStun                = 101004 --装甲车眩晕打击
 BufferType.kSeFrozen                = 103002 --冰霜弹专用
 BufferType.kSeParalysis             = 104002 --电磁弹专用
 BufferType.kSeCorrosion             = 106002 --强酸弹专用
 BufferType.kSeBurn                  = 107002 --燃烧弹专用
 BufferType.kSeSmoke                 = 114002 --烟幕弹专用
 BufferType.kSeDeforce               = 109002 --脱力弹专用
 BufferType.kSeArmor                 = 111002 --破甲弹专用
 BufferType.kSeLocation              = 116002 --定位弹专用
 BufferType.kAllDeffenceReduce       = 111003 --全体降防
 BufferType.kAllDeffenceSilence      = 104003 --全体沉默
 BufferType.kMidTankStun             = 101009 --中型坦克后排眩晕

 BufferType.kLaserBurnOne            = 107003 --初级灼热
 BufferType.kLaserBurnTwo            = 107004 --烈焰灼热
 BufferType.kLaserBurnThree          = 107005 --初级灼热
 BufferType.kLaserBurnFour           = 107006 --焚城灼热
 BufferType.kLaserAttackReduceOne    = 109003 --水深火热
 BufferType.kLaserAttackReduceTwo    = 109004 --水红束缚
 BufferType.kLaserStunOne            = 101005 --粉之魅惑
 BufferType.kLaserStunTwo            = 101006 --粉红魅惑
 BufferType.kLaserStunThree          = 101007 --初级眩晕
 BufferType.kLaserStunFour           = 101008 --心灵震颤
 BufferType.kLaserDeffenceReduceOne  = 111004 --初级破甲
 BufferType.kLaserDeffenceReduceTwo  = 111005 --血色穿刺
 BufferType.kLaserCorrosionOne       = 106003 --初级腐蚀
 BufferType.kLaserCorrosionTwo       = 106004 --黑暗腐蚀
 BufferType.kLaserGagOne             = 104004 --初级麻痹
 BufferType.kLaserGagTwo             = 104005 --干扰之源

 BufferType.kAllDeffencePromote      = 112004 --主角车全体加防御

 BufferType.kJiXieShiStun            = 101010
 BufferType.kRogueAddAttack          = 110006 --流氓加攻击

 BufferType.kExclusiveTankStun       = 101011 --主角车进阶群控
 BufferType.kExclusiveShield         = 108003 --进阶吸收护盾
 BufferType.kExclusiveZJStun         = 101012 --进阶装甲车前排眩晕
 BufferType.kExclusiveHitReduce      = 114003 --进阶减少全体命中

 BufferType.kXueTuFrozen             = 103003 --雪兔冰冻

 local BufferAI = class("BufferAI", function ()
 	return display.newNode()
 end)

 function BufferAI:ctor()
    
 end

 function  BufferAI:addBuffer(_member, _buffId, _sponsor, _sLvl)
    print("BUFF:".._buffId)

    -- if _member.m_posType == MemberPosType.defenceType and _member.fightPos == 1 then
    --    print("--------------------------------------------defense jiuhu buffId=".._buffId)
    -- end

    -- if _member.m_posType == MemberPosType.attackType and _member.fightPos == 1 then
    --    print("--------------------------------------------attack jiuhu buffId=".._buffId)
    -- end    

  --保存此BUFF的增量   时间到后删除增量
    local buffAttackInfo = {
       attackValue = 0, --攻击力
       curHp = 0, --当前生命
       maxHp = 0, --最大生命值
       defenceValue = 0, --防御力
       critValue = 0, -- 暴击
       hitValue = 0, -- 命中
       dodgeValue = 0, --闪避
       attackInterval = 0, --攻击间隔
       attackRect = 0, --攻击距离
       hitOffsetX = 0, --受击点X偏移
       stunNum = 0, --击晕魅惑值
       gagNum = 0,--沉默值
       mainCD = 0,--主炮间隔
    }
    local targetMember = nil
    local removeAction = nil

    local function showBuffMiss()
        HurtNumber.new(0,false)
        :pos(_member.progress:getPositionX()-_member.progress:getContentSize().width, _member.progress:getPositionY())
        :addTo(_member)
    end
    
    -------------------晕眩
    if _buffId == BufferType.kBufferStun then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
        
      if _member ~= nil and _member.m_isDead == false then
          targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    elseif _buffId == BufferType.kMidTankStun then
      print(_member.m_attackInfo.level)
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
        
      if _member ~= nil and _member.m_isDead == false then
          targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    elseif _buffId == BufferType.kJiXieShiStun then
      -- if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
      --     showBuffMiss()
      --     return
      -- end
        
      if _member ~= nil and _member.m_isDead == false then
          targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------冰冻
    elseif _buffId == BufferType.kBufferFrozen then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local frozenNums = string.split(buffData[_buffId]["valuePercent"],"|")
      buffAttackInfo.attackInterval = targetMember.m_attackInfo.attackInterval*tonumber(frozenNums[1])
      targetMember.m_attackInfo.attackInterval = targetMember.m_attackInfo.attackInterval + buffAttackInfo.attackInterval
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    -------------------电磁麻痹
    elseif _buffId == BufferType.kBufferParalysis then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.gagNum = 1
      targetMember.m_gagNum = targetMember.m_gagNum + buffAttackInfo.gagNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    -------------------酸性腐蚀
    elseif _buffId == BufferType.kBufferCorrosion then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      --间隔
      local  damageInterval = tonumber(buffData[_buffId]["Interval"])
      --伤害次数
      local atkBase = 0
      if _sponsor.m_memberType == MemberAllType.kMemberHero or _sponsor.m_memberType == MemberAllType.kMemberMonster then
          atkBase = _sponsor.m_attackInfo.attackValue
      else
          atkBase = _sponsor.m_mainAtk
      end
      local  damageTime = math.floor(tonumber(buffData[_buffId]["CD"])/damageInterval)
      local  damageValue = tonumber(buffData[_buffId]["blood"])*atkBase
      local  restriction = self:getBuffRestriction(_buffId)
      damageValue = restriction[targetMember.m_monsterType]*damageValue
      local function  makeDamage()
         if targetMember~=nil and targetMember.m_isDead == false then
             targetMember:LiquidateDamage(math.floor(damageValue),false)
             targetMember:afterBeAttack()
          end
      end
      removeAction = transition.sequence({cc.Repeat:create(transition.sequence({
                                                             cc.DelayTime:create(damageInterval),
                                                             cc.CallFunc:create(makeDamage),
                                                          }),damageTime),
                                          cc.CallFunc:create(function()
                                            self:clearBuff(targetMember,_buffId)
                                          end)
                                         })
      self:runAction(removeAction)
      
    -------------------火焰灼烧
    elseif _buffId == BufferType.kBufferBurn or _buffId == BufferType.kBufferBurnSeven then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      --间隔
      local  damageInterval = tonumber(buffData[_buffId]["Interval"])
      --伤害次数
      local atkBase = 0
      if _sponsor.m_memberType == MemberAllType.kMemberHero or _sponsor.m_memberType == MemberAllType.kMemberMonster then
          atkBase = _sponsor.m_attackInfo.attackValue
      else
          atkBase = _sponsor.m_mainAtk
      end
      local  damageTime = math.floor(tonumber(buffData[_buffId]["CD"])/damageInterval)
      local  damageValue = tonumber(buffData[_buffId]["blood"])*atkBase
      local  restriction = self:getBuffRestriction(_buffId)
      damageValue = restriction[targetMember.m_monsterType]*damageValue
      local function  makeDamage()
          if targetMember~=nil and targetMember.m_isDead == false then
             targetMember:LiquidateDamage(math.floor(damageValue),false)
             targetMember:afterBeAttack()
          end
      end
      removeAction = transition.sequence({cc.Repeat:create(transition.sequence({
                                                             cc.DelayTime:create(damageInterval),
                                                             cc.CallFunc:create(makeDamage),
                                                          }),damageTime),
                                          cc.CallFunc:create(function()
                                            self:clearBuff(targetMember,_buffId)
                                          end)
                                         })
      self:runAction(removeAction)
    
    -------------------攻击降低
    elseif _buffId == BufferType.kBufferAttackReduce then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.attackValue = - targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------攻击增加
    elseif _buffId == BufferType.kBufferAttackPromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.attackValue = targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    -------------------防御降低
    elseif _buffId == BufferType.kBufferDeffenceReduce then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = - targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------防御增加
    elseif _buffId == BufferType.kBufferDeffencePromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------攻速增加
    elseif _buffId == BufferType.kBufferSpeedPromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.mainCD = - targetMember.m_attackInfo.mainCD*tonumber(buffData[_buffId]["valuePercent"])
      targetMember.m_attackInfo.mainCD = targetMember.m_attackInfo.mainCD + buffAttackInfo.mainCD
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    -------------------命中降低
    elseif _buffId == BufferType.kBufferHitReduce or _buffId == BufferType.kExclusiveHitReduce then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.hitValue = - targetMember.m_attackInfo.hitValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.hitValue = targetMember.m_attackInfo.hitValue + buffAttackInfo.hitValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    -------------------命中增加
    elseif _buffId == BufferType.kBufferHitPromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.hitValue = targetMember.m_attackInfo.hitValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.hitValue = targetMember.m_attackInfo.hitValue + buffAttackInfo.hitValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------闪避降低
    elseif _buffId == BufferType.kBufferDodgeReduce then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.dodgeValue = - targetMember.m_attackInfo.dodgeValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue + buffAttackInfo.dodgeValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    -------------------闪避增加
    elseif _buffId == BufferType.kBufferDodgePromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue + buffAttackInfo.dodgeValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    -------------------魅惑
    elseif _buffId == BufferType.kBufferFighterCharm then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    --主角战车群体击晕
    elseif _buffId == BufferType.kBufferTankStun or _buffId == BufferType.kExclusiveTankStun then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    --主角战车加闪避
    elseif _buffId == BufferType.kBufferTankDodge  then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.dodgeValue = tonumber(buffData[_buffId]["value"])
      targetMember.m_attackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue + buffAttackInfo.dodgeValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------命中毒雨
    elseif _buffId == BufferType.kBufferPoisonRain then
      --todo

    -----------------滑板鞋 提升闪避
    elseif _buffId == BufferType.kBufferSkateboard then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.dodgeValue = tonumber(buffData[_buffId]["value"]) + tonumber(buffData[_buffId]["valueGF"])*targetMember.m_energySkills[MemberSkillType.kSkillHeroThree].lvl
      targetMember.m_attackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue + buffAttackInfo.dodgeValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    ----------------吉普车增加攻击
    elseif _buffId == BufferType.kBufferJeepAttack then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.attackValue = targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    ----------------吉普车增加命中
    elseif _buffId == BufferType.kBufferJeecpHit then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.hitValue = tonumber(buffData[_buffId]["value"])
      targetMember.m_attackInfo.hitValue = targetMember.m_attackInfo.hitValue + buffAttackInfo.hitValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    
    --格斗家 增加暴击
    elseif _buffId == BufferType.kBufferFighterCrit then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.critValue = tonumber(buffData[_buffId]["value"])
      targetMember.m_attackInfo.critValue = targetMember.m_attackInfo.critValue + buffAttackInfo.critValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -------------------装甲车眩晕打击
    elseif _buffId == BufferType.kTankStun or _buffId == BufferType.kExclusiveZJStun then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    --冰霜弹专用
    elseif _buffId == BufferType.kSeFrozen or _buffId == BufferType.kXueTuFrozen then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local frozenNums = string.split(buffData[_buffId]["valuePercent"],"|")
      buffAttackInfo.attackInterval = targetMember.m_attackInfo.attackInterval*tonumber(frozenNums[1])
      targetMember.m_attackInfo.attackInterval = targetMember.m_attackInfo.attackInterval + buffAttackInfo.attackInterval
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --电磁弹专用
    elseif _buffId == BufferType.kSeParalysis then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.gagNum = 1
      targetMember.m_gagNum = targetMember.m_gagNum + buffAttackInfo.gagNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end
     
    --强酸弹专用
    elseif _buffId == BufferType.kSeCorrosion then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      --间隔
      local  damageInterval = tonumber(buffData[_buffId]["Interval"])
      --伤害次数
      local atkBase = targetMember.m_attackInfo.maxHp
      local  damageTime = math.floor(tonumber(buffData[_buffId]["CD"])/damageInterval)
      local  damageValue = tonumber(buffData[_buffId]["blood"])*atkBase
      local  restriction = self:getBuffRestriction(_buffId)
      damageValue = restriction[targetMember.m_monsterType]*damageValue
      if damageValue > tonumber(buffData[_buffId]["Atklimit"]) then
          damageValue = tonumber(buffData[_buffId]["Atklimit"])
      end
      local function  makeDamage()
          if targetMember~=nil and targetMember.m_isDead == false then
             targetMember:LiquidateDamage(math.floor(damageValue),false)
             targetMember:afterBeAttack()
          end
      end
      
      removeAction = transition.sequence({cc.Repeat:create(transition.sequence({
                                                             cc.DelayTime:create(damageInterval),
                                                             cc.CallFunc:create(makeDamage),
                                                          }),damageTime),
                                          cc.CallFunc:create(function()
                                            self:clearBuff(targetMember,_buffId)
                                          end)
                                         })
      self:runAction(removeAction)

      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --燃烧弹专用
    elseif _buffId == BufferType.kSeBurn then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      --间隔
      local  damageInterval = tonumber(buffData[_buffId]["Interval"])
      --伤害次数
      local atkBase = targetMember.m_attackInfo.maxHp
      local  damageTime = math.floor(tonumber(buffData[_buffId]["CD"])/damageInterval)
      local  damageValue = tonumber(buffData[_buffId]["blood"])*atkBase
      local  restriction = self:getBuffRestriction(_buffId)
      damageValue = restriction[targetMember.m_monsterType]*damageValue
      if damageValue > tonumber(buffData[_buffId]["Atklimit"]) then
          damageValue = tonumber(buffData[_buffId]["Atklimit"])
      end
      
      local function  makeDamage()
          if targetMember~=nil and targetMember.m_isDead == false then
             targetMember:LiquidateDamage(math.floor(damageValue),false)
             targetMember:afterBeAttack()
          end
      end

      removeAction = transition.sequence({cc.Repeat:create(transition.sequence({
                                                             cc.DelayTime:create(damageInterval),
                                                             cc.CallFunc:create(makeDamage),
                                                          }),damageTime),
                                          cc.CallFunc:create(function()
                                            self:clearBuff(targetMember,_buffId)
                                          end)
                                         })
      self:runAction(removeAction)

      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --烟幕弹专用
    elseif _buffId == BufferType.kSeSmoke then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.hitValue = - targetMember.m_attackInfo.hitValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.hitValue = targetMember.m_attackInfo.hitValue + buffAttackInfo.hitValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --脱力弹专用
    elseif _buffId == BufferType.kSeDeforce then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.attackValue = - targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --破甲弹专用
    elseif _buffId == BufferType.kSeArmor then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = - targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --定位弹专用
    elseif _buffId == BufferType.kSeLocation then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.dodgeValue = - targetMember.m_attackInfo.dodgeValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.dodgeValue = targetMember.m_attackInfo.dodgeValue + buffAttackInfo.dodgeValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      if tonumber(buffData[_buffId]["Atkpower"]) > 0 then
          targetMember:LiquidateDamage(tonumber(buffData[_buffId]["Atkpower"]),false)
          targetMember:afterBeAttack()
      end

    --全体降防
    elseif _buffId == BufferType.kAllDeffenceReduce  then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = - targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
      
    --全体沉默
    elseif _buffId == BufferType.kAllDeffenceSilence then
      if _sponsor ~= nil and isStunHit(_member.m_attackInfo.level, _sLvl, _sponsor:getRandomSeed()) == false then
          showBuffMiss()
          return
      end
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.gagNum = 1
      targetMember.m_gagNum = targetMember.m_gagNum + buffAttackInfo.gagNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    --全体加防御
    elseif _buffId == BufferType.kAllDeffencePromote then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    elseif _buffId == BufferType.kLaserBurnOne or _buffId == BufferType.kLaserBurnTwo or _buffId == BufferType.kLaserBurnThree or _buffId == BufferType.kLaserBurnFour or _buffId == BufferType.kLaserCorrosionOne or _buffId == BufferType.kLaserCorrosionTwo then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      --间隔
      local  damageInterval = tonumber(buffData[_buffId]["Interval"])
      --伤害次数
      local atkBase = _sponsor
      
      local  damageTime = math.floor(tonumber(buffData[_buffId]["CD"])/damageInterval)
      local  damageValue = tonumber(buffData[_buffId]["blood"])*atkBase
      local  restriction = self:getBuffRestriction(_buffId)
      damageValue = restriction[targetMember.m_monsterType]*damageValue
      local function  makeDamage()
          if targetMember~=nil and targetMember.m_isDead == false then
             targetMember:LiquidateDamage(math.floor(damageValue),false)
             targetMember:afterBeAttack()
          end
      end
      removeAction = transition.sequence({cc.Repeat:create(transition.sequence({
                                                             cc.DelayTime:create(damageInterval),
                                                             cc.CallFunc:create(makeDamage),
                                                          }),damageTime),
                                          cc.CallFunc:create(function()
                                            self:clearBuff(targetMember,_buffId)
                                          end)
                                         })
      self:runAction(removeAction)

    elseif _buffId == BufferType.kLaserAttackReduceOne or _buffId == BufferType.kLaserAttackReduceTwo then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.attackValue = - targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    elseif _buffId == BufferType.kLaserStunOne or _buffId == BufferType.kLaserStunTwo or _buffId == BufferType.kLaserStunThree or _buffId == BufferType.kLaserStunFour then
      if _member ~= nil and _member.m_isDead == false then
          targetMember = _member
      else
        return
      end
      buffAttackInfo.stunNum = 1
      targetMember.m_stunNum = targetMember.m_stunNum + buffAttackInfo.stunNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    elseif _buffId == BufferType.kLaserDeffenceReduceOne or _buffId == BufferType.kLaserDeffenceReduceTwo then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local  restriction = self:getBuffRestriction(_buffId)
      buffAttackInfo.defenceValue = - targetMember.m_attackInfo.defenceValue*tonumber(buffData[_buffId]["valuePercent"])*restriction[targetMember.m_monsterType]
      targetMember.m_attackInfo.defenceValue = targetMember.m_attackInfo.defenceValue + buffAttackInfo.defenceValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    elseif _buffId == BufferType.kLaserGagOne or _buffId == BufferType.kLaserGagTwo then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.gagNum = 1
      targetMember.m_gagNum = targetMember.m_gagNum + buffAttackInfo.gagNum
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))

    -----------------机械师吸收盾
    elseif _buffId == BufferType.kBufferEnginerShield then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      local scaleX = 0.666
      local scaleY = 0.666
      if targetMember.m_posType  == MemberPosType.attackType then
         buffAttackInfo.hitOffsetX = display.width*0.09*BlockTypeScale
      elseif targetMember.m_posType  == MemberPosType.defenceType then
         buffAttackInfo.hitOffsetX = - display.width*0.09*BlockTypeScale
      else
         return
      end

      local hero_hxh = self:getParent()--得到机械师

      targetMember.hitOffsetX = targetMember.hitOffsetX + buffAttackInfo.hitOffsetX
      targetMember.m_allShields[tostring(_buffId)] = {}
      targetMember.m_allShields[tostring(_buffId)].shieldHp =  (tonumber(buffData[_buffId]["valuePercent"])+hero_hxh.m_energySkills[MemberSkillType.kSkillHeroTwo].lvl*tonumber(buffData[_buffId]["valuePercentGF"]))*hero_hxh.m_attackInfo.attackValue
      targetMember.m_allShields[tostring(_buffId)].shieldValueAdd = buffAttackInfo

      -- local shieldSp =  display.newSprite("Battle/Skill/eShield.png")
      -- :addTo(targetMember)
      ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Battle/Skill/jixieshidun.ExportJson")
      local shieldSp = ccs.Armature:create("jixieshidun")
              :addTo(targetMember)
      shieldSp:getAnimation():play("Skill2")

      if targetMember.m_posType  == MemberPosType.attackType then
          shieldSp:align(display.CENTER_BOTTOM, display.width*0.02,0)
          shieldSp:setScaleY(scaleY*BlockTypeScale)
          shieldSp:setScaleX(-1*scaleX*BlockTypeScale)
      elseif targetMember.m_posType  == MemberPosType.defenceType then
          shieldSp:align(display.CENTER_BOTTOM, -display.width*0.02,0)
          shieldSp:setScaleY(scaleY*BlockTypeScale)
          shieldSp:setScaleX(scaleX*BlockTypeScale)
      end
      targetMember.m_allShields[tostring(_buffId)].shieldEff = shieldSp

    -------------------吸收护盾
    elseif _buffId == BufferType.kBufferShield or _buffId == BufferType.kExclusiveShield then
      print("ggggggggggg:".._buffId)
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      targetMember.hitOffsetX = targetMember.hitOffsetX + buffAttackInfo.hitOffsetX
      targetMember.m_allShields[tostring(_buffId)] = {}
      targetMember.m_allShields[tostring(_buffId)].shieldHp =  tonumber(buffData[_buffId]["valuePercent"])*_sponsor.m_mainAtk
      targetMember.m_allShields[tostring(_buffId)].shieldValueAdd = buffAttackInfo
      local shieldSp =  display.newSprite("#buff108001_00.png") 
      :align(display.TOP_CENTER,0,_member.progress:getPositionY()+display.width*0.02*BlockTypeScale)
      :addTo(targetMember)
      shieldSp:scale(BlockTypeScale)
      local frames2 = display.newFrames("buff108001_%02d.png", 0, 13)
      local animation2 = display.newAnimation(frames2, 1.3/13)
      local aniAction2 = cc.Animate:create(animation2)
      shieldSp:runAction(cc.RepeatForever:create(aniAction2))
      targetMember.m_allShields[tostring(_buffId)].shieldEff = shieldSp

    --流氓加攻击
    elseif _buffId == BufferType.kRogueAddAttack then
      if _member ~= nil and _member.m_isDead == false then
        targetMember = _member
      else
        return
      end
      buffAttackInfo.attackValue = targetMember.m_attackInfo.attackValue*tonumber(buffData[_buffId]["valuePercent"])
      targetMember.m_attackInfo.attackValue = targetMember.m_attackInfo.attackValue + buffAttackInfo.attackValue
      removeAction = self:performWithDelay(function()
         self:clearBuff(targetMember,_buffId)
      end, tonumber(buffData[_buffId]["CD"]))
    else
      print("Error:无对应BUFF")
    end
    --buff显示
    if targetMember ~= nil and _buffId ~= BufferType.kBufferEnginerShield and _buffId ~= BufferType.kBufferShield and _buffId ~= BufferType.kExclusiveShield then
        local resName = buffData[_buffId]["buffResId"]
        local resNum = tonumber(buffData[_buffId]["buffResNum"])
        local buffShow = display.newSprite("#"..resName.."_00.png")
        :addTo(targetMember)
        buffShow:setPosition(0 , targetMember.progress:getPositionY() + display.width*0.02)
        local buffframes = display.newFrames(resName.."_%02d.png", 0, resNum-1)
        local buffanimation = display.newAnimation(buffframes, 0.06)
        buffAction = cc.Animate:create(buffanimation)
        buffShow:runAction(cc.RepeatForever:create(buffAction))
        self:clearBuff(targetMember,_buffId)
        targetMember.buffShowing[tostring(_buffId)] = {}
        targetMember.buffShowing[tostring(_buffId)].buffEff = buffShow
        targetMember.buffShowing[tostring(_buffId)].buffValueAdd = buffAttackInfo
        removeAction:setTag(_buffId)
        targetMember.buffShowing[tostring(_buffId)].removeAction = removeAction
        self:resetBuffShow(targetMember)

        local buffWordsSp = display.newSprite("SkillIcon/"..buffData[_buffId]["wordResId"]..".png")
        :pos(0, targetMember.progress:getPositionY())
        :addTo(targetMember)

        local fadein = cc.FadeIn:create(0.2)
        local scalein = cc.ScaleTo:create(0.2,1.0)
        local movebyin = cc.MoveBy:create(0.2,cc.p(0,display.width*0.01))
        local spIn = cc.Spawn:create({fadein,scalein,movebyin})

        local delay = cc.DelayTime:create(1)

        local fadeout = cc.FadeOut:create(0.5)
        local scaleout = cc.ScaleTo:create(0.5,0.85)
        local movebyout = cc.MoveBy:create(0.5,cc.p(0,display.width*0.03))
        local spOut = cc.Spawn:create({fadeout,scaleout,movebyout})
    
        local callback = cc.CallFunc:create(buffWordsSp.removeSelf)
        buffWordsSp:runAction(transition.sequence({spIn,delay,spOut,callback}))
    end
    --收集信息
    -- if targetMember ~= nil then
    --   local message = {}
    --   message["type"] = BattleMessageType.kMessageBuffOn
    --   message["passiveId"] = targetMember.m_attackInfo.tptId
    --   message["passiveName"] = targetMember.m_attackInfo.tptName
    --   message["buffId"] = _buffId
    --   message["buffName"] = buffData[_buffId]["name"]
    --   BattleMessageBox:addMessage(message)
    -- end
 end

 function BufferAI:getBuffRestriction(_buffID)
     local buffRestriction = {}
     local restrictionData = string.split(buffData[_buffID]["buffEff"],"|")
     for k,v in pairs(restrictionData) do
        if v == "null" then
            break
        end
        local tmpOne = string.split(v,"#")
        buffRestriction[tonumber(tmpOne[1])] = tonumber(tmpOne[2])
    end
    return buffRestriction
 end

 function BufferAI:clearBuff(_targetMember,_buffID)

      if _targetMember == nil or _targetMember.buffShowing[tostring(_buffID)] == nil then 
        return
      end

      -- if _targetMember.m_posType == MemberPosType.defenceType and _targetMember.fightPos == 1 then
      --    print("------------------------------defense jiuhu clearbuffId=".._buffID)
      -- end

      -- if _targetMember.m_posType == MemberPosType.attackType and _targetMember.fightPos == 1 then
      --    print("------------------------------attack jiuhu clearbuffId=".._buffID)
      -- end       

      local addAttackInfo = _targetMember.buffShowing[tostring(_buffID)].buffValueAdd
      _targetMember.m_attackInfo.attackValue    = _targetMember.m_attackInfo.attackValue    - addAttackInfo.attackValue
      _targetMember.m_attackInfo.curHp          = _targetMember.m_attackInfo.curHp          - addAttackInfo.curHp
      _targetMember.m_attackInfo.maxHp          = _targetMember.m_attackInfo.maxHp          - addAttackInfo.maxHp
      _targetMember.m_attackInfo.defenceValue   = _targetMember.m_attackInfo.defenceValue   - addAttackInfo.defenceValue
      _targetMember.m_attackInfo.critValue      = _targetMember.m_attackInfo.critValue      - addAttackInfo.critValue
      _targetMember.m_attackInfo.hitValue       = _targetMember.m_attackInfo.hitValue       - addAttackInfo.hitValue
      _targetMember.m_attackInfo.dodgeValue     = _targetMember.m_attackInfo.dodgeValue     - addAttackInfo.dodgeValue
      _targetMember.m_attackInfo.attackInterval = _targetMember.m_attackInfo.attackInterval - addAttackInfo.attackInterval
      _targetMember.m_attackInfo.attackRect     = _targetMember.m_attackInfo.attackRect     - addAttackInfo.attackRect
      -- print("_targetMember.m_attackInfo.mainCD:".._targetMember.m_attackInfo.mainCD)
      -- printTable(addAttackInfo)
      _targetMember.m_attackInfo.mainCD         = _targetMember.m_attackInfo.mainCD         - addAttackInfo.mainCD
      _targetMember.hitOffsetX                  = _targetMember.hitOffsetX                  - addAttackInfo.hitOffsetX
      _targetMember.m_stunNum                   = _targetMember.m_stunNum                   - addAttackInfo.stunNum
      _targetMember.m_gagNum                    = _targetMember.m_gagNum                     - addAttackInfo.gagNum

      -- --收集信息
      -- local message = {}
      -- message["type"] = BattleMessageType.kMessageBuffOff
      -- message["passiveId"] = _targetMember.m_attackInfo.tptId 
      -- message["passiveName"] = _targetMember.m_attackInfo.tptName
      -- message["buffId"] = _buffID
      -- message["buffName"] = buffData[tonumber(_buffID)]["name"]
      -- BattleMessageBox:addMessage(message)
      
      if _targetMember.buffShowing[tostring(_buffID)] then  
          if _targetMember.buffShowing[tostring(_buffID)].buffEff ~= nil and isNodeValue(_targetMember.buffShowing[tostring(_buffID)].buffEff) then
             _targetMember.buffShowing[tostring(_buffID)].buffEff:removeSelf()
          end
          self:stopActionByTag(_buffID)
          _targetMember.buffShowing[tostring(_buffID)] = nil
          self:resetBuffShow(_targetMember)
      end
  end
  function BufferAI:clearShield(_targetMember,_buffID)
      
      if _targetMember.m_allShields[tostring(_buffID)] then
          local addAttackInfo = _targetMember.m_allShields[tostring(_buffID)].shieldValueAdd
          _targetMember.hitOffsetX = _targetMember.hitOffsetX - addAttackInfo.hitOffsetX

          if _targetMember.m_allShields[tostring(_buffID)].shieldEff ~= nil and isNodeValue(_targetMember.m_allShields[tostring(_buffID)].shieldEff) then
            _targetMember.m_allShields[tostring(_buffID)].shieldEff:removeSelf()
          end
          _targetMember.m_allShields[tostring(_buffID)] = nil
          print("===============---------------jjjjjjjjjjjjkkkk")
          ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("Battle/Skill/jixieshidun.ExportJson")
          display.removeSpriteFramesWithFile("Battle/Skill/jixieshidun0.plist","Battle/Skill/jixieshidun0.png")
      end
      -- --收集信息
      -- local message = {}
      -- message["type"] = BattleMessageType.kMessageBuffOff
      -- message["passiveId"] = _targetMember.m_attackInfo.tptId
      -- message["passiveName"] = _targetMember.m_attackInfo.tptName
      -- message["buffId"] = _buffID
      -- message["buffName"] = buffData[tonumber(_buffID)]["name"]
      -- BattleMessageBox:addMessage(message)
  end
  
  function BufferAI:resetBuffShow(_targetMember)
      local buffNum = 0
      local tmpBuffs = {}
      for k,v in pairs(_targetMember.buffShowing) do
        if isNodeValue(v) then
            buffNum = buffNum + 1
            table.insert(tmpBuffs,#tmpBuffs+1,v)
        end
      end
      local x = math.floor(buffNum/2)
      local y = buffNum%2
      if y == 0 then --偶数
          for i=x,1,-1 do--前半段
              tmpBuffs[i].buffEff:setPosition(-display.width*0.015 - display.width*0.03*(x-i), _targetMember.progress:getPositionY() + display.width*0.025)
          end
          for i=x+1,x*2,1 do--后半段
              tmpBuffs[i].buffEff:setPosition(display.width*0.015 + display.width*0.03*(i-x-1), _targetMember.progress:getPositionY() + display.width*0.025)
          end
      elseif y == 1 then --奇数
          tmpBuffs[x+y].buffEff:setPosition(0, _targetMember.progress:getPositionY() + display.width*0.025)--中间位置
          for i=x,1,-1 do--前半段
              tmpBuffs[i].buffEff:setPosition(-display.width*0.03*(x-i+1), _targetMember.progress:getPositionY() + display.width*0.025)
          end
          for i=x+y+1,x*2+y,1 do--后半段
              tmpBuffs[i].buffEff:setPosition(display.width*0.03*(i-x-y), _targetMember.progress:getPositionY() + display.width*0.025)
          end
      end 
    end
 return BufferAI