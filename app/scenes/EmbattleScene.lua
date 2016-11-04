--
-- Author: Jun Jiang
-- Date: 2014-11-13 17:54:06
--
-----------------------常量/宏定义----------------------------

--------------------------------------------------------------

local function GetBltSprName(name,tag)
    local tabName = {
        [1] = "普通弹",
        [2] = "冰霜弹",
        [3] = "电磁弹",
        [4] = "烟幕弹",
        [5] = "强酸弹",
        [6] = "燃烧弹",
        [7] = "脱力弹",
        [8] = "破甲弹",
        [9] = "定位弹",
    }
    tag = tag or nil
    local sprName = nil
    for i=1, #tabName do
        if tabName[i]==name then
            sprName = string.format("blt_%d.png", i)
            if(tag~=nil) then
                sprName = tag..sprName
            end
        end
    end

    return sprName
end

local function getRentCost(carInfo)
    local index,cost = 0,0
    if carInfo.record==nil or carInfo.record==0 then
        return 1,math.ceil(carInfo.strength*5.2)
    elseif carInfo.record==1 then
        return 2,30
    elseif carInfo.record==2 then
        return 2,50
    end
    return index,cost
end

EmbattleScene = class("EmbattleScene",function()
	local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)
EmbattleScene.Instance      = nil       --实例
EmbattleScene.curSelSlot    = nil       --当前选择弹仓
EmbattleScene.sortList      = nil       --排序列表
EmbattleScene.args          = nil       --{}（布阵类型、关卡ID/敌方ID）

local currentBtn = nil

