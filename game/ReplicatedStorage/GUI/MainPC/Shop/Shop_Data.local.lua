local GameGUI = script.Parent.Parent.Game;
local ShopFrame = GameGUI.Shop;
local TitleFrame = ShopFrame.Title;
local Main = ShopFrame.Container.Main;
local Navigation = ShopFrame.Container.Nav;
local FeaturedFrame = ShopFrame.Container.Featured;
local FeaturedItems = game.ReplicatedStorage.GetSyncData:InvokeServer("Featured");

local ViewContents = Main.ViewContents
local ViewContentsInfo = ViewContents.Info;
local ViewContentsItems = ViewContents.Items.ScrollFrame.Container;
local ViewConnection = ViewContents.Info.Buy.MouseButton1Click:connect(function()end);
local _,_,HasElite = game.ReplicatedStorage.GetPlayerLevel:InvokeServer(game.Players.LocalPlayer);

local Dock = GameGUI.Dock;
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

local OpenCrate = require(script.OpenCrate);

local GridObjectFrame = script.Item;
local Items = Remote.GetSyncData:InvokeServer("Item");
local RarityColors = Remote.GetSyncData:InvokeServer("Rarity");

local Time = 0.2;
local Style = "Quad";
local Direction = "Out";

local MM2ID = 929751085;

local Database = {
	--[[Weapons = {
		Crates = Remote.GetSyncData:InvokeServer("MysteryBox");
		Bundles = Remote.GetSyncData:InvokeServer("Bundles");
	};]]
	Weapons = Remote.GetSyncData:InvokeServer("Bundles");
	Effects = Remote.GetSyncData:InvokeServer("Effects");
	Animations = Remote.GetSyncData:InvokeServer("Animations");
	Accessories = Remote.GetSyncData:InvokeServer("Accessories");
	Toys = Remote.GetSyncData:InvokeServer("Toys");
	Pets = Remote.GetSyncData:InvokeServer("Pets");
	--Recipes = Remote.GetSyncData:InvokeServer("Recipe");
};
local Crates = Remote.GetSyncData:InvokeServer("MysteryBox");

local Stuff = {"Weapons","Animations","Toys","Effects","Accessories","Pets"};
local MyStuff = {
	Weapons = nil;
	Effects = nil;
	Animations = nil;
	Accessories = nil;
	Pets = nil;
};

local function CopyTable(original) local copy = {} for k, v in pairs(original) do if type(v) == 'table' then v = CopyTable(v) end copy[k] = v end return copy end

local function CheckForItem(ItemName,DataName)
	if MyStuff[DataName].Owned[ItemName] then
		return true;
	end
	for _,Item in pairs(MyStuff[DataName].Owned) do
		if Item == ItemName then
			return true;
		end
	end
	return false;
end

for _,DataName in pairs(Stuff) do
	MyStuff[DataName] = CopyTable(_G.PlayerData[DataName]);
end

