-- @Author: anchen
-- @Date:   2015-12-24 16:08:23
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-05 17:47:56
local improveCarLayer = class("improveCarLayer",function()
    local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    layer:setNodeEventEnabled(true)
    return layer
end)

--材料强化消耗
local strengthCost = {
    {10000,1},
    {50000,2},
    {150000,5},
    {300000,10},
}

function improveCarLayer:ctor()
    local colorBg = display.newSprite("common/colorbg.png")
    :addTo(self,-1)
    colorBg:setAnchorPoint(0,0)
    colorBg:setScaleX(display.width/colorBg:getContentSize().width)
    colorBg:setScaleY(display.height/colorBg:getContentSize().height)     
    --返回按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :align(display.LEFT_TOP, 0, display.height )
    :addTo(self)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

    local topPanel = display.newSprite("#improve2_img15.png")
    :addTo(self,2)
    :pos(display.cx+20, display.cy+100)
    local tmpsize = topPanel:getContentSize()
    self.topPanel = topPanel

    local bottomPanel = display.newSprite("#improve2_img34.png")
    :addTo(self,2)
    :pos(display.cx+20, display.cy-250)

    display.newSprite("#improve2_img35.png")
    :addTo(self)
    :pos(display.cx-480, display.cy-130)
    display.newSprite("#improve2_img35.png")
    :addTo(self)
    :pos(display.cx+520, display.cy-130)

    local img = display.newSprite("#improve2_img29.png")
    :addTo(topPanel)
    :pos(270, tmpsize.height/2)
    -- img:setRotation(45)
    self.circleImg = img
    

    display.newSprite("#improve2_img19.png")
    :addTo(img)
    :pos(img:getContentSize().width/2, img:getContentSize().height/2)

    --左侧
    --战车
    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=curCarData.TemId})
                        :pos(img:getPositionX(), img:getPositionY()-80)
                        :addTo(topPanel)
                        carModel:setScaleY(0.6*2*0.75)
                        carModel:setScaleX(-0.6*2*0.75)

    --改装材料
    local imgposx = img:getPositionX()
    local imgposy = img:getPositionY()
    local meterialInfo = {
        {pos=cc.p(imgposx-140, imgposy)},
        {pos=cc.p(imgposx, imgposy+140)},
        {pos=cc.p(imgposx+140, imgposy)},
        {pos=cc.p(imgposx, imgposy-140)},
    }
    self.meterialNode = {}
    for i=1,#meterialInfo do
        self.meterialNode[i] = cc.ui.UIPushButton.new("#improve2_img28.png")
        :addTo(topPanel)
        :pos(meterialInfo[i].pos.x, meterialInfo[i].pos.y)
    end
    self.meterialInfo = meterialInfo

    --箭头
    display.newSprite("#improve2_img17.png")
    :addTo(topPanel)
    :pos(tmpsize.width/2, tmpsize.height/2)

    --右侧
    local transform = transformData[curCarData.TemId]
    local toTmpId = transform.toId

    --需要等级
    local bar = display.newSprite("#improve2_img18.png")
    :addTo(topPanel)
    :pos(tmpsize.width/2+150, tmpsize.height-40)

    local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "等级需达到", size = 22})
    :addTo(topPanel)
    :pos(tmpsize.width/2+60, bar:getPositionY())

    local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "LV "..transform.level, size = 22})
    :addTo(topPanel)
    :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())

    if srv_userInfo.level>=transform.level then
        label1:setColor(cc.c3b(72, 184, 210))
        label2:setColor(cc.c3b(72, 184, 210))
    else
        label1:setColor(cc.c3b(230, 0, 18))
        label2:setColor(cc.c3b(230, 0, 18))
    end

    --改装后面板
    local rightPanel = display.newSprite("#improve2_img16.png")
    :addTo(topPanel)
    :pos(tmpsize.width/2+270, tmpsize.height/2)
    self.rightPanel = rightPanel

    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=toTmpId})
                        :pos(130, rightPanel:getContentSize().height/2-90)
                        :addTo(rightPanel)
                        carModel:setScaleY(0.6*2*0.75)
                        carModel:setScaleX(-0.6*2*0.75)

    local rLabel = cc.ui.UILabel.new({UILabelType = 2, text = "改装后预览", size = 30, color = cc.c3b(55, 234, 255)})
    :align(display.CENTER, 130, rightPanel:getContentSize().height/2+90)
    :addTo(rightPanel)


    self.wenhao = display.newSprite("bounty/bounty2_img3.png")
    :addTo(rightPanel)
    :pos(350, rightPanel:getContentSize().height/2)

    local helpBt = cc.ui.UIPushButton.new("#MainUI_img29.png")
    :addTo(self,10)
    :pos(display.width-110, display.height-26)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:createHelpBox()
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "规则", size = 20, color = cc.c3b(129, 157, 163)})
    :addTo(helpBt)
    :align(display.CENTER, helpBt:getContentSize().width/2, -5)

    self.btNode1 = display.newNode()
    :addTo(topPanel)
    --锁定材料
    self.lockBt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(self.btNode1)
    :pos(tmpsize.width/2-120,10)
    -- :pos(tmpsize.width/2,10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "锁定材料", size = 30, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        if toTmpId==curCarData.TemId then
            showTips("已改装至最高阶，不需要再锁定材料")
            return 
        end
        if #self.MeterialIds<4 then
            showTips("请置入四个材料再进行锁定")
            return
        end
        local impStuff = ""
        printTable(self.MeterialIds)
        for i=1,#self.MeterialIds do
            if i<4 then
                impStuff = impStuff..self.MeterialIds[i].."|"
            else
                impStuff = impStuff..self.MeterialIds[i]
            end 
        end
        startLoading()
        local sendData = {}
        sendData.carId = curCarData.id
        sendData.impStuff = impStuff
        m_socket:SendRequest(json.encode(sendData), CMD_CAR_METERAIL_LOCK, self, self.onMeterailLock)

        end)


    --改装重置按钮
    local reset = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(self.btNode1)
    :pos(tmpsize.width/2+180,10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "改装重置", size = 30, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        self:resetTip()
        end)

    if toTmpId==curCarData.TemId then
        self.lockBt:setVisible(false)
        reset:setPositionX(tmpsize.width/2)
        rLabel:setString("已改装至最高阶")
        label2:setString("")
    end


    self.btNode2 = display.newNode()
    :addTo(topPanel)
    self.btNode2:setVisible(false)
    --确认改装
    self.confirmBt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_6_up.png",
        pressed = "common2/com2_Btn_6_down.png"
        })
    :addTo(self.btNode2)
    :pos(tmpsize.width/2-240,10)
    -- :pos(tmpsize.width/2-120,10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确认改装", size = 30, color = cc.c3b(94, 229, 101)}))
    :onButtonClicked(function(event)
        local locData = transformData[curCarData.TemId]
        if srv_userInfo.level<locData.level then
            showTips("无法改装，请先提升战队等级")
        else
            CarManager:ReqImprove(curCarData.id)
        end
        end)
    -- self.confirmBt:setVisible(false)

    local strengthBt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(self.btNode2)
    :pos(tmpsize.width/2,10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "材料强化", size = 30, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        self:strengthBox()
        end)


    --取消锁定
    self.cancelBt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(self.btNode2)
    :pos(tmpsize.width/2+240,10)
    -- :pos(tmpsize.width/2+180,10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "取消锁定", size = 30, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        if self.isLock then
            self:cancelLockPanel()
        else
            showTips("当前没有锁定的材料")
        end
        
        end)
    -- self.cancelBt:setVisible(false)



    --所有同星级改装材料
    self:reloadAllItemsData()
    
    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(10, 0, 1060, 190),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(bottomPanel)
        self.lv:setBounceable(false)
    self:reloadListview()


    --用于改造的材料
    self.MeterialIds = {}

    self:initMeterial()
end
function improveCarLayer:reloadAllItemsData()
    self.star = tonumber(string.sub(curCarData.TemId, 4, 5))+2
    if self.star>=5 then self.star=5 end
    self.allCurStarItems = {}
    for i,value in pairs(itemData) do
        if value["type"]==306 and getItemStar(value.id)==self.star then
            value.idx = {} --存放每个改造材料用在哪些材料位上
            table.insert(self.allCurStarItems, value)
        end
    end
    function sortfunc(a,b)
        return a.id<b.id
    end
    table.sort(self.allCurStarItems,sortfunc)
end
--初始化已锁定材料
function improveCarLayer:initMeterial()
    print("---------")
    printTable(curCarData)
    --如果材料已经锁定
    local stuffArr = lua_string_split(curCarData.impStuff,"|")
    if #stuffArr==4 then
        self.isLock = true
        for i=1,#stuffArr do
            local data = lua_string_split(stuffArr[i],";")
            table.insert(self.MeterialIds, tonumber(data[1]))

            local parentnode = self.meterialNode[i]
            --图标
            local icon = createItemIcon(data[1])
            :addTo(parentnode,0,10)
            :pos(0, 7)
            :scale(0.7)

            --锁
            display.newSprite("item/item_10000.png")
            :addTo(parentnode,1,11)
            :pos(0, 7)
            :scale(0.7)

            --星级
            for i=1,5 do
                display.newSprite("#improve2_img14.png")
                :addTo(icon)
                :pos(-44+(i-1)*22, -70)
                :scale(0.8)

                local img = display.newSprite("#improve2_img13.png")
                :addTo(icon)
                :pos(-44+(i-1)*22, -70)
                :scale(0.8)

                local star = getItemStar(data[1])
                if star<i then
                    img:setVisible(false)
                end
            end
        end
        self.btNode1:setVisible(false)
        self.btNode2:setVisible(true)
        -- self.confirmBt:setVisible(true)

        local tmpData
        self:createDataProgress(curCarData.impStuff)
    end

    if self.isLock then
        self.wenhao:setVisible(false)
        self.circleImg:setRotation(45)
        -- self.cancelBt:setVisible(true)
        for i=1,#self.meterialNode do
            if i==1 then
                self.meterialNode[i]:pos(self.meterialInfo[i].pos.x+40, self.meterialInfo[i].pos.y)
            elseif i==2 then
                self.meterialNode[i]:pos(self.meterialInfo[i].pos.x, self.meterialInfo[i].pos.y-40)
            elseif i==3 then
                self.meterialNode[i]:pos(self.meterialInfo[i].pos.x-40, self.meterialInfo[i].pos.y)
            elseif i==4 then
                self.meterialNode[i]:pos(self.meterialInfo[i].pos.x, self.meterialInfo[i].pos.y+40)
            end
        end
    end

    
end
function improveCarLayer:reloadListview()
    self.lv:removeAllItems()

    for i,value in ipairs(self.allCurStarItems) do
        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.lv:addItem(item)

        --判断是否拥有该材料
        local srv_value,cnt = get_SrvBackPack_Value(value.id)

        --图标
        if srv_value==nil then
            local icon = createItemIcon(value.id,nil,true)
            :addTo(content)
            :onButtonClicked(function(event)
                g_combinationLayer.new(value.id,handler(self,self.reloadListview),103)
                    :addTo(MainScene_Instance,50)
                end)
            display.newSprite("common2/com2_img_27.png")
            :addTo(icon)
            :scale(0.9)

            local bcanCom = isStuffCanCombination(value.id)
            if bcanCom then
                local RedPt = display.newSprite("common/common_RedPoint.png")
                :addTo(icon,10,10)
                :pos(45,45)
            end
        else
            local icon = createItemIcon(value.id,nil,true)
            :addTo(content,0,10)
            :onButtonClicked(function(event)
                --添加材料
                self.curIdx = 0
                for i=1,#self.meterialNode do
                    if self.meterialNode[i]:getChildByTag(10)==nil then
                        self.curIdx = i
                        break
                    end
                end
                local lestcnt = cnt-(#self.allCurStarItems[i].idx)
                if lestcnt<=0 then
                    showTips("材料不足")
                    return
                elseif self.curIdx == 0 then
                    showTips("已填满")
                    return
                end
                table.insert(self.allCurStarItems[i].idx, self.curIdx)
                local parentnode = self.meterialNode[self.curIdx]
                local icon2 = createItemIcon(value.id)
                :addTo(parentnode,0,10)
                :pos(0, 7)
                :scale(0.7)

                --星级
                for i=1,5 do
                    display.newSprite("#improve2_img14.png")
                    :addTo(icon2)
                    :pos(-44+(i-1)*22, -70)
                    :scale(0.8)

                    local img = display.newSprite("#improve2_img13.png")
                    :addTo(icon2)
                    :pos(-44+(i-1)*22, -70)
                    :scale(0.8)

                    local star = getItemStar(value.id)
                    if star<i then
                        img:setVisible(false)
                    end
                end

                
                event.target:getChildByTag(10):setString(lestcnt-1)
                event.target:getChildByTag(11):setVisible(true)

                table.insert(self.MeterialIds, value.id)
                --特效
                carImproEff2(event.target)
                self:performWithDelay(function ()
                        carImproEff3(parentnode)
                end, 0.4)
                

                end)

            local labNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20})
            :addTo(icon,1,10)
            :pos(45, -47)
            labNum:setAnchorPoint(1,0)
            labNum:setString(cnt)

            local jianBt = cc.ui.UIPushButton.new("#improve2_img36.png")
            :addTo(icon,1,11)
            :pos(32,32)
            :onButtonClicked(function(event)
                --移除材料
                local parentnode = self.meterialNode[self.allCurStarItems[i].idx[#self.allCurStarItems[i].idx]]
                parentnode:removeChildByTag(10)

                table.remove(self.allCurStarItems[i].idx)
                table.remove(self.MeterialIds)
                local lestcnt = cnt-(#self.allCurStarItems[i].idx)
                icon:getChildByTag(10):setString(lestcnt)

                if lestcnt==cnt then
                    event.target:setVisible(false)
                end
                end)
            jianBt:setVisible(false)
        end

        --名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = value.name, size = 23, color = display.COLOR_BLACK})
        :addTo(content)
        :align(display.CENTER, 0, 75)

        --星级
        for i=1, 5 do
            display.newSprite("#improve2_img14.png")
            :align(display.CENTER, -50+(i-1)*26, -72)
            :addTo(content)
            :scale(0.75)

            local star = display.newSprite("#improve2_img13.png")
            :align(display.CENTER, -50+(i-1)*26, -72)
            :addTo(content)
            :scale(0.75)
            if i>self.star then
                star:setVisible(false)
            end
        end
    end 

    self.lv:reload()
end

function improveCarLayer:cancelLockPanel()
    local masklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    :addTo(self,50)
    self.unLockMaskLayer = masklayer

    local panel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(700,460),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    local tmpsize = panel:getContentSize()

    --关闭按钮
    createCloseBt()
    :addTo(panel)
    :pos(tmpsize.width+30, tmpsize.height-50)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)

    local title = cc.ui.UILabel.new({UILabelType = 2, text = "提示", size = 28, color = cc.c3b(255, 241, 0)})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-50)

    local content = cc.ui.UILabel.new({UILabelType = 2, text = "请选择以下两种方式取消锁定，取消后可重新选择材料与生成属性，取消锁定后当前材料强化记录清空", size = 28})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height/2+30)
    content:setWidth(550)

    --消耗钻石取消
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2-150, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "消耗100   ", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        startLoading()
        local sendData = {}
        sendData.carId = curCarData.id
        sendData.type = 1
        m_socket:SendRequest(json.encode(sendData), CMD_CAR_METERAIL_UNLOCK, self, self.onMeterailUnLock)
        end)
    display.newSprite("common/common_Diamond.png")
    :addTo(bt)
    :pos(55,0)
    :scale(0.7)

    --消耗材料取消
    cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2+150, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "消耗1个材料", size = 26, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        startLoading()
        local sendData = {}
        sendData.carId = curCarData.id
        sendData.type = 2
        m_socket:SendRequest(json.encode(sendData), CMD_CAR_METERAIL_UNLOCK, self, self.onMeterailUnLock)
        end)
