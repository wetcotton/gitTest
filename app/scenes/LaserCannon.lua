-- @Author: anchen
-- @Date:   2015-10-29 10:52:35
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-18 15:20:29
LaserCannon = class("LaserCannon",function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

LaserCannon.Instance = nil

local caoweiPos = {
    cc.p(230,146),
    cc.p(358,146),
    cc.p(479,146),
    cc.p(592,146),
}
--激光炮说明面板
function LaserCannon:createPaoExplain()
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

    local str = [[1.槽位中装载镜片才能激活激光炮，槽位中镜片可以任意拖动互换。
2.至少装载1个镜片才可使激光炮组合生效。
3.不同镜片，不同排列，会激活不同的激光炮能力。
4.一共4个槽位，主槽位对任意镜片都有加成效果。
5.最多装载1个特效型镜片，最多装载2个数量型镜片，最多装载3个伤害型镜片。
6.特效型镜片影响攻击特效，数量型镜片影响目标数量与伤害率，伤害型镜片有额外伤害率加成。
7.激光炮可以进行强化，每次强化会增加基础伤害或能量恢复速度，每次强化有一定冷却时间，时间冷却后才可继续进行强化，强化等级不能超过战队等级。
        ]]
    _label:setString(str)

    layer:addHinder(spr)
    layer:setOnTouchEndedEvent(function()
        layer:removeFromParent()
    end)

    self:getParent():addChild(layer,2)
end
--初始化激光炮
function LaserCannon:ctor()
    --镜片列表框
    local lensBox = display.newScale9Sprite("#Embattle_frame12.png",nil,nil,cc.size(490,340),cc.rect(30, 30, 260, 30))
    :addTo(self,1)
    lensBox:pos(-lensBox:getContentSize().width-20, display.cy+30)
    lensBox:setAnchorPoint(0,0.5)
    local lensBoxSize = lensBox:getContentSize()


    --标签栏
    local tabImg = {
        {"Embattle_Img63.png", "Embattle_Img64.png"},
        {"Embattle_Img69.png", "Embattle_Img70.png"},
        {"Embattle_Img67.png", "Embattle_Img68.png"},
        {"Embattle_Img65.png", "Embattle_Img66.png"},
    }
    self.tabType = 1
    local _btnName = {"全部","伤害","数量","特效"}
    local tabBt = {}
    for i=1,4 do
        tabBt[i] = cc.ui.UIPushButton.new({
            normal = "#Embattle_Img72.png",
            disabled = "#Embattle_Img71.png"
            })
        :addTo(lensBox,4-i)
        :pos(150+(i-1)*80, lensBoxSize.height + 20)
        :onButtonClicked(function(event)
            self.tabType = i
            for j=1,4 do
                tabBt[j]:setButtonEnabled(true)
                tabBt[j]:getChildByTag(j):setColor(cc.c3b(144,247,255))
            end
            tabBt[i]:setButtonEnabled(false)
            tabBt[i]:getChildByTag(i):setColor(cc.c3b(78,8,0))
            self:reloadLensLv(true)
            end)
        
        display.newTTFLabel{text = _btnName[i],color = cc.c3b(144,247,255),size = 27}
        :addTo(tabBt[i],0,i)
        :pos(10,-3)
        if i==1 then
            tabBt[i]:setButtonEnabled(false)
            tabBt[i]:getChildByTag(i):setColor(cc.c3b(78,8,0))
        end
    end

    local lensBoxFlag = false
    local BoxBt = cc.ui.UIPushButton.new({
        normal = "#Embattle_Img52.png",
        pressed = "#Embattle_Img52.png"
        })
    :addTo(lensBox)
    :pos(lensBox:getContentSize().width-5,lensBox:getContentSize().height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.96)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    self.BoxBt = BoxBt
    BoxBt:setAnchorPoint(0,0.5)
    BoxBt:onButtonClicked(function(event)
        if lensBoxFlag then
            lensBox:runAction(cc.MoveBy:create(0.2, cc.p(-lensBox:getContentSize().width,0)))
        else
            lensBox:runAction(cc.MoveBy:create(0.2, cc.p(lensBox:getContentSize().width,0)))
        end
        GuideManager:_addGuide_2(11306, self:getParent(),handler(self,self.caculateGuidePos),1111)
        lensBoxFlag = not lensBoxFlag
        end)

    --镜片列表
    self.lensLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(45, 20, 420, 300),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(lensBox)
        :onTouch(handler(self, self.lensListOnTouch))

    --激光炮
    local pao = display.newSprite("#Embattle_Img42.png")
    :addTo(self)
    :pos(10,-3)
    pao:setAnchorPoint(0,0)

    --说明
    cc.ui.UIPushButton.new("#Embattle_Img60.png")
    :addTo(pao)
    :pos(pao:getContentSize().width+15, pao:getContentSize().height-35)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:createPaoExplain()
        end)

    self.lenCaoCurIdx = 0
    self.caoWei = {}
    local btPressedImg = {"#Embattle_Img55.png", "#Embattle_Img56.png", "#Embattle_Img56.png", "#Embattle_Img56.png"}
    for i=1,4 do
        self.caoWei[i] = {}
        self.caoWei[i].isUse = false --镜片槽位是否被使用
        --槽位按钮
        self.caoWei[i].button = cc.ui.UIPushButton.new({
            normal = "#Embattle_Img54.png",
            pressed = btPressedImg[i]
            })
        :addTo(pao)
        :pos(caoweiPos[i].x, caoweiPos[i].y)
        :onButtonClicked(function(event)
            if i==4 then
                if srv_userInfo.vip<9 then
                    showTips("VIP9可开启第四个槽位")
                    return
                elseif EmbattleMgr.curInfo.matrix.laser4==-1 then
                    showMessageBox("是否开启激光槽位？", function()
                        startLoading()
                        local sendData ={}
                        m_socket:SendRequest(json.encode(sendData), CMD_OPEN_LASER, self, self.onOpenLaser)
                        end)
                    return
                end
            end
            if not lensBoxFlag then
                lensBox:runAction(cc.MoveBy:create(0.2, cc.p(lensBox:getContentSize().width,0)))
                lensBoxFlag = not lensBoxFlag
            elseif not self.caoWei[i].isUse then
                lensBox:runAction(cc.MoveBy:create(0.2, cc.p(-lensBox:getContentSize().width,0)))
                lensBoxFlag = not lensBoxFlag
            end
            end)
        

        --槽位主副标志
        local imgpath
        if i==1 then
            imgpath = "#Embattle_Img49.png"
        else
            imgpath = "#Embattle_Img50.png"
        end
        self.caoWei[i].label = display.newSprite(imgpath)
        :addTo(pao)
        :pos(caoweiPos[i].x, caoweiPos[i].y)
        self.caoWei[i].pos = self.caoWei[i].label:convertToWorldSpace(self.caoWei[i].label:getAnchorPointInPoints())

        --空白图片，用于镜片拖拽的载体
        self.caoWei[i].box = display.newSprite("#Embattle_Img54.png")
        :addTo(pao,0,i+100)
        :pos(caoweiPos[i].x, caoweiPos[i].y)


        if i~=1 then
            self.caoWei[i].button:setScale(0.88)
            self.caoWei[i].box:setScale(0.88)
        end
    end

    --底条，显示属性的
    local bottomBar = display.newSprite("#Embattle_Img5.png")
    :addTo(self)
    :pos(0,30)
    bottomBar:setAnchorPoint(0,0)
    local bottomH = bottomBar:getContentSize().height

    self.lensAttriNum = {}
    local attriLab1 = cc.ui.UILabel.new({UILabelType = 2, text = "目标数量：", size = 20,color = cc.c3b(46,167,224)})
    :addTo(bottomBar)
    :pos(10, bottomH/2)
    self.lensAttriNum[1] = cc.ui.UILabel.new({UILabelType = 2, text = "0", size = 20})
    :addTo(bottomBar)
    :pos(10+attriLab1:getContentSize().width, bottomH/2)

    local attriLab2 = cc.ui.UILabel.new({UILabelType = 2, text = "最终伤害率：", size = 20,color = cc.c3b(46,167,224)})
    :addTo(bottomBar)
    :pos(150, bottomH/2)
    self.lensAttriNum[2] = cc.ui.UILabel.new({UILabelType = 2, text = "0", size = 20})
    :addTo(bottomBar)
    :pos(150+attriLab2:getContentSize().width, bottomH/2)

    local attriLab3 = cc.ui.UILabel.new({UILabelType = 2, text = "附带特效：", size = 20,color = cc.c3b(46,167,224)})
    :addTo(bottomBar)
    :pos(330, bottomH/2)
    self.lensAttriNum[3] = cc.ui.UILabel.new({UILabelType = 2, text = "无", size = 20})
    :addTo(bottomBar)
    :pos(330+attriLab3:getContentSize().width, bottomH/2)

    --强化强化激光炮
    local strengthBt = cc.ui.UIPushButton.new("#Embattle_Img74.png")
    :addTo(self)
    :pos(display.cx-70, 30)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:createStrengthBox()
        end)
    display.newSprite("#Embattle_Img75.png")
    :addTo(strengthBt)

    --重置组合
    local resetComBt = cc.ui.UIPushButton.new("#Embattle_Img74.png")
    :addTo(self)
    :pos(display.cx+40, 30)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        --槽位信息清空
        for i=1,4 do
            self.caoWei[i].isUse = false
            if self.caoWei[i].node then
                self.caoWei[i].node:removeSelf()
                self.caoWei[i].node = nil 
            end
        end
        --镜片信息清空
        for i=1,#self.lensItemTable do
            self.lensItemTable[i].caoweiIdx = 0
            if self.lensItemTable[i].gou then
                -- self.lensItemTable[i].gou:removeSelf()
                self.lensItemTable[i].gou = nil
            end
        end
       
        EmbattleMgr.curInfo.matrix.laser1 = 0
        EmbattleMgr.curInfo.matrix.laser2 = 0
        EmbattleMgr.curInfo.matrix.laser3 = 0
        if srv_userInfo.vip<9 then
            EmbattleMgr.curInfo.matrix.laser4 = -1
        else
            EmbattleMgr.curInfo.matrix.laser4 = 0
        end

        self.lensDrag:removeSelf()
        self.lensDrag = nil

        self.tId = {}
        -- self:performWithDelay(function ()
        self:reloadLensLv()
        -- end,0.01)
        self:CalculationLensAttri()
    end)
    display.newSprite("#Embattle_Img76.png")
    :addTo(resetComBt)

    
    --装载的镜片模板和是否主槽位（分类型）
    self.lensType1 = {}
    self.lensType2 = {}
    self.lensType3 = {}
    -- --上传服务器的激光炮信息
    -- self.laser1 = 0
    -- self.laser2 = 0
    -- self.laser3 = 0
    -- self.laser4 = 0
    --获取镜片
    self.lensItemTable = getBpItemByType(3)
