-- tabs/settings.lua
local Ether = getgenv().Ether
if not Ether then return end

local SettingsTab = Ether.exeTabs.SettingsTab
local EtherExecutor = Ether.EtherExecutor
local hub = Ether.hub

-- Forward declarations to prevent closure scoping bugs
local RGBModeBtn, AutoRotateBtn, RotationInput

local SettingsContent = Ether.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = SettingsTab.containerInstance })
Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SettingsContent })
Ether.Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = SettingsContent })

local VisibilitySection = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 90), BackgroundColor3 = Color3.fromRGB(35, 35, 42), BorderSizePixel = 0, LayoutOrder = 1, Parent = SettingsContent })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = VisibilitySection })
Ether.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = VisibilitySection })
Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "UI Visibility", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(0, 210, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = VisibilitySection })
local HideUIButton = Ether.Create("TextButton", { Size = UDim2.new(0, 140, 0, 32), Position = UDim2.new(0, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(200, 60, 60), Text = "Hide Main UI", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = VisibilitySection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = HideUIButton })
Ether.Create("TextLabel", { Size = UDim2.new(1, -150, 0, 32), Position = UDim2.new(0, 150, 0, 28), BackgroundTransparency = 1, Text = "Klik icon floating untuk buka lagi", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(160, 160, 170), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Parent = VisibilitySection })
HideUIButton.MouseButton1Click:Connect(function() Ether.setMainUIHidden(true) end)

local ToggleSection = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 290), BackgroundColor3 = Color3.fromRGB(35, 35, 42), BorderSizePixel = 0, LayoutOrder = 2, Parent = SettingsContent })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ToggleSection })
Ether.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = ToggleSection })

Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Toggle Button Customization", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(0, 210, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })

-- Icon
Ether.Create("TextLabel", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Text = "Icon:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })
local IconInput = Ether.Create("TextBox", { Size = UDim2.new(1, -140, 0, 26), Position = UDim2.new(0, 60, 0, 30), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = Ether.CustomIcon or "lucide:eye", PlaceholderText = "lucide:eye, solar:settings, ...", Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = IconInput })
Ether.Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = IconInput })
local IconApplyBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(1, -70, 0, 30), BackgroundColor3 = Color3.fromRGB(40, 148, 215), Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = IconApplyBtn })
IconApplyBtn.MouseButton1Click:Connect(function()
	local val = IconInput.Text
	if val and val:gsub("%s", "") ~= "" then
		Ether.CustomIcon = val
		Ether.applyToggleVisuals()
		Ether.saveToggleConfig()
		hub:Toast("Icon updated", EtherExecutor)
	end
end)

-- Stroke Mode
Ether.Create("TextLabel", { Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 66), BackgroundTransparency = 1, Text = "Stroke:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })
local SolidBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 90, 0, 66), BackgroundColor3 = Ether.ToggleButtonConfig.Gradient and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(0, 168, 255), Text = "Solid", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SolidBtn })
local GradientBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(0, 165, 0, 66), BackgroundColor3 = Ether.ToggleButtonConfig.Gradient and Color3.fromRGB(0, 168, 255) or Color3.fromRGB(50, 50, 60), Text = "Gradient", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = GradientBtn })

-- Colors
local function makeColorInput(parent, label, initialColor, yPos, onApply)
	Ether.Create("TextLabel", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 0, 0, yPos), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
	local rIn = Ether.Create("TextBox", { Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 60, 0, yPos), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(math.floor(initialColor.R * 255)), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 100, 100), ClearTextOnFocus = false, Parent = parent })
	local gIn = Ether.Create("TextBox", { Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 110, 0, yPos), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(math.floor(initialColor.G * 255)), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(100, 255, 100), ClearTextOnFocus = false, Parent = parent })
	local bIn = Ether.Create("TextBox", { Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 160, 0, yPos), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(math.floor(initialColor.B * 255)), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(100, 150, 255), ClearTextOnFocus = false, Parent = parent })
	local applyB = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 210, 0, yPos), BackgroundColor3 = Color3.fromRGB(40, 148, 215), Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = parent })
	for _, inst in ipairs({ rIn, gIn, bIn, applyB }) do Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = inst }) end
	applyB.MouseButton1Click:Connect(function()
		local r = math.clamp(tonumber(rIn.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(gIn.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(bIn.Text) or 0, 0, 255)
		onApply(Color3.fromRGB(r, g, b))
		Ether.saveToggleConfig()
	end)
end

makeColorInput(ToggleSection, "Color 1:", Ether.ToggleButtonConfig.StrokeColor, 100, function(c)
	Ether.ToggleButtonConfig.StrokeColor = c
	Ether.applyToggleVisuals()
end)

local Color2RowFrame = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 134), BackgroundTransparency = 1, Visible = Ether.ToggleButtonConfig.Gradient, Parent = ToggleSection })
makeColorInput(Color2RowFrame, "Color 2:", Ether.ToggleButtonConfig.StrokeColor2, 0, function(c)
	Ether.ToggleButtonConfig.StrokeColor2 = c
	Ether.applyToggleVisuals()
end)

