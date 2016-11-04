-- 获得物品通用显示框
-- Author: Jun Jiang
-- Date: 2015-02-04 15:23:18
--

--物品通用框用到的特殊物品ID
GAINBOXTPLID_GOLD       = 1 --金币
GAINBOXTPLID_DIAMOND    = 2 --钻石
GAINBOXTPLID_EXP        = 3 --经验
GAINBOXTPLID_STRENGTH   = 4 --燃油
GAINBOXTPLID_REPUTATION = 5 --声望
GAINBOXTPLID_GONGXUN    = 6 --功勋，军团获得
GAINBOXTPLID_HONOR      = 7 --荣誉点,成就任务获得
GAINBOXTPLID_EXPEDITION = 8 --远征币

UIGainBox = class("UIGainBox",UIMasklayer)

local curGuideBtn = nil

local scrollHeight = 200
local scrollWidth = 1280

UIGameBox_Instance = nil
function UIGainBox:ctor(params,_handler,titleType)
    self:setNodeEventEnabled(true)
    UIGameBox_Instance = self
	UIGainBox.super.ctor(self, params)
    self:setAlwaysExist(true)
	local tmpNode, tmpSize
   
    local titleType = titleType or 1
    local titleStr = "SingleImg/GainBox/title_"..titleType..".png"
    --self:removeChildByTag(11206)
    local gainNode= display.newNode()
            :addTo(self,1000,11206)
            :pos(display.cx,display.cy)
    self.box = gainNode
    local _size = cc.size(1280,270)
    gainNode:setContentSize(_size.width,_size.height)

    local blinklight = display.newSprite("SingleImg/GainBox/blinklight.png")
                            :addTo(gainNode)
                            :pos(0,_size.height/2)
                            :hide()

    blinklight:performWithDelay(function ()
        blinklight:show()
        blinklight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3,360)))
    end,0.5)


    local bg = display.newSprite("SingleImg/GainBox/gainBg.png")
                :addTo(gainNode)

    local tmpAction = transition.sequence({
                                                cc.ScaleTo:create(0  , 1 ,0.1),
                                                cc.ScaleTo:create(0.1, 1 ,1.11),
                                                cc.ScaleTo:create(0.1, 1 ,1.03),
                                                cc.ScaleTo:create(0.1, 1 ,0.99),
                                                cc.ScaleTo:create(0.1, 1 ,1)
                                        })
    bg:runAction(tmpAction)

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("SingleImg/GainBox/GainBoxAni.ExportJson")
    local armature = ccs.Armature:create("GainBoxAni")
                        :addTo(gainNode)
                        :pos(0,_size.height/2)

    local function playFlower()
        armature:getAnimation():play("titleFlower")
    end
    tmpAction = transition.sequence{
                                cc.Hide:create(),
                                cc.DelayTime:create(0.4),
                                cc.Show:create(),
                                cc.CallFunc:create(playFlower)
                            }

    armature:runAction(tmpAction)

    local title = display.newSprite(titleStr)
                    :addTo(gainNode)
                    :pos(0,_size.height/2)

    tmpAction = transition.sequence({           
                                cc.Hide:create(),
                                cc.DelayTime:create(0.5),
                                cc.Show:create(),
                                cc.ScaleTo:create(0  , 5.02 ,5.84),
                                cc.ScaleTo:create(0.1, 5.05 ,5.88),
                                cc.ScaleTo:create(0.1, 3.01 ,3.42),
                                cc.ScaleTo:create(0.1, 0.97 ,0.96),
                                cc.ScaleTo:create(0.1, 1 ,1)
                                    })
    title:runAction(tmpAction)


    tmpSize = self.box:getContentSize()

    local tipLabel_ = display.newTTFLabel{text = "点击空白处继续",size = 35 }
            :align(display.CENTER, display.width-150, 50)
            :addTo(self)

    local seq = transition.sequence({
        cc.FadeTo:create(1,90),
        cc.FadeTo:create(1,255),
        })
    transition.execute(tipLabel_, cc.RepeatForever:create(seq))


    tmpSize = tipLabel_:getContentSize()
	--确定按钮
	tmpNode = cc.ui.UIPushButton.new()
    				--:setButtonLabel(cc.ui.UILabel.new({text = "确定", size = 26, color = display.COLOR_GREEN}))
    				:align(display.CENTER, display.width-150, 50)
    				:addTo(self)
    				:onButtonClicked(function(event)
                         local _scene = cc.Director:getInstance():getRunningScene()
                         local g_taskLayer = _scene:getChildByTag(activityMenuLayerTag.taskTag)
                         local g_signLayer = _scene:getChildByTag(activityMenuLayerTag.signInTag)
    					if self.isNotRunning then
                            GuideManager:_addGuide_2(10304, _scene,g_taskLayer and handler(g_taskLayer,g_taskLayer.caculateGuidePos))
                            GuideManager:_addGuide_2(12204, _scene,g_taskLayer and handler(g_taskLayer,g_taskLayer.caculateGuidePos))
                            self:removeFromParent()
                            if _handler then
                                _handler()
                            end
                        else
                            self.isNotRunning = true
                            bg:scale(1):show():stopAllActions()
                            title:scale(1):show():stopAllActions()    
                            armature:getAnimation():gotoAndPause(30)
                            for k,v in pairs(self.allNode) do
                                v:stopAllActions()
                                v:scale(v._scale)
                                v:show()
                            end
                            
                        end
    				end)
    tmpNode:setContentSize(tmpSize.width,tmpSize.height)
    self.confirmBtn = tmpNode
    curGuideBtn = tmpNode
    -- display.newSprite("common/common_confirm.png")
    --     :addTo(tmpNode)

    self.scrollNode = display.newLayer() --cc.LayerColor:create(cc.c4b(0, 255, 0, 0))
    self.scrollNode:setContentSize(scrollWidth, scrollHeight)
    self.scrollNode:pos(-scrollWidth/2, -100)

    --物品列表
    self.desView = cc.ui.UIScrollView.new {
        --bgColor = cc.c4b(200, 0, 0, 120),
        viewRect = cc.rect(-scrollWidth/2, -100, scrollWidth, scrollHeight),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        }
        :addTo(self.box)
        :addScrollNode(self.scrollNode)

	-- self:addHinder(self.box)
    self:setAlwaysExist(false)
	self:setTouchCallback(function()
        if self.isNotRunning then
            self:removeFromParent()
            if _handler then
                _handler()
            end
        else
            self.isNotRunning = true
            bg:scale(1):show():stopAllActions()
            title:scale(1):show():stopAllActions()    
            armature:getAnimation():gotoAndPause(30)
    		for k,v in pairs(self.allNode) do
                v:stopAllActions()
                v:scale(v._scale)
                v:show()
            end
        end
	end)
