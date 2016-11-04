-- @Author: anchen
-- @Date:   2015-08-23 09:09:23
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-08-01 11:10:32
require("app.scenes.recharge.RechargeManager")
local Store = require("framework.cc.sdk.Store")

local AllProductsID = {
                         [1] = "com.threeBirdsGame.zcsj.d60",
                         [2] = "com.threeBirdsGame.zcsj.monthcard",
                         [3] = "com.threeBirdsGame.zcsj.d300",
                         [4] = "com.threeBirdsGame.zcsj.d980",
                         [5] = "com.threeBirdsGame.zcsj.d1980",
                         [6] = "com.threeBirdsGame.zcsj.d3280",
                         [7] = "com.threeBirdsGame.zcsj.d6480",
                      }
if gType_SDK==AllSdkType.Sdk_IOS2 then
    AllProductsID = {
                         [1] = "com.threeBirdsGame.zzjbfk.d60",
                         [2] = "com.threeBirdsGame.zzjbfk.monthcard",
                         [3] = "com.threeBirdsGame.zzjbfk.d300",
                         [4] = "com.threeBirdsGame.zzjbfk.d980",
                         [5] = "com.threeBirdsGame.zzjbfk.d1980",
                         [6] = "com.threeBirdsGame.zzjbfk.d3280",
                         [7] = "com.threeBirdsGame.zzjbfk.d6480",
}
elseif gType_SDK==AllSdkType.Sdk_IOS3 then
    AllProductsID = {
                         [1] = "com.threeBirdsGame.tksj.d60",
                         [2] = "com.threeBirdsGame.tksj.monthcard",
                         [3] = "com.threeBirdsGame.tksj.d300",
                         [4] = "com.threeBirdsGame.tksj.d980",
                         [5] = "com.threeBirdsGame.tksj.d1980",
                         [6] = "com.threeBirdsGame.tksj.d3280",
                         [7] = "com.threeBirdsGame.tksj.d6480",
                     }
elseif gType_SDK==AllSdkType.Sdk_IOS4 then
    AllProductsID = {
                         [1] = "com.threeBirdsGame.qmtk.d60",
                         [2] = "com.threeBirdsGame.qmtk.monthcard",
                         [3] = "com.threeBirdsGame.qmtk.d300",
                         [4] = "com.threeBirdsGame.qmtk.d980",
                         [5] = "com.threeBirdsGame.qmtk.d1980",
                         [6] = "com.threeBirdsGame.qmtk.d3280",
                         [7] = "com.threeBirdsGame.qmtk.d6480",
                     }
elseif gType_SDK==AllSdkType.Sdk_IOS5 then
    AllProductsID = {
                         [1] = "com.threeBirdsGame.qmtk2.d60",
                         [2] = "com.threeBirdsGame.qmtk2.monthcard",
                         [3] = "com.threeBirdsGame.qmtk2.d300",
                         [4] = "com.threeBirdsGame.qmtk2.d980",
                         [5] = "com.threeBirdsGame.qmtk2.d1980",
                         [6] = "com.threeBirdsGame.qmtk2.d3280",
                         [7] = "com.threeBirdsGame.qmtk2.d6480",
                     }
end

rechargeLayer = class("rechargeLayer", function()
    return display.newScene("rechargeLayer")
end)

-- local rechargeRecordInfo = {}
-- local curValue

