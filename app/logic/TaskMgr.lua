--
-- Author: Jun Jiang
-- Date: 2015-01-27 14:42:21
--
--任务类型
--截止至2015/8/10,只有普通、日常、签到，以及成就树任务，其中普通也归于日常任务
TASKTYPE_NORMAL 				= 1 	--普通任务
TASKTYPE_DAILY					= 2 	--日常任务
TASKTYPE_FREEDIAMOND			= 3 	--开服免费送钻石
TASKTYPE_VIP					= 4 	--VIP任务
TASKTYPE_SIGNIN					= 5 	--签到任务
TASKTYPE_ACHIEVEMENT			= 6 	--成就树任务
TASKTYPE_GUIDE                  = 7     --新手引导任务
TASKTYPE_RECHARGE				= 8     --充值任务
TASKTYPE_7DAYGIFT               = 9     --7日大礼包
TASKTYPE_TOTALCONSUME			= 10 	--累计消耗
TASTYPE_ONLINE					= 11	--在线奖励
TASTYPE_FOUNDACTIVITY			= 12	--基金活动
TASTYPE_LEVELGIF				= 13	--冲级礼包
TASTYPE_NEWFUND					= 14	--新手基金

--任务目标
TASKGOLE_ARMY					= 1 	--（跳转关卡选择界面）
TASKGOLE_DAILYLOGIN				= 2 	--每日登陆
TASKGOLE_TEAMLEV				= 3 	--战队等级
TASKGOLE_EQUIPMENTLEV			= 4 	--装备等级
TASKGOLE_CAREQUIPMENTSTRENGTHEN	= 5 	--战车装备强化（跳转战车属性界面）
TASKGOLE_ROLEEQUIPMENTADVANCE	= 6 	--人物装备进阶（跳转人物属性界面）
TASKGOLE_RECHARGE				= 7 	--充值（跳转充值界面）
TASKGOLE_TOTALRECHARGE 			= 8 	--累计充值（跳转充值界面）
TASKGOLE_GETSPECIFIEDCAR 		= 9 	--获取指定战车
TASKGOLE_GETSPECIFIEDEQUIPMENT	= 10 	--获取指定装备
TASKGOLE_SHOPTOBUY				= 11 	--商店购买（跳转商店界面）
TASKGOLE_CARTRANSFORM			= 12 	--战车改造（跳转战车改造界面）
TASKGOLE_DAILYINSTANCE 			= 13 	--每日副本（终结者）
TASKGOLE_NOVICETASK				= 14 	--新手任务
TASKGOLE_THREESTARCHAPTER		= 15 	--三星章节（跳转大区界面）
TASKGOLE_DOWNLOAD				= 16 	--下载（点击链接）
TASKGOLE_INVITE					= 17 	--邀请
TASKGOLE_VIP					= 18 	--VIP任务
TASKGOLE_SIGNIN					= 19 	--签到

TASKGOLE_LEGION      			= 23    --军团副本(跳转)
TASKGOLE_RELICS					= 24    --遗迹副本(跳转)
TASKGOLE_WORLDBOSS				= 25    --世界boss副本(跳转)
TASKGOLE_KILL					= 26    --怪物击杀类
TASKGOLE_BOUNTY					= 27    --剩余血量击败赏金首
TASKGOLE_EQUIPLEVELUP			= 28    --人物装备进阶任务(跳转)
TASKGOLE_ELITEBLOCK				= 29    --精英副本（精英终结者）
TASKGOLE_RENTCAR				= 30    --战车出租(跳转)
TASKGOLE_PVP					= 31    --竞技场战斗(跳转)
TASKGOLE_SKILLUP				= 32    --技能提升(跳转)
TASKGOLE_GOLDHAND				= 33    --点金手(跳转)
TASKGOLE_LOTTERY				= 34    --抽卡(跳转)
TASKGOLE_YUANZHENG				= 38    --胜利远征(跳转)
TASKGOLE_LEGION_CTRI			= 39    --军团建设一次(跳转)
TASKGOLE_7DAYGIFT				= 40    --七日礼包
TASKGOLE_FREEDIAMOND			= 41    --开服首周钻石
TASKGOLE_ONLINEREWARD			= 42    --在线时常
TASKGOLE_FUNDACTIVITY_1			= 43	--基金活动第一类
TASKGOLE_FUNDACTIVITY_2			= 44	--基金活动第二类
TASKGOLE_FUNDACTIVITY_3			= 45	--基金活动第三类
TASKGOLE_LEVELACTIVITY			= 46	--冲级活动
TASKGOLE_ABOARD					= 47	--乘降
TASKGOLE_GUIDE_GIFT				= 48	--新手礼包
TASKGOLE_NEWFUND				= 49	--新手基金

