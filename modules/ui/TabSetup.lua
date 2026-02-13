-- ============================================
-- TAB SETUP MODULE - ตั้งค่า Tabs และ UI Elements
-- ============================================

local TabSetup = {}

function TabSetup.SetupAllTabs(ui, config, state, data, utils, services, logUI, infoUI, flyUI, teleportModule)
    local Tabs = ui.Tabs
    local Options = ui.Options
    local mainUI = ui

    -- ============================================
    -- 🏠 HOME TAB
    -- ============================================
    Tabs.Home:AddToggle("StopAll", {
        Title = "STOP ALL ACTIONS",
        Default = false
    }):OnChanged(function()
        config.StopAll = Options.StopAll.Value
        if config.StopAll then
            config.IsFlying = false
            state.FlyVelocity = Vector3.new(0, 0, 0)
            local char = services.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
                char.Humanoid.AutoRotate = true
            end
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                for _, v in pairs({"FlyVelocity", "FlyGyro"}) do
                    if char.HumanoidRootPart:FindFirstChild(v) then
                        char.HumanoidRootPart[v]:Destroy()
                    end
                end
            end
        end
    end)

    -- ============================================
    -- 🎣 MAIN TAB (Auto Fish)
    -- ============================================
    local ToggleAutoFish = Tabs.Main:AddToggle("AutoFish", {
        Title = "Enable Auto Fish",
        Default = false
    })
    ToggleAutoFish:OnChanged(function(Value)
        config.AutoFish = Value
        if config.AutoFish and services.LocalPlayer.Character and services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            state.CurrentSpot = services.LocalPlayer.Character.HumanoidRootPart.CFrame
        else
            state.CurrentSpot = nil
        end
    end)

    Tabs.Main:AddToggle("AutoShake", {
        Title = "Auto Shake",
        Default = true
    }):OnChanged(function(Value)
        config.AutoShake = Value
    end)

    Tabs.Main:AddToggle("LockPosition", {
        Title = "Freeze Position",
        Default = true
    }):OnChanged(function(Value)
        config.LockPosition = Value
    end)

    -- ============================================
    -- 🤖 AUTOS TAB
    -- ============================================
    local Autos = Tabs.Autos
    Autos:AddParagraph({ Title = "Sell Items", Content = "Auto sell or sell on hand." })

    local ToggleSellAll = Autos:AddToggle("AutoSellAll", {
        Title = "Auto Sell All",
        Default = false
    })
    ToggleSellAll:OnChanged(function(Value)
        config.AutoSellAll = Value
    end)

    Autos:AddSlider("SellAllInterval", {
        Title = "Sell Interval (s)",
        Default = 5,
        Min = 1,
        Max = 60,
        Rounding = 1,
        Callback = function(V)
            config.SellAllInterval = V
        end
    })

    Autos:AddButton({
        Title = "Sell On Hand",
        Callback = function()
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("Sell")
            if remote then
                local success, res = pcall(function()
                    return remote:InvokeServer()
                end)
                if success then
                    logUI.AddLog("💰 Sold Items", Color3.fromRGB(100, 255, 100))
                    mainUI.Notify("Sell Hand", "Success! Return: " .. tostring(res), 3)
                else
                    warn("Sell Hand Error:", res)
                end
            else
                mainUI.Notify("Error", "Sell Remote Not Found!", 3)
            end
        end
    })

    Autos:AddParagraph({ Title = "---", Content = "" })

    -- Smart Auto Totem
    Autos:AddParagraph({
        Title = "Smart Auto Totem",
        Content = "ระบบตรวจจับเวลา Server แบบ Real-time\nจะทำงานทันทีที่เปลี่ยนช่วงเวลา (เช้า/ค่ำ)"
    })

    Autos:AddToggle("EnableAutoTotem", {
        Title = "เปิดใช้งาน Smart Auto Totem",
        Default = false
    }):OnChanged(function(Value)
        config.AutoTotem = Value
    end)

    Autos:AddDropdown("DayTotemDrop", {
        Title = "☀️ Totem เมื่อเข้าสู่ตอนเช้า (06:30)",
        Values = data.TotemList,
        Multi = false,
        Default = "Sundial Totem"
    }):OnChanged(function(Value)
        config.DayTotemSelect = Value
    end)

    Autos:AddDropdown("NightTotemDrop", {
        Title = "🌙 Totem เมื่อเข้าสู่ตอนค่ำ (18:00)",
        Values = data.TotemList,
        Multi = false,
        Default = "Aurora Totem"
    }):OnChanged(function(Value)
        config.NightTotemSelect = Value
    end)

    -- Auto Potion
    Autos:AddParagraph({
        Title = "Auto Potion (Timer)",
        Content = "ระบบกินยาแบบตั้งเวลาวนลูป (หน่วย: นาที)"
    })

    Autos:AddToggle("EnableAutoPotion", {
        Title = "เปิดใช้งาน Auto Potion",
        Default = false
    }):OnChanged(function(Value)
        config.AutoPotion = Value
        if Value then
            config.PotionTimer = 0
        end
    end)

    Autos:AddDropdown("PotionSelect", {
        Title = "เลือก Potion",
        Values = data.PotionList,
        Multi = false,
        Default = 1
    }):OnChanged(function(Value)
        config.SelectedPotion = Value
    end)

    Autos:AddInput("PotionTimeInput", {
        Title = "ระยะเวลาบัฟ (นาที)",
        Default = "16",
        Numeric = true,
        Callback = function(Value)
            config.PotionDelayMinutes = tonumber(Value) or 16
        end
    })

    Autos:AddInput("PotionCountInput", {
        Title = "จำนวนครั้งที่ทำซ้ำ",
        Default = "999",
        Numeric = true,
        Callback = function(Value)
            config.PotionRepeatCount = tonumber(Value) or 999
        end
    })

    -- ============================================
    -- 🏃 CHARACTER TAB
    -- ============================================
    Tabs.Character:AddToggle("ESPEnabled", {
        Title = "Enable Player ESP",
        Default = false
    }):OnChanged(function(Value)
        config.ESPEnabled = Value
        if not config.ESPEnabled then
            local CoreGui = game:GetService("CoreGui")
            local ESPHolder = CoreGui:FindFirstChild("FischESPHolder")
            if ESPHolder then
                ESPHolder:ClearAllChildren()
            end
        end
    end)

    Tabs.Character:AddToggle("WalkSpeedEnabled", {
        Title = "Enable Walk Speed",
        Default = false
    }):OnChanged(function(Value)
        config.WalkSpeedEnabled = Value
    end)

    Tabs.Character:AddInput("WalkSpeedVal", {
        Title = "Speed Value",
        Default = "16",
        Numeric = true,
        Callback = function(V)
            config.WalkSpeed = tonumber(V) or 16
        end
    })

    Tabs.Character:AddToggle("JumpPowerEnabled", {
        Title = "Enable Jump Power",
        Default = false
    }):OnChanged(function(Value)
        config.JumpPowerEnabled = Value
    end)

    Tabs.Character:AddInput("JumpPowerVal", {
        Title = "Jump Value",
        Default = "50",
        Numeric = true,
        Callback = function(V)
            config.JumpPower = tonumber(V) or 50
        end
    })

    Tabs.Character:AddToggle("Noclip", {
        Title = "Noclip",
        Default = false
    }):OnChanged(function(Value)
        config.Noclip = Value
    end)

    Tabs.Character:AddToggle("DashEnabled", {
        Title = "Enable Dash",
        Default = true
    }):OnChanged(function(Value)
        config.DashEnabled = Value
    end)

    Tabs.Character:AddSlider("DashSpeed", {
        Title = "Dash Speed",
        Default = 100,
        Min = 50,
        Max = 300,
        Rounding = 0,
        Callback = function(V)
            config.DashSpeed = V
        end
    })

    Tabs.Character:AddToggle("FlyEnabled", {
        Title = "Enable Fly",
        Default = true
    }):OnChanged(function(Value)
        config.FlyEnabled = Value
    end)

    Tabs.Character:AddToggle("FlyInertia", {
        Title = "Fly Inertia",
        Default = true
    }):OnChanged(function(Value)
        config.FlyInertia = Value
    end)

    Tabs.Character:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Default = 75,
        Min = 10,
        Max = 300,
        Rounding = 0,
        Callback = function(V)
            config.FlySpeed = V
        end
    })

    Tabs.Character:AddParagraph({ Title = "Mobile Support", Content = "เครื่องมือสำหรับมือถือ" })

    Tabs.Character:AddToggle("ShowFlyPanel", {
        Title = "Show Fly Panel (Mobile)",
        Default = false
    }):OnChanged(function(Value)
        flyUI.SetVisible(Value)
    end)

    -- ============================================
    -- 🗺️ TELEPORT TAB
    -- ============================================
    local DropdownManager, DropdownWarp, PlayerDropdown

    local function RefreshAllDropdowns()
        teleportModule.RefreshLocationLists(
            DropdownManager,
            DropdownWarp,
            utils.LoadCustomLocations(config.FileName),
            data.DefaultLocations,
            config.ManagerSearch,
            config.SearchQuery
        )
    end

    Tabs.Teleport:AddButton({
        Title = "🔄 Refresh Lists",
        Callback = function()
            RefreshAllDropdowns()
            mainUI.Notify("Teleport", "Refreshed!", 1)
        end
    })

    Tabs.Teleport:AddInput("ManagerSearch", {
        Title = "🔍 Search Saved",
        Default = "",
        Callback = function(V)
            config.ManagerSearch = V
            RefreshAllDropdowns()
        end
    })

    DropdownManager = Tabs.Teleport:AddDropdown("ManagerSelect", {
        Title = "📂 Select Saved",
        Values = {},
        Multi = false,
        Default = nil
    })

    DropdownManager:OnChanged(function(Value)
        local saved = utils.LoadCustomLocations(config.FileName)
        if Value and saved[Value] then
            config.CustomName = Value
            config.CustomX, config.CustomY, config.CustomZ = saved[Value].x, saved[Value].y, saved[Value].z
            if Options.LocName then Options.LocName:SetValue(Value) end
            if Options.InputX then Options.InputX:SetValue(tostring(config.CustomX)) end
            if Options.InputY then Options.InputY:SetValue(tostring(config.CustomY)) end
            if Options.InputZ then Options.InputZ:SetValue(tostring(config.CustomZ)) end
        end
    end)

    Tabs.Teleport:AddInput("LocName", {
        Title = "Name",
        Default = "",
        Callback = function(V)
            config.CustomName = V
        end
    })

    Tabs.Teleport:AddInput("InputX", {
        Title = "X",
        Default = "0",
        Numeric = true,
        Callback = function(V)
            config.CustomX = tonumber(V) or 0
        end
    })

    Tabs.Teleport:AddInput("InputY", {
        Title = "Y",
        Default = "135",
        Numeric = true,
        Callback = function(V)
            config.CustomY = tonumber(V) or 135
        end
    })

    Tabs.Teleport:AddInput("InputZ", {
        Title = "Z",
        Default = "0",
        Numeric = true,
        Callback = function(V)
            config.CustomZ = tonumber(V) or 0
        end
    })

    Tabs.Teleport:AddButton({
        Title = "📍 Get Position",
        Callback = function()
            local x, y, z = teleportModule.GetCurrentPosition()
            config.CustomX, config.CustomY, config.CustomZ = x, y, z
            if Options.InputX then Options.InputX:SetValue(tostring(x)) end
            if Options.InputY then Options.InputY:SetValue(tostring(y)) end
            if Options.InputZ then Options.InputZ:SetValue(tostring(z)) end
        end
    })

    Tabs.Teleport:AddButton({
        Title = "💾 Save",
        Callback = function()
            if config.CustomName == "" then
                return
            end
            local saved = utils.LoadCustomLocations(config.FileName)
            saved[config.CustomName] = {
                x = tonumber(config.CustomX),
                y = tonumber(config.CustomY),
                z = tonumber(config.CustomZ)
            }
            utils.SaveCustomLocations(config.FileName, saved)
            RefreshAllDropdowns()
        end
    })

    Tabs.Teleport:AddButton({
        Title = "🚀 Warp to XYZ",
        Callback = function()
            teleportModule.ToPosition(config.CustomX, config.CustomY, config.CustomZ, state, config)
        end
    })

    Tabs.Teleport:AddInput("SearchLoc", {
        Title = "🔍 Search Warp",
        Default = "",
        Callback = function(V)
            config.SearchQuery = V
            RefreshAllDropdowns()
        end
    })

    DropdownWarp = Tabs.Teleport:AddDropdown("IslandWarp", {
        Title = "📂 Select Destination",
        Values = {},
        Multi = false,
        Default = nil
    })

    DropdownWarp:OnChanged(function(Value)
        if not Value then
            return
        end
        teleportModule.ToLocation(Value, data.DefaultLocations, utils.LoadCustomLocations(config.FileName), state, config)
    end)

    -- Player Teleport
    Tabs.Teleport:AddParagraph({ Title = "-----------------", Content = "" })
    Tabs.Teleport:AddParagraph({ Title = "Player Teleport", Content = "วาร์ปไปหาผู้เล่นอื่นในเซิร์ฟ" })

    PlayerDropdown = Tabs.Teleport:AddDropdown("PlayerSelect", {
        Title = "เลือกผู้เล่น (Select Player)",
        Values = {},
        Multi = false,
        Default = nil
    })

    Tabs.Teleport:AddButton({
        Title = "🔄 Refresh Players List",
        Description = "กดเพื่อรีเฟรชรายชื่อคน",
        Callback = function()
            teleportModule.RefreshPlayerList(PlayerDropdown)
            mainUI.Notify("System", "Updated Player List!", 1)
        end
    })

    Tabs.Teleport:AddButton({
        Title = "🚀 Warp to Player",
        Description = "วาร์ปไปหาคนที่เลือก",
        Callback = function()
            local targetName = Options.PlayerSelect.Value
            if not targetName then
                return
            end
            local success = teleportModule.ToPlayer(targetName, state, config)
            if success then
                mainUI.Notify("Teleport", "Warped to: " .. targetName, 2)
            else
                mainUI.Notify("Error", "หาตัวผู้เล่นไม่เจอ หรือเขาตายอยู่", 3)
            end
        end
    })

    -- Initial refresh
    task.delay(1, function()
        RefreshAllDropdowns()
        teleportModule.RefreshPlayerList(PlayerDropdown)
    end)

    -- ============================================
    -- 🛒 SHOP TAB
    -- ============================================
    local RodNames = data.GetRodNames()
    Tabs.Shop:AddDropdown("SelectedRod", {
        Title = "Select Rod",
        Values = RodNames,
        Multi = false,
        Default = 1
    })

    Tabs.Shop:AddButton({
        Title = "Buy Rod",
        Callback = function()
            local remote = utils.GetPurchaseRemote()
            if remote then
                remote:FireServer(Options.SelectedRod.Value, "Rod", nil, 1)
            else
                mainUI.Notify("Error", "Purchase remote not found", 3)
            end
        end
    })

    -- Buy Totem Section
    Tabs.Shop:AddDropdown("SelectedTotem", {
        Title = "Select Totem",
        Values = data.TotemList,
        Multi = false,
        Default = 1
    })

    Tabs.Shop:AddInput("TotemAmount", {
        Title = "Amount",
        Default = "1",
        Numeric = true
    })

    Tabs.Shop:AddButton({
        Title = "Buy Totem",
        Callback = function()
            local selectedName = Options.SelectedTotem.Value
            local amount = math.clamp(tonumber(Options.TotemAmount.Value) or 1, 1, 50)
            local pricePerItem = data.GetTotemPrice(selectedName)
            local totalPrice = pricePerItem * amount
            local currentMoney = utils.GetMoney()

            if currentMoney >= totalPrice then
                local remote = utils.GetPurchaseRemote()
                if remote then
                    remote:FireServer(selectedName, "Item", nil, amount)
                    mainUI.Notify("Success", "Bought " .. amount .. " " .. selectedName, 3)
                else
                    mainUI.Notify("Error", "Purchase remote not found", 3)
                end
            else
                mainUI.Notify("Failed", "Not enough money! Need: " .. totalPrice, 5)
            end
        end
    })

    -- ============================================
    -- 👁️ VISUALS TAB
    -- ============================================
    local Visuals = Tabs.Visuals
    Visuals:AddParagraph({ Title = "UI Visibility", Content = "ตั้งค่าการแสดงผล/ซ่อนปุ่มต่างๆ" })

    Visuals:AddToggle("HideShakeUI", {
        Title = "Hide Shake UI (Stealth)",
        Default = false
    }):OnChanged(function(Value)
        config.HideShakeUI = Value
    end)

    -- ============================================
    -- ⚙️ SETTINGS TAB
    -- ============================================
    Tabs.Settings:AddToggle("AntiAFK", {
        Title = "Enable Anti AFK",
        Default = true
    }):OnChanged(function(Value)
        config.AntiAFK = Value
    end)

    Tabs.Settings:AddToggle("AlwaysPerfect", {
        Title = "Always Perfect Catch",
        Default = true
    }):OnChanged(function(Value)
        config.AlwaysPerfect = Value
    end)

    Tabs.Settings:AddToggle("FrozenBar", {
        Title = "Frozen Bar (Visual)",
        Default = true
    }):OnChanged(function(Value)
        config.FrozenBar = Value
    end)

    Tabs.Settings:AddSlider("ReelDelay", {
        Title = "Delay After Bite",
        Default = 2.5,
        Min = 0.0,
        Max = 10.0,
        Rounding = 1,
        Callback = function(V)
            config.ReelDelay = V
        end
    })

    Tabs.Settings:AddSlider("CastDelay", {
        Title = "Cooldown After Catch",
        Default = 0.5,
        Min = 0.1,
        Max = 2.0,
        Rounding = 1,
        Callback = function(V)
            config.CastDelay = V
        end
    })

    Tabs.Settings:AddButton({
        Title = "🔄 Rejoin Server",
        Callback = function()
            services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, services.LocalPlayer)
        end
    })

    Tabs.Settings:AddButton({
        Title = "⏩ Server Hop",
        Callback = function()
            services.TeleportService:Teleport(game.PlaceId, services.LocalPlayer)
        end
    })

    Tabs.Settings:AddParagraph({ Title = "Log Panel", Content = "หน้าต่างแสดงสถานะการทำงาน" })

    Tabs.Settings:AddToggle("ShowLogPanel", {
        Title = "Show Log Panel",
        Default = false
    }):OnChanged(function(Value)
        logUI.SetVisible(Value)
    end)

    Tabs.Settings:AddButton({
        Title = "Clear Logs",
        Callback = function()
            logUI.ClearLogs()
        end
    })

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

            mainUI.Notify("FPS Boost", "Textures & Effects Removed!", 3)
        end
    })

    Tabs.Settings:AddToggle("FullBright", {
        Title = "☀️ Full Bright (No Fog)",
        Default = false
    }):OnChanged(function(Value)
        if Value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)

    Tabs.Settings:AddToggle("SuperLowMode", {
        Title = "⚫ 3D Render Disable (Super AFK)",
        Default = false
    }):OnChanged(function(Value)
        services.RunService:Set3dRenderingEnabled(not Value)
        if Value then
            mainUI.Notify("AFK Mode", "ปิดการแสดงผล 3D แล้ว (ประหยัด GPU)", 3)
        else
            mainUI.Notify("AFK Mode", "กลับสู่โหมดปกติ", 3)
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

    -- ============================================
    -- ℹ️ SERVER INFO TAB
    -- ============================================
    local InfoTab = Tabs.ServerInfo

    InfoTab:AddToggle("ShowInfoPanel", {
        Title = "Show Info Panel Overlay",
        Default = true
    }):OnChanged(function(Value)
        infoUI.SetVisible(Value)
    end)

    InfoTab:AddParagraph({ Title = "---", Content = "" })

    local RealTimePara = InfoTab:AddParagraph({ Title = "🕒 เวลาชีวิตจริง (Real Time)", Content = "Loading..." })
    local GameTimePara = InfoTab:AddParagraph({ Title = "☀️ เวลาในเกม (Game Time)", Content = "Loading..." })
    local UptimePara = InfoTab:AddParagraph({ Title = "⏳ เซิร์ฟเวอร์เปิดมาแล้ว (Server Uptime)", Content = "Loading..." })

    -- Update Loop
    task.spawn(function()
        print("[Debug] Server Info update loop started")
        local loopCount = 0
        while true do
            loopCount = loopCount + 1
            if loopCount <= 3 then
                print("[Debug] Server Info loop iteration", loopCount)
            end
            
            local success, err = pcall(function()
                -- Real Time
                local statusTime = os.date("%H:%M:%S")

                -- Game Time
                local clockTime = game:GetService("Lighting").ClockTime
                local timeState = (clockTime >= 6 and clockTime < 18) and "Day ☀️" or "Night 🌙"
                local gameTimeStr = utils.FormatGameTime(clockTime) .. " " .. timeState

                -- Server Uptime
                local serverTime = workspace.DistributedGameTime
                local uptimeStr = utils.FormatTime(serverTime)

                -- Update Paragraphs
                if RealTimePara then
                    RealTimePara:SetDesc(statusTime)
                end
                if GameTimePara then
                    GameTimePara:SetDesc(gameTimeStr)
                end
                if UptimePara then
                    UptimePara:SetDesc(uptimeStr)
                end

                -- Update Info UI
                infoUI.Update(utils.FormatTime, utils.FormatGameTime)
            end)
            
            if not success and loopCount <= 3 then
                warn("[Debug] Server Info update error:", err)
            end

            task.wait(1)
        end
    end)

    -- Initial log
    logUI.AddLog("System initialized...", Color3.fromRGB(100, 255, 100))
end

return TabSetup
