-- 遗迹探测
-- Author: Jun Jiang
-- Date: 2015-06-04 10:33:31
--
RelicsLayer = class("RelicsLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
RelicsLayer.Instance = nil

--挑战重置的VIP等级和消耗
local ResetVipLimit = 6
local ResetCost     = 100

--金矿山洞、埋车之穴、红狼珍藏
local ChildModule = {
	{blockType=4, beginGoodBlock=42101001, beginEvilBlock=42201001},
	{blockType=5, beginGoodBlock=52101001, beginEvilBlock=52201001},
	{blockType=6, beginGoodBlock=61101001, beginEvilBlock=61201001},
	{blockType=7, beginGoodBlock=61101001, beginEvilBlock=61201001},
}

function RelicsLayer:ctor()
	g_nCurChildModule = 2
	RelicsLayer.Instance = self
	local tmpNode, tmpSize, tmpCx, tmpCy, tmpCfg
	tmpCx = display.width/2
	tmpCy = display.height/2

	self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
    display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    	:addTo(self)

	--返回按钮
	cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png", pressed="common/common_BackBtn_2.png"})
    	:align(display.LEFT_TOP, 0, display.height )
    	:addTo(self)
    	:onButtonClicked(function(event)
    		print("遗迹探测，点击返回")
            if TaskLayer.Instance~=nil then
                self:removeSelf()
                
            elseif g_WarriorsCenterLayer.Instance~=nil then
                g_WarriorsCenterLayer.Instance:ExitChildModule()
            end
    		
    		if FightSceneEnterType == EnterTypeList_2.RELICS_ENTER then
	    		FightSceneEnterType = EnterTypeList_2.NORMAL_ENTER
	    		print("-------------==================789--------FightSceneEnterType=="..FightSceneEnterType)
	    	end
    	end)

   	--关卡列表
   	self.blockList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(display.cx-590, display.cy-310, 1180, 600),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        }
        :addTo(self)

    --左箭头
    display.newSprite("#WarriorsCenter_Spr1.png")
    	:align(display.CENTER, display.cx-610, display.cy-15)
    	:addTo(self)

   	--右箭头
   	tmpNode = display.newSprite("#WarriorsCenter_Spr1.png")
		    	:align(display.CENTER, display.cx+610, display.cy-15)
		    	:addTo(self)
	tmpNode:setScaleX(-1)

	self.sprBright = {}
	self.sprFilter = {}
	self.labLeft = {}
    self.resetButton = {}
	--世界boss、遗迹探测、战车远征
	tmpCfg = {
		{
			bgSize=cc.size(305, 415), brightSize=cc.size(287, 401) , sprShow="Image/Relics_Img1.png",
			title="金矿山洞", titleX=152, titleY=445,
			desBg="#WarriorsCenter_Spr7.png", desBgScaleX=0.9, desBgX=152, desBgY=100,
			des="每周一、周四、周日开放", desSize=cc.size(283, 100), desX=152, desY=100,
		},
		{
			bgSize=cc.size(305, 415), brightSize=cc.size(287, 401) , sprShow="Image/Relics_Img2.png",
			title="埋车之穴", titleX=152, titleY=445,
			desBg="#WarriorsCenter_Spr7.png", desBgScaleX=0.9, desBgX=152, desBgY=100,
			des="每周三、周六、周日开放", desSize=cc.size(283, 100), desX=152, desY=100,
		},
		{
			bgSize=cc.size(305, 415), brightSize=cc.size(287, 401) , sprShow="Image/Relics_Img3.png",
			title="红狼珍藏", titleX=152, titleY=445,
			desBg="埋车之穴", desBgScaleX=0.9, desBgX=152, desBgY=100,
			des="每周二、周五、周日开放", desSize=cc.size(283, 100), desX=152, desY=100,
		},
		{
			bgSize=cc.size(305, 415), brightSize=cc.size(287, 401) , sprShow="Image/Relics_Img4.png",
			title="神秘地带", titleX=152, titleY=445,
			desBg="#WarriorsCenter_Spr7.png", desBgScaleX=0.9, desBgX=152, desBgY=100,
			des="有机会探测到人物，金币或者战车材料", desSize=cc.size(283, 100), desX=152, desY=400,
		},
	}
	local function BtnOnPressed(event)
		local nTag = event.target:getTag()
		if nil~=self.sprBright[nTag] then
			self.sprBright[nTag]:setVisible(true)
		end
	end

	local function BtnOnRelease(event)
		local nTag = event.target:getTag()
		if nil~=self.sprBright[nTag] then
			self.sprBright[nTag]:setVisible(false)
		end
	end

	local function BtnOnClicked(event)
		local nTag = event.target:getTag()
		local strBlockType = tostring(ChildModule[nTag].blockType)
		if "7"==strBlockType then 	--随机探测副本
            if g_WarriorsCenterMgr.relicsData.blockId>0 then
                self:showTipBox()
            else
            	if srv_userInfo.vip<5 then
            		showTips("vip等级5级开放")
            		return
                elseif g_WarriorsCenterMgr.relicsData["7"]<=0 then
                    showTips("今日探测次数已用完。")
                    return
                end
                showMessageBox("是否消耗一次探测次数，开启遗迹探测？", function()
                g_WarriorsCenterMgr:ReqDetect()
                self:SetLevChooseVisible(false)
                startLoading()
                end)
            end

		else
			if g_WarriorsCenterMgr.relicsData[strBlockType]>0 then
				self.nCurChildModule = nTag
				self:SetLevChooseVisible(true)
			end
		end
	end

	local frame
	local listView = self.blockList
	for i=1, #tmpCfg do
		local item = listView:newItem()
        local content = display.newNode()
		--底框
		frame = display.newScale9Sprite("#WarriorsCenter_Frame1.png", nil, nil, tmpCfg[i].bgSize)
					:align(display.CENTER, 0, 30)
					:addTo(content)
		tmpSize = frame:getContentSize()
		tmpCx = tmpSize.width/2
		tmpCy = tmpSize.height/2
		--展示图片
		self.sprFilter[i] = display.newGraySprite(tmpCfg[i].sprShow)
								:scale(0.9)
								:align(display.CENTER, tmpCx, tmpCy)
								:addTo(frame)
		--亮框
		self.sprBright[i] = display.newScale9Sprite("#WarriorsCenter_Frame2.png", nil, nil, tmpCfg[i].brightSize)
								:align(display.CENTER, tmpCx, tmpCy)
								:addTo(frame, 1)
		self.sprBright[i]:setVisible(false)
		--按钮
		tmpNode = cc.ui.UIPushButton.new()
					:align(display.CENTER, tmpCx, tmpCy)
					:addTo(frame)
		tmpNode:setTouchSwallowEnabled(false)
		tmpNode:setTag(i)
		tmpNode:setContentSize(tmpCfg[i].bgSize)
		tmpNode:onButtonPressed(BtnOnPressed)
			   :onButtonRelease(BtnOnRelease)
			   :onButtonClicked(BtnOnClicked)
		if i==1 then
			self.guideBtn1 = tmpNode
		end

		--标题背景
		display.newSprite("#WarriorsCenter_Spr6.png")
			:align(display.CENTER, tmpCfg[i].titleX, tmpCfg[i].titleY)
			:addTo(frame, 1)

		--标题
		
		display.newTTFLabel{text = tmpCfg[i].title,color = cc.c3b(95,255,250),size = 30}
			:align(display.CENTER, tmpCfg[i].titleX, tmpCfg[i].titleY-10)
			:addTo(frame, 1)

		--描述背景
		-- local desBg = display.newSprite(tmpCfg[i].desBg)
		-- 				:align(display.CENTER, tmpCfg[i].desBgX, tmpCfg[i].desBgY-180)
		-- 				:addTo(frame)
		-- desBg:setScaleX(tmpCfg[i].desBgScaleX)

		--描述
		local lab = display.newTTFLabel({
				text=tmpCfg[i].des,
				size=24,
				color=cc.c3b(186, 217, 212),
				align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				dimensions = tmpCfg[i].desSize,
			})
			:align(display.CENTER, tmpCfg[i].desX, tmpCfg[i].desY-155)
			:addTo(frame)
        if g_isBanShu then
            lab:setVisible(false)
        end

		--剩余挑战次数
		self.labLeft[i] = display.newTTFLabel({
							text="剩余挑战次数：0",
							size=24,
							color=cc.c3b(232, 56, 40),
							align = cc.TEXT_ALIGNMENT_CENTER,
			                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						})
						:align(display.CENTER, tmpCfg[i].desX, tmpCfg[i].desY-195)
						:addTo(frame)


		if 7==ChildModule[i].blockType then 	--随机探测
			self.labLeft[i]:setString("剩余探测次数：0")
			self.labLeft[i]:align(display.CENTER, tmpCfg[i].desX, tmpCfg[i].desBgY-180)

			-- self.btnDetect = cc.ui.UIPushButton.new({normal="common/commonBt1_1.png", pressed="common/commonBt1_2.png"}, {grayState=true})
			-- 			        :setButtonLabel(cc.ui.UILabel.new({text = "探测", size = 40, color = cc.c3b(254, 248, 126)}))
			-- 			        :align(display.CENTER, tmpCx, 50)
			-- 			        :scale(0.6)
			-- 			        :addTo(frame)
			-- 			        :onButtonClicked(function(event)
			-- 			        	local nNeedVip = g_VIPMgr:GetNeedVip(VIP_PRIVATE_RELICSDETECT)
			-- 			    		if srv_userInfo["vip"]<nNeedVip then
			-- 			    			showTips("VIP" .. nNeedVip .. "开放")
			-- 			    		else
			-- 			    			self.nCurChildModule = i
			-- 							self:SetLevChooseVisible(true)
			-- 			    		end
			-- 			        end)
			-- self.btnDetect:setButtonEnabled(false)
        end

        if 7 ~= ChildModule[i].blockType and srv_userInfo["vip"] >= ResetVipLimit then
            self.resetButton[i] = cc.ui.UIPushButton.new({normal="common/commonBt1_1.png", pressed="common/commonBt1_2.png"}, {grayState=true})
                                :setButtonLabel(cc.ui.UILabel.new({text = "重置", size = 40, color = cc.c3b(254, 248, 126)}))
                                :align(display.CENTER, tmpCx, 50)
                                :scale(0.6)
                                :addTo(frame)
                                :onButtonClicked(function(event)
                                    showMessageBox("是否花费100钻石重置挑战次数？",function ( ... )
                                    	self:sendResetRelics()
                                    	DCEvent.onEvent("遗迹探测重置")
                                    end)
                                end)
            self.resetButton[i]:setVisible(false)
		end

		item:addContent(content)
        item:setItemSize(320, 550)
        listView:addItem(item)
	end
	listView:reload()

	--遮罩层
	self.maskLayer = UIMasklayer.new()
						:addTo(self)
	self.maskLayer:setVisible(false)
	self.maskLayer:setOnTouchEndedEvent(function()
		self.levChoosePanel:setVisible(false)
	end)

	--难度选择面板
	self:GenerateLevChoose()

