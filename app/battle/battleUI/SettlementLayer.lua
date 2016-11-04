--
-- Author: liufei
-- Date: 2014-12-12 15:01:50
--
local SettlementLayer = class("SettlementLayer", function()
	 return display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,210))
end)

local curGuideBtn = nil

-- settleInfo = {
--                gold = 500,
--                rewards = {
-- 	                          [1] = {},
-- 	                          [2] = {},
-- 	                          [3] = {}
--	                        },
--                members = {
-- 	                          [1] = {},
-- 	                          [2] = {},
-- 	                          [3] = {}
--                          }
--              }
function SettlementLayer:ctor(_result, _settleInfo,_data)
    GuideManager:removeGuideLayer()
    audio.playMusic("audio/winBg.mp3",false)

    local colorBg = display.newSprite("common/colorbg.png")
    :addTo(self,-1)
    colorBg:setAnchorPoint(0,0)
    colorBg:setScaleX(display.width/colorBg:getContentSize().width)
    colorBg:setScaleY(display.height/colorBg:getContentSize().height)

	self.settleInfo = _settleInfo
    --结算标题
    local titleName = nil
	if _result == false then
        if IsOverTime == true then
	       titleName = "Battle/Settlement/zioop_cre-03-01.png"
        else
           titleName = "Battle/Settlement/jiesuan_12.png"
        end
	else
        titleName = "Battle/Settlement/jiesuan_11.png"
        if EmbattleMgr.nCurBattleType == BattleType_PVE then
            --扣除燃油
            local useEnergyEnd = 0
            if tonumber(string.sub(tostring(BattleID),1,1)) == 1 then
              useEnergyEnd = tonumber(blockData[block_idx]["energyCost"]) - 1
            else
              useEnergyEnd = tonumber(blockData[block_idx]["energyCost"]) - 2
            end
            SetEnergyAndCountDown(srv_userInfo["energy"] - useEnergyEnd)
        end
	end
    local title = display.newSprite(titleName)
    :addTo(self,2)
    --星星底框
    local starBg = display.newSprite("Battle/Settlement/jiesuan_10.png")
    :addTo(self,2)

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
            heroModel:setScaleX(heroModel:getScaleX()*0.8)
            heroModel:setScaleY(heroModel:getScaleY()*0.8)
            if tmpMakeType == ModelMakeType.kMake_Coco then
                heroModel:getAnimation():play("Standby")
            else
                if _result == true and BattleStar > 0 then
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
    starBg:setPosition(display.width*0.5, headBg[1]:getPositionY()+headBg[1]:getContentSize().height/2 + starBg:getContentSize().height*0.32)
    title:setPosition(display.width*0.5, headBg[1]:getPositionY()+headBg[1]:getContentSize().height/2+starBg:getContentSize().height+title:getContentSize().height*0.08)

    if _result == true then
        local fLight1 = display.newSprite("Battle/Settlement/slzzz_01.png")
        :pos(display.width*0.5, starBg:getPositionY()+starBg:getContentSize().height*0.5)
        :addTo(self,1)
        fLight1:setRotation(15)
        local fLight2 = display.newSprite("Battle/Settlement/slzzz_02.png")
        :pos(display.width*0.5, starBg:getPositionY()+starBg:getContentSize().height*0.5)
        :addTo(self,1)
        local fLight3 = display.newSprite("Battle/Settlement/slzzz_03.png")
        :pos(display.width*0.5, starBg:getPositionY()+starBg:getContentSize().height*0.5)
        :addTo(self,1)
        local sun = display.newSprite("Battle/Settlement/slzzz_04.png")
        :pos(display.width*0.5, starBg:getPositionY()+starBg:getContentSize().height*0.5)
        :addTo(self,1)
        fLight1:scale(1.3)
        fLight2:scale(1.3)
        fLight3:scale(1.3)
        fLight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(7, 360)))
        fLight2:runAction(cc.RepeatForever:create(cc.RotateBy:create(7, 360)))
        fLight3:runAction(cc.RepeatForever:create(cc.RotateBy:create(7,-360)))
        sun:runAction(cc.RepeatForever:create(transition.sequence({
                                             cc.ScaleTo:create(1.2, 1.2),
                                             cc.ScaleTo:create(1.2, 0.6),
                                          })))
    else
        local fLight = display.newSprite("Battle/Settlement/slzzz_05.png")
        :pos(display.width*0.5, starBg:getPositionY()+starBg:getContentSize().height*0.5)
        :addTo(self,1)
        fLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3,360)))
    end
    --人物头像
    -- local index = 1
    -- local headName = ""
    -- if _result == true then
    --     headName = "HalfBody/halfbody_%s_win.png"
    -- else
    --     headName = "HalfBody/halfbody_%s_lose.png"
    -- end
    
    local infoBg = display.newSprite("Battle/Settlement/infoBg.png")
    :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.55)
    :addTo(self,2)
    local infoBgSize = infoBg:getContentSize()
    --等级
    cc.ui.UILabel.new({UILabelType = 2, text = "Lv:", size = display.height/33, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(171,192,198)})
    :pos(infoBgSize.width*0.02,infoBgSize.height*0.5)
    :addTo(infoBg)
    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = _data["level"], size = display.height/33, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,241,0)})
    :pos(infoBgSize.width*0.08, infoBgSize.height*0.48)
    :addTo(infoBg)
    --经验
    local fillBg = display.newSprite("Battle/battleImg_5.png")
    :pos(infoBgSize.width*0.4, infoBgSize.height*0.5)
    :addTo(infoBg)
    fillBg:setScaleX(1.6)
    fillBg:setScaleY(1)
    local fill = display.newProgressTimer("Battle/battleImg_15.png", display.PROGRESS_TIMER_BAR)
    :pos(infoBgSize.width*0.4, infoBgSize.height*0.51)
    :addTo(infoBg)
    fill:setScaleX(1.6)
    fill:setScaleY(1)
    fill:setMidpoint(cc.p(0, 0.5))
    fill:setBarChangeRate(cc.p(1.0, 0))
    fill:setPercentage(_data["exp"]/_data["maxExp"]*100)
    local perLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = _data["exp"].."/".._data["maxExp"], size = display.height/40, align = cc.ui.TEXT_ALIGN_LEFT ,color = display.COLOR_WHITE})
    :pos(infoBgSize.width*0.36, infoBgSize.height*0.5)
    :addTo(infoBg)
    perLabel:enableOutline(cc.c4f(0,0,0,255),1.5)

    cc.ui.UILabel.new({UILabelType = 2, text = "战队经验:", size = display.height/33, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(171,192,198)})
    :pos(infoBgSize.width*0.7,infoBgSize.height*0.5)
    :addTo(infoBg)
    local getExp = ""
    if blockData[BattleID] ~= nil then
        getExp = blockData[BattleID]["exp"]
    else
        getExp = "0"
    end
    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "+"..getExp, size = display.height/33, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(255,241,0)})
    :pos(infoBgSize.width*0.85,infoBgSize.height*0.48)
    :addTo(infoBg)
    
    --线和掉落
    -- display.newSprite("Battle/Settlement/jiesuan_13.png")
    -- :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*1.2)
    -- :addTo(self)
    -- display.newSprite("Battle/Settlement/jiesuan_13.png")
    -- :pos(display.width*0.5, headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*2.4)
    -- :addTo(self)
    if _result == true then
        self.awardList = cc.ui.UIListView.new {
            viewRect = cc.rect(315, 60, 650, 130),
            direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        }
        :addTo(self)
        local reason = {"普通副本：",
                                "精英副本：",
                                "军团副本：",
                                "金币材料副本：",
                                "战车材料副本：",
                                "人物材料副本：",
                                "随机探测副本："}
        local strType = tonumber(string.sub(tostring(block_idx),1,1))
        for i=1,#self.settleInfo.rewards + 1 do
            local item = self.awardList:newItem()
            local oneSp = nil
            if i == 1 then 
                oneSp = display.newSprite("common/common_GoldGet.png")
                local goldLabel = cc.ui.UILabel.new({UILabelType = 2, text = string.format("x%d", self.settleInfo.gold), size = display.height/33, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
                :pos(12,-10)
                :addTo(oneSp)
                DCCoin.gain(reason[strType]..block_idx,"金币",self.settleInfo.gold,srv_userInfo.gold+self.settleInfo.gold)
            else
                oneSp = GlobalGetItemIcon(self.settleInfo.rewards[i-1]["id"])
                oneSp:setScale(0.7)
                local itemLabel = cc.ui.UILabel.new({UILabelType = 2, text = string.format("x%d", self.settleInfo.rewards[i-1]["num"]), size = display.height/23, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
                :pos(48,-15)
                :addTo(oneSp)

                local dc_item = itemData[self.settleInfo.rewards[i-1]["id"]+0]
                
                
                DCItem.get(tostring(dc_item.id), dc_item.name, self.settleInfo.rewards[i-1]["num"], reason[strType]..block_idx)
            end
            item:addContent(oneSp)
            item:setItemSize(112, 130)
            self.awardList:addItem(item)
        end
        self.awardList:reload()
    else
        local helpImgNames = {[1] = "Battle/Settlement/zdjs_sprs-07.png",[2] = "Battle/Settlement/zdjs_sprs-06.png",[3] = "Battle/Settlement/zdjs_sprs-05.png"}
        local helpWordNames = {[1] = "Battle/Settlement/zdjs_sprs-04.png",[2] = "Battle/Settlement/zdjs_sprs-08.png",[3] = "Battle/Settlement/zdjs_sprs-03.png"}
        local helpSize = display.newSprite("Battle/Settlement/zdjs_sprs-02.png"):getContentSize()
        for i=1,3 do
           local tmpHelpItem = cc.ui.UIPushButton.new({normal = "Battle/Settlement/zdjs_sprs-02.png",pressed = "Battle/Settlement/zdjs_sprs-01.png"})
           :pos(display.width*(0.31+(i-1)*0.19), headBg[1]:getPositionY() - headBg[1]:getContentSize().height*0.5*1.8)
           :addTo(self)
           :onButtonClicked(function()
                print("help click")
                if i==1 then
                    MainSceneEnterType = EnterTypeList.FAILD_LINK1
                elseif i==2 then
                    MainSceneEnterType = EnterTypeList.FAILD_LINK2
                elseif i==3 then
                    MainSceneEnterType = EnterTypeList.FAILD_LINK3
                end
                app:enterScene("LoadingScene", {SceneType.Type_Block})
           end)
           display.newSprite(helpImgNames[i])
           :align(display.CENTER,-helpSize.width*0.23, 0)
           :addTo(tmpHelpItem)
           display.newSprite(helpWordNames[i])
           :align(display.CENTER, helpSize.width*0.23, 0)
           :addTo(tmpHelpItem)
        end
    end
    --按钮
    local reItem = cc.ui.UIPushButton.new({normal = "Battle/Settlement/jiesuan_08.png",pressed = "Battle/Settlement/jiesuan_15.png"})
    :pos(display.width*0.15, headBg[1]:getPositionY())
    :addTo(self)
    :hide()
    :onButtonClicked(function()
        IsFightAgain = true
        self:settleItemClicked(_result)
    end)
    reItem:scale(1.2)

    local backItem = cc.ui.UIPushButton.new({normal = "Battle/Settlement/jiesuan_07.png",pressed = "Battle/Settlement/jiesuan_14.png"})
    :pos(display.width*0.85, headBg[1]:getPositionY())
    :addTo(self)
    :hide()
    :onButtonClicked(function()
        IsFightAgain = false
        self:settleItemClicked(_result)
    end)
    curGuideBtn = backItem
    backItem:scale(1.2)

    local function showItems()
        if (not fight_isInGuide) and blockData[block_idx] and (blockData[block_idx].type==1 or blockData[block_idx].type==2) and blockData[block_idx].ctype==1 then
                reItem:show()
            end
        backItem:show()
    end

    if _result == true and BattleStar > 0 then
        local  starIndex = 1
        local function showStar()
            if starIndex >= 4 then
                return
            end
            local star = display.newSprite("Battle/Settlement/jiesuan_03.png")
            :pos(display.width*0.44+display.width*0.061*(starIndex-1),starBg:getPositionY()+starBg:getContentSize().height*0.06)
            :addTo(self,2)
            star:scale(7)
            if starIndex == 2 then
                star:setPositionY(starBg:getPositionY() + starBg:getContentSize().height*0.15)
                star:runAction(cc.ScaleTo:create(0.2,1.2))
            else
                star:runAction(cc.ScaleTo:create(0.2,1))
            end
            
            starIndex = starIndex +1
        end
        self:runAction(cc.Repeat:create(transition.sequence({
                                                               cc.CallFunc:create(showStar),
                                                               cc.DelayTime:create(0.3)
                                                            }),BattleStar))
        self:performWithDelay(showItems, 0.3*BattleStar)
    else
        showItems()
    end
    -- if  _data["level"] > srv_userInfo["level"] then
    --      teamUpgrade:createUpgradeBox(srv_userInfo["level"],_data["level"],srv_userInfo["energy"])
    -- end
    --同步数据
    srv_userInfo["level"] = _data["level"]
    srv_userInfo["maxexp"] = _data["maxExp"]
    srv_userInfo["exp"] = _data["exp"]
    --新手教程
    GuideManager:_addGuide_2(11309, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10106, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10509, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11109, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11211, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10206, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11606, self,handler(self,self.caculateGuidePos))
    -- printTable(blockData[block_idx])
    --首次三星通过奖励显示
    print("首次三星通过奖励显示")
    print(_result)
    if _result == true then
        self:addAllstarReward()
        self:isTriggerBranch()
    end
end

function SettlementLayer:settleItemClicked(_r)
    GuideManager:removeGuideLayer()
    if _r == true then
        local getCarId = tonumber(blockData[block_idx]["car"])
        if 2==srv_userInfo.mainline then
            getCarId = tonumber(blockData[block_idx]["carEvil"])
        end
        local getMemberId = tonumber(blockData[block_idx]["member"])
        if getCarId ~= 0 and getFightBlockStar() <= 0  then--未通关  then
            addAwardLayer(self,{carID = getCarId})
            CarManager.isReqFlag = true --获得车后重新请求战车数据
            return
        end
        if getMemberId ~= 0 and getFightBlockStar() <= 0 then
            addAwardLayer(self,{memberID = getMemberId})
            RoleManager.isReqFlag = true --获得人后重新请求人物数据
            return
        end
    end
    app:enterScene("LoadingScene", {SceneType.Type_Block})
end
function addAwardLayer(parent,params,_handler,zorder)
    zorder = zorder or 3
    _handler = _handler or function ( ... )
        app:enterScene("LoadingScene", {SceneType.Type_Block})
    end
    local self = parent
    local awardLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,240))
    :addTo(self,zorder)
    local awardBg = display.newScale9Sprite("SingleImg/teamLevel/teamLevelImg3.png",display.cx, display.cy-50, 
        cc.size(785,519))
    :addTo(awardLayer)
    awardBg:setTouchEnabled(true)

    --标题动画
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("SingleImg/GainBox/GainBoxAni.ExportJson")
    local armature = ccs.Armature:create("GainBoxAni")
                        :addTo(awardBg,10)
                        :pos(awardBg:getContentSize().width/2, awardBg:getContentSize().height +20)

    local function playFlower()
        armature:getAnimation():play("titleFlower")
    end
    tmpAction = transition.sequence{
                                cc.Hide:create(),
                                cc.DelayTime:create(0.2),
                                cc.Show:create(),
                                cc.CallFunc:create(playFlower)
                            }
    armature:runAction(tmpAction)

    local title = display.newSprite("SingleImg/GainBox/title_1.png")
                    :addTo(awardBg,10)
                    :pos(awardBg:getContentSize().width/2, awardBg:getContentSize().height +20)

    tmpAction = transition.sequence({           
                                cc.Hide:create(),
                                cc.DelayTime:create(0.3),
                                cc.Show:create(),
                                cc.ScaleTo:create(0  , 5.02 ,5.84),
                                cc.ScaleTo:create(0.1, 5.05 ,5.88),
                                cc.ScaleTo:create(0.1, 3.01 ,3.42),
                                cc.ScaleTo:create(0.1, 0.97 ,0.96),
                                cc.ScaleTo:create(0.1, 1 ,1)
                                    })
    title:runAction(tmpAction)

    local awardBgSize = awardBg:getContentSize()
    local light = display.newSprite("Battle/Settlement/hdbirs_d02-05.png")
    :pos(awardBgSize.width*0.5, awardBgSize.height*0.55)
    :addTo(awardBg)
    -- light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5,360)))
    local labelStr = ""
    local nameStr = ""
    local mType = 0
    local tptID = 0
    local scaleNum = 1
    if params.carID ~= nil then
        labelStr = "你获得了一辆新的战车！"
        nameStr = carData[params.carID]["name"]
        mType = ModelType.Tank
        tptID = params.carID
        srv_userInfo.hasCar = tonumber(srv_userInfo.hasCar) + 1
        scaleNum = 1.5
    elseif params.memberID ~= nil then
        labelStr = "你获得了一个新的伙伴！"
        nameStr = memberData[params.memberID]["name"]
        mType = ModelType.Hero
        tptID = params.memberID
        scaleNum = 0.78
    end
    cc.ui.UILabel.new({UILabelType = 2, text = labelStr, size = awardBgSize.height*0.05, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(255, 235, 8)})
    :align(display.CENTER,awardBgSize.width*0.5, awardBgSize.height*0.88)
    :addTo(awardBg)
    local mModel = ShowModel.new({modelType=mType, templateID=tptID})
                        :pos(awardBgSize.width*0.5, awardBgSize.height*0.41)
                        :addTo(awardBg)
    mModel:setScaleX(-scaleNum)
    mModel:setScaleY(scaleNum)
    --名字
    display.newSprite("Battle/Settlement/hdbirs_d02-04.png")
    :pos(awardBgSize.width*0.5, awardBgSize.height*0.29)
    :addTo(awardBg)
    cc.ui.UILabel.new({UILabelType = 2, text = nameStr, size = awardBgSize.height*0.05, align = cc.ui.TEXT_ALIGN_CENTER ,color = cc.c3b(255, 235, 8)})
    :align(display.CENTER,awardBgSize.width*0.5, awardBgSize.height*0.29)
    :addTo(awardBg)
    --确定按钮
    local backItem = cc.ui.UIPushButton.new({normal = "common2/com2_Btn_6_up.png",pressed = "common2/com2_Btn_6_down.png"})
    :pos(awardBgSize.width*0.5, awardBgSize.height*0.12)
    :addTo(awardBg)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确 定", size = 28,color = cc.c3b(94, 229, 101)}))
    :onButtonClicked(function()
        _handler()
    end)
    -- display.newSprite("Battle/Settlement/hdbirs_d02-03.png")
    -- :pos(awardBgSize.width*0.5, awardBgSize.height*0.12)
    -- :addTo(awardBg)
