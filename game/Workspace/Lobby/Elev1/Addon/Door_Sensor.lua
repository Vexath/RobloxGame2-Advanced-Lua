--Door Sensor Light
--Local Setting(Do not touch)
SP = script.Parent.Parent
Data = SP.Data
Floor = Data.Floor
Motor = Data.Motor
Car   = SP.Car
Door   = Data.Door
Direction = Data.Direction
TCarG = Car:GetChildren()
Floors = SP.Floors
TFloorsG = Floors:GetChildren()
TotalFloors = 0

--Door Sensor

DoorLeft = Car.DL
DoorRight = Car.DR
DoorLeftG = DoorLeft:GetChildren()
DoorRightG = DoorRight:GetChildren()

Door.Changed:connect(function()
if Door.Value == "Opening" or Door.Value == "Open" or Door.Value == "ReOpen" then
for _,l in pairs(DoorLeftG) do if l.Name == "SENSORLED" then l.BrickColor = BrickColor.new("Lime green") end end
for _,l in pairs(DoorRightG) do if l.Name == "SENSORLED" then l.BrickColor = BrickColor.new("Lime green") end end
for _,l in pairs(DoorLeftG) do if l.Name == "SENSORLED" then l.Material = "Neon" end end
for _,l in pairs(DoorRightG) do if l.Name == "SENSORLED" then l.Material = "Neon" end end
else
for _,l in pairs(DoorLeftG) do if l.Name == "SENSORLED" then l.BrickColor = BrickColor.new("Really red") end end
for _,l in pairs(DoorRightG) do if l.Name == "SENSORLED" then l.BrickColor = BrickColor.new("Really red") end end
for _,l in pairs(DoorLeftG) do if l.Name == "SENSORLED" then l.Material = "Neon" end end
for _,l in pairs(DoorRightG) do if l.Name == "SENSORLED" then l.Material = "Neon" end end
return end
end)

