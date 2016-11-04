--require("app.data.GameData")
require("app.scenes.block.teamUpgrade")

--角色登录后的数据处理
function loginHandle(data)
  --切换账号后重置请求人物，战车数据的标志位
  CarManager.isReqFlag = true
  RoleManager.isReqFlag = true
  CurFightBattleType = 0

  
  srv_userInfo = data
  mapAreaId = areaData[srv_userInfo["areaId"]].resId
  lastTownId = mapAreaId
  SetEnergyAndCountDown()
  srv_local_dts = os.time()*1000 - data.ts
  RentMgr:InitWithLocalData()

  --保存本次登录的服务器信息到本地
  GameData.loginServerList = loginServerList
  GameState.save(GameData)

  print("======================================-----------GameData.loginServerList:")
  printTable(GameData.loginServerList)

  if loginServerList.serverName==nil or loginServerList.serverName=="" then loginServerList.serverName="测试重装机兵" end
  print("mUserId",mUserId,"loginServerList.serverId",loginServerList.serverId)
  if "zzjbSvr_01"==loginServerList.serverId then
    DCAccount.login(tostring(srv_userInfo.characterId),loginServerList.serverName)
  else
    DCAccount.login(tostring(mUserId),loginServerList.serverId)
  end
  
  print("--------------------------ccccc")
  if isUCLogin  then
      --"{\"roleLevel\":99,\"roleId\":\"29392\",\"roleName\":\"令狐一冲\",\"zoneId\":192825,\"zoneName\":\"游戏一区-逍遥谷\"}"
      loginServerList.serverName = loginServerList.serverName or ""
      local str = "{\"roleLevel\":"..srv_userInfo.level..",\"roleId\":\""..srv_userInfo.characterId.."\",\"roleName\":\""..srv_userInfo.name.."\",\"zoneId\":\""..loginServerList.serverId.."\",\"zoneName\":\""..loginServerList.serverName.."\"}"
      print(str)
      luaUCGameSdk:submitExtendData("loginGameRole",str)
  elseif isAnzhiLogin then
      loginServerList.serverName = loginServerList.serverName or ""
      local tab = {
        anzhiSDK.Nick,
        anzhiSDK.uid,
        loginServerList.serverName,
        srv_userInfo.level,
        srv_userInfo.name,
        "备注无",
      }
      anzhiSDK:submitGameInfo(tab)
  end
  DCAccount.setGameServer(loginServerList.serverName)
  
