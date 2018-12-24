--K.W. PGS V0.1 by bensonlam961--
--Alpha v0.A1

-- Getting Data (Do not touch) --
 Data = script.Parent.Data
 TCar = script.Parent.Car
 TFloors = script.Parent.Floors
 Floor = Data.Floor
 Motor = Data.Motor
 Direction = Data.Direction
 UD = Data.UD
 Door = Data.Door

-- <| DOOR ENGINE |>--

 DoorState = "Open"
 DoorSpeed = 0
 DoorL = 39
 DoorC = 0.05
 DoorP = 40
 DoorLeft = TCar.DL
 DoorRight = TCar.DR
 DoorLeftG = DoorLeft:GetChildren()
 DoorRightG = DoorRight:GetChildren()
 ResetDoorTimer = false


 Nudge = true
 WaitForNudge = false
 ResetNudgeTimer = false
 ResetDoorTimer = false
-- <| END DOOR ENG |> --

 FireLock = false
 Alarm = false
 Moving = false
 Busy = false
 Locked = false
 Fire = false
 Light = true
 Stop = false
 MotorStartSpeed = 0.01 --/ Start Speed
 MotorStopSpeed = 0.01 --/ Stop Speed
 MotorSpeed = 0.2 --/ CFrame speed (0.*, * = speed)
 MoveDirection = "None" --/ Direction
 LevelOffset = 3 --/ Level offset
 TargetFloor = 0 --/ Not in use
 TotalFloors = 0 --/ DO NOT TOUCH
 CallQuene = {}
 DCalls = {}

-- Values that can be changed --
 ConfigMode = false
 OpenWhenIdle = false
 Chime = true -- Not working yet
 FloorPassChime = true -- Worked on
 ClassicLevel = false --  Open when leveling /otis
 CardLock = false -- Enable or disable the Card Lock reader
 DoorSensors = true -- In developement, Buggy, Enable if you are sure
 DoorSensorHold = true -- Hold the door when someone stands beetween doors
 CardNumber = {0} -- Which cards that can Unlock the floors
 LockedFloors = {} -- Wich floors to be locked
 LightLock = {"Player1"}

 CarCF = {}


 MoveTimeout = 15
 MoveTime = 0
 MoveFloor = 1
 MoveErrors = 0
 MoveDB = false

-- Config Setting --
 CarButtonLit = script.Parent.Configuration.CarButton.BTFL.Value
 CarButtonUnlit = script.Parent.Configuration.CarButton.BTFUL.Value

-- Get Car for CFrame engine --

 TCarG = TCar:GetChildren()
 TFloorsG = TFloors:GetChildren()

-- Combine it into one array --
for i1=1,#TCarG do
	table.insert(CarCF,TCarG[i1])
end
-- End Get CBI --
for i4=1,#TFloorsG do
	TotalFloors = TotalFloors + 1
end

 BtnULit = "http://www.roblox.com/asset/?id=158427251"
 BtnLit =  "http://www.roblox.com/asset/?id=158427260"

 IndDirUp = "http://www.roblox.com/asset/?id=66704336"
 IndDirDown = "http://www.roblox.com/asset/?id=66704345"
 IndDirULit = "http://www.roblox.com/asset/?id=66704228"

 DirIndLit = "http://www.roblox.com/asset/?id=37847931"
 DirIndLit2 = "http://www.roblox.com/asset/?id=64659409"
 DirIndULit = "http://www.roblox.com/asset/?id=37848161"


function DecodeData(String)
	local Data = String
	local Values = {} 
	while Data:find("#") do 
		local TempData,_ = Data:find("#") 
		table.insert(Values,Data:sub(1,TempData-1)) 
		Data = Data:sub(TempData+1) 
	end 
	table.insert(Values,Data) 
	return Values 
end

-- DESTINATION DISPATCH --