for DataName,Data in pairs(Database) do
	local NewTable = {};
	local function Sort(A,B)
		local ItemDataA = A.ItemData;
		local ItemDataB = B.ItemData;

		--[[if ItemDataA.Price == ItemDataB.Price then
			return ItemDataA.Name < ItemDataB.Name;
		end	]]	
		
		local BundleA = (ItemDataA.Price==nil);
		local BundleB = (ItemDataB.Price==nil);
		
		if ItemDataA.Price == "NotForSale" and ItemDataB.Price ~= "NotForSale" then
			return false;
		elseif ItemDataB.Price == "NotForSale" and ItemDataA.Price ~= "NotForSale" then
			return true;
		elseif BundleA and not BundleB then
			return true;
		elseif BundleB and not BundleA then
			return false;
		elseif ItemDataA.Chances and not ItemDataB.Chances then
			return true;
		elseif ItemDataB.Chances and not ItemDataA.Chances then
			return false;
		elseif ItemDataA.Price=="Elite" and ItemDataB.Price~="Elite" then
			return true;
		elseif ItemDataB.Price=="Elite" and ItemDataA.Price~="Elite" then
			return false;			
		elseif tonumber(ItemDataA.Price) and tonumber(ItemDataB.Price) then
			if ItemDataA.Gems and not ItemDataB.Gems then
				return false;
			elseif ItemDataB.Gems and not ItemDataA.Gems then
				return true;
			else 
				return ItemDataA.Price < ItemDataB.Price;
			end;
		elseif ItemDataA.Price then
			return false;
		elseif ItemDataB.Price then
			return true;
		else
			return ItemDataA.Name < ItemDataB.Name;
		end;
	end

	--if DataName ~= "Weapons" then
	for ItemID,ItemData in pairs(Data) do
		table.insert(NewTable,{
			ItemID = ItemID;
			ItemData = ItemData;
		});
	end
	for ItemID,ItemData in pairs(Crates) do
		if ItemData.Type == DataName then
			
			if ItemData.Chances then
				
				local Contents = {};
				
				for Rarity,Chance in pairs(ItemData.Chances) do
					
					if Chance>0 then
						
						for _,BData in pairs(Crates) do
							if BData.Contents and BData.Type == "Weapons" and not BData.Chances then
								for _,ItemID in pairs(BData.Contents) do
									if Items[ItemID].Rarity == Rarity then							
										table.insert(Contents,ItemID);
									end;
								end
							end;
						end
						
					end;
					
				end;
				
				ItemData.Contents = Contents;
				
			end
			
			table.insert(NewTable,{
				ItemID = ItemID;
				ItemData = ItemData;
				Type = "Crate";
			});
			
		end
	end
	--else
		--[[for Type,Data2 in pairs(Data) do
			for ItemID,ItemData in pairs(Data2) do
				if ItemData.Price or Type == "Bundles" then
					table.insert(NewTable,{
						ItemID = ItemID;
						ItemData = ItemData;
						Type = (Type=="Crates" and "Weapon Crate") or "Bundle";
					});
				end;
			end
		end
	end;]]
	table.sort(NewTable,Sort);
	Database[DataName] = {
		Sorted = NewTable;
		Original = Data;
	};

end;



