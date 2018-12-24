																																																							--[[
____________________________________________________________________________________________________________________________________________________________________________

 @ CloneTrooper1019, 2014
	(Some code provided by Mark Langen, also known as stravant)


	This module comes with API for controlling 3D to 2D. 

	PLEASE NOTE: The API assumes there is nothing in front of the model being displayed (whether its a GUI, or anything in the workspace) 
  				 You need to manually put a BillBoardGui behind your 3D Display as well as handle a camera system for showing it properly
 				 This does not support character models too well yet. You can modify it to whatever extents you need.

____________________________________________________________________________________________________________________________________________________________________________

	(API DETAILS) Assuming that 'Module3d' is require(Module3D) this is how to use the library:
____________________________________________________________________________________________________________________________________________________________________________
		
		* Module3d:Attach3D(Instance guiObj, Instance model)
			Description:
				* Attaches a part/model to the center of the gui object specified.
				* Can have its offset changed as well as its active state. By default the model is hidden, and you need to call SetActive onto it manually
			Arguments:
				* Instance guiObj
					- guiObj must be any kind of Gui object that contains a "Position" property, such as a Frame, ImageLabel, etc.
				* Instance model
				 	- model can be either a Model, or a BasePart (Part, Wedge, Truss, etc).
			Returns:
				* 3dController
					- This is a library with a few functions and one property. It allows you to control your 3D Model's behavior.
						* 3dController:SetActive(boolean active)
							- Toggles whether or not the 3D Object should be shown or not
						* 3dController:SetCFrame(CoordinateFrame Offset)
							- Sets a CFrame rotation and offset from the location its trying to place the 3D Model.
							- Note that by default, it sets the CFrame a blank CFrame.new() ( or CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) )
						* 3dController:End()
							- Effectively Removes the model and disconnects its movement events.
						* 3dController.Object3D
							- The current model being used.
			Example Code:
			
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local model = workspace.Guy
				local frame = script.Parent.Frame
				local activeModel = handler:Attach3D(frame,model)
				activeModel:SetActive(true)
				activeModel:SetCFrame(CFrame.fromEulerAnglesXYZ(0,math.pi,0))
				----------------------------------------------------------------------------------------------------------

____________________________________________________________________________________________________________________________________________________________________________
	
		* Module3d:AdornScreenGuiToWorld(Instance screenGui, number depth = 1)
			Description:
				* This function takes a ScreenGui, and turns it into a SurfaceGui.
				* The SurfaceGui is adorned to a part whose width and height is fitted to fit the screen perfectly, 
				* The part follows the camera like an adorned 3D Model, but it uses a certain depth
			Arguments:
				* Instance screenGui
					- guiObj must be a ScreenGui. If you only need to do this with one frame, its reccomended you just make the entire ScreenGui an adorn.
				* number depth = 1
				 	- How many studs in front of the camera the GUI will be.
					- This argument is optional, and excluding it will set it to 1.
			Returns:
				* Instance SurfaceGui
					- This is the SurfaceGui version of your ScreenGui.
				* 3dGuiModifier
					- This is a small library with 2 functions. It allows you to change the depth of the WorldGui, and reset it back to a ScreenGui.
						* 3dController:SetDepth(number depth)
							- Sets a new depth value.
						* 3dGuiModifier:Reset()
							- Returns the ScreenGui to its former state, Destroys the old BillboardGui, and disconnects the movement event.
							
			Example Code:
			
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local oldGui = script.Parent
				local newGui,modifier = handler:AdornScreenGuiToWorld(screenGui,3)
				print(oldGui.Parent,newGui.Parent)
				wait(1)
				modifier:SetDepth(2)
				wait(1)
				modifier:Reset()
				print(oldGui.Parent,newGui.Parent)
				
				----------------------------------------------------------------------------------------------------------

____________________________________________________________________________________________________________________________________________________________________________

							
		* Module3d:GetScreenResolution()
			Description: 
				* Attempts to locate a ScreenGui within the client's PlayerGui and returns the AbsoluteSize if it can.
			Arguments: 
				* None
			Returns: 
				* A Vector2 of the clients resolution representing the width and depth of the roblox window.
			Example Code:
			
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local clientRes = handler:GetScreenResolution()
				print(clientRes)
				----------------------------------------------------------------------------------------------------------

____________________________________________________________________________________________________________________________________________________________________________
		
		* Module3d:PointToScreenSpace(Vector3 at)
			Description:
				* Converts a Vector3 location into a Vector2 pixel location using the clients resolution
			Arguments:
				* Vector3 at
					- Should be a Vector3 location in the world
			Returns:
				* A Vector2 location on the client's screen which sits right on top of the Vector3 location
			Example Code:
				
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local worldLoc = Vector3.new(0,0,0)
				local screenLoc = handler:PointToScreenSpace(worldLoc)
				print(worldLoc,screenLoc)
				----------------------------------------------------------------------------------------------------------			
____________________________________________________________________________________________________________________________________________________________________________

		* Module3d:ScreenSpaceToWorld(int x, int y, number depth)
			Description:
				* Converts an X/Y coordinate on the clients screen into a Vector3 location using depth to determine
				  how far away the Vector3 should be from the screen.
			Arguments:
				* int X
					- Should be a whole number representing an X-axis location on the client's screen.
				* int Y
					- Same as int X, but representing a Y-axis location vs an X-axis location.
				* number depth
					- The distance in studs the Vector3 should be from the camera
			Returns:
				* A Vector3 location on the clients screen with sits on top of the X and Y coordinates,
				  with a certain distance away from the client's camera depending on the depth.
			Example Code:
				* SEE THE GetDepthForWidth EXAMPLE BELOW. IT WILL USE BOTH FUNCTIONS
____________________________________________________________________________________________________________________________________________________________________________

		* Module3d:GetDepthForWidth(number partWidth, int visibleSize)
			Description: 
				* Calculates a depth value to be used with ScreenSpaceToWorld using
				  a ratio between a width in studs, and a width in pixels.
			Arguments:
				* number partWidth
					- Should be a number representing the width in studs of the object you are
					  calculating the depth for
				* int visibleSize
					- Should be a whole number represneting the width in pixels of the gui object
					  you want to put your object into
			Returns:
				* A number representing the depth to be used based on the arguments suppled.
			Example Code:
			
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local model = workspace.Guy
				local sizeX,sizeY = script.Parent.AbsoluteSize.X,script.Parent.AbsoluteSize.Y
				local modelScale = model:GetModelSize().magnitude
				
				local posZ = handler:GetDepthForWidth(modelScale, sizeY)
				local posX,posY = script.Parent.AbsolutePosition.X+(sizeX/2),script.Parent.AbsolutePosition.Y+(sizeY/2)
				local pos = ModuleAPI:ScreenSpaceToWorld(posX,posY,posZ)
				local location = workspace.CurrentCamera.CoordinateFrame * CFrame.new(pos.X, pos.Y, posZ)
				print(location)
				----------------------------------------------------------------------------------------------------------
____________________________________________________________________________________________________________________________________________________________________________

	Script Starts Below...
____________________________________________________________________________________________________________________________________________________________________________																																																																--]]

