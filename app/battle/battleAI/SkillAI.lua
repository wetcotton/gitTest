--
-- Author: liufei
-- Date: 2014-11-04 12:04:37
--

require("app.battle.BattleInfo")

local BufferAI = require("app.battle.battleAI.BufferAI")

local SkillAI = class("SkillAI", function ()
	return display.newNode()
end)

function SkillAI:ctor(_member)
    
    self:resetSkillInfo()
    self.BattleSkillInfo.skillSponsor = _member
    self.BattleSkillInfo.skillType = _member.curSkillType
    self.BattleSkillInfo.skillId = _member.curSkillID
    if _member.m_memberType == MemberAllType.kMemberHero then
        self.BattleSkillInfo.skillSLevel = _member.m_energySkills[_member.curSkillType].lvl
    else
        self.BattleSkillInfo.skillSLevel = _member.m_attackInfo.level
    end
    local restrictionData = string.split(skillData[self.BattleSkillInfo.skillId]["sklEff"],"|")
    for k,v in pairs(restrictionData) do
        local tmpOne = string.split(v,"#")
        self.BattleSkillInfo.skillRestriction[tonumber(tmpOne[1])] = tonumber(tmpOne[2])
    end
    
	if _member.m_posType == MemberPosType.defenceType then
		self.selfMemberList   = MemberDeffenceList
		self.enermyMemberList = MemberAttackList
	elseif _member.m_posType == MemberPosType.attackType then
		self.selfMemberList = MemberAttackList
		self.enermyMemberList = MemberDeffenceList
	end
	--self.selfMemberList[1].m_attackInfo.attackValue =  60
    self.BattleSkillInfo.skillCoefficient = tonumber(skillData[_member.curSkillID]["addPercent"])
	if self.BattleSkillInfo.skillType == MemberSkillType.kSkillHeroOne or self.BattleSkillInfo.skillType == MemberSkillType.kSkillHeroTwo or self.BattleSkillInfo.skillType == MemberSkillType.kSkillHeroThree or self.BattleSkillInfo.skillType == MemberSkillType.kSkillHeroFour then
		self.BattleSkillInfo.skillBaseDamage = _member.m_attackInfo.attackValue
	elseif self.BattleSkillInfo.skillType == MemberSkillType.kSkillTankMain or self.BattleSkillInfo.skillType == MemberSkillType.kSkillTankTwo or self.BattleSkillInfo.skillType == MemberSkillType.kSkillTankOne then
		self.BattleSkillInfo.skillBaseDamage = _member.m_mainAtk
	elseif self.BattleSkillInfo.skillType >= MemberSkillType.kSkillMonsterOne then
		self.BattleSkillInfo.skillBaseDamage = _member.m_attackInfo.attackValue
	end

    if self.BattleSkillInfo.skillType == MemberSkillType.kSkillTankMain then
        self:addMainSkill(_member)
    else
        self:addSkill(_member)
    end
end

function SkillAI:resetSkillInfo()
    self.BattleSkillInfo = {}
    self.BattleSkillInfo.skillSponsor = 0 --技能发起者
    self.BattleSkillInfo.skillType = 0 --技能类型
    self.BattleSkillInfo.skillId = 0 --技能ID             
    self.BattleSkillInfo.skillCoefficient = 0 --技能系数
    self.BattleSkillInfo.skillBaseDamage = 0 --技能伤害基数
    self.BattleSkillInfo.skillBuffID = 0 --技能附带BUFF的ID
    self.BattleSkillInfo.skillSLevel = 0 --施放者使用等级
    self.BattleSkillInfo.skillSection = 1 --技能伤害分段的次数
    self.BattleSkillInfo.skillRestriction = {} --技能克制值
end

local function isMemberNil(_member)
    return isNodeValue(_member)
end

--主炮技能
function SkillAI:addMainSkill(_member)
    --print(_member.m_posType.." -----jiuhu addMainSkill")
    local star = getItemStar(_member.m_mainTptId)
    local fNums = {
                    [2] = {name = "One", up = 8, down = 12, time = 0.6},--白
                    [3] = {name = "Two", up = 8, down = 13, time = 0.6},--绿
                    [4] = {name = "Three", up = 10, down = 15, time = 0.7},--蓝
                    [5] = {name = "Four", up = 12, down = 15, time = 0.8},--紫
                  }
    audio.playSound("audio/musicEffect/skillEffect/fire_1101001.mp3")
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end
    local offSets = string.split(_member.m_mainPos,"|")
    local xOffset = tonumber(offSets[1])
    local yOffset = tonumber(offSets[2])

    local startPos = nil
    local scaleX = 1
    if _member.m_posType == MemberPosType.defenceType then
        startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*BattleScaleValue*TankBlockScale, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*BattleScaleValue*TankBlockScale)
        scaleX = 1
    elseif _member.m_posType == MemberPosType.attackType then
        startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*BattleScaleValue, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*BattleScaleValue)
        scaleX = -1
    end
    local speBullet = display.newSprite("Battle/Bullet/bulletMain.png")
    :pos(startPos.x, startPos.y)
    :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
    speBullet:setScaleX(scaleX*BlockTypeScale)
    speBullet:setScaleY(BlockTypeScale)
    if _member.m_enermy == nil or _member.m_enermy.m_isDead ~= false then
        for i=_member.m_targetIndex,7 do
            if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                _member.m_targetIndex = i
                _member.m_enermy = _member.enermyList[i]
                break
            end
        end
    end
    local function resumeSkill()
        _member.m_isShowSkill = false
        for i = 1, 7 do
            if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                return
            end
        end
        for i = 1, 7 do
            if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                return
            end
        end
    end
    local function afterSkill()
        if isMemberNil(_member) then
            _member:afterSkill()
        end
    end

    if _member.m_enermy == nil or _member.m_enermy.m_isDead ~= false then
        speBullet:removeSelf()
        resumeSkill()
        if isMemberNil(_member) then
            _member:afterSkill()
        end
        return
    end
    local enermy = _member.m_enermy
    local  targetPosX = enermy:getPositionX()
    local  targetPosY = enermy:getPositionY()
    local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
    local moveTime = distance/(BulletMoveSpeed*2.5)
    local moveAction = cc.MoveTo:create(moveTime, cc.p(targetPosX,targetPosY))
    local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
    if startPos.x > targetPosX then
        if startPos.y > targetPosY  then
           speBullet:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
           speBullet:setRotation(rotateNum)
        end
    else
        if startPos.y > targetPosY  then
           speBullet:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
           speBullet:setRotation(-rotateNum)
        end
    end
    
    local speEpoUp,epoActionUp,speEpoDown,epoActionDown
    --需要分层处理
    speEpoUp = display.newSprite("#mainEpoUp"..fNums[star].name.."_00.png")
    :align(display.CENTER_BOTTOM,targetPosX, targetPosY - display.width*0.03)
    :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
    speEpoUp:scale(1.5)
    speEpoUp:setVisible(false)
    local epoframesUp = display.newFrames("mainEpoUp"..fNums[star].name.."_%02d.png", 1, fNums[star].up - 1)
    local epoanimationUp = display.newAnimation(epoframesUp, fNums[star].time/fNums[star].up)
    epoActionUp = cc.Animate:create(epoanimationUp)

    speEpoDown = display.newSprite("#mainEpoDown"..fNums[star].name.."_00.png")
    :align(display.CENTER_BOTTOM,targetPosX, targetPosY - display.width*0.03)
    :addTo(g_instance,BattleDisplayLevel[enermy.fightPos]-1)
    speEpoDown:setScaleX(scaleX*1.5*BattleScaleValue)
    speEpoDown:setScaleY(1.5*BattleScaleValue)
    speEpoDown:setVisible(false)
    local epoframesDown = display.newFrames("mainEpoDown"..fNums[star].name.."_%02d.png", 1, fNums[star].down - 1)
    local epoanimationDown = display.newAnimation(epoframesDown, fNums[star].time/fNums[star].down)
    epoActionDown = cc.Animate:create(epoanimationDown)
    
    local function removeSkill()
        speEpoUp:removeSelf()
        speEpoDown:removeSelf()
    end
    local function effectSkill()
        if enermy ~= nil and enermy.m_isDead == false then
            enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
        end
    end
    
    resumeSkill()
    local function showEpo()
        speBullet:setVisible(false)
        speEpoUp:setVisible(true)
        speEpoDown:setVisible(true)
        audio.playSound("audio/musicEffect/skillEffect/epo_1101001.mp3")
    end

    speBullet:runAction(moveAction)
    speEpoUp:runAction(transition.sequence({
                                                cc.DelayTime:create(moveTime),
                                                cc.CallFunc:create(showEpo),
                                                epoActionUp,
                                        }))
    speEpoDown:runAction(transition.sequence({
                                                cc.DelayTime:create(moveTime),
                                                cc.CallFunc:create(effectSkill),
                                                epoActionDown,
                                                cc.CallFunc:create(removeSkill),
                                            }))
    
    afterSkill()
end

