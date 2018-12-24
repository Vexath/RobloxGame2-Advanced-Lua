local Module = {};
local DataStoreService = game:GetService("DataStoreService")

local DataStores = {
	["Credits"] 		= DataStoreService:GetDataStore("Credits");
	["XP"] 				= DataStoreService:GetDataStore("XP2");
	["Inventory"]		= DataStoreService:GetDataStore("Inventory2");
	["KnifeEquipped"] 	= DataStoreService:GetDataStore("KnifeEquipped2");
	["GunEquipped"] 	= DataStoreService:GetDataStore("GunEquipped2");
	["CoinBag"] 		= DataStoreService:GetDataStore("5Bag");
	["ItemsConverted"] 	= DataStoreService:GetDataStore("ItemsConverted");
}

local DataDefaults = {
	["Credits"] 		= 0;
	["Gems"] 			= 0;
	["XP"] 				= 0;
	
	["CoinBag"]			= 0;
	["Prestige"] 		= 0;
	["ItemsConverted"] 	= false;
	
	["GameMode2"] = nil;
	["Gift"] = 0;
	
	["AccessorySongs"] = {};
	["Accessories"] = {
		["Owned"] = {"Default"};
		["Equipped"] = {"Default"};
		["Slots"] = 1;
		["Converted"] = true;
	};	
	["Animations"] = {
		["Owned"] = {"Default"};
		["Equipped"] = {"Default"};
		["Slots"] = 1;
		["Converted"] = true;
	};
	
	["Toys"] = {
		["Owned"] = {};
		["Equipped"] = {};
		["Slots"] = 1;
		["Converted"] = true;
		["Reset"] = true;
	};
	
	["Pets"] = {
		["Owned"] = {};
		["Equipped"] = {};
		["Slots"] = 1;
		["Converted"] = true;
	};
	
	["Effects"] = {
		["Owned"] = {};
		["Equipped"] = {};
		["Slots"] = 1;
		["Converted"] = true;
	};
	
	["Weapons"] = {
		["Owned"] = {
			["DefaultPillow"] = 1;
		};
		["Equipped"] = {
			["Knife"] = "DefaultPillow";
		};
		["Slots"] = 1;
		["Converted"] = false;
	};
	
	["Materials"] = {
		["Owned"] = {};
	};
	
	["ItemPacks"] = {};
	["PlayerPoints"] = false;
	["PetName"] = "";
	
	["PendingMerch"] = {};
	
	["SantaTutorial"] = false;
	
	--[[["PetSkins"] = {
		["Owned"] = {};
		["Equipped"] = {};
	};]]
	--[[["Inventory"] 		= {
		["DefaultPillow"] = 1;
	};
	["KnifeEquipped"] 	= "DefaultPillow";
]]
};

local LevelCap = 82500 -- level 100;


local function GetSyncData(DataType)
	return game.ReplicatedStorage.GetSyncDataServer:Invoke(DataType);
end

local PurchaseData = DataStoreService:GetDataStore("GameData");

local DataTable = {};

_G.AdminPlayers = {
	["Rainbowlocks13"] = true;
	["selvius13"] = true;
}

_G.ElitePlayers = {
	["Rainbowlocks13"] = true; 
	["Player2"] = true;
};

_G.AccessoryPlayers ={
		["Rainbowlocks13"] = true;
};

local function PlayerIsElite(Player)
	local IsElite = ( Player and (_G.ElitePlayers[Player.Name] or _G.ElitePlayers[Player.userId] )) or false;
	return IsElite;
end
local function PlayerIsAdmin(Player)
	local IsAdmin = (Player and (_G.AdminPlayers[Player.Name] or _G.AdminPlayers[Player.userId] )) or false;
	return IsAdmin
end

function game.ReplicatedStorage.AmElite.OnServerInvoke(Player) return PlayerIsElite(Player) end;
_G.CheckElite = PlayerIsElite;

_G.CheckAccessory = function (Player)
	local HasAccessory = true
	local CanUse = true;
	return HasAccessory,CanUse
end

function game.ReplicatedStorage.HasAccessory.OnServerInvoke(Player)
	return _G.CheckAccessory(Player);
end

local function RewardElite(Player)
	local Rewards = GetSyncData("EliteRewards");
	local Rewarded = false;
	for DataName,RewardData in pairs(Rewards) do
		if (not DataTable[Player.Name][DataName]) then
			if RewardData.Type == "Weapon" or RewardData.Type == "Pets" then
				local Type = (RewardData.Type=="Pets" and "Pets") or nil;
				Module.GiveItem(Player,RewardData.Reward,1,Type);
				game.ReplicatedStorage.ItemGift:FireClient(Player,RewardData.Reward,Type);
			else
				Module.GiveOther(Player,RewardData.Reward,RewardData.Type);
			end;
			DataTable[Player.Name][DataName] = true;
			Rewarded = true;
		end
	end
	if Rewarded then
		Module.SaveData(Player);
	end
end

_G.RemoveAccessory = function(Player)
	local Torso
	if Player.Character ~= nil then
		if Player.Character:FindFirstChild("Torso") then
			Torso = Player.Character.Torso
		end
		if Player.Character:FindFirstChild("UpperTorso") then
			Torso = Player.Character.UpperTorso
		end
	
		if Torso:FindFirstChild("StoreAccessory") then Torso.StoreAccessory:Destroy(); end;
	
	
		if Player.Character:FindFirstChild("StoreAccessory") then
			Player.Character.StoreAccessory:Destroy()
		end
	end
end

_G.WeldAccessory = function(Player)
	local Torso;
	local PlayerName;
	if Player:IsA("Player") then
		PlayerName = Player.Name;
		if Player.Character ~= nil then
			if Player.Character:FindFirstChild("Torso") then
				Torso = Player.Character.Torso;
			end
			if Player.Character:FindFirstChild("UpperTorso") then
				Torso = Player.Character.UpperTorso
			end
		end
	elseif Player:FindFirstChild("Torso") then
		Torso = Player.Torso;
		Player = game.Players:GetPlayerFromCharacter(Player)
		PlayerName = Player.Name;
	end;
	local Has,Use = _G.CheckAccessory(Player)
	_G.RemoveAccessory(Player)
	if Torso and Has and Use then
		if Torso.Parent:FindFirstChild("Accessory") then Torso.Parent.Accessory:Destroy(); end;
		local AccessoryID = DataTable[PlayerName].Accessories.Equipped[1];
		local AccessoryData = GetSyncData("Accessories")[AccessoryID];
		local AccessoryName = (AccessoryData["Name"])
		--default radio--
		if AccessoryData["ItemID"] == 336413959 then
			local Accessory = game.ServerStorage.Default.Accessory:Clone();
			pcall(function() Accessory = game.InsertService:LoadAsset(AccessoryData["ItemID"]):GetChildren()[1]; end);
			local OS = AccessoryData.Offset;
			local RN = AccessoryData.Rotation;
			Accessory.Anchored = false;
			Accessory.CanCollide = false;
			Accessory.Name = "StoreAccessory";
			local Weld = Instance.new("Weld",Torso);
			Weld.Part0 = Torso;
			Weld.Part1 = Accessory;
			Weld.C0 = CFrame.new(OS.X,OS.Y,OS.Z) * CFrame.Angles(RN.X,RN.Y,RN.Z);
			Accessory.Parent = Player.Character;
		
			if Accessory:FindFirstChild("Sound") then
				Accessory.Sound:Destroy();
			end
		
			game.ServerStorage.Sound:Clone().Parent = Accessory;
		
		elseif game.ServerStorage.Assets.Accessories:FindFirstChild(AccessoryName) then
				local StoreAccessory = game.ServerStorage.Assets.Accessories:FindFirstChild(AccessoryName):Clone()
				StoreAccessory.Name = "StoreAccessory"
				Player.Character.Humanoid:AddAccessory(StoreAccessory)
		end
	
		
	end;
end

_G.RemovePet = function(Player)
	if Player.Character:FindFirstChild("Pet") then Player.Character.Pet:Destroy(); end;
end

_G.GivePet = function(Player)
	if Player.Character:FindFirstChild("Pet") then Player.Character.Pet:Destroy(); end;
	local PetID = DataTable[Player.Name].Pets.Equipped[1];
	if not PetID then return; end;
	
	local PetData = GetSyncData("Pets")[PetID];
	
	if not game.ReplicatedStorage.Pets:FindFirstChild(PetID) then
		pcall(function()
			local PetTorso = game.InsertService:LoadAsset(PetData["TorsoID"]):GetChildren()[1];
			PetTorso.Name = PetID;	
			PetTorso.Parent = game.ReplicatedStorage.Pets;
		end);
	end;
	
	local NewPet = Instance.new("StringValue");
	NewPet.Name = "Pet";
	NewPet.Value = PetID;
	
	local PetName = Instance.new("StringValue");
	PetName.Name = "PetName";
	
	local FilteredPetName;
	pcall(function() FilteredPetName = game:GetService("Chat"):FilterStringForBroadcast(DataTable[Player.Name].PetName,Player) end);
	
	PetName.Value = FilteredPetName or "";
	PetName.Parent = NewPet;

	if PetData.Type == "Walking" then
		local Walking = Instance.new("Model");
		Walking.Name = "Walking";
		Walking.Parent = NewPet;
	end;
	
	NewPet.Parent = Player.Character;
	for _,Part in pairs(Player.Character:GetChildren()) do
		if Part.Name == "Pet" and Part ~= NewPet then
			Part:Destroy();
		end
	end

	
	--[[local NewPet = Instance.new("Model");
	PetTorso.Name = "Body";
	PetTorso.Anchored = true;
	NewPet.Parent = Player.Character;
	local NameTag = game.ServerStorage.Pet.NameTag:Clone();
	NameTag.Parent = PetTorso;
	
	local Script = game.ServerStorage.Pet[PetData.Type]:Clone();
	Script.Parent = NewPet;
	
	spawn(function()
		repeat wait(); until Player.Character and Player.Character:FindFirstChild("Torso");
		wait(0.2);
		PetTorso.Parent = NewPet;
		PetTorso.CFrame = Player.Character.Torso.CFrame;
		Script.Disabled = false;
		print("Pet given");
	end);]]
end

_G.RemoveToy = function(Player)
	if Player.Backpack:FindFirstChild("Toy") then
		Player.Backpack.Toy:Destroy()
	end
	if Player.Character:FindFirstChild("Toy") then
		Player.Character.Toy:Destroy()
	end
end

_G.GiveToy = function(Player)
	if not Player:FindFirstChild("Backpack") then return; end;
	local Toys = GetSyncData("Toys");
	local FakeTool = Instance.new("Tool",Player.Backpack);
	FakeTool.Name = "Loading Toys...";
	for _,Toy in pairs(DataTable[Player.Name].Toys.Equipped) do
		if Player.Backpack:FindFirstChild("Toy") then
			Player.Backpack.Toy:Destroy()
		end
		if Player.Character:FindFirstChild("Toy") then
			Player.Character.Toy:Destroy()
		end
		local NewToy = Instance.new("Tool");
		pcall(function() NewToy = game.InsertService:LoadAsset(Toys[Toy].ItemID):GetChildren()[1]; end);
		if NewToy then
			NewToy.CanBeDropped = false;
			NewToy.Parent = Player.Backpack;
			NewToy.Name = "Toy"
		end;
	end;
	FakeTool:Destroy();