-- Double check that we are being called from the client...

isClient = (game.Players.LocalPlayer ~= nil)

if not isClient then
	error("ERROR: '"..script:GetFullName().."' can only be used from a LocalScript.")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API

ModuleAPI = {}
c = workspace.CurrentCamera
player = game.Players.LocalPlayer
rs = game:GetService("RunService")

function checkArgs(...)
	-- Generic Function for checking if arguments exist / are the correct type.
	local args = {...}
	local function useVowel(name)
		local vowels = {"a","e","i","o","u"}
		for _,v in pairs(vowels) do
			if string.sub(string.lower(name),1,1) == v then
				return true
			end
		end
		return false
	end
	for i = 1,#args,2 do 
		local s = "Argument "..(i/2+.5)
		local var,f = args[i], args[i+1]
		if var == nil then 
			return error(s.." missing or nil") 
		end 
		local vt = type(var)
		if type(f) == "function" then
			local r,t = f(var)
			if not r then
				return error(s.." should be a"..(useVowel(t) and "n" or "").." "..t.." (not a"..(useVowel(vt) and "n" or "")..": "..vt..")")
			end
		elseif vt ~= f then
			return error(s.." should be a"..(useVowel(f) and "n" or "").." "..f.." (not a"..(useVowel(vt) and "n" or "")..": "..vt..")")
		end
	end
