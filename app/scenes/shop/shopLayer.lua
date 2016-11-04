
local shopLayer = class("shopLayer", function()
	local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
	end)

local refreshTimePoint = {
    9,12,18,24
}
local Refresh_107Point = {
    2,4,6,8,10,12,14,16,18,20,22,24
}
local wordText = {
    "现在生意好难做，价格这么低还要搞优惠。",
    "其实我喜欢乔伊很久了。",
    "不想当镇长的商店老板不是好的赏金猎人。",
    "我有几个姐妹长得都一样，每个镇的商店都被我们承包了。",
    "我现在想发展一下其他生意，想要进行一次众筹。你要不要资助一下？"
}
local FIXGOOD_TMPID = 1075005
g_thisIsOtherTime = false --普通商店刷新另一个商店
otherTimeData = nil


local masklayer
local localToSrv = 0
dTime = nil
local refCnt = 0 --刷新次数
local refId = 0
local timeHandle
local curValue
local curItem
local refFlag = 0
local refAuto = 1
--------------
g_shopPointTs = 0
local shopLocalKey = ""

--============
--shopType  商店类型
function shopLayer:ctor(shopType) 
    display.addSpriteFrames("Image/shop_img.plist", "Image/shop_img.png")
    
    g_shopType=shopType

	local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    local backBt = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self)
    :pos(0,display.height)
    :onButtonClicked(function(event)
        if g_shopType==1 then
            -- self:getParent():setMainMenuVisible(true)
        end
        local _scene = display.getRunningScene()
        self:removeSelf()
        if EmbattleScene.Instance~=nil then
            EmbattleScene.Instance:InitBulletList()
        end
    end)
    backBt:setAnchorPoint(0,1)
    self.backBt = backBt
    local shopBox = display.newSprite("#shop_img1.png")
    :addTo(self,1)
    :pos(display.cx+100, display.cy-30)
    self.shopBox = shopBox

    --
    self.menu1 = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
        })
    :addTo(self.shopBox)
    :pos(150, self.shopBox:getContentSize().height-70)
    :onButtonClicked(function(event)
        if g_shopType==4 then
            event.target:setButtonEnabled(false)
            event.target:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
            self.menu2:setButtonEnabled(true)
            self.menu2:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
            g_shopType=1
            self:onEnter()
        end
        end)
    self.menu1:setButtonEnabled(false)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 27, color = cc.c3b(95, 217, 255)})
    :addTo(self.menu1,0,10)
    :align(display.CENTER, -10, 2)

    self.menu2 = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
        })
    :addTo(self.shopBox)
    :pos(350, self.shopBox:getContentSize().height-70)
    :onButtonClicked(function(event)
        if g_shopType==1 then
            event.target:setButtonEnabled(false)
            event.target:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
            self.menu1:setButtonEnabled(true)
            self.menu1:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
            g_shopType=4
            self:onEnter()
        end
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(self.menu2,0,10)
    :align(display.CENTER, -10, 2)
    if g_shopType==4 then
        self.menu1:setButtonEnabled(true)
        self.menu2:setButtonEnabled(false)
    end

    --商店老板
    local shopBoss = display.newSprite("shop/shopBoss.png")
    :addTo(self,1)
    :pos(150,0)
    shopBoss:setAnchorPoint(0.5,0)
    local wordBox = display.newSprite("shop/wordBox.png")
    :addTo(self,5)
    :pos(330,230)
    local idx = math.random(1,#wordText)
    local word  = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    :addTo(wordBox)
    :pos(10,110)
    word:setString(wordText[idx])
    word:setAnchorPoint(0,1)
    word:setWidth(240)
    transition.execute(wordBox, cc.FadeOut:create(1.0), {
        delay = 2.0,
        onComplete = function()
            wordBox:removeSelf()
        end,
    })
    transition.execute(word, cc.FadeOut:create(1.0), {
        delay = 2.0,
    })
    --剩余时间
    local restLabel = cc.ui.UILabel.new({UILabelType = 2, text = "刷新倒计时：", size = 27})
    :addTo(shopBox)
    :pos(shopBox:getContentSize().width/2+250, shopBox:getContentSize().height - 100)
    restLabel:setAnchorPoint(1,0.5)
    restLabel:setColor(cc.c3b(105, 151, 159))
    self.restTime = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "00:00:00", size = 27})
    :addTo(shopBox)
    :pos(shopBox:getContentSize().width/2+250, restLabel:getPositionY())
    self.restTime:setColor(cc.c3b(248, 182, 45))
    if g_isBanShu and (g_shopType==1 or g_shopType==4) then
        restLabel:setVisible(false)
        self.restTime:setVisible(false)
    end
    --刷新按钮
    local function okListener()
        refAuto = 0
        g_thisIsOtherTime = false
        -- g_shopPointTs = getSrvPointTimeTs(self:getCurPointTime()) --当前在哪个时间段内
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["shopType"] = g_shopType
        sendData["auto"] = 0
        m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
        startLoading()
        
    end
    local refreshBt = cc.ui.UIPushButton.new({
        normal = "common/common_GBt1.png",
        pressed = "common/common_GBt2.png"
        })
    -- :onButtonPressed(function(event) event.target:setScale(0.95) end)
    -- :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :addTo(shopBox)
    :pos(shopBox:getContentSize().width - 150, shopBox:getContentSize().height - 50)
    :onButtonClicked(function(event)
        local needCost, name
        refId = refCnt+1
        if refId>9 then
            refId = 0
        end
        if g_shopType==1 or g_shopType==4 then
            if srv_userInfo.diamond< shopRefData[refId].diamond then
                showTips("钻石不足")
                return
            end
            needCost = shopRefData[refId].diamond
            name = "钻石"
        elseif g_shopType==2 then
            if srv_userInfo.reputation< shopRefData[refId].reputation then
                showTips("声望不足")
                return
            end
            needCost = shopRefData[refId].reputation
            name = "声望"
        elseif g_shopType==3 then
            if srv_userInfo.exploit< shopRefData[refId].exploit then
                showTips("功勋不足")
                return
            end
            needCost = shopRefData[refId].exploit
            name = "功勋"
        elseif g_shopType==5 then
            if srv_userInfo.expedition< shopRefData[refId].expedition then
                showTips("远征币不足")
                return
            end
            needCost = shopRefData[refId].expedition
            name = "远征币"
        end
        showMessageBox("是否花费"..needCost..name.."引进一批新货物？", okListener)
        end)
    self.refreshImg = display.newSprite("common/common_Diamond.png")
    :addTo(refreshBt)
    :pos(-25,0)
    :scale(0.55)
    cc.ui.UILabel.new({UILabelType = 2, text = "刷新", size = 25, color = cc.c3b(116, 233, 128)})
    :addTo(refreshBt)
    :align(display.CENTER, 15,-2)
    if g_isBanShu and (g_shopType==1 or g_shopType==4) then
        refreshBt:setVisible(false)
    end

 	
 	self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(18, 30, 863, 465),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(shopBox)


    
