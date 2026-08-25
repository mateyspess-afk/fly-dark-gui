--[[
    MANUS HUB - Versão Desofuscada
    Funcionalidades: Orbit, Dash, Follow, Music Player
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local OrbitRadius = 10
local OrbitHeight = 3
local OrbitSpeed = 3
local DashDistance = 15
local DashSpeed = 15
local FollowDistance = 5
local MusicVolume = 50
local BassEffect = 0

local OrbitActive = false
local DashActive = false
local FollowActive = false
local OrbitBodyActive = false
local DashBodyActive = false
local FollowBodyActive = false

local CurrentTarget = nil
local CurrentMusic = nil
local MusicId = nil
local MenuMinimized = false
local OriginalMenuSize = nil
local OrbitAngle = 0
local DashTime = 0
local AutoRotateState = true

local function IsPlayerValid(player)
    if not player or player == LocalPlayer then
        return false
    end
    local character = player.Character
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    return true
end

local function FindNearestTarget()
    local nearest = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if IsPlayerValid(player) then
            local targetRoot = player.Character.HumanoidRootPart
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local distance = (myRoot.Position - targetRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearest = player
                end
            end
        end
    end
    return nearest
end

local function UpdateTarget()
    if not (OrbitActive or DashActive or FollowActive) then
        CurrentTarget = nil
        return
    end
    if not IsPlayerValid(CurrentTarget) then
        CurrentTarget = FindNearestTarget()
    end
end

local function ApplyBassEffect(sound, bassLevel)
    if not sound then return end
    for _, child in pairs(sound:GetChildren()) do
        if child:IsA("EqualizerSoundEffect") then
            child:Destroy()
        end
    end
    local equalizer = Instance.new("EqualizerSoundEffect")
    local normalizedBass = bassLevel / 1000
    equalizer.HighGain = 0
    equalizer.MidGain = -(normalizedBass * 3)
    equalizer.LowGain = normalizedBass * 3
    equalizer.Parent = sound
end

local function PlayMusic(musicId)
    if CurrentMusic and MusicId == musicId then
        if not CurrentMusic.IsPlaying then
            CurrentMusic:Play()
        end
        return
    end
    if CurrentMusic then
        CurrentMusic:Stop()
        CurrentMusic:Destroy()
        CurrentMusic = nil
        MusicId = nil
    end
    local newSound = Instance.new("Sound")
    newSound.SoundId = "rbxassetid://" .. tostring(musicId)
    newSound.Volume = MusicVolume / 100
    newSound.Looped = true
    newSound.PlayOnRemove = false
    newSound.Parent = game:GetService("SoundService")
    ApplyBassEffect(newSound, BassEffect)
    newSound.ErrorOccurred:Connect(function(error)
        warn("Erro ao tocar música: " .. error)
        if CurrentMusic == newSound then
            CurrentMusic = nil
            MusicId = nil
        end
    end)
    newSound:Play()
    CurrentMusic = newSound
    MusicId = musicId
end

local function StopMusic()
    if CurrentMusic then
        CurrentMusic:Stop()
        CurrentMusic:Destroy()
        CurrentMusic = nil
        MusicId = nil
    end
end

local function SetVolume(volume)
    MusicVolume = volume
    if CurrentMusic then
        CurrentMusic.Volume = volume / 100
    end
end

local function SetBass(bass)
    BassEffect = bass
    if CurrentMusic then
        ApplyBassEffect(CurrentMusic, bass)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    UpdateTarget()
    if (OrbitActive or DashActive or FollowActive) and CurrentTarget then
        local targetCharacter = CurrentTarget.Character
        if not targetCharacter then return end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local targetPosition = targetRoot.Position
        if FollowActive then
            OrbitAngle = OrbitAngle + (OrbitSpeed * deltaTime)
            local orbitPosition = targetPosition + Vector3.new(
                math.cos(OrbitAngle) * OrbitRadius,
                OrbitHeight,
                math.sin(OrbitAngle) * OrbitRadius
            )
            if FollowBodyActive then
                if humanoid.AutoRotate then
                    AutoRotateState = humanoid.AutoRotate
                    humanoid.AutoRotate = false
                end
                rootPart.CFrame = CFrame.new(orbitPosition, targetPosition)
            else
                if not humanoid.AutoRotate and AutoRotateState then
                    humanoid.AutoRotate = AutoRotateState
                end
                rootPart.CFrame = CFrame.new(orbitPosition) * rootPart.CFrame.Rotation
            end
        elseif DashActive then
            DashTime = DashTime + (DashSpeed * deltaTime)
            local dashPosition = targetPosition + (targetRoot.CFrame.LookVector * math.sin(DashTime) * DashDistance) + Vector3.new(0, OrbitHeight, 0)
            if DashBodyActive then
                if humanoid.AutoRotate then
                    AutoRotateState = humanoid.AutoRotate
                    humanoid.AutoRotate = false
                end
                rootPart.CFrame = CFrame.new(dashPosition, targetPosition)
            else
                if not humanoid.AutoRotate and AutoRotateState then
                    humanoid.AutoRotate = AutoRotateState
                end
                rootPart.CFrame = CFrame.new(dashPosition) * rootPart.CFrame.Rotation
            end
        elseif OrbitActive then
            DashTime = DashTime + (OrbitSpeed * deltaTime)
            local orbitPosition = targetPosition + Vector3.new(
                math.cos(DashTime) * OrbitRadius,
                OrbitHeight,
                math.sin(DashTime) * OrbitRadius
            )
            if OrbitBodyActive then
                if humanoid.AutoRotate then
                    AutoRotateState = humanoid.AutoRotate
                    humanoid.AutoRotate = false
                end
                rootPart.CFrame = CFrame.new(orbitPosition, targetPosition)
            else
                if not humanoid.AutoRotate and AutoRotateState then
                    humanoid.AutoRotate = AutoRotateState
                end
                rootPart.CFrame = CFrame.new(orbitPosition) * rootPart.CFrame.Rotation
            end
        end
    elseif not humanoid.AutoRotate and AutoRotateState then
        humanoid.AutoRotate = AutoRotateState
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 460)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(34, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
OriginalMenuSize = MainFrame.Size

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BackgroundImage.BackgroundTransparency = 0
BackgroundImage.Image = "rbxassetid://100005968576512"
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.Parent = MainFrame

local DarkOverlay = Instance.new("ImageLabel")
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 0.5
DarkOverlay.Image = ""
DarkOverlay.Parent = MainFrame

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
HeaderFrame.Position = UDim2.new(0, 0, 0, 8)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.BackgroundTransparency = 0.3
HeaderFrame.Parent = MainFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 50, 0, 50)
AvatarImage.Position = UDim2.new(0, 5, 0, 5)
AvatarImage.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AvatarImage.BackgroundTransparency = 0
AvatarImage.BorderSizePixel = 0
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=8089270601&w=420&h=420"
AvatarImage.Parent = HeaderFrame
Instance.new("UICorner").Parent = AvatarImage

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 130, 0, 28)
TitleLabel.Position = UDim2.new(0, 70, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MANUS HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0, 100, 0, 16)
SubtitleLabel.Position = UDim2.new(0, 70, 0, 32)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "by mateus_15600"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 10
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = MainFrame

local Hue = 0
local TitleColorLoop = RunService.RenderStepped:Connect(function()
    Hue = (Hue + 0.005) % 1
    TitleLabel.TextColor3 = Color3.fromHSV(Hue, 1, 1)
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
MinimizeButton.Position = UDim2.new(1, -40, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.Parent = MainFrame
Instance.new("UICorner").Parent = MinimizeButton

local ContentScroller = Instance.new("ScrollingFrame")
ContentScroller.Size = UDim2.new(1, 0, 0, 300)
ContentScroller.Position = UDim2.new(0, 0, 0, 70)
ContentScroller.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentScroller.BackgroundTransparency = 0.3
ContentScroller.BorderSizePixel = 0
ContentScroller.ScrollBarThickness = 4
ContentScroller.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ContentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroller.AutomaticCanvasSize = Enum.AutomaticSize.X
ContentScroller.Parent = MainFrame

local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, 0, 0, 45)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = ContentScroller

local TabButtons = {}
local TabFrames = {}

local function CreateTab(tabName, height)
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 3
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, height or 350)
    tabFrame.Visible = false
    tabFrame.Parent = MainFrame
    TabFrames[tabName] = tabFrame
    return tabFrame
end

local function CreateTabButton(tabName, label, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 1, -2)
    button.Position = UDim2.new(0, position, 0, 2)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = label
    button.TextColor3 = Color3.fromRGB(150, 150, 150)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = TabsContainer
    Instance.new("UICorner").Parent = button
    button.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        for _, btn in pairs(TabButtons) do
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.BackgroundTransparency = 0.3
        end
        TabFrames[tabName].Visible = true
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
        button.BackgroundTransparency = 0.1
    end)
    table.insert(TabButtons, button)
    return button
