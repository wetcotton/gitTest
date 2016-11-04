--
-- Author: liufei
-- Date: 2014-11-04 12:04:26
--

local BulletAI = class("BulletAI", function()
	return display.newSprite()
end)

function BulletAI:ctor(_attacker, _beAttacker, _bulletName)

    --self:setVisible(false)
    if _attacker.m_bulletResNum <= 1 then
        self:setTexture("Battle/Bullet/".._bulletName..".png")
    else
        self:setTexture(display.newSprite("#".._attacker.m_attackEffectName.."_00.png"):getTexture())
        local bulletFrames = display.newFrames(_attacker.m_bulletStr.."_%02d.png", 0,_attacker.m_bulletResNum  - 1)
        local num = 0
        if _attacker.m_memberType == MemberAllType.kMemberHero then
            num = tonumber(memberData[tonumber(_attacker.m_attackInfo.tptId)]["atkResNum"])
        elseif _attacker.m_memberType == MemberAllType.kMemberTank then
            num = tonumber(carData[tonumber(_attacker.m_attackInfo.tptId)]["atkResNum"])
        elseif _attacker.m_memberType == MemberAllType.kMemberMonster then
            num = tonumber(monsterData[tonumber(_attacker.m_attackInfo.tptId)]["atkResNum"])
        end
        local bulletAnimation = display.newAnimation(bulletFrames, 0.3/num)
        local bulletAction = cc.Animate:create(bulletAnimation)
        self:runAction(cc.RepeatForever:create(bulletAction))
    end
    self:scale(BattleScaleValue*BlockTypeScale)
    self.bulletIndex = 0
    for i=1,20 do
        if AllFlyBullet[i] == nil then
            AllFlyBullet[i] = self
            self.bulletIndex = i
            break
        end
    end
    local offSets = string.split(_attacker.m_bltPos,"|")
    local xOffset = tonumber(offSets[1])
    local yOffset = tonumber(offSets[2])

    local startPos = nil
    local  targetPosX = _beAttacker:getHitPosition().x
    local  targetPosY = _beAttacker:getHitPosition().y
    local  targetPosX2,targetPosY2 = 0
    
    local tSize = {}
    if _attacker.makeType == ModelMakeType.kMake_Coco then
        tSize = _attacker.m_member:getContentSize()
    else
        tSize = {width = display.width*0.1, height = display.width*0.1}
    end
    if _attacker:getPositionX() < targetPosX then
        self:setScaleX(-1*self:getScaleX())
        startPos = cc.p(_attacker:getPositionX()+xOffset*tSize.width*_attacker.m_scaleNum, _attacker:getPositionY()+yOffset*tSize.height*_attacker.m_scaleNum)
    else
        startPos = cc.p(_attacker:getPositionX()-xOffset*tSize.width*_attacker.m_scaleNum, _attacker:getPositionY()+yOffset*tSize.height*_attacker.m_scaleNum)
    end

    local  rotateNum = math.deg(math.atan(math.abs((startPos.y - targetPosY)/(startPos.x - targetPosX))))
    if startPos.x > targetPosX then
        if startPos.y > targetPosY  then
           self:setRotation(-rotateNum)
        elseif startPos.y < targetPosY then
           self:setRotation(rotateNum)
        end
        if _bulletName == "TankBullet_1102009" then
            self:setScaleX(1)
            targetPosX2 = targetPosX + self:getContentSize().width*math.cos(math.rad(rotateNum))
            targetPosY2 = targetPosY + self:getContentSize().width*math.sin(math.rad(rotateNum))
        else
            targetPosX2 = targetPosX
            targetPosY2 = targetPosY
        end
        self:align(display.CENTER_LEFT,startPos.x + self:getContentSize().width/2, startPos.y)
    else
        if startPos.y > targetPosY  then
           self:setRotation(rotateNum)
        elseif startPos.y < targetPosY then
           self:setRotation(-rotateNum)
        end
        if _bulletName == "TankBullet_1102009" then
            self:setScaleX(-1)
            targetPosX2 = targetPosX - self:getContentSize().width*math.cos(math.rad(rotateNum))
            targetPosY2 = targetPosY + self:getContentSize().width*math.sin(math.rad(rotateNum))
        else
            targetPosX2 = targetPosX
            targetPosY2 = targetPosY
        end
        self:align(display.CENTER_RIGHT,startPos.x - self:getContentSize().width/2, startPos.y)
    end

    local g_instance = nil
    if startFightBattleScene.Instance~=nil then
        g_instance = startFightBattleScene.Instance
    else
        g_instance = cc.Director:getInstance():getRunningScene()
    end

    local function effectBullet()
        local g_instance = nil
        if startFightBattleScene.Instance~=nil then
            g_instance = startFightBattleScene.Instance
        else
            g_instance = cc.Director:getInstance():getRunningScene()
        end
        AllFlyBullet[self.bulletIndex] = nil
        if _beAttacker ~= nil and _beAttacker.m_isDead == false and _attacker ~= nil and _attacker.m_isDead == false then
            self:setVisible(false)
            _beAttacker:beAttacked(_attacker.m_attackInfo)

            local attackEffectSp = display.newSprite("#".._attacker.m_attackEffectName.."_00.png")
            :pos(targetPosX, targetPosY)
            :addTo(g_instance,BattleDisplayLevel[_beAttacker.fightPos])
            attackEffectSp:scale(BattleScaleValue)

            if startPos.x > targetPosX then
                attackEffectSp:setScaleX(-1*attackEffectSp:getScaleX())
            end

            local  attackEffectAction = nil
            if _attacker.m_memberType == MemberAllType.kMemberHero then
                local effectFrames = display.newFrames(_attacker.m_attackEffectName.."_%02d.png", 0, tonumber(memberData[tonumber(_attacker.m_attackInfo.tptId)]["atkResNum"]) - 1)
                local effectAnimation = display.newAnimation(effectFrames, 0.3/tonumber(memberData[tonumber(_attacker.m_attackInfo.tptId)]["atkResNum"]))
                attackEffectAction = cc.Animate:create(effectAnimation)
            elseif _attacker.m_memberType == MemberAllType.kMemberTank or _attacker.m_memberType == MemberAllType. kMemberTankWithHero then
                local effectFrames = display.newFrames(_attacker.m_attackEffectName.."_%02d.png", 0, tonumber(_attacker.subSkillData["atkResNum"]) - 1)
                local effectAnimation = display.newAnimation(effectFrames, 0.3/tonumber(_attacker.subSkillData["atkResNum"]))
                attackEffectAction = cc.Animate:create(effectAnimation)
            elseif _attacker.m_memberType == MemberAllType.kMemberMonster then
                local effectFrames = display.newFrames(_attacker.m_attackEffectName.."_%02d.png", 0, tonumber(_attacker.curMonsterData["atkResNum"]) - 1)
                local effectAnimation = display.newAnimation(effectFrames, 0.3/tonumber(_attacker.curMonsterData["atkResNum"]))
                attackEffectAction = cc.Animate:create(effectAnimation)
            end
            if _attacker.m_bltEpoSound ~= nil then
                audio.playSound("audio/musicEffect/weaponEffect/".._attacker.m_bltEpoSound..".mp3")
            end
            attackEffectSp:runAction(transition.sequence({
                                                             attackEffectAction,
                                                             cc.CallFunc:create(function()
                                                                  attackEffectSp:removeSelf()
                                                                  self:removeSelf()
                                                             end)
                                                         }))
        else
            self:removeSelf()
        end
    end

 
	local distance = math.sqrt(math.pow(startPos.x - targetPosX2, 2) + math.pow(startPos.y -targetPosY2, 2))
	local moveTime = distance/(BulletMoveSpeed*3)
	local move = cc.MoveBy:create(moveTime, cc.p(targetPosX2-self:getPositionX(),targetPosY2-self:getPositionY()))
	local call = cc.CallFunc:create(effectBullet)

    if _attacker.m_bltFireSound ~= nil then
        audio.playSound("audio/musicEffect/weaponEffect/".._attacker.m_bltFireSound..".mp3")
    end
    self:runAction(transition.sequence({move,call}))
end

return BulletAI