--
-- Author: xiaopao
-- Date: 2014-09-24 07:11:35
--

if cc.FileUtils:getInstance():isFileExist("app/utils/afterVersionCode3.lua") then
  require("app.utils.afterVersionCode3")
end

local SocketNet = require("app.net.SocketNet")
local armatureDataMgr = ccs.ArmatureDataManager:getInstance()

local LoadLayer = nil
local messageBoxLayer = nil
local connectPanel = nil
local RechargeLoadLayer = nil

local GlobalFunc = {}

function GlobalFunc.connectSocketServer(hostIp, hostPort)
  if not m_socket  then
    print("new socket")
    m_socket = SocketNet.new(hostIp,hostPort)
  end
	--m_socket = SocketNet.new(caller,hostIp,hostPort)
  m_socket:connectSocketServer()
  
end


function printTable(lua_table,indent )
  if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and not g_IsDebug then
    return
  end
  indent = indent or 0
  for k, v in pairs(lua_table) do
    if type(k) == "string" then
      k = string.format("%q", k)
    end
    local szSuffix = ""
    if type(v) == "table" then
      szSuffix = "{"
    end
    local szPrefix = string.rep("    ", indent)
    formatting = szPrefix.."["..k.."]".." = "..szSuffix
    if type(v) == "table" then
      print(formatting)
      printTable(v, indent + 1)
      print(szPrefix.."},")
    else
      local szValue = ""
      if type(v) == "string" then
        szValue = string.format("%q", v)
      else
        szValue = tostring(v)
      end
      print(formatting..szValue..",")
    end
  end
end
--分割字符串
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end
    return sub_str_tab;
end

--加载loading
function startLoading()
    if nil~=LoadLayer then
      return
    end
    LoadLayer = display.newLayer()
    :addTo(cc.Director:getInstance():getRunningScene(), 1001)

    local loading = display.newSprite("SingleImg/loading1.png")
    :addTo(LoadLayer)
    :pos(display.cx, display.cy)

    local action = cc.RotateBy:create(1.0, 180)
    loading:runAction(cc.RepeatForever:create(action))

    display.newSprite("SingleImg/loading2.png")
    :addTo(LoadLayer)
    :pos(display.cx, display.cy)

    -- local Gear = display.newSprite("SingleImg/chilun_jia_00.png")
    -- :pos(display.width*0.51,display.height*0.5)
    -- :addTo(LoadLayer)
    
    -- local animation = cc.Animation:create()
    -- for i=0,2 do
    --   animation:addSpriteFrameWithFile("SingleImg/chilun_jia_0"..i..".png")
    -- end
    -- animation:setDelayPerUnit(0.2/3)
    -- Gear:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))

    -- local Wrench = display.newSprite("SingleImg/chilun_banshou.png")
    -- :pos(display.width*0.46,display.height*0.52)
    -- :addTo(LoadLayer)

    -- Wrench:runAction(cc.RepeatForever:create(transition.sequence{
    --                                                                cc.RotateBy:create(0.5, 30),
    --                                                                cc.RotateBy:create(0.5, -30),
    --                                                             }))
   
    -- local loadLabel = cc.ui.UILabel.new({UILabelType = 2, text = "加载中.", size = display.width*0.02, align = cc.ui.TEXT_ALIGN_LEFT,color = display.COLOR_WHITE})
    -- :align(display.CENTER_LEFT,display.width*0.46, display.cy-display.height*0.08)
    -- :addTo(LoadLayer)
    
    -- loadLabel:runAction(cc.RepeatForever:create(transition.sequence{
    --                                                                   cc.DelayTime:create(0.3),
    --                                                                   cc.CallFunc:create(function()
    --                                                                     loadLabel:setString("加载中..")
    --                                                                   end),
    --                                                                   cc.DelayTime:create(0.3),
    --                                                                   cc.CallFunc:create(function()
    --                                                                     loadLabel:setString("加载中...")
    --                                                                   end),
    --                                                                   cc.DelayTime:create(0.6),
    --                                                                   cc.CallFunc:create(function()
    --                                                                     loadLabel:setString("加载中.")
    --                                                                   end),
    --                                                                }))
end

function endLoading()
    if LoadLayer~=nil then
      LoadLayer:removeFromParent()
      LoadLayer = nil
    end
end

--加载充值loading
function startRechargeLoading(_time)
    if nil~=RechargeLoadLayer then
      return
    end
    RechargeLoadLayer = display.newLayer()
    :addTo(cc.Director:getInstance():getRunningScene(), 1001)
    if _time ~= nil then
        RechargeLoadLayer:performWithDelay(function()
            endRechargeLoading()
        end,_time)
    end

    local loading = display.newSprite("SingleImg/loading1.png")
    :addTo(RechargeLoadLayer)
    :pos(display.cx, display.cy)

    local action = cc.RotateBy:create(1.0, 180)
    loading:runAction(cc.RepeatForever:create(action))

    display.newSprite("SingleImg/loading2.png")
    :addTo(RechargeLoadLayer)
    :pos(display.cx, display.cy)
end

function endRechargeLoading()
    if RechargeLoadLayer~=nil then
      RechargeLoadLayer:removeFromParent()
      RechargeLoadLayer = nil
    end
end

--连接框
function  removeConnectPanel()
  if connectPanel ~= nil then
      connectPanel:removeSelf()
      connectPanel = nil
  end
end

function showConnectPanel()
  if connectPanel ~= nil then
      removeConnectPanel()
  end
  connectPanel = display.newSprite("common/dxcl_wer-03.png")
  :pos(display.width/2,display.height/2)
  :addTo(cc.Director:getInstance():getRunningScene(), 1000)
  local circle = display.newSprite("common/dxcl_wer-02.png")
  :pos(connectPanel:getContentSize().width*0.2,connectPanel:getContentSize().height*0.5)
  :addTo(connectPanel)
  circle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.22, 180)))
  display.newSprite("common/dxcl_werw1-01.png")
  :pos(connectPanel:getContentSize().width*0.55,connectPanel:getContentSize().height*0.5)
  :addTo(connectPanel)
  local timeLabel = cc.ui.UILabel.new({
                UILabelType = 2, text = "5", size = connectPanel:getContentSize().height*0.23, align = cc.ui.TEXT_ALIGN_CENTER ,color = display.COLOR_WHITE})
  :align(display.CENTER,connectPanel:getContentSize().width*0.2,connectPanel:getContentSize().height*0.5)
  :addTo(connectPanel)
  timeLabel:runAction(cc.Repeat:create(transition.sequence({          
                                                              cc.DelayTime:create(1),
                                                              cc.CallFunc:create(function()
                                                                  timeLabel:setString(tostring(tonumber(timeLabel:getString() - 1)))
                                                              end)
                                                           }),5))
end

function sceneOnExit()
    if messageBoxLayer ~= nil then
        messageBoxLayer = nil
    end
end

--消息框
function showMessageBox(msg,okListener,cancelListener,oneBtListener,zorder,_title)
    if LoadLayer then
      endLoading()
    end
    
    if isNodeValue(messageBoxLayer) then
        messageBoxLayer:removeSelf()
        messageBoxLayer = nil
    end

    messageBoxLayer = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 128))
    :addTo(cc.Director:getInstance():getRunningScene(), zorder or 998)


    local messageBox = display.newSprite("SingleImg/messageBox/messageBox.png")
    :addTo(messageBoxLayer,0,10)
    :pos(display.cx, display.cy)
    :scale(0.8)
    
    _title = _title or "提  示"
    local titleLbl = display.newTTFLabel{text = _title,size = 45,color = cc.c3b(226,214,141)}
            :addTo(messageBox)
            :pos(messageBox:getContentSize().width/2, messageBox:getContentSize().height-45)

    local msgLabel = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 35, align = cc.ui.TEXT_ALIGN_CENTER, valign= cc.ui.TEXT_VALIGN_CENTER})
    :addTo(messageBox)
    :pos(messageBox:getContentSize().width/2, messageBox:getContentSize().height/2+50)
    msgLabel:setAnchorPoint(0.5,0.5)
    msgLabel:setString(msg)
    msgLabel:setWidth(550)
    msgLabel:setLineHeight(45)

    --确定按钮（单个）
    local msgOKBt = cc.ui.UIPushButton.new({
      normal="SingleImg/messageBox/tip_okBtn.png",
      })
    :addTo(messageBox)
    :pos(messageBox:getContentSize().width/2, 80)
    :onButtonPressed(function(event)
      event.target:setScale(0.95)
      end)
    :onButtonRelease(function(event)
      event.target:setScale(1.0)
      end)
    
    local tmpNode = display.newTTFLabel{text = "确  认",size = 40,color = cc.c3b(58,60,55)}
            :addTo(msgOKBt)
    tmpNode:enableOutline(cc.c4f(177,255,154,255),0.5)


    --确定按钮（双按钮）
    local msgOKBt1 = cc.ui.UIPushButton.new({
      normal="SingleImg/messageBox/tip_okBtn.png",
      })
    :addTo(messageBox)
    :pos(messageBox:getContentSize().width/2, 80)
    :onButtonPressed(function(event)
      event.target:setScale(0.95)
      end)
    :onButtonRelease(function(event)
      event.target:setScale(1.0)
      end)
    
    tmpNode = display.newTTFLabel{text = "确  认",size = 40,color = cc.c3b(58,60,55)}
            :addTo(msgOKBt1)
    tmpNode:enableOutline(cc.c4f(177,255,154,255),0.5)
    --取消按钮
    local cancelBt1 = cc.ui.UIPushButton.new({
      normal="SingleImg/messageBox/tip_close.png",
      })
    :addTo(messageBox)
    :pos(messageBox:getContentSize().width - 10, messageBox:getContentSize().height - 10)
    :onButtonPressed(function(event)
      event.target:setScale(0.95)
      end)
    :onButtonRelease(function(event)
      event.target:setScale(1.0)
      end)


    if okListener~=nil then
      msgOKBt:setVisible(false)
      msgOKBt1:setVisible(true)
      cancelBt1:setVisible(true)
      messageBox.msgOKBt = msgOKBt1
      msgOKBt1:onButtonClicked(function(event)
          okListener()
          messageBoxLayer:removeFromParent()
          messageBoxLayer = nil
          if srv_userInfo.guideStep~=nil then
          end
          print("Remove Box1")
      end)
      cancelBt1:onButtonClicked(function(event)
          if cancelListener ~= nil then
               cancelListener()
          end
          messageBoxLayer:removeFromParent()
          messageBoxLayer = nil
          print("Remove Box2")
      end)
    else
      msgOKBt:setVisible(true)
      msgOKBt1:setVisible(false)
      cancelBt1:setVisible(false)
      messageBox.msgOKBt = msgOKBt
      msgOKBt:onButtonClicked(function(event)
        if oneBtListener~=nil then
          oneBtListener()
        end
        messageBoxLayer:removeFromParent()
        messageBoxLayer = nil
      end)
    end

    return messageBox
