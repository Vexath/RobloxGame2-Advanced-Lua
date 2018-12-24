local GameGUI = script.Parent.Parent.Game;
local CraftGUI = GameGUI.Crafting;
local SalvageGUI = GameGUI.Salvage;
local Inventory = CraftGUI.Inventory;
local Action = CraftGUI.Action;
local RecipeFrame = CraftGUI.Recipes;
local RecipesButton = CraftGUI.Title.Recipes;

local Salvage = Action.Salvage;
local Craft = Action.Craft;

local Remote = game.ReplicatedStorage;
local Remotes = Remote.Remotes;
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


local Database = {
	Weapons = Remote.GetSyncData:InvokeServer("Item");
	Materials = Remote.GetSyncData:InvokeServer("Materials");
	Recipes = Remote.GetSyncData:InvokeServer("Recipes");
};

local MyStuff = {
	Weapons = nil;
	Materials = nil;
};

local Stuff = {"Weapons","Materials"};

local RawCodes = Remote.GetSyncData:InvokeServer("Codes");
local Codes = {};
for _,CodeData in pairs(RawCodes) do Codes[CodeData.Prize] = true; end; 

local RarityColors = Remote.GetSyncData:InvokeServer("Rarity");
local SalvageRewards = Remote.GetSyncData:InvokeServer("SalvageRewards");
local Materials = Remote.GetSyncData:InvokeServer("Materials");
local RarityOrder = {Classic=1;Common=2;Uncommon=3;Rare=4;Legendary=5;Godly=6;Victim=7;Christmas=1.5;Halloween=1.6;Ancient=6.5;};

