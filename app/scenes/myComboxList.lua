
local myComboxList = class("myComboxList",function()
	return display.newLayer()
end)

-- local listView
-- local jiantou

function myComboxList:ctor()

end

function myComboxList:updateBoxList(firstPanelBg,toLogin)
    local userNameBt  = firstPanelBg:getChildByTag(100)
    self.jiantou  = userNameBt:getChildByTag(10)
    self.jiantou:setRotation(0)
    curUserNameText  = userNameBt:getChildByTag(11)
    -- curUserName:setString(GameData.login_username)

    local size = 0
    if GameData.accountList then
        curUserNameText:setString(GameData.accountList[1].username)
        size = #GameData.accountList
    else
        curUserNameText:setString("")
    end


    self.listView = cc.ui.UIListView.new {
            bgColor = cc.c4b(200, 200, 200, 255),
            bgScale9 = true,
            viewRect = cc.rect(53, 303-84*(size-1), 579, 84*size+99),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
            -- :onTouch(handler(self, self.touchListener))
            :addTo(firstPanelBg, 10)
    self.listView:setBounceable(false)
    self.listView:setVisible(false)

    


    userNameBt:onButtonClicked(function(event)
        self:closeOpenList()
    end)

    self:createList(firstPanelBg,toLogin)

end

function myComboxList:closeOpenList()
        if self.jiantou:getRotation()==0 then
            self.jiantou:setRotation(180)
            self.listView:setVisible(true)
            -- self.createList(firstPanelBg)
            -- self:createList(firstPanelBg)
        else
            self.jiantou:setRotation(0)
            self.listView:setVisible(false)
        end
end

function myComboxList:createList(firstPanelBg,toLogin)
        self.listView:removeAllItems()
        -- printTable(GameData)
        if GameData.accountList~=nil then

            for k,value in ipairs(GameData.accountList)  do
                local item = self.listView:newItem()
                local content = display.newNode()

                local itemBar = cc.ui.UIPushButton.new("SingleImg/login/item.png")
                :addTo(content)
                itemBar:setAnchorPoint(0.5,0.5)
                item:setItemSize(579, 84)
                -- itemBar:removeAllEventListeners()
                itemBar:onButtonClicked(function(event)
                    addAccount(value.username, value.password)
                    curUserNameText:setString(value.username)
                    self:closeOpenList()
                    -- self:createList(firstPanelBg,toLogin)
                    end)
                local head = cc.ui.UIImage.new("SingleImg/login/head.png")
                :addTo(itemBar)
                head:setAnchorPoint(0,0.5)
                head:pos(-280,0)
                local Account=cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30})
                :align(display.CENTER_LEFT,-210,0)
                :addTo(itemBar)
                Account:setColor(display.COLOR_BLACK)
                Account:setString(value.username)
                local deleteBt = cc.ui.UIPushButton.new("SingleImg/login/deleteBt.png")
                :addTo(content)
                deleteBt:setAnchorPoint(0.5,0.5)
                deleteBt:pos(250,0)
                -- deleteBt:removeAllEventListeners()
                deleteBt:onButtonClicked(function(event)
                    delAccount(value.username)
                    if GameData.accountList==nil then
                        curUserNameText:setString("")
                    else
                        curUserNameText:setString(GameData.accountList[1].username)
                    end
                    self.listView:removeItem(item,false)
                    -- self.createList(firstPanelBg)
                    end)

                item:addContent(content)
                self.listView:addItem(item)
            end

        end

        --其他账户Item
        local item = self.listView:newItem()
        local content = display.newNode()
        local itemBar = cc.ui.UIPushButton.new("SingleImg/login/othersItem.png")
        :addTo(content)
        itemBar:setAnchorPoint(0.5,0.5)
        -- itemBar:removeAllEventListeners()
        itemBar:onButtonClicked(function(event)
            toLogin()
            end)
        local others = cc.ui.UIImage.new("SingleImg/login/others.png")
        :addTo(itemBar)
        others:setAnchorPoint(0.5,0.5)
        item:setItemSize(579, 99)
        item:addContent(content)
        self.listView:addItem(item)

        self.listView:reload()
end

return myComboxList