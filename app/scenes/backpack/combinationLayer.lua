-- 101:主炮 102:副炮 103:se炮 104:引擎 105:cDev 106:工具 107:特种弹
-- 108：军号 109:普通弹
-- 201：武器 202：帽子 203：衣服 204：手套 205：鞋子 206：护甲
-- 301：进阶材料 302：制造书
-- 303：职业材料 
-- 500：装备碎片
-- 600：材料碎片
-- 700：可使用物品
EQUIP_TYPE = {}
EQUIP_TYPE.TOUSE = 700

--对应道具表output字段
OUTPUT_TYPE = {}
OUTPUT_TYPE.GOLD = 1   --金币
OUTPUT_TYPE.ENERGY = 2 --燃油
OUTPUT_TYPE.ITEM = 3   --物品
OUTPUT_TYPE.DIAMOND=4  --钻石

combinationLayer_Instance = nil

local combinationLayer = class("combinationLayer", function()
	local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
	end)
local masklayer
local cur_value
-- local combLine = {}
local ToBlockId = nil --跳转的关卡ID
local ToAreaId = nil
function combinationLayer:onEnter()

end
function combinationLayer:onExit()
    self:performWithDelay(function ()
        self.comfinishFunc()
        combinationLayer_Instance = nil
    end,0.01)
end
function combinationLayer:ctor(tmpId,comfinishFunc,enterType,flag)
    combinationLayer_Instance = self
    if enterType~=nil then
        print("enterType:"..enterType)
    end

    comfinishFunc = comfinishFunc or (function()end)
    
	masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --材料信息框
    self.comInfoBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(self.comInfoBox)

    
	-- local combinationBox = cc.uiloader:load("CCStudio/combinationBox.ExportJson")
	-- :addTo(self,1)
	-- self.comInfoBox = cc.uiloader:seekNodeByName(combinationBox, "comInfoBox")
	-- self.comTree = cc.uiloader:seekNodeByName(combinationBox, "comTree")
	-- masklayer:addHinder(self.comInfoBox)
    self:createCombinationBox(tmpId,comfinishFunc,enterType,flag)
end