end

function RelicsLayer:showTipBox()
    local masklayer =  UIMasklayer.new()
    :addTo(self)
    --提示框
    local decomposeBox = display.newScale9Sprite("common/common_Frame4.png",display.cx, 
        display.cy,
        cc.size(500, 150),cc.rect(20, 20, 63, 61))
    :addTo(masklayer)
    masklayer:addHinder(decomposeBox)

    --重新探测
    cc.ui.UIPushButton.new({
        normal = "common/commonBt1_1.png",
        pressed = "common/commonBt1_2.png"
        })
    :addTo(decomposeBox)
    :pos(120, decomposeBox:getContentSize().height/2)
    :onButtonClicked(function(event)
        if g_WarriorsCenterMgr.relicsData["7"]<=0 then
            showTips("今日探测次数已用完。")
            return
        end
        showMessageBox("是否消耗一次探测次数，开启遗迹探测？", function()
                g_WarriorsCenterMgr:ReqDetect()
                self:SetLevChooseVisible(false)
                startLoading()
            end)
        end)
    :setButtonLabel(cc.ui.UILabel.new({text = "重新探测", size = 25, color = cc.c3b(255, 255, 0)}))

    --上次探测
    cc.ui.UIPushButton.new({
        normal = "common/commonBt1_1.png",
        pressed = "common/commonBt1_2.png"
        })
    :addTo(decomposeBox)
    :pos(decomposeBox:getContentSize().width - 120, decomposeBox:getContentSize().height/2)
    :onButtonClicked(function(event)
        local strBlockType, i = "7", 4
        local nTimes = g_WarriorsCenterMgr.relicsData[strBlockType]
        BlockUI.new(g_WarriorsCenterMgr.relicsData.blockId, nTimes)
        :addTo(display.getRunningScene(),51)
        FightSceneEnterType = EnterTypeList_2.RELICS_ENTER
        end)
    :setButtonLabel(cc.ui.UILabel.new({text = "上轮探测", size = 25, color = cc.c3b(255, 255, 0)}))
