-- UI/Builder.lua
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

    -- Root panel
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

    -- Title bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Theme.Colors.Surface
    title.BorderSizePixel = 0
    title.Font = Theme.FontBold
    title.Text = " ∞ Infinite Yield+ "
    title.TextColor3 = Theme.Colors.Accent
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    -- Search bar (di bawah title)
    local search = Instance.new("TextBox")
    search.Name = "Search"
    search.Size = UDim2.new(1, -Theme.Padding * 2, 0, 36)
    search.Position = UDim2.new(0, Theme.Padding, 0, 48)
    search.BackgroundColor3 = Theme.Colors.Surface
    search.BorderSizePixel = 0
    search.Font = Theme.Font
    search.PlaceholderText = "  🔍 Cari command..."
    search.PlaceholderColor3 = Theme.Colors.TextDim
    search.TextColor3 = Theme.Colors.Text
    search.TextSize = 14
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.ClearTextOnFocus = false
    search.Parent = panel

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = Theme.CornerRadius
    searchCorner.Parent = search

   -- SETELAH blok search & searchCorner...

-- Slot untuk TabBar (diisi oleh TabBar.create di init.lua)
local tabSlot = Instance.new("Frame")
tabSlot.Name = "TabBarSlot"
tabSlot.Size = UDim2.new(1, -Theme.Padding * 2, 0, 28)
tabSlot.Position = UDim2.new(0, Theme.Padding, 0, 92)
tabSlot.BackgroundTransparency = 1
tabSlot.Parent = panel

-- Scrolling list (posisi dan ukuran sudah memperhitungkan TabBar)
local list = Instance.new("ScrollingFrame")
list.Name = "CommandList"
list.Size = UDim2.new(1, -Theme.Padding * 2, 1, -(92 + 28 + 6 + Theme.Padding))
list.Position = UDim2.new(0, Theme.Padding, 0, 92 + 28 + 6)
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

    -- Responsif: UIScale yang reaktif ke viewport
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = panel
    local function updateScale()
        if Layout.isMobile() then
            uiScale.Scale = 1  -- biarkan penuh, sudah margin
        else
            uiScale.Scale = 1
        end
    end
    updateScale()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

-- Draggable: aktifkan drag dari Title bar
local dragging, dragStart, startPos = false, Vector2.zero, UDim2.new()

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
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
}
end

return Builder