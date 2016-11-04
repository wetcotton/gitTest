--
-- Author: liufei
-- Date: 2014-12-31 11:38:42
--
local PvpOpponent = class("PvpOpponent", function()
	return  display.newNode()
end)

function  PvpOpponent:ctor(_index)
    self.enermyData = PVPData["enemys"][_index]
    local bgSize = display.newSprite("#ajjc_d02-02.png"):getContentSize()
    self:setContentSize(bgSize)
    self.bg = display.newSprite("#ajjc_d02-02.png")
    :pos(bgSize.width/2, bgSize.height/2)
    :addTo(self)

    --头像
    local  bodyName = "Head/chead_"..string.sub(self.enermyData["tptId"],1,4)..".png"
    cc.ui.UIPushButton.new({normal = bodyName})
    :pos(bgSize.width*0.5,bgSize.height*0.67)
    :onButtonClicked(function(event)
         local sendData={}
         sendData["eId"] = self.enermyData["id"]
         startLoading()
         m_socket:SendRequest(json.encode(sendData), CMD_PVP_GETENERMYINFO, self, self.OnGetPVPEnermyInfo)
    end)
    :addTo(self.bg)
    :scale(0.77)
	--昵称
    cc.ui.UILabel.new({UILabelType = 2, text = self.enermyData["name"], size = display.height*0.028, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(13, 19, 83)})
    :align(display.CENTER, bgSize.width*0.5,bgSize.height*0.88+12)
    :addTo(self.bg)
	--排名
    -- cc.ui.UILabel.new({UILabelType = 2, text = "排名:", size = display.height*0.028, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(46, 167, 224)})
    -- :align(display.CENTER_LEFT,  bgSize.width*0.7,bgSize.height*0.38)
    -- :addTo(self.bg)
	display.newBMFontLabel({text = self.enermyData["order"], font = "fonts/num_1.fnt"})
    :align(display.CENTER_LEFT, bgSize.width*0.33,bgSize.height*0.4)
    :addTo(self.bg)
    --战斗力
    -- display.newSprite("common2/com_strengthTag.png")
    -- :align(display.CENTER_LEFT, bgSize.width*0.05,bgSize.height*0.375)
    -- :addTo(self.bg)
    display.newBMFontLabel({text = tostring(math.floor(tonumber(self.enermyData["strength"]))), font = "fonts/num_2.fnt"})
    :align(display.CENTER_LEFT, bgSize.width*0.33,bgSize.height*0.32)
    :addTo(self.bg)

    --挑战按钮
    local fightButton = cc.ui.UIPushButton.new({normal = "#jjcfightN.png",pressed = "#jjcfightS.png"})
    :pos(bgSize.width*0.5,bgSize.height*0.145)
    :addTo(self.bg)
    fightButton:scale(0.77)
    self.fightButtonImg = display.newSprite("#jjcsu_d02-03.png")
    :pos(bgSize.width*0.5,bgSize.height*0.145)
    :addTo(self.bg)
	fightButton:onButtonClicked(function(event)
        if PVPData["leftCnt"] <= 0 then
            showTips("挑战次数不足！")
            return
        end
        if PVPData.lastTs>=1000 then
            showTips("挑战时间未到！")
            return
        end
        EnermyID = tonumber(self.enermyData["id"])
        local layer = EmbattleScene.new({BattleType_PVP, tonumber(self.enermyData["id"])})
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
        GuideManager:removeGuideLayer()
    end)
end

function PvpOpponent:OnGetPVPEnermyInfo(cmd)
    if cmd.result == 1 then
       self.enermyData["matrixinfo"] = cmd["data"]["matrixinfo"]
       self:showEnermy()
    else
       showTips(cmd.msg)
    end
end