end
function getMessageBoxNode()
  return messageBoxLayer:getChildByTag(10)
end
--提示条
function showTips(msg,_color,x, y)
  x = x or display.cx
  y = y or display.cy
    print(msg)
    cc.Director:getInstance():getRunningScene():removeChildByTag(999)
    cc.Director:getInstance():getRunningScene():removeChildByTag(1000)
    local tipLabel = cc.ui.UILabel.new({UILabelType = 2, text = msg, size = 30, color = _color or cc.c3b(255, 255, 255)})
    :addTo(cc.Director:getInstance():getRunningScene(), 1000, 1000)
    :pos(x, y)
    tipLabel:setAnchorPoint(0.5,0.5)

    local tips = display.newScale9Sprite("common/common_box3.png",x, y,cc.size(tipLabel:getContentSize().width+40, 79))
    :addTo(cc.Director:getInstance():getRunningScene(), 999, 999)
    -- :pos(display.cx, display.cy)

    -- local tipLength = tips:getContentSize().width
    -- local tipLabelLength = tipLabel:getContentSize().width
    -- tips:setScaleX((tipLabelLength+100)/tipLength)

    transition.execute(tips, cc.FadeOut:create(1.0), {
      delay = 2.0,
      onComplete = function()
          tips:removeSelf()
      end,
  })
  transition.execute(tipLabel, cc.FadeOut:create(0.8), {
      delay = 2.0,
      onComplete = function()
          tipLabel:removeSelf()
      end,
  })
end


--分割数字
--@tabDigits:位数
function SplitNum(num, tabDigits)
  if "table"~=type(tabDigits) then
    return {num}
  end

  local arrNum = {}
  local strNum = tostring(num)
  local maxLen = string.len(strNum)
  local subStr = nil

  local nBeginPos, nEndPos = 1, 0
  for i=1, #tabDigits do
    nEndPos = nBeginPos+tabDigits[i]-1
    if nEndPos>maxLen then
      nEndPos = maxLen
    end

    subStr = string.sub(strNum, nBeginPos, nEndPos)
    table.insert(arrNum, tonumber(subStr))
    nBeginPos = nEndPos+1

    if nEndPos>=maxLen then
      break
    end
  end

  return arrNum
end

--获取文字单字字节(适用于中英文混合)
--返回所有文字分别占用字节数tab
function GlobalGetWordsBytes(str)
  local bytes = {}
  if nil==str then
    return bytes
  end
  local lenInByte = #str
  local curByte = nil       --单字节
  local byteCount = nil     --字节数
  local nCurIndex = 1

  repeat
    curByte = string.byte(str, nCurIndex)
    byteCount = 1
    if curByte>0 and curByte<=127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    table.insert(bytes, byteCount)
    nCurIndex = nCurIndex + byteCount
  until nCurIndex>lenInByte

  return bytes
end

--获取物品种类字符串
function GetItemTypeStr(nType)
  local strType = "unkonwn"
  if nType==ITEMTYPE_MAINGUN then
    strType = "主炮"
  elseif nType==ITEMTYPE_SUBGUN then
    strType = "副炮"
  elseif nType==ITEMTYPE_SEGUN then
    strType = "SE炮"
  elseif nType==ITEMTYPE_ENGINE then
    strType = "引擎"
  elseif nType==ITEMTYPE_CDEV then
    strType = "C装置"
  elseif nType==ITEMTYPE_TOOL then
    strType = "工具"
  elseif nType==ITEMTYPE_SEBLT then
    strType = "特种弹"
  elseif nType==ITEMTYPE_BUGLE then
    strType = "军号"

  elseif nType==ITEMTYPE_WEAPON then
    strType = "武器"
  elseif nType==ITEMTYPE_HAT then
    strType = "帽子"
  elseif nType==ITEMTYPE_CLOTHES then
    strType = "衣服"
  elseif nType==ITEMTYPE_GLOVE then
    strType = "手套"
  elseif nType==ITEMTYPE_SHOES then
    strType = "鞋子"
  elseif nType==ITEMTYPE_ARMOR then
    strType = "护甲"

  end

  return strType
end
--获取怪物按钮
function GlobalGetMonsterBt(nTemplateID,iconScale,bMsg)
  nTemplateID=nTemplateID+0 --如果是字符串转成数字
  local pIcon = nil
  -- print(nTemplateID)
  if nil==nTemplateID or nil==monsterData[nTemplateID] then
    pIcon = cc.ui.UIPushButton.new("itemBox/monsterBox.png")
    return pIcon
  end
  --品质框
  -- pIcon = cc.ui.UIPushButton.new("itemBox/monsterBox.png")
  if monsterData[nTemplateID].boss==1 then
    pIcon = cc.ui.UIPushButton.new("itemBox/monsterBox"..monsterData[nTemplateID].type1..".png")
    --角标
    display.newSprite("itemBox/monster_icon"..monsterData[nTemplateID].type1..".png")
    :addTo(pIcon, 2)
    :pos(28,28)
    
  elseif monsterData[nTemplateID].boss==2 then
    pIcon = cc.ui.UIPushButton.new("itemBox/monsterBossBox1.png")
    local box2 = display.newSprite("itemBox/monsterBossBox2.png")
    :align(display.CENTER, pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    :addTo(pIcon, 1)
    -- local bossImg = display.newSprite("Block/blockSelected/boss.png")
    -- :addTo(pIcon,2)
    -- :pos(pIcon:getContentSize().width/2, -30)
    --角标
    display.newSprite("itemBox/monster_icon"..monsterData[nTemplateID].type1..".png")
    :addTo(box2, 2)
    :pos(box2:getContentSize().width-15,box2:getContentSize().height-15)
    
  end

  local msgBox
  if bMsg then
    msgBox = display.newSprite("itemBox/msgBox.png")
    :addTo(pIcon,2)
    msgBox:pos(0,60)
    msgBox:setAnchorPoint(0.5,0)
    msgBox:setVisible(false)
    local icon = GlobalGetMonsterBt(nTemplateID)
    :addTo(msgBox)
    :pos(50,msgBox:getContentSize().height-47)
    icon:setScale(0.7)
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    :addTo(msgBox)
    :pos(85,msgBox:getContentSize().height-29)
    name:setString(monsterData[nTemplateID].name)
    name:setColor(cc.c3b(0, 255, 0))
    local level = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    :addTo(msgBox)
    :pos(85,msgBox:getContentSize().height-65)
    level:setString("LV:"..bMsg.level)
    level:setColor(cc.c3b(0, 255, 0))
    local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    :addTo(msgBox)
    :pos(25,msgBox:getContentSize().height-85)
    des:setString(monsterData[nTemplateID].des)
    des:setColor(MYFONT_COLOR)
    des:setAnchorPoint(0,1)
    des:setWidth(230)
  end
  pIcon:onButtonPressed(function(event)
    event.target:setScale(event.target:getScale()*0.98)
    if bMsg then
      msgBox:setVisible(true)
    end
    end)
  pIcon:onButtonRelease(function(event)
    event.target:setScale(event.target:getScale()/0.98)
    if bMsg then
      msgBox:setVisible(false)
    end
    end)
  
  local monsterInfo = monsterData[nTemplateID]
  local fileName = "monster/monster_"..monsterInfo.resId..".png"

  local tmpSize = pIcon:getContentSize()
  --图标
  local itemInfo = monsterData[nTemplateID]
  if iconScale==nil then
    iconScale = 1
    if monsterData[nTemplateID].boss==2 then iconScale = iconScale*1.15 end
  end
  fileName = string.format("monster/monster_%d.png", itemInfo.resId)
  display.newSprite(fileName)
    :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
    :addTo(pIcon, 0, 1)
    :setScale(iconScale)


  return pIcon
end

--获取怪物按钮2
function GlobalGetMonsterBt2(nTemplateID,iconScale,bMsg)
  nTemplateID=nTemplateID+0 --如果是字符串转成数字
  local pIcon = nil
  -- print(nTemplateID)
  if nil==nTemplateID or nil==monsterData[nTemplateID] then
    return pIcon
  end
  --品质框
  -- pIcon = cc.ui.UIPushButton.new("itemBox/monsterBox.png")
  if monsterData[nTemplateID].boss==1 then
    pIcon = cc.ui.UIPushButton.new("Block/blockSelected/select_img24.png")

    --名字
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = cc.c3b(25, 23, 23)})
    :addTo(pIcon)
    :align(display.CENTER, 0, 68)
    :setString(monsterData[nTemplateID].name)
    --等级
    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 18, color = cc.c3b(25, 23, 23)})
    :addTo(pIcon)
    :align(display.CENTER, 0, -70)
    :setString("LV"..bMsg.level)
    --星级底框
    local starBox = display.newSprite("Block/blockSelected/select_img2"..(monsterData[nTemplateID].type1)..".png")
    :addTo(pIcon)
    --角标
    display.newSprite("itemBox/monster_icon"..monsterData[nTemplateID].type1..".png")
    :addTo(pIcon, 2)
    :align(display.RIGHT_BOTTOM, starBox:getContentSize().width/2-2,-starBox:getContentSize().height/2+2)
    
  elseif monsterData[nTemplateID].boss==2 then
    pIcon = cc.ui.UIPushButton.new("Block/blockSelected/select_img19.png")
    
    --名字
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = cc.c3b(25, 23, 23)})
    :addTo(pIcon)
    :align(display.CENTER, 0, 74)
    :setString(monsterData[nTemplateID].name)
    --等级
    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 18, color = cc.c3b(25, 23, 23)})
    :addTo(pIcon)
    :align(display.CENTER, 0, -76)
    :setString("LV"..bMsg.level)
    --角标
    -- display.newSprite("itemBox/monster_icon"..monsterData[nTemplateID].type1..".png")
    -- :addTo(pIcon, 2)
    -- :pos(35,-47)
    --boss标志
    local bossImg = display.newSprite("Block/blockSelected/select_img18.png")
    :addTo(pIcon,2)
    :pos(pIcon:getContentSize().width/2+5, -40)
  end

  local msgBox
  if bMsg then
    msgBox = display.newSprite("common/common_msgBox.png")
    :addTo(pIcon,2)
    msgBox:pos(0,95)
    msgBox:setAnchorPoint(0.5,0)
    msgBox:setVisible(false)
    -- local icon = GlobalGetMonsterBt(nTemplateID)
    -- :addTo(msgBox)
    -- :pos(50,msgBox:getContentSize().height-47)
    -- icon:setScale(0.7)
    --怪物图标
    local iconBox
    if monsterData[nTemplateID].boss==1 then
      iconBox = display.newSprite("Block/blockSelected/select_img2"..(monsterData[nTemplateID].type1)..".png")
      :addTo(msgBox)
      :pos(45,msgBox:getContentSize().height/2)
      :scale(0.7)

      local itemInfo = monsterData[nTemplateID]
      fileName = string.format("monster/monster_%d.png", itemInfo.resId)
      display.newSprite(fileName)
      :align(display.CENTER_BOTTOM, iconBox:getContentSize().width/2, 2)
      :addTo(iconBox)
    else
      iconBox = display.newSprite("Block/blockSelected/select_img29.png")
      :addTo(msgBox)
      :pos(45,msgBox:getContentSize().height/2)

      local itemInfo = monsterData[nTemplateID]
      fileName = string.format("monster/monster_%d.png", itemInfo.resId)
      display.newSprite(fileName)
      :align(display.CENTER_BOTTOM, iconBox:getContentSize().width/2, 2)
      :addTo(iconBox)
      :scale(0.7)
    end
    

    

    --名字
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20,})
    :addTo(msgBox)
    :pos(85,msgBox:getContentSize().height-24)
    name:setString(monsterData[nTemplateID].name)
    name:setColor(cc.c3b(255, 200, 46))
    --等级
    local level = cc.ui.UILabel.new({font = "fonts/slicker.ttf",UILabelType = 2, text = "", size = 20})
    :addTo(msgBox)
    :pos(85+name:getContentSize().width + 20,msgBox:getContentSize().height-24)
    level:setString("LV:"..bMsg.level)
    level:setColor(cc.c3b(255, 200, 46))
    --描述
    local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = cc.c3b(144, 200, 209)})
    :addTo(msgBox)
    :pos(85,msgBox:getContentSize().height/2 + 15)
    des:setString(monsterData[nTemplateID].des)
    des:setAnchorPoint(0,1)
    des:setWidth(185)
  end
  pIcon:onButtonPressed(function(event)
    event.target:setScale(event.target:getScale()*0.98)
    if bMsg then
      msgBox:setVisible(true)
    end
    end)
  pIcon:onButtonRelease(function(event)
    event.target:setScale(event.target:getScale()/0.98)
    if bMsg then
      msgBox:setVisible(false)
    end
    end)
  
  local monsterInfo = monsterData[nTemplateID]
  local fileName = "monster/monster_"..monsterInfo.resId..".png"

  local tmpSize = pIcon:getContentSize()
  --图标
  local itemInfo = monsterData[nTemplateID]
  if iconScale==nil then
    iconScale = 1
    if monsterData[nTemplateID].boss==2 then iconScale = iconScale*1.15 end
  end
  fileName = string.format("monster/monster_%d.png", itemInfo.resId)
  local img = display.newSprite(fileName)
    :align(display.CENTER_BOTTOM, 0, -53)
    :addTo(pIcon, 0, 1)
    :scale(iconScale)
    if monsterData[nTemplateID].boss==2 then
      img:pos(0, -58)
    else
      img:pos(0, -53)
    end


  return pIcon
