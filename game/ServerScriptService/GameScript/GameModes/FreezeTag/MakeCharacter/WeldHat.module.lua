local WeldHat = function(Hat,Character,HatLink)
	local Weld = Instance.new("Weld");
	Weld.Part0 = Character.Head;
	Weld.Part1 = Hat.Handle:Clone();
	Weld.C0 = CFrame.new(0,0.5,0);
	Weld.C1 = Hat.AttachmentPoint;
	Weld.Parent = Weld.Part0;
	Weld.Part1.Name = Hat.Name;
	Weld.Part1.Parent = Character;
	local ObjV = Instance.new("ObjectValue");
	ObjV.Value = HatLink;
	ObjV.Name = "WeldedHat";
	ObjV.Parent = Character;
	Weld.Part1.CanCollide = false;
	Hat:Destroy();
end

return WeldHat;