end

local OrbitTab = CreateTab("Orbit", 350)
local DashTab = CreateTab("Dash", 350)
local FollowTab = CreateTab("Follow", 300)
local MusicTab = CreateTab("Music", 350)
local SettingsTab = CreateTab("Settings", 50)

CreateTabButton("Orbit", "ORBIT", 5)
CreateTabButton("Dash", "PASSAR", 75)
CreateTabButton("Follow", "SEGUIR", 145)
CreateTabButton("Music", "MUSICA", 215)
CreateTabButton("Settings", "OPCOES", 285)

TabsContainer.Size = UDim2.new(0, 355, 1, 0)

local function CreateToggleButton(text, position, color, parent, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.Position = position
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Parent = parent
    Instance.new("UICorner").Parent = button
    button.MouseButton1Click:Connect(callback)
    return button
end

local function CreateSlider(label, position, minValue, maxValue, initialValue, parent, callback)
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.9, 0, 0, 15)
    labelText.Position = position
    labelText.BackgroundTransparency = 1
    labelText.Text = label .. ": " .. initialValue
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 9
    labelText.Parent = parent
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0, 6)
    track.Position = position + UDim2.new(0, 0, 0, 18)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    track.BackgroundTransparency = 0.3
    track.Parent = parent
    Instance.new("UICorner").Parent = track
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    fill.Parent = track
    Instance.new("UICorner").Parent = fill
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInput.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                    if connection then connection:Disconnect() end
                end
            end)
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInput:GetMouseLocation()
                local percent = math.clamp((mousePos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(minValue + (percent * (maxValue - minValue)))
                labelText.Text = label .. ": " .. value
                callback(value)
            end)
        end
    end)
