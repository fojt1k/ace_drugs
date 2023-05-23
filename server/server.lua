ESX = exports["es_extended"]:getSharedObject()


RegisterServerEvent('item', function(item, amount)
	local src = source

	if xPlayer.canCarryItem(source, item, amount) then
		xPlayer.addInventoryItem(source, item, amount)
	else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek místa.' }})
	end
end)

RegisterServerEvent('process', function(removeItem, removeAmmount, giveItem, giveAmount)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getInventoryItem(removeItem).count >= removeAmmount then
		xPlayer.removeInventoryItem(removeItem, removeAmmount)
		Wait(1)
		xPlayer.addInventoryItem(giveItem, giveAmount)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' }})
	end
end)

-- prodej


RegisterServerEvent('prodej', function(sellItem, minAmmount, maxAmmount, minPrice, maxPrice)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
   --[[ local ammount = 1
    local price = 0
    local item = 'water'
]]
    if xPlayer.getInventoryItem(sellItem).count >= maxAmmount then
        ammount = math.random(minAmmount, maxAmmount)
        if minAmmount == 1 then
            price = math.random(minPrice, maxPrice)
        else
            price = ammount * math.random(minPrice, maxPrice)
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' } })
        return
    end

    xPlayer.removeInventoryItem(sellItem, ammount)
    Wait(1)
    xPlayer.addMoney(price)
    --TriggerEvent('sell', item, ammount, price)
end)