local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

for k, wall in pairs(data.raw["wall"]) do
    if (string.find(wall.name, "wall")) then
        if (wall.flags) and (not has_value(wall.flags, "not-repairable")) then
            table.insert(wall.flags, "not-repairable")
        end
    end
end

for k, wall in pairs(data.raw["gate"]) do
    if (string.find(wall.name, "gate")) then
        if (wall.flags) and (not has_value(wall.flags, "not-repairable")) then
            table.insert(wall.flags, "not-repairable")
        end
    end
end
