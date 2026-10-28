-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ETHER EXECUTOR LOADER (v2 Modular + Cache + Safe pcall)     ║
-- ╚══════════════════════════════════════════════════════════════╝

-- URL GitHub kamu (sudah saya masukkan)
local BASE_URL = "https://raw.githubusercontent.com/LucidSc1pt/Roblox/refs/heads/main/ether-executor/src/"
local CACHE_DIR = "EtherExecutor_Modules"

if isfolder and makefolder and not isfolder(CACHE_DIR) then
    pcall(makefolder, CACHE_DIR)
end

local function LoadModule(modulePath)
    local safeName = modulePath:gsub("/", "_") .. ".lua"
    local cachePath = CACHE_DIR .. "/" .. safeName
    local scriptContent = nil

    -- 1. Baca dari Cache Lokal (biar kalau internet down, tetep jalan)
    if isfile and readfile and isfile(cachePath) then
        local okRead, content = pcall(readfile, cachePath)
        if okRead and content and content ~= "" then
            scriptContent = content
        end
    end

    -- 2. Download dari GitHub (kalau cache kosong)
    if not scriptContent then
        local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
        if okDownload and response and response ~= "" then
            scriptContent = response
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

    -- 4. Jalankan Script dengan pcall (Anti Silent Crash)
    local success, result = pcall(func)
    if not success then
        warn("[Ether Loader] RUNTIME ERROR di module [" .. modulePath .. "]:\n" .. tostring(result))
        return nil
    end

    return result
end

print("[Ether] Memulai loading modular...")

-- Urutan Load Core (Wajib berurutan)
LoadModule("core/init")
LoadModule("core/services")
LoadModule("core/ui_helper")
LoadModule("core/utils")
LoadModule("core/highlighter")
LoadModule("core/ui_components")
LoadModule("core/tab_reuse")

print("[Ether] Core modules berhasil di-load!")

-- (Nanti kita tambah module lain di sini)
-- LoadModule("core/highlighter")
-- LoadModule("tabs/editor")

print("[Ether] Core modules berhasil di-load!")
