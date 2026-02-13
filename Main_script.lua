print("Script is runnig")
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not result then
    warn("[Script Error]: Failed to load Fluent UI! Check your internet.")
    return
end

local Fluent = result
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 🛠️ SERVICES
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- [[ ℹ️ SERVER INFO PANEL SETUP ]] --
local InfoGui = Instance.new("ScreenGui")
InfoGui.Name = "FischInfoGui"
InfoGui.Parent = game:GetService("CoreGui")
InfoGui.Enabled = true -- เริ่มต้นปิดไว้
InfoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- กรอบหลัก (Main Frame)
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "MainFrame"
InfoFrame.Parent = InfoGui
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
InfoFrame.BorderSizePixel = 1
InfoFrame.Position = UDim2.new(0.02, 0, 0.25, 0) -- ตำแหน่งซ้าย (ปรับได้)
InfoFrame.Size = UDim2.new(0, 250, 0, 120) -- ขนาดเริ่มต้น
InfoFrame.Active = true
InfoFrame.Draggable = true -- ลากได้

-- หัวข้อ (Title Bar)
local InfoTitle = Instance.new("TextLabel")
InfoTitle.Parent = InfoFrame
InfoTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoTitle.Size = UDim2.new(1, 0, 0, 25)
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.Text = "  📊 Server Info"
InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitle.TextSize = 14
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มพับเก็บ (Minimize Button) [-] / [+]
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = InfoFrame
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18

-- พื้นที่เนื้อหา (Content)
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = InfoFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 30)
ContentFrame.Size = UDim2.new(1, -20, 1, -35)

-- สร้าง TextLabel สำหรับแสดงค่าต่างๆ
local function CreateInfoLabel(order, defaultText)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ContentFrame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 0, 0, (order - 1) * 25)
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = defaultText
    return lbl
end

local RealTimeLabel = CreateInfoLabel(1, "🕒 Real: ...")
local GameTimeLabel = CreateInfoLabel(2, "☀️ Game: ...")
local UptimeLabel = CreateInfoLabel(3, "⏳ Up: ...")

-- [[ ระบบพับเก็บ (Minimizing Logic) ]] --
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        -- หุบ: ลดขนาดเฟรม + ซ่อนเนื้อหา
        InfoFrame:TweenSize(UDim2.new(0, 250, 0, 25), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        -- ขยาย: คืนขนาดเดิม + โชว์เนื้อหา
        InfoFrame:TweenSize(UDim2.new(0, 250, 0, 120), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- [[ ✈️ FLY CONTROL PANEL (MOBILE) ]] --
local FlyGui = Instance.new("ScreenGui")
FlyGui.Name = "FischFlyGui"
FlyGui.Parent = game:GetService("CoreGui")
FlyGui.Enabled = false -- เริ่มต้นปิดไว้
FlyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- กรอบหลัก (ปรับความสูงเพิ่มเป็น 180 เพื่อรองรับปุ่มใหม่)
local FlyFrame = Instance.new("Frame")
FlyFrame.Name = "FlyMainFrame"
FlyFrame.Parent = FlyGui
FlyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FlyFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
FlyFrame.BorderSizePixel = 1
FlyFrame.Position = UDim2.new(0.8, 0, 0.25, 0) 
FlyFrame.Size = UDim2.new(0, 150, 0, 180) -- สูงขึ้น
FlyFrame.Active = true
FlyFrame.Draggable = true 

-- หัวข้อ
local FlyTitle = Instance.new("TextLabel")
FlyTitle.Parent = FlyFrame
FlyTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyTitle.Size = UDim2.new(1, 0, 0, 25)
FlyTitle.Font = Enum.Font.GothamBold
FlyTitle.Text = "  ✈️ Fly Control"
FlyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyTitle.TextSize = 14
FlyTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มพับเก็บ
local FlyMinimizeBtn = Instance.new("TextButton")
FlyMinimizeBtn.Parent = FlyFrame
FlyMinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FlyMinimizeBtn.BackgroundTransparency = 1
FlyMinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
FlyMinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
FlyMinimizeBtn.Font = Enum.Font.GothamBold
FlyMinimizeBtn.Text = "-"
FlyMinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyMinimizeBtn.TextSize = 18

-- พื้นที่เนื้อหา
local FlyContent = Instance.new("Frame")
FlyContent.Parent = FlyFrame
FlyContent.BackgroundTransparency = 1
FlyContent.Position = UDim2.new(0, 10, 0, 35)
FlyContent.Size = UDim2.new(1, -20, 1, -45)

-- 1. ปุ่ม On/Off (Main Toggle)
local ToggleFlyBtn = Instance.new("TextButton")
ToggleFlyBtn.Name = "ToggleFlyBtn"
ToggleFlyBtn.Parent = FlyContent
ToggleFlyBtn.Size = UDim2.new(1, 0, 0, 50)
ToggleFlyBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
ToggleFlyBtn.Font = Enum.Font.GothamBold
ToggleFlyBtn.Text = "OFF"
ToggleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFlyBtn.TextSize = 24
Instance.new("UICorner", ToggleFlyBtn).CornerRadius = UDim.new(0, 8)

-- 2. ปุ่ม Speed Boost (อยู่ด้านล่าง)
local BoostFlyBtn = Instance.new("TextButton")
BoostFlyBtn.Name = "BoostFlyBtn"
BoostFlyBtn.Parent = FlyContent
BoostFlyBtn.Size = UDim2.new(1, 0, 0, 40)
BoostFlyBtn.Position = UDim2.new(0, 0, 0, 60) -- เว้นระยะลงมา
BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- สีเทา (ยังไม่กด)
BoostFlyBtn.Font = Enum.Font.GothamBold
BoostFlyBtn.Text = "⚡ Speed: Normal"
BoostFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostFlyBtn.TextSize = 16
Instance.new("UICorner", BoostFlyBtn).CornerRadius = UDim.new(0, 8)

-- Logic: ปุ่ม On/Off
ToggleFlyBtn.MouseButton1Click:Connect(function()
    _G.IsFlying = not _G.IsFlying
    
    if _G.IsFlying then
        ToggleFlyBtn.Text = "ON"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleFlyBtn.Text = "OFF"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        currentFlyVelocity = Vector3.new(0, 0, 0)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then 
            char.Humanoid.PlatformStand = false 
        end
    end
end)

-- Logic: ปุ่ม Boost
BoostFlyBtn.MouseButton1Click:Connect(function()
    _G.BoostEnabled = not _G.BoostEnabled
    
    if _G.BoostEnabled then
        BoostFlyBtn.Text = "⚡ Speed: FAST!"
        BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- สีเหลืองทอง
        BoostFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- ตัวหนังสือดำให้อ่านง่าย
    else
        BoostFlyBtn.Text = "⚡ Speed: Normal"
        BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BoostFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Logic: ย่อ/ขยาย หน้าต่าง
local isFlyMinimized = false
FlyMinimizeBtn.MouseButton1Click:Connect(function()
    isFlyMinimized = not isFlyMinimized
    if isFlyMinimized then
        FlyFrame:TweenSize(UDim2.new(0, 150, 0, 25), "Out", "Quad", 0.3, true)
        FlyContent.Visible = false
        FlyMinimizeBtn.Text = "+"
    else
        FlyFrame:TweenSize(UDim2.new(0, 150, 0, 180), "Out", "Quad", 0.3, true)
        FlyContent.Visible = true
        FlyMinimizeBtn.Text = "-"
    end
end)

-- Auto Sync Loop (สำหรับเช็คว่าสถานะเปลี่ยนจากทางอื่นหรือไม่)
task.spawn(function()
    while true do
        task.wait(0.2)
        if FlyGui.Enabled then
            -- Sync ปุ่มบิน
            if _G.IsFlying and ToggleFlyBtn.Text ~= "ON" then
                ToggleFlyBtn.Text = "ON"
                ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            elseif not _G.IsFlying and ToggleFlyBtn.Text ~= "OFF" then
                ToggleFlyBtn.Text = "OFF"
                ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end

            -- Sync ปุ่ม Boost
            if _G.BoostEnabled and BoostFlyBtn.Text ~= "⚡ Speed: FAST!" then
                BoostFlyBtn.Text = "⚡ Speed: FAST!"
                BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                BoostFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            elseif not _G.BoostEnabled and BoostFlyBtn.Text ~= "⚡ Speed: Normal" then
                BoostFlyBtn.Text = "⚡ Speed: Normal"
                BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                BoostFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end)

-- [[ 📜 LOG SYSTEM SETUP ]] --
local LogGui = Instance.new("ScreenGui")
LogGui.Name = "FischLogGui"
LogGui.Parent = game:GetService("CoreGui")
LogGui.Enabled = false -- เริ่มต้นปิดไว้
LogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LogFrame = Instance.new("Frame")
LogFrame.Name = "MainFrame"
LogFrame.Parent = LogGui
LogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
LogFrame.BorderSizePixel = 1
LogFrame.Position = UDim2.new(0.75, 0, 0.65, 0) -- ตำแหน่งขวาล่าง (ปรับได้)
LogFrame.Size = UDim2.new(0, 300, 0, 200) -- ขนาดหน้าต่าง
LogFrame.Active = true
LogFrame.Draggable = true -- ลากย้ายตำแหน่งได้

-- หัวข้อ (Title Bar)
local LogTitle = Instance.new("TextLabel")
LogTitle.Parent = LogFrame
LogTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LogTitle.Size = UDim2.new(1, 0, 0, 25)
LogTitle.Font = Enum.Font.GothamBold
LogTitle.Text = "  📜 Script Logs"
LogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LogTitle.TextSize = 14
LogTitle.TextXAlignment = Enum.TextXAlignment.Left

-- พื้นที่แสดงข้อความ (Scrolling Frame)
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Parent = LogFrame
LogScroll.BackgroundTransparency = 1
LogScroll.Position = UDim2.new(0, 5, 0, 30)
LogScroll.Size = UDim2.new(1, -10, 1, -35)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout")
UIList.Parent = LogScroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)

-- ฟังก์ชันสำหรับเพิ่ม Log (เรียกใช้ได้ทั่วสคริปต์)
_G.AddLog = function(text, color)
    local timestamp = os.date("%H:%M:%S")
    local label = Instance.new("TextLabel")
    label.Parent = LogScroll
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18) -- ความสูงบรรทัด
    label.Font = Enum.Font.SourceSans
    label.Text = string.format("[%s] %s", timestamp, text)
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200) -- สี default ขาวหม่น
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = false -- ตัดบรรทัดถ้ายาวเกิน
    
    -- Auto Scroll ลงล่างสุด
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, UIList.AbsoluteContentSize.Y)
    
    -- ลบ Log เก่าถ้าเยอะเกิน (กันแลค)
    if #LogScroll:GetChildren() > 100 then
        LogScroll:GetChildren()[2]:Destroy() -- [1] คือ UIListLayout
    end
