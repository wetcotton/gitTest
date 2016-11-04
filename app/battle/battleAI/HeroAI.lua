--
-- Author: liufei
-- Date: 2014-11-04 11:55:06
--
require("app.battle.BattleInfo")
require("app.data.GameData")

local MemberHero = require("app.battle.battleMember.MemberHero")
local BulletAI = require("app.battle.battleAI.BulletAI")
local SkillAI = require("app.battle.battleAI.SkillAI")
local TalkNode = require("app.battle.battleUI.TalkNode")

local HeroAI = class("HeroAI", MemberHero)


function HeroAI:ctor(_hero,_type)
    self.hero  = _hero
    self.fightPos = _hero.pos
    self.m_posType = _type
    HeroAI.super.ctor(self,_hero)
    self.m_canAttack = true
    self.m_targetIndex = 1
    self.m_enermy = nil
    self.m_moveAction = nil
    self.m_isRemoved = false
    self.m_isShowSkill = false

    self.skillListIdx = 1 --技能预设中列表中的顺序，当前放到第几个了（四个预设技能轮流放）
   
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(...)
           self:update()
        end)
    self:scheduleUpdate()
    if self.makeType == ModelMakeType.kMake_Coco then
        local function mCallback(_animation, _type, _name)
            self:movementCallbackCoco(_animation, _type, _name)
        end
        self:getMemberAnimation():setMovementEventCallFunc(mCallback)
    else
        self:getMemberAnimation():registerSpineEventHandler(function (event)
            self:movementCallbackSpine(event.animation)
        end, 2)
    end
    self:addStateMachine()

end