end

function ModuleAPI:GetScreenResolution()
	local mouse = player:GetMouse()
	if mouse then
		if mouse.ViewSizeX > 0 and mouse.ViewSizeY > 0 then
			return Vector2.new(mouse.ViewSizeX,mouse.ViewSizeY)
		end
	end
	if player.PlayerGui then
		local screenGui
		for _,v in pairs(player.PlayerGui:GetChildren()) do
			if v:IsA("ScreenGui") then
				screenGui = v
			end
		end
		if not screenGui then -- Not sure if this is possible assuming the scenario. But you never know.
			screenGui = Instance.new("ScreenGui",player.PlayerGui)
			wait(.1) -- Wait just a moment for the property to get set.
		end
		return screenGui.AbsoluteSize
	end
	return error("ERROR: Can't get client resolution")
end

function ModuleAPI:PointToScreenSpace(at)
	checkArgs(at,function(v)
		local p
		local is = pcall(function () return p.X,p.Y,p.Z end) 
		return is or false,"Vector3"
	end)
	local resolution = ModuleAPI:GetScreenResolution()
	local point = c.CoordinateFrame:pointToObjectSpace(at)
	local aspectRatio = resolution.X / resolution.Y
	local hfactor = math.tan(math.rad(c.FieldOfView)/2)
	local wfactor = aspectRatio*hfactor
	local x = (point.x/point.z) / -wfactor
	local y = (point.y/point.z) /  hfactor
	return Vector2.new(resolution.X*(0.5 + 0.5*x), resolution.Y*(0.5 + 0.5*y))
end

function ModuleAPI:ScreenSpaceToWorld(x, y, depth)
	checkArgs(x,"number",y,"number",depth,"number")
	local resolution = ModuleAPI:GetScreenResolution()
	local aspectRatio = resolution.X / resolution.Y
	local hfactor = math.tan(math.rad(c.FieldOfView)/2)
	local wfactor = aspectRatio*hfactor
	local xf, yf = x/resolution.X*2 - 1, y/resolution.Y*2 - 1
	local xpos = xf * -wfactor * depth
	local ypos = yf *  hfactor * depth
	return Vector3.new(xpos, ypos, depth)
end

function ModuleAPI:GetDepthForWidth(partWidth, visibleSize)
	checkArgs(partWidth,"number",visibleSize,"number")
	local resolution = ModuleAPI:GetScreenResolution()
	local aspectRatio = resolution.X / resolution.Y
	local hfactor = math.tan(math.rad(c.FieldOfView)/2)
	local wfactor = aspectRatio*hfactor
	return (-0.5*resolution.X*partWidth/(visibleSize*wfactor))
end

