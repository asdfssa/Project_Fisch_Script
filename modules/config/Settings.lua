-- ============================================
-- CONFIG MODULE - การตั้งค่าและตัวแปรทั่วไป
-- ============================================

local Config = {}

-- 🎯 Core Settings
Config.StopAll = false
Config.AutoFish = false
Config.AutoShake = true
Config.AlwaysPerfect = true
Config.FrozenBar = true
Config.LockPosition = true
Config.AntiAFK = true
Config.CastDelay = 0.5
Config.ReelDelay = 2.5
Config.HideShakeUI = false

-- 💰 Auto Sell Settings
Config.AutoSellAll = false
Config.SellAllInterval = 5

-- 🏃 Movement Settings
Config.WalkSpeedEnabled = false
Config.WalkSpeed = 16
Config.JumpPowerEnabled = false
Config.JumpPower = 50
Config.Noclip = false
Config.DashEnabled = true
Config.DashSpeed = 100
Config.FlyEnabled = true
Config.FlySpeed = 50
Config.IsFlying = false
Config.FlyInertia = true
Config.BoostEnabled = false

-- 👁️ ESP & Mobile Settings
Config.ESPEnabled = false
Config.MobileFlyUp = false

-- 📍 Custom Location Settings
Config.CustomName = ""
Config.CustomX = 0
Config.CustomY = 135
Config.CustomZ = 0
Config.SearchQuery = ""
Config.ManagerSearch = ""

-- 🛡️ Auto Totem Settings
Config.AutoTotem = false
Config.DayTotemSelect = "Sundial Totem"
Config.NightTotemSelect = "Aurora Totem"

-- 🧪 Auto Potion Settings
Config.AutoPotion = false
Config.SelectedPotion = "Luck Potion"
Config.PotionDelayMinutes = 10
Config.PotionRepeatCount = 999
Config.PotionTimer = 0

-- 🔒 Internal State (ไม่ควรแก้ไขโดยตรง)
Config.ProcessingTotem = false
Config.ProcessingPotion = false

-- 📁 File Name
Config.FileName = "Fisch_FarmHub_Locations.json"

return Config
