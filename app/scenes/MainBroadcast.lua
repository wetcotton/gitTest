-- @Author: anchen
-- @Date:   2015-08-20 15:58:34
-- @Last Modified by:   anchen
-- @Last Modified time: 2015-12-13 21:02:52

broadcast = class("broadcast", function()
    local layer =  display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)

local broadcastBar1
local bcImg
local broadcastBar
local broadcastWord = nil

local handle, handle2 = nil, nil

local finishOneWord = true --一条消息是否播完
broadcast.Instance = nil
function broadcast:ctor()
    finishOneWord = true
    --调节广播上下位置
    local Dy = 15
    
    broadcastBar1 = display.newSprite("#MainUI_img37.png")
        :addTo(self)
        :pos(display.cx+0,display.height - 210 + Dy)
    broadcastBar1:setVisible(false)
    broadcastBar1:runAction(cc.FadeOut:create(2.0))

    -- local bcImg = display.newSprite("common/common_broadCast.png")
    -- :addTo(broadcastBar1)
    -- :pos(25,broadcastBar1:getContentSize().height/2)
    -- bcImg:setVisible(false)
    -- bcImg:runAction(cc.FadeOut:create(2.0))
    local width = 550
    local pox = display.cx+10
    local cliRect = display.newClippingRectangleNode(cc.rect(
        pox - width/2-10,
        -- 0,
        display.height - 222 + Dy,width,37))
    :addTo(self)

    broadcastBar = display.newScale9Sprite("#MainUI_img37.png",nil, nil, cc.size(width,37))
        :addTo(cliRect)
        :pos(pox ,display.height - 210 + Dy)
    -- broadcastBar:setVisible(false)
    -- broadcastBar:runAction(cc.FadeOut:create(2.0))
    broadcastBar:setOpacity(0)

    

    broadcastWord = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = cc.c3b(255, 255, 0)})
    :addTo(broadcastBar)
    broadcastWord:pos(broadcastBar:getContentSize().width, broadcastBar:getContentSize().height/2)
    broadcastWord:setVisible(false)

    

end
function broadcast:onEnter()
    broadcast.Instance = self
end
function broadcast:onExit()
    broadcast.Instance = nil
    if handle then
        scheduler.unscheduleGlobal(handle)
        handle = nil
    end
    if handle2 then
        scheduler.unscheduleGlobal(handle2)
        handle2 = nil
    end
end

function broadcast:seqAction1(notes)
    local seq = cc.Sequence:create(
            cc.CallFunc:create(function()
                if notes then
                    notes:setVisible(true)
                end
                end), 
            cc.FadeIn:create(2.0))
        notes:runAction(seq)
    return true
end
function broadcast:seqAction2(notes)
    local seq = cc.Sequence:create(cc.FadeOut:create(2.0), 
                cc.CallFunc:create(function()
                    if finishOneWord then --如果在广播过程中就不需要消失
                        if notes then
                            notes:setVisible(false)
                        end
                    end
                end))
        notes:runAction(seq)
end

function broadcast:onBroadCast()
    if not broadcastBar1 then
        print("aaaaaa")
        return
    end
    -- if broadcastBar1:isVisible() then
    --     print("bbbbb")
    -- else
    --     print("ccc")
    --     self:seqAction1(broadcastBar1)
    --     -- self:seqAction1(bcImg)
    -- end
    
    handle, handle2 = nil, nil
    function onInterval()
        if MainScene_Instance==nil then
            if handle then
                scheduler.unscheduleGlobal(handle)
                handle = nil
            end
        elseif finishOneWord then
            finishOneWord = false
            if g_BroadCastMsg and #g_BroadCastMsg>0 then
                -- print("ddddd")
                -- printTable(g_BroadCastMsg)z
                -- g_BroadCastMsg[1].finish = true
                -- print("--------")
                -- printTable(g_BroadCastMsg[1])
                if broadcastWord then
                    self:seqAction1(broadcastBar1)
                    broadcastWord:setVisible(true)

                    broadcastWord:setString(g_BroadCastMsg[1])
                    local moveAct = cc.MoveTo:create(7+broadcastWord:getContentSize().width*0.01, 
                        cc.p(-broadcastWord:getContentSize().width, 
                            broadcastBar:getContentSize().height/2))
                    local funcAct2 = cc.CallFunc:create(function()
                        broadcastWord:setPositionX(broadcastBar:getContentSize().width)
                        -- scheduler.unscheduleGlobal(handle)
                        -- print("移动完成")
                        table.remove(g_BroadCastMsg, 1)
                        finishOneWord = true
                        end)
                    local seqAct = cc.Sequence:create(moveAct, funcAct2)
                    broadcastWord:runAction(seqAct)
                end
            else
                -- print("eee")
                finishOneWord = true
                -- broadcastBar1:setVisible(true)
                -- broadcastWord:setVisible(false)
            end
        end
        
    end

    local delayT = 0
    function onInterval2()
        if MainScene_Instance==nil then
            if handle2 then
                scheduler.unscheduleGlobal(handle2)
                handle2 = nil
            end
            return
        end
        if finishOneWord then
            if g_BroadCastMsg and #g_BroadCastMsg==0 then
                -- print("一秒")
                delayT = delayT + 1
            else
                -- print("广播中")
                delayT = 0
            end
            if delayT>=2 then
                -- print("隐藏广播条")
                self:seqAction2(broadcastBar1)
                
                -- scheduler.unscheduleGlobal(handle2)
                -- handle2=nil
            end
        end
        
    end

    --监听,如果上一条广播播完了，再播放下一条
    handle = scheduler.scheduleGlobal(onInterval, 1)
    --监听，如果广播播完后两秒没有新的广播，隐藏广播条
    if handle2==nil then
        handle2 = scheduler.scheduleGlobal(onInterval2,1)
    end
end
    

return broadcast