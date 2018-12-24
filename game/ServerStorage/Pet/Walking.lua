----------------------------------------

local Ghost = script.Parent
local Player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
local Character = Player.Character
local Humanoid = Character.Humanoid
local Alive = true
local Torso;
if Player.Character:FindFirstChild("Torso") then
	Torso = Player.Character.Torso
end

if Player.Character:FindFirstChild("UpperTorso") then
	Torso = Player.Character.UpperTorso
end

----------------------------------------
local Body = script.Parent.Body;

local torsoAt = Torso.Position local toGhost = Body.Position - torsoAt toGhost = Vector3.new(toGhost.x, 0, toGhost.z).unit
local ghostAt = torsoAt + toGhost*3 + Vector3.new(0, 2 + 1*math.sin(tick()), 0)
Body.CFrame = Torso.CFrame;

Instance.new("BodyPosition"){
	Name = 'Float';
	Parent = Body;
	position = Torso.Position + Vector3.new(1,1,1);
	--D = 500;
};
Instance.new('BodyGyro'){
	Name = 'Rotate';
	Parent = Body;
	cframe = Torso.CFrame;
	maxTorque = Vector3.new(40000, 20000, 40000);
};

wait(2);
--set up ghost following you
spawn(function()
	while Alive do
		local torsoAt = Torso.Position
		local toGhost = Body.Position - torsoAt
		toGhost = Vector3.new(toGhost.x, 0, toGhost.z).unit
		local ghostAt = torsoAt + toGhost*3 + Vector3.new(0, 2 + 1*math.sin(tick()), 0)
		
		local Under = CFrame.new(ghostAt):toWorldSpace(CFrame.new(Vector3.new(0,-1,0)));
		local Raycast = Ray.new(ghostAt, (Under.p-ghostAt).unit*100);
		local StandOn = game.Workspace:FindPartOnRay(Raycast,Character);
		if StandOn then
			print(StandOn);
			ghostAt = Vector3.new(ghostAt.X,StandOn.Position.Y+(StandOn.Size.Y/2)+(Body.Size.Y/2),ghostAt.Z);
		end;
		--
		Body.Float.position = ghostAt
		Body.Rotate.cframe = Torso.CFrame 
		wait()
		Body.Anchored = false;
		Body.CanCollide = false;
		Body:SetNetworkOwner(nil)
	end
end)


--and finally set up a veiw of our health