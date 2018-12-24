local GameGUI = script.Parent.Parent.Game;
local ShopFrame = GameGUI.Shop;
local TitleFrame = ShopFrame.Title;
local Main = ShopFrame.Container.Main;
local Navigation = ShopFrame.Container.Nav;
local Dock = GameGUI.Dock;
local ItemPackFrame = GameGUI.ItemPack;

local Time = 0.2;
local Style = "Quad";
local Direction = "Out";

_G.Tweening = false;
_G.CurrentFrame = "Featured";

--[[
	ShopFrame:TweenSizeAndPosition(
				UDim2.new(0,450,0,325),				
				UDim2.new(0.5,-225,0.5,-163),
				Direction,Style,Time
			);

--]]

TitleFrame.Back.MouseButton1Click:connect(function()
	script.Parent.Click:Play();
	if not _G.CurrentFrame then
		ShopFrame.Visible = false;
	elseif _G.CurrentFrame == "ViewContents" then
		if not _G.Tweening then
			_G.Tweening = true;
			_G.CurrentFrame = Main[_G.ViewContentsDataName];
			Main[_G.ViewContentsDataName]:TweenPosition(
				UDim2.new(0,0,0,0),
				Direction,Style,Time
			);
			Main.ViewContents:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,Time
			);
			wait(Time);
			_G.Tweening = false;
		end;
	elseif _G.CurrentFrame == "Featured" then
		
		if not _G.Tweening then
			_G.Tweening = true;
			TitleFrame.Title.Text = "Shop";
			TitleFrame.Back.Letter.Text = "X";
			_G.CurrentFrame = nil;
			ShopFrame:TweenSizeAndPosition(
				UDim2.new(0,450,0,460),				
				UDim2.new(0.5,-225,0.5,-230),
				Direction,Style,Time
			);
			ShopFrame.Container.Featured:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,Time
			);
			Navigation:TweenPosition(
				UDim2.new(0,0,0,0),
				Direction,Style,Time
			);
			wait(0.2);
			_G.Tweening = false;
		end;
		
	elseif _G.CurrentFrame == "GetCoins" or _G.CurrentFrame == "GetGems" then	
		if not _G.Tweening then
			_G.Tweening = true;
			TitleFrame.Title.Text = "Shop";
			TitleFrame.Back.Letter.Text = "X";
			_G.CurrentFrame = nil;
			ShopFrame:TweenSizeAndPosition(
				UDim2.new(0,450,0,460),				
				UDim2.new(0.5,-225,0.5,-230),
				Direction,Style,Time
			);
			ShopFrame.Container.Coins:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,Time
			);
			ShopFrame.Container.Gems:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,Time
			);
			Navigation:TweenPosition(
				UDim2.new(0,0,0,0),
				Direction,Style,Time
			);
			wait(0.2);
			_G.Tweening = false;
		end;
	else
		if not _G.Tweening then
			
			_G.Tweening = true;
			TitleFrame.Title.Text = "Shop";
			TitleFrame.Back.Letter.Text = "X";
			_G.CurrentFrame = nil;
			
			ShopFrame:TweenSizeAndPosition(
				UDim2.new(0,450,0,460),				
				UDim2.new(0.5,-225,0.5,-230),
				Direction,Style,Time
			);

			Navigation:TweenPosition(
				UDim2.new(0,0,0,0),
				Direction,Style,Time
			);

			for _,Frame in pairs(Main:GetChildren()) do
				Frame:TweenPosition(
					UDim2.new(1,0,0,0),
					Direction,Style,Time
				);
			end;
			
			wait(0.2);
			_G.Tweening = false;
		end;
	end;
	
	
end)


