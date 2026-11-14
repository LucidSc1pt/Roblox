-- Core/IYBridge.lua
local IYBridge = {}

function IYBridge.waitUntilReady(timeout)
    local deadline = tick() + (timeout or 15)
    while tick() < deadline do
        if getgenv().execCmd then return true end
        task.wait(0.2)
    end
    error("[IY+] Infinite Yield tidak terdeteksi setelah timeout.")
end

function IYBridge.execCmd(cmdStr, speaker)
    local fn = getgenv().execCmd
    if not fn then
        error("[IY+] execCmd belum tersedia.")
    end
    return fn(cmdStr, speaker)
end

return IYBridge