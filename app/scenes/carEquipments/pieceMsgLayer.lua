local pieceMsgLayer = class("pieceMsgLayer", function()
	return display.newLayer()
	end)
local masklayer
local ToAreaId
local ToBlockId

function pieceMsgLayer:ctor(pcomData,callback)
    
	masklayer =  UIMasklayer.new()
    :addTo(self)
    local function  func()
    	self:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --碎片信息框
    self.pieceInfoBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(self.pieceInfoBox)

    self.pcomData = pcomData
    self.callback = callback
    self:refreshData()
end
function pieceMsgLayer:refreshData()
	self.pieceInfoBox:removeAllChildren()
	local pcomData = self.pcomData
	local callback = self.callback


    --返回按钮
    self.backBt = createCloseBt()
    :addTo(masklayer,2)
    :pos(self.pieceInfoBox:getPositionX() + self.pieceInfoBox:getContentSize().width/2+15,
            self.pieceInfoBox:getPositionY() + self.pieceInfoBox:getContentSize().height/2-32)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

	local piece = {}
	if pcomData.value==nil then
        piece.cnt = 0
        local pieceArr=lua_string_split(pcomData.pieceTmpId,":")
        piece.tmpId = pieceArr[1]+0
    else
        piece = pcomData.value
    end
    local localItem=itemData[piece["tmpId"]]

    local msgBox = self.pieceInfoBox
	--图标
    local icon = createItemIcon(piece["tmpId"])
    :addTo(msgBox,0,1000)
    :pos(110,msgBox:getContentSize().height - 90)
    --类型
    -- local bar = display.newScale9Sprite("equipment/equipmentImg3.png",nil,nil,cc.size(120,39))
    -- :addTo(msgBox)
    -- :pos(252,msgBox:getContentSize().height - 55)

    -- local eqtType = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    -- :addTo(bar)
    -- :pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
    -- eqtType:setAnchorPoint(0.5,0.5)
    -- eqtType:setString(itemTypeToString(cur_value["tmpId"]))
    -- eqtType:setColor(cc.c3b(241, 171, 0))

    --名字
    self.name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 55)
    self.name:setAnchorPoint(0,0.5)
    self.name:setString(localItem.name)
    local star = getItemStar(localItem.id)
    if star==2 then
        self.name:setColor(cc.c3b(193, 195, 180))
    elseif star==3 then
        self.name:setColor(cc.c3b(107, 206, 82))
    elseif star==4 then
        self.name:setColor(cc.c3b(85, 171, 249))
    elseif star==5 then
        self.name:setColor(cc.c3b(204, 89, 252))
    end

    --星级
    local starNum = getItemStar(localItem.id)
    for i=1,starNum do
        local star = display.newSprite("common/common_Star.png")
        :addTo(msgBox)
        :pos(34*i+170,msgBox:getContentSize().height - 95)
    end

    local pieceType = math.floor(piece["tmpId"]/10000)
    if pieceType~=306 then
        --评分
        cc.ui.UILabel.new({UILabelType = 2, text = "（品质:"..localItem.score.."）", size = 25})
        :addTo(msgBox)
        :pos(34*starNum+180,msgBox:getContentSize().height - 98)
    end
    

    --等级
    self.level = cc.ui.UILabel.new({UILabelType = 2, text = "拥有：", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 135)
    self.level:setAnchorPoint(0,0.5)
    self.level:setColor(cc.c3b(248, 204, 45))

    self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(self.level:getPositionX()+self.level:getContentSize().width,msgBox:getContentSize().height - 135-2)
    self.level:setAnchorPoint(0,0.5)
    self.level:setString(piece.cnt)


    --底框1
    local msgPart = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,120))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2+80)

    --描述
    local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22,color=cc.c3b(131, 149, 165)})
    :addTo(msgPart)
    :pos(10,msgPart:getContentSize().height-10)
    des:setString(localItem["des"])
    des:setAnchorPoint(0,1)
    des:setWidth(420)
    des:setLineHeight(30)

    --万能碎片总量
    local pieceNumLabel = cc.ui.UILabel.new({UILabelType = 2, text = "万能碎片总量：", size = 25})
    :addTo(self.pieceInfoBox)
    :pos(40,self.pieceInfoBox:getContentSize().height/2-10)
    --碎片数量
    local piecenum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
    :addTo(self.pieceInfoBox)
    :pos(pieceNumLabel:getContentSize().width+pieceNumLabel:getPositionX(),pieceNumLabel:getPositionY())
    piecenum:setColor(cc.c3b(255, 241, 0))
    piecenum:setString(pcomData.universalPieceNum)
    --获得万能碎片按钮
    local getPieceBt = cc.ui.UIPushButton.new()
    :addTo(self.pieceInfoBox)
    :pos(self.pieceInfoBox:getContentSize().width - 100, self.pieceInfoBox:getContentSize().height/2-10)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = ">>获得", size = 25, color = cc.c3b(255, 241, 0)}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
    	showMessageBox("万能碎片通过抽卡获得，是否前去抽卡？",function()
    		local lotteryCard = g_lotteryCardLayer.new()
        	:addTo(display.getRunningScene())
    		end)
    	end)
    --合成进度
    local msgPart = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,120))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2-100)
    --装备碎片数
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "合成进度", size = 22})
    :addTo(msgPart)
    :pos(10,msgPart:getContentSize().height-40)
    label:setColor(cc.c3b(255, 241, 0))
    local num = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
    :addTo(msgPart)
    :pos(20+label:getContentSize().width, msgPart:getContentSize().height-40-2)
    num:setString((piece["cnt"]).."/"..pcomData.needPiece)
    if pcomData.result==2 then
    	num:setColor(cc.c3b(0, 255, 0))
        local Collecte = display.newSprite("SingleImg/BackPack/comb/Collecte.png")
        :addTo(msgPart)
        :pos(msgPart:getContentSize().width-60,msgPart:getContentSize().height/2)
        -- Collecte:setRotation(-20)
    else
    	num:setColor(cc.c3b(255, 0, 0))
    	local unCollecte = display.newSprite("equipment/equipmentImg15.png")
    	:addTo(msgPart)
    	:pos(msgPart:getContentSize().width-60,msgPart:getContentSize().height/2)
    	-- unCollecte:setRotation(-20)
    end
    --可用万能碎片
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "可用万能碎片", size = 22})
    :addTo(msgPart)
    :pos(10,40)
    label:setColor(cc.c3b(255, 241, 0))
    local num = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
    :addTo(msgPart)
    :pos(20+label:getContentSize().width, 40)
    num:setString(math.min(pcomData.maxOmniCount, math.max(0, pcomData.needPiece - piece["cnt"])))
    num:setColor(cc.c3b(255, 255, 0))
    --合成按钮
    self.comBt = createGreenBt2("合成", 1.2)
    :addTo(self.pieceInfoBox)
    :pos(130, 70)
    :onButtonClicked(function(event)
    	startLoading()
        comData={}--全局
        comData["itTmpId"] = pcomData.itTmpId
        local g_step = nil
        -- g_step = GuideManager:tryToSendFinishStep(124) --合成横纲力士下一步
        comData.guideStep = g_step
        m_socket:SendRequest(json.encode(comData), CMD_COMBINATION, self, self.onCombinationResult)
        local parent = BackPack_Equipment.Instance
        -- GuideManager:_addGuide_2(12306, display.getRunningScene(),handler(parent,parent.caculateGuidePos))
    	end)
    self.guideBtn = self.comBt
    --获得按钮
    self.comBt = createGreenBt2("获得", 1.2)
    :addTo(self.pieceInfoBox)
    :pos(self.pieceInfoBox:getContentSize().width - 130, 70)
    :onButtonClicked(function(event)
        self:showGetBlock(piece, event)
    	-- g_combinationLayer.new(piece["tmpId"],handler(self,self.refreshData),103)
     --    :addTo(self,10)
    	end)
