-- @Author: anchen
-- @Date:   2016-07-14 15:13:01
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-11 10:23:42

CAR_LEVEL = {
    "D","D+","C","C+","B","B+","A","A+","S","S+",
}

--本地战车进阶表按车模板，按等级区分
CARLEVEL_TMPID = {}
for k,value in pairs(carLevelData) do
    if CARLEVEL_TMPID[value.carTmpId]==nil then
        CARLEVEL_TMPID[value.carTmpId] = {}
    end
    CARLEVEL_TMPID[value.carTmpId][value.level] = value
end
--可用以下打印查看输出table
-- printTable(CARLEVEL_TMPID)

local carAdvance = class("carAdvance",function()
    local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 200))
    layer:setNodeEventEnabled(true)
    return layer
end)

function carAdvance:ctor(_curCarData)
    self._curCarData = _curCarData

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

    local panel = display.newSprite("#improve2_img15.png")
    :addTo(self)
    :pos(display.cx, display.cy-20)
    panel:setScaleY(1.4)
    local tmpsize = panel:getContentSize()
    self.panel = panel

    --左面板
    local leftPanel = display.newSprite("#improve2_img16.png")
    :addTo(self)
    :pos(display.cx-270, display.cy + 80)
    self.leftPanel = leftPanel

    

    local carModel1 = ShowModel.new({modelType=ModelType.Tank, templateID=_curCarData.TemId})
        :pos(leftPanel:getContentSize().width/2-100, leftPanel:getContentSize().height/2-100)
        :addTo(leftPanel)
        carModel1:setScaleY(0.7*2*0.6)
        carModel1:setScaleX(-0.7*2*0.6)

    --属性加成
    self:addAttri(_curCarData.carLvl, leftPanel)


    --箭头
    self.jiantou = display.newSprite("#improve2_img17.png")
    :addTo(self)
    :pos(display.cx, display.cy + 80)

    --右面板
    local rightPanel = display.newSprite("#improve2_img16.png")
    :addTo(self)
    :pos(display.cx+270, display.cy + 80)
    self.rightPanel = rightPanel

    

    --等级
    -- local num = 36 + math.floor((_curCarData.level+2)/2)
    -- local level = display.newSprite("#improve2_img"..num..".png")
    -- :addTo(rightPanel)
    -- :align(display.CENTER_LEFT, 10,rightPanel:getContentSize().height-40)

    -- local carLevelAdd = display.newSprite("#improve2_img42.png")
    -- :addTo(rightPanel)
    -- :align(display.CENTER_LEFT, level:getContentSize().width,rightPanel:getContentSize().height-40)
    -- if math.mod(_curCarData.level+1, 2)==0 then
    --     carLevelAdd:setVisible(true)
    -- else
    --     carLevelAdd:setVisible(false)
    -- end 

    local carModel = ShowModel.new({modelType=ModelType.Tank, templateID=_curCarData.TemId})
        :pos(leftPanel:getContentSize().width/2-100, leftPanel:getContentSize().height/2-100)
        :addTo(rightPanel)
        carModel:setScaleY(0.7*2*0.6)
        carModel:setScaleX(-0.7*2*0.6)

    --属性加成
    self:addAttri(_curCarData.carLvl + 1, rightPanel)
    


    


    --消耗核心
    local lab = cc.ui.UILabel.new({UILabelType = 2, text = "消耗核心：", size = 33, color = cc.c3b(220, 221, 221)})
    :addTo(self,10)
    :pos(display.cx-400, display.cy-130)
    setLabelStroke(lab,33,nil,nil,nil,nil,nil,nil, true)

    local bar = display.newSprite("#improve2_img51.png")
    :addTo(self)
    :align(display.LEFT_CENTER, lab:getPositionX()+lab:getContentSize().width, lab:getPositionY())
    
    self.ProBar1 = cc.ui.UILoadingBar.new({image = "#improve2_img49.png", viewRect = cc.rect(0,0,381,37)})
    :addTo(bar)
    :align(display.LEFT_BOTTOM,0, 0)
    

    self.proNum1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(bar,2)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-3)
    
    self.retNode1 = setLabelStroke(self.proNum1,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)



    --获取
    local getBt = cc.ui.UIPushButton.new("common2/com2_img_34.png")
    :addTo(self)
    :align(display.LEFT_CENTER, bar:getPositionX()+bar:getContentSize().width, bar:getPositionY())
    :onButtonPressed(function(event)
        event.target:setScale(0.98)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        if self.coreTmpId then
            self:createBlock(self.coreTmpId)
        end
        
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "获取", size = 30, color = cc.c3b(106, 57, 6)})
    :addTo(getBt)
    :pos(17,5)


    --消耗能源
    local lab = cc.ui.UILabel.new({UILabelType = 2, text = "消耗能源：", size = 33, color = cc.c3b(220, 221, 221)})
    :addTo(self,10)
    :pos(display.cx-400, display.cy-220)
    setLabelStroke(lab,33,nil,nil,nil,nil,nil,nil, true)

    local bar = display.newSprite("#improve2_img51.png")
    :addTo(self)
    :align(display.LEFT_CENTER, lab:getPositionX()+lab:getContentSize().width, lab:getPositionY())
    
    self.ProBar2 = cc.ui.UILoadingBar.new({image = "#improve2_img50.png", viewRect = cc.rect(0,0,381,37)})
    :addTo(bar)
    :align(display.LEFT_BOTTOM,0, 0)

    self.proNum2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
    :addTo(bar,2)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-3)
    self.retNode2 = setLabelStroke(self.proNum2,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)

    

    --获取
    local getBt = cc.ui.UIPushButton.new("common2/com2_img_34.png")
    :addTo(self)
    :align(display.LEFT_CENTER, bar:getPositionX()+bar:getContentSize().width, bar:getPositionY())
    :onButtonPressed(function(event)
        event.target:setScale(0.98)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        self:createBlock(ITEM_ENERGY)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "获取", size = 30, color = cc.c3b(106, 57, 6)})
    :addTo(getBt)
    :pos(17,5)

    --进度条数据
    self.flag = self:reloadProData()
    --觉醒按钮
    local adBt = createBlueBt("觉 醒")
    :addTo(self)
    :pos(display.cx+360, display.cy-175)
    :onButtonClicked(function(event)
        
        if self.flag then
            startLoading()
            local sendData={}
            sendData["carId"]=_curCarData.id
            m_socket:SendRequest(json.encode(sendData), CMD_CAR_ADVANCE, self, self.onCarAdvanceRes)
        else
            showTips("战车核心或能源不够")
        end
        end)
