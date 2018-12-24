local Surface = script.Surface:Clone();
Surface.Parent = script.Parent.Parent;
Surface.Adornee = game.Workspace.Lobby.Elite.Screen;

Surface.Frame.Frame.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.GetElite:FireServer();
end)

