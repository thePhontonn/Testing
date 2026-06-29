local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 15)
if not PlayerGui then return end

if PlayerGui:FindFirstChild("CompactStrictMenu") then
    PlayerGui["CompactStrictMenu"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactStrictMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Главная панель меню (Высота увеличена до 430 для новой кнопки)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 430)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(45, 45, 55)
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Верхняя плашка (Заголовок)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local GlowLine = Instance.new("Frame")
GlowLine.Size = UDim2.new(1, 0, 0, 2)
GlowLine.Position = UDim2.new(0, 0, 1, -2)
GlowLine.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
GlowLine.BorderSizePixel = 0
GlowLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Text = "BROOKHAVEN v10.0 NOCLIP UPDATE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 38, 0, 36)
CloseButton.Position = UDim2.new(1, -38, 0, 0)
CloseButton.Text = "×"
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextColor3 = Color3.fromRGB(140, 140, 155)
CloseButton.BackgroundTransparency = 1
CloseButton.Parent = Header

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 40)
OpenButton.Position = UDim2.new(0, 20, 0, 80)
OpenButton.Text = "OPEN"
OpenButton.TextSize = 14
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
OpenButton.TextColor3 = Color3.fromRGB(0, 162, 255)
OpenButton.BorderSizePixel = 1
OpenButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
OpenButton.Parent = ScreenGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -24, 1, -50)
Container.Position = UDim2.new(0, 12, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- СОСТОЯНИЯ --
local isWalkActive = false
local isJumpActive = false
local isFlying = false
local isFrozen = false
local isInfJumpActive = false
local isSafeModeActive = false
local isNoclipActive = false

local currentWalkSpeed = 16
local currentFlySpeed = 50
local currentJumpPower = 50

local flyConnection = nil
local flyVelocity = nil
local flyGyro = nil
local noclipConnection = nil

local function getRootPart()
    local char = Player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = Player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- СТРОКА 1: Скорость ходьбы
local WalkButton = Instance.new("TextButton")
WalkButton.Size = UDim2.new(0, 160, 0, 36)
WalkButton.Position = UDim2.new(0, 0, 0, 0)
WalkButton.Text = "СКОРОСТЬ: ВЫКЛ"
WalkButton.TextSize = 12
WalkButton.Font = Enum.Font.SourceSansBold
WalkButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
WalkButton.TextColor3 = Color3.fromRGB(220, 220, 230)
WalkButton.BorderSizePixel = 1
WalkButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
WalkButton.Parent = Container

local WalkSpeedInput = Instance.new("TextBox")
WalkSpeedInput.Size = UDim2.new(0, 106, 0, 36)
WalkSpeedInput.Position = UDim2.new(0, 170, 0, 0)
WalkSpeedInput.Text = "16"
WalkSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
WalkSpeedInput.BorderSizePixel = 1
WalkSpeedInput.BorderColor3 = Color3.fromRGB(45, 45, 55)
WalkSpeedInput.Font = Enum.Font.SourceSansBold
WalkSpeedInput.TextSize = 14
WalkSpeedInput.ClearTextOnFocus = false
WalkSpeedInput.Parent = Container

-- СТРОКА 2: Полет
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 160, 0, 36)
FlyButton.Position = UDim2.new(0, 0, 0, 48)
FlyButton.Text = "ПОЛЕТ: ВЫКЛ"
FlyButton.TextSize = 12
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
FlyButton.TextColor3 = Color3.fromRGB(220, 220, 230)
FlyButton.BorderSizePixel = 1
FlyButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
FlyButton.Parent = Container

local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0, 106, 0, 36)
FlySpeedInput.Position = UDim2.new(0, 170, 0, 48)
FlySpeedInput.Text = "50"
FlySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FlySpeedInput.BorderSizePixel = 1
FlySpeedInput.BorderColor3 = Color3.fromRGB(45, 45, 55)
FlySpeedInput.Font = Enum.Font.SourceSansBold
FlySpeedInput.TextSize = 14
FlySpeedInput.ClearTextOnFocus = false
FlySpeedInput.Parent = Container

