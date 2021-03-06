--
-- Author: xiaopao
-- Date: 2014-09-29 11:12:33
--
CMD_GET_ENERGY			= 602 	--获取最新燃油
CMD_LOGIN_INFO          = 605   --登录后整合的接口

CMD_HEARTBEAT           = 99 --心跳检测

CMD_ROLE_LOGIN 			= 10000
CMD_ROLE_CREATE 		= 10001

CMD_EMBATTLE_GETINFO	= 11001 --获取布阵信息
CMD_EMBATTLE_UNLOCKSLOT	= 11003 --解锁弹仓
CMD_OPEN_LASER          = 11004 --开启第四个激光炮槽位

CMD_BACKPACK 			= 12001 --背包
CMD_GETNICKNAME			= 10002 --获取随机昵称
CMD_BACKPACK_PUSH       = 12003 --背包消息推送

CMD_COMBINATION 		= 12101 --合成
CMD_GETADVANCED 		= 12102 --获取进阶信息
CMD_ADVANCED 			= 12103 --进阶
CMD_STRENGTHEN 			= 12104 --强化
CMD_DECOMPOSE 			= 12105 --分解
CMD_USEITEM				= 12106 --物品的使用
CMD_CHANGE_EQUIPMENT    = 12107 --人物换装
CMD_LASERSTRENGTH       = 12108 --激光炮强化
CMD_CHANGE 				= 12201 --更换装备
CMD_LOCK 				= 12301 --加锁，解锁

CMD_ENTER_BLOCK 		= 14001 --进入关卡
CMD_CHANGE_AREA 		= 14002 --换区
CMD_FIGHT_PREPARE 		= 14003	--战斗准备
CMD_FIGHT_REPORT    	= 14004 --战斗结果上报
CMD_SWEEP				= 14005 --扫荡
CMD_EBLOCK_PURCHASE		= 14006 --精英关卡购买
CMD_BAR_GETBOUNTY 		= 14021 --领取酒吧赏金首奖励
CMD_BAR_BARINFO			= 14022 --酒吧信息
CMD_BAR_RECORDSTORY		= 14023 --记录酒吧剧情进度
CMD_CHOOSE_GOODBAD      = 14024 --善恶选择
CMD_START_EXPEDITION	= 14080 --开始远征，请求布阵  expedition是远征的意思
CMD_UPDATE_FORMATION	= 14081 --远征，上传第一次布阵阵型，获取第二次阵型初始阵型
CMD_UPDATE_EXPEDITION   = 14082 --保存战斗结果
CMD_EXPEDITION_REVIVE   = 14083 --复活
CMD_EXPEDITION_BUYSUPPLY= 14084 --购买补给品
CMD_EXPEDITION_GETSUPPLY= 14085 --获取补给品


CMD_ROLE_PROPERTY 		= 15001	--人物属性
CMD_CAR_PROPERTY		= 15002	--战车属性
CMD_CAR_UPDATEMEMBER 	= 15003 --更新战车成员
CMD_CARIMPROVE_INITIAL	= 15004 --战车改造初始信息
CMD_CARIMPROVE_UNLOCK 	= 15005 --战车开孔
CMD_CARIMPROVE_UPGRADE 	= 15006 --战车升级
CMD_PROFESSION_DEVELOP	= 15014 --职业养成
CMD_DRIVE_INFO			= 15010 --驾驶信息
CMD_ROLE_UPSKILL 		= 15011 --人物技能提升
CMD_CAR_ACTIVESKILL 	= 15012 --战车技能激活
CMD_CARSKL_INFO         = 15013 --单独获取战车技能信息
CMD_CAR_METERAIL_LOCK   = 15015 --锁定战车改造材料
CMD_CAR_METERAIL_UNLOCK = 15016 --解锁战车改造材料
CMD_CAR_ADVANCE         = 15017 --战车进阶升星
CMD_CAR_RESET           = 15018 --战车重置
CMD_CAR_METERIAL_STREN  = 15019 --改装材料强化
CMD_CHANGENAME          = 15021 --改名
CMD_SAVESKLPRESET       = 15024 --保存技能预设

CMD_GETPVPINFO          = 17001 --获取PVP的基本信息
CMD_PVP_FIGHT           = 17002 --开始PVP战斗
CMD_CHANGE_ENERMY       = 17003 --换一组PVP对手
CMD_BUYPVP_TIME         = 17004 --购买PVP战斗次数
CMD_GET_PLAYBACK        = 17005 --获取战斗回放的信息
CMD_GET_BUYRECORD       = 17007 --获取商品购买记录
CMD_BUYPVP_ITEM         = 17008 --购买PVP商品
CMD_UPDATE_PVPRESULT    = 17009 --上传PVP战斗结果
CMD_PVP_MATRIXINFO		= 17010 --PVP阵型
CMD_PVP_REFRESHTIME     = 17011 --刷新PVP挑战剩余时间
CMD_PVP_GETFIGHTRECORD  = 17012 --获取对战记录
CMD_PVP_GETENERMYINFO   = 17013 --获取对手的阵型信息
CMD_PVP_SETDEFMATRIX	= 11005 --设置防守阵型

