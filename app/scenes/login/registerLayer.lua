-- @Author: anchen
-- @Date:   2015-12-22 18:30:15
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-01-06 15:48:53
local registerLayer = class("registerLayer", function()
    return display.newLayer()
end)

function registerLayer:ctor()
    local regPanel = display.newSprite("SingleImg/login/loginImg20.png")
    :addTo(self, 0 ,100)
    :pos(display.cx, display.cy)
    local tmpsize = regPanel:getContentSize()

    local title = display.newSprite("SingleImg/login/loginImg11.png")
    :addTo(regPanel)
    :pos(tmpsize.width/2, tmpsize.height-70)

    --返回按钮
    local backBt = cc.ui.UIPushButton.new("SingleImg/login/loginImg3.png")
    :addTo(regPanel, 0 ,100)
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

    local reg_userName = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(550, 70)})
    :addTo(regPanel, 0 ,101)
    :pos(370,770*display.width/1920)
    reg_userName:setPlaceHolder("账号")
    reg_userName:setMaxLength(16)
    reg_userName:setFontColor(display.COLOR_BLACK)


    local reg_password = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(550, 70)})
    :addTo(regPanel, 0 ,102)
    :pos(370,635*display.width/1920)
    reg_password:setPlaceHolder("密码")
    reg_password:setMaxLength(16)
    reg_password:setInputFlag(0)
    reg_password:setFontColor(display.COLOR_BLACK)

    local reg_ConfirmPwd = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(550, 70)})
    :addTo(regPanel, 0 ,103)
    :pos(370,500*display.width/1920)
    reg_ConfirmPwd:setPlaceHolder("确认密码")
    reg_ConfirmPwd:setMaxLength(16)
    reg_ConfirmPwd:setInputFlag(0)
    reg_ConfirmPwd:setFontColor(display.COLOR_BLACK)

    regErrorLabel=cc.ui.UILabel.new({
        UILabelType = 2, text = "", size = 40, color = display.COLOR_RED})
        :align(display.CENTER, tmpsize.width/2,50)
        :addTo(regPanel, 0 ,106)



    --提交按钮
    local commitBt = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg5.png",
        pressed = "SingleImg/login/loginImg10.png"
        })
    :addTo(regPanel, 0 ,104)
    :pos(tmpsize.width/2, tmpsize.height/2-136)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "提 交", size = 35}))

    --忘记密码
    local QQMsg = cc.ui.UIPushButton.new({
        normal = "SingleImg/login/loginImg4.png",
        pressed = "SingleImg/login/loginImg4.png"
        })
    :addTo(regPanel, 0 ,105)
    :pos(tmpsize.width/2+256, tmpsize.height/2-292)
end


return registerLayer