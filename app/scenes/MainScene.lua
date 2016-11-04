require("app.data.GameData")
require("app.path.ImgPath")
require("app.scenes.guide.GuideManager")
require("app.battle.BattleInfo")
require("app.scenes.block.BlockUI")
require("app.sdk.jpushSDK")
local httpNet = require("app.net.HttpNet")
local timeUpdateUtils = require("app.utils.timeUpdateUtils")

fightBt = nil
local areamap --大区Layer对象

local systemLayer = require("app.scenes.systemLayer")
local globalFunc = require("app.utils.GlobalFunc")
local scheduler = require("framework.scheduler")
local roleMenuBar = require("app.scenes.roleMenuBar")
-- local mainSceneTopBar = require("app.scenes.MainSceneTopBar")
local activityMenuBar = require("app.scenes.activityMenuBar")
backPackLayer  = require("app.scenes.backpack.backPack_Equipment")
friendLayer = require("app.scenes.friendScene.friendLayer")
shopLayer = require("app.scenes.shop.shopLayer")
local LegionLayer = require("app.scenes.legionScene.LegionScene")
g_lotteryCardLayer = require("app.scenes.lotterycard.LotteryCardScene")
g_combinationLayer = require("app.scenes.backpack.combinationLayer")
g_carEquipmentLayer = require("app.scenes.carEquipments.carEquipmentsMsg")
g_pieceMsgLayer = require("app.scenes.carEquipments.pieceMsgLayer")
g_broadcast = require("app.scenes.MainBroadcast")
g_recharge = require("app.scenes.recharge.rechargeLayer")
local PVPScene = require("app.scenes.PVPScene")


mainscenetopbar = nil --金钱条
MenuLayerFlag = nil --菜单标记在那种Layer中
bMinMenuFlag = 0
worldFreeTimes = 0 --世界聊天免费次数



local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)


-- local curCommand = CMD_ENTER_BLOCK
local fightSelectAreaData={}
local MainActionFlag = 1


bTaskLayerOpened = false

MainScene_Instance = nil
function setIgonreLayerShow(bShow)
    print("------------------------====")
    print(bShow)
    local ignoreTouchLayer = display.getRunningScene():getChildByTag(2011)
    if ignoreTouchLayer then
        if ignoreTouchLayer:isVisible() then
            display:getRunningScene():performWithDelay(function ()
                ignoreTouchLayer:setVisible(bShow)
            end,0.1)
        else
            ignoreTouchLayer:setVisible(bShow)
        end
    else
        print("error,ignoreTouchLayer is not exist!--")
        -- printTraceback()
    end
end
function MainScene:ctor()


    local opacity = 0
    if g_IsDebug then
        opacity = 100
    end
    local ignoreTouchLayer = display.newLayer() --display.newColorLayer({r = 255, g = 0, b = 0, a = opacity})
        :addTo(self,200,2011)
        :setTouchEnabled(true)
    GuideManager.IsFirstGuide = true
    MenuLayerFlag = 0
    -- printTable(srv_userInfo)
    

    self.mainBg = getMainSceneBgImg(areaData[mapAreaId].resId)
    :addTo(self,-1)


    local mainBgMaskLayer = display.newLayer() --display.newColorLayer({r = 0, g = 0, b = 0, a = 200})
    :addTo(self,0)
    mainBgMaskLayer:setVisible(false)
    self.mainBgMaskLayer = mainBgMaskLayer

    --头像
    self:createPlayerHead()


    --记住底下菜单开关
    if MainActionFlag == 0 then
        self:setMainListViewClose(ActionLayer)
    end

    g_isNewCreate = false
    --新手教程

    
    --战斗按钮
    fightBt = cc.ui.UIPushButton.new("#MainUI_img23.png")
    :addTo(self)
    :pos(display.width- 110, 90)
    :onButtonPressed(function(event) self.fgtBtImg:setVisible(true) end)
    :onButtonRelease(function(event) self.fgtBtImg:setVisible(false) end)
    :onButtonClicked(function(event)
        setIgonreLayerShow(true)
        GuideManager:hideGuideEff()
         MainSceneEnterType = EnterTypeList.FIGHT_ENTER
        local areamap
        print(srv_userInfo["maxBlockId"])
        local toAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
        if areaData[toAreaId+1]~=nil and canAreaEnter(toAreaId+1) and 
            srv_userInfo.level>=areaData[toAreaId+1].level then
            areamap = g_blockMap.new(toAreaId+1, srv_userInfo["maxBlockId"], 1)
        else
            areamap = g_blockMap.new(toAreaId, srv_userInfo["maxBlockId"], 1)
        end
        areamap:addTo(self,50)
       -- app:enterScene("MainScene")
       -- local curRewards = {}
       -- table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=100})
       -- GlobalShowGainBox({bAlwaysExist = true}, curRewards)
       -- teamUpgrade:createUpgradeBox(6,7, 100)
    end)
    self.fgtBtImg = display.newSprite("#MainUI_img22.png")
    :addTo(fightBt)
    self.fgtBtImg:setVisible(false)

    self.fight_Circle = display.newSprite("#MainUI_img24.png")
    :addTo(fightBt)
    -- :pos(display.width- 110, 90) 
    local rota = cc.RotateBy:create(5, 180)
    local action2 = cc.RepeatForever:create(rota)
    self.fight_Circle:runAction(action2)

    -- local num = tonumber(string.sub(tostring(srv_userInfo.maxBlockId), 4,8))
    -- print("num:",num)
    -- if num <= 1001 and srv_userInfo.guideStep<=102 then     --打第一关前，隐藏战斗按钮
    --     fightBt:hide()
    -- end

end


function reloadMailAndTask()
    local arr2 = string.split(os.date("%H:%M:%S"),":")
    local nowH,nowM,nowS = tonumber(arr2[1]),tonumber(arr2[2]),tonumber(arr2[3])
    if g_hourOld==23 and nowH==24 then
        reInitAllTask()
        reInitAllMail()
    end
    g_hourOld = nowH
end

function MainScene:addGuide_ani(_guideStep)
    print("调用addGuide_ani(".._guideStep..")",GuideManager.NextStep)
    local tmp = GuideManager.NextStep
    if tonumber(tmp) == 0 then
        tmp = tonumber(tostring(srv_userInfo.guideStep).."01")
    end
    if tmp ~= _guideStep then
        return
    end
    local ignoreTouchLayer = display.newLayer() --display.newColorLayer({r = 0, g = 200, b = 200, a = 10})
            :addTo(self)
    -- if _guideStep==10501 then
    --     fightBt:show()
    --         :pos(display.cx,display.cy)
    --         :opacity(0)
    --     local _delayTime = 1
    --     fightBt:runAction(cc.Spawn:create(cc.FadeIn:create(_delayTime),
    --         cc.MoveTo:create(_delayTime,cc.p(display.width- 110, 90))))
    --     self:performWithDelay(function ()
    --         self:performWithDelay(function ( ... )
    --             ignoreTouchLayer:removeSelf()
    --         end,0.1)
    --         GuideManager:_addGuide_2(_guideStep, self,handler(self,self.caculateGuidePos))
    --     end,_delayTime)
    -- else
        if _guideStep==10301 or _guideStep==12601 or _guideStep==13001 or _guideStep==11201 then
            self.activityMenuBar:showMoveAction(_guideStep,function ( ... )
                GuideManager:_addGuide_2(_guideStep, self,handler(self,self.caculateGuidePos))
                self:performWithDelay(function ( ... )
                    ignoreTouchLayer:removeSelf()
                end,0.1)
            end)
            if _guideStep==12601 then
                self.roleMenuBar:showMoveAction(_guideStep,function ( ... )
                    GuideManager:_addGuide_2(_guideStep, self,handler(self,self.caculateGuidePos))
                    self:performWithDelay(function ( ... )
                    end,0.1)
                end)
            end
        else
            self.roleMenuBar:showMoveAction(_guideStep,function ( ... )
                GuideManager:_addGuide_2(_guideStep, self,handler(self,self.caculateGuidePos))
                self:performWithDelay(function ( ... )
                    ignoreTouchLayer:removeSelf()
                end,0.1)
            end)
        end
            
    -- end
