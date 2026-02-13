-- ============================================
-- AUTO SELL MODULE - ระบบขายของอัตโนมัติ
-- ============================================

local AutoSell = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function AutoSell.Start(config, utils, logUI)
    task.spawn(function()
        while true do
            if config.AutoSellAll and not config.StopAll then
                local remote = utils.FindSellAllRemote()
                if remote then
                    pcall(function()
                        remote:InvokeServer()
                    end)
                end
                task.wait(config.SellAllInterval or 5)
            else
                task.wait(1)
            end
        end
    end)
end

return AutoSell
