-- local user = script.Parent
-- local UserInputService = game:GetService("UserInputService")
-- local Status = user.Assets.Status

-- local defaultMoveAnim = user.Humanoid:LoadAnimation(user.Assets.Move)
-- local defaultIdleAnim = user.Humanoid:LoadAnimation(user.Assets.Idle)

-- local animations = {
-- 	move = defaultMoveAnim,
-- 	idle = defaultIdleAnim,
-- 	frontAttack = nil
-- }

-- user.Assets.ChildAdded:Connect(function()

-- end)

-- animations.frontAttack.isPlaying:Connect(function()

-- end)

-- user.Humanoid.Running:Connect(function(movementSpeed)
-- 	if animations.frontAttack and animations.frontAttack.isPlaying return end
-- 	if movementSpeed > 0 then
-- 		if not animations.move.IsPlaying then
-- 			animations.idle:Stop()
-- 			animations.move:Play()
-- 		end
-- 	else
-- 		if animations.Idle.IsPlaying then
-- 			animations.move:Stop()
-- 			animations.idle:Play()
-- 		end
-- 	end
-- end)