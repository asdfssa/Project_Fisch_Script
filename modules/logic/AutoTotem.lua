-- ============================================
-- AUTO TOTEM MODULE - Smart Auto Totem (ต้นฉบับ)
-- ============================================

local AutoTotem = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/utils/Utils.lua"))()

function AutoTotem.Start()
    local currentPeriodStatus = nil 
    local hasUsedTotem = false 
    local hasFixedEclipse = false 
    local lastGameTime = -1       
    local lastRealTime = tick()
    
    -- ตัวแปรกันตีกัน
    _G.ProcessingTotem = false

    local function UseTotemItem(name, reason)
        if not Utils.hasItem(name) then return false end
        
        local char = Services.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        -- 1. ประกาศสถานะว่ากำลังทำงาน
        _G.ProcessingTotem = true
        
        -- 2. สั่งหยุดตกปลาแบบหักดิบ
        local wasFishing = _G.AutoFish
        if wasFishing then
            _G.AutoFish = false
            
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
        local totem = Services.LocalPlayer.Backpack:FindFirstChild(name)
        if not totem then totem = char:FindFirstChild(name) end

        if totem then
            -- 3. พยายามถือ Totem
            hum:EquipTool(totem)
            task.wait(1) 
            
            -- 4. เช็ควินาทีสุดท้ายว่าถือ Totem อยู่จริงไหม
            local heldItem = char:FindFirstChildWhichIsA("Tool")
            
            if heldItem and heldItem.Name == name then
                -- ถือถูกอันแล้ว -> กดใช้
                Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.2)
                Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                task.wait(2.5)
                hum:UnequipTools()
                success = true
            else
                -- ถือผิดอัน
                success = false
            end
        end

        -- 5. คืนค่าสถานะ และกลับไปตกปลา
        _G.ProcessingTotem = false
        
        if wasFishing then
            task.wait(0.5)
            _G.AutoFish = true
            
            -- ช่วยถือเบ็ดกลับคืน
            local rod = Services.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
            if not rod then 
                for _, v in pairs(Services.LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Rod") then rod = v; break end
                end
            end
            if rod then hum:EquipTool(rod) end
        end
        
        return success
    end

    task.spawn(function()
        while true do
            task.wait(1)
            
            if _G.AutoTotem and not _G.StopAll then
                local Lighting = game:GetService("Lighting")
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
                        if UseTotemItem(_G.DayTotemSelect, "Fix Eclipse") then
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
                    
                    if newPeriod ~= currentPeriodStatus then
                        currentPeriodStatus = newPeriod
                        hasUsedTotem = false 
                    end

                    if not hasUsedTotem then
                        local targetTotem = (currentPeriodStatus == "Day") and _G.DayTotemSelect or _G.NightTotemSelect
                        
                        if targetTotem and targetTotem ~= "" then
                            local result = UseTotemItem(targetTotem, "Change Time")
                            if result then
                                hasUsedTotem = true
                            end
                        end
                    end
                end
            else
                currentPeriodStatus = nil
                hasUsedTotem = false
            end
        end
    end)
end

return AutoTotem
