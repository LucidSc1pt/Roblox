-- core/services.lua
local Ether = getgenv().Ether
if not Ether then return end

Ether.TweenService = game:GetService("TweenService")
Ether.CoreGui = game:GetService("CoreGui")
Ether.UIS = game:GetService("UserInputService")
Ether.Players = game:GetService("Players")
Ether.RunService = game:GetService("RunService")
Ether.HttpService = game:GetService("HttpService")
Ether.Stats = game:GetService("Stats")
Ether.MarketplaceService = game:GetService("MarketplaceService")

Ether.Player = Ether.Players.LocalPlayer
Ether.Mouse = Ether.Player:GetMouse()

return Ether