end
function parseSocketData(commandId,result)
  data=result["data"]

  if result["result"]~=1 then
    return 0
  end

  if commandId == CMD_ROLE_LOGIN then
    loginHandle(data)

  elseif commandId == CMD_ROLE_CREATE then
    loginHandle(data)
    print("========================66")
    print("mUserId:",mUserId, 0, 0, "QH360", "srv_userInfo.level:",tostring(srv_userInfo.level), "loginServerList.serverId:",tostring(loginServerList.serverId), "")
    luaStatPlayer(mUserId, 0, 0, "QH360", tostring(srv_userInfo.level), tostring(loginServerList.serverId), "")
    luaStatRole(srv_userInfo.name)
    -- g_isNewCreate = true
  elseif commandId == CMD_ENTER_BLOCK then --关卡
        srv_blockData = {}
        srv_lastBlockData = {}
        srv_nextBlockData = {}

        local blockArr=lua_string_split(sendAreaList,"|")
        local midData, lastData, nextData

        for i,value in ipairs(data) do
          if value.areaId==(blockArr[2]+0) then
            midData = data[i]
          elseif value.areaId==(blockArr[1]+0) then
            lastData = data[i]
          elseif value.areaId==(blockArr[3]+0) then
            nextData = data[i]
          end
        end

        local normal2 = midData.normal
        if normal2~=nil then
          for i=1,#normal2 do
              local key=normal2[i].id
              srv_blockData[key]=normal2[i]
          end
          -- srv_blockArmyData = midData.army
        end

  elseif commandId == CMD_LEGION_BLOCK then
    -- srv_blockArmyData = data

  elseif commandId == CMD_CHANGE_AREA then
      -- print("换区")
      -- srv_blockData_byid = {}
      -- srv_blockData = {}
      -- -- srv_blockData_byid = data.data
      --   for i=1,#data.data do
      --      -- print(Data[i].id)
      --       local key=data.data[i].id
      --       srv_blockData[key]=data.data[i]
      --   end

  elseif commandId == CMD_BACKPACK then --背包
      srv_carEquipment = {}
      local tmp_carEptItem = data["carIt"]
      local tmp_carEptPiece = data["piece"]
      local tmp_bpItem = data["item"]
      local tmp_menIt = data["memIt"]
      local srv_EptItem={}
      local srv_EptPiece={}
      local srv_bpItem={}
      local srv_menIt={}
      for i,value in ipairs(tmp_carEptItem) do
        srv_EptItem[value["id"]]=value
      end
      for i,value in ipairs(tmp_carEptPiece) do
        srv_EptPiece[value["id"]]=value
      end
      for i,value in ipairs(tmp_bpItem) do
        srv_bpItem[value["id"]]=value
      end
      for i,value in ipairs(tmp_menIt) do
        srv_menIt[value["id"]]=value
      end
      srv_carEquipment["item"] = srv_EptItem 
      srv_carEquipment["piece"] = srv_EptPiece 
      srv_carEquipment["bp"] = srv_bpItem
      srv_carEquipment["memIt"] = srv_menIt
      -- universalPieceData = srv_carEquipment["piece"][1038] --万能碎片
      -- printTable(srv_carEquipment["memIt"])
      --在线活动定时器
      if g_isOnlineSeqSend then
        g_onlineHandle = scheduler.scheduleGlobal(playerOnline, 60)
      end
      
      
      

  elseif commandId == CMD_BACKPACK_PUSH then --背包主动推送
    --添加
    print("背包推送")
    -- printTable(data.add)
    if data.add==nil or data.del==nil or data.update==nil then
      showTips("背包物品更新失败")
      print("背包推送消息出错，错误被拦截处理。")
      return
    end
    --删除
    for k,value in ipairs(data.del) do
      removeItemFromBackPack(value)
      --删除新物品
      local tmpV = get_SrvBackPack_Value(value.tmpId)
      if tmpV==nil then
        g_BPNewItems[value.id] = nil
        if MainScene_Instance then
          MainScene_Instance:refreshEquipmentRedPoint()
        end
      end
      
    end
    --增加
    for k,value in ipairs(data.add) do
      -- printTable(value)
      isNewItem(value)
      addGoodsToBackPack(value)
    end
    -- saveLocalGameDataBykey("BPNewItems", g_BPNewItems)
    --更新
    for k,value in ipairs(data.update) do
      updateItemFromBackPack(value)
    end

    srv_BackPackPushData["add"] = data.add
    srv_BackPackPushData["del"] = data.del
    srv_BackPackPushData["update"] = data.update
  
  elseif commandId == CMD_COMBINATION then --合成

    m_comItemData["id"]=srv_BackPackPushData["add"][1].id
    m_comItemData["tmpId"]=srv_BackPackPushData["add"][1].tmpId


  elseif commandId == CMD_STRENGTHEN then --强化
    DCCoin.lost("强化消耗金币","金币",data["gold"] -srv_userInfo["gold"] ,data["gold"])
    DCCoin.lost("强化消耗钻石","钻石",data["diamond"] -srv_userInfo["diamond"] ,data["diamond"])
    srv_userInfo["gold"] = data["gold"]
    srv_userInfo["diamond"] = data["diamond"]
    mainscenetopbar:setDiamond()
    mainscenetopbar:setGlod()
    -- srv_carEquipment["item"][curItemData["id"]]["advLvl"] = data["advLvl"]

  elseif commandId == CMD_LOCK then --加锁


  elseif commandId == CMD_GETADVANCED then --获取进阶信息
    srv_getAdvanced = data

  elseif commandId == CMD_ADVANCED then --进阶
    DCCoin.lost("进阶消耗金币","金币",data["gold"] -srv_userInfo["gold"] ,data["gold"])
    DCCoin.lost("进阶消耗钻石","钻石",data["diamond"] -srv_userInfo["diamond"] ,data["diamond"])
    srv_userInfo["gold"] = data["gold"]
    srv_userInfo["diamond"] = data["diamond"]
    mainscenetopbar:setDiamond()
    mainscenetopbar:setGlod()
    -- srv_carEquipment["item"][curItemData["id"]]["tmpId"] = srv_getAdvanced["toItemId"]
    -- curItemData = srv_carEquipment["item"][curItemData["id"]]
    --材料减少操作

  elseif commandId == CMD_CHANGE then --更换装备

  elseif commandId == CMD_DECOMPOSE then --分解
    srv_userInfo["gold"]=data["gold"] + srv_userInfo["gold"]
    DCCoin.gain("分解产出金币","金币",data["gold"],srv_userInfo.gold)

  elseif commandId == CMD_LOTTERY_CARD then --钻石抽卡
    srv_userInfo.diamond = data.diamond
    srv_userInfo.gold = data.gold
    mainscenetopbar:setDiamond()
    mainscenetopbar:setGlod()

  elseif commandId == CMD_LOTTERY_CARD_GOLD then --金币抽卡
    srv_userInfo.diamond = data.diamond
    srv_userInfo.gold = data.gold
    mainscenetopbar:setDiamond()
    mainscenetopbar:setGlod()
    

  elseif commandId == CMD_LEGION_ENTER then --进入军团
      InitLegionList = data
      -- if data["inArmy"]==0 then
      --   InitLegionList = data["armyInfo"]
      --   armyId = data["armyId"]
      -- elseif data["inArmy"]==1 then
      --   mLegionData={}
      --   mLegionData = data["armyInfo"]
      -- end

  elseif commandId == CMD_MYLEGION_INFO then --主界面军团信息
    mLegionData = data

  elseif commandId == CMD_FIND_LEGION then --查找军团
    findLegionData = data
    if srv_userInfo["goodEvil"]>=0 then
      findLegionData.geType = 1
    else
      findLegionData.geType = 2
    end

  elseif commandId == CMD_LEGION_TIREN then --军团被踢，推送消息
    srv_userInfo["armyName"]=""
    if LegionScene.Instance then
      showMessageBox("你已被踢出军团", function(event)
        LegionScene.Instance:removeSelf()
        MainScene_Instance:setTopBarVisible(true)
        end)
    end

  elseif commandId == CMD_CREATE_LEGION then --创建军团
    local needDia = 500
    srv_userInfo.diamond = srv_userInfo.diamond - needDia
    mainscenetopbar:setDiamond()
    --数据统计
    luaStatBuy("创建军团", BUY_TYPE_CREAT_ARMY, 1, "钻石", needDia)

  elseif commandId == CMD_APPLY_LEGION then --申请军团
    mLegionData={}
    mLegionData = data
    srv_userInfo["armyName"] = mLegionData.army.name

  elseif commandId == CMD_LEGION_FB then --军团副本
    legionFBData = {}
    legionFBData = data

  elseif commandId == CMD_LEGION_RECORD then --军团分配记录
    LegionFB_RecordData = data

  elseif commandId == CMD_LEGION_DAMAGE_RANK then --军团伤害排名
    LegionDamageRankData = data

  elseif commandId == MMD_SPOILS_QUEUE then --军团战利品信息
    LegionSpoilsData = data
    
  elseif commandId == CMD_LEGION_RECORD then --军团分配记录
    LegionFB_RecordData = data

  elseif commandId == CMD_FRIEND_LIST then --好友列表
    FriendListData = data

  elseif commandId == CMD_FRIEND_APPLY then
    FriendApplyData = data

  elseif commandId == CMD_RECOM_FRIEND then
    RecomFriendData = data

  elseif commandId == CMD_FIND_FRIEND then
    findFriendData = data

  elseif commandId == CMD_PUSH_PRIVATE_CHAT then --私聊推送消息
    table.insert(chatRecordList.Private, 1, data)
    if #chatRecordList.Private>15 then --最多保存15条
      for i=16,#chatRecordList.Private do
        table.remove(chatRecordList.Private, i)
      end
    end
    saveLocalGameDataBykey("chatRecordList", chatRecordList)

    --主界面聊天红点
    if MainScene_Instance then
      local node = MainScene_Instance.activityMenuBar.chatBt
      node:removeChildByTag(10)
      local RedPt = display.newSprite("common/common_RedPoint.png")
          :addTo(node,0,10)
          :pos(30,30)
    end
    if chatBoxLayer~=nil then
        chatBoxLayer:onPushPrivateChat(result)
    end

  elseif commandId == CMD_PUSH_LEGION_CHAT then --推送军团消息
    table.insert(chatRecordList.Legion, 1, data)
    if #chatRecordList.Legion>15 then --最多保存15条
      for i=16,#chatRecordList.Legion do
        table.remove(chatRecordList.Legion, i)
      end
    end
    saveLocalGameDataBykey("chatRecordList", chatRecordList)
    if chatBoxLayer~=nil then
        chatBoxLayer:onPushLegionChat(result)
    end

  elseif commandId == CMD_PUSH_WORLD_CHAT then --推送世界消息
    -- print("推送世界消息")
    table.insert(chatRecordList.World, 1, data)
    if #chatRecordList.World>15 then --最多保存15条
      for i=16,#chatRecordList.World do
        table.remove(chatRecordList.World, i)
      end
    end
    saveLocalGameDataBykey("chatRecordList", chatRecordList)
    if chatLayer.Instance~=nil then
        chatLayer.Instance:onPushWorldChat(result)
    end

  elseif commandId == CMD_PUSH_VIDEO_CHAT then --推送分享视频
    table.insert(chatRecordList.World, 1, data)
    if #chatRecordList.World>15 then --最多保存15条
      for i=16,#chatRecordList.World do
        table.remove(chatRecordList.World, i)
      end
    end
    saveLocalGameDataBykey("chatRecordList", chatRecordList)
    if chatLayer.Instance~=nil then
        chatLayer.Instance:onPushVideoChat(result)
    end

  elseif commandId == CMD_SENT_OFFLINE_MSG then --离线私聊消息
    --这个接口已经整合到登陆的时候请求的接口中
    -- chatOffLineMsg = data
    -- for i=1,#chatOffLineMsg do
    --   table.insert(chatRecordList.Private, 1, chatOffLineMsg[i])
    -- end
    -- if #chatRecordList.Private>15 then --最多保存15条
    --   for i=16,#chatRecordList.Private do
    --     table.remove(chatRecordList.Private, i)
    --   end
    -- end
    -- saveLocalGameDataBykey("chatRecordList", chatRecordList)

  elseif commandId == CMD_GETSHOPINFO then --获取商品信息
    if g_thisIsOtherTime then
      otherTimeData = data
      otherTimeData["pointTs"] = getSrvPointTimeTs(getCurPointTime())
      if g_shopType==1 then
        saveLocalGameDataBykey("107GoodsInfo",otherTimeData)
      elseif g_shopType==4 then
        saveLocalGameDataBykey("shopGoodsInfo",otherTimeData)
      end
      return
    end
    shopGoodsInfo = data
    g_shopPointTs = getSrvPointTimeTs(getCurPointTime())
    shopGoodsInfo["pointTs"] = g_shopPointTs
    
    if g_shopType==1 then
      saveLocalGameDataBykey("shopGoodsInfo",shopGoodsInfo)
    elseif g_shopType==2 then
      saveLocalGameDataBykey("PVPShopGoodsInfo",shopGoodsInfo)
    elseif g_shopType==3 then
      saveLocalGameDataBykey("legionShopGoodsInfo",shopGoodsInfo)
    elseif g_shopType==4 then
      saveLocalGameDataBykey("107GoodsInfo",shopGoodsInfo)
    elseif g_shopType==5 then
      saveLocalGameDataBykey("ExpeditionGoodsInfo",shopGoodsInfo)
    end
    print("g_shopPointTs:"..g_shopPointTs)

    

  elseif commandId == CMD_SWEEP then --扫荡获取物品数据
    blockSweepData = data
    

  elseif commandId == CMD_UPGRADE_LEVEL then --角色等级提升推送
    --人物战车属性的标志位恢复
    RoleManager.isReqFlag = true
    CarManager.isReqFlag = true
    -- EmbattleMgr.isReqFlag  = true

    print("CMD_UPGRADE_LEVEL")
    local oldSkl = srv_userInfo.sklPoint
    srv_userInfo.level = data.newLevel
    srv_userInfo.sklPoint = data.sklPoint
    srv_userInfo.exp = data.exp
    if display.getRunningScene().level then
      display.getRunningScene().level:setString(srv_userInfo["level"])
    end

    
    RentMgr:InitWithLocalData()   --凡是角色升级，都要把租车重新排序

    DCAccount.setLevel(data.newLevel)
    if data.newLevel-data.level==1 and 
      (data.newLevel==10 or                  --战队10级，引导升级技能
        data.newLevel==12 or                 --战队12级，引导成就任务
        data.newLevel==14 or                 --战队14级，精英副本
        data.newLevel==15 or                 --战队15级，改造中心，觉醒
        data.newLevel==16 or                 --战队16级，竞技场
        data.newLevel==20 or                 --战队20级，用户中心，遗迹探测
        data.newLevel==25 or                 --战队25级，远征
        data.newLevel==28                    --战队30级，用户中心，军团
        ) then       
      print("此处有引导，强制转回主界面")
      if GuideManager.NextLocalStep == 20101 or GuideManager.NextLocalStep == 20301 or GuideManager.NextLocalStep == 20406 then
            GuideManager.NextLocalStep = 0
        end
        if data.newLevel==10 then
          if GuideManager.NextStep==12101 then
            MainSceneEnterType = EnterTypeList.NORMAL_ENTER
          end
        elseif data.newLevel==12 then
          if GuideManager.NextStep==12201 then
            MainSceneEnterType = EnterTypeList.NORMAL_ENTER
          end
        else
          MainSceneEnterType = EnterTypeList.NORMAL_ENTER
        end
      
      if MainScene_Instance then
        teamUpgrade:createUpgradeBox(data.level,data.newLevel, oldSkl,function ( ... )
          MainScene_Instance:clearMainscene(true)
        end)
      else
        teamUpgrade:createUpgradeBox(data.level,data.newLevel, oldSkl)
        -- app:enterScene("LoadingScene", {SceneType.Type_Main})
      end
      if data.newLevel==10 then
        bTaskLayerOpened = false
      end
    else
      teamUpgrade:createUpgradeBox(data.level,data.newLevel, oldSkl)
    end

    --升到指定级数后出发任务
    local taskLevel = 5
    if taskLevel>data.level and taskLevel<=data.newLevel then
      print("五级升级，发送活动通知")
      local comData={}
      comData["tgtType"] = 41
      comData["cnt"] = 1
      m_socket:SendRequest(json.encode(comData), CMD_REFRESH_TASK, nil, nil)
    end

    --解锁主界面图标
    if MainScene_Instance then
      if data.newLevel>=28 then
        MainScene_Instance.activityMenuBar.legionBt:removeChildByTag(11)
      end
      if data.newLevel>=16 then
        MainScene_Instance.roleMenuBar.ArenaBt:removeChildByTag(11)
      end
    end
    if isKURUILogin then
        KuRuiSDK:KuRuiUpRoloInfo(KuRuiRoleInfoType.KuRui_levelUp)
    end

  elseif commandId == CMD_BROADCAST then --广播
    local tmp = {}
    tmp.msg = data.msg
    tmp.finish = false
    table.insert(g_BroadCastMsg, data.msg)
    -- print(MainScene_Instance)
    -- print(broadcast.Instance)
    -- if MainScene_Instance and broadcast.Instance then
    --   broadcast.Instance:onBroadCast()
    -- end
    --发送世界消息
    -- local osDate = os.date()
    -- osDate = "//"..osDate
    local chatData = {}
    chatData.senderTmpId = 10000
    chatData.type = 3
    chatData.time = data.time
    chatData.senderCId = 1000000
    chatData.senderLevel = "99"
    chatData.senderName = "小助手"
    chatData.msg = data.msg
    -- printTable(chatData)
    table.insert(chatRecordList.World, 1, chatData)
    if #chatRecordList.World>15 then --最多保存15条
      for i=16,#chatRecordList.World do
        table.remove(chatRecordList.World, i)
      end
    end
    saveLocalGameDataBykey("chatRecordList", chatRecordList)
    if chatLayer.Instance~=nil then
        chatLayer.Instance:onPushWorldChat(result)
    end
    
  elseif commandId == CMD_LOGIN_OTHERPLACE then --角色在其他地方登陆推送
    showMessageBox(result.msg, nil,nil,function()
        app:enterScene("LoginScene")
        if GuideManager.NextStep  ~= 0 then
            GuideManager.NextStep  = 0
        end
        if GuideManager.NextLocalStep  ~= 0 then
            GuideManager.NextLocalStep  = 0
        end
    end)
  elseif commandId == CMD_TASK_INIT then --任务初始化
        TaskMgr:OnInitInfoRet(result)
        AchMgr:OnStatusPush(result)  --摘取成就任务部分
  elseif commandId == CMD_TASK_UPDATE then --任务推送
        TaskMgr:OnUpdateInfoRet(result)
  elseif commandId == CMD_MAIL_INIT then --邮件初始化
        MailMgr:InitByCmd(result)
  elseif commandId == CMD_MAIL_UPDATE then --邮件更新
        MailMgr:AddNewMail(result)
  elseif commandId == CMD_GET_ENERGY then
      if 1==cmd.result then
          SetEnergyAndCountDown(cmd.data.energy, cmd.data.eCountDown)
      else
    
      end
  elseif commandId == CMD_LEGION_TAXIPUSH then
    -- RentMgr:InitRentByCmd(result)一开始是推送，现在改成主动请求
  elseif commandId == CMD_TAXI_RECORDPUSH then
    RentMgr:OnRentRecordPush(result)
  elseif commandId == CMD_LEGION_TAXI_ONOFF then
    RentMgr:OnRentOnOffPush(result)
  elseif commandId == CMD__MYTAXI_ISRENTED then
    if rentCarListLayer.Instance~=nil then
      rentCarListLayer.Instance:myTaxiIsRented(result)
    end

  elseif commandId == CMD_TASK_RESIGNIN then --补签
    srv_userInfo.diamond = srv_userInfo.diamond - 1
    mainscenetopbar:setDiamond()
    --数据统计
    luaStatBuy("签到", BUY_TYPE_CHECKIN, 1, "钻石", 1)
  elseif commandId == CMD_BOSS_CHANGE_CAR_PUSH  or commandId == CMD_BOSS_CHANGE_CAR then 
    if worldBossInstance~=nil then
      worldBossInstance:OnUpdateCarRet(result)
    end
  elseif commandId == CMD_BOSS_MATCH_RCEVIVE then 
    if worldBossInstance~=nil then
      worldBossInstance:receiveHelpMsgPush(result)
    elseif MainScene_Instance~=nil then
      MainScene_Instance:receiveHelpMsgPush(result)
    end
  elseif commandId == CMD_BOSS_SOMEBODY_AGREE then 
    if worldBossInstance~=nil then
      worldBossInstance:OnHelpMsgPushRet(result)
    end
  elseif commandId == CMD_BOSS_CHAT_PUSH then 
    if worldBossInstance~=nil then
      worldBossInstance:onChatMsgRetPush(result)
    end
  elseif commandId == CMD_BOSS_EXIT_PUSH then 
    if worldBossInstance~=nil then
      worldBossInstance:OnExitTeamPush(result)
  end
  elseif commandId == CMD_BOSS_HELPEND_PUSH then 
    if worldBossInstance~=nil then
      worldBossInstance:OnHelpEndPush(result)
    end
  elseif commandId == CMD_BOSS_HPUPDATE then
    if display.getRunningScene().upDateWorldBossHp ~= nil then
        display.getRunningScene():upDateWorldBossHp(result)
    end
  elseif commandId == CMD_RECHARGE_RET then 
    if RechargeManager then
      RechargeManager:rechargeRet(data)
    end
  end--最外层if..end
