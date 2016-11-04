-- @Author: anchen
-- @Date:   2015-10-19 10:45:45
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-07 14:42:33
local blockMap = class("blockMap", function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

block_progress_id = nil --当前关卡进度
local type3_progress_id = nil --type3时的临时变量
isOpenElite = nil
-- local blockType = 1

local itemAplBoxFlag = false

blockMap_Instance = nil
function blockMap:getCur_AreaPath()
    local cur_AreaImgPath = "Block/area_"..self.toAreaId.."/"
    
    return cur_AreaImgPath
end


--=========================
--toAreaId 进入的大区
--toBlockId  指定的关卡，可以为空
--mType  当指定toBlockId时mType可以为nil, 1表示普通副本，2精英，3军团
--isSkip 是否通过任务，材料链接等跳转过来
function blockMap:ctor(toAreaId, toBlockId, mType, bSkip)
    if BlockUI and BlockUI.Instance then
        BlockUI.Instance=nil
    end
    blockMap_Instance = self
    -- print("=======")
    -- print(toAreaId)
    -- print(toBlockId)
    -- print("=======")
    self.toAreaId = toAreaId
    self.toBlockId =  toBlockId
    self.mType = mType or blockData[toBlockId].type
    self.bSkip = bSkip

    audio.playMusic("audio/blockBg.mp3", true)
    self.mainBg = getMainSceneBgImg()
    :addTo(self)

    --关卡地图
    self.blockBg = display.newSprite()
    :addTo(self,1)
    :pos(display.cx, display.cy)

    


    --金属边框
    self.blockBox = display.newScale9Sprite("Block/area_img8.png", display.cx, display.cy,
        cc.size(1141,660))
    :addTo(self,2)

    --支线按钮
    local branchBt = cc.ui.UIPushButton.new(
        {normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"})
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "支线", size = 27, color =cc.c3b(44, 210, 255)}))
    :addTo(self.blockBox)
    :pos(self.blockBox:getContentSize().width/2+380, self.blockBox:getContentSize().height)
    :scale(0.8)
    :onButtonClicked(function(event)
        g_branch.new()
        :addTo(self,50)
        end)
    local srvBranchTask = {}
    for i,value in pairs(TaskMgr.idKeyInfo) do
        -- print(value.tptId)
        if taskData[value.tptId].type==15 then
            srvBranchTask[#srvBranchTask+1] = value
        end
    end
    if #srvBranchTask<=0 and (srv_userInfo.subTaskGot==nil or srv_userInfo.subTaskGot=="") then
        branchBt:setVisible(false)
    end
    --支线红点
    local branchList,tasklistByTptId = initBranchData()
    local isOnGoing = false
    for i=1,#branchList do
        loc_zhixian = BranchTaskData[branchList[i]]
        local tasklist = string.split(loc_zhixian.taskId, "|")
        for i=1,#tasklist do
            if tasklistByTptId[tonumber(tasklist[i])] and tasklistByTptId[tonumber(tasklist[i])].sts==1 then
                isOnGoing = true
                break
            end
        end
    end
    --是否有红点
    if isOnGoing then
        local node = branchBt
        node:removeChildByTag(10)
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(70,20)
    end
    --支线对话
    if g_TriggerBranchId~=0 then
        local branchId = 1000 + tonumber(string.sub(tostring(g_TriggerBranchId),4, 6))
        local triggerId = BranchTaskData[branchId].talkId
        self.dialog = UIDialog.new()
        :addTo(self,150)
        self.dialog:setVisible(true)
        self.dialog:TriggerDialog(tonumber(triggerId), DialogType.zhixianPlot)
        g_TriggerBranchId = 0
    end
    
    
    --返回主城
    self.backTown = cc.ui.UIPushButton.new("Block/area_img3.png")
    :addTo(self.blockBox,2)
    :pos(25, self.blockBox:getContentSize().height-15)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(evnet)
        if MainSceneEnterType == EnterTypeList.BOUNTY_ENTER and bounty.Instance==nil then
            self.bounty = g_bounty.new()
            :addTo(display.getRunningScene(),1)
        end

        setMainSceneBgImg(MainScene_Instance.mainBg)
        local townName = areaData[areaData[srv_userInfo.areaId].resId].name2
        MainScene_Instance.townName:setString(townName)
        -- local imgName = "Block/area_"..areaData[srv_userInfo.areaId].resId.."/city_bg.jpg"
        -- MainScene_Instance.mainBg:setTexture(imgName)
        audio.playMusic("audio/mainbg.mp3", true)
        setIgonreLayerShow(true)
        GuideManager:removeGuideLayer()
        --新手教程
        local _scene = cc.Director:getInstance():getRunningScene()
        _scene:addGuide_ani(11401)
        _scene:addGuide_ani(10601)
        _scene:addGuide_ani(10301)
        _scene:addGuide_ani(11201)
        
        GuideManager:_addGuide_2(10201, _scene,handler(_scene,_scene.caculateGuidePos))
        GuideManager:_addGuide_2(11301, _scene,handler(_scene,_scene.caculateGuidePos))
        GuideManager:_addGuide_2(20201, _scene,handler(_scene,_scene.caculateGuidePos))
        GuideManager:_addGuide_2(20401, _scene,handler(_scene,_scene.caculateGuidePos))
        

        setIgonreLayerShow(false)--新手引导触摸遮罩，完全回到主界面要关闭
        
        g_isFirstIntoMainFromFight = false
        self:removeSelf()
        if MainScene_Instance._mainLineGuide then
            MainScene_Instance._mainLineGuide:refreshGuide()
        end
        
        end)
    display.newSprite("Block/area_img4.png")
    :addTo(self.backTown)
    :pos(-18,0)

    local img = display.newSprite("Block/area_img7.png")
    :addTo(self.blockBox, -1)
    :pos(350, self.blockBox:getContentSize().height+7)

    local img = display.newSprite("Block/area_img7.png")
    :addTo(self.blockBox, -1)
    :pos(-7, self.blockBox:getContentSize().height-150)
    img:setRotation(90)
    img:setScaleY(-1)

    local img = display.newSprite("Block/area_img7.png")
    :addTo(self.blockBox, -1)
    :pos(self.blockBox:getContentSize().width+7, 160)
    img:setRotation(-90)
    img:setScaleY(-1)

    --大区名字
    local areaNameImg = display.newSprite("Block/area_img6.png",150, self.blockBox:getContentSize().height-5)
    :addTo(self.blockBox)
    self.areaName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(21, 24, 30)})
    :addTo(areaNameImg)
    :align(display.CENTER, areaNameImg:getContentSize().width/2-10, areaNameImg:getContentSize().height/2)

    --左滑动
    self.toLeft = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self)
    :pos(35,display.height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(evnet)
        self.toAreaId = self.toAreaId - 1
        sendAreaList = getSendAreaList(self.toAreaId)
        startLoading()
        local SelectAreaData={}
        SelectAreaData["characterId"]=srv_userInfo["characterId"]
        SelectAreaData["areaId"]=sendAreaList
        m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
        end)
    self.toLeft:setVisible(false)
    -- local sequence1 = transition.sequence({
    --  transition.moveBy(self.toLeft, {x = -20, y = 0, time = 1.0}),
    --  transition.moveBy(self.toLeft, {x = 20, y = 0, time = 1.0})
    --  })
    -- self.toLeft:runAction(cc.RepeatForever:create(sequence1))

    --右滑动
    self.toRight = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(self)
    :pos(display.width-35,display.height/2)
    :onButtonPressed(function(event)
        event.target:setScaleX(-0.95)
        event.target:setScaleY(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScaleX(-1.0)
        event.target:setScaleY(1.0)
        end)
    :onButtonClicked(function(evnet)
        if srv_userInfo.level < areaData[srv_userInfo["areaId"]+1].level then
            showTips(areaData[srv_userInfo["areaId"]+1].level.."级后才能进入")
            return
        end
        self.toAreaId = self.toAreaId + 1
        sendAreaList = getSendAreaList(self.toAreaId)
        startLoading()
        local SelectAreaData={}
        SelectAreaData["characterId"]=srv_userInfo["characterId"]
        SelectAreaData["areaId"]=sendAreaList
        m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
        end)
    self.toRight:setScaleX(-1)
    self.toRight:setVisible(false)
    -- local sequence2 = transition.sequence({
    --  transition.moveBy(self.toRight, {x = 20, y = 0, time = 1.0}),
    --  transition.moveBy(self.toRight, {x = -20, y = 0, time = 1.0})
    --  })
    -- self.toRight:runAction(cc.RepeatForever:create(sequence2))

    --普通按钮
    self.normalBt = cc.ui.UIPushButton.new({
        normal = "Block/area_img2.png",
        disabled = "Block/area_img1.png"
        })
    :addTo(self,3)
    :pos(display.cx + self.blockBox:getContentSize().width/2+8,display.cy + self.blockBox:getContentSize().height/2-80)
    :onButtonClicked(function(event)
        -- curBlockType = 1
        -- self:updateBlockMenu(1)
        self.mType = 1
        self:changeAreaRefreshUI(1)
     end)
    cc.ui.UILabel.new({UILabelType = 2, text = "普通", size = 27, color = cc.c3b(146, 46, 0)})
    :addTo(self.normalBt,0,10)
    :align(display.CENTER, 20,0)

    --精英按钮
    self.eliteBt = cc.ui.UIPushButton.new({
        normal = "Block/area_img2.png",
        disabled = "Block/area_img1.png"
        })
    :addTo(self)
    :pos(display.cx + self.blockBox:getContentSize().width/2+8,display.cy + self.blockBox:getContentSize().height/2-160)
    :onButtonClicked(function(event)
        DCEvent.onEvent("点击精英按钮")
        if srv_userInfo.level<14 then
            showTips("战队等级14级开放")
            return
        end
        GuideManager:forceSendFinishStep(125)
        GuideManager:removeGuideLayer()
        -- print((not isOpenElite))
        -- print((not canAreaEnter(srv_userInfo["areaId"], 2)))
        self.mType = 2
        if (not isOpenElite) or (not canAreaEnter(srv_userInfo["areaId"], 2)) then
            local tmpAreaId
            if srv_userInfo["maxEBlockId"]==0 then
                tmpAreaId = 10001
            else
                tmpAreaId = blockIdtoAreaId(srv_userInfo["maxEBlockId"])
            end
            -- print("tmpAreaId:"..tmpAreaId)
            if canAreaEnter(tmpAreaId, 2) and canAreaEnter(tmpAreaId, 1) then
                if canAreaEnter((tmpAreaId+1), 2) then
                    tmpAreaId = tmpAreaId + 1
                end
                -- curBlockType = 2 --直接进入精英关卡
                if tmpAreaId>=self.toAreaId then
                    self:changeAreaRefreshUI(2)
                else
                    self.toAreaId = tmpAreaId
                    sendAreaList = getSendAreaList(self.toAreaId)
                    startLoading()
                    local SelectAreaData={}
                    SelectAreaData["areaId"]=sendAreaList
                    m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
                end
                
            else
                -- print("dddddd")
                showMessageBox("拉多区普通关卡通关后，开启精英关卡。")
            end
        else
            -- print("fffffffffff")
            -- self.blocklayer:updateBlockMenu(2)
            self:changeAreaRefreshUI(2)
        end
            
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "精英", size = 27, color = cc.c3b(136, 238, 255)})
    :addTo(self.eliteBt,0,10)
    :align(display.CENTER, 20,0)

    
    --团队按钮
    self.teamBt = nil
    self.teamBt = cc.ui.UIPushButton.new({
        normal = "Block/area_img2.png",
        disabled = "Block/area_img1.png"
        })
    :addTo(self)
    :pos(display.cx + self.blockBox:getContentSize().width/2+8,display.cy + self.blockBox:getContentSize().height/2-240)
    :onButtonClicked(function(event)
        curBlockType = 3
        startLoading()
        local sendData={}
        sendData["areaId"]=srv_userInfo["areaId"]
        m_socket:SendRequest(json.encode(sendData), CMD_LEGION_BLOCK, self, self.onLegionBlockResult)
         end)
    cc.ui.UILabel.new({UILabelType = 2, text = "军团", size = 27, color = cc.c3b(136, 238, 255)})
    :addTo(self.teamBt,0,10)
    :align(display.CENTER, 20,0)
    self.teamBt:setVisible(false)

    GuideManager:removeGuideLayer()
    local _scene = cc.Director:getInstance():getRunningScene()
    GuideManager:_addGuide_2(11310, _scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10207, _scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10510, _scene,handler(self,self.caculateGuidePos))
    
    GuideManager:_addGuide_2(11510, _scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(20101, _scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(20301, _scene,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11110, _scene,handler(self,self.caculateGuidePos))

    GuideManager:_addGuide_2(12403, _scene,handler(self,self.caculateGuidePos))
end
function blockMap:setThreeMenu(mType)
    --是否显示军团按钮
    if areaData[srv_userInfo["areaId"]].hasArmy==1 then
        self.teamBt:setVisible(true)
    else
        self.teamBt:setVisible(false)
    end
    if mType==1 then
        curBlockType = 1
        self.normalBt:setButtonEnabled(false)
        self.normalBt:setLocalZOrder(3)
        self.normalBt:getChildByTag(10):setColor(cc.c3b(145, 46, 0))
        self.eliteBt:setButtonEnabled(true)
        self.eliteBt:setLocalZOrder(0)
        self.eliteBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        if areaData[srv_userInfo["areaId"]].hasArmy==1 then
            self.teamBt:setButtonEnabled(true)
            self.teamBt:setLocalZOrder(0)
            self.teamBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        end

    elseif mType==2 then
        curBlockType = 2

        self.normalBt:setButtonEnabled(true)
        self.normalBt:setLocalZOrder(0)
        self.normalBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        self.eliteBt:setButtonEnabled(false)
        self.eliteBt:setLocalZOrder(3)
        self.eliteBt:getChildByTag(10):setColor(cc.c3b(145, 46, 0))
        if areaData[srv_userInfo["areaId"]].hasArmy==1 then
            self.teamBt:setButtonEnabled(true)
            self.teamBt:setLocalZOrder(0)
            self.teamBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        end
    elseif mType==3 then
        curBlockType = 3

        self.normalBt:setButtonEnabled(true)
        self.normalBt:setLocalZOrder(0)
        self.normalBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        self.eliteBt:setButtonEnabled(true)
        self.eliteBt:setLocalZOrder(0)
        self.eliteBt:getChildByTag(10):setColor(cc.c3b(136, 238, 255))
        if areaData[srv_userInfo["areaId"]].hasArmy==1 then
            self.teamBt:setButtonEnabled(false)
            self.teamBt:setLocalZOrder(3)
            self.teamBt:getChildByTag(10):setColor(cc.c3b(145, 46, 0))
        end
        
    end
end
function blockMap:setTeamState()
    local tipBar
    local tipLabel
    -- print(lgionFBResult.."team result")
    if lgionFBResult~=1 then
        tipBar = cc.ui.UIImage.new("Block/tipBar.png")
        :addTo(self.blockBg, 10)
        :align(display.CENTER,self.blockBg:getContentSize().width/2, self.blockBg:getContentSize().height/2)
        tipLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 35})
        :addTo(tipBar)
        :align(display.CENTER, tipBar:getContentSize().width/2, tipBar:getContentSize().height/2)
        tipLabel:setColor(MYFONT_COLOR)
    end
    if lgionFBResult==-4 then
        tipLabel:setString("大区未开启！")
        return
    elseif lgionFBResult==2 then
        tipLabel:setString("已通关！")
    elseif lgionFBResult==3 then
        tipLabel:setString("军团成员正在挑战中！")
    elseif lgionFBResult==4 then
        tipLabel:setString("怪物休息中！")
    elseif lgionFBResult==5 then
        tipLabel:setString("达到每日通关最大次数！")
    elseif lgionFBResult==-5 then
        tipLabel:setString("普通大区未开启！")
        return
    -- elseif lgionFBResult==1 then
    end
        local teamBottomBar = cc.ui.UIImage.new("Block/team/teamBottomBar.png")
        :addTo(self.blockBg,2)
        :align(display.CENTER_LEFT, 7, 45)

        local mScale = 0.8
        local hurtRankBt = cc.ui.UIPushButton.new(
        {normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"})
        :addTo(teamBottomBar)
        :pos(teamBottomBar:getContentSize().width-240, teamBottomBar:getContentSize().height/2)
        :scale(mScale)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "伤害排名", size = 27, color =cc.c3b(44, 210, 255)}))
        :onButtonClicked(function(event)
            self:createDamageRankBox()
            end)

        local spoilsRankBt = cc.ui.UIPushButton.new(
        {normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"})
        :addTo(teamBottomBar)
        :pos(teamBottomBar:getContentSize().width-80, teamBottomBar:getContentSize().height/2)
        :scale(mScale)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "战利品", size = 27, color =cc.c3b(245, 255, 49)}))
        :onButtonClicked(function(event)
            self:createSpoilsBox()
            end)


        local restTimes = cc.ui.UILabel.new({UILabelType = 2, text = "今日剩余挑战次数：", size = 25})
        :addTo(teamBottomBar)
        :align(display.CENTER_LEFT, 30, teamBottomBar:getContentSize().height/2)
        restTimes:setColor(cc.c3b(166, 202, 202))
        tipLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
        :addTo(teamBottomBar)
        :align(display.CENTER_LEFT, restTimes:getPositionX()+restTimes:getContentSize().width, teamBottomBar:getContentSize().height/2)

        local leftTimes = 2 - srv_blockArmyData.dayCount
        if leftTimes<=0 then
            tipLabel:setColor(cc.c3b(255, 0, 0))
        else
            tipLabel:setColor(cc.c3b(250, 238, 0))
        end
        tipLabel:setString(leftTimes.."/2")
    -- end
