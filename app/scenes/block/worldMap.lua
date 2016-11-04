-- @Author: anchen
-- @Date:   2015-10-19 10:14:17
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-03-30 16:00:38

require("app.scenes.block.areaMapPosition")
local worldMap = class("worldMap", function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

local cur_areaId

function worldMap:ctor()
    self.myLayer = display.newLayer() --display.newColorLayer(cc.c4f(0, 0, 0, 255))
    :addTo(self)

    self.backBt = cc.ui.UIPushButton.new({
        normal = "common/common_BackBtn_1.png",
        pressed = "common/common_BackBtn_2.png"})
    :addTo(self,2)
    :align(display.LEFT_TOP, 0, display.height )
    self.backBt:onButtonClicked(function(event)
        -- local imgName = "Block/area_"..areaData[srv_userInfo.areaId].resId.."/city_bg.jpg"
        -- MainScene_Instance.mainBg:setTexture(imgName)
        setMainSceneBgImg(MainScene_Instance.mainBg)
        local townName = areaData[areaData[srv_userInfo.areaId].resId].name2
        MainScene_Instance.townName:setString(townName)
        audio.playMusic("audio/mainbg.mp3", true)
        self:removeSelf()
        end)

    self.isMoved = false
    local beganX
    self.myLayer:setTouchEnabled(true)
    self.myLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self.myLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
    local x, y, prevX, prevY = event.x, event.y, event.prevX, event.prevY
        if event.name == "began" then
            self.isMoved = false
            beganX = x
            -- print("layer began")
        elseif event.name == "moved" then
            if math.abs(beganX - x)>50 then
                self.isMoved = true
            end
            local setX = self.myLayer:getPositionX() + x - prevX
            -- local setY = self.myLayer:getPositionY() + y - prevY
            if setX>=0 then setX=0 
            elseif setX<=-display.width*(g_areaScreenCnt-1) then setX = -display.width*(g_areaScreenCnt-1) end
            self.myLayer:setPosition(setX, 0)
            self.MapX = setX
            -- print("layer moved")
        elseif event.name == "ended" then
            -- print("layer ended")
        end
            return true
        end)
    self.MapX = 0 --地图位置的偏移量
end

function worldMap:onEnter()
    self.areaBt = {}
    self:getWorldMap()
end
function worldMap:onExit()
end