end

function MainScene:onEnter()
    print(loginServerList.serverId)

    self.roleMenuBar = roleMenuBar.new() --主菜单
        :addTo(self,-1)
    self.activityMenuBar = activityMenuBar.new() --活动菜单
        :addTo(self)
    ActivityMenuBar = self.activityMenuBar

    self:addGuide_ani(10401)    --乘降引导，出现乘降按钮
    self:addGuide_ani(10501)    --打第一关，出现战斗按钮
    self:addGuide_ani(10301)    --领任务引导，出现任务按钮
    self:addGuide_ani(10701)    --主炮升级，出现车库
    self:addGuide_ani(10101)    --第二关
    self:addGuide_ani(10601)    --抽奖，出现抽奖按钮、仓库按钮
    self:addGuide_ani(10801)    
    self:addGuide_ani(10901)
    self:addGuide_ani(11001)
    self:addGuide_ani(10201)
    self:addGuide_ani(11101)
    self:addGuide_ani(11301)
    self:addGuide_ani(11401)    --弹弓升级，出现任务按钮
    self:addGuide_ani(11501)
    self:addGuide_ani(11201)    --引导打水怪，出现赏金首按钮
    self:addGuide_ani(11601)
    self:addGuide_ani(11701)

    if srv_userInfo.level>=10 then   --
        print("主界面addGuide，12101")
        self:addGuide_ani(12101)
    end
    if srv_userInfo.level>=12 then
        self:addGuide_ani(12201)
    end
    self:addGuide_ani(12301)
    if srv_userInfo.level>=14 then
        self:addGuide_ani(12401)
    end
    if srv_userInfo.level>=15 then
        self:addGuide_ani(12501)
    end
    if srv_userInfo.level>=16 then
        self:addGuide_ani(12601)    --出现竞技场按钮
    end
    if srv_userInfo.level>=20 then
        self:addGuide_ani(12701)    --遗迹探测，出现勇士中心按钮
    end
    if srv_userInfo.level>=25 then
        self:addGuide_ani(12801)    
    end
    if srv_userInfo.level>=28 then
        self:addGuide_ani(12901)    --出现军团按钮
    end


    self:performWithDelay(function ()
        GuideManager:_addGuide_2(20401, self,handler(self,self.caculateGuidePos))
    end,0.1)
    

    -- local xxx = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(800,display.height/2),cc.rect(119, 127, 1, 1))
    --     :addTo(self)
    --     :pos(display.cx,display.cy/2)
    -- xxx:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.MoveBy:create(1,cc.p(0,display.height/2))))

    MainScene_Instance = self
    --主城公告
    if g_isFirstToMainScene then
        g_isFirstToMainScene = false
        startLoading()
        local path = cc.FileUtils:getInstance():getWritablePath() .. "upd/res/flist"
        local fileList = nil
        if cc.FileUtils:getInstance():isFileExist(path) then
            fileList = doFile(path)
        else
            fileList = doFile("flist")
        end
        self.curVersion = fileList.version
        local noticeData = {}
        noticeData["ver"] = self.curVersion
        -- noticeData["ver"] = "0.9.99998"
        noticeData.chnlId = gType_Chnl
        noticeData.mobileOS = g_MobileOS
        noticeData["isMain"] = 1
        httpNet.connectHTTPServer(handler(self, self.onNoticeHttpResponse), "/userver/common/getNotices?data=", json.encode(noticeData))


        g_activityLayer.new()
        :addTo(display.getRunningScene(), 999)
    end 
    

    --聊天记录拷贝
    chatRecordList = getLocalGameDataBykey("chatRecordList",{World = {},Legion = {},Private = {}})

    reloadMailAndTask()

    -- print("MainScene:onEnter 用时："..(socket.gettime()-g_startTime))
    -- self:hideMainScene()
    if MainSceneEnterType~=0 or FightSceneEnterType~=0 then
        local loadUtil = g_loadUtil.new()
        --抽卡按帧加载
        -- loadUtil:addRes(loadUtil.resType.plistType,"LotteryCard/card_bt",1)
        -- loadUtil:addRes(loadUtil.resType.plistType,"LotteryCard/card_light",1)
        -- loadUtil:addRes(loadUtil.resType.plistType,"LotteryCard/card_out",1)
        -- --改装中心按帧加载
        loadUtil:addRes(loadUtil.resType.plistType,"Image/improve2_img",1)
        loadUtil:addRes(loadUtil.resType.plistType,"Effect/Improve_Eff1",1)
        --属性按帧加载
        loadUtil:addRes(loadUtil.resType.plistType,"Image/RoleProperty2",1)
        loadUtil:startLoad()

        -- if true then
        --     return
        -- end
    end

    

    setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭

    mainscenetopbar = g_mainSceneTopBar.new() --顶部金钱条
    self:addChild(mainscenetopbar,50)
    

    -- teamUpgrade:createUpgradeBox(9,10)
    g_broadcast.new()
    :addTo(display.getRunningScene())
    :onBroadCast()

    if EnterTypeList_2.FIGHT_ENTER~=FightSceneEnterType then
        audio.playMusic("audio/mainbg.mp3", true)
    end
    
    print(srv_userInfo.templateId)
    print("----------")
    print(curFightBlockId)
    print(srv_userInfo["maxBlockId"])
    print("MainSceneEnterType:"..MainSceneEnterType)

    print("-------------==================456--------FightSceneEnterType=="..FightSceneEnterType)
    --遗迹探测战斗回来后的场景恢复，理应放在 if MainSceneEnterType == EnterTypeList.FIGHT_ENTER then下
    if FightSceneEnterType>0 then--
        if TaskLayer.Instance~=nil then
            if EnterTypeList_2.RELICS_ENTER==FightSceneEnterType then
                g_RelicsLayer.new()
                    :addTo(self)
            end
        else
            bMinMenuFlag = 1
            -- self:createTownMenu()
            --self.mainBgMaskLayer:setVisible(true)
            local warrior = g_WarriorsCenterLayer.new()
            :addTo(self, 1)
            warrior.nCurChildModule = g_nCurChildModule
            

            if EnterTypeList_2.RELICS_ENTER==FightSceneEnterType then
                warrior.mainFrame:setVisible(false)
                g_RelicsLayer.new()
                         :addTo(warrior)
            elseif EnterTypeList_2.EXPEDITION_ENTER==FightSceneEnterType then
                if not g_shouldBackToExpedition then
                    expeditionLayer.new()
                            :addTo(warrior)
                else
                    g_shouldBackToExpedition = false
                end
            elseif FightSceneEnterType == EnterTypeList_2.WORLDBOSS_ENTER then
                g_worldBoss.new()
                         :addTo(warrior)    
            end
        end

        FightSceneEnterType = 0
    end
    print("-------------==================456--------MainSceneEnterType=="..MainSceneEnterType)

    --进入的参数处理
    if GuideManager.NextStep == 10401 and not getIsGuideClosed() then
        
    elseif MainSceneEnterType==EnterTypeList.MAIN_LINE then
        local areamap = g_blockMap.new(MainLineToAreaId, MainLineToBlockId, nil, true)
        areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
    elseif IsFightAgain or MainSceneEnterType == EnterTypeList.FIGHT_ENTER then
        MainSceneEnterType = EnterTypeList.FIGHT_ENTER
        local curAreaIdx
        local toAreaId
        g_isFirstIntoMainFromFight = true
        -- print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        if IsFightAgain then --再次战斗直接打开布阵界面，不打开关卡界面
            toAreaId = blockIdtoAreaId(curFightBlockId)
            areamap = g_blockMap.new(toAreaId, curFightBlockId)
            areamap:addTo(self, 50 , TAG_AREA_LAYER)
            BlockUI.new(block_idx,srv_blockData)
                    :addTo(display.getRunningScene(),51)
            EmbattleScene.new({BattleType_PVE, block_idx})
                :addTo(display.getRunningScene(),51)
            IsFightAgain = false
        elseif curFightBlockId==srv_userInfo["maxBlockId"] and blockData[curFightBlockId].type==1 then
            -- print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
            curAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
            toAreaId = string.format("10%03d", curAreaIdx) + 0
            if blockData[curFightBlockId].mainLine==1 and canAreaEnter(toAreaId+1) and srv_userInfo.level >= areaData[toAreaId+1].level then
                areamap = g_blockMap.new(toAreaId+1, curFightBlockId)
            else
                areamap = g_blockMap.new(toAreaId, curFightBlockId)
            end

            -- print("-----------------")
            -- print(g_fightBlockStar)
            -- print(canAreaEnter(toAreaId+1))
            -- print(g_fightBlockStar<=0)
            -- print(srv_blockData[curFightBlockId].star>0)
            --大区通关奖励
            if blockData[curFightBlockId].mainLine==1 and canAreaEnter(toAreaId+1) and g_fightBlockStar<=0 and srv_blockData[curFightBlockId].star>0 then
                local tmpAreaId = blockIdtoAreaId(curFightBlockId)
                local tmplclAreaData = areaData[tmpAreaId]
                local curRewards = {}
                table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=tmplclAreaData.gold})
                table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=tmplclAreaData.diamond})
                table.insert(curRewards, {templateID=GAINBOXTPLID_EXP, num=tmplclAreaData.exp})
                local rewardItems = lua_string_split(tmplclAreaData.rewardItems, "|")
                for i=1,#rewardItems do
                    local item = lua_string_split(rewardItems[i], "#")
                    table.insert(curRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
                end
                GlobalShowGainBox(nil, curRewards, 3)

                --更新金币钻石等数据
                srv_userInfo.gold = srv_userInfo.gold + tmplclAreaData.gold
                srv_userInfo.diamond = srv_userInfo.diamond + tmplclAreaData.diamond
                srv_userInfo.exp = srv_userInfo.exp + tmplclAreaData.exp
                mainscenetopbar:setGlod()
                mainscenetopbar:setDiamond()
            end
            areamap:addTo(self, 50 , TAG_AREA_LAYER)
        elseif curFightBlockId==srv_userInfo["maxEBlockId"] and blockData[curFightBlockId].type==2 then
            print("bbb")
            curAreaIdx = math.modf(srv_userInfo["maxEBlockId"]/1000)%1000
            toAreaId = string.format("10%03d", curAreaIdx) + 0
            if canAreaEnter(toAreaId+1,2) and srv_userInfo.level>=areaData[toAreaId+1].level then

                areamap = g_blockMap.new(toAreaId+1, curFightBlockId)
            else
                areamap = g_blockMap.new(toAreaId, curFightBlockId)
            end
            areamap:addTo(self, 50 , TAG_AREA_LAYER)
        elseif curFightBlockId and blockData[curFightBlockId].type==2 then
            curAreaIdx = math.modf(curFightBlockId/1000)%1000
            toAreaId = string.format("10%03d", curAreaIdx) + 0
            areamap = g_blockMap.new(toAreaId, curFightBlockId)
            areamap:addTo(self, 50 , TAG_AREA_LAYER)
        elseif curFightBlockId and blockData[curFightBlockId].type==3 then
            startLoading()
            local sendData={}
            sendData["areaId"]=srv_userInfo["areaId"]
            m_socket:SendRequest(json.encode(sendData), CMD_LEGION_BLOCK, self, self.onLegionBlockResult)
        else
            print("ccc")
            toAreaId = blockIdtoAreaId(curFightBlockId)
            areamap = g_blockMap.new(toAreaId, curFightBlockId)
            areamap:addTo(self, 50 , TAG_AREA_LAYER)
        end
        
        
    elseif MainSceneEnterType == EnterTypeList.GETEQUIPMENT_ENTER then
        -- 打开背包界面，同时打开指定的装备
        local backpack = backPackLayer.new()
        :addTo(cc.Director:getInstance():getRunningScene())
        backpack:setTag(TAG_BACKPACK_LAYER)

        g_combinationLayer.new(bpFightBackTmpId,handler(backpack,backpack.updateListView),101, 1)
        :addTo(backpack,10)

    elseif MainSceneEnterType == EnterTypeList.ROLEPROPERTY_ENTER then
        --属性界面
        local roleProperty = g_RolePropertyLayer.new()
        :addTo(cc.Director:getInstance():getRunningScene(),1)
        -- roleProperty.combinationLayer:createCombinationBox(g_comBackTmpId, nil, 102, 2)
        g_combinationLayer.new(RoleFightBackTmpId,handler(roleProperty,roleProperty.refreshUpgradePanel),102, 2)
        :addTo(MainScene_Instance,49)

    elseif MainSceneEnterType == EnterTypeList.CARPROPERTY_ENTER or MainSceneEnterType == EnterTypeList.CARADVANCE_ENTER then
        g_ImproveLayer.new()
            :addTo(cc.Director:getInstance():getRunningScene(), 1)
            MainScene_Instance:setTopBarVisible(false)
  
        
    elseif MainSceneEnterType == EnterTypeList.TEAM_ENTER then
        --进入军团界面，打开军团副本
        -- startLoading()
        -- local sendData = {}
        -- sendData["characterId"] = srv_userInfo["characterId"]
        -- m_socket:SendRequest(json.encode(sendData), CMD_MYLEGION_INFO, self, self.onMyLegionInfo)
        local legion = LegionLayer.new()
        self:addChild(legion)
        self:setTopBarVisible(false)
        if MainSceneEnterType == EnterTypeList.TEAM_ENTER then
            if next(legionFBData)==nil then
                startLoading()
                local sendData = {}
                m_socket:SendRequest(json.encode(sendData), CMD_LEGION_FB, legion.border:getChildByTag(MYLEGION_TAG), legion.border:getChildByTag(MYLEGION_TAG).onLegionFBResult)
            else
                g_legionFBLayer.new()
                :addTo(borderNode:getParent(),10)
            end
        end
        

    elseif MainSceneEnterType == EnterTypeList.EQUIPMENT_ENTER then
        --装备碎片返回
        local backpack = backPackLayer.new()
        :addTo(display.getRunningScene())
        backpack:setTag(TAG_BACKPACK_LAYER)
        --选择战车装备标签页
        backpack.BpTabBt1:setButtonEnabled(true)
        backpack.BpTabBt2:setButtonEnabled(false)
        backpack.img1:setTexture("SingleImg/BackPack/bp/human.png")
        backpack.img2:setTexture("SingleImg/BackPack/bp/carSelect.png")
        backpack:selectTab(2)
        --打开碎片框
        local piceCombiData = getPieceCombination(g_EptFightBackCompoundId)
        g_pieceMsgLayer.new(piceCombiData,handler(backpack,backpack.updateListView))
        :addTo(backpack,10)

    elseif MainSceneEnterType == EnterTypeList.BOUNTY_ENTER then
        --赏金首返回
        print("---------------------jklhg----,",GuideManager.NextStep,GuideManager.NextLocalStep)
        print("guideID==nil?",GuideManager.guideID == nil)
        print("socket.gettime(): ",socket.gettime())
        MainSceneEnterType = 0
        if GuideManager.NextLocalStep==20503 or GuideManager.NextLocalStep==20406 then--引导赏金首领奖那一步，才能打开赏金首
            --打开赏金首
            self.bounty = g_bounty.new()
            :addTo(display.getRunningScene())
            --进入关卡界面
            local areamap = g_blockMap.new(g_click_value.id, nil, blockData[curFightBlockId].type)
            areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
            MainSceneEnterType = EnterTypeList.BOUNTY_ENTER
        else
            --进入关卡界面
            local areamap = g_blockMap.new(g_click_value.id, nil, blockData[curFightBlockId].type)
            areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
            MainSceneEnterType = EnterTypeList.FIGHT_ENTER
        end

    elseif MainSceneEnterType == EnterTypeList.PVP_ENTER then
        PVPScene.new()
        :addTo(self)
    elseif MainSceneEnterType == EnterTypeList.TASK_ENTER then
        --任务关卡返回
        self.taskLayer = TaskLayer.new()
        :addTo(display.getRunningScene(),1,activityMenuLayerTag.taskTag)
        bTaskLayerOpened = true
        DCEvent.onEvent("点击任务图标")
    elseif MainSceneEnterType == EnterTypeList.FAILD_LINK1 or MainSceneEnterType == EnterTypeList.FAILD_LINK2 then
        print("装备强化，进阶")
        if string.sub(curFightBlockId, 2, 2)=="1" then --人战
             local scene = display.getRunningScene()
            g_RolePropertyLayer.new()
                :addTo(scene, 1)
        elseif string.sub(curFightBlockId, 2, 2)=="2" then --车战
            if 0==srv_userInfo.hasCar then
                showMessageBox("当前战车数量为0")
            else
                g_ImproveLayer.new()
                    :addTo(self,1)
            end
        end
    elseif MainSceneEnterType == EnterTypeList.FAILD_LINK3 then
        print("技能升级")
        g_RolePropertyLayer.new({seltag = 3})
        :addTo(display.getRunningScene(),1)
    elseif MainSceneEnterType == EnterTypeList.ACHIEVEMENT_ENTER then --进入成就
        self.achievementTree = achievementTree.new()
            :addTo(display.getRunningScene(),51,activityMenuLayerTag.achieveTag)
    else

    end
    --登录后主界面整合的接口
    local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_LOGIN_INFO, self, self.onLoginGetSrvInfo)
    --积分奖励红点
    local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_POINTREWARD, self, self.onPointReward)


    -- 背包红点、任务红点，邮件红点，不需要请求
    self:refreshEquipmentRedPoint()
    self:refreshTaskRedPoin()
    self:mailRedPoint()



    local function s_refreshTask_()
        local cmdData={}
        cmdData["tgtType"] = 2
        cmdData["cnt"] = 1
        m_socket:SendRequest(json.encode(cmdData), CMD_REFRESH_TASK, nil, nil)
        print(os.date("%H:%M:%S"))
    end
    
    s_refreshTask_()

    self.timeUpdateUtils3 = timeUpdateUtils.new("21:00",s_refreshTask_,0,function ()
        if energyTask[102020012]~=0 or tonumber(os.date("%H"))>23 then
            return true
        end
        return false
    end)
        :addTo(self)      
    self.timeUpdateUtils1 = timeUpdateUtils.new("18:00",s_refreshTask_,0,function ()
        if energyTask[102020011]~=0 or tonumber(os.date("%H"))>20 then
            return true
        end
        return false
    end)
        :addTo(self)
    self.timeUpdateUtils2 = timeUpdateUtils.new("12:00",s_refreshTask_,0,function ()
        if energyTask[102020010]~=0 or tonumber(os.date("%H"))>14 then
            return true
        end
        return false
    end)
        :addTo(self)      

    if gType_SDK == AllSdkType.Sdk_MSDK and device.platform == "android" then
        RechargeManager:checkNofinishedOrder()
    end
    if device.platform == "ios" then
        rechargeLayer:checkIOSOrder()
    end
    DCCoin.setCoinNum(srv_userInfo.gold,"金币")
    DCCoin.setCoinNum(srv_userInfo.diamond,"钻石")
    DCCoin.setCoinNum(srv_userInfo.exploit,"功勋")
    DCCoin.setCoinNum(srv_userInfo.reputation,"声望")
    DCCoin.setCoinNum(srv_userInfo.expedition,"远征币")

    local mainLineGuide = require("app.widget.mainLineGuide")
    self._mainLineGuide = mainLineGuide.new()
            :addTo(self)

    --华为登录统计 必需
    if isHUAWEILogin then
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaRoleInfoForHuawei", {tostring(srv_userInfo.level),srv_userInfo.name,loginServerList.serverName,srv_userInfo.armyName or "战车世纪"}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    elseif isOPPOLogin then
        OppoSDK:OppoUpRoloInfo(tostring(srv_userInfo.level),srv_userInfo.name,loginServerList.serverName)
    elseif isKURUILogin then
        KuRuiSDK:KuRuiUpRoloInfo(KuRuiRoleInfoType.KuRui_enterServer)
    elseif isVIVOLogin then
        VivoSDK:VivoUpRoloInfo()
    end

    --推送
    -- if GameData.pushTags == nil then
    --     GameData.pushTags = jpushTags
    --     GameState.save(GameData)
    --     jpushSDK:setTag()
    -- end

