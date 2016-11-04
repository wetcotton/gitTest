block_idx = nil 	--选中关卡的索引
-- block_star = nil
g_fightBlockStar = nil --战斗关卡的星级

curGuideBtn = nil

BlockUI = class("BlockUI", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

local curBlock={}--当前区本地数据
local Srv_curBlock={}--当前区服务端数据
local masklayer
local msgPanel
local sweepBox
local curSweepNum
local showFightCnt
local needSweepDiamond = 0
local Ltimes
local sweepvalue
-- local cur_type

local challengeBt
blockUI_Instance = nil
BlockUI.Instance = nil
function BlockUI:ctor(commonid,publicBlockData)
    BlockUI.Instance = self
    blockUI_Instance = self
	setIgonreLayerShow(true)
    print(publicBlockData)

	block_idx=commonid
	curBlock=blockData[block_idx]
	-- print("curBlock")
	-- print(json.encode(curBlock))
    if type(publicBlockData)=="number" then
        local dayCount = 3- publicBlockData
        publicBlockData = {}
        publicBlockData.star = 0
        publicBlockData.dayCount = dayCount
        Srv_curBlock = publicBlockData
	elseif publicBlockData~=nil then
		Srv_curBlock=publicBlockData[block_idx]
	else
		Srv_curBlock=nil
	end
	-- print("Srv_curBlock")
	-- print(json.encode(Srv_curBlock))
    if Srv_curBlock~=nil then
        g_fightBlockStar = Srv_curBlock.star
    else
        g_fightBlockStar = 0
    end

 
    
	--屏蔽层
	masklayer =  display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 220))
    :addTo(self)

    local colorBg = display.newSprite("common/colorbg.png")
    :addTo(masklayer,-1)
    colorBg:setAnchorPoint(0,0)
    colorBg:setScaleX(display.width/colorBg:getContentSize().width)
    colorBg:setScaleY(display.height/colorBg:getContentSize().height)     

    --返回按钮
    cc.ui.UIPushButton.new({
    	normal = "common/common_BackBtn_1.png",
    	pressed = "common/common_BackBtn_2.png"
    	})
    :addTo(masklayer)
    :align(display.LEFT_TOP, 0, display.height )
    :onButtonClicked(function(event)
    	masklayer:removeSelf()
        BlockUI.Instance = nil
    	end)
    :setAnchorPoint(0,1)

    --关卡框
    local blockBox = display.newSprite("Block/blockSelected/blockSelectedBox.png")
    :addTo(masklayer)
    :pos(display.cx+50, display.cy)
    local boxsize = blockBox:getContentSize()

    --关卡名字
    local blockName = cc.ui.UILabel.new({UILabelType = 2, text = curBlock["name"], size = 34, color = cc.c3b(111, 160, 160)})
    :addTo(blockBox)
    :pos(30, boxsize.height- 40)
    setLabelStroke(blockName,34,nil,1,nil,nil,nil,nil,true)

    --描述
    local blockDes = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 23, color = cc.c3b(181, 181, 181)})
    :addTo(blockBox)
    :align(display.TOP_LEFT, 35, boxsize.height-58)
    blockDes:setWidth(600)
    blockDes:setLineHeight(26)
    blockDes:setString(curBlock["des"])
    setLabelStroke(blockName,23,nil,1,nil,nil,nil,nil,true)


    --敌方阵容
    display.newSprite("Block/blockSelected/select_img1.png")
    :addTo(blockBox)
    :pos(150, 470)
    --建议战力
    -- local bar = display.newSprite("Block/blockSelected/select_img5.png")
    -- :addTo(blockBox)
    -- :pos(330, 470)
    -- cc.ui.UILabel.new({UILabelType = 2, text = "当前战力：", size = 18, color = cc.c3b(120, 219, 79)})
    -- :addTo(bar)
    -- :pos(10, 36)
    -- cc.ui.UILabel.new({UILabelType = 2, text = "建议战力：", size = 18, color = cc.c3b(120, 219, 79)})
    -- :addTo(bar)
    -- :pos(10, 15)

    --怪物掉落数据
    local loc_Block
    if srv_userInfo.mainline==2 and curBlock.campType==1 then
        loc_Block = curBlock["monstersEvil"]
    else
        loc_Block = curBlock["monsters"]
    end
    local monsterStr=string.gsub(json.encode(loc_Block),"\"","")
    local monsterItem0=lua_string_split(monsterStr,"|")
    local monsterItem = {} --筛选后的怪物
    if curBlock["type3"]==1 then --如果有三场的，只显示第三场怪物
        for i=1,#monsterItem0 do
            local tmp_monsterItem0=monsterItem0[i]
            monsterItem0[i]=lua_string_split(monsterItem0[i],":")
            if blockData[block_idx].type==3 then
                local ArmyData=lua_string_split(srv_blockArmyData.tempo,"|")
                if block_progress_id==block_idx then            --正在打的军团关卡
                    if ArmyData[2]==nil then ArmyData[2]=1 end
                    if (ArmyData[2]+0)==(monsterItem0[i][2]+0) then
                        table.insert(monsterItem, tmp_monsterItem0)
                    end
                elseif (monsterItem0[i][2]+0)==3 then           --已经打完的军团关卡
                    table.insert(monsterItem, tmp_monsterItem0)
                end
                
            elseif (monsterItem0[i][2]+0)==3 and blockData[block_idx].type~=3 then --非军团关卡
                -- print(tmp_monsterItem0)
                table.insert(monsterItem, tmp_monsterItem0)
                -- monsterItem[#monsterItem+1] = tmp_monsterItem0
            end
        end
    elseif curBlock["type3"]==0 then --只有一场战斗的显示第一场的怪物
        for i=1,#monsterItem0 do
            local tmp_monsterItem0=monsterItem0[i]
            monsterItem0[i]=lua_string_split(monsterItem0[i],":")  
            if (monsterItem0[i][2]+0)==1 and blockData[block_idx].type~=3 then --非军团关卡
                table.insert(monsterItem, tmp_monsterItem0)
            end
        end
    end

    self.monsterLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 0, 0, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(80, 240, 610, 320),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(blockBox)
    -- self.monsterLv:setBounceable(false)
    --创建怪物
    for i=1,#monsterItem do
        if monsterStr=="null" then
            print("monsterItem is null")
            break
        else

        end
        local item = self.monsterLv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(120, 320)
        self.monsterLv:addItem(item)

        monsterItem[i]=lua_string_split(monsterItem[i],":")
        local enemybt = GlobalGetMonsterBt2(monsterItem[i][1], nil, {level = monsterItem[i][3]})
        :addTo(content)
        enemybt:setPosition(0,-40)
        enemybt:setTouchSwallowEnabled(false)
        if blockData[block_idx].type==3 then
            if block_progress_id==block_idx then
                self:MonsterProgress(enemybt,monsterItem[i][1]+0)
            elseif lgionFBResult==2 or block_idx%1000<block_progress_id%1000 then
                enemybt:setColor(cc.c3b(128, 128, 128))
                -- challengeBt:setVisible(false)
            end
            
        end
    end
    self.monsterLv:reload()

    --掉落物品
    display.newSprite("Block/blockSelected/select_img2.png")
    :addTo(blockBox)
    :pos(150, 200)
    local rewardStr=string.gsub(json.encode(curBlock["rewardItems"]),"\"","")
    local rewardItem=lua_string_split(rewardStr,"|")

    --活动掉落物品
    for key,value in pairs(srv_userInfo.actInfo.actTime) do
        if value.rewardItems and value.rewardItems~="null" and value.rewardItems~="" then
            local items = lua_string_split(value.rewardItems,"|")
            for k,v in ipairs(items) do
                local it = lua_string_split(v,":")
                table.insert(rewardItem, it[1])
            end
        end
    end

    self.rewardLv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(90, 80, 600, 200),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(blockBox)
    for i=1,#rewardItem  do
        if rewardStr=="null" then
            print("rewardItem is null")
            break
        end
        local item = self.rewardLv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(110, 200)
        self.rewardLv:addItem(item)

        rewardItem[i]=lua_string_split(rewardItem[i],":")
        local rewardbt = createItemIcon(rewardItem[i][1],rewardItem[i][3],true,{sacle = 1/0.9})
        :addTo(content)
        :scale(0.7)
        -- :pos(140+120*(i-1),133)
        :pos(0, -50)
    end
    self.rewardLv:reload()

    --剩余攻击次数
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "剩余攻击次数：", size = 23, color = cc.c3b(249, 202, 72)})
    :addTo(blockBox)
    :pos(120, 66)

    self.leftTimes = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 23, color = cc.c3b(249, 202, 72)})
    :addTo(blockBox)
    :pos(label:getPositionX() + label:getContentSize().width, label:getPositionY())
    if curBlock["ctimes"]==0 or Srv_curBlock==nil then
        Ltimes=1
    else
        if Srv_curBlock["buyCnt"]==nil then
            Ltimes = curBlock["ctimes"]-Srv_curBlock["dayCount"]
        else
            Ltimes = curBlock["ctimes"]*(Srv_curBlock["buyCnt"]+1)-Srv_curBlock["dayCount"]
        end
    end
    curBlock["ctimes"] = math.max(curBlock["ctimes"],1)
    self.leftTimes:setString(Ltimes.."/"..(curBlock["ctimes"]))

    --扫荡券数量显示
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "扫荡券：", size = 23, color = cc.c3b(249, 202, 72)})
    :addTo(blockBox)
    :pos(460, 66)

    local icon = display.newSprite("Item/item_"..itemData[SWEEP_TMPID].resId..".png")
    :addTo(blockBox)
    :pos(label:getPositionX()+label:getContentSize().width-10, 66)
    icon:setAnchorPoint(0,0.5)
    icon:setScale(0.5)

    self.sweepNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 23, color = cc.c3b(249, 202, 72)})
    :addTo(blockBox)
    :pos(icon:getPositionX()+icon:getContentSize().width-40,66)
    self.sweepNum:setAnchorPoint(0,0.5)
    sweepvalue = getSweepValue()
    if sweepvalue==nil then
        self.sweepNum:setString("0")
    else
        self.sweepNum:setString(sweepvalue.cnt)
    end

    --星级
    for i=1,3 do
        display.newSprite("Block/blockSelected/select_img7.png")
        :addTo(blockBox)
        :pos(810 + (i-1)*90, boxsize.height-80)
    end
    if (curBlock.type==1 or curBlock.type==2) and curBlock.ctype==1 then
        for i=1,Srv_curBlock["star"] do
            local starImg = display.newSprite("Block/blockSelected/select_img8.png")
            :addTo(blockBox)
            :pos(810 + (i-1)*90, boxsize.height-80)
        end
    else
    end
    --三星通关奖励
    display.newSprite("Block/blockSelected/select_img6.png")
    :addTo(blockBox)
    :pos(840, boxsize.height - 170)
    display.newSprite("Block/blockSelected/select_img4.png")
        :addTo(blockBox)
        :pos(960, boxsize.height - 170)
        :scale(1.2)
    --奖励物品
    if curBlock.starReward~="null" and curBlock.starReward~=0 then
        local allstarRewards = lua_string_split(curBlock.starReward,"|")
        for i=1,#allstarRewards do
            
            local rewardItem = lua_string_split(allstarRewards[i],"#")
            local rewardbt = createItemIcon(rewardItem[1],rewardItem[2],true,true,2)
            :addTo(blockBox)
            :scale(0.7)
            :pos(960+120*(i-1), boxsize.height - 170)
        end
    end

    --只有车战才推荐特种弹
    local second = math.modf(block_idx/1000000)%10
    if second==2 then
        display.newSprite("Block/blockSelected/select_img3.png")
        :addTo(blockBox)
        :pos(870, boxsize.height - 250)


        -- 特种弹图标
        -- for i=1,3 do
        --     display.newSprite("Block/blockSelected/select_img10.png")
        --     :addTo(blockBox)
        --     :pos(800+(i-1)*50,  boxsize.height -340)
        -- end
        function getBulletsTmpId(n)
            if n==1 then
                return 1075006
            elseif n==2 then
                return 1075005
            elseif n==3 then
                return 1075008
            elseif n==4 then
                return 1075003
            end
            return
        end
        local bullets = lua_string_split(curBlock.special,"#")
        for i=1,#bullets do
            display.newSprite("Block/blockSelected/select_img10.png")
            :addTo(blockBox)
            :pos(800+(i-1)*50,  boxsize.height -340)
            local bullettmpId = getBulletsTmpId(tonumber(bullets[i]))
            local bulletSpr = display.newSprite("Item/item_"..bullettmpId..".png")
            :addTo(blockBox)
            :pos(800+(i-1)*50,  boxsize.height -340)
            -- :scale(0.8)
            :setRotation(-90)
        end
        

        cc.ui.UIPushButton.new("Block/blockSelected/select_img9.png")
        :addTo(blockBox)
        :pos(boxsize.width - 100,  boxsize.height -340)
        :onButtonPressed(function(event) event.target:setScale(0.95) end)
        :onButtonRelease(function(event) event.target:setScale(1.0) end)
        :onButtonClicked(function(event)
            DCEvent.onEvent("关卡特种弹推荐点击")
            local shop = shopLayer.new(4)
            :addTo(self)
            end)
    end

    --挑战按钮
    challengeBt = cc.ui.UIPushButton.new("Block/blockSelected/select_img14.png")
    :addTo(blockBox)
    :pos(boxsize.width - 75, 115)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :onButtonClicked(function(event)
        if blockData[block_idx].type==3 then
            if lgionFBResult==2 or block_idx%1000<block_progress_id%1000 then
                showTips("该关卡怪物已打死，重置后可进入")
                return
            end
        end
        curFightBlockId = block_idx --用于军团副本（因为军团副本返回没有赋值curFightBlockId）
        if blockData[block_idx].type==3 and lgionFBResult==3 then
            showMessageBox("有其他成员正在挑战中，\n请稍后再试！")
            return
        elseif blockData[block_idx].type==3 and lgionFBResult==4 then
            showMessageBox("怪物休息中！")
            return
        elseif blockData[block_idx].type==3 and lgionFBResult==5 then
            showMessageBox("达到每日最大通关次数！")
            return
        end
        if blockData[block_idx].energyCost>srv_userInfo["energy"] then
            isSweepBuyEnergy = true
            addEnergy()
            return
        elseif Ltimes==0 and curBlock.type==2 then
            if srv_userInfo.vip<2 then
                showTips("vip等级到2级解锁重置精英关卡功能。")
                return
            elseif vipLevelData[srv_userInfo.vip]==nil or 
                vipLevelData[srv_userInfo.vip].blockCnt<=Srv_curBlock["buyCnt"] then
                showMessageBox("今日已重置精英关卡"..Srv_curBlock["buyCnt"].."次，"..
                    "重置精英关卡次数不足，提升vip等级可获得更多次数。")
            else
                showMessageBox("重置关卡进入次数需要花费"..eBlockPurchaseData[Srv_curBlock["buyCnt"]+1].cdiamond1.."钻石，"..
                    "是否继续（今日已重置"..Srv_curBlock["buyCnt"].."次）", handler(self, self.sendEBlockPurchase))
            end
            -- showMessageBox("msg", okListener)
            return
        end
        startLoading()
        GuideManager:removeGuideLayer()
        local layer
        if blockData[block_idx].type==3 then
            
            local comData = {areaId = blockData[block_idx].areaId}
            m_socket:SendRequest(json.encode(comData), CMD_LEGION_PVE_CHECK, self, self.getIfLegionCanFight)
        else
            BlockUI.Instance = nil
            layer = EmbattleScene.new({BattleType_PVE, block_idx})
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer, 52)
        end
        
    end)
    curGuideBtn= challengeBt

    --消耗燃油
    local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 16, color = cc.c3b(255, 240, 166)})
    :addTo(challengeBt)
    :pos(32,39)
    label:setRotation(45)
    label:setString(curBlock["energyCost"])

    local physicalNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 16})
    :addTo(challengeBt)
    :align(display.CENTER, 0, 0)
    physicalNum:setColor(cc.c3b(255, 240, 166))
    physicalNum:setString(curBlock["energyCost"])
    self.physicalNum = physicalNum

    --扫荡多次
    local sweepThreetimesBt = cc.ui.UIPushButton.new("Block/blockSelected/select_img15.png")
    :addTo(blockBox)
    :pos(boxsize.width - 240, 70)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    display.newSprite("Block/blockSelected/select_img16.png")
    :addTo(sweepThreetimesBt)
    :pos(0,5)
    self.sweepCnt = display.newSprite()
    :addTo(sweepThreetimesBt)
    :pos(15,5)

    --扫荡一次
    local sweepBt = cc.ui.UIPushButton.new("Block/blockSelected/select_img15.png")
    :addTo(blockBox)
    :pos(boxsize.width - 240, 155)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    display.newSprite("Block/blockSelected/select_img17.png")
    :addTo(sweepBt)
    :pos(0,5)

    
    if curBlock.type==1 then
        self.sweepCnt:setTexture("Block/blockSelected/select_img28.png")
    elseif curBlock.type==2 then
        if Ltimes==0 then
            -- self.sweepCnt:setString("无法扫荡")
            self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
        else
            if Ltimes==1 then
                self.sweepCnt:setTexture("Block/blockSelected/select_img25.png")
            elseif Ltimes==2 then
                self.sweepCnt:setTexture("Block/blockSelected/select_img26.png")
            elseif Ltimes==3 then
                self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
            else
                print(Ltimes)
                self.sweepCnt:setString("扫荡"..Ltimes.."次")
            end
        end
    end
    sweepBt:onButtonClicked(function(event)
        if srv_userInfo.level<10 then
            showTips("10级开启扫荡功能。")
            return
        end
        curSweepNum = 1
        -- if srv_userInfo.vip<1 then
        --  showTips("vip等级到1级解锁该功能。")
        --  return
        -- end

        if blockData[block_idx].energyCost>srv_userInfo["energy"] then --燃油判断
            isSweepBuyEnergy = true
            addEnergy()
            return
        elseif Ltimes==0 then --挑战次数判断
            if Srv_curBlock["buyCnt"] then
                if srv_userInfo.vip<2 then
                    showTips("vip等级到2级解锁重置精英关卡功能。")
                    return
                elseif vipLevelData[srv_userInfo.vip]==nil or 
                    vipLevelData[srv_userInfo.vip].blockCnt<=Srv_curBlock["buyCnt"] then
                    showMessageBox("今日已重置精英关卡"..Srv_curBlock["buyCnt"].."次，"..
                        "重置精英关卡次数不足，提升vip等级可获得更多次数。")
                else
                    showMessageBox("重置关卡进入次数需要花费"..eBlockPurchaseData[Srv_curBlock["buyCnt"]+1].cdiamond1.."钻石，"..
                        "是否继续（今日已重置"..Srv_curBlock["buyCnt"].."次）", handler(self, self.sendEBlockPurchase))
                end
            else
                showTips("达到每日最大通关次数！")
            end
            return
        end
        --扫荡券数量判断
        sweepvalue = getSweepValue()
        self.costSweep = 0
        if sweepvalue==nil or sweepvalue.cnt<curSweepNum then
            if sweepvalue==nil then
            else
                self.costSweep = sweepvalue.cnt
            end
            needSweepDiamond = curSweepNum
            showMessageBox("扫荡券不足，花费1钻石扫荡1次？", function ( ... )
                DCEvent.onEvent("扫荡一次", "钻石抵扫荡券")
                self:sendSweep()
            end)
        else
            self.costSweep = curSweepNum
            needSweepDiamond = 0
            self:sendSweep()
            DCEvent.onEvent("扫荡一次")
        end
    end)

    sweepThreetimesBt:onButtonClicked(function(event)
        if srv_userInfo.level<10 then
            showTips("10级开启扫荡功能。")
            return
        end
        if srv_userInfo.vip<3 then
            showTips("vip等级到3级解锁该功能。")
            return
        end

        if curBlock.type==1 and  Ltimes<10 then
            showTips("剩余攻击次数不足十次")
            return
        end

        if curBlock.type==1 then
            curSweepNum = 10
        elseif curBlock.type==2 then
            if Ltimes==0 then
                curSweepNum = 0
                -- showTips("无法扫荡")
                -- return
            else
                curSweepNum = Ltimes
            end
        end
        --燃油判断
        if blockData[block_idx].energyCost*curSweepNum>srv_userInfo["energy"] then
            isSweepBuyEnergy = true
            addEnergy()
            return
        elseif Ltimes==0 then --挑战次数判断
            if srv_userInfo.vip<2 then
                showTips("vip等级到2级解锁重置精英关卡功能。")
                return
            elseif vipLevelData[srv_userInfo.vip]==nil or 
                vipLevelData[srv_userInfo.vip].blockCnt<=Srv_curBlock["buyCnt"] then
                showMessageBox("今日已重置精英关卡"..Srv_curBlock["buyCnt"].."次，"..
                    "重置精英关卡次数不足，提升vip等级可获得更多次数。")
            else
                showMessageBox("重置关卡进入次数需要花费"..eBlockPurchaseData[Srv_curBlock["buyCnt"]+1].cdiamond1.."钻石，"..
                    "是否继续（今日已重置"..Srv_curBlock["buyCnt"].."次）", handler(self, self.sendEBlockPurchase))
            end
            -- showMessageBox("msg", okListener)
            return
        end
        --扫荡券判断（不足消耗钻石）
        sweepvalue = getSweepValue()
        self.costSweep = 0
        if sweepvalue==nil or sweepvalue.cnt<curSweepNum then
            if sweepvalue==nil then
                needSweepDiamond = curSweepNum
            else
                self.costSweep = sweepvalue.cnt
                needSweepDiamond = curSweepNum - sweepvalue.cnt
            end
            
            showMessageBox("扫荡券不足，花费"..needSweepDiamond.."钻石扫荡"..curSweepNum.."次？", function ()
                DCEvent.onEvent("扫荡"..curSweepNum.."次", "钻石抵扫荡券")
                self:sendSweep()
            end)
        else
            self.costSweep = curSweepNum
            needSweepDiamond = 0
            self:sendSweep()
            DCEvent.onEvent("扫荡"..curSweepNum.."次")
        end
    end)
    local function isShowSweep(b)
        if b==true then
            sweepBt:setVisible(true)
            sweepThreetimesBt:setVisible(true)
        else
            sweepBt:setVisible(false)
            sweepThreetimesBt:setVisible(false)
        end
    end
    if Srv_curBlock == nil then
        isShowSweep(false)
    elseif curBlock.ctype==1 and Srv_curBlock["star"]==3 then
        isShowSweep(true)
    else
        isShowSweep(false)
    end
	
	GuideManager:removeGuideLayer()
    GuideManager:_addGuide_2(10104, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11304, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10504, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(10204, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11104, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11205, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11604, masklayer,handler(self,self.caculateGuidePos))
    GuideManager:_addGuide_2(11704, masklayer,handler(self,self.caculateGuidePos))

    --未知原因，BlockUI:onEnter()未被调用，于是在这里手动调用
    self:onEnter()
end

--获取军团副本当前能否挑战
function BlockUI:getIfLegionCanFight(cmd)
    if cmd.result==1 then
        BlockUI.Instance = nil
        layer = EmbattleScene.new({BattleType_Legion, block_idx})
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer, 52)
    else
        showMessageBox("有其他成员正在挑战中，\n请稍后再试！")
    end
