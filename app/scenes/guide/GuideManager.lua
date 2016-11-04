--
-- Author: liufei
-- Date: 2015-03-02 16:30:24
--
require("app.scenes.guide.GuidePosition")
require("app.utils.getPositionLayer")

GuideManager = class("GuideManager")
GuideManager.NextStep  = 0
GuideManager.NextLocalStep = 0
local clipNode = nil
GuideManager.IsFirstGuide = false
-- 关闭新手引导：bIsCloseGuide = true
local bIsCloseGuide = g_isGuideClose

function getIsGuideClosed()
    return bIsCloseGuide
end

--检查是否需要在新手引导走完前关闭一些功能
GuideManager.needCheck = {}
GuideManager.needCheck.c_device = 10801   --c装置开孔
GuideManager.needCheck.bounty = 11701 --赏金首
GuideManager.needCheck.rentcar = 11201--租车
GuideManager.needCheck.piece = 12301  --碎片合成引擎
function GuideManager:checkOpenFunction(_guideId)
    if bIsCloseGuide then
      return false
    end
    print("checkOpenFunction(_guideId)".._guideId)
    if _guideId == GuideManager.needCheck.rentcar then
      print("srv_userInfo.maxBlockId:",srv_userInfo.maxBlockId)
      local num = tonumber(string.sub(tostring(srv_userInfo.maxBlockId), 4,8))
      if num< 1004 then
          return true
      else 
          return false
      end
    end

    if _guideId~=GuideManager.needCheck.rentcar and _guideId~=GuideManager.needCheck.c_device and _guideId~=GuideManager.needCheck.piece then
      return false
    end
    if srv_userInfo.isPass==1 or tonumber(GuideManager.NextStep)==0 or (srv_userInfo and tonumber(srv_userInfo.guideStep)==-1) then
      return false
    end
    if tonumber(GuideManager.NextStep)<_guideId then
        return true
    end
    return false
end

--开启条件引导（与新手引导树中其它引导无先后关系，由特定条件开启，以2开头）
GuideManager.guideConditions = {}
GuideManager.guideConditions.after_1_1_9 = 201  --打完1-9，引导装备进阶
GuideManager.guideConditions.after_1_2_5 = 203  --打完精英1-5，引导赏金首
GuideManager.guideConditions.bountyGet = 205  --打败赏金首后，引导领奖
function GuideManager:setCondition(_condition)
    if g_IsDebug then
        showTips("上传条件引导:".._condition,cc.c3b(255,0,0))
        showLogLabel("上传条件引导:".._condition)
    end
    srv_userInfo.guideStep2 = _condition
    return srv_userInfo.guideStep2
end
function GuideManager:resetCondition(tabMsg)
    if g_IsDebug then
        showTips("重置条件引导:",cc.c3b(255,0,0))
        showLogLabel("重置条件引导:")
    end
    tabMsg.guideStep2 = 0
    srv_userInfo.guideStep2 = 0
end
function GuideManager:getCondition()
    -- local ret = cc.UserDefault:getInstance():getIntegerForKey(mUserId.."guideCondition")
    -- return ret

    return srv_userInfo.guideStep2
end
--强制修改条件引导
function GuideManager:sendConditionForce(_step2)
    if g_IsDebug then
        showTips("修改条件引导:".._step2,cc.c3b(255,0,0))
        showLogLabel("修改条件引导:".._step2)
    end
    local comData = {}
    comData["step2"] = _step2
    m_socket:SendRequest(json.encode(comData), CMD_UPDATE_GUIDESTEP, GuideManager, GuideManager.OnUpdateGuideStep)
    srv_userInfo.guideStep2 = _step2
    GuideManager.NextLocalStep = _step2
end
--打开条件引导
function GuideManager:openConditionGuide(_condition)
    if _condition==GuideManager.guideConditions.after_1_1_9 then
        GuideManager.NextLocalStep = 20101
        return GuideManager:setCondition(202)
    elseif _condition==GuideManager.guideConditions.after_1_2_5 then
        GuideManager.NextLocalStep = 20301
        return GuideManager:setCondition(204)
    elseif _condition==GuideManager.guideConditions.bountyGet then
        GuideManager.NextLocalStep = 20406
        return GuideManager:setCondition(205)
    end
    return 0
end

