local LogService = game:GetService("LogService")
local ServerLog = {};

local Admins = {
	[840691484] = "selvius13";
};

script.RequestServerOutput.Parent = game.ReplicatedStorage;
script.ServerMessageOut.Parent = game.ReplicatedStorage;

LogService.MessageOut:connect(function(Text,Type)
	
	table.insert(ServerLog,{Text=Text,Type=Type,Time=os.time()});
	
	for _,Player in pairs(game.Players:GetPlayers()) do
		if Admins[Player.userId] or Player.Name == "Player1" then
			game.ReplicatedStorage.ServerMessageOut:FireClient(Player,Text,Type,os.time());
		end;
	end;
	
end)

function game.ReplicatedStorage.RequestServerOutput.OnServerInvoke()
	return ServerLog;
end

game.Players.PlayerAdded:connect(function(Player)
	if Admins[Player.userId] or Player.Name == "Player1" then
		local NewScript = script.Console:Clone();
		NewScript.Disabled = false;
		NewScript.Parent = Player.PlayerGui;
	end
end);