end


function blockMap:onEnter()
    self:setVisible(false)
    if self.mType~=nil then
        if next(srv_blockData)~=nil and srv_userInfo["areaId"]==self.toAreaId then
            -- self:addBlockLayer(self.toAreaId, self.toBlockId, self.mType)
            self:changeAreaRefreshUI(self.mType)
            self:setVisible(true)
        else
            -- cur_areaId = self.toAreaId
            startLoading()
            sendAreaList = getSendAreaList(self.toAreaId)
            local SelectAreaData={}
            SelectAreaData["characterId"]=srv_userInfo["characterId"]
            SelectAreaData["areaId"]=sendAreaList
            m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
        end

        --进入世界地图
        self.backWorldMap = cc.ui.UIPushButton.new("Block/area_img3.png")
        :addTo(self.blockBox,2)
        :pos(self.blockBox:getContentSize().width - 30, 40)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            startLoading()
            self:addWorldMapImg()
            end)
        self.backWorldMap:setRotation(180)
        display.newSprite("Block/area_img5.png")
        :addTo(self.backWorldMap)
        :pos(-18,0)
        :setRotation(180)

    end
end
function blockMap:onExit()
    blockMap_Instance = nil
end

function blockMap:onEnterBlockResult(result)
    endLoading()
    if not isNodeValue(self) then
        return
    end
    self:setVisible(true)
    if result["result"]==1 then
        srv_userInfo["areaId"]=self.toAreaId
        -- local imgName = "Block/area_"..areaData[srv_userInfo.areaId].resId.."/city_bg.jpg"
        -- self.mainBg:setTexture(imgName)
        setMainSceneBgImg(self.mainBg)
        if self.mType==3 then
            curBlockType = 3
            startLoading()
            local sendData={}
            sendData["areaId"]=srv_userInfo["areaId"]
            m_socket:SendRequest(json.encode(sendData), CMD_LEGION_BLOCK, self, self.onLegionBlockResult)
            -- self:changeAreaRefreshUI(self.mType)
        else
            self:changeAreaRefreshUI(self.mType)
        end
    else
        -- cur_areaId = cur_areaId - 1
        showTips(result.msg)
    end
