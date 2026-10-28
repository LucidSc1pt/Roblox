-- tabs/editor.lua
local Ether = getgenv().Ether
if not Ether then return end

local CodeTab = Ether.exeTabs.CodeTab
local hub = Ether.hub
local highlighter = Ether.highlighter

local EditorTabBar = Ether.Create("ScrollingFrame", { Name="EditorTabBar", Parent=CodeTab.containerInstance, BackgroundColor3=Color3.fromRGB(20,20,20), Position=UDim2.new(0,5,0,5), Size=UDim2.new(1,-125,0,32), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.X, ScrollingDirection=Enum.ScrollingDirection.X, ScrollBarThickness=0 })
Ether.Create("UIPadding", { PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4), PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4), Parent=EditorTabBar })

local AddTabBtn = Ether.Create("TextButton", { Name="AddTabBtn", Parent=CodeTab.containerInstance, Position=UDim2.new(1,-125,0,5), Size=UDim2.new(0,55,0,32), BackgroundColor3=Color3.fromRGB(40,148,215), Text="+", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamBold, TextSize=18, AutoButtonColor=false, ZIndex=5 })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=AddTabBtn })

local RenameTabBtn = Ether.Create("TextButton", { Name="RenameTabBtn", Parent=CodeTab.containerInstance, Position=UDim2.new(1,-65,0,5), Size=UDim2.new(0,60,0,32), BackgroundColor3=Color3.fromRGB(80,80,90), Text="Rename", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamBold, TextSize=11, AutoButtonColor=false, ZIndex=5 })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=RenameTabBtn })

local EditorFrameParent = Ether.Create("Frame", { Name="EditorFrameParent", Parent=CodeTab.containerInstance, BackgroundTransparency=1, Position=UDim2.new(0,5,0,42), Size=UDim2.new(1,-10,1,-130), ClipsDescendants=true })
Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Parent=EditorFrameParent })

local lineTextFrameParent = Ether.Create("Frame", { Name="lineTextFrameParent", Parent=EditorFrameParent, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,1,0) })
local lineText = Instance.new("TextLabel", lineTextFrameParent)
lineText.Size=UDim2.new(0,20,1,0) lineText.BackgroundColor3=Color3.fromRGB(20,20,20) lineText.Font=Enum.Font.Code lineText.AutomaticSize=Enum.AutomaticSize.X
lineText.TextSize=12 lineText.TextXAlignment=Enum.TextXAlignment.Right lineText.TextYAlignment=Enum.TextYAlignment.Top lineText.TextColor3=Color3.fromRGB(100,100,100) lineText.Text="1"

local EditorHolder = Ether.Create("ScrollingFrame", { Name="EditorHolder", Parent=EditorFrameParent, BackgroundColor3=Color3.fromRGB(25,25,25), Position=UDim2.new(0,5,0,5), Size=UDim2.new(1,lineText.AbsoluteSize.X,1,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=1, AutomaticCanvasSize=Enum.AutomaticSize.XY, ScrollingDirection=Enum.ScrollingDirection.XY })

local TextBox1 = Ether.Create("TextBox", { Name="Editor_Script", Parent=EditorHolder, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Font=Enum.Font.Code, TextColor3=Color3.fromRGB(255,255,255), Text="", PlaceholderText="Paste/Write your script here!", TextWrapped=false, TextSize=12, MultiLine=true, ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top })
Ether.currentTextBox = TextBox1

local function autoSizeEditor(target, line, scroll)
	local textBounds = target.TextBounds local frameSize = scroll.AbsoluteSize local text = target.Text
	local lines = select(2, text:gsub("\n", "")) + 1 local list = {}
	for i = 1, lines do list[#list+1] = tostring(i) end
	line.Text = table.concat(list, "\n")
	target.Size = UDim2.new(0, math.max(textBounds.X, frameSize.X) - line.AbsoluteSize.X, 0, math.max(textBounds.Y, frameSize.Y))
	line.Size = UDim2.new(0, line.AbsoluteSize.X, 0, math.max(textBounds.Y, frameSize.Y))
end

local tabEditor = Ether.TabReuse.new(EditorTabBar, TextBox1, highlighter, function(tabData)
	autoSizeEditor(TextBox1, lineText, EditorHolder)
end)
Ether.tabEditor = tabEditor

TextBox1.Focused:Connect(function()
	TextBox1.Size = UDim2.new(1, 0, 1, 0) tabEditor.hl.setVisible(false) lineText.Size = UDim2.new(0, lineText.AbsoluteSize.X, 1, 0) EditorHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
end)
TextBox1.FocusLost:Connect(function()
	autoSizeEditor(TextBox1, lineText, EditorHolder)
	local activeTab = tabEditor.activeId and tabEditor.tabs[tabEditor.activeId]
	if activeTab and activeTab._cachedLayers then tabEditor.hl.applyLayers(activeTab._cachedLayers) else tabEditor.hl.refresh() end
	tabEditor.hl.setVisible(true)
end)
EditorHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(function() lineText.Position = UDim2.new(0, 0, 0, -EditorHolder.CanvasPosition.Y) end)

Ether.SafeConnect(AddTabBtn.MouseButton1Click, function() tabEditor:AddTab("Tab " .. tabEditor.nextId, "") end)

-- RENAME POPUP
local function createRenamePopup(currentTitle, onConfirm)
	local overlay = Ether.Create("Frame", { Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.5, ZIndex=150, Parent=Ether.EtherExecutor })
	local popup = Ether.Create("Frame", { Size=UDim2.new(0,320,0,140), Position=UDim2.new(0.5,-160,0.5,-70), BackgroundColor3=Color3.fromRGB(35,35,42), ZIndex=151, Parent=overlay })
	Ether.Create("UICorner", { CornerRadius=UDim.new(0,10), Parent=popup })
	Ether.Create("TextLabel", { Size=UDim2.new(1,-20,0,25), Position=UDim2.new(0,10,0,10), BackgroundTransparency=1, Text="Rename Tab", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=152, Parent=popup })
	local input = Ether.Create("TextBox", { Size=UDim2.new(1,-20,0,35), Position=UDim2.new(0,10,0,40), BackgroundColor3=Color3.fromRGB(25,25,30), Text=currentTitle or "", PlaceholderText="New tab name...", Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(255,255,255), ZIndex=152, Parent=popup })
	Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=input })
	local saveBtn = Ether.Create("TextButton", { Size=UDim2.new(0,80,0,30), Position=UDim2.new(1,-170,1,-40), BackgroundColor3=Color3.fromRGB(40,148,215), Text="Save", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamBold, TextSize=12, AutoButtonColor=false, ZIndex=152, Parent=popup })
	local cancelBtn = Ether.Create("TextButton", { Size=UDim2.new(0,80,0,30), Position=UDim2.new(1,-85,1,-40), BackgroundColor3=Color3.fromRGB(60,60,70), Text="Cancel", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamBold, TextSize=12, AutoButtonColor=false, ZIndex=152, Parent=popup })
	Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=saveBtn }) Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=cancelBtn })

	local function close() overlay:Destroy() end
	cancelBtn.MouseButton1Click:Connect(close)
	saveBtn.MouseButton1Click:Connect(function() local newName = input.Text if newName and newName:gsub("%s", "") ~= "" then onConfirm(newName) end close() end)
	input.FocusLost:Connect(function(enter) if enter then local newName = input.Text if newName and newName:gsub("%s", "") ~= "" then onConfirm(newName) end close() end end)
	task.defer(function() pcall(function() input:CaptureFocus() end) end)
