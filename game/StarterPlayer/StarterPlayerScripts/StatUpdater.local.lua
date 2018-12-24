local function GetGifts()
	local Inventory = _G.PlayerData.Weapons.Owned;
	for ItemName,ItemAmount in pairs(Inventory) do
		if ItemName == "Gift" then
			_G.Gifts = ItemAmount;
			return;
		end
	end
end

_G.Gifts = 0;

_G.OfferEndTime = 1471244400;
local TotalSecondsLeft = _G.OfferEndTime-os.time();
_G.ShowItemPack = TotalSecondsLeft>0;
_G.CanJump = true;


repeat 
	_G.PlayerData = game.ReplicatedStorage.GetData2:InvokeServer();
	wait(0.1);
until _G.PlayerData ~= nil;


local function UpdateData()
	GetGifts();
end


game.ReplicatedStorage.UpdateData2.OnClientEvent:connect(function(Data,CoinUpdate)
	_G.PlayerData = Data;
	UpdateData();
	game.ReplicatedStorage.UpdateDataClient:Fire(CoinUpdate);
end)
game.ReplicatedStorage.UpdateDataClient.Event:connect(UpdateData)



game.ReplicatedStorage.UpdateData3.OnClientEvent:connect(function(Data)
	_G.PlayerData = Data;
end)


UpdateData();

