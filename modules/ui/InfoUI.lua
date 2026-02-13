-- ============================================
-- INFO UI MODULE - Server Info Panel (ต้นฉบับ)
-- ============================================

local InfoUI = {}

-- UI Elements (Global within module)
local InfoGui, InfoFrame, RealTimeLabel, GameTimeLabel, UptimeLabel

function InfoUI.Create()
    -- [[ ℹ️ SERVER INFO PANEL SETUP ]] --
    InfoGui = Instance.new("ScreenGui")
    InfoGui.Name = "FischInfoGui"
    InfoGui.Parent = game:GetService("CoreGui")
    InfoGui.Enabled = true
    InfoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- กรอบหลัก (Main Frame)
    InfoFrame = Instance.new("Frame")
    InfoFrame.Name = "MainFrame"
    InfoFrame.Parent = InfoGui
    InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    InfoFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    InfoFrame.BorderSizePixel = 1
    InfoFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
    InfoFrame.Size = UDim2.new(0, 250, 0, 120)
    InfoFrame.Active = true
    InfoFrame.Draggable = true

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

    -- ปุ่มพับเก็บ (Minimize Button)
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

    RealTimeLabel = CreateInfoLabel(1, "🕒 Real: ...")
    GameTimeLabel = CreateInfoLabel(2, "☀️ Game: ...")
    UptimeLabel = CreateInfoLabel(3, "⏳ Up: ...")

    -- [[ ระบบพับเก็บ (Minimizing Logic) ]] --
    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            InfoFrame:TweenSize(UDim2.new(0, 250, 0, 25), "Out", "Quad", 0.3, true)
            ContentFrame.Visible = false
            MinimizeBtn.Text = "+"
        else
            InfoFrame:TweenSize(UDim2.new(0, 250, 0, 120), "Out", "Quad", 0.3, true)
            ContentFrame.Visible = true
            MinimizeBtn.Text = "-"
        end
    end)
end

function InfoUI.SetVisible(enabled)
    if InfoGui then
        InfoGui.Enabled = enabled
    end
end

function InfoUI.Update(formatTimeFunc, formatGameTimeFunc)
    if not InfoGui or not InfoGui.Enabled then return end
    
    local statusTime = os.date("%H:%M:%S")
    local clockTime = game:GetService("Lighting").ClockTime
    local timeState = (clockTime >= 6 and clockTime < 18) and "Day ☀️" or "Night 🌙"
    local gameTimeStr = formatGameTimeFunc(clockTime) .. " " .. timeState
    local serverTime = workspace.DistributedGameTime
    local uptimeStr = formatTimeFunc(serverTime)
    
    RealTimeLabel.Text = "🕒 เวลาชีวิตจริง:  " .. statusTime
    GameTimeLabel.Text = "🗓️ เวลาในเกม: " .. gameTimeStr
    UptimeLabel.Text = "⏳ เวลาที่คุณออนเกม:    " .. uptimeStr
    
    if timeState == "Day ☀️" then
        GameTimeLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    else
        GameTimeLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    end
end

return InfoUI