function EmbattleScene:ctor(params)
    setIgonreLayerShow(true)
    EmbattleScene.Instance = self
    RentMgr:Resort()
    
    self.args = params or {}
    self:CheckHidePull()

    local tmpNode, tmpSize

    --资源加载
    display.addSpriteFrames("Image/UIEmbattle.plist", "Image/UIEmbattle.png")

    --背景
    local sprBg = display.newSprite("BgImg/bg_Garage.png")
                    :align(display.CENTER, display.cx, display.cy)
                    :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height)
        :addTo(self, 1)
        :onButtonClicked(function(event)
            if EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
                showMessageBox("挑战次数已经扣除，是否退出？",function ()
                    self:removeFromParent()
                    worldBossInstance:resetMyInfo()
                end)
            else
                if block_idx and blockData[block_idx].type==3 then
                    startLoading()
                    comData={}
                    comData["areaId"]= srv_userInfo.areaId
                    m_socket:SendRequest(json.encode(comData), CMD_UNLOCK_LEGION)
                end
                self:removeFromParent()
                g_WarriorsCenterMgr.step=-1
            end
            if IsFightAgain then --再次战斗直接打开布阵界面，没有关卡界面，返回时要打开
                IsFightAgain = false
                toAreaId = blockIdtoAreaId(curFightBlockId)
                areamap = g_blockMap.new(toAreaId, curFightBlockId)
                areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)

                -- BlockUI.new(block_idx,srv_blockData)
                -- :addTo(display.getRunningScene(),51)
            end
            -- reloadLuaFile("app.scenes.EmbattleScene")
            -- reloadLuaFile("app.logic.EmbattleMgr")
            -- g_laserCannon = reloadLuaFile("app.scenes.LaserCannon")
        end)

    local _size = cc.size(680,220)
    if self.bHidePull then
        _size = cc.size(520,220)
    end
    --主战面板
    local mainBattlePanel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,_size,cc.rect(123,120,42,18))
                                :align(display.BOTTOM_RIGHT, display.width-5, -30)
                                :addTo(self, 1)
    self.mainBattlePanel = mainBattlePanel
    display.newSprite("#Embattle_Img30.png")
                :addTo(mainBattlePanel)
                :align(display.CENTER_BOTTOM,10,30)
    display.newSprite("#Embattle_Img30.png")
                :addTo(mainBattlePanel)
                :align(display.CENTER_BOTTOM,_size.width-10,30)
                :setScaleX(-1)

    self.myTeamerList = cc.ui.UIListView.new{
                    -- bgColor = cc.c4b(255,0,0,100),
                    viewRect = cc.rect(35, 43-20, _size.width-77, 133+50),
                    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
                }
                :addTo(mainBattlePanel)
    

    --主战面板标题
    tmpSize = mainBattlePanel:getContentSize()
    tmpNode = display.newSprite("#Embattle_Img29.png")
                :align(display.CENTER, tmpSize.width/2, tmpSize.height+10)
                :addTo(mainBattlePanel)
    local text = "战车关卡"
    if block_idx and tonumber(string.sub(block_idx, 2, 2))==1 then
        text = "人物关卡"
    end
    if g_WarriorsCenterMgr.step==0 then
        text = "人物关卡"
    elseif g_WarriorsCenterMgr.step==1 then
        text = "战车关卡"
    end
    display.newTTFLabel{text = text,size = 33,color = cc.c3b(155,214,242)}
                :align(display.CENTER, tmpSize.width/2, tmpSize.height+3)
                :addTo(mainBattlePanel)

    --左面板（好友、军号）
    tmpSize = mainBattlePanel:getContentSize()

    local lPanel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(226,170+330),cc.rect(122,46,29,7))
                        :align(display.BOTTOM_RIGHT, display.width-tmpSize.width, -330)
                        :addTo(self)
    self.lPanel = lPanel
    tmpSize = lPanel:getContentSize()
    
    self.leftPP = display.newSprite("#Embattle_Img40.png")
        :align(display.RIGHT_BOTTOM, 2, 330)
        :addTo(lPanel)

    --牵引一按钮
    local pullBtn1 = cc.ui.UIPushButton.new{normal = "#Embattle_Img38.png"}
        :pos(tmpSize.width/2,tmpSize.height-90)
        :addTo(lPanel)
        :onButtonPressed(function(event)
            event.target:setScale(0.985)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function(event)
            if EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
                showTips("世界boss不能租车")
                return
            end
            if EmbattleMgr.nCurBattleType == BattleType_PVP or EmbattleMgr.nCurBattleType == BattleType_PVP_DEF then
                -- showTips("竞技场不能租车")
                --技能预设
                g_skillPreset.new(self.sortList)
                :addTo(self,100)
                return
            end
            if srv_userInfo.level<1 then
                showTips("战队升级1级开放")
                return
            end
            if GuideManager:checkOpenFunction(GuideManager.needCheck.rentcar) then
                showTips("暂未开放")
                return
            end

            if EmbattleMgr:isMatrixIsFull() then
                -- showTips("阵位已满，不能租车")
                -- return
            end
            if false==self.bHidePull then
                if g_CarListLayer.Instance~=nil then
                    return
                end
                RentMgr:ReqRentCarList(function ()
                    self.sortList.canRentCars = {}
                    for i=1, #RentMgr.sortList do
                        self.sortList.canRentCars[i] = RentMgr.sortList[i]--可以租的车
                    end
                    local carList = g_CarListLayer.new({openTag=OpenBy_Embattle, idList=self.sortList.canRentCars})
                                :addTo(self, 90)
                    GuideManager:_addGuide_2(11208, cc.Director:getInstance():getRunningScene(),handler(carList,carList.caculateGuidePos))
                end)
                
            end
        end)
    self.pullBtn1 = pullBtn1

    self.sprImg = display.newTTFLabel{text = "",size = 40,color = cc.c3b(161,251,255)}
                :addTo(pullBtn1)


    --牵引一头像
    self.sprPull = {}
    self.sprPull[1] = display.newSprite()
                        :align(display.CENTER, tmpSize.width/2-80, tmpSize.height-100)
                        :addTo(lPanel,5)

        

    --牵引二头像
    self.sprPull[2] = display.newSprite()
                        :align(display.CENTER, tmpSize.width/2+80, tmpSize.height-100)
                        :addTo(lPanel,5)

     local fpBg = display.newSprite("#Embattle_Img28.png")
        :align(display.RIGHT_TOP,display.width-100,display.height)
        :addTo(self)
    --战力
    display.newSprite("common2/com_strengthTag.png")
        :scale(1.2)
        :align(display.LEFT_CENTER,40,fpBg:getContentSize().height/2)
        :addTo(fpBg,10)
    self.labFp = cc.LabelAtlas:_create()
                    :align(display.LEFT_CENTER, 80, fpBg:getContentSize().height/2)
                    :addTo(fpBg)
    self.labFp:initWithString("0",
        "common/common_Num2.png",
        27.3,
        39,
        string.byte(0))

    if (g_WarriorsCenterMgr.step==0 or g_WarriorsCenterMgr.step==1) then
        local tabBg = display.newSprite("#Embattle_Img23.png")
            :align(display.CENTER_TOP,display.width/2,display.height)
            :addTo(self)
        local tab_1 = display.newSprite("#Embattle_Img25.png")
            :align(display.RIGHT_TOP,display.width/2-10,display.height)
            :addTo(self)
        local tab_2 = display.newSprite("#Embattle_Img26.png")
            :align(display.LEFT_TOP,display.width/2+10,display.height)
            :addTo(self)
        if g_WarriorsCenterMgr.step==0 then
            tab_1:setSpriteFrame("Embattle_Img24.png")
        end
        if g_WarriorsCenterMgr.step==1 then
            tab_2:setSpriteFrame("Embattle_Img27.png")
        end
    end

    --三个特种弹
    self.magazinePanel = display.newScale9Sprite("#Embattle_Img33.png", 0, 0, cc.size(323, 92), cc.rect(25, 25, 60, 60))
                        :align(display.LEFT_BOTTOM, 30, 20)
                        :addTo(self, 2)

    --特种弹列表标题
    tmpSize = self.magazinePanel:getContentSize()
    

    --弹槽
    local function SlotOnClick(event)
        local nTag = event.target:getTag()
        
        if nil==EmbattleMgr.curInfo then
            return
        end
        local key = "bullet" .. nTag
        ---[[
        if -1==EmbattleMgr.curInfo.matrix[key] then
            --showTips("槽位未开启")
            local viplevel = srv_userInfo.vip
            print("当前VIP等级："..viplevel)
            if nTag==2 then 
                if viplevel<2 then
                    showTips("需要达到VIP2才能开启")
                else
                    showMessageBox("是否开启弹仓2？", function()
                                    EmbattleMgr:ReqUnlockSlot(2)
                                    startLoading()
                                end)
                end
            elseif nTag==3 then
                if viplevel<8 then
                    showTips("需要达到VIP8才能开启")
                else
                    showMessageBox("是否花费500钻石开启弹仓3？", function()
                                    EmbattleMgr:ReqUnlockSlot(3)
                                    startLoading()
                                end)
                end
            end
            return
        end
        --]]
        local oldSel = self.curSelSlot
        self.curSelSlot = nTag
        if nil==oldSel then
            setIgonreLayerShow(true)
            self:performWithDelay(function()
                self:InitBulletList()
                self:ShowOrHideBltList(1, true)
                GuideManager:_addGuide_2(10506, display.getRunningScene(),handler(self,self.caculateGuidePos))
                setIgonreLayerShow(false)
            end, 0.1)
        elseif  oldSel==self.curSelSlot then
            self:ShowOrHideBltList(2, true)
            self.curSelSlot = nil
        end
        self:SetSlotState()
    end
    tmpSize = self.magazinePanel:getContentSize()
    
    self.slotItem = {}
    for i=1, BULLETSLOTNUM do
        local ptX = {51,165,269}
        self.slotItem[i] = {}
        --按钮
        self.slotItem[i].btn = cc.ui.UIPushButton.new({normal="#Embattle_Img35.png"})
                                    :align(display.CENTER, ptX[i], 32)
                                    :addTo(self.magazinePanel)
                                    :onButtonClicked(SlotOnClick)
        self.slotItem[i].btn:setTag(i)
        self.slotItem[i].btn:setPositionY(22+self.slotItem[i].btn.sprite_[1]:getContentSize().height/2)

        
        --库存
        self.slotItem[i].inventory = display.newTTFLabel({text="x10", size=18, color=cc.c3b(213, 204, 174)})
                :align(display.CENTER_BOTTOM, ptX[i], 22)
                :addTo(self.magazinePanel)
    end


    --特种弹列表面板
    --345
    self.bltListPanel = display.newScale9Sprite("#Embattle_frame12.png", 0, 0, cc.size(456+100, 352), cc.rect(30, 30, 260, 30))
                        :align(display.LEFT_CENTER, 0, display.cy+150)
                        :addTo(self, 1)
    tmpSize = self.bltListPanel:getContentSize()

   
    self.bltLPCBtn = cc.ui.UIPushButton.new({normal="common2/com2_Btn_2_up.png", pressed="common2/com2_Btn_2_down.png"})
                        :scale(0.7)
                        :align(display.CENTER, tmpSize.width-3, tmpSize.height+10)
                        :addTo(self.bltListPanel, 1)
                        :hide()
                        :onButtonPressed(function(event)
                            event.target:setScale(0.96*0.7)
                            end)
                        :onButtonRelease(function(event)
                            event.target:setScale(1.0*0.7)
                            end)
                        :onButtonClicked(function(event)
                            self:ShowOrHideBltList(2, true)
                            self.curSelSlot = nil
                            self:SetSlotState()
                        end)

    --特种弹详细信息面板
    self.detailPanel = display.newSprite("#Embattle_Img13.png")
                      :addTo(self,2)
    self.detailPanel:align(display.LEFT_CENTER, display.cx-self.detailPanel:getContentSize().width-50, tmpSize.height+display.cy)


                    
    self.detailPanel:setVisible(false)

    --特种弹描述
    tmpSize = self.detailPanel:getContentSize()
    self.labDetails = display.newTTFLabel({
                        text="",
                        size=22,
                        color=cc.c3b(186, 217, 212),
                        align = cc.TEXT_ALIGNMENT_CENTER,
                        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                        dimensions = cc.size(240, 110),
                    })
                    :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
                    :addTo(self.detailPanel)

    --特种弹列表
    self.bltList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 60),
        viewRect = cc.rect(15+100, 15, 423, 328),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self.bltListPanel)

    --主战位置框（1、2、3号位）
    self.mainBox = { 
                        {pBox=nil, nPosX=984, nPosY=610+20, z=3},
                        {pBox=nil, nPosX=749, nPosY=683+20, z=0},
                        {pBox=nil, nPosX=714, nPosY=543+20, z=6},
                        {pBox=nil, nPosX=503, nPosY=682+20, z=0},
                        {pBox=nil, nPosX=436, nPosY=545+20, z=3},
                    }

    for i=1, #self.mainBox do
        self.mainBox[i].pBox = display.newNode()
                                :align(display.CENTER, self.mainBox[i].nPosX, self.mainBox[i].nPosY)
                                :addTo(sprBg, self.mainBox[i].z, 10+i)
        self.mainBox[i].pBox:setContentSize(cc.size(220, 200))
    end

    local goPath = "#Embattle_Img2.png"
    local btnPos = cc.p(display.width+50, display.cy+100)
    if self.args[1] == BattleType_PVP_DEF then
        goPath = "#Embattle_Img34.png"
        btnPos.x = display.width-20
        btnPos.y = display.cy-20
    end
    
    --Go按钮
    local btnGo = cc.ui.UIPushButton.new(goPath)
                    :scale(0.8)
                    :align(display.RIGHT_CENTER, btnPos.x,btnPos.y)
                    :addTo(self, 1)
                    :onButtonClicked(function(event)    
                        if EmbattleMgr.nCurBattleType == BattleType_PVE then  --未开放的特种弹提示
                            local BulletInfo = EmbattleMgr.curInfo
                            for i = 1,3 do
                                local bulletid = BulletInfo["matrix"][string.format("bullet%d",i)]
                                if bulletid > -1 then
                                   for j = 1, #BulletInfo["seBlts"] do
                                       if BulletInfo["seBlts"][j]["id"] == bulletid then
                                            if BulletInfo["seBlts"][j]["count"] ~= 0 then
                                                if tonumber(BulletInfo["seBlts"][j]["templateId"]) == 1075007 then
                                                    showTips("您已装上的脱力弹暂未开放，请替换其他特种弹")
                                                    return
                                                end
                                                if tonumber(BulletInfo["seBlts"][j]["templateId"]) == 1075009 then
                                                    showTips("您已装上的定位弹暂未开放，请替换其他特种弹")
                                                    return
                                                end
                                           end
                                       end
                                   end
                               end
                            end
                        end
                        if self.args[1] == BattleType_PVP_DEF then
                            self:setPVPDefMatrix()
                            return
                        end
                        if g_WarriorsCenterMgr.step==0 or g_WarriorsCenterMgr.step==1 then
                            --上传第一次阵型变动，并开始第二次布阵
                            local nRet = EmbattleMgr:CheckFightCondition()
                            if 1==nRet then
                                showMessageBox("布阵信息未初始化")
                                return
                            elseif 2==nRet then
                                showMessageBox("请至少上阵一个单位")
                                return
                            end

                            local prama2 = nil
                            if self._rentInfo~=nil then
                                local str = "租借"
                                local key,rentIdx

                                local car = self._rentInfo
                                if car.driver~=nil then
                                str = str..car.dName.."的座驾"..carData[car.tptId].name.."，\n支付租金:"
                                else
                                    str = "战车"..carData[car.tptId].name.."，\n支付租金:"
                                end
                                local i,v = getRentCost(car)
                                if srv_userInfo.isFirstRent==1 then
                                    v = 0
                                end
                                if i==1 then
                                    str = str .. v .."金币"
                                elseif i==2 then
                                    str = str .. v .."钻石"
                                end
                                local prama2 = {}
                                prama2.renter = car.driver or car.tptId
                                prama2.rentIdx = rentIdx
                                prama2.rCnt = (car.record or 0) +1
                                prama2.rCost = v
                                printTable(prama2)
                                self.msgBox = showMessageBox(str,function()
                                    local modifyMatrix = EmbattleMgr:getModifyMatrix(prama2)
                                    printTable(modifyMatrix)
                                    -- writeTabToLog(modifyMatrix,"上传远征阵形修改,有租车","z001.txt")
                                    g_WarriorsCenterMgr:ReqUpdateExpeditionFormation(modifyMatrix)
                                end)
                                print("有租车1111111111111")
                            else
                                local modifyMatrix = EmbattleMgr:getModifyMatrix(prama2)
                                printTable(modifyMatrix)
                                -- writeTabToLog(modifyMatrix,"上传远征阵形修改,无租车","z001.txt")
                                g_WarriorsCenterMgr:ReqUpdateExpeditionFormation(modifyMatrix)
                                print("无租车22222222222222")
                            end
                            return
                        end
                        local nRet = nil
                        if self._rentInfo~=nil then
                            print("aaaaaaaaaaaaa")
                            local str = "租借"
                            local key,rentIdx
                            
                            local car = self._rentInfo
                            if car.driver~=nil then
                                str = str..car.dName.."的座驾"..carData[car.tptId].name.."，\n支付租金:"
                            else
                                str = "战车"..carData[car.tptId].name.."，\n支付租金:"
                            end
                            local i,v = getRentCost(car)
                            if srv_userInfo.isFirstRent==1 then
                                v = 0
                            end
                            if i==1 then
                                str = str .. v .."金币"
                            elseif i==2 then
                                str = str .. v .."钻石"
                            end
                            -- local prama2 = {}
                            -- prama2.renter = car.driver or car.tptId
                            -- prama2.rentIdx = rentIdx
                            -- prama2.rCnt = (car.record or 0) +1
                            -- prama2.rCost = v
                            self.msgBox = showMessageBox(str,function()
                                GuideManager:hideGuideEff()
                                nRet = EmbattleMgr:ReqFight(self.args[2]) 
                                end,nil,nil,100)
                            GuideManager:_addGuide_2(11210, display.getRunningScene(),handler(self,self.caculateGuidePos),101)
                        else
                            print("bbbbbb")
                            GuideManager:hideGuideEff()
                            nRet = EmbattleMgr:ReqFight(self.args[2]) 
                        end
                        if 0==nRet then
                            startLoading()
                        elseif 1==nRet then
                            showMessageBox("布阵信息未初始化")
                        elseif 2==nRet then
                            showMessageBox("请至少上阵一个单位")
                            return
                        end
                        if self.args[1] == BattleType_WorldBoss then
                            for i=1,#EmbattleMgr.curInfo.members do
                                for j=1,5 do
                                    if EmbattleMgr.curInfo.matrix["main"..j] == EmbattleMgr.curInfo.members[i].id then
                                         EmbattleMgr.curInfo.members[i].memAttr.pos = j
                                         break
                                    end
                                end
                            end
                            CurFightBattleType = FightBattleType.kType_WorldBoss
                            BattleData["members"] = {}
                            BattleData["members"][1] = EmbattleMgr.curInfo.members[1].memAttr
                            BattleData["members"][2] = EmbattleMgr.curInfo.members[2].memAttr
                            BattleData["members"][3] = EmbattleMgr.curInfo.members[3].memAttr
                            
                            BattleData["rewardItems"] = EmbattleMgr.curInfo.rewardItems
                            BattleData["boss"] = EmbattleMgr.curInfo.boss
                            BattleData["fIndex"] = EmbattleMgr.curInfo.fIndex

                            BattleFormatInfo = EmbattleMgr.curInfo
                            app:enterScene("LoadingScene",{SceneType.Type_Battle})
                        end
                    end)

    local action        = cc.MoveBy:create(0.3, cc.p(-50, 0))
    local action_back   = action:reverse()
    local g_sequence = cc.Sequence:create(action, action_back)
    if self.args[1] == BattleType_PVP_DEF then
        g_sequence = transition.sequence({
            cc.FadeTo:create(1,80),
            cc.FadeTo:create(1,255),
        })
    end
    local finalAction   = cc.RepeatForever:create(g_sequence)
    btnGo:runAction(finalAction)
    currentBtn = btnGo

    self:ShowOrHideBltList(2)   --隐藏特种弹列表并设定初始位置，不能去除

    self.isPullTouched = 0     --牵引车位被点击，1表示1号位，2表示2号位，0表示没有被点击
    self._rentInfo = nil  --表示租车信息,nil表示没有租车

    --新手教程
    GuideManager:_addGuide_2(11305, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10105, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10205, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11105, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10505, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11605, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11206, self,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11705, self,handler(self,self.caculateGuidePos))

    self:AdjustUI()

    if BattleType_PVP== self.args[1] or self.args[1] == BattleType_PVP_DEF then
        self.magazinePanel:setVisible(false)
    end
    self:setLocalZOrder(100)
