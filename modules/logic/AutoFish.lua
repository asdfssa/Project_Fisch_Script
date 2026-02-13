-- ============================================
-- AUTO FISH MODULE - ระบบตกปลาอัตโนมัติ (ต้นฉบับ)
-- ============================================

local AutoFish = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/utils/Utils.lua"))()

function AutoFish.Start()
    local finishRemote = Utils.FindRemote("Reel/Finish")
    
    task.spawn(function()
        while true do
            task.wait(0.1)
            
            if not _G.StopAll and _G.AutoFish then
                local char = Services.LocalPlayer.Character
                if not char then continue end
                
                -- เช็คเครื่องมือ
                local currentTool = char:FindFirstChildWhichIsA("Tool")
                if currentTool and currentTool.Name:lower():find("rod") then
                    if not Utils.IsUIActive() then
                        char.Humanoid:UnequipTools(); task.wait(0.1)
                    end
                end
                
                local rod = Utils.ForceEquipRod()
                if rod and rod:FindFirstChild("events") then
                    local castRemote = rod.events:FindFirstChild("castAsync")
                    if castRemote then
                        -- 1. เหวี่ยงเบ็ด
                        local castSuccess = pcall(function() castRemote:InvokeServer(100, 1, false) end)
                        if not castSuccess then warn("Cast failed, retrying..."); continue end
                        
                        local fishBited = false
                        local startTime = tick()
                        local lastActiveTime = tick()
                        
                        local maxTotalWait = 30
                        local noActivityTimeout = 3.5
                        
                        while _G.AutoFish and not _G.StopAll do
                            local currentTime = tick()
                            
                            if Utils.IsUIActive() then
                                lastActiveTime = currentTime
                            end
                            
                            if char.Humanoid.MoveDirection.Magnitude > 0 then
                                lastActiveTime = currentTime
                            end

                            if Services.LocalPlayer.PlayerGui:FindFirstChild("reel") then 
                                fishBited = true 
                                break 
                            end
                            
                            -- เงื่อนไขจบ: เบ็ดหลุดมือ
                            if not char:FindFirstChild(rod.Name) then break end
                            
                            -- ระบบตัดบัค (Smart Timeout)
                            if currentTime - lastActiveTime > noActivityTimeout then break end
                            if currentTime - startTime > maxTotalWait then break end
                            
                            task.wait(0.05)
                        end
                        
                        -- 2. ถ้าปลามาแล้ว ดึง
                        if fishBited then
                            task.wait(_G.ReelDelay)
                            if finishRemote then
                                pcall(function() finishRemote:FireServer({ ["e"] = 100, ["p"] = _G.AlwaysPerfect, ["l"] = {} }) end)
                                _G.AddLog("🎣 Fish Caught!", Color3.fromRGB(0, 255, 255))
                            end
                        end
                        
                        task.wait(_G.CastDelay)
                        Utils.CleanStack()
                        if char:FindFirstChild("Humanoid") then char.Humanoid:UnequipTools() end
                    end
                end
            end
        end
    end)
end

function AutoFish.SetupShakeDetection()
    Services.LocalPlayer.PlayerGui.DescendantAdded:Connect(Utils.FastShake)
    for _, v in pairs(Services.LocalPlayer.PlayerGui:GetDescendants()) do
        Utils.FastShake(v)
    end
end

return AutoFish