end

function shopLayer:comFixAndRanGoods()
    local comData = {}
    -- printTable(shopGoodsInfo)
    for i,value in ipairs(shopGoodsInfo.fixGoods) do
        if value.id == FIXGOOD_TMPID then
            table.insert(comData,1,value)
        else
            table.insert(comData,value)
        end
        if shopGoodsInfo.ranGoods[i]~=ni then
            table.insert(comData,shopGoodsInfo.ranGoods[i])
        end
    end
    return comData
end
function modifyGoodsData()
    for i,value in ipairs(shopGoodsInfo.goodIds) do
        if type(value)=="number" then
            local tmp = {}
            tmp.id = value
            tmp.buy = 0
            shopGoodsInfo.goodIds[i] = tmp
        end
    end
    -- if g_shopType==4 then
    --     for i,value in ipairs(shopGoodsInfo.goodIds) do
    --         if 
    --     end
    -- end
end
function shopLayer:updateListView()
    self.lv:removeAllItems()

    -- printTable(shopGoodsInfo)

    modifyGoodsData()
    local allGoods = shopGoodsInfo.goodIds
    if #allGoods==0 then
        refAuto = 1
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["shopType"] = g_shopType
        sendData["auto"] = 1
        m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
        startLoading()
        g_shopPointTs = getSrvPointTimeTs(getCurPointTime()) --当前在哪个时间段内
        return
    end
    print("allGoods")
    printTable(allGoods)
    for i=1,math.ceil(#allGoods/2) do
        local item = self.lv:newItem()
        local content = display.newNode()
         item:addContent(content)
        item:setItemSize(230, 465)

        for j=1,2 do
            local value = allGoods[(i-1)*2+j]
            -- printTable(value)
            if value==nil then
                break
            end
            local itemBt = cc.ui.UIPushButton.new("#shop_img5.png")
                :addTo(content)
                :pos(20, 125 - 252*(j-1))
                :onButtonPressed(function(event) event.target:setScale(0.95) end)
                :onButtonRelease(function(event) event.target:setScale(1.0) end)
                itemBt:setTouchSwallowEnabled(false)
                -- itemBt:scale(1920/1280)
                itemBt:onButtonClicked(function(event)
                    if srv_userInfo.level < goodsData[value.id].level then
                        showTips("等级不够，不能购买该物品")
                        return
                    end
                    self:createMsgBox(value)
                    curItem = itemBt
                    end)
            if i==1 and j==1 then
                self.guideBtn = itemBt
            end
            if value.buy==1 then
                self:createMaskItem(itemBt)
            end
            local itemName = cc.ui.UILabel.new({UILabelType = 2, text = "name", size = 20})
            :addTo(itemBt)
            :pos(0,75)
            itemName:setAnchorPoint(0.5,0.5)
            -- print("*****************************************")
            -- print(value.id)
            -- print(goodsData[value.id].id)
            itemName:setString(itemData[goodsData[value.id].id].name)
            itemName:setColor(cc.c3b(35, 37, 40))

            local iconImg = createItemIcon(goodsData[value.id].id, goodsData[value.id].stock)
            :addTo(itemBt)
            :pos(0,5)
            :scale(0.95)

            if goodsData[value.id].diamond~=0 and (g_shopType==1 or g_shopType==4) then
                local gold = display.newSprite("common/common_Diamond.png")
                :addTo(itemBt)
                :pos(-55, -75)
                gold:setScale(0.6)
                -- gold:setScale(1280/1920*0.6)
                local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(13, -75)
                goldNum:setAnchorPoint(0.5,0.5)
                goldNum:setString(self:setGlod(goodsData[value.id].diamond))
            elseif goodsData[value.id].gold~=0 and (g_shopType==1 or g_shopType==4) then
                itemBt:setButtonImage("normal", "#shop_img6.png")
                itemBt:setButtonImage("pressed", "#shop_img6.png")
                itemBt:setButtonImage("disabled", "#shop_img6.png")

                itemName:setColor(cc.c3b(106, 57, 6))

                local gold = display.newSprite("common/common_GoldGet.png")
                :addTo(itemBt)
                :pos(-50, -72)
                gold:setScale(0.45)
                local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(13, -75)
                goldNum:setAnchorPoint(0.5,0.5)
                goldNum:setString(self:setGlod(goodsData[value.id].gold))
            elseif g_shopType==3 then
                local gold = display.newSprite("common/gongxun.png")
                :addTo(itemBt)
                :pos(-55, -75)
                gold:setScale(0.5)
                local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(20, -75)
                goldNum:setAnchorPoint(0.5,0.5)
                goldNum:setString(self:setGlod(goodsData[value.id].exploit))
            elseif g_shopType==2 then
                local gold = display.newSprite("common/shengwang.png")
                :addTo(itemBt)
                :pos(-55, -75)
                gold:setScale(0.5)
                local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(20, -75)
                goldNum:setAnchorPoint(0.5,0.5)
                goldNum:setString(self:setGlod(goodsData[value.id].reputation))
            elseif g_shopType==5 then
                local gold = display.newSprite("common/expedition.png")
                :addTo(itemBt)
                :pos(-55, -75)
                gold:setScale(0.5)
                local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(20, -75)
                goldNum:setAnchorPoint(0.5,0.5)
                goldNum:setString(self:setGlod(goodsData[value.id].expedition))  
            end

            -- self:createMaskItem(itemBt)
        end
        
       
        self.lv:addItem(item)
    end
    

	self.lv:reload()
end

function shopLayer:createMaskItem(parent)
    local maskItem = display.newSprite("#shop_img10.png")
    :addTo(parent,2)
    parent:setTouchEnabled(false)
end

function shopLayer:createMsgBox(value)
    curValue = value
    masklayer =  UIMasklayer.new()
    :addTo(self,10)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)

    local msgBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    :pos(display.cx,display.cy-50)
    -- msgBox:setScale(1920/1208)
    masklayer:addHinder(msgBox)

    local closeBt = createCloseBt()
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width+15,msgBox:getContentSize().height-32)
    -- closeBt:setScale(1280/1920)
    closeBt:onButtonClicked(function(event)
        masklayer:removeSelf()
        end)

    --图标
    local icon = createItemIcon(goodsData[value.id].id, goodsData[value.id].stock)
    :addTo(msgBox,0,1000)
    :pos(110,msgBox:getContentSize().height - 90)
    --类型
    -- local bar = display.newSprite("equipment/equipmentImg3.png")
    -- :addTo(msgBox)
    -- :pos(222,msgBox:getContentSize().height - 55)

    -- local eqtType = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    -- :addTo(bar)
    -- :pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
    -- eqtType:setAnchorPoint(0.5,0.5)
    -- eqtType:setString(itemTypeToString(goodsData[value.id].id))
    -- eqtType:setColor(cc.c3b(241, 171, 0))

    --名字
    self.name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 55)
    self.name:setAnchorPoint(0,0.5)
    self.name:setString(itemData[goodsData[value.id].id].name)
    local star = getItemStar(goodsData[value.id].id)
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
    local starNum = getItemStar(goodsData[value.id].id)
    for i=1,starNum do
        local star = display.newSprite("common/common_Star.png")
        :addTo(msgBox)
        :pos(34*i+170,msgBox:getContentSize().height - 95)
    end

    --拥有
    self.level = cc.ui.UILabel.new({UILabelType = 2, text = "拥有：", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 135)
    self.level:setAnchorPoint(0,0.5)
    self.level:setColor(cc.c3b(248, 204, 45))

    local adv, valueCnt = get_SrvBackPack_Value(goodsData[value.id].id)
    local have = 0
    if adv~=nil then
        have = valueCnt
    end
    self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(self.level:getPositionX()+self.level:getContentSize().width,msgBox:getContentSize().height - 135-2)
    self.level:setAnchorPoint(0,0.5)
    self.level:setString(have)



    local textBox = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,150))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2+50)

    self:resetProperty(textBox, value)

    local dx = 60
    local dy = 160
    local Label1 = cc.ui.UILabel.new({UILabelType = 2, text = "购买", size = 25, color = cc.c3b(132, 149, 165)})
    :addTo(msgBox)
    Label1:pos(25+dx,dy)
    Label1:setAnchorPoint(0,0.5)
    local Label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    Label2:pos(25+Label1:getContentSize().width+dx,dy)
    Label2:setAnchorPoint(0,0.5)
    Label2:setString(goodsData[value.id].stock)
    Label2:setColor(cc.c3b(255, 241, 0))
    local Label3 = cc.ui.UILabel.new({UILabelType = 2, text = "件", size = 25, color = cc.c3b(132, 149, 165)})
    :addTo(msgBox)
    Label3:pos(Label2:getPositionX()+Label2:getContentSize().width,dy)
    Label3:setAnchorPoint(0,0.5)

    if goodsData[value.id].diamond~=0 and (g_shopType==1 or g_shopType==4) then
        local gold = display.newSprite("common/common_Diamond.png")
        :addTo(msgBox)
        :pos(250+dx, dy)
        gold:setScale(0.6)
        local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(msgBox)
        :pos(250+30+dx, dy)
        goldNum:setAnchorPoint(0,0.5)
        goldNum:setString(self:setGlod(goodsData[value.id].diamond))
    elseif goodsData[value.id].gold~=0 and (g_shopType==1 or g_shopType==4) then
        local gold = display.newSprite("common/common_GoldGet.png")
        :addTo(msgBox)
        :pos(250+dx, dy)
        gold:setScale(0.6)
        local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(msgBox)
        :pos(250+30+dx, dy)
        goldNum:setAnchorPoint(0,0.5)
        goldNum:setString(self:setGlod(goodsData[value.id].gold))
    elseif g_shopType==3 then
        local gold = display.newSprite("common/gongxun.png")
        :addTo(msgBox)
        :pos(250+dx, dy)
        gold:setScale(0.6)
        local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(msgBox)
        :pos(250+30+dx, dy)
        goldNum:setAnchorPoint(0,0.5)
        goldNum:setString(self:setGlod(goodsData[value.id].exploit))
    elseif g_shopType==2 then
        local gold = display.newSprite("common/shengwang.png")
        :addTo(msgBox)
        :pos(250+dx, dy)
        gold:setScale(0.6)
        local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(msgBox)
        :pos(250+30+dx, dy)
        goldNum:setAnchorPoint(0,0.5)
        goldNum:setString(self:setGlod(goodsData[value.id].reputation))
    elseif g_shopType==5 then
        local gold = display.newSprite("common/expedition.png")
        :addTo(msgBox)
        :pos(250+dx, dy)
        gold:setScale(0.6)
        local goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(msgBox)
        :pos(250+30+dx, dy)
        goldNum:setAnchorPoint(0,0.5)
        goldNum:setString(self:setGlod(goodsData[value.id].expedition)) 
    end

    local purchaseBt = createGreenBt2("购买", 1.2)
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, 70)
    :onButtonClicked(function(event)
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["goodId"] = value.id
        sendData["shopType"] = g_shopType
        m_socket:SendRequest(json.encode(sendData), CMD_PURCHASE, self, self.onPurchase)
        startLoading()
        end)
    self.purchaseBt = purchaseBt
    
