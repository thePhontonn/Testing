local NEW_JUMP_POWER = 100 

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

humanoid.UseJumpPower = true
humanoid.JumpPower = NEW_JUMP_POWER


player.CharacterAdded:Connect(function(newCharacter)
    local newHumanoid = newCharacter:WaitForChild("Humanoid")
    newHumanoid.UseJumpPower = true
    newHumanoid.JumpPower = NEW_JUMP_POWER
end)

print
