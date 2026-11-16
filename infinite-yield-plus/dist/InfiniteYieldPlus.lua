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
local baseCommands = require(script.Parent.Parent.Data.commands)
local PluginManager = require(script.Parent.PluginManager)

local Registry = {}
Registry._all = {}
Registry._byName = {}
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

-- Parser Argumen (sama seperti sebelumnya)
local NUMBER_KEYWORDS = {"num","number","delay","distance","radius","brightness","size","transparency","speed","amount","seconds"}
local STRING_KEYWORDS = {"url","text","statetype","emote","key","type","cmd","alias"}
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
    local upper = group:gsub("%s", "")
    if upper:match("^[XYZ]+$") and #upper == 3 then
        return {{type="number", key="X", placeholder="0", default=""}, {type="number", key="Y", placeholder="0", default=""}, {type="number", key="Z", placeholder="0", default=""}}
    end
    if lower:match("^%d+%s*%-%s*%d+$") then return {{type="number", key="value", placeholder=group, default=""}} end
    if lower:match("^%d+$") then return {{type="number", key="value", placeholder=group, default=group}} end
    if lower == "true" or lower == "false" or lower:match("^true%s*/%s*false$") then return {{type="bool", key="toggle", placeholder="true / false", default=""}} end
    if lower:match("player") then return {{type="player", key="player", placeholder="all", default="all"}} end
    if lower == "id" or lower:match("%sid$") or lower:match("^id%s") then return {{type="id", key="ID", placeholder=group, default=""}} end
    for _, kw in ipairs(NUMBER_KEYWORDS) do
        if matchKeyword(lower, kw) then return {{type="number", key=kw, placeholder=group, default=""}} end
    end
    for _, kw in ipairs(STRING_KEYWORDS) do
        if matchKeyword(lower, kw) then return {{type="string", key=kw, placeholder=group, default=""}} end
    end
    if lower:match("name") then return {{type="string", key="name", placeholder=group, default=""}} end
    return {{type="string", key=group, placeholder=group, default=""}}
end
local function parseArgsFromTitle(title)
    local args = {}
    for group in title:gmatch("%[([^%]]+)%]") do
        local parsed = parseArgGroup(group)
        if parsed then
            for _, a in ipairs(parsed) do table.insert(args, a) end
        end
    end
    return args
end

function Registry.rebuild()
    Registry._all = {}
    Registry._byName = {}
    lowerCache = {}
    local order = 0

    -- 1. Masukkan Command Bawaan IY
    for _, cmd in ipairs(baseCommands) do
        if cmd.NAME and cmd.NAME ~= "" then
            local primary, parts = parseCMDName(cmd.NAME)
            if primary then
                order = order + 1
                local aliases = {}
                for i = 2, #parts do table.insert(aliases, parts[i]) end
                
                local entry = {
                    name = primary,
                    fullName = cmd.NAME,
                    aliases = aliases,
                    desc = cmd.DESC or "",
                    cat = categorize(primary, cmd.DESC),
                    args = parseArgsFromTitle(cmd.NAME),
                    order = order
                }
                table.insert(Registry._all, entry)
                Registry._byName[primary] = entry
            end
        end
    end

    -- 2. Masukkan Command dari Plugin yang aktif
    local activePlugins = PluginManager.getAllLoadedPlugins()
    for _, p in ipairs(activePlugins) do
        for cmdName, cmdData in pairs(p.data.Commands or {}) do
            order = order + 1
            local entry = {
                name = cmdName,
                fullName = cmdData.ListName or cmdName,
                aliases = cmdData.Aliases or {},
                desc = cmdData.Description or "",
                cat = "Plugin",
                args = parseArgsFromTitle(cmdData.ListName or cmdName),
                order = order,
                func = cmdData.Function, -- Fungsi eksekusi plugin
                pluginPath = p.path
            }
            table.insert(Registry._all, entry)
            Registry._byName[cmdName] = entry
        end
    end

    for i, c in ipairs(Registry._all) do
        lowerCache[i] = c.name:lower()
    end
end

function Registry.all() return Registry._all end
function Registry.get(name) return Registry._byName[name] end

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
                if not hit and cmd.desc then hit = cmd.desc:lower():find(query, 1, true) ~= nil end
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

