-- @Author: anchen
-- @Date:   2015-10-23 16:36:21
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-10 15:30:26
local lensMsglayer=class("lensMsglayer", function()
    return display.newNode()
    end)

local Attribute_pos = {
    {x=50,y=430},
    {x=50,y=340},
    {x=50,y=300},
    {x=50,y=260},

    {x=50,y=280},
    {x=50,y=220},
}
function lensMsglayer:ctor(value, cur_localValue, callBack)
    self.value = value
    self.callBack = callBack
    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --框
    local msgBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
        display.cy-30,
        cc.size(500, 606),cc.rect(119, 127, 1, 1))
    :addTo(masklayer)
    masklayer:addHinder(msgBox)
    local boxsize = msgBox:getContentSize()
    

    self.closeBt = createCloseBt()
    :addTo(msgBox,1,100)
    :pos(boxsize.width+15,boxsize.height-32)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

    local localItem = cur_localValue

    --底框1
    display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,120))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2+80)

     --图标
    local icon = createItemIcon(value.tmpId)
    :addTo(msgBox,0,1000)
    :pos(110,msgBox:getContentSize().height - 90)
    --类型
    local bar = display.newSprite("equipment/equipmentImg3.png")
    :addTo(msgBox)
    :pos(222,msgBox:getContentSize().height - 55)

    local eqtType = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    :addTo(bar)
    :pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
    eqtType:setAnchorPoint(0.5,0.5)
    eqtType:setString(itemTypeToString(value["tmpId"]))
    eqtType:setColor(cc.c3b(241, 171, 0))

    --名字
    self.name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(270,msgBox:getContentSize().height - 55)
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
    local starNum = getItemStar(value.tmpId)
    for i=1,starNum do
        local star = display.newSprite("common/common_Star.png")
        :addTo(msgBox)
        :pos(34*i+170,msgBox:getContentSize().height - 95)
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
    self.level:setString(value.cnt)

    
    --技能描述
    self.des=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
    :align(display.TOP_LEFT, Attribute_pos[1].x ,Attribute_pos[1].y)
    :addTo(msgBox)
    self.des:setWidth(400)
    self.des:setAnchorPoint(0,1)
    self.des:setColor(cc.c3b(132, 149, 165))
    self.des:setLineHeight(25)
    self.des:setString(localItem.des)

    --属性
    if localItem.type==801 then
        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "附带特效：", size = 22, color= cc.c3b(132, 149, 165)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x, Attribute_pos[5].y)
        :addTo(msgBox)
        
        cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color= cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x+lab:getContentSize().width, Attribute_pos[5].y)
        :addTo(msgBox)
        :setString(buffData[localItem.buffId].name)

        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color= cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[6].x, Attribute_pos[6].y)
        :addTo(msgBox)
        lab:setWidth(340)
        lab:setLineHeight(25)
        lab:setString(buffData[localItem.buffId].des)
    elseif localItem.type==802 then
        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "目标数量：", size = 22, color= cc.c3b(132, 149, 165)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x, Attribute_pos[5].y)
        :addTo(msgBox)
        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22, color= cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x+lab:getContentSize().width, Attribute_pos[5].y)
        :addTo(msgBox)
        :setString(localItem.num)
        

        local lab2 = cc.ui.UILabel.new({UILabelType = 2, text = "初始伤害率：", size = 22, color= cc.c3b(132, 149, 165)})
        :align(display.CENTER_LEFT, Attribute_pos[6].x, Attribute_pos[6].y)
        :addTo(msgBox)
        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22, color= cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[6].x+lab2:getContentSize().width, Attribute_pos[6].y)
        :addTo(msgBox)
        :setString(100*localItem.atkPercent.."%")
    elseif localItem.type==803 then
        local lab = cc.ui.UILabel.new({UILabelType = 2, text = "额外伤害率：", size = 22, color= cc.c3b(132, 149, 165)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x, Attribute_pos[5].y)
        :addTo(msgBox)

        cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22, color= cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[5].x+lab:getContentSize().width, Attribute_pos[5].y)
        :addTo(msgBox)
        :setString(100*localItem.atkPercent.."%")
    end

    --分解
    local fenjieBt = createGreenBt2("分解", 1.2)
        :addTo(msgBox)
        :pos(msgBox:getContentSize().width/2,70)
        :onButtonClicked(function(event)
            showMessageBox("确定分解"..localItem.name.."？", function()
                local itemList = {}
                local data = {}
                data.id = value.id
                data.cnt = 1
                table.insert(itemList,data)
                -- table.insert(itemList,value.id)
                local sendData={}
                sendData["itemList"] = itemList
                m_socket:SendRequest(json.encode(sendData), CMD_DECOMPOSE, self, self.onDecomposeResult)
                end)
            end)

end
function lensMsglayer:onDecomposeResult(result) --分解
    endLoading()
    if result["result"]==1 then
        self.callBack()
        mainscenetopbar:setGlod()
        createDecomposeBox(self.value,result.data.gold)
        
        local dc_item = itemData[self.value.tmpId+0]
        if dc_item then
            DCItem.consume(tostring(dc_item.id), dc_item.name, 1, "装备分解")
        end

        self:removeSelf()
    else
        showTips(result.msg)
    end
end

return lensMsglayer