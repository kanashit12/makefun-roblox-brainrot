-- Brainrot Bazaar: the map layout, as numbers.
-- MUST match default.project.json, which builds the same stalls, belt and
-- spawn in the 3D world. Stall i's centre and its six slot positions live
-- here so the server can place brainrots on them.

local StallLayout = {}

StallLayout.STAND_OFFSET = 2.3 -- model root height above the surface it stands on
StallLayout.BELT_TOP_Y = 1.5
StallLayout.SLOT_TOP_Y = 1.2

StallLayout.STALL_CENTERS = {
	Vector3.new(-75, 0, -35),
	Vector3.new(-25, 0, -35),
	Vector3.new(25, 0, -35),
	Vector3.new(75, 0, -35),
	Vector3.new(-75, 0, 35),
	Vector3.new(-25, 0, 35),
	Vector3.new(25, 0, 35),
	Vector3.new(75, 0, 35),
}

-- Six slots per stall: two rows of three, local offsets from the centre.
StallLayout.SLOT_OFFSETS = {
	Vector3.new(-7, 0, -5),
	Vector3.new(0, 0, -5),
	Vector3.new(7, 0, -5),
	Vector3.new(-7, 0, 5),
	Vector3.new(0, 0, 5),
	Vector3.new(7, 0, 5),
}

function StallLayout.slotPosition(stallIndex, slotIndex)
	local center = StallLayout.STALL_CENTERS[stallIndex]
	local offset = StallLayout.SLOT_OFFSETS[slotIndex]
	return Vector3.new(center.X + offset.X, StallLayout.SLOT_TOP_Y, center.Z + offset.Z)
end

function StallLayout.stallCenter(stallIndex)
	return StallLayout.STALL_CENTERS[stallIndex]
end

return StallLayout