end
function improveCarLayer:resetTip()
    local masklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    :addTo(self,50)
    self.resetMaskLayer = masklayer

    local panel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(700,460),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    local tmpsize = panel:getContentSize()

    --关闭按钮
    createCloseBt()
    :addTo(panel)
    :pos(tmpsize.width+30, tmpsize.height-50)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)

    local title = cc.ui.UILabel.new({UILabelType = 2, text = "提示", size = 28, color = cc.c3b(255, 241, 0)})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-50)

    local content = cc.ui.UILabel.new({UILabelType = 2, text = "重置之后战车还原至初始形态，每一阶随机返回一个改装材料，是否进行改装重置？", size = 28})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height/2+80)
    content:setWidth(550)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "重置消耗：", size = 28})
    :addTo(panel)
    :align(display.CENTER_LEFT, 80, tmpsize.height/2-10)

    local icon = createItemIcon(RESET_TMPID,nil,true)
    :addTo(panel)
    :pos(label:getPositionX() + 200, label:getPositionY())
    :scale(0.8)
    :onButtonClicked(function(event)
        g_combinationLayer.new(RESET_TMPID,nil)
        :addTo(MainScene_Instance,50)
        end)

    local numBar = display.newScale9Sprite("common/common_Frame7.png",nil, 
        nil,
        cc.size(80, 23),cc.rect(10, 10, 30, 30))
    :addTo(icon)
    :pos(0, -42)
    local num = getComNumPer(RESET_TMPID,1)
    :addTo(numBar)
    :pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)

    --消耗钻石取消
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2-150, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确 定", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        
        startLoading()
        local sendData = {}
        sendData.carId = curCarData.id
        m_socket:SendRequest(json.encode(sendData), CMD_CAR_RESET, self, self.onCarResetResult)
        end)

    --消耗材料取消
    cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2+150, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "取 消", size = 26, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)
