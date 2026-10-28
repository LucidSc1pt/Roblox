-- core/init.lua
if getgenv().Ether and getgenv().Ether.Destroy then
    pcall(getgenv().Ether.Destroy)
end

local Ether = {
    Flags = {},
    ExecutorFlags = {},
    ThemeObjects = {},
    Connections = {},
    Themes = {
        Default = {
            WindowBackground = Color3.fromRGB(47, 54, 64),
            WindowBorder = Color3.fromRGB(47, 54, 64),
            ElementDivider = Color3.fromRGB(107, 114, 124),
            ElementDividerText = Color3.fromRGB(107, 114, 124),
            TabDivider = Color3.fromRGB(107, 114, 124),
            TabDividerText = Color3.fromRGB(107, 114, 124),
            TabBtnBackground = Color3.fromRGB(40, 148, 215),
            TabBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),
            TabScriptBtnBackground = Color3.fromRGB(40, 148, 215),
            TabScriptBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),
            Header = Color3.fromRGB(0, 168, 255),
            HeaderBorder = Color3.fromRGB(0, 168, 255),
            HeaderText = Color3.fromRGB(47, 54, 64),
            SubHeaderText = Color3.fromRGB(67, 74, 84),
            NormalText = Color3.fromRGB(245, 246, 250),
            NormalBackground = Color3.fromRGB(53, 59, 72),
            DropdownOptionBackground = Color3.fromRGB(53, 59, 72),
            DropdownOptionTextHolder = Color3.fromRGB(180, 180, 180),
            DropdownOptionSelect = Color3.fromRGB(73, 79, 92),
            BtnBorder = Color3.fromRGB(113, 128, 147),
            ToggleFiller = Color3.fromRGB(68, 189, 50),
            SliderFiller = Color3.fromRGB(76, 209, 55)
        }
    },
    GlobalAutoSave = true,
    MainFolder = "EtherExecutor",
    MainConfigFile = "ExeConfigs.json",
    MainFeatureFile = "Configs.json",
    IconCacheFolder = "IconCache",
    ImageCacheFolder = "ImageCache",
    SavedScriptFolder = "Saved Script",
    SavedTabEditorFolder = "Saved Tab Editor",
    SavedScriptHubFolder = "Saved Hub Script",
    SelectedTheme = "Default",
    
    CustomIcon = "lucide:eye",
    ToggleButtonConfig = {
        StrokeColor = Color3.fromRGB(0, 168, 255),
        StrokeColor2 = Color3.fromRGB(255, 105, 180),
        Gradient = false,
        GradientRotation = 45,
        Position = UDim2.new(0, 20, 0, 90),
        Size = 44,
        Visible = true,
        AutoRotate = false,
        AutoRotateSpeed = 45,
        RGBMode = false,
        RGBSpeed = 0.3,
        CornerRadius = 50,
    },
    MainUIHidden = false,
}

getgenv().Ether = Ether
return Ether
