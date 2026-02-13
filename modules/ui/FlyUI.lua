-- ============================================
-- FLY UI MODULE - Fly Control Panel (ต้นฉบับ)
-- ============================================

local FlyUI = {}

-- UI Elements
local FlyGui, FlyFrame, ToggleFlyBtn, BoostFlyBtn
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()

function FlyUI.Create()
    -- [[ ✈️ FLY CONTROL PANEL (MOBILE) ]] --
    FlyGui = Instance.new("ScreenGui")
    FlyGui.Name = "FischFlyGui"
    FlyGui.Parent = game:GetService("CoreGui")
    FlyGui.Enabled = false
    FlyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- กรอบหลัก
    FlyFrame = Instance.new("Frame")
    FlyFrame.Name = "FlyMainFrame"
    FlyFrame.Parent = FlyGui
    FlyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FlyFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    FlyFrame.BorderSizePixel = 1
    FlyFrame.Position = UDim2.new(0.8, 0, 0.25, 0)
    FlyFrame.Size = UDim2.new(0, 150, 0, 180)
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
    ToggleFlyBtn = Instance.new("TextButton")
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

    -- 2. ปุ่ม Speed Boost
    BoostFlyBtn = Instance.new("TextButton")
    BoostFlyBtn.Name = "BoostFlyBtn"
    BoostFlyBtn.Parent = FlyContent
    BoostFlyBtn.Size = UDim2.new(1, 0, 0, 40)
    BoostFlyBtn.Position = UDim2.new(0, 0, 0, 60)
    BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
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
            
            local char = Services.LocalPlayer.Character
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
            BoostFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            BoostFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
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

    -- Auto Sync Loop
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
end

function FlyUI.SetVisible(enabled)
    if FlyGui then
        FlyGui.Enabled = enabled
    end
end

return FlyUI
