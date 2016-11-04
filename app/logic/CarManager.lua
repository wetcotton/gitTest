--
-- Author: Jun Jiang
-- Date: 2014-11-03 10:42:41
--
-------------------------宏/常量----------------------------
--战车列表进入方式
OpenBy_Drive 			= 1 		--乘降打开
OpenBy_Improve 			= 2 		--改造打开
OpenBy_Embattle 		= 3 		--布阵打开
OpenBy_worldBoss 		= 4 		--世界boss

--攻击范围
atkScope_FrontOne		= 1 		--前排单体
atkScope_BackOne		= 2 		--后排单体
atkScope_FrontAll 		= 3 		--前排
atkScope_MidAll 		= 4 		--中排
atkScope_BackAll		= 5 		--后排
atkScope_All 			= 6 		--全体

--战车技能激活所需星级(一技能、二技能...)
CarSkillActStar = {1, 8, 15, 18}

--战车技能激活消耗金钱（消耗 = 当前技能等级x系数）
CarSkillActCost = {0, 100000, 800000, 2000000} 	--(一技能、二技能...)
------------------------------------------------------------

CarManager = class("CarManager")
CarManager.srv_CarProp 			= nil 	--服务器数据（自己）
CarManager.carIDKeyList 		= nil 	--以ID为key值的战车列表，方便快速定位（自己）
CarManager.nReqCharacterID 		= nil 	--请求战车信息的角色ID
CarManager.other_srv_CarProp 	= nil 	--服务器数据（他人）
CarManager.other_carIDKeyList	= nil 	--以ID为key值的战车列表，方便快速定位（他人）
CarManager.isReqFlag            = true   --判断是否请求战车信息的标志位

function CarManager:ReqCarProperty(nCharacterID)
	local tabMsg = {characterId=nCharacterID}
    m_socket:SendRequest(json.encode(tabMsg), CMD_CAR_PROPERTY, CarManager, CarManager.OnCarPropertyRet)

    self.nReqCharacterID = nCharacterID
end

function CarManager:OnCarPropertyRet(cmd)
	if 1==cmd.result then
        CarManager.isReqFlag = false
		if self.nReqCharacterID==srv_userInfo["characterId"] then
			self.srv_CarProp = cmd.data
			self.carIDKeyList = {}
			local key, val
			for i=1, #self.srv_CarProp.cars do
				val = self.srv_CarProp.cars[i]
				key = val.id
				self.carIDKeyList[key] = val
			end
		else
			self.other_srv_CarProp = cmd.data
			self.other_carIDKeyList = {}
			local key, val
			for i=1, #self.other_srv_CarProp.cars do
				val = self.other_srv_CarProp.cars[i]
				key = val.id
				self.other_carIDKeyList[key] = val
			end
		end
	else
		showTips(cmd.msg)
		printInfo("CarManager:ReqProperty failed!")
	end
	if nil~=g_CarListLayer.Instance then
        g_CarListLayer.Instance:OnCarPropertyRet(cmd)      --打开自己战车列表界面
    end
    if nil~=g_ImproveLayer.Instance then
        g_ImproveLayer.Instance:OnCarPropertyRet(cmd)
    end
end

--请求更新战车成员
function CarManager:ReqUpdateCarMember(nCarID, nMemberID)
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(105) --装备德里克
	local tabMsg = {characterId=srv_userInfo["characterId"], carId=nCarID, memberId=nMemberID, guideStep = g_step}
    m_socket:SendRequest(json.encode(tabMsg), CMD_CAR_UPDATEMEMBER, CarManager, CarManager.OnUpdateCarMemberRet)
end

--更新战车成员请求返回
function CarManager:OnUpdateCarMemberRet(cmd)
	if 1==cmd.result then
        CarManager.isReqFlag = true
		--todo
	else
		showTips(cmd.msg)
		printInfo("CarManager:ReqUpdateCarMember failed!")
	end
	if nil~=g_DriveLayer.Instance then
        g_DriveLayer.Instance:OnUpdateCarMemberRet(cmd)
    end