end

function RelicsLayer:sendResetRelics()
    if srv_userInfo.diamond < ResetCost then
        showTips("钻石不足")
        return
    end
    local sendData = {}
    m_socket:SendRequest(json.encode(sendData), CMD_RELICS_RESET, self, self.afterGetReset)
end

function RelicsLayer:afterGetReset(cmd)
    if cmd.result == 1 then
        local strBlockType, nTimes
        g_WarriorsCenterMgr.relicsData[tostring(self.curResetType)] = 3
        g_WarriorsCenterMgr.relicsData["buyExCnt"] = g_WarriorsCenterMgr.relicsData["buyExCnt"] + 1
        self:RefreshUI()
    else
        showTips(cmd.msg)
    end
end

--难度选择面板
function RelicsLayer:GenerateLevChoose()
	self.levChoosePanel = display.newScale9Sprite("common2/com2_Img_3.png",nil,nil,cc.size(800,320),cc.rect(119, 127, 1, 1))
							:align(display.CENTER, display.cx, display.cy)
							:addTo(self)
	self.levChoosePanel:setVisible(false)
	self.maskLayer:addHinder(self.levChoosePanel)

	local tmpNode
	local tmpSize = self.levChoosePanel:getContentSize()
	local tmpCx = tmpSize.width/2
	local tmpCy = tmpSize.height/2

	-- display.newSprite("#WarriorsCenter_Frame8.png")
	-- 		:align(display.CENTER, tmpCx, tmpSize.height-70)
	-- 		:addTo(self.levChoosePanel)
	display.newTTFLabel{text = "难度选择",size = 35,color = cc.c3b(95,255,250)}
			:align(display.CENTER, tmpCx, tmpSize.height-70)
			:addTo(self.levChoosePanel)
	display.newSprite("#WarriorsCenter_Spr1.png")
			:align(display.CENTER, tmpCx-320, 130)
			:addTo(self.levChoosePanel)
	tmpNode = display.newSprite("#WarriorsCenter_Spr1.png")
				:align(display.CENTER, tmpCx+320, 130)
				:addTo(self.levChoosePanel)
	tmpNode:setScaleX(-1)

	--难度列表
    self.levList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(100, 50, 600, 160),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        }
        :addTo(self.levChoosePanel)
    self:InitLevChoose()