end

local OrbitToggle = CreateToggleButton(
    "ORBIT: OFF",
    UDim2.new(0.05, 0, 0, 5),
    Color3.fromRGB(180, 50, 50),
    OrbitTab,
    function()
        if OrbitActive then
            OrbitActive = false
            OrbitToggle.Text = "ORBIT: OFF"
            OrbitToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            CurrentTarget = nil
        else
            DashActive = false
            FollowActive = false
            DashToggle.Text = "PASSAR: OFF"
            DashToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            FollowToggle.Text = "SEGUIR: OFF"
            FollowToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            OrbitActive = true
            OrbitToggle.Text = "ORBIT: ON"
            OrbitToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            UpdateTarget()
        end
    end
)

local OrbitBodyToggle = CreateToggleButton(
    "CORPO: OFF",
    UDim2.new(0.05, 0, 0, 50),
    Color3.fromRGB(150, 100, 50),
    OrbitTab,
    function()
        OrbitBodyActive = not OrbitBodyActive
        if OrbitBodyActive then
            OrbitBodyToggle.Text = "CORPO: ON"
            OrbitBodyToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        else
            OrbitBodyToggle.Text = "CORPO: OFF"
            OrbitBodyToggle.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        end
    end
)

CreateSlider("Orbit: Velocidade", UDim2.new(0.05, 0, 0, 100), 1, 20, OrbitSpeed, OrbitTab, function(value)
    OrbitSpeed = value
end)

CreateSlider("Orbit: Distancia", UDim2.new(0.05, 0, 0, 140), 2, 50, OrbitRadius, OrbitTab, function(value)
    OrbitRadius = value
end)

CreateSlider("Altura", UDim2.new(0.05, 0, 0, 180), -10, 20, OrbitHeight, OrbitTab, function(value)
    OrbitHeight = value
end)

local DashToggle = CreateToggleButton(
    "PASSAR: OFF",
    UDim2.new(0.05, 0, 0, 5),
    Color3.fromRGB(180, 50, 50),
    DashTab,
    function()
        if DashActive then
            DashActive = false
            DashToggle.Text = "PASSAR: OFF"
            DashToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            CurrentTarget = nil
        else
            OrbitActive = false
            FollowActive = false
            OrbitToggle.Text = "ORBIT: OFF"
            OrbitToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            FollowToggle.Text = "SEGUIR: OFF"
            FollowToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            DashActive = true
            DashToggle.Text = "PASSAR: ON"
            DashToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            UpdateTarget()
        end
    end
)

local DashBodyToggle = CreateToggleButton(
    "CORPO: OFF",
    UDim2.new(0.05, 0, 0, 50),
    Color3.fromRGB(150, 100, 50),
    DashTab,
    function()
        DashBodyActive = not DashBodyActive
        if DashBodyActive then
            DashBodyToggle.Text = "CORPO: ON"
            DashBodyToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        else
            DashBodyToggle.Text = "CORPO: OFF"
            DashBodyToggle.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        end
    end
)

CreateSlider("Passar: Velocidade", UDim2.new(0.05, 0, 0, 100), 1, 60, DashSpeed, DashTab, function(value)
    DashSpeed = value
end)

CreateSlider("Passar: Distancia", UDim2.new(0.05, 0, 0, 140), 2, 50, DashDistance, DashTab, function(value)
    DashDistance = value
end)

