local MainGUI = script.Parent.Game;

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

GetSyncData("Item");
GetSyncData("Recipe");


local Menu = MainGUI.Dock;
local InventoryFrame = MainGUI.Inventory.Items.Container;
local EquippedFrame =  MainGUI.Inventory.Equipped;
local Player = game.Players.LocalPlayer;
local State = "Equipping";
local function HideItems() end;



local Click = script:WaitForChild("Click");

local ItemNotifications = 0;
_G.GiveItem = function()
	ItemNotifications = ItemNotifications + 1;
	Menu.Inventory.Badge.Visible = true;
	Menu.Inventory.Badge.Amount.Text = ItemNotifications;
	Menu.Inventory.NotificationText.Visible = true;
end
--[[Menu.Play.MouseButton1Down:connect(function()
	Click:Play();
	Sidebar:TweenPosition(UDim2.new(0,-250,0,0),1,1,1,false,nil);
	wait(1);
	Sidebar.Open.Visible = true;
end)]]

local function OpenInventory()
	Click:Play();
	MainGUI.Inventory.Visible = not MainGUI.Inventory.Visible;
	
	MainGUI.Inventory.Background.Bags.Visible = false;
	
	MainGUI.Inventory.Items.Visible = false;
	MainGUI.Inventory.Loading.Visible = true;
	
	MainGUI.Shop.Visible = false;
	Menu.Inventory.Badge.Visible = false;
	Menu.Inventory.NotificationText.Visible = false;
	ItemNotifications = 0;
	
	UpdateInventory();
	HideItems();
end

local function OpenShop()
	Click:Play();
	MainGUI.Inventory.Visible = false;
	MainGUI.Shop.Visible = not MainGUI.Shop.Visible;
end

Menu.Shop.MouseButton1Down:connect(OpenShop);
Menu.Inventory.MouseButton1Down:connect(OpenInventory);

local function OpenItems()
	if MainGUI.Inventory.Loading.Visible == false then
		MainGUI.Inventory.Background.Bags.Visible = false;
		MainGUI.Inventory.Items.Visible = true;
		MainGUI.Inventory.Recipe.Visible = false;
		MainGUI.Inventory.Equipped.Visible = true;
		MainGUI.Inventory.Recycler.Visible = false;
		MainGUI.Inventory.NavBar.Items.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		--MainGUI.Inventory.NavBar.Bags.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Crafting.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Recycle.Style = Enum.ButtonStyle.RobloxRoundButton;
		State = "Equipping";
		HideItems();
	end;
end
MainGUI.Inventory.NavBar.Items.MouseButton1Click:connect(OpenItems)



local function OpenRecycler()
	if MainGUI.Inventory.Loading.Visible == false then
		--MainGUI.Inventory.NavBar.Bags.Style = Enum.ButtonStyle.RobloxRoundButton;
		--MainGUI.Inventory.Background.Bags.Visible = false;
		MainGUI.Inventory.Items.Visible = true;
		MainGUI.Inventory.Recipe.Visible = false;
		MainGUI.Inventory.Equipped.Visible = false;
		MainGUI.Inventory.Recycler.Visible = true;
		MainGUI.Inventory.NavBar.Items.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Recycle.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		MainGUI.Inventory.NavBar.Crafting.Style = Enum.ButtonStyle.RobloxRoundButton;
		State = "Recycling";
		HideItems();
	end;
end
MainGUI.Inventory.NavBar.Recycle.MouseButton1Click:connect(OpenRecycler)

--[[local function OpenBags()
	if MainGUI.Inventory.Loading.Visible == false then
		MainGUI.Inventory.Background.Bags.Visible = true;
		MainGUI.Inventory.Items.Visible = false;
		MainGUI.Inventory.Recipe.Visible = false;
		MainGUI.Inventory.Equipped.Visible = true;
		MainGUI.Inventory.NavBar.Items.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Bags.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		MainGUI.Inventory.NavBar.Crafting.Style = Enum.ButtonStyle.RobloxRoundButton;
	end;
end
MainGUI.Inventory.NavBar.Bags.MouseButton1Click:connect(OpenBags)]]