local function ViewContentsClick(IsBundle,ItemData,EliteLocked,DataName,ItemID)
	if not _G.Tweening then
		_G.ViewContentsDataName = DataName;
		script.Parent.Click:Play();
		local Price;
		if IsBundle then
			local TotalPrice = 0;
			for _,Table in pairs(ItemData.Contents) do
				TotalPrice = TotalPrice + Table.Price;
			end
			Price = math.floor(TotalPrice*0.85);
		--	ViewContentsInfo.Description.Text = "Buy the bundle and save!";
			ViewContentsInfo.Chances.Visible = false;
			ViewContentsInfo.OldPrice.Text = TotalPrice;
			ViewContentsInfo.OldPrice.Size = UDim2.new(0,-ViewContentsInfo.OldPrice.TextBounds.X,0,20);
			ViewContentsInfo.OldPrice.Visible = true;
		else
			Price = ItemData.Price;
			ViewContentsInfo.Chances.Visible = true ---ItemData.Chances~=nil;
			local Chances = ItemData.Chances;

			if Chances==nil then
				Chances = {
					["Common"] = 60;
					["Uncommon"] = 25;
					["Rare"] = 10;
					["Legendary"] = 5;
				};
			end
			
			for Rarity,Chance in pairs(Chances) do
				ViewContentsInfo.Chances[Rarity].Chance.Text = Chance.."%";
			end;
			ViewContentsInfo.Chances.Godly.Visible = (Chances.Common <= 0) or (ItemData.Godly~=nil)
			
			--end;
		--	ViewContentsInfo.Description.Text = "Buy this crate and randomly receive one of these skins!";
			ViewContentsInfo.OldPrice.Visible = false;
		end;
		
		local BuyWait = false;
		ViewConnection:disconnect();
		ViewConnection = ViewContentsInfo.Buy.MouseButton1Click:connect(function()
			local EliteBuy = (EliteLocked==true and HasElite==true) or (EliteLocked==false);
			if _G.PlayerData.Credits >= Price and not BuyWait then
				BuyWait = true;
				ViewContentsInfo.Buy.Style = Enum.ButtonStyle.RobloxRoundButton;
				ViewContentsInfo.Buy.Text = "Purchased!";
				_G.PlayerData.Credits = _G.PlayerData.Credits - Price;
				if IsBundle then
					script.Parent.Ching:Play();
					for _,Table in pairs(ItemData.Contents) do
						local OwnedWeapons = _G.PlayerData.Weapons.Owned;
						local ID = Table.ItemName;
						_G.PlayerData.Weapons.Owned[ID] = (OwnedWeapons[ID] and OwnedWeapons[ID]+1) or 1;
					end
					game.ReplicatedStorage.BuyBundle:FireServer(ItemID);
				else
					if EliteBuy then
						ShopFrame.Visible = false;
						_G.Process("Unboxing");
						
						local StartTime = time();
						local OpenedItem = Remotes.Shop.OpenCrate:InvokeServer(ItemID);
						wait( 0.75-(time()-StartTime));
						--InventoryFrame.Overlay.Visible = false;
						if OpenedItem then
							OpenCrate(ItemID,OpenedItem);
						end;
					else
						ShopFrame.Visible = false;
						GameGUI.GetElite.Visible = true;
					end;
				end;
				game.ReplicatedStorage.UpdateDataClient:Fire();
				wait(1);
				ViewContentsInfo.Buy.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
				ViewContentsInfo.Buy.Text = "Buy";
				BuyWait = false;
			else
				_G.GetCredits();
			end;
		end)
		ViewContentsInfo.Price.Text = Price;
		ViewContentsInfo.Icon.Image = GetImage(ItemData.Image);
		ViewContentsInfo.Title.Text = ItemData.Name;
		
		ViewContentsItems:ClearAllChildren();
		for Index,Item in pairs(ItemData.Contents) do
			local Size = script.Content.Size.Y.Scale;
			local Row = math.floor( (Index-1) / (1/Size) ); local Column = (Index-1)%(1/Size);
			local DB = (DataName=="Weapons"and Items) or Database[DataName].Original;
			local ItemData = DB[Item] or DB[Item.ItemName];
			local ContentFrame = script.Content:Clone();
			local ContentFrameContainer = ContentFrame.Container;
			ContentFrameContainer.Icon.Image = GetImage(ItemData.Image);
			ContentFrameContainer.ItemName.Text = ItemData.ItemName or ItemData.Name;
			ContentFrameContainer.ItemName.TextColor3 = RarityColors[ItemData.Rarity];
			ContentFrame.Parent = ViewContentsItems;
			ViewContentsItems.Parent.CanvasSize = UDim2.new(0,0,0,(Row+1)*ContentFrame.AbsoluteSize.Y);
			ContentFrame.Position = UDim2.new(ContentFrame.Size.X.Scale*Column,0,0,ContentFrame.AbsoluteSize.Y*Row)
			if IsBundle then
				ContentFrameContainer.MouseEnter:connect(function() ContentFrameContainer.Buy.Visible = true; end)
				ContentFrameContainer.MouseLeave:connect(function() ContentFrameContainer.Buy.Visible = false; end)
				ContentFrameContainer.Buy.MouseButton1Click:connect(function()
					if _G.PlayerData.Credits >= Item.Price then
						script.Parent.Ching:Play();
						ContentFrameContainer.Buy.Visible = false;

						local OwnedWeapons = _G.PlayerData.Weapons.Owned;
						_G.PlayerData.Credits = _G.PlayerData.Credits - Item.Price;
						_G.PlayerData.Weapons.Owned[Item.ItemName] = (OwnedWeapons[Item.ItemName] and OwnedWeapons[Item.ItemName]+1) or 1;

						game.ReplicatedStorage.UpdateDataClient:Fire();
						game.ReplicatedStorage.Buy:FireServer(Item.ItemName,DataName);
					else
						_G.GetCredits();
					end;
				end)
				ContentFrameContainer.Price.Text = Item.Price;
				ContentFrameContainer.Price.Visible = true;
				ContentFrameContainer.CoinIcon.Visible = true;
			end
		end
		
		_G.CurrentFrame = "ViewContents";
		_G.Tweening = true;
		
		ViewContents.Position = UDim2.new(1,0,0,0)
		FeaturedFrame:TweenPosition(UDim2.new(0,-FeaturedFrame.Size.X.Offset,0,0),Direction,Style,Time);
		Main[DataName]:TweenPosition(
			UDim2.new(-1,0,0,0),
			Direction,Style,Time
		);
		ViewContents:TweenPosition(
			UDim2.new(0,0,0,0),
			Direction,Style,Time
		)

		ShopFrame:TweenSizeAndPosition(
			UDim2.new(0,550,0,415),				
			UDim2.new(0.5,-275,0.5,-207),
			Direction,Style,0.2
		);


		wait(Time);
		_G.Tweening = false;
	end;
