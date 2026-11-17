-- Brainrot Bazaar: walks a model along waypoints.
-- Models are Anchored part assemblies moved with PivotTo, so no physics is
-- involved and the walk is the same on every server.

local RunService = game:GetService("RunService")

local Walker = {}

-- Walks `model` from its current pivot through `points` (Vector3) at
-- `speed` studs per second, facing its direction of travel. Calls `onDone`
-- when it arrives. Returns a function that cancels the walk.
function Walker.walk(model, points, speed, onDone)
	local cancelled = false
	local connection
	local current = 1
	local pivot = model:GetPivot()
	local target = points[1]

	local function step(dt)
		if cancelled then
			return
		end
		if not target then
			if connection then
				connection:Disconnect()
			end
			if onDone then
				onDone()
			end
			return
		end
		local pos = pivot.Position
		local toTarget = target - pos
		toTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
		local distance = toTarget.Magnitude
		local move = speed * dt
		if distance <= math.max(move, 0.05) then
			pivot = CFrame.new(target.X, pivot.Position.Y, target.Z)
			current += 1
			target = points[current]
		else
			local dir = toTarget.Unit
			local nextPos = pos + dir * move
			local look = CFrame.lookAt(nextPos, nextPos + dir)
			pivot = CFrame.new(nextPos.X, pivot.Position.Y, nextPos.Z) * look.Rotation
		end
		model:PivotTo(pivot)
	end

	connection = RunService.Heartbeat:Connect(step)

	return function()
		cancelled = true
		if connection then
			connection:Disconnect()
		end
	end
end

-- Places a model standing on a surface: its root sits STAND_OFFSET above it.
function Walker.placeOn(model, position, surfaceY)
	model:PivotTo(CFrame.new(position.X, surfaceY + 2.3, position.Z))
end

return Walker