__register("Core.PluginManager", function()
    local require = __require
    local script = __makeScriptProxy("Core.PluginManager")
-- Core/PluginManager.lua
local PluginManager = {}

local loadedPlugins = {} -- [path] = pluginData
local addedPaths = {}    -- [path] = true

-- Cari file .iy di workspace executor
function PluginManager.scan()
    if not listfiles or not isfolder then return {} end
    local files = listfiles("")
    local found = {}
    for _, f in ipairs(files) do
        if f:sub(-3) == ".iy" and not isfolder(f) and f:lower() ~= "iy_fe.iy" then
            table.insert(found, f)
        end
    end
    return found
end

-- Muat file .iy ke dalam memori
function PluginManager.load(path)
    if loadedPlugins[path] then return true, loadedPlugins[path] end
    if not (readfile and loadfile) then return false, "Executor tidak support loadfile" end
    
    local success, result = pcall(function()
        return loadfile(path)()
    end)
    
    if success and type(result) == "table" and result.PluginName then
        loadedPlugins[path] = result
        return true, result
    end
    return false, tostring(result)
end

function PluginManager.unload(path)
    loadedPlugins[path] = nil
end

function PluginManager.add(path)
    addedPaths[path] = true
end

function PluginManager.remove(path)
    addedPaths[path] = nil
    PluginManager.unload(path)
end

function PluginManager.getLoaded()
    return loadedPlugins
end

function PluginManager.isAdded(path)
    return addedPaths[path] == true
end

function PluginManager.getAllLoadedPlugins()
    -- Menggabungkan plugin yang sudah "add" dan berhasil "load"
    local result = {}
    for path, plugin in pairs(loadedPlugins) do
        if addedPaths[path] then
            table.insert(result, { path = path, data = plugin })
        end
    end
    return result
end

return PluginManager
end)