local FollowToggle = CreateToggleButton(
    "SEGUIR: OFF",
    UDim2.new(0.05, 0, 0, 5),
    Color3.fromRGB(180, 50, 50),
    FollowTab,
    function()
        if FollowActive then
            FollowActive = false
            FollowToggle.Text = "SEGUIR: OFF"
            FollowToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            CurrentTarget = nil
        else
            OrbitActive = false
            DashActive = false
            OrbitToggle.Text = "ORBIT: OFF"
            OrbitToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            DashToggle.Text = "PASSAR: OFF"
            DashToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            FollowActive = true
            FollowToggle.Text = "SEGUIR: ON"
            FollowToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            UpdateTarget()
        end
    end
)

local FollowBodyToggle = CreateToggleButton(
    "CORPO: OFF",
    UDim2.new(0.05, 0, 0, 50),
    Color3.fromRGB(150, 100, 50),
    FollowTab,
    function()
        FollowBodyActive = not FollowBodyActive
        if FollowBodyActive then
            FollowBodyToggle.Text = "CORPO: ON"
            FollowBodyToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        else
            FollowBodyToggle.Text = "CORPO: OFF"
            FollowBodyToggle.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        end
    end
)

CreateSlider("Seguir: Distancia", UDim2.new(0.05, 0, 0, 100), 1, 30, FollowDistance, FollowTab, function(value)
    FollowDistance = value
end)

local MusicIdBox = Instance.new("TextBox")
MusicIdBox.Size = UDim2.new(0.9, 0, 0, 35)
MusicIdBox.Position = UDim2.new(0.05, 0, 0, 10)
MusicIdBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MusicIdBox.BackgroundTransparency = 0.2
MusicIdBox.PlaceholderText = "ID da musica (ex: 1837204731)"
MusicIdBox.Text = ""
MusicIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicIdBox.Font = Enum.Font.Gotham
MusicIdBox.TextSize = 10
MusicIdBox.Parent = MusicTab
Instance.new("UICorner").Parent = MusicIdBox

local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.43, 0, 0, 35)
PlayButton.Position = UDim2.new(0.05, 0, 0, 55)
PlayButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
PlayButton.BackgroundTransparency = 0.2
PlayButton.Text = "PLAY"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 12
PlayButton.Parent = MusicTab
Instance.new("UICorner").Parent = PlayButton

PlayButton.MouseButton1Click:Connect(function()
    local id = MusicIdBox.Text
    if id ~= "" then
        PlayMusic(id)
    end
end)

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.43, 0, 0, 35)
StopButton.Position = UDim2.new(0.52, 0, 0, 55)
StopButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
StopButton.BackgroundTransparency = 0.2
StopButton.Text = "STOP"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 12
StopButton.Parent = MusicTab
Instance.new("UICorner").Parent = StopButton

StopButton.MouseButton1Click:Connect(function()
    StopMusic()
end)

CreateSlider("Volume (Max 10000)", UDim2.new(0.05, 0, 0, 110), 0, 10000, MusicVolume, MusicTab, function(value)
    SetVolume(value)
end)

CreateSlider("Grave (Max 1000)", UDim2.new(0.05, 0, 0, 170), 0, 1000, BassEffect, MusicTab, function(value)
    SetBass(value)
end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 50)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 240)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Grave: efeito de grave (quanto maior, mais grave)\nVolume max 10000 para sons mais altos"
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 9
InfoLabel.TextWrapped = true
InfoLabel.Parent = MusicTab

local CloseButton = CreateToggleButton(
    "FECHAR MENU",
    UDim2.new(0.05, 0, 0, 10),
    Color3.fromRGB(150, 50, 50),
    SettingsTab,
    function()
        StopMusic()
        TitleColorLoop:Disconnect()
        ScreenGui:Destroy()
    end
)

MinimizeButton.MouseButton1Click:Connect(function()
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://12221967"
    clickSound.Volume = 0.5
    clickSound.Parent = game:GetService("SoundService")
    clickSound:Play()
    MenuMinimized = not MenuMinimized
    if MenuMinimized then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 280, 0, 45)})
        tween:Play()
        tween.Completed:Connect(function()
            ContentScroller.Visible = false
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
        end)
        MinimizeButton.Text = "+"
    else
        ContentScroller.Visible = true
        local anyVisible = false
        for _, frame in pairs(TabFrames) do
            if frame.Visible then anyVisible = true end
        end
        if not anyVisible then
            TabFrames["Orbit"].Visible = true
        end
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = OriginalMenuSize})
        tween:Play()
        MinimizeButton.Text = "-"
    end
end)

TabFrames["Orbit"].Visible = true
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtons[1].BackgroundColor3 = Color3.fromRGB(50, 50, 100)
TabButtons[1].BackgroundTransparency = 0.1

print("Manus Hub Carregado | by mateus_15600")
print("Script desofuscado com sucesso!")
