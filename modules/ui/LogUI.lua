-- ============================================
-- LOG UI MODULE - หน้าต่างแสดง Logs
-- ============================================

local LogUI = {}

-- Services
local CoreGui = game:GetService("CoreGui")

-- UI Elements
LogUI.Gui = nil
LogUI.Frame = nil
LogUI.Scroll = nil
LogUI.UIList = nil

-- ฟังก์ชันสร้าง Log UI
function LogUI.Create()
    -- 📜 LOG SYSTEM SETUP
    local LogGui = Instance.new("ScreenGui")
    LogGui.Name = "FischLogGui"
    LogGui.Parent = CoreGui
    LogGui.Enabled = false -- เริ่มต้นปิดไว้
    LogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local LogFrame = Instance.new("Frame")
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

    -- Save references
    LogUI.Gui = LogGui
    LogUI.Frame = LogFrame
    LogUI.Scroll = LogScroll
    LogUI.UIList = UIList

    return LogUI
end

-- ฟังก์ชันเพิ่ม Log
function LogUI.AddLog(text, color)
    if not LogUI.Scroll then
        return
    end

    local timestamp = os.date("%H:%M:%S")
    local label = Instance.new("TextLabel")
    label.Parent = LogUI.Scroll
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.SourceSans
    label.Text = string.format("[%s] %s", timestamp, text)
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = false

    -- Auto Scroll ลงล่างสุด
    LogUI.Scroll.CanvasSize = UDim2.new(0, 0, 0, LogUI.UIList.AbsoluteContentSize.Y)
    LogUI.Scroll.CanvasPosition = Vector2.new(0, LogUI.UIList.AbsoluteContentSize.Y)

    -- ลบ Log เก่าถ้าเยอะเกิน (กันแลค)
    if #LogUI.Scroll:GetChildren() > 100 then
        LogUI.Scroll:GetChildren()[2]:Destroy() -- [1] คือ UIListLayout
    end
end

-- ฟังก์ชันล้าง Logs
function LogUI.ClearLogs()
    if not LogUI.Scroll then
        return
    end
    for _, child in pairs(LogUI.Scroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    LogUI.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogUI.AddLog("Logs cleared.", Color3.fromRGB(255, 255, 0))
end

-- ฟังก์ชัน Toggle การแสดงผล
function LogUI.SetVisible(visible)
    if LogUI.Gui then
        LogUI.Gui.Enabled = visible
    end
end

return LogUI
