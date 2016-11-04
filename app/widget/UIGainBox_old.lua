-- 获得物品通用显示框
-- Author: Jun Jiang
-- Date: 2015-02-04 15:23:18
--

UIGainBox_old = class("UIGainBox_old",UIMasklayer)

local curGuideBtn = nil

local offHeight = 200
local scrolWidth = 727

function UIGainBox_old:ctor(params,_handler)

	UIGainBox_old.super.ctor(self, params)
	local tmpNode, tmpSize
    
    local desPanel = display.newScale9Sprite("common/common_Frame4.png", nil, nil, cc.size(813,355+offHeight), cc.rect(50, 50, 10, 10))
                        :align(display.CENTER, display.cx, display.cy)
                        :addTo(self)
    tmpSize = desPanel:getContentSize()
    self.desPanel = desPanel

    self.bg2 = display.newScale9Sprite("common/common_Frame20.png",nil, 
        nil,cc.size(457, 298+offHeight),cc.rect(10, 10, 5, 5))
                       :addTo(desPanel)
                       :align(display.CENTER,tmpSize.width/2,tmpSize.height/2-5)

    self.bg3 = display.newScale9Sprite("common/common_Frame19.png",nil, 
        nil,cc.size(scrolWidth, 174+offHeight),cc.rect(10, 10, 5, 5))
                       :addTo(desPanel)
                       :align(display.CENTER,tmpSize.width/2,tmpSize.height/2+35)

	self.box = desPanel

	--标题框
	tmpNode = display.newScale9Sprite("common/common_Frame5.png",nil,nil,cc.size(246,69),cc.rect(30,0,1,69))
				:align(display.CENTER, tmpSize.width/2, tmpSize.height-10)
				:addTo(self.box)	
	--标题文字
	self.title = display.newSprite("common/common_WordsGain.png")
		:align(display.CENTER, tmpSize.width/2, tmpSize.height-10)
		:addTo(self.box)

	--确定按钮
	tmpNode = cc.ui.UIPushButton.new({normal="common/commonBt3_1.png", pressed="common/commonBt3_2.png"})
    				--:setButtonLabel(cc.ui.UILabel.new({text = "确定", size = 26, color = display.COLOR_GREEN}))
    				:align(display.CENTER, tmpSize.width/2, 65)
    				:addTo(self.box)
    				:onButtonClicked(function(event)
                        self:removeFromParent()
                        if _handler then
                            _handler()
                        end
    				end)
    self.confirmBtn = tmpNode
    curGuideBtn = tmpNode
    display.newSprite("common/common_confirm.png")
        :addTo(tmpNode)

    --物品列表
    self.listView = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 0, 0, 120),
        viewRect = cc.rect(0, 0, scrolWidth, 174+offHeight),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        }
        :addTo(self.bg3)

	self:addHinder(self.box)
	self:setOnTouchEndedEvent(function()
		self:removeFromParent()
	end)
end

--设置获得物品(tabItems:{{templateID=11, num=1}, {templateID=22, num=2}})
--templateID(GAINBOXTPLID_GOLD...)
function UIGainBox_old:SetGainItem(tabItems, titleImg)
    if titleImg then
        self.title:setTexture(titleImg)
    end

	local listView = self.listView
	if nil==listView or nil==tabItems then
		return
	end
    listView:removeAllItems()   --清空

    local itemSize = cc.size(scrolWidth, 130)
    local tmpNode, nTplID, nNum, name
    local specialName = {"金币", "钻石", "经验","燃油","声望","功勋"}
    local listNum = math.ceil(#tabItems/3)
    for i=1, listNum do
    	local item = listView:newItem()
    	local content = display.newNode()

        for j=1,3 do
            local k = (i-1)*3+j
            if k>#tabItems then
                break
            end
        	nTplID = tabItems[k].templateID
        	nNum = tabItems[k].num

        	--图标
        	if nTplID==GAINBOXTPLID_GOLD or nTplID==GAINBOXTPLID_DIAMOND or nTplID==GAINBOXTPLID_EXP or nTplID==GAINBOXTPLID_STRENGTH or GAINBOXTPLID_REPUTATION==nTplID then
        		tmpNode = GlobalGetSpecialItemIcon(nTplID, nNum)
        		name = specialName[nTplID]
        	else
                if nil~=itemData[nTplID] then
            		tmpNode = createItemIcon(nTplID, nNum, true)
                    tmpNode:scale(0.85)
            		name = itemData[nTplID].name
                    tmpNode:onButtonClicked(function()
                        print(nTplID)
                        local com = g_combinationLayer.new(tabItems[k].templateID)
                        :addTo(MainScene_Instance,50)
                        if com then
                            if com.comBt then com.comBt:setVisible(false) end
                            if com.comBt2 then com.comBt2:setVisible(false) end
                            if com.getBt then com.getBt:setVisible(false) end
                            if com.allgetBt then com.allgetBt:setVisible(false) end
                        end
                    end)
                else
                    tmpNode = nil
                    name = ""
                end
        	end

            local pointX = {-scrolWidth/2+100,0,scrolWidth/2-100}

            if nil~=tmpNode then
            	tmpNode:align(display.CENTER, pointX[j], 0)
            			:addTo(content)
            end


        	--名字
        	display.newTTFLabel({
        		text = name,
                size = 20,
                align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        		})
        		:align(display.CENTER, pointX[j], -60)
        		:addTo(content)
        end

    	item:addContent(content)
        item:setItemSize(itemSize.width, itemSize.height)
        
        -- if listNum==1 then
        --     item:setItemSize(itemSize.width,174+offHeight)
        -- end
        listView:addItem(item)
    end
    listView:reload()
end
