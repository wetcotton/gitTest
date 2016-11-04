-- Author: liufei
-- Date:   2015-08-31 21:09:57

SpeNoteState = {
                  Spe_Fire = 1,
                  Spe_Ready = 2,
               }

local SpeStateNote = class("SpeStateNote",function ()
    return display.newNode()
end)

function SpeStateNote:ctor()
    -- body
end

function SpeStateNote:showSpeNode(_speId, _speState)
    if self.m_stateNote ~= nil then
      self:removeStateNote()
    end

    self.m_stateNote = display.newSprite("Battle/SpeLoad/tzdfs_03.png")
    :addTo(self)
    local nSize = self.m_stateNote:getContentSize()
    self.m_stateNote:setPosition(-nSize.width*0.5,0)

    local girl = display.newSprite("Battle/SpeLoad/tzdfs_02-01.png")
    :align(display.CENTER_BOTTOM, nSize.width*0.18, 0)
    :addTo(self.m_stateNote)
    
    local stateName = ""
    if _speState == SpeNoteState.Spe_Fire then
       stateName = "Battle/SpeLoad/tzdfs_10.png"
    elseif _speState == SpeNoteState.Spe_Ready then
       stateName = "Battle/SpeLoad/tzdfs_04.png"
    else
       print("SpeStateNote: Unkown State Type!")
       return
    end
    local stateNameSp = display.newSprite(stateName)
    :pos(nSize.width*0.62,nSize.height*0.32)
    :addTo(self.m_stateNote)
    local bltName = display.newSprite("Battle/SpeLoad/speload_"..tostring(_speId)..".png")
    :pos(nSize.width*0.6,nSize.height*0.69)
    :addTo(self.m_stateNote)

    self.m_stateNote:runAction(transition.sequence({
                                                      cc.MoveBy:create(0.35, cc.p(nSize.width,0)),
                                                      cc.DelayTime:create(2),
                                                      cc.MoveBy:create(0.35, cc.p(-nSize.width,0)),
                                                      cc.CallFunc:create(handler(self,self.removeStateNote))
                                                   }))
end

function SpeStateNote:removeStateNote()
       self.m_stateNote:stopAllActions()
       self.m_stateNote:removeSelf()
       self.m_stateNote = nil
end

return SpeStateNote