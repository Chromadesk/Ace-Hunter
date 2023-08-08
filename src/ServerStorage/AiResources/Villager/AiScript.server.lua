local NPC = script.parent
local humanoid = NPC.Humanoid
local pauseStateChange = false
local InteractionRE = NPC:WaitForChild("InteractionRE")
local IsProtected = NPC:WaitForChild("IsProtected")

local ProximityMethods = require(game:GetService("ReplicatedStorage").ProximityMethods)
local NPCMethods = require(game:GetService("ReplicatedStorage").NPCMethods)

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
stats.FOLLOW_BUFFER = 5 --How much room the NPC will leave between themselves and the player when following them.
stats.PROTECTION_RANGE = 50 --Enemies will not attack if a player is within this distance.

local stateControl = {}
stateControl.State = "idle"
stateControl.FollowPart = Instance.new("Part") --shh the NPC actually follows this instead of the player
    stateControl.FollowPart.Anchored = true
    stateControl.FollowPart.CanCollide = false
    stateControl.FollowPart.Transparency = 1
    stateControl.FollowPart.Name = "FollowPart"

--NPC Behaviors:

--Follow player
stateControl.EnterFollowState = function(target)
    if pauseStateChange then return end
    stateControl.State = "follow"
    --NPCMethods.stopAnimations(Anims)
    humanoid.WalkSpeed = stats.RUN_SPEED
    while stateControl.State == "follow" and wait(0.001) and target.Humanoid.Health > 0 and humanoid.Health > 0 do
        IsProtected.Value = NPCMethods.isPlayerNear(NPC, stats.PROTECTION_RANGE)
        NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
        stateControl.FollowPart.CFrame = target.HumanoidRootPart.CFrame
        humanoid:MoveTo(stateControl.FollowPart.Position)

        local closestCharacter, closestDistance = ProximityMethods.getClosestCharacter(NPC, false)
        if not closestCharacter then break end

        --If too close, stop moving or slow down.
        if closestDistance < stats.FOLLOW_BUFFER + 15 then humanoid.WalkSpeed = stats.WALK_SPEED end --walk if too close
        if closestDistance < stats.FOLLOW_BUFFER then humanoid.WalkSpeed = 0 end --stop if too close
        if closestDistance > stats.FOLLOW_BUFFER + 15 then humanoid.WalkSpeed = stats.RUN_SPEED end --run if not too close
    end
    stateControl.EnterIdleState()
end
--Go to workplace

--Run from vampires

--Stand idly
stateControl.EnterIdleState = function()
    if pauseStateChange then return end
    stateControl.State = "idle"
    while stateControl.State == "idle" and wait(0.1) do
        IsProtected.Value = NPCMethods.isPlayerNear(NPC, stats.PROTECTION_RANGE)
    end
    --NPCMethods.stopAnimations(Anims)
end

--Hide idly

InteractionRE.onServerEvent:Connect(function(player)
    print(player)
    print(stateControl.State)
    if stateControl.State ~= "follow" then stateControl.EnterFollowState(player.Character)
    else stateControl.EnterIdleState() end
end)