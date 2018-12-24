local GameGUI = script.Parent.Parent.Game;
local InventoryFrame = GameGUI.ViewInventory;
local Navigation = InventoryFrame.Nav;
local Main = InventoryFrame.Main;
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
	
	Weapons = Remote.GetSyncData:InvokeServer("Item");
	Effects = Remote.GetSyncData:InvokeServer("Effects");
	Animations 	= Remote.GetSyncData:InvokeServer("Animations");
	Accessories	= Remote.GetSyncData:InvokeServer("Accessories");
	Toys	= Remote.GetSyncData:InvokeServer("Toys");
	Pets 	= Remote.GetSyncData:InvokeServer("Pets");
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
		local Table = CopyTable(MyStuff[DataName]);
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
			local Data1 = CopyTable(MyStuff[Type]);
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

local GridFunctions = {
	Weapons = {
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
			Frame.Type.Text = "/e " .. ItemData.Command;
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
	local Size = (GridFunctions[Type] and GridFunctions[Type].Size) or 0.25;
	local FrameFunction = (GridFunctions[Type] and GridFunctions[Type].FrameFunction) or function()end;
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
			end;

			ScrollFrame.CanvasSize = UDim2.new(0,0,0,(Row+1)*NewFrame.AbsoluteSize.Y);
			i = i + 1;
		end;
	end
	if Main[Type]:FindFirstChild("BuyAccessory") and HasAccessory then
		Main[Type].BuyAccessory.Visible = false;
	end		
	for Index,Value in pairs(MyStuff[Type].Owned) do
		CreateFrame(Index,Value);
	end
end

GameGUI.PlayerMenu.Inventory.MouseButton1Click:connect(function()
	InventoryFrame.Title.Title.Text = _G.MenuPlayer.Name .. "'s Stuff";
	local Data = game.ReplicatedStorage.GetFullInventory:InvokeServer(_G.MenuPlayer);
	for _,Type in pairs(Stuff) do
		MyStuff[Type] = Data[Type];
	end
	SortData();
	for _,Type in pairs(Stuff) do
		CreateGrid(Type);
	end
	GameGUI.Shop.Visible = false;
	GameGUI.Inventory.Visible = false;
	InventoryFrame.Visible = true;
end)


game.ReplicatedStorage.Admin.OnClientEvent:connect(function(Func,Arg)
	if Func == "CheckInventory" then
		InventoryFrame.Title.Title.Text = "Custom Inventory";
		local Data = Arg; --game.ReplicatedStorage.GetFullInventory:InvokeServer(_G.MenuPlayer);
		for _,Type in pairs(Stuff) do
			MyStuff[Type] = Data[Type];
		end
		SortData();
		for _,Type in pairs(Stuff) do
			CreateGrid(Type);
		end
		GameGUI.Shop.Visible = false;
		GameGUI.Inventory.Visible = false;
		InventoryFrame.Visible = true;
	end
end)


InventoryFrame.Title.Close.MouseButton1Click:connect(function()
	InventoryFrame.Visible = false;
end)