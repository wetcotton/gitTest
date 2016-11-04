
IsDataEyeEnabled = false
if device.platform == "android" or device.platform == "ios" then
	IsDataEyeEnabled = true
end


require("app.sdk.DCAccount")
require("app.sdk.DCAgent")
require("app.sdk.DCCardsGame")
require("app.sdk.DCCoin")
require("app.sdk.DCConfigParams")
require("app.sdk.DCEvent")
require("app.sdk.DCItem")
require("app.sdk.DCLevels")
require("app.sdk.DCTask")
require("app.sdk.DCVirtualCurrency")
