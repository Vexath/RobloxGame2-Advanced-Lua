Control = script.Parent.Parent.Parent.Data
Floor = Control.Floor
UD = Control.UD
Indicator = script.Parent.SurfaceGui.Indicator
DigA = Indicator.ARW1
Dig1 = Indicator.DIG1
Dig2 = Indicator.DIG2
CustomLabels = {
	
	--[Floor Number]= "Floor Name",
	
	}

function FloorControl()
	if string.len(Floor.Value) == 1 then
		if CustomLabels[Floor.Value] ~= nil then
			if string.len(CustomLabels[Floor.Value]) == 1 then
				Dig1.Value.Value = ""
				Dig2.Value.Value = CustomLabels[Floor.Value]:sub(1,1)
				return
			end
			if string.len(CustomLabels[Floor.Value]) == 2 then
				Dig1.Value.Value = CustomLabels[Floor.Value]:sub(1,1)	
				Dig2.Value.Value = CustomLabels[Floor.Value]:sub(2,2)	
				return
			end
			return -- Just to be sure :P
		end
			Dig1.Value.Value = ""
			Dig2.Value.Value = Floor.Value
		return
	end 
	if string.len(Floor.Value) == 2 then
			Dig1.Value.Value = tostring(Floor.Value):sub(1,1)
			Dig2.Value.Value = tostring(Floor.Value):sub(2,2)	
		return
	end 
end

UD.Changed:connect(function()
	if UD.Value == "US" then DigA.Value.Value = "2" return end
	if UD.Value == "U" then DigA.Value.Value = "1" return end
	if UD.Value == "N" then DigA.Value.Value = "0" return end
	if UD.Value == "D" then DigA.Value.Value = "-1" return end
	if UD.Value == "DS" then DigA.Value.Value = "-2" return end
end)

Floor.Changed:connect(FloorControl)
FloorControl()