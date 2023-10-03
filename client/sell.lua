local function Draw3DText(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x, _y)
    SetTextOutline()
end

local selling = false

function PrintConfig()
    print("=== Config ===")
    for key, value in pairs(Config) do
        if type(value) == "table" then
            print(key .. ":")
            for k, v in pairs(value) do
                print("  " .. k .. ": " .. tostring(v))
            end
        else
            print(key .. ": " .. tostring(value))
        end
    end
    print("==============")
end

local function StopSelling()
    if selling then
        selling = false
        TriggerEvent('chat:addMessage', {
            args = { '^2INFO', 'Selling has been canceled.' },
            color = { 0, 255, 0 }
        })
    end
end

local sellCommand = Config.Sell.Command.cmd or 'drugSell'

RegisterCommand(sellCommand, function(source, args)
    if selling then
        StopSelling()
    else
        selling = true

        local sellData = args[1]

        for _, itemData in pairs(Config.Sell.Items) do
            print(itemData.sellItem)
        end

        TriggerEvent('chat:addMessage', {
            args = { '^2INFO', 'Selling has started. Use /' .. sellCommand .. ' to stop.' },
            color = { 0, 255, 0 }
        })
    end
end)

TriggerEvent('chat:addSuggestion', '/' .. sellCommand, 'Start or stop selling items to NPC', {})

local function GetPedInFront()
    local player = PlayerId()
    local plyPed = GetPlayerPed(player)
    local plyPos = GetEntityCoords(plyPed, false)
    local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
    local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
    local _, _, _, _, ped = GetShapeTestResult(rayHandle)
    return ped
end

local function ShouldPedAttack()
    local randomChance = math.random()
    return randomChance <= Config.Sell.Chances.PedAttackChance
end

local function ShouldCallPolice()
    local randomChance = math.random()
    return randomChance <= Config.Sell.Chances.PoliceCallChance
end

local oldped = 0

local function SellItem(sellItem, minAmount, maxAmount, minPrice, maxPrice)
    local amount = math.random(minAmount, maxAmount)
    local price = 0

    for i = 1, amount do
        price = price + math.random(minPrice, maxPrice)
    end

    TriggerServerEvent('prodej', sellItem, amount, price)
end

CreateThread(function()
    while true do
        Wait(10)

        if selling then
            ped = GetPedInFront()

            if ped ~= 0 then
                if not IsPedDeadOrDying(ped) and not IsPedInAnyVehicle(ped) then
                    local pedType = GetPedType(ped)
                    if ped ~= oldped and (IsPedAPlayer(ped) == false and pedType ~= 28) then
                        local pos = GetEntityCoords(ped)
                        Draw3DText(pos.x, pos.y, pos.z + 0.0, "Press [E] to sell", 0.40)
                        if IsControlJustReleased(0, 38) then
                            local plyPed = GetPlayerPed(PlayerPedId())
                            oldped = ped
                            TaskLookAtCoord(ped, pos.x, pos.y, pos.z, -1, 2048, 3)
                            TaskStandStill(ped, 100.0)
                            SetEntityAsMissionEntity(ped)
                            Wait(1)
                            TaskStartScenarioInPlace(playerPed, 'package_dropoff', 0, true)
                            local pos1 = GetEntityCoords(ped)
                            lib.progressBar({
                                duration = 2000,
                                label = 'Selling',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    car = true,
                                }
                            })
                            Wait(3500)
                            SellItem(Config.Sell.Items[1].sellItem, Config.Sell.Items[1].minAmount, Config.Sell.Items[1].maxAmount, Config.Sell.Items[1].minPrice, Config.Sell.Items[1].maxPrice)
                            SetPedAsNoLongerNeeded(oldped)
                        end
                    end
                else
                    Wait(500)
                end
            else
                Wait(500)
            end

            if ShouldPedAttack() then
                print('attack')
                TaskCombatPed(ped, plyPed, 0, 16)
            end

            if ShouldCallPolice() then
                TriggerEvent(Config.Sell.Exports.PoliceCallEvent)
            else
                print("Incorrect police call event.")
            end
        end
    end
end)