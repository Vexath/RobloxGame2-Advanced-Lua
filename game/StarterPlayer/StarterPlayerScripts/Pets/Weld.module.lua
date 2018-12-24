
return function(Body)
	local function weldBetween(a, b)
	    --Make a new Weld and Parent it to a.
	    local weld = Instance.new("ManualWeld", a)
	    weld.C0 = a.CFrame:inverse() * b.CFrame
	    weld.Part0 = a
	    weld.Part1 = b
		a.Anchored = false;
		b.Anchored = false;
		a.CanCollide = false;
		b.CanCollide = false;
	    return weld
	end
	for _,Part in pairs(Body:GetChildren()) do
		if Part:IsA("BasePart") then weldBetween(Part,Body); end;
		if Part:IsA("Model") then
			for _,Part in pairs(Body:GetChildren()) do
				if Part:IsA("BasePart") then
					 weldBetween(Part,Body); 
				end;
			end
		end
	end
end;