end
function LaserCannon:onEnter()
    LaserCannon.Instance = self
    self.tmpCnt = 0

end
function LaserCannon:onExit()
    LaserGunInfo = {
       targetNum = self.targetNum,  --目标数量
       damageAdd = self.damageAdd,  --伤害加成
       buffId    = self.buffId,     --BUFF
    }
    if self.buffId == nil then
        LaserGunInfo.buffId = 0
    end
    if self.targetNum == nil then
        LaserGunInfo.targetNum = 0
    end
    if self.damageAdd == nil then
        LaserGunInfo.damageAdd = 0
    end
    LaserCannon.Instance = nil

    if self.timeHandle then
        scheduler.unscheduleGlobal(self.timeHandle)
    end
end

local Attribute_pos = {
    {x=110,y=47},
    {x=110,y=22},
}
--镜片列表
--isChangeTab 是否是切换上方分栏，如果是切换分栏刷新就不需要做上装操作
function LaserCannon:reloadLensLv(isChangeTab)
    self.lensLv:removeAllItems()
    for i,value in ipairs(self.lensItemTable) do
        -- local value = self.lensItemTable[curIdx]
        if self.tabType==1 or (self.tabType==2 and getItemType(value.tmpId)==803) 
            or (self.tabType==3 and getItemType(value.tmpId)==802) 
            or (self.tabType==4 and getItemType(value.tmpId)==801) then

            local item = self.lensLv:newItem()
            local content = display.newNode()
            

            if not isChangeTab then
                self.lensItemTable[i].caoweiIdx = 0
            end
            local _size = cc.size(400,110)
            local bar = display.newScale9Sprite("common2/com2_Img_7.png",nil,nil,_size,cc.rect(105,31,125,31))
            :addTo(content)
            :pos(-5, 0)

            if i== 1 then
                self.guideBt = bar
            end
            --图标
            local iconImg = createItemIcon(value.tmpId)
            :addTo(content,0,11)
            :pos(-145,0)
            :scale(0.75)
            --名字
            local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 23, color=cc.c3b(46, 167, 224)})
            :addTo(bar)
            :pos(110, 80)
            name:setString(itemData[value.tmpId].name)
            --星级
            local starNum = getItemStar(value.tmpId)
            for i=1,starNum do
                local star = display.newSprite("common/common_Star.png")
                :addTo(bar)
                :pos(100+(i*30)+name:getContentSize().width, 85)
                star:setScale(0.9)
            end

            --属性
            local localItem = itemData[value.tmpId]
            if localItem.type==801 then
                local lab = cc.ui.UILabel.new({UILabelType = 2, text = "附带特效：", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x, Attribute_pos[1].y)
                :addTo(bar)
                
                cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color= cc.c3b(0, 255, 0)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x+lab:getContentSize().width, Attribute_pos[1].y)
                :addTo(bar)
                :setString(buffData[localItem.buffId].name)
            elseif localItem.type==802 then
                local lab = cc.ui.UILabel.new({UILabelType = 2, text = "目标数量：", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x, Attribute_pos[1].y)
                :addTo(bar)
                cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x+lab:getContentSize().width, Attribute_pos[1].y)
                :addTo(bar)
                :setString(localItem.num)
                

                local lab2 = cc.ui.UILabel.new({UILabelType = 2, text = "初始伤害率：", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[2].x, Attribute_pos[2].y)
                :addTo(bar)
                cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[2].x+lab2:getContentSize().width, Attribute_pos[2].y)
                :addTo(bar)
                :setString(100*localItem.atkPercent.."%")
            elseif localItem.type==803 then
                local lab = cc.ui.UILabel.new({UILabelType = 2, text = "额外伤害率：", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x, Attribute_pos[1].y)
                :addTo(bar)

                cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20, color= cc.c3b(185, 247, 255)})
                :align(display.CENTER_LEFT, Attribute_pos[1].x+lab:getContentSize().width, Attribute_pos[1].y)
                :addTo(bar)
                :setString(100*localItem.atkPercent.."%")
            end

            if isChangeTab and self.lensItemTable[i].caoweiIdx>0 then
                --选中的已装备
                self.lensItemTable[i].gou = display.newSprite("SingleImg/BackPack/eptImg.png")
                :addTo(iconImg)
                :align(display.RIGHT_BOTTOM,48, -48)
                :scale(1/0.75)
            end
            
            if not isChangeTab then
                --初始镜片信息
                local tId = self.tId
                self.tmpCnt = 0
                for j=1,#tId do
                    self.tmpCnt = self.tmpCnt + tId[j]
                    self.lenCaoCurIdx = j
                    if tId[j]>0 and tId[j]==value.id then
                        self:createAndMoveLensIcon(value, true, i, iconImg)
                    end
                end
            end
            
        -- end
            item:addContent(content)
            item:setItemSize(_size.width, _size.height)
            item:setTag(i)
            self.lensLv:addItem(item)
        end
    end
    self.lensLv:reload()

    if not isChangeTab and self.tmpCnt<=0 then
        self:loadLensDrag()
    end
