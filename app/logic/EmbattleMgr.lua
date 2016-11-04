--
-- Author: Jun Jiang
-- Date: 2014-11-13 16:32:58
--

require("app.battle.BattleInfo")
-------------------------宏/常量----------------------------
BULLETSLOTNUM = 3       --弹仓数量(未开启的也算)

--排位分组
EmbattleGroup_Main		= 1 		--主战位
EmbattleGroup_Pull		= 2 		--牵引位

BattleNum_Main 			= 5 		--主战位数量
BattleNum_Pull			= 0 		--牵引位数量

--操作类型
EmbattleType_OnBattle	= 1 		--上阵
EmbattleType_OffBattle	= 2 		--下阵

--阵型类型
BattleType_PVE 			= 1 		--PVE
BattleType_PVP 			= 2 		--PVP
BattleType_Legion		= 3 		--军团
BattleType_EXPEDITION   = 4			--远征布阵
BattleType_WorldBoss    = 5			--世界BOSS
BattleType_PVP_DEF 		= 6 		--PVP防守阵形
------------------------------------------------------------

EmbattleMgr = class("EmbattleMgr")
EmbattleMgr.nCurBattleType 	= nil 	--当前布阵类型(不要直接修改)
EmbattleMgr.curInfo 		= nil 	--当前信息(布阵、特种弹等界面需要的全部信息)
EmbattleMgr.oldMatrix 		= nil 	--旧的阵型信息(进入界面最初的布阵)
EmbattleMgr.idKeyList 		= nil 	--以id为key值的列表

EmbattleMgr.PVEInfo			= nil
EmbattleMgr.PVPInfo			= nil
EmbattleMgr.isReqPVEFlag    = true  --是否请求普通关卡布阵信息的标志位
EmbattleMgr.isReqPVPFlag	= true	--是否请求PVP布阵信息的标志位

memberType = {}
memberType.TYPE_MAN_AND_CAR = 1
memberType.TYPE_MAN_ONLY = 2
memberType.TYPE_CAR_ONLY = 3

local function getRentCost(carInfo)
    local index,cost = 0,0
    if carInfo.record==nil or carInfo.record==0 then
        return 1,math.ceil(carInfo.strength*5.2)
    elseif carInfo.record==1 then
        return 2,30
    elseif carInfo.record==2 then
        return 2,50
    end
    return index,cost
end

--获取布阵信息
--@nType: 布阵类型
function EmbattleMgr:ReqEmbattleInfo(nType)
	local tabMsg, cmdKey = nil, nil
	self.nCurBattleType = nType
	if BattleType_PVE==nType or BattleType_Legion==nType then
		tabMsg = {characterId=srv_userInfo.characterId, blockId=block_idx}
		cmdKey = CMD_EMBATTLE_GETINFO

		m_socket:SendRequest(json.encode(tabMsg), cmdKey, self, self.OnEmbattleInfoRet)
	elseif BattleType_PVP==nType or BattleType_PVP_DEF==nType then
		startLoading()
		tabMsg = {characterId=srv_userInfo.characterId}
		cmdKey = CMD_PVP_MATRIXINFO
		m_socket:SendRequest(json.encode(tabMsg), cmdKey, self, self.OnEmbattleInfoRet)

	elseif BattleType_EXPEDITION==nType then
		tabMsg = nil
		cmdKey = nil
		self:OnEmbattleInfoRet(EmbattleScene.Instance.args[3])

	elseif BattleType_WorldBoss==nType then
		tabMsg = nil
		cmdKey = nil
		self:OnEmbattleInfoRet(EmbattleScene.Instance.args[3])
	end
end

--请求战斗(只发修改了的信息)
--@args: BattleType_PVE(关卡ID) BattleType_PVP(敌方ID)
function EmbattleMgr:ReqFight(args)
	local nRet = self:CheckFightCondition()
	if 0~=nRet then
		return nRet
	end

	prama2 = prama2 or nil

	local cmdKey = nil
	local callB = nil
	
	local modifyMatrix = self:getModifyMatrix()


	if BattleType_PVE==self.nCurBattleType or BattleType_Legion==self.nCurBattleType then
		if nil~=args then
			modifyMatrix.blockId = args
			cmdKey = CMD_FIGHT_PREPARE
		end
	elseif BattleType_PVP==self.nCurBattleType then
		if nil~=args then
			modifyMatrix.eId = args
			cmdKey = CMD_PVP_FIGHT
		end
	elseif BattleType_WorldBoss==self.nCurBattleType then
		--世界BOSS的处理
	end

	if nil~=cmdKey then
		nRet = 0
		m_socket:SendRequest(json.encode(modifyMatrix), cmdKey, self, self.OnReqFightRet)
	else
		nRet = -1 --nType值有误
	end

	return nRet
