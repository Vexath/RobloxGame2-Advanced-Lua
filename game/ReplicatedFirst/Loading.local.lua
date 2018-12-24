script.Parent:RemoveDefaultLoadingScreen()
game.StarterGui.ResetPlayerGuiOnSpawn = false;

local JoinedFriend = false;
game:GetService('TeleportService').LocalPlayerArrivedFromTeleport:connect(function(customLoadingScreen, TeleportData)
	if TeleportData then
		if TeleportData.Joined == true then
			JoinedFriend = true;
		end
	end;
end)

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local InputService = game:GetService("UserInputService");

local screen = script.Loading;
game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0)
screen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

--game.StarterGui:ClearAllChildren();

local function GiveGameGUI()
	local GUI;
	GUI = game.ReplicatedStorage.GUI.MainPC:Clone()
	GUI.Name = "MainGUI";
	GUI.Parent = game.StarterGui;
	GUI:Clone().Parent = game.Players.LocalPlayer.PlayerGui;
	game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(1)
end;

local function LoadGame()
	local QSize = tonumber(game.ContentProvider.RequestQueueSize);
	local FinishLoading = false;
	local Skipped = false;
	
	spawn(function()
		wait(7);
		pcall(function()
			if not FinishLoading then
				screen.Container.Skip.Visible = true;
				screen.Container.Warning.Visible = true;
				screen.Container.Skip.MouseButton1Click:connect(function()
					Skipped = true;
				end)
			end
		end);
	end)
	while game.ContentProvider.RequestQueueSize > 0 and not Skipped  do
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading World: " .. game.ContentProvider.RequestQueueSize .. " objects left.";
		--[[screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading World: " .. 
			math.floor(  ((QSize-game.ContentProvider.RequestQueueSize)/QSize)*100  ) 
		.. "%";]]
		game:GetService("RunService").RenderStepped:wait();
		
	end
	
	FinishLoading = true;
	screen:WaitForChild("Container").Skip.Visible = false;
	screen.Container.Warning.Visible = false;
	
end

local function WaitForCharacter()
	screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Waiting for Data";
	if game.Players.LocalPlayer.Character == nil then
		repeat wait(); until game.Players.LocalPlayer.Character ~= nil;
	end;
end

local Items = game.ReplicatedStorage:WaitForChild("GetSyncData"):InvokeServer("Item");
local Images = {};
local ContentProvider = game:GetService("ContentProvider")
local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";
_G.Cache = {};

local function GetImage(Image) 
	if _G.Cache[Image] ~= nil then 
		return _G.Cache[Image];
	else
		local NewImage = (tonumber(Image) and AssetURL..Image) or Image; 
		--NewImage = NewImage .. "&bust="..math.random(1,10000); 
		--_G.Cache[Image] = NewImage;
		return NewImage; 
	end;
end;

local Database = {"Item","Accessories","Effects","Animations","Toys","Pets"};

local function PreloadAssets()
	screen.Container.LoadingText.Text = "Loading Assets";
	local startTime = tick()
	for _,DataName in pairs(Database) do
		for ItemName,ItemTable in pairs(game.ReplicatedStorage.GetSyncData:InvokeServer(DataName)) do
			table.insert(Images,GetImage(ItemTable["Image"]));
			ContentProvider:Preload( GetImage(ItemTable["Image"]) );
		end
	end;
	wait(1);
end


local function ReloadAssets()
	for Index,Image in pairs(Images) do
		Images[Index] = Image .. "&bust="..math.floor(tick());
	end
	ContentProvider:PreloadAsync(Images);
end

local function DoneLoading()
	screen.Container.Images.Colored.Visible = true;
	screen.Container.Images.Grey.Visible = false;
	screen.Container.LoadingText.Text = "";
	screen.Container.Thumbs.Visible = false;
end

