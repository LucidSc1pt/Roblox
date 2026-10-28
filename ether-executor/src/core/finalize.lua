-- core/finalize.lua
local Ether = getgenv().Ether
if not Ether then return end

Ether.Notification({
	Title = "Loaded!",
	Content = "Ether Internal Executor",
	Time = 5
})

print("[Ether] All modules loaded successfully (Fully Modular Version)!")
