-- @Author: anchen
-- @Date:   2015-12-23 11:58:11
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-03-14 19:39:10
local selectRoleLayer = class("selectRoleLayer", function()
    return display.newLayer()
end)

function selectRoleLayer:ctor()
    display.newLayer()--display.newColorLayer(cc.c4f(0, 0, 0, 200))
    :addTo(self)

    local rolePanel = display.newSprite("SingleImg/login/loginImg29.png")
    :addTo(self, 0, 1000)
    :pos(display.cx, display.cy)

    local tmpsize = rolePanel:getContentSize()

    local topBar1 = display.newSprite("SingleImg/login/loginImg44.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2, tmpsize.height-32)
    
    local topBar2 = display.newSprite("SingleImg/login/loginImg43.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2, tmpsize.height-32)
    topBar2:setVisible(false)

    local leftBar = display.newSprite("SingleImg/login/loginImg45.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2-482, tmpsize.height/2)

    local rightBar = display.newSprite("SingleImg/login/loginImg46.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2+482, tmpsize.height/2)
    rightBar:setVisible(false)

    local cicle1 = display.newSprite("SingleImg/login/loginImg38.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2-502, tmpsize.height/2+10)

    local cicle2 = display.newSprite("SingleImg/login/loginImg38.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2+502, tmpsize.height/2+10)

    
    --选择男性
    local femaleBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg41.png",
        disabled = "SingleImg/login/loginImg42.png"
        })
    :addTo(rolePanel,0 ,11)
    :pos(tmpsize.width/2-502, tmpsize.height/2+10)
    :onButtonClicked(function(event)
        topBar1:setVisible(true)
        topBar2:setVisible(false)
        leftBar:setVisible(true)
        rightBar:setVisible(false)
        cicle1:runAction(cc.RotateBy:create(0.5, 180))
        end)

    --选择女性
    local femaleBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg39.png",
        disabled = "SingleImg/login/loginImg40.png"
        })
    :addTo(rolePanel,0 ,10)
    :pos(tmpsize.width/2+502, tmpsize.height/2+10)
    :onButtonClicked(function(event)
        topBar1:setVisible(false)
        topBar2:setVisible(true)
        leftBar:setVisible(false)
        rightBar:setVisible(true)
        cicle2:runAction(cc.RotateBy:create(0.5, 180))
        end)


    --简介框
    local msgBox = display.newSprite("SingleImg/login/loginImg50.png")
    :addTo(rolePanel,0 ,12)
    :pos(tmpsize.width/2-20, tmpsize.height/2+72)

    -- cc.ui.UILabel.new({UILabelType = 2, text = "人物介绍", size = 25, color =cc.c3b(255, 244, 92)})
    -- :addTo(msgBox)
    -- :pos(10,msgBox:getContentSize().height-35)

    --筛子
    cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg48.png",
        pressed = "SingleImg/login/loginImg49.png",
        })
    :addTo(rolePanel,0 ,13)
    :pos(tmpsize.width/2+140, 65)
    :scale(1.5)

    cc.ui.UILabel.new({UILabelType = 2, text = "输入昵称：", size = 30, color = cc.c3b(123, 166, 198)})
    :addTo(rolePanel)
    :pos(tmpsize.width/2-340, 65)

    display.newSprite("SingleImg/login/loginImg47.png")
    :addTo(rolePanel)
    :pos(tmpsize.width/2-50, 65)

end

return selectRoleLayer