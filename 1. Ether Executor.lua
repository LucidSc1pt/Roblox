if getgenv().EtherExecutorLibrary then
	getgenv().EtherExecutorLibrary:Destroy()
end

local EtherLibrary = {
	Flags = {},
	ExecutorFlags = {},
	ThemeObjects = {},
	Connections = {},
	Themes = {
		Default = {
			WindowBackground = Color3.fromRGB(47, 54, 64),
			WindowBorder = Color3.fromRGB(47, 54, 64),

			ElementDivider = Color3.fromRGB(107, 114, 124),
			ElementDividerText = Color3.fromRGB(107, 114, 124),

			TabDivider = Color3.fromRGB(107, 114, 124),
			TabDividerText = Color3.fromRGB(107, 114, 124),
			
			TabBtnBackground = Color3.fromRGB(40, 148, 215),
			TabBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),
			
			TabScriptBtnBackground = Color3.fromRGB(40, 148, 215),
			TabScriptBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),

			Header = Color3.fromRGB(0, 168, 255),
			HeaderBorder = Color3.fromRGB(0, 168, 255),
			HeaderText = Color3.fromRGB(47, 54, 64),
			SubHeaderText = Color3.fromRGB(67, 74, 84),

			NormalText = Color3.fromRGB(245, 246, 250),
			NormalBackground = Color3.fromRGB(53, 59, 72),

			DropdownOptionBackground = Color3.fromRGB(53, 59, 72),
			DropdownOptionTextHolder = Color3.fromRGB(180, 180, 180),
			DropdownOptionSelect = Color3.fromRGB(73, 79, 92),

			BtnBorder = Color3.fromRGB(113, 128, 147),

			ToggleFiller = Color3.fromRGB(68, 189, 50),

			SliderFiller = Color3.fromRGB(76, 209, 55)
		}
	},
	GlobalAutoSave = true,

	MainFolder = "EtherExecutor",
	MainConfigFile = "ExeConfigs.json",
	MainFeatureFile = "Configs.json",

	IconCacheFolder = "IconCache",

	SavedScriptFolder = "Saved Script",
	SavedTabEditorFolder = "Saved Tab Editor",
	SavedScriptFolder = "Saved Script",
	SavedScriptHubFolder = "Saved Hub Script",

	SelectedTheme = "Default"
}

getgenv().EtherExecutorLibrary = EtherLibrary

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local players = game:service('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:service('RunService');
local stepped = run.Stepped;
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local GuiService = game:GetService("GuiService")

local activeInteraction = nil
local FirstTab = true
local Version = "v0.0.1 beta"

local changeList = {
	["v0.0.1 beta"] = {
		"• Release!"
	}
}

local function isMobileDevice()
	return uis.TouchEnabled and not (uis.KeyboardEnabled or uis.MouseEnabled)
end

local function isSupportSaving()
	if not (makefolder or isfolder or writefile or readfile) then
		warn("Your executor not support saving")
		return false
	end
	return true
end

local function Create(Name, Properties)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	return Object
end

local function ensureIconCacheFolder()
	if makefolder and isfolder and not isfolder(EtherLibrary.IconCacheFolder) then
		pcall(makefolder, EtherLibrary.IconCacheFolder)
	end
end

local function ensureFolder(path)
	if isfolder and makefolder and not isfolder(path) then
		pcall(makefolder, path)
	end
end

local function getFolderPath(folderName, subFolder)
	ensureFolder(EtherLibrary.MainFolder)
	
	local userFolder = (folderName and folderName ~= "") and folderName or "DefaultScript"
	local userPath = EtherLibrary.MainFolder .. "/" .. userFolder
	ensureFolder(userPath)

	if subFolder then
		local subPath = userPath .. "/" .. subFolder
		ensureFolder(subPath)
		return subPath
	end

	return userPath
end

local function createUIName()
	local length = math.random(1, 80)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(1, 255))
	end
	return table.concat(array)
end

local EtherExecutor = Create("ScreenGui", {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ScreenInsets = Enum.ScreenInsets.None,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false
})

local function protect_gui(obj) -- 
	if destroyed or not obj then return end
	obj.Name = tostring(createUIName())
	if gethui then
		obj.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(obj)
		obj.Parent = CoreGui
	elseif get_hidden_gui then
		obj.Parent = get_hidden_gui()
	elseif game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") then
		obj.Parent = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	else
		obj.Parent = CoreGui
	end
end

protect_gui(EtherExecutor)

local function SafeConnect(signal, callback)
	if typeof(signal) ~= "RBXScriptSignal" then return nil end
	if type(callback) ~= "function" then return nil end

	local ok, connection = pcall(signal.Connect, signal, callback)
	if ok and connection then
		table.insert(EtherLibrary.Connections, connection)
		return connection
	end
	return nil
end

local function executeSource(source, chunkName)
	source = tostring(source or "")
	if type(loadstring) ~= "function" then
		print("Script execution is unavailable in this Delta build.")
		return false
	end
	local compiled, compileError = loadstring(source, chunkName or "=Delta V2")
	if not compiled then
		print(tostring(compileError) or "Unknown compile error")
		return false
	end
	task.spawn(function()
		local ok, runtimeError = xpcall(compiled, function(message)
			return tostring(message)
		end)
		if not ok then
			print(tostring(runtimeError) or "Unknown runtime error")
		end
	end)
	return true
end

local IconPacks = {}

local function loadIconPackWithCache(packName: string, url: string)
	local fileName = string.lower(packName) .. "_icons (DO NOT EDIT THIS FILE).lua"
	local filePath = EtherLibrary.IconCacheFolder .. "/" .. fileName
	local rawData = nil

	if writefile and readfile and isfile and isfile(filePath) then
		local success, content = pcall(readfile, filePath)
		if success and content and content ~= "" then
			rawData = content
		end
	end

	if not rawData then
		local success, response = pcall(function()
			return game:HttpGet(url)
		end)

		if success and response and response ~= "" then
			rawData = response

			if writefile then
				pcall(function()
					ensureIconCacheFolder()
					writefile(filePath, rawData)
				end)
			end
		else
			warn(`[EtherExecutor] Failed to download Icon Packs '{packName}'.`)
			return
		end
	end

	if rawData then
		local loadSuccess, result = pcall(loadstring(rawData))
		if loadSuccess and type(result) == "table" then
			IconPacks[packName] = result
		else
			warn(`[EtherExecutor] Failed to parse Icon Packs data '{packName}'.`)
		end
	end
end

