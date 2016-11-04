--haungyuzhao
--2015,12,4,11:19

--主线任务指引
local mainLineGuide = class("mainLineGuide",function ()
	local layer = display.newNode()
    layer:setNodeEventEnabled(true)
    return layer
end)

--返回记录
MainLineToAreaId = nil
MainLineToBlockId = nil
local function getCurentGuide()
	local curBlock = tonumber(string.sub(tostring(srv_userInfo.maxBlockId), 4,8))
	if curBlock == nil then
		return nil
	end
	for k,v in pairs(mainLineGuideData)  do
		local preBlock = tonumber(string.sub(tostring(v.preParams), 4,8))
		local postBlock = tonumber(string.sub(tostring(v.postParams), 4,8))
		if curBlock>= preBlock and curBlock<postBlock then
			return v.id
		end
	end
	return nil
end

--判断是否是当前条件区间内第一次由战斗回来进入主界面
local function getIsFirstIntoMainScene(bWrite)
	if not g_isFirstIntoMainFromFight then --不是从战斗回来
		return false
	end
	local curBlock = getCurentGuide()
	local _bol = cc.UserDefault:getInstance():getStringForKey("mainLine_"..curBlock.."_"..srv_userInfo.characterId,"0")
	if _bol=="0" then
		if bWrite==true then
			cc.UserDefault:getInstance():setStringForKey("mainLine_"..curBlock.."_"..srv_userInfo.characterId,"1")
		end
		return true
	end
	return false
end

function mainLineGuide:ctor()
	local guidePos = cc.p(display.width-100,display.height*0.65)
	self.guideBtn = cc.ui.UIPushButton.new{normal = "common2/com2_Img_15.png",pressed = "common2/com2_Img_15.png"}
			:addTo(self)
			:pos(guidePos.x,guidePos.y)
			:onButtonPressed(function(event)
				event.target:setScale(0.985)
				end)
			:onButtonRelease(function(event)
				event.target:setScale(1.0)
				end)
			:onButtonClicked(handler(self,self.onBtnClick))
	display.newSprite("common2/com2_Img_16.png")
		:addTo(self.guideBtn)
		:align(display.LEFT_TOP,self.guideBtn.sprite_[1]:getContentSize().width*0.02,self.guideBtn.sprite_[1]:getContentSize().height*0.08)

	self.btnSize = self.guideBtn.sprite_[1]:getContentSize()

   	self.guideTip = display.newTTFLabel{text = "本是后山人，偶作堂前客",
	                        size = 22,
	                        color = cc.c3b(255,255,255),
	                    }
	        :addTo(self.guideBtn)
	        :align(display.LEFT_TOP,-self.btnSize.width/2+10,self.btnSize.height/2-24)
	local _singleLineHeight = self.guideTip:getContentSize().height
			self.guideTip:setWidth(self.btnSize.width-10)
			self.guideTip:setLineHeight(_singleLineHeight+0)

	local clipLayer = display.newNode()
			
	local goImg = display.newSprite("common2/com2_Img_16.png")
		:align(display.LEFT_TOP,self.guideBtn.sprite_[1]:getContentSize().width*0.02,self.guideBtn.sprite_[1]:getContentSize().height*0.08)
	local goSize = goImg:getContentSize()
	local clipNode = cc.ClippingNode:create()
			:addTo(self.guideBtn)
    clipNode:setInverted(false)--设定遮罩的模式true显示没有被遮起来的纹理   如果是false就显示遮罩起来的纹理  
    clipNode:setAlphaThreshold(0)--设定遮罩图层的透明度取值范围 
    clipNode:addChild(clipLayer)
    clipNode:setPosition(0, 0)

    local sss = display.newSprite("common2/com2_Img_23.png")
    		:align(display.LEFT_TOP,self.guideBtn.sprite_[1]:getContentSize().width*0.02,self.guideBtn.sprite_[1]:getContentSize().height*0.08)
    		:addTo(clipLayer)
    sss:setBlendFunc(770,1)

   	clipNode:setStencil(goImg)

   	local sq = transition.sequence{
   					cc.Place:create(cc.p(self.guideBtn.sprite_[1]:getContentSize().width*0.02,self.guideBtn.sprite_[1]:getContentSize().height*0.08)),
   					cc.MoveBy:create(1.0,cc.p(goSize.width,0))
   				}
   	sss:runAction(cc.RepeatForever:create(sq))
end

function mainLineGuide:onBtnClick(event)
	local loc_data = self.curloc_data
	print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxcc"..loc_data.id,loc_data.des,loc_data.tgtType,loc_data.postParams)
	
	if loc_data.tgtType==TASKGOLE_ARMY or loc_data.tgtType==TASKGOLE_DAILYINSTANCE
			or loc_data.tgtType==TASKGOLE_ELITEBLOCK then 	--挑战关卡
		local toBlockId
		if loc_data.tgtType==TASKGOLE_DAILYINSTANCE then 	--终结者
			toBlockId = srv_userInfo.maxBlockId
		elseif loc_data.tgtType==TASKGOLE_ELITEBLOCK then 	--精英副本（精英终结者）
			if srv_userInfo.maxEBlockId==0 then
				toBlockId = 21001001
			else
				toBlockId = srv_userInfo.maxEBlockId
			end
		else 												--跳转到指定关卡
			toBlockId = loc_data.postParams
		end
		local toAreaId = blockIdtoAreaId(toBlockId)
		if srv_userInfo.level<areaData[toAreaId].level then
			showTips(areaData[toAreaId].level.."级开启该大区")
		elseif canAreaEnter(toAreaId, blockData[toBlockId].type) then
			if blockData[toBlockId].type==2 and srv_userInfo.level<14 then
				showTips("14级开启精英关卡")
				return
			end
			MainSceneEnterType = EnterTypeList.MAIN_LINE
			local areamap
            if loc_data.tgtType==TASKGOLE_DAILYINSTANCE then --终结者
                areamap = g_blockMap.new(toAreaId, nil, 1)
            elseif loc_data.tgtType==TASKGOLE_ELITEBLOCK then
                areamap = g_blockMap.new(toAreaId,  nil, 2)
            else
            	MainLineToAreaId = toAreaId
				MainLineToBlockId = toBlockId
                areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
            end
            areamap:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
		else
			showTips("未通过至此大区")
		end
	end
end

function mainLineGuide:onEnter()
	self:refreshGuide(true)
end

function mainLineGuide:onExit()
	-- body
end

--指定一个新的引导,id为主线引导表的id
function mainLineGuide:refreshGuide(notOpenDialog)
	local _mainGuideID = getCurentGuide()
	self:show()
	if _mainGuideID==nil then
		self:hide()
		return
	end

	local loc_data = mainLineGuideData[_mainGuideID]
	if loc_data==nil then
		self:hide()
		return
	end
	print("loc_data.talType-------------------------",loc_data.talType)
	if loc_data.talType==1 and (not notOpenDialog) then
		local _bol = getIsFirstIntoMainScene(true)
		print("-----------------------------------------_bol: ",_bol)
		if _bol then --第一次进来，显示对话
			local dialog = UIDialog.new()
	        	:addTo(display.getRunningScene(),501)
	        dialog:setVisible(true)
	        local _dialogId = loc_data.talkId
	        dialog:TriggerDialog(tonumber(_dialogId), DialogType.mainGuidePlot)
	        dialog:SetFinishCallback(function ( ... )
	        	dialog:removeSelf()
	        end)
		end
	end

	self.guideTip:setString(loc_data.des)

	self.curloc_data = loc_data

end

return mainLineGuide