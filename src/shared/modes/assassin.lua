local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

return {
    name = "Assassin",
    description = "Everyone is given a knife and assigned a target. Eliminate your target, avoid your assassin.",
    color = Color3.fromRGB(255, 128, 0),

    onStart = function(ctx)
        for _, participant in ipairs(ctx.participants) do
            ctx:GiveKnife(participant)
        end
    end
}