CMD_LEGION_ENTER        = 18001 --进入公会（军团）
CMD_LEGION_COST         = 18002 --军团花销
CMD_CREATE_LEGION       = 18003 --创建军团
CMD_APPLY_LEGION        = 18004 --申请加入军团
CMD_DEAL_APPLY          = 18005 --处理申请军团
CMD_KICK_MEMBER         = 18006 --踢成员（军团）
CMD_EXIT_LEGION         = 18007 --成员主动退出军团
CMD_DISSOLVE_LEGION     = 18008 --解散军团
CMD_APPOINT_POS         = 18009 --任命职务
CMD_SETTING_LEGION      = 18010 --设置军团
CMD_PROMOTE_LEGION      = 18011 --军团提升
CMD_CONSTR_LEGION       = 18012 --建设军团
CMD_FIND_LEGION			= 18013 --查找军团
CMD_MYLEGION_INFO		= 18014 --军团主界面信息
CMD_START_FB            = 18020 --开启军团副本（重置副本）
CMD_UNLOCK_LEGION       = 18021 --结算军团副本
CMD_LEGION_BLOCK		= 18022 --军团关卡信息
MMD_SPOILS_QUEUE        = 18023 --战利品排队信息
MMD_SPOILS_LIST         = 18024 --战利品申请
CMD_LEGION_FB       	= 18025 --军团副本
CMD_LEGION_DAMAGE_RANK	= 18026	--伤害排名
CMD_LEGION_RECORD       = 18027 --军团分配记录
CMD_SPOILS_CANCEL		= 18028	--取消战利品的申请
CMD_LEGION_TAXIPUSH  	= 18040 --军团其他成员所有出租车推送接口：
CMD_TAXI_RECORDPUSH  	= 18041 --战车租用记录
CMD_LEGION_ALLTAXI  	= 18042 --请求我所有的车
CMD_LEGION_BOOKIN   	= 18043 --登记自己的车
CMD_LEGION_UNBOOKIN   	= 18044 --收回登记的车
CMD_LEGION_TAXI_ONOFF   = 18060 --军团有人登记租车，或取消登记，实时推送
CMD__MYTAXI_ISRENTED    = 18061 --军团有人租了我的车，实时推送
CMD_LEGION_TIREN        = 18062 --军团被踢，推送消息
CMD_LEGION_MEMBER_INFO  = 18015 --获取军团成员信息（用于世界boss求助军团成员）
CMD_LEGION_PVE_CHECK	= 18029 --获取当前是否能打军团副本（有其他人在打，就不能打）

CMD_GETSHOPINFO         = 19001 --获取商品信息
CMD_PURCHASE            = 19002 --购买商品
CMD_LOTTERY_CARD        = 19003 --钻石抽卡
CMD_GETLOTCARD_TIME     = 19004 --抽卡剩余时间
CMD_SHOP_GETARMYINFO    = 19005 --获取军团商店信息
CMD_SHOP_GETPVPINFO     = 19006 --获取竞技场商店信息
CMD_GETLIMITCOMSUME     = 19007 --获取限时消费活动信息

CMD_GETRECHAGE_INFO     = 19010 --获取充值记录
CMD_RECHARGE            = 19011 --充值接口
-- CMD_STORE_RECORDS       = 19010 --获取内购商店的购买记录
-- CMD_STORE_VERIFY        = 19011 --验证订单请求
CMD_MONTHCARD_REWARD    = 19012 --领取月卡奖励
CMD_BUY_ENERGY          = 19013 --购买燃油
CMD_BUY_GOLD            = 19014 --购买金币
CMD_VIP_GIFT            = 19015 --vip礼包
CMD_LOTTERY_CARD_GOLD   = 19016 --金币抽卡
CMD_ACTIVITY_CUXIAO_NUM = 19017 --限时促销活动，活动期间消费数量
CMD_ACTIVITY_CUXIAO_GETREWARD  = 19018   --限时促销活动，领奖
CMD_ACTIVITY_CUXIAO_CHECKBUY  = 19019   --获取是否已经买过  --360测试版
CMD_ACTIVITY_CUXIAO_BUY = 19020 --限时促销活动，购买  --360测试版
CMD_GUYFUND             = 19022 --购买基金
CMD_TOTALRECHARGE_INIT = 19023  	--累计充值初始化
CMD_TOTALRECHARGE_REWARD = 19024  	--累计充值领奖
CMD_FU_GETINFO          = 19026 --祈福迎新进入获取信息接口
CMD_FU_EXCHANGE         = 19027 --祈福迎新活动兑换

CMD_TOTALCONSUME_INIT   = 19025 --累计消费初始化
CMD_TOTALCONSUME_REWARD = 19028 --累计消费领奖
CMD_POINTREWARD         = 19029 --积分奖励
CMD_POINTREWARDGET      = 19030 --积分兑换
CMD_NEWFUND             = 19031 --新手基金


