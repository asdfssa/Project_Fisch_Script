-- ============================================
-- UTILS MODULE - Helper Functions (ต้นฉบับ)
-- ============================================

local Utils = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/services/Services.lua"))()
local FileName = "Fisch_FarmHub_Locations.json"

-- File Operations
function Utils.LoadCustomLocations()
    if isfile and isfile(FileName) then
        local success, result = pcall(function() return Services.HttpService:JSONDecode(readfile(FileName)) end)
        if success then return result end
    end
    return {}
end

function Utils.SaveCustomLocations(data)
    if writefile then writefile(FileName, Services.HttpService:JSONEncode(data)) end
end

-- Item & Money
function Utils.hasItem(itemName)
    return (Services.LocalPlayer.Backpack:FindFirstChild(itemName) or (Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild(itemName))) ~= nil
end

function Utils.getMoney()
    local ls = Services.LocalPlayer:FindFirstChild("leaderstats")
    local coin = ls and ls:FindFirstChild("C$") or ls:FindFirstChild("Cash")
    return coin and coin.Value or 0
end

-- Remote Functions
function Utils.FindSellAllRemote()
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("SellAll") or events:FindFirstChild("sellall")
    end
    return nil
end

function Utils.FindSellHandRemote()
    local targetPath = "packages/Net/RF/Merchant/Sell"
    local parts = string.split(targetPath, "/")
    local current = Services.ReplicatedStorage
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
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if events then
        return events:FindFirstChild("purchase")
    end
    return nil
end

function Utils.FindRemote(name)
    local target = Services.ReplicatedStorage:FindFirstChild("packages")
    if target and target:FindFirstChild("Net") then
        local re = target.Net:FindFirstChild("RE/"..name)
        if re then return re end
    end
    return nil
end

-- Auto Fish Helpers
function Utils.CleanStack()
    local pg = Services.LocalPlayer.PlayerGui
    if pg:FindFirstChild("reel") then pg.reel:Destroy() end
    if pg:FindFirstChild("shakeui") then pg.shakeui:Destroy() end
end

function Utils.ForceEquipRod()
    local char = Services.LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name:lower():find("rod") then return tool end
    local backpack = Services.LocalPlayer.Backpack
    local rod = nil
    for _, v in pairs(backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then rod = v; break end
    end
    if rod then
        char.Humanoid:EquipTool(rod); task.wait(0.2); return char:FindFirstChildWhichIsA("Tool")
    else
        Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game); task.wait(0.3); return char:FindFirstChildWhichIsA("Tool")
    end
end

function Utils.IsUIActive()
    local pg = Services.LocalPlayer.PlayerGui
    local hasShake = pg:FindFirstChild("shakeui") and pg.shakeui.Enabled
    local hasReel = pg:FindFirstChild("reel") and pg.reel.Enabled
    return hasShake or hasReel
end

-- Shake Detection (from original script)
function Utils.FastShake(obj)
    if not _G.AutoShake then return end

    if obj.Name == "shake" and obj:IsA("RemoteEvent") then
        local parentUI = obj.Parent
        if parentUI and parentUI:IsA("GuiObject") then
            if _G.HideShakeUI then
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

-- Format Functions
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

return Utils