end
function MainScene:onLoginGetSrvInfo(result)
    if result.result==1 then
        local data = result.data
        --免费聊天次数红点
        -- if chatBoxLayer then
        --     chatBoxLayer:onChatFreeTimes(data["23000"])
        -- end
        --离线消息红点
        self:onOffLineChatMsg(data["23002"])
        --好友红点
        self:onFriendApplyResult(data["20008"])
        --抽卡红点
        self:onGetLotCardRestTimeResult(data["19004"])
        --车库红点
        self:onCalSklInfo(data["15013"])
        --酒吧，赏金首红点
        if BarMgr then
            BarMgr:OnInitInfoRet(data["14022"])
        end
        --限时活动
        -- self:limitConsumeRedPoint(data["19007"])
        --乘降红点
        self:TakeDownRedPoint(data["15010"])
    else
        showTips(result.msg)
    end
end

function MainScene:onExit()
    GuideManager:removeGuideLayer()
    -- display.removeSpriteFramesWithFile("SingleImg/MainScene/moonLigth.plist", "SingleImg/MainScene/moonLigth.png")

    -- display.removeSpriteFramesWithFile("CCStudio/MainScene0.plist", "CCStudio/MainScene0.png")
    -- display.removeSpriteFramesWithFile("CCStudio/MainScene1.plist", "CCStudio/MainScene1.png")
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    self.timeUpdateUtils1:removeSelf()
    self.timeUpdateUtils2:removeSelf()

    chatBoxLayer = nil
    mainscenetopbar = nil
    MainScene_Instance = nil
    ActivityMenuBar = nil
    
    sceneOnExit()
