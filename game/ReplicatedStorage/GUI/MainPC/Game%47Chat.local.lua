local ChallengeTitles = {
	["InnocentEasy"] = "Survivor";
	["InnocentMedium"] = "Collector";
	["InnocentHard"] = "Hero";
	
	["GunnerEasy"] = "Detective";
	["GunnerMedium"] = "Purifier";
	["GunnerHard"] = "Guardian";
	
	["KniferEasy"] = "Butcher";
	["KniferMedium"] = "Bulls-Eye";
	["KniferHard"] = "Slayer";
};

local ChallengeColors = {
	["InnocentEasy"] = Color3.new(0,1,0);
	["InnocentMedium"] = Color3.new(0,1,0);
	["InnocentHard"] = Color3.new(0,1,0);
	
	["GunnerEasy"] = Color3.new(0,89/255,206/255);
	["GunnerMedium"] = Color3.new(0,89/255,206/255);
	["GunnerHard"] = Color3.new(0,89/255,206/255);
	
	["KniferEasy"] = Color3.new(1,0,0);
	["KniferMedium"] = Color3.new(1,0,0);
	["KniferHard"] = Color3.new(1,0,0);
};

local MainGUI = script.Parent.Game;

local ChatFrame = MainGUI.ChatFrame;
local LocalPlayer = game.Players.LocalPlayer;
local ItemData = game.ReplicatedStorage.GetItemData:InvokeServer();

local SyncedData = {};
function GetSyncData(DataName) 
	if SyncedData[DataName] == nil then
		SyncedData[DataName] = game.ReplicatedStorage.GetSyncData:InvokeServer(DataName);
	end
	return SyncedData[DataName];
end
game.ReplicatedStorage.UpdateSyncedData.OnClientEvent:connect(function(DataName,Data)
	SyncedData[DataName] = Data;
end)

local Emojis = GetSyncData("Emojis");

if _G.Messages == nil then
	_G.Messages = {};
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

if _G["Emojis"] == nil then
	_G["Emojis"] = true;
end

MainGUI.DisableEmoji.MouseButton1Click:connect(function()
	_G["Emojis"] = not _G["Emojis"];
	Update();
end)

