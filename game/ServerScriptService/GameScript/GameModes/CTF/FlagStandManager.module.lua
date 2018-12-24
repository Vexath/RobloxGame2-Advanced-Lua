local FlagStandManager = {}

-- ROBLOX Services
local Players = game.Players

-- Game Services
local Configurations = require(script.Parent.Configurations)

-- Local Variables
local FlagObjects = {}
local FlagCarriers = {}
local Events = game.ReplicatedStorage.Events
local CaptureFlag = Events.CaptureFlag
local ReturnFlag = Events.ReturnFlag
local DropFlagEvent = game.ReplicatedStorage.Events.DropFlag

-- Local Functions
local MakeFlag

local function DestroyFlag(flagObject)
	flagObject.Flag:Destroy()
	for player, object in pairs(FlagCarriers) do
		if object == flagObject then
			FlagCarriers[player] = nil
		end
	end
end

local function OnCarrierDied(player)
	local flagObject = FlagCarriers[player]
	if flagObject then
		local flagPole = flagObject.FlagPole
		local flagBanner = flagObject.FlagBanner
		
		flagPole.CanCollide = false
		flagBanner.CanCollide = false
		flagPole.Anchored = true
		flagBanner.Anchored = true
		
		flagObject.PickedUp = false		
		
		FlagCarriers[player] = nil
		
		if Configurations.RETURN_FLAG_ON_DROP then
			wait(Configurations.FLAG_RESPAWN_TIME)
			if not flagObject.AtSpawn and not flagObject.PickedUp then
				DestroyFlag(flagObject)
				MakeFlag(flagObject)
				ReturnFlag:Fire(flagObject.FlagBanner.BrickColor)
			end
		end
	end
end

DropFlagEvent.Event:connect(OnCarrierDied)


local function PickupFlag(player, flagObject)
	FlagCarriers[player] = flagObject
	flagObject.AtSpawn = false
	flagObject.PickedUp = true
	
	local torso
	if player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		torso = player.Character:FindFirstChild('Torso')
	else
		torso = player.Character:FindFirstChild('UpperTorso')
	end
	local flagPole = flagObject.FlagPole
	local flagBanner = flagObject.FlagBanner
	
	flagPole.Anchored = false
	flagBanner.Anchored = false
	flagPole.CanCollide = false
	flagBanner.CanCollide = false
	local weld = Instance.new('Weld', flagPole)
	weld.Name = 'PlayerFlagWeld'
	weld.Part0 = flagPole
	weld.Part1 = torso
	weld.C0 = CFrame.new(0,0,-1)
end

local function BindFlagTouched(flagObject)
	local flagPole = flagObject.FlagPole
	local flagBanner = flagObject.FlagBanner
	flagPole.Touched:connect(function(otherPart)
		local player = Players:GetPlayerFromCharacter(otherPart.Parent)
		if not player then return end
		if not player.Character then return end
		local humanoid = player.Character:FindFirstChild('Humanoid')
		if not humanoid then return end
		if humanoid.Health <= 0 then return end
		if flagBanner.BrickColor ~= player.TeamColor and not flagObject.PickedUp then
			PickupFlag(player, flagObject)
		elseif flagBanner.BrickColor == player.TeamColor and not flagObject.AtSpawn and Configurations.FLAG_RETURN_ON_TOUCH then
			DestroyFlag(flagObject)
			MakeFlag(flagObject)
			ReturnFlag:Fire(flagObject.FlagBanner.BrickColor)
		end
	end)
end

function MakeFlag(flagObject)
	flagObject.Flag = flagObject.FlagCopy:Clone()
	flagObject.Flag.Parent = flagObject.FlagContainer
	flagObject.FlagPole = flagObject.Flag.FlagPole
	flagObject.FlagBanner = flagObject.Flag.FlagBanner
	flagObject.FlagBanner.CanCollide = false
	flagObject.AtSpawn = true
	flagObject.PickedUp = false
	BindFlagTouched(flagObject)
end

local function BindBaseTouched(flagObject)
	local flagBase = flagObject.FlagBase
	flagBase.Touched:connect(function(otherPart)
		local player = Players:GetPlayerFromCharacter(otherPart.Parent)
		if not player then return end
		if flagBase.BrickColor == player.TeamColor and FlagCarriers[player] then
			CaptureFlag:Fire(player)
			local otherFlag = FlagCarriers[player]
			DestroyFlag(otherFlag)
			MakeFlag(otherFlag)
		end
	end)
end

local function OnPlayerAdded(player)
	player.CharacterAdded:connect(function(character)
		character:WaitForChild('Humanoid').Died:connect(function() OnCarrierDied(player) end)
	end)
	player.CharacterRemoving:connect(function()
		OnCarrierDied(player)
	end)
end

-- Public Functions
function FlagStandManager:Init(container)
	local flagObject = {}
	
	local success, message = pcall(function()
		flagObject.AtSpawn = true	
		flagObject.PickedUp = false
		flagObject.TeamColor = container.FlagStand.BrickColor
		flagObject.Flag = container.Flag
		flagObject.FlagPole = container.Flag.FlagPole
		flagObject.FlagBanner = container.Flag.FlagBanner
		flagObject.FlagBase = container.FlagStand
		flagObject.FlagCopy = container.Flag:Clone()	
		flagObject.FlagContainer = container
	end)
	if not success then
		warn("Flag object not built correctly. Please load fresh template to see how flag stand is expected to be made.")
	end
	
	BindBaseTouched(flagObject)
	DestroyFlag(flagObject)
	MakeFlag(flagObject)
	
	table.insert(FlagObjects, flagObject)
end

-- Event Bindings

return FlagStandManager
