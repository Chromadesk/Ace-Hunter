--TODO when maps are made, every map should have a set of variables of which to set the lighting to.
local Lighting = game:GetService("Lighting")

Lighting.ColorCorrection.Enabled = false

Lighting.Brightness = 2
Lighting.ColorShift_Top = Color3.fromRGB(207, 72, 124)
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.OutdoorAmbient = Color3.fromRGB(94, 94, 94)
Lighting.ClockTime = 20
Lighting.FogColor = Color3.fromRGB(80, 45, 47)
Lighting.FogEnd = 500
Lighting.FogStart = 100