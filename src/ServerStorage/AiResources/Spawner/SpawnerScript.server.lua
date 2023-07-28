local ServerStorage = game:GetService("ServerStorage")
local Spawner = script.Parent
local NPC = ServerStorage.AiCharacters[Spawner.SpawnTarget.Value]

--Id: The unique ID number of the spawner.
--IsActive: Whether or not the spawner is allowed to spawn NPCs
--SpawnRate: How much time delay between spawning NPCs
--SpawnTarget: The name of the NPC to spawn
--MaxSpawns: The maximum amount of NPCs this spawner can spawn

local function getSpawnedCount()
    local count = 0
    for _,NPC in pairs(workspace.NPCs:GetChildren()) do
        if NPC.Id.Value == Spawner.Id.Value then count = count + 1 end
    end
    return count
end

local function activateSpawn()
    if Spawner.IsActive.Value and getSpawnedCount() < Spawner.MaxSpawns.Value then
        local copyNPC = NPC:Clone() --Grab the SpawnTarget NPC and give them the Spawner's ID
        local copyId = Spawner.Id:Clone()
        copyId.Parent = copyNPC
        copyNPC.Parent = workspace.NPCs --Spawn in the now ID'd SpawnTarget NPC
        copyNPC:MoveTo(Spawner.Position)
    end

    wait(Spawner.SpawnRate.Value) --Wait however many seconds SpawnRate says until trying to spawn an NPC again
    activateSpawn()
end

activateSpawn()