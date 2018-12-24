local WeldHat = function(Hat,Character)
	local Weld = Instance.new("Weld");
	Hat.Handle.Size = Vector3.new(0.34,0.32,0.3);
	Weld.Part0 = Character.Head;
	Weld.Part1 = Hat.Handle:Clone();
	Weld.C0 = CFrame.new(0,0.5,0);
	Weld.C1 = Hat.AttachmentPoint;
	Weld.Parent = Weld.Part0;
	Weld.Part1.Parent = Character;
	Hat:Destroy();
end

return WeldHat;
