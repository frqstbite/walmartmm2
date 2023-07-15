local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.Packages
local Knit = require(packages.Knit)

local MatchService = Knit.CreateService {
    Name = "MatchService",
    Client = {
        Timer = Knit.CreateProperty(0),
    },
}

function MatchService:KnitInit()
    print("MatchService is initialized!")
end

function MatchService:KnitStart()
    print("MatchService is running!")
end

return MatchService