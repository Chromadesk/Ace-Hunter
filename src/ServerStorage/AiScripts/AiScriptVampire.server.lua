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
	for _, player in pairs(game.Players:GetPlayers()) do
		local distance = getTargetDistance(player.Character)
		if distance and distance < closestDistance then
			closestDistance = distance
			closestCharacter = player.Character
		end
	end
	return closestCharacter, closestDistance
end

local stats = {}
stats.FollowDistance = 50
stats.StalkDistance = 20
stats.State = "idle"

local function manageStateChange()
    local closestCharacter, closestDistance = getClosestVisibleCharacter()
    local offset = stats.StalkDistance
    if closestDistance <= stats.StalkDistance and stats.State ~= "stalk" then
        stats.EnterStalkState(closestCharacter)
        return
    end
    if closestDistance <= stats.FollowDistance and closestDistance > stats.StalkDistance and stats.State ~= "chase" then
        stats.EnterChaseState(closestCharacter)
        return
    end
    if stats.State ~= "idle" then
        stats.EnterIdleState()
    end
end

stats.EnterIdleState = function()
    stats.State = "idle"
    while stats.State == "idle" and wait(0.001)  do
        manageStateChange()
    end
end

local isOrienting = false
local function orientNPC(target)
    isOrienting = true
	local HRP = vampire.HumanoidRootPart
	local targetHRP = target.HumanoidRootPart
	HRP.CFrame = CFrame.lookAt(HRP.CFrame.Position, Vector3.new(targetHRP.Position.X, HRP.CFrame.Position.Y, targetHRP.Position.Z))

    local orientEvent = targetHRP.Changed:Connect(function()
        if stats.State == "idle" then
            isOrienting = false
            orientEvent:Disconnect()
        end
        orientNPC(target)
    end)
end

stats.EnterChaseState = function(target)
    stats.State = "chase"
    if not isOrienting then orientNPC(target) end
    while stats.State == "chase" and wait(0.001) and target.Humanoid.Health > 0 do
        manageStateChange()
        humanoid:MoveTo(target.HumanoidRootPart.Position)
    end
end

stats.EnterStalkState = function(target)
    stats.State = "stalk"
    if not isOrienting then orientNPC(target) end
    local HRP = target.HumanoidRootPart
    local followPart = Instance.new("Part")
    followPart.Anchored = true
    followPart.CanCollide = false
    followPart.Transparency = 0.5
    followPart.Name = "FollowPart"
    followPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(0),0)*CFrame.new(0, 0, stats.StalkDistance - 1)
    followPart.Parent = target

    local currentAngle = 0

    while stats.State == "stalk" and wait(0.001) do
        manageStateChange()
        followPart.CFrame = CFrame.new(HRP.Position)*CFrame.Angles(0,math.rad(currentAngle),0)*CFrame.new(0, 0, stats.StalkDistance - 1)
        currentAngle = currentAngle + humanoid.WalkSpeed * 0.1
        humanoid:MoveTo(followPart.Position)
    end

    followPart:Destroy()
end

stats.EnterIdleState()