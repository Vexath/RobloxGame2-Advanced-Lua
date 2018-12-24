--[[game:GetService("UserInputService").InputBegan:connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.ButtonL1 then
		for _,Obj in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
			if Obj:IsA("Tool") then
				Obj.Parent = game.Players.LocalPlayer.Character;
				return;
			end
		end
		for _,Obj in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if Obj:IsA("Tool") then
				Obj.Parent = game.Players.LocalPlayer.Backpack;
				return;
			end
		end
	end
end)]]

script.Parent.Game.Knife.MouseButton1Down:connect(function()
	for _,Obj in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if Obj:IsA("Tool") and Obj:FindFirstChild("KnifeLocal") then
			Obj.Parent = game.Players.LocalPlayer.Character;
			return;
		end
	end
	for _,Obj in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if Obj:IsA("Tool") and Obj:FindFirstChild("KnifeLocal") then
			Obj.Parent = game.Players.LocalPlayer.Backpack;
			return;
		end
	end
end)