Motor.Changed:connect(function()
	if not MoveDB then
	 MoveDB = true
		repeat 
			wait(1)
			if Floor.Value ~= MoveFloor then
				MoveFloor = Floor.Value
				MoveTime = 0
			else
				MoveTime = MoveTime + 1
			end
			print("Error Checker: "..MoveTime)
		until not Moving or MoveTime == MoveTimeout or Stop == true
		if Stop == true then MoveDB = false return end
		if MoveTime ~= MoveTimeout then MoveTime = 0 MoveDB = false print("Succeeded to arrive at floor!") end
		if MoveErrors == 3 then 
			coroutine.resume(coroutine.create(function() Stop(Floor.Value, true) end)) 
			script.Parent["Floor Indicator OUTSIDE"].Disabled = true
			script.Parent["Floor Indicator"].Disabled = true
			TCar.Screen.SurfaceGui.Frame.Indicator.Text = "X"
			script.Parent.Floors.Floor1.FloorIndicator.SurfaceGui.Frame.Indicator.Text = "X"
			script.Parent.Data.Disabled.Value = true
			TCar.BTDIS.Texture.Texture = BtnLit
			MoveTime = 0 
 			MoveDB = false
			return
		end
		if MoveTime == MoveTimeout then 
			MoveErrors = MoveErrors + 1 
 			MoveTime = 0 
 			MoveDB = false
			coroutine.resume(coroutine.create(function() Stop(Floor.Value, true) end)) 
		end
	end

end)

script.Parent.Data.DestCall.Changed:connect(function()
	if script.Parent.Data.DestCall.Value ~= "READY" then	
		local CallData = DecodeData(script.Parent.Data.DestCall.Value)
		table.insert(DCalls,CallData[1])
		Quene(tonumber(CallData[1]),"Add","Call")
		if not Moving and Floor.Value == tonumber(CallData[1]) then
			Quene(tonumber(CallData[2]),"Add","Call") -- let's call this after Quene
		end		
	end
	script.Parent.Data.DestCall.Value = "READY"
end)


function ProcessCall(xFloor, xDest)
	if TargetFloor == 0 and xFloor ~= xDest then
		if xDest > xFloor then
			script.Parent.Data.TFloor.Value = xDest
			Start("Up")
		end
		if xDest < xFloor then
			script.Parent.Data.TFloor.Value = xDest
			Start("Down")	
		end	
	end
end


function Start(xDirection)
Busy = true

if DoorState ~= "Closed" then
repeat
wait()
until DoorState == "Closed" and DoorState ~= "Open"
end
Moving = true
wait(0.5)
	if xDirection == "Up" then
		Direction.Value = "U"
		UD.Value = "U"
		MoveDirection = "Up"
		local CallDirection = "Up"
		Motor.Value = 0.000001
		script.StartMotor.Value = true
		for i = 0, MotorSpeed, 0.02 do
			Motor.Value = i
			wait(MotorStartSpeed)
		end
	end
	if xDirection == "Down" then
		Direction.Value = "D"
		UD.Value = "D"
		MoveDirection = "Down"
		local CallDirection = "Down"
		Motor.Value = -0.000001
		script.StartMotor.Value = true
		for i = 0, MotorSpeed, 0.02 do
			Motor.Value = -i
			wait(MotorStartSpeed)
		end
	end
coroutine.resume(coroutine.create(function()
	while Motor.Value ~= 0 do
	wait()	

	for i = 1, #TFloorsG do
		local xx = tonumber(TFloorsG[i].Name:sub(6,8))
		if math.abs(TFloorsG[i].Level.Position.Y - TCar.Platform.Position.Y) < LevelOffset then
		if Floor.Value ~= xx then
			Floor.Value = xx
			Stop(xx) -- InCase f stops
		end
		end	
		
	end
	end
end))
	

end
	
function Stop(TF)
local HaveAStop = false
for i=1, #CallQuene do
	if CallQuene[i] == TF then 
		HaveAStop = true 
	end
end
--if TargetFloor ~= TF then return end
if HaveAStop then
coroutine.resume(coroutine.create(function()

script.Parent.Data.HallCall.Value = 0
if Floor.Value == TotalFloors then
Direction.Value = "D"
UD.Value = "D"
end
if Floor.Value == 1 then
Direction.Value = "U"
UD.Value = "U"
end

script.DoChime.Value = true
SetFloorDirInd(1)			
Btn(TF,0)

end))
	if MoveDirection == "Up" then
		for i = MotorSpeed, 0.01, -0.02 do
			Motor.Value = i
			wait(MotorStopSpeed)
		end
	end
	if MoveDirection == "Down" then
		for i = MotorSpeed, 0.01, -0.02 do
			Motor.Value = -i
			wait(MotorStopSpeed)
		end
	end