end


--获取道具图标(道具图标--tag=1 数量--tag=2)
function GlobalGetItemIcon(nTemplateID, nCount,nFrameType,bGray)
  -- print("tmpId:"..nTemplateID)
  nTemplateID=nTemplateID+0 --如果是字符串转成数字
  local pIcon
  if nil==nTemplateID or nil==itemData[nTemplateID] then
    -- print("aaa")
    return pIcon
  end
  local itemInfo = itemData[nTemplateID]
  local arrNum = SplitNum(nTemplateID, {3, 1, 3})
  -- if arrNum[2]==0 then
  --   arrNum[2] = 2
  -- end

  --品质框
  local item_type  = getItemType(nTemplateID)
  -- print("item_type1:"..item_type)
  local fileName
  if (item_type>=101 and item_type<=106) and nFrameType==nil then
    fileName = string.format("itemBox/item_box%d.png", arrNum[2])
    pIcon = display.newSprite(fileName)
    local icon = display.newSprite("itemBox/icon_"..item_type..".png")
    :addTo(pIcon,2,2)
    :pos(pIcon:getContentSize().width-24,pIcon:getContentSize().height-24)
  elseif item_type==500 or item_type==600  then
    fileName = string.format("itemBox/piece_box%d.png", arrNum[2])
    pIcon = display.newSprite(fileName)
    local tp = math.modf(nTemplateID/10000)
    if item_type==500 then
      local icon = display.newSprite("itemBox/icon_"..tp..".png")
      :addTo(pIcon,2,2)
      :pos(pIcon:getContentSize().width-34,pIcon:getContentSize().height-34)
    end
    local icon2 = display.newSprite("itemBox/icon_piece.png")
    :addTo(pIcon,2,3)
    :pos(35,35)
  else
    if nFrameType~=nil then
      fileName = string.format("itemBox/item%d_box%d.png", nFrameType, arrNum[2])
      pIcon = display.newSprite(fileName)
    else
      fileName = string.format("itemBox/item_box%d.png", arrNum[2])
      pIcon = display.newSprite(fileName)
    end

    
  end
  
  
  if nil==pIcon then
    return pIcon
  end
  local tmpSize = pIcon:getContentSize()

  --图标
  fileName = string.format("Item/item_%d.png", itemInfo.resId)
  local pic = display.newSprite(fileName)
    :align(display.CENTER, tmpSize.width/2, tmpSize.height/2)
    :addTo(pIcon, 0, 1)
  if item_type==107 then
    pic:setScaleX(0.7)
  end
  --数量
  if nil~=nCount then
    local labNum = cc.ui.UILabel.new({text=tostring(nCount), size=20})
                    :align(display.RIGHT_BOTTOM,  pIcon:getContentSize().width-10, 10)
                    :addTo(pIcon, 1, 2)
  end

  if bGray then
      pIcon:setColor(cc.c3b(128, 128, 128))
      for i=1,3 do
        if pIcon:getChildByTag(i) then
          pIcon:getChildByTag(i):setColor(cc.c3b(128, 128, 128))
        end
        
      end
  end


  return pIcon
end

local bgSize = cc.size(1280, 960)
--主城动画配置
TownAnimationName = {
  {name = "laduotexiao", pos = {cc.p(0, 0), cc.p(0,0),cc.p(0, 0), cc.p(0,0),cc.p(0, 0)}},
  {name = "zaozetexiao", pos = {cc.p(0, 120)}},
  {name = "bobuzheng", pos = {cc.p(0, 0), cc.p(0,100),cc.p(0, 0)}},
  {name = "", pos = {}},
  {name = "", pos = {}},

  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},

  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},

  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
  {name = "", pos = {}},
}

local lastAnimationFile = nil
function getMainSceneBgImg()
  -- print("srv_userInfo.areaId:"..srv_userInfo.areaId)
  local areaId=srv_userInfo.areaId --如果是字符串转成数字
  local imgName = "Block/area_"..areaData[areaId].resId.."/city_bg.jpg"
  
  -- local mainBg = display.newFilteredSprite(imgName, 
  --   {"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"}, {{2}, {2}})
  local mainBg = display.newSprite(imgName, display.cx, display.cy) --背景图
  mainBg:setTouchSwallowEnabled(true)
  if areaData[areaId].location~=nil then
    if areaData[areaId].location==1 then
      mainBg:align(display.CENTER_TOP, display.cx, display.height)
    elseif areaData[areaId].location==2 then
      mainBg:align(display.CENTER, display.cx, display.cy)
    elseif areaData[areaId].location==3 then
      mainBg:align(display.CENTER_BOTTOM, display.cx, 0)
    end
  end
  --主城背景动画
  if TownAnimationName[areaData[areaId].resId-10000].name~="" then
    local animations = {}
    local tmp = TownAnimationName[areaData[areaId].resId-10000]
    local manager = ccs.ArmatureDataManager:getInstance()
    local fileName = "Block/area_"..areaData[areaId].resId.."/"..tmp.name..".ExportJson"
    lastAnimationFile = fileName
    manager:removeArmatureFileInfo(fileName)
    manager:addArmatureFileInfo(fileName)
    for i=1,(#tmp.pos) do
      -- printTable(tmp.pos)
      animations[i] = ccs.Armature:create(tmp.name)
      :addTo(mainBg,0,100+i)
      -- :pos(tmp.pos[i].x, tmp.pos[i].y)
      animations[i]:getAnimation():playWithIndex(i-1)
      if areaData[areaId].location~=nil then
        if areaData[areaId].location==1 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y)
        elseif areaData[areaId].location==2 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y+120)
        elseif areaData[areaId].location==3 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y+240)
        end
      end
      dealSpecialAnimations(animations[i], i)
    end
  end
  return mainBg
end
--重设背景图和背景动画
function setMainSceneBgImg(note)
  local areaId=srv_userInfo.areaId --如果是字符串转成数字
  local imgName = "Block/area_"..areaData[areaId].resId.."/city_bg.jpg"
  note:setTexture(imgName)
  if areaData[areaId].location~=nil then
    if areaData[areaId].location==1 then
      note:align(display.CENTER_TOP, display.cx, display.height)
    elseif areaData[areaId].location==2 then
      note:align(display.CENTER, display.cx, display.cy)
    elseif areaData[areaId].location==3 then
      note:align(display.CENTER_BOTTOM, display.cx, 0)
    end
  end

  for i=1,10 do
    note:removeChildByTag(100+i)
  end
  local manager = ccs.ArmatureDataManager:getInstance()
  manager:removeArmatureFileInfo(lastAnimationFile)
  --主城背景动画
  if TownAnimationName[areaData[areaId].resId-10000].name~="" then
    local animations = {}
    local tmp = TownAnimationName[areaData[areaId].resId-10000]
    
    local fileName = "Block/area_"..areaData[areaId].resId.."/"..tmp.name..".ExportJson"
    
    manager:addArmatureFileInfo(fileName)
    for i=1,(#tmp.pos) do
      animations[i] = ccs.Armature:create(tmp.name)
      :addTo(note,0,100+i)
      -- :pos(tmp.pos[i].x, tmp.pos[i].y)
      animations[i]:getAnimation():playWithIndex(i-1)
      if areaData[areaId].location~=nil then
        if areaData[areaId].location==1 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y)
        elseif areaData[areaId].location==2 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y+120)
        elseif areaData[areaId].location==3 then
          animations[i]:pos(tmp.pos[i].x, tmp.pos[i].y+240)
        end
      end
      dealSpecialAnimations(animations[i], i)
    end
  end
