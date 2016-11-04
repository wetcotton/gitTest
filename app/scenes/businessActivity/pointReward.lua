-- @Author: anchen
-- @Date:   2016-04-08 11:00:20
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-04-20 10:52:02
pointReward = class("pointReward",function()
    -- local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

pointReward.Instance = nil
function pointReward:ctor()
    pointReward.Instance = self
    display.addSpriteFrames("Image/UITask.plist", "Image/UITask.png")

    local colorBg = display.newSprite("common/colorbg.png")
    :addTo(self,-1)
    colorBg:setAnchorPoint(0,0)
    colorBg:setScaleX(display.width/colorBg:getContentSize().width)
    colorBg:setScaleY(display.height/colorBg:getContentSize().height)  

    self.closeBtn = cc.ui.UIPushButton.new({
        normal="common/common_BackBtn_1.png",
        pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height )
        :addTo(self)
        :onButtonClicked(function(event)
            self:removeSelf()
        end)

    self.storyView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 200),
        viewRect = cc.rect(display.cx-930/2-10, display.cy-540/2+110, 960, 460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        }
        :addTo(self)
    self:reloadListView()

    
end


--获取有积分的任务
function pointReward:getPointTaskTab()
    local loc_pointTask = {}
    for i,value in pairs(taskData) do
        if value.point>0 then
            table.insert(loc_pointTask,value)
        end
    end
    return loc_pointTask
end

function pointReward:reloadListView()
    local loc_pointTask = self:getPointTaskTab()

    self.idList = TaskMgr.sortList[TaskTag.Daily]
        local listView = self.storyView
        listView:removeAllItems()   --清空
        self.selectedBtn = nil

        local xxTab = {}
        for i=1, #self.idList do
            local xx = TaskMgr.idKeyInfo[self.idList[i]]               
            if xx.tptId==102370001 then 
                xxTab[102370001] = xx
            elseif xx.tptId==101030001 then
                xxTab[101030001] = xx
            end
        end
        local boolTab = {}

        if xxTab[102370001] and xxTab[102370001].status==0 then --任务未达成时不显示
            boolTab[102370001]=true
        end
        if xxTab[101030001] and xxTab[101030001].status==0 then --任务未达成时不显示
            boolTab[101030001]=true
        end

        if srv_userInfo.isPass==1 then
            boolTab[101480001]=true
        end

        local function BtnOnClick(event)
            local nTag = event.target:getTag()
            local srv_TaskData = TaskMgr.idKeyInfo[nTag]
            local loc_TaskData = taskData[srv_TaskData.tptId]

            local function goBlock(nBlockID)
                local areamap = g_blockMap.new(nBlockID)
                    cc.Director:getInstance():getRunningScene():addChild(areamap,50)
                -- if next(srv_blockData)==nil then
          --           local fightSelectAreaData = {}
          --           fightSelectAreaData["characterId"]=srv_userInfo["characterId"]
          --           fightSelectAreaData["areaId"]=srv_userInfo["areaId"]
          --           m_socket:SendRequest(json.encode(fightSelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
          --       else
          --           local areamap = g_blockMap.new(nBlockID)
          --           cc.Director:getInstance():getRunningScene():addChild(areamap,50)
          --           -- cc.Director:getInstance():getRunningScene():setMainMenuVisible(false)
          --       end
            end

            if srv_TaskData.curcnt<loc_TaskData.cnt then
                if loc_TaskData.tgtType==TASKGOLE_ARMY or loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE
                        or loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then --挑战关卡
                    local toBlockId
                    if loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE then --终结者
                        if srv_userInfo.maxBlockId==0 then
                            toBlockId = 11001001
                        else
                            toBlockId = srv_userInfo.maxBlockId
                        end
                    elseif loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then
                        if srv_userInfo.maxEBlockId==0 then
                            toBlockId = 21001002
                        else
                            toBlockId = srv_userInfo.maxEBlockId
                        end
                    else     
                        toBlockId = loc_TaskData.params
                    end
                    print(toBlockId)
                    local toAreaId = blockIdtoAreaId(toBlockId)
                    if srv_userInfo.level<areaData[toAreaId].level then
                        showTips(areaData[toAreaId].level.."级开启该大区")
                    elseif canAreaEnter(toAreaId, blockData[toBlockId].type) then
                        if blockData[toBlockId].type==2 and srv_userInfo.level<14 then
                            showTips("14级开启精英关卡")
                            return
                        end
                        MainSceneEnterType = EnterTypeList.TASK_ENTER
                        -- local areamap
                        -- if loc_TaskData.tgtType~=TASKGOLE_ARMY and 
                        --  canAreaEnter(toAreaId+1, blockData[toBlockId].type) then
                        --  toAreaId = toAreaId + 1
                        --  areamap = g_blockMap.new(toAreaId, nil, 1, true)
                        -- end

                        local areamap
                        if loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE then --终结者
                            areamap = g_blockMap.new(toAreaId, nil, 1)
                        elseif loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then --精英终结者
                            areamap = g_blockMap.new(toAreaId,  nil, 2)
                        else
                            areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
                        end
                        areamap:addTo(MainScene_Instance, 10 , TAG_AREA_LAYER)
                    else
                        showTips("未通过至此大区")
                    end
                elseif loc_TaskData.tgtType==TASKGOLE_GUIDE_GIFT then
                    local toBlockId = loc_TaskData.params
                    local toAreaId = blockIdtoAreaId(toBlockId)
                    print("toAreaId:",toAreaId,"toBlockId:",toBlockId)
                    local areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
                            :addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
                elseif loc_TaskData.tgtType==TASKGOLE_CAREQUIPMENTSTRENGTHEN then
                    if 0==srv_userInfo.hasCar then
                        showMessageBox("当前战车数量为0")
                    else
                        g_ImproveLayer.new()
                            :addTo(self,10)
                    end

                elseif loc_TaskData.tgtType==TASKGOLE_ROLEEQUIPMENTADVANCE then
                    local scene = display.getRunningScene()
                    g_RolePropertyLayer.new()
                        :addTo(scene, 10)

                elseif loc_TaskData.tgtType==TASKGOLE_RECHARGE or loc_TaskData.tgtType==TASKGOLE_TOTALRECHARGE then
                    local layer = StoreLayer.new()
                    layer:addTo(self)

                elseif loc_TaskData.tgtType==TASKGOLE_SHOPTOBUY then
                    local layer = shopLayer.new(1)
                    layer:addTo(self)

                elseif loc_TaskData.tgtType==TASKGOLE_CARTRANSFORM then
                    if 0==srv_userInfo.hasCar then
                        showMessageBox("当前战车数量为0")
                    else
                        g_ImproveLayer.new()
                            :addTo(self)
                    end

                elseif loc_TaskData.tgtType==TASKGOLE_THREESTARCHAPTER then
                    showTips("暂未开放")

                elseif loc_TaskData.tgtType==TASKGOLE_LEGION
                        or loc_TaskData.tgtType==TASKGOLE_LEGION_CTRI then --军团
                    if srv_userInfo.level<28 then
                        showTips("28级后开启军团功能")
                        return
                    end
                    startLoading()
                    local sendData = {}
                    if srv_userInfo.armyName=="" then
                        sendData["characterId"] = srv_userInfo["characterId"]
                        sendData["No"] =  0
                        m_socket:SendRequest(json.encode(sendData), CMD_LEGION_ENTER, MainScene_Instance, MainScene_Instance.onEnterLegionResult)
                    else
                        sendData["characterId"] = srv_userInfo["characterId"]
                        m_socket:SendRequest(json.encode(sendData), CMD_MYLEGION_INFO, MainScene_Instance, MainScene_Instance.onMyLegionInfo)
                    end
                elseif loc_TaskData.tgtType==TASKGOLE_RELICS then --遗迹探测
                    display.addSpriteFrames("Image/UIWarriorsCenter.plist", "Image/UIWarriorsCenter.png")
                    g_RelicsLayer.new()
                        :addTo(self, 10)
                elseif loc_TaskData.tgtType==TASKGOLE_WORLDBOSS then --世界boss
                    g_WarriorsCenterLayer.new()
                    :addTo(self, 1)
                elseif loc_TaskData.tgtType==TASKGOLE_EQUIPLEVELUP then
                    g_RolePropertyLayer.new({seltag = 2})
                         :addTo(display.getRunningScene(),10)
                elseif loc_TaskData.tgtType==TASKGOLE_RENTCAR then  
                    RentMgr:ReqRentCarList(function ( ... )
                        rentCarListLayer.new()
                            :addTo(display.getRunningScene(),10)
                    end)
                    
                elseif loc_TaskData.tgtType==TASKGOLE_PVP then --PVP
                    -- showTips("暂未开放")
                    if srv_userInfo.level < 16 then
                       showTips("等级达到16级解锁竞技场")
                       return
                    end
                    startLoading()
                    comData={}
                    comData["characterId"] = srv_userInfo.characterId
                    m_socket:SendRequest(json.encode(comData), CMD_GETPVPINFO, MainScene_Instance, MainScene_Instance.OnGetPVPInfoRet)
                elseif loc_TaskData.tgtType==TASKGOLE_SKILLUP then --技能提升
                    g_RolePropertyLayer.new({seltag = 3})
                         :addTo(display.getRunningScene(),10)
                elseif loc_TaskData.tgtType==TASKGOLE_GOLDHAND then --点金手
                    addGold()
                elseif loc_TaskData.tgtType==TASKGOLE_LOTTERY then --抽卡
                    g_lotteryCardLayer.new()
                         :addTo(display.getRunningScene(),10)
                elseif loc_TaskData.tgtType==TASKGOLE_YUANZHENG then --远征
                    expeditionLayer.new()
                    :addTo(self, 1)
                
                else
                    -- print(loc_TaskData.tgtType)
                    --do nothing
                end
            else
                self:GenerateRewardsTab(srv_TaskData.tptId)
                TaskMgr:ReqSubmit(nTag)
                startLoading()
            end
        end
        self.Btns = {}
        local srv_TaskData, loc_TaskData
        for i=1, #loc_pointTask do
        -- for i=1, #self.idList do
            local srvIdIsExist = false
            for j=1, #self.idList do
                if TaskMgr.idKeyInfo[self.idList[j]].tptId==loc_pointTask[i].id then
                    --存在
                    srvIdIsExist = self.idList[j]
                    break
                end
            end
            srv_TaskData = TaskMgr.idKeyInfo[srvIdIsExist]
            if not srvIdIsExist then
                srv_TaskData = {}
                srv_TaskData.tptId = loc_pointTask[i].id
                srv_TaskData.curcnt = loc_pointTask[i].cnt
                srv_TaskData.id = 0
                srv_TaskData.status = 1
            end
            printTable(srv_TaskData)
            if boolTab[srv_TaskData.tptId]~=true then
                loc_TaskData = taskData[srv_TaskData.tptId]

                
                local item = listView:newItem()
                local bIsTimeLimit = false
                
                local content = cc.ui.UIPushButton.new("#task_03.png")
                                    :onButtonClicked(function (event)
                                        for i = 1,#self.Btns do
                                            self.Btns[i]:setButtonEnabled(true)
                                        end
                                        local btn = event.target
                                        btn:setButtonEnabled(false)
                                    end)
                table.insert(self.Btns,content)
                content:setTouchSwallowEnabled(false)
                local tmpSize = content.sprite_[1]:getContentSize()

                -- display.newSprite("#task_img11.png")
                --         :addTo(content)
                --         :align(display.CENTER,-tmpSize.width/2+80,0)
                local box = display.newSprite("#task_08.png")
                        :addTo(content)
                        :align(display.CENTER,-tmpSize.width/2+80,0)

                local taskIcon = display.newSprite("achIcon/task_"..loc_TaskData.resId..".png")
                        :addTo(box)
                        :align(display.CENTER,box:getContentSize().width/2,box:getContentSize().height/2)
                        :scale(1.36)
                taskIcon:setTag(14)

                if bIsTimeLimit then
                    display.newSprite("#task_05.png")
                        :addTo(box)
                        :align(display.CENTER,20,box:getContentSize().height-20)
                end

                display.newTTFLabel({
                            text = loc_TaskData.name,
                            size = 30,
                            color = cc.c3b(23,86,84),
                            align = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                            })
                            :addTo(content)
                            :align(display.LEFT_CENTER, -tmpSize.width/2+167, 40)

       --          --已经完成次数
                -- display.newTTFLabel({
                --              font = "fonts/slicker.ttf", 
                --              text = srv_TaskData.curcnt,
                --              size = 26,
                --              color = cc.c3b(35, 24, 21),
                --              })
                --              :align(display.RIGHT_CENTER,tmpSize.width/2-100, 40)
                --              :addTo(content,1)
                --完成进度
                display.newTTFLabel({
                                font = "fonts/slicker.ttf", 
                                text = srv_TaskData.curcnt.."/"..loc_TaskData.cnt,
                                size = 30,
                                color = cc.c3b(35, 24, 21),
                                })
                                :align(display.RIGHT_CENTER,tmpSize.width/2-70,40)
                                :addTo(content,1)
                --描述
                display.newTTFLabel({
                    text = loc_TaskData.tgtDes,
                    size = 20,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    -- valign= cc.ui.TEXT_VALIGN_CENTER,
                    color = cc.c3b(35, 24, 21)
                    })
                    :align(display.LEFT_CENTER, -tmpSize.width/2+165, 5)
                    :addTo(content,1)
                --奖励
                local label = cc.ui.UILabel.new({UILabelType = 2, text = "奖励：", size = 30, color = cc.c3b(252, 215, 62)})
                :addTo(content, 1)
                :pos(-tmpSize.width/2+165, -40)
                setLabelStroke(label,30,nil,1,nil,nil,nil,nil,true)

                --奖励积分
                cc.ui.UILabel.new({UILabelType = 2, text = loc_pointTask[i].point.."积分", size = 25, color = cc.c3b(252, 215, 62)})
                :addTo(content, 1)
                :pos(-tmpSize.width/2+250, -40)
                

                local btnLabStr,btnImg, bEnable = "",{}, true
                local xx_scale = 1
                if srv_TaskData.curcnt<loc_TaskData.cnt then

                    btnImg = {normal = "#task_07.png",pressed = "#task_07.png"}
                else
                    -- btnLabStr = "task_tag1.png"
                    btnImg = {normal = "pointReward/taskFinish.png",pressed = "pointReward/taskFinish.png"}
                end

                local btnGet = cc.ui.UIPushButton.new({normal=btnImg.normal,pressed=btnImg.pressed})
                    :align(display.CENTER,tmpSize.width/2-120, -20)
                    :addTo(content,0,srv_TaskData.id)
                    :onButtonPressed(function(event) event.target:setScale(0.95) end)
                    :onButtonRelease(function(event) event.target:setScale(1.0) end)
                    :onButtonClicked(BtnOnClick)
                    :scale(xx_scale)
                -- self.btnTag = display.newSprite("#"..btnLabStr)
                --  :addTo(content)
                --  :align(display.CENTER, tmpSize.width/2-120, -30)
                btnGet:setButtonEnabled(bEnable)
                btnGet:setName("btnGet")
                item:addContent(content)
                item:setItemSize(940, 155)
                listView:addItem(item)

                if srv_TaskData.curcnt<loc_TaskData.cnt then
                    btnGet:setButtonEnabled(true)
                else
                    btnGet:setButtonEnabled(false)
                end
            else
                print(srv_TaskData.tptId)
            end
        end
        listView:reload()
end

function pointReward:onEnter()
    startLoading()
    self.cansum = 0 --可领取个数
    local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_POINTREWARD, self, self.onPointReward)
end
function pointReward:onExit()
    pointReward.Instance = nil
end
--积分奖励接口返回
function pointReward:onPointReward(result)
    if result.result==1 then
        pointReward.Instance.srvPointRewardInfo = result.data
        self:initRewardsList()
    else
        showTips(result.msg)
    end
end

function pointReward:initRewardsList()
    self:removeChildByTag(100)

    local imgBG = display.newSprite("pointReward/point_img1.png")
            :align(display.CENTER, display.cx, 95)
            :addTo(self,0,100)

    local pointRewardByIdx = {}
    for i,value in pairs(pointRewardData) do
        table.insert(pointRewardByIdx, value)
    end 
    --排序
    function sortfunc(a,b)
        return a.id<b.id
    end
    table.sort(pointRewardByIdx, sortfunc)
    for i,value in ipairs(pointRewardByIdx) do
        
        --连接线
        if i~=#pointRewardByIdx then
            local bar = display.newSprite("pointReward/point_img3.png")
            :addTo(imgBG)
            :pos(235+(i-1)*170, imgBG:getContentSize().height/2-10)

            local per = (pointReward.Instance.srvPointRewardInfo.point - value.point)/(pointRewardByIdx[i+1].point - value.point)

            if per>0 then
                local progress = cc.ui.UILoadingBar.new({image = "pointReward/point_img4.png", viewRect = cc.rect(0,0,110,19)})
                :addTo(bar)
                :align(display.LEFT_BOTTOM,0, 0)
                per = math.min(per,1)
                print(per)
                progress:setPercent(per*100)
            end
            
        end

        local rewards = string.split(value.rewards, "#")
        local item = createItemIcon(rewards[1],rewards[2], true, true)
        :addTo(imgBG,2)
        :pos(150+(i-1)*170, imgBG:getContentSize().height/2-10)
        :scale(0.7)
        :onButtonClicked(function(event)
            startLoading()
            self.curItem = event.target
            self.curValue = value
            local tabMsg = {gId=value.id}
            m_socket:SendRequest(json.encode(tabMsg), CMD_POINTREWARDGET, self, self.OnSubmitRet)
            end)
            
        --积分图标
        display.newSprite("pointReward/point_"..value.point..".png")
        :addTo(item)
        :pos(0, 35)

        
        for j=1,#pointReward.Instance.srvPointRewardInfo.idList do
            if pointReward.Instance.srvPointRewardInfo.idList[j]==value.id and 
                pointReward.Instance.srvPointRewardInfo.point>=value.point then --在未领取列表中，切积分足够
                --可领取特效
                signCircleAnimation(item,0,0,2.5)
                self.cansum = self.cansum + 1
                break
            end
        end
        

        local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, align = cc.ui.TEXT_ALIGN_CENTER,color = cc.c3b(174, 211, 209)})
        :addTo(imgBG)
        :align(display.CENTER_TOP, 150+(i-1)*170, imgBG:getContentSize().height/2-60)
        :scale(0.8)
        des:setWidth(130)
        if value.des~="" and value.des~="null" then
            des:setString(value.des)
        end
    end

    display.newSprite("pointReward/point_img2.png")
    :addTo(imgBG)
    :pos(imgBG:getContentSize().width/2,155)

    --我的积分
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "我的积分：", size = 24,color = cc.c3b(174, 211, 209)})
    :addTo(imgBG)
    :pos(50,155)

    local points = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = pointReward.Instance.srvPointRewardInfo.point, size = 24, color = cc.c3b(255, 215, 61)})
    :addTo(imgBG,1)
    :pos(label:getPositionX()+label:getContentSize().width,155)
    setLabelStroke(points,24,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)

    --每日刷新时间
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "任务每日           刷新", size = 22,color = cc.c3b(174, 211, 209)})
    :addTo(imgBG)
    :pos(imgBG:getContentSize().width-300,155)
    local tmies = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "24:00", size = 22, color = cc.c3b(255, 215, 61)})
    :addTo(imgBG,1)
    :pos(label:getPositionX()+90,155)
    setLabelStroke(tmies,22,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
end

function pointReward:OnSubmitRet(cmd)
    if cmd.result==1 then
        srv_userInfo.diamond = cmd.data.diamond
        mainscenetopbar:setDiamond()
        srv_userInfo.vip = cmd.data.vip
        MainScene_Instance.vipNum:setString(srv_userInfo.vip)
        --如果最后一个领完了关闭该界面，主界面图标去除
        if cmd.data.point==-1 then
            self:removeSelf()
            local node = MainScene_Instance.activityMenuBar.sendVIPBt
            node:removeSelf()
            return
        end

        removeSignCircleAnimation(self.curItem)

        --奖励弹框
        local curRewards = {}
        local rewards = string.split(self.curValue.rewards, "#")
        table.insert(curRewards, {templateID=tonumber(rewards[1]), num=tonumber(rewards[2])})
        GlobalShowGainBox(nil, curRewards)

        self.cansum = self.cansum -1
        if self.cansum<=0 then
            local node = MainScene_Instance.activityMenuBar.sendVIPBt
            node:removeChildByTag(10)
        end
    else
        showTips(cmd.msg)
    end
end

return pointReward