Quene(TF,"Remove")
if ClassicLevel then
script.DoOpen.Value = true
end
repeat
	local EngineAPI
	if EngineAPI == "C" then			
		for i,l in pairs(TCar.Welds:GetChildren()) do
			l.Part1.CFrame = l.Part1.CFrame + Vector3.new(0, 0, 0)
		end
	end
wait()
until math.abs(TFloors:FindFirstChild("Floor"..TF).Level.Position.Y - TCar.Platform.Position.Y) < 0.01
if Floor.Value == TotalFloors then
	MoveDirection = "Down"
end
if Floor.Value == 1 then
	MoveDirection = "Up"
end
Motor.Value = 0

TargetFloor = 0
script.Parent.Data.TargetFloor.Value = 0

if not ClassicLevel then
script.DoOpen.Value = true
end
Moving = false
--DoorOpen(TF)
print("Waiting 5 before Reset")
Busy = false
wait(5)
Quene(0,"Check")
end
end








function DoorRun()
	if script.DoOpen.Value == true then
		script.DoOpen.Value = false
		DoorOpen(Floor.Value)
	end
	if script.DoClose.Value == true then
		script.DoClose.Value = false
		DoorClose(Floor.Value)
	end
	if script.ReOpen.Value == true then
		script.ReOpen.Value = false
		if DoorState == "Closing" then
		DoorOpen(Floor.Value,true)
		end
	end
end



function DoorOpen(F,ReOpen)
	if ReOpen and DoorState == "Closing" then
		DoorState = "ReOpen" 
		Door.Value = "ReOpen" 
	end
	if DoorState == "Closed" or DoorState == "ReOpen" then
		if not ReOpen then 
		DoorState = "Opening" 
		Door.Value = "Opening" 
		end
		if not Moving then script.DoChime.Value = true end
		SetFloorDirInd(1)
		SetCarDirInd(1)
		local DoorFloorLeft = TFloors:FindFirstChild("Floor"..Floor.Value):FindFirstChild("DL"):GetChildren()
		local DoorFloorRight = TFloors:FindFirstChild("Floor"..Floor.Value):FindFirstChild("DR"):GetChildren()
		
		if EngineAPI == "B" then

		end
		for i=DoorP, DoorL do
			DoorP = DoorP + 1
			
				for FR=1, #DoorFloorRight do				
				DoorFloorRight[FR].CFrame = DoorFloorRight[FR].CFrame * CFrame.new(0, 0, DoorC)
				end
				
				for FL=1, #DoorFloorLeft do				
				DoorFloorLeft[FL].CFrame = DoorFloorLeft[FL].CFrame * CFrame.new(0, 0,-DoorC)
				end
				
				for R=1, #DoorRightG do				
				DoorRightG[R].CFrame = DoorRightG[R].CFrame * CFrame.new(0, 0, DoorC)
				end
				
				for L=1, #DoorLeftG do				
				DoorLeftG[L].CFrame = DoorLeftG[L].CFrame * CFrame.new(0, 0, -DoorC)
				end
				
			wait(DoorSpeed)
		end
		DoorState = "Open"
		Door.Value = "Open" 
		coroutine.resume(coroutine.create(function() DoorTimer() end))
	end
end
function DoorClose(F)
	if DoorState == "Open" then
		DoorState = "Closing"
		Door.Value = "Closing"
		local DoorFloorLeft = TFloors:FindFirstChild("Floor"..Floor.Value):FindFirstChild("DL"):GetChildren()
		local DoorFloorRight = TFloors:FindFirstChild("Floor"..Floor.Value):FindFirstChild("DR"):GetChildren()
		for i=0, DoorL do
			if DoorState == "ReOpen" then return end
			DoorP = DoorP - 1
			
				for FR=1, #DoorFloorRight do				
				DoorFloorRight[FR].CFrame = DoorFloorRight[FR].CFrame * CFrame.new(0, 0, -DoorC)
				end
				
				for FL=1, #DoorFloorLeft do				
				DoorFloorLeft[FL].CFrame = DoorFloorLeft[FL].CFrame * CFrame.new(0, 0,DoorC)
				end
				
				for R=1, #DoorRightG do				
				DoorRightG[R].CFrame = DoorRightG[R].CFrame * CFrame.new(0, 0, -DoorC)
				end
				
				for L=1, #DoorLeftG do				
				DoorLeftG[L].CFrame = DoorLeftG[L].CFrame * CFrame.new(0, 0, DoorC)
				end
				
			wait(DoorSpeed)
		end
		DoorState = "Closed"
		Door.Value = "Closed"
		SetCarDirInd(0)
		SetFloorDirInd(0)
		Quene("Check",0)
	end
