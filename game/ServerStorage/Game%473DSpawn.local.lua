local Player = game.Players.LocalPlayer;


repeat wait(); until script.Parent:FindFirstChild("MainGUI");
function WaitForEverything(Object,Equivalent)
	for _,Child in pairs(Equivalent:GetChildren()) do
		if not Object:FindFirstChild(Child.Name) then
			repeat wait(); until Object:FindFirstChild(Child.Name);
		end;
		WaitForEverything(Object:FindFirstChild(Child.Name),Child);
	end
end
WaitForEverything(game.Players.LocalPlayer.PlayerGui.MainGUI,game.StarterGui.MainGUI);

local MainGUI = script.Parent.MainGUI.Computer;
local Phone = false;
if MainGUI.Parent.AbsoluteSize.X <= 960 and MainGUI.Parent.AbsoluteSize.Y <= 640 and game:GetService("UserInputService").TouchEnabled == true then
	MainGUI = script.Parent.MainGUI.Phone;
	Phone = true;
end

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


GetSyncData("Map");

game.Workspace.CurrentCamera:ClearAllChildren();

Port = Instance.new("Sound",script.Parent);
Port.SoundId = "http://www.roblox.com/asset/?id=147298833";
Port.Volume = 0.1;
Port.Looped = true;
Port.PlayOnRemove = false;
Port:Play();

local Vote;
game.ReplicatedStorage.MapVote.OnClientEvent:connect(function()
	Vote = Instance.new("Sound",script.Parent);
	Vote.SoundId = "http://www.roblox.com/asset/?id=145630659";
	Vote.Volume = 0.2;
	Vote.Looped = true;
	Vote.PlayOnRemove = false;
	Vote:Play();
end)

game.ReplicatedStorage.DoneVoteMap.OnClientEvent:connect(function()
	Vote:Stop();
	Vote = Instance.new("Sound",script.Parent);
	Vote.SoundId = "http://www.roblox.com/asset/?id=140413818";
	Vote.Volume = 0.5;
	Vote.Looped = false;
	Vote.PlayOnRemove = false;
	Vote:Play();
end)


local handler = require(game.ReplicatedStorage.Module3D)

local GameModeImages = {
	["Classic"] = "rbxassetid://2638802975";
	["FreezeTag"] = "rbxassetid://2638686511";
	["CTF"] = "rbxassetid://2638686290";
	["RUN"] = "rbxassetid://2638689281";
};

local RoleImages = {
	["Knifer"] = "rbxassetid://2641572256";
	["Gunner"] = "rbxassetid://2641572076";
	["Innocent"] = "rbxassetid://2641580329";
};

local GameModeTunes = {
	["CTF"] = "rbxassetid://1838679824";
	["Classic"] = "rbxassetid://1843663426";
	["RUN"] = "rbxassetid://1842424039";
	["FreezeTag"] = "rbxassetid://1843382633";
};

local MapAmbiences = {
	["Office2"] = "http://www.roblox.com/asset/?id=199963659";
	["Barn"] = "http://www.roblox.com/asset/?id=171028963";
	["Workplace"] = "http://www.roblox.com/asset/?id=199963659";
};

local GameMusic = {
	"http://www.roblox.com/asset/?id=196035027";
	"http://www.roblox.com/asset/?id=171971668";
	"http://www.roblox.com/asset/?id=142483305";
};

local Volumes = {
	["Office2"] = 0.2;
	["Barn"] = 1;
	["Workplace"] = 0.2;
};

local Song;
local MapNamer;
local GameModeNamer;
local ShowControls  = false;
game.ReplicatedStorage.LoadingScreen.OnClientEvent:connect(function(RoleName,MapName,GameModeName)
	Port:Stop();
	MapNamer = MapName;
	GameModeNamer = GameModeName;
	MainGUI.Spawning.RoundData.GameMode.Image = GameModeImages[GameModeName];
	MainGUI.Spawning.RoundData.Role.Image = RoleImages[RoleName];
	MainGUI.Spawning.RoundData.Map.MapName.Text = MapName;
	MainGUI.Spawning.RoundData.Map.Image = GetSyncData("Map")[MapName]["MapImage"];
	MainGUI.Spawning.Rules[GameModeName].Visible = true;
	Song = Instance.new("Sound",script.Parent);
	Song.SoundId = GameModeTunes[GameModeName];
	Song.Volume = 0.4;
	Song.Looped = true;
	Song.PlayOnRemove = false;
	Song:Play();
	if game:GetService("UserInputService").GamepadEnabled and (RoleName == "Knifer" or RoleName == "Gunner") then
		ShowControls = true;
	end
end)

