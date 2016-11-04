-- @Author: anchen
-- @Date:   2015-12-11 10:46:26
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-05-23 16:33:09
foundAct = class("foundAct",function()
    -- local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)
ACTIVITY_ID = 111001
foundAct.Instance = nil
function foundAct:ctor()
    totalRechage_Instance = self
    local activityType = "11"
    ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType]
    local rewardBox = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,cc.size(900,621))
    :addTo(self)
    :pos(display.cx, display.cy-20)
    self.rewardBox = rewardBox
    local tmpsize = rewardBox:getContentSize()

    --关闭按钮
    -- self.closeBtn = cc.ui.UIPushButton.new({
    --     normal="common/common_BackBtn_1.png",
    --     pressed="common/common_BackBtn_2.png"})
    --     :align(display.LEFT_TOP, 0, display.height )
    --     :addTo(self)
    --     :onButtonClicked(function(event)
    --         self:removeSelf()
    --     end)

    if srv_userInfo.fundId==0 then
        self.NotBuy=true
        self:NotBuyFoundInit()
    else
        self.NotBuy=false
        self:BuyFoundInit()
    end
    
end
--没有购买基金
function foundAct:NotBuyFoundInit()
    local tmpsize = self.rewardBox:getContentSize()

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width/2,tmpsize.height-150)

    cc.ui.UILabel.new({UILabelType = 2, text = "新的启程，让自己赢在起跑线上吧！", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(self.rewardBox)
    :pos(80,tmpsize.height-50)

    display.newSprite("youhui/youhuiTag_01.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width/2-50,tmpsize.height-110)

    --美女
    local beauty = display.newSprite("youhui/youhuiTag_08.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width-100,tmpsize.height-110)

    --充值按钮
    cc.ui.UIPushButton.new("youhui/youhuiBnt_01.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width-100,tmpsize.height-240)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "充值", size = 35}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        g_recharge.new()
            :addTo(display.getRunningScene())
        end)

    --规则
    local ruleText = cc.ui.UILabel.new({UILabelType = 2, text = "规则：", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(self.rewardBox)
    :pos(40,tmpsize.height-180)

    cc.ui.UILabel.new({UILabelType = 2, text = "1、三种基金只能选择一份购买，请谨慎选择", size = 25})
    :addTo(self.rewardBox)
    :pos(ruleText:getPositionX()+ruleText:getContentSize().width,ruleText:getPositionY())

    cc.ui.UILabel.new({UILabelType = 2, text = "2、每日登陆可获取一次返利，七日获得所有返利", size = 25})
    :addTo(self.rewardBox)
    :pos(ruleText:getPositionX()+ruleText:getContentSize().width,ruleText:getPositionY()-30)

    -- local label = cc.ui.UILabel.new({UILabelType = 2, text = "3、投资时间：", size = 25})
    -- :addTo(self.rewardBox)
    -- :pos(ruleText:getPositionX()+ruleText:getContentSize().width,ruleText:getPositionY()-60)

    self.activityTime = display.newTTFLabel{text = str,size= 25,color= cc.c3b(18,186,229)}
        :addTo(self.rewardBox)
        :align(display.LEFT_BOTTOM,60,tmpsize.height/2+28)

    local datestr = "活动时间："
    print("ACTIVITY_ID: ",ACTIVITY_ID)
    local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
    datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
    startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
    self.activityTime:setString(datestr)


    local tab = {
        {pos=cc.p(tmpsize.width/2-280,180), title = "拉多基金", img = "common2/com2_Img_9.png", des = "花费500钻，七日可获得750钻"},
        {pos=cc.p(tmpsize.width/2,180), title = "波布基金", img = "common2/com2_Img_10.png", des = "花费2000钻，七日可获得3600钻"},
        {pos=cc.p(tmpsize.width/2+280,180), title = "奥多基金", img = "common2/com2_Img_12.png", des = "花费5000钻，七日可获得10000钻"},
    }

    local sortList = {}
    for k,v in pairs(foundData) do
        --基金表里有不同的档位，对应不同的运营活动，通过运营活动开启情况个来确定
        print("v.aid",v.aid,ACTIVITY_ID)
        if v.aid==ACTIVITY_ID then
            sortList[#sortList+1] = v.id
        end
    end
    table.sort( sortList, function (val_1,val_2)
        return val_1<val_2
    end )

    --三种基金
    for i=1,#sortList do
        print(sortList[i])
        local locTab = foundData[sortList[i]]

        local selectBt = cc.ui.UIPushButton.new("youhui/youhuiImg_05.png")
        :addTo(self.rewardBox)
        :pos(tab[i].pos.x, tab[i].pos.y)
        :onButtonPressed(function(event) event.target:setScale(0.98) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            self:showFoundList(i,locTab)
            end)
        --钻石
        display.newSprite(tab[i].img)
        :addTo(selectBt)

        local title =cc.ui.UILabel.new({UILabelType = 2, text =locTab.name , size = 30,color = cc.c3b(255, 241, 0)})
        :addTo(selectBt)
        :align(display.CENTER, 0, 100)
        setLabelStroke(title,30,nil,nil,nil,nil,nil,nil, true)

        local des =cc.ui.UILabel.new({UILabelType = 2, text =tab[i].des , size = 22})
        :addTo(selectBt)
        :align(display.CENTER, 0, -100)
        des:setWidth(200)

        local coner = display.newSprite("youhui/youhuiImg_06.png")
        :addTo(selectBt)
        :align(display.CENTER, -110, 120)

        local label = cc.ui.UILabel.new({UILabelType = 2, text = "收益", size = 22,color = cc.c3b(255, 241, 0)})
        :addTo(coner,2)
        :align(display.CENTER,coner:getContentSize().width/2-8, coner:getContentSize().height/2+13)
        label:setRotation(-30)
        label:setLineHeight(20)
        local retNode = setLabelStroke(label,22,cc.c3b(136, 9, 18),1,nil,nil,nil,nil, true)
        setLabelRotation(label, retNode, -30)
        setLabelLineHeight(centerLabel, retNode, 20)

        --计算收益值
        local arrNum = lua_string_split(locTab.ret,"|")
        local income=0
        for i=1,#arrNum do
            income = income + arrNum[i]
        end
        local pro = income/locTab.diamond*100
        local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = pro.."%", size = 22})
        :addTo(coner,2)
        :align(display.CENTER,coner:getContentSize().width/2+3, coner:getContentSize().height/2-8)
        label:setRotation(-30)
        label:setLineHeight(20)
        local retNode = setLabelStroke(label,22,cc.c3b(136, 9, 18),1,nil,nil,nil,"fonts/slicker.ttf", true)
        setLabelRotation(label, retNode, -30)
        setLabelLineHeight(centerLabel, retNode, 20)
    end
end
--购买了基金初始化
function foundAct:BuyFoundInit()
    local tmpsize = self.rewardBox:getContentSize()

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width/2,tmpsize.height-150)

    cc.ui.UILabel.new({UILabelType = 2, text = "新的启程，让自己赢在起跑线上吧！", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(self.rewardBox)
    :pos(80,tmpsize.height-50)

    display.newSprite("youhui/youhuiTag_01.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width/2-50,tmpsize.height-110)

    --美女
    local beauty = display.newSprite("youhui/youhuiTag_08.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width-100,tmpsize.height-110)

    --名字
    local text = foundData[srv_userInfo.fundId].name or ""
    local label = cc.ui.UILabel.new({UILabelType = 2, text = text, size = 25, color = cc.c3b(255, 241, 0)})
    :addTo(self.rewardBox, 1)
    :align(display.CENTER, 140,tmpsize.height-207)

    --名字底框
    local img = display.newScale9Sprite("youhui/youhuiImg_03.png",nil,nil, cc.size(label:getContentSize().width+15,label:getContentSize().height+8))
    :addTo(self.rewardBox)
    :pos(label:getPositionX(), label:getPositionY())

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "总收益", size = 28, color = cc.c3b(0, 160, 233)})
    :addTo(self.rewardBox)
    :pos(img:getPositionX()+img:getContentSize().width/2+10,tmpsize.height-207)


    local arrNum = lua_string_split(foundData[srv_userInfo.fundId].ret,"|")
    local income=0
    for i=1,#arrNum do
        income = income + arrNum[i]
    end
    local pro = income/foundData[srv_userInfo.fundId].diamond*100

    cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = pro.."%", size = 28, color = cc.c3b(255, 241, 0)})
    :addTo(self.rewardBox)
    :pos(label:getPositionX()+label:getContentSize().width+5,label:getPositionY())


    self.foundLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(60, 30, 770, 360),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.rewardBox)

    self:reloadRewardLv()
end
function foundAct:reloadRewardLv()
    self.foundLv:removeAllItems()

    local loc_Data = self:getLocalTask()
    local srv_Data,minTaskTmpId = self:getSrvTask()
    local locTab = foundData[srv_userInfo.fundId]
    retArr = lua_string_split(locTab.ret,"|")
    for i=1,#retArr do
        local value = loc_Data[i]
        local item = self.foundLv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(770, 110)
        self.foundLv:addItem(item)

        local bar = display.newSprite("youhui/youhuiImg_04.png")
        :addTo(content)

        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "第", size = 30,color = cc.c3b(0, 160, 233)})
        :addTo(bar)
        :pos(25,bar:getContentSize().height/2)

        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = i, size = 33,color = cc.c3b(255, 241, 0)})
        :addTo(bar)
        :pos(label1:getPositionX()+label1:getContentSize().width+10,label1:getPositionY())

        local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "天可领取", size = 30,color = cc.c3b(0, 160, 233)})
        :addTo(bar)
        :pos(label2:getPositionX()+label2:getContentSize().width+10,label1:getPositionY())

        local label4 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = retArr[i], size = 33,color = cc.c3b(255, 241, 0)})
        :addTo(bar)
        :pos(label3:getPositionX()+label3:getContentSize().width+10,label1:getPositionY())

        display.newSprite("common/common_Diamond.png")
        :addTo(bar)
        :pos(label4:getPositionX()+label4:getContentSize().width+40,label1:getPositionY())

        local getDia=0
        local curI = 0
        for j=1,i do
            getDia = getDia + retArr[j]
            if getDia>=locTab.diamond then
                curI = j
                break
            end
        end
        if curI==i then
            --赚回本金
            display.newSprite("youhui/youhuiTag_02.png")
            :addTo(bar)
            :pos(bar:getContentSize().width/2+100,bar:getContentSize().height/2)
        end
        

        --领取按钮
        local bt = cc.ui.UIPushButton.new({
            normal = "youhui/youhuiBnt_01.png"
            },{grayState=true})
        :addTo(bar)
        :pos(bar:getContentSize().width-80,bar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "领取", size = 35}))
        :onButtonPressed(function(event) event.target:setScale(0.95*0.8) end)
        :onButtonRelease(function(event) event.target:setScale(1.0*0.8) end)
        :onButtonClicked(function(event)
            self.value  = value
            self.curItem = event.target
            startLoading()
            TaskMgr:ReqSubmit(srv_Data[value.id].id)
            
            end)
        :scale(0.8)

        if next(srv_Data)==nil then --全部领完
            bt:removeSelf()
            display.newSprite("youhui/youhuiImg_02.png")
            :addTo(bar)
            :pos(bar:getContentSize().width-80,bar:getContentSize().height/2)
        else
            if self.NotBuy and i==1 then --刚刚买完基金进来后第一天是可领取的
            elseif srv_Data[value.id]==nil and value.id<minTaskTmpId then --已领完
                bt:removeSelf()
                display.newSprite("youhui/youhuiImg_02.png")
                :addTo(bar)
                :pos(bar:getContentSize().width-80,bar:getContentSize().height/2)
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==2 then --已领完
                bt:removeSelf()
                display.newSprite("youhui/youhuiImg_02.png")
                :addTo(bar)
                :pos(bar:getContentSize().width-80,bar:getContentSize().height/2)
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==1 then --当前可领
            elseif srv_Data[value.id]~=nil and srv_Data[value.id].status==0 then --没有完成，不能领取
                bt:setButtonEnabled(false)
            else
                bt:setButtonEnabled(false)
            end
        end
        
    end
    self.foundLv:reload()
