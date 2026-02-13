-- ============================================
-- LOG UI MODULE - Log System (ต้นฉบับ)
-- ============================================

local LogUI = {}

-- UI Elements
local LogGui, LogFrame, LogScroll, UIList

function LogUI.Create()
    -- [[ 📜 LOG SYSTEM SETUP ]] --
    LogGui = Instance.new("ScreenGui")
    LogGui.Name = "FischLogGui"
    LogGui.Parent = game:GetService("CoreGui")
    LogGui.Enabled = false
    LogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    LogFrame = Instance.new("Frame")
    LogFrame.Name = "MainFrame"
    LogFrame.Parent = LogGui
    LogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    LogFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    LogFrame.BorderSizePixel = 1
    LogFrame.Position = UDim2.new(0.75, 0, 0.65, 0)
    LogFrame.Size = UDim2.new(0, 300, 0, 200)
    LogFrame.Active = true
    LogFrame.Draggable = true

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
    LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Parent = LogFrame
    LogScroll.BackgroundTransparency = 1
    LogScroll.Position = UDim2.new(0, 5, 0, 30)
    LogScroll.Size = UDim2.new(1, -10, 1, -35)
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.ScrollBarThickness = 4

    UIList = Instance.new("UIListLayout")
    UIList.Parent = LogScroll
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)
    
    -- ทดสอบ Log
    LogUI.AddLog("System initialized...", Color3.fromRGB(100, 255, 100))
end

function LogUI.AddLog(text, color)
    if not LogScroll then return end
    
    local timestamp = os.date("%H:%M:%S")
    local label = Instance.new("TextLabel")
    label.Parent = LogScroll
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.SourceSans
    label.Text = string.format("[%s] %s", timestamp, text)
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = false
    
    -- Auto Scroll
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, UIList.AbsoluteContentSize.Y)
    
    -- ลบ Log เก่าถ้าเยอะเกิน
    if #LogScroll:GetChildren() > 100 then
        LogScroll:GetChildren()[2]:Destroy()
    end
end

function LogUI.SetVisible(enabled)
    if LogGui then
        LogGui.Enabled = enabled
    end
end

function LogUI.ClearLogs()
    if not LogScroll then return end
    for _, child in pairs(LogScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    LogScroll.CanvasSize = UDim2.new(0,0,0,0)
    LogUI.AddLog("Logs cleared.", Color3.fromRGB(255, 255, 0))
end

return LogUI
