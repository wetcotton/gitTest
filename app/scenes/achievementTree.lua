--
-- Author: Huang Yuzhao
-- Date: 2015-08-04 14:07
--

achievementTree = class("achievementTree",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
achievementTree.Instance = nil
achievementTree.curRewards = nil 				--当前奖励，发送消息时更新（非每日签到）

function achievementTree:ctor(params)
 	achievementTree.Instance = self
 	self.pages = {1,1,1,1,1}
 	AchMgr:initData()

    -- display.addSpriteFrames("Image/UIAchievement.plist", "Image/UIAchievement.png")
    display.addSpriteFrames("SingleImg/achEff.plist", "SingleImg/achEff.png")

    self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
    
 	--返回按钮
    cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png",pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height)
        :addTo(self)
        :onButtonClicked(function(event)
        	display.getRunningScene():refreshTaskRedPoin()
            self:removeFromParent()
        end)

    local tmpSize = cc.size(1130,520)

	local imgBG = display.newScale9Sprite("achievementTree/achievement_img6.png", nil, nil, tmpSize)
					    :align(display.CENTER, display.cx, display.cy-60)
						:addTo(self,10)


	local function setMenuStatus(event)
        local ntag = event.target:getTag()-1000
        self.curMenuIdx = ntag

        for i=1,5 do
            self.menus[i]:setButtonEnabled(true)
            self.menus[i]:setLocalZOrder(5-i)
            self.menus[i]:getChildByTag(10):setColor(cc.c3b(0, 149, 178))
        end
        event.target:setButtonEnabled(false)
        event.target:setLocalZOrder(11)
        event.target:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
        self:reloadListview()
    end

    local menuName = {"战队等级","装备提升","怪物击杀","三星通关","赏金挑战",}
    self.curMenuIdx = 1
    self.menus  = {}
    for i=1,5 do
        self.menus[i] = cc.ui.UIPushButton.new({
            normal = "common/common_nBt7_1.png",
            disabled = "common/common_nBt7_2.png"
            })
        :addTo(self,5-i, 1000+i)
        :pos(display.cx-450+ (i-1)*150, display.cy+220)
        :onButtonClicked(setMenuStatus)
        self.menus[i]:setScaleY(-1)

        local label = cc.ui.UILabel.new({UILabelType = 2, text = menuName[i], size = 25, color = cc.c3b(0, 149, 178)})
        :addTo(self.menus[i],0, 10)
        :align(display.CENTER, -15,5)
        label:setScaleY(-1)

        if i==1 then
            self.menus[i]:setButtonEnabled(false)
            self.menus[i]:setLocalZOrder(11)
            self.menus[i]:getChildByTag(10):setColor(cc.c3b(95, 217, 255))
        end
    end

	local img = display.newSprite("achievementTree/achievement_img1.png")
		:addTo(self)
		:align(display.CENTER_TOP, display.cx, display.height)
	display.newSprite("achievementTree/achievement_img2.png")
		:addTo(img)
		:pos(img:getContentSize().width/2, img:getContentSize().height/2+8)

	local tmpNode = display.newSprite("achievementTree/achievement_img7.png")
							:addTo(self)
							:align(display.RIGHT_TOP,(tmpSize.width+display.width)/2-20,display.height-100)

	tmpNode = display.newSprite("common2/com2_img_33.png")
							:addTo(tmpNode)
							:align(display.LEFT_CENTER,tmpNode:getContentSize().width-200,tmpNode:getContentSize().height/2)

	self.hornorLab = display.newTTFLabel({
							font = "fonts/slicker.ttf",
							text=srv_userInfo.honor,
							size=25,
							color=cc.c3b(255,255,0),
							align = cc.TEXT_ALIGNMENT_LEFT,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.LEFT_CENTER, tmpNode:getContentSize().width+8,tmpNode:getContentSize().height/2)
						:addTo(tmpNode)

	--listview
	self.listview = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 120),
        bgScale9 = true,
        viewRect = cc.rect(30, 20, 1070, 460),
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(imgBG)
    self:reloadListview()


	self.mailDesMask = UIMasklayer.new()
	self.mailDesMask:addTo(self,20)
	self.mailDesMask:hide()


	local tmpSize = cc.size(795,491)
    
	local detailBox = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        tmpSize,cc.rect(119, 127, 1, 1))
					    :addTo(self.mailDesMask)
					    :pos(display.cx, display.cy)
	self.mailDesMask:addHinder(detailBox)
	self.detailBox = detailBox

	cc.ui.UIPushButton.new({normal="common2/com2_Btn_2_down.png",pressed="common2/com2_Btn_2_down.png"})
	    :align(display.CENTER, tmpSize.width+20, tmpSize.height-40)
	    :addTo(detailBox,10)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
	    :onButtonClicked(function(event)
	        self.mailDesMask:hide()
	    end)

	self.des = {}
	--成就图标
	self.des.sp1 = display.newSprite()
					:addTo(detailBox)
					:align(display.LEFT_TOP, 80, tmpSize.height-30)
	self.des.sp1:setContentSize(cc.size(128,128))
	--成就名称
	self.des.LbName = display.newTTFLabel({
							text="",
							size=30,
							color=cc.c3b(243,152,0),
							align = cc.TEXT_ALIGNMENT_CENTER,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.LEFT_CENTER, tmpSize.width/2-150, tmpSize.height-60)
						:addTo(detailBox)

	

	--成就目标
	self.des.Lb2 = display.newTTFLabel({
							text="",
							size=22,
							color=cc.c3b(177,209,225),
							align = cc.TEXT_ALIGNMENT_LEFT,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
			               
						})
						:align(display.LEFT_CENTER, tmpSize.width/2-150, tmpSize.height-100)
						:addTo(detailBox,1)
	--完成进度
	self.des.Lb3 = display.newTTFLabel({
							font = "fonts/slicker.ttf", 
							text="",
							size=22,
							color=cc.c3b(201,255,51),
							align = cc.TEXT_ALIGNMENT_LEFT,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
			               
						})
						:align(display.LEFT_CENTER, self.des.Lb2:getPositionX()+self.des.Lb2:getContentSize().width, self.des.Lb2:getPositionY())
						:addTo(detailBox,1)
    --进度条
    local bar = display.newScale9Sprite("achievementTree/achievement_img4.png",nil,nil, cc.size(407,25))
    :addTo(detailBox)
    :align(display.LEFT_CENTER, tmpSize.width/2-160, tmpSize.height-125)
    
    self.desProBar = cc.ui.UILoadingBar.new({image = "achievementTree/achievement_img8.png", viewRect = cc.rect(0,0,407,25)})
    :addTo(bar)
    :align(display.LEFT_BOTTOM,0, 0)

    self.desProNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 18})
    :addTo(bar,10)
    :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-2)
    self.desProNumRetNode = setLabelStroke(self.desProNum,18,nil,1,1,1,1,"fonts/slicker.ttf", false)

    --奖励物品列表
    self.desRewardlv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(20, tmpSize.height/2-80, tmpSize.width-40, 150),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(detailBox)

	self.btn_get = cc.ui.UIPushButton.new({normal="common2/com2_Btn_6_up.png",pressed="common2/com2_Btn_6_down.png"},{grayState = true})
	    :align(display.CENTER, tmpSize.width/2, 70)
	    :addTo(detailBox)
	    :onButtonClicked(function (event)
	    		local tptId = event.target:getTag()
				print("tptId: ",tptId)
				local loc_taskId = achievementData[tptId].taskID
				print("loc_taskId: ",loc_taskId)

				if event.target.canGoTo==true then
                    MainSceneEnterType = EnterTypeList.ACHIEVEMENT_ENTER
					local achData = achievementData[tptId]
					local params = achData.params
					if achData.type==4 then
						local toAreaId = params
						if srv_userInfo.level<areaData[toAreaId].level then
							showTips(areaData[toAreaId].level.."级开启该大区")
							return
						elseif not canAreaEnter(toAreaId, 1) then
							showTips("未通过至此大区")
							return
						end
						local areamap = g_blockMap.new(toAreaId, nil, 1)
							:addTo(self,100)
					elseif achData.type==5 then
						local toBlockId = params
						local toAreaId = blockIdtoAreaId(toBlockId)
						if srv_userInfo.level<areaData[toAreaId].level then
							showTips(areaData[toAreaId].level.."级开启该大区")
							return
						elseif not canAreaEnter(toAreaId, blockData[toBlockId].type) then
							showTips("未通过至此大区")
							return
						end
						local areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
							:addTo(self,100)
					elseif achData.type==3 then
						local toBlockId = achData.paramsBlock
						local toAreaId = blockIdtoAreaId(toBlockId)
						if srv_userInfo.level<areaData[toAreaId].level then
							showTips(areaData[toAreaId].level.."级开启该大区")
							return
						elseif not canAreaEnter(toAreaId, blockData[toBlockId].type) then
							showTips("未通过至此大区")
							return
						end
						local areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
							:addTo(self,100)
					end
					return
				end

				local srv_id = nil
				for k,v in pairs(AchMgr.statusList) do
					if k==loc_taskId then
						srv_id = v.id
						break
					end
				end
				print("srv_id: "..srv_id)
				if srv_id==nil then
					print("任务出错，function achievementTree:refreshBox(tptId) ")
					return
				end
				
				--printTable(TaskMgr.idKeyInfo[srv_id])
				TaskMgr:ReqSubmit(srv_id)
				startLoading()
				self:GenerateRewardsTab(loc_taskId)
			end)

	self.btnLabel = cc.ui.UILabel.new({text = "领取", size = 26, color = display.COLOR_GREEN})
						:addTo(self.btn_get)
						:align(display.CENTER,0,0)	

	-- self:jumpToHightLight()
	self:reloadRedPoint()