end

function BlockUI:MonsterProgress(parentNode,monsterTmpId)
	-- print(monsterTmpId)
	local proNum
	if (#srv_blockArmyData.tempo==8) then
		proNum = 100
	else
		local allBlood=0
		local restBlood=0
		local monstersArr = lua_string_split(blockData[block_idx].monsters, "|")
		for i,value in ipairs(monstersArr) do
			monsterTmpIdArr = lua_string_split(value, ":")
			if monsterTmpId==(monsterTmpIdArr[1]+0) then
				allBlood = getMonsterBlood(tonumber(monsterTmpIdArr[1]),tonumber(monsterTmpIdArr[3]))
				-- monsterData[monsterTmpIdArr[1]+0].hp+monsterData[monsterTmpIdArr[1]+0].hpGF*(monsterTmpIdArr[3]-1)
				break
			end
		end
		
		local ArmyData=lua_string_split(srv_blockArmyData.tempo,"|")
		local monsters = lua_string_split(ArmyData[3],";")
		for i=1,#monsters do
			mont = lua_string_split(monsters[i],":")
			if (mont[1]+0)==monsterTmpId then
				restBlood = mont[2]+0
				break
			end
		end
		proNum = restBlood/allBlood
	end

	if proNum==0 then
		parentNode:setColor(cc.c3b(128, 128, 128))
		return 
	end

	local mScale = 0.3
    local progress1 = display.newSprite("Battle/xxxttu_d02-06.png")
    :addTo(parentNode)
    -- :scale(mScale)
    :pos(0, -105)
    local progress2 = cc.Sprite:create("Battle/xxxttu_d02-07.png",cc.rect(0,0,300*proNum,13))
    :addTo(progress1)
    progress2:setAnchorPoint(0,0)
	-- progress2:setPercent(proNum*100)
end



function BlockUI:addSweepBox(curEnergy)
	--扫荡遮罩
    self.weepMask = UIMasklayer.new({bAlwaysExist=true})
    :addTo(masklayer, 2)
    local function  func()
        self.weepMask:removeSelf()
    end
    self.weepMask:setOnTouchEndedEvent(func)
  --   sweepBox = display.newScale9Sprite("common/common_Frame2.png",display.cx, 
		-- display.cy,
		-- cc.size(499, 568),cc.rect(135, 87, 93, 54))
	sweepBox = display.newSprite("common/common_box.png")
    :addTo(self.weepMask)
    :pos(display.cx,display.cy)
    self.weepMask:addHinder(sweepBox)
    local tmpsize = sweepBox:getContentSize()

    display.newSprite("Block/sweep/sweep_img9.png")
    :addTo(sweepBox)
    :pos(240, tmpsize.height - 50)

    local cntImg = display.newSprite()
    :addTo(sweepBox)
    :pos(277, tmpsize.height - 47)
    if curSweepNum==1 then
        cntImg:setTexture("Block/sweep/sweep_img4.png")
    elseif curSweepNum==2 then
        cntImg:setTexture("Block/sweep/sweep_img1.png")
    elseif curSweepNum==3 then
        cntImg:setTexture("Block/sweep/sweep_img3.png")
    elseif curSweepNum==10 then
        cntImg:setTexture("Block/sweep/sweep_img2.png")
    end

    --消耗体力
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "消耗     ：", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(sweepBox)
    :pos(tmpsize.width/2 - 50, tmpsize.height - 100)
    display.newSprite("common/common_Stamina.png")
    :addTo(sweepBox)
    :pos(label:getPositionX()+70, label:getPositionY()+5)
    :scale(0.8)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text =srv_userInfo.energy - curEnergy , 
        size = 25, 
        color = cc.c3b(248, 182, 45)})
    :addTo(sweepBox)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())

    --剩余体力
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "剩余     ：", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(sweepBox)
    :pos(tmpsize.width/2 + 180, tmpsize.height - 100)
    display.newSprite("common/common_Stamina.png")
    :addTo(sweepBox)
    :pos(label:getPositionX()+70, label:getPositionY()+5)
    :scale(0.8)

    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text =curEnergy , size = 25, 
        color = cc.c3b(248, 182, 45)})
    :addTo(sweepBox)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())


    sweepvalue = getSweepValue()
    local lestCnt
    if sweepvalue==nil then
        lestCnt = 0
    else
        lestCnt = sweepvalue.cnt
    end
    -- --消耗扫荡券
    -- local label = cc.ui.UILabel.new({UILabelType = 2, text = "消耗扫荡券：", size = 25, color = cc.c3b(0, 160, 233)})
    -- :addTo(sweepBox)
    -- :pos(tmpsize.width/2 + 180, tmpsize.height - 100)

    -- cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text =self.costSweep , size = 25, 
    --     color = cc.c3b(248, 182, 45)})
    -- :addTo(sweepBox)
    -- :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())


    --剩余扫荡券
    local label = cc.ui.UILabel.new({UILabelType = 2, text = "剩余扫荡券：", size = 25, color = cc.c3b(0, 160, 233)})
    :addTo(sweepBox)
    :pos(80, 30)

    
    cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = lestCnt , size = 25, 
        color = cc.c3b(248, 182, 45)})
    :addTo(sweepBox)
    :pos(label:getPositionX()+label:getContentSize().width, label:getPositionY())

    --关闭按钮
	local backBt = cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
	:addTo(sweepBox)
	:pos(tmpsize.width-20,tmpsize.height-20)
    
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
	backBt:onButtonClicked(function(event)
		sweepBox:setVisible(false)
		self.weepMask:setVisible(false)
		end)
	--继续扫荡按钮
	local go_onBt = cc.ui.UIPushButton.new("common/common_nBt2.png")
	:addTo(sweepBox)
	:pos(sweepBox:getContentSize().width - 183,5)
    :onButtonPressed(function(event) event.target:setScale(0.95) end)
    :onButtonRelease(function(event) event.target:setScale(1.0) end)
    :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = "继续扫荡", size = 27, 
                    color = cc.c3b(127, 79, 33)}))
    setLabelStroke(go_onBt:getButtonLabel(),27,cc.c3b(254, 255, 159),1,nil,nil,nil,nil, true)
	go_onBt:onButtonClicked(function(event)
        if curBlock.type==1 and curSweepNum==10 and Ltimes<10 then
            showTips("剩余攻击次数不足十次")
            return
        end

		if blockData[block_idx].energyCost*curSweepNum>srv_userInfo["energy"] then --燃油不足
			isSweepBuyEnergy = true
			addEnergy()
			sweepBox:setVisible(false)
			self.weepMask:setVisible(false)
			return
		elseif Ltimes==0 then --挑战次数判断
            if Srv_curBlock["buyCnt"] then
    			if vipLevelData[srv_userInfo.vip]==nil or 
    				vipLevelData[srv_userInfo.vip].blockCnt<=Srv_curBlock["buyCnt"] then
    				showMessageBox("今日已重置精英关卡"..Srv_curBlock["buyCnt"].."次，"..
    					"重置精英关卡次数不足，提升vip等级可获得更多次数。")
    			else
    				showMessageBox("重置关卡进入次数需要花费"..eBlockPurchaseData[Srv_curBlock["buyCnt"]+1].cdiamond1.."钻石，"..
    					"是否继续（今日已重置"..Srv_curBlock["buyCnt"].."次）", handler(self, self.sendEBlockPurchase))
    			end
    			-- showMessageBox("msg", okListener)
    			sweepBox:setVisible(false)
    			self.weepMask:setVisible(false)
            else
                showTips("达到每日最大通关次数！")
            end
			return
		end

		-- --扫荡券判断（不足消耗钻石）
		sweepvalue = getSweepValue()
        self.costSweep = 0
		if sweepvalue==nil or sweepvalue.cnt<curSweepNum then
			if sweepvalue==nil then
				needSweepDiamond = curSweepNum
			else
				needSweepDiamond = curSweepNum - sweepvalue.cnt
                self.costSweep = sweepvalue.cnt
			end
            showMessageBox("扫荡券不足，花费"..needSweepDiamond.."钻石扫荡"..curSweepNum.."次？", function ()
				DCEvent.onEvent("扫荡"..curSweepNum.."次", "钻石抵扫荡券")
				self:sendSweep()
			end)
		else
            self.costSweep = curSweepNum
			needSweepDiamond = 0
            self:sendSweep()
            DCEvent.onEvent("扫荡"..curSweepNum.."次")
		end
		sweepBox:setVisible(false)
		self.weepMask:setVisible(false)

	end)
	-- sweepBox:removeChildByTag(500)
	self.sweeplv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        bgScale9 = true,
        viewRect = cc.rect(5, 60, 875, 470),
        -- alignment = cc.ui.UIScrollView.ALIGNMENT_BOTTOM,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(sweepBox)

