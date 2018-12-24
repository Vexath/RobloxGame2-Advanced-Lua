local Main = script.Parent.Main;
local Confirm = Main.Confirm;

local CodeBox = Main.MerchCode;
local QuantityBox = Main.Quantity;
local UsernameBox = Main.Username;

local PlayerIcon = Main.Player;
local PreviewIcon = Main.PreviewIcon;
local PreviewText = Main.PreviewName;

local Codes = game.ReplicatedStorage.GetSyncData:InvokeServer("MerchCodes");
local Items = game.ReplicatedStorage.GetSyncData:InvokeServer("Item");
local Rarity = game.ReplicatedStorage.GetSyncData:InvokeServer("Rarity");
local CanConfirm = false;

local AssetURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=";

local function GetImage(Image) local Return; if _G.Cache[Image] ~= nil then return _G.Cache[Image]; else local NewImage = (tonumber(Image) and AssetURL..Image) or Image;  NewImage = NewImage .. "&bust="..math.random(1,10000); _G.Cache[Image] = NewImage; return NewImage; end; end;

local function Update()
	
	local CodeValid = false;
	local UsernameValid = false;
	local QuantityValid = false;
	
	local Reward = Codes[CodeBox.Text];
	
	if Reward and Items[Reward.Item] then
		CodeValid = true;
		local Item = Items[Reward.Item];
		PreviewIcon.Image = GetImage(Item.Image);
		PreviewText.Text = Item.ItemName or Item.Name;
		PreviewText.TextColor3 = Rarity[Item.Rarity];
		Main.MerchName.Text = Reward.Name;
		
		local Quantity = tonumber(QuantityBox.Text);
		QuantityValid = Quantity;
		PreviewText.Text = (Quantity and Quantity>1 and PreviewText.Text .. " (x"..Quantity..")") or PreviewText.Text;
	else
		PreviewIcon.Image = "";
		PreviewText.Text = "";
		Main.MerchName.Text = "";
	end;

	local Success = pcall(function() 
		local ID = game.Players:GetUserIdFromNameAsync(UsernameBox.Text);
		PlayerIcon.UserID.Text = ID;
		PlayerIcon.Username.Text = game.Players:GetNameFromUserIdAsync(ID); 
		PlayerIcon.Image = game.ReplicatedStorage.GetPlayerImage:Invoke(UsernameBox.Text);
		UsernameValid = true;
	end);
	
	if not Success then
		PlayerIcon.UserID.Text = "";
		PlayerIcon.Username.Text = "";
		PlayerIcon.Image = "";
	end	

	CanConfirm = (CodeValid and UsernameValid and QuantityValid);
	Confirm.Style = (CanConfirm and Enum.ButtonStyle.RobloxRoundDefaultButton) or Enum.ButtonStyle.RobloxRoundButton;	
	
end


Confirm.MouseButton1Click:connect(function()
	if CanConfirm then
		Main.Saving.Visible = true;
		local Done = game.ReplicatedStorage.M:InvokeServer(UsernameBox.Text,CodeBox.Text,QuantityBox.Text)
		Main.Saving.Visible = false;
	end
end)

CodeBox.Changed:connect(Update);
UsernameBox.Changed:connect(Update);
QuantityBox.Changed:connect(Update);