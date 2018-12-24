while true do
	if script.Parent.Parent.Parent.Button.Value.Value == 1 then
		script.Parent.Sound:Play()
	else
		script.Parent.Sound:Stop()
	end
	wait()
end