local RecipeTable = {
	["Recipe1"] = {ItemName = "",Amount = 0};
	["Recipe2"] = {ItemName = "",Amount = 0};
	["Recipe3"] = {ItemName = "",Amount = 0};
	["Recipe4"] = {ItemName = "",Amount = 0};
}

local RecipeFrame = MainGUI.Inventory.Recipe;

function FindInTable(Table,What)
	for _,Thing in pairs(Table) do
		if Thing == What then
			return true;
		end
	end
	return false;
end

game:GetService("UserInputService").InputBegan:connect(function(Input)
	local B = Input.KeyCode;
	if B == Enum.KeyCode.ButtonB or B == Enum.KeyCode.ButtonX or B == Enum.KeyCode.ButtonY then
		MainGUI.Recipes.Visible = false;
		game:GetService("GuiService").SelectedObject = nil;
	end;
end)

MainGUI.Recipes.Close.MouseButton1Click:connect(function()
	MainGUI.Recipes.Visible = false;
end)

local FoundRecipe;
function UpdateRecipe()
	local Inventory = game.ReplicatedStorage.GetData:InvokeServer("Inventory");
	for iRecipe,RecipeItemTable in pairs(RecipeTable) do
		local SelectedItem = RecipeItemTable.ItemName;
		if SelectedItem ~= "" then
			local RecipeItemData = GetSyncData("Item")[SelectedItem];
			RecipeFrame[iRecipe].Image = RecipeItemData["Image"];
			RecipeFrame[iRecipe].ItemName.Text = RecipeItemData["ItemName"]
			RecipeFrame[iRecipe].ItemName.TextColor3 = GetSyncData("Rarity")[RecipeItemData["Rarity"]];
			if SelectedItem == "Gift" then
				RecipeFrame[iRecipe].Amount.Text = "x" .. RecipeItemTable.Amount;
			else
				RecipeFrame[iRecipe].Amount.Text = "";
			end;
		else
			RecipeFrame[iRecipe].Amount.Text = "";
			RecipeFrame[iRecipe].Image = "";
			RecipeFrame[iRecipe].ItemName.Text = "";
		end
	end

	local IndexedRecipeTable = {}
	local GiftCount = 0;
	
	for _,ItemTable in pairs(RecipeTable) do
		local ItemIndex = ItemTable.ItemName;
		if ItemIndex ~= "" and ItemIndex ~= "Gift" then
			table.insert(IndexedRecipeTable,ItemIndex);
		elseif ItemIndex == "Gift" then
			GiftCount = ItemTable.Amount;
		end;
	end	
	
	FoundRecipe = nil;
	
	for ResultingItem,Recipe in pairs(GetSyncData("Recipe")) do
		local ComponentCount = 0;
		
		for _,Component in pairs(Recipe["Components"]) do
			if FindInTable(IndexedRecipeTable,Component) then
				ComponentCount = ComponentCount + 1;
			end
		end
		
		if ComponentCount == #Recipe["Components"] and #IndexedRecipeTable == #Recipe["Components"] then
			if Recipe.Gifts ~= nil then
				if GiftCount >= Recipe.Gifts then
					FoundRecipe = ResultingItem;
				end
			else
				FoundRecipe = ResultingItem;
			end;
		end
	end
	
	if FoundRecipe ~= nil then
		local ResultItemData = GetSyncData("Item")[FoundRecipe];
		RecipeFrame.ResultItem.Image = ResultItemData["Image"];
		RecipeFrame.ResultItem.ItemName.Text = ResultItemData["ItemName"]
		RecipeFrame.ResultItem.ItemName.TextColor3 = GetSyncData("Rarity")[ResultItemData["Rarity"]];
		RecipeFrame.Craft.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	else
		RecipeFrame.ResultItem.Image = "";
		RecipeFrame.ResultItem.ItemName.Text = "";
		RecipeFrame.Craft.Style = Enum.ButtonStyle.RobloxRoundButton;
	end
end

local CaseComplete = MainGUI.CaseComplete;

