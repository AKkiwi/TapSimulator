-- ============================================
-- AUDIT DUMPER PRO - Version Sécurité
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION AVANCÉE
-- ============================================

local CONFIG = {
    services = {
        {name = "ReplicatedStorage", obj = ReplicatedStorage, priority = 1},
        {name = "Workspace", obj = Workspace, priority = 2},
        {name = "Players", obj = Players, priority = 3}
    },
    
    -- Classes critiques pour la sécurité
    critical = {
        "RemoteEvent",
        "RemoteFunction",
        "BindableEvent",
        "BindableFunction"
    },
    
    -- Classes intéressantes
    interesting = {
        "LocalScript",
        "ModuleScript",
        "ScreenGui",
        "Tool",
        "Configuration",
        "IntValue",
        "StringValue",
        "BoolValue",
        "NumberValue"
    },
    
    -- Filtres (ignorer ces patterns)
    ignorePatterns = {
        "^Model$",  -- Ignore les Models sans nom unique
        "^Part$",
        "^MeshPart$",
        "^UnionOperation$",
        "^Decal$",
        "^Texture$",
        "^SpecialMesh$",
        "^Weld$",
        "^Motor6D$",
        "^Attachment$"
    },
    
    maxDepth = 15  -- Profondeur max de scan
}

-- ============================================
-- STOCKAGE DES DONNÉES
-- ============================================

local dumpData = {
    remotes = {},      -- RemoteEvents/Functions
    scripts = {},      -- LocalScripts/ModuleScripts
    guis = {},         -- ScreenGuis
    values = {},       -- Values (IntValue, StringValue, etc.)
    other = {},        -- Autres objets intéressants
    stats = {
        totalScanned = 0,
        remoteEvents = 0,
        remoteFunctions = 0,
        localScripts = 0,
        moduleScripts = 0,
        screenGuis = 0
    }
}

local scanMode = "security"  -- "security" ou "full"

-- ============================================
-- CRÉATION GUI
-- ============================================

local function createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "AuditDumperPro"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.85, 0, 0.8, 0)
    frame.Position = UDim2.new(0.075, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = frame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "?? AUDIT DUMPER PRO"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Mode Toggle
    local modeBtn = Instance.new("TextButton")
    modeBtn.Name = "ModeToggle"
    modeBtn.Size = UDim2.new(0, 140, 0, 35)
    modeBtn.Position = UDim2.new(1, -155, 0.5, -17.5)
    modeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    modeBtn.Text = "?? MODE: SÉCURITÉ"
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 12
    modeBtn.Parent = header
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 6)
    modeCorner.Parent = modeBtn
    
    -- Stats Bar
    local statsBar = Instance.new("Frame")
    statsBar.Size = UDim2.new(1, -20, 0, 30)
    statsBar.Position = UDim2.new(0, 10, 0, 70)
    statsBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    statsBar.BorderSizePixel = 0
    statsBar.Parent = frame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsBar
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -10, 1, 0)
    statsLabel.Position = UDim2.new(0, 5, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Prêt à scanner..."
    statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextSize = 13
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = statsBar
    
    -- Zone de résultats (ScrollingFrame)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ResultScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -180)
    scrollFrame.Position = UDim2.new(0, 10, 0, 110)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    scrollFrame.Parent = frame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 6)
    scrollCorner.Parent = scrollFrame
    
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Name = "ResultLabel"
    resultLabel.Size = UDim2.new(1, -15, 1, 0)
    resultLabel.Position = UDim2.new(0, 8, 0, 5)
    resultLabel.BackgroundTransparency = 1
    resultLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    resultLabel.Font = Enum.Font.Code
    resultLabel.TextSize = 13
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.TextYAlignment = Enum.TextYAlignment.Top
    resultLabel.TextWrapped = true
    resultLabel.Text = "Appuyez sur SCANNER pour démarrer l'audit..."
    resultLabel.Parent = scrollFrame
    
    -- Boutons
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 50)
    btnContainer.Position = UDim2.new(0, 10, 1, -60)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame
    
    local function createButton(text, pos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.24, 0, 1, 0)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.Parent = btnContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        return btn
    end
    
    local scanBtn = createButton("?? SCANNER", UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 150, 255))
    local copyBtn = createButton("?? COPIER", UDim2.new(0.253, 0, 0, 0), Color3.fromRGB(255, 140, 0))
    local exportBtn = createButton("?? EXPORTER", UDim2.new(0.506, 0, 0, 0), Color3.fromRGB(100, 200, 100))
    local closeBtn = createButton("? FERMER", UDim2.new(0.76, 0, 0, 0), Color3.fromRGB(200, 50, 50))
    
    sg.Parent = gui
    
    return sg, resultLabel, scanBtn, copyBtn, exportBtn, closeBtn, scrollFrame, modeBtn, statsLabel