end
function LaserCannon:lensListOnTouch(event)
    if event.name == "clicked" then
        local i = event.item:getTag()
        local value = self.lensItemTable[i]
        if self.lensItemTable[i].caoweiIdx == 0 then --装上去
            self.lenCaoCurIdx = 0
            --找到第一个空槽位
            for i=1,#self.caoWei do
                if self.caoWei[i].isUse==false then
                    self.lenCaoCurIdx = i
                    break
                end
            end
            -- print(self.lenCaoCurIdx)
            --槽位是否填满
            if self.lenCaoCurIdx==0 then
                showTips("槽位已填满")
                return
            elseif self.lenCaoCurIdx==4 and 
                    (srv_userInfo.vip<9 or EmbattleMgr.curInfo.matrix.laser4==-1 ) then
                showTips("槽位已填满，VIP9可开启第四个槽位")
                return
            end
            --该类型镜片装载数量限制
            self:getLensByType()
            local mtype = getItemType(value.tmpId)
            if mtype==801 and #self.lensType1.tmpId>=1 then
                showTips("特效型镜片最多装载1个")
                return
            elseif mtype==802 and #self.lensType2.tmpId>=2 then
                showTips("数量型镜片最多装载2个")
                return
            elseif mtype==803 and #self.lensType3.tmpId>=3 then
                showTips("伤害型镜片最多装载3个")
                return
            end
            self:createAndMoveLensIcon(
                value, nil, i, event.item:getChildByTag(11):getChildByTag(11))
            GuideManager:_addGuide_2(11307, self:getParent(),handler(self:getParent(),self:getParent().caculateGuidePos),1111)
        else
            self:moveAndremoveLensIcon(i, event.item:getChildByTag(11):getChildByTag(11))
        end
    end
