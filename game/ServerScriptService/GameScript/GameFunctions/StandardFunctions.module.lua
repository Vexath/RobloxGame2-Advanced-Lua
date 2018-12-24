local Module = {}

local Gets = script.Parent.Parent.Get

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Set = script.Parent.Parent.Set.PlayerData;

Module.PlayerRemoving = function(Player)
	local PlayerData = Get("PlayerData");
	local pData = PlayerData[Player.Name];
	if pData ~= nil then
		local GameMode = Get("GameMode");
		if GameMode.Name == "Classic" then
			Set:Fire(Player.Name,"Dead",true);
		end;
		if GameMode.Name == "CTF" then
			Set:Fire(Player.Name,"Dead",true);
		end
		if GameMode.Name == "FreezeTag" then
			Set:Fire(Player.Name,"Dead",true);
		end
		if GameMode.Name == "RUN" then
			Set:Fire(Player.Name,"Dead",true);
		end
		game.ReplicatedStorage.UpdatePlayerData:FireAllClients( PlayerData )
	end
end

Module.CheckForInnocents = function()
	local PlayerData = Get("PlayerData");
	for PlayerName,Data in pairs(PlayerData) do
		if (Data["Role"] == "Innocent" or Data["Role"] == "Gunner" or Data["Role"] == "Hero") and Data["Dead"] == false then
			return true;
		end
	end
	return false;
end

Module.CountInnocentsAlive = function(PlayerData)
	local Count = 0;
	for PlayerName,Data in pairs(PlayerData) do
		if Data["Role"] == "Innocent" and Data["Dead"] == false then
			Count = Count + 1;
		end
	end
	return Count;
end

Module.AllCharactersLoaded = function()
	for i,Player in pairs(game.Players:GetPlayers()) do
		if Player.Character == nil then
			return false;
		elseif Player.Character:FindFirstChild("Humanoid") == false then
			return false;
		end
	end
	return true;
end


Module.CountInnocentsDead = function()
	local PlayerData = Get("PlayerData");
	local Count = 0;
	for PlayerName,Data in pairs(PlayerData) do
		if (Data["Role"] == "Innocent" or Data["Role"] == "Gunner") and Data["Dead"] == true then
			Count = Count + 1;
		end
	end
	return Count;
end

return Module;
