-- ============================================
-- SERVICES MODULE - Roblox Services
-- ============================================

local Services = {}

-- Core Services
Services.HttpService = game:GetService("HttpService")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")
Services.Debris = game:GetService("Debris")
Services.Players = game:GetService("Players")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.CoreGui = game:GetService("CoreGui")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.VirtualUser = game:GetService("VirtualUser")
Services.Lighting = game:GetService("Lighting")
Services.TeleportService = game:GetService("TeleportService")

-- Player References
Services.LocalPlayer = Services.Players.LocalPlayer

-- Platform Detection
local ScreenSize = workspace.CurrentCamera.ViewportSize
Services.IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, Services.UserInputService:GetPlatform())

-- Window Sizing
if Services.IsMobile or ScreenSize.X < 700 then
    Services.WindowSize = UDim2.fromOffset(math.min(ScreenSize.X * 0.85, 600), math.min(ScreenSize.Y * 0.70, 400))
    Services.TabsWidth = 120
else
    Services.WindowSize = UDim2.fromOffset(580, 460)
    Services.TabsWidth = 160
end

return Services
