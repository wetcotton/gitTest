local InitLayer=class("InitLayer", function()
    return display.newNode()
    end)

local displayList = {}
-- local cur_idx = 1
local apl_idx
-- applyList = {}
local curItem_Value = nil
local cur_target = nil

local LIST_TAG = 100
local CREATE_TAG = 101


local displayList = {}
function InitLayer:ctor()
    display.newSprite("#legion_img39.png")
    :addTo(borderHead)
    :pos(200,borderHead:getContentSize().height/2-32)

    -- cur_idx = 1
	local inputBar = display.newSprite("#legion_img40.png")
	:addTo(borderHead)
	:pos(555,borderHead:getContentSize().height/2-32)

	self.findInput = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(330, 40)})
    :addTo(inputBar)
    :pos(inputBar:getContentSize().width/2,inputBar:getContentSize().height/2)
    self.findInput:setPlaceHolder("输入关键字查找")
    -- self.findInput:setFontColor(display.COLOR_BLACK)
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
        elseif event == "changed" then
            -- 输入框内容发生变化
            if self.findInput:getText()=="" then
                -- displayList = InitLegionList
                -- cur_idx = 1
                -- self:updateListView()
            end
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
            -- 从输入框返回
        end
    end
    --查找
    local findBt = cc.ui.UIPushButton.new("#legion_img41.png")
    :addTo(borderHead)
    :pos(borderSize.width - 340,borderHead:getContentSize().height/2-32)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if not self.listView:isVisible() then
            self:removeChildByTag(CREATE_TAG)
            self.createLegionBt:setButtonEnabled(true)
            self.listView:setVisible(true)
            return
        end
        self.createLegionBt:setButtonEnabled(true)
        self.listView:setVisible(true)
        startLoading()
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["name"] = self.findInput:getText()
        m_socket:SendRequest(json.encode(sendData), CMD_FIND_LEGION, self, self.onFindLegion)
        end)
    --创建军团
    self.createLegionBt = cc.ui.UIPushButton.new("#legion_img49.png")
    :addTo(borderHead,1)
    :pos(borderSize.width - 190,borderHead:getContentSize().height/2-32)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "创建\n军团", size = 25, color = cc.c3b(23, 56, 29)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:creatLegion()
        end)
    --下一批
    local nextPageBt = cc.ui.UIPushButton.new("#legion_img42.png")
    :addTo(borderHead)
    :pos(borderSize.width - 60,borderHead:getContentSize().height/2-32)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    nextPageBt:onButtonClicked(function(event)
        self.createLegionBt:setButtonEnabled(true)
        self.listView:setVisible(true)
        startLoading()
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["No"] =  InitLegionList.No + 1
        m_socket:SendRequest(json.encode(sendData), CMD_LEGION_ENTER, self, self.onEnterLegionResult)
        end)

    self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(15, 15, 1070, 385),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self,0,LIST_TAG)

    self:updateListView(1)