--找到最进的敌人
function HeroAI:findIndex()
    local ret = 8  --找不到敌人的情况，返回一个大于7的值
    local targetList = self.enermyList
    local srotList = {}
    for i=1,7 do
        local _beAttacker = targetList[i]
        if _beAttacker ~= nil and _beAttacker.m_isDead == false then
            local startPos = nil
            local  targetPosX = _beAttacker:getHitPosition().x
            local  targetPosY = _beAttacker:getHitPosition().y
            local offSets = string.split(self.m_bltPos,"|")
            local xOffset = tonumber(offSets[1])
            local yOffset = tonumber(offSets[2])
            if self:getPositionX() < targetPosX then
                startPos = cc.p(self:getPositionX()+xOffset*self.m_member:getContentSize().width*self.m_scaleNum, self:getPositionY()+yOffset*self.m_member:getContentSize().height*self.m_scaleNum)
            else
                startPos = cc.p(self:getPositionX()-xOffset*self.m_member:getContentSize().width*self.m_scaleNum, self:getPositionY()+yOffset*self.m_member:getContentSize().height*self.m_scaleNum)
            end

            --local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
            local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(0, 2))  --改为计算x轴距离
            srotList[#srotList+1] = {_index = i,_distance = distance}
        end
    end

    if #srotList>0 then
        table.sort( srotList, function (val_1,val_2)
            return val_1._distance<val_2._distance
        end )
        ret = srotList[1]._index
    end

    local nearestEnemy = nil
    if targetList[ret]~=nil then
        nearestEnemy = targetList[ret]
    end

    local farthestEnemy = nil
    if #srotList>0 then
        farthestEnemy = targetList[srotList[#srotList]._index]
    end

    return {
                _nearestIndex = ret,
                _nearestEnemy = nearestEnemy,
                _farthestEnemy = farthestEnemy,
                _srotList = srotList
            }
end

function HeroAI:update()
 
    if self.m_targetIndex>7 then
        return
    end

    if self.m_fsm:getState() == "dead" then
        return
    end

    if self.m_fsm:getState() == "stun" then
                
        if self.m_stunNum <= 0 then         
            self:doEvent("goIdle")
            self:resume()
            if self.m_posType == MemberPosType.attackType and self.m_memberType ~= MemberAllType.kMemberTank then
                local g_instance = nil
                if startFightBattleScene.Instance~=nil then
                    g_instance = startFightBattleScene.Instance
                else
                    g_instance = cc.Director:getInstance():getRunningScene()
                end
                g_instance.allControlDesk[self.fightPos]:resumeDesk()
            end
        end
        return
    end
    if self.m_stunNum > 0 and self.m_fsm:getState() ~= "stun" and self.m_isDead ~= true then
        if self.m_fsm:getState() == "win" then
           self.m_stunNum = 0
        else
           self:doEvent("goStun")
        end
        return
    end

    if self.m_fsm:getState() == "walk" then
        if self.enermyList[self.m_targetIndex] ~= nil then
            self.m_enermy = self.enermyList[self.m_targetIndex]
            if self.m_enermy.m_isDead == false then
                --计算距离
                if (self.m_enermy:getPositionX() - self:getPositionX()) <= self:getAttackRect() then
                      self:doEvent("goIdle")
                      self:stopAction(self.m_moveAction)
                end
            else
                self.m_targetIndex  = self:findIndex()._nearestIndex
                if self.m_targetIndex>7 then
                    self:stopAction(self.m_moveAction)
                    self:doEvent("goWin")
                end
            end
        else
            self.m_targetIndex  = self:findIndex()._nearestIndex
            if self.m_targetIndex>7 then
                self:stopAction(self.m_moveAction)
                self:doEvent("goWin")
            end
        end
        return
    end

    if self.m_fsm:getState() == "attack" then
        if self.m_enermy.m_isDead == true then
            self:stopHeroAnimation()
            self:doEvent("goWalk")
        end
        return
    end
    if self.m_fsm:getState() == "idle" then
        if  self.m_enermy == nil   or  self.m_enermy.m_isDead ~= false or ((self.m_enermy:getPositionX() - self:getPositionX()) > self:getAttackRect())then
                self:doEvent("goWalk")
                return
        end
        if self.m_canAttack then
                self:doEvent("goAttack")           
        end
    end

end

function HeroAI:movementCallbackCoco(_animation, _type, _name)
    if (_type == ccs.MovementEventType.loopComplete or _type == ccs.MovementEventType.complete) and _name == MemberAnimationType.kMemberAnimationAttack then
        self:doEvent("goIdle")
        return
    end
    if  _type ~= ccs.MovementEventType.start and _name == MemberAnimationType.kMemberAnimationDead then
        self:stopHeroAnimation()
        self.progress:setVisible(false) 
        local fadeout = cc.FadeOut:create(1)
        self.m_member:runAction(fadeout)
        local function removeHero()
            self.m_isRemoved = true
        end
        self:runAction(transition.sequence({
                                                cc.DelayTime:create(1),
                                                cc.CallFunc:create(removeHero)
                                           }))
        return
    end
    if _type ~= ccs.MovementEventType.start and _name == MemberAnimationType.kMemberAnimationHit then
        self:doEvent("goIdle")
        return
    end
end

function HeroAI:movementCallbackSpine(_animation)
    if _animation == MemberAnimationType.kMemberAnimationAttack and self.m_fsm:getState() ~= "idle" then
        self:doEvent("goIdle")
        return
    end
    if  _animation == MemberAnimationType.kMemberAnimationDead then
        self:stopHeroAnimation()
        self.progress:setVisible(false) 
        local fadeout = cc.FadeOut:create(1)
        self.m_member:runAction(fadeout)
        local function removeHero()
            self.m_isRemoved = true
        end
        self:runAction(transition.sequence({
                                                cc.DelayTime:create(1),
                                                cc.CallFunc:create(removeHero)
                                           }))
        return
    end
    if _animation == MemberAnimationType.kMemberAnimationHit and self.m_fsm:getState() ~= "idle" then
        self:doEvent("goIdle")
        return
    end
end


function HeroAI:effectAttack() 
    if  self.m_enermy == nil   or  self.m_enermy.m_isDead ~= false or self.m_fsm:getState() == "skill"  then
        return
    end
    if self.m_attackType == MemberAttackType.kAttackLong then
        self.m_enermy:beAttacked(self.m_attackInfo)
    else
        local g_instance = nil
        if startFightBattleScene.Instance~=nil then
            g_instance = startFightBattleScene.Instance
        else
            g_instance = cc.Director:getInstance():getRunningScene()
        end
        local bullet = BulletAI.new(self.selfList[self.fightPos],self.m_enermy, self.m_bulletStr)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos])
        -- if self.m_posType  == MemberPosType.defenceType then
        --    AllNAtkTime["def"][self.fightPos] = AllNAtkTime["def"][self.fightPos] + 1
        -- else
        --    AllNAtkTime["atk"][self.fightPos] = AllNAtkTime["atk"][self.fightPos] + 1
        -- end
    end
    -- g_instance:checkBugleBuffer()
end

function HeroAI:attackIntervalControl()
    self.m_canAttack = true
end

function HeroAI:beAttacked(_attackInfo)
    local trueDamage = self:CalculateBeAttacked(_attackInfo)
    if tonumber(trueDamage) <= 0 then
        return
    end
    self:afterBeAttack()
end

function HeroAI:afterBeAttack()
    if self.m_fsm:getState() == "skill" then
        return
    end
    if self.m_isDead and self.m_fsm:getState() ~= "dead" then
       self:doEvent("goDead")
    end
    if self.m_fsm:getState() ~= "walk" and self.m_fsm:getState() ~= "skill" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "attack" and self.m_fsm:getState() ~= "stun" and self.m_isDead == false then
       self:doEvent("goHit")
    end
end

function HeroAI:playSkill(_skillType)
    self:resume()
    self:getMemberAnimation():resume()
    self:stopAction(self.m_moveAction)
    if self.m_fsm:getState() == "attack" then
        self:stopAllActions()
        self.m_canAttack = true
    end
    
    self.curSkillType = _skillType
    self.curSkillID = self.m_energySkills[_skillType].id

    if self.curSkillType ~= MemberSkillType.kSkillTankMain then --统计非主炮的主动技能for 作弊校验
        self.sklPlayCnt = self.sklPlayCnt + 1 
    end    
    
    --对话
    self.m_talkNode:addTalk({member = self, talkType = TalkType.FireSkill, checkId = self.curSkillID})
    self:doEvent("goSkill")
    --收集信息
    -- local message = {}
    -- message["type"] = BattleMessageType.kMessageSkill
    -- message["initiativeId"] = self.m_attackInfo.tptId
    -- message["initiativeName"] = self.m_attackInfo.tptName
    -- message["skillId"] = self.curSkillID
    -- message["skillName"] = skillData[tonumber(self.curSkillID)]["sklName"]
    -- BattleMessageBox:addMessage(message)
end

function HeroAI:showSkill()
    self.m_isShowSkill = true
    local skill = SkillAI.new(self.selfList[self.fightPos])
    :addTo(self)
end

function HeroAI:afterSkill()
    if self.m_isDead == false then
        if self.m_fsm:getState() ~= "ready" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "idle" then
            self:doEvent("goIdle")
        end
        if CurFightBattleType == FightBattleType.kType_PVP or isBattleWin() == false or CurFightBattleType == FightBattleType.kType_Expedition then
            if IsAllMonsterDead == false and self.m_memberType ~= MemberAllType.kMemberTank and self.m_posType == MemberPosType.attackType and BattleSurplusTime > 0 then
                local g_instance = nil
                if startFightBattleScene.Instance~=nil then
                    g_instance = startFightBattleScene.Instance
                else
                    g_instance = cc.Director:getInstance():getRunningScene()
                end
                if self.curSkillType ~= MemberSkillType.kSkillTankMain then
                    g_instance.allControlDesk[self.fightPos]:resumeDesk() --竞技场这里需要resume
                end
            end
        end
    else
        if self.m_fsm:getState() ~= "dead" then
            self:doEvent("goDead")
        end
    end
end

function HeroAI:beSkilled(_skillInfo, _attackInfo)
    
    self:CalculateBeSkilled(_skillInfo, _attackInfo)

    if self.m_fsm:getState() == "skill" then
        return
    end
    if self.m_isDead and self.m_fsm:getState() ~= "dead" then
       self:doEvent("goDead")
    end
    if self.m_fsm:getState() ~= "walk" and self.m_fsm:getState() ~= "skill" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "attack" and self.m_fsm:getState() ~= "stun" and self.m_isDead == false then
       self:doEvent("goHit")
    end
end

function HeroAI:addStateMachine()
    self.m_fsm = {}
    cc.GameObject.extend(self.m_fsm)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()

    self.m_fsm:setupState({
        -- 初始状态
        initial = "ready",
        
        -- 事件和状态转换
        events = {
            {name = "goReady",    from = {"stun","walk","hit","idle","skill","win"},                              to = "ready" },
            {name = "goWalk",     from = {"stun","idle", "attack","ready","walk","win"},                  to = "walk" },--行走
            {name = "goAttack",   from = {"stun","idle", "walk"},                            to = "attack"},--攻击
            {name = "goDead",     from = {"stun","idle", "walk", "attack","hit","skill","win"},            to = "dead"},--死亡
            {name = "goIdle",     from = {"stun","walk", "attack","skill","hit",},            to = "idle"},--静止
            {name = "goWin",      from = {"stun","walk", "attack","idle","hit","skill","ready"},             to = "win"},--胜利
            {name = "goSkill",    from = {"stun","walk", "attack", "idle","hit","skill"},            to = "skill"},--技能
            {name = "goHit",      from = {"stun","idle", "attack","hit"},                    to = "hit"},--受击
            {name = "goStun",      from = {"stun","idle", "attack","hit","skill","walk"},                    to = "stun"},--击晕
            --{name = "goDefeat",   from = {"walk", "attack", "hit"},                   to = "defeat"},--失败
        }, 

        -- 状态转变后的回调 
        callbacks = {
            onready = function (event) self:ready() end,
            onwalk = function (event) self:walk() end,
            onattack = function (event) self:attack() end,
            ondead = function (event) self:dead() end,
            onidle = function (event) self:idle() end,
            onwin = function (event) self:win() end,
            onskill = function (event) self:skill() end,
            onhit = function (event) self:hit() end,
            onstun = function (event) self:stun() end,
            
            onleaveready = function (event) self:leaveready() end,
            onleavewalk = function (event) self:leavewalk() end,
        },
    })
end

function HeroAI:doEvent(event, ...)   
    self.m_fsm:doEvent(event, ...)
end
function HeroAI:goFight()
    print("goFight-----------------------")
    if self.m_fsm:getState() == "skill" or  self.m_fsm:getState() == "walk" then
        return
    end
    self:doEvent("goWalk")
    if self.m_posType  == MemberPosType.attackType then
        print("攻击方战斗")
        self.selfList = MemberAttackList
        self.enermyList = MemberDeffenceList
        print(self.m_memberType)
        if self.m_memberType == MemberAllType.kMemberTank then
            self:addAutoAI()
        else
                local g_instance = nil
                if startFightBattleScene.Instance~=nil then
                    g_instance = startFightBattleScene.Instance
                else
                    g_instance = cc.Director:getInstance():getRunningScene()
                end
          if g_instance.allControlDesk[self.fightPos] ~= nil and g_instance.allControlDesk[self.fightPos].energyProgress ~= nil then
              g_instance.allControlDesk[self.fightPos]:resumeDesk()
          end
        end
    elseif self.m_posType  == MemberPosType.defenceType then
        -- print("防守方战斗")
        self.selfList = MemberDeffenceList
        self.enermyList = MemberAttackList
        --PVP防守方
        self:addAutoAI()
    end
end

function HeroAI:addAutoAI()
    if self.aotoAllEnergy ~= nil or self.m_fsm:getState() == "ready" then
        return
    end
    local  hasUnlockSkill = false
    for k,v in pairs(self.m_energySkills) do
        if v ~= nil and v.sts == 1 then
           hasUnlockSkill = true
        end
    end
    self.aotoAllEnergy = 0
    if self.m_exclusiveInfo[ExclusiveType.kStartEnergy] then --竞技场加上防守方初始技能
        self.aotoAllEnergy = self.aotoAllEnergy + self.m_exclusiveInfo[ExclusiveType.kStartEnergy]
    end
    
    if self.m_posType  == MemberPosType.defenceType then
        print("防守方初始能量："..self.aotoAllEnergy)
    end    
    
    if self.m_memberType == MemberAllType.kMemberHero then
        self.startIndex = 1
        self.curSkillIndex = self:getFirstSkillIdx()
    else
        self.startIndex = 6
        self.curSkillIndex = self:getFirstSkillIdx()
    end
    -- print("self.curSkillIndex:"..self.curSkillIndex)
    local function refreshEnergy()
        print("能量回复")
        local function getNextAutoSkill()
            -- self.curSkillIndex = self.curSkillIndex + 1
            self.curSkillIndex = self:getNextSkillIdx()
            if self.m_energySkills[self.curSkillIndex] == nil then
                self.curSkillIndex = self.startIndex
            end
            if self.m_energySkills[self.curSkillIndex].sts == -1 or self.m_energySkills[self.curSkillIndex].sts == 0 then
                getNextAutoSkill()
            end
        end
        --   -1表示从未激活过，0表示更换装备后，战车星级降低，技能变为未激活状态
        
        print(self.curSkillIndex)
        printTable(self.m_energySkills)
        if self.m_energySkills[self.curSkillIndex].sts == -1 or self.m_energySkills[self.curSkillIndex].sts == 0 then
            getNextAutoSkill()
        end

        if self.m_attackInfo.tptName=="黄小宁" then
            print(self.m_energySkills[self.curSkillIndex].energy)
            print(self.aotoAllEnergy)
        end
        

        if self.aotoAllEnergy >= self.m_energySkills[self.curSkillIndex].energy then
            if self.m_attackInfo.tptName=="黄小宁" then
                print(self.curSkillIndex)
                print("技能已满，可以放技能了")
            end
            -- print("技能已满，可以放技能了")
            self:playSkill(self.curSkillIndex)
            self.aotoAllEnergy =  self.aotoAllEnergy - self.m_energySkills[self.curSkillIndex].energy
            getNextAutoSkill()
        end
    end

    local passTime = 0
    -- print("防守恢复速度："..self.recoverSpeed)
    local seq = transition.sequence({
      cc.DelayTime:create(self.recoverSpeed),
      cc.CallFunc:create(function()
            
            -- print("passTime:"..passTime)
            if self.m_fsm:getState() ~= "dead" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "ready" then
                
                --modify by jevon 2016/7/27
                --修复bug,此bug曾导致竞技场防守方技能恢复较快，原因是防守方在放技能的时候没有暂停技能恢复，而进攻方是有暂停的
                -- self.aotoAllEnergy = self.aotoAllEnergy + 1 --(此行为问题代码，下面四行为修复代码)
                if self.curSkillType == MemberSkillType.kSkillTankMain or self.m_fsm:getState() ~= "skill" then
                    self.aotoAllEnergy = self.aotoAllEnergy + 1
                end               

                if self.aotoAllEnergy > 100 then
                    self.aotoAllEnergy = 100
                end
            end
            -- print("能量："..self.aotoAllEnergy)
            --该bug曾导致放技能时主炮停止冷却
            if  self.m_fsm:getState() ~= "dead" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "stun" and self.m_fsm:getState() ~= "ready" then
                -- self.m_gagNum 技能受到沉默值值限制，但是主炮不受沉默值限制
                if self.m_fsm:getState() ~= "skill" and hasUnlockSkill == true and self.m_gagNum <= 0 then
                    refreshEnergy()
                end
                --主炮冷却恢复不受技能影响
                if self.m_memberType ~= MemberAllType.kMemberHero then
                    passTime = passTime + self.recoverSpeed
                    if passTime >= self.m_attackInfo.mainCD then
                        if self.m_fsm:getState() ~= "skill" then
                           self:playSkill(MemberSkillType.kSkillTankMain)
                           passTime = 0
                        else
                           passTime = self.m_attackInfo.mainCD
                        end
                    end
                end
            end
      end),
    })
    self.auotoAction = cc.RepeatForever:create(seq)
    self.m_member:runAction(self.auotoAction)
end

function HeroAI:ready()

    if self.m_moveAction ~= nil then
        self:stopAction(self.m_moveAction)
    end

    self:clearBuff()
    self.m_isReady = false
    self.m_targetIndex = 0
    self.m_enermy = nil
    self.enermyList = {}
    local function moveStop()
        self:stopHeroAnimation()
        self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
        self.m_isReady = true
        if startFightBattleScene.Instance~=nil then
            startFightBattleScene.Instance:checkIsAllReady()
        else
            local g_instance = nil
            if startFightBattleScene.Instance~=nil then
                g_instance = startFightBattleScene.Instance
            else
                g_instance = cc.Director:getInstance():getRunningScene()
            end
            g_instance:checkIsAllReady()
        end
        
    end
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationWalk)
    local  tarPoint = nil
    if self.m_posType  == MemberPosType.attackType then
        if CurBattleStep == 1 then
            tarPoint = cc.p(AttackPositions[self.fightPos][1],AttackPositions[self.fightPos][2])
        else
            tarPoint = cc.p(AttackPositions[self.fightPos][1],AttackPositions[self.fightPos][2])
        end
    elseif self.m_posType  == MemberPosType.defenceType then
        tarPoint = cc.p((display.width/2 - AttackPositions[self.fightPos][1]) + display.width/2, AttackPositions[self.fightPos][2])
        if CurFightBattleType == FightBattleType.kType_Expedition and cc.Director:getInstance():getRunningScene().IsFirstIn == false then
            self:stopHeroAnimation()
            self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
        end
    end
    local startMove = nil
    if CurFightBattleType == FightBattleType.kType_Expedition and cc.Director:getInstance():getRunningScene().curSupplyState == SupplyState.kSupply_In then
        startMove = transition.sequence({
                              cc.MoveTo:create(StartMoveTime*StartSpeedAdd*2,tarPoint),
                              cc.CallFunc:create(moveStop)
                            })
        self:runAction(startMove)
    else
        startMove = transition.sequence({
                              cc.MoveTo:create(StartMoveTime*StartSpeedAdd,tarPoint),
                              cc.CallFunc:create(moveStop)
                            })
        self:runAction(startMove)
    end
    
    self:showDust()
    