end
--主场景特殊的动画处理
function dealSpecialAnimations(animation, i)
  local areaId=srv_userInfo.areaId
  if areaId==10001 and i==4 then
    local oldPosX,oldPosY = animation:getPositionX(), animation:getPositionY()
    -- print(oldPos)
    -- printTable(oldPos)
    local seq = cc.Sequence:create(
      cc.MoveTo:create(1.2, cc.p(-70, 250)),
      cc.MoveTo:create(2.0, cc.p(0, 400)),
      cc.MoveTo:create(2.5, cc.p(-20, 500)),
      cc.DelayTime:create(2.0),
      cc.CallFunc:create(function(event)
        animation:setPosition(oldPosX, oldPosY)
        end)
      )
    animation:runAction(cc.RepeatForever:create(seq))
  end
end


function getBlockBgImg(areaId)
  areaId=areaId+0 --如果是字符串转成数字
  local imgName = "blockBg/block_"..areaId..".png"
  local blockBg = display.newSprite(imgName, display.cx, display.cy) --背景图
  return blockBg
end

--==============
--创建道具表图标
--tmpId   物品模板Id
--cnt     物品个数，nil就不显示
--bButton 是否是做成按钮
--bMsg    是否显示物品信息
--msgPos  物品信息框在物品的什么位置，0,1,2,3对应上下左右
function createItemIcon(tmpId,cnt,bButton,bMsg,msgPos, bIconGray)
  tmpId = tmpId + 0
  if tmpId==nil then
    return
  elseif tmpId==10000 then
    local pBox = display.newSprite("itemBox/commonBox3.png")
    display.newSprite("Item/item_10000.png")
    :addTo(pBox)
    :pos(pBox:getContentSize().width/2, pBox:getContentSize().height/2)
    return pBox
  elseif tmpId==10001 then
    local pBox = display.newSprite("itemBox/commonBox3.png")
    display.newSprite("Item/item_10001.png")
    :addTo(pBox)
    :pos(pBox:getContentSize().width/2, pBox:getContentSize().height/2)
    return pBox
  end
  local pBox
  local star  = getItemStar(tmpId) --星级
  local mType = getItemType(tmpId) --类型
  local boxName
  if mType == 307 then --战车核心
    boxName = "itemBox/hexinBox.png"
  elseif mType == 500 or mType==600 then
    boxName = string.format("itemBox/piece_box%d.png", star)
  else
    boxName = string.format("itemBox/item_box%d.png", star)
  end

  pBox =cc.ui.UIPushButton.new(boxName)
  pBox:setButtonEnabled(false)
  local msgBox
  if bMsg then
    local scale = 0.8
    msgBox = display.newSprite("common/common_msgBox.png")
    :addTo(pBox,2)
    msgBox:setVisible(false)
    msgBox:setScale(1/scale)
    if msgPos==nil or msgPos==0 then
      msgBox:pos(0,(msgBox:getContentSize().height+20))
    elseif msgPos==1 then
      msgBox:pos(0,-(msgBox:getContentSize().height+20))
    elseif msgPos==2 then
      msgBox:pos(-(msgBox:getContentSize().width+20),0)
    elseif msgPos==3 then
      msgBox:pos(msgBox:getContentSize().width+20,0)
    end
    local icon = createItemIcon(tmpId,nil)
    :addTo(msgBox)
    :pos(47,msgBox:getContentSize().height-67)
    icon:setScale(0.55)
    local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20})
    :addTo(msgBox)
    :pos(21,msgBox:getContentSize().height-20)
    name:setString(itemData[tmpId].name)
    name:setColor(cc.c3b(255, 200, 46))
    local des = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18})
    :addTo(msgBox)
    :pos(85,msgBox:getContentSize().height-37)
    des:setString(itemData[tmpId].des)
    des:setColor(cc.c3b(144, 200, 209))
    des:setAnchorPoint(0,1)
    des:setWidth(200)
  end

  if bButton then --按钮
    -- print("bButton")
    pBox:setTouchSwallowEnabled(false)
    pBox:setButtonEnabled(true)
    pBox:onButtonPressed(function(event)
      event.target:setScale(event.target:getScale()*0.98)
      if bMsg then
        msgBox:setVisible(true)
      end
      end)
    pBox:onButtonRelease(function(event)
      event.target:setScale(event.target:getScale()/0.98)
      if bMsg then
        msgBox:setVisible(false)
      end
      end)
  end
  
  if cnt~=nil then --数量
    local labNum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 20})
    :addTo(pBox,1)
    labNum:setAnchorPoint(1,0)
    labNum:setString(cnt)
    if mType==307 then
      labNum:setAnchorPoint(0,0)
      labNum:setPosition(-48, -50)
    elseif mType==500 or mType==600 then
      labNum:setPosition(45, -47)
    else
      labNum:setPosition(45, -47)
    end
  end

  --碎片标志和类型标志
  if mType==500 or mType==600 then
    local subNum = math.floor(tmpId/10000)
    if subNum>=101 and subNum<=106 then
      local typeImg = display.newSprite("itemBox/icon_"..subNum..".png")
      :addTo(pBox,1)
      :pos(50,50)
      typeImg:setAnchorPoint(1,1)
    end
  elseif mType>=101 and mType<=106 then
    local typeImg = display.newSprite("itemBox/icon_"..mType..".png")
    :addTo(pBox,1)
    :pos(50,50)
    typeImg:setAnchorPoint(1,1)
  end

  --图标
  local icon
  if bIconGray then
    pBox:setButtonImage("normal", "itemBox/item_box2.png")
    pBox:setButtonImage("pressed", "itemBox/item_box2.png")
    pBox:setButtonImage("disabled", "itemBox/item_box2.png")
    icon = display.newGraySprite("Item/item_"..itemData[tmpId].resId..".png")
  else
    icon = display.newSprite("Item/item_"..itemData[tmpId].resId..".png")
  end
  
  icon:addTo(pBox)
  if mType==107 or mType==109 then
    icon:setScale(0.8)
    icon:setRotation(-45)
  elseif mType==500 or mType==600 then
    icon:setScale(0.8)
  else
    icon:setScale(1.1)
  end
  -- icon:setScale(1.3)
  --紫装特效
  if star==5 then
    if mType==500 or mType==600 or mType==307 then
      PurplePieceEff(pBox,0,0)
    else
      PurpleEff(pBox,0,0)
    end
  end

  --判断是否套装
  if itemData[tmpId].suitID~=0 then
    display.newSprite("common2/com2_tag_02.png")
    :addTo(pBox)
    :align(display.LEFT_TOP, -50, 50)
  end
  return pBox
end

function getGoldsIcon(type,num,scale)
  scale = scale or 1
  type=tonumber(type)
  num = tonumber(num)
  local pIcon
  local boxName,iconImg
  boxName = "itemBox/commonBox2.png"
  if type==1 then --金币
    -- boxName = "itemBox/gold_box.png"
    iconImg = "common/common_GoldGetBg.png"
    pIcon = display.newSprite(boxName)
    :scale(scale)
    display.newSprite(iconImg)
    :addTo(pIcon)
    :scale(0.9)
    :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = MYFONT_COLOR})
    :addTo(pIcon)
    :align(display.CENTER_RIGHT, pIcon:getContentSize().width-15, 20)
    -- :scale(1/scale)
    :setString(num)
  elseif type==2 then --钻石
    -- boxName = "itemBox/diamond_box.png"
    iconImg = "recharge/diamond4.png"
    pIcon = display.newSprite(iconImg)
    :scale(scale*0.7)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 20, color = MYFONT_COLOR})
    :addTo(pIcon)
    :align(display.CENTER_RIGHT, pIcon:getContentSize().width-15, 20)
    -- :scale(1/scale)
    :setString(num)
  elseif type==3 then --燃油
    -- boxName = "itemBox/gold_box.png"
    iconImg = "item/item_7002002.png"
    pIcon = display.newSprite(iconImg)
    :scale(scale)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 13, color = MYFONT_COLOR})
    :addTo(pIcon)
    :align(display.CENTER_RIGHT, pIcon:getContentSize().width-10, 13)
    -- :scale(1/scale)
    :setString(num)
  elseif type==4 then --经验
    -- boxName = "itemBox/diamond_box.png"
    iconImg = "common/common_ExpBg.png"
    pIcon = display.newSprite(boxName)
    :scale(scale)
    display.newSprite(iconImg)
    :addTo(pIcon)
    :scale(0.9)
    :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = MYFONT_COLOR})
    :addTo(pIcon)
    :align(display.CENTER_RIGHT, pIcon:getContentSize().width-15, 20)
    -- :scale(1/scale)
    :setString(num)
  elseif type==5 then --声望
    -- boxName = "itemBox/diamond_box.png"
    iconImg = "common/shengwangIcon.png"
    pIcon = display.newSprite(boxName)
    :scale(scale)
    display.newSprite(iconImg)
    :addTo(pIcon)
    :scale(0.9)
    :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    cc.ui.UILabel.new({UILabelType = 2, text = "", size = 18, color = MYFONT_COLOR})
    :addTo(pIcon)
    :align(display.CENTER_RIGHT, pIcon:getContentSize().width-15, 20)
    -- :scale(1/scale)
    :setString(num)
  end

  

  return pIcon
