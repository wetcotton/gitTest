--
-- Author: xiaopao
-- Date: 2014-09-23 22:23:24
--

--模型类型
ModelType ={
	Hero 	= 1,
	Tank 	= 2,
	Monster = 3,
}

--游戏服务器登陆类型
eGSLoginType = {
	eGslt_Official  = 1, 	    --官方账号登陆
	eGslt_QQ        = 2, 		--QQ登陆
	eGslt_Weixin    = 3, 		--微信登陆
	eGslt_360       = 4, 		--360
	eGslt_UC        = 5,        --九游UC
	eGslt_HUAWEI    = 6,        --华为
	eGslt_DANGLE    = 7,        --当乐
	eGslt_XIAOMI    = 8,        --小米
	eGslt_GIONEE    = 9,        --金立
	eGslt_BAIDU     = 10,       --百度
	eGslt_OPPO      = 11,       --oppo
	eGslt_LENOVO    = 12,       --联想
	eGslt_VIVO      = 13,       --vivo
	eGslt_COOLPAD   = 14,       --酷派
	eGslt_ZY        = 15,       --天奕达卓悠
	eGslt_WDJ       = 16,       --豌豆荚
	eGslt_ANZHI     = 17,       --安智
	eGslt_YYH       = 18,       --应用汇
	eGslt_KURUI     = 19,       --酷睿
	eGslt_MEIZU     = 20,       --魅族
	eGslt_QBAO     	= 21,       --钱宝
	eGslt_XY		= 22,	    --XY助手
	eGslt_KUAIYONG	= 23,       --快用
	eGslt_TONGBU	= 24,	    --同步推
	eGslt_PP 		= 25, 	    --PP推
	eGslt_LieBao	= 26,		--猎宝
	eGslt_LESHI		= 27,   	--乐视
}

--SDK类型
AllSdkType = {
    Sdk_SZN     = -1,
    Sdk_IOS     = 0,
	Sdk_360     = 1,
	Sdk_UC      = 2,
	Sdk_MSDK    = 3,
	Sdk_HUAWEI  = 4,
	Sdk_DANGLE  = 5,
	Sdk_XIAOMI  = 6,
	Sdk_GIONEE  = 7,
	Sdk_BAIDU   = 8,
	Sdk_OPPO    = 9,
	Sdk_LENOVO  = 10,       
	Sdk_VIVO    = 11,       
	Sdk_COOLPAD = 12,       
	Sdk_ZY      = 13,
	Sdk_WDJ     = 14,
	Sdk_ANZHI   = 15,       
	Sdk_YYH     = 16,
	Sdk_KURUI   = 17,
	Sdk_MEIZU   = 18,
	Sdk_QBAO   	= 19,
	Sdk_XY		= 20,	--XY助手
	Sdk_KUAIYONG= 21,     --快用
	Sdk_TONGBU	= 22,	--同步推
	Sdk_PP 		= 23, 	--PP推
	Sdk_IOS2	= 24,	--ios2
	Sdk_IOS3	= 25,	--ios3
	Sdk_OPPO2	= 26,
	Sdk_360_2   = 27,
	Sdk_HUAWEI2 = 28,
	Sdk_LieBao	= 29,
	Sdk_COOLPAD2= 30,
	Sdk_VIVO2   = 31,
	Sdk_LENOVO2 = 32,
	Sdk_BAIDU2  = 33,
	Sdk_LESHI	= 34, --乐视
	Sdk_IOS4	= 35,
	Sdk_IOS5	= 36,
}

--define gType_SDK begin
gType_SDK = AllSdkType.Sdk_360_2
--define gType_SDK end

if device.platform == "windows" then
	gType_SDK = AllSdkType.Sdk_SZN
end

