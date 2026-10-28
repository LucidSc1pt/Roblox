-- core/tab_reuse.lua
local Ether = getgenv().Ether
if not Ether then return end

local TabReuse = {}
TabReuse.__index = TabReuse
Ether.TabReuse = TabReuse

function TabReuse.new(bar, box, hl, onSwitch)
	local self = setmetatable({}, TabReuse)
	self.tabBar = bar self.textBox = box self.tabs = {} self.activeId = nil self.nextId = 1 self.onSwitch = onSwitch
	if not bar:FindFirstChildOfClass("UIListLayout") then local l = Instance.new("UIListLayout") l.FillDirection = Enum.FillDirection.Horizontal l.Padding = UDim.new(0, 4) l.SortOrder = Enum.SortOrder.LayoutOrder l.Parent = bar end
	self.hl = hl.attach(box, { debounce = 0.15 })
	box.FocusLost:Connect(function() self:SaveCurrent() self:SaveAllToDisk() end)
	self:LoadFromDisk()
	if not next(self.tabs) then self:AddTab("Main", "-- Paste/Write your script here!") end
	return self
end

function TabReuse:_makeButton(id, title)
	local btn = Ether.Create("TextButton", { Name="Tab_"..id, Size=UDim2.new(0,110,1,0), BackgroundColor3=Color3.fromRGB(35,35,42), Text="", AutoButtonColor=false, Parent=self.tabBar })
	Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=btn })
	Ether.Create("TextLabel", { Name="Label", Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,6,0,0), BackgroundTransparency=1, Text=title, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamSemibold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Parent=btn })
	local close = Ether.Create("TextButton", { Size=UDim2.new(0,16,0,16), Position=UDim2.new(1,-20,0.5,-8), BackgroundTransparency=1, Text="×", TextColor3=Color3.fromRGB(180,180,180), Font=Enum.Font.GothamBold, TextSize=14, Parent=btn })
	btn.MouseButton1Click:Connect(function() self:SwitchTo(id) end) close.MouseButton1Click:Connect(function() self:CloseTab(id) end)
	return btn
end

function TabReuse:SaveCurrent()
	if self.activeId and self.tabs[self.activeId] then
		local tab = self.tabs[self.activeId] tab.code = self.textBox.Text
		if tab.code ~= "" then tab._cachedLayers = Ether.highlighter.buildLayers(tab.code) else tab._cachedLayers = nil end
	end
end

function TabReuse:SaveAllToDisk()
	if not (writefile and isfolder and makefolder and listfiles and delfile) then return end
	self:SaveCurrent() local folder = Ether.MainFolder.."/"..Ether.SavedTabEditorFolder
	if not isfolder(folder) then pcall(makefolder, folder) end
	local okList, files = pcall(listfiles, folder)
	if okList and type(files) == "table" then for _, f in ipairs(files) do if type(f) == "string" and f:lower():sub(-4) == ".lua" then pcall(delfile, f) end end end
	local ordered = {}
	for id, tab in pairs(self.tabs) do table.insert(ordered, { id=id, title=tab.title, code=tab.code }) end
	table.sort(ordered, function(a,b) return a.id < b.id end)
	for idx, t in ipairs(ordered) do
		local safeTitle = (t.title or "Tab"):gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1,40) if safeTitle == "" then safeTitle = "Tab_"..idx end
		pcall(writefile, folder.."/"..string.format("%03d__%s.lua", idx, safeTitle), t.code or "")
	end
end