local function refreshStrokeModeButtons()
	local isGrad = Ether.ToggleButtonConfig.Gradient
	SolidBtn.BackgroundColor3 = isGrad and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(0, 168, 255)
	GradientBtn.BackgroundColor3 = isGrad and Color3.fromRGB(0, 168, 255) or Color3.fromRGB(50, 50, 60)
	Color2RowFrame.Visible = isGrad
end

SolidBtn.MouseButton1Click:Connect(function() Ether.ToggleButtonConfig.Gradient = false Ether.applyToggleVisuals() Ether.saveToggleConfig() refreshStrokeModeButtons() end)
GradientBtn.MouseButton1Click:Connect(function() Ether.ToggleButtonConfig.Gradient = true Ether.applyToggleVisuals() Ether.saveToggleConfig() refreshStrokeModeButtons() end)

-- Rotation
Ether.Create("TextLabel", { Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 168), BackgroundTransparency = 1, Text = "Rotation:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })
RotationInput = Ether.Create("TextBox", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 90, 0, 168), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(Ether.ToggleButtonConfig.GradientRotation), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), ClearTextOnFocus = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RotationInput })
local RotationApply = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 155, 0, 168), BackgroundColor3 = Color3.fromRGB(40, 148, 215), Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RotationApply })
RotationApply.MouseButton1Click:Connect(function()
	local v = tonumber(RotationInput.Text)
	if v then
		Ether.ToggleButtonConfig.GradientRotation = math.clamp(v, 0, 360)
		Ether.applyToggleVisuals()
		Ether.saveToggleConfig()
	end
end)

-- Corner
Ether.Create("TextLabel", { Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 200), BackgroundTransparency = 1, Text = "Corner:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })
local CornerSliderBG = Ether.Create("Frame", { Size = UDim2.new(0, 175, 0, 8), Position = UDim2.new(0, 90, 0, 209), BackgroundColor3 = Color3.fromRGB(22, 22, 28), BorderSizePixel = 0, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderBG })
local CornerSliderFill = Ether.Create("Frame", { Size = UDim2.new((Ether.ToggleButtonConfig.CornerRadius or 50) / 50, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 168, 255), BorderSizePixel = 0, Parent = CornerSliderBG })
Ether.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderFill })
local CornerSliderKnob = Ether.Create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((Ether.ToggleButtonConfig.CornerRadius or 50) / 50, -7, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Parent = CornerSliderBG })
Ether.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderKnob })
local CornerSliderInput = Ether.Create("TextButton", { Size = UDim2.new(0, 175, 0, 20), Position = UDim2.new(0, 90, 0, 203), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = ToggleSection })
local CornerValueLbl = Ether.Create("TextLabel", { Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(0, 270, 0, 200), BackgroundTransparency = 1, Text = tostring(Ether.ToggleButtonConfig.CornerRadius or 50), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection })

local cornerDragging = false
local function setCornerFromX(mouseX)
	local absPos = CornerSliderBG.AbsolutePosition
	local absSize = CornerSliderBG.AbsoluteSize
	local rel = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
	local val = math.floor(rel * 50 + 0.5)
	Ether.ToggleButtonConfig.CornerRadius = val
	CornerSliderFill.Size = UDim2.new(val / 50, 0, 1, 0)
	CornerSliderKnob.Position = UDim2.new(val / 50, -7, 0.5, -7)
	CornerValueLbl.Text = tostring(val)
	Ether.ToggleButtonCorner.CornerRadius = UDim.new(val / 100, 0)
end
CornerSliderInput.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then cornerDragging = true setCornerFromX(input.Position.X) end end)
CornerSliderInput.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then cornerDragging = false Ether.saveToggleConfig() end end)
Ether.UIS.InputChanged:Connect(function(input) if cornerDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setCornerFromX(input.Position.X) end end)

