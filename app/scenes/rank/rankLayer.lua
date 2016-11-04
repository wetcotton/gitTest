-- @Author: anchen
-- @Date:   2015-08-28 11:21:25
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-18 16:41:08

rankLayer = class("rankLayer", function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

local openis = nil

rankLayer.Instance = nil
function rankLayer:ctor()
    rankLayer.Instance = self
    self.type = 1

    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    self.rankBox = display.newScale9Sprite("common/common_box3.png",nil,nil,cc.size(1016,612))
    :addTo(self)
    :pos(display.cx+30,display.cy)
    local tmpsize = self.rankBox:getContentSize()
    

    --title
    local titleBar = display.newSprite("rankLayer/rank2_img1.png")
    :addTo(self)
    :pos(display.cx, display.cy+tmpsize.height/2+10)
    -- self.title = display.newSprite("rankLayer/titile.png")
    -- :addTo(titleBar)
    -- :pos(titleBar:getContentSize().width/2, titleBar:getContentSize().height/2)

    local closeBt =  cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self,1)
    :align(display.TOP_LEFT, 0, display.height)
    closeBt:onButtonClicked(function(event)
        if display.getRunningScene().setTopBarVisible then
            display.getRunningScene():setTopBarVisible(true)
        end
        self:removeSelf()
        end)

    --左侧按钮栏
    -- local leftBar =  display.newScale9Sprite("common/common_Frame27.png",nil,nil,cc.size(188, 536))
    -- :addTo(self.rankBox)
    -- :pos(-120, tmpsize.height/2)

    self.menu = {}
    local isBtOpen = {
        {bOpen = true},
        {bOpen = false},
        {bOpen = false},
        {bOpen = false},
    }
    --左侧二级菜单下拉框
    function createOpenList()
        self.openList = display.newNode()
            :addTo(self.rankBox,1)
            self.openList:setVisible(false)

        self.openbt1 = cc.ui.UIPushButton.new({
            normal = "rankLayer/rank2_img10.png",
            disabled = "rankLayer/rank2_img11.png"
            })
        :addTo(self.openList,11)
        :pos(0,-60)
        :scale(0.7)
        :onButtonClicked(function(event)
            self.openbt1:setButtonEnabled(false)
            self.openbt2:setButtonEnabled(true)
            -- self.bian:setPositionY(85)
            if openis==3 then
                self.type = 3
                RankMgr:ReqRankInfo(self.type)
            elseif openis==4 then
                self.type = 5
                RankMgr:ReqRankInfo(self.type)
            end
            end)

        self.openbt2 = cc.ui.UIPushButton.new({
            normal = "rankLayer/rank2_img12.png",
            disabled = "rankLayer/rank2_img13.png"
            })
        :addTo(self.openList,12)
        :pos(0,-125)
        :scale(0.7)
        :onButtonClicked(function(event)
            self.openbt1:setButtonEnabled(true)
            self.openbt2:setButtonEnabled(false)
            -- self.bian:setPositionY(30)
            if openis == 3 then
                self.type = 4
                RankMgr:ReqRankInfo(self.type)
            elseif openis == 4 then
                self.type = 6
                RankMgr:ReqRankInfo(self.type)
            end
            end)

        --选择边框
        -- self.bian = display.newSprite("rankLayer/rank_img8.png")
        -- :addTo(self.openList,13)
        -- :pos(self.openList:getContentSize().width/2,85)
    end
    function resetOpenList(btmp,n)
        self.openList:setVisible(false)
        self.openbt1:setButtonEnabled(false)
        self.openbt2:setButtonEnabled(true)
        -- self.bian:setPositionY(85)
        if n==3 and (not btmp) then
            self.openList:align(display.CENTER_TOP, 
                -50, tmpsize.height - 240)
            self.openList:setVisible(true)
            openis = 3
        elseif n==4 and (not btmp) then
            self.openList:align(display.CENTER_TOP, 
                -50, tmpsize.height - 322)
            self.openList:setVisible(true)
            openis = 4
        else
            
        end
    end


    function clickBt(note,n)
        local btmp = isBtOpen[n].bOpen
        for i=1,#isBtOpen do
            self.menu[i]:setButtonEnabled(true)
            self.menu[i]:setLocalZOrder(-1)
            self.menu[i]:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
            isBtOpen[i].bOpen = false
        end

        self.menu[4]:setPositionY(tmpsize.height - 310)
        if not btmp then
            note:setButtonEnabled(false)
            note:setLocalZOrder(1)
            -- note:setButtonImage("pressed", "rankLayer/rank_bt2.png")
            note:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
            isBtOpen[n].bOpen = true

            if n==3 or n==4 then
                if n==3 then
                    self.menu[4]:setPositionY(tmpsize.height - 440)
                end
            end
        end
        resetOpenList(btmp,n)
        RankMgr:ReqRankInfo(self.type)
    end

    createOpenList()
    local dx = -50
    --战斗力
    self.menu[1] = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png",
        })
    :addTo(self.rankBox,1)
    :pos(dx, tmpsize.height - 70)
    :onButtonClicked(function(event)
        self.type = 1
        clickBt(event.target,1)
        end)
    self.menu[1]:setButtonEnabled(false)
    cc.ui.UILabel.new({UILabelType = 2, text = "战斗力", size = 27, color = cc.c3b(95, 217, 255)})
    :align(display.CENTER, -20, 2)
    :addTo(self.menu[1],0,10)
    --竞技
    self.menu[2] = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png",
        })
    :addTo(self.rankBox,-1)
    :pos(dx, tmpsize.height - 150)
    :onButtonClicked(function(event)
        self.type = 2
        clickBt(event.target,2)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "竞技", size = 27, color = cc.c3b(95, 217, 255)})
    :align(display.CENTER, -20, 2)
    :addTo(self.menu[2],0,10)
    --军团
    self.menu[3] = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png",
        })
    :addTo(self.rankBox,-1)
    :pos(dx, tmpsize.height - 230)
    :onButtonClicked(function(event)
        self.type = 3
        clickBt(event.target,3)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "军团", size = 27, color = cc.c3b(95, 217, 255)})
    :align(display.CENTER, -20, 2)
    :addTo(self.menu[3],0,10)


    --善恶
    self.menu[4] = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png",
        })
    :addTo(self.rankBox,-1)
    :pos(dx, tmpsize.height - 310)
    :onButtonClicked(function(event)
        self.type = 5
        clickBt(event.target,4)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "善恶", size = 27, color = cc.c3b(95, 217, 255)})
    :align(display.CENTER, -20, 2)
    :addTo(self.menu[4],0,10)
    if g_isBanShu then
        self.menu[4]:setVisible(false)
    end
    


    --==============
    --右侧排行榜
    self.border = self.rankBox

    self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(15, 10, 990, 560),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.border)

    --===================
    --下侧自己的信息
    local topBar = display.newScale9Sprite("rankLayer/rank2_img14.png",nil,nil,cc.size(1030, 52))
    :addTo(self)
    :align(display.CENTER_BOTTOM, display.cx+30, 0)


    local rankTxt = cc.ui.UILabel.new({UILabelType = 2, text = "当前排名：", size = 25, color = cc.c3b(110, 162, 183)})
    :addTo(topBar)
    :pos(30,20)

    --当前排名
    local rankNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 5, 48)})
    :addTo(topBar)
    :pos(rankTxt:getPositionX()+rankTxt:getContentSize().width,rankTxt:getPositionY())

    --自己头像
    -- local head = display.newSprite()
    -- :addTo(topBar)
    -- :pos(topBar:getContentSize().width/2 - 80, topBar:getContentSize().height/2)
    --等级
    local levelLabel = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 25, color = cc.c3b(110, 162, 183)})
    :addTo(topBar)
    :pos(320,20)

    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = srv_userInfo.level, size = 25, color = cc.c3b(253, 208, 48)})
    :addTo(topBar)
    :pos(levelLabel:getPositionX()+levelLabel:getContentSize().width,levelLabel:getPositionY())

    --自己的名字,或军团名字
    local nameLabel = cc.ui.UILabel.new({UILabelType = 2, text = "玩家：", size = 25, color = cc.c3b(110, 162, 183)})
    :addTo(topBar)
    :pos(530,20)

    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(253, 208, 48)})
        :addTo(topBar)
        :pos(nameLabel:getPositionX()+nameLabel:getContentSize().width,nameLabel:getPositionY())

    --自己的战斗力
    local strTxt = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 25, color = cc.c3b(110, 162, 183)})
        :addTo(topBar)
        :pos(800,20)
    local stren = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = srv_userInfo.level, size = 25, color = cc.c3b(253, 208, 48)})
    :addTo(topBar)
    :pos(strTxt:getPositionX()+strTxt:getContentSize().width,strTxt:getPositionY())

    local tipTxt = cc.ui.UILabel.new({UILabelType = 2, text = "您不在此排行榜中", 
        size = 25, color = cc.c3b(255, 241, 0)})
        :addTo(topBar)
        :align(display.CNETER, topBar:getContentSize().width/2, 20)
        tipTxt:setVisible(false)
        tipTxt:setAnchorPoint(0.5,0.5)


    self.myInfo = {}
    table.insert(self.myInfo, rankTxt)
    table.insert(self.myInfo, rankNum)
    table.insert(self.myInfo, levelLabel)
    table.insert(self.myInfo, level)
    table.insert(self.myInfo, nameLabel)
    table.insert(self.myInfo, name)
    table.insert(self.myInfo, strTxt)
    table.insert(self.myInfo, stren)

    self.tipInfo = {}
    table.insert(self.tipInfo, tipTxt)