RecipeFrame.Craft.MouseButton1Click:connect(function()
	if FoundRecipe ~= nil then
		RecipeTable = {
			["Recipe1"] = {ItemName = "",Amount = 0};
			["Recipe2"] = {ItemName = "",Amount = 0};
			["Recipe3"] = {ItemName = "",Amount = 0};
			["Recipe4"] = {ItemName = "",Amount = 0};
		};
		game.ReplicatedStorage.Craft:FireServer(FoundRecipe);
		MainGUI.Inventory.Visible = false;
		if FoundRecipe ~= "RandLuger" then
			CaseComplete.ItemImage.Image = GetSyncData("Item")[FoundRecipe]["Image"]-- .. "&bust="..math.floor(tick());
			CaseComplete.ItemImage.ItemName.Text = GetSyncData("Item")[FoundRecipe]["ItemName"];
			CaseComplete.ItemImage.ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[FoundRecipe]["Rarity"]];
			local Con1;
			Con1 = CaseComplete.OK.MouseButton1Click:connect(function()
				Con1:disconnect();
				script.Click2:Play()
				CaseComplete.Visible = false;
			end)
			CaseComplete.Visible = true;
		end;
		_G.GiveItem();
		UpdateRecipe();
	end
end)

local function OpenCrafting()
	if MainGUI.Inventory.Loading.Visible == false then
		State = "Crafting";
		RecipeTable = {
			["Recipe1"] = {ItemName="",Amount=0};
			["Recipe2"] = {ItemName="",Amount=0};
			["Recipe3"] = {ItemName="",Amount=0};
			["Recipe4"] = {ItemName="",Amount=0};
		};
		UpdateRecipe();
		MainGUI.Inventory.Background.Bags.Visible = false;
		MainGUI.Inventory.Recipe.Visible = true;
		MainGUI.Inventory.Equipped.Visible = false;
		MainGUI.Inventory.Items.Visible = true;
		MainGUI.Inventory.Recycler.Visible = false;
		MainGUI.Inventory.NavBar.Items.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Bags.Style = Enum.ButtonStyle.RobloxRoundButton;
		MainGUI.Inventory.NavBar.Crafting.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		MainGUI.Inventory.NavBar.Recycle.Style = Enum.ButtonStyle.RobloxRoundButton;
		HideItems();
	end;
end


local OpenIndex = 0;

local OpenFunctions = {
	[1] = OpenItems;
	[2] = OpenRecycler;
	[2] = OpenCrafting;
};



MainGUI.Inventory.NavBar.Crafting.MouseButton1Click:connect(OpenCrafting)

MainGUI.Inventory.Recipe.View.MouseButton1Click:connect(function()
	MainGUI.Inventory.Visible = false;
	MainGUI.Recipes.Visible = true;
end)

local RaritySort = {
	["Victim"] = 10;
	["Godly"] = 9;
	["Legendary"] = 8;
	["Rare"] = 7;
	["Classic"] = 6;
	["Uncommon"] = 5;
	["Common"] = 4;
};

local iRec = 0;
GetSyncData("Recipe");
function CreateRecipes()
	local Recipes = GetSyncData("Recipe");	
	local Results = {};
	for ResultItem,_ in pairs(Recipes) do
		table.insert(Results,ResultItem);
	end
	
	table.sort(Results,function(ResultItem1,ResultItem2)
		local Rarity1 = GetSyncData("Item")[ResultItem1]["Rarity"];
		local Rarity2 = GetSyncData("Item")[ResultItem2]["Rarity"];
		return RaritySort[Rarity1] > RaritySort[Rarity2];
	end)
	
	for _,ResultItem in pairs(Results) do
		local RecipeTable = Recipes[ResultItem];
		local NewSlot = script.Recipe:Clone();
		NewSlot.Name = "Recipe";
		NewSlot.Position = UDim2.new(0,0,0,75*(iRec));
		
		for iComp,Component in pairs(RecipeTable["Components"]) do
			NewSlot["Recipe"..iComp].Image = GetSyncData("Item")[Component]["Image"];
			NewSlot["Recipe"..iComp].ItemName.Text = GetSyncData("Item")[Component]["ItemName"];
			NewSlot["Recipe"..iComp].ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[Component]["Rarity"]];
		end
		
		if RecipeTable.Gifts then
			NewSlot["Recipe".. 2].Image = GetSyncData("Item")["Gift"]["Image"];
			NewSlot["Recipe".. 2].ItemName.Text = GetSyncData("Item")["Gift"]["ItemName"];
			NewSlot["Recipe".. 2].ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")["Gift"]["Rarity"]];
			NewSlot["Recipe".. 2].Amount.Text = "x" .. RecipeTable.Gifts;
			NewSlot.BackgroundColor3 = Color3.new(18/255,89/255,0/255);
		end
		
		NewSlot.Result.Image = GetSyncData("Item")[ResultItem]["Image"];
		NewSlot.Result.ItemName.Text = GetSyncData("Item")[ResultItem]["ItemName"];
		NewSlot.Result.ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[ResultItem]["Rarity"]];
		
		NewSlot.Parent = MainGUI.Recipes.Items.Container;
		iRec = iRec + 1;
	end
