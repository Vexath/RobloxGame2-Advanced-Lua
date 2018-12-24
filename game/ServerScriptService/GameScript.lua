game.Players.CharacterAutoLoads = false;
local ServerVersion = 11;
game.Workspace.Status.Message.Version.Text = "v"..ServerVersion;
local PlayerData = {};
local Map;
local KnifeScripts = game.ServerStorage.KnifeScripts:GetChildren();
local CoinObject;
local Data;

local PlaySong = game.ReplicatedStorage.PlayMusic
local Song;

local SongList = {
	["Lobby"] = game.ReplicatedStorage.Music.Lobby.lobbyM;
	["CTF"] = game.ReplicatedStorage.Music.CTF.ctfM;
	["Classic"] = game.ReplicatedStorage.Music.Classic.classicM;
	["FreezeTag"] = game.ReplicatedStorage.Music.FreezeTag.freezetagM;
	["RUN"] = game.ReplicatedStorage.Music.Run.runM;
}


	--force mode--
----------------------
--local GameType = "RUN"--
----------------------

--[[

local GameType

local GameList = { 
	[1] = "Classic";
	[2] = "RUN";
	[3] = "CTF";
	[4] = "FreezeTag";
};

--]]

_G.GameModeProducts = {
--[[["Infection"] = 31746325;
	["Dodgeball"] = 31746325;
	["Massacre"] = 31746325; --]]
};




math.randomseed(os.time());
--
local Data = require(script.DataModule);

local GameFunctions = {};
local GameConstants = {};

for _,Module in pairs(script.GameFunctions:GetChildren()) do
	GameFunctions[Module.Name] = require(Module);
end

for _,Module in pairs(script.GameConstants:GetChildren()) do
	GameConstants[Module.Name] = require(Module);
end


local Chance = GameFunctions["Chance"];
local ResetChance = Chance.Reset;
local GetChance = Chance.Get;
local CreateChanceTable = Chance.CreateChanceTable;
local IncreaseChance = Chance.Increase;

local GiveWeapon =  GameFunctions["GiveWeapon"];
local GiveKnife = GiveWeapon.Knife;
local GiveGun = GiveWeapon.Gun

local StandardFunctions = GameFunctions["StandardFunctions"];
local CheckForInnocents = StandardFunctions.CheckForInnocents;

local GunDrop = GameFunctions["GunDrop"];

local GameModes = script.GameModes;


local Sync;

local BannedOld = {
	[12471435] = true;
	[137845841] = true;
	[131866510] = true;
	[143890073] = true;
	[158365560] = true;
	[106801613] = true;
	[138374915] = true;
	[124636385] = true;
	[88064189] 	= true;
	[138545019] = true;
	[123027618] = true;
	[144222383] = true;
	[124843470] = true;
	[144556748] = true;
};


local PlayerSessions = {};

game.Players.PlayerAdded:connect(function(Player)
	repeat wait(); until Player.Parent == game.Players and Sync;
	
	local BanList = game.ReplicatedStorage.GetSyncDataServer:Invoke("Banned");
	local PlayerID = tostring(Player.userId);
	if BanList[PlayerID] then
		local KickText = "You have been banned from Slumber Party."
		if BanList[PlayerID] ~= true then
			KickText = KickText .. " Reason: " .. BanList[PlayerID];
		end
		Player:Kick(KickText);
		print(Player.Name .. " kicked.");
		return;
	end;
	print("test")
	
	
	local PlayerColor = BrickColor.new("Medium stone grey");
	for _,Module in pairs(GameFunctions) do
		if type(Module) ~= "function" then
			if Module["PlayerAdded"] ~= nil then
				Module.PlayerAdded(Player);
			end
		end;
	end
	Player.HealthDisplayDistance = 20;
	Player.NameDisplayDistance = 100;
	Player.CharacterAdded:connect(function(Character)
		GameFunctions["CharacterAdded"](Player,Character);
	end)
	Player.Chatted:connect(function(Message)
		GameFunctions["Chat"].Chatted(Player,Message);
	end)
	--repeat wait(); until Data.Ready == true;
	--repeat wait(); until Player.Name ~= nil;
	wait();
	Data.SetData(Player);	
end);

