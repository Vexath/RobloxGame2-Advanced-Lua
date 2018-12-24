local e = script.Parent.Equip;
local c = script.Parent.Craft;

local sec = script.Parent.Parent.Actions;
local ite = script.Parent.Parent.Items;
local equ = script.Parent.Parent.Equipped;

e.MouseButton1Click:connect(function()
	
	sec:TweenSizeAndPosition(UDim2.new(0.8,5,0,50),UDim2.new(0.2,-5,1,-50),"Out","Quad",0.2,false);
	
	ite:TweenSizeAndPosition(UDim2.new(0.8,-120,1,-45),UDim2.new(0.2,-5,0,0),"Out","Quad",0.2,false);
	equ:TweenSizeAndPosition(UDim2.new(0,130,1,-45),UDim2.new(1,-130,0,0),"Out","Quad",0.2,false);
	
	--script.Parent.Frame:TweenSizeAndPosition(UDim2.new(1,0,0,34),UDim2.new(0,0,0,0),"Out","Quad",0.2,false);
	
	e.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	c.Style = Enum.ButtonStyle.RobloxRoundButton;
end)

c.MouseButton1Click:connect(function()
	
	sec:TweenSizeAndPosition(UDim2.new(0.8,5,0,160),UDim2.new(0.2,-5,1,-160),"Out","Quad",0.2,false);
	
	ite:TweenSizeAndPosition(UDim2.new(0.8,-120,1,-155),UDim2.new(0.2,-5,0,0),"Out","Quad",0.2,false);
	equ:TweenSizeAndPosition(UDim2.new(0,130,1,-155),UDim2.new(1,-130,0,0),"Out","Quad",0.2,false);
	
	--script.Parent.Frame:TweenSizeAndPosition(UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),"Out","Quad",0.2,false);
	
	c.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
	e.Style = Enum.ButtonStyle.RobloxRoundButton;
	
end)