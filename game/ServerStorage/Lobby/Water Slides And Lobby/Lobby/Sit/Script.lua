enabled = true
function onTouched(hit)
	if not enabled then return end
	enabled = false 
	local h = hit.Parent:findFirstChild("Humanoid")
	if (h ~= nil) then
		h.Sit = true
	end
	enabled = true 
end 
script.Parent.Touched:connect(onTouched) 