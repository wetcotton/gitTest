DCCoin = {}

--[[虚拟币统计接口，设置虚拟币总量
	coinNum:虚拟币总量 long long类型
	coinType:虚拟币各类 String类型
]]
function DCCoin.setCoinNum(coinNum, coinType)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaCoin:setCoinNum(coinNum, coinType)
end

--[[虚拟币消耗接口
	id:消耗原因 String类型
	lost:消耗数量 long long类型
	left:剩余总量 long long类型
	coinType:虚拟币类型 String类型
]]
function DCCoin.lost(id, coinType, lost, left)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaCoin:lost(id, coinType, lost, left)
end

--[[虚拟币消耗接口
    id:消耗原因 String类型
    lost:消耗数量 long long类型
    left:剩余总量 long long类型
    coinType:虚拟币类型 String类型
    levelId:当前事件发生时所在的关卡ID
]]
function DCCoin.lostInLevel(id, coinType, lost, left, levelId)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaCoin:lostInLevel(id, coinType, lost, left, levelId)
end

--[[虚拟币获得接口
	id:获得原因 String类型
	gain:消耗数量 long long类型
	left:剩余总量 long long类型
	coinType:虚拟币类型 String类型
]]
function DCCoin.gain(id, coinType, gain, left)
	if not IsDataEyeEnabled then
		return
	end
	DCLuaCoin:gain(id, coinType, gain, left)
end

--[[虚拟币获得接口
    id:获得原因 String类型
    gain:消耗数量 long long类型
    left:剩余总量 long long类型
    coinType:虚拟币类型 String类型
    levelId:当前事件发生时所在的关卡ID
]]
function DCCoin.gainInLevel(id, coinType, gain, left, levelId)
	if not IsDataEyeEnabled then
		return
	end
    DCLuaCoin:gainInLevel(id, coinType, gain, left, levelId)
end

return DCCoin