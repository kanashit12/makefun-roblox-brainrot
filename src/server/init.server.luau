-- Brainrot Bazaar: server bootstrap.
-- Builds the remotes, claims stalls, loads saves, wires the buttons and
-- starts every system: conveyor, economy, stealing, waves, autosave.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local Game = require(script.Parent:WaitForChild("Game"))
local StallLayout = require(script.Parent:WaitForChild("StallLayout"))
local Conveyor = require(script.Parent:WaitForChild("Conveyor"))
local Economy = require(script.Parent:WaitForChild("Economy"))
local Steal = require(script.Parent:WaitForChild("Steal"))
local Wave = require(script.Parent:WaitForChild("Wave"))
local Save = require(script.Parent:WaitForChild("Save"))

print("[Brainrot Bazaar] starting v" .. tostring(Defs.GAME_VERSION))

-- Folders for the models the game creates at runtime.
local beltFolder = Instance.new("Folder")
beltFolder.Name = "BeltItems"
beltFolder.Parent = Workspace

local stallFolder = Instance.new("Folder")
stallFolder.Name = "StallModels"
stallFolder.Parent = Workspace

-- The wave itself: a big translucent wall, parked under the map until needed.
local wavePart = Instance.new("Part")
wavePart.Name = "TsunamiWave"
wavePart.Size = Vector3.new(12, 30, 260)
wavePart.Color = Color3.fromRGB(60, 140, 255)
wavePart.Material = Enum.Material.Glass
wavePart.Transparency = 0.35
wavePart.Anchored = true
wavePart.CanCollide = false
wavePart.CanQuery = false
wavePart.CFrame = CFrame.new(0, -50, 0)
wavePart.Parent = Workspace

-- Remotes.
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
for _, name in ipairs({ "StateUpdate", "Announce", "RebirthRequest", "SlapRequest" }) do
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
end

-- Stall state + the sign above each stall.
for i = 1, Defs.CONFIG.StallCount do
	Game.Stalls[i] = {
		Owner = nil,
		Center = StallLayout.stallCenter(i),
	}
end

local function updateStallSign(stallIndex)
	local world = Workspace:FindFirstChild("World")
	if not world then
		return
	end
	local sign = world:FindFirstChild("Sign" .. tostring(stallIndex))
	if not sign then
		return
	end
	local gui = sign:FindFirstChild("StallSignGui")
	if not gui then
		gui = Instance.new("SurfaceGui")
		gui.Name = "StallSignGui"
		-- North stalls (1-4) face the belt from -Z, so their sign reads from +Z;
		-- south stalls (5-8) are the other way round.
		gui.Face = stallIndex <= 4 and Enum.NormalId.Back or Enum.NormalId.Front
		gui.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "Text"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Parent = gui
	end
	local stall = Game.Stalls[stallIndex]
	local label = gui:FindFirstChild("Text")
	if stall and stall.Owner then
		local owner = Players:GetPlayerByUserId(stall.Owner)
		label.Text = "STALL " .. tostring(stallIndex) .. "\n" .. (owner and owner.DisplayName or "???")
	else
		label.Text = "STALL " .. tostring(stallIndex) .. "\n(empty)"
	end
end

for i = 1, Defs.CONFIG.StallCount do
	task.spawn(function()
		task.wait(1)
		updateStallSign(i)
	end)
end

-- Wire the systems together.
Conveyor.setup(beltFolder)
Economy.setup(remotes)
Steal.setup(Economy, Conveyor)
Wave.setup(Economy, Conveyor, Steal, wavePart)

remotes.RebirthRequest.OnServerEvent:Connect(function(player)
	Economy.tryRebirth(player)
end)

remotes.SlapRequest.OnServerEvent:Connect(function(player)
	Steal.trySlap(player)
end)

local function onPlayerAdded(player)
	local stallIndex = Game.claimFreeStall(player.UserId)
	if not stallIndex then
		player:Kick("Brainrot Bazaar is full (8 stalls). Try again later!")
		return
	end
	local state = Game.newPlayerState(player, stallIndex)
	Game.Players[player.UserId] = state

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = Defs.CONFIG.StartingCoins
	coins.Parent = leaderstats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	Save.load(player, state)
	coins.Value = math.floor(state.Coins)
	rebirths.Value = state.Rebirths
	updateStallSign(stallIndex)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			if state.Carrying then
				Steal.returnCarried(state)
			end
		end)
	end)

	task.delay(2, function()
		if player.Parent then
			Economy.announce(player, "Welcome to Brainrot Bazaar! Click a brainrot on the belt to buy it. Your stall is #" .. tostring(stallIndex) .. ".", "info")
			Economy.pushState(player)
		end
	end)
end

local function onPlayerRemoving(player)
	local state = Game.Players[player.UserId]
	if not state then
		return
	end
	if state.Carrying then
		Steal.returnCarried(state)
	end
	Save.save(player, state)
	for _, brainrot in pairs(state.Slots) do
		if brainrot and brainrot.Model then
			brainrot.Model:Destroy()
		end
	end
	Game.freeStall(state.StallIndex)
	Game.Players[player.UserId] = nil
	updateStallSign(state.StallIndex)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Conveyor.start()
Economy.start()
Wave.start()
Save.startAutosave()

print("[Brainrot Bazaar] ready: " .. tostring(Defs.CONFIG.StallCount) .. " stalls, " .. tostring(#Defs.CHARACTERS) .. " brainrots")
