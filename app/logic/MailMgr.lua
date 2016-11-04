--
-- Author: Jun Jiang
-- Date: 2015-02-05 17:34:10
--

--邮件状态
STATUS_MAIL_UNREAD		= 1 --未读
STATUS_MAIL_READ 		= 2 --已读
STATUS_MAIL_GET_REWARDS = 3 --已领奖

MailMgr = class("MailMgr")
MailMgr.mailInfo = {} 		--邮件信息
MailMgr.sortList = {} 		--排序列表
MailMgr.curMailDesData = {} --当前邮件的数据（记录下来，方便领取后修改本地金币钻石等数据）
MailMgr.canReadNum 			= 0 	--未读的邮件数量

--初始化
function MailMgr:InitByCmd(cmd)
	if 1==cmd.result then
		self.mailInfo = {}
		self.sortList = {}

		local key, val
		for i=1, #cmd.data.mList do
			val = cmd.data.mList[i]
			key = val.id
			self.mailInfo[key] = val
			table.insert(self.sortList, key)
			if STATUS_MAIL_UNREAD==val.status then
				self.canReadNum = self.canReadNum + 1
			end
		end
		self:Resort()
		-- print("aaa777777777777777777777777777777777777777777")
		-- printTable(self.mailInfo)
		-- print("bbb777777777777777777777777777777777777777777")
		-- printTable(self.sortList)
		-- print("ccc777777777777777777777777777777777777777777")
		--邮件红点
		-- if ActivityMenuBar and  not ActivityMenuBar.mailBt:getChildByTag(10) then
		-- 	local isMailRed = false
		-- 	for i,value in pairs(self.mailInfo) do
		-- 		if value.status==1 then
		-- 			isMailRed = true
		-- 			break
		-- 		end
		-- 	end
		-- 	if isMailRed then
		-- 		display.newSprite("common/common_RedPoint.png")
		-- 		:addTo(self.mailBt)
		-- 		:pos(30,30)
		-- 	end
		-- end
		
	else
		showTips(cmd.msg)
	end
end

--添加新邮件
function MailMgr:AddNewMail(cmd)
	if 1==cmd.result then
		print("实时添加新邮件---")
		local key, val
		for i=1, #cmd.data.mail do
			val = cmd.data.mail[i]
			key = val.id
			self.mailInfo[key] = val
			table.insert(self.sortList, key)
			if STATUS_MAIL_UNREAD==val.status then
				self.canReadNum = self.canReadNum + 1
				if MailMgr.canReadNum>0 and MainScene_Instance then
					local node = MainScene_Instance.activityMenuBar.mailBt
					node:removeChildByTag(10)
			        local RedPt = display.newSprite("common/common_RedPoint.png")
			        :addTo(node,0,10)
			        :pos(30,30)
			    end
			end
		end
		self:Resort()
		-- printTable(cmd.data.mail)
	else
		showTips(cmd.msg)
	end
end

--请求详细信息
function MailMgr:ReqDes(nMailID)
	local tabMsg = {characterId=srv_userInfo.characterId, mailId=nMailID}
	m_socket:SendRequest(json.encode(tabMsg), CMD_MAIL_DES, MailMgr,  MailMgr.OnDesRet)
end

--邮件详细信息返回
function MailMgr:OnDesRet(cmd)
	if 1==cmd.result then
		print("邮件详细信息返回")
		MailMgr.curMailDesData = cmd.data
		local srvData = cmd.data
		if nil~=self.mailInfo[srvData.id] then
			local oldStatus = self.mailInfo[srvData.id].status
			self.mailInfo[srvData.id].status = STATUS_MAIL_READ
			if oldStatus~=srvData.status then
				self:Resort()
			end
			if STATUS_MAIL_UNREAD==oldStatus then
				self.canReadNum = self.canReadNum - 1
			end
		end

		if self.canReadNum<=0 then
			local node = display.getRunningScene().activityMenuBar.mailBt:getChildByTag(10)
			if node then
				node:removeFromParent()
			end
		end
	else
		showTips(cmd.msg)
	end
	if nil~=MailLayer.Instance then
        MailLayer.Instance:OnDesRet(cmd)
    end
end

--请求领取附件
function MailMgr:ReqGet(nMailID)
	local tabMsg = {characterId=srv_userInfo.characterId, mailId=nMailID}
	m_socket:SendRequest(json.encode(tabMsg), CMD_MAIL_GETATTACHMENT, MailMgr, MailMgr.OnGetRet)
end

--领取附件返回
function MailMgr:OnGetRet(cmd)
	print("领取附件返回")
	if 1==cmd.result then
		local srvData = cmd.data
		if nil~=self.mailInfo[srvData.id] then
			self.mailInfo[srvData.id].status = STATUS_MAIL_GET_REWARDS
		end

		--删除
		--self:DelMail(srvData.id)
		--修改本地金币钻石数据
		if self.curMailDesData.gold then
			srv_userInfo.gold = srv_userInfo.gold + self.curMailDesData.gold
			mainscenetopbar:setGlod()
		end
		if self.curMailDesData.diamond then
			srv_userInfo.diamond = srv_userInfo.diamond + self.curMailDesData.diamond
			mainscenetopbar:setDiamond()
		end
		if self.curMailDesData.reputation then
			srv_userInfo.reputation = srv_userInfo.reputation + self.curMailDesData.reputation
		end
		if self.curMailDesData.exploit then
			srv_userInfo.exploit = srv_userInfo.exploit + self.curMailDesData.exploit
		end
		
	else
		showTips(cmd.msg)
	end
	if nil~=MailLayer.Instance then
        MailLayer.Instance:OnGetRet(cmd)
    end
end

--删除邮件
function MailMgr:DelMail(nMailID)
	self.mailInfo[nMailID] = nil
	for i=1, #self.sortList do
		if self.sortList[i]==nMailID then
			table.remove(self.sortList, i)
		end
	end
end

--排序邮件列表
function MailMgr:Resort()
	if nil==self.sortList then
		return
	end

	local function SortFunc(val1, val2)
		local data1 = self.mailInfo[val1]
		local data2 = self.mailInfo[val2]

		if data1.status==data2.status then
			return val1>val2
		else
			return data1.status<data2.status
		end
	end

	table.sort(self.sortList, SortFunc)
end