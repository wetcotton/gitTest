--
-- Author: liufei
-- Date: 2014-11-04 11:55:28
--
require("app.battle.BattleInfo")

local MemberMonster = require("app.battle.battleMember.MemberMonster")
local SkillAI = require("app.battle.battleAI.SkillAI")
local BulletAI = require("app.battle.battleAI.BulletAI")
local DropBox = require("app.battle.battleUI.DropBox")

local MonsterHitType = {
                        kHitAttack = 1,
                        kHitSkill  = 2,  
} 

local MonsterAI = class("MonsterAI", MemberMonster)

function MonsterAI:ctor(_monster,_level,_pos,_type)
    self.fightPos = _pos
    self.m_posType = _type
	MonsterAI.super.ctor(self,_monster,_level)
    self.m_canAttack = true
    self.m_targetIndex = 1
    self.m_enermy = nil
    self.m_moveAction = nil
    self.m_isRemoved = false
    self.m_hasGoFight = false
    self.m_isShowSkill = false
    self.NatkTime = 0
    self.m_hitType = MonsterHitType.kHitAttack

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(...)
            self:update()
    end)
    self.scheduleAction =  self:scheduleUpdate()
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

    self.m_isInAdjust = false
    self:addStateMachine()
end

--找到最进的敌人
function MonsterAI:findIndex()
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
            local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(0, 2))   --改为计算x轴距离
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


function MonsterAI:update()
    if self.m_fsm:getState() == "dead" then
        return
    end

    if self.m_fsm:getState() == "stun" then
        if self.m_stunNum <= 0 then
            self:doEvent("goIdle")
        end
        return
    end
     if self.m_stunNum > 0 and self.m_fsm:getState() ~= "stun" then
        if self.m_fsm:getState() == "win" then
           self.m_stunNum = 0
        else
           self:doEvent("goStun")
        end
        return
    end

    if self.m_fsm:getState() == "walk" then
        if MemberAttackList[self.m_targetIndex] ~= nil then
            self.m_enermy = MemberAttackList[self.m_targetIndex]
            if self.m_enermy.m_isDead == false then
                --计算距离
                if (self:getPositionX() - self.m_enermy:getPositionX()) <= self:getAttackRect() then
                      self:doEvent("goIdle")
                      self:stopAction(self.m_moveAction)
                end
            else
                self.m_targetIndex  = self:findIndex()._nearestIndex
                if self.m_targetIndex>5 then
                   self:stopAction(self.m_moveAction)
                   self:doEvent("goWin")
                end
            end
        else
            self.m_targetIndex  = self:findIndex()._nearestIndex
            if self.m_targetIndex>5 then
                self:stopAction(self.m_moveAction)
                self:doEvent("goWin")
            end
        end
        return
    end

    if self.m_fsm:getState() == "attack" then
        if self.m_enermy.m_isDead == true then
            self:stopMonsterAnimation()
            self:doEvent("goWalk")
        end
        return
    end

    if self.m_fsm:getState() == "idle" then
        if  self.m_enermy == nil   or  self.m_enermy.m_isDead ~= false or ((self:getPositionX() - self.m_enermy:getPositionX()) > self:getAttackRect()) then
            self:doEvent("goWalk")
            return
        end
        if self.m_canAttack then
            self:doEvent("goAttack")
            return
        end
    end

end

