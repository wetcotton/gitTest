DCLevels = {}

--[[进入头卡或者开始关卡
	levelId:关卡名称或者ID String类型
]]
function DCLevels.begin(levelId)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaLevels:begin(levelId)
end

--[[成功完成关卡
	levelId:关卡名称或者ID String类型
]]
function DCLevels.complete(levelId)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaLevels:complete(levelId)
end

--[[关卡失败
	levelId:关卡名称或者ID String类型
]]
function DCLevels.fail(levelId, failPoint)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaLevels:fail(levelId, failPoint)
end

return DCLevels