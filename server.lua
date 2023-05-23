ESX = exports["es_extended"]:getSharedObject()

local ox_inventory = exports.ox_inventory

RegisterNetEvent("drugs:Givecoke")
AddEventHandler("drugs:Givecoke", function(showcase)
    local client = source
	local reason = 'špatnej event'
    TriggerEvent('banPlayer', reason)
end)

RegisterServerEvent('item', function(item, amount)
	local src = source
	local Player = source

	if exports.ox_inventory:CanCarryItem(source, item, amount) then
		exports.ox_inventory:AddItem(source, item, amount)
	else

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

RegisterServerEvent('log', function(item, amount)
    local source = source
    local license = true
    local discord = true
    local xbl = true
    local liveid = true
    local ip = true

    for k,v in pairs(GetPlayerIdentifiers(source)) do
        print(v)

        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = string.sub(v, 9)
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end

    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = 'Hráč sebral: ' .. item .. ' v množství: ' .. amount,
            ["description"] = '`discord:` <@' .. discord .. '>',
            ["footer"] = {
                ["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
            },
        }
    }

    PerformHttpRequest('https://discord.com/api/webhooks/1099720307473911849/7IdUK3i7wAzI2RPl0aW9_zYczut7wL68nlf86CcEvC5pjphxCosbYzBlwv0eCoMqrVmy', function(err, text, headers) end, 'POST', json.encode({username = 'Join', embeds = embed}), { ['Content-Type'] = 'application/json' })
end)




-- prodej


RegisterServerEvent('prodej', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local ammount = 1
    local price = 0
    local item = 'water'

    if xPlayer.getInventoryItem(item).count >= 5 then
        ammount = math.random(1,5)
        if ammount == 1 then
            price = math.random(3,5)
        else
            price = ammount * math.random(3,5)
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' } })
        return
    end

    xPlayer.removeInventoryItem(item, ammount)
    Wait(1)
    xPlayer.addMoney(price)
    --TriggerEvent('sell', item, ammount, price)
end)



--[[

RegisterServerEvent('prodej', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local ammount = 1
    local price = 0

    if xPlayer.getInventoryItem('water').count >= 5 then
        ammount = math.random(1,5)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' } })
        return
    end

    if ammount == 1 then
        price = 1
    else
        price = ammount
    end

    xPlayer.removeInventoryItem('water', ammount)

    Wait(1)

    xPlayer.addInventoryItem('money', price)
end)
]]

--[[
RegisterServerEvent('prodej', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local ammount = 1

    if xPlayer.getInventoryItem('water').count >= 5 then
        math.random (1,5)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'Nemáš dostatek materiálů.' } })
    end
end)
]]