local Gets = script.Parent.Parent.Get
function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end
local Data = require(script.Parent.Parent.DataModule);

local L2N = {["a"] = 1;["b"] = 2;["c"] = 3;};
local N2L = {[1]="a";[2]="b";[3]="c";};

local Module = function(PlayerVotes)
	
	local CollectedVotes = {
		["a"] = 0;
		["b"] = 0;
		["c"] = 0;	
	};
	
	local TotalVotes = 0;
	for _,VI in pairs(PlayerVotes) do
		local VoteIndex = N2L[VI];
		CollectedVotes[VoteIndex] = CollectedVotes[VoteIndex] + 1;
		TotalVotes = TotalVotes+1;
	end
	
	local SortedVotes = {};
	
	for VoteIndex,VoteCount in pairs(CollectedVotes) do
		table.insert(SortedVotes,{
			VI = VoteIndex;
			VC = VoteCount;
		});
	end;
	table.sort(SortedVotes,function(a,b)
		return a.VC>b.VC;
	end);
	
	local FinalModes = {};
	local HighestCount = SortedVotes[1].VC;
	for _,VoteData in pairs(SortedVotes) do
		if VoteData.VC == HighestCount then
			table.insert(FinalModes,VoteData);
		end
	end
	
	return L2N[FinalModes[math.random(1,#FinalModes)].VI];
end

return Module;
