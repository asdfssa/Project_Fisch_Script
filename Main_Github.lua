-- ============================================
-- MAIN LOADER - สำหรับ GitHub/HttpGet (ต้นฉบับ)
-- ============================================

print("[Fisch FarmHub] Loading from GitHub...")

-- ============================================
-- GitHub Configuration
-- ============================================
local GITHUB_BASE = "https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/"

-- ============================================
-- Module Loader Function
-- ============================================
local function LoadModule(modulePath)
    local url = GITHUB_BASE .. modulePath
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("[Fisch FarmHub] Failed to load: " .. modulePath)
        warn("Error: " .. tostring(result))
        return nil
    end
    
    print("[Fisch FarmHub] Loaded: " .. modulePath)
    return result
end

-- ============================================
-- Load All Modules
-- ============================================
local Config = LoadModule("config/Settings.lua")
local Services = LoadModule("services/Services.lua")
local Data = LoadModule("data/Data.lua")
local Utils = LoadModule("utils/Utils.lua")

-- UI Modules
local MainUI = LoadModule("ui/MainUI.lua")
local LogUI = LoadModule("ui/LogUI.lua")
local InfoUI = LoadModule("ui/InfoUI.lua")
local FlyUI = LoadModule("ui/FlyUI.lua")
local TabSetup = LoadModule("ui/TabSetup.lua")

-- Logic Modules
local AutoFish = LoadModule("logic/AutoFish.lua")
local AutoTotem = LoadModule("logic/AutoTotem.lua")
local AutoPotion = LoadModule("logic/AutoPotion.lua")
local AutoSell = LoadModule("logic/AutoSell.lua")
local Character = LoadModule("logic/Character.lua")

-- Check if all modules loaded
if not (Config and Services and Data and Utils and MainUI) then
    warn("[Fisch FarmHub] Critical modules failed to load!")
    return
end

-- ============================================
-- Initialize UI Components
-- ============================================
LogUI.Create()
InfoUI.Create()
FlyUI.Create()

-- ============================================
-- Initialize Main UI
-- ============================================
local UI = MainUI.Create()
if not UI then
    warn("[Fisch FarmHub] Failed to initialize Main UI")
    return
end

-- Create Mobile UI
MainUI.CreateMobileUI()

-- ============================================
-- Setup All Tabs
-- ============================================
TabSetup.SetupAllTabs(UI, Data, Utils)

-- ============================================
-- Initialize Logic Systems
-- ============================================
AutoFish.Start()
AutoFish.SetupShakeDetection()
AutoTotem.Start()
AutoPotion.Start()
AutoSell.Start()
Character.Start()

-- ============================================
-- Script Loaded
-- ============================================
LogUI.AddLog("✅ All systems initialized from GitHub!", Color3.fromRGB(100, 255, 100))
print("[Fisch FarmHub] All modules loaded successfully!")