end

-- ทดสอบ Log
_G.AddLog("System initialized...", Color3.fromRGB(100, 255, 100))

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

local currentFlyVelocity = Vector3.new(0, 0, 0)
local currentSpot = nil
local keysDown = {}
local lastSpacePress = 0
local FileName = "Fisch_FarmHub_Locations.json"
local ESPHolder = Instance.new("Folder", CoreGui)
ESPHolder.Name = "FischESPHolder"

-- 📍 DATA TABLES
local DefaultLocations = {
    ["Moosewood (Spawn)"] = {x=380, y=135, z=220},
    ["Roslit Bay"] = {x=-1485, y=132, z=720},
    ["Terrapin Island"] = {x=-16, y=135, z=1540},
    ["Snowcap Island"] = {x=2610, y=135, z=2435},
    ["Sunstone Island"] = {x=-930, y=132, z=-1125},
    ["Statue of Sovereignty"] = {x=40, y=135, z=-1020},
    ["Mushgrove Swamp"] = {x=2440, y=132, z=-700},
    ["Keepers Altar"] = {x=1300, y=-225, z=-380},
    ["Desolate Deep"] = {x=-1650, y=-210, z=2840},
    ["Archeological Site"] = {x=4150, y=135, z=245},
    ["Vertigo (Entrance)"] = {x=-110, y=-510, z=1050},
    ["The Depths"] = {x=990, y=-710, z=1250},
    ["(Secret) Event Zone"] = {x=20654, y=140, z=-18005},

    ["Enchant"] = {x=1309,y=-806,z=-103},
    ["Coral Bastion"] = {x=2523,y=-1097,z=858}
}

local RodList = {
    {Name = "Training Rod", Price = 300}, {Name = "Plastic Rod", Price = 750},
    {Name = "Carbon Rod", Price = 2000}, {Name = "Stone Rod", Price = 2000},
    {Name = "Long Rod", Price = 3000}, {Name = "Fast Rod", Price = 4000},
    {Name = "Lucky Rod", Price = 4500}, {Name = "Steady Rod", Price = 7000},
    {Name = "Firefly Rod", Price = 9500}, {Name = "Fortune Rod", Price = 11000},
    {Name = "Rapid Rod", Price = 12000}, {Name = "Frog Rod", Price = 12000},
    {Name = "Magnet Rod", Price = 15000}, {Name = "Brine-Infused Rod", Price = 15000},
    {Name = "Merchant Rod", Price = 20000}, {Name = "Reinforced Rod", Price = 20000},
    {Name = "Arctic Rod", Price = 25000}, {Name = "Coral Rod", Price = 30000},
    {Name = "Crystalized Rod", Price = 35000}, {Name = "Avalanche Rod", Price = 35000},
    {Name = "Firework Rod", Price = 35000}, {Name = "Wildflower Rod", Price = 40000},
    {Name = "Depthseeker Rod", Price = 40000}, {Name = "Scurvy Rod", Price = 40000},
    {Name = "Boreal Rod", Price = 42000}, {Name = "Cinder Block Rod", Price = 50000},
    {Name = "The Boom Ball", Price = 50000}, {Name = "Verdant Shear Rod", Price = 50000},
    {Name = "Phoenix Rod", Price = 50000}, {Name = "Treasure Rod", Price = 50000},
    {Name = "Midas Rod", Price = 55000}, {Name = "Ice Warpers Rod", Price = 65000},
    {Name = "Blazebringer Rod", Price = 70000}, {Name = "Aurora Rod", Price = 70000},
    {Name = "Paper Fan Rod", Price = 70000}, {Name = "Carrot Rod", Price = 75000},
    {Name = "Meteor Totem", Price = 75000}, {Name = "Champions Rod", Price = 90000},
    {Name = "Mythical Rod", Price = 90000}, {Name = "Azure Of Lagoon", Price = 100000},
    {Name = "Kings Rod", Price = 100000}, {Name = "Fallen Rod", Price = 175000},
    {Name = "Scarlet Spincaster Rod", Price = 180000}, {Name = "Destiny Rod", Price = 190000},
    {Name = "Free Spirit Rod", Price = 200000}, {Name = "Volcanic Rod", Price = 250000},
    {Name = "Rainbow Cluster Rod", Price = 250000}, {Name = "Leviathan's Fang Rod", Price = 350000},
    {Name = "Wicked Fang Rod", Price = 400000}, {Name = "Tempest Rod", Price = 500000},
    {Name = "Summit Rod", Price = 500000}, {Name = "Poseidon Rod", Price = 700000},
    {Name = "Great Dreamer Rod", Price = 700000}, {Name = "Tidemourner Head", Price = 750000},
    {Name = "Challenger's Rod", Price = 750000}, {Name = "Rod Of The Depths", Price = 750000},
    {Name = "Cerulean Fang Rod", Price = 800000}, {Name = "Zeus Rod", Price = 850000},
    {Name = "Abyssal Specter Rod", Price = 850000}, {Name = "Kraken Rod", Price = 950000},
    {Name = "Luminescent Oath", Price = 1000000}, {Name = "Rod Of The Zenith", Price = 1500000},
    {Name = "Frostbane Rod", Price = 1500000}, {Name = "Heaven's Rod", Price = 1750000},
    {Name = "Eidolon Rod", Price = 2000000}, {Name = "Great Rod of Oscar", Price = 2500000},
    {Name = "Maelstrom", Price = 3250000}, {Name = "Cryolash", Price = 3500000},
    {Name = "Ethereal Prism Rod", Price = 3500000}, {Name = "Ruinous Oath", Price = 5000000},
    {Name = "Sanguine Spire", Price = 10000000}, {Name = "Thalassar's Ruin", Price = 14500000},
    {Name = "Original No-Life Rod", Price = 1},
}