end

function EmbattleMgr:getModifyMatrix()
	local modifyMatrix = {}
	for k, v in pairs(self.curInfo.matrix) do
		if k=="characterId" then
			modifyMatrix[k] = v
		else
			if self.oldMatrix[k]~=self.curInfo.matrix[k] then
				modifyMatrix[k] = self.curInfo.matrix[k]
			end
		end
	end

	if EmbattleScene.Instance._rentInfo~=nil then
		local car = EmbattleScene.Instance._rentInfo
		modifyMatrix.renter = car.driver or car.tptId
        modifyMatrix.rentIdx = car._pos
        modifyMatrix.rCnt = (car.record or 0) +1
        local i,v = getRentCost(car)
        if srv_userInfo.isFirstRent==1 then
            v = 0
        end
        modifyMatrix.rCost = v
	end
	print("modifyMatrix: ")
	printTable(modifyMatrix)
	-- writeTabToLog(modifyMatrix,"modifyMatrix: ","gggg.txt")
	-- writeTabToLog({main1 = self.curInfo.matrix["main1"],main2 = self.curInfo.matrix["main2"],main3 = self.curInfo.matrix["main3"],main4 = self.curInfo.matrix["main4"],main5 = self.curInfo.matrix["main5"],},"客户端设置的阵形: ","gggg.txt",2)
	return modifyMatrix

end

--检测战斗条件
--@return(0:允许战斗 1:布阵信息未初始化 2:主战位缺人)
function EmbattleMgr:CheckFightCondition()
	local nRet = 0
	if nil==self.curInfo or nil==self.oldMatrix then
		nRet = 1
		return nRet
	end

	nRet = 2
	local key
	for i=1, 5 do 	--主战位至少要上一个
		key = "main" .. i
		if -1~=self.curInfo.matrix[key] and 0~=self.curInfo.matrix[key] then
			nRet = 0
			break
		end
	end

	return nRet
end

--获取布阵消息返回
function EmbattleMgr:OnEmbattleInfoRet(cmd)
	if 1==cmd.result then
		if BattleType_PVE==self.nCurBattleType or BattleType_Legion==self.nCurBattleType then
			EmbattleMgr.isReqPVEFlag = false
		elseif BattleType_PVP==self.nCurBattleType then
			EmbattleMgr.isReqPVPFlag = false
		end
		
		--这里的代码执行顺序不能更改
		self.curInfo = cmd.data
		self.curInfo.friends = {}         --好友助阵的需求已经去掉了，这里置空
		self.oldMatrix = clone(self.curInfo.matrix)
		if BattleType_PVP_DEF==self.nCurBattleType then --设置防守阵型时候，
			for i=1,5 do
				self.curInfo.matrix["main"..i]=-1
			end
		end

		self:InitidKeyList()
		if EmbattleScene.Instance~=nil then
			EmbattleScene.Instance:OnEmbattleInfoRet(cmd)
		end
		if LaserCannon.Instance~=nil then
			LaserCannon.Instance:OnEmbattleInfoRet(cmd)
		end
	else
		showTips(cmd.msg)
		printInfo("EmbattleMgr:ReqEmbattleInfo failed!")
	end
end

function EmbattleMgr:getMenberInfoByMatrixId(_id)
    if _id>0 then  --由于历史遗留问题，存在人和车id相同的情况。区分，正为单人或人上车，负为单车
        for k,v in pairs(EmbattleMgr.curInfo.members) do
            if v.id==_id and (v.mtype==memberType.TYPE_MAN_ONLY or v.mtype==memberType.TYPE_MAN_AND_CAR) then
                return v
            end
        end
    else
        for k,v in pairs(EmbattleMgr.curInfo.members) do
            if v.id==-_id and v.mtype==memberType.TYPE_CAR_ONLY then
                return v
            end
        end
    end
    return nil
