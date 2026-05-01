-- 🚀 MOBILE SCRIPT v2.0 - УНИВЕРСАЛЬНЫЙ СКРИПТ ДЛЯ ТЕЛЕФОНА
-- 📱 Работает в Delta, Arceus X, Fluxus
-- 🔗 Положи на GitHub и используй свою ссылку

-- ============ КОНФИГУРАЦИЯ ============
local Config = {
    ScriptName = "Mobile Master",
    Version = "2.0",
    Author = "Alyosha",
    
    -- Основные настройки
    DefaultWalkSpeed = 50,
    DefaultJumpPower = 50,
    
    -- Цвета интерфейса
    PrimaryColor = Color3.fromRGB(255, 50, 50),
    SecondaryColor = Color3.fromRGB(30, 30, 45),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- ============ ПЕРЕМЕННЫЕ ============
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Глобальные переменные
_G.Settings = {
    -- Игрок
    WalkSpeed = Config.DefaultWalkSpeed,
    JumpPower = Config.DefaultJumpPower,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    NoclipSpeed = 1,
    
    -- Боевые
    AimBot = false,
    AimFOV = 150,
    AimSmoothness = 0.3,
    SilentAim = false,
    TriggerBot = false,
    NoRecoil = false,
    RapidFire = false,
    InfiniteAmmo = false,
    
    -- Магические пули
    MagicBullets = false,
    WallBang = false,
    BulletSpeed = 500,
    BulletGravity = false,
    HomingBullets = false,
    HomingStrength = 0.5,
    
    -- ESP
    ESP = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPMaxDistance = 500,
    
    -- Другое
    AntiAFK = true,
    AutoFarm = false,
    AutoClick = false,
    ClickSpeed = 10
}

-- ============ ФУНКЦИИ ИГРОКА ============
local function ApplySpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.WalkSpeed
    end
end

local function ApplyJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = _G.Settings.JumpPower
    end
end

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if _G.Settings.InfiniteJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end
end)

-- Ноклип
local NoclipConnection
if not NoclipConnection then
    NoclipConnection = RunService.Stepped:Connect(function()
        if _G.Settings.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- ============ МАГИЧЕСКИЕ ПУЛИ ============
local function SetupMagicBullets()
    if not _G.Settings.MagicBullets then return end
    
    local BulletTracers = {}
    
    -- Перехват выстрелов
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if _G.Settings.MagicBullets then
            -- Пули через стены
            if method == "FireServer" or method == "fireServer" then
                if tostring(self):find("Weapon") or tostring(self):find("Gun") then
                    -- Изменение свойств пули
                    if _G.Settings.WallBang then
                        -- Пули проходят через стены
                    end
                    
                    if _G.Settings.HomingBullets then
                        -- Самонаводящиеся пули
                    end
                    
                    if _G.Settings.InfiniteAmmo then
                        -- Бесконечные патроны
                    end
                end
            end
            
            -- Ускорение стрельбы
            if method == "Wait" or method == "wait" then
                if _G.Settings.RapidFire then
                    return 0.01
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    
    -- Создание трассеров
    local function CreateTracer(startPos, endPos)
        local tracer = Instance.new("Part")
        tracer.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
        tracer.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -tracer.Size.Z/2)
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Material = Enum.Material.Neon
        tracer.Color = Config.PrimaryColor
        tracer.Parent = workspace
        
        local light = Instance.new("PointLight")
        light.Brightness = 5
        light.Range = 10
        light.Color = Config.PrimaryColor
        light.Parent = tracer
        
        game:GetService("Debris"):AddItem(tracer, 1)
        table.insert(BulletTracers, tracer)
    end
    
    return {
        Tracers = BulletTracers,
        Cleanup = function()
            for _, tracer in pairs(BulletTracers) do
                tracer:Destroy()
            end
            BulletTracers = {}
        end
    }
end

