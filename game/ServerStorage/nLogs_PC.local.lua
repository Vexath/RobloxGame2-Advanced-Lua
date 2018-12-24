if _G.nLog == nil then _G.nLog = {}; end;
if _G.Mode == nil then _G.Mode = "Hide"; end;

if game.Players.LocalPlayer.Name ~= "selvius13" and game.Players.LocalPlayer.Name ~= "Player1" then
	script:Destroy();
end

_G.nLog = game.ReplicatedStorage.GetLogs:InvokeServer();

local Screen = script:WaitForChild("Output");
Screen.Parent = script.Parent;
local Logs = Screen:WaitForChild("Logs"):WaitForChild("Container");
local Colors = {
	[Enum.MessageType.MessageOutput] = Color3.new(1,1,1);
	[Enum.MessageType.MessageError] = Color3.new(1,0,0);
	[Enum.MessageType.MessageInfo] = Color3.new(0.1,0.1,1);
	[Enum.MessageType.MessageWarning] = Color3.new(1,120/250,0);
};

local Direction = "Out"; local Style = "Quad";

local function UpdateLogFrame(Time)
	if _G.Mode == "Preview" then
		Logs:TweenPosition(UDim2.new(0,0,-0.8,0),Direction,Style,Time or 0.2)
	elseif _G.Mode == "Full" then
		Logs:TweenPosition(UDim2.new(0,0,0,0),Direction,Style,Time or 0.2);
	elseif _G.Mode == "Hide" then
		Logs:TweenPosition(UDim2.new(0,0,-1,0),Direction,Style,Time or 0.2);
	end;
end

local function UpdateLogs(HTTP)
	Logs:ClearAllChildren();
	local Index = 1;
	for _,LogData in pairs(_G.nLog) do
		if (not HTTP) or (HTTP and string.find(LogData.Message,"HTTP") == nil and string.find(LogData.Message,"http") == nil) then
			local NewLog = script.Log:Clone();
			NewLog.Message.Text = LogData.Message;
			NewLog.Message.TextColor3 = Colors[LogData.Type];
			NewLog.Time.Text = LogData.Time;
			NewLog.Parent = Logs;
			NewLog.Position = UDim2.new(0,0,1,-(NewLog.AbsoluteSize.Y)*Index);
			NewLog.Visible = true;
			Index = Index + 1;
		end;
	end
end

Screen.Button.MouseButton1Click:connect(function()
	_G.Mode = (_G.Mode=="Preview" and "Full") or (_G.Mode=="Full" and "Hide") or (_G.Mode == "Hide" and "Preview");
	UpdateLogFrame();
end)

local HTTP = false;
Screen.Button2.MouseButton1Click:connect(function()
	HTTP = (not HTTP);
	UpdateLogs(HTTP);
end)

UpdateLogFrame(0);
UpdateLogs();

wait(1);

print("Test");