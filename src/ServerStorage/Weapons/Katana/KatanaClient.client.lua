--CLIENT SCRIPT
local tool = script.Parent
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false
local character = nil

local animations = {}
animations.setAnimations = function()
	animations.frontAttack = character.Humanoid:LoadAnimation(tool.Animations["Front Attack"])
	animations.backAttack = character.Humanoid:LoadAnimation(tool.Animations["Back Attack"])
	animations.idle = character.Humanoid:LoadAnimation(tool.Animations["Idle"])
	animations.move = character.Humanoid:LoadAnimation(tool.Animations["Move"])
end

local stats = {}
stats.DAMAGE = 60
stats.originalUserSpeed = 0

stats.doAttack = function(attackName)
	animations.idle:Stop()
	animations.move:Stop()
	character.Humanoid.WalkSpeed = 3
	ActivateRE:FireServer(stats.DAMAGE, character, attackName)
	animations[attackName]:Play()
	animations[attackName].Ended:Wait()
	animations.idle:Play()
	character.Humanoid.WalkSpeed = stats.originalUserSpeed
	pauseInput = false
end

while not tool.Parent:FindFirstChild("HumanoidRootPart") do
	tool.AncestryChanged:Wait()
end
character = tool.Parent
stats.originalUserSpeed = character.Humanoid.WalkSpeed
animations.setAnimations()

UserInputService.InputBegan:Connect(function(input, eventProcessed)
	if eventProcessed or pauseInput or character.Humanoid.Health <= 0 then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		pauseInput = true
		stats.doAttack("frontAttack")
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		pauseInput = true
		stats.doAttack("backAttack")
	end

	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == "E" then
		local mouseTarget = game:GetService("Players").LocalPlayer:GetMouse().Target
		if mouseTarget.Parent and mouseTarget.Parent:FindFirstChild("InteractionRE") then
			mouseTarget.Parent.InteractionRE:FireServer()
		end
	end
end)

--TODO find a way to put this into the player so all animations run on the Animations script.
character.Humanoid.Running:Connect(function(movementSpeed)
	if animations.frontAttack.isPlaying then return end
	if animations.backAttack.isPlaying then return end
	if movementSpeed > 0 then
		if not animations.move.IsPlaying then
			animations.idle:Stop()
			animations.move:Play()
		end
	else
		if not animations.idle.IsPlaying then
			animations.move:Stop()
			animations.idle:Play()
		end
	end
end)