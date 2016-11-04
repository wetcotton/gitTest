-- 展示模型(英雄、战车)
-- Author: Jun Jiang
-- Date: 2015-02-10 15:51:07
--
--单次动画
local OnceMoveMent = {
	"Attack", 		--普通攻击
	"Skill1", 		--技能攻击
}

local OnceMoveMent_Tank =
{
	"Attack", 		--普通攻击
	"Attack2", 		--技能攻击
	"Skill1",	--SE攻击
}

local manager = ccs.ArmatureDataManager:getInstance()

ShowModel = class("ShowModel", function(params)
	local model =  GlobalCreateModel(params.modelType, params.templateID)
	model.params = params
	return model
end)

--动作回调
local function AnimationEvent(armatureBack,movementType,movementID)
	if movementType == ccs.MovementEventType.complete then
		local animation = armatureBack:getAnimation()
        animation:play("Standby", -1, -1)
        animation:gotoAndPlay(0)
    end
end

function ShowModel:SpineAnimationEvent(event)
	if event.type=="complete" then
		self:setAnimation(0,"Standby",true)
	end
end

--展示模型构造
function ShowModel:ctor(params)
	self.nOnceIndex = params.nOnceIndex or 0 	--单次动作索引
	if params.modelType==ModelType.Tank then
		self.OnceMoveMent = OnceMoveMent_Tank
	else
		self.OnceMoveMent = OnceMoveMent
	end
	if self.makeType==ModelMakeType.kMake_Coco then
		local animation = self:getAnimation()
		animation:setMovementEventCallFunc(AnimationEvent)
		animation:play("Standby", -1, -1)
		animation:gotoAndPlay(0)
	else
		self:setAnimation(0, "Standby", true)
		self:registerSpineEventHandler(handler(self,self.SpineAnimationEvent),2)
	end
end

--展示单次播放动作
function ShowModel:ShowOnceMoveMent()
	-- print("\n\n\n\n\n\n\n单次动作")
	self.nOnceIndex = self.nOnceIndex+1
	if self.nOnceIndex>#self.OnceMoveMent then
		self.nOnceIndex = 1
	end
	local _animation = self.OnceMoveMent[self.nOnceIndex]
	print("_animation:",_animation)
	if self.makeType==ModelMakeType.kMake_Coco then
		local animation = self:getAnimation()
		animation:play(_animation, -1, 0)
		animation:gotoAndPlay(0)
	else
		print("spine动作")
		self:resume()
        self:setToSetupPose()
        self:setAnimation(0, _animation, false)
	end
end

function copySpineModel(_model)
	local params = _model.params
	local pos = cc.p(_model:getPositionX(),_model:getPositionY())
	local parent = _model:getParent()
	local zOrder = _model:getLocalZOrder()
	local tag = _model:getTag()
	params.nOnceIndex = _model.nOnceIndex
	local _scaleX = _model:getScaleX()
	local _scaleY = _model:getScaleY()

	local newModel = ShowModel.new(params)
			:pos(pos.x,pos.y)
	newModel:setScaleX(_scaleX)
	newModel:setScaleY(_scaleY)
	return newModel
end