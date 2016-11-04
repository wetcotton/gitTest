-- @Author: anchen
-- @Date:   2016-09-26 11:13:51
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-27 18:34:14
local skillPreset = class("skillPreset",function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

local sklSortData = {}  --技能顺序
local curSortList = "" --当前的技能顺序

function skillPreset:ctor(_sortList)
    self.sortList = _sortList

    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)


    --材料信息框
    local box = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy,
        cc.size(1100, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(box)
    self.box = box
    local tmpsize = box:getContentSize()
    self.tmpsize = tmpsize

    local help = cc.ui.UIPushButton.new("common2/com2_img_26.png")
    :addTo(box,2)
    :pos(50, box:getContentSize().height-20)
    :onButtonPressed(function(event) event.target:setScale(0.98) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:ruleTxt()
        end)

    local backBt = createCloseBt()
        :addTo(box,2)
        :pos(box:getContentSize().width, box:getContentSize().height-20)
        :onButtonClicked(function(event)
            self:removeSelf()
            end)

    display.newSprite("skillPreset/skillImg3.png")
    :addTo(box)
    :pos(tmpsize.width/2-320,tmpsize.height/2+100)

    self.headBox = display.newSprite("skillPreset/skillImg1.png")
    :addTo(box)
    :pos(tmpsize.width/2-390,tmpsize.height/2+100)

    --技能顺序框
    self.sklSortBox = {}
    self.sklSortIdx = 1
    for i=1,4 do
        self.sklSortBox[i] = display.newScale9Sprite("common2/com2_Img_5.png",nil,nil,cc.size(102,102),cc.rect(9,9,30,30))
        :addTo(box)
        :pos((tmpsize.width/2-200)+(i-1)*130,tmpsize.height/2)

        display.newSprite("skillPreset/skillImg"..(i+4)..".png")
        :addTo(self.sklSortBox[i])
        :pos(self.sklSortBox[i]:getContentSize().width/2, self.sklSortBox[i]:getContentSize().height/2)
    end

    local emptyBt  = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_7_up.png",
        pressed = "common2/com2_Btn_7_down.png"
        })
    :addTo(box)
        :pos(tmpsize.width- 120,tmpsize.height/2)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "清空循环", size = 26, color = cc.c3b(245, 255, 49)}))
    :onButtonClicked(function(event)
            self:emptySklSort()
        end)

    local bar = display.newSprite("skillPreset/skillImg4.png")
    :addTo(box)
    :pos(tmpsize.width/2-80,tmpsize.height/2-170)

    self.myTeamerList = cc.ui.UIListView.new{
                    -- bgColor = cc.c4b(255,0,0,100),
                    viewRect = cc.rect(13, 10, 795, 132),
                    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
                }
                :addTo(bar)
    


    --勾选按钮
    self.myHook= nil

    local nextOne = cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_8_up.png",
        pressed = "common2/com2_Btn_8_down.png"
        })
    :addTo(box)
    :pos(tmpsize.width-120, tmpsize.height/2-130)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "下一个", size = 30, color = cc.c3b(44, 210, 255)}))
    :onButtonClicked(function(event)
        if self.sklSortIdx~=1 and self.sklSortIdx~=5 then
            showTips("请将四个技能槽填满或者清空后，再选择另外的战车或者人物。")
            return
        end
        self:saveOrder()
        local cnt = #self.sortList.memSkl + (#self.sortList.carSkl)
        local nextIdx = self.curIdx + 1
        if nextIdx>cnt then
            nextIdx = 1
        end
        self.curIdx = nextIdx
        self:createHook(self.contentNode[nextIdx])
        end)

    local saveBt = cc.ui.UIPushButton.new({normal = "common2/com2_Btn_6_up.png",pressed = "common2/com2_Btn_6_down.png"})
    :addTo(box)
    :pos(tmpsize.width-120, tmpsize.height/2-210)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "保 存", size = 28,color = cc.c3b(94, 229, 101)}))
    :onButtonClicked(function()
        if self.sklSortIdx~=1 and self.sklSortIdx~=5 then
            showTips("请将四个技能槽填满或者清空后，再进行保存。")
            return
        end
        self:saveOrder()
        startLoading()
        local sendData={}
        local tmpData = {}
        for k,v in pairs(sklSortData) do
            table.insert(tmpData, v)
        end
        sendData["orderList"] = tmpData

        m_socket:SendRequest(json.encode(sendData), CMD_SAVESKLPRESET, self, self.onSaveSklPreset)
    end)


    self:carList()
end

