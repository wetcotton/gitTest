--
-- Author: liufei
-- Date: 2014-11-04 16:01:38
--

--[[三种英雄类型
 MemberAllHeroType = {}
 MemberAllHeroType.kHeroTanker = 1 -- 坦克手
 MemberAllHeroType.kHeroFighter = 2 -- 格斗家
 MemberAllHeroType.kHeroMechanic = 3 -- 机械师
 ]]--
 require("app.battle.BattleInfo")
 require("app.battle.battleAI.ExclusivesAI")
 local Progress = require("app.battle.battleUI.HpProgress")
 local LocalGameData = require("app.data.LocalGameData")
 local HurtNumber = require("app.battle.battleUI.HurtNumber")
 local TalkNode = require("app.battle.battleUI.TalkNode")
 local BufferAI = require("app.battle.battleAI.BufferAI")

 local MemberHero = class("MemberHero", function ()
 	return display.newNode()
 end)

 function MemberHero:ctor(_hero)
 	--设置精灵
    self:initAllAttribute(_hero)
    local typeName = nil
    local idName = nil
    local resName = ""
    local hpHeightValue = 1
    if _hero["mtype"] == MemberAllType.kMemberHero  then
        typeName = "Hero"
        idName = _hero["tptId"]
        resName = memberData[idName]["resId"]
        hpHeightValue = tonumber(memberData[idName]["hppos"])
        self.makeType = memberData[_hero["tptId"]]["actType"]
    else
        typeName = "Tank"
        idName = _hero["carTptId"]
        resName = carData[idName]["resId"]
        hpHeightValue = tonumber(carData[idName]["hppos"])
        self.makeType = ModelMakeType.kMake_Coco
    end

    if self.makeType == ModelMakeType.kMake_Coco then
     	local manager = ccs.ArmatureDataManager:getInstance()
        manager:removeArmatureFileInfo("Battle/"..typeName.."/"..typeName.."_"..resName.."_.ExportJson")
        manager:addArmatureFileInfo("Battle/"..typeName.."/"..typeName.."_"..resName.."_.ExportJson")
        self.m_member = ccs.Armature:create(typeName.."_"..resName.."_")
        self:addChild(self.m_member)
    else
        self.m_member = sp.SkeletonAnimation:create("Battle/"..typeName.."/"..typeName.."_"..resName.."_.json","Battle/"..typeName.."/"..typeName.."_"..resName.."_.atlas",1)
        self:addChild(self.m_member)
    end
    -- self.m_member:setColor(cc.c3b(0, 0, 0))
    -- self.m_member:getAnimation():setSpeedScale(0.5) 
    self.m_attackType = MemberAttackType.kAttackMelee --近战

    self.memberSize = self.m_member:getContentSize()
    --缩放值
    self.m_scaleNum = 1
    if self.m_memberType == MemberAllType.kMemberHero then
        self.m_scaleNum = memberData[tonumber(self.m_attackInfo.tptId)]["scale"]
    else
        self.m_scaleNum = carData[tonumber(self.m_attackInfo.tptId)]["scale"]
    end
    --根据距离远近再次缩放
    self.m_scaleNum = FightPosScale[self.fightPos]*self.m_scaleNum
    --分辨率调整再次缩放
    self.m_scaleNum = BattleScaleValue*self.m_scaleNum*BlockTypeScale
    self.m_member:scale(self.m_scaleNum)
    --朝向调整
    self.m_member:setScaleX(-self.m_member:getScaleX())
    
    --血条
    self.progress = Progress.new("Battle/xxxttu_d02-06.png", "Battle/xxxttu_d02-05.png")
    self.progress:setPosition(0, HpProgressHeight*hpHeightValue*FightPosScale[self.fightPos]*BlockTypeScale)
    self.progress:setScaleX(1.2*BlockTypeScale)
    self.progress:setScaleY(1.3*BlockTypeScale)
    self:addChild(self.progress)
    self.progress:setVisible(false)
    --对话框
    self.m_talkNode = TalkNode.new()
    :addTo(self)
    
    --PVP反向
    if self.m_posType == MemberPosType.attackType then
        self.m_talkNode:align(display.BOTTOM_CENTER, display.width*0.12, self.progress:getPositionY() + display.width*0.04)
    elseif self.m_posType == MemberPosType.defenceType then
        self.m_talkNode:align(display.BOTTOM_CENTER, 0, self.progress:getPositionY() + display.width*0.04)
        self.m_member:setScaleX(-self.m_member:getScaleX())
    end

    --buffs
    self.buffShowing = {}

    --伤害吸收护盾
    self.m_allShields = {}
    
    --受击点偏移量
    self.hitOffsetX = 0
    self.hitOffsetY = 0
    
    --怪物类型
    self.m_monsterType = 4

    --魅惑击晕值
    self.m_stunNum = 0

    --沉默值
    self.m_gagNum = 0

    --BUFF
    self.buffControl = BufferAI.new()
    :addTo(self)

 end

 function  MemberHero:initAllAttribute(_hero)
    --战斗需要的属性
    --普通攻击相关
    self.m_attackInfo = {
      attackValue = 0, --攻击力
      curHp = 0, --当前生命
      maxHp = 0, --最大生命值
      defenceValue = 0, --防御力   
      critValue = 0, -- 暴击
      hitValue = 1, -- 命中
      dodgeValue = 0, --闪避
      attackInterval = 0, --攻击间隔
      attackRect = 0,  --攻击距离
      heroTptId = 0,
      tptId = 0, --模板ID
      tptName = nil, --模板名字 
      level = srv_userInfo.level,
      posType = self.m_posType,
      mainCD = 0, --主炮攻击间隔
      carLvl = 0, --觉醒等级
    }
    
    --开场战斗攻击方的等级
    if self.m_attackInfo.level == nil then
        self.m_attackInfo.level = 120
    end
    --一下为修复BUG增加判断，PVP中战车的等级要去服务端传过来的，而不是取自身的等级
    if self.m_posType == MemberPosType.defenceType then
        self.m_attackInfo.level = BattleData.elevel
    else
        if IsPlayback then --回放进攻方的等级取当时战斗的等级，而不是现在的等级
            self.m_attackInfo.level = BattleData.mylevel
        end
    end

    --初始化随机数种子数组
    -- self.m_randSeedPool = {}
    -- self.m_startSeed = tonumber(tostring(os.time()):reverse():sub(1,6))
    -- math.randomseed(self.m_startSeed)
    -- for i=1,2000 do --2000个种子
    --     self.m_randSeedPool[i] = math.random(10000)
    -- end
    -- self.m_seedIndex = 1 
    --技能顺序
    self.sklOrder = _hero["sklOrder"]
    
    --所有能量消耗技能
    self.m_energySkills = {}
    self.m_attackInfo.heroTptId = _hero["tptId"]
    --逻辑相关
    self.m_isDead = false
    --技能相关
    self.m_energyRecovery = tonumber(_hero["erecover"])  --能量恢复速度  暂定死每秒2点
    self.recoverSpeed = 1/self.m_energyRecovery --定义self.recoverSpeed是为了pvp战斗结束，反推m_energyRecovery给服务端校验作弊
    self.sklPlayCnt = 0 --技能播放次数，for作弊校验
    self.avgEnergy = 0 --主动技能的平均能量值，for作弊校验

    self.m_memberType = _hero["mtype"]
    
    self.m_bltFireSound = nil
    self.m_bltEpoSound = nil
    self.m_mainFireSound = nil
    self.m_mainEpoSound = nil
    self.m_seFireSound = nil
    self.m_seEpoSound = nil

    self.m_attackTime = 0

    local svrSkillInfo = _hero["skl"]
    --助战NPC
    if svrSkillInfo == nil then
        if self.m_memberType == MemberAllType.kMemberHero then 
            svrSkillInfo = {
                          [1] = {["lvl"] = 1},
                          [2] = {["lvl"] = 1},
                          [3] = {["lvl"] = 1},
                          [4] = {["lvl"] = 1},
                       }
        else
            svrSkillInfo = {
                          [1] = {["sts"] = 1},
                          [2] = {["sts"] = 1},
                          [3] = {["sts"] = 1},
                          [4] = {["sts"] = 1},
                       }
        end
     end
    
    --坦克的进阶加成
    self.m_exclusiveInfo = {}
    
    local energySklCnt = 0
    local energySklEnergySum = 0
    if self.m_memberType == MemberAllType.kMemberHero then --单英雄
        self.m_attackInfo.attackValue = _hero["attack"]
        self.m_attackInfo.tptId = _hero["tptId"]
        self.m_attackInfo.tptName = self:getHeroNameByID(self.m_attackInfo.tptId)
        self.weId = memberData[tonumber(self.m_attackInfo.tptId)]["weaponTmpId"]
        local skillIds = string.split(memberData[tonumber(self.m_attackInfo.tptId)]["skillIds"],"#")
        
        self.m_energySkills[MemberSkillType.kSkillHeroOne] = {id = 0, bef = 0, energy = 0,sts = -1}
        self.m_energySkills[MemberSkillType.kSkillHeroOne].id = itemData[self.weId]["sklId"]
        self.m_energySkills[MemberSkillType.kSkillHeroOne].bef = memberData[tonumber(self.m_attackInfo.tptId)]["befCas"]
        self.m_energySkills[MemberSkillType.kSkillHeroOne].energy = skillData[self.m_energySkills[MemberSkillType.kSkillHeroOne].id]["sklCD"]
        self.m_energySkills[MemberSkillType.kSkillHeroOne].sts = 1

        energySklCnt = energySklCnt + 1
        energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillHeroOne].energy

        self.m_energySkills[MemberSkillType.kSkillHeroTwo] = {id = 0, bef = 0, energy = 0,lvl = 0,sts = -1}
        self.m_energySkills[MemberSkillType.kSkillHeroTwo].id = tonumber(skillIds[1])
        if self.m_energySkills[MemberSkillType.kSkillHeroTwo].id ~= nil and self.m_energySkills[MemberSkillType.kSkillHeroTwo].id ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillHeroTwo].bef = memberData[tonumber(self.m_attackInfo.tptId)]["befCas2"]
            self.m_energySkills[MemberSkillType.kSkillHeroTwo].energy = skillData[self.m_energySkills[MemberSkillType.kSkillHeroTwo].id]["sklCD"]
            self.m_energySkills[MemberSkillType.kSkillHeroTwo].lvl = tonumber(svrSkillInfo[1]["lvl"])
            if self.m_energySkills[MemberSkillType.kSkillHeroTwo].lvl > 0 then
                self.m_energySkills[MemberSkillType.kSkillHeroTwo].sts = 1

                energySklCnt = energySklCnt + 1
                energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillHeroTwo].energy                
            end
        end
    
        self.m_energySkills[MemberSkillType.kSkillHeroThree] = {id = 0, bef = 0, energy = 0,lvl = 0,sts = -1}
        self.m_energySkills[MemberSkillType.kSkillHeroThree].id = tonumber(skillIds[2])
        if self.m_energySkills[MemberSkillType.kSkillHeroThree].id ~= nil and self.m_energySkills[MemberSkillType.kSkillHeroThree].id ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillHeroThree].bef = memberData[tonumber(self.m_attackInfo.tptId)]["befCas3"]
            self.m_energySkills[MemberSkillType.kSkillHeroThree].energy = skillData[self.m_energySkills[MemberSkillType.kSkillHeroThree].id]["sklCD"]
            self.m_energySkills[MemberSkillType.kSkillHeroThree].lvl = tonumber(svrSkillInfo[2]["lvl"])
            if self.m_energySkills[MemberSkillType.kSkillHeroThree].lvl > 0 then
                self.m_energySkills[MemberSkillType.kSkillHeroThree].sts = 1

                energySklCnt = energySklCnt + 1
                energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillHeroThree].energy                
            end   
        end
        self.m_energySkills[MemberSkillType.kSkillHeroFour] = {id = 0, bef = 0, energy = 0,lvl = 0,sts = -1}
        self.m_energySkills[MemberSkillType.kSkillHeroFour].id = tonumber(skillIds[3])
        if self.m_energySkills[MemberSkillType.kSkillHeroFour].id ~= nil and self.m_energySkills[MemberSkillType.kSkillHeroFour].id ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillHeroFour].bef = memberData[tonumber(self.m_attackInfo.tptId)]["befCas4"]
            self.m_energySkills[MemberSkillType.kSkillHeroFour].energy = skillData[self.m_energySkills[MemberSkillType.kSkillHeroFour].id]["sklCD"]
            self.m_energySkills[MemberSkillType.kSkillHeroFour].lvl = tonumber(svrSkillInfo[3]["lvl"])
            if self.m_energySkills[MemberSkillType.kSkillHeroFour].lvl > 0 then
                self.m_energySkills[MemberSkillType.kSkillHeroFour].sts = 1

                energySklCnt = energySklCnt + 1
                energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillHeroFour].energy                
            end   
        end        

        self.m_attackInfo.attackInterval = tonumber(itemData[self.weId]["sklCD"]) - tonumber(_hero["weaAdvLvl"])*tonumber(itemData[self.weId]["timeGF"])
        --开枪音效
        if itemData[self.weId]["firemusic"] ~= "null" and tonumber(itemData[self.weId]["firemusic"]) ~= 0 then
             self.m_bltFireSound = itemData[self.weId]["firemusic"]
             audio.preloadSound("audio/musicEffect/weaponEffect/"..self.m_bltFireSound..".mp3")
        end
        --击中音效
        if itemData[self.weId]["burstmusic"] ~= "null" and tonumber(itemData[self.weId]["burstmusic"]) ~= 0 then
             self.m_bltEpoSound = itemData[self.weId]["burstmusic"]
             audio.preloadSound("audio/musicEffect/weaponEffect/"..self.m_bltEpoSound..".mp3")
        end
        --攻击前摇
        self.m_befAttack = memberData[tonumber(self.m_attackInfo.tptId)]["befAtk"]  
        --攻击距离
        self.m_attackInfo.attackRect = memberData[tonumber(self.m_attackInfo.tptId)]["atkDis"]
        --子弹出发相对位置
        self.m_bltPos = memberData[tonumber(self.m_attackInfo.tptId)]["balPos"]
        self.m_skillStartPos = memberData[tonumber(self.m_attackInfo.tptId)]["sklbslpos"]

        self.m_bulletStr = memberData[tonumber(_hero["tptId"])]["bltResId"]
        self.m_bulletResNum = memberData[tonumber(_hero["tptId"])]["bltResNum"]
        if self.m_bulletResNum > 1 then
            display.addSpriteFrames("Battle/Bullet/"..self.m_bulletStr..".plist", "Battle/Bullet/"..self.m_bulletStr..".png")
            table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..self.m_bulletStr..".plist",pngStr = "Battle/Bullet/"..self.m_bulletStr..".png"})
        end
        --加载弹道等资源
        self.m_attackEffectName = memberData[tonumber(self.m_attackInfo.tptId)]["atkResId"]
        display.addSpriteFrames("Battle/Skill/"..self.m_attackEffectName..".plist", "Battle/Skill/"..self.m_attackEffectName..".png")
        table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/"..self.m_attackEffectName..".plist",pngStr = "Battle/Skill/"..self.m_attackEffectName..".png"})
    else
        self.m_attackInfo.tptId = _hero["carTptId"]

        --进阶加成
        local exclusiveStr = carData[tonumber(self.m_attackInfo.tptId)]["exclusive"]
        if exclusiveStr ~= "null" and exclusiveStr ~= "" and exclusiveStr ~= "0" then
            local exclusive = string.split(exclusiveStr, "|")
            for i=1,#exclusive do
                local oneAdd = string.split(exclusive[i],"#")
                if oneAdd[2] == nil then
                    self.m_exclusiveInfo[tonumber(oneAdd[1])] = 1
                else
                    self.m_exclusiveInfo[tonumber(oneAdd[1])] = tonumber(oneAdd[2])
                end
            end
        end
        --烟尘
        local dustOffSets = string.split(carData[tonumber(self.m_attackInfo.tptId)]["dustPos"],"|")
        local dustxOffset = tonumber(dustOffSets[1])
        local dustyOffset = tonumber(dustOffSets[2])
        self.m_dustEff = display.newSprite("#dust_10001_00.png")
        :addTo(self)
        local dustScale = tonumber(carData[tonumber(self.m_attackInfo.tptId)]["dustScale"])
        self.m_dustEff:setScaleY(dustScale)
        if self.m_posType == MemberPosType.attackType then
            self.m_dustEff:setScaleX(-dustScale)
            self.m_dustEff:pos(-display.width*0.1*dustxOffset,display.width*0.1*dustyOffset)
        else
            self.m_dustEff:setScaleX(dustScale)
            self.m_dustEff:pos(display.width*0.1*dustxOffset,display.width*0.1*dustyOffset)
        end
        local framesdust= display.newFrames("dust_10001_%02d.png", 0, 10)
        local animationdust = display.newAnimation(framesdust, 0.5/11)
        local actiondust= cc.RepeatForever:create(cc.Animate:create(animationdust))
        self.m_dustEff:runAction(actiondust)
        --开枪音效
        if itemData[_hero["subTptId"]]["firemusic"] ~= "null" and tonumber(itemData[_hero["subTptId"]]["firemusic"]) ~= 0 then
             self.m_bltFireSound = itemData[_hero["subTptId"]]["firemusic"]
             audio.preloadSound("audio/musicEffect/weaponEffect/"..self.m_bltFireSound..".mp3")
        end
        --击中音效
        if itemData[_hero["subTptId"]]["burstmusic"] ~= "null" and tonumber(itemData[_hero["subTptId"]]["burstmusic"]) ~= 0 then
             self.m_bltEpoSound = itemData[_hero["subTptId"]]["burstmusic"]
             audio.preloadSound("audio/musicEffect/weaponEffect/"..self.m_bltEpoSound..".mp3")
        end
        if _hero["subTptId"] ~= nil and tonumber(_hero["subTptId"]) ~= 0 then
            self.m_skillSubID = itemData[_hero["subTptId"]]["sklId"]  --副炮技能ID
            self.m_attackInfo.attackValue = _hero["subAtk"]
            if self.m_skillSubID ~= nil and tonumber(self.m_skillSubID) ~= 0 then
                self.m_attackInfo.attackInterval = skillData[self.m_skillSubID]["sklCD"]
            end
        end
        
        local skillIdsStr = string.split(carData[tonumber(self.m_attackInfo.tptId)]["skillIds"],"|")[1]
        local skillIDs = string.split(skillIdsStr,"#")
        self.m_energySkills[MemberSkillType.kSkillTankOne] = {id = 0, bef = 0, energy = 0, sts = -1}
        self.m_energySkills[MemberSkillType.kSkillTankOne].id = tonumber(skillIDs[1])
        if self.m_energySkills[MemberSkillType.kSkillTankOne].id ~= nil and self.m_energySkills[MemberSkillType.kSkillTankOne].id ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillTankOne].bef = carData[tonumber(self.m_attackInfo.tptId)]["bef1"]
            self.m_energySkills[MemberSkillType.kSkillTankOne].energy = skillData[tonumber(skillIDs[1])]["sklCD"]
            self.m_energySkills[MemberSkillType.kSkillTankOne].sts =  tonumber(svrSkillInfo[1]["sts"])

            energySklCnt = energySklCnt + 1
            energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillTankOne].energy            
        end
        self.m_energySkills[MemberSkillType.kSkillTankTwo] = {id = 0, bef = 0, energy = 0, sts = -1}
        self.m_energySkills[MemberSkillType.kSkillTankTwo].id = tonumber(skillIDs[2])
        if self.m_energySkills[MemberSkillType.kSkillTankTwo].id ~= nil and self.m_energySkills[MemberSkillType.kSkillTankTwo].id ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillTankTwo].sts =  tonumber(svrSkillInfo[2]["sts"])
            self.m_energySkills[MemberSkillType.kSkillTankTwo].bef = carData[tonumber(self.m_attackInfo.tptId)]["bef2"]
            self.m_energySkills[MemberSkillType.kSkillTankTwo].energy = skillData[tonumber(skillIDs[2])]["sklCD"]

            energySklCnt = energySklCnt + 1
            energySklEnergySum = energySklEnergySum + self.m_energySkills[MemberSkillType.kSkillTankTwo].energy            
        end
        if _hero["mainTptId"] ~= nil and tonumber(_hero["mainTptId"]) ~= 0 then
            self.m_energySkills[MemberSkillType.kSkillTankMain] = {id = 0, bef = 0, energy = 0, sts = -1}
            self.m_energySkills[MemberSkillType.kSkillTankMain].id = itemData[_hero["mainTptId"]]["sklId"]
            self.m_energySkills[MemberSkillType.kSkillTankMain].bef = carData[tonumber(self.m_attackInfo.tptId)]["befmain"]
            self.m_mainTptId = _hero["mainTptId"]
            self.m_mainAtk = _hero["mainAtk"]
            --主炮攻击间隔
            self.m_attackInfo.mainCD = tonumber(itemData[self.m_mainTptId]["sklCD"])
        end
        
        self.m_attackInfo.attackRect = carData[tonumber(_hero["carTptId"])]["atkDis"]
        self.m_attackInfo.tptName = carData[tonumber(_hero["carTptId"])]["name"]
        
        --攻击前摇
        self.m_befAttack = carData[tonumber(self.m_attackInfo.tptId)]["befAtk"]
        --攻击距离
        self.m_attackInfo.attackRect = carData[tonumber(self.m_attackInfo.tptId)]["atkDis"]
        --子弹出发相对位置
        self.m_bltPos = carData[tonumber(self.m_attackInfo.tptId)]["subBalPos"]
        --主炮出发相对位置
        self.m_mainPos = carData[tonumber(self.m_attackInfo.tptId)]["mainBalPos"]
        
        
        --print("--------------"..self.m_bltPos)
        --加载弹道等资源
        self.subSkillData = skillData[self.m_skillSubID]
        self.m_bulletStr = self.subSkillData["bltResId"]
        self.m_bulletResNum = self.subSkillData["bltResNum"]
        if self.m_bulletResNum > 1 then
            display.addSpriteFrames("Battle/Bullet/"..self.m_bulletStr..".plist", "Battle/Bullet/"..self.m_bulletStr..".png")
            table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Bullet/"..self.m_bulletStr..".plist",pngStr = "Battle/Bullet/"..self.m_bulletStr..".png"})
        end
        self.m_fireResStr = self.subSkillData["fireResId"]
        self.m_fireResNum = self.subSkillData["fireResNum"]
        display.addSpriteFrames("Battle/Skill/"..self.m_fireResStr..".plist", "Battle/Skill/"..self.m_fireResStr..".png")
        table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/"..self.m_fireResStr..".plist",pngStr = "Battle/Skill/"..self.m_fireResStr..".png"})
        self.m_attackEffectName = self.subSkillData["atkResId"]
        display.addSpriteFrames("Battle/Skill/"..self.m_attackEffectName..".plist", "Battle/Skill/"..self.m_attackEffectName..".png")
        table.insert(AllAddedFramesCahe, #AllAddedFramesCahe+1,{plistStr = "Battle/Skill/"..self.m_attackEffectName..".plist",pngStr = "Battle/Skill/"..self.m_attackEffectName..".png"})
    end

    self.avgEnergy = math.floor(energySklEnergySum/energySklCnt)

    --准备技能音效
    for k,v in pairs(self.m_energySkills) do
        if v.sts == 1 and tonumber(skillData[v.id]["sklsoundres"]) ~= 0 then
            audio.preloadSound("audio/musicEffect/skillEffect/"..skillData[v.id]["sklsoundres"]..".mp3")
        end
    end

    self.m_attackInfo.curHp = math.floor(_hero["hp"])
    self.m_attackInfo.maxHp = math.floor(_hero["hp"])
    self.m_attackInfo.defenceValue = _hero["defense"]
    self.m_attackInfo.critValue = _hero["cri"]
    self.m_attackInfo.hitValue = _hero["hit"]
    self.m_attackInfo.dodgeValue = _hero["miss"]
    self.m_attackInfo.attackRect = AttackPosRects[self.fightPos]
    if _hero["carLvl"] then
        self.m_attackInfo.carLvl = _hero["carLvl"]
    end
    

    -- if self.m_posType == MemberPosType.attackType then
    --     self.m_attackInfo.defenceValue = 100000
    --     self.m_attackInfo.attackValue = 10000
    -- elseif self.m_posType == MemberPosType.defenceType then
    --     self.m_attackInfo.defenceValue = 0
    -- end
 end

 function MemberHero:getHitPosition()
    return {x = self:getPositionX() + self.hitOffsetX, y = self:getPositionY() + self.progress:getPositionY()/2 + self.hitOffsetY}
 end

 function MemberHero:getHeroNameByID(_tptId)
    if tonumber(string.sub(_tptId,1,3)) == 101 or tonumber(string.sub(_tptId,1,3)) == 102 then
        --主角
        return srv_userInfo.name or ""
    end
    return memberData[tonumber(self.m_attackInfo.tptId)]["name"]
 end

 function MemberHero:playHeroAnimation(_animation)
    if self.makeType == ModelMakeType.kMake_Coco then
        if _animation == "" or  _animation == "" then
            self.m_member:getAnimation():play(_animation,-1,0)
        else
            self.m_member:getAnimation():play(_animation)
        end
        --flash动画强行从0帧开始播放
        self.m_member:getAnimation():gotoAndPlay(0)
    else
        if self.m_attackInfo.tptId ~= 10641 then
            self.m_member:setToSetupPose()
        end
        local ret = nil
        if _animation == "walk" or _animation == "Standby" then
            ret = self.m_member:setAnimation(0, _animation, true)
        else
            ret = self.m_member:setAnimation(0, _animation, false)
        end

        -- if ret then
            -- cc.spAnimationState_apply(_state, _skeleton)
        -- end
    end
 end

 function MemberHero:getAttackInfo()
     return self.m_attackInfo
 end

 function MemberHero:CalculateBeAttacked(_attackerInfo)
     --计算最终伤害
     --是否命中
     
    if isTrigger(_attackerInfo.hitValue + 1000 - self.m_attackInfo.dodgeValue, 1000, self:getRandomSeed()) == false then
        self:LiquidateDamage(0, false)
        return 0
    end
     --伤害
     local damageValue = (_attackerInfo.attackValue - self.m_attackInfo.defenceValue)*damageRandom(self:getRandomSeed())
     --是否暴击
     local isCrit = false
     if isTrigger(_attackerInfo.critValue, 1000, self:getRandomSeed()) == true then
        isCrit = true
        damageValue = damageValue*1.5
     end
     if damageValue < 1 then
         damageValue = 1
         isCrit = false
     end


     local trueDamage = self:LiquidateDamage(math.floor(damageValue),isCrit,_attackerInfo)

     --收集信息
     --反作弊
     if self.m_attackInfo.defenceValue > BattleVerify["maxDef"] then
         BattleVerify["maxDef"] =self.m_attackInfo.defenceValue
     end
     -- local message = {}
     -- message["type"] = BattleMessageType.kMessageAttack
     -- message["initiativeId"] = _attackerInfo.tptId
     -- message["passiveId"] = self.m_attackInfo.tptId
     -- message["initiativeName"] = _attackerInfo.tptName
     -- message["passiveName"] = self.m_attackInfo.tptName
     -- message["damage"] = math.floor(damageValue)
     -- BattleMessageBox:addMessage(message)
     if trueDamage ~= nil then
         return trueDamage
     else
         return 0
     end
 end

 function MemberHero:CalculateBeSkilled(_skillInfo, _attackInfo)
     --buff
     if _skillInfo.skillBuffID ~= 0 then
        local flag = self.buffControl:addBuffer(self, _skillInfo.skillBuffID, _skillInfo.skillSponsor, _skillInfo.skillSLevel)
     end
     
     --只带BUFF 无伤害的技能
     if _skillInfo.skillBaseDamage <= 0 then
        return
     end

     local damage = (_skillInfo.skillBaseDamage - self.m_attackInfo.defenceValue/_skillInfo.skillSection)*_skillInfo.skillCoefficient*damageRandom(self:getRandomSeed())

     ----计算属性相克  hero的系数是1不用处理

     local isCrit = false
     if isTrigger(_attackInfo.critValue, 1000, self:getRandomSeed()) == true then
        isCrit = true
        damage = damage*1.5
     end
     if damage < 1 then
         damage = 1
     end
     local trueDamage =  self:LiquidateDamage(math.floor(damage),isCrit,_attackInfo)
     --收集信息
     --反作弊
     if self.m_attackInfo.defenceValue > BattleVerify["maxDef"] then
         BattleVerify["maxDef"] =self.m_attackInfo.defenceValue
     end
    -- local message = {}
    -- message["type"] = BattleMessageType.kMessageBeSkilled
    -- message["initiativeId"] = _attackInfo.tptId
    -- message["passiveId"] = self.m_attackInfo.tptId
    -- message["initiativeName"] = _attackInfo.tptName
    -- message["passiveName"] = self.m_attackInfo.tptName
    -- message["skillId"] = _skillInfo.skillId
    -- message["skillName"] = skillData[tonumber(_skillInfo.skillId)]["sklName"]
    -- message["damage"] = math.floor(damage)
    -- BattleMessageBox:addMessage(message)

    return trueDamage
 end

 function MemberHero:LiquidateDamage(_damageValue,_isCrit,_attackInfo) --计算伤害
    
     if IsBattleOver then
        return 0
     end
     local trueDamage = 0
     _damageValue = math.floor(_damageValue)
     if _damageValue > 0 then
       if self.m_exclusiveInfo[ExclusiveType.kFinalDefend] ~= nil then
           _damageValue = _damageValue - _damageValue*self.m_exclusiveInfo[ExclusiveType.kFinalDefend]
       end
       for k,v in pairs(self.m_allShields) do
          if v ~= nil and v.shieldHp > 0 then
              v.shieldHp = v.shieldHp - _damageValue
              if v.shieldHp <= 0 then
                  self.buffControl:clearShield(self,k)
              end
              return trueDamage
          end
       end
     end

     self.progress:stopAllActions()
     self.progress:setVisible(true)
     self.progress:performWithDelay(function()
        self.progress:setVisible(false)
     end, 2.5)
     
     --最终伤害的加成处理
     
     if _damageValue > 1 and _attackInfo ~= nil then
        _damageValue = ExclusivesAI:getFinalDamage(_damageValue,_attackInfo,self.m_attackInfo,self.buffShowing)
     end

     self.m_attackInfo.curHp = self.m_attackInfo.curHp - _damageValue

     if self.m_attackInfo.curHp > self.m_attackInfo.maxHp then
         self.m_attackInfo.curHp = self.m_attackInfo.maxHp
     end


     local damageNumber = HurtNumber.new(math.ceil(_damageValue),_isCrit) --此处向上取整，保证零点几的伤害不被处理成闪避
     :pos(self.progress:getPositionX()-self.progress:getContentSize().width, self.progress:getPositionY()+display.width/90)
     :addTo(self)
     local percent = 0
     if self.m_attackInfo.curHp<=0 then
         self.m_isDead = true
         percent = 0
         self.m_attackInfo.curHp = 0

        --self.m_isDead 置为true后，状态机要同步否则会出现一些不同步的问题（中型坦克空血上阵时，技能打不中，之后会卡死）
        if self.m_isDead and self.m_fsm:getState() ~= "dead" then
           self:doEvent("goDead")
           return
        end
     else
         --self:playHeroAnimation(MemberAnimationType.kMemberAnimationHit)
         percent = self.m_attackInfo.curHp/self.m_attackInfo.maxHp*100
     end
     self.progress:setProgress(percent)
     if self.m_posType  == MemberPosType.attackType and self.m_memberType ~=  MemberAllType.kMemberTank  then
         
        if startFightBattleScene.Instance~=nil then
            startFightBattleScene.Instance.allControlDesk[self.fightPos]:beHit(percent)
        else
            cc.Director:getInstance():getRunningScene().allControlDesk[self.fightPos]:beHit(percent)
        end
     end

    

     return _damageValue
 end

 function MemberHero:stopHeroAnimation()
    if self.makeType == ModelMakeType.kMake_Coco then
        self.m_member:getAnimation():stop()
    else
        self.m_member:stop()
    end
 end

 function MemberHero:getAttackRect()
     return self.m_attackInfo.attackRect * display.width
 end

 function MemberHero:getMemberAnimation()
     if self.makeType == ModelMakeType.kMake_Coco then
        return self.m_member:getAnimation()
     else
        return self.m_member
     end
 end

 function MemberHero:getRandomSeed()
     -- self.m_seedIndex = self.m_seedIndex + 1
     -- if self.m_randSeedPool[self.m_seedIndex - 1] then
     --      return self.m_randSeedPool[self.m_seedIndex - 1]
     -- else
     --      return 100000
     -- end

     return 100000
     
 end

 return MemberHero