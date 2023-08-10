local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local MAP_FOLDER = ServerStorage:FindFirstChild("maps")

local MapService = Knit.CreateService {
    Name = "MapService",
    Client = {},

    _loaded = Trove.new(),
    _maps = {},
}

function MapService:KnitInit()
    for _, map in ipairs(MAP_FOLDER:GetChildren()) do
        self._maps[map.Name] = map
    end
end

function MapService:LoadMap(name)
    self:UnloadMap() --Just in case

    local map = self._maps[name]
    assert(map, `Attempt to load nonexistent map ${name}`)
    map = self._loaded:Add(map:Clone())
    map.Parent = workspace
end

function MapService:UnloadMap()
    self._loaded:Clean()
end

function MapService:GetMapTrove()
    return self._loaded
end

return MapService