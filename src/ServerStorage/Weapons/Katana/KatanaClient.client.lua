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

	--E: NPC Interaction Key
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == "E" then
		local mouse = game:GetService("Players").LocalPlayer:GetMouse()
		--If too far from NPC, do nothing.
		if (mouse.Hit.Position - character.Head.Position).magnitude > 60 then return end

		if mouse.Target.Parent and mouse.Target.Parent:FindFirstChild("Humanoid") then
			mouse.Target.Parent.InteractionRE:FireServer() return
		end
		--Check if target is an accessory
		if mouse.Target.Parent.Parent and mouse.Target.Parent.Parent:FindFirstChild("Humanoid") then
			mouse.Target.Parent.Parent.InteractionRE:FireServer() return
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