end--函数end




--得到物品星级
function getItemStar(tmpId)
  tmpId = tmpId + 0
  local star = math.modf(tmpId/1000)%10
  if star==6 then
    star=5
  end
  return star
end
--战车总星级
function getCarAllStars(carId)
  local allStars = 0
  for key,value in pairs(srv_carEquipment["item"]) do
    local star = getItemStar(value["tmpId"])
    if value["wareMemberId"] == carId and getItemType(value.tmpId)~=103 and getItemType(value.tmpId)~=106 then
      allStars = allStars + star
    end
  end
  return allStars
end
--得到物品类型
function getItemType(tmpId) 
  -- print(tmpId)
  if tmpId==WANMENG_TMPID or tmpId==ITEM_ENERGY then
    return 100 --万能碎片
  else
    return itemData[tmpId].type
  end
  
  -- if math.modf(tmpId%1000/100)==5 then
  --   return 500
  -- else
  --   return math.modf(tmpId/10000)
  -- end
end
--显示星级
-- function showStar(node,starNum)
--   for i=1,5 do
--     local star = cc.uiloader:seekNodeByName(node,"star"..i)
--     star:setVisible(false)
--   end
--   for i=1,starNum do
--     local star = cc.uiloader:seekNodeByName(node,"star"..i)
--     star:setVisible(true)
--   end
-- end 

