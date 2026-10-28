-- tabs/search.lua
local Ether = getgenv().Ether
if not Ether then return end

local hub = Ether.hub
local SearchTab = Ether.exeTabs.ScriptSearchTab
local EtherExecutor = Ether.EtherExecutor

local SearchContent = Ether.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = SearchTab.containerInstance })
local SearchTop = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = SearchContent })

local SearchBox = Ether.Create("TextBox", { Size = UDim2.new(0, 200, 0, 30), BackgroundColor3 = Color3.fromRGB(35, 35, 42), PlaceholderText = "Search rscripts.net...", PlaceholderColor3 = Color3.fromRGB(150, 150, 150), Text = "", TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), Parent = SearchTop })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SearchBox })

local EngineBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0, 210, 0, 0), BackgroundColor3 = Color3.fromRGB(45, 49, 58), Text = "Engine: RScripts", TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamSemibold, AutoButtonColor = false, Parent = SearchTop })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = EngineBtn })

local GoBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 0, 30), Position = UDim2.new(0, 335, 0, 0), BackgroundColor3 = Color3.fromRGB(0, 168, 255), Text = "Go", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = SearchTop })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = GoBtn })

local FilterBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 110, 0, 30), Position = UDim2.new(0, 400, 0, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Text = "Filter: Default", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, AutoButtonColor = false, Parent = SearchTop })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = FilterBtn })

local PaginationBar = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30), BackgroundTransparency = 1, Parent = SearchContent })

local function makePagBtn(text, xPos)
	local b = Ether.Create("TextButton", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, xPos, 0, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, AutoButtonColor = false, Parent = PaginationBar })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
	return b
end

local FirstBtn = makePagBtn("First", 0)
local PrevBtn = makePagBtn("Prev", 55)
local PageLbl = Ether.Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 110, 0, 0), BackgroundTransparency = 1, Text = "1 / 1", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, Parent = PaginationBar })
local NextBtn = makePagBtn("Next", 195)
local LastBtn = makePagBtn("Last", 250)

local ResultHolder = Ether.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = SearchContent })
Ether.Create("UIGridLayout", { CellSize = UDim2.new(0, 170, 0, 160), CellPadding = UDim2.new(0, 8, 0, 8), Parent = ResultHolder })

local function setNavEnabled()
	local has = hub.pagination.hasResults
	FirstBtn.Visible = has NextBtn.Visible = has PrevBtn.Visible = has LastBtn.Visible = has PageLbl.Visible = has
	PageLbl.Text = hub.pagination.current .. " / " .. hub.pagination.total
end