print("Loading Sync...");
Sync = require(script.Sync);

local GameVariables = {
	["GameFunctions"] = GameFunctions;
	["GameConstants"] = GameConstants;
	["Map"] = nil;
	["Sync"] = Sync;
	["PlayerData"] = {};
	["GameTimer"] = 0;
};
GameFunctions["GameConnections"](Sync,ServerVersion,Data,GameFunctions,GameConstants);

for _,BindableFunction in pairs(script.Get:GetChildren()) do
	BindableFunction.OnInvoke = function()
		return GameVariables[BindableFunction.Name];
	end
end


game.Players.PlayerRemoving:connect(function(Player)
	for _,Module in pairs(GameFunctions) do
		if type(Module) ~= "function" then
			if Module["PlayerRemoving"] ~= nil then
				Module.PlayerRemoving(Player);
			end
		end;
	end;
	game.ReplicatedStorage.UpdateLeaderboard:FireAllClients();

end)

script.Set.PlayerData.Event:connect(function(SetWho,SetWhat,SetToWhat)
	pcall(function()
		GameVariables["PlayerData"][SetWho][SetWhat] = SetToWhat;
	end);
end);
	
game.ReplicatedStorage.Remotes.Gameplay.KnifeKill.Event:connect(function(Killer,Victim,VictimHumanoid,Type)
	if GameVariables["GameMode"] ~= nil then
		GameVariables["GameMode"].KnifeKill(Killer,Victim,VictimHumanoid,Type,GameVariables["PlayerData"]);
	end
end);

game.ReplicatedStorage.Remotes.Gameplay.GunKill.Event:connect(function(Killer,Victim,VictimHumanoid)
	if GameVariables["GameMode"] ~= nil then
		GameVariables["GameMode"].GunKill(Killer,Victim,VictimHumanoid,GameVariables["PlayerData"]);
	end	
end);

local Lobby = true;

local PlayerVotes = {};

game.ReplicatedStorage.VoteForMode.OnServerEvent:connect(function(Player,Index)
	PlayerVotes[Player.Name] = Index;
	game.ReplicatedStorage.VoteForMode:FireAllClients(PlayerVotes,time());
end);
--------------------gui stuff for game types-----------------
local SpecialRound = 0;

local IsMinigamesServer = (true);

local QueueIndex = 4;
-- if QueneIndex%4==0 then Locked 
local BonusRoundQueue = {
	"---";
	"Locked";
	"Random";
	"Random";
	"Random";
	"Locked";
	"Random";
	"Random";
	"Random";
	"Locked";
	--
	--
	--
	--
};
local RandomModes = {};
local PlayerVotes = {};
local BonusPrompts = {};

game.ReplicatedStorage.VoteForMode.OnServerEvent:connect(function(Player,Index)
	PlayerVotes[Player.Name] = Index;
	game.ReplicatedStorage.VoteForMode:FireAllClients(PlayerVotes,time());
end);

game.ReplicatedStorage.BuyMode.OnServerEvent:connect(function(Player,GameMode,Index)
	if BonusPrompts[Player] == nil then
		if Index ~= 2 and BonusRoundQueue[Index] == "Random" then
			BonusPrompts[Player] = {GameMode=GameMode,Index=Index};
			game:GetService("MarketplaceService"):PromptProductPurchase(Player,_G.GameModeProducts[GameMode])
		end;
	end
end);

function game.ReplicatedStorage.GetQueue.OnServerInvoke()
	return BonusRoundQueue;
end;