end
--设置图标(pIcon：创建接口-GlobalGetItemIcon)
function GlobalSetIcon(pIcon, nCount, nTemplateID, nFrameType)
  -- print(nTemplateID)
  if nil==pIcon then
    return
  end

  if nil~=nCount then
    local labNum = pIcon:getChildByTag(2)
    if nil~=labNum then
      labNum:setString(tostring(nCount))
    end
  end

  if nil~=nTemplateID then
    --品质框
    local arrNum = SplitNum(nTemplateID, {3, 1, 3})
    -- if nFrameType~=nil then
    --   fileName = string.format("item/item%d_box%d.png", nFrameType, arrNum[2])
    --   pIcon:setTexture(fileName)
    -- else
    --   fileName = string.format("item/item_box%d.png", arrNum[2])
    --   pIcon:setTexture(fileName)
    -- end
    local item_type  = getItemType(nTemplateID)
    -- print("item_type:"..item_type)
    local fileName
    if (item_type>=101 and item_type<=106) and nFrameType==nil then
      fileName = string.format("itemBox/item_box%d.png", arrNum[2])

      pIcon:setTexture(fileName)

      pIcon:getChildByTag(2):setTexture("itemBox/icon_"..item_type..".png")

    elseif item_type==500 then
      fileName = string.format("itemBox/piece_box%d.png", arrNum[2])
      pIcon:setTexture(fileName)
      local tp = math.modf(nTemplateID/10000)
      pIcon:getChildByTag(2):setTexture("item/icon_"..tp..".png")
      pIcon:getChildByTag(3):setTexture("itemBox/icon_piece.png")

    else
      -- print("cccccccccccccc")
      if nFrameType~=nil then
        fileName = string.format("itemBox/item%d_box%d.png", nFrameType, arrNum[2])
        pIcon:setTexture(fileName)
      else
        fileName = string.format("itemBox/item_box%d.png", arrNum[2])
        pIcon:setTexture(fileName)
      end

    end

    --图标
    local spr = pIcon:getChildByTag(1)
    if nil~=spr then
      local itemInfo = itemData[nTemplateID]
      if nil~=itemInfo then
        fileName = string.format("Item/item_%d.png", itemInfo.resId)
        spr:setTexture(fileName)
      end
    end
  end
end

--创建模型(nFace:1(朝右) -1(朝左))
function GlobalCreateModel(nType, nTemplateID, nFace)
  local preStr, name = "", ""
  local scaleX, scaleY, srcScale  --size规格不统一，故需要这些变量
  local srcFace = -1              --大部分模型文件朝左，个别朝右
  if 1~=nFace and -1~=nFace then
    nFace = 1
  end
  local nMakeType = ModelMakeType.kMake_Coco --1表示cocos做的动画，2表示spine做的动画
  --模型初始大小，朝向右
  if nType==ModelType.Hero then
    preStr = "Battle/Hero/"
    resId = memberData[nTemplateID].resId
    if "null"==memberData[nTemplateID].scale then
      srcScale = 1
    else
      srcScale = memberData[nTemplateID].scale or 1
    end
    name = "Hero_" .. resId .. "_"
    scaleX = -srcScale
    scaleY = srcScale
    nMakeType = memberData[nTemplateID].actType

  elseif nType==ModelType.Tank then
    preStr = "Battle/Tank/"
    resId = carData[nTemplateID].resId
    if "null"==carData[nTemplateID].scale then
      srcScale = 1
    else
      srcScale = carData[nTemplateID].scale or 1
    end
    name = "Tank_" .. resId .. "_"
    scaleX = -srcScale
    scaleY = srcScale
    srcFace = -1
    nMakeType  = ModelMakeType.kMake_Coco

  elseif nType==ModelType.Monster then
    preStr = "Battle/Monster/"
    resId = monsterData[nTemplateID].resId
    if "null"==monsterData[nTemplateID].scale then
      srcScale = 1
    else
      srcScale = monsterData[nTemplateID].scale or 1
    end
    name = "Monster_" .. resId .. "_"
    scaleX = -srcScale
    scaleY = srcScale
    nMakeType  = ModelMakeType.kMake_Coco

  end
  
  --模型朝向指定方向
  scaleX = scaleX*nFace
  if nMakeType == nil or nMakeType == ModelMakeType.kMake_Coco then
    --模型创建
    local filePath = preStr .. name .. ".ExportJson"
    --armatureDataMgr:removeArmatureFileInfo(filePath)
    armatureDataMgr:addArmatureFileInfo(filePath)
    
    if not cc.FileUtils:getInstance():isFileExist(filePath) then
      return nil
    end
    local armature = ccs.Armature:create(name)
    armature:setScaleX(scaleX)
    armature:setScaleY(scaleY)
    armature.srcFace = srcFace   --模型文件朝向
    armature.srcScale = srcScale --模型文件基准大小(战斗场景中的大小)缩放倍数
    armature.makeType = nMakeType
    return armature
  else
    local armature = sp.SkeletonAnimation:create(preStr..name..".json",preStr..name..".atlas",1)
    armature:setScaleX(scaleX)
    armature:setScaleY(scaleY)
    armature.makeType = nMakeType
    return armature
  end
end

--设置模型参数(pModel通过 GlobalCreateModel 创建)
function SetModelParams(pModel, params)
  if nil==pModel or nil==pModel.srcFace or nil==pModel.srcScale then
    return false
  end

  if nil==params then
    return false
  end

  local nCurScaleX, nCurScaleY = math.abs(pModel:getScaleX()), nil

  --朝向设置
  if 1==params.nFace or -1==params.nFace then
    if pModel.srcFace==1 then
      pModel:setScaleX(nCurScaleX*params.nFace)
    else
      pModel:setScaleX(nCurScaleX*(-params.nFace))
    end
  end

  --缩放设置
  if nil~=params.fScale then
    nCurScaleX = pModel:getScaleX()
    nCurScaleY = pModel:getScaleY()

    if nCurScaleX<0 then
      nCurScaleX = -1
    else
      nCurScaleY = 1
    end

    if nCurScaleY<0 then
      nCurScaleY = -1
    else
      nCurScaleY = 1
    end

    nCurScaleX = nCurScaleX*pModel.srcScale*params.fScale
    nCurScaleY = nCurScaleY*pModel.srcScale*params.fScale
    pModel:setScaleX(nCurScaleX)
    pModel:setScaleY(nCurScaleY)
  end

  return true
end

--获取头像路径
function GlobalGetHeadPath(nType, nTemplateID)
  if nil==nTemplateID then
    return ""
  end

  local path, locTab = "", nil
  if nType==ModelType.Hero then
    locTab = memberData[nTemplateID]
    if nil~=locTab then
      path = string.format("Head/headman_%d.png", locTab.resId)
    end

  elseif nType==ModelType.Tank then
    locTab = carData[nTemplateID]
    if nil~=locTab then
      path = string.format("Head/headman_%d.png", locTab.resId)
    end

  elseif nType==ModelType.Monster then
    locTab = monsterData[nTemplateID]
    if nil~=locTab then
      path = string.format("monster/monster_%d.png", locTab.resId)
    end

  end

  return path
end

--获取角色性别(0:Bug 1:男 2:女)
function GlobalGetRoleSex(nTemplateID)
  if nil==nTemplateID then
    nTemplateID = srv_userInfo.templateId
  end

  local loc_MemData = memberData[nTemplateID]
  if nil~=loc_MemData then     --男女主角
    return loc_MemData.sex
  else
    return 0
  end
end

function printLogForLua(msg)
    if device.platform ~= "android" then
      return
    end
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "printLogForLua", {msg}, "(Ljava/lang/String;)V")
end

function luaStart360Waiting(msg)
   if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360 or gType_SDK ~= AllSdkType.Sdk_360_2 then
      return
    end
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStart360Waiting", {msg}, "(Ljava/lang/String;)V")
end

function luaStop360Waiting()
   if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360 or gType_SDK ~= AllSdkType.Sdk_360_2 then
      return
    end
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStop360Waiting", {msg}, "()V")
end

-- 360 SDK 接口相关 start
function luaEndGame(strParams)
    -- local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "printLogForLua", {"调用lua退出"}, "(Ljava/lang/String;)V")
    -- local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStatPlayer", {"1000221",20,1,"QH360","3","ZZJB01",""}, "(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    if DCAgent then
        DCAgent.onKillProcessOrExit()
    end
    cc.Director:getInstance():endToLua()
end

function luaEndAudio(strParams)
  audio.setMusicVolume(0.0)
  audio.setSoundsVolume(0.0)
end

function luaStatPlayer(strId,nAge,nGender,strSource,strLevel,strServer,strComment)
  --strId 用户标识，这里对应userName
  --nAge 年龄
  --nGender 性别
  --strSource 来源，比如"QH360"
  --strLevel 等级 奇怪sdk接口里面居然是字符串型
  --strServer 来自哪个分服 比如 "zzjb01#2"
  --strComment
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360 or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end

  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStatPlayer", {strId,nAge,nGender,strSource,strLevel,strServer,strComment}, 
    "(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

--统计角色名
function luaStatRole(strRoleName)
  -- strRoleName 对应角色名
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360 or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end
  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStatRole", {strRoleName}, "(Ljava/lang/String;)V")
end

--统计开始挑战关卡
function luaStartBlock(strBlockName)
  -- strBlockName 对应关卡名
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360  or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end
  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStartBlock", {strBlockName}, "(Ljava/lang/String;)V")
end

--统计战胜关卡
function luaFinishBlock(strBlockName)
  -- strBlockName 对应关卡名
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360  or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end
  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaFinishBlock", {strBlockName}, "(Ljava/lang/String;)V")
end

--统计失败关卡
function luaFailBlock(strBlockName, strReason)
  -- strBlockName 对应关卡名
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360  or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end
  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaFailBlock", {strBlockName, strReason}, "(Ljava/lang/String;Ljava/lang/String;)V")
end

--统计虚拟币购买物品行为
function luaStatBuy(strName, strType, nNumber, strCoinType, nCoin)
  --strName  物品名称
  --strType: 物品类型
  --nNumber  物品数量
  --strCoinType: 虚拟币类型
  --nCoin：消费的虚拟币数量
  strType = tostring(strType)
  strCoinType = tostring(strCoinType)
  if device.platform ~= "android" or gType_SDK ~= AllSdkType.Sdk_360 or gType_SDK ~= AllSdkType.Sdk_360_2 then
    return
  end
  luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "luaStatBuy", {strName, strType, nNumber, strCoinType, nCoin}, "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;I)V")
end

function decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


-- 360 SDK 接口相关 end

--qq、wechat登陆成功回调(strParams: platform+open_id+accesstoken)

function luaLetUserLogin(strParams)
  if nil==LoginSceneInstance and not isWdjLogin then
    return
  end
  if gType_SDK == AllSdkType.Sdk_MSDK then
      local arr = string.split(strParams,"|")
      require("app.sdk.luaMSDKConstant")
      luaMSDKConstant.LoginInfo = {
                                userid = arr[4],
                                userkey = arr[5],
                                pf = arr[6],
                                pfkey = arr[7],
                                logintype = arr[8],
                                isdebug  = tonumber(arr[9]),
                            }
  end
  require("app.sdk.UEgihtSdkLoginManager")
  print("下面请求U8")
  UEgihtSdkLoginManager:sendTokenToU8(strParams)
end

