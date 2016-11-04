--
-- Author: liufei
-- Date: 2015-02-09 11:25:26
--
TalkType = {
              SkillReady = 1, --技能冷却到位
              FireSkill  = 2, --释放技能
           }
local TalkNode = class("TalkNode",function()
	return display.newNode()
end)

function TalkNode:ctor()
	
end

function TalkNode:addTalk(params)
    -- params = {
    --             member 
    --             talkType
    --             checkId
    --           }
    local talkInfo = self:getLabelString(params)
    if talkInfo.canTalk == false then
      return
    end
    if self.talkBg ~= nil then
      self.talkBg:stopAllActions()
      self.talkBg:removeSelf()
      self.label:removeSelf()
      self.talkBg = nil
      self.label = nil
    end
    local bgName = nil
    if params.member.m_posType == MemberPosType.defenceType then
      bgName = "Battle/qipao-02.png"
    else
      bgName = "Battle/qipao-01.png"
    end
    self.talkBg = display.newSprite(bgName)
    :pos(0, 0)
    :addTo(self)
    local  talkBgSize = self.talkBg:getContentSize()
    self:setContentSize(talkBgSize)
    local labelPosX = 0
    if params.member.m_posType == MemberPosType.defenceType then
      labelPosX = -talkBgSize.width*0.45
    else
      labelPosX = -talkBgSize.width*0.45
    end
    local rows = #string.split(talkInfo.talkWords, "#")
    talkInfo.talkWords = string.gsub(talkInfo.talkWords, "#", "\n")
    self.label =  cc.ui.UILabel.new({UILabelType = 2, text = talkInfo.talkWords, size = talkBgSize.height*0.23, align = cc.ui.TEXT_ALIGN_LEFT ,color = wordColor})
    :align(display.CENTER_LEFT,labelPosX, -talkBgSize.height*0.44 + talkBgSize.height*0.13*rows)
    :addTo(self)
    self.label:setDimensions(talkBgSize.width*0.94, talkBgSize.height*0.94)
    local scaleValues = {
                          [1] = 0.4,
                          [2] = 0.68,
                          [3] = 0.96,
                        }
    self.talkBg:setScaleY(scaleValues[rows])
    self.talkBg:runAction(transition.sequence({
                                          cc.DelayTime:create(2),
                                          cc.CallFunc:create(function()
                                              self.label:removeSelf()
                                              self.talkBg:removeSelf()
                                              self.talkBg = nil
                                          end)
                                       }))
end

function TalkNode:getLabelString(params)
    local talkInfo = {
                        canTalk = false,
                        talkWords = "",
                     }
    if params.talkType == TalkType.SkillReady then
        talkInfo.talkWords = skillData[params.checkId]["talk1"]
        if talkInfo.talkWords == "null" then
          talkInfo.canTalk = false
        else
          talkInfo.canTalk = isTrigger(tonumber(skillData[params.checkId]["protalk"])*100,100,params.member:getRandomSeed())
        end
    elseif params.talkType == TalkType.FireSkill then
        talkInfo.talkWords = skillData[params.checkId]["talk2"]
        if talkInfo.talkWords == "null" then
          talkInfo.canTalk = false
        else
          talkInfo.canTalk = isTrigger(tonumber(skillData[params.checkId]["protalk"])*100,100,params.member:getRandomSeed())
        end
    else
      print("未处理的对话类型")
    end
    return talkInfo
end
return TalkNode