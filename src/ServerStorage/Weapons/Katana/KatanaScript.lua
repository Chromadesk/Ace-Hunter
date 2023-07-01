--CLIENT SCRIPT
local tool = script.Parent
local AttackHitbox = tool:WaitForChild("AttackHitbox")
local UserInputService = game:GetService("UserInputService")
local user = nil
local pauseInput = false

local animations = {}
animations.setAnimations = function()
	animations.frontAttack = user.humanoid:LoadAnimation(tool.Animations["Front Attack"])
end

local sounds = {}
sounds.slash = tool.Handle.Slash
sounds.hitsound = tool.Handle.Hitsound

local stats = {}
stats.DAMAGE = 40
stats.originalUserSpeed = 0

AttackHitbox.touched:Connect(function(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(stats.DAMAGE)
		sounds.hitsound:Play()
	end

	AttackHitbox.CanTouch = false
end)

stats.doFrontAttack = function()
	user.WalkSpeed = 5
	animations.frontAttack:Play()
	wait(0.5)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.3)
	AttackHitbox.CanTouch = false
	animations.frontAttack.Ended:Wait()
	user.WalkSpeed = stats.originalUserSpeed
	pauseInput = false
end

tool.Changed("Parent"):Connect(function()
    if not tool.Parent:FindFirstChild("HumanoidRootPart") then tool.Changed("Parent"):Wait() end
    user = tool.Parent
	animations.setAnimations()
	stats.originalUserSpeed = user.WalkSpeed
end)

UserInputService.InputBegan:Connect(function(input, eventProcessed)
	if eventProcessed or pauseInput or character.Humanoid.Health <= 0 then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		pauseInput = true
		stats.doFrontAttack()
	end
end)