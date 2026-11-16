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

local function findCmdbar()
    if cachedCmdbar and cachedCmdbar.Parent then return cachedCmdbar end
    local holder = findHolder()
    if not holder then return nil end
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox")
            and obj.Name == "Input"
            and obj.Parent
            and obj.Parent.Name == "Cmdbar" then
            cachedCmdbar = obj
            return obj
        end
    end
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox") then
            cachedCmdbar = obj
            return obj
        end
    end
    return nil
end

-- Keyword → tipe argumen
local NUMBER_KEYWORDS = {
    "num", "number", "delay", "distance", "radius", "brightness",
    "size", "transparency", "speed", "amount", "seconds",
}

local STRING_KEYWORDS = {
    "url", "text", "statetype", "emote", "key", "type", "cmd", "alias",
}

-- Cek keyword dengan word-boundary (awal / akhir / standalone)
local function matchKeyword(lower, kw)
    if lower == kw then return true end
    if lower:match("^" .. kw .. "%s") then return true end
    if lower:match("%s" .. kw .. "$") then return true end
    return false
end

local function parseArgGroup(raw)
    local group = raw:match("^%s*(.-)%s*$")
    if group == "" then return nil end
    local lower = group:lower()

    -- 1. "X Y Z" — koordinat 3 sumbu
    local upper = group:gsub("%s", "")
    if upper:match("^[XYZ]+$") and #upper == 3 then
        return {
            { type = "number", key = "X", placeholder = "0", default = "" },
            { type = "number", key = "Y", placeholder = "0", default = "" },
            { type = "number", key = "Z", placeholder = "0", default = "" },
        }
    end

    -- 2. Range numerik, misal "1-10" atau "0-255"
    if lower:match("^%d+%s*%-%s*%d+$") then
        return { { type = "number", key = "value", placeholder = group, default = "" } }
    end

    -- 3. Angka tunggal, misal "5" atau "100"
    if lower:match("^%d+$") then
        return { { type = "number", key = "value", placeholder = group, default = group } }
    end

    -- 4. Boolean
    if lower == "true" or lower == "false"
        or lower:match("^true%s*/%s*false$") then
        return { { type = "bool", key = "toggle", placeholder = "true / false", default = "" } }
    end

    -- 5. Player
    if lower:match("player") then
        return { { type = "player", key = "player", placeholder = "all", default = "all" } }
    end

    -- 6. ID
    if lower == "id" or lower:match("%sid$") or lower:match("^id%s") then
        return { { type = "id", key = "ID", placeholder = group, default = "" } }
    end

    -- 7. Keyword angka
    for _, kw in ipairs(NUMBER_KEYWORDS) do
        if matchKeyword(lower, kw) then
            return { { type = "number", key = kw, placeholder = group, default = "" } }
        end
    end

    -- 8. Keyword string
    for _, kw in ipairs(STRING_KEYWORDS) do
        if matchKeyword(lower, kw) then
            return { { type = "string", key = kw, placeholder = group, default = "" } }
        end
    end

    -- 9. Fallback nama
    if lower:match("name") then
        return { { type = "string", key = "name", placeholder = group, default = "" } }
    end

    -- 10. Fallback umum
    return { { type = "string", key = group, placeholder = group, default = "" } }
end

local function parseArgsFromTitle(title)
    local args = {}
    for group in title:gmatch("%[([^%]]+)%]") do
        local parsed = parseArgGroup(group)
        if parsed then
            for _, a in ipairs(parsed) do
                table.insert(args, a)
            end
        end
    end
    return args
end

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
    error("[IY+] Infinite Yield tidak siap dalam " .. (timeout or 20) .. "s.")
end

function IYBridge.execCmd(cmdStr, speaker)
    local env = getEnv()
    if type(env.execCmd) == "function" then
        local ok = pcall(env.execCmd, cmdStr, speaker or Players.LocalPlayer)
        if ok then return end
    end
    local cmdbar = findCmdbar()
    if not cmdbar then
        error("[IY+] Cmdbar IY tidak ditemukan.")
    end
    if type(firefocuslost) == "function" then
        local ok = pcall(function()
            cmdbar.Text = cmdStr
            firefocuslost(cmdbar, true)
        end)
        if ok then return end
    end
    local ok, err = pcall(function()
        cmdbar:CaptureFocus()
        task.wait(0.1)
        cmdbar.Text = cmdStr
        task.wait()
        cmdbar:ReleaseFocus(true)
    end)
    if not ok then
        error("[IY+] Gagal trigger Cmdbar: " .. tostring(err))
    end
