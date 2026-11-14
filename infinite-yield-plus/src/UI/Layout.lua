-- UI/Layout.lua
local UIS = game:GetService("UserInputService")

local Layout = {}

function Layout.isMobile()
    -- Touch aktif tapi keyboard tidak → HP/tablet
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

function Layout.getPanelSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    if Layout.isMobile() then
        -- Mobile: hampir fullscreen, dengan margin kecil
        return UDim2.new(1, -24, 1, -80)
    else
        -- PC: window mengambang, ukuran tetap tapi dibatasi viewport
        local w = math.min(560, viewport.X * 0.5)
        local h = math.min(480, viewport.Y * 0.75)
        return UDim2.fromOffset(w, h)
    end
end

function Layout.getPanelPosition()
    if Layout.isMobile() then
        return UDim2.new(0.5, 0, 0.5, 0)  -- centered
    else
        return UDim2.fromScale(0.5, 0.5)
    end
end

return Layout