-- ============================================================
-- UPGRADED READ ONLY POPUP
-- ============================================================
local function createReadOnlyPopup(data)
	local overlay = Ether.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.4, ZIndex = 100, Parent = EtherExecutor })
	local popup = Ether.Create("Frame", { Size = UDim2.new(0, 600, 0, 460), Position = UDim2.new(0.5, -300, 0.5, -230), BackgroundColor3 = Color3.fromRGB(20, 20, 25), ZIndex = 101, Parent = overlay })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = popup })
	Ether.Create("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Parent = popup })

	-- HEADER INFO
	local HeaderFrame = Ether.Create("Frame", { Size = UDim2.new(1, -20, 0, 70), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Parent = popup })
	Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = data.title or "Script", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 102, Parent = HeaderFrame })
	Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = "By: " .. (data.author or "Unknown") .. " | Game: " .. (data.gameName or "Universal"), TextColor3 = Color3.fromRGB(150, 200, 255), Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = HeaderFrame })
	Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 44), BackgroundTransparency = 1, Text = "Source: " .. (data.source or "Unknown") .. " | Views: " .. tostring(data.views or 0) .. " | Likes: " .. tostring(data.likes or 0), TextColor3 = Color3.fromRGB(180, 180, 180), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = HeaderFrame })

	-- DESCRIPTION
	local DescFrame = Ether.Create("Frame", { Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, 85), BackgroundColor3 = Color3.fromRGB(30, 30, 36), ZIndex = 102, Parent = popup })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DescFrame })
	Ether.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = DescFrame })
	Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = data.description or "No description provided.", TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 103, Parent = DescFrame })

	-- CODE AREA
	local CodeScroll = Ether.Create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -205), Position = UDim2.new(0, 10, 0, 130), BackgroundColor3 = Color3.fromRGB(10, 10, 12), AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollBarThickness = 4, ZIndex = 102, Parent = popup })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CodeScroll })
	
	local cont = Ether.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = CodeScroll })
	
	local function renderCode(codeStr)
		codeStr = codeStr or "-- Failed to fetch code"
		local layers = Ether.highlighter.buildLayers(codeStr)
		for _, c in ipairs(cont:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
		for _, name in ipairs({"Numbers","Operators","Keywords","Globals","Executor","Types","Strings","Comments","Properties","Methods"}) do
			Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.Code, TextSize = 12, TextColor3 = Ether.highlighter.COLORS[name], Text = layers[name] or "", ZIndex = 103, Parent = cont })
		end
		task.spawn(function()
			local b = game:GetService("TextService"):GetTextSize(codeStr, 12, Enum.Font.Code, Vector2.new(10000, 10000))
			CodeScroll.CanvasSize = UDim2.new(0, b.X, 0, b.Y)
			cont.Size = UDim2.new(0, b.X, 0, b.Y)
		end)
		data.fetchedCode = codeStr
	end

	if data.isUrl and data.rawUrl ~= "" then
		renderCode("-- Loading from " .. data.source .. "...\n-- URL: " .. data.rawUrl)
		task.spawn(function()
			local ok, body = Ether.universalHttpGet(data.rawUrl)
			if ok and body ~= "" then renderCode(body)
			else renderCode("-- Failed to fetch from " .. data.source .. "\n-- URL: " .. data.rawUrl) end
		end)
	else
		renderCode(data.scriptCode)
	end

	-- BUTTONS
	local execBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 100, 0, 32), Position = UDim2.new(1, -330, 1, -45), BackgroundColor3 = Color3.fromRGB(40, 180, 80), Text = "Execute", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	local saveBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 100, 0, 32), Position = UDim2.new(1, -220, 1, -45), BackgroundColor3 = Color3.fromRGB(255, 165, 0), Text = "Save", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	local loadBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 100, 0, 32), Position = UDim2.new(1, -110, 1, -45), BackgroundColor3 = Color3.fromRGB(30, 144, 255), Text = "To Editor", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	for _, b in ipairs({ execBtn, saveBtn, loadBtn }) do Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b }) end
	local closeBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 10), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 106, Parent = popup })

	closeBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)
	
	execBtn.MouseButton1Click:Connect(function()
		local codeToRun = data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToRun or codeToRun:sub(1, 2) == "--") then
			local ok, body = Ether.universalHttpGet(data.rawUrl)
			if ok then codeToRun = body end
		end
		if codeToRun and codeToRun:sub(1,2) ~= "--" then Ether.executeSource(codeToRun, "=HubScript")
		else Ether.hub:Toast("Failed to load code", Ether.EtherExecutor) end
		overlay:Destroy()
	end)
	
	saveBtn.MouseButton1Click:Connect(function()
		local codeToSave = data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToSave or codeToSave:sub(1, 2) == "--") then
			local ok, body = Ether.universalHttpGet(data.rawUrl)
			if ok then codeToSave = body end
		end
		if codeToSave and codeToSave:sub(1,2) ~= "--" then
			local ok, path = hub:SaveAsFile({ title = data.title, scriptCode = codeToSave, source = data.source }, "lua")
			if ok then
				hub:Toast("Saved: " .. (path:match("([^/\\]+)$") or "?"), EtherExecutor)
				if _G.refreshSavedFn then _G.refreshSavedFn() end
			else hub:Toast("Failed save", EtherExecutor) end
		else Ether.hub:Toast("Failed to load code", Ether.EtherExecutor) end
		overlay:Destroy()
	end)
	
	loadBtn.MouseButton1Click:Connect(function()
		local codeToAdd = data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToAdd or codeToAdd:sub(1, 2) == "--") then
			local ok, body = Ether.universalHttpGet(data.rawUrl)
			if ok then codeToAdd = body end
		end
		if codeToAdd and codeToAdd:sub(1,2) ~= "--" then
			Ether.tabEditor:AddTab(data.title, codeToAdd)
			Ether.exeTabs.CodeTab:Select()
		else Ether.hub:Toast("Failed to load code", Ether.EtherExecutor) end
		overlay:Destroy()
	end)
end

