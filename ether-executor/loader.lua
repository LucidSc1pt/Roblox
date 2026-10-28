-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ETHER EXECUTOR LOADER (v3 Network-First + Cache Fallback)   ║
-- ╚══════════════════════════════════════════════════════════════╝

-- URL GitHub kamu
local BASE_URL = "https://raw.githubusercontent.com/LucidSc1pt/Roblox/refs/heads/main/ether-executor/src/"
local CACHE_DIR = "EtherExecutor_Modules"

if isfolder and makefolder and not isfolder(CACHE_DIR) then
    pcall(makefolder, CACHE_DIR)
end

local function LoadModule(modulePath)
    local safeName = modulePath:gsub("/", "_") .. ".lua"
    local cachePath = CACHE_DIR .. "/" .. safeName
    local scriptContent = nil

    -- 1. SELALU COBA DOWNLOAD DARI GITHUB (Network-First)
    local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
    
    if okDownload and response and response ~= "" then
        scriptContent = response
        -- Simpan ke cache lokal sebagai backup (kalau internet mati)
        if writefile then pcall(writefile, cachePath, scriptContent) end
    else
        -- 2. KALAU GAGAL DOWNLOAD, BARU BACA DARI CACHE
        warn("[Ether Loader] Gagal download " .. modulePath .. " (Cek internet/GitHub). Menggunakan cache lokal...")
        if isfile and readfile and isfile(cachePath) then
            local okRead, content = pcall(readfile, cachePath)
            if okRead and content and content ~= "" then
                scriptContent = content
            end
        end
    end

    -- 3. JIKA TETAP KOSONG (Gagal download & Cache gak ada)
    if not scriptContent then
        warn("[Ether Loader] FATAL: Module [" .. modulePath .. "] tidak ada di cache dan gagal di-download.")
        return nil
    end

    -- 4. Compile Script
    local func, err = loadstring(scriptContent, "=" .. modulePath)
    if not func then
        warn("[Ether Loader] SYNTAX ERROR di module [" .. modulePath .. "]:\n" .. tostring(err))
        return nil
    end

    -- 5. Jalankan Script dengan pcall (Anti Silent Crash)
    local success, result = pcall(func)
    if not success then
        warn("[Ether Loader] RUNTIME ERROR di module [" .. modulePath .. "]:\n" .. tostring(result))
        return nil
    end

    return result
end

print("[Ether] Memulai loading modular...")

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
