-- ============================================================
-- InfiniteYieldPlus — generated file, do not edit directly
-- Source: https://github.com/<user>/InfiniteYieldPlus
-- Build:  lua build.lua
-- ============================================================

local __modules, __cache, __loaded = {}, {}, {}

local function __makeScriptProxy(path)
    return setmetatable({__path = path}, {
        __index = function(self, key)
            local p = self.__path
            if key == "Parent" then
                local parent = p:match("^(.*)%.[^.]+$") or ""
                return __makeScriptProxy(parent)
            end
            local newPath = (p == "") and key or (p .. "." .. key)
            return __makeScriptProxy(newPath)
        end,
    })
end

local function __resolve(name)
    if __loaded[name] then return __cache[name] end
    local fn = __modules[name]
    if not fn then error("[IY+] Module not found: " .. tostring(name)) end
    __cache[name] = fn()
    __loaded[name] = true
    return __cache[name]
end

local function __require(mod)
    if type(mod) == "string" then return __resolve(mod) end
    if type(mod) == "table" and mod.__path then return __resolve(mod.__path) end
    error("[IY+] require() expects string or script proxy, got " .. type(mod))
end

local function __register(name, fn) __modules[name] = fn end


__register("Core.IYBridge", function()
    local require = __require
    local script = __makeScriptProxy("Core.IYBridge")
-- Core/IYBridge.lua
local IYBridge = {}

function IYBridge.waitUntilReady(timeout)
    local deadline = tick() + (timeout or 15)
    while tick() < deadline do
        if getgenv().execCmd then return true end
        task.wait(0.2)
    end
    error("[IY+] Infinite Yield tidak terdeteksi setelah timeout.")
end

function IYBridge.execCmd(cmdStr, speaker)
    local fn = getgenv().execCmd
    if not fn then
        error("[IY+] execCmd belum tersedia.")
    end
    return fn(cmdStr, speaker)
end

return IYBridge
end)