-- СТРОКА 3: Высота прыжка
local JumpButton = Instance.new("TextButton")
JumpButton.Size = UDim2.new(0, 160, 0, 36)
JumpButton.Position = UDim2.new(0, 0, 0, 96)
JumpButton.Text = "ПРЫЖОК: ВЫКЛ"
JumpButton.TextSize = 12
JumpButton.Font = Enum.Font.SourceSansBold
JumpButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
JumpButton.TextColor3 = Color3.fromRGB(220, 220, 230)
JumpButton.BorderSizePixel = 1
JumpButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
JumpButton.Parent = Container

local JumpPowerInput = Instance.new("TextBox")
JumpPowerInput.Size = UDim2.new(0, 106, 0, 36)
JumpPowerInput.Position = UDim2.new(0, 170, 0, 96)
JumpPowerInput.Text = "50"
JumpPowerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
JumpPowerInput.BorderSizePixel = 1
JumpPowerInput.BorderColor3 = Color3.fromRGB(45, 45, 55)
JumpPowerInput.Font = Enum.Font.SourceSansBold
JumpPowerInput.TextSize = 14
JumpPowerInput.ClearTextOnFocus = false
JumpPowerInput.Parent = Container

-- --- НОВАЯ СТРОКА 4: Ноуклип (Проход сквозь стены) ---
local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(1, 0, 0, 36)
NoclipButton.Position = UDim2.new(0, 0, 0, 144)
NoclipButton.Text = "НОУКЛИП: ВЫКЛ"
NoclipButton.TextSize = 12
NoclipButton.Font = Enum.Font.SourceSansBold
NoclipButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
NoclipButton.TextColor3 = Color3.fromRGB(220, 220, 230)
NoclipButton.BorderSizePixel = 1
NoclipButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
NoclipButton.Parent = Container

-- ФУНКЦИОНАЛЬНЫЕ КНОПКИ (Сдвинуты ниже на 48 пикселей)
local FreezeButton = Instance.new("TextButton")
FreezeButton.Size = UDim2.new(0, 132, 0, 36)
FreezeButton.Position = UDim2.new(0, 0, 0, 192)
FreezeButton.Text = "ЗАМОРОЗИТЬ"
FreezeButton.TextSize = 12
FreezeButton.Font = Enum.Font.SourceSansBold
FreezeButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
FreezeButton.TextColor3 = Color3.fromRGB(220, 220, 230)
FreezeButton.BorderSizePixel = 1
FreezeButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
FreezeButton.Parent = Container

local InfJumpButton = Instance.new("TextButton")
InfJumpButton.Size = UDim2.new(0, 132, 0, 36)
InfJumpButton.Position = UDim2.new(0, 144, 0, 192)
InfJumpButton.Text = "БЕСК. ПРЫЖОК"
InfJumpButton.TextSize = 12
InfJumpButton.Font = Enum.Font.SourceSansBold
InfJumpButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
InfJumpButton.TextColor3 = Color3.fromRGB(220, 220, 230)
InfJumpButton.BorderSizePixel = 1
InfJumpButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
InfJumpButton.Parent = Container

local ImpulseButton = Instance.new("TextButton")
ImpulseButton.Size = UDim2.new(1, 0, 0, 36)
ImpulseButton.Position = UDim2.new(0, 0, 0, 240)
ImpulseButton.Text = "РАКЕТНЫЙ РЫВОК (ВВЕРХ)"
ImpulseButton.TextSize = 12
ImpulseButton.Font = Enum.Font.SourceSansBold
ImpulseButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
ImpulseButton.TextColor3 = Color3.fromRGB(220, 220, 230)
ImpulseButton.BorderSizePixel = 1
ImpulseButton.BorderColor3 = Color3.fromRGB(45, 45, 55)
ImpulseButton.Parent = Container

