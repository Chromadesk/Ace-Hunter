local vampire = script.parent
local humanoid = vampire.Humanoid

--https://web.archive.org/web/20171120072253/http://wiki.roblox.com/index.php?title=Top_Down_Action/PiBot
local function getTargetDistance(targetCharacter)
	if not targetCharacter or targetCharacter.Humanoid.Health <= 0 then return nil end
	local toPlayer = targetCharacter.Head.Position - vampire.Head.Position
	local toPlayerRay = Ray.new(vampire.Head.Position, toPlayer)
	local part = game.Workspace:FindPartOnRay(toPlayerRay, vampire, false, false)
	if part and part:IsDescendantOf(targetCharacter) then
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
stats.FollowDistance = 50
stats.StalkDistance = 20
stats.State = "idle"

stats.EnterIdleState = function()
    stats.State = "idle"
    while stats.State == "idle" and wait(0.001)  do
        local closestCharacter, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.FollowDistance then
            stats.EnterChaseState(closestCharacter)
        end
    end
end

local function orientNPC(target)
	local HRP = vampire.HumanoidRootPart
	local targetHRP = target.HumanoidRootPart
    HRP.CFrame = CFrame.lookAt(HRP.CFrame.Position, Vector3.new(targetHRP.Position.X, HRP.CFrame.Position.Y, targetHRP.Position.Z))
end

stats.EnterChaseState = function(target)
    stats.State = "chase"
    while stats.State == "chase" and wait(0.001) and target.Humanoid.Health > 0 do
        orientNPC(target)
        humanoid:MoveTo(target.HumanoidRootPart.Position)

        local _, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.StalkDistance then
            stats.EnterStalkState(target)
        end
    end
    stats.State = "idle"
end

stats.EnterStalkState = function(target)
    stats.State = "stalk"
    local HRP = target.HumanoidRootPart
    local followPart = Instance.new("Part")
    followPart.Anchored = true
    followPart.CanCollide = false
    followPart.Transparency = 0.5
    followPart.Name = "FollowPart"
    followPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(0),0)*CFrame.new(0, 0, stats.StalkDistance - 1)
    followPart.Parent = workspace

    local currentAngle = 0

    while stats.State == "stalk" and wait(0.001) do
        local _, closestDistance, closestAngle = getClosestVisibleCharacter()
        if closestAngle > 10 then followPart.BrickColor = BrickColor.new("Really red") else followPart.BrickColor = BrickColor.new("White") end
        print(closestAngle)
        if closestDistance > stats.StalkDistance then
            followPart:Destroy()
            stats.EnterChaseState(target)
        end
        
        followPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(currentAngle),0)*CFrame.new(0, 0, stats.StalkDistance - 1)
        currentAngle = currentAngle + humanoid.WalkSpeed * 0.1
        orientNPC(target)
        humanoid:MoveTo(followPart.Position)
    end
    stats.State = "idle"
end

stats.EnterIdleState()