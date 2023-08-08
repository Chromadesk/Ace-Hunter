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
        local Accessories = npcResources.Accessories:Clone()
        local InteractionRE = Instance.new("RemoteEvent")

        InteractionRE.Name = "InteractionRE"
        InteractionRE.Parent = NPC
        NPCScript.Parent = NPC
        Animations.Parent = NPC
        if npcResources:FindFirstChild("DeathParticles") then --Not all NPCs have DeathParticles, so only apply for the ones that do
                local DeathParticles = npcResources.DeathParticles:Clone()
                DeathParticles.Parent = NPC.Hips
        end
        if npcResources:FindFirstChild("IsProtected") then --Not all NPCs have this bool value, so only apply for the ones that do
                local IsProtected = npcResources.IsProtected:Clone()
                IsProtected.Parent = NPC
        end
        
        extractFolder(npcResources.Sounds:Clone(), NPC.HumanoidRootPart) --Done to make sounds actually play from the HRT
        
        for _,a in pairs(Accessories:GetChildren()) do
                extractFolder(a, NPC)
        end
end

for _,v in pairs(workspace.NPCs:GetChildren()) do
        warn("NPCs already in map: Use spawners instead.")
        processNPC(v)
end

workspace.NPCs.ChildAdded:Connect(processNPC)