end
function achievementTree:reloadListview()
	self.listview:removeAllItems()
	
	for i=1,math.ceil(#AchMgr.sortList[self.curMenuIdx]/5) do
		local item = self.listview:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(1000, 200)
        self.listview:addItem(item)
		for j=1,5 do
			local cnt = j+(i-1)*5
			local tmpId = AchMgr.sortList[self.curMenuIdx][cnt]
            if tmpId==nil then
                break
            end
            local achLocData = achievementData[tmpId]
            local taskLocData = taskData[achLocData.taskID]

            local iconPath = "achIcon/achi_"..achLocData.resId..".png"
            local icon = cc.ui.UIPushButton.new({normal = iconPath})
            :addTo(content)
            :pos(-400+(j-1)*200, 0)
            :onButtonClicked(function(event)
            	self:refreshBox(tmpId, event.target)
            	end)
            icon:setTouchSwallowEnabled(false)

            --覆盖的精灵
            local sp = display.newNode()
            :addTo(icon)
            -- :pos(-400+(j-1)*200, 0)

            local lbCnt = 0
            local staLabel = "未达成"
            local staLabelColor = cc.c3b(255, 255, 255)
            local srv_status = AchMgr.statusList[achLocData.taskID]
            if srv_status~=nil then
            	lbCnt = AchMgr.statusList[achLocData.taskID].curcnt
            	if srv_status.status==2 then --已经领奖
					staLabel = "已达成"
                    staLabelColor = cc.c3b(151, 75, 35)

                    display.newSprite(iconPath)
                    :addTo(sp)
				elseif srv_status.status==0 then --未完成
					display.newGraySprite(iconPath)
                    :addTo(sp)
				elseif srv_status.status==1 then --已经完成，可领奖
					display.newSprite("achievementTree/achievement_img3.png")
					:addTo(icon,0,10)
					staLabel = "已达成"
                    staLabelColor = cc.c3b(151, 75, 35)
                    achiTreeEff(icon)

                    display.newSprite(iconPath)
                    :addTo(sp)
				end
			else --未开启
				lbCnt = 0

                display.newGraySprite(iconPath)
                :addTo(sp)
			end
			--进度
			local bar = display.newSprite("achievementTree/achievement_img4.png")
            :addTo(content)
            :pos(-400+(j-1)*200, -80)
         	
         	if self.curMenuIdx==1 then --等级成就的完成度，直接用玩家等级，服务端的值有问题（而且难解决）
         		lbCnt = srv_userInfo.level
         	end
            local per = lbCnt/achLocData.cnt
			local proBar = display.newSprite("achievementTree/achievement_img5.png",0,0, {capInsets=cc.rect(0,0,145*per,25)})
            :addTo(bar)
            :align(display.LEFT_BOTTOM, 0, 0)

            local label = cc.ui.UILabel.new({UILabelType = 2, text = staLabel, size = 20, color = staLabelColor})
            :addTo(bar,10)
            :align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2-1)
            if staLabel=="未达成" then
                setLabelStroke(label,20,nil,1,nil,nil,nil,nil, true)
            else
            end
            
		end
	end

	self.listview:reload()
	self:reloadRedPoint()
