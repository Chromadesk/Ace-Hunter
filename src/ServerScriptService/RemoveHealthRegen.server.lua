--Remove roblox regen script

game.Workspace.DescendantAdded:connect(function(des)
	wait(1)
	if des == nil then return end
	if des:IsA("Script") and des.Name == "Health" then
		if des == nil then return end
		des:remove()
	end
end)