CMD_ADD_FRIEND          = 20001 --加好友
CMD_DEAL_FRIEND         = 20002 --处理好友申请
CMD_DEL_FRIEND          = 20003 --删除好友
CMD_RECOM_FRIEND        = 20004 --推荐好友
CMD_FIND_FRIEND         = 20005 --查找好友
CMD_FRIEND_LIST         = 20006 --好友列表
CMD_FRIEND_CARINFO      = 20007 --获取好友战车信息
CMD_FRIEND_APPLY		= 20008 --好友申请列表

CMD_TASK_INIT 			= 21001 --任务初始化
CMD_TASK_UPDATE			= 21002 --任务更新
CMD_TASK_SIGNIN			= 21003 --签到
CMD_TASK_RESIGNIN		= 21004 --补签
CMD_TASK_SUBMIT 		= 21005 --提交任务
CMD_ACHIEVEMENT_PUSH	= 21006 --成就任务完成状态推送

CMD_MAIL_INIT 			= 22001 --邮件初始化
CMD_MAIL_UPDATE 		= 22002 --邮件更新（用于新邮件）
CMD_MAIL_DES 			= 22003 --邮件详细信息
CMD_MAIL_GETATTACHMENT 	= 22004 --附件获取
CMD_REFRESH_TASK        = 22005 --首周送钻石获得，更新任务接口

CMD_TASK_RE_INIT        = 22006 --重新获取所有任务(刚好过24点的时候)
CMD_MAIL_RE_INIT        = 22007 --重新获取所有邮件(刚好过24点的时候)

CMD_CHAT_FREE_TIMES     = 23000 --免费聊天次数（世界）
CMD_SENT_CHATMSG        = 23001 --发送聊天消息
CMD_SENT_OFFLINE_MSG    = 23002 --离线消息
CMD_PUSH_PRIVATE_CHAT   = 30001 --推送私人聊天消息
CMD_PUSH_LEGION_CHAT    = 30002 --推送军团消息
CMD_PUSH_WORLD_CHAT     = 30003 --推送世界消息
CMD_PUSH_VIDEO_CHAT     = 30004 --推送分享视频

CMD_RELICS_INIT 		= 24101 --遗迹初始信息
CMD_RELICS_DETECT		= 24102 --遗迹探测
CMD_RELICS_RESET        = 24103 --遗迹挑战次数重置
 
CMD_RANK_GETRANK		= 25001 --请求排行信息



CMD_BROADCAST           = 30005 --广播推送

CMD_UPGRADE_LEVEL		= 50010	--觉得等级提升推送

CMD_LOGIN_OTHERPLACE	= 88001 --其它地方登陆

CMD_UPDATE_GUIDESTEP    = 603   --上报新手教程进度

CMD_BUSINESS_OPEN       = 30000 --运营活动开启情况
CMD_ACTIVITY            = 31001 --活动

CMD_CDKEY = 30011           --礼包兑换码


CMD_BOSS_INIT = 24002  --世界BOSS,界面初始化
CMD_BOSS_CHANGE_CAR = 24003  --世界BOSS,更换登记战车
CMD_BOSS_CHANGE_CAR_PUSH = 50102 --世界BOSS,换车推送
CMD_BOSS_RAND_MATCH = 24004  --世界BOSS,随机匹配
CMD_BOSS_MATCH_REQUEST = 24005  --世界BOSS,发送组队请求
CMD_BOSS_MATCH_RCEVIVE = 50101  --世界BOSS,收到组队请求

CMD_BOSS_AGREE_ASK = 24006  --世界BOSS,接受组队请求
CMD_BOSS_SOMEBODY_AGREE = 50100  --世界BOSS,有人接受了我的组队请求
CMD_BOSS_CHAT_PUSH = 30006  --世界BOSS,聊天推送消息
CMD_BOSS_EXIT_TEAM = 24007  --世界BOSS,请求退出组队
CMD_BOSS_EXIT_PUSH = 50103  --世界BOSS,有人退出组队，推送
CMD_BOSS_EMBATLE_INFO = 24008 --世界BOSS,军团匹配，布阵信息
CMD_BOSS_RANK_INFO = 24010 --世界BOSS,排名信息
CMD_BOSS_BATTLEOVER = 24009 --世界BOSS，结算
CMD_BOSS_HPUPDATE   = 50105 --世界BOSS，BOSS生命推送
CMD_BOSS_RANK_INFO = 24010 --世界BOSS,排名信息
CMD_BOSS_HELPEND_PUSH = 50104 --世界BOSS,队长进入布阵界面,队员可以自由活动了
CMD_BOOSS_REFRESH_MYTEAM = 24011 --由于推送有可能出现问题，在这里主动请求。

CMD_RECHARGE_RET        = 99100 --充值成功返回接口

CMD_MSDK_RECHARGE_SEARCH     = 99002 --MSDK充值后查询服务器接口

CMD_GETSERVER_TIME     = 24001  --获取服务器时间
CMD_SKIP_GUIDE     = 606  --跳过新手引导