------------------------------------------------------------------------------------
local WaitTime = 15	-- Change this to the amount of time it takes for the button to re-enable.
local modelname = "Floaty Ring"	-- If your model is not named this, then make the purple words the same name as the model!
------------------------------------------------------------------------------------

-- To make this work, simply group it with the model you want!


local modelbackup = script.Parent.Parent:FindFirstChild(modelname):clone()
local trigger = script.Parent

enabled = true

function onClick()

	if enabled == true then

		enabled = false
		trigger.BrickColor = BrickColor.new("Really black")

	if script.Parent.Parent:FindFirstChild(modelname) ~= nil then

		script.Parent.Parent:FindFirstChild(modelname):Destroy()

	end

		local modelclone = modelbackup:clone()
		modelclone.Parent = script.Parent.Parent
		modelclone:MakeJoints()



		wait(WaitTime)
		
		enabled = true
		trigger.BrickColor = BrickColor.new("Bright violet")

	end

end

script.Parent.ClickDetector.MouseClick:connect(onClick)

