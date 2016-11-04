-- 乘降
-- Author: Jun Jiang
-- Date: 2015-06-12 11:48:11
--
local DriveLayer = class("DriveLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)
DriveLayer.Instance = nil
DriveLayer.srv_Data = nil 	--服务器返回数据

function DriveLayer:ctor()
	--资源加载
	display.addSpriteFrames("Image/UIDrive.plist", "Image/UIDrive.png")

	self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

	--返回按钮
    self.backBtn = cc.ui.UIPushButton.new({normal="common/common_BackBtn_1.png",pressed="common/common_BackBtn_2.png"})
        :align(display.LEFT_TOP, 0, display.height )
        :addTo(self)
        :onButtonClicked(function(event)
            --主界面乘降红点
            local flag = false
            local flag2 = false
	        for i,value in ipairs(self.srv_Data.members) do
	            if value.carTmpId==0 then
	                flag = true
	                break
	            end
	        end
	        for i,value in ipairs(self.srv_Data.cars) do
	            if value.carMember.memberId==0 then
	                flag2 = true
	                break
	            end
	        end
	        local node = MainScene_Instance.roleMenuBar.chengjiangBt
	        if flag and flag2 then
	            local RedPt = display.newSprite("common/common_RedPoint.png")
	            :addTo(node,0,10)
	            :pos(40,40)
	        else
	        	node:removeChildByTag(10)
	        end
	        GuideManager:removeGuideLayer()
	        local _scene = cc.Director:getInstance():getRunningScene()
        	_scene:addGuide_ani(10501)
            self:removeFromParent()
        end)

	-- --横线
	-- local points = {{display.cx-300, display.cy+270}, {display.cx+300, display.cy+270}}
	-- local lineParmas = {borderColor = cc.c4f(1, 0.9, 0.5, 1.0), borderWidth = 3}
	-- display.newLine(points, lineParmas)
	-- 	:addTo(self)

	-- --左斜线
	-- points = {{display.cx-300, display.cy+270}, {display.cx-400, display.cy+200}}
	-- display.newLine(points, lineParmas)
	-- 	:addTo(self)

	-- --右斜线
	-- points = {{display.cx+300, display.cy+270}, {display.cx+400, display.cy+200}}
	-- display.newLine(points, lineParmas)
	-- 	:addTo(self)

	-- --竖线
	-- lineParmas.borderWidth = 4
	-- points = {{display.cx, display.cy+270}, {display.cx, display.cy+200}}
	-- display.newLine(points, lineParmas)
	-- 	:addTo(self)

	--标题
	display.newSprite("#Drive2_img1.png")
		:align(display.CENTER, display.cx, display.cy+270)
		:addTo(self)

	-- display.newSprite("#Drive_Text1.png")
	-- 	:align(display.CENTER, display.cx, display.cy+270)
	-- 	:addTo(self)

	local function BtnOnClicked(event)
		local nTag = event.target:getTag()
		local nMemIndex = math.floor(nTag/10)
		local nOPType = nTag%10

		local tab = self.srv_Data.members[nMemIndex]
		if nil==tab then
			showTips("无驾驶员")
			return
		end
		GuideManager:hideGuideEff()
		if 1==nOPType then 		--上车
			local carlist = g_CarListLayer.new({opMem=tab.id, ignoreCar=tab.carId, openTag=OpenBy_Drive})
				:addTo(self, 10)
			

		elseif 2==nOPType then 	--下车
			if 0==tab.carTmpId then
				showTips("无法空车下乘")
			else
				CarManager:ReqUpdateCarMember(0, tab.id)
    			startLoading()
			end
		end
	end

	--人物面板
	local tmpNode, tmpSize, tmpCx, tmpCy
	self.sprRole = {}
	self.sprProf = {}
	self.sprProfName = {}
	self.sprCar = {}
	self.bg = {}
	self.upBt = {}
	--属性
	self.shuxingBg = {}
	self.SXcri = {}
	self.SXcriNum = {}
	self.SXhit = {}
	self.SXhitNum = {}
	self.SXmiss = {}
	self.SXmissNum = {}
	self.proAdd1 = {}
	self.proAdd1Num = {}
	self.proAdd2 = {}
	self.proAdd2Num = {}
	for i=1, 3 do
		--背景框
		tmpSize = cc.size(379, 542)
		tmpCx = tmpSize.width/2
		tmpCy = tmpSize.height/2
		self.bg[i] = display.newSprite("#Drive2_img3.png")
						:align(display.CENTER, display.cx-400+(i-1)*400, display.cy-60)
						:addTo(self)

		--人物背景
		-- display.newSprite("#Drive_Spr1.png")
		-- 	:align(display.CENTER, tmpCx, tmpCy+120)
		-- 	:addTo(self.bg[i])

		--人物图标
		self.sprRole[i] = display.newSprite("#Drive_Spr2.png")
							:align(display.CENTER, tmpCx, tmpCy+190)
							:addTo(self.bg[i])
							:scale(0.7)

		--职业图标
		self.sprProf[i] = display.newSprite("#Drive2_img2.png")
							:align(display.CENTER, tmpCx+70, tmpCy+130)
							:addTo(self.bg[i])
		self.sprProf[i]:setVisible(false)
		self.sprProfName[i] = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
		:addTo(self.sprProf[i])
		:align(display.CENTER, self.sprProf[i]:getContentSize().width/2+5, self.sprProf[i]:getContentSize().height/2-5)

		--战车背景
		-- display.newSprite("#Drive_Spr3.png")
		-- 	:align(display.CENTER, tmpCx, tmpCy-90)
		-- 	:addTo(self.bg[i])

		--战车图标
		self.sprCar[i] = display.newSprite("#Drive_Spr2.png")
							:align(display.CENTER, tmpCx+20, tmpCy-50)
							:addTo(self.bg[i])

		--属性底图
		self.shuxingBg[i] = display.newSprite("#Drive2_img4.png")
		:addTo(self.bg[i], 2)
		:pos(tmpCx+17, tmpCy-130)
		self.shuxingBg[i]:setVisible(false)

		--属性（暴击、命中、闪避）
		self.SXcri[i] = cc.ui.UILabel.new({UILabelType = 2, text = "暴击：", size = 18, color = cc.c3b(164, 255, 255)})
		:addTo(self.shuxingBg[i])
		:pos(8,55)
		self.SXcriNum[i] = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(46, 255, 130)})
		:addTo(self.shuxingBg[i])
		:pos(self.SXcri[i]:getPositionX()+self.SXcri[i]:getContentSize().width,self.SXcri[i]:getPositionY())

		self.SXhit[i] = cc.ui.UILabel.new({UILabelType = 2, text = "命中：", size = 18, color = cc.c3b(164, 255, 255)})
		:addTo(self.shuxingBg[i])
		:pos(8,35)
		self.SXhitNum[i] = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(46, 255, 130)})
		:addTo(self.shuxingBg[i])
		:pos(self.SXhit[i]:getPositionX()+self.SXhit[i]:getContentSize().width,self.SXhit[i]:getPositionY())

		self.SXmiss[i] = cc.ui.UILabel.new({UILabelType = 2, text = "闪避：", size = 18, color = cc.c3b(164, 255, 255)})
		:addTo(self.shuxingBg[i])
		:pos(8,12)
		self.SXmissNum[i] = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(46, 255, 130)})
		:addTo(self.shuxingBg[i])
		:pos(self.SXmiss[i]:getPositionX()+self.SXmiss[i]:getContentSize().width,self.SXmiss[i]:getPositionY())
		

		self.proAdd1[i] = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = cc.c3b(164, 255, 255)})
		:addTo(self.shuxingBg[i])
		:pos(self.shuxingBg[i]:getContentSize().width/2+15, 50)
		self.proAdd1Num[i] = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(46, 255, 130)})
		:addTo(self.shuxingBg[i])

		self.proAdd2[i] = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = cc.c3b(164, 255, 255)})
		:addTo(self.shuxingBg[i])
		:pos(self.shuxingBg[i]:getContentSize().width/2+15, 20)
		self.proAdd2Num[i] = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(46, 255, 130)})
		:addTo(self.shuxingBg[i])

		--上车按钮
		self.upBt[i] = cc.ui.UIPushButton.new("common/common_nBt2.png")
			    	:align(display.CENTER, tmpCx-85, 50)
			    	:addTo(self.bg[i])
			    	:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "选车", size = 27, 
						color = cc.c3b(127, 79, 33)}))
					:onButtonPressed(function(event) event.target:setScale(0.95) end)
					:onButtonRelease(function(event) event.target:setScale(1.0) end)
			    	:onButtonClicked(BtnOnClicked)
			    	setLabelStroke(self.upBt[i]:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)
		if i==1 then
			self.guideBtn = self.upBt[i]
		end
		self.upBt[i]:setTag(i*10+1)

		--下车按钮
		tmpNode = cc.ui.UIPushButton.new("common/common_nBtG.png")
			    	:align(display.CENTER, tmpCx+85, 50)
			    	:addTo(self.bg[i])
			    	:setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "下车", size = 25, 
						color = cc.c3b(55, 63, 56)}))
					:onButtonPressed(function(event) event.target:setScale(0.95) end)
					:onButtonRelease(function(event) event.target:setScale(1.0) end)
			    	:onButtonClicked(BtnOnClicked)
			    	setLabelStroke(tmpNode:getButtonLabel(),27,cc.c3b(178, 252, 161),1,nil,nil,nil,nil, true)
	    tmpNode:setTag(i*10+2)
	end
	GuideManager:_addGuide_2(10402, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
end

function DriveLayer:ReqInitData()
	local tabMsg = {characterId=srv_userInfo["characterId"]}
    m_socket:SendRequest(json.encode(tabMsg), CMD_DRIVE_INFO,g_DriveLayer.Instance, g_DriveLayer.Instance.OnInitDataRet)
    startLoading()
end

function DriveLayer:OnInitDataRet(cmd)
	if 1==cmd.result then
		self.srv_Data = cmd.data
		self:Sort()
		self:RefreshUI()
	else
		showTips(cmd.msg)
	end
	endLoading()
end

--人物排序
function DriveLayer:Sort()
	if nil==self.srv_Data then
		return
	end

	local function SortFunc(val1, val2)
		return val1.id<val2.id
	end
	table.sort(self.srv_Data.members, SortFunc)
end

--刷新界面
function DriveLayer:RefreshUI()
	if nil==self.srv_Data then
		return
	end

	local tab = self.srv_Data.members
	local tmpPath, resId
	local tmpSize = self.bg[1]:getContentSize()
	local tmpCx = tmpSize.width/2
	local tmpCy = tmpSize.height/2
	for i=1, #tab do
		resId = string.sub(tab[i].tmpId, 1, 4)
		tmpPath = string.format("HalfBody/halfbody_%s_win.png", resId)
		self.sprRole[i]:setTexture(tmpPath)
		self.sprRole[i]:align(display.CENTER_BOTTOM, tmpCx, tmpCy+115)
		self.sprProf[i]:setVisible(true)
		local mtype = string.sub(tab[i].tmpId, 1, 3)
		if mtype=="101" or mtype=="102" then
			self.sprProfName[i]:setString("坦克手")
		elseif mtype=="103" then
			self.sprProfName[i]:setString("机械师")
		elseif mtype=="104" then
			self.sprProfName[i]:setString("格斗家")
		end
		

		self.sprCar[i]:removeFromParent()
		self.sprCar[i] = nil

		local node = self.upBt[i]
		if 0~=tab[i].carTmpId then
			self.sprCar[i] = ShowModel.new({modelType=ModelType.Tank, templateID=tab[i].carTmpId})
								:pos(tmpCx, tmpCy-110)
								:addTo(self.bg[i])
			SetModelParams(self.sprCar[i], {fScale=0.5})
			node:removeChildByTag(10)

			self.shuxingBg[i]:setVisible(true)
			local tmp = string.format("%.2f%%", tab[i].cri/10)
			self.SXcriNum[i]:setString("+"..tmp)
			local tmp = string.format("%.2f%%", tab[i].hit/10)
			self.SXhitNum[i]:setString("+"..tmp)
			local tmp = string.format("%.2f%%", tab[i].miss/10)
			self.SXmissNum[i]:setString("+"..tmp)

			local tmpStr,tmpNum  = self:proLevelData(tab[i].tmpId, tab[i].proLevel)
			self.proAdd1[i]:setString(tmpStr[1])
			self.proAdd2[i]:setString(tmpStr[2])
			self.proAdd1Num[i]:pos(self.proAdd1[i]:getPositionX()+self.proAdd1[i]:getContentSize().width,
				self.proAdd1[i]:getPositionY())
			self.proAdd2Num[i]:pos(self.proAdd2[i]:getPositionX()+self.proAdd2[i]:getContentSize().width,
				self.proAdd2[i]:getPositionY())
			if type(tmpNum[1])=="number" then
				self.proAdd1Num[i]:setString("+"..tmpNum[1].."%")
				self.proAdd2Num[i]:setString("+"..tmpNum[2].."%")
			end
			
		else
			-- self.sprCar[i] = display.newSprite("#Drive_Text2.png")
			self.sprCar[i] = cc.ui.UILabel.new({UILabelType = 2, text = "暂 无 乘 车", size = 35, color = cc.c3b(146, 255, 255)})
								:align(display.CENTER, tmpCx, tmpCy-50)
								:addTo(self.bg[i])

			local flag2 = false
			for i,value in ipairs(self.srv_Data.cars) do
	            if value.carMember.memberId==0 then
	                flag2 = true
	                break
	            end
	        end
	        if flag2 then
	        	local RedPt = display.newSprite("common/common_RedPoint.png")
	            :addTo(node,0,10)
	            :pos(67,30)
	        else
	        	node:removeChildByTag(10)
	        end

	        self.shuxingBg[i]:setVisible(false)
		end
	end
end

--职业养成加成
function DriveLayer:proLevelData(menTmpId, proLevel)

	local loc_MemData = memberData[menTmpId]
	local nCurProLev = proLevel
	--当前职业的职业养成数据
	local curProfDevData = {}
	for key,value in pairs(profDevData) do
		if value.type==loc_MemData.proType then
			curProfDevData[value.level] = value
		end
	end

	--底座加成
	local tmpStr = {"", ""}
	local tmpNum = {"", ""}
	local nIdx
	nIdx = 0
	local curLev_proDevData = curProfDevData[nCurProLev]
	if curLev_proDevData.hp2~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "血量："
		tmpNum[nIdx] = (curLev_proDevData.hp2*100)
	end
	if curLev_proDevData.mainAtk~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "主炮："
		tmpNum[nIdx] = (curLev_proDevData.mainAtk*100)
	end
	if curLev_proDevData.subAtk~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "副炮："
		tmpNum[nIdx] = (curLev_proDevData.subAtk*100)
	end
	if curLev_proDevData.defense2~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "防御："
		tmpNum[nIdx] = (curLev_proDevData.defense2*100)
	end
	if curLev_proDevData.cri2~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "暴击："
		tmpNum[nIdx] = (curLev_proDevData.cri2*100)
	end
	if curLev_proDevData.hit2~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "命中："
		tmpNum[nIdx] = (curLev_proDevData.hit2*100)
	end
	if curLev_proDevData.miss2~=0 then
		nIdx = nIdx + 1
		tmpStr[nIdx] = "避闪："
		tmpNum[nIdx] = (curLev_proDevData.miss2*100)
	end

	return tmpStr,tmpNum
end

function DriveLayer:OnUpdateCarMemberRet(cmd)
	endLoading()
	if 1==cmd.result then
		
		GuideManager:_addGuide_2(10404, cc.Director:getInstance():getRunningScene(),handler(self,self.caculateGuidePos))
		if nil~=g_CarListLayer.Instance then
			g_CarListLayer.Instance:removeFromParent()
		end
		self:ReqInitData()
	else
		showTips(cmd.msg)
	end
end

function DriveLayer:onEnter()
	DriveLayer.Instance = self

	self:ReqInitData()
end

function DriveLayer:onExit()
	DriveLayer.Instance = nil

	--资源释放
	display.removeSpriteFramesWithFile("Image/UIDrive.plist", "Image/UIDrive.png")
end

function DriveLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10402 ==_guideId or 10404==_guideId then
    	if 10402==_guideId then
    		g_node = self.guideBtn
    	elseif 10404==_guideId then
    		g_node = self.backBtn
    	end
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 10404==_guideId then
    		midPos = g_node:convertToWorldSpace(cc.p(size.width/2,-size.height/2))
    	end
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

return DriveLayer