end

function carAdvance:reloadProData()
    local carTmpId = self._curCarData.TemId
    local carTmp = tonumber(string.sub(tostring(carTmpId),1,3))
    local LOC_TAB = CARLEVEL_TMPID[carTmp][self._curCarData.carLvl]

    local costItem =  LOC_TAB["costItem"]
    local needCnt,haveCnt = 0,0
    local needCnt2,haveCnt2 = 0,0
    if costItem and costItem~="null" then
        local costArr = string.split(costItem, "|")
        local cost = string.split(costArr[1], "#")
        local itTmpId = tonumber(cost[1])
        self.coreTmpId = itTmpId
        needCnt = tonumber(cost[2])
        _,haveCnt = get_SrvBackPack_Value(itTmpId)

        local cost = string.split(costArr[2], "#")
        local itTmpId = tonumber(cost[1])
        needCnt2 = tonumber(cost[2])
        _,haveCnt2 = get_SrvBackPack_Value(itTmpId)
    end
    
    local per1 = math.min(100, (haveCnt/needCnt)*100)
    local per2 = math.min(100, (haveCnt2/needCnt2)*100)

    self.ProBar1:setPercent(per1)
    self.proNum1:setString(haveCnt.."/"..needCnt)
    setLabelStrokeString(self.proNum1, self.retNode1)

    self.ProBar2:setPercent(per2)
    self.proNum2:setString(haveCnt2.."/"..needCnt2)
    setLabelStrokeString(self.proNum2, self.retNode2)

    return (per1>=100 and per2>=100)
end

