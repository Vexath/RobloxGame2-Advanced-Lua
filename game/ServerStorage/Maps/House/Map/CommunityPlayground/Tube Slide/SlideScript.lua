local Slide = script.Parent:WaitForChild("Slide")

-- Parts
local Entry = Slide:WaitForChild("Entry")

local function MovePlayer(Part)
	if game.Players:GetPlayerFromCharacter(Part.Parent) then
		local Character = Part.Parent
		local Humanoid = Character:WaitForChild("Humanoid")
		local RootPart = Character:WaitForChild("HumanoidRootPart")
		
		if Humanoid.Sit == false then
			-- Make player sit
			Humanoid.Sit = true
			
			if Character.PrimaryPart then
				-- Move player
				Character:SetPrimaryPartCFrame(Entry.CFrame * CFrame.Angles(0,0,math.rad(90)) + Entry.CFrame.lookVector*2)
			else
				-- Extra precaution
				RootPart.CFrame = CFrame.new(Entry.CFrame * CFrame.Angles(0,0,math.rad(90)) + Entry.CFrame.lookVector*2)
			end
		end
	end
end

-- Listen for touches
Entry.Touched:connect(MovePlayer)