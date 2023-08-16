local NPCMethods = {}
local ProximityMethods = require(game:GetService("ReplicatedStorage").ProximityMethods)

NPCMethods.orientNPC = function(NPC, position)
	local HRP = NPC.HumanoidRootPart
    HRP.CFrame = CFrame.new(HRP.CFrame.Position, Vector3.new(position.X, HRP.CFrame.Position.Y, position.Z))
end

--If the closest player is within max distance, return true. If not, return false.
NPCMethods.isPlayerNear = function(NPC, max)
    local closestCharacter, closestDistance = ProximityMethods.getClosestPlayer(NPC, false)
    if not closestCharacter then return false end
    if closestDistance < max then return true end
    return false
end

NPCMethods.stopAnimations = function(animations)
    for _,v in pairs(animations) do
        v:Stop()
    end
end

return NPCMethods