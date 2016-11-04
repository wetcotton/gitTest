-- @Author: anchen
-- @Date:   2015-08-30 17:26:33
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-09 15:05:15

--进阶按钮特效
function advancedBtAnimation(parentNode,x,y)
    x = x or 0
    y = y or 0
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/advBt_img.plist", "Effect/advBt_img.png")
    local frames = display.newFrames("advBt_img%d.png", 1, 13)
    local animation = display.newAnimation(frames, ts / 13)
    local sprite = display.newSprite("#advBt_img1.png")
    :addTo(parentNode)
    :pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/advBt_img.plist", "Effect/advBt_img.png")
    end,
    })
end
--换装按钮特效
function changeBtEff(parentNode, x, y)
    x = x or 0
    y = y or 0
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/changBt_img.plist", "Effect/changBt_img.png")
    local frames = display.newFrames("changBt_img%d.png", 1, 12)
    local animation = display.newAnimation(frames, ts / 12)
    local sprite = display.newSprite("#changBt_img1.png")
    :addTo(parentNode)
    :pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/changBt_img.plist", "Effect/changBt_img.png")
    end,
    })
end
--单个装备可换装特效
function changeEqtAnimation(chaBt, parentNode, idx)
    local pos = {cc.p(46,40),cc.p(28,40),cc.p(15,40), cc.p(12,40),cc.p(-3,40),cc.p(-20,40),}
    local scale = {1,1,1,-1,-1,-1}
    local plistName = {"change1_img","change2_img","change3_img","change3_img","change2_img","change1_img"}
    local imgCnt = {27,27,27, 27,27,27}
    if parentNode==nil then
        return
    end
    
    local ts = 0.5
    display.addSpriteFrames("Effect/"..plistName[idx]..".plist", "Effect/"..plistName[idx]..".png")
    local frames = display.newFrames(plistName[idx].."%d.png", 1, imgCnt[idx])
    local animation = display.newAnimation(frames, ts / imgCnt[idx])
    local sprite = display.newSprite("#"..plistName[idx].."1.png")
    :addTo(parentNode)
    :pos(pos[idx].x,pos[idx].y)
    sprite:setScaleX(scale[idx])
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        changeBtEff(chaBt, 0, 15)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/"..plistName[idx]..".plist", "Effect/"..plistName[idx]..".png")
    end,
    })
end
local waitChaSprite = nil
--待换装特效
function waitChangeAnimation(parentNode, x, y)
    x = x or 0
    y = y or 0
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/waitCha_img.plist", "Effect/waitCha_img.png")
    local frames = display.newFrames("waitCha_img%d.png", 1, 9)
    local animation = display.newAnimation(frames, ts / 9)
    local sprite = display.newSprite("#waitCha_img1.png")
    :addTo(parentNode)
    :pos(x,y)
    sprite:playAnimationForever(animation)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/waitCha_img.plist", "Effect/waitCha_img.png")
    -- end,
    -- })
    waitChaSprite = sprite
end
function removeWaitChangeAnimation()
    if waitChaSprite then
        waitChaSprite:removeSelf()
        waitChaSprite = nil
        display.removeSpriteFramesWithFile("Effect/waitCha_img.plist", "Effect/waitCha_img.png")
    end
end
--换装过程特效
function changeRoleEff(parentNode, x, y)
    x = x or 0
    y = y or 0
    if parentNode==nil then
        return
    end
    local ts = 2.0
    display.addSpriteFrames("Effect/changeRole_img.plist", "Effect/changeRole_img.png")
    local frames = display.newFrames("changeRole_img%d.png", 1, 36)
    local animation = display.newAnimation(frames, ts / 36)
    local sprite = display.newSprite("#changeRole_img1.png")
    :addTo(parentNode,2)
    :pos(x,y)
    :scale(2.0)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/changeRole_img.plist", "Effect/changeRole_img.png")
    end,
    })
end