function getCHeadBox(templateId)
  if templateId==nil then
    templateId = srv_userInfo["templateId"]
  end
  local head 
  if templateId==10000 then
    head = display.newSprite("common2/com_msgTag.png")
    return head
  end
  local headBox = cc.ui.UIPushButton.new("itemBox/cHeadBox.png")
  head = display.newSprite("Head/headman_"..memberData[templateId].resId..".png")
  
  head:addTo(headBox)
  head:pos(headBox:getContentSize().width/2, headBox:getContentSize().height/2+4)
  head:scale(0.62)

  return headBox
end
--获取服务器指定时间点的时间戳
function getSrvPointTimeTs(pointTime)
    local srvTime
    local tab = os.date("*t", srvTime)

    tab.hour = pointTime
    tab.min = 0
    tab.sec = 0

    return os.time(tab)*1000 + srv_local_dts
end
function createGoldIcon(goldNum,flag)
  local goldBox = display.newSprite("itemBox/commonBox2.png")
  local gold = display.newSprite("common/common_GoldGetBg.png")
  :addTo(goldBox)
  :pos(goldBox:getContentSize().width/2,goldBox:getContentSize().height/2)
  -- gold:setScale(0.9)

  if goldNum~=nil then
    local numBar = display.newScale9Sprite("common/common_Frame7.png",50, 
        20,
        cc.size(80, 23),cc.rect(10, 10, 30, 30))
      :addTo(goldBox)
    local num = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(0, 255, 0)})
    :addTo(numBar)
    :pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)
    num:setAnchorPoint(0.5,0.5)
    num:setString(goldNum)
    if goldNum and flag==nil then
      if srv_userInfo.gold < goldNum then
        num:setColor(cc.c3b(255, 0, 0))
      else
        num:setColor(cc.c3b(0, 255, 0))
      end
    end
  end
  
  
  return goldBox
end
function GetTimeStr(nSec) --毫秒
    nSec = nSec/1000
    local nHour, nMin
    nHour = math.floor(nSec/3600)
    nSec = nSec-nHour*3600
    nMin = math.floor(nSec/60)
    nSec = nSec-nMin*60
    if nSec==60 then
        nSec=0
    end

    local strRet = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
    return strRet
end

--描边
function setLabelStroke(centerLabel,fontSize,fontColor,dL,dR,dT,dB,font, isSetStr)
  if fontColor==nil then fontColor=display.COLOR_BLACK end
  if dL==nil then dL = 2 end
  if dR==nil then dR = dL end
  if dT==nil then dT = dL end
  if dB==nil then dB = dL end
  if font==nil then font= display.DEFAULT_TTF_FONT end
  local retNode = {}
  --左
  retNode[1] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10001)
  :pos(centerLabel:getPositionX()-dL, centerLabel:getPositionY())
  retNode[1]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[1]:setString(centerLabel:getString())
  end
  
  --右
  retNode[2] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10002)
  :pos(centerLabel:getPositionX()+dR, centerLabel:getPositionY())
  retNode[2]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[2]:setString(centerLabel:getString())
  end
  -- rightLabel:setString(centerLabel:getString())
  --上
  retNode[3] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10003)
  :pos(centerLabel:getPositionX(), centerLabel:getPositionY()+dT)
  retNode[3]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[3]:setString(centerLabel:getString())
  end
  -- topLabel:setString(centerLabel:getString())
  --下
  retNode[4] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10004)
  :pos(centerLabel:getPositionX(), centerLabel:getPositionY()-dB)
  retNode[4]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[4]:setString(centerLabel:getString())
  end
  -- BottomLabel:setString(centerLabel:getString())
   --左上
  retNode[5] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10005)
  :pos(centerLabel:getPositionX()-dL, centerLabel:getPositionY()+dT)
  retNode[5]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[5]:setString(centerLabel:getString())
  end
  -- leftLabel:setString(centerLabel:getString())
  --右上
  retNode[6] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10006)
  :pos(centerLabel:getPositionX()+dR, centerLabel:getPositionY()+dT)
  retNode[6]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[6]:setString(centerLabel:getString())
  end
  -- rightLabel:setString(centerLabel:getString())
  --左下
  retNode[7] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10007)
  :pos(centerLabel:getPositionX()-dL, centerLabel:getPositionY()-dB)
  retNode[7]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[7]:setString(centerLabel:getString())
  end
  -- topLabel:setString(centerLabel:getString())
  --右下
  retNode[8] =  cc.ui.UILabel.new({UILabelType = 2, text = "", size = fontSize, color = fontColor,font = font})
  :addTo(centerLabel:getParent(),centerLabel:getLocalZOrder()-1,10008)
  :pos(centerLabel:getPositionX()+dR, centerLabel:getPositionY()-dB)
  retNode[8]:setAnchorPoint(centerLabel:getAnchorPoint())
  if isSetStr then
    retNode[8]:setString(centerLabel:getString())
  end
  -- BottomLabel:setString(centerLabel:getString())
  return retNode
end
function setLabelStrokeString(centerLabel, retNode)
  for i=1,8 do
    retNode[i]:setString(centerLabel:getString())
  end
end
function removeLabelStrokeString(retNode)
  for i=1,8 do
    retNode[i]:removeSelf()
  end
end
function setLabelRotation(centerLabel, retNode, rotation)
  for i=1,8 do
    retNode[i]:setRotation(rotation)
  end
end
function setLabelLineHeight(centerLabel, retNode, height)
  for i=1,8 do
    retNode[i]:setLineHeight(height)
  end
end
function setLabelColor(centerLabel, retNode, color)
  for i=1,8 do
    retNode[i]:setColor(color)
  end
end
function setLabelVisible(retNode, bVisible)
  for i=1,8 do
    retNode[i]:setVisible(bVisible)
  end
end
function setLabelVisible(retNode, scalex, scaley)
  scalex = scalex or 1
  scaley = scaley or 1
  for i=1,8 do
    retNode[i]:setScaleX(scalex)
    retNode[i]:setScaleY(scaley)
  end
end

--获取战斗关卡的星级
function getFightBlockStar()
  return g_fightBlockStar or 0
end

--通过关卡Id，获取大区ID
function blockIdtoAreaId(blockId)
    -- local toAreaIdx = math.modf(blockId/1000)%1000
    -- local toAreaId = string.format("10%03d", toAreaIdx) + 0
    if blockId==0 then
      return 10001
    end
    print(blockId)
    print(blockData[blockId].areaId)
    local toAreaId = blockData[blockId].areaId
    return toAreaId
end
--怪物血量
function getMonsterBlood(tmpId,level)
  local maxHp = math.floor((monsterData[tmpId]["hp"] + 
    monsterData[tmpId]["hpGF"]*(level-1))*(math.floor(level/11 + 1)/2))
  return maxHp
end

function printTraceback()
    print("traceback----------------traceback---------------printBegin")
    print(debug.traceback())
    print("traceback----------------traceback---------------printEnd")
end

function showLogLabel(msg)
  if g_IsDebug then
    local tag = 10989
    local ttfLbl = display.getRunningScene():getChildByTag(tag)
    if ttfLbl==nil then
      ttfLbl = display.newTTFLabel({text=msg, size=30, color=cc.c3b(255, 0, 0)})
                      :align(display.CENTER, display.cx, display.height-50)
                      :addTo(display.getRunningScene(),111111,tag)
    end
    ttfLbl:setString(msg)
  end
end

g_bIsScenePaused = false

function applicationDidEnterBackground()
    if g_notAllowToBackGround == true then
      printTraceback()
      print("不准进")
        return
    end
    cc.Director:getInstance():stopAnimation();
    cc.Director:getInstance():pause();
    audio.pauseMusic();
    audio.pauseAllSounds();
    print("调用进入后台------------------------1111111111111")
end

function applicationWillEnterForeground()
    if not g_bIsScenePaused then
      cc.Director:getInstance():resume();
    end
    cc.Director:getInstance():startAnimation();

    audio.resumeMusic();
    audio.resumeAllSounds();

    print("调用从后台恢复------------------------2222222222222")
end
--重新加载lua文件
function reloadLuaFile(moduleName)
    package.loaded[moduleName] = nil
    local mod = require(moduleName)
    print("--------",moduleName,"  has been reloaded------------=====")
    return mod
end
--套装属性是否激活
function isSuitActivated(srvValue, locValue)
  if locValue.suitID==0 or srvValue.wareTmpId==0 then
    return false
  end
  local suitId = locValue.suitID
  local carTmpId = srvValue.wareTmpId
  local eptNum = 0

  for i,value in pairs(srv_carEquipment["item"]) do
    if eptNum>=4 then
      break
    end
    if value.wareTmpId==carTmpId and suitId==itemData[value.tmpId].suitID then
      eptNum = eptNum + 1
    end
  end

  if eptNum==4 then
    return true
  end

  return false
end

--材料是否可合成
function isStuffCanCombination(tmpId)
  local comTab = nil

  for i,value in pairs(combinationData) do
      if value.compoundId==tmpId then
        comTab = value
        break
      end
  end

  local pieceArr=lua_string_split(comTab.piece,":")
  local piceCombiData = getPieceCombination(comTab.compoundId)
  local peiceByTmpid = {}
  peiceByTmpid = getPieceByTmpId()
  local curPieceNum
  if peiceByTmpid[pieceArr[1]+0]==nil then
      curPieceNum = 0 
  else
      curPieceNum = peiceByTmpid[pieceArr[1]+0].cnt
  end
 
  local per = (curPieceNum+piceCombiData.maxOmniCount)/pieceArr[2]
  if per>=1 then
    return true
  end

  return false
end

function startCountDown(count,interval,handler,bIsGlobal)
  local sceneName = display.getRunningScene().name
  local count_begin = 1
  local count_ing = 2
  local count_end = 3
  local ret = {count = count,interval = interval,handler = handler,bIsGlobal = bIsGlobal}
  local function onTimer(dt)
    if not bIsGlobal and sceneName ~= display.getRunningScene().name then
      stopCountDown(ret)
    end
    count = count - interval
    ret.count = count
    if count<=0 then
      stopCountDown(ret)
          handler(count,count_end)
    else
      handler(count,count_ing)
    end
  end
  handler(count,count_begin)
  ret._handle = scheduler.scheduleGlobal(onTimer, interval, false)
  return ret
end

function pauseCountDown(arg)
  if arg then
    if arg._handle then
      scheduler.unscheduleGlobal(arg._handle)
      arg._handle = nil
    end
  end
end

function resumeCountDown(arg)
  if arg then
    return startCountDown(arg.count,arg.interval,arg.handler,arg.bIsGlobal)
  else
    return nil
  end
end

