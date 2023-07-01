local user = script.Parent

local defaultMoveAnim = user.Humanoid:LoadAnimation(user.Assets.Move)
local defaultIdleAnim = user.Humanoid:LoadAnimation(user.Assets.Idle)

local moveAnim = defaultMoveAnim
local idleAnim = defaultIdleAnim

user.Assets.Move.Changed:Connect(function()
    if not user.Assets.Move.AnimationId then moveAnim = defaultMoveAnim return end
    moveAnim = user.Humanoid:LoadAnimation(user.Assets.Move)
end)

user.Assets.Idle.Changed:Connect(function()
    if not user.Assets.Idle.AnimationId then idleAnim = defaultIdleAnim return end
    idleAnim = user.Humanoid:LoadAnimation(user.Assets.Idle)
end)

user.Humanoid.Running:Connect(function(movementSpeed)
	if movementSpeed > 0 then
		if not moveAnim.IsPlaying then
			idleAnim:Stop()
			moveAnim:Play()
		end
	else
		if moveAnim.IsPlaying then
			moveAnim:Stop()
			idleAnim:Play()
		end
	end
end)