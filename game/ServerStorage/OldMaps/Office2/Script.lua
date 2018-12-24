a = script.Parent.Spawns:GetChildren()
for i = 1,#a do
	if a[i]:IsA("BasePart") then
		a[i].Transparency = 1
	end
end