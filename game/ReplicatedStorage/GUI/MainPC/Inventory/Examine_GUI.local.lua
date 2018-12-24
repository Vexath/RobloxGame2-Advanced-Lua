local GameGUI = script.Parent.Parent.Game;
local InventoryFrame = GameGUI.ViewInventory;
local Navigation = InventoryFrame.Nav;
local Main = InventoryFrame.Main;
local Dock = GameGUI.Dock;

local NavOrder = {"Weapons";"Effects";"Animations";"Accessories";"Toys";"Pets";};
local Time = 0.2;
local Style = "Quad";
local Direction = "Out";

local CurrentFrame = "Weapons";
local CurrentAction = "Equip";
local Tweening = false;

local WeaponsFrame = InventoryFrame.Main.Weapons;
-- Navigation
for _,NavButton in pairs(Navigation:GetChildren()) do
	if NavButton:IsA("TextButton") then
		NavButton.MouseButton1Click:connect(function()
			local CurrentIndex;
			local NextIndex;
			local NextFrame = NavButton.Name;
			
			if NextFrame ~= CurrentFrame and not Tweening then
				for _,Button in pairs(Navigation:GetChildren()) do if Button:IsA("TextButton") then Button.Style = (Button==NavButton and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton; end; end;
				Tweening = true;
				for Index,Frame in pairs(NavOrder) do if Frame == CurrentFrame then CurrentIndex = Index; elseif Frame == NextFrame then NextIndex = Index; end; end;
				local Forward = (NextIndex>CurrentIndex and true) or false;
				local CurrentFrameTweenPosition = (Forward and UDim2.new(-1,0,0,0)) or UDim2.new(1,0,0);
				local NextFramePosition = (Forward and UDim2.new(1,0,0,0)) or UDim2.new(-1,0,0,0);
				Main[NextFrame].Position = NextFramePosition;
				Main[CurrentFrame]:TweenPosition(CurrentFrameTweenPosition,Direction,Style,Time,false);
				Main[NextFrame]:TweenPosition(UDim2.new(0,0,0,0),Direction,Style,Time,false);
				CurrentFrame = NextFrame;
				wait(Time);
				Tweening = false;
			end;
		end)
	end;
end