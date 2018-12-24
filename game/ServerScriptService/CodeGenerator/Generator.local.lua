if not script.Parent:FindFirstChild("GeneratorGUI") then
	local GUI = script:WaitForChild("GeneratorGUI"):Clone();
	GUI.Parent = script.Parent;
	
	GUI:WaitForChild("Main"):WaitForChild("Generate").MouseButton1Click:connect(function()
		GUI.Main:WaitForChild("Code").Text = "Generating...";
		local Code = game.ReplicatedStorage.G:InvokeServer();
		GUI.Main.Code.Text = Code;
	end)	
	
end