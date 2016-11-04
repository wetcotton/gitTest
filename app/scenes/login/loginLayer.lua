-- @Author: anchen
-- @Date:   2015-12-22 18:20:27
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-01-06 15:47:22
local loginLayer = class("loginLayer", function()
    return display.newLayer()
end)

function loginLayer:ctor()
    local loginPanel = display.newSprite("SingleImg/login/loginImg2.png")
    :addTo(self, 0 ,100)
    :pos(display.cx, display.cy)
    local tmpsize = loginPanel:getContentSize()

    local title = display.newSprite("SingleImg/login/loginImg11.png")
    :addTo(loginPanel, 0 ,10)
    :pos(tmpsize.width/2, tmpsize.height-70)

    --返回按钮
    local backBt = cc.ui.UIPushButton.new("SingleImg/login/loginImg3.png")
    :addTo(loginPanel, 0 ,11)
    :pos(tmpsize.width/2-290, tmpsize.height/2+300)

    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            local text,_ = string.gsub(editbox:getText(), " ", "")
            editbox:setText(text)
            -- 输入结束
        elseif event == "return" then
            -- 从输入框返回
        end
    end

    local loginUserName = cc.ui.UIInput.new({image = "EditBoxBg.png",listener = onEdit,size = cc.size(550, 70)})
    :addTo(loginPanel, 0 ,12)
    :pos(370,515)
    loginUserName:setPlaceHolder("账号")
    loginUserName:setMaxLength(16)
    loginUserName:setFontColor(display.COLOR_BLACK)


    local loginPassword = cc.ui.UIInput.new({image = "EditBoxBg.png",listener = onEdit,size = cc.size(550, 70)})
    :addTo(loginPanel, 0 ,13)
    :pos(370,425)
    loginPassword:setPlaceHolder("密码")
    loginPassword:setMaxLength(16)
    loginPassword:setInputFlag(0)
    loginPassword:setFontColor(display.COLOR_BLACK)



    loginErrorLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 40, color = display.COLOR_RED})
    :addTo(loginPanel, 0 ,14)
    :align(display.CENTER, tmpsize.width/2, 50)


    --提交按钮
    local commitBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg5.png",
        pressed = "SingleImg/login/loginImg10.png"
        })
    :addTo(loginPanel, 0 ,15)
    :pos(tmpsize.width/2, tmpsize.height/2-45)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "提 交", size = 35}))

    --忘记密码
    local QQMsg = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg4.png",
        pressed = "SingleImg/login/loginImg4.png"
        })
    :addTo(loginPanel, 0 ,16)
    :pos(tmpsize.width/2+256, tmpsize.height/2-292)
end


return loginLayer