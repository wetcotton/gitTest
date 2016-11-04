
local levelGift = class("levelGift",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

local ACTIVITY_ID = 112001
levelGift_Instance = nil
--tag,1:开服冲级，2:豪华开服冲级
function levelGift:ctor(tag)
    self.tag = tag
    levelGift_Instance = self
    if tag==nil then
        tag=1
    end
    self.locDataList = {}
    print("======================tag:",tag)
    if tag==1 then
        ACTIVITY_ID = 112001
    elseif tag==2 then
        ACTIVITY_ID = 117001
    end

    for k,v in pairs(taskData) do
        if v.tgtType==TASKGOLE_LEVELACTIVITY and v.params==ACTIVITY_ID then
            self.locDataList[#self.locDataList+1] = v
        end
    end
    table.sort(self.locDataList,function (val_1,val_2)
        return val_1.id<val_2.id
    end)

    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2, bgSize.height-150)

    local titleImg = "youhui/youhuiTag_04.png"
    if ACTIVITY_ID == 117001 then
        titleImg = "youhui/youhuiTag_14.png"
    end

    display.newSprite(titleImg)
    :addTo(bg)
    :align(display.LEFT_CENTER,50, bgSize.height-90)

    display.newSprite("youhui/youhuiImg_10.png")
        :addTo(bg)
        :pos(bgSize.width/2-100,bgSize.height-100)

    local str = ""
    self.tipLabel = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(bg)
        :align(display.LEFT_BOTTOM,60,bgSize.height-200)
    self:refreshActivityTime()
    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(bg)
    :hide()
    :pos(bgSize.width-10,bgSize.height-20)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

    display.newSprite("youhui/youhuiTag_08.png")
        :addTo(bg)
        :pos(bgSize.width-100,bgSize.height-80)

    self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(35, 30, 840, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }
        :addTo(bg)
        -- :setBounceable(false)
    self:reloadListView()
end

--获取服务端任务数据中的开服登录奖励部分
function levelGift:getSrvOneWeekTask()
    local srvLevelGiftList = {}
    local minTaskTmpId = 0
    for i,value in pairs(TaskMgr.idKeyInfo) do
        -- print(value.tptId,taskData[value.tptId].tgtType)
        if taskData[value.tptId].tgtType==TASKGOLE_LEVELACTIVITY then
            if self.tag==1 and value.tptId>=113461001 and value.tptId<=113461010 then
                srvLevelGiftList[value.tptId] = value
                if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                    minTaskTmpId = value.tptId
                end
            elseif self.tag==2 and value.tptId>=113462001 and value.tptId<=113462010 then
                srvLevelGiftList[value.tptId] = value
                if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                    minTaskTmpId = value.tptId
                end
            end
            
        end
    end
    return srvLevelGiftList,minTaskTmpId
end

function levelGift:refreshActivityTime(startDate,endDate,startTime,endTime)
    local str = [[活动时间内达到以下等级，即可领取大礼!
]]
    startDate = startDate or tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
    endDate = endDate or tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
    str = str..tonumber(string.sub(startDate,1,4)).."年"
    str = str..tonumber(string.sub(startDate,5,6)).."月"
    str = str..tonumber(string.sub(startDate,7,8)).."日"
    if startTime then
        str = str..startTime
    end
    str = str.."~"
    str = str..tonumber(string.sub(endDate,1,4)).."年"
    str = str..tonumber(string.sub(endDate,5,6)).."月"
    str = str..tonumber(string.sub(endDate,7,8)).."日"
    if endTime then
        str = str..endTime
    end

    self.tipLabel:setString(str)
end
function levelGift:onEnter()
    if ACTIVITY_ID == 112001 then
        self:ReqTime()
    end
end
function levelGift:onExit()
    levelGift_Instance = nil
end 

function levelGift:reloadListView()
    self:performWithDelay(function ()
    self.listview:removeAllItems()

    for i=1,#self.locDataList do  --遍历成就表中所有的等级成就
        local task_data = self.locDataList[i]

        local content = display.newSprite("firstRecharge/rewardBar.png")
        local _size = content:getContentSize()
        local dayImg = display.newSprite("youhui/youhuiImg_09.png")
        :addTo(content)
        :pos(80, _size.height/2)

        display.newTTFLabel{text = task_data.cnt,size = 35,font = "fonts/slicker.ttf"}
            :addTo(content)
            :pos(63,_size.height/2-5)
        display.newTTFLabel{text = "级",size = 29,color = cc.c3b(251,201,65)}
            :addTo(content)
            :pos(105,_size.height/2-5)

        local idx = 0
        if task_data.diamond>0 then
            idx = idx + 1
            local icon = GlobalGetSpecialItemIcon(2, task_data.diamond, 1.05)
                :addTo(content)
                icon:setPosition(220+120*(idx-1),_size.height/2)
        end
        if task_data.gold>0 then
            idx = idx + 1
            local icon = GlobalGetSpecialItemIcon(1, task_data.gold, 1.05)
                :addTo(content)
                icon:setPosition(220+120*(idx-1),_size.height/2)
        end
        if task_data.energy>0 then
            idx = idx + 1
            local icon = GlobalGetSpecialItemIcon(4, task_data.energy, 1.05)
                :addTo(content)
                icon:setPosition(220+120*(idx-1),_size.height/2)
        end
        if task_data.rewardItems~="null" then
            local rewards = lua_string_split(task_data.rewardItems, "|")
            for i=1,#rewards do
                idx = idx + 1
                local rewardItem = lua_string_split(rewards[i],"#")
                local icon = createItemIcon(rewardItem[1],rewardItem[2],true,true)
                :addTo(content)
                icon:setScale(0.9)
                icon:setPosition(220+120*(idx-1),_size.height/2)
            end
        end

        local srvLevelGiftList,minTaskTmpId = self:getSrvOneWeekTask()

        --签到按钮
        print("-----------")
        printTable(srvLevelGiftList)
        print(task_data.id)
        print(srvLevelGiftList[task_data.id])
        local srv_taskData = srvLevelGiftList[task_data.id]
        local receiveBt = cc.ui.UIPushButton.new({normal = "firstRecharge/receiveBt1.png"})
        :addTo(content)
        :pos(_size.width - 120, _size.height/2)
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function(event)
            self.idx = i
            startLoading()
            TaskMgr:ReqSubmit(srv_taskData.id)
            end)

        if srv_taskData then
            print("有任务，",task_data.id,srv_taskData.status)
            if srv_taskData.status==0 then --未完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
                receiveBt:setTouchEnabled(false)
            elseif srv_taskData.status==1 then --已完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
                receiveBt:setTouchEnabled(true)
            elseif srv_taskData.status==2 then --已领取
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
                receiveBt:setTouchEnabled(false)
            end
        else
            print("没任务，",minTaskTmpId,task_data.id)
            if minTaskTmpId==0 or (task_data.id)<minTaskTmpId then --已领取
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
                receiveBt:setTouchEnabled(false)
            else  --未完成
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
                receiveBt:setTouchEnabled(false)
            end
            
        end


        local item = self.listview:newItem()
        item:addContent(content)
        item:setItemSize(840, 130)
        self.listview:addItem(item)
    end
    self.listview:reload()
    end,0.01)
