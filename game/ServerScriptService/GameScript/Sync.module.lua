-- Sync 2.0

local Sync = {};

print("Setting up Sync Table..");

local DataStore = game:GetService("DataStoreService"):GetDataStore("Sync");
	
Sync.Data = {};

function Color(Table) for i,RGBTable in pairs(Table) do Table[i] = Color3.new(RGBTable["r"]/255,RGBTable["g"]/255,RGBTable["b"]/255); end return Table;end
local function ColorData()
	for DataName,Data in pairs(Sync.Data) do
		if DataName == "Rarity" or DataName == "NameTags" then
			Sync.Data[DataName] = Color(Data);
		end
	end
end

for _,SyncModule in pairs(script:GetChildren()) do
	local Name = SyncModule.Name;
	local Data = require(SyncModule);
	Sync.Data[Name] = Data;
end


local function InitializeSync()																			print("Initializing...")
	
	local NewData = game:GetService("HttpService"):JSONEncode(Sync.Data);
	local OldData = game:GetService("HttpService"):JSONEncode(DataStore:GetAsync("SyncData"));
	
	--print(OldData);
	--[[local Cheer = require(game.Workspace.Cheer);
	for _, Difference in pairs(Cheer.GetStructureDiff(NewData,OldData)) do
	    print('Path:', table.concat(Difference.Path, ', '));
	    print('Value:', Difference.Value);
	end;]]

	if NewData ~= OldData then
		DataStore:SetAsync("SyncData",Sync.Data); 														print("Sync Datastore Overrided.")
	end;
	
	DataStore:OnUpdate("SyncData",function(Data)
		Sync.Data = Data;
		ColorData();
		print("Sync Data Updated.");
	end);																								print("OnUpdate connected.")
	
	ColorData();																					 	print("Sync Data colored.")
	
	Sync.SyncMaps = function()
		for MapName,MapData in pairs(Sync.Data["Map"]) do
			local FoundMap = game.ServerStorage.Maps:FindFirstChild(MapName)
			if not FoundMap or (FoundMap and FoundMap:FindFirstChild("AssetID") and FoundMap.AssetID.Value~=MapData.MapID) then
				if FoundMap and FoundMap.AssetID.Value~=MapData.ID then FoundMap:Destroy(); end;
				local NewMap = game.InsertService:LoadAsset(MapData["MapID"]);
				local Map = NewMap:GetChildren()[1];
				local AssetValue = Instance.new("IntValue",Map);
				AssetValue.Name = "AssetID";
				AssetValue.Value = MapData.MapID;
				Map.Parent = game.ServerStorage.Maps;
			end
		end
	end; 																								print(5)

end;

print("Setup Succesful, initializing syncing...");

local DataCallSuccess,ErrorMessage = pcall(InitializeSync);

if not DataCallSuccess then
	--spawn(function()
		--[[repeat
			print("Sync failed to initialize... Retrying...");
			print("Error: " .. ErrorMessage);
			wait(30)
			DataCallSuccess = pcall(InitializeSync);
		until DataCallSuccess;]]
	--end);
	
	print("Sync failed to initialize... Retrying...");
	print("Error: " .. ErrorMessage);
	DataStore:OnUpdate("SyncData",function(Data)
		Sync.Data = Data;
		ColorData();
		print("Sync Data Updated.");
	end);																								
	ColorData();
	Sync.SyncMaps = function()
		for MapName,MapData in pairs(Sync.Data["Map"]) do
			local FoundMap = game.ServerStorage.Maps:FindFirstChild(MapName)
			if not FoundMap or (FoundMap and FoundMap:FindFirstChild("AssetID") and FoundMap.AssetID.Value~=MapData.MapID) then
				if FoundMap and FoundMap.AssetID.Value~=MapData.ID then FoundMap:Destroy(); end;
				local NewMap = game.InsertService:LoadAsset(MapData["MapID"]);
				local Map = NewMap:GetChildren()[1];
				local AssetValue = Instance.new("IntValue",Map);
				AssetValue.Name = "AssetID";
				AssetValue.Value = MapData.MapID;
				Map.Parent = game.ServerStorage.Maps;
			end
		end
	end; 
	
end;



print("Sync loaded.");

return Sync;
