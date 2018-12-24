local GameMode = {};

local Gets = script.Parent.Parent.Get
function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Data = require(script.Parent.Parent.DataModule);

local DataGet = function(Who,What)
	return game.ReplicatedStorage.GetDataServer:Invoke(Who,What)
end

local VictoryMusic = game.ReplicatedStorage.Music.RoundEnd.victoryM
local LoserMusic = game.ReplicatedStorage.Music.RoundEnd.loserM
local PlaySong = game.ReplicatedStorage.PlayMusic


local GameFunctions = Get("GameFunctions");

local RoleData = {};

GameMode.Name = "Classic";

GameMode.Coins = true;

GameMode.GameTimer = 180;

GameMode.PlayerData = {};

GameMode.RoleSelectWait = 15;

GameMode.DoRoles = function()
	RoleData = {};
	local Sync = Get("Sync");
	local Knifers = GameFunctions["Chance"].CreateChanceTable();
	local Gunners = game.Players:GetPlayers();
	local Knifer = math.random(1,#Knifers);
	
	for i,Player in pairs(Gunners) do
		if Player.Character == nil then 
			table.remove(Gunners,i)
		elseif Player.Name == Knifers[Knifer] then
			table.remove(Gunners,i);
		end
	end
		
	RoleData.Knifer = game.Players:FindFirstChild(Knifers[Knifer]);
	
	local Gunner; 
	repeat 
		RoleData.Gunner = Gunners[math.random(1,#Gunners)];
	until
		RoleData.Gunner ~= RoleData.Knifer;
	
	local ItemsDB = Sync.Data["Item"];
		
	local KnifeID = 2608018461;
	local GunID = 2628033850; --fix me--

	local KnifeModel = game.ServerStorage.Default.Pillow:Clone();
	local GunModel = game.ServerStorage.Default.PillowLauncher:Clone(); --and me--
		
	pcall(function() KnifeID = ItemsDB[Data.Get(RoleData.Knifer,"Weapons").Equipped.Knife]["ItemID"]; end);
	
	pcall(function() KnifeModel = game.InsertService:LoadAsset(KnifeID):GetChildren()[1]; end);
	
	RoleData.KniferKnife 	= KnifeModel;
	RoleData.GunnerGun 	= GunModel;
	RoleData.KniferName 	= RoleData.Knifer.Name;
end

GameMode.SpawnPlayers = function()
	local Map = Get("Map");
	for _,Player in pairs(game.Players:GetPlayers()) do
		pcall(function()
			if Player.Character ~= nil then
				Player.Character.Humanoid.WalkSpeed = 16;
				Player.Character.HumanoidRootPart.CFrame = Map.Spawns:GetChildren()[math.random(1,#Map.Spawns:GetChildren())].CFrame + Vector3.new(0,2,0)
			end
		end);
	end;
end

GameMode.GiveWeapons = function()
	local PlayerData = GameMode.PlayerData;
	local Knifer = RoleData.Knifer;
	local Gunner = RoleData.Gunner;
	local KniferKnife = RoleData.KniferKnife;
	local GunnerGun = RoleData.GunnerGun;
	local Map = Get("Map");
	for _,Player in pairs(game.Players:GetPlayers()) do
		pcall(function()
			if PlayerData[Player.Name] ~= nil then
				print("Role is " .. PlayerData[Player.Name]["Role"]);
				if PlayerData[Player.Name]["Dead"] == false then
					if PlayerData[Player.Name]["Role"] == "Knifer" then
						GameFunctions.GiveWeapon.Knife(Knifer);
					elseif PlayerData[Player.Name]["Role"] == "Gunner" then
						GameFunctions.GiveWeapon.Gun(Gunner);
					end
				end
			end
		end);
	end;
end

GameMode.Died = function()
	
end

GameMode.KnifeKill = function(Killer,Victim,VictimHumanoid,KillType,PlayerData)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "Creator";
	CreatorTag.Value = Killer;
	CreatorTag.Parent = VictimHumanoid;
	VictimHumanoid:TakeDamage(1000)
end

GameMode.GunKill = function(Killer,Victim,VictimHumanoid,PlayerData)
	if PlayerData[Victim.Name].Role ~= "Knifer" then
		Killer.Character.Humanoid:TakeDamage(1000);
	else
		_G.KniferWasShot = true;
	end;
	VictimHumanoid:TakeDamage(1000);
end

GameMode.EndConditions = function()
	if GameFunctions["StandardFunctions"].CheckForInnocents() == false then
		return true;
	end
					
	for _,pData in pairs(Get("PlayerData")) do
		if pData["Role"] == "Knifer" and pData["Dead"] == true then
			return true;
		end
	end
	
	return false;
end


GameMode.MakeCharacter = require(script.MakeCharacter);

GameMode.GeneratePlayerData = function()
	GameMode.PlayerData = {};
	local CodeNames = {unpack(require(game.ServerStorage.CodeNames))};
	local Colors = {unpack(require(game.ServerStorage.Colors))};
	for _,Player in pairs(game.Players:GetPlayers()) do
		if Player.Character ~= nil then
			if _G.ServerSettings.Disguises then
				Player:ClearCharacterAppearance();
			end;
			
			local CodeName = math.random(1,#CodeNames);		
			local Color = math.random(1,#Colors);		
			local Role = "Innocent"; 
			
			Player.HealthDisplayDistance = 0;
			Player.NameDisplayDistance = 0;				
			
			local MaxCoins;
			if Data.GetLevel(Data.Get(Player,"XP")) >= 40 then
				MaxCoins = 10;
			else
				MaxCoins = 5;
			end;
			
			--[[[if Data.Get(Player,"CoinBag") > 0 then
				MaxCoins = MaxCoins + 5;
			end]]
			
			if Player == RoleData.Knifer then
				Role = "Knifer";
			elseif Player == RoleData.Gunner then
				Role = "Gunner";
			end
			
			GameMode.PlayerData[Player.Name] = {
				["Role"] = Role;
				["CodeName"] = CodeNames[CodeName];
				["Color"] = BrickColor.new(Colors[Color]);
				["Dead"] = false;
				["XP"] = Data.Get(Player,"XP");
				["Knife"] = Data.Get(Player,"Weapons").Equipped.Knife;
				["Gun"] = Data.Get(Player,"Weapons").Equipped.Gun;
				["Coins"] = 0;
				["MaxCoins"] = MaxCoins;
			};
						
			pcall(function() Player.Character.Head.CodeNameGUI:Destroy();end);
			pcall(function() Player.Character.Torso.roblox:Destroy();end);	
			pcall(function() Player.Character.UpperTorso.roblox:Destroy();end);	

			table.remove(CodeNames,CodeName);
			table.remove(Colors,Color)
		end
	end
	return GameMode.PlayerData;
end


local function PrintTable(Table,Indent)
	local IndentString = "";
	for i = 1,Indent do
		IndentString = IndentString .. "--";
	end
	for Index,Value in pairs(Table) do
		if type(Value) == "table" then
			print(IndentString .. Index .. "{");
			PrintTable(Value,Indent+1);
		else
			print(IndentString .. Index .. ": " .. tostring(Value))
		end;
	end
end


GameMode.Reward = function(PlayerData,TimerData)
	local Winner = "Innocents";
	local XPTexts = {};
	
	for _,pData in pairs(PlayerData) do
		if pData["Role"] == "Knifer" and pData["Dead"] == false and TimerData > 0 then
			Winner = "Knifer";
		end
	end	
	
	
	for PlayerName,pData in pairs(PlayerData) do
		local DropTable;	
		spawn(function()
			local Player = game.Players:FindFirstChild(PlayerName);
			if pData["Role"] ~= "Knifer" then
				GameFunctions["Chance"].Increase(PlayerName);
			else
				GameFunctions["Chance"].Reset(PlayerName);
			end
			
			pcall(function()
				if _G.ServerSettings.Disguises then
					local NewGUI = game.ServerStorage.CodeNameGUI:Clone();
					NewGUI.ImageLabel.Image = require(game.ReplicatedStorage.CodeImages)[pData["CodeName"]];
					NewGUI.ImageLabel.ImageColor3 = pData["Color"].Color;
					NewGUI.Parent = Player.Character.Head;
				end;
			end);
			pcall(function()
				local XPText;
				if Player ~= nil then
						if pData["Role"] == "Knifer" then
							if pData["Dead"] == true or TimerData <= 0 then
								
								local Song = LoserMusic
								PlaySong:FireClient(Player, Song)
								
								Data.Give(Player,"XP",10);
								local Amount = 10*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								XPTexts[Player] = "You gained " .. Amount .. " xp for losing";
							else
								
								local Song = VictoryMusic
								PlaySong:FireClient(Player, Song)
								
								Data.Give(Player,"XP",50);
								
								local Amount = 50*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								XPTexts[Player] = "You gained " .. Amount .. " bonus xp for winning";
							end
							
						elseif 	pData["Role"] == "Gunner" then
							
							if pData["Dead"] == false and PlayerData[RoleData.KniferName]["Dead"] == true then
								
								local Song = VictoryMusic
								PlaySong:FireClient(Player, Song)

								local Amount1 = 50*10;
								Amount1 = (_G.CheckElite(Player) and Amount1*1.5) or Amount1;
								
								local Amount2 = (GameFunctions["StandardFunctions"].CountInnocentsAlive(PlayerData)*100);
								Amount2 = (_G.CheckElite(Player) and Amount2*1.5) or Amount2;
								
								Data.Give(Player,"XP",50+(GameFunctions["StandardFunctions"].CountInnocentsAlive(PlayerData)*10));
								XPTexts[Player] = "You gained " .. Amount1 .. " xp for winning, plus ".. Amount2 .. " for saving " .. GameFunctions["StandardFunctions"].CountInnocentsAlive(PlayerData) .. " innocents";
							else
								
								local Song = LoserMusic;
								PlaySong:FireClient(Player, Song)
								
								local Amount = 10*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",10);
								XPTexts[Player] = "You gained " .. Amount .. " xp for not shooting the Knifer";
							end
							
						elseif 	pData["Role"] == "Hero" then
							
							if pData["Dead"] == false and PlayerData[RoleData.KniferName]["Dead"] == true then
								
								local Song = VictoryMusic
								PlaySong:FireClient(Player, Song)
								
								local Amount = 200*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",200);
								XPTexts[Player] = "You gained " .. Amount .. " xp for shooting the Knifer";
							elseif pData["Dead"] == false then
								
								local Song = VictoryMusic
								PlaySong:FireClient(Player, Song)
								
								local Amount = (180-TimerData)*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",180-TimerData);
								XPTexts[Player] = "You gained " .. Amount .. " xp for surviving for " .. 180-TimerData .. " seconds";
							else
								local Song = LoserMusic;
								PlaySong:FireClient(Player, Song)

								local Amount = 10*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",10);
								XPTexts[Player] = "You gained " .. Amount .. " xp for losing";
							end
							
						elseif 	pData["Role"] == "Innocent"	then
							
							if pData["Dead"] == false then
								
								local Song = VictoryMusic
								PlaySong:FireClient(Player, Song)
								
								local Amount = (180-TimerData)*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",180-TimerData);
								XPTexts[Player] = "You gained " .. Amount .. " xp for surviving for " .. 180-TimerData .. " seconds";
							else

								local Song = LoserMusic;
								PlaySong:FireClient(Player, Song)

								local Amount = 10*10;
								Amount = (_G.CheckElite(Player) and Amount*1.5) or Amount;
								
								Data.Give(Player,"XP",10);
								XPTexts[Player] = "You gained " .. Amount .. " xp for losing";
							end
							
						end	
						
					if game.VIPServerId == "" then
						DropTable = Data.GiveDrops(Player);
					end;
					
						
					--if Data.Get(game.Players[Player],"CoinBag") > 0 then
						--Data.Give(game.Players[Player],"CoinBag",-1); -- coin bag expiry
					--end
				end
				--Data.SaveData(Player);
				local TitleText = (Winner=="Knifer" and "Knifer Wins") or "Innocents Win";
				local TitleTextColor = (Winner=="Knifer" and Color3.new( (213) /255, (23) /255, (26) /255 )) or Color3.new( (48) /255, (206) /255, (0) /255 );
				game.ReplicatedStorage.GameOver:FireClient(Player,PlayerData,TimerData,GameMode.Name,XPTexts[Player],Winner,TitleText,TitleTextColor,DropTable);
			end);
		end);
	end;
	--[[for _,Player in pairs(game.Players:GetPlayers()) do
		local XPText = "";
		if XPTexts[Player.Name] ~= nil then
			XPText = XPTexts[Player.Name]
		end;
		game.ReplicatedStorage.GameOver:FireClient(Player,PlayerData,TimerData,GameMode.Name,XPText,Winner);
	end]]
	
	_G.MurderWasShot = false;
end


return GameMode;










