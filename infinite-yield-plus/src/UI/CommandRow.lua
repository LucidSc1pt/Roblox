-- UI/CommandRow.lua
local Theme = require(script.Parent.Theme)
local Saved = require(script.Parent.Parent.Core.Saved)

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

local function createArgInput(parent, argDef, order, cols, defaultValue)
    local input = Instance.new("TextBox")
    input.Name = "arg_" .. tostring(order)
    input.Size = UDim2.new(1 / cols, -ARG_GAP, 0, ARG_H)
    input.BackgroundColor3 = Theme.Colors.Background
    input.BorderSizePixel = 0
    input.Font = Theme.Font
    input.Text = defaultValue or argDef.default or ""
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

local function createRow(parent, entry, onRun, onSavedChanged)
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
            local defVal = entry._savedArgs and entry._savedArgs[i] or argDef.default or ""
            argInputs[i] = createArgInput(argContainer, argDef, i, cols, defVal)
        end
    end

    local function getCurrentArgs()
        local t = {}
        for i = 1, #argInputs do
            local val = argInputs[i].Text
            val = val:gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(t, val)
        end
        return t
    end

    local function buildCommand()
        if not hasArgs then return entry.name end
        local parts = { entry.name }
        local argsTable = getCurrentArgs()
        for i = 1, #argsTable do
            if argsTable[i] ~= "" then table.insert(parts, argsTable[i]) end
        end
        return table.concat(parts, " ")
    end

    local function isArgsEqual(a, b)
        if #a ~= #b then return false end
        for i = 1, #a do
            if a[i] ~= b[i] then return false end
        end
        return true
    end

    local saveBtn = makeButton(btnContainer, "SAVE", Theme.Colors.SurfaceHover, 2)
    saveBtn.TextColor3 = Theme.Colors.Text

    local function updateSaveButton()
        local savedItem = Saved.get(entry.name)
        if not savedItem then
            saveBtn.Text = "SAVE"
            saveBtn.BackgroundColor3 = Theme.Colors.SurfaceHover
            saveBtn.TextColor3 = Theme.Colors.Text
        else
            local currentArgs = getCurrentArgs()
            local savedArgs = savedItem.argValues or {}
            if isArgsEqual(currentArgs, savedArgs) then
                saveBtn.Text = "UNSAVE"
                saveBtn.BackgroundColor3 = Theme.Colors.Danger
                saveBtn.TextColor3 = Theme.Colors.Text
            else
                saveBtn.Text = "UPDATE"
                saveBtn.BackgroundColor3 = Theme.Colors.Success
                saveBtn.TextColor3 = Theme.Colors.Background
            end
        end
    end

    for i = 1, #argInputs do
        argInputs[i]:GetPropertyChangedSignal("Text"):Connect(updateSaveButton)
    end

    local runBtn = makeButton(btnContainer, "RUN", Theme.Colors.Accent, 1)
    runBtn.MouseButton1Click:Connect(function() onRun(buildCommand()) end)

    saveBtn.MouseButton1Click:Connect(function()
        local savedItem = Saved.get(entry.name)
        local currentArgs = getCurrentArgs()
        if not savedItem then
            Saved.add(entry.name, currentArgs)
        else
            local savedArgs = savedItem.argValues or {}
            if isArgsEqual(currentArgs, savedArgs) then
                Saved.remove(entry.name)
            else
                Saved.update(entry.name, currentArgs)
            end
        end
        updateSaveButton()
        if onSavedChanged then onSavedChanged(entry.name) end
    end)

    updateSaveButton()

    return row
end

return createRow