function ModuleAPI:Attach3D(guiObj,model)
	checkArgs(
		guiObj,function (v)
			return guiObj:IsA("GuiObject") or false,"GuiObject"
		end,
		model,function (v)
			return (model:IsA("Model") or model:IsA("BasePart")) or false,"Model or BasePart"
		end
	)
	local index = {}
	local m = Instance.new("Model")
	m.Name = ""
	m.Parent = c
	objs = {}
	if model:IsA("BasePart") then
		local this = model:clone()
		this.Parent = m
		table.insert(objs,this)
	else
		local function recurse(obj)
			for _,v in pairs(obj:GetChildren()) do
				local part
				if v:IsA("BasePart") then
					part = v:clone()
				elseif v:IsA("Hat") and v:findFirstChild("Handle") then
					part = v.Handle:clone()
				end
				if part then
					local cf = part.CFrame
					part.Anchored = false
					part.Parent = m
					part.CFrame = cf
					if part:findFirstChild("Decal") and part.Transparency ~= 0 then
						part:Destroy()
					--elseif part.Name == "Head" then
						--part.Name = "H"
					end
					if part.Parent == m then
						table.insert(objs,part)
					end
				elseif not v:IsA("Model") and not v:IsA("Sound") and not v:IsA("Script") then
					v:clone().Parent = m
				else
					recurse(v)
				end
			end
		end
		recurse(model)
	end
	local primary = Instance.new("Part")
	primary.Anchored = true
	primary.Transparency = 1
	primary.CanCollide = false
	primary.Name = "MODEL_CENTER"
	primary.FormFactor = "Custom"
	primary.Size = m:GetExtentsSize()
	primary.CFrame = CFrame.new(m:GetModelCFrame().p)
	primary.Parent = m
	m.PrimaryPart = primary
	for _,v in pairs(objs) do
		v.Anchored = false
		v.CanCollide = false
		v.Archivable = true
		local w = Instance.new("Weld",primary)
		w.Part0 = primary
		w.Part1 = v
		local CJ = CFrame.new(primary.Position)
		w.C0 = primary.CFrame:inverse()*CJ
		w.C1 = v.CFrame:inverse()*CJ
		v.Parent = m
	end
	CF = CFrame.new(0, 0, 0, -1, 0, -8.74227766e-008, 0, 1, 0, 8.74227766e-008, 0, -1)
	Active = false
	DistOffset = 0
	function index:SetActive(b)
		checkArgs(b,"boolean")
		Active = b
	end
	function index:SetCFrame(cf)
		checkArgs(cf,function () 
			local isCFrame = pcall(function () return cf:components() end)
			return isCFrame or false,"CFrame"
		end)
		CF = cf
	end
	function index:GetCFrame()
		return CF;
	end
	local function updateModel()
		primary.Anchored = false
		if Active then
			local posZ = ModuleAPI:GetDepthForWidth(primary.Size.magnitude, guiObj.AbsoluteSize.Y)
			local sizeX,sizeY = guiObj.AbsoluteSize.X,guiObj.AbsoluteSize.Y
			local posX,posY = guiObj.AbsolutePosition.X+(sizeX/2),guiObj.AbsolutePosition.Y+(sizeY/2)
			local pos = ModuleAPI:ScreenSpaceToWorld(posX,posY,posZ)
			local location = c.CoordinateFrame * CFrame.new(pos.X, pos.Y, posZ)
			primary.CFrame = location * CF
		else
			primary.CFrame = CFrame.new()
		end
		primary.Anchored = true
	end
	local con = rs.RenderStepped:connect(updateModel)
	function index:End()
		con:disconnect()
		pcall(function ()
			m:Destroy()
		end)
		return
	end
	index.Object3D = m
	return index
end

function ModuleAPI:AdornScreenGuiToWorld(screenGui,depth)
	checkArgs(screenGui,function (v)
		return (screenGui:IsA("ScreenGui") or screenGui:IsA("BillboardGui")) or false,"ScreenGui or BillboardGui"
	end)
	local depth = type(depth) == "number" and depth or 1
	local s = Instance.new("BillboardGui",screenGui.Parent)
	s.Name = screenGui.Name
	local adorn = Instance.new("Part",s)
	adorn.Name = screenGui.Name.."_Adornee"
	adorn.FormFactor = "Custom"
	adorn.Anchored = true
	adorn.CanCollide = false
	adorn.Size = Vector3.new()
	adorn.Transparency = 1
	adorn.Locked = true
	local con
	local modifier = {}
	function modifier:SetDepth(n)
		checkArgs(n,"number")
		depth = n
	end
	function modifier:Reset()
		screenGui.Parent = s.Parent
		for _,v in pairs(s:GetChildren()) do
			v.Parent = screenGui
		end
		con:disconnect()
		adorn:Destroy()
		s:Destroy()
	end
	local function updateAdorn()
		local success,did = pcall(function ()
			local res = ModuleAPI:GetScreenResolution()
			adorn.CFrame = c.CoordinateFrame
			s.Size = UDim2.new(0,res.X,0,res.Y)
			s.StudsOffset = Vector3.new(0,0,-depth)
			return true
		end)
		if not success or not did then
			warn(script:GetFullName()..": The adornee was destroyed! The gui has been reset.")
			modifier:Reset()
		end
	end
	con = rs.RenderStepped:connect(updateAdorn)
	s.Adornee = adorn
	for _,v in pairs(screenGui:GetChildren()) do
		v.Parent = s
	end
	screenGui.Parent = nil
	return s,modifier
end

return ModuleAPI