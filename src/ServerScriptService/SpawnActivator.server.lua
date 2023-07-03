local ServerStorage = game:GetService("ServerStorage")
wait(0.1) -- wait so AiGiver can run first

function activateSpawn(spawn, NPC)
    if not spawn.IsActive.Value then return end
    local copyNPC = NPC:Clone()
    copyNPC.Parent = workspace.NPCs
    copyNPC:MoveTo(spawn.Position)

    wait(spawn.SpawnRate.Value)
    activateSpawn(spawn, NPC)
end

function initializeSpawn(part, NPCName)
    if part.Name == NPCName .."Spawner" and part.IsActive.Value then
        part.Transparency = 1

        activateSpawn(part, ServerStorage.AiEnemies[NPCName])
    end
end

for _,v in pairs(workspace:GetChildren()) do
    initializeSpawn(v, "Vampire")
end