-- @Author: anchen
-- @Date:   2015-08-31 13:10:30
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-06-27 18:56:38
bounty = class("bounty",function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)
bounty.Instance = nil
--记录返回
g_click_idx = nil
g_click_value = nil
local firstUnrewardIdx = 0 --第一个未领取的赏金首

local bossPos = {
    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(110, -320),
    cc.p(110, -320),

    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(160, -250),
    cc.p(160, -250),

    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(0, -300),
    cc.p(0, -300),

    cc.p(0, -300),
    cc.p(0, -300),
}
function bounty:ctor()
    bounty.Instance = self
    setIgonreLayerShow(true)
    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    self.bountyInfoData = nil
    self.isEnterDes = false --是否是否进入详细面板
    
    self:initBountyList()
    self:initBountyDesBox()
    
end
function bounty:setBoxVisible(type)
    if type==1 then
        self.bountyBox:setVisible(true)
        self.bountyDesBox:setVisible(false)
    else
        self.bountyBox:setVisible(false)
        self.bountyDesBox:setVisible(true)
    end
end
function bounty:initBountyList()
    --大框
    self.bountyBox = display.newScale9Sprite("common2/com2_Img_22.png",nil,nil,cc.size(1100,556))
    :addTo(self)
    :pos(display.cx, display.cy-30)
    local boxsize = self.bountyBox:getContentSize()


    --title
    local titlebar = display.newSprite("bounty/bounty2_img5.png")
    :addTo(self.bountyBox)
    :pos(boxsize.width/2, boxsize.height-10)

    display.newSprite("bounty/bounty2_img12.png")
    :addTo(titlebar)
    :pos(titlebar:getContentSize().width/2, titlebar:getContentSize().height/2)

    --关闭按钮
    self.closeBtn1 = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self)
    :align(display.TOP_LEFT, 0, display.height)
    :onButtonClicked(function(event)
        if self.isEnterDes then
            self:setBoxVisible(1)
            -- GuideManager:_addGuide_2(20505, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            self.isEnterDes = false
        else
            GuideManager:removeGuideLayer()
            self:removeSelf()
            local _scene = cc.Director:getInstance():getRunningScene()
            MainSceneEnterType = 0
        end
        
        end)

    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 30, 1050, 440),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(self.bountyBox)
end
function bounty:getBountyBossData()
    --获取每个大区的bossId
    local blockIds = {}
    for i,value in pairs(blockData) do
        table.insert(blockIds, value.id)
    end
    local tmpBlockData = getSortBlocksData(blockIds)
    local bossDataList = {}
    for i,value in pairs(tmpBlockData) do
        if value.isBounty~=0 then
            local tmpdata = value
            tmpdata.status = 0
            table.insert(bossDataList,tmpdata)
        end
    end
    --修改赏金首领取状态
    for i,value in ipairs(self.bountyInfoData.freeBty) do
        for j,val in ipairs(bossDataList) do
            if value==val.id then
                bossDataList[j].status = 1
            end
        end
        
    end
    for i,value in ipairs(self.bountyInfoData.gotBty) do
        for j,val in ipairs(bossDataList) do
            if value==val.id then
                bossDataList[j].status = 2
            end
        end
    end

    return bossDataList
