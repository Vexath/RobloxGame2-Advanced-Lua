script.Parent.MaxSpeed = 500 
maxspeed  =script.Parent.MaxSpeed
script.Parent.BodyPosition.position = script.Parent.Position--------------------DO NOT CHANGE ANYTHING!
script.Parent.BodyGyro.cframe = script.Parent.CFrame
value1 = 0
while true do
wait()
if script.Parent.Throttle== 1 then
if value1 < maxspeed then value1 = value1+1 end
script.Parent.Parent.Driving.Value = true
script.Parent.BodyVelocity.velocity = script.Parent.CFrame.lookVector*value1
script.Parent.Parent.Left.Value = false
script.Parent.Parent.Right.Value = false
end
if script.Parent.Throttle == 0 then 
value1 = 0
script.Parent.Parent.Driving.Value = false
script.Parent.BodyVelocity.velocity = script.Parent.CFrame.lookVector*value1
script.Parent.Parent.Left.Value = false
script.Parent.Parent.Right.Value = false
end
if script.Parent.Throttle== -1 then
if value1< maxspeed then value1 = value1+1 end
script.Parent.Parent.Driving.Value = true
script.Parent.BodyVelocity.velocity = script.Parent.CFrame.lookVector*-value1
script.Parent.Parent.Left.Value = false
script.Parent.Parent.Right.Value = false
end
if script.Parent.Steer == 1 then
script.Parent.BodyGyro.cframe = script.Parent.BodyGyro.cframe * CFrame.fromEulerAnglesXYZ(0,-.05,0)
script.Parent.Parent.Driving.Value = true
script.Parent.Parent.Right.Value = true
script.Parent.Parent.Left.Value = false
end
if script.Parent.Steer == -1 then
script.Parent.BodyGyro.cframe = script.Parent.BodyGyro.cframe * CFrame.fromEulerAnglesXYZ(0,.05,0)
script.Parent.Parent.Driving.Value = true
script.Parent.Parent.Left.Value = true
script.Parent.Parent.Right.Value = false
end
end
----the plate boat script is by ok3y11