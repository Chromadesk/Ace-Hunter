local NPC = script.parent
local humanoid = NPC.Humanoid
local pauseStateChange = false

local ProximityMethods = require(game:GetService("ReplicatedStorage").ProximityMethods)

local Anims = NPC:WaitForChild("Animations")
-- local animations = {
--     idleCalm = humanoid:LoadAnimation(Anims:WaitForChild("IdleCalm")),
--     idleScared1 = humanoid:LoadAnimation(Anims:WaitForChild("IdleScared1")),
--     idleScared1 = humanoid:LoadAnimation(Anims:WaitForChild("IdleScared2")),
--     run = humanoid:LoadAnimation(Anims:WaitForChild("Run")),
--     walk = humanoid:LoadAnimation(Anims:WaitForChild("Walk")),
-- }

local sounds = {
    scared = NPC.HumanoidRootPart:WaitForChild("Scared"),
}

local stats = {}
stats.WALK_SPEED = 16
stats.RUN_SPEED = 22

local stateControl = {}
stateControl.State = "idle"
stateControl.FollowPart = Instance.new("Part")
    stats.FollowPart.Anchored = true
    stats.FollowPart.CanCollide = false
    stats.FollowPart.Transparency = 1
    stats.FollowPart.Name = "FollowPart"

local function orientNPC(position)
	local HRP = NPC.HumanoidRootPart
    HRP.CFrame = CFrame.new(HRP.CFrame.Position, Vector3.new(position.X, HRP.CFrame.Position.Y, position.Z))
end

stateControl.StopAnimations = function()
    for _,v in pairs(animations) do
        v:Stop()
    end
end

--NPC Behaviors:

--Follow player
--Go to workplace
--Run from vampires
--Stand idly
--Hide idly