end

function DoorTimer()
	ResetDoorTimer = true
	wait(0.2)
	ResetDoorTimer = false
	for i=0,10 do
		if ResetDoorTimer then return end
		wait(0.5)
	end
	if ResetDoorTimer  then return end
	if DoorState == "Open" then DoorClose(Floor.Value) end
end


if DoorSensors then
TCar.DoorSensor.Touched:connect(function (Player)
if Player == nil then return end
if Player.Parent == nil then return end
if Player.Parent:FindFirstChild("Humanoid") then
script.ReOpen.Value = true
end
end)
end

local Chime = TCar.Platform.Chime
function SetCarDirInd(F)
	if F == 1 then
		if UD.Value == "U" or UD.Value == "US" then
		UD.Value = "US"
		elseif UD.Value == "D" or UD.Value == "DS" then	
		UD.Value = "DS"
		elseif Floor.Value == TotalFloors then
		UD.Value = "DS"
		elseif Floor.Value == 1 then
		UD.Value = "US"
		else
		UD.Value = "X"
		end
	end
	if F == 0 then 
		UD.Value = "N"
	end
end


function SetFloorDirInd(F)
	if F == 1 then
		if Direction.Value == "U" or Floor.Value == 1 then
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRUP" then l.BrickColor = BrickColor.new("Lime green") end end
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRUP" then l.Material = "Neon" end end
		end
		if Direction.Value == "D" or Floor.Value == TotalFloors then
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRDN" then l.BrickColor = BrickColor.new("Lime green") end end
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRDN" then l.Material = "Neon" end end
		end
	end
	if F == 0 then 
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRUP" then l.BrickColor = BrickColor.new("Institutional white") end end
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRUP" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRDN" then l.BrickColor = BrickColor.new("Institutional white") end end
		for _,l in pairs(TFloors:FindFirstChild("Floor"..Floor.Value):GetChildren()) do if l.Name == "DIRDN" then l.Material = "SmoothPlastic" end end
	end
end





