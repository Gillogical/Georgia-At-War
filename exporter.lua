local write_state = function()
    local stateFile = lfs.writedir()..[[Scripts\GAW\state.json]]
    local fp = io.open(stateFile, 'w')
    fp:write(json:encode(game_state))
    fp:close()
end

SCHEDULER:New(nil, write_state, {}, 513, 580)

-- update list of active CTLD AA sites in the global game state
function enumerateCTLD()
    local CTLDstate = {}
    for _groupname, _groupdetails in pairs(ctld.completeAASystems) do
        local CTLDsite = {}
        for k,v in pairs(_groupdetails) do
            CTLDsite[v['unit']] = v['point']
        end
        CTLDstate[_groupname] = CTLDsite
    end
    game_state["Theaters"]["Russian Theater"]["Hawks"] = CTLDstate
end

ctld.addCallback(function(_args)
    if _args.action and _args.action == "unpack" then
        local name
        local groupname = _args.spawnedGroup:getName()
        if string.match(groupname, "Hawk") then
            name = "hawk"
        elseif string.match(groupname, "Avenger") then
            name = "avenger"
        elseif string.match(groupname, "M 818") then
            name = 'ammo'
        elseif string.match(groupname, "Gepard") then
            name = 'gepard'
        elseif string.match(groupname, "MLRS") then
            name = 'mlrs'
        elseif string.match(groupname, "JTAC") then
            name = 'jtac'
        end

        table.insert(game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"], {
            name=name, 
            pos=GROUP:FindByName(groupname):GetVec2()
        })

        enumerateCTLD()
        write_state()
    end
end)