end

-- ============================================
-- LOGIQUE DE SCAN INTELLIGENTE
-- ============================================

local function shouldIgnore(obj)
    -- Ignorer selon les patterns
    for _, pattern in ipairs(CONFIG.ignorePatterns) do
        if obj.Name:match(pattern) and obj.ClassName:match(pattern) then
            return true
        end
    end
    return false
end

local function isCritical(obj)
    for _, class in ipairs(CONFIG.critical) do
        if obj:IsA(class) then return true end
    end
    return false
end

local function isInteresting(obj)
    for _, class in ipairs(CONFIG.interesting) do
        if obj:IsA(class) then return true end
    end
    return false
end

local function scanObject(obj, depth, results)
    if depth > CONFIG.maxDepth then return end
    
    dumpData.stats.totalScanned = dumpData.stats.totalScanned + 1
    
    -- Catégoriser l'objet
    local category = nil
    local info = {
        name = obj.Name,
        class = obj.ClassName,
        path = obj:GetFullName(),
        depth = depth
    }
    
    if obj:IsA("RemoteEvent") then
        category = "remotes"
        info.type = "RemoteEvent"
        dumpData.stats.remoteEvents = dumpData.stats.remoteEvents + 1
    elseif obj:IsA("RemoteFunction") then
        category = "remotes"
        info.type = "RemoteFunction"
        dumpData.stats.remoteFunctions = dumpData.stats.remoteFunctions + 1
    elseif obj:IsA("LocalScript") then
        category = "scripts"
        info.type = "LocalScript"
        dumpData.stats.localScripts = dumpData.stats.localScripts + 1
    elseif obj:IsA("ModuleScript") then
        category = "scripts"
        info.type = "ModuleScript"
        dumpData.stats.moduleScripts = dumpData.stats.moduleScripts + 1
    elseif obj:IsA("ScreenGui") then
        category = "guis"
        dumpData.stats.screenGuis = dumpData.stats.screenGuis + 1
    elseif obj:IsA("IntValue") or obj:IsA("StringValue") or obj:IsA("BoolValue") or obj:IsA("NumberValue") then
        category = "values"
        -- Tenter de lire la valeur
        pcall(function()
            info.value = tostring(obj.Value)
        end)
    elseif isInteresting(obj) and not shouldIgnore(obj) then
        category = "other"
    end
    
    if category then
        table.insert(dumpData[category], info)
    end
    
    -- Scanner les enfants
    for _, child in ipairs(obj:GetChildren()) do
        scanObject(child, depth + 1, results)
    end
end

local function performScan()
    -- Reset data
    dumpData = {
        remotes = {},
        scripts = {},
        guis = {},
        values = {},
        other = {},
        stats = {
            totalScanned = 0,
            remoteEvents = 0,
            remoteFunctions = 0,
            localScripts = 0,
            moduleScripts = 0,
            screenGuis = 0
        }
    }
    
    -- Scanner chaque service
    for _, serviceInfo in ipairs(CONFIG.services) do
        scanObject(serviceInfo.obj, 0)
    end
    
    -- Scanner PlayerGui
    if player:FindFirstChild("PlayerGui") then
        scanObject(player.PlayerGui, 0)
    end
end

-- ============================================
-- FORMATAGE DES RÉSULTATS
-- ============================================

