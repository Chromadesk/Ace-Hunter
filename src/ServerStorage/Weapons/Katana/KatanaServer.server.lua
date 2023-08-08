--CLIENT SCRIPT
local tool = script.Parent
local AttackHitbox = tool:WaitForChild("AttackHitbox")
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false

local character = nil
local damage = nil

local sounds = {}
sounds.slash = tool.Handle.Slash
sounds.hitsound = tool.Handle.Hitsound

local function registerHit(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(character) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(damage)
		sounds.hitsound:Play()
		AttackHitbox.CanTouch = false
	end
end

AttackHitbox.touched:Connect(registerHit)

local attacks = {}
attacks.frontAttack = function(aDamage, aCharacter)
    damage = aDamage
    character = aCharacter
    character.Assets.Status.Value = "attacking"
	wait(0.3)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.3)
	AttackHitbox.CanTouch = false
    character.Assets.Status.Value = "standby"
end

attacks.backAttack = function(aDamage, aCharacter)
    damage = aDamage * 2
    character = aCharacter
    character.Assets.Status.Value = "attacking"
	character.Assets.DisableRotation.Value = true
	wait(0.1)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.6)
	AttackHitbox.CanTouch = false
	character.Assets.DisableRotation.Value = false
    character.Assets.Status.Value = "standby"
end

attacks.downAttack = function(aDamage, aCharacter)
    damage = aDamage * 1.3
    character = aCharacter
    character.Assets.Status.Value = "attacking"
	character.Assets.DisableRotation.Value = true
	wait(0.3)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.15)
	AttackHitbox.CanTouch = false
	character.Assets.DisableRotation.Value = false
    character.Assets.Status.Value = "standby"
end

local function doAttack(player, aDamage, aCharacter, attackName)
	attacks[attackName](aDamage, aCharacter)
end

ActivateRE.OnServerEvent:Connect(doAttack)