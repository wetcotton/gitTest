-- @Author: anchen
-- @Date:   2016-05-20 11:12:02
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-05-23 19:03:04
newfund = class("newfund",function()
    local layer =  display.newNode()
    -- local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

newfund.instance = nil
function newfund:ctor(fundId)
    newfund.instance = self
    self.fundId = fundId
    local rewardBox = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,cc.size(900,621))
    :addTo(self)
    :pos(display.cx, display.cy-20)
    self.rewardBox = rewardBox
    local tmpsize = rewardBox:getContentSize()

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(self.rewardBox)
    :pos(tmpsize.width/2,tmpsize.height-150)

    display.newSprite("youhui/youhuiImg_21.png")
    :addTo(rewardBox)
    :pos(tmpsize.width/2-100,tmpsize.height-80)

    display.newSprite("youhui/youhuiImg_22.png")
    :addTo(rewardBox)
    :pos(tmpsize.width/2-20,tmpsize.height-170)

    local allDia = 0
    local arr = string.split(newbieFundData[self.fundId].rewards, "|")
    for i=1,#arr do
        local arr2 = string.split(arr[i], "#")
        allDia = allDia + tonumber(arr2[2])
    end
    local size = 30
    
    if newbieFundData[self.fundId].costDia>=10000 then
        size = 22
    elseif newbieFundData[self.fundId].costDia>=1000 then
        size = 27
    end
    print("size:"..size)

    local lable1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = newbieFundData[self.fundId].costDia, size = size,color = cc.c3b(234, 85, 20)})
    :addTo(rewardBox,2)
    :align(display.CENTER,135,tmpsize.height-63)
    setLabelStroke(lable1, size, cc.c3b(23, 28, 97), nil,nil,nil,nil,"fonts/slicker.ttf", newbieFundData[self.fundId].costDia)

    local lable2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = allDia, size = 30,color = cc.c3b(234, 85, 20)})
    :addTo(rewardBox,2)
    :align(display.CENTER,tmpsize.width/2-112,tmpsize.height-100)
    setLabelStroke(lable2, 30, cc.c3b(23, 28, 97), nil,nil,nil,nil,"fonts/slicker.ttf", allDia)

    local lable3 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = newbieFundData[self.fundId].vip, size = 30,color = cc.c3b(234, 152, 0)})
    :addTo(rewardBox,2)
    :align(display.CENTER,tmpsize.width/2-100,tmpsize.height-173)
    setLabelStroke(lable3, 30, cc.c3b(64, 34, 15), nil,nil,nil,nil,"fonts/slicker.ttf", newbieFundData[self.fundId].vip)

    --购买按钮
    if srv_userInfo.newbieFundSts[tostring(self.fundId)]==0 then
        -- self:performWithDelay(function ()
            
        self.buyBt = cc.ui.UIPushButton.new("youhui/youhuiBnt_01.png")
        :addTo(rewardBox)
        :pos(tmpsize.width/2 + 200, tmpsize.height-160)
        :scale(0.8)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "购 买", size = 33}))
        :onButtonPressed(function(event) event.target:setScale(0.95*0.8) end)
        :onButtonRelease(function(event) event.target:setScale(1.0*0.8) end)
        :onButtonClicked(function(event)
            if srv_userInfo.diamond<newbieFundData[self.fundId].costDia then
                showTips("钻石不足")
                return
            elseif srv_userInfo.vip<newbieFundData[self.fundId].vip then
                showTips("vip"..newbieFundData[self.fundId].vip.."及以上可购买。")
                return
            end

            showMessageBox("确定花"..newbieFundData[self.fundId].costDia.."钻石购买"..newbieFundData[self.fundId].name.."?", 
                function()
                    startLoading()
                    local sendData = {}
                    sendData["fundId"] = self.fundId
                    m_socket:SendRequest(json.encode(sendData), CMD_NEWFUND, self, self.onBuyFunRet)
                    end)
            
            end)
        -- end, 0.1)
    end
    
    local rechargeBt = cc.ui.UIPushButton.new("youhui/youhuiBnt_01.png")
    :addTo(rewardBox)
    :pos(tmpsize.width/2 + 360, tmpsize.height-160)
    :scale(0.8)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "充 值", size = 33}))
    :onButtonPressed(function(event) event.target:setScale(0.95*0.8) end)
    :onButtonRelease(function(event) event.target:setScale(1.0*0.8) end)
    :onButtonClicked(function(event)
        g_recharge.new()
        :addTo(display.getRunningScene())
        end)

    self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(35, 30, 840, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }
        :addTo(rewardBox)
        -- :setBounceable(false)
    printTable(srv_userInfo.newbieFundSts)
    self.locData = self:getLocalTask()

    self:reloadListView()

end
function newfund:onExit()
    newfund.instance = nil
end