end

_G.GiveAnimation = function(Player)
	if not Player:FindFirstChild("Backpack") then return; end;
	if not Player.Character:FindFirstChild("Humanoid") then return; end;
	--only works for r15--
	if Player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then return; end;
	local EquippedAnimation = DataTable[Player.Name].Animations.Equipped[1];
	local AnimationData = GetSyncData("Animations")[EquippedAnimation];
	local AnimationName = AnimationData.Name
	
	if Player.Character:FindFirstChild("Animate") then
		Player.Character.Animate:Destroy()
	end
	
	local AnimationPacks = game.ServerStorage.Assets.AnimationPacks
	
	if AnimationPacks:FindFirstChild(AnimationName) then
		local newAnimation = AnimationPacks:FindFirstChild(AnimationName):FindFirstChild("Animate"):Clone()
		newAnimation.Name = ("Animate")
		newAnimation.Parent = Player.Character
		print("New Animation Parented to Chr")
	end
	--just in case--
	if not Player.Character:FindFirstChild("Animate") then
		local newAnimation = AnimationPacks.Default:GetChildren():Clone()
		newAnimation.Name = ("Animate")
		newAnimation.Parent = Player.Character
	end
end

game:GetService("MarketplaceService").PromptPurchaseFinished:connect(function(Player, AssetID, IsPurchased)
	
	
	
	if IsPurchased and AssetID == 5496022 then
		
		_G.ElitePlayers[Player.userId] = true;
		RewardElite(Player);	
		
	elseif IsPurchased then
		
		for PassID,Pack in pairs(GetSyncData("ItemPacks")) do
			if tonumber(PassID) == AssetID then
				DataTable[Player.Name].ItemPacks[PassID] = true;
				for _,Item in pairs(Pack) do
					if Item.Type == "Weapons" or Item.Type == "Pets" then
						Module.GiveItem(Player,Item.ItemName,1,Item.Type);
						game.ReplicatedStorage.ItemGift:FireClient(Player,Item.ItemName,Item.Type);
					else
						Module.GiveOther(Player,Item.ItemName,Item.Type);
					end;
				end;
				Module.SaveData(Player);
				break;
			end;
		end;
		
	end;
	
end)

game.ReplicatedStorage.GetElite.OnServerEvent:connect(function(Player)
	game:GetService("MarketplaceService"):PromptPurchase(Player,5496022)
end)

game.ReplicatedStorage.GetAccessory.OnServerEvent:connect(function(Player)
	_G.RadioPlayers[Player.Name] = true;
	if _G.CheckRadio(Player) then
		_G.WeldRadio(Player);
	end;
	game.ReplicatedStorage.GetRadio:FireClient();
end)

game.ReplicatedStorage.GetPack.OnServerEvent:connect(function(Player,PackID)
	game:GetService("MarketplaceService"):PromptPurchase(Player,PackID)
end)

math.randomseed( os.time() )
math.random();

Module.GetLevel = function(XP)
	if XP ~= nil then
		return math.floor((25 + math.sqrt(625 + 300 * XP))/50);
	else
		return 1;
	end;
end 

local OldProfiles = game:GetService("DataStoreService"):GetDataStore("old405");
local Profiles = game:GetService("DataStoreService"):GetDataStore("new405");
local MerchDataStore = game:GetService("DataStoreService"):GetDataStore("merch405");

local DuperList = game:GetService("DataStoreService"):GetDataStore("duperlist405");

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


local function deepcopy(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        copy[k] = v
    end
    return copy
end

local ServerID = game.JobId;

Module.SetData = function(Player)
	
	local OldProfile;
	local Profile;
	local PendingMerchCodes;
	
	
	print("Loading data for " .. Player.Name);
	local DataCallSuccess = pcall(function()
		
		OldProfile = OldProfiles:GetAsync(Player.userId);
		Profile = Profiles:UpdateAsync(Player.userId, function(Data)
			if Data then Data.ServerID = ServerID; end;
			return Data;
		end)
		
		PendingMerchCodes = MerchDataStore:GetAsync(Player.userId);
	end)
	
	if not DataCallSuccess then
		repeat
			print(Player.Name.."'s Data not loaded, retrying...");
			wait(5)
			DataCallSuccess = pcall(function()
				OldProfile = OldProfiles:GetAsync(Player.userId);
				Profile = Profiles:UpdateAsync(Player.userId, function(Data)
					if Data then Data.ServerID = ServerID; end;
					return Data;
				end)
			end)
		until DataCallSuccess;
	else
		print(Player.Name.."'s Data successfully loaded.");
	end;
	
	
	local MultiKick = false;
	local OUCon;
	
	--[[OUCon = Profiles:OnUpdate(Player.userId,function(Data) 
		if Data.ServerID and Data.ServerID ~= ServerID then
			Player:Kick("You have logged in on another device.");
			MultiKick = true;
			OUCon:disconnect();
		end
	end)]]
	
	if MultiKick then
		return;
	end
	
	if Profile == nil or Profile == "Wiped" then
		DataTable[Player.Name] = {};
		
		if OldProfile ~= nil then -- Check for old profile
			DataTable[Player.Name]["Credits"] 			= OldProfile["Credits"];
			DataTable[Player.Name]["XP"] 				= OldProfile["XP"]
			DataTable[Player.Name]["KnifeEquipped"] 	= OldProfile["KnifeEquipped"]
			DataTable[Player.Name]["Animations"] 			= OldProfile["Animations"]
			DataTable[Player.Name]["Effects"] 			= OldProfile["Effects"]
			DataTable[Player.Name]["CoinBag"] 			= OldProfile["CoinBag"]
			DataTable[Player.Name]["Inventory"] = {};
			for _,ItemData in pairs(OldProfile["Inventory"]) do
				Module.GiveItem(Player,ItemData["ItemName"],1);
			end
		end

		for DataName,Default in pairs(DataDefaults) do
			if DataTable[Player.Name][DataName] == nil then
                if type(Default) == "table" then
					DataTable[Player.Name][DataName] = deepcopy(Default);
                else
		       		DataTable[Player.Name][DataName] = Default;
                end
			end
		end
				
		local _,Error = pcall(function() Profiles:SetAsync(Player.userId,DataTable[Player.Name]); end);
		if Error then
			print("Failed to save created profile for " .. Player.Name .. ": " .. Error);
		end

	else
		DataTable[Player.Name] = Profile;
		for DataName,Default in pairs(DataDefaults) do
			if DataTable[Player.Name][DataName] == nil then
                if type(Default) == "table" then
					DataTable[Player.Name][DataName] = deepcopy(Default);
                else
		       		DataTable[Player.Name][DataName] = Default;
                end
			end
		end
	end
	
	DataTable[Player.Name]["userId"] = Player.userId;


	-- Elite
	local Elite;
	print("[" .. Player.Name .. "] Checking Elite...");
	local _,Error = pcall(function() Elite = game:GetService("MarketplaceService"):PlayerOwnsAsset(Player,5496022) end);
	while Error do
		print("[" .. Player.Name .. "] Failed to check Elite, retrying...");
		wait(1);
		_,Error = pcall(function() Elite = game:GetService("MarketplaceService"):PlayerOwnsAsset(Player,5496022) end)
	end
	print("[" .. Player.Name .. "] Elite checked!");
	
	if Elite then
		_G.ElitePlayers[Player.userId] = true;
	end
	--------
	
	
	-- Accessory
	

	print("Attempt to Spawn Character")
	wait(3);	
	spawn(function()
		repeat Player:LoadCharacter(); wait();
		until Player.Character ~= nil;
	end)
	print("Character Spawned")
	game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
	
	game.ReplicatedStorage.PlayerAdded:FireAllClients(Player)

	wait();
	
	--Check if Admin--
	if Player.Name == "selvius13" or Player.Name == "rainbowlocks13" then
		Module.Give(Player,"Credits",20000)
		Module.Give(Player,"Gems",20000)	
	end
		
	for PassID,Pack in pairs(GetSyncData("ItemPacks")) do
		print("[" .. Player.Name .. "] Checking for: " .. PassID);
		local PackClaimed;
		for ID,_ in pairs(DataTable[Player.Name].ItemPacks) do if ID==PassID then PackClaimed = true; break; end; end;
		if not PackClaimed then
			--print("[" .. Player.Name .. "] has not been rewarded pass.");
			local HasPass;
			
			--print("[" .. Player.Name .. "] Checking for pass...");
			local _,Error = pcall(function() HasPass = game:GetService("MarketplaceService"):PlayerOwnsAsset(Player,PassID); end);
			while Error do
				print("[" .. Player.Name .. "] Error checking pass, retrying...");
				wait(0.25);
				_,Error = pcall(function() HasPass = game:GetService("MarketplaceService"):PlayerOwnsAsset(Player,PassID); end);
			end;
			--print("[" .. Player.Name .. "] pass checked!");
			
			if HasPass or Player.Name == "Player1" then
				print("[" .. Player.Name .. "] Player has pass, giving items.");
				DataTable[Player.Name].ItemPacks[PassID] = true;
				for _,Item in pairs(Pack) do
					if Item.Type == "Weapons" or Item.Type == "Pets" then
						Module.GiveItem(Player,Item.ItemName,1,Item.Type);
						game.ReplicatedStorage.ItemGift:FireClient(Player,Item.ItemName,Item.Type);
					else
						Module.GiveOther(Player,Item.ItemName,Item.Type);
					end;
				end;
				Module.SaveData(Player);
			end
		end
	end
	
	--[[local CodeDB = GetSyncData("MerchCodes");
	
	print("Checking for datastore");
	if PendingMerchCodes then
		print("Has datastore, checking codes");
		for Code,Amount in pairs(PendingMerchCodes) do
			print("Found pending codes, giving items");
			print("Code: " .. Code .. " - Amount: " .. Amount .. " - Item: " .. CodeDB[Code].Item);
			Module.GiveItem( Player, CodeDB[Code].Item, Amount);
			PendingMerchCodes[Code] = nil;
		end
		print("Saving");
		MerchDataStore:UpdateAsync(Player.userId,function()
			return PendingMerchCodes;
		end)
		print("Finished!");
	end]]

	if PlayerIsElite(Player) then
		RewardElite(Player);
	end
	
	local LeaderTable = {};
	for _,lPlayer in pairs(game.Players:GetPlayers()) do
		local Name = lPlayer.Name;
		local lData = DataTable[lPlayer.Name];
		if lData then
			table.insert(LeaderTable,{
				PlayerName = Name;
				Level = Module.GetLevel(Module.Get(lPlayer,"XP"));
				Prestige = Module.Get(lPlayer,"Prestige");
				Elite = _G.CheckElite(lPlayer);
			});			
		end
	end
	
	game.ReplicatedStorage.GiveLeaderboard:FireAllClients(LeaderTable)	
	game.ReplicatedStorage.UpdateLeaderboard:FireAllClients()
	--[[for i = 1,10 do
		if Player.Name == "Player1" then
			Module.Give(Player,"XP",1000);
		end
		wait(1);
	end;]]
end

--[[Module.GiveMerchReward = function(CallingPlayer,PlayerName,MerchCode,Amount)
	---if CallingPlayer.userId ~= 1823037 then return end;
	
	print("Getting UserID");
	local UserID;
	pcall(function()UserID=game.Players:GetUserIdFromNameAsync(PlayerName) end);
	if UserID then
		print("UserID foudn, saving");
		MerchDataStore:UpdateAsync(UserID,function(Data)
			if not Data then Data = {}; end;
			
			local Codes = Data[MerchCode];
			Data[MerchCode] = (Codes and Codes + Amount) or Amount;
			return Data;
			
		end)
		print("Saved");
		return true;
	end
	return false;
end

function game.ReplicatedStorage.M.OnServerInvoke(CallingPlayer,PlayerName,MerchCode,Amount)
	return Module.GiveMerchReward(CallingPlayer,PlayerName,MerchCode,Amount);
end]]

--game.ReplicatedStorage.M.OnServerEvent:connect(Module.GiveMerchReward)


local SavingData = {};

Module.SaveData = function(Player)
	if DataTable[Player.Name] ~= nil then	
	
		if not SavingData[Player.Name] then
			
			SavingData[Player.Name] = true;
			
			local DataCallSuccess = pcall(function()
				Profiles:UpdateAsync(Player.userId,function()
					return DataTable[Player.Name]
				end)
			end)
			
			if not DataCallSuccess then
				repeat
					print(Player.Name.."'s Data failed to save, retrying...");
					wait(5)
					DataCallSuccess = pcall(function()
						Profiles:UpdateAsync(Player.userId,function()
							return DataTable[Player.Name]
						end)
					end)
				until DataCallSuccess;
			else
				print(Player.Name.."'s Data saved successfully.");
			end;

			
			SavingData[Player.Name] = false;

		end;
		
	end
end

game.ReplicatedStorage.Save.Event:connect(Module.SaveData);

Module.Get = function(Player,DataName)
	local Output = game:GetService("TestService");
	if Player == nil then return end;

	local PlayerName = Player.Name;

	if PlayerName == nil then return nil end --Output:Error("PlayerName is nil (Get)"); return nil end;
	if DataTable[PlayerName] == nil then return nil end -- Output:Error("DataTable[" .. PlayerName .. "] is nil. (Get)"); return nil end;
	if DataTable[PlayerName][DataName] == nil then return nil end -- Output:Error("DataTable[" .. PlayerName .. "]["..DataName.."] is nil. (Get)"); return nil end;
	if DataTable[Player.Name] ~= nil then
		return DataTable[Player.Name][DataName];
	else
		return nil;
	end;
end

game.Players.PlayerRemoving:connect(function(Player)
	Module.Trade.DeclineTrade(Player)
	Module.SaveData(Player);
	
	local MinRarity = {["Godly"]=10;["Victim"]=5;["Classic"]=20};	
	for ItemID,Data in pairs(GetSyncData("Item")) do
		if Data.Rarity == "Godly" or Data.Rarity == "Victim" or Data.Rarity == "Classic" then
			local Has,Amount = CheckForItem(Player,ItemID,"Weapons");
			if Has and Amount >= MinRarity[Data.Rarity] then
				DuperList:UpdateAsync("List2",function(Value)
					Value[tostring(Player.userId)] = true;
					return Value;
				end)
				break;
			end;
		end;
	end;
	
	for ItemID,Data in pairs(GetSyncData("Pets")) do
		if Data.Rarity == "Godly" or Data.Rarity == "Victim" or Data.Rarity == "Classic" then
			local Has,Amount = CheckForItem(Player,ItemID,"Pets");
			if Has and Amount >= MinRarity[Data.Rarity] then
				DuperList:UpdateAsync("List2",function(Value)
					Value[tostring(Player.userId)] = true;
					return Value;
				end)
				break;
			end;
		end;
	end;
	
	--[[
	local LeaderTable = {};
	for _,lPlayer in pairs(game.Players:GetPlayers()) do
		local Name = lPlayer.Name;
		local lData = DataTable[lPlayer.Name];
		if lData then
			table.insert(LeaderTable,{
				PlayerName = Name;
				Level = Module.GetLevel(Module.Get(lPlayer,"XP"));
				Prestige = Module.Get(lPlayer,"Prestige");
				Elite = _G.CheckElite(lPlayer);
			});			
		end
	end
	game.ReplicatedStorage.GiveLeaderboard:FireAllClients(LeaderTable)]]
	
end)

Module.Give = function(Player,DataName,Amount)
	if DataName == "XP" then
		if string.sub(Player.Name,1,6)~="Guest " then--and Player.userId > 0 then
			local _,Error = pcall(function()
				local Badges = GetSyncData("Badge");
				local CurrentXP = Module.Get(Player,"XP");
				local CurrentLevel = Module.GetLevel(CurrentXP);
				local NextLevel = Module.GetLevel(CurrentXP + ((PlayerIsElite(Player) and Amount*1.5) or Amount) );
				if NextLevel > CurrentLevel and NextLevel%10 == 0 then
					--game.ReplicatedStorage.Chatted:FireAllClients("Server",Player.Name .. " has just reached level " .. NextLevel);
					local OldImage = require(game.ReplicatedStorage.RankIcons)[CurrentLevel];
					local NewImage = require(game.ReplicatedStorage.RankIcons)[NextLevel];
					game.ReplicatedStorage.LevelUp:FireClient(Player,OldImage,NewImage)
				end
				
				for BadgeName,BadgeID in pairs(Badges) do
					local Level = tonumber(string.sub(BadgeName,6));
					if (NextLevel >= Level) or Module.Get(Player,"Prestige") >= 1 then
						game.BadgeService:AwardBadge(Player.userId,BadgeID);
					end
				end
			end)
			if Error then
				game:GetService("TestService"):Error("Error giving badge: " .. Error,script);
			end
		end;
		
		if Module.Get(Player,DataName) + Amount > LevelCap then
			DataTable[Player.Name]["XP"] = LevelCap;
		else
			if PlayerIsElite(Player) then
				Amount = Amount*1.5;
			end
			DataTable[Player.Name]["XP"] = DataTable[Player.Name]["XP"] + Amount;
		end
		
		game.ReplicatedStorage.GiveXP:FireClient(Player,Amount)
		if Player.userId > 0 then game:GetService("PointsService"):AwardPoints(Player.userId, Amount) end;
	else
		DataTable[Player.Name][DataName] = DataTable[Player.Name][DataName] + Amount;
	end
	game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name],true);
