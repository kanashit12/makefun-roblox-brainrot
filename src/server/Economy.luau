-- Brainrot Bazaar: money.
-- Every second each player's stalled brainrots pay out, times the rebirth
-- multiplier, straight into their coins. Rebirth resets coins and brainrots
-- for a permanent income multiplier. The server also pushes a state snapshot
-- to every client once a second so the HUD never guesses.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local Game = require(script.Parent:WaitForChild("Game"))

local Economy = {}

local remotes = nil

function Economy.setup(remotesFolder)
	remotes = remotesFolder
end

local function pushState(player, state)
	if not remotes then
		return
	end
	local event = remotes:FindFirstChild("StateUpdate")
	if not event then
		return
	end
	-- Owned is a plain array (sequential keys): sparse numeric keys do not
	-- survive a RemoteEvent, so each entry carries its own slot number.
	local owned = {}
	for slot, brainrot in pairs(state.Slots) do
		if brainrot then
			local char = Defs.getCharacter(brainrot.DefId)
			if char then
				table.insert(owned, {
					Slot = slot,
					Name = char.Name,
					Rarity = char.Rarity,
					Mutation = brainrot.Mutation,
					Income = Defs.baseIncome(char, brainrot.Mutation),
				})
			end
		end
	end
	table.sort(owned, function(a, b)
		return a.Slot < b.Slot
	end)
	event:FireClient(player, {
		Coins = math.floor(state.Coins),
		IncomePerSecond = Game.incomePerSecond(state),
		Rebirths = state.Rebirths,
		Multiplier = Game.multiplier(state),
		RebirthCost = Defs.rebirthCost(state.Rebirths),
		Owned = owned,
		SlotsUsed = Game.ownedCount(state),
		SlotsTotal = Defs.CONFIG.SlotsPerStall,
		WaveWarn = Game.WaveActive,
		NextWaveIn = math.max(0, math.floor(Game.NextWaveAt - os.time())),
	})
end

function Economy.pushState(player)
	local state = Game.getState(player)
	if state then
		pushState(player, state)
	end
end

function Economy.announce(player, text, kind)
	if not remotes then
		return
	end
	local event = remotes:FindFirstChild("Announce")
	if event then
		event:FireClient(player, { Text = text, Kind = kind or "info" })
	end
end

function Economy.announceAll(text, kind)
	for _, player in ipairs(Players:GetPlayers()) do
		Economy.announce(player, text, kind)
	end
end

function Economy.start()
	task.spawn(function()
		while true do
			task.wait(Defs.CONFIG.IncomeTickSeconds)
			for _, player in ipairs(Players:GetPlayers()) do
				local state = Game.getState(player)
				if state then
					state.Coins += Game.incomePerSecond(state)
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local coins = leaderstats:FindFirstChild("Coins")
						if coins then
							coins.Value = math.floor(state.Coins)
						end
					end
					pushState(player, state)
				end
			end
		end
	end)
end

-- The rebirth button calls this. Returns true + new level, or false + reason.
function Economy.tryRebirth(player)
	local state = Game.getState(player)
	if not state then
		return false, "no state"
	end
	if state.Rebirths >= Defs.CONFIG.MaxRebirths then
		return false, "max rebirths"
	end
	local cost = Defs.rebirthCost(state.Rebirths)
	if state.Coins < cost then
		return false, "need " .. Defs.formatMoney(cost)
	end
	state.Coins = 0
	state.Rebirths += 1
	-- Clear the stall: every brainrot is sold back to the bazaar.
	for slot, brainrot in pairs(state.Slots) do
		if brainrot and brainrot.Model then
			brainrot.Model:Destroy()
		end
		state.Slots[slot] = nil
	end
	if state.Carrying then
		-- A carried brainrot goes home to its real owner, not the void.
		local Steal = require(script.Parent:WaitForChild("Steal"))
		Steal.returnCarried(state)
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = 0
		end
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		if rebirths then
			rebirths.Value = state.Rebirths
		end
	end
	pushState(player, state)
	Economy.announce(player, "REBIRTH! Income is now x" .. tostring(Game.multiplier(state)) .. " forever.", "good")
	return true, state.Rebirths
end

return Economy
