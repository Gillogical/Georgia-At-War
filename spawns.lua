-- Objective Names
objective_names = {
    "Blackjack", "Wildcard", "Crackpipe", "Bullhorn", "Outlaw", "Eclipse","Joker", "Anthill",
    "Firefly", "Buzzard", "Eagle", "Rambo", "Rocky", "Dredd", "Smokey", "Vulture", "Parrot",
    "Copper", "Ender", "Sanchez", "Freeman", "Bandito", "Atlanta", "Raleigh", "Charlotte", "Orlando",
    "Tiger", "Moocow", "Turkey", "Scarecrow", "Lancer", "Subaru", "Tucker", "Blazer", "Snowball"
}

objective_idx = 1

getCallsign = function()
    local callsign = objective_names[objective_idx]
    objective_idx = objective_idx + 1
    if objective_idx > #objective_names then objective_idx = 1 end
    return callsign
end

local attack_message_lock = 0

buildHitEvent = function(group, callsign)
    for i,unit in ipairs(group:GetUnits()) do
        unit:HandleEvent(EVENTS.Hit)
        function unit:OnEventHit(EventData)
            if EventData.IniPlayerName then
                local etime = timer.getAbsTime() + env.mission.start_time
                if etime > attack_message_lock + 5 then
                    local output = EventData.IniGroupName 
                    output = output .. " (" .. EventData.IniPlayerName .. ")"
                    output = output .. " is attacking " .. EventData.TgtTypeName .. " at objective " .. callsign
                    MESSAGE:New(output, 10):ToAll()
                    attack_message_lock = etime
                end
            end
        end
    end
end

buildCheckSAMEvent = function(group, callsign)
    for i,unit in ipairs(group:GetUnits()) do
        unit:HandleEvent(EVENTS.Dead)
        function unit:OnEventDead(EventData)
            local radars = 0
            local launchers = 0
            for i,inner_unit in ipairs(group:GetUnits()) do
                local type_name = inner_unit:GetTypeName()
                if type_name == "Kub 2P25 ln" then launchers = launchers + 1 end
                if type_name == "Kub 1S91 str" then radars = radars + 1 end
                if type_name == "S-300PS 64H6E sr" then radars = radars + 1 end
                if type_name == "S-300PS 40B6MD sr" then radars = radars + 1 end
                if type_name == "S-300PS 40B6M tr" then radars = radars + 1 end
                if type_name == "S-300PS 5P85C ln" then launchers = launchers + 1 end
                if type_name == "S-300PS 5P85D ln" then launchers = launchers + 1 end
            end

            if radars == 0 or launchers == 0 then
                game_state['Theaters']['Russian Theater']['StrategicSAM'][group:GetName()] = nil
                MESSAGE:New("SAM " .. callsign .. " has been destroyed!"):ToAll()
            end
        end
    end
end

buildCheckEWREvent = function(group, callsign)
    for i,unit in ipairs(group:GetUnits()) do
        unit:HandleEvent(EVENTS.Dead)
        function unit:OnEventDead(EventData)
            local radars = 0
            for i,inner_unit in ipairs(group:GetUnits()) do
                if inner_unit:GetTypeName() == "1L13 EWR" then radars = radars + 1 end
            end

            if radars == 0 then
                game_state['Theaters']['Russian Theater']['EWR'][group:GetName()] = nil
                MESSAGE:New("EWR " .. callsign .. " has been destroyed!"):ToAll()
            end
        end
    end
end

buildCheckC2Event = function(group, callsign)
    for i,unit in ipairs(group:GetUnits()) do
        unit:HandleEvent(EVENTS.Dead)
        function unit:OnEventDead(EventData)
            local cps = 0
            for i,inner_unit in ipairs(group:GetUnits()) do
                if inner_unit:GetTypeName() == "SKP-11" then cps = cps + 1 end
            end

            if cps == 0 then
                game_state['Theaters']['Russian Theater']['C2'][group:GetName()] = nil
                MESSAGE:New("C2 " .. callsign .. " has been destroyed!"):ToAll()
            end
        end
    end