end

function EmbattleMgr:getMatrixIdFromMemberInfo(memberInfo)
	if memberInfo==nil or memberInfo.mtype==nil or memberInfo.id==nil then
		return nil
	end
	if memberInfo.mtype == memberType.TYPE_MAN_ONLY or memberInfo.mtype == memberType.TYPE_MAN_AND_CAR then
		return memberInfo.id
	else
		return -memberInfo.id
	end
end

--初始化idKeyList
function EmbattleMgr:InitidKeyList()
	if nil==self.curInfo then
		return false
	end

	self.idKeyList = {
						members = {},
						pullCars = {},
						seBlts = {},
						friends = {},
					}
	local tmpTab = nil
	for i=1, #self.curInfo.members do
		tmpTab = self.curInfo.members[i]
		self.idKeyList.members[tmpTab.id] = tmpTab
	end

	-- for i=1, #self.curInfo.pullCars do
	-- 	tmpTab = self.curInfo.pullCars[i]
	-- 	self.idKeyList.pullCars[tmpTab.id] = tmpTab
	-- end

	for i=1, #self.curInfo.seBlts do
		tmpTab = self.curInfo.seBlts[i]
		self.idKeyList.seBlts[tmpTab.id] = tmpTab
	end

	for i=1, #self.curInfo.friends do
		tmpTab = self.curInfo.friends[i]
		self.idKeyList.friends[tmpTab.fCharacterId] = tmpTab
	end

	return true
end

--请求战斗返回
function EmbattleMgr:OnReqFightRet(cmd)
	if 1==cmd.result then

		local seed = tonumber(tostring(os.time()):reverse():sub(1,6))
		math.randomseed(seed) 

		if BattleType_PVE==self.nCurBattleType or BattleType_Legion==self.nCurBattleType then
			BattleData = cmd.data
			BattleFormatInfo = EmbattleMgr.curInfo

			--writeTabToLog(BattleData,"服务端下发的战场数据: ","yyyy.txt")

			if EmbattleScene.Instance._rentInfo then
	            local car = EmbattleScene.Instance._rentInfo
	            
	            local i,v = getRentCost(car)
	            if srv_userInfo.isFirstRent==1 then
                    v = 0
                end
	            if i==1 then
	            	srv_userInfo.gold = srv_userInfo.gold - v
	            elseif i==2 then
	            	srv_userInfo.diamond = srv_userInfo.diamond - v
	            end
	            mainscenetopbar:setGlod()
	            mainscenetopbar:setDiamond()
	            local num = tonumber(string.sub(tostring(srv_userInfo.maxBlockId), 4,8))
	            -- print("\n\n\n\n\nsrv_userInfo.maxBlockId:",srv_userInfo.maxBlockId)
	            if num>=1005 then
		            car.record  = (car.record or 0)+1
		        end
	        end
            CurFightBattleType = FightBattleType.kType_PVE
		elseif BattleType_PVP==self.nCurBattleType then
			BattleData = cmd.data
			writeTabToLog(BattleData,"服务端下发的战场数据: ","yyyy.txt")
			BattleFormatInfo = EmbattleMgr.curInfo
			CurFightBattleType = FightBattleType.kType_PVP
			IsPlayback = false


			RandomSeed = seed --保存全局种子，pvp回放需要用
			BattleBeginTS = os.time()
						
		end

		if EmbattleScene.Instance~=nil then
			EmbattleScene.Instance:OnReqFightRet(cmd)
		end

	else
		showTips(cmd.msg)
		printInfo("EmbattleMgr:ReqFight failed!")
	end
end

--更换位置（可能出现交换）
function EmbattleMgr:ChangePos(nGroup, srcPos, dstPos)
	local bSuccess = false
	if nil==self.curInfo then
		return bSuccess
	end

	if nil==nGroup then 		--无效组
		return bSuccess
	end

	local tmpInfo
	local id, lv 		--id，上阵等级

	if EmbattleGroup_Main==nGroup then
		local srcKey = "main" .. srcPos
		local dstKey = "main" .. dstPos
		tmpInfo = self.curInfo["matrix"][srcKey]
		self.curInfo["matrix"][srcKey] = self.curInfo["matrix"][dstKey]
		self.curInfo["matrix"][dstKey] = tmpInfo
		bSuccess = true
		printTable(self.curInfo)

	else
		--todo
	end

	return bSuccess