end

function EmbattleScene:setPVPDefMatrix()
    local _PVPDefMatrix = {characterId=srv_userInfo.characterId}
    local nochange = true
    for i=1,5 do
        _PVPDefMatrix["main"..i] = EmbattleMgr.curInfo.matrix["main"..i]
        if _PVPDefMatrix["main"..i]~=-1 and _PVPDefMatrix["main"..i] ~=0 then
            nochange = false
        end
    end
    if nochange then
        showTips("您的防守阵型不能为空")
        return
    end
    self._PVPDefMatrix = _PVPDefMatrix
    m_socket:SendRequest(json.encode(_PVPDefMatrix), CMD_PVP_SETDEFMATRIX, self, self.OnPVPDefMatrixRet)
end

function EmbattleScene:OnPVPDefMatrixRet(cmd)
    if cmd.result==1 then
        showTips("设置防守阵型成功")
        PVPData["strength"] = math.floor(EmbattleMgr:GetStrength())
        PVPData["defmembers"] = {}
        for i=1,5 do
            PVPData["defmatrix"]["main"..tostring(i)] = self._PVPDefMatrix["main"..i]
        end
        for i=1 ,#EmbattleMgr.curInfo.members do
            PVPData["defmembers"][i] = EmbattleMgr.curInfo.members[i]
        end
        -- writeTabToLog(PVPData["defmatrix"],"设置防守阵型成功defmatrix",nil,2)
        -- writeTabToLog(PVPData["defmembers"],"设置防守阵型成功defmembers")
        if PVP_Instance then
            PVP_Instance:refreshMyTeam()
        end
        
        -- printTable(self._PVPDefMatrix)
        -- print("\n\n\n\n\n\n")
        -- printTable(PVPData["defmatrix"])
        self:removeSelf()
    else
        showTips("cmd.msg")
    end