function newfund:reloadListView()
    print("刷新列表")
    self.listview:removeAllItems()
    local locData = self.locData
    local srvLevelGiftList = self:getSrvFundTask()

    local curFundData = newbieFundData[self.fundId]
    local levelTable = string.split(curFundData.rewards, "|")
    for i=1,#levelTable do  --遍历成就表中所有的等级成就
        local data = string.split(levelTable[i], "#")

        local content = display.newSprite("firstRecharge/rewardBar.png")
        local _size = content:getContentSize()
        -- local dayImg = display.newSprite("youhui/youhuiImg_09.png")
        -- :addTo(content)
        -- :pos(80, _size.height/2)

        display.newTTFLabel{text = data[1],size = 30,font = "fonts/slicker.ttf"}
            :addTo(content)
            :pos(43,_size.height/2-5)
        display.newTTFLabel{text = "级"..curFundData.name,size = 29,color = cc.c3b(99,45,15)}
            :addTo(content)
            :pos(140,_size.height/2-5)

        display.newTTFLabel{text = data[1],size = 30,font = "fonts/slicker.ttf"}
            :addTo(content)
            :pos(340,_size.height/2-5)
        display.newTTFLabel{text = "达到    级可领取",size = 29,color = cc.c3b(99,45,15)}
            :addTo(content)
            :pos(370,_size.height/2-5)
        display.newTTFLabel{text = data[2],size = 30,font = "fonts/slicker.ttf"}
            :addTo(content)
            :pos(520,_size.height/2-5)

        display.newSprite("common/common_Diamond.png")
        :addTo(content)
        :pos(590,_size.height/2-5)


        

        --签到按钮
        local srv_taskData = srvLevelGiftList[locData[i].id]
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
            self.curItem = event.target
            self.diamond = data[2]
            startLoading()
            TaskMgr:ReqSubmit(srv_taskData.id)
            end)
        if srv_userInfo.newbieFundSts[tostring(self.fundId)]==0 then  --没有购买，不可领取状态
            receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
            receiveBt:setTouchEnabled(false)
        elseif srv_taskData then
            --有任务记录
            -- print("有任务，",task_data.id,srv_taskData.status)
            if srv_taskData.status==0 then --未完成
                print("aaaaaaaaa")
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
                receiveBt:setTouchEnabled(false)
            elseif srv_taskData.status==1 then --已完成
                print("bbbbbbbbbbb")
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt1.png")
                receiveBt:setTouchEnabled(true)
            elseif srv_taskData.status==2 then --已领取
                print("ccccccccccc")
                receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
                receiveBt:setTouchEnabled(false)
            end
        else
            --没有任务记录
            -- print("没任务，",minTaskTmpId,task_data.id)
            -- if minTaskTmpId==0 or (locData[i].id)<minTaskTmpId then --已领取
            --     receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
            --     receiveBt:setTouchEnabled(false)
            -- else  --未完成
            --     receiveBt:setButtonImage("normal", "firstRecharge/receiveBt2.png")
            --     receiveBt:setTouchEnabled(false)
            -- end
            --全部完成，已领取状态
            receiveBt:setButtonImage("normal", "firstRecharge/receiveBt3.png")
            receiveBt:setTouchEnabled(false)
        end

        local item = self.listview:newItem()
        item:addContent(content)
        item:setItemSize(840, 130)
        self.listview:addItem(item)
    end
    self.listview:reload()
end
--获取本地任务表中的部分
function newfund:getLocalTask()
    local tmpData = {}
    for i,value in pairs(taskData) do
        if value.params2==self.fundId and value.tgtType==49 then
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
--获取服务端任务数据中的基金部分
function newfund:getSrvFundTask()
    local tmpData = {}
    local minTaskTmpId = 0

    for i,value in pairs(TaskMgr.idKeyInfo) do
        if taskData[value.tptId].params2==self.fundId and taskData[value.tptId].tgtType==49 then
            tmpData[value.tptId] = value
            if minTaskTmpId==0 or value.tptId<minTaskTmpId then
                minTaskTmpId = value.tptId
            end
        end
    end

    return tmpData
end

function newfund:onBuyFunRet(ret)
    if ret.result ==1 then
        showTips("购买成功。")

        --购买成功后去掉购买按钮
        if self.buyBt then
            self.buyBt:removeSelf()
        end
        --修改登陆下发的基金购买状态
        srv_userInfo.newbieFundSts[tostring(self.fundId)]=1
        --修改奖励列表领取状态
        self:reloadListView()

        srv_userInfo.diamond = ret.data.diamond
        mainscenetopbar:setDiamond()

    else
        showTips(ret.msg)
    end
end

function newfund:OnSubmitRet(ret)
    if ret.result==1 then
        -- self:reloadListView()
        local parent = self.curItem:getParent()
        self.curItem:removeSelf()
        display.newSprite("firstRecharge/receiveBt3.png")
            :addTo(parent)
            :pos(parent:getContentSize().width-120,parent:getContentSize().height/2)

        --奖励弹框
        local curRewards = {}
        table.insert(curRewards, {templateID=2, num=self.diamond})
        GlobalShowGainBox(nil, curRewards)

        srv_userInfo.diamond = ret.data.diamond
        mainscenetopbar:setDiamond()

        if fundLayer.instance then --基金界面的按钮红点
            fundLayer.instance:btRedPoint()
        end
    else
        -- showTips(ret.msg)
    end
end

return newfund