end
function BlockUI:updateListView()
	-- sweepBox:removeChildByTag(100)
	if self.sweeplv==nil then
		return
	end
	self.sweeplv:removeAllItems()
	showFightCnt = 1

	self:showRewardItem()

	self.sweeplv:reload()
end

function BlockUI:showRewardItem()
	if showFightCnt>#blockSweepData.rewardItems then
		print("return2")
		-- self.sweeplv:reload()

		return
	end
	--新手升级时直接返回主界面判断，这时找不到该值
	if self.sweeplv==nil then
		return
	end
	-- print("showFightCnt,"..showFightCnt)
	local rewardList = blockSweepData.rewardItems[showFightCnt]

		local k = #rewardList
        if #rewardList==0 then
        	k = 1
        end
        local extraH = (math.ceil(k/4)-1)*100/2
        if self.sweeplv:newItem()==nil then
        	return
        end
		local item = self.sweeplv:newItem()
        local content = display.newNode()
        item:addContent(content)
        item:setItemSize(380, 155+(math.ceil(k/4)-1)*100)
        self.sweeplv:addItem(item)

        local itemW,itemH = item:getItemSize()
        --上线
        local topLine = display.newSprite("Block/sweep/sweep_img7.png")
        :addTo(content)
        :pos(0, itemH/2-5)
        :setScaleY(1.67)
        --下线
        local bottomLine = display.newSprite("Block/sweep/sweep_img7.png")
        :addTo(content)
        :pos(0, -itemH/2+10)
        :setScaleY(1.67)
        --枪
        display.newSprite("Block/sweep/sweep_img10.png")
        :addTo(content)
        :pos(90-itemW/2, 5)
        --数字
        local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = showFightCnt, size = 70, color = cc.c3b(0, 160, 233)})
        :addTo(content, 2)
        :align(display.CENTER, 100-itemW/2, -5)
        setLabelStroke(label,70,nil,nil,nil,nil,nil,"fonts/slicker.ttf", true)

        local goldStr = lua_string_split(blockData[block_idx].gold,"|")
        local gold = 0
        for i=1,#goldStr do
            gold = gold + goldStr[i]
        end
        --金币
        local img = display.newSprite("common/common_GoldGet.png")
        :addTo(content)
        :pos(220-itemW/2, 20)
        local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "X"..gold, size = 25})
        :addTo(content, 2)
        :align(display.CENTER, img:getPositionX(), img:getPositionY() - 60)

        --经验
        local img = display.newSprite("common/common_Exp.png")
        :addTo(content)
        :pos(340-itemW/2, 20)
        local label = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "X"..blockData[block_idx].exp, size = 25})
        :addTo(content, 2)
        :align(display.CENTER, img:getPositionX(), img:getPositionY() - 60)
        
        
        --循环显示获得物品逻辑
        local idx = 1
        local dTime = 0.2
        function showItem()
        	if not sweepBox:isVisible() then
        		return
        	end

        	local i = math.ceil(idx/4)
        	local j = idx%4
        	if j==0 then
        		j=4
        	end
        	-- print(i,j)
        	if ((i-1)*4+j)>#rewardList then
        		print("return")
        		-- print(showFightCnt)
        		scheduler.performWithDelayGlobal(handler(self, self.showRewardItem), dTime+0.2)
        		-- self:showRewardItem()
        		return
        	end
        	local itemImg = createItemIcon(rewardList[(i-1)*4+j].tmpId,rewardList[(i-1)*4+j].cnt)
		        :addTo(content)
		        :pos(150+(j-2)*110,(-(i-1)*100)+extraH)
		        itemImg:setTouchSwallowEnabled(false)
		        itemImg:setScale(1.2)
		        -- itemImg:setOpacity(0)
		        itemImg:scaleTo(dTime, 0.8)
		        transition.fadeIn(itemImg, {time = dTime,
		        	onComplete = function()
			        showItem()
			    end})
		    idx = idx + 1
        end

        --显示获得物品
        if #rewardList~=0 then
        	showItem()
        end

        self.sweeplv:reload()
        if showFightCnt>=3 then
        	self.sweeplv:setContentPos(0, -itemH , false)
        	self.sweeplv:setContentPos(0, 0 , true) 
        end
        
        showFightCnt = showFightCnt + 1

        if #rewardList==0 then
        	self:showRewardItem()
        end