end
--装载镜片
function LaserCannon:createAndMoveLensIcon(value, isInit, curIdx, target)
    local tmpId = value.tmpId
    --startPos 空值，表示初始信息处理，不需要动作过程
    if not isInit then
        if self.lenCaoCurIdx==1 then
            EmbattleMgr.curInfo.matrix.laser1 = value.id
        elseif self.lenCaoCurIdx==2 then
             EmbattleMgr.curInfo.matrix.laser2 = value.id
        elseif self.lenCaoCurIdx==3 then
             EmbattleMgr.curInfo.matrix.laser3 = value.id
        elseif self.lenCaoCurIdx==4 then
             EmbattleMgr.curInfo.matrix.laser4 = value.id
        end
    end

    -- self.lensItemTable[curIdx].isSelect = 1
    local bottomImg
    if getItemStar(tmpId)==3 then
        bottomImg = "#Embattle_Img57.png"
    elseif getItemStar(tmpId)==4 then
        bottomImg = "#Embattle_Img58.png"
    elseif getItemStar(tmpId)==5 then
        bottomImg = "#Embattle_Img59.png"
    end

    local star = getItemStar(tmpId)
    local icon = display.newSprite("#Embattle_Img"..(54+star)..".png")
    if self.lenCaoCurIdx==1 then
        icon:scale(0.9)
    else
        icon:scale(0.8)
    end
    local img = display.newSprite("Item/item_"..itemData[tmpId].resId..".png")
    :addTo(icon)
    :pos(icon:getContentSize().width/2, icon:getContentSize().height/2)
    :scale(0.9)

    self.lensItemTable[curIdx].caoweiIdx = self.lenCaoCurIdx --记录当前这个镜片放在哪个槽位
    self.caoWei[self.lenCaoCurIdx].node = icon --记录当前这个镜片
    --选中的勾（已装备）
    self.lensItemTable[curIdx].gou = display.newSprite("SingleImg/BackPack/eptImg.png")
    :addTo(target)
    :align(display.RIGHT_BOTTOM,48, -48)
    :scale(1/0.75)
    
    -- print(isInit)
    if not isInit then
        local dragItem =self.lensDrag:find(self.caoWei[self.lenCaoCurIdx].box)
        icon:retain()
        icon:removeFromParent()
        icon:release()
        dragItem:setDragObj(nil)
        dragItem:setDragObj(icon)
        -- icon = nil
        lensEff1(target,target:getContentSize().width/2 ,target:getContentSize().height/2-5)
        local tmpNode = self.caoWei[self.lenCaoCurIdx].box
        lensEff2(icon,icon:getContentSize().width/2 ,icon:getContentSize().height/2, 1.1)
    else
        target:setButtonEnabled(true)
        self:loadLensDrag()
    end
    

    self.caoWei[self.lenCaoCurIdx].isUse = true
    self:CalculationLensAttri()

end
--卸载镜片
function LaserCannon:moveAndremoveLensIcon(curIdx, target)
    self.lenCaoCurIdx = self.lensItemTable[curIdx].caoweiIdx
    if self.lenCaoCurIdx==1 then
        EmbattleMgr.curInfo.matrix.laser1 = 0
    elseif self.lenCaoCurIdx==2 then
         EmbattleMgr.curInfo.matrix.laser2 = 0
    elseif self.lenCaoCurIdx==3 then
         EmbattleMgr.curInfo.matrix.laser3 = 0
    elseif self.lenCaoCurIdx==4 then
         EmbattleMgr.curInfo.matrix.laser4 = 0
    end
    self.lensItemTable[curIdx].caoweiIdx = 0

    local dragItem =self.lensDrag:find(self.caoWei[self.lenCaoCurIdx].box)
    dragItem:setDragObj(nil)
    dragItem = nil
    -- self.caoWei[self.lenCaoCurIdx].node:removeSelf()
    self.lensItemTable[curIdx].gou:removeSelf()
    self.caoWei[self.lenCaoCurIdx].node = nil 
    self.lensItemTable[curIdx].gou = nil


    self.caoWei[self.lenCaoCurIdx].isUse = false
    self:CalculationLensAttri()

    lensEff3(target,target:getContentSize().width/2 ,target:getContentSize().height/2)
    local tmpNode = self.caoWei[self.lenCaoCurIdx].box
    lensEff4(tmpNode,tmpNode:getContentSize().width/2+1 ,tmpNode:getContentSize().height/2-8, 1.1)
end
--计算各个类型镜片
function LaserCannon:getLensByType()
    self.lensType1.tmpId = {}
    self.lensType1.idx = {}
    self.lensType2.tmpId = {}
    self.lensType2.idx = {}
    self.lensType3.tmpId = {}
    self.lensType3.idx = {}
    for i,value in pairs(self.lensItemTable) do
        if value.caoweiIdx and value.caoweiIdx>0 then
            local mtype = getItemType(value.tmpId)
            if mtype==801 then
                table.insert(self.lensType1.tmpId, value.tmpId)
                table.insert(self.lensType1.idx, value.caoweiIdx)
            elseif mtype==802 then
                table.insert(self.lensType2.tmpId, value.tmpId)
                table.insert(self.lensType2.idx, value.caoweiIdx)
            elseif mtype==803 then
                table.insert(self.lensType3.tmpId, value.tmpId)
                table.insert(self.lensType3.idx, value.caoweiIdx)
            end
        end
    end