end

function HeroAI:clearBuff()
    for bk,bv in pairs(self.buffShowing) do
        self.buffControl:clearBuff(self,bk)
    end
    for sk,sv in pairs(self.m_allShields) do
        self.buffControl:clearShield(self,sk)
    end
end

function HeroAI:walk()
    self:showDust()
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationWalk)
    local moveTime = (math.abs(display.width - self:getPositionX())*StartMoveTime)/(display.width/2)
    if self.m_posType == MemberPosType.attackType then
         self.m_moveAction = cc.MoveTo:create(moveTime,cc.p(display.width,self:getPositionY()))
    elseif self.m_posType == MemberPosType.defenceType then
         self.m_moveAction = cc.MoveTo:create(moveTime,cc.p(0,self:getPositionY()))
    end
    self:runAction(self.m_moveAction)
end

function HeroAI:leavewalk()
    self:hideDust()
end

function HeroAI:leaveready()
    self:hideDust()
end

function HeroAI:attack()
    local tab = self:findIndex()
    self.m_targetIndex , self.m_enermy= tab._nearestIndex,tab._nearestEnemy
    if not self.m_enermy then
        error("普攻找不到敌人")
        return
    end
    local function normalAttack()
           self:stopHeroAnimation()
           self:playHeroAnimation(MemberAnimationType.kMemberAnimationAttack)
           self:performWithDelay(self.effectAttack,tonumber(self.m_befAttack))--攻击动画生效时间
           self:performWithDelay(self.attackIntervalControl,self.m_attackInfo.attackInterval)--攻击间隔
           self.m_canAttack = false
           
           if self.m_posType == MemberPosType.attackType and self.m_memberType == MemberAllType.kMemberTankWithHero then
            local g_instance = nil
            if startFightBattleScene.Instance~=nil then
                g_instance = startFightBattleScene.Instance
            else
                g_instance = cc.Director:getInstance():getRunningScene()
            end
             g_instance.allControlDesk[self.fightPos].subProgress:startCooling()
           end
    end 
    normalAttack()
