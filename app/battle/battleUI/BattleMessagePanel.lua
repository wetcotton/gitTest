  --
-- Author: liufei
-- Date: 2014-11-19 11:57:27
--
require("app.battle.BattleInfo")

-- 单个message的格式
-- local BattleOneMessage = {
-- 	                        "type" = 0,             --信息类型
-- 	                        "initiativeId" = 0,     --主动ID
--                          "passiveId" = 0,        --被动ID
-- 	                        "initiativeName" = 0,   --主动名字
--                          "passiveName" = 0,      --被动名字
--                          "buffId" = 0,           --buff
--                          "buffName" = 0,         --buff                          
--                          "skillId" = 0,          --skill
--                          "skillName" = 0,          --skill
--                          "damage" = 0,           --造成的损伤或者恢复值
--                          }

local BattleMessagePanel = class("BattleMessagePanel", function()
	return display.newLayer()
end)

function BattleMessagePanel:ctor()
	  self.meesagBg = display.newSprite("Battle/ZD-09.png")
    :addTo(self)
    self:setContentSize(self.meesagBg:getContentSize())
    self.m_step = 0
    self.showIndex = 1
    --5个label
    self.allMessageLabel = {
                              [1] = nil,
                              [2] = nil,
                           }

    --label字数不超过19个
    for i=1,2 do
    	  local messageLabel=cc.ui.UILabel.new({UILabelType = 2, text = "", size = self.meesagBg:getContentSize().height/8, align = cc.ui.TEXT_ALIGN_LEFT ,color = cc.c3b(55, 227, 232)})
        :pos(self.meesagBg:getContentSize().width*0.09, self.meesagBg:getContentSize().height - self.meesagBg:getContentSize().height/3*i)
        :addTo(self.meesagBg)
        messageLabel:setDimensions(self.meesagBg:getContentSize().width*0.75, self.meesagBg:getContentSize().height*0.3)
        self.allMessageLabel[i] = messageLabel
    end
end

function BattleMessagePanel:addMessage(_message)
	-- print("************************")
	-- self.m_step = self.m_step + 1
	-- print(self.m_step)
	-- printTable(_message)
	-- print("************************")
    
  local messageStr = nil
	if tonumber(_message["type"]) == BattleMessageType.kMessageAttack  then
		--暂不显示
		return
    elseif tonumber(_message["type"]) == BattleMessageType.kMessageSkill then
    	messageStr = _message["initiativeName"].."开始释放技能".._message["skillName"]
    elseif tonumber(_message["type"]) == BattleMessageType.kMessageBeSkilled then
    	local tStr = nil
    	if tonumber(_message["damage"]) > 0 then
    		tStr = "的伤害"
    	else
    		tStr = "治疗"
    	end 
    	local  damageNum =  math.abs(tonumber(_message["damage"]))
      messageStr = _message["passiveName"].."受到技能".._message["skillName"]..tStr..damageNum
    elseif tonumber(_message["type"]) == BattleMessageType.kMessageBuffOn then
        messageStr = _message["passiveName"].."获得Buff:".._message["buffName"]
    elseif tonumber(_message["type"]) == BattleMessageType.kMessageBuffOff then
        messageStr = _message["passiveName"].."的".._message["buffName"].."效果消失"
    elseif tonumber(_message["type"]) == BattleMessageType.kMessageDead then
        messageStr = _message["initiativeName"].."死亡！"
	end
	self:showMessage(messageStr)
end

function BattleMessagePanel:showMessage(_mStr)
	 if self.showIndex <= 2 then
	    self.allMessageLabel[self.showIndex]:setString(tostring(_mStr))
	    self.showIndex = self.showIndex + 1
	    return
	 end
   --挤掉第一个
   self.allMessageLabel[1]:setString(self.allMessageLabel[2]:getString())
   self.allMessageLabel[2]:setString(tostring(_mStr))
end

return BattleMessagePanel