function itemTypeToString(tmpId)
  local type = getItemType(tmpId) 
  if type == ITEMTYPE_MAINGUN then
    return "主炮"
  elseif type == ITEMTYPE_SUBGUN then
    return "副炮"
  elseif type == ITEMTYPE_SEGUN then
    return "SE炮"
  elseif type == ITEMTYPE_ENGINE then
    return "引擎"
  elseif type == ITEMTYPE_CDEV then
    return "C装置"
  elseif type == ITEMTYPE_TOOL then
    return "工具"
  elseif type == ITEMTYPE_SEBLT then
    return "特种弹"
  elseif type == ITEMTYPE_BUGLE then
    return "军号"
  elseif type == ITEMTYPE_SPECIALBULLET then
    return "特种弹"
  elseif type == ITEMTYPE_WEAPON then
    return "武器"
  elseif type == ITEMTYPE_HAT then
    return "帽子"
  elseif type == ITEMTYPE_CLOTHES then
    return "衣服"
  elseif type == ITEMTYPE_GLOVE then
    return "手套"
  elseif type == ITEMTYPE_SHOES then
    return "鞋子"
  elseif type == ITEMTYPE_ARMOR then
    return "护甲"
  elseif type == 301 then
    return "进阶材料"
  elseif type == 302 then
    return "制造书"
  elseif type == 303 then
    return "职业材料"
  elseif type == 304 then
    return "宝箱"
  elseif type == 305 then
    return "扫荡券"
  elseif type == 306 then
    return "改装材料"
  elseif type == 307 then
    return "战车核心"
  elseif type == 500 or type == 100 then
    return "碎片"
  elseif type == 600 then
    return "材料碎片"
  elseif type==801 then
    return "特效型"
  elseif type==802 then
    return "数量型"
  elseif type==803 then
    return "伤害型"
  else
    return "未知"
  end
end

function getCarEquipments(carId) --获取当前战车装备
  local carEquipments = {} --{"101"="主炮ID","102"="副炮ID",...}

  for key,value in pairs(srv_carEquipment["item"]) do
    local valueType = getItemType(value["tmpId"])
    if value["wareMemberId"] == carId then
      carEquipments[valueType] = key
    end
  end
  --printTable(carEquipments)
  --print(carEquipments)
  return carEquipments
end

