--
-- Author: Jun Jiang
-- Date: 2014-10-30 14:34:37
--
--------------------------宏/常量-------------------------------------------
proType_Tanker		= 1 	--坦克手
proType_Mechanic	= 2 	--机械师
proType_Fighter		= 3 	--格斗家

roleEquip_Weapon	= 1 	--武器
roleEquip_Clothes	= 2 	--衣服
roleEquip_Shoes		= 3 	--鞋子
roleEquip_Hat		= 4 	--帽子
roleEquip_Armor		= 5 	--护甲
roleEquip_Glove		= 6 	--手套

--人物技能激活所需战队等级(一技能、二技能...)
RoleSkillActLev = {10, 20, 30}

--技能提升消耗金钱系数（消耗 = 当前技能等级x系数）
RoleSkillUpCostFactor = {500, 500, 1000} 	--(一技能、二技能...)

--换装等级限制
RoleChangeEptLimitLvl = {
	10, 23, 47, 67
}

--人物称号
RoleTitle = {
	{"无知少年","初级驾驶员","助理机枪手","火炮装填手","高级炮手","战车车长"},
	{"无知少年","机械学徒","维修助理","助理工程师","机械工程师","机械专家"},
	{"无知少年","菜鸟新兵","二等侦察兵","绿色贝雷帽","海军陆战队","职业特工"},
}
--技能buff类型
SkillBuffType = {
	"停滞打断",
	"击退状态",
	"冰冻状态", 
	"电磁干扰", 
	"致盲状态",
	"腐蚀状态",
	"着火状态",
	"吸收",
	"攻击",
	"攻击",
	"防御",
	"防御",
	"攻速",
	"命中",
	"命中",
	"闪避",
	"闪避",
	"场景buff特效",
	"暴击",
	"沉默",
}
----------------------------------------------------------------------------

RoleManager = class("RoleManager")
RoleManager.srv_RoleProp 	= nil		--人物属性
RoleManager.roleIDKeyList 	= nil 		--以ID为key值的角色列表，方便快速定位
RoleManager.isReqFlag		= true      --是否请求获取角色信息接口(标志位)


function RoleManager:ReqRolePropertyData(nCharacterID)
	local tabMsg = {characterId=nCharacterID}
    m_socket:SendRequest(json.encode(tabMsg), CMD_ROLE_PROPERTY, RoleManager, RoleManager.OnRolePropertyDataRet)
end

function RoleManager:OnRolePropertyDataRet(cmd)
	-- printTable(cmd)
	if 1==cmd.result then
		RoleManager.isReqFlag = false
		self.srv_RoleProp = cmd.data
		self.roleIDKeyList = {}
		local key, val
		for i=1, #self.srv_RoleProp.members do
			val = self.srv_RoleProp.members[i]
			key = val.id
			self.roleIDKeyList[key] = val
		end
		--[[
		cmd = {
			    ["result"] = 1,
				["msg"] = "Successed",
				["data"] = {
				    ["proTal"] = 500,
				    ["members"] = {
				        [1] = {
				            ["itemSkil"] = "攻击前排",
				            ["id"] = 1007,
				            ["miss"] = 21.1,
				            ["hp"] = 1587,
				            ["proLevel"] = 5.5,
				            ["proType"] = 1,
				            ["equip"] = {
				                [1] = 1170,
				                [2] = 1171,
				                [3] = 1172,
				                [4] = 1173,
				                [5] = 1174,
				                [6] = 1175,
				            },
				            ["proGrowFac"] = 0.5,
				            ["cri"] = 19.2,
				            ["strength"] = 543.86,
				            ["attack"] = 169,
				            ["hit"] = 16.9,
				            ["tmpId"] = 101,
				            ["power"] = 11,
				            ["agility"] = 17,
				            ["energy"] = 16,
				            ["name"] = "de2ccctet",
				            ["defense"] = 49,
				        },
				        [2] = {
				            ["itemSkil"] = "攻击前排",
				            ["id"] = 1005,
				            ["miss"] = 23.5,
				            ["hp"] = 2067,
				            ["proLevel"] = 8.8,
				            ["proType"] = 3,
				            ["equip"] = {
				                [1] = 1176,
				                [2] = 1177,
				                [3] = 1178,
				                [4] = 1179,
				                [5] = 1180,
				                [6] = 1181,
				            },
				            ["proGrowFac"] = 0.8,
				            ["cri"] = 19.1,
				            ["strength"] = 630.91,
				            ["attack"] = 164,
				            ["hit"] = 16.2,
				            ["tmpId"] = 103,
				            ["power"] = 10,
				            ["agility"] = 21,
				            ["energy"] = 18,
				            ["name"] = "哈哈",
				            ["defense"] = 42,
				        },
				    },
				    ["teamLevel"] = 11,
				    ["gflevel"] = 1,
				    ["proItems"] = {
				        [1] = 1091,
				    },
				    ["teamMaxExp"] = 670,
				    ["growfac"] = 0.5,
				    ["teamExp"] = 620,
				},
			}
		]]
	else
		showTips(cmd.msg)
		printInfo("RoleManager:ReqRolePropertyData failed!")
	end
	if nil~=g_RolePropertyLayer.Instance then
        g_RolePropertyLayer.Instance:OnRolePropertyDataRet(cmd)
    end
