-- Services nécessaires
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local TARGET_SERVICES = {Workspace, ReplicatedStorage, Players}
local TARGET_CLASSES = {"ScreenGui", "TextBox", "RemoteEvent", "RemoteFunction", "ModuleScript"}

-- Création de l'interface graphique (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AuditDumperGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Cadre Principal (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.8, 0, 0.6, 0) -- 80% largeur, 60% hauteur
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0) -- Centré
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Titre
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Audit Dump - Client View"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Parent = mainFrame

-- Zone de texte pour le résultat (TextBox)
-- On utilise une TextBox pour permettre la copie manuelle sur Android
local resultBox = Instance.new("TextBox")
resultBox.Name = "ResultBox"
resultBox.Size = UDim2.new(0.95, 0, 0.75, 0)
resultBox.Position = UDim2.new(0.025, 0, 0.12, 0)
resultBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resultBox.TextColor3 = Color3.fromRGB(0, 255, 0) -- Texte vert style hacker
resultBox.TextXAlignment = Enum.TextXAlignment.Left
resultBox.TextYAlignment = Enum.TextYAlignment.Top
resultBox.TextSize = 14
resultBox.ClearTextOnFocus = false
resultBox.MultiLine = true
resultBox.TextWrapped = true -- Important pour les petits écrans
resultBox.Text = "Appuyez sur 'Lancer le Dump'..."
resultBox.Parent = mainFrame

-- Bouton d'Action
local dumpButton = Instance.new("TextButton")
dumpButton.Size = UDim2.new(0.4, 0, 0.1, 0)
dumpButton.Position = UDim2.new(0.05, 0, 0.88, 0)
dumpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
dumpButton.Text = "LANCER LE DUMP"
dumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dumpButton.TextScaled = true
dumpButton.Parent = mainFrame

-- Bouton Fermer
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.4, 0, 0.1, 0)
closeButton.Position = UDim2.new(0.55, 0, 0.88, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "FERMER"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Parent = mainFrame

-----------------------------------------------------------
-- LOGIQUE DU DUMP
-----------------------------------------------------------

local function getHierarchy(obj, indent)
    local result = ""
    local children = obj:GetChildren()
    
    for _, child in ipairs(children) do
        -- Vérification : On cherche soit tout, soit des classes spécifiques
        -- Ici, on filtre un peu pour ne pas faire crasher le téléphone avec trop de données
        local isInteresting = false
        
        for _, classType in ipairs(TARGET_CLASSES) do
            if child:IsA(classType) then
                isInteresting = true
                break
            end
        end
        
        -- On note aussi les dossier ou modèles pour la structure
        if child:IsA("Folder") or child:IsA("Model") then isInteresting = true end

        if isInteresting then
            result = result .. indent .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
            
            -- Récursion pour aller plus profond (Attention aux performances)
            -- On limite la profondeur si c'est un ScreenGui pour voir les boutons
            if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("Folder") then
                result = result .. getHierarchy(child, indent .. "  ")
            end
        end
    end
    return result
end

local function runDump()
    resultBox.Text = "Scan en cours... Veuillez patienter."
    task.wait(0.1) -- Laisser l'UI se mettre à jour
    
    local finalOutput = "-- DEBUT DU DUMP --\n\n"
    
    -- 1. Scan des Services Principaux
    for _, service in ipairs(TARGET_SERVICES) do
        finalOutput = finalOutput .. ">>> SERVICE: " .. service.Name .. "\n"
        finalOutput = finalOutput .. getHierarchy(service, "  ")
        finalOutput = finalOutput .. "\n"
    end
    
    -- 2. Scan spécifique des interfaces du joueur local
    finalOutput = finalOutput .. ">>> PLAYER GUI (LocalPlayer)\n"
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        finalOutput = finalOutput .. getHierarchy(LocalPlayer.PlayerGui, "  ")
    end
    
    finalOutput = finalOutput .. "\n-- FIN DU DUMP --"
    
    resultBox.Text = finalOutput
end

-- Connexions
dumpButton.MouseButton1Click:Connect(runDump)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)