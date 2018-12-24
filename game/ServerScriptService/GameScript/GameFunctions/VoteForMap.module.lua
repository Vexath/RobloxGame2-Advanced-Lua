local Gets = script.Parent.Parent.Get
function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

local Data = require(script.Parent.Parent.DataModule);

local Module = function()
	local GameFunctions = Get("GameFunctions");
	local Vote1 = game.Workspace.VoteIcons.VotePad1;
	local Vote2 = game.Workspace.VoteIcons.VotePad2;
	local Vote3 = game.Workspace.VoteIcons.VotePad3;
	
	local Map1;
	local Map2;
	local Map3;
	
	game.ReplicatedStorage.MapVote:FireAllClients();
	
	local GameMode = Get("GameMode")
	local Sync = Get("Sync");
	
	local CompatibleMaps = {};
	
	for MapName,MapTable in pairs(Sync.Data["Map"]) do
		for _,GameModeName in pairs(MapTable["GameModes"]) do
			if GameModeName == GameMode.Name then
				table.insert(CompatibleMaps,MapName)
			end
		end
	end
	
	if #CompatibleMaps >= 3 then
		Map1 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
		repeat 
			Map2 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
		until Map2 ~= Map1;
		
		repeat 
			Map3 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
		until Map3 ~= Map2 and Map3 ~= Map1;
	else
		Map1 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
		Map2 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
		Map3 = game.ServerStorage.Maps[CompatibleMaps[math.random(1,#CompatibleMaps)]];
	end
	
	local SelectedMap;
	
	Vote1.Voting.Value = true;
	Vote2.Voting.Value = true;
	Vote3.Voting.Value = true;
	
	Vote1.Map.Value = Map1;
	Vote2.Map.Value = Map2;
	Vote3.Map.Value = Map3;
	
	wait(10);
	
	game.ReplicatedStorage.DoneVoteMap:FireAllClients();
	
	local Votes1 = Vote1.Votes.Value;
	local Votes2 = Vote2.Votes.Value;
	local Votes3 = Vote3.Votes.Value;
	
	if Votes1 > Votes2 and Votes1 > Votes3 then
		SelectedMap = Map1;
	elseif Votes2 > Votes1 and Votes2 > Votes3 then
		SelectedMap = Map2;
	elseif Votes3 > Votes1 and Votes3 > Votes2 then
		SelectedMap = Map3;
	elseif (Votes1 == Votes2) and Votes1 > Votes3 and Votes2 > Votes3 then
		local MapNumber = math.random(1,2)
		if MapNumber == 1 then
			SelectedMap = Map1;
		else 
			SelectedMap = Map2;
		end
	elseif (Votes1 == Votes3) and Votes1 > Votes2 and Votes3 > Votes2 then
		local MapNumber = math.random(1,2)
		if MapNumber == 1 then
			SelectedMap = Map1;
		else 
			SelectedMap = Map3;
		end
	elseif (Votes2 == Votes3) and Votes2 > Votes1 and Votes3 > Votes1 then
		local MapNumber = math.random(1,2)
		if MapNumber == 1 then
			SelectedMap = Map2;
		else 
			SelectedMap = Map3;
		end
	else
		local MapNumber = math.random(1,3)
		if MapNumber == 1 then
			SelectedMap = Map1;
		elseif MapNumber == 2 then
			SelectedMap = Map2;
		elseif MapNumber == 3 then
			SelectedMap = Map3;
		end
	end
	
	Vote1.Voting.Value = false;
	Vote2.Voting.Value = false;
	Vote3.Voting.Value = false;
	
	return SelectedMap:Clone();
end

return Module;