--其他技能
function SkillAI:addSkill(_member)
    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end

    if SklPlayCnt[tostring(self.BattleSkillInfo.skillId)] == nil then
        SklPlayCnt[tostring(self.BattleSkillInfo.skillId)] = 1
    else
        SklPlayCnt[tostring(self.BattleSkillInfo.skillId)] = SklPlayCnt[tostring(self.BattleSkillInfo.skillId)] + 1
    end

    -- print("addSkill SklPlayCnt.."..tostring(self.BattleSkillInfo.skillId))
    -- printTable(SklPlayCnt)

    --抖动
    if tonumber(skillData[_member.curSkillID]["shake"]) ~= nil and tonumber(skillData[_member.curSkillID]["shake"]) ~= "" 
        and tonumber(skillData[_member.curSkillID]["shake"]) ~= "null" and tonumber(skillData[_member.curSkillID]["shake"]) ~= 0 then
        local shakeNode = display.newNode()
        :addTo(self)
        shakeNode:performWithDelay(function()
            g_instance:shakeBg(tonumber(skillData[_member.curSkillID]["shake"]))
        end,tonumber(skillData[_member.curSkillID]["shakedelay"]))
    end

    print(_member.m_posType.." jiuhu addSkill: "..self.BattleSkillInfo.skillId.."   name : "..skillData[self.BattleSkillInfo.skillId].sklName)
	if tonumber(self.BattleSkillInfo.skillId) == 1101001 then --激光炮
		local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        local startPos = nil
        local ali = nil
        if _member.m_posType == MemberPosType.defenceType then
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
            ali = display.CENTER_RIGHT
        elseif _member.m_posType == MemberPosType.attackType then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
            ali = display.CENTER_LEFT
        end
        local sp1 = display.newSprite("#juqi0001.png", startPos.x, startPos.y)
        :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
        local frames1 = display.newFrames("juqi%04d.png", 1, 31)
        local animation1 = display.newAnimation(frames1, 1/31)
        local aniAction1 = cc.Animate:create(animation1)
        local sp2 = display.newSprite("#jg0001.png", startPos.x, startPos.y)
        :align(ali, startPos.x, startPos.y)
        :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
        if _member.m_posType == MemberPosType.defenceType then
            sp2:setScaleX(startPos.x*1.2/sp2:getContentSize().width)
        elseif _member.m_posType == MemberPosType.attackType then
            sp2:setScaleX((display.width-(startPos.x*0.8))/sp2:getContentSize().width)
        end
        
        sp2:setVisible(false)
        local frames2 = display.newFrames("jg%04d.png", 1, 15)
        local animation2 = display.newAnimation(frames2, 0.8/15)
        local aniAction2 = cc.Animate:create(animation2)
        local function effectSkill()
            for i = 1, 7 do
        	    if self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and _member.fightPos%2 == self.enermyMemberList[i].fightPos%2 then
        		    self.enermyMemberList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
        	    end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
             _member:afterSkill()
          end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end

        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.6),
                                              cc.CallFunc:create(showSp2),
                                              cc.Animate:create(animation2),
                                              cc.CallFunc:create(removeSkill)
        	                              }))
        self:runAction(transition.sequence({ 
                                              cc.DelayTime:create(1.2),
                                              cc.CallFunc:create(effectSkill)
        	                              }))
    end

    -- print("---------------------------------------------------last skill..".._member.id.."--"..self.BattleSkillInfo.skillId)
    
    --烈焰轰击
    if tonumber(self.BattleSkillInfo.skillId) == 3012001 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0
        yOffset = 0.8
        local startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
        local sp1 = display.newSprite("#Skill3012001_blt_00.png",  startPos.x*1.05, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        local frames1 = display.newFrames("Skill3012001_blt_%02d.png", 0, 3)
        local animation1 = display.newAnimation(frames1, 0.2/4)
        local aniAction1 = cc.Repeat:create(cc.Animate:create(animation1),2)
        local moveAction = cc.MoveTo:create(0.4,self:getCurCenterPoint(_member))
        local sp2 = display.newSprite("#Skill3012001_epo_00.png", startPos.x, startPos.y)
        :pos(self:getCurCenterPoint(_member).x,self:getCurCenterPoint(_member).y)
        :addTo(g_instance,SkillMemmberLevel)
        sp2:setVisible(false)
        sp1:scale(1.5)
        sp2:scale(4)
        local frames2 = display.newFrames("Skill3012001_epo_%02d.png", 0, 6)
        local animation2 = display.newAnimation(frames2, 0.6/6)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            for i = 1, 7 do
                if self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false then
                    self.enermyMemberList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end

        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end

        sp1:runAction(cc.Spawn:create({
                                            aniAction1,
                                            moveAction
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.65),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end


    --se爆炸
    if tonumber(self.BattleSkillInfo.skillId) == 1103001 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.4
        yOffset = 0.38
        local startPos = nil
        if _member.m_posType == MemberPosType.defenceType then
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
        elseif _member.m_posType == MemberPosType.attackType then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
        end
        local sp1 = display.newSprite("#Skill1103001_blt_00.png", startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        local frames1 = display.newFrames("Skill1103001_blt_%02d.png", 0, 3)
        local animation1 = display.newAnimation(frames1, 0.2/3)
        local aniAction1 = cc.Animate:create(animation1)
        local moveAction = cc.MoveTo:create(0.4,self:getCurCenterPoint(_member))
        local sp2 = display.newSprite("#Skill1103001_epo_00.png", startPos.x, startPos.y)
        :pos(self:getCurCenterPoint(_member).x,self:getCurCenterPoint(_member).y)
        :addTo(g_instance,SkillMemmberLevel)
        sp2:setVisible(false)
        if _member.m_posType == MemberPosType.defenceType then
            sp1:setScaleX(1)
            sp2:scale(2.2)
        elseif _member.m_posType == MemberPosType.attackType then
            sp1:setScaleX(-1)
            sp2:scale(-2.2)
        end
        
        local frames2 = display.newFrames("Skill1103001_epo_%02d.png", 0, 7)
        local animation2 = display.newAnimation(frames2, 0.7/6)
        local aniAction2 = cc.Animate:create(animation2)
  
        local function effectSkill()
            for i = 1, 7 do
                if self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false then
                    self.enermyMemberList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        
        sp1:runAction(cc.Spawn:create({
                                            aniAction1,
                                            moveAction
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --1012弹弓技能
    if tonumber(self.BattleSkillInfo.skillId) == 2201001 then
        local offSets = string.split(_member.m_skillStartPos,"|")
        local xOffset = tonumber(offSets[1])*1.2
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or    _member.m_enermy.m_isDead == true == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = display.newSprite("Battle/Bullet/HeroBullet_1012.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum*1.5)
             local  startPos = nil

             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
             else
                startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
             end
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     local epoSp = display.newSprite("#beAtkEff_1012_00.png")
                     :pos(targetPosX-display.width*0.03, targetPosY)
                     :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                     epoSp:scale(1.5)
                     local epoFrames = display.newFrames("beAtkEff_1012_%02d.png", 0, 4)
                     local epoAnimation = display.newAnimation(epoFrames, 0.3/4)
                     local epoAction = cc.Animate:create(epoAnimation)
                     epoSp:runAction(transition.sequence({
                                                            epoAction,
                                                            cc.CallFunc:create(epoSp.removeSelf)
                                                         }))
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*1.8)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end

    --3014001 战狗的怒吼
    if tonumber(self.BattleSkillInfo.skillId) == 3014001 then
        local offSets = string.split(_member.m_energySkills[MemberSkillType.kSkillMonsterOne].pos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
            for i=_member.m_targetIndex,7 do
                if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                    _member.m_targetIndex = i
                    _member.m_enermy = _member.enermyList[i]
                    break
                end
            end
        end
        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillbullet3014001_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local frames1 = display.newFrames("skillbullet3014001_%02d.png", 0, 4)
        local animation1 = display.newAnimation(frames1, 0.2/5)
        local aniAction1 = cc.RepeatForever:create(cc.Animate:create(animation1))
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.7)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014001_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:scale(1.5*BlockTypeScale)
        local frames2 = display.newFrames("skillepo3014001_%02d.png", 0, 11)
        local animation2 = display.newAnimation(frames2, 0.7/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            aniAction1,
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --3014002 战狗的狂躁
    if tonumber(self.BattleSkillInfo.skillId) == 3014002 then
        --三段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/3
        self.BattleSkillInfo.skillSection = 3
        local offSets = string.split(_member.m_energySkills[MemberSkillType.kSkillMonsterTwo].pos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset =  0.45
        yOffset =  1.1
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY()
        local function fireBullet()
             local bullet = display.newSprite("#skillbullet3014002_00.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             local  startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
             bullet:pos(startPos.x, startPos.y)
             bullet:scale(0.7*BlockTypeScale)
             bullet:setRotation(30)
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + bullet:getContentSize().width*0.3
             end
             local framesbullet = display.newFrames("skillbullet3014002_%02d.png", 0, 2)
             local animationbullet = display.newAnimation(framesbullet, 0.2/3)
             local actionbullet = cc.RepeatForever:create(cc.Animate:create(animationbullet))

             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.5)
             local rotateAction = cc.RotateBy:create(moveTime, -90)

             local bezierConfig ={
                   cc.p(startPos.x-display.width*0.1, startPos.y+display.height*0.11),
                   cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.11),
                   cc.p(targetPosX, targetPosY)
             }
             -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
             local bezier = cc.BezierTo:create(moveTime, bezierConfig)
             
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
             end
             local function showEffect()
                   bullet:removeSelf()
                   local effectSp = display.newSprite("#skillepo3014002_00.png")
                   :pos(enermy:getPositionX(), enermy:getPositionY()+display.height*0.23*BlockTypeScale)
                   :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                   effectSp:scale(1.5*BlockTypeScale)
                   local function removeEffectSp()
                        effectSp:removeSelf()
                   end
                   local framesEffect = display.newFrames("skillepo3014002_%02d.png", 0, 6)
                   local animationEffect  = display.newAnimation(framesEffect, 0.5/6)
                   local actionEffect  = cc.Animate:create(animationEffect)
                   effectSp:runAction(transition.sequence({
                                                             actionEffect,
                                                             cc.CallFunc:create(removeEffectSp),
                                                          }))
                   effectSp:performWithDelay(effectSkill, 0.05)
             end
             bullet:runAction(transition.sequence({cc.Spawn:create({
                                                                      actionbullet,
                                                                      rotateAction,
                                                                      bezier
                                                                   }),
                                                   cc.CallFunc:create(showEffect),
                                                 }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.05),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end

    ----水怪毒液
    if tonumber(self.BattleSkillInfo.skillId) == 3014003 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            _member:afterSkill()
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014003.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014003_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014003_%02d.png", 0, 17)
        local animation2 = display.newAnimation(frames2, 1.4/17)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX() + sp2:getContentSize().width*0.05
                targetPosY = enermy:getPositionY() + sp2:getContentSize().height*0.4
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    ----水怪喷火
    if tonumber(self.BattleSkillInfo.skillId) == 3014004 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function effectSkill()
            for i=1,7 do
              if MemberAttackList[i] ~= nil and MemberAttackList[i].m_isDead == false then
                  MemberAttackList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end
        end
        effectSkill()
        local function removeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.8),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end

    ----霸王花酸液
    if tonumber(self.BattleSkillInfo.skillId) == 3014006 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX = 1
        end

        local sp2 = display.newSprite("#skillepo3014006_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(1.5)
        if _member:getPositionX() < targetPosX then
            sp2:align(display.CENTER_BOTTOM, targetPosX - sp2:getContentSize().width*0.3, targetPosY - sp2:getContentSize().height*0.4)
        else
            sp2:align(display.CENTER_BOTTOM, targetPosX + sp2:getContentSize().width*0.3, targetPosY - sp2:getContentSize().height*0.4)
        end
        local frames2 = display.newFrames("skillepo3014006_%02d.png", 0, 17)
        local animation2 = display.newAnimation(frames2, 1/17)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        resumeSkill()

        sp2:runAction(transition.sequence({ 
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----霸王花聚光炮
    if tonumber(self.BattleSkillInfo.skillId) == 3014007 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.3
        local yOffset = tonumber(offSets[2])*1.13
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014007_00.png",  (startPos.x + targetPosX)/2, (startPos.y + targetPosY)/2)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*(distance/sp1:getContentSize().width))
        sp1:setScaleY(fireScaleX*2)
        local frames1 = display.newFrames("skillblt3014007_%02d.png", 0, 5)
        local animation1 = display.newAnimation(frames1, 0.3/6)
        local aniAction1 = cc.Animate:create(animation1)

        local sp2 = display.newSprite("#skillepo3014007_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014007_%02d.png", 0, 10)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----马歇尔 加血
    if tonumber(self.BattleSkillInfo.skillId) == 3014008 then
        local recoverHp = skillData[3014008]["addPercent"]*_member.m_attackInfo.attackValue - skillData[3014008]["add"]
        _member:LiquidateDamage(recoverHp,false)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.2),
                                            cc.CallFunc:create(removeSkill),
                                           }))
    end

    ----马歇尔 人手导弹
    if tonumber(self.BattleSkillInfo.skillId) == 3014009 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.1
        yOffset = 0.55
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX() + display.width*0.1
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014009.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014009_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(-fireScaleX)
        sp2:setPosition(targetPosX - sp2:getContentSize().width*0.68, targetPosY)
        local frames2 = display.newFrames("skillepo3014009_%02d.png", 0, 7)
        local animation2 = display.newAnimation(frames2, 0.6/9)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----水鬼加攻击
    if tonumber(self.BattleSkillInfo.skillId) == 3014010 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function effectSkill()
            if isMemberNil(_member) then
                local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
                _member.buffControl:addBuffer(_member,buffID)
            end
        end
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(1),
                                            cc.CallFunc:create(effectSkill),
                                            cc.DelayTime:create(0.2),
                                            cc.CallFunc:create(removeSkill),
                                           }))
    end
    
    ----水鬼大炮
    if tonumber(self.BattleSkillInfo.skillId) == 3014011 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.1
        yOffset = 0.55
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX() + display.width*0.16
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014011_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014011_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(-fireScaleX)
        sp2:setPosition(targetPosX - sp2:getContentSize().width*0.68, targetPosY)
        local frames2 = display.newFrames("skillepo3014011_%02d.png", 0, 11)
        local animation2 = display.newAnimation(frames2, 0.7/9)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----大象冲撞
    if tonumber(self.BattleSkillInfo.skillId) == 3014012 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function effectSkill()
            for k,v in pairs(MemberAttackList) do
                if v ~= nil and v.m_isDead == false then
                    v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        
        self:runAction(transition.sequence({cc.DelayTime:create(0.8),
                                            cc.CallFunc:create(effectSkill),
                                            cc.DelayTime:create(0.1),
                                            cc.CallFunc:create(removeSkill),
                                           }))
    end

    ----大象疯狂扫射
    if tonumber(self.BattleSkillInfo.skillId) == 3014013 then
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/4
        self.BattleSkillInfo.skillSection = 4
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = self:getBackSingle(_member).effList[1]
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = display.newSprite("#skillblt3014013.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum)
             local  startPos = nil
                 
             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
             else
                startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
             end
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     local epoSp = display.newSprite("#skillepo3014013_00.png")
                     :pos(targetPosX, targetPosY)
                     :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                     local epoFrames = display.newFrames("skillepo3014013_%02d.png", 0, 4)
                     local epoAnimation = display.newAnimation(epoFrames, 0.3/5)
                     local epoAction = cc.Animate:create(epoAnimation)
                     epoSp:runAction(transition.sequence({
                                                            epoAction,
                                                            cc.CallFunc:create(epoSp.removeSelf)
                                                         }))
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.2)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireBullet),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end

    ----异形怪的撕咬
    if tonumber(self.BattleSkillInfo.skillId) == 3014023 then
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/3
        self.BattleSkillInfo.skillSection = 3
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(effectSkill),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end

    ----异形怪大炮
    if tonumber(self.BattleSkillInfo.skillId) == 3014024 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0
        yOffset = 1.3

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06

        local epoSp = display.newSprite("#skillepoup3014024_00.png")
        :addTo(g_instance,centerInfo.zOrder)

        local startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)

        local sp1 = display.newSprite("#skillblt3014024.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2)
        local rotateAction = cc.RotateBy:create(moveTime, -80)

        local bezierConfig ={
            cc.p(startPos.x-display.width*0.2, startPos.y+display.height*0.25),
            cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.35),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        epoSp:setPosition(targetPosX,targetPosY)
        epoSp:setScaleX(1.6)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepoup3014024_%02d.png", 0, 14)
        local epoanimation = display.newAnimation(epoframes, 1.3/15)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end
        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            epoSp:setVisible(true)
        end

        sp1:runAction(cc.Spawn:create({
                                            rotateAction,
                                            bezier,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --冰裂
    if tonumber(self.BattleSkillInfo.skillId) == 1103002 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0
        yOffset = 1.9
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY()
        function getEnermyInfo()
            if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         enermy = _member.m_enermy
                         targetPosX = enermy:getPositionX()
                         targetPosY = enermy:getPositionY()
                         break
                     end
                 end
            end
        end
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX =  1
        end
        local fireSp = display.newSprite("#skillfire1103002_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        fireSp:setScaleX(fireScaleX)
        local fireframes = display.newFrames("skillfire1103002_%02d.png", 0, 13)
        local fireanimation = display.newAnimation(fireframes, 1/13)
        local fireAction = cc.Animate:create(fireanimation) 
        local epoSp = display.newSprite("#skillepo1103002_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        epoSp:setPosition(targetPosX, targetPosY+epoSp:getContentSize().height*0.33)
        epoSp:setScaleX(fireScaleX)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo1103002_%02d.png", 0, 16)
        local epoanimation = display.newAnimation(epoframes, 1.4/16)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            fireSp:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showEpo()
            fireSp:setVisible(false)
            getEnermyInfo()
            epoSp:setPosition(targetPosX, targetPosY+epoSp:getContentSize().height*0.33)
            epoSp:setVisible(true)
            if _member.m_seEpoSound ~= nil then
                audio.playSound("audio/musicEffect/skillEffect/".._member.m_seEpoSound..".mp3")
            end
        end
        
        if _member.m_seFireSound ~= nil then
            audio.playSound("audio/musicEffect/skillEffect/".._member.m_seFireSound..".mp3")
        end
        fireSp:runAction(cc.Spawn:create({
                                            fireAction,
                                        }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.8),
                                              cc.CallFunc:create(showEpo),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1.6),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    --火枪
    if tonumber(self.BattleSkillInfo.skillId) == 2201003 then
        local xOffset = 0.8
        local yOffset = 1.05
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2201003.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo2201003_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        local frames2 = display.newFrames("skillepo2201003_%02d.png", 0, 8)
        local animation2 = display.newAnimation(frames2, 0.5/8)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --主角 汤姆森
    if tonumber(self.BattleSkillInfo.skillId) == 2201005 or tonumber(self.BattleSkillInfo.skillId) == 2201012 then
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/5
        self.BattleSkillInfo.skillSection = 5
        local offSets = string.split(_member.m_skillStartPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])+0.1
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = display.newSprite("#skillblt2201005.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum)
             local  startPos = nil
                 
             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
             else
                startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
             end
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     local epoSp = display.newSprite("#skillepo2201005_00.png")
                     :pos(targetPosX, targetPosY)
                     :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                     local epoFrames = display.newFrames("skillepo2201005_%02d.png", 0, 8)
                     local epoAnimation = display.newAnimation(epoFrames, 0.4/8)
                     local epoAction = cc.Animate:create(epoAnimation)
                     epoSp:runAction(transition.sequence({
                                                            epoAction,
                                                            cc.CallFunc:create(function()
                                                                epoSp:removeSelf()
                                                            end)
                                                         }))
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end
    --弓弩
    if tonumber(self.BattleSkillInfo.skillId) == 2201008 then
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local offSets = string.split(_member.m_skillStartPos,"|")
        local xOffset = 1
        local yOffset = 1
        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX() - enermy.m_member:getBoundingBox().width*0.3
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local fireScaleX = 1
        local  startPos = nil
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX =  -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = 1
        end

        local bullet = display.newSprite("#skillblt2201008_00.png",  startPos.x, startPos.y)
             :addTo(g_instance,SkillMemmberLevel)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))

        local moveTime = distance/(BulletMoveSpeed*2)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        bullet:setScaleX(fireScaleX*BlockTypeScale*0.7)
        bullet:setScaleY(BlockTypeScale*0.7)
        local frames1 = display.newFrames("skillblt2201008_%02d.png", 0, 4)
        local animation1 = display.newAnimation(frames1, 0.4/5)
        local bltAction = cc.Repeat:create(cc.Animate:create(animation1),2)

        local sp2 = display.newSprite("#skillepo2201008_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        :align(display.CENTER, targetPosX, targetPosY)
        :hide()
        sp2:setScaleX(fireScaleX*2)
        sp2:setScaleY(2)
        if _member:getPositionX() < targetPosX then
            sp2:setPosition(targetPosX - sp2:getContentSize().width*0.3, targetPosY)
        else
            sp2:setPosition(targetPosX + sp2:getContentSize().width*0.3, targetPosY)
        end

        if startPos.y > targetPosY  then
            sp2:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp2:setRotation(-rotateNum)
        end

        local frames2 = display.newFrames("skillepo2201008_%02d.png", 0, 20)
        local animation2 = display.newAnimation(frames2, 0.5/20)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        bullet:runAction(cc.Spawn:create({
                                            bltAction,
                                            aniAction1,
                                      }))

        resumeSkill()
        sp2:runAction(transition.sequence({   
                                                cc.DelayTime:create(moveTime),
                                                cc.Show:create(),
                                                cc.CallFunc:create(function ( ... )
                                                    bullet:removeSelf()
                                                end),
                                                aniAction2,
                                                cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime + 0.2),
                                              cc.CallFunc:create(effectSkill)
                                          }))

        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
     --机械师 一把钉子
    if tonumber(self.BattleSkillInfo.skillId) == 2201002 then
        --三段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/3
        self.BattleSkillInfo.skillSection = 3
        local offSets = string.split(_member.m_skillStartPos,"|")
        local xOffset = 0.6
        local yOffset = 0.8
        local tSize = {width = display.width*0.1, height = display.width*0.1}
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local moveTime = 0
        local index = 0
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local  startPos = nil
             local fireScaleX = 1
             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*tSize.width, _member:getPositionY()+yOffset*tSize.height*_member.m_scaleNum)
                fireScaleX =  -1
             else
                startPos = cc.p(_member:getPositionX()-xOffset*tSize.width, _member:getPositionY()+yOffset*tSize.height*_member.m_scaleNum)
                fireScaleX = 1
             end
             local bullet = display.newSprite("#skillblt2201002_00.png",  startPos.x, startPos.y)
             :addTo(g_instance,SkillMemmberLevel)
             bullet:setScaleX(fireScaleX*BlockTypeScale)
             bullet:setScaleY(BlockTypeScale)
             local frames1 = display.newFrames("skillblt2201002_%02d.png", 0, 4)
             local animation1 = display.newAnimation(frames1, 0.4/5)
             local aniAction1 = cc.RepeatForever:create(cc.Animate:create(animation1))
             
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     index = index + 1
                     if index == 1 then
                         local sp2 = display.newSprite("#skillepo2201002_00.png", targetPosX, targetPosY)
                         :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                         local frames2 = display.newFrames("skillepo2201002_%02d.png", 0, 13)
                         local animation2 = display.newAnimation(frames2, 0.6/13)
                         local aniAction2 = cc.Animate:create(animation2)
                         sp2:runAction(transition.sequence({
                                                            aniAction2,
                                                            cc.CallFunc:create(sp2.removeSelf)
                                                         }))
                     end
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             moveTime = distance/(BulletMoveSpeed*2.5)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end
    --毛瑟
    if tonumber(self.BattleSkillInfo.skillId) == 2201006 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = 0.3
        local yOffset = 0.6
        printTable(_member.m_member:getBoundingBox())
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2201006.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo2201006_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        local frames2 = display.newFrames("skillepo2201006_%02d.png", 0, 4)
        local animation2 = display.newAnimation(frames2, 0.4/4)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
    --手榴弹
    if tonumber(self.BattleSkillInfo.skillId) == 2201007 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead ~= false then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2201007_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX*BlockTypeScale)
        sp1:setScaleY(BlockTypeScale)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local frames1 = display.newFrames("skillblt2201007_%02d.png", 0, 2)
        local animation1 = display.newAnimation(frames1, 0.2/3)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
        local aniAction1 = cc.Repeat:create(cc.Animate:create(animation1),math.floor(moveTime/0.2)+1)

        local sp2 = display.newSprite("#skillepo2201007_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        local frames2 = display.newFrames("skillepo2201007_%02d.png", 0, 9)
        local animation2 = display.newAnimation(frames2, 0.6/9)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                            aniAction1,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.2),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    --手枪
    if tonumber(self.BattleSkillInfo.skillId) == 2201004 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        function getEnermyInfo()
            if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         enermy = _member.m_enermy
                         targetPosX = enermy:getPositionX()
                         targetPosY = enermy:getPositionY()
                         break
                     end
                 end
            end
        end
        local  startPos = nil
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
        end
        local damageAll = self.BattleSkillInfo.skillBaseDamage
        local function fireBullet(_index)
             if _index == 1 then
                 self.BattleSkillInfo.skillBaseDamage = damageAll/5
                 self.BattleSkillInfo.skillSection = 5
             elseif _index == 2 then
                 self.BattleSkillInfo.skillBaseDamage = damageAll/5
                 self.BattleSkillInfo.skillSection = 5
             elseif _index == 3 then
                 self.BattleSkillInfo.skillBaseDamage = damageAll/(10/3)
                 self.BattleSkillInfo.skillSection = 10/3
             end
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = nil
             if _index == 1 or _index == 2 then
                 bullet = display.newSprite("Battle/Bullet/HeroBullet_1014.png")
             else
                 bullet = display.newSprite("#skillblt2201004.png")
             end
             bullet:addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum)
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                    if _index == 1 or _index == 2 then
                        enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                        local epoSp = display.newSprite("#beAtkEff_1014_00.png")
                        :pos(targetPosX, targetPosY)
                        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                        local epoFrames = display.newFrames("beAtkEff_1014_%02d.png", 0, 3)
                        local epoAnimation = display.newAnimation(epoFrames, 0.3/3)
                        local epoAction = cc.Animate:create(epoAnimation)
                        epoSp:runAction(transition.sequence({
                                                              epoAction,
                                                              cc.CallFunc:create(epoSp.removeSelf)
                                                            }))
                    else
                        local function effectDamage()
                              enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                        end
                        local epoSp = display.newSprite("#skillepo2201004_00.png")
                        :pos(targetPosX, targetPosY)
                        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                        local epoFrames = display.newFrames("skillepo2201004_%02d.png", 0, 13)
                        local epoAnimation = display.newAnimation(epoFrames, 0.6/13)
                        local epoAction = cc.Animate:create(epoAnimation)
                        epoSp:runAction(transition.sequence({
                                                              cc.CallFunc:create(effectDamage),
                                                              cc.Spawn:create(
                                                              {epoAction,
                                                               transition.sequence({
                                                                  cc.DelayTime:create(0.32),
                                                                  cc.CallFunc:create(effectDamage),
                                                               }),
                                                              }),
                                                              cc.CallFunc:create(epoSp.removeSelf)
                                                            }))

                    end
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*1.8)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(function()
                                                  fireBullet(1)
                                              end),
                                              cc.DelayTime:create(0.333),
                                              cc.CallFunc:create(function()
                                                  fireBullet(2)
                                              end),
                                              cc.DelayTime:create(0.566),
                                              cc.CallFunc:create(function()
                                                  fireBullet(3)
                                              end),
                                              cc.DelayTime:create(1.1),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end
  
    --火箭炮
    if tonumber(self.BattleSkillInfo.skillId) == 2201011 then
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX = 1
        end

        local sp2 = display.newSprite("#skillepo2201011_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX)
        if _member:getPositionX() < targetPosX then
            sp2:setPosition(targetPosX - sp2:getContentSize().width*0.3, targetPosY + sp2:getContentSize().height*0.3)
        else
            sp2:setPosition(targetPosX + sp2:getContentSize().width*0.3, targetPosY + sp2:getContentSize().height*0.3)
        end
        local frames2 = display.newFrames("skillepo2201011_%02d.png", 0, 9)
        local animation2 = display.newAnimation(frames2, 0.8/9)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        resumeSkill()

        sp2:runAction(transition.sequence({ 
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --朝天一炮
    if tonumber(self.BattleSkillInfo.skillId) == 2201010 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = 0.6
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2201010_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed*1.5)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo2201010_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        :scale(3)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo2201010_%02d.png", 0, 14)
        local animation2 = display.newAnimation(frames2, 0.8/14)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --MP40
    if tonumber(self.BattleSkillInfo.skillId) == 2201009 then
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/5
        self.BattleSkillInfo.skillSection = 5
        local offSets = string.split(_member.m_skillStartPos,"|")
        local xOffset = 0.6
        local yOffset = 0.65
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = display.newSprite("#skillblt2201009.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum)
             local  startPos = nil
                 
             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
             else
                startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
             end
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             local  epoScaleX = 0
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
                epoScaleX = -1
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
                epoScaleX = 1
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     local epoSp = display.newSprite("#skillepo2201009_00.png")
                     :pos(targetPosX, targetPosY)
                     :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                     epoSp:setScaleX(epoScaleX)
                     local epoFrames = display.newFrames("skillepo2201009_%02d.png", 0, 8)
                     local epoAnimation = display.newAnimation(epoFrames, 0.4/8)
                     local epoAction = cc.Animate:create(epoAnimation)
                     epoSp:runAction(transition.sequence({
                                                            epoAction,
                                                            cc.CallFunc:create(epoSp.removeSelf)
                                                         }))
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*1.8)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1333),
                                              cc.CallFunc:create(fireBullet),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end
    --喝参丸
    if tonumber(self.BattleSkillInfo.skillId) == 2208001 then
        local sLvl = _member.m_energySkills[MemberSkillType.kSkillHeroTwo].lvl
        local recoverHp = (skillData[2208001]["addPercent"] - skillData[2208001]["addPercentGF"]*sLvl)*_member.m_attackInfo.attackValue - skillData[2208001]["add"] - skillData[2208001]["addGF"]*sLvl
        _member:LiquidateDamage(recoverHp,false)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.3),
                                            cc.CallFunc:create(removeSkill),
                                           }))
    end
    --主角 滑板鞋
    if tonumber(self.BattleSkillInfo.skillId) == 2208002 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        if _member.m_allShields[tostring(buffID)] ~= nil then
            _member.buffControl:clearShield(_member,buffID)
        end
        _member.buffControl:addBuffer(_member,buffID)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.4)
    end

    --主角 火力支援
    if tonumber(self.BattleSkillInfo.skillId) == 2208003 then
        self.BattleSkillInfo.skillCoefficient = skillData[2208003]["addPercent"] + skillData[2208003]["addPercentGF"]*_member.m_energySkills[MemberSkillType.kSkillHeroFour].lvl

        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2]) 

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06

        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX =  1
        end

        local sp2 = display.newSprite("#skillepo2208003_00.png", targetPosX, targetPosY + display.width*0.1)
        :addTo(g_instance)
        sp2:setScaleX(fireScaleX*2)
        sp2:setScaleY(2)
        local frames2 = display.newFrames("skillepo2208003_%02d.png", 0, 19)
        local animation2 = display.newAnimation(frames2, 1.5/19)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        sp2:runAction(transition.sequence({ 
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.6),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --机械师 盾牌
    if tonumber(self.BattleSkillInfo.skillId) == 2208004 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local target
        for i=1,7 do
            if self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false then
                target = self.selfMemberList[i]
                break
            end
        end
        if target.m_allShields[tostring(buffID)] ~= nil then
            target.buffControl:clearShield(target,buffID)
        end
        _member.buffControl:addBuffer(target,buffID)

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.45) 

    end

    --机械师 药箱急救
    if tonumber(self.BattleSkillInfo.skillId) == 2208005 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local targetList = {}
        if _member.m_posType == MemberPosType.defenceType then
            targetList = MemberDeffenceList
        else
            targetList = MemberAttackList
        end

        local sLvl = _member.m_energySkills[MemberSkillType.kSkillHeroThree].lvl
        local recoverHp = (skillData[2208005]["addPercent"] - skillData[2208005]["addPercentGF"]*sLvl)*_member.m_attackInfo.attackValue - skillData[2208005]["add"] - skillData[2208005]["addGF"]*sLvl
        for k,v in pairs(targetList) do
            if v ~= nil and v.m_isDead == false then
                local spRecover = display.newSprite("#skillepo1103011_00.png")
                :addTo(v) 
                spRecover:align(display.CENTER_BOTTOM, v.m_member:getPositionX(), v.m_member:getPositionY() - spRecover:getContentSize().height*0.15)
                local framesRecover = display.newFrames("skillepo1103011_%02d.png", 0, 10)
                local animationRecover = display.newAnimation(framesRecover, 0.5/10)
                local aniActionRecover = cc.Animate:create(animationRecover)
                spRecover:runAction(transition.sequence({
                                                           aniActionRecover,
                                                           cc.CallFunc:create(function()
                                                               spRecover:removeSelf()
                                                           end)
                                                       }))
                v:LiquidateDamage(recoverHp,false)
            end
        end

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.8) 
    end

    --机械师 隔山打怪
    if tonumber(self.BattleSkillInfo.skillId) == 2208012 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        self.BattleSkillInfo.skillCoefficient = skillData[2208012]["addPercent"] + skillData[2208012]["addPercentGF"]*_member.m_energySkills[MemberSkillType.kSkillHeroFour].lvl
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        local enermy = nil
        for i=7,1,-1 do
            if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                enermy = _member.enermyList[i]
                break
            end
        end
        if enermy == nil or enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end


        local sp2 = display.newSprite("#skillepo2208012_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(1.6)
        sp2:setScaleY(1.6)
        sp2:setPosition(enermy:getPositionX(),enermy:getPositionY() + sp2:getContentSize().height*0.7)
        local frames2 = display.newFrames("skillepo2208012_%02d.png", 0, 13)
        local animation2 = display.newAnimation(frames2, 0.5/13)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                enermy:runAction(transition.sequence{
                                                       cc.EaseOut:create(cc.MoveBy:create(0.35,cc.p(0,display.height*0.18)),13),
                                                       cc.EaseIn:create(cc.MoveBy:create(0.25,cc.p(0,-display.height*0.18)),13),
                                                    })
            end
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        sp2:runAction(cc.Sequence:create({
                                            aniAction2,
                                            cc.CallFunc:create(removeSkill)
                                      }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --机械师 有钱任性
    if tonumber(self.BattleSkillInfo.skillId) == 2208006 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06

        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX =  1
        end

        local sp2 = display.newSprite("#skillepo2208006_00.png", targetPosX, targetPosY + display.width*0.03)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*2)
        sp2:setScaleY(2)
        local frames2 = display.newFrames("skillepo2208006_%02d.png", 0, 18)
        local animation2 = display.newAnimation(frames2, 2/18)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end
            if isMemberNil(_member) then
               _member:afterSkill()
            end   
        end
        local function removeSkill()
            sp2:removeSelf()
        end

        resumeSkill()

        sp2:runAction(transition.sequence({ 
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --格斗家 魅惑
    if tonumber(self.BattleSkillInfo.skillId) == 2208007 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]

        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.6
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        local sp2 = display.newSprite("#skillepo2208007_00.png")
        :addTo(g_instance)

        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
            for i=_member.m_targetIndex,7 do
                if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                    _member.m_targetIndex = i
                    _member.m_enermy = _member.enermyList[i]
                    break
                end
            end
        end
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
            resumeSkill()
            sp2:removeSelf()
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() + sp2:getContentSize().height*0.25
       
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2208007.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
        
        sp2:setPosition(targetPosX, targetPosY)
        sp2:setLocalZOrder(BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        local frames2 = display.newFrames("skillepo2208007_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.6/17)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)
        
        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.2),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

     --格斗家 一杯二锅头
    if tonumber(self.BattleSkillInfo.skillId) == 2208008 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        
        local function effectSkill()
            for i = 1, 7 do
                if self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false then
                    local sp2 = display.newSprite("#skillepo2208008_00.png")
                    :addTo(self.selfMemberList[i])
                    sp2:setPosition(0,sp2:getContentSize().height*0.6)
                    local frames2 = display.newFrames("skillepo2208008_%02d.png", 0, 12)
                    local animation2 = display.newAnimation(frames2, 0.5/13)
                    local aniAction2 = cc.Animate:create(animation2)
                    sp2:performWithDelay(function()
                        self.selfMemberList[i].buffControl:addBuffer(self.selfMemberList[i],buffID)
                    end,0.2)
                    sp2:runAction(transition.sequence({
                                                        aniAction2,
                                                        cc.CallFunc:create(function()
                                                            sp2:removeSelf()
                                                        end)
                                                      }))
                end
            end
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        effectSkill()
        self:performWithDelay(removeSkill,0.5)
    end
    
    --格斗家 狙击
    if tonumber(self.BattleSkillInfo.skillId) == 2208009 then
        self.BattleSkillInfo.skillCoefficient = skillData[2208009]["addPercent"] + skillData[2208009]["addPercentGF"]*_member.m_energySkills[MemberSkillType.kSkillHeroFour].lvl
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = 0.5
        local yOffset = 0.6

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        local enermy = nil
        for i=7,1,-1 do
            if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                enermy = _member.enermyList[i]
                break
            end
        end
        if enermy == nil or enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1

        local spTar = display.newSprite("#skilltar2208009_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        local framesTar = display.newFrames("skilltar2208009_%02d.png", 0, 14)
        local animationTar = display.newAnimation(framesTar, 0.99/14)
        local aniActionTar = cc.Animate:create(animationTar)
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
            spTar:setPosition(targetPosX - display.width*0.02,targetPosY)
            spTar:runAction(cc.Spawn:create({
                                               aniActionTar,
                                               transition.sequence({
                                                                      cc.MoveBy:create(0.66,cc.p(display.width*0.04,0)),
                                                                      cc.MoveBy:create(0.33,cc.p(-display.width*0.02,0))
                                                                   }),

                                            }))
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = 1
            spTar:setPosition(targetPosX + display.width*0.02,targetPosY)
            spTar:runAction(cc.Spawn:create({
                                               aniActionTar,
                                               transition.sequence({
                                                                      cc.MoveBy:create(0.66,cc.p(-display.width*0.04,0)),
                                                                      cc.MoveBy:create(0.33,cc.p(display.width*0.02,0))
                                                                   })    
                                            }))
        end
        spTar:performWithDelay(function()
                spTar:removeSelf()
        end,1)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2208009.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        sp1:setVisible(false)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo2208009_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        sp2:setVisible(false)
        local frames2 = display.newFrames("skillepo2208009_%02d.png", 0, 15)
        local animation2 = display.newAnimation(frames2, 0.5/15)
        local aniAction2 = cc.Animate:create(animation2)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp1()
            sp1:setVisible(true)
        end
        local function  showSp2()
            sp2:setVisible(true)
        end

        sp1:runAction(transition.sequence({ 
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(showSp1),
                                              cc.CallFunc:create(removeSkill),
                                              moveAction,
                                              cc.CallFunc:create(function()
                                                  sp1:removeSelf()
                                              end)
                                          }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(1 + moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(function()
                                                  sp2:removeSelf()
                                              end)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1 + moveTime + 0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    
    --主角战车群控
    if tonumber(self.BattleSkillInfo.skillId) == 1103003 or tonumber(self.BattleSkillInfo.skillId) == 1103040 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.2
        yOffset = 2.7

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        local enermy = nil
        for i=7,1,-1 do
            if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                enermy = _member.enermyList[i]
                break
            end
        end
        if enermy == nil or enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY-display.width*0.03
        local startPos = nil
        local fireScaleX = 2
        local fireScaleY = 2
        local rotateNum = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX = -2
            fireScaleY = 2
            rotateNum  = 22
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX =  2
            fireScaleY = 2
            rotateNum  = -22
        end
        local fireSp = display.newSprite("#skillblt1103003_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        fireSp:setRotation(rotateNum)
        fireSp:setScaleX(fireScaleX*BlockTypeScale)
        fireSp:setScaleY(fireScaleY*1.8*BlockTypeScale)
        local fireframes = display.newFrames("skillblt1103003_%02d.png", 0, 9)
        local fireanimation = display.newAnimation(fireframes, 0.8/9)
        local fireAction = cc.Animate:create(fireanimation)
        local epoSp = display.newSprite("#skillepo1103003_00.png")
        :addTo(g_instance,20)
        epoSp:align(display.CENTER_BOTTOM,targetPosX, targetPosY - epoSp:getContentSize().height*0.2)
        epoSp:setScaleX(fireScaleX*3.3*BlockTypeScale)
        epoSp:setScaleY(fireScaleY*1.8*BlockTypeScale)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo1103003_%02d.png", 0, 14)
        local epoanimation = display.newAnimation(epoframes, 1/14)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            printTable(targetList)
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            fireSp:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        resumeSkill()

        local function  showEpo()
            fireSp:setVisible(false)
            epoSp:setPosition(targetPosX, targetPosY - epoSp:getContentSize().height*0.2)
            epoSp:setVisible(true)
            if _member.m_seEpoSound ~= nil then
                audio.playSound("audio/musicEffect/skillEffect/".._member.m_seEpoSound..".mp3")
            end
        end
        
        if _member.m_seFireSound ~= nil then
            audio.playSound("audio/musicEffect/skillEffect/".._member.m_seFireSound..".mp3")
        end
        fireSp:runAction(cc.Spawn:create({
                                            fireAction,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.7),
                                              cc.CallFunc:create(showEpo),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    --主角战车加闪避
    if tonumber(self.BattleSkillInfo.skillId) == 1103004 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        if _member.m_allShields[tostring(buffID)] ~= nil then
            _member.buffControl:clearShield(_member,buffID)
        end
        _member.buffControl:addBuffer(_member,buffID)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.4)
    end
    --主角战车前排AOE(现在是吉普车技能)
    if tonumber(self.BattleSkillInfo.skillId) == 1103005 or tonumber(self.BattleSkillInfo.skillId) == 1103050 then
        if tonumber(self.BattleSkillInfo.skillId) == 1103050 then
            self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        end
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.04
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt1103005.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo1103005_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(1.3)
        local frames2 = display.newFrames("skillepo1103005_%02d.png", 0, 19)
        local animation2 = display.newAnimation(frames2, 0.55/9)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     --print("----------BattleSkillInfo")
                     --printTable(self.BattleSkillInfo)
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --猪脚战车 砂之守护
    if tonumber(self.BattleSkillInfo.skillId) == 1103039 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local targetList = {}
        if _member.m_posType == MemberPosType.defenceType then
            targetList = MemberDeffenceList
        else
            targetList = MemberAttackList
        end
        for k,v in pairs(targetList) do
            if v ~= nil and v.m_isDead == false then
                local spRecover = display.newSprite("#skillepo1103039_00.png")
                :addTo(v) 
                spRecover:align(display.CENTER_BOTTOM, v.m_member:getPositionX(), v.m_member:getPositionY() )
                local framesRecover = display.newFrames("skillepo1103039_%02d.png", 0, 22)
                local animationRecover = display.newAnimation(framesRecover, 0.5/10)
                local aniActionRecover = cc.Animate:create(animationRecover)
                local function effBuff()
                    local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
                    v.buffControl:addBuffer(v,buffID)
                end
                spRecover:runAction(transition.sequence({cc.DelayTime:create(0.6),
                                                           aniActionRecover,
                                                           cc.CallFunc:create(function()
                                                               spRecover:removeSelf()
                                                           end),
                                                           cc.CallFunc:create(effBuff)
                                                       }))
                
                
            end
        end

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,1.2) 
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --吉普车攻击BUFF
    if tonumber(self.BattleSkillInfo.skillId) == 1103007 or tonumber(self.BattleSkillInfo.skillId) == 1103043 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        _member.buffControl:addBuffer(_member,buffID)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.5)
    end

    --吉普车命中BUFF  （作废，换成火焰榴弹）
    if tonumber(self.BattleSkillInfo.skillId) == 1103008 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        _member.buffControl:addBuffer(_member,buffID)
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.5)
    end

    --救护车 装甲恢复
    if tonumber(self.BattleSkillInfo.skillId) == 1103011 or tonumber(self.BattleSkillInfo.skillId) == 1103048 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local targetList = {}
        if _member.m_posType == MemberPosType.defenceType then
            targetList = MemberDeffenceList
        else
            targetList = MemberAttackList
        end
        for k,v in pairs(targetList) do
            if v ~= nil and v.m_isDead == false then
                local spRecover = display.newSprite("#skillepo1103011_00.png")
                :addTo(v) 
                spRecover:align(display.CENTER_BOTTOM, v.m_member:getPositionX(), v.m_member:getPositionY() - spRecover:getContentSize().height*0.15)
                local framesRecover = display.newFrames("skillepo1103011_%02d.png", 0, 10)
                local animationRecover = display.newAnimation(framesRecover, 0.5/10)
                local aniActionRecover = cc.Animate:create(animationRecover)
                spRecover:runAction(transition.sequence({
                                                           aniActionRecover,
                                                           cc.CallFunc:create(function()
                                                               spRecover:removeSelf()
                                                           end)
                                                       }))
                local recoverHp = tonumber(skillData[tonumber(self.BattleSkillInfo.skillId)]["addPercent"])*_member.m_mainAtk - tonumber(skillData[tonumber(self.BattleSkillInfo.skillId)]["add"])
                v:LiquidateDamage(recoverHp,false) --加血的技能也有可能导致改变状态（战车最大血量为0时，加完血还是0，战车变为死亡状态）
            end
        end

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:performWithDelay(removeSkill,0.8) 
    end

    --救护车 光能护盾
    if tonumber(self.BattleSkillInfo.skillId) == 1103012 or tonumber(self.BattleSkillInfo.skillId) == 1103044 then
        local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]

        local targetList = {}
        if _member.m_posType == MemberPosType.defenceType then
            targetList = MemberDeffenceList
        else
            targetList = MemberAttackList
        end
        local targetMember = nil
        local minHp = 2
        for k,v in pairs(targetList) do
            if v~=nil and v.m_isDead == false then
                if v.m_attackInfo.curHp/v.m_attackInfo.maxHp < minHp then
                    minHp = v.m_attackInfo.curHp/v.m_attackInfo.maxHp
                    targetMember = v
                end
            end
        end

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        if targetMember == nil then
           return
        end

        if targetMember.m_allShields[tostring(buffID)] ~= nil then
            targetMember.buffControl:clearShield(targetMember,buffID)
        end
        targetMember.buffControl:addBuffer(targetMember,buffID,_member)

        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        removeSkill()
    end

    --救护车 腐蚀强酸
    if tonumber(self.BattleSkillInfo.skillId) == 1103013 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt1103013.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*3)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo1103013_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(fireScaleX*1.3)
        local frames2 = display.newFrames("skillepo1103013_%02d.png", 0, 7)
        local animation2 = display.newAnimation(frames2, 0.3/7)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --装甲车 眩晕打击
    if tonumber(self.BattleSkillInfo.skillId) == 1103015 or tonumber(self.BattleSkillInfo.skillId) == 1103045 or tonumber(self.BattleSkillInfo.skillId) == 1103046 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.15
        yOffset = 1.75
        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        local rotateNum = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX = -1
            rotateNum  = 18
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX =  1
            rotateNum  = -18
        end
        local fireSp = display.newSprite("#skillblt2208003_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        fireSp:setRotation(rotateNum)
        fireSp:setScaleX(fireScaleX)
        local fireframes = display.newFrames("skillblt2208003_%02d.png", 0, 5)
        local fireanimation = display.newAnimation(fireframes, 0.4/6)
        local fireAction = cc.Animate:create(fireanimation)
        local epoSp = display.newSprite("#skillepo2208003_00.png")
        :addTo(g_instance,centerInfo.zOrder)
        epoSp:setPosition(targetPosX, targetPosY+display.width*0.15)
        epoSp:setScaleX(fireScaleX*2)
        epoSp:setScaleY(2)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo2208003_%02d.png", 0, 19)
        local epoanimation = display.newAnimation(epoframes, 1.3/19)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end      
        end
        local function removeSkill()
            fireSp:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showEpo()
            fireSp:setVisible(false)
            epoSp:setVisible(true)
        end
        
        fireSp:runAction(cc.Spawn:create({
                                            fireAction,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(showEpo),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.8),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    --装甲车 强袭干扰
    if tonumber(self.BattleSkillInfo.skillId) == 1103016 or tonumber(self.BattleSkillInfo.skillId) == 1103047 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt1103016.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.7)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo1103016_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX)
        local frames2 = display.newFrames("skillepo1103016_%02d.png", 0, 7)
        local animation2 = display.newAnimation(frames2, 0.5/7)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    --装甲车 洲际导弹
    if tonumber(self.BattleSkillInfo.skillId) == 1103017 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0
        yOffset = 1.3
        local enermy = nil
        for i=7,1,-1 do
            if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                enermy = _member.enermyList[i]
                break
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if enermy == nil or enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local epoSp = display.newSprite("#skillepo1103017_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() + epoSp:getContentSize().height*0.3
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 80
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
            rotate = -80
        end
        local sp1 = display.newSprite("#skillblt1103017.png",  startPos.x, startPos.y)
        :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
        sp1:setScaleX(fireScaleX*0.6)
        sp1:setScaleY(0.6)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2)
        local rotateAction = cc.RotateBy:create(moveTime, rotate)

        local bezierConfig ={
            cc.p(startPos.x+display.width*0.1, startPos.y+display.height*0.35),
            cc.p(targetPosX-display.width*0.1, targetPosY+display.height*0.35),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        epoSp:setPosition(targetPosX,targetPosY)
        epoSp:setScaleX(fireScaleX*1.6)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo1103017_%02d.png", 0, 12)
        local epoanimation = display.newAnimation(epoframes, 1/13)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end
        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            epoSp:setVisible(true)
        end

        sp1:runAction(cc.Spawn:create({
                                            rotateAction,
                                            bezier,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----红狼双枪
    if tonumber(self.BattleSkillInfo.skillId) == 2208010 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.2
        local yOffset = tonumber(offSets[2])*1.2
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2208010_00.png",  (startPos.x + targetPosX)/2, (startPos.y + targetPosY)/2)
        :addTo(g_instance,centerInfo.zOrder)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*(distance/sp1:getContentSize().width))
        sp1:setScaleY(fireScaleX*2*2)
        local frames1 = display.newFrames("skillblt2208010_%02d.png", 0, 5)
        local animation1 = display.newAnimation(frames1, 0.3/6)
        local aniAction1 = cc.Animate:create(animation1)

        local sp2 = display.newSprite("#skillepo2208010_00.png", targetPosX, targetPosY*0.8)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*1.5*2)
        sp2:setScaleY(fireScaleX*1.5*2)
        local frames2 = display.newFrames("skillepo2208010_%02d.png", 0, 9)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----嗜血红狼
    if tonumber(self.BattleSkillInfo.skillId) == 2208011 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY*1.2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        printTable(startPos)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2208011_00.png",  startPos.x , startPos.y )
                        :addTo(display.getRunningScene(),centerInfo.zOrder)

        sp1:setScaleX(fireScaleX)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end

        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)
        local moveAction = cc.MoveTo:create(moveTime, cc.p(targetPosX,targetPosY))
        local aniAction1 = cc.Spawn:create({
                                            moveAction,
                                            cc.FadeTo:create(moveTime,0.4),
                                            cc.ScaleTo:create(moveTime,fireScaleX*1.3,1.3)
                                      })

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp1:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        sp1:runAction(transition.sequence({
                                              aniAction1,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----电磁花技能
    if tonumber(self.BattleSkillInfo.skillId) == 3014033 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014033_00.png",  (startPos.x + targetPosX)/2, (startPos.y + targetPosY)/2)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*(distance/sp1:getContentSize().width))
        sp1:setScaleY(fireScaleX*2)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014033_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014033_%02d.png", 0, 13)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----戈麦斯  精准打击
    if tonumber(self.BattleSkillInfo.skillId) == 1103023 or tonumber(self.BattleSkillInfo.skillId) == 1103019 or tonumber(self.BattleSkillInfo.skillId) == 1103041 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
            for i=_member.m_targetIndex,7 do
                if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                    _member.m_targetIndex = i
                    _member.m_enermy = _member.enermyList[i]
                    break
                end
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getLeastHpEnermy(_member)
        if centerInfo == nil then
            return
        end
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        print("英雄ID：".._member.m_attackInfo.tptId)
        local seblt = display.newSprite("#skillblt1103019_00.png")
                :pos(startPos.x,startPos.y+display.height*0.5)
                :addTo(display.getRunningScene(),centerInfo.zOrder)
       
        local rotateNum = math.deg(math.atan(math.abs((startPos.y+display.height*0.5 - targetPosY)/(startPos.x - targetPosX))))
        if startPos.x > targetPosX  then
            seblt:setRotation(-rotateNum)
        elseif startPos.x < targetPosX then
            seblt:setRotation(rotateNum)
        end

        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y - targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
        
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup1103019_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(1)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup1103019_%02d.png", 0, 15)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown1103019_00.png")
        :addTo(display.getRunningScene())
        speEpoDown:scale(1)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown1103019_%02d.png", 0, 15)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY*0.8)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY*0.75)
       
        
        local function removeSkill()
            seblt:removeSelf()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            seblt:setVisible(false)
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
        local function effectSkill()
            
            for k,v in pairs(centerInfo.effList) do
              if v ~= nil and v.m_isDead == false then
                  v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        resumeSkill()
        seblt:runAction(moveAction)
      
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
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----嗜血狂暴
    if tonumber(self.BattleSkillInfo.skillId) == 1103025  or tonumber(self.BattleSkillInfo.skillId) == 1103021 then
        print("嗜血狂暴,将要激发")
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
       
        local function effectSkill()
            if isMemberNil(_member) and _member.m_isDead == false then
                _member:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end

        resumeSkill()
        if isMemberNil(_member) then
             _member:afterSkill()
        end
        
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ---- 绝对火力
    if tonumber(self.BattleSkillInfo.skillId) == 1103031 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/8
        self.BattleSkillInfo.skillSection = 8
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX*0.93
        local targetPosY = centerInfo.posY*1.2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        --math.randomseed(os.time()) --modify by xiaopao
        startPos = cc.p((startPos.x+targetPosX)/2,display.height/2+targetPosY)
        
        print("英雄ID：".._member.m_attackInfo.tptId)
        local function fireAction() 
            startPos.x = startPos.x+ math.random(1,120)-60
            targetPosX = targetPosX + math.random(1,120)-60

            local seblt = display.newSprite("#skillblt1103031_00.png")
                    :pos(startPos.x,startPos.y)
                    :addTo(display.getRunningScene(),centerInfo.zOrder)

           
            local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
            if startPos.y > targetPosY  then
                seblt:setRotation(rotateNum)
            elseif startPos.y < targetPosY then
                seblt:setRotation(-rotateNum)
            end
            seblt:setScaleX(fireScaleX)
            local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y - targetPosY, 2))
            local moveTime = distance/(BulletMoveSpeed*2)
            local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
            
            
            local speEpoUp,epoActionUp,speEpoDown,epoActionDown
            --需要分层处理
            speEpoUp = display.newSprite("#skillepoup1103031_00.png")
            :addTo(display.getRunningScene(),centerInfo.zOrder)
            speEpoUp:scale(1.5)
            speEpoUp:setVisible(false)
            local epoframesUp = display.newFrames("skillepoup1103031_%02d.png", 0, 8)
            local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
            epoActionUp = cc.Animate:create(epoanimationUp)
            speEpoDown = display.newSprite("#skillepodown1103031_00.png")
            :addTo(display.getRunningScene(),0)
            speEpoDown:scale(1.5)
            speEpoDown:setVisible(false)
            local epoframesDown = display.newFrames("skillepodown1103031_%02d.png", 0, 16)
            local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
            epoActionDown = cc.Animate:create(epoanimationDown)
        
            speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY*0.7)
            speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY*0.7)
           
            local function showEpoSp()
                seblt:setVisible(false)
                speEpoUp:setVisible(true)
                speEpoDown:setVisible(true)
            end
            local function effectSkill()
                local targetList = {}
                if _member.m_posType == MemberPosType.defenceType then
                     targetList = MemberAttackList
                else
                     targetList = MemberDeffenceList
                end
                for i=1,7 do
                  if targetList[i] ~= nil and targetList[i].m_isDead == false then
                      targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                  end
                end     
            end
            seblt:runAction(moveAction)
            local function removeAni()
                seblt:removeSelf()
                speEpoUp:removeSelf()
                speEpoDown:removeSelf()
                
            end
          
            speEpoUp:runAction(transition.sequence({ 
                                            cc.DelayTime:create(moveTime),
                                            cc.CallFunc:create(showEpoSp),
                                            epoActionUp
                                          }))
            speEpoDown:runAction(transition.sequence({ 
                                            cc.DelayTime:create(moveTime),
                                            epoActionDown,
                                            cc.CallFunc:create(effectSkill),
                                            cc.CallFunc:create(removeAni),
                                          }))
        end
        local function removeSkill()
                if isMemberNil(_member) then
                    _member:afterSkill()
                end
            end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.DelayTime:create(3),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        
        --cc.Director:getInstance():getScheduler():setTimeScale(0.5)
    end

    ----电磁打击
    if tonumber(self.BattleSkillInfo.skillId) == 1103032 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()*1.1
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end

        print("xOffset: "..xOffset.."yOffset  : "..yOffset)
        print("tank size: ".._member.m_member:getContentSize().width)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt1103032_00.png",  (startPos.x + targetPosX)/2, (startPos.y + targetPosY)/2)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo1103032_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo1103032_%02d.png", 0, 13)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --静默辐射
    if tonumber(self.BattleSkillInfo.skillId) == 1103027 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(removeSkill),
                                              
                                          }))
    end
    --阳炎侵蚀
    if tonumber(self.BattleSkillInfo.skillId) == 1103028 or tonumber(self.BattleSkillInfo.skillId) == 1103042 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.12
        yOffset = 2.7
        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        local rotateNum = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX = -1
            rotateNum  = 18
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum*0.9)
            fireScaleX =  1
            rotateNum  = -18
        end
        local fireSp = display.newSprite("#skillblt1103028_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,SkillMemmberLevel)
        fireSp:setRotation(rotateNum)
        fireSp:setScaleX(fireScaleX*BlockTypeScale)
        local fireframes = display.newFrames("skillblt1103028_%02d.png", 0, 6)
        local fireanimation = display.newAnimation(fireframes, 0.8/9)
        local fireAction = cc.Animate:create(fireanimation)
        local epoSp = display.newSprite("#skillepo1103028_00.png")
        :addTo(g_instance,centerInfo.zOrder)
        epoSp:setPosition(targetPosX, targetPosY+epoSp:getContentSize().height*0.33)
        epoSp:setScaleX(fireScaleX*2.4*BlockTypeScale)
        --epoSp:setScaleX(2.4*BlockTypeScale)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo1103028_%02d.png", 0, 19)
        local epoanimation = display.newAnimation(epoframes, 1/14)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            fireSp:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function  showEpo()
            fireSp:setVisible(false)
            epoSp:setPosition(targetPosX, targetPosY+epoSp:getContentSize().height*0.33)
            epoSp:setVisible(true)
            if _member.m_seEpoSound ~= nil then
                audio.playSound("audio/musicEffect/skillEffect/".._member.m_seEpoSound..".mp3")
            end
        end
        
        if _member.m_seFireSound ~= nil then
            audio.playSound("audio/musicEffect/skillEffect/".._member.m_seFireSound..".mp3")
        end
        fireSp:runAction(cc.Spawn:create({
                                            fireAction,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.7),
                                              cc.CallFunc:create(showEpo),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))

        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----智能炮
    if tonumber(self.BattleSkillInfo.skillId) == 3014022 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.8
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()*1.1
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end

        print("xOffset: "..xOffset.."yOffset  : "..yOffset)
        print("tank size: ".._member.m_member:getContentSize().width)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014022_00.png",  (startPos.x + targetPosX)/2, (startPos.y + targetPosY)/2)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed*2)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014022_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014022_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --神秘的微笑
    if tonumber(self.BattleSkillInfo.skillId) == 3014027 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            _member:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end
    ----神风炮
    if tonumber(self.BattleSkillInfo.skillId) == 3014028 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.7
        local yOffset = tonumber(offSets[2])*1.3
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end

        print("xOffset: "..xOffset.."yOffset  : "..yOffset)
        print("tank size: ".._member.m_member:getContentSize().width)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014028_00.png",  (startPos.x + targetPosX)*0.6, (startPos.y + targetPosY)*0.6)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014028_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014028_%02d.png", 0, 15)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --酸蚁酸液喷射
    if tonumber(self.BattleSkillInfo.skillId) == 3014016 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset = 0.8
        yOffset = 0.8
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local enermy = _member.m_enermy
        local epoSp = display.newSprite("#skillepo3014016_00.png")
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() + epoSp:getContentSize().height*0.3
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 60
        else
            startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1*_member.m_scaleNum*_member.m_scaleNum, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
            fireScaleX = 1
            rotate = -60
        end
        printTable(startPos)
        local sp1 = display.newSprite("#skillblt3014016_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
        sp1:setScaleX(fireScaleX*0.6)
        sp1:setScaleY(0.6)
        sp1:setRotation(60)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)
        local bltframes = display.newFrames("skillblt3014016_%02d.png", 0, 3)
        local bltanimation = display.newAnimation(bltframes, 1/30)
        local bltAction = cc.Repeat:create(cc.Animate:create(bltanimation),3)

        local bezierConfig ={
            cc.p(startPos.x-display.width*0.1, startPos.y+display.height*0.2),
            cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.2),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        epoSp:setPosition(targetPosX,targetPosY)
        -- epoSp:setScaleX(fireScaleX*1.6)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo3014016_%02d.png", 0, 24)
        local epoanimation = display.newAnimation(epoframes, 1/13)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end
        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            epoSp:setVisible(true)
        end

        sp1:runAction(cc.Spawn:create({
                                            cc.RotateTo:create(moveTime, rotate),
                                            bltAction,
                                            bezier,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125/4)
    end

    ----导弹蛙弹跳导弹
    if tonumber(self.BattleSkillInfo.skillId) == 3014015 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014015_00.png",  startPos.x+fireScaleX*(-40) , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*1.5)
        sp1:setScaleY(fireScaleX*1.5)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014015_00.png", targetPosX, targetPosY*1.1)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014015_%02d.png", 0, 9)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----龟式炮弹
    if tonumber(self.BattleSkillInfo.skillId) == 3014019 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getBackSingle(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        print("英雄ID：".._member.m_attackInfo.tptId)
        local seblt = display.newSprite("#skillblt3014019_00.png")
                :pos(startPos.x,startPos.y)
                :addTo(display.getRunningScene(),28)

        local bltframes = display.newFrames("skillblt3014019_%02d.png", 0, 3)
        local bltanimation = display.newAnimation(bltframes, 1/30)
        local bltAction = cc.Repeat:create(cc.Animate:create(bltanimation),3)
       
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        if startPos.y > targetPosY  then
            seblt:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            seblt:setRotation(rotateNum)
        end

        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y - targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
        
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup3014019_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(1.5)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup3014019_%02d.png", 0, 8)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown3014019_00.png")
        :addTo(display.getRunningScene(),0)
        speEpoDown:scale(1.5)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown3014019_%02d.png", 0, 16)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY-display.width*0.12)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY-display.width*0.12)
       
        
        local function removeSkill()
            seblt:removeSelf()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            seblt:setVisible(false)
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        resumeSkill()
        seblt:runAction(cc.Spawn:create({
                                            moveAction,
                                            bltAction,
                                      }))
      
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
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --铜管乌贼技能1墨汁攻击
    if tonumber(self.BattleSkillInfo.skillId) == 3014025 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.5
        local yOffset = tonumber(offSets[2])*0.5
        xOffset = 0
        yOffset = 1.3
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local enermy = _member.m_enermy
        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06
        local epoSp = display.newSprite("#skillepo3014025_00.png")
        :addTo(g_instance,centerInfo.zOrder)
        
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 60
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
            rotate = -60
        end
        local sp1 = display.newSprite("#skillblt3014025_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX*0.6)
        sp1:setScaleY(0.6)
        sp1:setRotation(60)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)
        local bltframes = display.newFrames("skillblt3014025_%02d.png", 0, 3)
        local bltanimation = display.newAnimation(bltframes, 1/30)
        local bltAction = cc.Repeat:create(cc.Animate:create(bltanimation),3)

        local bezierConfig ={
            cc.p(startPos.x+display.width*0.1, startPos.y+display.height*0.35),
            cc.p(targetPosX-display.width*0.1, targetPosY+display.height*0.35),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        epoSp:setPosition(targetPosX,targetPosY)
        epoSp:setScaleX(fireScaleX*1.6)
        epoSp:setVisible(false)
        local epoframes = display.newFrames("skillepo3014025_%02d.png", 0, 24)
        local epoanimation = display.newAnimation(epoframes, 1/13)
        local epoAction = cc.Animate:create(epoanimation)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end
        resumeSkill()
        local function  showSp2()
            sp1:setVisible(false)
            epoSp:setVisible(true)
        end

        sp1:runAction(cc.Spawn:create({
                                            cc.RotateTo:create(moveTime, rotate),
                                            bltAction,
                                            bezier,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125/4)
    end

    ----铜管乌贼技能2触角攻击
    if tonumber(self.BattleSkillInfo.skillId) == 3014026 then
        print("铜管乌贼技能2触角攻击,正在激发")
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
       
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014026_00.png", targetPosX, targetPosY*1.1)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014026_%02d.png", 0, 9)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp2:setVisible(true)
        end
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.FadeOut:create(0.5),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --3014018 导弹车三连击
    if tonumber(self.BattleSkillInfo.skillId) == 3014018 then
        --三段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/3
        self.BattleSkillInfo.skillSection = 3
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset =  0.3
        yOffset =  0.8
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        targetPosY = targetPosY+display.width*0.12
        targetPosX = targetPosX
        local function fireBullet()
             local bullet = display.newSprite("#skillblt3014018_00.png")
             :addTo(g_instance,centerInfo.zOrder)
             local  startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
             bullet:pos(startPos.x, startPos.y)
             bullet:setRotation(30)
             
             local framesbullet = display.newFrames("skillblt3014018_%02d.png", 0, 1)
             local animationbullet = display.newAnimation(framesbullet, 0.2/3)
             local actionbullet = cc.Repeat:create(cc.Animate:create(animationbullet),1)

             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.5)
             local rotateAction = cc.RotateBy:create(moveTime, -90)

             local bezierConfig ={
                   cc.p(startPos.x-display.width*0.1, startPos.y+display.height*0.11),
                   cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.11),
                   cc.p(targetPosX, targetPosY)
             }
             -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
             local bezier = cc.BezierTo:create(moveTime, bezierConfig)
             
             local function effectSkill()
                for k,v in pairs(centerInfo.effList) do
                    --print(v.m_attackInfo.tptName.."   isSkilled")
                     if v ~= nil and v.m_isDead == false then
                         v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     end
                end
             end
             local function showEffect()
                   bullet:removeSelf()
                   local effectSp = display.newSprite("#skillepo3014018_00.png")
                   :pos(targetPosX, targetPosY)
                   :addTo(g_instance,centerInfo.zOrder)
                   effectSp:scale(1.5)
                   local function removeEffectSp()
                        effectSp:removeSelf()
                   end
                   local framesEffect = display.newFrames("skillepo3014018_%02d.png", 0, 8)
                   local animationEffect  = display.newAnimation(framesEffect, 1/13)
                   local actionEffect  = cc.Animate:create(animationEffect)
                   effectSp:runAction(transition.sequence({
                                                             actionEffect,
                                                             cc.CallFunc:create(removeEffectSp),
                                                          }))
                   effectSp:performWithDelay(effectSkill, 0.05)
             end
             bullet:runAction(transition.sequence({cc.Spawn:create({
                                                                      actionbullet,
                                                                      rotateAction,
                                                                      bezier
                                                                   }),
                                                   cc.CallFunc:create(showEffect),
                                                 }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.05),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(1)
    end

    ----喷火鳄攻击
    if tonumber(self.BattleSkillInfo.skillId) == 3014017 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])*0.6
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local centerInfo = self:getBackSingle(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014017_00.png",  startPos.x , startPos.y )
        :addTo(g_instance,centerInfo.zOrder)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)
        --sp1:setScaleY(fireScaleX*2)

        local moveTime = distance/(BulletMoveSpeed*1.8)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014017_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[centerInfo.zOrder])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014017_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.6/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----铁甲炮技能
    if tonumber(self.BattleSkillInfo.skillId) == 3014020 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014020_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*(distance/sp1:getContentSize().width))
        sp1:setScaleY(fireScaleX*2)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014020_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014020_%02d.png", 0, 14)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----狙击鸟技能
    if tonumber(self.BattleSkillInfo.skillId) == 3014034 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014034_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        local bltframes = display.newFrames("skillblt3014034_%02d.png", 0, 7)
        local bltanimation = display.newAnimation(bltframes, 1/30)
        local bltAction = cc.Repeat:create(cc.Animate:create(bltanimation),4)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed/2)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014034_00.png", targetPosX-display.width*0.02, targetPosY+display.width*0.02)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014034_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            bltAction,
                                            aniAction1
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----机械螃蟹
    if tonumber(self.BattleSkillInfo.skillId) == 3014021 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014021_00.png",  startPos.x , startPos.y )
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014021_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014021_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----鬼蜈蚣技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014037 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014037_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014037_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014037_%02d.png", 0, 14)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --鬼蜈蚣技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014036 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            _member:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----巨型炮技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014031 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local centerInfo = self:getFrontSingle(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        print("英雄ID：".._member.m_attackInfo.tptId)
        local seblt = display.newSprite("#skillblt3014031_00.png")
                :pos(startPos.x,startPos.y)
                :addTo(display.getRunningScene(),centerInfo.zOrder)
       
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        if startPos.y > targetPosY  then
            seblt:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            seblt:setRotation(rotateNum)
        end

        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y - targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
        
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup3014031_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(1.5)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup3014031_%02d.png", 0, 23)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown3014031_00.png")
        :addTo(display.getRunningScene(),0)
        speEpoDown:scale(1.5)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown3014031_%02d.png", 0, 23)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY*0.65)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY*0.65)
       
        
        local function removeSkill()
            seblt:removeSelf()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            seblt:setVisible(false)
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
                
        end
        resumeSkill()
        seblt:runAction(moveAction)
      
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
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(1.2),
                                            cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----巨型炮技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014032 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        print("英雄ID：".._member.m_attackInfo.tptId)
        
        
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y - targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)
        
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup3014032_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(1.5)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup3014032_%02d.png", 0, 15)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown3014032_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoDown:scale(1.5)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown3014032_%02d.png", 0, 15)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY*0.8)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY*0.8)
       
        
        local function removeSkill()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        resumeSkill()
      
        speEpoUp:runAction(transition.sequence({ 
                                        --cc.DelayTime:create(moveTime),
                                        cc.CallFunc:create(showEpoSp),
                                        epoActionUp,
                                        cc.CallFunc:create(removeSkill)
                                      }))
        speEpoDown:runAction(transition.sequence({ 
                                        --cc.DelayTime:create(moveTime),
                                        epoActionDown,
                                      }))
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ----甲壳虫的束缚
    if tonumber(self.BattleSkillInfo.skillId) == 3014029 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX+display.width*0.08
        local targetPosY = centerInfo.posY+display.width*0.15
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        
        local g_xOff = -30*fireScaleX
        local g_yOff = 30
        startPos.x = startPos.x+display.width*0.05
        startPos.y = startPos.y+display.width*0.07
        local function getTargetPt()
            local i = 0
            return function ()
                i = i+1
                return i
            end
        end
        local function fireAction()
            local i = getTargetPt()
            local g_target = cc.p(i()*g_xOff+startPos.x+(-100*fireScaleX),i()*g_yOff+startPos.y+100)
            local g_targetPosX = g_target.x
            local g_targetPosY = g_target.y
            local rotateNum = math.deg(math.atan(math.abs((startPos.y - g_targetPosY)/(startPos.x - g_targetPosX))))
            local sp1 = display.newSprite("#skillblt3014029_00.png",  startPos.x , startPos.y )
            :addTo(g_instance,centerInfo.zOrder)
            
            if startPos.y > g_targetPosY  then
                sp1:setRotation(-rotateNum)
            elseif startPos.y < g_targetPosY then
                sp1:setRotation(rotateNum)
            end
            local distance = math.sqrt(math.pow(startPos.x - g_targetPosX, 2) + math.pow(startPos.y -g_targetPosY, 2))
            sp1:setScaleX(fireScaleX)

            local moveTime = distance/(BulletMoveSpeed)
            local aniAction1 = cc.MoveTo:create(moveTime,cc.p(g_targetPosX,g_targetPosY))
            printTable(cc.p(g_targetPosX,g_targetPosY))
            local function removeBlt()
                sp1:removeSelf()
            end
            sp1:runAction(transition.sequence({
                aniAction1,
                cc.CallFunc:create(removeBlt)
                }))
        end
        

        local sp2 = display.newSprite("#skillepo3014029_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014029_%02d.png", 0, 54)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp2:removeSelf()
        end
        local function afterUseSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp2:setVisible(true)
        end
        
        sp2:runAction(transition.sequence({ 
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireAction),
                                              cc.CallFunc:create(afterUseSkill),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill),
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
    --甲壳虫硬甲
    if tonumber(self.BattleSkillInfo.skillId) == 3014030 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
       
        local function effectSkill()
            if isMemberNil(_member) and _member.m_isDead == false then
                _member:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end

        resumeSkill()
        if isMemberNil(_member) then
             _member:afterSkill()
        end
        
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
    --瓦鲁战车技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014041 then
        --四段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/4
        self.BattleSkillInfo.skillSection = 4
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset =  0.3
        yOffset =  0.8
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY()
        local function fireBullet()
             local bullet = display.newSprite("#skillblt3014041.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             local  startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
             bullet:pos(startPos.x, startPos.y)
             bullet:scale(0.4)
             bullet:setRotation(30)
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + bullet:getContentSize().width*0.2
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.5)
             local rotateAction = cc.RotateBy:create(moveTime, -90)

             local bezierConfig ={
                   cc.p(startPos.x-display.width*0.1, startPos.y+display.height*0.11),
                   cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.11),
                   cc.p(targetPosX, targetPosY)
             }
             -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
             local bezier = cc.BezierTo:create(moveTime, bezierConfig)
             
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
             end
             local function showEffect()
                   bullet:removeSelf()
                   local effectSp = display.newSprite("#skillepo3014041_00.png")
                   :pos(enermy:getPositionX(), enermy:getPositionY()+enermy.progress:getPositionY()/2)
                   :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                   local function removeEffectSp()
                        effectSp:removeSelf()
                   end
                   local framesEffect = display.newFrames("skillepo3014041_%02d.png", 0, 11)
                   local animationEffect  = display.newAnimation(framesEffect, 0.6/12)
                   local actionEffect  = cc.Animate:create(animationEffect)
                   effectSp:runAction(transition.sequence({
                                                             actionEffect,
                                                             cc.CallFunc:create(removeEffectSp),
                                                          }))
                   effectSp:performWithDelay(effectSkill, 0.1)
             end
             bullet:runAction(transition.sequence({cc.Spawn:create({
                                                                      rotateAction,
                                                                      bezier
                                                                   }),
                                                   cc.CallFunc:create(showEffect),
                                                 }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.05),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
    --瓦鲁战车技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014042 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            _member:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --中型坦克 眩晕打击
    if tonumber(self.BattleSkillInfo.skillId) == 1103035 or tonumber(self.BattleSkillInfo.skillId) == 1103049 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = -0.4
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurBackPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY*0.8
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local target1 = cc.p((startPos.x+targetPosX)*2/5,display.height+20)
        local rotateNum1 = math.deg(math.atan(math.abs((startPos.y - target1.y)/(startPos.x - target1.x))))
        local rotateNum = math.deg(math.atan(math.abs((target1.y - targetPosY)/(target1.x - targetPosX))))
        print("英雄ID：".._member.m_attackInfo.tptId)
        local seblt = display.newSprite("#skillblt1103035_00.png",startPos.x, startPos.y)
                :addTo(display.getRunningScene(),centerInfo.zOrder)
   
        seblt:setScaleX(fireScaleX)
        if startPos.y > target1.y  then
            seblt:setRotation(rotateNum1)
        elseif startPos.y < target1.y then
            seblt:setRotation(-rotateNum1)
        end
        local distance1 = math.sqrt(math.pow(startPos.x - target1.x, 2) + math.pow(startPos.y -target1.y, 2))
        local distance = math.sqrt(math.pow(target1.x - targetPosX, 2) + math.pow(target1.y -targetPosY, 2))
        local moveTime1 = distance1/(BulletMoveSpeed*2.5)
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = transition.sequence({ 
                                        cc.MoveTo:create(moveTime1,cc.p(target1.x,target1.y)),
                                        cc.CallFunc:create(function ()
                                            if target1.y > targetPosY  then
                                                seblt:setRotation(rotateNum)
                                            elseif target1.y < targetPosY then
                                                seblt:setRotation(-rotateNum)
                                            end
                                        end),
                                        cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY)),
                                      })
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup1103035_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(1.5)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup1103035_%02d.png", 0, 17)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown1103035_00.png")
        :addTo(display.getRunningScene())
        speEpoDown:scale(1.5)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown1103035_%02d.png", 0, 17)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,targetPosY)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,targetPosY)
       
        local function removeSkill()
            seblt:removeSelf()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            seblt:setVisible(false)
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
        end
        local function effectSkill()
            
            for k,v in pairs(centerInfo.effList) do
              if v ~= nil and v.m_isDead == false then
                  v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        resumeSkill()
        seblt:runAction(moveAction)
      
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
        
        self:runAction(transition.sequence({
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --中型坦克 高射火炮
    if tonumber(self.BattleSkillInfo.skillId) == 1103036 then
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurBackPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY 
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt1103036_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX)
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed*2.5)
        local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo1103036_00.png", targetPosX, targetPosY )
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*1.3)
        sp2:setScaleY(1.3)
        local frames2 = display.newFrames("skillepo1103036_%02d.png", 0, 16)
        local animation2 = display.newAnimation(frames2, 0.55/9)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            --调整位置
            if enermy ~= nil and enermy.m_isDead == false then
                targetPosX = enermy:getPositionX()
                targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
            end
            sp2:setPosition(targetPosX, targetPosY + display.width*0.1)
            sp2:setVisible(true)
        end
        sp1:runAction(cc.Spawn:create({
                                            moveAction,
                                      }))
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.3),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --反坦克兵炮击
    if tonumber(self.BattleSkillInfo.skillId) == 3014038 then
        --四段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/4
        self.BattleSkillInfo.skillSection = 4
        printTable(_member.m_energySkills)
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset =  0.3
        yOffset =  0.8
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY()
        local function fireBullet()
             local bullet = display.newSprite("#skillblt3014038_00.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             local  startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height)
             bullet:pos(startPos.x, startPos.y)
             bullet:scale(0.4)
             bullet:setRotation(30)
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + bullet:getContentSize().width*0.2
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.5)
             local rotateAction = cc.RotateBy:create(moveTime, -90)

             local bezierConfig ={
                   cc.p(startPos.x-display.width*0.1, startPos.y+display.height*0.11),
                   cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.11),
                   cc.p(targetPosX, targetPosY)
             }
             -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
             local bezier = cc.BezierTo:create(moveTime, bezierConfig)
             
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
             end
             local function showEffect()
                   bullet:removeSelf()
                   local effectSp = display.newSprite("#skillepo3014038_00.png")
                   :pos(enermy:getPositionX(), enermy:getPositionY()+enermy.progress:getPositionY()/2)
                   :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                   local function removeEffectSp()
                        effectSp:removeSelf()
                   end
                   local framesEffect = display.newFrames("skillepo3014038_%02d.png", 0, 16)
                   local animationEffect  = display.newAnimation(framesEffect, 0.6/12)
                   local actionEffect  = cc.Animate:create(animationEffect)
                   effectSp:runAction(transition.sequence({
                                                             actionEffect,
                                                             cc.CallFunc:create(removeEffectSp),
                                                          }))
                   effectSp:performWithDelay(effectSkill, 0.1)
             end
             bullet:runAction(transition.sequence({cc.Spawn:create({
                                                                      rotateAction,
                                                                      bezier
                                                                   }),
                                                   cc.CallFunc:create(showEffect),
                                                 }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.167),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.05),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --拦截碟炮击
    if tonumber(self.BattleSkillInfo.skillId) == 3014040 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        --四段伤害
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/4
        self.BattleSkillInfo.skillSection = 4
        printTable(_member.m_energySkills)
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        xOffset =  0.3
        yOffset =  0.8
        if _member.m_enermy == nil or  _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local enermy = _member.m_enermy
        local  offY = 10
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY() - offY
        local  startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width, 
                                _member:getPositionY())
        startPos.y = startPos.y+13
        local function fireBullet()
             targetPosY = targetPosY+offY
             startPos.y = startPos.y+offY
             local bullet = display.newSprite("#skillblt3014040_00.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             
             bullet:pos(startPos.x, startPos.y)
             bullet:scale(0.4)
             bullet:setRotation(30)
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + bullet:getContentSize().width*0.2
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.5)
             local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
             local moveAction = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))
             bullet:setRotation(-rotateNum)
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
             end
             local function showEffect()
                   bullet:removeSelf()
                   local effectSp = display.newSprite("#skillepo3014040_00.png")
                   :pos(enermy:getPositionX(), enermy:getPositionY()+enermy.progress:getPositionY()/2)
                   :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                   local function removeEffectSp()
                        effectSp:removeSelf()
                   end
                   local framesEffect = display.newFrames("skillepo3014040_%02d.png", 0, 5)
                   local animationEffect  = display.newAnimation(framesEffect, 0.6/12)
                   local actionEffect  = cc.Animate:create(animationEffect)
                   effectSp:runAction(transition.sequence({
                                                             actionEffect,
                                                             cc.CallFunc:create(removeEffectSp),
                                                          }))
                   effectSp:performWithDelay(effectSkill, 0.1)
             end
             bullet:runAction(transition.sequence({cc.Spawn:create({
                                                                      moveAction
                                                                   }),
                                                   cc.CallFunc:create(showEffect),
                                                 }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.05),
                                              cc.CallFunc:create(removeSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    --狂躁的流氓
    if tonumber(self.BattleSkillInfo.skillId) == 3014039 then
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            if isMemberNil(_member) then
                local buffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
                _member.buffControl:addBuffer(_member,buffID)
            end
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ----光防御器炮击
    if tonumber(self.BattleSkillInfo.skillId) == 3014043 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014043_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed*1.3)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014043_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014043_%02d.png", 0, 13)
        local animation2 = display.newAnimation(frames2, 0.8/11)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)

        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        --cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

    ---- 戈麦斯技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014047 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        -- self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/8
        -- self.BattleSkillInfo.skillSection = 8
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX*0.93
        local targetPosY = centerInfo.posY - 50
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX = 1
        end
        -- math.randomseed(os.time())
        
        print("英雄ID：".._member.m_attackInfo.tptId)
        local function fireAction() 
            targetPosX = targetPosX + math.random(1,240)-120
            targetPosY = targetPosY + math.random(1,40)-20
            
            local speEpo,epoAction
            --需要分层处理
            speEpo = display.newSprite("#skillepo3014047_00.png")
                :addTo(display.getRunningScene(),centerInfo.zOrder)
                :align(display.CENTER_BOTTOM,targetPosX,targetPosY)
                :scale(2)
            speEpo:scale(1.5)
            speEpo:setVisible(false)
            local epoframes = display.newFrames("skillepo3014047_%02d.png", 0, 27)
            local epoanimation = display.newAnimation(epoframes, 0.05)
            epoAction = cc.Animate:create(epoanimation)
           
            local function showEpoSp()
                speEpo:setVisible(true)
            end
            
            
            local function removeAni()
                speEpo:removeSelf()
            end
          
            speEpo:runAction(transition.sequence({ 
                                            cc.CallFunc:create(showEpoSp),
                                            epoAction,
                                            cc.CallFunc:create(removeAni),
                                          }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                if v ~= nil and v.m_isDead == false then
                    v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(removeSkill),
                                              
                                          }))
        
        --cc.Director:getInstance():getScheduler():setTimeScale(0.5)
    end

    --戈麦斯技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014048 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,9 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end       
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(removeSkill),
                                              
                                          }))
    end

    ----水母技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014045 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local targetPosX = enermy:getPositionX()
        local targetPosY = enermy:getPositionY() +  enermy.progress:getPositionY()/2
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014045_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed*1.5)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014045_00.png", targetPosX, targetPosY)
        :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
        :scale(3)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014045_%02d.png", 0, 41)
        local animation2 = display.newAnimation(frames2, 0.8/41)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            if enermy ~= nil and enermy.m_isDead == false then
                enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    ---- 水母技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014046 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        -- self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/8
        -- self.BattleSkillInfo.skillSection = 8
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX*0.93
        local targetPosY = centerInfo.posY - 80
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            fireScaleX = -1
        else
            fireScaleX = 1
        end
        -- math.randomseed(os.time())
        
        print("英雄ID：".._member.m_attackInfo.tptId)
        local function fireAction() 
            targetPosX = targetPosX + math.random(1,200)-100
            targetPosY = targetPosY + math.random(1,40)-20
            
            local speEpo,epoAction
            --需要分层处理
            speEpo = display.newSprite("#skillepo3014046_00.png")
                :addTo(display.getRunningScene(),centerInfo.zOrder)
                :align(display.CENTER_BOTTOM,targetPosX,targetPosY)
                :scale(3)
            speEpo:scale(1.5)
            speEpo:setVisible(false)
            local epoframes = display.newFrames("skillepo3014046_%02d.png", 0, 9)
            local epoanimation = display.newAnimation(epoframes, 0.05)
            epoAction = cc.Animate:create(epoanimation)
           
            local function showEpoSp()
                speEpo:setVisible(true)
            end
            
            
            local function removeAni()
                speEpo:removeSelf()
            end
          
            speEpo:runAction(transition.sequence({ 
                                            cc.CallFunc:create(showEpoSp),
                                            epoAction,
                                            cc.CallFunc:create(removeAni),
                                          }))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                if v ~= nil and v.m_isDead == false then
                    v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.DelayTime:create(0.8),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.CallFunc:create(effectSkill),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(fireAction),
                                              cc.DelayTime:create(0.15),
                                              cc.CallFunc:create(removeSkill),
                                              
                                          }))
        
        --cc.Director:getInstance():getScheduler():setTimeScale(0.5)
    end

    ----人鱼技能1
    if tonumber(self.BattleSkillInfo.skillId) == 3014049 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurFrontPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014049_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX)

        local moveTime = distance/(BulletMoveSpeed*1.5)
        
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local sp2 = display.newSprite("#skillepo3014049_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        :scale(2)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014049_%02d.png", 0, 8)
        local animation2 = display.newAnimation(frames2, 0.8/8)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)

        end

        local function floatUp(  )
            --泡泡浮上去特殊效果
            local offY = 80
            local enemy = centerInfo.effList[1]
            local sp3 = display.newSprite("#skillepo3014049_08.png")
                :addTo(g_instance,centerInfo.zOrder)
                :scale(2)
                :pos(enemy:getPositionX(),enemy:getPositionY())
            sp3:setAnchorPoint(cc.p(0.5,0.3))

            local frames3 = display.newFrames("skillepo3014049_%02d.png", 9, 11)
            local animation3 = display.newAnimation(frames3, 0.8/11)
            local aniAction3 = cc.Animate:create(animation3)

            local moveH = cc.MoveBy:create(0.5,cc.p(0,offY))
            sp3:runAction(transition.sequence{
                    cc.DelayTime:create(0.5),
                    moveH,
                    aniAction3,
                    cc.CallFunc:create(function ()
                        sp3:removeSelf()
                    end)
                    })

            moveH = cc.MoveBy:create(0.5,cc.p(0,offY))
            enemy:runAction(transition.sequence{
                    cc.DelayTime:create(0.5),
                    moveH,
                    cc.DelayTime:create(0.2),
                    cc.MoveBy:create(0.25,cc.p(0,-offY))
                    })
        end

        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              cc.CallFunc:create(floatUp),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill),
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1),
                                              cc.CallFunc:create(effectSkill)
                                          }))

        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end

     ----人鱼技能2
    if tonumber(self.BattleSkillInfo.skillId) == 3014050 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        startPos.y = targetPosY
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014050_00.png",  startPos.x , startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        :scale(4)
        sp1:setAnchorPoint(cc.p(0.14,0.34))
        
        if startPos.y > targetPosY  then
            sp1:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*4)

        local moveTime = distance/(BulletMoveSpeed)
        local aniAction1 = cc.MoveTo:create(moveTime,cc.p(targetPosX,targetPosY))

        local frames1 = display.newFrames("skillblt3014050_%02d.png", 0, 16)
        local animation1 = display.newAnimation(frames1, moveTime/16)
        local aniAction1_ = cc.Animate:create(animation1)

        aniAction1 = cc.Spawn:create(aniAction1_,aniAction1)

        local sp2 = display.newSprite("#skillepo3014050_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        :scale(2)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo3014050_%02d.png", 0, 8)
        local animation2 = display.newAnimation(frames2, 0.8/8)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                if v ~= nil and v.m_isDead == false then
                    v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp1:setVisible(false)
            sp2:setVisible(true)
        end
        sp1:runAction(aniAction1)
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        
    end

    ----机械光能球
    if tonumber(self.BattleSkillInfo.skillId) == 2201013 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(memberData[_member.m_attackInfo.tptId]["sklbslpos"],"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])*1.2
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY
        local startPos = nil
        local fireScaleX = 1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = 1
        end
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt2201013_02.png",  startPos.x  ,startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setAnchorPoint(cc.p(1.0,0.5))
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        sp1:setScaleX(fireScaleX*(distance/sp1:getContentSize().width)*1.1)
        sp1:setScaleY(fireScaleX*2)
        local frames1 = display.newFrames("skillblt2201013_%02d.png", 0, 10)
        local animation1 = display.newAnimation(frames1, 0.8/10)
        local aniAction1 = cc.Animate:create(animation1)

        local sp2 = display.newSprite("#skillepo2201013_00.png", targetPosX, targetPosY*0.8)
        :addTo(g_instance,centerInfo.zOrder)
        :scale(2)
        sp2:setScaleX(fireScaleX*1.5)
        sp2:setScaleY(fireScaleX*1.5)
        local frames2 = display.newFrames("skillepo2201013_%02d.png", 0, 14)
        local animation2 = display.newAnimation(frames2, 0.8/14)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp1:removeSelf()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            
            sp2:setVisible(true)
        end
        sp1:runAction(transition.sequence{aniAction1,cc.CallFunc:create(function ( ... )
            sp1:setVisible(false)
        end)})
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.2),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))

        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    end
    
    ---雪兔  三枪拍案
    if tonumber(self.BattleSkillInfo.skillId) == 2208013 then
        self.BattleSkillInfo.skillBaseDamage = self.BattleSkillInfo.skillBaseDamage/3
        self.BattleSkillInfo.skillSection = 3
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*1.3
        local yOffset = tonumber(offSets[2])*0.93

        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local enermy = _member.m_enermy
        local  targetPosX = enermy:getPositionX()
        local  targetPosY = enermy:getPositionY()
        local function fireBullet()
             if enermy ~= nil and enermy.m_isDead == false then
                 targetPosX = enermy:getPositionX()
                 targetPosY = enermy:getPositionY() + enermy.progress:getPositionY()/2
             end
             local bullet = display.newSprite("#skillblt2208013.png")
             :addTo(g_instance,BattleDisplayLevel[_member.fightPos])
             bullet:scale(_member.m_scaleNum)
             bullet:setScaleX(-_member.m_scaleNum)
             local  startPos = nil
                 
             if _member:getPositionX() < targetPosX then
                startPos = cc.p(_member:getPositionX()+xOffset*display.width*0.1, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
             else
                startPos = cc.p(_member:getPositionX()-xOffset*display.width*0.1, _member:getPositionY()+yOffset*display.width*0.1*_member.m_scaleNum)
             end
             bullet:pos(startPos.x, startPos.y)
             local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX)))) + 180
             if startPos.x > targetPosX then
                if startPos.y > targetPosY  then
                    bullet:setRotation(-rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(rotateNum)
                end
             else
                if startPos.y > targetPosY  then
                    bullet:setRotation(rotateNum)
                elseif startPos.y < targetPosY then
                    bullet:setRotation(-rotateNum)
                end
             end
             local function effectSkill()
                 if enermy ~= nil and enermy.m_isDead == false and isMemberNil(_member) and _member.m_isDead == false then
                     enermy:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                     local epoSp = display.newSprite("#skillepo2208013_00.png")
                     :pos(targetPosX, targetPosY)
                     :addTo(g_instance,BattleDisplayLevel[enermy.fightPos])
                     epoSp:scale(2)
                     local epoFrames = display.newFrames("skillepo2208013_%02d.png", 0, 17)
                     local epoAnimation = display.newAnimation(epoFrames, 0.5/17)
                     local epoAction = cc.Animate:create(epoAnimation)
                     epoSp:runAction(transition.sequence({
                                                            epoAction,
                                                            cc.CallFunc:create(epoSp.removeSelf)
                                                         }))
                 end
                 bullet:removeSelf()
             end
             local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
             local moveTime = distance/(BulletMoveSpeed*2.2)
             local move = cc.MoveBy:create(moveTime, cc.p(targetPosX-bullet:getPositionX(),targetPosY-bullet:getPositionY()))
             local call = cc.CallFunc:create(effectSkill)
             bullet:runAction(transition.sequence({move,call}))
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        self:runAction(transition.sequence({
                                              cc.CallFunc:create(resumeSkill),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(fireBullet),
                                              cc.DelayTime:create(0.3),
                                              cc.CallFunc:create(fireBullet),
                                              cc.CallFunc:create(removeSkill)
                                          }))
    end
    ---雪兔  冰冻激光
    if tonumber(self.BattleSkillInfo.skillId) == 2208014 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        printTable(offSets)
        local xOffset = tonumber(offSets[1])*0.8
        local yOffset = tonumber(offSets[2])*1.2
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                        if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                             _member.m_targetIndex = i
                             _member.m_enermy = _member.enermyList[i]
                             break
                        end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX*1.1
        local targetPosY = _member:getPositionY() + display.width*0.08

        if _member:getPositionX() < targetPosX then
            fireScaleX = 1
        else
            fireScaleX = -1
        end
        local sp2 = display.newSprite("#skillepo2208014_00.png", targetPosX, targetPosY)
        :addTo(g_instance,centerInfo.zOrder)
        sp2:setScaleX(fireScaleX*2.5)
        sp2:setScaleY(fireScaleX*2.5)
        local frames2 = display.newFrames("skillepo2208014_%02d.png", 0, 32)
        local animation2 = display.newAnimation(frames2, 1/32)
        local aniAction2 = cc.Animate:create(animation2)
        sp2:setVisible(false)

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp2:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        local function  showSp2()
            sp2:setVisible(true)
        end
        sp2:runAction(transition.sequence({ 
                                              cc.DelayTime:create(0.4),
                                              cc.CallFunc:create(showSp2),
                                              aniAction2,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.9),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --神武炮击
    if tonumber(self.BattleSkillInfo.skillId) == 3014051 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.5
        local yOffset = tonumber(offSets[2])*0.5
        xOffset = 0
        yOffset = 1.3
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local enermy = _member.m_enermy
        local centerInfo = self:getCurBackPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06
        
        
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 40
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum-20, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum-15)
            fireScaleX = 1
            rotate = -40
        end
        local sp1 = display.newSprite("#skillblt3014051_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX*0.6)
        sp1:setScaleY(0.6)
        sp1:setRotation(40)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)

        local bezierConfig ={
            cc.p(startPos.x-display.width*0.3, startPos.y+display.height*0.2),
            cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.2),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        local speEpoUp,epoActionUp,speEpoDown,epoActionDown
        --需要分层处理
        speEpoUp = display.newSprite("#skillepoup3014051_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(2)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepoup3014051_%02d.png", 0, 14)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        speEpoDown = display.newSprite("#skillepodown3014051_00.png")
        :addTo(display.getRunningScene())
        speEpoDown:scale(2)
        speEpoDown:setVisible(false)
        local epoframesDown = display.newFrames("skillepodown3014051_%02d.png", 0, 19)
        local epoanimationDown = display.newAnimation(epoframesDown, 0.05)
        epoActionDown = cc.Animate:create(epoanimationDown)
    
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,display.height*0.20)
        speEpoDown:align(display.CENTER_BOTTOM,targetPosX ,display.height*0.20)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end

        local function removeSkill()
            sp1:removeSelf()
            speEpoUp:removeSelf()
            speEpoDown:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            sp1:setVisible(false)
            speEpoUp:setVisible(true)
            speEpoDown:setVisible(true)
            print("显示epo")
        end
        resumeSkill()

        sp1:runAction(cc.Spawn:create({
                                            cc.RotateTo:create(moveTime, rotate),
                                            bezier,
                                      }))
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

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125/14)
    end

    --机械河马炮击
    if tonumber(self.BattleSkillInfo.skillId) == 3014044 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.5
        local yOffset = tonumber(offSets[2])*0.5
        xOffset = 0
        yOffset = 1.3
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local enermy = _member.m_enermy
        local centerInfo = self:getCurBackPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06
        
        
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 50
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getContentSize().width*_member.m_scaleNum-30, _member:getPositionY()+yOffset*_member.m_member:getContentSize().height*_member.m_scaleNum-20)
            fireScaleX = 1
            rotate = -50
        end
        local sp1 = display.newSprite("#skillblt3014044_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX)
        sp1:setRotation(50)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)

        local bezierConfig ={
            cc.p(startPos.x-display.width*0.3, startPos.y+display.height*0.2),
            cc.p(targetPosX+display.width*0.1, targetPosY+display.height*0.2),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)
        
        local speEpoUp,epoActionUp
        --需要分层处理
        speEpoUp = display.newSprite("#skillepo3014044_00.png")
        :addTo(display.getRunningScene(),centerInfo.zOrder)
        speEpoUp:scale(2)
        speEpoUp:setVisible(false)
        local epoframesUp = display.newFrames("skillepo3014044_%02d.png", 0, 14)
        local epoanimationUp = display.newAnimation(epoframesUp, 0.05)
        epoActionUp = cc.Animate:create(epoanimationUp)
        
        speEpoUp:align(display.CENTER_BOTTOM,targetPosX,display.height*0.20)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end

        local function removeSkill()
            sp1:removeSelf()
            speEpoUp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            sp1:setVisible(false)
            speEpoUp:setVisible(true)
            print("显示epo")
        end

        resumeSkill()
        sp1:runAction(cc.Spawn:create({
                                            cc.RotateTo:create(moveTime, rotate),
                                            bezier,
                                      }))
        speEpoUp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showEpoSp),
                                              epoActionUp,
                                              cc.CallFunc:create(removeSkill)
                                          }))

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125*4)
    end

    ----垃圾怪半月斩
    if tonumber(self.BattleSkillInfo.skillId) == 3014052 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])
        local yOffset = tonumber(offSets[2])
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end

        local centerInfo = self:getCurCenterPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY*1.2
        local startPos = nil
        local fireScaleX = 1
        local fireScaleY = -1
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = 1
        else
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum, _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
        end
        printTable(startPos)
        local rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
        local sp1 = display.newSprite("#skillblt3014052_00.png",  startPos.x , startPos.y )
                        :addTo(display.getRunningScene(),centerInfo.zOrder)
                        :hide()

        sp1:setScaleX(fireScaleX)
        sp1:setScaleY(fireScaleY)
        
        if startPos.y > targetPosY  then
            sp1:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
            sp1:setRotation(-rotateNum)
        end

        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)*1.5
        local moveAction = cc.MoveTo:create(moveTime, cc.p(targetPosX,targetPosY))
        local aniAction1 = cc.Spawn:create({
                                            cc.Show:create(),
                                            moveAction,
                                            cc.ScaleTo:create(moveTime,fireScaleX*1.3,fireScaleY*1.3)
                                      })
        animation1 = transition.sequence{aniAction1,cc.FadeTo:create(0.5,200)}

        local function effectSkill()
            local targetList = {}
            if _member.m_posType == MemberPosType.defenceType then
                 targetList = MemberAttackList
            else
                 targetList = MemberDeffenceList
            end
            for i=1,7 do
              if targetList[i] ~= nil and targetList[i].m_isDead == false then
                  targetList[i]:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
              end
            end     
        end
        local function removeSkill()
            sp1:removeSelf()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
        end

        resumeSkill()

        sp1:runAction(transition.sequence({
                                              cc.DelayTime:create(0.22),
                                              aniAction1,
                                              cc.CallFunc:create(removeSkill)
                                          }))
        
        self:runAction(transition.sequence({
                                              cc.DelayTime:create(0.22+0.5),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125/2)
    end
    
    --垃圾怪激光
    if tonumber(self.BattleSkillInfo.skillId) == 3014053 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local centerInfo = self:getCurCenterPoint(_member)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              --cc.DelayTime:create(0.1),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end

    --沙漠之舟Casting1
    if tonumber(self.BattleSkillInfo.skillId) == 3014054 then
        print("---------shamozhizhou Casting1")
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do 
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        resumeSkill()
        local centerInfo = self:getCurCenterPoint(_member)

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                 if v ~= nil and v.m_isDead == false then
                     v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                 end
            end
        end
        local function removeSkill()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(1.3),
                                              cc.CallFunc:create(removeSkill),
                                              cc.CallFunc:create(effectSkill)
                                          }))
    end    

    ----沙漠之舟Casting2
    if tonumber(self.BattleSkillInfo.skillId) == 3014055 then
        self.BattleSkillInfo.skillBuffID = skillData[self.BattleSkillInfo.skillId]["buffId"]
        local offSets = string.split(_member.m_bltPos,"|")
        local xOffset = tonumber(offSets[1])*0.5
        local yOffset = tonumber(offSets[2])*0.5
        xOffset = 0.3
        yOffset = 0.65
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then
                 for i=_member.m_targetIndex,7 do
                     if _member.enermyList[i] ~= nil and _member.enermyList[i].m_isDead == false then
                         _member.m_targetIndex = i
                         _member.m_enermy = _member.enermyList[i]
                         break
                     end
                 end
        end
        local function resumeSkill()
            _member.m_isShowSkill = false
            for i = 1, 7 do
                if i ~= _member.fightPos and self.selfMemberList[i] ~= nil and self.selfMemberList[i].m_isDead == false and self.selfMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            for i = 1, 7 do
                if i ~= _member.fightPos and self.enermyMemberList[i] ~= nil and self.enermyMemberList[i].m_isDead == false and self.enermyMemberList[i].m_isShowSkill == true then
                    return
                end
            end
            g_instance.skillLayer:setVisible(false)
            skillResumeMembers()
        end
        if _member.m_enermy == nil or _member.m_enermy.m_isDead == true then --无有效敌人
            resumeSkill()
            if isMemberNil(_member) then
               _member:afterSkill()
            end
            return
        end
        local enermy = _member.m_enermy
        local centerInfo = self:getCurBackPoint(_member)
        local targetPosX = centerInfo.posX
        local targetPosY = centerInfo.posY + display.width*0.06
        
        
        local startPos = nil
        local fireScaleX = 1
        local rotate = 0
        if _member:getPositionX() < targetPosX then
            startPos = cc.p(_member:getPositionX()+xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum,
                             _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum)
            fireScaleX = -1
            rotate = 30
        else
            --print("ttttt=".._member.m_member:getBoundingBox().width) --这个width打印出来居然是0
            startPos = cc.p(_member:getPositionX()-xOffset*_member.m_member:getBoundingBox().width*_member.m_scaleNum-25,
                             _member:getPositionY()+yOffset*_member.m_member:getBoundingBox().height*_member.m_scaleNum+25)
            fireScaleX = 1
            rotate = -30
        end
        local sp1 = display.newSprite("#skillblt3014055_00.png",  startPos.x, startPos.y)
        :addTo(g_instance,centerInfo.zOrder)
        sp1:setScaleX(fireScaleX*0.6)
        sp1:setScaleX(0.6)
        sp1:setScaleY(0.6)
        sp1:setRotation(60)
        local distance = math.sqrt(math.pow(startPos.x - targetPosX, 2) + math.pow(startPos.y -targetPosY, 2))
        local moveTime = distance/(BulletMoveSpeed)

        local bezierConfig ={
            cc.p(startPos.x-display.width*0.15, startPos.y+display.height*0.3),
            cc.p(targetPosX+display.width*0.15, targetPosY+display.height*0.3),
            cc.p(targetPosX, targetPosY)
        }
        -- 创建贝塞尔曲线动作，第一个参数为持续时间，第二个参数为贝塞尔曲线结构
        local bezier = cc.BezierTo:create(moveTime, bezierConfig)

        local epoSp = display.newSprite("#skillepo3014055_00.png")
        :addTo(g_instance,centerInfo.zOrder)
        epoSp:setPosition(targetPosX,targetPosY)
        epoSp:setVisible(false)

        local epoframes = display.newFrames("skillepo3014055_%02d.png", 0, 6)
        local epoanimation = display.newAnimation(epoframes, 0.7/7)
        local epoAction = cc.Animate:create(epoanimation)                

        local function effectSkill()
            for k,v in pairs(centerInfo.effList) do
                --print(v.m_attackInfo.tptName.."   isSkilled")
                if v ~= nil and v.m_isDead == false then
                    v:beSkilled(self.BattleSkillInfo, _member.m_attackInfo)
                end
            end
        end

        local function removeSkill()
            sp1:removeSelf()
            epoSp:removeSelf()
            if isMemberNil(_member) then
                _member:afterSkill()
            end
        end
        local function showEpoSp()
            sp1:setVisible(false)
            epoSp:setVisible(true)
            print("显示epo")
        end
        resumeSkill()

        sp1:runAction(cc.Spawn:create({
                                            cc.RotateTo:create(moveTime, rotate),
                                            bezier,
                                      }))
        epoSp:runAction(transition.sequence({ 
                                              cc.DelayTime:create(moveTime),
                                              cc.CallFunc:create(showEpoSp),
                                              epoAction,
                                              cc.CallFunc:create(removeSkill)
                                          }))

        self:runAction(transition.sequence({
                                              cc.DelayTime:create(moveTime+0.15),
                                              cc.CallFunc:create(effectSkill)
                                          }))
        -- cc.Director:getInstance():getScheduler():setTimeScale(0.125/14)
    end
    
