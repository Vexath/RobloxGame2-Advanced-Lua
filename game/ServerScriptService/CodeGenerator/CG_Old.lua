local Codes = game:GetService("DataStoreService"):GetDataStore("StoreCodes");

game.Players.PlayerAdded:connect(function(Player)
    if Player.userId == 49111250 or Player.userId == 1848960 then
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


function CreateCode()	
	local Code;
	local CodeAvailable = false;
	repeat 
		Code = GenerateCode();
		
		Codes:UpdateAsync(Code, function(Value)
			if Value == nil then
				CodeAvailable = true;
				return "Not Redeemed";
			else
				print("Duplicate code generated.");
				return nil;
			end;
		end)
		
		wait();
	until CodeAvailable;
	return Code;
end
function script.G2.OnInvoke()
	return CreateCode();
end

function game.ReplicatedStorage.G.OnServerInvoke(Player)
	if Player.userId ~= 49111250 and Player.userId ~= 1848960  then return; end;
	return CreateCode();
end