function Update()
	ChatFrame:ClearAllChildren()
	if #_G.Messages > 10 then
		table.remove(_G.Messages,1)
	end
	for Index,MessageTable in pairs(ReverseTable(_G.Messages)) do
		local NewChatFrame;
		if not Phone then
			NewChatFrame = script.ChatMessage:Clone();
		else
			NewChatFrame = script.ChatMessageP:Clone();
		end
		NewChatFrame.Parent = ChatFrame;
		if MessageTable["Name"] ~= "Server" then
			NewChatFrame.CodeName.Text = MessageTable["Name"] .. ": ";
			NewChatFrame.CodeName.TextColor3 = MessageTable["Color"];
			local EmojiCount = 0;
			local Message = MessageTable["Message"];
			if MessageTable["Emojis"] and _G["Emojis"] then
				local NewMessage = Message;
				for Emoji,ImageID in pairs(Emojis) do
					repeat
						local Stop = false;
						Message = string.gsub(Message,Emoji,function()
							if not Stop and EmojiCount < 6 then
								Stop = true;
								local Start,End = string.find(Message,Emoji);
								local StringForBounds = string.sub(Message,1,Start);
								local BoundGetter = NewChatFrame.Message:Clone();
								BoundGetter.Text = StringForBounds;
								BoundGetter.Parent = NewChatFrame;
								local TextBoundsX = BoundGetter.TextBounds.X;
								BoundGetter:Destroy();
								local NewEmoji = script.Emoji:Clone();
								NewEmoji.Image = "http://www.roblox.com/asset/?id=" .. ImageID;
								NewEmoji.Position = UDim2.new(0,NewChatFrame.CodeName.TextBounds.X+TextBoundsX,0.5,-9);
								NewEmoji.Parent = NewChatFrame;
								EmojiCount = EmojiCount + 1;
								return "       ";
							end;
						end)
					until string.find(Message,Emoji) == nil or EmojiCount >= 6;
				end
				NewChatFrame.Message.Position = UDim2.new(0,NewChatFrame.CodeName.TextBounds.X+7,0,0);
				NewChatFrame.Message.Text = Message;
			else		
				NewChatFrame.Message.Position = UDim2.new(0,NewChatFrame.CodeName.TextBounds.X+7,0,0);
				NewChatFrame.Message.Text = MessageTable["Message"];
			end;
		else
			NewChatFrame.CodeName.Text = MessageTable["Message"];
			NewChatFrame.CodeName.TextColor3 = Color3.new(230/255,230/255,230/255);
			if MessageTable["ItemName"] ~= nil then
				--if ItemData[MessageTable["ItemName"]] ~= nil then
					NewChatFrame.CodeName.Font = Enum.Font.SourceSans;
					NewChatFrame.Message.Font = Enum.Font.SourceSansBold;
					NewChatFrame.Message.Position = UDim2.new(0,NewChatFrame.CodeName.TextBounds.X+5,0,0);
					NewChatFrame.Message.Text = MessageTable["ItemName"];
					NewChatFrame.Message.TextColor3 = MessageTable.RarityColor;
				--[[else 
					NewChatFrame.CodeName.Font = Enum.Font.SourceSans;
					NewChatFrame.Message.Font = Enum.Font.SourceSansBold;
					NewChatFrame.Message.Position = UDim2.new(0,NewChatFrame.CodeName.TextBounds.X+5,0,0);
					NewChatFrame.Message.Text = ChallengeTitles[MessageTable["ItemName"]
					NewChatFrame.Message.TextColor3 = ChallengeColors[MessageTable["ItemName"]
				end;]]
			else
				NewChatFrame.Message.Visible = false;
			end
		end
		NewChatFrame.Position = UDim2.new(0,0,1,-NewChatFrame.Size.Y.Offset*(Index-1));
	end
	
end

game.ReplicatedStorage.Chatted.OnClientEvent:connect(function(TalkingPlayer,Message,ItemTable,HasEmoji,DisguisesSetting)
	local ItemName = ItemTable.ItemName;
	local RarityColor = ItemTable.RarityColor;
	if TalkingPlayer ~= "Server" then
		local PlayerData = game.ReplicatedStorage.GetPlayerData:InvokeServer();
		local TalkingPlayerData = PlayerData[TalkingPlayer.Name];
		
		local SendMessage;
		
		local MessageName;
		local MessageColor;
		
		if TalkingPlayerData ~= nil then
			if TalkingPlayerData["Dead"] == false and DisguisesSetting == true then
				MessageName = TalkingPlayerData["CodeName"];
				MessageColor = TalkingPlayerData["Color"].Color;
			else
				MessageName = TalkingPlayer.Name;
				local _,_,Elite = game.ReplicatedStorage.GetPlayerLevel:InvokeServer(TalkingPlayer)
				if not Elite then
					MessageColor = BrickColor.new("Medium stone grey").Color;
				else
					MessageColor = Color3.new(232/255,42/255,42/255);
					MessageName = "[ELITE] " .. MessageName;
				end
			end
		else
			MessageName = TalkingPlayer.Name;
			local _,_,Elite = game.ReplicatedStorage.GetPlayerLevel:InvokeServer(TalkingPlayer)
			if not Elite then
				MessageColor = BrickColor.new("Medium stone grey").Color;
			else
				MessageColor = Color3.new(232/255,42/255,42/255);
				MessageName = "[ELITE] " .. MessageName;
			end
		end
		
		if PlayerData[LocalPlayer.Name] ~= nil then
			if PlayerData[LocalPlayer.Name]["Dead"] == true then
				SendMessage = true;
			else
				if TalkingPlayerData ~= nil then
					if TalkingPlayerData["Dead"] == true then
						SendMessage = false;
					else
						SendMessage = true;
					end
				else
					SendMessage = false;
				end
			end
		else
			SendMessage = true;
		end
				
		if SendMessage then
			table.insert(_G.Messages,
				{
					["Name"] = MessageName;
					["Color"] = MessageColor;
					["Message"] = Message;
				}
			);
		end;
	else
		table.insert(_G.Messages,
				{
					["Name"] = "Server";
					["Color"] = Color3.new(255,255,0);
					["Message"] = Message;
					["ItemName"] = ItemName;
					["RarityColor"] = RarityColor;
				}
		);
		
	end
	Update();
end)

Update();











