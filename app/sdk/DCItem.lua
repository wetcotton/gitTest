DCItem = {}

--[[道具购买
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	virtualCurrency:购买道具花费的虚拟币数量 long long类型
	currencyType:虚拟币类型 String类型
	consumePoint:消费点
]]
function DCItem.buy(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint)
    if not IsDataEyeEnabled then
        return
    end
    DCLuaItem:buy(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint)
	--DCLuaItem:buyInLevel(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint,srv_userInfo.maxBlockId)
end

--[[道具购买
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    virtualCurrency:购买道具花费的虚拟币数量 long long类型
    currencyType:虚拟币类型 String类型
    consumePoint:消费点
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.buyInLevel(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint, levelId)
    if not IsDataEyeEnabled then
        return
    end
    DCLuaItem:buyInLevel(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint, levelId)
end

--[[获得道具
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	reason:获得道具的原因
]]
function DCItem.get(itemId, itemType, itemCount, reason)
    if not IsDataEyeEnabled then
        return
    end
	DCLuaItem:get(itemId, itemType, itemCount, reason)
end

--[[获得道具
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    reason:获得道具的原因
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.getInLevel(itemId, itemType, itemCount, reason, levelId)
    if not IsDataEyeEnabled then
        return
    end
    DCLuaItem:getInLevel(itemId, itemType, itemCount, reason, levelId)
end

--[[消耗道具
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	reason:消耗道具的原因
]]
function DCItem.consume(itemId, itemType, itemCount, reason)
    if not IsDataEyeEnabled then
        return
    end
	DCLuaItem:consume(itemId, itemType, itemCount, reason)
end

--[[消耗道具
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    reason:消耗道具的原因
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.consumeInLevel(itemId, itemType, itemCount, reason, levelId)
    if not IsDataEyeEnabled then
        return
    end
    DCLuaItem:consumeInLevel(itemId, itemType, itemCount, reason, levelId)
end

return DCItem