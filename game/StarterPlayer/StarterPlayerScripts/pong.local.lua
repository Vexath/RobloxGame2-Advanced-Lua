-- stupid pong
repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local lPad = game.Workspace.Lobby.pongLeft
local rPad = game.Workspace.Lobby.pongRight
local paddle = game.Workspace.Lobby.PongScreen.SurfaceGui.Paddle
local ball = game.Workspace.Lobby.PongScreen.SurfaceGui.Ball
local scoreT = game.Workspace.Lobby.PongScreen.SurfaceGui.Score
local highscoreT = game.Workspace.Lobby.PongScreen.SurfaceGui.Highscore
local gameOverT = game.Workspace.Lobby.PongScreen.SurfaceGui.GameOver

local gameInProgress = false
local touchLeft = false
local touchRight = false

local xFactor = 8
local yFactor = 8
local xDir = 1
local yDir = 1

local xMaxBounds = 600 - 30
local xMinBounds = 20

local yMaxBounds = 430 - 30
local yMinBounds = 0

local canStartGame = true

lPad.Touched:connect(function(part)
	if part.Parent == player.Character and canStartGame then
		if not gameInProgress then
			startGame()
		end
		gameInProgress = true
		touchRight = false
		touchLeft = true
	end
end)

lPad.TouchEnded:connect(function(part)
	if part.Parent == player.Character and canStartGame then
		touchLeft = false
	end
end)
rPad.TouchEnded:connect(function(part)
	if part.Parent == player.Character and canStartGame then
		touchRight = false
	end
end)

rPad.Touched:connect(function(part)
	if part.Parent == player.Character and canStartGame then
		if not gameInProgress then
			startGame()
		end
		gameInProgress = true
		touchLeft = false
		touchRight = true
	end
end)

function endGame()
	
	canStartGame = false
	gameOverT.Visible = true
	wait(3)
	gameOverT.Visible = false
	paddle.Position = UDim2.new(0, 0,0, 155)
	ball.Position = UDim2.new(0,200,0,math.random(20,370))
	xFactor = 8
	yFactor = 8
	xDir = 1
	yDir = 1
	canStartGame = true
	scoreT.Text = 0
end

--game.ReplicatedStorage.Remotes.PongHighscore.OnClientEvent:connect(function(plr, score)
	
--end)
local highscore = 0

function startGame()
	local score = 0
	scoreT.Text = score
	coroutine.wrap(function()
		while wait() do
			if gameInProgress then
				if touchRight then
					paddle.Position = UDim2.new(0,0,0,paddle.Position.Y.Offset - 12)
					if paddle.Position.Y.Offset <= 0 then
						paddle.Position = UDim2.new(0,0,0,0)
					end
				elseif touchLeft then
					paddle.Position = UDim2.new(0,0,0,paddle.Position.Y.Offset + 12)
					if paddle.Position.Y.Offset >= 310 then
						paddle.Position = UDim2.new(0,0,0,310)
					end
				end
			
				if ball.Position.X.Offset >= xMaxBounds or ball.Position.X.Offset <= xMinBounds then
					if ball.Position.X.Offset <= xMinBounds then
						if ball.Position.Y.Offset + 30 >= paddle.Position.Y.Offset and ball.Position.Y.Offset <= paddle.Position.Y.Offset + 120 then
							xDir = xDir * -1
							score = score + 1
							scoreT.Text = score
						else
							-- game over
							gameInProgress = false
							endGame()
							if score > highscore then
								highscore = score
								highscoreT.Text = "Highscore - "..score.." "
							end
							return
						end
					else
						xDir = xDir * -1
					end
				
				end
				if ball.Position.Y.Offset >= yMaxBounds or ball.Position.Y.Offset <= yMinBounds then
					yDir = yDir * -1
				end
				ball.Position = UDim2.new(0,ball.Position.X.Offset + xFactor * xDir, 0, ball.Position.Y.Offset + yFactor * yDir)
			end
		end
	end)()
end