--进阶特效
function advancedAnimation(parentNode,x,y)
    x = x or 0
    y = y or 0
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/advance.plist", "Effect/advance.png")
    local frames = display.newFrames("advance_img%d.png", 1, 21)
    local animation = display.newAnimation(frames, ts / 21)
    local sprite = display.newSprite("#advance_img1.png")
    :addTo(parentNode)
    :pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/advance.plist", "Effect/advance.png")
    end,
    })
end

--强化特效
function strengthAnimation(parentNode,x,y)
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/strength.plist", "Effect/strength.png")
    local frames = display.newFrames("strength_img%d.png", 1, 16)
    local animation = display.newAnimation(frames, ts / 16)
    local sprite = display.newSprite("#strength_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/strength.plist", "Effect/strength.png")
    end,
    })
end

--技能升级特效
function skillUpAnimation(parentNode,x,y)
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/skillUp.plist", "Effect/skillUp.png")
    local frames = display.newFrames("skillUp%d.png", 1, 15)
    local animation = display.newAnimation(frames, ts / 15)
    local sprite = display.newSprite("#skillUp1.png")
    :addTo(parentNode,2)
    :pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/skillUp.plist", "Effect/skillUp.png")
    end,
    })
end

--签到光圈特效
function signCircleAnimation(parentNode,x,y,scale)
    scale = scale or 1
    local ts = 1.0
    display.addSpriteFrames("Effect/signEffective.plist", "Effect/signEffective.png")
    local frames = display.newFrames("sign_img%d.png", 1, 24)
    local animation = display.newAnimation(frames, ts / 24)
    local sprite = display.newSprite("#sign_img1.png")
    :addTo(parentNode,2,1000)
    :pos(x,y)
    :scale(scale)
    sprite:playAnimationForever(animation)

end
--移除签到光圈特效
function removeSignCircleAnimation(parentNode)
    if parentNode:getChildByTag(1000) then
        parentNode:removeChildByTag(1000)
        display.removeSpriteFramesWithFile("Effect/signEffective.plist", "Effect/signEffective.png")
    end 
end

--弹窗效果
function WindowsOpenAction(boxNode,scale)
    if boxNode==nil then
        return
    end
    scale = scale or 1
    boxNode:setScale(scale*0.95)

    local action1 = cc.ScaleTo:create(0.1, scale*1.05)
    local action3 = cc.ScaleTo:create(0.1, scale*0.98)
    local action4 = cc.ScaleTo:create(0.1, scale*1.0)

    local seq = cc.Sequence:create(action1, action3, action4)
    -- local spAct = cc.Spawn:create(seq,action2)
    boxNode:runAction(seq)
end
--窗口关闭效果
function WindowsCloseAction(boxNode,scale,callBack)
    if boxNode==nil then
        return
    end
    scale = scale or 1
    local act1 = cc.ScaleTo:create(0.08, scale*0.85)
    local act2 = cc.CallFunc:create(callBack)
    boxNode:runAction(cc.Sequence:create(act1, act2))
end

--关卡，锤子，钉子效果
function HammerAndNail(parentNode,x,y,scale)
    scale = scale or 1
    local ts = 1.0
    display.addSpriteFrames("area/areaEffects/hammerImg.plist", "area/areaEffects/hammerImg.png")
    local frames = display.newFrames("hammerImg%d.png", 1, 19)
    local animation = display.newAnimation(frames, ts / 19)
    local sprite = display.newSprite("#hammerImg1.png")
    :addTo(parentNode,2)
    :pos(x,y)
    :scale(scale)
    sprite:playAnimationForever(animation)
end

--激光炮上镜片，镜片位置动作
function lensEff1(parentNode,x,y)
    if parentNode==nil then
        return
    end
    local ts = 0.7
    display.addSpriteFrames("Effect/lensEff1_img.plist", "Effect/lensEff1_img.png")
    local frames = display.newFrames("lensEff1_img%d.png", 1, 14)
    local animation = display.newAnimation(frames, ts / 14)
    local sprite = display.newSprite("#lensEff1_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lensEff1_img.plist", "Effect/lensEff1_img.png")
    end,
    })