rechargeLayer.Instance = nil
function rechargeLayer:ctor()

    local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    --充值框
    local rechargeHead = display.newSprite("recharge/recharge2_img1.png")
    :addTo(self)
    :pos(display.cx, display.cy+170)
    self.rechargeBox = rechargeBox

    local rechargeBox = display.newScale9Sprite("recharge/recharge2_img4.png",nil,nil,cc.size(1045,417))
    :addTo(self)
    :pos(display.cx, display.cy-120)
    self.rechargeBox = rechargeBox
 

    --关闭按钮
    local closeBt = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"
        })
    :addTo(self)
    :align(display.LEFT_TOP, 0, display.height)
    :onButtonClicked(function(event)
        self:removeSelf()
        if firstRecharge.Instance~=nil then
            firstRecharge.Instance:setBtStatus()
        end
        end)

    display.newSprite("recharge/vipImg.png")
    :addTo(rechargeHead)
    :pos(290, rechargeHead:getContentSize().height/2+25)

    --当前vip
    self.vipNum = cc.LabelAtlas:_create()
    :pos(345,rechargeHead:getContentSize().height/2+25)
    :addTo(rechargeHead)
    self.vipNum:setAnchorPoint(0,0.5)
    self.vipNum:initWithString("", "recharge/vipNum1.png", 48.1, 69, string.byte(0))
    self.vipNum:setString(srv_userInfo.vip)

    --vip进度
    local btmbar = display.newSprite("recharge/recharge2_img6.png")
    :addTo(rechargeHead)
    :pos(rechargeHead:getContentSize().width/2, 60)
    self.progress = cc.ui.UILoadingBar.new({image = "recharge/recharge2_img7.png",
        viewRect = cc.rect(0,0,618,35)})
    :addTo(btmbar)

    --再充多少成为下一级VIP
    local dy = 25
    self.nextVipImg = cc.ui.UILabel.new({UILabelType = 2, text = "再充值", size = 25})
    :addTo(rechargeHead)
    :pos(rechargeHead:getContentSize().width/2-90, 80+dy)
    self.needDiamond = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 242, 85)})
    :addTo(rechargeHead)
    :pos(self.nextVipImg:getPositionX()+self.nextVipImg:getContentSize().width, 80+dy)

    self.diaImg =  display.newSprite("common/common_Diamond.png")
    :addTo(rechargeHead)
    :scale(0.8)

    self.text2 = cc.ui.UILabel.new({UILabelType = 2, text = "成为", size = 25})
    :addTo(rechargeHead)
    
    
    self.smallVip = display.newSprite("recharge/vipImg.png")
    :addTo(rechargeHead)
    :scale(0.5)

    --下一级vip
    self.nextvipNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 28, color = cc.c3b(255, 242, 85)})
    :addTo(rechargeHead)
    -- self.nextvipNum:initWithString("", "recharge/vipNum2.png", 23.7, 35, string.byte(0))

    --查看特权按钮
    local desBt = cc.ui.UIPushButton.new("recharge/recharge2_img5.png")
    :addTo(rechargeHead)
    :pos(130, rechargeHead:getContentSize().height/2)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:initPrivilegeUI()
        if srv_userInfo.vip<15 then
            self:reloadPrivilegeUI(srv_userInfo.vip+1)
        else
            self:reloadPrivilegeUI(15)
        end
        DCEvent.onEvent("查看特权")
        
        end)

    --礼包
    local gift = display.newSprite("recharge/giftImg.png")
    :addTo(rechargeHead)
    :pos(rechargeHead:getContentSize().width-115, rechargeHead:getContentSize().height/2)

    --礼包上，vip
    display.newSprite("recharge/vipImg2.png")
    :addTo(gift)
    :pos(gift:getContentSize().width/2-20, 80)

    self.nextvipNum2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 28, color = cc.c3b(255, 242, 85)})
    :pos(gift:getContentSize().width/2+10, 80)
    :addTo(gift)
    self.nextvipNum2:setAnchorPoint(0,0.5)
    -- self.nextvipNum2:initWithString("", "recharge/vipNum2.png", 24, 35, string.byte(0))
    

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "可购买特权礼包", size = 23, color = cc.c3b(255, 242, 85)})
    :addTo(gift,3)
    :pos(gift:getContentSize().width/2, 50)
    label:setAnchorPoint(0.5,0.5)
    setLabelStroke(label,23,nil,1,nil,nil,nil,nil, true)


    startLoading()
    local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_GETRECHAGE_INFO, self, self.onGetRechargeInfo)

    --IOS支付初始化
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
        --初始化商店
        if not cc.storeProvider then
            Store.init(handler(self, self.iosIapCallback)) 
        end
        
    end  

end
function rechargeLayer:onEnter()
    rechargeLayer.Instance = self
    DCEvent.onEventBegin("留在充值界面")
end
function rechargeLayer:onExit()
    rechargeLayer.Instance = nil
    DCEvent.onEventEnd("留在充值界面")
end