--渠道类型
AllChnlType = {
    Chnl_SZN     = 999,
    Chnl_IOS     = 1000,
	Chnl_360     = 1001,
	Chnl_UC      = 1002,
	Chnl_MSDK    = 1003,
	Chnl_HUAWEI  = 1004,
	Chnl_DANGLE  = 1005,
	Chnl_XIAOMI  = 1006,
	Chnl_GIONEE  = 1007,
	Chnl_BAIDU   = 1008,
	Chnl_OPPO    = 1009,
    Chnl_LENOVO  = 1010,       
	Chnl_VIVO    = 1011,       
	Chnl_COOLPAD = 1012,       
	Chnl_ZY      = 1013,
	Chnl_WDJ     = 1014, 
	Chnl_ANZHI   = 1015, 
	Chnl_YYH     = 1016, 
	Chnl_KURUI   = 1017,
	Chnl_MEIZU   = 1018, 
	Chnl_QBAO    = 1019,
	Chnl_XY		 = 1050,	--XY助手
	Chnl_KUAIYONG= 1051,    --快用
	Chnl_TONGBU	 = 1052,	--同步推
	Chnl_PP 	 = 1053, 	--PP推
	Chnl_IOS2	 = 1060,	--ios2
	Chnl_IOS3	 = 1061,	--ios3
	Chnl_OPPO2	 = 1062,
	Chnl_360_2   = 1063,
	Chnl_HUAWEI2 = 1064,
	Chnl_LieBao	 = 1065,
	Chnl_COOLPAD2= 1066,
	Chnl_VIVO2	 = 1067,
	Chnl_LENOVO2 = 1068,
	Chnl_BAIDU2	 = 1069,
	Chnl_LESHI	 = 1070,
	Chnl_IOS4	 = 1071,	--ios4
	Chnl_IOS5	 = 1072,	--ios5
}

gType_Chnl = AllChnlType.Chnl_SZN
if gType_SDK==AllSdkType.Sdk_360 then gType_Chnl = AllChnlType.Chnl_360
elseif gType_SDK==AllSdkType.Sdk_360_2 then gType_Chnl = AllChnlType.Chnl_360_2
elseif gType_SDK==AllSdkType.Sdk_UC then gType_Chnl = AllChnlType.Chnl_UC
elseif gType_SDK==AllSdkType.Sdk_MSDK then gType_Chnl = AllChnlType.Chnl_MSDK
elseif gType_SDK==AllSdkType.Sdk_HUAWEI then gType_Chnl = AllChnlType.Chnl_HUAWEI
elseif gType_SDK==AllSdkType.Sdk_HUAWEI2 then gType_Chnl = AllChnlType.Chnl_HUAWEI2
elseif gType_SDK==AllSdkType.Sdk_DANGLE then gType_Chnl = AllChnlType.Chnl_DANGLE
elseif gType_SDK==AllSdkType.Sdk_XIAOMI then gType_Chnl = AllChnlType.Chnl_XIAOMI
elseif gType_SDK==AllSdkType.Sdk_GIONEE then gType_Chnl = AllChnlType.Chnl_GIONEE
elseif gType_SDK==AllSdkType.Sdk_BAIDU then gType_Chnl = AllChnlType.Chnl_BAIDU
elseif gType_SDK==AllSdkType.Sdk_BAIDU2 then gType_Chnl = AllChnlType.Chnl_BAIDU2
elseif gType_SDK==AllSdkType.Sdk_OPPO then gType_Chnl = AllChnlType.Chnl_OPPO
elseif gType_SDK==AllSdkType.Sdk_LENOVO then gType_Chnl = AllChnlType.Chnl_LENOVO
elseif gType_SDK==AllSdkType.Sdk_VIVO then gType_Chnl = AllChnlType.Chnl_VIVO
elseif gType_SDK==AllSdkType.Sdk_COOLPAD then gType_Chnl = AllChnlType.Chnl_COOLPAD
elseif gType_SDK==AllSdkType.Sdk_ZY then gType_Chnl = AllChnlType.Chnl_ZY
elseif gType_SDK==AllSdkType.Sdk_WDJ then gType_Chnl = AllChnlType.Chnl_WDJ
elseif gType_SDK==AllSdkType.Sdk_ANZHI then gType_Chnl = AllChnlType.Chnl_ANZHI
elseif gType_SDK==AllSdkType.Sdk_YYH then gType_Chnl = AllChnlType.Chnl_YYH
elseif gType_SDK==AllSdkType.Sdk_KURUI then gType_Chnl = AllChnlType.Chnl_KURUI
elseif gType_SDK==AllSdkType.Sdk_SZN then gType_Chnl = AllChnlType.Chnl_SZN
elseif gType_SDK==AllSdkType.Sdk_IOS then gType_Chnl = AllChnlType.Chnl_IOS
elseif gType_SDK==AllSdkType.Sdk_MEIZU then gType_Chnl = AllChnlType.Chnl_MEIZU
elseif gType_SDK==AllSdkType.Sdk_QBAO then gType_Chnl = AllChnlType.Chnl_QBAO
elseif gType_SDK==AllSdkType.Sdk_XY then gType_Chnl = AllChnlType.Chnl_XY
elseif gType_SDK==AllSdkType.Sdk_KUAIYONG then gType_Chnl = AllChnlType.Chnl_KUAIYONG
elseif gType_SDK==AllSdkType.Sdk_TONGBU then gType_Chnl = AllChnlType.Chnl_TONGBU
elseif gType_SDK==AllSdkType.Sdk_PP then gType_Chnl = AllChnlType.Chnl_PP
elseif gType_SDK==AllSdkType.Sdk_IOS2 then gType_Chnl = AllChnlType.Chnl_IOS2
elseif gType_SDK==AllSdkType.Sdk_IOS3 then gType_Chnl = AllChnlType.Chnl_IOS3
elseif gType_SDK==AllSdkType.Sdk_IOS4 then gType_Chnl = AllChnlType.Chnl_IOS4
elseif gType_SDK==AllSdkType.Sdk_IOS5 then gType_Chnl = AllChnlType.Chnl_IOS5
elseif gType_SDK==AllSdkType.Sdk_OPPO2 then gType_Chnl = AllChnlType.Chnl_OPPO2
elseif gType_SDK==AllSdkType.Sdk_LieBao then gType_Chnl = AllChnlType.Chnl_LieBao
elseif gType_SDK==AllSdkType.Sdk_COOLPAD2 then gType_Chnl = AllChnlType.Chnl_COOLPAD2
elseif gType_SDK==AllSdkType.Sdk_VIVO2 then gType_Chnl = AllChnlType.Chnl_VIVO2
elseif gType_SDK==AllSdkType.Sdk_LENOVO2 then gType_Chnl = AllChnlType.Chnl_LENOVO2
elseif gType_SDK==AllSdkType.Sdk_LESHI then gType_Chnl = AllChnlType.Chnl_LESHI