end
--激光炮上镜片，激光槽位置动作
function lensEff2(parentNode,x,y,scale)
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 0.5
    display.addSpriteFrames("Effect/lensEff2_img.plist", "Effect/lensEff2_img.png")
    local frames = display.newFrames("lensEff2_img%d.png", 1, 12)
    local animation = display.newAnimation(frames, ts / 12)
    local sprite = display.newSprite("#lensEff2_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lensEff2_img.plist", "Effect/lensEff2_img.png")
    end,
    })
end
--激光炮卸载镜片，激光槽位置动作
function lensEff3(parentNode,x,y)
    if parentNode==nil then
        return
    end
    local ts = 0.7
    display.addSpriteFrames("Effect/lensEff3_img.plist", "Effect/lensEff3_img.png")
    local frames = display.newFrames("lensEff3_img%d.png", 1, 11)
    local animation = display.newAnimation(frames, ts / 11)
    local sprite = display.newSprite("#lensEff3_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lensEff3_img.plist", "Effect/lensEff3_img.png")
    end,
    })
end
--激光炮卸载镜片，激光槽位置动作
function lensEff4(parentNode,x,y, scale)
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 0.5
    display.addSpriteFrames("Effect/lensEff4_img.plist", "Effect/lensEff4_img.png")
    local frames = display.newFrames("lensEff4_img%d.png", 1, 15)
    local animation = display.newAnimation(frames, ts / 15)
    local sprite = display.newSprite("#lensEff4_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lensEff4_img.plist", "Effect/lensEff4_img.png")
    end,
    })
end
--紫装特效
function PurpleEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 1.5
    display.addSpriteFrames("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    local frames = display.newFrames("PurpleImg%d.png", 1, 16)
    local animation = display.newAnimation(frames, ts / 16)
    local sprite = display.newSprite("#PurpleImg1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
end
--紫装碎片特效
function PurplePieceEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 1.5
    display.addSpriteFrames("Effect/pieceImg.plist", "Effect/pieceImg.png")
    local frames = display.newFrames("pieceImg%d.png", 1, 12)
    local animation = display.newAnimation(frames, ts / 12)
    local sprite = display.newSprite("#pieceImg1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    -- sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
end

--关卡冒烟特效
function BlockSmokeEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 2.0
    display.addSpriteFrames("Battle/Skill/SmokeFrames.plist", "Battle/Skill/SmokeFrames.png")
    local frames = display.newFrames("SmokeFrames_%02d.png", 0, 24)
    local animation = display.newAnimation(frames, ts / 25)
    local sprite = display.newSprite("#SmokeFrames_00.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    -- sprite:setBlendFunc(1,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
end

--关卡瞄准特效
function BlockAimEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 1.2
    display.addSpriteFrames("Effect/AimImg.plist", "Effect/AimImg.png")
    local frames = display.newFrames("AimImg%d.png", 1, 15)
    local animation = display.newAnimation(frames, ts / 15)
    local sprite = display.newSprite("#AimImg1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
    return sprite
end
--关卡导弹爆炸效果
function BlockBoomEff(parentNode,x,y, scale, callback)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 0.2
    display.addSpriteFrames("Effect/blockBoomImg.plist", "Effect/blockBoomImg.png")
    local frames = display.newFrames("blockBoomImg%d.png", 1, 13)
    local animation = display.newAnimation(frames, ts / 13)
    local sprite = display.newSprite("#blockBoomImg1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/blockBoomImg.plist", "Effect/blockBoomImg.png")
        callback()
    end,
    })
    -- return sprite
end
--当前关卡箭头
function curBlockArrowEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/curBlockImg.plist", "Effect/curBlockImg.png")
    local frames = display.newFrames("curBlockImg%d.png", 1, 14)
    local animation = display.newAnimation(frames, ts / 14)
    local sprite = display.newSprite("#curBlockImg1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    -- sprite:setBlendFunc(0,0)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
end
--目标关卡箭头
function targetBlockArrowEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 1.0
    display.addSpriteFrames("Effect/targetBlockImg.plist", "Effect/targetBlockImg.png")
    local frames = display.newFrames("targetBlockImg%d.png", 1, 14)
    local animation = display.newAnimation(frames, ts / 14)
    local sprite = display.newSprite("#targetBlockImg1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    -- sprite:setBlendFunc(1,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    -- end,
    -- })
end
--免费建设特效
function freeLegionContriEff(parentNode,x,y, scale, callback)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 0.6
    display.addSpriteFrames("Effect/legionContri1_.plist", "Effect/legionContri1_.png")
    local frames = display.newFrames("legionContri1_%d.png", 1, 14)
    local animation = display.newAnimation(frames, ts / 14)
    local sprite = display.newSprite("#legionContri1_1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        callback()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    end,
    })
end
--钻石建设特效
function diamondLegionContriEff(parentNode,x,y, scale, callback)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    local ts = 0.6
    display.addSpriteFrames("Effect/legionContri2_.plist", "Effect/legionContri2_.png")
    local frames = display.newFrames("legionContri2_%d.png", 1, 14)
    local animation = display.newAnimation(frames, ts / 14)
    local sprite = display.newSprite("#legionContri2_2.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        callback()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/PurpleImg.plist", "Effect/PurpleImg.png")
    end,
    })
