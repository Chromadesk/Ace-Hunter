local NPC = script.parent
local humanoid = NPC.Humanoid
local AttackHitbox = NPC:WaitForChild("AttackHitbox")

local Anims = NPC:WaitForChild("Animations")
local animations = {
    strafeRight = humanoid:LoadAnimation(Anims:WaitForChild("Strafe Right")),
    strafeLeft = humanoid:LoadAnimation(Anims:WaitForChild("Strafe Left")),
    lunge = humanoid:LoadAnimation(Anims:WaitForChild("Chase Alt")),
    chase = humanoid:LoadAnimation(Anims:WaitForChild("Chase")),
    idle = humanoid:LoadAnimation(Anims:WaitForChild("Idle"))
}

local sounds = {
    breathing = NPC.HumanoidRootPart:WaitForChild("Breathing"),
    lunge = NPC.HumanoidRootPart:WaitForChild("Lunge"),
    taunt = NPC.HumanoidRootPart:WaitForChild("Taunt")
}

--https://web.archive.org/web/20171120072253/http://wiki.roblox.com/index.php?title=Top_Down_Action/PiBot
local function getTargetDistance(targetCharacter)
	if not targetCharacter or targetCharacter.Humanoid.Health <= 0 then return nil end
	local toPlayer = targetCharacter.Head.Position - NPC.Head.Position
	local toPlayerRay = Ray.new(NPC.Head.Position, toPlayer)
	local part = game.Workspace:FindPartOnRay(toPlayerRay, NPC, false, false)
	if part and part:IsDescendantOf(targetCharacter) or part:IsDescendantOf(NPC) then
		return toPlayer.magnitude
	end
	return nil
end

local function getClosestVisibleCharacter()
	local closestDistance = math.huge
	local closestCharacter = nil
    local closestAngle = nil
	for _, player in pairs(game.Players:GetPlayers()) do
		local distance = getTargetDistance(player.Character)
		if distance and distance < closestDistance then
			closestDistance = distance
			closestCharacter = player.Character
            closestAngle = (player.Character.HumanoidRootPart.CFrame:inverse() * NPC.HumanoidRootPart.CFrame).Z
		end
	end
	return closestCharacter, closestDistance, closestAngle
end

local stats = {}
stats.FOLLOW_DISTANCE = 50
stats.STALK_DISTANCE = 20
stats.CHASE_SPEED = 25
stats.LUNGE_SPEED = 40
stats.SLASH_DAMAGE = 50
stats.BITE_DAMAGE = 999
stats.ATTACK_CHANCE = 2 -- Out of 1000
stats.State = "idle"
stats.FollowPart = Instance.new("Part")
    stats.FollowPart.Anchored = true
    stats.FollowPart.CanCollide = false
    stats.FollowPart.Transparency = 1
    stats.FollowPart.Name = "FollowPart"

local attacking = false
AttackHitbox.touched:Connect(function(toucher)
    local closestCharacter, _, closestAngle = getClosestVisibleCharacter()
    if not closestCharacter then return end
    if attacking or not toucher:IsDescendantOf(closestCharacter) then return end
    attacking = true
    
    if closestAngle < 7 and closestAngle > 3 then --i dont know why the angle changes depending on distance
        closestCharacter.Humanoid:TakeDamage(stats.BITE_DAMAGE)
    else
        closestCharacter.Humanoid:TakeDamage(stats.SLASH_DAMAGE)
    end

    wait(0.1)
    attacking = false
    AttackHitbox.CanTouch = false
end)

stats.EnterIdleState = function()
    stats.State = "idle"
    stats.StopAnimations()
    animations.idle:Play()
    if not sounds.breathing.IsPlaying then sounds.breathing:Play() end
    while stats.State == "idle" and wait(0.001)  do
        local closestCharacter, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.FOLLOW_DISTANCE then
            stats.EnterChaseState(closestCharacter)
        end
    end
end

--TODO Use tween service for this to make smoother.
local function orientNPC(position)
	local HRP = NPC.HumanoidRootPart
    HRP.CFrame = CFrame.new(HRP.CFrame.Position, Vector3.new(position.X, HRP.CFrame.Position.Y, position.Z))
end

