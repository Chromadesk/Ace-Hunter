local vampire = script.parent
local humanoid = vampire.Humanoid
local AttackHitbox = vampire:WaitForChild("AttackHitbox")

--https://web.archive.org/web/20171120072253/http://wiki.roblox.com/index.php?title=Top_Down_Action/PiBot
local function getTargetDistance(targetCharacter)
	if not targetCharacter or targetCharacter.Humanoid.Health <= 0 then return nil end
	local toPlayer = targetCharacter.Head.Position - vampire.Head.Position
	local toPlayerRay = Ray.new(vampire.Head.Position, toPlayer)
	local part = game.Workspace:FindPartOnRay(toPlayerRay, vampire, false, false)
	if part and part:IsDescendantOf(targetCharacter) or part:IsDescendantOf(vampire) then
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
            closestAngle = (player.Character.HumanoidRootPart.CFrame:inverse() * vampire.HumanoidRootPart.CFrame).Z
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
stats.ATTACK_CHANCE = 5
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
    while stats.State == "idle" and wait(0.001)  do
        local closestCharacter, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.FOLLOW_DISTANCE then
            stats.EnterChaseState(closestCharacter)
        end
    end
end

local function orientNPC(position)
	local HRP = vampire.HumanoidRootPart
    HRP.CFrame = CFrame.new(HRP.CFrame.Position, Vector3.new(position.X, HRP.CFrame.Position.Y, position.Z))
end

stats.EnterChaseState = function(target)
    stats.State = "chase"
    humanoid.WalkSpeed = stats.CHASE_SPEED
    while stats.State == "chase" and wait(0.001) and target.Humanoid.Health > 0 do
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

stats.EnterStalkState = function(target)
    stats.State = "stalk"
    humanoid.WalkSpeed = stats.CHASE_SPEED

    local maxDistance = stats.STALK_DISTANCE - math.random(1, 8)
    local HRP = target.HumanoidRootPart
    stats.FollowPart.Parent = workspace

    local currentAngle = 0
    local secsToRedirect = math.random(1, 5)
    local redirectCount = 0
    local rotationSpeed = humanoid.WalkSpeed * 0.1

    while stats.State == "stalk" and wait(0.001) do
        local closestCharacter, closestDistance, closestAngle = getClosestVisibleCharacter()
        if not closestCharacter then break end
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
    humanoid.WalkSpeed = stats.LUNGE_SPEED

    orientNPC(target.HumanoidRootPart.Position)
    stats.FollowPart.CFrame = vampire.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (stats.STALK_DISTANCE + 10))
    humanoid:MoveTo(stats.FollowPart.Position)
    AttackHitbox.CanTouch = true
    humanoid.MoveToFinished:Wait()
    stats.State = "idle"
end

stats.EnterFakeLungeState = function(target)
    stats.State = "fakelunge"
    humanoid.WalkSpeed = stats.CHASE_SPEED

    orientNPC(target.HumanoidRootPart.Position)
    stats.FollowPart.CFrame = vampire.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0 - (4))
    humanoid:MoveTo(stats.FollowPart.Position)
    humanoid.MoveToFinished:Wait()
    stats.State = "idle"
end

stats.EnterIdleState()