end
--计算激光炮属性值
function LaserCannon:CalculationLensAttri()
    -- print("计算激光炮属性值")
    self:getLensByType()

    if #self.lensType1.tmpId==0 and #self.lensType2.tmpId==0 and #self.lensType3.tmpId==0 then
        self.lensAttriNum[1]:setString("0")
        self.lensAttriNum[2]:setString("0")
        self.lensAttriNum[3]:setString("无")
        self.targetNum = 0
        self.damageAdd = 0
        self.buffId = 0
        return
    end

    local speciEff = "无"
    --附带特效
    if #self.lensType1.tmpId>0 then
        local tmpId = self.lensType1.tmpId[1]
        if self.lensType1.idx[1]==1 then --主槽位时用buff2
            speciEff = buffData[itemData[tmpId].buffId2].name
            self.buffId = itemData[tmpId].buffId2
        else
            speciEff = buffData[itemData[tmpId].buffId].name
            self.buffId = itemData[tmpId].buffId
        end
    else
        speciEff = "无"
    end
    self.lensAttriNum[3]:setString(speciEff)
    
    --目标数量
    local tmpDamage = 0.9 --数量型镜片伤害率
    local allTargetNum = 1
    if #self.lensType2.tmpId==1 then --一个镜片
        -- print("num si 1")
        allTargetNum = itemData[self.lensType2.tmpId[1]].num
        tmpDamage = itemData[self.lensType2.tmpId[1]].atkPercent
        if self.lensType2.idx[1]==1 then --主槽位时数量加1
            allTargetNum = allTargetNum + 1
        end
    elseif #self.lensType2.tmpId==2 then --两个镜片
        -- print("num si 2")
        local tmpNum = {}
        for i=1,#self.lensType2.tmpId do
            tmpNum[i] = itemData[self.lensType2.tmpId[i]].num
            if self.lensType2.idx[i]==1 then --主槽位时数量加1
                tmpNum[i] = tmpNum[i] + 1
            end
        end
        -- printTable(tmpNum)
        local final
        if tmpNum[1]==tmpNum[2] then --两个数量相同时，伤害率低的生效
            if itemData[self.lensType2.tmpId[1]].atkPercent<=itemData[self.lensType2.tmpId[2]].atkPercent then
                final = 1
            else
                final =2
            end
        elseif tmpNum[1]>tmpNum[2] then
            final = 1
        elseif tmpNum[1]<tmpNum[2] then
            final = 2
        end
        allTargetNum = tmpNum[final]
        local oNum
        if final==1 then oNum=2 else oNum=1 end
        tmpDamage = itemData[self.lensType2.tmpId[final]].atkPercent-
            itemData[self.lensType2.tmpId[oNum]].atkPercent*0.1
        --有个数量型时，最终的那个数量加1
        allTargetNum = allTargetNum + 1
    end
    self.lensAttriNum[1]:setString(allTargetNum)
    self.targetNum = allTargetNum

    --伤害率
    local damageRate = tmpDamage
    if #self.lensType3.tmpId>0 then
        for i=1,#self.lensType3.tmpId do
            local tmpN = itemData[self.lensType3.tmpId[i]].atkPercent
            if self.lensType3.idx[i]==1 then
                tmpN = tmpN + 0.1
            end
            damageRate = damageRate + tmpN
        end

    else
        damageRate = tmpDamage
    end
    self.lensAttriNum[2]:setString(100*damageRate.."%")
    self.damageAdd = damageRate

end
--传给远征的接口,获取激光炮属性
function getLaserCannonAttri(lensTmpIds)
    print("getLaserCannonAttri")
    printTable(lensTmpIds)
    local lensType1 = {}
    lensType1.tmpId = {}
    lensType1.idx = {}
    local lensType2 = {}
    lensType2.tmpId = {}
    lensType2.idx = {}
    local lensType3 = {}
    lensType3.tmpId = {}
    lensType3.idx = {}

    for i,id in pairs(lensTmpIds) do
        if id and id>0 then
            -- print(srv_carEquipment["bp"][id].tmpId)
            if srv_carEquipment["bp"][id] then
                local tmpId = srv_carEquipment["bp"][id].tmpId
                local mtype = getItemType(tmpId)
                if mtype==801 then
                    table.insert(lensType1.tmpId, tmpId)
                    table.insert(lensType1.idx, i)
                elseif mtype==802 then
                    table.insert(lensType2.tmpId, tmpId)
                    table.insert(lensType2.idx, i)
                elseif mtype==803 then
                    table.insert(lensType3.tmpId, tmpId)
                    table.insert(lensType3.idx, i)
                end
            end
            
        end
    end

    if #lensType1.tmpId==0 and #lensType2.tmpId==0 and #lensType3.tmpId==0 then
        LaserGunInfo.targetNum = 0
        LaserGunInfo.damageAdd = 0
        LaserGunInfo.buffId = 0
        return
    end

    --附带特效
    local buffId = nil
    if #lensType1.tmpId>0 then
        local tmpId = lensType1.tmpId[1]
        if lensType1.idx[1]==1 then --主槽位时用buff2
            buffId = itemData[tmpId].buffId2
        else
            buffId = itemData[tmpId].buffId
        end
    end

    --目标数量
    local tmpDamage = 0.9 --数量型镜片伤害率
    local allTargetNum = 1
    if #lensType2.tmpId==1 then --一个镜片
        -- print("num si 1")
        allTargetNum = itemData[lensType2.tmpId[1]].num
        tmpDamage = itemData[lensType2.tmpId[1]].atkPercent
        if lensType2.idx[1]==1 then --主槽位时数量加1
            allTargetNum = allTargetNum + 1
        end
    elseif #lensType2.tmpId==2 then --两个镜片
        -- print("num si 2")
        local tmpNum = {}
        for i=1,#lensType2.tmpId do
            tmpNum[i] = itemData[lensType2.tmpId[i]].num
            if lensType2.idx[i]==1 then --主槽位时数量加1
                tmpNum[i] = tmpNum[i] + 1
            end
        end
        local final
        if tmpNum[1]==tmpNum[2] then --两个数量相同时，伤害率低的生效
            if itemData[lensType2.tmpId[1]].atkPercent<=itemData[lensType2.tmpId[2]].atkPercent then
                final = 1
            else
                final =2
            end
        elseif tmpNum[1]>tmpNum[2] then
            final = 1
        elseif tmpNum[1]<tmpNum[2] then
            final = 2
        end
        allTargetNum = tmpNum[final]
        local oNum
        if final==1 then oNum=2 else oNum=1 end
        tmpDamage = itemData[lensType2.tmpId[final]].atkPercent-
            itemData[lensType2.tmpId[oNum]].atkPercent*0.1
        --有个数量型时，最终的那个数量加1
        allTargetNum = allTargetNum + 1
    end

    --伤害率
    local damageRate = tmpDamage
    if #lensType3.tmpId>0 then
        for i=1,#lensType3.tmpId do
            local tmpN = itemData[lensType3.tmpId[i]].atkPercent
            if lensType3.idx[i]==1 then
                tmpN = tmpN + 0.1
            end
            damageRate = damageRate + tmpN
        end

    else
        damageRate = tmpDamage
    end

    LaserGunInfo.targetNum = allTargetNum
    LaserGunInfo.damageAdd = damageRate
    LaserGunInfo.buffId = buffId
