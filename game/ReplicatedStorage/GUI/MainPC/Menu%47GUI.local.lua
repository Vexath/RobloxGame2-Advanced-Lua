local MainGUI = script.Parent.Game;
local LocalPlayer = game.Players.LocalPlayer;

local Scoreboard = MainGUI.Scoreboard;

_G.LockTarget = nil;
LocalPlayer.CameraMode = Enum.CameraMode.Classic;

local SyncedData = {};
function GetSyncData(DataName) 
	if SyncedData[DataName] == nil then
		SyncedData[DataName] = game.ReplicatedStorage.GetSyncData:InvokeServer(DataName);
	end
	return SyncedData[DataName];
end
game.ReplicatedStorage.UpdateSyncedData.OnClientEvent:connect(function(DataName,Data)
	SyncedData[DataName] = Data;
end)

local LevelCap = 82500;
local RankIcons = require(game.ReplicatedStorage.RankIcons);
local CodeImages = require(game.ReplicatedStorage.CodeImages);


local LevelIcon = MainGUI.Level;

function GetData(DataName)
	return game.ReplicatedStorage.GetData:InvokeServer(DataName)
end

function GetLevel(XP)
	return math.floor((25 + math.sqrt(625 + 300 * XP))/50);
end 


function UpdateLevel()
	local XP = GetData("XP")
	local Bar = LevelIcon:WaitForChild("XPBar").XP;
	LevelIcon.LevelText.Text = GetLevel(XP);
	local Progress = ((25 + math.sqrt(625 + 300 * XP))/50)%1/1
	Bar.Size = UDim2.new(Progress,Bar.Size.X.Offset,Bar.Size.Y.Scale,Bar.Size.Y.Offset)
	--LevelIcon.Image = RankIcons[GetLevel(XP)];
	if GetLevel(XP) >= 100 then
		LevelIcon.Prestige.Visible = true;
	else
		LevelIcon.Prestige.Visible = false;
	end;
end

LevelIcon.Prestige.MouseButton1Click:connect(function()
	MainGUI.Prestige.Visible = true;
end)

MainGUI.Prestige.Accept.MouseButton1Click:connect(function()
	game.ReplicatedStorage.Prestige:FireServer();
	MainGUI.Prestige.Visible = false;
	UpdateLevel();
end)

MainGUI.Prestige.Decline.MouseButton1Click:connect(function()
	MainGUI.Prestige.Visible = false;
end)


function comma_value(amount)
  local formatted = amount

  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end	

function UpdateCash()
	local Credits = _G.PlayerData.Credits;
	local Gems = _G.PlayerData.Gems;
	--MainGUI.Inventory.Equipped.CreditsLabel.Text = comma_value(Credits);
	MainGUI.Shop.Cash.Icon.Container.Amount.Text = comma_value(Credits);
	MainGUI.Shop.Gems.Icon.Container.Amount.Text = comma_value(Gems);
end

game.ReplicatedStorage.UpdateDataClient.Event:connect(function()
	UpdateCash();
	UpdateLevel();
end);

game.ReplicatedStorage.UpdateData2.OnClientEvent:connect(function()
	UpdateCash();
	UpdateLevel();
end)

UpdateCash();



game.ReplicatedStorage.GiveXP.OnClientEvent:connect(function(Amount)
	local XPGain = script.XPGain:Clone();
	XPGain.Text = "+" .. Amount*10 .. " XP";
	XPGain.Parent = LevelIcon;
	wait(0.5);
	for i = 1,10 do
		XPGain.TextTransparency = i/10;
		wait(0.1);
	end
end)

game.ReplicatedStorage.SpecialXPEvent.OnClientEvent:connect(function(Text)
	local XPText = script.XPText:Clone();
	XPText.Text = Text;
	XPText.Parent = MainGUI;
	game.Debris:AddItem(XPText,2);
end)


local EarnedXP = MainGUI.EarnedXP;
local Playing = false;

LocalPlayer.Backpack.ChildAdded:connect(function(Child)
	if Child.Name == "Gun" then
		EarnedXP.Dead.Visible = true;
		EarnedXP.XPText.TextColor3 = BrickColor.new("Medium stone grey").Color;
		EarnedXP.VictoryLabel.TextColor3 = BrickColor.new("Medium stone grey").Color;
		Playing = false;
		wait(2);
		EarnedXP.Visible = false;
	end
end)

UpdateLevel();


game.Players.LocalPlayer.Character.Humanoid.Died:connect(function()
	MainGUI.Parent.Dead.Visible = true;
	EarnedXP.Dead.Visible = true;
	EarnedXP.XPText.TextColor3 = BrickColor.new("Medium stone grey").Color;
	EarnedXP.VictoryLabel.TextColor3 = BrickColor.new("Medium stone grey").Color;
	Playing = false;
	wait(0.15)
	MainGUI.Parent.Dead.BackgroundColor3 = Color3.new(0,0,0);
end)


