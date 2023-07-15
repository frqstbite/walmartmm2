local Topbar = require(script.Parent.Parent.components.Topbar)

return function(root)
    local tree = Topbar {
        Parent = root,
    }
    
    return function()
        tree:Destroy()
    end
end