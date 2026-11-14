-- UI/CommandRow.lua
local Theme = require(script.Parent.Theme)

local function makeButton(parent, label, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(60, 30)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Theme.FontBold
    btn.Text = label
    btn.TextColor3 = Theme.Colors.Background
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = Theme.CornerRadius
    c.Parent = btn
    return btn
end

local function createRow(parent, cmdName, cmdDesc, onRun, onSave)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Theme.Colors.Surface
    row.BorderSizePixel = 0
    row.Parent = parent

    Instance.new("UICorner", row).CornerRadius = Theme.CornerRadius

    -- Nama + deskripsi
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -140, 0, 22)
    name.Position = UDim2.fromOffset(10, 6)
    name.BackgroundTransparency = 1
    name.Font = Theme.FontBold
    name.Text = cmdName
    name.TextColor3 = Theme.Colors.Accent
    name.TextSize = 13
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -140, 0, 18)
    desc.Position = UDim2.fromOffset(10, 26)
    desc.BackgroundTransparency = 1
    desc.Font = Theme.Font
    desc.Text = cmdDesc or ""
    desc.TextColor3 = Theme.Colors.TextDim
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Parent = row

    -- Tombol Run / Save
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.fromOffset(130, 30)
    btnContainer.Position = UDim2.new(1, -140, 0.5, -15)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = row

    local bLayout = Instance.new("UIListLayout")
    bLayout.FillDirection = Enum.FillDirection.Horizontal
    bLayout.Padding = UDim.new(0, 6)
    bLayout.Parent = btnContainer

    local runBtn = makeButton(btnContainer, "RUN", Theme.Colors.Accent, 1)
    runBtn.MouseButton1Click:Connect(function()
        onRun(cmdName)
    end)

    local saveBtn = makeButton(btnContainer, "SAVE", Theme.Colors.SurfaceHover, 2)
    saveBtn.TextColor3 = Theme.Colors.Text
    saveBtn.MouseButton1Click:Connect(function()
        onSave(cmdName)
    end)

    return row
end

return createRow