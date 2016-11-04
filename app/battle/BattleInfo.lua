--
-- Author: liufei
-- Date: 2014-11-04 11:27:02
--
 --战斗信息
 BattleData = {}
 --阵型信息
 BattleFormatInfo = {}
 --战斗类型
 FightBattleType = {
                      kType_PVE = 1,
                      kType_PVP = 2,
                      kType_Legion = 3,
                      kType_Expedition = 4,
                      kType_WorldBoss = 5,
                   }
SupplyState = {
                kSupply_Out = 1,
                kSupply_In = 2,
              }

 --骨骼动画制作类型
 ModelMakeType = {
                   kMake_Coco  = 1,
                   kMake_Spine = 2,
                 }

 CurFightBattleType = 0
 --关卡ID
 BattleID = 11001001
 --战斗星级
 BattleStar = 3
 --分辨率调整后的通用缩放值
 BattleScaleValue = 0.666666
 --战斗是否超时
 IsOverTime = false

 --战斗开始时间戳 秒级
 BattleBeginTS = 0

 --战斗是否结束
 IsBattleOver = false

 --入场速度提升
 StartSpeedAdd = 0.8

 --人战缩放值
 MenBlockScale  = 1
 --车战缩放值
 TankBlockScale = 0.6
 --关卡类型缩放值
 BlockTypeScale = 1

 --剧情信息------------------
 --剧情出现是在战斗前还是战斗后
 DialogShowTime = {
                     DialogBehindFight = 1,
                     DialogAfterFight  = 2,
                  }
 --对话剧情
 PlotBlockInfo = {}
 PlotDetailInfo = {}

 --场景剧情
 DialogBlockInfo = {}
 DialogDetailInfo = {}

 --恶对话剧情
  EvilBlockInfo = {}
  EvilDetailInfo = {}
 ----------------------------
 --造成的总伤害
 AllDamageValue = 0
 --军团副本获得的奖励
 AllLegionRewards = {}
 --防作弊验证
 BattleVerify = {
                  ["maxAtk"] = 0,
                  ["maxDef"] = 0,
                  ["rhp"] = 0,
                  ["rcrit"] = 0,
                  ["rdef"] = 0,
                  ["rhit"] = 0,
                  ["rmiss"] = 0,
                  ["renergy"] = 0,
                  ["rerecover"] = 0
                }
 --所有加载的资源缓存
 AllAddedFramesCahe = {}
 --所有进攻方成员
 MemberAttackList = {}
 
 --所有防御方成员
 MemberDeffenceList = {}

 --光环类型技能
 AttackHaloSkillList = {}    --进攻方
 DeffenceHaloSkillList = {} --防守方

 --成员类型（攻击方还是防御方）
 MemberPosType = {}
 MemberPosType.attackType = 1
 MemberPosType.defenceType = 2

 --所有正在飞行的子弹
 AllFlyBullet = {
                  [1] = nil,
                  [2] = nil,
                  [3] = nil,
                  [4] = nil,
                  [5] = nil,
                  [6] = nil,
                  [7] = nil,
                  [8] = nil,
                  [9] = nil,
                  [10] = nil,
                  [11] = nil,
                  [12] = nil,
                  [13] = nil,
                  [14] = nil,
                  [15] = nil,
                  [16] = nil,
                  [17] = nil,
                  [18] = nil,
                  [19] = nil,
                  [20] = nil
                }
  
  --

 --进游戏移动到准备地点时间
 StartMoveTime = 3 

 --军号剩余冷却时间
 BugleWaitTime = 0
 --军号的触发概率
 BugleTriggerChance = 40

 --战斗结束后延迟时间
 BattleOverDelay = 0.4

 --战斗剩余时间
 BattleSurplusTime = 90

 --当前战斗的第几场
 CurBattleStep = 1
 --总共的战斗场次
 AllBattleStep = 3

 --是否自动战斗
 IsAutoFight = false

 --播放主动技能是否需要暂停members
 IsPauseMemberBeforePlaySkl = true

 --竞技场结果是否已经上报.  同归于尽情况下，光环技能属性回退试过会被处理2次，导致作弊校验出问题，加容错处理
 IsPvpResultSend = false

 --当前关卡的BOSS模板ID
 CurBossID = 0

 --记录战斗技能释放次数
 SklPlayCnt = {}

 --子弹的移动速度
 BulletMoveSpeed = display.width*0.6

 --血条位置的基准值
 HpProgressHeight = display.width*0.14

 --是否人物关卡
 IsMenBlock = false
 
 --激光炮加成信息
 LaserGunInfo = {
                   targetNum = 0,  --目标数量
                   damageAdd = 0,  --伤害加成
                   buffId    = 0,  --BUFF
                }

 --战斗过程信息
 BattleMessages = {}
 --战斗信息类型
 BattleMessageType = {}
 BattleMessageType.kMessageAttack    = 1
 BattleMessageType.kMessageSkill     = 2
 BattleMessageType.kMessageBeSkilled = 3
 BattleMessageType.kMessageBuffOn    = 4
 BattleMessageType.kMessageBuffOff   = 5
 BattleMessageType.kMessageDead      = 6
 --战斗信息控制脚本
 -- BattleMessageBox = nil
 
 --怪物类型
 MontserType = {}
 MontserType.kMonster_Bionics = 1 --仿生
 MontserType.kMonster_Machine = 2 --机械
 MontserType.kMonster_Mantype = 3 --类人

 --所有的掉落宝箱
 AllDropBox = {
                 [1] = nil,
                 [2] = nil,
                 [3] = nil,
                 [4] = nil,
                 [5] = nil,
                 [6] = nil,
                 [7] = nil,
                 [8] = nil,
                 [9] = nil,
                 [10] = nil,
                 [11] = nil,
                 [12] = nil,
                 [13] = nil,
                 [14] = nil,
                 [15] = nil,
                 [16] = nil,
                 [17] = nil,
                 [18] = nil,
                 [19] = nil,
                 [20] = nil,
              }

 --战斗中弹药的消耗数量
 BulletUseNums = {
                    [1] = 0,   --bullet1
                    [2] = 0,   --bullet2
                    [3] = 0,   --bullet3
                 }
 --战斗开始拥有的特种弹数量
 BulleHasNums = {}

 --英雄技能解锁等级
 SkillHeroUnLockLevel = {0,10,20,30}

 --所有的战斗成员类型
 MemberAllType = {} 
 MemberAllType.kMemberTankWithHero = 1 --坦克载英雄
 MemberAllType.kMemberHero         = 2 --单英雄
 MemberAllType.kMemberTank         = 3 --单坦克
 MemberAllType.kMemberMonster      = 4 --怪物

 --技能施放类型
 MemberSkillType = {}
 MemberSkillType.kSkillHeroOne        = 1
 MemberSkillType.kSkillHeroTwo        = 2
 MemberSkillType.kSkillHeroThree      = 3
 MemberSkillType.kSkillHeroFour       = 4
 MemberSkillType.kSkillTankMain       = 5
 MemberSkillType.kSkillTankOne        = 6
 MemberSkillType.kSkillTankTwo        = 7
 MemberSkillType.kSkillMonsterOne     = 8
 MemberSkillType.kSkillMonsterTwo     = 9


 --技能效果类型
 BattleSkillType = {}
 BattleSkillType.kBattleSkillHurt = 1 --伤害
 BattleSkillType.kBattleSkillRecover = 2 --回血
 BattleSkillType.kBattleSkillBuff = 3 --buff


 --攻击类型

 MemberAttackType = {}
 MemberAttackType.kAttackMelee = 1 --近战
 MemberAttackType.kAttackLong  = 2 --远程


 --[[战斗位置
                       --攻击方位置--                                                --防御方位置--                           
 ---------------------------------------------------------------------------------------------------------------------
    4号(0.1,0.46)    2号(0.2,0.5)                    **                       

                                                                2号(0.73,0.48)              6号(0.85,0.48)
                                                                               4号(0.79,0.45) 
                                     1号(0.3,0.42)    **1号(0.7,0.42)
                                                                                 
                                                                     3号(0.76,0.36)                 7号(0.88,0.36) 
                                                                                    5号(0.82,0.33) 
    5号(0.1,0.38)    3号(0.2,0.34)                    **           
----------------------------------------------------------------------------------------------------------------------
 ]]--
  --战斗进攻位置对应的坐标
 AttackPositions = {
        [1]  =  {0.3*display.width, display.height*0.42},
        [2]  =  {0.2*display.width, display.height*0.5},
        [3]  =  {0.2*display.width, display.height*0.34},
        [4]  =  {0.1*display.width, display.height*0.46},
        [5]  =  {0.1*display.width, display.height*0.38},
 }

 
 --战斗防御位置对应的坐标
 DefencePositions = {
        [1]  =  {0.62*display.width, display.height*0.42},
        [2]  =  {0.67*display.width, display.height*0.48},
        [3]  =  {0.72*display.width, display.height*0.36},
        [4]  =  {0.77*display.width, display.height*0.45},
        [5]  =  {0.82*display.width, display.height*0.33},
        [6]  =  {0.87*display.width, display.height*0.48},
        [7]  =  {0.92*display.width, display.height*0.36},
 }
 --攻击位置
 AttackPosType = {}
 AttackPosType.kAttackPosOne    = 1
 AttackPosType.kAttackPosTwo    = 2
 AttackPosType.kAttackPosThree  = 3
 AttackPosType.kAttackPosFour   = 4
 AttackPosType.kAttackPosFive   = 5
 AttackPosType.kAttackPosSix    = 6
 AttackPosType.kAttackPosSeven  = 7
 AttackPosType.kAttackPosEight  = 8
 AttackPosType.kAttackPosNine   = 9

  --攻击位置对应的显示层次
 BattleDisplayLevel = {
                        [AttackPosType.kAttackPosOne]    = 15,
                        [AttackPosType.kAttackPosTwo]    = 13,
                        [AttackPosType.kAttackPosThree]  = 16,
                        [AttackPosType.kAttackPosFour]   = 14,
                        [AttackPosType.kAttackPosFive]   = 17,
                        [AttackPosType.kAttackPosSix]    = 13,
                        [AttackPosType.kAttackPosSeven]  = 16,
                      }

 --攻击位置对应的攻击距离
 AttackPosRects = {
                     [1] = 0.85,
                     [2] = 0.85,
                     [3] = 0.85,
                     [4] = 0.85,
                     [5] = 0.85,
                     [6] = 0.85,
                     [7] = 0.85,
                  }


 --施放技能的遮挡框层次
 SkillOcclusionLevel = 10
 --施放技能的角色所处的层次
 SkillMemmberLevel = 40
 

 --各战斗位置对应的缩放比例
 FightPosScale = {
        [1]  =  0.95,
        [2]  =  1,
        [3]  =  1.05,
        [4]  =  1.05,
        [5]  =  1,
        [6]  =  0.95,
        [7]  =  0.95,
        [8]  =  1,
        [9]  =  1.05,
 }

 --特种弹对应的帧图数量
 SpeEpoFramesNum = {
        [1] = 8,
        [2] = 28,
        [3] = 23,
        [4] = 31,
        [5] = 23,
        [6] = 25,
        [7] = 12,
        [8] = 15,
        [9] = 13,
 }
 --特种弹伤害生效延迟
 SpeEpoEffectDelay = {
        [2] = 0.5,
        [3] = 0.3,
        [4] = 0.3,
        [5] = 0.3,
        [6] = 0.3,
        [7] = 0.3,
        [8] = 0.3,
        [9] = 0.3,
 }
 --特种弹对应的伤害范围
 SpeEffectRect = {
        [1] = 9,
        [2] = 0.05,
        [3] = 0.05,
        [4] = 0.2,
        [5] = 0.1,
        [6] = 0.1,
        [7] = 0.04,
        [8] = 0.04,
        [9] = 0.07,
 }


 --动作类型
 MemberAnimationType = {}
 MemberAnimationType.kMemberAnimationWalk            = "walk"
 MemberAnimationType.kMemberAnimationAttack          = "Attack"
 MemberAnimationType.kMemberAnimationDead            = "Death"
 MemberAnimationType.kMemberAnimationIdle            = "Standby"
 MemberAnimationType.kMemberAnimationHit             = "The blow"
 MemberAnimationType.kMemberAnimationHit2            = "The blow2"
 MemberAnimationType.kMemberAnimationIdle2           = "guard"

 MemberSkillAnimationType = {}
 MemberSkillAnimationType[MemberSkillType.kSkillHeroOne]       = "Skill1"
 MemberSkillAnimationType[MemberSkillType.kSkillHeroTwo]       = "Skill2"
 MemberSkillAnimationType[MemberSkillType.kSkillHeroThree]     = "Skill3"
 MemberSkillAnimationType[MemberSkillType.kSkillHeroFour]      = "Skill4"
 MemberSkillAnimationType[MemberSkillType.kSkillTankMain]      = "Attack2"
 MemberSkillAnimationType[MemberSkillType.kSkillTankOne]       = "Skill1"
 MemberSkillAnimationType[MemberSkillType.kSkillTankTwo]       = "Skill2"
 MemberSkillAnimationType[MemberSkillType.kSkillMonsterOne]    = "Casting1"
 MemberSkillAnimationType[MemberSkillType.kSkillMonsterTwo]    = "Casting2"

 --光环加成类型
 HaloBuffAddType = {}
 HaloBuffAddType.HaloMenAttack          = 1
 HaloBuffAddType.HaloTankMainAttack     = 2
 HaloBuffAddType.HaloTankNormalAttack   = 3
 HaloBuffAddType.HaloDeffence           = 4
 HaloBuffAddType.HaloHp                 = 5
 HaloBuffAddType.HaloCrit               = 6
 HaloBuffAddType.HaloHit                = 7
 HaloBuffAddType.HaloDodge              = 8

 --进阶加成类型
 ExclusiveType = {}
 ExclusiveType.kStartEnergy = 1 --初始能量加成
 ExclusiveType.kFinalDefend = 2 --最终减伤
 ExclusiveType.kExecute     = 3 --对生命值低于30%的目标造成的伤害提升30%
 ExclusiveType.kFullHp      = 4 --自身满血时伤害提升20%
 ExclusiveType.kAngry       = 5 --己方没阵亡一个单位伤害提升15%
 ExclusiveType.kGrow        = 6 --自身血量每降低10% 伤害提升10%
 ExclusiveType.kArmorRise   = 7 --对有破甲BUFF的目标造成的伤害提升50%
 ExclusiveType.kBurnRise    = 8 --对有灼烧BUFF的目标造成的伤害提升50%


 --暂停所有动作
 function  skillPauseMembers()
    if not IsPauseMemberBeforePlaySkl then
        return
    end

     for i=1,5 do
         if MemberAttackList[i] ~= nil and MemberAttackList[i].m_isDead == false and MemberAttackList[i].m_fsm:getState() ~= "skill" and MemberAttackList[i].m_fsm:getState() ~= "ready" then
             MemberAttackList[i]:pause()
             MemberAttackList[i]:getMemberAnimation():pause()
         end
     end
     for i=1,7 do
         if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false and MemberDeffenceList[i].m_fsm:getState() ~= "skill" and MemberDeffenceList[i].m_fsm:getState() ~= "ready" then
             MemberDeffenceList[i]:pause()
             MemberDeffenceList[i]:getMemberAnimation():pause()
         end
     end
     for i=1,20 do
         if AllFlyBullet[i] ~= nil then
            AllFlyBullet[i]:pause()
         end
     end
 end
 --恢复所有动作
 function  skillResumeMembers()
    if not IsPauseMemberBeforePlaySkl then
        return
    end
        
     for i=1,5 do
         if MemberAttackList[i] ~= nil and MemberAttackList[i].m_isDead == false then
             MemberAttackList[i]:resume()
             MemberAttackList[i]:getMemberAnimation():resume()
         end
     end
     for i=1,7 do
         if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false then
             MemberDeffenceList[i]:resume()
             MemberDeffenceList[i]:getMemberAnimation():resume()
         end
     end
     for i=1,20 do
         if AllFlyBullet[i] ~= nil then
            AllFlyBullet[i]:resume()
         end
     end
 end

 g_spriteProgress = {}
 g_allControlDesk = {}
 function pauseTheBattle(bIsWithOutAnimate)
    g_isBattlePaused = true
     for i=1,5 do
         if MemberAttackList[i] ~= nil and MemberAttackList[i].m_isDead == false then
             
             if not bIsWithOutAnimate then
                 MemberAttackList[i].m_member:pause()
                 MemberAttackList[i]:getMemberAnimation():pause()
             else
                 MemberAttackList[i]:stopHeroAnimation()
                 MemberAttackList[i]:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
             end
             print("attack  "..i.."  MemberAttackList is paused! ")
         end
     end
     for i=1,7 do
         if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false then
             MemberDeffenceList[i]:pause()
             if not bIsWithOutAnimate then
                 MemberDeffenceList[i].m_member:pause()
                 MemberDeffenceList[i]:getMemberAnimation():pause()
             else
                MemberDeffenceList[i]:stopMonsterAnimation()
                MemberDeffenceList[i]:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
             end
             print("Deffence  "..i.."  MemberAttackList is paused! ")
         end
     end

     -- for i=1,3 do
     --    if g_spriteProgress[i]~=nil then
     --        g_spriteProgress[i]:pauseCooling()
     --    end
     -- end
     for k,v in pairs(g_spriteProgress) do
        v:pauseCooling()
     end

     for i =1,5 do
        if g_allControlDesk[i]~=nil then
            g_allControlDesk[i]:pauseDesk()
        end
     end

     for i=1,20 do
         if AllFlyBullet[i] ~= nil then
            AllFlyBullet[i]:pause()
         end
     end
 end

 function resumeTheBattle()
    g_isBattlePaused = false
     skillResumeMembers()
     for i=1,5 do
         if MemberAttackList[i] ~= nil and MemberAttackList[i].m_isDead == false then
             MemberAttackList[i]:resume()
             MemberAttackList[i].m_member:resume()
             MemberAttackList[i]:getMemberAnimation():resume()
         end
     end
     for i=1,7 do
         if MemberDeffenceList[i] ~= nil and MemberDeffenceList[i].m_isDead == false then
             MemberDeffenceList[i]:resume()
             MemberDeffenceList[i].m_member:resume()
             MemberDeffenceList[i]:getMemberAnimation():resume()
             print("Deffence  "..i.."  MemberAttackList is resumed! ")
         end
     end
     -- for i=1,3 do
     --    if g_spriteProgress[i]~=nil then
     --        g_spriteProgress[i]:resumeCooling()
     --    end
     -- end
     for k,v in pairs(g_spriteProgress) do
        v:resumeCooling()
     end

     for i =1,5 do
        if g_allControlDesk[i]~=nil then
            g_allControlDesk[i]:resumeDesk()
        end
     end
 end

 --伤害变化范围
 function damageRandom(_seed)
     return math.random(97,103)/100
 end
 
 --是否触发 用于一些触发性结果的计算  如闪避 暴击 等
 --参数 _probability  触发的概率 0-100
 --返回值 bool   是否触发
 function isTrigger(_probability,_totalNum,_seed)
    if _probability <= 0 then
        return false
    end

    if math.random(_totalNum) <= _probability then
        return true
    end
    return false
 end

 --沉默击晕是否命中
 function isStunHit(eLvl, sLvl, eSeed)
    local hitProbability = 1 - math.max(math.min((eLvl-sLvl)*0.04, 0.8), 0)
    return isTrigger(hitProbability*100, 100, eSeed)
 end                       

 --是否胜利
 function isBattleWin()
     if AllBattleStep < CurBattleStep then
         return true
     else
         return false
     end
 end

 --**************************************************** 
 --PVP相关

 --PVP战斗信息
 PVPData = {}
 --敌人ID
 EnermyID = 0
 --PVP战斗结果
 PVPResult = false
 --是否回放
 IsPlayback = false
 
 --随机数种子池
 RandomSeedPool = {}
 --PVP战斗种子
 RandomSeed = 0 

IsStartFight = false

IsFightAgain = false

-- AllNAtkTime = {["atk"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}, ["def"] = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}}

