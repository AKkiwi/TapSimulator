-- Services nécessaires
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local TARGET_SERVICES = {Workspace, ReplicatedStorage, Players}
local TARGET_CLASSES = {"ScreenGui", "TextBox", "RemoteEvent", "RemoteFunction", "ModuleScript", "LocalScript"}

-- Création de l'interface graphique (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AuditDumperGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Cadre Principal (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
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

-- Zone de texte pour le résultat
local resultBox = Instance.new("TextBox")
resultBox.Name = "ResultBox"
resultBox.Size = UDim2.new(0.95, 0, 0.75, 0)
resultBox.Position = UDim2.new(0.025, 0, 0.12, 0)
resultBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resultBox.TextColor3 = Color3.fromRGB(0, 255, 0)
resultBox.TextXAlignment = Enum.TextXAlignment.Left
resultBox.TextYAlignment = Enum.TextYAlignment.Top
resultBox.TextSize = 14
resultBox.ClearTextOnFocus = false
resultBox.MultiLine = true
resultBox.TextWrapped = true 
resultBox.Text = "Appuyez sur 'Lancer le Dump'..."
resultBox.Parent = mainFrame

-----------------------------------------------------------
-- LES BOUTONS (Même logique pour tous)
-----------------------------------------------------------

-- 1. Bouton LANCER (Gauche)
local dumpButton = Instance.new("TextButton")
dumpButton.Name = "DumpButton"
dumpButton.Size = UDim2.new(0.3, 0, 0.1, 0)
dumpButton.Position = UDim2.new(0.025, 0, 0.88, 0)
dumpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
dumpButton.BorderSizePixel = 0
dumpButton.Text = "LANCER"
dumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dumpButton.TextScaled = true
dumpButton.Parent = mainFrame

-- 2. Bouton COPIER (Milieu)
local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(0.3, 0, 0.1, 0)
copyButton.Position = UDim2.new(0.35, 0, 0.88, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
copyButton.BorderSizePixel = 0
copyButton.Text = "COPIER TOUT"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.TextScaled = true
copyButton.Parent = mainFrame

-- 3. Bouton FERMER (Droite)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
closeButton.Position = UDim2.new(0.675, 0, 0.88, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
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
        local isInteresting = false
        for _, classType in ipairs(TARGET_CLASSES) do
            if child:IsA(classType) then
                isInteresting = true
                break
            end
        end
        if child:IsA("Folder") or child:IsA("Model") then isInteresting = true end

        if isInteresting then
            result = result .. indent .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
            if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("Folder") then
                result = result .. getHierarchy(child, indent .. "  ")
            end
        end
    end
    return result
end

local function runDump()
    resultBox.Text = "Scan en cours..."
    task.wait(0.1)
    
    local finalOutput = "-- DEBUT DU DUMP --\n\n"
    
    for _, service in ipairs(TARGET_SERVICES) do
        finalOutput = finalOutput .. ">>> SERVICE: " .. service.Name .. "\n"
        finalOutput = finalOutput .. getHierarchy(service, "  ")
        finalOutput = finalOutput .. "\n"
    end
    
    finalOutput = finalOutput .. ">>> PLAYER GUI\n"
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        finalOutput = finalOutput .. getHierarchy(LocalPlayer.PlayerGui, "  ")
    end
    
    finalOutput = finalOutput .. "\n-- FIN DU DUMP --"
    resultBox.Text = finalOutput
end

-----------------------------------------------------------
-- LOGIQUE COPIER (Safe & Unsafe)
-----------------------------------------------------------

local function copyText()
    local textToCopy = resultBox.Text
    local success = false
    
    -- Méthode 1 : Essai avec fonction d'injecteur (setclipboard)
    -- Utile si tu testes avec des outils de triche pour l'audit
    pcall(function()
        if setclipboard then
            setclipboard(textToCopy)
            copyButton.Text = "COPIÉ !"
            success = true
            task.wait(1)
            copyButton.Text = "COPIER TOUT"
        end
    end)
    
    -- Méthode 2 : Fallback Standard Roblox (Selection)
    if not success then
        resultBox:CaptureFocus() -- Force le focus sur la boite
        resultBox.CursorPosition = #resultBox.Text + 1 -- Met le curseur à la fin
        resultBox.SelectionStart = 1 -- Sélectionne depuis le début
        -- Sur Android, cela devrait surligner tout le texte.
        -- L'utilisateur n'a plus qu'à taper "Copier" sur son clavier.
    end
end

-- Connexions
dumpButton.MouseButton1Click:Connect(runDump)
copyButton.MouseButton1Click:Connect(copyText)
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)