end

function CheckForItem(Player,ItemName,Type)
	for Index,Value in pairs(DataTable[Player.Name][Type].Owned) do
		if Index == ItemName then
			return true,Value;
		end
		if Value == ItemName then
			return true,1;
		end
	end
	return false;
end
Module.CheckForItem = CheckForItem;

Module.Equip = function(Player,ItemName,Type)
	print(Type)
	print(ItemName)
	print(Player)
	if CheckForItem(Player,ItemName,Type) then
		if Type == "Weapons" then
			local ItemsDB = GetSyncData("Item") 
			local ItemType = ItemsDB[ItemName]["ItemType"]
			DataTable[Player.Name]["Weapons"]["Equipped"][ItemType] = ItemName;	
		else
			for _,Item in pairs(DataTable[Player.Name][Type].Equipped) do if Item == ItemName then return end; end;
			table.insert(DataTable[Player.Name][Type].Equipped,1,ItemName);
			local Equipped = #DataTable[Player.Name][Type].Equipped;
			if Equipped > DataTable[Player.Name][Type].Slots then
				table.remove(DataTable[Player.Name][Type].Equipped);
			end
			if Type == "Accessories" and _G.CheckAccessory(Player) then _G.WeldAccessory(Player); 
			elseif Type == "Pets" then
				_G.GivePet(Player);
			elseif Type == "Toys" then
				_G.GiveToy(Player);
			elseif Type == "Animations" then
				_G.GiveAnimation(Player);
			end;
		end;
		
		pcall(function()
			local ItemsDB = GetSyncData("Item") 
			if Player.Backpack:FindFirstChild("Weapon") then
				Player.Backpack:FindFirstChild("Weapon"):Destroy()
			end
			if Player.Character:FindFirstChild("Weapon") then
				Player.Character:FindFirstChild("Weapon"):Destroy()
			end

			local Equipped = DataTable[Player.Name]["Weapons"]["Equipped"];
			local EquippedKnife = game.ServerStorage.Default.Pillow:Clone();
			pcall(function() EquippedKnife = game.InsertService:LoadAsset(ItemsDB[Equipped.Knife]["ItemID"]):GetChildren()[1]; EquippedKnife.TextureId = ItemsDB[Equipped.Knife].Image; end);
			
			local Effects = GetSyncData("Effects");
			local EquippedEffect = DataTable[Player.Name]["Effects"].Equipped[1];
			if Effects[EquippedEffect] ~= nil then
				--try to equip effect--
				pcall(function() 
					local NewEffect = game.InsertService:LoadAsset(Effects[EquippedEffect]["KnifeModule"]):GetChildren()[1];
					NewEffect.Name = EquippedEffect
					--Welding it was a pain in the ass, just get the particle effects
					for i,v in pairs(EquippedKnife.Handle:GetChildren())do
						if v:IsA("ParticleEmitter") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
							v:Destroy()
						end
					end
					for i,v in pairs(NewEffect:GetChildren())do
						if v:IsA("ParticleEmitter") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
							local effectz = v:Clone()
							effectz.Parent = EquippedKnife.Handle
						end
					end
				end)
			end
									
			EquippedKnife.Parent = Player.Backpack
			EquippedKnife.Name = "Weapon"
			
			local KnifeName = Equipped.Knife;
			local KnifeRotation = ItemsDB[KnifeName]["Angles"] 
			local RadioRotation = ItemsDB[KnifeName]["RadioAngles"]
			local KnifePosition = ItemsDB[KnifeName]["Offset"] 
			local RadioOffset = ItemsDB[KnifeName]["RadioOffset"];
			
			
			
			local Torso;
			if Player.Character:FindFirstChild("Torso") then
				Torso = Player.Character.Torso
			end
			if Player.Character:FindFirstChild("UpperTorso") then
				Torso = Player.Character.UpperTorso
			end
			--[[
			Handle.CFrame = Torso.CFrame;
			local KnifeWeld = Instance.new("Weld",Torso);
			KnifeWeld.Part0 = Torso;
			KnifeWeld.Part1 = Handle;
			--]]
			local HasAccessory,CanUse = _G.CheckAccessory(Player)
			local UseAccessory = (HasAccessory and CanUse);	
			
			local DefaultRotation;
			local DefaultPosition;
			
			local function dAngles(Data)
				return CFrame.Angles(Data.X,Data.Y,Data.Z)
			end
			
			local function dOffset(Data)
				return CFrame.new(Data.X,Data.Y,Data.Z)
			end
		
			if not UseAccessory  then 
				DefaultRotation = 
					(KnifeRotation and dAngles(KnifeRotation)) or
					 CFrame.Angles(-math.pi/2,math.pi/4,math.pi/2);
				
				DefaultPosition = 
					(KnifeRotation and CFrame.new(0,0,0.5)) or
					 CFrame.new(-0.1,0,0.5);
				
				DefaultPosition = (KnifePosition and dOffset(KnifePosition)) or DefaultPosition;
			else
				DefaultPosition = (RadioOffset and dOffset(RadioOffset)) or CFrame.new(-1,-1.3,0.25);
				DefaultRotation = CFrame.Angles(math.rad(-60),0,math.rad(180));
				DefaultRotation = 
					(RadioOffset and dAngles(RadioRotation)	) 
				or 	(KnifeRotation and DefaultRotation * dAngles(KnifeRotation)	) 	
				or 	DefaultRotation;
			end;
			--[[
			KnifeWeld.C0 =  DefaultPosition * DefaultRotation;
			
			KnifeWeld.C1 = CFrame.new();
			Handle.Name = "KnifeDisplay";
			Handle.Parent = Player.Character;
		--]]	
		end)		
		
		game.ReplicatedStorage.UpdateData3:FireClient(Player,DataTable[Player.Name])
	end
