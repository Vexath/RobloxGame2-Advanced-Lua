print("Badge Awarder Loaded. BadgeID: " .. script.Parent.BadgeID.Value)



-- ROBLOX scripter hackers, see what you can do with this:
-- game:GetService("BadgeService"):UserHasBadge(userid, badgeid)


function OnTouch(part)
	if (part.Parent:FindFirstChild("Humanoid") ~= nil) then
		local p = game.Players:GetPlayerFromCharacter(part.Parent)
		if (p ~= nil) then
			print("Awarding BadgeID: " ..script.Parent.BadgeID.Value .. " to UserID: " .. p.userId)
			local b = game:GetService("BadgeService")
			b:AwardBadge(p.userId, script.Parent.BadgeID.Value)
		end
	end
end

script.Parent.Touched:connect(OnTouch)