end
function HeroAI:dead()
    --BUFF Skill
    -- for k,v in pairs(self.buffShowing) do
    --      v.buffEff:removeSelf()
    --      v = nil
    -- end 
    self:clearBuff()
    self:stopAction(self.m_moveAction)
    self:resume()
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationDead)
    
    if self.auotoAction then
        self.m_member:stopAction(self.auotoAction)
    end
    
    --收集信息
    -- local message = {}
    -- message["type"] = BattleMessageType.kMessageDead
    -- message["initiativeId"] = self.m_attackInfo.tptId
    -- message["initiativeName"] = self.m_attackInfo.tptName
    -- BattleMessageBox:addMessage(message)
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    g_instance:afterOneHeroDie(self)
    local isAllDead = true

    local tmplist = nil
    if self.m_posType == MemberPosType.defenceType then
        tmplist = MemberDeffenceList
    else
        tmplist = MemberAttackList
    end
    for k,v in pairs(tmplist) do
        if v~= nil and v.m_isDead == false then
            isAllDead = false
        end
    end
    if isAllDead == true then
        if CurFightBattleType == FightBattleType.kType_PVP then
            if self.m_posType == MemberPosType.defenceType then
                PVPResult = true
            else
                PVPResult = false
            end
            g_instance:afterPVPOver()
        elseif CurFightBattleType == FightBattleType.kType_Expedition then
            if self.m_posType == MemberPosType.defenceType then
                g_instance:afterAllMonsterDie()
            else
                g_instance:afterAllHeroDie()
            end
        else
            local g_instance = nil
            if startFightBattleScene.Instance~=nil then
                g_instance = startFightBattleScene.Instance
            else
                g_instance = cc.Director:getInstance():getRunningScene()
            end
            g_instance:afterAllHeroDie()
        end
    end