--属性加成
function carAdvance:addAttri(_carlevel, _parent)
    if _carlevel>10 then
        self.jiantou:removeSelf()
        _parent:removeSelf()
        return
    end
    _parent:removeChildByTag(100)
    local tmpNode = display.newNode()
    :addTo(_parent,0,100)
    --等级
    local num = 36 + math.floor((_carlevel+1)/2)
    local level = display.newSprite("common2/improve2_img"..num..".png")
    :addTo(tmpNode)
    :align(display.CENTER_LEFT, 10,_parent:getContentSize().height-40)

    local carLevelAdd = display.newSprite("common2/improve2_img42.png")
    :addTo(tmpNode)
    :align(display.CENTER_LEFT, level:getContentSize().width,_parent:getContentSize().height-20)
    :scale(0.6)
    if math.mod(_carlevel, 2)==0 then
        carLevelAdd:setVisible(true)
    else
        carLevelAdd:setVisible(false)
    end 

    local carTmpId = self._curCarData.TemId
    local carTmp = tonumber(string.sub(tostring(carTmpId),1,3))

    local tmpLab = {
        {name = "主炮成长：", clr1 = cc.c3b(55, 234, 255), clr2 = cc.c3b(255, 226, 0), attr = "mainAtkPro"},
        {name = "副炮成长：", clr1 = cc.c3b(55, 234, 255), clr2 = cc.c3b(255, 226, 0), attr = "subAtkPro"},
        {name = "血量成长：", clr1 = cc.c3b(55, 234, 255), clr2 = cc.c3b(255, 226, 0), attr = "hpPro"},
        {name = "防御成长：", clr1 = cc.c3b(55, 234, 255), clr2 = cc.c3b(255, 226, 0), attr = "defensePro"},
        {name = "命中成长：", clr1 = cc.c3b(55, 234, 255), clr2 = cc.c3b(255, 226, 0), attr = "hitPro"},
    }
    local _mszie = 23
    for key,value in pairs(tmpLab) do
        local lab = cc.ui.UILabel.new({UILabelType = 2, text = value.name, size = _mszie, color = value.clr1})
        :addTo(tmpNode)
        :pos(280, 236-(key-1)*50)

        local per = CARLEVEL_TMPID[carTmp][_carlevel][value.attr]
        local lab1 = cc.ui.UILabel.new({UILabelType = 2, text = "+"..per, size = _mszie, color = value.clr2, font = "fonts/slicker.ttf"})
        :addTo(tmpNode)
        :pos(lab:getPositionX()+lab:getContentSize().width, 236-(key-1)*50)
    end

end

function carAdvance:onCarAdvanceRes(cmd)
    if cmd.result==1 then
        CarManager.carIDKeyList[self._curCarData.id].carLvl = cmd.data.level
        curCarData = CarManager.carIDKeyList[self._curCarData.id]
        self._curCarData = curCarData

        if ImproveLayer_Instance then
            ImproveLayer_Instance:RefreshAttr()
        end
        


        self:addAttri(self._curCarData.carLvl, self.leftPanel)
        if (self._curCarData.carLvl+1)<=10 then
            self:addAttri(self._curCarData.carLvl+1, self.rightPanel)
        else
            self.jiantou:setVisible(false)
            self.rightPanel:setVisible(false)
        end
        
        self.flag = self:reloadProData()

        advancedAnimation(self.leftPanel,self.leftPanel:getContentSize().width/2-100,self.leftPanel:getContentSize().height/2-30)
        carImproEff1(self.rightPanel,self.rightPanel:getContentSize().width/2,self.rightPanel:getContentSize().height/2)
    else
        showTips(cmd.msg)
    end
end

