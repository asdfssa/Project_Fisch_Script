-- ============================================
-- AUTO SELL MODULE - Auto Sell All (ต้นฉบับ)
-- ============================================

local AutoSell = {}
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdfssa/Project_Fisch_Script/main/modules/utils/Utils.lua"))()

function AutoSell.Start()
    task.spawn(function()
        while true do
            if _G.AutoSellAll and not _G.StopAll then
                local remote = Utils.FindSellAllRemote()
                if remote then
                    pcall(function() remote:InvokeServer() end)
                end
                task.wait(_G.SellAllInterval or 5)
            else
                task.wait(1)
            end
        end
    end)
end

return AutoSell