end

--每栏红点判断
function achievementTree:reloadRedPoint()
	for i=1,5 do
		self.menus[i]:removeChildByTag(100)
		for j,value in ipairs(AchMgr.sortList[i]) do
            local achLocData = achievementData[value]
			local srv_status = AchMgr.statusList[achLocData.taskID]
			if srv_status and srv_status.status==1 then --可领取
				--红点
				display.newSprite("common/common_RedPoint.png")
				:addTo(self.menus[i],0,100)
				:pos(40,-20)
				break
			end
		end
	end
	
end


function achievementTree:initAllNode()
	local typeResPath = 
	{
		typeBg = {"#achTypeBg_1.png","#achTypeBg_2.png","#achTypeBg_3.png","#achTypeBg_2.png","#achTypeBg_3.png",},
		typeImg = {"#achTypeImg_1.png","#achTypeImg_2.png","#achTypeImg_3.png","#achTypeImg_4.png","#achTypeImg_5.png",},
		typeTitle = {"#achTypeText_1.png","#achTypeText_2.png","#achTypeText_3.png","#achTypeText_4.png","#achTypeText_5.png",},
	}
	self.nodeList = {}
	self.upBtn = {}
	self.downBtn = {}
	self.pageLabel = {}
	for i = 1,5 do
		local tmpNode,tmpSize
		tmpNode = display.newSprite(typeResPath.typeBg[i])
					:addTo(self.scrollNode)
		tmpSize = tmpNode:getContentSize()
		tmpNode:pos((tmpSize.width+5)*(i-1)+tmpSize.width/2,self.scrollNode:getContentSize().height/2)
		display.newSprite(typeResPath.typeImg[i])
					:addTo(tmpNode)
					:pos(tmpSize.width/2,tmpSize.height/2-20)
		display.newSprite(typeResPath.typeTitle[i])
					:addTo(tmpNode)
					:align(display.CENTER_TOP,tmpSize.width/2,tmpSize.height-20)

		local totalPageNum = math.ceil(#AchMgr.sortList[i]/9)
		self.upBtn[i] = cc.ui.UIPushButton.new({normal = "#achBtn_1_0.png",pressed = "#achBtn_1_1.png"})
				:addTo(tmpNode)
				:align(display.RIGHT_BOTTOM,tmpSize.width/2-30,15)
				:onButtonClicked(function ()
					self.pages[i] = self.pages[i]-1
					if self.pages[i]<1 then
						self.pages[i] = 1
					else
						self:reloadPage(i,self.pages[i])
					end
				end)

		self.downBtn[i] = cc.ui.UIPushButton.new({normal = "#achBtn_2_0.png",pressed = "#achBtn_2_1.png"})
				:addTo(tmpNode)
				:align(display.LEFT_BOTTOM,tmpSize.width/2+30,15)
				:onButtonClicked(function ()
					self.pages[i] = self.pages[i]+1
					if self.pages[i]>totalPageNum then
						self.pages[i] = totalPageNum
					else
						self:reloadPage(i,self.pages[i])
					end
					
				end)
		self.pageLabel[i] = display.newTTFLabel({
								text=self.pages[i].."/"..totalPageNum,
								size=22,
								color=cc.c3b(255,255,0),
								align = cc.TEXT_ALIGNMENT_CENTER,
				                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				               
							})
							:align(display.CENTER ,tmpSize.width/2,40)
							:addTo(tmpNode,1)
		tmpNode = display.newNode()
			:addTo(tmpNode)
			:pos(181,220)
		self.nodeList[i] = tmpNode
		local offX,offY = 20, 20
		local off = {{-1,1},{0,1},{1,1},{-1,0},{0,0},{1,0},{-1,-1},{0,-1},{1,-1}}
		for j=1,9 do
			local node = display.newSprite("#ach_box1.png")
				:addTo(tmpNode,0,j)
				:pos(off[j][1]*(offX+83),off[j][2]*(offY+83))

			node.btn = cc.ui.UIPushButton.new({normal = "#ach_box1.png"})
					:addTo(node)
					:align(display.LEFT_BOTTOM,0,0)
			node.btn:setTouchSwallowEnabled(false)

			node.icon = display.newSprite()
					:addTo(node,1)
					:align(display.CENTER,node:getContentSize().width/2,node:getContentSize().height/2)
		end
		self:reloadPage(i,self.pages[i])
	
	end
end

function achievementTree:reloadPage(_type,_page)
	local totalPageNum = math.ceil(#AchMgr.sortList[_type]/9)
	-- self.pageLabel[_type]:setString(_page.."/"..totalPageNum)
	local curPageItemNum = 9
	if totalPageNum==_page then
		curPageItemNum = #AchMgr.sortList[_type] - (totalPageNum-1)*9
	end
	local tmpNode = self.nodeList[_type]
	for j=1,9 do
		local node = tmpNode:getChildByTag(j)
		if j>curPageItemNum then
			node:setVisible(false)
		else
			node:setVisible(true)
			local index = (_page-1)*9 + j
			index = AchMgr.sortList[_type][index]
			local loc_data = achievementData[index]
			local btn = node.btn
			btn:setTag(index)
			local icon = node.icon
			btn:onButtonClicked(function (event)
				local nTag = event.target:getTag()
				--print(nTag.."  is clicked")
				self:refreshBox(nTag)
			end)
			self:refreshIcon(icon,loc_data)
		end
		
	end
end

--三种状态，0未完成，1完成未领奖，2已经领奖
function achievementTree:refreshIcon(icon,loc_data)
	
	local node = icon:getParent()
	node:removeChildByTag(1012)
	node:removeChildByTag(1013)
	node:removeChildByTag(1014)
	local strName = "achIcon/achi_"..loc_data.resId..".png"
	if cc.FileUtils:getInstance():isFileExist(strName) then
		local imgLight = display.newSprite("#achEff_01.png")
		local spr = display.newGraySprite(strName,{})
		local srv_status = AchMgr.statusList[loc_data.taskID]
		print("-------loc_data.taskID:  "..loc_data.taskID)
		print(srv_status)
		if srv_status~=nil and srv_status.status==2 then --已经领奖
			local frame = cc.SpriteFrame:create(strName,cc.rect(0,0,spr:getContentSize().width,spr:getContentSize().height))
			icon:setSpriteFrame(frame)
			display.newSprite("#ach_img8.png")
				:addTo(node,4,1014)
				:align(display.LEFT_TOP,0,node:getContentSize().height)
		elseif srv_status~=nil and srv_status.status==0 then --未完成
			display.newSprite("#ach_img13.png")
				:addTo(node,4,1014)
				:align(display.LEFT_TOP,0,node:getContentSize().height)
			spr:addTo(node,2,1012)
			   :pos(node:getContentSize().width/2,node:getContentSize().height/2)
		elseif srv_status~=nil and srv_status.status==1 then --已经完成，可领奖
			display.newSprite("#ach_img7.png")
				:addTo(node,4,1014)
				:align(display.RIGHT_BOTTOM,node:getContentSize().width,0)
			local frame = cc.SpriteFrame:create(strName,cc.rect(0,0,spr:getContentSize().width,spr:getContentSize().height))
			icon:setSpriteFrame(frame)
			imgLight:addTo(node,2,1013)
				:pos(icon:getContentSize().width/2,icon:getContentSize().height/2)
			local effframes = display.newFrames("achEff_%02d.png", 1, 9)
		    local effanimation = display.newAnimation(effframes, 0.85/9)
		    local effAction = cc.Animate:create(effanimation)
		    imgLight:runAction(cc.RepeatForever:create(effAction))
		elseif srv_status==nil then --未开启
			display.newSprite("#ach_img13.png")
				:addTo(node,4,1014)
				:align(display.LEFT_TOP,0,node:getContentSize().height)
			spr:addTo(node,2,1012)
			   :pos(node:getContentSize().width/2,node:getContentSize().height/2)
		end
	end
end

function achievementTree:refreshBox(tptId, target) 
	print("成就："..tptId)
	self.mailDesMask:show()
	local loc_data = achievementData[tptId]
	self.des.LbName:setString(loc_data.name)
	-- self.des.Lb1:setString(loc_data.des)
	self.des.Lb2:setString(loc_data.des)
	local lbCnt = 0
	local srv_status = AchMgr.statusList[achievementData[tptId].taskID]
	self.btn_get.canGoTo = false
	if srv_status~=nil then
		lbCnt = AchMgr.statusList[achievementData[tptId].taskID].curcnt
		print("srv_status.status: "..srv_status.status)
		if srv_status.status==ACH_FINISH_TYPE.HASGOT then --已经领奖
			self.btn_get:setButtonEnabled(false)	
			self.btnLabel:setString("已领奖")
		elseif srv_status.status==ACH_FINISH_TYPE.UNFINISH then --未完成
			self.btn_get:setButtonEnabled(false)	
			self.btnLabel:setString("未完成")
			if loc_data.type==3 or loc_data.type==4 or loc_data.type==5 then
				self.btn_get:setButtonEnabled(true)	
				self.btnLabel:setString("前往")
				self.btn_get:setTag(tptId)
				self.btn_get.canGoTo = true
			end
		elseif srv_status.status==ACH_FINISH_TYPE.FINISHED then --已经完成，可领奖
			self.btn_get:setButtonEnabled(true)	
			self.btnLabel:setString("领奖")

			self.btn_get:setTag(tptId)
            target:removeChildByTag(1000)
		end
	else
		self.btn_get:setButtonEnabled(false)	
		self.btnLabel:setString("未达成")
	end

    if self.btn_get:isButtonEnabled() then
        self.btnLabel:setColor(display.COLOR_GREEN)
    else
        self.btnLabel:setColor(MYFONT_COLOR)
    end
    if self.curMenuIdx==1 then --等级成就的完成度，直接用玩家等级，服务端的值有问题（而且难解决）
        lbCnt = srv_userInfo.level
    end

	self.des.Lb3:pos(self.des.Lb2:getPositionX()+self.des.Lb2:getContentSize().width, self.des.Lb2:getPositionY())
				:setString("("..lbCnt.."/"..loc_data.cnt..")")
	-- self.des.Lb4:pos(self.des.Lb3:getPositionX()+self.des.Lb3:getContentSize().width, self.des.Lb3:getPositionY())
	-- 			:setString()
    

    if lbCnt>=loc_data.cnt then
        self.des.Lb3:setColor(cc.c3b(201, 255, 51))
    else
        self.des.Lb3:setColor(cc.c3b(230, 0, 18))
    end

    self.desProBar:setPercent((lbCnt/loc_data.cnt)*100)

    self.desProNum:setString(math.floor(math.min(lbCnt/loc_data.cnt, 1.0)*100).."%")
    setLabelStrokeString(self.desProNum, self.desProNumRetNode)

	-- self.dexItems = self.dexItems or {}
	-- for k,v in pairs(self.dexItems) do
	-- 	v:removeFromParent()
	-- end
	-- self.dexItems = {}

    --奖励列表更新
    self.desRewardlv:removeAllItems()

	-- local ptX ,ptY = 120,255
	if loc_data.gold~=0 then
        local item = self.desRewardlv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.desRewardlv:addItem(item)
        local tmpNode = GlobalGetSpecialItemIcon(GAINBOXTPLID_GOLD, loc_data.gold)
        :addTo(content)
		-- local spGold = display.newSprite("common/common_GoldGet.png")
		-- 					:addTo(self.detailBox,1)
		-- 					:align(display.LEFT_CENTER, ptX, ptY)
		-- 					:scale(0.7)
		-- table.insert(self.dexItems,spGold)
		--金币数量
		-- local goldNum = display.newTTFLabel({
		-- 						font = "fonts/slicker.ttf", 
		-- 						text="×"..loc_data.gold,
		-- 						size=22,
		-- 						color=cc.c3b(255,255,0),
		-- 						align = cc.TEXT_ALIGNMENT_LEFT,
		-- 		                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				               
		-- 					})
		-- 					:align(display.LEFT_CENTER, spGold:getContentSize().width*0.7 + ptX , ptY-2)
		-- 					:addTo(self.detailBox,1)
		-- table.insert(self.dexItems,goldNum)
		-- ptY=ptY-70
	end

	if loc_data.diamond~=0 then
        local item = self.desRewardlv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.desRewardlv:addItem(item)
        local tmpNode = GlobalGetSpecialItemIcon(GAINBOXTPLID_DIAMOND, loc_data.diamond)
        :addTo(content)
		-- local spDiamond = display.newSprite("common/common_Diamond.png")
		-- 					:addTo(self.detailBox,1)
		-- 					:align(display.LEFT_CENTER, ptX, ptY)
		-- 					:scale(0.7)
		-- table.insert(self.dexItems,spDiamond)
		-- --钻石数量
		-- local diamondNum = display.newTTFLabel({
		-- 						font = "fonts/slicker.ttf", 
		-- 						text="×"..loc_data.diamond,
		-- 						size=22,
		-- 						color=cc.c3b(0,200,200),
		-- 						align = cc.TEXT_ALIGNMENT_LEFT,
		-- 		                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				               
		-- 					})
		-- 					:align(display.LEFT_CENTER, spDiamond:getContentSize().width*0.7 + ptX , ptY-2)
		-- 					:addTo(self.detailBox,1)
		-- table.insert(self.dexItems,diamondNum)
		-- ptY=ptY-70
	end

    if loc_data.exp~=0 then
        local item = self.desRewardlv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.desRewardlv:addItem(item)
        local tmpNode = GlobalGetSpecialItemIcon(GAINBOXTPLID_EXP, loc_data.exp)
        :addTo(content)
        -- local spDiamond = display.newSprite("common/common_Diamond.png")
        --                  :addTo(self.detailBox,1)
        --                  :align(display.LEFT_CENTER, ptX, ptY)
        --                  :scale(0.7)
        -- table.insert(self.dexItems,spDiamond)
        -- --钻石数量
        -- local diamondNum = display.newTTFLabel({
        --                      font = "fonts/slicker.ttf", 
        --                      text="×"..loc_data.diamond,
        --                      size=22,
        --                      color=cc.c3b(0,200,200),
        --                      align = cc.TEXT_ALIGNMENT_LEFT,
        --                      valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                               
        --                  })
        --                  :align(display.LEFT_CENTER, spDiamond:getContentSize().width*0.7 + ptX , ptY-2)
        --                  :addTo(self.detailBox,1)
        -- table.insert(self.dexItems,diamondNum)
        -- ptY=ptY-70
    end

	if loc_data.honor~=0 then
        local item = self.desRewardlv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.desRewardlv:addItem(item)
        local tmpNode = GlobalGetSpecialItemIcon(GAINBOXTPLID_HONOR, loc_data.honor)
        :addTo(content)
		-- local spHonor = display.newSprite("common/honor.png")
		-- 					:addTo(self.detailBox,1)
		-- 					:align(display.LEFT_CENTER, ptX, ptY)
		-- table.insert(self.dexItems,spHonor)
		-- --荣誉值
		-- local honorNum = display.newTTFLabel({
		-- 						font = "fonts/slicker.ttf", 
		-- 						text="×"..loc_data.honor,
		-- 						size=22,
		-- 						color=cc.c3b(255,255,0),
		-- 						align = cc.TEXT_ALIGNMENT_LEFT,
		-- 		                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				               
		-- 					})
		-- 					:align(display.LEFT_CENTER, spHonor:getContentSize().width + ptX , ptY-2)
		-- 					:addTo(self.detailBox,1)
		-- table.insert(self.dexItems,honorNum)
		-- ptY=ptY-70
	end
	
	-- local ptX ,ptY = 350,230
	local ItemsArr=lua_string_split(loc_data.reward,"|")
	for k,v in pairs(ItemsArr)do
        local itemAndNum=lua_string_split(v,"#")

        local item = self.desRewardlv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(150, 150)
        self.desRewardlv:addItem(item)

        local tmpNode = createItemIcon(itemAndNum[1], itemAndNum[2])
        :addTo(content)
        :scale(0.85)
		
		-- --printTable(itemAndNum)
		-- local node = createItemIcon(itemAndNum[1])
		-- 					:addTo(self.detailBox,1)
		-- 					:scale(0.7)

		-- node:setPosition(cc.p(ptX,ptY))
		-- table.insert(self.dexItems,node)
		-- local lbl = display.newTTFLabel({
		-- 				font = "fonts/slicker.ttf", 
		-- 	    		text = "×"..itemAndNum[2],
		-- 	    		size=20,
		-- 					color=cc.c3b(0,200,0),
		-- 					align = cc.TEXT_ALIGNMENT_LEFT,
		-- 	                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		-- 	    		})
		-- 				:align(display.LEFT_CENTER,ptX+50,ptY-2)
		-- 	    		:addTo(self.detailBox,1)
		-- table.insert(self.dexItems,lbl)
		-- ptY=ptY -100
	end
    self.desRewardlv:reload()

	local strName = "achIcon/achi_"..loc_data.resId..".png"
		local spr = display.newSprite(strName)
		if spr~=nil then
		local frame = cc.SpriteFrame:create(strName,cc.rect(0,0,spr:getContentSize().width,spr:getContentSize().height))
			self.des.sp1:setSpriteFrame(frame)
		end

			local sc = 128/self.des.sp1:getContentSize().width
			self.des.sp1:scale(sc)		
end


function achievementTree:onExit()
	achievementTree.Instance = nil
 	-- display.removeSpriteFramesWithFile("Image/UIAchievement.plist", "Image/UIAchievement.png")
 	display.removeSpriteFramesWithFile("SingleImg/achEff.plist", "SingleImg/achEff.png")
end

function achievementTree:OnSubmitRet(cmd)
	print("提交返回，task")
	if 1==cmd.result then
		self:reloadListview()
		-- for i=1,5 do
		-- 	self:reloadPage(i,self.pages[i])
		-- end
		if nil~=self.curRewards then
			GlobalShowGainBox(nil, self.curRewards)
            print("------------------添加奖励")
			--奖励添加
			self:RewardsAdd(self.curRewards)
			self.mailDesMask:hide()
			self.hornorLab:setString("×"..srv_userInfo.honor)
		end
	else
		showTips(cmd.msg)
	end
	endLoading()
end

function achievementTree:GenerateRewardsTab(nTaskTplID)
	local loc_TaskData = taskData[nTaskTplID]
	self.curRewards = {}
	if 0~=loc_TaskData.gold then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_GOLD, num=loc_TaskData.gold})
	end
	if 0~=loc_TaskData.diamond then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=loc_TaskData.diamond})
	end
	if 0~=loc_TaskData.exp then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_EXP, num=loc_TaskData.exp})
	end
	if 0~=loc_TaskData.honor then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_HONOR, num=loc_TaskData.honor})
	end
	
	if nil~=loc_TaskData.rewardItems and""~=loc_TaskData.rewardItems and "null"~=loc_TaskData.rewardItems then
		local arr = string.split(loc_TaskData.rewardItems, "|")
		local subArr
		for i=1, #arr do
			subArr = string.split(arr[i], "#")
			table.insert(self.curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
		end
	end
	
end

--奖励添加（除去道具）
function achievementTree:RewardsAdd(tabRewards)
	if nil==tabRewards then
		return
	end

	for i=1, #tabRewards do
		if tabRewards[i].templateID==GAINBOXTPLID_GOLD then
			srv_userInfo.gold = srv_userInfo.gold+tabRewards[i].num
			mainscenetopbar:setGlod()

		elseif tabRewards[i].templateID==GAINBOXTPLID_DIAMOND then
			srv_userInfo.diamond = srv_userInfo.diamond+tabRewards[i].num
			mainscenetopbar:setDiamond()

		elseif tabRewards[i].templateID==GAINBOXTPLID_EXP then
			srv_userInfo.exp = srv_userInfo.exp+tabRewards[i].num
		elseif tabRewards[i].templateID==GAINBOXTPLID_HONOR then
			srv_userInfo.honor = srv_userInfo.honor+tabRewards[i].num

		end
	end
end
--跳转到可领的地方
function achievementTree:jumpToHightLight()

	local bIsFirst_1 = true
	local _firstType = 1   --首先遇到的类别

	for i=1,5 do
		-- local bIsFirst_2 = true
		-- local _firstIndex = 1   --每一类首先遇到的可领取索引
		for j = 1,#AchMgr.sortList[i] do
			local achIndex = AchMgr.sortList[i][j] --成就表id
			local ach_data = achievementData[achIndex]
			local srv_status = AchMgr.statusList[ach_data.taskID]
			if srv_status and srv_status.status==1 then
				if bIsFirst_1 then
					_firstType = i    --记录第几类成就有可领取的，取最先的到的
					bIsFirst_1 = false
				end
				self.pages[i] = math.ceil(j/9)
				self:reloadPage(i,self.pages[i])
				print("第"..i.."类，第"..self.pages[i].."页")
				break
			end
		end
	end
	print("_firstType: ".._firstType)
	if _firstType==1 or _firstType==2 then
		self.scrollNode:setPositionX(45)
	elseif _firstType==3 then
		self.scrollNode:setPositionX(-318)
	elseif _firstType==4 or _firstType==5 then
		self.scrollNode:setPositionX(-680)
	end 

end