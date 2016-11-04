-- Author: liufei
-- Date:   2015-10-22 16:20:48
LaserGunAI = class("LaserGunAI")

LaserGunState = {} --激光炮状态
LaserGunState.StateNotReady  = 0   --条件未满足状态
LaserGunState.StateLow       = 1
LaserGunState.StateMid       = 2
LaserGunState.StateTop       = 3

local LaserGunTriggerEnergy = {
                                  [LaserGunState.StateLow] = 35,
                                  [LaserGunState.StateMid] = 45,
                                  [LaserGunState.StateTop] = 60,
                              }
local LaserGunCD = 20

local LaserHitFrameNums = {
                                  [LaserGunState.StateLow] = 7,
                                  [LaserGunState.StateMid] = 8,
                                  [LaserGunState.StateTop] = 8,
                              }

-- LaserGunInfo
function LaserGunAI:Init()
    
end

function LaserGunAI:addLaserItem(_father) --添加激光炮控制按钮
    self.curGunState = LaserGunState.StateNotReady
    self.fatherScene = _father
    self.laserAtk = BattleData["laserAtk"]
    self.laserRecover = BattleData["laserEco"]

    self.laserNode = display.newNode()
    :pos(display.width*38.5/50, display.height*0.08)
    :addTo(self.fatherScene,51)

    self.fireItem = cc.ui.UIPushButton.new({normal = "Battle/Laser/jingguangbpang_r3-03.png"})
    :pos(0, 0)
    :addTo(self.laserNode)
    local fireSize = self.fireItem:getContentSize()
    --状态圈
    self.allStateLight = {}
    for i=1,3 do
        local stateBg = display.newSprite("Battle/Laser/jingguangbpang_r3-01.png")
        :pos(-23 + 57*(i-1), -24)
        :addTo(self.fireItem)
        self.allStateLight[i] = display.newSprite("Battle/Laser/jingguangbpang_r3-02.png")
        :pos(-23 + 57*(i-1), -21)
        :addTo(self.fireItem)
        self.allStateLight[i]:setVisible(false)
    end
    --爆开效果
    self.stateOk = display.newSprite("#LaserOkEff_00.png")
    :addTo(self.fireItem)
    self.stateOk:setVisible(false)
    --大状态圈
    self.bigStateCircle = display.newSprite("#LaserBigOkEff_00.png")
    :pos(0,4)
    :addTo(self.fireItem)
    self.bigStateCircle:scale(2)
    self.bigStateCircle:setBlendFunc(770,1)
    local bigStateframes = display.newFrames("LaserBigOkEff_%02d.png", 0, 24)
    local bigStateanimation = display.newAnimation(bigStateframes, 1/24)
    local bigStateAction = cc.RepeatForever:create(cc.Animate:create(bigStateanimation))
    self.bigStateCircle:runAction(bigStateAction)
    self.bigStateCircle:setVisible(false)

    --点击事件
    self.fireItem:onButtonPressed(function()
        -- touchSp:setVisible(true)
    end)
    self.fireItem:onButtonClicked(function()
        if GuideManager.NextStep==11309 or GuideManager.NextStep==22222 then
            resumeTheBattle()
            GuideManager:removeGuideLayer()
        end
        self:fireLaserGun()
    end)
    
    --冷却进度
    self.laserCDprogress = display.newProgressTimer("Battle/Laser/jingguangbpang_r3-04.png", display.PROGRESS_TIMER_BAR)
    :pos(18,18)
    :addTo(self.fireItem)
    self.laserCDprogress:setMidpoint(cc.p(0, 0.5))
    self.laserCDprogress:setBarChangeRate(cc.p(1.0, 0))
    self.laserCDprogress:setPercentage(0)
    local seq = transition.sequence({
      cc.DelayTime:create(1/self.laserRecover),
      cc.CallFunc:create(handler(self,self.updateEnergy)),
    })
    if self.laserAtk > 0 then
        self.laserCDprogress:runAction(cc.RepeatForever:create(seq))
    end

    self.laserNode:performWithDelay(function()
        self.laserCDprogress:pause()
    end,0.1)
    -- self.progressHead = display.newProgressTimer("#LaserProgressEff_00.png", display.PROGRESS_TIMER_BAR)
    -- :pos(0,0)
    -- :addTo(self.fireItem)
    
    --激光炮特效资源
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("Battle/Laser/jiguangpaoqianduan.ExportJson")
    manager:addArmatureFileInfo("Battle/Laser/jiguangpaoqianduan.ExportJson")
    self.laserGun = ccs.Armature:create("jiguangpaoqianduan")
    :pos(0,display.height - display.height*0.25)
    self.fatherScene:addChild(self.laserGun,60)

    self:changeLaserItemState()
