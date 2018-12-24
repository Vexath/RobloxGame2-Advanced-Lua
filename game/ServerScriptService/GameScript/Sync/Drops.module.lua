local Boxes = {
	
	
	DropCountChance = {33,50,0};
	
	DropTree = {
		
		--[[["Christmas"] = {
			Type = "Materials";
			Chance = {25,0,0};
			DropTable = {
				
				["SkateboardParts"] = {
					Amount = {1,1};
					Chance = 5;
				};
				
				["BasketballParts"] = {
					Amount = {1,1};
					Chance = 29;
				};
				
				["GameSystemParts"] = {
					Amount = {1,1};
					Chance = 1;
				};
				
				["ActionFigureParts"] = {
					Amount = {1,1};
					Chance = 12;
				};
				
				["WrappingPaperRed"] = {
					Amount = {1,1};
					Chance = 52;
				};
				
				
			};
		};]]
		
		
		["Feathers"] = {
			Type = "Materials";
			Chance = {0,100,0};
			DropTable = {
				["CommonFeathers"]={Amount={1,3};Chance=6000;};
				["UncommonFeathers"]={Amount={1,3};Chance=2500;};
				["RareFeathers"]={Amount={1,2};Chance=1000;};
				["LegendaryFeathers"]={Amount={1,1};Chance=500;};
				["GodlyFeathers"]={Amount={1,1};Chance=1;};
			};
		};
		["Cloth"] = {
			Type = "Materials";
			Chance = {100,0,0};
			DropTable = {
				["CommonCloth"]={Amount={1,2};Chance=6000;};
				["UncommonCloth"]={Amount={1,2};Chance=2500;};
				["RareCloth"]={Amount={1,2};Chance=1000;};
				["LegendaryCloth"]={Amount={1,1};Chance=500;};
				["GodlyCloth"]={Amount={1,1};Chance=1;};
				
				
			};
		};
		
		--[[["Weapons"] = {
			Type = "Weapons";
			Chance = {0,5,0};
			DropTabale = {
				
			};
		};]]
	};
	
	
	

	
};


return Boxes;