end

--抽卡转动时候的光条
function LotteryCardEff1(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.0
    display.addSpriteFrames("Effect/lotCardEff_img.plist", "Effect/lotCardEff_img.png")
    local frames = display.newFrames("lotCardEff_img%d.png", 1, 35)
    local animation = display.newAnimation(frames, ts / 35)
    local sprite = display.newSprite("#lotCardEff_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2.5)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/lotCardEff_img.plist", "Effect/lotCardEff_img.png")
    -- end,
    -- })
end
--钻石单抽
function LotteryCardEff2(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.5
    display.addSpriteFrames("Effect/lotCardEff2_img.plist", "Effect/lotCardEff2_img.png")
    local frames = display.newFrames("lotCardEff2_img%d.png", 1, 34)
    local animation = display.newAnimation(frames, ts / 34)
    local sprite = display.newSprite("#lotCardEff2_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)
    -- sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff2_img.plist", "Effect/lotCardEff2_img.png")
    end,
    })
end
--钻石十连抽
function LotteryCardEff3(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.5
    display.addSpriteFrames("Effect/lotCardEff3_img.plist", "Effect/lotCardEff3_img.png")
    local frames = display.newFrames("lotCardEff3_img%d.png", 1, 46)
    local animation = display.newAnimation(frames, ts / 46)
    local sprite = display.newSprite("#lotCardEff3_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)
    -- sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff3_img.plist", "Effect/lotCardEff3_img.png")
    end,
    })
end
--金币单抽
function LotteryCardEff4(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.5
    display.addSpriteFrames("Effect/lotCardEff4_img.plist", "Effect/lotCardEff4_img.png")
    local frames = display.newFrames("lotCardEff4_img%d.png", 1, 34)
    local animation = display.newAnimation(frames, ts / 34)
    local sprite = display.newSprite("#lotCardEff4_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)
    -- sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff4_img.plist", "Effect/lotCardEff4_img.png")
    end,
    })
end
--金币十连抽
function LotteryCardEff5(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.5
    display.addSpriteFrames("Effect/lotCardEff5_img.plist", "Effect/lotCardEff5_img.png")
    local frames = display.newFrames("lotCardEff5_img%d.png", 1, 46)
    local animation = display.newAnimation(frames, ts / 46)
    local sprite = display.newSprite("#lotCardEff5_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)
    -- sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff5_img.plist", "Effect/lotCardEff5_img.png")
    end,
    })
