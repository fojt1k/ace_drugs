function Plant(name)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    local plant = CreateObject(GetHashKey(name), x, y, z - 0.9, true, true, true)
end

RegisterCommand('plant', function(name)

    Plant(name)
    
end)