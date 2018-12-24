local Players = {
	"Player1";
	"selvius13";
};

local Access = false;
for _,PlayerName in pairs(Players) do if game.Players.LocalPlayer.Name == PlayerName then Access = true; break; end; end;
if not Access then return end;


if _G.nLog == nil then _G.nLog = {}; end;
if _G.Mode == nil then _G.Mode = "Hide"; end;

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
		Logs:TweenPosition(UDim2.new(0,0,-0.2,0),Direction,Style,Time or 0.2);
	elseif _G.Mode == "Hide" then
		Logs:TweenPosition(UDim2.new(0,0,-1,0),Direction,Style,Time or 0.2);
	end;
end

local function UpdateLogs()
	Logs:ClearAllChildren();
	for Index,LogData in pairs(_G.nLog) do
		local NewLog = script.Log:Clone();
		NewLog.Message.Text = LogData.Message;
		NewLog.Message.TextColor3 = Colors[LogData.Type];
		NewLog.Time.Text = LogData.Time;
		NewLog.Parent = Logs;
		NewLog.Position = UDim2.new(0,0,1,-(NewLog.AbsoluteSize.Y)*Index);
		NewLog.Visible = true;
	end
end

game:GetService("LogService").MessageOut:connect(function(Message,Type)
    table.insert(_G.nLog,1,{
		Time = time();
		Message = Message;
		Type = Type;
	});
	UpdateLogs();
end)

Screen.Button.MouseButton1Click:connect(function()
	_G.Mode = (_G.Mode=="Preview" and "Full") or (_G.Mode=="Full" and "Hide") or (_G.Mode == "Hide" and "Preview");
	UpdateLogFrame();
end)
Screen.Button.Visible = true;

UpdateLogFrame(0);
UpdateLogs();

wait(1);

print("Test");