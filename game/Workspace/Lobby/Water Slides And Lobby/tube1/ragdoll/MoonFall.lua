local MoonFall = game.ReplicatedStorage.Events.Physics2

script.Parent.Touched:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
        local plr = workspace[hit.Parent.Name] --Access character from workspace.
        local player = game.Players:GetPlayerFromCharacter(plr) --Access (plr)
		local hrp = plr:WaitForChild("HumanoidRootPart")
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
		local h = hit.Parent:findFirstChild("Humanoid")
		if (h ~= nil) then
			h.Sit = true
		end
	end
end)