end

--显示难度选择面板
function RelicsLayer:SetLevChooseVisible(bVisible)
	if nil==bVisible then
		return
	end
	self.maskLayer:setVisible(bVisible)
	self.levChoosePanel:setVisible(bVisible)
end

function RelicsLayer:InitLevChoose()
	local listView = self.levList
    listView:removeAllItems()   --清空

    local levLimit = {20, 35, 50, 70, 80}

    local function BtnOnPressed(event)
    	event.target:setScale(0.9)
    end

    local function BtnOnRelease(event)
    	event.target:setScale(1)
    end

    local function BtnOnClicked(event)
    	local nTag = event.target:getTag()
    	local nLevLimit = levLimit[nTag]
    	if srv_userInfo.level>=nLevLimit then
    		if 7==ChildModule[self.nCurChildModule].blockType then
    			g_WarriorsCenterMgr:ReqDetect()
    			self:SetLevChooseVisible(false)
    			startLoading()
    		else
	    		local nBlock = nil 	 	--挑战关卡ID
	    		print("srv_userInfo.mainline: "..srv_userInfo.mainline)
	    		if 0==srv_userInfo.mainline or 1==srv_userInfo.mainline then
	    			nBlock = ChildModule[self.nCurChildModule].beginGoodBlock+(nTag-1)*1000
	    		else
	    			nBlock = ChildModule[self.nCurChildModule].beginEvilBlock+(nTag-1)*1000
	    		end
                strBlockType = tostring(ChildModule[self.nCurChildModule].blockType)
                nTimes = g_WarriorsCenterMgr.relicsData[strBlockType]
	    		BlockUI.new(nBlock,nTimes)
    			:addTo(display.getRunningScene(),51)
    			FightSceneEnterType = EnterTypeList_2.RELICS_ENTER
    			print("nBlock: "..nBlock)
    			
	    	end
    	else
    		showTips("战队"..nLevLimit.."级开放")
    	end
    end


	local tmpPath
    for i=1, 5 do
    	local item = listView:newItem()
    	local content = display.newNode()

        tmpPath = string.format("#WarriorsCenter_Frame%d.png", 2+i)
        local btn = cc.ui.UIPushButton.new(tmpPath)
    					:addTo(content)
    					:onButtonPressed(BtnOnPressed)
    					:onButtonRelease(BtnOnRelease)
    					:onButtonClicked(BtnOnClicked)
        btn:setTag(i)
        btn:setTouchSwallowEnabled(false)
        if i==1 then
        	self.guideBtn2 = btn
        end

        tmpPath = string.format("#WarriorsCenter_TextDL%d.png", i)
        display.newSprite(tmpPath)
        	:addTo(content)

        --添加content
        item:addContent(content)
        item:setItemSize(200, 160)
        listView:addItem(item)
    end
    listView:reload()