local function CopyTable(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == 'table' then
            v = CopyTable(v)
        end
        copy[k] = v
    end
    return copy
end

local function Resort(Table,Type)
	table.sort(Table,function(a,b)
		-- if A is less than B, return true;
		local ID = {a.ItemID,b.ItemID};
		local Amount = {a.Amount,b.Amount};
		local Data = {Database[a.Type or Type][ID[1]],Database[b.Type or Type][ID[2]]};
		local Rarity = {RarityOrder[Data[1].Rarity],RarityOrder[Data[2].Rarity]};
		local DefaultPillow = 1;

		if ID[1] == "DefaultPillow" then
			return true;
		elseif ID[2] == "DefaultPillow" then 
			return false;
		else
			if Rarity[1] ~= Rarity[2] then
				return Rarity[1] > Rarity[2];
			elseif Amount[1] ~= Amount[2] then
				return (Amount[1] > Amount[2]);
			else
				return Data[1][ (Type=="Weapons"and "ItemName")or "Name" ] < Data[2][ (Type=="Weapons"and "ItemName")or "Name" ];
			end;
		end;
	end)
end

local function SortData()
	
	
	
	for _,DataName in pairs(Stuff) do
		local Table = CopyTable(_G.PlayerData[DataName]);
		if Table ~= nil then
			table.sort(Table.Owned,function(a,b)
				return a < b; -- Attempt to compare bool with table
			end)
			MyStuff[DataName] = Table;
		end;
	end
	
	local CustomTypes = {"Weapons","Materials"};
	for _,Type in pairs(CustomTypes) do
		local Data1 = CopyTable(_G.PlayerData[Type]);
		local WeaponsTable = {};
		for ItemID,Amount in pairs(Data1.Owned) do
			table.insert(WeaponsTable,{
				ItemID = ItemID;
				Amount = Amount;
			});
		end
		
		if Type == "Materials" then
			for ItemID,Amount in pairs(_G.PlayerData["Weapons"].Owned) do
				if Database.Weapons[ItemID].Craftable then
					table.insert(WeaponsTable,{
						ItemID = ItemID;
						Amount = Amount;
						Type = "Weapons";
					});
				end
			end
		end
		
		table.sort(WeaponsTable,function(a,b)
			-- if A is less than B, return true;
			local ID = {a.ItemID,b.ItemID};
			local Amount = {a.Amount,b.Amount};
			local Data = {Database[a.Type or Type][ID[1]],Database[b.Type or Type][ID[2]]};
			local Rarity = {RarityOrder[Data[1].Rarity],RarityOrder[Data[2].Rarity]};
			local DefaultPillow = 1;
	
			if ID[1] == "DefaultPillow" then
				return true;
			elseif ID[2] == "DefaultPillow" then 
				return false;
			else
				if Rarity[1] ~= Rarity[2] then
					return Rarity[1] > Rarity[2];
				elseif Amount[1] ~= Amount[2] then
					return (Amount[1] > Amount[2]);
				else
					return Data[1][ (Type=="Weapons"and "ItemName")or "Name" ] < Data[2][ (Type=="Weapons"and "ItemName")or "Name" ];
				end;
			end;
		end)
		Data1.Owned = WeaponsTable;
		MyStuff[Type] = Data1;
	end;
	
end;

local CurrentlySalvaging;
local Salvageable = false;
local CraftingTable = {};
local FoundRecipe = nil;

local function UpdateSalvage()
	
	for _,Frame in pairs(Salvage.Rewards:GetChildren()) do Frame.Visible = false; end;
	Salvage.Icon.Image = "";
	Salvage.Icon.ItemName.Text = "";
	Salvage.NoSalvage.Visible = false;
	
	if Action.Salvage.Visible then
		Action.Confirm.Style = Enum.ButtonStyle.RobloxRoundButton;
	end;
	
	Salvageable = false;

	local ItemData = Database.Weapons[CurrentlySalvaging];
	if ItemData then
		local RewardsTable = SalvageRewards[CurrentlySalvaging] or SalvageRewards[ItemData.Rarity]
		local Rewards = RewardsTable and RewardsTable.Rewards;
		
		Salvageable = (not Codes[CurrentlySalvaging]) and Rewards;
		
		Salvage.Icon.ImageColor3 = (Salvageable and Color3.new(1,1,1)) or Color3.new(0.1,0.1,0.1);
		Salvage.NoSalvage.Visible = (not Salvageable);
		
		
		Salvage.Icon.Image = GetImage(ItemData.Image);
		Salvage.Icon.ItemName.Text = ItemData.ItemName or ItemData.Name;

		local RarityColor = RarityColors[ItemData.Rarity];
		Salvage.Icon.ItemName.TextColor3 = (Salvageable and RarityColor) or Color3.new(0.1,0.1,0.1);
		
		if Salvageable then
			local i = 1;
			for RewardID,RewardData in pairs(Rewards) do
				local Frame = Salvage.Rewards["Slot"..i].Frame;
				
				local Amount1,Amount2  = RewardData.Amount[1],RewardData.Amount[2];
				
				for e = 1,3 do
					local CountChance = RewardsTable.CountChance[e];
					local Rarity = RewardData.Rarity[e];
					if Rarity > 0 then
						if CountChance < 100 and CountChance > 0 then
							Amount1 = 0;
						end
					end
				end
				
				Frame.Icon.Image = Materials[RewardID].Image;
				Frame.Amount.Text = (Amount1~=Amount2 and Amount1 .. " - " .. Amount2) or Amount1;
				Frame.Parent.Visible = true;
				i=i+1;
			end
			
			if Action.Salvage.Visible then
				Action.Confirm.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
			end;
		end;
		
		Salvage.NoSalvage.Visible = not Salvageable;

	end
	-- Show Potential Rewards
end

local function UpdateCrafting()
	for _,Frame in pairs(Craft.Recipe:GetChildren()) do Frame.Container.Icon.Image = ""; Frame.Container.Amount.Text = ""; end;
	
	for Index,Data in pairs(CraftingTable) do
		local Frame = Craft.Recipe["Slot"..Index].Container;
		Frame.Icon.Image = Materials[Data.ItemID].Image;
		Frame.Amount.Text = "x"..Data.Amount;
	end
	
	local SelectedRecipe;	
	
	-- FindRecipe
	for RecipeID,RecipeData in pairs(Database.Recipes) do
		if not RecipeData.CombinationRecipe then
			local TotalOwnedMaterials = 0;
			local PartsOfRecipeOwned= 0;
			local TotalMaterialsNeeded = 0;
			local TotalPartsOfRecipeNeeded = 0;
			for MaterialID,RequiredAmount in pairs(RecipeData.Materials) do
				TotalPartsOfRecipeNeeded = TotalPartsOfRecipeNeeded + 1;
				TotalMaterialsNeeded = TotalMaterialsNeeded + RequiredAmount;
				for _,CData in pairs(CraftingTable) do
					if CData.ItemID == MaterialID and CData.Amount >= RequiredAmount then
						PartsOfRecipeOwned = PartsOfRecipeOwned + 1;
						TotalOwnedMaterials = TotalOwnedMaterials + CData.Amount;
						break;
					end
				end
			end;
			if TotalMaterialsNeeded == TotalOwnedMaterials and PartsOfRecipeOwned == TotalPartsOfRecipeNeeded and #CraftingTable == TotalPartsOfRecipeNeeded then
				SelectedRecipe = RecipeID;
				break;
			end;
		end;
	end;
	
	local RD = Database.Recipes[SelectedRecipe]	
	
	Craft.Reward.Container.Icon.Image = (RD and RD.Image) or "";
	Craft.Reward.Container.ItemName.Text = (RD and RD.Name) or "";
	
	FoundRecipe = RD;	
	
	if Craft.Visible then
		Action.Confirm.Style = (RD and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
	end

end

local function CreateGrid() end;

local D,S,T="Out","Quad",0.2;

Salvage.Icon.Button.MouseButton1Click:connect(function() CurrentlySalvaging=nil; UpdateSalvage(); end);
Action.Confirm.MouseButton1Click:connect(function()
	if Action.Salvage.Visible and CurrentlySalvaging and Salvageable then
		
		SalvageGUI.Claim.Style = Enum.ButtonStyle.RobloxRoundButton;
		SalvageGUI.Claim.Text = "Salvaging...";
		
		CraftGUI.Visible = false;
		_G.Process("Salvaging");
		
		local StartTime = time();
		local Rewards = Remotes.Inventory.Salvage:InvokeServer(CurrentlySalvaging);
		local SalvagedItem = CurrentlySalvaging;

		CurrentlySalvaging = nil;
		UpdateSalvage();
		
		local Item1,Item2,Item3 = SalvageGUI.Main.Item1.Container,SalvageGUI.Main.Item2.Container,SalvageGUI.Main.Item3.Container;
		Item1.Icon.Image="";Item1.ItemName.Text=""; Item2.Icon.Image="";Item2.ItemName.Text=""; Item3.Icon.Image="";Item3.ItemName.Text="";
		
		wait( 0.75-(time()-StartTime));
		if Rewards then
			
			GameGUI.Processing.Visible = false;
			
			Item1.Icon.Image = GetImage( Database.Weapons[SalvagedItem].Image );
			Item1.ItemName.Text = Database.Weapons[SalvagedItem].ItemName;
			Item1.ItemName.TextColor3 = RarityColors[ Database.Weapons[SalvagedItem].Rarity ];
			
			SalvageGUI.Visible = true;			
			
			wait(0.5);
			
			Item1.Slider:TweenPosition(UDim2.new(0,0,0,0),D,S,T);
			Item2.Slider:TweenPosition(UDim2.new(0,0,0,0),D,S,T);
			Item3.Slider:TweenPosition(UDim2.new(0,0,0,0),D,S,T);
			
			wait(0.5);
			
			for i,Reward in pairs(Rewards) do
				local ItemFrame = SalvageGUI.Main["Item"..i].Container;
				ItemFrame.Icon.Image = Materials[Reward.ID].Image;
				ItemFrame.ItemName.Text = Materials[Reward.ID].Name .. " [x" .. Reward.Amount .. "]";
				ItemFrame.ItemName.TextColor3 = RarityColors[ Materials[Reward.ID].Rarity ];
			end;
			
			Item1.Slider:TweenPosition(UDim2.new(0,0,-1,0),D,S,T);
			Item2.Slider:TweenPosition(UDim2.new(0,0,-1,0),D,S,T);
			Item3.Slider:TweenPosition(UDim2.new(0,0,-1,0),D,S,T);
			
			wait(T+0.2);
			
			SalvageGUI.Claim.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
			SalvageGUI.Claim.Text = "Claim!";

			-- Salvage Vision
		end;
	elseif Action.Craft.Visible and FoundRecipe then
		
		CraftGUI.Visible = false;
		_G.Process("Crafting");
		
		local StartTime = time();
		local SendTable = CraftingTable;
		CraftingTable = {};
		local RewardID,RewardAmount,RewardType = Remotes.Inventory.Craft:InvokeServer(SendTable);
		
		Resort(MyStuff.Materials.Owned,"Materials");
		CreateGrid("Materials",Inventory.Craft.ScrollFrame);
		UpdateCrafting();
		
		wait( 0.75-(time()-StartTime));
		
		if RewardID then
			GameGUI.Processing.Visible = false;
			_G.NewItem(RewardID,"You Crafted...",GameGUI.Crafting,RewardType);
		end
			
	end;
end)
SalvageGUI.Claim.MouseButton1Click:connect(function() if SalvageGUI.Claim.Style == Enum.ButtonStyle.RobloxRoundDefaultButton then SalvageGUI.Visible = false; CraftGUI.Visible = true; end; end);



local FrameFunction = function(Frame,Index,Table,Type)
	local ItemData = Database[Type][Table.ItemID];
	
	local RewardsTable = SalvageRewards[Table.ItemID] or SalvageRewards[ItemData.Rarity];
	local Rewards = RewardsTable and RewardsTable.Rewards;
	local Salvageable = (not Codes[Table.ItemID]) and Rewards;
	
	Frame.Icon.Image = GetImage(ItemData.Image);
	Frame.ItemName.Text = ItemData.ItemName or ItemData.Name;
	Frame.ItemName.TextColor3 = RarityColors[ItemData.Rarity];
	Frame.Rarity.Text = ItemData.Rarity;
	Frame.Rarity.TextColor3 = RarityColors[ItemData.Rarity];
	
	Frame.Cover.Visible = (not Salvageable);	
	
	if Table.Amount > 1 then
		Frame.Amount.Text = "x" .. Table.Amount;
	end
	Frame.MouseEnter:connect(function() Frame.Rarity.Visible = true; end);
	Frame.MouseLeave:connect(function() Frame.Rarity.Visible = false; end);
	Frame.Button.MouseButton1Click:connect(function()
		if Type == "Weapons" then

			CurrentlySalvaging = (CurrentlySalvaging~=Table.ItemID and Table.ItemID) or nil;
			UpdateSalvage();
			
		elseif Type == "Materials" then
			
			for _,Data in pairs (CraftingTable) do
				if Data.ItemID == Table.ItemID then
					Data.Amount = Data.Amount + 1;
					
					MyStuff[Type].Owned[Index].Amount = MyStuff[Type].Owned[Index].Amount - 1;
					if MyStuff[Type].Owned[Index].Amount < 1 then table.remove(MyStuff[Type].Owned,Index); end;
					
					CreateGrid("Materials",Inventory.Craft.ScrollFrame);
					UpdateCrafting();
					return;
				end
			end;
			
			if #CraftingTable < 6 then
				
				table.insert(CraftingTable,{
					ItemID = Table.ItemID;
					Amount = 1;
				});
				
				MyStuff[Type].Owned[Index].Amount = MyStuff[Type].Owned[Index].Amount - 1;
				if MyStuff[Type].Owned[Index].Amount < 1 then table.remove(MyStuff[Type].Owned,Index); end;
				CreateGrid("Materials",Inventory.Craft.ScrollFrame);
				
			end;
			UpdateCrafting();
			
		end;
	end)
	if Codes[Table.ItemID] then
		Frame.Icon.ImageColor3 = Color3.new(0.1,0.1,0.1);
		Frame.ItemName.TextColor3 = Color3.new(0.21,0.21,0.21);
		Frame.Amount.TextColor3 = Color3.new(0.21,0.21,0.21);
	end
end

CreateGrid = function(Type,ScrollFrame)
	if MyStuff[Type] == nil then return end;
	local i = 0;
	local Container = ScrollFrame.Container;
	local Size =  Type == "Weapons" and 0.2 or 0.25;

	Container:ClearAllChildren();
	local function CreateFrame(Index,Value)
		if type(Value) == "table" and (Value.ItemID == "DefaultPillow") then return; end
		local Row = math.floor(i/(1/Size)); local Column = i%(1/Size);
		local NewFrame = script.Item:Clone();
		NewFrame.Parent = Container;
		NewFrame.Size = UDim2.new(Size,0,Size,0);
		NewFrame.Position = UDim2.new(NewFrame.Size.X.Scale*Column,0,0,NewFrame.AbsoluteSize.Y*Row);
		FrameFunction(NewFrame.Container,Index,Value,Value.Type or Type); 
		NewFrame.Name = Value.ItemID;
		ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
		i = i + 1;
	end
	
	for Index,Value in pairs(MyStuff[Type].Owned) do
		CreateFrame(Index,Value);
	end
	
	local HasMats  = false;
	for _,_ in pairs(_G.PlayerData.Materials.Owned) do
		HasMats = true;
	end	
	
	if Type == "Materials" then
		ScrollFrame.Parent.NoMats.Visible = not HasMats;
		ScrollFrame.Parent.NoMats2.Visible = not HasMats;
	end;
	
end

local function CheckHasRecipe(RecipeID)
	local Has = 0;
	local Total = 0;
	local OwnedMaterials = {};
	
	if Database.Recipes[RecipeID].CombinationRecipe then
		local HasSome = false;
		for rID,RecipeData in pairs(Database.Recipes) do
			if RecipeData.CombinedRecipe == RecipeID then
				local HasFull,HasPartially = CheckHasRecipe(rID);
				if HasFull then
					return true,true;
				elseif HasSome then
					HasSome = true;
				end;
			end
		end
		return false,HasSome;
		--[[local HasAtleastOne = false;
		for _,RecipeData in pairs(Database.Recipes) do
			if RecipeData.CombinedRecipe == RecipeID then
				local cTotal = 0;
				local cHas = 0;
					
				for MaterialName,Amount in pairs(RecipeData.Materials) do
					cTotal = cTotal + 1;
					if _G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName] > 0 then
						cHas = cHas+1;
						HasAtleastOne = true;
					end
				end
				
				if cTotal == cHas then
					return true,true;
				end
			end
		end
		return false,true;]]
	else
	
		for MaterialName,Amount in pairs(Database.Recipes[RecipeID].Materials) do
			Total = Total + 1;
			if _G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName] > 0 then
				Has = Has+1;
				table.insert(OwnedMaterials,MaterialName);
			end
		end
		
	end;
	
	return (Has==Total), Has>0;
