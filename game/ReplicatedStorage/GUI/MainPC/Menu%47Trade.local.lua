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

local ItemData = GetSyncData("Item");
local PetData = GetSyncData("Pets");
local Rarity = GetSyncData("Rarity");

local Database = {
	Weapons = ItemData;
	Pets = PetData;
};

local function PrintTable(Table,Indent)
	local IndentString = "";
	for i = 1,Indent do
		IndentString = IndentString .. "--";
	end
	for Index,Value in pairs(Table) do
		if type(Value) == "table" then
			print(IndentString .. Index .. "{");
			PrintTable(Value,Indent+1);
		else
			print(IndentString .. Index .. ": " .. tostring(Value))
		end;
	end
end

local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";
local function GetImage(Image) 
	local Return;
	if _G.Cache[Image] ~= nil then 
		return _G.Cache[Image];
	else
		local NewImage = (tonumber(Image) and AssetURL..Image) or Image; 
		NewImage = NewImage .. "&bust="..math.random(1,10000); 
		_G.Cache[Image] = NewImage;
		return NewImage; 
	end;
end;
----------------------------------------------------------------------

local MainGUI = script.Parent.Game;
local TradeEvents = game.ReplicatedStorage.Trade;
local RequestFrame = MainGUI.TradeRequest;
local TradeGUI = MainGUI.Trade;

local function GetTradePlayers(Trade)
	if Trade["Player1"]["Player"] == game.Players.LocalPlayer then
		return "Player1","Player2";
	elseif Trade["Player2"]["Player"] == game.Players.LocalPlayer then
		return "Player2","Player1";
	end;
end
----------------------------

local function ShowRequest(Player2Name,IsSending)
	if not IsSending then
		RequestFrame.Accepting.Visible = false;
		RequestFrame.Sending.Visible = true;
		RequestFrame.Sending.Title.Text = "Waiting for " .. Player2Name .. " to accept your trade request..."
	else
		RequestFrame.Accepting.Visible = true;
		RequestFrame.Sending.Visible = false;
		RequestFrame.Accepting.Title.Text = Player2Name .. " has sent you a trade request."
	end;
	RequestFrame.Visible = true;
end

local Connections = {};
local CooldownRunning = false;
local Cooldown = 6;
function ResetCooldown()
	MainGUI.Trade.Offers.TradeAccepted.Visible = false;
	Cooldown = 6;
	MainGUI.Trade.Offers.Accept.Cooldown.Text = "(" .. Cooldown .. ")";
	if not CooldownRunning then
		MainGUI.Trade.Offers.Accept.Cooldown.Visible = true;
		CooldownRunning = true;
		repeat 
			wait(1)
			Cooldown = Cooldown - 1;
			MainGUI.Trade.Offers.Accept.Cooldown.Text = "(" .. Cooldown .. ")";
		until Cooldown <= 0;
		CooldownRunning = false;
		MainGUI.Trade.Offers.Accept.Cooldown.Visible = false;
	else
		Cooldown = 6;
	end
end



local function UpdateTrade(Trade)
	
	RequestFrame.Visible = false;	
	TradeGUI.Offers.TradeAccepted.Visible = false;
	TradeGUI.Offers.Waiting.Visible = false;

	for _,Frame in pairs(TradeGUI.Offers.Offer1:GetChildren()) do 	Frame.Image = ""; Frame.ItemName.Text = ""; Frame.Amount.Text = ""; end
	for _,Frame in pairs(TradeGUI.Offers.Offer2:GetChildren()) do 	Frame.Image = ""; Frame.ItemName.Text = ""; Frame.Amount.Text = ""; end	
	for _,Con in pairs(Connections) do Con:disconnect() end;
		
	
	if Trade then
		TradeGUI.Visible = true;
		local MyPlayer,TheirPlayer = GetTradePlayers(Trade);
		local MyOffers = Trade[MyPlayer]["Offer"];
		local TheirOffers = Trade[TheirPlayer]["Offer"];
		
		for i,OfferTable in pairs(MyOffers) do
			local DB = Database[OfferTable[3]];
			TradeGUI.Offers.Offer1["Slot" .. i].Image = GetImage( DB[OfferTable[1]]["Image"] );
			TradeGUI.Offers.Offer1["Slot" .. i].ItemName.Text = DB[OfferTable[1]]["ItemName"] or DB[OfferTable[1]]["Name"];
			TradeGUI.Offers.Offer1["Slot" .. i].ItemName.TextColor3 = Rarity[DB[OfferTable[1]]["Rarity"]];
			TradeGUI.Offers.Offer1["Slot" .. i].Amount.Text = "x" .. OfferTable[2];
			table.insert(Connections,TradeGUI.Offers.Offer1["Slot" .. i].MouseButton1Click:connect(function()
				TradeEvents.RemoveOffer:FireServer(OfferTable[1],OfferTable[3]);
			end));
		end
		
		for i,OfferTable in pairs(TheirOffers) do
			local DB = Database[OfferTable[3]];
			TradeGUI.Offers.Offer2["Slot" .. i].Image = GetImage(DB[OfferTable[1]]["Image"]);
			TradeGUI.Offers.Offer2["Slot" .. i].ItemName.Text = DB[OfferTable[1]]["ItemName"] or DB[OfferTable[1]]["Name"];
			TradeGUI.Offers.Offer2["Slot" .. i].ItemName.TextColor3 = Rarity[DB[OfferTable[1]]["Rarity"]];
			TradeGUI.Offers.Offer2["Slot" .. i].Amount.Text = "x" .. OfferTable[2];
		end
		
		spawn(ResetCooldown);
	else
		TradeGUI.Visible = true;
		UpdateInventory();
	end;
