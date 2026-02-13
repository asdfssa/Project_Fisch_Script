-- ============================================
-- CONFIG MODULE - ตัวแปร _G ทั้งหมดจากต้นฉบับ
-- ============================================

-- ⚙️ SETTINGS & VARIABLES
_G.StopAll = false
_G.AutoFish = false
_G.AutoShake = true
_G.AlwaysPerfect = true
_G.FrozenBar = true
_G.LockPosition = true
_G.AntiAFK = true
_G.CastDelay = 0.5
_G.ReelDelay = 2.5
_G.HideShakeUI = false

-- Autos Settings
_G.AutoSellAll = false
_G.SellAllInterval = 5

-- Movement
_G.WalkSpeedEnabled = false
_G.WalkSpeed = 16
_G.JumpPowerEnabled = false
_G.JumpPower = 50
_G.Noclip = false
_G.DashEnabled = true
_G.DashSpeed = 100
_G.FlyEnabled = true
_G.FlySpeed = 50
_G.IsFlying = false
_G.FlyInertia = true
_G.BoostEnabled = false

-- ESP & Mobile
_G.ESPEnabled = false
_G.MobileFlyUp = false

-- Custom Locations
_G.CustomName = ""
_G.CustomX = 0
_G.CustomY = 135
_G.CustomZ = 0
_G.SearchQuery = ""
_G.ManagerSearch = ""

-- Auto Totem Settings
_G.AutoTotem = false
_G.DayTotemSelect = "Sundial Totem"
_G.NightTotemSelect = "Aurora Totem"

-- Auto Potion Settings
_G.AutoPotion = false
_G.SelectedPotion = nil
_G.PotionDelayMinutes = 10
_G.PotionRepeatCount = 999
_G.PotionTimer = 0

-- Internal State
_G.ProcessingTotem = false

-- File Name
local FileName = "Fisch_FarmHub_Locations.json"

-- State variables (ไม่ใช่ _G) - แก้ currentSpot เป็น _G
local currentFlyVelocity = Vector3.new(0, 0, 0)
_G.currentSpot = nil
local keysDown = {}
local lastSpacePress = 0

-- Return state accessors
return {
    FileName = FileName,
    currentFlyVelocity = currentFlyVelocity,
    keysDown = keysDown,
    lastSpacePress = lastSpacePress
    -- currentSpot ย้ายไปใช้ _G.currentSpot แล้ว
