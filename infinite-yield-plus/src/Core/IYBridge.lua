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