local function FadeOut()
	for i = 1,60 do
		screen.Container.BackgroundTransparency = screen.Container.BackgroundTransparency + 1/60;
		screen.Container.Images.Colored.ImageTransparency = screen.Container.Images.Colored.ImageTransparency + 1/60;
		game:GetService("RunService").RenderStepped:wait();
	end
end



WaitForCharacter();

game:GetService("LogService").MessageOut:connect(function(Message, Type)
   --game.ReplicatedStorage.ServerPrint:FireServer(Message);
end)


local function Play()
	LoadGame();
	DoneLoading();
	wait(1);
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	GiveGameGUI();
	game.StarterGui.ResetPlayerGuiOnSpawn = true;
	FadeOut();
	screen:Destroy();
	
	--[[if not Phone then
		ReloadAssets();
	end;]]
end

local MM2ID = 929751085;

--local CasualTestID = 333740520;

local TeleportService = game:GetService("TeleportService");
local IsVIPServer = game.ReplicatedStorage.IsVIPServer:InvokeServer();

local ShowJoinMenu = (not JoinedFriend and (not IsVIPServer));
local JoinFrame;

local FriendPlaceId;
local FriendGameId;

JoinFrame = (script.Join:Clone()) or script.JoinPhone:Clone();
JoinFrame.Retry.Retry.MouseButton1Click:connect(function()
	JoinFrame.Retry.Visible = false;
	JoinFrame.Friends.Visible = true;
end)

local function UpdateList(Friends)
	if not Friends then Friends = game.Players.LocalPlayer:GetFriendsOnline(); end;
	local Index = 0;
	JoinFrame.Friends.Scroll.Container:ClearAllChildren();
	for _,Friend in pairs(Friends) do
		if Friend.PlaceId == MM2ID then
			local NewFrame = script.Friend:Clone();
			NewFrame.PlayerName.Text = game.Players:GetNameFromUserIdAsync(Friend.VisitorId);
			NewFrame.GameMode.Text = (Friend.PlaceId == "Casual");
			NewFrame.Position = UDim2.new(0,0,0,30*Index);
			NewFrame.Parent = JoinFrame.Friends.Scroll.Container;
			NewFrame.Join.MouseButton1Click:connect(function()
				JoinFrame.Friends.Visible = false;
				JoinFrame.Loading.Visible = true;
				local FoundFriend = false;
				for _,Player in pairs(game.Players:GetPlayers()) do if Player.UserId == Friend.VisitorId then FoundFriend = true; break; end;end;
				if not FoundFriend then
					FriendPlaceId = Friend.PlaceId;
					FriendGameId = Friend.GameId
					TeleportService:TeleportToPlaceInstance(FriendPlaceId,FriendGameId,game.Players.LocalPlayer,"",{Joined=true})
					wait(5);
					JoinFrame.Friends.Visible = false;
					JoinFrame.Retry.Visible = true;
					JoinFrame.Loading.Visible = false;
					spawn(function() while JoinFrame.Retry.Visible == true do JoinFrame.Retry.Spinner.Rotation = JoinFrame.Retry.Spinner.Rotation + 5; game:GetService("RunService").RenderStepped:wait(); end; end)
					spawn(function()
						local Attempts = 1;
						while JoinFrame.Retry.Visible == true do
							JoinFrame.Retry.Retrying.Text = "Retrying... (" .. Attempts .. ")";
							FriendPlaceId = Friend.PlaceId;
							FriendGameId = Friend.GameId

							TeleportService:TeleportToPlaceInstance(FriendPlaceId,FriendGameId,game.Players.LocalPlayer,"",{Joined=true})
							for i = 1,50 do
								wait(0.1);
								if not JoinFrame.Retry.Visible then
									break;
								end
							end
							Attempts = Attempts+1;
						end;
					end);
					
					UpdateList();
				else
					JoinFrame:Destroy();
					Play();
				end;
			end)
			Index = Index + 1;
		end;
	end;
end