end

--获取可上阵位置
function EmbattleMgr:GetCanOnPos(nGroup, nID)
	local retTab = {}
	local id, lv, key
	if EmbattleGroup_Main==nGroup then		
		for i=1, BattleNum_Main do
	 		key = "main" .. i
	 		id = self.curInfo["matrix"][key]
	 		if nID==id then 	--已经上阵
	 			return {}
	 		end

	 		if id==-1 or id==0 then
	 			table.insert(retTab, i)
	 		end
	 	end

	 -- 	if nil==self:getMenberInfoByMatrixId(nID) then 	--列表中找不到nID
	 -- 		return {}
		-- end

	elseif EmbattleGroup_Pull==nGroup then
		if srv_userInfo.level<5 then
			return retTab
		end

		local max = 2
		if srv_userInfo.level<30 then   --牵引位2未开放
			max = 1
		end

	 	for i=1, max do
	 		key = "pull" .. i
	 		id = self.curInfo["matrix"][key]
	 		if nID==id then 	--已经上阵
	 			return {}
	 		end
	 		print("key: "..key.."   id:"..id)
	 		if 0==id then
	 			table.insert(retTab, i)
	 		end
	 	end

	end

	return retTab
end

--自动上/下阵(返回值---nPos:要上阵位或下阵前位置  nType:上阵还是下阵)
function EmbattleMgr:AutoOnOffBattle(nGroup, nID)
	print("自动上下阵：",nID)
	local nType, nPos = 0, 0
	if nil==self.curInfo then
		return nType, nPos
	end
	local key = nil

	local nBattlePos = self:CheckOnBattle(nGroup, nID)
	print("nBattlePos",nBattlePos)
	if 0==nBattlePos then
		nType = EmbattleType_OnBattle
	else
		nType = EmbattleType_OffBattle
	end

	if EmbattleGroup_Main==nGroup then
		if EmbattleType_OnBattle==nType then
			local canOnPos = self:GetCanOnPos(nGroup, nID)
			if nil~=canOnPos[1] then
				key = "main" .. canOnPos[1]
				self.curInfo.matrix[key] = nID
				nPos = canOnPos[1]
			end
			if #canOnPos==0 then	--没有空位了可以上阵
				nPos=-1
			else
				print(nID.."上阵第"..canOnPos[1].."号位")
			end
		elseif EmbattleType_OffBattle==nType then
			key = "main" .. nBattlePos
			self.curInfo.matrix[key] = -1
			nPos = nBattlePos
			print(nID.."从第"..nBattlePos.."号位下阵")
		end

	elseif EmbattleGroup_Pull==nGroup then
		if EmbattleType_OnBattle==nType then
			local canOnPos = self:GetCanOnPos(nGroup, nID)
			print("306,canOnPos:  ")
			printTable(canOnPos)
			print("306,canOnPos:  ")

			key = "pull" .. EmbattleScene.Instance.isPullTouched
				self.curInfo.matrix[key] = nID
				nPos = EmbattleScene.Instance.isPullTouched
				print(key.." 上阵："..nID)

		elseif EmbattleType_OffBattle==nType then
			key = "pull" .. nBattlePos
			self.curInfo.matrix[key] = 0
			nPos = nBattlePos
		end

	end

	return nType, nPos
end

--好友援助
function EmbattleMgr:FriendsHelp(nID)
	if nil~=nID and nil~=self.idKeyList then
		if nil~=self.idKeyList.friends[nID] then
			self.curInfo.matrix.friendId = nID
			return true
		end
	end

	return false
end

