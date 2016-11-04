-- 
-- Author: Jun Jiang
-- Date: 2015-07-10 11:34:29
--

---------------VIP特权---------------------
VIP_PRIVATE_WIPE 			= 1 		--扫荡
VIP_PRIVATE_ELITEBUY 		= 2 		--精英关卡次数购买
VIP_PRIVATE_PVP 			= 3 		--竞技场次数购买
VIP_PRIVATE_WIPE10 			= 4 		--扫荡10次
VIP_PRIVATE_RELICSDETECT 	= 5 		--遗迹随机探测
VIP_PRIVATE_SPESLOTBUY1 	= 6 		--特种弹槽位购买1
VIP_PRIVATE_SKILLPOINTS20 	= 7 		--20点技能上限
VIP_PRIVATE_WORLDBOSS 		= 8 		--世界boss设定
VIP_PRIVATE_SPESLOTBUY2 	= 9 		--特种弹槽位购买2
VIP_PRIVATE_ARMYBUILD 		= 10 		--军团创建
VIP_PRIVATE_EXPEDITION1 	= 11 		--远征设定1
VIP_PRIVATE_EXPEDITION2 	= 12 		--远征设定2
-------------------------------------------

local VIPMgr = class("VIPMgr")

--获取特权所需VIP等级
function VIPMgr:GetNeedVip(nTag)
	local nNeedVip = 0

	for i=0, #vipLevelData do
		nNeedVip = i
		if nil~=vipLevelData[i] then
			local strUnLock = vipLevelData[i].unLock
			if "null"~=strUnLock then
				local arr = string.split(strUnLock, "#")
				local nUnLock
				for j=1, #arr do
					nUnLock = tonumber(arr[j])
					if nUnLock==nTag then
						return nNeedVip
					end
				end
			end
		end
	end

	return nNeedVip+1 --没有找到，取VIP等级上限+1
end

return VIPMgr