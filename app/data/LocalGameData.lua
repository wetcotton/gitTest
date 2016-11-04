--
-- Author: liufei
-- Date: 2014-10-31 17:50:10
--
require("app/data/base64")
require("app.utils.GlobalFunc")



local localData = nil

local LocalGameData = class("LocalGameData")

local LocalDataKey = "bird"



LocalDataType = {}
LocalDataType.kDataArea = 1
LocalDataType.kDataAreaBlock = 2
LocalDataType.kDataCar = 3
LocalDataType.kDataItem = 4
LocalDataType.kDataMember = 5
LocalDataType.kDataMonster = 6
LocalDataType.kDataSkill = 7
LocalDataType.kDataCombination = 8
LocalDataType.kDataAdvanced = 9
LocalDataType.kDataGoods = 10
LocalDataType.kDataTransform = 11
LocalDataType.kDataProfDev = 12
LocalDataType.kDataBarPlot = 13
LocalDataType.kDataFightPlot = 14
LocalDataType.kDataTask = 15
LocalDataType.kDataMail = 16
LocalDataType.kDataStrength = 17
LocalDataType.kDataScenePlot = 18
LocalDataType.kDataRegTalk  = 19
LocalDataType.kDataMainPlot  = 20 	--主线剧情
LocalDataType.kDataBuff  = 21
LocalDataType.kDataShopRef = 22
LocalDataType.kDataMemberLev = 23
LocalDataType.kDataEnergyBuy = 24
LocalDataType.kDataEBlockPurchase = 25
LocalDataType.kDataJoinNpc = 26
LocalDataType.kDataLegionLevel = 27
LocalDataType.kDataVipLevel = 28
LocalDataType.kDataRandTips = 29
LocalDataType.kDataRent = 30
LocalDataType.kDataAchievement = 31
LocalDataType.kDataRecharge = 32
LocalDataType.kDataStartFightMember = 33
LocalDataType.kDataExpedition = 34
LocalDataType.kDataSupply = 35
LocalDataType.kDataPVPReward = 36
LocalDataType.kDataLimitConsume = 37
LocalDataType.kDataBusinessActivity = 38
LocalDataType.kDataLimitConsumeReward = 39
LocalDataType.kDataSuit = 40
LocalDataType.kDataCDKey = 41
LocalDataType.kDataLaserCannon = 42
LocalDataType.kDataWorldBossRankReward = 43
LocalDataType.kDataMainLineGuide = 44
LocalDataType.kDataMainLineTalk = 45
LocalDataType.kDataFound = 46
LocalDataType.kDataTotalRecharge = 47
LocalDataType.kDataTotalConsume = 48
LocalDataType.kDataPointReward = 49
LocalDataType.kDataNewbieFund = 50   --新的等级基金
LocalDataType.kDataBranch	= 51	--支线任务
LocalDataType.kDataZhixianTalk = 52 --支线对话
LocalDataType.kDataCarLevel = 53 --战车进阶



local areaData = {}
local blockData = {}
local carData = {}
local itemData = {}
local memberData = {}
local monsterData = {}
local skillData = {}
local combinationData = {}
local advancedData = {}
local goodsData = {}
local transformData = {}
local profDevData = {}
local barPlotData = {}
local fightPlotData = {}
local taskData = {}
local mailData = {}
local strengthData = {}
local scenePlotData = {}
local regTalkData = {}
local mainPlotData = {}
local buffData = {}
local shopRefData = {}
local memberLevData = {}
local energyBuyData = {}
local eBlockPurchase = {}
local joinNpcData = {}
local legionLevelData = {}
local vipLevelData = {}
local randTipsData = {}
local rentData = {}
local achievementData = {}
local rechargeData = {}
local startFightMemberData = {}
local expeditionData = {}
local supplyData = {}
local PVPRewardData = {}
local LimitConsumeData = {}  --限时消费
local businessActivityData = {}
local limitConsumeRewardData = {}--限时促销礼包
local suitData = {}
local cdKeyData = {}
local laserCannonData = {}
local worldBossRankRewardData = {}
local mainLineGuideData = {}
local mainLineTalkData = {}
local foundData = {}
local totalRechargeData = {}
local totalConsumeData = {}
local pointRewardData = {}
local NewbieFundData = {}
local BranchTaskData = {}
local zhixianTalkData = {}
local carLevelData = {}


