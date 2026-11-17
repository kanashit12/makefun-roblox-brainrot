-- Brainrot Bazaar: the HUD.
-- One ScreenGui over the 3D world: coins and income top-centre (clear of
-- Roblox's own menu buttons in the top-left corner), the wave timer and the
-- rebirth button top-right, your brainrots bottom-left, hints bottom-centre,
-- announcements in the middle.

local HUD = {}

local function label(name, parent, text, size, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size
	l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	l.TextStrokeTransparency = 0
	l.Font = Enum.Font.GothamBold
	l.Parent = parent
	return l
end

local function panel(name, parent, size, position, anchor)
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = position
	f.AnchorPoint = anchor or Vector2.new(0, 0)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	f.BackgroundTransparency = 0.35
	f.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = f
	f.Parent = parent
	return f
end

function HUD.build(playerGui)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	-- Coins, top-centre.
	local coinsPanel = panel("Coins", gui, UDim2.fromOffset(300, 76), UDim2.new(0.5, 0, 0, 12), Vector2.new(0.5, 0))
	local coinsLabel = label("Coins", coinsPanel, "$200", 30, Color3.fromRGB(255, 220, 80))
	coinsLabel.Size = UDim2.fromScale(1, 0.6)
	coinsLabel.Position = UDim2.fromScale(0, 0.02)
	local incomeLabel = label("Income", coinsPanel, "$0/s", 18, Color3.fromRGB(140, 230, 150))
	incomeLabel.Size = UDim2.fromScale(1, 0.35)
	incomeLabel.Position = UDim2.fromScale(0, 0.58)

	-- Wave timer + rebirth, top-right.
	local wavePanel = panel("Wave", gui, UDim2.fromOffset(230, 46), UDim2.new(1, -12, 0, 12), Vector2.new(1, 0))
	local waveLabel = label("Wave", wavePanel, "Next wave: --", 18, Color3.fromRGB(140, 200, 255))
	waveLabel.Size = UDim2.fromScale(1, 1)

	local rebirthButton = Instance.new("TextButton")
	rebirthButton.Name = "Rebirth"
	rebirthButton.Size = UDim2.fromOffset(230, 52)
	rebirthButton.Position = UDim2.new(1, -12, 0, 66)
	rebirthButton.AnchorPoint = Vector2.new(1, 0)
	rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 60, 200)
	rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirthButton.TextSize = 18
	rebirthButton.Font = Enum.Font.GothamBold
	rebirthButton.Text = "REBIRTH"
	local rebirthCorner = Instance.new("UICorner")
	rebirthCorner.CornerRadius = UDim.new(0, 10)
	rebirthCorner.Parent = rebirthButton
	rebirthButton.Parent = gui

	-- Your brainrots, bottom-left.
	local ownedPanel = panel("Owned", gui, UDim2.fromOffset(280, 190), UDim2.new(0, 12, 1, -12), Vector2.new(0, 1))
	local ownedTitle = label("Title", ownedPanel, "Your Brainrots (0/6)", 18, Color3.fromRGB(255, 255, 255))
	ownedTitle.Size = UDim2.new(1, -16, 0, 28)
	ownedTitle.Position = UDim2.fromOffset(8, 6)
	ownedTitle.TextXAlignment = Enum.TextXAlignment.Left
	local ownedList = label("List", ownedPanel, "Buy brainrots from the belt!", 15, Color3.fromRGB(220, 220, 220))
	ownedList.Size = UDim2.new(1, -16, 1, -40)
	ownedList.Position = UDim2.fromOffset(8, 36)
	ownedList.TextXAlignment = Enum.TextXAlignment.Left
	ownedList.TextYAlignment = Enum.TextYAlignment.Top
	ownedList.TextWrapped = true
	ownedList.Font = Enum.Font.Gotham

	-- Hint, bottom-centre.
	local hintLabel = label("Hint", gui, "Click a brainrot on the belt to buy it  |  Click a rival's brainrot to steal it  |  E = slap", 16)
	hintLabel.Size = UDim2.new(0.9, 0, 0, 28)
	hintLabel.Position = UDim2.new(0.5, 0, 1, -40)
	hintLabel.AnchorPoint = Vector2.new(0.5, 1)

	-- Announcement, centre (hidden until used).
	local announceLabel = label("Announce", gui, "", 26, Color3.fromRGB(255, 220, 80))
	announceLabel.Size = UDim2.new(0.8, 0, 0, 40)
	announceLabel.Position = UDim2.new(0.5, 0, 0.25, 0)
	announceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	announceLabel.Visible = false

	return {
		Gui = gui,
		Coins = coinsLabel,
		Income = incomeLabel,
		Wave = waveLabel,
		Rebirth = rebirthButton,
		OwnedTitle = ownedTitle,
		OwnedList = ownedList,
		Announce = announceLabel,
	}
end

return HUD