end
--抽卡获得物品闪光
function LotteryCardEff6(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.6
    display.addSpriteFrames("Effect/lotCardEff6_img.plist", "Effect/lotCardEff6_img.png")
    local frames = display.newFrames("lotCardEff6_img%d.png", 1, 9)
    local animation = display.newAnimation(frames, ts / 9)
    local sprite = display.newSprite("#lotCardEff6_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff6_img.plist", "Effect/lotCardEff6_img.png")
    end,
    })
end

--抽卡上面发光
function LotteryCardEff7(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.0
    display.addSpriteFrames("Effect/lotCardEff7_img.plist", "Effect/lotCardEff7_img.png")
    local frames = display.newFrames("lotCardEff7_img%d.png", 1, 21)
    local animation = display.newAnimation(frames, ts / 21)
    local sprite = display.newSprite("#lotCardEff7_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/lotCardEff7_img.plist", "Effect/lotCardEff7_img.png")
    -- end,
    -- })
end
--新抽卡弹出框
function LotteryCardEff8(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.0
    display.addSpriteFrames("Effect/lotCardEff8_img.plist", "Effect/lotCardEff8_img.png")
    local frames = display.newFrames("lotCardEff8_img%d.png", 1, 21)
    local animation = display.newAnimation(frames, ts / 21)
    local sprite = display.newSprite("#lotCardEff8_img1.png")
    sprite:addTo(parentNode,100)
    sprite:pos(x,y)
    sprite:scale(scale*4)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/lotCardEff8_img.plist", "Effect/lotCardEff8_img.png")
    end,
    })
end
--充值
function rechargeEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 2.0
    display.addSpriteFrames("Effect/rechargeEFf_img.plist", "Effect/rechargeEFf_img.png")
    local frames = display.newFrames("rechargeEFf_img%d.png", 1, 20)
    local animation = display.newAnimation(frames, ts / 20)
    local sprite = display.newSprite("#rechargeEFf_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/lotCardEff7_img.plist", "Effect/lotCardEff7_img.png")
    -- end,
    -- })
end
--优惠
function youhuiEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 2.0
    display.addSpriteFrames("Effect/youhuiEFf_img.plist", "Effect/youhuiEFf_img.png")
    local frames = display.newFrames("youhuiEFf_img%d.png", 1, 20)
    local animation = display.newAnimation(frames, ts / 20)
    local sprite = display.newSprite("#youhuiEFf_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/lotCardEff7_img.plist", "Effect/lotCardEff7_img.png")
    -- end,
    -- })
end
--在线奖励
function onLineEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 2.0
    display.addSpriteFrames("Effect/onlineEff_img.plist", "Effect/onlineEff_img.png")
    local frames = display.newFrames("onlineEff_img%d.png", 1, 32)
    local animation = display.newAnimation(frames, ts / 32)
    local sprite = display.newSprite("#onlineEff_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/lotCardEff7_img.plist", "Effect/lotCardEff7_img.png")
    -- end,
    -- })
    return sprite
end
--战车改造右侧数据显示特效
function carImproEff1(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 2.0
    display.addSpriteFrames("Effect/carImproEff1_img.plist", "Effect/carImproEff1_img.png")
    local frames = display.newFrames("carImproEff1_img%d.png", 1, 32)
    local animation = display.newAnimation(frames, ts / 32)
    local sprite = display.newSprite("#carImproEff1_img1.png")
    sprite:addTo(parentNode,2)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/carImproEff1_img.plist", "Effect/carImproEff1_img.png")
    end,
    })
