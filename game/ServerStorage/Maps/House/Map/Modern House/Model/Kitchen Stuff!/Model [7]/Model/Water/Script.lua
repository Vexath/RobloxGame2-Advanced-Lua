while true do
	if script.Parent.Parent.Parent.Button.Value.Value == 1 then
		script.Parent.ParticleEmitter.Enabled = true
	else
		script.Parent.ParticleEmitter.Enabled = false
	end
	wait()
end