end
CreateRecipes();

for _,Button in pairs(RecipeFrame:GetChildren()) do
	if RecipeTable[Button.Name] ~= nil then
		Button.MouseButton1Click:connect(function()
			RecipeTable[Button.Name] = {ItemName="",Amount=0};
			UpdateRecipe();
		end)
	end
end


local GiftQueue = {};

local function ShowItem()
	local Item = GiftQueue[1];
	CaseComplete.ItemImage.Image = GetSyncData("Item")[Item]["Image"]-- .. "&bust="..math.floor(tick());
	CaseComplete.ItemImage.ItemName.Text = GetSyncData("Item")[Item]["ItemName"];
	CaseComplete.ItemImage.ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[Item]["Rarity"]];
	local Con1;
	Con1 = CaseComplete.OK.MouseButton1Click:connect(function()
		Con1:disconnect();
		script.Click2:Play()
		CaseComplete.Visible = false;
		table.remove(GiftQueue,1);
		if GiftQueue[1] ~= nil then
			ShowItem();
		end
	end)
	CaseComplete.Visible = true;
end

game.ReplicatedStorage.ItemGift.OnClientEvent:connect(function(Prize)
	table.insert(GiftQueue,Prize)
	if not CaseComplete.Visible then
		ShowItem();
	end
end)

game.ReplicatedStorage.RedeemCode.OnClientEvent:connect(function(Prize,Error)
	if Prize ~= false then
		MainGUI.Inventory.Visible = false;
		CaseComplete.ItemImage.Image = GetSyncData("Item")[Prize]["Image"];
		CaseComplete.ItemImage.ItemName.Text = GetSyncData("Item")[Prize]["ItemName"];
		CaseComplete.ItemImage.ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[Prize]["Rarity"]];
		local Con1;
		Con1 = CaseComplete.OK.MouseButton1Click:connect(function()
			Con1:disconnect();
			script.Click2:Play()
			CaseComplete.Visible = false;
		end)
		CaseComplete.Visible = true;
	else
		if Error == "Expired" then
			MainGUI.Inventory.NavBar.CodeBox.Text = "Code Expired";
		elseif Error == "Has" then
			MainGUI.Inventory.NavBar.CodeBox.Text = "Already Redeemed";
		elseif Error == "Invalid" then
			MainGUI.Inventory.NavBar.CodeBox.Text = "Invalid Code";
		end
	end
end)

MainGUI.Inventory.NavBar.CodeBox.FocusLost:connect(function(enterPressed)
    if enterPressed then
        game.ReplicatedStorage.RedeemCode:FireServer(MainGUI.Inventory.NavBar.CodeBox.Text);
    end
end)

MainGUI.Inventory.NavBar.Redeem.MouseButton1Click:connect(function()
	game.ReplicatedStorage.RedeemCode:FireServer(MainGUI.Inventory.NavBar.CodeBox.Text);
end)


local CanSpectate = true;