end
Ether.createRenamePopup = createRenamePopup

Ether.SafeConnect(RenameTabBtn.MouseButton1Click, function()
	local activeId = tabEditor:GetActiveId()
	if not activeId then hub:Toast("No active tab", Ether.EtherExecutor) return end
	createRenamePopup(tabEditor:GetActiveTitle(), function(newName)
		if tabEditor:RenameTab(activeId, newName) then hub:Toast("Renamed to "..newName, Ether.EtherExecutor) else hub:Toast("Failed rename", Ether.EtherExecutor) end
	end)
end)

-- BUTTONS
local Execute_Editor_Scripts = Ether.Create("TextButton", { Name="Execute_Editor_Scripts", Parent=CodeTab.containerInstance, BackgroundColor3=Color3.fromRGB(40,148,215), Position=UDim2.new(0,5,0.8,10), Size=UDim2.new(0.15,0,0,30), Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), Text="Execute", TextSize=13, AutoButtonColor=false })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=Execute_Editor_Scripts })
Ether.SafeConnect(Execute_Editor_Scripts.MouseButton1Click, function() Ether.executeSource(TextBox1.Text, "=Editor1") end)

local Clear_Editor_Scripts = Ether.Create("TextButton", { Name="Clear_Editor_Scripts", Parent=CodeTab.containerInstance, BackgroundColor3=Color3.fromRGB(200,60,60), Position=UDim2.new(0.2,-13,0.8,10), Size=UDim2.new(0.15,0,0,30), Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), Text="Clear", TextSize=13, AutoButtonColor=false })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=Clear_Editor_Scripts })
Ether.SafeConnect(Clear_Editor_Scripts.MouseButton1Click, function() TextBox1.Text = "" tabEditor:SaveCurrent() tabEditor.hl.refresh() autoSizeEditor(TextBox1, lineText, EditorHolder) end)

local Copy_Editor_Scripts = Ether.Create("TextButton", { Name="Copy_Editor_Scripts", Parent=CodeTab.containerInstance, BackgroundColor3=Color3.fromRGB(45,49,58), Position=UDim2.new(0.35,5,0.8,10), Size=UDim2.new(0.15,0,0,30), Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), Text="Copy", TextSize=13, AutoButtonColor=false })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=Copy_Editor_Scripts })
Ether.SafeConnect(Copy_Editor_Scripts.MouseButton1Click, function() if setclipboard then pcall(setclipboard, TextBox1.Text) end end)

local SaveToHubBtn = Ether.Create("TextButton", { Name="SaveToHubBtn", Parent=CodeTab.containerInstance, BackgroundColor3=Color3.fromRGB(255,165,0), Position=UDim2.new(0.5,5,0.8,10), Size=UDim2.new(0.2,0,0,30), Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), Text="Save to Hub", TextSize=13, AutoButtonColor=false })
Ether.Create("UICorner", { CornerRadius=UDim.new(0,6), Parent=SaveToHubBtn })
Ether.SafeConnect(SaveToHubBtn.MouseButton1Click, function()
	local code = tabEditor:GetActiveCode()
	if code == "" or code:gsub("%s", "") == "" then hub:Toast("Code empty!", Ether.EtherExecutor) return end
	createRenamePopup(tabEditor:GetActiveTitle(), function(newName)
		local ok, path = hub:SaveAsFile({ title = newName, scriptCode = code, source = "Code Tab" }, "lua")
		if ok then
			hub:Toast("Saved to Hub: " .. newName .. ".lua", Ether.EtherExecutor)
			local aid = tabEditor:GetActiveId() if aid then tabEditor:RenameTab(aid, newName) end
			if _G.refreshSavedFn then _G.refreshSavedFn() end
		else hub:Toast("Failed save", Ether.EtherExecutor) end
	end)
end)

return Ether
