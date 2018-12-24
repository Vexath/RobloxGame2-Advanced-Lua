-- This is the good stuff

--[[
ScalingCharacter.new(Character base) Returns ScalingCharacter object

ScalingCharacter object
:Resize(Number scale)


That's all you need to know
--]]

local ScalingCharacter={}
-----
-----
function ScalingCharacter.new(char)
local this={
Scale=1,
Base=char,
Humanoid=nil,
HeadMesh=nil,
IsTiny=false,

Joints={},
Parts={},
JointsForPart={},
RegisteredMembers={},
CharacterMeshes={},
TinyMeshes={}
}
--
--
function this:UpdateConnectedJoints(part)
for index,joint in next,this.JointsForPart or {} do
this:UpdateJointScale(joint)
end
end
function this:UpdateJointScale(joint)
local original=this.Joints[joint]

joint.C0=CFrame.new(original.C0.p*this.Scale)*CFrame.Angles(original.C0:toEulerAnglesXYZ())
joint.C1=CFrame.new(original.C1.p*this.Scale)*CFrame.Angles(original.C1:toEulerAnglesXYZ())
joint.Part0=original.Part0
joint.Part1=original.Part1
joint.Parent=original.Parent
end
function this:UpdatePartScale(part)
local original=this.Parts[part]

part.Size=original.Size*this.Scale
-- Update mesh
if original.Mesh ~= nil then
if (this.Scale > 0.2) or (part.Parent ~= this.Base) then
local doResize=true
if original.Mesh:IsA 'SpecialMesh' and original.Mesh.MeshType.Name == 'Head' then
doResize=false
original.Mesh.Scale=Vector3.new(1,1,1) * 1.25
end
if doResize then
original.Mesh.Scale=original.MeshScale*this.Scale
end
else
local scaleMultiplier=1*(this.Scale*1/0.2)
original.Mesh.Scale=(Vector3.new(1,1,1)*0.2/part.Size)*original.MeshScale*scaleMultiplier*original.Size
end
end
end
function this:EvaluateCharacterMember(member)
if not this.RegisteredMembers[member] then
if member ~= this.Base then
if member:IsA 'JointInstance' then
while not member.Part0 or not member.Part1 do wait() end

this.Joints[member]={
C0=member.C0,
C1=member.C1,
Part0=member.Part0,
Part1=member.Part1,
Parent=member.Parent
}

this.JointsForPart[member.Part0]=this.JointsForPart[member.Part0] or {}
table.insert(this.JointsForPart[member.Part0],member)
this.JointsForPart[member.Part1]=this.JointsForPart[member.Part1] or {}
table.insert(this.JointsForPart[member.Part1],member)

-- hat fix
local handle=member.Part1
local hat=handle.Parent
if hat:IsA 'Accoutrement' then
spawn(function()
local bin=Instance.new 'Frame'
bin.Name=hat.Name
bin.Parent=this.Base
handle.Parent=bin
hat.Parent=nil

member.Parent=handle
member.Part0=this.Base:FindFirstChild 'Head'
member.Part1=handle
end)
end
elseif member:IsA 'Tool' then
	--[[if not member:FindFirstChild("FixWeld") then
		script.FixWeld:Clone().Parent = member;
		member.FixWeld.Disabled = false;
	end]]
	--[[local Handle = member.Handle;
	local Size = Handle.Size;
	local X,Y,Z = Size.X,Size.Y,Size.Z;	
	
	local Table = {
		{"X",X};
		{"Y",Y};
		{"Z",Z};
	};
	--  returns true when the first is less than the second
	table.sort(Table,function(a,b)
		-- a < b == true
		return (a[2] > b[2]);
	end)
	
	local KY = Table[1][1];
	local KZ = Table[2][1];
	local KX = Table[3][1];
	
	local NewPos = {
		X = 0;
		Y = 0;
		Z = 0;
	};
	
	NewPos[KY] = -0.75;
	NewPos[KZ] = 0.75;
	NewPos[KX] = 0;
	
	member.GripPos = Vector3.new(		member.GripPos.X + NewPos.X,		member.GripPos.Y + NewPos.Y,		member.GripPos.Z + NewPos.Z);
	]]
	
	
elseif member:IsA 'BasePart' then
this.Parts[member]={
Size=member.Size,
Mesh=nil,
MeshScale=Vector3.new()
}
elseif member:IsA 'DataModelMesh' then
local parentData=this.Parts[member.Parent]
if parentData ~= nil then
parentData.Mesh=member
parentData.MeshScale=member.Scale
end
end
end
--
member.ChildAdded:connect(function(child)
this:EvaluateCharacterMember(child)
end)
for index,child in next,member:GetChildren() do
this:EvaluateCharacterMember(child)
end
--
this.RegisteredMembers[member]=true
end
end
function this:Initialize()
this:EvaluateCharacterMember(this.Base)
this.Humanoid=this.Base:WaitForChild'Humanoid'
end
--
--
function this:Resize(newScale)
--
-- Reflect
this.Scale=newScale

--
-- Change sizes
for part,original in next,this.Parts do
part.FormFactor='Custom'
this:UpdatePartScale(part)
end

--
-- Change welds
for joint,original in next,this.Joints do
this:UpdateJointScale(joint)
end

--
-- Update humanoids
this.Humanoid.CameraOffset=Vector3.new(0,1.5,0)*newScale-Vector3.new(0,1.5,0)

--
-- Try to bump
local center=this.Base:FindFirstChild 'HumanoidRootPart'
local leg=this.Base:FindFirstChild 'Left Leg'
if center and leg then
local height=leg.Size.y+center.Size.y/2
local hit,pos=workspace:FindPartOnRayWithIgnoreList(
	Ray.new(
	center.Position,
	Vector3.new(0,-1,0)*999
),
{this.Base,workspace.CurrentCamera}
)

center.CFrame=CFrame.new(center.CFrame.x,pos.y+height,center.CFrame.z) * CFrame.Angles(center.CFrame:toEulerAnglesXYZ())
end

--
-- Make sure it's not broke
this.Base:MakeJoints()
end
--
--
this:Initialize()
--
--
return this
end
-----
-----
return ScalingCharacter