end

function IYBridge.extractCommands(timeout)
    local deadline = tick() + (timeout or 15)
    while tick() < deadline do
        local holder = findHolder()
        if holder then
            local cmdsFrame = holder:FindFirstChild("CMDs")
            if cmdsFrame and #cmdsFrame:GetChildren() > 20 then
                local list = {}
                local index = 0
                for _, child in ipairs(cmdsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local title = child:GetAttribute("Title")
                        if title and title ~= "" then
                            local primary, parts = parseCMDName(title)
                            if primary then
                                index = index + 1
                                local aliases = {}
                                for i = 2, #parts do
                                    table.insert(aliases, parts[i])
                                end
                                table.insert(list, {
                                    name = primary,
                                    fullName = title,
                                    aliases = aliases,
                                    desc = child:GetAttribute("Desc") or "",
                                    args = parseArgsFromTitle(title),
                                    order = index,
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

return IYBridge
end)

__register("Core.Registry", function()
    local require = __require
    local script = __makeScriptProxy("Core.Registry")
local manualCommands = require(script.Parent.Parent.Data.commands)
local Registry = {}
local lowerCache = {}

local categoryRules = {
    { cat = "Movement", patterns = {"fly","speed","jump","noclip","walk","swim","float","clip","hip","gravity","spin","stun","trip","edgejump","autojump","wallwalk","cframe","anchor","platform","velocity","teleportwalk","tpwalk"} },
    { cat = "Combat", patterns = {"kill","freeze","thaw","god","heal","damage","bang","fling","hitbox","reach","hkill","antifling","unanchored","spasm"} },
    { cat = "Teleport", patterns = {"tp","teleport","goto","bring","waypoint","spawn","offset","thru","tween","walltp","flashback","rejoin","serverhop","pulsetp","walkto"} },
    { cat = "Visual", patterns = {"esp","cham","xray","fog","bright","dark","light","sky","ambient","day","night","restorelight"} },
    { cat = "Camera", patterns = {"freecam","cam","fov","zoom","lookat","fixcam","firstp","thirdp","noclipcam","shiftlock"} },
    { cat = "Tools", patterns = {"tool","btool","f3x","grip","dupetool","drop","grab","use","removetool","boxreach"} },
    { cat = "Chat", patterns = {"chat","spam","whisper","pm","say","vsay","bubble","logswebhook"} },
    { cat = "Character", patterns = {"char","hat","head","arm","leg","naked","face","torso","accessory","anim","emote","dance","creeper","nilchar","split"} },
    { cat = "Player", patterns = {"age","joindate","userid","appearance","friend","inspect","rolewatch","staffwatch","listento","copyuser","copyid"} },
    { cat = "Utility", patterns = {"rejoin","antiafk","console","explorer","dex","spy","gui","scale","alias","bind","notify","log","addplugin","removeplugin","clearerror","volume","record","screenshot","togglefs","alignment","ctrl","click","mousesens","savegame","antigameplay"} },
}

local function categorize(name, desc)
    local search = (name .. " " .. (desc or "")):lower()
    for _, rule in ipairs(categoryRules) do
        for _, pattern in ipairs(rule.patterns) do
            if search:find(pattern, 1, true) then return rule.cat end
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

Registry._all = manualCommands
rebuildCache()

function Registry.setAutoCommands(autoList)
    local manualByName = {}
    for _, m in ipairs(manualCommands) do
        manualByName[m.name] = m
    end

    local merged, seen = {}, {}
    for i, auto in ipairs(autoList) do
        if not seen[auto.name] then
            seen[auto.name] = true
            local manual = manualByName[auto.name]
            if manual then
                local m = {}
                for k, v in pairs(manual) do m[k] = v end
                m.fullName = auto.fullName or m.fullName or m.name
                m.aliases = auto.aliases or m.aliases
                if not m.args and auto.args and #auto.args > 0 then m.args = auto.args end
                m.order = i
                table.insert(merged, m)
            else
                table.insert(merged, {
                    name = auto.name,
                    fullName = auto.fullName,
                    aliases = auto.aliases,
                    desc = auto.desc,
                    cat = categorize(auto.name, auto.desc),
                    args = auto.args,
                    order = i,
                })
            end
        end
    end

    for _, m in ipairs(manualCommands) do
        if not seen[m.name] then
            seen[m.name] = true
            local mm = {}
            for k, v in pairs(m) do mm[k] = v end
            mm.order = #merged + 1
            table.insert(merged, mm)
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

function Registry.get(name)
    for _, cmd in ipairs(Registry._all) do
        if cmd.name == name then return cmd end
    end
    return nil
end

return Registry
end)

__register("Core.Saved", function()
    local require = __require
    local script = __makeScriptProxy("Core.Saved")
-- Core/Saved.lua
local HttpService = game:GetService("HttpService")
local Saved = {}

local FILE_PATH = "IYPlus_saved.json"
local items = {}          -- array of { name, argValues }
local index = {}          -- name -> item
local canPersist = (typeof(writefile) == "function" and typeof(readfile) == "function")

local function persist()
    if not canPersist then return end
    pcall(function()
        writefile(FILE_PATH, HttpService:JSONEncode(items))
    end)
end

function Saved.load()
    items, index = {}, {}
    if not canPersist then return end
    pcall(function()
        if isfile and not isfile(FILE_PATH) then return end
        local raw = readfile(FILE_PATH)
        if raw and #raw > 0 then
            local decoded = HttpService:JSONDecode(raw)
            if type(decoded) == "table" then
                for _, v in ipairs(decoded) do
                    -- Backward compatibility (jika sebelumnya string)
                    if type(v) == "string" then
                        v = { name = v, argValues = {} }
                    end
                    if type(v) == "table" and v.name then
                        v.argValues = v.argValues or {}
                        items[#items + 1] = v
                        index[v.name] = v
                    end
                end
            end
        end
    end)
end

function Saved.add(name, argValues)
    if index[name] then return false end
    local item = { name = name, argValues = argValues or {} }
    items[#items + 1] = item
    index[name] = item
    persist()
    return true
end

function Saved.remove(name)
    if not index[name] then return false end
    index[name] = nil
    for i, v in ipairs(items) do
        if v.name == name then
            table.remove(items, i)
            break
        end
    end
    persist()
    return true
end

function Saved.update(name, argValues)
    local item = index[name]
    if not item then return false end
    item.argValues = argValues or {}
    persist()
    return true
end

function Saved.get(name) return index[name] end
function Saved.list() return items end

return Saved
end)

__register("Data.commands", function()
    local require = __require
    local script = __makeScriptProxy("Data.commands")
return {
    
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
local UIS = game:GetService("UserInputService")
local Layout = {}

function Layout.isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

function Layout.getPanelSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    if Layout.isMobile() then
        local w = math.min(viewport.X * 0.7, 380)
        local h = math.min(viewport.Y * 0.62, 520)
        return UDim2.fromOffset(w, h)
    else
        local w = math.min(320, viewport.X * 0.32)
        local h = math.min(340, viewport.Y * 0.6)
        return UDim2.fromOffset(w, h)
    end
end

function Layout.getPanelPosition()
    if Layout.isMobile() then
        return UDim2.new(0.5, 0, 0.5, 0)
    else
        return UDim2.fromScale(0.5, 0.5)
    end
end

return Layout
end)

__register("UI.Builder", function()
    local require = __require
    local script = __makeScriptProxy("UI.Builder")
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
    refreshBtn.Text = "⟳"
    refreshBtn.TextColor3 = Theme.Colors.TextDim
    refreshBtn.TextSize = 16
    refreshBtn.Parent = btnArea

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(30, 34)
    closeBtn.Position = UDim2.fromOffset(30, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Theme.FontBold
    closeBtn.Text = "✕"
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
end)

__register("UI.CommandRow", function()
    local require = __require
    local script = __makeScriptProxy("UI.CommandRow")
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
        btn.Size = UDim2.fromOffset(0, 24)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Theme.Colors.Surface
        btn.BorderSizePixel = 0
        btn.Font = Theme.FontBold
        btn.Text = tabName
        btn.TextColor3 = Theme.Colors.TextDim
        btn.TextSize = 10
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
local Theme     = require(UIMod.Theme)

IYBridge.waitUntilReady()
Saved.load()

local ui = Builder.create()
local autoCmds = IYBridge.extractCommands(15)
if #autoCmds > 0 then
    Registry.setAutoCommands(autoCmds)
end

local currentTab = "All"
local currentRows = {}     -- Array of { row = Instance, searchStr = "string" }
local buildToken = nil     -- Mencegah bentrok saat ganti tab cepat
local applySearch, buildList, runCommand, onSavedChanged

runCommand = function(cmdName)
    local ok, err = pcall(function()
        IYBridge.execCmd(cmdName, game.Players.LocalPlayer)
    end)
    if not ok then
        warn("[IY+] Gagal run:", cmdName, err)
    end
end

onSavedChanged = function(cmdName)
    if currentTab == "Saved" then
        buildList()
    end
end

-- Optimasi Search: Hanya loop string (tidak menyentuh Instance)
applySearch = function(query)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, item in ipairs(currentRows) do
        if query == "" then
            item.row.Visible = true
        else
            item.row.Visible = item.searchStr:find(query, 1, true) ~= nil
        end
    end
end

-- Optimasi Render: Chunking (memecah render agar tidak freeze)
buildList = function()
    if buildToken then buildToken = nil end
    local thisBuild = {}
    buildToken = thisBuild

    ui.List:ClearAllChildren()
    currentRows = {}

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = ui.List

    local entries = {}
    if currentTab == "Saved" then
        for _, savedItem in ipairs(Saved.list()) do
            local baseEntry = Registry.get(savedItem.name)
            if baseEntry then
                local copy = {}
                for k, v in pairs(baseEntry) do copy[k] = v end
                copy._savedArgs = savedItem.argValues
                table.insert(entries, copy)
            end
        end
    elseif currentTab == "All" then
        entries = Registry.all()
    else
        entries = Registry.filter("", currentTab)
    end

    -- Render menggunakan task.spawn dengan jeda
    task.spawn(function()
        for i, entry in ipairs(entries) do
            if buildToken ~= thisBuild then break end -- Batalkan jika user ganti tab saat loading

            local row = createRow(ui.List, entry, runCommand, onSavedChanged)
            
            -- Siapkan string pencarian (Name + FullName + Desc + Aliases)
            local parts = { entry.name }
            if entry.fullName then table.insert(parts, entry.fullName) end
            if entry.desc then table.insert(parts, entry.desc) end
            if entry.aliases then
                for _, a in ipairs(entry.aliases) do table.insert(parts, a) end
            end
            
            table.insert(currentRows, {
                row = row,
                searchStr = table.concat(parts, " "):lower()
            })

            -- Beri napas 1 frame setiap 20 command
            if i % 20 == 0 then
                task.wait()
            end
        end
        
        -- Terapkan search terakhir setelah selesai render
        if buildToken == thisBuild then
            applySearch(ui.Search.Text)
        end
    end)
end

-- Fungsi membuat TabBar
local function setupTabs()
    local tabs = { "All", "Saved" }
    for _, cat in ipairs(Registry.categories()) do
        tabs[#tabs+1] = cat
    end
    
    ui.TabBarSlot:ClearAllChildren()
    TabBar.create(ui.TabBarSlot, tabs, function(selected)
        currentTab = selected
        buildList()
    end, currentTab)
end

setupTabs()

-- Debounce Pencarian (Hanya jalan setengah detik setelah berhenti ngetik)
local searchToken = 0
ui.Search:GetPropertyChangedSignal("Text"):Connect(function()
    searchToken = searchToken + 1
    local myToken = searchToken
    task.delay(0.15, function()
        if myToken == searchToken then
            applySearch(ui.Search.Text)
        end
    end)
end)

-- Tombol Close (X)
ui.CloseBtn.MouseButton1Click:Connect(function()
    ui.Gui:Destroy()
end)

-- Tombol Refresh (⟳)
ui.RefreshBtn.MouseButton1Click:Connect(function()
    ui.RefreshBtn.TextColor3 = Theme.Colors.Accent -- Efek loading
    task.spawn(function()
        -- Ekstrak ulang dari IY (Berguna jika baru nge-load plugin baru)
        local newCmds = IYBridge.extractCommands(5)
        if #newCmds > 0 then
            Registry.setAutoCommands(newCmds)
        end
        
        -- Reset tab ke All jika kategori tab lama hilang
        local valid = false
        for _, cat in ipairs(Registry.categories()) do
            if cat == currentTab then valid = true break end
        end
        if currentTab ~= "All" and currentTab ~= "Saved" and not valid then
            currentTab = "All"
        end

        setupTabs()
        buildList()
        ui.RefreshBtn.TextColor3 = Theme.Colors.TextDim -- Selesai loading
    end)
end)

buildList()
end