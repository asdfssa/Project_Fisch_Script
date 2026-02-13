-- ============================================
-- MAIN LOADER - จุดเริ่มต้นของ Script
-- ============================================

print("Script is running")

-- ============================================
-- Load Modules
-- ============================================
local Config = loadstring(readfile("modules/config/Settings.lua"))()
local Services = loadstring(readfile("modules/services/Services.lua"))()
local Data = loadstring(readfile("modules/data/Data.lua"))()
local Utils = loadstring(readfile("modules/utils/Utils.lua"))()

-- UI Modules
local MainUI = loadstring(readfile("modules/ui/MainUI.lua"))()
local LogUI = loadstring(readfile("modules/ui/LogUI.lua"))()
local InfoUI = loadstring(readfile("modules/ui/InfoUI.lua"))()
local FlyUI = loadstring(readfile("modules/ui/FlyUI.lua"))()
local TabSetup = loadstring(readfile("modules/ui/TabSetup.lua"))()

-- Logic Modules
local AutoFish = loadstring(readfile("modules/logic/AutoFish.lua"))()
local AutoTotem = loadstring(readfile("modules/logic/AutoTotem.lua"))()
local AutoPotion = loadstring(readfile("modules/logic/AutoPotion.lua"))()
local AutoSell = loadstring(readfile("modules/logic/AutoSell.lua"))()
local Character = loadstring(readfile("modules/logic/Character.lua"))()
local Teleport = loadstring(readfile("modules/logic/Teleport.lua"))()

-- ============================================
-- State Management
-- ============================================
local State = {
    FlyVelocity = Vector3.new(0, 0, 0),
    CurrentSpot = nil,
    LocalPlayer = Services.LocalPlayer
}

-- ============================================
-- Initialize UI Components
-- ============================================
LogUI.Create()
InfoUI.Create()
FlyUI.Create(State)

-- ============================================
-- Initialize Main UI
-- ============================================
local UI = MainUI.Create(Services, Data, Config, State)
if not UI then
    warn("Failed to initialize Main UI")
    return
end

-- Create Mobile UI
MainUI.CreateMobileUI(Services)

-- ============================================
-- Setup All Tabs
-- ============================================
TabSetup.SetupAllTabs(UI, Config, State, Data, Utils, Services, LogUI, InfoUI, FlyUI, Teleport)

-- ============================================
-- Initialize Logic Systems
-- ============================================
AutoFish.Start(Config, State, Utils, LogUI, UI)
AutoFish.SetupShakeDetection(Utils, Config)

AutoTotem.Start(Config, State, Utils, UI)
AutoPotion.Start(Config, State, Utils, UI, LogUI)
AutoSell.Start(Config, Utils, LogUI)
Character.Start(Config, State, Utils, FlyUI)
Character.SetupAntiAFK(Config)

-- ============================================
-- Script Loaded
-- ============================================
LogUI.AddLog("✅ All systems initialized successfully!", Color3.fromRGB(100, 255, 100))
print("[Fisch FarmHub] All modules loaded successfully!")
