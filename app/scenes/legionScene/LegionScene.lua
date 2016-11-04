legionIconLayer = require("app.scenes.legionScene.LegionIcon")
local Initlayer = require("app.scenes.legionScene.InitLayer")
myLegionLayer = require("app.scenes.legionScene.myLegionLayer")

LegionScene=class("LegionScene", function()
    local layer =  display.newLayer("LegionScene")
    layer:setNodeEventEnabled(true)
    return layer
    end)

--self.legionBox子节点
INITLEGION_TAG          = 1000
MYLEGION_TAG            = 1001
LEGIONMANAGE_TAG        = 1002
LEGION_SETTING_TAG      = 1003
LEGION_APPLY_TAG        = 1004
LEGION_PROMOTE_TAG      = 1005
LEGION_INFO_TAG         = 1006

borderNode = nil
borderSize = nil
borderHead = nil
g_myLegionLayer = nil

LegionScene.Instance=nil
function LegionScene:ctor()
    display.addSpriteFrames("Image/legion_img.plist", "Image/legion_img.png")

    local bStep = string.sub(tostring(GuideManager.NextStep), 1,3)
    if tonumber(bStep)==131 then
        GuideManager:removeGuideLayer()
        GuideManager:forceSendFinishStep(-1,true)
    end
	local mainBg = getMainSceneBgImg(mapAreaId)
    :addTo(self)
    local fixMasklayer =  display.newLayer() --display.newColorLayer(cc.c4b(0, 0, 0, fixMasklayerA))
    :addTo(self)

    local backBt =  cc.ui.UIPushButton.new({
    	normal = "common/common_BackBtn_1.png",
    	pressed = "common/common_BackBtn_2.png"
    	})
    :addTo(self,1)
    :align(display.LEFT_TOP, 0, display.height )
    backBt:setAnchorPoint(0,1)
    backBt:onButtonClicked(function(event)
        -- MainSceneEnterType = 0
        -- if self.border:getChildByTag(LEGIONMANAGE_TAG)~=nil then
        --     self.border:removeAllChildren()
        --     myLegionLayer.new()
        --     :addTo(self.border,0,MYLEGION_TAG)
        -- else
        --     if TaskLayer.Instance==nil then --如果从任务跳转进来，不需要显示顶部金币条
        --         display.getRunningScene():setTopBarVisible(true)
        --     end
        --     self:removeSelf()

        -- end
            MainSceneEnterType = EnterTypeList.NORMAL_ENTER
            self:removeSelf()
            display.getRunningScene():setTopBarVisible(true)

    	end)

    self.legionBox = display.newScale9Sprite("#legion_img22.png",nil,nil,cc.size(1100,610))
    :addTo(self)
    :pos(display.cx,display.cy-35)

    borderSize = self.legionBox:getContentSize()

    borderHead = display.newSprite("#legion_img19.png")
    :addTo(self.legionBox)
    :pos(borderSize.width/2, borderSize.height - 70)


    -- self.border = display.newScale9Sprite("common/common_Frame10.png",display.cx,display.cy-40,
    --     cc.size(968, 520),cc.rect(20,20,11,11))
    -- :addTo(self)
    borderNode = self.legionBox
    -- borderSize = borderNode:getContentSize()



    if srv_userInfo["armyName"]=="" then
        Initlayer.new()
        :addTo(self.legionBox,0,INITLEGION_TAG)
    else
    	g_myLegionLayer =  myLegionLayer.new()
        :addTo(self.legionBox,0,MYLEGION_TAG)
    end

end
function LegionScene:onEnter()
    LegionScene.Instance=self
end
function LegionScene:onExit()
    LegionScene.Instance=nil
    display.removeSpriteFramesWithFile("Image/legion_img.plist", "Image/legion_img.png")
end


return LegionScene