-- ============================================
-- CHARACTER MODULE - ESP, Fly, Noclip, Dash (ต้นฉบับ)
-- ============================================

local Character = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/config/Settings.lua"))()

-- State from Config
local currentFlyVelocity = Config.currentFlyVelocity
local keysDown = Config.keysDown
local lastSpacePress = Config.lastSpacePress
local currentSpot = Config.currentSpot

-- ESP Holder
local ESPHolder = Instance.new("Folder", Services.CoreGui)
ESPHolder.Name = "FischESPHolder"

function Character.Start()
    -- Anti AFK
    Services.LocalPlayer.Idled:Connect(function()
        if _G.AntiAFK then
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    -- Input Handling
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        keysDown[input.KeyCode] = true
        
        if input.KeyCode == Enum.KeyCode.Q then 
            if _G.DashEnabled and not _G.StopAll then
                local char = Services.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hrp = char.HumanoidRootPart
                    local moveDir = char.Humanoid.MoveDirection
                    if moveDir.Magnitude == 0 then moveDir = hrp.CFrame.LookVector end
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "DashVelocity"
                    bv.Velocity = moveDir * _G.DashSpeed
                    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                    bv.P = 5000
                    bv.Parent = hrp
                    Services.Debris:AddItem(bv, 0.25)
                end
            end
        end
        
        if input.KeyCode == Enum.KeyCode.LeftShift then
            _G.BoostEnabled = not _G.BoostEnabled
        end
        
        if input.KeyCode == Enum.KeyCode.Space and _G.FlyEnabled and not _G.StopAll then
            if (tick() - lastSpacePress) < 0.3 then
                _G.IsFlying = not _G.IsFlying
                currentFlyVelocity = Vector3.new(0, 0, 0)
                if not _G.IsFlying and Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Services.LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end
            lastSpacePress = tick()
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        keysDown[input.KeyCode] = nil
    end)

    -- Main RenderStepped Loop
    Services.RunService.RenderStepped:Connect(function()
        -- ESP
        if _G.ESPEnabled then
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= Services.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    local espBox = ESPHolder:FindFirstChild(player.Name)
                    if not espBox then
                        espBox = Instance.new("BillboardGui", ESPHolder)
                        espBox.Name = player.Name
                        espBox.Size = UDim2.new(0, 100, 0, 50)
                        espBox.StudsOffset = Vector3.new(0, 2, 0)
                        espBox.AlwaysOnTop = true
                        local nl = Instance.new("TextLabel", espBox)
                        nl.Name = "NameLabel"
                        nl.Size = UDim2.new(1,0,1,0)
                        nl.BackgroundTransparency = 1
                        nl.TextColor3 = Color3.white
                        nl.TextStrokeTransparency = 0
                        nl.TextSize = 14
                        nl.Font = Enum.Font.SourceSansBold
                        local dl = Instance.new("TextLabel", espBox)
                        dl.Name = "DistLabel"
                        dl.Size = UDim2.new(1,0,0.5,0)
                        dl.Position = UDim2.new(0,0,0.8,0)
                        dl.BackgroundTransparency = 1
                        dl.TextColor3 = Color3.new(0.8,0.8,0.8)
                        dl.TextStrokeTransparency = 0
                        dl.TextSize = 12
                        dl.Font = Enum.Font.SourceSans
                    end
                    if espBox.Adornee ~= head then espBox.Adornee = head end
                    local myRoot = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and (myRoot.Position - head.Position).Magnitude or 0
                    espBox.NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                    espBox.DistLabel.Text = math.floor(dist) .. " m"
                else
                    if ESPHolder:FindFirstChild(player.Name) then ESPHolder[player.Name]:Destroy() end
                end
            end
        elseif #ESPHolder:GetChildren() > 0 then
            ESPHolder:ClearAllChildren()
        end

        if _G.StopAll then return end
        
        local char = Services.LocalPlayer.Character
        if not char then return end
        
        local hrp, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
        
        -- Noclip
        if _G.Noclip then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
        
        -- Fly Physics
        if _G.IsFlying and hrp and hum then
            hum.PlatformStand = true
            hum.AutoRotate = false
            local bv = hrp:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            local bg = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", hrp)
            bg.Name = "FlyGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            local moveDir = hum.MoveDirection
            local cam = workspace.CurrentCamera
            if moveDir.Magnitude > 0 then
                local lookY = cam.CFrame.LookVector.Y
                moveDir = Vector3.new(moveDir.X, moveDir.Y + (lookY * 2), moveDir.Z).Unit
            end
            if keysDown[Enum.KeyCode.Space] or _G.MobileFlyUp then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
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
        
        -- Lock Position for Auto Fish
        if _G.AutoFish and _G.LockPosition and currentSpot and not _G.IsFlying and hrp then
            hrp.CFrame = currentSpot
            hrp.Velocity = Vector3.zero
        end
        
        -- WalkSpeed & JumpPower
        if hum and not _G.IsFlying then
            if _G.WalkSpeedEnabled then hum.WalkSpeed = _G.WalkSpeed end
            if _G.JumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = _G.JumpPower end
        end
        
        -- Frozen Bar
        if _G.AutoFish and _G.FrozenBar then
            local bar = Services.LocalPlayer.PlayerGui:FindFirstChild("reel") and Services.LocalPlayer.PlayerGui.reel:FindFirstChild("bar")
            if bar and bar:FindFirstChild("playerbar") then
                bar.playerbar.Size = UDim2.new(1,0,1,0)
                bar.playerbar.Position = UDim2.new(0,0,0,0)
                bar.playerbar.AnchorPoint = Vector2.new(0,0)
                bar.playerbar.BackgroundColor3 = Color3.new(1,1,1)
            end
        end
    end)
end

return Character
