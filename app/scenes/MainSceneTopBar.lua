
local MainSceneTopBar = class("MainSceneTopBar", function()
	return display.newNode()
	end)

--点金手需要的钻石
local needDiamondList = {
	10,
	20,
	20,
	20,
	40,
	40,
	40,
	100,
	100,
	100,
	200,
	200,
	200,
	400,
	400,
	400,
	800,
	800,
	800,
	1600
}
local butGoldCostDiamond
local goldNum
local diamondNum

function MainSceneTopBar:ctor()
	--底条
	local TopBar = display.newSprite("#MainUI_img1.png")
	:addTo(self)
	:align(display.TOP_RIGHT, display.width, display.height)
	local tmpsize = TopBar:getContentSize()
 	--金币条
 	self.goldIcon = display.newSprite("common/common_Gold.png")
 	:addTo(TopBar)
 	:pos(0, tmpsize.height/2)
 	:scale(0.7)
 	self.goldAdd = cc.ui.UIPushButton.new("common/common_add1.png")
 	:addTo(TopBar)
 	:pos(tmpsize.width - 490, tmpsize.height/2)
 	:onButtonPressed(function(event) event.target:setScale(1.1) end)
 	:onButtonRelease(function(event) event.target:setScale(1.0) end)
 	:onButtonClicked(function(event)
 		addGold()
 		DCEvent.onEvent("点击点金手")
 		end)
 	--钻石条
 	self.DiaIcon = display.newSprite("common/common_Diamond.png")
 	:addTo(TopBar)
 	:pos(0, tmpsize.height/2)
 	:scale(0.7)
 	self.diamondAdd = cc.ui.UIPushButton.new("common/common_add1.png")
 	:addTo(TopBar)
 	:pos(tmpsize.width - 270, tmpsize.height/2)
 	:onButtonPressed(function(event) event.target:setScale(1.1) end)
 	:onButtonRelease(function(event) event.target:setScale(1.0) end)
 	:onButtonClicked(function(event)
 		if rechargeLayer.Instance==nil then
 			g_recharge.new()
			:addTo(display.getRunningScene(),49)
			DCEvent.onEvent("点击加钻石")
 		end
 		
 		end)
 	--燃油条
 	function showTili()
 		self.tiliBox = nil
 		self.tiliBox = display.newSprite("common/showTiliBox.png")
 		:addTo(display.getRunningScene(),55)
 		:pos(display.width-240, display.height - 130)
 		local text1 = cc.ui.UILabel.new({UILabelType = 2, text = "购买燃油次数：", size = 22})
 		:addTo(self.tiliBox)
 		:pos(20,95)
 		text1:setColor(MYFONT_COLOR)
 		local num = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 22})
 		:addTo(self.tiliBox)
 		:pos(20+text1:getContentSize().width,95)
 		num:setColor(cc.c3b(0, 255, 0))
 		num:setString(srv_userInfo.eBuyCnt.."/"..vipLevelData[srv_userInfo.vip].energyCnt)
 		local text2 = cc.ui.UILabel.new({UILabelType = 2, text = "燃油恢复间隔：", size = 22})
 		:addTo(self.tiliBox)
 		:pos(20,60)
 		text2:setColor(MYFONT_COLOR)
 		local num = cc.ui.UILabel.new({UILabelType = 2, text = "5分钟", size = 22})
 		:addTo(self.tiliBox)
 		:pos(20+text2:getContentSize().width,60)
 		num:setColor(cc.c3b(230, 230, 50))
 		local text3 = cc.ui.UILabel.new({UILabelType = 2, text = "恢复全部燃油：", size = 22})
 		:addTo(self.tiliBox)
 		:pos(20,25)
 		text3:setColor(MYFONT_COLOR)
 		local num = cc.ui.UILabel.new({UILabelType = 2, text = "00:00:00", size = 20})
 		:addTo(self.tiliBox)
 		:pos(20+text3:getContentSize().width,25)
 		num:setColor(cc.c3b(255, 0, 0))
 		local nCurEnergy = srv_userInfo["energy"]
		local nCurLev = srv_userInfo["level"]
		local nMaxEnergy = memberLevData[nCurLev].energy
		if nCurEnergy<nMaxEnergy then
			local needMins = 5*(nMaxEnergy - nCurEnergy)
			local str = GetTimeStr(needMins*60*1000)
			num:setString(str)
		end
 	end
 	function removeTili()
 		if self.tiliBox then
 			self.tiliBox:removeSelf()
 			self.tiliBox = nil
 		end
 		
 	end
 	--燃油条
 	-- local hysicalBar = cc.ui.UIPushButton.new("common/common_goldBar.png")
 	-- :addTo(self)
 	-- :align(display.CENTER_TOP, display.width - 160,display.height - 10)
 	-- :onButtonPressed(function(event)
 		-- showTili()
 	-- 	end)
 	-- :onButtonRelease(function(event)
 	-- 	removeTili()
 	-- 	end)
 	self.hyIcon = cc.ui.UIPushButton.new("common/common_Stamina.png")
 	:addTo(TopBar)
 	:pos(0, tmpsize.height/2)
 	:scale(0.7)
 	:onButtonPressed(function(event)
 		showTili()
 		end)
 	:onButtonRelease(function(event)
 		removeTili()
 		end)
 	self.hysicalAdd = cc.ui.UIPushButton.new("common/common_add1.png")
 	:addTo(TopBar)
 	:pos(tmpsize.width - 50, tmpsize.height/2)
 	:onButtonPressed(function(event) event.target:setScale(1.1) end)
 	:onButtonRelease(function(event) event.target:setScale(1.0) end)
 	self.hysicalAdd:onButtonClicked(function(event)
 		addEnergy()
 		DCEvent.onEvent("点击购买燃油")
 	end)

 	goldNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
 	:addTo(TopBar)
 	:align(display.CENTER_RIGHT, self.goldAdd:getPositionX() - 10 , self.goldAdd:getPositionY())
 	goldNum:setAnchorPoint(1,0.5)
 	self.goldNumret = setLabelStroke(goldNum,22,nil,nil,nil,nil,nil,"fonts/slicker.ttf")

 	diamondNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
 	:addTo(TopBar)
 	:align(display.CENTER_RIGHT, self.diamondAdd:getPositionX() - 10 , self.diamondAdd:getPositionY())
 	diamondNum:setAnchorPoint(1,0.5)
 	self.diamondNumret = setLabelStroke(diamondNum,22,nil,nil,nil,nil,nil,"fonts/slicker.ttf")

 	self.hysicalNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})  --燃油数字
 	:addTo(TopBar)
 	:align(display.CENTER_RIGHT, self.hysicalAdd:getPositionX() - 10 , self.hysicalAdd:getPositionY())
 	self.hysicalNum:setAnchorPoint(1,0.5)
 	self.hysicalNumret = setLabelStroke(self.hysicalNum,22,nil,nil,nil,nil,nil,"fonts/slicker.ttf")

 	

 	self:setGlod()
 	self:setDiamond()
 	self:setEnergy()
