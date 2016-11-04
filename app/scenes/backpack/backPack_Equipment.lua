

BackPack_Equipment = class("BackPack_Equipment", function()
	local layer = display.newLayer()
        layer:setNodeEventEnabled(true)
        return layer
	end)
--背包
local curTypeBp=1
local BackPackBox
local useData = {}
--背包返回值
bpFightBackTmpId = nil 

--部件
local sortItem = {}
decomposeList = {}
local curDecompIdx = 1
local masklayer
local curType=101
local itemlistbox
local carEpt_Right
local equipmentPanel
local equipmentBox
--部件返回的值
g_eptType = nil
g_EptFightBackCompoundId = nil

local delNewList = {} --查看后要删除新物品表的索引

BackPack_Equipment.Instance = nil
BackPack_Equipment_Instance = nil
function BackPack_Equipment:ctor()
    BackPack_Equipment_Instance = self
    MenuLayerFlag = 1
    curTypeBp = 1
    curType = 101

    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    --tab背包，部件
    self.lunzi = {}
    for i=1,3 do
        self.lunzi[i] = {}
        self.lunzi[i] = display.newSprite("common/common_lunzi.png")
        :addTo(self,1)
        :pos(180+(i-1)*246,display.cy-360+580)
        local lunziMid = display.newSprite("common/common_lunzimid.png")
        :addTo(self,1)
        :pos(180+(i-1)*246,display.cy-360+580)
    end

    --添加背包
    self.BackPackLayer = cc.uiloader:load("CCStudio/BackPack.ExportJson")
    :addTo(self)
    BackPackBox = cc.uiloader:seekNodeByName(self.BackPackLayer,"equipmentBox")
    BackPackBox:setPositionY(BackPackBox:getPositionY()-display.cy+360)
    for i=1,4 do
        local menu = cc.uiloader:seekNodeByName(BackPackBox,"menu"..i)
        menu:onButtonClicked(function(event)
            for j=1,4 do
                local menu2 = cc.uiloader:seekNodeByName(BackPackBox,"menu"..j)
                menu2:setButtonEnabled(true)
                -- menu2:setLocalZOrder(4-j)
                menu2:getChildByTag(10):setTexture("SingleImg/BackPack/bp/grayIcon"..j..".png")
                menu2:getChildByTag(11):setTexture("SingleImg/BackPack/bp/name2_"..j..".png")
            end
            menu:setButtonEnabled(false)
            -- menu:setLocalZOrder(5)
            menu:getChildByTag(10):setTexture("SingleImg/BackPack/bp/icon"..i..".png")
            menu:getChildByTag(11):setTexture("SingleImg/BackPack/bp/name"..i..".png")
            curTypeBp = i
            self:performWithDelay(function ()
                       self:updateBpListView()
            end, 0.1)
            end)
        if i==1 then
            menu:setButtonEnabled(false)
            local icon = display.newSprite("SingleImg/BackPack/bp/icon"..i..".png")
            :addTo(menu,0,10)
            :pos(-140,0)
            local name  = display.newSprite("SingleImg/BackPack/bp/name"..i..".png")
            :addTo(menu,0,11)
            :pos(-90,0)
        else
            local icon = display.newSprite("SingleImg/BackPack/bp/grayIcon"..i..".png")
            :addTo(menu,0,10)
            :pos(-140,0)
            local name  = display.newSprite("SingleImg/BackPack/bp/name2_"..i..".png")
            :addTo(menu,0,11)
            :pos(-90,0)
        end

        
    end
    self.bplv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(75, 75, 930, 337),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(BackPackBox)

    --添加部件
    self.carEptLayer = cc.uiloader:load("CCStudio/EquipmentPart.ExportJson")
    :addTo(self)
    self.carEptLayer:setVisible(false)
    equipmentBox = cc.uiloader:seekNodeByName(self.carEptLayer,"equipmentBox")
    equipmentBox:setPositionY(equipmentBox:getPositionY()-display.cy+360)
    masklayer =  UIMasklayer.new()
    :addTo(self, 2)
    local function  func()
        masklayer:setVisible(false)
    end
    masklayer:setVisible(false)
    masklayer:setOnTouchEndedEvent(func)
    -- local property = cc.uiloader:load("CCStudio/equipmentProperty.ExportJson")
    -- :addTo(masklayer)
    -- self.combt = combination.new(property)
    -- :addTo(self.carEptLayer)
    -- carEpt_Right = cc.uiloader:seekNodeByName(property,"carEptBox_left")
    -- carEpt_Right:setVisible(false)
    -- self.decomposeOutBox = cc.uiloader:seekNodeByName(property,"decomposeOutBox")
    -- self.OutlistView = cc.uiloader:seekNodeByName(self.decomposeOutBox,"listView")
    for i=1,5 do
        local m = i
        if i>2 then
            m = i + 1
        end
        local menu = cc.uiloader:seekNodeByName(equipmentBox,"menu"..m)
        menu:onButtonClicked(function(event)
            for j=1,5 do
                local n = j
                if j>2 then
                    n = j + 1
                end
                local menu2 = cc.uiloader:seekNodeByName(equipmentBox,"menu"..n)
                menu2:setButtonEnabled(true)
                -- menu2:setLocalZOrder(6-j)
                if j~=5 then
                    menu2:getChildByTag(10):setTexture("SingleImg/BackPack/grayIcon"..n..".png")
                    menu2:getChildByTag(11):setTexture("SingleImg/BackPack/name2_"..n..".png")
                end
                
            end
            menu:setButtonEnabled(false)
            -- menu:setLocalZOrder(7)
            if i~=5 then
                menu:getChildByTag(10):setTexture("SingleImg/BackPack/icon"..m..".png")
                menu:getChildByTag(11):setTexture("SingleImg/BackPack/name"..m..".png")
            end
            
            
            curType = 100+m
            if i==5 then
                curType = 306
            end
            
            -- self:updateListView()
            self:performWithDelay(function ()
                self:updateListView()
                if 4==m then --点击引擎，合成碎片，此新手引导（4？此处按钮依次为1、2、4、5，很奇怪）
                    GuideManager:_addGuide_2(12304, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
                end
                end, 0.1)
            end)
        if m==4 then
            self.guideBtn = menu
        end
        if m==1 then
            menu:setButtonEnabled(false)
            local icon = display.newSprite("SingleImg/BackPack/icon"..m..".png")
            :addTo(menu,0,10)
            :pos(-130,0)
            local name  = display.newSprite("SingleImg/BackPack/name"..m..".png")
            :addTo(menu,0,11)
            :pos(-80,0)
        elseif m==6 then
            local icon = display.newSprite("SingleImg/BackPack/grayIcon"..m..".png")
            :addTo(menu,0,10)
            :pos(-130,0)

            local label = cc.ui.UILabel.new({UILabelType = 2, text = "改造", size = 28, color = cc.c3b(254, 234, 196)})
            :addTo(menu,0,11)
            :align(display.CENTER, -80,0)
        else
            local icon = display.newSprite("SingleImg/BackPack/grayIcon"..m..".png")
            :addTo(menu,0,10)
            :pos(-130,0)
            local name  = display.newSprite("SingleImg/BackPack/name2_"..m..".png")
            :addTo(menu,0,11)
            :pos(-80,0)
        end
        
    end

    self.BpTabBt1 = cc.ui.UIPushButton.new({
        normal = "SingleImg/BackPack/bp/tabBt.png",
        disabled = "SingleImg/BackPack/bp/tabBtSelect.png"
        })
    :addTo(self,1)
    :pos(300,display.cy-360+600)
    :onButtonClicked(function(event)
        self.BpTabBt1:setButtonEnabled(false)
        self.BpTabBt2:setButtonEnabled(true)
        self.img1:setTexture("SingleImg/BackPack/bp/humanSelect.png")
        self.img2:setTexture("SingleImg/BackPack/bp/car.png")
        self:selectTab(1)
        end)
    self.BpTabBt1:setButtonEnabled(false)
    self.img1 = display.newSprite("SingleImg/BackPack/bp/humanSelect.png")
    :addTo(self.BpTabBt1)
    self.BpTabBt2 = cc.ui.UIPushButton.new({
        normal = "SingleImg/BackPack/bp/tabBt.png",
        disabled = "SingleImg/BackPack/bp/tabBtSelect.png"
        })
    :addTo(self,1)
    :pos(550,display.cy-360+600)
    :onButtonClicked(function(event)
        self.BpTabBt1:setButtonEnabled(true)
        self.BpTabBt2:setButtonEnabled(false)
        self.img1:setTexture("SingleImg/BackPack/bp/human.png")
        self.img2:setTexture("SingleImg/BackPack/bp/carSelect.png")
        self:selectTab(2)
        GuideManager:_addGuide_2(12303, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
        end)
    self.img2 = display.newSprite("SingleImg/BackPack/bp/car.png")
    :addTo(self.BpTabBt2)

    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(75, 75, 930, 337),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(equipmentBox)
    


    local backBt = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self,100)
    :align(display.TOP_LEFT, 0, display.height)
    -- backBt:setAnchorPoint(0,1)
    backBt:onButtonClicked(function(event)
        setIgonreLayerShow(true)
        local _scene = cc.Director:getInstance():getRunningScene()
        GuideManager:_addGuide_2(20201, _scene,handler(_scene,_scene.caculateGuidePos))
        setIgonreLayerShow(false)
        display.getRunningScene():refreshEquipmentRedPoint()
        self:removeFromParent()
        GuideManager:removeGuideLayer()
        end)
    self.backBt = backBt
    
    self:performWithDelay(function ()
        self:updateBpListView()
        end, 0.1)

    GuideManager:_addGuide_2(12302, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
end
function BackPack_Equipment:onEnter()
    BackPack_Equipment.Instance = self
    self:getRedPoint()
end
function BackPack_Equipment:onExit()
    BackPack_Equipment.Instance = nil
    BackPack_Equipment_Instance = nil
end
function BackPack_Equipment:selectTab(nIdx)
    for i=1,3 do
        local rota = cc.RotateBy:create(0.3, 180)
        local action = cc.Repeat:create(rota,2)
        self.lunzi[i]:runAction(action)
    end
    if nIdx==1 then
        self:performWithDelay(function ()
                self.BackPackLayer:setVisible(true)
                self.carEptLayer:setVisible(false)
                self:updateBpListView()
            end, 0.1)
    elseif nIdx==2 then
        self:performWithDelay(function ()
                self.BackPackLayer:setVisible(false)
                self.carEptLayer:setVisible(true)
                self:updateListView()
            end, 0.1)
        
    end
end
function getBpItemByType(mType)
    -- print("mType:"..mType)
    local itemTable = {}
    for i,value in pairs(srv_carEquipment["bp"]) do
        local tmpVal = value
        tmpVal.isnew = 0 --判断是否是新的物品
        if g_BPNewItems[tmpVal.id]~=nil then
            tmpVal.isnew = 1
        end
        -- for j,val in pairs(g_BPNewItems) do
        --     if tmpVal.tmpId==val.tmpId then
        --         tmpVal.isnew = 1
        --         break
        --     end
        -- end
        local localItem = itemData[tmpVal["tmpId"]]
        -- print(tmpVal["tmpId"])
        if mType==1 and (localItem["type"]==301 or localItem["type"]==302 or localItem["type"]==307 or localItem["type"]==600) then --材料
            -- print("111")
            table.insert(itemTable,tmpVal)
        elseif mType==2 and (localItem["type"]==303 or localItem["type"]==304 or localItem["type"]==305 or localItem["type"]==700
            or localItem["type"]==701 or localItem["type"]==702 or tmpVal.tmpId==WANMENG_TMPID or tmpVal.tmpId==ITEM_ENERGY ) then --消耗品
            -- print("222")
            table.insert(itemTable,tmpVal)
        elseif mType==3 and (localItem["type"]==801 or localItem["type"]==802 or localItem["type"]==803) then --镜片
            -- print("333")
            table.insert(itemTable,tmpVal)
        elseif mType==4 and localItem["type"]==107 then --特种弹
            -- print("444")
            table.insert(itemTable,tmpVal)
        elseif mType==306 and localItem["type"]==306 then
            -- print("555")
            table.insert(itemTable,tmpVal)
        end
    end
    --物品排序
    function sortfunc(a,b)
        if a.isnew==b.isnew then --新获得装备提前
            if getItemStar(a.tmpId)==getItemStar(b.tmpId) then
                return a.tmpId<b.tmpId
            else
                return getItemStar(a.tmpId)>getItemStar(b.tmpId)
            end
        else
            return a.isnew>b.isnew
        end
    end
    table.sort(itemTable,sortfunc)
    -- printTable(itemTable)
    return itemTable
end
function BackPack_Equipment:getLensComItem() --获取可合成镜片
    local comItem = {}
    for i,value in pairs(combinationData) do
        local mType2 = getItemType(i)
        if mType2 == 801 or mType2 == 802 or mType2 == 803 then
            table.insert(comItem,value)
        end
    end
    function sortfunc(a,b)
        return getItemStar(a.compoundId)>getItemStar(b.compoundId)
    end
    table.sort(comItem,sortfunc)
    return comItem
end
function BackPack_Equipment:updateBpListView()
    self.bplv:removeAllItems()

    self:getRedPoint()
    local itemTable = {}
    itemTable = getBpItemByType(curTypeBp)
    --所有可合成的镜片
    local OthersItem = self:getLensComItem()
    
    
    
    local lineCnt --listView，每个Item有几列
    if curTypeBp==3 then
        lineCnt = 3
        local removePos = {}
        for i,value in ipairs(OthersItem) do
            local pieceArr=lua_string_split(value.piece,":")
            local piceCombiData = getPieceCombination(value.compoundId)
            local peiceByTmpid = {}
            peiceByTmpid = getPieceByTmpId()
            local curPieceNum
            if peiceByTmpid[pieceArr[1]+0]==nil then
                curPieceNum = 0 
            else
                curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
            end
           
            local per = (curPieceNum+piceCombiData.maxOmniCount)/pieceArr[2]
            if per>=1 then
                print("可合成的装备提前")
                local insertValue = {}
                insertValue.tmpId = value.compoundId
                insertValue.wareTmpId = 0
                insertValue.per = 1
                table.insert(itemTable,1,insertValue)
                table.insert(removePos,i)
            end
        end
        for i=#removePos,1,-1 do
            table.remove(OthersItem,removePos[i])
        end
    else
        lineCnt = 6
    end

    for i=1,math.ceil(#itemTable/lineCnt) do
        local item = self.bplv:newItem()
        local content = display.newNode()

        for j=1,lineCnt do
            local value = itemTable[j+(i-1)*lineCnt]
            if value==nil then
                break
            end

            if getItemType(value.tmpId)>=801 and getItemType(value.tmpId)<=803 then --镜片和装备一样显示
                -- print(value.tmpId)
                local localItem = itemData[value.tmpId]

                    local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemBox.png")
                    :addTo(content)
                    :pos(310*(j-2),0)
                    itemBt:setTouchSwallowEnabled(false)
                    itemBt:setScale(1.15)
                    itemBt:onButtonClicked(function(event)
                        if value.per==1 then
                            if getItemType(value.tmpId)==104 and  GuideManager:checkOpenFunction(GuideManager.needCheck.piece) then
                                showTips("暂未开放")
                                return
                            end
                            g_EptFightBackCompoundId = combinationData[value.tmpId].compoundId
                            local piceCombiData = getPieceCombination(combinationData[value.tmpId].compoundId)
                            local piecwMsg = g_pieceMsgLayer.new(piceCombiData,handler(self,self.updateBpListView))
                            :addTo(MainScene_Instance,50,1012)
                            return
                        else
                            g_lensMsg.new(value,localItem,handler(self,self.updateBpListView))
                            :addTo(MainScene_Instance,50)
                        end
                        end)
                    local iconImg = createItemIcon(value.tmpId)
                    :addTo(itemBt)
                    :pos(-81,1)
                    iconImg:setScale(0.79)
                    --新获得的物品图标
                    if g_BPNewItems[value.id]~=nil then
                        display.newSprite("SingleImg/BackPack/bp/newIcon.png")
                        :addTo(iconImg,1)
                        :pos(-45,45)
                    end
                    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                    :addTo(itemBt)
                    :pos(40,32)
                    name:setAnchorPoint(0.5,0.5)
                    name:setString(localItem.name)

                    if value.per==1 then
                        -- printTable(value)
                        local img = display.newSprite("SingleImg/BackPack/canComb.png")
                        :addTo(itemBt)
                        :pos(45,-20)
                    else
                       local starNum = getItemStar(value.tmpId)
                        for i=1,starNum do
                            local star = display.newSprite("common/common_Star.png")
                            :addTo(itemBt)
                            :pos(-45+(i*30), -32)
                            star:setScale(0.9)
                        end 
                    end
                
            else
                local iconImg = createItemIcon(value.tmpId,value.cnt,true)
                :addTo(content)
                :pos(-78*5+(j-1)*155,0)
                iconImg:setTouchSwallowEnabled(false)
                iconImg:onButtonClicked(function(event)
                    bpFightBackTmpId = value.tmpId
                    g_combinationLayer.new(value.tmpId,handler(self,self.updateBpListView),101)
                    :addTo(MainScene_Instance,50)
                    end)
                --新获得的物品图标
                if g_BPNewItems[value.id]~=nil then
                    local newImg = display.newSprite("SingleImg/BackPack/bp/newIcon.png")
                    :addTo(iconImg,1)
                    :pos(-45,45)
                    if getItemType(value.tmpId)==500 or getItemType(value.tmpId)==600 then
                        newImg:setPositionX(-10)
                    end
                end
            end

        end
        item:addContent(content)
        item:setItemSize(930, 150)
        self.bplv:addItem(item)
    end

    if curTypeBp==3 then
        --分割线
        local item = self.bplv:newItem()
        local content = display.newNode()
        local line = display.newSprite("SingleImg/BackPack/line.png")
        :addTo(content)
        :pos(-930/4-35,0)
        line:setScale(0.4)
        local line2 = display.newSprite("SingleImg/BackPack/line.png")
        :addTo(content)
        :pos(930/4+35,0)
        line2:setScale(0.4)
        local labelTip = cc.ui.UILabel.new({UILabelType = 2, text = "以下镜片未获得", size = 22})
        :addTo(content)
        labelTip:setAnchorPoint(0.5,0.5)
        item:addContent(content)
        item:setItemSize(930, 100)
        self.bplv:addItem(item)
        --镜片碎片
        for i=1,math.ceil(#OthersItem/3) do
            local item = self.bplv:newItem()
            local content = display.newNode()
            for j=1,3 do
                local lcoalItem = OthersItem[j+(i-1)*3]
                if lcoalItem==nil then
                else
                    g_EptFightBackCompoundId = lcoalItem.compoundId
                    local piceCombiData = getPieceCombination(lcoalItem.compoundId)
                    local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemBox.png")
                    :addTo(content)
                    :pos(310*(j-2),0)
                    
                    itemBt:setTouchSwallowEnabled(false)
                    itemBt:setScale(1.15)
                    itemBt:onButtonClicked(function(event)
                        -- print(lcoalItem.compoundId)
                        -- self:combiFunc(piceCombiData)
                        printTable(piceCombiData)
                        g_pieceMsgLayer.new(piceCombiData,handler(self,self.updateListView))
                        :addTo(MainScene_Instance,50)
                        end)
                    -- print(lcoalItem.id)
                    local pieceArr=lua_string_split(lcoalItem.piece,":")
                    local iconImg = createItemIcon(lcoalItem.compoundId)
                    :addTo(itemBt)
                    :pos(-81,0)
                    iconImg:setScale(0.79)
                    --新获得的物品图标
                    if piceCombiData.result~=0 and g_BPNewItems[piceCombiData.value.id]~=nil then
                        local newImg = display.newSprite("SingleImg/BackPack/bp/newIcon.png")
                        :addTo(iconImg,1)
                        :pos(-45,45)
                    end

                    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                    :addTo(itemBt)
                    :pos(50,32)
                    name:setAnchorPoint(0.5,0.5)
                    name:setString(itemData[lcoalItem.compoundId].name)
                    -- name:setColor(cc.c3b(0, 255, 0))
                    local numper = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
                    :addTo(itemBt)
                    :pos(47,-20)
                    numper:setAnchorPoint(0.5,0.5)
                    local peiceByTmpid = {}
                    peiceByTmpid = getPieceByTmpId()
                    local curPieceNum
                    if peiceByTmpid[pieceArr[1]+0]==nil then
                        curPieceNum = 0 
                    else
                        curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
                    end
                    -- numper:setString((curPieceNum).."/"..pieceArr[2])
                    numper:setString("碎片收集")
                    local progress1 = display.newSprite("SingleImg/BackPack/numProgress1.png")
                    :addTo(itemBt)
                    :pos(-28,-35)
                    progress1:setAnchorPoint(0,0.5)
                    local per = (curPieceNum+piceCombiData.maxOmniCount)/pieceArr[2]
                    if per>=1 then
                        per = 1
                        local comBt = cc.ui.UIPushButton.new(
                            {normal = "SingleImg/BackPack/combinationBt.png",
                            pressed = "SingleImg/BackPack/combinationBt_down.png"})
                        :addTo(itemBt)
                        :pos(45,-20)
                        comBt:setScale(0.5)
                        comBt:onButtonClicked(function(event)
                            startLoading()
                            comData={}--全局
                            comData["itTmpId"] = lcoalItem.compoundId+0
                            m_socket:SendRequest(json.encode(comData), CMD_COMBINATION, self, self.onCombinationResult)
                            end)
                        local img = display.newSprite("SingleImg/BackPack/canComb.png")
                        :addTo(comBt)
                        img:setScale(1.3)
                        numper:setVisible(false)
                        progress1:setVisible(false)
                    else

                        local progress2 = cc.Sprite:create("SingleImg/BackPack/numProgress2.png",cc.rect(0,0,151*(per),9))
                        :addTo(itemBt)
                        :pos(-28,-35)
                        progress2:setAnchorPoint(0,0.5)
                    end
                    
                end
            end

            item:addContent(content)
            item:setItemSize(930, 140)
            self.bplv:addItem(item)
        end
    end

    delNewList = {}
    -- print(curTypeBp)
    for j,val in pairs(g_BPNewItems) do
        local mType = itemData[val["tmpId"]].type
        if curTypeBp==1 and (mType==301 or mType==302 or mType==307 or mType==600) then
            table.insert(delNewList,val.id)
        elseif curTypeBp==2 and (mType==303 or mType==304 or mType==305 or mType==700 or mType==701 or mType==702 or val.tmpId==WANMENG_TMPID or val.tmpId==ITEM_ENERGY ) then --消耗品
            table.insert(delNewList,val.id)
        elseif curTypeBp==3 and (mType==801 or mType==802 or mType==803) then --辅助
            table.insert(delNewList,val.id)
        elseif curTypeBp==3 and mType==500 and 
            (math.modf(val.tmpId/10000)==801 or math.modf(val.tmpId/10000)==802 or math.modf(val.tmpId/10000)==803)  then
            print("del tmpId:"..val.id)
            table.insert(delNewList,val.id)
        elseif curTypeBp==4 and mType==107 then --特种弹
            table.insert(delNewList,val.id)
        end
    end
    -- print("----delNewList-----")
    -- printTable(delNewList)
    -- print("----g_BPNewItems-----")
    -- printTable(g_BPNewItems)
    --查看到删除新的物品
    for i,val in pairs(delNewList) do
        -- print("刪除")
        -- print(val)
        if g_BPNewItems[val]~=nil then
            g_BPNewItems[val]=nil
        end
        -- table.remove(g_BPNewItems, val)
    end
    -- printTable(g_BPNewItems)
    -- saveLocalGameDataBykey("BPNewItems", g_BPNewItems)
    self.bplv:reload()
end
--部件函数
function BackPack_Equipment:getItemByType(mType)
    local itemTable = {}
    for i,value in pairs(srv_carEquipment["item"]) do
        local tmpVal = value
        tmpVal.isnew = 0 --判断是否是新的物品
        if g_BPNewItems[value.id]~=nil then
            tmpVal.isnew = 1
        end

        local localItem = itemData[tmpVal["tmpId"]]
        if localItem["type"]==mType then
            table.insert(itemTable,tmpVal)
        end
    end
    --物品排序
    function sortfunc(a,b)
        if a.isnew==b.isnew then --新获得装备提前
            if (a.wareTmpId==0 and b.wareTmpId==0) or (a.wareTmpId~=0 and b.wareTmpId~=0) then
                if getItemStar(a.tmpId)==getItemStar(b.tmpId) then
                    if (a.tmpId)==(b.tmpId) then
                        return (a.advLvl)>(b.advLvl)
                    else
                        return a.tmpId>b.tmpId
                    end
                else
                    return getItemStar(a.tmpId)>getItemStar(b.tmpId)
                end
            else
                return a.wareTmpId>b.wareTmpId
            end
        else
            return a.isnew>b.isnew
        end
    end
    table.sort(itemTable,sortfunc)


    return itemTable
end
function BackPack_Equipment:getCombinationItem(mtype)
    local comItem = {}
    for i,value in pairs(combinationData) do
        local tmpVal = value
        local mType2 = getItemType(i)
        if mType2 == mtype then
            table.insert(comItem,value)
        end
    end
    function sortfunc(a,b)
        return getItemStar(a.compoundId)>getItemStar(b.compoundId)
    end
    table.sort(comItem,sortfunc)
    -- printTable(comItem)
    return comItem
end
function BackPack_Equipment:updateListView()
    print("更新了列表")
    self.lv:removeAllItems()
    self:getRedPoint()


    local itemTable = {}
    if curType==306 then
        itemTable = getBpItemByType(curType)
    else
        itemTable = self:getItemByType(curType)
    end
    

    --可合成的装备提前
    -- local canComItem = {}
    local OthersItem = {}
    OthersItem = self:getCombinationItem(curType)
    local removePos = {}
    for i,value in ipairs(OthersItem) do
        local pieceArr=lua_string_split(value.piece,":")
        local piceCombiData = getPieceCombination(value.compoundId)
        local peiceByTmpid = {}
        peiceByTmpid = getPieceByTmpId()
        local curPieceNum
        if peiceByTmpid[pieceArr[1]+0]==nil then
            curPieceNum = 0 
        else
            curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
        end
       
        local per = (curPieceNum+piceCombiData.maxOmniCount)/pieceArr[2]
        if per>=1 then
            print("可合成的装备提前")
            local insertValue = {}
            insertValue.tmpId = value.compoundId
            insertValue.wareTmpId = 0
            insertValue.per = 1
            table.insert(itemTable,1,insertValue)
            table.insert(removePos,i)
        end
    end
    for i=#removePos,1,-1 do
        table.remove(OthersItem,removePos[i])
    end


   -- print("size:"..#itemTable)
   for i=1,math.ceil(#itemTable/3) do
        local item = self.lv:newItem()
        local content = display.newNode()

        for j=1,3 do
            local value = itemTable[j+(i-1)*3]
            if value==nil then
                -- local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemNullBox.png")
                -- :addTo(content)
                -- :pos(310*(j-2),0)
                -- itemBt:setTouchSwallowEnabled(false)
                -- itemBt:setScale(1920/1280)
            else
                local localItem={}
                localItem=itemData[value["tmpId"]]

                local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemBox.png")
                :addTo(content)
                :pos(310*(j-2),0)
                if i==1 and j==1 then
                    self.guideBtn_1 = itemBt
                end
                itemBt:setTouchSwallowEnabled(false)
                itemBt:setScale(1.15)
                itemBt:onButtonClicked(function(event)
                    -- self:showBPMsgBox()
                    -- self:reloadBPBoxData(value)
                    if value.per==1 then 
                        if getItemType(value.tmpId)==104 and  GuideManager:checkOpenFunction(GuideManager.needCheck.piece) then
                            showTips("暂未开放")
                            return
                        end
                        g_EptFightBackCompoundId = combinationData[value.tmpId].compoundId
                        local piceCombiData = getPieceCombination(combinationData[value.tmpId].compoundId)
                        local piecwMsg = g_pieceMsgLayer.new(piceCombiData,handler(self,self.updateListView))
                        :addTo(MainScene_Instance,50,1012)

                        print("添加引导12305，引导点击合成")
                        GuideManager:_addGuide_2(12305, display.getRunningScene(),handler(piecwMsg,piecwMsg.caculateGuidePos))
                        -- showMessageBox("是否合成？", function()
                        --     startLoading()
                        --     comData={}--全局
                        --     comData["itTmpId"] = value.tmpId
                        --     m_socket:send2SocketServer(m_socket:constructSendData(json.encode(comData), CMD_COMBINATION))
                        --     end)
                        return
                    end
                    if curType==306 then
                        bpFightBackTmpId = value.tmpId
                        g_combinationLayer.new(value.tmpId,handler(self,self.updateBpListView),101)
                        :addTo(MainScene_Instance,50)
                    else
                        local isSuit = false 
                        if localItem.suitID~=0 then
                            isSuit = true
                        end
                        g_carEquipmentLayer.new(value,localItem,1,handler(self,self.updateListView),isSuit)
                        :addTo(MainScene_Instance,50)
                    end
                    
                    end)
                local iconImg
                if curType==306 then
                    iconImg = createItemIcon(value.tmpId, value.cnt)
                else
                    iconImg = createItemIcon(value.tmpId)
                end
                iconImg:addTo(itemBt)
                iconImg:pos(-81,1)
                iconImg:setScale(0.79)

                local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(40,32)
                name:setAnchorPoint(0.5,0.5)
                name:setString(localItem.name)

                if value.per==1 then
                    -- printTable(value)
                    local img = display.newSprite("SingleImg/BackPack/canComb.png")
                    :addTo(itemBt)
                    :pos(45,-20)
                else
                   local starNum = getItemStar(value.tmpId)
                    for i=1,starNum do
                        local star = display.newSprite("common/common_Star.png")
                        :addTo(itemBt)
                        :pos(-45+(i*30), -32)
                        star:setScale(0.9)
                    end 
                end

                --新获得的物品图标
                if g_BPNewItems[value.id]~=nil then
                    display.newSprite("SingleImg/BackPack/bp/newIcon.png")
                    :addTo(iconImg,1)
                    :pos(-45,45)
                end

                if curType~=306 and value["wareTmpId"]~=0 then
                    --装备于图标
                    display.newSprite("SingleImg/BackPack/eptImg.png")
                    :addTo(iconImg)
                    :pos(20, -35)

                    local eptAbove = cc.ui.UILabel.new({UILabelType = 2, text = "装备于", size = 18})
                    :addTo(itemBt)
                    :pos(-25, -5)
                    eptAbove:setColor(cc.c3b(255, 255, 0))
                    eptAbove:setString(carData[value["wareTmpId"]]["name"])
                end
            end
            
        end

        item:addContent(content)
        item:setItemSize(930, 140)
        self.lv:addItem(item)
    end

    local item = self.lv:newItem()
    local content = display.newNode()
    local line = display.newSprite("SingleImg/BackPack/line.png")
    :addTo(content)
    :pos(-930/4-35,0)
    line:setScale(0.4)
    local line2 = display.newSprite("SingleImg/BackPack/line.png")
    :addTo(content)
    :pos(930/4+35,0)
    line2:setScale(0.4)
    local labelTip = cc.ui.UILabel.new({UILabelType = 2, text = "以下装备未获得", size = 22})
    :addTo(content)
    labelTip:setAnchorPoint(0.5,0.5)
    item:addContent(content)
    item:setItemSize(930, 100)
    self.lv:addItem(item)

    
    -- printTable(OthersItem)
    for i=1,math.ceil(#OthersItem/3) do
        local item = self.lv:newItem()
        local content = display.newNode()

        for j=1,3 do
            local lcoalItem = OthersItem[j+(i-1)*3]
            if lcoalItem==nil then
                -- local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemNullBox.png")
                -- :addTo(content)
                -- :pos(310*(j-2),0)
                -- itemBt:setTouchSwallowEnabled(false)
                -- itemBt:setScale(1920/1280)
            else
                g_EptFightBackCompoundId = lcoalItem.compoundId
                local piceCombiData = getPieceCombination(lcoalItem.compoundId)
                local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemBox.png")
                :addTo(content)
                :pos(310*(j-2),0)
                
                itemBt:setTouchSwallowEnabled(false)
                itemBt:setScale(1.15)
                itemBt:onButtonClicked(function(event)
                    -- print(lcoalItem.compoundId)
                    -- self:combiFunc(piceCombiData)

                    g_pieceMsgLayer.new(piceCombiData,handler(self,self.updateListView))
                    :addTo(MainScene_Instance,50)
                    end)
                -- print(lcoalItem.id)
                local pieceArr=lua_string_split(lcoalItem.piece,":")
                self.dc_pieceArr = pieceArr
                local iconImg = createItemIcon(lcoalItem.compoundId)
                :addTo(itemBt)
                :pos(-81,0)
                iconImg:setScale(0.79)
                --新获得的物品图标
                if piceCombiData.result~=0 and g_BPNewItems[piceCombiData.value.id]~=nil then
                    display.newSprite("SingleImg/BackPack/bp/newIcon.png")
                    :addTo(iconImg,1)
                    :pos(-45,45)
                end

                local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(50,32)
                name:setAnchorPoint(0.5,0.5)
                name:setString(itemData[lcoalItem.compoundId].name)
                -- name:setColor(cc.c3b(0, 255, 0))
                local numper = cc.ui.UILabel.new({UILabelType = 2, text = "进度", size = 20})
                :addTo(itemBt)
                :pos(-20,-20)
                local peiceByTmpid = {}
                peiceByTmpid = getPieceByTmpId()
                local curPieceNum
                if peiceByTmpid[pieceArr[1]+0]==nil then
                    curPieceNum = 0 
                else
                    curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
                end
                -- numper:setString((curPieceNum).."/"..pieceArr[2])
                local per = (curPieceNum+piceCombiData.maxOmniCount)/pieceArr[2]
                --进度
                cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, 
                    text = (curPieceNum+piceCombiData.maxOmniCount).."/"..pieceArr[2], size = 20})
                :addTo(itemBt)
                :pos(25,-20)

                local progress1 = display.newSprite("SingleImg/BackPack/numProgress1.png")
                :addTo(itemBt)
                :pos(-28,-35)
                progress1:setAnchorPoint(0,0.5)
                
                if per>=1 then
                    per = 1
                    local comBt = cc.ui.UIPushButton.new(
                        {normal = "SingleImg/BackPack/combinationBt.png",
                        pressed = "SingleImg/BackPack/combinationBt_down.png"})
                    :addTo(itemBt)
                    :pos(45,-20)
                    comBt:setScale(0.5)
                    comBt:onButtonClicked(function(event)
                        startLoading()
                        comData={}--全局
                        comData["itTmpId"] = lcoalItem.compoundId+0
                        m_socket:SendRequest(json.encode(comData), CMD_COMBINATION, self, self.onCombinationResult)
                        end)
                    local img = display.newSprite("SingleImg/BackPack/canComb.png")
                    :addTo(comBt)
                    img:setScale(1.3)
                    numper:setVisible(false)
                    progress1:setVisible(false)
                else

                    local progress2 = cc.Sprite:create("SingleImg/BackPack/numProgress2.png",cc.rect(0,0,151*(per),9))
                    :addTo(itemBt)
                    :pos(-28,-35)
                    progress2:setAnchorPoint(0,0.5)
                end
                
            end
        end

        item:addContent(content)
        item:setItemSize(930, 140)
        self.lv:addItem(item)
    end
   self.lv:reload()

    delNewList = {}
    for j,val in pairs(g_BPNewItems) do
        local mType = itemData[val["tmpId"]].type
        if mType==500 then
            local pieceType = math.floor(val.tmpId/10000)
            if pieceType==curType then --碎片
                table.insert(delNewList,val.id)
            end
        elseif curType==mType then --整装
            table.insert(delNewList,val.id)
        end
    end
    -- print("----delNewList-----")
    -- printTable(delNewList)
    -- print("----g_BPNewItems-----")
    -- printTable(g_BPNewItems)
    --查看到删除新的物品
    for i,val in ipairs(delNewList) do
        -- print("刪除2")
        -- print(val)
        if g_BPNewItems[val]~=nil then
            g_BPNewItems[val]=nil
        end
        -- table.remove(g_BPNewItems, val)
    end
    -- saveLocalGameDataBykey("BPNewItems", g_BPNewItems)
end

--使用返回接口
function BackPack_Equipment:onUseItem(result)
    endLoading()
    if result.result==1 then
        srv_carEquipment["bp"][useData.id].cnt = srv_carEquipment["bp"][useData.id].cnt - 1
        self:updateListView()
        local outstr = itemData[useData.tmpId].output
        local outArr = lua_string_split(outstr,"#")
        if (outArr[1]+0)==1 then
            srv_userInfo.gold = srv_userInfo.gold + outArr[2]
            mainscenetopbar:setGlod()
        elseif (outArr[1]+0)==2 then
            srv_userInfo.energy = srv_userInfo.energy + outArr[2]
            SetEnergyAndCountDown(srv_userInfo.energy)
        end
        local dc_item = itemData[useData.tmpId]
        if dc_item then
            DCItem.consume(tostring(dc_item.id), dc_item.name, 1, "使用可消耗物品")
        end
    else
        showTips(result.msg)
    end
end
--人类装备，战车装备小红点
function BackPack_Equipment:getRedPoint()
    print("BackPack_Equipment:getRedPoint")

    for i=1,4 do
        local menu = cc.uiloader:seekNodeByName(BackPackBox,"menu"..i)
        if menu:getChildByTag(100) then
            menu:removeChildByTag(100)
        end
    end

    local menu1 = cc.uiloader:seekNodeByName(equipmentBox,"menu1")
    if menu1:getChildByTag(100) then
        menu1:removeChildByTag(100)  
    end
    local menu2 = cc.uiloader:seekNodeByName(equipmentBox,"menu2")
    if menu2:getChildByTag(100) then
        menu2:removeChildByTag(100)
    end
    local menu4 = cc.uiloader:seekNodeByName(equipmentBox,"menu4")
    if menu4:getChildByTag(100) then
        menu4:removeChildByTag(100)
    end
    local menu5 = cc.uiloader:seekNodeByName(equipmentBox,"menu5")
    if menu5:getChildByTag(100) then
        menu5:removeChildByTag(100)
    end
    local menu6 = cc.uiloader:seekNodeByName(equipmentBox,"menu6")
    if menu6:getChildByTag(100) then
        menu6:removeChildByTag(100)
    end

    if bAllEquipmentCanCom(101) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(menu1,0,100)
        :pos(-40,25)
    end
    if bAllEquipmentCanCom(102) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(menu2,0,100)
        :pos(-40,25)
    end
    if bAllEquipmentCanCom(104) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(menu4,0,100)
        :pos(-40,25)
    end
    if bAllEquipmentCanCom(105) then
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(menu5,0,100)
        :pos(-40,25)
    end


    --判断新增物品在哪儿（人类装备/战车装备）
    local isManEptRed,isCarEptRed = false, false
    --人类道具红点数，战车道具红点数
    local manRedNum, carRedNum = 0, 0 
    -- print("#g_BPNewItems:"..(#g_BPNewItems))
    printTable(g_BPNewItems)
    for i,value in pairs(g_BPNewItems) do
        -- print(value.tmpId)
        local mType = getItemType(value.tmpId)
        -- print("mType:"..mType)
        if (mType>=101 and mType<=106) or mType==500 or mType==306 then --战车装备需要红点
            -- carRedNum = carRedNum + 1
            if not isCarEptRed then
                isCarEptRed = true
            end
            local pieceType = 0
            if mType==500 then
                pieceType = math.floor(value.tmpId/10000)
            end
            -- print("mType:"..mType)
            -- print("pieceType:"..pieceType)
            local menu
            if mType==101 or pieceType==101 then
                menu = cc.uiloader:seekNodeByName(equipmentBox,"menu1")
            elseif mType==102 or pieceType==102 then
                menu = cc.uiloader:seekNodeByName(equipmentBox,"menu2")
            elseif mType==104 or pieceType==104 then
                menu = cc.uiloader:seekNodeByName(equipmentBox,"menu4")
            elseif mType==105 or pieceType==105 then
                menu = cc.uiloader:seekNodeByName(equipmentBox,"menu5")
            elseif mType==306 or pieceType==306 then
                menu = cc.uiloader:seekNodeByName(equipmentBox,"menu6")
            elseif pieceType==801 or pieceType==802 or pieceType==803 then --辅助
                menu = cc.uiloader:seekNodeByName(BackPackBox,"menu3")
            else

            end
            menu:removeChildByTag(100)
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(menu,0,100)
            :pos(-40,25)
        else
            -- manRedNum = manRedNum + 1
            if not isManEptRed then
                isManEptRed = true
            end
            --类型分页上的红点
            local menu
            if mType==301 or mType==302 or mType==307 or mType==600 then --材料
                menu = cc.uiloader:seekNodeByName(BackPackBox,"menu1")
            elseif mType==303 or mType==304 or mType==305 or mType==700 or mType==701 or mType==702 or value.tmpId==WANMENG_TMPID or value.tmpId==ITEM_ENERGY then --消耗品
                menu = cc.uiloader:seekNodeByName(BackPackBox,"menu2")
            elseif mType==801 or mType==802 or mType==803 then --辅助
                menu = cc.uiloader:seekNodeByName(BackPackBox,"menu3")
            elseif mType==107 then --特种弹
                menu = cc.uiloader:seekNodeByName(BackPackBox,"menu4")
            end
            menu:removeChildByTag(100)
            local RedPt = display.newSprite("common/common_RedPoint.png")
            :addTo(menu,0,100)
            :pos(-40,25)
        end
    end

    local node = self.BpTabBt2
    node:removeChildByTag(10)
    if bAllEquipmentCanCom() or isCarEptRed then --战车装备添加红点
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(110,25)
    end


    local node = self.BpTabBt1
    node:removeChildByTag(10)
    if isManEptRed then --人类装备添加红点
        local RedPt = display.newSprite("common/common_RedPoint.png")
        :addTo(node,0,10)
        :pos(110,25)
    end

end
--装备合成接口
function BackPack_Equipment:onCombinationResult(result)
    endLoading()
    if result.result==1 then
        showTips("合成成功")
        self:updateListView()
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
    else
        showTips(result.msg)
    end
end

function BackPack_Equipment:caculateGuidePos(_guideId)
    print("-------------------------指引ID：".._guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 12302 ==_guideId or 12303 ==_guideId or 12304 ==_guideId or 12306 ==_guideId then
        if 12302==_guideId then
            g_node = self.BpTabBt2
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        elseif 12303==_guideId then
            g_node = self.guideBtn
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(-size.width/2,0))
        elseif 12304==_guideId then
            g_node = self.guideBtn_1
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(0,0))
        elseif 12306==_guideId then
            g_node = self.backBt
            size = g_node.sprite_[1]:getContentSize()
            midPos = g_node:convertToWorldSpace(cc.p(size.width/2,-size.height/2))
        end
        
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return BackPack_Equipment