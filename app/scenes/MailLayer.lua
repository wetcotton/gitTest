--
-- Author: Jun Jiang
-- Date: 2015-02-06 15:00:37
--

MailLayer = class("MailLayer",function()
	local layer = UIMasklayer.new({bAlwaysExist=true})
	layer:setNodeEventEnabled(true)
	return layer
end)
MailLayer.Instance = nil 	--实例
MailLayer.nCurSel 	= nil 	--当前选择{nMailID, oldStatus, des={content, rewards}}

function MailLayer:ctor(params)
 	MailLayer.Instance = self
 	display.addSpriteFrames("Image/UIMail.plist", "Image/UIMail.png")
    local bsSize = cc.size(895,654)
    
 	local tmpNode, tmpSize
 	local mailbox = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
		display.cy,
		bsSize,cc.rect(119, 127, 1, 1))
 	    :addTo(self)

 	tmpSize = mailbox:getContentSize()

 	--关闭按钮
    cc.ui.UIPushButton.new({normal="common2/com2_Btn_2_up.png",pressed="common2/com2_Btn_2_up.png"})
	    :align(display.CENTER, tmpSize.width-30, tmpSize.height-35)
	    :addTo(mailbox)
	    :onButtonPressed(function(event)
			event.target:setScale(0.95)
			end)
		:onButtonRelease(function(event)
			event.target:setScale(1.0)
			end)
	    :onButtonClicked(function(event)
			self:removeFromParent()
	    end)

	self.noMailTip = display.newSprite("common2/com2_Img_24.png")
        :addTo(mailbox)
        :pos(tmpSize.width/2, tmpSize.height/2)

	display.newTTFLabel{text = "您目前没有收到任何邮件",size = 22, color = cc.c3b(128, 136, 150)}
			:addTo(self.noMailTip)
			:pos(self.noMailTip:getContentSize().width/2,-20)
			--:hide()
	
	display.newSprite("common2/com2_Img_2.png")
		:align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
		:addTo(mailbox)
	--标题
	display.newSprite("#mailImg_4.png")
		:align(display.CENTER, tmpSize.width/2, tmpSize.height-60)
		:addTo(mailbox)


	--邮件列表
	self.mailListView = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(50, 61, 800, 490),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        --scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(mailbox)
        :onTouch(handler(self, self.MailListOnTouch))

	---------------------------------详细信息-------------------------------------
	--邮件详细信息遮罩层
	self.mailDesMask = UIMasklayer.new()
	self.mailDesMask:addTo(self)
	self.mailDesMask:hide()
	local function  func()
        self:InitMailList()
    end
    self.mailDesMask:setOnTouchEndedEvent(func)

	bsSize = cc.size(749,547)

	--邮件详细信息面板
	local desPanel = display.newScale9Sprite("common2/com2_Img_3.png",display.cx, 
		display.cy,bsSize,cc.rect(119, 127, 1, 1))
					    :align(display.CENTER, display.cx, display.cy)
						:addTo(self.mailDesMask)
	self.mailDesMask:addHinder(desPanel)
	tmpSize = desPanel:getContentSize()

	--领取/关闭按钮
    self.btn_get = cc.ui.UIPushButton.new({normal="common2/com2_Btn_1_up.png",pressed="common2/com2_Btn_1_down.png"})
	    :align(display.CENTER, tmpSize.width/2, 55)
	    :addTo(desPanel)
	    :onButtonClicked(function(event)
	    	local srvMail = MailMgr.mailInfo[self.nCurSel.nMailID]
	    	if srvMail.type==1 or srvMail.type==2 or srvMail.type==4 then
	    		if (srvMail.hasReward==1 and srvMail.status==3) or srvMail.hasReward==0 then
	    			--(关闭按钮)
	    			self.mailDesMask:hide()
	    			return
	    		end
	    	end
	    	if #self.nCurSel.des.rewards==0 then
		    	if self.nCurSel.oldStatus ~= MailMgr.mailInfo[self.nCurSel.nMailID].status then 	--状态改变
		        	self:InitMailList()
		        end
		        self.mailDesMask:hide()
		    else 	--领取附件
		    	if STATUS_MAIL_GET_REWARDS~=self.nCurSel.oldStatus then
			    	MailMgr:ReqGet(self.nCurSel.nMailID)
			    	startLoading()
			    else
			    	self.mailDesMask:hide()
			    end
		    end
	    end)
	display.newSprite("#mailTag_1.png")
		:addTo(self.btn_get,0, 10)
	


	display.newSprite("common2/com2_Img_2.png")
		:addTo(desPanel)
		:align(display.CENTER, tmpSize.width/2, tmpSize.height-55)
	--标题
	self.labTitle = display.newTTFLabel({
			    		text = "",
			            size = 31,
			            align = cc.TEXT_ALIGNMENT_CENTER,
			            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
			            color = cc.c3b(248, 182, 45),
			    		})
			    		:align(display.CENTER, tmpSize.width/2, tmpSize.height-52)
			    		:addTo(desPanel)

	tmpNode = display.newScale9Sprite("common2/com2_Img_4.png",nil,nil,cc.size(622,167),cc.rect(40, 40, 1, 1))
		:addTo(desPanel)
		:pos(bsSize.width/2,bsSize.height*0.4)

	--滚动层
	local scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(200, 0, 0, 0))
	scrollNode:setContentSize(610, 160)

	self.desView = cc.ui.UIScrollView.new {
    	--bgColor = cc.c4b(200, 0, 0, 30),
    	viewRect=cc.rect(6, 3, 610, 160),
    	direction=cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
		}
		:addScrollNode(scrollNode)
		:addTo(tmpNode)
		
		scrollNode:setPosition(cc.p(6,3))

	---------------------------滚动子节点-----------------------------------
	self.scrollChild = {}
	--内容
	self.scrollChild[1] = display.newTTFLabel({
				    		text = "",
				            size = 25,
				            align = cc.TEXT_ALIGNMENT_LEFT,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
				            color = display.COLOR_WHITE,
				            dimensions = cc.size(600, 0)
				    		})
				    		:align(display.LEFT_TOP, 90, bsSize.height*0.78)
				    		:addTo(desPanel)

	--发送者
	self.scrollChild[2] = display.newTTFLabel({
				    		text = "",
				            size = 24,
				            align = cc.TEXT_ALIGNMENT_RIGHT,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM,
				            color = cc.c3b(98,101,112),
				    		})
				    		:align(display.RIGHT_BOTTOM, 690, bsSize.height*0.15)
				    		:addTo(desPanel)

	--附件文字
	self.scrollChild[3] = display.newTTFLabel({
				    		text = "奖励物品：",
				            size = 25,
				            align = cc.TEXT_ALIGNMENT_RIGHT,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
				            color = cc.c3b(248, 182, 45),
				    		})
				    		:align(display.LEFT_TOP, 20, 145)
				    		:addTo(scrollNode)

	--附件（动态设定）
	self.attachment = {}
	---------------------------------------------------------------------------------

	self:InitMailList()
