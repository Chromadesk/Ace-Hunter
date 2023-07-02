--CLIENT SCRIPT
local tool = script.Parent
local AttackHitbox = tool:WaitForChild("AttackHitbox")
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false
local user = nil

local animations = {}
animations.setAnimations = function()
	animations.frontAttack = user.Humanoid:LoadAnimation(tool.Animations["Front Attack"])
	animations.backAttack = user.Humanoid:LoadAnimation(tool.Animations["Back Attack"])
	animations.idle = user.Humanoid:LoadAnimation(tool.Animations["Idle"])
	animations.move = user.Humanoid:LoadAnimation(tool.Animations["Move"])
end

local stats = {}
stats.DAMAGE = 60
stats.originalUserSpeed = 0

stats.doAttack = function(attackName)
	user.Humanoid.WalkSpeed = 3
	animations.idle:Stop()
	animations.move:Stop()
	animations[attackName]:Play()
	ActivateRE:FireServer(stats.DAMAGE, user, attackName)
	animations[attackName].Ended:Wait()
	animations.idle:Play()
	user.Humanoid.WalkSpeed = stats.originalUserSpeed
	pauseInput = false
end

while not tool.Parent:FindFirstChild("HumanoidRootPart") do
	tool.AncestryChanged:Wait()
end
user = tool.Parent
stats.originalUserSpeed = user.Humanoid.WalkSpeed
animations.setAnimations()

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

--TODO find a way to put this into the player so all animations run on the Animations script.
user.Humanoid.Running:Connect(function(movementSpeed)
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