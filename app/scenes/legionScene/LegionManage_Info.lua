local LegionManage_Info=class("LegionManage_Info", function()
    return display.newNode()
    end)
function LegionManage_Info:ctor()
	-- local memNumTxt = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	-- :addTo(self)
	-- :pos(15,40)
	-- memNumTxt:setColor(MYFONT_COLOR)
	-- local maxNum = legionLevelData[mLegionData.army.level].maxMemNum
	-- memNumTxt:setString("军团成员总数："..mLegionData.army.memNum.."/"..maxNum)

	--底框
	local btSelect = display.newSprite("#legion_img53.png")
	:addTo(self)
	:pos(466,-(50+display.height/2-360))

    --上线时间
    local bt1 = cc.ui.UIPushButton.new()
    :addTo(btSelect)
    :pos(260, btSelect:getContentSize().height/2-5)
    :onButtonClicked(function(event)
        setMenuStatus2(event.target)
        self:updateList(1)
        end)
    cc.ui.UILabel.new({UILabelType = 2, text = "最后上线时间", size = 27, color = cc.c3b(255, 221, 70)})
    :addTo(bt1, 0, 10)
    :align(display.CENTER, 0,0)
	
	--七日贡献
	local bt2 = cc.ui.UIPushButton.new()
    :addTo(btSelect)
    :pos(500, btSelect:getContentSize().height/2-5)
	:onButtonClicked(function(event)
        setMenuStatus2(event.target)
		self:updateList(2)
		end)
    cc.ui.UILabel.new({UILabelType = 2, text = "七日贡献活跃", size = 27, color = cc.c3b(151, 190, 204)})
    :addTo(bt2, 0, 10)
    :align(display.CENTER, 0,0)
	--挑战次数
	local bt3 = cc.ui.UIPushButton.new()
    :addTo(btSelect)
    :pos(740, btSelect:getContentSize().height/2-5)
	:onButtonClicked(function(event)
        setMenuStatus2(event.target)
		self:updateList(3)
		end)
    cc.ui.UILabel.new({UILabelType = 2, text = "团队挑战次数", size = 27, color = cc.c3b(151, 190, 204)})
    :addTo(bt3, 0, 10)
    :align(display.CENTER, 0,0)

    function setMenuStatus2(node)
        bt1:getChildByTag(10):setColor(cc.c3b(151, 190, 204))
        bt2:getChildByTag(10):setColor(cc.c3b(151, 190, 204))
        bt3:getChildByTag(10):setColor(cc.c3b(151, 190, 204))

        node:getChildByTag(10):setColor(cc.c3b(255, 221, 70))
    end
	
	self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 20, 895, 460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)

    self:updateList(1)

end
function LegionManage_Info:updateList(Type)
	self.listView:removeAllItems()
	sortLegionMenList()
	local tmpTable = mLegionData.mem
	for i,value in pairs(tmpTable) do
        local item = self.listView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(950,120)
        local itemW,itemH = item:getItemSize() 

        local bottomLine = display.newSprite("Block/sweep/sweep_img8.png")
            :addTo(content)
            :pos(0, -(itemH/2-7))

        if Type==1 then
            self:lastOnlineList(value,content,itemW,itemH)
        elseif Type==2 then
            self:oneWeekActiveList(value,content,itemW,itemH)    
        elseif Type==3 then
            self:fightTimesList(value,content,itemW,itemH)
        end
        self.listView:addItem(item)
    end
    self.listView:reload()
end
function LegionManage_Info:lastOnlineList(value,content,itemW,itemH)
    --成员头像
    headIdx = memberData[value.icon].resId
    local head = display.newSprite("Head/headman_"..headIdx..".png")
    :addTo(content)
    :pos(120-itemW/2,7)
    head:setScale(0.9)
    --成员等级
	local Level = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 85-itemH/2)
	Level:setString("LV:"..value.level)
	Level:setColor(cc.c3b(0, 183, 227))
	--成员名字
	local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 290-itemW/2, 85-itemH/2)
	name:setString(value.name)
	name:setColor(cc.c3b(151, 190, 204))
	--成员战斗力
	strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 35-itemH/2)
	strengthLabel:setColor(cc.c3b(123, 163, 172))
	local strength = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180 + strengthLabel:getContentSize().width-itemW/2, 35-itemH/2)
	strength:setString(value.strength)
	strength:setColor(cc.c3b(240, 133, 5))
	--职位
    if value.rank>0 then
        local pos = display.newSprite()
        :addTo(head)
        
        local post
        if value.rank==1 then
            post = display.newSpriteFrame("legion_img23.png")
            pos:align(display.BOTTOM_LEFT, 0 , -2)
        elseif value.rank==2 then
            post = display.newSpriteFrame("legion_img24.png")
            pos:align(display.LEFT_TOP, 0 , head:getContentSize().height)
        end
        pos:setSpriteFrame(post)
    end
	--最后上线时间
	local lastonline = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(content)
    :pos(700-itemW/2,0)
    lastonline:setColor(cc.c3b(248, 182, 45))
    lastonline:setString(getLastOnLine(value.lastOnTime))