function MonsterAI:movementCallbackCoco(_animation, _type, _name)
    if (_type == ccs.MovementEventType.loopComplete or _type == ccs.MovementEventType.complete) and _name == MemberAnimationType.kMemberAnimationAttack and self.m_fsm:getState() ~= "dead" then
        self:doEvent("goIdle")
        return
    end
    if _type == ccs.MovementEventType.complete and _name == MemberAnimationType.kMemberAnimationDead then
        self.progress:setVisible(false)
        local fadeout = cc.FadeOut:create(1)
        self.m_member:runAction(fadeout)

        local function removeMonster()
            self.m_isRemoved = true
            self:removeSelf()
        end
        if self.smokeEff ~= nil then
            self:runAction(transition.sequence({
                                                cc.DelayTime:create(0.6),
                                                cc.CallFunc:create(function()
                                                    self.smokeEff:setVisible(false)
                                                end),
                                                cc.DelayTime:create(0.4),
                                                cc.CallFunc:create(removeMonster)
                                           }))
        else
            self:runAction(transition.sequence({
                                                cc.DelayTime:create(1),
                                                cc.CallFunc:create(removeMonster)
                                           }))
        end
        return 
    end 
    if _type ~= ccs.MovementEventType.start and _name == MemberAnimationType.kMemberAnimationHit and self.m_enermy.m_isDead == false then
        self:doEvent("goIdle")
        return
    end
    if _type ~= ccs.MovementEventType.start and _name == MemberAnimationType.kMemberAnimationHit2 and self.m_enermy.m_isDead == false then
        self:doEvent("goIdle")
        return
    end
end

function MonsterAI:movementCallbackSpine(_animation)
    if _animation == MemberAnimationType.kMemberAnimationAttack and self.m_fsm:getState() ~= "idle" and self.m_fsm:getState() ~= "dead" then
        self:doEvent("goIdle")
        return
    end
    if _animation == MemberAnimationType.kMemberAnimationDead then
        self.progress:setVisible(false)
        local fadeout = cc.FadeOut:create(1)
        self.m_member:runAction(fadeout)

        local function removeMonster()
            self.m_isRemoved = true
            self:removeSelf()
        end
        if self.smokeEff ~= nil then
            self:runAction(transition.sequence({
                                                cc.DelayTime:create(0.6),
                                                cc.CallFunc:create(function()
                                                    self.smokeEff:setVisible(false)
                                                end),
                                                cc.DelayTime:create(0.4),
                                                cc.CallFunc:create(removeMonster)
                                           }))
        else
            self:runAction(transition.sequence({
                                                cc.DelayTime:create(1),
                                                cc.CallFunc:create(removeMonster)
                                           }))
        end
        return 
    end 
    if _animation == MemberAnimationType.kMemberAnimationHit and self.m_enermy.m_isDead == false and self.m_fsm:getState() ~= "idle" then
        self:doEvent("goIdle")
        return
    end
    if _animation == MemberAnimationType.kMemberAnimationHit2 and self.m_enermy.m_isDead == false and self.m_fsm:getState() ~= "idle" then
        self:doEvent("goIdle")
        return
    end
end

function MonsterAI:effectAttack()
    if  self.m_enermy == nil   or  self.m_enermy.m_isDead ~= false   then
        return
    end
    if self.m_attackType == MemberAttackType.kAttackMelee then
         self.m_enermy:beAttacked(self.m_attackInfo)
    else
        local g_instance = nil
        if startFightBattleScene.Instance~=nil then
            g_instance = startFightBattleScene.Instance
        else
            g_instance = cc.Director:getInstance():getRunningScene()
        end
        local bullet = BulletAI.new(MemberDeffenceList[self.fightPos],self.m_enermy, self.m_bulletStr)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos])
    end
end

function MonsterAI:attackIntervalControl()
    self.m_canAttack = true
end

function MonsterAI:playSkill(_skillType)
    self:resume()
    self:getMemberAnimation():resume()
    self:stopAction(self.m_moveAction)
    if self.m_fsm:getState() == "attack" then
        self:stopAllActions()
        self.m_canAttack = true
    end
    
    self.curSkillType = _skillType
    self.curSkillID = self.m_energySkills[_skillType].id
    self:doEvent("goSkill")
    --对话
    self.m_talkNode:addTalk({member = self, talkType = TalkType.FireSkill, checkId = self.curSkillID})
    --收集信息
    -- local message = {}
    -- message["type"] = BattleMessageType.kMessageSkill
    -- message["initiativeId"] = self.m_attackInfo.tptId
    -- message["initiativeName"] = self.m_attackInfo.tptName
    -- message["skillId"] = self.curSkillID
    -- message["skillName"] = skillData[tonumber(self.curSkillID)]["sklName"]
    -- BattleMessageBox:addMessage(message)
