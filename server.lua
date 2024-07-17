-- Apocalypse Script - Server Side

QBCore = exports['qb-core']:GetCoreObject()

-- Function to give items to the player
RegisterNetEvent('apocalypse:giveItem')
AddEventHandler('apocalypse:giveItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)

-- Function to give cash to the player
RegisterNetEvent('apocalypse:giveCash')
AddEventHandler('apocalypse:giveCash', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', amount)
end)
