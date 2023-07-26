local NPC = script.parent
local humanoid = NPC.Humanoid
local pauseStateChange = false

local ProximityMethods = require(game:GetService("ReplicatedStorage").ProximityMethods)

local Anims = NPC:WaitForChild("Animations")
local animations = {
    idleCalm = humanoid:LoadAnimation(Anims:WaitForChild("IdleCalm")),
    idleScared1 = humanoid:LoadAnimation(Anims:WaitForChild("IdleScared1")),
    idleScared1 = humanoid:LoadAnimation(Anims:WaitForChild("IdleScared2")),
    run = humanoid:LoadAnimation(Anims:WaitForChild("Run")),
    walk = humanoid:LoadAnimation(Anims:WaitForChild("Walk")),
}

local sounds = {
    scared = NPC.HumanoidRootPart:WaitForChild("Scared"),
}

local stats = {}
stats.WALK_SPEED = 16
stats.RUN_SPEED = 22