stats.EnterChaseState = function(target)
    stats.State = "chase"
    stats.StopAnimations()
    animations.chase:Play()
    humanoid.WalkSpeed = stats.CHASE_SPEED
    while stats.State == "chase" and wait(0.001) and target.Humanoid.Health > 0 and humanoid.Health > 0 do
        orientNPC(target.HumanoidRootPart.Position)
        stats.FollowPart.CFrame = target.HumanoidRootPart.CFrame
        humanoid:MoveTo(stats.FollowPart.Position)

        local closestCharacter, closestDistance = getClosestVisibleCharacter()
        if not closestCharacter then break end
        if closestDistance <= stats.STALK_DISTANCE then
            stats.EnterStalkState(target)
        end
    end
    stats.State = "idle"
end

stats.StopAnimations = function()
    for _,v in pairs(animations) do
        v:Stop()
    end
end

stats.EnterStalkState = function(target)
    stats.State = "stalk"
    stats.StopAnimations()
    humanoid.WalkSpeed = stats.CHASE_SPEED

    local maxDistance = stats.STALK_DISTANCE - math.random(1, 8)
    local HRP = target.HumanoidRootPart
    stats.FollowPart.Parent = workspace

    local currentAngle = 0
    local secsToRedirect = math.random(1, 5)
    local redirectCount = 0
    local rotationSpeed = humanoid.WalkSpeed * 0.1
    local direction = 1
    animations.strafeLeft:Play()

    while stats.State == "stalk" and wait(0.001) and target.Humanoid.Health > 0 and humanoid.Health > 0 do
        local closestCharacter, closestDistance, closestAngle = getClosestVisibleCharacter()
        if not closestCharacter then break end
        if direction == 1 then
            if animations.strafeLeft.IsPlaying then animations.strafeRight:Play() animations.strafeLeft:Stop() end
        else
            if animations.strafeRight.IsPlaying then animations.strafeLeft:Play() animations.strafeRight:Stop() end
        end
        if closestAngle > 10 then -- If facing the target's back, auto attack them.
            stats.EnterLungeState(target)
            return
        end
        if closestDistance > stats.STALK_DISTANCE then -- If the target goes out of stalking range, chase them.
            stats.EnterChaseState(target)
            return
        end
        if math.random(0, 1000) <= stats.ATTACK_CHANCE then stats.EnterLungeState(target) return end --randomly lunge
        if math.random(0, 1000) <= stats.ATTACK_CHANCE * 2 then stats.EnterFakeLungeState(target) return end --randomly fake lunge

        stats.FollowPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(currentAngle),0)*CFrame.new(0, 0, maxDistance)

        if redirectCount >= secsToRedirect then -- If enough time has passed while stalking, change directions.
            rotationSpeed = 0 - rotationSpeed
            redirectCount = 0
            secsToRedirect = math.random(1, 5) -- set a new time to change directions
            direction = 0 - direction
        end
        currentAngle = currentAngle + rotationSpeed

        orientNPC(target.HumanoidRootPart.Position)
        humanoid:MoveTo(stats.FollowPart.Position)
        redirectCount = redirectCount + 0.05
    end
    stats.State = "idle"
end

stats.EnterLungeState = function(target)
    stats.State = "lunge"
    stats.StopAnimations()

    orientNPC(target.HumanoidRootPart.Position)
    humanoid.WalkSpeed = stats.LUNGE_SPEED

    stats.FollowPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (stats.STALK_DISTANCE + 50))
    humanoid:MoveTo(stats.FollowPart.Position)
    animations.lunge:Play()
    sounds.lunge.TimePosition = 0.2
    sounds.lunge:Play()

    AttackHitbox.CanTouch = true
    wait(1)
    humanoid.WalkSpeed = 0
    AttackHitbox.CanTouch = false
    animations.lunge:Stop()
    sounds.lunge:Stop()
    animations.idle:Play()
    wait(1.5)
    stats.State = "idle"
end

stats.EnterFakeLungeState = function(target)
    stats.State = "fakelunge"
    humanoid.WalkSpeed = stats.CHASE_SPEED
    stats.StopAnimations()

    orientNPC(target.HumanoidRootPart.Position)
    stats.FollowPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (4))
    humanoid:MoveTo(stats.FollowPart.Position)
    animations.chase:Play()

    wait(0.2)
    humanoid.WalkSpeed = 0
    animations.lunge:Stop()
    stats.State = "idle"
end

stats.EnterDeadState = function()
    stats.State = "dead"
    stats.StopAnimations()
    AttackHitbox.CanTouch = false
    NPC.Hips.DeathParticles.Enabled = true
    sounds.taunt:Play()
    sounds.taunt.Ended:Wait()
    NPC:Destroy()
end

humanoid.Died:Connect(stats.EnterDeadState)

stats.EnterIdleState()