--任务标签（界面用）
TaskTag ={
	Daily 		= 1,
	Achievement = 2,
	VIP 		= 3,
	SignIn 		= 4, 	--从任务界面分离
	TotalConsume = 5,
	FreeDiamond = 6,
	Recharge    =7,
	_7DayGift   =8,
	Online 		= 9,    --在线
	levelGift   = 10,
	levelGift_2   = 11,
	oldfund		= 12,
	newfund 	= 13,
	Num 		= 13, 	--总数
}

TaskMgr = class("TaskMgr")
TaskMgr.idKeyInfo 			= nil 	--以ID为key值的初始任务信息
TaskMgr.nCurSubmitTaskID 	= 0 	--当前提交任务ID
TaskMgr.sortList 			= nil 	--ID排序列表
TaskMgr.canSubNum 			= {} 	--可提交任务数量(不算签到)
TaskMgr.hasSevenDay			= false --七天礼是否存在

--补签花费钻石
SignCost = {
	10,
	20,
	20,
	40,
	80,
}

energyTask = {}
energyTask[102020010]=0   --12:00-14:00领燃油
energyTask[102020011]=0   --18:00-20:00领燃油
energyTask[102020012]=0   --21:00-22:00领燃油


--任务初始信息下发
function TaskMgr:OnInitInfoRet(cmd)
	self.canSubNum = {}
	for i=1, TaskTag.Num do
		self.canSubNum[i] = 0
	end
	if 1==cmd.result then
		local taskList = cmd.data.tList
		self.idKeyInfo = {}
		for i=1, #taskList do
			print(i)
			print(taskList[i].tptId)
			if taskData[taskList[i].tptId] ~=nil then
				--在线奖励关闭
				-- if taskData[taskList[i].tptId].type==11 then
				-- 	g_isOnlineSeqSend = true

				-- 	g_ActOnLineListTs = (taskData[taskList[i].tptId].cnt - taskList[i].curcnt)*60*1000
				-- end
				self.idKeyInfo[taskList[i].id] = taskList[i]
				self:IfAddCanSubNum(taskList[i])

				local _locData = taskData[taskList[i].tptId]
				if _locData then
					if _locData.id==102020010 or _locData.id==102020011 or _locData.id==102020012 then
						energyTask[_locData.id] = taskList[i].status
						print(_locData.id.."  lingtilizhuangtai----------"..taskList[i].status)
					end
				end
			end
		end
		if energyTask[102020010]==0 then
			energyTask[102020010] = nil
		end
		if energyTask[102020011]==0 then
			energyTask[102020011] = nil
		end
		if energyTask[102020012]==0 then
			energyTask[102020012] = nil
		end		
		self:_InitSortList()
	else
		showTips(cmd.msg)
	end
end

