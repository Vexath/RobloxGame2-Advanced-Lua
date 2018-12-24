local MainGUI = script.Parent.Game;
local LocalPlayer = game.Players.LocalPlayer;

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

function CreateSlots()
	local i = 1;
	for BadgeName,BadgeID in pairs(GetSyncData("Badge")) do
		local Info = game.MarketplaceService:GetProductInfo(BadgeID);
		local Row = math.floor((i-1)/5);
		local Column = (i-1)%5
		local NewSlot = script.Slot:Clone();
		NewSlot.Name = BadgeName;
		NewSlot.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. BadgeID;
		NewSlot.Position = UDim2.new(0,(100*Column),0,(100*Row));
		NewSlot.Parent = MainGUI.Badges.Items.Container;
		NewSlot.MouseEnter:connect(function()
			MainGUI.Badges.Description.Text = Info.Description;
		end)
		i = i + 1;
	end
end
CreateSlots();

function ShowBadges(Player)
	for i,BadgeItem in pairs(MainGUI.Badges.Items.Container:GetChildren()) do
		if game.MarketplaceService:PlayerOwnsAsset(Player,GetSyncData("Badge")[BadgeItem.Name]) then
			BadgeItem.ImageColor3 = Color3.new(1,1,1);
		else
			BadgeItem.ImageColor3 = Color3.new(0,0,0);
		end;
	end
	
	MainGUI.Badges.Visible = true;
end


MainGUI.Badges.Close.MouseButton1Click:connect(function()
	MainGUI.Badges.Visible = false;
end)
MainGUI.PlayerMenu.Badges.MouseButton1Click:connect(function()
	ShowBadges(_G.MenuPlayer);
end);

