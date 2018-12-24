local hinge = script.Parent.Hinge
local pole = script.Parent.Pole
local base = script.Parent.Base

pole.BodyGyro.cframe = pole.CFrame
base.BodyPosition.Position = base.Position

for i, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("BasePart") and v ~= hinge then
		v.Anchored = false
	end
end