end

function blockMap:createBlocks()
end

--切换精英，军团，关卡背景和关卡图标不需要重置，只需要重置星级,进度等UI
-- function blockMap:reloadCurAreaUI(blockType)
--     --判断左右换区箭头是否出现
--     self.toLeft:setVisible(true)
--     self.toRight:setVisible(true)
--     if srv_userInfo["areaId"]==10001 or (blockType==3 and areaData[srv_userInfo["areaId"]-1].hasArmy==0) then
--         -- print("aaaaa")
--         self.toLeft:setVisible(false)
--     end
--     if areaData[srv_userInfo["areaId"]+1]~=nil and (not canAreaEnter(srv_userInfo["areaId"]+1)) 
--         or (blockType==3 and areaData[srv_userInfo["areaId"]+1].hasArmy==0) then
--         self.toRight:setVisible(false)
--     elseif areaData[srv_userInfo["areaId"]+1]==nil then
--         self.toRight:setVisible(false)
--     elseif blockType==3 then
        
--     end
--     self:setThreeMenu(blockType)

--     block_progress_id=nil
--     -- printTable(srv_blockData)
--     -- printTable(self.publicBlockData)
--     -- print("-------------")
--     local curBlockData = {}
--     curBlockData = getCurAreaBlocksData(self.toAreaId)
--     -- printTable(curBlockData)
--     for i,value in ipairs(curBlockData) do
--         -- print(value.id)

