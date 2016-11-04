
myGrayButton=class("myGrayButton", function()
	return display.newNode()
	end)

myGrayButton.NORMAL   = "normal"
myGrayButton.PRESSED  = "pressed"
myGrayButton.DISABLED = "disabled"

function myGrayButton:ctor(images)
	if type(images) ~= "table" then
	 	images = {normal = images}
	end
	self.images_ = images
	print("ccccc")
	print(self.images_[myGrayButton.NORMAL])
	local myButton_ = display.newSprite(self.images_[myGrayButton.NORMAL])
	-- myButton_:setTouchEnabled(true)
 --    myButton_:setTouchSwallowEnabled(true)
 --    myButton_:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
 --    myButton_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
 --        if event.name == "began" then
 --            if self.images[myGrayButton.PRESSED]~=nil then
 --            	myButton_:setTexture(self.images_[myGrayButton.PRESSED])
 --            end
 --        elseif event.name == "moved" then
            
 --        elseif event.name == "ended" then
 --            if self.images[myGrayButton.PRESSED]~=nil then
 --            	myButton_:setTexture(self.images_[myGrayButton.NORMAL])
 --            end
 --        end
 
 --        return true
 --    end)

    return myButton_
end

return myGrayButton