--判断是否增加可提交任务数
--@tabData：任务数据
function TaskMgr:IfAddCanSubNum(tabData)
	-- print(":IfAddCanSubNum(tabData) star")
	if nil==tabData then
		return
	end

	local loc_Task = taskData[self.idKeyInfo[tabData.id].tptId]
	-- printTable(self.idKeyInfo[tabData.id])
	-- printTable(loc_Task)
	if nil==loc_Task then
		return
	end
	local nType = loc_Task.type
	if TASKTYPE_7DAYGIFT==nType then --七天礼
		TaskMgr.hasSevenDay = true
	end
	if 1==tabData.status then 	--可提交
		print("-----------------------------------------------xcc")
		print("----nType: "..nType)
		if TASKTYPE_DAILY==nType or TASKTYPE_NORMAL==nType then
			print("TASKTYPE_DAILY")
			print(tabData.id)
			self.canSubNum[TaskTag.Daily] = self.canSubNum[TaskTag.Daily]+1
			
		elseif TASKTYPE_ACHIEVEMENT==nType then
			self.canSubNum[TaskTag.Achievement] = self.canSubNum[TaskTag.Achievement]+1

		elseif TASKTYPE_VIP==nType then
			self.canSubNum[TaskTag.VIP] = self.canSubNum[TaskTag.VIP]+1

		elseif TASKTYPE_SIGNIN==nType then
			--do nothing
		elseif TASKTYPE_TOTALCONSUME==nType then
			self.canSubNum[TaskTag.TotalConsume] = self.canSubNum[TaskTag.TotalConsume]+1
		elseif TASKTYPE_7DAYGIFT==nType then
			self.canSubNum[TaskTag._7DayGift] = self.canSubNum[TaskTag._7DayGift]+1
		elseif TASKTYPE_FREEDIAMOND==nType then
			self.canSubNum[TaskTag.FreeDiamond] = self.canSubNum[TaskTag.FreeDiamond]+1
		elseif TASKTYPE_RECHARGE==nType then
			self.canSubNum[TaskTag.Recharge] = self.canSubNum[TaskTag.Recharge]+1
		elseif TASTYPE_ONLINE==nType then
			self.canSubNum[TaskTag.Online] = self.canSubNum[TaskTag.Online]+1
		elseif TASTYPE_LEVELGIF==nType then
			local num = tonumber(string.sub(tostring(loc_Task.id), 6,9))
			--因为表上通过type和tgtType区分不开来，所以通过id区间来区分
			if num<=1007 then   --开服冲级
				print("增加开服冲级红点，num："..num)
				self.canSubNum[TaskTag.levelGift] = self.canSubNum[TaskTag.levelGift]+1
			else 				--豪华礼包
				print("增加猎人豪礼红点，num："..num)
				self.canSubNum[TaskTag.levelGift_2] = self.canSubNum[TaskTag.levelGift_2]+1
			end
		elseif TASTYPE_NEWFUND==nType then
			self.canSubNum[TaskTag.newfund] = self.canSubNum[TaskTag.newfund]+1
		elseif TASTYPE_FOUNDACTIVITY==nType then
			self.canSubNum[TaskTag.oldfund] = self.canSubNum[TaskTag.oldfund]+1
		end
	end
	-- print(":IfAddCanSubNum(tabData) end")
	if MainScene_Instance then
		print("任务成就红点")
		MainScene_Instance:refreshTaskRedPoin()
	end
	if discountInstance then
		discountInstance:refreshActivityRedPoint()
	end
	
end

--减少可提交任务数
--@tabData：任务数据
function TaskMgr:ReduceCanSubNum(tabData)
	if nil==tabData then
		return
	end

	local loc_Task = taskData[tabData.tptId]
	if nil==loc_Task then
		return
	end
	local nType = loc_Task.type
	if TASKTYPE_DAILY==nType or TASKTYPE_NORMAL==nType then
		self.canSubNum[TaskTag.Daily] = self.canSubNum[TaskTag.Daily]-1

	elseif  TASKTYPE_ACHIEVEMENT==nType then
		self.canSubNum[TaskTag.Achievement] = self.canSubNum[TaskTag.Achievement]-1

	elseif TASKTYPE_VIP==nType then
		self.canSubNum[TaskTag.VIP] = self.canSubNum[TaskTag.VIP]-1

	elseif TASKTYPE_SIGNIN==nType then
		--do nothing
	elseif TASKTYPE_TOTALCONSUME==nType then
		self.canSubNum[TaskTag.TotalConsume] = self.canSubNum[TaskTag.TotalConsume]-1
	elseif TASKTYPE_7DAYGIFT==nType then
		self.canSubNum[TaskTag._7DayGift] = self.canSubNum[TaskTag._7DayGift]-1
	elseif TASKTYPE_FREEDIAMOND==nType then
		self.canSubNum[TaskTag.FreeDiamond] = self.canSubNum[TaskTag.FreeDiamond]-1
	elseif TASKTYPE_RECHARGE==nType then
		self.canSubNum[TaskTag.Recharge] = self.canSubNum[TaskTag.Recharge]-1
	elseif TASTYPE_ONLINE==nType then
		self.canSubNum[TaskTag.Online] = self.canSubNum[TaskTag.Online]-1
	elseif TASTYPE_LEVELGIF==nType then
		local num = tonumber(string.sub(tostring(loc_Task.id), 6,9))
		--因为表上通过type和tgtType区分不开来，所以通过id区间来区分
		if num<=1007 then   --开服冲级
			self.canSubNum[TaskTag.levelGift] = self.canSubNum[TaskTag.levelGift]-1
		else 				--豪华礼包
			self.canSubNum[TaskTag.levelGift_2] = self.canSubNum[TaskTag.levelGift_2]-1
		end
	elseif TASTYPE_NEWFUND==nType then
			self.canSubNum[TaskTag.newfund] = self.canSubNum[TaskTag.newfund]-1
	elseif TASTYPE_FOUNDACTIVITY==nType then
		self.canSubNum[TaskTag.oldfund] = self.canSubNum[TaskTag.oldfund]-1
	end
