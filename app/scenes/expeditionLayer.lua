-- 远征
-- Author: Huang Yuzhao
-- Date: 2015-08-13 10:20
--
require("app.battle.BattleInfo")

expeditionLayer = class("expeditionLayer",function()
	local layer = display.newLayer()
	layer:setNodeEventEnabled(true)
	return layer
end)

expeditionLayer.Instance = nil
g_expeditionDialogIndex = 1
g_expeditionDialog = {100001,200001,300001}
g_expeditionRewards  = {}
function expeditionLayer:ctor()
  g_nCurChildModule = 3
    GuideManager:forceSendFinishStep(129)
	  expeditionLayer.Instance = self
    self.bg = display.newSprite("Expedition/expeditionDialogBg.jpg")
    :pos(display.cx,display.cy)
    :addTo(self)
    display.newSprite("Expedition/csgate.png")
    :pos(self.bg:getContentSize().width*0.5,self.bg:getContentSize().height*0.72)
    :addTo(self.bg)
    self.bg:scale(1.333)
    local doctor = display.newSprite("Expedition/mqdoctor.png")
    :pos(display.width*0.6,display.height*0.52)
    :addTo(self)
    doctor:scale(0.7)
    doctor:setScaleX(-0.7)
	  
    --返回按钮
    self.backItem = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    :align(display.LEFT_TOP, 0, display.height )
    :addTo(self)
    :onButtonClicked(function(event)
        if FightSceneEnterType == EnterTypeList_2.EXPEDITION_ENTER then
           FightSceneEnterType = EnterTypeList_2.NORMAL_ENTER
        end
        g_expeditionDialogIndex = 1
        g_expeditionRewards  = {}
        self:removeFromParent()
    end)
    self.backItem:setVisible(false)
    
    local tabMsg = {}
    startLoading()
    m_socket:SendRequest(json.encode(tabMsg), CMD_ROLE_PROPERTY, self, self.OnRolePropertyDataRet)

end

function expeditionLayer:OnRolePropertyDataRet(cmd)
  if cmd.result == 1 then
      self:addMembers(cmd["data"]["members"])
  else
      showTips(cmd.msg)
  end
end

function expeditionLayer:addMembers(_members)
    local manager = ccs.ArmatureDataManager:getInstance()
    for i=1,#_members do
        local member = nil
        local resName = memberData[_members[i]["tmpId"]]["resId"]
        if tonumber(memberData[_members[i]["tmpId"]]["actType"]) == 1 then
            manager:addArmatureFileInfo("Battle/Hero/Hero_"..resName.."_.ExportJson")
            member = ccs.Armature:create("Hero_"..resName.."_")
            self:addChild(member)
            member:setPosition(AttackPositions[i][1]-display.width/2, AttackPositions[i][2])
            member:scale(memberData[_members[i]["tmpId"]]["scale"]*BattleScaleValue)
            member:setScaleX(-1*member:getScaleX())
            member:getAnimation():play("walk")
        else
            member = sp.SkeletonAnimation:create("Battle/Hero/Hero_"..resName.."_.json","Battle/Hero/Hero_"..resName.."_.atlas",1)
            self:addChild(member)
            member:setPosition(AttackPositions[i][1]-display.width/2, AttackPositions[i][2])
            member:scale(memberData[_members[i]["tmpId"]]["scale"]*BattleScaleValue)
            member:setScaleX(-1*member:getScaleX())
            member:setToSetupPose()
            member:setAnimation(0, "walk", true)
        end
        member:runAction(transition.sequence({
                                                 cc.MoveBy:create(2,cc.p(display.width/2,0)),
                                                 cc.CallFunc:create(function()
                                                      if tonumber(memberData[_members[i]["tmpId"]]["actType"]) == 1 then
                                                          member:getAnimation():play("Standby")
                                                      else
                                                          member:setToSetupPose()
                                                          member:setAnimation(0, "Standby", true)
                                                      end
                                                 end)
                                             }))

    end
    self:performWithDelay(self.addDialog,2)
end

