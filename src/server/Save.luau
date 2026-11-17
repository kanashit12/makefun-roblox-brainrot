-- Brainrot Bazaar: saving.
-- Coins and rebirths save to a DataStore; brainrots save as (def, mutation)
-- pairs per slot and are rebuilt on join. Everything is pcall-guarded: in
-- Studio, or anywhere DataStores are off, the game just plays session-only
-- and says so once in the output instead of breaking.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local Game = require(script.Parent:WaitForChild("Game"))
local ModelFactory = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModelFactory"))
local StallLayout = require(script.Parent:WaitForChild("StallLayout"))
local Walker = require(script.Parent:WaitForChild("Walker"))

local Save = {}

local store = nil
local warned = false

local function getStore()
	if store ~= nil then
		return store
	end
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("BrainrotBazaar")
	end)
	if ok then
		store = result
	else
		if not warned then
			warned = true
			warn("[Brainrot Bazaar] DataStores unavailable, playing session-only: " .. tostring(result))
		end
		store = false
	end
	return store
end

function Save.load(player, state)
	local db = getStore()
	if not db then
		return
	end
	local key = Defs.CONFIG.SaveKeyPrefix .. tostring(player.UserId)
	local ok, data = pcall(function()
		return db:GetAsync(key)
	end)
	if not ok or type(data) ~= "table" then
		return
	end
	if type(data.Coins) == "number" then
		state.Coins = math.max(0, math.floor(data.Coins))
	end
	if type(data.Rebirths) == "number" then
		state.Rebirths = math.clamp(math.floor(data.Rebirths), 0, Defs.CONFIG.MaxRebirths)
	end
	-- Rebuild saved brainrots into their slots.
	if type(data.Slots) == "table" then
		local Steal = require(script.Parent:WaitForChild("Steal"))
		for slotIndex, saved in pairs(data.Slots) do
			slotIndex = tonumber(slotIndex)
			if slotIndex and slotIndex >= 1 and slotIndex <= Defs.CONFIG.SlotsPerStall then
				local char = saved and Defs.getCharacter(saved.DefId)
				if char then
					local mutation = Defs.getMutation(saved.Mutation) and saved.Mutation or "None"
					local model = ModelFactory.build(char, mutation)
					model.Parent = workspace:FindFirstChild("StallModels") or workspace
					local brainrot = {
						Id = Game.nextItemId(),
						DefId = char.Id,
						Mutation = mutation,
						Model = model,
						Slot = slotIndex,
					}
					state.Slots[slotIndex] = brainrot
					local slotPos = StallLayout.slotPosition(state.StallIndex, slotIndex)
					Walker.placeOn(model, slotPos, StallLayout.SLOT_TOP_Y)
					Steal.wireStealClicks(state, brainrot)
				end
			end
		end
	end
end

function Save.save(player, state)
	local db = getStore()
	if not db then
		return
	end
	local slots = {}
	for slotIndex, brainrot in pairs(state.Slots) do
		if brainrot then
			slots[tostring(slotIndex)] = { DefId = brainrot.DefId, Mutation = brainrot.Mutation }
		end
	end
	local data = {
		Coins = math.floor(state.Coins),
		Rebirths = state.Rebirths,
		Slots = slots,
		SavedAt = os.time(),
	}
	local key = Defs.CONFIG.SaveKeyPrefix .. tostring(player.UserId)
	local ok, err = pcall(function()
		db:SetAsync(key, data)
	end)
	if not ok then
		warn("[Brainrot Bazaar] save failed for " .. player.Name .. ": " .. tostring(err))
	end
end

-- Autosave every 60s, plus on leave (called from init.server.luau).
function Save.startAutosave()
	task.spawn(function()
		while true do
			task.wait(60)
			for _, player in ipairs(Players:GetPlayers()) do
				local state = Game.getState(player)
				if state then
					Save.save(player, state)
				end
			end
		end
	end)
end

return Save
