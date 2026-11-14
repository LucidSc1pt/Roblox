-- build.lua
-- Usage: lua build.lua
-- Output: dist/InfiniteYieldPlus.lua (single-file untuk loadstring)

local SRC_DIR  = "src"
local OUT_FILE = "dist/InfiniteYieldPlus.lua"

-- Tambahkan modul baru di sini kalau kamu bikin file baru
local MODULES = {
    "Core.IYBridge",
    "Core.Registry",
    "Core.Saved",
    "Data.commands",
    "UI.Theme",
    "UI.Layout",
    "UI.Builder",
    "UI.CommandRow",
    "UI.TabBar",
}

local HEADER = [==[
-- ============================================================
-- InfiniteYieldPlus — generated file, do not edit directly
-- Source: https://github.com/<user>/InfiniteYieldPlus
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

]==]

local function readFile(path)
    local f = io.open(path, "r")
    if not f then error("Cannot read: " .. path) end
    local c = f:read("*a")
    f:close()
    return c
end

local function build()
    local out = { HEADER }

    for _, mod in ipairs(MODULES) do
        local path = SRC_DIR .. "/" .. mod:gsub("%.", "/") .. ".lua"
        local content = readFile(path)
        out[#out+1] = ('__register("%s", function()'):format(mod)
        out[#out+1] = '    local require = __require'
        out[#out+1] = ('    local script = __makeScriptProxy("%s")'):format(mod)
        out[#out+1] = content
        out[#out+1] = "end)"
        out[#out+1] = ""
    end

    local entry = readFile(SRC_DIR .. "/init.lua")
    out[#out+1] = "-- === ENTRY ==="
    out[#out+1] = "do"
    out[#out+1] = '    local require = __require'
    out[#out+1] = '    local script = __makeScriptProxy("")'
    out[#out+1] = entry
    out[#out+1] = "end"

    return table.concat(out, "\n")
end

-- Buat folder dist kalau belum ada
local sep = package.config:sub(1, 1)
os.execute((sep == "\\") and "if not exist dist mkdir dist" or "mkdir -p dist")

local result = build()
local f = io.open(OUT_FILE, "w")
f:write(result)
f:close()
print(("Built %s (%d bytes)"):format(OUT_FILE, #result))