end

function LaserGunAI:updateEnergy()
    self.curEnergy = self.laserCDprogress:getPercentage() + 1
    if self.curEnergy > 100 then
        self.curEnergy = 100
    end
    self.laserCDprogress:setPercentage(self.curEnergy)

    if self.curEnergy < 30 and self.curGunState ~= LaserGunState.StateNotReady then
        self.curGunState = LaserGunState.StateNotReady
        self:changeLaserItemState()
        return
    end
    if self.curEnergy >= 30 and self.curEnergy < 45 and self.curGunState ~= LaserGunState.StateLow then
        self.curGunState = LaserGunState.StateLow
        self:changeLaserItemState()
        return
    end
    if self.curEnergy >= 45 and self.curEnergy < 60 and self.curGunState ~= LaserGunState.StateMid then
        self.curGunState = LaserGunState.StateMid
        self:changeLaserItemState()
        return
    end
    if self.curEnergy >= 60 and self.curGunState ~= LaserGunState.StateTop then
        self.curGunState = LaserGunState.StateTop
        self:changeLaserItemState()
        return
    end
end

function LaserGunAI:changeLaserItemState() --改变激光炮按钮状态
    if self.curGunState == LaserGunState.StateNotReady then
        self.bigStateCircle:setVisible(false)
        self.fireItem:setTouchEnabled(false)
        self.laserCDprogress:pause()
        self.allStateLight[1]:setVisible(false)
        self.allStateLight[2]:setVisible(false)
        self.allStateLight[3]:setVisible(false)

    elseif self.curGunState == LaserGunState.StateLow then
        self.bigStateCircle:setVisible(true)
        self.fireItem:setTouchEnabled(true)
        local stateframes = display.newFrames("LaserOkEff_%02d.png", 0, 8)
        local stateanimation = display.newAnimation(stateframes, 0.5/8)
        local stateAction = cc.Animate:create(stateanimation)
        self.stateOk:setVisible(true)
        self.stateOk:setPosition(-23, -21)
        self.stateOk:runAction(transition.sequence{
                stateAction,
                cc.CallFunc:create(function()
                    self.stateOk:setVisible(false)
                end)
        })
        self.allStateLight[1]:setVisible(true)
        self.allStateLight[2]:setVisible(false)
        self.allStateLight[3]:setVisible(false)
        if not getIsGuideClosed() and GuideManager.NextStep == 11308 then
            GuideManager:_addGuide_2(11308, display.getRunningScene(),handler(self,self.caculateGuidePos),1111)
            pauseTheBattle()
        end

    elseif self.curGunState == LaserGunState.StateMid then
        self.bigStateCircle:setVisible(true)
        self.fireItem:setTouchEnabled(true)
        local stateframes = display.newFrames("LaserOkEff_%02d.png", 0, 8)
        local stateanimation = display.newAnimation(stateframes, 0.5/8)
        local stateAction = cc.Animate:create(stateanimation)
        self.stateOk:setVisible(true)
        self.stateOk:setPosition(34, -21)
        self.stateOk:runAction(transition.sequence{
                stateAction,
                cc.CallFunc:create(function()
                    self.stateOk:setVisible(false)
                end)
        })
        self.allStateLight[1]:setVisible(true)
        self.allStateLight[2]:setVisible(true)
        self.allStateLight[3]:setVisible(false)
          
    elseif self.curGunState == LaserGunState.StateTop then
        self.bigStateCircle:setVisible(true)
        self.fireItem:setTouchEnabled(true) 
        local stateframes = display.newFrames("LaserOkEff_%02d.png", 0, 8)
        local stateanimation = display.newAnimation(stateframes, 0.5/8)
        local stateAction = cc.Animate:create(stateanimation)
        self.stateOk:setVisible(true)
        self.stateOk:setPosition(91, -21)
        self.stateOk:runAction(transition.sequence{
                stateAction,
                cc.CallFunc:create(function()
                    self.stateOk:setVisible(false)
                end)
        })
        self.allStateLight[1]:setVisible(true)
        self.allStateLight[2]:setVisible(true)
        self.allStateLight[3]:setVisible(true)

    else
        print("Unkown LaserState!")
    end
