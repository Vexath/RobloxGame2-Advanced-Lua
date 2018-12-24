script.Parent.ClickDetector.MouseClick:connect(function()
	if script.Parent.Parent.Gate.CanCollide == true then
		script.Parent.Parent.Gate.Transparency = 1
		script.Parent.Parent.Gate.CanCollide = false
		wait(3)
		script.Parent.Parent.Gate.Transparency = 0
		script.Parent.Parent.Gate.CanCollide = true
	end
end)