local NPC = script.parent
local humanoid = NPC.Humanoid
local AttackHitbox = NPC:WaitForChild("AttackHitbox")
local pauseStateChange = false

local ProximityMethods = require(game:GetService("ReplicatedStorage").ProximityMethods)
local NPCMethods = require(game:GetService("ReplicatedStorage").NPCMethods)

local Anims = NPC:WaitForChild("Animations")
local animations = {
    strafeRight = humanoid:LoadAnimation(Anims:WaitForChild("Strafe Right")),
    strafeLeft = humanoid:LoadAnimation(Anims:WaitForChild("Strafe Left")),
    lunge = humanoid:LoadAnimation(Anims:WaitForChild("Chase Alt")),
    lungeBegin = humanoid:LoadAnimation(Anims:WaitForChild("Lunge Begin")),
    chase = humanoid:LoadAnimation(Anims:WaitForChild("Chase")),
    idle = humanoid:LoadAnimation(Anims:WaitForChild("Idle")),
    hit = humanoid:LoadAnimation(Anims:WaitForChild("Hit")),
    dodge = humanoid:LoadAnimation(Anims:WaitForChild("Dodge"))
}

local sounds = {
    breathing = NPC.HumanoidRootPart:WaitForChild("Breathing"),
    lunge = NPC.HumanoidRootPart:WaitForChild("Lunge"),
    lungeBegin = NPC.HumanoidRootPart:WaitForChild("Lunge Begin"),
    taunt = NPC.HumanoidRootPart:WaitForChild("Taunt")
}

local stats = {}
stats.FOLLOW_DISTANCE = 250
stats.STALK_DISTANCE = 20 --How much distance the NPC will stay away from their target when stalking
stats.CHASE_SPEED = 25
stats.LUNGE_SPEED = 40
stats.SLASH_DAMAGE = 50
stats.BITE_DAMAGE = 999 --How much damage the NPC does when "biting" (hitting target's back)
stats.ATTACK_CHANCE = 2 -- Random chance out of 1000 to attack autonomously while stalking.
stats.State = "idle"
stats.FollowPart = Instance.new("Part") --shh the NPC actually follows this instead of the player
    stats.FollowPart.Anchored = true
    stats.FollowPart.CanCollide = false
    stats.FollowPart.Transparency = 1
    stats.FollowPart.Name = "FollowPart"

local attacking = false
AttackHitbox.touched:Connect(function(toucher)
    local closestTarget, targetAngle = nil

    local closestPlayer, _, playerAngle = ProximityMethods.getClosestPlayer(NPC, false)
    local closestVillager, _, villagerAngle = ProximityMethods.getClosestVillager(NPC, false)
    if toucher:IsDescendantOf(closestPlayer) then
        closestTarget = closestPlayer
        targetAngle = playerAngle
    end
    if toucher:IsDescendantOf(closestVillager) then
        closestTarget = closestVillager
        targetAngle = villagerAngle
    end

    if attacking then return end
    attacking = true
    
    if targetAngle < 8 and targetAngle > 0 then --Why does angle change depending on distance?
        closestTarget.Humanoid:TakeDamage(stats.BITE_DAMAGE)
    else
        closestTarget.Humanoid:TakeDamage(stats.SLASH_DAMAGE)
    end

    wait(0.1)
    attacking = false
    AttackHitbox.CanTouch = false
end)

stats.EnterIdleState = function()
    if pauseStateChange then return end
    stats.State = "idle"
    NPCMethods.stopAnimations(animations)
    animations.idle:Play()
    if not sounds.breathing.IsPlaying then sounds.breathing:Play() end
    while stats.State == "idle" and wait(0.001)  do
        local closestPlayer, playerDistance = ProximityMethods.getClosestPlayer(NPC, true)
        local closestVillager, villagerDistance = ProximityMethods.getClosestVillager(NPC, true, true)

        if closestVillager and closestVillager.IsProtected.Value == false and villagerDistance <= stats.FOLLOW_DISTANCE then
            print("i see vilager!")
            stats.EnterChaseState(closestVillager)
        end
        if closestPlayer and playerDistance <= stats.FOLLOW_DISTANCE then
            print("i see player!")
            stats.EnterChaseState(closestPlayer)
        end
    end
end

stats.EnterChaseState = function(target)
    if pauseStateChange then return end
    stats.State = "chase"
    NPCMethods.stopAnimations(animations)
    animations.chase:Play()
    humanoid.WalkSpeed = stats.CHASE_SPEED
    while stats.State == "chase" and wait(0.001) and target.Humanoid.Health > 0 and humanoid.Health > 0 do
        if ProximityMethods.getTargetDistance(target, NPC, false) <= stats.STALK_DISTANCE then
            if target.Name == "Villager" then stats.EnterLungeState(target)
            else stats.EnterStalkState(target) end
        end

        NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
        stats.FollowPart.CFrame = target.HumanoidRootPart.CFrame
        humanoid:MoveTo(stats.FollowPart.Position)
    end
    stats.EnterIdleState()
end

stats.EnterStalkState = function(target)
    if pauseStateChange then return end
    stats.State = "stalk"
    NPCMethods.stopAnimations(animations)
    humanoid.WalkSpeed = stats.CHASE_SPEED

    local maxDistance = stats.STALK_DISTANCE - math.random(1, 8)
    local HRP = target.HumanoidRootPart
    stats.FollowPart.Parent = workspace

    local currentAngle = 0
    local secsToRedirect = math.random(1, 5)
    local redirectCount = 0
    local rotationSpeed = humanoid.WalkSpeed * 0.1
    local direction = math.round(math.random(0, 1))
    local canAttack = false
    animations.strafeLeft:Play()

    while stats.State == "stalk" and wait(0.001) and target.Humanoid.Health > 0 and humanoid.Health > 0 do
        if pauseStateChange then return end
        local closestCharacter, closestDistance, closestAngle = ProximityMethods.getClosestPlayer(NPC, false)
        if not closestCharacter then break end
        if direction == 1 then
            if animations.strafeLeft.IsPlaying then animations.strafeRight:Play() animations.strafeLeft:Stop() end
        else
            if animations.strafeRight.IsPlaying then animations.strafeLeft:Play() animations.strafeRight:Stop() end
        end

        -- If the target attacks prematurely, begin counterattack.
        if target.Assets.Status.Value == "attacking" then stats.EnterCounterState(target, closestAngle) return end

        -- If facing the target's back, auto attack them. 
        if closestAngle > 10 then stats.EnterLungeState(target) return end

        -- If the target goes out of stalking range, chase them.
        if closestDistance > stats.STALK_DISTANCE then stats.EnterChaseState(target) return end

        if canAttack and math.random(0, 1000) <= stats.ATTACK_CHANCE then stats.EnterLungeState(target) return end --randomly lunge
        if canAttack and math.random(0, 1000) <= stats.ATTACK_CHANCE * 2 then stats.EnterFakeLungeState(target) return end --randomly fake lunge

        --Change FollowPart's CFrame to (maxDistance) amount away from the player, and at (currentAngle) of them.
        stats.FollowPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(currentAngle),0)*CFrame.new(0, 0, maxDistance)

        if redirectCount >= secsToRedirect then -- If enough time has passed while stalking, change directions.
            rotationSpeed = 0 - rotationSpeed
            redirectCount = 0
            secsToRedirect = math.random(1, 5) -- set a new time to change directions
            direction = 0 - direction
        end
        if redirectCount > 2 then canAttack = true end -- If enough time has passed, start rolling to randomly attack.
        currentAngle = currentAngle + rotationSpeed

        NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
        humanoid:MoveTo(stats.FollowPart.Position)
        redirectCount = redirectCount + 0.05
    end
    stats.EnterIdleState()
