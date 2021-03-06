--[[
	// FileName: MasterControl
	// Version 1.0
	// Written by: jeditkacheff
	// Description: All character control scripts go thru this script, this script makes sure all actions are performed
--]]

--[[ Local Variables ]]--
local MasterControl = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

while not Players.LocalPlayer do
	wait()
end
local LocalPlayer = Players.LocalPlayer
local CachedHumanoid = nil
local RenderSteppedCon = nil
local SeatedCn = nil
local moveFunc = LocalPlayer.Move

local isJumping = false
local isSeated = false
local myVehicleSeat = nil
local moveValue = Vector3.new(0,0,0)

--[[ Local Functions ]]--
local function getHumanoid()
	local character = LocalPlayer and LocalPlayer.Character
	if character then
		if CachedHumanoid and CachedHumanoid.Parent == character then
			return CachedHumanoid
		else
			CachedHumanoid = nil
			for _,child in pairs(character:GetChildren()) do
				if child:IsA('Humanoid') then
					CachedHumanoid = child
					return CachedHumanoid
				end
			end
		end
	end
end

--[[ Public API ]]--
function MasterControl:Init()
	
	local renderStepFunc = function()
		if LocalPlayer and LocalPlayer.Character then
			local humanoid = getHumanoid()
			if not humanoid then return end
			
			if humanoid and not humanoid.PlatformStand and isJumping and _G.CanJump then
				humanoid.Jump = isJumping
			end
			
			_G.pMoveValue = moveValue;
			
			moveFunc(LocalPlayer, moveValue, true)	
		end
	end
	
	local success = pcall(function() RunService:BindToRenderStep("MasterControlStep", Enum.RenderPriority.Input.Value, renderStepFunc) end)
	
	if not success then
		if RenderSteppedCon then return end
		RenderSteppedCon = RunService.RenderStepped:connect(renderStepFunc)
	end
end

function MasterControl:Disable()
	local success = pcall(function() RunService:UnbindFromRenderStep("MasterControlStep") end)
	if not success then
		if RenderSteppedCon then
			RenderSteppedCon:disconnect()
			RenderSteppedCon = nil
		end
	end
	
	moveValue = Vector3.new(0,0,0)
	isJumping = false
end

function MasterControl:AddToPlayerMovement(playerMoveVector)
	moveValue = Vector3.new(moveValue.X + playerMoveVector.X, moveValue.Y + playerMoveVector.Y, moveValue.Z + playerMoveVector.Z)
end

function MasterControl:GetMoveVector()
	return moveValue
end

function MasterControl:SetIsJumping(jumping)
	isJumping = jumping
end

function MasterControl:DoJump()
	local humanoid = getHumanoid()
	if humanoid and _G.CanJump then
		print(_G.CanJump);
		humanoid.Jump = true
	end
end

return MasterControl
