--TODO when maps are made, every map should have a set of variables of which to set the lighting to.
local Lighting = game:GetService("Lighting")

Lighting.ColorCorrection.Enabled = false

Lighting.Brightness = 1
Lighting.ColorShift_Top = Color3.fromRGB(72, 72, 207)
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.OutdoorAmbient = Color3.fromRGB(24, 24, 24)
Lighting.ClockTime = 2
Lighting.FogColor = Color3.fromRGB(22, 15, 15)
Lighting.FogEnd = 500
Lighting.FogStart = 300