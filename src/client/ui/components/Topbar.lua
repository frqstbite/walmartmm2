local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New

return function(props)
    props = props or {}
    props.Size = props.Size or UDim2.new(1, 0, 0, 48)

    return New "Frame" (props)
end