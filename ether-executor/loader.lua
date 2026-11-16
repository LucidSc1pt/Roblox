--[[

   ('-.   .-') _    ('-. .-.   ('-.  _  .-')   
 _(  OO) (  OO) )  ( OO )  / _(  OO)( \( -O )  
(,------./     '._ ,--. ,--.(,------.,------.  
 |  .---'|'--...__)|  | |  | |  .---'|   /`. ' 
 |  |    '--.  .--'|   .|  | |  |    |  /  | | 
(|  '--.    |  |   |       |(|  '--. |  |_.' | 
 |  .--'    |  |   |  .-.  | |  .--' |  .  '.' 
 |  `---.   |  |   |  | |  | |  `---.|  |\  \  
 `------'   `--'   `--' `--' `------'`--' '--' 

╔═══════════════════════════╗
║     ETHER EXECUTOR LOADER      ║
║   by LucidSc1pt and DeepSeek   ║
╚═══════════════════════════╝

]]

-- =======================
-- ==== CONFIGURATION ====
-- =======================
-- Pilihan LOAD_MODE: "HTTP" atau "CACHE"
local LOAD_MODE = "CACHE" 

-- Pilihan RUN_MODE (Hanya berlaku jika LOAD_MODE = "CACHE"):
-- "SYNC"  = Cek update ke GitHub. (Untuk Production)
-- "LOCAL" = Langsung pakai cache lokal tanpa nembak GitHub. (Untuk Ngetes Edit Lokal)
local RUN_MODE = "LOCAL" 

-- =======================
-- ====    LOADER    ====
-- =======================
local BASE_URL = "https://raw.githubusercontent.com/LucidSc1pt/Roblox/refs/heads/main/ether-executor/src/"
local CACHE_DIR = "EtherExecutor_Modules"

-- Pastikan folder utama cache ada
if isfolder and makefolder and not isfolder(CACHE_DIR) then
    pcall(makefolder, CACHE_DIR)
end

-- Fungsi bantuan untuk bikin folder (misal: EtherExecutor_Modules/core)
local function ensureDirectory(dirPath)
    if isfolder and makefolder and not isfolder(dirPath) then
        pcall(makefolder, dirPath)
    end
end

local function LoadModule(modulePath)
    -- Pisahkan "core/init" menjadi folder="core" dan file="init"
    local folderName = modulePath:match("^(.-)/") or ""
    local fileName = modulePath:match("/(.*)$") or modulePath
    
    local targetDir = CACHE_DIR
    local cachePath = ""
    
    -- Kalau module-nya ada foldernya (misal core/init)
    if folderName ~= "" then
        targetDir = CACHE_DIR .. "/" .. folderName
        ensureDirectory(targetDir) -- Bikin folder core, tabs, features
        cachePath = targetDir .. "/" .. fileName .. ".lua"
    else
		cachePath = CACHE_DIR .. "/" .. fileName .. ".lua"
    end
    
    local cacheContent = nil
    local remoteContent = nil

    -- 1. Baca Cache Lokal
    if isfile and readfile and isfile(cachePath) then
        local okRead, content = pcall(readfile, cachePath)
        if okRead and content and content ~= "" then
            cacheContent = content
        end
    end

    -- 2. Tentukan Strategi Loading
    if LOAD_MODE == "HTTP" then
        local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
        if okDownload and response and response ~= "" then
            remoteContent = response
            if writefile then pcall(writefile, cachePath, remoteContent) end 
        elseif cacheContent then
            warn("[Ether] Gagal download " .. modulePath .. ". Menggunakan Cache.")
            remoteContent = cacheContent
        else
            warn("[Ether] FATAL: Gagal download " .. modulePath .. " dan tidak ada cache.")
            return nil
        end
        
    elseif LOAD_MODE == "CACHE" then
        if RUN_MODE == "SYNC" then
            local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
            if okDownload and response and response ~= "" then
                remoteContent = response
                if cacheContent ~= remoteContent then
                    if writefile then 
                        pcall(writefile, cachePath, remoteContent) 
                        print("[Ether] Update terdeteksi: " .. modulePath)
                    end
            	else
            		if cacheContent then
                    	remoteContent = cacheContent
                	else
                    	warn("[Ether] FATAL: Tidak ada cache untuk " .. modulePath)
                    	return nil
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
        else
            -- LOCAL ONLY
            if cacheContent then
                remoteContent = cacheContent
                -- print("[Ether] Local test: " .. modulePath)
            else
                warn("[Ether] File lokal tidak ada: " .. modulePath .. ". Mendownload...")
                local okDownload, response = pcall(game.HttpGet, game, BASE_URL .. modulePath .. ".lua")
                if okDownload and response and response ~= "" then
                    remoteContent = response
                    if writefile then pcall(writefile, cachePath, remoteContent) end
                else
                    warn("[Ether] FATAL: Gagal download " .. modulePath .. " dan tidak ada cache.")
                    return nil
                end
            end
        end
    end

    -- 3. Compile
    local func, err = loadstring(remoteContent, "=" .. modulePath)
    if not func then
        warn("[Ether] SYNTAX ERROR di [" .. modulePath .. "]:\n" .. tostring(err))
        return nil
    end

    -- 4. Jalankan
    local success, result = pcall(func)
    if not success then
        warn("[Ether] RUNTIME ERROR di [" .. modulePath .. "]:\n" .. tostring(result))
        return nil
    end

    return result
end

print("[Ether] Loading... (Mode: " .. LOAD_MODE .. (LOAD_MODE == "CACHE" and " / " .. RUN_MODE or "") .. ")")

-- Core Loader
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