loadIconPackWithCache("lucide", "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
loadIconPackWithCache("solar", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua")
loadIconPackWithCache("craft", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
loadIconPackWithCache("geist", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
loadIconPackWithCache("sfsymbols", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
loadIconPackWithCache("gravity", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua")

local function parseUniversalIcon(raw)
	if not raw then return nil end

	local result = {
		Image = "",
		RectSize = Vector2.zero,
		RectOffset = Vector2.zero
	}

	if type(raw) == "number" then
		result.Image = "rbxassetid://" .. raw
		return result
	end

	if type(raw) == "string" then
		if string.sub(raw, 1, 13) == "rbxassetid://" or string.find(raw, "://") then
			result.Image = raw
			return result
		elseif tonumber(raw) then
			result.Image = "rbxassetid://" .. raw
			return result
		end
	end

	if type(raw) == "table" then
		local img = raw.Image or raw.image or raw.id or raw.Id or raw.Asset or raw.asset or raw.url or raw[1]
		if type(img) == "number" then
			result.Image = "rbxassetid://" .. img
		elseif type(img) == "string" then
			result.Image = (string.sub(img, 1, 13) == "rbxassetid://" or string.find(img, "://")) and img or ("rbxassetid://" .. img)
		end

		local size = raw.ImageRectSize or raw.imageRectSize or raw.Size or raw.size or raw[2]
		if typeof(size) == "Vector2" then
			result.RectSize = size
		elseif type(size) == "table" then
			result.RectSize = Vector2.new(size[1] or size.X or size.x or 0, size[2] or size.Y or size.y or 0)
		end

		local offset = raw.ImageRectOffset or raw.imageRectOffset or raw.Offset or raw.offset or raw[3]
		if typeof(offset) == "Vector2" then
			result.RectOffset = offset
		elseif type(offset) == "table" then
			result.RectOffset = Vector2.new(offset[1] or offset.X or offset.x or 0, offset[2] or offset.Y or offset.y or 0)
		end

		return (result.Image ~= "") and result or nil
	end

	return nil
end

local function getIconData(input)
	if not input then return nil end

	local directParsed = parseUniversalIcon(input)
	if directParsed then return directParsed end

	if type(input) ~= "string" or input == "" then return nil end

	local packName, iconName = string.match(input, "^(%w+):(.+)$")
	if not packName then
		packName = "lucide"
		iconName = input
	end

	packName = string.lower(packName)
	iconName = string.match(string.lower(iconName), "^%s*(.*)%s*$")

	local selectedPack = IconPacks[packName]
	if not selectedPack then return nil end

	local sizedIcons = selectedPack['48px'] or selectedPack['24px'] or selectedPack
	local rawIcon = sizedIcons[iconName]

	if not rawIcon and type(selectedPack.Get) == "function" then
		rawIcon = selectedPack:Get(iconName)
	end

	return parseUniversalIcon(rawIcon)
end

local function applyIcon(imageInstance, iconInput)
	local data = getIconData(iconInput)
	if not data then 
		imageInstance.Image = ""
		return 
	end

	imageInstance.Image = data.Image
	imageInstance.ImageRectSize = data.RectSize     -- Jika bukan spritesheet, nilainya Vector2(0,0)
	imageInstance.ImageRectOffset = data.RectOffset -- Jika bukan spritesheet, nilainya Vector2(0,0)
end

local highlighter = {}
local keywords = {
	lua = {
		"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
		"local", "return", "function", "export", "continue", "type", "typeof", "not",
	},
	rbx = {
		"game","Game", "Workspace", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
		"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring","SharedTable","plugin","DateTime",
		"unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
		"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo","printidentity","Content","ColorSequence",
		"collectgarbage", "utf8", "ypcall","pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs","ColorSequenceKeypoint",
		"Font", "getfenv", "setfenv", "rawget", "rawlen", "rawset", "rawequal", "RotationCurveKey", "FloatCurveKey", "File", "debug", "coroutine",
		"SecurityCapabilities", "PhysicalProperties", "bit32", "buffer", "CatalogSearchParams", "delay", "Delay", "DockWidgetPluginGuiInfo",
		"spawn", "Spawn", "ElapsedTime", "elapsedTime", "Faces", "NumberSequence", "NumberSequenceKeypoint", "NumberRange", "newproxy",
		"PathWaypoint", "Path2DControlPoint", "Region3int16", "Secret", "settings", "Stats", "stats", "UserSettings", "version", "Version",
		"vector", "Vector2int16", "Vector3int16", "Wait", "require",
	},
	operators = {
		"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"
	}
}

local colors = {
	numbers = Color3.fromRGB(255, 198, 0),
	boolean = Color3.fromRGB(214, 128, 23),
	operator = Color3.fromRGB(232, 210, 40),
	lua = Color3.fromRGB(160, 87, 248),
	rbx = Color3.fromRGB(146, 180, 253),
	str = Color3.fromRGB(56, 241, 87),
	comment = Color3.fromRGB(103, 110, 149),
	null = Color3.fromRGB(79, 79, 79),
	call = Color3.fromRGB(130, 170, 255),
	self_call = Color3.fromRGB(227, 201, 141),
	local_color = Color3.fromRGB(199, 146, 234),
	function_color = Color3.fromRGB(241, 122, 124),
	self_color = Color3.fromRGB(146, 134, 234),
	local_property = Color3.fromRGB(129, 222, 255),
}

local function createKeywordSet(keywords)
	local keywordSet = {}
	for _, keyword in ipairs(keywords) do
		keywordSet[keyword] = true
	end
	return keywordSet
end

local luaSet = createKeywordSet(keywords.lua)
local rbxSet = createKeywordSet(keywords.rbx)
local operatorsSet = createKeywordSet(keywords.operators)

local function getHighlight(tokens, index)
	local token = tokens[index]

	if colors[token .. "_color"] then
		return colors[token .. "_color"]
	end

	if tonumber(token) then
		return colors.numbers
	elseif token == "nil" then
		return colors.null
	elseif token:sub(1, 2) == "--" then
		return colors.comment
	elseif operatorsSet[token] then
		return colors.operator
	elseif luaSet[token] then
		return colors.rbx
	elseif rbxSet[token] then
		return colors.lua
	elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
		return colors.str
	elseif token == "true" or token == "false" then
		return colors.boolean
	end

	if tokens[index + 1] == "(" then
		if tokens[index - 1] == ":" then
			return colors.self_call
		end

		return colors.call
	end

	if tokens[index - 1] == "." then
		if tokens[index - 2] == "Enum" then
			return colors.rbx
		end

		return colors.local_property
	end
end

function highlighter.run(source)
	local tokens = {}
	local currentToken = ""

	local inString = false
	local inComment = false
	local commentPersist = false

	for i = 1, #source do
		local character = source:sub(i, i)

		if inComment then
			if character == "\n" and not commentPersist then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""

				inComment = false
			elseif source:sub(i - 1, i) == "]]" and commentPersist then
				currentToken ..= "]"

				table.insert(tokens, currentToken)
				currentToken = ""

				inComment = false
				commentPersist = false
			else
				currentToken = currentToken .. character
			end
		elseif inString then
			if character == inString and source:sub(i-1, i-1) ~= "\\" or character == "\n" then
				currentToken = currentToken .. character
				inString = false
			else
				currentToken = currentToken .. character
			end
		else
			if source:sub(i, i + 1) == "--" then
				table.insert(tokens, currentToken)
				currentToken = "-"
				inComment = true
				commentPersist = source:sub(i + 2, i + 3) == "[["
			elseif character == "\"" or character == "\'" then
				table.insert(tokens, currentToken)
				currentToken = character
				inString = character
			elseif operatorsSet[character] then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			elseif character:match("[%w_]") then
				currentToken = currentToken .. character
			else
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			end
		end
	end

	table.insert(tokens, currentToken)

	local highlighted = {}

	for i, token in ipairs(tokens) do
		local highlight = getHighlight(tokens, i)

		if highlight then
			local syntax = string.format("<font color = \"#%s\">%s</font>", highlight:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))

			table.insert(highlighted, syntax)
		else
			table.insert(highlighted, token)
		end
	end

	return table.concat(highlighted)
end

local function MakeDraggable(DragPoint, Main)
	Main = Main or DragPoint
	if typeof(DragPoint) ~= "Instance" or typeof(Main) ~= "Instance" then return end

	local Dragging = false
	local DragInput = nil
	local MousePos = nil
	local FramePos = nil

	SafeConnect(DragPoint.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			if Dragging and activeInteraction ~= nil then return end

			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position
			DragInput = Input

			local changedConnection
			changedConnection = Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					DragInput = nil
					if changedConnection then
						changedConnection:Disconnect()
					end
				end
			end)
		end
	end)

	SafeConnect(DragPoint.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if not Dragging then
				DragInput = Input
			end
		end
	end)

	SafeConnect(uis.InputChanged, function(Input)
		if Dragging and activeInteraction == nil and Input == DragInput then
			local Delta = Input.Position - MousePos
			Main.Position = UDim2.new(
				FramePos.X.Scale, 
				FramePos.X.Offset + Delta.X, 
				FramePos.Y.Scale, 
				FramePos.Y.Offset + Delta.Y
			)
		end
	end)

	SafeConnect(Main.AncestryChanged, function(_, parent)
		if not parent then
			Dragging = false
		end
	end)
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	elseif Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Object:IsA("UIStroke") then
		return "Color"
	elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end
	return "BackgroundColor3"
end

local function AddThemeObject(Object, ThemeKey, SpecificProperty)
	if not EtherLibrary.ThemeObjects[ThemeKey] then
		EtherLibrary.ThemeObjects[ThemeKey] = {}
	end
	
	local targetProperty = SpecificProperty or ReturnProperty(Object)

	table.insert(EtherLibrary.ThemeObjects[ThemeKey], {
		Object = Object,
		Property = targetProperty
	})

	local currentTheme = EtherLibrary.Themes[EtherLibrary.SelectedTheme]
	if currentTheme and currentTheme[ThemeKey] then
		Object[targetProperty] = currentTheme[ThemeKey]
	end

	return Object
end

function EtherLibrary:AddTheme(themeName, themeTable)
	if type(themeName) == "string" and type(themeTable) == "table" then
		EtherLibrary.Themes[themeName] = themeTable
	end
end

function EtherLibrary:SetTheme(themeInput)
	local targetTheme = nil

	if type(themeInput) == "string" then
		if EtherLibrary.Themes[themeInput] then
			EtherLibrary.SelectedTheme = themeInput
			targetTheme = EtherLibrary.Themes[themeInput]
		end
	elseif type(themeInput) == "table" then
		targetTheme = themeInput
		EtherLibrary.SelectedTheme = "Custom"
	end

	if not targetTheme then return end

	for themeKey, objectList in pairs(EtherLibrary.ThemeObjects) do
		local targetColor = targetTheme[themeKey]
		if targetColor then
			for i = #objectList, 1, -1 do
				local item = objectList[i]
				if item.Object and item.Object.Parent then
					item.Object[item.Property] = targetColor
				else
					table.remove(objectList, i)
				end
			end
		end
	end
end

local function registerFlag(config, controller)
	if not config.Flag then return end

	if EtherLibrary.Flags[config.Flag] ~= nil then
		warn("[EtherExecutor] Duplicate flag: '".. tostring(config.Flag).."' on '".. tostring(config.Title).."'")
		return
	end

	EtherLibrary.Flags[config.Flag] = config.Default
end

local isHasSaving = isSupportSaving()

local function execCallback(callback, itemConfig, ...)
	if type(callback) ~= "function" then return true end

	local isSafe = true
	if itemConfig and (typeof(itemConfig.SafeCallback) == "boolean" and itemConfig.SafeCallback ~= nil) then
		isSafe = itemConfig.SafeCallback
	end

	if isSafe then
		local success, err = xpcall(callback, function(errMessage)
			return errMessage .. "\n" .. debug.traceback("", 2)
		end, ...)

		if not success then
			local elementName = "Unknown Element"
			if type(itemConfig) == "table" then
				elementName = itemConfig.Title or itemConfig.Name or itemConfig.Text or "Element"
			end

			warn("[EtherLibrary SafeCallback Error on " .. tostring(elementName) .. "]:\n" .. tostring(err))
			return false
		end
		return true
	else
		callback(...)
		return true
	end
end

local function randomNameString()
	local length = math.random(40, 60)
	local array = {}
	for i = 1, length do
	local charType = math.random(1, 3)
	if charType == 1 then
			array[i] = string.char(math.random(48, 57))
	elseif charType == 2 then
		array[i] = string.char(math.random(97, 122))
	else
		array[i] = string.char(math.random(65, 90))
	end
	end
	return table.concat(array)
end

function EtherLibrary:Destroy()
	if EtherLibrary.GlobalAutoSave == true then
		task.wait(4)
	end

	if EtherLibrary.Connections then
		for _, conn in ipairs(EtherLibrary.Connections) do
			if typeof(conn) == "RBXScriptConnection" and conn.Connected then
				pcall(function() conn:Disconnect() end)
			end
		end
		table.clear(EtherLibrary.Connections)
	end

	if EtherExecutor then
		pcall(function() EtherExecutor:Destroy() end)
		EtherExecutor = nil
	end

	if EtherLibrary.ThemeObjects then table.clear(EtherLibrary.ThemeObjects) end
	if EtherLibrary.Flags then table.clear(EtherLibrary.Flags) end
	if EtherLibrary.Themes then table.clear(EtherLibrary.Themes) end
	if IconPacks then table.clear(IconPacks) end

	if getgenv().EtherExecutorLibrary == EtherLibrary then
		getgenv().EtherExecutorLibrary = nil
	end
end

local function getNotificationContainer()
	local container = EtherExecutor:FindFirstChild("NotificationHolder")
	if not container then
		container = Create("Frame", {
			Name = "NotificationHolder",
			Parent = EtherExecutor,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -25, 1, -25),
			Size = UDim2.new(0, 240, 1, -25),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ZIndex = 99
		})

		Create("UIListLayout", {
			Parent = container,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 5)
		})
	end
	return container
end

local function Notification(NotificationConfig)
	task.spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Title = (NotificationConfig.Title or NotificationConfig.Name or NotificationConfig.Text) or "Notification"
		NotificationConfig.Content = (NotificationConfig.Content or NotificationConfig.Desc or NotificationConfig.Description) or "Hello World"
		NotificationConfig.Image = (NotificationConfig.Image or NotificationConfig.Icon) or 4384403532
		NotificationConfig.Type = NotificationConfig.Type or "Info"
		NotificationConfig.Time = ((NotificationConfig.Time or NotificationConfig.Duration) or (NotificationConfig.duration)) or 5

		local NotificationHolder = getNotificationContainer()

		local accentColors = {
			Info = Color3.fromRGB(52, 152, 219),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Error = Color3.fromRGB(231, 76, 60)
		}
		local accentColor = accentColors[NotificationConfig.Type] or accentColors.Info

		local isDismissed = false

		local NotificationParent = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Parent = NotificationHolder
		})

		local NotificationFrame = Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(1, 50, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = EtherLibrary["Themes"]["Default"].WindowBackground,
			BackgroundTransparency = 1,
			Parent = NotificationParent
		})

		Create("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
			Parent = NotificationFrame
		})

		local NotificationFrame_Stroke = Create("UIStroke", {
			Parent = NotificationFrame,
			Thickness = 1.2,
			Color = accentColor,
			Transparency = 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Enabled = true
		})

		local Padding = Create("UIPadding", {
			Parent = NotificationFrame,
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		})

		local closeNotifButton = Create("ImageButton", {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://7072725342",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Parent = NotificationFrame
		})

		local contentHolder = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = NotificationFrame
		})

		local textLayoutHolder = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = contentHolder
		})

		local textHolder = Create("Frame", {
			Size = UDim2.new(1, -25, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = contentHolder
		})

		local textLayoutHolder2 = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = textHolder
		})

		local Icon = Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			LayoutOrder = 1,
			ImageTransparency = 1,
			Parent = textHolder
		})

		local Title = Create("TextLabel", {
			Parent = textHolder,
			Size = UDim2.new(1, -32, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = NotificationConfig.Title,
			TextTransparency = 1,
			LayoutOrder = 2
		})

		if NotificationConfig.Image and (NotificationConfig.Image ~= nil and NotificationConfig.Image ~= "") then
			applyIcon(Icon, NotificationConfig.Image)
		else
			Icon:Destroy()
			Title.Size = UDim2.new(1, 0, 0, 0)
		end

		local Content = Create("TextLabel", {
			Parent = contentHolder,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.GothamSemibold,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextTransparency = 1,
			LayoutOrder = 2,
			Text = NotificationConfig.Content
		})

		local ProgressBarParent = Create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Parent = NotificationFrame,
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, 1, 5),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(60,60,60),
			BorderSizePixel = 0
		})
		Create("UICorner", {
			Parent = ProgressBarParent,
			CornerRadius = UDim.new(0, 3)
		})

		local ProgressBar = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0),
			Parent = ProgressBarParent,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0
		})
		Create("UICorner", {
			Parent = ProgressBar,
			CornerRadius = UDim.new(0, 3)
		})

		local SlideInTween = TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { 
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0
		})

		local barTween = TweenService:Create(ProgressBar, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		})

		SlideInTween:Play()

		local function DismissNotification()
			if isDismissed then return end
			isDismissed = true

			barTween:Cancel()

			NotificationParent.Size = UDim2.new(1, 0, 0, NotificationFrame.AbsoluteSize.Y)
			NotificationParent.AutomaticSize = Enum.AutomaticSize.None

			TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 50, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			if Icon and Icon.Parent then
				TweenService:Create(Icon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			end

			task.wait(0.25)

			local shrinkTween = TweenService:Create(NotificationParent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1, 0, 0, 0)
			})
			shrinkTween:Play()
			shrinkTween.Completed:Connect(function()
				NotificationParent:Destroy()
			end)
		end

		SlideInTween.Completed:Connect(function()
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			if Icon and Icon.Parent then
				TweenService:Create(Icon, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
			end

			task.wait(0.25)

			if (typeof(NotificationConfig.Time) == "string" and NotificationConfig.Time == "inf") or NotificationConfig.Time == 0 then
				ProgressBarParent:Destroy()
			else
				barTween:Play()

				task.delay(NotificationConfig.Time, function()
					if not isDismissed then
						DismissNotification()
					end
				end)
			end
		end)

		closeNotifButton.MouseButton1Click:Connect(DismissNotification)
	end)
