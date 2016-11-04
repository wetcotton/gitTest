--
-- Author: Jun Jiang
-- Date: 2015-06-03 15:12:04
--
local WarriorsCenterMgr = class("WarriorsCenterMgr")
WarriorsCenterMgr.relicsData = nil 		--遗迹数据
WarriorsCenterMgr.step = -1  --表示远征进行到哪一步了，0表示还没进行过远征，1表示已经布阵一次了，2表示布阵两次了
--请求初始化遗迹
function WarriorsCenterMgr:ReqInitRelics()
	local tabMsg = {}
	m_socket:SendRequest(json.encode(tabMsg), CMD_RELICS_INIT, g_WarriorsCenterMgr, g_WarriorsCenterMgr.OnInitRelicsRet)
end

--初始化遗迹返回
function WarriorsCenterMgr:OnInitRelicsRet(cmd)
	if 1==cmd.result then
		self.relicsData = cmd.data
		print("------------------------------------------sss")
		printTable(self.relicsData)
		print("------------------------------------------sss")
	else
		showTips(cmd.msg)
	end
	if nil~=g_RelicsLayer.Instance then 
        g_RelicsLayer.Instance:OnInitRelicsRet(cmd)
    end
end

--请求随机探测
function WarriorsCenterMgr:ReqDetect(nHardLev)
	local tabMsg = {hardLevel=nHardLev}
	m_socket:SendRequest(json.encode(tabMsg), CMD_RELICS_DETECT, g_WarriorsCenterMgr, g_WarriorsCenterMgr.OnDetectRet)
end

--随机探测返回
function WarriorsCenterMgr:OnDetectRet(cmd)
	if 1==cmd.result then
		self.relicsData.blockId = cmd.data.blockId
		self.relicsData["7"] = self.relicsData["7"]-1
	else
		showTips(cmd.msg)
	end
	if nil~=g_RelicsLayer.Instance then
        g_RelicsLayer.Instance:OnDetectRet(cmd)
    end
end

--请求远征开始，如果没有远征过，返回预设阵型1，如果已经远征过，则返回远征战斗所需信息
function WarriorsCenterMgr:ReqExpeditionSatrt()
	local tabMsg = {}
	m_socket:SendRequest(json.encode(tabMsg), CMD_START_EXPEDITION, self, self.OnExpeditionStartRet)
end

function WarriorsCenterMgr:OnExpeditionStartRet(cmd)
	if 1==cmd.result then   --今日还没远征过，现在去第一次布阵
		self.step = 0

	elseif 2==cmd.result then     --今日已经远征过，直接进入战斗
		self.step = 2
		--这里要记录阵型信息，记录战场数据，然后在进入战斗场景即可
	else
		showTips(cmd.msg)
	end
	
	if expeditionLayer.Instance~=nil then
		expeditionLayer.Instance:OnExpeditionStartRet(cmd)
	end
end
--远征，上传布阵详情（只上传改变了的）
function WarriorsCenterMgr:ReqUpdateExpeditionFormation(modifyMatrix)
	local tabMsg = modifyMatrix
	if self.step==0 then
		tabMsg.type = 1     --此次上传的是人战阵型
	elseif self.step==1 then
		tabMsg.type = 2     --此次上传的是车站阵型
	end

	m_socket:SendRequest(json.encode(tabMsg), CMD_UPDATE_FORMATION, self, self.UpdateFormationRet)
end
--远征，获取第二次布阵初始阵型
function WarriorsCenterMgr:UpdateFormationRet(cmd)
	if 1==cmd.result then   --第一次布阵完毕，现在去第二次布阵
		self.step = 1

	elseif 2==cmd.result then  --第二次布阵完毕，现在去进入战斗
		self.step = 2
		--这里要记录阵型信息，记录战场数据，然后在进入战斗场景即可
		BattleData = cmd.data
	else
		showTips(cmd.msg)
	end
	if expeditionLayer.Instance~=nil then
		expeditionLayer.Instance:UpdateFormationRet(cmd)
	end
end

return WarriorsCenterMgr