end

function SettlementLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11309 ==_guideId or 10106 ==_guideId or 11211 ==_guideId or 10206 ==_guideId or 10509 ==_guideId 
        or 11109 ==_guideId or 10706 ==_guideId or 11606 ==_guideId then
        g_node = curGuideBtn
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

function SettlementLayer:addAllstarReward()
    local lclvalue = blockData[block_idx]
    print(lclvalue.starReward)
    print(lclvalue.starReward~=0)
    print(BattleStar==3)
    print(BattleStar>g_fightBlockStar)
    print(g_fightBlockStar)
    if lclvalue.starReward~="null" and lclvalue.starReward~=0 and
            BattleStar==3 and BattleStar>g_fightBlockStar then
        local starRewards = lua_string_split(lclvalue.starReward, "|")
        -- printTable(starRewards)
        local curRewards = {}
        printTable(starRewards)
        for i=1,#starRewards do
            print(i)
            local reward = lua_string_split(starRewards[i], "#")
            table.insert(curRewards, {templateID=tonumber(reward[1]), num=tonumber(reward[2])})
        end
        -- printTable(curRewards)

        self:performWithDelay(function ()
            GlobalShowGainBox(nil, curRewards, 2)
            end,1.0)
        
    end
end
--该关卡是否触发支线任务
function SettlementLayer:isTriggerBranch()
    g_TriggerBranchId = 0
    for i,id in pairs(g_branchTriggerBlockId) do
        if tonumber(id)== block_idx then
            if g_fightBlockStar<=0 and BattleStar>0 then
                g_TriggerBranchId = i
            end
            break
        end
    end
end

return SettlementLayer