end
--系统设置头像
function MainScene:createPlayerHead()
    --头像框
    local headBox = display.newSprite("#MainUI_img28.png")
    :addTo(self)
    :align(display.TOP_LEFT, 10,display.height + 2)


    local headBt
    headBt = cc.ui.UIPushButton.new("Head/headman_"..memberData[srv_userInfo["templateId"]].resId..".png")
        :addTo(headBox)
        :pos(headBox:getContentSize().width/2, headBox:getContentSize().height/2+3)
        :scale(1.1)
    headBt:onButtonPressed(function(event)
        -- event.target:setScale(1.0)
        headBox:setPositionY(display.height)
        end)
    headBt:onButtonRelease(function(event)
        -- event.target:setScale(1.1)
        headBox:setPositionY(display.height+2)
        end)
    headBt:onButtonClicked(function(event)
        systemLayer.new()
        :addTo(self,52)
        end)
    self.headBt = headBt

    --镇名
    local townBar = display.newSprite("#MainUI_img29.png")
    :addTo(self)
    :align(display.TOP_LEFT, 150,display.height + 1)

    self.townName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(129, 157, 163)})
    :addTo(townBar)
    :align(display.CENTER, townBar:getContentSize().width/2, 20)

    local townName = areaData[areaData[srv_userInfo.areaId].resId].name2
    self.townName:setString(townName)
    
    
    --名字条
    local nameBar = display.newSprite("#MainUI_img30.png")
    :addTo(self)
    :align(display.CENTER_LEFT, 140, display.height - 88)

    --vip
    local star = display.newSprite("#MainUI_img33.png")
    :addTo(nameBar)
    :pos(20,20)

    local img_V = display.newSprite("common/common_V.png")
    :addTo(star)
    :pos(10,star:getContentSize().height/2)
    :scale(0.66)

    self.vipNum = cc.LabelAtlas:_create()
                        :align(display.CENTER, 25,star:getContentSize().height/2)
                        :addTo(star)
                        :scale(0.66)
        self.vipNum:initWithString("",
            "common/common_Num3.png",
            22,
            29,
            string.byte(0))
    self.vipNum:setString(srv_userInfo.vip)
    if srv_userInfo.vip>=10 then
        self.vipNum:setPositionX(28)
    else
        self.vipNum:setPositionX(25)
    end

    --角色等级
    local levelBar = display.newSprite("#MainUI_img36.png")
    :addTo(headBox)
    :pos(headBox:getContentSize().width/2,0)
    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "LV", size = 20, color =cc.c3b(105, 120, 122)})
    :addTo(levelBar)
    :pos(15, levelBar:getContentSize().height/2-2)
    self.charactorLevel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20,color =cc.c3b(248, 182, 45)})
    :addTo(levelBar)
    :pos(43, levelBar:getContentSize().height/2-2)
    self.charactorLevel:setString(srv_userInfo.level)

    --善恶
    local goodBadBt = cc.ui.UIPushButton.new("#MainUI_img32.png")
    :addTo(nameBar)
    :pos(nameBar:getContentSize().width/2, 44)
    :onButtonPressed(function(evnet)
        if not g_isBanShu then
            self.goodBadMsgBox:setVisible(true)
        end
        
        end)
    :onButtonRelease(function(evnet)
        if not g_isBanShu then
        self.goodBadMsgBox:setVisible(false)
            end
        end)


    local bottomBar = display.newSprite("#MainUI_img32.png")
    :addTo(goodBadBt)
    
    -- printTable(srv_userInfo)
    local per = 0.5-srv_userInfo["goodEvil"]/10000
    print(per)
    per = math.max(per,0)
    per = math.min(per,1)
    cc.ui.UILoadingBar.new({image = "#MainUI_img31.png", viewRect = cc.rect(0,2,208,16)})
    :addTo(bottomBar)
    :setPercent(per*100)

    --善恶显示框
    self.goodBadMsgBox = display.newScale9Sprite("common/common_Frame23.png",520, 
        display.height - 120,
        cc.size(220, 100))
    :addTo(self,10)
    self.goodBadMsgBox:setVisible(false)
    cc.ui.UILabel.new({UILabelType = 2, text = "当前阵营：", size = 20, color = MYFONT_COLOR})
    :addTo(self.goodBadMsgBox)
    :pos(20, 70)

    local zyLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(255, 255, 0)})
    :addTo(self.goodBadMsgBox)
    :pos(120, 70)

    local gbLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = MYFONT_COLOR})
    :addTo(self.goodBadMsgBox)
    :pos(20, 30)

    local gbnum = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(255, 255, 0)})
    :addTo(self.goodBadMsgBox)
    :pos(100, 30)

    if per==0.5 then
        zyLabel:setString("中立")
        gbLabel:setString("善恶值：")
        gbnum:setString("0")
    elseif per<0.5 then --善
        cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 16, color = cc.c3b(127, 79, 33)})
        :addTo(nameBar,2)
        :align(display.CENTER_RIGHT, nameBar:getContentSize().width-10, 44)
        :setString(srv_userInfo["goodEvil"])

        zyLabel:setString("善")
        gbLabel:setString("善值：")
        gbnum:setString(srv_userInfo["goodEvil"])
        gbnum:setColor(cc.c3b(0, 255, 0))
    else
        cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 16, color = cc.c3b(43, 0, 0)})
        :addTo(nameBar,2)
        :align(display.CENTER_LEFT, 5, 44)
        :setString((-srv_userInfo["goodEvil"]))

        zyLabel:setString("恶")
        gbLabel:setString("恶值：")
        gbnum:setString((-srv_userInfo["goodEvil"]))
        gbnum:setColor(cc.c3b(255, 0, 0))
    end
    if per>1 then
        per=1
    end
    display.newSprite("#MainUI_img34.png")
    :addTo(bottomBar)
    :pos(bottomBar:getContentSize().width/2+bottomBar:getContentSize().width*(per-0.5), 8)


    --角色名字
    self.charactorName = cc.ui.UILabel.new({font = "font/arial.ttf",UILabelType = 2, text = "", size = 23, color = cc.c3b(202, 202, 202)})
    :addTo(nameBar)
    :align(display.CENTER, nameBar:getContentSize().width/2 + 5, 18)
    self.charactorName:setString(srv_userInfo.name)
    if srv_userInfo.vip>0 then
        self.charactorName:setColor(cc.c3b(255, 219, 37))
    else
        self.charactorName:setColor(cc.c3b(202, 202, 202))
    end
    
