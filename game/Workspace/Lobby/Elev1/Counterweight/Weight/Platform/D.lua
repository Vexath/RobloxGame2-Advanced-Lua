
while true do
wait()
script.Parent.BodyVelocity.Velocity = Vector3.new(0,-script.Parent.Parent.Parent.Car.Platform.Velocity.Magnitude/1,0)
end