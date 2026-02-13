-- ============================================
-- UTILS MODULE - ฟังก์ชัน Helper ต่างๆ
-- ============================================

local Utils = {}

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 💾 File Operations
function Utils.LoadCustomLocations(fileName)
    if isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success then
            return result
        end
    end
    return {}
end

function Utils.SaveCustomLocations(fileName, data)
    if writefile then
        writefile(fileName, HttpService:JSONEncode(data))
    end
end

-- 💰 Money & Items
function Utils.HasItem(itemName)
    return (LocalPlayer.Backpack:FindFirstChild(itemName) or
            (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName))) ~= nil
end

function Utils.GetMoney()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local coin = ls and (ls:FindFirstChild("C$") or ls:FindFirstChild("Cash"))
    return coin and coin.Value or 0
end

-- 📡 Remote Functions
function Utils.FindSellAllRemote()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("SellAll") or events:FindFirstChild("sellall")
    end
    return nil
end

function Utils.FindSellHandRemote()
    local targetPath = "packages/Net/RF/Merchant/Sell"
    local parts = string.split(targetPath, "/")
    local current = ReplicatedStorage
    for _, part in ipairs(parts) do
        if current:FindFirstChild(part) then
            current = current[part]
        else
            return nil
        end
    end
    if current and current:IsA("RemoteFunction") then
        return current
    end
    return nil
end

function Utils.GetPurchaseRemote()
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("purchase")
    end
    return nil
end

function Utils.FindRemote(name)
    local target = ReplicatedStorage:FindFirstChild("packages")
    if target and target:FindFirstChild("Net") then
        local re = target.Net:FindFirstChild("RE/" .. name)
        if re then
            return re
        end
    end
    return nil
end

-- ⏰ Time Formatting
function Utils.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function Utils.FormatGameTime(clockTime)
    local hours = math.floor(clockTime)
    local minutes = math.floor((clockTime - hours) * 60)
    return string.format("%02d:%02d", hours, minutes)
end

-- 🎯 Equipment Helpers
function Utils.ForceEquipRod()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name:lower():find("rod") then
        return tool
    end
    local backpack = LocalPlayer.Backpack
    local rod = nil
    for _, v in pairs(backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then
            rod = v
            break
        end
    end
    if rod then
        char.Humanoid:EquipTool(rod)
        task.wait(0.2)
        return char:FindFirstChildWhichIsA("Tool")
    else
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
        task.wait(0.3)
        return char:FindFirstChildWhichIsA("Tool")
    end
end

function Utils.CleanStack()
    local pg = LocalPlayer.PlayerGui
    if pg:FindFirstChild("reel") then
        pg.reel:Destroy()
    end
    if pg:FindFirstChild("shakeui") then
        pg.shakeui:Destroy()
    end
end

function Utils.IsUIActive()
    local pg = LocalPlayer.PlayerGui
    local hasShake = pg:FindFirstChild("shakeui") and pg.shakeui.Enabled
    local hasReel = pg:FindFirstChild("reel") and pg.reel.Enabled
    return hasShake or hasReel
end

-- 🌊 UI Detection
function Utils.FastShake(obj, autoShake, hideShakeUI)
    if not autoShake then
        return
    end
    if obj.Name == "shake" and obj:IsA("RemoteEvent") then
        local parentUI = obj.Parent
        if parentUI and parentUI:IsA("GuiObject") then
            if hideShakeUI then
                parentUI.Visible = false
            else
                parentUI.Visible = true
            end
        end
        obj:FireServer()
        task.delay(0.1, function()
            obj:FireServer()
        end)
    end
end

return Utils