end
function rankLayer:onEnter()
    -- startLoading()
    RankMgr:ReqRankInfo(self.type)
end
function rankLayer:onExit()
    rankLayer.Instance = nil
end

function rankLayer:reloadData()
    local tmpvalue = RankMgr.srv_RankInfo.myRank
    if tmpvalue==nil then
        self.lv:removeAllItems()
        for i=1,#self.myInfo do
            self.myInfo[i]:setVisible(false)
        end
        for i=1,#self.tipInfo do
            self.tipInfo[i]:setVisible(true)
        end
        return
    end
    if tmpvalue.myOrder==0 then
        for i=1,#self.myInfo do
            self.myInfo[i]:setVisible(false)
        end
        for i=1,#self.tipInfo do
            self.tipInfo[i]:setVisible(true)
        end
    else
        for i=1,#self.myInfo do
            self.myInfo[i]:setVisible(true)
        end
        for i=1,#self.tipInfo do
            self.tipInfo[i]:setVisible(false)
        end
        self.myInfo[5]:setString("玩家：")
        if self.type==3 or self.type==4 then
            self.myInfo[5]:setString("军团：")
            self.myInfo[7]:setString("总战斗力：")
            self.myInfo[8]:setString(tmpvalue.strength)
        elseif self.type==5 then
            self.myInfo[7]:setString("善值：")
            self.myInfo[8]:setString(srv_userInfo.goodEvil)
        elseif self.type==6 then
            self.myInfo[7]:setString("恶值：")
            self.myInfo[8]:setString(-srv_userInfo.goodEvil)
        else
            self.myInfo[7]:setString("战斗力：")
            self.myInfo[8]:setString(tmpvalue.strength)
        end

        self.myInfo[2]:setString(tmpvalue.myOrder)
        self.myInfo[6]:setString(tmpvalue.name)
    end

    self.lv:removeAllItems()
    for i,value in ipairs(RankMgr.srv_RankInfo.rList) do
        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(990, 150)
        self.lv:addItem(item)

        local bar = display.newSprite("rankLayer/rank2_img2.png")
        :addTo(content)
        local tmpsize = bar:getContentSize()
        if self.type==4 or self.type==6 then
            bar:setTexture("rankLayer/rank2_img3.png")
        end

        --名次
        if i<=3 then
            display.newSprite("rankLayer/rank2_img"..(i+3)..".png")
            :addTo(bar)
            :pos(100, tmpsize.height/2)
        else
            local img = display.newSprite("rankLayer/rank2_img7.png")
            :addTo(bar)
            :pos(100, tmpsize.height/2)
            local rankNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = i, size = 45, color = cc.c3b(0, 0, 0)})
            :addTo(img,2)
            :align(display.CENTER, 80,img:getContentSize().height/2)

            -- setLabelStroke(rankNum,45,nil,nil,nil,nil,nil,"fonts/slicker.ttf", true)
        end

        --名字
        local name = cc.ui.UILabel.new({UILabelType = 2, text = value.name, size = 25})
        :addTo(bar,2)
        :pos(320, tmpsize.height/2+25)
        -- setLabelStroke(name,25,nil,1,nil,nil,nil,nil, true)

        --等级
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 25, color = cc.c3b(175, 206, 226)})
        :addTo(bar,2)
        :pos(320, tmpsize.height/2-25)
        -- setLabelStroke(label,25,nil,1,nil,nil,nil,nil, true)
        local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = value.level, size = 25, color = cc.c3b(175, 206, 226)})
        :addTo(bar,2)
        :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())
        -- setLabelStroke(level,25,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)

        --头像
        if self.type==3 or self.type==4 then
            local typeIcon = display.newSprite()
            :addTo(bar,2)
            :pos(250,tmpsize.height/2)
            :scale(0.8)
            if self.type==3 then --善
                typeIcon:setTexture("common/common_good.png")
            elseif self.type==4 then
                typeIcon:setTexture("common/common_bad.png")
            end

            local path = "SingleImg/legion/legionIcon/Legion_"..value.resId..".png"
            local head = display.newSprite(path)
            :addTo(typeIcon)
            :pos(typeIcon:getContentSize().width/2,typeIcon:getContentSize().height/2)
            -- head:setScale(0.9)
        else
            local head
            if self.type==2 then
                head = getCHeadBox(value.templateId) 
            else
                head = getCHeadBox(value.resId) 
            end
            head:addTo(bar)
            head:pos(260,tmpsize.height/2)
            head:setScale(1.2)
            head:setButtonEnabled(false)
        end

        --战斗力
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力", size = 28, color = cc.c3b(255, 241, 0)})
        :addTo(bar,2)
        :align(display.CENTER, tmpsize.width-165, tmpsize.height/2+13)
        local strengthNum = cc.LabelAtlas:_create()
            :addTo(bar)
            :align(display.CENTER, label:getPositionX(),tmpsize.height/2-30)
            strengthNum:initWithString("","common/common_Num2.png",27.3,39,string.byte(0))
        if value.strength~=nil then
            label:setString("战斗力")
            strengthNum:setString(value.strength)
        else
            label:setString("善恶点")
            strengthNum:setString(value.goodEvil)
        end

        -- if self.type~=3 and self.type~=4 then
        --     cc.ui.UIPushButton.new("rankLayer/search.png")
        --     :addTo(bar)
        --     :pos(tmpsize.width - 50, tmpsize.height/2)
        --     :onButtonPressed(function(event)
        --         event.target:setScale(0.98)
        --         end)
        --     :onButtonRelease(function(event)
        --         event.target:setScale(1.0)
        --         end)
        --     :onButtonClicked(function(event)
        --         showTips("暂未开放")
        --         end)
        -- end

    end
    self.lv:reload()
end

function rankLayer:OnRankInfoRet(cmd)
    endLoading()
    if cmd.result==1 then
        self:reloadData()
    else
        showTips(cmd.msg)
    end
end



return rankLayer