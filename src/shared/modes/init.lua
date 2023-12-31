local modes = {}

for _, child in ipairs(script:GetChildren()) do
    local modeId = child.Name

    -- Mode setup
    local mode = require(child)
    assert(mode.maps, "Mode " .. modeId .. " is missing a maps declaration")
    mode.id = modeId
    mode.ffa = mode.teams == nil
    
    modes[modeId] = mode
end

return modes