local  allFileName = {"config_area.json",
                      "config_block.json",
                      "config_car.json",
                      "config_item.json",
                      "config_member.json",
                      "config_monster.json",
                      "config_skill.json",
                      "config_combination.json",
                      "config_advanced.json",
                      "config_goods.json",
                      "config_transform.json",
                      "config_professionDevelop.json",
                      "talk_bar.json",
                      "talk_fight.json",
                      "config_task.json",
                      "config_mail.json",
                      "config_strengthen.json",
                      "talk_scene.json",
                      "talk_reg.json",
                      "talk_mainPlot.json",
                      "config_buff.json",
                      "config_shop.json",
                      "config_memberLevel.json",
                      "config_energyBuy.json",
                      "config_eBlockPurchase.json",
                      "config_join.json",
                      "config_legionLevel.json",
                      "config_vipLevel.json",
                      "config_Tips.json",
                      "config_rent.json",
                      "config_achievement.json",
                      "config_recharge.json",
                      "config_start.json",
                      "config_yuanzheng.json",
                      "config_depot.json",
                      "config_pvpReward.json",
                      "config_xianshixiaofei.json",
                      "config_yunying.json",
                      "config_libao.json",
                      "config_suit.json",
                      "config_jihuo.json",
                      "config_laserCannon.json",
                      "config_bossreward.json",
                      "config_mainguide.json",
                      "talk_guide.json",
                      "config_found.json",
                      "config_paydia.json",
                      "config_costdia.json",
                      "config_pointreward.json",
                      "config_newbie_fund.json",
                      "config_zhixian.json",
                      "talk_zhixian.json",
                      "config_car_level.json",
                     }



function LocalGameData:getInstance()
	if localData == nil or tolua.isnull(localData) then
		localData = LocalGameData.new()
	end
	return localData
end