end
--重置返回物品
function improveCarLayer:resetBackItem(items)
    local masklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    :addTo(self,50)

    local panel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(700,460),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    local tmpsize = panel:getContentSize()

    --关闭按钮
    createCloseBt()
    :addTo(panel)
    :pos(tmpsize.width+30, tmpsize.height-50)
    :onButtonClicked(function(event)
        self:removeSelf()
        ImproveLayer_Instance:RefreshUI()
        end)

    local title = cc.ui.UILabel.new({UILabelType = 2, text = "重置返回", size = 28, color = cc.c3b(255, 241, 0)})
    :addTo(panel)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-50)

    local content = cc.ui.UILabel.new({UILabelType = 2, text = "战车已重置到初始形态，返还材料如下：", size = 28})
    :addTo(panel)
    :align(display.CENTER_LEFT, 80, tmpsize.height/2+80)
    content:setWidth(550)

    for i=1,#items do
        local icon  = createItemIcon(items[i].tmpId)
        :addTo(panel)
        :pos(130+(i-1)*130, tmpsize.height/2)
        :scale(0.9)

        local locTab = itemData[items[i].tmpId]
        local name = cc.ui.UILabel.new({UILabelType = 2, text = locTab.name, size = 18})
        :addTo(panel)
        :align(display.CENTER, icon:getPositionX(), tmpsize.height/2-65)
    end

    --确定按钮
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(panel)
    :pos(tmpsize.width/2, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确 定", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        self:removeSelf()
        ImproveLayer_Instance:RefreshUI()
        end)

