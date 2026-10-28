-- core/ui_components.lua
local Ether = getgenv().Ether
if not Ether then return end

local TweenService = Ether.TweenService
local HttpService = Ether.HttpService

-- ========== ADVANCED HUB API ==========
local AdvancedHub = {}
AdvancedHub.__index = AdvancedHub

function AdvancedHub.new()
	return setmetatable({
		engines = { "RScripts", "RobloxScripts", "ScriptBlox", "HaxHell" },
		currentEngine = "RScripts",
		pagination = { current = 1, total = 1, query = "", hasResults = false },
		currentPageScripts = {},
		filterModes = { "Default", "Views", "Likes", "A-Z" },
		filterMode = "Default",
		searching = false,
		savedScriptsCache = {}
	}, AdvancedHub)
end

-- [KEMBALIKAN FUNGSI TOAST DI SINI]
function AdvancedHub:Toast(msg, parent)
	local toast = Ether.Create("TextLabel", {
		Size = UDim2.new(0, 260, 0, 30), Position = UDim2.new(0.5, -130, 1, -40),
		BackgroundColor3 = Color3.fromRGB(30, 144, 255), Text = msg,
		TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
		TextSize = 12, ZIndex = 200, Parent = parent
	})
	if toast then
		Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toast })
		TweenService:Create(toast, TweenInfo.new(0.3), { Position = UDim2.new(0.5, -130, 1, -70) }):Play()
		task.delay(2, function()
			TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.wait(0.3)
			toast:Destroy()
		end)
	end
end

