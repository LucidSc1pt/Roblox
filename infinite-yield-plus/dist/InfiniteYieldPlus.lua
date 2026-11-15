-- ============================================================
-- InfiniteYieldPlus — generated file, do not edit directly
-- Source: https://github.com/LucidSc1pt/Roblox/infinite-yield-plus
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
local Players = game:GetService("Players")

local IYBridge = {}

local cachedCmdbar = nil
local cachedHolder = nil

local function getEnv()
    local ok, env = pcall(function() return getgenv() end)
    if ok and type(env) == "table" then return env end
    return _G
end

local function getContainers()
    local out = {}
    pcall(function()
        if gethui then
            local h = gethui()
            if h then table.insert(out, h) end
        end
    end)
    pcall(function() table.insert(out, game:GetService("CoreGui")) end)
    local pg = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(out, pg) end
    return out
end

-- Cari Holder IY lewat Title label (paling stabil)
local function findHolder()
    if cachedHolder and cachedHolder.Parent then return cachedHolder end
    for _, container in ipairs(getContainers()) do
        local ok, list = pcall(function() return container:GetDescendants() end)
        if ok then
            for _, obj in ipairs(list) do
                if obj:IsA("TextLabel")
                    and obj.Name == "Title"
                    and obj.Text:find("Infinite Yield FE") then
                    cachedHolder = obj.Parent
                    return cachedHolder
                end
            end
        end
    end
    return nil
end

-- Cari TextBox Cmdbar yang sudah di-rename jadi "Input"
local function findCmdbar()
    if cachedCmdbar and cachedCmdbar.Parent then return cachedCmdbar end
    local holder = findHolder()
    if not holder then return nil end

    -- Prioritas: TextBox "Input" di bawah Frame "Cmdbar"
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox")
            and obj.Name == "Input"
            and obj.Parent
            and obj.Parent.Name == "Cmdbar" then
            cachedCmdbar = obj
            return obj
        end
    end
    -- Fallback: TextBox apa pun di Holder (cuma ada 1 = Cmdbar)
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox") then
            cachedCmdbar = obj
            return obj
        end
    end
    return nil
end

function IYBridge.isReady()
    if type(getEnv().execCmd) == "function" then return true end
    return findCmdbar() ~= nil
end

function IYBridge.waitUntilReady(timeout)
    local deadline = tick() + (timeout or 20)
    while tick() < deadline do
        if IYBridge.isReady() then return true end
        task.wait(0.25)
    end

    local env = getEnv()
    local status = string.format(
        "\n  IY_LOADED     : %s" ..
        "\n  execCmd       : %s" ..
        "\n  Title(holder) : %s" ..
        "\n  Cmdbar        : %s" ..
        "\n  gethui        : %s" ..
        "\n  firefocuslost : %s",
        tostring(env.IY_LOADED),
        tostring(type(env.execCmd) == "function"),
        tostring(findHolder() ~= nil),
        tostring(findCmdbar() ~= nil),
        tostring(gethui ~= nil),
        tostring(type(firefocuslost) == "function")
    )
    error("[IY+] Infinite Yield tidak siap dalam " .. (timeout or 20) .. "s. Status:" .. status)
end

function IYBridge.execCmd(cmdStr, speaker)
    -- Jalur 1: kalau executor kebetulan expose (jarang tapi gratis dicoba)
    local env = getEnv()
    if type(env.execCmd) == "function" then
        local ok, err = pcall(env.execCmd, cmdStr, speaker or Players.LocalPlayer)
        if ok then return end
        warn("[IY+] execCmd dari env gagal, fallback Cmdbar:", err)
    end

    local cmdbar = findCmdbar()
    if not cmdbar then
        error("[IY+] Cmdbar IY tidak ditemukan. IY mungkin belum selesai loading.")
    end

    -- Jalur 2: firefocuslost (kalau executor support)
    if type(firefocuslost) == "function" then
        local ok = pcall(function()
            cmdbar.Text = cmdStr
            firefocuslost(cmdbar, true)
        end)
        if ok then return end
    end

    -- Jalur 3: CaptureFocus -> ReleaseFocus(true)
    local ok, err = pcall(function()
        cmdbar:CaptureFocus()
        task.wait(0.1)
        if not cmdbar:IsFocused() then
            cmdbar:CaptureFocus()
            task.wait(0.1)
        end
        cmdbar.Text = cmdStr
        task.wait()
        cmdbar:ReleaseFocus(true)
    end)
    if not ok then
        error("[IY+] Gagal trigger Cmdbar (" .. tostring(err) .. "). "
            .. "Executor mungkin tidak support CaptureFocus/ReleaseFocus.")
    end
