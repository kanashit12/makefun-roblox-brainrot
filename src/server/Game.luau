-- Brainrot Bazaar: the server's shared game state.
-- One table per player, the stall map, and the belt. No gameplay logic here,
-- only state and the small helpers every system needs.

local Defs = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Defs"))

local Game = {}

Game.Players = {} -- [userId] = playerState
Game.Stalls = {} -- [stallIndex] = { Owner = userId | nil, Center = Vector3, Slots = { Vector3, ... } }
Game.Belt = {} -- [itemId] = beltItem
Game.NextItemId = 1
Game.WaveActive = false
Game.WaveWarnUntil = 0
Game.NextWaveAt = 0

function Game.newPlayerState(player, stallIndex)
	return {
		Player = player,
		UserId = player.UserId,
		Coins = Defs.CONFIG.StartingCoins,
		Rebirths = 0,
		StallIndex = stallIndex,
		-- [slotIndex] = brainrot | nil; brainrot = { Id, DefId, Mutation, Model, Slot }
		Slots = {},
		Carrying = nil, -- brainrot stolen from someone else, held overhead
		CarryingFrom = nil, -- { OwnerUserId, SlotIndex } the carried one came from
		LastStealAt = 0,
		LastSlapAt = 0,
		JoinedAt = os.time(),
	}
end

function Game.getState(player)
	if typeof(player) == "number" then
		return Game.Players[player]
	end
	return Game.Players[player.UserId]
end

function Game.multiplier(state)
	return Defs.rebirthMultiplier(state.Rebirths)
end

function Game.incomePerSecond(state)
	local total = 0
	for _, brainrot in pairs(state.Slots) do
		if brainrot then
			local char = Defs.getCharacter(brainrot.DefId)
			if char then
				total += Defs.baseIncome(char, brainrot.Mutation)
			end
		end
	end
	return total * Game.multiplier(state)
end

function Game.ownedCount(state)
	local n = 0
	for _, brainrot in pairs(state.Slots) do
		if brainrot then
			n += 1
		end
	end
	return n
end

function Game.firstFreeSlot(state)
	for i = 1, Defs.CONFIG.SlotsPerStall do
		if state.Slots[i] == nil then
			return i
		end
	end
	return nil
end

function Game.nextItemId()
	local id = Game.NextItemId
	Game.NextItemId += 1
	return id
end

-- Stall helpers. Stall centres and slot positions are filled in by
-- init.server.luau from the world the Rojo project builds.
function Game.claimFreeStall(userId)
	for i = 1, Defs.CONFIG.StallCount do
		local stall = Game.Stalls[i]
		if stall and stall.Owner == nil then
			stall.Owner = userId
			return i
		end
	end
	return nil
end

function Game.freeStall(stallIndex)
	local stall = Game.Stalls[stallIndex]
	if stall then
		stall.Owner = nil
	end
end

function Game.stallOf(userId)
	local state = Game.Players[userId]
	if not state then
		return nil
	end
	return Game.Stalls[state.StallIndex]
end

function Game.isInsideOwnStall(player)
	local state = Game.getState(player)
	if not state then
		return false
	end
	local stall = Game.Stalls[state.StallIndex]
	if not stall then
		return false
	end
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	local p = root.Position
	local c = stall.Center
	-- Stalls are 24 wide (x) by 20 deep (z).
	return math.abs(p.X - c.X) <= 12 and math.abs(p.Z - c.Z) <= 10
end

return Game
