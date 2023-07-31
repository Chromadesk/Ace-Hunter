local Player = game:GetService("Players").LocalPlayer
local Character = script.Parent
local UserInputService = game:GetService("UserInputService")
local pauseInput = false

local isActiveW = false
local isActiveA = false
local isActiveS = false
local isActiveD = false
local isActiveSpace = false
local lastKeyPressed = nil

local function m1Action()
	
end

UserInputService.InputBegan:Connect(function(input, eventProcessed)
	if eventProcessed or pauseInput or Character.Humanoid.Health <= 0 then return end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode.Name == "W" then isActiveW = true end
		if input.KeyCode.Name == "A" then isActiveA = true  end
		if input.KeyCode.Name == "S" then isActiveS = true  end
		if input.KeyCode.Name == "D" then isActiveD = true end
		if input.KeyCode.Name == "Space" then isActiveSpace = true end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		pauseInput = true
		m1Action()
	end

end)

UserInputService.InputEnded:Connect(function(input, eventProccessed)
	if eventProcessed or pauseInput or Character.Humanoid.Health <= 0 then return end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode.Name == "W" then isActiveW = false lastKeyPressed = "W" end
		if input.KeyCode.Name == "A" then isActiveA = false lastKeyPressed = "A" end
		if input.KeyCode.Name == "S" then isActiveS = false lastKeyPressed = "S" end
		if input.KeyCode.Name == "D" then isActiveD = false lastKeyPressed = "D" end
		if input.KeyCode.Name == "Space" then isActiveSpace = false lastKeyPressed = "Space" end
	end
end)