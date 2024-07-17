-- Apocalypse Script - Client Side

local QBCore = exports['qb-core']:GetCoreObject()
local zombies = {}
local safeZones = {
    {x = 200.0, y = -1000.0, z = 30.0, radius = 100.0}, -- Example safe zone
    -- Add more safe zones here
}

-- Function to check if player is in a safe zone
function isInSafeZone(playerPos)
    for _, zone in ipairs(safeZones) do
        local dist = Vdist(playerPos.x, playerPos.y, playerPos.z, zone.x, zone.y, zone.z)
        if dist < zone.radius then
            return true
        end
    end
    return false
end

-- Function to spawn a zombie near the player
function spawnZombie()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local zombieModel = GetHashKey('u_m_y_zombie_01') -- Example zombie model

    RequestModel(zombieModel)
    while not HasModelLoaded(zombieModel) do
        Wait(1)
    end

    local zombie = CreatePed(4, zombieModel, playerPos.x + math.random(-10, 10), playerPos.y + math.random(-10, 10), playerPos.z, 0.0, true, false)
    TaskWanderStandard(zombie, 10.0, 10)
    table.insert(zombies, zombie)
end

-- Function to handle zombie AI
function zombieAI()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    for _, zombie in ipairs(zombies) do
        if DoesEntityExist(zombie) and not IsEntityDead(zombie) then
            local zombiePos = GetEntityCoords(zombie)
            local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, zombiePos.x, zombiePos.y, zombiePos.z)

            if distance < 20.0 then
                TaskGoToEntity(zombie, playerPed, -1, 0.0, 1.0, 1073741824.0, 0)
            elseif distance < 50.0 then
                TaskWanderStandard(zombie, 10.0, 10)
            end
        end
    end
end

-- Function to attract zombies to a sound
function attractZombies(x, y, z)
    for _, zombie in ipairs(zombies) do
        if DoesEntityExist(zombie) and not IsEntityDead(zombie) then
            TaskGoStraightToCoord(zombie, x, y, z, 1.0, -1, 0.0, 0.0)
        end
    end
end

-- Function to search a dead zombie
function searchZombie(zombie)
    local lootTable = {
        {item = "weapon_knife", chance = 30},
        {item = "cash", amount = math.random(50, 200), chance = 50},
        -- Add more loot items here
    }

    for _, loot in ipairs(lootTable) do
        if math.random(100) <= loot.chance then
            if loot.item == "cash" then
                TriggerServerEvent('apocalypse:giveCash', loot.amount)
            else
                TriggerServerEvent('apocalypse:giveItem', loot.item)
            end
        end
    end
end

-- Main loop
Citizen.CreateThread(function()
    while true do
        Wait(1000)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        if not isInSafeZone(playerPos) then
            if math.random(1, 100) < 10 then -- 10% chance to spawn a zombie every second
                spawnZombie()
            end
        end

        zombieAI()
    end
end)

-- Event listener for gunshots
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventGunShot' then
        local x, y, z = table.unpack(args)
        attractZombies(x, y, z)
    end
end)

-- Key press to search dead zombies
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 38) then -- E key
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)

            for _, zombie in ipairs(zombies) do
                if IsEntityDead(zombie) then
                    local zombiePos = GetEntityCoords(zombie)
                    local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, zombiePos.x, zombiePos.y, zombiePos.z)

                    if distance < 2.0 then
                        searchZombie(zombie)
                    end
                end
            end
        end
    end
end)