end

local function Popup(config)
	config = config or {}
	config.Title = config.Title or "Confirmation"
	config.Content = config.Content or "Are you sure you want to proceed?"
	config.Mode = config.Mode or "Alert"
	config.AcceptText = config.AcceptText or (config.Mode == "YesNo" and "Yes" or "OK")
	config.CancelText = config.CancelText or "No"
	config.OnAccept = config.OnAccept or function() end
	config.OnCancel = config.OnCancel or function() end

	local overlay = Instance.new("TextButton") -- Memakai TextButton agar menghentikan input ke UI di belakangnya
	overlay.Name = "PopupOverlay"
	overlay.Parent = EtherExecutor
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 15

	local popupFrame = Instance.new("Frame")
	local popupCorner = Instance.new("UICorner")
	local popupStroke = Instance.new("UIStroke")
	local titleLabel = Instance.new("TextLabel")
	local contentLabel = Instance.new("TextLabel")
	local buttonHolder = Instance.new("Frame")
	local buttonLayout = Instance.new("UIListLayout")

	popupFrame.Name = "PopupFrame"
	popupFrame.Parent = overlay
	popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	popupFrame.Size = UDim2.new(0, 320, 0, 160)
	popupFrame.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
	popupFrame.ClipsDescendants = true
	popupFrame.ZIndex = 15

	popupCorner.CornerRadius = UDim.new(0, 8)
	popupCorner.Parent = popupFrame

	popupStroke.Color = Color3.fromRGB(60, 64, 72)
	popupStroke.Thickness = 1
	popupStroke.Parent = popupFrame

	titleLabel.Name = "Title"
	titleLabel.Parent = popupFrame
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 15, 0, 12)
	titleLabel.Size = UDim2.new(1, -30, 0, 20)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = config.Title
	titleLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	contentLabel.Name = "Content"
	contentLabel.Parent = popupFrame
	contentLabel.BackgroundTransparency = 1
	contentLabel.Position = UDim2.new(0, 15, 0, 38)
	contentLabel.Size = UDim2.new(1, -30, 0, 60)
	contentLabel.Font = Enum.Font.SourceSans
	contentLabel.Text = config.Content
	contentLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
	contentLabel.TextSize = 14
	contentLabel.TextWrapped = true
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top

	buttonHolder.Name = "ButtonHolder"
	buttonHolder.Parent = popupFrame
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Position = UDim2.new(0, 15, 1, -42)
	buttonHolder.Size = UDim2.new(1, -30, 0, 30)

	buttonLayout.Parent = buttonHolder
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.Padding = UDim.new(0, 8)

	local function createButton(text, bgCol, callback)
		local btn = Instance.new("TextButton")
		local btnCorner = Instance.new("UICorner")
		local btnConn

		btn.Parent = buttonHolder
		btn.Size = UDim2.new(0, config.Mode == "YesNo" and 90 or 100, 1, 0)
		btn.BackgroundColor3 = bgCol
		btn.Font = Enum.Font.SourceSansBold
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(245, 246, 250)
		btn.TextSize = 14
		btn.ZIndex = 1002

		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn

		btnConn = btn.MouseButton1Click:Connect(function()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(overlay, tweenInfo, {BackgroundTransparency = 1}):Play()
			local closeTween = TweenService:Create(popupFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
			closeTween:Play()
			
			closeTween.Completed:Connect(function()
				if btnConn then btnConn:Disconnect() end
				overlay:Destroy()
				if callback then
					execCallback(callback, config)
				end
			end)
		end)
	end

	if config.Mode == "YesNo" then
		createButton(config.CancelText, Color3.fromRGB(72, 84, 96), config.OnCancel)
		createButton(config.AcceptText, Color3.fromRGB(232, 65, 24), config.OnAccept)
	else
		createButton(config.AcceptText, Color3.fromRGB(9, 132, 227), config.OnAccept)
	end

	popupFrame.Size = UDim2.new(0, 320, 0, 0)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
	TweenService:Create(popupFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 160)}):Play()
