jpushSDK = {}

jpushTags = {
	           Tag_1200 = 1, --12点体力推送
	           Tag_1800 = 1, --18点体力推送
	           Tag_1230 = 1, --12点30世界BOSS推送
	           Tag_2000 = 1, --20点世界BOSS推送
            }
function jpushSDK:addTag(tagStr)
	jpushTags[tagStr] = 1
end

function jpushSDK:removeTag(tagStr)
	jpushTags[tagStr] = 0
end


local isAndroid = cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and getVersionCode()>=3
local isIOS = cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD

local classPath = "org/cocos2dx/jpush/jpushSDK"

function jpushSDK:stopPush()
	if isAndroid then
		luaj.callStaticMethod(classPath, "stopPush", {}, "()V")
	end
end

function jpushSDK:resumePush()
	if isAndroid then
		luaj.callStaticMethod(classPath, "resumePush", {}, "()V")
	end
end

-- /*
-- 	 * tag以","分割
-- 	 */
function jpushSDK:setTag()
	if isAndroid then
		local tagStr = ""
		for k,v in pairs(jpushTags) do
			if v==1 then
				tagStr = tagStr..k..","
			end
		end
		tagStr = string.sub(tagStr,1,string.len(tagStr)-1)
		luaj.callStaticMethod(classPath, "setTag", {tagStr}, "(Ljava/lang/String;)V")
	end
	if isIOS then
		print("重置推送TAG：")
	    printTable(jpushTags)
        luaoc.callStaticMethod("JPushBridge", "setJPushTags", jpushTags)
	end
end


function jpushcallback_setTagResult(retStr)--(success,msg)
	if isAndroid then
		print("lua回调：",retStr)
		local arr = string.split(retStr,"#")
		local success = tonumber(arr[1])
		local msg = arr[2]
		if success==2 then	--设置失败，并且有网，10秒后再试一次
			display.getRunningScene():performWithDelay(function ( ... )
				jpush:setTag(msg)
			end,10)
		end
	end
end

function jpushSDK:setAlias(aliasStr)
	aliasStr = tostring(aliasStr)
	if isAndroid then
		luaj.callStaticMethod(classPath, "setAlias", {aliasStr}, "(Ljava/lang/String;)V")
	end
end

function jpushcallback_setAliasResult(retStr)--(success,msg)
	if isAndroid then
		print("lua回调：",retStr)
		local arr = string.split(retStr,"#")
		local success = tonumber(arr[1])
		local msg = arr[2]
		if success==2 then	--设置失败，并且有网，10秒后再试一次
			display.getRunningScene():performWithDelay(function ( ... )
				jpushSDK:setAlias(msg)
			end,10)
		end
	end
end

-- /*设置允许推送的时间
-- 	 * days以","分割
-- 	 * startHour开始接受时间
-- 	 * endHour结束接收时间
-- 	 */
function jpushSDK:setPushTime(daysStr,startHour,endHour)
	if isAndroid then
		luaj.callStaticMethod(classPath, "setPushTime", {daysStr,startHour,endHour}, "(Ljava/lang/String;II)V")
	end
end

-- /*设置免打扰时间
-- 	 *  int startHour 静音时段的开始时间 - 小时 （24小时制，范围：0~23 ）
-- 	 *	int startMinute 静音时段的开始时间 - 分钟（范围：0~59 ）
-- 	 *	int endHour 静音时段的结束时间 - 小时 （24小时制，范围：0~23 ）
-- 	 * 	int endMinute 静音时段的结束时间 - 分钟（范围：0~59 ）
-- 	 */
function jpushSDK:setSilenceTime(startHour, startMinute,endHour, endMinute)
	if isAndroid then
		luaj.callStaticMethod(classPath, "setSilenceTime", {startHour, startMinute,endHour, endMinute}, "(IIII)V")
	end
end

function jpushSDK:getRegistrationID()
	if isAndroid then
		local ok,ret = luaj.callStaticMethod(classPath, "getRegistrationID", {startHour, startMinute,endHour, endMinute}, "()Ljava/lang/String;")
		if ok then
			return ret
		end
	end
end