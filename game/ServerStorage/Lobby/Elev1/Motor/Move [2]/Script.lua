local uni = script.Parent
local Motor = script.Parent.Parent.Parent.Data.Motor

local Running = false
Motor.Changed:connect(function()
	if not Running then
		Running = true
		if Motor.Value ~= 0 then
			repeat
			uni.CFrame = uni.CFrame * CFrame.Angles(0,Motor.Value,0)
			wait()
			until Motor.Value == 0
		end
		Running = false
	end
end)