local MainGUI = script.Parent.MainGUI;
local CrateSelect = MainGUI.Container.CrateSelect.Container;
local CrateFinished = MainGUI.Container.CrateFinished;
local ClientEvents = game.ReplicatedStorage.ClientEvents;
local HTTP = ClientEvents.HTTP;

local SyncedData = {};
function GetSyncData(DataName) 
	if SyncedData[DataName] == nil then
		SyncedData[DataName] = game.ReplicatedStorage.ClientEvents.GetSyncData:InvokeServer(DataName);
	end
	return SyncedData[DataName];
end
game.ReplicatedStorage.ClientEvents.UpdateSyncedData.OnClientEvent:connect(function(DataName,Data)
	SyncedData[DataName] = Data;
end)

local Items = GetSyncData("Items");
local RarityColor = GetSyncData("Rarity");

math.randomseed(tick());

function CrateOpen(CrateName,RewardItem)
	CrateSelect:ClearAllChildren();
	local Contents = Items[CrateName]["Contents"];
	local Destination = 20;
	RewardItem = Items[RewardItem];
	for i = 1,Destination+3 do
		local RarityRoll = math.random();
		local Rarity;
		if (RarityRoll <= 0.0044) then
			Rarity = "Ancient";
		elseif (RarityRoll <= 0.0143) then
			Rarity = "Legendary";
		elseif (RarityRoll <= 0.0425) then
			Rarity = "Epic";
		elseif (RarityRoll <= 0.2121) then
			Rarity = "Rare";
		else
			Rarity = "Uncommon";
		end;
		local ItemTable = {
			["Uncommon"] = {};
			["Rare"] = {};
			["Epic"] = {};
			["Legendary"] = {};
			["Ancient"] = {Items[CrateName]["Ancient"]};
		};
		for _,ItemName in pairs(Contents) do
			table.insert(ItemTable[Items[ItemName]["Rarity"]],ItemName);
		end
		
		local Item = Items[ItemTable[Rarity][math.random(1,#ItemTable[Rarity])]];
		
		if i == Destination then
			Item = RewardItem;
			Rarity = Item["Rarity"];
		end
		
		local NewFrame = script.Content:Clone();
		NewFrame.Position = UDim2.new(0,150*i,0,1);
		NewFrame.ItemName.Text = Item["ItemName"];
		NewFrame.ItemName.TextColor3 = RarityColor[Rarity];
		NewFrame.BorderColor3 = RarityColor[Rarity];
		NewFrame.ItemImage.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=".. Item["ItemID"];
		NewFrame.Parent = CrateSelect;
	end	 
	
	script.Parent.ViewFrame:Fire("CrateSelect");	
	
	CrateSelect.Parent.Visible = true;
	
	local CurrentX = 0;
	local FinishX = (Destination-1)*150;
	local Speed = 20;
	local OffsetX = math.random(-75,75);
	FinishX = FinishX + OffsetX;
	local SlowdownPoint = FinishX - 300;
	local LastFrame = 0;

	wait(1);	
	
	while CurrentX < FinishX do
		local Start = CurrentX - SlowdownPoint
		local End = FinishX - SlowdownPoint - 75;
		if CurrentX >= SlowdownPoint then
			local Multiplier = Start/End;
			Speed = 20 * (1 - Multiplier);
			if Speed < 1 then
				Speed = 1;
			end
		end
		for _,Frame in pairs(CrateSelect:GetChildren()) do
			Frame.Position = UDim2.new(0,Frame.Position.X.Offset - Speed,0,1);
		end
		CurrentX = CurrentX + Speed;
		wait();
	end
	wait(1.25);
	CrateFinished.Item.ItemName.Text = RewardItem["ItemName"];
	CrateFinished.Item.ItemName.TextColor3 = RarityColor[RewardItem["Rarity"]];
	CrateFinished.Item.ItemImage.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=".. RewardItem["ItemID"];
	script.Parent.ViewFrame:Fire("CrateFinished");
	_G.UpdateInventory()
end

ClientEvents.OpenCrate.OnClientEvent:connect(CrateOpen);