end

local UIWindow = Create("Frame", {
	Name = tostring(createUIName()),
	Parent = EtherExecutor,
	BackgroundTransparency = 1,
	Position = UDim2.new(0,340,0,300),
	Size = UDim2.new(0,340,0,300),
	Active = false,
	ClipsDescendants = true
})

local MainFrameParent = Create("Frame", {
	Name = tostring(createUIName()),
	Parent = UIWindow,
	BackgroundTransparency = 1,
	BorderColor3 = Color3.fromRGB(0, 151, 230),
	Position = UDim2.new(0,0,0,0),
	Size = UDim2.new(1,0,1,0),
	Active = false,
	ClipsDescendants = true
})

Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = MainFrameParent
})

local HeaderFrame = Create("Frame", {
	Name = "HeaderFrame",
	Parent = MainFrameParent,
	BackgroundColor3 = Color3.fromRGB(25,25,25),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Position = UDim2.new(0,0,0,0),
	Size = UDim2.new(0.8,0,0,40),
	Visible = true,
	Active = true
})

local HeaderContentFrame = Create("Frame", {
	Name = "HeaderContentFrame",
	Parent = HeaderFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(0,0,0,0),
	Size = UDim2.new(1,-60,1,0),
	Visible = true,
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderContentFrame
})

local HeaderTextFrame = Create("Frame", {
	Name = "HeaderTextFrame",
	Parent = HeaderContentFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(0,0,0,0),
	Size = UDim2.new(1,0,1,0),
	Visible = true,
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderTextFrame
})