end
-- function InitLayer:getDisplayList(iType) --1:查找，2：下一页
--     displayList = {}
--     if iType==2 then
--         if #InitLegionList<=10 then
--             displayList = InitLegionList
--         else
--             for i=cur_idx,cur_idx+9 do
--                 if i>#InitLegionList then
--                     cur_idx=1
--                     return
--                 end
--                 displayList[i] = InitLegionList[i]
--             end
--             cur_idx = cur_idx+10
--         end
--     elseif iType==1 then
--         for i,value in pairs(InitLegionList) do
--             if value["name"] == self.findInput:getText() then
--                 displayList[1] = value
--             end
--         end
--     end
-- end
function InitLayer:updateListView(nflag)
    self:removeChildByTag(CREATE_TAG)
	self.listView:removeAllItems()

    local tmpData = {}
    if nflag==1 then
        tmpData = InitLegionList.armyList
        -- printTable(tmpData)
    elseif nflag==2 then
        tmpData[1] = findLegionData
    end

    for i,value in pairs(tmpData) do
        local item = self.listView:newItem()
        local content = display.newNode()
        -- content:setTag(10)

        local itemBar = display.newSprite()
        :addTo(content)
        itemBar:setTag(10)
        itemBar:setAnchorPoint(0.5,0.5)
        local barFrame
        if i%2~=0 then
            barFrame= display.newSpriteFrame("legion_img43.png")
        else
            barFrame= display.newSpriteFrame("legion_img44.png")
        end
        itemBar:setSpriteFrame(barFrame)

        --顺序
        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = i, size = 33, color =cc.c3b(151, 190, 204)})
        :addTo(itemBar)
        :align(display.CENTER, 50, itemBar:getContentSize().height/2)

        --图标
        local typeIcon = display.newSprite()
        :addTo(itemBar)
        :pos(135,itemBar:getContentSize().height/2)
        :scale(0.7)
        if value.geType>=0 then --善
            typeIcon:setTexture("common/common_good.png")
        else
            typeIcon:setTexture("common/common_bad.png")
        end
        local Img = display.newSprite("SingleImg/legion/legionIcon/Legion_"..value.icon..".png")
        :addTo(typeIcon)
        :pos(typeIcon:getContentSize().width/2,typeIcon:getContentSize().height/2)

        --名字
        local name=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, 250+70, 68)
        :addTo(itemBar)
        name:setString(value["name"])
        name:setColor(cc.c3b(151, 190, 204))

        --等级
        local level=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, 140+70, 68)
        :addTo(itemBar)
        level:setString("LV:"..value["level"])
        level:setColor(cc.c3b(255, 221, 70))

        --战斗力
        cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 27, color = cc.c3b(151, 190, 204)})
        :align(display.CENTER_LEFT, 140+70, 25)
        :addTo(itemBar)
        local fightValue=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 27})
        :align(display.CENTER_LEFT, 250+70, 25-2)
        :addTo(itemBar)
        fightValue:setString(value.strength)
        fightValue:setColor(cc.c3b(240, 133, 5))

        --成员
        cc.ui.UILabel.new({UILabelType = 2, text = "成员", size = 27, color = cc.c3b(109, 197, 240)})
        :addTo(itemBar)
        :align(display.CENTER,700,itemBar:getContentSize().height/2+20)

        local lestNum=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :align(display.CENTER,700,itemBar:getContentSize().height/2-20)
        :addTo(itemBar)
        local maxNum = legionLevelData[value.level].maxMemNum
        if value.nowMemNum>= maxNum then
            lestNum:setString(value.nowMemNum.."/"..maxNum.."(已满)")
            lestNum:setColor(cc.c3b(230, 0, 18))
        else
            lestNum:setString(value.nowMemNum.."/"..maxNum)
            lestNum:setColor(cc.c3b(109, 197, 240))
        end
        self:performWithDelay(function ()
        local applyBt = cc.ui.UIPushButton.new("common/common_nBtG.png")
        :addTo(itemBar)
        :pos(itemBar:getContentSize().width - 100,itemBar:getContentSize().height/2)
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "申请加入", size = 27, color = cc.c3b(7, 74, 6)}))
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            if value.isApl==1 then
                showTips("不可重复申请。")
                return 
            end
            apl_idx = i
            startLoading()
            local sendData = {}
            sendData["armyId"] =  value.id
            m_socket:SendRequest(json.encode(sendData), CMD_APPLY_LEGION, self, self.onAPPLYLegionResult)
            curItem_Value = value
            cur_target = event.target
            end)
        if value.isApl==1 then
            applyBt:getButtonLabel():setString("已申请")
        end
        setLabelStroke(applyBt:getButtonLabel(),27,cc.c3b(178, 252, 161),1,nil,nil,nil,nil, true)
        end,0.01)
        
        item:addContent(content)
        item:setItemSize(950,108)
        item:setTag(value.id)
        self.listView:addItem(item)
    end
    self.listView:reload()
