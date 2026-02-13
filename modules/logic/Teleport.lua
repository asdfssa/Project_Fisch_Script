-- ============================================
-- TELEPORT MODULE - ระบบวาร์ป
-- ============================================

local Teleport = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Teleport.ToPosition(x, y, z, state, config)
    if config.StopAll then
        return
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local tp = CFrame.new(tonumber(x) or 0, tonumber(y) or 135, tonumber(z) or 0)
        char.HumanoidRootPart.CFrame = tp
        if config.AutoFish then
            state.CurrentSpot = tp
        end
    end
end

function Teleport.ToLocation(locationName, defaultLocations, customLocations, state, config)
    if config.StopAll then
        return
    end
    local target = defaultLocations[locationName]
    if not target and customLocations[locationName] then
        target = customLocations[locationName]
    end
    if target then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local tp = CFrame.new(target.x, target.y, target.z)
            char.HumanoidRootPart.CFrame = tp
            if config.AutoFish then
                state.CurrentSpot = tp
            end
        end
    end
end

function Teleport.ToPlayer(playerName, state, config)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
            if config.AutoFish then
                state.CurrentSpot = char.HumanoidRootPart.CFrame
            end
            return true
        end
    end
    return false
end

function Teleport.GetCurrentPosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        return math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
    end
    return 0, 135, 0
end

-- Refresh Player List
function Teleport.RefreshPlayerList(dropdown)
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(pList, p.Name)
        end
    end
    table.sort(pList)
    if dropdown then
        dropdown:SetValues(pList)
    end
    return pList
end

-- Refresh Location Lists
function Teleport.RefreshLocationLists(dropdownManager, dropdownWarp, savedLocations, defaultLocations, searchManager, searchWarp)
    local managerList, warpList = {}, {}
    local mQuery = searchManager:lower()
    local wQuery = searchWarp:lower()

    for name, _ in pairs(savedLocations) do
        if mQuery == "" or name:lower():find(mQuery) then
            table.insert(managerList, name)
        end
        if wQuery == "" or name:lower():find(wQuery) then
            table.insert(warpList, name)
        end
    end

    for name, _ in pairs(defaultLocations) do
        if wQuery == "" or name:lower():find(wQuery) then
            table.insert(warpList, name)
        end
    end

    table.sort(managerList)
    table.sort(warpList)

    if dropdownManager then
        dropdownManager:SetValues(managerList)
    end
    if dropdownWarp then
        dropdownWarp:SetValues(warpList)
    end
end

return Teleport
