DCTask = {}

--[[任务开始
	taskId:任务ID String类型
	taskType:任务类型 枚举类型，其值为下列值之一
	DC_GuideLine，1
	DC_MainLine,2
	DC_BranchLine,3
	DC_Daily,4
	DC_Activity,5
	DC_Other
]]
function DCTask.begin(taskId, taskType)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaTask:begin(taskId, taskType)
end

--[[任务完成
	taskId:任务ID String类型
]]
function DCTask.complete(taskId)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaTask:complete(taskId)
end

--[[任务失败
	taskId:任务ID String类型
	reason:任务失败原因
]]
function DCTask.fail(taskId, reason)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaTask:fail(taskId, reason)
end

return DCTask