local function formatResults()
    local lines = {}
    
    table.insert(lines, "??????????????????????????????????????????????????????????????")
    table.insert(lines, "?           ?? AUDIT DE SÉCURITÉ - RAPPORT COMPLET          ?")
    table.insert(lines, "??????????????????????????????????????????????????????????????")
    table.insert(lines, "")
    
    -- Stats
    table.insert(lines, "?? STATISTIQUES:")
    table.insert(lines, "  • Objets scannés: " .. dumpData.stats.totalScanned)
    table.insert(lines, "  • RemoteEvents: " .. dumpData.stats.remoteEvents .. " ??")
    table.insert(lines, "  • RemoteFunctions: " .. dumpData.stats.remoteFunctions .. " ??")
    table.insert(lines, "  • LocalScripts: " .. dumpData.stats.localScripts)
    table.insert(lines, "  • ModuleScripts: " .. dumpData.stats.moduleScripts)
    table.insert(lines, "  • ScreenGuis: " .. dumpData.stats.screenGuis)
    table.insert(lines, "")
    table.insert(lines, string.rep("?", 60))
    table.insert(lines, "")
    
    -- Mode sécurité: seulement les remotes
    if scanMode == "security" then
        table.insert(lines, "?? ÉLÉMENTS CRITIQUES (EXPLOITABLES):")
        table.insert(lines, "")
        
        if #dumpData.remotes > 0 then
            for i, remote in ipairs(dumpData.remotes) do
                table.insert(lines, string.format("[%d] %s", i, remote.type))
                table.insert(lines, "    Nom: " .. remote.name)
                table.insert(lines, "    Chemin: " .. remote.path)
                table.insert(lines, "")
            end
        else
            table.insert(lines, "  ? Aucun Remote détecté (bon signe!)")
            table.insert(lines, "")
        end
        
        table.insert(lines, string.rep("?", 60))
        table.insert(lines, "")
        table.insert(lines, "?? TIP: Passez en mode COMPLET pour voir tous les objets")
    else
        -- Mode complet
        
        -- Remotes
        if #dumpData.remotes > 0 then
            table.insert(lines, "?? REMOTES (CRITIQUE - " .. #dumpData.remotes .. "):")
            table.insert(lines, "")
            for i, remote in ipairs(dumpData.remotes) do
                table.insert(lines, string.format("  [%d] %s: %s", i, remote.type, remote.name))
                table.insert(lines, "      ? " .. remote.path)
            end
            table.insert(lines, "")
        end
        
        -- Scripts
        if #dumpData.scripts > 0 then
            table.insert(lines, "?? SCRIPTS (" .. #dumpData.scripts .. "):")
            table.insert(lines, "")
            for i, script in ipairs(dumpData.scripts) do
                table.insert(lines, string.format("  [%d] %s: %s", i, script.type, script.name))
                table.insert(lines, "      ? " .. script.path)
            end
            table.insert(lines, "")
        end
        
        -- GUIs
        if #dumpData.guis > 0 then
            table.insert(lines, "??? SCREEN GUIS (" .. #dumpData.guis .. "):")
            table.insert(lines, "")
            for i, gui in ipairs(dumpData.guis) do
                table.insert(lines, string.format("  [%d] %s", i, gui.name))
                table.insert(lines, "      ? " .. gui.path)
            end
            table.insert(lines, "")
        end
        
        -- Values
        if #dumpData.values > 0 then
            table.insert(lines, "?? VALUES (" .. #dumpData.values .. "):")
            table.insert(lines, "")
            for i, val in ipairs(dumpData.values) do
                local valueStr = val.value and (" = " .. val.value) or ""
                table.insert(lines, string.format("  [%d] %s: %s%s", i, val.class, val.name, valueStr))
                table.insert(lines, "      ? " .. val.path)
            end
            table.insert(lines, "")
        end
        
        -- Autres
        if #dumpData.other > 0 then
            table.insert(lines, "?? AUTRES OBJETS (" .. #dumpData.other .. "):")
            table.insert(lines, "")
            for i, obj in ipairs(dumpData.other) do
                table.insert(lines, string.format("  [%d] [%s] %s", i, obj.class, obj.name))
                table.insert(lines, "      ? " .. obj.path)
            end
            table.insert(lines, "")
        end
    end
    
    table.insert(lines, string.rep("?", 60))
    table.insert(lines, "FIN DU RAPPORT")
    
    return table.concat(lines, "\n")
end

-- ============================================
-- COPIE & EXPORT
-- ============================================

local function copyToClipboard(text, btn)
    local success = false
    
    pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        end
    end)
    
    if success then
        btn.Text = "? COPIÉ! (" .. #text .. " car.)"
        task.wait(2)
        btn.Text = "?? COPIER"
    else
        print("========== AUDIT DUMP ==========")
        print(text)
        print("========== FIN ==========")
        btn.Text = "?? CONSOLE (F9)"
        task.wait(2)
        btn.Text = "?? COPIER"
    end
end

local function exportToFile(btn)
    local text = formatResults()
    local fileName = "audit_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local success = false
    
    pcall(function()
        if writefile then
            writefile(fileName, text)
            success = true
        end
    end)
    
    if success then
        btn.Text = "?? SAUVÉ: " .. fileName
        task.wait(3)
        btn.Text = "?? EXPORTER"
    else
        btn.Text = "? FONCTION INDISPO"
        task.wait(2)
        btn.Text = "?? EXPORTER"
    end
end

-- ============================================
-- INITIALISATION
-- ============================================

local function init()
    local sg, label, scanBtn, copyBtn, exportBtn, closeBtn, scrollFrame, modeBtn, statsLabel = createGui()
    
    -- Toggle Mode
    modeBtn.MouseButton1Click:Connect(function()
        if scanMode == "security" then
            scanMode = "full"
            modeBtn.Text = "?? MODE: COMPLET"
            modeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            scanMode = "security"
            modeBtn.Text = "?? MODE: SÉCURITÉ"
            modeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        
        -- Re-formatter si déjà scanné
        if dumpData.stats.totalScanned > 0 then
            local result = formatResults()
            label.Text = result
            
            local textSize = game:GetService("TextService"):GetTextSize(
                result, 13, Enum.Font.Code,
                Vector2.new(scrollFrame.AbsoluteSize.X - 20, math.huge)
            )
            label.Size = UDim2.new(1, -15, 0, textSize.Y + 10)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
        end
    end)
    
    -- Scanner
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "? SCAN EN COURS..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        label.Text = "Scanning...\nCela peut prendre quelques secondes..."
        statsLabel.Text = "Scan en cours..."
        task.wait(0.1)
        
        performScan()
        local result = formatResults()
        
        label.Text = result
        
        -- Mise à jour des stats
        statsLabel.Text = string.format(
            "Scannés: %d | Remotes: %d ?? | Scripts: %d | Mode: %s",
            dumpData.stats.totalScanned,
            dumpData.stats.remoteEvents + dumpData.stats.remoteFunctions,
            dumpData.stats.localScripts + dumpData.stats.moduleScripts,
            scanMode == "security" and "SÉCURITÉ" or "COMPLET"
        )
        
        -- Ajuster taille
        local textSize = game:GetService("TextService"):GetTextSize(
            result, 13, Enum.Font.Code,
            Vector2.new(scrollFrame.AbsoluteSize.X - 20, math.huge)
        )
        label.Size = UDim2.new(1, -15, 0, textSize.Y + 10)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
        
        scanBtn.Text = "?? SCANNER"
        scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    -- Copier
    copyBtn.MouseButton1Click:Connect(function()
        if dumpData.stats.totalScanned == 0 then
            copyBtn.Text = "?? SCAN D'ABORD!"
            task.wait(1)
            copyBtn.Text = "?? COPIER"
            return
        end
        copyToClipboard(formatResults(), copyBtn)
    end)
    
    -- Exporter
    exportBtn.MouseButton1Click:Connect(function()
        if dumpData.stats.totalScanned == 0 then
            exportBtn.Text = "?? SCAN D'ABORD!"
            task.wait(1)
            exportBtn.Text = "?? EXPORTER"
            return
        end
        exportToFile(exportBtn)
    end)
    
    -- Fermer
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
end

init()