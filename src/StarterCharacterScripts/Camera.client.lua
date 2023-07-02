local player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local character = script.Parent

character.Humanoid.AutoRotate = false
character.Humanoid.CameraOffset = Vector3.new(2,-1,0)
player.CameraMaxZoomDistance = 10
player.CameraMinZoomDistance = 5

RunService:BindToRenderStep("MouseLock",Enum.RenderPriority.Last.Value+1,function()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end)


RunService.RenderStepped:Connect(function()
    if character.Assets.DisableRotation.Value then return end
    local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
    character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position) * CFrame.Angles(0,y,0)
end)