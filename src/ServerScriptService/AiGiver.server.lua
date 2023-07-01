local AiResources = game:GetService("ServerStorage").AiResources

local function extractFolder(folder, reciever)
        for _,v in pairs(folder:GetChildren()) do
                v.Parent = reciever
        end
end

local function processVampire(vampireNPC)
        local vampireResources = AiResources.Vampire
        local NPCScript = vampireResources.AiScriptVampire:Clone()
        local Animations = vampireResources.Animations:Clone()
        local DeathParticles = vampireResources.DeathParticles:Clone()
        NPCScript.Parent = vampireNPC
        Animations.Parent = vampireNPC
        DeathParticles.Parent = vampireNPC.Hips
        extractFolder(AiResources.Vampire.Sounds:Clone(), vampireNPC.HumanoidRootPart)
end

for _,v in pairs(workspace.NPCs:GetChildren()) do
        processVampire(v)
end

workspace.NPCs.ChildAdded:Connect(processVampire)