end

-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ["Novorossiysk"] = SPAWN:New("NovoroTransport"),
    ["Gelendzhik"] = SPAWN:New("GelenTransport"), 
    ["Krasnodar-Center"] = SPAWN:New("KDARTransport"),
    ["Krasnodar-East"] = SPAWN:New("KDAR2Transport"),
    ["Krymsk"] = SPAWN:New("KrymskTransport")
}

NorthGeorgiaFARPTransportSpawns = {
    ["NW"] = SPAWN:New("NW FARP HELO"),
    ["NE"] = SPAWN:New("NE FARP HELO"), 
    ["SW"] = SPAWN:New("SW FARP HELO"),
    ["SE"] = SPAWN:New("SE FARP HELO"),
}

-- Support Spawn
TexacoSpawn = SPAWN:New("Texaco"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(120)
ShellSpawn = SPAWN:New("Shell"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(140)
OverlordSpawn = SPAWN:New("AWACS Overlord"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(160)
AWACSPatrol = SPAWN:New("AWACS Patrol"):InitRepeatOnEngineShutDown():InitLimit(2, 0):SpawnScheduled(600)

-- Local defense spawns.  Usually used after a transport spawn lands somewhere.
AirfieldDefense = SPAWN:New("AirfieldDefense")

-- Strategic REDFOR spawns
RussianTheaterSA10Spawn = { SPAWN:New("SA10"), "SA10" }
RussianTheaterSA6Spawn = { SPAWN:New("SA6"), "SA6" }
RussianTheaterEWRSpawn = { SPAWN:New("EWR"), "EWR" }
RussianTheaterC2Spawn = { SPAWN:New("C2"), "C2" }
RussianTheaterAirfieldDefSpawn = SPAWN:New("Russia-Airfield-Def")
RussianTheaterAWACSSpawn = SPAWN:New("A50"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)
RUSTankerSpawn = SPAWN:New("IL78-RUSTanker"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)

-- REDFOR specific airfield defense spawns
DefKrasPash = SPAWN:New("Red Airfield Defense Kras-Pash 1")
DefKrasCenter = SPAWN:New("Red Airfield Defense Kras-Center 1")
DefKrymsk = SPAWN:New("Red Airfield Defense Krymsk 1")
DefNovo = SPAWN:New("Red Airfield Defense Novo 1")
DefGlensPenis = SPAWN:New("Red Airfield Defense GlensDick 1")

-- CAP Redfor spawns
RussianTheaterMig212ShipSpawn = SPAWN:New("Mig21-2ship")
RussianTheaterMig292ShipSpawn = SPAWN:New("Mig29-2ship")
RussianTheaterSu272sShipSpawn = SPAWN:New("Su27-2ship")
RussianTheaterMig312ShipSpawn = SPAWN:New("Mig31-2ship"):InitLimit(2, 0)
RussianTheaterAWACSPatrol = SPAWN:New("SU27-RUSAWACS Patrol"):InitRepeatOnEngineShutDown():InitLimit(2, 0):SpawnScheduled(600)

-- Strike Target Spawns
RussianHeavyArtySpawn = { SPAWN:New("ARTILLERY"), "ARTILLERY" }
ArmorColumnSpawn = { SPAWN:New("ARMOR COLUMN"), "ARMOR COLUMN" }
MechInfSpawn = { SPAWN:New("MECH INF"), "MECH INF" }
AmmoDumpSpawn = { SPAWNSTATIC:NewFromStatic("Ammo Dump", country.id.RUSSIA), "Ammo Dump" }
CommsArraySpawn = { SPAWNSTATIC:NewFromStatic("Comms Array", country.id.RUSSIA), "Comms Array" }
PowerPlantSpawn = { SPAWNSTATIC:NewFromStatic("Power Plant", country.id.RUSSIA), "Power Plant" }

-- Airfield CAS Spawns
RussianTheaterCASSpawn = SPAWN:New("Su25T-CASGroup")
RussianTheaterCASSpawn:HandleEvent(EVENTS.EngineShutdown)
function RussianTheaterCASSpawn:_OnEngineShutdown(EventData)
    local grp = EventData.IniGroup
    grp:Destroy()
end
--RussianTheatreCASEscort = SPAWN:New("Su27CASEscort")

-- Group spanws for easy randomization
local allcaps = {RussianTheaterMig212ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterMig292ShipSpawn}
poopcaps = {RussianTheaterMig212ShipSpawn}
goodcaps = {RussianTheaterMig292ShipSpawn, RussianTheaterSu272sShipSpawn}
baispawns = {RussianHeavyArtySpawn, ArmorColumnSpawn, MechInfSpawn}

-- OnSpawn Callbacks.  Add ourselves to the game state
RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    RussianTheaterAWACSPatrol:Spawn()
end)

OverlordSpawn:OnSpawnGroup(function(SpawnedGroup)
    AWACSPatrol:Spawn()
end)

--local sammenu = MENU_MISSION:New("DESTROY SAMS")
RussianTheaterSA6Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, sammenu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddRussianTheaterStrategicSAM(SpawnedGroup, "SA6", callsign)
    buildHitEvent(SpawnedGroup, callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

RussianTheaterSA10Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, sammenu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddRussianTheaterStrategicSAM(SpawnedGroup, "SA10", callsign)
    buildHitEvent(SpawnedGroup, callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

--local ewrmenu = MENU_MISSION:New("DESTROY EWRS")
RussianTheaterEWRSpawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, ewrmenu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddRussianTheaterEWR(SpawnedGroup, "EWR", callsign)
    buildHitEvent(SpawnedGroup, callsign)
    buildCheckEWREvent(SpawnedGroup, callsign)
end)

--local c2menu = MENU_MISSION:New("DESTROY C2S")
RussianTheaterC2Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, c2menu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddRussianTheaterC2(SpawnedGroup, "C2", callsign)
    buildHitEvent(SpawnedGroup, callsign)
    buildCheckC2Event(SpawnedGroup, callsign)
end)

RUSTankerSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterTankerTarget(SpawnedGroup)
end)

RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterAWACSTarget(SpawnedGroup)
end)