function rechargeLayer:reloadData()
    local vipNum = srv_userInfo.vip
    
    if srv_userInfo.vip<15 then
        local needNum = vipLevelData[vipNum+1].diamond - self.rechargeRecordInfo.paidDiad
        local per = (self.rechargeRecordInfo.paidDiad-vipLevelData[vipNum].diamond)/
                (vipLevelData[vipNum+1].diamond - vipLevelData[vipNum].diamond)
        -- print(self.rechargeRecordInfo.paidDiad)
        -- print(vipLevelData[vipNum].diamond)
        -- print(vipLevelData[vipNum+1].diamond)
        -- print(vipLevelData[vipNum].diamond)

        self.needDiamond:setString(needNum)
        self.diaImg:align(display.CENTER_LEFT, self.needDiamond:getPositionX()+self.needDiamond:getContentSize().width, 105)
        self.text2:pos(self.diaImg:getPositionX()+self.diaImg:getContentSize().width*0.8, 105)
        self.smallVip:align(display.CENTER_LEFT, self.text2:getPositionX()+self.text2:getContentSize().width, 105)
        self.vipNum:setString(srv_userInfo.vip)
        self.nextvipNum:setVisible(true)
        self.nextvipNum:setString(srv_userInfo.vip+1)
        self.nextvipNum:align(display.CENTER_LEFT, self.smallVip:getPositionX()+self.smallVip:getContentSize().width *0.5, 105)
        self.nextvipNum2:setString(srv_userInfo.vip+1)
        print(per*100)
        if per<0 then per=0 end
        self.progress:setPercent(per*100)
    else
        self.vipNum:setString(srv_userInfo.vip)
        self.progress:setPercent(100)
        self.needDiamond:setVisible(false)
        self.diaImg:setVisible(false)
        self.text2:setVisible(false)
        self.smallVip:setVisible(false)
        self.nextVipImg:setVisible(false)
        self.nextvipNum:setVisible(false)
        self.nextvipNum2:setString(15)
    end

    -- self.vipNum:setString(srv_userInfo.vip)
end

function rechargeLayer:initGoodsUI()
    self.goodsLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(30, 30, 977, 375),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(self.rechargeBox)

    -- self:sortRechargeData()
    self:reloadGoodsUI()
end
function rechargeLayer:sortRechargeData()
    if rechargeData[2].type==2 then
        local tmp = rechargeData[2]
        table.remove(rechargeData, 2)
        table.insert(rechargeData, 1, tmp)
    end