end

Module.Unequip = function(Player,Index,Type)
	local SlotInfo = GetSyncData("SlotInfo");
	if SlotInfo[Type].Unequip then
		table.remove(DataTable[Player.Name][Type].Equipped,Index);
	end
	if Type == "Pets" then
		_G.RemovePet(Player)
	elseif Type == "Accessories" then
		_G.RemoveAccessory(Player)
	elseif Type == "Toys" then
		_G.RemoveToy(Player)
	end
end


Module.Buy = function(Player,ID,Type)
	print(Player,ID,Type);
	
	if DataTable[Player.Name] == nil then return end;
	if DataTable[Player.Name][Type] == nil then return end;
	
	local Credits = Module.Get(Player,"Credits"); if Credits == nil then return end;
	local Gems = Module.Get(Player,"Gems"); if Gems == nil then return end;
	local Database = GetSyncData(Type) or GetSyncData("Item"); if Database == nil then return; end;
	local Data = Database[ID]; if Data == nil then return end;
	
	local Price = Data.Price; if Price == nil then 
		for _,Bundle in pairs(GetSyncData("Bundles")) do
			for _,Table in pairs(Bundle.Contents) do
				if Table.ItemName == ID then
					Price = Table.Price;
					break;
				end
			end
		end;
	end;
	
	local Currency = (Data.Gems and "Gems") or "Credits";
	local Amount = (Data.Gems and Gems) or Credits;
	
	if Amount >= Price then
		if Type == "Weapons" or Type == "Pets" then
			Module.GiveItem(Player,ID,1,Type);
		else
			table.insert(DataTable[Player.Name][Type].Owned,ID);
		end;
		DataTable[Player.Name][Currency] = DataTable[Player.Name][Currency] - Price;
		game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
		wait();
		Module.SaveData(Player);
		print(Player.Name .. " has successfully purchased " .. ID);

	end;
end

Module.BuyBundle = function(Player,Bundle)
	local Bundles = GetSyncData("Bundles");
	local Price = 0;
	for _,ItemTable in pairs(Bundles[Bundle].Contents) do
		Price = Price + ItemTable["Price"];
	end
	local PlayerName = GetPlayerName(Player);
	local Credits = DataTable[PlayerName]["Credits"];
	local Price = math.floor(Price*0.85);
	if Credits >= Price then
		DataTable[PlayerName]["Credits"] = DataTable[PlayerName]["Credits"] - Price;
		for _,ItemTable in pairs(Bundles[Bundle].Contents) do
			Module.GiveItem(Player,ItemTable["ItemName"],1);
			
			--[[local _,Error = pcall(function() PurchaseData:UpdateAsync(ItemTable["ItemName"],function(Value) if Value then return Value+1; else return 1; end; end); end);
			if Error then
				print("Failed to update " .. ItemTable["ItemName"] .. ": " .. Error);
			end]]
			
		end
		game.ReplicatedStorage.UpdateData:FireClient(Player);
		
		--[[local _,Error = pcall(function() PurchaseData:UpdateAsync(Bundle,function(Value) if Value then return Value+1; else return 1; end; end); end);
		if Error then
			print("Failed to update " .. Bundle .. ": " .. Error);
		end]]
		
	end
end


function GetPlayerName(Player)
	local PlayerName;
	if type(Player) == "string" then
		PlayerName = Player;
	elseif type(Player) == "userdata" then
		PlayerName = Player.Name;
	end
	return PlayerName;
end

local function GetGifts(Player)
	local PlayerName = GetPlayerName(Player);
	local Inventory = DataTable[PlayerName]["Weapons"].Owned;
	for ItemName,ItemAmount in pairs(Inventory) do
		if ItemName == "Gift" then
			return ItemAmount;
		end
	end
	return 0;
end

local function GetCandies(Player)
	local PlayerName = GetPlayerName(Player);
	local Inventory = DataTable[PlayerName]["Weapons"].Owned;
	for ItemName,ItemAmount in pairs(Inventory) do
		if ItemName == "Candies" then
			return ItemAmount;
		end
	end
	return 0;
end

Module.GiveOther = function(Player,ID,Type,NoSave)
	if DataTable[Player.Name] == nil then return end;
	if DataTable[Player.Name][Type] == nil then return end;
	table.insert(DataTable[Player.Name][Type].Owned,ID);
	game.ReplicatedStorage.ItemGift:FireClient(Player,ID,Type);
	game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
	wait();
	--Module.SaveData(Player);
	
	--print("Updating " .. ID .. " count...");
	--[[local _,Error = pcall(function() PurchaseData:UpdateAsync(ID,function(Value) if Value then return Value+1; else return 1; end; end); end);
	if Error then
		print("Error updating " .. ID .. ": " .. Error);
	end]]
	
end

Module.GiveItem = function(Player,ItemName,Amount,Type)
	if not Type then Type = "Weapons" end;
	local PlayerName = GetPlayerName(Player);
	
	if not GetSyncData("Item")[ItemName] and not GetSyncData("Pets")[ItemName] and not GetSyncData("Materials")[ItemName] then
		print("[Error] Cannot find item: " .. ItemName);
		return;
	end
	
	if PlayerName ~= nil then
		if DataTable[PlayerName] ~= nil then
			if DataTable[PlayerName][Type] ~= nil then
				if DataTable[PlayerName][Type].Owned[ItemName] == nil then
					DataTable[PlayerName][Type].Owned[ItemName] = Amount;
				else
					DataTable[PlayerName][Type].Owned[ItemName] = DataTable[PlayerName][Type].Owned[ItemName] + Amount;
				end;
				game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[PlayerName])
			else
				print("Error: DataTable[PlayerName][DataName] == nil (GiveItem)");
			end
		else
			print("Error: DataTable[PlayerName] == nil (GiveItem)");
		end;
	else
		print("Error: PlayerName == nil (GiveItem)");
	end;
end

Module.RemoveItem = function(Player,ItemName,Amount,Type)
	if not Type then Type = "Weapons" end;
	local PlayerName = GetPlayerName(Player);
	if PlayerName ~= nil then
		if DataTable[PlayerName] ~= nil then
			if DataTable[PlayerName][Type] ~= nil then
					
				if DataTable[PlayerName][Type].Owned[ItemName] == nil then
					print("Error: Player doesn't have the item (RemoveItem)");
				elseif DataTable[PlayerName][Type].Owned[ItemName] - Amount > 0 then
					DataTable[PlayerName][Type].Owned[ItemName] = DataTable[PlayerName][Type].Owned[ItemName] - Amount;
				else
					DataTable[PlayerName][Type].Owned[ItemName] = nil;
					if DataTable[PlayerName].Weapons.Equipped.Knife == ItemName then
						DataTable[PlayerName].Weapons.Equipped.Knife = "DefaultPillow";
					elseif DataTable[PlayerName].Pets.Equipped[1] == ItemName then
						Module.Unequip(Player,1,"Pets");
					end;
					print("Error: Player has less than 0 (RemoveItem)");
				end
				game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[PlayerName])

			else
				print("Error: DataTable[PlayerName][DataName] == nil (RemoveItem)");
			end
		else
			print("Error: DataTable[PlayerName] == nil (RemoveItem)");
		end;
	else
		print("Error: PlayerName == nil (RemoveItem)");
	end;
end


-- Salvage