MakeDraggable(HeaderFrame, MainFrameParent)

local ExeTitleText = Create("TextLabel", {
	Name = "TitleText",
	Parent = HeaderTextFrame,
	BackgroundColor3 = Color3.fromRGB(45,45,45),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(1,-140,0.5,0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255,255,255),
	Text = "Ether Internal Executor",
	TextSize = 18,
	TextScaled = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Visible = true,
	Active = false
})

local ExeSubTitleText = Create("TextLabel", {
	Name = "SubTitleText",
	Parent = HeaderTextFrame,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1,-140,0.5,0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255,255,255),
	Text = Version,
	TextSize = 14,
	TextScaled = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Visible = true,
	Active = false
})

local HeaderToolBarFrame = Create("Frame", {
	AnchorPoint = Vector2.new(1,0),
	Name = "HeaderToolBarFrame",
	Parent = HeaderFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(0,0,0,0),
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.new(0,0,1,0),
	Visible = true,
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderToolBarFrame
})

local DestroyBut = Create("TextButton", {
	Name = "DestroyBut",
	Parent = HeaderToolBarFrame,
	BackgroundColor3 = Color3.fromRGB(255,0,0),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(0.1,0,1,0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(242,243,243),
	Text = "×",
	TextSize = 18,
	TextScaled = false,
	TextWrapped = false,
	Visible = true,
	Active = true
})

SafeConnect(DestroyBut.MouseButton1Click, function()
  EtherLibrary:Destroy()
end)

local MinimizeBut = Create("TextButton", {
	Name = "MinimizeBut",
	Parent = HeaderToolBarFrame,
	BackgroundColor3 = Color3.fromRGB(0,0,255),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(0.1,0,1,0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(242,243,243),
	Text = "-",
	TextSize = 18,
	TextScaled = false,
	TextWrapped = false,
	Visible = true,
	Active = true
})

local minimize = false
local tweening = false

local TabHolder = Create("ScrollingFrame", {
	Name = "TabFrame",
	Parent = MainFrameParent,
	BackgroundColor3 = Color3.fromRGB(45,45,45),
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	ScrollBarThickness = 0,
	Size = UDim2.new(0,35,1,0),
	Visible = false,
	Active = true
})

local TabHolderListLayout = Create("UIListLayout", {
	Name = "TabHolderListLayout",
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = TabHolder
})

local TabHolderPadding = Create("UIPadding", {
	PaddingRight = UDim.new(0, 5),
	PaddingLeft = UDim.new(0, 5),
	Parent = TabHolder
})

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainFrameParent
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0,0,1)
MainFrame.Size = UDim2.new(1,0,7)
MainFrame.Visible = true
MainFrame.Active = false

Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 2),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = MainFrame
})

