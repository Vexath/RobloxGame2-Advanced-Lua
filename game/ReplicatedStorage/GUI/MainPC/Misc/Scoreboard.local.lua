local GameGUI = script.Parent.Parent.Game;
local LocalPlayer = game.Players.LocalPlayer;

local ScoreboardFrame = GameGUI.Scoreboard;
local ServerSettings = game.ReplicatedStorage.GetServerSettings:InvokeServer();
local CodeImages = require(game.ReplicatedStorage.CodeImages);
local ItemsDB = game.ReplicatedStorage.GetSyncData:InvokeServer("Item");
local EffectsDB = game.ReplicatedStorage.GetSyncData:InvokeServer("Effects");
local RarityColors = game.ReplicatedStorage.GetSyncData:InvokeServer("Rarity");

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

if not _G.Coins then _G.Coins = 0; end;
game.ReplicatedStorage.GetCoin.OnClientEvent:connect(function() _G.Coins = _G.Coins + 1; end);

local Time = 0.2;
local Style = "Quad";
local Direction = "Out";

local SongList = {
	["Lobby"] = "rbxassetid://1845554017";
	["CTF"] = "rbxassetid://1838679824";
	["Classic"] = "rbxassetid://1843663426";
	["FreezeTag"] = "rbxassetid://1843382633";
	["RUN"] = "rbxassetid://1842424039";
}
local Song;
local function FadeSong()
	for i = 1,20 do
		Song.Volume = Song.Volume-0.05;
		wait(0.05);
	end;		
end

local VictoryMusic = "rbxassetid://1842939295"
local LoserMusic = "rbxassetid://1842893338"

local function WinMusic()
	Song = Instance.new("Sound",script.Parent.Parent);
	Song.SoundId = VictoryMusic;
	Song.Volume = 0.4;
	Song.Looped = false;
	Song.PlayOnRemove = false;
	Song:Play();
end

local function LoseMusic()
	Song = Instance.new("Sound",script.Parent.Parent);
	Song.SoundId = LoserMusic;
	Song.Volume = 0.4;
	Song.Looped = false;
	Song.PlayOnRemove = false;
	Song:Play();
end

local Remote=game.ReplicatedStorage;

local Database = {
	
	Weapons 	= Remote.GetSyncData:InvokeServer("Item");
	Effects 	= Remote.GetSyncData:InvokeServer("Effects");
	Animations 		= Remote.GetSyncData:InvokeServer("Animations");
	Accessories		= Remote.GetSyncData:InvokeServer("Accessories");
	Toys		= Remote.GetSyncData:InvokeServer("Toys");
	Pets 		= Remote.GetSyncData:InvokeServer("Pets");
	Materials 	= Remote.GetSyncData:InvokeServer("Materials");
	
};

local RoleColors = {
	["Innocent"] = Color3.new(1,1,1);
	["Gunner"] = Color3.new(0,0,1);
	["Hero"] = Color3.new(1,1,0);
	["Knifer"] = Color3.new(1,0,0);
	["Zombie"] = Color3.new(25/255, 172/255, 0);
	["Survivor"] = Color3.new(43/255,154/255,238/255);		
	["Red"] = Color3.new(217/255, 35/255, 35/255);
	["Blue"] = Color3.new(63/255, 176/255, 224/255);
	["Monster"] = Color3.new(217/255, 35/255, 35/255);
	["MonsterHunter"] = Color3.new(63/255, 176/255, 224/255);
};