end

stats.EnterCounterState = function(target, closestAngle)
    if pauseStateChange then return end
    stats.State = "counter"
    NPCMethods.stopAnimations(animations)

    stats.FollowPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)
    NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
    animations.dodge:Play()
    humanoid:MoveTo(stats.FollowPart.Position)
    wait(0.3)
    animations.dodge:Stop()
    if stats.State ~= "counter" then return end
    stats.EnterLungeState(target)
end

stats.EnterLungeState = function(target)
    if pauseStateChange then return end
    stats.State = "lunge"
    NPCMethods.stopAnimations(animations)

    NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
    humanoid.WalkSpeed = stats.LUNGE_SPEED

    sounds.lungeBegin.TimePosition = 0.2
    sounds.lungeBegin:Play()
    animations.lungeBegin:Play()
    wait(0.7)
    sounds.lungeBegin:Stop()
    sounds.lunge.TimePosition = 0.2
    sounds.lunge:Play()
    stats.FollowPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (stats.STALK_DISTANCE + 50))
    humanoid:MoveTo(stats.FollowPart.Position)
    animations.lungeBegin:Stop()
    animations.lunge:Play()

    AttackHitbox.CanTouch = true
    wait(1)
    humanoid.WalkSpeed = 0
    AttackHitbox.CanTouch = false
    animations.lunge:Stop()
    sounds.lunge:Stop()
    animations.idle:Play()
    wait(1.5)
    stats.EnterIdleState()
end

stats.EnterFakeLungeState = function(target)
    if pauseStateChange then return end
    stats.State = "fakelunge"
    humanoid.WalkSpeed = stats.CHASE_SPEED
    NPCMethods.stopAnimations(animations)

    NPCMethods.orientNPC(NPC, target.HumanoidRootPart.Position)
    stats.FollowPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (4))
    humanoid:MoveTo(stats.FollowPart.Position)
    animations.chase:Play()

    wait(0.2)
    humanoid.WalkSpeed = 0
    animations.lunge:Stop()
    stats.EnterIdleState()
end

stats.EnterDeadState = function()
    --ignores pauseStateChange
    stats.State = "dead"
    NPCMethods.stopAnimations(animations)
    pauseStateChange = true

    AttackHitbox.CanTouch = false
    NPC.Hips.DeathParticles.Enabled = true
    sounds.taunt:Play()
    sounds.taunt.Ended:Wait()
    if FollowPart then FollowPart:Destroy() end
    NPC:Destroy()
end

stats.EnterHitState = function()
    --ignores pauseStateChange
    stats.State = "hit"
    NPCMethods.stopAnimations(animations)
    pauseStateChange = true
    
    AttackHitbox.CanTouch = false
    animations.hit:Play()
    wait(1.5)
    pauseStateChange = false
    stats.EnterIdleState()
end

humanoid.Died:Connect(stats.EnterDeadState)
humanoid.HealthChanged:Connect(stats.EnterHitState) --TODO Only enter hit state when damage has been taken.

stats.EnterIdleState()