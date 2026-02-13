-- ============================================
-- CHARACTER MODULE - ระบบควบคุมตัวละคร (Fly, ESP, etc.)
-- ============================================

local Character = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ESP Holder
local ESPHolder = Instance.new("Folder", CoreGui)
ESPHolder.Name = "FischESPHolder"

-- State
local currentFlyVelocity = Vector3.new(0, 0, 0)
local keysDown = {}
local lastSpacePress = 0

function Character.Start(config, state, utils, flyUI)
    -- Setup Input Handling
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then
            return
        end
        keysDown[input.KeyCode] = true

        -- Dash
        if input.KeyCode == Enum.KeyCode.Q then
            if config.DashEnabled and not config.StopAll then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hrp = char.HumanoidRootPart
                    local moveDir = char.Humanoid.MoveDirection
                    if moveDir.Magnitude == 0 then
                        moveDir = hrp.CFrame.LookVector
                    end
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "DashVelocity"
                    bv.Velocity = moveDir * config.DashSpeed
                    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                    bv.P = 5000
                    bv.Parent = hrp
                    game:GetService("Debris"):AddItem(bv, 0.25)
                end
            end
        end

        -- Boost Toggle
        if input.KeyCode == Enum.KeyCode.LeftShift then
            config.BoostEnabled = not config.BoostEnabled
        end

        -- Fly Toggle (Double Space)
        if input.KeyCode == Enum.KeyCode.Space and config.FlyEnabled and not config.StopAll then
            if (tick() - lastSpacePress) < 0.3 then
                config.IsFlying = not config.IsFlying
                currentFlyVelocity = Vector3.new(0, 0, 0)
                if not config.IsFlying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end
            lastSpacePress = tick()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        keysDown[input.KeyCode] = nil
    end)

    -- Main Render Loop
    RunService.RenderStepped:Connect(function()
        -- ESP
        if config.ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
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
                        nl.Size = UDim2.new(1, 0, 1, 0)
                        nl.BackgroundTransparency = 1
                        nl.TextColor3 = Color3.white
                        nl.TextStrokeTransparency = 0
                        nl.TextSize = 14
                        nl.Font = Enum.Font.SourceSansBold
                        local dl = Instance.new("TextLabel", espBox)
                        dl.Name = "DistLabel"
                        dl.Size = UDim2.new(1, 0, 0.5, 0)
                        dl.Position = UDim2.new(0, 0, 0.8, 0)
                        dl.BackgroundTransparency = 1
                        dl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                        dl.TextStrokeTransparency = 0
                        dl.TextSize = 12
                        dl.Font = Enum.Font.SourceSans
                    end
                    if espBox.Adornee ~= head then
                        espBox.Adornee = head
                    end
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and (myRoot.Position - head.Position).Magnitude or 0
                    espBox.NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                    espBox.DistLabel.Text = math.floor(dist) .. " m"
                else
                    if ESPHolder:FindFirstChild(player.Name) then
                        ESPHolder[player.Name]:Destroy()
                    end
                end
            end
        elseif #ESPHolder:GetChildren() > 0 then
            ESPHolder:ClearAllChildren()
        end

        -- Stop All Check
        if config.StopAll then
            return
        end

        local char = LocalPlayer.Character
        if not char then
            return
        end

        local hrp, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")

        -- Noclip
        if config.Noclip then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end

        -- Fly Logic
        if config.IsFlying and hrp and hum then
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
            if keysDown[Enum.KeyCode.Space] or config.MobileFlyUp then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            local speed = config.FlySpeed * (config.BoostEnabled and 2.5 or 1.0)
            if moveDir.Magnitude > 0 then
                currentFlyVelocity = currentFlyVelocity:Lerp(moveDir.Unit * speed, 0.2)
                bg.CFrame = bg.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + currentFlyVelocity) * CFrame.Angles(math.rad(-90), 0, 0), 0.2)
            else
                currentFlyVelocity = config.FlyInertia and currentFlyVelocity:Lerp(Vector3.zero, 0.05) or Vector3.zero
                local forward = cam.CFrame.LookVector
                bg.CFrame = bg.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(forward.X, 0, forward.Z)), 0.1)
            end
            bv.Velocity = currentFlyVelocity
        else
            if hrp and hrp:FindFirstChild("FlyVelocity") then
                hrp.FlyVelocity:Destroy()
            end
            if hrp and hrp:FindFirstChild("FlyGyro") then
                hrp.FlyGyro:Destroy()
            end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
        end

        -- Position Lock
        if config.AutoFish and config.LockPosition and state.CurrentSpot and not config.IsFlying and hrp then
            hrp.CFrame = state.CurrentSpot
            hrp.Velocity = Vector3.zero
        end

        -- WalkSpeed & JumpPower
        if hum and not config.IsFlying then
            if config.WalkSpeedEnabled then
                hum.WalkSpeed = config.WalkSpeed
            end
            if config.JumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = config.JumpPower
            end
        end

        -- Frozen Bar
        if config.AutoFish and config.FrozenBar then
            local bar = LocalPlayer.PlayerGui:FindFirstChild("reel") and LocalPlayer.PlayerGui.reel:FindFirstChild("bar")
            if bar and bar:FindFirstChild("playerbar") then
                bar.playerbar.Size = UDim2.new(1, 0, 1, 0)
                bar.playerbar.Position = UDim2.new(0, 0, 0, 0)
                bar.playerbar.AnchorPoint = Vector2.new(0, 0)
                bar.playerbar.BackgroundColor3 = Color3.new(1, 1, 1)
            end
        end

        -- Sync Fly UI Buttons
        if flyUI then
            flyUI.UpdateButtons(config.IsFlying, config.BoostEnabled)
        end
    end)
end

-- Anti AFK
function Character.SetupAntiAFK(config)
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    LocalPlayer.Idled:Connect(function()
        if config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

return Character