local function JoinFriend()	
	if ShowJoinMenu then
		local Friends;
		pcall(function() Friends = game.Players.LocalPlayer:GetFriendsOnline(); end)
		if Friends and #Friends > 0 then
			local OnlineMM2 = false;
			for _,Friend in pairs(Friends) do 
				if Friend.PlaceId == MM2ID then 
					OnlineMM2 = true; 
				end; 
			end;
			
			if OnlineMM2 then
				JoinFrame.Parent = game.Players.LocalPlayer.PlayerGui;
				UpdateList(Friends);
				JoinFrame.Friends.Play.MouseButton1Click:connect(function()
					JoinFrame:Destroy();
					Play();
				end)
			else
				Play();
			end;
		else
			Play();
		end;
	else
		Play();
	end
end


local function SelectGameMode()
	screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Checking Data...";
	local GameMode = (game.ReplicatedStorage.GetData:InvokeServer("GameMode2")) or nil;
 
	if (game.PlaceId == MM2ID) and not game:GetService("UserInputService").GamepadEnabled and not IsVIPServer and not JoinedFriend then
		if GameMode == nil then
			local GameModeFrame = (script.Gamemode:Clone()) or script.GamemodePhone:Clone();
			GameModeFrame.Parent = game.Players.LocalPlayer.PlayerGui;
			
			--[[GameModeFrame.Select.Minigames.Play.MouseButton1Click:connect(function()
				GameModeFrame.Select.Visible = false;
				GameModeFrame.Loading.Visible = true;
				game.ReplicatedStorage.ChangeGameMode:FireServer("Minigames");
				game:GetService('TeleportService'):Teleport(MinigamesID);
			end)]]
			
			GameModeFrame.Select.Casual.Play.MouseButton1Click:connect(function()
				GameModeFrame:Destroy();
				game.ReplicatedStorage.ChangeGameMode:FireServer("Casual");
				JoinFriend();
			end)
			
		elseif GameMode == "Casual" then
			JoinFriend();
		end;
	else
		JoinFriend();
	end;

end


local function ConnectJoinFrame()
	JoinFrame = (script.Join:Clone()) or script.JoinPhone:Clone();
	JoinFrame.Retry.Retry.MouseButton1Click:connect(function()
		JoinFrame.Retry.Visible = false;
		JoinFrame.Friends.Visible = true;
	end)
end

local DeviceNot = {
	["Tablet"] = "Phone";
	["Phone"] = "Tablet";
};

if game.Players.LocalPlayer.FollowUserId > 0 and not IsVIPServer then
	local FoundPlayer = false;
	for _,Player in pairs(game.Players:GetChildren()) do
		if Player.userId == game.Players.LocalPlayer.FollowUserId then
			FoundPlayer = true;
			break;
		end
	end
	if not FoundPlayer then
		screen.Container.LoadingText.Text = "Joining User...";
		game.ReplicatedStorage.Follow:FireServer();	
		wait(5);
		screen.Container.LoadingText.Text = "Failed to join user.";
		wait(1);
	end;	
else
	Play();
end;








 --[[
local textLabel = Instance.new("TextLabel")
textLabel.Parent = screen
textLabel.Text = "Loading"
textLabel.Size = UDim2.new(1,0,1,0)
textLabel.Font = Enum.Font.SourceSansBold;
textLabel.FontSize = Enum.FontSize.Size48;
textLabel.TextColor3 = Color3.new(1,1,1);
textLabel.BackgroundColor3 = Color3.new(0,0,0);
textLabel.ZIndex = 10;
 
local count = 0


textLabel.Text = "Waiting for Replication";

repeat wait(); until game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI");

function WaitForEverything(Object,Equivalent)
	for _,Child in pairs(Equivalent:GetChildren()) do
		if not Object:FindFirstChild(Child.Name) then
			repeat wait(); until Object:FindFirstChild(Child.Name);
		end;
		WaitForEverything(Object:FindFirstChild(Child.Name),Child);
	end
end
WaitForEverything(game.Players.LocalPlayer.PlayerGui.MainGUI,game.StarterGui.MainGUI);
 
screen.Parent = nil]]