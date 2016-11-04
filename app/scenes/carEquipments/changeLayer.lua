local changeLayer = class("changeLayer", function()
	return display.newNode()
	end)
local masklayer
local msgBox
local listViewBox
local defalutValue
local selectBox

local selEptLevel = 0 --当前已装备的装备等级
local Attribute_pos = {
    {x=50,y=248},
    {x=50,y=211},
    {x=50,y=174},
    {x=50,y=137},
    {x=50,y=285},

    {x=50,y=418},
    {x=50,y=378},
    {x=50,y=338},
}
local itemTable = {}
function changeLayer:ctor(cur_value,curEqupmentIdx,callBack, msgNode) --curEqupmentIdx 装备类型
    if cur_value~=nil then
        selEptLevel = cur_value.advLvl
    end
    print("selEptLevel:"..selEptLevel)
	self.curEqupmentIdx = curEqupmentIdx
	self.cur_value = cur_value
    self.callBack = callBack
    self.msgNode = msgNode
    print(msgNode)


    if self.curEqupmentIdx~=nil then
        itemTable = self:getItemByNum(self.curEqupmentIdx)
    else
        local eptIdx = getItemType(self.cur_value.tmpId) 
        itemTable = self:getItemByNum(eptIdx)
    end

    if #itemTable==0 then
        showTips("该位置没有更多的装备了。")
        return
    end

	masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
 	masklayer:setOnTouchEndedEvent(func)
    --框
	msgBox = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(500, 597),cc.rect(119, 127, 1, 1))
	:addTo(masklayer)
    :pos(display.cx-250, display.cy-30)
	masklayer:addHinder(msgBox)


	--右边装备列表框
	listViewBox = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(500, 597),cc.rect(119, 127, 1, 1))
	:addTo(masklayer)
    :pos(display.cx+250, display.cy-30)

    local closeBt = createCloseBt()
    :addTo(listViewBox)
    :pos(listViewBox:getContentSize().width+15,listViewBox:getContentSize().height-32)
    :onButtonClicked(function(event)
        if self.msgNode then
            self.msgNode:setVisible(true)
        end
        
        self:removeSelf()
        
        end)

	--listView
	self.lv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(30, 20, 440, 550),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(listViewBox)
    self:itemListView()

    


	self:reloadData(defalutValue)