function combinationLayer:createCombinationBox(tmpId,comfinishFunc,enterType,flag)
    self.enterType = enterType
    g_comBackTmpId = tmpId
    self.comfinishFunc = comfinishFunc
    self.flag = flag
	local localItem = itemData[tmpId]
	cur_value = get_SrvBackPack_Value(tmpId)
	local cnt
	if cur_value == nil then
		cnt = 0
	else
		cnt = cur_value.cnt
	end
    self.cnt = cnt
	self.comInfoBox:removeAllChildren()
    --返回按钮
    if (not self.comTree) or (not self.comTree:isVisible()) then
        self.backBt = createCloseBt()
        :addTo(masklayer,2)
        :pos(self.comInfoBox:getPositionX() + self.comInfoBox:getContentSize().width/2+15,
                self.comInfoBox:getPositionY() + self.comInfoBox:getContentSize().height/2-32)
        :onButtonClicked(function(event)
            if enterType==102 then
                self.comfinishFunc()
            end
            self:removeSelf()
            end)
    end
    

    local msgBox = self.comInfoBox
    --图标
    local icon = createItemIcon(tmpId)
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
    local starNum = getItemStar(tmpId)
    for i=1,starNum do
        local star = display.newSprite("common/common_Star.png")
        :addTo(msgBox)
        :pos(34*i+170,msgBox:getContentSize().height - 95)
    end

    --等级
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "拥有：", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 135)
    label:setAnchorPoint(0,0.5)
    label:setColor(cc.c3b(248, 204, 45))

    self.have = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(label:getPositionX()+label:getContentSize().width,msgBox:getContentSize().height - 135-2)
    self.have:setAnchorPoint(0,0.5)
    self.have:setString(cnt)


    --底框1
    local msgPart = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,150))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2+40)

    --描述
    local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22,color=cc.c3b(131, 149, 165)})
    :addTo(msgPart)
    :pos(10,msgPart:getContentSize().height-10)
    des:setString(localItem["des"])
    des:setAnchorPoint(0,1)
    des:setWidth(420)
    des:setLineHeight(30)


    self.comBt = createGreenBt2("获得", 1.2)
    :addTo(self.comInfoBox)
    :pos(self.comInfoBox:getContentSize().width/2, 70)
    :onButtonClicked(function(event)
        if self.comTree then
            self.comTree:removeSelf()
            self.comTree = nil
        end
        --合成和获取框
        self.comTree =  display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
                display.cy-30,
                cc.size(500, 606),cc.rect(119, 127, 1, 1))
        :addTo(masklayer)
        self.comInfoBox:setPositionX(display.cx -self.comInfoBox:getContentSize().width/2)
        self.comTree:setPositionX(display.cx + self.comInfoBox:getContentSize().width/2)
        event.target:setButtonEnabled(false)
        event.target:setColor(cc.c3b(128, 128, 128))
        if self.comBt2 then
            self.comBt2:setButtonEnabled(true)
            self.comBt2:setColor(cc.c3b(255, 255, 255))
        end
        

        g_combLine = {}
        self:performWithDelay(function ()
                       self:showItemComb(tmpId)
            end, 0.01)

        self.backBt:setPositionX(self.comInfoBox:getPositionX() + self.comInfoBox:getContentSize().width/2*3-20)
    end)


    if combinationData[tmpId]==nil then
        self.comBt:getButtonLabel():setString("获得")
    else
        self.comBt:getButtonLabel():setString("合成")
    end

    --判断材料可分解或者是碎片可合成（增加一个按钮）
    if localItem.carEngOut>0 then --可分解
        self.comBt:setPositionX(self.comInfoBox:getContentSize().width/4)
        self.comBt2 = createGreenBt2("分解", 1.2)
        :addTo(self.comInfoBox)
        :pos(self.comInfoBox:getContentSize().width/4*3, 70)
        :onButtonClicked(function(event)
            self:decomposeBox(tmpId)
            end)
    elseif getItemType(tmpId)==600 then   --可合成
        self.comBt:setPositionX(self.comInfoBox:getContentSize().width/4)
        self.comBt2 = createGreenBt2("合成", 1.2)
        :addTo(self.comInfoBox)
        :pos(self.comInfoBox:getContentSize().width/4*3, 70)
        :onButtonClicked(function(event)
            --碎片的合成
            if self.comTree then
                self.comTree:removeSelf()
                self.comTree = nil
            end
            
            self.comTree =  display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
                    display.cy-30,
                    cc.size(500, 606),cc.rect(119, 127, 1, 1))
            :addTo(masklayer)
            self.comInfoBox:setPositionX(display.cx -self.comInfoBox:getContentSize().width/2)
            self.comTree:setPositionX(display.cx + self.comInfoBox:getContentSize().width/2)
            event.target:setButtonEnabled(false)
            event.target:setColor(cc.c3b(128, 128, 128))
            self.comBt:setButtonEnabled(true)
            self.comBt:setColor(cc.c3b(255, 255, 255))

            g_combLine = {}
            self:performWithDelay(function ()
                local tpId = tmpId - getItemType(tmpId)
                           self:showItemComb(tpId)
                end, 0.01)

            self.backBt:setPositionX(self.comInfoBox:getPositionX() + self.comInfoBox:getContentSize().width/2*3-20)
            end)
    end
    

    --宝箱等可使用物品
    if math.modf(localItem.type/100)==7 then
        self.comBt:setPositionX(100)
        -- self.comBt:setScale(0.8)
        self.getBt = createGreenBt2("使用", 1.2)
        :addTo(self.comInfoBox)
        :pos(self.comInfoBox:getContentSize().width/2, 70)
        -- :scale(0.8)
        :onButtonClicked(function(event)
            if srv_userInfo.level<localItem.minLvl then
                showTips(localItem.minLvl.."级可使用该礼包")
                return
            end
            if localItem.type==701 then --选择礼包 
                self:selectLeftBox(localItem, 1)
            else
                startLoading()
                sendData={}
                sendData["itemId"] = cur_value.id
                sendData["num"] = 1
                m_socket:SendRequest(json.encode(sendData), CMD_USEITEM, self, self.onUseItem)
            end
            
        end)


        --一键使用
        self.allgetBt = createGreenBt2("一键使用", 1.2)
        :addTo(self.comInfoBox)
        :pos(self.comInfoBox:getContentSize().width-100, 70)
        -- :scale(0.8)
        :onButtonClicked(function(event)
            if srv_userInfo.level<localItem.minLvl then
                showTips(localItem.minLvl.."级可使用该礼包")
                return
            end
            if localItem.type==701 then --选择礼包
                self:selectLeftBox(localItem, cnt)
            else
                startLoading()
                sendData={}
                sendData["itemId"] = cur_value.id
                sendData["num"] = cnt
                m_socket:SendRequest(json.encode(sendData), CMD_USEITEM, self, self.onUseItem)
            end
            
        end)
    end

    if self.flag==1 or self.flag==2 then --背包，属性界面返回进入
        self.comTree = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
            display.cy-30,
            cc.size(500, 606),cc.rect(119, 127, 1, 1))
        :addTo(masklayer)
        self.comInfoBox:setPositionX(display.cx -self.comInfoBox:getContentSize().width/2)
        self.comTree:setPositionX(display.cx + self.comInfoBox:getContentSize().width/2)
        self.comBt:setButtonEnabled(false)
        self.comBt:setColor(cc.c3b(128, 128, 128))
        self.backBt:setPositionX(self.comInfoBox:getPositionX() + self.comInfoBox:getContentSize().width/2*3-20)
        
        self:performWithDelay(function ()
                        self:showItemComb(g_combLine[#g_combLine])
            end, 0.01)
        if self.enterType==101 then
            MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
        elseif self.enterType==102 then
            MainSceneEnterType = EnterTypeList.ROLEPROPERTY_ENTER
        elseif self.enterType==103 then
            MainSceneEnterType = EnterTypeList.CARPROPERTY_ENTER
        end
        local areamap = g_blockMap.new(ToAreaId, ToBlockId, nil, true)
        areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
            -- cc.Director:getInstance():getRunningScene():setMainMenuVisible(false)
            
        -- if next(srv_blockData)~=nil and srv_userInfo["areaId"]==ToAreaId then
        --     print("当前区")
        --     local areamap = g_blockMap.new(ToAreaId, ToBlockId)
        --     areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
        --     -- cc.Director:getInstance():getRunningScene():setMainMenuVisible(false)
        --     if self.enterType==101 then
        --         MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
        --     elseif self.enterType==102 then
        --         MainSceneEnterType = EnterTypeList.ROLEPROPERTY_ENTER
        --     end
        -- else
        --     print("其他区")
        --     startLoading()
        --     sendAreaList = getSendAreaList(ToAreaId)
        --     local SelectAreaData={}
        --     SelectAreaData["characterId"]=srv_userInfo["characterId"]
        --     SelectAreaData["areaId"]=sendAreaList
        --     m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
        -- end
    end



end

function combinationLayer:selectLeftBox(localItem,num)
    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self, 10)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --材料信息框
    local box = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(600, 406),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(box)

    local backBt = createCloseBt()
        :addTo(box,2)
        :pos(box:getContentSize().width+15, box:getContentSize().height-15)
        :onButtonClicked(function(event)
            masklayer:removeSelf()
            end)

    cc.ui.UILabel.new({UILabelType = 2, text = "请选择以下一种物品进行使用", size = 25})
    :addTo(box)
    :align(display.CENTER, box:getContentSize().width/2, box:getContentSize().height-50)

    print(localItem.output)
    local outArr = string.split(localItem.output, "|")
    local minVip
    local itemList = {}
    for i,v in ipairs(outArr) do
        if i==1 then
            minVip = tonumber(v)
        else
            local arr = string.split(v, "#")
            local value = {}
            if tonumber(arr[1])==1 then
                value.templateID = GAINBOXTPLID_GOLD
            elseif tonumber(arr[1])==2 then
                value.templateID = GAINBOXTPLID_STRENGTH
            elseif tonumber(arr[1])==5 then
                value.templateID = GAINBOXTPLID_DIAMOND
            elseif tonumber(arr[1])==4 then
                value.templateID = tonumber(arr[3])
            end
            value.num = tonumber(arr[2])
            table.insert(itemList, value)
        end
    end


    local scrollWidth = 532
    local scrollHeight = 150

  local scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 255, 0, 0))
  scrollNode:setContentSize(scrollWidth, scrollHeight)
  scrollNode:pos(35, 150)

  --勾选图标
  local myHook= nil
  local function createHook(parentNode)
    if myHook then
        myHook:removeSelf()
    end
    myHook = display.newSprite("common2/com_hook.png")
    :addTo(parentNode)
  end

  local selIdx = 0
  for i,value in ipairs(itemList) do
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18})
    :addTo(scrollNode)
    :align(display.CENTER,(i-1)*120+50, scrollHeight/2-60)

    local pIcon
    if value.templateID<100 then
      pIcon = cc.ui.UIPushButton.new("itemBox/box_1.png")
      :addTo(scrollNode)
      :pos((i-1)*120+50, scrollHeight/2)
      :onButtonPressed(function(event) event.target:setScale(0.98) end)
      :onButtonRelease(function(event) event.target:setScale(1.0) end)
      :onButtonClicked(function(event)
        selIdx = i
        createHook(event.target)
        end)

      cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = value.num, size = 16})
      :addTo(pIcon,10)
      :align(display.CENTER_RIGHT, 40, -35)
    end
    if value.templateID==GAINBOXTPLID_GOLD then
      display.newSprite("common/common_GoldGetBg.png")
      :addTo(pIcon)
      name:setString("金币")
      -- :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_DIAMOND then
      display.newSprite("common/common_DiamondBg.png")
      :addTo(pIcon)
      name:setString("钻石")
      -- :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_STRENGTH then
      display.newSprite("common/common_StaminaBg.png")
      :addTo(pIcon)
      name:setString("燃油")
      -- :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    else
      local item = createItemIcon(value.templateID, value.num, true)
      :addTo(scrollNode)
      :pos((i-1)*120+50, scrollHeight/2)
      :scale(0.8)
      :onButtonClicked(function(event)
        selIdx = i
        createHook(event.target)
        end)
      name:setString(itemData[value.templateID].name)
    end
  end
  

  --物品列表
  local desView = cc.ui.UIScrollView.new {
      -- bgColor = cc.c4b(200, 0, 0, 120),
      viewRect = cc.rect(35, 150, scrollWidth, scrollHeight),
      direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
      }
      :addTo(box)
      :addScrollNode(scrollNode)

    --确定按钮
    local bt = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(box)
    :pos(box:getContentSize().width/2, 70)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "确 定", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
        if selIdx==0 then
            showTips("请先选择一个物品")
            return 
        end
        startLoading()
        sendData={}
        sendData["itemId"] = cur_value.id
        sendData["num"] = num
        sendData["idx"] = selIdx
        m_socket:SendRequest(json.encode(sendData), CMD_USEITEM, self, self.onUseItem)
        masklayer:removeSelf()
        end)