-----------------------------------------------------------------------------------
while true do

	wait(60)
	
	if Sync.SyncMaps then
		Sync.SyncMaps();
	else
		print("Sync services disabled, unable to sync maps.");
	end;
	if game.Players.NumPlayers > 1 then
		print("Test")
		local CodeNames = {unpack(require(game.ServerStorage.CodeNames))};
		local Colors = {unpack(require(game.ServerStorage.Colors))};
		
		--uncomment to randomly choose game mode--
		--[[
			GameType = GameList[math.random(1, #GameList)]
		--]]
		
		--add modes--
		--------Make GameType Visible and Votable-----------
			table.remove(BonusRoundQueue,1);
			table.insert(BonusRoundQueue,QueueIndex%4==0 and "Locked" or "Random")
			QueueIndex = QueueIndex + 1;
			local CurrentMode = BonusRoundQueue[2];

			if CurrentMode == "Locked" or CurrentMode == "Random" then
				RandomModes = {};
				PlayerVotes = {};
				local AllModes = script.GameModes:GetChildren();
				for i = 1,3 do
					local RandomMode = math.random(1,#AllModes);
					table.insert(RandomModes,AllModes[RandomMode].Name)--"RUN");
					
					table.remove(AllModes,RandomMode);
				end
				game.ReplicatedStorage.VoteBonusRound:FireAllClients(BonusRoundQueue,CurrentMode,RandomModes);
			else
				game.ReplicatedStorage.VoteBonusRound:FireAllClients(BonusRoundQueue,CurrentMode);
			end;
			
			wait( (CurrentMode=="Locked"or CurrentMode=="Random" and 10) or 3 );
			
			if CurrentMode=="Locked"or CurrentMode=="Random" then
				local SelectedIndex = GameFunctions.CountVotes(PlayerVotes);
				local SelectedMode = RandomModes[SelectedIndex];
				CurrentMode = SelectedMode;
			end
			
			BonusRoundQueue[2] = CurrentMode;
			
			local CompatibleMaps = {};
			for MapName,MapTable in pairs(Sync.Data["Map"]) do
				for _,GameModeName in pairs(MapTable["GameModes"]) do
					if GameModeName == CurrentMode then
						table.insert(CompatibleMaps,MapName)
					end
				end
			end
			
			game.ReplicatedStorage.VoteBonusRoundComplete:FireAllClients( CurrentMode )

			GameVariables["GameMode"] = require(GameModes[CurrentMode]); --require(GameModes.SpecialRounds:GetChildren()[math.random(1,#GameModes.SpecialRounds:GetChildren())]);
			wait(5)
			GameVariables["Map"] = GameFunctions.VoteForMap(); ---allow map voting----GameVariables["Map"] = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]]:Clone();		
			SpecialRound = 0;

	--[[  Keep If this ^^ breaks game modes
		if GameType == "FreezeTag" then
			GameVariables["GameMode"] = require(GameModes["FreezeTag"]);
			GameVariables["Map"] =  GameFunctions.VoteForMap();
		elseif GameType == "CTF" then
			GameVariables["GameMode"] = require(GameModes["CTF"]);
		----GameVariables["Map"] = GameFunctions.VoteForMap();----
			GameVariables["Map"] = game.ServerStorage.Maps.MadHouse:Clone()
		elseif GameType == "RUN" then
			GameVariables["GameMode"] = require(GameModes["RUN"]);
			GameVariables["Map"] = GameFunctions.VoteForMap();
		elseif GameType == "Infection" then
			GameVariables["GameMode"] = require(GameModes["Infection"]);
			GameVariables["Map"] = GameFunctions.VoteForMap();
		else 
			GameVariables["GameMode"] = require(GameModes["Classic"]);
			GameVariables["Map"] = GameFunctions.VoteForMap();
		end
		--]]
		wait(1);
		
		repeat 
		wait();
		until StandardFunctions.AllCharactersLoaded();

		GameVariables["Map"].Parent = game.Workspace;
		
		--add new skybox--
		if GameVariables["Map"]:FindFirstChild("SkyBox") then
			local SkyBox = GameVariables["Map"].SkyBox.SkyBox:Clone()
			game.Lighting:FindFirstChildOfClass("Sky"):Destroy()
			SkyBox.Parent = game.Lighting
		end
		
		game.ReplicatedStorage.LoadingMap:FireAllClients(GameVariables["GameMode"].Name);
		wait(10);
		repeat wait(); until game.Players.NumPlayers > 1;
		
		GameVariables["GameMode"].DoRoles();
		GameVariables["PlayerData"] = GameVariables["GameMode"].GeneratePlayerData();
		
		for PlayerName,pData in pairs(GameVariables["PlayerData"]) do
			if game.Players:FindFirstChild(PlayerName) and game.Players:FindFirstChild(PlayerName).Character ~= nil and pData.Dead == false then
				pcall(function() game.ReplicatedStorage.Fade:FireClient(game.Players[PlayerName],GameVariables["PlayerData"]); end);
			end;
		end
		
		SongName = GameVariables["GameMode"].Name
		
		if SongList[SongName] ~= nil then
			Song = SongList[SongName]
			PlaySong:FireAllClients(Song);
		end	
		
		wait(2);
		
		GameVariables["GameMode"].SpawnPlayers();
		
		for _,Player in pairs(game.Players:GetPlayers()) do
			if GameVariables["PlayerData"][Player.Name] ~= nil then
				spawn(function() 
					GameVariables["GameMode"].MakeCharacter(Player,
						GameVariables["PlayerData"][Player.Name]["Color"],
						GameVariables["PlayerData"][Player.Name]["Role"],
						GameVariables["Map"],
						GameVariables["PlayerData"][Player.Name]["CodeName"]
					); 
					
					if _G.ServerSettings.Disguises == false then
						Data.GiveToys(Player);
					end;
				end);
			end;
		end;
		
		Lobby = false;
		
		wait(GameVariables["GameMode"].RoleSelectWait); --wait(15);

		GameVariables["GameMode"].GiveWeapons();		
		GameVariables["GameTimer"] = GameVariables["GameMode"].GameTimer;

		game.ReplicatedStorage.DoneLoading:FireAllClients();
		game.ReplicatedStorage.RoundStart:FireAllClients(GameVariables["GameTimer"]);
		
		
		if GameVariables["Map"]:FindFirstChild("CoinAreas") then	
			GameVariables["Map"].CoinAreas:Destroy();	
		end;	
		
		wait(1);
		
		if GameVariables["GameMode"].Coins and game.VIPServerId == "" then
			GameFunctions["Coins"]();
		end
		
		
		repeat 
			wait(1)
			GameVariables["GameTimer"] = GameVariables["GameTimer"] - 1;
		until GameVariables["GameTimer"] <= 0 or GameVariables["GameMode"].EndConditions();
		Lobby = true;
		
		local TimerData = GameVariables["GameTimer"];
				
		GameVariables["GameTimer"] = -1;
		GameVariables["Map"]:Destroy();
		
		for Player,pData in pairs(GameVariables["PlayerData"]) do
			if game.Players:FindFirstChild(Player) ~= nil then --and (pData["Dead"] == false or Player.Character == nil)--
				game.Players:FindFirstChild(Player):LoadCharacter();
			end;
		end;
		
		game.ReplicatedStorage.UpdatePlayerData:FireAllClients( {} )		
		
			
		for i,Part in pairs(game.Workspace:GetChildren()) do if Part.Name == "GunDrop" or Part.Name == "Raggy" then Part:Destroy() end end;	
						
		wait(4)
		
		GameVariables["GameMode"].Reward(GameVariables["PlayerData"],TimerData);		
		
		--[[if KniferDead == false and TimerData > 0 then
			PlayKniferMusic();
		else
			PlayInnocentMusic();
		end;]]
		
		GameVariables["PlayerData"] = {};
		GameVariables["GameMode"] = nil;
		game.ReplicatedStorage.UpdatePlayerData:FireAllClients( GameVariables["PlayerData"]  )
	
		wait(10);
		
		Song = SongList["Lobby"]
		PlaySong:FireAllClients(Song);
		
		--PlayLobbyMusic();
		
		
		print ("Checking version...");
		local _,Error pcall(function()
			CheckVersion = game:GetService("DataStoreService"):GetDataStore("GameData"):GetAsync("Version");
			print("Version: " .. CheckVersion);
		end);
		if Error then
			print("Error checking version: " .. Error);
		end
		
		
		if ServerVersion < CheckVersion then
			game.Workspace.Status.Message.Good.Visible = false;
			game.Workspace.Status.Message.Bad.Visible = true;
		end;
		
	end
	
	--Sync.UpdateFrames();
	
end


