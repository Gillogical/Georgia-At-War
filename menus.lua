-- Global Menu, available to everyone
XportMenu = CoalitionMenu(coalition.side.BLUE, "Deploy Airfield Security Forces")
FARPXportMenu = CoalitionMenu(coalition.side.BLUE, "Deploy FARP/Warehouse Security Forces")
--imperialSettings = SETTINGS:Set("IMPERIALDOGS")
--imperialSettings:SetImperial()
--metricSettings = SETTINGS:Set("COMMUNISTPIGS")


GetCoordinateString = function(grp, p)
    local lat, long = coord.LOtoLL(p)
    local type = 1
    local metric = false
    if string.match(grp:getName(), "Hawg") then 
        type = 2
    elseif string.match(grp:getName(), "Chevy") then
        type = 4
        metric = true
     elseif string.match(grp:getName(), "Colt") then
        type = 3
     else
        type = 1
     end

    if grp:getName() == "Chevy 3" or grp:getName() == "Chevy 4" then
        type = 1
    end
    coords = {
        function() return mist.tostringLL(lat, long, 3, false) end,
        function() return mist.tostringMGRS(coord.LLtoMGRS(lat,long), 5) end,
        function() return mist.tostringLL(lat, long, 3, true) end,
        function() return "" end,
    }
    return coords[type]() .. " -- " .. mist.getBRString({units = {grp:getUnit(1):getName()}, ref=p, alt=false, metric=metric})

