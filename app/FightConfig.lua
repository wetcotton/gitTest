-- @Author: anchen
-- @Date:   2016-01-28 15:34:45

--战斗测试配置       
--------------------------------------------------------------------------------------------------
local g_isCarFight = true         --是否车战   true车战  false人战
local g_tptID      = 1014         --测试人物或战车的模板ID

local g_monsters   = {              --测试的怪物
                        [1] = {     --1号位置
                                id = 22014018,   --怪物ID
                                level = 300,      --怪物等级
                              },
                        -- [1] = {     --1号位置
                        --         id = 31011005,   --怪物ID
                        --         level = 300,      --怪物等级
                        --       },                        
                        -- [2] = {     --2号位置
                        --         id = 12001002,   --怪物ID
                        --         level = 15,      --怪物等级
                        --       },
                        -- [2] = {     --2号位置
                        --         id = 2201422,   --怪物ID
                        --         level = 120,      --怪物等级
                        --       },                        
                        -- [3] = {     --4号位置
                        --         id = 82014018,   --怪物ID
                        --         level = 50,      --怪物等级
                        --       },
                     }

local g_mainTptID  = 1015001        --测试战车的主炮ID 白：1012001  绿：1013002  蓝：1014001  紫：1015001
--------------------------------------------------------------------------------------------------

function gotoSkillScene(block)
    if not g_IsDebug then
        --return
    end

    if false then

        package.loaded["app.widget.UIGainBox"] = nil
        local mod = require("app.widget.UIGainBox")

        local loc_TaskData = {gold = 100,diamond = 101,exp = 102,energy = 104}
        loc_TaskData.rewardItems = "3025003#10"
        local curRewards = {}
        if 0~=loc_TaskData.gold then
            table.insert(curRewards, {templateID=GAINBOXTPLID_GOLD, num=loc_TaskData.gold})
        end
        if 0~=loc_TaskData.diamond then
            table.insert(curRewards, {templateID=GAINBOXTPLID_DIAMOND, num=loc_TaskData.diamond})
        end
        if 0~=loc_TaskData.exp then
            table.insert(curRewards, {templateID=GAINBOXTPLID_EXP, num=loc_TaskData.exp})
        end
        if 0~=loc_TaskData.energy then
            table.insert(curRewards, {templateID=GAINBOXTPLID_STRENGTH, num=loc_TaskData.energy})
        end
        if nil~=loc_TaskData.rewardItems and""~=loc_TaskData.rewardItems and "null"~=loc_TaskData.rewardItems then
            local arr = string.split(loc_TaskData.rewardItems, "|")
            local subArr
            for i=1, #arr do
                subArr = string.split(arr[i], "#")
                table.insert(curRewards, {templateID=tonumber(subArr[1]), num=tonumber(subArr[2])})
            end
        end
        GlobalShowGainBox({bAlwaysExist = true}, curRewards,2)
        return
    end

    BattleData.members = {}
    BattleData.rewardItems = {}
    local nums = {}
    if g_isNewCreate then
        nums = {1002,1003,1004,1005,1006}
    end
    for i = 1 ,#nums do
      local memberHero = startFightMemberData[nums[i]]
      local _data = {}
      local tmpId = nil
      if memberHero.mtype==2 then --人
        _data = memberData
        tmpId = memberHero.tptId
      elseif memberHero.mtype==1 or memberHero.mtype==3 then --车或牵引车
        _data = carData
        tmpId = memberHero.carTptId
      end
      local sklStr = _data[tmpId].skillIds
      local arr = lua_string_split(sklStr,"#")
      local skl = {}
      for k,v in pairs(arr) do
        skl[#skl+1] = {id=v,sts = 1}
      end
      memberHero.skl = skl
      memberHero.pos = i
      memberHero.hp = 800000000
      memberHero.hp = 800000000
      BattleData.members[#BattleData.members+1] = memberHero
    end

    BattleData["laserAtk"] = 500
    BattleData["laserEco"] = 5
    BattleFormatInfo = 
    {
        matrix = {
            bullet3 = 12107,
            bullet1 = 12109,
            bullet2 = 12106,
        },

        seBlts = {
            {
                id = 12106,
                templateId = 1075006,
                count = 60,
            },
            {
                id = 12107,
                templateId = 1075005,
                count = 383,
            },
            {
                id = 12109,
                templateId = 1075003,
                count = 110,
            },

        },

    }
        
    local g_wolf = 
    {
        attack = 10000,
        erecover = 4.09,
        miss = 524.5,
        mainAtk = 1358,
        carTptId = 1052,
        tptId = 1052,
        agility = 76,
        cri = 63.51,
        cDevTptId = 1055001,
        subTptId = 1022001,
        mainSklId = 1101001,
        defense = 111,
        engTptId = 1042001,
        power = 119.1,
        proLevel = 1,
        subSklId = 1102001,
        strength = 419,
        mainTptId = 1013002,
        hp = 8000000000,
        subAtk = 371,
        name = "Ì¹¿Ë",
        hit = 28.08,
        weaAdvLvl = 1.1,

        skl = {
            {
                id = 1103007,
                sts = 1,
                lvl = 1,
            },

            {
                id = 1103050,
                sts = 1,
                lvl = 1,
            },

            {
                id = 1103009,
                sts = 1,
                lvl = 1,
            },

            {
                id = 1103010,
                sts = -1,
                lvl = 1,
            },

        },
         
        mtype = 2,
        -- mtype = 1,
        energy = 185,
        pos = 1,

    }
        
    if g_isNewCreate then
        block_idx = 10000001
    else
        if  g_isCarFight == true then
            block_idx = 22003001
            g_wolf.mtype = 1
            g_wolf.carTptId = g_tptID
            g_wolf.tptId = g_tptID
        else
            block_idx = 11006006
            g_wolf.mtype = 2
            g_wolf.tptId = g_tptID
        end
        g_wolf.mainTptId = g_mainTptID

        -- blockData[block_idx].monsters = blockData[block_idx].monsters.."|12012001:2:1:2|12005001:3:2:1"
        blockData[block_idx].monsters = ""
        for k,v in pairs(g_monsters) do
            if blockData[block_idx].monsters ~= "" then
                blockData[block_idx].monsters = blockData[block_idx].monsters.."|"
            end
            blockData[block_idx].monsters = blockData[block_idx].monsters..tostring(v.id)..":".."1"..":"..tostring(v.level)..":"..tostring(k)
        end

        BattleData.members[#BattleData.members+1] = g_wolf
    end

    app:enterScene("LoadingScene",{SceneType.Type_Battle})

end