local Module = {};

local Gets = script.Parent.Parent.Get

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Data = require(script.Parent.Parent.DataModule);
local Set = script.Parent.Parent.Set.PlayerData;

Module.PlayerRemoving = function(Player)
	if Get("GameMode") == "Classic" then
		local PlayerData = Get("PlayerData");
		local GiveGun = Get("GameFunctions")["GiveWeapon"].Gun;
		local Map = Get("Map");
		local Sync = Get("Sync");
		if PlayerData[Player.Name] ~= nil then
			if PlayerData[Player.Name]["Role"] == "Knifer" then
				--KniferDead = true;
			elseif PlayerData[Player.Name]["Role"] == "Gunner" and not PlayerData[Player.Name]["Dead"] then
				pcall(function()
					local GunDrop = game.ServerStorage.GunDrop:Clone();
					GunDrop.Position = Map.Spawns:GetChildren()[math.random(1,#Map.Spawns:GetChildren())].Position;
					GunDrop.Parent = game.Workspace;
					GunDrop.Touched:connect(function(TouchedPart)
						local tCharacter = TouchedPart.Parent;
						local Hero = game.Players:GetPlayerFromCharacter(tCharacter)
						if Hero ~= nil and Hero ~= Player then
							if PlayerData[Hero.Name]["Role"] ~= "Knifer" then
								Set:Fire(Hero.Name,"Role","Hero");
								GunDrop:Destroy();
								GiveGun(Hero)
							end
						end
					end)
				end);
			elseif PlayerData[Player.Name]["Role"] == "Hero" and not PlayerData[Player.Name]["Dead"] then
				pcall(function()
					Set:Fire(Player.Name,"Role","Innocent");
					local GunDrop = game.ServerStorage.GunDrop:Clone();
					GunDrop.Position = Map.Spawns:GetChildren()[math.random(1,#Map.Spawns:GetChildren())].Position;
					GunDrop.Parent = game.Workspace;
					GunDrop.Touched:connect(function(TouchedPart)
						local tCharacter = TouchedPart.Parent;
						local Hero = game.Players:GetPlayerFromCharacter(tCharacter)
						if Hero ~= nil and Hero ~= Player then
							if PlayerData[Hero.Name]["Role"] ~= "Knifer" then
								Set:Fire(Hero.Name,"Role","Hero");
								GunDrop:Destroy();
								GiveGun(Hero)
							end
						end
					end)
				end);
			end;
			PlayerData[Player.Name]["Dead"] = true;
		end
	end;
end

Module.Drop = function(Victim)
	local PlayerData = Get("PlayerData");
	local GiveGun = Get("GameFunctions")["GiveWeapon"].Gun;
	local Map = Get("Map");
	local Sync = Get("Sync");
	local Status,Error = pcall(function()
		local GunDrop = game.ServerStorage.GunDrop:Clone();
		GunDrop.CFrame = Victim.Character.Torso.CFrame;
		GunDrop.Parent = game.Workspace;
		GunDrop.Touched:connect(function(TouchedPart)
			local tCharacter = TouchedPart.Parent;
			local Hero = game.Players:GetPlayerFromCharacter(tCharacter)
			if Hero ~= nil and Hero ~= Victim and PlayerData[Hero.Name] ~= nil then
				if PlayerData[Hero.Name]["Role"] ~= "Knifer" and PlayerData[Hero.Name]["Dead"] == false then
					Set:Fire(Hero.Name,"Role","Hero");
					GunDrop:Destroy();
					GiveGun(Hero);
				end
			end
		end)
	end);
	if not Status then
		print("Erorr: " .. Error);
		local GunDrop = game.ServerStorage.GunDrop:Clone();
		GunDrop.Position = Map.Spawns:GetChildren()[math.random(1,#Map.Spawns:GetChildren())].Position;
		GunDrop.Parent = game.Workspace;
		GunDrop.Touched:connect(function(TouchedPart)
			local tCharacter = TouchedPart.Parent;
			local Hero = game.Players:GetPlayerFromCharacter(tCharacter)
			if Hero ~= nil and Hero ~= Victim then
				if PlayerData[Hero.Name]["Role"] ~= "Knifer" then
					Set:Fire(Hero.Name,"Role","Hero");
					GunDrop:Destroy();
					GiveGun(Hero);
				end
			end
		end)
	end	
end

return Module;
