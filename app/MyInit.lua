-- 初始化文件
-- Author: Jun Jiang
-- Date: 2014-12-24 11:35:59
--
require("app.utils.myLog")
require("app.utils.FuncEx")
require("app.utils.Utility")
require("app.utils.ShowModel")
require("app.widget.UIDrag")
require("app.widget.UIMasklayer")
require("app.widget.UIDialog")
require("app.widget.UIGainBox")
require("app.widget.UIGainBox_old")
require("app.widget.UISceneDlg")
require("app.logic.RoleManager")
require("app.logic.CarManager")
require("app.logic.EmbattleMgr")
require("app.logic.ShopMgr")
require("app.logic.BarMgr")
require("app.logic.RankMgr")
require("app.logic.TaskMgr")
require("app.logic.MailMgr")
require("app.logic.RentMgr")
require("app.logic.RentMgr")
require("app.logic.AchMgr")
require("app.scenes.Animations")
require("socket")

g_bounty = require("app.scenes.bounty.bounty")
g_SchedulerMgr = require("app.logic.SchedulerMgr")
g_WarriorsCenterMgr = require("app.logic.WarriorsCenterMgr")
g_VIPMgr = require("app.logic.VIPMgr")
g_mainSceneTopBar = require("app.scenes.MainSceneTopBar")
g_chatLayer = require("app.scenes.chatLayer.chatLayer")
require("app.scenes.legionScene.rentCarListLayer")
require("app.scenes.achievementTree")
require("app.scenes.expeditionLayer")
g_worldBoss = require("app.scenes.worldBoss")
require("app.scenes.EmbattleScene")
require("app.scenes.TaskLayer")
require("app.scenes.MailLayer")
require("app.scenes.rank.rankLayer")
g_BattleScene = require("app.scenes.BattleScene")
g_CGScene = require("app.scenes.CGScene")
g_worldMap = require("app.scenes.block.worldMap")
g_blockMap = require("app.scenes.block.blockMap")
g_RelicsLayer = require("app.scenes.RelicsLayer")
g_WarriorsCenterLayer = require("app.scenes.WarriorsCenterLayer")
g_RolePropertyLayer = require("app.scenes.RolePropertyLayer")
g_CarListLayer = require("app.scenes.CarListLayer")
g_DriveLayer = require("app.scenes.DriveLayer")
g_ImproveLayer = require("app.scenes.ImproveLayer")
g_MainScene =  require("app.scenes.MainScene")
g_ExpeditionScene = require("app.scenes.ExpeditionScene")
g_SignInLayer = require("app.scenes.SignInLayer")
g_oneWeekReward = require("app.scenes.businessActivity.oneWeekReward")
g_firstRecharge = require("app.scenes.businessActivity.firstRecharge")
g_firstWeekReward = require("app.scenes.businessActivity.firstWeekReward")
g_foundAct = require("app.scenes.businessActivity.foundAct")
g_newfund = require("app.scenes.businessActivity.fund.newfund")
g_fundLayer = require("app.scenes.businessActivity.fund.fundLayer")
g_activityLayer = require("app.scenes.activity.activityLayer")
g_loadUtil = require("app.utils.asyncLoadUtils")
g_lensMsg = require("app.scenes.carEquipments.lensMsgLayer")
g_laserCannon = require("app.scenes.LaserCannon")
require("app.sdk.UEgihtSdkLoginManager")

g_PVPScene = require("app.scenes.PVPScene")

--
g_LoadingScene = require("app.scenes.LoadingScene")


require("app.scenes.startFIghtBattleScene")
g_totolConsume = require("app.scenes.businessActivity.totalConsume")
g_flashSale = require("app.scenes.businessActivity.flashSale")
LimitConsume = require("app.scenes.shop.LimitConsume")
g_levelGift = require("app.scenes.businessActivity.levelGift")
g_totalRecharge = require("app.scenes.businessActivity.totalRecharge")
g_itemExchangeAct = require("app.scenes.businessActivity.itemExchangeAct")
g_discountLayer = require("app.scenes.discountLayer")
g_pointReward = require("app.scenes.businessActivity.pointReward")
g_branch = require("app.scenes.block.Branch")
g_carAdvance = require("app.scenes.carUI.carAdvance")
g_skillPreset = require("app.scenes.skillPreset")
require("app.sdk.dataeyeInit")
require("app.sdk.jpushSDK")
require("app.FightConfig")