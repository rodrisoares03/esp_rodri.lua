local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TudoEmUmGui"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,240,0,180)
MainFrame.Position = UDim2.new(0,50,0,80)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1,0,0,32)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = Color3.fromRGB(60,60,80)
Title.Text = "Aimbot & ESP"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BorderSizePixel = 0

local MinButton = Instance.new("TextButton")
MinButton.Parent = MainFrame
MinButton.Size = UDim2.new(0,32,0,32)
MinButton.Position = UDim2.new(1,-32,0,0)
MinButton.BackgroundColor3 = Color3.fromRGB(40,40,70)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255,255,255)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 20
MinButton.BorderSizePixel = 0

local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,120,0,32)
OpenButton.Position = UDim2.new(0,50,0,80)
OpenButton.BackgroundColor3 = Color3.fromRGB(60,60,80)
OpenButton.Text = "Abrir Aimbot&ESP"
OpenButton.TextColor3 = Color3.fromRGB(255,255,255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 15
OpenButton.Visible = false
OpenButton.BorderSizePixel = 0

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Parent = MainFrame
AimbotToggle.Size = UDim2.new(1,-40,0,40)
AimbotToggle.Position = UDim2.new(0,20,0,48)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
AimbotToggle.Text = "Aimbot: OFF [X]"
AimbotToggle.TextColor3 = Color3.fromRGB(255,255,255)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 16
AimbotToggle.BorderSizePixel = 0

local ESPToggle = Instance.new("TextButton")
ESPToggle.Parent = MainFrame
ESPToggle.Size = UDim2.new(1,-40,0,40)
ESPToggle.Position = UDim2.new(0,20,0,98)
ESPToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
ESPToggle.Text = "ESP: OFF [Z]"
ESPToggle.TextColor3 = Color3.fromRGB(255,255,255)
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.TextSize = 16
ESPToggle.BorderSizePixel = 0

-- Variáveis
local AimbotON = false
local ESPON = false
local ESPBoxes = {}

-- Funções auxiliares
local function updateAimbotButton()
    AimbotToggle.Text = "Aimbot: " .. (AimbotON and "ON" or "OFF") .. " [X]"
    AimbotToggle.BackgroundColor3 = AimbotON and Color3.fromRGB(0,200,50) or Color3.fromRGB(80,80,120)
end
local function updateESPButton()
    ESPToggle.Text = "ESP: " .. (ESPON and "ON" or "OFF") .. " [Z]"
    ESPToggle.BackgroundColor3 = ESPON and Color3.fromRGB(0,200,50) or Color3.fromRGB(80,80,120)
end

-- Minimizar/restaurar
local function setMenuVisible(state)
    MainFrame.Visible = state
    OpenButton.Visible = not state
end
MinButton.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)
OpenButton.MouseButton1Click:Connect(function()
    setMenuVisible(true)
end)

-- Atalhos do teclado
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.J then
        setMenuVisible(not MainFrame.Visible)
    elseif input.KeyCode == Enum.KeyCode.X then
        AimbotON = not AimbotON
        updateAimbotButton()
    elseif input.KeyCode == Enum.KeyCode.Z then
        ESPON = not ESPON
        updateESPButton()
        if not ESPON then
            for _,v in pairs(ESPBoxes) do if v then v:Destroy() end end
            ESPBoxes = {}
        end
    end
end)

-- Toggle Aimbot/ESP pelos botões
AimbotToggle.MouseButton1Click:Connect(function()
    AimbotON = not AimbotON
    updateAimbotButton()
end)
ESPToggle.MouseButton1Click:Connect(function()
    ESPON = not ESPON
    updateESPButton()
    if not ESPON then
        for _,v in pairs(ESPBoxes) do if v then v:Destroy() end end
        ESPBoxes = {}
    end
end)

-- Função ESP aprimorada usando Highlight (wallhack)
function CriarESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    -- Remove highlights antigos se o personagem mudou
    if ESPBoxes[player] then
        if ESPBoxes[player].Adornee ~= char then
            ESPBoxes[player]:Destroy()
            ESPBoxes[player] = nil
        end
    end
    
    -- Cria o Highlight se não existir ainda
    if not ESPBoxes[player] and char then
        local highlight = Instance.new("Highlight", ScreenGui)
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Vermelho
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.2 -- Mais visível
        highlight.OutlineTransparency = 0 -- Contorno branco
        ESPBoxes[player] = highlight
    end
end

-- Função Aimbot
function JogadorMaisProximo()
    local prox, dist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onscreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onscreen then
                local mousePos = UIS:GetMouseLocation()
                local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if d < dist and d < 200 then
                    prox = p
                    dist = d
                end
            end
        end
    end
    return prox
end

-- Loops
RunService.RenderStepped:Connect(function()
    -- ESP
    if ESPON then
        for _,p in ipairs(Players:GetPlayers()) do
            pcall(function() CriarESP(p) end)
        end
    end
    -- Remove ESP de quem saiu/morreu
    for p,esp in pairs(ESPBoxes) do
        if not p or not p.Parent or not p.Character then
            if esp then esp:Destroy() end
            ESPBoxes[p] = nil
        end
    end
    -- Aimbot
    if AimbotON and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local alvo = JogadorMaisProximo()
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, alvo.Character.Head.Position)
        end
    end
end)

-- Arrastar a janela
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
Title.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Inicialização dos botões
updateAimbotButton()
updateESPButton()