function AdvancedHub:Fetch(engine, query, page)
	page = page or 1 query = query or "" local encoded = Ether.urlEncode(query) local url = ""
	if engine == "RScripts" then
		url = string.format("https://rscripts.net/api/v2/scripts?page=%d&orderBy=date&sort=desc", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	elseif engine == "RobloxScripts" then
		url = string.format("https://robloxscripts.com/api/v1/scripts?page=%d&limit=24&sort=newest", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	elseif engine == "HaxHell" then
		if query == "" then url = string.format("https://haxhell.com/api/v1/scripts?page=%d&limit=20", page)
		else url = string.format("https://haxhell.com/api/v1/search/scripts?q=%s&page=%d&limit=20", encoded, page) end
	else
		if query == "" then url = string.format("https://scriptblox.com/api/script/fetch?page=%d", page)
		else url = string.format("https://scriptblox.com/api/script/search?q=%s&page=%d", encoded, page) end
	end
	
	local ok, body = Ether.universalHttpGet(url) if not ok then return {}, 1 end
	local ok2, dec = pcall(HttpService.JSONDecode, HttpService, body) if not ok2 or not dec then return {}, 1 end
	
	local data, totalPages = {}, 1
	if engine == "RScripts" then
		data = dec.scripts or {} totalPages = dec.info and dec.info.maxPages or dec.totalPages or 1
	elseif engine == "RobloxScripts" then
		data = dec.data or {} local pag = dec.pagination or {} totalPages = tonumber(pag.totalPages or pag.pages or pag.lastPage or 1) or 1
		if pag.total and pag.limit then totalPages = math.ceil(pag.total / math.max(pag.limit, 1)) end
		totalPages = math.min(totalPages, 200)
	elseif engine == "HaxHell" then
		data = dec.data or {} local pag = dec.pagination or {} totalPages = tonumber(pag.totalPages or 1) or 1
	else
		local result = dec.result or {} data = result.scripts or {} totalPages = result.totalPages or 1
	end
	
	local normalized = {}
	for _, item in ipairs(data) do
		if engine == "RScripts" then
			table.insert(normalized, { title = item.title or "No Title", author = item.creator and item.creator.username or item.owner or "Anon", description = item.description or "", views = item.views or 0, likes = item.likes or item.likeCount or 0, source = engine, scriptCode = "", rawUrl = item.rawScript or item.scriptLink or item.raw or item.rawScriptUrl or "", isUrl = true, _raw = item, gameId = item.gameId or (item.game and item.game.gameId) or item.placeId or (item.game and item.game.placeId) })
		elseif engine == "HaxHell" then
			table.insert(normalized, { title = item.title or "No Title", author = item.author and item.author.username or "Anon", description = item.description or "", views = item.stats and item.stats.views or 0, likes = item.stats and item.stats.likes or 0, source = engine, scriptCode = "", rawUrl = item.links and item.links.raw or "", isUrl = true, _raw = item, gameId = item.game and item.game.placeId })
		else
			local directCode = item.script or item.code or "" local rawUrl = item.rawScriptUrl or item.scriptLink or item.raw or ""
			local isUrl = rawUrl ~= "" and directCode == "" if not isUrl then rawUrl = "" end
			table.insert(normalized, { title = item.title or "No Title", author = item.creator and item.creator.username or item.owner or "Anon", description = item.description or "", views = item.views or 0, likes = item.likes or item.likeCount or 0, source = engine, scriptCode = directCode, rawUrl = rawUrl, isUrl = isUrl, _raw = item, gameId = item.gameId or (item.game and item.game.gameId) or item.placeId or (item.game and item.game.placeId) })
		end
	end
	return normalized, totalPages
end

function AdvancedHub:SaveAsFile(data, extension)
	extension = tostring(extension or "lua"):gsub("[^%w]", ""):lower() if extension == "" then extension = "lua" end
	local safeName = (data.title or "script"):gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1, 40) if safeName == "" then safeName = "script_" .. os.time() end
	local filePath = Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder .. "/" .. safeName .. "." .. extension
	local header = string.format("--[[ Saved from Ether Executor\n   Title: %s\n   Source: %s\n   SavedAt: %s\n   Format: .%s\n]]\n\n", data.title or "Untitled", data.source or "Unknown", os.date("%Y-%m-%d %H:%M:%S"), extension)
	local fullCode = header .. (data.scriptCode or "")
	if writefile then local ok, err = pcall(writefile, filePath, fullCode) if ok then return true, filePath else warn(err) return false end end return false
end

function AdvancedHub:LoadSavedScripts()
	local folder = Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder
	if not (isfolder and isfolder(folder) and listfiles) then return {} end
	local ok, files = pcall(listfiles, folder) if not ok or type(files) ~= "table" then return {} end
	local results = {}
	for _, f in ipairs(files) do
		local lower = f:lower()
		if lower:sub(-5) == ".json" then
			local ok2, content = pcall(readfile, f) if ok2 then local ok3, data = pcall(HttpService.JSONDecode, HttpService, content) if ok3 and data then table.insert(results, { filePath = f, fileName = f:match("([^/\\]+)%.json$") or "old", title = data.title or "Old JSON", code = data.code or "", isLua = false, isOldJson = true, ext = "json" }) end end
		else
			local ok2, content = pcall(readfile, f) if ok2 and content then local fileName = f:match("([^/\\]+)%.%w+$") or (f:match("([^/\\]+)$") or "Untitled") local baseName = f:match("([^/\\]+)%.%w+$") or fileName local ext = f:match("%.(%w+)$") or "lua" local headerTitle = content:match("Title:%s*(.-)\n") local title = headerTitle or baseName:gsub("_", " ") table.insert(results, { filePath = f, fileName = fileName, title = title, code = content, isLua = (ext:lower() == "lua"), ext = ext }) end
		end
	end
	table.sort(results, function(a, b) return a.title:lower() < b.title:lower() end) self.savedScriptsCache = results
	return results
end

Ether.AdvancedHub = AdvancedHub
Ether.hub = AdvancedHub.new()

-- ========== NOTIFICATION ==========
function Ether.getNotificationContainer()
	local container = Ether.EtherExecutor:FindFirstChild("NotificationHolder")
	if not container then
		container = Ether.Create("Frame", { Name="NotificationHolder", Parent=Ether.EtherExecutor, AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-25,1,-25), Size=UDim2.new(0,240,1,-25), BackgroundTransparency=1, ClipsDescendants=false, ZIndex=99 })
		Ether.Create("UIListLayout", { Parent=container, SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5) })
	end
	return container
