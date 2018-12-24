while true do
	if script.Parent.Parent.Parent.Button.Value.Value == 1 then
		script.Parent.ParticleEmitter.Enabled = true
		script.Parent.Sound:Play()
	else
		script.Parent.ParticleEmitter.Enabled = false
		script.Parent.Sound:Stop()
	end
	wait()
end
