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