end
--获取本地任务表中的部分
function foundAct:getLocalTask()

    local tmpData = {}
    for i,value in pairs(taskData) do
        if value.params2==srv_userInfo.fundId then
            table.insert(tmpData, value)
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
--获取服务端任务
function foundAct:getSrvTask()
    local tmpData = {}
    local minTaskTmpId = 0

    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].params2==srv_userInfo.fundId then
            tmpData[value.tptId] = value
            if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                minTaskTmpId = value.tptId
            end
        end
    end

    return tmpData,minTaskTmpId
end

function foundAct:showFoundList(type,locTab)
    local box = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,cc.size(854,546))
    :addTo(self.rewardBox)
    :pos(self.rewardBox:getContentSize().width/2, self.rewardBox:getContentSize().height/2)
    box:setTouchEnabled(true)

    local tmpsize = box:getContentSize()

    --关闭按钮
    cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
    :addTo(box)
    :pos(tmpsize.width+20,tmpsize.height-35)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        box:removeSelf()
        end)

    self.showLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(40, 120, 770, 400),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(box)

    retArr = lua_string_split(locTab.ret,"|")
    for i=1,#retArr do
        local item = self.showLv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(770, 110)
        self.showLv:addItem(item)

        local bar = display.newSprite("youhui/youhuiImg_04.png")
        :addTo(content)

        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "第", size = 30,color = cc.c3b(0, 160, 233)})
        :addTo(bar)
        :pos(25,bar:getContentSize().height/2)

        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = i, size = 33,color = cc.c3b(255, 241, 0)})
        :addTo(bar)
        :pos(label1:getPositionX()+label1:getContentSize().width+10,label1:getPositionY())

        local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "天可领取", size = 30,color = cc.c3b(0, 160, 233)})
        :addTo(bar)
        :pos(label2:getPositionX()+label2:getContentSize().width+10,label1:getPositionY())

        local label4 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = retArr[i], size = 33,color = cc.c3b(255, 241, 0)})
        :addTo(bar)
        :pos(label3:getPositionX()+label3:getContentSize().width+10,label1:getPositionY())

        display.newSprite("common/common_Diamond.png")
        :addTo(bar)
        :pos(label4:getPositionX()+label4:getContentSize().width+40,label1:getPositionY())

        --领取按钮
        -- cc.ui.UIPushButton.new({normal = "youhui/youhuiBnt_01.png"})
        -- :addTo(bar)
        -- :pos(bar:getContentSize().width-80,bar:getContentSize().height/2)
        -- :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "领取", size = 35}))
        -- :onButtonPressed(function(event) event.target:setScale(0.95) end)
        -- :onButtonRelease(function(event) event.target:setScale(1.0) end)
        -- :onButtonClicked(function(event)
        --     end)
        -- :scale(0.7)

        
    end
    self.showLv:reload()

    --确认购买
    cc.ui.UIPushButton.new({normal = "youhui/youhuiBnt_01.png"})
    :addTo(box)
    :pos(box:getContentSize().width/2,65)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确认购买", size = 35}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        startLoading()
        local sendData = {}
        sendData.fid = locTab.id
        m_socket:SendRequest(json.encode(sendData), CMD_GUYFUND, self, self.onBuyFunRet)
        end)