end

--施放激光逻辑
function LaserGunAI:fireLaserGun()
    local laserStr = ""
    local frameNumUp = 0
    local frameNumMid = 0
    local frameNumDown = 0
    local curDamageBase = 0
    local allDesk = display.getRunningScene().allControlDesk
    local energyUse = 0
    if self.curGunState == LaserGunState.StateLow then
        laserStr = "Low"
        frameNumUp = 14
        frameNumDown = 18
        curDamageBase = self.laserAtk
        energyUse = 30
    elseif self.curGunState == LaserGunState.StateMid then
        laserStr = "Mid"
        frameNumUp = 15
        frameNumDown = 19
        curDamageBase = self.laserAtk*1.5
        energyUse = 45
    elseif self.curGunState == LaserGunState.StateTop then
        laserStr = "Top"
        frameNumUp = 17
        frameNumMid = 22
        frameNumDown = 19
        curDamageBase = self.laserAtk*2.5
        energyUse = 60
    else
        print("Wrong Laser State!")
        return
    end
    --伤害
    local hitState = self.curGunState

    self.curEnergy = self.laserCDprogress:getPercentage() - energyUse
    self.laserCDprogress:setPercentage(self.curEnergy)
    self:updateEnergy()

    self.laserCDprogress:resume()
    
    local function fire()
        local targetList = self:getTargetList()
    
        if hitState == LaserGunState.StateLow then
            for k,v in pairs(targetList) do
                if v~=nil and v.m_isDead == false then
                    local epoUpSp = display.newSprite("#LaserEpo"..laserStr.."Up_00.png")
                    epoUpSp:setAnchorPoint(0.6,0.32)
                    v:addChild(epoUpSp,30)
                    epoUpSp:setScaleX(3)
                    epoUpSp:setScaleY(3)
                    epoUpSp:setBlendFunc(770,1)
                    local epoUpSpframes = display.newFrames("LaserEpo"..laserStr.."Up_%02d.png", 0, frameNumUp - 1)
                    local epoUpSpanimation = display.newAnimation(epoUpSpframes, 1.5/frameNumUp)
                    local epoUpSpAction = cc.Animate:create(epoUpSpanimation)
                    epoUpSp:runAction(transition.sequence{
                                                          epoUpSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoUpSp:removeSelf()
                                                          end)
                                                       })

                    local epoDownSp = display.newSprite("#LaserEpo"..laserStr.."Down_00.png")
                    epoDownSp:setAnchorPoint(0.6,0.32)
                    epoDownSp:setPosition(v:getPositionX(), v:getPositionY())
                    display.getRunningScene():addChild(epoDownSp)
                    epoDownSp:setScaleX(3)
                    epoDownSp:setScaleY(3)
                    epoDownSp:setBlendFunc(770,1)
                    local epoDownSpframes = display.newFrames("LaserEpo"..laserStr.."Down_%02d.png", 0, frameNumDown - 1)
                    local epoDownSpanimation = display.newAnimation(epoDownSpframes, 1.5/frameNumDown)
                    local epoDownSpAction = cc.Animate:create(epoDownSpanimation)
                    epoDownSp:runAction(transition.sequence{
                                                          epoDownSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoDownSp:removeSelf()
                                                          end)
                                                       })
                end
            end
        elseif hitState == LaserGunState.StateMid then
            for k,v in pairs(targetList) do
                if v~=nil and v.m_isDead == false then
                    local epoUpSp = display.newSprite("#LaserEpo"..laserStr.."Up_00.png")
                    epoUpSp:setAnchorPoint(0.6,0.32)
                    v:addChild(epoUpSp,30)
                    epoUpSp:setScaleX(3)
                    epoUpSp:setScaleY(3)
                    epoUpSp:setBlendFunc(770,1)
                    local epoUpSpframes = display.newFrames("LaserEpo"..laserStr.."Up_%02d.png", 0, frameNumUp - 1)
                    local epoUpSpanimation = display.newAnimation(epoUpSpframes, 1.5/frameNumUp)
                    local epoUpSpAction = cc.Animate:create(epoUpSpanimation)
                    epoUpSp:runAction(transition.sequence{
                                                          epoUpSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoUpSp:removeSelf()
                                                          end)
                                                       })

                    local epoDownSp = display.newSprite("#LaserEpo"..laserStr.."Down_00.png")
                    epoDownSp:setAnchorPoint(0.6,0.32)
                    epoDownSp:setPosition(v:getPositionX(), v:getPositionY())
                    display.getRunningScene():addChild(epoDownSp)
                    epoDownSp:setScaleX(3)
                    epoDownSp:setScaleY(3)
                    epoDownSp:setBlendFunc(770,1)
                    local epoDownSpframes = display.newFrames("LaserEpo"..laserStr.."Down_%02d.png", 0, frameNumDown - 1)
                    local epoDownSpanimation = display.newAnimation(epoDownSpframes, 1.5/frameNumDown)
                    local epoDownSpAction = cc.Animate:create(epoDownSpanimation)
                    epoDownSp:runAction(transition.sequence{
                                                          epoDownSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoDownSp:removeSelf()
                                                          end)
                                                       })
                end
            end
        elseif hitState == LaserGunState.StateTop then
            for k,v in pairs(targetList) do
                if v~=nil and v.m_isDead == false then
                    local epoUpSp = display.newSprite("#LaserEpo"..laserStr.."Up_00.png")
                    epoUpSp:setAnchorPoint(0.6,0.32)
                    v:addChild(epoUpSp,20)
                    epoUpSp:setScaleX(3)
                    epoUpSp:setScaleY(3)
                    epoUpSp:setBlendFunc(770,1)
                    local epoUpSpframes = display.newFrames("LaserEpo"..laserStr.."Up_%02d.png", 0, frameNumUp - 1)
                    local epoUpSpanimation = display.newAnimation(epoUpSpframes, 1.5/frameNumUp)
                    local epoUpSpAction = cc.Animate:create(epoUpSpanimation)
                    epoUpSp:runAction(transition.sequence{
                                                          epoUpSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoUpSp:removeSelf()
                                                          end)
                                                       })
                    local epoMidSp = display.newSprite("#LaserEpo"..laserStr.."Mid_00.png")
                    epoMidSp:setAnchorPoint(0.6,0.32)
                    epoMidSp:setPosition(v:getPositionX(), v:getPositionY())
                    display.getRunningScene():addChild(epoMidSp)
                    epoMidSp:setScaleX(3)
                    epoMidSp:setScaleY(3)
                    local epoMidSpframes = display.newFrames("LaserEpo"..laserStr.."Mid_%02d.png", 0, frameNumMid - 1)
                    local epoMidSpanimation = display.newAnimation(epoMidSpframes, 1.5/frameNumMid)
                    local epoMidSpAction = cc.Animate:create(epoMidSpanimation)
                    epoMidSp:runAction(transition.sequence{
                                                          epoMidSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoMidSp:removeSelf()
                                                          end)
                                                       })

                    local epoDownSp = display.newSprite("#LaserEpo"..laserStr.."Down_00.png")
                    epoDownSp:setAnchorPoint(0.6,0.32)
                    epoDownSp:setPosition(v:getPositionX(), v:getPositionY())
                    display.getRunningScene():addChild(epoDownSp)
                    epoDownSp:setScaleX(3)
                    epoDownSp:setScaleY(3)
                    epoDownSp:setBlendFunc(770,1)
                    local epoDownSpframes = display.newFrames("LaserEpo"..laserStr.."Down_%02d.png", 0, frameNumDown - 1)
                    local epoDownSpanimation = display.newAnimation(epoDownSpframes, 1.5/frameNumDown)
                    local epoDownSpAction = cc.Animate:create(epoDownSpanimation)
                    epoDownSp:runAction(transition.sequence{
                                                          epoDownSpAction,
                                                          cc.CallFunc:create(function()
                                                              epoDownSp:removeSelf()
                                                          end)
                                                       })
                end
            end
        end
        self.fireItem:runAction(transition.sequence({
                                                        cc.DelayTime:create(0.2),
                                                        cc.CallFunc:create(function ()
                                                            display.getRunningScene():shakeBg(3)
                                                        end),
                                                        cc.DelayTime:create(0.4),
                                                        cc.CallFunc:create(function ()
                                                            self:LaserGunEffcetDamage(targetList,hitState,curDamageBase)
                                                        end),
                                                   }))
    end
    self.laserGun:getAnimation():play("Laser")
    display.getRunningScene().skillLayer:setVisible(true)
    skillPauseMembers()
    self.fireItem:performWithDelay(function()
        skillResumeMembers()
        display.getRunningScene().skillLayer:setVisible(false)
        fire()
    end,0.7)