end
--材料强化框
function improveCarLayer:strengthBox()
    -- {bAlwaysExist=true}
    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self,10)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --材料信息框
    local comInfoBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(700, 608),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(comInfoBox)
    local tmpsize = comInfoBox:getContentSize()

    local backBt = createCloseBt()
    :addTo(comInfoBox,2)
    :pos(tmpsize.width-20, tmpsize.height-20)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)

    local help = cc.ui.UIPushButton.new("common2/com2_img_26.png")
    :addTo(comInfoBox,2)
    :pos(50,tmpsize.height-20)
    :onButtonPressed(function(event) event.target:setScale(0.98) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:ruleTxt()
        end)

    cc.ui.UILabel.new({UILabelType = 2, text = "请对锁定的材料进行强化", size = 26})
    :addTo(comInfoBox)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height - 40)

    --锁定的材料

    local attr = string.split(curCarData.stuffInten, "|") 
    for i,v in ipairs(self.MeterialIds) do
        local icon = createItemIcon(v)
        :addTo(comInfoBox)
        :pos(120, (tmpsize.height-140)-(i-1)*120)
        :scale(0.9)

        local msgPart = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(350,100))
        :addTo(comInfoBox)
        :pos(tmpsize.width/2+10, icon:getPositionY())

        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "改造属性上限", size = 22,color=cc.c3b(131, 149, 165)})
        :addTo(msgPart)
        :align(display.CENTER_LEFT, 10, 30)

        local num = cc.ui.UILabel.new({font="fonts/slicker.ttf",UILabelType = 2, text = "", size = 22})
        :addTo(msgPart)
        :align(display.CENTER_LEFT, lab:getPositionX()+lab:getContentSize().width, lab:getPositionY())
        self:setMeterialNum(num,attr,i)
        

        local strenBt = createGreenBt2("强化",1.0)
        :addTo(msgPart)
        :pos(msgPart:getContentSize().width-60, 30)
        :onButtonClicked(function(event)
            self.curIcon = icon
            self.curLab = lab
            self.curNum = num
            self.curi = i
            startLoading()
            local sendData = {}
            sendData.carId = curCarData.id
            sendData.idx = i-1
            m_socket:SendRequest(json.encode(sendData), CMD_CAR_METERIAL_STREN, self, self.carMeterialStren)
            
            end)
    end
    local star = getItemStar(self.MeterialIds[1]) 

    --消耗材料
    local tmplab = cc.ui.UILabel.new({UILabelType = 2, text = "消耗材料", size = 25,color=cc.c3b(131, 149, 165)})
    :addTo(comInfoBox)
    :align(display.CENTER, tmpsize.width - 90, tmpsize.height - 150)

    --金币
    local gold = createGoldIcon(strengthCost[star-1][1])
    :addTo(comInfoBox)
    :pos(tmplab:getPositionX(), (tmpsize.height-260))

    --星石
    local icon = createItemIcon(STARSTONE_ID,nil,true)
    :addTo(comInfoBox)
    :pos(tmplab:getPositionX(), (tmpsize.height-380))
    :scale(0.9)
    :onButtonClicked(function(event)
        g_combinationLayer.new(STARSTONE_ID,nil)
        :addTo(MainScene_Instance,50)
        end)
    local numBar = display.newScale9Sprite("common/common_Frame7.png",nil, 
        nil,
        cc.size(90, 23),cc.rect(10, 10, 30, 30))
    :addTo(icon,5)
    :pos(0,-40)
    local num = getComNumPer(STARSTONE_ID,strengthCost[star-1][2])
    :addTo(numBar)
    :pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)
    self.starStoneNum = num
