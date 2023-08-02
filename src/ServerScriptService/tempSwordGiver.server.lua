local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local katana = game:GetService("ServerStorage").Weapons.Katana:Clone()
        wait(0.1)
        katana.Name = "Weapon"
        katana.Parent = workspace
        katana.Parent = character
    end)  
end)