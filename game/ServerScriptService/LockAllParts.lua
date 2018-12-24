local scan;

scan = function(par)
	for i,v in ipairs(par:GetChildren()) do
		if v:IsA("BasePart") then
			v.Locked = true;
		else
			scan(v);
		end
	end
end

workspace.DescendantAdded:connect(function(desc)
	if desc and desc:IsA("BasePart") then
		desc.Locked = true;
	end
end);

scan(workspace);