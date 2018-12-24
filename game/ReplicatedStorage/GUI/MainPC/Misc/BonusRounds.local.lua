local GameGUI = script.Parent.Parent.Game;
local BonusRoundFrame = GameGUI.BonusRoundSelect;

local PlayerVotes = {};
local RandomModes = {[1]="";[2]="";[3]="";};
local LastUpdate = 0;
local Icons = require(game.ReplicatedStorage.BonusRoundIcons)
local BWIcons = require(game.ReplicatedStorage.BonusRoundIconsBW);
local VoteButton = nil;

local L2N = {
	["a"] = 1;
	["b"] = 2;
	["c"] = 3;
};
local N2L = {[1]="a";[2]="b";[3]="c";};

local Connections = {};
local function UpdateVotes()
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

	for _,Connection in pairs(Connections) do Connection:disconnect(); end;
	local i = 1;
	for _,VoteData in pairs(SortedVotes) do
		local VoteIndex = L2N[VoteData.VI];
		local VoteCount = VoteData.VC;
		local VoteFrame = BonusRoundFrame.Voting["Vote"..VoteIndex];
		VoteFrame.VoteBar.Bar.VoteCount.Text = VoteCount;
		
		local VotePercentage = (VoteCount==0 and TotalVotes==0 and 0) or VoteCount/TotalVotes;
					
		VoteFrame.VoteBar.Bar:TweenSize(UDim2.new(VotePercentage,0,1,0),"Out","Quad",0.2,true);
		VoteFrame.VoteBar.Bar.BackgroundColor3 =
			(i==1 and Color3.new( 0,186/255,0 )) or
			(i==2 and Color3.new( 227/255, 127/255, 26/255  )) or
			(i==3 and Color3.new( 203/255, 31/255, 34/255 ));
		for _,VD in pairs(SortedVotes) do
			if VD.VI ~= VoteData.VI and VD.VC == VoteCount then
				VoteFrame.VoteBar.Bar.BackgroundColor3 = Color3.new( 247/255,230/255,33/255 );
			end
		end;
		
		VoteFrame.VoteBar.Bar.VoteCount.Visible = (VoteCount>0);
		VoteFrame.VoteBar.Bar.BackgroundColor3 = (VoteCount<1 and Color3.new(0.4,0.4,0.4)) or VoteFrame.VoteBar.Bar.BackgroundColor3;
		
		VoteFrame.Icon.Image = Icons[RandomModes[VoteIndex]] or "";
		
		local Deb = false;
		table.insert(Connections,VoteFrame.Vote.MouseButton1Click:connect(function()
			if Deb then return; else Deb = true; end;
			if VoteButton == VoteFrame.Vote then
				VoteButton = nil;
				VoteFrame.Vote.Style = Enum.ButtonStyle.RobloxRoundButton;
				game.ReplicatedStorage.VoteForMode:FireServer(nil);
			else
				if VoteButton then VoteButton.Style = Enum.ButtonStyle.RobloxRoundButton; end;
				VoteButton = VoteFrame.Vote;
				VoteFrame.Vote.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
				game.ReplicatedStorage.VoteForMode:FireServer(VoteIndex);
			end;
		end));
		
		i=i+1;
	end
end

game.ReplicatedStorage.VoteForMode.OnClientEvent:connect(function(Votes,Time)
	if Time > LastUpdate then
		PlayerVotes = Votes;
		LastUpdate = Time;
		UpdateVotes();
	end
end)

local Stage = "Nothing";

game.ReplicatedStorage.VoteBonusRoundComplete.OnClientEvent:connect(function(CurrentMode)
	Stage = "Loading";
	local CurrentModeFrame = BonusRoundFrame.Title.Container.ModeContainer["Mode"..2];
	CurrentModeFrame.Icon.Image = Icons[CurrentMode] or "";
	CurrentModeFrame.QMark.Visible = false;
	CurrentModeFrame.Locked.Visible = false;
	CurrentModeFrame.ModeName.Text = "";
	BonusRoundFrame.Voting.Visible = false;
	BonusRoundFrame.Loading.Visible = (not BonusRoundFrame.BuyMode.Visible);
	BonusRoundFrame.Loading[CurrentMode].Visible = true;
end)

BonusRoundFrame.Loading.Close.MouseButton1Click:connect(function()
	BonusRoundFrame.Visible = false;
end);

--[[
GameGUI.Settings.Queue.MouseButton1Click:connect(function()
	BonusRoundFrame.Visible = not BonusRoundFrame.Visible;
end)]]
--[[
local BuyingIndex;
for _,Frame in pairs(BonusRoundFrame.BuyMode:GetChildren()) do
	Frame.Buy.MouseButton1Click:connect(function()
		game.ReplicatedStorage.BuyMode:FireServer(Frame.Name,BuyingIndex);
	end)
end
--]]
game.ReplicatedStorage.BuyMode.OnClientEvent:connect(function(Index,GameMode)
	local ModeFrame = BonusRoundFrame.Title.Container.ModeContainer["Mode"..Index];
	ModeFrame.Icon.Image = Icons[GameMode] or "";
	ModeFrame.ModeName.Text = "";
	ModeFrame.QMark.Visible = false;
	local Overhead = BonusRoundFrame.Title.Container.OverheadContainer["Mode"..Index];
	Overhead.Buy.Visible = false;
	Overhead.Purchased.Visible = true;
end)


