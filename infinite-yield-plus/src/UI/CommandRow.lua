-- UI/CommandRow.lua
local Theme = require(script.Parent.Theme)

local COLS = 3
local ARG_H = 26
local ARG_GAP = 6

local function calcArgsHeight(n)
    if n == 0 then return 0 end
    local rows = math.ceil(n / COLS)
    return rows * (ARG_H + ARG_GAP) + 4
end

local function makeButton(parent, label, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(60, 28)
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

local function createArgInput(parent, argDef, order)
    local input = Instance.new("TextBox")
    input.Name = "arg_" .. argDef.key
    -- Scale: 1/COLS dari parent, minus gap
    input.Size = UDim2.new(1 / COLS, -ARG_GAP - 2, 0, ARG_H)
    input.BackgroundColor3 = Theme.Colors.Background
    input.BorderSizePixel = 0
    input.Font = Theme.Font
    input.Text = argDef.default or ""
    input.PlaceholderText = argDef.key
    input.PlaceholderColor3 = Theme.Colors.TextDim
    input.TextColor3 = Theme.Colors.Text
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.LayoutOrder = order
    input.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = input

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = input

    return input
end

local function createRow(parent, entry, onRun, onSave)
    local args = entry.args or {}
    local hasArgs = #args > 0
    local headerHeight = 52
    local argsHeight = calcArgsHeight(#args)
    local totalHeight = headerHeight + argsHeight

    local row = Instance.new("Frame")
    row.Name = "Row_" .. entry.name
    row.Size = UDim2.new(1, 0, 0, totalHeight)
    row.BackgroundColor3 = Theme.Colors.Surface
    row.BorderSizePixel = 0
    row.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius
    corner.Parent = row

    local displayName = entry.fullName or entry.name

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -140, 0, 22)
    name.Position = UDim2.fromOffset(10, 6)
    name.BackgroundTransparency = 1
    name.Font = Theme.FontBold
    name.Text = displayName
    name.TextColor3 = Theme.Colors.Accent
    name.TextSize = 13
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -140, 0, 18)
    desc.Position = UDim2.fromOffset(10, 26)
    desc.BackgroundTransparency = 1
    desc.Font = Theme.Font
    desc.Text = entry.desc or ""
    desc.TextColor3 = Theme.Colors.TextDim
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Parent = row

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.fromOffset(130, 28)
    btnContainer.Position = UDim2.new(1, -140, 0, 12)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = row

    local bLayout = Instance.new("UIListLayout")
    bLayout.FillDirection = Enum.FillDirection.Horizontal
    bLayout.Padding = UDim.new(0, 6)
    bLayout.Parent = btnContainer

    local argInputs = {}
    if hasArgs then
        local argContainer = Instance.new("Frame")
        argContainer.Name = "Args"
        argContainer.Size = UDim2.new(1, -20, 0, argsHeight)
        argContainer.Position = UDim2.fromOffset(10, headerHeight)
        argContainer.BackgroundTransparency = 1
        argContainer.ClipsDescendants = false
        argContainer.Parent = row

        local aLayout = Instance.new("UIListLayout")
        aLayout.FillDirection = Enum.FillDirection.Horizontal
        aLayout.Wraps = true                       -- <-- kunci: wrap kalau tidak muat
        aLayout.Padding = UDim.new(0, ARG_GAP)
        aLayout.SortOrder = Enum.SortOrder.LayoutOrder
        aLayout.Parent = argContainer

        for i, argDef in ipairs(args) do
            argInputs[argDef.key] = createArgInput(argContainer, argDef, i)
        end
    end

    local function buildCommand()
        if not hasArgs then return entry.name end
        local parts = { entry.name }
        for _, argDef in ipairs(args) do
            local input = argInputs[argDef.key]
            local val = input and input.Text or ""
            if val ~= "" then
                table.insert(parts, val)
            end
        end
        return table.concat(parts, " ")
    end

    local runBtn = makeButton(btnContainer, "RUN", Theme.Colors.Accent, 1)
    runBtn.MouseButton1Click:Connect(function()
        onRun(buildCommand())
    end)

    local saveBtn = makeButton(btnContainer, "SAVE", Theme.Colors.SurfaceHover, 2)
    saveBtn.TextColor3 = Theme.Colors.Text
    saveBtn.MouseButton1Click:Connect(function()
        onSave(entry.name)
    end)

    return row
end

return createRow