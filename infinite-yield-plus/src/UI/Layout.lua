local UIS = game:GetService("UserInputService")
local Layout = {}

function Layout.isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

function Layout.getPanelSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    if Layout.isMobile() then
        local w = math.min(viewport.X * 0.7, 380)
        local h = math.min(viewport.Y * 0.62, 520)
        return UDim2.fromOffset(w, h)
    else
        local w = math.min(320, viewport.X * 0.32)
        local h = math.min(340, viewport.Y * 0.6)
        return UDim2.fromOffset(w, h)
    end
end

function Layout.getPanelPosition()
    if Layout.isMobile() then
        return UDim2.new(0.5, 0, 0.5, 0)
    else
        return UDim2.fromScale(0.5, 0.5)
    end
end

return Layout