end

--UI调整
function EmbattleScene:AdjustUI()
    --特种弹面板不显示情况
    if BattleType_PVE==self.args[1] then
        --普通或精英关卡,或军团副本
        if 1==blockData[block_idx].type or 2==blockData[block_idx].type then
            local nTag = tonumber(string.sub(tostring(block_idx), 2, 2))
            if self.bHidePull then     --只允许人出战
                self.magazinePanel:setVisible(false)
                self.bltListPanel:setVisible(false)

                self.lPanel:setVisible(false)
                self.leftPP:setVisible(false)
                --添加激光炮
                self.laserCannon = g_laserCannon.new()
                :addTo(self)
            end
        end
    end

    if g_WarriorsCenterMgr.step==0 or g_WarriorsCenterMgr.step==1 then
            -- print(self.bHidePull)
            if self.bHidePull then     --只允许人出战
                self.magazinePanel:setVisible(false)
                self.bltListPanel:setVisible(false)

                self.lPanel:setVisible(false)
                self.leftPP:setVisible(false)
                --添加激光炮
                self.laserCannon = g_laserCannon.new()
                :addTo(self)
            end
    end

    if RelicsLayer and RelicsLayer.Instance then
        if self.bHidePull then     --只允许人出战
            self.magazinePanel:setVisible(false)
            self.bltListPanel:setVisible(false)

            self.lPanel:setVisible(false)
            self.leftPP:setVisible(false)
            --添加激光炮
            self.laserCannon = g_laserCannon.new()
            :addTo(self)
        end
    end

end

--初始化弹仓
function EmbattleScene:InitBulletSlot()
    local nID, key
    for i=1, BULLETSLOTNUM do
        key = "bullet" .. i
        nID = EmbattleMgr.curInfo.matrix[key]
        self:SetSlot(i, nID)
    end
    return true
end

--设置弹仓(单个)
function EmbattleScene:SetSlot(nPos, nID)
    local slot = self.slotItem
    local itemData = LocalGameData:getLocalData(LocalDataType.kDataItem)
    if nil==nID or nil==nPos or nil==slot[nPos] then    --无效位
        return
    end

    local strName = ""
    local strInv = ""
    if -1==nID then     --未开启
        strInv = ""
        local vipName = "#vipUnlock_0"..nPos..".png"
        
        slot[nPos].btn:setButtonImage("normal",vipName)
        slot[nPos].btn:setButtonImage("pressed",vipName)

        slot[nPos].btn:setPositionY(22+slot[nPos].btn.sprite_[1]:getContentSize().height/2 )
        slot[nPos].btn:stopAllActions()
        slot[nPos].btn:setOpacity(255)
    elseif 0==nID then  --已开启，未装备
       
        slot[nPos].btn:setButtonImage("normal","#Embattle_Img35.png")
        slot[nPos].btn:setButtonImage("pressed","#Embattle_Img35.png")

        slot[nPos].btn:setPositionY(22+slot[nPos].btn.sprite_[1]:getContentSize().height/2 )

        local sequence = transition.sequence({
            cc.FadeTo:create(1,50),
            cc.FadeTo:create(1,255),
        })
        slot[nPos].btn:runAction(cc.RepeatForever:create(sequence))
        local selectedImg = self.slotItem[nPos].btn:getChildByTag(3)
        if selectedImg~=nil then
            selectedImg:setContentSize(self.slotItem[nPos].btn.sprite_[1]:getContentSize())
        end
    else                --开启并装备
        if nil~=EmbattleMgr.idKeyList.seBlts[nID] then
            if EmbattleMgr.idKeyList.seBlts[nID].count<0 then
                strInv = "无限"
            else
                strInv = "库存 " .. EmbattleMgr.idKeyList.seBlts[nID].count
            end
            local nTemplateID = EmbattleMgr.idKeyList.seBlts[nID].templateId
            if nil~=itemData[nTemplateID] then
                strName = itemData[nTemplateID].name
                strInv = strName.."x".. EmbattleMgr.idKeyList.seBlts[nID].count
                

                print(strInv)
            end
            slot[nPos].btn:stopAllActions()
            slot[nPos].btn:setOpacity(255)

            slot[nPos].btn:setButtonImage("normal","Battle/battleSeblt_"..nTemplateID..".png")
            slot[nPos].btn:setButtonImage("pressed","Battle/battleSeblt_"..nTemplateID..".png")

            slot[nPos].btn:setPositionY(-55+slot[nPos].btn.sprite_[1]:getContentSize().height )
        end
    end

    slot[nPos].inventory:setString(strInv)
end

--设置弹仓选中状态
function EmbattleScene:SetSlotState()
    if nil==self.slotItem then
        return
    end
    --按钮选中状态更改
    for i=1, #self.slotItem do
        local selectedImg = self.slotItem[i].btn:getChildByTag(3)
        if i==self.curSelSlot then
            if selectedImg~=nil then
                selectedImg:show()
            else
                selectedImg = display.newScale9Sprite("common/common_bulletSelected.png",nil,nil,self.slotItem[i].btn.sprite_[1]:getContentSize(),cc.rect(24,32,10,83))
                    :addTo(self.slotItem[i].btn,0,3)
                    :align(display.CENTER,0,0)
            end
            
            selectedImg:setContentSize(self.slotItem[i].btn.sprite_[1]:getContentSize())
            
        else

            if selectedImg~=nil then
                selectedImg:hide()
            end
        end
    end
end

