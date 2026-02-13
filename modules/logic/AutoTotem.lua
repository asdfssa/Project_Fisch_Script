-- ============================================
-- AUTO TOTEM MODULE - ระบบใช้ Totem อัตโนมัติ
-- ============================================

local AutoTotem = {}

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

function AutoTotem.Start(config, state, utils, mainUI)
    local currentPeriodStatus = nil
    local hasUsedTotem = false
    local hasFixedEclipse = false
    local lastGameTime = -1
    local lastRealTime = tick()

    -- ตัวแปรกันตีกัน
    config.ProcessingTotem = false

    local function UseTotemItem(name, reason)
        if not utils.HasItem(name) then
            return false
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            return false
        end

        -- 1. ประกาศสถานะว่ากำลังทำงาน
        config.ProcessingTotem = true

        -- 2. สั่งหยุดตกปลาแบบหักดิบ
        local wasFishing = config.AutoFish
        if wasFishing then
            config.AutoFish = false
            if mainUI.Options and mainUI.Options.AutoFish then
                mainUI.Options.AutoFish:SetValue(false)
            end

            -- เคลียร์เบ็ดออกจากมือ
            local attempts = 0
            repeat
                hum:UnequipTools()
                task.wait(0.2)
                attempts = attempts + 1
            until not char:FindFirstChildWhichIsA("Tool") or attempts > 10

            task.wait(0.5)
        end

        local success = false
        local totem = LocalPlayer.Backpack:FindFirstChild(name)
        if not totem then
            totem = char:FindFirstChild(name)
        end

        if totem then
            mainUI.Notify("Auto Totem", "⏳ กำลังใช้: " .. name, 2)

            -- พยายามถือ Totem
            hum:EquipTool(totem)
            task.wait(1)

            -- เช็ควินาทีสุดท้ายว่าถือ Totem อยู่จริงไหม
            local heldItem = char:FindFirstChildWhichIsA("Tool")

            if heldItem and heldItem.Name == name then
                -- ถือถูกอันแล้ว -> กดใช้
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.2)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                mainUI.Notify("Auto Totem", "ใช้สำเร็จ!", 3)
                task.wait(2.5)
                hum:UnequipTools()
                success = true
            else
                -- ถือผิดอัน
                mainUI.Notify("Auto Totem", "โดนขัดจังหวะ! กำลังลองใหม่...", 2)
                success = false
            end
        end

        -- 5. คืนค่าสถานะ และกลับไปตกปลา
        config.ProcessingTotem = false

        if wasFishing then
            task.wait(0.5)
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

        return success
    end

    task.spawn(function()
        while true do
            task.wait(1)

            if config.AutoTotem and not config.StopAll then
                local currentTime = Lighting.ClockTime

                -- เช็คเวลาค้าง (Eclipse Fix)
                if currentTime ~= lastGameTime then
                    lastGameTime = currentTime
                    lastRealTime = tick()
                end
                local timeFrozen = tick() - lastRealTime

                -- [Case 1] แก้บัค Eclipse
                if currentTime >= 2.0 and currentTime <= 2.3 and timeFrozen > 10 then
                    if not hasFixedEclipse then
                        if UseTotemItem(config.DayTotemSelect, "Fix Eclipse") then
                            hasFixedEclipse = true
                            lastRealTime = tick()
                            task.wait(10)
                            currentPeriodStatus = nil
                            hasUsedTotem = false
                        end
                    end
                else
                    hasFixedEclipse = false
                end

                -- [Case 2] เปลี่ยนเวลาปกติ
                if not hasFixedEclipse then
                    local newPeriod = (currentTime >= 6.55 and currentTime < 18.05) and "Day" or "Night"

                    -- รีเซ็ตสถานะเมื่อเวลาเปลี่ยน
                    if newPeriod ~= currentPeriodStatus then
                        currentPeriodStatus = newPeriod
                        hasUsedTotem = false
                    end

                    -- ถ้ายังใช้ไม่สำเร็จ ให้พยายามใช้ซ้ำๆ
                    if not hasUsedTotem then
                        local targetTotem = (currentPeriodStatus == "Day") and config.DayTotemSelect or config.NightTotemSelect

                        if targetTotem and targetTotem ~= "" then
                            local result = UseTotemItem(targetTotem, "Change Time")
                            if result then
                                hasUsedTotem = true
                            end
                        end
                    end
                end
            else
                -- Reset เมื่อปิด Auto Totem
                currentPeriodStatus = nil
                hasUsedTotem = false
            end
        end
    end)
end

return AutoTotem
