local MainGUI = script.Parent.Game;
local MuteButton = MainGUI.Mute
local MuteLabel = "rbxassetid://172649152"
local UnMuteLabel = "rbxassetid://166376559"
local MuteMusic = false
local Song



game.ReplicatedStorage.PlayMusic.OnClientEvent:connect(function(Song)
	if MuteMusic == true then return; end;
	
	for i = 1,10 do
		for i,S in pairs(game.SoundService:GetChildren()) do
			S.Volume = S.Volume - 0.1;
		end
		wait(0.1);
	end;
	for i,S in pairs(game.SoundService:GetChildren()) do
		S:Stop();
		S:Destroy();
	end
	local Song = Song:Clone();
	Song.Parent = game.SoundService;
	Song:Play();
	for i = 1,Song.Volume*10 do
		Song.Volume = Song.Volume + 0.1;
		wait(0.1);
	end
end)

MuteButton.MouseButton1Down:connect(function()
	if MuteMusic == true then 
		MuteButton.Image = UnMuteLabel
		MuteMusic = false
	elseif MuteMusic == false then
		for i,S in pairs(game.SoundService:GetChildren()) do
			S:Stop();
			S:Destroy();
		end
		MuteMusic = true
		MuteButton.Image = MuteLabel
	end
end)