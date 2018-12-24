script.Parent.Touched:connect(function(obj)
	if obj.Parent:FindFirstChild("Humanoid") then
		obj.Parent.Humanoid.Sit = true
	end
end)