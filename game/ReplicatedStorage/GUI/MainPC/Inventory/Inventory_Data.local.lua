local GameGUI = script.Parent.Parent.Game;
local InventoryFrame = GameGUI.Inventory;
local Navigation = InventoryFrame.Nav;
local Main = InventoryFrame.Main;
local CodeFrame = Main.Weapons.Equipped.Codes;
local ProcessingFrame = GameGUI.Processing;
local Remote = game.ReplicatedStorage;
local Remotes = Remote.Remotes;
local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";
local HasAccessory,CanUseAccessory = game.ReplicatedStorage.HasAccessory:InvokeServer();

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

local Update;

local Database = {
	
	Weapons 	= Remote.GetSyncData:InvokeServer("Item");
	Effects 	= Remote.GetSyncData:InvokeServer("Effects");
	Animations 	= Remote.GetSyncData:InvokeServer("Animations");
	Accessories	= Remote.GetSyncData:InvokeServer("Accessories");
	Toys		= Remote.GetSyncData:InvokeServer("Toys");
	Pets 		= Remote.GetSyncData:InvokeServer("Pets");
	Materials 	= Remote.GetSyncData:InvokeServer("Materials");
	
	Codes = Remote.GetSyncData:InvokeServer("Codes");
	Recyclable = Remote.GetSyncData:InvokeServer("Recyclable");
	SlotInfo = Remote.GetSyncData:InvokeServer("SlotInfo");
	
};
local RarityColors = Remote.GetSyncData:InvokeServer("Rarity");
local RarityOrder = {Classic=1;Common=2;Uncommon=3;Rare=4;Legendary=5;Godly=6;Victim=7;Christmas=1.5;Halloween=1.6;Ancient=6.5;};

local MyStuff = {
	Weapons = nil;
	Effects = nil;
	Animations = nil;
	Accessories = nil;
	Pets = nil;
};
local Stuff = {"Weapons","Animations","Toys","Effects","Accessories","Pets"};
local CurrentAction = "Equip";


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

local function CreateWeaponFrame(Frame,ItemName,Amount,Type)
	local ImageFrame = ((Frame:IsA("ImageLabel") or Frame:IsA("ImageButton")) and Frame) or Frame.Icon;
	if ItemName == nil then
		ImageFrame.Image = "";
		Frame.ItemName.Text = "";
		if Frame:FindFirstChild("Amount") then
			Frame.Amount.Text = "";
		end
	else
		local ItemData = Database[(Type or "Weapons")][ItemName];
		ImageFrame.Image = GetImage(ItemData.Image);
		Frame.ItemName.Text = ItemData.ItemName or ItemData.Name;
		Frame.ItemName.TextColor3 = (ItemData.Rarity and RarityColors[ItemData.Rarity]) or Color3.new(1,1,1);
		if tonumber(Amount) and Frame:FindFirstChild("Amount") then
			Frame.Amount.Text = "x" .. Amount;
		end
	end;
end;


