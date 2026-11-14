-- UI/TabBar.lua
local Theme = require(script.Parent.Theme)

local TabBar = {}

function TabBar.create(parent, tabs, onSelect, initial)
    local bar = Instance.new("ScrollingFrame")
    bar.Name = "TabBar"
    bar.Size = UDim2.fromScale(1, 1)
    bar.Position = UDim2.fromScale(0, 0)
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.ScrollBarThickness = 0
    bar.ScrollingDirection = Enum.ScrollingDirection.X
    bar.CanvasSize = UDim2.new(0, 0, 0, 0)
    bar.AutomaticCanvasSize = Enum.AutomaticSize.X
    bar.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = bar

    local buttons  = {}
    local selected = initial or tabs[1]

    local function updateVisuals()
        for name, btn in pairs(buttons) do
            if name == selected then
                btn.BackgroundColor3 = Theme.Colors.Accent
                btn.TextColor3      = Theme.Colors.Background
            else
                btn.BackgroundColor3 = Theme.Colors.Surface
                btn.TextColor3      = Theme.Colors.TextDim
            end
        end
    end

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.fromOffset(0, 28)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Theme.Colors.Surface
        btn.BorderSizePixel = 0
        btn.Font = Theme.FontBold
        btn.Text = tabName
        btn.TextColor3 = Theme.Colors.TextDim
        btn.TextSize = 12
        btn.LayoutOrder = i
        btn.Parent = bar

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft  = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = btn

        local corner = Instance.new("UICorner")
        corner.CornerRadius = Theme.CornerRadius
        corner.Parent = btn

        buttons[tabName] = btn
        btn.MouseButton1Click:Connect(function()
            selected = tabName
            updateVisuals()
            onSelect(tabName)
        end)
    end

    updateVisuals()

    return {
        Frame = bar,
        SetSelected = function(name)
            selected = name
            updateVisuals()
        end,
    }
end

return TabBar