end
function changeLayer:reloadData(value) --mtype 1为强化，mtype 2为进阶
    local localItem = itemData[value.tmpId]
    msgBox:removeAllChildren()

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
    --评分
    cc.ui.UILabel.new({UILabelType = 2, text = "（品质:"..localItem.score.."）", size = 25})
    :addTo(msgBox)
    :pos(34*starNum+180,msgBox:getContentSize().height - 98)

    --等级
    self.level = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 25})
    :addTo(msgBox)
    :pos(190,msgBox:getContentSize().height - 135)
    self.level:setAnchorPoint(0,0.5)
    self.level:setColor(cc.c3b(248, 204, 45))

    self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 25})
    :addTo(msgBox)
    :pos(self.level:getPositionX()+self.level:getContentSize().width,msgBox:getContentSize().height - 135-2)
    self.level:setAnchorPoint(0,0.5)
    self.level:setString(value["advLvl"])
    

    --底框1
    display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,120))
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2+80)
    local fontSize = 25
    --技能描述
    local mcolor = cc.c3b(132, 149, 165)
    if localItem.sklId==0 then
        local des=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
        :align(display.TOP_LEFT, Attribute_pos[1].x ,Attribute_pos[1].y)
        :addTo(msgBox)
        des:setWidth(400)
        des:setString(localItem.des)
        des:setAnchorPoint(0,1)
        des:setColor(mcolor)
    else
        local skl=cc.ui.UILabel.new({UILabelType = 2, text = "武器技能：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[1].x,Attribute_pos[1].y)
        :addTo(msgBox)
        skl:setColor(mcolor)
        local sklName=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[1].x+skl:getContentSize().width+10, Attribute_pos[1].y)
        :addTo(msgBox)
        sklName:setString(skillData[localItem.sklId].sklName)
        sklName:setColor(cc.c3b(85, 177, 202))

        local hurt=cc.ui.UILabel.new({UILabelType = 2, text = "伤害系数：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[2].x,Attribute_pos[2].y)
        :addTo(msgBox)
        hurt:setColor(mcolor)
        local hurtNum=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[2].x+hurt:getContentSize().width+10, Attribute_pos[2].y)
        :addTo(msgBox)
        hurtNum:setString((skillData[localItem.sklId].addPercent*100).."%")
        hurtNum:setColor(cc.c3b(85, 177, 202))

        local CD=cc.ui.UILabel.new({UILabelType = 2, text = "冷却时间：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[3].x,Attribute_pos[3].y)
        :addTo(msgBox)
        CD:setColor(mcolor)
        local CDTime=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[3].x+CD:getContentSize().width+10, Attribute_pos[3].y)
        :addTo(msgBox)
        CDTime:setString(skillData[localItem.sklId].sklCD.."s")
        CDTime:setColor(cc.c3b(85, 177, 202))

        local effect=cc.ui.UILabel.new({UILabelType = 2, text = "技能效果：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[4].x,Attribute_pos[4].y)
        :addTo(msgBox)
        effect:setColor(mcolor)
        local sklDes=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
        :align(display.TOP_LEFT, Attribute_pos[4].x+effect:getContentSize().width+10, Attribute_pos[4].y+13)
        :addTo(msgBox)
        sklDes:setString(skillData[localItem.sklId].sklDes)
        sklDes:setDimensions(320,0)
        sklDes:setColor(cc.c3b(85, 177, 202))

        
    end

    --装备差异
    local diff = cc.ui.UILabel.new({UILabelType = 2, text = "同等级装备后差异", size = 22,color = cc.c3b(81, 91, 102)})
    :addTo(msgBox)
    :pos(280,  Attribute_pos[6].y)

    --技能属性值
    local item = localItem
    local value2 = self.cur_value
    
    local mcolor1 = cc.c3b(248, 204, 45)
    local mcolor2 = cc.c3b(117, 242, 31)
    local mcolor3 = cc.c3b(255, 241, 0)
    local pos=5
    if item.hp>0 then
        pos = pos + 1
        local HP=cc.ui.UILabel.new({UILabelType = 2, text = "血量：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        HP:setColor(mcolor1)
        local HpNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+HP:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        
        if self.cur_value==nil then
        	HpNum:setString(string.format("%.2f",item.hp) )
        	HpNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, HpNum:getPositionX()+HpNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.hp + (selEptLevel-1)*item.hpGF - (item2.hp + (selEptLevel-1)*item2.hpGF)
        	if dNum>=0 then
        		HpNum:setString(string.format("%.2f",dNum))
        		HpNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, HpNum:getPositionX()+HpNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		HpNum:setString(string.format("%.2f",-dNum))
        		HpNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, HpNum:getPositionX()+HpNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end

    end
    if item.attack>0 then
        pos = pos + 1
        local Attack=cc.ui.UILabel.new({UILabelType = 2, text = "攻击：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Attack:setColor(mcolor1)
        local AttackNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Attack:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        if self.cur_value==nil then
        	AttackNum:setString(string.format("%.2f",item.attack))
        	AttackNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, AttackNum:getPositionX()+AttackNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.attack + (selEptLevel-1)*item.atkGF - (item2.attack + (selEptLevel-1)*item2.atkGF)
        	if dNum>=0 then
        		AttackNum:setString(string.format("%.2f",dNum))
        		AttackNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, AttackNum:getPositionX()+AttackNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		AttackNum:setString(string.format("%.2f",-dNum))
        		AttackNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, AttackNum:getPositionX()+AttackNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end
    end
    if item.defense>0 then
        pos = pos + 1
        local Defense=cc.ui.UILabel.new({UILabelType = 2, text = "防御：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Defense:setColor(mcolor1)
        local DefenseNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Defense:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        if self.cur_value==nil then
        	DefenseNum:setString(string.format("%.2f",item.defense))
        	DefenseNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, DefenseNum:getPositionX()+DefenseNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.defense + (selEptLevel-1)*item.defGF - (item2.defense + (selEptLevel-1)*item2.defGF)
        	if dNum>=0 then
        		DefenseNum:setString(string.format("%.2f",dNum))
        		DefenseNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, DefenseNum:getPositionX()+DefenseNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		DefenseNum:setString(string.format("%.2f",-dNum))
        		DefenseNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, DefenseNum:getPositionX()+DefenseNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end
    end
    if item.cri>0 then
        pos = pos + 1
        local Cri=cc.ui.UILabel.new({UILabelType = 2, text = "暴击：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Cri:setColor(mcolor1)
        local CriNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Cri:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        if self.cur_value==nil then
        	CriNum:setString(string.format("%.2f",item.cri))
        	CriNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, CriNum:getPositionX()+CriNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.cri + (selEptLevel-1)*item.criGF - (item2.cri + (selEptLevel-1)*item2.criGF)
        	if dNum>=0 then
        		CriNum:setString(string.format("%.2f",dNum))
        		CriNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, CriNum:getPositionX()+CriNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		CriNum:setString(string.format("%.2f",-dNum))
        		CriNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, CriNum:getPositionX()+CriNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end
    end
    if item.hit>0 then
        pos = pos + 1
        local Hit=cc.ui.UILabel.new({UILabelType = 2, text = "命中：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Hit:setColor(mcolor1)
        local HitNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Hit:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        if self.cur_value==nil then
        	HitNum:setString(string.format("%.2f",item.hit))
        	HitNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, HitNum:getPositionX()+HitNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.hit + (selEptLevel-1)*item.hitGF - (item2.hit + (selEptLevel-1)*item2.hitGF)
        	if dNum>=0 then
        		HitNum:setString(string.format("%.2f",dNum))
        		HitNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, HitNum:getPositionX()+HitNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		HitNum:setString(string.format("%.2f",-dNum))
        		HitNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, HitNum:getPositionX()+HitNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end
    end
    if item.miss>0 then
        pos = pos + 1
        local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "闪避：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Miss:setColor(mcolor1)
        local MissNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        if self.cur_value==nil then
        	MissNum:setString(string.format("%.2f",item.miss))
        	MissNum:setColor(mcolor2)
        	local jiantou = display.newSprite("common/Improve_Img17.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, MissNum:getPositionX()+MissNum:getContentSize().width+5,Attribute_pos[pos].y)
        else
        	local item2 = itemData[self.cur_value.tmpId]
        	local dNum = item.miss + (selEptLevel-1)*item.missGF - (item2.miss + (selEptLevel-1)*item2.missGF)
        	if dNum>=0 then
        		MissNum:setString(string.format("%.2f",dNum))
        		MissNum:setColor(mcolor2)
        		local jiantou = display.newSprite("common/Improve_Img17.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, MissNum:getPositionX()+MissNum:getContentSize().width+5,Attribute_pos[pos].y)
        	else
        		MissNum:setString(string.format("%.2f",-dNum))
        		MissNum:setColor(mcolor3)
        		local jiantou = display.newSprite("common/Improve_Img18.png")
	            :addTo(msgBox)
	            :align(display.CENTER_LEFT, MissNum:getPositionX()+MissNum:getContentSize().width+5,Attribute_pos[pos].y)
        	end
        end
    end
    --装载等级限制
    if item.minLvl>0 then
        pos = 5
        local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "装载等级：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Miss:setColor(cc.c3b(132, 149, 165))
        local MissNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width+10,Attribute_pos[pos].y)
        :addTo(msgBox)
        MissNum:setString(item.minLvl)
        MissNum:setColor(cc.c3b(85, 171, 202))
        -- if self.cur_value==nil then
        --     MissNum:setString(item.minLvl)
        --     MissNum:setColor(cc.c3b(85, 171, 202))
        -- else
        --     local dNum = item.minLvl
        --     MissNum:setString(dNum)
        --     MissNum:setColor(cc.c3b(0, 255, 0))
        -- end

        if item.minLvl>srv_userInfo.level then
            Miss:setColor(cc.c3b(230, 0, 18))
            MissNum:setColor(cc.c3b(230, 0, 18))
        end
    end

    -- self:performWithDelay(function ()
        --更换
        local changeBt = createGreenBt2("更换",1.2)
        :addTo(msgBox)
        :pos(msgBox:getContentSize().width/2,50)
        :onButtonClicked(function(event)
            if srv_userInfo.level<item.minLvl then
                showTips("等级不足，不能装载")
                return
            end
            GuideManager:hideGuideEff()
			local sendData={}
			sendData["characterId"] = srv_userInfo["characterId"]
	        sendData["itemId"] = value["id"]
	        sendData["carId"] = curCarData["id"]
            local g_step = nil
            g_step = g_step or GuideManager:tryToSendFinishStep(110) --装备c装置
            sendData.guideStep = g_step
	        m_socket:SendRequest(json.encode(sendData), CMD_CHANGE, self, self.onChangeResult)
	        startLoading()
            end)
        self.changeBt = changeBt
    -- end,0.01)

    
end
function changeLayer:getItemByNum(mtype)
	local itemTable = {}
    local itId
    if self.cur_value==nil then
        itId = 0
    else
        itId = self.cur_value.id
    end
	for i,value in pairs(srv_carEquipment["item"]) do
		if itemData[value.tmpId].type==mtype and itId~=value.id then
             table.insert(itemTable,value)
		end
	end

	--物品排序
	function sortfunc(a,b)
        if itemData[a.tmpId].minLvl<=srv_userInfo.level and itemData[b.tmpId].minLvl>srv_userInfo.level then
            return true
        elseif itemData[a.tmpId].minLvl>srv_userInfo.level and itemData[b.tmpId].minLvl<=srv_userInfo.level then
            return false
		elseif getItemStar(a.tmpId)==getItemStar(b.tmpId) then
			if  a.tmpId== b.tmpId then
				return a.advLvl>b.advLvl
			else
				return (a.tmpId)>(b.tmpId)
			end
		else
			return getItemStar(a.tmpId)>getItemStar(b.tmpId)
		end
	end
	table.sort(itemTable,sortfunc)


	return itemTable
end
function changeLayer:itemListView()
	self.lv:removeAllItems()

   	for i=1,math.ceil(#itemTable) do
   	-- print("aaaaa")

        local item = self.lv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(440, 120)
        local itemW,itemH = item:getItemSize()
        -- for j=1,2 do
            local value = itemTable[i]

            if value==nil then
                -- local itemBt = cc.ui.UIPushButton.new("SingleImg/BackPack/itemNullBox.png")
                -- :addTo(content)
                -- :pos(225*(j-1)-122,0)
                -- itemBt:setScale(0.8)
                -- itemBt:setTouchSwallowEnabled(false)
                -- itemBt:setScale(1920/1280)
                if i==1 then
	            	defalutValue = nil
	            end
            else
            	if i==1 then
	            	defalutValue = value
	            	selectBox = display.newScale9Sprite("equipment/equipmentImg18.png",nil,nil,cc.size(440,120))
                	:addTo(content,1,100)
                	-- :pos(-142,0)
	            end
	            
                local localItem={}
                localItem=itemData[value["tmpId"]]


                local itemBt = cc.ui.UIPushButton.new({normal = "equipment/equipmentImg5.png"},{scale9=true})
                :addTo(content)
                itemBt:setButtonSize(440,120)
                itemBt:setTouchSwallowEnabled(false)
                itemBt:onButtonClicked(function(event)
                	selectBox:removeSelf()
                	selectBox = display.newScale9Sprite("equipment/equipmentImg18.png",nil,nil,cc.size(440,120))
                	:addTo(content,1,100)
                	-- :pos(270*(j-1)-142,0)
                	self:reloadData(value)

                    end)
                local iconImg = GlobalGetItemIcon(value.tmpId)
                :addTo(itemBt)
                :pos(-158,1)
                iconImg:setScale(0.79)
                -- iconImg:setScale(1280/1920)
                
                --名字
                local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
                :addTo(itemBt)
                :pos(-105,32)
                name:setString(localItem.name)
                local star = getItemStar(localItem.id)
                if star==2 then
                    name:setColor(cc.c3b(193, 195, 180))
                elseif star==3 then
                    name:setColor(cc.c3b(107, 206, 82))
                elseif star==4 then
                    name:setColor(cc.c3b(85, 171, 249))
                elseif star==5 then
                    name:setColor(cc.c3b(204, 89, 252))
                end

                --等级
                local label = cc.ui.UILabel.new({UILabelType = 2, text = "等级：", size = 22,color = cc.c3b(248, 204, 45)})
                :addTo(itemBt)
                :pos(-105,0)
                local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = value.advLvl, size = 22})
                :addTo(itemBt)
                :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())

                if value["wareTmpId"]~=0 then
                    --装备于图标
                    display.newSprite("SingleImg/BackPack/eptImg.png")
                    :addTo(iconImg)
                    :align(display.RIGHT_BOTTOM, iconImg:getContentSize().width-12, 12)

                    --装备于
                    local label = cc.ui.UILabel.new({UILabelType = 2, text = "装备于：", size = 20})
                    :addTo(itemBt)
                    :pos(-105, -30)
                    label:setColor(cc.c3b(248, 204, 45))
                    local eptAbove = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
                    :addTo(itemBt)
                    :pos(label:getPositionX()+label:getContentSize().width,label:getPositionY())
                    eptAbove:setColor(cc.c3b(98, 171, 213))
                    eptAbove:setString(carData[value["wareTmpId"]]["name"])
                    setLabelStroke(eptAbove,20,nil,nil,nil,nil,nil,nil, true)
                end

                local starBar = display.newScale9Sprite("equipment/equipmentImg6.png",nil,nil,cc.size(170,50))
                :addTo(itemBt)
                :pos(130,25)
                local starNum = getItemStar(value.tmpId)
                for i=1,starNum do
                    local star = display.newSprite("common/common_Star.png")
                    :addTo(starBar)
                    :pos((i*30), starBar:getContentSize().height/2)
                    star:setScale(0.9)
                end
            end
            
        -- end

        
        self.lv:addItem(item)
    end

	self.lv:reload()
end
function changeLayer:onChangeResult(result)
	endLoading()
	if result["result"]==1 then
        showTips("更换装备成功！")
        
        
        GuideManager:_addGuide_2(11002, cc.Director:getInstance():getRunningScene(),handler(g_ImproveLayer.Instance,g_ImproveLayer.Instance.caculateGuidePos))
		GuideManager:_addGuide_2(11004, cc.Director:getInstance():getRunningScene(),handler(g_ImproveLayer.Instance,g_ImproveLayer.Instance.caculateGuidePos))
        self.callBack()

        if self.msgNode then
            self.msgNode:removeSelf()
        end
		self:removeSelf()
	else
		showTips(result.msg)
	end
end

function changeLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10903 ==_guideId then
        if 10903 ==_guideId then
            g_node = self.changeBt
        end
        
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return changeLayer