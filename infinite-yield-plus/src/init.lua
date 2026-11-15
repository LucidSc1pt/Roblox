-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge  = require(Core.IYBridge)
local Registry  = require(Core.Registry)
local Saved     = require(Core.Saved)
local Builder   = require(UIMod.Builder)
local createRow = require(UIMod.CommandRow)
local TabBar    = require(UIMod.TabBar)

IYBridge.waitUntilReady()
Saved.load()

local ui = Builder.create()
local autoCmds = IYBridge.extractCommands(15)
if #autoCmds > 0 then
    Registry.setAutoCommands(autoCmds)
end

local currentTab = "All"
local currentRows = {}
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

applySearch = function(query)
    query = (query or ""):lower()
    if query == "" then
        for _, row in pairs(currentRows) do row.Visible = true end
        return
    end
    for name, row in pairs(currentRows) do
        local entry = Registry.get(name)
        local hit = false
        if entry then
            -- Pencarian mencakup: Name, FullName (Title beserta aliases), Desc, dan Aliases
            hit = entry.name:lower():find(query, 1, true) ~= nil
                or (entry.fullName and entry.fullName:lower():find(query, 1, true) ~= nil)
                or (entry.desc and entry.desc:lower():find(query, 1, true) ~= nil)
            if not hit and entry.aliases then
                for _, a in ipairs(entry.aliases) do
                    if a:lower():find(query, 1, true) then hit = true break end
                end
            end
        else
            hit = name:lower():find(query, 1, true) ~= nil
        end
        row.Visible = hit
    end
end

buildList = function()
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
                -- Duplikasi entry agar tidak menimpa state aslinya
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

    for _, entry in ipairs(entries) do
        local row = createRow(ui.List, entry, runCommand, onSavedChanged)
        currentRows[entry.name] = row
    end
    applySearch(ui.Search.Text)
end

local tabs = { "All", "Saved" }
for _, cat in ipairs(Registry.categories()) do
    tabs[#tabs+1] = cat
end

TabBar.create(ui.TabBarSlot, tabs, function(selected)
    currentTab = selected
    buildList()
end, "All")

-- Debounce Pencarian
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

buildList()