end

function Ether.Notification(Config)
	task.spawn(function()
		Config = Config or {}
		local TitleText = Config.Title or Config.Name or "Notification"
		local ContentText = Config.Content or Config.Desc or "Hello World"
		local ImageId = Config.Image or Config.Icon or 4384403532
		local Type = Config.Type or "Info"
		local Time = Config.Time or Config.Duration or 5
		local accentColors = { Info=Color3.fromRGB(52,152,219), Success=Color3.fromRGB(46,204,113), Warning=Color3.fromRGB(241,196,15), Error=Color3.fromRGB(231,76,60) }
		local accentColor = accentColors[Type] or accentColors.Info
		local isDismissed = false
		local NotificationHolder = Ether.getNotificationContainer()
		local NotificationParent = Ether.Create("Frame", { Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, ClipsDescendants=false, Parent=NotificationHolder })
		local NotificationFrame = Ether.Create("Frame", { Size=UDim2.new(1,0,1,0), Position=UDim2.new(1,50,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=Ether.Themes.Default.WindowBackground, BackgroundTransparency=1, Parent=NotificationParent })
		Ether.Create("UICorner", { CornerRadius=UDim.new(0.1,0), Parent=NotificationFrame })
		local Stroke = Ether.Create("UIStroke", { Parent=NotificationFrame, Thickness=1.2, Color=accentColor, Transparency=0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border })
		Ether.Create("UIPadding", { Parent=NotificationFrame, PaddingTop=UDim.new(0,8), PaddingBottom=UDim.new(0,12), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10) })
		local CloseBtn = Ether.Create("ImageButton", { AnchorPoint=Vector2.new(1,0), Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,0,0,0), BackgroundTransparency=1, Image="rbxassetid://7072725342", Parent=NotificationFrame })
		local ContentHolder = Ether.Create("Frame", { Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=NotificationFrame })
		Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Vertical, HorizontalAlignment=Enum.HorizontalAlignment.Left, Padding=UDim.new(0,8), Parent=ContentHolder })
		local TextHolder = Ether.Create("Frame", { Size=UDim2.new(1,-25,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=ContentHolder })
		Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8), Parent=TextHolder })
		local Icon = Ether.Create("ImageLabel", { Size=UDim2.new(0,24,0,24), BackgroundTransparency=1, ImageTransparency=1, Parent=TextHolder })
		local Title = Ether.Create("TextLabel", { Size=UDim2.new(1,-32,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), TextSize=14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Text=TitleText, TextTransparency=1, Parent=TextHolder })
		if ImageId and ImageId ~= "" then Ether.applyIcon(Icon, ImageId) else Icon:Destroy() end
		local Content = Ether.Create("TextLabel", { Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, Font=Enum.Font.GothamSemibold, TextColor3=Color3.fromRGB(220,220,220), TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, TextTransparency=1, Text=ContentText, Parent=ContentHolder })
		local SlideIn = TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position=UDim2.new(0,0,0,0), BackgroundTransparency=0 })
		
		local function Dismiss()
			if isDismissed then return end isDismissed = true
			TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position=UDim2.new(1,50,0,0), BackgroundTransparency=1 }):Play()
			TweenService:Create(Stroke, TweenInfo.new(0.2), { Transparency=1 }):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), { TextTransparency=1 }):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), { TextTransparency=1 }):Play()
			if Icon and Icon.Parent then TweenService:Create(Icon, TweenInfo.new(0.2), { ImageTransparency=1 }):Play() end
			task.wait(0.3) NotificationParent:Destroy()
		end
		CloseBtn.MouseButton1Click:Connect(Dismiss) SlideIn:Play()
		SlideIn.Completed:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.2), { Transparency=0 }):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), { TextTransparency=0 }):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), { TextTransparency=0 }):Play()
			if Icon and Icon.Parent then TweenService:Create(Icon, TweenInfo.new(0.2), { ImageTransparency=0 }):Play() end
			if Time > 0 then task.delay(Time, Dismiss) end
		end)
	end)
