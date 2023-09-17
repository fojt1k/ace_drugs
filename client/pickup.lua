-- load

ESX = exports["es_extended"]:getSharedObject()

local sleep = false
local playerPed = PlayerPedId()

--

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
            if #(coords - zone.coords) < 50 then
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
	  if #(coords - zoneData.coords) <= zoneData.radius then
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
        
        for zone, zoneData in pairs(Config.CircleZones) do
            for i = 1, #PropPlants, 1 do
                local propCoords = GetEntityCoords(PropPlants[i])
                if #(coords - propCoords) < 2 then
                    ESX.ShowHelpNotification('Stiskni [E] pro sběr') 
                    nearbyObject, nearbyID = PropPlants[i], i
                end
            end
            
            if nearbyObject and IsPedOnFoot(playerPed) then
                if not isPickingUp then
                    isPickingUp = false
                    Wait(10)
                end
                if IsControlJustReleased(0, 38) then
                    isPickingUp = true
                    
                    TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, true)

                    if lib.progressBar({
                        duration = 3500,
                        label = 'sbíráš ' .. zoneData.name,
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            movement = true,
                            carMovement = true,
                            mouse = false,
                            combat = true
                        },
                    }) then
                        DeleteObject(nearbyObject)
                        ClearPedTasks(playerPed)
                        PickUpItem(zoneData.item, zoneData.amount)
                        table.remove(PropPlants, nearbyID)
                        PropSpawned = PropSpawned - 1
                    end
                end
            else
                Wait(500)
            end
        end
    end
end)




AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(PropPlants) do
			DeleteObject(v)
            ClearPedTasks(playerPed)
		end
	end
end)