local function GenerateViewAll(ScoreFrame,PlayerData)
	local Index = 0;
	local PlayerTable = {};
	for PlayerName,Data in pairs(PlayerData) do
		table.insert(PlayerTable,{PlayerName=PlayerName,Data=Data});
	end
	table.sort(PlayerTable,function(a,b)
		
		if a.Data.Role == "Knifer" then
			return true;
		elseif b.Data.Role == "Knifer" then
			return false;
		elseif a.Data.Role == "Gunner" then
			return true;
		elseif b.Data.Role == "Gunner" then
			return false;
		elseif a.Data.Role == "Hero" then
			return true;
		elseif b.Data.Role == "Hero" then
			return false;
		elseif a.Data.Dead ~= b.Data.Dead then
			return (a.Data.Dead==false and true) or false;
		end;
		return a.PlayerName < b.PlayerName;
	end)
	for _,Table in pairs(PlayerTable) do
		local PlayerName = Table.PlayerName; local Data=Table.Data;
		local NewFrame = script.PlayerFrame:Clone();
		local Row = math.floor(Index/6); local Column = Index%6;
		NewFrame.Position = UDim2.new(0,100*Column,0,100*Row);
		
		local PlayerImage =  (string.sub(PlayerName, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(PlayerName);
		NewFrame.Container.PlayerIcon.Image = GetImage(PlayerImage);
		NewFrame.Container.PlayerIcon.ImageColor3 = (Data.Dead and Color3.new(50/255,50/255,50/255)) or Color3.new(1,1,1);
		NewFrame.Container.PlayerName.Text = PlayerName;

		NewFrame.Container.PlayerName.TextColor3 =  RoleColors[Data.Role]; -- (Data.Role=="Hero" and Color3.new(1,1,0)) or (Data.Role=="Gunner" and Color3.new(40/255,120/255,220/255)) or (Data.Role=="Knifer" and Color3.new(220/255,0,0)) or  Color3.new(1,1,1);
		NewFrame.Container.Dead.Visible = Data.Dead;
		
		if ServerSettings.Disguises then
			NewFrame.Container.CodeName.Text = Data.CodeName --.Image = CodeImages[Data.CodeName];
			NewFrame.Container.CodeName.TextColor3 = Data.Color.Color; --ImageColor3 = Data.Color.Color;
		end
		
		NewFrame.Parent = ScoreFrame.ViewAll.Container;
		Index = Index + 1;
	end
end

local function CreateKniferFrame(PlayerData,Name,KniferFrame,KnifeFrame,EffectFrame)
	local KniferImage =  (string.sub(Name, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or game.ReplicatedStorage.GetPlayerImage:Invoke(Name);
	KniferFrame.PlayerIcon.Image = KniferImage;
	KniferFrame.PlayerIcon.ImageColor3 = (PlayerData[Name].Dead and Color3.new(50/255,50/255,50/255)) or Color3.new(1,1,1);
	KniferFrame.PlayerName.Text = Name;
	KniferFrame.Dead.Visible = PlayerData[Name].Dead;
	if ServerSettings.Disguises then
		KniferFrame.CodeName.Image = CodeImages[PlayerData[Name].CodeName];
		KniferFrame.CodeName.ImageColor3 = PlayerData[Name].Color.Color;
	end
	
	if KnifeFrame then
		local Knife = PlayerData[Name].Knife;
		local KnifeData = ItemsDB[Knife];
		KnifeFrame.Icon.Image = GetImage(KnifeData.Image);
		KnifeFrame.ItemName.Text = KnifeData.ItemName;
		KnifeFrame.ItemName.TextColor3 = RarityColors[KnifeData.Rarity];
	end;
	
	if EffectFrame then
		local Effect = PlayerData[Name].Effect;
		if Effect then
			local EffectData = EffectsDB[Effect];
			EffectFrame.Icon.Image = GetImage(EffectData.Image);
			EffectFrame.ItemName.Text = EffectData.Name;
		end;
	end	
	
end
		local DropFrame = ScoreboardFrame.Drop;		

game.ReplicatedStorage.GameOver.OnClientEvent:connect(function(PlayerData,GameTime,GameMode,XPText,Winner,TitleText,TitleTextColor,DropTable,CoinText)	
	
	local ScoreFrame = ScoreboardFrame[GameMode];
	ScoreFrame.TitleFrame.Title.Text = TitleText;
	ScoreFrame.TitleFrame.Title.TextColor3 = TitleTextColor;
	ScoreFrame.Main.Close.MouseButton1Click:connect(function() ScoreFrame.Visible = false DropFrame.Visible = false; end);
	
	if GameMode == "Classic" then
		ScoreFrame.ViewAll.Close.MouseButton1Click:connect(function() ScoreFrame.Visible = false end);
		local Knifer;
		local Gunner;
		local Hero;
		for PlayerName,Data in pairs(PlayerData) do if Data["Role"] == "Knifer" then Knifer = PlayerName; end; if Data["Role"] == "Gunner" then Gunner = PlayerName; end; if Data["Role"] == "Hero" and not Data["Dead"] then Hero = PlayerName; end; end
		
		CreateKniferFrame(PlayerData,Knifer,ScoreFrame.Main.Knifer.Container,ScoreFrame.Main.Knife.Container);
		
		local GunFrame = ScoreFrame.Main.Gun.Container;
		local GunnerFrame = ScoreFrame.Main.Gunner.Container;
		local GunnerImage =  (string.sub(Gunner, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(Hero or Gunner);
		local GunnerData = (Hero and PlayerData[Hero]) or PlayerData[Gunner];
		
		GunnerFrame.PlayerIcon.Image = GetImage(GunnerImage);
		GunnerFrame.PlayerIcon.ImageColor3 = (GunnerData.Dead and Color3.new(50/255,50/255,50/255)) or Color3.new(1,1,1);
		GunnerFrame.PlayerName.Text = (Hero or Gunner);
		GunnerFrame.Dead.Visible = GunnerData.Dead;
		GunnerFrame.Role.Text = (Hero and "Hero") or "Gunner";
		GunnerFrame.Role.TextColor3 = (Hero and Color3.new(1,1,0)) or Color3.new(40/255,120/255,220/255);
		if ServerSettings.Disguises then
			GunnerFrame.CodeName.Image = CodeImages[PlayerData[Hero or Gunner].CodeName];
			GunnerFrame.CodeName.ImageColor3 = PlayerData[Hero or Gunner].Color.Color;
		end
		ScoreFrame.Main.Coins.TextLabel.Text = "You collected " .. _G.Coins .. " coins";

		
		if DropTable and #DropTable > 0 then
			DropFrame.Title.Text = "You received a drop!";
			for i,Reward in pairs(DropTable) do
				DropFrame["Drop"..i].Container.Icon.Image = GetImage(Database[Reward.Type][Reward.ItemID].Image);
				DropFrame["Drop"..i].Container.ItemName.Text = Database[Reward.Type][Reward.ItemID].Name or Database[Reward.Type][Reward.ItemID].ItemName;
				DropFrame["Drop"..i].Container.ItemName.TextColor3 = RarityColors[Database[Reward.Type][Reward.ItemID].Rarity];
				DropFrame["Drop"..i].Container.Amount.Text = "x" .. Reward.Amount;
				DropFrame["Drop"..i].Visible = true;
			end
			DropFrame.Visible = true;
		else
			DropFrame.Title.Text = "You received no drops this round.";
			DropFrame.Visible = true;
		end;
	end
	
	if GameMode == "FreezeTag" then
		if Winner then
			local Index = 0;
			for pName,Data in pairs(PlayerData) do
				if Data.Role == Winner then
					local PlayerName = pName;
					local NewFrame = script.PlayerFrame:Clone();
					local Row = math.floor(Index/6); local Column = Index%6;
					NewFrame.Position = UDim2.new(0,100*Column,0,100*Row);
					local PlayerImage =  (string.sub(PlayerName, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(PlayerName);
					NewFrame.Container.PlayerIcon.Image = GetImage(PlayerImage);
					NewFrame.Container.PlayerIcon.ImageColor3 = (Data.Dead and Color3.new(50/255,50/255,50/255)) or Color3.new(1,1,1);
					NewFrame.Container.PlayerName.Text = PlayerName;			
					NewFrame.Parent = ScoreFrame.Main.Winner;
					Index = Index + 1;
				end
			end
			ScoreFrame.Main.Title.Visible = true;
			ScoreFrame.Main.Winner.Visible = true;
		else
			ScoreFrame.Main.NoWinner.Visible = true;
		end;


	end
	
	if GameMode == "Massacre" then
		local AliveCount = 0;
		for _,pData in pairs(PlayerData) do if pData.Dead==false then AliveCount = AliveCount+1;end;end;

		if AliveCount == 1 then
			for Name,pData in pairs(PlayerData) do 
				if pData.Dead==false then 
					
					CreateKniferFrame(PlayerData,Name,ScoreFrame.Main.Winner.Knifer.Container,ScoreFrame.Main.Winner.Knife.Container,ScoreFrame.Main.Winner.Effect.Container);
					break;
				end;
			end;
		else
			ScoreFrame.Main.Winner.Visible = false;
			ScoreFrame.Main.NoWinner.Visible = true;
		end;

	end
	
	if GameMode == "CTF" then
		if Winner then
			local Index = 0;
			for pName,Data in pairs(PlayerData) do
				if Data.Role == Winner then
					local PlayerName = pName;
					local NewFrame = script.PlayerFrame:Clone();
					local Row = math.floor(Index/6); local Column = Index%6;
					NewFrame.Position = UDim2.new(0,100*Column,0,100*Row);
					local PlayerImage =  (string.sub(PlayerName, 1,6) == "Guest " and "http://www.roblox.com/asset/?id=65732094" ) or  game.ReplicatedStorage.GetPlayerImage:Invoke(PlayerName);
					NewFrame.Container.PlayerIcon.Image = GetImage(PlayerImage);
					NewFrame.Container.PlayerIcon.ImageColor3 = (Data.Dead and Color3.new(50/255,50/255,50/255)) or Color3.new(1,1,1);
					NewFrame.Container.PlayerName.Text = PlayerName;			
					NewFrame.Parent = ScoreFrame.Main.Winner;
					Index = Index + 1;
				end
			end
			ScoreFrame.Main.Title.Visible = true;
			ScoreFrame.Main.Winner.Visible = true;
		else
			ScoreFrame.Main.NoWinner.Visible = true;
		end;


	end
	
	if GameMode == "RUN" then
		
		for pName,Data in pairs(PlayerData) do
			if Data.Role == "Monster" then
				
				CreateKniferFrame(PlayerData,pName,ScoreFrame.Main.Knifer.Container,ScoreFrame.Main.Knife.Container);
				
				ScoreFrame.Main.Health.TextLabel.TextColor3 = 
						(Data.HealthPercent >= 0.75 and Color3.new(0, 170/255, 0)) or
						(Data.HealthPercent < 0.75 and Data.HealthPercent >= 0.5 and Color3.new(1,1,0)) or
						(Data.HealthPercent < 0.5 and Data.HealthPercent >= 0.25 and Color3.new(1,170/255,0)) or
						(Data.HealthPercent < 0.25 and Color3.new(1,0,0));
						
				ScoreFrame.Main.Health.TextLabel.Text = math.ceil( Data.HealthPercent*100 ) .. "%";
				
			end;
		end;
		
	end
	
	
	if GameMode == "Assassin" then
		local AliveCount = 0;
		for _,pData in pairs(PlayerData) do if pData.Dead==false then AliveCount = AliveCount+1;end;end;

		if AliveCount == 1 then
			for Name,pData in pairs(PlayerData) do 
				if pData.Dead==false then 
					
					CreateKniferFrame(PlayerData, Name, ScoreFrame.Main.Winner.Knifer.Container, ScoreFrame.Main.Winner.Knife.Container,ScoreFrame.Main.Winner.Effect.Container);
					break;
				end;
			end;
		else
			ScoreFrame.Main.Winner.Visible = false;
			ScoreFrame.Main.NoWinner.Visible = true;
		end;
		
		ScoreFrame.Main.Coins.TextLabel.Text = "You collected " .. _G.Coins .. " coins";

	end
	
	
	GenerateViewAll(ScoreFrame,PlayerData);

	

	local ScoreFrameSize = ScoreFrame.Size;
	local ScoreFramePosition = ScoreFrame.Position;
	
	ScoreFrame.Main.ViewAll.MouseButton1Click:connect(function()
		ScoreFrame:TweenSizeAndPosition(
			UDim2.new(0,615,0,380),
			UDim2.new(0.5,-307,0.5,-190),
			Direction,Style,Time
		);
		ScoreFrame.Main:TweenPosition(UDim2.new(-1,0,0,45),Direction,Style,Time);
		ScoreFrame.ViewAll:TweenPosition(UDim2.new(0,0,0,45),Direction,Style,Time);
		DropFrame.Visible = false;
	end)
	ScoreFrame.ViewAll.Back.MouseButton1Click:connect(function()
		ScoreFrame:TweenSizeAndPosition(
			ScoreFrameSize,
			ScoreFramePosition,
			Direction,Style,Time
		);
		ScoreFrame.Main:TweenPosition(UDim2.new(0,0,0,45),Direction,Style,Time);
		ScoreFrame.ViewAll:TweenPosition(UDim2.new(1,0,0,45),Direction,Style,Time);
		
	end)
	
	if CoinText then 
		ScoreFrame.Main.Coins.TextLabel.Text = CoinText;
	end
	ScoreFrame.Main.XP.TextLabel.Text = XPText;
	
	_G.Coins = 0;	
	
	
	
	
	ScoreFrame.Visible = true;
	wait(10);
	FadeSong();
	wait(10);
	ScoreFrame.Visible = false;
	DropFrame.Visible = false;
end)