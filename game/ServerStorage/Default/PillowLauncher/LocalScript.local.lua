-- Variables for services
local render = game:GetService("RunService").RenderStepped
local contextActionService = game:GetService("ContextActionService")
local userInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local Tool = script.Parent

-- Variables for Module Scripts
local screenSpace = require(Tool:WaitForChild("ScreenSpace"))

local connection

local neck, shoulder, oldNeckC0, oldShoulderC0

local mobileShouldTrack = true

-- Thourough check to see if a character is sitting
local function amISitting(character)
	return character.Humanoid.SeatPart ~= nil
end

-- Function to call on renderstepped. Orients the character so it is facing towards
-- the player mouse's position in world space. If character is sitting then the torso
-- should not track
local function frame(mousePosition)
	-- Special mobile consideration. We don't want to track if the user was touching a ui
	-- element such as the movement controls. Just return out of function if so to make sure
	-- character doesn't track
	if not mobileShouldTrack then return end
	
	--This math is completely wrong with R15. We're better off just not doing it at all
	if player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return
	end
	
	-- Make sure character isn't swiming. If the character is swimming the following code will
	-- not work well; the character will not swim correctly. Besides, who shoots underwater?
	if player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
		local torso = player.Character.HumanoidRootPart
		local head = player.Character.Head
		
		local toMouse = (mousePosition - head.Position).unit
		local angle = math.acos(toMouse:Dot(Vector3.new(0,1,0)))
		
		local neckAngle = angle
	
		-- Limit how much the head can tilt down. Too far and the head looks unnatural
		if math.deg(neckAngle) > 110 then
			neckAngle = math.rad(110)
		end
		neck.C0 = CFrame.new(0,1,0) * CFrame.Angles(math.pi - neckAngle,math.pi,0)
		
		-- Calculate horizontal rotation
		local arm do
			arm = player.Character:FindFirstChild("Right Arm") or
				  player.Character:FindFirstChild("RightUpperArm")
		end
		local fromArmPos = torso.Position + torso.CFrame:vectorToWorldSpace(Vector3.new(
			torso.Size.X/2 + arm.Size.X/2, torso.Size.Y/2 - arm.Size.Z/2, 0))
		local toMouseArm = ((mousePosition - fromArmPos) * Vector3.new(1,0,1)).unit
		local look = (torso.CFrame.lookVector * Vector3.new(1,0,1)).unit
		local lateralAngle = math.acos(toMouseArm:Dot(look))		
		
		-- Check for rogue math
		if tostring(lateralAngle) == "-1.#IND" then
			lateralAngle = 0
		end		
		
		-- Handle case where character is sitting down
		if player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated then			
			
			local cross = torso.CFrame.lookVector:Cross(toMouseArm)
			if lateralAngle > math.pi/2 then
				lateralAngle = math.pi/2
			end
			if cross.Y < 0 then
				lateralAngle = -lateralAngle
			end
		end	
		
		-- Turn shoulder to point to mouse
		shoulder.C0 = CFrame.new(1,0.5,0) * CFrame.Angles(math.pi/2 - angle,math.pi/2 + lateralAngle,0)	
		
		-- If not sitting then aim torso laterally towards mouse
		if not amISitting(player.Character) then
			torso.CFrame = CFrame.new(torso.Position, torso.Position + (Vector3.new(
				mousePosition.X, torso.Position.Y, mousePosition.Z)-torso.Position).unit)
		end	
	end
end

-- Function to bind to render stepped if player is on PC
local function pcFrame()
	frame(mouse.Hit.p)
end

-- Function to bind to touch moved if player is on mobile
local function mobileFrame(touch, processed)
	-- Check to see if the touch was on a UI element. If so, we don't want to update anything
	if not processed then
		-- Calculate touch position in world space. Uses Stravant's ScreenSpace Module script
		-- to create a ray from the camera.
		local test = screenSpace.ScreenToWorld(touch.Position.X, touch.Position.Y, 1)
		local nearPos = game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(screenSpace.ScreenToWorld(touch.Position.X, touch.Position.Y, 1))
		nearPos = game.Workspace.CurrentCamera.CoordinateFrame.p - nearPos
		local farPos = screenSpace.ScreenToWorld(touch.Position.X, touch.Position.Y,50) 
		farPos = game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(farPos) * -1
		if farPos.magnitude > 900 then
			farPos = farPos.unit * 900
		end
		local ray = Ray.new(nearPos, farPos)
		local part, pos = game.Workspace:FindPartOnRay(ray, player.Character)
		
		-- if a position was found on the ray then update the character's rotation
		if pos then
			frame(pos)
		end
	end
end

local function OnActivated()
	local myModel = player.Character
	if Tool.Enabled and myModel and myModel:FindFirstChild('Humanoid') and myModel.Humanoid.Health > 0 then
		Tool.Enabled = false
		game.ReplicatedStorage.ROBLOX_RocketFireEvent:FireServer(mouse.Hit.p)
		wait(2)

		Tool.Enabled = true
	end
end

local oldIcon = nil
-- Function to bind to equip event
local function equip()
	local character = player.Character
	local humanoid = character.Humanoid
	
	-- Setup joint variables
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local torso = character.Torso
		neck = torso.Neck	
		shoulder = torso["Right Shoulder"]
		
	elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
		neck = character.Head.Neck
		shoulder = character.RightUpperArm.RightShoulder
	end
	
	oldNeckC0 = neck.C0
	oldShoulderC0 = shoulder.C0
	
	-- Remember old mouse icon and update current
	oldIcon = mouse.Icon
	mouse.Icon = "http://www.roblox.com/asset/?id=79658449"
	
	-- Bind TouchMoved event if on mobile. Otherwise connect to renderstepped
	if userInputService.TouchEnabled then
		connection = userInputService.TouchMoved:connect(mobileFrame)
	else
		connection = render:connect(pcFrame)
	end
	
	-- Bind TouchStarted and TouchEnded. Used to determine if character should rotate
	-- during touch input
	userInputService.TouchStarted:connect(function(touch, processed)
		mobileShouldTrack = not processed
	end)	
	userInputService.TouchEnded:connect(function(touch, processed)
		mobileShouldTrack = false
	end)

	-- If game uses filtering enabled then need to update server while tool is
	-- held by character.
	if workspace.FilteringEnabled then
		while connection and connection.Connected do
			wait()
			game.ReplicatedStorage.ROBLOX_RocketUpdateEvent:FireServer(neck.C0, shoulder.C0)
		end
	end
end

-- Function to bind to Unequip event
local function unequip()
	if connection then connection:disconnect() end
	
	mouse.Icon = oldIcon
	
	neck.C0 = oldNeckC0
	shoulder.C0 = oldShoulderC0
end

-- Bind tool events
Tool.Equipped:connect(equip)
Tool.Unequipped:connect(unequip)
Tool.Activated:connect(OnActivated)