end

--请求职业养成
function RoleManager:ReqProfDev(memId)
	print(memId)
	startLoading()
	local tabMsg  = {}
	tabMsg["memberId"] = memId
    m_socket:SendRequest(json.encode(tabMsg), CMD_PROFESSION_DEVELOP, RoleManager, RoleManager.OnProfDevRet)
end

--职业养成返回
function RoleManager:OnProfDevRet(cmd)
	if 1==cmd.result then
		-- if nil==RoleManager.srv_RoleProp then
		-- 	return
		-- end

		-- RoleManager.srv_RoleProp.gflevel = cmd.data.gflevel
		-- RoleManager.srv_RoleProp.growfac = cmd.data.growfac
		-- RoleManager.srv_RoleProp.proTal = cmd.data.proTal
		--[[ 
		cmd = {
			    "msg": "学习成功", 
			    "data": {
			        "gflevel": 2, 
			        "growfac": 0.22, 
			        "proTal": 1500
			    }, 
			    "result": 1
			}
		]]
	else
		showTips(cmd.msg)
		printInfo("RoleManager:ReqProfDev failed")
	end
	if nil~=g_RolePropertyLayer.Instance then
        g_RolePropertyLayer.Instance:OnProfDevRet(cmd)
    end
end

--请求提升技能
function RoleManager:ReqUpSkill(nRoleID, nSkillID)
	local g_step = nil
	g_step = GuideManager:tryToSendFinishStep(122) --12级任务
	local tabMsg = {memberId=nRoleID, sklId=nSkillID, guideStep = g_step}
    m_socket:SendRequest(json.encode(tabMsg), CMD_ROLE_UPSKILL, RoleManager, RoleManager.OnUpSkillRet)
end

--提升技能返回
function RoleManager:OnUpSkillRet(cmd)
	if 1==cmd.result then
		local roleInfo = self.roleIDKeyList[cmd.data.memberId]
		if nil==roleInfo then
			return
		end

		for i=1, #roleInfo.skl do
			if roleInfo.skl[i].id==cmd.data.sklId then
				srv_userInfo.gold = srv_userInfo.gold-roleInfo.skl[i].lvl*RoleSkillUpCostFactor[i]
				roleInfo.skl[i].lvl = roleInfo.skl[i].lvl+1
				srv_userInfo.sklPoint = srv_userInfo.sklPoint-1
				break
			end
		end
	else
		showTips(cmd.msg)
	end
	if nil~=g_RolePropertyLayer.Instance then
        g_RolePropertyLayer.Instance:OnUpSkillRet(cmd)
    end
end