end


function MainScene:setTopBarVisible(visible)
    if mainscenetopbar~=nil then
        mainscenetopbar:setVisible(visible)
    end
end
function MainScene:setMainMenuVisible(visible)
    -- self.mainscenemenu:setVisible(visible)
end
function MainScene:getTopBarVisible()
    local ret = nil 
    if mainscenetopbar~=nil then
        ret = mainscenetopbar:isVisible()
    end
    return ret
end
function MainScene:getMainMenuIsVisible()
    -- return self.mainscenemenu:isVisible()
end
--返回主界面的必要操作
function MainScene:backToMainScene()
    self:setTopBarVisible(true)
    -- self:setMainMenuVisible(true)
    MenuLayerFlag=0
    -- self.mainscenemenu:setMainMenuOpening(true)
end

--玩家头像信息等
function MainScene:playerMsgBox()
    local headMsg = display.newSprite("MainUI/playerMsgBar.png")
    :addTo(self)
    :pos(10, display.height - 10)
    headMsg:setAnchorPoint(0,1)
end

function MainScene:onLegionExitResult(result)
    if result["result"]==1 then
        showMessageBox("已退出军团！")
        srv_userInfo["armyName"]=""
        mLegionData  = {}
        self.legion:setVisible(false)
        self.exitLegionBt:setVisible(false)
        mLegionData  = {}
    else
        showTips(result.msg)
    end
end

function MainScene:OnGetPVPInfoRet(result)
    if tonumber(result["result"]) == 1 then
        PVPData = result["data"]
        PVPScene.new()
        :addTo(self)
    else
        -- addMessageBox(self, 80)
        showTips(result["msg"])
    end
    
end




function MainScene:onEnterBlockResult(result)
    areamap:onEnterBlockResult(result)
end
--初始化军团
function MainScene:onEnterLegionResult(result)
    if result["result"]==1 then
        local legion = LegionLayer.new()
        self:addChild(legion,2)
        self:setTopBarVisible(false)
    else
        showTips(result.msg)
    end
end
--主界面军团
function MainScene:onMyLegionInfo(result)
    if result.result ==1 then
        local legion = LegionLayer.new()
        self:addChild(legion, 2)
        self:setTopBarVisible(false)

        if MainSceneEnterType == EnterTypeList.TEAM_ENTER then
            if next(legionFBData)==nil then
                startLoading()
                local sendData = {}
                m_socket:SendRequest(json.encode(sendData), CMD_LEGION_FB, legion.border:getChildByTag(MYLEGION_TAG), legion.border:getChildByTag(MYLEGION_TAG).onLegionFBResult)
            else
                g_legionFBLayer.new()
                :addTo(borderNode:getParent(),10)
            end
        end
    elseif result.result==-2 then --可能被人踢出但是客户端不知道
        srv_userInfo.armyName=""
        startLoading()
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["No"] =  0
        m_socket:SendRequest(json.encode(sendData), CMD_LEGION_ENTER, self, self.onEnterLegionResult)
    else
        showTips(result.msg)
    end
end

function MainScene:onSelectAreaResult(result)
    if result.result==1 then
        print("服务端更新城镇成功！")
    end
end


function MainScene:onOffLineChatMsg(result)
    if result.result==1 then
        --数据处理
        chatOffLineMsg = result.data
        for i=1,#chatOffLineMsg do
          table.insert(chatRecordList.Private, 1, chatOffLineMsg[i])
        end
        if #chatRecordList.Private>15 then --最多保存15条
          for i=16,#chatRecordList.Private do
            table.remove(chatRecordList.Private, i)
          end
        end
        saveLocalGameDataBykey("chatRecordList", chatRecordList)

        -- print("获取离线=============")
        local node = self.activityMenuBar.chatBt
        node:removeChildByTag(10)
        if #chatOffLineMsg>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
    end
    
