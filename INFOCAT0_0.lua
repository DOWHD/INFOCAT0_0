-- [[ Сервисы ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Удаление старой панели, если она была запущенна
if CoreGui:FindFirstChild("InfocatoMenu") then
    CoreGui:FindFirstChild("InfocatoMenu"):Destroy()
end

-- Основной GUI контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfocatoMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- [[ АНИМЕ ЗВУК ]]
local Audio = Instance.new("Sound")
Audio.SoundId = "rbxassetid://9114223193"
Audio.Volume = 0.9
Audio.Parent = CoreGui

local function PlayAnimeSound()
    Audio:Play()
end

-- [[ СИСТЕМА КЛЮЧЕЙ (ПАНЕЛЬ АВТОРИЗАЦИИ) ]]
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 260, 0, 140)
KeyFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner") KeyCorner.CornerRadius = UDim.new(0, 10) KeyCorner.Parent = KeyFrame
local KeyStroke = Instance.new("UIStroke") KeyStroke.Thickness = 1.5; KeyStroke.Color = Color3.fromRGB(100, 50, 200); KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "ТРЕБУЕТСЯ КЛЮЧ"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 14
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 210, 0, 32)
KeyInput.Position = UDim2.new(0.5, -105, 0, 45)
KeyInput.BackgroundColor3 = Color3.fromRGB(24, 22, 42)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Введите ключ здесь..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
KeyInput.TextColor3 = Color3.fromRGB(0, 240, 255)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.TextSize = 12
KeyInput.Parent = KeyFrame
local KIC = Instance.new("UICorner") KIC.CornerRadius = UDim.new(0, 6) KIC.Parent = KeyInput
local KIS = Instance.new("UIStroke") KIS.Color = Color3.fromRGB(40, 35, 60); KIS.Parent = KeyInput

local KeyBtn = Instance.new("TextButton")
KeyBtn.Size = UDim2.new(0, 100, 0, 32)
KeyBtn.Position = UDim2.new(0.5, -50, 0, 92)
KeyBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
KeyBtn.Text = "Войти"
KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBtn.Font = Enum.Font.GothamBold
KeyBtn.TextSize = 12
KeyBtn.Parent = KeyFrame
local KBC = Instance.new("UICorner") KBC.CornerRadius = UDim.new(0, 6) KBC.Parent = KeyBtn

