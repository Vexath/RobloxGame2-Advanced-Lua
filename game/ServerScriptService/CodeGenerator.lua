local Codes = game:GetService("DataStoreService"):GetDataStore("StoreCodes2");

game.Players.PlayerAdded:connect(function(Player)
    if Player.userId == 840691484 then
        Player.Chatted:connect(function(Message)
 			if Message == "generate" then
				script.Generator:Clone().Parent = Player.PlayerGui;
			end;
        end)
    end
end)

local function GenerateCode()
	local Code = "";
	for i = 1,3 do
		if math.random(1,2) == 1 then
			Code = Code .. math.random(0,9);
		else
			Code = Code .. string.char(math.random(65,90));
		end;
	end
	Code = Code .. "-";
	for i = 1,3 do
		if math.random(1,2) == 1 then
			Code = Code .. math.random(0,9);
		else
			Code = Code .. string.char(math.random(65,90));
		end;
	end
	return Code;
end


function CreateCode(Rewards)	
	local Code;
	local CodeAvailable = false;
	repeat 
		Code = GenerateCode();
		
		Codes:UpdateAsync(Code, function(Value)
			
			if Value == nil then
				CodeAvailable = true;
				return {
					Redeemed = false;
					Rewards = Rewards;
					--[[Rewards = {
						{RewardID = RewardID;RewardType = RewardType;};
					};]]
				};
			else
				print("Duplicate code generated.");
				return Value;
			end;
			
		end)
		
		wait();
	until CodeAvailable;
	return Code;
end


function script.G2.OnInvoke(Rewards)
	return CreateCode(Rewards);
end


--[[
	
	{{ID="Rainbow";Type="Effects"};};
	
	game.ServerScriptService.CodeGenerator.PB:Invoke({{ID="Rainbow";Type="Effects"};},1);
	
	print(game.ServerScriptService.CodeGenerator.G2:Invoke({{ID="Rainbow";Type="Effects"};},1));
	
--]]


function game.ReplicatedStorage.G.OnServerInvoke(Player,Rewards)
	if Player.userId ~= 840691484 then return; end;
	return CreateCode(Rewards);
end





