-- ============================================
--   УНИВЕРСАЛЬНАЯ МИНИ-МЕНЮШКА
--   Работает в: Solara, Xeno, Real, Madium и др.
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Безопасное получение родителя для GUI (gethui есть не везде)
local function GetGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    -- fallback: CoreGui или PlayerGui
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Удаляем старую версию, если есть
local parentGui = GetGuiParent()
if parentGui:FindFirstChild("CoolMenu") then
    parentGui.CoolMenu:Destroy()
end

-- Основной ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- ================= ГЛАВНЫЙ ФРЕЙМ =================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- встроенное перетаскивание, работает почти везде
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 100)
MainStroke.Thickness = 1
MainStroke.Parent = Main

-- Градиент (UIElement, не Drawing — безопасно)
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 30, 120))
}
Gradient.Rotation = 90
Gradient.Parent = Main

-- ================= ЗАГОЛОВОК =================
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "✦ MENU ✦"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ================= КНОПКА СВЕРНУТЬ =================
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 8)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 180, 50)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = Main

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- ================= КОНТЕНТ =================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- ============ ФУНКЦИЯ СОЗДАНИЯ КНОПКИ ============
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(230, 230, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = Content

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(80, 80, 110)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(70, 50, 150)
        }):Play()
    end)

    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        }):Play()
    end)

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return Btn
end

-- ============ ФУНКЦИЯ ПЕРЕКЛЮЧАТЕЛЯ ============
local function CreateToggle(text, default, callback)
    local state = default or false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = Content

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBg.BackgroundColor3 = state and Color3.fromRGB(120, 80, 255) or Color3.fromRGB(60, 60, 70)
    SwitchBg.Text = ""
    SwitchBg.BorderSizePixel = 0
    SwitchBg.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchBg

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    SwitchBg.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(SwitchBg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(120, 80, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        pcall(callback, state)
    end)

    return Frame
end

-- ============ НАПОЛНЕНИЕ МЕНЮ ============
CreateButton("🚀 Скорость x2", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 32
    end
end)

CreateButton("🦘 Прыжок x2", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 100
    end
end)

CreateButton("❤️ Восстановить HP", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

CreateToggle("🌙 Бесконечный прыжок", false, function(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum.UseJumpPower = true
        -- Используем UserInputService, который есть везде
        _G.infjump = UserInputService.JumpRequest:Connect(function()
            if hum and hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if _G.infjump then _G.infjump:Disconnect() end
    end
end)

CreateToggle("💨 Noclip", false, function(state)
    _G.noclip = state
    if state then
        task.spawn(function()
            while _G.noclip do
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- ================= ЛОГИКА СВЕРНУТЬ / ЗАКРЫТЬ =================
local minimized = false
local originalSize = Main.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 220, 0, 40)
        Content.Visible = false
    else
        Main.Size = originalSize
        Content.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