function skillPreset:carList()
    self.contentNode = {}
    self.curIdx = nil

    local _listView = self.myTeamerList
    _listView:removeAllItems()

    local sortList = self.sortList
    if nil==sortList then
        return
    end
    self.mainBattleItem = {}
    -- printTable(sortList.carSkl)
    local _carList = sortList.carSkl
    for i=1,#_carList do
        local value = _carList[i]
        local nTemplateID = value.tmpId
        local nResID = tonumber(string.sub(nTemplateID,1,4))
        local headPath = string.format("Head/head_%d.png", nResID)

        local item = _listView:newItem()

        local content = display.newSprite("#Embattle_Img38.png")
        self.contentNode[i] = content

        local _size = content:getContentSize()
        self.mainBattleItem[i] = {}

        self.mainBattleItem[i].btnSel = cc.ui.UIPushButton.new()
                :size(105, 105)
                :align(display.CENTER, _size.width/2,_size.height/2)
                :addTo(content,0,i)
                :onButtonClicked(function(event)
                        if self.sklSortIdx~=1 and self.sklSortIdx~=5 then
                            showTips("请将四个技能槽填满或者清空后，再选择另外的战车或者人物。")
                            return
                        end
                        self:saveOrder()
                        self.curIdx = i
                        self:createHook(content)
                    end)

        self.mainBattleItem[i].btnSel:setTouchSwallowEnabled(false)

        self.mainBattleItem[i].imgHead = display.newSprite(headPath)
                :align(display.CENTER_BOTTOM, _size.width/2,7)
                :addTo(content)

        --同步服务端的数据
        local tmp = {}
        tmp.id = value.id
        tmp.order = value.sklOrder
        tmp.sklType = 2
        sklSortData[value.id] = tmp

        item:addContent(content)
        item:setItemSize(150,130)
        _listView:addItem(item)
    end

    local addCnt = #_carList
    local _memList = sortList.memSkl
    for i=1,#_memList do
        local value = _memList[i]
        local nTemplateID = value.tmpId

        local nResID = tonumber(string.sub(nTemplateID,1,4))
        local headPath = string.format("Head/headman_%d.png", nResID)

        local item = _listView:newItem()

        local content = display.newSprite("#Embattle_Img38.png")
        self.contentNode[i+addCnt] = content

        local _size = content:getContentSize()
        self.mainBattleItem[i+addCnt] = {}

        self.mainBattleItem[i+addCnt].btnSel = cc.ui.UIPushButton.new()
                :size(105, 105)
                :align(display.CENTER, _size.width/2,_size.height/2)
                :addTo(content,0,i+addCnt)
                :onButtonClicked(function(event)
                        if self.sklSortIdx~=1 and self.sklSortIdx~=5 then
                            showTips("请将四个技能槽填满或者清空后，再选择另外的战车或者人物。")
                            return
                        end
                        self:saveOrder()
                        self.curIdx = i+addCnt
                        self:createHook(content)
                    end)

        self.mainBattleItem[i+addCnt].btnSel:setTouchSwallowEnabled(false)

        self.mainBattleItem[i+addCnt].imgHead = display.newSprite(headPath)
                :align(display.CENTER_BOTTOM, _size.width/2,7)
                :addTo(content)

        --同步服务端的数据
        local tmp = {}
        tmp.id = value.id
        tmp.order = value.sklOrder
        tmp.sklType = 1
        sklSortData[value.id] = tmp

        item:addContent(content)
        item:setItemSize(150,130)
        _listView:addItem(item)
    end

    self.curIdx = 1
    self:createHook(self.contentNode[1])

    _listView:reload()

    print("----------技能顺序--------")
    printTable(sklSortData)
    print("----------技能顺序 end--------")
end

