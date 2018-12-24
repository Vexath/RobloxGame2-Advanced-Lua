return function(Player,RecipeID,RecipeData)
	local Rarity = RecipeData.Rarity;
	local ItemTable = {};
	local Items = game.ReplicatedStorage.GetSyncDataServer:Invoke("Item");
	local Boxes = game.ReplicatedStorage.GetSyncDataServer:Invoke("MysteryBox");
	local OldCraftingWeapons = game.ReplicatedStorage.GetSyncDataServer:Invoke("OldRecipe");

	for BoxID,BoxData in pairs(Boxes) do
		if BoxData.Type == "Weapons" and BoxData.Contents then
			for _,ItemID in pairs(BoxData.Contents) do
				if Items[ItemID] and Items[ItemID].Rarity == Rarity then
					table.insert(ItemTable,ItemID);
				end
			end
		end
	end;
	
	for ItemID,_ in pairs(OldCraftingWeapons) do
		if Items[ItemID].Rarity == Rarity then
			table.insert(ItemTable,ItemID);
		end
	end
	
	local Item = ItemTable[math.random(1,#ItemTable)];
	
	return Item,1,"Weapons";
end