end

TradeEvents.DeclineTrade.OnClientEvent:connect(function()
	TradeGUI.Visible = false;
end)

RequestFrame.Accepting.Accept.MouseButton1Click:connect(function()
	TradeEvents.AcceptRequest:FireServer();
end)

RequestFrame.Accepting.Decline.MouseButton1Click:connect(function()
	TradeEvents.DeclineRequest:FireServer();
	RequestFrame.Visible = false;
end)

TradeEvents.DeclineRequest.OnClientEvent:connect(function()
	RequestFrame.Visible = false;
end)

RequestFrame.Sending.Cancel.MouseButton1Click:connect(function()
	TradeEvents.CancelRequest:FireServer();
	RequestFrame.Visible = false;
end)

TradeEvents.CancelRequest.OnClientEvent:connect(function()
	RequestFrame.Visible = false;
end)


game:GetService("UserInputService").InputBegan:connect(function(Input)
	local B = Input.KeyCode;
	if B == Enum.KeyCode.DPadRight and MainGUI.PlayerMenu.Visible then
		if _G.MenuPlayer ~= game.Players.LocalPlayer then
			local IsBusy = TradeEvents.SendRequest:InvokeServer(_G.MenuPlayer);
			if not IsBusy then
				ShowRequest(_G.MenuPlayer.Name,false);
			end
		end;
	end
end)

function game.ReplicatedStorage.CheckClient.OnClientInvoke()
	return 5;
end;

MainGUI.PlayerMenu.Trade.MouseButton1Click:connect(function()
	if _G.MenuPlayer ~= game.Players.LocalPlayer then
		local IsBusy = TradeEvents.SendRequest:InvokeServer(_G.MenuPlayer);
		if not IsBusy then
			ShowRequest(_G.MenuPlayer.Name,false);
		end
	end;
end)

function TradeEvents.SendRequest.OnClientInvoke(Player1)
	if _G.RequestsEnabled then
		ShowRequest(Player1.Name,true);
	end;
	return _G.RequestsEnabled;
end;

TradeEvents.UpdateTrade.OnClientEvent:connect(UpdateTrade);

TradeEvents.StartTrade.OnClientEvent:connect(function()
	UpdateTrade();
end)

TradeEvents.AcceptTrade.OnClientEvent:connect(function(TradeComplete)
	if TradeComplete then
		TradeGUI.Visible = false;
	else
		TradeGUI.Offers.TradeAccepted.Visible = true;
	end;
end)

TradeGUI.Offers.Decline.MouseButton1Click:connect(function()
	TradeEvents.DeclineTrade:FireServer();
end)


local LastAccept = time();
TradeGUI.Offers.Accept.MouseButton1Click:connect(function()
	if CooldownRunning == false and time()-LastAccept >=1 and not TradeGUI.Offers.Accept.Cooldown.Visible then
		LastAccept = time();
		TradeGUI.Offers.Waiting.Visible = true;
		TradeEvents.AcceptTrade:FireServer();
	end;
end)


local TradeStatus,Data = game.ReplicatedStorage.GetTradeStatus:InvokeServer();
if TradeStatus == "StartTrade" then
	UpdateTrade(Data);
elseif TradeStatus == "ShowRequest" then
	ShowRequest(Data,false);
elseif TradeStatus == "SendRequest" then
	ShowRequest(Data,true)
end




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

