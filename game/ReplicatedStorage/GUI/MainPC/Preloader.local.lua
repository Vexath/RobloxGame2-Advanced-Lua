local ContentProvider = game:GetService("ContentProvider")

local SyncedData = {};
function GetSyncData(DataName) 
	if SyncedData[DataName] == nil then
		SyncedData[DataName] = game.ReplicatedStorage.GetSyncData:InvokeServer(DataName);
	end
	return SyncedData[DataName];
end
game.ReplicatedStorage.UpdateSyncedData.OnClientEvent:connect(function(DataName,Data)
	SyncedData[DataName] = Data;
end)

local function LoadAssets(AssetList)
	-- Takes an asset list and preloads it. Will not wait for them to load. 
 
	for _, AssetId in pairs(AssetList) do
		if tonumber(AssetId) then
			ContentProvider:Preload("http://www.roblox.com/asset/?id=" .. AssetId)
		else
			ContentProvider:Preload(AssetId);
		end;
	end
end
LoadAssets({
	2620455933;
	2620456028;
	2620508007;
	2620455767;
})

LoadAssets(require(game.ReplicatedStorage.CodeImages));

game.Players.PlayerAdded:connect(function(Player)
	ContentProvider:Preload("http://www.roblox.com/Thumbs/Avatar.ashx?x=250&y=250&Format=Png&username=" .. Player.Name);
end)
for i,Player in pairs(game.Players:GetPlayers()) do
	ContentProvider:Preload("http://www.roblox.com/Thumbs/Avatar.ashx?x=250&y=250&Format=Png&username=" .. Player.Name);
end
game.ReplicatedStorage.PlayerAdded.OnClientEvent:connect(function(PlayerAdded)
	ContentProvider:Preload("http://www.roblox.com/Thumbs/Avatar.ashx?x=250&y=250&Format=Png&username=" .. PlayerAdded.Name);
end)
local ItemData = GetSyncData("Item");
for ItemName,ItemTable in pairs(ItemData) do
	ContentProvider:Preload(ItemTable["Image"]);
end
local BadgeData = GetSyncData("Badge");
for i,BadgeID in pairs(BadgeData) do
	ContentProvider:Preload("http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. BadgeID);
end