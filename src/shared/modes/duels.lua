local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local ROLE_BYSTANDER = "bystander"
local ROLE_GUNSLINGER = "gunslinger"
local ROLE_KNIFEWIELDER = "knifewielder"

return {
    name = "Duels",
    description = "One gun, one blade. Last player standing wins.",
    maps = { "testmap" },
    color = Color3.fromRGB(252, 89, 100),

    roles = {
        [ROLE_BYSTANDER] = {
            name = "Bystander",
            description = "Outlive everyone.",
        },

        [ROLE_KNIFEWIELDER] = {
            name = "Knifewielder",
            description = "Kill the gunslinger.",
        },

        [ROLE_GUNSLINGER] = {
            name = "Gunslinger",
            description = "Shoot the knifewielder.",
        },
    },

    assignRoles = function(ctx)
        local remaining = TableUtil.Copy(ctx.participants)
        local kw = table.remove(remaining, math.random(1, #remaining))
        local gs = table.remove(remaining, math.random(1, #remaining))

        for _, participant in ipairs(ctx.participants) do
            local role = ROLE_BYSTANDER

            if participant == kw then
                role = ROLE_KNIFEWIELDER
            elseif participant == gs then
                role = ROLE_GUNSLINGER
            end

            ctx:AssignRole(participant, role)
        end

        ctx.knifewielder = kw
        ctx.gunslinger = gs
    end,

    onStart = function(ctx)
        ctx:GiveKnife(ctx.kw, true)
        ctx:GiveGun(ctx.gs, true)
    end,

    onGunKill = function(ctx, victim, _)
        local legal = victim == ctx.knifewielder
        if not legal then
            --TODO: punish gunslinger
            do end
        end

        return legal
    end,

    onKill = function(ctx, _, _, _)
        -- Last player standing wins!
        local alive = TableUtil.Keys(ctx.alive)
        if #alive == 1 then
            ctx:End(alive[1])
        end
    end,
}