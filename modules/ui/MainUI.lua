-- ============================================
-- MAIN UI MODULE - Fluent UI และ Tabs (ต้นฉบับ)
-- ============================================

local MainUI = {}

-- Global references
MainUI.Window = nil
MainUI.Tabs = nil
MainUI.Options = nil
MainUI.Fluent = nil
MainUI.SaveManager = nil
MainUI.InterfaceManager = nil

function MainUI.Create()
    -- Load Fluent
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not result then
        warn("[Script Error]: Failed to load Fluent UI! Check your internet.")
        return nil
    end

    local Fluent = result
    MainUI.Fluent = Fluent
    
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    MainUI.SaveManager = SaveManager
    MainUI.InterfaceManager = InterfaceManager

    local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()

    -- 🖼️ UI SETUP
    local Window = Fluent:CreateWindow({
        Title = "Farm Hub | version 1.2",
        SubTitle = "Ban 100%",
        TabWidth = Services.TabsWidth,
        Size = Services.WindowSize,
        Acrylic = false,
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    MainUI.Window = Window

    -- สร้าง Tabs
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
    MainUI.Tabs = Tabs
    MainUI.Options = Fluent.Options

    return {
        Fluent = Fluent,
        Window = Window,
        Tabs = Tabs,
        Options = Fluent.Options,
        SaveManager = SaveManager,
        InterfaceManager = InterfaceManager
    }
end

function MainUI.CreateMobileUI()
    local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
    local CoreGui = Services.CoreGui
    local VirtualInputManager = Services.VirtualInputManager

    if CoreGui:FindFirstChild("FischMobileUI") then CoreGui.FischMobileUI:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "FischMobileUI"
    
    local MenuBtn = Instance.new("ImageButton", ScreenGui)
    MenuBtn.Name = "MenuToggle"
    MenuBtn.BackgroundColor3 = Color3.new(0,0,0)
    MenuBtn.BackgroundTransparency = 0.5
    MenuBtn.AnchorPoint = Vector2.new(0.5, 0)
    MenuBtn.Position = UDim2.new(0.5, -25, 0.05, 0)
    MenuBtn.Size = UDim2.fromOffset(50, 50)
    MenuBtn.Size = UDim2.fromOffset(50, 50)
    MenuBtn.Image = "rbxassetid://100142831144115"
    MenuBtn.Draggable = true
    Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", MenuBtn).Color = Color3.new(1,1,1)
    
    MenuBtn.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end

return MainUI