-- Функция запуска основного скрипта
local function InitializeMainScript()
    KeyFrame:Destroy() -- Удаляем панель ключа
    PlayAnimeSound()

    -- [[ Настройки ]]
    local MenuOpen = false
    local FOV_Radius = 120
    local AimSmoothness = 0.15 
    local ESP_TextSize = 11
    local AimTargetPart = "Head"

    _G.Box_Enabled = false
    _G.HP_Enabled = false
    _G.Name_Enabled = false
    _G.Weapon_Enabled = false
    _G.Dist_Enabled = false
    local Aim_Enabled = false
    local AutoShot_Enabled = false

    local CurrentThemeIdx = 1
    local Themes = {
        Color3.fromRGB(100, 50, 200),
        Color3.fromRGB(0, 240, 255), 
        Color3.fromRGB(255, 40, 80), 
        Color3.fromRGB(40, 255, 120),
        Color3.fromRGB(255, 200, 0)  
    }

    local function CheckIsEnemy(p)
        if not p or p == LocalPlayer or p.Name == LocalPlayer.Name then return false end
        if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return false end
        if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor == LocalPlayer.TeamColor and p.TeamColor ~= BrickColor.new("White") then return false end
        
        local myTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side") or LocalPlayer:GetAttribute("Faction")
        local pTeamAttr = p:GetAttribute("Team") or p:GetAttribute("Side") or p:GetAttribute("Faction")
        if myTeamAttr and pTeamAttr and myTeamAttr == pTeamAttr then return false end
        
        if p:FindFirstChild("Team") or p:FindFirstChild("TeamValue") then
            local pTeamVal = p:FindFirstChild("Team") or p:FindFirstChild("TeamValue")
            local myTeamVal = LocalPlayer:FindFirstChild("Team") or LocalPlayer:FindFirstChild("TeamValue")
            if pTeamVal and myTeamVal and pTeamVal.Value == myTeamVal.Value then return false end
        end
        return true
    end

    -- [[ Главный Интерфейс Меню (УМЕНЬШЕННЫЙ И КОМПАКТНЫЙ РАЗМЕР) ]]
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 320) -- Размер значительно уменьшен
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 12) MainCorner.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke") MainStroke.Thickness = 1.5; MainStroke.Color = Themes[1]; MainStroke.Parent = MainFrame

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 0, 40)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = "INFOCATO_O"
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextSize = 18
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.Parent = MainFrame

    -- [[ Кнопка изменения размера ]]
    local ResizeBtn = Instance.new("Frame")
    ResizeBtn.Size = UDim2.new(0, 15, 0, 15)
    ResizeBtn.Position = UDim2.new(1, -15, 1, -15)
    ResizeBtn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    ResizeBtn.BackgroundTransparency = 0.4
    ResizeBtn.Active = true
    ResizeBtn.Parent = MainFrame
    local RC = Instance.new("UICorner") RC.CornerRadius = UDim.new(1, 0) RC.Parent = ResizeBtn

    local resizing = false
    local rStartPos, rStartSize
    ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; rStartPos = input.Position; rStartSize = MainFrame.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - rStartPos
            MainFrame.Size = UDim2.new(0, math.clamp(rStartSize.X.Offset + delta.X, 280, 600), 0, math.clamp(rStartSize.Y.Offset + delta.Y, 240, 500))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0, 95, 1, -55)
    LeftPanel.Position = UDim2.new(0, 10, 0, 45)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.Parent = MainFrame
    local LeftLayout = Instance.new("UIListLayout") LeftLayout.Padding = UDim.new(0, 6); LeftLayout.Parent = LeftPanel

    local ContentPanel = Instance.new("Frame")
    ContentPanel.Size = UDim2.new(1, -120, 1, -55)
    ContentPanel.Position = UDim2.new(0, 110, 0, 45)
    ContentPanel.BackgroundColor3 = Color3.fromRGB(24, 22, 42)
    ContentPanel.Parent = MainFrame
    local ContentCorner = Instance.new("UICorner") ContentCorner.CornerRadius = UDim.new(0, 10); ContentCorner.Parent = ContentPanel

    -- Скролл-панели для вкладок
    local ScrollVisuals = Instance.new("ScrollingFrame")
    ScrollVisuals.Size = UDim2.new(1, -12, 1, -12)
    ScrollVisuals.Position = UDim2.new(0, 6, 0, 6)
    ScrollVisuals.BackgroundTransparency = 1
    ScrollVisuals.CanvasSize = UDim2.new(0,0,0,320)
    ScrollVisuals.ScrollBarThickness = 2
    ScrollVisuals.ScrollBarImageColor3 = Themes[1]
    ScrollVisuals.Parent = ContentPanel

    local ScrollAim = Instance.new("ScrollingFrame")
    ScrollAim.Size = UDim2.new(1, -12, 1, -12)
    ScrollAim.Position = UDim2.new(0, 6, 0, 6)
    ScrollAim.BackgroundTransparency = 1
    ScrollAim.CanvasSize = UDim2.new(0,0,0,320)
    ScrollAim.ScrollBarThickness = 2
    ScrollAim.ScrollBarImageColor3 = Themes[1]
    ScrollAim.Visible = false
    ScrollAim.Parent = ContentPanel

    local ScrollSettings = Instance.new("ScrollingFrame")
    ScrollSettings.Size = UDim2.new(1, -12, 1, -12)
    ScrollSettings.Position = UDim2.new(0, 6, 0, 6)
    ScrollSettings.BackgroundTransparency = 1
    ScrollSettings.CanvasSize = UDim2.new(0,0,0,320)
    ScrollSettings.ScrollBarThickness = 2
    ScrollSettings.ScrollBarImageColor3 = Themes[1]
    ScrollSettings.Visible = false
    ScrollSettings.Parent = ContentPanel

    local VLayout = Instance.new("UIListLayout") VLayout.Padding = UDim.new(0, 4); VLayout.Parent = ScrollVisuals
    local ALayout = Instance.new("UIListLayout") ALayout.Padding = UDim.new(0, 4); ALayout.Parent = ScrollAim
    local SLayout = Instance.new("UIListLayout") SLayout.Padding = UDim.new(0, 8); SLayout.Parent = ScrollSettings

    -- Управление табами
    local TabButtons = {}
    local function CreateTabButton(text, isTarget)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 32)
        Btn.BackgroundColor3 = isTarget and Color3.fromRGB(35, 30, 60) or Color3.fromRGB(20, 16, 35)
        Btn.Text = text
        Btn.TextColor3 = isTarget and Themes[1] or Color3.fromRGB(150, 150, 170)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Btn.Parent = LeftPanel
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = Btn
        local s = Instance.new("UIStroke") s.Thickness = 1; s.Color = isTarget and Themes[1] or Color3.fromRGB(40, 35, 60); s.Parent = Btn
        table.insert(TabButtons, Btn)
        return Btn
    end

    local vTab = CreateTabButton("Visuals", true)
    local aTab = CreateTabButton("Aimbot", false)
    local sTab = CreateTabButton("Settings", false)

    local function SwitchTab(activeTab, activeScroll)
        PlayAnimeSound()
        ScrollVisuals.Visible = false; ScrollAim.Visible = false; ScrollSettings.Visible = false
        activeScroll.Visible = true
        
        for _, tab in pairs(TabButtons) do
            tab.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
            tab.TextColor3 = Color3.fromRGB(150, 150, 170)
            tab.UIStroke.Color = Color3.fromRGB(40, 35, 60)
        end
        activeTab.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
        activeTab.TextColor3 = Themes[CurrentThemeIdx]
        activeTab.UIStroke.Color = Themes[CurrentThemeIdx]
    end

    vTab.MouseButton1Click:Connect(function() SwitchTab(vTab, ScrollVisuals) end)
    aTab.MouseButton1Click:Connect(function() SwitchTab(aTab, ScrollAim) end)
    sTab.MouseButton1Click:Connect(function() SwitchTab(sTab, ScrollSettings) end)

    -- Конструкторы элементов интерфейса
    local function CreateCheckbox(text, parent, callback)
        local Frame = Instance.new("Frame") Frame.Size = UDim2.new(1, 0, 0, 28); Frame.BackgroundTransparency = 1; Frame.Parent = parent
        local Check = Instance.new("TextButton") Check.Size = UDim2.new(0, 16, 0, 16); Check.Position = UDim2.new(0, 4, 0.5, -8); Check.BackgroundColor3 = Color3.fromRGB(15, 12, 28); Check.Text = ""; Check.Parent = Frame
        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 4) cc.Parent = Check
        local cs = Instance.new("UIStroke") cs.Thickness = 1.2; cs.Color = Color3.fromRGB(100, 80, 150); cs.Parent = Check
        local Label = Instance.new("TextLabel") Label.Position = UDim2.new(0, 26, 0, 0); Label.Size = UDim2.new(1, -26, 1, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(200, 200, 220); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.Parent = Frame

        local active = false
        Check.MouseButton1Click:Connect(function()
            PlayAnimeSound()
            active = not active; callback(active)
            Check.Text = active and "✓" or ""
            Check.TextColor3 = active and Themes[CurrentThemeIdx] or Color3.fromRGB(255,255,255)
            Check.BackgroundColor3 = active and Color3.fromRGB(30, 50, 90) or Color3.fromRGB(15, 12, 28)
        end)
    end

    local function CreateInputField(text, parent, default, callback)
        local Frame = Instance.new("Frame") Frame.Size = UDim2.new(1, 0, 0, 32); Frame.BackgroundTransparency = 1; Frame.Parent = parent
        local Label = Instance.new("TextLabel") Label.Size = UDim2.new(0.65, 0, 1, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(180, 180, 200); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
        local Box = Instance.new("TextBox") Box.Size = UDim2.new(0, 50, 0.8, 0); Box.Position = UDim2.new(1, -55, 0.1, 0); Box.BackgroundColor3 = Color3.fromRGB(15, 12, 28); Box.Text = tostring(default); Box.TextColor3 = Color3.fromRGB(0, 240, 255); Box.Font = Enum.Font.GothamBold; Box.TextSize = 11; Box.Parent = Frame
        local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 5) bc.Parent = Box
        Box.FocusLost:Connect(function() local n = tonumber(Box.Text); if n then callback(n) else Box.Text = tostring(default) end end)
    end

    local function CreateHitboxSelector(parent)
        local Frame = Instance.new("Frame") Frame.Size = UDim2.new(1, 0, 0, 32); Frame.BackgroundTransparency = 1; Frame.Parent = parent
        local Label = Instance.new("TextLabel") Label.Size = UDim2.new(0.4, 0, 1, 0); Label.BackgroundTransparency = 1; Label.Text = "Часть тела:"; Label.TextColor3 = Color3.fromRGB(180, 180, 200); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
        local ChangeBtn = Instance.new("TextButton") ChangeBtn.Size = UDim2.new(0, 100, 0, 24); ChangeBtn.Position = UDim2.new(1, -105, 0.5, -12); ChangeBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 50); ChangeBtn.Text = "Голова"; ChangeBtn.TextColor3 = Color3.fromRGB(0, 240, 255); ChangeBtn.Font = Enum.Font.GothamBold; ChangeBtn.TextSize = 11; ChangeBtn.Parent = Frame
        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 5) cc.Parent = ChangeBtn
        local cs = Instance.new("UIStroke") cs.Color = Color3.fromRGB(100, 50, 200); cs.Parent = ChangeBtn

        local modes = {"Голова", "Грудь", "Тело", "Ноги"}
        local internalParts = {["Голова"] = "Head", ["Грудь"] = "UpperTorso", ["Тело"] = "HumanoidRootPart", ["Ноги"] = "LeftLowerLeg"}
        local currentIdx = 1
        ChangeBtn.MouseButton1Click:Connect(function()
            PlayAnimeSound(); currentIdx = currentIdx + 1; if currentIdx > #modes then currentIdx = 1 end
            ChangeBtn.Text = modes[currentIdx]; AimTargetPart = internalParts[modes[currentIdx]]
        end)
    end

    -- Наполнение вкладок
    CreateCheckbox("ВХ Коробки (Рамка)", ScrollVisuals, function(s) _G.Box_Enabled = s end)
    CreateCheckbox("ВХ Цифры ХП", ScrollVisuals, function(s) _G.HP_Enabled = s end)
    CreateCheckbox("ВХ Никнеймы", ScrollVisuals, function(s) _G.Name_Enabled = s end)
    CreateCheckbox("ВХ Название Оружия", ScrollVisuals, function(s) _G.Weapon_Enabled = s end)
    CreateCheckbox("ВХ Дистанция", ScrollVisuals, function(s) _G.Dist_Enabled = s end)
    CreateInputField("Размер текста ESP:", ScrollVisuals, ESP_TextSize, function(v) ESP_TextSize = math.clamp(v, 4, 24) end)

    CreateCheckbox("Включить Аимбот", ScrollAim, function(s) Aim_Enabled = s end)
    CreateCheckbox("Авто-Выстрел", ScrollAim, function(s) AutoShot_Enabled = s end)
    CreateInputField("Радиус Аима (FOV):", ScrollAim, FOV_Radius, function(v) FOV_Radius = math.clamp(v, 10, 600) end)
    CreateHitboxSelector(ScrollAim)

    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, 0, 0, 24)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "Настройки & Поддержка"
    InfoText.TextColor3 = Color3.fromRGB(160, 160, 180)
    InfoText.Font = Enum.Font.GothamSemibold
    InfoText.TextSize = 11
    InfoText.Parent = ScrollSettings

    local ChangeColorBtn = Instance.new("TextButton")
    ChangeColorBtn.Size = UDim2.new(1, -6, 0, 30)
    ChangeColorBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
    ChangeColorBtn.Text = "🎨 Сменить цвет меню"
    ChangeColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChangeColorBtn.Font = Enum.Font.GothamBold
    ChangeColorBtn.TextSize = 11
    ChangeColorBtn.Parent = ScrollSettings
    local ccc = Instance.new("UICorner") ccc.CornerRadius = UDim.new(0, 6) ccc.Parent = ChangeColorBtn
    local ccs = Instance.new("UIStroke") ccs.Color = Themes[1]; ccs.Thickness = 1; ccs.Parent = ChangeColorBtn

    local DonateBtn = Instance.new("TextButton")
    DonateBtn.Size = UDim2.new(1, -6, 0, 35)
    DonateBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 204)
    DonateBtn.Text = "💸 Поддержать автора денежкой"
    DonateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DonateBtn.Font = Enum.Font.GothamBold
    DonateBtn.TextSize = 11
    DonateBtn.Parent = ScrollSettings
    local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0, 6) dc.Parent = DonateBtn

    local TgBtn = Instance.new("TextButton")
    TgBtn.Size = UDim2.new(1, -6, 0, 35)
    TgBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 43)
    TgBtn.Text = "📢 Наш Telegram: t.me/stav_fast"
    TgBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
    TgBtn.Font = Enum.Font.GothamBold
    TgBtn.TextSize = 11
    TgBtn.Parent = ScrollSettings
    local tc2 = Instance.new("UICorner") tc2.CornerRadius = UDim.new(0, 6) tc2.Parent = TgBtn
    local ts2 = Instance.new("UIStroke") ts2.Color = Color3.fromRGB(0, 136, 204); ts2.Thickness = 1; ts2.Parent = TgBtn

    local function CopyLink()
        PlayAnimeSound()
        setclipboard("https://t.me/stav_fast")
        local oldText = TgBtn.Text
        TgBtn.Text = "Ссылка скопирована в буфер!"
        task.wait(2)
        TgBtn.Text = oldText
    end
    DonateBtn.MouseButton1Click:Connect(CopyLink)
    TgBtn.MouseButton1Click:Connect(CopyLink)

    -- [[ КНОПКА МЕНЮ (КРУГЛЯШОК ИЗ ТВОЕГО СКРИНШОТА) ]]
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 120) 
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    ToggleBtn.Text = "MENU"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.Active = true
    ToggleBtn.Parent = ScreenGui

    local tcc = Instance.new("UICorner") tcc.CornerRadius = UDim.new(1,0) tcc.Parent = ToggleBtn
    local tss = Instance.new("UIStroke") tss.Color = Themes[1]; tss.Thickness = 1.5; tss.Parent = ToggleBtn

    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        PlayAnimeSound()
        MainFrame.Visible = MenuOpen
    end)

    ChangeColorBtn.MouseButton1Click:Connect(function()
        PlayAnimeSound()
        CurrentThemeIdx = CurrentThemeIdx + 1
        if CurrentThemeIdx > #Themes then CurrentThemeIdx = 1 end
        
        local newColor = Themes[CurrentThemeIdx]
        MainStroke.Color = newColor
        tss.Color = newColor
        ccs.Color = newColor
        ToggleBtn.TextColor3 = newColor
        vTab.TextColor3 = newColor
        ScrollVisuals.ScrollBarImageColor3 = newColor
        ScrollAim.ScrollBarImageColor3 = newColor
        ScrollSettings.ScrollBarImageColor3 = newColor
    end)

    local function IsBehindWall(targetPart)
        if not targetPart or not LocalPlayer.Character then return true end
        local ignoreList = {LocalPlayer.Character, Camera}
        for _, p in pairs(Players:GetPlayers()) do if p.Character and not CheckIsEnemy(p) then table.insert(ignoreList, p.Character) end end
        return #Camera:GetPartsObscuringTarget({targetPart.Position}, ignoreList) > 0
    end

    -- [[ ИСПРАВЛЕННЫЙ СКАНЕР ХП И ОРУЖИЯ ]]
    local function GetAdvancedHealthAndWeapon(player, hum)
        local char = player.Character
        if not char then return 0, 100, "" end

        local curH, maxH = 100, 100
        local weaponText = ""

        for _, obj in pairs(char:GetDescendants()) do
            if (obj.Name == "Health" or obj.Name == "HP" or obj.Name == "HealthValue") and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                curH = obj.Value
                maxH = (char:FindFirstChild("MaxHealth") and char.MaxHealth.Value or 100)
                break
            end
        end
        
        local head = char:FindFirstChild("Head")
        if head and curH == 100 then
            for _, bGui in pairs(head:GetChildren()) do
                if bGui:IsA("BillboardGui") then
                    local bar = bGui:FindFirstChild("Bar", true) or bGui:FindFirstChild("Health", true)
                    if bar and bar:IsA("Frame") and bar.Size.X.Scale then
                        curH = bar.Size.X.Scale * 100
                    end
                end
            end
        end

        if hum and curH == 100 then
            curH, maxH = hum.Health, hum.MaxHealth
        end

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            weaponText = tool.Name
        else
            for _, obj in pairs(char:GetDescendants()) do
                if obj:IsA("Tool") or (obj:IsA("StringValue") and (obj.Name:find("Weapon") or obj.Name:find("Gun") or obj.Name == "CurrentGun")) then
                    weaponText = obj.Name
                    break
                end
            end
        end

        return curH, maxH, weaponText
    end

    -- [[ ВХ РЕНДЕР ]]
    local function ApplyESP(player)
        local function SetupCharacter(char)
            if not char then return end
            local root = char:WaitForChild("HumanoidRootPart", 10)
            local hum = char:WaitForChild("Humanoid", 10)
            if not root or not hum then return end
            
            if char:FindFirstChild("DeltaCustomESP") then char:FindFirstChild("DeltaCustomESP"):Destroy() end

            local container = Instance.new("Folder")
            container.Name = "DeltaCustomESP"
            container.Parent = char

            local bGui = Instance.new("BillboardGui", container)
            bGui.AlwaysOnTop = true; bGui.Size = UDim2.new(4.5, 0, 6.0, 0); bGui.Adornee = root
            local boxF = Instance.new("Frame", bGui) boxF.Size = UDim2.new(1,0,1,0); boxF.BackgroundTransparency = 1
            local bs = Instance.new("UIStroke", boxF) bs.Thickness = 1.5; bs.Color = Color3.fromRGB(255, 40, 80)

            local hpGui = Instance.new("BillboardGui", container)
            hpGui.AlwaysOnTop = true; hpGui.Size = UDim2.new(0, 90, 0, 20); hpGui.StudsOffset = Vector3.new(-3.0, 0, 0); hpGui.Adornee = root
            local hpL = Instance.new("TextLabel", hpGui) hpL.Size = UDim2.new(1,0,1,0); hpL.BackgroundTransparency = 1; hpL.Font = Enum.Font.GothamBold; Instance.new("UIStroke", hpL).Color = Color3.fromRGB(0,0,0)

            local topGui = Instance.new("BillboardGui", container)
            topGui.AlwaysOnTop = true; topGui.Size = UDim2.new(0, 180, 0, 20); topGui.StudsOffset = Vector3.new(0, 3.2, 0); topGui.Adornee = root
            local nameL = Instance.new("TextLabel", topGui) nameL.Size = UDim2.new(1,0,1,0); nameL.BackgroundTransparency = 1; nameL.TextColor3 = Color3.fromRGB(255,255,255); nameL.Font = Enum.Font.GothamBold; Instance.new("UIStroke", nameL).Color = Color3.fromRGB(0,0,0)

            local botGui = Instance.new("BillboardGui", container)
            botGui.AlwaysOnTop = true; botGui.Size = UDim2.new(0, 180, 0, 20); botGui.StudsOffset = Vector3.new(0, -3.4, 0); botGui.Adornee = root
            local toolL = Instance.new("TextLabel", botGui) toolL.Size = UDim2.new(1,0,1,0); toolL.BackgroundTransparency = 1; toolL.TextColor3 = Color3.fromRGB(0, 230, 255); toolL.Font = Enum.Font.GothamBold; Instance.new("UIStroke", toolL).Color = Color3.fromRGB(0,0,0)

            local connection
            connection = RunService.Heartbeat:Connect(function()
                if pcall(function() return char.Parent and container.Parent and root.Parent end) == false then
                    connection:Disconnect(); return
                end

                local isEnemy = CheckIsEnemy(player)
                local currentHp, maxHp, weaponName = GetAdvancedHealthAndWeapon(player, hum)

                if currentHp <= 0 or not isEnemy then
                    boxF.Visible = false; hpL.Visible = false; nameL.Visible = false; toolL.Visible = false; return
                end

                boxF.Visible = (_G.Box_Enabled and isEnemy)
                hpL.Visible = (_G.HP_Enabled and isEnemy)
                nameL.Visible = ((_G.Name_Enabled or _G.Dist_Enabled) and isEnemy)
                toolL.Visible = (_G.Weapon_Enabled and isEnemy)

                hpL.TextSize = ESP_TextSize; nameL.TextSize = ESP_TextSize; toolL.TextSize = ESP_TextSize

                pcall(function()
                    if hpL.Visible then
                        hpL.Text = math.floor(currentHp) .. " HP"
                        local r = math.clamp(currentHp / maxHp, 0, 1)
                        hpL.TextColor3 = Color3.fromRGB(255 * (1-r), 255 * r, 0)
                    end
                    if nameL.Visible then
                        local distText = ""
                        if _G.Dist_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            distText = " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                        end
                        nameL.Text = _G.Name_Enabled and (player.Name .. distText) or distText
                    end
                    if toolL.Visible then
                        toolL.Text = (weaponName ~= "") and ("⚔️ " .. weaponName) or "⚔️ None"
                    end
                end)
            end)
        end
        if player.Character then SetupCharacter(player.Character) end
        player.CharacterAdded:Connect(SetupCharacter)
    end

    for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
    Players.PlayerAdded:Connect(ApplyESP)

    -- [[ АИМБОТ ]]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5; FOVCircle.Color = Color3.fromRGB(0, 240, 255); FOVCircle.Filled = false

    RunService.RenderStepped:Connect(function()
        local screenSize = Camera.ViewportSize
        local centerScreen = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        FOVCircle.Radius = FOV_Radius; FOVCircle.Position = centerScreen; FOVCircle.Visible = Aim_Enabled
        
        if Aim_Enabled and LocalPlayer.Character then
            local maxDist = FOV_Radius
            local targetPart = nil
            
            for _, p in pairs(Players:GetPlayers()) do
                if CheckIsEnemy(p) and p.Character then
                    local currentHp = GetAdvancedHealthAndWeapon(p, p.Character:FindFirstChild("Humanoid"))
                    if currentHp > 0 then
                        local part = p.Character:FindFirstChild(AimTargetPart)
                        if not part then
                            if AimTargetPart == "UpperTorso" then part = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("Chest") end
                            if AimTargetPart == "LeftLowerLeg" then part = p.Character:FindFirstChild("LeftLeg") or p.Character:FindFirstChild("Left Leg") end
                        end
                        part = part or p.Character:FindFirstChild("HumanoidRootPart")
                        
                        if part and not IsBehindWall(part) then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                                if dist < maxDist then maxDist = dist; targetPart = part end
                            end
                        end
                    end
                end
            end
            if targetPart then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), AimSmoothness)
                if AutoShot_Enabled and LocalPlayer.Character:FindFirstChildOfClass("Tool") then LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate() end
            end
        end
    end)
end

-- [[ Обработка нажатия кнопки войти ]]
KeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "dayday-money" then
        InitializeMainScript()
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
        KeyInput.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        KeyInput.PlaceholderText = "Введите ключ здесь..."
        KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    end
end)
