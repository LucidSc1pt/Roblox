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
                
                -- Cek Aliases (termasuk yang dipisah garis miring)
                if not hit and cmd.aliases then
                    for _, a in ipairs(cmd.aliases) do
                        if a:lower():find(query, 1, true) then hit = true break end
                    end
                end
                
                -- Cek FullName (Title asli dari IY)
                if not hit and cmd.fullName then
                    hit = cmd.fullName:lower():find(query, 1, true) ~= nil
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