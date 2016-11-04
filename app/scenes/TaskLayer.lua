--
-- Author: Huang YuZhao
-- Date: 2015-08-6 16:12:38
--


TaskLayer = class("TaskLayer",function()
	local layer = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 128))
    layer:setNodeEventEnabled(true)
    return layer
end)

TaskLayer.Instance = nil 				--实例
TaskLayer.curRewards = nil 				--当前奖励，发送消息时更新（非每日签到）

function TaskLayer:ctor(params)
	setIgonreLayerShow(true)
	TaskLayer.Instance = self 	
	display.addSpriteFrames("Image/UITask.plist", "Image/UITask.png")
	-- if mainscenetopbar~=nil then
	-- 	mainscenetopbar:hide()
	-- end
	-- self:setLocalZOrder(51)
    self.mainBg = getMainSceneBgImg(mapAreaId)
    				:addTo(self)
    local tmpNode
	local tmpSize = cc.size(998,596)
	-- local imgBG = display.newScale9Sprite("#task_frame1.png", nil, nil, tmpSize, cc.rect(30, 30, 7, 7))
	-- 				    :align(display.CENTER, display.cx, display.cy-27)
	-- 					:addTo(self,1)

	self.closeBtn = cc.ui.UIPushButton.new({
		normal="common/common_BackBtn_1.png",
		pressed="common/common_BackBtn_2.png"})
	    :align(display.LEFT_TOP, 0, display.height )
	    :addTo(self)
	    :onButtonClicked(function(event)
	        display.getRunningScene():refreshTaskRedPoin()
	        GuideManager:removeGuideLayer()
	        local _scene = cc.Director:getInstance():getRunningScene()
	    	_scene:addGuide_ani(10401)
	    	GuideManager:_addGuide_2(12301, _scene,handler(_scene,_scene.caculateGuidePos))
	        self:removeFromParent()
	        bTaskLayerOpened = false
	    end)

	display.newSprite("#task_02.png")
		:addTo(self)
		:align(display.CENTER_BOTTOM, display.cx, display.cy+tmpSize.height/2-64)
	display.newSprite("#task_01.png")
		:addTo(self)
		:align(display.CENTER_BOTTOM, display.cx, display.cy+tmpSize.height/2-47)
	display.newSprite("#task_04.png")
		:addTo(self)
		:align(display.CENTER_BOTTOM, display.cx, display.cy+tmpSize.height/2-70)
	-- display.newSprite("#task_img4.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.CENTER, tmpSize.width/2, tmpSize.height-9)
	-- display.newSprite("#task_img5.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.CENTER, tmpSize.width/2, 0)
	-- display.newSprite("#task_img1.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.CENTER, 0, tmpSize.height/2)
	-- display.newSprite("#task_img2.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.LEFT_TOP, 0-12, tmpSize.height+9)
	-- tmpNode = display.newSprite("#task_img1.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.CENTER, tmpSize.width, tmpSize.height/2)
	-- tmpNode:setScale(-1,1)
	-- tmpNode = display.newSprite("#task_img2.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.LEFT_TOP, tmpSize.width+12, tmpSize.height+9)
	-- tmpNode:setScale(-1,1)
	-- display.newSprite("#task_img3.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.LEFT_BOTTOM, -12, -11)
	-- tmpNode = display.newSprite("#task_img3.png")
	-- 	:addTo(imgBG)
	-- 	:align(display.LEFT_BOTTOM, tmpSize.width+12, -11)
	-- tmpNode:setScale(-1,1)
	
	self.storyView = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 0, 0, 200),
        viewRect = cc.rect(display.cx-930/2-10, display.cy-540/2-40, 960, 540),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = "common/jiaob_lapit-05.png",
        scrollbarImgVBg = "common/jiaob_lapit-04.png",
        }
        :addTo(self)

    self:InitTaskList()

    GuideManager:_addGuide_2(10302, display.getRunningScene(),handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(12202, display.getRunningScene(),handler(self,self.caculateGuidePos))
end



--刷新红点标志
function TaskLayer:RefreshRedPoints()
	
end


--初始化任务列表
function TaskLayer:InitTaskList()
	--self:performWithDelay(function ()
		self.idList = TaskMgr.sortList[TaskTag.Daily]
		local listView = self.storyView
		listView:removeAllItems()   --清空
		self.selectedBtn = nil

		local xxTab = {}
		for i=1, #self.idList do
		    local xx = TaskMgr.idKeyInfo[self.idList[i]]
		    	
		    if xx.tptId==102370001 then 
		    	xxTab[102370001] = xx
		    elseif xx.tptId==101030001 then
		    	xxTab[101030001] = xx
		    end
	    end

	    local boolTab = {}

		if xxTab[102370001] and xxTab[102370001].status==0 then --任务未达成时不显示
			boolTab[102370001]=true
		end
		if xxTab[101030001] and xxTab[101030001].status==0 then --任务未达成时不显示
			boolTab[101030001]=true
		end

		if srv_userInfo.isPass==1 then
			boolTab[101480001]=true
		end

		local function BtnOnClick(event)
	    	local nTag = event.target:getTag()
	    	local srv_TaskData = TaskMgr.idKeyInfo[nTag]
	    	local loc_TaskData = taskData[srv_TaskData.tptId]

	    	local function goBlock(nBlockID)
	    		local areamap = g_blockMap.new(nBlockID)
	                cc.Director:getInstance():getRunningScene():addChild(areamap,50)
	    		-- if next(srv_blockData)==nil then
	      --           local fightSelectAreaData = {}
	      --           fightSelectAreaData["characterId"]=srv_userInfo["characterId"]
	      --           fightSelectAreaData["areaId"]=srv_userInfo["areaId"]
	      --           m_socket:SendRequest(json.encode(fightSelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
	      --       else
	      --           local areamap = g_blockMap.new(nBlockID)
	      --           cc.Director:getInstance():getRunningScene():addChild(areamap,50)
	      --           -- cc.Director:getInstance():getRunningScene():setMainMenuVisible(false)
	      --       end
	    	end

	    	if srv_TaskData.curcnt<loc_TaskData.cnt then
	    		if loc_TaskData.tgtType==TASKGOLE_ARMY or loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE
	    				or loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then --挑战关卡
	    			local toBlockId
	    			if loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE then --终结者
	    				if srv_userInfo.maxBlockId==0 then
                            toBlockId = 11001001
                        else
                            toBlockId = srv_userInfo.maxBlockId
                        end
	    			elseif loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then
	    				if srv_userInfo.maxEBlockId==0 then
	    					toBlockId = 21001002
	    				else
	    					toBlockId = srv_userInfo.maxEBlockId
	    				end
	    			else	 
	    				toBlockId = loc_TaskData.params
	    			end
            		local toAreaId = blockIdtoAreaId(toBlockId)
            		if srv_userInfo.level<areaData[toAreaId].level then
						showTips(areaData[toAreaId].level.."级开启该大区")
            		elseif canAreaEnter(toAreaId, blockData[toBlockId].type) then
            			if blockData[toBlockId].type==2 and srv_userInfo.level<14 then
            				showTips("14级开启精英关卡")
            				return
            			end
            			MainSceneEnterType = EnterTypeList.TASK_ENTER
            			-- local areamap
            			-- if loc_TaskData.tgtType~=TASKGOLE_ARMY and 
            			-- 	canAreaEnter(toAreaId+1, blockData[toBlockId].type) then
            			-- 	toAreaId = toAreaId + 1
            			-- 	areamap = g_blockMap.new(toAreaId, nil, 1, true)
            			-- end

            			local areamap
            			if loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE then --终结者
            				areamap = g_blockMap.new(toAreaId, nil, 1)
		    			elseif loc_TaskData.tgtType==TASKGOLE_ELITEBLOCK then --精英终结者
		    				areamap = g_blockMap.new(toAreaId,  nil, 2)
		    			else
		    				areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
		    			end
				        areamap:addTo(MainScene_Instance, 10 , TAG_AREA_LAYER)
            		else
            			showTips("未通过至此大区")
            		end
            	elseif loc_TaskData.tgtType==TASKGOLE_GUIDE_GIFT then
            		local toBlockId = loc_TaskData.params
            		local toAreaId = blockIdtoAreaId(toBlockId)
            		print("toAreaId:",toAreaId,"toBlockId:",toBlockId)
            		local areamap = g_blockMap.new(toAreaId, toBlockId, nil, true)
            				:addTo(MainScene_Instance, 50 , TAG_AREA_LAYER)
	    		elseif loc_TaskData.tgtType==TASKGOLE_CAREQUIPMENTSTRENGTHEN then
	    			if 0==srv_userInfo.hasCar then
			            showMessageBox("当前战车数量为0")
			        else
		    			g_ImproveLayer.new()
							:addTo(self,10)
		            end

	    		elseif loc_TaskData.tgtType==TASKGOLE_ROLEEQUIPMENTADVANCE then
	    			local scene = display.getRunningScene()
	    			g_RolePropertyLayer.new()
	    				:addTo(scene, 10)

	    		elseif loc_TaskData.tgtType==TASKGOLE_RECHARGE or loc_TaskData.tgtType==TASKGOLE_TOTALRECHARGE then
	    			local layer = StoreLayer.new()
	    			layer:addTo(self)

	    		elseif loc_TaskData.tgtType==TASKGOLE_SHOPTOBUY then
	                local layer = shopLayer.new(1)
	                layer:addTo(self)

	    		elseif loc_TaskData.tgtType==TASKGOLE_CARTRANSFORM then
	    			if 0==srv_userInfo.hasCar then
			            showMessageBox("当前战车数量为0")
			        else
			        	g_ImproveLayer.new()
							:addTo(self)
		            end

	    		elseif loc_TaskData.tgtType==TASKGOLE_THREESTARCHAPTER then
	    			showTips("暂未开放")

	    		elseif loc_TaskData.tgtType==TASKGOLE_LEGION
	    				or loc_TaskData.tgtType==TASKGOLE_LEGION_CTRI then --军团
	    			if srv_userInfo.level<28 then
			            showTips("28级后开启军团功能")
			            return
			        end
	                startLoading()
			        local sendData = {}
			        if srv_userInfo.armyName=="" then
			            sendData["characterId"] = srv_userInfo["characterId"]
			            sendData["No"] =  0
			            m_socket:SendRequest(json.encode(sendData), CMD_LEGION_ENTER, MainScene_Instance, MainScene_Instance.onEnterLegionResult)
			        else
			            sendData["characterId"] = srv_userInfo["characterId"]
			            m_socket:SendRequest(json.encode(sendData), CMD_MYLEGION_INFO, MainScene_Instance, MainScene_Instance.onMyLegionInfo)
			        end
			    elseif loc_TaskData.tgtType==TASKGOLE_RELICS then --遗迹探测
			    	display.addSpriteFrames("Image/UIWarriorsCenter.plist", "Image/UIWarriorsCenter.png")
			    	g_RelicsLayer.new()
						:addTo(self, 10)
				elseif loc_TaskData.tgtType==TASKGOLE_WORLDBOSS then --世界boss
					g_WarriorsCenterLayer.new()
            		:addTo(self, 1)
				elseif loc_TaskData.tgtType==TASKGOLE_EQUIPLEVELUP then
					g_RolePropertyLayer.new({seltag = 2})
	       				 :addTo(display.getRunningScene(),10)
	       		elseif loc_TaskData.tgtType==TASKGOLE_RENTCAR then  
	       			RentMgr:ReqRentCarList(function ( ... )
	       				rentCarListLayer.new()
			        		:addTo(display.getRunningScene(),10)
	       			end)
	       			
			    elseif loc_TaskData.tgtType==TASKGOLE_PVP then --PVP
			    	-- showTips("暂未开放")
			    	if srv_userInfo.level < 16 then
			           showTips("等级达到16级解锁竞技场")
			           return
			        end
			        startLoading()
			        comData={}
			        comData["characterId"] = srv_userInfo.characterId
			        m_socket:SendRequest(json.encode(comData), CMD_GETPVPINFO, MainScene_Instance, MainScene_Instance.OnGetPVPInfoRet)
			    elseif loc_TaskData.tgtType==TASKGOLE_SKILLUP then --技能提升
			    	g_RolePropertyLayer.new({seltag = 3})
	       				 :addTo(display.getRunningScene(),10)
			    elseif loc_TaskData.tgtType==TASKGOLE_GOLDHAND then --点金手
			    	addGold()
			    elseif loc_TaskData.tgtType==TASKGOLE_LOTTERY then --抽卡
			    	g_lotteryCardLayer.new()
	       				 :addTo(display.getRunningScene(),10)
	       		elseif loc_TaskData.tgtType==TASKGOLE_YUANZHENG then --远征
	       			expeditionLayer.new()
            		:addTo(self, 1)
            	
	    		else
	    			-- print(loc_TaskData.tgtType)
					--do nothing
				end
			else
				self:GenerateRewardsTab(srv_TaskData.tptId)
				TaskMgr:ReqSubmit(nTag)
				startLoading()
			end
	    end
	    self.Btns = {}
	    local srv_TaskData, loc_TaskData
	    for i=1, #self.idList do
	    	srv_TaskData = TaskMgr.idKeyInfo[self.idList[i]]
	    	if boolTab[srv_TaskData.tptId]~=true then
		    	loc_TaskData = taskData[srv_TaskData.tptId]

	            
	            local item = listView:newItem()
	            local bIsTimeLimit = false
	            
	            local content = cc.ui.UIPushButton.new("#task_03.png")
	                                :onButtonClicked(function (event)
	                                	for i = 1,#self.Btns do
	                                		self.Btns[i]:setButtonEnabled(true)
	                                	end
	                                    local btn = event.target
	                                    btn:setButtonEnabled(false)
	                                end)
	            table.insert(self.Btns,content)
	            content:setTouchSwallowEnabled(false)
	            local tmpSize = content.sprite_[1]:getContentSize()

	            -- display.newSprite("#task_img11.png")
	            --         :addTo(content)
	            --         :align(display.CENTER,-tmpSize.width/2+80,0)
	            local box = display.newSprite("#task_08.png")
	                    :addTo(content)
	                    :align(display.CENTER,-tmpSize.width/2+80,0)

	            local taskIcon = display.newSprite("achIcon/task_"..loc_TaskData.resId..".png")
	                    :addTo(box)
	                    :align(display.CENTER,box:getContentSize().width/2,box:getContentSize().height/2)
	                    :scale(1.36)
	            taskIcon:setTag(14)

	            if bIsTimeLimit then
	            	display.newSprite("#task_05.png")
	                    :addTo(box)
	                    :align(display.CENTER,20,box:getContentSize().height-20)
	            end

	            display.newTTFLabel({
	                        text = loc_TaskData.name,
	                        size = 30,
	                        color = cc.c3b(23,86,84),
	                        align = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	                        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	                        })
	                        :addTo(content)
	                        :align(display.LEFT_CENTER, -tmpSize.width/2+167, 40)

	   --          --已经完成次数
				-- display.newTTFLabel({
				-- 				font = "fonts/slicker.ttf", 
				-- 	    		text = srv_TaskData.curcnt,
				-- 	            size = 26,
				-- 	            color = cc.c3b(35, 24, 21),
				-- 	    		})
				-- 	    		:align(display.RIGHT_CENTER,tmpSize.width/2-100, 40)
				-- 	    		:addTo(content,1)
				--完成进度
			    display.newTTFLabel({
			    				font = "fonts/slicker.ttf", 
					    		text = srv_TaskData.curcnt.."/"..loc_TaskData.cnt,
					            size = 30,
					            color = cc.c3b(35, 24, 21),
					    		})
					    		:align(display.RIGHT_CENTER,tmpSize.width/2-70,40)
					    		:addTo(content,1)
				--描述
	            display.newTTFLabel({
		    		text = loc_TaskData.tgtDes,
		            size = 20,
		            align = cc.ui.TEXT_ALIGN_CENTER,
	                -- valign= cc.ui.TEXT_VALIGN_CENTER,
	                color = cc.c3b(35, 24, 21)
		    		})
		    		:align(display.LEFT_CENTER, -tmpSize.width/2+165, 5)
		    		:addTo(content,1)
		    	--奖励
		    	local label = cc.ui.UILabel.new({UILabelType = 2, text = "奖励：", size = 30, color = cc.c3b(252, 215, 62)})
		    	:addTo(content, 1)
		    	:pos(-tmpSize.width/2+165, -40)
		    	setLabelStroke(label,30,nil,1,nil,nil,nil,nil,true)

	            do
		            local ptX = -tmpSize.width/2+250
					local ptY = -40
					if loc_TaskData.gold~=0 then
						local sp = display.newSprite("common/common_GoldGet.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY+5)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.gold,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
					if loc_TaskData.diamond~=0 then
						local sp = display.newSprite("common/common_Diamond.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.diamond,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
					if loc_TaskData.exp~=0 then
						local sp = display.newSprite("common/common_Exp.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.exp,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
					if loc_TaskData.energy~=0 then  --燃油
						local sp = display.newSprite("common/common_Stamina.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.energy,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
					if loc_TaskData.exploit~=0 then  --军团功勋币
						local sp = display.newSprite("common/gongxun.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.exploit,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
					if loc_TaskData.expedition~=nil and loc_TaskData.expedition~=0 then  --远征币
						local sp = display.newSprite("common/expedition.png")
							:addTo(content)
							:align(display.LEFT_CENTER,ptX,ptY)
							:scale(0.7)
						ptX=ptX+sp:getContentSize().width*0.7
						local lb = display.newTTFLabel({
									font = "fonts/slicker.ttf", 
						    		text = "×"..loc_TaskData.expedition,
						            size = 30,
						            align = cc.TEXT_ALIGNMENT_LEFT,
						            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
						            color = cc.c3b(252, 215, 62),
						    		})
						    		:align(display.LEFT_CENTER,ptX,ptY)
						    		:addTo(content,1)
						    		setLabelStroke(lb,30,nil,1,nil,nil,nil,"fonts/slicker.ttf",true)
						ptX=ptX+lb:getContentSize().width+10
					end
				end

				local btnLabStr,btnImg, bEnable = "",{}, true
				local xx_scale = 1
				if srv_TaskData.curcnt<loc_TaskData.cnt then
					-- if loc_TaskData.tgtType==TASKGOLE_ARMY
					-- 	or loc_TaskData.tgtType==TASKGOLE_CAREQUIPMENTSTRENGTHEN
					-- 	or loc_TaskData.tgtType==TASKGOLE_ROLEEQUIPMENTADVANCE
					-- 	or loc_TaskData.tgtType==TASKGOLE_RECHARGE
					-- 	or loc_TaskData.tgtType==TASKGOLE_TOTALRECHARGE
					-- 	or loc_TaskData.tgtType==TASKGOLE_SHOPTOBUY
					-- 	or loc_TaskData.tgtType==TASKGOLE_CARTRANSFORM
					-- 	or loc_TaskData.tgtType==TASKGOLE_LEGION
					-- 	or loc_TaskData.tgtType==TASKGOLE_RELICS
					-- 	or loc_TaskData.tgtType==TASKGOLE_WORLDBOSS
					-- 	or loc_TaskData.tgtType==TASKGOLE_EQUIPLEVELUP
					-- 	or loc_TaskData.tgtType==TASKGOLE_RENTCAR
					-- 	or loc_TaskData.tgtType==TASKGOLE_PVP
					-- 	or loc_TaskData.tgtType==TASKGOLE_SKILLUP
					-- 	or loc_TaskData.tgtType==TASKGOLE_GOLDHAND
					-- 	or loc_TaskData.tgtType==TASKGOLE_LOTTERY
					-- 	or loc_TaskData.tgtType==TASKGOLE_THREESTARCHAPTER
					-- 	or loc_TaskData.tgtType==TASKGOLE_YUANZHENG
					-- 	or loc_TaskData.tgtType==TASKGOLE_LEGION_CTRI
					-- 	or loc_TaskData.tgtType==TASKGOLE_DAILYINSTANCE then
					-- 	-- btnLabStr = "task_tag2.png"
					-- 	btnImg = {normal = "#task_07.png",pressed = "#task_07.png"}
					-- 	-- xx_scale = 0.85
					-- else
					-- 	-- btnLabStr = "task_tag5.png"
					-- 	btnImg = {normal = "#task_07.png",pressed = "#task_07.png"}
					-- 	bEnable = false
					-- end
					btnImg = {normal = "#task_07.png",pressed = "#task_07.png"}
				else
					-- btnLabStr = "task_tag1.png"
					btnImg = {normal = "#task_06.png",pressed = "#task_06.png"}
				end

				local btnGet = cc.ui.UIPushButton.new({normal=btnImg.normal,pressed=btnImg.pressed})
				    :align(display.CENTER,tmpSize.width/2-120, -20)
				    :addTo(content,0,self.idList[i])
				    :onButtonPressed(function(event) event.target:setScale(0.95) end)
				    :onButtonRelease(function(event) event.target:setScale(1.0) end)
				    :onButtonClicked(BtnOnClick)
				    :scale(xx_scale)
				-- self.btnTag = display.newSprite("#"..btnLabStr)
				-- 	:addTo(content)
				-- 	:align(display.CENTER, tmpSize.width/2-120, -30)
				btnGet:setButtonEnabled(bEnable)
	            btnGet:setName("btnGet")
	            item:addContent(content)
	            item:setItemSize(940, 155)
	            listView:addItem(item)
	        else
	        	print(srv_TaskData.tptId)
	        end
	    end
	    listView:reload()

	 --end, 0.01)
end


function TaskLayer:OnSubmitRet(cmd)
	print("提交返回，task")
	if 1==cmd.result then

		self:InitTaskList()

		if nil~=self.curRewards then
			GlobalShowGainBox({bAlwaysExist = true}, self.curRewards)
			--奖励添加
			self:RewardsAdd(self.curRewards)
			self:RefreshRedPoints()
		end

		
	else
		showTips(cmd.msg)
	end
	endLoading()
end

function TaskLayer:GenerateRewardsTab(nTaskTplID)
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
	if 0~=loc_TaskData.energy then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_STRENGTH, num=loc_TaskData.energy})
	end
	if 0~=loc_TaskData.exploit then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_GONGXUN, num=loc_TaskData.exploit})
	end
	if nil ~=loc_TaskData.expedition and 0~=loc_TaskData.expedition then
		table.insert(self.curRewards, {templateID=GAINBOXTPLID_EXPEDITION, num=loc_TaskData.expedition})
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
function TaskLayer:RewardsAdd(tabRewards)
	if nil==tabRewards then
		return
	end

	for i=1, #tabRewards do
		if tabRewards[i].templateID==GAINBOXTPLID_GOLD then
			srv_userInfo.gold = srv_userInfo.gold+tabRewards[i].num
			if mainscenetopbar ~=nil then
				mainscenetopbar:setGlod()
			end
		elseif tabRewards[i].templateID==GAINBOXTPLID_DIAMOND then
			srv_userInfo.diamond = srv_userInfo.diamond+tabRewards[i].num
			if mainscenetopbar ~=nil then
				mainscenetopbar:setDiamond()
			end
		elseif tabRewards[i].templateID==GAINBOXTPLID_EXP then
			srv_userInfo.exp = srv_userInfo.exp+tabRewards[i].num

		elseif tabRewards[i].templateID==GAINBOXTPLID_STRENGTH then
			srv_userInfo.energy = srv_userInfo.energy+tabRewards[i].num
			--if mainscenetopbar ~=nil then
				mainscenetopbar:setEnergy()
			--end
		elseif tabRewards[i].templateID==GAINBOXTPLID_GONGXUN then
			srv_userInfo.exploit = srv_userInfo.exploit+tabRewards[i].num
		elseif tabRewards[i].templateID==GAINBOXTPLID_EXPEDITION then
			srv_userInfo.expedition = srv_userInfo.expedition+tabRewards[i].num
		end
	end
end

function TaskLayer:onEnter()
	setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
end

function TaskLayer:onExit()
	TaskLayer.Instance = nil
	if mainscenetopbar~=nil then
		mainscenetopbar:show()
	end
	display.removeSpriteFramesWithFile("Image/UITask.plist", "Image/UITask.png")
end

function TaskLayer:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10304 ==_guideId or 10302==_guideId or 12202==_guideId or 12204==_guideId then
    	if 10304==_guideId or 12204==_guideId then
    		g_node = self.closeBtn
    	elseif 10302==_guideId or 12202==_guideId then
    		--g_node = self.btnGet
    		g_node = self.Btns[1]:getChildByName("btnGet")
    	end
        
        size = g_node.sprite_[1]:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(0,0))
        if 10304==_guideId or 12204==_guideId then
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