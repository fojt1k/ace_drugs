local playerPed = PlayerPedId()

local isProcessing = false

local function ProcessItem(removeItem, removeAmmount, giveItem, giveAmount)

	TriggerServerEvent('process', removeItem, removeAmmount, giveItem, giveAmount)

end

local function GetProcessZone(coords)
	for zoneName, zoneData in pairs(Config.ProcessZones) do
	  if #(coords - zoneData.coords) <= zoneData.radius then
		return zoneData
	  end
	end
  
	return nil
end


local function Process(item)
	isProcessing = true

	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)

    if lib.progressBar({
        duration = 3500,
        label = 'Předěláváš ' .. item.name,
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
			print(item.removeItem, item.removeAmmount, item.giveItem, item.giveAmount)

			ProcessItem(item.removeItem, item.removeAmmount, item.giveItem, item.giveAmount)

			local timeLeft = Config.Delays.Processing / 1000
			while timeLeft > 0 do
				Wait(1000)
				timeLeft -= 1

				if #(GetEntityCoords(playerPed)-item.coords) > item.radius then
					break
				end
			end
			ClearPedTasks(playerPed)
			isProcessing = false
        end
end

CreateThread(function()
    while Config.Enable do

        Wait(0)

        local coords = GetEntityCoords(playerPed)
        local processZone = GetProcessZone(coords)

        for _, zoneData in pairs(Config.ProcessZones) do
            if processZone == zoneData then
                if not isProcessing then
                    DrawMarker(zoneData.markerType, zoneData.coords.x, zoneData.coords.y, zoneData.coords.z - 0.99, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, true, 2, false, false, false, false)
                end

                if #(coords - zoneData.coords) < 1 then
                    ESX.ShowHelpNotification('Stiskni [E] pro predel')
                end

                if IsControlJustReleased(0, 38) and not isProcessing then
                    isProcessing = true
                    Process(zoneData)
                end
            else
                isProcessing = false
            end
        end
    end
end)