-- ============================================
-- SERVICES MODULE - เก็บ Services จากต้นฉบับ
-- ============================================

local Services = {}

Services.HttpService = game:GetService("HttpService")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")
Services.Debris = game:GetService("Debris")
Services.Players = game:GetService("Players")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.CoreGui = game:GetService("CoreGui")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.VirtualUser = game:GetService("VirtualUser")
Services.LocalPlayer = Services.Players.LocalPlayer
Services.Lighting = game:GetService("Lighting")
Services.TeleportService = game:GetService("TeleportService")

-- ScreenSize & Platform Detection
Services.ScreenSize = workspace.CurrentCamera.ViewportSize
Services.IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, Services.UserInputService:GetPlatform())

-- Window Size Calculation
if Services.IsMobile or Services.ScreenSize.X < 700 then
    local targetWidth = math.min(Services.ScreenSize.X * 0.85, 600)
    local targetHeight = math.min(Services.ScreenSize.Y * 0.70, 400)
    Services.WindowSize = UDim2.fromOffset(targetWidth, targetHeight)
    Services.TabsWidth = 120
else
    Services.WindowSize = UDim2.fromOffset(580, 460)
    Services.TabsWidth = 160
end

return Services