end

--任务更新消息下发
function TaskMgr:OnUpdateInfoRet(cmd)
	if 1==cmd.result then
		local updateInfo = cmd.data
		local key
		--旧任务更新
		for i=1, #cmd.data.tList do
			print("旧任务更新")
			key = cmd.data.tList[i].id
			print("------refresh old task: "..key)
			if nil~=self.idKeyInfo[key] then
				self.idKeyInfo[key].curcnt = cmd.data.tList[i].curcnt
				self.idKeyInfo[key].status = cmd.data.tList[i].status
				self:IfAddCanSubNum(cmd.data.tList[i])
				local locData = taskData[self.idKeyInfo[key].tptId]
				if locData.type==7 then
					startLoading()
					self:ReqSubmit(key)
				end
				if locData.id==102020010 or locData.id==102020011 or locData.id==102020012 then
					energyTask[locData.id] = cmd.data.tList[i].status
				end
			end
			if nil~=AchMgr.idKeyInfo[key] then
				AchMgr.idKeyInfo[key].curcnt = cmd.data.tList[i].curcnt
				AchMgr.idKeyInfo[key].status = cmd.data.tList[i].status
				AchMgr.statusList[AchMgr.idKeyInfo[key].tptId].curcnt = cmd.data.tList[i].curcnt
				AchMgr.statusList[AchMgr.idKeyInfo[key].tptId].status = cmd.data.tList[i].status
			end


		end

		--新任务添加
		if nil~=cmd.data.ntList then
			print("新任务更新")
			for i=1, #cmd.data.ntList do
				key = cmd.data.ntList[i].id
				print("------refresh new task: "..key)
				self.idKeyInfo[key] = cmd.data.ntList[i]
				self:AddTaskToSortList(key)
				self:IfAddCanSubNum(cmd.data.ntList[i])

				local locData = taskData[cmd.data.ntList[i].tptId]
				if locData.type==6 then
					AchMgr.statusList[cmd.data.ntList[i].tptId] = cmd.data.ntList[i]
					AchMgr.idKeyInfo[cmd.data.ntList[i].id] = cmd.data.ntList[i]
				end
			end

			self:ResortTask(0)
		end
		if totalConsume_Instance ~= nil then
	    	totalConsume_Instance:refreshItems()
	    end

	    if nil~=TaskLayer.Instance then
	        TaskLayer.Instance:InitTaskList()
	    end
	    if nil~=pointReward.Instance then
	    	pointReward.Instance:reloadListView()
	    	if cmd.data.point then
	    		pointReward.Instance.srvPointRewardInfo.point = cmd.data.point
		    	print("--------------------")
		    	print(cmd.data.point)
		    	print(pointReward.Instance.srvPointRewardInfo)
		    	pointReward.Instance:initRewardsList()
	    	end
	    	
	    	
	    end

	    if MainScene_Instance and cmd.data.pointReward==1 then
	    	local node = MainScene_Instance.activityMenuBar.sendVIPBt
	    	local RedPt = display.newSprite("common/common_RedPoint.png")
	            :addTo(node,0,10)
	            :pos(30,30)
	    end

	    if MainScene_Instance then --刷新新手基金红点
	    	MainScene_Instance:refreshFundRedPoint()
	    	if fundLayer.instance then --基金界面的按钮红点
	            fundLayer.instance:btRedPoint()
	        end
	    end

	else
		showTips(cmd.msg)
	end