end

 --初始化邮件列表
function MailLayer:InitMailList()
 	local listView = self.mailListView
 	listView:removeAllItems()

 	local IsNoMail = true

 	local nID, srvInfo, tmpNode, tmpSize
 	for i=1, #MailMgr.sortList do
 		nID = MailMgr.sortList[i]
 		srvInfo = MailMgr.mailInfo[nID]
 		--已领取的3,4type不再显示
 		if STATUS_MAIL_GET_REWARDS~=srvInfo.status or srvInfo.type==1 or srvInfo.type==2 then 
	 		local item = listView:newItem()
	    	local content = display.newSprite()
	    	tmpSize = cc.size(800,132)
	    	--local content = display.newScale9Sprite("common/common_Frame18.png",nil,nil,tmpSize,cc.rect(10, 10, 5, 5))
	    					
	    	content:setContentSize(tmpSize)

	    	tmpNode = display.newScale9Sprite("common/common_Frame17.png",nil,nil,cc.size(100, 100),cc.rect(10, 10, 5, 5))
	    	                 :addTo(content,1)
	    	                 :align(display.LEFT_CENTER, 50, tmpSize.height/2)
	    	                 :opacity(0)

	    	if srvInfo.status==STATUS_MAIL_UNREAD then
	    		local tmpSize = tmpNode:getContentSize()
	    		if srvInfo.type==3 or srvInfo.type==4 then
		    		display.newSprite("common/common_RedPoint.png")
		    			:align(display.CENTER, tmpSize.width-10, tmpSize.height-10)
		    			:addTo(tmpNode,1)

		    		
		    		display.newSprite("#mailImg_1.png") 
		    	                 :addTo(tmpNode)
		    	                 :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)

		    	elseif srvInfo.type==1 or srvInfo.type==2 then
			 	    display.newSprite("common/common_RedPoint.png")
		    			:align(display.CENTER, tmpSize.width-20, tmpSize.height-30)
		    			:addTo(content)

					local tmpSize = tmpNode:getContentSize()
		    		display.newSprite("#mailImg_2.png") 
		    	                 :addTo(tmpNode)
		    	                 :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
	    		end
	    		
	    	else
	    		
				local tmpSize = tmpNode:getContentSize()
	    		display.newSprite("#mailImg_2.png") 
	    	                 :addTo(tmpNode)
	    	                 :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)


	   
	    	end

	    	--标题
	    	tmpNode = display.newTTFLabel({
				    		text = srvInfo.title,
				            size = 28,
				            align = cc.TEXT_ALIGNMENT_CENTER,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				            color = cc.c3b(248, 182, 45),
				    		})
				    		:align(display.LEFT_CENTER, 180, 90)
				    		:addTo(content)

			--时间
	    	tmpNode = display.newTTFLabel({
				    		text = srvInfo.cTime,
				            size = 20,
				            align = cc.TEXT_ALIGNMENT_CENTER,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				            color = cc.c3b(98,101,112),
				    		})
				    		:align(display.RIGHT_CENTER, 700, 40)
				    		:addTo(content)

			--发送人
	    	tmpNode = display.newTTFLabel({
				    		text = "发送人：" .. srvInfo.sender,
				            size = 24,
				            align = cc.TEXT_ALIGNMENT_CENTER,
				            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				            color = cc.c3b(98,173,180),
				    		})
				    		:align(display.LEFT_CENTER, 180, 40)
				    		:addTo(content)

			tmpNode = display.newScale9Sprite("#mailImg_3.png",nil,nil,cc.size(750, 5),cc.rect(30, 2, 1, 1))
	    	                 :addTo(content,1)
	    	                 :align(display.LEFT_CENTER, 20, 10)

	    	if i==#MailMgr.sortList then
	    		tmpNode:hide()
	    	end

			item.nMailID = nID

	    	item:addContent(content)
	        item:setItemSize(800, 132)
	        listView:addItem(item)

	        IsNoMail = false
    	end
    end
    listView:reload()

    self.noMailTip:hide()
    if IsNoMail then
    	self.noMailTip:show()
    end