end
function rechargeLayer:reloadGoodsUI()
    self.goodsLv:setVisible(true)
    -- if self.tequan then
    --     self.tequan[1].box:setVisible(false)
    --     self.tequan[2].box:setVisible(false)
    -- end
    
    self.goodsLv:removeAllItems()


    for i=1,#rechargeData do
        local item = self.goodsLv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(235, 345)
        self.goodsLv:addItem(item)

        local cnt = i
        local lcl_value = rechargeData[cnt]
        if lcl_value==nil then
            break
        end
        local barbt = cc.ui.UIPushButton.new("recharge/recharge2_img10.png")
        :addTo(content)
        :pos(0,-10)
        barbt:setButtonEnabled(false)
        barbt:setTouchSwallowEnabled(false)

        local buyBt = createYellowBt(lcl_value.money.."元")
        :addTo(barbt)
        :pos(0, -117)
        :onButtonClicked(function(event)
            print(loginServerList.serverId)
            self.cnt = cnt
            if cnt==2 and self.rechargeRecordInfo.validity>=5 then
                showTips("月卡已购买，剩余"..(self.rechargeRecordInfo.validity).."天有效，剩余5天内可再次购买")
                return
            end
            if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK ~= AllSdkType.Sdk_None then
                self.curValue = lcl_value
                RechargeManager:buyGoods(i)
            elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
                self.curValue = lcl_value
                self:buyIOSProduct(i)
            else
                -- 充值钻石
                -- if cnt==5 and srv_userInfo.level<20 then
                --     showTips("该档位内测期间20级开启")
                --     return
                -- elseif cnt==6 and srv_userInfo.level<30 then
                --     showTips("该档位内测期间30级开启")
                --     return
                -- elseif cnt==7 and srv_userInfo.level<40 then
                --     showTips("该档位内测期间40级开启")
                --     return
                -- end
                self.curValue = lcl_value
                local msg
                if lcl_value.type==2 then
                    msg = "确定花"..lcl_value.money.."元购买月卡？"
                else
                    msg = "确定花"..lcl_value.money.."元购买"..lcl_value.diamond.."钻石？"
                end
                
                showMessageBox(msg, function()
                    startLoading()
                    local sendData = {}
                    sendData.type = lcl_value.type
                    sendData.orderIdStr = 1111111
                    sendData.isTest = 1
                    m_socket:SendRequest(json.encode(sendData), CMD_RECHARGE, self, self.onRecharge)
                end)
            end 
        end)


        --图标
        local icon = self:getGoodsIcon(lcl_value.type)
        :addTo(barbt)
        :pos(0, 50)

        --名字
        local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28, color = cc.c3b(248, 182, 45)})
        :addTo(barbt)
        :align(display.CENTER, 0,135)
        local str
        if i==2 then
            str = "月卡"
        else
            str = lcl_value.diamond.."钻石"
        end
        label:setString(str)
        setLabelStroke(label,28,cc.c3b(64, 34, 15),nil,nil,nil,nil,nil, true)

        local isFirstRecharge = false
        for i,value in ipairs(self.rechargeRecordInfo.double) do
            if value==lcl_value.type then
                isFirstRecharge = true
                break
            end
        end
        local dy = -50
        if lcl_value.type~=2 and isFirstRecharge and lcl_value.firstAward>0 then
            --送钻石
            local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "送", size = 25, color = cc.c3b(105, 57, 6)})
            :addTo(barbt)
            :pos(-68, dy)
            local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(232, 56, 40)})
            :addTo(barbt)
            :pos(-68+label1:getContentSize().width, dy)
            label2:setString(lcl_value.firstAward)
            
            local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "钻石", size = 25, color = cc.c3b(105, 57, 6)})
            :addTo(barbt)
            :pos(label2:getPositionX()+label2:getContentSize().width, dy)

            --限购
            local img = display.newSprite("recharge/recharge2_img9.png")
            :addTo(barbt)
            :pos(-90,160)
            local label = cc.ui.UILabel.new({UILabelType = 2, text = "限购\n一次", size = 22})
            :addTo(img,2)
            :align(display.CENTER,img:getContentSize().width/2, img:getContentSize().height/2)
            label:setRotation(-30)
            label:setLineHeight(20)
            local retNode = setLabelStroke(label,22,cc.c3b(19, 0, 21),1,nil,nil,nil,nil, true)
            setLabelRotation(label, retNode, -30)
            setLabelLineHeight(centerLabel, retNode, 20)
        elseif lcl_value.type==2 then
            --送钻石
            local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "送", size = 25, color = cc.c3b(105, 57, 6)})
            :addTo(barbt)
            :pos(-68, dy)
            local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "300", size = 25, color = cc.c3b(232, 56, 40)})
            :addTo(barbt)
            :pos(-68+label1:getContentSize().width, dy)
            
            local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "钻石", size = 25, color = cc.c3b(105, 57, 6)})
            :addTo(barbt)
            :pos(label2:getPositionX()+label2:getContentSize().width, dy)

            --限购
            -- local img = display.newSprite("recharge/recharge2_img9.png")
            -- :addTo(barbt)
            -- :pos(-90,160)
            -- local label = cc.ui.UILabel.new({UILabelType = 2, text = "限购\n一次", size = 22})
            -- :addTo(img,2)
            -- :align(display.CENTER,img:getContentSize().width/2, img:getContentSize().height/2)
            -- label:setRotation(-30)
            -- label:setLineHeight(20)
            -- local retNode = setLabelStroke(label,22,cc.c3b(19, 0, 21),1,nil,nil,nil,nil, true)
            -- setLabelRotation(label, retNode, -30)
            -- setLabelLineHeight(centerLabel, retNode, 20)
        else
            if lcl_value.lastAward>0 then
                --送钻石
                local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "送", size = 25, color = cc.c3b(105, 57, 6)})
                :addTo(barbt)
                :pos(-68, dy)
                local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(232, 56, 40)})
                :addTo(barbt)
                :pos(-68+label1:getContentSize().width, dy)
                label2:setString(lcl_value.lastAward)
                
                local label3 = cc.ui.UILabel.new({UILabelType = 2, text = "钻石", size = 25, color = cc.c3b(105, 57, 6)})
                :addTo(barbt)
                :pos(label2:getPositionX()+label2:getContentSize().width, dy)
            end
        end
    end

    self.goodsLv:reload()
end
function rechargeLayer:getGoodsIcon(type)
    local pIcon
    pIcon = display.newSprite("recharge/recharge2_img12.png")
    
    if type==1 then
        display.newSprite("common2/com2_Img_14.png")
        :addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)

        display.newSprite("common/common_Diamond.png")
        :addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif type==2 then
        display.newSprite("common2/com2_Img_13.png")
        :addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
        :scale(0.67)
    else
        display.newSprite("common2/com2_Img_14.png")
        :addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)

        
        display.newSprite("common2/com2_Img_"..(type+5)..".png")
        :addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
        :scale(0.67)
    end

    return pIcon