end


isUCLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_UC
isMSDKLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_MSDK
isGIONEELogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_GIONEE
isDownJoyLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_DANGLE
isHUAWEILogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_HUAWEI
	or gType_SDK == AllSdkType.Sdk_HUAWEI2)
isXIAOMILogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_XIAOMI
isBaiDuLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_BAIDU
	or gType_SDK == AllSdkType.Sdk_BAIDU2)
isOPPOLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_OPPO 
	or gType_SDK == AllSdkType.Sdk_OPPO2)
isLenovoLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_LENOVO
	or gType_SDK == AllSdkType.Sdk_LENOVO2)
isWdjLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_WDJ
isZYLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_ZY
isAnzhiLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_ANZHI
isYYHLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_YYH
isVIVOLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_VIVO
	or gType_SDK == AllSdkType.Sdk_VIVO2)
isCoolPadLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and (gType_SDK == AllSdkType.Sdk_COOLPAD
	or gType_SDK == AllSdkType.Sdk_COOLPAD2)
isKURUILogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_KURUI
isMEIZULogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_MEIZU
isQBaoLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_QBAO
isLieBaoLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_LieBao
isLeshiLogin = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_LESHI

isXYLogin = device.platform == "ios" and gType_SDK == AllSdkType.Sdk_XY
isKUAIYONGLogin = device.platform == "ios" and gType_SDK == AllSdkType.Sdk_KUAIYONG
isTONGBULogin = device.platform == "ios" and gType_SDK == AllSdkType.Sdk_TONGBU
isPPLogin = device.platform == "ios" and gType_SDK == AllSdkType.Sdk_PP



g_bNoticeEndGame    = 0 --停机公告是否退出游戏,1退出，0不退出

--获取服务器列表相关数据
g_MobileOS  = 0    --平台类型
g_Version   = ""    --版本号
g_AreaType  = 0   --1MSK  0其他
if gType_SDK == AllSdkType.Sdk_MSDK then
    g_AreaType = 1
end
g_Mac       = ""
g_Udid      = ""

if device.platform == "ios" then
   g_MobileOS = 1
   g_Udid = device.getOpenUDID()
elseif device.platform == "android" then
   g_MobileOS = 2
   g_Mac = device.getOpenUDID()
else
   g_MobileOS = 2
end

g_U8AppId =  "2"