function worldMap:getWorldMap()
    local maxAreaId = 10018 --最后一个大区的ID
    self.maxAreaId = maxAreaId

    self.myLayer:setScaleY(display.height/720)
    local clickFlag = false
    for i=10001,maxAreaId do
        local btFlag = {}
        --每块区域图片
        local areaBt = cc.ui.UIPushButton.new({
            normal="area/map/normal/"..i..".png",
            -- pressed = "area/map/down/"..i..".png"
            },{grayState=true})
        :addTo(self.myLayer,0,i)
        :pos(g_areaPos[i-10000].x, g_areaPos[i-10000].y)
        areaBt:setTouchSwallowEnabled(false)
        areaBt:setTouchEnabled(false)
        self.areaBt[i] = areaBt

        local tmpSize = areaBt:getContentSize()
        local tmpCx = tmpSize.width/2
        local tmpCy = tmpSize.height/2

        local bottom = display.newSprite("area/bottom.png")
        :addTo(areaBt)
        :pos(tmpCx + g_areaTouchPos[i-10000].x, tmpCy + g_areaTouchPos[i-10000].y)
        local name = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 25})
        :addTo(bottom)
        :pos(bottom:getContentSize().width/2, bottom:getContentSize().height/2)
        name:setAnchorPoint(0.5,0.5)
        name:setString(areaData[i].name)

        --触摸结点
        -- local isMoved = false
        local touchNode = display.newNode()
        :addTo(areaBt)
        :pos(tmpCx + g_areaTouchPos[i-10000].x, tmpCy + g_areaTouchPos[i-10000].y)
        touchNode:setContentSize(g_areaTouchSize[i-10000])
        touchNode:setTouchSwallowEnabled(false)
        touchNode:setAnchorPoint(0.5,0.5)
        touchNode:setTouchEnabled(true)
        touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        local x, y, prevX, prevY = event.x, event.y, event.prevX, event.prevY
            if event.name == "began" then
                -- isMoved = false
                if not canAreaEnter(i) then
                    return false
                end
                areaBt:setButtonImage("normal", "area/map/down/"..i..".png")
                -- print("layer began2")
            elseif event.name == "moved" then
                -- isMoved = true
                -- print("layer moved2")
            elseif event.name == "ended" then
                areaBt:setButtonImage("normal", "area/map/normal/"..i..".png")
                if not self.isMoved then
                    --判断触摸点是否超出触摸区域
                    -- local minX, maxX, minY, maxY = 0, 0, 0, 0
                    -- local panNum = 50
                    -- minX = touchNode:getPositionX() - panNum
                    --                 + areaBt:getPositionX() - areaBt:getContentSize().width/2
                    -- maxX = touchNode:getPositionX() + panNum
                    --                 + areaBt:getPositionX() - areaBt:getContentSize().width/2
                    -- minY = touchNode:getPositionY() - panNum
                    --                 + areaBt:getPositionY() - areaBt:getContentSize().height/2
                    -- maxY = touchNode:getPositionY() + panNum
                    --                 + areaBt:getPositionY() - areaBt:getContentSize().height/2
                    -- minX = minX + self.MapX
                    -- maxX = maxX + self.MapX
                    
                    -- if x<minX or x>maxX or y<minY or y>maxY then
                    --     print("touch out")
                    --     return
                    -- end
                    -- print("touch area "..i)
                    if areaData[i].isOpen==0 then
                        showTips("大区暂未开放，尽请期待。")
                        return
                    end
                    cur_areaId=i
                    if srv_userInfo.level < areaData[cur_areaId].level then
                        showTips(areaData[cur_areaId].level.."级后才能进入")
                        return 
                    end
                    setIgonreLayerShow(true)
                    if next(srv_blockData)~=nil and srv_userInfo["areaId"]==cur_areaId then
                        -- print("当前区")
                        self.mType = 1
                        g_blockMap.new(cur_areaId, nil, 1)
                        :addTo(MainScene_Instance, 50)
                        self:removeSelf()
                    else
                        -- print("其他区")
                        -- self.mType = 1
                        startLoading()
                        sendAreaList = getSendAreaList(cur_areaId)
                        local SelectAreaData={}
                        SelectAreaData["characterId"]=srv_userInfo["characterId"]
                        SelectAreaData["areaId"]=sendAreaList
                        m_socket:SendRequest(json.encode(SelectAreaData), CMD_ENTER_BLOCK, self, self.onEnterBlockResult)
                    end
                    GuideManager:removeGuideLayer()
                    GuideManager:_addGuide_2(12403, display.getRunningScene(),handler(self,self.caculateGuidePos))
                end
            end
                return true
            end)
        -- local testNode = display.newScale9Sprite("common/common_Frame13.png",nil, nil, g_areaTouchSize[i-10000])
        -- :addTo(areaBt)
        -- :pos(tmpCx + g_areaTouchPos[i-10000].x, tmpCy + g_areaTouchPos[i-10000].y)
    end

    local tmpAreaId = blockIdtoAreaId(srv_userInfo["maxBlockId"])
    --判断是否灰色，箭头指向哪个区域
    local areaFlag = {}
    self.sortAreaData = getSortAreaData()
    for id,data in pairs(self.sortAreaData) do
        local tmp = data
        tmp.flag = 0
        areaFlag[id] = tmp
        if not canAreaEnter(data.id) then
            if self.myLayer:getChildByTag(data.id) and data.id<=maxAreaId then
                self.myLayer:getChildByTag(data.id):setButtonEnabled(false)
            end
        elseif canAreaEnter(data.id) then
            if data.id<=maxAreaId then
                local tmp = data
                tmp.flag = 1
                areaFlag[id]=tmp
                -- local parentNode = self.myLayer:getChildByTag(data.id)
                -- local tmpCx = parentNode:getContentSize().width/2
                -- local tmpCy = parentNode:getContentSize().height/2
                -- local arrow = getArrow()
                -- :addTo(parentNode)
                -- :pos(tmpCx + g_areaTouchPos[data.id-10000].x, tmpCy + g_areaTouchPos[data.id-10000].y+ 50)
                -- arrow:setAnchorPoint(0.5,0)
                -- arrow:setTag(10)

                if self.myLayer:getChildByTag(data.id-1)~=nil then
                    local tmp = areaFlag[id-1]
                    tmp.flag = 0
                    areaFlag[id-1]=tmp
                    -- self.myLayer:getChildByTag(data.id-1):getChildByTag(10):removeSelf()
                end
            end
        end
    end
    for id,data in pairs(areaFlag) do
        -- print(id)
        -- printTable(data)
        if data.flag==1 then
            local parentNode = self.myLayer:getChildByTag(data.id)
            local tmpCx = parentNode:getContentSize().width/2
            local tmpCy = parentNode:getContentSize().height/2
            getArrow("Block/curBlock.png", self.myLayer,
                g_areaPos[id].x+tmpCx + g_areaTouchPos[data.id-10000].x-30, 
                g_areaPos[id].y+tmpCy + g_areaTouchPos[data.id-10000].y + 40)

        end
    end
    
    local areaIdx = tmpAreaId%1000
    if areaIdx>4 and areaIdx<(#g_areaPos-4) then
        self.myLayer:setPositionX(-g_areaPos[areaIdx].x+display.cx)
    end

    self:addAreaEffects()
end

function worldMap:addAreaEffects()
    --静止的云
    local cloud = display.newSprite("area/areaEffects/cloud.png")
    :addTo(self.myLayer)
    :pos(-200,350)
    local act = cc.Sequence:create(cc.MoveBy:create(20, cc.p(display.width-200,0)), cc.CallFunc:create(function()
        cloud:setPositionX(-200)
        end))
    cloud:runAction(cc.RepeatForever:create(act))

    --毒气
    local ts = 1.0
    -- display.addSpriteFrames("area/areaEffects/areaGasImg.plist", "area/areaEffects/areaGasImg.png")
    local frames = display.newFrames("areaGasImg%d.png", 1, 20)
    local animation = display.newAnimation(frames, ts / 20)
    gasSprite = display.newGraySprite("#areaGasImg1.png")
    :addTo(self.myLayer)
    :pos(592, display.height - 166)
    gasSprite:playAnimationForever(animation)


    --火焰
    local firePos = {
        {pos = cc.p(625, 135),scale = 1},
        {pos = cc.p(688,183),scale = 1},
        {pos = cc.p(display.width*3 - 315, 230),scale = 1.3},
        {pos = cc.p(display.width*3 - 265, 385),scale = 1},
        {pos = cc.p(display.width*3 - 245, 335),scale = 1},

        {pos = cc.p(display.width*3 - 220, 275),scale = 1.3},
        {pos = cc.p(display.width*3 - 180, 190),scale = 1.3},
    }
    local ts = 0.7
    local fireNode = {}
    for i = 1,#firePos do
        -- display.addSpriteFrames("area/areaEffects/areaFireImg.plist", "area/areaEffects/areaFireImg.png")
        local frames = display.newFrames("areaFireImg%d.png", 1, 8)
        local animation = display.newAnimation(frames, ts / 8)
        fireNode[i] = display.newGraySprite("#areaFireImg1.png")
        :addTo(self.myLayer)
        :pos(firePos[i].pos.x, firePos[i].pos.y)
        :scale(firePos[i].scale)
        fireNode[i]:playAnimationForever(animation)
    end

    --雪花
    local particle = cc.ParticleSystemQuad:create("area/areaEffects/snow_1.plist")
    :addTo(self.myLayer)
    :pos(display.width + 50, 360)
    :scale(0.9)

    --烟雾
    local smokePos = {
        {pos = cc.p(820, 165),scale = 0.6},
        {pos = cc.p(740,70),scale = 0.6},
        {pos = cc.p(display.width + 511, 231),scale = 0.8},
        {pos = cc.p(display.width*3 - 195, 405),scale = 0.7},
        {pos = cc.p(display.width*3 - 100, 220),scale = 0.9},
    }
    local ts = 0.7
    local smokeNode = {}
    for i=1,#smokePos do
        -- display.addSpriteFrames("area/areaEffects/areaSmokeImg.plist", "area/areaEffects/areaSmokeImg.png")
        local frames = display.newFrames("areaSmokeImg%d.png", 1, 6)
        local animation = display.newAnimation(frames, ts / 6)
        smokeNode[i] = display.newGraySprite("#areaSmokeImg1.png")
        :addTo(self.myLayer)
        :pos(smokePos[i].pos.x, smokePos[i].pos.y)
        :scale(smokePos[i].scale)
        smokeNode[i]:playAnimationForever(animation)
    end
    --瀑布
    local ts = 0.4
    -- display.addSpriteFrames("area/areaEffects/waterfallImg.plist", "area/areaEffects/waterfallImg.png")
    local frames = display.newFrames("waterfallImg%d.png", 1, 6)
    local animation = display.newAnimation(frames, ts / 6)
    local waterfallNode = display.newGraySprite("#waterfallImg1.png")
    :addTo(self.myLayer)
    :pos(display.width*2 - 100, 312)
    waterfallNode:playAnimationForever(animation)
    --瀑布水雾
    local ts = 0.5
    -- display.addSpriteFrames("area/areaEffects/fallSmokeImg.plist", "area/areaEffects/fallSmokeImg.png")
    local frames = display.newFrames("fallSmokeImg%d.png", 1, 10)
    local animation = display.newAnimation(frames, ts / 10)
    local fallSmokeNode = display.newGraySprite("#fallSmokeImg1.png")
    :addTo(self.myLayer)
    :pos(display.width*2-50 , 342)
    fallSmokeNode:playAnimationForever(animation)
    --龙卷风
    local TornadoPos = {
        {pos = cc.p(display.width*2 + 443, 537),scale = 1.0},
        {pos = cc.p(display.width*2 + 523, 417),scale = 0.6},
    }
    local ts = 0.5
    for i=1,#TornadoPos do
        -- display.addSpriteFrames("area/areaEffects/areaTornadoImg.plist", "area/areaEffects/areaTornadoImg.png")
        local frames = display.newFrames("areaTornadoImg%d.png", 1, 10)
        local animation = display.newAnimation(frames, ts / 10)
        local areaTornadoNode = display.newGraySprite("#areaTornadoImg1.png")
        :addTo(self.myLayer)
        :pos(TornadoPos[i].pos.x, TornadoPos[i].pos.y)
        :scale(TornadoPos[i].scale)
        areaTornadoNode:playAnimationForever(animation)
    end
    


    for id,data in pairs(self.sortAreaData) do
        if canAreaEnter(data.id) then
            if id==2 then
                gasSprite:clearFilter()
            elseif id==4 then
                fireNode[1]:clearFilter()
                fireNode[2]:clearFilter()
            elseif id==12 then
                waterfallNode:clearFilter()
            elseif id==17 then
                fireNode[3]:clearFilter()
                fireNode[4]:clearFilter()
                fireNode[5]:clearFilter()
                fireNode[6]:clearFilter()
                fireNode[7]:clearFilter()
            end
        end
    end
end


function worldMap:onEnterBlockResult(result)
    endLoading()
    if result["result"]==1 then
        self.mType = 1
        srv_userInfo["areaId"]=cur_areaId
        g_blockMap.new(cur_areaId, nil, 1)
        :addTo(MainScene_Instance, 50)
        self:removeSelf()
    else
        cur_areaId = cur_areaId - 1
        showTips(result.msg)
    end
end


return worldMap