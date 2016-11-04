
local LegionManage_settting=class("LegionManage_settting", function()
    return display.newNode()
    end)

local limitWord = {
	"需要验证才可加入",
	"直接加入"
}
local limitIdx
local limitLevel
local limitWordLabel
local limitLevelLabel

function LegionManage_settting:ctor()
	limitIdx = mLegionData.army.autoJoin + 1
	limitLevel = mLegionData.army.minMemLevel
	--军团图标
	local IconLabel = cc.ui.UILabel.new({UILabelType = 2, text = "军团徽章：", size = 25})
    :addTo(self)
    :align(display.CENTER_LEFT, 200, 410)
    IconLabel:setColor(cc.c3b(151, 190, 204))
    local path = "SingleImg/legion/legionIcon/Legion_"..mLegionData.army.icon..".png"
    self.legionIcon = display.newSprite(path)
    :addTo(self,0,mLegionData.army.icon)
    :align(display.CENTER_LEFT, IconLabel:getPositionX()+IconLabel:getContentSize().width+15,
    	IconLabel:getPositionY())
    

    local modify = cc.ui.UIPushButton.new({normal = "#legion_img8.png"},{scale9 = true})
    :addTo(self)
    :pos(self.legionIcon:getPositionX()+self.legionIcon:getContentSize().width+80,
        IconLabel:getPositionY())
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        -- legionIconLayer.new(self:getParent():getParent():getParent(),2)
        end)
    modify:setButtonSize(100, 40)

    cc.ui.UILabel.new({UILabelType = 2, text = "修改", size = 25, color = cc.c3b(229, 241, 215)})
    :addTo(modify)
    :align(display.CENTER, 0 , -2)
    -- :pos()
    ---------------------
    --申请限制
    local limitLabel = cc.ui.UILabel.new({UILabelType = 2, text = "申请限制：", size = 25})
    :addTo(self)
    :align(display.CENTER_LEFT, 200, 340)
    limitLabel:setColor(cc.c3b(151, 190, 204))
    --验证方式
    function changeLimitWord(nd)
    	if nd==1 then
    		limitIdx = limitIdx + 1
    		if limitIdx>2 then
	    		limitIdx = 1
	    	end
    	elseif nd==-1 then
    		limitIdx = limitIdx - 1
    		if limitIdx<1 then
	    		limitIdx = #limitWord
	    	end
    	end
    	limitWordLabel:setString(limitWord[limitIdx])
    end

    local bar = display.newScale9Sprite("#legion_img8.png",
        limitLabel:getPositionX()+limitLabel:getContentSize().width+128, limitLabel:getPositionY(),
		cc.size(260, 34),cc.rect(10,10,31,40))
	:addTo(self)
	--限制方式Label
	limitWordLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = cc.c3b(229, 241, 215)})
	:addTo(bar)
	:pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
	limitWordLabel:setAnchorPoint(0.5,0.5)
	limitWordLabel:setString(limitWord[limitIdx])

    left1 = cc.ui.UIPushButton.new("#legion_img16.png")
    :addTo(bar)
    :align(display.CENTER, 15, bar:getContentSize().height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        changeLimitWord(-1)
        end)
    left1:setRotation(90)

	right1 = cc.ui.UIPushButton.new("#legion_img16.png")
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width-15, bar:getContentSize().height/2)
    :onButtonPressed(function(event)
    	event.target:setScaleX(-0.95)
    	event.target:setScaleY(0.95)
    	end)
    :onButtonRelease(function(event)
    	event.target:setScaleX(-1.0)
    	event.target:setScaleY(1)
    	end)
    :onButtonClicked(function(event)
    	changeLimitWord(1)
    	end)
    right1:setScaleX(-1)
    right1:setRotation(-90)
    ---------------------

    local limitLabel = cc.ui.UILabel.new({UILabelType = 2, text = "最小等级限制：", size = 25})
    :addTo(self)
    :align(display.CENTER_LEFT, 200, 280)
    limitLabel:setColor(cc.c3b(151, 190, 204))
    --等级限制
    
    local bar = display.newScale9Sprite("#legion_img8.png",
        limitLabel:getPositionX()+limitLabel:getContentSize().width+100, limitLabel:getPositionY(),
        cc.size(130, 34),cc.rect(10,10,31,40))
	:addTo(self)
	limitLevelLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25, color = cc.c3b(229, 241, 215)})
	:addTo(bar)
	:pos(bar:getContentSize().width/2,bar:getContentSize().height/2-2)
	limitLevelLabel:setAnchorPoint(0.5,0.5)

    left = cc.ui.UIPushButton.new({normal = "#legion_img16.png"},{grayState = true})
    :addTo(bar)
    :align(display.CENTER, 15, bar:getContentSize().height/2)
    :onButtonPressed(function(event)
        event.target:setScale(0.95)
        end)
    :onButtonRelease(function(event)
        event.target:setScale(1.0)
        end)
    :onButtonClicked(function(event)
        limitLevelFunc(-1)
        end)
    left:setRotation(90)

	right = cc.ui.UIPushButton.new({normal = "#legion_img16.png"},{grayState = true})
    :addTo(bar)
    :align(display.CENTER, bar:getContentSize().width - 15, bar:getContentSize().height/2)
    :onButtonPressed(function(event)
    	event.target:setScaleX(-0.95)
    	event.target:setScaleY(0.95)
    	end)
    :onButtonRelease(function(event)
    	event.target:setScaleX(-1.0)
    	event.target:setScaleY(1)
    	end)
    :onButtonClicked(function(event)
    	limitLevelFunc(1)
    	end)
    right:setScaleX(-1)
    right:setRotation(-90)

    function limitLevelFunc(flag)
    	if flag==1 then
    		limitLevel = limitLevel + 1
    	elseif flag==-1 then
    		limitLevel = limitLevel - 1
    	else
    	end
    	limitLevelLabel:setString(limitLevel)
    	if limitLevel==1 then
    		left:setButtonEnabled(false)
    	else
    		left:setButtonEnabled(true)
    	end
    	if limitLevel==90 then
    		right:setButtonEnabled(false)
    	else
    		right:setButtonEnabled(true)
    	end
    end
    limitLevelFunc(0)

    --军团宣言
    local manifesto = cc.ui.UILabel.new({UILabelType = 2, text = "军团宣言：", size = 25})
    :addTo(self)
    :align(display.CENTER_LEFT, 200, 220)
    manifesto:setColor(cc.c3b(151, 190, 204))
    local bar = display.newScale9Sprite("#legion_img8.png",manifesto:getPositionX()+manifesto:getContentSize().width+10,
    	manifesto:getPositionY()+10,
		cc.size(270, 130),cc.rect(10,10,31,30))
	:addTo(self)
	bar:setAnchorPoint(0,1)

    display.newSprite("#legion_img9.png")
    :addTo(bar)
    :pos(bar:getContentSize().width/2, bar:getContentSize().height/2)

	self.maniLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22, color = cc.c3b(229, 241, 215)})
	:addTo(bar)
	:pos(10,125)
	self.maniLabel:setAnchorPoint(0,1)
	self.maniLabel:setWidth(240)
	self.maniLabel:setLineHeight(32)
	self.maniLabel:setString(mLegionData.army.manifesto)

    local oldMani = self.maniLabel:getString()
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            -- editbox:setText(self.maniLabel:getString())
        elseif event == "changed" then
            -- 输入框内容发生变化
            print("changed")
        elseif event == "ended" then
            print("end")
            -- 输入结束
            if editbox:getText()~="" then
                oldMani = editbox:getText()
                editbox:setText("")
                self.maniLabel:setString(oldMani)
            else
                editbox:setText("")
                self.maniLabel:setString(oldMani)
            end
            -- self.maniLabel:setString(editbox:getText())
            -- editbox:setText("")
        elseif event == "return" then
            print("return")
            -- editbox:setText("")
            -- 从输入框返回
        end
    end
	local maniInput = cc.ui.UIInput.new({image = "EditBoxBg.png", listener = onEdit,size = cc.size(250, 120)})
	:addTo(bar)
	:pos(130,70)
    maniInput:setMaxLength(30)
	

	--确定按钮
	local confirmBt = createGreenBt("确认修改")
	:addTo(self)
	:pos(484,60)
	:onButtonClicked(function(event)
		startLoading()
		local sendData = {}
		sendData["icon"] = self.legionIcon:getTag()
		sendData["autoJoin"] = limitIdx - 1
		sendData["minMemLevel"] = limitLevel
		sendData["manifesto"] = self.maniLabel:getString()
		
		m_socket:SendRequest(json.encode(sendData), CMD_SETTING_LEGION, self, self.onSettingLegionResult)
		end)
end
function LegionManage_settting:onSettingLegionResult(result)
	endLoading()
	if result["result"]==1 then
		mLegionData.army.icon = self.legionIcon:getTag()
		mLegionData.army.minMemLevel = limitLevel
        mLegionData.army.autoJoin = limitIdx - 1
        mLegionData.army.manifesto= self.maniLabel:getString()
		showTips("修改成功！")

        if g_myLegionLayer then
            g_myLegionLayer:reloadThisLayerAllData()
        end
	else
		showTips(result.msg)
	end
end

function LegionManage_settting:selIconCallBack(path,iconId)
	self.legionIcon:setButtonImage("normal", path)
    self.legionIcon:setButtonImage("pressed", path)
    self.legionIcon:setTag(iconId)
end

return LegionManage_settting