local TotemData = {
    {Name = "Tempest Totem", Price = 2000},
    {Name = "Windset Totem", Price = 2000},
    {Name = "Sundial Totem", Price = 2000},
    {Name = "Smokescreen Totem", Price = 2000},
    {Name = "Clearcast Totem", Price = 2000},
    {Name = "Meteor Totem", Price = 75000},
    {Name = "Blue Moon Totem", Price = 75000},
    {Name = "Eclipse Totem", Price = 75000},
    {Name = "Blizzard Totem", Price = 75000},
    {Name = "Avalanche Totem", Price = 75000},
    {Name = "Aurora Totem", Price = 500000}
}
local TotemList = {}
for _, v in ipairs(TotemData) do table.insert(TotemList, v.Name) end

local PotionList = {
    "Luck Potion", "Lure Speed Potion", "All Season Potion", 
    "Glitched Potion", "Abyssal Tonic", "Ghost Elixir", 
    "Fortune Potion", "Hasty Potion", "Sea Traveler Note"
}

-- ⚡ HELPER FUNCTIONS
local function LoadCustomLocations()
    if isfile and isfile(FileName) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if success then return result end
    end
    return {}
end

local function SaveCustomLocations(data)
    if writefile then writefile(FileName, HttpService:JSONEncode(data)) end
end

local function hasItem(itemName)
    return (LocalPlayer.Backpack:FindFirstChild(itemName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName))) ~= nil
end

local function getMoney()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local coin = ls and ls:FindFirstChild("C$") or ls:FindFirstChild("Cash")
    return coin and coin.Value or 0
end

local function FindSellAllRemote()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("SellAll") or events:FindFirstChild("sellall")
    end
    return nil
end

local function FindSellHandRemote()
    local targetPath = "packages/Net/RF/Merchant/Sell"
    local parts = string.split(targetPath, "/")
    local current = ReplicatedStorage
    for _, part in ipairs(parts) do
        if current:FindFirstChild(part) then
             current = current[part]
        else
            return nil
        end
    end
    if current and current:IsA("RemoteFunction") then
        return current
    end
    return nil
end

local function GetPurchaseRemote()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("purchase")
    end
    return nil
end

local ScreenSize = workspace.CurrentCamera.ViewportSize
local IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, game:GetService("UserInputService"):GetPlatform())
local WindowSize
local TabsWidth = 160 -- ค่าเดิมสำหรับ PC

if IsMobile or ScreenSize.X < 700 then
    -- กรณีมือถือ หรือจอเล็ก: ให้ขนาดหน้าต่างเป็น 85% ของความกว้าง และ 70% ของความสูง
    -- แต่ต้องไม่เกินขนาด Max ที่เรากำหนดไว้
    local targetWidth = math.min(ScreenSize.X * 0.85, 600)
    local targetHeight = math.min(ScreenSize.Y * 0.70, 400)
    
    WindowSize = UDim2.fromOffset(targetWidth, targetHeight)
    TabsWidth = 120 -- ลดขนาดความกว้างปุ่ม Tab ให้เล็กลงในมือถือ
else
    -- กรณี PC: ใช้ขนาด Fixed แบบเดิม
    WindowSize = UDim2.fromOffset(580, 460)
end

-- 🖼️ UI SETUP (แก้ใหม่)
local Window = Fluent:CreateWindow({
    Title = "Farm Hub | version 1.1",
    SubTitle = "Ban 100%",
    TabWidth = TabsWidth, -- ใช้ตัวแปรที่คำนวณมา
    Size = WindowSize,    -- ใช้ตัวแปรที่คำนวณมา
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Auto Fish", Icon = "component" }),
    Autos = Window:AddTab({ Title = "Autos", Icon = "repeat" }), 
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    ServerInfo = Window:AddTab({ Title = "Server Info", Icon = "info" })
}

local Options = Fluent.Options

-- 📱 MOBILE TOGGLE
local function CreateMobileUI()
    if CoreGui:FindFirstChild("FischMobileUI") then CoreGui.FischMobileUI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "FischMobileUI"
    local MenuBtn = Instance.new("ImageButton", ScreenGui)
    MenuBtn.Name = "MenuToggle"; MenuBtn.BackgroundColor3 = Color3.new(0,0,0); MenuBtn.BackgroundTransparency = 0.5
    MenuBtn.AnchorPoint = Vector2.new(0.5, 0)
    MenuBtn.Position = UDim2.new(0.5, -25, 0.05, 0)
    
    MenuBtn.Size = UDim2.fromOffset(50, 50); MenuBtn.Size = UDim2.fromOffset(50, 50)
    MenuBtn.Image = "rbxassetid://100142831144115"; MenuBtn.Draggable = true
    Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", MenuBtn).Color = Color3.new(1,1,1)
    MenuBtn.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end
CreateMobileUI()

-- 🏠 HOME
Tabs.Home:AddToggle("StopAll", {Title = "STOP ALL ACTIONS", Default = false }):OnChanged(function()
    _G.StopAll = Options.StopAll.Value
    if _G.StopAll then
        _G.IsFlying = false; currentFlyVelocity = Vector3.new(0,0,0)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
             char.Humanoid.PlatformStand = false; char.Humanoid.AutoRotate = true 
        end
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            for _, v in pairs({"FlyVelocity", "FlyGyro"}) do
                 if char.HumanoidRootPart:FindFirstChild(v) then char.HumanoidRootPart[v]:Destroy() end
            end
        end
    end
end)

-- 🎣 MAIN (Auto Fish)
local ToggleAutoFish = Tabs.Main:AddToggle("AutoFish", {Title = "Enable Auto Fish", Default = false })
ToggleAutoFish:OnChanged(function()
    _G.AutoFish = Options.AutoFish.Value
    if _G.AutoFish and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        currentSpot = LocalPlayer.Character.HumanoidRootPart.CFrame
    else
        currentSpot = nil
    end
end)
Tabs.Main:AddToggle("AutoShake", {Title = "Auto Shake", Default = true }):OnChanged(function() _G.AutoShake = Options.AutoShake.Value end)
Tabs.Main:AddToggle("LockPosition", {Title = "Freeze Position", Default = true }):OnChanged(function() _G.LockPosition = Options.LockPosition.Value end)

-- 🤖 AUTOS (Original Sell + New Totem/Potion)
local Autos = Tabs.Autos
Autos:AddParagraph({ Title = "Sell Items", Content = "Auto sell or sell on hand." })

local ToggleSellAll = Autos:AddToggle("AutoSellAll", {Title = "Auto Sell All", Default = false })
ToggleSellAll:OnChanged(function() _G.AutoSellAll = Options.AutoSellAll.Value end)
Autos:AddSlider("SellAllInterval", {Title = "Sell Interval (s)", Default = 5, Min = 1, Max = 60, Rounding = 1, Callback = function(V) _G.SellAllInterval = V end})

Autos:AddButton({Title = "Sell On Hand", Callback = function()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("Sell")
    if remote then
        local success, res = pcall(function() return remote:InvokeServer() end)
        if success then _G.AddLog("💰 Sold Items", Color3.fromRGB(100, 255, 100)) Fluent:Notify({Title="Sell Hand", Content="Success! Return: " .. tostring(res), Duration=3}) else warn("Sell Hand Error:", res) end
    else
        Fluent:Notify({Title="Error", Content="Sell Remote Not Found!", Duration=3})
    end
end})

Autos:AddParagraph({ Title = "---", Content = "" })

-- [[ 🛡️ SMART AUTO TOTEM ]] --
Autos:AddParagraph({ Title = "Smart Auto Totem", Content = "ระบบตรวจจับเวลา Server แบบ Real-time\nจะทำงานทันทีที่เปลี่ยนช่วงเวลา (เช้า/ค่ำ)" })

_G.AutoTotem = false
_G.DayTotemSelect = "Sundial Totem"
_G.NightTotemSelect = "Aurora Totem"

Autos:AddToggle("EnableAutoTotem", {Title = "เปิดใช้งาน Smart Auto Totem", Default = false }):OnChanged(function(Value) _G.AutoTotem = Value end)

Autos:AddDropdown("DayTotemDrop", {
    Title = "☀️ Totem เมื่อเข้าสู่ตอนเช้า (06:30)", 
    Values = TotemList, 
    Multi = false, 
    Default = "Sundial Totem", -- [แก้ตรงนี้] ใส่ชื่อให้ตรงเป๊ะๆ
}):OnChanged(function(Value) _G.DayTotemSelect = Value end)

Autos:AddDropdown("NightTotemDrop", {
    Title = "🌙 Totem เมื่อเข้าสู่ตอนค่ำ (18:00)", 
    Values = TotemList, 
    Multi = false, 
    Default = "Aurora Totem", -- [แก้ตรงนี้] ใส่ชื่อให้ตรงเป๊ะๆ
}):OnChanged(function(Value) _G.NightTotemSelect = Value end)

-- [[ 🧪 AUTO POTION (TIMER MODE) ]] --
Autos:AddParagraph({ Title = "Auto Potion (Timer)", Content = "ระบบกินยาแบบตั้งเวลาวนลูป (หน่วย: นาที)" })

_G.AutoPotion = false
_G.SelectedPotion = PotionList[1]
_G.PotionDelayMinutes = 10 -- ค่าเริ่มต้น 10 นาที
_G.PotionRepeatCount = 999
_G.PotionTimer = 0 -- ตัวนับถอยหลังภายใน

Autos:AddToggle("EnableAutoPotion", {Title = "เปิดใช้งาน Auto Potion", Default = false }):OnChanged(function(Value)
    _G.AutoPotion = Value
    if Value then 
        _G.PotionTimer = 0 -- เปิดปุ๊บให้กินรอบแรกทันที
    end
end)

Autos:AddDropdown("PotionSelect", {
    Title = "เลือก Potion",
    Values = PotionList,
    Multi = false,
    Default = 1,
}):OnChanged(function(Value)
    _G.SelectedPotion = Value
end)

Autos:AddInput("PotionTimeInput", {
    Title = "ระยะเวลาบัฟ (นาที)",
    Default = "16",
    Numeric = true,
    Callback = function(Value)
        _G.PotionDelayMinutes = tonumber(Value) or 16
    end
})

Autos:AddInput("PotionCountInput", {
    Title = "จำนวนครั้งที่ทำซ้ำ",
    Default = "999",
    Numeric = true,
    Callback = function(Value)
        _G.PotionRepeatCount = tonumber(Value) or 999
    end
})


-- 🏃 CHARACTER
Tabs.Character:AddToggle("ESPEnabled", {Title = "Enable Player ESP", Default = false }):OnChanged(function() 
    _G.ESPEnabled = Options.ESPEnabled.Value 
    if not _G.ESPEnabled then ESPHolder:ClearAllChildren() end
end)
Tabs.Character:AddToggle("WalkSpeedEnabled", {Title = "Enable Walk Speed", Default = false }):OnChanged(function() _G.WalkSpeedEnabled = Options.WalkSpeedEnabled.Value end)
Tabs.Character:AddInput("WalkSpeedVal", {Title = "Speed Value", Default = "16", Numeric = true, Callback = function(V) _G.WalkSpeed = tonumber(V) or 16 end})
Tabs.Character:AddToggle("JumpPowerEnabled", {Title = "Enable Jump Power", Default = false }):OnChanged(function() _G.JumpPowerEnabled = Options.JumpPowerEnabled.Value end)
Tabs.Character:AddInput("JumpPowerVal", {Title = "Jump Value", Default = "50", Numeric = true, Callback = function(V) _G.JumpPower = tonumber(V) or 50 end})
Tabs.Character:AddToggle("Noclip", {Title = "Noclip", Default = false }):OnChanged(function() _G.Noclip = Options.Noclip.Value end)
Tabs.Character:AddToggle("DashEnabled", {Title = "Enable Dash", Default = true }):OnChanged(function() _G.DashEnabled = Options.DashEnabled.Value end)
Tabs.Character:AddSlider("DashSpeed", {Title = "Dash Speed", Default = 100, Min = 50, Max = 300, Rounding = 0, Callback = function(V) _G.DashSpeed = V end})
Tabs.Character:AddToggle("FlyEnabled", {Title = "Enable Fly", Default = true }):OnChanged(function() _G.FlyEnabled = Options.FlyEnabled.Value end)
Tabs.Character:AddToggle("FlyInertia", {Title = "Fly Inertia", Default = true }):OnChanged(function() _G.FlyInertia = Options.FlyInertia.Value end)
Tabs.Character:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 75, Min = 10, Max = 300, Rounding = 0, Callback = function(V) _G.FlySpeed = V end})
-- ใส่ต่อจาก Slider Fly Speed เดิม
Tabs.Character:AddParagraph({ Title = "Mobile Support", Content = "เครื่องมือสำหรับมือถือ" })