local function UpdateQueue(BonusRoundQueue,CurrentMode,RandomM,StartVoting)
	BonusRoundFrame.Title.Container.ModeContainer:ClearAllChildren();
	BonusRoundFrame.Title.Container.OverheadContainer:ClearAllChildren();
	for Index,GameModeName in pairs(BonusRoundQueue) do
		local ModeFrame = script.GameMode:Clone();
		ModeFrame.QMark.Visible = (GameModeName=="Locked"or GameModeName=="Random");
		ModeFrame.ModeName.Text = (GameModeName=="Locked"or GameModeName=="Random") and "Random" or "";
		ModeFrame.Locked.Visible = (GameModeName=="Locked");
		ModeFrame.Icon.Image = Icons[GameModeName] or "";
		if Index==1 then
			ModeFrame.BackgroundColor3 = Color3.new(40/255,40/255,40/255);
			ModeFrame.BorderColor3 = Color3.new(25/255,25/255,25/255);
			ModeFrame.ModeName.TextColor3 = Color3.new(59/255,59/255,59/255);
			ModeFrame.QMark.TextColor3 = Color3.new(59/255,59/255,59/255);
			ModeFrame.Icon.Image = BWIcons[GameModeName]or"";
		end
		ModeFrame.Position = UDim2.new(0,(Index-1)*(76+7),0,4);
		ModeFrame.Name = "Mode"..Index;
		ModeFrame.Parent = BonusRoundFrame.Title.Container.ModeContainer;
		
		local OverheadFrame = script.Overhead:Clone();
		local NextUp = (Index==2);		
		local Buy = (GameModeName=="Random");
		local Purchased = (GameModeName~="Random"and GameModeName~="Locked");
		local Buyable = (Buy and not NextUp);
		OverheadFrame.Name = "Mode"..Index;
		
		OverheadFrame.Buy.Visible = false;
		--[[
		if Buyable then
			OverheadFrame.Buy.MouseButton1Click:connect(function()
				if BuyingIndex ~= Index then
					BonusRoundFrame.BuyMode.Visible = true;
					BonusRoundFrame.Loading.Visible = false;
					BonusRoundFrame.Voting.Visible = false;
					BonusRoundFrame.Nothing.Visible = false;
					BuyingIndex = Index;

					for _,OV in pairs(BonusRoundFrame.Title.Container.OverheadContainer:GetChildren()) do
						OV.Buy.Style = (OV==OverheadFrame and Enum.ButtonStyle.RobloxRoundButton) or Enum.ButtonStyle.RobloxRoundDefaultButton;
					end
					
				else
					BuyingIndex = nil;
					OverheadFrame.Buy.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					BonusRoundFrame.BuyMode.Visible = false;
					BonusRoundFrame.Loading.Visible = Stage=="Loading";
					BonusRoundFrame.Voting.Visible = Stage=="Voting";
					BonusRoundFrame.Nothing.Visible = Stage=="Nothing";
				end;
				-- game.ReplicatedStorage.BuyMode:FireServer(Index);
			end)
		end
		--]]
		OverheadFrame.Locked.Visible = (GameModeName=="Locked" and not NextUp);
		OverheadFrame.Next.Visible = NextUp;
		OverheadFrame.Purchased.Visible = Purchased and not NextUp;
		OverheadFrame.Position = UDim2.new(0,(Index-1)*(76+7),0,-2);
		OverheadFrame.Parent = BonusRoundFrame.Title.Container.OverheadContainer;
			
	end
	
	if StartVoting then
		BonusRoundFrame.Nothing.Visible = false;
		if RandomM then
			RandomModes = RandomM;
			BonusRoundFrame.Voting.Visible = true;
			Stage = "Voting";
		else
			RandomModes = {};
			BonusRoundFrame.Voting.Visible = false;
			BonusRoundFrame.Loading.Visible = true;
			Stage = "Loading";
			BonusRoundFrame.Loading[CurrentMode].Visible = true;
		end;
		UpdateVotes();
	end;
	
end

game.ReplicatedStorage.VoteBonusRound.OnClientEvent:connect(function(BonusRoundQueue,CurrentMode,RandomM)
	UpdateQueue(BonusRoundQueue,CurrentMode,RandomM,true);
	BonusRoundFrame.Visible = true;
end)

local BonusRoundQueue = game.ReplicatedStorage.GetQueue:InvokeServer();
UpdateQueue(BonusRoundQueue);

