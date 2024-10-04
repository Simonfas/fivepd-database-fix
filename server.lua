local function fixPedCitations()
    exports.oxmysql:query('SELECT citationID, reason FROM pedcitations WHERE reason IS NOT NULL AND (reason NOT LIKE "%]" OR reason LIKE "%[")', {}, function(results)
        if results and #results > 0 then
            print("Fixing citations...")
            for _, row in ipairs(results) do
                local fixedReason = row.reason
                if string.sub(fixedReason, -1) ~= "]" then
                    fixedReason = fixedReason .. "]"
                end
                
                if string.sub(fixedReason, 1, 1) ~= "[" then
                    fixedReason = "[" .. fixedReason
                end
                
                if string.sub(fixedReason, -2, -2) ~= '"' then
                    fixedReason = fixedReason:sub(1, -2) .. '"' .. ']'
                end

                exports.oxmysql:query('UPDATE pedcitations SET reason = ? WHERE citationID = ?', {fixedReason, row.citationID}, function(updateResult)
                    if updateResult.affectedRows > 0 then
                        if Config.debug == true then
                            print("Fixed citation ID: " .. row.citationID)
                        end
                    else
                        if Config.debug == true then
                            print("Failed to fix citation ID: " .. row.citationID)
                        end
                    end
                end)
            end
        else
            if Config.debug == true then
                print("No citations to fix.")
            end
        end
    end)
end

if Config.usecommand == true then
    RegisterCommand(Config.command, function(source, args, rawCommand)
        fixPedCitations()
    end, false)
end

if Config.useonresourcestart == true then
    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() == resourceName then
            fixPedCitations()
        end
    end)
end

if Config.useplayerconnecting == true then
    AddEventHandler('playerConnecting', function()
        fixPedCitations()
    end)
end

if Config.usetimer == true then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.timer)
            fixPedCitations() 
        end
    end)
end