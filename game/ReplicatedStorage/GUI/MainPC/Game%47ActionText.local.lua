local MainGUI = script.Parent.Game;

local ActionText = MainGUI.ActionText;
game.ReplicatedStorage.ActionText.OnClientEvent:connect(function(Text,Duration) 
	ActionText.Text = Text;
	if Duration ~= nil then
		wait(Duration);
		if ActionText.Text == Text then
			ActionText.Text = "";
		end
	end
end)