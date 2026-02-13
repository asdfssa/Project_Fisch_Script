-- ============================================
-- AUTO FISH MODULE - ระบบตกปลาอัตโนมัติ
-- ============================================

local AutoFish = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

function AutoFish.Start(config, state, utils, logUI, mainUI)
    local finishRemote = utils.FindRemote("Reel/Finish")
    print("[Debug] AutoFish.Start called, finishRemote:", finishRemote)

    task.spawn(function()
        local loopCount = 0
        while true do
            task.wait(0.1)
            loopCount = loopCount + 1
            
            if loopCount <= 5 then
                print("[Debug] AutoFish loop", loopCount, "StopAll:", config.StopAll, "AutoFish:", config.AutoFish)
            elseif loopCount == 6 then
                print("[Debug] AutoFish loop running normally... (suppressing further debug)")
            end

            if not config.StopAll and config.AutoFish then
                local char = LocalPlayer.Character
                if not char then
                    continue
                end

                -- เช็คเครื่องมือ
                local currentTool = char:FindFirstChildWhichIsA("Tool")
                if currentTool and currentTool.Name:lower():find("rod") then
                    if not utils.IsUIActive() then
                        char.Humanoid:UnequipTools()
                        task.wait(0.1)
                    end
                end

                local rod = utils.ForceEquipRod()
                if rod and rod:FindFirstChild("events") then
                    local castRemote = rod.events:FindFirstChild("castAsync")
                    if castRemote then
                        -- 1. เหวี่ยงเบ็ด
                        local castSuccess = pcall(function()
                            castRemote:InvokeServer(100, 1, false)
                        end)
                        if not castSuccess then
                            warn("Cast failed, retrying...")
                            continue
                        end

                        local fishBited = false
                        local startTime = tick()
                        local lastActiveTime = tick()

                        local maxTotalWait = 30
                        local noActivityTimeout = 3.5

                        while config.AutoFish and not config.StopAll do
                            local currentTime = tick()

                            if utils.IsUIActive() then
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
                            if not char:FindFirstChild(rod.Name) then
                                break
                            end

                            -- 1. ถ้าเงียบกริบเกิน 8 วิ -> ตัดจบ
                            if currentTime - lastActiveTime > noActivityTimeout then
                                break
                            end

                            -- 2. ถ้ารอนานเกิน 30 วิ -> ตัดจบ
                            if currentTime - startTime > maxTotalWait then
                                break
                            end

                            task.wait(0.05)
                        end

                        -- 2. ถ้าปลามาแล้ว ดึง
                        if fishBited then
                            task.wait(config.ReelDelay)
                            if finishRemote then
                                pcall(function()
                                    finishRemote:FireServer({
                                        ["e"] = 100,
                                        ["p"] = config.AlwaysPerfect,
                                        ["l"] = {}
                                    })
                                end)
                                if logUI and logUI.AddLog then
                                    logUI.AddLog("🎣 Fish Caught!", Color3.fromRGB(0, 255, 255))
                                end
                            end
                        end

                        task.wait(config.CastDelay)
                        utils.CleanStack()
                        if char:FindFirstChild("Humanoid") then
                            char.Humanoid:UnequipTools()
                        end
                    end
                end
            end
        end
    end)
end

-- Setup Shake Detection
function AutoFish.SetupShakeDetection(utils, config)
    local function FastShakeHandler(obj)
        utils.FastShake(obj, config.AutoShake, config.HideShakeUI)
    end

    LocalPlayer.PlayerGui.DescendantAdded:Connect(FastShakeHandler)
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        FastShakeHandler(v)
    end
end

return AutoFish