function stopCountDown(arg)
  if arg then
    if arg._handle then
      scheduler.unscheduleGlobal(arg._handle)
      arg._handle = nil
      arg = nil
    end
  end
end


--timeEnd形式为“小时：分”，如12:30
function getSecendFromNowTo_(timeEnd,timeFrom)
  local arr = string.split(timeEnd,":")
  local h,m = tonumber(arr[1]),tonumber(arr[2])
  if h<0 or h>24 or m<0 or m>60 then
    print("传入的时间参数有问题")
    return nil
  end

  local arr2
  if timeFrom==nil then
    timeFrom = os.date("%H:%M:%S")
    arr2 = string.split(timeFrom,":")
  else
    arr2 = string.split(timeFrom,":")
  end
  local nowH,nowM,nowS = tonumber(arr2[1]),tonumber(arr2[2]),tonumber(arr2[3])
  if nowS==nil then
    nowS = 0
  end
  -- print("--------------------------cccccccc")
  -- print(nowH,nowM,nowS)
  
  h = h-nowH
  --print("h:"..h)
  if h<0 or (h==0 and m<nowM)then
    return 0 - getSecendFromNowTo_(timeFrom,timeEnd)
  end

  m = (h*60 + m-nowM)*60 - nowS

  return m
end
--创建浅蓝色按钮
function createBlueBt(text, scale)
  scale = scale or 1
  local bt = cc.ui.UIPushButton.new("common/common_nBt1.png")
  :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = text, size = 30, color = cc.c3b(0, 50, 255)}))
  :onButtonPressed(function(event) event.target:setScale(0.95*scale) event.target:getButtonLabel():setPositionY(5) end)
  :onButtonRelease(function(event) event.target:setScale(1.0*scale) event.target:getButtonLabel():setPositionY(5) end)
  :scale(scale)
  bt:getButtonLabel():setPositionY(5)
  local nodes = setLabelStroke(bt:getButtonLabel(),30,cc.c3b(178, 252, 161),1,nil,nil,nil,nil, true)

  return bt,nodes
end
--创建绿色按钮
function createGreenBt(text, scale)
  scale = scale or 1
  local bt = cc.ui.UIPushButton.new("common/common_nBtG.png")
  :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = text, size = 27, color = cc.c3b(7, 74, 6)}))
  :onButtonPressed(function(event) event.target:setScale(0.95*scale) event.target:getButtonLabel():setPositionY(5) end)
  :onButtonRelease(function(event) event.target:setScale(1.0*scale) event.target:getButtonLabel():setPositionY(5) end)
  :scale(scale)
  bt:getButtonLabel():setPositionY(5)
  local nodes = setLabelStroke(bt:getButtonLabel(),27,cc.c3b(178, 252, 161),1,nil,nil,nil,nil, true)

  return bt,nodes
end
--创建黄色按钮
function createYellowBt(text, scale)
  scale = scale or 1
  local bt = cc.ui.UIPushButton.new({normal = "common/common_nBt2.png"}, {grayState=true})
  :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = text, size = 27, color = cc.c3b(127, 79, 33)}))
  :onButtonPressed(function(event) event.target:setScale(0.95*scale) event.target:getButtonLabel():setPositionY(5) end)
  :onButtonRelease(function(event) event.target:setScale(1.0*scale) event.target:getButtonLabel():setPositionY(5) end)
  :scale(scale)
  bt:getButtonLabel():setPositionY(5)
  local nodes = setLabelStroke(bt:getButtonLabel(),27,cc.c3b(254, 255, 186),1,nil,nil,nil,nil, true)

  return bt,nodes
end
--创建橙红色按钮
function createYellowRedBt(text, scale)
  scale = scale or 1
  local bt = cc.ui.UIPushButton.new("common/common_nBt6.png")
  :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = text, size = 27, color = cc.c3b(93, 37, 33)}))
  :onButtonPressed(function(event) event.target:setScale(0.95*scale) event.target:getButtonLabel():setPositionY(5) end)
  :onButtonRelease(function(event) event.target:setScale(1.0*scale) event.target:getButtonLabel():setPositionY(5) end)
  :scale(scale)
  local nodes = bt:getButtonLabel():setPositionY(5)
  setLabelStroke(bt:getButtonLabel(),27,cc.c3b(241, 146, 118),1,nil,nil,nil,nil, true)

  return bt,nodes
end
--创建绿色按钮2
function createGreenBt2(text, scale)
  scale = scale or 1
  local bt = cc.ui.UIPushButton.new({
    normal = "common/common_GBt1.png",
    pressed = "common/common_GBt2.png"
    })
  :setButtonLabel(cc.ui.UILabel.new({UILabelType = 2, text = text, size = 23, color = cc.c3b(116, 233, 168)}))
  :scale(scale)

  return bt
end



