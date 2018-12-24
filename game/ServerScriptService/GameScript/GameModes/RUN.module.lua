local GameMode = {};

local Gets = script.Parent.Parent.Get
local Set = script.Parent.Parent.Set.PlayerData;
function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Data = require(script.Parent.Parent.DataModule);

local DataGet = function(Who,What)
	return game.ReplicatedStorage.GetDataServer:Invoke(Who,What)
end

local GameFunctions = Get("GameFunctions");


local VictoryMusic = game.ReplicatedStorage.Music.RoundEnd.victoryM
local LoserMusic = game.ReplicatedStorage.Music.RoundEnd.loserM
local PlaySong = game.ReplicatedStorage.PlayMusic

local RoleData = {};

GameMode.Name = "RUN";

GameMode.Outfits = "Map";

GameMode.Coins = true;

GameMode.GameTimer = 120;

GameMode.PlayerData = {};

GameMode.RoleSelectWait = 8;

GameMode.DoRoles = function()

end

GameMode.MakeCharacter = function(Player,Color,RoleName,Map,CodeName)
	game.ReplicatedStorage.RoleSelect:FireClient(Player,RoleName,Color,CodeName,_G.ServerSettings.LockFirstPerson,"RUN");
end;

GameMode.SpawnPlayers = function()
	local Map = Get("Map");
	local PlayerData = Get("PlayerData");
	
	local Spawns = Map.Spawns:GetChildren();
	
	for _,Player in pairs(game.Players:GetPlayers()) do --pcall(function()
		local pData = PlayerData[Player.Name];
		
		if Player.Character ~= nil and pData ~= nil then
			local iSpawn = math.random(1,#Spawns);
			local Torso
				
			if Player.Character:FindFirstChild("Torso") then
				Torso = Player.Character.Torso
			end
				
			if Player.Character:FindFirstChild("UpperTorso") then
				Torso = Player.Character.UpperTorso
			end
			if Torso == nil then
				Player:LoadCharacter();
			end
			
			if Player.Character:FindFirstChild("Torso") then
				Torso = Player.Character.Torso
			end
			if Player.Character:FindFirstChild("UpperTorso") then
				Torso = Player.Character.UpperTorso
			end
				
			Torso.CFrame = Spawns[iSpawn].CFrame + Vector3.new(0,2,0)
			table.remove(Spawns,iSpawn);
			end;
		end
		wait()	--role select wait

	for _,Player in pairs(game.Players:GetPlayers()) do --pcall(function()
	local pData = PlayerData[Player.Name];
	if Player.Character ~= nil and pData ~= nil then
		if pData.Role == "Monster" then				
			Player.Character.Humanoid.MaxHealth = (#game.Players:GetPlayers()-1) * 100 * 4;
			Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth;
			--animation levitation to make it look better--
			
			if Player.Character:FindFirstChild("Animate") then
				Player.Character.Animate:Destroy()
			end

			local newAnimation = script.Levitation.Animate:Clone()
			newAnimation.Name = ("Animate")
			newAnimation.Parent = Player.Character
			
			
			
			local HealthBar = script.HealthBar:Clone();
			HealthBar.Parent = Player.Character.Head;
			local Character = Player.Character
			--Skin player as monster--
			for _,Part in pairs(Character:GetChildren()) do 
				if Part:IsA("CharacterMesh") or Part:IsA("Clothing") or Part:IsA("BodyColors") then
					Part:Destroy();
				end
			end
	
			--randomMonster--
			local MonsterChoice

			local MonsterList = {
				[1] = script.Monsters.FreddyK;
				[2] = script.Monsters.Jason;
				[3] = script.Monsters.NightmareBoy;
				[4] = script.Monsters.NightmareChica;
				[5] = script.Monsters.NightmareFreddy;
				[6] = script.Monsters.Skellington;
			}
	
			MonsterChoice = MonsterList[math.random(1, #MonsterList)]
			local meshChoice = MonsterChoice:Clone()
			meshChoice.Parent = Player.Character.Head
	
			Character:findFirstChild("LeftFoot").Transparency = 0.3
			Character:findFirstChild("LeftHand").Transparency = 0.3
			Character:findFirstChild("LeftLowerArm").Transparency = 0.3
			Character:findFirstChild("LeftLowerLeg").Transparency = 0.3
			Character:findFirstChild("LeftUpperArm").Transparency = 0.3
			Character:findFirstChild("LeftUpperLeg").Transparency = 0.3
			Character:findFirstChild("LowerTorso").Transparency = 0.3
			Character:findFirstChild("RightFoot").Transparency = 0.3
			Character:findFirstChild("RightHand").Transparency = 0.3
			Character:findFirstChild("RightLowerArm").Transparency = 0.3
			Character:findFirstChild("RightLowerLeg").Transparency = 0.3
			Character:findFirstChild("RightUpperArm").Transparency = 0.3
			Character:findFirstChild("RightUpperLeg").Transparency = 0.3
			Character:findFirstChild("UpperTorso").Transparency = 0.3
			Character:findFirstChild("Head").Transparency = 0.3
			Character:findFirstChild("Head").face.Transparency = 0.3

			if Character:findFirstChild("Shirt") ~= nil then
				Character:findFirstChild("Shirt"):Destroy()
			end
			if Character:findFirstChild("Pants") ~= nil then
				Character:findFirstChild("Pants"):Destroy()
			end
			if Character:findFirstChild("Shirt Graphic") ~= nil then
				Character:findFirstChild("Shirt Graphic"):Destroy()
			end

			local d = Character:GetChildren() 
			for i=1, #d do 
				if (d[i].className == "Accessory") then 
					d[i]:Destroy()
				end
			end
			if Character:FindFirstChild("Accessory") then
				Character.Accessory:Destroy()
			end
	
			if Character.Head:FindFirstChild("face") then
				Character.Head.face:Destroy();
			end
				
			Player.Character.Humanoid.HealthChanged:connect(function(Health)
					
				local Percent = Health / Player.Character.Humanoid.MaxHealth;
				HealthBar.Bar.Size = UDim2.new(Percent,0,0.25,0);
					
				HealthBar.Bar.BackgroundColor3 = 
					(Percent >= 0.75 and Color3.new(0, 170/255, 0)) or
					(Percent < 0.75 and Percent >= 0.5 and Color3.new(1,1,0)) or
					(Percent < 0.5 and Percent >= 0.25 and Color3.new(1,170/255,0)) or
					(Percent < 0.25 and Color3.new(1,0,0));
				
				Set:Fire(Player.Name,"HealthPercent",Percent)

			end)
				
			HealthBar.Enabled = true;
			
			--[[
			pcall(function() require(script.Size).new(Player.Character):Resize(1.5); end);
			script.FixWeld:Clone().Parent = Knife;

			wait();
			Knife.FixWeld.Disabled = false;
			--]]
			end;
		end

	end--end);end;
end

GameMode.GiveWeapons = function()
	local PlayerData = Get("PlayerData");
	local Map = Get("Map");
	
	for _,Player in pairs(game.Players:GetPlayers()) do pcall(function()
		
		if PlayerData[Player.Name].Role ~= "Monster" then
			local Gun = GameFunctions.GiveWeapon.Gun(Player);
		else
			local Knife = GameFunctions.GiveWeapon.Knife(Player);
		end;
		Player.Character.Humanoid.WalkSpeed = 16;
			
	end);end;
end

GameMode.Died = function()
	
end

GameMode.KnifeKill = function(Killer,Victim,VictimHumanoid,KillType,PlayerData)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = ( KillType == "Throwing" and "Creator2" ) or "Creator";
	CreatorTag.Value = Killer;
	CreatorTag.Parent = VictimHumanoid;
	VictimHumanoid:TakeDamage(1000)
end

GameMode.GunKill = function(Killer,Victim,VictimHumanoid,PlayerData)

	VictimHumanoid:TakeDamage(100);
	
end

GameMode.EndConditions = function()
	
	for _,pData in pairs(Get("PlayerData")) do
		if pData["Role"] == "Monster" and pData["Dead"] == true then
			return true;
		end
	end	
	
	local AliveCount = 0;
	for Player,pData in pairs(Get("PlayerData")) do
		if not pData.Dead then AliveCount = AliveCount+1; end;
	end;
	return (AliveCount<=1);
end

GameMode.GeneratePlayerData = function()
	GameMode.PlayerData = {};
	
	local Monster = game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())];
	
	for _,Player in pairs(game.Players:GetPlayers()) do if Player.Character ~= nil then if _G.ServerSettings.Disguises then Player:ClearCharacterAppearance(); end;
	
		local Role = (Player==Monster and "Monster") or "MonsterHunter";
		
		Player.HealthDisplayDistance = 0;
		Player.NameDisplayDistance = 150;		
				

	GameMode.PlayerData[Player.Name] = {["Role"] = Role; HealthPercent = 1; ["Dead"] = false;["Effect"]=Data.Get(Player,"Effects").Equipped[1]; ["XP"] = Data.Get(Player,"XP");["Knife"] = Data.Get(Player,"Weapons").Equipped.Knife;["Gun"] = Data.Get(Player,"Weapons").Equipped.Gun;};		
	pcall(function() Player.Character.Head.CodeNameGUI:Destroy();end); pcall(function() Player.Character.Torso.roblox:Destroy();end); end end
	return GameMode.PlayerData;
end



GameMode.Reward = function(PlayerData,TimerData)
	
	local Winner = "MonsterHunters";
	
	if TimerData > 0 then
		for pName,pData in pairs(PlayerData) do
			if pData["Dead"] == false and pData["Role"] == "Monster" then
				Winner = pName;
				break;
			end
		end;
	end;
	
	local TitleText = (Winner=="MonsterHunters" and "The Monster Hunters have defeated the Monster!") or Winner .. " has slain the MonsterHunters!";
	local TitleTextColor = 
		Winner~="MonsterHunters" and Color3.new(217/255, 35/255, 35/255) or
		Color3.new(63/255, 176/255, 224/255);
	
	for Player,pData in pairs(PlayerData) do			
		ypcall(function()
			if pData["Dead"] == false and pData["Role"] == "Monster" and TimerData > 0 then
				
				local Song = VictoryMusic
				PlaySong:FireClient(game.Players[Player], Song)

				local XPAmount = 50;
				local CoinAmount = 10;
				
				local IsElite = _G.CheckElite(game.Players[Player]);
				local EliteAmount = ( IsElite and math.ceil(CoinAmount*0.5) ) or 0;
				local CoinText = "You earned " .. CoinAmount .. " coins for winning." 
				if IsElite then 
					CoinText = CoinText .. " (+" .. EliteAmount .. " from Elite)";
				end
				
				Data.Give(game.Players[Player],"Credits",CoinAmount+EliteAmount);
				Data.Give(game.Players[Player],"XP",XPAmount);
				
				game.ReplicatedStorage.GameOver:FireClient(
					game.Players[Player],
					PlayerData,
					TimerData,
					GameMode.Name,
					"You gained " .. XPAmount*10 .. " xp for winning.",
					Winner,
					TitleText,
					TitleTextColor,
					CoinText
				);
				
			elseif (pData["Dead"] == true and pData["Role"] == "Monster") or TimerData < 1 then
				
				local XPAmount = 10;
				local CoinAmount = 5;
				
				local Song = LoserMusic
				PlaySong:FireClient(game.Players[Player], Song)
				
				local IsElite = _G.CheckElite(game.Players[Player]);
				local EliteAmount = ( IsElite and math.ceil(CoinAmount*0.5) ) or 0;
				local CoinText = "You earned " .. CoinAmount .. " coins for participating." 
				if IsElite then 
					CoinText = CoinText .. " (+" .. EliteAmount .. " from Elite)";
				end
				
				Data.Give(game.Players[Player],"Credits",CoinAmount+EliteAmount);
				Data.Give(game.Players[Player],"XP",XPAmount);
				
				game.ReplicatedStorage.GameOver:FireClient(
					game.Players[Player],
					PlayerData,
					TimerData,
					GameMode.Name,
					"You gained " .. XPAmount*10 .. " xp for participating.",
					Winner,
					TitleText,
					TitleTextColor,
					CoinText
				);
				
			elseif pData["Role"] ~= "Monster" and Winner ~= "MonsterHunters" then
				
				local XPAmount = 10;
				local CoinAmount = 5;
				
				local Song = LoserMusic
				PlaySong:FireClient(game.Players[Player], Song)
				
				local IsElite = _G.CheckElite(game.Players[Player]);
				local EliteAmount = ( IsElite and math.ceil(CoinAmount*0.5) ) or 0;
				local CoinText = "You earned " .. CoinAmount .. " coins for participating." 
				if IsElite then 
					CoinText = CoinText .. " (+" .. EliteAmount .. " from Elite)";
				end
				
				Data.Give(game.Players[Player],"Credits",CoinAmount+EliteAmount);
				Data.Give(game.Players[Player],"XP",XPAmount);
				
				game.ReplicatedStorage.GameOver:FireClient(
					game.Players[Player],
					PlayerData,
					TimerData,
					GameMode.Name,
					"You gained " .. XPAmount*10 .. " xp for participating.",
					Winner,
					TitleText,
					TitleTextColor,
					CoinText
				);
				
			elseif pData["Role"] ~= "Monster" and Winner == "MonsterHunters" then
				
				local XPAmount = 50;
				local CoinAmount = 10;

				local Song = VictoryMusic
				PlaySong:FireClient(game.Players[Player], Song)				

				local IsElite = _G.CheckElite(game.Players[Player]);
				local EliteAmount = ( IsElite and math.ceil(CoinAmount*0.5) ) or 0;
				local CoinText = "You earned " .. CoinAmount .. " coins for winning." 
				if IsElite then 
					CoinText = CoinText .. " (+" .. EliteAmount .. " from Elite)";
				end
				
				Data.Give(game.Players[Player],"Credits",CoinAmount+EliteAmount);
				Data.Give(game.Players[Player],"XP",XPAmount);
				
				game.ReplicatedStorage.GameOver:FireClient(
					game.Players[Player],
					PlayerData,
					TimerData,
					GameMode.Name,
					"You gained " .. XPAmount*10 .. " xp for winning.",
					Winner,
					TitleText,
					TitleTextColor,
					CoinText
				);
				
			end;
			
		end);
	end;
	
	
end


return GameMode;