SafeConnect(MinimizeBut.MouseButton1Click, function()
	if tweening then return end
	tweening = true

	minimize = not minimize
	local tweenTime = 0.35
	local easing = TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local SizeAnimUIOut = TweenService:Create(MainFrame, easing, {Size = UDim2.new(1, 0, 0, 0)}):Play()
	local SizeAnimUIIn = TweenService:Create(MainFrame, easing, {Size = UDim2.new(1, 0, 7, 0)}):Play()

	if minimize then
		MinimizeBut.Text = "+"
		SizeAnimUIOut:Play()
		SizeAnimUIOut.Completed:Connect(function()
			tweening = false
			MainFrame.Visible = false
		end)
	else
		MainFrame.Visible = true
		MinimizeBut.Text = "–"
		SizeAnimUIIn:Play()
		SizeAnimUIIn.Completed:Connect(function()
			tweening = false
		end)
	end
end)

local window = {
	_autoSaveConnected = false,
	tabs = {},
	activeTab = nil
}

local function window:AddTab(TabConfig)
	TabConfig = TabConfig or {}
	TabConfig.Title = TabConfig.Title or "Main"
	TabConfig.Icon = TabConfig.Icon or "sword"
	TabConfig.IsAutoLayout = TabConfig.IsAutoLayout or false

	local tab = {
		type = "tab",
		title = TabConfig.Title,
		buttonInstance = nil,
		buttonTitle = nil,
		containerInstance = nil
	}

	local tabButtonFrame = Create("Frame", {
		Name = TabConfig.Title,
		Parent = TabHolder,
		BackgroundColor3 = Color3.fromRGB(45,45,45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,0,30),
		Visible = true,
		Active = true
	})

	local tabButton = Create("TextButton", {
		Name = "_Button",
		Parent = tabButtonFrame,
		BackgroundColor3 = Color3.fromRGB(25,25,25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,1,0),
		Font = Enum.Font.GothamSemibold,
		TextTransparency = 1,
		Visible = true,
		Active = false
	})

	local ListLayouttt = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabButton
	})

	local PadLayouttt = Create("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		Parent = tabButton
	})

	local Iccon = Create("ImageLabel", {
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "Icon",
		LayoutOrder = 1,
		Parent = tabButton
	})

	if TabConfig.Icon and (TabConfig.Icon ~= nil and TabConfig.Icon ~= "") then
		applyIcon(Iccon, TabConfig.Icon)
	else
		Iccon:Destroy()
	end

	local tabButtonTitle = Create("TextLabel", {
		LayoutOrder = 2,
		Parent = tabButton,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(25,25,25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,0,0),
		Font = Enum.Font.GothamSemibold,
		Text = TabConfig.Title,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = true,
		Active = false
	})
	AddThemeObject(tabButtonTitle, "NormalText", "TextColor3")

	local tabContainer = Create("ScrollingFrame", {
		Name = "Content_" .. TabConfig.Title,
		Parent = window.contentArea,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ScrollBarThickness = 0,
		Size = UDim2.new(1,0,1,0),
		Visible = false,
		Active = true
	})

	Create("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 0),
		PaddingLeft = UDim.new(0, 0),
		Parent = tabContainer
	})

	if TabConfig.IsAutoLayout then
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabContainer
		})
	end

	tab.buttonTitle = tabButtonTitle
	tab.buttonInstance = tabButtonFrame
	tab.containerInstance = tabContainer

	function tab:Select()
		for _, otherTab in ipairs(window.tabs) do
			if otherTab.containerInstance then
				otherTab.containerInstance.Visible = false
			end
			if otherTab.buttonInstance then
				otherTab.buttonInstance.BackgroundTransparency = 1
			end
			if otherTab.buttonTitle then
				otherTab.buttonTitle.TextTransparency = 0.2
			end
		end

		tab.containerInstance.Visible = true
		tab.buttonInstance.BackgroundTransparency = 0
		tab.buttonTitle.TextTransparency = 0
		window.activeTab = tab
	end

	tabButton.MouseButton1Click:Connect(function()
		tab:Select()
	end)

	table.insert(window.tabs, tab)

	if #window.tabs == 1 then
		if window.activeTab == nil then
			tab:Select()
		end
	end

	return tab
end

local exeTabs = {
	CodeTab = window:AddTab({Title = "Code", Icon = "code"}),
	InfoTab = window:AddTab({Title = "Info", Icon = "info"})
}

local EditorHolder = Instance.new("ScrollingFrame") 
EditorHolder.Name = "EditorHolder"
EditorHolder.Parent = exeTabs.CodeTab.containerInstance
EditorHolder.BackgroundColor3 = Color3.fromRGB(25,25,25)
EditorHolder.BackgroundTransparency = 0
EditorHolder.BorderSizePixel = 0
EditorHolder.Position = UDim2.new(0,5,0,5)
EditorHolder.Size = UDim2.new(0.5,0,0.8)
EditorHolder.CanvasSize = UDim2.new(0,0,0,0)
EditorHolder.ScrollBarThickness = 1
EditorHolder.ElasticBehavior = Enum.ElasticBehavior.Never
EditorHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
EditorHolder.ScrollingDirection = Enum.ScrollingDirection.Y
EditorHolder.Visible = true
EditorHolder.Active = false

local lineText = Instance.new("TextLabel", EditorHolder)
lineText.Size = UDim2.new(0,40,1,0)
lineText.BackgroundColor3 = Color3.fromRGB(20,20,20)
lineText.Position = UDim2.new(0,0,0,0)
lineText.BackgroundTransparency = 0
lineText.Font = Enum.Font.Code
lineText.TextSize = 14
lineText.TextXAlignment = Enum.TextXAlignment.Right
lineText.TextYAlignment = Enum.TextYAlignment.Top
lineText.TextColor3 = Color3.fromRGB(100,100,100)
lineText.Text = "1"

