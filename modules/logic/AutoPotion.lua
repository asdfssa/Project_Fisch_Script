-- ============================================
-- AUTO POTION MODULE - ระบบกิน Potion อัตโนมัติ
-- ============================================

local AutoPotion = {}

-- Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

function AutoPotion.Start(config, state, utils, mainUI, logUI)
    task.spawn(function()
        while true do
            task.wait(1)

            -- เช็คเงื่อนไขพื้นฐาน
            if config.AutoPotion and not config.StopAll and config.PotionRepeatCount > 0 then

                -- ถ้านับถอยหลังหมดแล้ว
                if config.PotionTimer <= 0 then
                    local potionName = config.SelectedPotion

                    -- เช็คว่ามีของในตัวไหม
                    if utils.HasItem(potionName) then

                        -- 1. ประกาศหยุดตกปลา (Hard Stop)
                        local wasFishing = config.AutoFish
                        if wasFishing then
                            config.AutoFish = false
                            if mainUI.Options and mainUI.Options.AutoFish then
                                mainUI.Options.AutoFish:SetValue(false)
                            end

                            mainUI.Notify("Auto Potion", "หยุดตกปลาเพื่อดื่มยา...", 2)
                            task.wait(2)
                        end

                        local char = LocalPlayer.Character
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
                            local potionTool = LocalPlayer.Backpack:FindFirstChild(potionName) or char:FindFirstChild(potionName)

                            if potionTool then
                                hum:EquipTool(potionTool)
                                task.wait(0.8)

                                -- เช็คว่าถือติดจริงไหม
                                local heldItem = char:FindFirstChildWhichIsA("Tool")
                                if heldItem and heldItem.Name == potionName then
                                    mainUI.Notify("Auto Potion", "🧪 กำลังดื่ม: " .. potionName, 3)

                                    -- คลิกดื่ม
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                    task.wait(0.2)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                                    task.wait(2.5)
                                    hum:UnequipTools()

                                    -- สำเร็จ: รีเซ็ตเวลาและลดจำนวน
                                    config.PotionRepeatCount = config.PotionRepeatCount - 1
                                    config.PotionTimer = config.PotionDelayMinutes * 60

                                    if logUI and logUI.AddLog then
                                        logUI.AddLog("Drank: " .. potionName, Color3.fromRGB(100, 255, 100))
                                    end
                                else
                                    -- ถือไม่ติด
                                    mainUI.Notify("Auto Potion", "⚠️ ถือของไม่ติด! กำลังลองใหม่...", 2)
                                    hum:UnequipTools()
                                end
                            end
                        end

                        -- 4. กลับไปตกปลา (ถ้าเดิมเปิดไว้)
                        if wasFishing then
                            task.wait(1)
                            config.AutoFish = true
                            if mainUI.Options and mainUI.Options.AutoFish then
                                mainUI.Options.AutoFish:SetValue(true)
                            end

                            -- ช่วยถือเบ็ดกลับคืน
                            local rod = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                            if not rod then
                                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                                    if v:IsA("Tool") and v.Name:find("Rod") then
                                        rod = v
                                        break
                                    end
                                end
                            end
                            if rod then
                                hum:EquipTool(rod)
                            end
                        end

                    else
                        -- ถ้าไม่มีของ
                        mainUI.Notify("Auto Potion", "หา " .. potionName .. " ไม่เจอ!", 3)
                        task.wait(5)
                    end
                else
                    -- นับถอยหลังตามปกติ
                    config.PotionTimer = config.PotionTimer - 1
                end
            end
        end
    end)
end

return AutoPotion