end

function rechargeLayer:initPrivilegeUI()
    local tmpSize = cc.size(462,317)

    local masklayer =  UIMasklayer.new({bAlwaysExist=true})
    :addTo(self,2)
    local function  func()
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)


    local rechargeBox = display.newSprite("SingleImg/messageBox/messageBox.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    :scale(1.2)
    masklayer:addHinder(rechargeBox)

    --关闭按钮
    cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
    :addTo(masklayer)
    :pos(display.cx+rechargeBox:getContentSize().width/2+36, display.cy+rechargeBox:getContentSize().height/2+20)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        masklayer:removeSelf()
        end)


    display.newSprite("recharge/recharge2_img8.png")
    :addTo(masklayer)
    :pos(display.cx-160, display.cy+210)


    --左箭头
    local leftjt = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(masklayer)
    :pos(100, display.cy)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1)
        end)
    :onButtonClicked(function(event)
        self:reloadPrivilegeUI(self.privilegeVip-1)
        end)


    display.newSprite("recharge/vipImg2.png")
    :addTo(masklayer)
    :pos(display.cx-270, display.cy+120)

    local title_L = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28, color = cc.c3b(255, 255, 0)})
    :addTo(masklayer)
    :pos(display.cx-230, display.cy+120)

    local content_L = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = MYFONT_COLOR})
    :addTo(masklayer)
    :align(display.TOP_LEFT, display.cx-220, display.cy+100)
    content_L:setWidth(440)
    content_L:setLineHeight(30)


    --右箭头
    local rightjt = cc.ui.UIPushButton.new("common/common_LeftArrow.png")
    :addTo(masklayer)
    :pos(display.width - 100, display.cy)
    :scale(-1)
    :onButtonPressed(function(event)
        event.target:setScale(-0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(-1)
        end)
    :onButtonClicked(function(event)
        self:reloadPrivilegeUI(self.privilegeVip+1)
        end)

    --分割线
    display.newSprite("recharge/recharge2_img13.png")
    :addTo(masklayer)
    :pos(display.cx+20, display.cy-20)


    --右侧
    local rightY = display.cx+200
    local title_R = cc.ui.UILabel.new({UILabelType = 2, text = "特 权 礼 包", size = 30, color = cc.c3b(255, 241, 0)})
    :addTo(masklayer)
    :align(display.CENTER, rightY, display.cy+120)

    --礼包
    local gift = cc.ui.UIPushButton.new("recharge/giftImg.png")
    :addTo(masklayer)
    :pos(rightY, display.cy+30)
    :onButtonPressed(function(event)
        event.target:setScale(0.98)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)

        local lclValue = vipLevelData[self.privilegeVip]
        local outputItems = lclValue.output
        outputItems = lua_string_split(outputItems,"|")

        local curRewards = {}
        table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=lclValue.gold})
        -- table.insert(curRewards, {templateID=2, num=lclValue.gold})
        -- table.insert(curRewards, {templateID=3, num=lclValue.gold})
        -- table.insert(curRewards, {templateID=4, num=lclValue.gold})
        -- table.insert(curRewards, {templateID=5, num=lclValue.gold})
        for i=1,#outputItems do
            local item = lua_string_split(outputItems[i],"#")
            table.insert(curRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
        end
        showItemListBox(curRewards)
        end)

    --礼包上，下一级vip
    display.newSprite("recharge/vipImg2.png")
    :addTo(gift)
    :pos(gift:getContentSize().width/2-10, -30)

    local nextvipNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 28, color = cc.c3b(255, 242, 85)})
    :pos(gift:getContentSize().width/2+18, -30)
    :addTo(gift)
    nextvipNum:setAnchorPoint(0,0.5)
    -- nextvipNum:initWithString("", "recharge/vipNum2.png", 24, 35, string.byte(0))

    cc.ui.UILabel.new({UILabelType = 2, text = "VIP     特权礼包", size = 25, color = MYFONT_COLOR})
    :addTo(gift)
    :pos(gift:getContentSize().width/2, -65)
    :setAnchorPoint(0.5,0.5)

    local vipNum2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(255, 255, 0)})
    :addTo(gift)
    :pos(gift:getContentSize().width/2-23, -65)
    vipNum2:setAnchorPoint(0.5,0.5)

    --原价
    cc.ui.UILabel.new({UILabelType = 2, text = "原价：", size = 25, color = cc.c3b(230, 0, 18)})
    :addTo(masklayer)
    :pos(display.cx+115,display.cy-80)

    display.newSprite("common/common_Diamond.png")
    :addTo(masklayer)
    :pos(display.cx+200,display.cy-80)
    :scale(0.8)

    local price1 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(230, 0, 18)})
    :addTo(masklayer)
    :align(display.CENTER, display.cx+260,display.cy-80)

    display.newSprite("recharge/redLine.png")
    :addTo(masklayer)
    :pos(display.cx+260,display.cy-80)

    --现价
    cc.ui.UILabel.new({UILabelType = 2, text = "折后：", size = 25, color = cc.c3b(248, 182, 45)})
    :addTo(masklayer)
    :pos(display.cx+115,display.cy-120)

    display.newSprite("common/common_Diamond.png")
    :addTo(masklayer)
    :pos(display.cx+200,display.cy-120)
    :scale(0.8)

    local price2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(248, 182, 45)})
    :addTo(masklayer)
    :align(display.CENTER, display.cx+260,display.cy-120)

    local butBt = createYellowBt("购买")
    :addTo(masklayer)
    :pos(rightY, display.cy-200)
    :onButtonClicked(function(event)
        startLoading()
        local sendData = {}
        sendData.vip = self.privilegeVip
        m_socket:SendRequest(json.encode(sendData), CMD_VIP_GIFT, self, self.ongetVipGift)
        
        end)
    self.butBt = butBt


    self.tequan = {}
    self.tequan[1] = {}
    self.tequan[2] = {}

    self.tequan[1].jt = leftjt
    self.tequan[1].title = title_L
    self.tequan[1].content = display.newNode()
    :addTo(masklayer)
    :pos(display.cx-350, display.cy-170)
    -- self.tequan[1].content = content_L
    
    self.tequan[2].jt = rightjt
    self.tequan[2].vipNum = nextvipNum
    self.tequan[2].vipNum2 = vipNum2
    self.tequan[2].price1 = price1 
    self.tequan[2].price2 = price2 