end

function UIGainBox:onExit()
    UIGameBox_Instance = nil
end

--设置获得物品(tabItems:{{templateID=11, num=1}, {templateID=22, num=2}})
--templateID(GAINBOXTPLID_GOLD...)
function UIGainBox:SetGainItem(tabItems, titleImg)
    if titleImg then
        self.title:setTexture(titleImg)
    end

    local itemSize = cc.size(124,124)
    local tmpNode, nTplID, nNum, name
    local specialName = {"金币", "钻石", "经验","燃油","声望","功勋","荣誉","远征币"}

    local _interval = 160
    local length = (#tabItems-1) * _interval
    local ptX = 100
    print("mmmmm---------------length: ",length)
    if length+itemSize.width<display.width-10 then
        ptX = (display.width-length)/2
    end

    local ptY = 100
    local _startDelay = 1.3
    local _delay = 0.3
    self.allNode = {}
    for i=1, #tabItems do
    	local content = display.newNode()
                :addTo(self.scrollNode)
                :pos(ptX,ptY)

        ptX = ptX+_interval
        local k = i
        if k>#tabItems then
            break
        end
    	nTplID = tabItems[k].templateID
    	nNum = tabItems[k].num

        local _scale

    	--图标
    	if nTplID==GAINBOXTPLID_GOLD or nTplID==GAINBOXTPLID_DIAMOND or nTplID==GAINBOXTPLID_EXP 
            or nTplID==GAINBOXTPLID_STRENGTH or GAINBOXTPLID_REPUTATION==nTplID or GAINBOXTPLID_HONOR==nTplID 
            or nTplID==GAINBOXTPLID_EXPEDITION or nTplID==GAINBOXTPLID_GONGXUN then
    		tmpNode = GlobalGetSpecialItemIcon(nTplID, nNum)
    		name = specialName[nTplID]
            tmpNode:addTo(content)
            _scale = 1.17
            tmpNode._scale = _scale
            --名字
            display.newTTFLabel({
                text = name,
                size = 18,
                align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                })
                :addTo(tmpNode)
                :align(display.CENTER_TOP,52,-5)
    	else
            if nil~=itemData[nTplID] then
        		tmpNode = createItemIcon(nTplID, nNum)
                _scale = 1
                tmpNode._scale = _scale
        		name = itemData[nTplID].name
                --名字
            display.newTTFLabel({
                text = name,
                size = 18,
                align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                })
                :addTo(tmpNode)
                :align(display.CENTER_TOP,2,-68)
                :scale(1.17)
            tmpNode:addTo(content)
            else
                tmpNode = nil
                name = ""
            end
    	end



        if nil~=tmpNode then
            table.insert(self.allNode,tmpNode)
            local tmpAction = transition.sequence{
                    cc.Hide:create(),
                    cc.DelayTime:create(_startDelay+(i-1)*_delay),
                    cc.Show:create(),
                    cc.ScaleTo:create(0,1.16*_scale,1.16*_scale),
                    cc.ScaleTo:create(0.1,1.33*_scale,1.33*_scale),
                    cc.ScaleTo:create(0.1,1*_scale,1*_scale),
                }

            tmpNode:runAction(tmpAction)
        else
            print("tmpNode is nil     ",i)
        end
    end

    self:performWithDelay(function ( ... )
        self.isNotRunning = true
    end,_startDelay+table.nums(tabItems)*_delay)

end

function UIGainBox:caculateGuidePos(_guideId)
    local g_node, midPos, promptRect= nil,nil,nil
    local size = cc.size(0.1*display.width,0.1*display.width)
    if 10303==_guideId or 11303==_guideId or 12203==_guideId then
        g_node = curGuideBtn
        size = g_node:getContentSize()
        if g_node==nil then
            print("g_node==nil return")
            return nil
        end
        midPos = g_node:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        promptRect = cc.rect(midPos.x-size.width/2,midPos.y-size.height/2,size.width,size.height)
    end
    if midPos~=nil then
        midPos.x = midPos.x+30
        midPos.y = midPos.y-30
    end
    return midPos, promptRect
end

--获取特殊物品图标
function GlobalGetSpecialItemIcon(nTemplateID, nNum, _scale)
    _scale = _scale or 1
    local sprRet = nil
    local ttfColor = cc.c3b(255,255,255)

    local pIcon
    local boxName
    boxName = "itemBox/commonBox2.png"
    pIcon = display.newSprite(boxName)
        :scale(_scale)

    if GAINBOXTPLID_GOLD==nTemplateID then --金币
        sprRet = display.newSprite("common/common_GoldGetBg.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_DIAMOND==nTemplateID then --钻石
        sprRet = display.newSprite("common/common_DiamondBg.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_EXP==nTemplateID then --经验
        sprRet = display.newSprite("common/common_ExpBg.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_STRENGTH==nTemplateID then --燃油
        sprRet = display.newSprite("common/common_StaminaBg.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_REPUTATION==nTemplateID then --声望
        sprRet = display.newSprite("common/shengwangIcon.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_GONGXUN==nTemplateID then --功勋
        sprRet = display.newSprite("common/gongxunIcon.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_HONOR==nTemplateID then --荣誉点
        sprRet = display.newSprite("common/honorIcon.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    elseif GAINBOXTPLID_EXPEDITION==nTemplateID then --远征币
        sprRet = display.newSprite("common/expedition.png")
        sprRet:addTo(pIcon)
        :pos(pIcon:getContentSize().width/2, pIcon:getContentSize().height/2)
    else
        return sprRet
    end
    local tmpSize = pIcon:getContentSize()

    if nil~=nNum then
        local numBar = display.newScale9Sprite("common/common_Frame7.png",tmpSize.width/2, 
            20,
            cc.size(88, 23),cc.rect(10, 10, 30, 30))
          :addTo(pIcon)
        local numLabel = cc.ui.UILabel.new({font = "fonts/slicker.ttf", UILabelType = 2, text = "", size = 18, color = cc.c3b(255, 255, 255)})
        :addTo(numBar)
        :pos(numBar:getContentSize().width/2,numBar:getContentSize().height/2)
        numLabel:setAnchorPoint(0.5,0.5)
        numLabel:setString(nNum)

    end

    

    return pIcon
end

--显示获得物品(直接调用即可)
function GlobalShowGainBox(params, tabItems, titleType,_handler)
    if nil==tabItems or 0==#tabItems then
        return
    end
    
	local box = UIGainBox.new(params,_handler, titleType)
    box:SetGainItem(tabItems)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(box, 1000)
    
    
    if GuideManager.NextStep==10303 then
        box:setLocalZOrder(199)
        setIgonreLayerShow(true)
        GuideManager:_addGuide_2(10303, cc.Director:getInstance():getRunningScene(),handler(box,box.caculateGuidePos),1001)
    end
    if GuideManager.NextStep==12203 then
        box:setLocalZOrder(199)
        setIgonreLayerShow(true)
        GuideManager:_addGuide_2(12203, cc.Director:getInstance():getRunningScene(),handler(box,box.caculateGuidePos),1001)
    end
end