-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ETHER EXECUTOR LOADER (v2 Modular + Cache + Safe pcall)     ║
-- ╚══════════════════════════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/LucidSc1pt/Roblox/main/ether-executor/"
local CACHE_DIR = "EtherExecutor_Modules"

-- Buat folder cache
if isfolder and makefolder and not isfolder(CACHE_DIR) then
    pcall(makefolder, CACHE_DIR)
end

local function LoadModule(modulePath)
    local safeName = modulePath:gsub("/", "_") .. ".lua"
    local cachePath = CACHE_DIR .. "/" .. safeName
    local scriptContent = nil

    -- 1. Coba baca dari Cache Lokal
    if isfile and readfile and isfile(cachePath) then
        local okRead, content = pcall(readfile, cachePath)
        if okRead and content and content ~= "" then
            scriptContent = content
        end
    end

    -- 2. Kalau Cache kosong, Download dari GitHub
    if not scriptContent then
        local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
        if okDownload and response and response ~= "" then
            scriptContent = response
            -- Simpan ke cache untuk run berikutnya
            if writefile then pcall(writefile, cachePath, scriptContent) end
        else
            warn("[Ether Loader] GAGAL DOWNLOAD module: " .. modulePath)
            return nil
        end
    end

    -- 3. Compile Script
    local func, err = loadstring(scriptContent, "=" .. modulePath)
    if not func then
        warn("[Ether Loader] SYNTAX ERROR di module [" .. modulePath .. "]:\n" .. tostring(err))
        return nil
    end

    -- 4. Jalankan Script
    local success, result = pcall(func)
    if not success then
        warn("[Ether Loader] RUNTIME ERROR di module [" .. modulePath .. "]:\n" .. tostring(result))
        return nil
    end

    return result
end

-- Ambil file version.txt dari GitHub
local ok, latestVer = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/USERNAME/REPO/main/version.txt")
if ok and latestVer then
    -- Kalau ada update, hapus cache lama biar download versi baru
    if writefile and isfolder and delfile then
        -- Hapus semua file .lua di folder cache
        local files = listfiles(CACHE_DIR)
        for _, file in ipairs(files) do
            pcall(delfile, file)
        end
    end
end

-- ============================================================
-- URUTAN LOADING (Harus berurutan dari Core ke UI)
-- ============================================================

print("[Ether] Memulai loading modular...")

local Core = LoadModule("core/init")
if not Core then warn("[Ether] Gagal load Core, script dihentikan.") return end

LoadModule("core/services")
LoadModule("core/ui_helper")
LoadModule("core/highlighter")
LoadModule("core/image_cache")
LoadModule("core/hub_api")

LoadModule("tabs/editor")
LoadModule("tabs/search")
LoadModule("tabs/saved")
LoadModule("tabs/info")
LoadModule("tabs/settings")

LoadModule("features/clock")
LoadModule("features/toggle")

LoadModule("core/finalize")

print("[Ether] Semua module berhasil di-load!")
