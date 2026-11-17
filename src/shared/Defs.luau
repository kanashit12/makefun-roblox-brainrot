-- Brainrot Bazaar: shared definitions.
-- Every character, rarity, mutation and tuning number the whole game uses.
-- Original characters and names, made for this game.

local Defs = {}

Defs.GAME_NAME = "Brainrot Bazaar"
Defs.GAME_VERSION = 1

Defs.CONFIG = {
	-- Economy
	StartingCoins = 200,
	IncomeTickSeconds = 1,
	CostPerIncome = 90, -- a brainrot costs ~90 seconds of its own income
	-- Conveyor
	SpawnIntervalSeconds = 4,
	MaxOnBelt = 12,
	BeltSpeed = 6, -- studs per second
	BeltStartX = -90,
	BeltEndX = 90,
	BeltZ = 0,
	BeltY = 1.5,
	-- Stalls
	SlotsPerStall = 6,
	StallCount = 8,
	-- Steal
	StealCarryHeight = 5,
	SlapRange = 10,
	StealCooldownSeconds = 5,
	-- Wave
	WaveEverySeconds = 240,
	WaveWarnSeconds = 30,
	WaveSweepSeconds = 6,
	-- Rebirth
	RebirthBaseCost = 50000,
	RebirthCostGrowth = 2,
	RebirthMultiplierPerLevel = 2,
	MaxRebirths = 10,
	-- Data
	SaveKeyPrefix = "BrainrotBazaar_v1_",
}

Defs.RARITIES = {
	{ Name = "Common", Weight = 40, Color = Color3.fromRGB(170, 170, 170), IncomeScale = 1 },
	{ Name = "Rare", Weight = 27, Color = Color3.fromRGB(80, 160, 255), IncomeScale = 1 },
	{ Name = "Epic", Weight = 17, Color = Color3.fromRGB(170, 90, 255), IncomeScale = 1 },
	{ Name = "Legendary", Weight = 10, Color = Color3.fromRGB(255, 190, 40), IncomeScale = 1 },
	{ Name = "Mythic", Weight = 5, Color = Color3.fromRGB(255, 80, 180), IncomeScale = 1 },
	{ Name = "Brainrot God", Weight = 1, Color = Color3.fromRGB(255, 60, 60), IncomeScale = 1 },
}

