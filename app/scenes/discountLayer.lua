-- local xx,g_totolConsume = reloadLuaFile("app.scenes.businessActivity.totalConsume")
-- local xx,g_flashSale = reloadLuaFile("app.scenes.businessActivity.flashSale")
-- local xx,g_oneWeekReward = reloadLuaFile("app.scenes.businessActivity.oneWeekReward")
-- local xx,g_firstRecharge = reloadLuaFile("app.scenes.businessActivity.firstRecharge")
-- local xx,g_firstWeekReward = reloadLuaFile("app.scenes.businessActivity.firstWeekReward")
-- local xx,LimitConsume = reloadLuaFile("app.scenes.shop.LimitConsume")

local discountLayer = class("discountLayer",function ()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)

local activitys = {
	{"youhui/discountBtn_1.png",g_totolConsume,false,"累计消费"},--累计消费
	{"youhui/discountBtn_2.png",g_flashSale,false,"超值礼包"},--限时促销礼包
	{"youhui/discountBtn_3.png",g_firstWeekReward,false,"节日大礼"},--节日大礼
	{"youhui/discountBtn_4.png",nil,false,"限时促销"},--限时促销
    {"youhui/discountBtn_5.png",g_firstRecharge,true,"首冲礼包"},--首冲礼包
    {"youhui/discountBtn_6.png",g_oneWeekReward,false,"开服活动"},--开服活动
    {"youhui/discountBtn_7.png",g_levelGift,true,"成长礼包"},--冲级礼包
    {"youhui/discountBtn_8.png",foundAct,false,"城镇基金"},--勇士基金
    {"youhui/discountBtn_9.png",g_totalRecharge,false},--累计充值
    {"youhui/discountBtn_7.png",g_levelGift,false,"猎人豪礼"},--豪华冲级礼包
	{"youhui/discountBtn_11.png",g_itemExchangeAct,false,"集福大礼"},--物品兑换
    {"youhui/discountBtn_9.png",g_totalRecharge,false},--累计充值2
    {"youhui/discountBtn_9.png",g_totalRecharge,false},--累计充值3
}

discountInstance = nil

function discountLayer:ctor()
    discountInstance = self
	self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)

	self.backBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
	    :align(display.LEFT_TOP, 0, display.height )
	    :addTo(self,10)
	    :onButtonClicked(function(event)
            if MainScene_Instance then
                print("任务成就红点")
                MainScene_Instance:refreshTaskRedPoin()
            end
	        self:removeFromParent()
	    end)

	self.listView = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(80, 20, 240, 600),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self)
    self.m_node = display.newNode()
        :addTo(self,10)
        :pos(display.cx,display.cy)
    self.activityBtns = {}
    self:initListView()
    --self:refreshBtns()

    --活动按钮
    local actBt = cc.ui.UIPushButton.new({normal = "youhui/youhuiTag_20.png"})
    :addTo(self)
    :pos(display.width/2-220, display.height-33)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        g_activityLayer.new()
        :addTo(display.getRunningScene())
        end)
    -- cc.ui.UILabel.new({UILabelType = 2, text = "惊喜福利", size = 25, color = cc.c3b(255, 255, 0)})
    -- :addTo(self)
    -- :align(display.CENTER, display.width/2-210, display.height-40)
    local act1 = cc.MoveBy:create(0.5,cc.p(20,0))
    local act2 = cc.MoveBy:create(1.5,cc.p(-40,0))
    actBt:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2,act1)))

end

function discountLayer:initListView()
    self.activityBtns = {}
        local isFirst = true
        local index_ = 0
        self.listView:removeAllItems()
    	for i=1,#activitys do
            if activitys[i][3] then
        		print("i:"..i)
                print(activitys[i][1])
        		local item = self.listView:newItem()
                local content = cc.ui.UIPushButton.new({normal="firstRecharge/discountImg_1.png",pressed="firstRecharge/discountImg_1.png",disabled="firstRecharge/discountImg_2.png"})
                        :scale(0.96)
                        :onButtonClicked(function(event)
                            self:ChooseActivityItem(i)
                        end)
                display.newSprite(activitys[i][1])
                	:addTo(content)
                    :pos(-18,0)

                local label = cc.ui.UILabel.new({UILabelType = 2, text = activitys[i][4], size = 32})
                :addTo(content,2)
                :align(display.CENTER,10,0)
                local retNode = setLabelStroke(label,32,display.COLOR_BLACK,nil,nil,nil,nil,nil, true)
                if i==9 or i==12 or i==13 then --累计充值的名字从服务端获取，客户端没办法区分是哪个累计充值活动
                    local act_14 = srv_userInfo.actInfo.actIds["14"]
                    for k,v in ipairs(act_14) do
                        if (k==1 and i==9) or (k==2 and i==12) or (k==3 and i==13) then
                            label:setString(srv_userInfo.actInfo.actTime[tostring(v)].param)
                            setLabelStrokeString(label, retNode)
                        end 
                        
                    end
                    
                end

                content:setTouchSwallowEnabled(false)

                item:addContent(content)
                item:setItemSize(240, 94)
                self.listView:addItem(item)
                self.activityBtns[i] = content
                if isFirst then
                    isFirst = false
                    index_ = i
                end
            end
    	end
        self.listView:reload()
        if index_~=0 then
            self:ChooseActivityItem(index_)
        end

        self:refreshActivityRedPoint()