end

function MonsterAI:showSkill()
    print("showSkill-------------------")
    self.m_isShowSkill = true
    local skill = SkillAI.new(MemberDeffenceList[self.fightPos])
    :addTo(self)
end

function MonsterAI:afterSkill()
    if self.m_isDead == false then
        if self.m_fsm:getState() ~= "win" then
            self:doEvent("goIdle")
        end
    else
        if self.m_fsm:getState() ~= "dead" then
            self:doEvent("goDead")
        end
    end 
end 

function MonsterAI:beAttacked(_attackInfo)
    local trueDamage = self:CalculateBeAttacked(_attackInfo)
    if tonumber(trueDamage) <= 0 then
        return
    end
    self:afterBeAttack()
end

function MonsterAI:afterBeAttack()
    if self.m_fsm:getState() == "skill" then
        return
    end
    if self.m_isDead and self.m_fsm:getState() ~= "dead" then
       self:doEvent("goDead")
       return
    end
    if self.m_fsm:getState() ~= "walk" and self.m_fsm:getState() ~= "skill" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "attack" and self.m_fsm:getState() ~= "stun" and self.m_isDead == false then
        self.m_hitType = MonsterHitType.kHitAttack
        self:doEvent("goHit")
    end
end

function MonsterAI:beSkilled(_skillInfo, _attackInfo)
    self:CalculateBeSkilled(_skillInfo, _attackInfo)
    if self.m_isDead and self.m_fsm:getState() ~= "dead" then
       self:doEvent("goDead")
    end
    print("_skillInfo.skillBaseDamage:".._skillInfo.skillBaseDamage)
    if self.m_fsm:getState() ~= "walk" and self.m_fsm:getState() ~= "skill" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "stun" and self.m_isDead == false and _skillInfo.skillBaseDamage > 0 then
        self.m_hitType = MonsterHitType.kHitSkill
        if self.m_fsm:getState() ~= "attack" then
            self:doEvent("goHit")
        else
            self:doEvent("goHit")
            self:stopAction(self.m_attackAction)
            self:stopAction(self.m_attackIntervalAction)
            self.m_canAttack = true
        end
    end
end

function MonsterAI:addStateMachine()
	self.m_fsm = {}
	cc.GameObject.extend(self.m_fsm)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()

    self.m_fsm:setupState({
        -- 初始状态
        initial = "ready",

        -- 事件和状态转换
        events = {
            {name = "goReady",    from = {"walk","idle","skill"},                                    to = "ready" },
            {name = "goWalk",     from = {"stun","idle", "attack","ready","win"},                  to = "walk" },--行走
            {name = "goAttack",   from = {"stun","idle", "walk"},                            to = "attack"},--攻击
            {name = "goDead",     from = {"stun","idle", "walk", "attack", "hit","skill","win"},           to = "dead"},--死亡
            {name = "goIdle",     from = {"stun","walk", "attack","hit","skill","ready"},            to = "idle"},--静止
            {name = "goWin",      from = {"stun","walk", "attack","idle","hit","skill"},             to = "win"},--胜利
            {name = "goSkill",    from = {"stun","walk", "attack", "idle", "hit"},           to = "skill"},--技能
            {name = "goHit",      from = {"idle", "attack","hit"},                    to = "hit"},--受击
            {name = "goStun",      from = {"idle", "attack","hit","skill","walk"},                    to = "stun"},--击晕
            --{name = "goDefeat",   from = {"walk", "attack", "hit"},                   to = "defeat"},--失败
        },

        -- 状态转变后的回调
        callbacks = {
            onready = function (event) self:ready()  end,
            onwalk = function (event) self:walk()  end,
            onattack =  function (event) self:attack() end,
            ondead = function (event) self:dead() end,
            onidle = function (event) self:idle() end,
            onwin = function (event) self:win()   end,
            onskill = function (event) self:skill() end,
            onhit = function (event) self:hit() end,
            onstun = function (event) self:stun() end,
                -- body
        },
    })
