local camera = game.Workspace.CurrentCamera;
local player = game.Players.LocalPlayer
local character = game.Players.LocalPlayer.CharacterAdded:Wait();
local hrp = character:WaitForChild("HumanoidRootPart");
local humanoid = character:WaitForChild("Humanoid");
local animate = character:WaitForChild("Animate");

while (not character.Parent) do character.AncestryChanged:Wait(); end
local idleAnim = humanoid:LoadAnimation(script:WaitForChild("IdleAnim"));
local moveAnim = humanoid:LoadAnimation(script:WaitForChild("MoveAnim"));
local lastAnim = idleAnim;

local bodyGyro = Instance.new("BodyGyro");
bodyGyro.maxTorque = Vector3.new(1, 1, 1)*10^6;
bodyGyro.P = 10^6;

local bodyVel = Instance.new("BodyVelocity");
bodyVel.maxForce = Vector3.new(1, 1, 1)*10^6;
bodyVel.P = 10^4;

local isFlying = false;
local isJumping = false;
local movement = {forward = 0, backward = 0, right = 0, left = 0};

-- functions

local function setFlying(flying)
	isFlying = flying;
	bodyGyro.Parent = isFlying and hrp or nil;
	bodyVel.Parent = isFlying and hrp or nil;
	bodyGyro.CFrame = hrp.CFrame;
	bodyVel.Velocity = Vector3.new();
	
	animate.Disabled = isFlying;
	
	if (isFlying) then
		lastAnim = idleAnim;
		lastAnim:Play();
	else
		lastAnim:Stop();
	end
end

local function onUpdate(dt)
	if (isFlying) then
		local cf = camera.CFrame;
		local direction = cf.rightVector*(movement.right - movement.left) + cf.lookVector*(movement.forward - movement.backward);
		
		if (direction:Dot(direction) > 0) then
			direction = direction.unit;
		end

		bodyGyro.CFrame = cf;
		bodyVel.Velocity = direction * humanoid.WalkSpeed * 3;
	end
end

local function onJumpRequest()
	if (not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead) then
		return;
	end
	
	if (isFlying) then
		setFlying(false);
		isJumping = false;
	else
		setFlying(true);
	end
end
	
local function onStateChange(old, new)
	if (new == Enum.HumanoidStateType.Landed) then	
		isJumping = false;
	elseif (new == Enum.HumanoidStateType.Jumping) then
		isJumping = true;
	end
end

--turn off flying for tourneys--


local function movementBind(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		movement[actionName] = 1;
	
	elseif (inputState == Enum.UserInputState.End) then
		movement[actionName] = 0;
	end
	
	if (isFlying) then
		local isMoving = movement.right + movement.left + movement.forward + movement.backward > 0;
		local nextAnim = isMoving and moveAnim or idleAnim;
		if (nextAnim ~= lastAnim) then
			lastAnim:Stop();
			lastAnim = nextAnim;
			lastAnim:Play();
		end
	end
	
	return Enum.ContextActionResult.Pass;
end

-- connections

humanoid.StateChanged:Connect(onStateChange);


game:GetService("UserInputService").InputBegan:connect(function(input)
    if input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.F then
        onJumpRequest()
	end
end)

game:GetService("ContextActionService"):BindAction("forward", movementBind, false, Enum.PlayerActions.CharacterForward);
game:GetService("ContextActionService"):BindAction("backward", movementBind, false, Enum.PlayerActions.CharacterBackward);
game:GetService("ContextActionService"):BindAction("left", movementBind, false, Enum.PlayerActions.CharacterLeft);
game:GetService("ContextActionService"):BindAction("right", movementBind, false, Enum.PlayerActions.CharacterRight);
game:GetService("RunService").RenderStepped:Connect(onUpdate)

--Works with Controllers now with deadzone set to 0.25--
game:GetService("UserInputService").InputChanged:connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			if input.Position.X > 0.25 then
				movement["right"] = 1;
			
			elseif input.Position.X < -0.25 then
				movement["left"] = 1;
			
			elseif input.Position.Y > 0.25 then
				movement["forward"] = 1;
		
			elseif input.Position.Y < -0.25 then
				movement["backward"] = 1;
		
			else 
				movement["left"] = 0;
				movement["right"] = 0;
				movement["forward"] = 0;
				movement["backward"] = 0;
			end
			if (isFlying) then
				local isMoving = movement.right + movement.left + movement.forward + movement.backward > 0;
				local nextAnim = isMoving and moveAnim or idleAnim;
				if (nextAnim ~= lastAnim) then
					lastAnim:Stop();
					lastAnim = nextAnim;
					lastAnim:Play();
				end
			end
		end
	end
end)

game:GetService("UserInputService").InputEnded:connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		-- Stop moving character if left thumbstick released
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			movement["left"] = 0;
			movement["right"] = 0;
			movement["forward"] = 0;
			movement["backward"] = 0;
		end
		if (isFlying) then
			local isMoving = movement.right + movement.left + movement.forward + movement.backward > 0;
			local nextAnim = isMoving and moveAnim or idleAnim;
			if (nextAnim ~= lastAnim) then
				lastAnim:Stop();
				lastAnim = nextAnim;
				lastAnim:Play();
			end
		end
	end
end)