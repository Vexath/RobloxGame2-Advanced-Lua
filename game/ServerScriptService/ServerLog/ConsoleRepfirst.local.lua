if game.Players.LocalPlayer.Name ~= "selvius13" then
	print("Bad permissions");
	script:Destroy();
	return;
end

print("Loading console");

wait();

local ConsoleGUI = script:WaitForChild("ConsoleGUI");
ConsoleGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui");

local Logs = game.ReplicatedStorage.RequestServerOutput:InvokeServer();
local ConvertTime = require(script:WaitForChild("ConvertTimeStamp"));

local Controls = ConsoleGUI.Main.Controls;
local LogContainer = ConsoleGUI.Main.Output;
local CurrentPage = 0;
local MaxPages = 1;

local FilterNameToEnum={Info=Enum.MessageType.MessageInfo;Warning=Enum.MessageType.MessageWarning;Output=Enum.MessageType.MessageOutput;Error=Enum.MessageType.MessageError;};
local Filters = {
	[Enum.MessageType.MessageOutput] 	= true;
	[Enum.MessageType.MessageInfo] 		= true;
	[Enum.MessageType.MessageWarning]	= true;
	[Enum.MessageType.MessageError] 	= true;
	FilterText = "";
};

local MessageColors = {
	[Enum.MessageType.MessageOutput] 	= Color3.new(1, 1, 1);
	[Enum.MessageType.MessageInfo] 		= Color3.new(0.4, 0.5, 1); 
	[Enum.MessageType.MessageWarning]	= Color3.new(1, 0.6, 0.4); 
	[Enum.MessageType.MessageError] 	= Color3.new(1, 0, 0); 
};

local Labels = {};

for i = 1,#Logs do
	local NewLabel = script.LogEntry:Clone();
	local PageNumber =  math.ceil(i/2048)
	NewLabel.Text = PageNumber.." " .. ConvertTime(Logs[i].Time) .. " -- " .. Logs[i].Text;
	NewLabel.TextColor3 = MessageColors[Logs[i].Type];
	Labels[i] = NewLabel;
	NewLabel.Visible = false;
	NewLabel.Parent = LogContainer;
end

local function RefreshPages()
	for _,Page in pairs(LogContainer:GetChildren()) do
		Page.Visible = Page.Name == "Page"..CurrentPage or Page.Name == "ScrollBar";
		if Page:IsA("ScrollingFrame") then
			Page.CanvasPosition = Vector2.new(0,Page.CanvasSize.Y.Offset-Page.AbsoluteWindowSize.Y);
		end;
	end
	Controls.Page.CurrentPage.Text = CurrentPage;
	Controls.Page.MaxPages.Text = "/ " .. MaxPages;
end


local function Filter(Message)
	if not Filters[Message.Type] then return false; end;
	if #Filters.FilterText > 0 then
		if not string.find(string.lower(Message.Text),Filters.FilterText) then return false; end;
	end
	
	return true;
end

local function UpdateContainer()
	local LastCurrent = CurrentPage;
	
	local Position = 0;
	local Counter = 1;
	
	local LastPage = 0;
	MaxPages = 0;
	
	for i = 1,#Logs do
		if Filter(Logs[i]) then

			local PageNumber = math.ceil(Counter/2048);
			local PageFrame = LogContainer:FindFirstChild("Page"..PageNumber) or script.Page:Clone();
			PageFrame.Name = "Page"..PageNumber;
			PageFrame.Parent = LogContainer;
			
			if PageNumber ~= LastPage then
				if LastPage ~= 0 then
					LogContainer["Page"..LastPage].CanvasSize = UDim2.new(0,0,0,Position);
				end;
				Position = 0;
				Controls.Page.CurrentPage.Text = PageNumber;
				MaxPages = PageNumber;
			end
			
			Labels[i].Visible = true;
			Labels[i].Position = UDim2.new(0,0,0,Position);
			Position = Position+14;	
			Labels[i].Parent = PageFrame.Container;
						
			Counter = Counter+1;
			LastPage = PageNumber;
			CurrentPage = PageNumber;
			
		else
			Labels[i].Visible = false;
			Labels[i].Parent = LogContainer.NoPage;
		end;
		
	end
	
	if LastPage ~= 0 then
		LogContainer["Page"..LastPage].CanvasSize = UDim2.new(0,0,0,Position+14);
	end;
	
	if LogContainer:FindFirstChild("Page"..LastCurrent) and LastCurrent <= MaxPages and LastCurrent > 0 then
		CurrentPage = LastCurrent;
	end	
	
	RefreshPages();

end

UpdateContainer();

Controls.Page.CurrentPage.FocusLost:connect(function()
	if LogContainer:FindFirstChild("Page" .. Controls.Page.CurrentPage.Text) then
		CurrentPage = tonumber(Controls.Page.CurrentPage.Text);
		RefreshPages();
	else
		Controls.Page.CurrentPage.Text = CurrentPage;
	end;
end)
Controls.Page.Left.MouseButton1Click:connect(function()
	local NewPage = CurrentPage - 1;
	if LogContainer:FindFirstChild("Page" .. NewPage) then
		CurrentPage = NewPage;
		RefreshPages();
	end;
end)
Controls.Page.Right.MouseButton1Click:connect(function()
	local NewPage = CurrentPage + 1;
	if NewPage <= MaxPages then
		CurrentPage = NewPage;
		RefreshPages();
	end;
end)

for _,FilterFrame in pairs(Controls.Settings:GetChildren()) do
	FilterFrame.Button.MouseButton1Click:connect(function()
		local FilterEnum = FilterNameToEnum[FilterFrame.Name];
		Filters[FilterEnum] = not Filters[FilterEnum];
		FilterFrame.Center.Visible = Filters[ FilterEnum ];
		UpdateContainer();
	end)
end

Controls.Filter.TextFilter.FocusLost:connect(function()
	Filters.FilterText = string.lower(Controls.Filter.TextFilter.Text);
	UpdateContainer();
end)

local NeedsUpdate = false;
local LastLog = -1000;

game.ReplicatedStorage.ServerMessageOut.OnClientEvent:connect(function(Text,Type,Time)
	local Pos = #Logs+1;
			
	table.insert(Logs,Pos,{Text=Text,Type=Type,Time=Time});
	
	local NewLabel = script.LogEntry:Clone();
	local PageNumber =  math.ceil(Pos/2048)
	NewLabel.Text = "" .. PageNumber.." " .. ConvertTime(Time) .. " -- " ..Text ;
	NewLabel.TextColor3 = MessageColors[Type];
	Labels[Pos] = NewLabel;
	NewLabel.Visible = false;
	
	NeedsUpdate = true;
	if ConsoleGUI.Main.Visible then	
		local ThisLog = time();
		LastLog = ThisLog;
		spawn(function()
			wait(0.1)
			if LastLog == ThisLog then
				UpdateContainer();
			end;
		end)
	end;
end)

ConsoleGUI.Main.Controls.Close.Button.MouseButton1Click:connect(function()
	ConsoleGUI.Main.Visible = false;
end)


game:GetService("UserInputService").InputBegan:connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.F7 then
		if ConsoleGUI.Main.Visible == false and NeedsUpdate then
			NeedsUpdate = false;
			UpdateContainer();
		end
		ConsoleGUI.Main.Visible = not ConsoleGUI.Main.Visible;
	end
end)
