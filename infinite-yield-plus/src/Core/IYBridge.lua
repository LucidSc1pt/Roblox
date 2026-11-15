-- Core/IYBridge.lua
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

-- Cari Holder IY lewat Title label (paling stabil)
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

-- Cari TextBox Cmdbar yang sudah di-rename jadi "Input"
local function findCmdbar()
    if cachedCmdbar and cachedCmdbar.Parent then return cachedCmdbar end
    local holder = findHolder()
    if not holder then return nil end

    -- Prioritas: TextBox "Input" di bawah Frame "Cmdbar"
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox")
            and obj.Name == "Input"
            and obj.Parent
            and obj.Parent.Name == "Cmdbar" then
            cachedCmdbar = obj
            return obj
        end
    end
    -- Fallback: TextBox apa pun di Holder (cuma ada 1 = Cmdbar)
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("TextBox") then
            cachedCmdbar = obj
            return obj
        end
    end
    return nil
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

    local env = getEnv()
    local status = string.format(
        "\n  IY_LOADED     : %s" ..
        "\n  execCmd       : %s" ..
        "\n  Title(holder) : %s" ..
        "\n  Cmdbar        : %s" ..
        "\n  gethui        : %s" ..
        "\n  firefocuslost : %s",
        tostring(env.IY_LOADED),
        tostring(type(env.execCmd) == "function"),
        tostring(findHolder() ~= nil),
        tostring(findCmdbar() ~= nil),
        tostring(gethui ~= nil),
        tostring(type(firefocuslost) == "function")
    )
    error("[IY+] Infinite Yield tidak siap dalam " .. (timeout or 20) .. "s. Status:" .. status)
end

function IYBridge.execCmd(cmdStr, speaker)
    -- Jalur 1: kalau executor kebetulan expose (jarang tapi gratis dicoba)
    local env = getEnv()
    if type(env.execCmd) == "function" then
        local ok, err = pcall(env.execCmd, cmdStr, speaker or Players.LocalPlayer)
        if ok then return end
        warn("[IY+] execCmd dari env gagal, fallback Cmdbar:", err)
    end

    local cmdbar = findCmdbar()
    if not cmdbar then
        error("[IY+] Cmdbar IY tidak ditemukan. IY mungkin belum selesai loading.")
    end

    -- Jalur 2: firefocuslost (kalau executor support)
    if type(firefocuslost) == "function" then
        local ok = pcall(function()
            cmdbar.Text = cmdStr
            firefocuslost(cmdbar, true)
        end)
        if ok then return end
    end

    -- Jalur 3: CaptureFocus -> ReleaseFocus(true)
    local ok, err = pcall(function()
        cmdbar:CaptureFocus()
        task.wait(0.1)
        if not cmdbar:IsFocused() then
            cmdbar:CaptureFocus()
            task.wait(0.1)
        end
        cmdbar.Text = cmdStr
        task.wait()
        cmdbar:ReleaseFocus(true)
    end)
    if not ok then
        error("[IY+] Gagal trigger Cmdbar (" .. tostring(err) .. "). "
            .. "Executor mungkin tidak support CaptureFocus/ReleaseFocus.")
    end
end

function IYBridge.diagnose()
    local env = getEnv()
    return {
        IY_LOADED     = env.IY_LOADED,
        execCmd       = type(env.execCmd) == "function",
        title         = findHolder() ~= nil,
        cmdbar        = findCmdbar() ~= nil,
        gethui        = gethui ~= nil,
        firefocuslost = type(firefocuslost) == "function",
    }
end

return IYBridge