-- ============ ESP ============
local ESPObjects = {}

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local objects = {}
    
    -- Box
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Config.PrimaryColor
    box.Thickness = 2
    box.Filled = false
    objects.Box = box
    
    -- Name
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Config.TextColor
    name.Size = 14
    name.Outline = true
    name.Text = player.Name
    objects.Name = name
    
    -- Health
    local health = Drawing.new("Text")
    health.Visible = false
    health.Color = Color3.fromRGB(0, 255, 0)
    health.Size = 12
    health.Outline = true
    objects.Health = health
    
    ESPObjects[player] = objects
end

local function UpdateESP()
    if not _G.Settings.ESP then return end
    
    for player, objects in pairs(ESPObjects) do
        local char = player.Character
        if not char then
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
            continue
        end
        
        local humanoid = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if humanoid and head and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                
                if distance <= _G.Settings.ESPMaxDistance then
                    -- Box
                    if objects.Box then
                        objects.Box.Size = Vector2.new(1000/pos.Z, 1500/pos.Z)
                        objects.Box.Position = Vector2.new(pos.X - objects.Box.Size.X/2, pos.Y - objects.Box.Size.Y/2)
                        objects.Box.Visible = true
                    end
                    
                    -- Name
                    if objects.Name then
                        objects.Name.Position = Vector2.new(pos.X, pos.Y - objects.Box.Size.Y/2 - 20)
                        objects.Name.Visible = true
                    end
                    
                    -- Health
                    if objects.Health then
                        objects.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        objects.Health.Position = Vector2.new(pos.X, pos.Y - objects.Box.Size.Y/2 - 5)
                        objects.Health.Color = Color3.fromRGB(
                            255 - (humanoid.Health/humanoid.MaxHealth * 255),
                            (humanoid.Health/humanoid.MaxHealth * 255),
                            0
                        )
                        objects.Health.Visible = true
                    end
                else
                    for _, obj in pairs(objects) do
                        obj.Visible = false
                    end
                end
            else
                for _, obj in pairs(objects) do
                    obj.Visible = false
                end
            end
        else
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
        end
    end
end