Menu.Inventory.MouseEnter:connect(function()
	Menu.Inventory.Inventory.Image = "http://www.roblox.com/asset/?id=189694645";
end)
Menu.Inventory.MouseLeave:connect(function()
	Menu.Inventory.Inventory.Image = "http://www.roblox.com/asset/?id=189664481";
end)
Menu.Shop.MouseEnter:connect(function()
	Menu.Shop.Inventory.Image = "http://www.roblox.com/asset/?id=189694655";
end)
Menu.Shop.MouseLeave:connect(function()
	Menu.Shop.Inventory.Image = "http://www.roblox.com/asset/?id=189689518";
end)
Menu.Spectate.MouseEnter:connect(function()
	if CanSpectate then
		Menu.Spectate.Inventory.Image = "http://www.roblox.com/asset/?id=189694662";
	end
end)
Menu.Spectate.MouseLeave:connect(function()
	if CanSpectate then
		Menu.Spectate.Inventory.Image = "http://www.roblox.com/asset/?id=189690337";
	end
end)

game.ReplicatedStorage.PurchaseCrate.OnClientEvent:connect(function()
	UpdateInventory();
end)



game.ReplicatedStorage.CameraMode.OnClientEvent:connect(function(Mode)
	--[[
	if Mode == "FirstPerson" then
		Player.CameraMode = Enum.CameraMode.LockFirstPerson;
		--MainGUI.ter.Waiting.Visible = false;
		CanSpectate = false;
		Menu.Spectate.Inventory.Image = "http://www.roblox.com/asset/?id=189764018";
	else
		Player.CameraMode = Enum.CameraMode.Classic;
	end]]
end)

-- Inventory Frame

function CheckDuplicate(Duplicate)
	for _,ItemName in pairs(RecipeTable) do
		if ItemName.ItemName == Duplicate then
			return true;
		end
	end
	return false;
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

local ControllerSelection = 1;
local TotalItems;
local SelectingDock = false;
local DockSelect = 0;

local DockIndex = {
	[1] = {
		["ButtonName"] = "Inventory";
		["Select"] = "http://www.roblox.com/asset/?id=189694645";
		["Deselect"] = "http://www.roblox.com/asset/?id=189664481";
		["Function"] = OpenInventory;
	};
	[2] = {
		["ButtonName"] = "Shop";
		["Select"] = "http://www.roblox.com/asset/?id=189694655";
		["Deselect"] = "http://www.roblox.com/asset/?id=189689518";
		["Function"] = OpenShop;
	};
	[3] = {
		["ButtonName"] = "Spectate";
		["Select"] = "http://www.roblox.com/asset/?id=189694662";
		["Deselect"] = "http://www.roblox.com/asset/?id=189690337";
		["Function"] = function()script.Parent.SpectateClicked:Fire();end;
	};
};

local function Bind(ActionName,ButtonEnum,func)
	game:GetService("ContextActionService"):BindAction(ActionName,
		function(actionName, inputState, inputObject)
			if inputState == Enum.UserInputState.Begin then
				func();
			end
		end,
		false,
		ButtonEnum
	);
end
local function Unbind(ActionName)
	game:GetService("ContextActionService"):UnbindAction(ActionName)
end

local function CancelDock()
	SelectingDock = false;
	for _,A in pairs(MainGUI.Dock:GetChildren()) do
		for _,D in pairs(DockIndex) do
			if D["ButtonName"] == A.Name then
				A.Inventory.Image = D["Deselect"];
			end
		end
	end
	Unbind("NoJumpPlz");
	game:GetService("GuiService").SelectedObject = nil;
end



