-- 全局定时器管理类
-- Author: Jun Jiang
-- Date: 2015-05-12 15:29:16
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local SchedulerMgr = class(SchedulerMgr)
SchedulerMgr.handle = {}

function SchedulerMgr:scheduleGlobal(name, listener, interval)
	if nil==name then
		printInfo("name can't be nil")
		return
	end
	if nil~=self.handle[name] then
		printInfo("schedule-%s has already exist", name)
		return
	end

	self.handle[name] = scheduler.scheduleGlobal(listener, interval)
end

function SchedulerMgr:unscheduleGlobal(name)
	if nil==name then
		return
	end

	local handle = self.handle[name]
	if nil==handle then
		printInfo("Can't find schedule-%s", name)
		return
	end

	scheduler.unscheduleGlobal(handle)
	self.handle[name] = nil
end

return SchedulerMgr