end
function bounty:reloadBountyListView()
    self.isred = false
    firstUnrewardIdx=0

    self:performWithDelay(function ()
    self.lv:removeAllItems()
    self.bossDataList = self:getBountyBossData()
    for i=1,math.ceil(#self.bossDataList) do
        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(300, 440)
        self.lv:addItem(item)

        -- for j=1,3 do
            local idx = i
            if self.bossDataList[idx]==nil then
                break
            end
            local blockValue = self.bossDataList[idx]
            local value = areaData[blockValue.areaId]
            -- local maxAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
            -- print(value.bossId)   
            -- local clippingRect = display.newClippingRectangleNode(cc.rect(-289/2, -431/2,289,431))
            --     :addTo(content)
            --item按钮
            local bossBt = cc.ui.UIPushButton.new("bounty/bounty2_img2.png")
            :addTo(content)
            :pos(0, 0)
            :onButtonPressed(function(event)
                event.target:setScale(0.98)
                end)
            :onButtonRelease(function(event)
                event.target:setScale(1.0)
                end)
            :onButtonClicked(function(event)
                print("11111111")
                --记录返回
                g_click_idx = idx
                g_click_value = value

                self.curValueIdx = idx
                self.curBlockValue = blockValue
                self:setBoxVisible(2)
                print("2222222")
                self:BountyDesData(value)
                print("3333333333")
                
                if self.curBlockValue.status==2 and GuideManager.NextLocalStep == 20403 then
                    GuideManager:sendConditionForce(0)
                    GuideManager:removeGuideLayer()
                else
                    GuideManager:_addGuide_2(20403, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                end
                if self.curBlockValue.status==2 and GuideManager.NextLocalStep == 11203 then
                    GuideManager:forceSendFinishStep(-1,true)
                    GuideManager:removeGuideLayer()
                else
                    GuideManager:_addGuide_2(11203, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                end
                print("44444444444")
                -- GuideManager:_addGuide_2(20503, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                self.isEnterDes = true
                end)
            if idx==2 and GuideManager.NextLocalStep==20402 then
                self.guideBtn1 = bossBt
                GuideManager:_addGuide_2(20402, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                -- GuideManager:_addGuide_2(20502, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            elseif idx==1 and GuideManager.NextStep==11202 then
                self.guideBtn1 = bossBt
                GuideManager:_addGuide_2(11202, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            end
            bossBt:setTouchSwallowEnabled(false)
            -- bossBt:setVisible(false)

            if value.status==2 then
                display.newSprite("bounty/bounty_img15.png")
                :addTo(bossBt,2)
                :pos(40,-30)
            end

            if not canAreaEnter(value.id, 1) or srv_userInfo.level < areaData[value.id].level then
                -- bossBt:setButtonEnabled(false)
                display.newSprite("bounty/bounty2_img3.png")
                :addTo(bossBt)
                :pos(0, 0)

                display.newSprite("bounty/bounty2_img3.png")
                :addTo(bossBt)
                :pos(0, -175)
                :scale(0.2)

                self.isred = true
            else
                --boss头像
                -- local clippingRect2 = display.newClippingRectangleNode(cc.rect(-108, -135,217,400))
                -- :addTo(content)

                local bossId
                if blockValue.type==1 then
                    bossId = value.bossId
                elseif blockValue.type==2 then
                    bossId = value.bossId2
                end

                local resName =  monsterData[bossId].resId
                local boss = display.newSprite("monster/boss_"..resName..".png")
                :addTo(bossBt)
                :align(display.CENTER, 0, 0)

                --boss名字
                local bossName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(201, 196, 184)})
                :addTo(bossBt)
                :align(display.CENTER, 0, -175)
                if blockValue.type==1 then
                    bossName:setString(monsterData[value.bossId].name)
                elseif blockValue.type==2 then
                    bossName:setString(monsterData[value.bossId2].name)
                end
                

                if blockValue.status==2 then
                    -- local clippingRect3 = display.newClippingRectangleNode(cc.rect(-289/2, -431/2,289,431))
                    -- :addTo(content)

                    display.newSprite("bounty/bounty2_img6.png")
                    :addTo(bossBt)
                    :pos(0, 160)
                    --铁链子
                    display.newSprite("bounty/bounty2_img1.png")
                    :addTo(bossBt)
                    :pos(2, -70)
                    :setRotation(34)

                    display.newSprite("bounty/bounty2_img1.png")
                    :addTo(bossBt)
                    :pos(2, -70)
                    :setRotation(-34)
                else
                    if firstUnrewardIdx==0 then
                        firstUnrewardIdx = idx
                    end
                end
                
            end

            
        -- end
    end

    self.lv:reload()

    print("firstUnrewardIdx"..firstUnrewardIdx)
    if firstUnrewardIdx==0 then firstUnrewardIdx=1 end
    if firstUnrewardIdx>(#self.bossDataList-4) then
        firstUnrewardIdx = #self.bossDataList-4
    end
    
    local curBigStep = tonumber(string.sub(tostring(GuideManager.NextLocalStep), 1,3))
    print("curBigStep",curBigStep)
    if curBigStep~=204 then
        self.lv:setContentPos(-300*(firstUnrewardIdx-1), 0, true)
    end
    end,0.01)
end

function bounty:initBountyDesBox()
    --大框
    self.bountyDesBox = display.newSprite("bounty/bounty2_img7.png")
    :addTo(self)
    :pos(display.cx, display.cy-30)
    self.bountyDesBox:setVisible(false)
    local boxsize = self.bountyDesBox:getContentSize()

    --名字
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 35, color = cc.c3b(178, 8, 8)})
    :addTo(self.bountyDesBox)
    :align(display.CENTER, boxsize.width/2 + 210, boxsize.height-170)
    self.Bossname = label

    self.BossNameLeft = display.newSprite("bounty/bounty2_img11.png")
    :addTo(self.bountyDesBox)
    self.BossNameLeft:pos(label:getPositionX()- (label:getContentSize().width/2 + 20), label:getPositionY())

    self.BossNameRight = display.newSprite("bounty/bounty2_img11.png")
    :addTo(self.bountyDesBox)
    :pos(label:getPositionX()+ (label:getContentSize().width/2 + 20), label:getPositionY())
    self.BossNameRight:setScaleX(-1)

    --描述
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28, color = display.COLOR_BLACK})
    :addTo(self.bountyDesBox)
    :align(display.LEFT_TOP, boxsize.width/2 + 40, boxsize.height-200)
    -- label:setString(locBossData.des)
    label:setWidth(340)
    self.bossDes = label

    --悬赏金
    display.newSprite("bounty/bounty2_img9.png")
    :addTo(self.bountyDesBox)
    :pos(boxsize.width/2 + 100, boxsize.height/2-60)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(self.bountyDesBox)
    :pos(boxsize.width/2 + 290, boxsize.height/2-60)
    :setScaleX(0.9)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(self.bountyDesBox)
    :pos(boxsize.width/2 - 270, 60)

    display.newSprite("bounty/bounty2_img10.png")
    :addTo(self.bountyDesBox)
    :pos(boxsize.width/2 + 270, 60)

    self.getBt = cc.ui.UIPushButton.new({
        normal = "bounty/bounty2_img8.png",
        pressed = "bounty/bounty2_img8.png",
        disabled = "bounty/bounty2_img14.png"})
    :addTo(self.bountyDesBox)
    :pos(boxsize.width/2 , 60)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if self.curBlockValue.status==0 then --前往
            if self.curBlockValue.type==2 and srv_userInfo.level<14 then
                showTips("14级开放精英副本")
                return
            -- elseif srv_userInfo.maxEBlockId%1000000<1005 then
            --     showTips("暂未开放")
            --     return
            elseif not canAreaEnter(self.curValue.id, self.curBlockValue.type) then
                showTips("该大区精英副本未开启")
                return
            end
            if GuideManager.NextLocalStep == 11112 then
                GuideManager:sendConditionForce(0)
            end
            MainSceneEnterType = EnterTypeList.BOUNTY_ENTER
            local areamap = g_blockMap.new(self.curValue.id, self.curBlockValue.id, nil, true)
            areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
            
        elseif self.curBlockValue.status==1 then --领取
            startLoading()
            BarMgr:ReqSubmitTask(self.curBlockValue.id)
        end
    end)

    

    --左箭头
    self.leftjt = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self.bountyDesBox)
    :pos(-100, boxsize.height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1)
        end)
    :onButtonClicked(function(event)
        local idx
        if self.curValueIdx==1 then
            idx = #self.bossDataList
        else
            idx = self.curValueIdx - 1
        end
        
        self.curValueIdx = idx
        self.curBlockValue = self.bossDataList[idx]
        local tmp = areaData[self.bossDataList[idx].areaId]
        g_click_value = tmp
        self:BountyDesData(tmp)
        end)

    --右箭头
    self.rightjt = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self.bountyDesBox)
    :pos(100+boxsize.width, boxsize.height/2)
    :scale(-1)
    :onButtonPressed(function(event)
        event.target:setScale(-0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(-1)
        end)
    :onButtonClicked(function(event)
        local idx
        if self.curValueIdx== #self.bossDataList then
            idx = 1
        else
            idx = self.curValueIdx +1
        end
        -- print(idx)
        -- print(#self.bossDataList)
        -- local maxAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
        -- if not canAreaEnter(value.id, 2) or srv_userInfo.level < areaData[value.id].level then
        --     return
        -- end
        self.curValueIdx = idx
        self.curBlockValue = self.bossDataList[idx]
        local tmp = areaData[self.bossDataList[idx].areaId]
        g_click_value = tmp
        self:BountyDesData(tmp)
        end)

end

function bounty:BountyDesData(value)
    -- self.bossBody:setTexture(value)
    printTable(value)
    print("2.11111111111111111")
    self.bossDataList = self:getBountyBossData()
    self.curValue = value
    if self.boss then
        self.boss:removeSelf()
    end
    print("2.22222222222")
    printTable(value)
    --boss模型
    local bossId
    if self.bossDataList[self.curValueIdx].type==1 then
        bossId = value.bossId
    elseif self.bossDataList[self.curValueIdx].type==2 then
        bossId = value.bossId2
    end

    local resName = monsterData[bossId].resId
    
    local dx = 260
    if bossId==21014008 or bossId==61014008 then
        dx = 340
    end

    print("2.3333333333")
    if monsterData[bossId].actType==1 then --cocos动画
        print("aaaaaaaaaaa")
        local manager = ccs.ArmatureDataManager:getInstance()
        manager:removeArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        -- print(resName)
        manager:addArmatureFileInfo("Battle/Monster/Monster_"..resName.."_.ExportJson")
        self.boss = ccs.Armature:create("Monster_"..resName.."_")
        :addTo(self.bountyDesBox)
        :pos(dx,self.bountyDesBox:getContentSize().height/2)
        :scale(value.bossScale)
        self.boss:setAnchorPoint(0.5,0.5)
        self.boss:getAnimation():play("Standby")
        self.boss:getAnimation():gotoAndPlay(0)
    else
        print("bbbbbbbbbbbb")
        self.boss = sp.SkeletonAnimation:create("Battle/Monster/Monster_"..resName.."_.json","Battle/Monster/Monster_"..resName.."_.atlas",1)
        print("ccccccccccc")
        self.boss:addTo(self.bountyDesBox)
        print("ddddddddd")
        self.boss:pos(dx,self.bountyDesBox:getContentSize().height/2-100)
        print("eeeeeeeeeee")
        self.boss:scale(value.bossScale)
        print("fffffffffffff")
        -- self.boss:setAnchorPoint(0.5,0.5)
        self.boss:setAnimation(0, "Standby", true)
    end
    print("2.444444444444")
    


    local locBossData = monsterData[bossId]
    self.Bossname:setString(locBossData.name)
    self.BossNameLeft:pos(self.Bossname:getPositionX()- (self.Bossname:getContentSize().width/2 + 20), self.Bossname:getPositionY())
    self.BossNameRight:pos(self.Bossname:getPositionX()+ (self.Bossname:getContentSize().width/2 + 20), self.Bossname:getPositionY())
    self.bossDes:setString(value.des)


    local dx = 460
    local dy = 50
    local rewardsPos = {
    cc.p(100+dx,95+dy),
    cc.p(180+dx,95+dy),
    cc.p(260+dx,95+dy),
    cc.p(340+dx,95+dy),
    }
    if self.rewardsIcon then
        for i=1,#self.rewardsIcon do
            self.rewardsIcon[i]:removeSelf()
        end
    end
    self.rewardsIcon = {}
    local rewardIdx = 0

    local valueBounty
    if self.bossDataList[self.curValueIdx].type==1 then
        valueBounty = value.bounty
    elseif self.bossDataList[self.curValueIdx].type==2 then
        valueBounty = value.bounty2
    end
    local rewards = string.split(valueBounty, "|")
    --物品
    local items = string.split(rewards[1], ";")
    --金币
    local golds = tonumber(rewards[2]) 
    --钻石
    local diamond = tonumber(rewards[3])
    if golds>0 then
        rewardIdx = rewardIdx + 1
        self.rewardsIcon[rewardIdx] = GlobalGetSpecialItemIcon(GAINBOXTPLID_GOLD, golds,0.7)
        :addTo(self.bountyDesBox)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
    end
    if diamond>0 then
        rewardIdx = rewardIdx + 1
        self.rewardsIcon[rewardIdx] = GlobalGetSpecialItemIcon(GAINBOXTPLID_DIAMOND, diamond, 0.7)
        :addTo(self.bountyDesBox)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
    end
    for i=1,#items do
        rewardIdx = rewardIdx + 1
        local item = string.split(items[i], "#")
        -- printTable(item)
        self.rewardsIcon[rewardIdx] = createItemIcon(item[1],item[2])
        :addTo(self.bountyDesBox)
        :scale(0.6)
        :pos(rewardsPos[rewardIdx].x, rewardsPos[rewardIdx].y)
    end
    
    --领取按钮
    self.getBt:setScale(1.0)
    if self.curBlockValue.status==2 then
        -- print("aaaaaa")
        self.getBt:setButtonEnabled(false)
        -- self.getBt:setButtonImage("normal", "bounty/bounty2_img14.png")
        -- self.getBt:setButtonImage("pressed", "bounty/bounty2_img14.png")
    else
        -- print("bbbb")
        self.getBt:setButtonEnabled(true)
        if self.curBlockValue.status==1 and canAreaEnter(self.curValue.id, self.curBlockValue.type) then
            self.getBt:setButtonImage("normal", "bounty/bounty2_img13.png")
            self.getBt:setButtonImage("pressed", "bounty/bounty2_img13.png")
        elseif self.curBlockValue.status==0 then
            self.getBt:setButtonImage("normal", "bounty/bounty2_img8.png")
            self.getBt:setButtonImage("pressed", "bounty/bounty2_img8.png")
        end
    end

    --左箭头
    local idx
    if self.curValueIdx==1 then
        idx = #self.bossDataList
    else
        idx = self.curValueIdx -1
    end
    local maxAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
    if not canAreaEnter(self.bossDataList[idx].areaId, 1) or 
        srv_userInfo.level < areaData[self.bossDataList[idx].areaId].level then
        self.leftjt:setVisible(false)
    else
        self.leftjt:setVisible(true)
    end
    --右箭头
    local idx
    if self.curValueIdx==#self.bossDataList then
        idx = 1
    else
        idx = self.curValueIdx +1
    end
    local maxAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
    if not canAreaEnter(self.bossDataList[idx].areaId, 1) or 
        srv_userInfo.level < areaData[self.bossDataList[idx].areaId].level then
        self.rightjt:setVisible(false)
    else
        self.rightjt:setVisible(true)
    end
end

function bounty:onEnter()
    setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
    
    startLoading()
    BarMgr:ReqInitInfo()
end
function bounty:onExit()
    bounty.Instance = nil
end
--获取赏金首
function bounty:OnInitInfoRet(cmd)
    endLoading()
    if cmd.result==1 then
        self.bountyInfoData = cmd.data
        self:reloadBountyListView()
        self:setBoxVisible(1)
        if MainSceneEnterType == EnterTypeList.BOUNTY_ENTER then
            --打开赏金首详细信息
            self.isEnterDes = true
            self.curValueIdx = g_click_idx
            self:setBoxVisible(2)

            self.bossDataList = self:getBountyBossData()
            self.curBlockValue = self.bossDataList[self.curValueIdx]

            self:BountyDesData(g_click_value)
            
        end
    else
        showTips(cmd.msg)
    end
end
--领取赏金首
function bounty:OnSubmitTaskRet(cmd)
    endLoading()
    if cmd.result==1 then

        -- GuideManager:_addGuide_2(20504, display.getRunningScene(),handler(self,self.caculateGuidePos))
        --删除这条可领取信息
        for i,value in ipairs(self.bountyInfoData.freeBty) do
            if value==self.curBlockValue.id then
                table.remove(self.bountyInfoData.freeBty, i)
                break
            end
        end
        --添加到已领取信息中
        table.insert(self.bountyInfoData.gotBty, self.curBlockValue.id)
        
        self:reloadBountyListView()
        self.getBt:setButtonEnabled(false)

        --弹窗显示获得物品
        self.rewardsIcon = {}
        local rewardIdx = 0
        local valueBounty
        if self.bossDataList[self.curValueIdx].type==1 then
            valueBounty = self.curValue.bounty
        elseif self.bossDataList[self.curValueIdx].type==2 then
            valueBounty = self.curValue.bounty2
        end
        local rewards = string.split(valueBounty, "|")
        --物品
        local items = string.split(rewards[1], ";")
        --金币
        local golds = tonumber(rewards[2]) 
        --钻石
        local diamond = tonumber(rewards[3])
        local curRewards = {}
        if golds>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=golds})
        end
        if diamond>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=diamond})
        end
        for i=1,#items do
            local item = lua_string_split(items[i],"#")
            table.insert(curRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
            local dc_item = itemData[tonumber(item[1])]
            DCItem.get(tostring(dc_item.id), dc_item.name, tonumber(item[2]), "领取赏金首")
        end
        DCCoin.gain("领取赏金首","金币",golds,srv_userInfo.gold+golds)
        GlobalShowGainBox(nil, curRewards)

        --是否移除小红点
        if self.isred then
            local node = display.getRunningScene().activityMenuBar.bountyBt
            node:removeChildByTag(10)
        end
    else
        showTips(cmd.msg)
    end
end

function bounty:caculateGuidePos(_guideId)
    print("指引id:------------------- ".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 20402==_guideId or 20403==_guideId or 20502==_guideId or 20503==_guideId or 20504==_guideId or 20505==_guideId 
        or 11202==_guideId or 11203==_guideId then
        if 20402==_guideId or 20502==_guideId or 11202==_guideId then
            print("----=-=-==-=-20402   ii")
            g_node = self.guideBtn1
        elseif 20403==_guideId or 20503==_guideId or 11203==_guideId then
            print("----=-=-==-=-20403   ii")
            g_node = self.getBt
        elseif 20504==_guideId or 20505==_guideId then
            g_node = self.closeBtn1
        end
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 20504==_guideId or 20505==_guideId then
            midPos = g_node:convertToWorldSpace(cc.p(size.width/2,-size.height/2))
        end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return bounty