--装载特种弹
function EmbattleMgr:LoadSeblts(nID, nPos,isUnLoad)
	local bSuccess = false
	if nil==nID or nil==nPos then
		return bSuccess
	end

	local nHasEquip = self:CheckSebltEquiped(nID)
	print("nHasEquip: ",nHasEquip)
	local key = "bullet" .. nPos
	if isUnLoad then
		key = "bullet" .. nHasEquip
	end
	print("key: ",key)
	if nil==self.curInfo.matrix[key] then
		return bSuccess
	end

	isUnLoad = isUnLoad or false

	--[[
	if -1==self.curInfo.matrix[key] then 			--弹仓未开启
		return bSuccess
	end
	]]
	print("isUnLoad:",isUnLoad)
	print("self.idKeyList.seBlts[nID]: ",self.idKeyList.seBlts[nID],nID)
	printTable(self.idKeyList.seBlts)
    if not isUnLoad then  --加载特种弹
		if nil~=self.idKeyList.seBlts[nID] then 		--在可选列表中找到
			if 0==nHasEquip then 						--未装备的才能装上
				self.curInfo.matrix[key] = nID
				bSuccess = true
			end
		end
	else--卸载特种弹
		if nil~=self.idKeyList.seBlts[nID] then 		--在可选列表中找到
			if 0~=nHasEquip then 						--
				self.curInfo.matrix[key] = 0
				bSuccess = nHasEquip
			end
		end
	end

	return bSuccess
end

--检查是否已上阵
function EmbattleMgr:CheckOnBattle(nGroup, nID)
	local nPos = 0
	if nil==nGroup or nil==nID or nID==0 or nID==-1 or nil==self.curInfo then
		return nPos
	end
	-- print("检测上阵：",nID)
	local key = nil
	if EmbattleGroup_Main==nGroup then
		for i=1, BattleNum_Main do
			key = "main" .. i
			-- print(key.." -> "..self.curInfo.matrix[key])
			if nID==self.curInfo.matrix[key] then
				nPos = i
				-- print("检测已上阵："..nID,"阵位："..nPos)
				break
			end
		end
	elseif EmbattleGroup_Pull==nGroup then
		for i=1, BattleNum_Pull do
			key = "pull" .. i
			if nID==self.curInfo.matrix[key] then
				nPos = i
				break
			end
		end
	end
	
	return nPos
end

--获取总战力
function EmbattleMgr:GetStrength()
	local key, nID
	local fStrength = 0
	for i=1, BattleNum_Main do
		key = "main" .. i
		nID = self.curInfo.matrix[key]
		if nil~=self:getMenberInfoByMatrixId(nID) then
			fStrength = fStrength + self:getMenberInfoByMatrixId(nID).strength
		end
	end

	return fStrength
end

--检测特种弹是否装备
function EmbattleMgr:CheckSebltEquiped(nID)
	local nPos = 0
	if nil==self.curInfo then
		return nPos
	end

	local key, nBltID =  nil
	for i=1, BULLETSLOTNUM do
		key = "bullet" .. i
		nBltID = self.curInfo.matrix[key]
		if nBltID==nID then
			nPos = i
			break
		end
	end

	return nPos
end

--设置援助好友
function EmbattleMgr:SetFriendsHelp(nID)
	if nil==nID or nil==self.curInfo then
		return false
	end

	self.curInfo.matrix.friendId = nID
	return true
end

function EmbattleMgr:ReqUnlockSlot(nPos)
	print("请求开启弹仓"..nPos)
	local tabMsg, cmdKey = {bulletNo="bullet"..nPos}, CMD_EMBATTLE_UNLOCKSLOT
	m_socket:SendRequest(json.encode(tabMsg), cmdKey, EmbattleMgr, EmbattleMgr.OnUnlockSlotRet)
end

function EmbattleMgr:OnUnlockSlotRet(cmd)
	if 1==cmd.result then
		local key = cmd.data.bulletNo
		print("-------------------解锁特种弹槽位，"..key)
		self.curInfo.matrix[key] = 0
		if nil~=EmbattleScene.Instance then
			srv_userInfo.diamond = srv_userInfo.diamond - cmd.data.cosDia
	        EmbattleScene.Instance:OnUnlockRet(cmd)
	    end
	else
		showTips(cmd.msg)
		print("error")
		return 
	end
	
end

function EmbattleMgr:isMatrixIsFull()
	local isFull = true
    for i=1,5 do
        local key = "main"..i
        local value = EmbattleMgr.curInfo.matrix[key]
        if value==-1 or value==0 then
            isFull = false
            break
        end
    end
    return isFull
end