function LocalGameData:loadLocalData()
	print("Load config")
	local fileUtil = cc.FileUtils:getInstance()
	local tmpData = nil
	for i=1,table.getn(allFileName) do
		local newPath = cc.FileUtils:getInstance():getWritablePath().."upd/res/configRead/"..allFileName[i]
		local jsonStr = ""
		if cc.FileUtils:getInstance():isFileExist(newPath) == true then
			print("config new:"..newPath)
			jsonStr = cc.HelperFunc:getFileData(newPath)
		else
			print("config old:"..fileUtil:fullPathForFilename("res/configRead/"..allFileName[i]))
	        jsonStr = cc.HelperFunc:getFileData(fileUtil:fullPathForFilename(getCurResPath().."/configRead/"..allFileName[i]))
		end
		if  string.len(jsonStr) > 0  then
			--local  str = crypto.decryptXXTEA(from_base64(jsonStr), LoacalDataKey)
			tmpData = json.decode(jsonStr)
			if     i == 1 then
				for key=1, #tmpData do
					areaData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 2 then
				for key=1, #tmpData do
					blockData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 3 then
				for key=1, #tmpData do
					carData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 4 then
				for key=1, #tmpData do
					itemData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 5 then
				for key=1, #tmpData do
					memberData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 6 then
				for key=1, #tmpData do
					monsterData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 7 then
				for key=1, #tmpData do
					skillData[tmpData[key].sklId] = tmpData[key]
				end
			elseif i == 8 then
				for key=1, #tmpData do
					combinationData[tmpData[key].compoundId] = tmpData[key]
				end
			elseif i == 9 then
				for key=1, #tmpData do
					advancedData[tmpData[key].fromItemId] = tmpData[key]
				end
			elseif i == 10 then
				for key=1, #tmpData do
					goodsData[key] = tmpData[key]
				end
			elseif i == 11 then
				for key=1, #tmpData do
					transformData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 12 then
				for key=1, #tmpData do
					profDevData[key] = tmpData[key]
				end
			elseif i == 13 then
				for key=1, #tmpData do
					barPlotData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 14 then
				for key=1, #tmpData do
					fightPlotData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 15 then
				for key=1, #tmpData do
					taskData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 16 then
				for key=1, #tmpData do
					mailData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 17 then
				strengthData = tmpData
			elseif i == 18 then
				for key=1, #tmpData do
					scenePlotData[tmpData[key].id] = tmpData[key]
				end
			elseif i==19 then
				for key=1, #tmpData do
					regTalkData[tmpData[key].id] = tmpData[key]
				end
			elseif i==20 then
				for key=1, #tmpData do
					mainPlotData[tmpData[key].id] = tmpData[key]
				end
			elseif i==21 then
				for key=1, #tmpData do
					buffData[tmpData[key].id] = tmpData[key]
				end
			elseif i==22 then
				for key=1, #tmpData do
					shopRefData[tmpData[key].recnt] = tmpData[key]
				end
			elseif i==23 then
				for key=1, #tmpData do
					memberLevData[tmpData[key].level] = tmpData[key]
				end
			elseif i==24 then
				for key=1, #tmpData do
					energyBuyData[tmpData[key].buycnt] = tmpData[key]
				end
			elseif i==25 then
				for key=1, #tmpData do
					eBlockPurchase[tmpData[key].buycnt] = tmpData[key]
				end
			elseif i==26 then
				for key=1, #tmpData do
					joinNpcData[tmpData[key].joinID] = tmpData[key]
				end
			elseif i==27 then
				for key=1,#tmpData do
					legionLevelData[tmpData[key].level] = tmpData[key] 
				end
			elseif i==28 then
				for key=1,#tmpData do
					vipLevelData[tmpData[key].vip] = tmpData[key]
				end
			elseif i==29 then
				for key = 1,#tmpData do
					table.insert(randTipsData,tmpData[key])
				end
			elseif i==30 then
				for key=1,#tmpData do
					rentData[tmpData[key].id] = tmpData[key]
				end 
			elseif i==31 then
				for key=1,#tmpData do
					achievementData[tmpData[key].id] = tmpData[key]
				end
			elseif i==32 then
				for key=1,#tmpData do
					rechargeData[tmpData[key].type] = tmpData[key]
				end
			elseif i==33 then
				for key=1,#tmpData do
					startFightMemberData[tmpData[key].ID] = tmpData[key]
				end
			elseif i==34 then
				for key=1,#tmpData do
					expeditionData[tmpData[key].id] = tmpData[key]
				end
			elseif i==35 then
				for key=1,#tmpData do
					supplyData[tmpData[key].id] = tmpData[key]
				end
			elseif i==36 then
				for key=1,#tmpData do
					PVPRewardData[tmpData[key].sorder] = tmpData[key]
				end
			elseif i == 37 then
                for key=1,#tmpData do
					LimitConsumeData[tmpData[key].id] = tmpData[key]
				end 
			elseif i == 38 then
                for key=1,#tmpData do
					businessActivityData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 39 then
                for key=1,#tmpData do
					limitConsumeRewardData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 40 then
                for key=1,#tmpData do
					suitData[tmpData[key].suitID] = tmpData[key]
				end
			elseif i == 41 then
                for key=1,#tmpData do
					cdKeyData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 42 then
                for key=1,#tmpData do
					laserCannonData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 43 then
                for key=1,#tmpData do
					worldBossRankRewardData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 44 then
                for key=1,#tmpData do
					mainLineGuideData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 45 then
                for key=1,#tmpData do
					mainLineTalkData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 46 then
                for key=1,#tmpData do
					foundData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 47 then
                for key=1,#tmpData do
					totalRechargeData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 48 then
                for key=1,#tmpData do
					totalConsumeData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 49 then
                for key=1,#tmpData do
					pointRewardData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 50 then
                for key=1,#tmpData do
					NewbieFundData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 51 then
                for key=1,#tmpData do
					BranchTaskData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 52 then
                for key=1,#tmpData do
					zhixianTalkData[tmpData[key].id] = tmpData[key]
				end
			elseif i == 53 then
                for key=1,#tmpData do
					carLevelData[tmpData[key].id] = tmpData[key]
				end
			end
		end
	end
end

