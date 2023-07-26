local ServerStorage = game:GetService("ServerStorage")
local Spawner = script.Parent
local NPC = ServerStorage.AiEnemies[Spawner.SpawnTarget.Value]

function activateSpawn()
    if not Spawner.IsActive.Value then return end

    local copyNPC = NPC:Clone() --Grab the SpawnTarget NPC and give them the Spawner's ID
    local copyId = Spawner.Id:Clone()
    copyId.Parent = copyNPC
    copyNPC.Parent = workspace.NPCs --Spawn in the now ID'd SpawnTarget NPC
    copyNPC:MoveTo(Spawner.Position)

    wait(Spawner.SpawnRate.Value) --Wait however many seconds SpawnRate says until trying to spawn an NPC again
    activateSpawn()
end

activateSpawn()