function expeditionLayer:addDialog()
    local dlg = UIDialog.new()
    dlg:addTo(self)
    local dilogId = g_expeditionDialog[g_expeditionDialogIndex]
    dlg:TriggerDialog(dilogId, DialogType.RegisterPlot)
    dlg:SetFinishCallback(function()
        if g_expeditionDialogIndex == 1 then
            g_expeditionDialogIndex = g_expeditionDialogIndex
            dlg:removeFromParent()
            local function addButtons()
                local fightButton = cc.ui.UIPushButton.new({normal="Expedition/yuanhi_oiiqw-01.png"})
                :align(display.CENTER_RIGHT, display.width, display.height*0.5)
                :addTo(self)
                :onButtonClicked(function(event)
                    g_WarriorsCenterMgr:ReqExpeditionSatrt()
                end)
                fightButton:runAction(cc.RepeatForever:create(transition.sequence{
                                                                                    fightButton:runAction(cc.MoveBy:create(0.45,cc.p(-display.width/50,0))),
                                                                                    fightButton:runAction(cc.MoveBy:create(0.45,cc.p(display.width/50,0))),
                                                                                 }))
                local shopButtonBarOne = display.newSprite("Expedition/yuanhi_oiiqw-03.png")
                :pos(display.width*0.93, display.height*0.15)
                :addTo(self)
                local shopButtonBarTwo = display.newSprite("Expedition/yuanhi_oiiqw-04.png")
                :pos(display.width*0.975, display.height*0.1)
                :addTo(self)
                local shopButton = cc.ui.UIPushButton.new({normal="Expedition/yuanhi_oiiqw-02.png"})
                :align(display.CENTER_RIGHT, display.width*0.99, display.height*0.25)
                :addTo(self)
                shopButton:onButtonPressed(function(event)
                    shopButtonBarOne:runAction(cc.MoveBy:create(0.15,cc.p(0,-display.height*0.01)))
                    shopButton:runAction(cc.MoveBy:create(0.15,cc.p(0,-display.height*0.01)))
                    shopButtonBarTwo:runAction(cc.RotateBy:create(0.15,-15))
                end)
                shopButton:onButtonRelease(function(event)
                    shopButtonBarOne:runAction(cc.MoveBy:create(0.15,cc.p(0,display.height*0.01)))
                    shopButton:runAction(cc.MoveBy:create(0.15,cc.p(0,display.height*0.01)))
                    shopButtonBarTwo:runAction(cc.RotateBy:create(0.15,15))
                    
                end)
                shopButton:onButtonClicked(function ( ... )
                  shopLayer.new(5)
                    :addTo(display.getRunningScene(),52)
                end)
            end
            self:performWithDelay(addButtons,0.1)
            -- g_WarriorsCenterMgr:ReqExpeditionSatrt()
            self.backItem:setVisible(true)
            
        elseif g_expeditionDialogIndex == 2 then
            local manager = ccs.ArmatureDataManager:getInstance()
            manager:addArmatureFileInfo("Expedition/boxEffect.ExportJson")
            self:showRewards()
        else
            if FightSceneEnterType == EnterTypeList_2.EXPEDITION_ENTER then
                FightSceneEnterType = EnterTypeList_2.NORMAL_ENTER
            end
            g_expeditionDialogIndex = 1
            g_expeditionRewards  = {}
            self:removeFromParent()
        end
    end)
end

