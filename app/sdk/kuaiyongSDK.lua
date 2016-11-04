-- @Author: anchen
-- @Date:   2016-04-05 11:12:47
-- @Last Modified by:   anchen
-- @Last Modified time: 2016-04-05 12:09:03
kuaiyongSDK = {}

local iskuaiyongValid = device.platform == "ios" and gType_SDK == AllSdkType.Sdk_KUAIYONG

function kuaiyongSDK:initAndLogin()
    if  not iskuaiyongValid then
        return
    end
    local ok, ret = luaoc.callStaticMethod("RootViewController", "XSDKInit")
end