end
function HeroAI:idle()
    self:stopHeroAnimation()
    if self.makeType == ModelMakeType.kMake_Coco then
        self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
    else
        self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle2)
    end
end
function HeroAI:win()
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
end
function HeroAI:skill()
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    local delay = self.m_energySkills[self.curSkillType].bef
    if self.curSkillType ~= MemberSkillType.kSkillTankMain then
        g_instance.skillLayer:setVisible(true)
        skillPauseMembers()
    end

    self:performWithDelay(function()
        if self.m_isDead == false then
            self:showSkill()
        else
            if self.m_fsm:getState() ~= "dead" then
                self:doEvent("goDead")
            end
        end
    end, delay)
    --技能音效
    if tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= 0 then
        local audioNode = display.newNode()
        :addTo(self)
        audioNode:runAction(transition.sequence({
                                                  cc.DelayTime:create(tonumber(skillData[self.curSkillID]["sklsounddelay"])),
                                                  cc.CallFunc:create(function()
                                                     audio.playSound("audio/musicEffect/skillEffect/"..skillData[self.curSkillID]["sklsoundres"]..".mp3")
                                                  end)
                                               }))
    end
    
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberSkillAnimationType[self.curSkillType])
    if self.m_posType == MemberPosType.attackType and self.m_memberType ~= MemberAllType.kMemberTank then
        if self.curSkillType ~= MemberSkillType.kSkillTankMain then
            g_instance.allControlDesk[self.fightPos]:pauseSkillItems() --竞技场这里还是暂停
        end
    end
