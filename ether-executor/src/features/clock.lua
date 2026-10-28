-- features/clock.lua
local Ether = getgenv().Ether
if not Ether then return end

local HeaderFrame = Ether.HeaderFrame
local DAY_NAMES = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"}
local MONTH_NAMES = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}

local HeaderClockFrame = Ether.Create("Frame", {
	Name = "HeaderClock", Parent = HeaderFrame, AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -108, 0.5, 0), Size = UDim2.new(0, 130, 0, 36),
	BackgroundTransparency = 1, ZIndex = 5,
})
Ether.Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center, Parent = HeaderClockFrame,
})
local HeaderClockTimeLbl = Ether.Create("TextLabel", {
	Name = "TimeLbl", Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
	Text = "00:00:00", Font = Enum.Font.GothamBold, TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255), TextXAlignment = Enum.TextXAlignment.Right,
	Parent = HeaderClockFrame,
})
local HeaderClockDateLbl = Ether.Create("TextLabel", {
	Name = "DateLbl", Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
	Text = "---", Font = Enum.Font.Gotham, TextSize = 9,
	TextColor3 = Color3.fromRGB(190, 200, 220), TextXAlignment = Enum.TextXAlignment.Right,
	Parent = HeaderClockFrame,
})

local function updateHeaderClock()
	local ok, now = pcall(os.date, "*t")
	if not ok or not now then return end
	HeaderClockTimeLbl.Text = string.format("%02d:%02d:%02d", now.hour or 0, now.min or 0, now.sec or 0)
	HeaderClockDateLbl.Text = string.format("%s, %02d %s %d",
		DAY_NAMES[now.wday] or "?",
		now.day or 0,
		MONTH_NAMES[now.month] or "?",
		now.year or 0)
end
updateHeaderClock()
task.spawn(function()
	while HeaderClockFrame and HeaderClockFrame.Parent do
		task.wait(1)
		updateHeaderClock()
	end
end)

return Ether