__register("Core.Registry", function()
    local require = __require
    local script = __makeScriptProxy("Core.Registry")
-- Core/Registry.lua
local commands = require(script.Parent.Parent.Data.commands)

local Registry = {}
Registry._all = commands

-- Cache lowercase untuk pencarian cepat
local lowerCache = {}
for i, c in ipairs(commands) do
    lowerCache[i] = c.name:lower()
end

function Registry.all()
    return Registry._all
end

function Registry.filter(query, category)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if query == "" and not category then
        return Registry._all
    end

    local out = {}
    for i, cmd in ipairs(Registry._all) do
        local matchQuery = (query == "") or lowerCache[i]:find(query, 1, true)
        local matchCat   = (category == nil) or (cmd.cat == category)
        if matchQuery and matchCat then
            out[#out + 1] = cmd
        end
    end
    return out
end

function Registry.categories()
    local seen, out = {}, {}
    for _, cmd in ipairs(Registry._all) do
        if cmd.cat and not seen[cmd.cat] then
            seen[cmd.cat] = true
            out[#out + 1] = cmd.cat
        end
    end
    return out
end

return Registry
end)

__register("Core.Saved", function()
    local require = __require
    local script = __makeScriptProxy("Core.Saved")
-- Core/Saved.lua
local Saved = {}

local FILE_PATH = "IYPlus_saved.json"
local items = {}          -- array of string
local index = {}          -- set untuk cek cepat
local canPersist = (typeof(writefile) == "function"
                and typeof(readfile) == "function")

local function serialize(list)
    -- escape sederhana untuk JSON-ish
    local parts = {}
    for _, v in ipairs(list) do
        parts[#parts + 1] = '"' .. v:gsub('"', '\\"') .. '"'
    end
    return "[" .. table.concat(parts, ",") .. "]"
end

local function deserialize(str)
    local out = {}
    for v in str:gmatch('"([^"]*)"') do
        out[#out + 1] = v
    end
    return out
end

local function persist()
    if not canPersist then return end
    pcall(function()
        writefile(FILE_PATH, serialize(items))
    end)
end

function Saved.load()
    items, index = {}, {}
    if not canPersist then return end
    pcall(function()
        if isfile and not isfile(FILE_PATH) then return end
        local raw = readfile(FILE_PATH)
        if raw and #raw > 0 then
            for _, v in ipairs(deserialize(raw)) do
                items[#items + 1] = v
                index[v] = true
            end
        end
    end)
end

function Saved.add(name)
    if index[name] then return false end
    items[#items + 1] = name
    index[name] = true
    persist()
    return true
end

function Saved.remove(name)
    if not index[name] then return false end
    index[name] = nil
    for i, v in ipairs(items) do
        if v == name then
            table.remove(items, i)
            break
        end
    end
    persist()
    return true
end

function Saved.toggle(name)
    if index[name] then
        Saved.remove(name); return false
    else
        Saved.add(name); return true
    end
end

function Saved.has(name) return index[name] == true end
function Saved.list() return items end

return Saved
end)

__register("Data.commands", function()
    local require = __require
    local script = __makeScriptProxy("Data.commands")
-- Data/commands.lua
-- Format: { name = "cmd", desc = "deskripsi", cat = "kategori" }
-- cat membantu untuk filter tab kategori nanti

return {
    -- Movement
    { name = "fly",        desc = "Aktifkan mode terbang",                 cat = "Movement" },
    { name = "unfly",      desc = "Matikan mode terbang",                  cat = "Movement" },
    { name = "noclip",     desc = "Tembus objek",                          cat = "Movement" },
    { name = "speed",      desc = "Atur kecepatan. Contoh: speed 100",     cat = "Movement" },
    { name = "jump",       desc = "Atur tinggi lompat. Contoh: jump 100",  cat = "Movement" },
    { name = "hipheight",  desc = "Atur HipHeight karakter",               cat = "Movement" },
    { name = "infjump",    desc = "Lompat tanpa batas",                    cat = "Movement" },
    { name = "nojumpcooldown", desc = "Hilangkan cooldown lompat",         cat = "Movement" },

    -- Combat
    { name = "god",        desc = "Mode kebal (server-side mungkin tidak berlaku)", cat = "Combat" },
    { name = "heal",       desc = "Isi penuh HP karakter",                 cat = "Combat" },
    { name = "kill",       desc = "Bunuh pemain. Contoh: kill all",        cat = "Combat" },
    { name = "loopkill",   desc = "Loop kill target",                      cat = "Combat" },
    { name = "freeze",     desc = "Bekukan pemain. Contoh: freeze all",    cat = "Combat" },
    { name = "thaw",       desc = "Cairkan pemain yang dibekukan",         cat = "Combat" },

    -- Teleport
    { name = "goto",       desc = "Teleport ke pemain. Contoh: goto Bob",  cat = "Teleport" },
    { name = "bring",      desc = "Tarik pemain ke kamu. Contoh: bring all", cat = "Teleport" },
    { name = "tp",         desc = "Alias goto",                            cat = "Teleport" },
    { name = "loopbring",  desc = "Loop tarik pemain",                     cat = "Teleport" },

    -- Visual
    { name = "esp",        desc = "Lihat posisi pemain lewat tembok",      cat = "Visual" },
    { name = "fog",        desc = "Atur kabut. Contoh: fog 100",           cat = "Visual" },
    { name = "skybox",     desc = "Ganti skybox",                          cat = "Visual" },
    { name = "day",        desc = "Atur ke siang",                         cat = "Visual" },
    { name = "night",      desc = "Atur ke malam",                         cat = "Visual" },

    -- Utility
    { name = "rejoin",     desc = "Keluar dan masuk server yang sama",     cat = "Utility" },
    { name = "serverhop",  desc = "Pindah ke server lain",                 cat = "Utility" },
    { name = "antiafk",    desc = "Cegah kick karena AFK",                 cat = "Utility" },
    { name = "btools",     desc = "Beri Building Tools",                   cat = "Utility" },
    { name = "help",       desc = "Tampilkan bantuan IY",                  cat = "Utility" },
    { name = "cmds",       desc = "List semua command IY asli",            cat = "Utility" },
}
end)

__register("UI.Theme", function()
    local require = __require
    local script = __makeScriptProxy("UI.Theme")
-- UI/Theme.lua
local Theme = {
    Colors = {
        Background   = Color3.fromRGB(20, 20, 28),
        Surface      = Color3.fromRGB(30, 30, 42),
        SurfaceHover = Color3.fromRGB(42, 42, 58),
        Accent       = Color3.fromRGB(0, 217, 163),   -- cyan/teal khas IY
        AccentDark   = Color3.fromRGB(0, 150, 115),
        Text         = Color3.fromRGB(235, 235, 245),
        TextDim      = Color3.fromRGB(140, 140, 160),
        Danger       = Color3.fromRGB(235, 80, 80),
        Success      = Color3.fromRGB(80, 220, 130),
    },
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8),
    Padding = 8,
}
return Theme
end)

__register("UI.Layout", function()
    local require = __require
    local script = __makeScriptProxy("UI.Layout")
-- UI/Layout.lua
local UIS = game:GetService("UserInputService")

local Layout = {}

function Layout.isMobile()
    -- Touch aktif tapi keyboard tidak → HP/tablet
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

function Layout.getPanelSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    if Layout.isMobile() then
        -- Mobile: hampir fullscreen, dengan margin kecil
        return UDim2.new(1, -24, 1, -80)
    else
        -- PC: window mengambang, ukuran tetap tapi dibatasi viewport
        local w = math.min(560, viewport.X * 0.5)
        local h = math.min(480, viewport.Y * 0.75)
        return UDim2.fromOffset(w, h)
    end
end

function Layout.getPanelPosition()
    if Layout.isMobile() then
        return UDim2.new(0.5, 0, 0.5, 0)  -- centered
    else
        return UDim2.fromScale(0.5, 0.5)
    end
end

return Layout
end)

__register("UI.Builder", function()
    local require = __require
    local script = __makeScriptProxy("UI.Builder")
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

    return {
    Gui        = gui,
    Panel      = panel,
    Search     = search,
    TabBarSlot = tabSlot,
    List       = list,
}
end

return Builder
end)

__register("UI.CommandRow", function()
    local require = __require
    local script = __makeScriptProxy("UI.CommandRow")
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
end)

__register("UI.TabBar", function()
    local require = __require
    local script = __makeScriptProxy("UI.TabBar")
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
end)

-- === ENTRY ===
do
    local require = __require
    local script = __makeScriptProxy("")
-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge  = require(Core.IYBridge)
local Registry  = require(Core.Registry)
local Saved     = require(Core.Saved)
local Builder   = require(UIMod.Builder)
local createRow = require(UIMod.CommandRow)
local TabBar    = require(UIMod.TabBar)

-- 1. Tunggu IY siap
IYBridge.waitUntilReady()

-- 2. Load daftar favorit tersimpan
Saved.load()

-- 3. Bangun UI
local ui = Builder.create()

-- 4. State
local currentTab = "All"
local renderList, runCommand, saveCommand -- forward declaration

-- 5. Fungsi run
runCommand = function(cmdName)
    local ok, err = pcall(function()
        IYBridge.execCmd(cmdName, game.Players.LocalPlayer)
    end)
    if not ok then
        warn("[IY+] Gagal run:", cmdName, err)
    end
end

-- 6. Fungsi save (toggle)
saveCommand = function(cmdName)
    local nowSaved = Saved.toggle(cmdName)
    print("[IY+] " .. (nowSaved and "Disimpan: " or "Dihapus: ") .. cmdName)
    if currentTab == "Saved" and renderList then renderList() end
end

-- 7. Lookup entry by name (untuk render tab Saved)
local function findEntry(name)
    for _, c in ipairs(Registry.all()) do
        if c.name == name then return c end
    end
end

-- 8. Render command list
renderList = function()
    ui.List:ClearAllChildren()
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = ui.List

    if currentTab == "Saved" then
        for _, name in ipairs(Saved.list()) do
            local entry = findEntry(name)
            if entry then
                createRow(ui.List, entry.name, entry.desc, runCommand, saveCommand)
            end
        end
    else
        local cat = (currentTab == "All") and nil or currentTab
        for _, entry in ipairs(Registry.filter(ui.Search.Text, cat)) do
            createRow(ui.List, entry.name, entry.desc, runCommand, saveCommand)
        end
    end
end

-- 9. TabBar: All + Saved + semua kategori dari registry
local tabs = { "All", "Saved" }
for _, cat in ipairs(Registry.categories()) do
    tabs[#tabs+1] = cat
end

TabBar.create(ui.TabBarSlot, tabs, function(selected)
    currentTab = selected
    renderList()
end, "All")

-- 10. Search realtime
ui.Search:GetPropertyChangedSignal("Text"):Connect(renderList)

renderList()
print("[IY+] UI siap.")
end