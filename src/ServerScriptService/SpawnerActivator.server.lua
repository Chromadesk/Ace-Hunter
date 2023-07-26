local AiResources = game:GetService("ServerStorage").AiResources
local nextId = 0

for _,spawn in pairs(workspace:GetChildren()) do
    if spawn.Name == "Spawner" then
        spawn.Transparency = 1

        local id = Instance.new("NumberValue") --Create an ID for the spawner that is given to all of its spawned NPCs
        id.Name = "Id"
        id.Value = nextId
        nextId = nextId + 1
        id.Parent = spawn

        local spawnerScript = AiResources.Spawner.SpawnerScript:Clone() --Give spawner the SpawnerScript
        spawnerScript.Parent = spawn
    end
end