end

function discountLayer:ChooseActivityItem(index)
    if activitys[index]==nil then
        return
    end
	for i,v in pairs(self.activityBtns) do
        if self.activityBtns[i]~=nil then
            self.activityBtns[i]:setButtonEnabled(true)
            if i==index then
                self.activityBtns[i]:setButtonEnabled(false)
            end
        end
    end

    if self.m_node then
        self.m_node:removeFromParent()
        self.m_node = nil
    end
    
    if index==4 then
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_GETLIMITCOMSUME, self, self.onGetLimitConsumeInfo)
    else
        print('index',index)
        local parmas = nil
        if index==7 or index==9 then
            parmas = 1
        elseif index==10 or index==12 then
            parmas = 2
        elseif index==13 then
            parmas = 3
        end
        self.m_node = activitys[index][2].new(parmas)
            :addTo(self)
            :pos(150,0)
    end

end

function discountLayer:onGetLimitConsumeInfo(cmd)
    if cmd.result == 1 then
       self.m_node = LimitConsume.new(cmd.data)
            :addTo(self)
            :pos(150,0)

    else
       showTips(cmd.msg)
    end
end

function discountLayer:onEnter()
    self:updateCheckActivity()
    self.activityHandle = scheduler.scheduleGlobal(handler(self, self.updateCheckActivity), 300)
    
end

function discountLayer:onExit( ... )
    if self.activityHandle~=nil then
        scheduler.unscheduleGlobal(self.activityHandle)
        self.activityHandle = nil
    end
    discountInstance = nil
end

function discountLayer:updateCheckActivity()
    self:ReqBusinessOpenDetail()
end

--h获取运营活动开启情况
function discountLayer:ReqBusinessOpenDetail()    
    local sendData={}
    m_socket:SendRequest(json.encode(sendData), CMD_BUSINESS_OPEN, self, self.OnBusinessOpenDetailRet)
end

function discountLayer:OnBusinessOpenDetailRet(cmd)
        if cmd.result==1 then
            srv_userInfo.actInfo = cmd.data
            print("-------------")
            print(srv_userInfo.actInfo)
            printTable(srv_userInfo.actInfo)
            print("修改sctSts完毕")
            self:checkAndOpenBusinessDoor()
            self:initListView()
            --self:refreshBtns()
        else
            showTips(cmd.msg)
        end
    end

function discountLayer:checkAndOpenBusinessDoor()
    for i=1,#activitys do
        activitys[i][3] = false
    end
    activitys[5][3] = true
    -- activitys[6][3] = true --开服七天礼提到外面了
    
    

    local list = {}
    for k,v in pairs(srv_userInfo.actInfo.actSts) do
        list[#list+1] = {k,v}
    end

    table.sort( list, function (v_1,v_2)
        return tonumber(v_1[1])<tonumber(v_2[1])
    end )

    local offX = display.width-460
    for i=1,#list do
        local v = list[i][2]
        local k = list[i][1]
        if v==1 then    --1为开启，0位未开启
            --print("---   "..k)
            if k=="1"then       --限时消费
                activitys[4][3] = true
            elseif k=="2"then   --限时促销
                activitys[2][3] = true
            elseif k=="3"then   --首周福利
                activitys[3][3] = true
            elseif k=="4"then   --累计消费
                activitys[1][3] = true
            elseif k=="11"then  --基金活动
                activitys[8][3] = false
            elseif k=="12"then  --开服冲级
                activitys[7][3] = true
            elseif k=="14"then  --累计充值
                --增加充值活动需要修改此处代码
                self.prama_actIds = {}  --创建累计充值对象的时候传过去的参数
                if srv_userInfo.actInfo.actIds["14"] then
                    local act_14 = srv_userInfo.actInfo.actIds["14"]
                    for j=1,#act_14 do
                        self.prama_actIds[j] = act_14[j]
                        if j==1 then
                            activitys[9][3] = true
                        elseif j==2 then
                            activitys[12][3] = true
                        elseif j==3 then
                            activitys[13][3] = true
                        end
                    end
                end
            elseif k=="17"then  --豪华开服冲级
                activitys[10][3] = true
            elseif k=="18"then  --物品兑换
                activitys[11][3] = true
            end
           offX = offX-130     
        end
    end

    local srvData = nil
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==8 then
            srvData = value
        end
    end
    if srvData==nil or srvData.status==2 then
        activitys[5][3] = false
    end

    local srvOneweekData = false
    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].type==9 then
            srvOneweekData = true
        end
    end
    -- if not srvOneweekData then
    --     activitys[6][3] = false
    -- end