end
--战车改造添加材料特效
function carImproEff2(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.6
    display.addSpriteFrames("Effect/carImproEff2_img.plist", "Effect/carImproEff2_img.png")
    local frames = display.newFrames("carImproEff2_img%d.png", 1, 21)
    local animation = display.newAnimation(frames, ts / 21)
    local sprite = display.newSprite("#carImproEff2_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/carImproEff2_img.plist", "Effect/carImproEff2_img.png")
    end,
    })
end
--战车改造添加材料爆炸特效
function carImproEff3(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.0
    display.addSpriteFrames("Effect/carImproEff3_img.plist", "Effect/carImproEff3_img.png")
    local frames = display.newFrames("carImproEff3_img%d.png", 1, 12)
    local animation = display.newAnimation(frames, ts / 12)
    local sprite = display.newSprite("#carImproEff3_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/carImproEff3_img.plist", "Effect/carImproEff3_img.png")
    end,
    })
end
--战车改造添加材料四合一特效
function carImproEff4(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 3.0
    display.addSpriteFrames("Effect/carImproEff4_img.plist", "Effect/carImproEff4_img.png")
    local frames = display.newFrames("carImproEff4_img%d.png", 1, 37)
    local animation = display.newAnimation(frames, ts / 37)
    local sprite = display.newSprite("#carImproEff4_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/carImproEff4_img.plist", "Effect/carImproEff4_img.png")
    end,
    })
end

--点金手特效
function getGoldEff1(parentNode,x,y, targetNode)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.5
    display.addSpriteFrames("Effect/getGold1_img.plist", "Effect/getGold1_img.png")
    local frames = display.newFrames("getGold1_img%d.png", 1, 17)
    local animation = display.newAnimation(frames, ts / 17)
    local sprite = display.newSprite("#getGold1_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        getGoldEff5(parentNode,-190,-10, targetNode)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold1_img.plist", "Effect/getGold1_img.png")
    end,
    })
end
function getGoldEff2(parentNode,x,y, targetNode)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.5
    display.addSpriteFrames("Effect/getGold2_img.plist", "Effect/getGold2_img.png")
    local frames = display.newFrames("getGold2_img%d.png", 1, 17)
    local animation = display.newAnimation(frames, ts / 17)
    local sprite = display.newSprite("#getGold2_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        getGoldEff5(parentNode,-93,-10, targetNode)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold2_img.plist", "Effect/getGold2_img.png")
    end,
    })
end
function getGoldEff3(parentNode,x,y, targetNode)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.5
    display.addSpriteFrames("Effect/getGold3_img.plist", "Effect/getGold3_img.png")
    local frames = display.newFrames("getGold3_img%d.png", 1, 17)
    local animation = display.newAnimation(frames, ts / 17)
    local sprite = display.newSprite("#getGold3_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        getGoldEff5(parentNode,15,-10, targetNode)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold3_img.plist", "Effect/getGold3_img.png")
    end,
    })
end
function getGoldEff4(parentNode,x,y, targetNode)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.5
    display.addSpriteFrames("Effect/getGold4_img.plist", "Effect/getGold4_img.png")
    local frames = display.newFrames("getGold4_img%d.png", 1, 17)
    local animation = display.newAnimation(frames, ts / 17)
    local sprite = display.newSprite("#getGold4_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        getGoldEff5(parentNode,115,-10, targetNode)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold4_img.plist", "Effect/getGold4_img.png")
    end,
    })
