-- ============================================
-- TAB SETUP MODULE - ตั้งค่า Tabs และ UI Elements (ต้นฉบับ)
-- ============================================

local TabSetup = {}

function TabSetup.SetupAllTabs(UI, Data, Utils)
    local Tabs = UI.Tabs
    local Options = UI.Options
    local Fluent = UI.Fluent
    local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
    local LogUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/ui/LogUI.lua"))()
    local InfoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/ui/InfoUI.lua"))()
    local FlyUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/ui/FlyUI.lua"))()

    -- 🏠 HOME
    Tabs.Home:AddToggle("StopAll", {Title = "STOP ALL ACTIONS", Default = false }):OnChanged(function()
        _G.StopAll = Options.StopAll.Value
        if _G.StopAll then
            _G.IsFlying = false
            local char = Services.LocalPlayer.Character
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
        if _G.AutoFish and Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            _G.currentSpot = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
        else
            _G.currentSpot = nil
        end
    end)
    Tabs.Main:AddToggle("AutoShake", {Title = "Auto Shake", Default = true }):OnChanged(function() _G.AutoShake = Options.AutoShake.Value end)
    Tabs.Main:AddToggle("LockPosition", {Title = "Freeze Position", Default = true }):OnChanged(function() _G.LockPosition = Options.LockPosition.Value end)

    -- 🤖 AUTOS
    local Autos = Tabs.Autos
    Autos:AddParagraph({ Title = "Sell Items", Content = "Auto sell or sell on hand." })

    local ToggleSellAll = Autos:AddToggle("AutoSellAll", {Title = "Auto Sell All", Default = false })
    ToggleSellAll:OnChanged(function() _G.AutoSellAll = Options.AutoSellAll.Value end)
    Autos:AddSlider("SellAllInterval", {Title = "Sell Interval (s)", Default = 5, Min = 1, Max = 60, Rounding = 1, Callback = function(V) _G.SellAllInterval = V end})

    Autos:AddButton({Title = "Sell On Hand", Callback = function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("Sell")
        if remote then
            local success, res = pcall(function() return remote:InvokeServer() end)
            if success then 
                LogUI.AddLog("💰 Sold Items", Color3.fromRGB(100, 255, 100)) 
                Fluent:Notify({Title="Sell Hand", Content="Success! Return: " .. tostring(res), Duration=3}) 
            else 
                warn("Sell Hand Error:", res) 
            end
        else
            Fluent:Notify({Title="Error", Content="Sell Remote Not Found!", Duration=3})
        end
    end})

    Autos:AddParagraph({ Title = "---", Content = "" })

    -- Smart Auto Totem
    Autos:AddParagraph({ Title = "Smart Auto Totem", Content = "ระบบตรวจจับเวลา Server แบบ Real-time\nจะทำงานทันทีที่เปลี่ยนช่วงเวลา (เช้า/ค่ำ)" })

    _G.AutoTotem = false
    _G.DayTotemSelect = "Sundial Totem"
    _G.NightTotemSelect = "Aurora Totem"

    Autos:AddToggle("EnableAutoTotem", {Title = "เปิดใช้งาน Smart Auto Totem", Default = false }):OnChanged(function(Value) _G.AutoTotem = Value end)

    Autos:AddDropdown("DayTotemDrop", {
        Title = "☀️ Totem เมื่อเข้าสู่ตอนเช้า (06:30)", 
        Values = Data.TotemList, 
        Multi = false, 
        Default = "Sundial Totem",
    }):OnChanged(function(Value) _G.DayTotemSelect = Value end)

    Autos:AddDropdown("NightTotemDrop", {
        Title = "🌙 Totem เมื่อเข้าสู่ตอนค่ำ (18:00)", 
        Values = Data.TotemList, 
        Multi = false, 
        Default = "Aurora Totem",
    }):OnChanged(function(Value) _G.NightTotemSelect = Value end)

    -- Auto Potion
    Autos:AddParagraph({ Title = "Auto Potion (Timer)", Content = "ระบบกินยาแบบตั้งเวลาวนลูป (หน่วย: นาที)" })

    _G.AutoPotion = false
    _G.SelectedPotion = Data.PotionList[1]
    _G.PotionDelayMinutes = 10
    _G.PotionRepeatCount = 999
    _G.PotionTimer = 0

    Autos:AddToggle("EnableAutoPotion", {Title = "เปิดใช้งาน Auto Potion", Default = false }):OnChanged(function(Value)
        _G.AutoPotion = Value
        if Value then _G.PotionTimer = 0 end
    end)

    Autos:AddDropdown("PotionSelect", {
        Title = "เลือก Potion",
        Values = Data.PotionList,
        Multi = false,
        Default = 1,
    }):OnChanged(function(Value) _G.SelectedPotion = Value end)

    Autos:AddInput("PotionTimeInput", {
        Title = "ระยะเวลาบัฟ (นาที)",
        Default = "16",
        Numeric = true,
        Callback = function(Value) _G.PotionDelayMinutes = tonumber(Value) or 16 end
    })

    Autos:AddInput("PotionCountInput", {
        Title = "จำนวนครั้งที่ทำซ้ำ",
        Default = "999",
        Numeric = true,
        Callback = function(Value) _G.PotionRepeatCount = tonumber(Value) or 999 end
    })

    -- 🏃 CHARACTER
    Tabs.Character:AddToggle("ESPEnabled", {Title = "Enable Player ESP", Default = false }):OnChanged(function() 
        _G.ESPEnabled = Options.ESPEnabled.Value 
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
    
    Tabs.Character:AddParagraph({ Title = "Mobile Support", Content = "เครื่องมือสำหรับมือถือ" })

    Tabs.Character:AddToggle("ShowFlyPanel", {Title = "Show Fly Panel (Mobile)", Default = false }):OnChanged(function(Value)
        FlyUI.SetVisible(Value)
    end)

    -- 🗺️ TELEPORT
    local DropdownManager, DropdownWarp
    local function RefreshAllDropdowns()
        local saved = Utils.LoadCustomLocations()
        local managerList, warpList = {}, {}
        local mQuery, wQuery = _G.ManagerSearch:lower(), _G.SearchQuery:lower()
        for name, _ in pairs(saved) do
            if mQuery == "" or name:lower():find(mQuery) then table.insert(managerList, name) end
            if wQuery == "" or name:lower():find(wQuery) then table.insert(warpList, name) end
        end
        for name, _ in pairs(Data.DefaultLocations) do
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
        local saved = Utils.LoadCustomLocations()
        if Value and saved[Value] then
            _G.CustomName = Value
            _G.CustomX, _G.CustomY, _G.CustomZ = saved[Value].x, saved[Value].y, saved[Value].z
            if Options.LocName then Options.LocName:SetValue(Value) end
            if Options.InputX then Options.InputX:SetValue(tostring(_G.CustomX)) end
            if Options.InputY then Options.InputY:SetValue(tostring(_G.CustomY)) end
            if Options.InputZ then Options.InputZ:SetValue(tostring(_G.CustomZ)) end
        end
    end)
    
    Tabs.Teleport:AddInput("LocName", {Title = "Name", Default = "", Callback = function(V) _G.CustomName = V end})
    Tabs.Teleport:AddInput("InputX", {Title = "X", Default = "0", Numeric = true, Callback = function(V) _G.CustomX = tonumber(V) or 0 end})
    Tabs.Teleport:AddInput("InputY", {Title = "Y", Default = "135", Numeric = true, Callback = function(V) _G.CustomY = tonumber(V) or 135 end})
    Tabs.Teleport:AddInput("InputZ", {Title = "Z", Default = "0", Numeric = true, Callback = function(V) _G.CustomZ = tonumber(V) or 0 end})
    
    Tabs.Teleport:AddButton({Title = "📍 Get Position", Callback = function()
        local char = Services.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            _G.CustomX, _G.CustomY, _G.CustomZ = math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
            if Options.InputX then Options.InputX:SetValue(tostring(_G.CustomX)) end
            if Options.InputY then Options.InputY:SetValue(tostring(_G.CustomY)) end
            if Options.InputZ then Options.InputZ:SetValue(tostring(_G.CustomZ)) end
        end
    end})
    
    Tabs.Teleport:AddButton({Title = "💾 Save", Callback = function()
        if _G.CustomName == "" then return end
        local saved = Utils.LoadCustomLocations()
        saved[_G.CustomName] = {x = tonumber(_G.CustomX), y = tonumber(_G.CustomY), z = tonumber(_G.CustomZ)}
        Utils.SaveCustomLocations(saved); RefreshAllDropdowns()
    end})
    
    Tabs.Teleport:AddButton({Title = "🚀 Warp to XYZ", Callback = function()
        if _G.StopAll then return end
        local char = Services.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local tp = CFrame.new(tonumber(_G.CustomX) or 0, tonumber(_G.CustomY) or 135, tonumber(_G.CustomZ) or 0)
            char.HumanoidRootPart.CFrame = tp
        end
    end})
    
    Tabs.Teleport:AddInput("SearchLoc", {Title = "🔍 Search Warp", Default = "", Callback = function(V) _G.SearchQuery = V; RefreshAllDropdowns() end})
    
    DropdownWarp = Tabs.Teleport:AddDropdown("IslandWarp", {Title = "📂 Select Destination", Values = {}, Multi = false, Default = nil})
    DropdownWarp:OnChanged(function(Value)
        if _G.StopAll or not Value then return end
        local target, saved = Data.DefaultLocations[Value], Utils.LoadCustomLocations()
        if not target and saved[Value] then target = saved[Value] end
        if target then
            local char = Services.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local tp = CFrame.new(target.x, target.y, target.z)
                char.HumanoidRootPart.CFrame = tp
            end
        end
    end)

    -- Player Teleport
    Tabs.Teleport:AddParagraph({ Title = "-----------------", Content = "" })
    Tabs.Teleport:AddParagraph({ Title = "Player Teleport", Content = "วาร์ปไปหาผู้เล่นอื่นในเซิร์ฟ" })

    local PlayerDropdown = Tabs.Teleport:AddDropdown("PlayerSelect", {
        Title = "เลือกผู้เล่น (Select Player)",
        Values = {},
        Multi = false,
        Default = nil,
    })

    local function RefreshPlayerList()
        local pList = {}
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= Services.LocalPlayer then
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
            
            local targetPlayer = Services.Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local char = Services.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                    Fluent:Notify({Title = "Teleport", Content = "Warped to: " .. targetName, Duration = 2})
                end
            else
                Fluent:Notify({Title = "Error", Content = "หาตัวผู้เล่นไม่เจอ หรือเขาตายอยู่", Duration = 3})
            end
        end
    })

    task.delay(1, function() RefreshPlayerList() end)

    -- 🛒 SHOP
    local RodNames = {}
    for _, v in ipairs(Data.RodList) do table.insert(RodNames, v.Name) end
    Tabs.Shop:AddDropdown("SelectedRod", {Title = "Select Rod", Values = RodNames, Multi = false, Default = 1})
    Tabs.Shop:AddButton({Title = "Buy Rod", Callback = function() 
        local remote = Utils.GetPurchaseRemote()
        if remote then
            remote:FireServer(Options.SelectedRod.Value, "Rod", nil, 1) 
        else
            Fluent:Notify({Title = "Error", Content = "Purchase remote not found", Duration = 3})
        end
    end})

    Tabs.Shop:AddDropdown("SelectedTotem", {Title = "Select Totem", Values = Data.TotemList, Multi = false, Default = 1})
    Tabs.Shop:AddInput("TotemAmount", {Title = "Amount", Default = "1", Numeric = true})
    Tabs.Shop:AddButton({Title = "Buy Totem", Callback = function()
        local selectedName = Options.SelectedTotem.Value
        local amount = math.clamp(tonumber(Options.TotemAmount.Value) or 1, 1, 50)
        
        local pricePerItem = 0
        for _, v in ipairs(Data.TotemData) do
            if v.Name == selectedName then pricePerItem = v.Price; break end
        end
        
        local totalPrice = pricePerItem * amount
        local currentMoney = Utils.getMoney()
        
        if currentMoney >= totalPrice then
            local remote = Utils.GetPurchaseRemote()
            if remote then
                remote:FireServer(selectedName, "Item", nil, amount)
                Fluent:Notify({Title = "Success", Content = "Bought " .. amount .. " " .. selectedName, Duration = 3})
            else
                Fluent:Notify({Title = "Error", Content = "Purchase remote not found", Duration = 3})
            end
        else
            Fluent:Notify({Title = "Failed", Content = "Not enough money! Need: " .. totalPrice, Duration = 5})
        end
    end})

    -- 👁️ VISUALS
    local Visuals = Tabs.Visuals
    Visuals:AddParagraph({ Title = "UI Visibility", Content = "ตั้งค่าการแสดงผล/ซ่อนปุ่มต่างๆ" })
    Visuals:AddToggle("HideShakeUI", {Title = "Hide Shake UI (Stealth)", Default = false }):OnChanged(function() 
        _G.HideShakeUI = Options.HideShakeUI.Value 
    end)

    -- ⚙️ SETTINGS
    Tabs.Settings:AddToggle("AntiAFK", {Title = "Enable Anti AFK", Default = true }):OnChanged(function() _G.AntiAFK = Options.AntiAFK.Value end)
    Tabs.Settings:AddToggle("AlwaysPerfect", {Title = "Always Perfect Catch", Default = true }):OnChanged(function() _G.AlwaysPerfect = Options.AlwaysPerfect.Value end)
    Tabs.Settings:AddToggle("FrozenBar", {Title = "Frozen Bar (Visual)", Default = true }):OnChanged(function() _G.FrozenBar = Options.FrozenBar.Value end)
    Tabs.Settings:AddSlider("ReelDelay", {Title = "Delay After Bite", Default = 2.5, Min = 0.0, Max = 10.0, Rounding = 1, Callback = function(V) _G.ReelDelay = V end})
    Tabs.Settings:AddSlider("CastDelay", {Title = "Cooldown After Catch", Default = 0.5, Min = 0.1, Max = 2.0, Rounding = 1, Callback = function(V) _G.CastDelay = V end})
    Tabs.Settings:AddButton({Title = "🔄 Rejoin Server", Callback = function() Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Services.LocalPlayer) end})
    Tabs.Settings:AddButton({Title = "⏩ Server Hop", Callback = function() Services.TeleportService:Teleport(game.PlaceId, Services.LocalPlayer) end})
    
    Tabs.Settings:AddParagraph({ Title = "Log Panel", Content = "หน้าต่างแสดงสถานะการทำงาน" })
    Tabs.Settings:AddToggle("ShowLogPanel", {Title = "Show Log Panel", Default = false }):OnChanged(function(Value)
        LogUI.SetVisible(Value)
    end)
    Tabs.Settings:AddButton({Title = "Clear Logs", Callback = function() LogUI.ClearLogs() end})

    -- Performance & FPS
    Tabs.Settings:AddParagraph({ Title = "-----------------", Content = "" })
    Tabs.Settings:AddParagraph({ Title = "Performance & FPS", Content = "เครื่องมือช่วยลดแลค และลดการทำงานเครื่อง" })

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
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            
            Fluent:Notify({Title = "FPS Boost", Content = "Textures & Effects Removed!", Duration = 3})
        end
    })

    Tabs.Settings:AddToggle("FullBright", {Title = "☀️ Full Bright (No Fog)", Default = false }):OnChanged(function(Value)
        if Value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)

    Tabs.Settings:AddToggle("SuperLowMode", {Title = "⚫ 3D Render Disable (Super AFK)", Default = false }):OnChanged(function(Value)
        Services.RunService:Set3dRenderingEnabled(not Value)
        if Value then
            Fluent:Notify({Title = "AFK Mode", Content = "ปิดการแสดงผล 3D แล้ว (ประหยัด GPU)", Duration = 3})
        else
            Fluent:Notify({Title = "AFK Mode", Content = "กลับสู่โหมดปกติ", Duration = 3})
        end
    end)

    Tabs.Settings:AddInput("FPSCap", {
        Title = "🔒 Max FPS Cap",
        Default = "60",
        Numeric = true,
        Callback = function(Value)
            setfpscap(tonumber(Value) or 60)
        end
    })

    -- ℹ️ SERVER INFO TAB
    local InfoTab = Tabs.ServerInfo

    InfoTab:AddToggle("ShowInfoPanel", {Title = "Show Info Panel Overlay", Default = true }):OnChanged(function(Value)
        InfoUI.SetVisible(Value)
    end)

    InfoTab:AddParagraph({ Title = "---", Content = "" })

    local RealTimePara = InfoTab:AddParagraph({ Title = "🕒 เวลาชีวิตจริง (Real Time)", Content = "Loading..." })
    local GameTimePara = InfoTab:AddParagraph({ Title = "☀️ เวลาในเกม (Game Time)", Content = "Loading..." })
    local UptimePara = InfoTab:AddParagraph({ Title = "⏳ เซิร์ฟเวอร์เปิดมาแล้ว (Server Uptime)", Content = "Loading..." })

    -- Update Loop
    task.spawn(function()
        while true do
            -- Real Time
            local statusTime = os.date("%H:%M:%S")
            
            -- Game Time
            local clockTime = game:GetService("Lighting").ClockTime
            local timeState = (clockTime >= 6 and clockTime < 18) and "Day ☀️" or "Night 🌙"
            local gameTimeStr = Utils.FormatGameTime(clockTime) .. " " .. timeState

            -- Server Uptime
            local serverTime = workspace.DistributedGameTime
            local uptimeStr = Utils.FormatTime(serverTime)

            -- Update Paragraphs
            if RealTimePara then RealTimePara:SetDesc(statusTime) end
            if GameTimePara then GameTimePara:SetDesc(gameTimeStr) end
            if UptimePara then UptimePara:SetDesc(uptimeStr) end

            -- Update Info UI
            InfoUI.Update(Utils.FormatTime, Utils.FormatGameTime)

            task.wait(1)
        end
    end)

    -- SaveManager Setup
    UI.SaveManager:SetLibrary(Fluent)
    UI.InterfaceManager:SetLibrary(Fluent)
    UI.SaveManager:IgnoreThemeSettings()
    UI.InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    UI.Window:SelectTab(1)
    UI.SaveManager:LoadAutoloadConfig()
    
    RefreshAllDropdowns()
end

return TabSetup
