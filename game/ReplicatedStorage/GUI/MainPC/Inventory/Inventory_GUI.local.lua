local GameGUI = script.Parent.Parent.Game;
local InventoryFrame = GameGUI.Inventory;
local Navigation = InventoryFrame.Nav;
local Main = InventoryFrame.Main;
local Dock = GameGUI.Dock;

local NavOrder = {
	"Weapons";
	"Effects";
	"Animations";
	"Accessories";
	"Toys";
	"Pets";
};

local Time = 0.2;
local Style = "Quad";
local Direction = "Out";

local CurrentFrame = "Weapons";
local CurrentAction = "Equip";
local Tweening = false;

-- Weapons Tab 
local WeaponsFrame = InventoryFrame.Main.Weapons;

local ActionsFrame = WeaponsFrame.Actions;
local EquippedFrame = WeaponsFrame.Equipped;
local ItemsFrame = WeaponsFrame.Items;

local ActionContainer = ActionsFrame.ActionContainer
local CraftingFrame = ActionContainer.Craft;

local EquipButton = ActionsFrame.Equip;
local CraftButton = ActionsFrame.Craft;
local RecycleButton = ActionsFrame.Recycle;
local RecipesFrame = InventoryFrame.Recipes;

local Sizes = {
	
	[ItemsFrame] = {
		[EquipButton] = {
			Size = ItemsFrame.Size;
			Position = ItemsFrame.Position;
		};
		[CraftButton] = {
			Size = UDim2.new(0,-427,1,-155);
			Position = ItemsFrame.Position;
		};
		[RecycleButton] = {
			Size = UDim2.new(0,-427,1,-200);
			Position = ItemsFrame.Position;
		};
	};
	
	[ActionsFrame] = {
		[EquipButton] = {
			Size = ActionsFrame.Size;
			Position = ActionsFrame.Position;
		};
		[CraftButton] = {
			Size = UDim2.new(1,0,0,160);
			Position = UDim2.new(0,0,1,-160);
		};
		[RecycleButton] = {
			Size = UDim2.new(1,0,0,205);
			Position = UDim2.new(0,0,1,-205);
		};
	};
	
	[EquippedFrame] = {
		[EquipButton] = {
			Size = EquippedFrame.Size;
			Position = EquippedFrame.Position;
		};
		[CraftButton] = {
			Size = UDim2.new(0,130,1,-155);
			Position = UDim2.new(1,0,0,0);
		};
		[RecycleButton] = {
			Size = UDim2.new(0,130,1,-200);
			Position = EquippedFrame.Position;
		};
	};
	
	[RecipesFrame] = {
		[EquipButton] = {
			Size = RecipesFrame.Size;
			Position = RecipesFrame.Position;
		};
		[CraftButton] = {
			Size = UDim2.new(0,292,1,-155);
			Position = RecipesFrame.Position; --EquippedFrame.Position;
		};
		[RecycleButton] = {
			Size = UDim2.new(0,0,1,-200);
			Position = ItemsFrame.Position;
		};
	};
	
};

local Buttons = {EquipButton,CraftButton,RecycleButton};

local function ChangeAction(Button,CustomTime)
	CurrentAction = Button.Name;
	for _,B in pairs(Buttons) do B.Style = (B==Button and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton; end;
	if Button.Name ~= "Equip" then for _,F in pairs(ActionContainer:GetChildren()) do F.Visible = (F.Name==Button.Name); end; end;
	for Frame,Data in pairs(Sizes) do
		Frame:TweenSizeAndPosition(
			Data[Button].Size,
			Data[Button].Position,
			Direction,Style,((tonumber(CustomTime)~=nil and CustomTime) or Time)
		);
	end
end
for _,Button in pairs(Buttons) do
	Button.MouseButton1Click:connect(function()
		ChangeAction(Button);
	end)
end


-- End of Weapons Tab


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
				ChangeAction(EquipButton,0.1);
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

Dock.Inventory.MouseButton1Click:connect(function()
	if GameGUI.Processing.Visible or GameGUI.CaseOpen.Visible then return; end;
	InventoryFrame.Visible = not InventoryFrame.Visible;
	GameGUI.Crafting.Visible = false;
	GameGUI.Santa.Visible = false;
end)

Dock.Shop.MouseButton1Click:connect(function()
	InventoryFrame.Visible = false;
	GameGUI.Crafting.Visible = false;
	GameGUI.Santa.Visible = false;
end)

-- End of Navigation

