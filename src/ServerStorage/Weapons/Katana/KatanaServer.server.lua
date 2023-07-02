--CLIENT SCRIPT
local tool = script.Parent
local AttackHitbox = tool:WaitForChild("AttackHitbox")
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false

local user = nil
local damage = nil

local sounds = {}
sounds.slash = tool.Handle.Slash
sounds.hitsound = tool.Handle.Hitsound

AttackHitbox.touched:Connect(function(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(damage)
		sounds.hitsound:Play()
		AttackHitbox.CanTouch = false
	end
end)

local attacks = {}
attacks.frontAttack = function(aDamage, aUser)
    damage = aDamage
    user = aUser
    user.Assets.Status.Value = "attacking"
	wait(0.3)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.3)
	AttackHitbox.CanTouch = false
    user.Assets.Status.Value = "standby"
end

attacks.backAttack = function(aDamage, aUser)
    damage = aDamage * 2
    user = aUser
    user.Assets.Status.Value = "attacking"
	wait(0.1)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.6)
	AttackHitbox.CanTouch = false
    user.Assets.Status.Value = "standby"
end

local function doAttack(player, aDamage, aUser, attackName)
	attacks[attackName](aDamage, aUser)
end

ActivateRE.OnServerEvent:Connect(doAttack)