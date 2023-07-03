--CLIENT SCRIPT
local tool = script.Parent
local StabHitbox = tool:WaitForChild("StabHitbox")
local SlashHitbox = tool:WaitForChild("SlashHitbox")
local UserInputService = game:GetService("UserInputService")
local ActivateRE = tool:WaitForChild("ActivateRE")
local pauseInput = false

local user = nil
local damage = nil

local sounds = {}
sounds.slash = tool.Handle.Slash
sounds.hitsound = tool.Handle.Hitsound

local function registerHit(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(damage)
		sounds.hitsound:Play()
		SlashHitbox.CanTouch = false
		StabHitbox.CanTouch = false
	end
end

SlashHitbox.touched:Connect(registerHit)
StabHitbox.touched:Connect(registerHit)

local attacks = {}
attacks.frontAttack = function(aDamage, aUser)
    damage = aDamage
    user = aUser
    user.Assets.Status.Value = "attacking"
	wait(0.3)
	SlashHitbox.CanTouch = true
	SlashHitbox.Transparency = 0
	sounds.slash:Play()
	wait(0.3)
	SlashHitbox.CanTouch = false
	SlashHitbox.Transparency = 1
    user.Assets.Status.Value = "standby"
end

attacks.backAttack = function(aDamage, aUser)
    damage = aDamage * 2
    user = aUser
    user.Assets.Status.Value = "attacking"
	user.Assets.DisableRotation.Value = true
	wait(0.1)
	StabHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.6)
	StabHitbox.CanTouch = false
	user.Assets.DisableRotation.Value = false
    user.Assets.Status.Value = "standby"
end

attacks.downAttack = function(aDamage, aUser)
    damage = aDamage * 1.3
    user = aUser
    user.Assets.Status.Value = "attacking"
	user.Assets.DisableRotation.Value = true
	wait(0.3)
	StabHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.15)
	StabHitbox.CanTouch = false
	user.Assets.DisableRotation.Value = false
    user.Assets.Status.Value = "standby"
end

local function doAttack(player, aDamage, aUser, attackName)
	attacks[attackName](aDamage, aUser)
end

ActivateRE.OnServerEvent:Connect(doAttack)