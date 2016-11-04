-- @Author: anchen
-- @Date:   2015-09-22 10:45:41
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-09-13 12:00:47
local activityLayer = class("activityLayer",function()
    local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)

function activityLayer:ctor()
    -- local mainBg = getMainSceneBgImg(mapAreaId)
    -- :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)



    local bigBox = display.newScale9Sprite("activity/bigBox.png",nil,nil,cc.size(1007,519))
    :addTo(self,1)
    :pos(display.cx, display.cy-40)
    local boxSize = bigBox:getContentSize()

    --轮子
    display.newSprite("common/common_lunzi2.png")
    :addTo(self,0)
    :pos(display.cx-boxSize.width/2+15, display.cy-40-boxSize.height/2+20)
    :scale(1.2)

    display.newSprite("common/common_lunzi2.png")
    :addTo(self,0)
    :pos(display.cx+boxSize.width/2-15, display.cy-40-boxSize.height/2+20)
    :scale(1.2)

    --上边
    local topBar = display.newSprite("activity/topBorder.png")
    :addTo(bigBox)
    :pos(boxSize.width/2, boxSize.height+30)

    --title
    display.newSprite("activity/title.png")
    :addTo(topBar)
    :pos(topBar:getContentSize().width/2, topBar:getContentSize().height - 33)

    --侧边
    display.newSprite("activity/side.png")
    :addTo(bigBox)
    :pos(0, boxSize.height/2)

    display.newSprite("activity/side.png")
    :addTo(bigBox)
    :pos(boxSize.width, boxSize.height/2)
    :setScaleX(-1)

    --上左右角
    display.newSprite("activity/corner.png")
    :addTo(bigBox)
    :pos(45, boxSize.height-20)

    display.newSprite("activity/corner.png")
    :addTo(bigBox)
    :pos(boxSize.width-45, boxSize.height-20)
    :setScaleX(-1)


    --下边
    display.newSprite("activity/side1.png")
    :addTo(bigBox)
    :pos(boxSize.width/4-5, 45)

    display.newSprite("activity/side1.png")
    :addTo(bigBox)
    :pos(boxSize.width/4*3+5, 45)
    :setScaleX(-1)

    display.newSprite("activity/side2.png")
    :addTo(bigBox)
    :pos(boxSize.width/2, 8)


    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common/common_CloseBtn_1.png",
        pressed = "common/common_CloseBtn_2.png"
        })
    :addTo(bigBox)
    :pos(boxSize.width, boxSize.height)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)


    local leftBox = display.newScale9Sprite("activity/box1.png", nil, nil, cc.size(333, 466))
    :addTo(bigBox)
    :pos(195, boxSize.height/2)

    local rightBox = display.newScale9Sprite("activity/box1.png", nil, nil, cc.size(599, 466))
    :addTo(bigBox)
    :pos(boxSize.width - 330, boxSize.height/2)

    self.title = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(248, 182, 45)})
    :addTo(rightBox)
    :align(display.CENTER, rightBox:getContentSize().width/2, rightBox:getContentSize().height - 30)

    local rightMidBox = display.newScale9Sprite("activity/box2.png",nil ,nil, cc.size(566, 382))
    :addTo(rightBox)
    :pos(rightBox:getContentSize().width/2, rightBox:getContentSize().height/2-15)

    self.listView = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(15, 15, 303, 436),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(leftBox)

    local svsize = cc.size(546, 362)
    self.scrollview = {}
    self.scrollview.sv = cc.ui.UIScrollView.new({
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect=cc.rect(10, 10, 546, 362),
        direction=cc.ui.UIScrollView.DIRECTION_VERTICAL})
    :addTo(rightMidBox)

    local scNode =  display.newNode()
    :pos(10, 0)
    self.scrollview.sv:addScrollNode(scNode)

    --活动时间
    self.scrollview.title1 = cc.ui.UILabel.new({UILabelType = 2, text = "活动时间：", 
        size = 25, color = cc.c3b(248, 182, 45)})
    :addTo(scNode)
    :pos(0, svsize.height - 20)

    self.scrollview.date = cc.ui.UILabel.new({UILabelType = 2, text = "", 
        size = 22, color = MYFONT_COLOR})
    :addTo(scNode)
    :pos(0, svsize.height - 60)

    --活动内容
    self.scrollview.title2 = cc.ui.UILabel.new({UILabelType = 2, text = "活动内容：", 
        size = 25, color = cc.c3b(248, 182, 45)})
    :addTo(scNode)
    :pos(0, svsize.height - 100)

    self.scrollview.content = cc.ui.UILabel.new({UILabelType = 2, text = "", 
        size = 22, color = MYFONT_COLOR})
    :addTo(scNode)
    :pos(0, svsize.height - 130)
    self.scrollview.content:setWidth(500)
    self.scrollview.content:setLineHeight(30)
    self.scrollview.content:setAnchorPoint(0,1)

