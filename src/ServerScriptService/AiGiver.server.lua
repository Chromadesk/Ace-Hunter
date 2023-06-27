local AiScriptStorage = game:GetService("ServerStorage").AiScripts

for _,v in pairs(workspace.NPCs:GetChildren()) do
        local i = AiScriptStorage.AiScriptVampire:Clone()
        i.Parent = v
end

-- TODO: Add later
-- workspace.NPCs.ChildAdded:Connect(function()
--     for _,v in pairs(workspace.NPCs:GetChildren()) do
--         local i = AiScripts.AiScriptVampire:Clone()
--         i.Parent = v
--     end
-- end)