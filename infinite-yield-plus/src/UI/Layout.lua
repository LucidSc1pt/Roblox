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
        return UDim2.new(0.85, 0, 0.62, 0)      -- 85% × 62%, dari sebelumnya 100%×80%
    else
        local w = math.min(400, viewport.X * 0.4)
        local h = math.min(360, viewport.Y * 0.65)
        return UDim2.fromOffset(w, h)            -- 400×360, dari sebelumnya 560×480
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