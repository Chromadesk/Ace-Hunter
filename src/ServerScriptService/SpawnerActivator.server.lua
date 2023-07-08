local AiResources = game:GetService("ServerStorage").AiResources
local nextId = 0

for _,spawn in pairs(workspace:GetChildren()) do
    if spawn.Name ~= "Spawner" then return end
    spawn.Transparency = 1

    local id = Instance.new("NumberValue")
    id.Name = "Id"
    id.Value = nextId
    nextId = nextId + 1
    id.Parent = spawn

    local spawnerScript = AiResources.Spawner.SpawnerScript:Clone()
    spawnerScript.Parent = spawn
end