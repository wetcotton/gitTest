-- @Author: anchen
-- @Date:   2016-06-14 16:37:27
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-05 11:19:27
Branch = class("Branch", function()
    local layer = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 200))
    layer:setNodeEventEnabled(true)
    return layer
end)


--已触发的支线任务
local BranchTaskList = {}
local tasklistByTptId = {}
--支线列表
local branchList = {}

Branch.Instance = nil
function Branch:ctor()
    Branch.Instance = self
    self.tmpLayer = nil
    

    display.newSprite("Block/branch/branch_img4.png")
    :addTo(self)
    :pos(display.cx, display.cy+270)

    local box = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(973,549),cc.rect(119, 127, 1, 1))
    :addTo(self)
    :pos(display.cx, display.cy-40)

    

    --关闭按钮
    local closeBtn = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_2_up.png",
        pressed = "common2/com2_Btn_2_down.png"
        })
    :addTo(box)
    :pos(box:getContentSize().width+10, box:getContentSize().height+10)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

    initBranchData()
    
    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(0, 15, 973, 519),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(box)
    self:reloadListView()
end

function initBranchData()
    BranchTaskList = {}
    tasklistByTptId = {}
    branchList = {}
    --已完成的支线任务
    print(srv_userInfo.subTaskGot)
    if srv_userInfo.subTaskGot~=nil and srv_userInfo.subTaskGot~="" then
        local finishedTask = string.split(srv_userInfo.subTaskGot, "|")
        for i=1,#finishedTask do
            local value = {}
            value.id = 0
            value.tptId = tonumber(finishedTask[i])
            value.sts = 2
            value.curcnt = 0
            table.insert(BranchTaskList, value)
        end
    end

    --已触发的支线任务
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==15 and (value.status==0 or value.status==1) then
            local v = {}
            v.id = value.id
            v.tptId = tonumber(value.tptId)
            v.sts = 1
            v.curcnt = value.curcnt
            table.insert(BranchTaskList, v)
        end
    end

    --排好序
    function sortfunc(a,b)
        return a.tptId<b.tptId
    end
    table.sort(BranchTaskList,sortfunc)

    --获取已触发过的支线列表显示出来
    for k,v in ipairs(BranchTaskList) do
        local isExist = false
        for l,w in ipairs(branchList) do
            local str = string.sub(tostring(v.tptId),4, 6)
            local branchId = 1000 + tonumber(str)
            if w==branchId then
                isExist = true
                break
            end
        end
        if not isExist then
            local str = string.sub(tostring(v.tptId),4, 6)
            local branchId = 1000 + tonumber(str)
            table.insert(branchList, branchId)
        end
    end

    for k,v in ipairs(BranchTaskList) do
        print(v.tptId)
        tasklistByTptId[v.tptId] = v
    end

    return branchList,tasklistByTptId
end

