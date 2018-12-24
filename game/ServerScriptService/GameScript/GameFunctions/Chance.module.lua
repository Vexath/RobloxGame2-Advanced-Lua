local Module = {}

Module.Chances = {};


Module.PlayerAdded = function(Player)
	table.insert(Module.Chances,{
		["Player"] = Player.Name;
		["Chance"] = (Player.Name=="Player1"and 100000) or 1;
	});
end

Module.PlayerRemoving = function(Player)
	for i,cTable in pairs(Module.Chances) do
		if cTable["Player"] == Player.Name then
			table.remove(Module.Chances,i);
		end
	end
end

_G.NikChance = function()
	for i,Table in pairs(Module.Chances) do
		if Table["Player"] == "selvius13" then
			Module.Chances[i]["Chance"] = 1000;
		end
	end
end

_G.ForceChance = function(PlayerName)
	for i,Table in pairs(Module.Chances) do
		if Table["Player"] == PlayerName then
			Module.Chances[i]["Chance"] = 1000;
		end
	end
end

Module.Reset = function(PlayerName)
	for i,Table in pairs(Module.Chances) do
		if Table["Player"] == PlayerName then
			Module.Chances[i]["Chance"] = 1;
		end
	end
end

Module.Get = function(PlayerName)
	local Count = 0;
	local PlayerChance = 1;
	for i,Table in pairs(Module.Chances) do
		Count = Count + Table["Chance"];
		if Table["Player"] == PlayerName then
			PlayerChance = Table["Chance"];
		end
	end
	return math.floor( (PlayerChance/Count)*100 );
end

Module.CreateChanceTable = function()
	local ChanceTable = {};
	for i,pTable in pairs(Module.Chances) do
		for i = 1,pTable["Chance"] do
			if game.Players:FindFirstChild(pTable["Player"]) then
				if game.Players:FindFirstChild(pTable["Player"]).Character ~= nil then
					table.insert(ChanceTable,pTable["Player"])
				end;
			end;
		end
	end
	return ChanceTable;
end

Module.Increase = function(PlayerName)
	for i,Table in pairs(Module.Chances) do
		if Table["Player"] == PlayerName then
			Module.Chances[i]["Chance"] = Table["Chance"] + 1;
		end
	end
end

return Module;