end

--请求签到
function TaskMgr:ReqSignIn()
	local g_step = nil
	local tabMsg = {characterId=srv_userInfo.characterId, guideStep = g_step}
	m_socket:SendRequest(json.encode(tabMsg), CMD_TASK_SIGNIN, TaskMgr, TaskMgr.OnSignInRet)
end

--签到返回
function TaskMgr:OnSignInRet(cmd)
	if 1==cmd.result then
		srv_userInfo.checkInStatus = 1 	--修改状态，当天已签到
		local info = cmd.data.tList
		local key
		for i=1, #info do
			key = info[i].id
			if nil~=self.idKeyInfo[key] then
				self.idKeyInfo[key].curcnt = info[i].curcnt
				self.idKeyInfo[key].status = info[i].status
			end
		end
	else
		showTips(cmd.msg)
	end
	if nil~=TaskLayer.Instance then
        TaskLayer.Instance:OnSignInRet(cmd)
    end
    if nil~=g_SignInLayer.Instance then
        g_SignInLayer.Instance:OnSignInRet(cmd)
    end


end

--请求补签
function TaskMgr:ReqReSingIn()
	local tabMsg = {characterId=srv_userInfo.characterId}
	m_socket:SendRequest(json.encode(tabMsg), CMD_TASK_RESIGNIN, TaskMgr, TaskMgr.OnReSignInRet)
end

--补签返回
function TaskMgr:OnReSignInRet(cmd)
	if 1==cmd.result then
		srv_userInfo.reCheckInCnt = cmd.data.reCheckInCnt 	--修改补签次数
		local info = cmd.data.tList
		local key
		for i=1, #info do
			key = info[i].id
			if nil~=self.idKeyInfo[key] then
				self.idKeyInfo[key].curcnt = info[i].curcnt
				self.idKeyInfo[key].status = info[i].status
			end
		end

		srv_userInfo.diamond = srv_userInfo.diamond - SignCost[srv_userInfo.reCheckInCnt]+1
		DCCoin.lost("补签消耗钻石","钻石",SignCost[srv_userInfo.reCheckInCnt]-1,srv_userInfo.diamond)
	else
		showTips(cmd.msg)
	end
	if nil~=TaskLayer.Instance then
        TaskLayer.Instance:OnReSignInRet(cmd)
    end
    if nil~=g_SignInLayer.Instance then
        g_SignInLayer.Instance:OnReSignInRet(cmd)
    end
end

--请求提交任务
function TaskMgr:ReqSubmit(nTaskID)
	if nil==nTaskID then
		return false
	end
	print("nTaskID------------1111111111  : "..nTaskID)
	local tplID = self.idKeyInfo[nTaskID].tptId
	print(tplID)
	self.nCurSubmitTaskID = nTaskID
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(104) --第一个任务提交
	g_step = g_step or GuideManager:tryToSendFinishStep(124) --12级任务提交
	local tabMsg = {characterId=srv_userInfo.characterId, taskId=nTaskID, guideStep = g_step}
	m_socket:SendRequest(json.encode(tabMsg), CMD_TASK_SUBMIT, TaskMgr, TaskMgr.OnSubmitRet)

	return true
end