--         local srv_value = self.publicBlockData[value.id]
--         -- if srv_value==nil then
--         --  showTips("数据错误，请稍后再试")
--         -- end
--         if blockType==1 and value.type==1 and srv_value.star<=0 and block_progress_id==nil then
--             block_progress_id = value.id
--             break
--         elseif blockType==2 and value.type==2 and srv_value.star<=0 and block_progress_id==nil then
--             -- print("adc222")
--             block_progress_id = value.id
--         elseif blockType==3 and value.type==3 then
--             if lgionFBResult~=-4 and lgionFBResult~=-5 then
--                 local ArmyData=lua_string_split(srv_blockArmyData.tempo,"|")
--                 if (#ArmyData)==1 and value.id==ArmyData then
--                     block_progress_id = value.id
--                     break
--                 elseif value.id==(ArmyData[1]+0) then
--                     block_progress_id = ArmyData[1]+0
--                     break
--                 end
--             end
--         end
--     end

--     if self.toBlockId~=nil and 
--         MainSceneEnterType ~= EnterTypeList.FIGHT_ENTER and MainSceneEnterType~=EnterTypeList.FIGHT_ENTER then
--         type3_progress_id = block_progress_id --type3时的最新关卡
--         if blockType~=3 then
--             block_progress_id = self.toBlockId --箭头指向的关卡
--         end
--     else
--     end
--     -- print("block_progress_id:"..block_progress_id)

--     --创建每个大区的关卡按钮
--     for key,value in pairs(self.publicBlockData) do
--         -- print(key)
--         local localItem = blockData[key]
--         if localItem.type==1 then
--             if value.star<=0 then
--                 isOpenElite = false
--             end
--             local sendBlockId
--             if blockType==1 then
--                 sendBlockId=key
--             elseif blockType==2 then

--                 local eliteid
--                 for Ekey,Evalue in pairs(self.publicBlockData) do
--                     -- print(Ekey)
--                     local ElocalItem = blockData[Ekey]
--                     if ElocalItem["type"]==2 and ElocalItem.id%1000000==localItem.id%1000000 then
--                         eliteid=Ekey
--                         break
--                     end
--                 end
--                 -- print("sendBlockId=eliteid")
--                 sendBlockId=eliteid
--                 -- print("sendId1:"..sendBlockId)
--             elseif blockType==3 then
--                 local teamid
--                 for Tkey,TlocalItem in pairs(curBlockData) do
--                     if TlocalItem["type"]==3 and TlocalItem.id%1000000==localItem.id%1000000 then
--                         teamid=TlocalItem.id
--                         -- print("teamId;"..TlocalItem.id)
--                         break
--                     end
--                 end
--                 sendBlockId=teamid
--             end
--             if sendBlockId==nil then
--                 sendBlockId = key
--             end
--             -- print("sendId:"..sendBlockId)
--             self:performWithDelay(function ()
--             if localItem.ctype==2 then --小关卡
--                 self:setSmallBlockImg(value.star, key)
--                 local smallBlockBt = self.blockBg:getChildByTag(key)

--                 if blockType==2 or blockType==3 then
--                     -- smallBlockBt:getChildByTag(10):setButtonImage("disabled", "Block/smallBlockDisable.png")
--                     smallBlockBt:setButtonEnabled(false)
--                 end

--             else  --大关卡
--                 local blockImg = cc.ui.UIImage.new(self:getCur_AreaPath().."block_"..key..".png") --只用于获取它的大小
--                 local star
--                 if blockType==3 then
--                     star = -1
--                 else
--                     -- print(sendBlockId)
--                     star = self.publicBlockData[sendBlockId].star
--                 end
--                 self:setBigBlockImg(star,key,sendBlockId)
--                 local BigBlockBt = self.blockBg:getChildByTag(key)
                
--             end
--             setIgonreLayerShow(false)
--             end,0.01)
--         end
--     end
-- end
--切换大区，更新UI,需要重置整个关卡界面的UI
function blockMap:changeAreaRefreshUI(blockType)
    --更新背景图
    local bgPath = self:getCur_AreaPath().."block_bg.jpg"
    self.blockBg:setTexture(bgPath)
    --更新大区名字
    self.areaName:setString(areaData[srv_userInfo["areaId"]].name)
    --判断左右换区箭头是否出现
    self.toLeft:setVisible(true)
    self.toRight:setVisible(true)
    if srv_userInfo["areaId"]==10001 or (blockType==3 and areaData[srv_userInfo["areaId"]-1].hasArmy==0) then
        -- print("aaaaa")
        self.toLeft:setVisible(false)
    end
    -- print(canAreaEnter(srv_userInfo["areaId"]+1, blockType))
    if areaData[srv_userInfo["areaId"]+1]~=nil and (not canAreaEnter(srv_userInfo["areaId"]+1, blockType)) 
        or (blockType==3 and areaData[srv_userInfo["areaId"]+1].hasArmy==0) then
        self.toRight:setVisible(false)
    elseif areaData[srv_userInfo["areaId"]+1]==nil then
        self.toRight:setVisible(false)
    elseif blockType==3 then
        
    end

    self:setThreeMenu(blockType)
    self:updateBlockMenu(blockType)
end
function blockMap:updateBlockMenu(blockType)
    self.blockBg:removeAllChildren()
    if blockType==3 then
        self:setTeamState()
    end

    self.publicBlockData = srv_blockData
    --获取当前大区进度
    block_progress_id=nil
    -- printTable(srv_blockData)
    -- printTable(self.publicBlockData)
    -- print("-------------")
    local curBlockData = {}
    curBlockData = getCurAreaBlocksData(self.toAreaId)
    -- printTable(curBlockData)
    writeTabToLog(srv_blockData,"srv_blockData","nnn.log")

    for i,value in ipairs(curBlockData) do
        -- print(value.id)
        writeTabToLog({value_id = value.id},"value_id","nnn.log")
        local srv_value = self.publicBlockData[value.id]
        -- if srv_value==nil then
        --  showTips("数据错误！")
        -- end
        if blockType==1 and value.type==1 and srv_value.star<=0 and block_progress_id==nil then
            block_progress_id = value.id
            break
        elseif blockType==2 and value.type==2 and srv_value.star<=0 and block_progress_id==nil then
            -- print("adc222")
            block_progress_id = value.id
        elseif blockType==3 and value.type==3 then
            -- if lgionFBResult~=-4 and lgionFBResult~=-5 then
                local ArmyData=lua_string_split(srv_blockArmyData.tempo,"|")
                if (#ArmyData)==1 and value.id==ArmyData then
                    block_progress_id = value.id
                    break
                elseif value.id==(ArmyData[1]+0) then
                    block_progress_id = ArmyData[1]+0
                    break
                end
            -- end
        end
    end

    if self.toBlockId~=nil and MainSceneEnterType ~= EnterTypeList.FIGHT_ENTER then
        type3_progress_id = block_progress_id --type3时的最新关卡
        if blockType~=3  then 
            -- block_progress_id = self.toBlockId --箭头指向的关卡
            self.Arrow_blockId = self.toBlockId
        else
            self.Arrow_blockId = block_progress_id
        end
    else
        self.Arrow_blockId = block_progress_id
    end
    if self.bSkip then
        self.curBlockId = block_progress_id
    end

    --创建每个大区的关卡按钮
    self.blockBtns = {}
    for key,value in pairs(self.publicBlockData) do
        -- print(key,value)
        local localItem = blockData[key]
        if localItem.type==1 then
            if value.star<=0 then
                isOpenElite = false
            end
            local sendBlockId
            if blockType==1 then
                sendBlockId=key
            elseif blockType==2 then

                local eliteid
                for Ekey,Evalue in pairs(self.publicBlockData) do
                    -- print(Ekey)
                    local ElocalItem = blockData[Ekey]
                    if ElocalItem["type"]==2 and ElocalItem.id%1000000==localItem.id%1000000 then
                        eliteid=Ekey
                        break
                    end
                end
                -- print("sendBlockId=eliteid")
                sendBlockId=eliteid
                -- print("sendId1:"..sendBlockId)
            elseif blockType==3 then
                local teamid
                for Tkey,TlocalItem in pairs(curBlockData) do
                    if TlocalItem["type"]==3 and TlocalItem.id%1000000==localItem.id%1000000 then
                        teamid=TlocalItem.id
                        -- print("teamId;"..TlocalItem.id)
                        break
                    end
                end
                sendBlockId=teamid
            end
            if sendBlockId==nil then
                sendBlockId = key
            end
            -- print("sendId:"..sendBlockId)
            self:performWithDelay(function ()
            if localItem.ctype==2 then --小关卡
                local smallBlockBt = self:getSmallBlockImg(value.star,key)
                :addTo(self.blockBg,0,key)
                :pos((localItem.posX)*display.width/1920-8,self.blockBg:getContentSize().height-(localItem.posY)*display.width/1920-10)
                smallBlockBt:setAnchorPoint(0,0)
                smallBlockBt:onButtonClicked(function(event)
                    -- print(srv_userInfo.level)
                    -- if blockData[key].mainLine==0 then
                    --     showTips("该关卡暂未开放")
                    if blockData[key].mainLine==0 and srv_userInfo.level<50 then
                        showTips("50级开启支线关卡")
                    elseif key~=block_progress_id and value.star<=0 then
                        -- showMessageBox("未开启")
                        showTips("未开启")
                    else
                        --导弹效果
                        if self.Missile and self.MissileId == sendBlockId then
                            self:MissileAction(self.Missile, function()
                                BlockUI.new(sendBlockId,self.publicBlockData)
                                :addTo(display.getRunningScene(),51)
                                end,true)
                        else
                            BlockUI.new(sendBlockId,self.publicBlockData)
                            :addTo(display.getRunningScene(),51)
                        end
                    end
                    
                end)
                if blockType==2 or blockType==3 then
                    -- smallBlockBt:getChildByTag(10):setButtonImage("disabled", "Block/smallBlockDisable.png")
                    smallBlockBt:setButtonEnabled(false)
                end
                if key==self.Arrow_blockId then
                    if self.bSkip then
                        getArrow("Block/targetBlock.png", self.blockBg,smallBlockBt:getPositionX()+5, smallBlockBt:getPositionY()+63)
                        --瞄准镜
                        self.Missile = BlockAimEff(self.blockBg,
                                                smallBlockBt:getPositionX()+33, smallBlockBt:getPositionY()+30, 0.6)
                        self.MissileId = sendBlockId
                    else
                        getArrow("Block/curBlock.png", self.blockBg,smallBlockBt:getPositionX()+5, smallBlockBt:getPositionY()+63)
                        --瞄准镜
                        self.Missile = BlockAimEff(self.blockBg,
                                                smallBlockBt:getPositionX()+33, smallBlockBt:getPositionY()+30,0.6)
                        self.MissileId = sendBlockId
                    end
                    
                elseif self.bSkip and sendBlockId==self.curBlockId then --当前箭头
                    getArrow("Block/curBlock.png", self.blockBg,
                        smallBlockBt:getPositionX()+5, smallBlockBt:getPositionY()+63)
                end
                self.blockBtns[key] = smallBlockBt
            else  --大关卡
                local blockImg = cc.ui.UIImage.new(self:getCur_AreaPath().."block_"..key..".png") --只用于获取它的大小
                local star
                if blockType==3 then
                    star = -1
                else
                    -- print(sendBlockId)
                    star = self.publicBlockData[sendBlockId].star
                end
                local BigBlockBt = self:getBigBlockImg(star,key,sendBlockId)
                :addTo(self.blockBg,0,key)
                :pos(localItem.posX*display.width/1920+blockImg:getContentSize().width/2,
                    self.blockBg:getContentSize().height-localItem.posY*display.width/1920+blockImg:getContentSize().height/2)
                BigBlockBt:onButtonClicked(function(event)
                    -- if blockData[key].mainLine==0 then
                    --     showTips("该关卡暂未开放")
                    if blockData[key].mainLine==0 and srv_userInfo.level<50 then
                        showTips("50级开启支线关卡")
                    else
                        -- BlockUI:updateMsgLayer(sendBlockId,self.publicBlockData)
                        --导弹效果
                        if self.Missile and self.MissileId == sendBlockId then
                            self:MissileAction(self.Missile, function()
                                BlockUI.new(sendBlockId,self.publicBlockData)
                                :addTo(display.getRunningScene(),51)
                                end)
                        else
                            BlockUI.new(sendBlockId,self.publicBlockData)
                            :addTo(display.getRunningScene(),51)
                        end
                    end
                    end)
                if sendBlockId==self.Arrow_blockId then --目标箭头
                    if self.bSkip then
                        getArrow("Block/targetBlock.png", self.blockBg,BigBlockBt:getPositionX()-25,BigBlockBt:getPositionY()+70)
                        --瞄准镜
                        self.Missile = BlockAimEff(self.blockBg,BigBlockBt:getPositionX(), BigBlockBt:getPositionY())
                        self.MissileId = sendBlockId
                    else
                        getArrow("Block/curBlock.png", self.blockBg,BigBlockBt:getPositionX()-25,BigBlockBt:getPositionY()+70)
                        --瞄准镜
                        self.Missile = BlockAimEff(self.blockBg,BigBlockBt:getPositionX(), BigBlockBt:getPositionY())
                        self.MissileId = sendBlockId
                    end
                elseif self.bSkip and sendBlockId==self.curBlockId then --当前箭头
                    getArrow("Block/curBlock.png", self.blockBg,BigBlockBt:getPositionX()-25, BigBlockBt:getPositionY()+70)
                end
                self.blockBtns[key] = BigBlockBt

                if blockType~=3 then
                    local star = self:createBlockStar(self.publicBlockData[sendBlockId].star,sendBlockId)
                    :addTo(BigBlockBt)
                    :pos(0+11, -blockImg:getContentSize().height/2)
                elseif blockType==3 and sendBlockId==block_progress_id then --军团关卡进度条
                    self:LegionFBProgress(BigBlockBt,sendBlockId)
                end

                local bossTmpId = blockData[sendBlockId].type2
                if bossTmpId~=0 and type(bossTmpId)=="number" then --boss怪物
                    local resId = monsterData[bossTmpId].resId
                    local newRole
                    if monsterData[bossTmpId].actType==1 then --cocos动画
                        local manager = ccs.ArmatureDataManager:getInstance()
                        manager:removeArmatureFileInfo("Battle/Monster/Monster_"..resId.."_.ExportJson")
                        manager:addArmatureFileInfo("Battle/Monster/Monster_"..resId.."_.ExportJson")
                        newRole = ccs.Armature:create("Monster_"..resId.."_")
                        :addTo(BigBlockBt)
                        :pos(0,30)
                        newRole:getAnimation():play("Standby")
                        newRole:getAnimation():gotoAndPlay(0)
                        newRole:setScale(0.35*monsterData[bossTmpId].scale2)
                        newRole:setContentSize(cc.size(0, 0))
                    else --spine动画
                        newRole = sp.SkeletonAnimation:create("Battle/Monster/Monster_"..resId.."_.json","Battle/Monster/Monster_"..resId.."_.atlas",1)
                        :addTo(BigBlockBt)
                        :pos(0,0)
                        newRole:setAnimation(0, "Standby", true)
                    end
                    newRole:setScale(0.35*monsterData[bossTmpId].scale2)
                end
                
            end

            
            GuideManager:_addGuide_2(10503, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(10103, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(10203, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(11103, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(11204, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(11303, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(11603, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            GuideManager:_addGuide_2(11703, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
            setIgonreLayerShow(false)
            end,0.01)
        end
    end
end
--关卡选择导弹动作
function blockMap:MissileAction(parentNode, callback, bSmall)
    local parentWorldPos = parentNode:convertToWorldSpace(cc.p(0,0))
    local nodesize = parentNode:getContentSize()

    local dx = nodesize.width/2
    local dy = 30
    local scale = 2.0
    if bSmall then
        dx = 45
        dy = 0
        scale = 1
    end
    local Missile = display.newSprite("Block/Missile.png")
    :addTo(self, 10)
    :pos(parentWorldPos.x+dx, display.height+100)

    local moveAct = cc.MoveTo:create(0.3, cc.p(parentWorldPos.x+dx, parentWorldPos.y+nodesize.height/2+dy))
    local callFunc = cc.CallFunc:create(function()
        parentNode:setVisible(false)
        Missile:removeSelf()
        BlockBoomEff(self,parentWorldPos.x+dx,parentWorldPos.y+nodesize.height/2+dy, scale, 
            function()
                parentNode:setVisible(true)
                if BlockUI.Instance==nil then
                    callback()
                end
            end)
        end)
    local seqAct = cc.Sequence:create(moveAct,callFunc)
    Missile:runAction(seqAct)
end
function blockMap:LegionFBProgress(parentNode,sendBlockId)
    local proNum
    if (#srv_blockArmyData.tempo==8) then
        proNum = 0
    else
        local restBlood=0 --剩余怪物血量
        local allBlood=0  --怪物总血量
        local sectionBlood1 = 0 --第一节怪物血量
        local sectionBlood2 = 0 --第二节怪物血量
        local sectionBlood3 = 0 --第三节怪物血量
        
        local monstersArr = lua_string_split(blockData[sendBlockId].monsters, "|")
        for i,value in ipairs(monstersArr) do
            monsterTmpIdArr = lua_string_split(value, ":")
            local tmpBlood = getMonsterBlood(tonumber(monsterTmpIdArr[1]),tonumber(monsterTmpIdArr[3]))
            if (monsterTmpIdArr[2]+0)==1 then
                sectionBlood1 = sectionBlood1 + tmpBlood
            elseif (monsterTmpIdArr[2]+0)==2 then
                sectionBlood2 = sectionBlood2 + tmpBlood
            elseif (monsterTmpIdArr[2]+0)==3 then
                sectionBlood3 = sectionBlood3 + tmpBlood
            end
        end
        allBlood = sectionBlood1 + sectionBlood2 + sectionBlood3
        
        local ArmyData=lua_string_split(srv_blockArmyData.tempo,"|")
        local monsters = lua_string_split(ArmyData[3],";")
        for i=1,#monsters do --当前小节怪物剩余血量，之前的都死了不用算，之后的需要累加
            mont = lua_string_split(monsters[i],":")
            restBlood = restBlood + mont[2]
        end
        if (ArmyData[2]+0)==1 then
            restBlood = restBlood + sectionBlood2 + sectionBlood3
        elseif (ArmyData[2]+0)==2 then
            restBlood = restBlood + sectionBlood3
        end
        -- print(allBlood)
        -- print(restBlood)
        proNum = (allBlood-restBlood)/allBlood
        print("proNum:"..proNum)
    end

    local mScale = 0.5
    local progress1 = display.newSprite("Block/blockProgress1.png")
    :addTo(parentNode)
    -- :scale(mScale)
    :pos(0, -50)
    progress1:setScaleX(mScale)
    local progress2 = cc.Sprite:create("Block/blockProgress2.png",cc.rect(0,0,300*proNum,13))
    :addTo(progress1)
    :pos(0,2)
    progress2:setAnchorPoint(0,0)
    -- progress2:setPercent(proNum*100)
    local proNumLab = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text =math.floor(proNum*100).."%" , size = 24,
        color = cc.c3b(255, 255, 0)})
    :addTo(progress1)
    :pos(progress1:getContentSize().width + 17, 5)
end

function blockMap:getSmallBlockImg(flag,blockId) -- -1:未通过，1：当前可战斗，>=0：已通过
    -- local smallBlockBottom = cc.ui.UIImage.new("Block/smallBlockBottom.png")
    local second = math.modf(blockId/1000000)%10
    local smallBlock
    if second==1 then
        smallBlock = cc.ui.UIPushButton.new(
        {normal = "Block/man.png",
        pressed = "Block/man.png"},
        {grayState=true})
    else
        smallBlock = cc.ui.UIPushButton.new(
        {normal = "Block/tank.png",
        pressed = "Block/tank.png"},
        {grayState=true})
    end
    smallBlock:setAnchorPoint(0,0)

    if self.mType==3 then --type为3时
        if blockId==type3_progress_id  then 
        elseif flag>0 then
            smallBlock:setButtonEnabled(false)
        elseif flag==-1 then
        end
    else
        if blockId==block_progress_id  then
        elseif flag>0 then
            smallBlock:setButtonEnabled(false)
        elseif flag==-1 then
        end
    end
    -- smallBlock:setTag(10)
    return smallBlock
end
function blockMap:setSmallBlockImg(flag,blockId) -- -1:未通过，1：当前可战斗，>=0：已通过
    local smallBlock = self.blockBg:getChildByTag(blockId)
    if self.mType==3 then --type为3时
        if blockId==type3_progress_id  then 
            smallBlock:setButtonEnabled(true)
        elseif flag>0 then
            smallBlock:setButtonEnabled(false)
        elseif flag==-1 then
            smallBlock:setButtonEnabled(true)
        else
            smallBlock:setButtonEnabled(true)
        end
    else
        if blockId==block_progress_id  then
            smallBlock:setButtonEnabled(true)
        elseif flag>0 then
            smallBlock:setButtonEnabled(false)
        elseif flag==-1 then
            smallBlock:setButtonEnabled(true)
        else
            smallBlock:setButtonEnabled(true)
        end
    end

end
function blockMap:getBigBlockImg(flag,blockId,sendId)
    local blockImg = cc.ui.UIImage.new(self:getCur_AreaPath().."block_"..blockId..".png") --取大小
    local blockBt = cc.ui.UIPushButton.new(
                {normal = self:getCur_AreaPath().."block_"..blockId..".png",
                pressed = self:getCur_AreaPath().."block_"..blockId..".png"},
                {grayState=true})

    if self.mType==3 then
        if flag<=0 and sendId~=type3_progress_id and sendId~=block_progress_id then
            blockBt:setButtonEnabled(false)
        end
    else
        if flag<=0 and sendId~=block_progress_id then
            blockBt:setButtonEnabled(false)
        end
    end

    if block_progress_id and blockData[sendId].type==3 and sendId%1000<block_progress_id%1000 then
        blockBt:setButtonEnabled(true)
    end


    blockBt:setAnchorPoint(0.5,0.5)
    blockBt:onButtonPressed(function(event)
        blockBt:setScale(0.95)
        end)
    blockBt:onButtonRelease(function(event)
        blockBt:setScale(1.0)
        end)
    blockBt:setScale(blockData[sendId].scale)

    --通关的冒烟效果
    -- if flag>0 then
    --     BlockSmokeEff(blockBt,0,100)
    -- end
    
    return blockBt
end
function blockMap:setBigBlockImg(flag,blockId,sendId)
    local blockBt = self.blockBg:getChildByTag(blockId)

    if self.mType==3 then
        if flag<=0 and sendId~=type3_progress_id and sendId~=block_progress_id then
            blockBt:setButtonEnabled(false)
        else
            blockBt:setButtonEnabled(true)
        end
    else
        if flag<=0 and sendId~=block_progress_id then
            blockBt:setButtonEnabled(false)
        else
            blockBt:setButtonEnabled(true)
        end
    end

    if lgionFBResult==2 or (lgionFBResult==1 and blockData[sendId].type==3 and sendId%1000<block_progress_id%1000) then
        blockBt:setButtonEnabled(true)
    else
        blockBt:setButtonEnabled(true)
    end

    
    return blockBt
end

function getArrow(imgPath, parentNode, x, y)
    x = x or 0
    y = y or 0
    local arrow = cc.ui.UIImage.new(imgPath)
    :addTo(parentNode,10)
    :pos(x,y)
    local sequence = transition.sequence({
        transition.moveBy(arrow, {x = 0, y = 10, time = 0.5}),
        transition.moveBy(arrow, {x = 0, y = -10, time = 0.5})
        })
    arrow:runAction(cc.RepeatForever:create(sequence))
    return arrow
end
function blockMap:createBlockStar(starNum,sendBlockId)
    local starBar = display.newSprite("Block/starBar.png") 
    starBar:setScaleX(1.2)
    local scale = 0.83
    local dx = 5

    local second = math.modf(sendBlockId/1000000)%10
    local man_tank
    if second==1 then
        if starNum<=0 then
            man_tank = display.newGraySprite("Block/man.png")
        else
            man_tank = display.newSprite("Block/man.png")
        end
    else
        if starNum<=0 then
            man_tank = display.newGraySprite("Block/tank.png")
        else
            man_tank = display.newSprite("Block/tank.png")
        end
    end
    man_tank:addTo(starBar)
    man_tank:pos(0, starBar:getContentSize().height/2)
    man_tank:setScaleX(scale)

    for i=1,3 do
        local star = cc.ui.UIImage.new("common/common_Star.png")
        :addTo(starBar)
        :align(display.CENTER, starBar:getContentSize().width/4*i+dx, starBar:getContentSize().height/2)
        star:setScaleX(scale)
        if i>starNum then
            star:setTexture("common/common_nullStar.png")
        end
    end

    return starBar
end

function blockMap:onLegionBlockResult(result)
    endLoading()
    lgionFBResult = result.result
    if lgionFBResult==-2 then
        showTips("加入军团，才可挑战军团副本")
        return
    end
    srv_blockArmyData = result.data
    self.mType = 3
    self:changeAreaRefreshUI(self.mType)
end

function blockMap:GetResNum()
    return 6
end

function blockMap:LoadResAsync()
    if nil==g_LoadingScene or nil==g_LoadingScene.Instance then
        return
    end

    local instance = g_LoadingScene.Instance
    

    --关卡小图加载
    display.addImageAsync("Block/man.png", handler(instance, instance.ImgDataLoaded))
    display.addImageAsync("Block/man_disable.png", handler(instance, instance.ImgDataLoaded))

    display.addImageAsync("Block/selectBt.png", handler(instance, instance.ImgDataLoaded))
    display.addImageAsync("Block/starBar.png", handler(instance, instance.ImgDataLoaded))
    display.addImageAsync("Block/tank.png", handler(instance, instance.ImgDataLoaded))
    display.addImageAsync("Block/tank_disable.png", handler(instance, instance.ImgDataLoaded))

end

function blockMap:addWorldMapImg()
    self.imgCnt = 0
    local function addLoadCnt()
        self.imgCnt = self.imgCnt + 1
        -- print(self.imgCnt)
        if self.imgCnt>=36 then
            print("世界地图资源加载完毕")
            endLoading()
            g_worldMap.new()
            :addTo(MainScene_Instance)
            self:removeSelf()
        end
    end

    display.addSpriteFrames("area/areaEffects/areaGasImg.plist", "area/areaEffects/areaGasImg.png")
    display.addSpriteFrames("area/areaEffects/areaFireImg.plist", "area/areaEffects/areaFireImg.png")
    display.addSpriteFrames("area/areaEffects/areaSmokeImg.plist", "area/areaEffects/areaSmokeImg.png")
    display.addSpriteFrames("area/areaEffects/waterfallImg.plist", "area/areaEffects/waterfallImg.png")
    display.addSpriteFrames("area/areaEffects/fallSmokeImg.plist", "area/areaEffects/fallSmokeImg.png")
    display.addSpriteFrames("area/areaEffects/areaTornadoImg.plist", "area/areaEffects/areaTornadoImg.png")
    --地图
    for i=10001,10018 do
        display.addImageAsync("area/map/down/"..i..".png",addLoadCnt)
        display.addImageAsync("area/map/normal/"..i..".png",addLoadCnt)
    end
end

function blockMap:createSpoilsBox()
    local spoils_masklayer =  UIMasklayer.new()
    :addTo(cc.Director:getInstance():getRunningScene(),52)
    local function  func()
        spoils_masklayer:removeFromParent()
    end
    spoils_masklayer:setOnTouchEndedEvent(func)
    local spoilsBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, display.cy-30,
        cc.size(1000, 603),cc.rect(119, 127, 1, 1))
    :addTo(spoils_masklayer)
    spoils_masklayer:addHinder(spoilsBox)
    self.spoilsBox = spoilsBox
    local closeBt = cc.ui.UIPushButton.new("common2/com2_Btn_2_up.png")
    :addTo(spoilsBox)
    :pos(spoilsBox:getContentSize().width +20, spoilsBox:getContentSize().height -40)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        spoils_masklayer:removeFromParent()
        end)
    local titleBar = display.newSprite("common2/com2_img_31.png")
    :addTo(spoilsBox)
    :pos(spoilsBox:getContentSize().width/2, spoilsBox:getContentSize().height+10)
    cc.ui.UILabel.new({UILabelType = 2, text = "战利品申请", size = 30, color = cc.c3b(255, 240, 0)})
    :addTo(titleBar)
    :align(display.CENTER, titleBar:getContentSize().width/2, titleBar:getContentSize().height/2-5)

    self.spoilsListview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 20, 960, 550),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
    :addTo(spoilsBox)
    startLoading()
    local sendData={}
    sendData["areaId"]=srv_userInfo.areaId
    m_socket:SendRequest(json.encode(sendData), MMD_SPOILS_QUEUE, self, self.onLegionSpoilsRank)
end
function blockMap:createDamageRankBox()
    local damage_masklayer =  UIMasklayer.new()
    :addTo(cc.Director:getInstance():getRunningScene(),52)
    local function  func()
        damage_masklayer:removeFromParent()
    end
    damage_masklayer:setOnTouchEndedEvent(func)
    local DamageRankBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, display.cy-30,
        cc.size(1020, 591),cc.rect(119, 127, 1, 1))
    :addTo(damage_masklayer)
    damage_masklayer:addHinder(DamageRankBox)
    local closeBt = cc.ui.UIPushButton.new("common2/com2_Btn_2_up.png")
    :addTo(DamageRankBox)
    :pos(DamageRankBox:getContentSize().width +20, DamageRankBox:getContentSize().height -40)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        damage_masklayer:removeFromParent()
        end)
    local titleBar = display.newSprite("common2/com2_img_31.png")
    :addTo(DamageRankBox)
    :pos(DamageRankBox:getContentSize().width/2, DamageRankBox:getContentSize().height+10)
    cc.ui.UILabel.new({UILabelType = 2, text = "伤害排名", size = 30, color = cc.c3b(255, 240, 0)})
    :addTo(titleBar)
    :align(display.CENTER, titleBar:getContentSize().width/2, titleBar:getContentSize().height/2-5)

    self.DamageListview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(18, 20, 990, 550),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
    :addTo(DamageRankBox)

    startLoading()
    local sendData={}
    sendData["areaId"]=srv_userInfo.areaId
    m_socket:SendRequest(json.encode(sendData), CMD_LEGION_DAMAGE_RANK, self, self.onLegionDamageRank)
end
--战利品申请列表
function blockMap:createItemApplyList(value)
    self.aplList_masklayer =  UIMasklayer.new()
    :addTo(cc.Director:getInstance():getRunningScene(),52)
    local function  func()
        itemAplBoxFlag = false
        self.aplList_masklayer:removeFromParent()
    end
    self.aplList_masklayer:setOnTouchEndedEvent(func)
    local aplListBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, display.cy-30,
        cc.size(860, 570),cc.rect(119, 127, 1, 1))
    :addTo(self.aplList_masklayer,2)
    self.aplList_masklayer:addHinder(aplListBox)
    --关闭
    local closeBt = cc.ui.UIPushButton.new("common2/com2_Btn_2_up.png")
    :addTo(aplListBox)
    :pos(aplListBox:getContentSize().width +20, aplListBox:getContentSize().height -40)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        itemAplBoxFlag = false
        self.aplList_masklayer:removeFromParent()
        end)
    --title
    local titleBar = display.newSprite("common2/com2_img_32.png")
    :addTo(self.aplList_masklayer)
    :pos(display.cx, display.cy+aplListBox:getContentSize().height/2)
    cc.ui.UILabel.new({UILabelType = 2, text = "申请队列", size = 30, color = cc.c3b(255, 240, 0)})
    :addTo(titleBar)
    :align(display.CENTER, titleBar:getContentSize().width/2, titleBar:getContentSize().height/2-10)

    --物品信息
    local bottombar = display.newSprite("Block/team/teamApl.png")
    :addTo(aplListBox)
    :pos(aplListBox:getContentSize().width/2, 80)
    local icon = createItemIcon(value.tmpId)
    :addTo(bottombar)
    :pos(70, bottombar:getContentSize().height/2)
    --待分配
    local itemNum = cc.ui.UILabel.new({UILabelType = 2, text = "待分配：", size = 22})
    :addTo(bottombar)
    :pos(150, 100)
    local label = cc.ui.UILabel.new({UILabelType = 2, text = value.num.."个", size = 22, color = cc.c3b(243, 152, 0)})
    :addTo(bottombar)
    :pos(itemNum:getPositionX()+itemNum:getContentSize().width, itemNum:getPositionY())
    --分配时间
    local leftTime = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    :addTo(bottombar)
    :pos(150, 60)
    local srv_ts = os.time()*1000 - srv_local_dts
    local inPoint
    for i=10,23 do
        if srv_ts>getSrvPointTimeTs(i) then
            inPoint = i+1
        end
    end
    -- print(inPoint)
    local timeStr = GetTimeStr(getSrvPointTimeTs(inPoint) - srv_ts)
    timeStr = string.sub(timeStr, 4, 5)
    leftTime:setString(timeStr)
    leftTime:setColor(cc.c3b(243, 152, 0))
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "分钟后自动分配", size = 22})
    :addTo(bottombar)
    :pos(leftTime:getPositionX()+leftTime:getContentSize().width, leftTime:getPositionY())

    if LegionSpoilsData.mine.armyItId==value.armyItId then
        --当前排名
        local itemNum = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
        :addTo(bottombar)
        :pos(150, 20)
        itemNum:setString("当前排在第"..LegionSpoilsData.mine.No.."位")

        local applyedBt = cc.ui.UIPushButton.new({
            normal = "common2/com2_Btn_6_up.png",
            pressed = "common2/com2_Btn_6_down.png"
            })
        :addTo(bottombar)
        :pos(bottombar:getContentSize().width-100, bottombar:getContentSize().height/2)
        :onButtonClicked(function(event)
            print("itemAplBoxFlag = true")
            itemAplBoxFlag = true
            local msg = "您目前在"..itemData[LegionSpoilsData.mine.tmpId].name.."的队列中排名第"..LegionSpoilsData.mine.No
            ..",\n是否要放弃对"..itemData[LegionSpoilsData.mine.tmpId].name.."的申请？"
            showMessageBox(msg,function()
                startLoading()
                local sendData={}
                sendData["areaId"]=srv_userInfo.areaId
                sendData["armyItemId"] = value.armyItId
                m_socket:SendRequest(json.encode(sendData), CMD_SPOILS_CANCEL, self, self.onLegionSpoilsCancel)
                end)
            end)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "已申请", size = 27, color =cc.c3b(94, 229, 101)}))
            
    else
        local unApplyBt = cc.ui.UIPushButton.new({
            normal = "common2/com2_Btn_7_up.png",
            pressed = "common2/com2_Btn_7_down.png"
            })
        :addTo(bottombar)
        :pos(bottombar:getContentSize().width-100, bottombar:getContentSize().height/2)
        :onButtonClicked(function(event)
            itemAplBoxFlag = true
            if LegionSpoilsData.mine.No==0 then
                aplValue = value
                startLoading()
                local sendData={}
                sendData["areaId"]=srv_userInfo.areaId
                sendData["armyItemId"] = value.armyItId
                m_socket:SendRequest(json.encode(sendData), MMD_SPOILS_LIST, self, self.onLegionApply)
                return
            end
            local msg = "您目前在"..itemData[LegionSpoilsData.mine.tmpId].name.."的队列中排名第"..LegionSpoilsData.mine.No
            ..",\n是否要放弃对"..itemData[LegionSpoilsData.mine.tmpId].name.."的申请？\n"..
            "加入到"..itemData[value.tmpId].name.."的申请队列"
            showMessageBox(msg,function()
                aplValue = value
                startLoading()
                local sendData={}
                sendData["areaId"]=srv_userInfo.areaId
                sendData["armyItemId"] = value.armyItId
                m_socket:SendRequest(json.encode(sendData), MMD_SPOILS_LIST, self, self.onLegionApply)
                end)
            end)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "未申请", size = 27, color =cc.c3b(245, 255, 49)}))
    end
    
    self.aplListview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 150, 820, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
    :addTo(aplListBox)

    for i,value2 in ipairs(value.aplInfo) do
        local item = self.aplListview:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(660,120)
        self.aplListview:addItem(item)

        local itemW,itemH = item:getItemSize()
        local bottomLine = display.newSprite("Block/sweep/sweep_img8.png")
            :addTo(content)
            :pos(0, -(itemH/2-7))
        --条
        -- local itemBar = display.newScale9Sprite("common/common_Frame9.png",0, 
        -- 0,
        -- cc.size(660, 120),cc.rect(20,20,70,64))
        -- :addTo(content)

        local rankNum = cc.LabelAtlas:_create()
                        :align(display.CENTER, 300, 10)
                        :addTo(content)
        rankNum:initWithString("",
            "common/common_Num1.png",
            42,
            51,
            string.byte(0))
        if 1==i then
            rankNum:setString(":")
        elseif 2==i then
            rankNum:setString(";")
        elseif 3==i then
            rankNum:setString("<")
        else
            rankNum:setString(i)
        end

        --成员头像
        local head = getCHeadBox(value2.icon) 
        :addTo(content)
        :pos(90-itemW/2,10)
        -- head:setScale(0.9)
        --成员名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(content)
        :pos(150-itemW/2, 30)
        name:setString(value2.name)
        name:setColor(cc.c3b(255, 241, 0))
        --等级
        local level = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(content)
        :pos(150-itemW/2, -10)
        level:setString("等级："..value2.level)
        level:setColor(cc.c3b(175, 206, 226))

        --24小时内不能领取
        if value2.name==srv_userInfo.name then
            local joints = LegionSpoilsData.mine.joinTS
            local curts = os.time()
            local dHour = (curts - joints/1000)/(60*60)
            print(dHour)
            if dHour<24 then
                local tips = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                :addTo(content)
                :align(display.CENTER, 50, 10)
                tips:setString("（加入军团不足24小时不会分配）")
                tips:setColor(cc.c3b(255, 0, 0))
            end
        end
        
    end
    self.aplListview:reload()
