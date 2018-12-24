script.Parent.Equipped:connect(function()
	
	repeat game:GetService("RunService").Stepped:wait() until script.Parent.Parent:FindFirstChild("Right Arm");
	local joint = (function() repeat game:GetService("RunService").Stepped:wait(); until script.Parent.Parent["Right Arm"]:FindFirstChild("RightGrip"); return script.Parent.Parent["Right Arm"].RightGrip; end)();
	local original = joint;
	joint.C0=CFrame.new(original.C0.p*1.5)*CFrame.Angles(original.C0:toEulerAnglesXYZ())
	joint.C1=CFrame.new(original.C1.p*1.5)*CFrame.Angles(original.C1:toEulerAnglesXYZ())
	joint.Parent=script.Parent.Parent.Torso;
	
	
end)