function Btn(xFloor,xMode,Type)

	local xCar = TCar:FindFirstChild("BTF"..xFloor)
	local xCall = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButton")
	local xCallUp = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButtonUp")
	local xCallDn = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButtonDn")
	local xCall2 = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButton2")
	local xCallUp2 = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButtonUp2")
	local xCallDn2 = TFloors:FindFirstChild("Floor"..xFloor):FindFirstChild("CallButtonDn2")

	if xMode == 1 then
		if xCar ~= nil and Type == "Car" then
		xCar.Called.Value = true
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCall ~= nil and Type == "Call"  then
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCallUp ~= nil and Type == "Call"  then
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCallDn ~= nil and Type == "Call"  then
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCall2 ~= nil and Type == "Call"  then
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCallUp2 ~= nil and Type == "Call"  then
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end
		if xCallDn2 ~= nil and Type == "Call"  then
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
		end

	end
	if xMode == 0 then
		if xCar ~= nil then
		xCar.Called.Value = false
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCar:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCall ~= nil then
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCall:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCallUp ~= nil then
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCallUp:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCallDn ~= nil then
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCallDn:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCall2 ~= nil then
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCall2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCallUp2 ~= nil then
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCallUp2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end
		if xCallDn2 ~= nil then
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
		for _,l in pairs(xCallDn2:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
		end

	end
 
end

function DirInd(xFloor,xDir)
end
		

function Quene(xFloor,Mode,isCall)

	if Mode == "Check" then
		for i = 1, #CallQuene do
			if CallQuene[i] ~= nil then
				ProcessCall(Floor.Value, CallQuene[i])
			end
		end
	end
	if Mode == "Add" then
	
if Fire then return end
		Btn(xFloor,1,isCall)
		local IgnoreCall = false
		local IsCalled = false
		
		if isCall == "Car" then
		if CardLock then
		for i = 1, #LockedFloors do
			if LockedFloors[i] == xFloor then
				print("Floor Locked...")
					IgnoreCall = true
			end	
		end
		end
		end
		
		
		for i = 1, #CallQuene do
			if CallQuene[i] == xFloor then
				print("Call exist, Not adding floor: "..CallQuene[i])
				IgnoreCall = true
				IsCalled = true
			end		
		end

		
	
		if xFloor == Floor.Value and not Busy and not Moving then	
			script.DoOpen.Value = true
			wait(0.2)
			Btn(xFloor,0)
		end	
		if not IgnoreCall and xFloor ~= Floor.Value and not Locked or not IgnoreCall and xFloor ~= Floor.Value and xFloor == 1  then
			table.insert(CallQuene,xFloor)
			print("Floor added, Value: "..xFloor)
			Btn(xFloor,1,isCall)		
			if not Busy then Quene(0,"Check") end
		else
			if xFloor == Floor.Value and not Locked or IgnoreCall and IsCalled == false then
			wait(0.2)
			Btn(xFloor,0)
			end
			if Locked then
			wait(0.2)
			Btn(xFloor,0)
			end
		end
		
	end
	
	if Mode == "Remove" then
			for i = 1, #CallQuene do
				if CallQuene[i] == xFloor then
				print("Removed: "..CallQuene[i])
					table.remove(CallQuene,i)
				end
			end
			Btn(xFloor,"Off")
	end
end



-- Start New stuff --
x = script.Parent.Floors:GetChildren()
cs = TCar:GetChildren()
		


for i = 1, #TCarG  do

	if TCarG[i].Name:sub(1,3) == "BTF" then
	TCarG[i].Button.ClickDetector.MouseClick:connect(function() TCar.Platform.Beep:Play() end)
	end

	if TCarG[i].Name:sub(1,4) == "BTDO" then
	local BO = false
	TCarG[i].Button.ClickDetector.MouseClick:connect(function() 
	if not BO then 
	Bo = true
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
	if not Moving and not IsClosing then script.DoOpen.Value = true 
	elseif Open and IsClosing and not Closed then script.ReOpen.Value = true end 
	wait(0.2)
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
	for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
	Bo = false
	end
	end)
		
	end
	if TCarG[i].Name:sub(1,4) == "BTDC" then
	local BC = false
	TCarG[i].Button.ClickDetector.MouseClick:connect(function() 
		if not BC then 
			BC = true
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonLit) end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.Material = "Neon" end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonLit end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonLit end end
			script.DoClose.Value = true
			wait(0.2)
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.BrickColor = BrickColor.new(CarButtonUnlit) end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LED" then l.Material = "SmoothPlastic" end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "TextHalo" then l.SurfaceGui.TextLabel.TextColor3 = CarButtonUnlit end end
			for _,l in pairs(TCarG[i]:GetChildren()) do if l.Name == "LabelHalo" then l.SurfaceGui.ImageLabel.ImageColor3 = CarButtonUnlit end end
			BC = false
		end
	end)	
	end	
	
	-- Get Floor Buttons --
	if TCarG[i].Name:sub(1,3) == "BTF" then
		TCarG[i].Button.ClickDetector.MouseClick:connect(function() 
			Quene(tonumber(TCarG[i].Name:sub(4)),"Add","Car") end)
	end
	-- Get Alarm --
	if TCarG[i].Name:sub(1,4) == "BTAL" then
	TCarG[i].Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then DoAlarm() end end)
	end
end

-- CallButton --	
for i,l in pairs(x) do
	if TFloorsG[i]:FindFirstChild("CallButton") then
	TFloorsG[i].CallButton.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
	if TFloorsG[i]:FindFirstChild("CallButtonUp") then
	TFloorsG[i].CallButtonUp.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
	if TFloorsG[i]:FindFirstChild("CallButtonDn") then
	TFloorsG[i].CallButtonDn.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
	

	if TFloorsG[i]:FindFirstChild("CallButton2") then
	TFloorsG[i].CallButton2.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
	if TFloorsG[i]:FindFirstChild("CallButtonUp2") then
	TFloorsG[i].CallButtonUp2.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
	if TFloorsG[i]:FindFirstChild("CallButtonDn2") then
	TFloorsG[i].CallButtonDn2.Button.ClickDetector.MouseClick:connect(function() if not ConfigMode then Quene(tonumber(TFloorsG[i].Name:sub(6)),"Add","Call") end end)
	end
end



script.Parent.Data.ScriptCall.Changed:connect(function ()
	if script.Parent.Data.ScriptCall.Value ~= 0 then
		Quene(script.Data.Parent.ScriptCall.Value,"Add",true)
		script.Parent.Data.ScriptCall.Value = 0
	end
end)

