-- UI/Theme.lua
local Theme = {
    Colors = {
        Background   = Color3.fromRGB(20, 20, 28),
        Surface      = Color3.fromRGB(30, 30, 42),
        SurfaceHover = Color3.fromRGB(42, 42, 58),
        Accent       = Color3.fromRGB(0, 217, 163),   -- cyan/teal khas IY
        AccentDark   = Color3.fromRGB(0, 150, 115),
        Text         = Color3.fromRGB(235, 235, 245),
        TextDim      = Color3.fromRGB(140, 140, 160),
        Danger       = Color3.fromRGB(235, 80, 80),
        Success      = Color3.fromRGB(80, 220, 130),
    },
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8),
    Padding = 8,
}
return Theme