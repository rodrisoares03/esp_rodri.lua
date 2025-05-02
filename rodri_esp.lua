local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Configurações otimizadas para Big Paintball
local ESP_CONFIG = {
    Color = Color3.fromRGB(255, 50, 50),
    FillTransparency = 0.7,
    OutlineColor = Color3.new(1, 1, 1),
    TextSize = 11,
    TextOffset = Vector3.new(0, 2.5, 0),
    RefreshRate = 0.3,
    MaxDistance = 2000,
    RecheckDelay = 1.5 -- Tempo para verificar personagens desaparecidos
}

-- Sistema de cache avançado
local ESPStore = {
    Active = {},
    Pending = {},
    Connections = {}
}

-- Função para criar ESP persistente
local function createPersistentESP(player)
    if player == localPlayer then return end

    local function applyESP(character)
        if not character or ESPStore.Active[character] then return end

        -- Criação do highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "PaintballESP_"..player.UserId
        highlight.FillColor = ESP_CONFIG.Color
        highlight.OutlineColor = ESP_CONFIG.OutlineColor
        highlight.FillTransparency = ESP_CONFIG.FillTransparency
        highlight.OutlineTransparency = 0

        -- Criação do billboard
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PaintballESPInfo"
        billboard.Size = UDim2.new(4, 0, 1.2, 0)
        billboard.StudsOffset = ESP_CONFIG.TextOffset
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = ESP_CONFIG.MaxDistance

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = player.Name
        textLabel.TextColor3 = ESP_CONFIG.Color
        textLabel.TextSize = ESP_CONFIG.TextSize
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextStrokeTransparency = 0.4
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Parent = billboard

        -- Sistema de verificação contínua
        local checkConnection
        local function verifyExistence()
            if not character.Parent then
                highlight.Enabled = false
                billboard.Enabled = false
                ESPStore.Pending[character] = true
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                highlight.Enabled = false
                billboard.Enabled = false
                ESPStore.Pending[character] = true
                return
            end

            highlight.Enabled = true
            billboard.Enabled = true
            ESPStore.Pending[character] = nil
        end

        checkConnection = RunService.Heartbeat:Connect(verifyExistence)

        -- Armazenamento
        ESPStore.Active[character] = {
            Highlight = highlight,
            Billboard = billboard,
            Connection = checkConnection,
            LastValidPosition = character:GetPivot().Position
        }

        -- Parenteamento
        highlight.Parent = character
        billboard.Parent = character:WaitForChild("Head", 5) or character:WaitForChild("UpperTorso", 5) or character.PrimaryPart or character

        -- Conexão para limpeza
        ESPStore.Connections[character] = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                ESPStore.Pending[character] = true
            end
        end)
    end

    -- Monitorar personagem atual
    if player.Character then
        applyESP(player.Character)
    end

    -- Monitorar novos personagens
    ESPStore.Connections[player] = player.CharacterAdded:Connect(applyESP)
end

-- Sistema de recuperação de ESPs perdidos
local function recoverMissingESP()
    for character, data in pairs(ESPStore.Active) do
        if not character:IsDescendantOf(workspace) then
            ESPStore.Pending[character] = true
        end
    end

    for character, _ in pairs(ESPStore.Pending) do
        if ESPStore.Active[character] then
            for _, v in pairs(ESPStore.Active[character]) do
                if typeof(v) == "RBXScriptConnection" then
                    v:Disconnect()
                elseif v:IsA("Instance") then
                    v:Destroy()
                end
            end
            ESPStore.Active[character] = nil
        end
    end
end

-- Atualizador principal
local function updateESP()
    -- Verificar jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if not ESPStore.Connections[player] and player ~= localPlayer then
            createPersistentESP(player)
        end
    end

    -- Tentar recuperar ESPs perdidos
    recoverMissingESP()
end

-- Inicialização
for _, player in ipairs(Players:GetPlayers()) do
    createPersistentESP(player)
end

Players.PlayerAdded:Connect(createPersistentESP)
Players.PlayerRemoving:Connect(function(player)
    if player.Character and ESPStore.Active[player.Character] then
        for _, v in pairs(ESPStore.Active[player.Character]) do
            if typeof(v) == "RBXScriptConnection" then
                v:Disconnect()
            elseif v:IsA("Instance") then
                v:Destroy()
            end
        end
        ESPStore.Active[player.Character] = nil
    end
    if ESPStore.Connections[player] then
        ESPStore.Connections[player]:Disconnect()
        ESPStore.Connections[player] = nil
    end
end)

-- Loop de atualização
local updateInterval = 0
RunService.Heartbeat:Connect(function(delta)
    updateInterval = updateInterval + delta
    if updateInterval >= ESP_CONFIG.RefreshRate then
        updateInterval = 0
        updateESP()
    end
end)

-- Sistema de limpeza
local function cleanUp()
    for character, data in pairs(ESPStore.Active) do
        for _, v in pairs(data) do
            if typeof(v) == "RBXScriptConnection" then
                v:Disconnect()
            elseif v:IsA("Instance") then
                v:Destroy()
            end
        end
    end

    for _, conn in pairs(ESPStore.Connections) do
        conn:Disconnect()
    end

    table.clear(ESPStore.Active)
    table.clear(ESPStore.Pending)
    table.clear(ESPStore.Connections)
end

script.Destroying:Connect(cleanUp)