end

function improveCarLayer:setMeterialNum(num, attr,i)
    if tonumber(attr[i])>=0 then
        num:setColor(cc.c3b(0, 255, 0))
        num:setString("+"..attr[i].."%")
    else
        num:setColor(cc.c3b(255, 0, 0))
        num:setString(attr[i].."%")
    end
end

--强化说明
function improveCarLayer:ruleTxt()
    local layer = UIMasklayer.new()
    :addTo(self,50)
    layer:setTouchCallback(function ( ... )
        layer:removeSelf()
    end)
    local tmpSize = cc.size(843, 555)
    local spr = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
                    :addTo(layer)
                    :pos(display.cx,display.cy)


    display.newTTFLabel{text = "规则说明",size = 40,color = cc.c3b(95,255,250)}
        :align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
        :addTo(spr)

    local _label = display.newTTFLabel({text = "你好",size = 25})
                        :addTo(spr)
                        :align(display.CENTER,spr:getContentSize().width/2,spr:getContentSize().height/2-30)
            local _singleLineHeight = _label:getContentSize().height
            _label:setWidth(spr:getContentSize().width-113)
            _label:setLineHeight(_singleLineHeight+4)

    local str = [[1、消耗金币与星石可对锁定的4个材料进行强化
2、强化可提升改造材料的属性上限，强化后再进行改装，战车可获得更多的改造属性
3、每个材料强化次数不限，每个改造材料属性上限最多提升20%
4、每次强化属性变动随机变动，小概率会出现负值
5、强化期间若取消锁定材料，则之前强化记录清空
6、强化期间若确认改装，则以当时的强化数值进行战车改装
        ]]
        _label:setString(str)

        layer:addHinder(spr)
    layer:setOnTouchEndedEvent(function()
        layer:removeFromParent()
    end)
