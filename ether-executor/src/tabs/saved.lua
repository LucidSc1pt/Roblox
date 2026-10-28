-- tabs/saved.lua
local Ether = getgenv().Ether
if not Ether then return end

local hub = Ether.hub
local SavedTab = Ether.exeTabs.SavedTab
local EtherExecutor = Ether.EtherExecutor

local SavedTopBar = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = SavedTab.containerInstance })
local SavedSearchBox = Ether.Create("TextBox", { Size = UDim2.new(1, -70, 1, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 42), PlaceholderText = "Search saved scripts...", PlaceholderColor3 = Color3.fromRGB(150, 150, 150), Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), Parent = SavedTopBar })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SavedSearchBox })

local SavedRefreshBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -60, 0, 0), BackgroundColor3 = Color3.fromRGB(50, 50, 60), Text = "Refresh", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, AutoButtonColor = false, Parent = SavedTopBar })
Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SavedRefreshBtn })

local SavedList = Ether.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = SavedTab.containerInstance })
Ether.Create("UIListLayout", { Padding = UDim.new(0, 4), Parent = SavedList })

local savedFilterQuery = ""

local function refreshSavedList()
	for _, c in ipairs(SavedList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local scripts = hub:LoadSavedScripts()
	local filtered = {}
	local q = savedFilterQuery:lower():gsub("%s", "")
	if q == "" then filtered = scripts
	else
		for _, s in ipairs(scripts) do
			if (s.title or ""):lower():find(q, 1, true) or (s.fileName or ""):lower():find(q, 1, true) then table.insert(filtered, s) end
		end
	end

	local header = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = SavedList })
	Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = header })
	Ether.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Folder: " .. Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder .. " (" .. #filtered .. "/" .. #scripts .. ")", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 8, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	Ether.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 8, 0, 22), BackgroundTransparency = 1, Text = "Format: .lua default (any text format supported) | Direct Exec available", TextColor3 = Color3.fromRGB(100, 200, 100), TextSize = 9, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

	for _, data in ipairs(filtered) do
		local row = Ether.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = data.isOldJson and Color3.fromRGB(60, 40, 40) or Color3.fromRGB(35, 35, 42), Parent = SavedList })
		Ether.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })
		
		Ether.Create("TextLabel", { Size = UDim2.new(1, -210, 0, 20), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = data.title or "Untitled", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
		Ether.Create("TextLabel", { Size = UDim2.new(1, -210, 0, 15), Position = UDim2.new(0, 8, 0, 22), BackgroundTransparency = 1, Text = (data.fileName or "?") .. (data.isOldJson and " (legacy json)" or (" (." .. (data.ext or "lua") .. ")")), TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 8, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		Ether.Create("TextLabel", { Size = UDim2.new(1, -210, 0, 12), Position = UDim2.new(0, 8, 0, 37), BackgroundTransparency = 1, Text = data.filePath or "", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 7, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })

		local loadBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -160, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 144, 255), Text = "Load", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local execBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -115, 0, 10), BackgroundColor3 = Color3.fromRGB(40, 180, 80), Text = "Exec", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local editBtn = Ether.Create("TextButton", { Size = UDim2.new(0, 25, 0, 30), Position = UDim2.new(1, -70, 0, 10), BackgroundColor3 = Color3.fromRGB(80, 80, 90), Text = "Edit", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local delBtn  = Ether.Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -45, 0, 10), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "Del", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		for _, b in ipairs({ loadBtn, execBtn, editBtn, delBtn }) do Ether.Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = b }) end

		loadBtn.MouseButton1Click:Connect(function()
			Ether.tabEditor:AddTab(data.title, data.code)
			hub:Toast("Loaded " .. data.fileName, EtherExecutor)
		end)
		execBtn.MouseButton1Click:Connect(function()
			local execCode = (data.code or ""):gsub("^%-%-%[%[.-%]%]%s*", "")
			local fn, err = loadstring(execCode)
			if not fn then hub:Toast("Compile error: " .. tostring(err):sub(1, 40), EtherExecutor) return end
			local ok, err2 = pcall(fn)
			if ok then hub:Toast("Executed " .. data.title, EtherExecutor)
			else hub:Toast("Runtime error", EtherExecutor) warn(err2) end
		end)
		editBtn.MouseButton1Click:Connect(function()
			Ether.tabEditor:AddTab((data.title or "Script") .. " [Edit]", data.code)
			Ether.exeTabs.CodeTab:Select()
			hub:Toast("Opened for edit", EtherExecutor)
		end)
		delBtn.MouseButton1Click:Connect(function()
			if delfile then pcall(delfile, data.filePath) end
			refreshSavedList()
			hub:Toast("Deleted " .. data.fileName, EtherExecutor)
		end)
	end

	if #filtered == 0 then
		local msg = savedFilterQuery ~= "" and ("No results for '" .. savedFilterQuery .. "'") or "No saved scripts yet. Save from Search popup or Code tab!"
		Ether.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = msg, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.Gotham, Parent = SavedList })
	end
end

SavedSearchBox:GetPropertyChangedSignal("Text"):Connect(function() savedFilterQuery = SavedSearchBox.Text refreshSavedList() end)
SavedRefreshBtn.MouseButton1Click:Connect(refreshSavedList)
_G.refreshSavedFn = refreshSavedList
refreshSavedList()

return Ether