end

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    log("Building radio menus")

    GroupCommand(Group:getID(), "FARP/WAREHOUSE Locations", nil, function()
        local output = [[NW FARP: 45 12'10"N 38 4'45" E
SW FARP: 44 55'45"N 38 5'17" E
NE FARP: 45 10'4" N 38 55'22"E
SE FARP: 44 50'7" N 38 46'34"E
MAYKOP AREA FARP: 44 42'47" N 39 34' 55"E]]
        MessageToGroup( Group:getID(), output, 60 )
    end)

    local MissionMenu = GroupCommand(Group:getID(), "Get Mission Status", nil, function()
        MessageToGroup(Group:getID(), TheaterUpdate("Russian Theater"), 60)
    end)


    local MissionMenu = GroupMenu(Group:getID(), "Get Current Missions")
    GroupCommand(Group:getID(), "Convoy Strike", MissionMenu, function()
        ConvoyUpdate(Group)
    end)

    GroupCommand(Group:getID(), "SEAD", MissionMenu, function()
        log("Sending SAM report")
        local sams ="ACTIVE SAM REPORT:\n"
        for group_name, group_table in pairs(game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
            log("Iterating sam group " .. group_name)
            local type_name = group_table["spawn_name"]
            local callsign = group_table['callsign']
            --TODO: Add BR etc. again. Can't easily figure it out yet.
            log("appending message")
            sams = sams .. "OBJ: ".. callsign .." -- TYPE: " .. type_name ..": \t" .. GetCoordinateString(Group, group_table["position"]) .. "\n"
        end
        MessageToGroup(Group:getID(), sams, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Air Interdiction", MissionMenu, function()
    GroupCommand(Group:getID(), "Air Interdiction", MissionMenu, function()
        local bais ="BAI TASK LIST:\n"
        for id,group_table in pairs(game_state["Theaters"]["Russian Theater"]["BAI"]) do
            local type_name = group_table["spawn_name"]
            local lat,long = coord.LOtoLL(group_table["position"])
            bais = bais .. "OBJ: " .. group_table["callsign"] .. " -- " .. type_name .. ": \t" .. GetCoordinateString(Group, group_table["position"]) .. "\n"
        end
        MessageToGroup(Group:getID(), bais, 60)
    end)

    GroupCommand(Group:getID(), "Strike", MissionMenu, function()
        local strikes ="STRIKE TARGET LIST:\n"
        for group_name,group_table in pairs(game_state["Theaters"]["Russian Theater"]["C2"]) do
            local lat,long = coord.LOtoLL(group_table["position"])
            local callsign = group_table['callsign']
            strikes = strikes .. "OBJ: " .. callsign .. " -- MOBILE CP: \t" .. GetCoordinateString(Group, group_table["position"]) .. "\n" -- " ".. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end
        
        for group_name,group_table in pairs(game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do
            local lat,long = coord.LOtoLL(group_table["position"])
            local callsign = group_table['callsign']
            local spawn_name = group_table['spawn_name']
            strikes = strikes .. "OBJ: " .. callsign .. " -- " .. spawn_name .. ": \t" .. GetCoordinateString(Group, group_table["position"]) .. "\n" -- " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end

        --MESSAGE:New(strikes, 60):ToGroup(Group)
        MessageToGroup(Group:getID(), strikes, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Naval Strike", MissionMenu, function()
    GroupCommand(Group:getID(), "Naval Strike", MissionMenu, function()
        local output ="MARITIME REPORT:\n"
        for group_name, group_table in pairs(game_state["Theaters"]["Russian Theater"]["NavalStrike"]) do
            local type_name = group_table["spawn_name"]
            local lat,long = coord.LOtoLL(group_table["position"])
            if lat and long then
                local callsign = group_table['callsign']
                output = output .. "OBJ: ".. callsign .." -- TYPE: " .. type_name ..": \t" ..  GetCoordinateString(Group, group_table["position"]) .. "\n" -- " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
            end
        end
        --MESSAGE:New(output, 60):ToGroup(Group)
        MessageToGroup(Group:getID(), output, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Interception", MissionMenu, function()
    GroupCommand(Group:getID(), "Interception", MissionMenu, function()
        local intercepts ="INTERCEPTION TARGETS:\n"
        for i,group_name in ipairs(game_state["Theaters"]["Russian Theater"]["AWACS"]) do
            local g = Group.getByName(group_name)
            local lat,long = coord.LOtoLL(GetCoordinate(g))
            if lat and long then
                local group_coord = GetCoordinate(Group)
                local coords = {
                    mist.tostringLL(lat, long, 3),
                    --coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDMS(), 
                }
                intercepts = intercepts .. "AWACS: \t" .. coords[type] .. "\n"
            end
        end

        for i,group_name in ipairs(game_state["Theaters"]["Russian Theater"]["Tanker"]) do
            local g = Group.getByName(group_name)
            local coord = GetCoordinate(g)
            local group_coord = GetCoordinate(Group)

            local coords = {
                mist.tostringLL(lat, long, 3),
                --coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDMS(), 
                --coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringMGRS(),
                --coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDDM(),
                --coord:ToStringBRA(group_coord, useSettings),
            }
            intercepts = intercepts .. "TANKER: \t" .. coords[type] .. "\n"
        end
        MessageToGroup(Group:getID(), intercepts, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Check In On-Call CAS", MissionMenu, function()
    GroupCommand(Group:getID(), "Check In On-Call CAS", MissionMenu, function()
        if #oncall_cas > 2 then
            --MESSAGE:New("No more on call CAS taskings are available, please try again when players currently running CAS are finished."):ToGroup(Group)
            MessageToGroup(Group:getID(), "No more on call CAS taskings are available, please try again when players currently running CAS are finished.", 30)
            return
        end

        for i,v in ipairs(oncall_cas) do
            if v.name == Group:getName() then
                --MESSAGE:New("You are already on call for CAS.  Stand by for tasking")
                MessageToGroup( Group:getID(), "You are already on call for CAS.  Stand by for tasking", 30)
                return
            end
        end

        trigger.action.outSoundForGroup(Group:getID(), standbycassound)
        --MESSAGE:New("Understood " .. Group:GetName() .. ", hold position east of Anapa and stand by for tasking.\nSelect 'Check Out On-Call CAS' to cancel mission" ):ToGroup(Group)
        MessageToGroup(Group:getID(), "Understood " .. Group:getName() .. ", hold position east of Anapa and stand by for tasking.\nSelect 'Check Out On-Call CAS' to cancel mission", 30)
        table.insert(oncall_cas, {name = Group:getName(), mission = nil})
    end)

    --MENU_GROUP_COMMAND:New(Group, "Check Out On-Call CAS", MissionMenu, function()
    GroupCommand(Group:getID(), "Check Out On-Call CAS", MissionMenu, function()
        for i,v in ipairs(oncall_cas) do
            if v.name == Group:getName() then
                pcall(function() Group.getByName(oncall_cas[i].mission[1]):destroy() end)
                pcall(function() Group.getByName(oncall_cas[i].mission[2]):destroy() end)
                table.remove(oncall_cas, i)
                trigger.action.outSoundForGroup(Group:getID(), terminatecassound)
                return
            end
        end
    end)

    --MENU_GROUP_COMMAND:New(Group, "Get Current CAS Target Location", MissionMenu, function()
    GroupCommand(Group:getID(), "Get Current CAS Target Location", MissionMenu, function()
        for i,v in ipairs(oncall_cas) do
            if v.name == Group:GetName() then
                local enemy_coord = GetCoordinate(Group.getByName(v.mission[1]))
                local group_coord = GetCoordinate(Group)
                --MESSAGE:New("TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke", 60):ToGroup(Group)
                --TODO This won't work.
                MessageToGroup( Group:getID(), "TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke", 60)
            end
        end
    end)
    log("Done building radio menus")
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    log("Preparing menus for NorthGeorgiaTransportSpawns")
    --local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function()
    local curMenu = CoalitionCommand(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function()
        log("Requested deploy to " .. name)
        local spawn_idx =1
        local ab = Airbase.getByName(name)
        if ab:getCoalition() == 1 then spawn_idx = 2 end
        local new_spawn_time = SpawnDefenseForces(name, timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn[spawn_idx])
        if new_spawn_time ~= nil then
            trigger.action.outSoundForCoalition(2, ableavesound)
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
    log("Done preparing menus for NorthGeorgiaTransportSpawns")
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    log("Preparing menus for NorthGeorgiaFARPTransportSpawns")
    --local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name .. " FARP/WAREHOUSE", FARPXportMenu, function() 
    local curMenu = CoalitionCommand(coalition.side.BLUE, "Deploy to " .. name .. " FARP/WAREHOUSE", FARPXportMenu, function() 
        log("Requested deploy to " .. name)
        local new_spawn_time = SpawnDefenseForces(name, timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn[1])
        if new_spawn_time ~= nil then
            trigger.action.outSoundForCoalition(2, farpleavesound)
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
    log("Done Preparing menus for NorthGeorgiaFARPTransportSpawns")
end


function groupBirthHandler( Event )
    if Event.id ~= world.event.S_EVENT_BIRTH then return end
    if not Event.initiator then return end
    if not Event.initiator.getGroup then return end
    local grp = Event.initiator:getGroup()
    if grp then
        for i,u in ipairs(grp:getUnits()) do
            if u:getPlayerName() ~= "" then
                log("Group birth. Building menus")
                buildMenu(grp)
                log("Done group birth. Building menus")
            end
        end
    end
end
mist.addEventHandler(groupBirthHandler)
log("Event Handler complete")
log("menus.lua complete")