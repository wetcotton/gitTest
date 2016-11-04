--
-- Author: xiaopao
-- Date: 2014-09-29 11:10:54
--

local HttpNet={}

--XXTEA密码
local MessageKey = "szn100szn"

function HttpNet.connectHTTPServer(callback, requetTypeStr, sendDataStr)
    local rUrl = ""
    if sendDataStr then
        --加密
        -- sendDataStr = crypto.encryptXXTEA(sendDataStr, MessageKey)
        -- sendDataStr = encodeURL(sendDataStr)
        rUrl = DIR_SERVER_URL..requetTypeStr..sendDataStr
    else
    	rUrl = DIR_SERVER_URL..requetTypeStr
    end
    printf("http request url=%s", rUrl)
    local request = network.createHTTPRequest(function(event)
        callback(event)
    end, rUrl, "GET")
    
    printf("REQUEST START")
    request:start()
end

--解密
function HttpNet.getUnTeaResponseString(_teaRequest)
 --    local deStr = crypto.decryptXXTEA(_teaRequest:getResponseString(), MessageKey)
 --    print("-------------------")
 --    print("Before:".._teaRequest:getResponseString())
 --    print("After:"..deStr)
 --    print("-------------------")
	-- return deStr
    return _teaRequest:getResponseString()
end

function decodeURL(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+") 
end

return HttpNet