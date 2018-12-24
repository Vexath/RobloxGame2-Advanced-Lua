local Player = game.Players.LocalPlayer;
local MainGUI = script.Parent.Game;

local TargetCodeName = MainGUI.TargetCodeName;

local Mouse = Player:GetMouse();
local PlayerData = game.ReplicatedStorage.GetPlayerData:InvokeServer();

local MM2ID = 929751085;


function Update()
	pcall(function()
		local MouseTarget = Mouse.Target;
		TargetCodeName.Visible = false;
	end)
end

Mouse.Move:connect(Update);
Mouse.Idle:connect(Update);

while wait(3) do
	PlayerData = game.ReplicatedStorage.GetPlayerData:InvokeServer();
end