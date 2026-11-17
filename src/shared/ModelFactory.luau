-- Brainrot Bazaar: builds the little 3D character models from Defs.
-- Every model is a Model with a transparent Root part (PrimaryPart), a Body,
-- a Head with two eyes, and one accessory. No external assets: every part is
-- a plain Roblox part, so the place needs no asset ids at all.

local Defs = require(script.Parent:WaitForChild("Defs"))

local ModelFactory = {}

local BODY_SIZES = {
	Block = Vector3.new(2.4, 2.6, 1.6),
	Tall = Vector3.new(2, 3.6, 1.4),
	Ball = Vector3.new(2.6, 2.6, 2.6),
	Wide = Vector3.new(3.4, 1.8, 2),
}

local BODY_SHAPES = {
	Block = Enum.PartType.Block,
	Tall = Enum.PartType.Block,
	Ball = Enum.PartType.Ball,
	Wide = Enum.PartType.Block,
}

local function newPart(name, size, color, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	return part
end

local function addAccessory(model, kind, color)
	if kind == "None" then
		return
	end
	if kind == "TopHat" then
		local brim = newPart("HatBrim", Vector3.new(1.8, 0.15, 1.8), Color3.fromRGB(30, 30, 30), Enum.PartType.Cylinder)
		brim.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, 0, math.rad(90))
		brim.Parent = model
		local top = newPart("HatTop", Vector3.new(1.2, 1.2, 1.2), Color3.fromRGB(30, 30, 30), Enum.PartType.Cylinder)
		top.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 3.2, 0) * CFrame.Angles(0, 0, math.rad(90))
		top.Parent = model
	elseif kind == "Crown" then
		local band = newPart("Crown", Vector3.new(1.5, 0.5, 1.5), Color3.fromRGB(255, 215, 0), Enum.PartType.Cylinder)
		band.Material = Enum.Material.Metal
		band.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
		band.Parent = model
		for i = 1, 3 do
			local spike = newPart("CrownSpike", Vector3.new(0.3, 0.5, 0.3), Color3.fromRGB(255, 215, 0))
			spike.CFrame = model.PrimaryPart.CFrame * CFrame.new(-0.5 + (i - 1) * 0.5, 2.9, 0)
			spike.Parent = model
		end
	elseif kind == "Shades" then
		for _, x in ipairs({ -0.4, 0.4 }) do
			local lens = newPart("Shade", Vector3.new(0.7, 0.4, 0.15), Color3.fromRGB(15, 15, 15))
			lens.CFrame = model.PrimaryPart.CFrame * CFrame.new(x, 1.9, 0.85)
			lens.Parent = model
		end
	elseif kind == "ChefHat" then
		local puff = newPart("ChefHat", Vector3.new(1.6, 1, 1.6), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
		puff.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 2.9, 0)
		puff.Parent = model
	elseif kind == "Headphones" then
		for _, x in ipairs({ -1, 1 }) do
			local cup = newPart("Headphone", Vector3.new(0.35, 0.8, 0.8), color)
			cup.CFrame = model.PrimaryPart.CFrame * CFrame.new(x, 1.9, 0)
			cup.Parent = model
		end
		local band = newPart("HeadphoneBand", Vector3.new(2.1, 0.2, 0.4), color)
		band.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 2.45, 0)
		band.Parent = model
	elseif kind == "PartyHat" then
		local cone = newPart("PartyHat", Vector3.new(0.9, 1.3, 0.9), Color3.fromRGB(255, 110, 200))
		cone.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
		cone.Parent = model
	elseif kind == "Cape" then
		local cape = newPart("Cape", Vector3.new(2.2, 2.6, 0.2), Color3.fromRGB(180, 30, 50))
		cape.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 0.9, -0.95)
		cape.Parent = model
	end
end

-- Builds a character model. `mutationName` may be "None".
-- The model is NOT parented; the caller parents and positions it with PivotTo.
function ModelFactory.build(char, mutationName)
	local mutation = Defs.getMutation(mutationName or "None") or Defs.getMutation("None")
	local bodyColor = char.Color
	if mutation.Color then
		bodyColor = mutation.Color
	end

	local model = Instance.new("Model")
	model.Name = char.Name

	local root = newPart("Root", Vector3.new(2.4, 4.6, 1.6), bodyColor)
	root.Transparency = 1
	root.CanQuery = true
	model.PrimaryPart = root
	root.Parent = model

	local bodySize = BODY_SIZES[char.Body] or BODY_SIZES.Block
	local body = newPart("Body", bodySize, bodyColor, BODY_SHAPES[char.Body])
	if mutation.Name == "Diamond" then
		body.Material = Enum.Material.Glass
	elseif mutation.Name == "Lava" then
		body.Material = Enum.Material.Neon
	end
	body.CFrame = CFrame.new(0, 0.4, 0)
	body.Parent = model

	local head = newPart("Head", Vector3.new(1.7, 1.5, 1.5), bodyColor, Enum.PartType.Ball)
	head.CFrame = CFrame.new(0, 2.1, 0)
	head.Parent = model

	for _, x in ipairs({ -0.4, 0.4 }) do
		local eye = newPart("Eye", Vector3.new(0.28, 0.4, 0.15), Color3.fromRGB(20, 20, 20), Enum.PartType.Ball)
		eye.CFrame = CFrame.new(x, 2.2, 0.8)
		eye.Parent = model
	end

	addAccessory(model, char.Accessory, bodyColor)

	if mutation.Name == "Rainbow" or mutation.Name == "Lava" then
		local light = Instance.new("PointLight")
		light.Color = mutation.Color or Color3.fromRGB(255, 255, 255)
		light.Range = 8
		light.Brightness = 1
		light.Parent = root
	end

	-- Click targets on every big part, so clicking anywhere on the character
	-- works: the server wires MouseClick for buy / steal on each of them.
	for _, part in ipairs({ root, body, head }) do
		local click = Instance.new("ClickDetector")
		click.MaxActivationDistance = 32
		click.Parent = part
	end

	-- Floating name tag: name, rarity colour, income.
	local tag = Instance.new("BillboardGui")
	tag.Name = "BrainrotTag"
	tag.Size = UDim2.fromOffset(140, 56)
	tag.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
	tag.AlwaysOnTop = false
	tag.Parent = root

	local rarity = Defs.getRarity(char.Rarity)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.fromScale(1, 0.55)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = char.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = tag

	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "Sub"
	subLabel.Position = UDim2.fromScale(0, 0.55)
	subLabel.Size = UDim2.fromScale(1, 0.45)
	subLabel.BackgroundTransparency = 1
	local mutationText = mutation.Name == "None" and "" or (" " .. mutation.Name)
	subLabel.Text = char.Rarity .. mutationText .. "  |  " .. Defs.formatMoney(Defs.baseIncome(char, mutation.Name)) .. "/s"
	subLabel.TextColor3 = rarity and rarity.Color or Color3.fromRGB(255, 255, 255)
	subLabel.TextStrokeTransparency = 0
	subLabel.TextScaled = true
	subLabel.Font = Enum.Font.Gotham
	subLabel.Parent = tag

	return model
end

return ModelFactory
