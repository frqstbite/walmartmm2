local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)
local TableUtil = require(Packages.TableUtil)
local Trove = require(Packages.Trove)
local modes = require(ReplicatedStorage.shared.modes)

local MatchContext = {}
MatchContext.__index = MatchContext

function MatchContext.new(modeId: string, players: {Player})
    local self = setmetatable({}, MatchContext)

    self._trove = Trove.new() --Cleaned up upon match end
    self._roles = {} --Maps participant to role
    self._alive = {} --Set of participants that are alive
    self._deathEvent = self._trove:Construct(Signal)
    self._endEvent = self._trove:Construct(Signal)
    self._ended = false

    self.mode = modes[modeId]
    self.participants = {}
    self.winner = Promise.fromEvent(self._endEvent)

    -- Set up participants
    for _, player in ipairs(players) do
        -- Participants start alive.
        local participant = player.UserId
        table.insert(self.participants, participant)
        self.alive[participant] = true

        -- Detect if character dies by outside circumstances and report it
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local unreported = true
        
        local trove = self._trove:Extend() --Cleans up if match ends
        trove:AttachToInstance(character) --Detect if character is destroyed
        trove:Connect(humanoid.Died, function() --Detect if humanoid dies
            trove:Destroy()
        end)
        trove:Add(function() --Report external deaths
            if not self._ended and unreported then
                self:Kill(participant, nil, nil, false) --Report without executing
            end
        end)

        -- Execute if killed manually with :Kill
        trove:Connect(self._deathEvent, function(victim)
            if victim == participant then
                unreported = false --Death has already been recorded
                humanoid.Health = 0
            end
        end)
    end

    return self
end

function MatchContext:AssignRole(participant: number, role: string)
    assert(self.mode.roles, `Mode {self.mode.id} does not support roles`)
    assert(self.mode.roles[role], `Role {role} does not exist in mode {self.mode.id}`)

    -- Change role
    local oldRole = self._roles[participant]
    self._roles[participant] = role

    -- Notify mode of role change
    if oldRole and self.mode.roleChanged then
        self.mode.roleChanged(participant, role, oldRole)
    end
end

function MatchContext:OnTeam(participant: number, team: string): boolean
    assert(not self.mode.ffa, `Mode {self.mode.id} does not support teams`)
    local role = self._roles[participant]
    return role and self.mode.roles[role].team == team or false
end

function MatchContext:GetPlayer(participant: number): Player
    return Players:GetPlayerByUserId(participant)
end

function MatchContext:GetCharacter(participant: number): Model
    local player = self:GetPlayer(participant)
    return player and player.Character
end

function MatchContext:IsAlive(participant: number): boolean
    return self.alive[participant] or false
end

function MatchContext:GetAlive(): {number}
    return TableUtil.Keys(self._alive)
end

function MatchContext:Kill(victim: number, killer: number?, weapon: string?, execute: boolean?)
    execute = execute or true
    assert(not self._ended, `Attempt to kill after match has already ended`)
    assert(self:IsAlive(victim), `Cannot kill dead player {victim} ({self:GetPlayer(victim).Name})`)

    -- Mode decides fate of victim
    local die = true
    if killer then
        if weapon == "gun" and self.mode.onGunKill then
            die = self.mode.onGunKill(self, victim, killer)
        elseif weapon == "knife" and self.mode.onKnifeKill then
            die = self.mode.onKnifeKill(self, victim, killer)
        end
    end
    
    if die then
        self.alive[victim] = nil
        if execute then
            self._deathEvent:Fire(victim)
        end

        --TODO: drop weapons

        self.mode.onKill(self, victim, killer, weapon)
    end
end

function MatchContext:GiveKnife(participant: number, drops: boolean?)
    drops = drops or false
    print(`Granting {if drops then "droppable " else ""}knife to {participant}`)
end

function MatchContext:GiveGun(participant: number, drops: boolean?)
    drops = drops or false
    print(`Granting {if drops then "droppable " else ""}gun to {participant}`)
end

function MatchContext:End(winner: string | number | nil)
    local teamWinInFFA = self.mode.ffa and typeof(winner) == "string"
    assert(teamWinInFFA, `Team wins are not supported in FFA modes. Team: {winner}`)
    
    self._ended = true
    self._endEvent:Fire(winner)
    self._trove:Destroy()
end

return MatchContext