end
--布阵信息返回后激光炮数据UI处理
function LaserCannon:initLensAttri()
    --初始返回的信息处理是否有勾
    local tId = {}
    for i=1,4 do
        if i==1 then
            tId[i] = EmbattleMgr.curInfo.matrix.laser1
            if tId[i]>0 then
                self.caoWei[1].isUse = true
            end
        elseif 2==i then
            tId[i] = EmbattleMgr.curInfo.matrix.laser2
            if tId[i]>0 then
                self.caoWei[2].isUse = true
            end
        elseif 3==i then
            tId[i] = EmbattleMgr.curInfo.matrix.laser3
            if tId[i]>0 then
                self.caoWei[3].isUse = true
            end
        elseif 4==i then
            tId[i] = EmbattleMgr.curInfo.matrix.laser4
            if tId[i]>0 then
                self.caoWei[4].isUse = true
            end
        end
    end
    self.tId = tId

    if EmbattleMgr.curInfo.matrix.laser4==-1 then
        local frame = display.newSpriteFrame("vipUnlock_04.png")
        self.caoWei[4].label:setSpriteFrame(frame)
    else
        local frame = display.newSpriteFrame("Embattle_Img50.png")
        self.caoWei[4].label:setSpriteFrame(frame)
    end

    self.lensDrag = nil
    
end
--镜片拖拽
function LaserCannon:loadLensDrag()
    -- print("镜片拖拽")
    -- if true then
    --     return
    -- end
    if self.lensDrag then
        self.lensDrag:removeDragAll()
        self.lensDrag:removeFromParent()
        self.lensDrag = nil
    end
    --创建拖拽对象
    self.lensDrag = UIDrag.new()
    self:addChild(self.lensDrag,10)
    --支持交换拖拽
    self.lensDrag.isExchangeModel = true
    self.lensDrag:setTouchSwallowEnabled(false)

    --拖拽前事件
    self.lensDrag:setOnDragUpBeforeEvent(function(currentItem,point)
        return true
    end)
    --拖拽放下之前
    self.lensDrag:setOnDragDownBeforeEvent(function(currentItem,targetItem,point)
        if targetItem then
            --背包内部操作
            if currentItem:getGroup() == 1000 and targetItem:getGroup() == 1000 then
                --物品交换只允许在背包内部
                if currentItem.dragObj and targetItem.dragObj then
                    return true
                elseif not targetItem.dragObj then
                    --背包空拖拽
                    return true
                end
            end
        end

        return false
    end)
    --拖拽放下之后
    self.lensDrag:setOnDragDownAfterEvent(function(currentItem,targetItem,point)
        print("放下成功")
        --交换位置后做相应的数据修改
        --放下成功后，currentItem.dragObj与targetItem.dragObj的位置是交换的
        if currentItem then
            if currentItem:getGroup()==targetItem:getGroup()then
                local  idx1 = currentItem.dragBox:getTag()-100
                local idx2 = targetItem.dragBox:getTag()-100
                if currentItem.dragObj and targetItem.dragObj then
                    --两个物品交换
                    self.caoWei[idx1].node = currentItem.dragObj
                    self.caoWei[idx2].node = targetItem.dragObj
                elseif not currentItem.dragObj then
                    --一个物品交换
                    self.caoWei[idx1].node = nil
                    self.caoWei[idx1].isUse = false
                    self.caoWei[idx2].node = targetItem.dragObj
                    self.caoWei[idx2].isUse = true
                end
                local valId1, valId2=0, 0
                --将镜片中的槽位属性修改
                for i,val in pairs(self.lensItemTable) do
                    if val.caoweiIdx==idx1 then
                        self.lensItemTable[i].caoweiIdx = idx2
                        valId1 = val.id
                    elseif val.caoweiIdx==idx2 then
                        self.lensItemTable[i].caoweiIdx = idx1
                        valId2 = val.id
                    end
                end
                --交换后，上传的镜片信息修改
                for i,val in pairs(self.caoWei) do
                    local tmp = idx1
                    if 1==i then
                        if idx1==1 then
                            EmbattleMgr.curInfo.matrix.laser1 = valId2
                        elseif idx2==1 then
                            EmbattleMgr.curInfo.matrix.laser1 = valId1
                        end
                    elseif 2==i then
                        if idx1==2 then
                            EmbattleMgr.curInfo.matrix.laser2 = valId2
                        elseif idx2==2 then
                            EmbattleMgr.curInfo.matrix.laser2 = valId1
                        end
                    elseif 3==i then
                        if idx1==3 then
                            EmbattleMgr.curInfo.matrix.laser3 = valId2
                        elseif idx2==3 then
                            EmbattleMgr.curInfo.matrix.laser3 = valId1
                        end
                    elseif 4==i then
                        if idx1==4 then
                            EmbattleMgr.curInfo.matrix.laser4 = valId2
                        elseif idx2==4 then
                            EmbattleMgr.curInfo.matrix.laser4 = valId1
                        end
                    end
                end
                --交换位置后，重新计算属性
                -- print("交换位置后，重新计算属性")
                self:CalculationLensAttri()
                if self.caoWei[idx1].node then
                    if idx1==1 then
                        self.caoWei[idx1].node:setScale(0.9)
                    else
                        self.caoWei[idx1].node:setScale(0.8)
                    end
                end
                if self.caoWei[idx2].node then
                    if idx2==1 then
                        self.caoWei[idx2].node:setScale(0.9)
                    else
                        self.caoWei[idx2].node:setScale(0.8)
                    end
                end
            end
        end
    end)
    --让激光槽具备拖拽属性,设置激光槽的属性标记tag
    for i=1,4 do
        local tag = 1000
        if i==4 and EmbattleMgr.curInfo.matrix.laser4==-1 then
            tag = 1001
        end
        self.lensDrag:addDragItem(self.caoWei[i].box):setGroup(tag)
        --镜片放到槽位里
        if self.caoWei[i].node then
            self.lensDrag:find(self.caoWei[i].box):setDragObj(self.caoWei[i].node)
        end
    end