end

local function UpdateRecipes()
	local ScrollFrame = RecipeFrame.ScrollFrame;
	local Container = ScrollFrame.Container;
	Container:ClearAllChildren();
	
	local CombinedRecipes = {};
	for RecipeID,RecipeData in pairs(Database.Recipes) do
		if RecipeData.CombinedRecipe then
			if CombinedRecipes[RecipeData.CombinedRecipe] then
				CombinedRecipes[RecipeData.CombinedRecipe][RecipeID] = RecipeData;
			else
				CombinedRecipes[RecipeData.CombinedRecipe] = { [RecipeID] = RecipeData;};
			end;
		end
	end
	
	local SortedRecipes = {};
	for RecipeID,RecipeData in pairs(Database.Recipes) do
		if not RecipeData.CombinedRecipe then
			table.insert(SortedRecipes,{ID=RecipeID;Data=RecipeData;});
		end;
	end
	
	for CombinedRecipeID,RecipeList in pairs(CombinedRecipes) do
		
		for iR,rTable in pairs(SortedRecipes) do
			
			if rTable.ID == CombinedRecipeID then
				local NewList = {};
				for RecipeID,RecipeData in pairs(RecipeList) do
					table.insert(NewList,{ID=RecipeID;Data=RecipeData;});
				end
				table.sort(NewList,function(A,B)
					return A.ID < B.ID;
				end)
				SortedRecipes[iR].Data.RecipeList = NewList;
				break;
			end
			
		end
		
	end
	
	table.sort(SortedRecipes,function(A,B)
		local HasRecipeA,PartiallyA = CheckHasRecipe(A.ID);
		local HasRecipeB,PartiallyB = CheckHasRecipe(B.ID);
		
		if HasRecipeA and not HasRecipeB then
			return true;
		elseif HasRecipeB and not HasRecipeA then
			return false;
		elseif PartiallyA and not PartiallyB then
			return true;
		elseif PartiallyB and not PartiallyA then
			return false;
		elseif A.Data.SortPriority ~= B.Data.SortPriority then
			return A.Data.SortPriority < B.Data.SortPriority;
		elseif A.Data.Rarity ~= B.Data.Rarity then
			return RarityOrder[A.Data.Rarity] > RarityOrder[B.Data.Rarity];
		else
			return A.Data.Name < B.Data.Name;
		end;
	end);
	
	-- RarityOrder[A.Data.Rarity] > RarityOrder[B.Data.Rarity];
	
	local i = 0;
	local SizeX = 1;
	
	local function CreateFrame(Index,Table)
		local Data = Table.Data;
		local Row = math.floor(i/(1/1));
		
		local NewFrame = script.Recipe:Clone();
		NewFrame.Parent = Container;
		NewFrame.Position = UDim2.new(0,0,0,NewFrame.AbsoluteSize.Y*Row);
		NewFrame.Name = Table.ID;
		
		if not Data.CombinationRecipe then
			NewFrame.RecipeName.Text = Data.Name;
			NewFrame.RecipeName.TextColor3 = RarityColors[Data.Rarity];
			NewFrame.Result.Container.Icon.Image = Data.Image;
			
			local HasAMaterial = false;		
			
			local m = 1;
			for MaterialName,Amount in pairs(Data.Materials) do
				
				local HasEnough = (_G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName] >= Amount);
				local HasPartial = (_G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName]>0);
				local HasAny = (HasEnough or HasPartial);
				
				local Frame = NewFrame.Materials["Material"..m];
				Frame.Container.Icon.Image = Materials[MaterialName].Image;
				Frame.Container.Amount.Text =  (HasAny and _G.PlayerData.Materials.Owned[MaterialName] .. "/" .. Amount) or "x" .. Amount;
				
				Frame.Container.BorderColor3 = (HasEnough and Color3.new(0,140,0)) or (HasPartial and Color3.new(1,1,0)) or Color3.new(0,0,0);
				Frame.Container.BorderSizePixel = ( HasAny and 1 ) or 0;
				
				if HasAMaterial == false then
					HasAMaterial = HasAny;
				end
				
				Frame.Visible = true;
				m=m+1;
			end
			NewFrame.Missing.Visible = (not HasAMaterial);
		else
			
			
			spawn(function()
				local CurrentRecipe = 0;
				while wait(1) and NewFrame and NewFrame.Parent do
					
					CurrentRecipe = CurrentRecipe+1;
					local rData = Data.RecipeList[CurrentRecipe];
					
					if not rData then 
						CurrentRecipe = 1; 
						rData = Data.RecipeList[CurrentRecipe];
					end;
					
					local cData = rData.Data;
					
					NewFrame.RecipeName.Text = Data.Name--cData.Name;
					NewFrame.RecipeName.TextColor3 = RarityColors[cData.Rarity];
					NewFrame.Result.Container.Icon.Image = cData.Image;
					
					local HasAMaterial = false;		
					
					local m = 1;
					for MaterialName,Amount in pairs(cData.Materials) do
						
						local HasEnough = (_G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName] >= Amount);
						local HasPartial = (_G.PlayerData.Materials.Owned[MaterialName] and _G.PlayerData.Materials.Owned[MaterialName]>0);
						local HasAny = (HasEnough or HasPartial);
						
						local Frame = NewFrame.Materials["Material"..m];
						Frame.Container.Icon.Image = Materials[MaterialName].Image;
						Frame.Container.Amount.Text =  (HasAny and _G.PlayerData.Materials.Owned[MaterialName] .. "/" .. Amount) or "x" .. Amount;
						
						Frame.Container.BorderColor3 = (HasEnough and Color3.new(0,140,0)) or (HasPartial and Color3.new(1,1,0)) or Color3.new(0,0,0);
						Frame.Container.BorderSizePixel = ( HasAny and 1 ) or 0;
						
						if HasAMaterial == false then
							HasAMaterial = HasAny;
						end;
						Frame.Visible = true;
						m=m+1;
					end
					NewFrame.Missing.Visible = (not HasAMaterial);
				end
			end)
			
			
		end;
		
	
		
		ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
		i = i + 1;
	end
	
	for Index,Value in pairs(SortedRecipes) do
		CreateFrame(Index,Value);
	end
	