end
--购买燃油接口
function addEnergy()
	local nCurVip = srv_userInfo["vip"]
	local nCurBuyCnt = srv_userInfo["eBuyCnt"]
	local energyCnt = vipLevelData[nCurVip].energyCnt
	local nCost = 0
	if nCurBuyCnt>=16 then
		showMessageBox("已达到最大购买次数。")
		return
	end
	nCost = energyBuyData[nCurBuyCnt+1].cdiamond
	-- if nil~=energyBuyData[nCurBuyCnt+1] then
	-- 	nNeedVip = energyBuyData[nCurBuyCnt+1].vip
	-- 	nCost = energyBuyData[nCurBuyCnt+1].cdiamond
	-- end
	print(energyCnt)
	print(nCurBuyCnt)
	if nCurBuyCnt>=energyCnt then
		showMessageBox("今日已购买燃油"..nCurBuyCnt.."次，"..
			"购买燃油次数不足，提升vip等级获得更多次数。")
		-- showTips("已达当前VIP最大购买次数")
	else
		local msg = string.format("是否花费%d钻石购买120点燃油？（今日已购买%d次）", nCost, nCurBuyCnt)
		showMessageBox(msg, handler(MainSceneTopBar, MainSceneTopBar.ReqBuyEnergy))
	end
end

function MainSceneTopBar:refreshBarData()
	self:setGlod()
	self:setDiamond()
	self:setEnergy()
end

