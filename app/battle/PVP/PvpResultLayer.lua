--
-- Author: liufei
-- Date: 2015-01-09 15:11:26
--
local PvpResultLayer = class("PvpResultLayer", function()
	 return display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,180))
end)

function PvpResultLayer:ctor()
  local colorBg = display.newSprite("common/colorbg.png")
  :addTo(self,-1)
  colorBg:setAnchorPoint(0,0)
  colorBg:setScaleX(display.width/colorBg:getContentSize().width)
  colorBg:setScaleY(display.height/colorBg:getContentSize().height)  
	--结算标题
    local titleName = nil
    local headNameEnd = ""
	if PVPResult == false then
	    if IsOverTime == true then
         titleName = "Battle/Settlement/zioop_cre-03-01.png"
      else
         titleName = "Battle/Settlement/jiesuan_12.png"
      end
      headNameEnd = "lose.png"
	else
      titleName = "Battle/Settlement/jiesuan_11.png"
      headNameEnd = "win.png"
	end
    local title = display.newSprite(titleName)
    :addTo(self)
    --星星底框
    local starBg = display.newSprite("Battle/Settlement/jiesuan_10.png")
    :addTo(self)

    --头像底框
    local headBg = display.newSprite("Battle/Settlement/jiesuan_09.png")
    :pos(display.width*0.5, display.height*0.5)
    :addTo(self,2)
    starBg:setPosition(display.width*0.5, headBg:getPositionY()+headBg:getContentSize().height/2 + starBg:getContentSize().height*0.4)
    title:setPosition(display.width*0.5, headBg:getPositionY()+headBg:getContentSize().height/2+starBg:getContentSize().height+title:getContentSize().height*0.16)

    --头像底框
    local heroNum = 0
    for i=1,5 do
        if MemberAttackList[i] ~= nil and MemberAttackList[i].m_attackInfo.heroTptId ~= nil then
            heroNum = heroNum + 1
        end
    end
    local headBg = {}
    for i=1,heroNum do
        headBg[i] = display.newSprite("Battle/Settlement/jiesuan_09.png")
        :addTo(self,2)
        if heroNum == 1 then
           headBg[i]:setPosition(display.width*0.5, display.height*0.5)
        elseif heroNum == 2 then
           headBg[i]:setPosition(display.width*(0.29 + i*0.14), display.height*0.5)
        elseif heroNum == 3 then
           headBg[i]:setPosition(display.width*(0.22 + i*0.14), display.height*0.5)
        end
    end
    local heroIndex = 1
    for i=1,5 do
        if MemberAttackList[i] ~= nil and MemberAttackList[i].m_attackInfo.heroTptId ~= nil then
            local  tmpMakeType = memberData[MemberAttackList[i].m_attackInfo.heroTptId]["actType"]
            local heroModel = GlobalCreateModel(ModelType.Hero, MemberAttackList[i].m_attackInfo.heroTptId, 1, tmpMakeType)
            :pos(headBg[heroIndex]:getContentSize().width*0.5,0)
            :addTo(headBg[heroIndex])
            heroIndex = heroIndex + 1
            if tmpMakeType == ModelMakeType.kMake_Coco then
                heroModel:getAnimation():play("Standby")
            else
                if PVPResult == true then
                    heroModel:setAnimation(0, "victory", true)
                else
                    heroModel:setAnimation(0, "Standby", true)
                end
            end
        end
    end
    if heroNum == 0 then
        headBg[1] = display.newSprite("Battle/Settlement/jiesuan_09.png")
        :pos(display.width*0.5, display.height*0.5)
        :addTo(self,2)
    end

    --按钮
    local backItem = cc.ui.UIPushButton.new({normal = "Battle/Settlement/jiesuan_07.png",pressed = "Battle/Settlement/jiesuan_14.png"})
    :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*2)
    :addTo(self)
    :onButtonClicked(function()
        if CurFightBattleType == FightBattleType.kType_PVP then
           -- comData={}
           -- comData["characterId"] = srv_userInfo.characterId
           -- m_socket:SendRequest(json.encode(comData), CMD_GETPVPINFO, self, self.OnGetPVPInfoRet)
           --停止PVP冷却计时
            if display.getRunningScene().pvpLastTimeHandle ~= nil then
                scheduler.unscheduleGlobal(display.getRunningScene().pvpLastTimeHandle)
            end
            app:enterScene("LoadingScene", {SceneType.Type_Main})
        elseif CurFightBattleType == FightBattleType.kType_Expedition then
           app:enterScene("LoadingScene", {SceneType.Type_Main})
        end
    end)
    display.newSprite("Battle/Settlement/jiesuan_13.png")
    :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*1.2)
    :addTo(self)
    if PVPResult == false then
        display.newSprite("Battle/Settlement/jiesuan_13.png")
        :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*2.4)
        :addTo(self)
        local helpImgNames = {[1] = "Battle/Settlement/zdjs_sprs-07.png",[2] = "Battle/Settlement/zdjs_sprs-06.png",[3] = "Battle/Settlement/zdjs_sprs-05.png"}
        local helpWordNames = {[1] = "Battle/Settlement/zdjs_sprs-04.png",[2] = "Battle/Settlement/zdjs_sprs-08.png",[3] = "Battle/Settlement/zdjs_sprs-03.png"}
        local helpSize = display.newSprite("Battle/Settlement/zdjs_sprs-02.png"):getContentSize()
        for i=1,3 do
           local tmpHelpItem = cc.ui.UIPushButton.new({normal = "Battle/Settlement/zdjs_sprs-02.png",pressed = "Battle/Settlement/zdjs_sprs-01.png"})
           :pos(display.width*(0.33+(i-1)*0.17), headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*1.8)
           :addTo(self)
           :onButtonClicked(function()
              print("help click")
           end)
           display.newSprite(helpImgNames[i])
           :align(display.CENTER,-helpSize.width*0.23, 0)
           :addTo(tmpHelpItem)
           display.newSprite(helpWordNames[i])
           :align(display.CENTER, helpSize.width*0.23, 0)
           :addTo(tmpHelpItem)
        end   
        backItem:setPosition(display.width*0.85, headBg[1]:getPositionY()) 
    else
        for i=1,3 do
          local star = display.newSprite("Battle/Settlement/jiesuan_03.png")
          :pos(display.width*0.44+display.width*0.061*(i-1),starBg:getPositionY()+starBg:getContentSize().height*0.04)
          :addTo(self)
        end
    end
end

-- function PvpResultLayer:OnGetPVPInfoRet(result)
--     if tonumber(result["result"]) == 1 then
--         PVPData = result["data"]
--         app:enterScene("PVPScene")
--     else
--         -- addMessageBox(self, 80)
--         showMessageBox(result["msg"])
--     end
-- end

return PvpResultLayer 