--详情展示框
function showItemListBox(itemList)
  local masklayer =  UIMasklayer.new()
  :addTo(display:getRunningScene(),1000)
  local function  func()
      masklayer:removeSelf()
  end
  masklayer:setOnTouchEndedEvent(func)

  local box = display.newScale9Sprite("common/common_box3.png",nil,nil,cc.size(572,325))
  :addTo(masklayer)
  :pos(display.cx, display.cy)
  
  cc.ui.UILabel.new({UILabelType = 2, text = "详 情 展 示", size = 35, color = cc.c3b(255, 197, 0)})
  :addTo(box)
  :align(display.CENTER, box:getContentSize().width/2, box:getContentSize().height-40)

  local scrollWidth = 532
  local scrollHeight = 200

  local scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 255, 0, 0))
  scrollNode:setContentSize(scrollWidth, scrollHeight)
  scrollNode:pos(20, 40)

  for i,value in ipairs(itemList) do
    local pIcon
    if value.templateID<100 then
      pIcon = display.newSprite("itemBox/box_1.png")
      :addTo(scrollNode)
      :pos((i-1)*120+50, scrollHeight/2)
    end
    if value.templateID==GAINBOXTPLID_GOLD then
      display.newSprite("common/common_GoldGetBg.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_DIAMOND then
      display.newSprite("common/common_DiamondBg.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_EXP then
      display.newSprite("common/common_ExpBg.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_STRENGTH then
      display.newSprite("common/common_StaminaBg.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_REPUTATION then
      display.newSprite("common/shengwangIcon.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_EXPEDITION then
      display.newSprite("common/expedition.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif value.templateID==GAINBOXTPLID_HONOR then
      display.newSprite("common/honor.png")
      :addTo(pIcon)
      :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    else
      local item = createItemIcon(value.templateID, value.num)
      :addTo(scrollNode)
      :pos((i-1)*120+50, scrollHeight/2)
      :scale(0.8)
    end
  end
  

  --物品列表
  local desView = cc.ui.UIScrollView.new {
      -- bgColor = cc.c4b(200, 0, 0, 120),
      viewRect = cc.rect(20, 40, scrollWidth, scrollHeight),
      direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
      }
      :addTo(box)
      :addScrollNode(scrollNode)
  masklayer:addHinder(box)
end
--关闭按钮
function createCloseBt(scale)
  scale = scale or 1

  local bt = cc.ui.UIPushButton.new("SingleImg/messageBox/tip_close.png")
  :onButtonPressed(function(event) event.target:setScale(0.95*scale) end)
  :onButtonRelease(function(event) event.target:setScale(1.0*scale) end)
  :scale(scale)

  return bt
end

function shareTo3thPlatform()
    screenShoot(function ( ... )
        if device.platform == "android" then
            local className = "org.cocos2dx.utils.PSNative"
            local luaj = require("cocos.cocos2d.luaj")
            print("luaj",luaj)
            --复制图片到sd卡下面
            local ok,ret = luaj.callStaticMethod(className, "copyPicture2SDCard", {"share.jpg"}, "(Ljava/lang/String;)Ljava/lang/String;")
            if ok then
                print("sd卡路径:",ret)
                print("调用原生分享功能")
                local text = "隆重推荐《重装机兵》，大家快来玩！xxxxxxxxxxxxxxxxx"
                luaj.callStaticMethod(className, "Share", {ret,text}, '(Ljava/lang/String;Ljava/lang/String;)V')
            else
                print("调用复制失败")
            end
        elseif device.platform == "ios" then

        end
    end)
end

-- /*
--      * tag,1:微信，2：微信朋友圈，3：qq，4：QQ空间
--      * text,分享文字内容
--      * targetUrl,指向的链接
--      */
function UMengShare(tag,text,targetUrl)
    if gType_Chnl==AllChnlType.Chnl_MSDK then
      print("msdk没接友盟")
        return
    end
    initSharePlatform(1,"wx027afd499cfc44b6","d4624c36b6795d1d99dcf0547af5443d")
    screenShoot(function ( ... )
        if device.platform == "android" then
            local className = "org.cocos2dx.utils.PSNative"
            local luaj = require("cocos.cocos2d.luaj")
            print("luaj",luaj)
            --复制图片到sd卡下面
            local ok,ret = luaj.callStaticMethod(className, "copyPicture2SDCard", {"share.jpg"}, "(Ljava/lang/String;)Ljava/lang/String;")
            if ok then
                className = "org.cocos2dx.lua.umengShare"
                print("sd卡路径:",ret)
                local text = text or "隆重推荐《重装机兵》，大家快来玩！"
                luaj.callStaticMethod(className, "UMengShareMsg", {tag,ret,text,targetUrl}, '(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V')
                cc.Director:getInstance():pause()
            else
                print("调用复制失败")
            end
        elseif device.platform == "ios" then

        end
    end)
end

-- /*万一appId有问题，可以在这里修改，而不用动Java
--    * tag,1:微信，2:QQ
--    */
function initSharePlatform(tag,appId,key)
    if device.platform == "android" then
      print("call initSharePlatform，=====")
      local className = "org.cocos2dx.lua.umengShare"
      luaj.callStaticMethod(className, "initSharePlatform", {tag,appId,key}, '(ILjava/lang/String;Ljava/lang/String;)V')
    end
end

-- /*
--      * tag为渠道id,1:微信，2：微信朋友圈，3：qq，4：QQ空间
--      * code返回码,1:成功,2:失败,3:取消
--      */
function umshare_callback(retStr)--tag,code
    print("lua分享回调：",retStr)
    local arr = string.split(retStr,"|")
    local tag = tonumber(arr[1])
    local code = tonumber(arr[2])
    if code==1 then
      if tag==2 then
        print("朋友圈分享成功")
      end
    end
    if not g_bIsScenePaused then
      cc.Director:getInstance():resume()
    end
end

function screenShoot(_Call)
    local path = device.writablePath

    local screen = cc.RenderTexture:create(display.width, display.height)
    local temp  = display:getRunningScene()
    screen:begin()
    temp:visit()
    screen:endToLua()
    local pathsave = path.."share.jpg"

    if screen:saveToFile('share.jpg', 0) == true then
        print(pathsave)
    end
    local colorLayer1 = display.newLayer() --cc.LayerColor:create(cc.c4f(0, 0, 0, 125))
            :addTo(display.getRunningScene(),50)
    colorLayer1:setAnchorPoint(cc.p(0, 0))
    colorLayer1:setPosition(cc.p(0, display.height))


    local colorLayer2 = display.newLayer() --cc.LayerColor:create(cc.c4f(0, 0, 0, 125))
            :addTo(display.getRunningScene(),50)
    colorLayer2:setAnchorPoint(cc.p(0, 0))
    colorLayer2:setPosition(cc.p(0, - display.height))

    local function _callback( ... )
        if _Call and type(_Call)=="function" then
            _Call()
        end
    end

    local sq = transition.sequence{cc.MoveTo:create(0.3,cc.p(0,display.cy)),cc.MoveTo:create(0.2,cc.p(0,display.height))}
    colorLayer1:runAction(sq)

    local sq2 = transition.sequence{cc.MoveTo:create(0.3,cc.p(0,-display.cy)),cc.MoveTo:create(0.2,cc.p(0,-display.height)),cc.CallFunc:create(_callback)}
    colorLayer2:runAction(sq2)
end
--判断字符串中字的个数（一个汉字算一个，一个字母也算一个）
function getCharactersCnt(str)
  local HanziNum=0
  local othersNum = 0
  for i=1,#str do
    local curByte = string.byte(str, i)
    if curByte>127 then
      HanziNum = HanziNum + 1
    else
      othersNum = othersNum + 1
    end
  end

  return (HanziNum/3+othersNum)
end

function dumpTextureInfo()
    local texttureInfo = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    print("\n---------------------->>")
    print(texttureInfo)
    print("---------------------->>\n")
end

function getVersionCode()
    if g_isVersionAfter3==nil then
      return -1
    end
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
      local className = "org.cocos2dx.utils.PSNative"
      local luaj = require("cocos.cocos2d.luaj")
      local ok,ret = luaj.callStaticMethod(className, "getVersionCode", {}, "()I")
      if ok then
        return ret
      end
    end
    return -1
end

function getVersionName()
  if g_isVersionAfter3==nil then
    return "Unknown"
  end
  if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
    local className = "org.cocos2dx.utils.PSNative"
    local luaj = require("cocos.cocos2d.luaj")
    local ok,ret = luaj.callStaticMethod(className, "getVersionName", {}, "()Ljava/lang/String;")
    if ok then
      return ret
    end
  end
  return "Unknown"
end

function restartTheApp()
  if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID and getVersionCode()>=3 then
    local className = "org.cocos2dx.utils.PSNative"
    local luaj = require("cocos.cocos2d.luaj")
    luaj.callStaticMethod(className, "restartApp", {}, "()V")
  end
end

--prama,1:追加，2:换行追加，3:刷新
function printInScreen(msg,prama)
  print(msg)
  local g_IsDebug = false
  if not g_IsDebug then
    return
  end
  local _tag = 45308
  local _bg = display.getRunningScene():getChildByTag(_tag+1)
  local _label = display.getRunningScene():getChildByTag(_tag)
  if _label==nil then

    _bg = display.newScale9Sprite("common2/com2_Img_6.png",nil,nil,cc.size(10,10),cc.rect(40,40,1,1))
      :addTo(display.getRunningScene(),9999,_tag+1)
      :align(display.LEFT_TOP,50,display.height-50)
      :opacity(130)
    _bg:setColor(cc.c3b(0,0,0))

    _label = display.newTTFLabel{text="同学你好！欢迎充值！",color = cc.c3b(250,0,0)}
            :addTo(display.getRunningScene(),9999,_tag)
            :align(display.LEFT_TOP,60,display.height-60)
    local _singleLineHeight = _label:getContentSize().height
    _label:setWidth(display.width-120)
    _label:setLineHeight(_singleLineHeight)
  end

  _label:setString("")
  if prama==nil then
    prama = 1
  end
  local text = _label:getString()
  if prama==1 then
    text = text.."  <-->  "..msg
  elseif prama==2 then
    text = text..[[ 
]]..msg
  elseif prama==3 then
    text = msg
  end
  _label:setString(text)
  _bg:setContentSize(cc.size(_label:getContentSize().width,_label:getContentSize().height+20))
end

-- /*创建一个抛物线动作
--     参数：
--         t          时间
--         startPoint   开始点
--         endPoint   结束点
--         height     高度（影响抛物线的高度）
--         angle      角度（贝塞尔曲线两个控制点与y轴的夹角，直接影响精灵的抛出角度）
--     */
function  bezierEaseInOut(t, startPoint, endPoint, height , angle )
  height = height or 0
  angle = angle or 0

  -- 把角度转换为弧度
    local radian = angle*3.14159/180.0;
    -- 第一个控制点为抛物线左半弧的中点
    local q1x = startPoint.x+(endPoint.x - startPoint.x)/4.0;
    local q1 = cc.p(q1x, height + startPoint.y+math.cos(radian)*q1x);   
    -- 第二个控制点为整个抛物线的中点
    local q2x = startPoint.x + (endPoint.x - startPoint.x)/2.0;
    local q2 = cc.p(q2x, height + startPoint.y+math.cos(radian)*q2x);
    
    --曲线配置
    local bezierConfig ={
      q1,
      q2,
      endPoint,
  }

  return cc.BezierTo:create(t,bezierConfig)
end

function showDebugMsg(errorMessage, _callback)


  local _errmsg = "LUA ERROR: " .. tostring(errorMessage) .. "\n"
  _errmsg = _errmsg..debug.traceback("", 2)
  local _title = "发生了一些小错误"


  DCAgent.reportError("错误", _errmsg)

  
  if not g_IsDebug then
    return
  end

  local errMsgTTF = display.newTTFLabel{text = _errmsg,size = 19}
  errMsgTTF:setWidth(650)
  errMsgTTF:setLineHeight(30)

  local _size = errMsgTTF:getContentSize()
  _size.width = _size.width+60
  _size.height = _size.height+60+50
  local bg = display.newScale9Sprite("common2/com2_Img_6.png",nil,nil,_size,cc.rect(15,15,55,55))
          :addTo(display.getRunningScene(),100)
          :pos(display.cx,display.cy)

  display.newScale9Sprite("common/common_Frame5.png",nil,nil,cc.size(250,69),cc.rect(118,69,1,69))
    :addTo(bg)
    :pos(_size.width/2,_size.height-30)
  local titleTTF = display.newTTFLabel{text = _title,color = cc.c3b(255,255,0)}
          :addTo(bg)
          :pos(_size.width/2,_size.height-30)

  errMsgTTF:addTo(bg)
          :align(display.LEFT_TOP,30,_size.height-70)

  display.newTTFLabel{text = "截图反馈有奖励",color = cc.c3b(200,200,50)}
      :addTo(bg)
      :align(display.RIGHT_CENTER,_size.width-40,_size.height-60)

  local msgOKBt = cc.ui.UIPushButton.new({
      normal="SingleImg/messageBox/tip_okBtn.png",
      })
    :setButtonLabel(display.newTTFLabel{text = "关 闭",color = cc.c3b(100,100,100),size = 30})
    :addTo(bg)
    :pos(_size.width/2,20)
    :onButtonPressed(function(event)
      event.target:setScale(0.95)
      end)
    :onButtonRelease(function(event)
      event.target:setScale(1.0)
      end)
    :onButtonClicked(function ( ... )
      if _callback then
        _callback()
      end
      bg:removeSelf()
    end)

end

function isNodeValue(_userdata)
  if _userdata==nil then
    return false
  end
  local ret = nil
  if type(_userdata)=="userdata" then
    if _userdata.isNodeValue then --可能是老版本，c++代码是旧的
      ret = _userdata:isNodeValue()
    else
      ret = true
    end
  end
  return ret
end

function isRefValue(_userdata)
  if _userdata==nil then
    return false
  end
  local ret = nil
  if type(_userdata)=="userdata" then
    if _userdata.isRefValue then --可能是老版本，c++代码是旧的
      ret = _userdata:isRefValue() 
    else
      ret = true
    end
  end
  return ret
end

--把一个无环table写入一个字符串
function getTableStr(_t,_indent,_tabDescribe)  
    _indent = _indent or 1
    local szPrefix = string.rep("    ", _indent-1)
    local szRet = _tabDescribe or ""
    szRet = szRet.."\n"..szPrefix.."{\n"  
    function doT2S(_i, _v) 
        local szPrefix = string.rep("    ", _indent)
        if "number" == type(_i) then  
            szRet = szRet .. szPrefix.."[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ",\n"  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ",\n"  
            elseif "table" == type(_v) then  
                szRet = szRet .. getTableStr(_v,_indent + 1) .. ",\n"  
            else  
                szRet = szRet .. "nil,\n"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. szPrefix..'["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ",\n"  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ",\n"  
            elseif "table" == type(_v) then  
                szRet = szRet .. getTableStr(_v,_indent + 1) .. ",\n"  
            else  
                szRet = szRet .. "nil,\n"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. szPrefix.."}"  
    return szRet  
end

--mod==1追加，mod==2覆盖
function writeTabToLog(_tab,tabDescribe,logPath,mod)
  local logPath = logPath or "tabLog.log"
  logPath = device.writablePath..logPath
  local mod = mod or 1
  local str = ""
  if mod==1 then
    local oldStr = ""
    local file = io.open(logPath, "r")
    if file then
      oldStr = file:read("*a")
      file:close()
    end
    local temp = getTableStr(_tab,1,tabDescribe)
    str = oldStr.."\n\n\n==============================>>>>>>\n\n\n"..temp
  else
    local temp = getTableStr(_tab,1,tabDescribe)
    str = temp
  end
  local file = io.open(logPath, "w")
  file:write(str)
  file:close()
  
end

function m_addSearchPath()
  cc.FileUtils:getInstance():addSearchPath("res")
  cc.FileUtils:getInstance():addSearchPath("res/res2")
end
function getCurResPath()
  local res = ""
  if g_LanguageVer==0 then
    res = "res"
  elseif g_LanguageVer==1 then
    res = "res2"
  elseif g_LanguageVer==2 then
    res = "res3"
  end

  return res
end

return GlobalFunc

