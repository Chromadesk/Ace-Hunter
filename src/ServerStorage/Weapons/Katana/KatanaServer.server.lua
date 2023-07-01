--CLIENT SCRIPT
local tool = script.Parent
local AttackHitbox = tool:WaitForChild("AttackHitbox")
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false

local user
local stats

local sounds = {}
sounds.slash = tool.Handle.Slash
sounds.hitsound = tool.Handle.Hitsound

AttackHitbox.touched:Connect(function(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(stats.DAMAGE)
		sounds.hitsound:Play()
	end

	AttackHitbox.CanTouch = false
end)

local function doFrontAttack(aStats, aUser)
    stats = aStats
    user = aUser
	wait(0.5)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.3)
	AttackHitbox.CanTouch = false
end

ActivateRE.OnServerEvent:Connect(doFrontAttack)