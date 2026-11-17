-- Brainrot Bazaar: stealing.
-- Click a brainrot on someone else's stall to snatch it and carry it home:
-- it only becomes yours when you reach your own stall with it. The owner can
-- slap you (press E nearby) to knock it loose, and if you die or leave, it
-- walks straight back to its owner's stall.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Defs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Defs"))
local Game = require(script.Parent:WaitForChild("Game"))
local StallLayout = require(script.Parent:WaitForChild("StallLayout"))

local Steal = {}

local Economy = nil -- set in setup (avoids a load-time require cycle)
local Conveyor = nil

function Steal.setup(economyModule, conveyorModule)
	Economy = economyModule
	Conveyor = conveyorModule
end

local function characterRoot(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Sends a carried brainrot home to its real owner.
function Steal.returnCarried(carrierState)
	local brainrot = carrierState.Carrying
	local from = carrierState.CarryingFrom
	carrierState.Carrying = nil
	carrierState.CarryingFrom = nil
	if carrierState.CarryConnection then
		carrierState.CarryConnection:Disconnect()
		carrierState.CarryConnection = nil
	end
	if not brainrot or not from then
		return
	end
	local ownerState = Game.Players[from.OwnerUserId]
	if not ownerState then
		if brainrot.Model then
			brainrot.Model:Destroy()
		end
		return
	end
	Conveyor.returnToSlot(ownerState, brainrot)
end

local function startCarryLoop(carrierState)
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local brainrot = carrierState.Carrying
		local player = carrierState.Player
		if not brainrot or not brainrot.Model or not brainrot.Model.Parent then
			if connection then
				connection:Disconnect()
			end
			carrierState.CarryConnection = nil
			return
		end
		local root = characterRoot(player)
		if not root then
			return
		end
		-- Overhead, bobbing gently.
		local bob = math.sin(os.clock() * 4) * 0.3
		local pos = root.Position + Vector3.new(0, Defs.CONFIG.StealCarryHeight + bob, 0)
		brainrot.Model:PivotTo(CFrame.new(pos))
		-- Home? The stall's front edge counts: inside the stall bounds.
		if Game.isInsideOwnStall(player) then
			connection:Disconnect()
			carrierState.CarryConnection = nil
			Steal.completeSteal(carrierState)
		end
	end)
	carrierState.CarryConnection = connection
end

function Steal.completeSteal(carrierState)
	local brainrot = carrierState.Carrying
	local from = carrierState.CarryingFrom
	carrierState.Carrying = nil
	carrierState.CarryingFrom = nil
	if not brainrot then
		return
	end
	local slot = Game.firstFreeSlot(carrierState)
	if not slot then
		-- Nowhere to put it: it goes home.
		local ownerState = from and Game.Players[from.OwnerUserId]
		if ownerState then
			Conveyor.returnToSlot(ownerState, brainrot)
		elseif brainrot.Model then
			brainrot.Model:Destroy()
		end
		if Economy then
			Economy.announce(carrierState.Player, "Your stall is full! The brainrot ran home.", "bad")
		end
		return
	end
	brainrot.Slot = slot
	carrierState.Slots[slot] = brainrot
	local slotPos = StallLayout.slotPosition(carrierState.StallIndex, slot)
	brainrot.Model:PivotTo(CFrame.new(slotPos.X, StallLayout.SLOT_TOP_Y + StallLayout.STAND_OFFSET, slotPos.Z))
	-- Rivals can now steal it from its new owner.
	Steal.wireStealClicks(carrierState, brainrot)
	if Economy then
		local char = Defs.getCharacter(brainrot.DefId)
		Economy.announce(carrierState.Player, "STOLE " .. (char and char.Name or "a brainrot") .. "! It is yours now.", "good")
		if from then
			local owner = Players:GetPlayerByUserId(from.OwnerUserId)
			if owner then
				Economy.announce(owner, carrierState.Player.DisplayName .. " stole your " .. (char and char.Name or "brainrot") .. "!", "bad")
			end
		end
	end
end

-- Wire a stalled brainrot's click detectors so rivals can steal it.
function Steal.wireStealClicks(ownerState, brainrot)
	local model = brainrot.Model
	if not model then
		return
	end
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("ClickDetector") then
			descendant.MouseClick:Connect(function(player)
				Steal.trySteal(player, ownerState, brainrot)
			end)
		end
	end
end

function Steal.trySteal(player, ownerState, brainrot)
	local thiefState = Game.getState(player)
	if not thiefState or not ownerState then
		return false
	end
	if ownerState.UserId == thiefState.UserId then
		return false -- your own brainrot: clicking it does nothing
	end
	if thiefState.Carrying then
		return false -- one at a time
	end
	if ownerState.Slots[brainrot.Slot] ~= brainrot then
		return false -- already gone
	end
	if os.clock() - thiefState.LastStealAt < Defs.CONFIG.StealCooldownSeconds then
		return false
	end
	thiefState.LastStealAt = os.clock()
	-- Stop any walk it was on (e.g. still walking home after a buy).
	if brainrot.CancelWalk then
		brainrot.CancelWalk()
		brainrot.CancelWalk = nil
	end
	ownerState.Slots[brainrot.Slot] = nil
	thiefState.Carrying = brainrot
	thiefState.CarryingFrom = { OwnerUserId = ownerState.UserId, SlotIndex = brainrot.Slot }
	startCarryLoop(thiefState)
	if Economy then
		Economy.announce(player, "Run! Get it to your stall before they slap you!", "info")
		local owner = Players:GetPlayerByUserId(ownerState.UserId)
		if owner then
			local char = Defs.getCharacter(brainrot.DefId)
			Economy.announce(owner, player.DisplayName .. " grabbed your " .. (char and char.Name or "brainrot") .. "! Press E near them to slap it loose!", "bad")
		end
	end
	return true
end

-- E key: knock a carried brainrot loose if the thief is close and it is yours.
function Steal.trySlap(player)
	local state = Game.getState(player)
	if not state then
		return false
	end
	if os.clock() - state.LastSlapAt < 1 then
		return false
	end
	state.LastSlapAt = os.clock()
	local myRoot = characterRoot(player)
	if not myRoot then
		return false
	end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local thiefState = Game.getState(other)
			if thiefState and thiefState.Carrying and thiefState.CarryingFrom then
				if thiefState.CarryingFrom.OwnerUserId == state.UserId then
					local thiefRoot = characterRoot(other)
					if thiefRoot and (thiefRoot.Position - myRoot.Position).Magnitude <= Defs.CONFIG.SlapRange then
						Steal.returnCarried(thiefState)
						if Economy then
							Economy.announce(player, "SLAP! Your brainrot is coming home.", "good")
							Economy.announce(other, "SLAPPED! You dropped the brainrot.", "bad")
						end
						return true
					end
				end
			end
		end
	end
	return false
end

return Steal