function expeditionLayer:showRewards()
    self.allBox = {}
    if #g_expeditionRewards <= 0 then
       self.backItem:setVisible(true)
       return
    end
    local groupNum = math.floor(#g_expeditionRewards/6)
    local lastNum = #g_expeditionRewards%6
    local showIndex = 0
    local function addOneGroup()
        local startIndex = 0
        local endIndex = 0
        if groupNum > 0 then
           startIndex = 1 + showIndex*6
           endIndex = (showIndex+1)*6
        else
           startIndex = 1 + showIndex*6
           endIndex = showIndex*6 + lastNum
        end
        local allNum = endIndex - startIndex  + 1
        for i=startIndex,endIndex do
           local dc_item = itemData[g_expeditionRewards[i]["id"]+0]
           DCItem.get(tostring(dc_item.id), dc_item.name, g_expeditionRewards[i]["num"], "远征掉落")
           
           local box = ccs.Armature:create("boxEffect")
           self:addChild(box)
           table.insert(self.allBox,#self.allBox + 1,box)
           box:getAnimation():play("show")
           box:performWithDelay(function()
               box:getAnimation():play("stay")
           end,0.34)
           local tLayer = display.newNode()
           :pos(-display.width*0.05,-display.width*0.01)
           :addTo(box)
           tLayer:setContentSize(cc.size(display.width*0.1,display.width*0.09))
           tLayer:setTouchEnabled(true)
           tLayer:setTouchSwallowEnabled(true)
           tLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
              if event.name == "began" then
                   box:getAnimation():play("open")
                   box:performWithDelay(function()
                       local itemSprite = GlobalGetItemIcon(g_expeditionRewards[i]["id"])
                       :pos(0,display.width*0.13)
                       :addTo(box)
                       self.timeLabel=cc.ui.UILabel.new({UILabelType = 2, text = tostring(g_expeditionRewards[i]["num"]), size = display.width*0.02, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
                       :pos(itemSprite:getContentSize().width*0.76, itemSprite:getContentSize().height*0.22)
                       :addTo(itemSprite)
                   end, 0.34)
                   allNum = allNum - 1
                   if allNum <= 0 then
                       if groupNum > 0 then
                           self.nextItem:setVisible(true)
                       elseif groupNum == 0 then
                            if lastNum > 0 then
                              self.nextItem:setVisible(true)
                            else
                              self:performWithDelay(function()
                                  for k,v in pairs(self.allBox) do
                                      v:runAction(cc.FadeOut:create(0.8))
                                  end
                              end,2)
                              self:performWithDelay(function()
                                  for k,v in pairs(self.allBox) do
                                      v:removeSelf()
                                  end
                              end,3)
                              self.backItem:setVisible(true)
                            end
                       else
                              self:performWithDelay(function()
                                  for k,v in pairs(self.allBox) do
                                      v:runAction(cc.FadeOut:create(0.8))
                                  end
                              end,2)
                              self:performWithDelay(function()
                                  for k,v in pairs(self.allBox) do
                                      v:removeSelf()
                                  end
                              end,3)

                          self.backItem:setVisible(true)
                       end
                   end
                   tLayer:setTouchEnabled(false)
              end
              return true
           end)
        end
        local x = math.floor(allNum/2)
        local y = allNum%2
        if y == 0 then --偶数
            for i=x,1,-1 do--前半段
                self.allBox[i]:setPosition(display.width*0.44 - display.width*0.12*(x-i), display.height*0.4)
            end
            for i=x+1,x*2,1 do--后半段
                self.allBox[i]:setPosition(display.width*0.56 + display.width*0.12*(i-x-1), display.height*0.4)
            end
        elseif y == 1 then --奇数
            self.allBox[x+y]:setPosition(display.width*0.5, display.height*0.4)--中间位置
            for i=x,1,-1 do--前半段
                self.allBox[i]:setPosition(display.width*0.38 - display.width*0.12*(x-i), display.height*0.4)
            end
            for i=x+2,x*2+1,1 do--后半段
                self.allBox[i]:setPosition(display.width*0.62 + display.width*0.12*(i-x-2), display.height*0.4)
            end
        end 
        groupNum = groupNum - 1
        showIndex = showIndex + 1
    end
    self.nextItem = cc.ui.UIPushButton.new({normal="Battle/PVPUI/jjc_fair_d02-09.png", pressed="Battle/PVPUI/jjc_fair_d02-08.png"})
    :pos(display.width*0.88, display.height*0.25)
    :addTo(self)
    :onButtonClicked(function(event)
        for k,v in pairs(self.allBox) do
            v:runAction(cc.FadeOut:create(0.8))
        end
        self:performWithDelay(function()
            for k,v in pairs(self.allBox) do
                v:removeSelf()
            end
            self.allBox = {}
            addOneGroup()
        end,1)
        self.nextItem:setVisible(false)
    end)
    local nextTitle = display.newSprite("Expedition/youhou_pusa-05-01.png")
    :pos(0, 0)
    :addTo(self.nextItem)
    self.nextItem:setVisible(false)
    addOneGroup()
end

function expeditionLayer:onTouchEnded(point)
		-- self:hide()
 --    if nil~=self.onTouchEndedEvent then
 --        self.onTouchEndedEvent()
 --    end
end

function expeditionLayer:OnExpeditionStartRet(cmd)
	if 1==cmd.result then   --今日还没远征过，现在去第一次布阵
		    local layer = EmbattleScene.new({BattleType_EXPEDITION, 0,cmd})
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer, 52,111)
        self:setVisible(false)
	elseif 2==cmd.result then     --今日已经远征过，直接进入战斗
        BattleData = cmd.data
		app:enterScene("LoadingScene", {SceneType.Type_Expedition})
		FightSceneEnterType = EnterTypeList_2.EXPEDITION_ENTER
	else
        self:removeSelf()
	end
end

function expeditionLayer:UpdateFormationRet(cmd)
	if 1==cmd.result then   --第一次布阵完毕，现在去第二次布阵
		local layer = EmbattleScene.new({BattleType_EXPEDITION, 0,cmd})
        local scene = cc.Director:getInstance():getRunningScene()
        scene:removeChildByTag(111)
        scene:addChild(layer, 52,111)
        self:setVisible(false)
	elseif 2==cmd.result then     --第二次布阵完毕，现在去进入战斗
		app:enterScene("LoadingScene", {SceneType.Type_Expedition})
		FightSceneEnterType = EnterTypeList_2.EXPEDITION_ENTER
	else
		  showTips(cmd.msg)
	end
	
end

function expeditionLayer:onEnter()
	 MainSceneEnterType = EnterTypeList.NORMAL_ENTER
end

function expeditionLayer:onExit()
	expeditionLayer.Instance = nil
	g_WarriorsCenterMgr.step = -1
	print("g_WarriorsCenterMgr.step-------------------: "..g_WarriorsCenterMgr.step)
end

return expeditionLayer