end

function MonsterAI:doEvent(event, ...)
    self.m_fsm:doEvent(event, ...)
end

function MonsterAI:goFight()
    self.m_hasGoFight = true
    self.selfList = MemberDeffenceList
    self.enermyList = MemberAttackList
    --开始战斗
    self:doEvent("goWalk")
    --技能逻辑
    if (self.m_energySkills[MemberSkillType.kSkillMonsterOne] ~= nil 
        or self.m_energySkills[MemberSkillType.kSkillMonsterTwo] ~= nil) and CurFightBattleType ~= FightBattleType.kType_WorldBoss then
        print("怪物自动战斗。。。。。。。。")
       self:addAutoAI()
    end
end

function MonsterAI:addAutoAI()
    if self.aotoAllEnergy ~= nil or self.m_fsm:getState() == "dead" then
        return
    end
    self.aotoAllEnergy = 0
    self.startIndex = MemberSkillType.kSkillMonsterOne
    self.curSkillIndex = MemberSkillType.kSkillMonsterOne

    -- print("aaaaaaaaaaaaaaaaaa")
    -- print(self.m_energyRecovery)
    local function refreshEnergy()
        -- print("怪物能量："..self.aotoAllEnergy)
        -- print(self.m_energySkills[self.curSkillIndex].energy)
        self.aotoAllEnergy = self.aotoAllEnergy + 1
        if self.aotoAllEnergy > 100 then
            self.aotoAllEnergy = 100
        end
        if self.m_fsm:getState() ~= "skill" and self.m_fsm:getState() ~= "dead" and self.m_fsm:getState() ~= "win" and self.m_fsm:getState() ~= "stun" and self.m_fsm:getState() ~= "ready" and self.m_gagNum <= 0 then
            local function getNextAutoSkill()
                self.curSkillIndex = self.curSkillIndex + 1
                if self.m_energySkills[self.curSkillIndex] == nil then
                    self.curSkillIndex = self.startIndex
                end
                if self.m_energySkills[self.curSkillIndex] == nil then
                    getNextAutoSkill()
                end
            end
            if self.m_energySkills[self.curSkillIndex] == nil then
                getNextAutoSkill()
            end
            if self.aotoAllEnergy >= self.m_energySkills[self.curSkillIndex].energy then
                self:playSkill(self.curSkillIndex)
                self.aotoAllEnergy =  self.aotoAllEnergy - self.m_energySkills[self.curSkillIndex].energy
                getNextAutoSkill()
            end
        end
    end

    -- print(1/self.m_energyRecovery)
    local seq = transition.sequence({
        -- cc.CallFunc:create(function() print("test222222") end),
        -- cc.CallFunc:create(function() print("test3333333") end),
      cc.DelayTime:create(1/self.m_energyRecovery),
      cc.CallFunc:create(refreshEnergy),
    })
    self.m_member:runAction(cc.RepeatForever:create(seq))
    -- print(self.m_member)
end

function MonsterAI:clearBuff()
    for bk,bv in pairs(self.buffShowing) do
        self.buffControl:clearBuff(self,bk)
    end
    for sk,sv in pairs(self.m_allShields) do
        self.buffControl:clearShield(self,sk)
    end
end

