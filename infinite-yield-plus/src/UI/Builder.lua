local Players = game:GetService("Players")
local Theme   = require(script.Parent.Theme)
local Layout  = require(script.Parent.Layout)

local Builder = {}

function Builder.create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "IYPlus"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = Layout.getPanelSize()
    panel.Position = Layout.getPanelPosition()
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Theme.Colors.Background
    panel.BorderSizePixel = 0
    panel.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.SurfaceHover
    stroke.Thickness = 1
    stroke.Parent = panel

    -- Title Area
    local titleArea = Instance.new("Frame")
    titleArea.Size = UDim2.new(1, 0, 0, 34)
    titleArea.BackgroundColor3 = Theme.Colors.Surface
    titleArea.BorderSizePixel = 0
    titleArea.Parent = panel

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = Theme.CornerRadius
    titleCorner.Parent = titleArea

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Theme.FontBold
    title.Text = " ∞ Infinite Yield+ "
    title.TextColor3 = Theme.Colors.Accent
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleArea

    local btnArea = Instance.new("Frame")
    btnArea.Size = UDim2.fromOffset(60, 34)
    btnArea.Position = UDim2.new(1, -60, 0, 0)
    btnArea.BackgroundTransparency = 1
    btnArea.Parent = titleArea

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.fromOffset(30, 34)
    refreshBtn.Position = UDim2.fromOffset(0, 0)
    refreshBtn.BackgroundTransparency = 1
    refreshBtn.Font = Theme.FontBold
    refreshBtn.Text = "r"
    refreshBtn.TextColor3 = Theme.Colors.TextDim
    refreshBtn.TextSize = 16
    refreshBtn.Parent = btnArea

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(30, 34)
    closeBtn.Position = UDim2.fromOffset(30, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Theme.FontBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Colors.Danger
    closeBtn.TextSize = 16
    closeBtn.Parent = btnArea

    local search = Instance.new("TextBox")
    search.Name = "Search"
    search.Size = UDim2.new(1, -Theme.Padding * 2, 0, 30)
    search.Position = UDim2.new(0, Theme.Padding, 0, 42)
    search.BackgroundColor3 = Theme.Colors.Surface
    search.BorderSizePixel = 0
    search.Font = Theme.Font
    search.PlaceholderText = "  Cari command..."
    search.PlaceholderColor3 = Theme.Colors.TextDim
    search.TextColor3 = Theme.Colors.Text
    search.TextSize = 12
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.ClearTextOnFocus = false
    search.Parent = panel

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = Theme.CornerRadius
    searchCorner.Parent = search

    local tabSlot = Instance.new("Frame")
    tabSlot.Name = "TabBarSlot"
    tabSlot.Size = UDim2.new(1, -Theme.Padding * 2, 0, 24)
    tabSlot.Position = UDim2.new(0, Theme.Padding, 0, 78)
    tabSlot.BackgroundTransparency = 1
    tabSlot.Parent = panel

    local list = Instance.new("ScrollingFrame")
    list.Name = "CommandList"
    list.Size = UDim2.new(1, -Theme.Padding * 2, 1, -116)
    list.Position = UDim2.new(0, Theme.Padding, 0, 108)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = Theme.Colors.Accent
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    -- Draggable Logic
    local dragging, dragStart, startPos = false, Vector2.zero, UDim2.new()
    titleArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleArea.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return {
        Gui        = gui,
        Panel      = panel,
        Search     = search,
        TabBarSlot = tabSlot,
        List       = list,
        RefreshBtn = refreshBtn,
        CloseBtn   = closeBtn,
    }
end

return Builder