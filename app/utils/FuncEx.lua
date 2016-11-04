-- 接口扩展
-- Author: Jun Jiang
-- Date: 2015-03-02 11:29:33
--
--[[
display.newLine(points, params)的扩展，可一次绘制多条线段
]]
function display.newLineEx(points, params, drawNode)
    local radius
    local borderColor
    local scale

    if not params then
        borderColor = cc.c4f(0,0,0,1)
        radius = 0.5
        scale = 1.0
    else
        borderColor = params.borderColor or cc.c4f(0,0,0,1)
        radius = (params.borderWidth and params.borderWidth/2) or 0.5
        scale = checknumber(params.scale or 1.0)
    end

    for i, p in ipairs(points) do
        p = cc.p(p[1] * scale, p[2] * scale)
        points[i] = p
    end

    drawNode = drawNode or cc.DrawNode:create()
    drawNode:clear()
    for i=1, #points-1 do
    	drawNode:drawSegment(points[i], points[i+1], radius, borderColor)
    end

    return drawNode
end