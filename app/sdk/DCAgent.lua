DCAgent = {}

--[[SDK初始化接口，该接口只在IOS平台起作用，android为空实现，不需要调用
	appId:游戏或应用在DataEye平台对应的ID号，请在DataEye官网申请 String类型
	channelId:游戏或应用将要发布的渠道，String类型
]]
function DCAgent.onStart(appId, channelId)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaAgent:onStart(appId, channelId)
end

--[[SDK调试模式开关，android平台会将log打印到logcat中，IOS会在调试时将log打印到xcode中
	mode：调试模式开关，boolean类型，true为开，false为关
]]
function DCAgent.setDebugMode(mode)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaAgent:setDebugMode(mode)
end

--[[设置SDK上报模式
	mode:其值为DC_DEFAULT、DC_AFTER_LOGIN二者之一，具体说明请参考文档
]]
function DCAgent.setReportMode(mode)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaAgent:setReportMode(mode)
end

--[[设置SDK上报频率]]
function DCAgent.setUploadInterval(interval)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaAgent:setUploadInterval(interval)
end

--[[设置应用版本号
	version:版本号，string类型
]]
function DCAgent.setVersion(version)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaAgent:setVersion(version)
end

--[[自定义错误上报
	title:错误标题，string类型
	content:错误内容，建议传入错误的堆栈信息, stirng类型
]]
function DCAgent.reportError(title, content)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaAgent:reportError(title, content)
end

--[[强制SDK立即上报数据]]
function DCAgent.uploadNow()
	if not IsDataEyeEnabled then
		return
	end
	DCLuaAgent:uploadNow()
end

--[[获取当前设备UID]]
function DCAgent.getUID()
	if not IsDataEyeEnabled then
		return
	end
	return DCLuaAgent:getUID()
end

function DCAgent:onKillProcessOrExit()
	
end

return DCAgent