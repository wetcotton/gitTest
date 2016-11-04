local scheduler = require("framework.scheduler")
local timeUpdateUtils = class("timeUpdateUtils",function ( ... )
	local node  = display.newNode()
	node:setNodeEventEnabled(true)
	return node
end)

local intervals = {
	600,60,10,2
}


--timeStr形式为“小时：分”，如12:30
--handler，时间到了的回调
--leeway是误差允许范围，单位为秒，有正负区分，如果为正，则推迟触发，否则提前触发
--bFunc,判断是否在时间到了之后继续调用回调的回调
--一般情况下，后两个参数不需要用
function timeUpdateUtils:ctor(timeStr,handler,leeway,bFunc)
	self.timeHandle = nil
	self.callback = handler
	leeway = leeway or 0
	self.bFunc = bFunc
	local arr = string.split(timeStr,":")
	local h,m = tonumber(arr[1]),tonumber(arr[2])
	if h<0 or h>24 or m<0 or m>60 then
		print("传入的时间参数有问题")
		return
	end

	local arr2 = string.split(os.date("%H:%M:%S"),":")
	local nowH,nowM,nowS = tonumber(arr2[1]),tonumber(arr2[2]),tonumber(arr2[3])
	print("--------------------------cccccccc")
	print(nowH,nowM,nowS)
	
	h = h-nowH
	print("h:"..h)
	if h<0 or (h==0 and m<nowM)then
		if self.bFunc~=nil then
			self.timeHandle2 = scheduler.scheduleGlobal(function () self:update2() end, 10)
		end
		return
	end

	m = (h*60 + m-nowM)*60 - nowS + leeway

	self.timeLast = m      --回调的时间，单位：秒
	print(m)
	self.intervalIndex = #intervals  --一开始，定时器为10分钟响应一次，然后一次是一分钟，10秒钟，2秒钟
	while self.intervalIndex>=2 and self.timeLast/intervals[self.intervalIndex-1]>1 do
		self.intervalIndex = self.intervalIndex-1
	end

print("开始")
print(self.intervalIndex)
print(intervals[self.intervalIndex])
	self.timeHandle = scheduler.scheduleGlobal(function ()self:update1()end,intervals[self.intervalIndex])
	
end

function timeUpdateUtils:update1()
	local function func()
		if self.intervalIndex>#intervals then  --时间到了
			scheduler.unscheduleGlobal(self.timeHandle)
			self.timeHandle = nil
			self.callback()
			print(os.date("%H:%M:%S"))
			if self.bFunc~=nil then
				self.timeHandle2 = scheduler.scheduleGlobal(function () self:update2() end, 10)
			end
			return true
		else --时间没到，但是定时器级别升高
			scheduler.unscheduleGlobal(self.timeHandle)
			self.timeHandle = nil
			self.timeHandle = scheduler.scheduleGlobal(function () self:update1() end, intervals[self.intervalIndex])
			print("4")
			print("self.intervalIndex: "..self.intervalIndex)
			return false
		end
	end

	if self.timeLast<=0 then --时间到了 --理论上应该不会出现这种情况，一般是由下面那个结束定时器
		scheduler.unscheduleGlobal(self.timeHandle)
		self.timeHandle = nil
		self.callback()
		print("2")
		if self.bFunc~=nil then
			self.timeHandle2 = scheduler.scheduleGlobal(function () self:update2() end, 10)
		end
	elseif self.timeLast>intervals[self.intervalIndex] then
		self.timeLast = self.timeLast - intervals[self.intervalIndex]
		print(os.date("%H:%M:%S").."self.timeLast: "..self.timeLast)
		while self.intervalIndex<=#intervals and self.timeLast<intervals[self.intervalIndex] do
			self.intervalIndex = self.intervalIndex + 1
			func()
		end
	else
		self.intervalIndex = self.intervalIndex + 1
		if func() then
			return
		end
		self:update1()
	end

end

function timeUpdateUtils:update2()
	if self.bFunc() then  
		if self.timeHandle2~=nil then
			scheduler.unscheduleGlobal(self.timeHandle2)
			self.timeHandle2 = nil
		end
		return
	end
	self.callback()
end

function timeUpdateUtils:onExit()
	if self.timeHandle ~= nil then
		scheduler.unscheduleGlobal(self.timeHandle)
		self.timeHandle = nil
	end
	if self.timeHandle2~=nil then
		scheduler.unscheduleGlobal(self.timeHandle2)
		self.timeHandle2 = nil
	end
end

return timeUpdateUtils