function LocalGameData:getLocalData(dataType)
	if     dataType == LocalDataType.kDataArea then
		return areaData
	elseif dataType == LocalDataType.kDataAreaBlock then
		return blockData
    elseif dataType == LocalDataType.kDataCar then
		return carData
	elseif dataType == LocalDataType.kDataItem then
		return itemData
	elseif dataType == LocalDataType.kDataMember then
		return memberData
	elseif dataType == LocalDataType.kDataMonster then
		return monsterData
	elseif dataType == LocalDataType.kDataSkill then
		return skillData
	elseif dataType == LocalDataType.kDataCombination then
		return combinationData
	elseif dataType == LocalDataType.kDataAdvanced then
		return advancedData
	elseif dataType == LocalDataType.kDataGoods then
		return goodsData
	elseif dataType == LocalDataType.kDataTransform then
		return transformData
	elseif dataType == LocalDataType.kDataProfDev then
		return profDevData
	elseif dataType == LocalDataType.kDataBarPlot then
		return barPlotData
	elseif dataType == LocalDataType.kDataFightPlot then
		return fightPlotData
	elseif dataType == LocalDataType.kDataTask then
		return taskData
	elseif dataType == LocalDataType.kDataMail then
		return mailData
	elseif dataType == LocalDataType.kDataStrength then
		return strengthData
	elseif dataType == LocalDataType.kDataScenePlot then
		return scenePlotData
	elseif dataType == LocalDataType.kDataRegTalk then
		return regTalkData
	elseif dataType == LocalDataType.kDataMainPlot then
		return mainPlotData
	elseif dataType == LocalDataType.kDataBuff then
		return buffData
	elseif dataType == LocalDataType.kDataShopRef then
		return shopRefData
	elseif dataType == LocalDataType.kDataMemberLev then
		return memberLevData
	elseif dataType == LocalDataType.kDataEnergyBuy then
		return energyBuyData
	elseif dataType == LocalDataType.kDataEBlockPurchase then
		return eBlockPurchase
	elseif dataType == LocalDataType.kDataJoinNpc then
		return joinNpcData
	elseif dataType == LocalDataType.kDataLegionLevel then
		return legionLevelData
	elseif dataType == LocalDataType.kDataVipLevel then
		return vipLevelData
	elseif dataType == LocalDataType.kDataRandTips then
		return randTipsData
	elseif dataType == LocalDataType.kDataRent then
		return rentData 
	elseif dataType == LocalDataType.kDataAchievement then
		return achievementData
	elseif dataType == LocalDataType.kDataRecharge then
		return rechargeData
	elseif dataType == LocalDataType.kDataStartFightMember then
		return startFightMemberData
	elseif dataType == LocalDataType.kDataExpedition then
		return expeditionData
	elseif dataType == LocalDataType.kDataSupply then
		return supplyData
	elseif dataType == LocalDataType.kDataPVPReward then
		return PVPRewardData
	elseif dataType == LocalDataType.kDataLimitConsume then
		return LimitConsumeData
	elseif dataType == LocalDataType.kDataBusinessActivity then
		return businessActivityData
	elseif dataType == LocalDataType.kDataLimitConsumeReward then
		return limitConsumeRewardData
	elseif dataType == LocalDataType.kDataSuit then
		return suitData
	elseif dataType == LocalDataType.kDataCDKey then
		return cdKeyData
	elseif dataType == LocalDataType.kDataLaserCannon then
		return laserCannonData
	elseif dataType == LocalDataType.kDataWorldBossRankReward then
		return worldBossRankRewardData
	elseif dataType == LocalDataType.kDataMainLineGuide then
		return mainLineGuideData
	elseif dataType == LocalDataType.kDataMainLineTalk then
		return mainLineTalkData
	elseif dataType == LocalDataType.kDataFound then
		return foundData
	elseif dataType == LocalDataType.kDataTotalRecharge then
		return totalRechargeData
	elseif dataType == LocalDataType.kDataTotalConsume then
		return totalConsumeData
	elseif dataType == LocalDataType.kDataPointReward then
		return pointRewardData
	elseif dataType == LocalDataType.kDataNewbieFund then
		return NewbieFundData
	elseif dataType == LocalDataType.kDataBranch then
		return BranchTaskData
	elseif dataType == LocalDataType.kDataZhixianTalk then
		return zhixianTalkData
	elseif dataType == LocalDataType.kDataCarLevel then
		return carLevelData
	end
end

function LocalGameData:encryptAllJson()
	for i=1,table.getn(allFileName) do
		local pathString = device.writablePath.."config/"..allFileName[i]
		if io.exists(pathString) then
			local  str = crypto.encryptXXTEA(io.readfile(pathString), LoacalDataKey)
			io.writefile(pathString, to_base64(str),"w+b")
		end
	end
end

return LocalGameData
