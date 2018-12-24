--local CompletedTutorial = (_G.PlayerData.SantaTutorial==true);
local SantaGUI = script.Parent.Parent.Game.Santa;
local Remote = game.ReplicatedStorage;

--if not _G.TutorialGUI then
	_G.TutorialGUI = true;
--end

SantaGUI.Shop.Visible = (_G.TutorialGUI);
SantaGUI.Tutorial.Visible = (not _G.TutorialGUI);

local Database = {
	
	Weapons 	= Remote.GetSyncData:InvokeServer("Item");
	Materials 	= Remote.GetSyncData:InvokeServer("Materials");
	Effects 	= Remote.GetSyncData:InvokeServer("Effects");
	Accessories		= Remote.GetSyncData:InvokeServer("Accessories");
	Toys		= Remote.GetSyncData:InvokeServer("Toys");
	Pets 		= Remote.GetSyncData:InvokeServer("Pets");
	
};
local RarityColors = Remote.GetSyncData:InvokeServer("Rarity");
local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";

local ChristmasShop = Remote.GetSyncData:InvokeServer("ChristmasShop");

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


local function OpenShop()
	script.Parent.Parent.Game.Santa.Visible = true;
end

SantaGUI.Tutorial.ViewShop.MouseButton1Click:connect(function()
	SantaGUI.Tutorial.Visible = false;
	SantaGUI.Shop.Visible = true;
end)

SantaGUI.Shop.Help.MouseButton1Click:connect(function()
	SantaGUI.Tutorial.Visible = true;
	SantaGUI.Shop.Visible = false;
end)

--[[
local function MakeShopDialog()
	local Dialog = script.Shop:Clone();
	local HeyMessage = math.random(1,3);
	if HeyMessage == 1 then
		Dialog.InitialPrompt = "Hey " .. game.Players.LocalPlayer.Name .. ", how's the gift collecting going?";
	elseif HeyMessage == 2 then		
		Dialog.InitialPrompt = "Hello " .. game.Players.LocalPlayer.Name .. "! Got some more gifts for me?";
	else
		Dialog.InitialPrompt = "What's up " .. game.Players.LocalPlayer.Name .. "? Got some tokens to spend?";
	end;
	Dialog.Parent = game.Workspace.Lobby.Santa.Head;
	Dialog.DialogChoiceSelected:connect(function(Player,Choice)
		if Choice.Name == "SeeShop" then
			OpenShop();
			Dialog.InUse = false;
		elseif Choice.Name == "zCancel" then
			Dialog.InUse = false;
		end;
	end)
end

if not CompletedTutorial then
	local Dialog = script.Tutorial:Clone();
	Dialog.InitialPrompt = "Hey " .. game.Players.LocalPlayer.Name .. ", I need your help!";
	Dialog.Parent = game.Workspace.Lobby.Santa.Head;
	
	Dialog.DialogChoiceSelected:connect(function(Player,Choice)
		if Choice.Name == "SeeShop" then
			CompletedTutorial = true;
			Dialog:Destroy();
			MakeShopDialog();
			OpenShop();
			_G.PlayerData.SantaTutorial = true;
			game.ReplicatedStorage.ChristmasEvents.CompleteTutorial:FireServer();
		elseif Choice.Name == "zCancel" then
			Dialog.InUse = false;
		end;
	end)
else
	MakeShopDialog();
end;
]]

local ChristmasInventory = {};
local function SortChristmasInventory()
	ChristmasInventory = {};
	
	for ItemID,Amount in pairs(_G.PlayerData.Materials.Owned) do
		if Database.Materials[ItemID].Christmas then
			table.insert(ChristmasInventory,{ItemID=ItemID;Amount=Amount;});
		end
	end

	table.sort(ChristmasInventory,function(A,B)
		return A.ItemID < B.ItemID;
	end)	
end

local CurrentExchange = "";

