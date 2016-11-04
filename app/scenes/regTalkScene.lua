
local regTalkScene = class("regTalkScene", function()
    return display.newScene("regTalkScene")
end)

function regTalkScene:ctor(...)
	self.bg = display.newSprite("Block/area_10001/city_bg.jpg")
    :addTo(self)
    self.bg:pos(display.cx,self.bg:getContentSize().height/2)

    local params = {...}
    local resName = ""
    local scale = 0.85
    if params[1] == 10121 then --男
        resName = "1012"
        scale = 0.85
    else--女
        resName = "1022"
        scale = 0.6
    end

    -- local manager = ccs.ArmatureDataManager:getInstance()
    -- manager:removeArmatureFileInfo("CG/cg2"..resName..".ExportJson")
    -- manager:addArmatureFileInfo("CG/cg2"..resName..".ExportJson")

    -- self.user = ccs.Armature:create("cg2"..resName)
    -- :align(display.CENTER_BOTTOM, display.width*0.4, - display.height*0.07)
    -- :addTo(self.bg)
    -- self.user:scale(scale)

    local newRole = sp.SkeletonAnimation:create("Battle/Hero/Hero_"..resName.."_.json","Battle/Hero/Hero_"..resName.."_.atlas",1)
    :addTo(self)
    :align(display.CENTER,display.cx-150,display.cy-200)
    -- :scale(1.2)
    newRole:setAnimation(0, "Standby", true)
end

function regTalkScene:onEnter()
    -- self.user:getAnimation():play("falldown")
    -- self:performWithDelay(self.showDialog, 3)
    self:showDialog()

    audio.playMusic("audio/mainbg.mp3", true)
end


function regTalkScene:showDialog()
    local dlg = UIDialog.new()
    dlg:addTo(self)
    dlg:TriggerDialog(10001, DialogType.RegisterPlot)
    dlg:SetFinishCallback(function()
        -- self:showSkipSelectDlg()
        self:ReqGetCBackPack()
    end)
end

function regTalkScene:showSkipSelectDlg( ... )
    local node = display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, 100))
            :addTo(self)
            
    local guider = display.newSprite("Bust/bust_guider.png")
            :addTo(node)
            :align(display.LEFT_BOTTOM,display.cx-275,display.height*0.2+85)
    local bg = display.newScale9Sprite("common2/com2_img_28.png",nil,nil,cc.size(582,189),cc.rect(25,25,90,90))
            :addTo(node)
            :pos(display.cx,display.height*0.2)
    display.newSprite("common2/com2_img_30.png")
            :addTo(bg)
            :align(display.LEFT_BOTTOM,5,100)
    display.newTTFLabel{text = "请选择是否跳过第一阶段新手引导",size = 21,color = cc.c3b(212,250,250)}
            :addTo(bg)
            :align(display.LEFT_BOTTOM,20,140)
    display.newTTFLabel{text = "特别提示：完成全部引导即可获得一份新手大礼包哦",size = 21,color = cc.c3b(248,182,45)}
            :addTo(bg)
            :align(display.LEFT_CENTER,20,120)
    local btn = cc.ui.UIPushButton.new{normal = "common2/com2_Btn_7_up.png",pressed = "common2/com2_Btn_7_down.png"}
        :addTo(bg)
        :pos(140,60)
        :onButtonClicked(function ( ... )
            self:ReqGetCBackPack()
            GuideManager:ReqSkip()
            node:removeSelf()
        end)
    display.newTTFLabel{text = "我要跳过",size = 32,color = cc.c3b(255,255,72)}
        :addTo(btn)

    btn = cc.ui.UIPushButton.new{normal = "common2/com2_Btn_6_up.png",pressed = "common2/com2_Btn_6_down.png"}
        :addTo(bg)
        :pos(440,60)
        :onButtonClicked(function ( ... )
            self:ReqGetCBackPack()
        end)
    display.newTTFLabel{text = "我要继续",size = 32,color = cc.c3b(93,230,101)}
        :addTo(btn)
end

function regTalkScene:ReqGetCBackPack()
    g_isNewCreate = true
    gotoSkillScene()
    -- startLoading()
    -- local sendData = {}
    -- sendData["characterId"]=srv_userInfo["characterId"]
    -- m_socket:SendRequest(json.encode(sendData), CMD_BACKPACK, self, self.onCarEquipmentResult)
end

function regTalkScene:onCarEquipmentResult(result) --获取背包信息
    if result["result"]==1 then
        print("获取背包信息成功啊！")
        -- app:enterScene("LoadingScene")
        g_isNewCreate = true
        gotoSkillScene()
    end
    endLoading()
end

return regTalkScene