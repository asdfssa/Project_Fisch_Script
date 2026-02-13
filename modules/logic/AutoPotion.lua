-- ============================================
-- AUTO POTION MODULE - Auto Potion Timer (ต้นฉบับ)
-- ============================================

local AutoPotion = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()

function AutoPotion.Start()
    task.spawn(function()
        while true do
            task.wait(1)
            
            if _G.AutoPotion and not _G.StopAll and _G.PotionRepeatCount > 0 then
                if _G.PotionTimer <= 0 then
                    local potionName = _G.SelectedPotion
                    
                    -- เช็คว่ามีของในตัวไหม
                    local hasItem = (Services.LocalPlayer.Backpack:FindFirstChild(potionName) or 
                                    (Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild(potionName))) ~= nil
                    
                    if hasItem then
                        -- 1. ประกาศหยุดตกปลา (Hard Stop)
                        local wasFishing = _G.AutoFish
                        if wasFishing then
                            _G.AutoFish = false
                            task.wait(2)
                        end

                        local char = Services.LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        
                        if char and hum and hum.Health > 0 then
                            -- 2. เคลียร์มือให้ว่าง
                            for i = 1, 5 do
                                if char:FindFirstChildWhichIsA("Tool") then
                                    hum:UnequipTools()
                                    task.wait(0.2)
                                else
                                    break
                                end
                            end
                            
                            -- 3. พยายามถือและดื่มยา
                            local potionTool = Services.LocalPlayer.Backpack:FindFirstChild(potionName) or char:FindFirstChild(potionName)
                            
                            if potionTool then
                                hum:EquipTool(potionTool)
                                task.wait(0.8)
                                
                                local heldItem = char:FindFirstChildWhichIsA("Tool")
                                if heldItem and heldItem.Name == potionName then
                                    -- คลิกดื่ม
                                    Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                    task.wait(0.2)
                                    Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                    
                                    task.wait(2.5)
                                    hum:UnequipTools()
                                    
                                    _G.PotionRepeatCount = _G.PotionRepeatCount - 1
                                    _G.PotionTimer = _G.PotionDelayMinutes * 60
                                else
                                    hum:UnequipTools()
                                end
                            end
                        end
                        
                        -- 4. กลับไปตกปลา
                        if wasFishing then
                            task.wait(1)
                            _G.AutoFish = true
                            
                            local rod = Services.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                            if not rod then 
                                for _, v in pairs(Services.LocalPlayer.Backpack:GetChildren()) do
                                    if v:IsA("Tool") and v.Name:find("Rod") then rod = v; break end
                                end
                            end
                            if rod then hum:EquipTool(rod) end
                        end
                    else
                        task.wait(5)
                    end
                else
                    _G.PotionTimer = _G.PotionTimer - 1
                end
            end
        end
    end)
end

return AutoPotion