end

function MailLayer:MailListOnTouch(event)
 	if event.name=="clicked" then
 		if nil==self.nCurSel then
 			self.nCurSel = {}
 			self.nCurSel.nMailID = nil
 			self.nCurSel.des = {content=nil, rewards=nil}
 		end

 		self.nCurSel.oldStatus = MailMgr.mailInfo[event.item.nMailID].status
 		-- if self.nCurSel.nMailID~=event.item.nMailID then
 		-- 	self.nCurSel.nMailID = event.item.nMailID
 		-- 	MailMgr:ReqDes(self.nCurSel.nMailID)
 		-- 	startLoading()
 		-- else
 		-- 	self:ShowDesPanel(false)
 		-- end
 		self.nCurSel.nMailID = event.item.nMailID
		MailMgr:ReqDes(self.nCurSel.nMailID)
		startLoading()
 	end
end

--显示详细面板
--@bInit：true(初始化) false(用上次的)
function MailLayer:ShowDesPanel(bInit)
 	if bInit then
 		self:InitDesPanel()
 	end

 	self.mailDesMask:show()
end

--初始化邮件详细面板
function MailLayer:InitDesPanel()
	local nMailID = self.nCurSel.nMailID
	local srvData = MailMgr.mailInfo[nMailID]
	local curContent = self.nCurSel.des.content
	local curRewards = self.nCurSel.des.rewards
	local scrollNode = self.desView:getScrollNode()
	local nRewardsNum = #curRewards

	self.labTitle:setString(srvData.title)
	self.scrollChild[1]:setString(curContent)
	self.scrollChild[2]:setString("发送者：" .. srvData.sender)

	--滚动节点高度，头三个文本控件间隔
	local nCurHeight, nGapY, tmpSize, nCurY = 0, 10, 0, 0
	local nGap1 = 50 	--第一个附件与之上文本间隔
	local nGap2 = 80 	--附件之间间隔
	local nGap3 = 60 	--与底部间隔

	
	--删除旧附件
	for i=1, #self.attachment do
		print("删除第"..i.."个item")
		if nil~=self.attachment[i].icon then
			self.attachment[i].icon:removeFromParent()
		end
		self.attachment[i] = nil
	end

	local startPtX,startPtY = 100,scrollNode:getContentSize().height/2-20
	local offX = 110

	for i=1, nRewardsNum do
		print("-------i: ",i,curRewards[i].templateID)
		if curRewards[i].templateID==GAINBOXTPLID_GOLD
			or curRewards[i].templateID==GAINBOXTPLID_DIAMOND
			or curRewards[i].templateID==GAINBOXTPLID_EXP
			or curRewards[i].templateID==GAINBOXTPLID_REPUTATION 
			or curRewards[i].templateID==GAINBOXTPLID_GONGXUN then
			
			self.attachment[i] = {}
			self.attachment[i].icon = GlobalGetSpecialItemIcon(curRewards[i].templateID, curRewards[i].num, 1)
						:align(display.CENTER, startPtX,startPtY)
						:addTo(scrollNode)
		else
			self.attachment[i] = {}
			self.attachment[i].icon = createItemIcon(curRewards[i].templateID,curRewards[i].num)
								:scale(0.84)
			:align(display.CENTER, startPtX,startPtY)
			:addTo(scrollNode)
		end

		startPtX = startPtX + offX
	end