--只能获取可叠加的物品
function get_SrvBackPack_Value(tmpId)
  -- print("get_SrvBackPack_Value")
  -- print(tmpId)
  local value, valueCnt = nil, 0 --valueCnt记录不可叠加的物品的数量
  local mType = getItemType(tmpId)
  if mType==500 then
    for key,v in pairs(srv_carEquipment["piece"]) do
      if v.tmpId == tmpId then
        value = v
        valueCnt = value.cnt
        break
      end
    end
  elseif mType>=101 and mType<=106 then --战车装备
    for key,v in pairs(srv_carEquipment["item"]) do
      if v.tmpId == tmpId then
        value = v
        valueCnt = valueCnt + value.cnt
      end
    end
  elseif mType>=201 and mType<=206 then
    for key,v in pairs(srv_carEquipment["memIt"]) do
      if v.tmpId == tmpId then
        value = v
        valueCnt = valueCnt + 1
      end
    end
  else
    for key,v in pairs(srv_carEquipment["bp"]) do
      if v.tmpId == tmpId then
        value = v
        valueCnt = value.cnt
        break
      end
    end
  end

  return value, valueCnt
end

--往背包添加物品接口
function addGoodsToBackPack(value)
  --[[战车物品 type: ['101','102','103','104','105','106']
      背包 type: ['107', '108', '109'] 3开头的消耗品
                            消耗品：107--普通弹  、109--特种弹 、 3开头的道具      可叠加
                            宝具：108     不可叠加
      碎片      type 500
      人物装备  type 201-206
                            --]]
  local mType = getItemType(value.tmpId)
  
  -- print("type:",mType)
  
  if mType==500 then --碎片
    -- print("添加碎片--")
      if srv_carEquipment["piece"][value["id"]]==nil then
        srv_carEquipment["piece"][value["id"]]=value
        -- srv_carEquipment["piece"][value["id"]].cpdTmpId = value.tmpId - 500
        
      else
        local count = srv_carEquipment["piece"][value["id"]]["cnt"]
        local newCount = value["cnt"]
        srv_carEquipment["piece"][value["id"]]["cnt"] = count+newCount
      end
  elseif (mType>=101 and mType<=106) then --战车装备
    -- print("添加战车装备--")
    if value.advLvl==nil then value["advLvl"]=1 end
    if value.isLocked==nil then value["isLocked"]=0 end
    if value.wareMemberId==nil then value["wareMemberId"]=0 end
    if value.wareTmpId==nil then value["wareTmpId"]=0 end
    srv_carEquipment["item"][value["id"]] = value
  elseif mType>=201 and mType<=206 then
    -- print("添加人物装备--")
    if value.advLvl==nil then value["advLvl"]=1 end
    if value.memTmpId==nil then value["memTmpId"]=0 end
    srv_carEquipment["memIt"][value["id"]] = value
  else
    -- print("添加背包--")
    if mType==600 or mType==700 or math.modf(mType/100)==7 or mType==107 or mType==108 or mType==801 or mType==802 or mType==803 or mType==100 or math.modf(mType/100)==3 or math.modf(mType/100)==4 then --消耗品（可叠加）
      -- print("消耗品")
      if srv_carEquipment["bp"][value["id"]]==nil then
        srv_carEquipment["bp"][value["id"]]=value
      else
        local count = srv_carEquipment["bp"][value["id"]]["cnt"]
        local newCount = value["cnt"]
        srv_carEquipment["bp"][value["id"]]["cnt"] = count+newCount
        -- if value.tmpId==3052001 then
        --   print(count)
        --   print(newCount)
        --   print("newCount="..srv_carEquipment["bp"][value["id"]]["cnt"])
        -- end
      end
    elseif mType==108 or mType==801 or mType==802 or mType==803  then --军号（不可叠加）
      -- print("军号")
      srv_carEquipment["bp"][value["id"]]=value
    end
  end
  -- printTable(srv_carEquipment)
  -- printTable(value)
end
function removeItemFromBackPack(value)
  local mType = getItemType(value.tmpId)
  if mType>=101 and mType<=106 then --战车装备
    -- print("删除战车装备--")
    srv_carEquipment["item"][value["id"]] = nil
  elseif mType==500 then --碎片
    -- print("删除碎片--")
    if value.cnt<=0 then
      srv_carEquipment["piece"][value["id"]] = nil
    else
      srv_carEquipment["piece"][value["id"]].cnt = value.cnt
    end
    
  elseif mType>=201 and mType<=206 then
    -- print("删除人物装备--")
    srv_carEquipment["memIt"][value["id"]] = nil
  else
    -- print("删除背包--")
    if mType==600 or mType==700 or math.modf(mType/100)==7 or mType==107 or mType==108 or mType==801 or mType==802 or mType==803 or mType==100 or math.modf(mType/100)==3 or math.modf(mType/100)==4 then --消耗品（可叠加）
      -- print("消耗品")
      if value.cnt<=0 then
        srv_carEquipment["bp"][value["id"]] = nil
      else
        srv_carEquipment["bp"][value["id"]].cnt = value.cnt
      end
      -- if value.tmpId==3052001 then
      --   print(value.cnt)
      --   -- print("newCount2="..srv_carEquipment["bp"][value["id"]]["cnt"])
      -- end
    elseif mType==108 or mType==801 or mType==802 or mType==803 then --军号（不可叠加）
      -- print("军号")
      srv_carEquipment["bp"][value["id"]]=nil
    end
  end
  -- printTable(value)
end
function updateItemFromBackPack(value)
  if value.templateId~=nil then
    value.tmpId = value.templateId
  end
  local mType = getItemType(value.tmpId)
  if mType>=101 and mType<=106 then --战车装备
    if value.advLvl~=nil then srv_carEquipment["item"][value["id"]].advLvl = value.advLvl end
    if value.tmpId~=nil then srv_carEquipment["item"][value["id"]].tmpId = value.tmpId end
    if value.isLocked~=nil then srv_carEquipment["item"][value["id"]].isLocked = value.isLocked end
    if value.wareMemberId~=nil then srv_carEquipment["item"][value["id"]].wareMemberId = value.wareMemberId end
    if value.wareTmpId~=nil then srv_carEquipment["item"][value["id"]].wareTmpId = value.wareTmpId end

  elseif mType==500 then --碎片
    if value.advLvl~=nil then srv_carEquipment["piece"][value["id"]].advLvl = value.advLvl end
    if value.tmpId~=nil then srv_carEquipment["piece"][value["id"]].tmpId = value.tmpId end
    
  elseif mType>=201 and mType<=206 then
    if value.advLvl~=nil then srv_carEquipment["memIt"][value["id"]].advLvl = value.advLvl end
    if value.tmpId~=nil then srv_carEquipment["memIt"][value["id"]].tmpId = value.tmpId end
    if value.memTmpId~=nil then srv_carEquipment["memIt"][value["id"]].memTmpId = value.memTmpId end

  else
    print("其他物品更改，未处理！")
  end
end

