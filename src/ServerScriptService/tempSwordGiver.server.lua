local Players = game:GetService("Players")

local katana = game:GetService("ServerStorage").Weapons.Katana:Clone()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    katana.Parent = workspace
    katana.Parent = player.Character
end)