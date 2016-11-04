--
-- Author: Huang yu zhao
-- Date: 2015-07-27 14:37
--


RentMgr = class("RentMgr")
RentMgr.rentInfo = {} 		--邮件信息
RentMgr.sortList = {} 		--排序列表

function RentMgr:ReqRentCarList(_handler)
	self.initCallback = _handler
	local tabMsg = {}
	m_socket:SendRequest(json.encode(tabMsg), CMD_LEGION_TAXIPUSH, RentMgr, RentMgr.InitRentByCmd)
end

--初始化可租用车辆
function RentMgr:InitRentByCmd(cmd)
	if 1==cmd.result then
		self.rentInfo = {}
		self.sortList = {}

		local key, val
		for i=1, #cmd.data.rentCars do
			val = cmd.data.rentCars[i]
			key = val.id
			self.rentInfo[key] = val
			table.insert(self.sortList, key)
		end

		for key,value in pairs(rentData) do
			self.rentInfo[key] = value
			table.insert(self.sortList, key)
		end

		self:Resort()
		if self.initCallback then
			self.initCallback()
		end
	else
		if GuideManager.NextStep==11207 then
			if self.initCallback then
				self.initCallback()
			end
		else
			showTips(cmd.msg)
		end
		
	end
end

function RentMgr:InitWithLocalData()
	self.rentInfo = {}
	self.sortList = {}

	for key,value in pairs(rentData) do
		self.rentInfo[key] = value
		table.insert(self.sortList, key)
	end

	-- print("=================================xxxxxxxxxxxxxxxx")
	-- 	printTable(self.rentInfo)
	-- 	print("=================================xxxxxxxxxxxxxxxx")
	-- 	printTable(self.sortList)
	-- 	print("=================================xxxxxxxxxxxxxxxx")

	self:Resort()
end

--排序可租用列表
function RentMgr:Resort()
	--print("开始排序出租车--------------------------------")
	if nil==self.sortList then
		return
	end
	--print("真的开始排序出租车=============================")
	local function SortFunc(val1, val2)
		local data1 = self.rentInfo[val1]
		local data2 = self.rentInfo[val2]

		--小于用户等级的在前
		if data1.level<=srv_userInfo.level and data2.level>srv_userInfo.level then
			return true
		end

		if data1.level>srv_userInfo.level and data2.level<=srv_userInfo.level then
			return false
		end
		--系统配车的在前
		if data1.driver==nil and data2.driver~=nil then
			return true
		end

		if data1.driver~=nil and data2.driver==nil then
			return false
		end
		--战斗力高的在前
		if data1.strength==data2.strength then
			return val1<val2
		else
			return data1.strength>data2.strength
		end
	end

	table.sort(self.sortList, SortFunc)

	-- print("=================================yyyyyyyyyyyyyy1")
	-- 	printTable(self.rentInfo)
	-- 	print("=================================yyyyyyyyyyyy2")
	-- 	printTable(self.sortList)
	-- 	print("=================================yyyyyyyyyyyyyyyy3")
end

function RentMgr:OnRentRecordPush(cmd)--战车租用记录
	if 1==cmd.result then
		self.rentInfo[11].record = 0
		self.rentInfo[12].record = 0
		self.rentInfo[13].record = 0
		for k,v in pairs(cmd.data.recs) do
			if self.rentInfo[k+0]~=nil then
				self.rentInfo[k+0].record = v   --记录每辆战车已经租用了几次
			else 
				print("error")
			end
		end
	else
		showTips(cmd.msg)
	end

	-- print("=================================666666666666666")
	-- 	printTable(self.rentInfo)
	-- 	print("=================================66666666666666")
	-- 	printTable(self.sortList)
	-- 	print("=================================6666666666666666")
end


function RentMgr:OnRentOnOffPush(cmd)--军团有人登记租车，或取消登记，实时推送
	if 1==cmd.result then
		print("推送，军团租车变化")
		local key, val
		local bIsMe = false
		for i = 1,#cmd.data.add do
			val = cmd.data.add[i]
			key = val.id

			if val.driver==srv_userInfo.characterId then
				bIsMe = true
				break
			end

			self.rentInfo[key] = val
			table.insert(self.sortList, key)
		end

		for i = 1,#cmd.data.del do
			val = cmd.data.del[i]
			key = val.id
			if val.driver==srv_userInfo.characterId then
				bIsMe = true
				break
			end
			self.rentInfo[key] = nil
			for kk = 1,#self.sortList do
				if self.sortList[kk]==key then
					table.remove(self.sortList, kk)
					break
				end
			end
		end

		self:Resort()
		if rentCarListLayer.Instance~=nil and not bIsMe then
			print("刷新UI")
			rentCarListLayer.Instance:getAllTaxiRet()
			rentCarListLayer.Instance:ReloadCarList(true)
		end
	else
		showTips(cmd.msg)
	end
end