end

function improveCarLayer:createDataProgress(data)
    -- printTable(data)
    if self.dataNode then
        self.dataNode:removeSelf()
        self.dataNode = nil
    end
    
    self.dataNode = display.newNode()
    :addTo(self.rightPanel)

    local mpos = {
        cc.p(270, 225),
        cc.p(270, 170),
        cc.p(270, 115),
        cc.p(270, 60),
    }
    local stuffArr = lua_string_split(data,"|")
    local name = {"主炮攻击：", "副炮攻击：", "防御：", "血量：","闪避：", "命中：", "暴击："}
    local posIdx = 0
    for i,value in ipairs(self.MeterialIds) do
        local tabIdx = 0
        local locNum = 0
        local tmpArr = lua_string_split(stuffArr[i],";")
        local locData = itemData[value]
        local fourLetter = tonumber(string.sub(value, 7, 7))
        if locData.attack~=0 and fourLetter==1 then
            tabIdx = 1  
            locNum= locData.attack
        elseif locData.attack~=0 and fourLetter==2 then
            tabIdx = 2
            locNum= locData.attack
        elseif locData.defense~=0 then
            tabIdx = 3
            locNum= locData.defense
        elseif locData.hp~=0 then
            tabIdx = 4
            locNum= locData.hp
        elseif locData.miss~=0 then
            tabIdx = 5
            locNum= locData.miss
        elseif locData.hit~=0 then
            tabIdx = 6
            locNum= locData.hit
        elseif locData.cri~=0 then
            tabIdx = 7
            locNum= locData.cri
        else
            showTips("数据错误")
            return
        end
        local attr = string.split(curCarData.stuffInten, "|") 
        print("----------")
        print(curCarData.stuffInten)
        printTable(attr)
        locNum = locNum*(1+tonumber(attr[i])/100)
        local perNum = tonumber(tmpArr[2])
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = name[tabIdx], size = 22, color = cc.c3b(255, 226, 0)})
        :addTo(self.dataNode)
        :pos(mpos[i].x, mpos[i].y)

        --数值
        local label1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "+"..string.format("%.1f", perNum*locNum), size = 22, color = cc.c3b(55, 234, 255)})
        :addTo(self.dataNode)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())

        local bar = display.newScale9Sprite("#improve2_img32.png",nil,nil,cc.size(155, 15))
        :addTo(self.dataNode)
        :pos(mpos[i].x+75, mpos[i].y-25)

        local pro = cc.ui.UILoadingBar.new({image = "#improve2_img33.png", viewRect = cc.rect(0,0,155, 15), scale9 = true, capInsets=cc.rect(0,0,117, 9)})
        :addTo(bar)
        pro:setPercent(perNum*100)

        local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = (perNum*100).."%", size = 18})
        :addTo(bar,2)
        :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2)
        setLabelStroke(label,18,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
    end
    
end
--帮助界面
function improveCarLayer:createHelpBox()
    local layer = UIMasklayer.new()
    layer:setTouchCallback(function ( ... )
        layer:removeSelf()
    end)
    local tmpSize = cc.size(843, 555)
    local spr = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
                    :addTo(layer)
                    :pos(display.cx,display.cy)


    display.newTTFLabel{text = "规则说明",size = 40,color = cc.c3b(95,255,250)}
        :align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
        :addTo(spr)

    local _label = display.newTTFLabel({text = "你好",size = 25})
                        :addTo(spr)
                        :align(display.CENTER,spr:getContentSize().width/2,spr:getContentSize().height/2-30)
            local _singleLineHeight = _label:getContentSize().height
            _label:setWidth(spr:getContentSize().width-113)
            _label:setLineHeight(_singleLineHeight+4)

    local str = [[1.每次改造需要达到规定的战队等级并消耗任意4个对应星级的材料
2.不同的改造材料决定改造后战车属性偏向，请慎重选择材料改造自己的爱车
3.每个材料在改造后会转化成战车属性，转化百分比每次随机生成，最低60%，最高100%（V7玩家最低转化70%）
4.锁定材料之后可以生成改造属性预览
5.消耗100钻石或1个已锁定的材料可以取消锁定，取消后可重新放入材料与生成属性
6.改造成功后不能进行回退，材料属性永久增加到战车属性上

        ]]
    _label:setString(str)

    layer:addHinder(spr)
    layer:setOnTouchEndedEvent(function()
        layer:removeFromParent()
    end)

    self:getParent():addChild(layer,50)
end

function improveCarLayer:onMeterailLock(cmd)
    if cmd.result==1 then
        showTips("已锁定")
        self.isLock = true
        self.wenhao:setVisible(false)
        -- self.cancelBt:setVisible(true)
        self.circleImg:runAction(cc.RotateBy:create(0.2, 45))
        for i=1,#self.meterialNode do
            display.newSprite("item/item_10000.png")
            :addTo(self.meterialNode[i],1,11)
            :pos(0, 7)
            :scale(0.7)
            if i==1 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(40,0)))
            elseif i==2 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(0,-40)))
            elseif i==3 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(-40,0)))
            elseif i==4 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(0,40)))
            end
        end
        self.btNode1:setVisible(false)
        self.btNode2:setVisible(true)
        -- self.confirmBt:setVisible(true)

        --更新战车数据
        CarManager.carIDKeyList[curCarData.id].impStuff = cmd.data.info
        curCarData.impStuff = cmd.data.info

        self:performWithDelay(function ()
                       self:createDataProgress(curCarData.impStuff)
            end, 0.5)
        
        
        self:reloadListview()
        --UI特效
        carImproEff1(self.rightPanel,self.rightPanel:getContentSize().width/2,self.rightPanel:getContentSize().height/2)
        carImproEff4(self.topPanel, 270, self.topPanel:getContentSize().height/2)
    else
        showTips(cmd.msg)
    end
