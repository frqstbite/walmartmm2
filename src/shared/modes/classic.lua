local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local TEAM_INNOCENT = "innocent"
local TEAM_MURDERER = "murderer"

local ROLE_INNOCENT = "innocent"
local ROLE_SHERIFF = "sheriff"
local ROLE_HERO = "hero"
local ROLE_MURDERER = "murderer"

return {
    name = "Classic",
    description = "One among you is a murderer. Be careful who you turn your back to.",
    maps = { "testmap" },
    defaultWinner = TEAM_INNOCENT,

    teams = {
        [TEAM_INNOCENT] = {
            name = "Innocents",
            color = Color3.fromRGB(0, 255, 0),
        },
        [TEAM_MURDERER] = {
            name = "The Murderer",
            color = Color3.fromRGB(255, 0, 0),
        }
    },

    roles = {
        [ROLE_INNOCENT] = {
            name = "Innocent",
            description = "Outlive the murderer.",
            team = TEAM_INNOCENT,
        },

        [ROLE_SHERIFF] = {
            name = "Sheriff",
            description = "Protect the innocents.",
            color = Color3.fromRGB(0, 0, 255),
            team = TEAM_INNOCENT,
        },

        [ROLE_HERO] = {
            name = "Hero",
            color = Color3.fromRGB(255, 255, 0),
            team = TEAM_INNOCENT,
        },

        [ROLE_MURDERER] = {
            name = "Murderer",
            description = "Kill everyone.",
            team = TEAM_MURDERER,
        },
    },

    assignRoles = function(ctx)
        local remaining = TableUtil.Copy(ctx.participants)
        local murderer = table.remove(remaining, math.random(1, #remaining))
        local sheriff = table.remove(remaining, math.random(1, #remaining))

        for _, participant in ipairs(ctx.participants) do
            local role = ROLE_INNOCENT

            if participant == murderer then
                role = ROLE_MURDERER
            elseif participant == sheriff then
                role = ROLE_SHERIFF
            end

            ctx:AssignRole(participant, role)
        end

        ctx.murderer = murderer
        ctx.sheriff = sheriff
    end,

    onStart = function(ctx)
        ctx:GiveKnife(ctx.murderer)
        ctx:GiveGun(ctx.sheriff, true)
    end,

    onGunKill = function(ctx, victim, sheriff)
        if ctx:OnTeam(victim, TEAM_INNOCENT) then --They killed an innocent!
            ctx:Kill(sheriff)
        end

        return true
    end,

    onKill = function(ctx, victim, _, _)
        if victim == ctx.murderer then --Murderer is dead. Game over!
            ctx:End(TEAM_INNOCENT)
            return
        end

        if #TableUtil.Keys(ctx.alive) == 1 then --Only one person is left, and the murderer has not died.
            ctx:End(TEAM_MURDERER)
        end
    end,
}