end

for DataName,DatabaseTable in pairs(Database) do
	local Data = DatabaseTable.Sorted;
	local i = 0;
	local ScrollFrame = Main[DataName].Items.ScrollFrame;
	local InfoFrame = Main[DataName].Info;
	local Container = ScrollFrame.Container;
	local Size = GridObjectFrame.Size.Y.Scale;
	local AxisLength = math.floor(1/Size)
	
	
	
	local AbsoluteSize1;
	local AbsoluteSize2;
	local GetSizeFrame = GridObjectFrame:Clone(); 
	Container.Size = UDim2.new(1,0,1,0);
	GetSizeFrame.Parent = Container;
	AbsoluteSize1 = GetSizeFrame.AbsoluteSize.Y;
	Container.Size = UDim2.new(1,-ScrollFrame.ScrollBarThickness-1,1,0);
	AbsoluteSize2 = GetSizeFrame.AbsoluteSize.Y;
	GetSizeFrame:Destroy();
	
	local MaxRow = math.floor( (#Data) / AxisLength);
	local ScrollSize = ((MaxRow+1)*AbsoluteSize1)-1;
	local ShowScroll = (ScrollSize > ScrollFrame.AbsoluteSize.Y);
	if ShowScroll then 
		ScrollSize = (MaxRow+1)*AbsoluteSize2;
		--ShowScroll = (ScrollSize >= ScrollFrame.AbsoluteSize.Y);
	end
	Container.Size = (ShowScroll and UDim2.new(1,-ScrollFrame.ScrollBarThickness-1,1,0)) or UDim2.new(1,0,1,0);
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,ScrollSize);
	--[[
	
	Container:ClearAllChildren();
	--print(ScrollSize);]]
	

	local function CreateFrame(Index,ItemTable)
		local Row = math.floor(i/AxisLength); local Column = i%AxisLength;
		local NewFrame = GridObjectFrame:Clone();
		local FrameContainer = NewFrame.Container;
		local ItemID = ItemTable.ItemID; local ItemData = ItemTable.ItemData;
		NewFrame.Parent = Container;
		NewFrame.Size = UDim2.new(Size,0,Size,0);
		NewFrame.Position = UDim2.new(NewFrame.Size.X.Scale*Column,0,0,NewFrame.AbsoluteSize.Y*Row);
		FrameContainer.Icon.Image = GetImage(ItemData.Image);
		FrameContainer.ItemName.Text = ItemData.Name;
		if ItemData.Rarity then
			FrameContainer.ItemName.TextColor3 = RarityColors[ItemData.Rarity]
		end
		InfoFrame.Type.Text = ItemTable.Type or ItemData.Type or ItemData.Name;
		
		for _,FT in pairs(FeaturedItems.HotItems) do
			if FT.Name == ItemID and FT.New then
				FrameContainer.New.Visible = true;
			end
		end
		
		local EliteLocked = false;
		if ItemTable.Type == "Crate" then
			local ReleaseTime = ItemData.Released;
			if os.time()-ReleaseTime < 86400 then
				EliteLocked = true;
			end
		end;
		
		
		FrameContainer.CoinIcon.Visible = (ItemData.Price~=nil and not ItemData.Gems);
		FrameContainer.GemsIcon.Visible = (ItemData.Price~=nil and ItemData.Gems);		
		
		if ItemData.Price and not CheckForItem(ItemID,DataName) then
			if ItemData.Price == "Elite" or EliteLocked then
				FrameContainer.Price.Visible = false;
				FrameContainer.CoinIcon.Visible = false;
				FrameContainer.GemsIcon.Visible = false;
				FrameContainer.Elite.Visible = true;
				FrameContainer.Owned.TextColor3 = FrameContainer.Elite.TextColor3;
			else
				FrameContainer.Price.Text = ItemData.Price;
			end;
		else
			FrameContainer.Price.Visible = false;
			FrameContainer.CoinIcon.Visible = false;
			FrameContainer.GemsIcon.Visible = false;
			FrameContainer.Owned.Visible = (CheckForItem(ItemID,DataName));
			if ItemData.Price == "Elite" then
				FrameContainer.Owned.TextColor3 = FrameContainer.Elite.TextColor3;
			end
		end;
		
		local CanBuy = not CheckForItem(ItemID,DataName);
		FrameContainer.Buy.MouseButton1Click:connect(function()
			if ItemData.Price == "Elite" then
				game.ReplicatedStorage.GetElite:FireServer();
			else
				local Currency = (ItemData.Gems and "Gems") or "Credits";
				--local Credits = _G.PlayerData.Credits;
				
				local Amount = _G.PlayerData[Currency];
				if Amount >= ItemData.Price and CanBuy then
					
					CanBuy = false;
					script.Parent.Ching:Play();
					FrameContainer.Price.Visible = false;
					FrameContainer.CoinIcon.Visible = false;
					FrameContainer.GemsIcon.Visible = false;
					FrameContainer.Owned.Visible = true;
					if DataName == "Pets" then
						local OwnedWeapons = _G.PlayerData.Pets.Owned;
						_G.PlayerData.Pets.Owned[ItemID] = (OwnedWeapons[ItemID] and OwnedWeapons[ItemID]+1) or 1;
					else
						table.insert(_G.PlayerData[DataName].Owned,ItemID);
					end;
					FrameContainer.Buy.Visible = false;
					_G.PlayerData[Currency] = _G.PlayerData[Currency] - ItemData.Price;
					game.ReplicatedStorage.UpdateDataClient:Fire();
					game.ReplicatedStorage.Buy:FireServer(ItemID,DataName);

				else
					if Currency == "Gems" then
						_G.GetGems();
					else
						_G.GetCredits();
					end;
				end;
			end;
		end)
		
		FrameContainer.MouseEnter:connect(function()
			
			InfoFrame.Title.Text = ItemData.Name;
			InfoFrame.Icon.Image = GetImage(ItemData.Image);
			InfoFrame.Type.Text = (ItemTable.Type) or (ItemData.Type) or ItemData.Name;
			
			if ItemData.Description then
				InfoFrame.Description.Text = ItemData.Description;
			end
			
			if InfoFrame:FindFirstChild("Contents") and InfoFrame:FindFirstChild("Contains") then
				InfoFrame.Contents.Visible = (ItemData.Contents~=nil);
				InfoFrame.Contains.Visible = (ItemData.Contents~=nil);
			end;
			
			if ItemData.Contents or ItemData.Chances then
				for _,F in pairs(InfoFrame.Contents:GetChildren()) do F.Visible = false; end;
				InfoFrame.Contents.Visible = (ItemData.Chances==nil);
				InfoFrame.Contains.Visible = (ItemData.Chances==nil);
				if not ItemData.Chances then
					InfoFrame.Contents.Pink.Visible = (ItemData.Godly);
					for Index,Item in pairs(ItemData.Contents) do
						local DB = (DataName=="Weapons"and Items) or Database[DataName].Original;
						local ItemData = DB[Item] or DB[Item.ItemName];
						local Frame = InfoFrame.Contents["Weapon"..Index];
						Frame.Icon.Image = GetImage(ItemData.Image);
						Frame.Rarity.BackgroundColor3 = RarityColors[ItemData.Rarity];
						Frame.Visible = true;
						--Frame.ItemName.Text = ItemData.ItemName;);
						--Frame.ItemName.TextColor3 = RarityColors[ItemData.Rarity];
					end;
				end;	
			else
				FrameContainer.Buy.Visible = CanBuy;
			end;
		end)
		
		FrameContainer.MouseLeave:connect(function()
			FrameContainer.Buy.Visible = false;
		end)
		
		local IsBundle = (DataName == "Weapons" and ItemTable.Type~="Crate");
		local IsCrate = (ItemTable.Type=="Crate");		
		
		if (IsBundle or IsCrate) then
			FrameContainer.Button.MouseButton1Click:connect(function()
				ViewContentsClick(IsBundle,ItemData,EliteLocked,DataName,ItemID)
			end)
		end;
		
		
		--- Test
		i = i + 1;
	end
		
	if DataName ~= "Weapons" then
		for Index,Value in pairs(Data) do
			if Value.ItemData.Price ~= "NotForSale" then
				CreateFrame(Index,Value);
			end
		end;
	else
		for Index,Value in pairs(Data) do
			CreateFrame(Index,Value);
		end
	end;