end

--解锁
function improveCarLayer:onMeterailUnLock(cmd)
    if cmd.result==1 then
        srv_userInfo.diamond = cmd.data.diamond
        mainscenetopbar:setDiamond()
        self.MeterialIds = {} --清空数据
        self.isLock = false
        CarManager.carIDKeyList[curCarData.id].impStuff = ""
        curCarData.impStuff = ""
        self:reloadAllItemsData()

        --更新UI
        self.circleImg:runAction(cc.RotateBy:create(0.2, -45))
        for i=1,#self.meterialNode do
            self.meterialNode[i]:removeChildByTag(10)
            self.meterialNode[i]:removeChildByTag(11)
            if i==1 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(-40,0)))
            elseif i==2 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(0,40)))
            elseif i==3 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(40,0)))
            elseif i==4 then
                self.meterialNode[i]:runAction(cc.MoveBy:create(0.2, cc.p(0,-40)))
            end
        end
        self.dataNode:removeSelf()
        self.dataNode = nil
        self.btNode1:setVisible(true)
        self.btNode2:setVisible(false)
        -- self.confirmBt:setVisible(false)
        self.wenhao:setVisible(true)
        -- self.cancelBt:setVisible(false)

        self:reloadListview()
        self.unLockMaskLayer:removeSelf()
        showTips("已取消锁定")

        curCarData.stuffInten = "0|0|0|0"
    else
        self.unLockMaskLayer:removeSelf()
        showTips(cmd.msg)
    end
