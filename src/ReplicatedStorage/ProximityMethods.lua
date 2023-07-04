local ProximityMethods = {}

--https://web.archive.org/web/20171120072253/http://wiki.roblox.com/index.php?title=Top_Down_Action/PiBot

--If visible is true, will only return value if there are no obstructions between origin and target.
ProximityMethods.getTargetDistance = function(target, origin, visible)
	if not target then return nil end
	local toTarget = target.Head.Position - origin.Head.Position -- Target must have a part named "Head"
	local toTargetRay = Ray.new(origin.Head.Position, toTarget)
	local part = game.Workspace:FindPartOnRay(toTargetRay, origin, false, false)
    if not visible then return toTarget.magnitude end
	if part and part:IsDescendantOf(target) or part and part:IsDescendantOf(origin) then
		print(toTarget.magnitude)
		return toTarget.magnitude
	end
	return nil
end

ProximityMethods.getClosestCharacter = function(origin, visible)
	local closestDistance = math.huge
	local closestCharacter = nil
    local closestAngle = nil
	
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character.Humanoid.Health <= 0 then break end
		local distance = ProximityMethods.getTargetDistance(player.Character, origin, visible)
		if distance and distance < closestDistance then
			closestDistance = distance
			closestCharacter = player.Character
            closestAngle = (player.Character.ChestUpper.CFrame:inverse() * origin.HumanoidRootPart.CFrame).Z
		end
	end
	return closestCharacter, closestDistance, closestAngle
end

ProximityMethods.getClosestLightsource = function(origin, visible)
	local closestDistance = math.huge
	local closestLightsource = nil

	for _,lightsource in pairs(workspace.Lightsources:GetChildren()) do
		local distance = ProximityMethods.getTargetDistance(lightsource, origin, visible)
		if distance and distance < closestDistance then
			closestDistance = distance
			closestLightsource = lightsource
		end
	end
	return closestLightsource, closestDistance
end

return ProximityMethods