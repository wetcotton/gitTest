--
-- Author: Huang Yuzhao
-- Date: 2015-08-05 10:17
--

AchMgr = class("AchMgr")

ACHTYPE = {}           --成就类型
ACHTYPE.RENK            =1     --等级
ACHTYPE.EQUIP           =2     --装备
ACHTYPE.KILL            =3     --击杀
ACHTYPE.BLOCK           =4	   --关卡
ACHTYPE.STORY           =5     --剧情

ACH_FINISH_TYPE = {}
ACH_FINISH_TYPE.UNFINISH = 0   --未完成
ACH_FINISH_TYPE.FINISHED = 1   --可领奖
ACH_FINISH_TYPE.HASGOT   = 2   --已领奖

AchMgr.statusList = {}

--初始化数据
function AchMgr:initData()
	self.treeInfo = {{},{},{},{},{}}  --表示树的根节点，共有五个
	
	self.sortList = {{},{},{},{},{}}  --表示排序数组，共有五个
	for i,v in pairs(achievementData) do
		if v.type==ACHTYPE.RENK then
			self.sortList[1][#self.sortList[1] + 1] = v.id
		elseif v.type==ACHTYPE.EQUIP then
			self.sortList[2][#self.sortList[2] + 1] = v.id
		elseif v.type==ACHTYPE.KILL then
			self.sortList[3][#self.sortList[3] + 1] = v.id
		elseif v.type==ACHTYPE.BLOCK then
			self.sortList[4][#self.sortList[4] + 1] = v.id
		elseif v.type==ACHTYPE.STORY then
			self.sortList[5][#self.sortList[5] + 1] = v.id
		end
	end

	local function sortFun(val1,val2)
		local loc_1 = achievementData[val1]
		local loc_2 = achievementData[val2]
		if loc_1.type==loc_2.type then
			return loc_1.sequence<loc_2.sequence
		else
			return loc_1.type<loc_2.type
		end
	end

	for i = 1,5 do
		table.sort( self.sortList[i], sortFun )
	end


	self.g_head = nil

end

function AchMgr:OnStatusPush(cmd)
	if 1==cmd.result then
		self.statusList = {}
		self.idKeyInfo = {}
		for k,v in pairs(cmd.data.tList) do
			--printTable(v)
			local locData = taskData[v.tptId]
			if locData~=nil then
				if locData.type==6 then
					self.statusList[v.tptId] = v
					self.idKeyInfo[v.id] = v
				end
			else
				print("成就发生错误！两端数据不一致")
			end
		end
		-- print("----------------------------00000000000000000000")
		-- printTable(self.statusList)
		-- print("-----------------------------00000000000000000000")
	else
		showTips(cmd.msg)
	end


end