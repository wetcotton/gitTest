
teamUpgrade = class("teamUpgrade")

local pos = {
	320,260,200,140,80
}

function teamUpgrade:createUpgradeBox(level1,level2,oldSkl,_handler) 
	local tili1 = memberLevData[level1].energy
	local tili2 = memberLevData[level2].energy

	if display.getRunningScene().charactorLevel then
		display.getRunningScene().charactorLevel:setString(srv_userInfo.level)
	end

	local masklayer =  UIMasklayer.new()
    :addTo(display.getRunningScene(),800)
    local function  func()
    	if _handler and type(_handler)=="function" then
    		_handler()
    	end
        masklayer:removeSelf()
    end
    masklayer:setOnTouchEndedEvent(func)
    local light = display.newSprite("SingleImg/teamLevel/teamLevelImg1.png")
    :addTo(masklayer)
    :pos(display.cx, display.cy)
    light:runAction(cc.RepeatForever:create(cc.RotateBy:create(8, 180)))
    light:setScale(1.5)
    --框
	local upgradeBox = display.newSprite("SingleImg/teamLevel/teamLevelImg3.png",display.cx, display.cy)
	:addTo(masklayer)
	:pos(display.cx, display.cy)
	masklayer:addHinder(upgradeBox)
	-- upgradeBox:setVisible(false)

	-- local upgradeBox2 = display.newSprite("SingleImg/teamLevel/teamLevelImg3.png",display.cx, display.cy)
	-- :addTo(masklayer)
	-- :align(display.CENTER_TOP, display.cx, display.cy+upgradeBox:getContentSize().height/2)
	-- upgradeBox2:setScaleY(0)

	-- local act = cc.Sequence:create(cc.ScaleTo:create(0.3, 1, 1),cc.CallFunc:create(function()
	-- 		upgradeBox2:removeSelf()
	-- 		upgradeBox:setVisible(true)
	-- 		levelUpEff(masklayer, display.cx, display.cy)
	-- 	end))
	-- upgradeBox2:runAction(act)

	-- local titleBar = display.newSprite("SingleImg/teamLevel/teamLevelImg2.png")
	-- :addTo(upgradeBox)
	-- :pos(upgradeBox:getContentSize().width/2, upgradeBox:getContentSize().height +20)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("SingleImg/GainBox/GainBoxAni.ExportJson")
    local armature = ccs.Armature:create("GainBoxAni")
                        :addTo(upgradeBox)
                        :pos(upgradeBox:getContentSize().width/2, upgradeBox:getContentSize().height +20)

    local function playFlower()
        armature:getAnimation():play("titleFlower")
    end
    tmpAction = transition.sequence{
                                cc.Hide:create(),
                                cc.DelayTime:create(0.2),
                                cc.Show:create(),
                                cc.CallFunc:create(playFlower)
                            }

    armature:runAction(tmpAction)

    local title = display.newSprite("SingleImg/teamLevel/teamLevelImg2.png")
                    :addTo(upgradeBox)
                    :pos(upgradeBox:getContentSize().width/2, upgradeBox:getContentSize().height +20)

    tmpAction = transition.sequence({           
                                cc.Hide:create(),
                                cc.DelayTime:create(0.3),
                                cc.Show:create(),
                                cc.ScaleTo:create(0  , 5.02 ,5.84),
                                cc.ScaleTo:create(0.1, 5.05 ,5.88),
                                cc.ScaleTo:create(0.1, 3.01 ,3.42),
                                cc.ScaleTo:create(0.1, 0.97 ,0.96),
                                cc.ScaleTo:create(0.1, 1 ,1)
                                    })
    title:runAction(tmpAction)

	--关闭按钮
	-- local closeBt = cc.ui.UIPushButton.new({
	-- 	normal = "common2/com2_Btn_2_down.png",
	-- 	pressed = "common2/com2_Btn_2_down.png"
	-- 	})
	-- :addTo(upgradeBox)
	-- :pos(upgradeBox:getContentSize().width+20, upgradeBox:getContentSize().height-10)
	-- :onButtonClicked(function(event)
	-- 	masklayer:removeSelf()
	-- 	end)
	
	local mFontsize = 28
	local mcolor1 = cc.c3b(64, 34, 15)
	local mcolor2 = cc.c3b(255, 251, 182)
	local mcolor3 = cc.c3b(200, 255, 29)

	--战队等级
	local teamLevel = cc.ui.UILabel.new({UILabelType = 2, text = "战队等级：", size = mFontsize})
	:addTo(upgradeBox)
	:pos(100,pos[1])
	teamLevel:setAnchorPoint(0,0.5)
	teamLevel:setColor(mcolor1)
	local oldLevel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize, color = mcolor2})
	:addTo(upgradeBox,1)
	:pos(teamLevel:getPositionX()+teamLevel:getContentSize().width+10,pos[1]-2)
	oldLevel:setAnchorPoint(0,0.5)
	oldLevel:setString(level1)
	setLabelStroke(oldLevel,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	local jiantou1 = display.newSprite("SingleImg/addGold/addGoldImg1.png")
	:addTo(upgradeBox)
	:pos(oldLevel:getPositionX()+80,pos[1])
	jiantou1:setAnchorPoint(0,0.5)
	local newLevel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize})
	:addTo(upgradeBox,1)
	:pos(jiantou1:getPositionX()+jiantou1:getContentSize().width+30,pos[1]-2)
	newLevel:setAnchorPoint(0,0.5)
	newLevel:setColor(mcolor3)
	newLevel:setString(level2)
	setLabelStroke(newLevel,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	--燃油上限
	local teamTili = cc.ui.UILabel.new({UILabelType = 2, text = "燃油上限：", size = mFontsize})
	:addTo(upgradeBox)
	:pos(100,pos[2])
	teamTili:setAnchorPoint(0,0.5)
	teamTili:setColor(mcolor1)
	local oldTili = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize, color = mcolor2})
	:addTo(upgradeBox,1)
	:pos(teamTili:getPositionX()+teamTili:getContentSize().width+10,pos[2]-2)
	oldTili:setAnchorPoint(0,0.5)
	oldTili:setString(tili1)
	setLabelStroke(oldTili,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	local jiantou2 = display.newSprite("SingleImg/addGold/addGoldImg1.png")
	:addTo(upgradeBox)
	:pos(oldTili:getPositionX()+80,pos[2])
	jiantou2:setAnchorPoint(0,0.5)
	local newTili = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize})
	:addTo(upgradeBox,1)
	:pos(jiantou2:getPositionX()+jiantou2:getContentSize().width+30,pos[2]-2)
	newTili:setAnchorPoint(0,0.5)
	newTili:setColor(mcolor3)
	newTili:setString(tili2)
	setLabelStroke(newTili,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	--技能点数
	local nowdian = cc.ui.UILabel.new({UILabelType = 2, text = "技能点数：", size = mFontsize})
	:addTo(upgradeBox)
	:pos(100,pos[3])
	nowdian:setAnchorPoint(0,0.5)
	nowdian:setColor(mcolor1)
	local oldDian = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = mFontsize, color = mcolor2})
	:addTo(upgradeBox,1)
	:pos(teamTili:getPositionX()+teamTili:getContentSize().width+10,pos[3]-2)
	oldDian:setAnchorPoint(0,0.5)
	oldDian:setString(oldSkl)
	setLabelStroke(oldDian,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	local jiantou3 = display.newSprite("SingleImg/addGold/addGoldImg1.png")
	:addTo(upgradeBox)
	:pos(oldTili:getPositionX()+80,pos[3])
	jiantou3:setAnchorPoint(0,0.5)
	local newDian = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize})
	:addTo(upgradeBox,1)
	:pos(jiantou2:getPositionX()+jiantou3:getContentSize().width+30,pos[3]-2)
	newDian:setAnchorPoint(0,0.5)
	newDian:setColor(mcolor3)
	newDian:setString(srv_userInfo.sklPoint)
	setLabelStroke(newDian,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	--当前燃油
	local nowTili = cc.ui.UILabel.new({UILabelType = 2, text = "当前燃油：", size = mFontsize})
	:addTo(upgradeBox)
	:pos(100,pos[4])
	nowTili:setAnchorPoint(0,0.5)
	nowTili:setColor(mcolor1)
	local Tilinum = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "29", size = mFontsize, color = mcolor2})
	:addTo(upgradeBox,1)
	:pos(nowTili:getPositionX()+nowTili:getContentSize().width+10,pos[4]-2)
	Tilinum:setAnchorPoint(0,0.5)
	Tilinum:setString(srv_userInfo.energy)
	setLabelStroke(Tilinum,mFontsize,nil,1,nil,nil,nil,"fonts/slicker.ttf", true)
	
	--解锁
	local unLock = cc.ui.UILabel.new({UILabelType = 2, text = "解锁功能：", size = mFontsize})
	:addTo(upgradeBox)
	:pos(100,pos[5])
	unLock:setAnchorPoint(0,0.5)
	unLock:setColor(mcolor1)
	local lockfun = cc.ui.UILabel.new({UILabelType = 2, text = "无", size = mFontsize, color = mcolor2})
	:addTo(upgradeBox,1)
	:pos(Tilinum:getPositionX(),pos[5])
	lockfun:setAnchorPoint(0,0.5)
	if memberLevData[level2].des~="" and memberLevData[level2].des~="null" then
		lockfun:setString(memberLevData[level2].des)
	else
		lockfun:setString("无")
	end
	setLabelStroke(lockfun,mFontsize,nil,1,nil,nil,nil,nil, true)

	
end

return teamUpgrade