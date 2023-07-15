local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local packages = ReplicatedStorage.Packages
local Knit = require(packages.Knit)

-- Initialization
Knit.AddServicesDeep(script.services)
Knit.Start():catch(warn)