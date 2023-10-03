ESX = exports["es_extended"]:getSharedObject()


RegisterServerEvent('item', function(item, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem(item, amount) then
		xPlayer.addInventoryItem(item, amount)
	else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek místa.' }})
	end
end)

RegisterServerEvent('process', function(removeItem, removeAmmount, giveItem, giveAmount)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

    if giveAmount > Config.giveAmount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Pokus o neplatné množství itemů.' }})
    end

	if xPlayer.getInventoryItem(removeItem).count >= removeAmmount then
        xPlayer.removeInventoryItem(removeItem, removeAmmount)
        xPlayer.addInventoryItem(giveItem, giveAmount)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' }})
	end
end)

-- prodej

RegisterServerEvent('prodej')
AddEventHandler('prodej', function(sellItem, amount, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local itemCount = xPlayer.getInventoryItem(sellItem).count

        if itemCount >= amount then
            xPlayer.removeInventoryItem(sellItem, amount)
            Wait(1)
            xPlayer.addMoney(price)

            local message = string.format("You sold %sx %s for $%s", amount, sellItem, price)
            TriggerClientEvent('chatMessage', source, '^2SELL', { 255, 0, 0 }, message)
        else
            TriggerClientEvent('chatMessage', source, '^1ERROR', { 255, 0, 0 }, 'You do not have enough items to sell.')
        end
    end
end)
