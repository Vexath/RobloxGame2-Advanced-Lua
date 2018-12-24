local isOn = false
function on()
	isOn = true
	script.Parent.Parent.Parent.grill.Flame.Flame.Enabled = false
	script.Parent.Parent.Parent.grill.Flame.Sound:Stop()
	script.Parent.Parent.click1.Transparency = 0
    script.Parent.Parent.click2.Transparency = 1
    script.Parent.Sound:Play()
    wait(0.3)
    script.Parent.Sound:Stop()
end


function off()
	isOn = false
	script.Parent.Parent.Parent.grill.Flame.Flame.Enabled = true
	script.Parent.Parent.Parent.grill.Flame.Sound:Play()
    script.Parent.Parent.click1.Transparency = 1
    script.Parent.Parent.click2.Transparency = 0
    script.Parent.Sound:Play()
    wait(0.3)
    script.Parent.Sound:Stop()
end

function onClicked()
	
	if isOn == true then off() else on() end

end

script.Parent.Parent.click.ClickDetector.MouseClick:connect(onClicked)


on()