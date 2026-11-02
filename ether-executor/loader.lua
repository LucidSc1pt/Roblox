-- ╔═══════════════════════════╗
-- ║     ETHER EXECUTOR LOADER      ║
-- ║   by LucidSc1pt and DeepSeek   ║
-- ╚═══════════════════════════╝

-- =======================
-- ==== CONFIGURATION ====
-- =======================
local LOAD_MODE = "CACHE" 

local BASE_URL = "https://raw.githubusercontent.com/LucidSc1pt/Roblox/refs/heads/main/ether-executor/src/"
local CACHE_DIR = "EtherExecutor_Modules"

if isfolder and makefolder and not isfolder(CACHE_DIR) then
    pcall(makefolder, CACHE_DIR)
else
    LOAD_MODE = "HTTP"
end

local function LoadModule(modulePath)
    local safeName = modulePath:gsub("/", "_") .. ".lua"
    local cachePath = CACHE_DIR .. "/" .. safeName
    
    local cacheContent = nil
    local remoteContent = nil

    if isfile and readfile and isfile(cachePath) then
        local okRead, content = pcall(readfile, cachePath)
        if okRead and content and content ~= "" then
            cacheContent = content
        end
    else
        LOAD_MODE = "HTTP"
    end

    if LOAD_MODE == "HTTP" then
        local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
        if okDownload and response and response ~= "" then
            remoteContent = response
            if writefile then pcall(writefile, cachePath, remoteContent) end -- Update cache
        elseif cacheContent then
            warn("[Ether] Gagal download " .. modulePath .. ". Menggunakan Cache lokal.")
            remoteContent = cacheContent
        else
            warn("[Ether] FATAL: Gagal download " .. modulePath .. " dan tidak ada cache.")
            return nil
        end
        
    else
        local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
        
        if okDownload and response and response ~= "" then
            remoteContent = response
            
            if cacheContent ~= remoteContent then
                if writefile then 
                    pcall(writefile, cachePath, remoteContent) 
                    print("[Ether] Update terdeteksi: " .. modulePath .. " (Cache diperbarui)")
                end
            end
        else
            if cacheContent then
                remoteContent = cacheContent
            else
                warn("[Ether] FATAL: Tidak ada internet dan tidak ada cache untuk " .. modulePath)
                return nil
            end
        end
    end

    -- 3. Compile Script
    local func, err = loadstring(remoteContent, "=" .. modulePath)
    if not func then
        warn("[Ether] SYNTAX ERROR di module [" .. modulePath .. "]:\n" .. tostring(err))
        return nil
    end

    -- 4. Jalankan
    local success, result = pcall(func)
    if not success then
        warn("[Ether] RUNTIME ERROR di module [" .. modulePath .. "]:\n" .. tostring(result))
        return nil
    end

    return result
end

print("[Ether] Memulai loading... (Mode: " .. LOAD_MODE .. ")")

-- Core
LoadModule("core/init")
LoadModule("core/services")
LoadModule("core/ui_helper")
LoadModule("core/utils")
LoadModule("core/highlighter")
LoadModule("core/ui_components")
LoadModule("core/tab_reuse")
LoadModule("core/window")

-- Features
LoadModule("features/toggle")
LoadModule("features/clock")

-- Tabs
LoadModule("tabs/editor")
LoadModule("tabs/info")
LoadModule("tabs/search")
LoadModule("tabs/saved")
LoadModule("tabs/settings")

-- Finalize
LoadModule("core/finalize")

print("[Ether] Semua modules berhasil di-load!")