local Highlighter1 = Instance.new("TextLabel") 
Highlighter1.Name = "Editor_Script_Highlighter"
Highlighter1.Parent = EditorHolder
Highlighter1.BackgroundColor3 = Color3.fromRGB(25,25,25)
Highlighter1.BackgroundTransparency = 1
Highlighter1.BorderSizePixel = 0
Highlighter1.Position = UDim2.new(0,43,0,0)
Highlighter1.Size = UDim2.new(1,0,1,0)
Highlighter1.Font = Enum.Font.Code
Highlighter1.TextColor3 = Color3.fromRGB(255,255,255)
Highlighter1.Text = ""
Highlighter1.TextScaled = false
Highlighter1.TextWrapped = false
Highlighter1.TextSize = 14
Highlighter1.TextXAlignment = Enum.TextXAlignment.Left
Highlighter1.TextYAlignment = Enum.TextYAlignment.Top
Highlighter1.RichText = true
Highlighter1.Visible = true
Highlighter1.Active = false

local TextBox1 = Instance.new("TextBox") 
TextBox1.Name = "Editor_Script"
TextBox1.Parent = EditorHolder
TextBox1.BackgroundColor3 = Color3.fromRGB(25,25,25)
TextBox1.BackgroundTransparency = 1
TextBox1.BorderSizePixel = 0
TextBox1.Position = UDim2.new(0,43,0,0)
TextBox1.Size = UDim2.new(1,0,1,0)
TextBox1.Font = Enum.Font.Code
TextBox1.TextColor3 = Color3.fromRGB(255,255,255)
TextBox1.Text = "-- Paste/Write your script here!"
TextBox1.PlaceholderText = ""
TextBox1.TextScaled = false
TextBox1.TextWrapped = false
TextBox1.TextSize = 14
TextBox1.MultiLine = true
TextBox1.ClearTextOnFocus = false
TextBox1.TextXAlignment = Enum.TextXAlignment.Left
TextBox1.TextYAlignment = Enum.TextYAlignment.Top
TextBox1.RichText = true
TextBox1.Visible = true
TextBox1.Active = true

