-- src/init.lua
local Core  = script.Core
local UIMod = script.UI

local IYBridge  = require(Core.IYBridge)
local Registry  = require(Core.Registry)
local Saved     = require(Core.Saved)
local Builder   = require(UIMod.Builder)
local createRow = require(UIMod.CommandRow)
local TabBar    = require(UIMod.TabBar)

-- 1. Tunggu IY siap
IYBridge.waitUntilReady()

-- 2. Load daftar favorit tersimpan
Saved.load()

-- 3. Bangun UI
local ui = Builder.create()

-- 4. State
local currentTab = "All"
local renderList, runCommand, saveCommand -- forward declaration

-- 5. Fungsi run
runCommand = function(cmdName)
    local ok, err = pcall(function()
        IYBridge.execCmd(cmdName, game.Players.LocalPlayer)
    end)
    if not ok then
        warn("[IY+] Gagal run:", cmdName, err)
    end
end

-- 6. Fungsi save (toggle)
saveCommand = function(cmdName)
    local nowSaved = Saved.toggle(cmdName)
    print("[IY+] " .. (nowSaved and "Disimpan: " or "Dihapus: ") .. cmdName)
    if currentTab == "Saved" and renderList then renderList() end
end

-- 7. Lookup entry by name (untuk render tab Saved)
local function findEntry(name)
    for _, c in ipairs(Registry.all()) do
        if c.name == name then return c end
    end
end

-- 8. Render command list
renderList = function()
    ui.List:ClearAllChildren()
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = ui.List

    if currentTab == "Saved" then
        for _, name in ipairs(Saved.list()) do
            local entry = findEntry(name)
            if entry then
                createRow(ui.List, entry.name, entry.desc, runCommand, saveCommand)
            end
        end
    else
        local cat = (currentTab == "All") and nil or currentTab
        for _, entry in ipairs(Registry.filter(ui.Search.Text, cat)) do
            createRow(ui.List, entry.name, entry.desc, runCommand, saveCommand)
        end
    end
end

-- 9. TabBar: All + Saved + semua kategori dari registry
local tabs = { "All", "Saved" }
for _, cat in ipairs(Registry.categories()) do
    tabs[#tabs+1] = cat
end

TabBar.create(ui.TabBarSlot, tabs, function(selected)
    currentTab = selected
    renderList()
end, "All")

-- 10. Search realtime
ui.Search:GetPropertyChangedSignal("Text"):Connect(renderList)

renderList()
print("[IY+] UI siap.")