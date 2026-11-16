-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge  = require(Core.IYBridge)
local Registry  = require(Core.Registry)
local Saved     = require(Core.Saved)
local Builder   = require(UIMod.Builder)
local createRow = require(UIMod.CommandRow)
local TabBar    = require(UIMod.TabBar)
local Theme     = require(UIMod.Theme)

IYBridge.waitUntilReady()
Saved.load()

local ui = Builder.create()
local autoCmds = IYBridge.extractCommands(15)
if #autoCmds > 0 then
    Registry.setAutoCommands(autoCmds)
end

local currentTab = "All"
local currentRows = {}     -- Array of { row = Instance, searchStr = "string" }
local buildToken = nil     -- Mencegah bentrok saat ganti tab cepat
local applySearch, buildList, runCommand, onSavedChanged

runCommand = function(cmdName)
    local ok, err = pcall(function()
        IYBridge.execCmd(cmdName, game.Players.LocalPlayer)
    end)
    if not ok then
        warn("[IY+] Gagal run:", cmdName, err)
    end
end

onSavedChanged = function(cmdName)
    if currentTab == "Saved" then
        buildList()
    end
end

-- Optimasi Search: Hanya loop string (tidak menyentuh Instance)
applySearch = function(query)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, item in ipairs(currentRows) do
        if query == "" then
            item.row.Visible = true
        else
            item.row.Visible = item.searchStr:find(query, 1, true) ~= nil
        end
    end
end

-- Optimasi Render: Chunking (memecah render agar tidak freeze)
buildList = function()
    if buildToken then buildToken = nil end
    local thisBuild = {}
    buildToken = thisBuild

    ui.List:ClearAllChildren()
    currentRows = {}

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = ui.List

    local entries = {}
    if currentTab == "Saved" then
        for _, savedItem in ipairs(Saved.list()) do
            local baseEntry = Registry.get(savedItem.name)
            if baseEntry then
                local copy = {}
                for k, v in pairs(baseEntry) do copy[k] = v end
                copy._savedArgs = savedItem.argValues
                table.insert(entries, copy)
            end
        end
    elseif currentTab == "All" then
        entries = Registry.all()
    else
        entries = Registry.filter("", currentTab)
    end

    -- Render menggunakan task.spawn dengan jeda
    task.spawn(function()
        for i, entry in ipairs(entries) do
            if buildToken ~= thisBuild then break end -- Batalkan jika user ganti tab saat loading

            local row = createRow(ui.List, entry, runCommand, onSavedChanged)
            
            -- Siapkan string pencarian (Name + FullName + Desc + Aliases)
            local parts = { entry.name }
            if entry.fullName then table.insert(parts, entry.fullName) end
            if entry.desc then table.insert(parts, entry.desc) end
            if entry.aliases then
                for _, a in ipairs(entry.aliases) do table.insert(parts, a) end
            end
            
            table.insert(currentRows, {
                row = row,
                searchStr = table.concat(parts, " "):lower()
            })

            -- Beri napas 1 frame setiap 20 command
            if i % 20 == 0 then
                task.wait()
            end
        end
        
        -- Terapkan search terakhir setelah selesai render
        if buildToken == thisBuild then
            applySearch(ui.Search.Text)
        end
    end)
end

-- Fungsi membuat TabBar
local function setupTabs()
    local tabs = { "All", "Saved" }
    for _, cat in ipairs(Registry.categories()) do
        tabs[#tabs+1] = cat
    end
    
    ui.TabBarSlot:ClearAllChildren()
    TabBar.create(ui.TabBarSlot, tabs, function(selected)
        currentTab = selected
        buildList()
    end, currentTab)
end

setupTabs()

-- Debounce Pencarian (Hanya jalan setengah detik setelah berhenti ngetik)
local searchToken = 0
ui.Search:GetPropertyChangedSignal("Text"):Connect(function()
    searchToken = searchToken + 1
    local myToken = searchToken
    task.delay(0.15, function()
        if myToken == searchToken then
            applySearch(ui.Search.Text)
        end
    end)
end)

-- Tombol Close (X)
ui.CloseBtn.MouseButton1Click:Connect(function()
    ui.Gui:Destroy()
end)

-- Tombol Refresh (⟳)
ui.RefreshBtn.MouseButton1Click:Connect(function()
    ui.RefreshBtn.TextColor3 = Theme.Colors.Accent -- Efek loading
    task.spawn(function()
        -- Ekstrak ulang dari IY (Berguna jika baru nge-load plugin baru)
        local newCmds = IYBridge.extractCommands(5)
        if #newCmds > 0 then
            Registry.setAutoCommands(newCmds)
        end
        
        -- Reset tab ke All jika kategori tab lama hilang
        local valid = false
        for _, cat in ipairs(Registry.categories()) do
            if cat == currentTab then valid = true break end
        end
        if currentTab ~= "All" and currentTab ~= "Saved" and not valid then
            currentTab = "All"
        end

        setupTabs()
        buildList()
        ui.RefreshBtn.TextColor3 = Theme.Colors.TextDim -- Selesai loading
    end)
end)

buildList()