end
function BlockUI:sendSweep()
    -- self:addSweepBox(100)
	startLoading()
	sendData={}
	sendData["blockId"] = block_idx
	sendData["num"] = curSweepNum
	m_socket:SendRequest(json.encode(sendData), CMD_SWEEP, self, self.onSweep)
end
function BlockUI:onSweep(result)

	endLoading()
	if result.result==1 then
		--弹出扫荡框
		self:addSweepBox(result.data.energy)
		--更新剩余攻击次数
		srv_blockData[block_idx].dayCount = srv_blockData[block_idx].dayCount + curSweepNum
		if Srv_curBlock["buyCnt"]==nil then
			Ltimes = curBlock["ctimes"]-Srv_curBlock["dayCount"]
		else
			Ltimes = curBlock["ctimes"]*(Srv_curBlock["buyCnt"]+1)-Srv_curBlock["dayCount"]
		end
		self.leftTimes:setString(Ltimes.."/"..(curBlock["ctimes"]))
		--更新扫荡次数按钮
		if curBlock.type==2 then
			if Ltimes==0 then
				-- self.sweepCnt:setString("无法扫荡")
				self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
			else
				if Ltimes==1 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img25.png")
				elseif Ltimes==2 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img26.png")
				elseif Ltimes==3 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
				else
                    print(Ltimes)
					-- self.sweepCnt:setString("扫荡"..Ltimes.."次")
				end
			end
		end
		--更新扫荡券数量
		sweepvalue = getSweepValue()
		if sweepvalue==nil then
			self.sweepNum:setString("：0")
		else
			self.sweepNum:setString("："..sweepvalue.cnt)
		end

		self.weepMask:setVisible(true)
		sweepBox:setVisible(true)
		self:updateListView()
		
		for i=1,#blockSweepData.rewardItems do
			local arr = blockSweepData.rewardItems[i]
			for j=1,#arr do
				local _reward = arr[j]
				local dc_item = itemData[_reward.tmpId]
				DCItem.get(tostring(dc_item.id), dc_item.name, _reward.cnt, "扫荡掉落:"..block_idx)
			end
		end
		DCCoin.gain("扫荡掉落:"..block_idx,"金币",result.data.gold-srv_userInfo.gold,result.data.gold)

		--扣钻石
		if needSweepDiamond>0 then
			srv_userInfo.diamond = srv_userInfo.diamond - needSweepDiamond
			DCCoin.lost("钻石荡券","钻石",needSweepDiamond,srv_userInfo.diamond)
			mainscenetopbar:setDiamond()
		end
		
		--更新金币，燃油，等级，经验数据及显示
		srv_userInfo.maxexp = result.data.maxExp
		srv_userInfo.gold = result.data.gold
		srv_userInfo.energy = result.data.energy
		srv_userInfo.exp = result.data.exp
		mainscenetopbar:setGlod()
		SetEnergyAndCountDown(srv_userInfo.energy)
		

	else
		showTips(result.msg)
	end
