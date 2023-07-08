local ServerStorage = game:GetService("ServerStorage")
local Spawner = script.Parent
local NPC = ServerStorage.AiEnemies[Spawner.NPCName]

function activateSpawn()
    if not Spawner.IsActive.Value then return end
    local copyNPC = NPC:Clone()
    local copyId = Spawner.Id:Clone()
    copyId.Parent = copyNPC
    copyNPC.Parent = workspace.NPCs
    copyNPC:MoveTo(Spawner.Position)

    wait(spawn.SpawnRate.Value)
    activateSpawn()
end