function PvpOpponent:showEnermy()
    local oneEnermyLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,210))
    :align(display.CENTER,display.cx,display.cy)
    :addTo(display.getRunningScene(),60)
    oneEnermyLayer:setTouchEnabled(true)
    oneEnermyLayer:setTouchSwallowEnabled(true)
    oneEnermyLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        oneEnermyLayer:removeSelf()
    end)
    -- local oneEnermyBg = display.newSprite("#xiaok_butt-01.png")
    local oneEnermyBg = display.newScale9Sprite("common/tanchu-03.png",nil,nil,
            cc.size(600,300),cc.rect(10,10,30,30))
    :pos(display.width/2,display.height/2)
    :addTo(oneEnermyLayer)
    oneEnermyBg:setTouchEnabled(true)
    local bgSize = oneEnermyBg:getContentSize()
    cc.ui.UILabel.new({UILabelType = 2, text = self.enermyData["name"], size = bgSize.height*0.09, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(255, 196, 117)})
    :align(display.CENTER, bgSize.width*0.5,bgSize.height*0.89)
    :addTo(oneEnermyBg)
    cc.ui.UILabel.new({UILabelType = 2, text = tostring(self.enermyData["level"]), size = bgSize.height*0.08, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255, 235, 8)})
    :align(display.CENTER_LEFT, bgSize.width*0.25,bgSize.height*0.71)
    :addTo(oneEnermyBg)
    cc.ui.UILabel.new({UILabelType = 2, text = tostring(math.floor(tonumber(self.enermyData["strength"]))), size = bgSize.height*0.08, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255, 235, 8)})
    :align(display.CENTER_LEFT, bgSize.width*0.73,bgSize.height*0.71)
    :addTo(oneEnermyBg)
    cc.ui.UILabel.new({UILabelType = 2, text = self.enermyData["armyName"], size = bgSize.height*0.08, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255, 235, 8)})
    :align(display.CENTER_LEFT, bgSize.width*0.25,bgSize.height*0.52)
    :addTo(oneEnermyBg)
    
    local headIds = {
                      [1] = nil,
                      [2] = nil,
                      [3] = nil,
                      [4] = nil,
                      [5] = nil,
                    }

    local _dataInfo = self.enermyData["matrixinfo"]
    for i=1,5 do
        if i <= 5 and tonumber(_dataInfo["matrix"]["main"..tostring(i)]) ~= -1 then
            for j=1,#_dataInfo["members"] do
                if tonumber(_dataInfo["matrix"]["main"..tostring(i)]) == tonumber(_dataInfo["members"][j]["id"]) then
                    if tonumber(_dataInfo["members"][j]["mtype"])==1 then
                        headIds[i] = {[1] = "car",[2] = _dataInfo["members"][j]["carTptId"]}--人和车
                        break
                    elseif tonumber(_dataInfo["members"][j]["mtype"])==2 then
                        headIds[i] = {[1] = "men",[2] = _dataInfo["members"][j]["tptId"]}--单人
                        break
                    end
                elseif tonumber(_dataInfo["matrix"]["main"..tostring(i)]) == -tonumber(_dataInfo["members"][j]["id"]) then
                    if tonumber(_dataInfo["members"][j]["mtype"])==3 then
                        headIds[i] = {[1] = "car",[2] = _dataInfo["members"][j]["tptId"]}    --单车
                        break
                    end
                end
            end
        end
    end
    for i=1,5 do
        local mBg = display.newSprite("#jjc_d02-02.png")
        :pos((bgSize.width/6)*i,bgSize.height*0.25)
        :scale(0.7)
        :addTo(oneEnermyBg)
        local headName = ""
        if headIds[i] ~= nil then
            local scaleN = 1
            if headIds[i][1] == "car" then
                headName = string.format("Head/head_%d.png", tonumber(carData[headIds[i][2]]["resId"]))
                scaleN = 0.55

                --等级
                local _carlevel = _dataInfo["members"][i]["carLvl"]
                local num = 36 + math.floor((_carlevel+1)/2)
                local level = display.newSprite("common2/improve2_img"..num..".png")
                :addTo(mBg)
                :align(display.CENTER_LEFT, 10,mBg:getContentSize().height-22)
                :scale(0.6)
                local carLevelAdd = display.newSprite("common2/improve2_img42.png")
                :addTo(mBg)
                :align(display.CENTER_LEFT, 28,mBg:getContentSize().height-17)
                :scale(0.6)
                if math.mod(_carlevel, 2)==0 then
                    carLevelAdd:setVisible(true)
                else
                    carLevelAdd:setVisible(false)
                end 

            elseif headIds[i][1] == "men" then
                headName = string.format("Head/headman_%d.png", tonumber(string.sub(tostring(headIds[i][2]),1,4)))
                scaleN = 0.6
            end
            display.newSprite(headName)
            :pos((bgSize.width/6)*i,bgSize.height*0.25)
            :scale(scaleN)
            :addTo(oneEnermyBg)
            -- if headIds[i][3] == 0 then
            if headIds[i][3] ~= nil and headIds[i][3] == 1 then
                display.newSprite("common2/com2_tag_02.png")
                :pos(28,100)
                :addTo(mBg)
            end
        end
    end
end
return PvpOpponent