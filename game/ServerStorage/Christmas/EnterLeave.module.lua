local module = function(ConnectionName,Frames,Enter,Leave,GUI)
	local Mouse = game.Players.LocalPlayer:GetMouse();
	local InsideLast = {};
	
	game:GetService("RunService"):UnbindFromRenderStep(ConnectionName);
	
	game:GetService("RunService"):BindToRenderStep(ConnectionName,0,
		function()
			for _,Frame in pairs(Frames) do
				local Last = InsideLast[Frame.Name];
				local MouseX = Mouse.X;
				local MouseY = Mouse.Y;
				local Inside = false;
				local Region = {
					X = Frame.AbsolutePosition.X;
					Y = Frame.AbsolutePosition.Y;
					X2 = Frame.AbsolutePosition.X + Frame.AbsoluteSize.X;
					Y2 = Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y;
				};
				
				if MouseX >= Region.X and MouseX <= Region.X2 and MouseY >= Region.Y and MouseY <= Region.Y2 and GUI.Visible then
					Inside = true;
				else
					Inside = false;
				end;
				
				if Inside and not Last then
					Enter(Frame);
				elseif not Inside and Last then
					Leave(Frame);
				end
				InsideLast[Frame.Name] = Inside;
			end;
		end
	);
end

return module;