--初始化特种弹列表
function EmbattleScene:InitBulletList()
    if nil==self.bltList then
        return false
    end
    self:performWithDelay(function (  )
        local listView = self.bltList
        listView:removeAllItems()   --清空

        local _bltTab = {}
        local _bltTab_2 = {}
        for k,v in pairs(srv_carEquipment["bp"]) do
            local loc_data = itemData[v.tmpId]
            if loc_data.type==107 then
                _bltTab[#_bltTab+1] = {id = v.id,templateId = v.tmpId,count = v.cnt}
                _bltTab_2[v.id] = {id = v.id,templateId = v.tmpId,count = v.cnt}
            end
        end
        EmbattleMgr.curInfo.seBlts = _bltTab
        EmbattleMgr.idKeyList.seBlts = _bltTab_2
        
        local tab = EmbattleMgr.curInfo.seBlts
        local nID, nTemplateID, strName, strInv

        local function Callback(sender, data)
            if nil==self.detailPanel or nil==data then
                return
            end

            local seBlt = EmbattleMgr.idKeyList.seBlts[data.nID]
            if nil==seBlt then
                return
            end

            --特种弹描述
            local tab = itemData[seBlt.templateId]
            local str = ""
            if nil~=tab then
                str = tab.des
            end
            self.labDetails:setString(tab.des)

            local spW = sender:convertToWorldSpaceAR(cc.p(0, 0))
            local spN = self.bltListPanel:convertToNodeSpace(spW)
            self.detailPanel:setPositionY(spW.y)
            self.detailPanel:setVisible(true)
        end

        local loc_Item
        local bgSize = cc.size(270, 60)
        for i=1, #tab do
            nID = tab[i].id
            nTemplateID = tab[i].templateId
            local nHasEquip = EmbattleMgr:CheckSebltEquiped(nID)
            if 1095001~=nTemplateID then
                local item = listView:newItem()
                local content = cc.Node:create()
                local _size = cc.size(435,125)
                content:setContentSize(_size)
                -- local content = display.newScale9Sprite("common2/com2_Img_6.png",nil,nil,_size,cc.rect(15,15,50,50))
                -- content:opacity(0)
                -- content:setColor(cc.c3b(255,0,0))
                -- content:setAnchorPoint(cc.p(0,0))

                loc_Item = itemData[nTemplateID]

                --特种弹按钮
                local btn = cc.ui.UIPushButton.new({normal = "common2/com2_Img_7.png"})
                                :addTo(content)
                                :pos(_size.width/2-30,_size.height/2+20)
                                :onButtonPressed(function(event)
                                    event.target:setScale(0.985)
                                    end)
                                :onButtonRelease(function(event)
                                    event.target:setScale(1.0)
                                    end)
                                :onButtonClicked(function(event)

                                        nHasEquip = EmbattleMgr:CheckSebltEquiped(tab[i].id)
                                        if(0~=nHasEquip) then --已经装载的，要卸载
                                            local bSuccess = EmbattleMgr:LoadSeblts(tab[i].id, self.curSelSlot,true)
                                            if bSuccess then
                                                print("数据卸载陈宫，以下UI卸载")
                                                self:SetSlot(bSuccess, 0)

                                                local selectTag2 = event.target:getChildByTag(10012)

                                                selectTag2:setVisible(false)
                                            end
                                        else
                                            local bSuccess = EmbattleMgr:LoadSeblts(tab[i].id, self.curSelSlot)
                                            if bSuccess then
                                                self:SetSlot(self.curSelSlot, tab[i].id)
                                                self:ShowOrHideBltList(2, true)
                                                self.curSelSlot = nil
                                                self:SetSlotState()
                                                GuideManager:_addGuide_2(10507, display.getRunningScene(),handler(self,self.caculateGuidePos))
                                            end
                                        end
                                    end)
                if i==1 then
                    self.guideBtn = btn
                end
                btn:setTouchSwallowEnabled(false)
                local btnSize = btn.sprite_[1]:getContentSize()

                --特种弹图标
                local bulletSpr = display.newSprite("Battle/battleSeblt_"..nTemplateID..".png")
                    :align(display.CENTER, -10,0)
                    :addTo(btn,2)
                bulletSpr:setRotation(90)

                --名称
                local strName = ""
                --print("===========,",string.len(loc_Item.name))
                for i=3,string.len(loc_Item.name),3 do
                    local str = string.sub(loc_Item.name,i-2,i)
                    strName = strName..str.." "
                    --print("--------------------====================",strName)
                end
                local nameLbl = display.newTTFLabel{text = strName,color = cc.c3b(179,255,255),size = 22}
                    :addTo(btn,2)
                    :align(display.LEFT_BOTTOM,50,5-btnSize.height/2)
                nameLbl:enableOutline(cc.c4f(201,154,82,1))

                display.newSprite("#Embattle_Img1.png")
                    :addTo(btn)
                    :align(display.LEFT_BOTTOM,-btnSize.width/2+2, -btnSize.height/2+4)

                --库存
                display.newTTFLabel({
                            text="x" .. tab[i].count,
                            size=22,
                            color=cc.c3b(249, 227, 18),
                            font = "fonts/slicker.ttf"
                        })
                        :align(display.LEFT_BOTTOM, -btnSize.width/2+15, -btnSize.height/2+4)
                        :addTo(btn,10)

                local selectTag2 =  display.newSprite("common2/com2_tag_01.png")
                    :align(display.LEFT_TOP, -btnSize.width/2+2, btnSize.height/2)
                    :addTo(btn,2,10012)
                if(0~=nHasEquip)then
                    --selectTag1:setVisible(true)
                    selectTag2:setVisible(true)
                else
                    --selectTag1:setVisible(false)
                    selectTag2:setVisible(false)
                    --btnBg:setSpriteFrame("Embattle_Img15.png")
                end

                --购买特种弹按钮
                local buyBtn = cc.ui.UIPushButton.new({normal = "#Embattle_Img3.png",})
                        :addTo(btn,2)
                        :align(display.CENTER, btnSize.width/2+10, 0)
                        :onButtonPressed(function(event)
                            event.target:setScale(0.985)
                            end)
                        :onButtonRelease(function(event)
                            event.target:setScale(1.0)
                            end)
                        :onButtonClicked(function()
                            local shop = shopLayer.new(4)
                            :addTo(self,20)
                            end)

                display.newSprite("#Embattle_Img4.png")
                    :addTo(buyBtn)
                    :pos(10,0)

                local _label = display.newTTFLabel{text = loc_Item.des,color = cc.c3b(141,163,170),size = 18}
                    :addTo(content)
                    :align(display.LEFT_TOP,btn:getPositionX()-btnSize.width/2+5,btn:getPositionY()-btnSize.height/2)
                local _singleLineHeight = _label:getContentSize().height
                _label:setWidth(btnSize.width+60)
                _label:setLineHeight(_singleLineHeight)

                --添加content
                item:addContent(content)
                item:setItemSize(_size.width, _size.height+5)
                listView:addItem(item)
            end
        end
        listView:reload()

        return true
    end,0.01)
end

--刷新牵引车头像
function EmbattleScene:RefreshPullHead()
    
end

--设置战斗力
function EmbattleScene:SetStrength(nVal)
    if nil~=nVal and nil~=self.labFp then
        self.labFp:setString(tostring(nVal))
    end
end

--设置最大装载量
function EmbattleScene:SetMaxLoadNum(nVal)
    if nil~=nVal and nil~=self.magazineItem.labMaxLoadNum then
        self.magazineItem.labMaxLoadNum:setString(tostring(nVal))
    end
end

--显示/隐藏特种弹列表面板(nType=1:显示  nType=2:隐藏)
function EmbattleScene:ShowOrHideBltList(nType, bAni)
    if nil==self.bltListPanel then
        return
    end
    local panel = self.bltListPanel
    local magazineX, magazineY = -345-100,display.cy+40

    if 1==nType then    --显示
        if bAni then
            panel:setPosition(magazineX+10, magazineY)
            panel:setVisible(true)
            local action = cc.MoveTo:create(0.2, cc.p(magazineX+318, magazineY))
            panel:runAction(action)
        else
            panel:setPosition(magazineX+305, magazineY)
            panel:setVisible(true)
        end
    elseif 2==nType then    --隐藏
        if bAni then
            local action1 = cc.MoveTo:create(0.2, cc.p(magazineX+10, magazineY))
            local action2 = cc.Hide:create()
            local finalAction = cc.Sequence:create(action1, action2)
            panel:runAction(finalAction)
        else
            panel:setPosition(magazineX+10, magazineY)
            panel:setVisible(false)
        end
    end
end

--初始化主战面板
function EmbattleScene:refreshMainBattleItem()
    local sortList = self.sortList
    if nil==sortList then
        return
    end
    self:performWithDelay(function ()
        --主战面板元素
        local function MainBattleItemOnClick(event)
            if EmbattleMgr.nCurBattleType == BattleType_WorldBoss then
                showTips("世界BOSS不允许下阵")
                return
            end
            local nTag = event.target:getTag()
            
            if nil==self.sortList then
                return
            end
            local tab = self.sortList.members
            if nil==tab[nTag] then
                printInfo("Empty pos")
            else
                if nil==self.sortList or nil==self.sortList.members[nTag] then
                    return
                end
                local _memberInfo = self.sortList.members[nTag]
                -- if event.target.isRent==true then
                --     local _tmpId = self._rentInfo.tptId
                --     if _tmpId==11 then _tmpId = 1020 end
                --     if _tmpId==12 then _tmpId = 1040 end
                --     if _tmpId==13 then _tmpId = 1070 end
                --     _memberInfo = {mtype=3,strength = self._rentInfo.strength,id = self._rentInfo.id,tptId = _tmpId}
                -- end
                local nID = EmbattleMgr:getMatrixIdFromMemberInfo(_memberInfo)
                local nType, nPos = EmbattleMgr:AutoOnOffBattle(EmbattleGroup_Main, nID)
                if nPos==-1 then
                    showTips("阵位已满，不能再上了")
                    return
                end
                if 0~=nPos then
                    if EmbattleType_OnBattle==nType then
                        self:OnOffBattleAni(nType, EmbattleGroup_Main, nTag, nPos)
                        self:SetStrength(math.floor(EmbattleMgr:GetStrength()))
                    elseif EmbattleType_OffBattle==nType then
                        self:OnOffBattleAni(nType, EmbattleGroup_Main, nPos, nTag)
                        self:SetStrength(math.floor(EmbattleMgr:GetStrength()))
                    end
                end
            end
        end
        local _listView = self.myTeamerList
        _listView:removeAllItems()
        self.mainBattleItem = {}
        local _memberList = sortList.members
        for k,v in pairs(_memberList) do
            if v.isRent == true then
                _memberList[k] = nil
            end
        end
        -- if self._rentInfo ~= nil then
        --     print("有租车头像")
        --     local _tmpId = self._rentInfo.tptId
        --     if _tmpId==11 then _tmpId = 1020 end
        --     if _tmpId==12 then _tmpId = 1040 end
        --     if _tmpId==13 then _tmpId = 1070 end
        --     table.insert(_memberList,{isRent = true,mtype=3,strength = self._rentInfo.strength,id = self._rentInfo.id,tptId = _tmpId})
        -- end
        print("#_memberList:",#_memberList,"\n")
        for i=1,#_memberList do
            local value = _memberList[i]
            local nID = EmbattleMgr:getMatrixIdFromMemberInfo(value)
            local nTemplateID = value.tptId
            if value.mtype==memberType.TYPE_MAN_AND_CAR then
                nTemplateID = value.carTptId
            end
            local nResID = tonumber(string.sub(nTemplateID,1,4))
            local headPath
            if value.mtype==memberType.TYPE_MAN_ONLY then
                headPath = string.format("Head/headman_%d.png", nResID)
            else
                headPath = string.format("Head/head_%d.png", nResID)
            end

            local nPos = EmbattleMgr:CheckOnBattle(EmbattleGroup_Main, nID)
            local item = _listView:newItem()

            local content = display.newSprite("#Embattle_Img38.png")
            local _size = content:getContentSize()
            self.mainBattleItem[i] = {}

            self.mainBattleItem[i].btnSel = cc.ui.UIPushButton.new()
                    :size(105, 105)
                    :align(display.CENTER, _size.width/2,_size.height/2)
                    :addTo(content,0,i)
                    :onButtonClicked(MainBattleItemOnClick)
            self.mainBattleItem[i].btnSel:setTouchSwallowEnabled(false)
            if value.isRent then
                self.mainBattleItem[i].btnSel.isRent = true
            end

            self.mainBattleItem[i].imgHead = display.newSprite(headPath)
                    :align(display.CENTER_BOTTOM, _size.width/2,7)
                    :addTo(content)

            self.mainBattleItem[i].sprSel = display.newSprite("common2/com_hook.png")
                    :align(display.BOTTOM_RIGHT, _size.width-8,8)
                    :addTo(content)
                    :scale(0.7)
                    :hide()
            if 0~=nPos then
                self.mainBattleItem[i].sprSel:show()
            end

            if value.mtype==memberType.TYPE_MAN_AND_CAR then
                local manHeadBg = display.newSprite("common/common_HeadFrame1.png")
                    :pos(_size.width-30,_size.height-0)
                    :addTo(content)
                local nResID = tonumber(string.sub(value.tptId,1,4))
                tmpStr = string.format("Head/chead_%d.png", nResID)
                display.newSprite(tmpStr)
                    :scale(0.44)
                    :align(display.CENTER, manHeadBg:getContentSize().width/2, manHeadBg:getContentSize().height/2)
                    :addTo(manHeadBg)
            elseif value.mtype==memberType.TYPE_CAR_ONLY then
                display.newSprite("#Embattle_Img41.png")
                    :addTo(content)
                    :pos(_size.width-30,_size.height-21)
            end

            item:addContent(content)
            item:setItemSize(_size.width+8,_size.height)
            _listView:addItem(item)
        end
        _listView:reload()
    end,0.1)
        

end

--布阵信息返回
function EmbattleScene:OnEmbattleInfoRet(cmd)
    if 1==cmd.result then
        if nil==EmbattleMgr.curInfo then
            return
        end
        self:InitSortList()
        local tmpVal = 0

        tmpVal = math.floor(EmbattleMgr:GetStrength())
        self:SetStrength(tmpVal)
        self:LoadDrag()

        self:refreshMainBattleItem()
        self:InitBulletSlot()
        self:RefreshPullHead()

        --军团布阵倒计时
        self.legionTimeFlag = true --军团是否可以继续布阵（剩余时间结束时置为false）
        self.legionLestTime = 60
        if BattleType_Legion==self.args[1] then
            self.legiontimeLabel = cc.ui.UILabel.new({UILabelType = 2, text = "布阵剩余时间：01:00", size = 25, color = MYFONT_COLOR}) 
            :addTo(self)
            :align(display.CENTER, display.cx, display.height - 20)
            self.timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
        end
        
        --技能预设
        if EmbattleMgr.nCurBattleType == BattleType_PVP or EmbattleMgr.nCurBattleType == BattleType_PVP_DEF then
            self.sprImg:setString("技能预设")
            self.sprImg:setScale(0.8)
        else
            self.sprImg:setString("租车")
            self.sprImg:setScale(1.0)
        end
    else
        showTips(cmd.msg)
    end
    endLoading()
end
--军团布阵倒计时监听
function EmbattleScene:onInterval()
    if self.legionLestTime>=1 then
        self.legionLestTime = self.legionLestTime - 1
        local str = "布阵剩余时间："..string.sub(GetTimeStr(self.legionLestTime*1000), 4,8)
        self.legiontimeLabel:setString(str)
        if self.legionLestTime==0 then
            showMessageBox("布阵超时！")
        end
    else
        scheduler.unscheduleGlobal(self.timeHandle)
    end
end

--初始化排序列表
function EmbattleScene:InitSortList()
    if nil==EmbattleMgr.curInfo then
        return false
    end

    --根据获得顺序升序排列
    local function AscendGetOrder(val1, val2)
        return val1.id < val2.id
    end

    --根据获得顺序降序排列
    local function DescendGetOrder(val1, val2)
        return val1.id > val2.id
    end

    self.sortList = {
                        memSkl = {},
                        carSkl = {},
                        members = {},
                        pullCars = {},
                        friends = {},
                        canRentCars = {},
                    }

    if EmbattleMgr.curInfo.memSkl then
        for i=1, #EmbattleMgr.curInfo.memSkl do
            self.sortList.memSkl[i] = EmbattleMgr.curInfo.memSkl[i]
        end
    end
    if EmbattleMgr.curInfo.carSkl then
        for i=1, #EmbattleMgr.curInfo.carSkl do
            self.sortList.carSkl[i] = EmbattleMgr.curInfo.carSkl[i]
        end
    end
    for i=1, #EmbattleMgr.curInfo.members do
        self.sortList.members[i] = EmbattleMgr.curInfo.members[i]
    end
    table.sort( self.sortList.members, AscendGetOrder )

    for i=1, #RentMgr.sortList do
        self.sortList.canRentCars[i] = RentMgr.sortList[i]--可以租的车
    end

    for i=1, #EmbattleMgr.curInfo.friends do
        self.sortList.friends[i] = EmbattleMgr.curInfo.friends[i]
    end
  
    return true
end

--加载拖动层
function EmbattleScene:LoadDrag()
    if self.drag then
        self.drag:removeDragAll()
        self.drag:removeFromParentAndCleanup(true)
        self.drag = nil
    end

    self.drag = UIDrag.new(nil,true)
    self.drag.isExchangeModel = true
    self.drag:setTouchSwallowEnabled(false)
    self.drag:addHinder(self.bltListPanel)
    self.drag:addHinder(self.bltLPCBtn)
    self:addChild(self.drag, 19)

    local key, thisID, tplID, memberInfo, nArmatureType
    local spr = nil
    
    for i=1, #self.mainBox do
        self.drag:addDragItem(self.mainBox[i].pBox, nil, nil, 10, cc.p(0.5,0), false)
        key = "main" .. i
        thisID = EmbattleMgr.curInfo.matrix[key]
        print("--------------thisID:",thisID)
        if thisID~=-1 and thisID~=0 then
                
            memberInfo = EmbattleMgr:getMenberInfoByMatrixId(thisID)
            if memberInfo==nil then --服务端数据发生错误
                EmbattleMgr.curInfo.matrix[key] = -1
                -- writeTabToLog({key = key},"服务端数据发生错误: ","gggg.txt")
                -- writeTabToLog(EmbattleMgr.curInfo.matrix,"修改后的值: ","gggg.txt")
            else
                print("memberInfo.cType:",memberInfo.mtype)
                printTable(memberInfo)
                print("==========================================================")
                if memberType.TYPE_MAN_ONLY==memberInfo.mtype then  --人
                    nArmatureType = ModelType.Hero
                    tplID = memberInfo.tptId
                else
                    nArmatureType = ModelType.Tank
                    if memberType.TYPE_CAR_ONLY==memberInfo.mtype then --车
                        tplID = memberInfo.tptId
                    else   --人和车
                        tplID = memberInfo.carTptId
                    end
                end
                spr = ShowModel.new({modelType=nArmatureType, templateID=tplID})
                SetModelParams(spr, {fScale=0.8})
                self.drag:find(self.mainBox[i].pBox):setDragObj(spr)
            end
        end
    end

    --拖拽前
    self.drag:setOnDragUpAfterEvent(function(currentItem,point)
        self.pressPoint = point     --用于判断骨骼是否切换动画
    end)

    --拖拽放下之前
    self.drag:setOnDragDownBeforeEvent(function(currentItem,targetItem,point)
        if targetItem then
            --拖动允许（主战-主战，牵引-牵引）
            if currentItem:getGroup() == targetItem:getGroup() then

                --交换操作
                local nGroup = currentItem:getGroup()/10
                local srcPos = currentItem.dragBox:getTag()%10
                local dstPos = targetItem.dragBox:getTag()%10
                if currentItem.dragObj then
                    local bResult = EmbattleMgr:ChangePos(nGroup, srcPos, dstPos)
                    if false==bResult then
                        showTips("战车位未开启")
                    else
                        if self._rentInfo and self._rentInfo._pos==srcPos then
                            self._rentInfo._pos = dstPos
                        elseif self._rentInfo and self._rentInfo._pos==dstPos then
                            self._rentInfo._pos = srcPos
                        end
                    end
                    return bResult
                end
            end
        else
            if self.pressPoint.x==point.x and self.pressPoint.y==point.y then
                local nGroup = currentItem:getGroup()
                if currentItem.dragObj then
                    currentItem.dragObj:ShowOnceMoveMent()
                end
            end
            self.pressPoint = nil
        end
        
        return false
    end)
end

--上下阵动画(nType=1:上阵  nType=2:下阵)
function EmbattleScene:OnOffBattleAni(nType, nGroup, srcPos, dstPos)
    if nil==nType or nil==nGroup or nil==srcPos or nil==dstPos then
        return
    end

    if EmbattleType_OnBattle==nType then
        local nArmatureType
        if EmbattleGroup_Main==nGroup then
            local dragItem = self.drag:find(self.mainBox[dstPos].pBox)
            if nil==dragItem or nil~=dragItem.dragObj then
                return
            end
            local memberInfo = self.sortList.members[srcPos]
            local tplID
            if memberType.TYPE_MAN_ONLY==memberInfo.mtype then  --人
                nArmatureType = ModelType.Hero
                tplID = memberInfo.tptId
            else
                nArmatureType = ModelType.Tank
                if memberType.TYPE_CAR_ONLY==memberInfo.mtype then --车
                    tplID = memberInfo.tptId
                else   --人和车
                    tplID = memberInfo.carTptId
                end
            end
            local curOpObj = ShowModel.new({modelType=nArmatureType, templateID=tplID})
            SetModelParams(curOpObj, {fScale=0.8})
            self.mainBattleItem[srcPos].btnSel:setButtonEnabled(false)

            --世界坐标
            local beginPos = self.mainBattleItem[srcPos].imgHead:convertToWorldSpaceAR(cc.p(0, 0))
            local boxSize = dragItem.dragBox:getContentSize()
            local endPos = dragItem.dragBox:convertToWorldSpaceAR(cc.p(0, -boxSize.height))

            --托动层坐标
            beginPos = self.drag:convertToNodeSpace(beginPos)
            endPos = self.drag:convertToNodeSpace(endPos)

            self.drag:addChild(curOpObj)
            curOpObj:setPosition(beginPos)

            local function Callback()
                curOpObj:retain()
                curOpObj:removeFromParent()
                curOpObj:release()
                dragItem:setDragObj(nil)
                dragItem:setDragObj(curOpObj)
                curOpObj = nil
                self.mainBattleItem[srcPos].sprSel:setVisible(true)
                self.mainBattleItem[srcPos].btnSel:setButtonEnabled(true)
            end

            local action1 = cc.MoveTo:create(0.2, endPos)
            local action2 = cc.CallFunc:create(Callback)
            local finalAction = cc.Sequence:create(action1, action2)
            curOpObj:runAction(finalAction)

        elseif EmbattleGroup_Pull==nGroup then
            self:OnOffBattle(nType, nGroup, srcPos, dstPos)

        end

    elseif EmbattleType_OffBattle==nType then
        if EmbattleGroup_Main==nGroup then
            local dragItem = self.drag:find(self.mainBox[srcPos].pBox)
            if nil==dragItem or nil==dragItem.dragObj then
                return
            end
            local curOpObj = dragItem.dragObj
            self.mainBattleItem[dstPos].btnSel:setButtonEnabled(false)

            --世界坐标
            local boxSize = dragItem.dragBox:getContentSize()
            local beginPos = dragItem.dragBox:convertToWorldSpaceAR(cc.p(0, -boxSize.height/2))
            local endPos = self.mainBattleItem[dstPos].imgHead:convertToWorldSpaceAR(cc.p(0, 0))

            --托动层坐标
            beginPos = self.drag:convertToNodeSpace(beginPos)
            endPos = self.drag:convertToNodeSpace(endPos)

            curOpObj:retain()
            curOpObj:removeFromParent()
            curOpObj:setPosition(beginPos)
            self.drag:addChild(curOpObj)
            curOpObj:release()

            local function Callback()
                dragItem:setDragObj(nil)
                curOpObj = nil
                self.mainBattleItem[dstPos].sprSel:setVisible(false)
                self.mainBattleItem[dstPos].btnSel:setButtonEnabled(true)
            end

            local action1 = cc.MoveTo:create(0.2, endPos)
            local action2 = cc.CallFunc:create(Callback)
            local finalAction = cc.Sequence:create(action1, action2)
            curOpObj:runAction(finalAction)

        elseif EmbattleGroup_Pull==nGroup then
            self:OnOffBattle(nType, nGroup, srcPos, dstPos)

        end
    end

end

--上下阵
function EmbattleScene:OnOffBattle(nType, nGroup, srcPos, dstPos, bIsRent)
    if nil==nType or nil==nGroup or nil==srcPos or nil==dstPos then
        return
    end
    bIsRent = bIsRent or false --nil==false

    if EmbattleType_OnBattle==nType then
        local nArmatureType
        if EmbattleGroup_Main==nGroup then
            local dragItem = self.drag:find(self.mainBox[dstPos].pBox)
            if nil==dragItem or nil~=dragItem.dragObj then
                return
            end
            local memberInfo
            if not bIsRent then
                memberInfo = self.sortList.members[srcPos]
            else
                local rentInfo = RentMgr.rentInfo[self.sortList.canRentCars[srcPos]]
                rentInfo._pos = dstPos
                memberInfo = {carTptId = rentInfo.tptId}

                self._rentInfo = rentInfo
                --self:refreshMainBattleItem()
            end
            local tplID
            if nil==memberInfo.carTptId then
                nArmatureType = ModelType.Hero
                tplID = memberInfo.tptId
            else
                nArmatureType = ModelType.Tank
                tplID = memberInfo.carTptId
            end
            local curOpObj = ShowModel.new({modelType=nArmatureType, templateID=tplID})
            SetModelParams(curOpObj, {fScale=0.8})

            dragItem:setDragObj(nil)
            dragItem:setDragObj(curOpObj)
            curOpObj = nil
        end
    elseif EmbattleType_OffBattle==nType then
        if EmbattleGroup_Main==nGroup then
            local dragItem = self.drag:find(self.mainBox[srcPos].pBox)
            if nil==dragItem or nil==dragItem.dragObj then
                return
            end

            dragItem:setDragObj(nil)

            if bIsRent then
                self._rentInfo = nil
                print("刷新减少头像")
                self:refreshMainBattleItem()
            end
        end
    end
end

function EmbattleScene:OnReqFightRet(cmd)
    
    endLoading()
    if 1==cmd.result then
        app:enterScene("LoadingScene",{SceneType.Type_Battle})
    else
        showTips(cmd.msg)
    end
end

function EmbattleScene:CheckHidePull()
    self.bHidePull = false

    if RelicsLayer and RelicsLayer.Instance then
        if block_idx and tonumber(string.sub(block_idx, 2, 2))==1 then
            self.bHidePull = true
            return
        end
    end
    

    if g_WarriorsCenterMgr.step==0  then
        self.bHidePull = true
        print("+++++++++++++++++++++++++++++++++++  self.bHidePull = true")
        return
    elseif g_WarriorsCenterMgr.step==1 then
        self.bHidePull = false
        return
    end

    --当前非PVE战斗
    if BattleType_PVE~=self.args[1] then
        return
    end

    --数据未初始化
    if nil==block_idx then
        return
    end

    --无该关卡数据
    if nil==blockData[block_idx] then
        return
    end

    local nTag = tonumber(string.sub(tostring(block_idx), 2, 2))
    if 1~=nTag then     --车可以出战，无需隐藏牵引
        return
    end

    self.bHidePull = true
end

function EmbattleScene:onExit()
    print(g_WarriorsCenterMgr.step)
    if g_WarriorsCenterMgr.step~=1 then
        EmbattleScene.Instance = nil
        display.removeSpriteFramesWithFile("Image/UIEmbattle.plist", "Image/UIEmbattle.png")
    end
    if self.timeHandle then
        scheduler.unscheduleGlobal(self.timeHandle)
    end
end

function EmbattleScene:onEnter()
    setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
    EmbattleMgr:ReqEmbattleInfo(self.args[1])
    
end

function EmbattleScene:OnUnlockRet(cmd)
    if 1==cmd.result then
        self:InitBulletSlot()
        mainscenetopbar:refreshBarData()
    else
        showTips(cmd.msg)
    end
    endLoading()
end

function EmbattleScene:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local targetPos = nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11305==_guideId or 10105==_guideId or 10705==_guideId or 10205==_guideId or 11105==_guideId 
    or 10505==_guideId or 10506==_guideId or 11206==_guideId or 11209==_guideId or 11210==_guideId 
    or 10507==_guideId or 11307==_guideId or 11605==_guideId or 11705==_guideId then
        if 10105==_guideId or 10507==_guideId or 10205==_guideId or 11105==_guideId 
        or 11209==_guideId or 11307==_guideId or 11605==_guideId or 11705==_guideId then
            g_node = currentBtn
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(-size.width/2,0))
        elseif 11305==_guideId then
            g_node = self.laserCannon.BoxBt
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(size.width/2,0))
        elseif 10505==_guideId then
            g_node = self.slotItem[1].btn
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        elseif 10506==_guideId then
            g_node = self.guideBtn
            midPos = g_node:convertToWorldSpace(cc.p(size.width*1.5,0))
            midPos.x = 100
            size = g_node.sprite_[1]:getContentSize()
            size = cc.size(size.width/2,size.height)
        elseif 11206==_guideId then
            g_node = self.pullBtn1
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
            size = g_node.sprite_[1]:getContentSize()
        elseif 11210==_guideId then
            g_node = self.msgBox.msgOKBt
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
            size = g_node.sprite_[1]:getContentSize()
        end
     
        if g_node==nil then
            print("g_node==nil,  return")
            return nil
        end
        
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
        if 10506==_guideId then
            promptRect = cc.rect(midPos.x-size.width/2+0,midPos.y-size.height/2,size.width-25,size.height)
        end
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect,targetPos
end