end

-- ========== POPUP ==========
function Ether.Popup(config)
	config = config or {}
	config.Title = config.Title or "Confirmation"
	config.Content = config.Content or "Are you sure you want to proceed?"
	config.Mode = config.Mode or "Alert"
	config.AcceptText = config.AcceptText or (config.Mode == "YesNo" and "Yes" or "OK")
	config.CancelText = config.CancelText or "No"
	config.OnAccept = config.OnAccept or function() end
	config.OnCancel = config.OnCancel or function() end

	local overlay = Ether.Create("TextButton", { Name="PopupOverlay", Parent=Ether.EtherExecutor, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=15 })
	local popupFrame = Ether.Create("Frame", { Parent=overlay, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,320,0,160), BackgroundColor3=Color3.fromRGB(35,39,42), ClipsDescendants=true, ZIndex=15 })
	Ether.Create("UICorner", { CornerRadius=UDim.new(0,8), Parent=popupFrame })
	Ether.Create("UIStroke", { Color=Color3.fromRGB(60,64,72), Thickness=1, Parent=popupFrame })
	Ether.Create("TextLabel", { Parent=popupFrame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,12), Size=UDim2.new(1,-30,0,20), Font=Enum.Font.SourceSansBold, Text=config.Title, TextColor3=Color3.fromRGB(245,246,250), TextSize=16, TextXAlignment=Enum.TextXAlignment.Left })
	Ether.Create("TextLabel", { Parent=popupFrame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,38), Size=UDim2.new(1,-30,0,60), Font=Enum.Font.SourceSans, Text=config.Content, TextColor3=Color3.fromRGB(189,195,199), TextSize=14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top })
	local buttonHolder = Ether.Create("Frame", { Parent=popupFrame, BackgroundTransparency=1, Position=UDim2.new(0,15,1,-42), Size=UDim2.new(1,-30,0,30) })
	Ether.Create("UIListLayout", { Parent=buttonHolder, FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Right, Padding=UDim.new(0,8) })

	local function createButton(text, bgCol, callback)
		local btn = Ether.Create("TextButton", { Parent=buttonHolder, Size=UDim2.new(0,config.Mode=="YesNo" and 90 or 100,1,0), BackgroundColor3=bgCol, Font=Enum.Font.SourceSansBold, Text=text, TextColor3=Color3.fromRGB(245,246,250), TextSize=14, ZIndex=1002 })
		Ether.Create("UICorner", { CornerRadius=UDim.new(0,4), Parent=btn })
		btn.MouseButton1Click:Connect(function()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
			local closeTween = TweenService:Create(popupFrame, tweenInfo, { Size = UDim2.new(0, 0, 0, 0) })
			closeTween:Play()
			closeTween.Completed:Connect(function()
				overlay:Destroy()
				if callback then pcall(callback) end
			end)
		end)
	end

	if config.Mode == "YesNo" then
		createButton(config.CancelText, Color3.fromRGB(72,84,96), config.OnCancel)
		createButton(config.AcceptText, Color3.fromRGB(232,65,24), config.OnAccept)
	else
		createButton(config.AcceptText, Color3.fromRGB(9,132,227), config.OnAccept)
	end

	popupFrame.Size = UDim2.new(0, 320, 0, 0)
	TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.6 }):Play()
	TweenService:Create(popupFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 320, 0, 160) }):Play()
end

return Ether