end
function activityLayer:onEnter()
    startLoading()
    comData={}
    comData["characterId"] = srv_userInfo.characterId
    m_socket:SendRequest(json.encode(comData), CMD_ACTIVITY, self, self.OnActivity)
end

function activityLayer:reloadLisview()
    self.listView:removeAllItems()

    for i,value in ipairs(ActivitySrvInfo) do
        local item = self.listView:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(303, 100)
        self.listView:addItem(item)

        local itemBar = cc.ui.UIPushButton.new("activity/itemBar.png")
        :addTo(content)
        :onButtonPressed(function(event)
            event.target:setScale(0.98)
            end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
            end)
        :onButtonClicked(function(event)
            self.title:setString(value.title)
            self.scrollview.content:setString(value.content)
            local str = self:srvDateToString(value.effDate, value.effTime, value.endDate, value.endTime)
            self.scrollview.date:setString(str)
            end)
        itemBar:setTouchSwallowEnabled(false)

        --活动图标
        if i==1 then
            display.newSprite("achIcon/task_101014.png")
            :addTo(itemBar)
            :pos(-103,0)
            :scale(0.94)
        else
            display.newSprite("achIcon/task_101016.png")
            :addTo(itemBar)
            :pos(-103,0)
            :scale(0.94)
        end

        --活动名字
        cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = cc.c3b(79, 52, 43)})
        :addTo(itemBar)
        :pos(-60, 18)
        :setString(value.title)

        --活动状态
        local sts = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
        :addTo(itemBar)
        :pos(-60, -18)
        if value.sts==0 then
            sts:setString("未开启")
            sts:setColor(cc.c3b(50, 50, 50))
        elseif value.sts==1 then
            sts:setString("进行中")
            sts:setColor(cc.c3b(0, 255, 0))
        elseif value.sts==2 then
            sts:setString("已结束")
            sts:setColor(cc.c3b(255, 0, 0))
        end
    end
    self.listView:reload()
end


function activityLayer:OnActivity(ret)
    endLoading()
    if ret.result==1 then
        ActivitySrvInfo = ret.data.actInfo
        for i,value in ipairs(ActivitySrvInfo) do
            if value.type==12 then
                table.remove(ActivitySrvInfo, i)
            end
        end

        self:reloadLisview()

        local tmpvalue = ActivitySrvInfo[1]

        if tmpvalue then
            self.title:setString(tmpvalue.title)
            self.scrollview.content:setString(tmpvalue.content)
            local str = self:srvDateToString(tmpvalue.effDate, tmpvalue.effTime, tmpvalue.endDate, tmpvalue.endTime)
            self.scrollview.date:setString(str)
            self.scrollview.title2:setVisible(true)
        else
            self.scrollview.title1:setString("暂无活动")
            self.scrollview.title2:setVisible(false)
        end
        
    else
        showTips(ret.msg)
    end
end

function activityLayer:srvDateToString(effDate, effTime, endDate, endTime)
    local retStr = ""
    local eDateStr,endDateStr = "", ""
    eYear = string.sub(effDate, 1, 4)
    eMoth = string.sub(effDate, 5, 6)
    eDay = string.sub(effDate, 7, 9)

    eYear2 = string.sub(endDate, 1, 4)
    eMoth2 = string.sub(endDate, 5, 6)
    eDay2 = string.sub(endDate, 7, 9)

    eDateStr = eYear.."年"..eMoth.."月"..eDay.."日"..effTime
    endDateStr = eYear2.."年"..eMoth2.."月"..eDay2.."日"..endTime

    retStr = eDateStr.."—"..endDateStr

    return retStr
end

return activityLayer