--修改更新关卡的服务端数据
function modify_srv_blockData(blockId,star,cnt)
  -- print("blockId:"..blockId..",star:"..blockId)
  if tonumber(string.sub(tostring(blockId),1,1)) >= 4 then
      --活动副本不做处理
      return
  end
  if cnt==nil then
    cnt=1
  end
  if star>srv_blockData[blockId].star then
    srv_blockData[blockId].star = star 
  end

  if star>0 then
    srv_blockData[blockId].dayCount = srv_blockData[blockId].dayCount+cnt
  end
    

    --更新当前进度关卡
    local curAreaIdx = math.modf(blockId/1000)%1000
    local maxAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
    local maxAreaEIdx = math.modf(srv_userInfo["maxEBlockId"]/1000)%1000
    if blockData[blockId].type==1 then
      if curAreaIdx>maxAreaIdx then
        srv_userInfo["maxBlockId"] = blockId
      elseif curAreaIdx==maxAreaIdx and blockId%1000>srv_userInfo["maxBlockId"]%1000 then
        if star>0 then
          srv_userInfo["maxBlockId"] = blockId
        end
      end
    elseif blockData[blockId].type==2 then
      if curAreaIdx>maxAreaEIdx then
        srv_userInfo["maxEBlockId"] = blockId
      elseif curAreaIdx==maxAreaEIdx and blockId%1000>srv_userInfo["maxEBlockId"]%1000 then
        if star>0 then
          srv_userInfo["maxEBlockId"] = blockId
        end
      end
    end

    curFightBlockId=nil
    -- curFightBlockId = blockId
    curFightBlockId = blockId
    -- if star>0 then
    --   curFightBlockId = blockId
    -- else
    --   if blockData[blockId].type==1 then
    --     curFightBlockId = srv_userInfo["maxBlockId"]
    --   else
    --     curFightBlockId = srv_userInfo["maxEBlockId"]
    --   end
      
    -- end
    
    -- if blockId~=srv_userInfo["maxBlockId"] and srv_userInfo["maxEBlockId"] then --如果不是最新关卡（普通或精英），记住刚刚打过的关卡
    --   curFightBlockId = blockId
    -- end
    mapAreaId = srv_userInfo["areaId"]

    -- MainSceneEnterType = EnterTypeList.FIGHT_ENTER
