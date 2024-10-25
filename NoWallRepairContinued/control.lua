script.on_event(
    defines.events.on_entity_damaged,
    function(event)
        local tick = game.tick
        queueRepairs(event.entity, tick)
    end
)

script.on_event(
    defines.events.on_built_entity,
    function(event)
        local tick = game.tick
        queueRepairs(event.created_entity , tick)
    end
)

script.on_event(
    defines.events.on_robot_built_entity,
    function(event)
        local tick = game.tick
        queueRepairs(event.created_entity, tick)
    end
)

script.on_event(
    defines.events.on_tick,
    function(event)
        doRepairs(event)
    end
)

function queueRepairs(entity, tick)
    --log("Damaged " .. entity.name)
    if (not global.RepairQueue) then
        global.RepairQueue = {}
    end
    if (entity.type == "wall") or (entity.type == "gate") then
        local damaged = {
            entity = entity,
            tick = tick
        }
        global.RepairQueue[entity.unit_number] = damaged
       --log(serpent.block(global.RepairQueue))
    end
end

function doRepairs(event)
    local repairCount = 0
    -- local surface = game.get_surface()

    -- log("Surface: " .. surface)

    local evoFactor = game.forces["enemy"].get_evolution_factor()

    log("Evo Factor: " .. evoFactor)

    -- if (surface) then
    --     evoFactor = game.forces["enemy"].get_evolution_factor(surface)
    -- end

    local updateSpeed = settings.global["wall-repair-delay"].value or 5

    if(evoFactor < 0.5) then
        updateSpeed = updateSpeed * 2
    else
        if (evoFactor < 0.7) then
            updateSpeed = updateSpeed * 1.5
        end
    end
    if(game.tick % 60 == 0 ) then
        if (global.RepairQueue) then
            local removeList = {}
            local repairMult = settings.global["wall-repair-factor"].value or 1
            local maxRepairsPerSecond = settings.global["wall-repair-max"].value  or 100
            for k, v in pairs(global.RepairQueue) do
                local unit = v.entity
                local t = v.tick
                -- wait for 5 seconds
                if (game.tick - t > 60 * updateSpeed) then
                    --this unit hasn't been damaged in the last 5 seconds, begin repair
                    if (unit.valid) and (unit.get_health_ratio() < 1) then
                        unit.health = unit.health + ((30 * repairMult) + (30 * evoFactor))
                        repairCount = repairCount+1
                    else
                        table.insert(removeList, k)
                    end
                end
                if(repairCount > maxRepairsPerSecond) then break end
            end
            for __, v in pairs(removeList) do
                global.RepairQueue[v] = nil
            end
        end
    end
end
