require("launcher.config")
require("framework.init")
scheduler = require("framework.scheduler")

LocalGameData = require("app/data/LocalGameData")

reloadLuaFile("app.utils.Constants")
reloadLuaFile("app.utils.GlobalFunc")
reloadLuaFile("framework.display")



display.DEFAULT_TTF_FONT        = "fonts/blackfont.TTF"
display.DEFAULT_TTF_FONT_SIZE   = 24


m_addSearchPath()

local MyApp = class("MyApp", cc.mvc.AppBase)

local energyNode = display.newNode()
energyNode:retain()

function MyApp:ctor()
    if Launcher.needUpdate and Launcher.fileServer~="" then
        Launcher.fileServer = ""
        restartTheApp()
    end
    
    MyApp.super.ctor(self)

    reloadLuaFile("app.utils.Constants")
    reloadLuaFile("app.utils.GlobalFunc")
    reloadLuaFile("app.net.parseGameData")
    reloadLuaFile("framework.display")
    reloadLuaFile("app.scenes.block.teamUpgrade")

    
    
    
    --LocalGameData:getInstance():encryptAllJson();
    --local areaData = LocalGameData:getInstance():getLocalData(LocalDataType.kDataArea)
    --print(areaData["10001"]["name"])
    --local Zlib = require("zlib")
    -- local deflated, eof,  bytes_in, bytes_out = Zlib.deflate()("hahahahasssss","finish")
    -- print(deflated)
    -- print(eof)
    -- print(bytes_in)
    -- print(bytes_out)
    -- local inflate, eof2,  bytes_in2, bytes_out2 = Zlib.inflate()(cc.FileUtils:getInstance():getStringFromFile("1.txt.gz"))
    -- print(inflate)
    -- print(eof2)
    -- print(bytes_in2)
    -- print(bytes_out2)
end

function MyApp:run()
    reloadLuaFile("launcher.init")
    LocalGameData:getInstance():loadLocalData();
    self:enterScene("LoginScene")
end

function MyApp:enterScene(sceneName, ...)
    MyApp.super.enterScene(self,sceneName, ...)
end

function getLocalGameDataBykey(key,defaultRet)
    local chaId = srv_userInfo["characterId"]..""
    if GameData[chaId]==nil then
        GameData[chaId] = {}
    end

    return GameData[chaId][key] or defaultRet
end
function saveLocalGameDataBykey(key,data)
    if srv_userInfo["characterId"] == nil then
       return
    end
    local chaId = srv_userInfo["characterId"]..""
    if GameData[chaId]==nil then
        GameData[chaId] = {}
    end

    GameData[chaId][key] = data
    GameState.save(GameData)
    -- printTable(GameData)
end

function MyApp:onEnterBackground()
    MyApp.super.onEnterBackground(self)
    if nil~=SchedulerMgr then
        SchedulerMgr:unscheduleGlobal("energy")
    end
end

function MyApp:onEnterForeground()
    MyApp.super.onEnterForeground(self)
    energyNode:performWithDelay(ReqLatestEnergy, 0.2)
    -- ReqLatestEnergy()
end


return MyApp