Tabs.Character:AddToggle("ShowFlyPanel", {Title = "Show Fly Panel (Mobile)", Default = false }):OnChanged(function(Value)
    if FlyGui then
        FlyGui.Enabled = Value
        -- ถ้าปิด Panel ให้ปิดโหมดบินไปด้วยเพื่อความปลอดภัย (หรือจะเอาออกก็ได้ถ้าอยากให้บินค้าง)
        if not Value and _G.IsFlying then
            -- _G.IsFlying = false -- ปลดบรรทัดนี้ออกถ้าอยากปิดหน้าต่างแต่ยังบินอยู่
        end
    end
end)
-- 🗺️ TELEPORT
local DropdownManager, DropdownWarp
local function RefreshAllDropdowns()
    local saved = LoadCustomLocations()
    local managerList, warpList = {}, {}
    local mQuery, wQuery = _G.ManagerSearch:lower(), _G.SearchQuery:lower()
    for name, _ in pairs(saved) do
        if mQuery == "" or name:lower():find(mQuery) then table.insert(managerList, name) end
        if wQuery == "" or name:lower():find(wQuery) then table.insert(warpList, name) end
    end
    for name, _ in pairs(DefaultLocations) do
        if wQuery == "" or name:lower():find(wQuery) then table.insert(warpList, name) end
    end
    table.sort(managerList); table.sort(warpList)
    if DropdownManager then DropdownManager:SetValues(managerList) end
    if DropdownWarp then DropdownWarp:SetValues(warpList) end
end

Tabs.Teleport:AddButton({Title = "🔄 Refresh Lists", Callback = function() RefreshAllDropdowns(); Fluent:Notify({Title="Teleport", Content="Refreshed!", Duration=1}) end})
Tabs.Teleport:AddInput("ManagerSearch", {Title = "🔍 Search Saved", Default = "", Callback = function(V) _G.ManagerSearch = V; RefreshAllDropdowns() end})
DropdownManager = Tabs.Teleport:AddDropdown("ManagerSelect", {Title = "📂 Select Saved", Values = {}, Multi = false, Default = nil})
DropdownManager:OnChanged(function(Value)
    local saved = LoadCustomLocations()
    if Value and saved[Value] then
        _G.CustomName = Value
        _G.CustomX, _G.CustomY, _G.CustomZ = saved[Value].x, saved[Value].y, saved[Value].z
        Options.LocName:SetValue(Value); Options.InputX:SetValue(tostring(_G.CustomX)); Options.InputY:SetValue(tostring(_G.CustomY)); Options.InputZ:SetValue(tostring(_G.CustomZ))
    end
end)
Tabs.Teleport:AddInput("LocName", {Title = "Name", Default = "", Callback = function(V) _G.CustomName = V end})
Tabs.Teleport:AddInput("InputX", {Title = "X", Default = "0", Numeric = true, Callback = function(V) _G.CustomX = V end})
Tabs.Teleport:AddInput("InputY", {Title = "Y", Default = "135", Numeric = true, Callback = function(V) _G.CustomY = V end})
Tabs.Teleport:AddInput("InputZ", {Title = "Z", Default = "0", Numeric = true, Callback = function(V) _G.CustomZ = V end})
Tabs.Teleport:AddButton({Title = "📍 Get Position", Callback = function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        _G.CustomX, _G.CustomY, _G.CustomZ = math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
        Options.InputX:SetValue(tostring(_G.CustomX)); Options.InputY:SetValue(tostring(_G.CustomY)); Options.InputZ:SetValue(tostring(_G.CustomZ))
    end
end})
Tabs.Teleport:AddButton({Title = "💾 Save", Callback = function()
    if _G.CustomName == "" then return end
    local saved = LoadCustomLocations()
    saved[_G.CustomName] = {x = tonumber(_G.CustomX), y = tonumber(_G.CustomY), z = tonumber(_G.CustomZ)}
    SaveCustomLocations(saved); RefreshAllDropdowns()
end})
Tabs.Teleport:AddButton({Title = "🚀 Warp to XYZ", Callback = function()
    if _G.StopAll then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local tp = CFrame.new(tonumber(_G.CustomX) or 0, tonumber(_G.CustomY) or 135, tonumber(_G.CustomZ) or 0)
        char.HumanoidRootPart.CFrame = tp
        if _G.AutoFish then currentSpot = tp end
    end
end})
Tabs.Teleport:AddInput("SearchLoc", {Title = "🔍 Search Warp", Default = "", Callback = function(V) _G.SearchQuery = V; RefreshAllDropdowns() end})
DropdownWarp = Tabs.Teleport:AddDropdown("IslandWarp", {Title = "📂 Select Destination", Values = {}, Multi = false, Default = nil})
DropdownWarp:OnChanged(function(Value)
    if _G.StopAll or not Value then return end
    local target, saved = DefaultLocations[Value], LoadCustomLocations()
    if not target and saved[Value] then target = saved[Value] end
    if target then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local tp = CFrame.new(target.x, target.y, target.z)
            char.HumanoidRootPart.CFrame = tp
            if _G.AutoFish then currentSpot = tp end
        end
    end
end)
-- [[ 🧍 TELEPORT TO PLAYER ]] --
Tabs.Teleport:AddParagraph({ Title = "-----------------", Content = "" })
Tabs.Teleport:AddParagraph({ Title = "Player Teleport", Content = "วาร์ปไปหาผู้เล่นอื่นในเซิร์ฟ" })

