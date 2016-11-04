require "socket"

local asyncLoadUtils = class("asyncLoadUtils")

local texetureRes = class("texetureRes")
function texetureRes:ctor(resPath,weight,_func)
	self.resPath = resPath
	self.weight = weight or 1
	self.loadCompeleteCallback = _func
end

function texetureRes:loadCallback(_texetuer2d)
	-- local width = _texetuer2d:getPixelsWide()
	-- local height = _texetuer2d:getPixelsHigh()
	self.loadCompeleteCallback(self)
end

function texetureRes:load()
	if not cc.FileUtils:getInstance():isFileExist(self.resPath) then
	    print("file error , "..self.resPath.." is not exist! ,,hyz")
	    self:loadCallback(nil)
	else
		cc.Director:getInstance():getTextureCache():addImageAsync(self.resPath, handler(self,self.loadCallback)) 
	end
end

local plistRes = class("plistRes")
function plistRes:ctor(resPath,weight,_func)
	self.resPngPath = resPath..".png"
	self.resPlistPath = resPath..".plist"
	self.weight = weight or 1
	self.loadCompeleteCallback = _func
end

function plistRes:loadCallback(_texetuer2d)
	if _texetuer2d~=nil then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(self.resPlistPath, _texetuer2d) 
	end
	self.loadCompeleteCallback(self)
end

function plistRes:load()
	if not cc.FileUtils:getInstance():isFileExist(self.resPngPath) then
	    print("file error , "..self.resPngPath.." is not exist! ,,hyz")
	    self:loadCallback(nil)
	else
		cc.Director:getInstance():getTextureCache():addImageAsync(self.resPngPath, handler(self,self.loadCallback)) 
	end
end

local oldTime = 0

function asyncLoadUtils:ctor()
	self:resetLoadUtils()
end

function asyncLoadUtils:resetLoadUtils()
	self.resType = {
		textureType = 1,
		plistType = 2,
	}
	self.allResArray = {}   --需要加载的所有资源
	self.hasLoadResArray = {}   --已经加载的资源
	self.mFrameCheckObj = nil
	self.allWeight = 0
	self.curWeight = 0
	self.timeHandle = nil
	self.mFrameCheckObj = display.newNode()  -- 用于标记是否已经经过了一帧
							:addTo(display.getRunningScene(),0,0)
end

function asyncLoadUtils:addRes(resType,resPath,weight)
	if resType==self.resType.textureType then
		local texetureRes = texetureRes.new(resPath,weight,handler(self,self.oneLoadCompleted))
		self.allResArray[#self.allResArray+1] = texetureRes
	elseif resType==self.resType.plistType then
		local plistRes = plistRes.new(resPath,weight,handler(self,self.oneLoadCompleted))
		self.allResArray[#self.allResArray+1] = plistRes
	end
end

function asyncLoadUtils:startLoad()
	for i=1,#self.allResArray do
		self.allWeight = self.allWeight+self.allResArray[i].weight
	end
	self.mFrameCheckObj:removeFromParent()                  
	self.mFrameCheckObj = display.newNode()  -- 用于标记是否已经经过了一帧
							:addTo(display.getRunningScene(),0,0)
	display.getRunningScene():performWithDelay(function ()
		self:checkUpdate()
	end,0)
end

function asyncLoadUtils:checkUpdate(dt)
	if self.mFrameCheckObj:getReferenceCount()==1 then  --保证已经过完了一帧
		local index = #self.hasLoadResArray+1
		-- print("index:"..index)
		-- print(#self.allResArray)
		self.allResArray[index]:load()
	else
	end
end

function asyncLoadUtils:oneLoadCompleted(res)
	local curTime = socket.gettime()
	-- print("shi jian jian ge : "..curTime-oldTime)
	oldTime = curTime

	self.mFrameCheckObj:removeFromParent()                  
	self.mFrameCheckObj = display.newNode()  -- 用于标记是否已经经过了一帧
							:addTo(display.getRunningScene(),0,0)
	self:loadProgressNotify(res)
	
	if #self.hasLoadResArray==#self.allResArray then   --已经加载完了
		print("加载完了")
	else
		display.getRunningScene():performWithDelay(function ()
			self:checkUpdate()
		end,0)
		
	end
end

function asyncLoadUtils:loadProgressNotify(res)
	self.hasLoadResArray[#self.hasLoadResArray+1] = res
	--print("已经加载了第 "..#self.hasLoadResArray.." 帧： "..(res.resPath or res.resPlistPath))
	
	self.curWeight = self.curWeight + res.weight
	local progress = 100*self.curWeight/self.allWeight
	--print("进度："..progress.."%")
	return progress
end

return asyncLoadUtils