end

for i = 1,6 do 
	local Frame = Craft.Recipe["Slot"..i];
	Frame.Container.Button.MouseButton1Click:connect(function()
		if CraftingTable[i] then
		
			local Found = false;
			for Index,Data in pairs(MyStuff.Materials.Owned) do
				if Data.ItemID == CraftingTable[i].ItemID then
					MyStuff.Materials.Owned[Index].Amount = MyStuff.Materials.Owned[Index].Amount + 1;
					Found = true;
					break;
				end
			end
			
			if not Found then
				table.insert(MyStuff.Materials.Owned,{
					ItemID = CraftingTable[i].ItemID;
					Amount = 1;
				});
			end
			
			CraftingTable[i].Amount = CraftingTable[i].Amount - 1;
			if CraftingTable[i].Amount <= 0 then
				table.remove(CraftingTable,i);
			end
			
			Resort(MyStuff.Materials.Owned,"Materials");
			CreateGrid("Materials",Inventory.Craft.ScrollFrame);
			UpdateCrafting();
		end;
	end)
end

Update = function(CoinUpdate)
	if not CoinUpdate then
		SortData();
		CreateGrid("Weapons",Inventory.Salvage.ScrollFrame);
		
		for _,Data in pairs(CraftingTable) do
			local Type = "Materials";
			for Index,Table in pairs(MyStuff[Type].Owned) do
				if Table.ItemID == Data.ItemID then
					MyStuff[Type].Owned[Index].Amount = MyStuff[Type].Owned[Index].Amount - Data.Amount
					if MyStuff[Type].Owned[Index].Amount < 1 then table.remove(MyStuff[Type].Owned,Index); end;
				end;
			end;
		end
		
		CreateGrid("Materials",Inventory.Craft.ScrollFrame);
		UpdateRecipes();
		UpdateCrafting();
		UpdateSalvage();
	end;