_G.Navigate = function(FrameName,Override)
	if FrameName == "Elite" then
		ShopFrame.Visible = false;
		GameGUI.GetElite.Visible = true;
		return;
	elseif FrameName == "ItemPack" then
		return;
	elseif FrameName == "Featured" then
		if not _G.Tweening then
			_G.Tweening = true;TitleFrame.Title.Text = FrameName;TitleFrame.Back.Letter.Text = "<";_G.CurrentFrame = FrameName;local CustomTime = Override or Time;
			ShopFrame:TweenSizeAndPosition(
				UDim2.new(0,500,0,400),				
				UDim2.new(0.5,-250,0.5,-200),
				Direction,Style,CustomTime
			);
			ShopFrame.Container.Featured.Position = UDim2.new(1,0,0,0);
			ShopFrame.Container.Featured:TweenPosition(
				UDim2.new(0,0,0,0),
				Direction,Style,CustomTime
			);
			Navigation:TweenPosition(
				UDim2.new(-1,0,0,0),
				Direction,Style,CustomTime
			);
			GameGUI.Inventory.Visible = false;
			GameGUI.Shop.Visible = true;
			wait(CustomTime);
			_G.Tweening = false;
		end;
		return;
	end;

	if not _G.Tweening then
		_G.Tweening = true;
		TitleFrame.Title.Text = FrameName;
		TitleFrame.Back.Letter.Text = "<";
		_G.CurrentFrame = FrameName;
		local CustomTime = Override or Time;
		
		ShopFrame:TweenSizeAndPosition(
			UDim2.new(0,550,0,415),				
			UDim2.new(0.5,-275,0.5,-207),
			Direction,Style,CustomTime
		);
		
		Navigation:TweenPosition(
			UDim2.new(-1,0,0,0),
			Direction,Style,CustomTime
		);
		
		ShopFrame.Container.Featured:TweenPosition(
			UDim2.new(0,-ShopFrame.Container.Featured.Size.X.Offset,0,0),
			Direction,Style,CustomTime
		);
		
		for _,Frame in pairs(Main:GetChildren()) do
			Frame.Position = UDim2.new(1,0,0,0);
		end
		
		Main[FrameName]:TweenPosition(
			UDim2.new(0,0,0,0),
			Direction,Style,CustomTime
		);
		GameGUI.Inventory.Visible = false;
		GameGUI.Shop.Visible = true;
		wait(CustomTime);
		_G.Tweening = false;
	end;

end

for _,NavButton in pairs(Navigation:GetChildren()) do
	NavButton.MouseButton1Click:connect(function()
		script.Parent.Click:Play();
		_G.Navigate(NavButton.Name);
	end)
end

local function GetCurrency(Currency)
	if not _G.Tweening and _G.CurrentFrame ~= "Get"..Currency then
		
		
		if _G.CurrentFrame == "GetCoins" then
			ShopFrame.Container.Coins:TweenPosition(
				UDim2.new(-1,0,0,0),
				Direction,Style,Time
			);
		elseif _G.CurrentFrame == "GetGems" then
			ShopFrame.Container.Gems:TweenPosition(
				UDim2.new(-1,0,0,0),
				Direction,Style,Time
			);
		end;
		
		_G.Tweening = true;
		TitleFrame.Title.Text = Currency.. "!";
		TitleFrame.Back.Letter.Text = "<";
		_G.CurrentFrame = "Get"..Currency;
		
		ShopFrame.Container[Currency]:TweenPosition(
			UDim2.new(0,0,0,0),
			Direction,Style,Time
		);
		ShopFrame.Container.Featured:TweenPosition(
			UDim2.new(0,-ShopFrame.Container.Featured.Size.X.Offset,0,0),
			Direction,Style,Time
		);
		Navigation:TweenPosition(
			UDim2.new(-1,0,0,0),
			Direction,Style,Time
		);
		ShopFrame:TweenSizeAndPosition(
			UDim2.new(0,450,0,325),				
			UDim2.new(0.5,-225,0.5,-163),
			Direction,Style,Time
		);
		for _,Frame in pairs(Main:GetChildren()) do
			Frame:TweenPosition(
				UDim2.new(-1,0,0,0),
				Direction,Style,Time
			);
		end;
		
		wait(Time);
		

		if _G.CurrentFrame == "GetGems" then
			ShopFrame.Container.Coins:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,0
			);
		elseif _G.CurrentFrame == "GetCoins" then
			ShopFrame.Container.Gems:TweenPosition(
				UDim2.new(1,0,0,0),
				Direction,Style,0
			);
		end;	
		
		for _,Frame in pairs(Main:GetChildren()) do
			Frame.Position = UDim2.new(1,0,0,0);
		end;
		_G.Tweening = false;
	end;
end


_G.GetGems = function()
	GetCurrency("Gems");
end

_G.GetCredits = function()
	GetCurrency("Coins")
	--[[if not _G.Tweening then
		_G.Tweening = true;
		TitleFrame.Title.Text = "Coins!";
		TitleFrame.Back.Letter.Text = "<";
		_G.CurrentFrame = "GetCoins";
		
		ShopFrame.Container.Coins:TweenPosition(
			UDim2.new(0,0,0,0),
			Direction,Style,Time
		);
		ShopFrame.Container.Featured:TweenPosition(
			UDim2.new(0,-ShopFrame.Container.Featured.Size.X.Offset,0,0),
			Direction,Style,Time
		);
		Navigation:TweenPosition(
			UDim2.new(-1,0,0,0),
			Direction,Style,Time
		);
		ShopFrame:TweenSizeAndPosition(
			UDim2.new(0,450,0,325),				
			UDim2.new(0.5,-225,0.5,-163),
			Direction,Style,Time
		);
		for _,Frame in pairs(Main:GetChildren()) do
			Frame:TweenPosition(
				UDim2.new(-1,0,0,0),
				Direction,Style,Time
			);
		end;
		
		wait(Time);
		for _,Frame in pairs(Main:GetChildren()) do
			Frame.Position = UDim2.new(1,0,0,0);
		end;
		_G.Tweening = false;
	end;]]
