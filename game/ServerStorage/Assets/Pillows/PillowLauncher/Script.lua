local tool = script.Parent
local canFire = true
local gunWeld


-----------------
--| Constants |--
-----------------

local GRAVITY_ACCELERATION = 196.2

local RELOAD_TIME = tool.Configurations.ReloadTime.Value -- Seconds until tool can be used again
local ROCKET_SPEED = tool.Configurations.RocketSpeed.Value -- Speed of the projectile

local ROCKET_PART_SIZE = Vector3.new(1.2, 1.2, 3.27)


local BoomSound = script:WaitForChild('Boom')

local attackCooldown = tool.Configurations.AttackCooldown.Value
local damage = tool.Configurations.Damage.Value
local reloadTime = tool.Configurations.ReloadTime.Value

local function createEvent(eventName)
	local event = game.ReplicatedStorage:FindFirstChild(eventName)
	if not event then
		event = Instance.new("RemoteEvent", game.ReplicatedStorage)
		event.Name = eventName
	end
	return event
end

local updateEvent = createEvent("ROBLOX_RocketUpdateEvent")
local equipEvent = createEvent("ROBLOX_RocketEquipEvent")
local unequipEvent = createEvent("ROBLOX_RocketUnequipEvent")
local fireEvent = createEvent("ROBLOX_RocketFireEvent")

updateEvent.OnServerEvent:connect(function(player, neckC0, rshoulderC0)
	local character = player.Character
	local humanoid = character.Humanoid
	
	if humanoid.Health <= 0 then return end
	
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		character.Torso.Neck.C0 = neckC0
		character.Torso:FindFirstChild("Right Shoulder").C0 = rshoulderC0
		gunWeld = character:FindFirstChild("Right Arm"):WaitForChild("RightGrip")
	
	elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
		character.Head.Neck.C0 = neckC0
		character.RightUpperArm.RightShoulder.C0 = rshoulderC0
		gunWeld = character.RightHand:WaitForChild("RightGrip")
	end
end)

equipEvent.OnServerEvent:connect(function(player)
	player.Character.Humanoid.AutoRotate = false
end)

unequipEvent.OnServerEvent:connect(function(player)
	player.Character.Humanoid.AutoRotate = true
end)

--NOTE: We create the rocket once and then clone it when the player fires
local Rocket = script.PillowRocket:Clone() do
	-- Set up the rocket part

	-- Add the mesh

	-- Add fire
	Rocket.Fire.Enabled = true
	Rocket.Transparency = 0

	-- Add a force to counteract gravity
	local bodyForce = Instance.new('BodyForce', Rocket)
	bodyForce.Name = 'Antigravity'
	bodyForce.force = Vector3.new(0, Rocket:GetMass() * GRAVITY_ACCELERATION, 0)

	-- Clone the sounds and set Boom to PlayOnRemove
	local boomSoundClone = BoomSound:Clone()
	boomSoundClone.PlayOnRemove = true
	boomSoundClone.Parent = Rocket

	-- Finally, clone the rocket script and enable it
--	local rocketScriptClone = RocketScript:Clone()
--	rocketScriptClone.Parent = Rocket
--	rocketScriptClone.Disabled = false
end


fireEvent.OnServerEvent:connect(function(player, target)
	if canFire and player.Character == tool.Parent then
		canFire = false
		
		-- Create a clone of Rocket and set its color
		local rocketClone = Rocket:Clone()
		--game.Debris:AddItem(rocketClone, 30)
		rocketClone.Touched:connect(function(hit)
			if hit and hit.Parent and hit.Parent ~= player.Character and hit.Parent ~= tool then
				local explosion = Instance.new("Explosion", game.Workspace)
				explosion.BlastPressure = 0
				explosion.Position = rocketClone.Position
				rocketClone:Destroy()
			end
			if not hit or not hit.Parent then
				return
			end
			local RightArm = player.Character:FindFirstChild("Right Arm") or player.Character:FindFirstChild("RightHand")
			if not RightArm then
				return
			end
			local RightGrip = RightArm:FindFirstChild("RightGrip")
			if not RightGrip or (RightGrip.Part0 ~= tool.Handle and RightGrip.Part1 ~= tool.Handle) then
				return
			end

			local character = hit.Parent
			if character == player.Character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			humanoid:TakeDamage(damage)
		end)

		
		spawn(function()
			wait(30)
			if rocketClone then rocketClone:Destroy() end
		end)		
		
		-- Position the rocket clone and launch!
		local spawnPosition = (tool.Handle.CFrame * CFrame.new(2, 0, 0)).p
		rocketClone.CFrame = CFrame.new(spawnPosition, target) --NOTE: This must be done before assigning Parent
		rocketClone.Velocity = rocketClone.CFrame.lookVector * ROCKET_SPEED --NOTE: This should be done before assigning Parent
		rocketClone.Parent = game.Workspace		
		
		-- Attach creator tags to the rocket early on
		local creatorTag = Instance.new('ObjectValue', rocketClone)
		creatorTag.Value = player
		creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
		local iconTag = Instance.new('StringValue', creatorTag)
		iconTag.Value = tool.TextureId
		iconTag.Name = 'icon'
		
		delay(attackCooldown, function()
			canFire = true
		end)
	end
end)