--提交任务返回
function TaskMgr:OnSubmitRet(cmd)
	if 1==cmd.result then print("self.nCurSubmitTaskID:  2222222  : "..self.nCurSubmitTaskID)
		
		local tplID = self.idKeyInfo[self.nCurSubmitTaskID].tptId
		local locData = taskData[tplID]

		if tplID==109400007 then --七天礼最后一天领完后，隐藏主界面图标
			TaskMgr.hasSevenDay = false
			if MainScene_Instance then
			    node = MainScene_Instance.activityMenuBar.startServerBt
			    node:setVisible(false)
			end
		end

		if tplID==105200001 or tplID==105210001 or tplID==105220001 then
			self.idKeyInfo[self.nCurSubmitTaskID].status = 2

		elseif locData.type==7 then
			self:GuideTaskRewards(tplID)
			DCTask.begin(tplID..locData.name, 1)
		else
			self:ReduceCanSubNum(self.idKeyInfo[self.nCurSubmitTaskID])
			if taskData[tplID].type==10 then
				self.idKeyInfo[self.nCurSubmitTaskID].status = 2
			else
				self.idKeyInfo[self.nCurSubmitTaskID] = nil
			end
			
			self:DelTaskFromSortList(self.nCurSubmitTaskID)

			if nil~=AchMgr.idKeyInfo[self.nCurSubmitTaskID] then
				--print(AchMgr.idKeyInfo[self.nCurSubmitTaskID].curcnt.." ->new curcnt: "..2)
				print(AchMgr.idKeyInfo[self.nCurSubmitTaskID].status.." ->new status: "..2)
				--AchMgr.idKeyInfo[self.nCurSubmitTaskID].curcnt = cmd.data.tList[i].curcnt

				AchMgr.idKeyInfo[self.nCurSubmitTaskID].status = 2
				--AchMgr.statusList[AchMgr.idKeyInfo[self.nCurSubmitTaskID].tptId].curcnt = 2
				AchMgr.statusList[AchMgr.idKeyInfo[self.nCurSubmitTaskID].tptId].status = 2
				DCTask.begin(tplID..locData.name, 3)
			else
				DCTask.begin(tplID..locData.name, 4)
			end
		end
		DCTask.complete(tplID..locData.name)
		self.nCurSubmitTaskID = 0
		if nil~=locData.rewardItems and 0~=locData.rewardItems and ""~=locData.rewardItems then
			local arr = string.split(locData.rewardItems, "|")
			local subArr
			for i=1, #arr do
				subArr = string.split(arr[i], "#")
				local dc_item = itemData[tonumber(subArr[1])]
				if dc_item then --如果奖励为道具
					DCItem.get(tostring(dc_item.id), dc_item.name, tonumber(subArr[2]), "任务奖励: "..locData.name)
				end
			end
		end
		if 0~=locData.gold then
			DCCoin.gain("任务奖励: "..locData.name,"金币",locData.gold,srv_userInfo.gold+locData.gold)
		end
		if 0~=locData.diamond then
			DCCoin.gain("任务奖励: "..locData.name,"钻石",locData.diamond,srv_userInfo.diamond+locData.diamond)
		end
		--在线奖励功能关闭
		-- if MainScene_Instance then
		-- 	local locData = taskData[tplID+1]
		-- 	if taskData[tplID].type==11 then
		-- 		MainScene_Instance.activityMenuBar:showOnlineActReward()
		-- 		if locData then
		-- 			g_ActOnLineListTs = locData.cnt*60*1000
		-- 		else
		-- 			MainScene_Instance.activityMenuBar.onlineActivity:setVisible(false)
		-- 		end
				
		-- 	end
			
		-- end
	else
		if cmd.result==-4 then --已经领过奖了（可能是由于之前领奖的瞬间断了线，没有收到返回，导致面板没刷新，才能在这里继续点）
			if nil~=TaskLayer.Instance then
		        TaskLayer.Instance:OnSubmitRet(cmd)
		    end
		end
		showTips(cmd.msg)
	end
	if nil~=TaskLayer.Instance then
		print("提交返回，mgr")
        TaskLayer.Instance:OnSubmitRet(cmd)
    end
    if nil~=g_SignInLayer.Instance then
        g_SignInLayer.Instance:OnSubmitRet(cmd)
    end

    if achievementTree.Instance ~= nil then
    	achievementTree.Instance:OnSubmitRet(cmd)
    end

    if totalConsume_Instance ~= nil then
    	totalConsume_Instance:OnSubmitRet(cmd)
    end

    if oneWeekReward.Instance~=nil then
    	oneWeekReward.Instance:OnSubmitRet(cmd)
    end

    if firstRecharge.Instance~=nil then
    	firstRecharge.Instance:OnSubmitRet(cmd)
    end

    if firstWeekReward.Instance~=nil then
    	firstWeekReward.Instance:OnSubmitRet(cmd)
    end
    if levelGift_Instance~=nil then
    	levelGift_Instance:OnSubmitRet(cmd)
    end

    if MainScene_Instance then
		print("任务成就红点")
		MainScene_Instance:refreshTaskRedPoin()
		--积分红点
		num = TaskMgr:GetCanSubNum(TaskTag._7DayGift)
	    node = MainScene_Instance.activityMenuBar.startServerBt
	    if node and num==0 then
	        node:removeChildByTag(10)
	    end
	end
    if discountInstance then
		discountInstance:refreshActivityRedPoint()
	end

	if foundAct.Instance then
		foundAct.Instance:OnSubmitRet(cmd)
	end

	if pointReward.Instance then
		pointReward.Instance:OnSubmitRet(cmd)
	end

	if newfund.instance then
		newfund.instance:OnSubmitRet(cmd)
		MainScene_Instance:refreshFundRedPoint()
	end

	if Branch.Instance then
		Branch.Instance:OnSubmitRet(cmd)
	end