end

    

--获取全屏攻击的目标点
function SkillAI:getCurCenterPoint(_member)
    local targetList = {}
    if _member.m_posType == MemberPosType.defenceType then
         targetList = MemberAttackList
    else
         targetList = MemberDeffenceList
    end
    local maxX = -10000
    local maxY = -10000
    local maxZ = -10000
    local minX = 10000
    local minY = 10000 
    local minZ = 10000
    local tmpEffList = {}
    for i=1,7 do
        if targetList[i] ~= nil and targetList[i].m_isDead == false then
            table.insert(tmpEffList,#tmpEffList+1,targetList[i])
            local curX = targetList[i]:getPositionX()
            local curY = targetList[i]:getPositionY()
            local curZ = BattleDisplayLevel[targetList[i].fightPos]
            if curX < minX then
                minX = curX
            end
            if curX > maxX then
                maxX = curX
            end
            if curY < minY then
                minY = curY
            end
            if curY > maxY then
                maxY = curY
            end
            if curZ < minZ then
                minZ = curZ
            end
            if curZ > maxZ then
                maxZ = curZ
            end
        end
    end        
    return {
              zOrder = math.floor((minZ + maxZ)/2),
              posX = (minX + maxX)/2,
              posY = (minY + maxY)/2,
              effList = tmpEffList,
           }
end

--获取前排攻击的目标点
function SkillAI:getCurFrontPoint(_member)
    local targetList = {}
    if _member.m_posType == MemberPosType.defenceType then
         targetList = MemberAttackList
    else
         targetList = MemberDeffenceList
    end
    local maxX = -10000
    local maxY = -10000
    local maxZ = -10000
    local minX = 10000
    local minY = 10000
    local minZ = 10000
    local tmpEffList = {}
    local num = 0
    for i=1,7 do
        if targetList[i] ~= nil and targetList[i].m_isDead == false then
            num = num +1
            table.insert(tmpEffList,#tmpEffList+1,targetList[i])
            local curX = targetList[i]:getPositionX()
            local curY = targetList[i]:getPositionY()
            local curZ = BattleDisplayLevel[targetList[i].fightPos]
            if curX < minX then
                minX = curX
            end
            if curX > maxX then
                maxX = curX
            end
            if curY < minY then
                minY = curY
            end
            if curY > maxY then
                maxY = curY
            end
            if curZ < minZ then
                minZ = curZ
            end
            if curZ > maxZ then
                maxZ = curZ
            end
            if num >= 3 then
                break
            end
        end
    end 
    return {
              zOrder = math.floor((minZ + maxZ)/2),
              posX = (minX + maxX)/2,
              posY = (minY + maxY)/2,
              effList = tmpEffList,
           }
end

--获取后排攻击的目标点
function SkillAI:getCurBackPoint(_member)
    local targetList = {}
    if _member.m_posType == MemberPosType.defenceType then
         targetList = MemberAttackList
    else
         targetList = MemberDeffenceList
    end
    local maxX = -10000
    local maxY = -10000
    local maxZ = -10000
    local minX = 10000
    local minY = 10000
    local minZ = 10000
    local num = 0
    local tmpEffList = {}

    for i=7,1,-1 do
        if targetList[i] ~= nil and targetList[i].m_isDead == false then
            num = num +1
            table.insert(tmpEffList,#tmpEffList+1,targetList[i])
            local curX = targetList[i]:getPositionX()
            local curY = targetList[i]:getPositionY()
            local curZ = BattleDisplayLevel[targetList[i].fightPos]
            if curX < minX then
                minX = curX
            end
            if curX > maxX then
                maxX = curX
            end
            if curY < minY then
                minY = curY
            end
            if curY > maxY then
                maxY = curY
            end
            if curZ < minZ then
                minZ = curZ
            end
            if curZ > maxZ then
                maxZ = curZ
            end
            if num >= 2 then
                break
            end
        end
    end        
    return {
              zOrder = math.floor((minZ + maxZ)/2),
              posX = (minX + maxX)/2,
              posY = (minY + maxY)/2,
              effList = tmpEffList,
           }
end
--获得血量百分比最少的敌人
function SkillAI:getLeastHpEnermy(_member)
    local targetList = {}
    if _member.m_posType == MemberPosType.defenceType then
         targetList = MemberAttackList
    else
         targetList = MemberDeffenceList
    end
    local enermy = nil
    local firstIdx = 0

    for i=1,7 do --先找出第一个活着的敌人
        if targetList[i] ~= nil and targetList[i].m_isDead == false and targetList[i].m_attackInfo.curHp > 0 then  
            enermy = targetList[i]
            firstIdx = i
            break
        end      
    end

    if firstIdx == 0 then --找不到敌人
        return nil
    end

    for i=firstIdx+1,7 do
        if targetList[i] ~= nil and targetList[i].m_isDead == false then
            if targetList[i].m_attackInfo.curHp > 0 and targetList[i].m_attackInfo.curHp < enermy.m_attackInfo.curHp then
                enermy = targetList[i]
            end            
        end
    end 

    return {
    posX = enermy:getPositionX(),
    posY = enermy:getPositionY(),
    zOrder = BattleDisplayLevel[enermy.fightPos],
    effList = {enermy}
}
end
--获得后排单体
function SkillAI:getBackSingle(_member)
    -- local targetList = {}
    -- if _member.m_posType == MemberPosType.defenceType then
    --      targetList = MemberAttackList
    -- else
    --      targetList = MemberDeffenceList
    -- end
    -- local enermy = nil
    -- for i=7,1,-1 do
    --     if targetList[i] ~= nil and targetList[i].m_isDead == false then
    --         enermy = targetList[i]
    --         break
    --     end
    -- end
    local enermyTab = _member:findIndex()
    local enermy = enermyTab._farthestEnemy
    return {
    posX = enermy:getPositionX(),
    posY = enermy:getPositionY(),
    zOrder = BattleDisplayLevel[enermy.fightPos],
    effList = {enermy}
}
end

--获得前排单体
function SkillAI:getFrontSingle(_member)
    -- local targetList = {}
    -- if _member.m_posType == MemberPosType.defenceType then
    --      targetList = MemberAttackList
    -- else
    --      targetList = MemberDeffenceList
    -- end
    -- local enermy = nil
    -- for i=1,7,1 do
    --     if targetList[i] ~= nil and targetList[i].m_isDead == false then
    --         enermy = targetList[i]
    --         break
    --     end
    -- end
    local enermyTab = _member:findIndex()
    local enermy = enermyTab._nearestEnemy
    return {
    posX = enermy:getPositionX(),
    posY = enermy:getPositionY(),
    zOrder = BattleDisplayLevel[enermy.fightPos],
    effList = {enermy}
}
end

return SkillAI