-- ============================================================
-- RENDER & SEARCH LOGIC
-- ============================================================
local function renderCurrentPage()
	local list = hub.currentPageScripts
	if hub.filterMode == "Views" then table.sort(list, function(a, b) return (a.views or 0) > (b.views or 0) end)
	elseif hub.filterMode == "Likes" then table.sort(list, function(a, b) return (a.likes or 0) > (b.likes or 0) end)
	elseif hub.filterMode == "A-Z" then table.sort(list, function(a, b) return (a.title or ""):lower() < (b.title or ""):lower() end) end

	for _, c in ipairs(ResultHolder:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

	for _, data in ipairs(list) do
		local card = Ether.Create("Frame", { Size = UDim2.new(0, 170, 0, 160), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Parent = ResultHolder })
		Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = card })
		local thumb = Ether.Create("ImageLabel", { Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Image = "", ImageTransparency = 1, Parent = card })
		Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = thumb })

		local raw = data._raw or {}
		local remoteImageUrl
		if data.source == "ScriptBlox" then remoteImageUrl = Ether.resolveScriptBloxImage(raw)
		elseif data.source == "RScripts" then remoteImageUrl = Ether.resolveRScriptsImage(raw)
		elseif data.source == "HaxHell" then remoteImageUrl = Ether.resolveHaxHellImage(raw)
		else remoteImageUrl = Ether.resolveRobloxScriptsImage(raw) end
		
		local sourceUrl = remoteImageUrl
		if not sourceUrl and data.gameId then sourceUrl = Ether.buildRobloxThumbnail(data.gameId) end

		if sourceUrl then
			task.spawn(function()
				local custom = Ether.downloadImageAsset(sourceUrl)
				if custom then thumb.Image = custom thumb.ImageTransparency = 0
				elseif data.gameId then Ether.tryFetchPlaceIcon(data.gameId, thumb) end
			end)
		elseif data.gameId then Ether.tryFetchPlaceIcon(data.gameId, thumb) end

		Ether.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 5, 0, 75), BackgroundTransparency = 1, Text = (data.title or ""):sub(1, 30), TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		Ether.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 100), BackgroundTransparency = 1, Text = (data.source or "") .. " | " .. tostring(data.views or 0), TextColor3 = Color3.fromRGB(150, 200, 255), TextSize = 8, Parent = card })
		Ether.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 40), Position = UDim2.new(0, 5, 0, 115), BackgroundTransparency = 1, Text = (data.description or ""):sub(1, 60), TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 8, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = card })
		
		local btn = Ether.Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = card })
		btn.MouseButton1Click:Connect(function() createReadOnlyPopup(data) end)
	end
	setNavEnabled()
end

local function runSearch(query, page)
	if hub.searching then return end
	hub.searching = true GoBtn.Text = "..." GoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	task.spawn(function()
		local data, total = hub:Fetch(hub.currentEngine, query, page or 1)
		hub.currentPageScripts = data or {}
		hub.pagination.current = page or 1
		hub.pagination.total = total or 1
		hub.pagination.query = query or ""
		hub.pagination.hasResults = #hub.currentPageScripts > 0
		renderCurrentPage()
		hub.searching = false GoBtn.Text = "Go" GoBtn.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
		if #hub.currentPageScripts == 0 then hub:Toast("No scripts found", EtherExecutor) end
	end)
end

EngineBtn.MouseButton1Click:Connect(function()
	local idx = Ether.table_find(hub.engines, hub.currentEngine) or 1
	hub.currentEngine = hub.engines[idx % #hub.engines + 1]
	EngineBtn.Text = "Engine: " .. hub.currentEngine
	if hub.currentEngine == "RScripts" then
		SearchBox.PlaceholderText = "Search rscripts.net..." EngineBtn.BackgroundColor3 = Color3.fromRGB(45, 49, 58)
	elseif hub.currentEngine == "RobloxScripts" then
		SearchBox.PlaceholderText = "Search robloxscripts.com..." EngineBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 68)
	elseif hub.currentEngine == "HaxHell" then
		SearchBox.PlaceholderText = "Search haxhell.com..." EngineBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 60)
	else
		SearchBox.PlaceholderText = "Search scriptblox.com..." EngineBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
	end
end)

FilterBtn.MouseButton1Click:Connect(function()
	local idx = Ether.table_find(hub.filterModes, hub.filterMode) or 1
	hub.filterMode = hub.filterModes[idx % #hub.filterModes + 1]
	FilterBtn.Text = "Filter: " .. hub.filterMode
	renderCurrentPage()
end)

GoBtn.MouseButton1Click:Connect(function() runSearch(SearchBox.Text, 1) end)
SearchBox.FocusLost:Connect(function(enter) if enter then runSearch(SearchBox.Text, 1) end end)
FirstBtn.MouseButton1Click:Connect(function() runSearch(hub.pagination.query, 1) end)
PrevBtn.MouseButton1Click:Connect(function() if hub.pagination.current > 1 then runSearch(hub.pagination.query, hub.pagination.current - 1) end end)
NextBtn.MouseButton1Click:Connect(function() if hub.pagination.current < hub.pagination.total then runSearch(hub.pagination.query, hub.pagination.current + 1) end end)
LastBtn.MouseButton1Click:Connect(function() runSearch(hub.pagination.query, hub.pagination.total) end)

setNavEnabled()
task.delay(1, function() pcall(function() runSearch("", 1) end) end)

return Ether