end

-- Parsing: "speed / ws / walkspeed [num]" → name="speed", aliases={"ws","walkspeed"}
local function parseCMDName(raw)
    local stripped = raw:gsub("%s*%[[^%]]*%]", "")
    local parts = {}
    for part in stripped:gmatch("([^/]+)") do
        part = part:gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then table.insert(parts, part) end
    end
    if #parts == 0 then return nil end
    return parts[1], parts
end

function IYBridge.extractCommands(timeout)
    local deadline = tick() + (timeout or 15)
    while tick() < deadline do
        local holder = findHolder()
        if holder then
            local cmdsFrame = holder:FindFirstChild("CMDs")
            -- Tunggu sampai CMDsF terisi (IY populate setelah Cmdbar)
            if cmdsFrame and #cmdsFrame:GetChildren() > 20 then
                local list = {}
                for _, child in ipairs(cmdsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local title = child:GetAttribute("Title")
                        if title and title ~= "" then
                            local primary, parts = parseCMDName(title)
                            if primary then
                                local aliases = {}
                                for i = 2, #parts do
                                    table.insert(aliases, parts[i])
                                end
                                table.insert(list, {
                                    name = primary,
                                    fullName = title,
                                    aliases = aliases,
                                    desc = child:GetAttribute("Desc") or "",
                                })
                            end
                        end
                    end
                end
                return list
            end
        end
        task.wait(0.3)
    end
    return {}
end

function IYBridge.diagnose()
    local env = getEnv()
    return {
        IY_LOADED     = env.IY_LOADED,
        execCmd       = type(env.execCmd) == "function",
        title         = findHolder() ~= nil,
        cmdbar        = findCmdbar() ~= nil,
        gethui        = gethui ~= nil,
        firefocuslost = type(firefocuslost) == "function",
    }
end

return IYBridge
end)

