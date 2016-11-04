--
-- Author: liufei
-- Date: 2015-01-08 15:57:49
--
local PvpRuleLayer = class("PvpRuleLayer", function()
	return  display.newLayer() --display.newColorLayer(cc.c4b(0,0,0,200))
end)

function  PvpRuleLayer:ctor()
	--返回按钮
    -- cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png",pressed="common/common_BackBtn_2.png"})
    -- :align(display.LEFT_TOP, display.width*0.03, display.height*0.98)
    -- :addTo(self)
    -- :onButtonClicked(function(event)
    --     self:removeSelf()
    -- end)
    local tmpSize = cc.size(843, 555)
    local ruleBg = display.newSprite("SingleImg/worldBoss/bossFrame_03.png")
                    :addTo(self)
                    :pos(display.cx,display.cy-30)

    display.newTTFLabel{text = "规则说明",size = 40,color = cc.c3b(95,255,250)}
        :align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
        :addTo(ruleBg)
    
    -- self:setTouchEnabled(true)
    -- self:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
    --     if event.name == "began" then
    --       if cc.rectContainsPoint(cc.rect(ruleBg:getPositionX() - ruleBg:getContentSize().width/2,ruleBg:getPositionY() - ruleBg:getContentSize().height/2,ruleBg:getContentSize().width,ruleBg:getContentSize().height), cc.p(event.x, event.y)) == false then
    --            self:removeSelf()
    --       end
    --       return true
    --     end
    -- end)

    local ruleBgSize = ruleBg:getContentSize()

    --关闭按钮
    cc.ui.UIPushButton.new({
        normal = "common2/com2_Btn_2_down.png",
        pressed = "common2/com2_Btn_2_up.png"
        })
    :addTo(ruleBg)
    :pos(ruleBgSize.width+20, ruleBgSize.height-40)
    :onButtonPressed(function(event) event.target:setScale(0.98) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        self:removeSelf()
        end)

    
    -- display.newSprite("common/common_Frame5.png")
    -- :pos(ruleBgSize.width/2, ruleBgSize.height)
    -- :addTo(ruleBg)
    -- display.newSprite("#guize-01.png")
    -- :pos(ruleBgSize.width/2, ruleBgSize.height)
    -- :addTo(ruleBg)

    local  scrollLayer = display.newNode()
    :pos(80,-ruleBgSize.height*1.12)
    -- scrollLayer:setContentSize(cc.size(ruleBgSize.width, ruleBgSize.height*2))
    local  scrollSize = cc.size(ruleBgSize.width, ruleBgSize.height*2)

    cc.ui.UILabel.new({UILabelType = 2, text = "您当前排名是第        名，今日可领取奖励为：", size = scrollSize.height*0.025})
    :addTo(scrollLayer)
    :pos(0, scrollSize.height*0.96-10)

    --我的排名
    cc.ui.UILabel.new({UILabelType = 2, text = PVPData["myOrder"], size = scrollSize.height*0.025, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
    :align(display.CENTER, scrollSize.width*0.28-10, scrollSize.height*0.96-10)
    :addTo(scrollLayer)

    --奖励物品
    local rewardData = {}
    for i,value in pairs(PVPRewardData) do
        if PVPData["myOrder"]<=10 and PVPData["myOrder"]==value.sorder and PVPData["myOrder"]==value.eorder then
            rewardData = value
            break
        else
            if PVPData["myOrder"]>value.sorder and PVPData["myOrder"]<=value.eorder then
                rewardData = value
                break
            end
        end
    end
    local rewardIcon = GlobalGetSpecialItemIcon(1, rewardData.gold)
    :pos(scrollSize.width*0.13, scrollSize.height*0.85+30)
    :addTo(scrollLayer)
    local rewardIcon = GlobalGetSpecialItemIcon(2, rewardData.diamond)
    :pos(scrollSize.width*0.13+120, scrollSize.height*0.85+30)
    :addTo(scrollLayer)
    local rewardIcon = GlobalGetSpecialItemIcon(5, rewardData.reputation)
    :pos(scrollSize.width*0.13+240, scrollSize.height*0.85+30)
    :addTo(scrollLayer)

    --历史最高排名
    cc.ui.UILabel.new({UILabelType = 2, text = "历史最高排名：", size = scrollSize.height*0.025, color = cc.c3b(225, 255, 0)})
    :addTo(scrollLayer)
    :pos(0, scrollSize.height*0.85-80)

    cc.ui.UILabel.new({UILabelType = 2, text = PVPData.maxorder, size = 30, color = MYFONT_COLOR})
    :pos(scrollSize.width*0.13+70, scrollSize.height*0.85-80)
    :addTo(scrollLayer)

    --竞技场规则
    cc.ui.UILabel.new({UILabelType = 2, text = "竞技场规则：", size = scrollSize.height*0.025, color = cc.c3b(225, 255, 0)})
    :addTo(scrollLayer)
    :pos(0, scrollSize.height*0.85-140)

    local label = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 23})
    :addTo(scrollLayer)
    :pos(0, scrollSize.height*0.85-160)
    label:setAnchorPoint(0,1)
    label:setWidth(scrollSize.width-100)
    label:setLineHeight(28)
    local text =  "1.  每晚9点整结算最终排名，通过邮箱发送排名奖励\n"
    text = text.."2.  挑战成功且守方排名高于进攻方，则双方排名对调\n"
    text = text.."3.  竞技场中战斗自动进行，玩家不能手动释放技能\n"
    text = text.."4.  竞技场中无法使用特种弹与租车\n"
    text = text.."5.  战斗超时则进攻方失败\n"
    text = text.."6.  每天每名玩家初始挑战次数为5次，每天24点重置次数\n"
    text = text.."7.  当一名玩家同时被多人挑战时，根据结果顺序时间计算排名\n"
    text = text.."8.  当玩家达到自己的历史最高排名时，通过邮箱发放一定钻石奖励，奖励与进步幅度有关\n"
    text = text.."9.  对战双方的战斗属性取实时最新值\n"
    text = text.."10.  防守方的战斗力显示需重新设定保存防守阵型后才会刷新\n"
    label:setString(text)


    cc.ui.UILabel.new({UILabelType = 2, text = "每日排名奖励规则：", size = scrollSize.height*0.025, color = cc.c3b(225, 255, 0)})
    :addTo(scrollLayer)
    :pos(0, scrollSize.height*0.85-520)
    --一到五名奖励显示

    local dx = 120
    local dy = 100
    for i=1,5 do
        cc.ui.UILabel.new({UILabelType = 2, text = "第"..i.."名：", size = scrollSize.height*0.025, color = cc.c3b(225, 255, 0)})
        :pos(0, scrollSize.height*0.3+30-dy*(i-1))
        :addTo(scrollLayer)

        local rewardData = PVPRewardData[i]

        local rewardIcon = GlobalGetSpecialItemIcon(1, rewardData.gold, 0.8)
        :pos(scrollSize.width*0.13+50, scrollSize.height*0.3+30-dy*(i-1))
        :addTo(scrollLayer)
        local rewardIcon = GlobalGetSpecialItemIcon(2, rewardData.diamond, 0.8)
        :pos(scrollSize.width*0.13+dx+50, scrollSize.height*0.3+30-dy*(i-1))
        :addTo(scrollLayer)
        local rewardIcon = GlobalGetSpecialItemIcon(5, rewardData.reputation, 0.8)
        :pos(scrollSize.width*0.13+dx*2+50, scrollSize.height*0.3+30-dy*(i-1))
        :addTo(scrollLayer)
    end

    cc.ui.UILabel.new({UILabelType = 2, text = "。。。", size = scrollSize.height*0.025, color = cc.c3b(225, 255, 0)})
        :pos(0, scrollSize.height*0.3+30-dy*(6-1))
        :addTo(scrollLayer)


    -- display.newSprite("#guize-02.png")
    -- :pos(scrollSize.width*0.4, scrollSize.height*0.5)
    -- :addTo(scrollLayer)
    cc.ui.UIScrollView.new({viewRect = cc.rect(80,50,ruleBgSize.width*0.9,ruleBgSize.height*0.78-20)})
    :addScrollNode(scrollLayer)
    :setDirection(cc.ui.UIScrollView.DIRECTION_VERTICAL)
    :addTo(ruleBg)

end

return PvpRuleLayer