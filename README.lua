--[[
    Fly Dark GUI | Universal (Mobile & PC Fixed Edition)
    Personalized by: mateyspess-afk
    Original concept credits: XNEO / de_stupidtornadokid
    Improved version with fixed mobile joystick movement & RGB border
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Speeds = 1
local Flying = false
local MaxFlySpeed = 50

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Fly Dark GUI",
        Text = "by mateyspess-afk | Credits: XNEO",
        Duration = 5
    })
end)

if PlayerGui:FindFirstChild("FlyDarkGUI") then
    PlayerGui.FlyDarkGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyDarkGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 220, 0, 110)
MainFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- RGB Border Effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local RGBConnection
RGBConnection = RunService.RenderStepped:Connect(function()
    if not MainFrame or not MainFrame.Parent then
        if RGBConnection then RGBConnection:Disconnect() end
        return
    end
    local hue = tick() % 5 / 5
    UIStroke.Color = Color3.fromHSV(hue, 1, 1)
end)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Fly Dark | mateyspess"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 28, 0, 28)
MiniBtn.Position = UDim2.new(1, -64, 0, 2)
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
MiniBtn.Text = "-"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 18
MiniBtn.Parent = TitleBar

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 6)
MiniCorner.Parent = MiniBtn

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -42)
Content.Position = UDim2.new(0, 8, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local function CreateButton(parent, text, size, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

-- Traduzido para Inglês
local UpBtn = CreateButton(Content, "UP", UDim2.new(0, 50, 0, 28), UDim2.new(0, 0, 0, 0))
local DownBtn = CreateButton(Content, "DOWN", UDim2.new(0, 50, 0, 28), UDim2.new(0, 0, 0, 34))
local PlusBtn = CreateButton(Content, "+", UDim2.new(0, 40, 0, 28), UDim2.new(0, 56, 0, 0))
local MinusBtn = CreateButton(Content, "-", UDim2.new(0, 40, 0, 28), UDim2.new(0, 56, 0, 34))

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 50, 0, 28)
SpeedLabel.Position = UDim2.new(0, 102, 0, 0)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SpeedLabel.Text = tostring(Speeds)
SpeedLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 16
SpeedLabel.Parent = Content

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedLabel

local FlyBtn = CreateButton(Content, "FLY OFF", UDim2.new(0, 90, 0, 62), UDim2.new(0, 110, 0, 0), Color3.fromRGB(50, 90, 140))

local BodyGyro, BodyVelocity
local FlyConnection
local UpConnection, DownConnection

local function StopFly()
    Flying = false

    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end

    FlyBtn.Text = "FLY OFF"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 90, 140)
end

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not root then return end

    Flying = true
    FlyBtn.Text = "FLY ON"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)

    hum.PlatformStand = true
    local animate = char:FindFirstChild("Animate")
    if animate then animate.Disabled = true end

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = root.CFrame
    BodyGyro.Parent = root

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not char or not char.Parent or not hum or hum.Health <= 0 then
            StopFly()
            return
        end

        local cam = workspace.CurrentCamera
        local moveDirection = hum.MoveDirection
        local currentSpeed = Speeds * 22

        -- Correção para o analógico do celular não inverter a direção
        if moveDirection.Magnitude > 0 then
            local moveVector = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z))
            BodyVelocity.Velocity = Vector3.new(moveVector.X, moveDirection.Y * currentSpeed, moveVector.Z) * currentSpeed
        else
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end

        BodyGyro.CFrame = cam.CFrame
    end)
end

FlyBtn.MouseButton1Click:Connect(function()
    if Flying then
        StopFly()
    else
        StartFly()
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    Speeds = math.clamp(Speeds + 1, 1, 10)
    SpeedLabel.Text = tostring(Speeds)
end)

MinusBtn.MouseButton1Click:Connect(function()
    Speeds = math.clamp(Speeds - 1, 1, 10)
    SpeedLabel.Text = tostring(Speeds)
end)

UpBtn.MouseButton1Down:Connect(function()
    UpConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 1.2, 0)
        end
    end)
end)

UpBtn.MouseButton1Up:Connect(function()
    if UpConnection then UpConnection:Disconnect() UpConnection = nil end
end)

UpBtn.MouseLeave:Connect(function()
    if UpConnection then UpConnection:Disconnect() UpConnection = nil end
end)

DownBtn.MouseButton1Down:Connect(function()
    DownConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        if root then
            root.CFrame = root.CFrame - Vector3.new(0, 1.2, 0)
        end
    end)
end)

DownBtn.MouseButton1Up:Connect(function()
    if DownConnection then DownConnection:Disconnect() DownConnection = nil end
end)

DownBtn.MouseLeave:Connect(function()
    if DownConnection then DownConnection:Disconnect() DownConnection = nil end
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFly()
    if RGBConnection then RGBConnection:Disconnect() end
    ScreenGui:Destroy()
end)

local Minimized = false
MiniBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0, 220, 0, 36)
        MiniBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 220, 0, 110)
        MiniBtn.Text = "-"
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    StopFly()
end)

print("[Fly Dark GUI] Loaded successfully by mateyspess-afk")
