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