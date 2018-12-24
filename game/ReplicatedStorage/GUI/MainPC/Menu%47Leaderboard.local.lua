local MainGUI = script.Parent.Game;
local LocalPlayer = game.Players.LocalPlayer;

local RankIcons = require(game.ReplicatedStorage.RankIcons);
local Leaderboard = MainGUI.Leaderboard;

local PrestigeTexts = {
	[0]	= "";
	[1]	= "I";
	[2]	= "II";
	[3]	= "III";
	[4]	= "IV";
	[5]	= "V";
	[6]	= "VI";
	[7]	= "VII";
	[8]	= "VIII";
	[9]	= "IX";
	[10]= "X";
};

local Selecting = false;
local Select = 0;
local Selector = Leaderboard.Selector;

local NameTags = game.ReplicatedStorage.GetSyncData:InvokeServer("NameTags");

local LevelData = {};

function UpdateLeaderboard()
	
	local PlayerTable = {}
	for _,Player in pairs(game.Players:GetPlayers()) do
		if not LevelData[Player.Name] then
			local Level,Prestige,Elite = game.ReplicatedStorage.GetPlayerLevel:InvokeServer(Player);
			if Level~=nil and Prestige ~=nil and Elite ~= nil then
				LevelData[Player.Name] = {};
				LevelData[Player.Name].Level = Level;
				LevelData[Player.Name].Prestige = Prestige;
				LevelData[Player.Name].Elite = Elite;
			end;
		end
		
		if LevelData[Player.Name] ~= nil and LevelData[Player.Name].Level ~= nil and LevelData[Player.Name].Prestige ~=nil and LevelData[Player.Name].Elite ~= nil then
			table.insert(PlayerTable,{
				Player = Player;
				LD = LevelData[Player.Name];
			});
		end;
	end	
	
	table.sort(PlayerTable,function(a,b)
		if a.Elite and not b.Elite then
			return true;
		elseif b.Elite and not a.Elite then
			return false;
		else
			local SortLevelA = (a.LD.Prestige*100)+a.LD.Level;
			local SortLevelB = (b.LD.Prestige*100)+b.LD.Level;
			return SortLevelA > SortLevelB;
		end;
	end)

	for _,Obj in pairs(Leaderboard:GetChildren()) do
		if Obj.Name ~= "Controller" and Obj.Name ~= "Selector" and Obj.Name ~= "TradeText" and Obj.Name~="Requests" and Obj.Name~="FriendsOnline" then
			Obj:Destroy();
		end
	end

	Leaderboard.Size = UDim2.new(0,-210,0,#PlayerTable*30);
	
	for i,Table in pairs(PlayerTable) do
		
		local Player = Table.Player;
		
		if Player ~= nil then
			local NewLabel = script:WaitForChild("PlayerLabel"):Clone();
			NewLabel.Name = "Player" .. i;
			NewLabel.Position = UDim2.new(0,5,0,(i-1)*30);
			local LD = LevelData[Player.Name];
			
			NewLabel.Level.Image = RankIcons[LD.Level];
			NewLabel.Level.Prestige.Text = PrestigeTexts[LD.Prestige];

			local Prefix = "";
			if LD.Elite then 
				NewLabel.TextColor3 = Color3.new(232/255,42/255,42/255);
				Prefix = "[ELITE] ";
			end

			local PlayerObj = Instance.new("ObjectValue",NewLabel);
			PlayerObj.Name = "PlayerObj";
			PlayerObj.Value = Player;
			NewLabel.Text = Prefix .. Player.Name;
			
			local Color = NameTags[ tostring(Player.userId) ];			
			
			if Color then
				NewLabel.TextColor3 = Color;
			end
			
			NewLabel.Parent = Leaderboard;
			
			if Player == LocalPlayer then
				NewLabel.TextStrokeColor3 = Color3.new(15/255,15/255,15/255);
			end
			
			NewLabel.Button.MouseButton1Click:connect(function()
				_G.MenuPlayer = Player;
				MainGUI.PlayerMenu.Position = UDim2.new(1,-213,0,NewLabel.Position.Y.Offset+3);
				MainGUI.PlayerMenu.Visible = not MainGUI.PlayerMenu.Visible;
			end)
			
			NewLabel.Button.Selectable = true;
			NewLabel.Button.Selectable = false;
		end;
	end
	
	if Leaderboard.Size.Y.Offset > 100 then
		MainGUI.PlayerMenu.Close.Size = UDim2.new(0,500,0,Leaderboard.Size.Y.Offset+10+MainGUI.Leaderboard.Size.Y.Offset)
	else
		MainGUI.PlayerMenu.Close.Size = UDim2.new(0,500,0,110);
	end
	wait(1);
	UpdateLeaderboard();
end


MainGUI.PlayerMenu.Close.MouseLeave:connect(function()
	MainGUI.PlayerMenu.Visible = false;
end)

UpdateLeaderboard();

--game.ReplicatedStorage.UpdateLeaderboard.OnClientEvent:connect(UpdateLeaderboard);