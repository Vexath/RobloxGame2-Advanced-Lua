local Pads = game.Workspace.VoteIcons:GetChildren();

for i = 1,#Pads do
	if Pads[i]:IsA("BasePart") and string.sub(Pads[i].Name,1,1) == "V" then
		local PlayersTouching = {}
		
		--[[function CheckTable(Player)
			for e = 1,#PlayersTouching do
				if PlayersTouching[e] == Player then
					return true;
				end
			end
			return false;
		end
		
		function FindTable(Player)
			for e = 1,#PlayersTouching do
				if PlayersTouching[e] == Player then
					return e;
				end
			end
			return nil;
		end]]
		
		Pads[i].Votes.Changed:connect(function()
			Pads[i].MapInfo.Surface.Frame.Votes.Text = Pads[i].Votes.Value
			Pads[i].MapInfo.Surface.Frame.Votes.Text = "Votes: " .. Pads[i].Votes.Value;
		end)
		
		
		Pads[i].Map.Changed:connect(function()
			if Pads[i].Map.Value ~= nil then
				Pads[i].MapInfo.Surface.Frame.MapName.Text = Pads[i].Map.Value.Name;
				Pads[i].MapInfo.Surface.Frame.MapName.Text = Pads[i].Map.Value.Name
				if Pads[i].Map.Value:FindFirstChild("IconSq") then
					Pads[i].Surface.Background.Image = Pads[i].Map.Value.IconSq.Texture;
				end
			end
		end)
		
		Pads[i].Voting.Changed:connect(function()
			if Pads[i].Voting.Value then
				Pads[i].Surface.Enabled = true;
				Pads[i].MapInfo.Surface.Frame.Votes.Text = "Votes: 0";
				Pads[i].MapInfo.Surface.Enabled = true; 
			else
				Pads[i].MapInfo.Surface.Enabled = false;
				Pads[i].Surface.Enabled = false;
			end
		end)
		
		local Pad = Pads[i]
		local Detector = script.Parent["Detector" .. string.sub(Pads[i].Name,string.len(Pads[i].Name))];
		local Region = Region3.new(Detector.Position-Detector.Size/2,(Detector.Position+Detector.Size/2)+Vector3.new(0,10,0))
		local Total = 0;
		
		local newThread = coroutine.create(function()
		    while wait(0.1) do
				local Total = 0;
				local Parts = game.Workspace:FindPartsInRegion3(Region,nil,100)
				for e = 1,#Parts do
					if Parts[e].Name == "Torso" or Parts[e].Name == "UpperTorso" then
						local TorsoOffset1 = Detector.CFrame:toObjectSpace( Parts[e].CFrame );
						if math.abs(TorsoOffset1.x ) <= Detector.Size.x / 2 and math.abs( TorsoOffset1.z ) <= Detector.Size.z / 2 then
							Total = Total + 1
						end
					end
				end
				Pad.Votes.Value = Total;
			end
		end)
		 
		coroutine.resume(newThread)

		
		--[[Pads[i].Touched:connect(function(hit)
			local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if Player and not CheckTable(Player) then
				table.insert(PlayersTouching,Player)
				Pads[i].Votes.Value = Pads[i].Votes.Value + 1
			end
		end)
		
		Pads[i].TouchEnded:connect(function(hit)
			local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if Player and CheckTable(Player) then
				table.remove(PlayersTouching,FindTable(Player))
				Pads[i].Votes.Value = Pads[i].Votes.Value - 1
			end
		end)]]
	end
end