end
local Attribute_pos = {
    {x = 10, y = 130},
    {x = 10, y = 90},
    {x = 10, y = 50},
    {x = 10, y = 10},
    -- {x = 10, y = 30},

}
--属性显示
function shopLayer:resetProperty(leftBox, value)
    local item  = itemData[goodsData[value.id].id]
    for i=101,150 do
        if leftBox:getChildByTag(i) then
            leftBox:removeChildByTag(i)
        end
    end
    local pos=0
    if item.hp>0 then
        pos = pos + 1
        local HP=cc.ui.UILabel.new({UILabelType = 2, text = "血量：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        HP:setTag(102)
        local HpNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+HP:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        HpNum:setString(item.hp)
        HpNum:setTag(101)
    end
    if item.attack>0 then
        pos = pos + 1
        local Attack=cc.ui.UILabel.new({UILabelType = 2, text = "攻击：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Attack:setTag(104)
        local AttackNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Attack:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        AttackNum:setString(item.attack)
        AttackNum:setTag(103)
    end

    if item.defense>0 then
        pos = pos + 1
        local Defense=cc.ui.UILabel.new({UILabelType = 2, text = "防御：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Defense:setTag(106)
        local DefenseNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Defense:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        DefenseNum:setString(item.defense)
        DefenseNum:setTag(105)
    end
    if item.cri>0 then
        pos = pos + 1
        local Cri=cc.ui.UILabel.new({UILabelType = 2, text = "暴击：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Cri:setTag(108)
        local CriNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Cri:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        CriNum:setString(item.cri)
        CriNum:setTag(107)
    end
    if item.hit>0 then
        pos = pos + 1
        local Hit=cc.ui.UILabel.new({UILabelType = 2, text = "命中：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Hit:setTag(110)
        local HitNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Hit:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        HitNum:setString(item.hit)
        HitNum:setTag(109)
    end
    if item.miss>0 then
        pos = pos + 1
        local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "闪避：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Miss:setTag(112)
        local MissNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        MissNum:setString(item.miss)
        MissNum:setTag(111)
    end
    if item.minLvl>0 then
        pos = pos + 1
        local Attack=cc.ui.UILabel.new({UILabelType = 2, text = "装载等级：", size = 25, color = cc.c3b(248, 204, 45)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Attack:setTag(104)
        local AttackNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Attack:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        AttackNum:setString(item.minLvl)
        AttackNum:setTag(103)
    end

    
    if item.sklId~=0 then
        pos = pos + 1
        local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "技能：", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(leftBox)
        Miss:setTag(113)
        local MissNum=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(leftBox)
        MissNum:setColor(display.COLOR_GREEN)
        MissNum:setString(skillData[item.sklId].sklName)
        MissNum:setTag(114)
    end

    --没有属性的显示描述
    if pos==0 then
        pos=1
        local des=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(132, 149, 165)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y+10)
        :addTo(leftBox)
        des:setTag(101)
        des:setString(item.des)
        des:setWidth(420)
        des:setAnchorPoint(0,1)
    end

end

function shopLayer:setGlod(num)
    local goldStr = num..""
    local length = #goldStr
    for i=1,math.floor((length-1)/3) do
        local Lstr = string.sub(goldStr, 1, length-i*3)
        local Rstr = string.sub(goldStr, length-i*3+1)
        goldStr = Lstr..","..Rstr
    end
    return goldStr
end

function shopLayer:GetTimeStr(nSec)
    nSec = nSec/1000
    local nHour, nMin
    nHour = math.floor(nSec/3600)
    nSec = nSec-nHour*3600
    nMin = math.floor(nSec/60)
    nSec = nSec-nMin*60
    if nSec==60 then
        nSec=0
    end

    local strRet = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
    return strRet
end

-- function shopLayer:getDtime()
--     local srvTime
--     local tab = os.date("*t", srvTime)

--     if tab.hour<9 then
--         tab.hour = 9
--         tab.min = 0
--         tab.sec = 0

--     elseif tab.hour<12 then
--         tab.hour = 12
--         tab.min = 0
--         tab.sec = 0

--     elseif tab.hour<18 then
--         tab.hour = 18
--         tab.min = 0
--         tab.sec = 0

--     elseif tab.hour<=24 then
--         tab.hour = 24
--         tab.min = 0
--         tab.sec = 0
--     end
--     local endTime = os.time(tab)*1000 - localToSrv
--     dTime = endTime - os.time()*1000
-- end

function shopLayer:onInterval()
    dTime = dTime - 1000

    if dTime<=0 then
        dTime = 1000
        refAuto = 1
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["shopType"] = g_shopType
        sendData["auto"] = 1
        m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
        startLoading()
        g_shopPointTs = getSrvPointTimeTs(getCurPointTime()) --当前在哪个时间段内
        if timeHandle~=nil then
            scheduler.unscheduleGlobal(timeHandle)
        end
    else
        self.restTime:setString(self:GetTimeStr(dTime))
    end

end

function shopLayer:onGetShopInfo(ret)
    endLoading()
    if ret.result==1 then
        -- if g_thisIsOtherTime and (g_shopType==1 or g_shopType==4) then
        --     print("另外")
        --     return
        -- end
        self:performWithDelay(function ()
            self:updateListView()
        end,0.01)
        refCnt = ret.data.refCnt
        
        if refAuto==0 then
            print("手动")
            if g_shopType==1 or g_shopType==4 then
                srv_userInfo["diamond"] = srv_userInfo["diamond"]-shopRefData[refId].diamond
                mainscenetopbar:setDiamond()
                if refId>0 then
                    refId = refId+1
                end
                if refId>9 then
                    refId = 0
                end
            elseif g_shopType==2 then
                srv_userInfo["reputation"] = srv_userInfo["reputation"]-shopRefData[refId].reputation
                self.reputation:setString(srv_userInfo.reputation)
                if refId>0 then
                    refId = refId+1
                end
                if refId>9 then
                    refId = 0
                end
            elseif g_shopType==3 then
                srv_userInfo["exploit"] = srv_userInfo["exploit"]-shopRefData[refId].exploit
                self.gongxunNum:setString(srv_userInfo.exploit)
                if refId>0 then
                    refId = refId+1
                end
                if refId>9 then
                    refId = 0
                end
            elseif g_shopType==5 then
                srv_userInfo["expedition"] = srv_userInfo["expedition"]-shopRefData[refId].expedition
                self.yuanzhengNum:setString(srv_userInfo.expedition)
                if refId>0 then
                    refId = refId+1
                end
                if refId>9 then
                    refId = 0
                end
            end

            --数据统计
            -- if g_shopType==1 or g_shopType==4 then
            --     luaStatBuy("普通商店刷新", BUY_TYPE_NORMAL_REFRESH, 1, 
            --         "钻石", shopRefData[refId].diamond)
            -- elseif g_shopType==2 then
            --     luaStatBuy("PVP商店刷新", BUY_TYPE_PVP_REFRESH, 1, 
            --         "钻石", shopRefData[refId].diamond)
            -- elseif g_shopType==3 then
            --     luaStatBuy("军团商店刷新", BUY_TYPE_ARMY_REFRESH, 1, 
            --         "钻石", shopRefData[refId].diamond)
            -- end
            

            --普通商店手动刷新,还需要帮助刷新另一个商店（装备店，特种弹店）
            --现在不需要了
            -- if g_shopType==1 then
            --     g_thisIsOtherTime = true
            --     local sendData={}
            --     sendData["characterId"] = srv_userInfo["characterId"]
            --     sendData["shopType"] = 4
            --     sendData["auto"] = 1
            --     m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
            --     startLoading()
            -- elseif g_shopType==4 then
            --     g_thisIsOtherTime = true
            --     local sendData={}
            --     sendData["characterId"] = srv_userInfo["characterId"]
            --     sendData["shopType"] = 1
            --     sendData["auto"] = 1
            --     m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
            --     startLoading()
            -- else
            --     g_thisIsOtherTime = false
            -- end
            
        else
            print("自动")
            g_thisIsOtherTime = false
            srv_userInfo.ts = srv_local_dts + os.time()*1000
            dTime = shopGoodsInfo.pointTs - srv_userInfo.ts
            if timeHandle~=nil then
                scheduler.unscheduleGlobal(timeHandle)
            end
            timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
        end

        
        
        
    else
        showTips(ret.msg)
        endLoading()
    end
end
function shopLayer:onPurchase(result)
    if result.result==1 then
        showTips("购买成功")
        masklayer:removeSelf()

        local Item_ = itemData[goodsData[curValue.id].id]
        if goodsData[curValue.id].diamond~=0 and (g_shopType==1 or g_shopType==4) then
            if srv_userInfo["diamond"]<goodsData[curValue.id].diamond then
                showTips("钻石不足")
                return
            end
            srv_userInfo["diamond"] = srv_userInfo["diamond"]-goodsData[curValue.id].diamond
            mainscenetopbar:setDiamond()
            DCItem.buy(tostring(Item_.id),Item_.name,tonumber(goodsData[curValue.id].stock),goodsData[curValue.id].diamond,"钻石")

            --数据统计
            luaStatBuy("普通商店商品", BUY_TYPE_NORMAL, 1, "钻石", goodsData[curValue.id].diamond)
        elseif goodsData[curValue.id].gold~=0 and (g_shopType==1 or g_shopType==4) then
            if srv_userInfo["gold"]<goodsData[curValue.id].gold then
                showTips("金币不足")
                return
            end
            srv_userInfo["gold"] = srv_userInfo["gold"]-goodsData[curValue.id].gold
            mainscenetopbar:setGlod()
            DCItem.buy(tostring(Item_.id),Item_.name,tonumber(goodsData[curValue.id].stock),goodsData[curValue.id].gold,"金币")
        elseif g_shopType==3 then
            if srv_userInfo["exploit"]<goodsData[curValue.id].exploit then
                showTips("功勋不足")
                return
            end
            srv_userInfo["exploit"] = srv_userInfo["exploit"]-goodsData[curValue.id].exploit
            self.gongxunNum:setString(srv_userInfo.exploit)
            DCItem.buy(tostring(Item_.id),Item_.name,tonumber(goodsData[curValue.id].stock),goodsData[curValue.id].exploit,"功勋")
        elseif g_shopType==2 then
            if srv_userInfo["reputation"]<goodsData[curValue.id].reputation then
                showTips("声望不足")
                return
            end
            srv_userInfo["reputation"] = srv_userInfo["reputation"]-goodsData[curValue.id].reputation
            self.reputation:setString(srv_userInfo.reputation)
            DCItem.buy(tostring(Item_.id),Item_.name,tonumber(goodsData[curValue.id].stock),goodsData[curValue.id].reputation,"声望")
        elseif g_shopType==5 then
            if srv_userInfo["expedition"]<goodsData[curValue.id].expedition then
                showTips("远征币不足")
                return
            end
            srv_userInfo["expedition"] = srv_userInfo["expedition"]-goodsData[curValue.id].expedition
            self.yuanzhengNum:setString(srv_userInfo.expedition)
            DCItem.buy(tostring(Item_.id),Item_.name,tonumber(goodsData[curValue.id].stock),goodsData[curValue.id].expedition,"远征币")
        end

        self:createMaskItem(curItem)

        for i,value in ipairs(shopGoodsInfo.goodIds) do
            if value.id == curValue.id then
                shopGoodsInfo.goodIds[i].buy = 1
                break
            end
        end
        -- for i,value in ipairs(shopGoodsInfo.ranGoods) do
        --     if value.id == curValue.id then
        --         shopGoodsInfo.ranGoods[i].buy = 1
        --         break
        --     end
        -- end
        if g_shopType==1 then
          saveLocalGameDataBykey("shopGoodsInfo",shopGoodsInfo)
        elseif g_shopType==2 then
          saveLocalGameDataBykey("PVPShopGoodsInfo",shopGoodsInfo)
        elseif g_shopType==3 then
          saveLocalGameDataBykey("legionShopGoodsInfo",shopGoodsInfo)
        end
        -- printTable(shopGoodsInfo)
        
    else
        showTips(result.msg)
        endLoading()
    end
    
end
function getCurPointTime()
    if g_shopType==4 then
        if g_thisIsOtherTime then
            for i=1,#refreshTimePoint do
                if srv_userInfo.ts<=getSrvPointTimeTs(refreshTimePoint[i]) then
                    return refreshTimePoint[i]
                end
            end
        else
            for i=1,#Refresh_107Point do
                if srv_userInfo.ts<=getSrvPointTimeTs(Refresh_107Point[i]) then
                    return Refresh_107Point[i]
                end
            end
        end
    else
        if g_thisIsOtherTime and g_shopType==1 then
            for i=1,#Refresh_107Point do
                if srv_userInfo.ts<=getSrvPointTimeTs(Refresh_107Point[i]) then
                    return Refresh_107Point[i]
                end
            end
        else
            for i=1,#refreshTimePoint do
                if srv_userInfo.ts<=getSrvPointTimeTs(refreshTimePoint[i]) then
                    return refreshTimePoint[i]
                end
            end
        end
    end
    -- if srv_userInfo.ts<=getSrvPointTimeTs(9) then
    --     return 9
    -- elseif srv_userInfo.ts<=getSrvPointTimeTs(12) then
    --     return 12
    -- elseif srv_userInfo.ts<=getSrvPointTimeTs(18) then
    --     return 18
    -- elseif srv_userInfo.ts<=getSrvPointTimeTs(24) then
    --     return 24
    -- end
end
function shopLayer:onEnter()
    srv_userInfo.ts = srv_local_dts + os.time()*1000

    if g_shopType==1 then
        self.menu2:setVisible(true)
        self.menu1:getChildByTag(10):setString("装备店")
        self.menu2:getChildByTag(10):setString("炮弹店")
        self.refreshImg:setTexture("common/common_Diamond.png")

        goodsData = shopData_type1
        shopLocalKey = "shopGoodsInfo"
        self.guideTab2 = self.menu2
    elseif g_shopType==4 then
        self.menu1:getChildByTag(10):setString("装备店")
        self.menu2:getChildByTag(10):setString("炮弹店")
        self.refreshImg:setTexture("common/common_Diamond.png")
        self.menu2:setVisible(true)
        goodsData = shopData_type4
        shopLocalKey = "107GoodsInfo"
    elseif g_shopType==2 then
        self.menu1:getChildByTag(10):setString("竞技场商店")
        self.refreshImg:setTexture("common/shengwang.png")
        self.menu1:setButtonEnabled(false)
        self.menu2:setVisible(false)

        mainscenetopbar:setVisible(false)
        goodsData = shopData_type2
        shopLocalKey = "PVPShopGoodsInfo"

        --声望
        local reputationBar = display.newSprite("common/common_goldBar.png")
        :addTo(self,0,100)
        :align(display.CENTER_TOP, display.cx + 350,display.height - 10)
        local icon = display.newSprite("common/shengwang.png")
        :addTo(reputationBar)
        :pos(0,reputationBar:getContentSize().height/2)
        self.reputation = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
        :addTo(reputationBar)
        :pos(40,reputationBar:getContentSize().height/2)
        self.reputation:setString(srv_userInfo.reputation)
    elseif g_shopType==3 then
        self.menu1:getChildByTag(10):setString("军团商店")
        self.refreshImg:setTexture("common/gongxun.png")
        self.menu1:setButtonEnabled(false)
        self.menu2:setVisible(false)
        goodsData = shopData_type3
        shopLocalKey = "legionShopGoodsInfo"

        --功勋数量显示
        local gongxunBar = display.newSprite("common/common_goldBar.png")
        :addTo(self,0,100)
        :align(display.CENTER_TOP, display.cx + 350,display.height - 10)
        local icon = display.newSprite("common/gongxun.png")
        :addTo(gongxunBar)
        :pos(0,gongxunBar:getContentSize().height/2)
        self.gongxunNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
        :addTo(gongxunBar)
        :pos(40,gongxunBar:getContentSize().height/2)
        self.gongxunNum:setString(srv_userInfo.exploit)
    elseif g_shopType==5 then
        self.menu1:getChildByTag(10):setString("远征商店")
        self.refreshImg:setTexture("common/expedition.png")
        self.menu1:setButtonEnabled(false)
        self.menu2:setVisible(false)
        goodsData = shopData_type5
        shopLocalKey = "ExpeditionGoodsInfo"

        -- local titleBar = display.newSprite("shop/titleBar.png")
        -- :addTo(self.shopBox)
        -- :pos(self.shopBox:getContentSize().width/2, self.shopBox:getContentSize().height)
        -- local img = display.newSprite("shop/title_expeditionShop.png")
        -- :addTo(titleBar)
        -- :pos(titleBar:getContentSize().width/2, titleBar:getContentSize().height/2)

        --远征币 数量显示
        local gongxunBar = display.newSprite("common/common_goldBar.png")
        :addTo(self,0,100)
        :align(display.CENTER_TOP, display.cx + 350,display.height - 10)
        local icon = display.newSprite("common/expedition.png")
        :addTo(gongxunBar)
        :pos(0,gongxunBar:getContentSize().height/2)
        self.yuanzhengNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
        :addTo(gongxunBar)
        :pos(40,gongxunBar:getContentSize().height/2)
        self.yuanzhengNum:setString(srv_userInfo.expedition)
    end

    --//不需要本地的都每次从服务端
    -- if getLocalGameDataBykey(shopLocalKey)~=nil then
    --     shopGoodsInfo = getLocalGameDataBykey(shopLocalKey)
    --     modifyGoodsData()
    --     -- printTable(shopGoodsInfo)
    --     if shopGoodsInfo.goodIds[1].id<10000 then
    --         print("本地保存的老数据，需要更新")
    --         refAuto = 1
    --         local sendData={}
    --         sendData["characterId"] = srv_userInfo["characterId"]
    --         sendData["shopType"] = g_shopType
    --         sendData["auto"] = 1
    --         m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
    --         startLoading()
    --         g_shopPointTs = getSrvPointTimeTs(getCurPointTime()) --当前在哪个时间段内
    --     elseif srv_userInfo.ts<shopGoodsInfo["pointTs"] then
    --         print("本地有商品记录")
    --         self:performWithDelay(function ()
    --             self:updateListView()
    --         end,0.01)
    --         dTime = shopGoodsInfo["pointTs"] - srv_userInfo.ts
    --         refCnt = shopGoodsInfo.refCnt
    --         if timeHandle~=nil then
    --             scheduler.unscheduleGlobal(timeHandle)
    --         end
    --         timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
    --         -- if refAuto==0 then
    --         --     srv_userInfo["diamond"] = srv_userInfo["diamond"]-shopRefData[refId].diamond
    --         --     mainscenetopbar:setDiamond()
    --         -- end
    --         -- refId = refCnt+1
    --         -- if refId>9 then
    --         --     refId = 0
    --         -- end
    --     else
    --         print("本地有商品记录，但是需要更新")
    --         refAuto = 1
    --         local sendData={}
    --         sendData["characterId"] = srv_userInfo["characterId"]
    --         sendData["shopType"] = g_shopType
    --         sendData["auto"] = 1
    --         m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
    --         startLoading()
    --         g_shopPointTs = getSrvPointTimeTs(getCurPointTime()) --当前在哪个时间段内
    --     end
    -- else
        print("本地无商品")
        refAuto = 1
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["shopType"] = g_shopType
        sendData["auto"] = 1
        m_socket:SendRequest(json.encode(sendData), CMD_GETSHOPINFO, self, self.onGetShopInfo)
        startLoading()
        g_shopPointTs = getSrvPointTimeTs(getCurPointTime()) --当前在哪个时间段内
    -- end
end
function shopLayer:onExit()
    scheduler.unscheduleGlobal(timeHandle)
    display.removeSpriteFramesWithFile("Image/shop_img.plist", "Image/shop_img.png")
    if g_shopType==2 then
        mainscenetopbar:setVisible(true)
    end
end

return shopLayer