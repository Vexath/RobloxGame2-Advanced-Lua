Motor = script.Parent.Parent.Data.Motor

local Running = false
Motor.Changed:connect(function()
	if not Running then
		Running = true
		if Motor.Value ~= 0 then
			repeat
				for i,l in pairs(script.Parent.Weight:GetChildren()) do
				l.CFrame = l.CFrame + Vector3.new(0, -Motor.Value, 0)
				end
			wait()
			until Motor.Value == 0
		end
		Running = false
	end
end)