end



ShopFrame.Cash.Icon.Container.More.MouseButton1Click:connect(function()
	script.Parent.Click:Play();
	_G.GetCredits();
end)

ShopFrame.Gems.Icon.Container.More.MouseButton1Click:connect(function()
	script.Parent.Click:Play();
	_G.GetGems();
end)


game.ReplicatedStorage.CashSound.OnClientEvent:connect(function()
	script.Parent.Ching:Play();
end)


for i,Button in pairs(ShopFrame.Container.Coins:GetChildren()) do
	Button.MouseButton1Click:connect(function()
		script.Parent.Click:Play();
		game.ReplicatedStorage.PurchaseProduct:FireServer(Button.Name,"Coins");
	end)
end
for i,Button in pairs(ShopFrame.Container.Gems:GetChildren()) do
	Button.MouseButton1Click:connect(function()
		script.Parent.Click:Play();
		game.ReplicatedStorage.PurchaseProduct:FireServer(Button.Name,"Gems");
	end)
end



Dock.Inventory.MouseButton1Click:connect(function()	 
	ShopFrame.Visible = false;
end);

Dock.Shop.MouseButton1Click:connect(function() 
	if GameGUI.Processing.Visible or GameGUI.CaseOpen.Visible then return; end;
	
	if _G.ShowItemPack then
		ItemPackFrame.Visible = true;
	else
		ShopFrame.Visible = not ShopFrame.Visible;
	end;
end);
ItemPackFrame.Buy.Cancel.MouseButton1Click:connect(function()ItemPackFrame.Visible=false;_G.ShowItemPack=false; ShopFrame.Visible=true; end);
ItemPackFrame.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.GetPack:FireServer(475567921); -- futuristuc
end)

Navigation.ItemPack.LearnMore.MouseButton1Click:connect(function()
	ShopFrame.Visible = false;
	ItemPackFrame.Visible = true;
end)


local ShopTimer = ShopFrame.Container.Featured.Cover.Timer.TimeLeft;
local PackTimer = ItemPackFrame.Timer.TimeLeft;

local ShopDays = ShopFrame.Container.Featured.Cover.Timer.Days;
local PackDays = ItemPackFrame.Timer.Days;


game:GetService("RunService"):BindToRenderStep("Timer",100,function()
	local TotalSecondsLeft = _G.OfferEndTime-os.time();
	local TotalMinutesLeft = math.floor(TotalSecondsLeft/60);
	local TotalHoursLeft = math.floor(TotalMinutesLeft/60);
	local TotalDaysLeft = math.floor(TotalHoursLeft/24);
	
	local MinutesLeft = TotalMinutesLeft%60;
	local SecondsLeft = TotalSecondsLeft%60;
	
	if MinutesLeft < 10 then MinutesLeft = "0"..MinutesLeft; end;
	if SecondsLeft < 10 then SecondsLeft = "0"..SecondsLeft; end;
	if TotalHoursLeft < 10 then TotalHoursLeft = "0"..TotalHoursLeft;end;
	
		
	local TimeText = TotalHoursLeft .. ":" .. MinutesLeft .. ":" .. SecondsLeft;
	if TotalSecondsLeft < 0 then
		TimeText = "00:00:00";
		ShopFrame.Container.Featured.Cover.Timer.Visible = false;
	end
	
	local DayText = (TotalDaysLeft > 0 and TotalDaysLeft .. " days left!") or "Ends Today!";
	local DayText = (TotalSecondsLeft < 0 and "Offer Ended.") or DayText;
	
	PackTimer.Text = TimeText;
	ShopTimer.Text = TimeText;
	
	ShopDays.Text = DayText;
	PackDays.Text = DayText;
end);


local Coins = 0;
local Elite = game.ReplicatedStorage.AmElite:InvokeServer();
game.ReplicatedStorage.GetCoin.OnClientEvent:connect(function()
	local MaxCoins = (Elite and 15) or 10;
	if Coins < MaxCoins then
		Coins = Coins + 1;
	end
	if Coins >= MaxCoins then
		GameGUI.CashBag.Image = "http://www.roblox.com/asset/?id=197073328";
		GameGUI.CashBag.Full.Visible = true;
		if not Elite then GameGUI.CashBag.Elite.Visible = true; end;
	end	
	GameGUI.CashBag.Coins.Text = Coins;
end)

