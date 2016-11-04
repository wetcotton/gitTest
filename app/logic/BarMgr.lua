--
-- Author: Jun Jiang
-- Date: 2014-12-22 14:40:32
--
BarMgr = class("BarMgr")

--管理类初始化
function BarMgr:Init()
	self.BarInfo = nil 		--酒吧信息
	self.bountyList = {} 	--赏金列表
	for k=10001, table.nums(areaData)+10000 do
		local tab = {}
		table.insert(tab, areaData[k].bossId)
		self.bountyList[#self.bountyList+1] = tab
	end
end

--请求初始信息
function BarMgr:ReqInitInfo()
	local tabMsg = {characterId=srv_userInfo.characterId}
	m_socket:SendRequest(json.encode(tabMsg), CMD_BAR_BARINFO, self, self.OnInitInfoRet)
end

--初始信息返回
function BarMgr:OnInitInfoRet(cmd)
	if 1==cmd.result then
		self.BarInfo = cmd.data

		--酒吧信息重组
		local key
		self.BarInfo.btyRed = {}	--0:不可领取 1:可领取 2:已领取
		for i=1, #self.BarInfo.freeBty do 	--可领取列表
			key = cmd.data.freeBty[i]
			self.BarInfo.btyRed[key] = 1
		end

		for i=1, #self.BarInfo.gotBty do 	--已领取列表
			key = cmd.data.gotBty[i]
			self.BarInfo.btyRed[key] = 2
		end

		if bounty.Instance~=nil then
			bounty.Instance:OnInitInfoRet(cmd)
		end
		
		if MainScene_Instance~=nil then
			MainScene_Instance:OnInitInfoRet(cmd)
		end
	else
		showTips(cmd.msg)
	end
end

--申请提交任务
function BarMgr:ReqSubmitTask(nID)
	
	local tabMsg = {characterId=srv_userInfo.characterId, areaId=nID, guideStep2 = g_step}
	local g_step = GuideManager:getCondition()
	if g_step==205 then 
		GuideManager:resetCondition(tabMsg)
	end
	m_socket:SendRequest(json.encode(tabMsg), CMD_BAR_GETBOUNTY, self, self.OnSubmitTaskRet)
end

--提交任务返回
function BarMgr:OnSubmitTaskRet(cmd)
	if 1==cmd.result then
		self.BarInfo.btyRed[srv_userInfo.areaId] = 2 	--0:不可领取 1:可领取 2:已领取
		srv_userInfo["gold"] = srv_userInfo["gold"]+cmd.data.gold
		srv_userInfo["diamond"] = srv_userInfo["diamond"]+cmd.data.diamond
		mainscenetopbar:setGlod()
		mainscenetopbar:setDiamond()

		if bounty.Instance~=nil then
			bounty.Instance:OnSubmitTaskRet(cmd)
		end
	else
		showTips(cmd.msg)
	end
end

--请求记录剧情
function BarMgr:ReqRecordStory(nID)
	-- local tabMsg = {characterId=srv_userInfo.characterId, areaId=nID}
	-- m_socket:SendRequest(json.encode(tabMsg), CMD_BAR_RECORDSTORY, BarScene.Instance, BarScene.Instance.OnRecordStoryRet)
end

--存储剧情返回
function BarMgr:OnRecordStoryRet(cmd)
	if 1==cmd.result then
		if self.BarInfo.styArId<srv_userInfo.areaId then
			self.BarInfo.styArId = srv_userInfo.areaId
		end
	else
		showTips(cmd.msg)
	end
end

BarMgr:Init()