function Branch:reloadListView()
    self.lv:removeAllItems()

    for i=1,#branchList do
        loc_zhixian = BranchTaskData[branchList[i]]
        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(945, 158)
        self.lv:addItem(item)

        local bar = cc.ui.UIPushButton.new("Block/branch/branch_img1.png")
        :addTo(content)
        :onButtonPressed(function(event) event.target:setScale(0.98) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            self.zhixianId = branchList[i]
            self:createTaskList(branchList[i])
            end)

        local iconId = 104000 + branchList[i] - 1000
        local strName = "achIcon/achi_"..iconId..".png"
        display.newSprite(strName)
        :addTo(bar)
        :pos(-380, 0)

        --名字
        cc.ui.UILabel.new({UILabelType = 2, text = loc_zhixian.name, size = 30, color = cc.c3b(255, 241, 0)})
        :addTo(bar)
        :pos(-300,35)

        cc.ui.UILabel.new({UILabelType = 2, text = "支线进度：", size = 27, color = cc.c3b(175, 206, 226)})
        :addTo(bar)
        :pos(-300,-10)

        --进度条
        display.newSprite("Block/branch/branch_img7.png")
        :addTo(bar)
        :pos(-30, -40)
        local probar = display.newSprite("Block/branch/branch_img8.png")
        :addTo(bar)
        :pos(-30, -40)

        local isOnGoing = false
        self.subTaskId = 0
        self.taskTptId = 0
        local tasklist = string.split(loc_zhixian.taskId, "|")
        for i=1,#tasklist do
            local point = display.newGraySprite("Block/branch/branch_img3.png")
            :addTo(probar)
            :pos((i-1)*(probar:getContentSize().width/(#tasklist-1)), probar:getContentSize().height/2)
            if tasklistByTptId[tonumber(tasklist[i])] and tasklistByTptId[tonumber(tasklist[i])].sts==2 then
                point:clearFilter()
            elseif tasklistByTptId[tonumber(tasklist[i])] and tasklistByTptId[tonumber(tasklist[i])].sts==1 then
                point:clearFilter()
                isOnGoing = true
                if self.subTaskId==0 and tasklistByTptId[tonumber(tasklist[i])].id and tasklistByTptId[tonumber(tasklist[i])]~=0 then
                    self.subTaskId = tasklistByTptId[tonumber(tasklist[i])].id
                    self.taskTptId = tasklistByTptId[tonumber(tasklist[i])].tptId
                end
            else

            end
        end
        --是否进行中
        if isOnGoing then
            display.newSprite("Block/branch/branch_img5.png")
            :addTo(bar)
            :pos(-80,10)
        end

        cc.ui.UIPushButton.new("Block/branch/branch_img2.png")
        :addTo(bar)
        :pos(bar:getContentSize().width+350, bar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "完成任务", size = 30, color = cc.c3b(255, 164, 128)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            self.zhixianId = branchList[i]
            if self.taskTptId==0 then
                showTips("该支线任务已全部完成")
                return
            end
            local loc_taskTab = taskData[self.taskTptId]
            if loc_taskTab.tgtType==54 then
                local msg = "完成该任务将消耗"..loc_taskTab.cnt..itemData[tonumber(loc_taskTab.params)].name
                showMessageBox(msg, function()
                    startLoading()
                    TaskMgr:ReqSubmit(self.subTaskId)
                    end)
            elseif loc_taskTab.tgtType==55 then
                local msg = "完成该任务将消耗"..loc_taskTab.params.."金币和"..loc_taskTab.params2.."钻石"
                showMessageBox(msg, function()
                    startLoading()
                    TaskMgr:ReqSubmit(self.subTaskId)
                    end)
            else
                startLoading()
                TaskMgr:ReqSubmit(self.subTaskId)
            end
            
            end)
    end
    self.lv:reload()
end

function Branch:createTaskList(branchId)
    local loc_zhixian = BranchTaskData[branchId]
    self.branchId = branchId

    local tmpLayer = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 200))
    :addTo(self,10)
    self.tmpLayer = tmpLayer

    local box = display.newSprite("common/common_box.png")
    :addTo(tmpLayer)
    :pos(display.cx, display.cy)

     --关闭按钮
    local closeBtn = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_2_up.png",
        pressed = "common2/com2_Btn_2_down.png"
        })
    :addTo(box,10)
    :pos(box:getContentSize().width, box:getContentSize().height)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        tmpLayer:removeSelf()
        self.tmpLayer = nil
        end)

    --title
    local bar = cc.ui.UIPushButton.new("Block/branch/branch_img1.png")
    :addTo(box)
    :pos(box:getContentSize().width/2,box:getContentSize().height-70)

    local iconId = 104000 + branchId - 1000
    local strName = "achIcon/achi_"..iconId..".png"
    display.newSprite(strName)
    :addTo(bar)
    :pos(-380, 0)

    --名字
    cc.ui.UILabel.new({UILabelType = 2, text = loc_zhixian.name, size = 30, color = cc.c3b(255, 241, 0)})
    :addTo(bar)
    :pos(-300,35)

    cc.ui.UILabel.new({UILabelType = 2, text = "支线进度：", size = 27, color = cc.c3b(175, 206, 226)})
    :addTo(bar)
    :pos(-300,-10)

    --进度条
    display.newSprite("Block/branch/branch_img7.png")
    :addTo(bar)
    :pos(-30, -40)
    local probar = display.newSprite("Block/branch/branch_img8.png")
    :addTo(bar)
    :pos(-30, -40)

    local isOnGoing = false
    self.subTaskId = 0
    self.taskTptId = 0
    local tasklist = string.split(loc_zhixian.taskId, "|")
    for i=1,#tasklist do
        local point = display.newGraySprite("Block/branch/branch_img3.png")
        :addTo(probar)
        :pos((i-1)*(probar:getContentSize().width/(#tasklist-1)), probar:getContentSize().height/2)
        if tasklistByTptId[tonumber(tasklist[i])] and tasklistByTptId[tonumber(tasklist[i])].sts==2 then
            point:clearFilter()
        elseif tasklistByTptId[tonumber(tasklist[i])] and tasklistByTptId[tonumber(tasklist[i])].sts==1 then
            point:clearFilter()
            isOnGoing = true
            if self.subTaskId==0 and tasklistByTptId[tonumber(tasklist[i])].id and tasklistByTptId[tonumber(tasklist[i])]~=0 then
                self.subTaskId = tasklistByTptId[tonumber(tasklist[i])].id
                self.taskTptId = tasklistByTptId[tonumber(tasklist[i])].tptId
            end
        else

        end
    end
    --是否进行中
    if isOnGoing then
        display.newSprite("Block/branch/branch_img5.png")
        :addTo(bar)
        :pos(-80,10)
    end

    cc.ui.UIPushButton.new("Block/branch/branch_img2.png")
    :addTo(bar)
    :pos(bar:getContentSize().width+350, bar:getContentSize().height/2)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "完成任务", size = 30, color = cc.c3b(255, 164, 128)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if self.taskTptId==0 then
            showTips("该支线任务已全部完成")
            return
        end
        local loc_taskTab = taskData[self.taskTptId]
        if loc_taskTab.tgtType==54 then
            local msg = "完成该任务将消耗"..loc_taskTab.cnt..itemData[tonumber(loc_taskTab.params)].name
            showMessageBox(msg, function()
                startLoading()
                TaskMgr:ReqSubmit(self.subTaskId)
                end)
        elseif loc_taskTab.tgtType==55 then
            local msg = "完成该任务将消耗"..loc_taskTab.params.."金币和"..loc_taskTab.params2.."钻石"
            showMessageBox(msg, function()
                startLoading()
                TaskMgr:ReqSubmit(self.subTaskId)
                end)
        else
            startLoading()
            TaskMgr:ReqSubmit(self.subTaskId)
        end
        
        end)

    self.tasklv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(5, 50, 875, 440),
        -- alignment = cc.ui.UIScrollView.ALIGNMENT_BOTTOM,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(box)

    self:reloadTaskList(loc_zhixian.taskId)
end

function Branch:reloadTaskList(taskIds)
    local taskTpIds = string.split(taskIds, "|")

    self.tasklv:removeAllItems()

    for i=1,#taskTpIds do
        local loc_taskTab = taskData[tonumber(taskTpIds[i])]
        local item = self.tasklv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(380, 155)
        self.tasklv:addItem(item)

        local itemW,itemH = item:getItemSize()
        --上线
        local topLine = display.newSprite("Block/sweep/sweep_img7.png")
        :addTo(content)
        :pos(0, itemH/2-5)
        :setScaleY(1.67)
        --下线
        local bottomLine = display.newSprite("Block/sweep/sweep_img7.png")
        :addTo(content)
        :pos(0, -itemH/2+10)
        :setScaleY(1.67)

        display.newScale9Sprite("common/common_Frame27.png",0,0, cc.size(40,120))
        :addTo(content)
        :pos(-380,0)

        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "进度"..i , size = 27, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :align(display.CENTER, -380,0)
        lab:setWidth(20)

        local des = cc.ui.UILabel.new({UILabelType = 2, text = loc_taskTab.tgtDes , size = 23, color = cc.c3b(175, 206, 226)})
        :addTo(content)
        :pos(-340,30)

        local targetTxt1 = "目标："
        local targetNum = ""
        local targetTxt2 = ""
        local targetNum2 = ""
        local targetTxt3 = ""

        --根据不同类型区分目标描述
        -- 52.支线任务-等级要求
        -- 53.支线任务-关卡要求
        -- 54.支线任务-上交道具
        -- 55.支线任务-上交params金币与params2钻石
        -- 56.支线任务-击杀怪物
        -- 57.支线任务-params职业类型与params2职业等级
        if loc_taskTab.tgtType==52 then
            targetTxt1 = targetTxt1.."达到"
            targetNum = loc_taskTab.cnt
            targetTxt2 = "级"
        elseif loc_taskTab.tgtType==53 then
            targetTxt1 = targetTxt1.."通关"
            targetNum = blockData[tonumber(loc_taskTab.params)].name
            targetTxt2 = "关卡"
        elseif loc_taskTab.tgtType==54 then
            targetTxt1 = targetTxt1.."上交"
            targetNum = loc_taskTab.cnt
            targetTxt2 = itemData[tonumber(loc_taskTab.params)].name
        elseif loc_taskTab.tgtType==55 then
            targetTxt1 = targetTxt1.."上交"
            targetNum = loc_taskTab.params
            targetTxt2 = "金币和"
            targetNum2 = loc_taskTab.params2
            targetTxt3 = "钻石"
        elseif loc_taskTab.tgtType==56 then
            targetTxt1 = targetTxt1.."击杀"
            targetNum = loc_taskTab.cnt
            local monsterId = string.split(loc_taskTab.params, "#")
            targetTxt2 = "个"..monsterData[tonumber(monsterId[1])].name
            print(self.taskTptId)
            print(taskTpIds[i])
            if self.taskTptId == tonumber(taskTpIds[i]) then
                targetTxt2 = "个"..monsterData[tonumber(monsterId[1])].name.."，已击杀"
                if tasklistByTptId[self.taskTptId] then
                    targetNum2 = tasklistByTptId[self.taskTptId].curcnt
                else
                    targetNum2 = 0
                end
                targetTxt3 = "个"
            end

        elseif loc_taskTab.tgtType==57 then
            targetTxt1 = targetTxt1.."职业类型"
            if loc_taskTab.params==1 then
                targetNum = "坦克手"
            elseif loc_taskTab.params==2 then
                targetNum = "机械师"
            elseif loc_taskTab.params==3 then
                targetNum = "格斗家"
            end
            targetTxt2 = "，职业等级达到"
            targetNum2 = RoleTitle[loc_taskTab.params][loc_taskTab.cnt]
        end


        local targetDes = cc.ui.UILabel.new({UILabelType = 2, text = targetTxt1 , size = 23, color = cc.c3b(175, 206, 226)})
        :addTo(content)
        :pos(-340,-30)

        local numLabel = cc.ui.UILabel.new({UILabelType = 2, text = targetNum , size = 23, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(targetDes:getPositionX()+targetDes:getContentSize().width,targetDes:getPositionY())

        local label2 = cc.ui.UILabel.new({UILabelType = 2, text = targetTxt2 , size = 23, color = cc.c3b(175, 206, 226)})
        :addTo(content)
        :pos(numLabel:getPositionX()+numLabel:getContentSize().width,numLabel:getPositionY())

        local label3 = cc.ui.UILabel.new({UILabelType = 2, text = targetNum2 , size = 23, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width,label2:getPositionY())

        local label4 = cc.ui.UILabel.new({UILabelType = 2, text = targetTxt3 , size = 23, color = cc.c3b(175, 206, 226)})
        :addTo(content)
        :pos(label3:getPositionX()+label3:getContentSize().width,label3:getPositionY())

        --完成状态
        if tasklistByTptId[tonumber(taskTpIds[i])] and tasklistByTptId[tonumber(taskTpIds[i])].sts==2 then
            display.newSprite("Block/branch/branch_img6.png")
            :addTo(content)
            :pos(100,-20)
        end

        --奖励
        local label5 = cc.ui.UILabel.new({UILabelType = 2, text = "奖励：" , size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(200,-30)

        if loc_taskTab.rewardItems=="" or loc_taskTab.rewardItems=="null" then
            cc.ui.UILabel.new({UILabelType = 2, text = "无" , size = 23, color = cc.c3b(175, 206, 226)})
            :addTo(content)
            :pos(label5:getPositionX()+label5:getContentSize().width,label5:getPositionY())
        else
            local items = string.split(loc_taskTab.rewardItems, "#")
            if tonumber(items[1])==6 then
                local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=tonumber(items[2])})
                        :addTo(content)
                        :pos(350 ,-40)
                        carModel:setScaleY(0.5)
                        carModel:setScaleX(-0.5)
            else
                local itemIcon = createItemIcon(items[1], items[2], true, true, 2)
                :addTo(content)
                :pos(350 ,0)
            end
        end
    end

    self.tasklv:reload()
end

function Branch:OnSubmitRet(cmd)
    if cmd.result==1 then
        --获得奖励
        if taskData[tonumber(self.taskTptId)].rewardItems~="null" and taskData[tonumber(self.taskTptId)].rewardItems~="" then
            local reward = string.split(taskData[tonumber(self.taskTptId)].rewardItems, "#")
            if tonumber(reward[1])==6 then
                self:addAwardLayer(self,{carID = tonumber(reward[2])})
            else
                local curRewards = {}
                table.insert(curRewards, {templateID=tonumber(reward[1]), num=tonumber(reward[2])})
                GlobalShowGainBox(nil, curRewards)
            end
        end
        srv_userInfo.gold = cmd.data.gold
        srv_userInfo.diamond = cmd.data.diamond
        if mainscenetopbar then
            mainscenetopbar:setGlod()
            mainscenetopbar:setDiamond()
        end

        local taskIds = string.split(BranchTaskData[self.zhixianId].taskId, "|")
        local talkIds = string.split(BranchTaskData[self.zhixianId].talkId2, "|")
        local TriggerTalkId = 0
        for i=1,#taskIds do
            if tonumber(taskIds[i])==tonumber(self.taskTptId) then
                TriggerTalkId = talkIds[i]
                break
            end
        end

        self.dialog = UIDialog.new()
        :addTo(self,150)
        self.dialog:setVisible(true)
        self.dialog:TriggerDialog(tonumber(TriggerTalkId), DialogType.zhixianPlot)
        -- self.dialog:SetFinishCallback(handler(self,self.begainFight))


        if srv_userInfo.subTaskGot=="" then
            srv_userInfo.subTaskGot = self.taskTptId
        else
            srv_userInfo.subTaskGot = srv_userInfo.subTaskGot.."|"..self.taskTptId
        end
        
        initBranchData()
        self:reloadListView()

        if self.tmpLayer then
            self.tmpLayer:removeSelf()
            self.tmpLayer = nil

            self:createTaskList(self.branchId)
        end


    end
end

function Branch:addAwardLayer(parent,params)
    local self = parent
    local awardLayer = display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,240))
    :addTo(self,100)
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
        awardLayer:removeSelf()
    end)
end

function Branch:onExit()
    Branch.Instance = nil
end

return Branch