end
    

function combinationLayer:showItemComb(tmpId)
    -- print("bbbbbb")
	self.comTree:removeAllChildren()

    if combinationData[tmpId]==nil then
        self:createBlock(tmpId)
    else
        self:createPiece(tmpId)
    end

    local tmpCom = g_combLine
    g_combLine = {}
    for i,value in ipairs(tmpCom) do
        if value~=tmpId then
            table.insert(g_combLine,value)
        else
            break
        end
    end
    table.insert(g_combLine,tmpId)
    
	
	for i=1,#g_combLine do
		local icon = createItemIcon(g_combLine[i],nil,true)
		:addTo(self.comTree,1)
		:pos(70+(i-1)*80,self.comTree:getContentSize().height-55)
		icon:setScale(0.6)
        icon:onButtonClicked(function(event)
            self:performWithDelay(function ()
                       self:showItemComb(g_combLine[i])
            end, 0.01)
            end)
		if i==#g_combLine then
			local curDown = display.newSprite("SingleImg/BackPack/comb/curDown.png")
			:addTo(icon)
			:pos(0,-80)
		end
	end
	local line = display.newSprite("SingleImg/BackPack/comb/titleLine.png")
	:addTo(self.comTree)
	:pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 100)
	
	
end
--通过碎片合成
function combinationLayer:createPiece(tmpId)
	print("have piece")

    local titleLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2,self.comTree:getContentSize().height - 120)
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

	local comIcon = createItemIcon(tmpId)
	:addTo(self.comTree)
	:pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 200)

    -- local UpArrow  = display.newSprite("common/common_UpArrow.png")
    -- :addTo(self.comTree)
    -- :pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 320)
    --底框
    local midPart = display.newScale9Sprite("equipment/equipmentImg7.png",nil,nil,cc.size(445,230),cc.rect(222,100,1,1))
    :addTo(self.comTree)
    :pos(self.comTree:getContentSize().width/2, 225)

	local pieceStr = combinationData[tmpId].piece

	-- print(pieceStr)
	local pieceArr = lua_string_split(pieceStr,"|")
    self.dc_pieceArr = pieceArr
	-- print("pieceArr size:"..#pieceArr)
	for i=1,#pieceArr do
		pieceArr[i] = lua_string_split(pieceArr[i],":")
	end

	if #pieceArr==1 then
        local pieceIcon = createItemIcon(pieceArr[1][1]+0,nil,true)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2, self.comTree:getContentSize().height - 395)
            pieceIcon:setScale(0.8)
            pieceIcon:onButtonClicked(function(evnet)
                self:performWithDelay(function ()
                       self:showItemComb(pieceArr[1][1]+0)
                end, 0.01)
                end)
            local numBar = display.newScale9Sprite("common/common_Frame8.png",self.comTree:getContentSize().width/2,
                140,
                cc.size(95, 30),cc.rect(10,10,30,30))
            :addTo(self.comTree)
            local numPer = getComNumPer(pieceArr[1][1]+0,pieceArr[1][2]+0)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2, 140)

	elseif #pieceArr==2 then
        for i=1,2 do
            printTable(pieceArr[i])
            local pieceIcon = createItemIcon(pieceArr[i][1]+0,nil,true)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2 -70 + (i-1)*140, self.comTree:getContentSize().height - 395)
            pieceIcon:setScale(0.8)
            pieceIcon:onButtonClicked(function(evnet)
                self:performWithDelay(function ()
                       self:showItemComb(pieceArr[i][1]+0)
                end, 0.01)
                end)
            local numBar = display.newScale9Sprite("common/common_Frame8.png",self.comTree:getContentSize().width/2 -70 + (i-1)*140,
                140,
                cc.size(95, 30),cc.rect(10,10,30,30))
            :addTo(self.comTree)
            local numPer = getComNumPer(pieceArr[i][1]+0,pieceArr[i][2]+0)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2 -70 + (i-1)*140, 140)
        end
	elseif #pieceArr==3 then
        for i=1,3 do
            -- printTable(pieceArr[i])
            local pieceIcon = createItemIcon(pieceArr[i][1]+0,nil,true)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2 -100 + (i-1)*100, self.comTree:getContentSize().height - 395)
            pieceIcon:setScale(0.8)
            pieceIcon:onButtonClicked(function(evnet)
                self:performWithDelay(function ()
                       self:showItemComb(pieceArr[i][1]+0)
                end, 0.01)
                end)
            local numBar = display.newScale9Sprite("common/common_Frame8.png",self.comTree:getContentSize().width/2 -100  + (i-1)*100,
                140,
                cc.size(95, 30),cc.rect(10,10,30,30))
            :addTo(self.comTree)
            local numPer = getComNumPer(pieceArr[i][1]+0,pieceArr[i][2]+0)
            :addTo(self.comTree)
            :pos(self.comTree:getContentSize().width/2 -100 + (i-1)*100, 140)
        end
	end

	-- local buttomLine = display.newSprite("SingleImg/BackPack/comb/bar.png")
	-- :addTo(self.comTree)
	-- :pos(self.comTree:getContentSize().width/2, 140)

    --合成按钮
	local combBt = createGreenBt2("合成", 1.2)
	:addTo(self.comTree)
	:pos(self.comTree:getContentSize().width/2, 60)
    :onButtonClicked(function(event)
        startLoading()
        comData={}--全局
        comData["characterId"] = srv_userInfo["characterId"]
        comData["itTmpId"] = tmpId
        m_socket:SendRequest(json.encode(comData), CMD_COMBINATION, self, self.onCombinationResult)
        
        end)
