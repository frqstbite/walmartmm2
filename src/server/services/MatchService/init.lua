local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local modes = require(ReplicatedStorage.shared.modes)
local MatchContext = require(script.MatchContext)

local function playersRequired(modeId)
    local mode = modes[modeId]
    local minimum = mode.minPlayers or 2
    local amount = #Players:GetPlayers()
    return math.max(minimum - amount, 0)
end

local function teleportPlayersRandomly(ctx, map)
    local spawns = map:FindFirstChild("spawns")
    assert(spawns, `Mode {ctx.mode.id} and map {map.Name} are missing teleportation implementations!`)


end

local MatchService = Knit.CreateService {
    Name = "MatchService",
    Client = {},
}

function MatchService:KnitInit()
    print("MatchService is initialized!")
end

function MatchService:KnitStart()
    while true do
        local success, err = pcall(self.Loop, self)
        if not success then
            warn(`Match ended with error: {err}`)
        end
    end
end

function MatchService:CreateMatch(modeId)
    return MatchContext.new(modeId, Players:GetPlayers())
end

function MatchService:Loop()
    -- 15 second intermission
    print("Intermission")
    task.wait(15)

    -- select random mode
    local modeId = TableUtil.Sample(TableUtil.Keys(modes), 1)
    local mode = modes[modeId]
    print("Mode: " .. modeId)

    -- 5 second delay while mode info is shown
    task.wait(5)

    -- map voting for 20 seconds
    local choices = TableUtil.Sample(mode.maps, 3)
    print("Map voting: " .. table.concat(choices, ", "))
    task.wait(20)

    local map = TableUtil.Sample(choices, 1)
    print("Map chosen! " .. map)

    -- 5 second delay while map info is shown
    task.wait(5)

    -- display match info in lobby

    -- make sure enough players are in the game to start
    local short = playersRequired(modeId)
    if short > 0 then
        print(`{short} player(s) short! Waiting for more...`)
        task.wait(30)

        if not playersRequired(mode) then
            print("Not enough players to start! Vote discarded.")
            return --restart match loop, discarding vote results
        end
    end

    -- create match
    local ctx = self:CreateMatch(modeId)
    print("Match created!")
    
    -- mode: assign roles
    if mode.assignRoles then
        mode.assignRoles(ctx)
    end

    -- mode: teleport players to map
    print("Teleporting players...")
    if mode.teleportPlayers then
        mode.teleportPlayers(ctx, map)
    else
        teleportPlayersRandomly(ctx, map)
    end

    -- wait for players to teleport
    task.wait(3)

    -- start countdown
    for i = 10, 0, -1 do
        print(`Match starts in {i}...`)
        task.wait(1)
    end

    -- mode: start match
    if mode.onStart then
        mode.onStart(ctx)
    end
end

return MatchService