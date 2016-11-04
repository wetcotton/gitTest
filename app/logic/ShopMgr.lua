--
-- Author: Jun Jiang
-- Date: 2014-11-27 16:15:14
--
require("app.utils.GlobalFunc")

--商店类型
SHOPTYPE_ALL 	= 1 	--普通商店（固定+限时模块）
SHOPTYPE_LIMIT 	= 2 	--普通商店（限时模块）
SHOPTYPE_PVP 	= 3 	--竞技场商店
SHOPTYPE_ARMY 	= 4 	--军团商店

ShopMgr = class("ShopMgr")
ShopMgr.srv_Data = {} 			--服务器数据
ShopMgr.timeDif = 0 			--服务器与客户端时间差（s）
ShopMgr.fixSortList 	= {} 	--固定模块排序列表
ShopMgr.limitSortList	= {} 	--限时模块排序列表
ShopMgr.buyRecords		= {} 	--购买记录

--请求最新商店信息(nType:商店类型)
--注：对于 SHOPTYPE_LIMIT 请求即刷新普通商店限时模块,其它只是请求最新信息
function ShopMgr:ReqShopInfo(nType)
	local tabMsg = {characterId=srv_userInfo.characterId, type=nType}
	local cmdKey
	if SHOPTYPE_ALL==nType or SHOPTYPE_LIMIT==nType then
		cmdKey = CMD_SHOP_GETINFO
	elseif SHOPTYPE_PVP==nType then
		cmdKey = CMD_SHOP_GETPVPINFO
	elseif SHOPTYPE_ARMY==nType then
		cmdKey = CMD_SHOP_GETARMYINFO
	end

	if nil==cmdKey then
		return false
	end
	m_socket:SendRequest(json.encode(tabMsg), cmdKey, ShopScene.Instance, ShopScene.Instance.OnShopInfoRet)
	return true
end

--商店信息返回
function ShopMgr:OnShopInfoRet(cmd)
	if 1==cmd.result then
		self.srv_Data = cmd.data
		if nil~=cmd.data.curTS then
			local locTime = os.time()
			self.timeDif = math.floor(cmd.data.curTS/1000)-locTime
		else
			self.timeDif = 0
		end

		--初始化限时模块排序列表
		self:InitLimitSortList()

		--按ID存储
		self.buyRecords = {}
		--[[
			cmd = {
				    "msg": "刷新成功", 
				    "data": {
				        "limitRecs": [ ], 
				        "curTS": 1417081828, 
				        "fixRecs": [
				            {
				                "count": 1, 
				                "goodId": 11012001
				            }
				        ]
				    }, 
				    "result": 1
				}
		]]
	else
		showTips(cmd.msg)
		printInfo("ShopMgr:OnShopInfoRet failed! result=" .. cmd.result)
	end
end

--请求购买商品
function ShopMgr:ReqBuy(nType, nGoodsID, nCount)
	--预判
	if nil==nType or nil==nGoodsID or nil==nCount then
		return
	end

	--发送请求
	local tabMsg = {characterId=srv_userInfo.characterId, type=nType, goodId=nGoodsID, count=nCount}
	m_socket:SendRequest(json.encode(tabMsg), CMD_SHOP_BUYGOODS,  ShopScene.Instance,  ShopScene.Instance.OnBuyRet)
end

