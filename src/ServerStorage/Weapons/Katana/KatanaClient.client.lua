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
	user.Assets.Idle.AnimationId = tool.Animations.Idle.AnimationId
	user.Assets.Move.AnimationId = tool.Animations.Move.AnimationId
end

local stats = {}
stats.DAMAGE = 40
stats.originalUserSpeed = 0

stats.doFrontAttack = function()
	user.Humanoid.WalkSpeed = 3
	animations.frontAttack:Play()
	ActivateRE:FireServer(stats, user)
	animations.frontAttack.Ended:Wait()
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
		stats.doFrontAttack()
	end
end)