function MainSceneTopBar:setGlod()
	srv_userInfo["gold"] = math.max(srv_userInfo["gold"],0)
	local goldStr = srv_userInfo["gold"]..""
	local length = #goldStr
	for i=1,math.floor((length-1)/3) do
		local Lstr = string.sub(goldStr, 1, length-i*3)
		local Rstr = string.sub(goldStr, length-i*3+1)
		goldStr = Lstr..","..Rstr
	end

	goldNum:setString(goldStr)
	setLabelStrokeString(goldNum, self.goldNumret)
	self.goldIcon:setPositionX(goldNum:getPositionX()-goldNum:getContentSize().width - 20)
	
	if g_ImproveLayer and g_ImproveLayer.Instance then
		g_ImproveLayer.Instance:setGoldDiamond()
	end
end
function MainSceneTopBar:setDiamond()
	srv_userInfo["diamond"] = math.max(srv_userInfo["diamond"],0)
	local diamondStr = srv_userInfo["diamond"]..""
	local length = #diamondStr
	for i=1,math.floor((length-1)/3) do
		local Lstr = string.sub(diamondStr, 1, length-i*3)
		local Rstr = string.sub(diamondStr, length-i*3+1)
		diamondStr = Lstr..","..Rstr
	end

	diamondNum:setString(diamondStr)
	setLabelStrokeString(diamondNum, self.diamondNumret)
	self.DiaIcon:setPositionX(diamondNum:getPositionX()-diamondNum:getContentSize().width - 20)

	if g_ImproveLayer and g_ImproveLayer.Instance then
		g_ImproveLayer.Instance:setGoldDiamond()
	end
end
function MainSceneTopBar:setEnergy()
	srv_userInfo["energy"] = math.max(srv_userInfo["energy"],0)
	local nCurEnergy = srv_userInfo["energy"]
	local nCurLev = srv_userInfo["level"]
	local nMaxEnergy = memberLevData[nCurLev].energy
	local tmpStr = nCurEnergy.."/"..nMaxEnergy
	self.hysicalNum:setString(tmpStr)
	setLabelStrokeString(self.hysicalNum, self.hysicalNumret)
	self.hyIcon:setPositionX(self.hysicalNum:getPositionX()-self.hysicalNum:getContentSize().width - 20)
end
function MainSceneTopBar:ReqBuyGold()
	local tabMsg = {}
	m_socket:SendRequest(json.encode(tabMsg), CMD_BUY_GOLD, self, self.onGuyGoldResult)
	startLoading()
end
function MainSceneTopBar:ReqBuyEnergy()
	if isSweepBuyEnergy then
		DCEvent.onEvent("扫荡购买燃油成功","今日第"..(srv_userInfo["eBuyCnt"]+1).."次")
	else
		DCEvent.onEvent("加号购买燃油成功","今日第"..(srv_userInfo["eBuyCnt"]+1).."次")
	end
	isSweepBuyEnergy = false
	local tabMsg = {}
	m_socket:SendRequest(json.encode(tabMsg), CMD_BUY_ENERGY, mainscenetopbar, mainscenetopbar.OnBuyEnergyRet)
	startLoading()
end

function MainSceneTopBar:OnBuyEnergyRet(cmd)
	endLoading()
	if 1==cmd.result then
		srv_userInfo["eBuyCnt"] = srv_userInfo["eBuyCnt"]+1
		local nCost = energyBuyData[srv_userInfo["eBuyCnt"]].cdiamond
		
		srv_userInfo["diamond"] = srv_userInfo["diamond"]-nCost
		SetEnergyAndCountDown(srv_userInfo["energy"]+120)

		self:setDiamond()

		--数据统计
		luaStatBuy("燃油", BUY_TYPE_ENERGY, 120, "钻石", nCost)
		DCCoin.lost("购买燃油","钻石",nCost,srv_userInfo.diamond)
	else
		showTips(cmd.msg)
	end
