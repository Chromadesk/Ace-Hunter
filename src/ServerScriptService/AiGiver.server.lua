local AiResources = game:GetService("ServerStorage").AiResources

local function extractFolder(folder, reciever)
        for _,v in pairs(folder:GetChildren()) do
                v.Parent = reciever
        end
end

local function processNPC(NPC)
        local npcResources = AiResources[NPC.Name] --Grab the aiResources for this particular NPC
        local NPCScript = npcResources.AiScript:Clone()
        local Animations = npcResources.Animations:Clone()
        
        NPCScript.Parent = NPC
        Animations.Parent = NPC
        if npcResources:FindFirstChild("DeathParticles") then --Not all NPCs have DeathParticles, so only apply for the ones that do
                local DeathParticles = npcResources.DeathParticles:Clone()
                DeathParticles.Parent = NPC.Hips
        end
        if npcResources:FindFirstChild("InteractionRE") then --Not all NPCs have an Interaction RE, so only apply for the ones that do
                local InteractionRE = npcResources.InteractionRE:Clone()
                InteractionRE.Parent = NPC
        end
        extractFolder(npcResources.Sounds:Clone(), NPC.HumanoidRootPart) --Done to make sounds actually play from the HRT
end

for _,v in pairs(workspace.NPCs:GetChildren()) do
        warn("NPCs already in map: Use spawners instead.")
        processNPC(v)
end

workspace.NPCs.ChildAdded:Connect(processNPC)