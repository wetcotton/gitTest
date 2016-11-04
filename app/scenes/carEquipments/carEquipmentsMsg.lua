local strengNode = require("app.scenes.carEquipments.strengthen")
local advancedNode = require("app.scenes.carEquipments.advanced")
local changeNode = require("app.scenes.carEquipments.changeLayer")

local carEquipmentsMsg=class("InitLayer", function()
    return display.newNode()
    end)

local masklayer
local msgBox
-- local closeBt
local BtType = 0
local fontSize = 25
local midBoxSize
local fengeLinePos

local Attribute_pos = {
	{x=50,y=380},
	{x=50,y=340},
	{x=50,y=300},
	{x=50,y=260},

	{x=50,y=200},
	{x=50,y=160},
	{x=50,y=120},
    {x=230,y=200},
    {x=230,y=160},
    {x=230,y=120},
}
local equipmentIdx = {
    101,102,104,105
}

--创建装备信息框
--mtype 1为战车装备弹出，nil为改造中心弹出
--isSuit 是否是套装物品
function carEquipmentsMsg:ctor(value,cur_localValue,mtype,callBack,isSuit, curEquipments, parentNode)
    self.value = value
    self.callBack = callBack
    self.mtype = mtype
    self.isSuit = isSuit
    self.parentNode = parentNode
    self.eptIdx = nil
    if curEquipments then
        for i,key in pairs(curEquipments) do
            if key==value.id then
                if i==101 then
                    self.eptIdx = 1
                elseif i==102 then
                    self.eptIdx = 2
                elseif i==104 then
                    self.eptIdx = 3
                elseif i==105 then
                    self.eptIdx = 4
                end
                break
            end
        end
    end
    

    BtType = 0
	masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self)
    local function  func()
        self:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --框
	msgBox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
		display.cy-30,
		cc.size(500, 606),cc.rect(119, 127, 1, 1))
	:addTo(masklayer)
	masklayer:addHinder(msgBox)
    

    self.closeBt = createCloseBt()
    :addTo(msgBox,1,100)
    :pos(msgBox:getContentSize().width+15,msgBox:getContentSize().height-32)
    :onButtonClicked(function(event)
        self:removeSelf()
        -- if BackPack_Equipment.Instance then
        --     BackPack_Equipment.Instance:updateListView()
        -- end
        -- self:performWithDelay(function ()
        --                -- self:updateBpListView()
        --     end, 0.1)
        end)

    local localItem = cur_localValue
    self.localItem = localItem
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

    --底框2
    -- display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,150))
    -- :addTo(msgBox)
    -- :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2)

    

    --套装
    self.suitNode = display.newNode()
    :addTo(msgBox)

    --套装属性
    local suitBox = display.newScale9Sprite("equipment/equipmentImg9.png",nil,nil,cc.size(447,60))
    :addTo(self.suitNode)
    :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height/2-20)

    --套装名字
    self.SuitName = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 23, color = cc.c3b(255, 255, 0)})
    :addTo(suitBox)
    :pos(20, 40)

    --套装属性是否激活
    self.isSuitActImg = display.newSprite("SingleImg/BackPack/activated.png")
    :addTo(suitBox)
    :pos(suitBox:getContentSize().width-55, suitBox:getContentSize().height/2+10)


    local tmpColor = cc.c3b(132, 149, 165)
    self.suitHp = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
    :addTo(suitBox)

    self.suitMainAtk = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
    :addTo(suitBox)
    
    self.suitSubAtk = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)
    
    self.suitDef = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)
    
    self.suitCri = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)
    
    self.suitHit = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)
    
    self.suitMiss = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)
    
    self.suitEre = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = tmpColor})
        :addTo(suitBox)


    
    --技能描述
    self.des=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
    :align(display.TOP_LEFT, Attribute_pos[1].x ,Attribute_pos[1].y)
    :addTo(msgBox)
    self.des:setWidth(400)
    self.des:setAnchorPoint(0,1)
    self.des:setColor(cc.c3b(132, 149, 165))
    self.des:setLineHeight(30)

    self.sklNode = display.newNode()
    :addTo(msgBox)
    self.skl=cc.ui.UILabel.new({UILabelType = 2, text = "武器技能：", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[1].x,Attribute_pos[1].y)
    :addTo(self.sklNode)
    self.skl:setColor(cc.c3b(132, 149, 165))
    self.sklName=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[1].x+self.skl:getContentSize().width, Attribute_pos[1].y)
    :addTo(self.sklNode)
    self.sklName:setColor(cc.c3b(85, 177, 201))

    self.hurt=cc.ui.UILabel.new({UILabelType = 2, text = "伤害系数：", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[2].x,Attribute_pos[2].y)
    :addTo(self.sklNode)
    self.hurt:setColor(cc.c3b(132, 149, 165))
    self.hurtNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[2].x+self.hurt:getContentSize().width, Attribute_pos[2].y)
    :addTo(self.sklNode)
    self.hurtNum:setColor(cc.c3b(85, 177, 201))

    self.CD=cc.ui.UILabel.new({UILabelType = 2, text = "冷却时间：", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[3].x,Attribute_pos[3].y)
    :addTo(self.sklNode)
    self.CD:setColor(cc.c3b(132, 149, 165))
    self.CDTime=cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = fontSize})
    :addTo(self.sklNode)
    self.CDTime:setColor(cc.c3b(85, 177, 201))

    self.effect=cc.ui.UILabel.new({UILabelType = 2, text = "技能效果：", size = fontSize})
    :align(display.CENTER_LEFT, Attribute_pos[4].x,Attribute_pos[4].y)
    :addTo(self.sklNode)
    self.effect:setColor(cc.c3b(132, 149, 165))
    self.sklDes=cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize})
    :addTo(self.sklNode)
    self.sklDes:setDimensions(300,0)
    self.sklDes:setColor(cc.c3b(85, 177, 201))

    

    if localItem.sklId==0 then
        self.des:setVisible(true)
        self.sklNode:setVisible(false)
    else
        self.des:setVisible(false)
        self.sklNode:setVisible(true)
    end

    --技能属性值
    local item = localItem
    
    self.hp = {}
    self.attack = {}
    self.defense = {}
    self.cri = {}
    self.hit = {}
    self.miss = {}
    self.erecover = {}
    self.minLvl = {}
    local pos=4
    if item.hp>0 then
        pos = pos + 1
        local HP=cc.ui.UILabel.new({UILabelType = 2, text = "血量：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        HP:setColor(cc.c3b(248, 204, 45))
        local HpNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+HP:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        -- HpNum:setString(item.hp + (value["advLvl"]-1)*item.hpGF)
        
        local jiantou = display.newSprite("common/Improve_Img16.png")
        :addTo(msgBox)
        :align(display.CENTER_LEFT, HpNum:getPositionX()+HpNum:getContentSize().width+5,Attribute_pos[pos].y)
        jiantou:setVisible(false)
        local HpNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
        :addTo(msgBox)
        HpNum2:setColor(cc.c3b(117, 242, 31))
        HpNum2:setVisible(false)

        self.hp.name = HP
        self.hp.Num1 = HpNum
        self.hp.jiantou = jiantou
        self.hp.Num2 = HpNum2

    end
    if item.attack>0 then
        pos = pos + 1
        local Attack=cc.ui.UILabel.new({UILabelType = 2, text = "攻击：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Attack:setColor(cc.c3b(248, 204, 45))
        local AttackNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Attack:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        AttackNum:setString(item.attack + (value["advLvl"]-1)*item.atkGF)
        
        local jiantou = display.newSprite("common/Improve_Img16.png")
        :addTo(msgBox)
        :align(display.CENTER_LEFT, AttackNum:getPositionX()+AttackNum:getContentSize().width+5,Attribute_pos[pos].y)
        jiantou:setVisible(false)
        local AttackNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
        :addTo(msgBox)
        AttackNum2:setColor(cc.c3b(117, 242, 31))
        AttackNum2:setVisible(false)

        self.attack.name = Attack
        self.attack.Num1 = AttackNum
        self.attack.jiantou = jiantou
        self.attack.Num2 = AttackNum2
    end
    if item.defense>0 then
        pos = pos + 1
        local Defense=cc.ui.UILabel.new({UILabelType = 2, text = "防御：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Defense:setColor(cc.c3b(248, 204, 45))
        local DefenseNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Defense:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        DefenseNum:setString(item.defense + (value["advLvl"]-1)*item.defGF)
        
        local jiantou = display.newSprite("common/Improve_Img16.png")
        :addTo(msgBox)
        :align(display.CENTER_LEFT, DefenseNum:getPositionX()+DefenseNum:getContentSize().width+5,Attribute_pos[pos].y)
        jiantou:setVisible(false)
        local DefenseNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
        :addTo(msgBox)
        DefenseNum2:setColor(cc.c3b(117, 242, 31))
        DefenseNum2:setVisible(false)

        self.defense.name = Defense
        self.defense.Num1 = DefenseNum
        self.defense.jiantou = jiantou
        self.defense.Num2 = DefenseNum2
    end
    if item.cri>0 then
        pos = pos + 1
        local Cri=cc.ui.UILabel.new({UILabelType = 2, text = "暴击：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Cri:setColor(cc.c3b(248, 204, 45))
        local CriNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Cri:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        CriNum:setString(item.cri + (value["advLvl"]-1)*item.criGF)
        
        local jiantou = display.newSprite("common/Improve_Img16.png")
        :addTo(msgBox)
        :align(display.CENTER_LEFT, CriNum:getPositionX()+CriNum:getContentSize().width+5,Attribute_pos[pos].y)
        jiantou:setVisible(false)
        local CriNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
        :addTo(msgBox)
        CriNum2:setColor(cc.c3b(117, 242, 31))
        CriNum2:setVisible(false)

        self.cri.name = Cri
        self.cri.Num1 = CriNum
        self.cri.jiantou = jiantou
        self.cri.Num2 = CriNum2

    end
    if item.hit>0 then
        pos = pos + 1
        local Hit=cc.ui.UILabel.new({UILabelType = 2, text = "命中：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Hit:setColor(cc.c3b(248, 204, 45))
        local HitNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Hit:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)

        local jiantou = display.newSprite("common/Improve_Img16.png")
        :addTo(msgBox)
        :align(display.CENTER_LEFT, HitNum:getPositionX()+HitNum:getContentSize().width+5,Attribute_pos[pos].y)
        jiantou:setVisible(false)
        local HitNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
        :addTo(msgBox)
        HitNum2:setColor(cc.c3b(117, 242, 31))
        HitNum2:setVisible(false)

        self.hit.name = Hit
        self.hit.Num1 = HitNum
        self.hit.jiantou = jiantou
        self.hit.Num2 = HitNum2
        -- end
    end
    if item.miss>0 then
        pos = pos + 1
        local Miss=cc.ui.UILabel.new({UILabelType = 2, text = "闪避：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Miss:setColor(cc.c3b(248, 204, 45))
        local MissNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Miss:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        -- MissNum:setString(item.miss + (value["advLvl"]-1)*item.missGF)
        -- if mtype~=nil then
            local jiantou = display.newSprite("common/Improve_Img16.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, MissNum:getPositionX()+MissNum:getContentSize().width+5,Attribute_pos[pos].y)
            jiantou:setVisible(false)
            local MissNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
            :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
            :addTo(msgBox)
            MissNum2:setColor(cc.c3b(117, 242, 31))
            MissNum2:setVisible(false)

        self.miss.name = Miss
        self.miss.Num1 = MissNum
        self.miss.jiantou = jiantou
        self.miss.Num2 = MissNum2
    end
    if item.erecover>0 then
        pos = pos + 1
        local Erecover=cc.ui.UILabel.new({UILabelType = 2, text = "能量回复：", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        :addTo(msgBox)
        Erecover:setColor(cc.c3b(248, 204, 45))
        local ErecoverNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+Erecover:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        local tmp = item.erecover + (value["advLvl"]-1)*item.erGF
        tmp = string.format("%0.2f%%",(tmp*100))
        ErecoverNum:setString(tmp)
        -- if mtype~=nil then
            local jiantou = display.newSprite("common/Improve_Img16.png")
            :addTo(msgBox)
            :align(display.CENTER_LEFT, ErecoverNum:getPositionX()+ErecoverNum:getContentSize().width+5,Attribute_pos[pos].y)
            jiantou:setVisible(false)
            local erecoverNum2=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize})
            :align(display.CENTER_LEFT, jiantou:getPositionX()+jiantou:getContentSize().width+5,Attribute_pos[pos].y)
            :addTo(msgBox)
            erecoverNum2:setColor(cc.c3b(117, 242, 31))
            erecoverNum2:setVisible(false)

        self.erecover.name = Erecover
        self.erecover.Num1 = ErecoverNum
        self.erecover.jiantou = jiantou
        self.erecover.Num2 = erecoverNum2
    end
    --装载等级限制
    if item.minLvl>0 then
        local minLevel=cc.ui.UILabel.new({UILabelType = 2, text = "装载等级：", size = fontSize})
        :addTo(msgBox)
        minLevel:setColor(cc.c3b(132, 149, 165))
        local levelNum=cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = fontSize,color = cc.c3b(85, 177, 201)})
        :align(display.CENTER_LEFT, Attribute_pos[pos].x+minLevel:getContentSize().width,Attribute_pos[pos].y)
        :addTo(msgBox)
        -- levelNum:setString(item.minLvl)

        self.minLvl.name = minLevel
        self.minLvl.Num = levelNum

        if item.minLvl>srv_userInfo.level then
            minLevel:setColor(cc.c3b(230, 0, 18))
            levelNum:setColor(cc.c3b(230, 0, 18))
        end
    end



    --强化
    local stBt = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
        })
    :addTo(msgBox,-1)
    :pos(-50,msgBox:getContentSize().height-90)
    :onButtonClicked(function(event)
        if BtType==1 then
            return
        end
        BtType = 1
        setMenuStatus(event.target)
        if self.closeBt~=nil then
            self.closeBt:removeSelf()
            self.closeBt=nil
        end

        -- self.leftArrow:setVisible(true)
        -- self.rightArrow:setVisible(true)
        msgBox:setPositionX(display.cx-msgBox:getContentSize().width/2+50)
        self.strLayer:setVisible(true)
        self.advLayer:setVisible(false)
        GuideManager:_addGuide_2(10704, cc.Director:getInstance():getRunningScene(),handler(self.strLayer,
            self.strLayer.caculateGuidePos))
        self:reloadData(value,cur_localValue,1)
        end)
    self.guideBtn = stBt
    cc.ui.UILabel.new({UILabelType = 2, text = "强化", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(stBt,0,10)
    :align(display.CENTER, -20, 2)

    --进阶
    local advBt = cc.ui.UIPushButton.new({
        normal = "common/common_nBt7_1.png",
        disabled = "common/common_nBt7_2.png"
        })
    :addTo(msgBox,-2)
    :pos(-50,msgBox:getContentSize().height-180)
    :onButtonClicked(function(event)
        if BtType==2 then
            return
        end
        setMenuStatus(event.target)
        BtType = 2

        if self.closeBt~=nil then
            self.closeBt:removeSelf()
            self.closeBt=nil
        end
        -- self.leftArrow:setVisible(true)
        -- self.rightArrow:setVisible(true)
        msgBox:setPositionX(display.cx-msgBox:getContentSize().width/2+50)
        self.strLayer:setVisible(false)
        self.advLayer:setVisible(true)
        self:reloadData(value,cur_localValue,2)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "进阶", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(advBt,0,10)
    :align(display.CENTER, -20, 2)

    if self.mtype==nil and bItemCanAdvance(value.tmpId) then
        -- print("该物品可进阶")
        display.newSprite("common/common_RedPoint.png")
        :addTo(advBt,0,100)
        :pos(-75, 20)
    else
        -- print("该物品不可进阶")
    end

    --第三个按钮
    local changeBt = cc.ui.UIPushButton.new({
            normal = "common/common_nBt7_1.png",
            disabled = "common/common_nBt7_2.png"
            })
        :addTo(msgBox,-3)
        :pos(-50,msgBox:getContentSize().height-270)
    cc.ui.UILabel.new({UILabelType = 2, text = "更换", size = 27, color = cc.c3b(0, 149, 178)})
    :addTo(changeBt,0,10)
    :align(display.CENTER, -20, 2)
    if self.mtype==nil then
        --更换
        changeBt:getChildByTag(10):setString("更换")
        changeBt:onButtonClicked(function(event)
            local changelayer = changeNode.new(value,nil,
            function()
                CarManager:ReqCarProperty(srv_userInfo["characterId"])
                startLoading()
            end, self)
            :addTo(self:getParent(),10)
            -- self:removeSelf()
            self:setVisible(false)
            end)
        -- self.chanLayer = changelayer
    elseif self.mtype==1 then
        --分解
        changeBt:getChildByTag(10):setString("分解")
        changeBt:onButtonClicked(function(event)
            showMessageBox("确定分解"..self.localItem.name.."？", function()
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
            
            -- self:createDecomposeBox(value)
            end)
    end


    function setMenuStatus(node)
        stBt:setButtonEnabled(true)
        advBt:setButtonEnabled(true)
        changeBt:setButtonEnabled(true)

        stBt:setLocalZOrder(-1)
        advBt:setLocalZOrder(-1)
        changeBt:setLocalZOrder(-1)

        stBt:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        advBt:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        changeBt:getChildByTag(10):setColor(cc.c3b(0, 149, 178))

        node:setButtonEnabled(false)
        node:setLocalZOrder(0)
        node:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
    end
    -- function setMenuState(node)
    --     self.menuTab:setButtonEnabled(true)
    --     self.menuTab1:setButtonEnabled(true)
    --     self.menuTab2:setButtonEnabled(true)
    --     self.menuTab:setLocalZOrder(0)
    --     self.menuTab1:setLocalZOrder(0)
    --     self.menuTab2:setLocalZOrder(0)
    --     self.menuTab:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
    --     self.menuTab1:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
    --     self.menuTab2:getChildByTag(10):setColor(cc.c3b(0, 149, 178))

    --     node:setButtonEnabled(false)
    --     node:setLocalZOrder(-1)
    --     node:getChildByTag(10):setColor(cc.c3b(95, 217, 255))

    --     msgBox:removeAllChildren()
    -- end

    self.strLayer = strengNode.new(value, cur_localValue, self.callBack)
    :addTo(masklayer,0,101)
    self.strLayer:setVisible(false)

    self.advLayer = advancedNode.new(value, cur_localValue, 
        function(event)
            self.callBack()
            if self.mtype==nil and bItemCanAdvance(value.tmpId) then
                -- print("该物品可进阶")
                display.newSprite("common/common_RedPoint.png")
                :addTo(advBt)
                :pos(-75, 20)
            else
                advBt:removeChildByTag(100)
            end
        end 
        )
    :addTo(masklayer,0,100)
    self.advLayer:setVisible(false)

    --左右箭头
    -- self.leftArrow = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    -- :addTo(masklayer)
    -- :pos(display.cx-msgBox:getContentSize().width-50, msgBox:getPositionY())
    -- :onButtonPressed(function(event) event.target:setScale(0.95) end)
    -- :onButtonRelease(function(event) event.target:setScale(1.0) end)
    -- :onButtonClicked(function(event) 
    --  end)
    -- self.leftArrow:setVisible(false)

    -- self.rightArrow = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    -- :addTo(masklayer)
    -- :pos(display.cx+msgBox:getContentSize().width+50, msgBox:getPositionY())
    -- :onButtonPressed(function(event) event.target:setScaleX(-0.95) event.target:setScaleY(0.95) end)
    -- :onButtonRelease(function(event) event.target:setScaleX(-1.0) event.target:setScaleY(1.0)  end)
    -- :onButtonClicked(function(event)
    --     function toRight()
    --         self.eptIdx = self.eptIdx +1
    --         if self.eptIdx>5 then
    --             self.eptIdx = 1
    --         end
    --         local value = curEquipments[equipmentIdx[self.eptIdx]]
    --         if value and value~=0 then
    --             printTable(srv_carEquipment["item"])
    --             print(value)
    --             value = srv_carEquipment["item"][value]
    --             local isSuit = false 
    --             if cur_localValue.suitID~=0 then
    --                 isSuit = true
    --             end
    --             g_carEquipmentLayer.new(value,itemData[value.tmpId],nil,
    --                 function()
    --                     self.parentNode:RefreshUI()
    --                 end,
    --                 isSuit, curEquipments, self.parentNode)
    --             :addTo(self.parentNode,10)
    --         else
    --             toRight()
    --         end
    --     end
    --     toRight()
    --     self:removeSelf()


    --  end)
    -- self.rightArrow:setVisible(false)
    -- self.rightArrow:setScaleX(-1)
	
    self:reloadData(value,cur_localValue)
end
function carEquipmentsMsg:reloadData(value,cur_localValue,mtype) --mtype 1为强化，mtype 2为进阶
    local localItem = cur_localValue
    self.localItem = localItem

    local item = localItem
    local item2
    if advancedData[item.id]~=nil then
        local advanced = advancedData[item.id]
        item2 = itemData[advanced.toItemId]
    else
        if mtype==2 then
            mtype = nil
        end
    end
    self.mtype = mtype

     --判断是否是套装
    if self.isSuit then
        self.suitNode:setVisible(true)
        midBoxSize = cc.size(380, 210)
        
        Attribute_pos = {
                {x=50,y=190},
                {x=50,y=150},
                {x=50,y=110},
                {x=50,y=70},
                {x=50,y=230},

                {x=50,y=423},
                {x=50,y=383},
                {x=50,y=343},
            }
        

        local tmpSuitData = suitData[cur_localValue.suitID]

        --套装名字
        self.SuitName:setString(tmpSuitData.name.."（套装属性）")

        --套装属性是否激活
        local isSuitDisabled = isSuitActivated(value, cur_localValue)
        if isSuitDisabled then
            self.isSuitActImg:setTexture("SingleImg/BackPack/activated.png")
        else
            self.isSuitActImg:setTexture("SingleImg/BackPack/unactivate.png")
        end

        local AttributePos = {
            cc.p(20, 15),
            cc.p(160, 15),
            cc.p(300, 15),
            
            }
        local AttributeName = ""
        local AttributeNum = 0
        local posIdx = 0
        if tmpSuitData.hp>0 then
            posIdx = posIdx + 1
            AttributeName = "血量:"
            AttributeNum = tmpSuitData.hp

            self.suitHp:setVisible(true)
            self.suitHp:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitHp:setString(AttributeName.."+"..AttributeNum)
        else
            self.suitHp:setVisible(false)
        end
        if tmpSuitData.mainAtk>0 then
            posIdx = posIdx + 1
            AttributeName = "主炮攻击:"
            AttributeNum = tmpSuitData.mainAtk

            self.suitMainAtk:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitMainAtk:setString(AttributeName.."+"..AttributeNum)
            self.suitMainAtk:setVisible(true)
        else
            self.suitMainAtk:setVisible(false)
        end
        if tmpSuitData.subAtk>0 then
            posIdx = posIdx + 1
            AttributeName = "副炮攻击:"
            AttributeNum = tmpSuitData.subAtk

            self.suitSubAtk:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitSubAtk:setString(AttributeName.."+"..AttributeNum)
            self.suitSubAtk:setVisible(true)
        else
            self.suitSubAtk:setVisible(false)
        end
        if tmpSuitData.defense>0 then
            posIdx = posIdx + 1
            AttributeName = "防御:"
            AttributeNum = tmpSuitData.defense

            self.suitDef:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitDef:setString(AttributeName.."+"..AttributeNum)
            self.suitDef:setVisible(true)
        else
            self.suitDef:setVisible(false)
        end
        if tmpSuitData.cri>0 then
            posIdx = posIdx + 1
            AttributeName = "暴击:"
            AttributeNum = tmpSuitData.cri

            self.suitCri:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitCri:setString(AttributeName.."+"..AttributeNum)
            self.suitCri:setVisible(true)
        else
            self.suitCri:setVisible(false)
        end
        if tmpSuitData.hit>0 then
            posIdx = posIdx + 1
            AttributeName = "命中:"
            AttributeNum = tmpSuitData.hit

            self.suitHit:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitHit:setString(AttributeName.."+"..AttributeNum)
            self.suitHit:setVisible(true)
        else
            self.suitHit:setVisible(false)
        end
        if tmpSuitData.miss>0 then
            posIdx = posIdx + 1
            AttributeName = "闪避："
            AttributeNum = tmpSuitData.miss

            self.suitMiss:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitMiss:setString(AttributeName..AttributeNum)
        end
        if tmpSuitData.erecover>0 then
            posIdx = posIdx + 1
            AttributeName = "能量恢复："
            AttributeNum = tmpSuitData.erecover

            self.suitEre:pos(AttributePos[posIdx].x, AttributePos[posIdx].y)
            self.suitEre:setString(AttributeName..AttributeNum)
            self.suitEre:setVisible(true)
        else
            self.suitEre:setVisible(false)
        end

    else
        self.suitNode:setVisible(false)
        midBoxSize = cc.size(380, 300)
        Attribute_pos = {
            {x=50,y=230},
            {x=50,y=190},
            {x=50,y=150},
            {x=50,y=110},
            {x=50,y=270},

            {x=50,y=423},
            {x=50,y=383},
            {x=50,y=343},
        }
    end


    --装备技能或描述
    if localItem.sklId==0 then
        self.des:setVisible(true)
        self.sklNode:setVisible(false)
        self.des:setString(localItem.des)
        self.des:align(display.TOP_LEFT, Attribute_pos[1].x ,Attribute_pos[1].y)
    else
        self.des:setVisible(false)
        self.sklNode:setVisible(true)

        self.skl:align(display.CENTER_LEFT, Attribute_pos[1].x,Attribute_pos[1].y)
        self.sklName:align(display.CENTER_LEFT, Attribute_pos[1].x+self.skl:getContentSize().width, Attribute_pos[1].y)
        self.sklName:setString(skillData[localItem.sklId].sklName)

        self.hurt:align(display.CENTER_LEFT, Attribute_pos[2].x,Attribute_pos[2].y)
        self.hurtNum:align(display.CENTER_LEFT, Attribute_pos[2].x+self.hurt:getContentSize().width, Attribute_pos[2].y)
        self.hurtNum:setString((skillData[localItem.sklId].addPercent*100).."%")

        self.CD:align(display.CENTER_LEFT, Attribute_pos[3].x,Attribute_pos[3].y)
        self.CDTime:align(display.CENTER_LEFT, Attribute_pos[3].x+self.CD:getContentSize().width, Attribute_pos[3].y)

        self.effect:align(display.CENTER_LEFT, Attribute_pos[4].x,Attribute_pos[4].y)
        self.sklDes:align(display.TOP_LEFT, Attribute_pos[4].x+self.effect:getContentSize().width, Attribute_pos[4].y+13)
        self.sklDes:setString(skillData[localItem.sklId].sklDes)

        
        if getItemType(localItem.id)==101 then
            self.CDTime:setString(localItem.sklCD.."秒")
        else
            self.CDTime:setString(skillData[localItem.sklId].sklCD.."秒")
        end
        
    end


    --装备属性
    if mtype==1 then
        self.level:setString("强化："..value["advLvl"])
    elseif mtype==2 or mtype==nil then
        self.name:setString(localItem.name)
    else
        --隐藏
    end

    local pos=5
    if item.hp>0 then
        pos = pos + 1
        self.hp.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.hp.Num1:setString(math.floor(item.hp + (value["advLvl"]-1)*item.hpGF))
        self.hp.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.hp.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.hp.jiantou:setVisible(true)
            self.hp.Num2:setVisible(true)
            self.hp.jiantou:align(display.CENTER_LEFT, 
                    self.hp.Num1:getPositionX()+self.hp.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.hp.Num2:align(display.CENTER_LEFT, 
                    self.hp.jiantou:getPositionX()+self.hp.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.hp.Num2:setString(math.floor(item.hp + (value["advLvl"])*item.hpGF))
            elseif mtype==2 then
                self.hp.Num2:setString(math.floor(item2.hp + (value["advLvl"]-1)*item2.hpGF))
            end
        else
            self.hp.jiantou:setVisible(false)
            self.hp.Num2:setVisible(false)
        end
        
    end
    if item.attack>0 then
        pos = pos + 1
        self.attack.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.attack.Num1:setString(string.format("%.1f", (item.attack + (value["advLvl"]-1)*item.atkGF)))
        self.attack.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.attack.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.attack.jiantou:setVisible(true)
            self.attack.Num2:setVisible(true)
            self.attack.jiantou:align(display.CENTER_LEFT, 
                    self.attack.Num1:getPositionX()+self.attack.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.attack.Num2:align(display.CENTER_LEFT, 
                    self.attack.jiantou:getPositionX()+self.attack.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.attack.Num2:setString(string.format("%.1f", (item.attack + (value["advLvl"])*item.atkGF)))
            elseif mtype==2 then
                self.attack.Num2:setString(string.format("%.1f", (item2.attack + (value["advLvl"]-1)*item2.atkGF)))
            end
        else
            self.attack.jiantou:setVisible(false)
            self.attack.Num2:setVisible(false)
        end
        
    end
    if item.defense>0 then
        pos = pos + 1
        self.defense.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.defense.Num1:setString(string.format("%.1f", (item.defense + (value["advLvl"]-1)*item.defGF)))
        self.defense.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.defense.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.defense.jiantou:setVisible(true)
            self.defense.Num2:setVisible(true)
            self.defense.jiantou:align(display.CENTER_LEFT, 
                    self.defense.Num1:getPositionX()+self.defense.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.defense.Num2:align(display.CENTER_LEFT, 
                    self.defense.jiantou:getPositionX()+self.defense.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.defense.Num2:setString(string.format("%.1f", (item.defense + (value["advLvl"])*item.defGF)))
            elseif mtype==2 then
                self.defense.Num2:setString(string.format("%.1f", (item2.defense + (value["advLvl"]-1)*item2.defGF)))
            end
        else
            self.defense.jiantou:setVisible(false)
            self.defense.Num2:setVisible(false)
        end
        
    end
    if item.cri>0 then
        pos = pos + 1
        self.cri.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.cri.Num1:setString(string.format("%.1f", (item.cri + (value["advLvl"]-1)*item.criGF)))
        self.cri.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.cri.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.cri.jiantou:setVisible(true)
            self.cri.Num2:setVisible(true)
            self.cri.jiantou:align(display.CENTER_LEFT, 
                    self.cri.Num1:getPositionX()+self.cri.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.cri.Num2:align(display.CENTER_LEFT, 
                    self.cri.jiantou:getPositionX()+self.cri.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.cri.Num2:setString(string.format("%.1f", (item.cri + (value["advLvl"])*item.criGF)))
            elseif mtype==2 then
                self.cri.Num2:setString(string.format("%.1f", (item2.cri + (value["advLvl"]-1)*item2.criGF)))
            end
        else
            self.cri.jiantou:setVisible(false)
            self.cri.Num2:setVisible(false)
        end
        
    end
    if item.hit>0 then
        pos = pos + 1
        self.hit.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.hit.Num1:setString(string.format("%.1f", (item.hit + (value["advLvl"]-1)*item.hitGF)))
        self.hit.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.hit.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.hit.jiantou:setVisible(true)
            self.hit.Num2:setVisible(true)
            self.hit.jiantou:align(display.CENTER_LEFT, 
                    self.hit.Num1:getPositionX()+self.hit.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.hit.Num2:align(display.CENTER_LEFT, 
                    self.hit.jiantou:getPositionX()+self.hit.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.hit.Num2:setString(string.format("%.1f", (item.hit + (value["advLvl"])*item.hitGF)))
            elseif mtype==2 then
                self.hit.Num2:setString(string.format("%.1f", (item2.hit + (value["advLvl"]-1)*item2.hitGF)))
            end
        else
            self.hit.jiantou:setVisible(false)
            self.hit.Num2:setVisible(false)
        end
        
    end
    if item.miss>0 then
        pos = pos + 1
        self.miss.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.miss.Num1:setString(string.format("%.1f", (item.miss + (value["advLvl"]-1)*item.missGF)))
        self.miss.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.miss.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.miss.jiantou:setVisible(true)
            self.miss.Num2:setVisible(true)
            self.miss.jiantou:align(display.CENTER_LEFT, 
                    self.miss.Num1:getPositionX()+self.miss.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.miss.Num2:align(display.CENTER_LEFT, 
                    self.miss.jiantou:getPositionX()+self.miss.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.miss.Num2:setString(string.format("%.1f", (item.miss + (value["advLvl"])*item.missGF)))
            elseif mtype==2 then
                self.miss.Num2:setString(string.format("%.1f", (item2.miss + (value["advLvl"]-1)*item2.missGF)))
            end
        else
            self.miss.jiantou:setVisible(false)
            self.miss.Num2:setVisible(false)
        end
        
    end
    if item.erecover>0 then
        pos = pos + 1
        self.erecover.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y)
        self.erecover.Num1:setString((string.format("%.1f", (item.erecover + (value["advLvl"]-1)*item.erGF)*100)).."%")
        self.erecover.Num1:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.erecover.name:getContentSize().width,Attribute_pos[pos].y-2)
        if mtype~=nil then
            self.erecover.jiantou:setVisible(true)
            self.erecover.Num2:setVisible(true)
            self.erecover.jiantou:align(display.CENTER_LEFT, 
                    self.erecover.Num1:getPositionX()+self.erecover.Num1:getContentSize().width, Attribute_pos[pos].y)
            self.erecover.Num2:align(display.CENTER_LEFT, 
                    self.erecover.jiantou:getPositionX()+self.erecover.jiantou:getContentSize().width,Attribute_pos[pos].y-2)
            if mtype==1 then
                self.erecover.Num2:setString((string.format("%.1f", (item.erecover + (value["advLvl"])*item.erGF)*100)).."%")
            elseif mtype==2 then
                self.erecover.Num2:setString((string.format("%.1f", (item2.erecover + (value["advLvl"]-1)*item2.erGF)*100)).."%")
            end
        else
            self.erecover.jiantou:setVisible(false)
            self.erecover.Num2:setVisible(false)
        end
    end
    if item.minLvl>0 then
        pos = 5
        self.minLvl.name:align(display.CENTER_LEFT, Attribute_pos[pos].x, Attribute_pos[pos].y-2)
         self.minLvl.Num:align(display.CENTER_LEFT, Attribute_pos[pos].x+self.minLvl.name:getContentSize().width,Attribute_pos[pos].y-4)
        self.minLvl.Num:setString(item.minLvl)
    end
end

function createDecomposeBox(value,gold)
    local masklayer =  UIMasklayer.new()
    :addTo(display.getRunningScene(),100)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    --材料信息框
    local decomposeBox = display.newScale9Sprite("common/common_Frame4.png",display.cx, 
        display.cy,
        cc.size(500, 350),cc.rect(20, 20, 63, 61))
    :addTo(masklayer)
    masklayer:addHinder(decomposeBox)

    local tmpSize = decomposeBox:getContentSize()
    --分解产出
    cc.ui.UILabel.new({UILabelType = 2, text = "分解产出", size = 30, color = cc.c3b(255, 255, 0)})
    :addTo(decomposeBox)
    :align(display.CENTER, tmpSize.width/2, tmpSize.height - 40)

    --列表
    local lvBox = display.newScale9Sprite("common/Improve_Img14.png",nil,nil,
        cc.size(420, 180),cc.rect(20,20,136,6))
    :addTo(decomposeBox)
    :pos(tmpSize.width/2, tmpSize.height/2+20)
    local listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(0, 0, 420, 180),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(lvBox)

    local itCnt
    if gold>0 then
        itCnt = 1 + #srv_BackPackPushData["add"]
    else
        itCnt = #srv_BackPackPushData["add"]
    end
    -- local itCnt = 5
    for i=1,math.ceil(itCnt/3) do
        local item = listview:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(420, 180)
        listview:addItem(item)

        for j=1,3 do
            local itIdx = (3*(i-1)+j)
            if itIdx==1 and gold>0 then
                local icon = createGoldIcon(gold, 1)
                :addTo(content)
                :pos((j-2)*128, 20)
                local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
                :addTo(content)
                :align(display.CENTER, (j-2)*128, -60)
                name:setString("金币")
                
            else
                if itIdx>(itCnt) then
                    break
                end
                local curIdx = itIdx
                if gold>0 then
                    curIdx = itIdx -1
                end
                local icon = createItemIcon(srv_BackPackPushData["add"][curIdx].tmpId, 
                    srv_BackPackPushData["add"][curIdx].cnt)
                :addTo(content)
                :pos((j-2)*128, 20)
                :scale(0.75)
                local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
                :addTo(content)
                :align(display.CENTER, (j-2)*128, -60)
                name:setString(itemData[srv_BackPackPushData["add"][curIdx].tmpId].name)
                local dc_item = itemData[srv_BackPackPushData["add"][curIdx].tmpId+0]
                DCItem.get(tostring(dc_item.id), dc_item.name,srv_BackPackPushData["add"][curIdx].cnt, "分解产出:")
            end
            
        end
    end
    listview:reload()

    --确定按钮
    local bt = cc.ui.UIPushButton.new({
        normal = "common/commonBt3_1.png",
        pressed = "common/commonBt3_2.png"
        })
    :addTo(decomposeBox)
    :pos(tmpSize.width/2, 50)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)
    local img = display.newSprite("common/common_confirm.png")
    :addTo(bt)
end

function carEquipmentsMsg:onDecomposeResult(result) --分解
    endLoading()
    if result["result"]==1 then
        -- showTips("分解成功")
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

function carEquipmentsMsg:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10703 ==_guideId then
        if 10703==_guideId then
            g_node = self.guideBtn
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

return carEquipmentsMsg