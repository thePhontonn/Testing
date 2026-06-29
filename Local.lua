-- ==================== НАСТРОЙКИ ====================
local DEFAULT_JUMP = 50       -- Обычная высота прыжка
local MEGA_JUMP = 120         -- Высота супер-прыжка
-- ===================================================

local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- Переменная для отслеживания состояния (true = включен, false = выключен)
local isJumpEnabled = false

-- Функция для применения прыжка к текущему гуманоиду
local function applyJumpPower(character)
    if character then
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = isJumpEnabled and MEGA_JUMP or DEFAULT_JUMP
        end
    end
end

-- Создание UI элементов
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JumpToggleGui"
screenGui.ResetOnSpawn = false -- Чтобы кнопка не пропадала после смерти
screenGui.Parent = pGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25) -- Слева по центру экрана
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Красный по умолчанию
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Супер Прыжок: ВЫКЛ"
toggleButton.Parent = screenGui

-- Скругление углов для кнопки (чтобы выглядела красивее)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = toggleButton

-- Логика нажатия на кнопку
toggleButton.MouseButton1Click:Connect(function()
    isJumpEnabled = not isJumpEnabled -- Переключаем состояние
    
    if isJumpEnabled then
        toggleButton.Text = "Супер Прыжок: ВКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Зеленый
    else
        toggleButton.Text = "Супер Прыжок: ВЫКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Красный
    end
    
    -- Применяем изменения сразу
    applyJumpPower(player.Character)
end)

-- Следим за возрождением персонажа, чтобы настройки прыжка не сбрасывались
player.CharacterAdded:Connect(function(char)
    -- Небольшая задержка, чтобы игра успела загрузить гуманоида
    task.wait(0.5)
    applyJumpPower(char)
end)

-- Применяем настройки к уже существующему персонажу при первом запуске
if player.Character then
    applyJumpPower(player.Character)
end