script.Parent.Data.HallCall.Changed:connect(function ()
	if script.Parent.Data.HallCall.Value ~= 0 then
		Quene(script.Parent.Data.HallCall.Value,"Add",true)
		script.Parent.Data.HallCall.Value = 0
	end
end)



script.Parent.Data.FireMode.Changed:connect(function ()
	if script.Parent.Data.FireMode.Value == true then
		
		FireLock = true
		Locked = true
			for i = 1, #CallQuene do
				print("Removed: "..CallQuene[i])
				table.remove(CallQuene,i)
			end		
	wait(1)
	Quene(1,"Add","Call")
		
		
	Fire = true

	else
	Fire = false
	FireLock = false
	Locked = false
	script.DoClose.Value = true
	end
end)


 -- End --

if TCar:FindFirstChild("RFID") ~= nil then
	TCar:FindFirstChild("RFID").CARDDETECTOR.Touched:connect(function (Card)
	local Accepted = false
		if Card.Parent.Name ~= "ConfigKey" and Card.Parent:FindFirstChild("CardNumber") ~= nil and CardLock  then

			for id=1, #CardNumber do
			if Card.Parent.CardNumber.Value == CardNumber[id] then
				--TCar.RFID.Beep:Play()
				TCar.RFID.LED.BrickColor = BrickColor.new("Lime green")
				CardLock = false
				--CardLock = false
				wait(5)
				CardLock = true
				--CardLock = true
				TCar.RFID.LED.BrickColor = BrickColor.new("Really red")
				Accepted = true
			end
			wait()
			end
			if not Accepted then
				TCar.RFID.LED.BrickColor = BrickColor.new("New Yeller")
				wait(1)
				TCar.RFID.LED.BrickColor = BrickColor.new("Really red")
			end
		end
	end)
end


Floor.Changed:connect(function() 
	if FloorPassChime then
	TCar.Platform.FloorPassChime:Play()
	end
end)


function DoAlarm()
	if not Alarm then
		Alarm = true
		local g = Instance.new("Hint",workspace)
		g.Text = "Attention, Elevator "..script.Parent.Data.Elevator.Value.."'s Alarm was pressed, Please take a look at security"
		TCar.Platform.Alarm:Play()
		wait(5)
		TCar.Platform.Alarm:Stop()
		wait(1)						
		g:Destroy()
		Alarm = false
	end
end


script.DoChime.Changed:connect(function()
	if script.DoChime.Value == true then
		if Direction.Value == "U" then
			Chime:Play()		
		elseif Direction.Value == "D" then		
			Chime:Play()		
			 wait(0.8)
			Chime:Play()	
		elseif Floor.Value == TotalFloors then
			Chime:Play()			
			wait(0.8)
			Chime:Play()	
		elseif Floor.Value == 1 then
			Chime:Play()	
		else
			Chime:Play()	
		end
		script.DoChime.Value = false
	end
end)

script.ReOpen.Changed:connect(DoorRun)
script.DoOpen.Changed:connect(DoorRun)
script.DoClose.Changed:connect(DoorRun)

print("Floor served: "..TotalFloors)

-- SMARTMOVER™ --

local Running = false
Motor.Changed:connect(function()
	if not Running then
		Running = true
		if Motor.Value ~= 0 then
			repeat
				for i,l in pairs(TCar.Welds:GetChildren()) do
				l.Part1.CFrame = l.Part1.CFrame + Vector3.new(0, Motor.Value, 0)
				end
			wait()
			until Motor.Value == 0
		end
		Running = false
	end
end)

-- WELDING SYSTEM --
function DoWeld(a, b)
    local w = Instance.new("ManualWeld")
    w.Part0 = a
    w.Part1 = b
    w.C0 = CFrame.new()
    w.C1 = b.CFrame:inverse() * a.CFrame
	print(b.Name)
    return w;
end

-- CabWeld --
function StartWeld(ChildAbuse)
	for _,l in pairs(ChildAbuse) do
		if l:IsA("BasePart")then
			local w = DoWeld(TCar.Level,l)
			w.Parent = TCar.Welds
			w.Name = l.Name.."WELD"
		end
		if l:IsA("Model") and l.Name ~= "Welds" then
			StartWeld(l:GetChildren())
		end	
	end
end
StartWeld(TCar:GetChildren())

DoorClose(Floor.Value)