end

function LaserGunAI:getTargetList()
    local targetList = {}
    local aliveNum = 0
    for k,v in pairs(MemberDeffenceList) do
        if v ~= nil and v.m_isDead == false then
            aliveNum = aliveNum + 1
        end
    end
    if aliveNum <= LaserGunInfo.targetNum then
        targetList = MemberDeffenceList
    else
        local allMonsterIndex = {}
        for k,v in pairs(MemberDeffenceList) do
            if v ~= nil and v.m_isDead == false then
                table.insert(allMonsterIndex,#allMonsterIndex+1,v.fightPos)
            end
        end
        for i=1,LaserGunInfo.targetNum do
            --math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
            local rIndex = math.random(#allMonsterIndex)
            local mIndex = allMonsterIndex[rIndex]
            table.insert(targetList,#targetList+1,MemberDeffenceList[mIndex])
            if rIndex ~= #allMonsterIndex then --与最后一个交换
                allMonsterIndex[rIndex] = allMonsterIndex[#allMonsterIndex]
                allMonsterIndex[#allMonsterIndex] = nil
            end
        end
    end
    return targetList
end

--激光炮伤害逻辑
function LaserGunAI:LaserGunEffcetDamage(_targetList,_hitState,_curDamageBase)
    
    local function hitEnermy(_enermy)
        if LaserGunInfo.buffId ~= 0 and LaserGunInfo.buffId ~= nil then
            _enermy.buffControl:addBuffer(_enermy, LaserGunInfo.buffId, _curDamageBase)
        end
        print("_curDamageBase:".._curDamageBase)
        _enermy:LiquidateDamage(math.floor(_curDamageBase*LaserGunInfo.damageAdd),false)
        _enermy:afterBeAttack()
    end 
    
    for k,v in pairs(_targetList) do
        if v ~= nil and v.m_isDead == false then
            hitEnermy(v)
        end
    end
end

--暂停激光炮
function LaserGunAI:pauseLaserGun()
    print("LaserGunAI Pause")
    if self.curGunState == nil then
        return
    end
    self.laserCDprogress:pause()
    if self.curGunState == LaserGunState.StateNotReady then
        --Do Nothing
    else
        self.curGunState = LaserGunState.StateNotReady
        self:changeLaserItemState()
    end
    
end

--继续激光炮
function LaserGunAI:resumeLaserGun()
    print("LaserGunAI Resume")
    if self.curGunState == nil then
        return
    end
    self.laserCDprogress:resume()
end

function LaserGunAI:removeLaserGun()
    if self.laserNode~= nil then
        self.laserNode:removeSelf()
        self.laserNode = nil
        self.curGunState = nil
    end
end

function LaserGunAI:setItemNil()
    self.laserNode = nil
    self.curGunState = nil
end

function LaserGunAI:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11308==_guideId then
        g_node = self.bigStateCircle
        size = g_node:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
        
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