end
function blockMap:updateDamageListview()
    self.DamageListview:removeAllItems()

    for i,value in ipairs(LegionDamageRankData) do
        local item = self.DamageListview:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(990,150)
        self.DamageListview:addItem(item)
        --条
        local itemBar = display.newSprite("rankLayer/rank2_img2.png")
        :addTo(content)
        local tmpsize = itemBar:getContentSize()

        if i<=3 then
            display.newSprite("rankLayer/rank2_img"..(i+3)..".png")
            :addTo(itemBar)
            :pos(100, tmpsize.height/2)
        else
            local img = display.newSprite("rankLayer/rank2_img7.png")
            :addTo(itemBar)
            :pos(100, tmpsize.height/2)
            local rankNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = i, size = 45, color = cc.c3b(0, 0, 0)})
            :addTo(img,2)
            :align(display.CENTER, 80,img:getContentSize().height/2)
        end

        --名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = value.name, size = 25})
        :addTo(itemBar,2)
        :pos(320, tmpsize.height/2+25)
        -- setLabelStroke(name,25,nil,1,nil,nil,nil,nil, true)

        --等级
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 25, color = cc.c3b(175, 206, 226)})
        :addTo(itemBar,2)
        :pos(320, tmpsize.height/2-25)
        -- setLabelStroke(label,25,nil,1,nil,nil,nil,nil, true)
        local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = value.level, size = 25, color = cc.c3b(175, 206, 226)})
        :addTo(itemBar,2)
        :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
        -- setLabelStroke(level,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)

        --头像
        local head = getCHeadBox(value.icon) 
        :addTo(itemBar)
        head:pos(260,tmpsize.height/2)
        head:setScale(1.2)
        head:setButtonEnabled(false)

        --成员总伤害
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "总伤害", size = 28, color = cc.c3b(255, 241, 0)})
        :addTo(itemBar,2)
        :align(display.CENTER, tmpsize.width-165, tmpsize.height/2+13)
        local strengthNum = cc.LabelAtlas:_create()
            :addTo(itemBar)
            :align(display.CENTER, label:getPositionX(),tmpsize.height/2-30)
            strengthNum:initWithString("","common/common_Num2.png",27.3,39,string.byte(0))
            strengthNum:setString(value.hurt)
        -- strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "总伤害：", size = 22})
        -- :addTo(itemBar)
        -- :pos(itemBar:getContentSize().width-220, itemBar:getContentSize().height/2)
        -- strengthLabel:setColor(MYFONT_COLOR)
        -- local strength = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
        -- :addTo(itemBar)
        -- :pos(itemBar:getContentSize().width - 130, itemBar:getContentSize().height/2)
        -- strength:setString(value.hurt)
        -- strength:setColor(cc.c3b(255, 255, 0))

    end
    self.DamageListview:reload()