end
--好友红点
function MainScene:onFriendApplyResult(result)
    endLoading()
    if result.result==1 then
        FriendApplyData = result.data
        local node = self.activityMenuBar.friendBt
        node:removeChildByTag(10)
        if #FriendApplyData>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
    else
        showTips(result.msg)
    end
    
end
--获取抽卡免费时间
function MainScene:onGetLotCardRestTimeResult(result)
    if result["result"]==1 then
        if result.data.diffTS==0 or (result.data.goldTS==0 and result.data.goldFreeCnt<5) then
            self:refreshCardRedPt(true)
        end
    end
end
--抽卡
function MainScene:refreshCardRedPt(bIsRed)
    if bIsRed then
        if not self.roleMenuBar.lotterycardBt:getChildByTag(10) then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(self.roleMenuBar.lotterycardBt,0,10)
            :pos(40,40)
        end
    else
        self.roleMenuBar.lotterycardBt:removeChildByTag(10)
    end
end
--装备红点
function MainScene:refreshEquipmentRedPoint()
    local node = self.roleMenuBar.backpackBt
    node:removeChildByTag(10)
    if not node:getChildByTag(10) and (bAllEquipmentCanCom() or next(g_BPNewItems)~=nil) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(40,40)
    end
end
function MainScene:refreshFundRedPoint()
    --新手基金
    local num = TaskMgr:GetCanSubNum(TaskTag.newfund) + TaskMgr:GetCanSubNum(TaskTag.oldfund)
    local node = self.activityMenuBar.fundBt
    node:removeChildByTag(10)
    if num>0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(30,30)
    end
end
--任务红点
function MainScene:refreshTaskRedPoin()
    self:refreshFundRedPoint()
    --在线奖励（功能已关闭）
    -- if self.activityMenuBar.onlineActivity then
    --     local num = TaskMgr:GetCanSubNum(TaskTag.Online)
    --     local node = self.activityMenuBar.onlineActivity
    --     node:removeChildByTag(10)
    --     if num>0 then
    --         local RedPt = display.newSprite("common/common_RedPoint.png")
    --         :addTo(node,0,10)
    --         :pos(30,30)

    --         -- print("出现奖励二字")
    --         -- g_onlineLabel:setVisible(false)
    --         -- g_awardLabel:setVisible(true)
    --         -- setLabelVisible(g_OLretNode, false)
    --     end
    -- end
    
    
    --任务
    local num = TaskMgr:GetCanSubNum(TaskTag.Daily)
    local node = self.activityMenuBar.taskBt
    node:removeChildByTag(10)
    if num>0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(30,30)
        
    end

    --成就
    num = TaskMgr:GetCanSubNum(TaskTag.Achievement)
    node = self.activityMenuBar.achievementBt
    node:removeChildByTag(10)
    if num>0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(30,30)
    end

    --签到
    node = self.activityMenuBar.signBt
    node:removeChildByTag(10)
    if srv_userInfo.checkInStatus==0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(30,30)
    end

    --七日大礼
    num = TaskMgr:GetCanSubNum(TaskTag._7DayGift)
    node = self.activityMenuBar.startServerBt
    if TaskMgr.hasSevenDay==false then
        node:setVisible(false)
    end
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
    end

    --优惠
    local handler = {}
    local node3 = self.activityMenuBar.discountBt
    function handler:_callback(cmd)
        if node3==nil or cmd.result~=1 then
            return
        end
        print("================ooooooooooooopopop----")
        srv_userInfo.actInfo = cmd.data
        local activityStates = cmd.data.actSts
        printTable(activityStates)
        local num = TaskMgr:GetCanSubNum(TaskTag.Recharge)--七日礼包和首冲是一直存在的
        print("七日礼包+首冲",num)
        for k,v in pairs(activityStates) do
            if v==1 then
                if k=="1"then       --限时消费
                    --这个没法算
                elseif k=="2" then   --限时促销
                    --这个不需要算红点
                elseif k=="3" then   --首周福利
                    num = num + TaskMgr:GetCanSubNum(TaskTag.FreeDiamond)
                     print("首周福利",TaskMgr:GetCanSubNum(TaskTag.FreeDiamond))
                elseif k=="4" then   --累计消费
                    num = num + TaskMgr:GetCanSubNum(TaskTag.TotalConsume)
                     print("累计消费",TaskMgr:GetCanSubNum(TaskTag.TotalConsume))
                elseif k=="11" then  --基金活动
                    --不需要红点
                elseif k=="12" then  --开服冲级
                    num = num + TaskMgr:GetCanSubNum(TaskTag.levelGift)
                elseif k=="17" then  --猎人豪礼
                    num = num + TaskMgr:GetCanSubNum(TaskTag.levelGift_2)
                end
            end
        end

        print("所有：",num)
        node3:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node3,0,10)
            :pos(30,30)
        else
            if activityStates["14"]==1 then   --累计充值
                local _handler = {}
                function _handler:func(cmd)
                    if node3==nil or cmd.result~=1 then
                        return
                    end
                    local list = cmd.data.idList
                    if cmd.data.isReward==1 then
                        node3:removeChildByTag(10) 
                        local RedPt = display.newSprite("common/common_RedPoint.png")
                            :addTo(node3,0,10)
                            :pos(30,30)
                    end
                end
                local sendData = {}
                m_socket:SendRequest(json.encode(sendData), CMD_TOTALRECHARGE_INIT, _handler, _handler.func)
            end
            if activityStates["4"]==1 then    --累计消费  
                local _handler = {}
                function _handler:func(cmd)
                    if node3==nil or cmd.result~=1 then
                        return
                    end
                    local list = cmd.data.idList
                    if cmd.data.isReward==1 then
                        node3:removeChildByTag(10) 
                        local RedPt = display.newSprite("common/common_RedPoint.png")
                            :addTo(node3,0,10)
                            :pos(30,30)
                    end
                end
                local sendData = {}
                m_socket:SendRequest(json.encode(sendData), CMD_TOTALCONSUME_INIT, _handler, _handler.func)
            end
            if activityStates["1"]==1 then      --限时消费
                local _handler = {}
                function _handler:func(cmd)
                    if node3==nil or cmd.result~=1 then
                        return
                    end
                    for i=1,#cmd.data.itemInfo do
                        redPtTag[cmd.data.itemInfo[i].id] = false
                        if cmd.data.itemInfo[i].buyTimes==0 then
                            redPtTag[cmd.data.itemInfo[i].id] = true
                            print("------------xxv")
                        end
                    end
                    if getLimitConsumeRedBool() then
                        node3:removeChildByTag(10)
                        local RedPt = display.newSprite("common/common_RedPoint.png")
                        :addTo(node3,0,10)
                        :pos(30,30)
                    end
                end
                local sendData = {}
                m_socket:SendRequest(json.encode(sendData), CMD_GETLIMITCOMSUME, _handler, _handler.func)
            end
        end

    end
    
    m_socket:SendRequest(json.encode({}), CMD_BUSINESS_OPEN, handler, handler._callback)


    
end
function MainScene:limitConsumeRedPoint(cmd)
    if cmd.result==1 then
        for i=1,#cmd.data.itemInfo do
            redPtTag[cmd.data.itemInfo[i].id] = false
            if cmd.data.itemInfo[i].buyTimes==0 then
                redPtTag[cmd.data.itemInfo[i].id] = true
            end
        end

        if discountInstance then
            discountInstance:refreshActivityRedPoint()
        end
        if num~=0 then
            return
        end
        node:removeChildByTag(10)
        if getLimitConsumeRedBool() then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
    else
        
    end
    

    
end
--邮件红点
function MainScene:mailRedPoint()
    local node = self.activityMenuBar.mailBt
    node:removeChildByTag(10)
    if MailMgr.canReadNum>0 then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(30,30)
    end