end
--判断大区是否能进入
function canAreaEnter(areaId,blockType)
    -- print("canAreaEnter")
    -- print(areaId)
    -- print(srv_userInfo["maxBlockId"])
    -- print(blockType)
    -- if srv_userInfo.level < areaData[areaId].level then
    --   return false
    -- end
    if blockType==3 then blockType=1 end
    if areaData[areaId].isOpen==0 then
      return false
    end
    if areaId<10001 then
      return false
    end

    local curBlocksData = getCurAreaBlocksData(areaId-1)

    local areaIdx = areaId%1000 --余数
    local curAreaIdx = 0
    local curBlockIdx = 0
    if blockType==nil then
      curAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
      curBlockIdx = srv_userInfo["maxBlockId"]%1000
    else
      if blockType==1 then --普通
          curAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
          curBlockIdx = srv_userInfo["maxBlockId"]%1000
      elseif blockType==2 then --精英
        if srv_userInfo["maxEBlockId"]==0 then
          if canAreaEnter(10002, 1) then
            curAreaIdx = 1
          else
            curAreaIdx = 0
          end
          
        else
          curAreaIdx = math.modf(srv_userInfo["maxEBlockId"]/1000)%1000
          curBlockIdx = srv_userInfo["maxEBlockId"]%1000
        end
      end
    end

    -- print("curAreaIdx:"..curAreaIdx)
    -- print("areaIdx:"..areaIdx)

    if areaIdx<=curAreaIdx then
      -- print("aa")
        return true
    end
    -- print("maxBlockId:"..srv_userInfo["maxBlockId"])
    -- print(curAreaIdx)
    -- print(areaIdx)
    
    -- print(areaId)
    -- printTable(curBlocksData)
    local maxIdx = curBlockIdx
    for i,value in ipairs(curBlocksData) do --计算本大区最后一关索引值
      if value.id%1000>maxIdx and blockData[value.id].mainLine==1 then
        maxIdx = value.id%1000
        -- print(maxIdx)
      end
    end
    -- local maxIdx = curBlocksData[#curBlocksData].id%1000
    -- print("------")
    -- print(maxIdx)
    -- print(curBlockIdx)
    if maxIdx==curBlockIdx and (areaIdx-curAreaIdx)==1 then--判断该关卡是否是本大区最后一关
      -- print("bb")
        --如果打到该大区精英关卡最后一关，则可以进入下一大区，但是如果下一大区普通关卡尚未通过则不能进入
        local tmpAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
        local  tmpBlockIdx = srv_userInfo["maxBlockId"]%1000
        local maxIdx = tmpBlockIdx
        -- print(areaIdx)
        -- print(tmpAreaIdx)
        -- print(curAreaIdx)
        -- print("*****")
        if (curAreaIdx+1)==tmpAreaIdx then --
          for i,value in ipairs(curBlocksData) do
            if value.id%1000>maxIdx and blockData[value.id].mainLine==1 then
              maxIdx = value.id%1000
            end
          end
          -- print(maxIdx)
          -- print(tmpBlockIdx)
          if maxIdx>tmpBlockIdx then --判断是否普通关卡通过
            -- print("fff")
            return false --如果未通过则false
          end
        end

        return true
    else
      -- print("ccc")
        return false
    end

    -- print("ddd")
    return false
end

--军团副本是否可以进入
function canLegionAreaEnter(areaId)
  local areaIdx = areaId%1000 --余数
  local curAreaIdx = math.modf(srv_userInfo["maxBlockId"]/1000)%1000
  local curBlockIdx = srv_userInfo["maxBlockId"]%1000

  if areaIdx<curAreaIdx then
    -- print("aa")
      return true
  elseif areaIdx>curAreaIdx then
    -- print("bbbb")
    return false
  elseif areaIdx==curAreaIdx then
    local curBlocksData = getCurAreaBlocksData(areaId-1)
    local maxIdx = curBlockIdx
    for i,value in ipairs(curBlocksData) do --计算本大区最后一关索引值
      if value.id%1000>maxIdx and blockData[value.id].mainLine==1 then
        maxIdx = value.id%1000
        -- print(maxIdx)
      end
    end
    -- print(maxIdx)
    -- print(curBlockIdx)
    if maxIdx==curBlockIdx then
      return true
    else
      -- print("ccc")
      return false
    end
  end

end

--是否是本大区的最后一关
function isAreaLastBlock(areaId, blockId)
  -- local areaId = blockIdtoAreaId(blockId)
  local curBlocksData = getCurAreaBlocksData(areaId)
  -- print(blockId)
  -- print(curBlocksData[#curBlocksData].id)
  if blockId==curBlocksData[#curBlocksData].id then
    return true
  else
    return false
  end
end
--获取扫荡券
function getSweepValue()
  for i,value in pairs(srv_carEquipment["bp"]) do
    if value.tmpId==SWEEP_TMPID then
      return value
    end
  end
  return nil
end
--获取万能碎片
function getWanNengPiece()
  for i,value in pairs(srv_carEquipment["bp"]) do
    if value.tmpId==WANMENG_TMPID then
      -- print("万能在此")
      return value
    end
  end
  return nil
end
function getPieceCombination(itTmpId)
  local pieceTable = {}
  pieceTable.itTmpId = itTmpId
  -- print(combinationData[itTmpId])
  if combinationData[itTmpId] == nil then
    pieceTable.result = 0
    return pieceTable --合成表没有配数据
  end
  -- print(itTmpId)
  local pieceArr=lua_string_split(combinationData[itTmpId].piece,":")
  -- local pieceData
  -- for i=1,#pieceArr do
  --   pieceData[i] = 
  -- end

  -- print(pieceArr[2])
  pieceTable.pieceTmpId = pieceArr[1]+0
  pieceTable.needPiece = pieceArr[2]+0 --需要的碎片数
  pieceTable.pieceCnt=0  --该装备碎片
  for k,v in pairs(srv_carEquipment["piece"]) do
    if v.tmpId==pieceTable.pieceTmpId then
      pieceTable.pieceCnt = v.cnt
      pieceTable.value = v
      break
    end
  end

  pieceTable.maxOmniCount = combinationData[itTmpId].maxOmniCount --最多能用万能碎片
  local wanNengPiece = getWanNengPiece()
  if wanNengPiece==nil then
    pieceTable.universalPieceNum=0
  else
    pieceTable.universalPieceNum = wanNengPiece["cnt"] --万能碎片个数
  end
  if pieceTable.maxOmniCount>pieceTable.universalPieceNum then
    pieceTable.maxOmniCount=pieceTable.universalPieceNum
  end

  if pieceTable.pieceCnt==0 then
    pieceTable.result = 0
    return pieceTable --装备没有一个碎片
  end
  
  
  pieceTable.canUsePiece = pieceTable.pieceCnt + math.min(pieceTable.universalPieceNum,pieceTable.maxOmniCount) --可用于合成的碎片数 

  if pieceTable.canUsePiece < pieceTable.needPiece then
    pieceTable.result = 1
    return pieceTable --有碎片，但不够合成
  elseif pieceTable.canUsePiece >= pieceTable.needPiece then
    pieceTable.result = 2
    return pieceTable --有足够碎片可以合成
  else
    pieceTable.result = -1
    return pieceTable
  end

end
function getCpdTmpId(pieceTmpId)
  for cpdTmpId,value in pairs(combinationData) do
    local pieceArr=lua_string_split(value.piece,":")
    if (pieceArr[1]+0)==pieceTmpId then
      return cpdTmpId
    end
  end
end

function getStengthGold(value)
  local gold
  local star = getItemStar(value.tmpId)
  local itType = getItemType(value.tmpId)
  local strName
  if itType==101 then
    strName = "main_"..star.."_gold"
  elseif itType==102 then
    strName = "sub_"..star.."_gold"
  elseif itType==103 then
    strName = "se_"..star.."_gold"
  elseif itType==104 then
    strName = "eng_"..star.."_gold"
  elseif itType==105 then
    strName = "cDev_"..star.."_gold"
  elseif itType==106 then
    strName = "main_"..star.."_gold"
  end

  gold = strengthData[value.advLvl][strName]
  return gold
end

--按顺序排好的大区关卡信息
function getCurAreaBlocksData(areaId)
  -- print("getCurAreaBlocksData--------------------")
  local areaIdx = math.fmod(areaId,1000)
  local curBlockData = {}
  local i=0
  for k,value in pairs(blockData) do --按顺序的当前区关卡信息
    -- print(k)
    local Aidx = math.fmod(math.modf(value.id/1000),1000)
    local firstNum = math.floor(value.id/10000000)
    -- print("Aidx:"..Aidx)
    if Aidx==areaIdx and firstNum<=3 then
      -- print(k)
      i=i+1
      curBlockData[i] = value
    end
  end

  --排序
  local function sortfunc(a,b)
        if math.modf(a.id/10000000)==math.modf(b.id/10000000) then
          return a.id%1000<b.id%1000  --当a应该排在b前面时, 返回true, 反之返回false.
        else
          return math.modf(a.id/10000000)<math.modf(b.id/10000000)
        end
    end

    table.sort(curBlockData,sortfunc)
  -- printTable(curBlockData)
  -- print("aa")
  return curBlockData
end
--排序大区信息
function getSortAreaData()
  local newAreaData = {}
  local i=0
  for k,value in pairs(areaData) do --按顺序的当前区关卡信息
      i=i+1
      newAreaData[i] = value
  end
  --排序
  local function sortfunc(a,b)
    return math.modf(a.id)<math.modf(b.id)
  end

  table.sort(newAreaData,sortfunc)
  -- printTable(curBlockData)
  -- print("aa")
  return newAreaData
end
--将指定的block排序
function getSortBlocksData(blocksData) 
  local curBlockData = {}
  for k,value in pairs(blocksData) do --按顺序的当前区关卡信息
      curBlockData[k] = blockData[value]
      -- print(blockData[value].id)
  end
  -- printTable(blocksData)
  --排序
  local function sortfunc(a,b)
    
        if math.modf(a.id/1000)%1000==math.modf(b.id/1000)%1000 then
          if math.modf(a.id/10000000)==math.modf(b.id/10000000) then
            return a.id%1000<b.id%1000  --当a应该排在b前面时, 返回true, 反之返回false.
          else
            return math.modf(a.id/10000000)<math.modf(b.id/10000000)
          end
        else
          return math.modf(a.id/1000)%1000<math.modf(b.id/1000)%1000 --按区排序
        end
  end

    table.sort(curBlockData,sortfunc)
  -- printTable(curBlockData)
  -- print("aa")
  return curBlockData
end

function getSendAreaList(areaId)
  local areaList
  -- if areaData[areaId-1]==nil then
  --   areaList = "0|"
  -- else
  --   areaList = (areaId-1).."|"
  -- end
  -- areaList = areaList..areaId
  
  -- if areaData[areaId+1]~=nil then
  --   areaList =areaList.."|"..(areaId+1)
  -- else
  --   areaList =areaList.."|0"
  -- end
  areaList = "0|"..areaId.."|0"
  print(areaList)
  return areaList

end

function ReqLatestEnergy()
  local tabMsg = {characterId=srv_userInfo.characterId}
  m_socket:SendRequest(json.encode(tabMsg), CMD_GET_ENERGY, mainscenetopbar, mainscenetopbar.OnLatestEnergyRet)
end

--5分钟的倒计时
local function EnergySchedulerCallBack1()
  srv_userInfo["energy"] = srv_userInfo["energy"]+1
  if nil~=mainscenetopbar then
    mainscenetopbar:setEnergy()
  end

  local nMaxEnergy = memberLevData[srv_userInfo["level"]].energy
  local nCurEnergy = srv_userInfo["energy"]
  if nCurEnergy>=nMaxEnergy then
    g_SchedulerMgr:unscheduleGlobal("energy")
    srv_userInfo["eCountDown"] = 300
  end
end

--不足5分钟的倒计时
local function EnergySchedulerCallBack2()
  srv_userInfo["energy"] = srv_userInfo["energy"]+1
  if nil~=mainscenetopbar then
    mainscenetopbar:setEnergy()
  end

  g_SchedulerMgr:unscheduleGlobal("energy")
  local nMaxEnergy = memberLevData[srv_userInfo["level"]].energy
  local nCurEnergy = srv_userInfo["energy"]
  if nCurEnergy>=nMaxEnergy then
    srv_userInfo["eCountDown"] = 300
  else
    g_SchedulerMgr:scheduleGlobal("energy", EnergySchedulerCallBack1, 300)
  end
end

--是否开启体力定时器
local function IfSchedulerEnergy()
  local nMaxEnergy = memberLevData[srv_userInfo["level"]].energy
  local nCurEnergy = srv_userInfo["energy"]
  if nCurEnergy>=nMaxEnergy then
    g_SchedulerMgr:unscheduleGlobal("energy")
    srv_userInfo["eCountDown"] = 300
  else
    if srv_userInfo["eCountDown"]<300 then
      g_SchedulerMgr:scheduleGlobal("energy", EnergySchedulerCallBack2, srv_userInfo["eCountDown"])
    else
      g_SchedulerMgr:scheduleGlobal("energy", EnergySchedulerCallBack1, 300)
    end
  end
end

--设置体力和倒计时
function SetEnergyAndCountDown(energy, countDown)
  if nil~=energy then
    srv_userInfo["energy"] = energy
  end

  if nil~=countDown then
    srv_userInfo["eCountDown"] = countDown
  end

  if nil~=mainscenetopbar then
    if mainscenetopbar.setEnergy~=nil then
      mainscenetopbar:setEnergy()
    end
  end

  IfSchedulerEnergy()
end
--获取合成碎片的数量Label
function getComNumPer(tmpId,needNum)
  local cnt
  local value = get_SrvBackPack_Value(tmpId)
  if value==nil then
    cnt = 0
  else
    cnt = value.cnt
  end
  local numPer = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20})
  numPer:setString(cnt.."/"..needNum)
  numPer:setAnchorPoint(0.5,0.5)
  if cnt<needNum then
    numPer:setColor(cc.c3b(255, 46, 0))
  else
    numPer:setColor(cc.c3b(121, 229, 99))
  end
  return numPer
end
--比较关卡大小，（获取副本链接，未打过的不能跳转）
function bCpBlock(block1,block2)
  -- print("blockId:"..block1)
  if block2==nil then
    if math.modf(block1/10000000)<2 then
      block2 = srv_userInfo.maxBlockId or 0
    else
      block2 = srv_userInfo.maxEBlockId or 0
    end
  end
  if blockIdtoAreaId(block1)<blockIdtoAreaId(block2) then
    return true
  elseif blockIdtoAreaId(block1)>blockIdtoAreaId(block2) then
    -- print("false3")
    return false
  elseif blockIdtoAreaId(block1)==blockIdtoAreaId(block2) then
    if math.fmod(block1,1000)>math.fmod(block2,1000) then
      -- print("false2")
      return false
    end
  end
  return true
end
function getPieceByTmpId()
    local itemTable = {}
    for i,value in pairs(srv_carEquipment["piece"]) do
        itemTable[value.tmpId] = value
    end
    return itemTable
end
--判断装备是否可合成
function bAllEquipmentCanCom(mtype)

  local comItem = {}
  for i,value in pairs(combinationData) do
      local mType2 = getItemType(i)
      if mtype~=nil and mType2==mtype then
        -- print("aaaaaa")
        table.insert(comItem,value)
      elseif mtype==nil and (mType2==101 or mType2==102 or mType2==104 or mType2==105) then
        -- print("bbbbbbbb")
        table.insert(comItem,value)
      end
  end
  for i=1,#comItem do
    local lcoalItem = comItem[i]
    -- local pieceArr=lua_string_split(lcoalItem.piece,":")
    -- local peiceByTmpid = {}
    -- peiceByTmpid = getPieceByTmpId()
    -- local curPieceNum
    -- if peiceByTmpid[pieceArr[1]+0]==nil then
    --     curPieceNum = 0 
    -- else
    --     curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
    -- end
    -- print(lcoalItem.compoundId)
    local piceCombiData = getPieceCombination(lcoalItem.compoundId)
    -- local per = (curPieceNum + piceCombiData.maxOmniCount)/pieceArr[2]
    if piceCombiData.result==2 then
      -- print(lcoalItem.compoundId)
      return true
    end
  end
  return false
end
--判断装备是否可进阶（材料和金币都满足）
function bItemCanAdvance(tmpId)
  -- print("bItemCanAdvance tmpId:"..tmpId)
  if getItemType(tmpId)==103 or getItemType(tmpId)==106 then
    return false
  end
  local localValue = itemData[tmpId]

  local advanced = advancedData[localValue.id]
  if advanced==nil then
    return false
  end

  if srv_userInfo.gold < advanced.gold then
    return false
  end

  local StuffArr=lua_string_split(advanced.stuff,"|")
  --材料一
  local Stuff1=lua_string_split(StuffArr[1],"#")
  local StuffValue1 = get_SrvBackPack_Value(Stuff1[1]+0)
  if StuffValue1==nil or StuffValue1.cnt<(Stuff1[2]+0) then
    return false
  end

  --材料二
  if #StuffArr==2 then
    local Stuff2=lua_string_split(StuffArr[2],"#")
    local StuffValue2 = get_SrvBackPack_Value(Stuff2[1]+0)
    if StuffValue2==nil or StuffValue2.cnt<(Stuff2[2]+0) then
      return false
    end
  end
  
  return true
end

--获取已装备的装备
function getBeEquippedItem()
  local tmpTab = {}
  for key,value in pairs(srv_carEquipment["item"]) do
    if getItemType(value.tmpId)~=103 and getItemType(value.tmpId)~=106 and value.wareTmpId~=0 then
      table.insert(tmpTab, value)
    end
  end
  return tmpTab
end
--是否是新获得的物品
function isNewItem(val)
  local isnew = true
  local mType = getItemType(val.tmpId)


  if (mType<201 or mType>206) and isnew then
    print("获得新物品")
    g_BPNewItems[val.id] = val
    -- table.insert(g_BPNewItems, val)
    if MainScene_Instance then
      MainScene_Instance:refreshEquipmentRedPoint()
    end
  end
end

--心跳检测
function HeartBeatCheck()
  if m_socket then
    print("心跳检测")
    g_isSendBeat = true
    local comData={}
    m_socket:SendRequest(json.encode(comData), CMD_HEARTBEAT, m_socket, m_socket.HeartBeatResult)
  else
    g_isSendBeat = false
  end
end
--在线活动定时器监听
function playerOnline()
  if m_socket then
    local comData={}
    comData["tgtType"] = 42
    comData["cnt"] = 1
    m_socket:SendRequest(json.encode(comData), CMD_REFRESH_TASK, nil, nil)
  end
  
end

--重新刷新所有任务
function reInitAllTask()
  if TaskMgr ~=nil then
    local comData={}
    print("-----------------------------------重新刷新所有任务")
    m_socket:SendRequest(json.encode(comData), CMD_TASK_RE_INIT, TaskMgr, TaskMgr.OnInitInfoRet)
  end
end

--重新刷新所有邮件
function reInitAllMail()
  if TaskMgr ~=nil then
    local comData={}
    print("-----------------------------------重新刷新所有邮件")
    m_socket:SendRequest(json.encode(comData), CMD_MAIL_RE_INIT, MailMgr, MailMgr.InitByCmd)
  end
end