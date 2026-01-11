local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- Création de l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExploitVisualizer"
screenGui.Parent = LP.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Pour pouvoir la déplacer sur l'écran
mainFrame.Parent = screenGui

-- Ajout d'un arrondi (UICorner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "AUDIT : EXPLOIT SIMULATOR"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextSize = 18
title.Font = Enum.Font.Code
title.Parent = mainFrame

local function createBtn(name, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = mainFrame
    
    local bCorner = Instance.new("UICorner")
    bCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- LOGIQUE DES BOUTONS (Basée sur tes résultats d'audit)

-- 1. Simulation Pack Gratuit
createBtn("EXPLOIT : Free Forever Pack", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(180, 130, 0), function()
    print("Tentative d'exploitation de ForeverPack...")
    if RS:FindFirstChild("ForeverPackClaim") then
        RS.ForeverPackClaim:FireServer(1) 
        print("Requête envoyée pour l'item ID: 1")
    else
        warn("Remote non trouvée !")
    end
end)

-- 2. Simulation Kill All (PetAttack)
createBtn("EXPLOIT : Remote Kill-All", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(150, 0, 0), function()
    print("Injection PetAttackEvent...")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent.Name ~= LP.Name then
            RS.PetAttackEvent:FireServer(obj.Parent)
        end
    end
end)

-- 3. Simulation Admin Bypass
createBtn("CHECK : Cmdr Admin Access", UDim2.new(0.05, 0, 0.5, 0), Color3.fromRGB(0, 100, 200), function()
    if RS:FindFirstChild("CmdrClient") then
        local res = RS.CmdrClient.CmdrFunction:InvokeServer("help")
        print("Réponse Cmdr : Access Granted (Vulnerable)")
    end
end)

-- Bouton de fermeture
local close = createBtn("FERMER L'AUDIT", UDim2.new(0.05, 0, 0.8, 0), Color3.fromRGB(50, 50, 50), function()
    screenGui:Destroy()
end)

print("Interface d'audit chargée.")