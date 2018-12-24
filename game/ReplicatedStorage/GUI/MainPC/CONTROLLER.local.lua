local MainGUI = script.Parent.Game;

if game:GetService("UserInputService").GamepadEnabled then
    
	MainGUI.Dock.Controller.Visible = true; -- Done
	
	--MainGUI.Inventory.Controller.Visible = true; -- Done
	--MainGUI.Inventory.Controller2.Visible = true; -- Done
	
	MainGUI.Shop.Controller.Visible = true; -- Done
	MainGUI.Shop.Controller2.Visible = true;-- Done
	
	MainGUI.CaseComplete.OK.Controller.Visible = true; -- Done
	
	MainGUI.Shop.PurchaseBox.Unlock.Controller.Visible = true; -- Done
	
	--MainGUI.Spawning.Spawn.Label.Controller.Visible = true;
	
	MainGUI.Trade.Offers.Controller.Visible = true; -- Kinda Done
	
	MainGUI.Leaderboard.Controller.Visible = true; -- Done
	
	MainGUI.PlayerMenu.Trade.Controller.Visible = true; -- Done
	MainGUI.PlayerMenu.Inventory.Controller.Visible = true; -- Done
	
	MainGUI.ViewInventory.Controller.Visible = true; -- Done
	MainGUI.ViewInventory.Controller2.Visible = true; -- Done
	MainGUI.ViewInventory.Close.Visible = false; -- Done
	
	MainGUI.Spectate.Controller2.Visible = true; --??
	MainGUI.Spectate.Controller.Visible = true; --??
	MainGUI.Spectate.Left.Visible = false; --??
	MainGUI.Spectate.Right.Visible = false; --??
	
	MainGUI.Recipes.Controller.Visible = true; -- Done
	MainGUI.Recipes.Close.Visible = false; -- Done
	
	MainGUI.Shop.NavBar.Effects.Visible = false;
	MainGUI.Shop.NavBar.Animations.Visible = false;
	
	
	MainGUI.GetCredits.Controller2.Visible = true;
	
	
	MainGUI.Christmas.Xbox.Visible = true;
	MainGUI.Christmas.GetMore.Controller.Visible = true;
	
	MainGUI.Settings.Visible = false;

end
