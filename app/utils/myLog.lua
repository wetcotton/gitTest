myLog = {}

local function luaLog(methodName,msg,title)
	msg = tostring(msg)
	if title then
		title = tostring(title)
	end
	if cc.Application:getInstance():getTargetPlatform()~=cc.PLATFORM_OS_ANDROID then
		title = title or ""
		print("--"..title.."-->",msg)
		return
	end
	title = title or "myLog"
	luaj.callStaticMethod("android/util/Log", methodName, {title,msg}, "(Ljava/lang/String;Ljava/lang/String;)I")
end

function myLog.v(msg,title)
	luaLog("v",msg,title)
end

function myLog.d(msg,title)
	luaLog("d",msg,title)
end

function myLog.i(msg,title)
	luaLog("i",msg,title)
end

function myLog.w(msg,title)
	luaLog("w",msg,title)
end

function myLog.e(msg,title)
	luaLog("e",msg,title)
end