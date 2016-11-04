lenovoSDK = {}

local isLenovoValid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and gType_SDK == AllSdkType.Sdk_LENOVO

function lenovoSDK:lenovoLogin()
	if  not isLenovoValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lenovo/lenovoSDK", "getTokenByQuickLogin", {}, "()V")
end

--登陆回调
--success,1为登录成功，2为失败
--msg描述信息
function lenovo_loginResult(retStr)--(success,msg)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("联想登陆成功----------------------------")
		print("msg: ",msg)
		local str = eGSLoginType.eGslt_LENOVO.."|"..msg.."|"..""
        print(str)
        luaLetUserLogin(str)
        startLoading()

	elseif success==2 then

	end
end

-- /**
-- 	 * 支付
-- 	 * _waresid，商品编码,接入时商户自建,int
-- 	 * _orderid，订单号,String
-- 	 * _price，价格，单位分,int
-- 	 * _cpprivateinfo，私有字符串，原封返回,String
-- 	 */
function lenovoSDK:pay(pramas)
	if  not isLenovoValid then
		return
	end
	local _waresid, _orderid,_price,_cpprivateinfo = unpack(pramas)
	print("_waresid",_waresid)
	print("_orderid",_orderid)
	print("_price",_price)
	print("_cpprivateinfo",_cpprivateinfo)
	luaj.callStaticMethod("org/cocos2dx/lenovo/lenovoSDK", "pay", pramas, "(ILjava/lang/String;ILjava/lang/String;)V")
end

-- //支付回调
-- 	//success,1为支付成功，2为失败，3为取消
-- 	//msg为描述信息
function lenovo_payResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("联想支付成功")
	elseif success==2 then

	elseif success==3 then
	end
end

function lenovoSDK:exitSDK()
	if  not isLenovoValid then
		return
	end
	luaj.callStaticMethod("org/cocos2dx/lenovo/lenovoSDK", "exitSDK", {}, "()V")
end

-- //退出回调
-- 	//success,1为退出成功
-- 	//msg为描述信息
function lenovo_exitResult(retStr)
	print("lua回调：",retStr)
	local arr = string.split(retStr,"|")
	local success = tonumber(arr[1])
	local msg = arr[2]
	if success==1 then
		print("退出联想SDK")
		if DCAgent then
            DCAgent.onKillProcessOrExit()
        end
		cc.Director:getInstance():endToLua()
	else
	end
end