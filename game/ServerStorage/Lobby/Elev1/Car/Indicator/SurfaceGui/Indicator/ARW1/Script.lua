SP = script.Parent
LEDOn = script.Parent.Parent.Parent.Parent.LEDOn.Value
LEDOff = script.Parent.Parent.Parent.Parent.LEDOff.Value

function SetDigit(Value)
	if Value == "2" then
	script.Parent.U.Disabled = true
	script.Parent.D.Disabled = true
    script.Parent.Row1["1"].BackgroundTransparency = LEDOff
    script.Parent.Row1["2"].BackgroundTransparency = LEDOff
    script.Parent.Row1["3"].BackgroundTransparency = LEDOn
    script.Parent.Row1["4"].BackgroundTransparency = LEDOff
    script.Parent.Row1["5"].BackgroundTransparency = LEDOff
    script.Parent.Row2["1"].BackgroundTransparency = LEDOff
    script.Parent.Row2["2"].BackgroundTransparency = LEDOn
    script.Parent.Row2["3"].BackgroundTransparency = LEDOn
    script.Parent.Row2["4"].BackgroundTransparency = LEDOn
    script.Parent.Row2["5"].BackgroundTransparency = LEDOff
    script.Parent.Row3["1"].BackgroundTransparency = LEDOn
    script.Parent.Row3["2"].BackgroundTransparency = LEDOff
    script.Parent.Row3["3"].BackgroundTransparency = LEDOn
    script.Parent.Row3["4"].BackgroundTransparency = LEDOff
    script.Parent.Row3["5"].BackgroundTransparency = LEDOn
    script.Parent.Row4["1"].BackgroundTransparency = LEDOff
    script.Parent.Row4["2"].BackgroundTransparency = LEDOff
    script.Parent.Row4["3"].BackgroundTransparency = LEDOn
    script.Parent.Row4["4"].BackgroundTransparency = LEDOff
    script.Parent.Row4["5"].BackgroundTransparency = LEDOff
    script.Parent.Row5["1"].BackgroundTransparency = LEDOff
    script.Parent.Row5["2"].BackgroundTransparency = LEDOff
    script.Parent.Row5["3"].BackgroundTransparency = LEDOn
    script.Parent.Row5["4"].BackgroundTransparency = LEDOff
    script.Parent.Row5["5"].BackgroundTransparency = LEDOff
    script.Parent.Row6["1"].BackgroundTransparency = LEDOff
    script.Parent.Row6["2"].BackgroundTransparency = LEDOff
    script.Parent.Row6["3"].BackgroundTransparency = LEDOn
    script.Parent.Row6["4"].BackgroundTransparency = LEDOff
    script.Parent.Row6["5"].BackgroundTransparency = LEDOff
    script.Parent.Row7["1"].BackgroundTransparency = LEDOff
    script.Parent.Row7["2"].BackgroundTransparency = LEDOff
    script.Parent.Row7["3"].BackgroundTransparency = LEDOn
    script.Parent.Row7["4"].BackgroundTransparency = LEDOff
    script.Parent.Row7["5"].BackgroundTransparency = LEDOff
		return
	end	
	if Value == "1" then
		script.Parent.U.Disabled = false
		script.Parent.D.Disabled = true
		return
	end	
	if Value == "0" then
	script.Parent.U.Disabled = true
	script.Parent.D.Disabled = true
    script.Parent.Row1["1"].BackgroundTransparency = LEDOff
    script.Parent.Row1["2"].BackgroundTransparency = LEDOff
    script.Parent.Row1["3"].BackgroundTransparency = LEDOff
    script.Parent.Row1["4"].BackgroundTransparency = LEDOff
    script.Parent.Row1["5"].BackgroundTransparency = LEDOff
    script.Parent.Row2["1"].BackgroundTransparency = LEDOff
    script.Parent.Row2["2"].BackgroundTransparency = LEDOff
    script.Parent.Row2["3"].BackgroundTransparency = LEDOff
    script.Parent.Row2["4"].BackgroundTransparency = LEDOff
    script.Parent.Row2["5"].BackgroundTransparency = LEDOff
    script.Parent.Row3["1"].BackgroundTransparency = LEDOff
    script.Parent.Row3["2"].BackgroundTransparency = LEDOff
    script.Parent.Row3["3"].BackgroundTransparency = LEDOff
    script.Parent.Row3["4"].BackgroundTransparency = LEDOff
    script.Parent.Row3["5"].BackgroundTransparency = LEDOff
    script.Parent.Row4["1"].BackgroundTransparency = LEDOff
    script.Parent.Row4["2"].BackgroundTransparency = LEDOff
    script.Parent.Row4["3"].BackgroundTransparency = LEDOff
    script.Parent.Row4["4"].BackgroundTransparency = LEDOff
    script.Parent.Row4["5"].BackgroundTransparency = LEDOff
    script.Parent.Row5["1"].BackgroundTransparency = LEDOff
    script.Parent.Row5["2"].BackgroundTransparency = LEDOff
    script.Parent.Row5["3"].BackgroundTransparency = LEDOff
    script.Parent.Row5["4"].BackgroundTransparency = LEDOff
    script.Parent.Row5["5"].BackgroundTransparency = LEDOff
    script.Parent.Row6["1"].BackgroundTransparency = LEDOff
    script.Parent.Row6["2"].BackgroundTransparency = LEDOff
    script.Parent.Row6["3"].BackgroundTransparency = LEDOff
    script.Parent.Row6["4"].BackgroundTransparency = LEDOff
    script.Parent.Row6["5"].BackgroundTransparency = LEDOff
    script.Parent.Row7["1"].BackgroundTransparency = LEDOff
    script.Parent.Row7["2"].BackgroundTransparency = LEDOff
    script.Parent.Row7["3"].BackgroundTransparency = LEDOff
    script.Parent.Row7["4"].BackgroundTransparency = LEDOff
    script.Parent.Row7["5"].BackgroundTransparency = LEDOff
		return
	end	
	if Value == "-1" then
		script.Parent.U.Disabled = true
		script.Parent.D.Disabled = false
		return
	end	
	if Value == "-2" then
	script.Parent.U.Disabled = true
	script.Parent.D.Disabled = true
    script.Parent.Row1["1"].BackgroundTransparency = LEDOff
    script.Parent.Row1["2"].BackgroundTransparency = LEDOff
    script.Parent.Row1["3"].BackgroundTransparency = LEDOn
    script.Parent.Row1["4"].BackgroundTransparency = LEDOff
    script.Parent.Row1["5"].BackgroundTransparency = LEDOff
    script.Parent.Row2["1"].BackgroundTransparency = LEDOff
    script.Parent.Row2["2"].BackgroundTransparency = LEDOff
    script.Parent.Row2["3"].BackgroundTransparency = LEDOn
    script.Parent.Row2["4"].BackgroundTransparency = LEDOff
    script.Parent.Row2["5"].BackgroundTransparency = LEDOff
    script.Parent.Row3["1"].BackgroundTransparency = LEDOff
    script.Parent.Row3["2"].BackgroundTransparency = LEDOff
    script.Parent.Row3["3"].BackgroundTransparency = LEDOn
    script.Parent.Row3["4"].BackgroundTransparency = LEDOff
    script.Parent.Row3["5"].BackgroundTransparency = LEDOff
    script.Parent.Row4["1"].BackgroundTransparency = LEDOff
    script.Parent.Row4["2"].BackgroundTransparency = LEDOff
    script.Parent.Row4["3"].BackgroundTransparency = LEDOn
    script.Parent.Row4["4"].BackgroundTransparency = LEDOff
    script.Parent.Row4["5"].BackgroundTransparency = LEDOff
    script.Parent.Row5["1"].BackgroundTransparency = LEDOn
    script.Parent.Row5["2"].BackgroundTransparency = LEDOff
    script.Parent.Row5["3"].BackgroundTransparency = LEDOn
    script.Parent.Row5["4"].BackgroundTransparency = LEDOff
    script.Parent.Row5["5"].BackgroundTransparency = LEDOn
    script.Parent.Row6["1"].BackgroundTransparency = LEDOff
    script.Parent.Row6["2"].BackgroundTransparency = LEDOn
    script.Parent.Row6["3"].BackgroundTransparency = LEDOn
    script.Parent.Row6["4"].BackgroundTransparency = LEDOn
    script.Parent.Row6["5"].BackgroundTransparency = LEDOff
    script.Parent.Row7["1"].BackgroundTransparency = LEDOff
    script.Parent.Row7["2"].BackgroundTransparency = LEDOff
    script.Parent.Row7["3"].BackgroundTransparency = LEDOn
    script.Parent.Row7["4"].BackgroundTransparency = LEDOff
    script.Parent.Row7["5"].BackgroundTransparency = LEDOff
		return
	end	
end




SP.Value.Changed:connect(function() SetDigit(SP.Value.Value) end)