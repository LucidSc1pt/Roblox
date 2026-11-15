-- Core/IYBridge.lua
local Players = game:GetService("Players")

local IYBridge = {}

local cachedCmdbar = nil

-- Ambil getgenv, fallback ke _G kalau getgenv tidak ada
local function getEnv()
    local ok, env = pcall(function() return getgenv() end)
    if ok and type(env) == "table" then return env end
    return _G
end

-- Cari Cmdbar milik IY asli (bukan milik IYP)
local function findCmdbar()
    if cachedCmdbar and cachedCmdbar.Parent then
        return cachedCmdbar
    end

    local containers = {}

    -- 1. Prioritas gethui() — IY pakai ini kalau ada
    pcall(function()
        if gethui then
            local h = gethui()
            if h then table.insert(containers, h) end
        end
    end)

    -- 2. CoreGui
    pcall(function()
        table.insert(containers, game:GetService("CoreGui"))
    end)

    -- 3. PlayerGui (fallback)
    local pg = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(containers, pg) end

    for _, container in ipairs(containers) do
        if container then
            local ok, list = pcall(function() return container:GetDescendants() end)
            if ok then
                for _, obj in ipairs(list) do
                    if obj:IsA("TextBox") and obj.Name == "Cmdbar" then
                        -- Verifikasi: harus punya saudara Title berisi "Infinite Yield FE"
                        local holder = obj.Parent
                        if holder then
                            for _, sib in ipairs(holder:GetChildren()) do
                                if sib:IsA("TextLabel")
                                    and sib.Name == "Title"
                                    and sib.Text:find("Infinite Yield FE") then
                                    cachedCmdbar = obj
                                    return obj
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

function IYBridge.isReady()
    local env = getEnv()
    if env.execCmd then return true end
    if env.IY_LOADED and findCmdbar() then return true end
    return false
end

function IYBridge.waitUntilReady(timeout)
    local deadline = tick() + (timeout or 20)
    while tick() < deadline do
        if IYBridge.isReady() then return true end
        task.wait(0.2)
    end

    -- Diagnostic lengkap kalau gagal
    local env = getEnv()
    local status = string.format(
        "\n  IY_LOADED : %s\n  execCmd   : %s\n  Cmdbar    : %s\n  gethui    : %s",
        tostring(env.IY_LOADED),
        tostring(env.execCmd ~= nil),
        tostring(findCmdbar() ~= nil),
        tostring(gethui ~= nil)
    )
    error("[IY+] Infinite Yield tidak terdeteksi dalam " .. (timeout or 20) .. "s. Status:" .. status
        .. "\n  → Pastikan IY sudah jalan sebelum IYP, dan tunggu IY selesai loading.")
end

function IYBridge.execCmd(cmdStr, speaker)
    -- Jalur 1: execCmd dari getgenv (kalau ada)
    local env = getEnv()
    if type(env.execCmd) == "function" then
        local ok, err = pcall(env.execCmd, cmdStr, speaker or Players.LocalPlayer)
        if ok then return end
        warn("[IY+] execCmd via getgenv gagal, fallback ke Cmdbar:", err)
    end

    -- Jalur 2: picu Cmdbar FocusLost
    local cmdbar = findCmdbar()
    if not cmdbar then
        error("[IY+] Tidak bisa menemukan Cmdbar IY. IY mungkin belum selesai loading.")
    end

    cmdbar.Text = cmdStr
    pcall(function() cmdbar:CaptureFocus() end)
    task.wait() -- beri 1 frame

    if type(firefocuslost) == "function" then
        pcall(firefocuslost, cmdbar, true)
    else
        pcall(function() cmdbar:ReleaseFocus(true) end)
    end
end

function IYBridge.diagnose()
    local env = getEnv()
    return {
        IY_LOADED = env.IY_LOADED,
        execCmd = env.execCmd ~= nil,
        cmdbar = findCmdbar() ~= nil,
        gethui = gethui ~= nil,
        firefocuslost = firefocuslost ~= nil,
    }
end

return IYBridge