end
function LegionManage_Info:oneWeekActiveList(value,content,itemW,itemH)
    --成员头像
    headIdx = memberData[value.icon].resId
    local head = display.newSprite("Head/headman_"..headIdx..".png")
    :addTo(content)
    :pos(120-itemW/2,0)
    head:setScale(0.9)
    --成员等级
	local Level = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 85-itemH/2)
	Level:setString("LV:"..value.level)
	Level:setColor(cc.c3b(0, 183, 227))
	--成员名字
	local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 290-itemW/2, 85-itemH/2)
	name:setString(value.name)
	name:setColor(cc.c3b(151, 190, 204))
	--成员战斗力
	strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 35-itemH/2)
	strengthLabel:setColor(cc.c3b(123, 163, 172))
	local strength = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180 + strengthLabel:getContentSize().width-itemW/2, 35-itemH/2)
	strength:setString(value.strength)
	strength:setColor(cc.c3b(240, 133, 5))
	--职位
    if value.rank>0 then
        local pos = display.newSprite()
        :addTo(head)
        
        local post
        if value.rank==1 then
            post = display.newSpriteFrame("legion_img23.png")
            pos:align(display.BOTTOM_LEFT, 0 , -2)
        elseif value.rank==2 then
            post = display.newSpriteFrame("legion_img24.png")
            pos:align(display.LEFT_TOP, 0 , head:getContentSize().height)
        end
        pos:setSpriteFrame(post)
    end
	--贡献值
	local contri = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(content)
    :pos(600-itemW/2,0)
    contri:setColor(cc.c3b(248, 182, 45))
    contri:setString("七日贡献活跃："..value.active)
end
function LegionManage_Info:fightTimesList(value,content,itemW,itemH)
    --成员头像
    headIdx = memberData[value.icon].resId
    local head = display.newSprite("Head/headman_"..headIdx..".png")
    :addTo(content)
    :pos(120-itemW/2,0)
    head:setScale(0.9)
    --成员等级
	local Level = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 85-itemH/2)
	Level:setString("LV:"..value.level)
	Level:setColor(cc.c3b(0, 183, 227))
	--成员名字
	local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 290-itemW/2, 85-itemH/2)
	name:setString(value.name)
	name:setColor(cc.c3b(151, 190, 204))
	--成员战斗力
	strengthLabel = cc.ui.UILabel.new({UILabelType = 2, text = "战斗力：", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180-itemW/2, 35-itemH/2)
	strengthLabel:setColor(cc.c3b(123, 163, 172))
	local strength = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	:addTo(content)
	:align(display.CENTER_LEFT, 180 + strengthLabel:getContentSize().width-itemW/2, 35-itemH/2)
	strength:setString(value.strength)
	strength:setColor(cc.c3b(240, 133, 5))
	--职位
    if value.rank>0 then
        local pos = display.newSprite()
        :addTo(head)
        
        local post
        if value.rank==1 then
            post = display.newSpriteFrame("legion_img23.png")
            pos:align(display.BOTTOM_LEFT, 0 , -2)
        elseif value.rank==2 then
            post = display.newSpriteFrame("legion_img24.png")
            pos:align(display.LEFT_TOP, 0 , head:getContentSize().height)
        end
        pos:setSpriteFrame(post)
    end
	--贡献值
	local lestTimes = cc.ui.UILabel.new({UILabelType = 2, text = "今日剩余：", size = 25})
    :addTo(content)
    :pos(600-itemW/2,0)
    lestTimes:setColor(cc.c3b(248, 182, 45))
    local lestNum = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
    :addTo(content)
    :pos(600+lestTimes:getContentSize().width-itemW/2,0)
    lestNum:setColor(cc.c3b(0, 255, 0))
    lestNum:setString(value.fCnt.."次")
end

return LegionManage_Info