function GuideManager:_addGuide_2(_guideId, _layer,_guideFunc, _zOrder)
    if srv_userInfo.isPass==1 and _guideId<12101 then
      return
    end
    if bIsCloseGuide then
      return
    end    
    local _bol = nil
    if tonumber(string.sub(tostring(_guideId), 1,1)) == 1 then
        --print("11尝试添加条件引导：".._guideId)
        print("srv_userInfo.guideStep:"..srv_userInfo.guideStep.."parma _guideId = ".._guideId)
        if tonumber(srv_userInfo.guideStep) == -1 then
           --新手教程已全部完成
           return
        end
        if tonumber(GuideManager.NextStep) == 0 then
            GuideManager.NextStep = tonumber(tostring(srv_userInfo.guideStep).."01")
        end

        _bol = tonumber(_guideId) == tonumber(GuideManager.NextStep)
    elseif tonumber(string.sub(tostring(_guideId), 1,1)) == 2 then
        --print("22尝试添加条件引导：".._guideId)
        local loc_guideStep = self:getCondition()
        print("loc_guideStep: "..loc_guideStep)
        print("self.hasNorGuide:")
        print(self.hasNorGuide)
        if self.hasNorGuide then
           --正在进行其它引导，于是推迟条件引导，条件已经达成，下次再触发
           return
        end
        print("------"..GuideManager.NextLocalStep)
        if tonumber(GuideManager.NextLocalStep) == 0 then
            if loc_guideStep==0 then
                return
            end
            GuideManager.NextLocalStep = tonumber(loc_guideStep.."01")
        end
        _bol = tonumber(_guideId) == tonumber(GuideManager.NextLocalStep)
        -- if _bol then
        --     if _guideId==20204 or _guideId==20504 then
        --         self:resetCondition()
        --     end
        -- end
    end
    
    if _bol then
      if tonumber(string.sub(tostring(_guideId), 1,1)) == 1 then
        self.hasNorGuide = true
        print("self.hasNorGuide = true--gggggggggggggggggg")
        GuideManager.NextStep = GuidePositions[_guideId].nextStep
        print("-----------------_guideId: ".._guideId.."  GuideManager.NextStep: "..GuideManager.NextStep)
      elseif tonumber(string.sub(tostring(_guideId), 1,1)) == 2 then
        GuideManager.NextLocalStep = GuidePositions[_guideId].nextStep
        print("-----------------_guideId: ".._guideId.."  GuideManager.NextStep: "..GuideManager.NextLocalStep)
      end
      
      local function addMyGuide()
          self:addGuideLayer(_guideId,_layer,_guideFunc,_zOrder)
          setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
      end

      local function _callFunc(plist, image)
          --延迟0.1 防止触摸BUG
          _layer:performWithDelay(addMyGuide, 0.05)
          print("有效添加引导-------------------------".._guideId)
      end

      if GuideManager.IsFirstGuide == true then
        print("Is true first guide----------")
         display.addSpriteFrames("common/GuideRes.plist","common/GuideRes.png",_callFunc)
         GuideManager.IsFirstGuide = false
       else
        print("Is not first guide==========")
          _callFunc()
      end
      
    end
   
end
 