function TabReuse:LoadFromDisk()
	if not (readfile and isfile and isfolder and listfiles) then return end
	local folder = Ether.MainFolder.."/"..Ether.SavedTabEditorFolder if not isfolder(folder) then return end
	local okList, files = pcall(listfiles, folder) if not okList or type(files) ~= "table" then return end
	local luaFiles = {} local legacyJson = nil
	for _, f in ipairs(files) do if type(f) == "string" then if f:lower():sub(-4) == ".lua" then table.insert(luaFiles, f) elseif f:lower():sub(-5) == ".json" then legacyJson = f end end end
	table.sort(luaFiles)
	for _, f in ipairs(luaFiles) do
		local okRead, content = pcall(readfile, f)
		if okRead and content then
			local baseName = f:match("([^/\\]+)%.lua$") or "Tab" local title = baseName:match("^%d+__(.*)$") or baseName title = title:gsub("_", " ")
			local id = self.nextId self.nextId += 1 local btn = self:_makeButton(id, title)
			self.tabs[id] = { title=title, code=content, button=btn, _cachedLayers=nil }
		end
	end
	if not self.activeId then for id, _ in pairs(self.tabs) do self.activeId = id break end end
	if self.activeId and self.tabs[self.activeId] then
		local targetTab = self.tabs[self.activeId] self.textBox.Text = targetTab.code
		if targetTab.code ~= "" then targetTab._cachedLayers = Ether.highlighter.buildLayers(targetTab.code) self.hl.applyLayers(targetTab._cachedLayers) else self.hl.refresh() end
		for tid, d in pairs(self.tabs) do d.button.BackgroundColor3 = (tid == self.activeId) and Color3.fromRGB(55,55,65) or Color3.fromRGB(35,35,42) end
		if self.onSwitch then self.onSwitch(targetTab) end
	end
end

function TabReuse:RenameTab(id, newTitle)
	if not self.tabs[id] then return false end if not newTitle or newTitle:gsub("%s", "") == "" then return false end
	newTitle = newTitle:sub(1, 40) self.tabs[id].title = newTitle
	if self.tabs[id].button then local lbl = self.tabs[id].button:FindFirstChild("Label") if lbl then lbl.Text = newTitle end end
	self:SaveAllToDisk() return true
end

function TabReuse:GetActiveTitle() return (self.activeId and self.tabs[self.activeId]) and self.tabs[self.activeId].title or "Untitled" end
function TabReuse:GetActiveId() return self.activeId end
function TabReuse:GetActiveCode() return self.textBox.Text end

function TabReuse:AddTab(title, code)
	self:SaveCurrent() local id = self.nextId self.nextId += 1 local btn = self:_makeButton(id, title or ("Tab "..id))
	self.tabs[id] = { title=title or ("Tab "..id), code=code or "", button=btn, _cachedLayers=nil }
	self:SwitchTo(id) self:SaveAllToDisk() return id
end

function TabReuse:SwitchTo(id)
	if not self.tabs[id] or self.activeId == id then return end
	self:SaveCurrent() for tid, d in pairs(self.tabs) do d.button.BackgroundColor3 = (tid == id) and Color3.fromRGB(55,55,65) or Color3.fromRGB(35,35,42) end
	self.activeId = id local targetTab = self.tabs[id] self.textBox.Text = targetTab.code
	if self.hl then
		if targetTab.code == "" then self.hl.refresh()
		elseif targetTab._cachedLayers then self.hl.applyLayers(targetTab._cachedLayers)
		else targetTab._cachedLayers = Ether.highlighter.buildLayers(targetTab.code) self.hl.applyLayers(targetTab._cachedLayers) end
	end
	if self.onSwitch then self.onSwitch(targetTab) end self:SaveAllToDisk()
end

function TabReuse:CloseTab(id)
	if not self.tabs[id] then return end local wasActive = self.activeId == id
	self.tabs[id].button:Destroy() self.tabs[id] = nil
	if wasActive then
		self.activeId = nil local nextId = nil for tid, _ in pairs(self.tabs) do nextId = tid break end
		if nextId then self:SwitchTo(nextId) else self.textBox.Text = "" if self.hl then self.hl.refresh() end if self.onSwitch then self.onSwitch(nil) end end
	end
	self:SaveAllToDisk()
end

return Ether
