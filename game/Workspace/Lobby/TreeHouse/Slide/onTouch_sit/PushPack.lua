door = script.Parent

function onTouch(hit)
	if hit.Parent == nil then return end
	local h = hit.Parent:FindFirstChild("Humanoid")
	if h ~= nil then 
                hit.Parent.Humanoid.Sit = true
		hit.Parent.Torso.Velocity=door.CFrame.lookVector * 20
	end
end
door.Touched:connect(onTouch)