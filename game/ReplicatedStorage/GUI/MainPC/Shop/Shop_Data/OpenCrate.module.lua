local GameGUI = script.Parent.Parent.Parent.Game;
local Remote = game.ReplicatedStorage;
local Boxes = Remote.GetSyncData:InvokeServer("MysteryBox");
local RarityColor = Remote.GetSyncData:InvokeServer("Rarity");
local Items = Remote.GetSyncData:InvokeServer("Item");
local Pets = Remote.GetSyncData:InvokeServer("Pets");

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

return function(CrateName,RewardItem)
	_G.UnfinishedItem = RewardItem;
	_G.UnfinishedType = Boxes[CrateName].Type;
	local CrateSelect = GameGUI.CaseOpen.ItemContainer;
	local CrateFinished = GameGUI.CaseComplete;
	GameGUI.Shop.Visible = false;
	CrateSelect:ClearAllChildren();
	local Contents = Boxes[CrateName]["Contents"];
	local ItemsDB = (Boxes[CrateName].Type=="Weapons" and Items) or Pets;
	local Destination = 20;
	local RewardData = ItemsDB[RewardItem];
	local LastItemFrame;
	for i = 1,Destination+3 do
		
		local ItemRarity;
		local Item;
		
		if not Boxes[CrateName].Chances then
			
			local Rarity = math.random(1,100);
			if Rarity >= 1 and Rarity <= 60 then
				ItemRarity = "Common";
			elseif Rarity > 60 and Rarity <= 85 then
				ItemRarity = "Uncommon";
			elseif Rarity > 80 and Rarity <= 95 then
				ItemRarity  = "Rare";
			else
				ItemRarity = "Legendary";
			end
			local ItemTable = {
				["Common"] = {};
				["Uncommon"] = {};
				["Rare"] = {};
				["Legendary"] = {};
				["Godly"] = {Boxes[CrateName]["Godly"]};
			};
			for _,ItemName in pairs(Contents) do
				table.insert(ItemTable[ItemsDB[ItemName]["Rarity"]],ItemName);
			end
			
			Item = ItemsDB[ ItemTable[ItemRarity][math.random(1,#ItemTable[ItemRarity])] ];
			
			if (math.random(1,500) == 1) then
				ItemRarity = "Godly"; -- Godly
				Item = ItemsDB[Boxes[CrateName]["Godly"]];
			end;
			
		else
			local Chances = Boxes[CrateName].Chances;
			local ItemTable = {};	
				
			for Rarity,Chance in pairs(Chances) do
				if Chance >= 0 then
					ItemTable[Rarity] = {};
					for _,BData in pairs(Boxes) do
						if BData.Contents and BData.Type == "Weapons" then
							for _,ItemID in pairs(BData.Contents) do
								local ItemD = ItemsDB[ItemID];
								if ItemD.Rarity == Rarity then
									table.insert(ItemTable[Rarity],ItemID);
								end;
							end;
	
						end;
					end;
				end;				
			end;
			
			local Roll = math.random(1,100);
			
			local ChanceTable = {};
			for Rarity,Chance in pairs(Chances) do
				for i = 1,Chance do 
					table.insert(ChanceTable,Rarity);
				end
			end;
			
			ItemRarity = ChanceTable[math.random(1,#ChanceTable)];
			ChanceTable = {};
			Item =  ItemsDB[ ItemTable[ItemRarity][math.random(1,#ItemTable[ItemRarity])] ] ;


			if Chances.Common <= 0 then
				if (math.random(1,500) == 1) then
					ItemRarity = "Godly"; -- Godly
					local Godlies = {};
					for _,BData in pairs(Boxes) do
						if BData.Type == "Weapons" and BData.Godly then
							table.insert(Godlies,BData.Godly);
						end
					end
					Item =  ItemsDB[ Godlies[math.random(1,#Godlies)] ];
				end;
			end;

			--[[for Rarity,Chance in pairs(Chances) do
				if Roll <= Chance then
					ItemRarity = Rarity;
				end
			end;]]
			
		end;		
				
		
		if i == Destination then
			Item = ItemsDB[RewardItem];
			ItemRarity = Item["Rarity"];
		end	
		
		local NewFrame = script.Item:Clone();
		NewFrame.Parent = CrateSelect;
		NewFrame.Position = UDim2.new(0,NewFrame.AbsoluteSize.X*(i-1)-(NewFrame.AbsoluteSize.X/2),0.5,-NewFrame.AbsoluteSize.Y/2);
		local NameText = (Boxes[CrateName].Type=="Weapons" and "ItemName") or "Name";
		NewFrame.ItemName.Text = Item[NameText];
		NewFrame.ItemName.TextColor3 = RarityColor[ItemRarity];
		--NewFrame.BorderColor3 = RarityColor[ItemRarity];
		NewFrame.Image = GetImage(Item["Image"]);
		LastItemFrame = NewFrame;
	end	 
	
	--script.Parent.ViewFrame:Fire("CrateSelect");	
	CrateSelect.Position = UDim2.new(0.5,0,0,0);
	GameGUI.Processing.Visible = false;
	CrateSelect.Parent.Visible = true;
	
	
	local CurrentX = 0;
	local FinishX = (Destination-1)*LastItemFrame.AbsoluteSize.X;
	local MaxSpeed = 10;
	local Speed = MaxSpeed;
	local OffsetX = math.random(-(LastItemFrame.AbsoluteSize.X/2),LastItemFrame.AbsoluteSize.X/2);
	FinishX = FinishX + OffsetX;
	local SlowdownPoint = FinishX - LastItemFrame.AbsoluteSize.X*2;
	local LastFrame = 0;
	
	--CrateSelect.Position = UDim2.new(0.5,-(LastItemFrame.AbsoluteSize.X/2),0,0);
	
	wait(0.25);	
	
	
	while CurrentX < FinishX do
		local Start = CurrentX - SlowdownPoint
		local End = FinishX - SlowdownPoint - (LastItemFrame.AbsoluteSize.X/2);
		
		if CurrentX >= SlowdownPoint then
			local Multiplier = Start/End;
			Speed = MaxSpeed * (1 - Multiplier);
			if Speed < 1 then
				Speed = 1;
			end
		end
		
		CrateSelect.Position = UDim2.new(0.5,(CrateSelect.Position.X.Offset-Speed),0,0);
		--[[for _,Frame in pairs(CrateSelect:GetChildren()) do
			Frame.Position = UDim2.new(0.5,Frame.Position.X.Offset-Speed,0.05,0);
		end]]
		CurrentX = CurrentX + Speed;
		if Speed >= 5 then
			game:GetService("RunService").Stepped:wait();
		else
			wait();
		end;
	end
	wait(1.25);
	
	GameGUI.CaseOpen.Visible = false;
	_G.NewItem(RewardItem,"You Unboxed...",GameGUI.Inventory,Boxes[CrateName].Type);

	game.ReplicatedStorage.CrateComplete:FireServer();
end