local function UpdateExchange()
	local StillHasItem = (_G.PlayerData.Materials.Owned[CurrentExchange] and _G.PlayerData.Materials.Owned[CurrentExchange] > 0)
	CurrentExchange = (StillHasItem and CurrentExchange) or "";
	if CurrentExchange=="" then CurrentExchange=nil;end;
	
	SantaGUI.Shop.Exchange.Container.ItemIcon.Image = (CurrentExchange and GetImage(Database.Materials[CurrentExchange].Image)) or "";
	SantaGUI.Shop.Exchange.Container.RewardIcon.Image = (CurrentExchange and "rbxassetid://585005752") or "";
	SantaGUI.Shop.Exchange.Container.RewardIcon.Amount.Text = (CurrentExchange and "x".. Database.Materials[CurrentExchange].TokenValue) or "";
	
	SantaGUI.Shop.Exchange.Container.Trade.Style = (CurrentExchange and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
end

SantaGUI.Shop.Exchange.Container.Trade.MouseButton1Click:connect(function()
	if CurrentExchange then
		
		_G.PlayerData.Materials.Owned[CurrentExchange] = _G.PlayerData.Materials.Owned[CurrentExchange]-1;
		if _G.PlayerData.Materials.Owned[CurrentExchange]<1 then _G.PlayerData.Materials.Owned[CurrentExchange]=nil; end;
		
		_G.PlayerData.Materials.Owned.BlueTokens = (_G.PlayerData.Materials.Owned.BlueTokens and _G.PlayerData.Materials.Owned.BlueTokens + Database.Materials[CurrentExchange].TokenValue) or Database.Materials[CurrentExchange].TokenValue;
		
		
		local Exchange = CurrentExchange;
		CurrentExchange=nil;
		game.ReplicatedStorage.ChristmasEvents.ExchangeGift:FireServer(Exchange);
		--game.ReplicatedStorage.UpdateDataClient:Fire();
		
	end
end)



local function UpdateChristmasInventory()
	
	local ScrollFrame = SantaGUI.Shop.Inventory.Container.Container.ScrollFrame;
	local i = 0;
	local Container = ScrollFrame.Container;
	local Size = 0.25;
	SortChristmasInventory()
	
	local Frames = {};

	Container:ClearAllChildren();
	local function CreateFrame(Index,Value)
		local Row = math.floor(i/(1/Size)); local Column = i%(1/Size);
		local NewFrame = script.Item:Clone();
		local ItemData = Database.Weapons[Value.ItemID] or Database.Materials[Value.ItemID];
		NewFrame.Container.Icon.Image = GetImage(ItemData.Image);
		NewFrame.Container.Amount.Text = "x"..Value.Amount;
		NewFrame.Parent = Container;
		NewFrame.Size = UDim2.new(Size,0,Size,0);
		NewFrame.Position = UDim2.new(NewFrame.Size.X.Scale*Column,0,0,NewFrame.AbsoluteSize.Y*Row);
		NewFrame.Name = Value.ItemID;
		ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
		NewFrame.Container.Button.MouseButton1Click:connect(function()
			if ItemData.TokenValue then
				CurrentExchange = ( CurrentExchange==Value.ItemID and "" ) or Value.ItemID;
				UpdateExchange();
			end
		end)
		NewFrame.Container.MouseEnter:connect(function()
			SantaGUI.Description.LastFrame.Value = NewFrame;
			SantaGUI.Description.Title.Text =  ItemData.Rarity .. " " .. ItemData.Name .. (  (ItemData.ChristmasDescription and (" - " .. ItemData.ChristmasDescription)) or "");
			SantaGUI.Description.RarityColor.BackgroundColor3 = RarityColors[ItemData.Rarity];
			SantaGUI.Description.Visible = true;
		end)
		NewFrame.Container.MouseLeave:connect(function()
			if SantaGUI.Description.LastFrame.Value ~= NewFrame then return end;
			SantaGUI.Description.Visible = false;
		end)
		table.insert(Frames,NewFrame);
		i = i + 1;
	end
	
	for Index,Value in pairs(ChristmasInventory) do
		CreateFrame(Index,Value);
	end

	--[[require(script.EnterLeave)("ChristmasInventory",Frames,function(Frame)
		local ItemData = Database.Weapons[Frame.Name] or Database.Materials[Frame.Name];
		SantaGUI.Description.Title.Text =  ItemData.Rarity .. " " .. ItemData.Name .. (  (ItemData.ChristmasDescription and (" - " .. ItemData.ChristmasDescription)) or "");
		SantaGUI.Description.RarityColor.BackgroundColor3 = RarityColors[ItemData.Rarity];
		SantaGUI.Description.Visible = true;
	end,
	function()
		SantaGUI.Description.Visible = false;
	end,SantaGUI)]]
end


function UpdateShop()
	local ScrollFrame = SantaGUI.Shop.Shop.Container.Container.ScrollFrame;
	local i = 0;
	local Container = ScrollFrame.Container;
	local Size = 0.5;
	local Frames = {};

	Container:ClearAllChildren();
	local function CreateFrame(Index,Value)
		local Row = math.floor(i/(1/Size)); local Column = i%(1/Size);
		local NewFrame = script.ShopItem:Clone();

		local RewardData = Database[Value.RewardType][Value.RewardID];
		local CostData = Database.Weapons[Value.CostID] or Database.Materials[Value.CostID];
		
		NewFrame.Container.RewardIcon.Image = GetImage(RewardData.Image);
		NewFrame.Container.CostIcon.Image = (CostData and GetImage(CostData.Image)) or "https://www.roblox.com/asset/?id=377010926";
		NewFrame.Container.CostText.Text = "x" .. Value.Cost;
		local ShopData = Value;
		
		local Purchased;
		
		for _,rID in pairs(_G.PlayerData[ShopData.RewardType].Owned) do
			if rID == Value.RewardID then
				Purchased = true;
				NewFrame.Container.Purchased.Visible = true;
			end
		end
		
		NewFrame.Container.Buy.MouseButton1Click:connect(function()
			if not Purchased then
				local Currency = ShopData.CostID;
				local Amount = (ShopData.CostID == "Gems" and _G.PlayerData.Gems) or _G.PlayerData[ShopData.CostType].Owned[ShopData.CostID];
				if Amount and Amount >= ShopData.Cost then
					
					if ShopData.RewardType == "Weapons" or ShopData.RewardType == "Pets" or ShopData.RewardType == "Materials" then
						local OwnedWeapons = _G.PlayerData[ShopData.RewardType].Owned;
						_G.PlayerData[ShopData.RewardType].Owned[ShopData.RewardID] = (OwnedWeapons[ShopData.RewardID] and OwnedWeapons[ShopData.RewardID]+ShopData.RewardAmount) or ShopData.RewardAmount;
					else
						Purchased = true;
						table.insert(_G.PlayerData[ShopData.RewardType].Owned,ShopData.RewardID);
						NewFrame.Container.Purchased.Visible = true;
						NewFrame.Container.Buy.Visible = false;
					end;
					
					if ShopData.CostID == "Gems" then
						_G.PlayerData[Currency] = _G.PlayerData[Currency] - ShopData.Cost;
					else
						_G.PlayerData[ShopData.CostType].Owned[ShopData.CostID] = (_G.PlayerData[ShopData.CostType].Owned[ShopData.CostID] and _G.PlayerData[ShopData.CostType].Owned[ShopData.CostID] - ShopData.Cost) or 0;
						if _G.PlayerData[ShopData.CostType].Owned[ShopData.CostID] < 1 then
							_G.PlayerData[ShopData.CostType].Owned[ShopData.CostID] = nil;
						end
					end;
					game.ReplicatedStorage.ChristmasEvents.ChristmasBuy:FireServer(Index);
					--game.ReplicatedStorage.UpdateDataClient:Fire();
				end;
			end;
		end)
		
		NewFrame.Container.Title.Text = Value.Name;
		
		NewFrame.Container.MouseEnter:connect(function()
			if not Purchased then
				NewFrame.Container.Buy.Visible = true;
			end;
			SantaGUI.Description.LastFrame.Value = NewFrame;
			SantaGUI.Description.Title.Text =  (RewardData.Rarity or "(Limited)") .. " " .. (RewardData.Name or RewardData.ItemName) .. (  (RewardData.ChristmasDescription and (" - " .. RewardData.ChristmasDescription)) or "");
			SantaGUI.Description.RarityColor.BackgroundColor3 = (RewardData.Rarity and RarityColors[RewardData.Rarity]) or Color3.new(1,1,1);
			SantaGUI.Description.Visible = true;
		end)
		
		NewFrame.Container.MouseLeave:connect(function()
			if not Purchased then
				NewFrame.Container.Buy.Visible = false;
			end;
			if SantaGUI.Description.LastFrame.Value ~= NewFrame then return end;
			SantaGUI.Description.Visible = false;
		end)
		
		NewFrame.Parent = Container;
		NewFrame.Size = UDim2.new(Size,0,0,75);
		NewFrame.Position = UDim2.new(NewFrame.Size.X.Scale*Column,0,0,NewFrame.AbsoluteSize.Y*Row);
		NewFrame.Name = Value.RewardID;
		ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
		table.insert(Frames,NewFrame);
		i = i + 1;
	end	
	
	for Index,Value in pairs(ChristmasShop) do
		CreateFrame(Index,Value);
	end
	
	--[[require(script.EnterLeave)("ChristmasShop",Frames,function(Frame)
		Frame.Container.Buy.Visible = true;
		local ItemData = Database.Weapons[Frame.Name] or Database.Materials[Frame.Name];
		SantaGUI.Description.Title.Text =  ItemData.Rarity .. " " .. ItemData.Name .. (  (ItemData.ChristmasDescription and (" - " .. ItemData.ChristmasDescription)) or "");
		SantaGUI.Description.RarityColor.BackgroundColor3 = RarityColors[ItemData.Rarity];
		SantaGUI.Description.Visible = true;
	end,
	function(Frame)
		Frame.Container.Buy.Visible = false;
		SantaGUI.Description.Visible = false;
	end,SantaGUI)]]
	
end

local function UpdateTokens()
	SantaGUI.Shop.Tokens.Frame.GemsText.Text = "x".. _G.PlayerData.Gems;
	
	local BlueTokens = _G.PlayerData.Materials.Owned.BlueTokens or 0;
	local RedTokens = _G.PlayerData.Materials.Owned.RedTokens or 0;
	SantaGUI.Shop.Tokens.Frame.BlueTokenText.Text =  "x" .. BlueTokens;
	SantaGUI.Shop.Tokens.Frame.RedTokenText.Text =  "x" .. RedTokens;
end


local function Update()
	UpdateChristmasInventory();
	UpdateTokens()
	UpdateShop();
	UpdateExchange()
end

game.ReplicatedStorage.UpdateDataClient.Event:connect(function()
	Update();
end)

Update();


local CanTouch = true;
game.Workspace.SantaBrick.Touched:connect(function(Part)
	if Part ~= game.Players.LocalPlayer.Character.Torso then return end;
	if CanTouch and SantaGUI.Parent.Inventory.Visible == false and SantaGUI.Parent.Crafting.Visible == false  and SantaGUI.Parent.Shop.Visible == false then
		CanTouch = false;
		SantaGUI.Visible = true;
	end
end)

game.Workspace.SantaBrick.SantaExit.TouchEnded:connect(function(Part)
	if Part ~= game.Players.LocalPlayer.Character.Torso then return end;
	CanTouch = true;
	SantaGUI.Visible = false;
end)

SantaGUI.Close.MouseButton1Click:connect(function()
	SantaGUI.Visible = false;
end)