local InventoryFrame = TradeGUI.Items;
local PetsFrame = TradeGUI.PetsFrame;

function UpdateInventory()
	local SyncItems = GetSyncData("Item");
	local Pets = GetSyncData("Pets");
	
	InventoryFrame:ClearAllChildren();
	PetsFrame:ClearAllChildren();
	
	local InventoryTable = _G.PlayerData.Weapons;
	local Inventory = {};
	
	local PetTable = _G.PlayerData.Pets;
	local PetInventory = {};
	
	for ItemName,Amount in pairs(InventoryTable.Owned) do 
		table.insert(Inventory,{
			["ItemName"] = ItemName;
			["Amount"] = Amount;
		})
	end
	
	for ItemName,Amount in pairs(PetTable.Owned) do 
		table.insert(PetInventory,{
			["ItemName"] = ItemName;
			["Amount"] = Amount;
		})
	end
	
	table.sort(PetInventory,function(Item1,Item2)
		if RarityValue[Pets[Item1["ItemName"]]["Rarity"]] ~= RarityValue[Pets[Item2["ItemName"]]["Rarity"]] then
			return (RarityValue[Pets[Item1["ItemName"]]["Rarity"]] > RarityValue[Pets[Item2["ItemName"]]["Rarity"]]);
		else
			return (Item1["Amount"] > Item2["Amount"]);
		end
	end)
	
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
		NewSlot.Parent = TradeGUI.Items
		NewSlot.Image = CurrentItemData["Image"];
		NewSlot.ItemName.Text = GetSyncData("Item")[ItemName]["ItemName"];
		NewSlot.ItemName.TextColor3 = GetSyncData("Rarity")[CurrentItemData["Rarity"]];
		
		if Amount > 1 then
			NewSlot.Amount.Text = "x" .. Amount;
		end	
	
		NewSlot.MouseButton1Click:connect(function()
			TradeEvents.OfferItem:FireServer(ItemName,"Weapons");
		end)
	end
	
	local ItemCount = 0;
	for _,iData in pairs(PetInventory) do
		local ItemName = iData["ItemName"];
		local Amount = iData["Amount"];
		ItemCount = ItemCount+1;
		local CurrentItemData = Pets[ItemName];

		local Row = math.floor((ItemCount-1)/5);
		local Column = (ItemCount-1)%5
		local NewSlot = script.Slot:Clone();
		NewSlot.Position = UDim2.new(0,(93*Column)+5,0,(93*Row)+5);
		NewSlot.Parent = PetsFrame;
		NewSlot.Image = GetImage(CurrentItemData["Image"]);
		NewSlot.ItemName.Text = Pets[ItemName].Name
		NewSlot.ItemName.TextColor3 = GetSyncData("Rarity")[CurrentItemData["Rarity"]];
		if Amount > 1 then
			NewSlot.Amount.Text = "x" .. Amount;
		end	
		NewSlot.MouseButton1Click:connect(function()
			TradeEvents.OfferItem:FireServer(ItemName,"Pets");
		end)
	end
	
end

local PetsButton = TradeGUI.Pets;
local WeaponsButton = TradeGUI.Weapons;

local RequestsFrame = MainGUI.Leaderboard.Requests
if _G.RequestsEnabled == nil then
	_G.RequestsEnabled = true;
end

RequestsFrame.On.Visible = _G.RequestsEnabled;
RequestsFrame.Off.Visible = (not _G.RequestsEnabled);

RequestsFrame.On.MouseButton1Click:connect(function()
	RequestsFrame.On.Visible = false;
	RequestsFrame.Off.Visible = true;
	_G.RequestsEnabled = false;
	TradeEvents.DeclineRequest:FireServer();
	RequestFrame.Visible = false;
end)
RequestsFrame.Off.MouseButton1Click:connect(function()
	RequestsFrame.On.Visible = true;
	RequestsFrame.Off.Visible = false;
	_G.RequestsEnabled = true;
	TradeEvents.DeclineRequest:FireServer();
	RequestFrame.Visible = false;
end)



PetsButton.MouseButton1Click:connect(function()
	PetsButton.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	WeaponsButton.Style = Enum.ButtonStyle.RobloxRoundButton;
	PetsFrame.Visible = true;
	InventoryFrame.Visible = false;
end)
WeaponsButton.MouseButton1Click:connect(function()
	WeaponsButton.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	PetsButton.Style = Enum.ButtonStyle.RobloxRoundButton;
	PetsFrame.Visible = false;
	InventoryFrame.Visible = true;
end)

UpdateInventory();







