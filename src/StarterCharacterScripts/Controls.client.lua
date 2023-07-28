local Player = game:GetService("Players").LocalPlayer
local Character = script.Parent
local UserInputService = game:GetService("UserInputService")
local pauseInput = false

UserInputService.InputBegan:Connect(function(input, eventProcessed)
	if eventProcessed or pauseInput or user.Humanoid.Health <= 0 then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		pauseInput = true
		stats.doAttack("frontAttack")
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		pauseInput = true
		stats.doAttack("backAttack")
	end
end)