function GuideManager:addGuideLayer(_guideId,_layer,_guideFunc,_zOrder)
    -- --这是添加测量标尺，以便计算
    -- getPositionLayer.new()
    --             :addTo(_layer)
    if _guideId == 12901 then 
      local MainLineChoose = require("app.battle.battleUI.MainLineChoose")
      local chooseLayer = MainLineChoose.new(function ( ... )
          self:forceSendFinishStep(130)
          MainScene_Instance:addGuide_ani(13001)
      end)
         :addTo(_layer,45)
      print("GuideManager.NextStep=================",GuideManager.NextStep)
      return
    end

    if clipNode ~= nil then
        self:removeGuideLayer()
    end
    self.guideID = _guideId
	  local bgColor = cc.c3b(0, 0, 0) --非高亮区域颜色
    local bgOpacity = 0.25 --非高亮区域透明度
    local layerColor = display.newLayer() --cc.LayerColor:create(cc.c4f(bgColor.r, bgColor.g, bgColor.b, bgOpacity * 255),  display.width, display.height)
    layerColor:setContentSize(display.width, display.height) 
    clipNode = cc.ClippingNode:create()
    clipNode:setInverted(true)--设定遮罩的模式true显示没有被遮起来的纹理   如果是false就显示遮罩起来的纹理  
    clipNode:setAlphaThreshold(1)--设定遮罩图层的透明度取值范围 
    clipNode:addChild(layerColor)
    clipNode:setPosition(0, 0)
    local g_arrowPos,g_promptRect,g_targetPos = nil,nil,nil
    if _guideFunc~=nil  then
        g_arrowPos,g_promptRect,g_targetPos = _guideFunc(_guideId)
        if g_arrowPos~=nil or g_promptRect~=nil then
           
            if g_promptRect~=nil then
                GuidePositions[_guideId].promptRect = g_promptRect
            end
            if g_arrowPos~=nil then
                GuidePositions[_guideId].arrowPos = g_arrowPos
            end
            print("-------------caculated，已经经过计算了 "..self.guideID)
        end
    end
    -- local rect = {
    --             {GuidePositions[_guideId].promptRect.x,GuidePositions[_guideId].promptRect.y},
    --             {GuidePositions[_guideId].promptRect.x,GuidePositions[_guideId].promptRect.y + GuidePositions[_guideId].promptRect.height},
    --             {GuidePositions[_guideId].promptRect.x + GuidePositions[_guideId].promptRect.width,GuidePositions[_guideId].promptRect.y + GuidePositions[_guideId].promptRect.height},
    --             {GuidePositions[_guideId].promptRect.x + GuidePositions[_guideId].promptRect.width,GuidePositions[_guideId].promptRect.y},
    --           }
    local rect = {
                    {0,0},
                    {0,0},
                    {0,0},
                    {0,0},
                 }
    local polygon = display.newPolygon(rect,{borderWidth = 3, fillColor = cc.c4f(1, 1, 1, 1), borderColor = cc.c4f(1, 1, 0, 1)})
    clipNode:setStencil(polygon) --一定要有，设置裁剪模板
    if _zOrder ~= nil then
       _layer:addChild(clipNode,_zOrder)
    else
       _layer:addChild(clipNode,500)
    end
    clipNode:setTouchEnabled(true)
    clipNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        if event.name == "began" then
          if cc.rectContainsPoint(GuidePositions[_guideId].promptRect, cc.p(event.x, event.y)) then
              print("Touch In")
              return false
          else
              print("Touch Out")
              return true
          end
        end
    end)

    if GuidePositions[_guideId].guiderPos ~= nil then
      --指引者
      local guider = display.newSprite("Bust/bust_guider.png")
      :pos(GuidePositions[_guideId].guiderPos.x, GuidePositions[_guideId].guiderPos.y)
      :addTo(layerColor)
      guider:setScaleX(GuidePositions[_guideId].guiderX)
      --指引对话框
      local textPanel = display.newScale9Sprite("common2/com2_img_28.png",nil,nil,cc.size(646,140),cc.rect(24,20,100,100))
      :pos(GuidePositions[_guideId].wordsPos.x, GuidePositions[_guideId].wordsPos.y)
      :addTo(layerColor)
      --对话内容
      local wordsLabel = cc.ui.UILabel.new({UILabelType = 2, text = GuidePositions[_guideId].words, size = textPanel:getContentSize().height*0.18, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(201,188,156)})
      :align(display.CENTER_LEFT, textPanel:getContentSize().width*0.05, textPanel:getContentSize().height*0.5)
      :addTo(textPanel)
      wordsLabel:setDimensions(textPanel:getContentSize().width*0.9, textPanel:getContentSize().height*0.7)
    end

    local effSp = display.newSprite("#guideTouchEff_00.png")
    :pos(GuidePositions[_guideId].promptRect.x + GuidePositions[_guideId].promptRect.width/2,GuidePositions[_guideId].promptRect.y + GuidePositions[_guideId].promptRect.height/2)
    :addTo(layerColor)
    effSp:scale(GuidePositions[_guideId].touchScale*0.7)
    local effframes = display.newFrames("guideTouchEff_%02d.png", 0, 16)
    local effanimation = display.newAnimation(effframes, 1.5/20)
    effAction = cc.Animate:create(effanimation)
    
    local arrow = display.newSprite("#guideFinger.png") 
    :addTo(layerColor)
    arrow:scale(0.6)
    arrow:setPosition(GuidePositions[_guideId].arrowPos.x, GuidePositions[_guideId].arrowPos.y)
    local moveRange = display.width*0.015
    local angle = 35
    local outPos = cc.p(arrow:getPositionX() - moveRange*math.cos(angle),arrow:getPositionY() + moveRange*math.sin(angle))

    if self.guideID == 10508 then --需要移动箭头的特殊处理
       --effSp:setPosition(cc.p(display.width*0.78,display.width*0.4))
       effSp:runAction(cc.RepeatForever:create(effAction))
       local hold = cc.Repeat:create(transition.sequence({
                                                                  cc.MoveTo:create(0.25, outPos),
                                                                  cc.MoveTo:create(0.25, cc.p(arrow:getPositionX(),arrow:getPositionY())),
                                                                }),2)
       arrow:runAction(cc.RepeatForever:create(transition.sequence({
                                              cc.CallFunc:create(function()
                                                arrow:setPosition(GuidePositions[_guideId].arrowPos.x, GuidePositions[_guideId].arrowPos.y)
                                              end),
                                              hold,
                                              cc.MoveTo:create(1.3, cc.p(g_targetPos.x,g_targetPos.y)),
                                              cc.DelayTime:create(0.5)
                                           })))
    elseif false then --需要移动箭头的特殊处理
        --effSp:setPosition(GuidePositions[_guideId].arrowPos.x, GuidePositions[_guideId].arrowPos.y)
        print("------------------------------------5555")
        printTable(g_targetPos)
        print("------------------------------------5555")
        effSp:runAction(cc.RepeatForever:create(effAction))
        local hold = cc.Repeat:create(transition.sequence({
                                                                    cc.MoveTo:create(0.25, outPos),
                                                                    cc.MoveTo:create(0.25, cc.p(arrow:getPositionX(),arrow:getPositionY())),
                                                                  }),2)
        arrow:runAction(cc.RepeatForever:create(transition.sequence({
                                                cc.CallFunc:create(function()
                                                  arrow:setPosition(GuidePositions[_guideId].arrowPos.x, GuidePositions[_guideId].arrowPos.y)
                                                end),
                                                hold,
                                                cc.MoveTo:create(1.3, cc.p(g_targetPos.x,g_targetPos.y)),
                                                cc.DelayTime:create(0.5)
                                             })))
    else
      effSp:setBlendFunc(770,1)
       effSp:runAction(cc.RepeatForever:create(effAction))
       arrow:runAction(cc.RepeatForever:create(transition.sequence({
                                                                  cc.MoveTo:create(0.25, outPos),
                                                                  cc.MoveTo:create(0.25, cc.p(arrow:getPositionX(),arrow:getPositionY())),
                                                                })))
    end

    self.hideCall = function ()
      arrow:hide()
      effSp:hide()
      -- layerColor:setOpacity(0)
      -- layerColor:setColor(cc.c3b(0,50,0))
    end
    