local PlayerDropdown = Tabs.Teleport:AddDropdown("PlayerSelect", {
    Title = "เลือกผู้เล่น (Select Player)",
    Values = {},
    Multi = false,
    Default = nil,
})

-- ฟังก์ชันดึงรายชื่อคน
local function RefreshPlayerList()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(pList, p.Name)
        end
    end
    table.sort(pList)
    PlayerDropdown:SetValues(pList)
end

Tabs.Teleport:AddButton({
    Title = "🔄 Refresh Players List",
    Description = "กดเพื่อรีเฟรชรายชื่อคน",
    Callback = function()
        RefreshPlayerList()
        Fluent:Notify({Title = "System", Content = "Updated Player List!", Duration = 1})
    end
})

Tabs.Teleport:AddButton({
    Title = "🚀 Warp to Player",
    Description = "วาร์ปไปหาคนที่เลือก",
    Callback = function()
        local targetName = Options.PlayerSelect.Value
        if not targetName then return end
        
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- วาร์ปไปที่ตัวคนนั้น
                char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0) -- สูงขึ้นนิดนึงกันบัคจมดิน
                
                -- อัปเดตจุด AFK (ถ้าเปิด Auto Fish อยู่)
                if _G.AutoFish then currentSpot = char.HumanoidRootPart.CFrame end
                
                Fluent:Notify({Title = "Teleport", Content = "Warped to: " .. targetName, Duration = 2})
            end
        else
            Fluent:Notify({Title = "Error", Content = "หาตัวผู้เล่นไม่เจอ หรือเขาตายอยู่", Duration = 3})
        end
    end
})

-- สั่งรีเฟรช 1 ครั้งตอนเริ่ม
task.delay(1, function() RefreshPlayerList() end)
-- 🛒 SHOP
local RodNames = {}
for _, v in ipairs(RodList) do table.insert(RodNames, v.Name) end
Tabs.Shop:AddDropdown("SelectedRod", {Title = "Select Rod", Values = RodNames, Multi = false, Default = 1})
Tabs.Shop:AddButton({Title = "Buy Rod", Callback = function() 
    local remote = GetPurchaseRemote()
    if remote then
        remote:FireServer(Options.SelectedRod.Value, "Rod", nil, 1) 
    else
        Fluent:Notify({Title = "Error", Content = "Purchase remote not found", Duration = 3})
    end
end})

local Visuals = Tabs.Visuals
Visuals:AddParagraph({ Title = "UI Visibility", Content = "ตั้งค่าการแสดงผล/ซ่อนปุ่มต่างๆ" })
Visuals:AddToggle("HideShakeUI", {Title = "Hide Shake UI (Stealth)", Default = false }):OnChanged(function() 
    _G.HideShakeUI = Options.HideShakeUI.Value 
end)

-- Tabs.Shop:AddButton({
--     Title = "BUY ALL AFFORDABLE RODS",
--     Description = "Buys all rods you can afford & don't own",
--     Callback = function()
--         local currentMoney = getMoney()
--         local remote = GetPurchaseRemote()
--         if not remote then 
--             Fluent:Notify({Title = "Error", Content = "Purchase remote not found", Duration = 3})
--             return 
--         end
--         local boughtCount = 0
--         for _, rod in ipairs(RodList) do
--             if not hasItem(rod.Name) and currentMoney >= rod.Price then
--                 remote:FireServer(rod.Name, "Rod", nil, 1)
--                 boughtCount = boughtCount + 1
--                 task.wait(0.2)
--             end
--         end
--         if boughtCount > 0 then
--              Fluent:Notify({Title = "Shop", Content = "Bought " .. boughtCount .. " rods!", Duration = 3})
--         else
--              Fluent:Notify({Title = "Shop", Content = "No affordable rods found or you own them all.", Duration = 3})
--         end
--     end
-- })

