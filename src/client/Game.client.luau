-- Brainrot Bazaar: client bootstrap.
-- Builds the HUD, listens for the server's once-a-second state snapshot and
-- announcements, and sends the two things the player can ask for: rebirth
-- (the button) and slap (the E key).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local HUD = require(script.Parent:WaitForChild("HUD"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateEvent = remotes:WaitForChild("StateUpdate")
local announceEvent = remotes:WaitForChild("Announce")
local rebirthEvent = remotes:WaitForChild("RebirthRequest")
local slapEvent = remotes:WaitForChild("SlapRequest")

local hud = HUD.build(playerGui)

local announceUntil = 0

local function showAnnounce(text, kind)
	local color = Color3.fromRGB(255, 220, 80)
	if kind == "good" then
		color = Color3.fromRGB(140, 230, 150)
	elseif kind == "bad" then
		color = Color3.fromRGB(255, 110, 110)
	end
	hud.Announce.Text = text
	hud.Announce.TextColor3 = color
	hud.Announce.Visible = true
	announceUntil = os.clock() + 4
	task.delay(4, function()
		if os.clock() >= announceUntil then
			hud.Announce.Visible = false
		end
	end)
end

stateEvent.OnClientEvent:Connect(function(state)
	hud.Coins.Text = Defs.formatMoney(state.Coins)
	hud.Income.Text = Defs.formatMoney(state.IncomePerSecond) .. "/s  (x" .. tostring(state.Multiplier) .. ")"
	if state.WaveWarn then
		hud.Wave.Text = "WAVE INCOMING!"
		hud.Wave.TextColor3 = Color3.fromRGB(255, 110, 110)
	else
		hud.Wave.Text = "Next wave: " .. tostring(state.NextWaveIn) .. "s"
		hud.Wave.TextColor3 = Color3.fromRGB(140, 200, 255)
	end
	hud.Rebirth.Text = "REBIRTH x" .. tostring(state.Multiplier * 2) .. "  (" .. Defs.formatMoney(state.RebirthCost) .. ")"
	hud.OwnedTitle.Text = "Your Brainrots (" .. tostring(state.SlotsUsed) .. "/" .. tostring(state.SlotsTotal) .. ")"
	local lines = {}
	for _, owned in ipairs(state.Owned or {}) do
		local mutation = owned.Mutation ~= "None" and (" [" .. owned.Mutation .. "]") or ""
		table.insert(lines, owned.Name .. mutation .. "  -  " .. Defs.formatMoney(owned.Income) .. "/s")
	end
	if #lines == 0 then
		hud.OwnedList.Text = "Buy brainrots from the belt!"
	else
		hud.OwnedList.Text = table.concat(lines, "\n")
	end
end)

announceEvent.OnClientEvent:Connect(function(data)
	showAnnounce(data.Text, data.Kind)
end)

hud.Rebirth.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.E then
		slapEvent:FireServer()
	end
end)
