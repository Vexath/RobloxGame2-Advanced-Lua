--Door Sound
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

--Plugin(Paste here)

--Door Open and Close Sound
Door.Changed:connect(function()
if Door.Value == "Opening" then
Car.Platform.DO:Play()	
return end
if Door.Value == "Closing" then
Car.Platform.DC:Play()
return end
end)