local function autoSizeEditor(target, line, scroll)
    local textBounds = target.TextBounds
    local frameSize = scroll.AbsoluteSize
    local padding = 0
    local text = target.Text
    local lines = select(2, text:gsub("\n", "")) + 1
    local list = {}
    for i = 1, lines do
        list[#list+1] = tostring(i)
    end
    line.Text = table.concat(list, "\n")
    
    local newWidth = math.max(textBounds.X + padding, frameSize.X)
    local newHeight = math.max(textBounds.Y + padding, frameSize.Y)
    
    target.Size = UDim2.new(0, newWidth, 0, newHeight)
    line.Size = UDim2.new(0,40,0,newHeight)
end

local function updateHighlighter(TextBox, Highlighter, Scroll, pd)
  local textBounds = TextBox.TextBounds
  local frameSize = Scroll.AbsoluteSize
  local padding = pd or 0
  
  local newWidth = math.max(textBounds.X + padding, frameSize.X)
  local newHeight = math.max(textBounds.Y + padding, frameSize.Y)
  
  Highlighter.Size = UDim2.new(0, newWidth, 0, newHeight)
  Highlighter.Text = highlighter.run(TextBox.Text)
end

local function autoSizeUniversal(TextBox, Scroll, pd)
  local textBounds = TextBox.TextBounds
  local frameSize = Scroll.AbsoluteSize
  local padding = pd or 0
  
  local newWidth = math.max(textBounds.X + padding, frameSize.X)
  local newHeight = math.max(textBounds.Y + padding, frameSize.Y)
  
  TextBox.Size = UDim2.new(0, newWidth, 0, newHeight)
end

local function autoSizeUniversalY(TextBox, Scroll, pd)
  local textBounds = TextBox.TextBounds
  local frameSize = Scroll.AbsoluteSize
  local padding = pd or 0
  
  local newWidth = math.max(textBounds.X + padding, frameSize.X)
  local newHeight = math.max(textBounds.Y + padding, frameSize.Y)
  
  TextBox.Size = UDim2.new(0, newWidth, 0, newHeight)
end

TextBox1.Focused:Connect(function()
  TextBox1.Size = UDim2.new(1,0,1,0)
  TextBox1.TextTransparency = 0
  Highlighter1.Size = UDim2.new(1,0,1,0)
  Highlighter1.TextTransparency = 1
  lineText.Size = UDim2.new(0,40,1,0)
  EditorHolder.CanvasSize = UDim2.new(0,0,0,0)
end)

TextBox1.FocusLost:Connect(function()
  autoSizeEditor(TextBox1, lineText, EditorHolder)
  updateHighlighter(TextBox1, Highlighter1, EditorHolder)
  Highlighter1.TextTransparency = 0
  TextBox1.TextTransparency = 1
end)

local Copy_Editor_Scripts = Instance.new("TextButton")
Copy_Editor_Scripts.Name = "Copy_Editor_Scripts"
Copy_Editor_Scripts.Parent = exeTabs.CodeTab.containerInstance
Copy_Editor_Scripts.BackgroundColor3 = Color3.fromRGB(25,25,25)
Copy_Editor_Scripts.BackgroundTransparency = 0
Copy_Editor_Scripts.BorderSizePixel = 0
Copy_Editor_Scripts.Position = UDim2.new(0.35,5,0.8,10)
Copy_Editor_Scripts.Size = UDim2.new(0.15,0,0,30)
Copy_Editor_Scripts.Font = Enum.Font.SourceSansBold
Copy_Editor_Scripts.TextColor3 = Color3.fromRGB(255,255,255)
Copy_Editor_Scripts.Text = "Copy Editor Scripts"
Copy_Editor_Scripts.TextSize = 14
Copy_Editor_Scripts.TextTransparency = 0
Copy_Editor_Scripts.TextScaled = false
Copy_Editor_Scripts.TextWrapped = false
Copy_Editor_Scripts.Visible = true
Copy_Editor_Scripts.Active = true

Copy_Editor_Scripts.MouseButton1Click:Connect(function()
  setclipboard(TextBox1.Text)
end)

local Clear_Editor_Scripts = Instance.new("TextButton")
Clear_Editor_Scripts.Name = "Clear_Editor_Scripts"
Clear_Editor_Scripts.Parent = exeTabs.CodeTab.containerInstance
Clear_Editor_Scripts.BackgroundColor3 = Color3.fromRGB(25,25,25)
Clear_Editor_Scripts.BackgroundTransparency = 0
Clear_Editor_Scripts.BorderSizePixel = 0
Clear_Editor_Scripts.Position = UDim2.new(0.2,-13,0.8,10)
Clear_Editor_Scripts.Size = UDim2.new(0.15,0,0,30)
Clear_Editor_Scripts.Font = Enum.Font.SourceSansBold
Clear_Editor_Scripts.TextColor3 = Color3.fromRGB(255,255,255)
Clear_Editor_Scripts.Text = "Clear Editor Scripts"
Clear_Editor_Scripts.TextSize = 14
Clear_Editor_Scripts.TextTransparency = 0
Clear_Editor_Scripts.TextScaled = false
Clear_Editor_Scripts.TextWrapped = false
Clear_Editor_Scripts.Visible = true
Clear_Editor_Scripts.Active = true

Clear_Editor_Scripts.MouseButton1Click:Connect(function()
  TextBox1.Text = ""
  autoSizeEditor(TextBox1, lineText, EditorHolder)
end)

local Execute_Editor_Scripts = Instance.new("TextButton")
Execute_Editor_Scripts.Name = "Execute_Editor_Scripts"
Execute_Editor_Scripts.Parent = exeTabs.CodeTab.containerInstance
Execute_Editor_Scripts.BackgroundColor3 = Color3.fromRGB(25,25,25)
Execute_Editor_Scripts.BackgroundTransparency = 0
Execute_Editor_Scripts.BorderSizePixel = 0
Execute_Editor_Scripts.Position = UDim2.new(0,5,0.8,10)
Execute_Editor_Scripts.Size = UDim2.new(0.15,0,0,30)
Execute_Editor_Scripts.Font = Enum.Font.SourceSansBold
Execute_Editor_Scripts.TextColor3 = Color3.fromRGB(255,255,255)
Execute_Editor_Scripts.Text = "Execute Scripts"
Execute_Editor_Scripts.TextSize = 14
Execute_Editor_Scripts.TextTransparency = 0
Execute_Editor_Scripts.TextScaled = false
Execute_Editor_Scripts.TextWrapped = false
Execute_Editor_Scripts.Visible = true
Execute_Editor_Scripts.Active = true

Execute_Editor_Scripts.MouseButton1Click:Connect(function()
  executeSource(TextBox1.Text, "=Editor1")
end)

local Credits = Instance.new("TextLabel") 
Credits.Name = "Credits"
Credits.Parent = exeTabs.InfoTab.containerInstance
Credits.BackgroundColor3 = Color3.fromRGB(25,25,25)
Credits.BackgroundTransparency = 0
Credits.Position = UDim2.new(0,5,0,5)
Credits.Size = UDim2.new(0.2,0,0,30)
Credits.Font = Enum.Font.GothamBlack
Credits.TextColor3 = Color3.fromRGB(255,255,255)
Credits.Text = "Credits:"
Credits.TextSize = 20
Credits.TextScaled = false
Credits.TextWrapped = false
Credits.Visible = true
Credits.Active = false

local Credits_Text = Credits:Clone()
Credits_Text.Name = "Credits_Text"
Credits_Text.Parent = exeTabs.InfoTab.containerInstance
Credits_Text.Position = UDim2.new(0,5,0,40)
Credits_Text.BackgroundTransparency = 0
Credits_Text.Size = UDim2.new(1,-10,0.3,0)
Credits_Text.Font = Enum.Font.GothamSemibold
Credits_Text.Text = "This script is using an API for Obfuscate function\nAPI is from ghostplayer on YouTube\nThis script was made by LucidSc1pt"
Credits_Text.TextSize = 18
Credits_Text.TextScaled = false
Credits_Text.TextWrapped = false
Credits_Text.TextTransparency = 0
Credits_Text.Visible = true
Credits_Text.Active = false

local versions = {}
for version in pairs(changeList) do
	table.insert(versions, version)
end
table.sort(versions)

local combinedText = "📜 All Versions:\n\n"
for i = #versions, 1, -1 do
	local version = versions[i]
	local logs = changeList[version]
	combinedText = combinedText .. "[" .. version .. "]\n"
	combinedText = combinedText .. table.concat(logs, "\n") .. "\n\n"
end

local Changelog = Credits:Clone()
Changelog.Name = "Changelog"
Changelog.Parent = exeTabs.InfoTab.containerInstance
Changelog.Position = UDim2.new(0,5,0.5,5)
Changelog.BackgroundTransparency = 0
Changelog.Size = UDim2.new(0.2,0,0,30)
Changelog.Font = Enum.Font.GothamBlack
Changelog.Text = "📜 Changelog:"
Changelog.TextSize = 20
Changelog.TextScaled = false
Changelog.TextWrapped = false
Changelog.Visible = true
Changelog.Active = false

local Changelog_Text_Holder = Instance.new("ScrollingFrame") 
Changelog_Text_Holder.Name = "Output_Scripts_Holder2"
Changelog_Text_Holder.Parent = exeTabs.InfoTab.containerInstance
Changelog_Text_Holder.BackgroundColor3 = Color3.fromRGB(25,25,25)
Changelog_Text_Holder.BackgroundTransparency = 0
Changelog_Text_Holder.BorderSizePixel = 0
Changelog_Text_Holder.Position = UDim2.new(0,5,0.6,17)
Changelog_Text_Holder.Size = UDim2.new(1,-10,0.3,0)
Changelog_Text_Holder.CanvasSize = UDim2.new(0,0,0,0)
Changelog_Text_Holder.ScrollBarThickness = 1
Changelog_Text_Holder.ElasticBehavior = Enum.ElasticBehavior.Never
Changelog_Text_Holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
Changelog_Text_Holder.ScrollingDirection = Enum.ScrollingDirection.Y
Changelog_Text_Holder.Visible = true
Changelog_Text_Holder.Active = false

local Changelog_Text_Holder_Padding = Instance.new("UIPadding")
Changelog_Text_Holder_Padding.PaddingLeft = UDim.new(0,5)
Changelog_Text_Holder_Padding.Parent = Changelog_Text_Holder

local Changelog_Text = Credits:Clone()
Changelog_Text.Name = "Changelog_Text"
Changelog_Text.Parent = Changelog_Text_Holder
Changelog_Text.Position = UDim2.new(0,0,0,0)
Changelog_Text.BackgroundTransparency = 1
Changelog_Text.Size = UDim2.new(0,0,0,0)
Changelog_Text.Font = Enum.Font.GothamSemibold
Changelog_Text.Text = combinedText
Changelog_Text.TextXAlignment = Enum.TextXAlignment.Left
Changelog_Text.TextSize = 18
Changelog_Text.TextScaled = false
Changelog_Text.TextWrapped = false
Changelog_Text.TextTransparency = 0
Changelog_Text.Visible = true
Changelog_Text.Active = false

autoSizeUniversal(Changelog_Text, Changelog_Text_Holder, 0)

Notification({
    Title = "Loaded!",
    Content = "Ether Internal Executor",
    Time = 5
})