-- Reset
local ResetBtn = Ether.Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 240), BackgroundColor3 = Color3.fromRGB(80, 80, 90), Text = "Reset to Defaults", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = ToggleSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ResetBtn })

-- Presets
local PresetsSection = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 130), BackgroundColor3 = Color3.fromRGB(35, 35, 42), BorderSizePixel = 0, LayoutOrder = 3, Parent = SettingsContent })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = PresetsSection })
Ether.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = PresetsSection })
Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Presets", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(0, 210, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = PresetsSection })

local PRESETS = {
	{ name = "Ocean", c1 = Color3.fromRGB(0, 168, 255), c2 = Color3.fromRGB(0, 255, 200), gradient = true, rgb = false, rot = 45 },
	{ name = "Sunset", c1 = Color3.fromRGB(255, 100, 50), c2 = Color3.fromRGB(255, 100, 180), gradient = true, rgb = false, rot = 45 },
	{ name = "Neon", c1 = Color3.fromRGB(0, 255, 100), c2 = Color3.fromRGB(0, 255, 100), gradient = false, rgb = false, rot = 0 },
	{ name = "Fire", c1 = Color3.fromRGB(255, 50, 0), c2 = Color3.fromRGB(255, 200, 0), gradient = true, rgb = false, rot = 90 },
	{ name = "Magic", c1 = Color3.fromRGB(160, 50, 255), c2 = Color3.fromRGB(255, 100, 200), gradient = true, rgb = false, rot = 45 },
	{ name = "Midnight", c1 = Color3.fromRGB(30, 50, 120), c2 = Color3.fromRGB(30, 50, 120), gradient = false, rgb = false, rot = 0 },
	{ name = "Cyber", c1 = Color3.fromRGB(255, 0, 200), c2 = Color3.fromRGB(0, 255, 200), gradient = true, rgb = false, rot = 135 },
	{ name = "Rainbow", c1 = Color3.fromRGB(255, 0, 0), c2 = Color3.fromRGB(0, 0, 255), gradient = true, rgb = true, rot = 0 },
}

local PresetGrid = Ether.Create("Frame", { Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 28), BackgroundTransparency = 1, Parent = PresetsSection })
Ether.Create("UIGridLayout", { CellSize = UDim2.new(0, 95, 0, 32), CellPadding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = PresetGrid })

for _, preset in ipairs(PRESETS) do
	local pBtn = Ether.Create("TextButton", { BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = preset.name, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = PresetGrid })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = pBtn })
	local pStroke = Ether.Create("UIStroke", { Parent = pBtn, Thickness = 2, Color = preset.c1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	if preset.gradient then
		Ether.Create("UIGradient", { Parent = pStroke, Rotation = preset.rot, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, preset.c1), ColorSequenceKeypoint.new(1, preset.c2) }) })
	end
	pBtn.MouseButton1Click:Connect(function()
		local cfg = Ether.ToggleButtonConfig
		cfg.StrokeColor = preset.c1 cfg.StrokeColor2 = preset.c2 cfg.Gradient = preset.gradient cfg.GradientRotation = preset.rot
		cfg.RGBMode = preset.rgb cfg.AutoRotate = false
		
		-- The fix: Since RGBModeBtn, AutoRotateBtn, RotationInput are now forward-declared, we can access them safely.
		RGBModeBtn.Text = preset.rgb and "ON" or "OFF" RGBModeBtn.BackgroundColor3 = preset.rgb and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
		AutoRotateBtn.Text = "OFF" AutoRotateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		RotationInput.Text = tostring(preset.rot)
		
		Ether.applyToggleVisuals() refreshStrokeModeButtons() Ether.saveToggleConfig()
		hub:Toast("Preset: " .. preset.name, EtherExecutor)
	end)
end

-- Animation Settings
local AnimationSection = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 130), BackgroundColor3 = Color3.fromRGB(35, 35, 42), BorderSizePixel = 0, LayoutOrder = 4, Parent = SettingsContent })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = AnimationSection })
Ether.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = AnimationSection })
Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Animation", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(0, 210, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection })

-- Auto Rotate
Ether.Create("TextLabel", { Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Text = "Auto Rotate:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection })
AutoRotateBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 100, 0, 30), BackgroundColor3 = Ether.ToggleButtonConfig.AutoRotate and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60), Text = Ether.ToggleButtonConfig.AutoRotate and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = AnimationSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = AutoRotateBtn })
Ether.Create("TextLabel", { Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 168, 0, 30), BackgroundTransparency = 1, Text = "Speed °/s:", Font = Enum.Font.GothamSemibold, TextSize = 10, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection })
local AutoRotSpeedInput = Ether.Create("TextBox", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 238, 0, 30), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(Ether.ToggleButtonConfig.AutoRotateSpeed or 45), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), ClearTextOnFocus = false, Parent = AnimationSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = AutoRotSpeedInput })
AutoRotSpeedInput.FocusLost:Connect(function()
	local v = tonumber(AutoRotSpeedInput.Text)
	if v then Ether.ToggleButtonConfig.AutoRotateSpeed = math.clamp(v, 5, 360) AutoRotSpeedInput.Text = tostring(Ether.ToggleButtonConfig.AutoRotateSpeed) Ether.saveToggleConfig() end
end)
AutoRotateBtn.MouseButton1Click:Connect(function()
	local cfg = Ether.ToggleButtonConfig cfg.AutoRotate = not cfg.AutoRotate
	AutoRotateBtn.Text = cfg.AutoRotate and "ON" or "OFF" AutoRotateBtn.BackgroundColor3 = cfg.AutoRotate and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
	if not cfg.AutoRotate then Ether.ToggleButtonGradient.Rotation = cfg.GradientRotation end
	Ether.saveToggleConfig()
end)

-- RGB Mode
Ether.Create("TextLabel", { Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(0, 0, 0, 66), BackgroundTransparency = 1, Text = "RGB Mode:", Font = Enum.Font.GothamSemibold, TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection })
RGBModeBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 100, 0, 66), BackgroundColor3 = Ether.ToggleButtonConfig.RGBMode and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60), Text = Ether.ToggleButtonConfig.RGBMode and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Parent = AnimationSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RGBModeBtn })
Ether.Create("TextLabel", { Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 168, 0, 66), BackgroundTransparency = 1, Text = "Speed Hz:", Font = Enum.Font.GothamSemibold, TextSize = 10, TextColor3 = Color3.fromRGB(220, 220, 230), TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection })
local RGBSpeedInput = Ether.Create("TextBox", { Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 238, 0, 66), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Text = tostring(Ether.ToggleButtonConfig.RGBSpeed or 0.3), Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), ClearTextOnFocus = false, Parent = AnimationSection })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RGBSpeedInput })
RGBSpeedInput.FocusLost:Connect(function()
	local v = tonumber(RGBSpeedInput.Text)
	if v then Ether.ToggleButtonConfig.RGBSpeed = math.clamp(v, 0.05, 3) RGBSpeedInput.Text = tostring(Ether.ToggleButtonConfig.RGBSpeed) Ether.saveToggleConfig() end
end)
RGBModeBtn.MouseButton1Click:Connect(function()
	local cfg = Ether.ToggleButtonConfig cfg.RGBMode = not cfg.RGBMode
	RGBModeBtn.Text = cfg.RGBMode and "ON" or "OFF" RGBModeBtn.BackgroundColor3 = cfg.RGBMode and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
	if not cfg.RGBMode then Ether.applyToggleVisuals() end
	Ether.saveToggleConfig()
end)

ResetBtn.MouseButton1Click:Connect(function()
	Ether.CustomIcon = "lucide:eye"
	Ether.ToggleButtonConfig = {
		StrokeColor = Color3.fromRGB(0, 168, 255), StrokeColor2 = Color3.fromRGB(255, 105, 180), Gradient = false, GradientRotation = 45,
		Position = UDim2.new(0, 20, 0, 90), Size = 44, Visible = true, AutoRotate = false, AutoRotateSpeed = 45, RGBMode = false, RGBSpeed = 0.3, CornerRadius = 50,
	}
	Ether.ToggleButton.Position = Ether.ToggleButtonConfig.Position
	IconInput.Text = Ether.CustomIcon RotationInput.Text = "45" AutoRotSpeedInput.Text = "45" RGBSpeedInput.Text = "0.3"
	AutoRotateBtn.Text = "OFF" AutoRotateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	RGBModeBtn.Text = "OFF" RGBModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	CornerSliderFill.Size = UDim2.new(1, 0, 1, 0) CornerSliderKnob.Position = UDim2.new(1, -7, 0.5, -7) CornerValueLbl.Text = "50"
	Ether.ToggleButtonCorner.CornerRadius = UDim.new(0.5, 0)
	Ether.applyToggleVisuals() Ether.saveToggleConfig() refreshStrokeModeButtons()
	hub:Toast("Reset to defaults", EtherExecutor)
end)

return Ether