end

--战车重置
function improveCarLayer:onCarResetResult(cmd)
    if cmd.result==1 then
        self.resetMaskLayer:removeSelf()
        CarManager.carIDKeyList[curCarData.id] = cmd.data.carInfo
        curCarData = cmd.data.carInfo
        printTable(srv_BackPackPushData["add"])
        self:resetBackItem(srv_BackPackPushData["add"])
        curCarData.stuffInten = "0|0|0|0"
    else
        showTips(cmd.msg)
    end
end
--材料强化
function improveCarLayer:carMeterialStren(cmd)
    if cmd.result==1 then
        srv_userInfo.gold = cmd.data.gold
        mainscenetopbar:setGlod()


        curCarData.stuffInten = cmd.data.stuffInten
        local attr = string.split(curCarData.stuffInten, "|") 
        self:setMeterialNum(self.curNum, attr, self.curi)
        -- curCarData.stuffInten = ""rf
        -- for i,v in ipairs do
        --     if i~=4 then
        --         curCarData.stuffInten = curCarData.stuffInten..v.."|"
        --     else
        --         curCarData.stuffInten = curCarData.stuffInten..v
        --     end
            
        -- end
        self:createDataProgress(curCarData.impStuff)
        --星石数量更新
        local cnt
        local value = get_SrvBackPack_Value(STARSTONE_ID)
        if value==nil then
            cnt = 0
        else
            cnt = value.cnt
        end
        local star = getItemStar(self.MeterialIds[1]) 
        local text = cnt.."/"..strengthCost[star-1][2]
        self.starStoneNum:setString(text)

        --材料强化特效
        strengthAnimation(self.curIcon,self.curIcon:getContentSize().width/2,self.curIcon:getContentSize().height/2)

        --属性增加动画
        self:addAttriNum(self.curLab,cmd.data.intenAdd)
    else
        showTips(cmd.msg)
    end
end

function improveCarLayer:addAttriNum(node,intenAdd)
    local lab = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
    :addTo(node:getParent())
    :pos(node:getPositionX()+132, node:getPositionY())

    if intenAdd>=0 then
        if intenAdd==0 then
            lab:setString("+0")
        else
            lab:setString("+"..intenAdd)
        end
        
        lab:setColor(cc.c3b(0, 255, 0))
    else
        lab:setString(intenAdd)
        lab:setColor(cc.c3b(255, 0, 0))
    end

    local moveAct = cc.MoveBy:create(1, cc.p(0, 50))
    local FadeOut = cc.FadeOut:create(2)
    local seq = transition.sequence({moveAct,
        cc.CallFunc:create(function()
            lab:removeSelf()
            end)})
    lab:runAction(FadeOut)
    lab:runAction(seq)
    
end


return improveCarLayer