Module.SalvageItem = function(Player,Item)
	for _,CodeData in pairs(GetSyncData("Codes")) do if CodeData.Prize == Item then return end; end;
	if CheckForItem(Player,Item,"Weapons") then
		local ItemRarity = GetSyncData("Item")[Item].Rarity;
		local SalvageRewards = GetSyncData("SalvageRewards");
		local SalvageTable = SalvageRewards[Item] or SalvageRewards[ItemRarity];
		
		local Rewards = {};
		--local ItemCount = 1 + ((math.random(1,3)==1 and 1) or 0) + ((math.random(1,3)==1 and 1) or 0)

		local ItemCount = 0;
		for i = 1,3 do
			if math.random(1,100)<=SalvageTable.CountChance[i] then
				ItemCount = ItemCount+1;
			else
				break;
			end;
		end		
		
		
		--print("--");
		
		Module.RemoveItem(Player,Item,1);
		
		for i = 1,ItemCount do
			
			local RewardsTable = {};
			for RewardID,RewardData in pairs(SalvageTable.Rewards) do
				if RewardData.Rarity[i] then
					for i = 1,RewardData.Rarity[i] do
						table.insert(RewardsTable,RewardID);
					end;
				end;
			end
			
			
			if #RewardsTable >= 1 then
				local Reward = RewardsTable[math.random(1,#RewardsTable)];
				local Amount = math.random(SalvageTable.Rewards[Reward].Amount[1],SalvageTable.Rewards[Reward].Amount[2]);
				
				Rewards[i] = {
					ID = Reward;
					Amount = Amount;
				};
				--print(Reward .. ": " .. Amount);
				
				Module.GiveItem(Player,Reward,Amount,"Materials");
						
			end;

		end
		--print("--");
		
		local ConvertedRewards = {};
		for i,v in pairs(Rewards) do
			ConvertedRewards[v.ID] = v.Amount;
		end
			
		
		spawn(function()
			Module.SaveData(Player);
			--[[local _,Error1 = pcall(function() 
				PurchaseData:UpdateAsync("Salvages",function(Table) 
					Table = (Table) or {};
					Table[Item] = (Table[Item] and Table[Item]+1) or 1;
					return Table;
				end); 
			end);
			if Error1 then
				print("Failed to update salvage table " .. Player.Name .. ": " .. Error1);
			end]]
		end)		
		
		return Rewards;
		
	end
end
function game.ReplicatedStorage.Remotes.Inventory.Salvage.OnServerInvoke(Player,Item)
	return Module.SalvageItem(Player,Item);
end


Module.GiveDrops = function(Player)
	local Drops = GetSyncData("Drops");
	local DropCount = 0;
	if math.random(1,100)<=Drops.DropCountChance[1] then
		DropCount = 1;
		if math.random(1,100)<=Drops.DropCountChance[2] then
			DropCount = 2;
		end
	end
	
	local DropRewards = {};
	
	for CurrentDrop = 1,DropCount do
		local CategoryChanceTable = {};
		local Category;
		
		for DropCategory,CategoryData in pairs(Drops.DropTree) do
			for e = 1,CategoryData.Chance[CurrentDrop] do
				table.insert(CategoryChanceTable,DropCategory);
			end;
		end
		
		Category = CategoryChanceTable[math.random(1,#CategoryChanceTable)];
		
		local DropTable = Drops.DropTree[Category].DropTable;
		local DropChanceTable = {};
		
		for ItemID,DropData in pairs(DropTable) do
			for i = 1,DropData.Chance do
				table.insert(DropChanceTable,ItemID);
			end
		end
		
		local DropReward = DropChanceTable[ math.random(1,#DropChanceTable) ];
		DropRewards[CurrentDrop] = {
			ItemID = DropReward;
			Type = Drops.DropTree[Category].Type;
			Amount = math.random(DropTable[DropReward].Amount[1],DropTable[DropReward].Amount[2]);
		};
	end
	
	for i,Reward in pairs(DropRewards) do
		Module.GiveItem(Player,Reward.ItemID,Reward.Amount,Reward.Type);	
	end;
	
	local ConvertedRewards = {};
	for i,v in pairs(DropRewards) do
		ConvertedRewards[v.ItemID] = {Type=v.Type; Amount=v.Amount;};
	end
	
	spawn(function()
		Module.SaveData(Player);
		--[[local _,Error1 = pcall(function() 
			PurchaseData:UpdateAsync("GiveDrops",function(Table) 
				Table = (Table) or {};
				for _,Reward in pairs(DropRewards) do
					Table[Reward.ItemID] = (Table[Reward.ItemID] and Table[Reward.ItemID]+Reward.Amount) or Reward.Amount;
				end;
				return Table;
			end); 
		end);
		if Error1 then
			print("Failed to update drop table " .. Player.Name .. ": " .. Error1);
		end]]
	end)
	
	return DropRewards;
	
end

--[[function CheckForItem(Player,ItemName,Type)
	for Index,Value in pairs(DataTable[Player.Name][Type].Owned) do
		if Index == ItemName then
			return true,Value;
		end
		if Value == ItemName then
			return true,1;
		end
	end
	return false;
end]]

Module.CraftItem = function(Player,CraftingTable)
	
	-- Check if they have what the CraftingTable says they have
	local AmountHas = 0;
	for _,Data in pairs (CraftingTable) do
		local Has,Amount = CheckForItem(Player,Data.ItemID,"Materials");
		if Has and Amount >= Data.Amount then
			AmountHas = AmountHas + 1;
		end
	end;
	if AmountHas >= #CraftingTable then
		print("CraftingTable verified")
		
		local SelectedRecipe;	
		-- FindRecipe
		for RecipeID,RecipeData in pairs(GetSyncData("Recipes")) do
			if RecipeData.Materials then
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
		
		local RD = GetSyncData("Recipes")[SelectedRecipe]	
		
		if RD then
			-- Recipe found, craft item
			local CrateName
			
			if RD.Name == "Random Uncommon Weapon" then
				CrateName = "UncommonBox";
			elseif RD.Name == "Random Rare Weapon" then
				CrateName = "RareBox";
			elseif RD.Name == "Random Legendary Weapon" then
				CrateName = "LegendaryBox";
			end
			
			-------------------roll----------------
			local DB = (
				GetSyncData("MysteryBox")[CrateName].Type == "Weapons" and GetSyncData("Item")) 
				or GetSyncData(GetSyncData("MysteryBox")[CrateName].Type
				);
	
			local SelectedKnife;
			local SelectedRarity;
			
			if GetSyncData("MysteryBox")[CrateName].Contents then				
				local ItemRarity;
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
				if (math.random(1,500) == 1) then
					ItemRarity = "Godly"; -- Godly
					SelectedKnife = GetSyncData("MysteryBox")[CrateName]["Godly"];
				else
					local RarityTable = {};
					for i,ItemName in pairs(GetSyncData("MysteryBox")[CrateName]["Contents"]) do
						if DB[ItemName]["Rarity"] == ItemRarity then
							table.insert(RarityTable,ItemName);
						end
					end
					if #RarityTable > 0 then
						SelectedKnife = RarityTable[math.random(1,#RarityTable)];
					else
						local RarityTable = {};
						for i,ItemName in pairs(GetSyncData("MysteryBox")[CrateName]["Contents"]) do
							if DB[ItemName]["Rarity"] == "Common" then
								table.insert(RarityTable,ItemName);
							end
						end
						SelectedKnife = RarityTable[math.random(1,#RarityTable)];
					end				
				end;
				
			else	
				local Chances = GetSyncData("MysteryBox")[CrateName].Chances;
				local ItemTable = {};	
					
				for Rarity,Chance in pairs(Chances) do
					ItemTable[Rarity] = {};
					for _,BData in pairs(GetSyncData("MysteryBox")) do
						if BData.Contents and BData.Type == "Weapons" then
							for _,ItemID in pairs(BData.Contents) do
								local ItemD = GetSyncData("Item")[ItemID];
								if ItemD.Rarity == Rarity then
									table.insert(ItemTable[Rarity],ItemID);
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
				
				SelectedRarity = ChanceTable[math.random(1,#ChanceTable)];
				SelectedKnife = ItemTable[SelectedRarity][math.random(1,#ItemTable[SelectedRarity])];	

				ChanceTable = {};
				
				if Chances.Common <= 0 then
					if (math.random(1,500) == 1) then
						SelectedRarity = "Godly"; -- Godly
						local Godlies = {};
						for _,BData in pairs(GetSyncData("MysteryBox")) do
							if BData.Type == "Weapons" and BData.Godly then
								table.insert(Godlies,BData.Godly);
							end
						end
						SelectedKnife = Godlies[math.random(1,#Godlies)];
					end;
				end;
				
				print(SelectedKnife);
								
				
				--[[for Rarity,Chance in pairs(Chances) do
					if Roll <= Chance then
						SelectedRarity = Rarity;
					end
				end	]]	
				
				Module.GiveItem(Player,SelectedKnife,1,GetSyncData("MysteryBox")[CrateName].Type);
			
				local MsgConnection;
				MsgConnection = game.ReplicatedStorage.CrateComplete.OnServerEvent:connect(function(ePlayer)
					if ePlayer == Player then
						MsgConnection:disconnect();
						local StuffName = (DB[SelectedKnife].ItemName or DB[SelectedKnife].Name);
						print(StuffName);
						game.ReplicatedStorage.Chatted:FireAllClients("Server",Player.Name .. " has just unboxed:", {
							ItemName = StuffName;
							RarityColor = GetSyncData("Rarity")[DB[SelectedKnife].Rarity];
						})
					end
				end)
			end;
		
			wait();
			spawn(function()
				Module.SaveData(Player);
			--[[local _,Error1 = pcall(function() PurchaseData:UpdateAsync(SelectedKnife,function(Value) if Value then return Value+1; else return 1; end; end); end);
			local _,Error2 = pcall(function() PurchaseData:UpdateAsync(CrateName,function(Value) if Value then return Value+1; else return 1; end; end); end);
			if Error1 then
				print("Failed to update " .. SelectedKnife .. "(Crate): " .. Error1);
			end
			if Error2 then
				print("Failed to update " .. CrateName .. "(Crate): " .. Error2);
			end]]
			end);
			return SelectedKnife;
			-----------------------------------------
			
			--they called some wonky ass module instead of using the mbox system?--
			
			
			--[[
				
			local RewardID,RewardAmount,RewardType;-- = RD.RewardItem,RD.RewardAmount,RD.RewardType;
			if RD.Function then
				RewardID,RewardAmount,RewardType = require(RD.Function)(Player,SelectedRecipe,RD);
			else
				RewardID,RewardAmount,RewardType = RD.RewardItem,RD.RewardAmount,RD.RewardType;
			end;
			
			print(RewardID,RewardAmount,RewardType);
			
			for Material,Amount in pairs(RD.Materials) do
				Module.RemoveItem(Player,Material,Amount,"Materials");
			end
			Module.GiveItem(Player,RewardID,RewardAmount,RewardType);
			
			spawn(function()
				Module.SaveData(Player);

				--[[local _,Error1 = pcall(function() 
					PurchaseData:UpdateAsync("CraftedItems",function(Table) 
						Table = (Table) or {};
						Table[RewardID] = (Table[RewardID] and Table[RewardID]+RewardAmount) or RewardAmount;
						return Table;
					end); 
				end);
				if Error1 then
					print("Failed to update crafting table " .. RewardID .. ": " .. Error1);
				end]]
				--[[local _,Error1 = pcall(function() PurchaseData:UpdateAsync(RewardID,function(Value) if Value then return Value+1; else return 1; end; end); end);
				local _,Error2 = pcall(function() PurchaseData:UpdateAsync("TotalCrafts",function(Value) if Value then return Value+1; else return 1; end; end); end);
				if Error1 then
					print("Failed to update " .. RewardID .. ": " .. Error1);
				end
				if Error2 then
					print("Failed to update " .. "TotalCrafts: " .. Error2);
				end]]
			--end)	
			--]]
		end	
	end
end;


function game.ReplicatedStorage.Remotes.Inventory.Craft.OnServerInvoke(Player,CraftingTable)
	return Module.CraftItem(Player,CraftingTable);
end




local TradeEvents = game.ReplicatedStorage.Trade;

Module.TradingPlayers = {};


local ShirtCodes = game:GetService("DataStoreService"):GetDataStore("StoreCodes2");

Module.Redeem = function(Player,Code)

	for CodeCheck,CodeTable in pairs(GetSyncData("Codes")) do

		if Code == CodeCheck then
			if not CheckForItem(Player,CodeTable["Prize"],"Weapons") then
				if os.time() < GetSyncData("Codes")[Code]["Expiry"] then
					Module.GiveItem(Player,CodeTable["Prize"],1);
					game.ReplicatedStorage.RedeemCode:FireClient(Player,CodeTable["Prize"]);
					return;
				else
					game.ReplicatedStorage.RedeemCode:FireClient(Player,false,"Expired");
					return
				end;
			else
				game.ReplicatedStorage.RedeemCode:FireClient(Player,false,"Has");
				return;
			end;
		end
		
	end;
	
end

function game.ReplicatedStorage.RedeemShirtCode.OnServerInvoke(Player,Code)

	local ShirtCodeSuccess = "Invalid";
	local Rewards;

	ShirtCodes:UpdateAsync(Code, function(Value)
		
		if Value == nil then
			return nil;
		elseif Value.Redeemed == false then
			ShirtCodeSuccess = "Awarded"
			Value.Redeemed = Player.userId;
			Rewards = Value.Rewards;
			return Value;
		else
			ShirtCodeSuccess = "Redeemed";
			return Value;
		end;
		
	end)
	
	if ShirtCodeSuccess == "Invalid" then
		return "Invalid";
	elseif ShirtCodeSuccess == "Awarded" then
		for _,Reward in pairs(Rewards) do
			if Reward.Type == "Weapons" or Reward.Type == "Pets" or Reward.Type == "Materials" then
				Module.GiveItem(Player,Reward.ID,1,Reward.Type);
			else
				Module.GiveOther(Player,Reward.ID,Reward.Type);
			end;
		end;
		Module.SaveData(Player);
		return "Success!",Rewards;
	elseif ShirtCodeSuccess == "Redeemed" then
		return "Used already";
	end;
	
end




Module.OpenCrate = function(Player,CrateName)
	local IsElite = false;
	local ReleaseTime = GetSyncData("MysteryBox")[CrateName]["Released"];
	if os.time()-ReleaseTime < 86400 then
		IsElite = true;
	end
	
	local DB = (
		GetSyncData("MysteryBox")[CrateName].Type == "Weapons" and GetSyncData("Item")) 
		or GetSyncData(GetSyncData("MysteryBox")[CrateName].Type
	);
	
	if not IsElite or (IsElite and PlayerIsElite(Player)) then
		local ChristmasPrice = GetSyncData("MysteryBox")[CrateName].ChristmasPrice;
		local Candies = GetSyncData("MysteryBox")[CrateName].Candies;
		local Credits = Module.Get(Player,"Credits");		
		
		local CanBuy;
		if ChristmasPrice then
			CanBuy = (GetGifts(Player) >= ChristmasPrice);
		elseif Candies then
			CanBuy = (GetCandies(Player) >= GetSyncData("MysteryBox")[CrateName]["Price"]);
		else
			CanBuy = (Credits >= GetSyncData("MysteryBox")[CrateName]["Price"]);
		end;

		local SelectedKnife;
		local SelectedRarity;
		if CanBuy then
			
			if GetSyncData("MysteryBox")[CrateName].Contents then				
				local ItemRarity;
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
				if (math.random(1,500) == 1) then
					ItemRarity = "Godly"; -- Godly
					SelectedKnife = GetSyncData("MysteryBox")[CrateName]["Godly"];
				else
					local RarityTable = {};
					for i,ItemName in pairs(GetSyncData("MysteryBox")[CrateName]["Contents"]) do
						if DB[ItemName]["Rarity"] == ItemRarity then
							table.insert(RarityTable,ItemName);
						end
					end
					if #RarityTable > 0 then
						SelectedKnife = RarityTable[math.random(1,#RarityTable)];
					else
						local RarityTable = {};
						for i,ItemName in pairs(GetSyncData("MysteryBox")[CrateName]["Contents"]) do
							if DB[ItemName]["Rarity"] == "Common" then
								table.insert(RarityTable,ItemName);
							end
						end
						SelectedKnife = RarityTable[math.random(1,#RarityTable)];
					end				
				end;
				
			else	
				local Chances = GetSyncData("MysteryBox")[CrateName].Chances;
				local ItemTable = {};	
					
				for Rarity,Chance in pairs(Chances) do
					ItemTable[Rarity] = {};
					for _,BData in pairs(GetSyncData("MysteryBox")) do
						if BData.Contents and BData.Type == "Weapons" then
							for _,ItemID in pairs(BData.Contents) do
								local ItemD = GetSyncData("Item")[ItemID];
								if ItemD.Rarity == Rarity then
									table.insert(ItemTable[Rarity],ItemID);
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
				
				SelectedRarity = ChanceTable[math.random(1,#ChanceTable)];
				SelectedKnife = ItemTable[SelectedRarity][math.random(1,#ItemTable[SelectedRarity])];	

				ChanceTable = {};
				
				if Chances.Common <= 0 then
					if (math.random(1,500) == 1) then
						SelectedRarity = "Godly"; -- Godly
						local Godlies = {};
						for _,BData in pairs(GetSyncData("MysteryBox")) do
							if BData.Type == "Weapons" and BData.Godly then
								table.insert(Godlies,BData.Godly);
							end
						end
						SelectedKnife = Godlies[math.random(1,#Godlies)];
					end;
				end;
				
				print(SelectedKnife);
								
				
				--[[for Rarity,Chance in pairs(Chances) do
					if Roll <= Chance then
						SelectedRarity = Rarity;
					end
				end	]]	
				
			end
			
			if ChristmasPrice then
				Module.RemoveItem(Player,"Gift",ChristmasPrice);
			elseif Candies then
				Module.RemoveItem(Player,"Candies", GetSyncData("MysteryBox")[CrateName]["Price"]);
			else 
				DataTable[Player.Name]["Credits"] = DataTable[Player.Name]["Credits"] - GetSyncData("MysteryBox")[CrateName]["Price"];
			end;
			
			Module.GiveItem(Player,SelectedKnife,1,GetSyncData("MysteryBox")[CrateName].Type);
			
			local MsgConnection;
			MsgConnection = game.ReplicatedStorage.CrateComplete.OnServerEvent:connect(function(ePlayer)
				if ePlayer == Player then
					MsgConnection:disconnect();
					local StuffName = (DB[SelectedKnife].ItemName or DB[SelectedKnife].Name);
					print(StuffName);
					game.ReplicatedStorage.Chatted:FireAllClients("Server",Player.Name .. " has just unboxed:", {
						ItemName = StuffName;
						RarityColor = GetSyncData("Rarity")[DB[SelectedKnife].Rarity];
					})
				end
			end)
			
		else
			return nil;
		end;
		
		local CrateType = GetSyncData("MysteryBox")[CrateName].Type;		
		
		wait();
		spawn(function()
			Module.SaveData(Player);
			--[[local _,Error1 = pcall(function() PurchaseData:UpdateAsync(SelectedKnife,function(Value) if Value then return Value+1; else return 1; end; end); end);
			local _,Error2 = pcall(function() PurchaseData:UpdateAsync(CrateName,function(Value) if Value then return Value+1; else return 1; end; end); end);
			if Error1 then
				print("Failed to update " .. SelectedKnife .. "(Crate): " .. Error1);
			end
			if Error2 then
				print("Failed to update " .. CrateName .. "(Crate): " .. Error2);
			end]]
		end);
		return SelectedKnife;
	else
		game.ReplicatedStorage.GetElite:FireClient(Player);
	end;
end

Module.Prestige = function(Player)
	local Level = Module.GetLevel(Module.Get(Player,"XP"));
	if Level >= 100 and Module.Get(Player,"Prestige") < 10 then
		DataTable[Player.Name]["XP"] = 0;
		DataTable[Player.Name]["Prestige"] = DataTable[Player.Name]["Prestige"] + 1;
		game.ReplicatedStorage.Chatted:FireAllClients("Server",Player.Name .. " has just prestiged!");
		game.ReplicatedStorage.UpdateLeaderboard:FireAllClients();
	end
end
game.ReplicatedStorage.Prestige.OnServerEvent:connect(Module.Prestige);


local TradeRequests = {};
local Trades = {};

local function IsInTrade(Player)
	for i,Request in pairs(TradeRequests) do
		if Request["Sender"] == Player or Request["Receiver"] == Player then
			return true,Request,i,"Request";
		end;
	end
	for i,Trade in pairs(Trades) do
		if Trade["Player1"]["Player"] == Player or Trade["Player2"]["Player"] == Player then
			return true,Trade,i,"Trade";
		end;
	end
	return false;
end

local function GetPlayerFromTrade(Player,Trade)
	if Trade ~= nil then
		if Trade["Player1"]["Player"] == Player then
			return "Player1","Player2";
		elseif Trade["Player2"]["Player"] == Player then
			return "Player2","Player1";
		end;
	end;
end

Module.Trade = {};

Module.Trade.Request = function(Player1,Player2)
	if not IsInTrade(Player1) and not IsInTrade(Player2) and not (Player1==Player2) then
		local RequestsEnabled = TradeEvents.SendRequest:InvokeClient(Player2,Player1);
		if RequestsEnabled then
			table.insert(TradeRequests,{
				["Sender"] = Player1;
				["Receiver"] = Player2;
			});
			return false;
		else
			return true;
		end;
	end;
	return true;
end
function TradeEvents.SendRequest.OnServerInvoke(Player1,Player2)
	return Module.Trade.Request(Player1,Player2);
end;


Module.Trade.AcceptRequest = function(Player)
	local IsTrading,Request,iRequest,Type = IsInTrade(Player);
	--false nil nil nil
	if IsTrading and Type == "Request" then
		local Player1 = Request["Sender"];
		local Player2 = Request["Receiver"];
		
		table.remove(TradeRequests,iRequest);
		
		table.insert(Trades,{
			["LastOffer"] = os.time();
			["Locked"] = false;
			["Player1"] = {
				["Player"] = Player1;
				["Offer"] = {};
				["Accepted"] = false;
			};
			["Player2"] = {
				["Player"] = Player2;
				["Offer"] = {};
				["Accepted"] = false;
			};
		});
		TradeEvents.StartTrade:FireClient(Player1);
		TradeEvents.StartTrade:FireClient(Player2);		
	end
end
TradeEvents.AcceptRequest.OnServerEvent:connect(Module.Trade.AcceptRequest);

Module.Trade.DeclineRequest = function(Player)
	local IsTrading,Request,iRequest,Type = IsInTrade(Player);
	if IsTrading and Type == "Request" then
		local Player1 = Request["Sender"];
		table.remove(TradeRequests,iRequest);
		TradeEvents.DeclineRequest:FireClient(Player1);
	end
end
TradeEvents.DeclineRequest.OnServerEvent:connect(Module.Trade.DeclineRequest);


Module.Trade.CancelRequest = function(Player)
	local IsTrading,Request,iRequest,Type = IsInTrade(Player);
	if IsTrading and Type == "Request" then
		local Player1 = Request["Receiver"];
		TradeEvents.CancelRequest:FireClient(Player1);
		table.remove(TradeRequests,iRequest);
	end
end
TradeEvents.CancelRequest.OnServerEvent:connect(Module.Trade.CancelRequest);

Module.Trade.OfferItem = function(Player,ItemName,ItemType)
	if ItemName ~= "DefaultPillow" then
		local IsTrading,Trade,iTrade,Type = IsInTrade(Player);
		--print(tostring(IsTrading),tostring(Trade));
		local tPlayer = GetPlayerFromTrade(Player,Trade);
		if IsTrading and Type == "Trade" then
			if #Trade[tPlayer]["Offer"] < 4 then
				
				local AlreadyOffered = 0;
				for _,Item in pairs(Trade[tPlayer]["Offer"]) do
					if Item[1] == ItemName and Item[3] == ItemType then
						AlreadyOffered = Item[2];
					end
				end
				
				local HasItem,Amount = CheckForItem(Player,ItemName,ItemType);
				
				--print("Offer Attempt");
				if HasItem and Amount-AlreadyOffered > 0 then
					--print("Has Enough");
					if AlreadyOffered == 0 then
						--print("None Offered, Adding the first item");
						table.insert(Trades[iTrade][tPlayer]["Offer"],
							{ItemName,1,ItemType}
						);
					else
						--print("Some offered");
						for Index,Item in pairs(Trade[tPlayer]["Offer"]) do
							if Item[1] == ItemName then
								--print("Added to existing offer.");
								Trades[iTrade][tPlayer]["Offer"][Index][2] = Trades[iTrade][tPlayer]["Offer"][Index][2] + 1;
								break;
							end
						end
						
					end;
				end;
				
				Trades[iTrade]["LastOffer"] = os.time();
				Trades[iTrade]["Player1"]["Accepted"] = false;
				Trades[iTrade]["Player2"]["Accepted"] = false;
				TradeEvents.UpdateTrade:FireClient(Trades[iTrade]["Player1"]["Player"],Trades[iTrade]);
				TradeEvents.UpdateTrade:FireClient(Trades[iTrade]["Player2"]["Player"],Trades[iTrade]);
			end
		end
	end;
end
TradeEvents.OfferItem.OnServerEvent:connect(Module.Trade.OfferItem);

Module.Trade.RemoveOffer = function(Player,ItemName,ItemType)
	local IsTrading,Trade,iTrade,Type = IsInTrade(Player);
	local tPlayer = GetPlayerFromTrade(Player,Trade);
	if IsTrading and Type == "Trade" then

		if Trades[iTrade]["Locked"] then
			return;
		end		
		
		Trades[iTrade]["LastOffer"] = os.time();
		Trades[iTrade]["Player1"]["Accepted"] = false;
		Trades[iTrade]["Player2"]["Accepted"] = false;
		
		for Index,Item in pairs(Trade[tPlayer]["Offer"]) do
			if Item[1] == ItemName and Item[3] == ItemType then
				Trades[iTrade][tPlayer]["Offer"][Index][2] = Trades[iTrade][tPlayer]["Offer"][Index][2] - 1;
				if Trades[iTrade][tPlayer]["Offer"][Index][2] <= 0 then
					table.remove(Trades[iTrade][tPlayer]["Offer"],Index);
				end
				--table.remove(Trades[iTrade][tPlayer]["Offer"],i);
				break;
			end
		end
		TradeEvents.UpdateTrade:FireClient(Trades[iTrade]["Player1"]["Player"],Trades[iTrade]);
		TradeEvents.UpdateTrade:FireClient(Trades[iTrade]["Player2"]["Player"],Trades[iTrade]);
	end
end
TradeEvents.RemoveOffer.OnServerEvent:connect(Module.Trade.RemoveOffer);

Module.Trade.AcceptTrade = function(Player)
	local IsTrading,Trade,iTrade,Type = IsInTrade(Player);
	local tPlayer,oPlayer = GetPlayerFromTrade(Player,Trade);
	if IsTrading and Type == "Trade" and os.time()-Trades[iTrade]["LastOffer"] >= 5 then
		Trades[iTrade][tPlayer]["Accepted"] = true;
		if Trades[iTrade]["Player1"]["Accepted"] and Trades[iTrade]["Player2"]["Accepted"] then
			Trades[iTrade]["Locked"] = true;			
			
			wait(1);

			if os.time()-Trades[iTrade]["LastOffer"] >= 5 and Trades[iTrade]["Player1"]["Accepted"] and Trades[iTrade]["Player2"]["Accepted"] then
				wait()
			else
				return;
			end;
			
			local OfferError = false;
			
			for _,Item in pairs(Trades[iTrade]["Player1"]["Offer"]) do
				local Has,Amount = CheckForItem(Trades[iTrade]["Player1"]["Player"],Item[1],Item[3]);
				if not (Amount >= Item[2]) then
					OfferError = true;
				end
			end;
			
			for _,Item in pairs(Trades[iTrade]["Player2"]["Offer"]) do
				local Has,Amount = CheckForItem(Trades[iTrade]["Player2"]["Player"],Item[1],Item[3]);
				if not (Amount >= Item[2]) then
					OfferError = true;
				end
			end;
			
			if OfferError then
				local Player1 = Trades[iTrade]["Player1"]["Player"];
				local Player2 = Trades[iTrade]["Player2"]["Player"];
				return;
			end
			
			if game.ReplicatedStorage.CheckClient:InvokeClient(Trades[iTrade]["Player2"]["Player"])==5 and game.ReplicatedStorage.CheckClient:InvokeClient(Trades[iTrade]["Player1"]["Player"])==5  then	
				if Trades[iTrade]["Player2"]["Player"] and Trades[iTrade]["Player1"]["Player"] then
					for _,Item in pairs(Trades[iTrade]["Player1"]["Offer"]) do
						
						Module.GiveItem(Trades[iTrade]["Player2"]["Player"],Item[1],Item[2],Item[3]);
						Module.RemoveItem(Trades[iTrade]["Player1"]["Player"],Item[1],Item[2],Item[3]);
						
					end
					for _,Item in pairs(Trades[iTrade]["Player2"]["Offer"]) do
						Module.GiveItem(Trades[iTrade]["Player1"]["Player"],Item[1],Item[2],Item[3]);
						Module.RemoveItem(Trades[iTrade]["Player2"]["Player"],Item[1],Item[2],Item[3]);
					end
				end;
				
				TradeEvents.AcceptTrade:FireClient(Trades[iTrade]["Player1"]["Player"],true);
				TradeEvents.AcceptTrade:FireClient(Trades[iTrade]["Player2"]["Player"],true);
				game.ReplicatedStorage.UpdateData2:FireClient(Trades[iTrade]["Player1"]["Player"],DataTable[Trades[iTrade]["Player1"]["Player"].Name]);
				game.ReplicatedStorage.UpdateData2:FireClient(Trades[iTrade]["Player2"]["Player"],DataTable[Trades[iTrade]["Player2"]["Player"].Name]);
				local Player1 = Trades[iTrade]["Player1"]["Player"];
				local Player2 = Trades[iTrade]["Player2"]["Player"];
				
				local NewOffer1 = {};
				local NewOffer2 = {};
				
				for _,ItemTable in pairs(Trades[iTrade]["Player1"]["Offer"]) do
					if #ItemTable>0 then
						NewOffer1[ItemTable[1]] = {Type=ItemTable[3];Amount=ItemTable[2];};
					end;
				end;
				for _,ItemTable in pairs(Trades[iTrade]["Player2"]["Offer"]) do
					if #ItemTable>0 then
						NewOffer2[ItemTable[1]] = {Type=ItemTable[3];Amount=ItemTable[2];};
					end;
				end;
				
				table.remove(Trades,iTrade);
				Module.SaveData(Player1);
				Module.SaveData(Player2);

				

			end;
		else
			TradeEvents.AcceptTrade:FireClient(Trades[iTrade][oPlayer]["Player"],false);
		end;
	end
end
TradeEvents.AcceptTrade.OnServerEvent:connect(Module.Trade.AcceptTrade);

Module.Trade.DeclineTrade = function(Player)
	local IsTrading,Trade,iTrade,Type = IsInTrade(Player);
	local tPlayer = GetPlayerFromTrade(Player,Trade);
	if IsTrading and Type == "Trade" then
		TradeEvents.DeclineTrade:FireClient(Trade["Player1"]["Player"]);
		TradeEvents.DeclineTrade:FireClient(Trade["Player2"]["Player"]);
		table.remove(Trades,iTrade);
	end
end

TradeEvents.DeclineTrade.OnServerEvent:connect(Module.Trade.DeclineTrade);

function game.ReplicatedStorage.GetTradeStatus.OnServerInvoke(Player)
	local IsBusy,BusyTable,iBusy,BusyType = IsInTrade(Player);
	if IsBusy then
		if BusyType == "Trade" then
			return "StartTrade",BusyTable;
		elseif BusyType == "Request" then
			if BusyTable["Sender"] == Player then
				return "ShowRequest",BusyTable["Receiver"].Name;
			elseif BusyTable["Receiver"] == Player then
				return "SendRequest",BusyTable["Sender"].Name;
			end;
		end;
	end;
end


Module.GiveToys = function(Player)
	if not Player:FindFirstChild("Backpack") then return; end;
	local Toys = GetSyncData("Toys");
	local FakeTool = Instance.new("Tool",Player.Backpack);
	FakeTool.Name = "Loading Toys...";
	for _,Toy in pairs(DataTable[Player.Name].Toys.Equipped) do
		local NewToy = Instance.new("Tool");
		pcall(function() NewToy = game.InsertService:LoadAsset(Toys[Toy].ItemID):GetChildren()[1]; end);
		if NewToy then
			NewToy.CanBeDropped = false;
			NewToy.Parent = Player.Backpack;
		end;
	end;
	FakeTool:Destroy();
end

-- Halloween
Module.BuyCandies = function(Player,Amount)
	if Amount < 1 then return end;
	if DataTable[Player.Name].Gems >= Amount then
		DataTable[Player.Name].Gems = DataTable[Player.Name].Gems - Amount;
		Module.GiveItem(Player,"Candies",Amount*2,"Weapons");
		return;
	end	
end
game.ReplicatedStorage.BuyCandies.OnServerEvent:connect(Module.BuyCandies);


Module.SellCandies = function(Player,Amount)
	if Amount < 1 then return end;

	local HasCandies,Candies = CheckForItem(Player,"Candies","Weapons");
	if HasCandies and (Candies >= Amount) then
		DataTable[Player.Name].Credits = DataTable[Player.Name].Credits + Amount;
		Module.RemoveItem(Player,"Candies",Amount,"Weapons");
		return;
	end	
end
game.ReplicatedStorage.SellCandies.OnServerEvent:connect(Module.SellCandies);


------------ CHRISTMAS

--[[Module.ExchangeGifts = function(Player)
	local Gifts = GetGifts(Player);
	if Gifts >= 1 then
		Module.Give(Player,"Credits",2);
		Module.RemoveItem(Player,"Gift",1);
		game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
	end
end

Module.ExchangeCoins = function(Player)
	local Coins = Module.Get(Player,"Credits");
	if Coins >= 10 then
		Module.Give(Player,"Credits",-10);
		Module.GiveItem(Player,"Gift",1);
		game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
	end
end

function game.ReplicatedStorage.ExchangeGifts.OnServerInvoke(Player)
	Module.ExchangeGifts(Player);
	return true;
end
	
function game.ReplicatedStorage.ExchangeCoins.OnServerInvoke(Player)
	Module.ExchangeCoins(Player);
	return true;
end]]


game.ReplicatedStorage.ChristmasEvents.CompleteTutorial.OnServerEvent:connect(function(Player)
	DataTable[Player.Name].SantaTutorial = true;
end)

game.ReplicatedStorage.ChristmasEvents.ChristmasBuy.OnServerEvent:connect(function(Player,ShopIndex)
	
	if DataTable[Player.Name] == nil then return end;
	
	--local Credits = Module.Get(Player,"Credits"); if Credits == nil then return end;
	local Gems = Module.Get(Player,"Gems"); if Gems == nil then return end;
	--local Database = GetSyncData(Type) or GetSyncData("Item"); if Database == nil then return; end;
	--local Data = Database[ID]; if Data == nil then return end;
	
	local ShopData = GetSyncData("ChristmasShop")[ShopIndex];
	
	
	local Currency = ShopData.CostID;
	local Amount = (ShopData.CostID == "Gems" and Gems) or DataTable[Player.Name][ShopData.CostType].Owned[ShopData.CostID];
	
	for _,rN in pairs(DataTable[Player.Name][ShopData.RewardType].Owned) do
		if rN == ShopData.RewardID then
			return;
		end
	end
	
	if Amount >= ShopData.Cost then
		
		if ShopData.CostID == "Gems" then
			DataTable[Player.Name][Currency] = DataTable[Player.Name][Currency] - ShopData.Cost;
		else
			Module.RemoveItem(Player,ShopData.CostID,ShopData.Cost,ShopData.CostType);
		end;

		if ShopData.RewardType == "Weapons" or ShopData.RewardType == "Pets" or ShopData.RewardType == "Materials" then
			Module.GiveItem(Player,ShopData.RewardID,ShopData.RewardAmount,ShopData.RewardType);
		else
			table.insert(DataTable[Player.Name][ShopData.RewardType].Owned,ShopData.RewardID);
			game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
		end;		
		
		

		wait();
		--
		--print(Player.Name .. " has successfully purchased " .. ID);
		
		--[[local _,Error = pcall(function() PurchaseData:UpdateAsync(ID,function(Value) if Value then return Value+1; else return 1; end; end); end);
		if Error then
			print("Failed to update " .. ID .. ": " .. Error);
		end]]
		
		
		
		spawn(function()
			Module.SaveData(Player);
			--[[local _,Error1 = pcall(function() 
				PurchaseData:UpdateAsync("ChristmasBuy",function(Table) 
					Table = (Table) or {};
					Table[ShopData.RewardID] = (Table[ShopData.RewardID] and Table[ShopData.RewardID]+1) or 1;
					return Table;
				end); 
			end);
			if Error1 then
				print("Failed to update xmasbuytable " .. Player.Name .. ": " .. Error1);
			end]]
		end)	

	end;
end)

game.ReplicatedStorage.ChristmasEvents.ExchangeGift.OnServerEvent:connect(function(Player,GiftID)
	if CheckForItem(Player,GiftID,"Materials") then
		Module.RemoveItem(Player,GiftID,1,"Materials");
		Module.GiveItem(Player,"BlueTokens",GetSyncData("Materials")[GiftID].TokenValue,"Materials");
		
		spawn(function()
			--[[local _,Error1 = pcall(function() 
				PurchaseData:UpdateAsync("GiftExchange",function(Table) 
					Table = (Table) or {};
					Table[GiftID] = (Table[GiftID] and Table[GiftID]+1) or 1;
					Table["Total"] = (Table["Total"] and Table["Total"]+1) or 1;
					Table["TokenValue"] = (Table["TokenValue"] and Table["TokenValue"]+GetSyncData("Materials")[GiftID].TokenValue) or GetSyncData("Materials")[GiftID].TokenValue;
					return Table;
				end); 
			end);
			if Error1 then
				print("Failed to update xmasbuytable " .. Player.Name .. ": " .. Error1);
			end]]
			local TokenValue = GetSyncData("Materials")[GiftID].TokenValue;
				
		end)	
		
	end;
end);


local RarityIndex = {
	["Common"] = "Uncommon";
	["Uncommon"] = "Rare";
	["Rare"] = "Legendary";
};

--[[function game.ReplicatedStorage.Remotes.Inventory.Recycle.OnServerInvoke(Player,RecycleTable)
	if RecycleTable and #RecycleTable == 8 then
		
		local RecyclableItems = 0;
		for _,ItemName in pairs(RecycleTable) do
			for _,rItem in pairs(GetSyncData("Recyclable")) do
				if ItemName == rItem then
					RecyclableItems = RecyclableItems + 1; break;
				end
			end
		end
		
		if RecyclableItems == 8 then
			local ItemsWithAmount = {};
			for _,ItemName in pairs(RecycleTable) do
				if not ItemsWithAmount[ItemName] then
					ItemsWithAmount[ItemName] = 1;
				else
					ItemsWithAmount[ItemName] = ItemsWithAmount[ItemName] + 1;
				end;
			end				
			local ItemHas = 0;
			for ItemName,Amount in pairs(ItemsWithAmount) do
				local Inventory = Module.Get(Player,"Weapons").Owned;
				if Inventory[ItemName] >= Amount then
					ItemHas = ItemHas + Amount;
				end
			end;
			if ItemHas == 8 then
				local Items = GetSyncData("Item");
				local NeededType = Items[RecycleTable[1].ItemType;
				local NeededRarity = Items[RecycleTable[1].Rarity;
				local CanRecycle = true;
				for _,ItemName in pairs(RecycleTable) do
					if Items[ItemName].ItemType ~= NeededType or Items[ItemName].Rarity ~= NeededRarity then
						CanRecycle = false;
					end
				end
				
				if CanRecycle then
					local Rewards = GetSyncData("RecycleRewards");
					local UpgradeRarity = RarityIndex[NeededRarity];
					local RewardTable = Rewards[UpgradeRarity][NeededType];
					local RewardKnife = RewardTable[math.random(1,#RewardTable)];
					Module.GiveItem(Player,RewardKnife,1);
					for _,ItemName in pairs(RecycleTable) do
						Module.RemoveItem(Player,ItemName,1);
					end;
					game.ReplicatedStorage.UpdateData2:FireClient(Player,DataTable[Player.Name]);
					spawn(function()
						wait(0.75);
						game.ReplicatedStorage.Chatted:FireAllClients("Server",Player.Name .. " recycled and got:",
							{
								ItemName = RewardKnife;
								RarityColor = GetSyncData("Rarity")[GetSyncData("Item")[RewardKnife].Rarity];
							}
						)
					end)
					return RewardKnife;
				else
					print("Not matching types and rarity");
				end;
				
			else
				print("Doesn't have all items");
			end;
		else
			print("Not all items are recylable");
		end;
		
	else
		print("Table is nil");
	end;
end]]

game.ReplicatedStorage.Remotes.Inventory.BuySlot.OnServerEvent:connect(function(Player,Type)
	local SlotInfo = GetSyncData("SlotInfo");
	local NextSlot = DataTable[Player.Name][Type].Slots + 1;
	if NextSlot <= SlotInfo[Type].Max then
		DataTable[Player.Name][Type].Slots = DataTable[Player.Name][Type].Slots + 1;
		DataTable[Player.Name]["Credits"] = DataTable[Player.Name]["Credits"] - SlotInfo[Type].Prices[NextSlot];
	end
end);

function game.ReplicatedStorage.GetPlayerLevel.OnServerInvoke(Player,Target)
	return Module.GetLevel(Module.Get(Target,"XP")),Module.Get(Target,"Prestige"),PlayerIsElite(Target);
end

game.ReplicatedStorage.Equip.OnServerEvent:connect(function(Player,ItemName,Type)
	Module.Equip(Player,ItemName,Type);
end)
game.ReplicatedStorage.Remotes.Inventory.Unequip.OnServerEvent:connect(function(Player,ItemName,Type)
	Module.Unequip(Player,ItemName,Type);
end)

game.ReplicatedStorage.Craft.OnServerEvent:connect(function(Player,ItemName)
	Module.Craft(Player,ItemName);
end)

function game.ReplicatedStorage.Remotes.Shop.OpenCrate.OnServerInvoke(Player,Box)
	return Module.OpenCrate(Player,Box);
end

function game.ReplicatedStorage.GetData2.OnServerInvoke(Player)
	return DataTable[Player.Name];
end

game.ReplicatedStorage.ChangeGameMode.OnServerEvent:connect(function(Player,NewMode)
	DataTable[Player.Name]["GameMode2"] = NewMode;
	Module.SaveData(Player);
end);

game.ReplicatedStorage.ChangeLastDevice.OnServerEvent:connect(function(Player,NewDevice)
	DataTable[Player.Name]["LastDevice"] = NewDevice;
	Module.SaveData(Player);
end);


game.ReplicatedStorage.RedeemCode.OnServerEvent:connect(function(Player,Code)
	Module.Redeem(Player,Code);
end)

game.ReplicatedStorage.Buy.OnServerEvent:connect(Module.Buy);
game.ReplicatedStorage.BuyBundle.OnServerEvent:connect(Module.BuyBundle);

function game.ReplicatedStorage.GetData.OnServerInvoke(Player,DataName,Target)
	if Target ~= nil then
		return Module.Get(Target,DataName);
	else
		return Module.Get(Player,DataName);
	end;
end

local Products = {
	Coins = {
		["50"] 		= 426067504;
		["100"] 	= 426067336;
		["200"] 	= 426067673;
		["500"] 	= 430201870;
		["1500"] 	= 430202074;
		["3500"] 	= 430202341; 
	};
	
	Gems = {
		["50"] 		= 430202657;
		["250"] 	= 430202789;
		["700"] 	= 430202923;
		["1400"] 	= 430203135;
		["3000"] 	= 430203415;
		["8000"] 	= 430203721; 
	};
};

game.ReplicatedStorage.PurchaseProduct.OnServerEvent:connect(function(Player,ButtonName,Type)
	game:GetService("MarketplaceService"):PromptProductPurchase(Player,Products[Type][ButtonName])
end)

local Purchases = {};
game:GetService("MarketplaceService").ProcessReceipt = function(ReceiptInfo)
	local Player = game.Players:GetPlayerByUserId(ReceiptInfo.PlayerId)

	local Key = ReceiptInfo.PlayerId .. ":" .. ReceiptInfo.PurchaseId
	if Purchases[Key] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	

	if Player then
		for Amount,ProductID in pairs(Products.Coins) do
			if ReceiptInfo.ProductId == ProductID then
				Purchases[Key] = true;
				Module.Give(Player,"Credits",tonumber(Amount));
				game.ReplicatedStorage.CashSound:FireClient(Player);
				game.ReplicatedStorage.Save:Fire(Player);
				
				
				return Enum.ProductPurchaseDecision.PurchaseGranted	
			end
		end
		for Amount,ProductID in pairs(Products.Gems) do
			if ReceiptInfo.ProductId == ProductID then
				Purchases[Key] = true;
				Module.Give(Player,"Gems",tonumber(Amount));
				game.ReplicatedStorage.CashSound:FireClient(Player);
				game.ReplicatedStorage.Save:Fire(Player);
				return Enum.ProductPurchaseDecision.PurchaseGranted	
			end
		end
		
		for _,ID in pairs(_G.GameModeProducts) do
			if ID == ReceiptInfo.ProductId then
				_G.ModePurchaseComplete(Player);
				Purchases[Key] = true;
				
				return Enum.ProductPurchaseDecision.PurchaseGranted	
			end
		end
	end;

end	

function game.ReplicatedStorage.GetFullInventory.OnServerInvoke(Player,TargetPlayer)
	return DataTable[TargetPlayer.Name];
end	
	
function game.ReplicatedStorage.GetLeaderboard.OnServerInvoke()
	local LeaderTable = {};
	for _,lPlayer in pairs(game.Players:GetPlayers()) do
		local Name = lPlayer.Name;
		local lData = DataTable[lPlayer.Name];
		if lData then
			table.insert(LeaderTable,{
				PlayerName = Name;
				Level = Module.GetLevel(Module.Get(lPlayer,"XP"));
				Prestige = Module.Get(lPlayer,"Prestige");
				Elite = _G.CheckElite(lPlayer);
			});			
		end
	end
	return LeaderTable;
end

function game.ReplicatedStorage.GetDataServer.OnInvoke(Player,DataName)
	return Module.Get(Player,DataName);
end

Module.Ready = true;

return Module;