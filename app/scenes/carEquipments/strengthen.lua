local strengthen = class("strengthen", function()
	return display.newNode()
	end)

function strengthen:ctor(value,localValue,callBack)
	
	self.value = value
	self.localValue = localValue
	self.callBack = callBack

	local msgBox = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(500, 597),cc.rect(119, 127, 1, 1))
	:addTo(self)
	:pos(display.cx+250+50, display.cy-30)
	local BoxSize = msgBox:getContentSize()

	self.closeBt = createCloseBt()
    :addTo(msgBox)
    :pos(msgBox:getContentSize().width+15,msgBox:getContentSize().height-32)
    :onButtonClicked(function(event)
    	if g_ImproveLayer.Instance~=nil then
	    	GuideManager:_addGuide_2(10802, cc.Director:getInstance():getRunningScene(),handler(g_ImproveLayer.Instance,g_ImproveLayer.Instance.caculateGuidePos))
	    end
        self:getParent():removeSelf()
        end)
	-- --名字
	-- local titleBar = display.newScale9Sprite("common/common_Frame8.png",BoxSize.width/2, 
	-- 	msgBox:getContentSize().height-38,
	-- 	cc.size(209, 39),cc.rect(10,10,30,30))
	-- :addTo(msgBox)
	-- local title = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
	-- :addTo(titleBar)
	-- :pos(titleBar:getContentSize().width/2, titleBar:getContentSize().height/2)
	-- title:setString(localValue.name)
	-- title:setAnchorPoint(0.5,0.5)
	-- --等级
	-- local levelBar = display.newSprite("common/Improve_Img24.png")
	-- :addTo(msgBox)
	-- :pos(msgBox:getContentSize().width/2, msgBox:getContentSize().height-90)
	-- self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 22})
	-- :addTo(levelBar)
	-- :pos(100,levelBar:getContentSize().height/2)
	-- self.level:setString(value.advLvl)
	-- self.level:setAnchorPoint(0.5,0.5)
	-- --图标
	-- local icon = createItemIcon(value.tmpId)
	-- :addTo(msgBox)
	-- :pos(BoxSize.width/2, BoxSize.height-170)
 --    self.strenIcon = icon
	-- --底框
	-- local midPart = display.newScale9Sprite("common/common_Frame8.png",BoxSize.width/2, 
	-- 	240,
	-- 	cc.size(392, 200),cc.rect(10,10,30,30))
	-- :addTo(msgBox)
	--需要金币
	self.needGold = cc.ui.UILabel.new({UILabelType = 2, text = "消耗金币", size = 28})
	:addTo(msgBox)
	:align(display.CENTER, BoxSize.width/2,BoxSize.height/2+120)
	self.needGold:setAnchorPoint(0.5,0.5)
	self.needGold:setColor(cc.c3b(255, 241, 0))
	local goldIcon = display.newSprite("common/common_GoldGet.png")
    :addTo(msgBox)
	:pos(BoxSize.width/2,BoxSize.height/2-30)
    self.goldIcon = goldIcon

	self.goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(msgBox)
	:align(display.CENTER, BoxSize.width/2,BoxSize.height/2-100)
	self.goldNum:setString(getStengthGold(value))
	self.goldNum:setColor(cc.c3b(255, 241, 0))

	--强化
	local strenBt = createGreenBt2("强化",1.2)
	:addTo(msgBox)
	:pos(150, 80)
	:onButtonClicked(function(event)
		
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["itemId"] = value["id"]
        sendData["isAuto"] = 0
        local g_step = nil
        g_step = GuideManager:tryToSendFinishStep(108) --强化主炮
        sendData.guideStep = g_step
        m_socket:SendRequest(json.encode(sendData), CMD_STRENGTHEN, self, self.onStrengthenResult)
        GuideManager:_addGuide_2(10705, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
        startLoading()
		end)
	self.guideBtn = strenBt

	--一键强化
	local oneStrenBt = createGreenBt2("一键强化",1.2)
	:addTo(msgBox)
	:pos(BoxSize.width - 150, 80)
	:onButtonClicked(function(event)
        local sendData={}
        sendData["characterId"] = srv_userInfo["characterId"]
        sendData["itemId"] = value["id"]
        sendData["isAuto"] = 1
        m_socket:SendRequest(json.encode(sendData), CMD_STRENGTHEN, self, self.onStrengthenResult)
        startLoading()
		end)

   self:reloadData() 
end
function strengthen:reloadData()
	-- self.level:setString(self.value.advLvl)
    if self.value.advLvl<90 then
        self.goldIcon:setVisible(true)
        self.goldNum:setVisible(true)
        self.needGold:setString("消耗金币")
        self.goldNum:setString(getStengthGold(self.value))
    else
        self.goldIcon:setVisible(false)
        self.goldNum:setVisible(false)
        self.needGold:setString("已强化到最高等级")
    end
	
end
function strengthen:onStrengthenResult(result) --强化
	endLoading()
    if result["result"]==1 then
        print("强化成功！")
        self:reloadData()
        self:getParent():getParent():reloadData(self.value,self.localValue,1)
        mainscenetopbar:setGlod()
        self.callBack()

        --强化特效
        -- local note = self.strenIcon
        -- advancedAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)
        local note = self.goldIcon
        strengthAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)
        
    else
    	showTips(result.msg)
    end
end

function strengthen:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10704 ==_guideId or 10705 ==_guideId then
        if 10704==_guideId then
            g_node = self.guideBtn
        elseif 10705==_guideId then
        	g_node = self.closeBt
        end
        
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return strengthen