local SafeModeButton = Instance.new("TextButton")
SafeModeButton.Size = UDim2.new(1, 0, 0, 36)
SafeModeButton.Position = UDim2.new(0, 0, 0, 288)
SafeModeButton.Text = "БЕЗОПАСНЫЙ РЕЖИМ: ВЫКЛ"
SafeModeButton.TextSize = 12
SafeModeButton.Font = Enum.Font.SourceSansBold
SafeModeButton.BackgroundColor3 = Color3.fromRGB(28, 38, 32)
SafeModeButton.TextColor3 = Color3.fromRGB(150, 200, 160)
SafeModeButton.BorderSizePixel = 1
SafeModeButton.BorderColor3 = Color3.fromRGB(40, 55, 45)
SafeModeButton.Parent = Container


-- ОБНОВЛЕНИЕ ХАРАКТЕРИСТИК --
local function updateCharacterState()
    local targetWalk = tonumber(WalkSpeedInput.Text) or 16
    local targetFly = tonumber(FlySpeedInput.Text) or 50
    local targetJump = tonumber(JumpPowerInput.Text) or 50
    
    if isSafeModeActive then
        targetWalk = math.clamp(targetWalk, 0, 45)
        targetFly = math.clamp(targetFly, 0, 45)
        targetJump = math.clamp(targetJump, 0, 90)
    end
    
    currentWalkSpeed = targetWalk
    currentFlySpeed = targetFly
    currentJumpPower = targetJump
    
    local humanoid = getHumanoid()
    if humanoid and not isFrozen then
        pcall(function()
            if not isFlying then
                humanoid.WalkSpeed = isWalkActive and currentWalkSpeed or 16
            end
            humanoid.UseJumpPower = true
            humanoid.JumpPower = isJumpActive and currentJumpPower or 50
        end)
    end
end

WalkSpeedInput:GetPropertyChangedSignal("Text"):Connect(updateCharacterState)
FlySpeedInput:GetPropertyChangedSignal("Text"):Connect(updateCharacterState)
JumpPowerInput:GetPropertyChangedSignal("Text"):Connect(updateCharacterState)


-- ЛОГИКА НАСТОЯЩЕГО МОБИЛЬНОГО ПОЛЁТА --
local function toggleFly()
    local rootPart = getRootPart()
    local humanoid = getHumanoid()
    if not rootPart or not humanoid then return end

    isFlying = not isFlying

    if isFlying then
        FlyButton.Text = "ПОЛЕТ: АКТИВЕН"
        FlyButton.BackgroundColor3 = Color3.fromRGB(130, 50, 150)
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro.P = 9e4
        flyGyro.cframe = rootPart.CFrame
        flyGyro.Parent = rootPart
        
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        flyVelocity.velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = rootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            local camera = Workspace.CurrentCamera
            if not isFlying or not rootPart or not humanoid or not camera or not flyVelocity or not flyGyro then return end
            
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            flyGyro.cframe = camera.CFrame
            
            if humanoid.MoveDirection.Magnitude > 0 then
                local camCFrame = camera.CFrame
                local flatMove = humanoid.MoveDirection
                
                local camLookFlat = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
                local camRightFlat = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit
                
                local forwardDot = flatMove:Dot(camLookFlat)
                local rightDot = flatMove:Dot(camRightFlat)
                
                local trueFlyDirection = (camCFrame.LookVector * forwardDot) + (camCFrame.RightVector * rightDot)
                if trueFlyDirection.Magnitude > 0 then
                    trueFlyDirection = trueFlyDirection.Unit
                end
                
                local targetVelocity = trueFlyDirection * currentFlySpeed
                flyVelocity.velocity = flyVelocity.velocity:Lerp(targetVelocity, 0.25)
            else
                flyVelocity.velocity = flyVelocity.velocity:Lerp(Vector3.new(0, 0, 0), 0.25)
            end
        end)
    else
        FlyButton.Text = "ПОЛЕТ: ВЫКЛ"
        FlyButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
        
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        updateCharacterState()
    end
end