end
--购买基金返回
function foundAct:onBuyFunRet(result)
    if result.result==1 then
        showTips("购买成功。")
        srv_userInfo.diamond = result.data.diamond
        if mainscenetopbar then
            mainscenetopbar:setDiamond()
        end
        self.rewardBox:removeAllChildren()

        srv_userInfo.fundId = result.data.fundId

        self:BuyFoundInit()
        self.NotBuy=false

    else
        showTips(result.msg)
    end
end
function foundAct:onEnter()
    foundAct.Instance = self
end
function foundAct:onExit()
    foundAct.Instance = nil
end
function foundAct:OnSubmitRet(cmd)
    if cmd.result==1 then
        local parent = self.curItem:getParent()
        self.curItem:removeSelf()
        display.newSprite("youhui/youhuiImg_02.png")
            :addTo(parent)
            :pos(parent:getContentSize().width-80,parent:getContentSize().height/2)

        --奖励弹框
        local curRewards = {}
        table.insert(curRewards, {templateID=2, num=self.value.diamond})
        GlobalShowGainBox(nil, curRewards)

        srv_userInfo.diamond = cmd.data.diamond
        mainscenetopbar:setDiamond()

        if fundLayer.instance then --基金界面的按钮红点
            fundLayer.instance:btRedPoint()
        end
    else
        showTips(cmd.msg)
    end
end

return foundAct