-- core/window.lua
local Ether = getgenv().Ether
if not Ether then return end

local TweenService = Ether.TweenService
local uis = Ether.UIS

Ether.exeRunningTime = os.time()
Ether.window = { tabs = {}, activeTab = nil }

-- 1. FRAME UTAMA
local UIWindow = Ether.Create("Frame", {
	Name = tostring(Ether.createUIName()), Parent = Ether.EtherExecutor,
	BackgroundTransparency = 1, Position = UDim2.new(0, 340, 0, 300),
	Size = UDim2.new(0, 340, 0, 300), ClipsDescendants = true
})

local MainFrameParent = Ether.Create("Frame", {
	Name = tostring(Ether.createUIName()), Parent = Ether.EtherExecutor,
	BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 151, 230),
	Position = UDim2.new(0, 50, 0, 50), Size = UDim2.new(0, 530, 0, 300), ClipsDescendants = true
})
Ether.MainFrameParent = MainFrameParent

Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = MainFrameParent })

local HeaderFrame = Ether.Create("Frame", { Name="HeaderFrame", Parent=MainFrameParent, BackgroundColor3=Color3.fromRGB(25,25,25), Size=UDim2.new(1,0,0,40), Active=true })
Ether.HeaderFrame = HeaderFrame

local MainExeWinFrame = Ether.Create("Frame", { Name=tostring(Ether.createUIName()), Parent=MainFrameParent, BackgroundColor3=Color3.fromRGB(25,25,25), Position=UDim2.new(0,0,1), Size=UDim2.new(1,0,1,-40) })
Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = MainExeWinFrame })

local HeaderContentFrame = Ether.Create("Frame", { Name="HeaderContentFrame", Parent=HeaderFrame, BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0) })
Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = HeaderContentFrame })

local HeaderTextFrame = Ether.Create("Frame", { Name="HeaderTextFrame", Parent=HeaderContentFrame, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0) })
Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = HeaderTextFrame })

Ether.MakeDraggable(HeaderFrame, MainFrameParent)

Ether.Create("TextLabel", { Name="TitleText", Parent=HeaderTextFrame, BackgroundTransparency=1, Size=UDim2.new(1,-140,0.5,0), Font=Enum.Font.FredokaOne, TextColor3=Color3.fromRGB(255,255,255), Text="Ether Internal Executor", TextSize=18, TextXAlignment=Enum.TextXAlignment.Left })
Ether.Create("TextLabel", { Name="SubTitleText", Parent=HeaderTextFrame, BackgroundTransparency=1, Size=UDim2.new(1,-140,0.5,0), Font=Enum.Font.FredokaOne, TextColor3=Color3.fromRGB(205,205,205), Text="v0.0.1 beta", TextSize=14, TextXAlignment=Enum.TextXAlignment.Left })

local HeaderToolBarFrame = Ether.Create("Frame", { AnchorPoint=Vector2.new(1,0), Name="HeaderToolBarFrame", Parent=HeaderFrame, BackgroundTransparency=1, Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,100,1,0) })
Ether.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Parent = HeaderToolBarFrame })

local DestroyBut = Ether.Create("TextButton", { Name="DestroyBut", Parent=HeaderToolBarFrame, BackgroundColor3=Color3.fromRGB(255,0,0), Size=UDim2.new(0,50,1,0), Font=Enum.Font.FredokaOne, TextColor3=Color3.fromRGB(242,243,243), Text="×", TextSize=18, Active=true })
Ether.SafeConnect(DestroyBut.MouseButton1Click, function() Ether:Destroy() end)

local MinimizeBut = Ether.Create("TextButton", { Name="MinimizeBut", Parent=HeaderToolBarFrame, BackgroundColor3=Color3.fromRGB(0,0,255), Size=UDim2.new(0,50,1,0), Font=Enum.Font.FredokaOne, TextColor3=Color3.fromRGB(242,243,243), Text="-", TextSize=18, Active=true })

local TabHolder = Ether.Create("ScrollingFrame", { Name="TabFrame", Parent=MainExeWinFrame, BackgroundColor3=Color3.fromRGB(45,45,45), BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y, ScrollBarThickness=0, Size=UDim2.new(0,50,1,0), Active=true })
Ether.Create("UIListLayout", { Name="TabHolderListLayout", FillDirection=Enum.FillDirection.Vertical, HorizontalAlignment=Enum.HorizontalAlignment.Center, SortOrder=Enum.SortOrder.LayoutOrder, Parent=TabHolder })
Ether.Create("UIPadding", { PaddingRight=UDim.new(0,5), PaddingLeft=UDim.new(0,5), Parent=TabHolder })

local contentArea = Ether.Create("Frame", { Name="contentArea", BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), Parent=MainExeWinFrame })
Ether.window.winContentArea = contentArea