local function SortData()
	for _,DataName in pairs(Stuff) do
		--local Table = Remote.GetData:InvokeServer(DataName);
		local Table = CopyTable(_G.PlayerData[DataName]);
		if Table ~= nil then
			table.sort(Table.Owned,function(a,b)
				return a < b; -- Attempt to compare bool with table
			end)
			MyStuff[DataName] = Table;
		end;
	end
	--pcall(function() 
		--local Data = Remote.GetData:InvokeServer("Weapons");
		local CustomTypes = {"Weapons","Pets"};
		for _,Type in pairs(CustomTypes) do
			local Data1 = CopyTable(_G.PlayerData[Type]);
			local WeaponsTable = {};
			for ItemID,Amount in pairs(Data1.Owned) do
				table.insert(WeaponsTable,{
					ItemID = ItemID;
					Amount = Amount;
				});
			end
			table.sort(WeaponsTable,function(a,b)
				-- if A is less than B, return true;
				local ID = {a.ItemID,b.ItemID};
				local Amount = {a.Amount,b.Amount};
				local Data = {Database[Type][ID[1]],Database[Type][ID[2]]};
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
	--end);
end;

local RarityIndex = {
	["Common"] = "Uncommon";
	["Uncommon"] = "Rare";
	["Rare"] = "Legendary";
};

local function UpdateEquip()
	for _,StuffName in pairs(Stuff) do
		if StuffName ~= "Weapons" and MyStuff[StuffName].Equipped then
			local EquipFrame = Main[StuffName].Equipped;
			for Index,ItemName in pairs(MyStuff[StuffName].Equipped) do
				local Slot = EquipFrame["Slot"..Index];
				if type(ItemName) == "table" then for i,v in pairs(ItemName) do print(i,v); end; end;
				Slot.Image = GetImage(Database[StuffName][ItemName].Image);
				Slot.ItemName.Text = Database[StuffName][ItemName].Name;
				Slot.MouseButton1Click:connect(function()
					if Database.SlotInfo[StuffName] and Database.SlotInfo[StuffName].Unequip then
						table.remove(_G.PlayerData[StuffName].Equipped,Index);
						Update();
						Remotes.Inventory.Unequip:FireServer(Index,StuffName);
					end
				end)
			end;
		else
			local EquipFrame = Main.Weapons.Equipped;
			for Type,Value in pairs(MyStuff.Weapons.Equipped) do
				local ItemData = Database.Weapons[Value];
				EquipFrame[Type].Icon.Image = GetImage(ItemData.Image);
				EquipFrame[Type].ItemName.Text = ItemData.ItemName;
				EquipFrame[Type].ItemName.TextColor3 = RarityColors[ItemData.Rarity];
			end
		end;
	end
end

local function Equip(Type,ItemName)
	for _,Item in pairs(MyStuff[Type].Equipped) do if Item == ItemName then return end; end;
	table.insert(MyStuff[Type].Equipped,1,ItemName);
	local EquippedAmount = #MyStuff[Type].Equipped;
	if EquippedAmount > MyStuff[Type].Slots then
		table.remove(MyStuff[Type].Equipped,EquippedAmount);
	end
	UpdateEquip();
	Remote.Equip:FireServer(ItemName,Type);
end


local function WeaponAction(ItemID,Amount,ItemData,RightClick)
	if CurrentAction == "Equip" then
		if ItemData.ItemType ~= "Misc" then
			MyStuff.Weapons.Equipped[ItemData.ItemType] = ItemID;
			UpdateEquip();
			Remote.Equip:FireServer(ItemID,"Weapons");
		end;
	end;
end

local GridFunctions = {
	Weapons = {
		Size = 0.25;
		FrameFunction = function(Frame,Index,Table)
			local ItemData = Database.Weapons[Table.ItemID];
			Frame.Icon.Image = GetImage(ItemData.Image);
			Frame.ItemName.Text = ItemData.ItemName;
 			Frame.ItemName.TextColor3 = RarityColors[ItemData.Rarity];
			Frame.Rarity.Text = ItemData.Rarity;
			Frame.Rarity.TextColor3 = RarityColors[ItemData.Rarity];
			if Table.Amount > 1 then
				Frame.Amount.Text = "x" .. Table.Amount;
			end
			Frame.MouseEnter:connect(function() Frame.Rarity.Visible = true; end);
			Frame.MouseLeave:connect(function() Frame.Rarity.Visible = false; end);
			Frame.Button.MouseButton1Click:connect(function()
				WeaponAction(Table.ItemID,Table.Amount,ItemData);
			end)
			Frame.Button.MouseButton2Click:connect(function()
				WeaponAction(Table.ItemID,Table.Amount,ItemData,true);
			end)
		end
	};
	Effects = {
		FrameFunction = function(Frame,Index,EffectName)
			local ItemData = Database.Effects[EffectName];
			Frame.Icon.Image = GetImage(ItemData.Image);
			Frame.Type.Text = ItemData.Type;
			Frame.ItemName.Text = ItemData.Name;
		end;
	};
	Animations = {
		FrameFunction = function(Frame,Index,Name)
			local ItemData = Database.Animations[Name];
			Frame.ItemName.Text = ItemData.Name;
			Frame.Icon.Image = GetImage(ItemData.Image);
		end;
	};
	Accessories = {
		FrameFunction = function(Frame,Index,Name)
			local ItemData = Database.Accessories[Name];
			Frame.ItemName.Text = ItemData.Name;
			Frame.Icon.Image = GetImage(ItemData.Image);
		end
	};
	Toys = {
		FrameFunction = function(Frame,Index,Name)
			local ItemData = Database.Toys[Name];
			Frame.ItemName.Text = ItemData.Name;
			Frame.Icon.Image = GetImage(ItemData.Image);
		end
	};
	Pets = {
		FrameFunction = function(Frame,Index,Table)
			local ItemData = Database.Pets[Table.ItemID];
			Frame.Icon.Image = GetImage(ItemData.Image);
			Frame.ItemName.Text = ItemData.Name;
 			Frame.ItemName.TextColor3 = RarityColors[ItemData.Rarity];
			Frame.Rarity.Text = ItemData.Rarity;
			Frame.Rarity.TextColor3 = RarityColors[ItemData.Rarity];
			if Table.Amount > 1 then
				Frame.Amount.Text = "x" .. Table.Amount;
			end
			Frame.MouseEnter:connect(function() Frame.Rarity.Visible = true; end);
			Frame.MouseLeave:connect(function() Frame.Rarity.Visible = false; end);
		end
	};
};

local function CreateGrid(Type)
	if MyStuff[Type] == nil then return end;
	local i = 0;
	local ScrollFrame = Main[Type].Items.ScrollFrame;
	local Container = ScrollFrame.Container;
	local Size = (GridFunctions[Type] and GridFunctions[Type].Size) or 0.2;
	local FrameFunction = (GridFunctions[Type] and GridFunctions[Type].FrameFunction) or function()end;
	
	if MyStuff[Type].Equipped and Type ~= "Weapons" then
		Main[Type].Equipped:ClearAllChildren();
		
		for Index = 1,MyStuff[Type].Slots do
			local NewSlot = script.EquipSlot:Clone();
			NewSlot.ItemName.Text = "";
			NewSlot.Position = UDim2.new(0,7+(130*(Index-1)),0.5,-60);
			NewSlot.Parent = Main[Type].Equipped;
			NewSlot.Name = "Slot"..Index;
		end
		
		local NextSlotIndex = MyStuff[Type].Slots + 1;
		if NextSlotIndex <= Database.SlotInfo[Type].Max then
			
			local NextSlot = script.EquipSlot:Clone();
			local Price = Database.SlotInfo[Type].Prices[NextSlotIndex];
			NextSlot.Locked.Visible = true;
			NextSlot.Locked.Price.Text = Price;
			NextSlot.Position = UDim2.new(0,7+(MyStuff[Type].Slots*130),0.5,-60);
			NextSlot.Parent = Main[Type].Equipped;
			NextSlot.Name = "Slot"..NextSlotIndex;

			NextSlot.MouseButton1Click:connect(function()
				if _G.PlayerData.Credits >= Price then
					_G.PlayerData.Credits = _G.PlayerData.Credits - Price;
					_G.PlayerData[Type].Slots = _G.PlayerData[Type].Slots + 1;
					script.Parent.Ching:Play();
					Update();
					game.ReplicatedStorage.UpdateDataClient:Fire();
					Remotes.Inventory.BuySlot:FireServer(Type);
				end
			end)
			
		end
	end;

	Container:ClearAllChildren();
	local function CreateFrame(Index,Value)
		if Value ~= "None" then
			local Row = math.floor(i/(1/Size)); local Column = i%(1/Size);
			local NewFrame = (Value == "GetMore" and script.GetMore:Clone()) or script.Item:Clone();
			NewFrame.Parent = Container;
			NewFrame.Size = UDim2.new(Size,0,Size,0);
			NewFrame.Position = UDim2.new(NewFrame.Size.X.Scale*Column,0,0,NewFrame.AbsoluteSize.Y*Row);
			
			if type(Value) == "string" then
				NewFrame.Name = Value;
			elseif type(Value) == "table" and Value.ItemID then
				NewFrame.Name = Value.ItemID;
			end;
			
			if Index and Value then 
				FrameFunction(NewFrame.Container,Index,Value); 
				if Type ~= "Weapons" then
					NewFrame.Container.Button.MouseButton1Click:connect(function()
						if Type == "Pets" then
							Equip(Type,Value.ItemID); 
						else
							Equip(Type,Value);
						end;
					end)
				end;
			end;
			
			if Value == "GetMore" then
				NewFrame.Container.Button.MouseButton1Click:connect(function()
					_G.Navigate(Type,0);
				end)
			end
			ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
			i = i + 1;
		end;
	end
	
	--if Type ~= "Accessories" or (Type=="Accessories" and HasAccessory) then
		
		if Main[Type]:FindFirstChild("BuyAccessory") and HasAccessory then
			Main[Type].BuyAccessory.Visible = false;
		end		
		
		for Index,Value in pairs(MyStuff[Type].Owned) do
			CreateFrame(Index,Value);
		end
		CreateFrame(nil,"GetMore");
		
	--end;
	
end

Update = function(CoinUpdate)
	if not CoinUpdate then
		SortData();
		for _,StuffName in pairs(Stuff) do
			CreateGrid(StuffName);
		end
		UpdateEquip();
	end;
end;
Update();
game.ReplicatedStorage.UpdateDataClient.Event:connect(Update);

local NewItemFrame = GameGUI.NewItem;
local LastFrame;

local ItemQueue = {};

local function ShowItem()
	local Item = ItemQueue[1];
	CreateWeaponFrame(NewItemFrame.Item,Item.ItemName,nil,Item.Type);
	NewItemFrame.Title.Text = Item.TitleText;
	if Item.LFrame then
		LastFrame = Item.LFrame;
		LastFrame.Visible = false;
	end;
	NewItemFrame.Visible = true;
end

_G.NewItem = function(ItemName,TitleText,LFrame,Type)
	
	table.insert(ItemQueue,
		{
			ItemName=ItemName,
			TitleText=(TitleText or "You Got..."),
			LFrame=LFrame,
			Type=(Type or "Weapons")
		}
	);
	
	if not NewItemFrame.Visible then
		ShowItem();
	end
	
end

game.ReplicatedStorage.ItemGift.OnClientEvent:connect(function(Prize,Type)
	GameGUI.ItemPack.Visible = false;
	GameGUI.Inventory.Visible = false;
	_G.NewItem(Prize,"You Got...",nil,Type);
end);

_G.Process = function(TitleText)
	ProcessingFrame.Title.Text = TitleText;
	spawn(function() while ProcessingFrame.Visible == true do ProcessingFrame.Spinner.Rotation = ProcessingFrame.Spinner.Rotation + 5; game:GetService("RunService").RenderStepped:wait(); end; end)
	spawn(function() while ProcessingFrame.Visible == true do wait(0.2); ProcessingFrame.Title.Text = ProcessingFrame.Title.Text .. ".";  end; end)
	ProcessingFrame.Visible = true;
end

NewItemFrame.Claim.MouseButton1Click:connect(function()
	NewItemFrame.Visible = false;
	_G.UnfinishedItem = nil;
	_G.UnfinishedType = nil;
	table.remove(ItemQueue,1);
	if ItemQueue[1] ~= nil then
		ShowItem();
	else
		if LastFrame then LastFrame.Visible = true; end;
	end;
end)


local function Redeem()
	for Code,CodeTable in pairs(Database.Codes) do
		local Match = (CodeFrame.CodeBox.Text==Code);
		if Match then
			local OwnedWeapons = _G.PlayerData.Weapons.Owned;
			if OwnedWeapons[CodeTable.Prize] then
				CodeFrame.CodeBox.Text = "Redeemed.";
				return;
			end
			if os.time() < CodeTable.Expiry then
				_G.PlayerData.Weapons.Owned[CodeTable.Prize] = (OwnedWeapons[CodeTable.Prize] and OwnedWeapons[CodeTable.Prize]+1) or 1;
				game.ReplicatedStorage.UpdateDataClient:Fire();
				_G.NewItem(CodeTable.Prize,"You Got...",InventoryFrame);
				game.ReplicatedStorage.RedeemCode:FireServer(Code);
			else
				CodeFrame.CodeBox.Text = "Code Expired :(";
			end;
			return;
			
		elseif ((string.len(CodeFrame.CodeBox.Text)==7 and string.sub(CodeFrame.CodeBox.Text,4,4) == "-") and Enum.ButtonStyle.RobloxRoundDefaultButton) then
			
			local Code = CodeFrame.CodeBox.Text;
			CodeFrame.CodeBox.Text = "Redeeming...";
			CodeFrame.Redeem.Style = Enum.ButtonStyle.RobloxRoundButton;
			
			local Text,Items = game.ReplicatedStorage.RedeemShirtCode:InvokeServer(Code);
			CodeFrame.CodeBox.Text = Text;
			
			if Items then
				
				for _,Item in pairs(Items) do
					
					if Item.Type == "Weapons" or Item.Type == "Item" or Item.Type == "Materials" or Item.Type == "Pets" then
						local OwnedType = _G.PlayerData[Item.Type].Owned;
						_G.PlayerData[Item.Type].Owned[Item.ID] = (OwnedType[Item.ID] and OwnedType[Item.ID]+1) or 1;
						_G.NewItem(Item.ID,"You Got...",InventoryFrame,Item.Type);
					else
						--table.insert(_G.PlayerData[Item.Type].Owned,Item.ID);
					end;
				end;
				game.ReplicatedStorage.UpdateDataClient:Fire();
			end;
			
		end;
	end
end

CodeFrame.CodeBox.Changed:connect(function()
	for Code,CodeTable in pairs(Database.Codes) do
		local Match = CodeFrame.CodeBox.Text==Code
		CodeFrame.Redeem.Style = (Match and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
		if Match then return end;
	end

	CodeFrame.Redeem.Style = ((string.len(CodeFrame.CodeBox.Text)==7 and string.sub(CodeFrame.CodeBox.Text,4,4) == "-") and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;
	
	
end)


CodeFrame.Redeem.MouseButton1Click:connect(Redeem);
CodeFrame.CodeBox.FocusLost:connect(function(Enter) if Enter then Redeem() end; end);
