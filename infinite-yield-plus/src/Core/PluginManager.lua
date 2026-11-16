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