MainGUI.GetElite.Info.Buy.MouseButton1Down:connect(function()
	game.ReplicatedStorage.GetElite:FireServer();
	MainGUI.GetElite.Visible = false;
end)

MainGUI.GetElite.Info.Cancel.MouseButton1Down:connect(function()
	MainGUI.GetElite.Visible = false;
end)

game.ReplicatedStorage.GetElite.OnClientEvent:connect(function()
	MainGUI.Shop.Visible = false;
	MainGUI.GetElite.Visible = true;
end)

game.ReplicatedStorage.RoundStart.OnClientEvent:connect(function(GameTimer)
	local PlayerData = game.ReplicatedStorage.GetPlayerData:InvokeServer()
	if PlayerData[LocalPlayer.Name] ~= nil then
		if PlayerData[LocalPlayer.Name]["Role"] == "Innocent" then
			Playing = true;
			local XPEarned = 0;
			EarnedXP.XPText.Text = XPEarned;
			EarnedXP.Visible = true;
			while Playing do
				wait(1);
				XPEarned = XPEarned + 10;
				EarnedXP.XPText.Text = XPEarned;
			end
		else
			Playing = true;
			local Timer = GameTimer + 1;
			MainGUI.Timer.Visible = true;
			MainGUI.RoleSelector.Visible = false;
			while Playing do
				wait(1);
				Timer = Timer - 1;
				MainGUI.Timer.XPText.Text = Timer;
				if Timer <= 30 then
					MainGUI.Timer.XPText.TextColor3 = Color3.new(255,0,0);
				end
			end
		end 
	end;
end)

function CountInnocentsAlive(PlayerData)
	local Count = 0;
	for PlayerName,Data in pairs(PlayerData) do
		if Data["Role"] == "Innocent" and Data["Dead"] == false then
			Count = Count + 1;
		end
	end
	return Count;
end

function CountInnocentsDead(PlayerData)
	local Count = 0;
	for PlayerName,Data in pairs(PlayerData) do
		if (Data["Role"] == "Innocent" or Data["Role"] == "Gunner") and Data["Dead"] == true then
			Count = Count + 1;
		end
	end
	return Count;
end


game.ReplicatedStorage.LevelUp.OnClientEvent:connect(function(OldRankImage,NewRankImage)
	local Vote = Instance.new("Sound",script.Parent);
	Vote.SoundId = "http://www.roblox.com/asset/?id=169038670";
	Vote.Volume = 0.7;
	Vote.Looped = false;
	Vote.PlayOnRemove = false;
	--Vote:Play();
	MainGUI.RankUp.Visible = true;
	MainGUI.OldRank.Image = OldRankImage;
	MainGUI.NewRank.Image = NewRankImage;
	MainGUI.OldRank.Visible = true;
	wait(1);
	MainGUI.OldRank:TweenPosition(UDim2.new(0, -150, 1, -250), "Out", "Quad", 0.5, false)
	MainGUI.NewRank:TweenPosition(UDim2.new(0.5,-75, 1, -250), "Out", "Quad", 0.5, false)
	wait(4);
	MainGUI.RankUp.Visible = false;
	MainGUI.OldRank.Visible = false;
	MainGUI.NewRank.Visible = false;
end)

game.ReplicatedStorage.SpecialRound.OnClientEvent:connect(function()
	local Vote = Instance.new("Sound",script.Parent);
	Vote.SoundId = "http://www.roblox.com/asset/?id=136938019";
	Vote.Volume = 0.7;
	Vote.Looped = false;
	Vote.PlayOnRemove = false;
	Vote:Play();
	MainGUI.SpecialRound:TweenPosition(UDim2.new(0.5, -250, 0.5, -125), "Out", "Quad", 0.5, false);
	MainGUI.SpecialRound.Visible = true;
	wait(5);
	MainGUI.SpecialRound.Visible = false;
	Vote:Stop();
end);


repeat wait() until LocalPlayer.Character ~= nil;
wait();
LocalPlayer.CameraMode = "Classic";
LocalPlayer.CameraMinZoomDistance = 7;
wait(0.5);
LocalPlayer.CameraMinZoomDistance = 0.5;
game.StarterGui:SetCoreGuiEnabled("Health",false);
game.StarterGui:SetCoreGuiEnabled("PlayerList",false);

local Version = game.ReplicatedStorage.GetVersion:InvokeServer();
MainGUI.Dock.Version.Text = Version;


MainGUI.Dock.Touch.Visible = game:GetService("UserInputService").TouchEnabled;

local Open = true;
MainGUI.Dock.Touch.Button.MouseButton1Click:connect(function()
	Open = not Open;
	MainGUI.Dock.Touch.Title.Text = (Open and "<") or ">";
	MainGUI.Dock:TweenPosition(
		UDim2.new(0, (Open and 0) or -135, 0.5, -150),
		"Out","Quad",0.2,true
	);
end)


