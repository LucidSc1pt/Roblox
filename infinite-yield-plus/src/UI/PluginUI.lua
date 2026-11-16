local Theme = require(script.Parent.Theme)
local PluginManager = require(script.Parent.Parent.Core.PluginManager)

local PluginUI = {}

function PluginUI.render(parent, onRefresh)
    parent:ClearAllChildren()
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent

    local function createItem(text, btnText, btnColor, onClick, isActive)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Theme.Colors.Surface
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = Theme.CornerRadius

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -80, 1, 0)
        lbl.Position = UDim2.fromOffset(10, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Theme.Font
        lbl.Text = text
        lbl.TextColor3 = isActive and Theme.Colors.Accent or Theme.Colors.Text
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row

        if btnText then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.fromOffset(60, 24)
            btn.Position = UDim2.new(1, -70, 0.5, -12)
            btn.BackgroundColor3 = btnColor
            btn.BorderSizePixel = 0
            btn.Font = Theme.FontBold
            btn.Text = btnText
            btn.TextColor3 = Theme.Colors.Background
            btn.TextSize = 10
            btn.Parent = row
            Instance.new("UICorner", btn).CornerRadius = Theme.CornerRadius
            btn.MouseButton1Click:Connect(onClick)
        end
    end

    -- 1. Render Plugin yang sudah di-ADD
    local loaded = PluginManager.getAllLoadedPlugins()
    if #loaded > 0 then
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Font = Theme.FontBold
        title.Text = "PLUGIN AKTIF"
        title.TextColor3 = Theme.Colors.TextDim
        title.TextSize = 10
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = parent

        for _, p in ipairs(loaded) do
            createItem(p.data.PluginName or p.path, "REMOVE", Theme.Colors.Danger, function()
                PluginManager.remove(p.path)
                onRefresh()
            end, true)
        end
    end

    -- 2. Render File .iy yang belum di-ADD
    local files = PluginManager.scan()
    local available = {}
    for _, f in ipairs(files) do
        if not PluginManager.isAdded(f) then table.insert(available, f) end
    end

    if #available > 0 then
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Font = Theme.FontBold
        title.Text = "TERSEDIA DI WORKSPACE"
        title.TextColor3 = Theme.Colors.TextDim
        title.TextSize = 10
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = parent

        for _, f in ipairs(available) do
            createItem(f, "ADD", Theme.Colors.Accent, function()
                local ok, err = PluginManager.load(f)
                if ok then
                    PluginManager.add(f)
                    onRefresh()
                else
                    warn("[IY+] Gagal load plugin:", err)
                end
            end, false)
        end
    end

    if #loaded == 0 and #available == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Font = Theme.Font
        empty.Text = "Tidak ada file .iy ditemukan di workspace."
        empty.TextColor3 = Theme.Colors.TextDim
        empty.TextSize = 11
        empty.Parent = parent
    end
end

return PluginUI