local Gets = script.Parent.Parent.Get

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end


local module = function(Sync,ServerVersion,Data,GameFunctions,GameConstants)
	
	function game.ReplicatedStorage.GetItemData.OnServerInvoke(Player)
		return Sync.Data["Item"];
	end
	
	function game.ReplicatedStorage.GetVersion.OnServerInvoke()
		return ServerVersion;
	end
	
	function game.ReplicatedStorage.GetChance.OnServerInvoke(Player)
		return GameFunctions.Chance.Get(Player.Name);
	end
	
	function game.ReplicatedStorage.GetPlayerData.OnServerInvoke()
		return Get("PlayerData");
	end
	
	function game.ReplicatedStorage.GetTimer.OnServerInvoke()
		return Get("GameTimer");
	end
	
	function game.ReplicatedStorage.GetPlayerData_REMOTE.OnInvoke()
		return Get("PlayerData");
	end
	
	function game.ReplicatedStorage.GetSyncData.OnServerInvoke(Player,DataName)
		return Sync.Data[DataName];
	end
	
	function game.ReplicatedStorage.GetSyncDataServer.OnInvoke(DataName)
		return Sync.Data[DataName];
	end
end

return module
