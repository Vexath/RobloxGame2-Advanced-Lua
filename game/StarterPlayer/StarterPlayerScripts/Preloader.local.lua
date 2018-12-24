local ContentProvider = game:GetService("ContentProvider")
local PlayerImages = {};
local Resolution = 250;
local URL = "http://www.roblox.com/Thumbs/Avatar.ashx?x="..Resolution.."&y="..Resolution.."&Format=Png&userId=";
local URL2= "http://www.roblox.com/Thumbs/Avatar.ashx?x="..Resolution.."&y="..Resolution.."&Format=Png&username=";
local GetImageBindable = Instance.new("BindableFunction",game.ReplicatedStorage);
GetImageBindable.Name = "GetPlayerImage";


local function FindImage(PlayerIdentifier)
	for Index,Data in pairs(PlayerImages) do
		if Data.Name == PlayerIdentifier or Data.userId == tostring(PlayerIdentifier) then
			return Data.Image,Index;
		end
	end
	if tonumber(PlayerIdentifier) then
		return URL .. PlayerIdentifier,nil;
	else
		return URL2 .. PlayerIdentifier,nil;
	end;
end
GetImageBindable.OnInvoke = FindImage;

local function LoadPlayerImage(Player)
	if Player:IsA("Player") then
		local Raw = (Player.Name:find("Guest ") and URL .. "1" or Player.userId < 1 and URL .. "1" or URL .. Player.userId);
		ContentProvider:Preload(Raw);
		local Display = Raw .. "&bust="..math.floor(tick());
		table.insert(PlayerImages,{
			Name = Player.Name;
			userId = tostring(Player.userId);
			RawImage = Raw;
			Image = Display;
		});
	end;
end

game.Players.ChildAdded:connect(LoadPlayerImage);
game.Players.ChildRemoved:connect(function(Player)
	local _,Index = FindImage(Player.Name);
	if Index then table.remove(PlayerImages,Index) end;
end);
for _,Player in pairs(game.Players:GetPlayers()) do LoadPlayerImage(Player) end;