-- Buy Totem Section
Tabs.Shop:AddDropdown("SelectedTotem", {Title = "Select Totem", Values = TotemList, Multi = false, Default = 1})
Tabs.Shop:AddInput("TotemAmount", {Title = "Amount", Default = "1", Numeric = true})
Tabs.Shop:AddButton({Title = "Buy Totem", Callback = function()
    local selectedName = Options.SelectedTotem.Value
    local amount = math.clamp(tonumber(Options.TotemAmount.Value) or 1, 1, 50)
    
    local pricePerItem = 0
    for _, v in ipairs(TotemData) do
        if v.Name == selectedName then pricePerItem = v.Price; break end
    end
    
    local totalPrice = pricePerItem * amount
    local currentMoney = getMoney()
    
    if currentMoney >= totalPrice then
        local remote = GetPurchaseRemote()
        if remote then
            -- "Item" category confirmed for totems
            remote:FireServer(selectedName, "Item", nil, amount)
            Fluent:Notify({Title = "Success", Content = "Bought " .. amount .. " " .. selectedName, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Purchase remote not found", Duration = 3})
        end
    else
        Fluent:Notify({Title = "Failed", Content = "Not enough money! Need: " .. totalPrice, Duration = 5})
    end
end})

-- ⚙️ SETTINGS
Tabs.Settings:AddToggle("AntiAFK", {Title = "Enable Anti AFK", Default = true }):OnChanged(function() _G.AntiAFK = Options.AntiAFK.Value end)
Tabs.Settings:AddToggle("AlwaysPerfect", {Title = "Always Perfect Catch", Default = true }):OnChanged(function() _G.AlwaysPerfect = Options.AlwaysPerfect.Value end)
Tabs.Settings:AddToggle("FrozenBar", {Title = "Frozen Bar (Visual)", Default = true }):OnChanged(function() _G.FrozenBar = Options.FrozenBar.Value end)
Tabs.Settings:AddSlider("ReelDelay", {Title = "Delay After Bite", Default = 2.5, Min = 0.0, Max = 10.0, Rounding = 1, Callback = function(V) _G.ReelDelay = V end})
Tabs.Settings:AddSlider("CastDelay", {Title = "Cooldown After Catch", Default = 0.5, Min = 0.1, Max = 2.0, Rounding = 1, Callback = function(V) _G.CastDelay = V end})
Tabs.Settings:AddButton({Title = "🔄 Rejoin Server", Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end})
Tabs.Settings:AddButton({Title = "⏩ Server Hop", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end})
Tabs.Settings:AddParagraph({ Title = "Log Panel", Content = "หน้าต่างแสดงสถานะการทำงาน" })
Tabs.Settings:AddToggle("ShowLogPanel", {Title = "Show Log Panel", Default = false }):OnChanged(function(Value)
    if LogGui then
        LogGui.Enabled = Value
    end
end)

Tabs.Settings:AddButton({Title = "Clear Logs", Callback = function()
    for _, child in pairs(LogScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    LogScroll.CanvasSize = UDim2.new(0,0,0,0)
    _G.AddLog("Logs cleared.", Color3.fromRGB(255, 255, 0))
end})

-- [[ 📉 PERFORMANCE & FPS BOOST ]] --
Tabs.Settings:AddParagraph({ Title = "-----------------", Content = "" })
Tabs.Settings:AddParagraph({ Title = "Performance & FPS", Content = "เครื่องมือช่วยลดแลค และลดการทำงานเครื่อง" })

-- 1. ปุ่มลบ Texture และ Effect (กดทีเดียว)
Tabs.Settings:AddButton({
    Title = "📉 Remove Textures & Effects",
    Description = "ปรับภาพให้เป็นดินน้ำมัน + ลบเอฟเฟกต์ (FPS Boost)",
    Callback = function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 2
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy() -- ลบลวดลาย
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false -- ปิดเอฟเฟกต์
            end
        end
        
        Fluent:Notify({Title = "FPS Boost", Content = "Textures & Effects Removed!", Duration = 3})
    end
})

-- 2. Toggle ปิดหมอก / แสงสว่าง (Full Bright)
Tabs.Settings:AddToggle("FullBright", {Title = "☀️ Full Bright (No Fog)", Default = false }):OnChanged(function(Value)
    if Value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

-- 3. Toggle โหมดประหยัดสุดขีด (ปิด 3D Rendering)
Tabs.Settings:AddToggle("SuperLowMode", {Title = "⚫ 3D Render Disable (Super AFK)", Default = false }):OnChanged(function(Value)
    local RunService = game:GetService("RunService")
    
    -- ใช้ Set3dRenderingEnabled เพื่อหยุดการวาดภาพ 3D (จอดำ/ขาว แต่เกมยังรันอยู่)
    -- วิธีนี้ลดการทำงาน GPU ได้ดีที่สุด
    RunService:Set3dRenderingEnabled(not Value)
    
    if Value then
        Fluent:Notify({Title = "AFK Mode", Content = "ปิดการแสดงผล 3D แล้ว (ประหยัด GPU)", Duration = 3})
    else
        Fluent:Notify({Title = "AFK Mode", Content = "กลับสู่โหมดปกติ", Duration = 3})
    end
end)

-- 4. ปุ่มล็อก FPS (Optional)
Tabs.Settings:AddInput("FPSCap", {
    Title = "🔒 Max FPS Cap",
    Default = "60",
    Numeric = true,
    Callback = function(Value)
        setfpscap(tonumber(Value) or 60)
    end
})
-- 🛠️ MAIN LOOPS & EVENTS
-- [LOGIC: AUTO POTION (PRIORITY MODE)]
task.spawn(function()
    while true do
        task.wait(1)
        
        -- เช็คเงื่อนไขพื้นฐาน
        if _G.AutoPotion and not _G.StopAll and _G.PotionRepeatCount > 0 then
            
            -- ถ้านับถอยหลังหมดแล้ว
            if _G.PotionTimer <= 0 then
                local potionName = _G.SelectedPotion
                
                -- เช็คว่ามีของในตัวไหม
                if hasItem(potionName) then
                    
                    -- 1. ประกาศหยุดตกปลา (Hard Stop)
                    local wasFishing = _G.AutoFish
                    if wasFishing then
                        _G.AutoFish = false
                        if Options.AutoFish then Options.AutoFish:SetValue(false) end
                        
                        Fluent:Notify({Title = "Auto Potion", Content = "หยุดตกปลาเพื่อดื่มยา...", Duration = 2})
                        task.wait(2) -- รอให้ลูปตกปลาหยุดสนิท
                    end

                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if char and hum and hum.Health > 0 then
                        -- 2. เคลียร์มือให้ว่าง (บังคับเก็บเบ็ด)
                        for i = 1, 5 do
                            if char:FindFirstChildWhichIsA("Tool") then
                                hum:UnequipTools()
                                task.wait(0.2)
                            else
                                break
                            end
                        end
                        
                        -- 3. พยายามถือและดื่มยา
                        local potionTool = LocalPlayer.Backpack:FindFirstChild(potionName) or char:FindFirstChild(potionName)
                        
                        if potionTool then
                            hum:EquipTool(potionTool)
                            task.wait(0.8) -- รออนิเมชั่นถือ
                            
                            -- เช็คว่าถือติดจริงไหม (กันพลาด)
                            local heldItem = char:FindFirstChildWhichIsA("Tool")
                            if heldItem and heldItem.Name == potionName then
                                Fluent:Notify({Title = "Auto Potion", Content = "🧪 กำลังดื่ม: " .. potionName, Duration = 3})
                                
                                -- คลิกดื่ม
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait(0.2)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                
                                task.wait(2.5) -- รออนิเมชั่นดื่มจนเสร็จ
                                hum:UnequipTools()
                                
                                -- สำเร็จ: รีเซ็ตเวลาและลดจำนวน
                                _G.PotionRepeatCount = _G.PotionRepeatCount - 1
                                _G.PotionTimer = _G.PotionDelayMinutes * 60
                                
                                if _G.AddLog then
                                    _G.AddLog("Drank: " .. potionName, Color3.fromRGB(100, 255, 100))
                                end
                            else
                                -- ถ้าถือไม่ติด (โดนแย่ง) ให้รอแล้ววนมาทำใหม่รอบหน้า (Timer ไม่ถูกรีเซ็ต)
                                Fluent:Notify({Title = "Auto Potion", Content = "⚠️ ถือของไม่ติด! กำลังลองใหม่...", Duration = 2})
                                hum:UnequipTools()
                            end
                        end
                    end
                    
                    -- 4. กลับไปตกปลา (ถ้าเดิมเปิดไว้)
                    if wasFishing then
                        task.wait(1)
                        _G.AutoFish = true
                        if Options.AutoFish then Options.AutoFish:SetValue(true) end
                        
                        -- ช่วยถือเบ็ดกลับคืน
                        local rod = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                        if not rod then 
                            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if v:IsA("Tool") and v.Name:find("Rod") then rod = v; break end
                            end
                        end
                        if rod then hum:EquipTool(rod) end
                    end
                    
                else
                    -- ถ้าไม่มีของ: แจ้งเตือนและรอ 10 วิค่อยเช็คใหม่ (ไม่ลด Timer เพื่อให้กินทันทีที่ซื้อของมา)
                    Fluent:Notify({Title = "Auto Potion", Content = "หา " .. potionName .. " ไม่เจอ!", Duration = 3})
                    task.wait(5)
                end
            else
                -- นับถอยหลังตามปกติ
                _G.PotionTimer = _G.PotionTimer - 1
            end
        end
    end
end)

-- [[ ℹ️ SERVER INFO TAB ]] --
local InfoTab = Tabs.ServerInfo

-- ปุ่มเปิด/ปิด Panel ลอย
InfoTab:AddToggle("ShowInfoPanel", {Title = "Show Info Panel Overlay", Default = true }):OnChanged(function(Value)
    if InfoGui then
        InfoGui.Enabled = Value
    end
end)

InfoTab:AddParagraph({ Title = "---", Content = "" }) -- ขีดคั่นสวยๆ

-- Paragraph เดิมใน Menu (เก็บไว้ดูในเมนูได้เหมือนเดิม)
local RealTimePara = InfoTab:AddParagraph({ Title = "🕒 เวลาชีวิตจริง (Real Time)", Content = "Loading..." })
local GameTimePara = InfoTab:AddParagraph({ Title = "☀️ เวลาในเกม (Game Time)", Content = "Loading..." })
local UptimePara = InfoTab:AddParagraph({ Title = "⏳ เซิร์ฟเวอร์เปิดมาแล้ว (Server Uptime)", Content = "Loading..." })


-- [[ ฟังก์ชันแปลงเวลา ]] --
local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function FormatGameTime(clockTime)
    local hours = math.floor(clockTime)
    local minutes = math.floor((clockTime - hours) * 60)
    return string.format("%02d:%02d", hours, minutes)
end

-- [[ ลูปอัปเดตข้อมูล (Update Loop) ]] --
task.spawn(function()
    while true do
        -- 1. Real Time
        local statusTime = os.date("%H:%M:%S")
        
        -- 2. Game Time (แก้ใหม่ให้เป็น HH:MM)
        local clockTime = game:GetService("Lighting").ClockTime
        local timeState = (clockTime >= 6 and clockTime < 18) and "Day ☀️" or "Night 🌙"
        local gameTimeStr = FormatGameTime(clockTime) .. " " .. timeState

        -- 3. Server Uptime
        local serverTime = workspace.DistributedGameTime
        local uptimeStr = FormatTime(serverTime)

        -- [[ อัปเดตใน Fluent Menu (Tab) ]] --
        if RealTimePara then RealTimePara:SetDesc(statusTime) end
        if GameTimePara then GameTimePara:SetDesc(gameTimeStr) end
        if UptimePara then UptimePara:SetDesc(uptimeStr) end

        -- [[ อัปเดตใน Floating Panel (GUI) ]] --
        if InfoGui and InfoGui.Enabled then
            RealTimeLabel.Text = "🕒 เวลาชีวิตจริง:  " .. statusTime
            GameTimeLabel.Text = "🗓️ เวลาในเกม: " .. gameTimeStr
            UptimeLabel.Text   = "⏳ เวลาที่คุณออนเกม:    " .. uptimeStr
            
            -- เปลี่ยนสีข้อความตามเวลา
            if timeState == "Day ☀️" then
                GameTimeLabel.TextColor3 = Color3.fromRGB(255, 220, 100) -- เหลือง
            else
                GameTimeLabel.TextColor3 = Color3.fromRGB(100, 150, 255) -- ฟ้า
            end
        end

        task.wait(1)
    end
end)

-- [AUTO SELL ALL LOOP]
task.spawn(function()
    while true do
        if _G.AutoSellAll and not _G.StopAll then
            local remote = FindSellAllRemote()
            if remote then
                pcall(function() remote:InvokeServer() end)
            end
            task.wait(_G.SellAllInterval or 5)
        else
            task.wait(1)
        end
    end
end)

LocalPlayer.Idled:Connect(function() if _G.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    keysDown[input.KeyCode] = true
    if input.KeyCode == Enum.KeyCode.Q then 
        if _G.DashEnabled and not _G.StopAll then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local moveDir = char.Humanoid.MoveDirection
                if moveDir.Magnitude == 0 then moveDir = hrp.CFrame.LookVector end
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DashVelocity"; bv.Velocity = moveDir * _G.DashSpeed; bv.MaxForce = Vector3.new(1e5, 0, 1e5); bv.P = 5000; bv.Parent = hrp
                Debris:AddItem(bv, 0.25)
            end
        end
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then _G.BoostEnabled = not _G.BoostEnabled end
    if input.KeyCode == Enum.KeyCode.Space and _G.FlyEnabled and not _G.StopAll then
        if (tick() - lastSpacePress) < 0.3 then
            _G.IsFlying = not _G.IsFlying
            currentFlyVelocity = Vector3.new(0, 0, 0)
            if not _G.IsFlying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
        end
        lastSpacePress = tick()
    end
end)
UserInputService.InputEnded:Connect(function(input) keysDown[input.KeyCode] = nil end)

RunService.RenderStepped:Connect(function()
    if _G.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local espBox = ESPHolder:FindFirstChild(player.Name)
                if not espBox then
                    espBox = Instance.new("BillboardGui", ESPHolder); espBox.Name = player.Name; espBox.Size = UDim2.new(0, 100, 0, 50); espBox.StudsOffset = Vector3.new(0, 2, 0); espBox.AlwaysOnTop = true
                    local nl = Instance.new("TextLabel", espBox); nl.Name = "NameLabel"; nl.Size = UDim2.new(1,0,1,0); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.white; nl.TextStrokeTransparency = 0; nl.TextSize = 14; nl.Font = Enum.Font.SourceSansBold
                    local dl = Instance.new("TextLabel", espBox); dl.Name = "DistLabel"; dl.Size = UDim2.new(1,0,0.5,0); dl.Position = UDim2.new(0,0,0.8,0); dl.BackgroundTransparency = 1; dl.TextColor3 = Color3.new(0.8,0.8,0.8); dl.TextStrokeTransparency = 0; dl.TextSize = 12; dl.Font = Enum.Font.SourceSans
                end
                if espBox.Adornee ~= head then espBox.Adornee = head end
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myRoot and (myRoot.Position - head.Position).Magnitude or 0
                espBox.NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"; espBox.DistLabel.Text = math.floor(dist) .. " m"
            else
                if ESPHolder:FindFirstChild(player.Name) then ESPHolder[player.Name]:Destroy() end
            end
        end
    elseif #ESPHolder:GetChildren() > 0 then ESPHolder:ClearAllChildren() end

    if _G.StopAll then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
    if _G.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    
    if _G.IsFlying and hrp and hum then
        hum.PlatformStand = true; hum.AutoRotate = false
        local bv = hrp:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", hrp); bv.Name = "FlyVelocity"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local bg = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", hrp); bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        local moveDir = hum.MoveDirection
        local cam = workspace.CurrentCamera
        if moveDir.Magnitude > 0 then
            local lookY = cam.CFrame.LookVector.Y; moveDir = Vector3.new(moveDir.X, moveDir.Y + (lookY * 2), moveDir.Z).Unit
        end
        if keysDown[Enum.KeyCode.Space] or _G.MobileFlyUp then moveDir = moveDir + Vector3.new(0, 1, 0) end
        local speed = _G.FlySpeed * (_G.BoostEnabled and 2.5 or 1.0)
        if moveDir.Magnitude > 0 then
            currentFlyVelocity = currentFlyVelocity:Lerp(moveDir.Unit * speed, 0.2)
            bg.CFrame = bg.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + currentFlyVelocity) * CFrame.Angles(math.rad(-90), 0, 0), 0.2)
        else
            currentFlyVelocity = _G.FlyInertia and currentFlyVelocity:Lerp(Vector3.zero, 0.05) or Vector3.zero
            local forward = cam.CFrame.LookVector
            bg.CFrame = bg.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(forward.X, 0, forward.Z)), 0.1)
        end
        bv.Velocity = currentFlyVelocity
    else
        if hrp and hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp and hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if hum then hum.PlatformStand = false; hum.AutoRotate = true end
    end
    
    if _G.AutoFish and _G.LockPosition and currentSpot and not _G.IsFlying and hrp then hrp.CFrame = currentSpot; hrp.Velocity = Vector3.zero end
    if hum and not _G.IsFlying then
        if _G.WalkSpeedEnabled then hum.WalkSpeed = _G.WalkSpeed end
        if _G.JumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = _G.JumpPower end
    end
    
    if _G.AutoFish and _G.FrozenBar then
        local bar = LocalPlayer.PlayerGui:FindFirstChild("reel") and LocalPlayer.PlayerGui.reel:FindFirstChild("bar")
        if bar and bar:FindFirstChild("playerbar") then
            bar.playerbar.Size = UDim2.new(1,0,1,0); bar.playerbar.Position = UDim2.new(0,0,0,0); bar.playerbar.AnchorPoint = Vector2.new(0,0); bar.playerbar.BackgroundColor3 = Color3.new(1,1,1)
        end
    end

    if ToggleFlyBtn then
    if _G.IsFlying and ToggleFlyBtn.Text ~= "ON" then
        ToggleFlyBtn.Text = "ON"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    elseif not _G.IsFlying and ToggleFlyBtn.Text ~= "OFF" then
        ToggleFlyBtn.Text = "OFF"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end