end
--通过关卡获取
function combinationLayer:createBlock(tmpId)
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
    :pos(self.comTree:getContentSize().width/2, 60)
    :onButtonClicked(function(event)
        if #g_combLine<=1 then
            self.comTree:setVisible(false)
            self.comInfoBox:setPositionX(display.cx)
            self.comTree:setPositionX(display.cx)
            self.comBt:setButtonEnabled(true)
            self.comBt:setColor(cc.c3b(255, 255, 255))
            -- self.comBt2:setButtonEnabled(true)
            -- self.comBt2:setColor(cc.c3b(255, 255, 255))
        else
            table.remove(g_combLine)
            self:performWithDelay(function ()
                       self:showItemComb(g_combLine[#g_combLine])
            end, 0.01)
        end
        if not self.comTree:isVisible() then
            self.backBt:setPositionX(self.comInfoBox:getPositionX() + self.comInfoBox:getContentSize().width/2-20)
        end
        
        end)

    if next(blockList)==nil then
        local txt = "剧情、自动售货机或各类\n商店中获得"
        if ITEM_ENERGY==tmpId then
            txt = "分解完整材料、道具或\n战车装备获得"
        elseif STARSTONE_ID==tmpId then
            txt = "夜晚世界BOSS、军团商店、\n各类活动中获得"
        elseif RESET_TMPID==tmpId then
            txt = "竞技场中兑换获得"
        elseif itemData[tmpId].type==701 or itemData[tmpId].type==702 then
            txt = "在各类活动中获得"
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
                if self.enterType==101 then
                    MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
                elseif self.enterType==102 then
                    MainSceneEnterType = EnterTypeList.ROLEPROPERTY_ENTER
                elseif self.enterType==103 then
                    MainSceneEnterType = EnterTypeList.CARPROPERTY_ENTER
                end
                
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

function getItemBlock(itemTmpId)
	-- print(itemTmpId)
    local blockList = {}
    for k,value in pairs(blockData) do
        -- if value.id==22006005 then
        --     print(value.rewardItem)
        -- end
        if value~="null" and value.areaId~=0 and value.type~=3 and value.ctype==1 then
            local rewardItem=lua_string_split(value.rewardItems,"|")
            for i=1,#rewardItem do
                rewardItem[i]=lua_string_split(rewardItem[i],":")
                if (rewardItem[i][1]+0)==itemTmpId then
                    table.insert(blockList,k)
                    break
                end
            end
        end
    end
    
    blockList = getSortBlocksData(blockList)
    --精英关卡三个普通关卡三个
    local tmpBlockList = {}
    local mormalCnt, eliteCnt = 0, 0
    for i,value in ipairs(blockList) do
        if value.type==1 and mormalCnt<3 then
            mormalCnt = mormalCnt + 1
            table.insert(tmpBlockList,value)
        elseif value.type==2 and eliteCnt<3 then
            eliteCnt = eliteCnt + 1
            table.insert(tmpBlockList,value)
        end
        if mormalCnt>=3 and eliteCnt>=3 then
            break
        end
    end
    -- for i=#blockList,7,-1 do
    --     table.remove(blockList, i)
    -- end
    -- print("blockList+++++++++++++++=")
    -- printTable(blockList)
    blockList = tmpBlockList
    return blockList
end

function combinationLayer:onCombinationResult(result) --装备合成
    endLoading()
    if result["result"]==1 then
        showTips("合成成功！")
        if #g_combLine>1 then
            table.remove(g_combLine)
        end
        self:performWithDelay(function ()
                       self:showItemComb(g_combLine[#g_combLine])
            end, 0.01)
        
        cur_value = get_SrvBackPack_Value(g_comBackTmpId)
        local cnt
        if cur_value == nil then
            cnt = 0
        else
            cnt = cur_value.cnt
        end
        self.have:setString(cnt)

        if self.comfinishFunc then
            self:performWithDelay(function ()
                self.comfinishFunc()
            end,0.01)
        end
        if self.dc_pieceArr~="" and self.dc_pieceArr~=nil then
            local arr1 = string.split(self.dc_pieceArr,"|")
            for i=1,#arr1 do
                local arr2 = string.split(arr1[i],":")
                local dc_item = itemData[arr2[1]]
                if dc_item then
                    DCItem.consume(tostring(dc_item.id), dc_item.name, arr2[2], "装备合成消耗碎片")
                end
            end
        end

        local dc_item = itemData[g_comBackTmpId]
        if dc_item then --如果奖励为道具
            DCItem.get(tostring(dc_item.id), dc_item.name, 1, "碎片合成")
        end
    else
        showTips(result.msg)
        -- self.comfinishFunc()
    end
end
--进入关卡
function combinationLayer:onEnterBlockResult(result)
    endLoading()
    if result["result"]==1 then
        if self.enterType==101 then
            print("EnterTypeList.GETEQUIPMENT_ENTER 111")
            MainSceneEnterType = EnterTypeList.GETEQUIPMENT_ENTER
        elseif self.enterType==102 then
            MainSceneEnterType = EnterTypeList.ROLEPROPERTY_ENTER
        elseif self.enterType==103 then
                    MainSceneEnterType = EnterTypeList.CARPROPERTY_ENTER
        end

        srv_userInfo["areaId"] = ToAreaId
        local areamap = g_blockMap.new(ToAreaId, ToBlockId, nil, true)
        areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
    else
        showTips(result.msg)
    end
end
--物品使用
function combinationLayer:onUseItem(result)
    endLoading()
    if result.result==1 then
        -- self:performWithDelay(function ()
        --         self.comfinishFunc()
        --     end,0.01)
        self.comfinishFunc() 

        -- local itemType = result.data.type
        -- local num = result.data.outNum
        local itemArr = result.data.item

        local items = {}
        if result.data.addGold>0 then
            srv_userInfo.gold = srv_userInfo.gold + result.data.addGold
            mainscenetopbar:setGlod()
            DCCoin.gain("金币宝箱 ","金币",result.data.addGold,srv_userInfo.gold)
            table.insert(items, {templateID=GAINBOXTPLID_GOLD, num=result.data.addGold})
        end
        if  result.data.addDia>0 then
            srv_userInfo.diamond = srv_userInfo.diamond + result.data.addDia
            mainscenetopbar:setDiamond()
            print(srv_userInfo.diamond)
            table.insert(items, {templateID=GAINBOXTPLID_DIAMOND, num=result.data.addDia})
        end
        if result.data.addEng>0 then
            srv_userInfo.energy = srv_userInfo.energy + result.data.addEng
            SetEnergyAndCountDown(srv_userInfo.energy)
            mainscenetopbar:setEnergy()
            table.insert(items, {templateID=GAINBOXTPLID_STRENGTH, num=result.data.addEng})
        end
        
        if #itemArr>0 then
            for k,v in pairs(itemArr) do
                table.insert(items, {templateID=v.tmpId, num=v.cnt})
                local dc_item = itemData[v.tmpId]
                if dc_item then --如果奖励为道具
                    DCItem.get(tostring(dc_item.id), dc_item.name, tonumber(v.cnt), "开启了神秘宝箱:")
                end
            end
        end

        GlobalShowGainBox(nil, items)
        -- relf:removeSelf()
        if get_SrvBackPack_Value(g_comBackTmpId)==nil then
            self:removeSelf()
        else
            local dc_item = itemData[g_comBackTmpId]
            if dc_item then
                DCItem.consume(tostring(dc_item.id), dc_item.name, 1, "使用可消耗物品")
            end
            self:createCombinationBox(g_comBackTmpId,self.comfinishFunc,self.enterType,self.flag)
        end
        
    else
        showTips(result.msg)
    end
end

--材料分解
function combinationLayer:decomposeBox(tmpId)
    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    self.decomasklayer = masklayer
    local cangetItLabel = nil

    local box = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(600,400),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    local tmpsize = box:getContentSize()

    local backBt = createCloseBt()
    :addTo(box)
    :pos(tmpsize.width-10, tmpsize.height-10)
    :onButtonClicked(function()
        masklayer:removeSelf()
        end)

    cc.ui.UILabel.new({UILabelType = 2, text = "请选择分解数量", size = 30})
    :addTo(box)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-48)


    local selectNum = 1
    local curNum = self.cnt
    --进度条
    local bar = display.newSprite("common2/improve2_img51.png")
    :addTo(box)
    :align(display.CENTER, tmpsize.width/2, tmpsize.height-120)
    local ProBar1 = cc.ui.UILoadingBar.new({image = "common2/improve2_img49.png", viewRect = cc.rect(0,0,381,37)})
    :addTo(bar)
    :align(display.LEFT_BOTTOM,0, 0)
    ProBar1:setPercent(selectNum/curNum*100)
    local proNum1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "1/"..curNum, size = 25})
    :addTo(bar,2)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-3)
    local retNode1 = setLabelStroke(proNum1,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)

    local function updateAddNum(flag)
        if flag then
            selectNum = math.min(selectNum + 1, curNum)
        else
            selectNum = math.max(selectNum - 1, 1)
        end
        local per = selectNum/curNum*100
        ProBar1:setPercent(per)
        proNum1:setString(selectNum.."/"..curNum)
        setLabelStrokeString(proNum1, retNode1)

        local num = itemData[tmpId].carEngOut*selectNum
        cangetItLabel:setString(num)
    end

    --加减数量按钮
    local addHandle,deHandle
    local releaseFlag = false
    cc.ui.UIPushButton.new("common2/com2_img_35.png")
    :addTo(box)
    :pos(75,tmpsize.height-120)
    :onButtonPressed(function(event) 
        event.target:setScale(0.98) 
        releaseFlag = false
        transition.execute(event.target,cc.DelayTime:create(0.5),
            {onComplete = function()
                if releaseFlag==false and deHandle==nil then
                    deHandle = scheduler.scheduleGlobal(function() updateAddNum(false) end, 0.1)
                end
            end,
            })
        end)
    :onButtonRelease(function(event) 
        event.target:setScale(1.0) 
        releaseFlag = true
        if deHandle then
            scheduler.unscheduleGlobal(deHandle)
            deHandle = nil
        end
        end)
    :onButtonClicked(function(event)
        updateAddNum(false)
        end)

    cc.ui.UIPushButton.new("common2/com2_img_36.png")
    :addTo(box)
    :pos(tmpsize.width - 75,tmpsize.height-120)
    :onButtonPressed(function(event)
        event.target:setScale(0.98) 
        releaseFlag = false
        transition.execute(event.target,cc.DelayTime:create(0.5),
            {onComplete = function()
                if releaseFlag==false and addHandle==nil then
                    addHandle = scheduler.scheduleGlobal(function() updateAddNum(true) end, 0.1)
                end
            end,
            })
        end)
    :onButtonRelease(function(event) 
        event.target:setScale(1.0) 
        releaseFlag = true
        if addHandle then
            scheduler.unscheduleGlobal(addHandle)
            addHandle = nil
        end
        
        end)
    :onButtonClicked(function(event)
        if addHandle then
            scheduler.unscheduleGlobal(addHandle)
            addHandle = nil
        end
        updateAddNum(true)
        end)


    --可获得能源
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "可获得能源     ：", size = 30})
    :addTo(box)
    :pos(80, tmpsize.height/2)

    display.newSprite("Item/item_5005502.png")
    :addTo(box)
    :pos(255, tmpsize.height/2)
    :scale(0.6)

    local num = itemData[tmpId].carEngOut
    cangetItLabel = cc.ui.UILabel.new({UILabelType = 2, text = num, size = 30, color = cc.c3b(234, 85, 20)})
    :addTo(box)
    :pos(label:getPositionX()+label:getContentSize().width, tmpsize.height/2)

    local maxBt = createYellowBt("最 大")
    :addTo(box)
    :pos(tmpsize.width/4, 70)
    :onButtonClicked(function(event)
        selectNum = self.cnt
        updateAddNum(true)
        end)

    local decoBt = createBlueBt("分 解")
    :addTo(box)
    :pos(tmpsize.width/4*3, 70)
    :onButtonClicked(function(event)
        local itemList = {}
        local data = {}
        data.id = cur_value.id
        data.cnt = selectNum
        table.insert(itemList,data)
        startLoading()
        local sendData={}
        sendData["itemList"] = itemList
        m_socket:SendRequest(json.encode(sendData), CMD_DECOMPOSE, self, self.onDecomposeResult)
        end)
end
function combinationLayer:onDecomposeResult(result) --分解
    endLoading()
    if result["result"]==1 then
        self.comfinishFunc()
        -- showTips("分解成功")
        mainscenetopbar:setGlod()
        createDecomposeBox(cur_value,result.data.gold)

        self.decomasklayer:removeSelf()

        if get_SrvBackPack_Value(cur_value.tmpId)==nil then
            self:removeSelf()
        else
            local dc_item = itemData[cur_value.tmpId]
            self:createCombinationBox(cur_value.tmpId,self.comfinishFunc,self.enterType,self.flag)
        end
    else
        showTips(result.msg)
    end
end

return combinationLayer