function MonsterAI:ready()
    self.selfList = {}
    self.enermyList = {}
    local function moveStop()
        if self.m_hasGoFight == false then
            self:stopMonsterAnimation()
            self:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
        end
    end

    self:stopMonsterAnimation()
    if CurFightBattleType ~= FightBattleType.kType_Expedition and CurBattleStep == 1 then        
        self:playMonsterAnimation(MemberAnimationType.kMemberAnimationWalk)
    elseif CurFightBattleType == FightBattleType.kType_Expedition and cc.Director:getInstance():getRunningScene().IsFirstIn ~= false then
        self:playMonsterAnimation(MemberAnimationType.kMemberAnimationWalk)
    else
        self:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
    end
    local moveTime = StartMoveTime*StartSpeedAdd
    if CurFightBattleType == FightBattleType.kType_Expedition and cc.Director:getInstance():getRunningScene().curSupplyState == SupplyState.kSupply_In then
       moveTime = StartMoveTime*StartSpeedAdd*2
    end
    local startMove = transition.sequence({
                                              cc.MoveTo:create(moveTime,cc.p(DefencePositions[self.fightPos][1],DefencePositions[self.fightPos][2])),
                                              cc.CallFunc:create(moveStop)
                                         })
    self:runAction(startMove)
end
function MonsterAI:walk()
    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationWalk)
    local moveTime = ((self:getPositionX())*StartMoveTime) / (display.width/2)
    self.m_moveAction = cc.MoveTo:create(moveTime,cc.p(0,self:getPositionY()))
    self:runAction(self.m_moveAction)
end
function MonsterAI:attack()
    local tab = self:findIndex()
    self.m_targetIndex , self.m_enermy= tab._nearestIndex,tab._nearestEnemy
    
    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationAttack)
    self.m_attackAction = self:performWithDelay(self.effectAttack,tonumber(self.m_befAttack))--攻击动画生效时间
    self.m_attackIntervalAction = self:performWithDelay(self.attackIntervalControl,self.m_attackInfo.attackInterval)--攻击间隔
    self.m_canAttack = false
end
function MonsterAI:dead()

    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    --BUFF Skill
    -- for k,v in pairs(self.buffShowing) do
    --      v.buffEff:removeSelf()
    --      v = nil
    -- end
    self:clearBuff() 
    if self.m_moveAction ~= nil then
        self:stopAction(self.m_moveAction)
    end
    self:resume()

    --收集信息
    -- local message = {}
    -- message["type"] = BattleMessageType.kMessageDead
    -- message["initiativeId"] = self.m_attackInfo.tptId
    -- message["initiativeName"] = self.m_attackInfo.tptName
    -- BattleMessageBox:addMessage(message)

    --掉落处理
    for i=1,#self.m_rewards do
         local dropIndex = 1
         for i=1,20 do
            if AllDropBox[i] == nil then
                dropIndex = i
            end
         end
         local box = DropBox.new(self.m_rewards[i], dropIndex, self:getPositionX())
         :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
         :addTo(g_instance,70)
         AllDropBox[dropIndex] = box
         if EmbattleMgr.nCurBattleType == BattleType_Legion then--军团
             table.insert(AllLegionRewards, #AllLegionRewards+1, self.m_rewards[i])
         end
    end

    --是否已经全部死亡
    local isAllDead = true
    for k,v in pairs(MemberDeffenceList) do
        if v~= nil and v.m_isDead == false then
            isAllDead = false
        end
    end
    if isAllDead == true then
        g_instance:afterAllMonsterDie()
    end

    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationDead)
    self:addDeadEff()
end
function MonsterAI:idle()
    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
end
function MonsterAI:win()
    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