__register("Core.Registry", function()
    local require = __require
    local script = __makeScriptProxy("Core.Registry")
local manualCommands = require(script.Parent.Parent.Data.commands)

local Registry = {}
local lowerCache = {}

-- Kategorisasi otomatis berdasarkan keyword di name + desc
local categoryRules = {
    { cat = "Movement",  patterns = {"fly", "speed", "jump", "noclip", "walk", "swim", "float", "clip", "hip", "gravity", "spin", "stun", "trip", "edgejump", "autojump", "wallwalk", "cframe", "anchor", "platform", "velocity", "teleportwalk", "tpwalk"} },
    { cat = "Combat",    patterns = {"kill", "freeze", "thaw", "god", "heal", "damage", "bang", "fling", "hitbox", "reach", "hkill", "antifling", "unanchored", "unanchor", "spasm"} },
    { cat = "Teleport",  patterns = {"tp", "teleport", "goto", "bring", "waypoint", "spawn", "offset", "thru", "tween", "walltp", "flashback", "rejoin", "serverhop", "pulsetp", "walkto"} },
    { cat = "Visual",    patterns = {"esp", "cham", "xray", "fog", "bright", "dark", "light", "sky", "ambient", "day", "night", "restorelight"} },
    { cat = "Camera",    patterns = {"freecam", "cam", "fov", "zoom", "lookat", "fixcam", "firstp", "thirdp", "noclipcam", "shiftlock"} },
    { cat = "Tools",     patterns = {"tool", "btool", "f3x", "grip", "dupetool", "drop", "grab", "use", "removetool", "boxreach"} },
    { cat = "Chat",      patterns = {"chat", "spam", "whisper", "pm", "say", "vsay", "bubble", "logswebhook"} },
    { cat = "Character", patterns = {"char", "hat", "head", "arm", "leg", "naked", "face", "torso", "accessory", "anim", "emote", "dance", "creeper", "nilchar", "split"} },
    { cat = "Player",    patterns = {"age", "joindate", "userid", "appearance", "friend", "inspect", "rolewatch", "staffwatch", "listento", "copyuser", "copyid"} },
    { cat = "Utility",   patterns = {"rejoin", "antiafk", "console", "explorer", "dex", "spy", "gui", "scale", "alias", "bind", "keybind", "notify", "log", "addplugin", "removeplugin", "clearerror", "volume", "record", "screenshot", "togglefs", "alignment", "ctrl", "click", "mousesens", "savegame", "antigameplay"} },
}

local function categorize(name, desc)
    local search = (name .. " " .. (desc or "")):lower()
    for _, rule in ipairs(categoryRules) do
        for _, pattern in ipairs(rule.patterns) do
            if search:find(pattern, 1, true) then
                return rule.cat
            end
        end
    end
    return "Misc"
end

local function rebuildCache()
    lowerCache = {}
    for i, c in ipairs(Registry._all) do
        lowerCache[i] = c.name:lower()
    end
end

-- Fallback awal (sebelum auto-detect)
Registry._all = manualCommands
rebuildCache()

function Registry.setAutoCommands(autoList)
    local manualByName = {}
    for _, m in ipairs(manualCommands) do
        manualByName[m.name] = m
    end

    local merged = {}
    local seen = {}
    for _, auto in ipairs(autoList) do
        if not seen[auto.name] then
            seen[auto.name] = true
            local manual = manualByName[auto.name]
            if manual then
                -- Override: gunakan versi manual (punya args)
                local m = {}
                for k, v in pairs(manual) do m[k] = v end
                m.fullName = auto.fullName or m.fullName or m.name
                m.aliases = auto.aliases or m.aliases
                table.insert(merged, m)
            else
                table.insert(merged, {
                    name = auto.name,
                    fullName = auto.fullName,
                    aliases = auto.aliases,
                    desc = auto.desc,
                    cat = categorize(auto.name, auto.desc),
                })
            end
        end
    end

    for _, m in ipairs(manualCommands) do
        if not seen[m.name] then
            seen[m.name] = true
            table.insert(merged, m)
        end
    end

    Registry._all = merged
    rebuildCache()
end

function Registry.all() return Registry._all end

function Registry.filter(query, category)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local out = {}
    for i, cmd in ipairs(Registry._all) do
        local matchCat = (category == nil) or (cmd.cat == category)
        if matchCat then
            if query == "" then
                out[#out+1] = cmd
            else
                local hit = lowerCache[i]:find(query, 1, true) ~= nil
                if not hit and cmd.desc then
                    hit = cmd.desc:lower():find(query, 1, true) ~= nil
                end
                if not hit and cmd.aliases then
                    for _, a in ipairs(cmd.aliases) do
                        if a:lower():find(query, 1, true) then hit = true break end
                    end
                end
                if hit then out[#out+1] = cmd end
            end
        end
    end
    return out
end

function Registry.categories()
    local seen, out = {}, {}
    for _, cmd in ipairs(Registry._all) do
        if cmd.cat and not seen[cmd.cat] then
            seen[cmd.cat] = true
            out[#out+1] = cmd.cat
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
return {
    -- Movement
    { name = "fly", desc = "Aktifkan mode terbang", cat = "Movement",
      args = { { key = "speed", placeholder = "default", default = "" } } },
    { name = "unfly", desc = "Matikan mode terbang", cat = "Movement" },
    { name = "noclip", desc = "Tembus objek", cat = "Movement" },
    { name = "speed", desc = "Atur kecepatan", cat = "Movement",
      args = { { key = "value", placeholder = "16", default = "16" } } },
    { name = "jump", desc = "Atur tinggi lompat", cat = "Movement",
      args = { { key = "power", placeholder = "50", default = "50" } } },
    { name = "hipheight", desc = "Atur HipHeight", cat = "Movement",
      args = { { key = "value", placeholder = "0", default = "0" } } },
    { name = "infjump", desc = "Lompat tanpa batas", cat = "Movement" },

    -- Combat
    { name = "god", desc = "Mode kebal", cat = "Combat" },
    { name = "heal", desc = "Isi penuh HP", cat = "Combat" },
    { name = "kill", desc = "Bunuh pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "loopkill", desc = "Loop kill target", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "freeze", desc = "Bekukan pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "thaw", desc = "Cairkan pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },

    -- Teleport
    { name = "goto", desc = "Teleport ke pemain", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "bring", desc = "Tarik pemain ke kamu", cat = "Teleport",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "tp", desc = "Alias goto", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "loopbring", desc = "Loop tarik pemain", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "tppos", desc = "Teleport ke koordinat", cat = "Teleport",
      args = {
        { key = "x", placeholder = "0", default = "0" },
        { key = "y", placeholder = "0", default = "0" },
        { key = "z", placeholder = "0", default = "0" },
      } },

    -- Visual
    { name = "esp", desc = "Lihat posisi pemain", cat = "Visual" },
    { name = "fog", desc = "Atur kabut", cat = "Visual",
      args = { { key = "value", placeholder = "100", default = "100" } } },
    { name = "brightness", desc = "Atur brightness", cat = "Visual",
      args = { { key = "value", placeholder = "2", default = "2" } } },
    { name = "day", desc = "Atur ke siang", cat = "Visual" },
    { name = "night", desc = "Atur ke malam", cat = "Visual" },

    -- Utility
    { name = "rejoin", desc = "Keluar dan masuk server sama", cat = "Utility" },
    { name = "serverhop", desc = "Pindah ke server lain", cat = "Utility" },
    { name = "antiafk", desc = "Cegah kick karena AFK", cat = "Utility" },
    { name = "btools", desc = "Beri Building Tools", cat = "Utility" },
    { name = "notify", desc = "Kirim notifikasi", cat = "Utility",
      args = { { key = "text", placeholder = "Pesan..." } } },
    { name = "chat", desc = "Kirim chat", cat = "Utility",
      args = { { key = "text", placeholder = "Pesan..." } } },
    { name = "help", desc = "Tampilkan bantuan IY", cat = "Utility" },
    { name = "cmds", desc = "List semua command IY", cat = "Utility" },
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
        return UDim2.new(0.85, 0, 0.62, 0)      -- 85% × 62%, dari sebelumnya 100%×80%
    else
        local w = math.min(400, viewport.X * 0.4)
        local h = math.min(360, viewport.Y * 0.65)
        return UDim2.fromOffset(w, h)            -- 400×360, dari sebelumnya 560×480
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
end)

__register("UI.CommandRow", function()
    local require = __require
    local script = __makeScriptProxy("UI.CommandRow")
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

-- 1b. Auto-extract commands dari IY GUI
print("[IY+] Extracting commands from IY...")
local autoCmds = IYBridge.extractCommands(15)
print("[IY+] Found " .. #autoCmds .. " commands")
Registry.setAutoCommands(autoCmds)

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

    local entries = {}

    if currentTab == "Saved" then
        for _, name in ipairs(Saved.list()) do
            for _, e in ipairs(Registry.all()) do
                if e.name == name then
                    table.insert(entries, e)
                    break
                end
            end
        end
    elseif currentTab == "All" then
        entries = Registry.all()
    else
        entries = Registry.filter("", currentTab)
    end

    -- Apply search filter secara terpisah (setelah tentukan base list)
    local query = ui.Search.Text
    if query and query ~= "" then
        local lowerQuery = query:lower()
        local filtered = {}
        for _, e in ipairs(entries) do
            if e.name:lower():find(lowerQuery, 1, true) then
                table.insert(filtered, e)
            end
        end
        entries = filtered
    end

    for _, entry in ipairs(entries) do
        createRow(ui.List, entry, runCommand, saveCommand)
    end

    print(string.format("[IY+] Rendered %d entries for tab '%s' (query='%s')",
        #entries, currentTab, query or ""))
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