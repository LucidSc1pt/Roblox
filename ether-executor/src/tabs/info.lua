-- tabs/info.lua
local Ether = getgenv().Ether
if not Ether then return end

local InfoTab = Ether.exeTabs.InfoTab
local run = Ether.RunService
local players = Ether.Players
local Stats = Ether.Stats
local player = Ether.Player

local ServerInfo_Holder = Ether.Create("ScrollingFrame", { Name="ServerInfo_Holder", Parent=InfoTab.containerInstance, BackgroundColor3=Color3.fromRGB(25,25,25), Size=UDim2.new(1,0,0.6,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=1, AutomaticCanvasSize=Enum.AutomaticSize.XY, ScrollingDirection=Enum.ScrollingDirection.XY })
Ether.Create("UIListLayout", { FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,5), Parent=ServerInfo_Holder })

local function makeInfoLabel(name)
	local lbl = Ether.Create("TextLabel", { Name=name, Size=UDim2.new(1,-10,0,20), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.XY, Text=name..": ...", TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.SourceSans, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=ServerInfo_Holder })
	return lbl
end

local GameNameLabel = makeInfoLabel("Game") local PlaceIdLabel = makeInfoLabel("PlaceId")
local JobIdLabel = makeInfoLabel("JobId") local PlayerCountLbl = makeInfoLabel("Players")
local PingLabel = makeInfoLabel("Ping") local FPSLabel = makeInfoLabel("FPS")
local PlaceVersionLbl = makeInfoLabel("PlaceVersion") local ServerTypeLbl = makeInfoLabel("ServerType")
local LocalPlayerLbl = makeInfoLabel("LocalPlayer") local AccountAgeLbl = makeInfoLabel("AccountAge")
local UptimeLabel = makeInfoLabel("Uptime") local MemoryLabel = makeInfoLabel("Memory")

task.spawn(function()
	local placeId = game.PlaceId local jobId = game.JobId local gameName = "Unknown"
	pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name end)
	local placeVersion = tonumber(game.PlaceVersion) or 0
	Ether.SafeConnect(run.RenderStepped, function()
		local playersList = players:GetPlayers() local playerCount = #playersList
		local pingStr = "N/A" local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
		if pingItem then pingStr = pingItem:GetValueString() end
		local memoryStr = "N/A" pcall(function() memoryStr = string.format("%.1f MB", Stats:GetTotalMemoryUsageMb()) end)
		local serverType = "Public" pcall(function() if playerCount == 1 and players.MaxPlayers > 1 then serverType = "Private" end end)
		local accountAgeDays = player.AccountAge or 0 local uptimeSec = os.time() - Ether.exeRunningTime
		local h, m, s = math.floor(uptimeSec / 3600), math.floor((uptimeSec % 3600) / 60), uptimeSec % 60
		local uptimeStr = string.format("%02d:%02d:%02d", h, m, s)
		local names = {} for _, plr in ipairs(playersList) do table.insert(names, plr.Name) end
		
		GameNameLabel.Text = "Game: " .. tostring(gameName)
		PlaceIdLabel.Text = "PlaceId: " .. tostring(placeId)
		JobIdLabel.Text = "JobId: " .. tostring(jobId)
		PlayerCountLbl.Text = "Players: " .. tostring(playerCount) .. " [" .. table.concat(names, ", ") .. "]"
		PingLabel.Text = "Ping: " .. tostring(pingStr)
		FPSLabel.Text = "FPS: " .. tostring(0)
		PlaceVersionLbl.Text = "PlaceVersion: " .. tostring(placeVersion)
		ServerTypeLbl.Text = "ServerType: " .. serverType
		LocalPlayerLbl.Text = "LocalPlayer: " .. player.Name .. " (ID: " .. tostring(player.UserId) .. ")"
		AccountAgeLbl.Text = "AccountAge: " .. tostring(accountAgeDays) .. " days"
		UptimeLabel.Text = "Uptime: " .. uptimeStr
		MemoryLabel.Text = "Memory: " .. memoryStr
	end)
end)

local Credits = Ether.Create("TextLabel", { Name="Credits", Parent=InfoTab.containerInstance, BackgroundColor3=Color3.fromRGB(25,25,25), Size=UDim2.new(0.2,0,0,30), Font=Enum.Font.GothamBlack, TextColor3=Color3.fromRGB(255,255,255), Text="Credits:", TextSize=20 })
local Credits_Text = Credits:Clone() Credits_Text.Name="Credits_Text" Credits_Text.Parent=InfoTab.containerInstance Credits_Text.Size=UDim2.new(1,-10,0.3,0) Credits_Text.Font=Enum.Font.GothamSemibold Credits_Text.Text="This script was made by LucidSc1pt" Credits_Text.TextSize=18

local combinedText = "📜 All Versions:\n\n[v0.0.1 beta]\n• Release!\n\n"
local Changelog = Credits:Clone() Changelog.Name="Changelog" Changelog.Parent=InfoTab.containerInstance Changelog.Size=UDim2.new(0.25,0,0,30) Changelog.Text="📜 Changelog:"
local Changelog_Text_Holder = Ether.Create("ScrollingFrame", { Name="Changelog_Text_Holder", Parent=InfoTab.containerInstance, BackgroundColor3=Color3.fromRGB(25,25,25), Size=UDim2.new(1,0,0.6,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=1, AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y })
Ether.Create("TextLabel", { Name="Changelog_Text", Parent=Changelog_Text_Holder, BackgroundTransparency=1, Size=UDim2.new(0,0,0,0), Font=Enum.Font.GothamSemibold, Text=combinedText, TextXAlignment=Enum.TextXAlignment.Left, TextSize=18, AutomaticSize=Enum.AutomaticSize.Y, TextWrapped=false })

return Ether