end
function MonsterAI:skill()
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    g_instance.skillLayer:setVisible(true)
    skillPauseMembers()
    -- print("------========---------:          skillId: "..self.m_energySkills[self.curSkillType].id)
    -- print(self.m_attackInfo.tptName.."   怪物ID： "..self.m_attackInfo.tptId)
    -- print("动作名： "..MemberSkillAnimationType[self.curSkillType])
    -- print(self.m_energySkills[self.curSkillType].bef)

    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberSkillAnimationType[self.curSkillType])
    self:performWithDelay(function()
        if self.m_isDead == false then
            self:showSkill()
        else
            if self.m_fsm:getState() ~= "dead" then
                self:doEvent("goDead")
            end
        end
    end, self.m_energySkills[self.curSkillType].bef)
    --技能音效
    -- if tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= 0 then
    if tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= nil and tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= 0 
        and tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= "" 
        and tonumber(skillData[self.curSkillID]["sklsoundres"]) ~= "null" then
        local audioNode = display.newNode()
        :addTo(self)
        audioNode:runAction(transition.sequence({
                                                  cc.DelayTime:create(tonumber(skillData[self.curSkillID]["sklsounddelay"])),
                                                  cc.CallFunc:create(function()
                                                     audio.playSound("audio/musicEffect/skillEffect/"..skillData[self.curSkillID]["sklsoundres"]..".mp3")
                                                  end)
                                               }))
    end
end
function MonsterAI:hit()
    if self.m_hitType == MonsterHitType.kHitSkill and self.hasSkillHit == true then
        self:stopMonsterAnimation()
        self:playMonsterAnimation(MemberAnimationType.kMemberAnimationHit2)
        return
    end

    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationHit)
end
function MonsterAI:stun()
    self:stopAction(self.m_moveAction)
    self.m_canAttack = true

    self:stopMonsterAnimation()
    self:playMonsterAnimation(MemberAnimationType.kMemberAnimationIdle)
end

--世界BOSS的逻辑

--世界BOSS要处理的事件点
local WordBossEventPoint = {
                              BossStart                  = 0,       --初始
                              BossDrop10W                = 100000,  --掉落：第1个掉落
                              BossStronger30W            = 300000,  --强化：开始释放技能
                              BossDrop50W                = 500000,  --掉落：第2个掉落
                              BossDrop80W                = 800000,  --掉落：第3个掉落
                              BossStronger100W           = 1000000, --强化：攻击加10%
                              BossDrop120W               = 1200000, --掉落：第4个掉落
                              BossStronger150W           = 1500000, --强化：能量恢复+1
                              BossDropAndStronger200W    = 2000000, --掉落：第5个掉落 and 强化：攻击加10%
                           }