--购买商品结果返回(nType:刷新类型)
function ShopMgr:OnBuyRet(nType, nBuy, cmd)
	if nil==nType or nil==nBuy or nil==cmd then
		return
	end

	if 1==cmd.result then
		local data = cmd.data
		local nGoodsID = data.templateId
		if nil==goodsData[nGoodsID] then
			return
		end

		local tabRecs = nil
		if nType==SHOPTYPE_ALL then
			tabRecs = self.srv_Data.fixRecs
			srv_userInfo.gold = srv_userInfo.gold-nBuy*goodsData[nGoodsID].gold
			mainscenetopbar:setGlod()

		elseif nType==SHOPTYPE_LIMIT then
			tabRecs = self.srv_Data.limitRecs
			if 0~=goodsData[nGoodsID].gold then
				srv_userInfo.gold = srv_userInfo.gold-nBuy*goodsData[nGoodsID].gold
				mainscenetopbar:setGlod()
			else
				srv_userInfo.diamond = srv_userInfo.diamond-nBuy*goodsData[nGoodsID].diamond
				mainscenetopbar:setDiamond()
			end

		elseif nType==SHOPTYPE_PVP then
			tabRecs = self.srv_Data
			--声望值减少

		elseif nType==SHOPTYPE_ARMY then
			tabRecs = self.srv_Data
			--功勋值减少

		end

		if nil==tabRecs[nGoodsID] then
			tabRecs[nGoodsID] = nBuy
		else
			tabRecs[nGoodsID] = tabRecs[nGoodsID]+nBuy
		end

		--添加至背包
	else
		showTips(cmd.msg)
		printInfo("购买商品失败")
	end
end

--初始化固定模块排序列表
function ShopMgr:InitFixSortList()
	-- body
	local goodsData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataGoods)

	self.fixSortList = {carWeapon={}, carArmor={}, seBlt={}, pvp={}, army={}}
	for k, v in pairs(goodsData) do
		--@tabID[1]：道具类型
		--@tabID[2]：道具星级
		--@tabID[3]：顺序号
		local tabID = SplitNum(k, {3, 1, 3})

		--普通商店固定模块商品
		if 1==v.fix then
			if ITEMTYPE_MAINGUN==tabID[1] or ITEMTYPE_SUBGUN==tabID[1] or ITEMTYPE_SEGUN==tabID[1] then
				table.insert(self.fixSortList.carWeapon, k)
			elseif ITEMTYPE_ENGINE==tabID[1] or ITEMTYPE_CDEV==tabID[1] or ITEMTYPE_TOOL==tabID[1] then
				table.insert(self.fixSortList.carArmor, k)
			elseif ITEMTYPE_SEBLT==tabID[1] then
				table.insert(self.fixSortList.seBlt, k)
			end
		end

		--竞技场商店商品
		if 1==v.arena then
			table.insert(self.fixSortList.pvp, k)
		end

		--军团商店商品
		if 1==v.corps then
			table.insert(self.fixSortList.army, k)
		end
	end

	local function Sort(id1, id2)
		local tabID_1 = SplitNum(id1, {3, 1, 3})
		local tabID_2 = SplitNum(id2, {3, 1, 3})

		if tabID_1[2]==tabID_2[2] then
			if tabID_1[1]==tabID_2[1] then
				return tabID_1[3]<tabID_2[3]
			else
				return tabID_1[1]<tabID_2[1]
			end
		else
			return tabID_1[2]>tabID_2[2]
		end
	end
	table.sort(self.fixSortList.carWeapon, Sort)
	table.sort(self.fixSortList.carArmor, Sort)
	table.sort(self.fixSortList.seBlt, Sort)
	table.sort(self.fixSortList.pvp, Sort)
	table.sort(self.fixSortList.army, Sort)
end

--初始化限时模块排序列表
function ShopMgr:InitLimitSortList()
	if nil==self.srv_Data or nil==self.srv_Data.limitGoods then
		self.limitSortList = {}
		return
	end
	self.limitSortList = {}

	for i=1, #self.srv_Data.limitGoods do
		table.insert(self.limitSortList, self.srv_Data.limitGoods[i])
	end

	local function Sort(id1, id2)
		local tabID_1 = SplitNum(id1, {3, 1, 3})
		local tabID_2 = SplitNum(id2, {3, 1, 3})

		if tabID_1[2]==tabID_2[2] then
			if tabID_1[1]==tabID_2[1] then
				return tabID_1[3]<tabID_2[3]
			else
				return tabID_1[1]<tabID_2[1]
			end
		else
			return tabID_1[2]>tabID_2[2]
		end
	end
	table.sort(self.limitSortList, Sort)
end

--获取服务器时间
function ShopMgr:GetSrvTime()
	return os.time()+self.timeDif
end

ShopMgr:InitFixSortList()