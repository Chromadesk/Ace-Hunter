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
stats.StalkDistance = 10
stats.State = "idle"

stats.EnterIdleState = function()
    stats.State = "idle"
    while wait(0.1) and stats.State == "idle" do
        local closestCharacter, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.FollowDistance then
            stats.EnterChaseState(closestCharacter)
        end
    end
end

stats.EnterChaseState = function(target)
    stats.State = "chase"
    while wait(0.1) and stats.State == "chase" and target.Humanoid.Health > 0 do
        humanoid:MoveTo(target.HumanoidRootPart.Position)

        local _, closestDistance = getClosestVisibleCharacter()
        if closestDistance <= stats.StalkDistance then
            stats.EnterStalkState(target)
        end
    end
end

stats.EnterStalkState = function(target)
    local HRP = target.HumanoidRootPart
    stats.State = "stalk"
    while wait(0.1) and stats.State == "stalk" and target.Humanoid.Health > 0 do
        local _, closestDistance = getClosestVisibleCharacter()

        if closestDistance <= stats.StalkDistance then
            humanoid:MoveTo(Vector3.new(stats.StalkDistance, 0, stats.StalkDistance / 2) + HRP.Position)
            offset = offset + 1
        else
            stats.EnterChaseState(target)
        end
    end
end

humanoid.Died:Connect(function()
    stats.State = "idle"
end)

stats.EnterIdleState()
