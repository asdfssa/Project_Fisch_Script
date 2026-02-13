-- ============================================
-- MAIN LOADER - สำหรับ GitHub/HttpGet
-- ใช้งาน: loadstring(game:HttpGet("YOUR_GITHUB_RAW_URL/Main.lua"))()
-- ============================================

print("[Fisch FarmHub] Loading from GitHub...")

-- ============================================
-- GitHub Configuration
-- แก้ URL นี้ให้ตรงกับ repo ของคุณ
-- ============================================
local GITHUB_BASE = "https://raw.githubusercontent.com/USERNAME/REPO_NAME/main/modules/"
-- ตัวอย่าง: "https://raw.githubusercontent.com/yossa/fisch-script/main/modules/"

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
local Teleport = LoadModule("logic/Teleport.lua")

-- Check if all modules loaded
if not (Config and Services and Data and Utils and MainUI) then
    warn("[Fisch FarmHub] Critical modules failed to load!")
    return
end

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
    warn("[Fisch FarmHub] Failed to initialize Main UI")
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
LogUI.AddLog("✅ All systems initialized from GitHub!", Color3.fromRGB(100, 255, 100))
print("[Fisch FarmHub] All modules loaded successfully!")