end
--乘降红点
function MainScene:TakeDownRedPoint(result)
    if result.result==1 then
        local flag = false
        local flag2 = false
        for i,value in ipairs(result.data.members) do
            if value.carTmpId==0 then
                flag = true
                break
            end
        end
        for i,value in ipairs(result.data.cars) do
            if value.carMember.memberId==0 then
                flag2 = true
                break
            end
        end
        if flag and flag2 then
            local node = self.roleMenuBar.chengjiangBt
            node:removeChildByTag(10)
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(40,40)
        end
    else
        showTips(result.msg)
    end
end
--积分奖励接口返回
function MainScene:onPointReward(result)
    if result.result==1 then
        local node = self.activityMenuBar.sendVIPBt
        local data = result.data 
        if data.point==-1 then --活动已完成需关闭
            node:setVisible(false)
            return
        elseif data.isReward==1 then --有红点显示
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
        node:setVisible(true)
    else
        showTips(result.msg)
    end
end



--军团副本
function MainScene:onLegionBlockResult(result)
    endLoading()
    lgionFBResult = result.result
    if lgionFBResult==-2 then
        showTips("加入军团，才可挑战军团副本")
        return
    elseif lgionFBResult==-4 or lgionFBResult==-5 then
        showTips(result.msg)
    end
    srv_blockArmyData = result.data

    local ToAreaId = blockIdtoAreaId(curFightBlockId)
    local areamap = g_blockMap.new(ToAreaId, nil, 3)
    areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
end
--战车技能信息
function MainScene:onCalSklInfo(cmd)
    endLoading()
    if cmd.result==1 then
        main_carSklData = cmd.data.carsSkl
        self:improveRedPoint()
    end
end
function MainScene:improveRedPoint()
    local flag = false
    --条件一，有可激活的技能
    for key,value in ipairs(main_carSklData) do
        print(value.id)
        if value.id~=1003 then
            local carAllStarNum = getCarAllStars(value.id)
            for i=1,4 do
                local keyStr = "skl"..i.."Sts"
                if value[keyStr]<1 and carAllStarNum>=CarSkillActStar[i] then
                    -- print(keyStr)
                    flag = true
                    break
                end
            end
        end
    end
    --条件二，有可进阶的装备
    local tmpIt = getBeEquippedItem()
    for i,value in ipairs(tmpIt) do
        if bItemCanAdvance(value.tmpId) then
            flag = true
            break
        end
    end

    if flag then --需要小红点
        if self.SklRedPoint==nil then
            self.SklRedPoint = display.newSprite("common/common_RedPoint.png")
            :addTo(self.roleMenuBar.improveBt)
            :pos(40,40)
        end
    else
        if self.SklRedPoint then
            self.SklRedPoint:removeSelf()
            self.SklRedPoint=nil
        end
    end
