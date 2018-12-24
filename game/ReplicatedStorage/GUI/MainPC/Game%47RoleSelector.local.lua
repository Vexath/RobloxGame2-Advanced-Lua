local GameGUI = script.Parent.Game;
local RoleSelector = GameGUI.RoleSelector;


for _,Sound in pairs(script:GetChildren()) do
	game:GetService("ContentProvider"):Preload(Sound.SoundId)
end

game.ReplicatedStorage.Fade.OnClientEvent:connect(function()
	GameGUI.BonusRoundSelect.Visible = false;
	game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(0)
	for i = 1,30 do
		GameGUI.Fade.Transparency = GameGUI.Fade.Transparency - 1/30;
		game:GetService("RunService").RenderStepped:wait();
	end
end)

game.ReplicatedStorage.LoadingMap.OnClientEvent:connect(function(SpecialRound)
	GameGUI.Waiting.Image = "rbxassetid://2641616890";
end)

local ItemsDB = game.ReplicatedStorage.GetSyncData:InvokeServer("Item");

local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";
local function GetImage(Image) 
	local Return;
	if _G.Cache[Image] ~= nil then 
		return _G.Cache[Image];
	else
		local NewImage = (tonumber(Image) and AssetURL..Image) or Image; 
		NewImage = NewImage .. "&bust="..math.random(1,10000); 
		_G.Cache[Image] = NewImage;
		return NewImage; 
	end;
end;


local Colors = {
	["Innocent"] = Color3.new(0,1,0);
	["Gunner"] = Color3.new(0,0,1);
	["Knifer"] = Color3.new(1,0,0);
	["Zombie"] = Color3.new(25/255, 172/255, 0);
	["Survivor"] = Color3.new(43/255,154/255,238/255);		
	["Red"] = Color3.new(217/255, 35/255, 35/255);
	["Blue"] = Color3.new(63/255, 176/255, 224/255);
	["Monster"] = Color3.new(217/255, 35/255, 35/255);
	["MonsterHunter"] = Color3.new(63/255, 176/255, 224/255);
};

local Stop = {
	["Innocent"] = 13;
	["Gunner"] = 14;
	["Knifer"] = 15;
};
local RoleIndexes = {
	["Classic"] = {"Innocent","Gunner","Knifer"};
	["Infection"] = {"Survivor","Zombie"};
};

