-- @Author: anchen
-- @Date:   2016-01-26 16:41:55
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-07-12 16:00:15

--祈福迎新
local itemExchangeAct = class("itemExchangeAct",function()
    --local layer =  display.newColorLayer(cc.c4f(0, 0, 0, 200))
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
    end)

local ACTIVITY_ID = 118001

function itemExchangeAct:ctor()
    local activityType = "18"
    printTable(srv_userInfo.actInfo)
    ACTIVITY_ID = srv_userInfo.actInfo.actIds[activityType]
    local bgSize = cc.size(896,621)
    local bg = display.newScale9Sprite("youhui/youhuiImg_07.png",nil,nil,bgSize,cc.rect(60,0,1,621))
        :addTo(self)
        :pos(display.cx, display.cy-20)

    display.newSprite("youhui/youhuiImg_08.png")
    :addTo(bg)
    :pos(bgSize.width/2,bgSize.height-150)

    local bust = display.newSprite("Bust/bust_20094.png")
        :addTo(bg)
        :align(display.CENTER, bgSize.width-160, bgSize.height-110)
    bust:setScaleX(-0.8)
    bust:setScaleY(0.8)

    local img = display.newSprite("youhui/youhuiTag_16.png")
    :addTo(bg)
    :pos(bgSize.width/2-170, bgSize.height-80)

    local rechargeBt = cc.ui.UIPushButton.new("youhui/youhuiBnt_01.png")
    :addTo(bg)
    :pos(bgSize.width/2 + 140, img:getPositionY())
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "充 值", size = 33}))
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        g_recharge.new()
        :addTo(display.getRunningScene())
        end)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "收集关卡中掉落“福”，加上少量钻石即可兑换限时大礼包哦！", size = 28})
    :addTo(bg)
    :pos(70, bgSize.height-155)
    label:setWidth(600)
    
    local actTime = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28})
    :addTo(bg)
    :pos(70, bgSize.height-205)
    local datestr = "活动时间："
    local startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].effDate)
    datestr = datestr..tonumber(string.sub(startDate,1,4)).."年"
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日-"
    startDate = tostring(srv_userInfo.actInfo.actTime[tostring(ACTIVITY_ID)].endDate)
    datestr = datestr..tonumber(string.sub(startDate,5,6)).."月"
    datestr = datestr..tonumber(string.sub(startDate,7,8)).."日"
    actTime:setString(datestr)

    self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(10, 15, 880, 390),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }
        :addTo(bg)
        -- :setBounceable(false)
    
end
function itemExchangeAct:onEnter()
    startLoading()
    local tabMsg = {}
    m_socket:SendRequest(json.encode(tabMsg), CMD_FU_GETINFO, self, self.onFUGetInfo)
