-- Author: liufei
-- Date:   2015-09-16 11:50:12
local LimitOneItem = reloadLuaFile("app.scenes.shop.LimitOneItem")

redPtTag = {}

local ACTIVITY_ID = 101001

function getLimitConsumeRedBool()
    for k,v in pairs (LimitConsumeData) do
        if redPtTag[v.id] then
            return true  --要打红点
        end
    end
    return false  --无红点
end

local LimitConsume = class("LimitConsume",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)

function LimitConsume:ctor(_result)
    ACTIVITY_ID = _result.actId
    self:setTouchEnabled(true)
    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)
    self.sBg = bg

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2, bgSize.height-150)

    display.newSprite("youhui/youhuiTag_11.png")
    :addTo(bg)
    :align(display.LEFT_CENTER,30, bgSize.height-85)

    display.newSprite("youhui/youhuiImg_10.png")
        :addTo(bg)
        :pos(bgSize.width/2-100,bgSize.height-100)
    

    --关闭按钮
    cc.ui.UIPushButton.new({normal="common/common_CloseBtn_1.png",pressed="common/common_CloseBtn_2.png"})
    :align(display.CENTER, bgSize.width-3, bgSize.height-5)
    :addTo(self.sBg)
    :onButtonClicked(function(event)
        self:removeFromParent()
    end)
    :hide()

    --左上侧时间
    
    print(tostring(ACTIVITY_ID))
    printTable(srv_userInfo.actInfo.actTime)
    local startTime = srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)]["effDate"]
    local endTime = srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)]["endDate"]
    local sYear,sMonth,sDay, eYear,eMonth,eDay = "","","","","",""
    sYear = tonumber(string.sub(tostring(startTime),1,4))
    sMonth = tonumber(string.sub(tostring(startTime),5,6))
    sDay = tonumber(string.sub(tostring(startTime),7,8))
    eYear = tonumber(string.sub(tostring(endTime),1,4))
    eMonth = tonumber(string.sub(tostring(endTime),5,6))
    eDay = tonumber(string.sub(tostring(endTime),7,8))
    
    local tip = display.newTTFLabel{text = "活动开启时间：",size= 20,color= cc.c3b(18,186,229)}
        :addTo(self.sBg)
        :align(display.LEFT_CENTER,70, bgSize.height*0.75)
    local dateStr = sYear.."年"..sMonth.."月"..sDay.."日".."-".. eYear.."年"..eMonth.."月"..eDay.."日"
    display.newTTFLabel{text = dateStr,size= 20,color= cc.c3b(255,250,188)}
    :align(display.LEFT_CENTER,tip:getPositionX()+tip:getContentSize().width, tip:getPositionY())
    :addTo(self.sBg)

    --右上侧广告
    display.newSprite("youhui/youhuiImg_16.png")
    :pos(bgSize.width*0.7,bgSize.height*0.88)
    :addTo(self.sBg)


    --下部黑底板
    local blackBg = display.newScale9Sprite("limitConsume/brag_shops-02.png", nil, nil, cc.size(800,403))
    :align(display.BOTTOM_CENTER,bgSize.width*0.5,40)
    :addTo(self.sBg)
    
    local blackSize = blackBg:getContentSize()
    for i=1,#_result.itemInfo do
        local tmpItem = LimitOneItem.new(_result.itemInfo[i])
        :addTo(blackBg)
        if i == 1 then
            tmpItem:setPosition(blackSize.width*0.22,blackSize.height*0.74)
        elseif i == 2 then
            tmpItem:setPosition(blackSize.width*0.74,blackSize.height*0.74)
        elseif i == 3 then
            tmpItem:setPosition(blackSize.width*0.22,blackSize.height*0.26)
        elseif i == 4 then
            tmpItem:setPosition(blackSize.width*0.74,blackSize.height*0.26)
        end
    end
end


return LimitConsume