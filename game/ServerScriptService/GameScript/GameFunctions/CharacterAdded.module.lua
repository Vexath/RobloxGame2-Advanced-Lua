local Gets = script.Parent.Parent.Get
local Set = script.Parent.Parent.Set;

local function SpawnLobby(Player)
	local Spawns = workspace.Lobby.Spawns:GetChildren()
	if Player.Character ~= nil then
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
	end
end

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local DataModule = require(script.Parent.Parent.DataModule);

local Module = function(Player,Character)
	Player.HealthDisplayDistance = 0;
	Player.NameDisplayDistance = 100;
	Player.Backpack.ChildAdded:connect(function(Child)
		if Get("PlayerData")[Player.Name] ~= nil then
			if Get("PlayerData")[Player.Name]["Role"] == "Knifer" and Child:FindFirstChild("IsGun") then
				repeat Child:Destroy(); wait();
				until Child.Parent == nil;
			end;
		end
	end)

	Character.ChildAdded:connect(function(Child)
		if Get("PlayerData")[Player.Name] ~= nil then --
			if Get("PlayerData")[Player.Name]["Role"] == "Knifer" and Child:FindFirstChild("IsGun") then
				repeat Child:Destroy(); wait();
				until Child.Parent == nil;
			end;
		end
		Player.HealthDisplayDistance = 0;
	end)		
	
	if DataModule.TradingPlayers[Player] == true then --
		game.ServerStorage.TradingGUI:Clone().Parent = Character;
	end
	
	Player.Character.Humanoid.Died:connect(function()
		if Get("PlayerData")[Player.Name] ~= nil and not Get("PlayerData")[Player.Name]["Dead"] then
			
			local IsDead = Get("PlayerData")[Player.Name]["Dead"];	
			
			Get("GameMode").Died(Player);			
			
			Set.PlayerData:Fire(Player.Name,"Dead",true);

			if IsDead == false then
				if Get("PlayerData")[Player.Name]["Role"] == "Gunner" and Get("GameMode").Name == "Classic" then
					Get("GameFunctions").GunDrop.Drop(Player,Get("PlayerData"));
				elseif Get("PlayerData")[Player.Name]["Role"] == "Hero" and Get("GameMode").Name == "Classic" then
					Get("GameFunctions").GunDrop.Drop(Player,Get("PlayerData"));
				end
			end;
			
			game.ReplicatedStorage.UpdatePlayerData:FireAllClients( Get("PlayerData") )
			
			if Get("GameMode").Coins then
				if Get("PlayerData")[Player.Name]["Coins"] ~= nil and Get("PlayerData")[Player.Name]["Coins"] > 1 then
					local DroppedCoins = Get("PlayerData")[Player.Name]["Coins"] - math.ceil(Get("PlayerData")[Player.Name]["Coins"]/2);
					Set.PlayerData:Fire(Player.Name,"Coins",math.ceil(Get("PlayerData")[Player.Name]["Coins"]/2));
					
					for i = 1,DroppedCoins do
						local Torso3
						if Player.Character:FindFirstChild("Torso") then
							Torso3 = Player.Character.Torso
						end
						if Player.Character:FindFirstChild("UpperTorso") then
							Torso3 = Player.Character.UpperTorso
						end
						
						local NewCoin = game.ServerStorage.Coin:Clone();
					    NewCoin.CFrame = (CFrame.new(Torso3.CFrame.p)+Vector3.new(math.random(1,5)/10,math.random(1,5)/10,math.random(1,5)/10)) * CFrame.Angles(math.pi/2, -math.pi/2, 0);
						NewCoin.Parent = Get("Map").CoinContainer;
						local DeathTimer = time();
						local TouchCon;
						TouchCon = NewCoin.Touched:connect(function(Toucher)
							if time()-DeathTimer > 0.25 then
								local Coiner = game.Players:GetPlayerFromCharacter(Toucher.Parent);
								if Coiner ~= nil and Coiner ~= Player then
									if Get("PlayerData")[Coiner.Name] ~= nil then
										if Get("PlayerData")[Coiner.Name]["Coins"] < Get("PlayerData")[Coiner.Name]["MaxCoins"] then
											TouchCon:disconnect();
											local Sound = game.ServerStorage.CoinSound:Clone();
											pcall(function()
												local torso
												if Coiner.Character:FindFirstChild("Torso") then
													torso = Coiner.Character.Torso
												end
												if Coiner.Character:FindFirstChild("UpperTorso") then
													torso = Coiner.Character.UpperTorso
												end
												Sound.Parent = torso;
												Sound:Play();
											end)
											game.Debris:AddItem(Sound,3)
											NewCoin:Destroy();
											game.ReplicatedStorage.GetCoin:FireClient(Coiner);
											Set.PlayerData:Fire(Player.Name,"Coins",Get("PlayerData")[Coiner.Name]["Coins"] + 1);
											DataModule.Give(Coiner,"Credits",1);
										end
									end
								end
							end;
						end)
					end
				end;
			end
			--torso handled from here down--
			local Torso
			if Player.Character:FindFirstChild("Torso") then
				Torso = Player.Character.Torso
			end
			if Player.Character:FindFirstChild("UpperTorso") then
				Torso = Player.Character.UpperTorso
			end
			
			if Player.Character.Humanoid:FindFirstChild("Creator") then
				pcall(function()
					local Killer = Player.Character.Humanoid.Creator.Value;
					if Get("PlayerData")[Killer.Name]["Role"] == "Knifer" then
						if Get("PlayerData")[Killer.Name]["Effect"] ~= "Ninja" then
							print("Play4");
						end;
					end
					game.ReplicatedStorage.SpecialXPEvent:FireClient(Killer,"Melee Kill! +250")
					DataModule.Give(Killer,"XP",25);
				end);
			elseif Player.Character.Humanoid:FindFirstChild("Creator2") then
				pcall(function()
					local Killer = Player.Character.Humanoid.Creator2.Value;
					if Get("PlayerData")[Killer.Name]["Role"] == "Knifer" then
						if Get("PlayerData")[Killer.Name]["Effect"] ~= "Ninja" then
							print("Play3");
						end;
					end
					game.ReplicatedStorage.SpecialXPEvent:FireClient(Killer,"Throwing Kill! +100")
					DataModule.Give(Killer,"XP",10);
				end);
			else
				print("Play1");
			end;		
							
			wait(3)
			
			if Get("GameTimer") > -1 or Player.Character == nil or (Player.Character and Player.Character.Parent == nil) then
				if Player ~= nil then
					Player:LoadCharacter()
					SpawnLobby(Player)
				end;
			end
		else
			print("Play2");
			Player:LoadCharacter();
			SpawnLobby(Player)

		end
	end)
	
	
	---------------------
	local HasAccessory,CanUse = _G.CheckAccessory(Player)
	local UseAccessory = (HasAccessory and CanUse);
	
	if UseAccessory then 
		_G.WeldAccessory(Player);
	end	
	------- WELD WEAPONS

	local ItemsDB = Get("Sync").Data["Item"];
	local KnifeName = DataModule.Get(Player,"Weapons").Equipped.Knife;
	local EquippedKnife = game.ServerStorage.Default.Pillow:Clone(); 
	pcall(function() EquippedKnife = game.InsertService:LoadAsset(ItemsDB[KnifeName]["ItemID"]):GetChildren()[1]; EquippedKnife.TextureId = ItemsDB[KnifeName].Image; end);
		
	local Effects = Get("Sync").Data["Effects"];
	local EquippedEffect = DataModule.Get(Player,"Effects").Equipped[1];
	if Effects[EquippedEffect] ~= nil then
	--try to equip effect--
		pcall(function() 
			local NewEffect = game.InsertService:LoadAsset(Effects[EquippedEffect]["KnifeModule"]):GetChildren()[1];
			NewEffect.Name = EquippedEffect
			--Welding it was a pain in the ass, just get the particle effects
			for i,v in pairs(EquippedKnife.Handle:GetChildren())do
				if v:IsA("ParticleEmitter") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
					v:Destroy()
				end
			end
			for i,v in pairs(NewEffect:GetChildren())do
				if v:IsA("ParticleEmitter") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
					local effectz = v:Clone()
					effectz.Parent = EquippedKnife.Handle
				end
			end
		end)
	end
	
	local KnifeRotation = ItemsDB[KnifeName]["Angles"] 
	local RadioRotation = ItemsDB[KnifeName]["RadioAngles"]
	
	local KnifePosition = ItemsDB[KnifeName]["Offset"] 
	local RadioOffset = ItemsDB[KnifeName]["RadioOffset"];
	
	--[[	
	local Handle = EquippedKnife.Handle:Clone();

	EquippedKnife:Destroy();
	Handle.CanCollide = false;
	Handle.CFrame = Player.Character.HumanoidRootPart.CFrame;
	local KnifeWeld = Instance.new("Weld",Player.Character.HumanoidRootPart);
	KnifeWeld.Part0 = Player.Character.HumanoidRootPart;
	KnifeWeld.Part1 = Handle;
	
	--]]
	
	local DefaultRotation;
	local DefaultPosition;
	
	local function dAngles(Data)
		return CFrame.Angles(Data.X,Data.Y,Data.Z)
	end
	
	local function dOffset(Data)
		return CFrame.new(Data.X,Data.Y,Data.Z)
	end

	if not UseAccessory  then 
		DefaultRotation = 
			(KnifeRotation and dAngles(KnifeRotation))
			or CFrame.Angles(-math.pi/2,math.pi/4,math.pi/2);
		
		DefaultPosition = 
			(KnifeRotation and CFrame.new(0,0,0.5))
			or CFrame.new(-0.1,0,0.5);
		
		DefaultPosition = (KnifePosition and dOffset(KnifePosition)) or DefaultPosition;
	else
		DefaultPosition = (RadioOffset and dOffset(RadioOffset)) or CFrame.new(-1,-1.3,0.25);
		DefaultRotation = CFrame.Angles(math.rad(-60),0,math.rad(180));
		DefaultRotation = 
			(RadioRotation and dAngles(RadioRotation)	) 
		or 	(KnifeRotation and DefaultRotation * dAngles(KnifeRotation)	) 	
		or 	DefaultRotation;
	end;
	--[[
	KnifeWeld.C0 =  DefaultPosition * DefaultRotation;
	
	KnifeWeld.C1 = CFrame.new();
	Handle.Name = "KnifeDisplay";
	Handle.Parent = Player.Character;
	
	local GunName = DataModule.Get(Player,"Weapons").Equipped.Gun;
	
	local EquippedGun = game.ServerStorage.Default.Gun:Clone();
	pcall(function() EquippedGun = game.InsertService:LoadAsset(ItemsDB[GunName]["ItemID"]):GetChildren()[1]; end);
	
	local GunRotation = ItemsDB[GunName]["Angles"] 
	
	local Handle2 = EquippedGun.Handle:Clone();
	EquippedGun:Destroy();
	Handle2.CanCollide = false;
	Handle2.CFrame = Player.Character.Torso.CFrame;
	local GunWeld = Instance.new("Weld",Player.Character.Torso);
	GunWeld.Part0 = Player.Character.Torso;
	GunWeld.Part1 = Handle2;
	if GunRotation ~= nil then
		GunWeld.C0 = CFrame.new(1,-1.5,0.2) * CFrame.Angles(GunRotation["X"],GunRotation["Y"],GunRotation["Z"])
	else
		GunWeld.C0 = CFrame.new(1,-1.5,0.2) * CFrame.Angles(math.rad(150),0,0)
	end;
	GunWeld.C1 = CFrame.new();
	Handle2.Name = "GunDisplay";
	Handle2.Parent = Player.Character;		
		--]]
	
	for _,Part in pairs(Character:GetChildren()) do
		if Part.Name == "RabbitWitch" then
			require(script.WeldHat)(Part,Character);
		end
	end
	
end

return Module;