end
--点金手返回接口
function MainSceneTopBar:onGuyGoldResult(result)
	endLoading()
	if result.result==1 then
		local oldGold = srv_userInfo.gold
		srv_userInfo.gold = result.data.gold
		srv_userInfo["diamond"] = srv_userInfo["diamond"] - butGoldCostDiamond
		self:setGlod()
 		self:setDiamond()
 		srv_userInfo["buyGoldCnt"] = srv_userInfo["buyGoldCnt"] + 1
 		mainscenetopbar.goldLayer:removeSelf()
 		mainscenetopbar.goldLayer=nil
 		mainscenetopbar.goldLayer1:removeSelf()
 		mainscenetopbar.goldLayer1=nil
 		addGold()


 		local headLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 35, 
 			color = cc.c3b(0, 255, 0)})
 		:addTo(mainscenetopbar.goldLayer,2)
 		:align(display.CENTER_RIGHT, display.cx-30, display.cy+70)

 		local getGoldLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 35,
 			color = cc.c3b(0, 255, 0)})
 		:addTo(mainscenetopbar.goldLayer,2)
 		:align(display.CENTER_LEFT, display.cx - 30, display.cy+70)


 		local dgold = result.data.gold-oldGold
 		-- result.data.crit
 		if result.data.crit==1 then
 			headLabel:setString("金币：")
 			getGoldLabel:setString("+"..dgold)
 		else
 			headLabel:setString("暴击X"..result.data.crit.."：")
			getGoldLabel:setString("+"..dgold)
 		end
 		local moveAct = cc.MoveBy:create(2, cc.p(0, 80))
		local FadeOut = cc.FadeOut:create(3)
		local seq = transition.sequence({moveAct,
			cc.CallFunc:create(function()
				getGoldLabel:removeSelf()
				end)})
		getGoldLabel:runAction(FadeOut)
		getGoldLabel:runAction(seq)

		local moveAct = cc.MoveBy:create(2, cc.p(0, 80))
		local FadeOut = cc.FadeOut:create(3)
		local seq = transition.sequence({moveAct,
			cc.CallFunc:create(function()
				headLabel:removeSelf()
				end)})
		headLabel:runAction(FadeOut)
		headLabel:runAction(seq)

		--特效
		dImg = goldImg
		local targetNode = mainscenetopbar.goldIcon
		getGoldEff1(dImg,-45,55, targetNode)
		transition.execute(dImg,cc.DelayTime:create(0.1),
		    {onComplete = function() getGoldEff2(dImg,-45,55, targetNode) end})
		transition.execute(dImg,cc.DelayTime:create(0.2),
		    {onComplete = function() getGoldEff3(dImg,-45,55, targetNode) end})
		transition.execute(dImg,cc.DelayTime:create(0.3),
		    {onComplete = function() getGoldEff4(dImg,-45,55, targetNode) end})
		

 		--数据统计
 		luaStatBuy("金币", BUY_TYPE_GOLD, (srv_userInfo.gold-oldGold), "钻石", butGoldCostDiamond)
 		DCCoin.gain("点金手获得金币","金币",dgold,srv_userInfo.gold)
 		DCCoin.lost("点金手消耗钻石","钻石",butGoldCostDiamond,srv_userInfo.diamond)
	else
		showTips(result.msg)
	end
end

function MainSceneTopBar:OnLatestEnergyRet(cmd)
	if 1==cmd.result then
		self:setEnergy()
	else
		showTips(cmd.msg)
	end
end