end

function rechargeLayer:reloadPrivilegeUI(vipNum)
    self.privilegeVip = vipNum

    local tmpFlag = false
    for i,value in ipairs(self.rechargeRecordInfo.vipGift) do
        if value==self.privilegeVip then
            tmpFlag = true
            break
        end
    end
    
    if tmpFlag then
        self.butBt:setButtonEnabled(false)
    else
        self.butBt:setButtonEnabled(true)
    end
    self.butBt:getButtonLabel():setPositionY(5)


    --左边
    if vipNum<=1 then
        self.tequan[1].jt:setVisible(false)
    else
        self.tequan[1].jt:setVisible(true)
    end
    self.tequan[1].title:setString(vipNum.."特权")
    -- local contentStr = ""
    -- if vipNum>1 then
    --     contentStr = contentStr.."包含VIP"..(vipNum-1).."所有特权\n"
    -- end
    -- if vipLevelData[vipNum].des~="null" then
    --     contentStr = contentStr.."解锁"..vipLevelData[vipNum].des.."功能。\n"
    -- end
    -- contentStr = contentStr..
    --     "每天可购买燃油   次。\n"..
    --     "每天可使用点金手   次。\n"..
    --     "每天可重置精英关卡   次。\n"..
    --     "每天可刷新竞技场   次。\n"..
    --     "每天可以购买特殊商店商品   次。\n"
    -- self.tequan[1].content:setString(contentStr)
    
    --更新特权内容
    self.tequan[1].content:removeAllChildren()
    local lablePos = cc.p(20, 270)
    local content = self.tequan[1].content
    local ctnIdx = 0
    local mfont = 25
    if vipNum>1 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "包含", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)

        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString("VIP"..(vipNum-1))

        cc.ui.UILabel.new({UILabelType = 2, text = "所有特权", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].mopUpCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可领取扫荡券", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].mopUpCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "个", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].energyCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可购买燃油", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].energyCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "次", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].goldCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可使用点金手", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].goldCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "次", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].blockCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可重置精英关卡", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].blockCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "次", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].pvpCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可刷新竞技场", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].pvpCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "次", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    if vipLevelData[vipNum].diaAdvCnt>0 then
        ctnIdx = ctnIdx + 1
        local label1 = cc.ui.UILabel.new({UILabelType = 2, text = "每日可用钻石强化", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
        local label2 = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mfont, color = cc.c3b(255, 241, 0)})
        :addTo(content)
        :pos(label1:getPositionX()+label1:getContentSize().width, label1:getPositionY())
        label2:setString(vipLevelData[vipNum].diaAdvCnt)

        cc.ui.UILabel.new({UILabelType = 2, text = "次", size = mfont, color = cc.c3b(237, 227, 199)})
        :addTo(content)
        :pos(label2:getPositionX()+label2:getContentSize().width, label2:getPositionY())
    end
    local vipDes = vipLevelData[vipNum].des
    if vipDes~="null" then
        local FuncDes = lua_string_split(vipDes,"#")
        for i=1,#FuncDes do
            ctnIdx = ctnIdx + 1
            cc.ui.UILabel.new({UILabelType = 2, text = "", size = mfont, color = cc.c3b(237, 227, 199)})
            :addTo(content)
            :pos(lablePos.x, lablePos.y-(ctnIdx)*35)
            :setString(FuncDes[i])
        end 
    end

    --右边
    if vipNum>=15 then
        self.tequan[2].jt:setVisible(false)
    else
        self.tequan[2].jt:setVisible(true)
    end
    self.tequan[2].vipNum:setString(vipNum)
    self.tequan[2].vipNum2:setString(vipNum)
    self.tequan[2].price1:setString(vipLevelData[vipNum].sale2)
    self.tequan[2].price2:setString(vipLevelData[vipNum].sale)
    
