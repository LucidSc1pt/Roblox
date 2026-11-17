-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge      = require(Core.IYBridge)
local Registry      = require(Core.Registry)
local Saved         = require(Core.Saved)
local PluginManager = require(Core.PluginManager)
local Builder       = require(UIMod.Builder)
local createRow     = require(UIMod.CommandRow)
local TabBar        = require(UIMod.TabBar)
local PluginUI      = require(UIMod.PluginUI)
local Theme         = require(UIMod.Theme)

IYBridge.waitUntilReady()
Saved.load()

-- Inisialisasi awal Registry (membaca commands.lua)
Registry.rebuild()

local ui = Builder.create()

local currentTab = "All"
local currentRows = {}
local buildToken = nil
local applySearch, buildList, runCommand, onSavedChanged

runCommand = function(cmdStr)
    -- Ekstrak nama command untuk cek apakah ini command plugin
    local cmdName = cmdStr:match("^(%S+)")
    local entry = Registry.get(cmdName)

    if entry and entry.func then
        -- Eksekusi Plugin (lokal)
        local args = {}
        for arg in cmdStr:gmatch("%S+") do table.insert(args, arg) end
        table.remove(args, 1) -- hapus nama command
        local ok, err = pcall(entry.func, args, game.Players.LocalPlayer)
        if not ok then warn("[IY+] Plugin Error ("..cmdName.."):", err) end
    else
        -- Eksekusi Command IY Asli via Bridge
        local ok, err = pcall(function()
            IYBridge.execCmd(cmdStr, game.Players.LocalPlayer)
        end)
        if not ok then warn("[IY+] Gagal run IY:", cmdStr, err) end
    end
end

onSavedChanged = function(cmdName)
    if currentTab == "Saved" then buildList() end
end

applySearch = function(query)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, item in ipairs(currentRows) do
        if query == "" then item.row.Visible = true
        else item.row.Visible = item.searchStr:find(query, 1, true) ~= nil end
    end
end

buildList = function()
    if buildToken then buildToken = nil end
    local thisBuild = {}
    buildToken = thisBuild
    ui.List:ClearAllChildren()
    currentRows = {}

    if currentTab == "Plugins" then
        PluginUI.render(ui.List, function()
            Registry.rebuild()
            buildList()
        end)
        return
    end

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

    task.spawn(function()
        for i, entry in ipairs(entries) do
            if buildToken ~= thisBuild then break end
            local row = createRow(ui.List, entry, runCommand, onSavedChanged)
            local parts = { entry.name }
            if entry.fullName then table.insert(parts, entry.fullName) end
            if entry.aliases then
                for _, a in ipairs(entry.aliases) do table.insert(parts, a) end
            end
            table.insert(currentRows, { row = row, searchStr = table.concat(parts, " "):lower() })
            if i % 20 == 0 then task.wait() end
        end
        if buildToken == thisBuild then applySearch(ui.Search.Text) end
    end)
end

local function setupTabs()
    -- Urutan: All, Saved, Plugins, lalu kategori IY
    local tabs = { "All", "Saved", "Plugins" }
    for _, cat in ipairs(Registry.categories()) do
        if cat ~= "Plugin" then table.insert(tabs, cat) end
    end
    
    ui.TabBarSlot:ClearAllChildren()
    TabBar.create(ui.TabBarSlot, tabs, function(selected)
        currentTab = selected
        buildList()
    end, currentTab)
end

setupTabs()

local searchToken = 0
ui.Search:GetPropertyChangedSignal("Text"):Connect(function()
    searchToken = searchToken + 1
    local myToken = searchToken
    task.delay(0.15, function()
        if myToken == searchToken then applySearch(ui.Search.Text) end
    end)
end)

ui.CloseBtn.MouseButton1Click:Connect(function() ui.Gui:Destroy() end)

ui.RefreshBtn.MouseButton1Click:Connect(function()
    ui.RefreshBtn.TextColor3 = Theme.Colors.Accent
    task.spawn(function()
        Registry.rebuild()
        setupTabs()
        buildList()
        ui.RefreshBtn.TextColor3 = Theme.Colors.TextDim
    end)
end)

buildList()