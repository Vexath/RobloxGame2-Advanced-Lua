local PassFaces = require(game.ServerStorage.Faces)
local Data = require(game.ServerScriptService.GameScript.DataModule);

local Module = function(Player,Color,RoleName,Map,CodeName)
	game.ReplicatedStorage.RoleSelect:FireClient(Player,RoleName,Color,CodeName,false,"Classic");
end

return Module;
