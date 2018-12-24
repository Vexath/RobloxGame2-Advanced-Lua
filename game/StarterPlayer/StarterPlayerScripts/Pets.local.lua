repeat wait(); until _G.PlayerData ~= nil;
wait(0.2);

local PetsDB = game.ReplicatedStorage.GetSyncData:InvokeServer("Pets");

local Pets = game.ReplicatedStorage.Pets;
game:GetService("RunService"):BindToRenderStep("Pets",1000,function()
	for _,Character in pairs(game.Workspace:GetChildren()) do
		local Pet = Character:FindFirstChild("Pet");
		if Pet and Pet:IsA("StringValue") then
			local PetID = Pet.Value;
			if Pets:FindFirstChild(PetID) then
				local PetPart = Pet:FindFirstChild("PetPart");
				if not PetPart then
					local PetPart = Pets[PetID]:Clone();
					PetPart.Name = "PetPart";
					PetPart.Parent = Pet	
					PetPart.CanCollide = false
					PetPart.Anchored = false
					PetPart.CFrame = Character.Head.CFrame
					local NameTag = game.ReplicatedStorage.NameTag:Clone();
					NameTag.Tag.Text = (Pet.PetName.Value~="" and not game:GetService("UserInputService").GamepadEnabled and Pet.PetName.Value) or PetsDB[PetID].Name;
					NameTag.StudsOffset = Vector3.new(0,2,0);
					NameTag.Parent = PetPart;
					local BodyPosition = Instance.new("BodyPosition", PetPart)
					while Character.Pet:FindFirstChild("PetPart") do
						PetPart.BodyPosition.Position = Character.Head.CFrame:pointToWorldSpace(Vector3.new(2, 1, 0))
						PetPart.CFrame = CFrame.new(PetPart.CFrame.p, PetPart.CFrame.p + Character.HumanoidRootPart.CFrame.lookVector)
						wait()
					end
				end
			end
		end	
	end
end);