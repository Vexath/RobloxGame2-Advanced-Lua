Running = false

UD = script.Parent.Parent.Data.UD
Motor = script.Parent.Motor

function Run()
	if (UD.Value == "U") or (UD.Value == "D") and Running == false then
		Running = true
		Motor.Start:Play()
		wait(3.8)
		Motor.Run:Play()
		repeat wait() until UD.Value == "US" or UD.Value == "DS"
		Motor.Run:Stop()
		Motor.Stop:Play()
		Running = false
	end
end
UD.Changed:connect(Run)