-- core/ui_helper.lua
local Ether = getgenv().Ether
if not Ether then return end

local player = Ether.Player
local CoreGui = Ether.CoreGui
local uis = Ether.UIS

function Ether.createUIName()
    local length = math.random(1, 80)
    local array = {}
    for i = 1, length do array[i] = string.char(math.random(1, 255)) end
    return table.concat(array)
end

function Ether.ensureFolder(path)
    if isfolder and makefolder and not isfolder(path) then
        pcall(makefolder, path)
    end
end

function Ether.table_find(tbl, val)
    if table.find then return table.find(tbl, val) end
    for i, v in ipairs(tbl) do if v == val then return i end end
    return nil
end

function Ether.protect_gui(obj)
    local s = false
    obj.Name = tostring(Ether.createUIName())
    if gethui then local ok, hui = pcall(gethui) if ok and hui then pcall(function() obj.Parent = hui end) s = true end end
    if not s and get_hidden_gui then local ok, hui = pcall(get_hidden_gui) if ok and hui then pcall(function() obj.Parent = hui end) s = true end end
    if not s and syn and syn.protect_gui then pcall(function() syn.protect_gui(obj) end) pcall(function() obj.Parent = CoreGui end) s = true end
    if not s then
        if player and player:FindFirstChild("PlayerGui") then
            pcall(function() obj.Parent = player:FindFirstChild("PlayerGui") end) s = true
        else
            pcall(function() obj.Parent = CoreGui end)
        end
    end
    pcall(function()
        obj.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        obj.DisplayOrder = 999999
        obj.ResetOnSpawn = false
    end)
    return s
end

function Ether.Create(Name, Properties)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do Object[i] = v end
    return Object
end

function Ether.SafeConnect(signal, callback)
    if typeof(signal) ~= "RBXScriptSignal" then return nil end
    if type(callback) ~= "function" then return nil end
    local ok, connection = pcall(signal.Connect, signal, callback)
    if ok and connection then
        table.insert(Ether.Connections, connection)
        return connection
    end
    return nil
end

function Ether.MakeDraggable(DragPoint, Main)
    Main = Main or DragPoint
    if typeof(DragPoint) ~= "Instance" or typeof(Main) ~= "Instance" then return end
    local Dragging = false
    local DragInput = nil
    local MousePos = nil
    local FramePos = nil

    Ether.SafeConnect(DragPoint.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging and activeInteraction ~= nil then return end
            Dragging = true
            MousePos = Input.Position
            FramePos = Main.Position
            DragInput = Input
            local changedConnection
            changedConnection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    DragInput = nil
                    if changedConnection then changedConnection:Disconnect() end
                end
            end)
        end
    end)

    Ether.SafeConnect(DragPoint.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging then DragInput = Input end
        end
    end)

    Ether.SafeConnect(uis.InputChanged, function(Input)
        if Dragging and Input == DragInput then
            local Delta = Input.Position - MousePos
            Main.Position = UDim2.new(
                FramePos.X.Scale,
                FramePos.X.Offset + Delta.X,
                FramePos.Y.Scale,
                FramePos.Y.Offset + Delta.Y
            )
        end
    end)

    Ether.SafeConnect(Main.AncestryChanged, function(_, parent)
        if not parent then Dragging = false end
    end)
end

-- Buat ScreenGui Utama langsung di sini
Ether.EtherExecutor = Ether.Create("ScreenGui", {
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ScreenInsets = Enum.ScreenInsets.None,
    ResetOnSpawn = false,
    ClipToDeviceSafeArea = false
})
Ether.protect_gui(Ether.EtherExecutor)

return Ether
