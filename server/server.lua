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

    if xPlayer.getInventoryItem(sellItem).count >= maxAmmount then
        local ammount = math.random(minAmmount, maxAmmount)
        local price = 0

        if ammount == 1 then
            price = math.random(minPrice, maxPrice)
        else
            for i = 1, ammount do
                price = price + math.random(minPrice, maxPrice)
            end
        end

        xPlayer.removeInventoryItem(sellItem, ammount)
        Wait(1)
        xPlayer.addMoney(price)

        local connect = {
            {
                ["color"] = "16718105",
                ["title"] = GetPlayerName(source).." (".. xPlayer.identifier ..")",
                ["description"] = "📤 Prodal: **"..sellItem.. "**, V množství: **".. ammount .. "**, Za částku: **" .. price .. " 💲**",
                ["footer"] = {
                    ["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
                },
            }
        }

        PerformHttpRequest("https://discord.com/api/webhooks/1104472321575616544/Z_p4-tX79zL9PDBKb603h-OMiL31LCTSirePoDXIVrqzGU5Zl-FUxc3YcxTxjxPtBqBB", function(err, text, headers) end, 'POST', json.encode({username = "Dealer", embeds = connect}), { ['Content-Type'] = 'application/json' })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' } })
        return
    end
end)
