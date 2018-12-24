-- Jump Throttler by selvius13

local TimeBetweenJumps = 0; -- Time in seconds.
local CanJump = true;

-----------------------------

local Player = game.Players.LocalPlayer
repeat wait() until Player.Character ~= nil;
local Character = Player.Character
--repeat wait() until Character:FindFirstChild("Humanoid")
local Humanoid = Character:WaitForChild("Humanoid");

local LastJump = time();
Humanoid.Changed:connect(function()
	if Humanoid.Jump then
		if time()-LastJump >= TimeBetweenJumps and CanJump then
			LastJump = time();
		else
			Humanoid.Jump = false;
		end
	end
end)


game.ReplicatedStorage.JumpDelay.OnClientEvent:connect(function(GameModeName)
	local Delays = {
		["Infection"] = 1.5;
		["Juggernaut"] = 3;
		["HotPotato"] = false;
	};
	if type(Delays[GameModeName]) == "number" then
		TimeBetweenJumps = Delays[GameModeName];
	else
		CanJump = false;
	end;
end)