function skillPreset:createHook(parentNode)
    if self.myHook then
        self.myHook:removeSelf()
        self.myHook=nil
    end
    self.myHook = display.newSprite("common2/com_hook.png")
    :addTo(parentNode,10)
    :pos(50,50)

    local value  = nil
    if self.curIdx>#self.sortList.carSkl then
        value = self.sortList.memSkl[self.curIdx-(#self.sortList.carSkl)]
    else
        value = self.sortList.carSkl[self.curIdx]
    end
    local nID = EmbattleMgr:getMatrixIdFromMemberInfo(value)
    local nTemplateID = value.tmpId

    local nResID = tonumber(string.sub(nTemplateID,1,4))
    local headPath
    if self.curIdx>#self.sortList.carSkl then
        headPath = string.format("Head/headman_%d.png", nResID)
    else
        headPath = string.format("Head/head_%d.png", nResID)
    end
    if self.mHead then
        self.mHead:removeSelf()
        self.mHead = nil
    end
    self.mHead = display.newSprite(headPath)
        :addTo(self.headBox)
        :pos(self.headBox:getContentSize().width/2, self.headBox:getContentSize().height/2)

    
    --清空循环
    self:emptySklSort()

    --技能图标
    if self.sklBt then
        for i=1,#self.sklBt do
            if self.sklBt[i]~=nil then
                self.sklBt[i]:removeSelf()
                self.sklBt[i] = nil
            end
        end
    end
    
    self.sklBt = {}
    
    local tabSkill = value.skl
    -- printTable(tabSkill)
    --人物在第一位加上一个武器技能
    if #tabSkill==3 and self.curIdx>#self.sortList.carSkl then
        local tmp = {}
        tmp.lvl = 1
        tmp.id = itemData[memberData[nTemplateID].weaponTmpId].sklId
        table.insert(tabSkill, 1, tmp)
    end

    if tabSkill==nil then
        return
    end
    -- curSortList = ""
    self:performWithDelay(function()
    for k,v in ipairs(tabSkill) do
        if self.curIdx<=#self.sortList.carSkl and k>2 then  --车的技能值显示前面两个主动技能
            return
        end
        local skillId = tabSkill[k].id
        local loc_Skl = skillData[skillId]

        self.sklBt[k] = cc.ui.UIPushButton.new("itemBox/box_1.png")
        :addTo(self.box)
        :pos((self.tmpsize.width/2-200)+(k-1)*130,self.tmpsize.height/2+200)
        :onButtonPressed(function(event) event.target:setScale(0.98) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            if self.curIdx<=#self.sortList.carSkl and tabSkill[k].sts<=0 then --战车技能未激活
                showTips("该技能未激活")
                return
            end
            if self.curIdx>#self.sortList.carSkl and tabSkill[k].lvl<1 then --人物技能未激活
                showTips("该技能未激活")
                return
            end
            if self.sklSortIdx>4 then
                showTips("技能已经填满")
                return
            end

            local node = self.sklSortBox[self.sklSortIdx]
            self.sortSkl[self.sklSortIdx] = display.newSprite("SkillIcon/skillicon" .. loc_Skl.resId2 .. ".png")
            :addTo(node)
            :pos(node:getContentSize().width/2,node:getContentSize().height/2)


            if self.sklSortIdx~=4 then
                curSortList = curSortList..k.."|"
            else
                curSortList = curSortList..k
            end

            self.sklSortIdx = self.sklSortIdx + 1
         end)


        --技能图标
        local icon = display.newGraySprite("SkillIcon/skillicon" .. loc_Skl.resId2 .. ".png")
            :addTo(self.sklBt[k])
            -- :pos((self.tmpsize.width/2-200)+(k-1)*120,self.tmpsize.height/2+200)
        if (self.curIdx<=#self.sortList.carSkl and tabSkill[k].sts<=0) or 
            (self.curIdx>#self.sortList.carSkl and tabSkill[k].lvl<1) then --战车技能未激活
            -- local filters = filter.newFilter("GRAY")
            -- icon:setFilter(filters)
        else
            icon:clearFilter()
        end
    end
    end,0.01)

    --初始化技能顺序
    print("当前技能顺序")
    print(sklSortData[value.id].order)
    curSortList = sklSortData[value.id].order
    local orderList = sklSortData[value.id].order
    local orderArr = string.split(orderList, "|")
    if #orderArr~=4 then
        return
    end
    for i=1,#orderArr do
        local skillId = tabSkill[tonumber(orderArr[i])].id
        local loc_Skl = skillData[skillId]
        local node = self.sklSortBox[i]
        self.sortSkl[i] = display.newSprite("SkillIcon/skillicon" .. loc_Skl.resId2 .. ".png")
        :addTo(node)
        :pos(node:getContentSize().width/2,node:getContentSize().height/2)
    end
    self.sklSortIdx = 5 --已经设置了技能顺序


end

function skillPreset:emptySklSort()
    print("清空循环")
    if self.sortSkl then
        for i=1,4 do
            if self.sortSkl[i] then
                self.sortSkl[i]:removeSelf()
            end
        end
    end
    self.sortSkl = {}
    self.sklSortIdx = 1
    curSortList = ""
end
function skillPreset:saveOrder()
    print("--------------save order------------")
    local value  = nil
    if self.curIdx>#self.sortList.carSkl then
        value = self.sortList.memSkl[self.curIdx-(#self.sortList.carSkl)]
    else
        value = self.sortList.carSkl[self.curIdx]
    end
    sklSortData[value.id].order = curSortList

    
    printTable(sklSortData[value.id])
end
function skillPreset:onSaveSklPreset(cmd)
    if cmd.result==1 then
        showTips("保存成功！")

        --修改布阵本地数据
        for k,v in ipairs(self.sortList.carSkl) do
            self.sortList.carSkl[k].sklOrder = sklSortData[v.id].order
        end
        for k,v in ipairs(self.sortList.memSkl) do
            self.sortList.memSkl[k].sklOrder = sklSortData[v.id].order
        end
    else
        showTips(cmd.msg)
    end
end

--强化说明
function skillPreset:ruleTxt()
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

    local str = [[1、仅在竞技场中才能使用技能预设
2、攻击阵型与防守阵型共用一套预热方案
3、每个单位最多预设4个技能，战斗中以此4个技能顺序循环施放
4、不进行预设则按照默认循环施放技能
5、单位未激活的技能不能加入预设循环
6、预设的循环中，4个技能不能留空
        ]]
        _label:setString(str)

        layer:addHinder(spr)
    layer:setOnTouchEndedEvent(function()
        layer:removeFromParent()
    end)
end

return skillPreset