-- @Author: anchen
-- @Date:   2016-01-19 14:28:54
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-05-30 14:31:37

--进阶后坦克的一些逻辑
ExclusivesAI = {}

--血量相关的一些特殊逻辑
function ExclusivesAI:getFinalDamage(_damageValue,_attackInfo,_deffenceInfo,_deffenceBuff)
    if _attackInfo.tptId == 1014 then --对血量低于30%的目标造成的伤害提高30%
        if _deffenceInfo.curHp/_deffenceInfo.maxHp < 0.7 then
            return math.floor(_damageValue*1.3)
        end
    elseif _attackInfo.tptId == 1053 or _attackInfo.tptId == 1054 then --自身满血时，对目标造成的伤害提升20%
        if _attackInfo.curHp >= _attackInfo.maxHp then
            return math.floor(_damageValue*1.2)
        end
    elseif _attackInfo.tptId == 1074 then --自身血量每降低10%，造成的伤害提升10%
        return math.floor(_damageValue*(1 + math.floor((1 - _attackInfo.curHp/_attackInfo.maxHp)*10)/10))
    elseif _attackInfo.tptId == 1064 then --每阵亡一个己方单位，对敌方造成的伤害增加15%
        local deadNum = 0
        if _attackInfo.posType == MemberPosType.attackType then
            for k,v in pairs(MemberAttackList) do
                if v~= nil and v.m_isDead == true then
                    deadNum = deadNum + 1
                end
            end
        else
            for k,v in pairs(MemberDeffenceList) do
                if v~= nil and v.m_isDead == true then
                    deadNum = deadNum + 1
                end
            end
        end
        return math.floor(_damageValue*(1+0.15*deadNum))
    elseif _attackInfo.tptId == 1084 then --对处于灼烧状态的目标造成的伤害提高50%
        local hasBurnBuff = 1
        for k,v in pairs(_deffenceBuff) do
            local tmpK = tonumber(k)
            if tmpK == 107001 or tmpK == 107002 then
                hasBurnBuff = 1.5
                break
            end
        end
        return math.floor(_damageValue*hasBurnBuff)
    elseif _attackInfo.tptId == 2074 then --对处于破甲状态的目标造成的伤害提高50%
        local hasBurnBuff = 1
        for k,v in pairs(_deffenceBuff) do
            local tmpK = tonumber(k)
            if tmpK == 111001 or tmpK == 111002 or tmpK == 111003 then
                hasBurnBuff = 1.5
                break
            end
        end
        return math.floor(_damageValue*hasBurnBuff)
    else
        return _damageValue
    end
    return _damageValue
end