end

function BlockUI:showSweepNum(mtype)
	-- for i=100,103 do
	-- 	msgPanel:removeChildByTag(i)
	-- end

	if mtype==false then
		return
	end
	
	local name = cc.ui.UILabel.new({UILabelType = 2, text = "扫荡券：", size = 25})
	:addTo(self.btBar,0,100)
	:pos(20,37)
	name:setColor(cc.c3b(0, 255, 0))
	name:setAnchorPoint(0,0.5)
	local icon = display.newSprite("Item/item_"..itemData[SWEEP_TMPID].resId..".png")
	:addTo(self.btBar,0,101)
	:pos(20+name:getContentSize().width,37)
	icon:setAnchorPoint(0,0.5)
	icon:setScale(0.8)
	self.sweepNum = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
	:addTo(self.btBar,0,102)
	:pos(icon:getPositionX()+icon:getContentSize().width-10,37)
	self.sweepNum:setAnchorPoint(0,0.5)
	sweepvalue = getSweepValue()
	if sweepvalue==nil then
		self.sweepNum:setString("：0")
	else
		self.sweepNum:setString("："..sweepvalue.cnt)
	end
	
end
function BlockUI:sendEBlockPurchase()
	startLoading()
	sendData={}
	sendData["blockId"] = block_idx
	m_socket:SendRequest(json.encode(sendData), CMD_EBLOCK_PURCHASE, self, self.onEBlockPurchase)