-- ============ МЕНЮ ДЛЯ ТЕЛЕФОНА ============
local function CreateMobileMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = "MobileMasterMenu"
    
    -- Главная кнопка
    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(0, 60, 0, 60)
    MainButton.Position = UDim2.new(0.95, -60, 0.9, 0)
    MainButton.BackgroundColor3 = Config.PrimaryColor
    MainButton.BackgroundTransparency = 0.3
    MainButton.Text = "⚙️"
    MainButton.TextColor3 = Config.TextColor
    MainButton.Font = Enum.Font.SourceSansBold
    MainButton.TextSize = 28
    MainButton.Parent = ScreenGui
    MainButton.ZIndex = 100
    
    -- Меню
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
    MenuFrame.Position = UDim2.new(0.6, 0, 0.25, 0)
    MenuFrame.BackgroundColor3 = Config.SecondaryColor
    MenuFrame.BackgroundTransparency = 0.1
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Config.PrimaryColor
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui
    MenuFrame.ZIndex = 99
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.08, 0)
    Title.BackgroundColor3 = Config.PrimaryColor
    Title.Text = "📱 " .. Config.ScriptName .. " v" .. Config.Version
    Title.TextColor3 = Config.TextColor
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.Parent = MenuFrame
    
    -- Закрыть
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.15, 0, 0.08, 0)
    CloseButton.Position = UDim2.new(0.85, 0, 0, 0)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Config.TextColor
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 20
    CloseButton.Parent = MenuFrame
    
    -- Список
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -10, 0.88, -40)
    ScrollingFrame.Position = UDim2.new(0, 5, 0.1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 3
    ScrollingFrame.Parent = MenuFrame
    
    local YPosition = 0
    local function AddButton(text, callback, icon)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.95, 0, 0, 40)
        button.Position = UDim2.new(0.025, 0, 0, YPosition)
        button.Text = icon .. " " .. text
        button.TextColor3 = Config.TextColor
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 14
        button.Parent = ScrollingFrame
        
        button.MouseButton1Click:Connect(callback)
        
        YPosition = YPosition + 45
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, YPosition)
        
        return button
    end
    
    local function AddToggle(text, setting, icon)
        local button = AddButton(text .. (_G.Settings[setting] and " ✅" or " ❌"), function()
            _G.Settings[setting] = not _G.Settings[setting](button.Text) = icon .. " " .. text .. (_G.Settings[setting] and " ✅" : " ❌")
            
            -- Включение/выключение функций
            if setting == "NoClip" then
                if _G.Settings.NoClip then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Noclip",
                        Text = "Включен (идти сквозь стены)",
                        Duration = 3
                    })
                end
            elseif setting == "MagicBullets" then
                if _G.Settings.MagicBullets then
                    local magic = SetupMagicBullets()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Магические пули",
                        Text = "Активированы!",
                        Duration = 3
                    })
                end
            elseif setting == "ESP" then
                if _G.Settings.ESP then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            CreateESP(player)
                        end
                    end
                    RunService.RenderStepped:Connect(UpdateESP)
                end
            end
        end, icon)
        
        return button
    end
    
    -- Добавляем функции
    AddToggle("Бесконечный прыжок", "InfiniteJump", "🦘")
    AddToggle("Ноклип", "NoClip", "👻")
    AddToggle("Ускорение (Speed)", "WalkSpeed", "⚡")
    AddToggle("Высокие прыжки", "JumpPower", "🏃")
    
    AddButton("Скорость +10", function()
        _G.Settings.WalkSpeed = _G.Settings.WalkSpeed + 10
        ApplySpeed()
    end, "➕")
    
    AddButton("Скорость -10", function()
        _G.Settings.WalkSpeed = math.max(16, _G.Settings.WalkSpeed - 10)
        ApplySpeed()
    end, "➖")
    
    AddToggle("Aimbot", "AimBot", "🎯")
    AddToggle("Магические пули", "MagicBullets", "🔮")
    AddToggle("Пули сквозь стены", "WallBang", "🧱")
    AddToggle("Самонаводящиеся", "HomingBullets", "🌀")
    AddToggle("Без отдачи", "NoRecoil", "🎪")
    AddToggle("Быстрая стрельба", "RapidFire", "🔫")
    AddToggle("Бесконечные патроны", "InfiniteAmmo", "♾️")
    
    AddToggle("ESP игроков", "ESP", "👁️")
    AddToggle("ESP имена", "ESPName", "📛")
    AddToggle("ESP здоровье", "ESPHealth", "❤️")
    
    AddToggle("Анти-AFK", "AntiAFK", "⏰")
    AddToggle("Авто-фарм", "AutoFarm", "🤖")
    AddToggle("Авто-клик", "AutoClick", "🖱️")
    
    -- Управление меню
    MainButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = false
    end)
    
    -- Drag меню
    local dragging = false
    local dragInput, dragStart, startPos
    
    MenuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MenuFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MenuFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MenuFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui
end

-- ============ ЗАГРУЗКА ============
-- Создаем меню
CreateMobileMenu()

-- Применяем начальные настройки
LocalPlayer.CharacterAdded:Connect(function()
    ApplySpeed()
    ApplyJump()
end)

if LocalPlayer.Character then
    ApplySpeed()
    ApplyJump()
end

-- Анти-AFK
if _G.Settings.AntiAFK then
    for _, v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
        v:Disable()
    end
end

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = Config.ScriptName,
    Text = "Скрипт загружен! Тапни ⚙️",
    Duration = 5,
    Icon = "rbxassetid://4483345998"
})

print("==========================================")
print("📱 " .. Config.ScriptName .. " v" .. Config.Version)
print("👤 Автор: " .. Config.Author)
print("🎮 Игра: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("✅ Функций: 18+")
print("==========================================")
