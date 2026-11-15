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