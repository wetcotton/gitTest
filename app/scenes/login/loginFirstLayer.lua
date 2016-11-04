-- @Author: anchen
-- @Date:   2015-12-17 11:31:32
-- @Last Modified by:   anchen
-- @Last Modified time: 2015-12-23 17:59:16
local ComboxList = require("app.scenes.myComboxList")

local loginFirstLayer = class("loginFirstLayer", function()
    return display.newLayer()
end)

function loginFirstLayer:ctor()
    local firstPanel = display.newSprite("SingleImg/login/loginImg1.png")
    :addTo(self, 0, 100)
    :pos(display.cx, display.cy)
    local tmpsize = firstPanel:getContentSize()

    local title = display.newSprite("SingleImg/login/loginImg11.png")
    :addTo(firstPanel)
    :pos(tmpsize.width/2, tmpsize.height-70)

    local nameBt = cc.ui.UIPushButton.new("SingleImg/login/loginImg18.png")
    :addTo(firstPanel, 0, 100)
    :pos(tmpsize.width/2, tmpsize.height-165)
    :onButtonClicked(function(event)
        -- print("点击到")
        end)

    display.newSprite("SingleImg/login/head.png")
    :addTo(nameBt)
    :pos(-250, 0)

    display.newSprite("SingleImg/login/loginImg19.png")
    :addTo(nameBt, 0, 10)
    :pos(250, 0)

    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = display.COLOR_BLACK})
    :addTo(nameBt, 0, 11)
    :pos(-208, 0)


    --登录按钮
    local LoginBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg5.png",
        pressed = "SingleImg/login/loginImg10.png"
        })
    :addTo(firstPanel, 0, 101)
    :pos(tmpsize.width/2, tmpsize.height/2+39)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "登 录", size = 35}))

    --注册按钮
    local regBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg6.png",
        pressed = "SingleImg/login/loginImg9.png"
        })
    :addTo(firstPanel, 0, 102)
    :pos(tmpsize.width/2, tmpsize.height/2-74)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "注 册", size = 35}))

    --快速注册按钮
    local FastLoginBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg7.png",
        pressed = "SingleImg/login/loginImg8.png"
        })
    :addTo(firstPanel, 0, 103)
    :pos(tmpsize.width/2, tmpsize.height/2-187)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "游客模式", size = 35}))

    --微信登录
    local microMsg = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg13.png",
        pressed = "SingleImg/login/loginImg12.png"
        })
    :addTo(firstPanel, 0, 104)
    :pos(tmpsize.width/2-191, tmpsize.height/2-292)

    display.newSprite("SingleImg/login/loginImg14.png")
    :addTo(microMsg)
    :pos(-85,0)

    display.newSprite("SingleImg/login/loginImg16.png")
    :addTo(microMsg)
    :pos(27,0)

    --QQ登录
    local QQMsg = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg13.png",
        pressed = "SingleImg/login/loginImg12.png"
        })
    :addTo(firstPanel, 0, 105)
    :pos(tmpsize.width/2+68, tmpsize.height/2-292)

    display.newSprite("SingleImg/login/loginImg15.png")
    :addTo(QQMsg)
    :pos(-85,0)

    display.newSprite("SingleImg/login/loginImg17.png")
    :addTo(QQMsg)
    :pos(27,0)

    --忘记密码
    local QQMsg = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg4.png",
        pressed = "SingleImg/login/loginImg4.png"
        })
    :addTo(firstPanel, 0, 106)
    :pos(tmpsize.width/2+256, tmpsize.height/2-292)
end

return loginFirstLayer