function addGold()
	print(srv_userInfo["buyGoldCnt"])
	local nCurVip = srv_userInfo["vip"]
	local nCurBuyCnt = srv_userInfo["buyGoldCnt"]
	local msg = (vipLevelData[nCurVip].goldCnt-nCurBuyCnt).."/"..vipLevelData[nCurVip].goldCnt
	-- if vipLevelData[nCurVip].goldCnt>nCurBuyCnt then
	-- 	msg = "姐姐能帮你钻石变成金币哦\n当日剩余次数："..
	-- else
	-- 	msg = "今日已使用点金手"..nCurBuyCnt.."次，".."购买点金手次数不足，提升vip等级获得更多次数。"
	-- end

	if mainscenetopbar.goldLayer~=nil then
		return
	end
	mainscenetopbar.goldLayer1 = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 200))
	:addTo(display.getRunningScene(),49)
	mainscenetopbar.goldLayer = display.newLayer()
	:addTo(display.getRunningScene(),100)
	-- :pos(display.cx, display.cy)
	local goldBox = display.newSprite("SingleImg/addGold/goldBox.png")
	:addTo(mainscenetopbar.goldLayer)
	:pos(display.cx, display.cy)
	local tmpsize = goldBox:getContentSize()

	local titleBar = display.newSprite("SingleImg/addGold/addGoldImg2.png")
	:addTo(goldBox)
	:pos(tmpsize.width/2, tmpsize.height-26)
	cc.ui.UILabel.new({UILabelType = 2, text = "点金手", size =  28, color = cc.c3b(112, 213, 255)})
	:addTo(titleBar)
	:align(display.CENTER, titleBar:getContentSize().width/2, titleBar:getContentSize().height/2)

	local redBar = display.newSprite("SingleImg/addGold/addGoldImg3.png")
	:addTo(goldBox)
	:pos(tmpsize.width/2, tmpsize.height/2)

	local oldSister = display.newSprite("Bust/bust_20041.png")
	:addTo(goldBox,2)
	:pos(80, goldBox:getContentSize().height/2+68)

	local msgLabel = cc.ui.UILabel.new({UILabelType = 2, text = "姐姐能帮你钻石变成金币哦。", size = 25})
	:addTo(goldBox)
	:align(display.CENTER, tmpsize.width/2+50, tmpsize.height - 92)
	msgLabel:setColor(MYFONT_COLOR)
	if not g_isBanShu then
		cc.ui.UILabel.new({UILabelType = 2, text = "VIP等级越高，暴击几率越高", size = 25, color=cc.c3b(234, 85, 20)})
		:addTo(goldBox)
		:align(display.CENTER, tmpsize.width/2+50, tmpsize.height - 122)
	end
	

	--消耗钻石
	local dx = 100
	local dImg = display.newSprite("common/common_Diamond.png")
	:addTo(goldBox)
	:pos(100+dx,redBar:getPositionY())
	local dNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(goldBox)
	:pos(80+dImg:getContentSize().width+dx, redBar:getPositionY())
	dNum:setColor(MYFONT_COLOR)
	local bugCnt = math.min(nCurBuyCnt + 1, 20)
	butGoldCostDiamond = needDiamondList[bugCnt]
	dNum:setString(butGoldCostDiamond)
	--箭头
	local jiantou = display.newSprite("SingleImg/addGold/addGoldImg1.png")
	:addTo(goldBox)
	:pos(goldBox:getContentSize().width/2-50+dx, redBar:getPositionY())
	--生产金币
	goldImg = display.newSprite("common/common_Gold.png")
	:addTo(goldBox, 10)
	:pos(goldBox:getContentSize().width/2+10+dx,redBar:getPositionY())
	local dNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 25})
	:addTo(goldBox)
	:pos(goldBox:getContentSize().width/2-10+goldImg:getContentSize().width+dx, redBar:getPositionY())
	dNum:setColor(MYFONT_COLOR)
	local getGold = 20000+100*srv_userInfo.level+(nCurBuyCnt-1)*1280+math.floor(nCurBuyCnt/4)*1000
	dNum:setString(getGold)

	local label = cc.ui.UILabel.new({UILabelType = 2, text = "今日可用", size = 25,color=MYFONT_COLOR})
	:addTo(goldBox)
	:pos(tmpsize.width/2-100, 120)

	cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = msg, size = 25,color=MYFONT_COLOR})
	:addTo(goldBox)
	:pos(label:getPositionX()+label:getContentSize().width+5, 120)


	--确定
	local confirmBt = cc.ui.UIPushButton.new({
		normal = "common2/com2_Btn_7_up.png",
		pressed = "common2/com2_Btn_7_down.png"
		})
	:addTo(goldBox)
	:pos(tmpsize.width/2, 50)
	:onButtonClicked(function(event)
		if vipLevelData[nCurVip].goldCnt<=nCurBuyCnt then
			showTips("今日次数已用完，提高VIP等级可增加每日使用次数")
			return
		end
		mainscenetopbar:ReqBuyGold()
	end)
		
	display.newSprite("common/common_Diamond.png")
	:addTo(confirmBt)
	:pos(-36,0)
	:scale(0.8)

	cc.ui.UILabel.new({UILabelType = 2, text = "点 金", size = 28, color = cc.c3b(255, 243, 69)})
	:addTo(confirmBt)
	:pos(-5,0)

	--取消
	local cancelBt = cc.ui.UIPushButton.new({
		normal = "common2/com2_Btn_2_down.png",
		pressed = "common2/com2_Btn_2_up.png"
		})
	:addTo(goldBox)
	:pos(tmpsize.width+23, tmpsize.height-35)
	:onButtonPressed(function(event) event.target:setScale(0.95) end)
	:onButtonRelease(function(event) event.target:setScale(1.0) end)
	:onButtonClicked(function(event)
		mainscenetopbar.goldLayer:removeSelf()
		mainscenetopbar.goldLayer = nil
		mainscenetopbar.goldLayer1:removeSelf()
		mainscenetopbar.goldLayer1 = nil
		end)
end

return MainSceneTopBar