end
function getGoldEff5(parentNode,x,y, targetNode)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.2
    display.addSpriteFrames("Effect/getGold5_img.plist", "Effect/getGold5_img.png")
    local frames = display.newFrames("getGold5_img%d.png", 1, 9)
    local animation = display.newAnimation(frames, ts / 9)
    local sprite = display.newSprite("#getGold5_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationForever(animation)

    local targetWordPos = targetNode:convertToWorldSpace(cc.p(0,0))
    local pos = parentNode:convertToNodeSpace(targetWordPos)

    transition.execute(sprite,cc.MoveTo:create(0.2,cc.p(pos.x+20, pos.y+30)),
    {onComplete = function()
        getGoldEff6(targetNode, 20, 30)
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold5_img.plist", "Effect/getGold5_img.png")
    end,
    })

end
function getGoldEff6(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.2
    display.addSpriteFrames("Effect/getGold6_img.plist", "Effect/getGold6_img.png")
    local frames = display.newFrames("getGold6_img%d.png", 1, 6)
    local animation = display.newAnimation(frames, ts / 6)
    local sprite = display.newSprite("#getGold6_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale)
    sprite:playAnimationOnce(animation)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/getGold6_img.plist", "Effect/getGold6_img.png")
    end,
    })
end
--注册切换角色特效
function roleChangeEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 2.0
    display.addSpriteFrames("Effect/roleChange_img.plist", "Effect/roleChange_img.png")
    local frames = display.newFrames("roleChange_img%d.png", 1, 23)
    local animation = display.newAnimation(frames, ts / 23)
    local sprite = display.newSprite("#roleChange_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/roleChange_img.plist", "Effect/roleChange_img.png")
    end,
    })
end
--升级框闪框
function levelUpEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 0.8
    display.addSpriteFrames("Effect/levelUp_img.plist", "Effect/levelUp_img.png")
    local frames = display.newFrames("levelUp_img%d.png", 1, 7)
    local animation = display.newAnimation(frames, ts / 7)
    local sprite = display.newSprite("#levelUp_img1.png")
    sprite:addTo(parentNode,10)
    sprite:pos(x,y+20)
    sprite:scale(scale*2)
    sprite:playAnimationOnce(animation)
    sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/levelUp_img.plist", "Effect/levelUp_img.png")
    end,
    })
end
--成就可领取特效
function achiTreeEff(parentNode,x,y, scale)
    x = x or 0
    y = y or 0
    scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.0
    display.addSpriteFrames("Effect/achiTreeEff_img.plist", "Effect/achiTreeEff_img.png")
    local frames = display.newFrames("achiTreeEff_img%d.png", 1, 32)
    local animation = display.newAnimation(frames, ts / 32)
    local sprite = display.newSprite("#achiTreeEff_img1.png")
    sprite:addTo(parentNode,10, 1000)
    sprite:pos(x,y)
    sprite:scale(scale*2)
    sprite:playAnimationForever(animation)
    sprite:setBlendFunc(770,1)

    -- transition.execute(sprite,cc.DelayTime:create(ts),
    -- {onComplete = function()
    --     sprite:removeSelf()
    --     display.removeSpriteFramesWithFile("Effect/levelUp_img.plist", "Effect/levelUp_img.png")
    -- end,
    -- })
    return sprite
end
--解锁军团副本特效
function LegionUnlockEff(parentNode,x,y, callBack, callBack2)
    x = x or 0
    y = y or 0
    -- scale = scale or 1
    if parentNode==nil then
        return
    end
    ts = 1.5
    display.addSpriteFrames("Effect/legionUnlockImg.plist", "Effect/legionUnlockImg.png")
    local frames = display.newFrames("legionUnlockImg%d.png", 1, 31)
    local animation = display.newAnimation(frames, ts / 31)
    local sprite = display.newSprite("#legionUnlockImg1.png")
    sprite:addTo(parentNode,10, 1000)
    sprite:pos(x,y)
    sprite:scale(2)
    sprite:playAnimationForever(animation)
    -- sprite:setBlendFunc(770,1)

    transition.execute(sprite,cc.DelayTime:create(ts-0.8),
    {onComplete = function()
        callBack()
    end,
    })
    transition.execute(sprite,cc.DelayTime:create(ts),
    {onComplete = function()
        callBack2()
        sprite:removeSelf()
        display.removeSpriteFramesWithFile("Effect/legionUnlockImg.plist", "Effect/legionUnlockImg.png")
    end,
    })
    return sprite
end