game:GetService("UserInputService").InputBegan:connect(function(input)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		local B = input.KeyCode;
		
		if B == Enum.KeyCode.ButtonR1 then
			Click:Play();
			OpenIndex = (OpenIndex+1)%3
			OpenFunctions[OpenIndex+1]();
			
		elseif B == Enum.KeyCode.ButtonL1 then
			Click:Play();
			OpenIndex = (OpenIndex-1)%3;
			OpenFunctions[OpenIndex+1]();
			
		elseif B == Enum.KeyCode.ButtonB then
			if MainGUI.Inventory.Visible or MainGUI.Shop.Visible and not MainGUI.Shop.PurchaseBox.Visible then
				Click:Play();
				MainGUI.Inventory.Visible = false;
				MainGUI.Inventory.Background.Bags.Visible = false;
				MainGUI.Inventory.Items.Visible = false;
				MainGUI.Inventory.Loading.Visible = true;
				MainGUI.Shop.Visible = false;
				CancelDock();
			elseif SelectingDock then
				CancelDock();
			end;
			
		elseif B == Enum.KeyCode.ButtonX then
			if not MainGUI.Inventory.Visible and not MainGUI.Shop.Visible and MainGUI.Dock.Visible and not MainGUI.Christmas.Visible then
				if not SelectingDock then
					SelectingDock = true;
					MainGUI.Dock[DockIndex[DockSelect+1]["ButtonName"]].Inventory.Image = DockIndex[DockSelect+1]["Select"];
					Bind("NoJumpPlz",Enum.KeyCode.ButtonA,function()end);
				else
					CancelDock();
				end;
			end
			
		elseif B == Enum.KeyCode.DPadDown and SelectingDock and not MainGUI.Inventory.Visible and not MainGUI.Shop.Visible and not MainGUI.Recipes.Visible then
			MainGUI.Dock[DockIndex[DockSelect+1]["ButtonName"]].Inventory.Image = DockIndex[DockSelect+1]["Deselect"];
			DockSelect = (DockSelect+1)%3
			MainGUI.Dock[DockIndex[DockSelect+1]["ButtonName"]].Inventory.Image = DockIndex[DockSelect+1]["Select"];
			
		elseif B == Enum.KeyCode.DPadUp and SelectingDock and not MainGUI.Inventory.Visible and not MainGUI.Shop.Visible and not MainGUI.Recipes.Visible then
			MainGUI.Dock[DockIndex[DockSelect+1]["ButtonName"]].Inventory.Image = DockIndex[DockSelect+1]["Deselect"];
			DockSelect = (DockSelect-1)%3
			MainGUI.Dock[DockIndex[DockSelect+1]["ButtonName"]].Inventory.Image = DockIndex[DockSelect+1]["Select"];
			
		elseif B == Enum.KeyCode.ButtonA and SelectingDock and not MainGUI.Inventory.Visible and not MainGUI.Shop.Visible and not MainGUI.CaseOpen.Visible and not MainGUI.CaseComplete.Visible and not MainGUI.Recipes.Visible then
			if not MainGUI.Shop.PurchaseBox.Visible and not MainGUI.Spectate.Visible then			
				DockIndex[DockSelect+1]["Function"]();
			end;
		end;
	end
end)
Player.PlayerGui.ChildAdded:connect(function(Child)
	wait();
	if Child.Name == "Dummy" then
		CancelDock();
	end
end);

local RecycleTable = {};
local Recycler = MainGUI.Inventory.Recycler;
local RecycleRestrictions = {
	ItemType = "";
	Rarity = "";
};

local Recyclable = GetSyncData("Recyclable");
HideItems = function()
	local Items = GetSyncData("Item");
	for _,Frame in pairs(MainGUI.Inventory.Items.Container:GetChildren()) do
		local ItemName = Frame.Name;
		if State == "Recycling" then
			
			local CanCraft = false;			
			for _,rItem in pairs(Recyclable) do
				if ItemName == rItem then
					CanCraft = true; break;
				end
			end
			
			if not CanCraft then
				Frame.Cover.Visible = true;
			elseif RecycleRestrictions.ItemType ~= "" then
				local ItemData = Items[ItemName]
				if ItemData.ItemType == RecycleRestrictions.ItemType and ItemData.Rarity == RecycleRestrictions.Rarity then
					Frame.Cover.Visible = false;
				else
					Frame.Cover.Visible = true;
				end;
			else
				Frame.Cover.Visible = false;
			end;
			
		else
			Frame.Cover.Visible = false;
		end;
	end
end