end
--赏金首红点
function MainScene:OnInitInfoRet(cmd)
    if cmd.result==1 then
        local node = self.activityMenuBar.bountyBt
        node:removeChildByTag(10)

        local bossDataList = self:getBountyBossData(cmd.data)
        local isRed = false
        for i=1,math.ceil(#bossDataList) do
            local blockValue = bossDataList[i]
            local value = areaData[blockValue.areaId]
            if bossDataList[i].status~=2 and canAreaEnter(value.id, 1) and srv_userInfo.level >= areaData[value.id].level then
                isRed = true
                break
            end
        end
        if isRed then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(30,30)
        end
    end
end
function MainScene:getBountyBossData(bountyInfoData)
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
    for i,value in ipairs(bountyInfoData.freeBty) do
        for j,val in ipairs(bossDataList) do
            if value==val.id then
                bossDataList[j].status = 1
            end
        end
        
    end
    for i,value in ipairs(bountyInfoData.gotBty) do
        for j,val in ipairs(bossDataList) do
            if value==val.id then
                bossDataList[j].status = 2
            end
        end
    end

    return bossDataList
end



--公告返回接口
function MainScene:onNoticeHttpResponse(event)
    local request = event.request
    printf("onLoginHttpResponse - event.name = %s", event.name)
    if event.name == "completed" then
        printf("REQUEST - getResponseStatusCode() = %d", request:getResponseStatusCode())
        printf("REQUEST - getResponseHeadersString() =\n%s", request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            print("code ", request:getResponseStatusCode())
            return 
        else
            printf("REQUEST - getResponseDataLength() = %d", request:getResponseDataLength())
            printf("REQUEST - getResponseString() =\n%s", httpNet.getUnTeaResponseString(request))

            local loginResult = httpNet.getUnTeaResponseString(request)
            local jLoginResult= json.decode(loginResult)
            if jLoginResult["result"] == 1 then --获取公告成功
                print("获取公告成功")
                printTable(jLoginResult)
                local noticedata = jLoginResult.data.notices
                endLoading()

                --弹出公告框
                if #noticedata==0 then
                    return
                end
                self:createNoticePanel(noticedata)
            end

        end
    elseif event.name == "progress" then
        --printf("REQUEST - total:%d, have download:%d", event.total, event.dltotal)
        local percent = 0
        if event.total and 0 ~= event.total then
            percent = event.dltotal*100/event.total
        end
        --printf("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent)
    else
        printf("REQUEST - getErrorCode() = %d, getErrorMessage() = %s", request:getErrorCode(), request:getErrorMessage())
        showMessageBox("网络连接失败")
    end
end
function MainScene:createNoticePanel(noticedata)
    local noticePanel = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 200))
    :addTo(self,1000)

    local posY = { display.cy-77, }
    for i=1,4 do
        local bar = display.newSprite("common2/com2_Img_19.png")
        :addTo(noticePanel, 1,99)
        :pos(display.cx, (display.cy-238)+(i-1)*155)

        if i<4 then
            display.newSprite("common2/com2_Img_18.png")
            :addTo(bar,-1)
            :pos(35, bar:getContentSize().height)

            display.newSprite("common2/com2_Img_18.png")
            :addTo(bar,-1)
            :pos(bar:getContentSize().width - 35, bar:getContentSize().height)
        end
        
    end

    local img = display.newSprite("common2/com2_Img_20.png")
    :addTo(noticePanel, 1,100)
    :pos(display.cx, display.cy)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(30, 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(30,img:getContentSize().height - 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(img:getContentSize().width - 40, 30)

    display.newSprite("common2/com2_Img_17.png")
    :addTo(img)
    :pos(img:getContentSize().width - 40, img:getContentSize().height - 30)


    --关闭按钮
    createCloseBt()
    :addTo(noticePanel, 1,102)
    :pos(display.cx+505, display.cy+270)
    :onButtonClicked(function(event)
        noticePanel:removeSelf()
        end)


    local noticeId = noticedata[1].id
    webview = ccexp.WebView:create()
        img:addChild(webview, 100)
        webview:setVisible(true)
        webview:setScalesPageToFit(true)
        local url = DIR_SERVER_URL.."/userver/common/getNotice?data="
        local data = "{\"nId\":"..noticeId..",\"chnlId\":"..gType_Chnl.."}"
        local data = encodeURI(data)
        url = url..data
        webview:loadURL(url)
        webview:setContentSize(cc.size(790,500)) -- 一定要设置大小才能显示
        webview:reload()
        webview:setPosition(img:getContentSize().width/2,img:getContentSize().height/2)

end
function MainScene:GetResNum()
    local num = 4
    if MainSceneEnterType~=0 or FightSceneEnterType~=0 then
        print("MainScene:GetResNum")
        return 1
    end
    return num
end
function MainScene:LoadResAsync()
    if nil==g_LoadingScene or nil==g_LoadingScene.Instance then
        return
    end

    local instance = g_LoadingScene.Instance
    -- display.addSpriteFrames("CCStudio/MainScene0.plist", "CCStudio/MainScene0.png", handler(instance, instance.ImgDataLoaded))
    -- display.addSpriteFrames("CCStudio/MainScene1.plist", "CCStudio/MainScene1.png", handler(instance, instance.ImgDataLoaded))
    -- display.addSpriteFrames("SingleImg/MainScene/moonLigth.plist", "SingleImg/MainScene/moonLigth.png", handler(instance, instance.ImgDataLoaded))

    

    if MainSceneEnterType==0 and FightSceneEnterType==0 then
        --主界面背景图
        display.addImageAsync("Block/area_"..mapAreaId.."/city_bg.jpg",
                function(texture)
                    if texture ~= nil then
                        --texture:retain()
                        --instance:ImgDataLoaded()
                    end
                end)
        print("loading Improve")
        --抽卡
        
        -- display.addSpriteFrames("LotteryCard/card_bt.plist", "LotteryCard/card_bt.png", handler(instance, instance.ImgDataLoaded))
        -- display.addSpriteFrames("LotteryCard/card_light.plist", "LotteryCard/card_light.png", handler(instance, instance.ImgDataLoaded))
        -- display.addSpriteFrames("LotteryCard/card_out.plist", "LotteryCard/card_out.png", handler(instance, instance.ImgDataLoaded))
        --改造中心
        display.addSpriteFrames("Image/improve2_img.plist", "Image/improve2_img.png", handler(instance, instance.ImgDataLoaded))
        display.addSpriteFrames("Effect/Improve_Eff1.plist", "Effect/Improve_Eff1.png", handler(instance, instance.ImgDataLoaded))
        --属性
        display.addSpriteFrames("Image/RoleProperty2.plist", "Image/RoleProperty2.png", handler(instance, instance.ImgDataLoaded))

    else
        print("not loading Improve")
    end
    display.addSpriteFrames("Image/MainUI_img.plist", "Image/MainUI_img.png", handler(instance, instance.ImgDataLoaded))
end

function MainScene:caculateGuidePos(_guideId)
    print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    local _clearBol = true
    if 11401==_guideId or 10301==_guideId or 11301==_guideId or 11401==_guideId or 11501==_guideId 
    or 10101==_guideId or 10601==_guideId or 11001==_guideId or 10401==_guideId 
    or 11201==_guideId or 10201==_guideId or 11101==_guideId or 11601==_guideId or 11701==_guideId 
    or 10801==_guideId or 12701==_guideId or 12801==_guideId or 12702==_guideId or 12802==_guideId 
    or 13001==_guideId or 12601==_guideId or 12602==_guideId or 12501==_guideId 
    or 12401==_guideId or 10901==_guideId or 12201==_guideId or 20201==_guideId or 20401==_guideId 
    or 20501==_guideId or 10701==_guideId or 10501==_guideId or 12101==_guideId or 12301==_guideId then
        if 10101==_guideId or 10201==_guideId or 11101==_guideId or 11301==_guideId or 12401==_guideId or 10501==_guideId 
            or 11601==_guideId or 11701==_guideId then
            g_node = fightBt
            _clearBol = false
        elseif 10301==_guideId then
            g_node = self.activityMenuBar.taskBt
        elseif 11401==_guideId or 11501==_guideId or 12101==_guideId or 20201==_guideId then
            g_node = self.roleMenuBar.rolePropertyBt
        elseif 10601==_guideId then
            g_node = self.roleMenuBar.lotterycardBt
        elseif 11001==_guideId or 10701==_guideId or 10801==_guideId or 12501==_guideId or 10901==_guideId then
            g_node = self.roleMenuBar.improveBt
        elseif 12301==_guideId then
            g_node = self.roleMenuBar.backpackBt
        elseif 10401==_guideId then
            g_node = self.roleMenuBar.chengjiangBt
        elseif 13001==_guideId then
             g_node = self.activityMenuBar.legionBt
        elseif 12601==_guideId then
            g_node = self.roleMenuBar.ArenaBt
        elseif 12701==_guideId or 12801==_guideId then
            g_node = self.roleMenuBar.WarCenterBt
        elseif 12201==_guideId then
            g_node = self.activityMenuBar.taskBt
        elseif 20401==_guideId or 20501==_guideId or 11201==_guideId then
            g_node = self.activityMenuBar.bountyBt
        end
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
        if _clearBol then
            self:clearMainscene(false)
        end
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end


function MainScene:hideMainScene()
    self.roleMenuBar:runAction(cc.MoveBy:create(0.2, cc.p(0,-300)))
    self.BoardBt:runAction(cc.MoveBy:create(0.2, cc.p(0,-300)))
    fightBt:runAction(cc.MoveBy:create(0.2, cc.p(0,-300)))
    self.fight_Circle:runAction(cc.MoveBy:create(0.2, cc.p(0,-300)))
    -- self.activityMenuBar:runAction(toDown_act)
end
--世界BOSS收到组队请求
function MainScene:receiveHelpMsgPush(cmd)
    if 1==cmd.result then
        local tag = 23098
        if self:getChildByTag(tag)~=nil then
            self:removeChildByTag(tag)
        end
        self.helpTagBtn = cc.ui.UIPushButton.new{normal = "SingleImg/worldBoss/bossBtn_01.png"}
            :addTo(self,1,tag)
            :align(display.RIGHT_CENTER,display.width,display.height*0.7)
            :onButtonPressed(function(event)
                event.target:setScale(0.95)
                end)
            :onButtonRelease(function(event)
                event.target:setScale(1.0)
                end)
            :onButtonClicked(function (event)
                g_worldBoss.new()
                    :addTo(self,53)

                local btn = event.target
                btn:removeSelf()
            end)
        -- display.newSprite("SingleImg/worldBoss/bossTag_06.png")
        --         :addTo(self.helpTagBtn)
        --         :pos(-110,100)
    else

    end
end

--关闭所有其他子页面,并添加新手引导
function MainScene:clearMainscene(_isGuide)
    print("清理主界面\n\n\n\n")

    -- if UIGameBox_Instance ~=nil then
    --     UIGameBox_Instance:removeSelf()
    -- end
    
    if messageBoxLayer ~= nil then
        messageBoxLayer:removeSelf()
        messageBoxLayer = nil
    end

    if blockUI_Instance~=nil then
        blockUI_Instance:removeSelf()
    end
    if blockMap_Instance~=nil then
        blockMap_Instance:removeSelf()
    end
    if TaskLayer.Instance~=nil then
        TaskLayer.Instance:removeSelf()
    end
    if achievementTree.Instance~=nil then
        achievementTree.Instance:removeSelf()
    end

    
    if isNodeValue(combinationLayer_Instance) then
        combinationLayer_Instance:removeSelf()
    end
    if RolePropertyLayer_Instance~=nil then
        RolePropertyLayer_Instance:removeSelf()
    end
    if isNodeValue(ImproveLayer_Instance) then
        ImproveLayer_Instance:removeSelf()
    end
    if BackPack_Equipment_Instance~=nil then
        BackPack_Equipment_Instance:removeSelf()
    end
    
    
    
    self.charactorLevel:setString(srv_userInfo.level)

    if _isGuide then
        if srv_userInfo.level>=10 then   --
            print("主界面addGuide，12101")
            self:addGuide_ani(12101)
        end
        if srv_userInfo.level>=12 then
            self:addGuide_ani(12201)
        end
        self:addGuide_ani(12301)
        if srv_userInfo.level>=14 then
            self:addGuide_ani(12401)
        end
        if srv_userInfo.level>=15 then
            self:addGuide_ani(12501)
        end
        if srv_userInfo.level>=16 then
            self:addGuide_ani(12601)    --出现竞技场按钮
        end
        if srv_userInfo.level>=20 then
            self:addGuide_ani(12701)    --遗迹探测，出现勇士中心按钮
        end
        if srv_userInfo.level>=25 then
            self:addGuide_ani(12801)    
        end
        if srv_userInfo.level>=28 then
            self:addGuide_ani(12901)    --出现军团按钮
        end
    end
end

function MainScene:onSocketConnected(__event)
    roleLoginData["chnlId"] = gType_Chnl
    roleLoginData["ver"] = g_Version
    startLoading()
    m_socket:SendRequest(json.encode(roleLoginData), CMD_ROLE_LOGIN, self, self.onRoleLoginResult)
    
end

function MainScene:onRoleLoginResult(result)
    endLoading()
    if result["result"] == 1 then
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    elseif result["result"] == -2 then
        display.removeUnusedSpriteFrames()
        app:enterScene("LoginScene",{1})
    else
        
        showTips(result.msg)
    end

end

return MainScene