end
--激光炮强化进阶
function LaserCannon:createStrengthBox()
    local masklayer =  UIMasklayer.new()
    :addTo(display.getRunningScene(), 52)
    local function  func()
        masklayer:removeSelf()
        self.strenNode = nil
    end
    masklayer:setOnTouchEndedEvent(func)

    local strenBox = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    masklayer:addHinder(strenBox)
    local boxsize = strenBox:getContentSize()

    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(strenBox)
    :pos(boxsize.width-15, boxsize.height-15)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        self.strenNode = nil
        end)

    local laserLvl = self.matrix.laserLvl
    self.strenNode = {}
    local msize = 28
    local fixX = 150
    local mcolor = cc.c3b(186, 175, 149)
    local mcolor2 = cc.c3b(92, 175, 90)
    --强化等级
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "强化等级：", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX, boxsize.height - 100)
    self.strenNode.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX+label:getContentSize().width, boxsize.height - 100-2)
    if laserLvl<90 then
        self.strenNode.level2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor2})
        :addTo(strenBox)
        :pos(0, label:getPositionY())
    end

    --基础攻击
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "基础攻击：", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX, boxsize.height - 170)
    self.strenNode.attack = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX+label:getContentSize().width, boxsize.height - 170-2)
    if laserLvl<90 then
        self.strenNode.Arrow = display.newSprite("common/common_arrow1.png")
        :addTo(strenBox)
        :pos(0, label:getPositionY())
        
        self.strenNode.attack2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor2})
        :addTo(strenBox)
        :pos(0, label:getPositionY())
    end

    display.newSprite("common/common_arrow2.png")
        :addTo(strenBox)
        :pos(boxsize.width - 150, label:getPositionY())

    --能量恢复
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "能量恢复：", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX, boxsize.height - 240)
    self.strenNode.erecover = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor})
    :addTo(strenBox)
    :pos(fixX+label:getContentSize().width, boxsize.height - 240-2)
    if laserLvl<90 then
        self.strenNode.erecover2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = mcolor2})
        :addTo(strenBox)
        :pos(0, label:getPositionY())
    end

    --消耗
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "消耗：", size = msize, color = MYFONT_COLOR})
    :addTo(strenBox)
    :pos(60, 220)
    local goldIcon = display.newSprite("common/common_GoldGet.png")
    :addTo(strenBox)
    :align(display.CENTER_LEFT, label:getPositionX()+label:getContentSize().width, 237)
    :scale(0.8)
    self.strenNode.gold = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = msize, color = cc.c3b(183, 146, 95)})
    :addTo(strenBox)
    :pos(goldIcon:getPositionX()+goldIcon:getContentSize().width, 220)

    --分割线
    display.newLine({{50, 200}, {boxsize.width/2-10,200}}, 
        {borderColor = cc.c4f(0.32, 0.33, 0.33, 1.0), borderWidth = 3})
    :addTo(strenBox)
    display.newLine({{boxsize.width/2-10, 200}, {boxsize.width/2+10,195}}, 
        {borderColor = cc.c4f(0.32, 0.33, 0.33, 1.0), borderWidth = 3})
    :addTo(strenBox)
    display.newLine({{boxsize.width/2+10,195}, {boxsize.width-50,195}}, 
        {borderColor = cc.c4f(0.32, 0.33, 0.33, 1.0), borderWidth = 3})
    :addTo(strenBox)

    --冷却时间
    self.strenNode.cdlabel = cc.ui.UILabel.new({UILabelType = 2, text = "冷却时间：", size = msize, color = MYFONT_COLOR})
    :addTo(strenBox)
    :pos(boxsize.width/2+80, 175)
    self.strenNode.cdTime = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "00:00", size = msize, color = cc.c3b(92, 175, 90)})
    :addTo(strenBox)
    :pos(boxsize.width/2+210, 175)


    --强化按钮
    local strengthBt = cc.ui.UIPushButton.new({
        normal = "common/common_GBt1.png",
        pressed = "common/common_GBt1.png"
        })
    :addTo(strenBox)
    :pos(boxsize.width/2, 90)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    strengthBt:onButtonClicked(function(event)
        if self.laserAdvTime>=1000 then
            showTips("冷却完后才能继续强化")
            return
        end
        if srv_userInfo.level<self.matrix.laserLvl then
            showTips("强化等级不能高于战队等级")
            return
        end
        if not self.isgold then
            showTips("金币不足")
            return
        end
        startLoading()
        local sendData = {}
        m_socket:SendRequest(json.encode(sendData), CMD_LASERSTRENGTH, self, self.onLaserStrength)
        end)
    display.newSprite("common/common_text15.png")
    :addTo(strengthBt)
    :scale(0.5)

    self.isgold =  self:reloadStrengthData(self.strenNode)

