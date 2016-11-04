-- @Author: anchen
-- @Date:   2015-12-23 10:17:42
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-01-04 14:58:30
local enterGameLayer = class("enterGameLayer", function()
    return display.newLayer()
end)

function enterGameLayer:ctor()
    --进入游戏按钮
    local startGameBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg22.png",
        pressed = "SingleImg/login/loginImg23.png",
        })
    :addTo(self, 0, 100)
    :pos(display.cx, display.cy-274)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "登录游戏", size = 35, color = cc.c3b(0, 255, 255)}))
    :onButtonPressed(function(event) event.target:getButtonLabel():setPositionY(5) end)
    :onButtonRelease(function(event) event.target:getButtonLabel():setPositionY(5) end)
    startGameBt:getButtonLabel(normal):setPositionY(5)


    --选区条
    local selectBar = display.newSprite("SingleImg/login/loginImg26.png")
    :addTo(self, 0, 101)
    :pos(display.cx, display.cy-170)

    local selectBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg24.png",
        pressed = "SingleImg/login/loginImg25.png",
        })
    :addTo(selectBar, 0, 10)
    :pos(selectBar:getContentSize().width/2+172, selectBar:getContentSize().height/2)
    :onButtonClicked(function(event)
        if self.serverListPanel:isVisible() then
            self.serverListPanel:setVisible(false)
        else
            self.serverListPanel:setVisible(true)
        end
        end)
    display.newSprite("SingleImg/login/loginImg37.png")
    :addTo(selectBt)
    :pos(-50,0)
    cc.ui.UILabel.new({UILabelType = 2, text = "点击换区", size = 25, color = cc.c3b(94, 229, 101)})
    :addTo(selectBt)
    :pos(-30,0)

    --服务器列表
    self.serverListPanel = display.newSprite("SingleImg/login/loginImg27.png")
    :addTo(self, 0, 103)
    :pos(display.cx, display.cy+110)
    self.serverListPanel:setVisible(false)
    local tempsize = self.serverListPanel:getContentSize()

    display.newSprite("SingleImg/login/loginImg28.png")
    :addTo(self.serverListPanel)
    :pos(tempsize.width/2-311, tempsize.height/2+198)

    --服务器状态
    local tab = {
    {pos=cc.p(tempsize.width/2-200,26), img = "SingleImg/login/server_state1.png", name = "正常", color = cc.c3b(87, 255, 7)},
    {pos=cc.p(tempsize.width/2-68,26), img = "SingleImg/login/server_state2.png", name = "拥挤", color = cc.c3b(255, 238, 31)},
    {pos=cc.p(tempsize.width/2+68,26), img = "SingleImg/login/server_state3.png", name = "火爆", color = cc.c3b(255, 0, 0)},
    {pos=cc.p(tempsize.width/2+200,26), img = "SingleImg/login/server_state4.png", name = "维护", color = cc.c3b(202, 202, 202)},
}
    for i=1,4 do
        display.newSprite(tab[i].img)
        :addTo(self.serverListPanel)
        :pos(tab[i].pos.x, tab[i].pos.y)

        cc.ui.UILabel.new({UILabelType = 2, text = tab[i].name, size = 25, color = tab[i].color})
        :addTo(self.serverListPanel)
        :pos(tab[i].pos.x+20, tab[i].pos.y)
    end
    
    -- local webview = ccexp.WebView:create()
    --     self:addChild(webview, 100)
    --     webview:setVisible(true)
    --     webview:setScalesPageToFit(true)
    --     webview:loadURL("http://119.29.72.22:8080/userver/game/notice")
    --     webview:setContentSize(cc.size(500,300)) -- 一定要设置大小才能显示
    --     webview:reload()
    --     webview:setPosition(display.cx,display.cy)
end

return enterGameLayer 