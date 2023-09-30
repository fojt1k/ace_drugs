local sold = false
local SellEnable = false
local npcs = {}

function GetNpc()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return npc
end

function SellDrugs()

end

CreateThread(function()
    while true do
        Wait(0)
        local npc = GetNpc()


        local InVehicle = IsPedInAnyVehicle(npc)

        if idk then
            npc = GetNpc()

            if npc ~= 0 then
                if not InVehicle then
                    if npc ~= oldNpc then
                        local positon = GetEntityCoords(npc)
                        SellEnable = true
                        Wait(10)
                        SellDrugs()
                    else
                        Wait(1000)
                    end
                end
            end
        end
    end
end)