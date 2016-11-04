--
-- Author: liufei
-- Date: 2014-12-29 14:40:34
--

local PvpOpponent = require("app.battle.PVP.PvpOpponent")
local PvpRuleLayer = require("app.battle.PVP.PvpRuleLayer")

local  ResourceAddType = {}
ResourceAddType.AddType_Gold = 1
ResourceAddType.AddType_Diamond= 2
ResourceAddType.AddType_Energy = 3

local buyTimeCosts = {
       [1] = {one = 15, five = 50},
       [2] = {one = 15, five = 50},
       [3] = {one = 30, five = 100},   
       [4] = {one = 30, five = 100},
       [5] = {one = 60, five = 200},
       [6] = {one = 60, five = 200},
       [7] = {one = 60, five = 200},
       [8] = {one = 120, five = 400},
       [9] = {one = 120, five = 400},
       [10] = {one = 120, five = 400},
       [11] = {one = 240, five = 800},
       [12] = {one = 240, five = 800},
       [13] = {one = 240, five = 800},
}

local PVPScene = class("PVPScene", function()
	return display.newLayer()
end)

PVP_Instance = nil

function PVPScene:ctor()
    PVP_Instance = self
    GuideManager:removeGuideLayer()
    GuideManager:forceSendFinishStep(127)
    display.addSpriteFrames("Image/UIPVPScene.plist", "Image/UIPVPScene.png")

    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,150))
    :addTo(self)
    self.backItem = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png",pressed="common/common_BackBtn_2.png"})
	:align(display.LEFT_TOP, 0, display.height)
	:addTo(self)
	:onButtonClicked(function(event)
        self:removeSelf()
	end)


    --底部四按钮
    for i=1,4 do
        
        local buttonName = ""
        if i == 1 then
          buttonName = "#jjc_d02-14.png"
        elseif i == 2  then
          buttonName = "#jjc_d02-13.png"    
        elseif i == 3  then
          buttonName = "#jjc_d02-12.png" 
        elseif i == 4  then
          buttonName = "#jjc_d02-11.png" 
        end
        local myButton = cc.ui.UIPushButton.new({normal = buttonName})
        :pos(display.width*0.55+ display.width*0.105*(i-1), display.height*1.2)
        :onButtonPressed(function(event)
            event.target:setScale(0.95)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function()
           if i == 1 then --规则说明
               PvpRuleLayer.new()
               :pos(0, 0)
               :addTo(self)
           elseif i == 2  then --排行榜
               local layer = rankLayer.new()
               :addTo(self)
           elseif i == 3  then --对战记录
               comData={}
               m_socket:SendRequest(json.encode(comData), CMD_PVP_GETFIGHTRECORD, self, self.onGetFightRecord)
           elseif i == 4  then --兑换奖励
               local shop = shopLayer.new(2)
                :addTo(self,50)
           end
        end)
        :addTo(self)

        local function showMyButton()
            myButton:setVisible(true)
        end
       
        myButton:runAction(transition.sequence({
                                                  cc.DelayTime:create(0.2+0.05*i),
                                                  cc.CallFunc:create(showMyButton),
                                                  cc.MoveBy:create(0.2,cc.p(0,-display.height*0.4+13)),
                                              }))
    end
    self.enermys = {}
    --上底
    self.myTeamDi = display.newSprite("#jjc_d02-08.png")
    :addTo(self)
    self.myTeamDi:setPosition(self.myTeamDi:getContentSize().width*0.36 - display.width/2, display.height*0.13)
	self:initMyTeam()
    --下底
    self.enermyDi = display.newSprite("#jjc_d02-08.png")
    :addTo(self)
    self.enermyDi:setScaleX(-1)
    self.enermyDi:setPosition(display.width - self.enermyDi:getContentSize().width*0.29 + display.width/2, display.height*0.49)
    self:initEnermyTeam()
    self.myTeamDi:runAction(cc.MoveBy:create(0.2,cc.p(display.width*0.5,0)))
    self.teamBg:runAction(transition.sequence({
                                                cc.MoveBy:create(0.4,cc.p(display.width*0.5,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(-self.myTeamDi:getContentSize().width*0.2,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(self.myTeamDi:getContentSize().width*0.15,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(-self.myTeamDi:getContentSize().width*0.5,0)),
                                              }))
    self.enermyDi:runAction(cc.MoveBy:create(0.2,cc.p(-display.width*0.5,0)))
    self.enermyBg:runAction(transition.sequence({
                                                cc.MoveBy:create(0.2,cc.p(-display.width*0.5,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(self.enermyDi:getContentSize().width*0.2,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(-self.enermyDi:getContentSize().width*0.15,0)),
                                                -- cc.MoveBy:create(0.1,cc.p(self.enermyDi:getContentSize().width*0.5,0)),
                                              }))

    --GuideManager:_addGuide_2(12603,self,handler(self,self.caculateGuidePos))
    MainSceneEnterType = EnterTypeList.PVP_ENTER

end

function PVPScene:refreshMyTeam()
    if self.strengthLabel then
        self.strengthLabel:setString(PVPData["strength"])
    end
    self.myTeamNode:removeAllChildren()
    local bgSize = self.teamBg:getContentSize()
    local headIds = {
                      [1] = nil,
                      [2] = nil,
                      [3] = nil,
                      [4] = nil,
                      [5] = nil,
                    }
    for i=1,5 do
        if i <= 5 and tonumber(PVPData["defmatrix"]["main"..tostring(i)]) ~= -1 then
            for j=1,#PVPData["defmembers"] do
                if tonumber(PVPData["defmatrix"]["main"..tostring(i)]) == tonumber(PVPData["defmembers"][j]["id"]) then
                    if tonumber(PVPData["defmembers"][j]["mtype"])==1 then
                        headIds[i] = {[1] = "car",[2] = PVPData["defmembers"][j]["carTptId"]}--人和车
                        break
                    elseif tonumber(PVPData["defmembers"][j]["mtype"])==2 then
                        headIds[i] = {[1] = "men",[2] = PVPData["defmembers"][j]["tptId"]}--单人
                        break
                    end
                elseif tonumber(PVPData["defmatrix"]["main"..tostring(i)]) == -tonumber(PVPData["defmembers"][j]["id"]) then
                    if tonumber(PVPData["defmembers"][j]["mtype"])==3 then
                        headIds[i] = {[1] = "car",[2] = PVPData["defmembers"][j]["tptId"]}    --单车
                        break
                    end
                end
            end
        end
    end
    
    local manager = ccs.ArmatureDataManager:getInstance()
    for i=1,5 do
        local headName = ""
        if headIds[i] ~= nil then
            local scaleNum = 1
            if headIds[i][1] == "car" then
                -- print("i:"..i,"carId:"..headIds[i][2])
                headName = string.format("Head/head_%d.png", tonumber(carData[headIds[i][2]]["resId"]))
                scaleNum = 1
                if tonumber(string.sub(tostring(headIds[i][2]),1,3)) == 102 then
                    scaleNum = 0.85
                end
                local headSp = display.newSprite(headName)
                :align(display.CENTER_BOTTOM, bgSize.width*(0.04+0.17*i), bgSize.height*0.13)
                :addTo(self.myTeamNode)
                headSp:scale(scaleNum)

            elseif headIds[i][1] == "men" then
                -- print("headIds[i][2]:",headIds[i][2])
                local headSp = ShowModel.new({modelType=ModelType.Hero, templateID=headIds[i][2]})
                :align(display.CENTER_BOTTOM, bgSize.width*(0.04+0.17*i), bgSize.height*0.12)
                :addTo(self.myTeamNode)
                headSp:setScaleX(-memberData[tonumber(headIds[i][2])]["scale"]*0.32)
                headSp:setScaleY(memberData[tonumber(headIds[i][2])]["scale"]*0.32)
            end
        end
    end
end

function PVPScene:initMyTeam()
    self.teamBg = display.newSprite("#jingjc_spix-05-01.png")
    :addTo(self)
    local bgSize = self.teamBg:getContentSize()
    self.teamBg:setPosition(bgSize.width/2+self.myTeamDi:getContentSize().width*0.8 - display.width*0.5, display.height*0.13)

    local tmpBt = cc.ui.UIPushButton.new{normal = "common2/com2_Btn_7_up.png", pressed = "common2/com2_Btn_7_down.png"}
        :addTo(self.teamBg)
        -- :setButtonLabel(display.newTTFLabel{text = "防守\n阵型",color = cc.c3b(255,255,0),size = 25})
        :scale(0.7)
        :align(display.LEFT_CENTER,bgSize.width+5,bgSize.height/2)
        :onButtonClicked(function ( ... )
            local layer = EmbattleScene.new({BattleType_PVP_DEF})
                    :addTo(cc.Director:getInstance():getRunningScene(),51)
        end)
        tmpBt:setScaleY(1.4)
    local label = display.newTTFLabel{text = "防守\n阵型",color = cc.c3b(255,255,0),size = 25}
    :addTo(self.teamBg)
    :align(display.CENTER, tmpBt:getPositionX()+65, tmpBt:getPositionY())
    
    local myTeamIcon = display.newSprite("#xiaok_but-02-04.png")
    :addTo(self.teamBg)
    :pos(65, 70)
    --我方阵容
    cc.ui.UILabel.new({UILabelType = 2, text = "我方\n阵容", size = 30, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(0, 65, 28)})
    :align(display.CENTER_LEFT, 13, 40)
    :addTo(myTeamIcon)

    self.myTeamNode = display.newNode()
        :addTo(self.teamBg)

    self:refreshMyTeam()
end

function PVPScene:initEnermyTeam()
    self.enermyBg = display.newSprite("#jjcenermyBg.png")
    :addTo(self)
    local bgSize = self.enermyBg:getContentSize()
    self.enermyBg:setPosition(display.width - self.enermyDi:getContentSize().width*0.4 - 
        bgSize.width*0.5 + display.width*0.5, 
        display.height*0.57)

    display.newSprite("Head/headman_"..memberData[srv_userInfo["templateId"]].resId..".png")
        :addTo(self.enermyBg)
        :align(display.LEFT_BOTTOM,bgSize.width*0.08,bgSize.height*0.8)

    cc.ui.UILabel.new({UILabelType = 2, text = "己方排名：", size = 22,color = MYFONT_COLOR})
    :align(display.LEFT_CENTER,bgSize.width*0.18,bgSize.height*0.91)
    :addTo(self.enermyBg)
    cc.ui.UILabel.new({UILabelType = 2, text = "己方战斗力：", size = 22 ,color = MYFONT_COLOR})
    :align(display.LEFT_CENTER,bgSize.width*0.18,bgSize.height*0.84)
    :addTo(self.enermyBg)
    self.rankLabel = display.newBMFontLabel({text = tostring(PVPData["myOrder"]), font = "fonts/num_3.fnt"})
    :align(display.LEFT_CENTER,bgSize.width*0.27,bgSize.height*0.905)
    :addTo(self.enermyBg)
    self.strengthLabel = display.newBMFontLabel({text = tostring(PVPData["strength"]), font = "fonts/num_3.fnt"})
    :align(display.LEFT_CENTER,bgSize.width*0.29,bgSize.height*0.835)
    :addTo(self.enermyBg)

    self:loadEnermy()

    cc.ui.UILabel.new({UILabelType = 2, text = "剩余挑战次数:", size = bgSize.height*0.055, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(46, 167, 224)})
    :align(display.CENTER_LEFT, bgSize.width*0.03, bgSize.height*0.08)
    :addTo(self.enermyBg)
    --剩余次数
    self.leftTime = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = bgSize.height*0.055, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255, 242, 24)})
    :align(display.CENTER_LEFT, bgSize.width*0.18, bgSize.height*0.08)
    :addTo(self.enermyBg)
    self.leftTime:setString(PVPData["leftCnt"].."/5")
    if PVPData["leftCnt"]==0 then
        self.leftTime:setColor(cc.c3b(255, 0, 0))
    else
        self.leftTime:setColor(cc.c3b(255, 255, 0))
    end

    local buytimeBt = cc.ui.UIPushButton.new({
        normal = "#jjcbuyN.png",
        pressed = "#jjcbuyS.png"
        })
    :addTo(self.enermyBg)
    :pos(bgSize.width*0.29,bgSize.height*0.085)
    :onButtonClicked(function(event)
        self:addAddTimeLayer()
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "购买次数", size = bgSize.height*0.05, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(255, 249, 29)})
    :align(display.CENTER, 0, 0)
    :addTo(buytimeBt)

    self.lestTimeNode = display.newNode()
    :addTo(self.enermyBg)
    self.lestTimeNode:setVisible(false)

    cc.ui.UILabel.new({UILabelType = 2, text = "冷却时间:", size = bgSize.height*0.055, color = cc.c3b(46, 167, 224)})
    :addTo(self.lestTimeNode)
    :align(display.CENTER_LEFT, bgSize.width*0.5, bgSize.height*0.08)

    --剩余时间
    self.lestTimeStr = cc.ui.UILabel.new({UILabelType = 2, text = "", size = bgSize.height*0.055, color = cc.c3b(255, 242, 24)})
    :addTo(self.lestTimeNode)
    :align(display.CENTER_LEFT, bgSize.width*0.6, bgSize.height*0.08)

    --刷新剩余时间按钮
    local resetTimeButton = cc.ui.UIPushButton.new({normal = "#jjcrefreshN.png",pressed = "#jjcrefreshS.png"})
    :pos(bgSize.width*0.75, bgSize.height*0.085)
    :onButtonClicked(function()
        if srv_userInfo.vip<4 then
            showTips("VIP4及以上可重置冷却时间")
            return 
        end
        showMessageBox("是否花费50钻石，重置挑战时间？", function()
            comData={}
            m_socket:SendRequest(json.encode(comData), CMD_PVP_REFRESHTIME, self, self.onPVPRefreshTime)
            end)
    end)
    :addTo(self.lestTimeNode)
    display.newSprite("#jjcrefreshIcon.png")
    :pos(-30,0)
    :addTo(resetTimeButton)
    cc.ui.UILabel.new({UILabelType = 2, text = "重置", size = bgSize.height*0.05, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(100, 244, 255)})
    :align(display.CENTER, 18, 0)
    :addTo(resetTimeButton)


    if PVPData.lastTs>=1000 then
        self.lestTimeNode:setVisible(true)
    else
        self.lestTimeNode:setVisible(false)
    end
    
    self.backItem:runAction(cc.RepeatForever:create(transition.sequence({
                                                                           cc.CallFunc:create(handler(self, self.onInterval)),
                                                                           cc.DelayTime:create(1),
                                                                        })))
    
    --换一组
    local changeEnermyButton = cc.ui.UIPushButton.new({normal = "#jjcchangeN.png",pressed = "#jjcchangeS.png"})
    :pos(bgSize.width*0.92, bgSize.height*0.085)
    :onButtonClicked(function()
        comData={}
        comData["characterId"] = srv_userInfo.characterId
        m_socket:SendRequest(json.encode(comData), CMD_CHANGE_ENERMY, self, self.OnPVPChangeEnermyRet)
    end)
    :addTo(self.enermyBg)
    display.newSprite("#jjcchangeIcon.png")
    :pos(-35,0)
    :addTo(changeEnermyButton)
    cc.ui.UILabel.new({UILabelType = 2, text = "换一组", size = bgSize.height*0.05, align = cc.ui.TEXT_ALIGN_CENTER, color = cc.c3b(158, 255, 113)})
    :align(display.CENTER, 15, 0)
    :addTo(changeEnermyButton)
end
function PVPScene:onInterval()
        -- print(PVPData.lastTs)
    if PVPData["leftCnt"]>0 and PVPData.lastTs>=1000 then
        self.lestTimeNode:setVisible(true)
        local timeStr = GetTimeStr(PVPData.lastTs)
        timeStr = string.sub(timeStr, 4, #timeStr)
        timeStr = timeStr.."后"
        self.lestTimeStr:setString(timeStr)
        PVPData.lastTs = PVPData.lastTs-1000
    else
        self.lestTimeNode:setVisible(false)
    end
end

function PVPScene:loadEnermy()
	for i=1,#self.enermys do
		self.enermys[i]:removeSelf()
	end
    local eCnt = #PVPData["enemys"]
	for i=1,eCnt do
    	self.enermys[i] = PvpOpponent.new(i)
    	:pos(self.enermyBg:getContentSize().width*(0.08 + (4-eCnt)*0.22)+self.enermyBg:getContentSize().width*0.22*(i-1),self.enermyBg:getContentSize().height*0.16)
    	:addTo(self.enermyBg)
    end
end

function PVPScene:addAddTimeLayer()
    if tonumber(PVPData["leftCnt"]) > 0 then
        showTips("请使用完剩余次数后再来购买")
        return
    end
    -- printTable(srv_userInfo)
    local hasBuyTime = PVPData["buyCnt"]
    local vipLevel = tonumber(srv_userInfo.vip)
    local bigestTime = self:getBigestBuyTime(vipLevel)
    if hasBuyTime >= bigestTime then
        if bigestTime == 0 then
            showTips("VIP等级不足，无法购买")
        else
            showTips("已达到当日最大购买次数")
        end
        return
    end
    self.addTimeBg = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,180))
    :addTo(self)
    self.addTimeBg:setTouchEnabled(true)
    self.addTimeBg:setTouchSwallowEnabled(true)
    self.addTimeBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.addTimeBg:removeSelf()
        return true
    end)

    local buyBg = display.newSprite("#jjc_fair_d02-05.png")
    :pos(display.width*0.5, display.height*0.5)
    :addTo(self.addTimeBg)
    buyBg:setTouchEnabled(true)
    --标题
    local buyBgSize = buyBg:getContentSize()
    display.newSprite("#jjc_fair_d02-01.png")
    :pos(buyBgSize.width*0.5,buyBgSize.height)
    :addTo(buyBg)
    display.newSprite("#jjc_fair_d02-10.png")
    :pos(buyBgSize.width*0.5,buyBgSize.height)
    :addTo(buyBg)
    cc.ui.UILabel.new({UILabelType = 2, text = "选择购买方式", size = buyBgSize.height*0.08, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(143, 255, 63)})
    :align(display.CENTER, buyBgSize.width*0.5,buyBgSize.height*0.76)
    :addTo(buyBg)

    local diamondCost = self:getBuyTimeCost(vipLevel, hasBuyTime)
    --单次按钮
    local oneItem = cc.ui.UIPushButton.new({normal="#jjc_fair_d02-02.png",pressed="#jjc_fair_d02-07.png"})
    :addTo(buyBg)
    :onButtonClicked(function(event)
        --购买PVP次数
        self.curAddTime = 1
        self.curBuyCost = diamondCost.oneCost
        comData={}
        comData["characterId"] = srv_userInfo.characterId
        comData["buyCnt"] = self.curAddTime
        m_socket:SendRequest(json.encode(comData), CMD_BUYPVP_TIME, self, self.OnPVPBuyTimeRet)
    end)
    local oneTitle = display.newSprite("#jjc_fair_d02-03.png")
    :addTo(buyBg)
    local oneDiamondBg = display.newSprite("#jjc_fair_d02-06.png")
    :addTo(buyBg)
    local oneDiamond = display.newSprite("common/common_Diamond.png")
    :addTo(buyBg)
    oneDiamond:scale(0.7)
    local oneDiamondLabel = cc.ui.UILabel.new({UILabelType = 2, text = tostring(diamondCost.oneCost), size = buyBgSize.height*0.09, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
    :align(display.CENTER, buyBgSize.width*0.49, buyBgSize.height*0.5)
    :addTo(buyBg)
    
    if diamondCost.fiveCost == nil then
        oneItem:setPosition(buyBgSize.width*0.5, buyBgSize.height*0.47)
        oneTitle:setPosition(buyBgSize.width*0.5, buyBgSize.height*0.47)
        oneDiamondBg:setPosition(buyBgSize.width*0.5, buyBgSize.height*0.23)
        oneDiamond:setPosition(buyBgSize.width*0.35, buyBgSize.height*0.23)
        oneDiamondLabel:setPosition(buyBgSize.width*0.5, buyBgSize.height*0.23)
    else
        oneItem:setPosition(buyBgSize.width*0.25, buyBgSize.height*0.47)
        oneTitle:setPosition(buyBgSize.width*0.25, buyBgSize.height*0.47)
        oneDiamondBg:setPosition(buyBgSize.width*0.25, buyBgSize.height*0.23)
        oneDiamond:setPosition(buyBgSize.width*0.12, buyBgSize.height*0.23)
        oneDiamondLabel:setPosition(buyBgSize.width*0.25, buyBgSize.height*0.23)
        --5次按钮
        local fiveItem = cc.ui.UIPushButton.new({normal="#jjc_fair_d02-08.png",pressed="#jjc_fair_d02-09.png"})
        :pos(buyBgSize.width*0.75, buyBgSize.height*0.47)
        :addTo(buyBg)
        :onButtonClicked(function(event)
            self.curAddTime = 5
            self.curBuyCost = diamondCost.fiveCost
             --购买PVP次数
            comData={}
            comData["characterId"] = srv_userInfo.characterId
            comData["buyCnt"] = 5
            m_socket:SendRequest(json.encode(comData), CMD_BUYPVP_TIME, self, self.OnPVPBuyTimeRet)
        end)
        local fiveTitle = display.newSprite("#jjc_fair_d02-04.png")
        :pos(buyBgSize.width*0.75, buyBgSize.height*0.47)
        :addTo(buyBg)
        local fiveDiamondBg = display.newSprite("#jjc_fair_d02-06.png")
        :pos(buyBgSize.width*0.75, buyBgSize.height*0.23)
        :addTo(buyBg)
        local fiveDiamond = display.newSprite("common/common_Diamond.png")
        :pos(buyBgSize.width*0.62, buyBgSize.height*0.23)
        :addTo(buyBg)
        fiveDiamond:scale(0.7)
        local fiveDiamondLabel = cc.ui.UILabel.new({UILabelType = 2, text = tostring(diamondCost.fiveCost), size = buyBgSize.height*0.09, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
        :align(display.CENTER, buyBgSize.width*0.75, buyBgSize.height*0.23)
        :addTo(buyBg)
    end
end

--拆解时间 返回一个table
function PVPScene:splitTime(_timeStr)
	local  dayTimeTable = string.split(_timeStr," ")
	local  dayLabel = string.split(tostring(dayTimeTable[1]),"-")
	local  timeLabel = string.split(tostring(dayTimeTable[2]),":")
	for i=1,#timeLabel do
		table.insert(dayLabel, #dayLabel + 1, timeLabel[i])
	end
	return dayLabel
end

function PVPScene:onGetFightRecord(cmd)
    if cmd.result == 1 then
       PVPData["fRecs"] = {}
       PVPData["fRecs"] = cmd["data"]["fRecs"]
       self:addRecordLayer()
    else
       showTips(cmd.msg)
    end
end

--根据时间数组对比确定一个字符串并返回
function PVPScene:handleRecord()
    for i=1,#PVPData["fRecs"] do
        local _times = self:splitTime(PVPData["fRecs"][i]["time"])
        local  tmpStr = nil
        local serverTime = os.time({year = _times[1], month = _times[2], day = _times[3], hour = _times[4], min = _times[5], sec = _times[6]})
        local lastSec = os.time() - serverTime
        if lastSec < 0 then
           PVPData["fRecs"][i]["bTime"] = "1分钟前"
        elseif math.floor(lastSec/(3600*24*30)) >= 1 then
           PVPData["fRecs"][i]["bTime"] = math.floor(lastSec/(3600*24*30)).."个月前"
        elseif math.floor(lastSec/(3600*24)) >= 1 then
           PVPData["fRecs"][i]["bTime"] = math.floor(lastSec/(3600*24)).."天前"
        elseif math.floor(lastSec/3600) >= 1 then
           PVPData["fRecs"][i]["bTime"] = math.floor(lastSec/3600).."小时前"
        elseif math.ceil(lastSec/60) >= 1 then
           PVPData["fRecs"][i]["bTime"] = math.floor(lastSec/60).."分钟前"
        end
        PVPData["fRecs"][i]["bTimeSecond"] = lastSec
    end
end

function PVPScene:addRecordLayer()
    local  recordLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,180))
    :addTo(self)
    -- --返回按钮
    -- cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png",pressed="common/common_BackBtn_2.png"})
    -- :align(display.LEFT_TOP, display.width*0.03, display.height*0.98)
    -- :addTo(recordLayer)
    -- :onButtonClicked(function(event)
    --     recordLayer:removeSelf()
    -- end)
    local recordBg = display.newScale9Sprite("common/common_Frame4.png",nil,nil,
        cc.size(705, 535),cc.rect(20, 20, 63, 61))
    :pos(display.width/2, display.height/2)
    :addTo(recordLayer)
    local recordBgSize = recordBg:getContentSize()
    display.newSprite("common/common_Frame5.png")
    :pos(recordBgSize.width/2, recordBgSize.height)
    :addTo(recordBg)
    display.newSprite("#huifang-06.png")
    :pos(recordBgSize.width/2, recordBgSize.height)
    :addTo(recordBg)

    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(recordBg)
    :pos(recordBgSize.width, recordBgSize.height)
    :onButtonClicked(function(event)
        recordLayer:removeSelf()
    end)

    if PVPData["fRecs"] == nil or #PVPData["fRecs"]==0 then
        cc.ui.UILabel.new({UILabelType = 2, text = "无对战记录", size = 30, color = cc.c3b(255, 255, 0)})
        :addTo(recordBg)
        :align(display.CENTER, recordBgSize.width/2, recordBgSize.height/2)
        return
    end

    self:handleRecord()

    --筛选出24小时内的记录
    local  showRecords = {}
    for i=1,#PVPData["fRecs"] do
        if tonumber(PVPData["fRecs"][i]["bTimeSecond"]) < 360000*24 then
            showRecords[#showRecords + 1] = PVPData["fRecs"][i]
        end
    end
    
    --滑动列表
    self.recordList = cc.ui.UIListView.new {
        viewRect = cc.rect(14, 25, 677, 460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
    }
    :addTo(recordBg)
     
    for i=1,#showRecords do
        local item = self.recordList:newItem()
        local  oneBg = display.newScale9Sprite("common/Improve_Text13.png",nil,nil,cc.size(655, 90))
        local oneBgSize = oneBg:getContentSize()

        --名字
        local namebar = display.newScale9Sprite("common/common_Frame26.png",nil,nil,
            cc.size(180,30),cc.rect(10,10,30,30))
        :addTo(oneBg)
        :align(display.CENTER_LEFT, 250,oneBgSize.height/2+17)
        cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = cc.c3b(255, 255, 0)})
        :addTo(namebar)
        :pos(20, namebar:getContentSize().height/2)
        :setString(showRecords[i]["ename"])

        --等级
        local levelBar = display.newScale9Sprite("common/common_Frame26.png",nil,nil,
            cc.size(50,30),cc.rect(10,10,30,30))
        :addTo(oneBg)
        :align(display.CENTER_LEFT, 245,oneBgSize.height/2-17)
        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
        :addTo(levelBar)
        :pos(20, levelBar:getContentSize().height/2-2)
        :setString(showRecords[i]["elvl"])

        --头像框
        local headBg = display.newSprite("common/common_headBox.png")
        :pos(oneBgSize.width/13+175, oneBgSize.height/2)
        :addTo(oneBg)
        --头像
        local  bodyName = "Head/headman_"..string.sub(showRecords[i]["eTptId"],1,4)..".png"
        display.newSprite(bodyName)
        :addTo(headBg)
        :pos(headBg:getContentSize().width/2, headBg:getContentSize().height/2)
        :scale(0.65)

        --过去时间
        local lastTime = cc.ui.UILabel.new({UILabelType = 2, text = showRecords[i]["bTime"], size = 22, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
        :align(display.CENTER_LEFT, oneBgSize.width*0.2+200, oneBgSize.height*0.3)
        :addTo(oneBg)

        --名次变化
        --胜利失败图标
        local winImg = display.newSprite()
        :addTo(oneBg)
        :pos(45, oneBgSize.height/2)
        local jiantouImg = display.newSprite()
        :addTo(oneBg)
        :pos(95, oneBgSize.height/2-10)
        local num = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(0, 255, 0)})
            :addTo(oneBg)
            :pos(115, 33)
        if showRecords[i]["corder"] == 0 then
            if showRecords[i].win==1 then
                winImg:setSpriteFrame("zduiz_jilu-03.png")
                jiantouImg:setSpriteFrame("zduiz_jilu-05.png")
                num:setString("0")
                num:setColor(cc.c3b(0, 255, 0))
                lastTime:setColor(cc.c3b(0, 255, 0))
            else
                winImg:setSpriteFrame("zduiz_jilu-04.png")
                jiantouImg:setSpriteFrame("zduiz_jilu-06.png")
                num:setString("0")
                num:setColor(cc.c3b(255, 0, 0))
                lastTime:setColor(cc.c3b(255, 0, 0))
            end
        elseif showRecords[i]["corder"] > 0 then
            winImg:setSpriteFrame("zduiz_jilu-03.png")
            jiantouImg:setSpriteFrame("zduiz_jilu-05.png")
            num:setString(showRecords[i]["corder"])
            num:setColor(cc.c3b(0, 255, 0))
            lastTime:setColor(cc.c3b(0, 255, 0))
        else
            winImg:setSpriteFrame("zduiz_jilu-04.png")
            jiantouImg:setSpriteFrame("zduiz_jilu-06.png")
            num:setString(-showRecords[i]["corder"])
            num:setColor(cc.c3b(255, 0, 0))
            lastTime:setColor(cc.c3b(255, 0, 0))
        end
        
        
        --分享按钮
        local shareItem = cc.ui.UIPushButton.new({normal = "#zduiz_jilu-08.png",pressed = "#zduiz_jilu-09.png"})
        :pos(oneBgSize.width*0.7+50, oneBgSize.height*0.5)
        :onButtonClicked(function(event)
            if srv_userInfo.level<20 then
                showTips("等级20级才能分享至世界聊天")
                return
            end
                print("分享")
                startLoading()
                chatType = 4
                local sendData = {}
                sendData["msg"] = showRecords[i]["id"]
                sendData["type"] = 4
                sendData["tarCID"] = srv_userInfo["characterId"]
                m_socket:SendRequest(json.encode(sendData), CMD_SENT_CHATMSG, self, self.onSendChatMsg)
        end)
        :addTo(oneBg)
        --回放按钮
        local playBackItem = cc.ui.UIPushButton.new({normal = "#zduiz_jilu-10.png",pressed = "#zduiz_jilu-11.png"})
        :pos(oneBgSize.width*0.9, oneBgSize.height*0.5)
        :onButtonClicked(function(event)
            startLoading()
            comData={}
            comData["characterId"] = srv_userInfo.characterId
            comData["recId"] = showRecords[i]["id"]
           m_socket:SendRequest(json.encode(comData), CMD_GET_PLAYBACK, self, self.OnPVPPlaybackRet)
        end)
        :addTo(oneBg)

        item:addContent(oneBg)
        item:setItemSize(655, 100)
        self.recordList:addItem(item)
    end
    self.recordList:reload()
end 

--开始战斗
function PVPScene:OnPVPFightRet(result)
    
end

--换一组返回
function PVPScene:OnPVPChangeEnermyRet(result)
    if result.result==1 then
        PVPData["enemys"] = result["data"]["enemys"]
        self:loadEnermy()
        self.rankLabel:setString(result["data"].myOrder)
    else
        showTips(result.msg)
    end
    
end

--通过VIP等级获取最大购买次数
function PVPScene:getBigestBuyTime(_vipLevel)
    if tonumber(_vipLevel) < 3 then
        return 0
    end
    return (tonumber(_vipLevel) -2)*5
end

--通过当前已经购买次数和VIP等级获取价格
function PVPScene:getBuyTimeCost(_vipLevel, _hasBuyTime)
    local cost = {}
    local index = math.floor(_hasBuyTime/5) + 1
    local rest = _hasBuyTime%5
    cost.oneCost = buyTimeCosts[index].one
    if rest == 0 then
        cost.fiveCost = buyTimeCosts[index].five
    end
    return cost
end

--购买挑战次数
function PVPScene:OnPVPBuyTimeRet(result)
    if tonumber(result["result"]) == 1 then
        self.addTimeBg:removeSelf()
        PVPData["leftCnt"] = tonumber(PVPData["leftCnt"]) + self.curAddTime
        self.leftTime:setString(PVPData["leftCnt"].."/5")
        self.leftTime:setColor(cc.c3b(0, 255, 0))
        --srv_userInfo["diamond"] = tonumber(srv_userInfo["diamond"]) - self.curBuyCost
        --self.diamondLabel:setString(srv_userInfo["diamond"])
        showTips("购买成功")

        srv_userInfo.diamond = srv_userInfo.diamond - self.curBuyCost
        DCCoin.lost("购买竞技场挑战次数","钻石",self.curBuyCost,srv_userInfo.diamond)
        mainscenetopbar:setDiamond()
        --数据统计
        luaStatBuy("竞技场次数", BUY_TYPE_PVP_CNT, 1, "钻石", self.curBuyCost)

        --显示倒计时
        if PVPData.lastTs>=1000 then
            self.lestTimeNode:setVisible(true)
        else
            self.lestTimeNode:setVisible(false)
        end
    else
        showTips(result["msg"])
    end
end
--获取回放信息
function PVPScene:OnPVPPlaybackRet(result)
    if tonumber(result["result"]) == 1 then
        --print("----------------------------OnPVPPlaybackRet start")


        --printTable(result)
        --print("----------------------------OnPVPPlaybackRet end")
        CurFightBattleType = FightBattleType.kType_PVP
        IsPlayback = true
        --RandomSeedPool = result["data"]["fdetail"]["randomSeeds"]
        RandomSeed = result["data"]["fdetail"]["randomSeed"]
        BattleData["members"] = {}
        BattleData["enemys"] = {}
        --BattleData["defName"] = result["data"]["defName"]
        --BattleData["eName"] = result["data"]["enemyName"]
        BattleData["mylevel"] = result["data"]["fdetail"]["mylevel"]
        BattleData["elevel"] = result["data"]["fdetail"]["elevel"]
        BattleData["eStrength"] = result["data"]["fdetail"]["eStrength"]
        BattleData["strength"] = result["data"]["fdetail"]["strength"]
        BattleData["members"] = result["data"]["fdetail"]["members"]
        BattleData["enemys"] = result["data"]["fdetail"]["enemys"]
        BattleData["type"] = result.data.type --type==1进攻方，type==2防守方
        BattleData["win"] = result.data.win

        if BattleData["type"] == 1 then
            BattleData["defName"] = result["data"]["enemyName"] --右边
            BattleData["eName"] = srv_userInfo.name --左边
        else
            BattleData["defName"] = srv_userInfo.name --右边
            BattleData["eName"] = result["data"]["enemyName"] --左边
        end

        --print("----------defName="..BattleData["defName"])
        --print("----------eName="..BattleData["eName"])

        if (BattleData["type"] == 1 and BattleData["win"] == 1) or (BattleData["type"] == 2 and BattleData["win"] == 0) then --进攻方赢
            print("attack side win")
            for k, enemy in pairs(BattleData["enemys"]) do
                if enemy['cri'] ~= nil then
                    enemy['cri'] = 0.5*enemy['cri']
                end
                if enemy['miss'] ~= nil then
                    enemy['miss'] = 0.5*enemy['miss']
                end
            end            
            --printTable(BattleData["enemys"])
        else --进攻方输
            print("attack side lose")
            for k, member in pairs(BattleData["members"]) do
                if member['cri'] ~= nil then
                    member['cri'] = 0.5*member['cri']
                end
                if member['miss'] ~= nil then
                    member['miss'] = 0.5*member['miss']
                end
            end
            --printTable(BattleData["members"])
        end      

        app:enterScene("LoadingScene",{SceneType.Type_Battle})
    end 
end
--分享视频
function PVPScene:onSendChatMsg(result)
    if result.result==1 then
        showTips("已分享至世界聊天。")
    end
end

--获取PVP商品购买记录
function PVPScene:OnPVPBuyRecordRet(result)

end
--购买PVP商品
function PVPScene:OnPVPBuyItemRet(result)

end

function PVPScene:onPVPRefreshTime(result)
    if result.result==1 then
        PVPData.lastTs=0
        self.lestTimeNode:setVisible(false)
        showTips("当前可前往挑战！")

        srv_userInfo.diamond = srv_userInfo.diamond - 50
        DCCoin.lost("购买竞技场冷却时间","钻石",50,srv_userInfo.diamond)

        mainscenetopbar:setDiamond()
    else
        showTips(result.msg)
    end
end

function PVPScene:onEnter()
end

function PVPScene:onExit()
    PVP_Instance = nil
    GuideManager:removeGuideLayer()
    display.removeSpriteFramesWithFile("Image/UIPVPScene.plist", "Image/UIPVPScene.png")
end

return PVPScene