end

--初始化排序列表
function TaskMgr:_InitSortList()
	self.sortList = {}
	for i=1, TaskTag.Num do
		self.sortList[i] = {}
	end
	print("self.idKeyInfo--------------------------------")
	-- printTable(self.idKeyInfo)
		print("self.idKeyInfo-----------------------------------")

	local nType
	for k, v in pairs(self.idKeyInfo) do
		if nil~=taskData[v.tptId] then
			nType = taskData[v.tptId].type
			-- print("-------------------------uuuuu----- nType: "..nType)
			if TASKTYPE_DAILY==nType or TASKTYPE_NORMAL==nType then
				table.insert(self.sortList[TaskTag.Daily], k)

			elseif TASKTYPE_ACHIEVEMENT==nType then
				table.insert(self.sortList[TaskTag.Achievement], k)

			elseif TASKTYPE_VIP==nType then
				table.insert(self.sortList[TaskTag.VIP], k)

			elseif TASKTYPE_SIGNIN==nType then
				table.insert(self.sortList[TaskTag.SignIn], k)
			end
		end
	end
	self:ResortTask(0)

end

--排序任务对应标签列表(nTag:任务标签，0-重排全部)
function TaskMgr:ResortTask(nTag)
	-- print("11111111111111111111111111111111")
	local function SortFunc(val1, val2)
		local data1 = self.idKeyInfo[val1]
		local data2 = self.idKeyInfo[val2]
		if nil~=data1 and nil~=data2 then
			if data1.status==data2.status then
				local loc_data1 = taskData[data1.tptId]
				local loc_data2 = taskData[data2.tptId]
				if nil~=loc_data1 and nil~=loc_data2 then
					if loc_data1.top>loc_data2.top then
						return true
					end
					if loc_data1.top<loc_data2.top then
						return false
					end
				else
					return val1<val2
				end
				
				return val1<val2
			else
				return data1.status>data2.status
			end
		else
			return val1<val2
		end
	end

	

	if nTag==0 then
		for i=1, TaskTag.Num do
			table.sort(self.sortList[i], SortFunc)
		end

	elseif nTag==TaskTag.Daily then
		table.sort(self.sortList[TaskTag.Daily], SortFunc)

	elseif nTag==TaskTag.Achievement then
		table.sort(self.sortList[TaskTag.Achievement], SortFunc)
	elseif nTag==TaskTag.VIP then
		table.sort(self.sortList[TaskTag.VIP], SortFunc)

	elseif nTag==TaskTag.SignIn then
		table.sort(self.sortList[TaskTag.SignIn], SortFunc)

	end
	-- print("-------------------------------------------777")
	-- printTable(self.sortList[TaskTag.Daily])
	-- for k,v in pairs(self.sortList[TaskTag.Daily])do
	-- 	printTable(self.idKeyInfo[v])
	-- 	print("========================================================")
	-- end

	-- print("-------------------------------------------nnn")
end

