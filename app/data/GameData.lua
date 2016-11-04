
------------------宏/常量-----------------------



--物品种类ID
ITEMTYPE_MAINGUN	= 101		--主炮
ITEMTYPE_SUBGUN		= 102		--副炮
ITEMTYPE_SEGUN		= 103		--SE炮
ITEMTYPE_ENGINE		= 104		--引擎
ITEMTYPE_CDEV		= 105		--C装置
ITEMTYPE_TOOL		= 106		--工具
ITEMTYPE_SEBLT		= 107		--特种弹
ITEMTYPE_BUGLE		= 108		--军号
ITEMTYPE_SPECIALBULLET = 109    --普通弹

ITEMTYPE_WEAPON		= 201		--武器
ITEMTYPE_HAT		= 202		--帽子
ITEMTYPE_CLOTHES	= 203		--衣服
ITEMTYPE_GLOVE		= 204		--手套
ITEMTYPE_SHOES		= 205		--鞋子
ITEMTYPE_ARMOR		= 206		--护甲
------------------------------------------------

--------------------图层Tag---------------------
TAG_BACKPACK_LAYER              = 1001
TAG_EQUIPMENT_LAYER             = 1002
TAG_FERIEND_LAYER               = 1003
TAG_MASK_LAYER                  = 1004
TAG_AREA_LAYER					= 1005
------------------------------------------------

--------------------进入主界面类型---------------------
MainSceneEnterType = 0  --进入战斗的类型
EnterTypeList = {}
EnterTypeList.NORMAL_ENTER			   	= 0
EnterTypeList.FIGHT_ENTER              	= 1
EnterTypeList.GETEQUIPMENT_ENTER       	= 2
EnterTypeList.TASK_ENTER               	= 3
EnterTypeList.TEAM_ENTER               	= 4
EnterTypeList.ROLEPROPERTY_ENTER       	= 5
EnterTypeList.EQUIPMENT_ENTER		   	= 6
EnterTypeList.BOUNTY_ENTER              = 7
EnterTypeList.PVP_ENTER                 = 8
EnterTypeList.FAILD_LINK1               = 9
EnterTypeList.FAILD_LINK2               = 10
EnterTypeList.FAILD_LINK3               = 11
EnterTypeList.MAIN_LINE                 = 12
EnterTypeList.CARPROPERTY_ENTER         = 13
EnterTypeList.ACHIEVEMENT_ENTER         = 14
EnterTypeList.CARADVANCE_ENTER         = 15

--------------------进入战斗场景的类型-------------
FightSceneEnterType = 0
EnterTypeList_2 = {}
EnterTypeList_2.NORMAL_ENTER           = 0
EnterTypeList_2.RELICS_ENTER           = 1        --遗迹探测
EnterTypeList_2.EXPEDITION_ENTER       = 2        --远征
EnterTypeList_2.WORLDBOSS_ENTER       = 3        --世界BOSS

--------------------钻石消耗统计类型--------------------
BUY_TYPE_NORMAL = 1
BUY_TYPE_NORMAL_REFRESH = 2
BUY_TYPE_PVP = 3
BUY_TYPE_PVP_REFRESH = 4
BUY_TYPE_ARMY = 5
BUY_TYPE_ARMY_REFRESH = 6
BUY_TYPE_SEBLT = 7
BUY_TYPE_SEBLT_REFRESH = 8
BUY_TYPE_LOTTERY = 9
BUY_TYPE_CHECKIN = 10
BUY_TYPE_ENERGY = 11
BUY_TYPE_TALK = 12
BUY_TYPE_PVP_CNT = 13
BUY_TYPE_GOLD = 14
BUY_TYPE_VIP_GIFT = 15
BUY_TYPE_CREAT_ARMY = 20
BUY_TYPE_CONTR_ARMY = 21 --军团建设
BUY_TYPE_BLOCK_CNT = 22 
BUY_TYPE_EXPED_REVIVE = 23 --远征复活
BUY_TYPE_EXPED_SUPPLY = 24 --远征补给
------------------------------------------------

WANMENG_TMPID       = 5005501   --万能碎片模板Id
TIEKUAI_TMPID       = 3013001   --铁块模板Id
SWEEP_TMPID			= 3052001	--扫荡券模板Id
ITEM_ENERGY			= 5005502	--能源
STARSTONE_ID		= 3055003   --星石
RESET_TMPID			= 3055004   --重置券ID
-- MAX_VIP_LEVEL		= 15
fixMasklayerA			= 150
------------------------------------------------
--字体颜色
MYFONT_COLOR = cc.c3b(239, 227, 199)


--玩家的基本信息
srv_userInfo = {}

mUserId = 0
mUserName=nil --登陆账号
mPassWord=nil --登陆密码
-- mServerName = nil --服务器名字
-- mServerId = nil --服务区ID
loginServerList={} --hostIp,port(本次登录的服务器信息)
sceneSwitchCase=-1
curFightBlockId = nil --当前战斗的关卡
mapAreaId = nil --背景图的大区
lastTownId = nil --上一次出现的城镇ID
musicSwitch = true --音乐开关
soundSwitch = true --音效开关
chatType = 0 --聊天类型
srv_local_dts = nil --服务器时间与本地时间的差值
g_checkPointLayer = nil --关卡信息Layer
g_combLine = {}  --合成公式链
g_comBackTmpId = {}