end

function GuideManager:removeGuideLayer()
    self.hideCall = nil
    if self.guideID == nil then
        return
    end
    self.hasNorGuide = false
    if clipNode ~= nil then
          if isNodeValue(clipNode) then
            clipNode:removeSelf()
            clipNode = nil
          else
            clipNode = nil
          end
    end
end

function GuideManager:forceSendFinishStep(_step,force)
    local g_step = self:tryToSendFinishStep(_step) 
    if (not force) and g_step==nil then
        return
    end
    local comData = {}
    comData["step"] = _step
    m_socket:SendRequest(json.encode(comData), CMD_UPDATE_GUIDESTEP, GuideManager, GuideManager.OnUpdateGuideStep)
    srv_userInfo.guideStep = _step

end

function GuideManager:sendFinishStep(_step)
    if g_IsDebug then
        showTips("新手教程上报:".._step,cc.c3b(255,0,0))
        showLogLabel("新手教程上报:".._step)
    end
    srv_userInfo.guideStep = _step
    return _step
end

function GuideManager:tryToSendFinishStep(_step)
    print("tryToSendFinishStep() : ".._step)
    local _next = tonumber(self.NextStep)
    print("self.nextStep:".._next)
    if bIsCloseGuide or self.guideID==nil or tonumber(srv_userInfo.guideStep) == -1 or GuideManager.NextStep==-1 or GuideManager.NextStep == 0 then
      return nil
    end

    local nextBigStep = tonumber(string.sub(tostring(_next), 1,3))
    local curBigStep = tonumber(string.sub(tostring(self.guideID), 1,3))
    print("curBigStep:"..curBigStep.."  nextBigStep:  "..nextBigStep)
    if GuidePositions[_next] and GuidePositions[_next].needReport == true and (curBigStep+1==_step or (curBigStep == 122 and _step==124) or (curBigStep == 117 and _step==121)) then  --不是最后一小步，即nextBigStep==curBigStep
        return self:sendFinishStep(_step)
    elseif nextBigStep==_step and (curBigStep+1 ==nextBigStep or (curBigStep == 117 and _step==121) or (curBigStep == 122 and _step==124))then  --nextBigStep=curBigStep+1
        return self:sendFinishStep(_step)
    else
        --print("error, 试图上传错误的新手引导进程!")
    end
    return nil
end

function GuideManager:OnUpdateGuideStep(result)
    if tonumber(result["result"]) ~= 1 then
      print("Error:"..result["msg"])
      showMessageBox(result["msg"])
      return
    end
end
--隐藏手指和光圈，但是触摸屏蔽依然存在
function GuideManager:hideGuideEff()
    if self.hideCall then
      self.hideCall()
    end
end

function GuideManager:ReqSkip()
    local comData={isPass = 1}
    m_socket:SendRequest(json.encode(comData), CMD_SKIP_GUIDE,GuideManager,GuideManager.skipCallback)
end

function GuideManager:skipCallback(cmd)
    endLoading()
  if 1==cmd.result then
    srv_userInfo.isPass = 1
  else
    showTips(cmd.msg)
  end
end