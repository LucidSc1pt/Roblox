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