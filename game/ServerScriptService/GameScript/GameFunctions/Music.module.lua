local Module = {}

local CurrentSong = game.ReplicatedStorage.Music.Lobby.lobbyM;

Module.Lobby = function()
	local Song = game.ReplicatedStorage.Music.Lobby.lobbyM
	CurrentSong = Song;
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.Classic = function()
	local Song = game.ReplicatedStorage.Music.Classic.classicM
	CurrentSong = Song;
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.CTF = function()
	local Song = game.ReplicatedStorage.Music.CTF.ctfM
	CurrentSong = Song;
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.RUN = function()
	local Song = game.ReplicatedStorage.Music.Run.runM
	CurrentSong = Song;
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.FreezeTag = function()
	local Song = game.ReplicatedStorage.Music.FreezeTag.freezetagM
	CurrentSong = Song;
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.RoundEnd = function()
	local Music = game.ReplicatedStorage.Music.RoundEnding.SAW	
	local Song = Music
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.Victory = function()
	local Music = game.ReplicatedStorage.Music.RoundEnd.victoryM	
	local Song = Music
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.Loser = function()
	local Music = game.ReplicatedStorage.Music.RoundEnd.loserM	
	local Song = Music
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.RoundEnd = function()
	local Music = game.ReplicatedStorage.Music.RoundEnding.SAW	
	local Song = Music
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.Innocents = function()
	local Music = game.ReplicatedStorage.Music.Innocent:GetChildren();
	local Song = Music[math.random(1,#Music)];
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

Module.Knifer = function()
	local Music = game.ReplicatedStorage.Music.Knifer:GetChildren();
	local Song = Music[math.random(1,#Music)];
	game.ReplicatedStorage.PlayMusic:FireAllClients(Song);
end

return Module;