__register("Data.commands", function()
    local require = __require
    local script = __makeScriptProxy("Data.commands")
-- Data/commands.lua
-- Copy semua baris "CMDs[#CMDs + 1] = {NAME = ..., DESC = ...}" dari source IY dan paste di sini.
local rawCMDString = [=[
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the Infinite Yield Discord server.'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the GUI. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens Dex by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt [player]', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/AFK'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Sets outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Sets IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your UserId to the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute IY when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disables keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Saves the game you are in to a file'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents LocalScripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents LocalScripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality in an attempt to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'setfpscap / fpscap / maxfps', DESC = 'Sets FPS cap'}
CMDs[#CMDs + 1] = {NAME = 'record / rec', DESC = 'Starts Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disables 3D Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enables 3D Rendering'}
CMDs[#CMDs + 1] = {NAME = '2022materials / use2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'un2022materials / unuse2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'togglenoclip', DESC = 'Toggles noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'togglefly', DESC = 'Toggles fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float / platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'togglefloat', DESC = 'Toggles float'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a Discord webhook for chatlogs to go to (provide no URL to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'vsay [text]', DESC = 'Say anything uncensored (CLIENT)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam / nospam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam / nopmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with voice chat'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'view / spectate [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unview / unspectate', DESC = 'Stops viewing player/part'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fcam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Sets maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Sets minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Unfreezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'unglobalshadows / ungshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players UserId'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current PlaceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current GameId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players AppearanceId'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players AppearanceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to climb into the air by repeatedly pressing jump'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infinitejump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Infinite jump that continuously flies upward just by holding the jump button'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools LocalScripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'defemote [emote]', DESC = 'Plays default emote'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your AnimationId or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesnt let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'clickfor', DESC = 'Click a player to run (click type) (player)'}
CMDs[#CMDs + 1] = {NAME = 'unclickfor', DESC = 'Disables clickfor'}
CMDs[#CMDs + 1] = {NAME = 'clicktype [type]', DESC = 'Sets click type'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
]=]

local env = { CMDs = {} }
local chunk = loadstring(rawCMDString)
if chunk then
    setfenv(chunk, env)
    chunk()
end

return env.CMDs
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
    refreshBtn.Text = "r"
    refreshBtn.TextColor3 = Theme.Colors.TextDim
    refreshBtn.TextSize = 16
    refreshBtn.Parent = btnArea

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(30, 34)
    closeBtn.Position = UDim2.fromOffset(30, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Theme.FontBold
    closeBtn.Text = "×"
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

__register("UI.PluginUI", function()
    local require = __require
    local script = __makeScriptProxy("UI.PluginUI")
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
end)

-- === ENTRY ===
do
    local require = __require
    local script = __makeScriptProxy("")
-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge      = require(Core.IYBridge)
local Registry      = require(Core.Registry)
local Saved         = require(Core.Saved)
local PluginManager = require(Core.PluginManager)
local Builder       = require(UIMod.Builder)
local createRow     = require(UIMod.CommandRow)
local TabBar        = require(UIMod.TabBar)
local PluginUI      = require(UIMod.PluginUI)
local Theme         = require(UIMod.Theme)

IYBridge.waitUntilReady()
Saved.load()

-- Inisialisasi awal Registry (membaca commands.lua)
Registry.rebuild()

local ui = Builder.create()

local currentTab = "All"
local currentRows = {}
local buildToken = nil
local applySearch, buildList, runCommand, onSavedChanged

runCommand = function(cmdStr)
    -- Ekstrak nama command untuk cek apakah ini command plugin
    local cmdName = cmdStr:match("^(%S+)")
    local entry = Registry.get(cmdName)

    if entry and entry.func then
        -- Eksekusi Plugin (lokal)
        local args = {}
        for arg in cmdStr:gmatch("%S+") do table.insert(args, arg) end
        table.remove(args, 1) -- hapus nama command
        local ok, err = pcall(entry.func, args, game.Players.LocalPlayer)
        if not ok then warn("[IY+] Plugin Error ("..cmdName.."):", err) end
    else
        -- Eksekusi Command IY Asli via Bridge
        local ok, err = pcall(function()
            IYBridge.execCmd(cmdStr, game.Players.LocalPlayer)
        end)
        if not ok then warn("[IY+] Gagal run IY:", cmdStr, err) end
    end
end

onSavedChanged = function(cmdName)
    if currentTab == "Saved" then buildList() end
end

applySearch = function(query)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, item in ipairs(currentRows) do
        if query == "" then item.row.Visible = true
        else item.row.Visible = item.searchStr:find(query, 1, true) ~= nil end
    end
end

buildList = function()
    if buildToken then buildToken = nil end
    local thisBuild = {}
    buildToken = thisBuild
    ui.List:ClearAllChildren()
    currentRows = {}

    if currentTab == "Plugins" then
        PluginUI.render(ui.List, function()
            Registry.rebuild()
            buildList()
        end)
        return
    end

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

    task.spawn(function()
        for i, entry in ipairs(entries) do
            if buildToken ~= thisBuild then break end
            local row = createRow(ui.List, entry, runCommand, onSavedChanged)
            local parts = { entry.name }
            if entry.fullName then table.insert(parts, entry.fullName) end
            if entry.desc then table.insert(parts, entry.desc) end
            if entry.aliases then
                for _, a in ipairs(entry.aliases) do table.insert(parts, a) end
            end
            table.insert(currentRows, { row = row, searchStr = table.concat(parts, " "):lower() })
            if i % 20 == 0 then task.wait() end
        end
        if buildToken == thisBuild then applySearch(ui.Search.Text) end
    end)
end

local function setupTabs()
    -- Urutan: All, Saved, Plugins, lalu kategori IY
    local tabs = { "All", "Saved", "Plugins" }
    for _, cat in ipairs(Registry.categories()) do
        if cat ~= "Plugin" then table.insert(tabs, cat) end
    end
    
    ui.TabBarSlot:ClearAllChildren()
    TabBar.create(ui.TabBarSlot, tabs, function(selected)
        currentTab = selected
        buildList()
    end, currentTab)
end

setupTabs()

local searchToken = 0
ui.Search:GetPropertyChangedSignal("Text"):Connect(function()
    searchToken = searchToken + 1
    local myToken = searchToken
    task.delay(0.15, function()
        if myToken == searchToken then applySearch(ui.Search.Text) end
    end)
end)

ui.CloseBtn.MouseButton1Click:Connect(function() ui.Gui:Destroy() end)

ui.RefreshBtn.MouseButton1Click:Connect(function()
    ui.RefreshBtn.TextColor3 = Theme.Colors.Accent
    task.spawn(function()
        Registry.rebuild()
        setupTabs()
        buildList()
        ui.RefreshBtn.TextColor3 = Theme.Colors.TextDim
    end)
end)

buildList()
end