function MonsterAI:bossDamage(_damageValue)
    if self.allBossDamageNum == nil then
        self.allBossDamageNum = 0
        self.curBossState = WordBossEventPoint.BossStart
    end
    self.allBossDamageNum = self.allBossDamageNum + _damageValue

    if self.allBossDamageNum >= WordBossEventPoint.BossDrop10W and self.allBossDamageNum < WordBossEventPoint.BossStronger30W then
        self:doBossEvent(WordBossEventPoint.BossDrop10W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossStronger30W and self.allBossDamageNum < WordBossEventPoint.BossDrop50W then
        self:doBossEvent(WordBossEventPoint.BossStronger30W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossDrop50W and self.allBossDamageNum < WordBossEventPoint.BossDrop80W then
        self:doBossEvent(WordBossEventPoint.BossDrop50W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossDrop80W and self.allBossDamageNum < WordBossEventPoint.BossStronger100W then
        self:doBossEvent(WordBossEventPoint.BossDrop80W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossStronger100W and self.allBossDamageNum < WordBossEventPoint.BossDrop120W then
        self:doBossEvent(WordBossEventPoint.BossStronger100W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossDrop120W and self.allBossDamageNum < WordBossEventPoint.BossStronger150W then
        self:doBossEvent(WordBossEventPoint.BossDrop120W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossStronger150W and self.allBossDamageNum < WordBossEventPoint.BossDropAndStronger200W then
        self:doBossEvent(WordBossEventPoint.BossStronger150W)
    elseif self.allBossDamageNum >= WordBossEventPoint.BossDropAndStronger200W then
        self:doBossEvent(WordBossEventPoint.BossDropAndStronger200W)
    end
end

--添加死亡特效
function MonsterAI:addDeadEff()
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    if tonumber(monsterData[self.m_attackInfo.tptId]["deadres"]) == 0 then
        return
    elseif tonumber(monsterData[self.m_attackInfo.tptId]["deadres"]) == 1 then
        local offSets = string.split(monsterData[self.m_attackInfo.tptId]["deadpos"],"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        local sp = display.newSprite("#deadEffMoney_00.png")
        :align(display.CENTER_BOTTOM,self:getPositionX()-display.width*0.05*BlockTypeScale + display.width*0.1*BlockTypeScale*xOffset, self:getPositionY() + display.width*0.1*BlockTypeScale*yOffset)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos])
        sp:scale(3*tonumber(monsterData[self.m_attackInfo.tptId]["deadscale"]))
        local frames = display.newFrames("deadEffMoney_%02d.png", 0, 24)
        local animation = display.newAnimation(frames, 1/24)
        local aniAction = cc.Animate:create(animation)
        sp:runAction(transition.sequence({ 
                                           aniAction,
                                           cc.CallFunc:create(function()
                                               sp:removeSelf()
                                           end)
                                         }))
    elseif tonumber(monsterData[self.m_attackInfo.tptId]["deadres"]) == 2 then
        local offSets = string.split(monsterData[self.m_attackInfo.tptId]["deadpos"],"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        local spUp = display.newSprite("#deadEffBiologyUp_00.png")
        :align(display.CENTER_BOTTOM,self:getPositionX()-display.width*0.05*BlockTypeScale + display.width*0.1*BlockTypeScale*xOffset, self:getPositionY() + display.width*0.1*BlockTypeScale*yOffset)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos])
        local framesUp = display.newFrames("deadEffBiologyUp_%02d.png", 0, 23)
        local animationUp = display.newAnimation(framesUp, 1/23)
        local aniActionUp = cc.Animate:create(animationUp)
        local spDown = display.newSprite("#deadEffBiologyDown_00.png")
        :align(display.CENTER_BOTTOM,self:getPositionX()-display.width*0.05*BlockTypeScale + display.width*0.1*BlockTypeScale*xOffset, self:getPositionY() + display.width*0.1*BlockTypeScale*yOffset)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos] - 1)
        local framesDown = display.newFrames("deadEffBiologyDown_%02d.png", 0, 17)
        local animationDown = display.newAnimation(framesDown, 1/17)
        local aniActionDown = cc.Animate:create(animationDown)
        spUp:scale(3*tonumber(monsterData[self.m_attackInfo.tptId]["deadscale"]))
        spDown:scale(3*tonumber(monsterData[self.m_attackInfo.tptId]["deadscale"]))
        spUp:runAction(transition.sequence({
                                           aniActionUp,
                                           cc.CallFunc:create(function()
                                               spUp:removeSelf()
                                           end)
                                         }))
        spDown:runAction(transition.sequence({ 
                                           aniActionDown,
                                           cc.CallFunc:create(function()
                                               spDown:removeSelf()
                                           end)
                                         }))
    elseif tonumber(monsterData[self.m_attackInfo.tptId]["deadres"]) == 3 then
        local offSets = string.split(monsterData[self.m_attackInfo.tptId]["deadpos"],"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        local sp = display.newSprite("#deadEffMachine_00.png")
        :align(display.CENTER_BOTTOM,self:getPositionX()-display.width*0.05*BlockTypeScale + display.width*0.1*BlockTypeScale*xOffset, self:getPositionY() + display.width*0.1*BlockTypeScale*yOffset)
        :addTo(g_instance,BattleDisplayLevel[self.fightPos])
        sp:scale(3*tonumber(monsterData[self.m_attackInfo.tptId]["deadscale"]))
        local frames = display.newFrames("deadEffMachine_%02d.png", 0, 30)
        local animation = display.newAnimation(frames, 1/30)
        local aniAction = cc.Animate:create(animation)
        sp:runAction(transition.sequence({ 
                                           aniAction,
                                           cc.CallFunc:create(function()
                                               sp:removeSelf()
                                           end)
                                         }))
    else
        return
    end
end

function MonsterAI:doBossEvent(_event)
    if self.curBossState == _event then
        return
    end
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    
    if _event == WordBossEventPoint.BossDrop10W then
        for k,v in pairs(BattleData["rewardItems"]) do
            if v.hurt == WordBossEventPoint.BossDrop10W then
                local dropIndex = 1
                for i=1,20 do
                    if AllDropBox[i] == nil then
                        dropIndex = i
                    end
                end
                local box = DropBox.new(v, dropIndex, self:getPositionX())
                :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
                :addTo(g_instance,70)
                AllDropBox[dropIndex] = box
                table.insert(AllLegionRewards, #AllLegionRewards+1, v)
            end
        end
    elseif _event == WordBossEventPoint.BossStronger30W then
        self:addAutoAI()
    elseif _event == WordBossEventPoint.BossDrop50W then
        for k,v in pairs(BattleData["rewardItems"]) do
            if v.hurt == WordBossEventPoint.BossDrop50W then
                local dropIndex = 1
                for i=1,20 do
                    if AllDropBox[i] == nil then
                        dropIndex = i
                    end
                end
                local box = DropBox.new(v, dropIndex, self:getPositionX())
                :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
                :addTo(g_instance,70)
                AllDropBox[dropIndex] = box
                table.insert(AllLegionRewards, #AllLegionRewards+1, v)
            end
        end
    elseif _event == WordBossEventPoint.BossDrop80W then
        for k,v in pairs(BattleData["rewardItems"]) do
            if v.hurt == WordBossEventPoint.BossDrop80W then
                local dropIndex = 1
                for i=1,20 do
                    if AllDropBox[i] == nil then
                        dropIndex = i
                    end
                end
                local box = DropBox.new(v, dropIndex, self:getPositionX())
                :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
                :addTo(g_instance,70)
                AllDropBox[dropIndex] = box
                table.insert(AllLegionRewards, #AllLegionRewards+1, v)
            end
        end
    elseif _event == WordBossEventPoint.BossStronger100W then
        self.m_attackInfo.attackValue = self.m_attackInfo.attackValue*1.1
    elseif _event == WordBossEventPoint.BossDrop120W then
        for k,v in pairs(BattleData["rewardItems"]) do
            if v.hurt == WordBossEventPoint.BossDrop120W then
                local dropIndex = 1
                for i=1,20 do
                    if AllDropBox[i] == nil then
                        dropIndex = i
                    end
                end
                local box = DropBox.new(v, dropIndex, self:getPositionX())
                :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
                :addTo(g_instance,70)
                AllDropBox[dropIndex] = box
                table.insert(AllLegionRewards, #AllLegionRewards+1, v)
            end
        end
    elseif _event == WordBossEventPoint.BossStronger150W then
        self.m_energyRecovery = self.m_energyRecovery + 1
        self.m_member:stopAllActions()
        self:addAutoAI()
    else
        self.m_attackInfo.attackValue = self.m_attackInfo.attackValue*1.1
        for k,v in pairs(BattleData["rewardItems"]) do
            if v.hurt == WordBossEventPoint.BossDropAndStronger200W then
                local dropIndex = 1
                for i=1,20 do
                    if AllDropBox[i] == nil then
                        dropIndex = i
                    end
                end
                local box = DropBox.new(v, dropIndex, self:getPositionX())
                :pos(self:getPositionX(), self:getPositionY()+self.m_member:getContentSize().height/2)
                :addTo(g_instance,70)
                AllDropBox[dropIndex] = box
                table.insert(AllLegionRewards, #AllLegionRewards+1, v)
            end
        end
    end
    self.curBossState = _event
end

return MonsterAI