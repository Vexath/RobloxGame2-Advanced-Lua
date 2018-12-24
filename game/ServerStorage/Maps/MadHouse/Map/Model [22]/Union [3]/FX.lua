local X 		
local Y 		
local Z 		
X= 4
Y= 0
Z= 0
function start() 
	while (true) do 
		script.Parent.CFrame = script.Parent.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(X),math.rad(Y),math.rad(Z)) 
		wait() 		
	end 														
end 													
start() 
