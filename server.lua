-- Server.lua

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Tabellen zur Speicherung der Informationen
droppedPlayers = {}
playerCoords = {}

-- Empfange Spielerkoordinaten vom Client
RegisterNetEvent('LS-antiCombatlog:updateCoords')
AddEventHandler('LS-antiCombatlog:updateCoords', function(coords)
    local _source = source
    playerCoords[_source] = coords
end)

-- Ereignis, wenn ein Spieler das Spiel verlässt
AddEventHandler('playerDropped', function(reason)
    local _source = source
    local playerName = GetPlayerName(_source)
    
    -- Letzte bekannte Koordinaten abrufen
    local coords = playerCoords[_source] or {x = 0.0, y = 0.0, z = 0.0}

    -- Gründe vereinfachen
    local simplifiedReason = "verlassen"
    local lowerReason = reason:lower()
    if string.find(lowerReason, "timed out") or string.find(lowerReason, "timeout") then
        simplifiedReason = "Timeout"
    elseif string.find(lowerReason, "bann") or string.find(lowerReason, "ban") then
        simplifiedReason = "Bann"
    elseif string.find(lowerReason, "crash") then
        simplifiedReason = "Gamecrash"
    end

    -- Informationen des verlassenen Spielers speichern
    droppedPlayers[_source] = {
        playerName = playerName,
        reason = simplifiedReason,
        coords = coords
    }

    -- Ereignis an alle Clients senden, um Marker anzuzeigen
    TriggerClientEvent('LS-antiCombatlog:playerDropped', -1, droppedPlayers[_source])

    -- Nachricht in der Serverkonsole anzeigen
    TriggerClientEvent('LS-antiCombatlog:consoleMessage', -1, playerName, reason)
end)
