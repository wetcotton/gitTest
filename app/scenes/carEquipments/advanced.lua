
local advanced = class("advanced", function()
	return display.newNode()
	end)
local msgBox2
function advanced:ctor(value,localValue,callBack)
	
	self.value = value
	self.localValue = localValue
	self.callBack = callBack

	msgBox2 = display.newScale9Sprite("common2/com2_Img_3.png",nil, nil,
        cc.size(500, 597),cc.rect(119, 127, 1, 1))
	:addTo(self)
	:pos(display.cx+250+50, display.cy-30)

	self:reloadData(value,localValue)

    return bCanAdv
end
function advanced:reloadData(value,localValue)
	msgBox2:removeAllChildren()
    local BoxSize = msgBox2:getContentSize()

    local closeBt = createCloseBt()
    :addTo(msgBox2)
    :pos(msgBox2:getContentSize().width+15,msgBox2:getContentSize().height-32)
    :onButtonClicked(function(event)
        self:getParent():removeSelf()
        end)

    self.item2 = nil
    local advanced = nil
    if advancedData[localValue.id]==nil then
        cc.ui.UILabel.new({UILabelType = 2, text = "已进阶到最高等级", size = 25, color = cc.c3b(255, 255, 0)})
        :addTo(msgBox2)
        :align(display.CENTER, BoxSize.width/2, 300)
        return
    else
        advanced = advancedData[localValue.id]
        self.item2 = itemData[advanced.toItemId]
    end

	--名字
	local title = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25, color = MYFONT_COLOR})
	:addTo(msgBox2)
	:pos(msgBox2:getContentSize().width/2, msgBox2:getContentSize().height-80)
	title:setString(self.item2.name)
	title:setAnchorPoint(0.5,0.5)
    local star = getItemStar(localValue.id)
    if star==2 then
        title:setColor(cc.c3b(193, 195, 180))
    elseif star==3 then
        title:setColor(cc.c3b(107, 206, 82))
    elseif star==4 then
        title:setColor(cc.c3b(85, 171, 249))
    elseif star==5 then
        title:setColor(cc.c3b(204, 89, 252))
    end
	-- --等级
	-- local levelBar = display.newSprite("common/Improve_Img24.png")
	-- :addTo(msgBox2)
	-- :pos(msgBox2:getContentSize().width/2, msgBox2:getContentSize().height-90)
	-- self.level = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 22})
	-- :addTo(levelBar)
	-- :pos(100,levelBar:getContentSize().height/2)
	-- self.level:setString(value.advLvl)
	-- self.level:setAnchorPoint(0.5,0.5)
	--图标
	local icon = createItemIcon(localValue.id)
	:addTo(msgBox2)
	:pos(BoxSize.width/2, BoxSize.height-170)
	self.advanceIcon = icon
	--底框
	local midPart = display.newScale9Sprite("equipment/equipmentImg7.png",nil,nil,cc.size(445,200),cc.rect(222,100,1,1))
	:addTo(msgBox2)
    :pos(BoxSize.width/2, 240)


	--合成材料
	-- local leftLine = display.newSprite("common/Improve_Img19.png")
	-- :addTo(msgBox2)
	-- :pos(BoxSize.width/2-65,320)
	--金币
	local goldIcon = createGoldIcon(advanced.gold)
	:addTo(msgBox2)
	:pos(BoxSize.width/2-135,210)
	self.stuffNote = {}
	self.stuffNote[1] = goldIcon
	
	-- local rightLine = display.newSprite("common/Improve_Img19.png")
	-- :addTo(msgBox2)
	-- :pos(BoxSize.width/2+65,320)
	-- rightLine:setScaleX(-1)
	
    --判断材料是否足够
    self.isStuffEnough = true
    local stuffTab = {}

	local StuffArr=lua_string_split(advanced.stuff,"|")
	local Stuff1=lua_string_split(StuffArr[1],"#")
	-- printTable(Stuff1)
	-- print(Stuff1[1])
	-- local StuffValue1 = get_SrvBackPack_Value(Stuff1[1]+0)
	-- self:performWithDelay(function ()
		
		--材料1
		local stuffItem1 =createItemIcon(Stuff1[1]+0, nil, true)
		:addTo(msgBox2)
		:pos(BoxSize.width/2+135,210)
		:onButtonClicked(function(event)
			g_combinationLayer.new(Stuff1[1]+0, function(event)
				self:reloadData(value,localValue)
				end)
    		:addTo(self,10)
			end)
		stuffItem1:setScale(0.75)
		local numBar = display.newScale9Sprite("common/common_Frame7.png",BoxSize.width/2+135, 
			183,
			cc.size(80, 23),cc.rect(10, 10, 30, 30))
		:addTo(msgBox2)
		local num = getComNumPer(Stuff1[1]+0,Stuff1[2]+0)
		:addTo(numBar)
		:pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)
		-- num:setAnchorPoint(0.5,0.5)
		-- num:setColor(cc.c3b(0, 255, 0))
		-- if StuffValue1==nil then --还没有材料判断
  --       	num:setString("0/"..Stuff1[2])
  --       	num:setColor(cc.c3b(255, 0, 0))
  --           self.isStuffEnough = false
  --           stuffTab[1] = {}
  --           stuffTab[1].tmpId = tonumber(Stuff1[1])
  --           stuffTab[1].needNum = tonumber(Stuff1[2])
  --       else
  --       	num:setString(StuffValue1.cnt.."/"..Stuff1[2])
  --       	if StuffValue1.cnt<(Stuff1[2]+0) then
  --       		num:setColor(cc.c3b(255, 0, 0))
  --               self.isStuffEnough = false
  --               stuffTab[1] = {}
  --               stuffTab[1].tmpId = tonumber(Stuff1[1])
  --               stuffTab[1].needNum = tonumber(Stuff1[2]) - tonumber(StuffValue1.cnt)
  --       	end
  --       end
        self.stuffNote[2] = stuffItem1
        --材料2
        if #StuffArr==2 then
   --      	local midLine = display.newSprite("common/Improve_Img20.png")
			-- :addTo(msgBox2)
			-- :pos(BoxSize.width/2,320)
	    	local Stuff2=lua_string_split(StuffArr[2],"#")
	    	local StuffValue2 = get_SrvBackPack_Value(Stuff2[1]+0)
		    local stuffItem2 = createItemIcon(Stuff2[1]+0, nil, true)
			:addTo(msgBox2)
			:pos(BoxSize.width/2,210)
			:onButtonClicked(function(event)
				g_combinationLayer.new(Stuff2[1]+0, function(event)
					self:reloadData(value,localValue)
				end)
    			:addTo(self,10)
				end)
			stuffItem2:setScale(0.75)
			local numBar = display.newScale9Sprite("common/common_Frame7.png",BoxSize.width/2, 
				183,
				cc.size(80, 23),cc.rect(10, 10, 30, 30))
			:addTo(msgBox2)
			local num = getComNumPer(Stuff2[1]+0,Stuff2[2]+0)
			:addTo(numBar)
			:pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)
			-- num:setAnchorPoint(0.5,0.5)
			-- num:setColor(cc.c3b(0, 255, 0))
			-- if StuffValue2==nil then --还没有材料判断
	  --       	num:setString("0/"..Stuff2[2])
	  --       	num:setColor(cc.c3b(255, 0, 0))
   --              self.isStuffEnough = false
   --              local idx = #stuffTab+1
   --              stuffTab[idx] = {}
   --              stuffTab[idx].tmpId = tonumber(Stuff2[1])
   --              stuffTab[idx].needNum = tonumber(Stuff2[2])
	  --       else
	  --       	num:setString(StuffValue2.cnt.."/"..Stuff2[2])
	  --       	if StuffValue2.cnt<(Stuff2[2]+0) then
	  --       		num:setColor(cc.c3b(255, 0, 0))
   --                  self.isStuffEnough = false
   --                  local idx = #stuffTab+1
   --                  stuffTab[idx] = {}
   --                  stuffTab[idx].tmpId = tonumber(Stuff2[1])
   --                  stuffTab[idx].needNum = tonumber(Stuff2[2]) - tonumber(StuffValue2.cnt)
	  --       	end
	  --       end
	        self.stuffNote[3] = stuffItem2
	    end
	-- end,0.01)
	
	local need = cc.ui.UILabel.new({UILabelType = 2, text = "所需材料", size = 25})
	:addTo(msgBox2)
	:pos(BoxSize.width/2,280)
	need:setAnchorPoint(0.5,0.5)
	need:setColor(cc.c3b(132, 149, 165))

	--进阶按钮
	local advancedBt = createGreenBt2("进阶",1.2)
	:addTo(msgBox2)
	:pos(BoxSize.width/2, 70)
	:onButtonClicked(function(event)
        if srv_userInfo.gold < advanced.gold then
            showTips("金币不足")
            return
        end
        local isDia = 0
        if not self.isStuffEnough then
            local needDiaNum = 0
            for i,value in ipairs(stuffTab) do
                needDiaNum = needDiaNum + itemData[value.tmpId].advDiamond*value.needNum
            end
            local msg = "是否消耗"..needDiaNum.."钻石代替材料进行进阶？"
            showMessageBox(msg, function(event)
                isDia = 1
                local sendData = {}
                sendData["characterId"] = srv_userInfo["characterId"]
                sendData["itemId"] =  value["id"]
                sendData["isDia"] = isDia
                m_socket:SendRequest(json.encode(sendData), CMD_ADVANCED, self, self.onAdvancedResult)
                startLoading()
                end)
        else
            local sendData = {}
            sendData["characterId"] = srv_userInfo["characterId"]
            sendData["itemId"] =  value["id"]
            sendData["isDia"] = isDia
            m_socket:SendRequest(json.encode(sendData), CMD_ADVANCED, self, self.onAdvancedResult)
            startLoading()
        end
		end)

end


function advanced:onAdvancedResult(result) --进阶
	endLoading()
    if result["result"]==1 then
        print("进阶成功")
        showTips("进阶成功")
        
        local tmpValue = self.value
        tmpValue.tmpId = self.item2.id
        self:getParent():getParent():reloadData(tmpValue,self.item2,2)
        self:reloadData(tmpValue,self.item2)
        
        mainscenetopbar:setGlod()
        -- self:getParent():getParent():removeSelf()
        self.callBack()

        if self.item2~=nil then
            --进阶特效
            local note = self.advanceIcon
            if note then
                advancedAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)
            end
            -- self:performWithDelay(function ()
                for i=1,#self.stuffNote do
                    -- print("stuffNote")
                    local note = self.stuffNote[i]
                    if i==1 then
                        strengthAnimation(note,note:getContentSize().width/2,note:getContentSize().height/2)
                    else
                        strengthAnimation(note,0,0)
                    end
                end
            -- end,0.01)
        end
        
        
    else
    	showTips(result.msg)
    end
end


return advanced