game.ReplicatedStorage.RoleSelect.OnClientEvent:connect(function(Role,Color,CodeName,LockFirstPerson,GameMode,Target,Knife)
	GameGUI.Waiting.Visible = false;
	for i = 1,30 do
		GameGUI.Fade.Transparency = GameGUI.Fade.Transparency + 1/30;
		game:GetService("RunService").RenderStepped:wait();
	end
	game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(0.5);
	if GameMode == "Classic" then
		RoleSelector.Chance.Text = "Your chance to be Knifer: "
		spawn(function() RoleSelector.Chance.Text = "Your chance to be Knifer: " .. game.ReplicatedStorage.GetChance:InvokeServer() .. "%";end);
	end;
	RoleSelector.Visible = true;
	
	if GameMode == "Classic" then
		local RoleIndex = RoleIndexes[GameMode] --{"Innocent","Gunner","Knifer"};	
		for i = 1,Stop[Role] do
			local cRole = RoleIndex[((i-1)% #RoleIndex )+1];
			if i ~= Stop[Role] then
				script["Click"..((i-1)% #RoleIndex )+1]:Play();
			else
				script.Ding:Play();
			end;
			wait(0.04);
			RoleSelector.Role.Text = cRole;
			RoleSelector.Role.TextColor3 = Colors[cRole];
			wait(0.06);
		end;
		wait(2.5);
		
		if Role == "Knifer" or Role == "Gunner" or Role == "Zombie" or Role == "Survivor" then
			RoleSelector.Title.Text = "You will receive your weapon in...";
			RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
			for i = 1,10 do
				RoleSelector.Role.Text = 11-i
				if i == 3 then
					RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
				end
				wait(1);
			end
			RoleSelector.Visible = false;
			GameGUI.CashBag.Visible = true;
		else
			RoleSelector.Title.Text = "Game starts in...";
			RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
			for i = 1,10 do
				RoleSelector.Role.Text = 11-i
				if i == 3 then
					RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
				end
				wait(1);
			end
		end;
	end
	
	if GameMode == "CTF" or GameMode == "FreezeTag" then
		
		RoleSelector.Title.Text = "You are on the"
		RoleSelector.Role.Text = Role .. " Team";
		RoleSelector.Role.TextColor3 = Colors[Role]or Color3.new();
		wait(3);
		RoleSelector.Title.Text = "Game starts in...";
		RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
		RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
		for i = 1,5 do
			RoleSelector.Role.Text = 6-i
			wait(1);
		end

	elseif GameMode == "Infection" then
		
		RoleSelector.Title.Text = "Everyone is a"
		RoleSelector.Role.Text = "Survivor"
		RoleSelector.Role.TextColor3 = Colors["Survivor"];
		wait(3);
		RoleSelector.Title.Text = "Someone will be infected in...";
		RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
		RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
		for i = 1,5 do
			RoleSelector.Role.Text = 6-i
			wait(1);
		end
		
	elseif GameMode == "Massacre" then
		
		RoleSelector.Title.Text = "Everyone is a"
		RoleSelector.Role.Text = "Knifer"
		RoleSelector.Role.TextColor3 = Color3.new(1,0,0);
		wait(3);
		RoleSelector.Title.Text = "Massacre starts in...";
		RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
		RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
		for i = 1,5 do
			RoleSelector.Role.Text = 6-i
			wait(1);
		end
		
	elseif GameMode == "RUN" then
		
		RoleSelector.Title.Text = "You are a"
		RoleSelector.Role.Text = Role;
		RoleSelector.Role.TextColor3 = Colors[Role];
		wait(3);
		RoleSelector.Title.Text = "Battle begins in...";
		RoleSelector:TweenPosition(UDim2.new(0.5,-150,0,25), "Out", "Quad", 1, false)
		RoleSelector.Role.TextColor3 = Color3.new(1,1,1);
		for i = 1,5 do
			RoleSelector.Role.Text = 6-i
			wait(1);
		end
		
	end;
	
	if GameMode == "Assassin" then
		RoleSelector.Visible = false;
		local PlayerImage = (string.sub(Target, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(Target);
		
		--[[GameGUI.Target.Target.PlayerIcon.Image = PlayerImage;
		GameGUI.Target.Knife.Icon.Image = GetImage(ItemsDB[Knife].Image);
		GameGUI.Target.Gun.Icon.Image = GetImage(ItemsDB[Gun].Image);
		
		GameGUI.Target.TargetName.Text = Target;
		GameGUI.Target.Visible = true;
		
		for i = 1,5 do
			GameGUI.Target.Timer.Text = "Game starts in... " .. 11-i
			wait(1);
		end]]
		
		GameGUI.Target2.Target.PlayerIcon.Image = PlayerImage;
		
		GameGUI.Target2.Knife.Icon.Image = GetImage(ItemsDB[Knife].Image);		
		GameGUI.Target2.TargetName.Text = Target;
		GameGUI.Target.Visible = false;
		GameGUI.Target2.Visible = true;
		
		for i = 1,10 do
			GameGUI.Target2.Timer.Text = "Game starts in... " .. 11-i
			wait(1);
		end
		
		GameGUI.Target2.Timer.Visible = false;
		
	end

	RoleSelector.Visible = false;
	GameGUI.CashBag.Visible = true;
	
	if LockFirstPerson then 
		game.Players.LocalPlayer.CameraMode = "LockFirstPerson"; 
		GameGUI.YourCodeName.Image = require(game.ReplicatedStorage.CodeImages)[CodeName];
		GameGUI.YourCodeName.ImageColor3 = Color.Color;
		GameGUI.YourCodeName.Visible = true;
	end;
	
	--GameGUI.Weapon.Visible =  game:GetService("UserInputService").GamepadEnabled and (Role=="Knifer" or Role=="Gunner");
	GameGUI.Weapon.Knifer.Visible =  (game:GetService("UserInputService").TouchEnabled and Role=="Knifer");
	GameGUI.Weapon.Gunner.Visible =  (game:GetService("UserInputService").TouchEnabled and Role=="Gunner");

end)



game.ReplicatedStorage.ChangeTarget.OnClientEvent:connect(function(Target,Knife)
	if Target then
		local PlayerImage = (string.sub(Target, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(Target);
		GameGUI.Target2.Target.PlayerIcon.Image = PlayerImage;
		GameGUI.Target2.TargetName.Text = Target;
		
		GameGUI.Target2.Knife.Icon.Image = GetImage(ItemsDB[Knife].Image);		
	end;
	GameGUI.Target2.Visible = (Target);
		
end)
