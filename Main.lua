-- ============================================
-- AUDIT DUMPER - Version Optimisée
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================

local CONFIG = {
    services = {Workspace, ReplicatedStorage, Players},
    classes = {"ScreenGui", "TextBox", "RemoteEvent", "RemoteFunction", "ModuleScript", "LocalScript", "Folder", "Model"}
}

-- ============================================
-- STOCKAGE DES DONNÉES
-- ============================================

local dumpData = {}

-- ============================================
-- CRÉATION GUI
-- ============================================

local function createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "AuditDumper"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.7, 0)
    frame.Position = UDim2.new(0.1, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    -- Coins arrondis
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "?? AUDIT DUMPER"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame
    
    -- Zone de résultats (ScrollingFrame au lieu de TextBox)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -120)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = frame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 4)
    scrollCorner.Parent = scrollFrame
    
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Name = "ResultLabel"
    resultLabel.Size = UDim2.new(1, -10, 1, 0)
    resultLabel.Position = UDim2.new(0, 5, 0, 0)
    resultLabel.BackgroundTransparency = 1
    resultLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    resultLabel.Font = Enum.Font.Code
    resultLabel.TextSize = 14
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.TextYAlignment = Enum.TextYAlignment.Top
    resultLabel.TextWrapped = true
    resultLabel.Text = "Appuyez sur SCANNER pour démarrer..."
    resultLabel.Parent = scrollFrame
    
    -- Container pour les boutons
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 50)
    btnContainer.Position = UDim2.new(0, 10, 1, -60)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame
    
    -- Boutons
    local function createButton(text, pos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.31, 0, 1, 0)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Parent = btnContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        return btn
    end
    
    local scanBtn = createButton("?? SCANNER", UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 120, 215))
    local copyBtn = createButton("?? COPIER", UDim2.new(0.345, 0, 0, 0), Color3.fromRGB(255, 140, 0))
    local closeBtn = createButton("? FERMER", UDim2.new(0.69, 0, 0, 0), Color3.fromRGB(200, 50, 50))
    
    sg.Parent = gui
    
    return sg, resultLabel, scanBtn, copyBtn, closeBtn, scrollFrame
end

-- ============================================
-- LOGIQUE DE SCAN
-- ============================================

local function scanHierarchy(obj, indent, results)
    indent = indent or ""
    results = results or {}
    
    for _, child in ipairs(obj:GetChildren()) do
        local match = false
        for _, className in ipairs(CONFIG.classes) do
            if child:IsA(className) then
                match = true
                break
            end
        end
        
        if match then
            table.insert(results, {
                indent = indent,
                class = child.ClassName,
                name = child.Name,
                path = child:GetFullName()
            })
            
            if child:IsA("ScreenGui") or child:IsA("Folder") or child:IsA("Model") or child:IsA("Frame") then
                scanHierarchy(child, indent .. "  ", results)
            end
        end
    end
    
    return results
end

local function performScan()
    dumpData = {}
    
    for _, service in ipairs(CONFIG.services) do
        local serviceData = {
            name = service.Name,
            items = scanHierarchy(service)
        }
        table.insert(dumpData, serviceData)
    end
    
    -- Scan PlayerGui
    if player:FindFirstChild("PlayerGui") then
        table.insert(dumpData, {
            name = "PlayerGui",
            items = scanHierarchy(player.PlayerGui)
        })
    end
    
    return dumpData
end

-- ============================================
-- FORMATAGE DES RÉSULTATS
-- ============================================

local function formatResults()
    local lines = {"=== AUDIT DUMP ===", ""}
    
    for _, serviceData in ipairs(dumpData) do
        table.insert(lines, ">>> " .. serviceData.name)
        
        for _, item in ipairs(serviceData.items) do
            table.insert(lines, string.format("%s[%s] %s", item.indent, item.class, item.name))
        end
        
        table.insert(lines, "")
    end
    
    table.insert(lines, "=== FIN DU DUMP ===")
    return table.concat(lines, "\n")
end

-- ============================================
-- COPIE MULTI-MÉTHODES
-- ============================================

local function copyToClipboard(text, btn)
    local success = false
    
    -- Méthode 1: setclipboard (exploits)
    local ok = pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        end
    end)
    
    if success then
        btn.Text = "? COPIÉ! (" .. #text .. " car.)"
        task.wait(2)
        btn.Text = "?? COPIER"
        return
    end
    
    -- Méthode 2: Fichier JSON (export)
    local fileName = "audit_dump_" .. os.time() .. ".txt"
    ok = pcall(function()
        if writefile then
            writefile(fileName, text)
            btn.Text = "?? SAUVEGARDÉ: " .. fileName
            success = true
            task.wait(3)
            btn.Text = "?? COPIER"
        end
    end)
    
    if success then return end
    
    -- Méthode 3: Print (console)
    print("========== AUDIT DUMP ==========")
    print(text)
    print("========== FIN ==========")
    btn.Text = "?? VOIR CONSOLE (F9)"
    task.wait(2)
    btn.Text = "?? COPIER"
end

-- ============================================
-- INITIALISATION
-- ============================================

local function init()
    local sg, label, scanBtn, copyBtn, closeBtn, scrollFrame = createGui()
    
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "? SCAN..."
        label.Text = "Scan en cours...\n"
        task.wait(0.1)
        
        performScan()
        local result = formatResults()
        
        label.Text = result
        
        -- Ajuster la taille du label pour le scroll
        local textSize = game:GetService("TextService"):GetTextSize(
            result,
            14,
            Enum.Font.Code,
            Vector2.new(scrollFrame.AbsoluteSize.X - 20, math.huge)
        )
        label.Size = UDim2.new(1, -10, 0, textSize.Y + 10)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
        
        scanBtn.Text = "?? SCANNER"
    end)
    
    copyBtn.MouseButton1Click:Connect(function()
        if #dumpData == 0 then
            copyBtn.Text = "?? SCAN D'ABORD!"
            task.wait(1)
            copyBtn.Text = "?? COPIER"
            return
        end
        
        copyToClipboard(formatResults(), copyBtn)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
end

init()