end
function InitLayer:creatLegion()
    local masklayer =  UIMasklayer.new()
    :addTo(borderNode:getParent(),2)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    self.createMaskLayer = masklayer

    local createLegionBox = display.newSprite("SingleImg/messageBox/messageBox.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    masklayer:addHinder(createLegionBox)
    local tmpsize = createLegionBox:getContentSize()

    --标题
    cc.ui.UILabel.new({UILabelType = 2, text = "创建军团", size = 35, color = cc.c3b(255, 192, 67)})
    :addTo(createLegionBox)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height - 40)

    --军团名称
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "军团名称：", size = 27, color = cc.c3b(151, 190, 204)})
    :addTo(createLegionBox)
    :pos(100, tmpsize.height - 110)

    local inputBar = display.newScale9Sprite("#legion_img8.png", nil, nil, cc.size(210, 40))
    :addTo(createLegionBox)
    :align(display.CENTER_LEFT, label:getPositionX()+label:getContentSize().width, label:getPositionY())
    self.nameInput = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(200, 40)})
    :addTo(inputBar)
    :pos(inputBar:getContentSize().width/2,inputBar:getContentSize().height/2)
    self.nameInput:setFontColor(cc.c3b(31, 35, 43))
    self.nameInput:setPlaceHolder("输入军团名称")

    --善恶选择
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "军团阵营：", size = 27, color = cc.c3b(151, 190, 204)})
    :addTo(createLegionBox)
    :pos(100, tmpsize.height - 170)

    -- local goodBg = display.newSprite("#legion_img12.png")
    -- :addTo(createLegionBox)
    -- :pos(300, tmpsize.height - 210)
    -- goodBg:setVisible(true)

    -- local badBg = display.newSprite("#legion_img13.png")
    -- :addTo(createLegionBox)
    -- :pos(470, tmpsize.height - 210)
    -- badBg:setVisible(false)

    -- self.geType = 1
    if srv_userInfo["goodEvil"]>=0 then
        self.goodIcon = cc.ui.UIPushButton.new("#legion_img50.png")
        :addTo(createLegionBox)
        :pos(300, tmpsize.height - 210)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            end)
    else
        self.badIcon = cc.ui.UIPushButton.new("#legion_img51.png")
            :addTo(createLegionBox)
            :pos(300, tmpsize.height - 210)
            :onButtonPressed(function(event) event.target:setScale(0.95) end)
            :onButtonRelease(function(event) event.target:setScale(1.0) end)
            :onButtonClicked(function(event)
                end)
    end
    

    --军团图标
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "军团图标：", size = 27, color = cc.c3b(151, 190, 204)})
    :addTo(createLegionBox)
    :pos(100, tmpsize.height - 280)
    self.legionIcon = cc.ui.UIPushButton.new("SingleImg/legion/legionIcon/Legion_10001.png")
    :addTo(createLegionBox,0,10001)
    :align(display.CENTER,280,tmpsize.height - 310)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        legionIconLayer.new(borderNode:getParent(),1)
        end)

   
    --创建花费
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "创建花费", size = 27, color = cc.c3b(109, 197, 240)})
    :addTo(createLegionBox)
    :pos(tmpsize.width/2-135, 80)
    display.newSprite("common/common_Diamond.png")
    :addTo(createLegionBox)
    :pos(tmpsize.width/2+10, 80)
    self.diamondNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "500", size = 27, color = cc.c3b(109, 197, 240)})
    :addTo(createLegionBox)
    :pos(tmpsize.width/2+40, 80)
    --创建按钮
    local createBt = cc.ui.UIPushButton.new("common/common_nBtG.png")
    :addTo(createLegionBox)
    :pos(tmpsize.width/2, 5)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确认创建", size = 27, color = cc.c3b(7, 74, 6)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        local chaCnt = getCharactersCnt(self.nameInput:getText())
        if chaCnt>10 then
            showTips("军团名字不能超过10个字")
            return 
        end

        startLoading()
        local sendData = {}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["serverId"] =  loginServerList.serverId
        sendData["name"] =  self.nameInput:getText()
        sendData["manifesto"] =  ""
        sendData["icon"] =  self.legionIcon:getTag()
        -- sendData["geType"] =  self.geType
        m_socket:SendRequest(json.encode(sendData), CMD_CREATE_LEGION, self, self.onCreateLegionResult)
        end)
    setLabelStroke(createBt:getButtonLabel(),27,cc.c3b(178, 252, 161),1,nil,nil,nil,nil, true)
