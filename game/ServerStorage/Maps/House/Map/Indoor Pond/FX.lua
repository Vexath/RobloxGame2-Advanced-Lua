local Configuration = script.Parent:WaitForChild("Configuration")

-- Water fall variables
local FountainModel = script.Parent:WaitForChild("Fountain")
local Water = FountainModel:WaitForChild("Falls")
local Speed = Configuration:WaitForChild("FadeSpeed")
local Thres = Configuration:WaitForChild("TransparencyThreshold")

-- Sound variables
local sound = Water:WaitForChild("WaterFX")
local soundpitch = Configuration:WaitForChild("SoundPitch")
local soundvolume = Configuration:WaitForChild("SoundVolume")

-- Particle variables
local IsParticlesEnabled = Configuration:WaitForChild("IsParticlesEnabled")
local Emitter = script.Parent:WaitForChild("Emitter")
local Particle1 = Emitter:WaitForChild("Main1")
local Particle2 = Emitter:WaitForChild("Main2")

-- Other
sound:Play()
local n=0

while wait() and Water do
	n=n+Speed.Value
	local NewTransparency = math.cos(n)/Thres.Value
	
	-- If it's negative, we'll change it to positive
	if NewTransparency < 0 then
		NewTransparency = NewTransparency + -NewTransparency*2
	end
	
	-- Change water transparency
	Water.Transparency = NewTransparency
	
	-- Change sound based on settings folder
	sound.Pitch = soundpitch.Value
	sound.Volume = soundvolume.Value
	
	-- Enable particles based on settings folder
	Particle1.Enabled = IsParticlesEnabled.Value
	Particle2.Enabled = IsParticlesEnabled.Value
end