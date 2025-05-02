local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    localPlayer = Players.PlayerAdded:Wait()
end

-- Configurações do ESP
local ESP_COLOR = Color3.new(1, 0, 0) -- Cor vermelha
local ESP_FILL_TRANSPARENCY = 0.8 -- Transparência do preenchimento
local ESP_OUTLINE_TRANSPARENCY = 0 -- Sem transparência no contorno
local UPDATE_INTERVAL = 1 -- Atualizar a cada 1 segundo

local function createESP(character)
    -- Remove ESP antigo se existir
    local oldESP = character:FindFirstChild("WallHackESP")
    if oldESP then
        oldESP:Destroy()
    end

    -- Cria novo ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "WallHackESP"
    highlight.FillTransparency = ESP_FILL_TRANSPARENCY
    highlight.OutlineTransparency = ESP_OUTLINE_TRANSPARENCY
    highlight.OutlineColor = ESP_COLOR
    highlight.FillColor = ESP_COLOR
    highlight.Parent = character
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            createESP(player.Character)
        end
    end
end

-- Atualiza periodicamente
local lastUpdate = 0
RunService.Heartbeat:Connect(function(deltaTime)
    lastUpdate = lastUpdate + deltaTime
    if lastUpdate >= UPDATE_INTERVAL then
        lastUpdate = 0
        updateESP()
    end
end)

-- Aplica ESP quando um jogador entra no jogo
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= localPlayer then
            createESP(character)
        end
    end)
end)

-- Aplica ESP nos jogadores existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer and player.Character then
        createESP(player.Character)
    end
end

-- Limpa quando o script é desativado
script.Destroying:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("WallHackESP")
            if esp then
                esp:Destroy()
            end
        end
    end
end)
