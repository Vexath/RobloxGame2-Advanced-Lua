local Home = script.Parent
local Supports = Home:WaitForChild("Supports")
local Swing1 = Home:WaitForChild("Swing1")
local Swing2 = Home:WaitForChild("Swing2")

-- Parts
local Frame = Home:WaitForChild("Frame")

local Hook1 = Swing1:WaitForChild("Hook1")
local Hook2 = Swing1:WaitForChild("Hook2")
local Hook3 = Swing2:WaitForChild("Hook3")
local Hook4 = Swing2:WaitForChild("Hook4")
local SwingSeat1 = Swing1:WaitForChild("SwingSeat1")
local SwingSeat2 = Swing2:WaitForChild("SwingSeat2")
local SwingMesh1 = Swing1:WaitForChild("SwingMesh1")
local SwingMesh2 = Swing2:WaitForChild("SwingMesh2")

local RopeSupport1 = Supports:WaitForChild("RopeSupport1")
local RopeSupport2 = Supports:WaitForChild("RopeSupport2")
local RopeSupport3 = Supports:WaitForChild("RopeSupport3")
local RopeSupport4 = Supports:WaitForChild("RopeSupport4")

-- Other
local CurrentOccupant = nil
local Vector3New,CFrameNew,CFrameAngles,MathRad,MathAbs = Vector3.new,CFrame.new,CFrame.Angles,math.rad,math.abs

-- Settings
local Configuration = Home:WaitForChild("Configuration")
local SwingPower = Configuration:WaitForChild("SwingPower")

local function SetPhysicalProperties(Part,Density)
	if Part then
		Part.CustomPhysicalProperties = PhysicalProperties.new(Density,Part.Friction,Part.Elasticity)
	end
end

GetAllDescendants = function(instance, func)
	func(instance)
	for _, child in next, instance:GetChildren() do
		GetAllDescendants(child, func)
	end
end

local function SetCharacterToWeight(ToDensity,Char)
	GetAllDescendants(Char,function(d)
		if d and d.Parent and d:IsA("BasePart") then
			SetPhysicalProperties(d,ToDensity)
		end
	end)
end

local function OnSeatChange(Seat)
	if Seat.Occupant then
		local CurrentThrottle = Seat.Throttle
		local BodyForce = Seat:WaitForChild("BodyForce")
		
		-- Adjust swing when interacted
		if CurrentThrottle == 1 then
			BodyForce.Force = Seat.CFrame.lookVector * SwingPower.Value * 100
		elseif CurrentThrottle == -1 then
			BodyForce.Force = Seat.CFrame.lookVector * SwingPower.Value * -100
		else
			BodyForce.Force = Vector3New()
		end
		
		delay(0.2,function()
			BodyForce.Force = Vector3New()
		end)
		
		-- Make the character weightless for the swing to behave correctly
		if CurrentOccupant == nil then
			CurrentOccupant = Seat.Occupant
			SetCharacterToWeight(0,CurrentOccupant.Parent)
		end
		
	elseif CurrentOccupant then
		-- Set the character's weight back
		SetCharacterToWeight(0.7,CurrentOccupant.Parent)
		CurrentOccupant = nil
	end
end

SwingSeat1.Changed:connect(function()
	OnSeatChange(SwingSeat1)
end)

SwingSeat2.Changed:connect(function()
	OnSeatChange(SwingSeat2)
end)