local function UpdateRecycler()
	
	local Items = GetSyncData("Item");
	local Rarity = GetSyncData("Rarity");
	
	for _,Button in pairs(Recycler:GetChildren()) do
		if Button:IsA("ImageButton") then
			Button.Image = "";
			Button.ItemName.Text = "";
		end;
	end

	for Index,ItemName in pairs(RecycleTable) do
		local ItemData = Items[ItemName];
		local Button = Recycler["Recipe"..Index];
		Button.Image = ItemData.Image;
		Button.ItemName.Text = ItemData.ItemName;
		Button.ItemName.TextColor3 = Rarity[ItemData.Rarity];
	end;
	
	Recycler.Recycle.Style = Enum.ButtonStyle.RobloxRoundButton;
	if #RecycleTable == 1 then
		local ItemData = Items[RecycleTable[1]];
		RecycleRestrictions.ItemType = ItemData.ItemType;
		RecycleRestrictions.Rarity = ItemData.Rarity;
	elseif #RecycleTable < 1 then
		RecycleRestrictions.ItemType = "";
		RecycleRestrictions.Rarity = "";
	elseif #RecycleTable == 8 then
		Recycler.Recycle.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	end;
	HideItems();
end

for _,Button in pairs(Recycler:GetChildren()) do
	if Button:IsA("ImageButton") then
		local ButtonIndex = tonumber(string.sub(Button.Name,7,7));
		Button.MouseButton1Click:connect(function()
			if RecycleTable[ButtonIndex] ~= nil then
				table.remove(RecycleTable,ButtonIndex);
				UpdateRecycler();
			end
		end)
	end
end

local CanRecycle = true;
Recycler.Recycle.MouseButton1Click:connect(function()
	if #RecycleTable == 8 and CanRecycle then
		local Items = GetSyncData("Item");
		local Rarity = GetSyncData("Rarity");
		CanRecycle = false;
		local NewTable = {unpack(RecycleTable)};
		RecycleTable = {};
		UpdateRecycler();
		MainGUI.Inventory.Visible = false;
		
		local Reward = game.ReplicatedStorage.RecycleItems:InvokeServer(NewTable);
		
		CanRecycle = true;
		if Reward then
			local CrateFinished = MainGUI.CaseComplete;
			CrateFinished.ItemImage.ItemName.Text = Items[Reward].ItemName
			CrateFinished.ItemImage.ItemName.TextColor3 = Rarity[Items[Reward]["Rarity"]];
			CrateFinished.ItemImage.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=".. Items[Reward]["ItemID"];
			CrateFinished.Visible = true;
			_G.GiveItem();
		end;
	end
end)

