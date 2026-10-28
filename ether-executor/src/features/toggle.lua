-- features/toggle.lua
local Ether = getgenv().Ether
if not Ether then return end

local TweenService = Ether.TweenService
local uis = Ether.UIS
local RunService = Ether.RunService

local TOGGLE_CONFIG_PATH = Ether.MainFolder .. "/toggle_config.txt"

function Ether.saveToggleConfig()
	if type(writefile) ~= "function" then return end
	local cfg = Ether.ToggleButtonConfig
	local c1, c2 = cfg.StrokeColor, cfg.StrokeColor2
	local data = table.concat({
		"CustomIcon=" .. tostring(Ether.CustomIcon or "lucide:eye"),
		"StrokeColorR=" .. math.floor(c1.R * 255),
		"StrokeColorG=" .. math.floor(c1.G * 255),
		"StrokeColorB=" .. math.floor(c1.B * 255),
		"StrokeColor2R=" .. math.floor(c2.R * 255),
		"StrokeColor2G=" .. math.floor(c2.G * 255),
		"StrokeColor2B=" .. math.floor(c2.B * 255),
		"Gradient=" .. tostring(cfg.Gradient),
		"GradientRotation=" .. tostring(cfg.GradientRotation),
		"TogglePosX=" .. tostring(cfg.Position.X.Offset),
		"TogglePosY=" .. tostring(cfg.Position.Y.Offset),
		"AutoRotate=" .. tostring(cfg.AutoRotate),
		"AutoRotateSpeed=" .. tostring(cfg.AutoRotateSpeed),
		"RGBMode=" .. tostring(cfg.RGBMode),
		"RGBSpeed=" .. tostring(cfg.RGBSpeed),
		"CornerRadius=" .. tostring(cfg.CornerRadius or 50),
	}, "\n")
	pcall(writefile, TOGGLE_CONFIG_PATH, data)
end

function Ether.loadToggleConfig()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
	local okExist, exists = pcall(isfile, TOGGLE_CONFIG_PATH)
	if not okExist or not exists then return end
	local okRead, content = pcall(readfile, TOGGLE_CONFIG_PATH)
	if not okRead or not content then return end
	local cfg = Ether.ToggleButtonConfig
	local function num(k) return tonumber(content:match(k .. "=(%-?%d+)")) end
	local function fnum(k) return tonumber(content:match(k .. "=([%-%d%.]+)")) end
	local icon = content:match("CustomIcon=([^\n]+)")
	if icon and icon ~= "" then Ether.CustomIcon = icon end
	local r, g, b = num("StrokeColorR"), num("StrokeColorG"), num("StrokeColorB")
	if r and g and b then cfg.StrokeColor = Color3.fromRGB(r, g, b) end
	local r2, g2, b2 = num("StrokeColor2R"), num("StrokeColor2G"), num("StrokeColor2B")
	if r2 and g2 and b2 then cfg.StrokeColor2 = Color3.fromRGB(r2, g2, b2) end
	local gradStr = content:match("Gradient=([^\n]+)")
	if gradStr then cfg.Gradient = (gradStr == "true") end
	local rot = num("GradientRotation")
	if rot then cfg.GradientRotation = rot end
	local px, py = num("TogglePosX"), num("TogglePosY")
	if px and py then cfg.Position = UDim2.new(0, px, 0, py) end
	local ar = content:match("AutoRotate=([^\n]+)")
	if ar then cfg.AutoRotate = (ar == "true") end
	local ars = fnum("AutoRotateSpeed")
	if ars then cfg.AutoRotateSpeed = ars end
	local rgb = content:match("RGBMode=([^\n]+)")
	if rgb then cfg.RGBMode = (rgb == "true") end
	local rgbs = fnum("RGBSpeed")
	if rgbs then cfg.RGBSpeed = rgbs end
	local cr = num("CornerRadius")
	if cr then cfg.CornerRadius = math.clamp(cr, 0, 50) end
end

Ether.loadToggleConfig()

local ToggleButton = Ether.Create("TextButton", {
	Name = "EtherToggleButton", Parent = Ether.EtherExecutor,
	Size = UDim2.new(0, Ether.ToggleButtonConfig.Size, 0, Ether.ToggleButtonConfig.Size),
	Position = Ether.ToggleButtonConfig.Position,
	BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.05,
	BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 1001, Active = true,
})
Ether.ToggleButton = ToggleButton

local ToggleButtonCorner = Ether.Create("UICorner", {
	CornerRadius = UDim.new((Ether.ToggleButtonConfig.CornerRadius or 50) / 100, 0),
	Parent = ToggleButton,
})
Ether.ToggleButtonCorner = ToggleButtonCorner