end
--获取充值记录
function rechargeLayer:onGetRechargeInfo(cmd)
    endLoading()
    if cmd.result==1 then
        self.rechargeRecordInfo = cmd.data
        self:reloadData()
        self:initGoodsUI()
    else
        showTips(result.msg)
    end
end
--充值
function rechargeLayer:onRecharge(cmd)
    endLoading()
    endRechargeLoading()
    if cmd.result==1 then
        showTips("充值成功！")
        flashSale_ReqConsumeNum()
        local data = cmd.data
        srv_userInfo.vip = data.vip
        srv_userInfo.diamond = data.diamond
        srv_userInfo.paidDiad = data.paidDiad
        mainscenetopbar:setDiamond()

        if MainScene_Instance then
            display.getRunningScene().vipNum:setString(srv_userInfo.vip)
        end
        if self.curTransaction ~= nil then
            Store.finishTransaction(self.curTransaction)
            self.curTransaction = nil
            table.remove(GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)],#GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)])
            GameState.save(GameData)
            self:checkIOSOrder()
            -- print("ios支付上报了")
            -- DCVirtualCurrency.paymentSuccess("空",tostring(self.curValue['type']),tonumber(self.curValue['money']),"CNY","ios支付")
        end

        if self.rechargeRecordInfo ~= nil then
            if rechargeLayer.cnt==2 then
                self.rechargeRecordInfo.validity = self.rechargeRecordInfo.validity + 30
            end
            self.rechargeRecordInfo.paidDiad = data.paidDiad
            --删除首充双倍记录
            for i,value in ipairs(self.rechargeRecordInfo.double) do
                if value==self.curValue.type then
                    table.remove(self.rechargeRecordInfo.double, i)
                    break
                end
            end
            self:reloadData()
            self:reloadGoodsUI()
        end
    elseif cmd.result==-3 then
        if self.curTransaction ~= nil then
            Store.finishTransaction(self.curTransaction)
            self.curTransaction = nil
            table.remove(GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)],#GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)])
            GameState.save(GameData)
            self:checkIOSOrder()
        end
    elseif cmd.result==(-88) then
    else
        -- if self.curTransaction ~= nil then
        --     Store.finishTransaction(self.curTransaction)
        --     self.curTransaction = nil
        --     table.remove(GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)],#GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)])
        --     GameState.save(GameData)
        --     self:checkIOSOrder()
        -- end

        showTips(cmd.msg)
    end
