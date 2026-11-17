-- Brainrot Bazaar: the conveyor belt.
-- Brainrots roll for a rarity and a mutation, ride the belt from the spawn
-- gate to the exit, and any player who clicks one (and can afford it, and has
-- a free stall slot) buys it: it walks off the belt to their stall.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local ModelFactory = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModelFactory"))
local Game = require(script.Parent:WaitForChild("Game"))
local StallLayout = require(script.Parent:WaitForChild("StallLayout"))
local Walker = require(script.Parent:WaitForChild("Walker"))
local Steal = require(script.Parent:WaitForChild("Steal"))

local Conveyor = {}

local beltFolder = nil -- Folder "BeltItems" under Workspace, made by init

function Conveyor.setup(folder)
	beltFolder = folder
end

local function beltCount()
	local n = 0
	for _ in pairs(Game.Belt) do
		n += 1
	end
	return n
end

local function wireBuyClicks(model, item)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("ClickDetector") then
			descendant.MouseClick:Connect(function(player)
				Conveyor.tryBuy(player, item.Id)
			end)
		end
	end
end

local function spawnOne()
	if beltCount() >= Defs.CONFIG.MaxOnBelt then
		return
	end
	local char = Defs.rollCharacter()
	local mutation = Defs.rollMutation()
	local id = Game.nextItemId()
	local model = ModelFactory.build(char, mutation)
	model.Parent = beltFolder
	Walker.placeOn(model, Vector3.new(Defs.CONFIG.BeltStartX, 0, Defs.CONFIG.BeltZ), Defs.CONFIG.BeltY)
	local item = {
		Id = id,
		DefId = char.Id,
		Mutation = mutation,
		Model = model,
		X = Defs.CONFIG.BeltStartX,
	}
	Game.Belt[id] = item
	wireBuyClicks(model, item)
end

function Conveyor.start()
	-- The belt itself: items ride +X until the exit, then wash away.
	RunService.Heartbeat:Connect(function(dt)
		for id, item in pairs(Game.Belt) do
			if not item.Model.Parent then
				Game.Belt[id] = nil
			else
				item.X += Defs.CONFIG.BeltSpeed * dt
				if item.X >= Defs.CONFIG.BeltEndX then
					item.Model:Destroy()
					Game.Belt[id] = nil
				else
					item.Model:PivotTo(CFrame.new(item.X, Defs.CONFIG.BeltY + StallLayout.STAND_OFFSET, Defs.CONFIG.BeltZ))
				end
			end
		end
	end)

	-- Spawner.
	task.spawn(function()
		while true do
			task.wait(Defs.CONFIG.SpawnIntervalSeconds)
			if not Game.WaveActive then
				local ok, err = pcall(spawnOne)
				if not ok then
					warn("[Brainrot Bazaar] spawn failed: " .. tostring(err))
				end
			end
		end
	end)
end

-- Sweeps every belt item away (the wave does this).
function Conveyor.clearBelt()
	for id, item in pairs(Game.Belt) do
		if item.Model then
			item.Model:Destroy()
		end
		Game.Belt[id] = nil
	end
end

function Conveyor.tryBuy(player, itemId)
	local state = Game.getState(player)
	if not state then
		return false, "no state"
	end
	local item = Game.Belt[itemId]
	if not item then
		return false, "gone"
	end
	local char = Defs.getCharacter(item.DefId)
	if not char then
		return false, "unknown"
	end
	if state.Coins < char.Cost then
		return false, "too expensive"
	end
	local slot = Game.firstFreeSlot(state)
	if not slot then
		return false, "stall full"
	end
	-- Take it off the belt first, so a double click cannot sell it twice.
	Game.Belt[itemId] = nil
	state.Coins -= char.Cost

	local brainrot = {
		Id = item.Id,
		DefId = item.DefId,
		Mutation = item.Mutation,
		Model = item.Model,
		Slot = slot,
	}
	state.Slots[slot] = brainrot

	-- Walk it home: belt -> stall front -> its slot.
	local stallCenter = StallLayout.stallCenter(state.StallIndex)
	local slotPos = StallLayout.slotPosition(state.StallIndex, slot)
	local model = item.Model
	local start = model:GetPivot().Position
	brainrot.CancelWalk = Walker.walk(model, {
		Vector3.new(start.X, Defs.CONFIG.BeltY, stallCenter.Z),
		Vector3.new(stallCenter.X, Defs.CONFIG.BeltY, stallCenter.Z + 14),
		Vector3.new(slotPos.X, Defs.CONFIG.BeltY, slotPos.Z),
	}, 14, function()
		brainrot.CancelWalk = nil
		Walker.placeOn(model, slotPos, StallLayout.SLOT_TOP_Y)
		-- From here on, rivals can steal it by clicking it.
		Steal.wireStealClicks(state, brainrot)
	end)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = math.floor(state.Coins)
		end
	end
	return true, brainrot
end

-- Hands a brainrot record back to the belt systems (used by Steal on return).
function Conveyor.returnToSlot(ownerState, brainrot)
	local slot = brainrot.Slot
	if ownerState.Slots[slot] ~= nil and ownerState.Slots[slot] ~= brainrot then
		slot = Game.firstFreeSlot(ownerState)
		if not slot then
			return false
		end
		brainrot.Slot = slot
	end
	ownerState.Slots[slot] = brainrot
	local slotPos = StallLayout.slotPosition(ownerState.StallIndex, slot)
	brainrot.CancelWalk = Walker.walk(brainrot.Model, {
		Vector3.new(slotPos.X, Defs.CONFIG.BeltY, slotPos.Z),
	}, 14, function()
		brainrot.CancelWalk = nil
		Walker.placeOn(brainrot.Model, slotPos, StallLayout.SLOT_TOP_Y)
	end)
	return true
end

return Conveyor