end)

-- 🎣 CORE AUTO FISH (LAG-PROOF)
local function FindRemote(name)
    local target = ReplicatedStorage:FindFirstChild("packages")
    if target and target:FindFirstChild("Net") then
        local re = target.Net:FindFirstChild("RE/"..name)
        if re then return re end
    end
    return nil
end

local function CleanStack()
    local pg = LocalPlayer.PlayerGui
    if pg:FindFirstChild("reel") then pg.reel:Destroy() end
    if pg:FindFirstChild("shakeui") then pg.shakeui:Destroy() end
end


local function ForceEquipRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name:lower():find("rod") then return tool end
    local backpack = LocalPlayer.Backpack
    local rod = nil
    for _, v in pairs(backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then rod = v; break end
    end
    if rod then
        char.Humanoid:EquipTool(rod); task.wait(0.2); return char:FindFirstChildWhichIsA("Tool")
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game); task.wait(0.3); return char:FindFirstChildWhichIsA("Tool")
    end
end

local function IsUIActive()
    local pg = LocalPlayer.PlayerGui
    local hasShake = pg:FindFirstChild("shakeui") and pg.shakeui.Enabled
    local hasReel = pg:FindFirstChild("reel") and pg.reel.Enabled
    return hasShake or hasReel
end

local function FastShake(obj)
    if not _G.AutoShake then return end

    if obj.Name == "shake" and obj:IsA("RemoteEvent") then
        local parentUI = obj.Parent
        if parentUI and parentUI:IsA("GuiObject") then
            if _G.HideShakeUI then
                parentUI.Visible = false
            else
                parentUI.Visible = true
            end
        end

        obj:FireServer()
        task.delay(0.1, function()
            obj:FireServer()
        end)
    end
end

LocalPlayer.PlayerGui.DescendantAdded:Connect(FastShake)
for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
    FastShake(v)
end