end
function InitLayer:selIconCallBack(path,iconId)
    self.legionIcon:setButtonImage("normal", path)
    self.legionIcon:setButtonImage("pressed", path)
    self.legionIcon:setTag(iconId)
end
function InitLayer:reloadLegionData()
    srv_userInfo["armyName"] = self.nameInput:getText() --系统设置更新
    mLegionData.army={}
    mLegionData.mem={}
    mLegionData.mem[1]={}
    mLegionData.army.active=0
    mLegionData.army.manifesto=""
    mLegionData.army.name=self.nameInput:getText()
    mLegionData.army.level=1
    mLegionData.army.memNum=1
    mLegionData.army.contri=0
    mLegionData.army.minMemLevel = 1
    mLegionData.army.autoJoin = 0
    mLegionData.army.aplInfo={}
    mLegionData.army.strength = srv_userInfo.strength
    mLegionData.army.icon = self.legionIcon:getTag()
    mLegionData.mem[1].strength = srv_userInfo.strength
    mLegionData.mem[1].name = srv_userInfo.name
    mLegionData.mem[1].level = srv_userInfo.level
    mLegionData.mem[1].active = 0
    mLegionData.mem[1].contri = -1
    local function getLocalDate()
        local mDate = os.date()
        local day = string.sub(mDate,1,2)
        local month = string.sub(mDate,4,5)
        local year = string.sub(mDate,7,8)
        local mTime = string.sub(mDate,9)
        mDate = "20"..year.."-"..month.."-"..day..mTime
        return mDate
    end
    mLegionData.mem[1].lastOnTime = getLocalDate()
    mLegionData.mem[1].chaId = srv_userInfo.characterId
    mLegionData.mem[1].rank = 2
    mLegionData.mem[1].icon = srv_userInfo["templateId"] --玩家头像
end

--申请加入军团
function InitLayer:onAPPLYLegionResult(result)
    endLoading()
    if result["result"]==1 then
        borderHead:removeAllChildren()
        self:removeAllChildren()
        g_myLegionLayer = myLegionLayer.new(borderNode)
        :addTo(borderNode,0,MYLEGION_TAG)
        --同步系统设置界面的军团信息
        if display.getRunningScene().legion~=nil then
            display.getRunningScene().legion:setVisible(true)
            display.getRunningScene().exitLegionBt:setVisible(true)
            display.getRunningScene().legionName:setString(srv_userInfo["armyName"])
        end
        
    elseif result["result"]==2 then
        print("待审核")
        InitLegionList.armyList[apl_idx].isApl=1
        self:updateListView(1)
    else
        showTips(result.msg)
    end
end
--创建军团花销
function InitLayer:onLegionCostResult(result)
    endLoading()
    if result["result"]==1 then
        self:creatLegion()
        self.diamondNum:setString(result.data)
    else
        showTips(result.msg)
    end
end
--创建军团
function InitLayer:onCreateLegionResult(result)
    endLoading()
    if result["result"]==1 then
        showTips("军团创建成功")
        self:reloadLegionData()
        borderHead:removeAllChildren()
        self:removeAllChildren()
        self.createMaskLayer:removeSelf()
        g_myLegionLayer = myLegionLayer.new(borderNode)
        :addTo(borderNode,0,MYLEGION_TAG)

        --同步系统设置界面的军团信息
        if display.getRunningScene().legion~=nil then
            display.getRunningScene().legion:setVisible(true)
            display.getRunningScene().exitLegionBt:setVisible(true)
            display.getRunningScene().legionName:setString(srv_userInfo["armyName"])
        end
    else
        --如果创建失败，清空数据
        srv_userInfo["armyName"] = ""
        mLegionData.army={}
        mLegionData.mem={}
        showTips(result.msg)
    end
end
--军团查找
function InitLayer:onFindLegion(result)
    endLoading()
    if result.result==1 then
        self:updateListView(2)
    else
        showTips(result.msg)
    end
end
--下一批
function InitLayer:onEnterLegionResult(result)
    if result["result"]==1 then
        if #InitLegionList.armyList==0 then
            showTips("没有更多军团")
        else
            self:updateListView(1)
        end
    else
        showTips(result.msg)
    end
end

return InitLayer