end
--购买vip礼包
function rechargeLayer:ongetVipGift(cmd)
    endLoading()
    if cmd.result==1 then
        table.insert(self.rechargeRecordInfo.vipGift,self.privilegeVip)

        self:reloadPrivilegeUI(self.privilegeVip)

        local lclValue = vipLevelData[self.privilegeVip]
        -- print(lclValue.sale)
        srv_userInfo.diamond = srv_userInfo.diamond - lclValue.sale
        srv_userInfo.gold = srv_userInfo.gold + lclValue.gold

        local outputItems = lclValue.output
        outputItems = lua_string_split(outputItems,"|")

        local curRewards = {}
        table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=lclValue.gold})
        
        for i=1,#outputItems do
            local item = lua_string_split(outputItems[i],"#")
            table.insert(curRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
        end
        GlobalShowGainBox(nil, curRewards)

        mainscenetopbar:setDiamond()
        mainscenetopbar:setGlod()

        --数据统计
        luaStatBuy("vip礼包", BUY_TYPE_VIP_GIFT, 1, "钻石", lclValue.sale)
    else
        showTips(cmd.msg)
    end
end

--IOS支付相关
function rechargeLayer:buyIOSProduct()
    startRechargeLoading(100)
    if Store.isProductLoaded(AllProductsID[self.cnt]) then
        Store.purchase(AllProductsID[self.cnt])
    else
        Store.loadProducts(AllProductsID, handler(self, self.loadCallback))
    end
end

---IOS载入商品的回掉
function rechargeLayer:loadCallback(products)
    -- --返回商品列表
    if products ~= nil then
        printTable(products)
        Store.purchase(AllProductsID[self.cnt])
    else
        print("products is nil")
    end
end

function rechargeLayer:getSign(order)
    local secretKey = "JLL4932*(&*343Imnm"
    print(crypto.md5(order..mUserId..srv_userInfo.characterId..secretKey))
    return crypto.md5(order..mUserId..srv_userInfo.characterId..secretKey)
end
function rechargeLayer:iosIapCallback(transaction)
    self = rechargeLayer.Instance
    self.curTransaction = transaction.transaction
    --处理购买中的事件回调，如购买成功
    if transaction.transaction.state == "purchased" then
        
        print("buy success")
        
        self:saveIOSOrder(self.curTransaction)
        local sendData = {}
        sendData["transaction"] = self.curTransaction
        sendData["verify"] = self:getSign(self.curTransaction.transactionIdentifier)
        sendData["chnlId"] = gType_Chnl
        sendData["dy_gameId"] =  g_gameId_dataEye
        sendData["isSandbox"] = g_IsSandbox
        m_socket:SendRequest(json.encode(sendData), CMD_RECHARGE, self, self.onRecharge)
    else
        endRechargeLoading()
        print("buy failed")
        

        if self.cnt then
            local sendData = {}
            sendData["transaction"] = self.curTransaction
            sendData["verify"] = self:getSign(self.curTransaction.transactionIdentifier)
            sendData["chnlId"] = gType_Chnl
            sendData["dy_gameId"] =  g_gameId_dataEye
            sendData["isSandbox"] = g_IsSandbox
            m_socket:SendRequest(json.encode(sendData), CMD_RECHARGE, self, self.onRecharge)

            showTips("购买失败")
        end
        
    end
end

function rechargeLayer:saveIOSOrder(transaction)
    if GameData.IOSOrder == nil then
        GameData.IOSOrder = {}
        GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)] = {}
    end
    if GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)] == nil then
        GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)] = {}
    end
    table.insert(GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)],#GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)] + 1, transaction)
    GameState.save(GameData)
end

function rechargeLayer:checkIOSOrder()
    self = rechargeLayer.Instance
    if GameData.IOSOrder == nil then
        return
    end
    if GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)] == nil then
        return
    end
    local lastOrderNum = #GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)]
    if lastOrderNum > 0 then
        print("检测到未完成IOS订单")
        print("mUserId:"..mUserId)
        printTable(GameData.IOSOrder)
        printTable(GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)][lastOrderNum])
        local sendData = {}
        sendData["transaction"] = GameData.IOSOrder[tostring(mUserId..loginServerList.serverId)][lastOrderNum]
        sendData["verify"] = self:getSign(sendData["transaction"].transactionIdentifier)
        sendData["chnlId"] = gType_Chnl
        sendData["dy_gameId"] =  g_gameId_dataEye
        sendData["isSandbox"] = g_IsSandbox
        m_socket:SendRequest(json.encode(sendData), CMD_RECHARGE, self, self.onRecharge)
    end
end

return rechargeLayer