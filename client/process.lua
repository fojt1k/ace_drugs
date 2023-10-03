local playerPed = PlayerPedId()
local isProcessing = false
local isInZone = false

local function ProcessItem(removeItem, removeAmount, giveItem, giveAmount)
    TriggerServerEvent('process', removeItem, removeAmount, giveItem, giveAmount)
end

CreateThread(function()
    while Config.Enable do
        local wait = 1000
        Wait(0)
        local coords = GetEntityCoords(playerPed)

        for zoneName, zoneData in pairs(Config.ProcessZones) do
            local distance = #(coords - zoneData.coords)

            if distance <= zoneData.radius then
                local isInZone = true
                wait = 2
                if not isProcessing then
                    DrawMarker(zoneData.markerType, zoneData.coords.x, zoneData.coords.y, zoneData.coords.z - 0.99, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, true, 2, false, false, false, false)

                    if distance < 1 then
                        ESX.ShowHelpNotification('Press [E] to process ' .. zoneData.name)
                    end

                    if IsControlJustReleased(0, 38) then
                        isProcessing = true
                        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)

                        if lib.progressBar({
                            duration = 3500,
                            label = 'Processing ' .. zoneData.name,
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                movement = true,
                                carMovement = true,
                                mouse = false,
                                combat = true
                            },
                        }) then
                            isProcessing = false
                            if isInZone then
                                ProcessItem(zoneData.removeItem, zoneData.removeAmount, zoneData.giveItem, zoneData.giveAmount)
                            end

                            local timeLeft = Config.Delays.Processing / 1000

                            while timeLeft > 0 do
                                Wait(1000)
                                timeLeft = timeLeft - 1

                                local newDistance = #(GetEntityCoords(playerPed) - zoneData.coords)

                                if newDistance > zoneData.radius then
                                    break
                                end
                            end

                            ClearPedTasks(playerPed)
                            isProcessing = false
                        end
                    end
                end
            end

            Wait(wait)
        end
    end
end)
