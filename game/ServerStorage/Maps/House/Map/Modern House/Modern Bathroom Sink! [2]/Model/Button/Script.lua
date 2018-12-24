local isOn = false
function on()
	isOn = true
	script.Parent.Value.Value = 0 
	
    
   
end


function off()
	isOn = false
	script.Parent.Value.Value = 1
end

function onClicked()
	
	if isOn == true then off() else on() end

end

script.Parent.ClickDetector.MouseClick:connect(onClicked)


on()