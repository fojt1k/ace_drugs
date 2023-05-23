local function Draw3DText(x,y,z,text,scale) -- založení funkce Draw3DText s paremetry: x, y, z, text, scale
    local onScreen, _x, _y = World3dToScreen2d(x,y,z)
    local pX,pY,pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(scale, scale) -- nastav velikost textu
    SetTextFont(4) -- nastav font textu
    SetTextProportional(1)
    SetTextCentre(1) -- dej text na střed
    SetTextColour(255, 255, 255, 255) -- nastav plnou bílou barvu (red, green, blue, alpha) vše 0-255
    SetTextDropShadow(0, 0, 0, 0, 255) -- nastav vzdálenost stínu (stín za textem) (vzdálenost, red, green, blue, alpha)
    SetTextDropShadow()
    SetTextOutline() -- nastav textu obrys
    SetTextEntry("STRING") -- v textu bude string
    AddTextComponentString(text) -- jaký text se bude vykreslovat
    DrawText(_x,_y) -- v jaké části obrazovky se text vykreslí
    SetTextOutline()
end


local selling = false

RegisterCommand('StartSell', function()
    selling = true

    TriggerEvent('chat:addMessage', {
        args = { '^2INFO', 'Prodej byl spuštěn.' },
        color = { 0, 255, 0 }
    })
end)



TriggerEvent('chat:addSuggestion', '/StartSell', 'Slouží pro prodej drog NPC', {
})


RegisterCommand('StopSell', function()
    selling = false
    TriggerEvent('chat:addMessage', {
        args = { '^2INFO', 'Prodej byl zrušen.' },
        color = { 0, 255, 0 }
    })
end)


TriggerEvent('chat:addSuggestion', '/StopSell', 'Slouží pro ukončení prodeje drog NPC', {
})


local function GetPedInFront()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return ped
end

local function SellItem(sellItem, minAmmount, maxAmmount, minPrice, maxPrice)

    TriggerServerEvent('prodej', sellItem, minAmmount, maxAmmount, minPrice, maxPrice)

end


CreateThread(function()
    while Config.Enable do
        Wait(10)

        if selling then
            ped = GetPedInFront()

            if ped ~= 0 then 
                if not IsPedDeadOrDying(ped) and not IsPedInAnyVehicle(ped) then
                    local pedType = GetPedType(ped)
                    if ped ~= oldped and (IsPedAPlayer(ped) == false and pedType ~= 28) then
                        local pos = GetEntityCoords(ped)
                        Draw3DText(pos.x, pos.y, pos.z + 0.0, "Stiskni [E] pro prodej", 0.40)
                        if IsControlJustReleased(0, 38) then
                            oldped = ped
                            TaskLookAtCoord(ped, pos.x, pos.y, pos.z, -1, 2048, 3)
                            TaskStandStill(ped, 100.0)
							SetEntityAsMissionEntity(ped)
                            Wait(1)
                            TaskStartScenarioInPlace(playerPed, 'package_dropoff', 0, true)
							local pos1 = GetEntityCoords(ped)
                            lib.progressBar({
                                duration = 2000,
                                label = 'prodáváš',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    car = true,
                                }
                            })
                            Wait(3500)
                            SellItem(item.sellItem, item.minAmmount, item.maxAmmount, item.minPrice, item.maxPrice)
                            SetPedAsNoLongerNeeded(oldped)
                        end
                    end
                else
                    Wait(500)
                end
            else
                Wait(500)    
            end
        end
    end
end)