--[[ 
 UNIVERSAL FPS AIMBOT + ESP + MENU 
 Menu: J | Aimbot: X (segure direito) | ESP: C (inimigos em vermelho)
 Feito para funcionar em FPS customizados (ex: Gun Grounds FFA)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Detecta inimigo: tenta por Team, TeamColor, senão marca todo mundo menos você
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team ~= LocalPlayer.Team then return true end
    if player.TeamColor and LocalPlayer.TeamColor and player.TeamColor ~= LocalPlayer.TeamColor then return true end
    -- Se não há times, considera todos menos você como inimigos
    if not player.Team and not player.TeamColor then return true end
    return false
end

-- Tenta buscar partes válidas da cabeça (Head, UpperTorso, Torso, Body)
local function getHead(character)
    local possible = {"Head", "head", "UpperTorso", "Torso", "Body", "body", "Main", "MainPart"}
    for _,name in ipairs(possible) do
        if character:FindFirstChild(name) then return character[name] end
    end
    -- Procura primeiro BasePart
    for _,v in ipairs(character:GetChildren()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

-- Tenta buscar partes do corpo para ESP (todas BasePart exceto HumanoidRootPart)
local function getBodyParts(character)
    local parts = {}
    for _,v in ipairs(character:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            table.insert(parts, v)
        end
    end
    return parts
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalFPSAimbotESP"
pcall(function() ScreenGui.Parent = gethui and gethui() or game.CoreGui end)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,240,0,180)
MainFrame.Position = UDim2.new(0,50,0,80)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,32)
Title.BackgroundColor3 = Color3.fromRGB(60,60,80)
Title.Text = "UNIVERSAL FPS Aimbot & ESP"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local MinButton = Instance.new("TextButton", MainFrame)
MinButton.Size = UDim2.new(0,32,0,32)
MinButton.Position = UDim2.new(1,-32,0,0)
MinButton.BackgroundColor3 = Color3.fromRGB(40,40,70)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.new(1,1,1)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 20

local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0,140,0,32)
OpenButton.Position = UDim2.new(0,50,0,80)
OpenButton.BackgroundColor3 = Color3.fromRGB(60,60,80)
OpenButton.Text = "Abrir Menu (J)"
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 15
OpenButton.Visible = false

local AimbotToggle = Instance.new("TextButton", MainFrame)
AimbotToggle.Size = UDim2.new(1,-40,0,40)
AimbotToggle.Position = UDim2.new(0,20,0,48)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
AimbotToggle.Text = "Aimbot: OFF [X]"
AimbotToggle.TextColor3 = Color3.new(1,1,1)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 16

local ESPToggle = Instance.new("TextButton", MainFrame)
ESPToggle.Size = UDim2.new(1,-40,0,40)
ESPToggle.Position = UDim2.new(0,20,0,98)
ESPToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
ESPToggle.Text = "ESP: OFF [C]"
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.TextSize = 16

-- Variáveis
local AimbotON = false
local ESPON = false
local ESPBoxes = {}

local function updateAimbotButton()
    AimbotToggle.Text = "Aimbot: " .. (AimbotON and "ON" or "OFF") .. " [X]"
    AimbotToggle.BackgroundColor3 = AimbotON and Color3.fromRGB(0,200,50) or Color3.fromRGB(80,80,120)
end
local function updateESPButton()
    ESPToggle.Text = "ESP: " .. (ESPON and "ON" or "OFF") .. " [C]"
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
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.J then
        setMenuVisible(not MainFrame.Visible)
    elseif input.KeyCode == Enum.KeyCode.X then
        AimbotON = not AimbotON
        updateAimbotButton()
    elseif input.KeyCode == Enum.KeyCode.C then
        ESPON = not ESPON
        updateESPButton()
        if not ESPON then
            for _,boxes in pairs(ESPBoxes) do for _,v in pairs(boxes) do if v then v:Destroy() end end end
            ESPBoxes = {}
        end
    end
end)

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotON = not AimbotON
    updateAimbotButton()
end)
ESPToggle.MouseButton1Click:Connect(function()
    ESPON = not ESPON
    updateESPButton()
    if not ESPON then
        for _,boxes in pairs(ESPBoxes) do for _,v in pairs(boxes) do if v then v:Destroy() end end end
        ESPBoxes = {}
    end
end)

-- ESP: caixa vermelha no boneco inteiro e nome em vermelho
function CriarESP(player)
    if player == LocalPlayer or not isEnemy(player) then 
        if ESPBoxes[player] then
            for _,v in pairs(ESPBoxes[player]) do if v then v:Destroy() end end
            ESPBoxes[player] = nil
        end
        return
    end
    local char = player.Character
    if not char then return end
    if not ESPBoxes[player] then ESPBoxes[player] = {} end
    -- Caixa vermelha em cada parte do corpo
    for _,part in ipairs(getBodyParts(char)) do
        if not ESPBoxes[player][part] then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPBox"
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size
            box.Color3 = Color3.fromRGB(255,0,0)
            box.Transparency = 0.7
            box.Parent = part
            ESPBoxes[player][part] = box
        end
    end
    -- Nome acima da cabeça
    local head = getHead(char)
    if head and not ESPBoxes[player].NameGui then
        local gui = Instance.new("BillboardGui")
        gui.Adornee = head
        gui.Size = UDim2.new(0,100,0,30)
        gui.AlwaysOnTop = true
        local label = Instance.new("TextLabel", gui)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255,0,0)
        label.TextStrokeTransparency = 0.6
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        gui.Parent = head
        ESPBoxes[player].NameGui = gui
    end
end
function RemoverESP(player)
    if ESPBoxes[player] then
        for _,v in pairs(ESPBoxes[player]) do
            if v and typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
        end
        ESPBoxes[player] = nil
    end
end

-- Aim no inimigo mais próximo ao mouse
function JogadorMaisProximo()
    local prox, dist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) and p.Character then
            local head = getHead(p.Character)
            if head then
                local pos, onscreen = Camera:WorldToViewportPoint(head.Position)
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
    end
    return prox
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    if ESPON then
        for _,p in ipairs(Players:GetPlayers()) do
            pcall(function() CriarESP(p) end)
        end
    end
    -- Limpa ESP de quem saiu/morreu/não é inimigo
    for p,_ in pairs(ESPBoxes) do
        if not p or not p.Parent or not p.Character or not getHead(p.Character) or not isEnemy(p) then
            RemoverESP(p)
        end
    end
    -- Aimbot
    if AimbotON and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local alvo = JogadorMaisProximo()
        if alvo and alvo.Character then
            local head = getHead(alvo.Character)
            if head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            end
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

updateAimbotButton()
updateESPButton()