end
local aplValue = {}
function blockMap:updateSpoilsListview()
    self.spoilsListview:removeAllItems()

    if #LegionSpoilsData.army==0 then
        display.newSprite("common2/com2_Img_24.png")
        :addTo(self.spoilsBox)
        :pos(self.spoilsBox:getContentSize().width/2, self.spoilsBox:getContentSize().height/2)
        cc.ui.UILabel.new({UILabelType = 2, text = "目前没有可申请的物品", size = 25, color = cc.c3b(128, 136, 150)})
        :addTo(self.spoilsBox)
        :align(display.CENTER, self.spoilsBox:getContentSize().width/2, self.spoilsBox:getContentSize().height/2-100)
        return
    end

    for i,value in ipairs(LegionSpoilsData.army) do
        local item = self.spoilsListview:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(960,140)
        self.spoilsListview:addItem(item)

        local itemW,itemH = item:getItemSize()
        local bottomLine = display.newSprite("Block/sweep/sweep_img8.png")
            :addTo(content)
            :pos(0, -(itemH/2-7))

        --条
        -- local itemBar = display.newScale9Sprite("common/common_Frame9.png",0, 
        -- 0,
        -- cc.size(800, 120),cc.rect(20,20,70,64))
        -- :addTo(content)

        --物品图标
        local itemIcon = createItemIcon(value.tmpId)
        :addTo(content)
        :pos(120-itemW/2, 0)
        :scale(0.8)
        --物品名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(content)
        :pos(200-itemW/2, 20)
        name:setString(itemData[value.tmpId].name)
        name:setColor(cc.c3b(255, 238, 31))
        --剩余件数、申请人数
        local numlabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(content)
        :pos(200-itemW/2, -20)
        numlabel:setColor(cc.c3b(151, 190, 204))
        local detailFlag = false
        local numStr = ""
        if value.num>0 then
            numStr = "剩余"..value.num.."件"
        end
        if #value.aplInfo>0 then
            if numStr~="" then
                numStr = numStr.."，"
            end
            numStr = numStr.."已有"..#value.aplInfo.."人申请"
            detailFlag = true
        end
        numlabel:setString(numStr)
        --详情按钮
        if detailFlag then
            local detailBt = cc.ui.UIPushButton.new({
                normal = "common2/com2_Btn_8_up.png",
                pressed = "common2/com2_Btn_8_down.png"
                })
            :addTo(content)
            :pos(160, 0)
            :onButtonClicked(function(event)
                aplValue = value
                self:createItemApplyList(value)
                end)
            :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "详 情", size = 27, color =cc.c3b(44, 210, 255)}))
        end
        if value.armyItId==LegionSpoilsData.mine.armyItId then
            local applyedBt = cc.ui.UIPushButton.new({
                normal = "common2/com2_Btn_6_up.png",
                pressed = "common2/com2_Btn_6_down.png"
                })
            :addTo(content)
            :pos(350, 0)
            :onButtonClicked(function(event)
                local msg = "您目前在"..itemData[LegionSpoilsData.mine.tmpId].name.."的队列中排名第"..LegionSpoilsData.mine.No
                ..",是否要放弃对"..itemData[LegionSpoilsData.mine.tmpId].name.."的申请？"
                showMessageBox(msg,function()
                    startLoading()
                    local sendData={}
                    sendData["areaId"]=srv_userInfo.areaId
                    sendData["armyItemId"] = value.armyItId
                    m_socket:SendRequest(json.encode(sendData), CMD_SPOILS_CANCEL, self, self.onLegionSpoilsCancel)
                    end)
                end)
            :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "已申请", size = 27, color =cc.c3b(94, 229, 101)}))
        else
            local unapplyBt = cc.ui.UIPushButton.new({
                normal = "common2/com2_Btn_7_up.png",
                pressed = "common2/com2_Btn_7_down.png"
                })
            :addTo(content)
            :pos(350,0)
            :onButtonClicked(function(event)
                if LegionSpoilsData.mine.No==0 then
                    aplValue = value
                    startLoading()
                    local sendData={}
                    sendData["areaId"]=srv_userInfo.areaId
                    sendData["armyItemId"] = value.armyItId
                    m_socket:SendRequest(json.encode(sendData), MMD_SPOILS_LIST, self, self.onLegionApply)
                    return
                end
                local msg = "您目前在"..itemData[LegionSpoilsData.mine.tmpId].name.."的队列中排名第"..LegionSpoilsData.mine.No
                ..",是否要放弃对"..itemData[LegionSpoilsData.mine.tmpId].name.."的申请？"..
                "加入到"..itemData[value.tmpId].name.."的申请队列"
                showMessageBox(msg,function()
                    aplValue = value
                    startLoading()
                    local sendData={}
                    sendData["areaId"]=srv_userInfo.areaId
                    sendData["armyItemId"] = value.armyItId
                    m_socket:SendRequest(json.encode(sendData), MMD_SPOILS_LIST, self, self.onLegionApply)
                    end)
                
                end)
            :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "未申请", size = 27, color =cc.c3b(245, 255, 49)}))

        end

    end
    self.spoilsListview:reload()