end

--刷新界面
function RelicsLayer:RefreshUI()
	if nil==g_WarriorsCenterMgr.relicsData then
		return
	end

	local filters = filter.newFilter("GRAY")
	local strBlockType, nTimes
	for i=1, #ChildModule do
		strBlockType = tostring(ChildModule[i].blockType)
		nTimes = g_WarriorsCenterMgr.relicsData[strBlockType]

		if "7"==strBlockType then 	--随机探测
            self.sprFilter[i]:clearFilter()
			self.labLeft[i]:setString("剩余探测次数：" .. nTimes)
			-- if -1~=g_WarriorsCenterMgr.relicsData.blockId then
			-- 	self.sprFilter[i]:clearFilter()
			-- 	-- self.btnDetect:setVisible(false)
			-- else
			-- 	self.sprFilter[i]:setFilter(filters)
			-- 	-- self.btnDetect:setVisible(true)
			-- end

			--探测按钮
			-- if g_WarriorsCenterMgr.relicsData[strBlockType]<=0 then
			-- 	self.btnDetect:setButtonEnabled(false)
			-- else
			-- 	self.btnDetect:setButtonEnabled(true)
			-- end
		else
			self.labLeft[i]:setString("剩余挑战次数：" .. nTimes)
			if nTimes>0 then
				self.sprFilter[i]:clearFilter()
                if srv_userInfo["vip"] >= ResetVipLimit and self.curResetType == ChildModule[i].blockType then
                    self.labLeft[i]:setVisible(true)
                    self.resetButton[i]:setVisible(false)
                end
			else
				self.sprFilter[i]:setFilter(filters)
                if srv_userInfo["vip"] >= ResetVipLimit and (self.curResetType ==0 or self.curResetType == ChildModule[i].blockType) and g_WarriorsCenterMgr.relicsData["buyExCnt"] <= 0 then
                    self.labLeft[i]:setVisible(false)
                    self.resetButton[i]:setVisible(true)
                end
			end
		end
	end
end

--初始化遗迹信息返回
function RelicsLayer:OnInitRelicsRet(cmd)
	endLoading()
	if 1==cmd.result then
        self.curResetType = g_WarriorsCenterMgr.relicsData["type"]
		self:RefreshUI()
	else
		showTips(cmd.msg)
	end
end

--随机探测返回
function RelicsLayer:OnDetectRet(cmd)
	if 1==cmd.result then
		-- local filters = filter.newFilter("GRAY")
		local strBlockType, i = "7", 4
		local nTimes = g_WarriorsCenterMgr.relicsData[strBlockType]

		self.labLeft[i]:setString("剩余探测次数：" .. nTimes)
		-- if -1~=g_WarriorsCenterMgr.relicsData.blockId then
		-- 	self.sprFilter[i]:clearFilter()
		-- else
		-- 	self.sprFilter[i]:setFilter(filters)
		-- end

		-- self.btnDetect:setVisible(false)
		--探测按钮
		-- if g_WarriorsCenterMgr.relicsData[strBlockType]<=0 then
		-- 	self.btnDetect:setButtonEnabled(false)
		-- else
		-- 	self.btnDetect:setButtonEnabled(true)
		-- end
        BlockUI.new(g_WarriorsCenterMgr.relicsData.blockId, nTimes)
        :addTo(display.getRunningScene(),51)
        FightSceneEnterType = EnterTypeList_2.RELICS_ENTER
	else
		showTips(cmd.msg)
	end
end

function RelicsLayer:onEnter()
	MainSceneEnterType = EnterTypeList.NORMAL_ENTER
	g_WarriorsCenterMgr:ReqInitRelics()
	startLoading()
end

function RelicsLayer:onExit()
	RelicsLayer.Instance = nil
end

return RelicsLayer