end
function HeroAI:hit()
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationHit)
end
function HeroAI:stun()
    self:stopAction(self.m_moveAction)
    self.m_canAttack = true
    self:stopHeroAnimation()
    self:playHeroAnimation(MemberAnimationType.kMemberAnimationIdle)
end

function HeroAI:showDust()
    if self.m_memberType ~= MemberAllType.kMemberHero and self.m_posType == MemberPosType.attackType and self.m_dustEff ~= nil then
        self.m_dustEff:setVisible(true)
    end
end

function HeroAI:hideDust()
    if self.m_dustEff ~= nil then
        self.m_dustEff:setVisible(false)
    end
end

 --技能预设
 function HeroAI:getNextSkillIdx(_sortList)
    if CurFightBattleType ~= FightBattleType.kType_PVP then
        return (self.curSkillIndex + 1)
    end

    self.skillListIdx = self.skillListIdx + 1
    -- if self.m_memberType == MemberAllType.kMemberHero then
    --     if self.skillListIdx>4 then
    --         self.skillListIdx = 1
    --     end
    -- else
    --     if self.skillListIdx>2 then
    --         self.skillListIdx = 1
    --     end
    -- end
    if self.skillListIdx>4 then
        self.skillListIdx = 1
    end
    print("getNextSkillIdx.."..self.skillListIdx)
    -- _sortList = {2,1,1,2}
    local _sortList = {}
      if self.hero.sklOrder==nil or self.hero.sklOrder=="" then
        if self.hero.m_memberType == MemberAllType.kMemberHero then
          _sortList = {1,2,3,4}
        else
          _sortList = {1,2,1,2}
        end
      else
        local sklOrderArr = string.split(self.hero.sklOrder, "|")
        for i=1,#sklOrderArr do
          _sortList[i] = tonumber(sklOrderArr[i])
        end
      end

    local curSkillIndex
    if self.m_memberType == MemberAllType.kMemberHero then
        curSkillIndex = _sortList[self.skillListIdx]
    else
        curSkillIndex = _sortList[self.skillListIdx] + 5
    end

    return curSkillIndex
 end

 function HeroAI:getFirstSkillIdx()
    if CurFightBattleType ~= FightBattleType.kType_PVP then
        if self.hero.m_memberType == MemberAllType.kMemberHero then
            return 1
        else
            return 6
        end
    end
    local _sortList = {}
      if self.hero.sklOrder==nil or self.hero.sklOrder=="" then
        if self.hero.m_memberType == MemberAllType.kMemberHero then
          _sortList = {1,2,3,4}
        else
          _sortList = {1,2,1,2}
        end
      else
        local sklOrderArr = string.split(self.hero.sklOrder, "|")
        for i=1,#sklOrderArr do
          _sortList[i] = tonumber(sklOrderArr[i])
        end
      end
    local firstIdx = 0
    if self.hero.m_memberType == MemberAllType.kMemberHero then
        firstIdx = _sortList[1]
    else
        firstIdx = _sortList[1] + 5
    end 
    return firstIdx
 end

return HeroAI 