Player.PlayerGui.ChildAdded:connect(function(Child)
	wait();
	if Child.Name == "Dummy" then
				
		local frame = MainGUI.Spawning.Frame;
		local activeModel = handler:Attach3D(frame,Child)
		
		activeModel:SetActive(true)
		--activeModel:SetCFrame(CFrame.fromEulerAnglesXYZ(0,math.pi,0))
		
		game.Workspace.CurrentCamera.CameraType = "Scriptable";
		game.Workspace.CurrentCamera.CoordinateFrame = game.Workspace.CameraBrick.CFrame;
		
		MainGUI.Spawning.Visible = true;
		
		local PlayerData = game.ReplicatedStorage.GetPlayerData:InvokeServer();
		local Data = PlayerData[Player.Name];
		
		MainGUI.Spawning.CodeImage.Image = require(game.ReplicatedStorage.CodeImages)[Data["CodeName"]];
		MainGUI.Spawning.CodeImage.ImageColor3 = Data["Color"].Color;
		MainGUI.Spawning.Chance.Text = "Your chance to be Knifer: " .. game.ReplicatedStorage.GetChance:InvokeServer() .. "%";
		
		MainGUI.Waiting.Image = "rbxassetid://2641539759";
		MainGUI.Dock.Visible = false;
		MainGUI.Level.Visible = false;
		MainGUI.Inventory.Visible = false;
		MainGUI.Shop.Visible = false;
		MainGUI.Badges.Visible = false;
		
		local X = 0;
		spawn(function()
			while true do
				activeModel:SetCFrame(CFrame.Angles(math.rad(10),math.sin((X/15))*math.pi/4+math.pi,0));
				X = X + 1;
				wait(0);
			end
		end)
		
		spawn(function()
			local Steps = 200;
			for i = 1,Steps do
				MainGUI.Spawning.Loading.Bar.Bar2.Size = UDim2.new(i/Steps,0,1,0);
				wait();
			end
		end)

		game.ReplicatedStorage.DoneLoading.OnClientEvent:connect(function()
			local IsSpawned = false;
			MainGUI.Spawning.Loading.Visible = false;
			
			MainGUI.Spawning.Spawn.Visible = true;
						
			game:GetService("UserInputService").InputBegan:connect(function(Input)
				if Input.KeyCode == Enum.KeyCode.ButtonA then
					if ShowControls then
						MainGUI.Weapon.Visible = true;
					end
					IsSpawned = true;
					MainGUI.Spawning.Visible = false;
					MainGUI.Level.Visible = true;
					MainGUI.Waiting.Visible = false;
					--MainGUI.Dock.Visible = true;
					MainGUI.CashBag.Visible = true;
					game.Workspace.CurrentCamera.CameraType = "Custom";
					repeat wait(); until Player.Character ~= nil;
					repeat wait(); until Player.Character:FindFirstChild("Humanoid");
					game.Workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;	
					activeModel:End();
					
					MainGUI.YourCodeName.Image = require(game.ReplicatedStorage.CodeImages)[Data["CodeName"]];
					MainGUI.YourCodeName.ImageColor3 = Data["Color"].Color;
					MainGUI.YourCodeName.Visible = true;
					
					if game.ReplicatedStorage.GetPlayerData:InvokeServer()[Player.Name]["Coins"] ~= nil then
						local RoundsLeft = MainGUI.CashBag.RoundsLeft;
						local Rounds = game.ReplicatedStorage.GetData:InvokeServer("CoinBag");
						RoundsLeft.Text = Rounds .. " rounds left.";
						if Rounds > 0 then
							RoundsLeft.Visible = true;
						end
					end;
					
					for i = 1,20 do
						Song.Volume = Song.Volume-0.05;
						wait(0.05);
					end;			
					
					if MapAmbiences[MapNamer] ~= nil then
						Song = Instance.new("Sound",script.Parent);
						Song.SoundId = MapAmbiences[MapNamer];
						Song.Volume = Volumes[MapNamer];
						Song.Looped = true;
						Song.PlayOnRemove = false;
						Song:Play();
					end;
					if GameModeNamer ~= "Classic" or GameModeNamer ~= "RUN" or GameModeNamer ~= "CTF" or GameModeNamer ~= "FreezeTag" then
						Song = Instance.new("Sound",script.Parent);
						Song.SoundId = GameMusic[math.random(1,#GameMusic)];
						Song.Volume = 0.1;
						Song.Looped = true;
						Song.PlayOnRemove = false;
						Song:Play();
					end;
				end
			end)					
						
			MainGUI.Spawning.Spawn.MouseButton1Click:connect(function()
				if ShowControls then
					MainGUI.Weapon.Visible = true;
				end
				IsSpawned = true;
				MainGUI.Spawning.Visible = false;
				MainGUI.Level.Visible = true;
				MainGUI.Waiting.Visible = false;
				--MainGUI.Dock.Visible = true;
				MainGUI.CashBag.Visible = true;
				game.Workspace.CurrentCamera.CameraType = "Custom";
				repeat wait(); until Player.Character ~= nil;
				repeat wait(); until Player.Character:FindFirstChild("Humanoid");
				game.Workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;	
				activeModel:End();
				
				MainGUI.YourCodeName.Image = require(game.ReplicatedStorage.CodeImages)[Data["CodeName"]];
				MainGUI.YourCodeName.ImageColor3 = Data["Color"].Color;
				MainGUI.YourCodeName.Visible = true;
				
				if game.ReplicatedStorage.GetPlayerData:InvokeServer()[Player.Name]["Coins"] ~= nil then
					local RoundsLeft = MainGUI.CashBag.RoundsLeft;
					local Rounds = game.ReplicatedStorage.GetData:InvokeServer("CoinBag");
					RoundsLeft.Text = Rounds .. " rounds left.";
					if Rounds > 0 then
						RoundsLeft.Visible = true;
					end
				end;
				
				for i = 1,20 do
					Song.Volume = Song.Volume-0.05;
					wait(0.05);
				end;			
				
				if MapAmbiences[MapNamer] ~= nil then
					Song = Instance.new("Sound",script.Parent);
					Song.SoundId = MapAmbiences[MapNamer];
					Song.Volume = Volumes[MapNamer];
					Song.Looped = true;
					Song.PlayOnRemove = false;
					Song:Play();
				end;
				if GameModeNamer ~= "Classic" or GameModeNamer ~= "RUN" or GameModeNamer ~= "CTF" or GameModeNamer ~= "FreezeTag" then
					Song = Instance.new("Sound",script.Parent);
					Song.SoundId = GameMusic[math.random(1,#GameMusic)];
					Song.Volume = 0.1;
					Song.Looped = true;
					Song.PlayOnRemove = false;
					Song:Play();
				end;
			end);
						
			wait(30);
			
			if not IsSpawned then
				if ShowControls then
					MainGUI.Weapon.Visible = true;
				end
				IsSpawned = true;
				MainGUI.Spawning.Visible = false;
				MainGUI.Level.Visible = true;
				MainGUI.Waiting.Visible = false;
				--MainGUI.Dock.Visible = true;
				MainGUI.CashBag.Visible = true;
				game.Workspace.CurrentCamera.CameraType = "Custom";
				repeat wait(); until Player.Character ~= nil;
				repeat wait(); until Player.Character:FindFirstChild("Humanoid");
				game.Workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;	
				activeModel:End();
				
				MainGUI.YourCodeName.Image = require(game.ReplicatedStorage.CodeImages)[Data["CodeName"]];
				MainGUI.YourCodeName.ImageColor3 = Data["Color"].Color;
				MainGUI.YourCodeName.Visible = true;
				
				if game.ReplicatedStorage.GetPlayerData:InvokeServer()[Player.Name]["Coins"] ~= nil then
					local RoundsLeft = MainGUI.CashBag.RoundsLeft;
					local Rounds = game.ReplicatedStorage.GetData:InvokeServer("CoinBag");
					RoundsLeft.Text = Rounds .. " rounds left.";
					if Rounds > 0 then
						RoundsLeft.Visible = true;
					end
				end;
			end	
		
		end)
		
		
		
	end
end)