end


--伤害排名列表
function blockMap:onLegionDamageRank(result)
    endLoading()
    if result.result==1 then
        self:updateDamageListview()
    else
        showTips(result.msg)
    end
end
--战利品
function blockMap:onLegionSpoilsRank(result)
    endLoading()
    if result.result==1 then
        self:updateSpoilsListview()
    else
        showTips(result.msg)
    end
end
--战利品申请
function blockMap:onLegionApply(result)
    endLoading()
    if result.result==1 then
        showTips("申请成功")
        --修改自己申请物品的数据
        LegionSpoilsData.mine["tmpId"] = aplValue.tmpId
        LegionSpoilsData.mine["armyItId"] = aplValue.armyItId
        LegionSpoilsData.mine["No"] = #aplValue.aplInfo+1
        local myAplInfo = {}
        myAplInfo.level = srv_userInfo.level
        myAplInfo.name = srv_userInfo.name
        myAplInfo.icon = srv_userInfo.templateId
        for i,value in ipairs(LegionSpoilsData.army) do
            if value.armyItId==aplValue.armyItId then --在物品的申请队列中增加自己
                LegionSpoilsData.army[i].aplInfo[#LegionSpoilsData.army[i].aplInfo+1] = myAplInfo
            else                                      --在原来的队列中删除自己（如果已申请其他的物品）
                for j,value2 in ipairs(value.aplInfo) do
                    if value2.icon==srv_userInfo.templateId then
                        table.remove(LegionSpoilsData.army[i].aplInfo, j)
                        break
                    end
                end
            end
        end
        self:updateSpoilsListview()


        if itemAplBoxFlag then
            itemAplBoxFlag = false
            self.aplList_masklayer:removeFromParent()
            self:createItemApplyList(aplValue)
        end
    else
        showTips(result.msg)
    end
end
--取消战利品申请
function blockMap:onLegionSpoilsCancel(result)
    endLoading()
    if result.result==1 then
        showTips("取消申请")
        --修改自己申请物品的数据
        LegionSpoilsData.mine["tmpId"] = 0
        LegionSpoilsData.mine["armyItId"] = 0
        LegionSpoilsData.mine["No"] = 0
        for i,value in ipairs(LegionSpoilsData.army) do
            for j,value2 in ipairs(value.aplInfo) do
                if value2.icon==srv_userInfo.templateId then
                    table.remove(LegionSpoilsData.army[i].aplInfo, j)
                    break
                end
            end
        end
        self:updateSpoilsListview()

        if itemAplBoxFlag then
            itemAplBoxFlag = false
            self.aplList_masklayer:removeFromParent()
            
            -- self:createItemApplyList(aplValue)
        end
    else
        showTips(result.msg)
    end
end

function blockMap:caculateGuidePos(_guideId)
    print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11303==_guideId or 10103==_guideId or 10503==_guideId or 10203==_guideId or 11204==_guideId 
    or 11203==_guideId or 20404==_guideId or 11310==_guideId or 11103==_guideId or 11603==_guideId 
    or 10207==_guideId or 11510==_guideId or 20101==_guideId or 11110==_guideId or 11703==_guideId 
    or 20301==_guideId or 20406==_guideId or 12403==_guideId or 10510==_guideId then

        if 11310==_guideId or 10207==_guideId or 10510==_guideId or 11110==_guideId
        or 11510==_guideId or 20101==_guideId or 20301==_guideId or 20406==_guideId then
            g_node = self.backTown
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        elseif 11303==_guideId or 10503==_guideId or 11103==_guideId or 10103==_guideId then
            if 10503==_guideId then
                g_node = self.blockBtns[12001003]
            elseif 11303==_guideId then
                g_node = self.blockBtns[11001006]
            elseif 11103==_guideId then
                g_node = self.blockBtns[12001004]
            elseif 10103==_guideId then
                g_node = self.blockBtns[11001001]
            end
            print("指引小关卡---------------")
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        elseif 10203==_guideId or 11204==_guideId or 11603==_guideId or 11703==_guideId then
            if 10203==_guideId then
                g_node = self.blockBtns[11001002]
            elseif 11204==_guideId then
                g_node = self.blockBtns[12001005]
            elseif 11603==_guideId then
                g_node = self.blockBtns[11001007]
            elseif 11703==_guideId then
                g_node = self.blockBtns[12002001]
            end
            print("指引大关卡---------------")
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        elseif 12403==_guideId then
            g_node = self.eliteBt
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        end
        if g_node==nil then
            print("g_node==nil,  return")
            return nil
        end
        
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end


return blockMap