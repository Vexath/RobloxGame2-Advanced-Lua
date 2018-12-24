local ServerSettings,IsOwner = game.ReplicatedStorage.GetServerSettings:InvokeServer();
local MainGUI = script.Parent.Game;
local SettingsButton = MainGUI.Settings.VIPSettings;

local MM2ID = 929751085;	

if ServerSettings and IsOwner then
	local SettingsFrame = MainGUI.SettingsFrame;
	
	--[[if not HasRadio then
		MainGUI.Settings.Size = UDim2.new(0,150,0,50);
	else
		MainGUI.Settings.Size = UDim2.new(0,200,0,50);
		SettingsButton.Position = UDim2.new(0,200,0,0);
	end;]]
		
	SettingsButton.Visible = true;
	
	SettingsButton.MouseButton1Click:connect(function()
		SettingsFrame.Visible = not SettingsFrame.Visible;
	end)
	
	SettingsFrame.Close.MouseButton1Click:connect(function()
		SettingsFrame.Visible = false;
	end)
	
	local function UpdateSettings()
		for _,SettingFrame in pairs(SettingsFrame:GetChildren()) do
			if SettingFrame:FindFirstChild("Button") then
				if ServerSettings[SettingFrame.Name] == true then
					SettingFrame.Button.Text = "On";
					SettingFrame.Button.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
				else
					SettingFrame.Button.Text = "Off";
					SettingFrame.Button.Style = Enum.ButtonStyle.RobloxRoundButton;
				end;
			end;
		end
	end
	
	for _,SettingFrame in pairs(SettingsFrame:GetChildren()) do
		if ServerSettings[SettingFrame.Name] ~= nil then
			SettingFrame.Button.MouseButton1Click:connect(function()
				ServerSettings[SettingFrame.Name] = not ServerSettings[SettingFrame.Name];
				UpdateSettings();
				game.ReplicatedStorage.UpdateServerSettings:FireServer(ServerSettings);
			end)
		end;
	end	
	
	UpdateSettings();	
end;