end;
Update();
game.ReplicatedStorage.UpdateDataClient.Event:connect(Update);


-- GUI Components 
local D,S,T="Out","Quad",0.2;

local RecipesOpen = "Closed";


local function ToggleRecipes()
	RecipesOpen = (RecipesOpen == "Closed" and "Open") or (RecipesOpen == "Open" and "Half") or "Closed";
	RecipesButton.Style = ((RecipesOpen == "Open" or RecipesOpen == "Half") and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
	--Inventory.Visible = (not RecipesOpen);
	--RecipeFrame.Visible = RecipesOpen;
	--[[InProgress:TweenPosition(UDim2.new(0,0,
		(RecipesOpen and 1) or 0.7,0
	),D,S,T,true);]]


	Inventory:TweenSizeAndPosition(
		--Size
		RecipesOpen == "Closed" and UDim2.new(0.7, 0,1, -40) or
		RecipesOpen == "Half" 	and UDim2.new(0.7, 0, 0.5, 5) or
		RecipesOpen == "Open" 	and UDim2.new(0.7, 0,1, -40),
		
		--Position
		RecipesOpen == "Closed" and UDim2.new(0, 0,0, 40) or
		RecipesOpen == "Half" 	and UDim2.new(0, 0, 0.5, -5) or
		RecipesOpen == "Open" 	and UDim2.new(0, 0,1, 0),
		
		D,S,T
	);
	
	RecipeFrame:TweenSizeAndPosition(
		--Size
		RecipesOpen == "Closed" and UDim2.new(0.7, 0,0, 0) or
		RecipesOpen == "Half" 	and UDim2.new(0.7, 0,0.5, -40) or
		RecipesOpen == "Open" 	and UDim2.new(0.7, 0,1, -40),
		
		--Position
		RecipesOpen == "Closed" and UDim2.new(0, 0, 0, 40) or
		RecipesOpen == "Half" 	and UDim2.new(0, 0, 0, 40) or
		RecipesOpen == "Open" 	and UDim2.new(0, 0, 0, 40),
		
		D,S,T
	);


	--[[Inventory:TweenSize(UDim2.new(0.7,0,
		(RecipesOpen and 1) or 0.7, 
		(RecipesOpen and -40) or -35
	),D,S,T,true);
	
	RecipeFrame:TweenSize(UDim2.new(0.7,0,
		(RecipesOpen and 1) or 0.7, 
		(RecipesOpen and -40) or -35
	),D,S,T,true);]]
	
end;
RecipesButton.MouseButton1Click:connect(ToggleRecipes);

for _,Button in pairs(Action.Nav:GetChildren()) do
	Button.MouseButton1Click:connect(function()
		for _,Button2 in pairs(Action.Nav:GetChildren()) do
			Button2.Style = (Button2==Button and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
		end		
		for _,Frame in pairs(Inventory:GetChildren()) do
			Frame.Visible = Frame.Name==Button.Name;
		end
		for _,Frame in pairs(Action:GetChildren()) do
			if Frame.Name == "Craft" or Frame.Name == "Salvage" then
				Frame.Visible = Frame.Name==Button.Name;
			end
		end;
		UpdateCrafting();
		UpdateSalvage();
	end)
end

GameGUI.Inventory.Main.Weapons.Equipped.View.MouseButton1Click:connect(function()
	GameGUI.Inventory.Visible = false;
	CraftGUI.Visible = true;
end)
CraftGUI.Title.Back.MouseButton1Click:connect(function()
	GameGUI.Inventory.Visible = true;
	CraftGUI.Visible = false;
end)