end

if _G.UnfinishedItem ~= nil then
	_G.NewItem(_G.UnfinishedItem,"You unboxed...",GameGUI.Inventory,_G.UnfinishedType);
end



-- Featured
FeaturedFrame.Cover.Image = FeaturedItems.Cover;

if FeaturedItems.CoverID then
	FeaturedFrame.Cover.Button.MouseButton1Click:connect(function()
		game.ReplicatedStorage.GetPack:FireServer(FeaturedItems.CoverID);
	end)
end

for i = 1,4 do
	local HotItem = FeaturedItems.HotItems[i];
	local Frame = FeaturedFrame.HotItems["Item"..i];
	if HotItem then
		local HotID = HotItem.Name;
		local DataName = HotItem.Type;
		local HotType = HotItem.Type;
		local IsNew = HotItem.New;
		local HotItemData;
		
		if HotType == "Item" then
			HotItemData = Items[HotID];
		else
			for _,ItemTable in pairs(Database[HotType].Sorted) do
				if ItemTable.ItemID == HotID then
					HotItemData = ItemTable.ItemData;
					HotType = ItemTable.Type or HotType;
				end
			end;
		end;
		
		--local HotItemData = Database[HotType].Original[HotID];
		
		local HotFrame = Frame.Container;
		
		local Price = (HotItemData.Price and HotItemData.Price~="NotForSale" and HotItemData.Price) or nil;		
		
		HotFrame.Icon.Image = GetImage(HotItemData.Image);
		HotFrame.ItemName.Text = HotItemData.Name or HotItemData.ItemName or"";
		HotFrame.ItemName.TextColor3 = RarityColors[HotItemData.Rarity] or Color3.new(1,1,1);
		HotFrame.Price.Text = Price or "";
		HotFrame.CoinIcon.Visible = (Price~=nil and not HotItemData.Gems);
		HotFrame.GemsIcon.Visible = (Price~=nil and HotItemData.Gems);
		
		
		HotFrame.New.Visible = IsNew or false;
		
		local EliteLocked = false;
		if HotType == "Crate" then local ReleaseTime = HotItemData.Released; if os.time()-ReleaseTime < 86400 then EliteLocked = true; end end;
		
		HotFrame.Button.MouseButton1Click:connect(function()
			if HotType=="Bundle"or HotType=="Crate"then
				ViewContentsClick(HotType=="Bundle",HotItemData,EliteLocked,DataName,HotID);
			elseif HotItem.PackID then
				game.ReplicatedStorage.GetPack:FireServer(HotItem.PackID); -- ClockworkPack
			else
				_G.Navigate(DataName)
			end;
		end)
		
	else
		Frame.Visible = false;
	end;
end