--添加任务ID至排序列表(需要idKeyInfo中有该ID)
function TaskMgr:AddTaskToSortList(nTaskID)
	if nil==nTaskID then
		return 0
	end

	local nRet = 0
	local v = self.idKeyInfo[nTaskID]
	if nil==v then
		return nRet
	end

	if nil~=taskData[v.tptId] then
		local nType = taskData[v.tptId].type
		if TASKTYPE_DAILY==nType or TASKTYPE_NORMAL==nType then
			table.insert(self.sortList[TaskTag.Daily], nTaskID)
			nRet = TaskTag.Daily

		elseif  TASKTYPE_ACHIEVEMENT==nType then
			table.insert(self.sortList[TaskTag.Achievement], nTaskID)
			nRet = TaskTag.Achievement

		elseif TASKTYPE_VIP==nType then
			table.insert(self.sortList[TaskTag.VIP], nTaskID)
			nRet = TaskTag.VIP

		elseif TASKTYPE_SIGNIN==nType then
			table.insert(self.sortList[TaskTag.SignIn], nTaskID)
			nRet = TaskTag.SignIn

		end

	end

	return nRet
end

--从排序列表删除任务ID
function TaskMgr:DelTaskFromSortList(nTaskID)
	for i=1, TaskTag.Num do
		if i~=TaskTag.SignIn then 	--签到任务不删除
			for j=1, #self.sortList[i] do
				if nTaskID==self.sortList[i][j] then
					table.remove(self.sortList[i], j)
					return i, j
				end
			end
		end
	end

	return 0, 0
end

function TaskMgr:GetCanSubNum(nTag)

	local nNum = 0
	if nil==nTag then
		for i=1, #self.canSubNum do
			nNum = nNum+self.canSubNum[i]
		end
	else 
		if nil~=self.canSubNum[nTag] then
			nNum = nNum+self.canSubNum[nTag]
			
		end
	end
	if nTag==TaskTag.Daily then
		local arr2 = string.split(os.date("%H:%M"),":")
		local nowH,nowM= tonumber(arr2[1]),tonumber(arr2[2])
		if energyTask[102020010]==1 and nowH>=14 then --可领奖，但是时间过了（服务端没处理）
			nNum = nNum-1
		end
		if energyTask[102020011]==1 and nowH>=20 then --可领奖，但是时间过了（服务端没处理）
			nNum = nNum-1
		end
		if energyTask[102020012]==1 and nowH>=23 then --可领奖，但是时间过了（服务端没处理）
			nNum = nNum-1
		end		
	end

	return nNum
end

--获取当月总天数
function TaskMgr:GetCurTotalDays()
	local days = tonumber(os.date("%d",os.time({year=os.date("%Y"),month=os.date("%m")+1,day=0})))
	return days
end

--新手引导奖励弹框
function TaskMgr:GuideTaskRewards(taskTmpId)
  local lcl_data = taskData[taskTmpId]
  local curRewards = {}
  if lcl_data.gold>0 then
  	table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=lcl_data.gold})
  end
  if lcl_data.diamond>0 then
  	table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=lcl_data.diamond})
  end
  if lcl_data.exp>0 then
  	table.insert(curRewards, {templateID=GAINBOXTPLID_EXP, num=lcl_data.exp})
  end
  
  local rewardItems = lua_string_split(lcl_data.rewardItems, "|")
  for i=1,#rewardItems do
      local item = lua_string_split(rewardItems[i], "#")
      table.insert(curRewards, {templateID=tonumber(item[1]), num=tonumber(item[2])})
  end
  GlobalShowGainBox(nil, curRewards)

  --更新金币钻石等数据
  srv_userInfo.gold = srv_userInfo.gold + lcl_data.gold
  srv_userInfo.diamond = srv_userInfo.diamond + lcl_data.diamond
  srv_userInfo.exp = srv_userInfo.exp + lcl_data.exp
  mainscenetopbar:setGlod()
  mainscenetopbar:setDiamond()
   DCCoin.gain("新手引导奖励","金币",lcl_data.gold,srv_userInfo.gold)
   DCCoin.gain("新手引导奖励","钻石",lcl_data.diamond,srv_userInfo.diamond)
end
