-- load

ESX = exports["es_extended"]:getSharedObject()

local sleep = false
local playerPed = PlayerPedId()


-- sběr

local PropSpawned = 0
local PropPlants = {}
local isPickingUp, inField = false, false

local function ValidateCoord(plantCoord)
    local validate = true
    if PropSpawned > 0 then
        for _, v in pairs(PropPlants) do
            if #(plantCoord - GetEntityCoords(v)) < 5 then
                validate = false
            end
        end
    end
    return validate
end

local function GetCoordZ(x, y)
	local groundCheckHeights = { 1.0, 25.0, 50.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 77
end

local function GenerateCoords(x, y)
	while true do
		Wait(1)

		local modX = math.random(-35, 35)
		Wait(100)
		local modY = math.random(-35, 35)

		local CoordX = x + modX
		local CoordY = y + modY

		local coordZ = GetCoordZ(CoordX, CoordY)
		local coord = vector3(CoordX, CoordY, coordZ)

		if ValidateCoord(coord) then
			return coord
		end
	end
end

local function SpawnPlants()
    for _, zone in pairs(Config.CircleZones) do
        local model = zone.model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(100)
        end
        if PropSpawned < 15 then
            local Coords = GenerateCoords(zone.coords.x, zone.coords.y)
            local obj = CreateObject(model, Coords.x, Coords.y, Coords.z, false, true, false)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            PropPlants[#PropPlants+1] = obj
            PropSpawned = PropSpawned + 1
            SetModelAsNoLongerNeeded(model)
        end
    end
end


CreateThread(function()
    while true do
        Wait(10)
        local coords = GetEntityCoords(playerPed)

        for _, zone in pairs(Config.CircleZones) do
            if GetDistanceBetweenCoords(coords, zone.coords, true) < 50 then
                SpawnPlants()
                Wait(500)
            else
                Wait(500)
            end
        end
    end
end)

local function GetZone(coords)
	for zoneName, zoneData in pairs(Config.CircleZones) do
	  if GetDistanceBetweenCoords(coords, zoneData.coords, true) <= zoneData.radius then
		return zoneData
	  end
	end
  
	return nil
end
  
  local function PickUpItem(item, amount)
	TriggerServerEvent('item', item, amount)
end



CreateThread(function()
    while Config.Enable do
        Wait(0)
        
        local coords = GetEntityCoords(playerPed)
        local nearbyObject, nearbyID = nil, nil
        local zone = GetZone(coords)
        
        for _, zone in pairs(Config.CircleZones) do
            for i = 1, #PropPlants, 1 do
                if GetDistanceBetweenCoords(coords, GetEntityCoords(PropPlants[i]), false) < 2 then
                    ESX.ShowHelpNotification(('Stiskni [E] pro sber'))
                    nearbyObject, nearbyID = PropPlants[i], i
                end
            end
            
            if nearbyObject and IsPedOnFoot(playerPed) then
                if not isPickingUp then
                    Wait(0)
                end
                
                if IsControlJustReleased(0, 38) and not isPickingUp then
                    isPickingUp = true
                    
                    TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, true)
                    
                    exports['progressbar']:Progress({
                        name = "coca leaf",
                        duration = 3500,
                        label = ('sbíráš ' .. zone.name),
                        useWhileDead = false,
                        canCancel = false,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }
                    }, function(status)
                        if not status then
                            isPickingUp = false
                            DeleteObject(nearbyObject)                            
                            ClearPedTasks(playerPed)
                            PickUpItem(zone.item, zone.amount)
							TriggerServerEvent('log', zone.item, zone.amount)
                            table.remove(PropPlants, nearbyID)
                            PropSpawned = PropSpawned - 1
                        else
                            isPickingUp = false
                        end
                    end)
                end
            else
                Wait(500)
            end
        end
    end
end)


-- předěl

local isProcessing = false

local function ProcessItem(removeItem, removeAmmount, giveItem, giveAmount)

	TriggerServerEvent('process', removeItem, removeAmmount, giveItem, giveAmount)

end

local function GetProcessZone(coords)
	for zoneName, zoneData in pairs(Config.ProcessZones) do
	  if GetDistanceBetweenCoords(coords, zoneData.coords, true) <= zoneData.radius then
		return zoneData
	  end
	end
  
	return nil
end


local function Process(item)
	isProcessing = true

	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)

	exports['progressbar']:Progress({
		name = item.name,
		duration = Config.Delays.Processing,
		label = ('zpracováváš ' .. item.name),
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true
		}
	}, function(status)
		if not status then
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
	end, function()
		ClearPedTasks(playerPed)
		isProcessing = false
	end)
end

local isProcessing = false

CreateThread(function()
    while Config.Enable do
        Wait(0)

        local coords = GetEntityCoords(playerPed)
        local zone1 = GetProcessZone(coords)

        for _, zoneData in pairs(Config.ProcessZones) do
            if zone1 == zoneData then
                if not isProcessing then
                    DrawMarker(1, zoneData.coords.x, zoneData.coords.y, zoneData.coords.z - 0.99, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, true, 2, false, false, false, false)
                end
                if IsControlJustReleased(0, 38) and not isProcessing then
                    isProcessing = true
                    Process(zoneData)
                end
                --Wait(1000)
            end
            Wait(1000)
        end
    end
end)

-- prodej

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


CreateThread(function()
    while Config.Enable do
        Wait(10)

        if selling then -- kontrola, zda je prodej aktivní
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
                            exports['progressbar']:Progress({
                                name = "prodej",
                                duration = 3500,
                                label = (' Prodej ' ),
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = {
                                    disableMovement = false,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true
                                }
                            }, function(status)
                            end)
                            Wait(3500)
                            TriggerServerEvent('prodej')
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

       




-- stop

--[[
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(PropPlants) do
			DeleteObject(v)
		end
	end
end)
]]