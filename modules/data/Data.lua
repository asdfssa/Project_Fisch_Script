-- ============================================
-- DATA MODULE - ตารางข้อมูลต่างๆ
-- ============================================

local Data = {}

-- 📍 Default Locations
Data.DefaultLocations = {
    ["Moosewood (Spawn)"] = {x=380, y=135, z=220},
    ["Roslit Bay"] = {x=-1485, y=132, z=720},
    ["Terrapin Island"] = {x=-16, y=135, z=1540},
    ["Snowcap Island"] = {x=2610, y=135, z=2435},
    ["Sunstone Island"] = {x=-930, y=132, z=-1125},
    ["Statue of Sovereignty"] = {x=40, y=135, z=-1020},
    ["Mushgrove Swamp"] = {x=2440, y=132, z=-700},
    ["Keepers Altar"] = {x=1300, y=-225, z=-380},
    ["Desolate Deep"] = {x=-1650, y=-210, z=2840},
    ["Archeological Site"] = {x=4150, y=135, z=245},
    ["Vertigo (Entrance)"] = {x=-110, y=-510, z=1050},
    ["The Depths"] = {x=990, y=-710, z=1250},
    ["(Secret) Event Zone"] = {x=20654, y=140, z=-18005},
    ["Enchant"] = {x=1309, y=-806, z=-103},
    ["Coral Bastion"] = {x=2523, y=-1097, z=858}
}

-- 🎣 Rod List with Prices
Data.RodList = {
    {Name = "Training Rod", Price = 300},
    {Name = "Plastic Rod", Price = 750},
    {Name = "Carbon Rod", Price = 2000},
    {Name = "Stone Rod", Price = 2000},
    {Name = "Long Rod", Price = 3000},
    {Name = "Fast Rod", Price = 4000},
    {Name = "Lucky Rod", Price = 4500},
    {Name = "Steady Rod", Price = 7000},
    {Name = "Firefly Rod", Price = 9500},
    {Name = "Fortune Rod", Price = 11000},
    {Name = "Rapid Rod", Price = 12000},
    {Name = "Frog Rod", Price = 12000},
    {Name = "Magnet Rod", Price = 15000},
    {Name = "Brine-Infused Rod", Price = 15000},
    {Name = "Merchant Rod", Price = 20000},
    {Name = "Reinforced Rod", Price = 20000},
    {Name = "Arctic Rod", Price = 25000},
    {Name = "Coral Rod", Price = 30000},
    {Name = "Crystalized Rod", Price = 35000},
    {Name = "Avalanche Rod", Price = 35000},
    {Name = "Firework Rod", Price = 35000},
    {Name = "Wildflower Rod", Price = 40000},
    {Name = "Depthseeker Rod", Price = 40000},
    {Name = "Scurvy Rod", Price = 40000},
    {Name = "Boreal Rod", Price = 42000},
    {Name = "Cinder Block Rod", Price = 50000},
    {Name = "The Boom Ball", Price = 50000},
    {Name = "Verdant Shear Rod", Price = 50000},
    {Name = "Phoenix Rod", Price = 50000},
    {Name = "Treasure Rod", Price = 50000},
    {Name = "Midas Rod", Price = 55000},
    {Name = "Ice Warpers Rod", Price = 65000},
    {Name = "Blazebringer Rod", Price = 70000},
    {Name = "Aurora Rod", Price = 70000},
    {Name = "Paper Fan Rod", Price = 70000},
    {Name = "Carrot Rod", Price = 75000},
    {Name = "Meteor Totem", Price = 75000},
    {Name = "Champions Rod", Price = 90000},
    {Name = "Mythical Rod", Price = 90000},
    {Name = "Azure Of Lagoon", Price = 100000},
    {Name = "Kings Rod", Price = 100000},
    {Name = "Fallen Rod", Price = 175000},
    {Name = "Scarlet Spincaster Rod", Price = 180000},
    {Name = "Destiny Rod", Price = 190000},
    {Name = "Free Spirit Rod", Price = 200000},
    {Name = "Volcanic Rod", Price = 250000},
    {Name = "Rainbow Cluster Rod", Price = 250000},
    {Name = "Leviathan's Fang Rod", Price = 350000},
    {Name = "Wicked Fang Rod", Price = 400000},
    {Name = "Tempest Rod", Price = 500000},
    {Name = "Summit Rod", Price = 500000},
    {Name = "Poseidon Rod", Price = 700000},
    {Name = "Great Dreamer Rod", Price = 700000},
    {Name = "Tidemourner Head", Price = 750000},
    {Name = "Challenger's Rod", Price = 750000},
    {Name = "Rod Of The Depths", Price = 750000},
    {Name = "Cerulean Fang Rod", Price = 800000},
    {Name = "Zeus Rod", Price = 850000},
    {Name = "Abyssal Specter Rod", Price = 850000},
    {Name = "Kraken Rod", Price = 950000},
    {Name = "Luminescent Oath", Price = 1000000},
    {Name = "Rod Of The Zenith", Price = 1500000},
    {Name = "Frostbane Rod", Price = 1500000},
    {Name = "Heaven's Rod", Price = 1750000},
    {Name = "Eidolon Rod", Price = 2000000},
    {Name = "Great Rod of Oscar", Price = 2500000},
    {Name = "Maelstrom", Price = 3250000},
    {Name = "Cryolash", Price = 3500000},
    {Name = "Ethereal Prism Rod", Price = 3500000},
    {Name = "Ruinous Oath", Price = 5000000},
    {Name = "Sanguine Spire", Price = 10000000},
    {Name = "Thalassar's Ruin", Price = 14500000},
    {Name = "Original No-Life Rod", Price = 1}
}

-- 🗿 Totem Data
Data.TotemData = {
    {Name = "Tempest Totem", Price = 2000},
    {Name = "Windset Totem", Price = 2000},
    {Name = "Sundial Totem", Price = 2000},
    {Name = "Smokescreen Totem", Price = 2000},
    {Name = "Clearcast Totem", Price = 2000},
    {Name = "Meteor Totem", Price = 75000},
    {Name = "Blue Moon Totem", Price = 75000},
    {Name = "Eclipse Totem", Price = 75000},
    {Name = "Blizzard Totem", Price = 75000},
    {Name = "Avalanche Totem", Price = 75000},
    {Name = "Aurora Totem", Price = 500000}
}

-- Generate Totem Name List
Data.TotemList = {}
for _, v in ipairs(Data.TotemData) do
    table.insert(Data.TotemList, v.Name)
end

-- 🧪 Potion List
Data.PotionList = {
    "Luck Potion",
    "Lure Speed Potion",
    "All Season Potion",
    "Glitched Potion",
    "Abyssal Tonic",
    "Ghost Elixir",
    "Fortune Potion",
    "Hasty Potion",
    "Sea Traveler Note"
}

-- Helper: Get Rod Names only
function Data.GetRodNames()
    local names = {}
    for _, v in ipairs(Data.RodList) do
        table.insert(names, v.Name)
    end
    return names
end

-- Helper: Get Rod Price
function Data.GetRodPrice(rodName)
    for _, v in ipairs(Data.RodList) do
        if v.Name == rodName then
            return v.Price
        end
    end
    return 0
end

-- Helper: Get Totem Price
function Data.GetTotemPrice(totemName)
    for _, v in ipairs(Data.TotemData) do
        if v.Name == totemName then
            return v.Price
        end
    end
    return 0
end

return Data
