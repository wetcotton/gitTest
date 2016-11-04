-- @Author: anchen
-- @Date:   2015-09-16 22:08:36
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-01 15:23:55
--
--节日礼包
firstWeekReward = class("firstWeekReward",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)
ACTIVITY_ID = 103001
firstWeekReward.Instance = nil
function firstWeekReward:ctor()
    local activityType = "3"
    -- printTable(srv_userInfo.actInfo)
    ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType]
    local rewardBox = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,cc.size(900,621))
    :addTo(self)
    :pos(display.cx, display.cy-20)
    local rewardsize = rewardBox:getContentSize()


    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(rewardBox)
    :pos(rewardBox:getContentSize().width-10,rewardBox:getContentSize().height-20)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)
    :hide()

    -- local tmpBox = display.newSprite("firstRecharge/xxcx_img5.png")
    -- :addTo(rewardBox)
    -- :pos(rewardsize.width/2, rewardsize.height/2-50)
    display.newSprite("youhui/holidayBg_01.png")
    :addTo(rewardBox)
    :pos(rewardsize.width/2-110, rewardsize.height/2+165)

    cc.ui.UILabel.new({UILabelType = 2, text = "每日登陆，即可领取圣诞大礼包，过时不候哦！", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(rewardBox)
    :pos(60,rewardsize.height/2+100)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "活动时间：", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(rewardBox)
    :pos(60,rewardsize.height/2+60)

    -- cc.ui.UILabel.new({UILabelType = 2, text = "2015年12月24日-2015年12月27日", size = 25})
    -- :addTo(rewardBox)
    -- :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())

    self.activityTime = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(rewardBox)
        :align(display.LEFT_BOTTOM,60,rewardsize.height/2)

    local datestr = "活动时间："
    local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
    datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
    startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
    self.activityTime:setString(datestr)


    local oldSister = display.newSprite("Bust/bust_20041.png")
    :addTo(rewardBox,2)
    :pos(rewardsize.width - 130, rewardsize.height/2+160)
    oldSister:setScaleX(-1)

    self.listview = cc.ui.UIListView.new {
        bgColor = cc.c4b(200, 0, 0, 50),
        viewRect = cc.rect(26, 30, 841, 238),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
        }
        :addTo(rewardBox)

    self:reloadListView()

end
function firstWeekReward:onEnter()
    firstWeekReward.Instance = self
end
function firstWeekReward:onExit()
    firstWeekReward.Instance = nil
end

function firstWeekReward:reloadListView()
    self.listview:removeAllItems()
    local loc_Data = self:getLocalTask()
    local srv_Data,minTaskTmpId = self:getSrvTask()

    for i,value in ipairs(loc_Data) do
        local itemBox = cc.ui.UIPushButton.new("youhui/youhuiImg_01.png")
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function(event)
            print(srv_Data[value.id]~=nil)
            print(srv_Data[value.id].status==0)
            if i==1 and srv_Data[value.id]~=nil and srv_Data[value.id].status==0 then
                showTips("等级到达5级后可领取！")
                return
            end
            self.value  = value
            self.curItem = event.target
            startLoading()
            TaskMgr:ReqSubmit(srv_Data[value.id].id)
            
            end)
        local _size = itemBox.sprite_[1]:getContentSize()
        removeSignCircleAnimation(itemBox)
        itemBox:setButtonEnabled(false)
        itemBox:setTouchSwallowEnabled(false)
        local reward = lua_string_split(value.rewardItems,"#")
        local icon = createItemIcon(tonumber(reward[1]), tonumber(reward[2]))
        -- local icon = display.newSprite("recharge/diamond4.png")
        :addTo(itemBox)
        :pos(0,0)

        if next(srv_Data)==nil then
            -- print("aaaa")
            display.newSprite("youhui/youhuiImg_02.png")
            :addTo(itemBox)
            :pos(0,-20)
        else
            -- print("bbb")
            -- print(value.id)
            if srv_Data[value.id]==nil and value.id<minTaskTmpId then
                display.newSprite("youhui/youhuiImg_02.png")
                :addTo(itemBox)
                :pos(0,-20)
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==2 then
                display.newSprite("youhui/youhuiImg_02.png")
                :addTo(itemBox)
                :pos(0,-20)
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==1 then
                itemBox:setButtonEnabled(true)
                signCircleAnimation(itemBox,0,0,3.5)
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==0 
                    and i==1 then --第一天未达到指定等级时也显示光圈
                signCircleAnimation(itemBox,0,0,3.5)
                itemBox:setButtonEnabled(true)
            end
        end

        local item = self.listview:newItem()
        item:addContent(itemBox)
        item:setItemSize(_size.width+15, _size.height)
        self.listview:addItem(item)
        
    end
    self.listview:reload()
end

--获取本地任务表中的首充送大礼部分
function firstWeekReward:getLocalTask()
    local tmpData = {}
    for i,value in pairs(taskData) do
        if value.type==3 then
            print("value.params2",value.params,ACTIVITY_ID)
            if value.params2==ACTIVITY_ID then
                table.insert(tmpData, value)
            end
        end
    end
    function sortfunc(a,b)
        if a.id<b.id then
            return true
        else
            return false
        end
    end
    table.sort(tmpData, sortfunc)

    return tmpData
end
--获取服务端任务数据
function firstWeekReward:getSrvTask()
    local tmpData = {}
    local minTaskTmpId = 0
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==3 then
            tmpData[value.tptId] = value
            if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                minTaskTmpId = value.tptId
            end
        end
    end
    return tmpData,minTaskTmpId
end

function firstWeekReward:OnSubmitRet(cmd)
    if cmd.result==1 then
        display.newSprite("youhui/youhuiImg_02.png")
        :addTo(self.curItem)
        :pos(0,-20)
        self.curItem:setButtonEnabled(false)
        removeSignCircleAnimation(self.curItem)

        -- srv_userInfo.diamond = srv_userInfo.diamond + self.value.diamond
        -- mainscenetopbar:setDiamond()
        -- mainscenetopbar:setDiamond()

        --奖励弹框
        local curRewards = {}
        local reward = lua_string_split(self.value.rewardItems,"#")
        table.insert(curRewards, {templateID=tonumber(reward[1]), num=tonumber(reward[2])})
        GlobalShowGainBox(nil, curRewards)
    else
        showTips(cmd.msg)
    end
end

return firstWeekReward