Defs.MUTATIONS = {
	{ Name = "None", Weight = 60, Multiplier = 1, Color = nil },
	{ Name = "Golden", Weight = 25, Multiplier = 2, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Diamond", Weight = 10, Multiplier = 5, Color = Color3.fromRGB(140, 230, 255) },
	{ Name = "Rainbow", Weight = 4, Multiplier = 10, Color = Color3.fromRGB(255, 110, 220) },
	{ Name = "Lava", Weight = 1, Multiplier = 25, Color = Color3.fromRGB(255, 90, 30) },
}

-- 24 original characters. Income is coins per second on a base, before
-- mutation and rebirth multipliers. Cost is derived: Income * CostPerIncome.
Defs.CHARACTERS = {
	-- Common
	{ Id = "baron-noodle", Name = "Baron von Noodle", Rarity = "Common", Income = 8, Color = Color3.fromRGB(240, 210, 130), Body = "Block", Accessory = "TopHat", Blurb = "A noodle with a title and no manners." },
	{ Id = "captain-croissant", Name = "Captain Croissant", Rarity = "Common", Income = 12, Color = Color3.fromRGB(230, 170, 90), Body = "Wide", Accessory = "ChefHat", Blurb = "Sails the seven butters." },
	{ Id = "dj-pickle", Name = "DJ Pickle", Rarity = "Common", Income = 18, Color = Color3.fromRGB(110, 200, 90), Body = "Tall", Accessory = "Headphones", Blurb = "Drops beats. Drops brine. Never both." },
	{ Id = "sir-barksalot", Name = "Sir Barksalot", Rarity = "Common", Income = 25, Color = Color3.fromRGB(200, 140, 80), Body = "Block", Accessory = "Cape", Blurb = "Knighted for barking at the mailman." },
	-- Rare
	{ Id = "prof-banana-peel", Name = "Professor Banana Peel", Rarity = "Rare", Income = 40, Color = Color3.fromRGB(250, 225, 60), Body = "Tall", Accessory = "TopHat", Blurb = "Slipped into a PhD." },
	{ Id = "turbo-toaster", Name = "Turbo Toaster", Rarity = "Rare", Income = 55, Color = Color3.fromRGB(200, 200, 210), Body = "Block", Accessory = "None", Blurb = "Burns bread at Mach 2." },
	{ Id = "agent-avocado", Name = "Agent Avocado", Rarity = "Rare", Income = 70, Color = Color3.fromRGB(120, 180, 80), Body = "Ball", Accessory = "Shades", Blurb = "Licensed to guac." },
	{ Id = "queen-quokka", Name = "Queen Quokka", Rarity = "Rare", Income = 90, Color = Color3.fromRGB(190, 150, 110), Body = "Block", Accessory = "Crown", Blurb = "The happiest monarch alive." },
	-- Epic
	{ Id = "count-spaghetti", Name = "Count Spaghetti", Rarity = "Epic", Income = 130, Color = Color3.fromRGB(250, 200, 120), Body = "Tall", Accessory = "Cape", Blurb = "Counts noodles. Never sleeps." },
	{ Id = "dr-drumstick", Name = "Dr. Drumstick", Rarity = "Epic", Income = 180, Color = Color3.fromRGB(210, 120, 70), Body = "Block", Accessory = "Headphones", Blurb = "A doctor of drum solos." },
	{ Id = "elvis-eggplant", Name = "Elvis Eggplant", Rarity = "Epic", Income = 240, Color = Color3.fromRGB(140, 80, 180), Body = "Ball", Accessory = "Shades", Blurb = "Thank you. Thank you very much." },
	{ Id = "ninja-noodle", Name = "Ninja Noodle", Rarity = "Epic", Income = 320, Color = Color3.fromRGB(90, 90, 110), Body = "Tall", Accessory = "PartyHat", Blurb = "You never see it coming. It is pasta." },
	-- Legendary
	{ Id = "pirate-pancake", Name = "Pirate Pancake", Rarity = "Legendary", Income = 500, Color = Color3.fromRGB(235, 190, 110), Body = "Wide", Accessory = "PartyHat", Blurb = "Stacks gold. Eats maps." },
	{ Id = "wizard-waffle", Name = "Wizard Waffle", Rarity = "Legendary", Income = 700, Color = Color3.fromRGB(200, 150, 80), Body = "Block", Accessory = "TopHat", Blurb = "Syrup is a spell component." },
	{ Id = "samurai-sushi", Name = "Samurai Sushi", Rarity = "Legendary", Income = 950, Color = Color3.fromRGB(240, 130, 130), Body = "Tall", Accessory = "Headphones", Blurb = "Slices first. Asks later." },
	{ Id = "disco-duck", Name = "Disco Duck", Rarity = "Legendary", Income = 1300, Color = Color3.fromRGB(255, 220, 80), Body = "Ball", Accessory = "Shades", Blurb = "Quacks in four-on-the-floor." },
	-- Mythic
	{ Id = "giga-giraffe", Name = "Giga Giraffe", Rarity = "Mythic", Income = 1800, Color = Color3.fromRGB(240, 200, 90), Body = "Tall", Accessory = "Crown", Blurb = "Too tall for the lore." },
	{ Id = "mango-man", Name = "Mango Man", Rarity = "Mythic", Income = 2400, Color = Color3.fromRGB(255, 170, 40), Body = "Block", Accessory = "Cape", Blurb = "Sweet. Ripe. Unstoppable." },
	{ Id = "burrito-bandit", Name = "Burrito Bandit", Rarity = "Mythic", Income = 3200, Color = Color3.fromRGB(220, 180, 120), Body = "Wide", Accessory = "Shades", Blurb = "Steals beans. Leaves tips." },
	{ Id = "cosmic-cucumber", Name = "Cosmic Cucumber", Rarity = "Mythic", Income = 4500, Color = Color3.fromRGB(100, 220, 140), Body = "Ball", Accessory = "Crown", Blurb = "Cool as a... you know." },
	-- Brainrot God
	{ Id = "lord-llama-latte", Name = "Lord Llama Latte", Rarity = "Brainrot God", Income = 8000, Color = Color3.fromRGB(230, 210, 190), Body = "Tall", Accessory = "Crown", Blurb = "Foamed by destiny itself." },
	{ Id = "madame-mooncheese", Name = "Madame Mooncheese", Rarity = "Brainrot God", Income = 12000, Color = Color3.fromRGB(250, 245, 200), Body = "Ball", Accessory = "TopHat", Blurb = "The moon is 40% her." },
	{ Id = "yeti-yogurt", Name = "Yeti Yogurt", Rarity = "Brainrot God", Income = 18000, Color = Color3.fromRGB(240, 245, 255), Body = "Wide", Accessory = "ChefHat", Blurb = "Fermented in a blizzard." },
	{ Id = "zebra-zookeeper", Name = "Zebra Zookeeper", Rarity = "Brainrot God", Income = 25000, Color = Color3.fromRGB(245, 245, 245), Body = "Block", Accessory = "Cape", Blurb = "Keeps the zoo. IS the zoo." },
}

-- Derived lookups, built once.
local byId = {}
local byRarity = {}
for _, char in ipairs(Defs.CHARACTERS) do
	char.Cost = char.Income * Defs.CONFIG.CostPerIncome
	byId[char.Id] = char
	byRarity[char.Rarity] = byRarity[char.Rarity] or {}
	table.insert(byRarity[char.Rarity], char)
end

local rarityByName = {}
for _, r in ipairs(Defs.RARITIES) do
	rarityByName[r.Name] = r
end

local mutationByName = {}
for _, m in ipairs(Defs.MUTATIONS) do
	mutationByName[m.Name] = m
end

function Defs.getCharacter(id)
	return byId[id]
end

function Defs.getRarity(name)
	return rarityByName[name]
end

function Defs.getMutation(name)
	return mutationByName[name]
end

function Defs.charactersOfRarity(name)
	return byRarity[name] or {}
end

local function pickWeighted(list)
	local total = 0
	for _, entry in ipairs(list) do
		total += entry.Weight
	end
	local roll = math.random() * total
	for _, entry in ipairs(list) do
		roll -= entry.Weight
		if roll <= 0 then
			return entry
		end
	end
	return list[1]
end

function Defs.rollRarity()
	return pickWeighted(Defs.RARITIES).Name
end

function Defs.rollMutation()
	return pickWeighted(Defs.MUTATIONS).Name
end

function Defs.rollCharacter()
	local rarity = Defs.rollRarity()
	local pool = byRarity[rarity]
	return pool[math.random(1, #pool)]
end

-- Income of one owned brainrot, before the owner's rebirth multiplier.
function Defs.baseIncome(char, mutationName)
	local mutation = mutationByName[mutationName] or mutationByName.None
	return char.Income * mutation.Multiplier
end

function Defs.rebirthCost(level)
	-- Cost of the NEXT rebirth when the player already has `level` rebirths.
	return Defs.CONFIG.RebirthBaseCost * (Defs.CONFIG.RebirthCostGrowth ^ level)
end

function Defs.rebirthMultiplier(level)
	return Defs.CONFIG.RebirthMultiplierPerLevel ^ level
end

function Defs.formatMoney(n)
	n = math.floor(n + 0.5)
	if n >= 1000000000 then
		return string.format("$%.2fB", n / 1000000000)
	elseif n >= 1000000 then
		return string.format("$%.2fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n / 1000)
	else
		return "$" .. tostring(n)
	end
end

return Defs