local EquipConnections = {};
function UpdateInventory()
	local SyncItems = GetSyncData("Item");
	
	for i,Connection in pairs(EquipConnections) do Connection:disconnect() end;
	InventoryFrame:ClearAllChildren();
	
	local InventoryTable = game.ReplicatedStorage.GetData:InvokeServer("Inventory");
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
	TotalItems = #Inventory;
	
	
	local EquippedKnife = game.ReplicatedStorage.GetData:InvokeServer("KnifeEquipped");
	
	local KnifeItem = GetSyncData("Item")[EquippedKnife];
	
	EquippedFrame.Knife.Image = KnifeItem["Image"];
	EquippedFrame.Knife.ItemName.Text = GetSyncData("Item")[EquippedKnife]["ItemName"];
	EquippedFrame.Knife.ItemName.TextColor3 = GetSyncData("Rarity")[GetSyncData("Item")[EquippedKnife]["Rarity"]];	
	
	
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
		NewSlot.Name = ItemName;
		if ItemCount == ControllerSelection then
			--NewSlot.BackgroundColor3 = Color3.new(1,1,0);
		end

		NewSlot.Image = CurrentItemData["Image"];-- .. "&bust="..math.floor(tick());
		NewSlot.ItemName.Text = GetSyncData("Item")[ItemName]["ItemName"];
		NewSlot.ItemName.TextColor3 = GetSyncData("Rarity")[CurrentItemData["Rarity"]];
		if Amount > 1 then
			NewSlot.Amount.Text = "x" .. Amount;
		end	
	
		local Click = function(Right)
			if State == "Recycling" and CurrentItemData["ItemType"] ~= "Misc" then
				if #RecycleTable < 8 then
					local ThisItemAmount = 0;
					for _,ItemR in pairs(RecycleTable) do if ItemR == ItemName then ThisItemAmount = ThisItemAmount + 1; end end;
					local HasAmount = Amount-ThisItemAmount; 					
					if HasAmount >= 1 and NewSlot.Cover.Visible == false then
						table.insert(RecycleTable,ItemName);
						UpdateRecycler();
					end;
				end
			elseif State == "Equipping" and CurrentItemData["ItemType"] ~= "Misc" then
				EquippedFrame[CurrentItemData["ItemType"]].Image = CurrentItemData["Image"];
				EquippedFrame[CurrentItemData["ItemType"]].ItemName.Text = CurrentItemData["ItemName"];
				EquippedFrame[CurrentItemData["ItemType"]].ItemName.TextColor3 = GetSyncData("Rarity")[CurrentItemData["Rarity"]];
				game.ReplicatedStorage.EquipItem:FireServer(ItemName);
			elseif State == "Crafting" then
				local CurrentAmount = Amount;
				if ItemName ~= "Gift" then
					for rIndex,Item in pairs(RecipeTable) do
						if Item.ItemName == ItemName then
							CurrentAmount = CurrentAmount - 1;
						end
					end
				else
					for rIndex,Item in pairs(RecipeTable) do
						if Item.ItemName == ItemName then
							CurrentAmount = CurrentAmount - Item.Amount;
						end
					end
				end;
				if CurrentAmount > 0 then
					if ItemName ~= "Gift" then
						if RecipeTable["Recipe1"].ItemName == "" then
							RecipeTable["Recipe1"].ItemName = ItemName;
							RecipeTable["Recipe1"].Amount = 1;
						elseif RecipeTable["Recipe2"].ItemName == "" then
							RecipeTable["Recipe2"].ItemName = ItemName;
							RecipeTable["Recipe2"].Amount = 1;
						elseif RecipeTable["Recipe3"].ItemName == "" then
							RecipeTable["Recipe3"].ItemName = ItemName;
							RecipeTable["Recipe3"].Amount = 1;
						elseif RecipeTable["Recipe4"].ItemName == "" then
							RecipeTable["Recipe4"].ItemName = ItemName;
							RecipeTable["Recipe4"].Amount = 1;
						end;
					else
						local Found = false;
						for RecipeIndex,RecipeItemTable in pairs(RecipeTable) do
							if RecipeItemTable.ItemName == "Gift" then
								RecipeTable[RecipeIndex].ItemName = "Gift";
								RecipeTable[RecipeIndex].Amount = RecipeTable[RecipeIndex].Amount + (( (Right and CurrentAmount >= 10) and 10) or (Right and CurrentAmount) or 1);
								Found = true;
							end
						end
						
						if not Found then
							if RecipeTable["Recipe1"].ItemName == "" then
								RecipeTable["Recipe1"].ItemName = ItemName;
								RecipeTable["Recipe1"].Amount = 1;
							elseif RecipeTable["Recipe2"].ItemName == "" then
								RecipeTable["Recipe2"].ItemName = ItemName;
								RecipeTable["Recipe2"].Amount = 1;
							elseif RecipeTable["Recipe3"].ItemName == "" then
								RecipeTable["Recipe3"].ItemName = ItemName;
								RecipeTable["Recipe3"].Amount = 1;
							elseif RecipeTable["Recipe4"].ItemName == "" then
								RecipeTable["Recipe4"].ItemName = ItemName;
								RecipeTable["Recipe4"].Amount = 1;
							end;
						end
						
						
					end;

				end;
				UpdateRecipe();
			end
		end	
	
		local Connection;
		Connection = NewSlot.MouseButton1Click:connect(function()
			Click();
		end)
		local Connection2;
		Connection2 = NewSlot.MouseButton2Click:connect(function()
			Click(true);
		end)
		
		table.insert(EquipConnections,Connection);
		table.insert(EquipConnections,Connection2);
	end
	wait(0.2);
	MainGUI.Inventory.Items.Visible = true;
	MainGUI.Inventory.Loading.Visible = false;
end

game.ReplicatedStorage.Trade.EndTrade.OnClientEvent:connect(UpdateInventory);

game.ReplicatedStorage.UpdateData2.OnClientEvent:connect(function()
	wait();
	UpdateInventory();
end)

UpdateInventory();

