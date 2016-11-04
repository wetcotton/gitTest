--
-- Author: liufei
-- Date: 2014-11-19 10:34:55
--
--战斗界面英雄控制台
require("app.battle.BattleInfo")
require("app.battle.battleAI.LaserGunAI")
local SpriteProgress = require("app.battle.battleUI.SpriteProgress")

local SkillPosType = {}
SkillPosType.skillOne = 1
SkillPosType.skillTwo = 2

local curGuideBtn = nil
local ControlDesk = class("ControlDesk", function()
  local node = display.newNode()
  node:setNodeEventEnabled(true)
	return node
end)

function ControlDesk:ctor(_member)
  self:setContentSize(cc.size(200, 200))
  self.controlSize = cc.size(200, 200)
  self.skillItemPos = {
                        [1] = {scaleX =  1, scaleY =  1, itemPosX = self.controlSize.width*0.21, itemPosY = self.controlSize.height*0.78,imgPosX = self.controlSize.width*0.21, imgPosY = self.controlSize.height*0.79, ePosX = self.controlSize.width*0.331, ePosY = self.controlSize.height*0.78},--2
                        [2] = {scaleX =  1, scaleY = -1, itemPosX = self.controlSize.width*0.21, itemPosY = self.controlSize.height*0.44,imgPosX = self.controlSize.width*0.21, imgPosY = self.controlSize.height*0.43, ePosX = self.controlSize.width*0.327, ePosY = self.controlSize.height*0.44},--1
                        [3] = {scaleX = -1, scaleY = -1, itemPosX = self.controlSize.width*0.79, itemPosY = self.controlSize.height*0.44,imgPosX = self.controlSize.width*0.79, imgPosY = self.controlSize.height*0.43, ePosX = self.controlSize.width*0.669, ePosY = self.controlSize.height*0.43},--4
                        [4] = {scaleX = -1, scaleY =  1, itemPosX = self.controlSize.width*0.79, itemPosY = self.controlSize.height*0.78,imgPosX = self.controlSize.width*0.79, imgPosY = self.controlSize.height*0.79, ePosX = self.controlSize.width*0.671, ePosY = self.controlSize.height*0.78},--3
                        [6] = {scaleX = -1, scaleY =  1, itemPosX = self.controlSize.width*0.16, itemPosY = self.controlSize.height*0.59,imgPosX = self.controlSize.width*0.1785, imgPosY = self.controlSize.height*0.603, ePosX = self.controlSize.width*0.22, ePosY = self.controlSize.height*0.605, sType = MemberSkillType.kSkillTankOne},
                        [7] = {scaleX = 1, scaleY =  1, itemPosX = self.controlSize.width*0.85, itemPosY = self.controlSize.height*0.59,imgPosX = self.controlSize.width*0.83, imgPosY = self.controlSize.height*0.603, ePosX = self.controlSize.width*0.78, ePosY = self.controlSize.height*0.605, sType = MemberSkillType.kSkillTankTwo},
                      }
  --底板
  if _member.m_memberType ==  MemberAllType.kMemberHero then --英雄
     -- local controlBlackBg = display.newSprite("Battle/battleImg_1.png")
     -- :pos(self.controlSize.width*0.5,self.controlSize.height*0.5)
     -- :addTo(self)
     -- controlBlackBg:setScaleX(10.3)
     -- local leftBg = display.newSprite("Battle/battleImg_2.png")
     -- :pos(-20,self.controlSize.height*0.5)
     -- :addTo(self)
     -- local rightBg = display.newSprite("Battle/battleImg_2.png")
     -- :pos(220,self.controlSize.height*0.5)
     -- :addTo(self)
     -- rightBg:setScaleX(-1)
  else--坦克
     -- local controlBlackBg = display.newSprite("Battle/battleImg_3.png")
     -- :pos(self.controlSize.width*0.5,self.controlSize.height*0.5)
     -- :addTo(self)
     -- controlBlackBg:setScaleX(26)
     -- local leftBg = display.newSprite("Battle/battleImg_4.png")
     -- :pos(-20,self.controlSize.height*0.5)
     -- :addTo(self)
     -- local rightBg = display.newSprite("Battle/battleImg_4.png")
     -- :pos(220,self.controlSize.height*0.5)
     -- :addTo(self)
     -- rightBg:setScaleX(-1)
  end

  local headName = nil
  if _member.m_memberType == MemberAllType.kMemberHero then
        headName = "Head/chead_"..string.sub(tostring(_member.m_attackInfo.tptId),1,4)..".png"
  else
        headName = string.format("Head/head_%d.png", tonumber(carData[_member.m_attackInfo.tptId]["resId"]))
  end

  self.member = _member
  
  --所有的控制单元
  self.allControlUnit = {}
  self.isPausingItem = false
  self.curAutoIndex = 1

	--英雄技能
	if _member.m_memberType == MemberAllType.kMemberHero then
      --能量条
      display.newSprite("Battle/battleImg_5.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.08)
      :addTo(self)
      self.energyProgress = display.newProgressTimer("Battle/battleImg_6.png", display.PROGRESS_TIMER_BAR)
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.08)
      :addTo(self)
      self.energyProgress:setMidpoint(cc.p(0, 0.5))
      self.energyProgress:setBarChangeRate(cc.p(1.0, 0))
      self.energyProgress:setPercentage(0)
      -- display.newSprite("Battle/battleImg_7.png")
      -- :pos(self.controlSize.width*0.5,self.controlSize.height*0.08)
      -- :addTo(self)
      self.energyLabel=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "0/100", size = self:getContentSize().height*0.06, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
      :align(display.CENTER, self:getContentSize().width*0.5, self:getContentSize().height*0.075)
      :addTo(self)
      self.energyLabel:enableOutline(cc.c4f(0,0,0,255),1)

      --生命条
      display.newSprite("Battle/battleImg_5.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.18)
      :addTo(self)
      self.hpProgress = display.newProgressTimer("Battle/battleImg_8.png", display.PROGRESS_TIMER_BAR)
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.18)
      :addTo(self)
      self.hpProgress:setMidpoint(cc.p(0, 0.5))
      self.hpProgress:setBarChangeRate(cc.p(1.0, 0))
      self.hpProgress:setPercentage(100)
      -- display.newSprite("Battle/battleImg_7.png")
      -- :pos(self.controlSize.width*0.5,self.controlSize.height*0.18)
      -- :addTo(self)
      self.hpLabel=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = tostring(_member.m_attackInfo.curHp).."/"..tostring(_member.m_attackInfo.maxHp), size = self:getContentSize().height*0.06, align = cc.ui.TEXT_ALIGN_CENTER ,color = COLOR_WHITE})--cc.c3b(255,255,0)
      :align(display.CENTER, self:getContentSize().width*0.5, self:getContentSize().height*0.175)
      :addTo(self)
      self.hpLabel:enableOutline(cc.c4f(0,0,0,255),1)
      --头像
      display.newSprite("Battle/battleImg_9.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.605)
      :addTo(self,1)
      self.headSp = display.newSprite(headName)
      :pos(self:getContentSize().width*0.5,self:getContentSize().height*0.60)
      :scale(0.6)
      :addTo(self,1)
      --4个技能按钮
      local rotateNum = {-45,45,-45,45}
      for i=1,4 do
        if self.member.m_energySkills[i].id == nil or self.member.m_energySkills[i].id == 0 then --没解锁
            local itemSp = display.newSprite("Battle/battleImg_10.png")
            :pos(self.skillItemPos[i].itemPosX,self.skillItemPos[i].itemPosY)
            :addTo(self)
            itemSp:setScaleX(self.skillItemPos[i].scaleX)
            itemSp:setScaleY(self.skillItemPos[i].scaleY)
            itemSp:setColor(display.COLOR_BLACK)
            display.newSprite("Battle/battleImg_23.png")
              :pos(self.skillItemPos[i].itemPosX*1.1,self.skillItemPos[i].itemPosY)
              :addTo(self)
        else
            self.allControlUnit[#self.allControlUnit + 1] = {skillType = 0, button = nil, black = nil, energyNeed = 0,okepo = nil,okstay = nil, sts = 0}
            local index = #self.allControlUnit
            self.allControlUnit[#self.allControlUnit].skillType = i
            self.allControlUnit[#self.allControlUnit].button = cc.ui.UIPushButton.new({normal = "Battle/battleImg_10.png",pressed = "Battle/battleImg_10.png"})
            :pos(self.skillItemPos[i].itemPosX,self.skillItemPos[i].itemPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].button:setScaleX(self.skillItemPos[i].scaleX)
            self.allControlUnit[#self.allControlUnit].button:setScaleY(self.skillItemPos[i].scaleY)
            if CurFightBattleType == FightBattleType.kType_PVP then
                self.allControlUnit[#self.allControlUnit].button:setTouchEnabled(false)
            end

            self.allControlUnit[#self.allControlUnit].skillImg =  display.newSprite("SkillIcon/skillicon_"..skillData[self.member.m_energySkills[i].id]["resId2"]..".png")
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            skillImgScale = 0.65
            self.allControlUnit[#self.allControlUnit].skillImg:scale(skillImgScale)
            
            self.allControlUnit[#self.allControlUnit].black = display.newSprite("Battle/battleImg_10.png")
            :pos(self.skillItemPos[i].itemPosX,self.skillItemPos[i].itemPosY)
            :addTo(self)
            :opacity(140)
            self.allControlUnit[#self.allControlUnit].black:setColor(cc.c3b(0,0,0))
            self.allControlUnit[#self.allControlUnit].black:setScaleX(self.skillItemPos[i].scaleX)
            self.allControlUnit[#self.allControlUnit].black:setScaleY(self.skillItemPos[i].scaleY)
            self.allControlUnit[#self.allControlUnit].black:setTouchEnabled(true)
            self.allControlUnit[#self.allControlUnit].energyNeed = self.member.m_energySkills[i].energy

            self.allControlUnit[#self.allControlUnit].eLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = tostring(self.member.m_energySkills[i].energy), size = self:getContentSize().height*0.06, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
            :align(display.CENTER, self.skillItemPos[i].ePosX, self.skillItemPos[i].ePosY)
            :addTo(self,1)
            self.allControlUnit[#self.allControlUnit].eLabel:setRotation(rotateNum[i])

            --冷却提示
            self.allControlUnit[#self.allControlUnit].okepo = display.newSprite("#manSkillokepo_00.png")
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].okepo:setScaleX(self.skillItemPos[i].scaleX*1*2)
            self.allControlUnit[#self.allControlUnit].okepo:setScaleY(self.skillItemPos[i].scaleY*1*2)
            self.allControlUnit[#self.allControlUnit].okepo:setBlendFunc(770,1)

            self.allControlUnit[#self.allControlUnit].okstay = display.newSprite("#manSkillokstay_00.png")
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            :scale(skillImgScale)
            self.allControlUnit[#self.allControlUnit].okstay:setScaleX(self.skillItemPos[i].scaleX*1*2)
            self.allControlUnit[#self.allControlUnit].okstay:setScaleY(self.skillItemPos[i].scaleY*1*2)
            self.allControlUnit[#self.allControlUnit].okstay:setBlendFunc(770,1)

            self.allControlUnit[#self.allControlUnit].okepo:setVisible(false)
            self.allControlUnit[#self.allControlUnit].okstay:setVisible(false)
            
            self.allControlUnit[#self.allControlUnit].sts = self.member.m_energySkills[i].sts
            if self.allControlUnit[#self.allControlUnit].sts == -1 then
                self.allControlUnit[#self.allControlUnit].black:setTouchEnabled(false)
                local lockSp = display.newSprite("Battle/battleImg_23.png")
                :pos(50,40)
                :addTo(self.allControlUnit[#self.allControlUnit].black)
                if i == 2 or i == 3 then
                    lockSp:setScaleY(-1)
                end
                self.allControlUnit[#self.allControlUnit].unlock = 0
                self.allControlUnit[#self.allControlUnit].button:onButtonClicked(function()
                    showTips("技能未解锁")
                end)
            else
                self.allControlUnit[#self.allControlUnit].button:onButtonClicked(function()
                    self:goToPlaySkill(self.allControlUnit[index])
                    if GuideManager.NextStep==90000 then
                      resumeTheBattle()
                      print("恢复")
                    end
                end)
            end
        end
      end
      self.curEnergy = 0

      self:setSklOrder()
      
  else
      -- display.newSprite("Battle/battleImg_12.png")
      -- :pos(self.controlSize.width*0.5,self.controlSize.height*0.5)
      -- :addTo(self)
      --主炮冷却条
      self.mainProgress = SpriteProgress.new("Battle/wordMain", _member)
      :pos(self.controlSize.width*0.505,self.controlSize.height*0.895)
      :addTo(self,2)
      self.mainProgress:setIsMainCDGet(true)
      self.mainProgress:startCooling()
      --副炮冷却条
      self.subProgress = SpriteProgress.new("Battle/wordSub", _member.m_attackInfo.attackInterval)
      :pos(self.controlSize.width*0.505,self.controlSize.height*0.315)
      :addTo(self,2)
      
      --能量条
      display.newSprite("Battle/battleImg_5.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.08)
      :addTo(self)
      self.energyProgress = display.newProgressTimer("Battle/battleImg_14.png", display.PROGRESS_TIMER_BAR)
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.08)
      :addTo(self)
      self.energyProgress:setMidpoint(cc.p(0, 0.5))
      self.energyProgress:setBarChangeRate(cc.p(1.0, 0))
      self.energyProgress:setPercentage(0)
      if self.member.m_exclusiveInfo[ExclusiveType.kStartEnergy] ~= nil then
          self.energyProgress:setPercentage(self.member.m_exclusiveInfo[ExclusiveType.kStartEnergy])
          self.curEnergy = self.member.m_exclusiveInfo[ExclusiveType.kStartEnergy]
      else
          self.curEnergy = 0
      end


      self.energyLabel=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = self.curEnergy.."/100", size = self:getContentSize().height*0.06, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
      :align(display.CENTER, self:getContentSize().width*0.5, self:getContentSize().height*0.076)
      :addTo(self)
      self.energyLabel:enableOutline(cc.c4f(0,0,0,255),1)


      --生命条
      display.newSprite("Battle/battleImg_5.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.18)
      :addTo(self)
      self.hpProgress = display.newProgressTimer("Battle/battleImg_15.png", display.PROGRESS_TIMER_BAR)
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.18)
      :addTo(self)
      self.hpProgress:setMidpoint(cc.p(0, 0.5))
      self.hpProgress:setBarChangeRate(cc.p(1.0, 0))
      self.hpProgress:setPercentage(100)

      self.hpLabel=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = tostring(_member.m_attackInfo.curHp).."/"..tostring(_member.m_attackInfo.maxHp), size = self:getContentSize().height*0.06, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
      :align(display.CENTER, self:getContentSize().width*0.5, self:getContentSize().height*0.176)
      :addTo(self)
      self.hpLabel:enableOutline(cc.c4f(0,0,0,255),1.5)

      display.newSprite("Battle/battleImg_20.png")
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.605)
      :addTo(self,1)

      --头像
      self.headSp = display.newSprite(headName)
      :pos(self.controlSize.width*0.5,self.controlSize.height*0.605)
      :addTo(self,1)
      self.headSp:scale(0.55)

      --坦克等级
      if _member.m_attackInfo.carLvl and _member.m_attackInfo.carLvl>0 then
        local num = 36 + math.floor((_member.m_attackInfo.carLvl+1)/2)
        local level = display.newSprite("common2/improve2_img"..num..".png")
        :addTo(self,1)
        :pos(self.controlSize.width*0.5,self.controlSize.height*0.605+30)
        :scale(0.5)

        local carLevelAdd = display.newSprite("common2/improve2_img42.png")
        :addTo(self,1)
        :pos(self.controlSize.width*0.5+13,self.controlSize.height*0.605+35)
        :scale(0.5)
        if math.mod(_member.m_attackInfo.carLvl, 2)==0 then
            carLevelAdd:setVisible(true)
        else
            carLevelAdd:setVisible(false)
        end 
      end
      

      for i=6,7 do
            self.allControlUnit[#self.allControlUnit + 1] = {skillType = 0, button = nil, black = nil, energyNeed = 0}
            local index = #self.allControlUnit
            self.allControlUnit[#self.allControlUnit].skillType = self.skillItemPos[i].sType
            self.allControlUnit[#self.allControlUnit].button = cc.ui.UIPushButton.new({normal = "Battle/battleImg_16.png"})
            :pos(self.skillItemPos[i].itemPosX,self.skillItemPos[i].itemPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].button:setScaleX(self.skillItemPos[i].scaleX)
            self.allControlUnit[#self.allControlUnit].button:setScaleY(self.skillItemPos[i].scaleY)
            if CurFightBattleType == FightBattleType.kType_PVP then
                self.allControlUnit[#self.allControlUnit].button:setTouchEnabled(false)
            end
            self.allControlUnit[#self.allControlUnit].button:setTouchSwallowEnabled(false)

            local skillImgStr = ""
            skillImgStr = "SkillIcon/skilllong_"..skillData[self.member.m_energySkills[i].id]["resId2"]..".png"
            if cc.FileUtils:getInstance():isFileExist(skillImgStr) == false then
                skillImgStr = "SkillIcon/skilllong1103019.png"
            end
            skillImgScale = 0.6666
            
            self.allControlUnit[#self.allControlUnit].skillImg =  display.newSprite(skillImgStr)
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].skillImg:setScaleX(skillImgScale)
            self.allControlUnit[#self.allControlUnit].skillImg:setScaleY(skillImgScale)
            
            self.allControlUnit[#self.allControlUnit].black = display.newSprite("Battle/battleImg_16.png")
            :pos(self.skillItemPos[i].itemPosX,self.skillItemPos[i].itemPosY)
            :addTo(self,1)
            :opacity(140)
            self.allControlUnit[#self.allControlUnit].black:setColor(cc.c3b(0,0,0))
            self.allControlUnit[#self.allControlUnit].black:setScaleX(self.skillItemPos[i].scaleX)
            self.allControlUnit[#self.allControlUnit].black:setScaleY(self.skillItemPos[i].scaleY*1.03)
            self.allControlUnit[#self.allControlUnit].black:setTouchEnabled(true)
            self.allControlUnit[#self.allControlUnit].energyNeed = self.member.m_energySkills[i].energy
            
            -- display.newSprite("Battle/battleImg_18.png")
            -- :pos(self.skillItemPos[i].ePosX, self.skillItemPos[i].ePosY)
            -- :addTo(self,2)
            self.allControlUnit[#self.allControlUnit].eLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = tostring(self.member.m_energySkills[i].energy), size = self:getContentSize().height*0.07, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
            :align(display.CENTER, self.skillItemPos[i].ePosX, self.skillItemPos[i].ePosY)
            :addTo(self,2)
            
            --冷却提示
            self.allControlUnit[#self.allControlUnit].okepo = display.newSprite("#carSkillokepo_00.png")
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].okepo:setScaleX(self.skillItemPos[i].scaleX*-1*2)
            self.allControlUnit[#self.allControlUnit].okepo:setScaleY(self.skillItemPos[i].scaleY*2)
            self.allControlUnit[#self.allControlUnit].okepo:setBlendFunc(770,1)

            self.allControlUnit[#self.allControlUnit].okstay = display.newSprite("#carSkillokstay_00.png")
            :pos(self.skillItemPos[i].imgPosX,self.skillItemPos[i].imgPosY)
            :addTo(self)
            self.allControlUnit[#self.allControlUnit].okstay:setScaleX(self.skillItemPos[i].scaleX*-1*2)
            self.allControlUnit[#self.allControlUnit].okstay:setScaleY(self.skillItemPos[i].scaleY*2)
            self.allControlUnit[#self.allControlUnit].okstay:setBlendFunc(770,1)

            self.allControlUnit[#self.allControlUnit].okepo:setVisible(false)
            self.allControlUnit[#self.allControlUnit].okstay:setVisible(false)
          
            if self.member.m_energySkills[i].sts == -1 then
               self.allControlUnit[#self.allControlUnit].sts = -1
               self.allControlUnit[#self.allControlUnit].black:setTouchEnabled(false)
               self.allControlUnit[#self.allControlUnit].button:onButtonClicked(function()
                    showTips("未激活")
               end)
            elseif self.member.m_energySkills[i].sts == 0 then
               self.allControlUnit[#self.allControlUnit].sts = 0
               self.allControlUnit[#self.allControlUnit].black:setTouchEnabled(false)
               self.allControlUnit[#self.allControlUnit].button:onButtonClicked(function()
                    showTips("未激活")
               end)
            else
               self.allControlUnit[#self.allControlUnit].sts = 1
               self.allControlUnit[#self.allControlUnit].button:onButtonClicked(function()
                    self:goToPlaySkill(self.allControlUnit[index])
                    if GuideManager.NextStep==90001 then
                      resumeTheBattle()
                      print("恢复")
                      GuideManager.NextStep = 90103
                    end
               end)
            end
        end
      self:setSklOrder()
  end
  self:scheduleRepeat(self.updateEnergy,1/self.member.m_energyRecovery)
end

function ControlDesk:onEnter()
  self:pauseDesk()
end

function ControlDesk:setEnergyProgress(_per)
   if self.energyProgress == nil then
      return
   end
   self.energyProgress:setPercentage(_per)
   self.energyLabel:setString(tostring(self.energyProgress:getPercentage()).."/100")
   self.curEnergy = _per
end

function ControlDesk:getEnergyProgress()
    return self.energyProgress:getPercentage()
end

function ControlDesk:refreshHpProgress()
   self.hpLabel:setString(tostring(self.member.m_attackInfo.curHp).."/"..tostring(self.member.m_attackInfo.maxHp))
   self.hpProgress:setPercentage(self.member.m_attackInfo.curHp/self.member.m_attackInfo.maxHp*100)
end

function ControlDesk:updateEnergy()
    self.curEnergy = self.energyProgress:getPercentage() + 1

    --if self.member.fightPos == 1 then
    --   print("attack jiuhu aotoAllEnergy="..self.curEnergy.."------------------state="..self.member.m_fsm:getState())
    --end

    if self.curEnergy > 100 then
        self.curEnergy = 100
    end
    if self.isPausingItem == true then
        return
    end
    self:resetAllControlUnit()
end

function ControlDesk:resetAllControlUnit()
    self.energyProgress:setPercentage(self.curEnergy)
    self.energyLabel:setString(tostring(self.curEnergy).."/100")
    for i=1,#self.allControlUnit do
      if self.allControlUnit[i].sts == 1 and self.curEnergy >= self.allControlUnit[i].energyNeed and self.member.m_fsm:getState() ~= "skill" and self.member.m_fsm:getState() ~= "stun" and self.member.m_fsm:getState() ~= "win" and self.member.m_fsm:getState() ~= "ready" and self.member.m_gagNum <= 0 then
          self.allControlUnit[i].black:setVisible(false)
          curGuideBtn = self.allControlUnit[i].black
          if not getIsGuideClosed() and GuideManager.NextStep == 90102 and self.member.m_attackInfo.tptId == 1051 then
              GuideManager:_addGuide_2(90102, startFightBattleScene.Instance.guideBg,handler(self,self.caculateGuidePos))
              pauseTheBattle()
              self:resume()
              print("暂停，90102")
          end
          if not getIsGuideClosed() and GuideManager.NextStep == 90101 then
              GuideManager:_addGuide_2(90101, startFightBattleScene.Instance.guideBg,handler(self,self.caculateGuidePos))
              pauseTheBattle()
              self:resume()
              print("暂停，90101")
          end
          if self.allControlUnit[i].okstay:isVisible() == false then
              self.allControlUnit[i].okepo:setVisible(true)
              self.allControlUnit[i].okstay:setVisible(true)

            local formatStr,num,skillImgScale
            if self.member.m_memberType == MemberAllType.kMemberHero then
              formatStr = "manSkillokepo_%02d.png"
              skillImgScale = 0.65
              num = 17
            else
              formatStr = "carSkillokepo_%02d.png"
              skillImgScale = 0.66666
              num = 18
            end

            local framesepo = display.newFrames(formatStr, 0, num)
            local animationepo = display.newAnimation(framesepo, 0.5/num)
            local okepoAction = transition.sequence({
               cc.Animate:create(animationepo),
               cc.CallFunc:create(function()
                 self.allControlUnit[i].okepo:setVisible(false)
               end)
            })

            if self.member.m_memberType == MemberAllType.kMemberHero then
              formatStr = "manSkillokstay_%02d.png"
              num = 15
            else
              formatStr = "carSkillokstay_%02d.png"
              num = 15
            end

            local framesstay = display.newFrames(formatStr, 0, num)
            local animationstay = display.newAnimation(framesstay, 1/num)
            local okstayAction = cc.RepeatForever:create(cc.Animate:create(animationstay))
            self.allControlUnit[i].okepo:runAction(okepoAction)
            self.allControlUnit[i].okstay:runAction(okstayAction)
          end
      else
        
        if not(self.member.m_fsm:getState()=="skill" and self.member.curSkillType == MemberSkillType.kSkillTankMain) then
          self.allControlUnit[i].black:setVisible(true)
          self.allControlUnit[i].okstay:stopAllActions()
          self.allControlUnit[i].okstay:setVisible(false)
        end
      end
    end
    if IsAutoFight == true and self.member.m_fsm:getState() ~= "skill" and self.member.m_fsm:getState() ~= "stun" and self.member.m_fsm:getState() ~= "win" and self.member.m_fsm:getState() ~= "ready" and self.member.m_gagNum <= 0  then
      for i=1,#self.allControlUnit do
        if self.curAutoIndex == i and self.allControlUnit[i].sts == 1 and self.curEnergy >= self.allControlUnit[i].energyNeed then
            if self.allControlUnit[i].seIndex ~= nil then
               if self.allControlUnit[i].seIndex == 1 then
                    --print("------------goToPlaySkill5555")
                   self:goToPlaySkill(self.allControlUnit[i])
               else
                   self.curAutoIndex = 1
                   break
               end
            else
               --print("------------goToPlaySkill66666")
               self:goToPlaySkill(self.allControlUnit[i])
            end
            for j=self.curAutoIndex,#self.allControlUnit do
               if j == #self.allControlUnit then
                  self.curAutoIndex = 1
                  break
               end
               if self.allControlUnit[j + 1].sts == 1 then
                  self.curAutoIndex = j + 1
                  break
               end
            end
            return
        end
      end 
    end

    if self.mainProgress ~= nil and self.mainProgress:getPercent() <= 0 and self.member.m_fsm:getState() ~= "skill" 
      and self.member.m_fsm:getState() ~= "stun" and self.member.m_fsm:getState() ~= "win" 
      and self.member.m_fsm:getState() ~= "ready" then
      self.member:playSkill(MemberSkillType.kSkillTankMain)
      self.mainProgress:startCooling()
    end
end

function ControlDesk:deductEnergy()
    self.curEnergy = self.energyProgress:getPercentage() - self.energyDeduct
    self:resetAllControlUnit()
end
 
function ControlDesk:goToPlaySkill(_unit)
    GuideManager:removeGuideLayer()
    if self.member.m_fsm:getState() ~= "win" and self.member.m_isDead ~= true then
        self.energyDeduct = _unit.energyNeed
        print("-------jiuhu goToPlaySkill skillType=".._unit.skillType)
        self.member:playSkill(_unit.skillType)
        self:deductEnergy()
    end
end

function ControlDesk:beHit(_percent)
    self.hpLabel:setString(tostring(self.member.m_attackInfo.curHp).."/"..tostring(self.member.m_attackInfo.maxHp))
    self.hpProgress:setPercentage(_percent)
end

--战斗中转换成自动战斗状态
--检查是否有可施放的技能
function ControlDesk:changeToAuto()
    self.curAutoIndex = 1
end

function ControlDesk:pauseDesk()
  self:pause()
	for i=1,#self.allControlUnit do
      self.allControlUnit[i].black:setVisible(true)
      self.allControlUnit[i].okstay:stopAllActions()
      self.allControlUnit[i].okstay:setVisible(false)
  end
  if self.mainProgress then
      self.mainProgress:pauseCooling()
  end
end

function ControlDesk:pauseSkillItems()
  for i=1,#self.allControlUnit do
      self.allControlUnit[i].black:setVisible(true)
      self.allControlUnit[i].okstay:stopAllActions()
      self.allControlUnit[i].okstay:setVisible(false)
  end
  self.isPausingItem = true
end

function ControlDesk:resumeDesk()
  if self.energyProgress == nil then
      return
  end
  self:resume()
  if self.mainProgress then
      self.mainProgress:resumeCooling()
  end
  self.isPausingItem = false
	self:resetAllControlUnit()
end

function ControlDesk:cleanDesk()
	self:stopAllActions()
  self.energyProgress:removeSelf()
  self.energyProgress = nil
  self.energyLabel:removeSelf()
  self.hpProgress:removeSelf()
  self.hpLabel:removeSelf()
  for i=1,#self.allControlUnit do
      if self.allControlUnit[i] then
        if self.allControlUnit[i].button then self.allControlUnit[i].button:setTouchEnabled(false) self.allControlUnit[i].button =nil end
        if self.allControlUnit[i].skillImg then self.allControlUnit[i].skillImg:removeSelf() self.allControlUnit[i].skillImg = nil end
        if self.allControlUnit[i].black then self.allControlUnit[i].black:removeSelf() self.allControlUnit[i].black = nil end
        if self.allControlUnit[i].eLabel then self.allControlUnit[i].eLabel:removeSelf() self.allControlUnit[i].eLabel = nil end
        if self.allControlUnit[i].okepo then self.allControlUnit[i].okepo:removeSelf() self.allControlUnit[i].okepo = nil end
        if self.allControlUnit[i].okstay then self.allControlUnit[i].okstay:removeSelf() self.allControlUnit[i].okstay = nil end
      end
  end
  if self.mainProgress then
      self.mainProgress:removeSelf()
      self.mainProgress = nil
  end
  --阵亡
  display.newSprite("Battle/battleImg_19.png")
  :pos(self.controlSize.width*0.5,self.controlSize.height*0.6)
  :addTo(self,3)
end

function ControlDesk:scheduleRepeat(callback, interval)
    local seq = transition.sequence({
      cc.DelayTime:create(interval),
      cc.CallFunc:create(callback),
    })
    self:runAction(cc.RepeatForever:create(seq))
end

function ControlDesk:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 90101==_guideId or 90102==_guideId then
        g_node = curGuideBtn
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

function ControlDesk:setSklOrder()
  if CurFightBattleType ~= FightBattleType.kType_PVP then
    return
  end
  local _sortList = {}
  if self.member.sklOrder==nil or self.member.sklOrder=="" then
    if self.member.m_memberType == MemberAllType.kMemberHero then
      _sortList = {1,2,3,4}
    else
      _sortList = {1,2,1,2}
    end
  else
    local sklOrderArr = string.split(self.member.sklOrder, "|")
    for i=1,#sklOrderArr do
      _sortList[i] = tonumber(sklOrderArr[i])
    end
  end
  print("_sortList")
  printTable(_sortList)
  local tmpTab = self.allControlUnit
  self.allControlUnit = nil
  self.allControlUnit = {}
  -- printTable(tmpTab)
  for k,v in ipairs(_sortList) do
    -- print("self.member.m_memberType"..self.member.m_memberType)
    -- if self.member.m_memberType ~= MemberAllType.kMemberHero and k>2 then
    --   return
    -- end
    -- print("bbb")
    self.allControlUnit[k] = tmpTab[v]
  end

  -- print("++++++++++++++")
  -- printTable(self.allControlUnit)
  -- print("---------")
end

return ControlDesk