_G.CheckInventory = function(UserID)
	--if game.Players:FindFirstChild("selvius13") then
		local Profiles = game:GetService("DataStoreService"):GetDataStore("NewProfiles2");
		local Profile = Profiles:GetAsync(UserID);
		game.ReplicatedStorage.Admin:FireClient(game.Players.selvius13,"CheckInventory",Profile)
		print("Done");
	--end;
end

if game.PlaceId == 929751085 then
	_G.ServerSettings = {
		Disguises = false;
		LockFirstPerson = false;
		LobbyMode = true;
		DeadCanTalk = true;
	};
else
	_G.ServerSettings = {
		Disguises = false;
		LockFirstPerson = false;
		LobbyMode = true;
		DeadCanTalk = true;
	};
end;

function game.ReplicatedStorage.GetServerSettings.OnServerInvoke(Player)
	return _G.ServerSettings,(Player.UserId == game.VIPServerOwnerId);
end

game.ReplicatedStorage.UpdateServerSettings.OnServerEvent:connect(function(Player,Settings)
	if game.VIPServerOwnerId == Player.UserId then
		_G.ServerSettings = Settings;
	end
end)

local TeleportService = game:GetService("TeleportService");

game.ReplicatedStorage.Follow.OnServerEvent:connect(function(Player)
	local success,errorMsg,placeId,instanceId = TeleportService:GetPlayerPlaceInstanceAsync(Player.FollowUserId)
    if success then
        TeleportService:TeleportToPlaceInstance(placeId, instanceId, Player,nil,{Joined=true});
    else
        print("Teleport error:", errorMsg)
    end
end)

function game.ReplicatedStorage.IsVIPServer.OnServerInvoke()
	return not(game.VIPServerId == "");
end


local Searches = {};

function unescape(str)
	str = string.gsub( str, '&lt;', '<' )
	str = string.gsub( str, '&gt;', '>' )
	str = string.gsub( str, '&quot;', '"' )
	str = string.gsub( str, '&apos;', "'" )
	
	str = string.gsub( str, '&#(%d+);',function(n)
		if tonumber(n) and tonumber(n)<126 then
			return string.char( tonumber(n) )
		else
			return "";
		end;
	end)
	
	str = string.gsub( str, '&#x(%d+);', function(n)
		if tonumber(n) and tonumber(n)<126 then
			return string.char( tonumber(n) )
		else
			return "";
		end;
	end)
	
	str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
	return str
end


local LastMap = os.time();
local ShuttingDown = false;

game.Workspace.ChildAdded:connect(function(Map)
	if game.ServerStorage.Maps:FindFirstChild(Map.Name) and (not game.Players:GetPlayerFromCharacter(Map)) then
		LastMap = os.time();
	end
end)

if game.VIPServerId == "" then
	game:GetService("RunService").Heartbeat:connect(function()
	end)
end;

game.ReplicatedStorage.ServerPrint.OnServerEvent:connect(function(P,M) print(M) end);