end
function BlockUI:onEBlockPurchase(result)
	endLoading()
	if result.result == 1 then
		--更新剩余攻击次数
		srv_blockData[block_idx].buyCnt = srv_blockData[block_idx].buyCnt + 1
		Ltimes = curBlock["ctimes"]*(Srv_curBlock["buyCnt"]+1)-Srv_curBlock["dayCount"]
		self.leftTimes:setString(Ltimes.."/"..(curBlock["ctimes"]))
		--更新扫荡次数按钮
		if curBlock.type==2 then
			if Ltimes==0 then
				-- self.sweepCnt:setString("无法扫荡")
				self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
			else
				if Ltimes==1 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img25.png")
				elseif Ltimes==2 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img26.png")
				elseif Ltimes==3 then
					self.sweepCnt:setTexture("Block/blockSelected/select_img27.png")
				else
					-- self.sweepCnt:setString("扫荡"..Ltimes.."次")
				end
			end
		end
		--扣钻石
		srv_userInfo.diamond = srv_userInfo.diamond - eBlockPurchaseData[Srv_curBlock["buyCnt"]].cdiamond1
		mainscenetopbar:setDiamond()
        --数据统计
        luaStatBuy("精英关卡次数", BUY_TYPE_BLOCK_CNT, 1, 
            "钻石", eBlockPurchaseData[Srv_curBlock["buyCnt"]].cdiamond1)
	else
		showTips(result.msg)
	end
end

function BlockUI:onEnter()
    -- BlockUI.Instance = self
	setIgonreLayerShow(false)--新手引导触摸遮罩，要么成功添加引导后关闭，要么在onEnter里面关闭
end
function BlockUI:onExit()
    -- BlockUI.Instance = nil
    blockUI_Instance = nil
end

function BlockUI:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)

    if 10105==_guideId or 11304 ==_guideId or 10104 ==_guideId or 10504 ==_guideId or 11604 ==_guideId or 11704 ==_guideId 
    or 11204 ==_guideId or 20405 ==_guideId or 10204 ==_guideId or 11104 ==_guideId or 11205 ==_guideId then
        g_node = curGuideBtn
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

return BlockUI