end

--请求开孔
function CarManager:ReqUnlock(nCarID, nPos)
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(109) --c装置开孔
	local tabMsg = {characterId=srv_userInfo.characterId, carId=nCarID, pos=nPos,guideStep = g_step}
    m_socket:SendRequest(json.encode(tabMsg), CMD_CARIMPROVE_UNLOCK, CarManager, CarManager.OnUnlockRet)
end

--开孔返回
function CarManager:OnUnlockRet(cmd)
	if 1==cmd.result then
		local carTab = self.carIDKeyList[cmd.data.carId]
		carTab.holes[cmd.data.pos] = 0
		DCCoin.lost("战车开孔","金币",data.gold -srv_userInfo.gold ,data.gold)
        srv_userInfo.gold = data.gold
        mainscenetopbar:setGlod()
	else
		showTips(cmd.msg)
	end
	if nil~=g_ImproveLayer.Instance then
        g_ImproveLayer.Instance:OnUnlockRet(cmd)
    end
end

--请求提升
function CarManager:ReqImprove(nCarID)
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(126) --战车改装
	local tabMsg = {characterId=srv_userInfo.characterId, carId=nCarID, guideStep = g_step}
    m_socket:SendRequest(json.encode(tabMsg), CMD_CARIMPROVE_UPGRADE, CarManager, CarManager.OnImproveRet)
end

--提升返回
function CarManager:OnImproveRet(cmd)
	if 1==cmd.result then
		print("----------------------------------------------改装")
		printTable(cmd.data)
		local newCarTab = cmd.data.carInfo
		local nThisID = newCarTab.id
		for i=1, #self.srv_CarProp.cars do
			if nThisID==self.srv_CarProp.cars[i].id then
				self.srv_CarProp.cars[i] = newCarTab
			end
		end
		if data.gold~=nil then
			DCCoin.lost("战车改装","金币",data.gold -srv_userInfo.gold ,data.gold)
	        srv_userInfo.gold = data.gold
	        mainscenetopbar:setGlod()
		end

		self.carIDKeyList[nThisID] = newCarTab
	else
		showTips(cmd.msg)
	end
	if nil~=g_ImproveLayer.Instance then
        g_ImproveLayer.Instance:OnImproveRet(cmd)
    end
end

--请求激活技能
function CarManager:ReqActSkill(nCarID, nSkillID)
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(111) --德里克第一个技能激活
	local tabMsg = {carId=nCarID, sklId=nSkillID, guideStep = g_step}
    m_socket:SendRequest(json.encode(tabMsg), CMD_CAR_ACTIVESKILL, CarManager, CarManager.OnActSkillRet)
end

--激活技能返回
function CarManager:OnActSkillRet(cmd)
	if 1==cmd.result then
		local srv_Car = self.carIDKeyList[cmd.data.carId]
        self.carIDKeyList[cmd.data.carId].strength = cmd.data.strength
		for i=1, #srv_Car.skl do
			if srv_Car.skl[i].id==cmd.data.sklId then
				srv_Car.skl[i].sts = 1 --激活后更新此处了技能数据（换装后重新请求了数据来更新技能）
				srv_userInfo.gold = srv_userInfo.gold-CarSkillActCost[i]
				DCCoin.lost("激活战车技能","金币",CarSkillActCost[i],srv_userInfo.gold)
                --修改主界面技能数据（显示红点数据）
                for key,value in ipairs(main_carSklData) do
                    if value.id==cmd.data.carId then
                        for j=1,4 do
                            local keyStr = "skl"..j.."Sts"
                            value[keyStr] = srv_Car.skl[i].sts
                        end
                        break
                    end
                end
				break
			end
		end
	else
		showTips(cmd.msg)
	end
    if nil~=g_ImproveLayer.Instance then
            g_ImproveLayer.Instance:OnActSkillRet(cmd)
    end
end