task.spawn(function()
    local finishRemote = FindRemote("Reel/Finish")
    while true do
        task.wait(0.1)
        
        if not _G.StopAll and _G.AutoFish then
            local char = LocalPlayer.Character
            if not char then continue end
            
            -- เช็คเครื่องมือ
            local currentTool = char:FindFirstChildWhichIsA("Tool")
            if currentTool and currentTool.Name:lower():find("rod") then
                if not IsUIActive() then
                    char.Humanoid:UnequipTools(); task.wait(0.1)
                end
            end
            
            local rod = ForceEquipRod()
            if rod and rod:FindFirstChild("events") then
                local castRemote = rod.events:FindFirstChild("castAsync")
                if castRemote then
                    -- 1. เหวี่ยงเบ็ด
                    local castSuccess = pcall(function() castRemote:InvokeServer(100, 1, false) end)
                    if not castSuccess then warn("Cast failed, retrying..."); continue end
                    
                    local fishBited = false
                    local startTime = tick()
                    local lastActiveTime = tick()
                    
                    local maxTotalWait = 30
                    local noActivityTimeout = 3.5
                    
                    while _G.AutoFish and not _G.StopAll do
                        local currentTime = tick()
                        
                        if IsUIActive() then
                            lastActiveTime = currentTime
                        end
                        
                        if char.Humanoid.MoveDirection.Magnitude > 0 then
                            lastActiveTime = currentTime
                        end

                        if LocalPlayer.PlayerGui:FindFirstChild("reel") then 
                            fishBited = true 
                            break 
                        end
                        
                        -- E. เงื่อนไขจบ: เบ็ดหลุดมือ
                        if not char:FindFirstChild(rod.Name) then break end
                        
                        -- [[ F. ระบบตัดบัค (Smart Timeout) ]] --
                        
                        -- 1. ถ้าเงียบกริบ (ไม่มี UI, ไม่ได้กด Shake, ไม่เดิน) เกิน 8 วิ -> ตัดจบ (Reset)
                        if currentTime - lastActiveTime > noActivityTimeout then
                            -- _G.AddLog("⚠️ Reset: No Activity (Bugged)", Color3.fromRGB(255, 100, 100))
                            break 
                        end
                        
                        -- 2. ถ้ารอนานเกินไปจริงๆ (30 วิ) -> ตัดจบ
                        if currentTime - startTime > maxTotalWait then
                            break
                        end
                        
                        task.wait(0.05) -- ลูปย่อยทำงานไวขึ้น
                    end
                    
                    -- 2. ถ้าปลามาแล้ว ดึง
                    if fishBited then
                        task.wait(_G.ReelDelay)
                        if finishRemote then
                            pcall(function() finishRemote:FireServer({ ["e"] = 100, ["p"] = _G.AlwaysPerfect, ["l"] = {} }) end)
                            _G.AddLog("🎣 Fish Caught!", Color3.fromRGB(0, 255, 255))
                        end
                    end
                    
                    task.wait(_G.CastDelay)
                    CleanStack()
                    if char:FindFirstChild("Humanoid") then char.Humanoid:UnequipTools() end
                end
            end
        end
    end
end)

-- [LOGIC: SMART AUTO TOTEM - AGGRESSIVE MODE]
task.spawn(function()
    local currentPeriodStatus = nil 
    local hasUsedTotem = false 
    local hasFixedEclipse = false 
    local lastGameTime = -1       
    local lastRealTime = tick()
    
    -- ตัวแปรกันตีกัน
    _G.ProcessingTotem = false

    local function UseTotemItem(name, reason)
        if not hasItem(name) then return false end
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        -- 1. ประกาศสถานะว่ากำลังทำงาน (เพื่อให้ส่วนอื่นหยุด)
        _G.ProcessingTotem = true
        
        -- 2. สั่งหยุดตกปลาแบบหักดิบ
        local wasFishing = _G.AutoFish
        if wasFishing then
            _G.AutoFish = false
            if Options.AutoFish then Options.AutoFish:SetValue(false) end
            
            -- เคลียร์เบ็ดออกจากมือ (ทำซ้ำจนกว่าจะหลุด)
            local attempts = 0
            repeat
                hum:UnequipTools()
                task.wait(0.2)
                attempts = attempts + 1
            until not char:FindFirstChildWhichIsA("Tool") or attempts > 10
            
            task.wait(0.5) -- รอให้ server รับรู้ว่ามือว่าง
        end

        local success = false
        local totem = LocalPlayer.Backpack:FindFirstChild(name)
        if not totem then totem = char:FindFirstChild(name) end

        if totem then
            Fluent:Notify({Title = "Auto Totem", Content = "⏳ กำลังใช้: " .. name, Duration = 2})
            
            -- 3. พยายามถือ Totem
            hum:EquipTool(totem)
            task.wait(1) 
            
            -- 4. [สำคัญ] เช็ควินาทีสุดท้ายว่าถือ Totem อยู่จริงไหม?
            -- ถ้าตอนนนี้ถือเบ็ดอยู่ (โดนแย่ง) จะไม่กดใช้ และ return false เพื่อให้ลองใหม่
            local heldItem = char:FindFirstChildWhichIsA("Tool")
            
            if heldItem and heldItem.Name == name then
                -- ถือถูกอันแล้ว -> กดใช้
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.2)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                Fluent:Notify({Title = "Auto Totem", Content = "ใช้สำเร็จ!", Duration = 3})
                task.wait(2.5) -- รออนิเมชั่น Totem
                hum:UnequipTools()
                success = true
            else
                -- ถือผิดอัน (โดนเบ็ดแย่ง) -> แจ้งเตือนและส่งกลับค่า False
                Fluent:Notify({Title = "Auto Totem", Content = "โดนขัดจังหวะ! กำลังลองใหม่...", Duration = 2})
                success = false
            end
        end

        -- 5. คืนค่าสถานะ และกลับไปตกปลา
        _G.ProcessingTotem = false
        
        if wasFishing then
            task.wait(0.5)
            _G.AutoFish = true
            if Options.AutoFish then Options.AutoFish:SetValue(true) end
            
            -- ช่วยถือเบ็ดกลับคืน
            local rod = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") -- หาของชิ้นแรก (มักจะเป็นเบ็ด)
            if not rod then 
                -- ถ้าหาไม่เจอ ลองวนหาที่มีคำว่า Rod
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Rod") then rod = v; break end
                end
            end
            if rod then hum:EquipTool(rod) end
        end
        
        return success
    end

    while true do
        task.wait(1)
        
        if _G.AutoTotem and not _G.StopAll then
            local Lighting = game:GetService("Lighting")
            local currentTime = Lighting.ClockTime
            
            -- เช็คเวลาค้าง (Eclipse Fix)
            if currentTime ~= lastGameTime then
                lastGameTime = currentTime
                lastRealTime = tick()
            end
            local timeFrozen = tick() - lastRealTime

            -- [Case 1] แก้บัค Eclipse
            if currentTime >= 2.0 and currentTime <= 2.3 and timeFrozen > 10 then 
                if not hasFixedEclipse then
                    if UseTotemItem(_G.DayTotemSelect, "Fix Eclipse") then
                        hasFixedEclipse = true
                        lastRealTime = tick()
                        task.wait(10)
                        currentPeriodStatus = nil 
                        hasUsedTotem = false      
                    end
                end
            else
                hasFixedEclipse = false
            end
            
            -- [Case 2] เปลี่ยนเวลาปกติ
            if not hasFixedEclipse then
                local newPeriod = (currentTime >= 6.55 and currentTime < 18.05) and "Day" or "Night"
                
                -- รีเซ็ตสถานะเมื่อเวลาเปลี่ยน
                if newPeriod ~= currentPeriodStatus then
                    currentPeriodStatus = newPeriod
                    hasUsedTotem = false 
                end

                -- ถ้ายังใช้ไม่สำเร็จ ให้พยายามใช้ซ้ำๆ (Retry Logic)
                if not hasUsedTotem then
                    -- เช็คว่าถือของที่ต้องการอยู่หรือเปล่า ถ้าใช่ให้กดเลย
                    local targetTotem = (currentPeriodStatus == "Day") and _G.DayTotemSelect or _G.NightTotemSelect
                    
                    if targetTotem and targetTotem ~= "" then
                        -- ถ้าสำเร็จ hasUsedTotem จะเป็น true และหยุดลอง
                        -- ถ้าไม่สำเร็จ (success = false) มันจะวนลูปมาทำใหม่ในวินาทีถัดไปเรื่อยๆ
                        local result = UseTotemItem(targetTotem, "Change Time")
                        if result then
                            hasUsedTotem = true
                        end
                    end
                end
            end
        else
            -- Reset เมื่อปิด Auto Totem
            currentPeriodStatus = nil
            hasUsedTotem = false
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
RefreshAllDropdowns()