--读取本地信息
itemData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataItem)
areaData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataArea)
blockData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataAreaBlock)
monsterData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMonster)
carData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataCar)
memberData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMember)
skillData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataSkill)
combinationData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataCombination)
advancedData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataAdvanced)
goodsData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataGoods)
transformData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataTransform)
profDevData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataProfDev)
barPlotData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataBarPlot)
fightPlotData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataFightPlot)
taskData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataTask)
strengthData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataStrength)
mailData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMail)
scenePlotData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataScenePlot)
regTalkData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataRegTalk)
mainPlotData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMainPlot)
buffData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataBuff)
shopRefData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataShopRef)
memberLevData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMemberLev)
energyBuyData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataEnergyBuy)
eBlockPurchaseData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataEBlockPurchase)
joinNpcData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataJoinNpc)
legionLevelData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataLegionLevel)
vipLevelData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataVipLevel)
randTipsData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataRandTips)
rentData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataRent)
achievementData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataAchievement)
rechargeData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataRecharge)
startFightMemberData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataStartFightMember)
expeditionData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataExpedition)
supplyData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataSupply)
PVPRewardData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataPVPReward)
LimitConsumeData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataLimitConsume)
businessActivityData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataBusinessActivity)
limitConsumeRewardData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataLimitConsumeReward)
suitData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataSuit)
cdKeyData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataCDKey)
laserCannonData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataLaserCannon)
worldBossRankRewardData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataWorldBossRankReward)
mainLineGuideData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMainLineGuide)
mainLineTalkData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataMainLineTalk)
foundData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataFound)
totalRechargeData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataTotalRecharge)
totalConsumeData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataTotalConsume)
pointRewardData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataPointReward)
newbieFundData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataNewbieFund)
BranchTaskData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataBranch)
zhixianTalkData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataZhixianTalk)
carLevelData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataCarLevel)


--商店数据拆分
shopData_type1 = {}
shopData_type2 = {}
shopData_type3 = {}
shopData_type4 = {}
shopData_type5 = {}
for i,value in ipairs(goodsData) do
	if value.type==1 then
		shopData_type1[value.gid] = value
	elseif value.type==2 then
		shopData_type2[value.gid] = value
	elseif value.type==3 then
		shopData_type3[value.gid] = value
	elseif value.type==4 then
		shopData_type4[value.gid] = value
    elseif value.type==5 then
        shopData_type5[value.gid] = value
	end
end


mainscenetopbar = nil --金钱条

g_isOnlineSeqSend = false
-- srv_blockData_byid      ={} --服务器返回的关卡信息(原始的)
srv_blockData           = {} --服务器返回的关卡信息(修改后的，通过关卡ID索引的)
srv_lastBlockData       = {} --上一次的关卡信息
srv_nextBlockData       = {} --下一次的关卡信息

srv_blockArmyData		= {} --团队副本关卡数据
srv_lastArmyData		= {}
srv_nextArmyData		= {}
local sendAreaList 		= nil

srv_carEquipment        ={} --服务器数据战车装备（通过ID索引）
srv_BackPackPushData    ={} --背包推送的数据
g_BPNewItems            ={} --背包新增物品

--srv_BackPack          ={} --非装备物品(背包通过ID)
srv_getAdvanced         = {} --获取进阶信息
curItemData             ={} --当前打开的物品信息
universalPieceData      ={} --万能碎片
m_comItemData           ={} --要合成的新Item
-- m_comPieceData          ={} --合成碎片Item
changeSelectItemData    = {} --战车装备中选择的装备

InitLegionList          = {} --符合条件的军团信息
mLegionData             = {} --自己军团的信息
armyId                  = nil--军团申请列表
legionFBData			= {} --军团副本
lgionFBResult			= nil --军团副本返回结果类型
LegionFB_RecordData     = {} --军团分配记录
findLegionData			= {} --查找军团数据
LegionDamageRankData	= {} --军团伤害排名
LegionSpoilsData		= {} --军团战利品信息

FriendListData          = {} --好友列表
FriendApplyData         = {} --好友请求列表
RecomFriendData         = {} --推荐好友列表
findFriendData			= {} --查找好友数据

chatRecordList          = {} --聊天记录
chatRecordList.World    = {} --世界聊天记录
chatRecordList.Legion   = {} --军团聊天记录
chatRecordList.Private  = {} --个人聊天记录
chatOffLineMsg	        = {} --离线聊天消息

shopGoodsInfo			= {} --普通商店商品信息
-- PVPShopGoodsInfo		= {} --竞技场商店
-- legionShopGoodsInfo		= {} --军团商店
g_shopType				= 1 --商店类型

blockSweepData			= {} --扫荡获取物品数据
main_carSklData         = {} --主界面获取战车技能数据

g_BroadCastMsg          = {} --广播消息
ActivitySrvInfo         = {} --活动接口返回信息
g_ActOnLineListTs       = nil --在线活动剩余时间(毫秒)
-- g_ActSendDts              = 60 --在线活动发送消息间隔
g_isFirstToMainScene    = true --是否第一次进入主界面（用于公告显示）

g_isSendBeat = false

--远征正常返回和点X返回
g_shouldBackToExpedition = false

g_startTime = nil

g_gameId_dataEye = 1 --1战车世纪，2机甲风云
g_IsSandbox = 0	-- 1 ios沙箱支付，0 正式环境

g_branchTriggerBlockId = {}  --所有触发支线任务的关卡ID
for k,value in pairs(taskData) do
	if value.type==15 and value.activeParams~=0 then
		g_branchTriggerBlockId[value.id] = value.activeParams
	end
end
g_TriggerBranchId = 0 --支线关卡触发的任务Id

g_isBanShu = false    --是否版署审核包

g_LanguageVer = 0    -- 0国内版，1繁体版，2英文版





