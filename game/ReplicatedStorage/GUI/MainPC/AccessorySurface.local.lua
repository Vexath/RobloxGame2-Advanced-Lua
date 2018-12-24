
local Surface = script.Surface:Clone();
Surface.Parent = script.Parent.Parent;
pcall(function() Surface.Adornee = game.Workspace.Lobby.AccessoryGamepass.Screen; end);

Surface.Frame.Frame.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.GetAccessory:FireServer();
end)

