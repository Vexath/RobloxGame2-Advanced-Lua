local Module = {}

local Gets = script.Parent.Parent.Get

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Data = require(script.Parent.Parent.DataModule);

Module.Gun = function(Player)
	local Sync = Get("Sync");
	local ItemsDB = Sync.Data["Item"];
	
	local NewItem = game.ServerStorage.Default.PillowLauncher:Clone();
	
	if NewItem:FindFirstChild("Script") then
		NewItem.Script:Destroy()
	end
	
	local NewScript = game.ServerStorage.GunScripts.ClassicScript:Clone()
	NewScript.Parent = NewItem;
	
	NewItem.CanBeDropped = false;
	NewItem.Parent = Player.Backpack;
	return NewItem;
end

Module.Knife = function(Player)
	local Sync = Get("Sync");
	local ItemsDB = Sync.Data["Item"];
	local KnifeID = ItemsDB[Data.Get(Player,"Weapons").Equipped.Knife];
	local NewItem = game.ServerStorage.Default.Pillow:Clone();
	pcall(function() NewItem = game.InsertService:LoadAsset(KnifeID["ItemID"]):GetChildren()[1]; NewItem.TextureId = KnifeID.Image; end);
	
	if NewItem:FindFirstChild("Script") then
		NewItem.Script:Destroy()
	end
	
	local NewScript = game.ServerStorage.KnifeScripts.ClassicScript:Clone()
	NewScript.Parent = NewItem;
	

	NewItem.CanBeDropped = false;
	NewItem.Parent = Player.Backpack;
	return NewItem;
end


return Module;