-- ЛОГИКА НОУКЛИПА (ПРОХОД СКВОЗЬ СТЕНЫ) --
local function toggleNoclip()
    isNoclipActive = not isNoclipActive
    
    if isNoclipActive then
        NoclipButton.Text = "НОУКЛИП: АКТИВЕН"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(110, 40, 140) -- Фиолетовый цвет активности
        
        -- Цикл отключения коллизий персонажа на каждый кадр игры
        noclipConnection = RunService.Stepped:Connect(function()
            local character = Player.Character
            if character and isNoclipActive then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        NoclipButton.Text = "НОУКЛИП: ВЫКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end


-- НАЖАТИЯ КНОПОК ПЕРЕКЛЮЧАТЕЛЕЙ --
WalkButton.MouseButton1Click:Connect(function()
    isWalkActive = not isWalkActive
    WalkButton.Text = isWalkActive and "СКОРОСТЬ: АКТИВНА" or "СКОРОСТЬ: ВЫКЛ"
    WalkButton.BackgroundColor3 = isWalkActive and Color3.fromRGB(46, 139, 87) or Color3.fromRGB(32, 32, 42)
    updateCharacterState()
end)

JumpButton.MouseButton1Click:Connect(function()
    isJumpActive = not isJumpActive
    JumpButton.Text = isJumpActive and "ПРЫЖОК: АКТИВЕН" or "ПРЫЖОК: ВЫКЛ"
    JumpButton.BackgroundColor3 = isJumpActive and Color3.fromRGB(46, 139, 87) or Color3.fromRGB(32, 32, 42)
    updateCharacterState()
end)

FlyButton.MouseButton1Click:Connect(function()
    toggleFly()
end)

NoclipButton.MouseButton1Click:Connect(function()
    toggleNoclip()
end)

FreezeButton.MouseButton1Click:Connect(function()
    local rootPart = getRootPart()
    if rootPart then
        isFrozen = not isFrozen
        rootPart.Anchored = isFrozen
        if isFrozen then
            if isFlying then toggleFly() end
            FreezeButton.Text = "РАЗМОРОЗИТЬ"
            FreezeButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        else
            FreezeButton.Text = "ЗАМОРОЗИТЬ"
            FreezeButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
            updateCharacterState()
        end
    end
end)

InfJumpButton.MouseButton1Click:Connect(function()
    isInfJumpActive = not isInfJumpActive
    InfJumpButton.Text = isInfJumpActive and "АКТИВЕН" or "БЕСК. ПРЫЖОК"
    InfJumpButton.BackgroundColor3 = isInfJumpActive and Color3.fromRGB(40, 60, 120) or Color3.fromRGB(32, 32, 42)
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if isInfJumpActive and not isFlying then
        local rootPart = getRootPart()
        if rootPart then
            pcall(function()
                local jumpHeight = isJumpActive and currentJumpPower or 50
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, jumpHeight, rootPart.AssemblyLinearVelocity.Z)
            end)
        end
    end
end)

ImpulseButton.MouseButton1Click:Connect(function()
    local rootPart = getRootPart()
    if rootPart and not isFrozen then
        pcall(function()
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 140, rootPart.AssemblyLinearVelocity.Z)
        end)
        local oldBg = ImpulseButton.BackgroundColor3
        ImpulseButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        task.wait(0.15)
        ImpulseButton.BackgroundColor3 = oldBg
    end
end)

SafeModeButton.MouseButton1Click:Connect(function()
    isSafeModeActive = not isSafeModeActive
    SafeModeButton.Text = isSafeModeActive and "БЕЗОПАСНЫЙ РЕЖИМ: АКТИВЕН" or "БЕЗОПАСНЫЙ РЕЖИМ: ВЫКЛ"
    SafeModeButton.BackgroundColor3 = isSafeModeActive and Color3.fromRGB(46, 139, 87) or Color3.fromRGB(28, 38, 32)
    SafeModeButton.TextColor3 = isSafeModeActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 200, 160)
    updateCharacterState()
end)


-- СБРОС ПРИ СМЕРТИ/СПАВНЕ --
Player.CharacterAdded:Connect(function(char)
    isFrozen = false
    isFlying = false
    if isNoclipActive then toggleNoclip() end -- Выключаем ноуклип для чистого респавна
    
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
    
    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid then
        task.wait(0.5)
        updateCharacterState()
    end
end)


-- СМАЙЛ-ДРАГГИНГ ДЛЯ МОБИЛОК --
local dragging = false
local dragStart = Vector3.new()
local startPos = UDim2.new()

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