end

--生成邮件类容(type：1、2类型本地数据生成,其他通过服务器返回数据生成)
function MailLayer:GenerateMailDes(data)
	if nil==data then
		return
	end

	--文本
	self.nCurSel.des.content = data.content
	
	--附件奖励（自己构造，方便GlobalShowGainBox接口使用）
	self.nCurSel.des.rewards = {}
	if 0~=data.gold then
		table.insert(self.nCurSel.des.rewards, {templateID=GAINBOXTPLID_GOLD, num=data.gold})
	end
	if 0~=data.diamond then
		table.insert(self.nCurSel.des.rewards, {templateID=GAINBOXTPLID_DIAMOND, num=data.diamond})
	end
	if 0~=data.reputation then
		table.insert(self.nCurSel.des.rewards, {templateID=GAINBOXTPLID_REPUTATION, num=data.reputation})
	end
	if 0~=data.exploit then
		table.insert(self.nCurSel.des.rewards, {templateID=GAINBOXTPLID_GONGXUN, num=data.exploit})
	end

	if ""~=data.rewardItems and "null"~=data.rewardItems then
		local arr = string.split(data.rewardItems, "|")
		local subArr
		for i=1, #arr do
			subArr = string.split(arr[i], "#")
			table.insert(self.nCurSel.des.rewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
end

--详细信息返回
function MailLayer:OnDesRet(cmd)
	if 1==cmd.result then
		local srvData = cmd.data
		if nil~=MailMgr.mailInfo[srvData.id] then
			self:GenerateMailDes(srvData)
			print("-----------------------------------======server")
			printTable(srvData)
			print("\n")
			self:ShowDesPanel(true)

			local srvMail = MailMgr.mailInfo[self.nCurSel.nMailID]
			printTable(srvMail)
			if srvMail.type==1 or srvMail.type==2 or srvMail.type==4 then
				-- print("aaaa")
				-- print((srvMail.hasReward==1 and srvData.status==3))
				-- print(srvMail.hasReward==0)
				if (srvMail.hasReward==1 and srvData.status==3) or srvMail.hasReward==0 then
					-- print("bbb")
					self.btn_get:setButtonImage("normal", "common/commonBt2_1.png")
					self.btn_get:setButtonImage("pressed", "common/commonBt2_2.png")
					self.btn_get:getChildByTag(10):setTexture("common/Improve_Text14.png")
				else
					-- print("ccc")
					self.btn_get:setButtonImage("normal", "common2/com2_Btn_1_up.png")
					self.btn_get:setButtonImage("pressed", "common2/com2_Btn_1_down.png")
					self.btn_get:getChildByTag(10):setSpriteFrame("mailTag_1.png")
				end
			else
				-- print("dd")
				self.btn_get:setButtonImage("normal", "common2/com2_Btn_1_up.png")
				self.btn_get:setButtonImage("pressed", "common2/com2_Btn_1_down.png")
				self.btn_get:getChildByTag(10):setSpriteFrame("mailTag_1.png")
			end
		end
	else
		showTips(cmd.msg)
	end
	endLoading()
end

function MailLayer:OnGetRet(cmd)
	if 1==cmd.result then
		self:InitMailList()
		self.mailDesMask:hide()
		GlobalShowGainBox(nil, self.nCurSel.des.rewards)
		for i=1,#self.nCurSel.des.rewards do
			local _reward = self.nCurSel.des.rewards[i]
			local dc_item = itemData[_reward.templateID]
			if dc_item then  --当奖励为道具时
				DCItem.get(tostring(dc_item.id), dc_item.name, _reward.num, "邮件领取")
			elseif _reward.templateID==GAINBOXTPLID_GOLD then
				DCCoin.gain("邮件领取","金币",_reward.num,srv_userInfo.gold+_reward.num)
			elseif _reward.templateID==GAINBOXTPLID_DIAMOND then
				print("获得钻石：", _reward.num)
				DCCoin.gain("邮件领取","钻石",_reward.num,srv_userInfo.diamond+_reward.num)
			elseif _reward.templateID==GAINBOXTPLID_REPUTATION then
				DCCoin.gain("邮件领取","声望",_reward.num,srv_userInfo.reputation+_reward.num)
			end
		end
	else
		showTips(cmd.msg)
	end
	endLoading()
end

function MailLayer:onExit()
 	MailLayer.Instance = nil

 	display.removeSpriteFramesWithFile(nil, "Image/UIMail/Mail_BoxBg.png")
 	display.removeSpriteFramesWithFile(nil, "Image/UIMail/Mail_Words_Inbox.png")
 	display.removeSpriteFramesWithFile(nil, "Image/UIMail/Mail_ItemBg_1.png")
 	display.removeSpriteFramesWithFile(nil, "Image/UIMail/Mail_ItemBg_2.png")

 	display.removeSpriteFramesWithFile("Image/UIMail.plist", "Image/UIMail.png")
end