end

function discountLayer:closeActivity(index)
    if activitys[index][3]==true then
        activitys[index][3] = false
    end
    self:initListView()
end

function discountLayer:refreshActivityRedPoint()
    --累计充值红点   --增加充值活动需要修改此处代码
    local num = TaskMgr:GetCanSubNum(TaskTag.TotalConsume)
    local node1 = self.activityBtns[9]
    local node1_12 = self.activityBtns[12]
    local node1_13 = self.activityBtns[13]
    if node1 or node1_12 or node1_13 then
        local _handler = {}
        function _handler:func(cmd)
            if cmd.result==1 then
                for k,v in ipairs(srv_userInfo.actInfo.actIds["14"]) do
                    if k==1 then
                        node1:removeChildByTag(10) 
                        if cmd.data[tostring(v)].isReward==1 then
                            local RedPt = display.newSprite("common/common_RedPoint.png")
                                :addTo(node1,0,10)
                                :pos(60,30)
                        end
                    elseif k==2 then
                        node1_12:removeChildByTag(10) 
                        if cmd.data[tostring(v)].isReward==1 then
                            local RedPt = display.newSprite("common/common_RedPoint.png")
                                :addTo(node1_12,0,10)
                                :pos(60,30)
                        end
                    elseif k==3 then
                        node1_13:removeChildByTag(10) 
                        if cmd.data[tostring(v)].isReward==1 then
                            local RedPt = display.newSprite("common/common_RedPoint.png")
                                :addTo(node1_13,0,10)
                                :pos(60,30)
                        end
                    end
                    -- local list = cmd.data.idList
                    -- if node1==nil then
                    --     return
                    -- end
                    -- node1:removeChildByTag(10) 
                    -- if cmd.data.isReward==1 then
                    --     local RedPt = display.newSprite("common/common_RedPoint.png")
                    --         :addTo(node1,0,10)
                    --         :pos(60,30)
                    -- end
                end
            else
            end
        end
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_TOTALRECHARGE_INIT, _handler, _handler.func)
    end

    --改到累计充值里面去刷新，避免重复发送请求
    --累计充值红点
    -- local num = TaskMgr:GetCanSubNum(TaskTag.TotalConsume)
    -- local node3 = self.activityBtns[1]
    -- if node3 then
    --     local _handler = {}
    --     function _handler:func(cmd)
    --         local list = cmd.data.idList
    --         node3:removeChildByTag(10) 
    --         if cmd.data.isReward==1 then
    --             local RedPt = display.newSprite("common/common_RedPoint.png")
    --                 :addTo(node3,0,10)
    --                 :pos(60,30)
    --         end
    --     end
    --     local sendData = {}
    --     print("----------------------ddfg22\n\n\n\n\n")
    --     m_socket:SendRequest(json.encode(sendData), CMD_TOTALCONSUME_INIT, _handler, _handler.func)
    -- end

    --限时消费红点
    local node2 = self.activityBtns[4]
    if node2 then
        local _handler = {}
        function _handler:func(cmd)
            for i=1,#cmd.data.itemInfo do
                redPtTag[cmd.data.itemInfo[i].id] = false
                if cmd.data.itemInfo[i].buyTimes==0 then
                    redPtTag[cmd.data.itemInfo[i].id] = true
                    print("------------xxv")
                end
            end
            if node2==nil then
                return
            end
            node2:removeChildByTag(10)
            if getLimitConsumeRedBool() then
                local RedPt = display.newSprite("common/common_RedPoint.png")
                :addTo(node2,0,10)
                :pos(60,30)
            end
        end
        local sendData = {}
        print("----------------------ddfg")
        m_socket:SendRequest(json.encode(sendData), CMD_GETLIMITCOMSUME, _handler, _handler.func)
    end

    --节日礼包红点
    local num = TaskMgr:GetCanSubNum(TaskTag.FreeDiamond)
    local node = self.activityBtns[3]
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end

    --七日大礼
    num = TaskMgr:GetCanSubNum(TaskTag._7DayGift)
    node = self.activityBtns[6]
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end

    --首冲
    num = TaskMgr:GetCanSubNum(TaskTag.Recharge)
    node = self.activityBtns[5]
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end

    --普通冲级礼包红点
    num = TaskMgr:GetCanSubNum(TaskTag.levelGift)
    node = self.activityBtns[7]
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end

    --猎人豪礼红点
    num = TaskMgr:GetCanSubNum(TaskTag.levelGift_2)
    node = self.activityBtns[10]
    if node then
        node:removeChildByTag(10)
        if num>0 then
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(node,0,10)
            :pos(60,30)
        end
    end
end

return discountLayer
