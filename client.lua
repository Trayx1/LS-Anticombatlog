-- Client.lua

local droppedPlayers = {}

-- Funktion zum Zeichnen von 3D-Text
local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(camCoords.x, camCoords.y, camCoords.z) - vector3(coords.x, coords.y, coords.z))
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry('STRING')
        SetTextCentre(1)
        SetTextColour(155, 0, 155, 255)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 100)
    end
end

-- Spielerkoordinaten regelmäßig an den Server senden
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- alle 5 Sekunden
        local ped = PlayerPedId()
        if ped and DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            TriggerServerEvent('LS-antiCombatlog:updateCoords', {x = coords.x, y = coords.y, z = coords.z})
        end
    end
end)

-- Ereignis, wenn ein Spieler das Spiel verlässt (Marker anzeigen)
RegisterNetEvent('LS-antiCombatlog:playerDropped')
AddEventHandler('LS-antiCombatlog:playerDropped', function(droppedPlayer)
    -- Überprüfen, ob die Koordinaten gültig sind (nicht alle 0)
    if droppedPlayer.coords.x == 0.0 and droppedPlayer.coords.y == 0.0 and droppedPlayer.coords.z == 0.0 then
        print('^1[Anti-CombatLog]^0 Ungültige Koordinaten für Spieler ' .. droppedPlayer.playerName .. '. Marker wird nicht angezeigt.')
        return
    end

    table.insert(droppedPlayers, droppedPlayer)

    -- Marker und Text für 15 Sekunden anzeigen
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + 15000 -- 15 Sekunden
        while GetGameTimer() < endTime do
            -- Marker zeichnen
            DrawMarker(
                32, 
                droppedPlayer.coords.x, 
                droppedPlayer.coords.y, 
                droppedPlayer.coords.z + 1.0, 
                0, 0, 0, 0, 0, 0, 
                1.5, 1.5, 1.0, 
                155, 0, 155, 100, 
                false, true, 2, false, nil, nil, false
            )

            -- Text formatieren
            local displayText = ""
            if droppedPlayer.reason == "verlassen" then
                displayText = droppedPlayer.playerName .. ' hat das Spiel verlassen'
            else
                displayText = droppedPlayer.playerName .. ' hat das Spiel verlassen: ' .. droppedPlayer.reason
            end

            -- 3D-Text zeichnen
            DrawText3D(droppedPlayer.coords, displayText)
            Citizen.Wait(0)
        end

        -- Entferne den Marker nach der Anzeigezeit
        for i, v in ipairs(droppedPlayers) do
            if v == droppedPlayer then
                table.remove(droppedPlayers, i)
                break
            end
        end
    end)
end)

-- Ereignis zum Anzeigen der Nachricht in der Konsole
RegisterNetEvent('LS-antiCombatlog:consoleMessage')
AddEventHandler('LS-antiCombatlog:consoleMessage', function(playerName, reason)
    print('^1[Anti-CombatLog]^0 Spieler ^5' .. playerName .. '^0 hat das Spiel verlassen: ' .. reason)
end)
