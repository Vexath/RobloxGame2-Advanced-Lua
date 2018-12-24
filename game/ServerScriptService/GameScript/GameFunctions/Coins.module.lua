local Gets = script.Parent.Parent.Get

function Get(What)
	return Gets:FindFirstChild(What):Invoke();
end

math.randomseed(tick());

local Data = require(script.Parent.Parent.DataModule);

local Set = script.Parent.Parent.Set.PlayerData;

local module = function()
	local Map = Get("Map");
	CoinObject = Instance.new("Model");
	CoinObject.Name = "CoinContainer";
	CoinObject.Parent = Map;
	local CoinAreas = game.ServerStorage.Maps[Map.Name].CoinAreas:GetChildren();
	
	local GiftData = {};
	for _,Player in pairs(game.Players:GetPlayers()) do
		GiftData[Player.Name] = 0;
	end

	local CoinData = {};
	for _,Player in pairs(game.Players:GetPlayers()) do
		CoinData[Player.Name] = 0;
	end
	
	local coro = coroutine.create(function()
		
		
		while Get("GameTimer") > 0 do
			
			if #CoinObject:GetChildren() < 20 then
				
				
				
			    local Area = CoinAreas[math.random(1, #CoinAreas)];
			    local X = math.random(-Area.Size.x / 2, Area.Size.x / 2);
			    local Y = math.random(-Area.Size.y / 2, Area.Size.y / 2);
			    local Z = math.random(-Area.Size.z / 2, Area.Size.z / 2);
			    local Point = Area.CFrame:toWorldSpace(CFrame.new(X, Y, Z));
			
				local IsGift = false--true--(math.random(1,3)==1);
				local Gifts = game.ServerStorage.Gifts:GetChildren();
				
				local NewCoin;
				if IsGift then
					NewCoin = Gifts[math.random(1,#Gifts)]:Clone();
					NewCoin.CFrame = CFrame.new(Point.p);
				else
					NewCoin = game.ServerStorage.Coin:Clone();
					NewCoin.CFrame = CFrame.new(Point.p) * CFrame.Angles(math.pi/2, -math.pi/2, 0)
				end;
				NewCoin.Parent = CoinObject;
				
				local TouchCon;
				TouchCon = NewCoin.Touched:connect(function(Toucher)
					
					local Coiner = game.Players:GetPlayerFromCharacter(Toucher.Parent);
					local PlayerData = Get("PlayerData");
					if Coiner ~= nil then
						if PlayerData[Coiner.Name] ~= nil then
							
							if not IsGift then
								--if PlayerData[Coiner.Name]["Coins"] < PlayerData[Coiner.Name]["MaxCoins"] then
								if (CoinData[Coiner.Name] < 10) or (CoinData[Coiner.Name] < 15 and _G.CheckElite(Coiner)) then
									TouchCon:disconnect();
									local Sound = game.ServerStorage.CoinSound:Clone();
									pcall(function()
										Sound.Parent = Coiner.Character.Torso;
										Sound:Play();
									end)
									game.Debris:AddItem(Sound,3)
									NewCoin:Destroy();
									CoinData[Coiner.Name] = CoinData[Coiner.Name] + 1;
									Data.Give(Coiner,"Credits",1);
									game.ReplicatedStorage.GetCoin:FireClient(Coiner);
								end
							else

								if (GiftData[Coiner.Name] < 10) or (GiftData[Coiner.Name] < 15 and _G.CheckElite(Coiner)) then
									TouchCon:disconnect();
									local Sound = game.ServerStorage.GiftSound:Clone();
									pcall(function()
										Sound.Parent = Coiner.Character.Torso;
										Sound:Play();
									end)
									game.Debris:AddItem(Sound,3)
									NewCoin:Destroy();
									Data.GiveItem(Coiner,"Candies",1);
									GiftData[Coiner.Name] = GiftData[Coiner.Name] + 1;
									game.ReplicatedStorage.GetCoin:FireClient(Coiner);
									game.ReplicatedStorage.CollectGift:FireClient(Coiner);
								end;
								
							end;
							
						end
					end
					
				end)
				
				
				
			end
			
			wait(1);
		end
		
		
		
	end);
	coroutine.resume(coro);
	spawn(function()
		while Get("GameTimer") > 0 do
			for _,Coin in pairs(CoinObject:GetChildren()) do
				if Coin.Name == "Coin" then
					Coin.CFrame = Coin.CFrame * CFrame.Angles(math.pi/90,0,0)
				else
					Coin.CFrame = Coin.CFrame * CFrame.Angles(0,math.pi/90,0)
				end;
			end
			wait(0.05);
		end;
	end);
end

return module