local ToggleButtonStroke = Ether.Create("UIStroke", {
	Parent = ToggleButton, Thickness = 2,
	Color = Ether.ToggleButtonConfig.StrokeColor,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
})
Ether.ToggleButtonStroke = ToggleButtonStroke

local ToggleButtonGradient = Ether.Create("UIGradient", {
	Parent = ToggleButtonStroke,
	Rotation = Ether.ToggleButtonConfig.GradientRotation,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Ether.ToggleButtonConfig.StrokeColor),
		ColorSequenceKeypoint.new(1, Ether.ToggleButtonConfig.StrokeColor2),
	}),
	Enabled = Ether.ToggleButtonConfig.Gradient,
})
Ether.ToggleButtonGradient = ToggleButtonGradient

local ToggleButtonIcon = Ether.Create("ImageLabel", {
	Name = "Icon", Size = UDim2.new(0.55, 0, 0.55, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(240, 240, 240),
	Image = "", Parent = ToggleButton,
})
Ether.applyIcon(ToggleButtonIcon, Ether.CustomIcon or "lucide:eye")
Ether.ToggleButtonIcon = ToggleButtonIcon

function Ether.applyToggleVisuals()
	local cfg = Ether.ToggleButtonConfig
	if not cfg.RGBMode then
		ToggleButtonStroke.Color = cfg.StrokeColor
		ToggleButtonGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, cfg.StrokeColor),
			ColorSequenceKeypoint.new(1, cfg.StrokeColor2),
		})
	end
	if not cfg.AutoRotate then
		ToggleButtonGradient.Rotation = cfg.GradientRotation
	end
	ToggleButtonGradient.Enabled = cfg.Gradient
	ToggleButtonCorner.CornerRadius = UDim.new((cfg.CornerRadius or 50) / 100, 0)
	Ether.applyIcon(ToggleButtonIcon, Ether.CustomIcon or "lucide:eye")
end

local animStartTime = time()
Ether.SafeConnect(RunService.RenderStepped, function()
	local cfg = Ether.ToggleButtonConfig
	if not ToggleButton or not ToggleButton.Parent then return end
	if not (cfg.AutoRotate or cfg.RGBMode) then return end
	local t = time() - animStartTime
	if cfg.AutoRotate then
		ToggleButtonGradient.Rotation = (t * (cfg.AutoRotateSpeed or 45)) % 360
	end
	if cfg.RGBMode then
		local hue = (t * (cfg.RGBSpeed or 0.3)) % 1
		local c1 = Color3.fromHSV(hue, 0.85, 1)
		if cfg.Gradient then
			local c2 = Color3.fromHSV((hue + 0.5) % 1, 0.85, 1)
			ToggleButtonGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, c1),
				ColorSequenceKeypoint.new(1, c2),
			})
		else
			ToggleButtonStroke.Color = c1
		end
	end
end)

function Ether.setMainUIHidden(hidden)
	Ether.MainUIHidden = hidden
	Ether.MainFrameParent.Visible = not hidden
end

Ether.SafeConnect(ToggleButton.MouseButton1Click, function()
	Ether.setMainUIHidden(not Ether.MainUIHidden)
end)

local toggleDragging, toggleDragStart, toggleStartPos = false, nil, nil
Ether.SafeConnect(ToggleButton.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		toggleDragging = true toggleDragStart = input.Position toggleStartPos = ToggleButton.Position
	end
end)
Ether.SafeConnect(ToggleButton.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if toggleDragging then
			toggleDragging = false
			Ether.ToggleButtonConfig.Position = ToggleButton.Position
			Ether.saveToggleConfig()
		end
	end
end)
Ether.SafeConnect(uis.InputChanged, function(input)
	if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - toggleDragStart
		local nx = toggleStartPos.X.Offset + delta.X
		local ny = toggleStartPos.Y.Offset + delta.Y
		local cam = workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			nx = math.clamp(nx, 0, math.max(0, vp.X - ToggleButton.AbsoluteSize.X))
			ny = math.clamp(ny, 0, math.max(0, vp.Y - ToggleButton.AbsoluteSize.Y))
		end
		ToggleButton.Position = UDim2.new(0, nx, 0, ny)
	end
end)

Ether.SafeConnect(uis.InputBegan, function(input)
	if input.KeyCode == Enum.KeyCode.H then
		if input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
			Ether.setMainUIHidden(not Ether.MainUIHidden)
		end
	end
end)

return Ether