-- MINIMIZE LOGIC
local minimize = false local tweening = false
Ether.SafeConnect(MinimizeBut.MouseButton1Click, function()
	if tweening then return end tweening = true minimize = not minimize
	local easing = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local SizeAnimUIOut = TweenService:Create(MainExeWinFrame, easing, { Size = UDim2.new(1, 0, 0, 0) })
	local SizeAnimUIIn = TweenService:Create(MainExeWinFrame, easing, { Size = UDim2.new(1, 0, 1, -40) })
	if minimize then MinimizeBut.Text = "+" SizeAnimUIOut:Play() SizeAnimUIOut.Completed:Connect(function() tweening = false MainExeWinFrame.Visible = false end)
	else MainExeWinFrame.Visible = true MinimizeBut.Text = "–" SizeAnimUIIn:Play() SizeAnimUIIn.Completed:Connect(function() tweening = false end) end
end)

-- 2. TAB CREATOR
function Ether.AddTab(TabConfig)
	TabConfig = TabConfig or {}
	TabConfig.Title = TabConfig.Title or "Main"
	TabConfig.Icon = TabConfig.Icon or "sword"
	TabConfig.IsAutoLayout = TabConfig.IsAutoLayout or false
	TabConfig.AutoSizeScroll = TabConfig.AutoSizeScroll or false

	local tab = { title = TabConfig.Title, buttonInstance = nil, buttonTitle = nil, containerInstance = nil }
	local tabButtonFrame = Ether.Create("Frame", { Name=TabConfig.Title, Parent=TabHolder, BackgroundColor3=Color3.fromRGB(45,45,45), BackgroundTransparency=1, Size=UDim2.new(1,0,0,45), Active=true })
	local tabButton = Ether.Create("TextButton", { Name="_Button", Parent=tabButtonFrame, BackgroundColor3=Color3.fromRGB(25,25,25), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), TextTransparency=1, Active=false })
	
	Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Vertical, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabButton })
	Ether.Create("UIPadding", { PaddingBottom=UDim.new(0,5), PaddingTop=UDim.new(0,5), PaddingRight=UDim.new(0,5), PaddingLeft=UDim.new(0,5), Parent=tabButton })

	local Iccon = Ether.Create("ImageLabel", { Size=UDim2.new(0,24,0,24), BackgroundTransparency=1, ImageColor3=Color3.fromRGB(240,240,240), Name="Icon", LayoutOrder=1, Parent=tabButton })
	if TabConfig.Icon and TabConfig.Icon ~= "" then Ether.applyIcon(Iccon, TabConfig.Icon) else Iccon:Destroy() end

	local tabButtonTitle = Ether.Create("TextLabel", { LayoutOrder=2, Parent=tabButton, AutomaticSize=Enum.AutomaticSize.XY, BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=TabConfig.Title, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Active=false })
	
	local tabContainer = Ether.Create("ScrollingFrame", { Name="Content_"..TabConfig.Title, Parent=contentArea, BackgroundTransparency=1, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=TabConfig.AutoSizeScroll and Enum.AutomaticSize.Y or Enum.AutomaticSize.None, ScrollingDirection=Enum.ScrollingDirection.Y, ScrollBarThickness=0, Size=UDim2.new(1,0,1,0), Visible=false, Active=true })
	Ether.Create("UIPadding", { PaddingBottom=UDim.new(0,5), PaddingTop=UDim.new(0,5), PaddingRight=UDim.new(0,5), PaddingLeft=UDim.new(0,5), Parent=tabContainer })
	
	if TabConfig.IsAutoLayout then Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabContainer }) end

	tab.buttonTitle = tabButtonTitle
	tab.buttonInstance = tabButtonFrame
	tab.containerInstance = tabContainer

	function tab:Select()
		for _, otherTab in ipairs(Ether.window.tabs) do
			if otherTab.containerInstance then otherTab.containerInstance.Visible = false end
			if otherTab.buttonInstance then otherTab.buttonInstance.BackgroundTransparency = 1 end
			if otherTab.buttonTitle then otherTab.buttonTitle.TextTransparency = 0.2 end
		end
		tab.containerInstance.Visible = true tab.buttonInstance.BackgroundTransparency = 0 tab.buttonTitle.TextTransparency = 0
		Ether.window.activeTab = tab
	end

	Ether.SafeConnect(tabButton.MouseButton1Click, function() tab:Select() end)
	table.insert(Ether.window.tabs, tab)
	if #Ether.window.tabs == 1 and Ether.window.activeTab == nil then tab:Select() end
	return tab
end

Ether.exeTabs = {
	CodeTab = Ether.AddTab({ Title = "Code", Icon = "code" }),
	ScriptSearchTab = Ether.AddTab({ Title = "Search", Icon = "search" }),
	SavedTab = Ether.AddTab({ Title = "Saved", Icon = "folder" }),
	InfoTab = Ether.AddTab({ Title = "Info", Icon = "info", IsAutoLayout = true, AutoSizeScroll = true }),
	SettingsTab = Ether.AddTab({ Title = "Settings", Icon = "lucide:settings" })
}

return Ether