end

--领取任务
function levelGift:OnSubmitRet(cmd)
    endLoading()
    if cmd.result==1 then
        self:reloadListView()

        --奖励弹框
        local curRewards = {}
        if self.locDataList[self.idx].diamond>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=self.locDataList[self.idx].diamond})
            srv_userInfo.diamond = srv_userInfo.diamond + self.locDataList[self.idx].diamond
            mainscenetopbar:setDiamond()
        end
        if self.locDataList[self.idx].gold>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=self.locDataList[self.idx].gold})
            srv_userInfo.gold = srv_userInfo.gold + self.locDataList[self.idx].gold
            mainscenetopbar:setGlod()
        end
        if self.locDataList[self.idx].energy>0 then
            table.insert(curRewards, {templateID=GAINBOXTPLID_STRENGTH, num=self.locDataList[self.idx].energy})
            srv_userInfo.energy = srv_userInfo.energy + self.locDataList[self.idx].energy
            mainscenetopbar:setEnergy()
        end
        if self.locDataList[self.idx].rewardItems~="null" then
            local rewards = lua_string_split(self.locDataList[self.idx].rewardItems, "|")
            for i=1,#rewards do
                local rewardItem = lua_string_split(rewards[i],"#")
                table.insert(curRewards, {templateID=tonumber(rewardItem[1]), num=tonumber(rewardItem[2])})
            end
        end
        
        GlobalShowGainBox(nil, curRewards)
    else
        showTips(cmd.msg)
    end
    
end

function levelGift:ReqTime()
    startLoading()
    comData={}
    comData["characterId"] = srv_userInfo.characterId
    m_socket:SendRequest(json.encode(comData), CMD_ACTIVITY, self, self.OnActivity)
end

function levelGift:OnActivity(cmd)
    endLoading()
    if cmd.result==1 then
        local actInfo = cmd.data.actInfo
        for k,v in pairs(actInfo) do
            if v.type==12 then
                printTable(v)
                local effDate = v.effDate
                local endDate = v.endDate
                print("effDate:",effDate,"endDate:",endDate)
                self:refreshActivityTime(effDate,endDate,v.effTime,v.endTime)
                break
            end
        end
    end
end

return levelGift