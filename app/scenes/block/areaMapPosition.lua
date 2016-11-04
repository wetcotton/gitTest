-- @Author: anchen
-- @Date:   2015-09-11 14:42:09
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-03-09 15:32:12
local fixHeight = 720
local fixBottomH = 0

g_totalAreaPositionX = 0 --当前整个地图的位置，记录地图移动的位置，下次自动定位
g_areaScreenCnt = 3 --当前显示几屏地图
g_lastAreaId = 10013

--每一块地图的位置
g_areaPos = {
    --第一屏
    cc.p(244, fixHeight - 255),
    cc.p(592, fixHeight - 166),
    cc.p(333, 226+fixBottomH),
    cc.p(670, 115+fixBottomH),
    cc.p(892, 334+fixBottomH),
    cc.p(display.width - 300, fixHeight - 136),
    --第二屏
    cc.p(display.width + 10, 360+fixBottomH),
    cc.p(display.width + 351, 211+fixBottomH),
    cc.p(display.width + 788, 190+fixBottomH),
    cc.p(display.width + 528, fixHeight - 224),
    cc.p(display.width + 953, fixHeight - 99),
    cc.p(display.width*2 - 235, 332+fixBottomH),
    --第三屏
    cc.p(display.width*2 + 125, fixHeight - 272),
    cc.p(display.width*2 + 557, fixHeight - 222),
    cc.p(display.width*2 + 107, 190+fixBottomH),
    cc.p(display.width*2 + 633, 227+fixBottomH),
    cc.p(display.width*3 - 220, 221+fixBottomH),
    cc.p(display.width*3 - 238, fixHeight - 219),
}

--每一块地图触摸区域的位置
g_areaTouchPos = {
    cc.p(-50, 100),
    cc.p(0, 20),
    cc.p(135, 80),
    cc.p(0, -40),
    cc.p(0, 0),
    cc.p(40, 50),

    cc.p(30, -50),
    cc.p(80, -70),
    cc.p(-20, -40),
    cc.p(70, -40),
    cc.p(10, 0),
    cc.p(40, 30),

    cc.p(0, 80),
    cc.p(30, 45),
    cc.p(30, -75),
    cc.p(0, -80),
    cc.p(15, -20),
    cc.p(20, 60),
}

--每一块地图触摸区域的大小
g_areaTouchSize = {
    cc.size(400, 300),
    cc.size(200, 300),
    cc.size(380, 150),
    cc.size(400, 160),
    cc.size(330, 230),
    cc.size(450, 180),

    cc.size(400, 350),
    cc.size(240, 300),
    cc.size(300, 320),
    cc.size(350, 230),
    cc.size(500, 130),
    cc.size(270, 370),

    cc.size(380, 370),
    cc.size(440, 350),
    cc.size(570, 220),
    cc.size(410, 290),
    cc.size(400, 400),
    cc.size(400, 310),
}