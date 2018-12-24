local ScoreFrame = script.Parent.ScoreFrame
local Events = game.ReplicatedStorage.Events
local DisplayScore = Events.DisplayScore
local Player = game.Players.LocalPlayer
local CTFDisplay = Events.CTFDisplay
local sound = script.score

local function ToggleDisplay(toggle)
	if toggle == true then
		ScoreFrame.Visible = true
	else
		ScoreFrame.Visible = false
	end
	
end

local function OnScoreChange(team, score)
	sound:Play()
	if team == "Red" then
		ScoreFrame.Red.Text = score
	end 
	if team == "Blue" then
		ScoreFrame.Blue.Text = score
	end
end

CTFDisplay.OnClientEvent:connect(ToggleDisplay)

DisplayScore.OnClientEvent:connect(OnScoreChange)