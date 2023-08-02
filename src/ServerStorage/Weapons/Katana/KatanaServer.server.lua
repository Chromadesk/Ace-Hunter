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

local function registerHit(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(damage)
		sounds.hitsound:Play()
		AttackHitbox.CanTouch = false
	end
end

AttackHitbox.touched:Connect(registerHit)

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
	user.Assets.DisableRotation.Value = true
	wait(0.1)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.6)
	AttackHitbox.CanTouch = false
	user.Assets.DisableRotation.Value = false
    user.Assets.Status.Value = "standby"
end

attacks.downAttack = function(aDamage, aUser)
    damage = aDamage * 1.3
    user = aUser
    user.Assets.Status.Value = "attacking"
	user.Assets.DisableRotation.Value = true
	wait(0.3)
	AttackHitbox.CanTouch = true
	sounds.slash:Play()
	wait(0.15)
	AttackHitbox.CanTouch = false
	user.Assets.DisableRotation.Value = false
    user.Assets.Status.Value = "standby"
end

local function doAttack(player, aDamage, aUser, attackName)
	attacks[attackName](aDamage, aUser)
end

ActivateRE.OnServerEvent:Connect(doAttack)

---------------------------------------------------------------------------

--CLIENT SCRIPT
local parentFolder = script.Parent --The folder the server and client scripts are inside of
local ActivateRE = parentFolder:WaitForChild("ActivateRE")
local user = parentFolder.Parent
local animFolder = parentFolder.Animations
local tool = nil

for i in pairs(user:GetChildren())

local animations = {}
	animations.frontAttack = user.Humanoid:LoadAnimation(animFolder["Front Attack"])
	animations.backAttack = user.Humanoid:LoadAnimation(animFolder["Back Attack"])
	animations.idle = user.Humanoid:LoadAnimation(animFolder["Idle"])
	animations.move = user.Humanoid:LoadAnimation(animFolder["Move"])

local sounds = {}
	sounds.slash = tool.Handle.Slash
	sounds.hitsound = tool.Handle.Hitsound

local stats = {}
stats.originalUserSpeed = user.Humanoid.WalkSpeed

stats.doAttack = function(attackName)
	animations.idle:Stop()
	animations.move:Stop()
	user.Humanoid.WalkSpeed = 3
	ActivateRE:FireServer(stats.DAMAGE, user, attackName)
	animations[attackName]:Play()
	animations[attackName].Ended:Wait()
	animations.idle:Play()
	user.Humanoid.WalkSpeed = stats.originalUserSpeed
	pauseInput = false
end

while not tool.Parent:FindFirstChild("HumanoidRootPart") do
	tool.AncestryChanged:Wait()
end
stats.originalUserSpeed = 
animations.setAnimations()

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