--通过关卡获取
function carAdvance:createBlock(tmpId)
    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self,100)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)

    self.comTree =  display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
                display.cy-30,
                cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)

    local backBt = createCloseBt()
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width-10,self.comTree:getContentSize().height-10)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        self.flag = self:reloadProData()
        end)

    local line = display.newSprite("SingleImg/BackPack/comb/titleLine.png")
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 100)

    print("have block")

    local icon = createItemIcon(tmpId)
    :addTo(self.comTree)
    :pos(70,self.comTree:getContentSize().height - 55)
    :scale(0.6)

    local curDown = display.newSprite("SingleImg/BackPack/comb/curDown.png")
            :addTo(icon)
            :pos(0,-80)

    local titleLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2,self.comTree:getContentSize().height - 150)
    titleLabel:setAnchorPoint(0.5,0.5)
    titleLabel:setString(itemData[tmpId].name)
    local star = getItemStar(tmpId)
    if star==2 then
        titleLabel:setColor(cc.c3b(193, 195, 180))
    elseif star==3 then
        titleLabel:setColor(cc.c3b(107, 206, 82))
    elseif star==4 then
        titleLabel:setColor(cc.c3b(85, 171, 249))
    elseif star==5 then
        titleLabel:setColor(cc.c3b(204, 89, 252))
    end

    --获取途径列表
    local getListView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(15, 120, 460, 300),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.comTree)
    local blockList = getItemBlock(tmpId)


    if next(blockList)==nil then
        local txt = "剧情、自动售货机或各类\n商店中获得"
        if ITEM_ENERGY==tmpId then
            txt = "分解完整材料、道具或\n战车装备获得"
        end
        local TipLabel=cc.ui.UILabel.new({UILabelType = 2, text = txt, size = 30})
        :addTo(self.comTree)
        :pos(self.comTree:getContentSize().width/2,self.comTree:getContentSize().height/2)
        TipLabel:setColor(cc.c3b(255,255,0))
        TipLabel:setAnchorPoint(0.5,0.5)
        return
    end

    for i,value in pairs(blockList) do
        
        local blockId = value.id
        local areaId = blockIdtoAreaId(blockId)
        -- print("blockId1:"..blockId)
        local local_blockData = blockData[blockId]

        local item = getListView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(460, 100)

        local itemW,itemH = item:getItemSize()

        local BarBt = cc.ui.UIPushButton.new("equipment/equipmentImg5.png",
            {scale9 = true})
        :addTo(content)
        BarBt:setButtonSize(440, 100)
        BarBt:setAnchorPoint(0.5,0.5)
        BarBt:setTouchSwallowEnabled(false)

        if not bCpBlock(blockId) then
            BarBt:setColor(cc.c3b(50, 50, 50))
        end

        local cur_AreaImgPath = "Block/area_"..blockIdtoAreaId(blockId).."/"
        local imgBlockId = blockId
        if blockData[blockId].type~=1 then
            local curBlockData = getCurAreaBlocksData(blockIdtoAreaId(blockId))
            for i,value in pairs(curBlockData) do
                if value.type==1 and value.id%1000==blockData[blockId].id%1000 and value.name == blockData[blockId].name then
                    imgBlockId = value.id
                    break
                end
            end
        end
        -- local blockIcon = cc.ui.UIImage.new(cur_AreaImgPath.."block_"..imgBlockId..".png")
        -- :addTo(BarBt)
        -- :pos(-165,0)
        -- blockIcon:setScale(0.4)
        -- blockIcon:setAnchorPoint(0,0.5)
        --箭头
        local goBt = cc.ui.UIPushButton.new("equipment/equipmentImg12.png")
        :addTo(BarBt)
        :pos(130,0)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            if not bCpBlock(blockId) then
                showTips("关卡尚未开启")
                return
            end
            ToBlockId = blockId
            ToAreaId = areaId
            if next(srv_blockData)~=nil and srv_userInfo["areaId"]==ToAreaId then
                print("碎片获取，当前区")
                MainSceneEnterType = EnterTypeList.CARADVANCE_ENTER
                
                local areamap = g_blockMap.new(ToAreaId, ToBlockId, nil, true)
                areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
                -- cc.Director:getInstance():getRunningScene():setMainMenuVisible(false)
                
                
            else
                print("碎片获取，其他区")
                startLoading()
                sendAreaList = getSendAreaList(ToAreaId)
                local SelectAreaData={}
                SelectAreaData["characterId"]=srv_userInfo["characterId"]
                SelectAreaData["areaId"]=sendAreaList
                m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
            end

        end)

        local blockName=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        -- :align(display.TOP_LEFT, -165, -15)
        :addTo(BarBt)
        local areaName = areaData[local_blockData.areaId].name
        local blockname = local_blockData.name
        blockName:setString(areaName.."-"..blockname)
        
        if local_blockData.type==1 then
            local blockType=cc.ui.UILabel.new({UILabelType = 2, text = "普通", size = 25,color = cc.c3b(149, 176, 198)})
            :align(display.CENTER_LEFT, -185, 18)
            :addTo(BarBt)

            blockName:pos(-185,-15)
            blockName:setColor(cc.c3b(98, 171, 213))
        else
            display.newSprite("equipment/equipmentImg14.png")
            :align(display.TOP_LEFT, -itemW/2+12, itemH/2-2)
            :addTo(BarBt)

            blockName:pos(-185,0)
            blockName:setColor(cc.c3b(209, 147, 205))

            goBt:setButtonImage("normal", "equipment/equipmentImg13.png")
            goBt:setButtonImage("pressed", "equipment/equipmentImg13.png")
            goBt:setButtonImage("disabled", "equipment/equipmentImg13.png")

            BarBt:setButtonImage("normal", "equipment/equipmentImg16.png")
            BarBt:setButtonImage("pressed", "equipment/equipmentImg16.png")
            BarBt:setButtonImage("disabled", "equipment/equipmentImg16.png")
        end

        

        
        getListView:addItem(item)
    end
    getListView:reload()

end
--进入关卡
function carAdvance:onEnterBlockResult(result)
    endLoading()
    if result["result"]==1 then
        MainSceneEnterType = EnterTypeList.CARADVANCE_ENTER

        srv_userInfo["areaId"] = ToAreaId
        local areamap = g_blockMap.new(ToAreaId, ToBlockId, nil, true)
        areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
    else
        showTips(result.msg)
    end
end

return carAdvance