local Module = {
	
	["Common"] = {
		CountChance = {100,33,0};
		Rewards = {
			["CommonFeathers"] = {
				Amount = {1,3};
				Rarity = {100,0,0};
			};
			["CommonCloth"] = {
				Amount = {1,2};
				Rarity = {0,100,0};
			};
			
			--[["BasketballParts"] = {
				Amount = {1,1};
				Rarity = {0,100,0};
			};
			
			["CommonBlade"] = {
				Amount = {1,1};
				Rarity = {0,0,100};
			};]]
		};
	};
	
	["Uncommon"] = {
		CountChance = {100,33,0};
		Rewards = {
			["UncommonFeathers"] = {
				Amount = {1,3};
				Rarity = {100,0,0};
			};
			["UncommonCloth"] = {
				Amount = {1,2};
				Rarity = {0,100,0};
			};
			--[[["ActionFigureParts"] = {
				Amount = {1,1};
				Rarity = {0,100,0};
			};]]
		};
	};
	
	
	["Rare"] = {
		CountChance = {100,33,0};
		Rewards = {
			["RareFeathers"] = {
				Amount = {2,3};
				Rarity = {100,0,0};
			};
			["RareCloth"] = {
				Amount = {1,2};
				Rarity = {0,100,0};
			};
			--[[["SkateboardParts"] = {
				Amount = {1,1};
				Rarity = {0,100,0};
			};]]
		};
	};
	
	["Legendary"] = {
		CountChance = {100,33,0};
		Rewards = {
			["LegendaryFeathers"] = {
				Amount = {2,2};
				Rarity = {100,0,0};
			};
			["LegendaryCloth"] = {
				Amount = {1,2};
				Rarity = {0,100,0};
			};
			--[[["GameSystemParts"] = {
				Amount = {1,1};
				Rarity = {0,100,0};
			};]]
		};
	};
	
	["Godly"] = {
		CountChance = {100,0,0};
		Rewards = {
			["GodlyFeathers"] = {
				Amount = {1,1};
				Rarity = {100,0,0};
			};
		};
	};
	["WrapPaperBoxPurple"] = {
		CountChance = {100,0,0};
		Rewards = {
			["WrappingPaperPurple"] = {
				Amount = {5,5};
				Rarity = {100,0,0};
			};
		};
	};
	["WrapPaperBoxGold"] = {
		CountChance = {100,0,0};
		Rewards = {
			["WrappingPaperGold"] = {
				Amount = {5,5};
				Rarity = {100,0,0};
			};
		};
	};
	
};

return Module;
