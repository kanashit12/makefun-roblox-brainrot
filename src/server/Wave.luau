-- Brainrot Bazaar: the Tsunami of Nonsense.
-- Every few minutes the game warns the map, then a giant wave sweeps across
-- the island from west to east. Anyone caught outside their own stall is
-- flung back to spawn and stunned for a few seconds, drops anything they were
-- carrying, and every brainrot still riding the belt is washed away.
-- Your stall is the only safe ground.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local Game = require(script.Parent:WaitForChild("Game"))

local Wave = {}

local Economy = nil
local Conveyor = nil
local Steal = nil
local wavePart = nil

function Wave.setup(economyModule, conveyorModule, stealModule, part)
	Economy = economyModule
	Conveyor = conveyorModule
	Steal = stealModule
	wavePart = part
end

local function stun(player, seconds)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local oldSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	task.delay(seconds, function()
		if humanoid.Parent then
			humanoid.WalkSpeed = oldSpeed
		end
	end)
end

local function fling(player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	-- Back to spawn, facing the bazaar.
	root.CFrame = CFrame.new(0, 3, 70) * CFrame.Angles(0, math.pi, 0)
	stun(player, 3)
end

function Wave.runOnce()
	Game.WaveActive = true
	if Economy then
		Economy.announceAll("🌊 TSUNAMI OF NONSENSE! Get to your stall!", "bad")
	end
	Conveyor.clearBelt()
	-- Sweep the wave across the map.
	local startX = -130
	local endX = 130
	local elapsed = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local t = math.clamp(elapsed / Defs.CONFIG.WaveSweepSeconds, 0, 1)
		local x = startX + (endX - startX) * t
		if wavePart then
			wavePart.CFrame = CFrame.new(x, 8, 0)
		end
		-- Anyone the wave has passed who is not home gets flung.
		for _, player in ipairs(Players:GetPlayers()) do
			local state = Game.getState(player)
			if state and not Game.isInsideOwnStall(player) then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and root.Position.X < x + 6 then
					if state.Carrying then
						Steal.returnCarried(state)
					end
					fling(player)
					if Economy then
						Economy.announce(player, "The wave got you! Back to spawn.", "bad")
					end
				end
			end
		end
		if t >= 1 then
			connection:Disconnect()
			if wavePart then
				wavePart.CFrame = CFrame.new(0, -50, 0) -- parked under the map
			end
			Game.WaveActive = false
			Game.NextWaveAt = os.time() + Defs.CONFIG.WaveEverySeconds
			if Economy then
				Economy.announceAll("The wave has passed. The bazaar is open again!", "good")
			end
		end
	end)
end

function Wave.start()
	Game.NextWaveAt = os.time() + Defs.CONFIG.WaveEverySeconds
	task.spawn(function()
		while true do
			local waitFor = math.max(1, Game.NextWaveAt - os.time() - Defs.CONFIG.WaveWarnSeconds)
			task.wait(waitFor)
			if Economy then
				Economy.announceAll("🌊 A wave is coming in " .. Defs.CONFIG.WaveWarnSeconds .. "s! Get to your stall!", "bad")
			end
			task.wait(Defs.CONFIG.WaveWarnSeconds)
			local ok, err = pcall(Wave.runOnce)
			if not ok then
				warn("[Brainrot Bazaar] wave failed: " .. tostring(err))
				Game.WaveActive = false
				Game.NextWaveAt = os.time() + Defs.CONFIG.WaveEverySeconds
			end
		end
	end)
end

return Wave
