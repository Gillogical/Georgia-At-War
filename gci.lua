fs = require('lfs')
package.path = fs.currentdir() .. "Scripts\\?.lua;" .. package.path
--logFile = io.open(fs.writedir()..[[Logs\HoggitGCI\GCI.log]], "w")
--dofile(fs.writedir()..[[Scripts\HoggitGCI\worldstate.lua]])
--socket = require('socket')

local stateFile = fs.writedir()..[[Scripts\HoggitGCI\state.json]]
log("STATEFILE: " .. stateFile )

-- All red
BlueGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
RedGroups = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()

local gci_airbases = {
    AIRBASE.Caucasus.Anapa_Vityazevo,
    AIRBASE.Caucasus.Novorossiysk,
    AIRBASE.Caucasus.Gelendzhik,
    AIRBASE.Caucasus.Krymsk,
    AIRBASE.Caucasus.Krasnodar_Center,
    AIRBASE.Caucasus.Krasnodar_Pashkovsky,
    AIRBASE.Caucasus.Maykop_Khanskaya
}

SCHEDULER:New(nil, function()
    pcall(
        function()
            local output = ""
            local state = {}
            local blue_state = {}
			
			RedGroups:ForEachGroup(function(group)
                if group:IsAlive() then
                    for i,unit in ipairs(group:GetUnits()) do
                        local lat, lon = coord.LOtoLL(unit:GetCoordinate():GetVec3())
                        local id = unit:GetID()
                        local height = unit:GetHeight()
                        local heading = group:GetHeading()
                        local velocity = VELOCITY_POSITIONABLE:New(unit):GetMiph() * .86
                        table.insert(state, {["id"] = id, ["height"] = height, ["type"] = unit:GetTypeName(), ["lat"] = lat, ["long"] = lon, ["speed"] = velocity, ["heading"] = heading, ["name"] = unit:GetCallsign()})
                    end
                end
            end)

            BlueGroups:ForEachGroup(function(group)
                if group:IsAlive() then
                    for i,unit in ipairs(group:GetUnits()) do
                        local lat, lon = coord.LOtoLL(unit:GetCoordinate():GetVec3())
                        local id = unit:GetID()
                        local height = unit:GetHeight()
                        local heading = group:GetHeading()
                        local velocity = VELOCITY_POSITIONABLE:New(unit):GetMiph() * .86
                        table.insert(blue_state, {["id"] = id, ["height"] = height, ["type"] = unit:GetTypeName(), ["lat"] = lat, ["long"] = lon, ["speed"] = velocity, ["heading"] = heading, ["playerName"] = unit:GetPlayerName() or '', ["name"] = unit:GetCallsign()})
                    end
                end
            end)
            output = output .. '{"red":['
            local idx = 1
            for j,unit in ipairs(state) do
                if idx > 1 then  output = output .. ',' end
                output = output .. '{"id":' .. unit['id'] .. ', "height":' .. unit['height'] .. ', "type":"' .. unit['type'] .. '", "lat":' .. unit['lat'] ..  ', "long": ' .. unit['long']  ..  ', "heading": ' .. unit['heading'] .. ', "speed": ' .. unit['speed'] .. ', "name": "' .. unit['name'] ..'"}'
                idx = idx + 1
            end

            output = output .. '],"blue":['
            idx = 1
            for k,blue_unit in ipairs(blue_state) do
                if idx > 1 then  output = output .. ',' end
                output = output .. '{"id":' .. blue_unit['id'] .. ', "height":' .. blue_unit['height'] ..', "type":"' .. blue_unit['type'] ..  '", "lat":' .. blue_unit['lat'] ..  ', "long": ' .. blue_unit['long']  ..  ', "heading": ' .. blue_unit['heading'] .. ', "speed": ' .. blue_unit['speed'] .. ', "name": "' .. blue_unit['name'] ..'", "playerName": "'.. blue_unit['playerName'] ..'"}'
                idx = idx + 1
            end

            output = output .. '], "FARPS":{'
            idx = 1
            for name,coalition in pairs(game_state["Theaters"]["Russian Theater"]["FARPS"]) do
                if idx > 1 then  output = output .. ',' end
                output = output .. '"'.. name ..'": '.. coalition
                idx = idx + 1
            end

            output = output .. '}, "ABS":{'
            idx = 1
            for name, owner in pairs(game_state["Theaters"]["Russian Theater"]["Airfields"]) do
                if idx > 1 then  output = output .. ',' end
                output = output .. '"' .. name .. '": '.. owner
                idx = idx + 1
            end

            output = output .. '}}'
			local file = io.open(stateFile, 'w')
            file:write(output)
            file:close()
        end)
end, {}, 23, 27)
