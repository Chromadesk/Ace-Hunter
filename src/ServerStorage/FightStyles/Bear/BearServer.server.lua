local parentFolder = script.Parent --The folder the server and client scripts are inside of
local ActivateRE = parentFolder:WaitForChild("ActivateRE")
local user = parentFolder.Parent
local animFolder = parentFolder.Animations
local tool = nil

for _,v in pairs(user:GetChildren()) do
    if v:IsA("Accessory") and v:FindFirstChild("AttackHitbox") then tool = v end
end

local animations = {}
	animations.frontAttack = user.Humanoid:LoadAnimation(animFolder["Front Attack"])
	animations.backAttack = user.Humanoid:LoadAnimation(animFolder["Back Attack"])
	animations.idle = user.Humanoid:LoadAnimation(animFolder["Idle"])
	animations.move = user.Humanoid:LoadAnimation(animFolder["Move"])

local sounds = {}
	sounds.attack = tool.Handle.Attack
	sounds.hit = tool.Handle.Hit

local stats = {}
stats.originalUserSpeed = user.Humanoid.WalkSpeed

local function registerHit(toucher)
	if not toucher then return end
	if toucher:IsDescendantOf(user) then return end

	if toucher.Parent and toucher.Parent:FindFirstChild("Humanoid") then
		toucher.Parent.Humanoid:TakeDamage(damage)
		sounds.hitsound:Play()
		AttackHitbox.CanTouch = false
	end
end

local attacks = {}

attacks.frontAttack = function()
	animations.idle:Stop()
	animations.move:Stop()
    --Pre-attack
	user.Humanoid.WalkSpeed = 3
	animations.frontAttack:Play()
    user.Assets.Status.Value = "attacking"
    wait(0.3)
    --During attack
    AttackHitbox.CanTouch = true
	sounds.attack:Play()
    wait(0.3)
    --Post attack
    pauseInput = false
    AttackHitbox.CanTouch = false
    --Returning to starting point
    animations.frontAttack.Ended:Wait()
	animations.idle:Play()
    user.Assets.Status.Value = "standby"
	user.Humanoid.WalkSpeed = stats.originalUserSpeed
end


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