end
--显示获取途径
function pieceMsgLayer:showGetBlock(value, event)
    self.backBt:setPositionX(self.pieceInfoBox:getPositionX() + self.pieceInfoBox:getContentSize().width-20)
    self.pieceInfoBox:setPositionX(display.cx - self.pieceInfoBox:getContentSize().width/2)
    self.comTree = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    self.comTree:setPositionX(display.cx + self.comTree:getContentSize().width/2)
    event.target:setButtonEnabled(false)
    event.target:setColor(cc.c3b(128, 128, 128))

    local icon = createItemIcon(value.tmpId,nil,true)
    :addTo(self.comTree,1)
    :pos(70, self.comTree:getContentSize().height-55)
    icon:setScale(0.6)
    icon:onButtonClicked(function(event)
        end)
    local curDown = display.newSprite("SingleImg/BackPack/comb/curDown.png")
    :addTo(icon)
    :pos(0,-80)
    local line = display.newSprite("SingleImg/BackPack/comb/titleLine.png")
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 100)

    self:createBlock(value.tmpId)
end
function pieceMsgLayer:createBlock(tmpId)
    print("have block")
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

    --返回按钮
    local combBt = createGreenBt2("返回", 1.2)
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2, 70)
    :onButtonClicked(function(event)
        if #g_combLine<=1 then
            self.comTree:setVisible(false)
            self.pieceInfoBox:setPositionX(display.cx)
            self.comTree:setPositionX(display.cx)
            self.comBt:setButtonEnabled(true)
            self.comBt:setColor(cc.c3b(255, 255, 255))
        else
            table.remove(g_combLine)
            self:performWithDelay(function ()
                       self:showItemComb(g_combLine[#g_combLine])
            end, 0.01)
        end
        self.backBt:setPositionX(self.pieceInfoBox:getPositionX() + self.pieceInfoBox:getContentSize().width/2-20)
        end)


    if next(blockList)==nil then
        local TipLabel=cc.ui.UILabel.new({UILabelType = 2, text = "剧情、自动售货机或各类\n商店中获得", size = 30})
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
            BarBt:setColor(cc.c3b(128, 128, 128))
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
                -- if self.enterType==101 then
                --     MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
                -- elseif self.enterType==102 then
                --     MainSceneEnterType = EnterTypeList.ROLEPROPERTY_ENTER
                -- end
                MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
                
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
--装备合成接口
function pieceMsgLayer:onCombinationResult(result)
    endLoading()
    if result.result==1 then
        showTips("合成成功")
        self.callback()
        self:removeSelf()
    else
        showTips(result.msg)
    end
end
--进入关卡
function pieceMsgLayer:onEnterBlockResult(result)
    endLoading()
    if result["result"]==1 then
        MainSceneEnterType = EnterTypeList.EQUIPMENT_ENTER

        srv_userInfo["areaId"] = ToAreaId
        local areamap = g_blockMap.new(ToAreaId, ToBlockId, nil, true)
        areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
        
    else
        showTips(result.msg)
    end
end

function pieceMsgLayer:caculateGuidePos(_guideId)
    print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 12305 ==_guideId then
        if 12305==_guideId then
            g_node = self.guideBtn
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        end
        
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return pieceMsgLayer