end
function itemExchangeAct:reloadListView()
    self.listview:removeAllItems()

    local sortList = {}
    for k,v in pairs(limitConsumeRewardData) do
        if v.aid==ACTIVITY_ID then
            sortList[#sortList+1] = v.id
        end
    end
    table.sort( sortList, function (val_1,val_2)
        return val_1<val_2
    end )

    for i=1,#sortList do
        local value = limitConsumeRewardData[sortList[i]]
        if value.aid == ACTIVITY_ID then
            local item = self.listview:newItem()
            local content = display.newNode()
            item:addContent(content)
            item:setItemSize(840, 130)
            self.listview:addItem(item)

            local bar = display.newSprite("youhui/youhuiImg_12.png")
            :addTo(content)

            local fromBar = display.newSprite("youhui/youhuiTag_15.png")
            :addTo(bar,1)
            :pos(120, bar:getContentSize().height/2)

            
            --钻石
            local diaBox = display.newSprite("itemBox/commonBox2.png")
            :addTo(fromBar)
            :pos(85, fromBar:getContentSize().height/2+5)
            :scale(0.8)
            display.newSprite("common/common_DiamondBg.png")
            :addTo(diaBox)
            :pos(diaBox:getContentSize().width/2, diaBox:getContentSize().height/2)
            cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = value.diamond, size = 25, color = cc.c3b(0,160,231)})
            :addTo(diaBox)
            :align(display.CENTER, diaBox:getContentSize().width/2, -10)
            --消耗道具
            local fromItems = lua_string_split(value.fromItem,"#")
            local icon = createItemIcon(tonumber(fromItems[1]))
            :addTo(fromBar)
            :pos(170, fromBar:getContentSize().height/2+5)
            :scale(0.7)

            --当前拥有的数量
            local srv_value = get_SrvBackPack_Value(tonumber(fromItems[1]))
            local cnt
            if srv_value == nil then
                cnt = 0
            else
                cnt = srv_value.cnt
            end

            cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = cnt.."/"..fromItems[2], size = 27, color = cc.c3b(0,160,231)})
            :addTo(icon)
            :align(display.CENTER, 0, -72)

            --兑换的物品
            local getItems = lua_string_split(value.reItems,"|")
            for i=1,#getItems do
                local itemInfo = lua_string_split(getItems[i],":")
                createItemIcon(itemInfo[1], itemInfo[2], true, true)
                :addTo(bar)
                :scale(0.8)
                :pos(280+(i-1)*100, bar:getContentSize().height/2)
            end

            local UIExChangeBt = cc.ui.UIPushButton.new({normal = "youhui/youhuiTag_19.png"},{grayState=true})
            :addTo(bar,1)
            :pos(bar:getContentSize().width-80, bar:getContentSize().height/2)
            :scale(0.8)
            :onButtonPressed(function(event) event.target:setScale(0.95*0.8) end)
            :onButtonRelease(function(event) event.target:setScale(1.0*0.8) end)
            :onButtonClicked(function(event)
                local bExchanged = true
                for i,key in ipairs(self.FUInfoData) do
                    if key==value.id then
                        bExchanged = false
                        break
                    end
                end
                if bExchanged then
                    showTips("不可重复兑换的物品")
                else
                    startLoading()
                    self.curValue = value
                    self.curBt = UIExChangeBt
                    local tabMsg = {}
                    tabMsg.gId = value.id
                    m_socket:SendRequest(json.encode(tabMsg), CMD_FU_EXCHANGE, self, self.onFUExchange)
                end
                end)

            if value.isRe==1 then
                cc.ui.UILabel.new({UILabelType = 2, text = "兑 换", size = 35, color = cc.c3b(242,244,187)})
                :addTo(UIExChangeBt,0,10)
                :align(display.CENTER, 0, 10)
                cc.ui.UILabel.new({UILabelType = 2, text = "（可重复）", size = 20, color = cc.c3b(242,244,187)})
                :addTo(UIExChangeBt)
                :align(display.CENTER, 0, -15)
            else
                local label = cc.ui.UILabel.new({UILabelType = 2, text = "已兑换", size = 40, color = cc.c3b(242,244,187)})
                :addTo(UIExChangeBt,0,10)
                :align(display.CENTER, 0, 0)
                UIExChangeBt:setButtonEnabled(false)
                for i,key in ipairs(self.FUInfoData) do
                    if key==value.id then
                        label:setString("兑 换")
                        UIExChangeBt:setButtonEnabled(true)
                        break
                    end
                end
            end
        end
    end
    self.listview:reload()
end

function itemExchangeAct:onFUGetInfo(result)
    if result.result==1 then
        self.FUInfoData = result.data.idList
        self:reloadListView()
    else
        showTips(result.msg)
    end
end
function itemExchangeAct:onFUExchange(result)
    if result.result==1 then
        srv_userInfo.diamond = result.data.diamond
        mainscenetopbar:setDiamond()
        -- showMessageBox("兑换成功，请前往背包查看")
        --恭喜获得
        local curRewards = {}
        local rewards = lua_string_split(self.curValue.reItems,"|")
        for i=1,#rewards do
            local rewardItem = lua_string_split(rewards[i],":")
            if tonumber(rewardItem[1])==1 then
                table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=golds})
            elseif tonumber(rewardItem[1])==2 then
                table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=diamond})
            else
                table.insert(curRewards, {templateID=tonumber(rewardItem[1]), num=tonumber(rewardItem[2])})
            end
        end
        GlobalShowGainBox(nil, curRewards)
        
        if self.curValue.isRe~=1 then
            for i,key in ipairs(self.FUInfoData) do
                if key == self.curValue  then
                    table.remove(self.FUInfoData, i)
                    break
                end
            end
        end

        self:reloadListView()
        
    else
        showTips(result.msg)
    end
end


return itemExchangeAct