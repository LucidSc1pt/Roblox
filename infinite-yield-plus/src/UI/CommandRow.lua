local Theme = require(script.Parent.Theme)

local ARG_H = 24
local ARG_GAP = 5

local function colsFor(n)
    if n <= 2 then return 2 end
    return 3
end

local function calcArgsHeight(n, cols)
    if n == 0 then return 0 end
    return math.ceil(n / cols) * (ARG_H + ARG_GAP)
end

local function makeButton(parent, label, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(52, 24)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Theme.FontBold
    btn.Text = label
    btn.TextColor3 = Theme.Colors.Background
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = Theme.CornerRadius
    c.Parent = btn
    return btn
end

local function createArgInput(parent, argDef, order, cols)
    local input = Instance.new("TextBox")
    input.Name = "arg_" .. tostring(order)
    input.Size = UDim2.new(1 / cols, -ARG_GAP, 0, ARG_H)
    input.BackgroundColor3 = Theme.Colors.Background
    input.BorderSizePixel = 0
    input.Font = Theme.Font
    input.Text = argDef.default or ""
    input.PlaceholderText = argDef.placeholder or "value"
    input.PlaceholderColor3 = Theme.Colors.TextDim
    input.TextColor3 = Theme.Colors.Text
    input.TextSize = 10
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.LayoutOrder = order
    input.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = input

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = input

    return input
end

local function createRow(parent, entry, onRun, onSave)
    local args = entry.args or {}
    local hasArgs = #args > 0
    local cols = colsFor(#args)
    local headerH = 42
    local argsH = calcArgsHeight(#args, cols)
    local totalH = headerH + argsH + (hasArgs and 8 or 2)

    local row = Instance.new("Frame")
    row.Name = "Row_" .. entry.name
    row.Size = UDim2.new(1, 0, 0, totalH)
    row.BackgroundColor3 = Theme.Colors.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = entry.order or 0
    row.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius
    corner.Parent = row

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -118, 0, 18)
    name.Position = UDim2.fromOffset(8, 4)
    name.BackgroundTransparency = 1
    name.Font = Theme.FontBold
    name.Text = entry.fullName or entry.name
    name.TextColor3 = Theme.Colors.Accent
    name.TextSize = 10
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -118, 0, 14)
    desc.Position = UDim2.fromOffset(8, 20)
    desc.BackgroundTransparency = 1
    desc.Font = Theme.Font
    desc.Text = entry.desc or ""
    desc.TextColor3 = Theme.Colors.TextDim
    desc.TextSize = 9
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Parent = row

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.fromOffset(108, 24)
    btnContainer.Position = UDim2.new(1, -116, 0, 8)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = row

    local bLayout = Instance.new("UIListLayout")
    bLayout.FillDirection = Enum.FillDirection.Horizontal
    bLayout.Padding = UDim.new(0, 4)
    bLayout.Parent = btnContainer

    local argInputs = {}
    if hasArgs then
        local argContainer = Instance.new("Frame")
        argContainer.Name = "Args"
        argContainer.Size = UDim2.new(1, -16, 0, argsH)
        argContainer.Position = UDim2.fromOffset(8, headerH)
        argContainer.BackgroundTransparency = 1
        argContainer.Parent = row

        local aLayout = Instance.new("UIListLayout")
        aLayout.FillDirection = Enum.FillDirection.Horizontal
        aLayout.Wraps = true
        aLayout.Padding = UDim.new(0, ARG_GAP)
        aLayout.SortOrder = Enum.SortOrder.LayoutOrder
        aLayout.Parent = argContainer

        for i, argDef in ipairs(args) do
            argInputs[i] = createArgInput(argContainer, argDef, i, cols)
        end
    end

    local function buildCommand()
        if not hasArgs then return entry.name end
        local parts = { entry.name }
        for i = 1, #args do
            local val = argInputs[i] and argInputs[i].Text or ""
            val = val:gsub("^%s+", ""):gsub("%s+$", "")
            if val ~= "" then table.insert(parts, val) end
        end
        return table.concat(parts, " ")
    end

    local runBtn = makeButton(btnContainer, "RUN", Theme.Colors.Accent, 1)
    runBtn.MouseButton1Click:Connect(function() onRun(buildCommand()) end)

    local saveBtn = makeButton(btnContainer, "SAVE", Theme.Colors.SurfaceHover, 2)
    saveBtn.TextColor3 = Theme.Colors.Text
    saveBtn.MouseButton1Click:Connect(function() onSave(entry.name) end)

    return row
end

return createRow