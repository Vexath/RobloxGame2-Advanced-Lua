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

local RarityValue = {
	["Classic"] = 1;
	["Common"] = 2;
	["Uncommon"] = 3; 
	["Rare"] = 4;
	["Legendary"] = 5;
	["Godly"] = 6;
	["Victim"] = 7;
	["Ancient"] = 6.5;
	["Christmas"] = 1.6;
	["Halloween"] = 1.5;
};

local InventoryFrame = MainGUI.ViewInventory.Items.Container;
function UpdateInventory(Target,InvOverride)
	local SyncItems = GetSyncData("Item");
	InventoryFrame:ClearAllChildren();
	
	local InventoryTable 
	if not InvOverride then
		InventoryTable = game.ReplicatedStorage.GetData:InvokeServer("Weapons",Target).Owned;
	else
		InventoryTable = InvOverride;
	end;
	local Inventory = {};
	--must return true if the first argument should come first
	for ItemName,Amount in pairs(InventoryTable) do 
		table.insert(Inventory,{
			["ItemName"] = ItemName;
			["Amount"] = Amount;
		})
	end
	
	table.sort(Inventory,function(Item1,Item2)
		if Item1["ItemName"] == "DefaultPillow" then
			return true;
		elseif Item2["ItemName"] == "DefaultPillow" then
			return false;
		end;
		
		if RarityValue[SyncItems[Item1["ItemName"]]["Rarity"]] ~= RarityValue[SyncItems[Item2["ItemName"]]["Rarity"]] then
			return (RarityValue[SyncItems[Item1["ItemName"]]["Rarity"]] > RarityValue[SyncItems[Item2["ItemName"]]["Rarity"]]);
		else
			return (Item1["Amount"] > Item2["Amount"]);
		end
	end)
	
	local ItemCount = 0;
	for _,iData in pairs(Inventory) do
		local ItemName = iData["ItemName"];
		local Amount = iData["Amount"];
		ItemCount = ItemCount+1;
		local CurrentItemData = GetSyncData("Item")[ItemName];

		local Row = math.floor((ItemCount-1)/5);
		local Column = (ItemCount-1)%5
		local NewSlot = script.Slot:Clone();
		NewSlot.Position = UDim2.new(0,(93*Column)+5,0,(93*Row)+5);
		NewSlot.Parent = InventoryFrame;

		NewSlot.Image = CurrentItemData["Image"];
		NewSlot.ItemName.Text = GetSyncData("Item")[ItemName]["ItemName"];
		NewSlot.ItemName.TextColor3 = GetSyncData("Rarity")[CurrentItemData["Rarity"]];
		if Amount > 1 then
			NewSlot.Amount.Text = "x" .. Amount;
		end	
	end
	MainGUI.ViewInventory.Visible = true;
end

game:GetService("UserInputService").InputBegan:connect(function(Input)
	local B = Input.KeyCode;
	if B == Enum.KeyCode.DPadLeft and MainGUI.PlayerMenu.Visible then
		UpdateInventory(_G.MenuPlayer);
	elseif B == Enum.KeyCode.ButtonB then
		MainGUI.ViewInventory.Visible = false;
		game:GetService("GuiService").SelectedObject = nil;
	end;
end)

MainGUI.PlayerMenu.Inventory.MouseButton1Click:connect(function()
	UpdateInventory(_G.MenuPlayer);
end)

game.ReplicatedStorage.Admin.OnClientEvent:connect(function(Func,Arg)
	if Func == "CheckInventory" then
		UpdateInventory(nil,Arg);
	end
end)

MainGUI.ViewInventory.Close.MouseButton1Click:connect(function()
	MainGUI.ViewInventory.Visible = false;
end)