SpawnOPFORCas = function(zone, spawn)
    log("===== CAS Spawn begin")
    local casZone = AI_CAS_ZONE:New( zone, 100, 1500, 250, 600, zone )
    local casGroup = spawn:Spawn()
    casGroup:HandleEvent(EVENTS.EngineShutdown, function(EventData)
        casGroup:Destroy()
    end)
    
    casZone:SetControllable( casGroup )
    casZone:__Start ( 1 )
    casZone:__Engage( 2 )
    log("===== CAS Spawn Done")
end

--local baimenu = MENU_MISSION:New("DESTROY BAIS")
for i,v in ipairs(baispawns) do
    v[1]:OnSpawnGroup(function(SpawnedGroup)
        local callsign = getCallsign()
        --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, baimenu, function()
        --    SpawnedGroup:Destroy()
        --end)
        AddRussianTheaterBAITarget(SpawnedGroup, v[2], callsign)
    end)
end

--local capsmenu = MENU_MISSION:New("DESTROY CAPS")
for i,v in ipairs(allcaps) do
    v:OnSpawnGroup(function(SpawnedGroup)
       -- MENU_MISSION_COMMAND:New("DESTROY " .. SpawnedGroup:GetName(), capsmenu, function()
        --    SpawnedGroup:Destroy()
        --end)
        AddRussianTheaterCAP(SpawnedGroup)
    end)
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.place:getPosition().p)
            apV3:SetX(apV3:GetX() + math.random(400, 600))
            apV3:SetY(apV3:GetY() + math.random(200))
            local air_def_grp = AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.IniGroup:GetPositionVec3())
            apV3:SetX(apV3:GetX() + math.random(-100, 200))
            apV3:SetY(apV3:GetY() + math.random(-100, 200))
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

BASE:I("HOGGIT GAW - SPAWNS COMPLETE")
log("spawns.lua complete")