end
function LaserCannon:reloadStrengthData(strenNodes)
    local laserLvl = self.matrix.laserLvl
    -- self.laserAdvTime = self.matrix.laserAdvTime
    local locTabs, allAtk, allerecover = {}, 0, 0
    local locTab=nil
    for i,value in pairs(laserCannonData) do
        if laserLvl>=value.slevel then
            table.insert(locTabs, value)
        end
    end
    -- printTable(locTabs)
    for i,value in ipairs(locTabs) do
        for j=value.slevel,value.elevel do
            if j>=laserLvl then
                locTab = value
                break
            end
            if j%2~=0 then
                allAtk = allAtk + value.attack
            else
                allerecover = allerecover + value.erecover
            end
        end
    end

    strenNodes.level:setString(laserLvl)
    strenNodes.attack:setString(allAtk)
    strenNodes.erecover:setString(100*allerecover.."%")
    strenNodes.gold:setString(locTab.gold)
    if laserLvl<90 then
        self.strenNode.Arrow:setVisible(true)
         self.strenNode.Arrow:setPositionX(strenNodes.attack:getPositionX()+strenNodes.attack:getContentSize().width+60)

        self.strenNode.level2:setPositionX(strenNodes.Arrow:getPositionX()+strenNodes.Arrow:getContentSize().width+10)
        self.strenNode.level2:setString(laserLvl+1)

        self.strenNode.attack2:setPositionX(strenNodes.Arrow:getPositionX()+strenNodes.Arrow:getContentSize().width+10)
        if laserLvl%2~=0 then
            allAtk = allAtk + locTab.attack
        end
        self.strenNode.attack2:setString(allAtk)

        self.strenNode.erecover2:setPositionX(strenNodes.Arrow:getPositionX()+strenNodes.Arrow:getContentSize().width+10)
        if laserLvl%2==0 then
            allerecover = allerecover + locTab.erecover
        end
        self.strenNode.erecover2:setString(100*allerecover.."%")
    else
        self.strenNode.level2:setVisible(false)

        self.strenNode.Arrow:setVisible(false)
        self.strenNode.attack2:setVisible(false)

        self.strenNode.erecover2:setVisible(false)
    end

    -- print(self.laserAdvTime)
    if self.laserAdvTime<1000 then
        self.strenNode.cdlabel:setVisible(false)
        self.strenNode.cdTime:setVisible(false)
    else
        self.strenNode.cdlabel:setVisible(true)
        self.strenNode.cdTime:setVisible(true)
        self.strenNode.cdTime:setString(GetTimeStr(self.laserAdvTime))
    end
    
    return srv_userInfo.gold>=locTab.gold
end
function LaserCannon:onInterval()
    if self.laserAdvTime>=1000 then
        self.laserAdvTime = self.laserAdvTime - 1000
        if self.strenNode and self.strenNode.cdTime then
            self.strenNode.cdlabel:setVisible(true)
            self.strenNode.cdTime:setVisible(true)
            self.strenNode.cdTime:setString(GetTimeStr(self.laserAdvTime))
        end
    else
        if self.strenNode then
            self.strenNode.cdlabel:setVisible(false)
            self.strenNode.cdTime:setVisible(false)
        end
        scheduler.unscheduleGlobal(self.timeHandle)
    end
    -- print(GetTimeStr(self.laserAdvTime))
end

--开启激光炮槽位返回
function LaserCannon:onOpenLaser(result)
    endLoading()
    if result.result==1 then
        EmbattleMgr.curInfo.matrix.laser4 = 0
        local frame = display.newSpriteFrame("Embattle_Img50.png")
        self.caoWei[4].label:setSpriteFrame(frame)
    else
        showTips(result.msg)
    end
end
--布阵信息返回
function LaserCannon:OnEmbattleInfoRet(cmd)
    if 1==cmd.result then
        self.matrix = cmd.data.matrix
        self.laserAdvTime = self.matrix.laserAdvTime
        self.timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
        if EmbattleScene.Instance.bHidePull then
            self:initLensAttri()
            self:reloadLensLv()
        end
    else
        showTips(cmd.msg)
    end
    endLoading()
end
--激光炮强化
function LaserCannon:onLaserStrength(result)
    if result.result==1 then
        showTips("强化成功")
        EmbattleMgr.curInfo.matrix.laserLvl = EmbattleMgr.curInfo.matrix.laserLvl + 1
        local laserLvl = EmbattleMgr.curInfo.matrix.laserLvl
        local locTab=nil
        for i,value in pairs(laserCannonData) do
            if laserLvl>=value.slevel and laserLvl<=value.elevel then
                locTab = value
                break
            end
        end
        print("locTab")
        printTable(locTab)
        self.laserAdvTime = tonumber(locTab.cd*60*1000)
        print(self.laserAdvTime)
        self.matrix = EmbattleMgr.curInfo.matrix
        self.timeHandle = scheduler.scheduleGlobal(handler(self, self.onInterval), 1)
        self:reloadStrengthData(self.strenNode)
    else
        showTips(result.msg)
    end
end

function LaserCannon:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 11306==_guideId then
        g_node = self.guideBt
        size = g_node:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
        printTable(midPos)

        midPos = g_node:convertToWorldSpace(cc.p(size.width,size.height/2))
        midPos.x = 200
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return LaserCannon