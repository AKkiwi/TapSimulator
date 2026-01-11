-- ============================================
-- EXPLOIT TOOLKIT PRO - Version Offensive
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

-- ============================================
-- CONFIGURATION
-- ============================================

local CONFIG = {
    services = {ReplicatedStorage, Workspace, Players},
    maxDepth = 20,
    autoScan = true,
    -- LIMITES POUR ÉVITER LES CRASHS (surtout sur mobile)
    maxItemsPerCategory = 100,  -- Limite par catégorie
    maxTextSize = 50000,        -- Limite de caractères pour éviter crash
    paginationSize = 50         -- Afficher par paquets de 50
}

-- ============================================
-- DONNÉES COLLECTÉES
-- ============================================

local exploitData = {
    -- Remotes
    remotes = {events = {}, functions = {}},
    
    -- UI exploitable
    hiddenGuis = {},
    accessibleButtons = {},
    
    -- Interactions
    clickDetectors = {},
    proximityPrompts = {},
    touchInterests = {},
    
    -- Anti-cheat
    antiCheatScripts = {},
    
    -- Exploitables
    tools = {},
    animations = {},
    sounds = {},
    
    -- Values
    playerValues = {},
    configValues = {},
    
    -- Stats
    stats = {
        totalScanned = 0,
        exploitableRemotes = 0,
        hiddenUIs = 0,
        clickDetectors = 0,
        suspiciousScripts = 0
    }
}

-- Remote spy data
local remoteLogs = {}
local remoteSpyActive = false

-- ============================================
-- GUI CREATION
-- ============================================

local function createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ExploitToolkit"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0.9, 0, 0.85, 0)
    main.Position = UDim2.new(0.05, 0, 0.075, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    main.BorderSizePixel = 0
    main.Parent = sg
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = main
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "? EXPLOIT TOOLKIT PRO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "?"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    -- Tab System
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = main
    
    local tabs = {"?? REMOTES", "?? UI HIDDEN", "?? INTERACTIONS", "??? ANTI-CHEAT", "?? RAPPORT"}
    local tabButtons = {}
    local contentFrames = {}
    
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab"..i
        tabBtn.Size = UDim2.new(1/#tabs, -4, 1, -8)
        tabBtn.Position = UDim2.new((i-1)/#tabs, 2, 0, 4)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn
        
        table.insert(tabButtons, tabBtn)
        
        -- Content Frame
        local content = Instance.new("ScrollingFrame")
        content.Name = "Content"..i
        content.Size = UDim2.new(1, -20, 1, -150)
        content.Position = UDim2.new(0, 10, 0, 100)
        content.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 6
        content.Visible = (i == 1)
        content.Parent = main
        
        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 6)
        contentCorner.Parent = content
        
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Name = "Label"
        contentLabel.Size = UDim2.new(1, -10, 1, 0)
        contentLabel.Position = UDim2.new(0, 5, 0, 5)
        contentLabel.BackgroundTransparency = 1
        contentLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        contentLabel.Font = Enum.Font.Code
        contentLabel.TextSize = 12
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.TextWrapped = true
        contentLabel.Text = "Chargement..."
        contentLabel.Parent = content
        
        table.insert(contentFrames, content)
    end
    
    -- Tab switching
    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            for j, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                b.TextColor3 = Color3.fromRGB(180, 180, 180)
                contentFrames[j].Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            contentFrames[i].Visible = true
        end)
    end
    
    -- Action Buttons
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 40)
    btnContainer.Position = UDim2.new(0, 10, 1, -50)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = main
    
    local function createActionBtn(text, pos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.19, 0, 1, 0)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = btnContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        return btn
    end
    
    local scanBtn = createActionBtn("?? SCAN", UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 150, 255))
    local spyBtn = createActionBtn("?? SPY ON", UDim2.new(0.202, 0, 0, 0), Color3.fromRGB(255, 140, 0))
    local fireBtn = createActionBtn("? FIRE ALL", UDim2.new(0.404, 0, 0, 0), Color3.fromRGB(200, 0, 200))
    local copyBtn = createActionBtn("?? COPIER", UDim2.new(0.606, 0, 0, 0), Color3.fromRGB(100, 200, 100))
    local exportBtn = createActionBtn("?? EXPORT", UDim2.new(0.808, 0, 0, 0), Color3.fromRGB(50, 150, 200))
    
    sg.Parent = gui
    
    -- Active first tab
    tabButtons[1].BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    return sg, contentFrames, scanBtn, spyBtn, fireBtn, copyBtn, exportBtn, closeBtn
end

-- ============================================
-- SCANNING LOGIC
-- ============================================

local function scanRemotes(obj, depth)
    if depth > CONFIG.maxDepth then return end
    
    for _, child in ipairs(obj:GetChildren()) do
        exploitData.stats.totalScanned = exploitData.stats.totalScanned + 1
        
        if child:IsA("RemoteEvent") then
            table.insert(exploitData.remotes.events, {
                name = child.Name,
                path = child:GetFullName(),
                obj = child
            })
            exploitData.stats.exploitableRemotes = exploitData.stats.exploitableRemotes + 1
        elseif child:IsA("RemoteFunction") then
            table.insert(exploitData.remotes.functions, {
                name = child.Name,
                path = child:GetFullName(),
                obj = child
            })
            exploitData.stats.exploitableRemotes = exploitData.stats.exploitableRemotes + 1
        end
        
        scanRemotes(child, depth + 1)
    end
end

local function scanHiddenUIs(obj, depth)
    if depth > CONFIG.maxDepth then return end
    
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("ScreenGui") and not child.Enabled then
            table.insert(exploitData.hiddenGuis, {
                name = child.Name,
                path = child:GetFullName(),
                obj = child,
                enabled = child.Enabled
            })
            exploitData.stats.hiddenUIs = exploitData.stats.hiddenUIs + 1
        end
        
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            table.insert(exploitData.accessibleButtons, {
                name = child.Name,
                path = child:GetFullName(),
                obj = child,
                visible = child.Visible
            })
        end
        
        scanHiddenUIs(child, depth + 1)
    end
end

local function scanInteractions(obj, depth)
    if depth > CONFIG.maxDepth then return end
    
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("ClickDetector") then
            table.insert(exploitData.clickDetectors, {
                name = child.Parent.Name,
                path = child.Parent:GetFullName(),
                obj = child,
                maxDistance = child.MaxActivationDistance
            })
            exploitData.stats.clickDetectors = exploitData.stats.clickDetectors + 1
        elseif child:IsA("ProximityPrompt") then
            table.insert(exploitData.proximityPrompts, {
                name = child.Parent.Name,
                path = child.Parent:GetFullName(),
                obj = child,
                maxDistance = child.MaxActivationDistance
            })
        elseif child:IsA("Tool") and child.Parent == ReplicatedStorage then
            table.insert(exploitData.tools, {
                name = child.Name,
                path = child:GetFullName(),
                obj = child
            })
        end
        
        scanInteractions(child, depth + 1)
    end
end

local function scanAntiCheat(obj, depth)
    if depth > CONFIG.maxDepth then return end
    
    local suspiciousNames = {"AntiCheat", "AntiExploit", "Security", "Detection", "Kick", "Ban", "Check"}
    
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("LocalScript") or child:IsA("Script") then
            for _, keyword in ipairs(suspiciousNames) do
                if child.Name:lower():find(keyword:lower()) then
                    table.insert(exploitData.antiCheatScripts, {
                        name = child.Name,
                        path = child:GetFullName(),
                        type = child.ClassName
                    })
                    exploitData.stats.suspiciousScripts = exploitData.stats.suspiciousScripts + 1
                    break
                end
            end
        end
        
        scanAntiCheat(child, depth + 1)
    end
end

local function performFullScan()
    -- Reset
    exploitData = {
        remotes = {events = {}, functions = {}},
        hiddenGuis = {},
        accessibleButtons = {},
        clickDetectors = {},
        proximityPrompts = {},
        touchInterests = {},
        antiCheatScripts = {},
        tools = {},
        animations = {},
        sounds = {},
        playerValues = {},
        configValues = {},
        stats = {
            totalScanned = 0,
            exploitableRemotes = 0,
            hiddenUIs = 0,
            clickDetectors = 0,
            suspiciousScripts = 0
        }
    }
    
    -- Scan everything
    for _, service in ipairs(CONFIG.services) do
        scanRemotes(service, 0)
        scanInteractions(service, 0)
        scanAntiCheat(service, 0)
    end
    
    scanHiddenUIs(gui, 0)
    
    -- Scan player
    if player:FindFirstChild("leaderstats") then
        for _, stat in ipairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                table.insert(exploitData.playerValues, {
                    name = stat.Name,
                    value = stat.Value,
                    obj = stat
                })
            end
        end
    end
end

-- ============================================
-- REMOTE SPY
-- ============================================

local function setupRemoteSpy()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if remoteSpyActive and (method == "FireServer" or method == "InvokeServer") then
            local log = {
                remote = self:GetFullName(),
                method = method,
                args = args,
                time = os.date("%H:%M:%S")
            }
            table.insert(remoteLogs, log)
            
            print(string.format("[SPY] %s -> %s(%s)", 
                log.time, 
                log.remote, 
                table.concat(args, ", ")
            ))
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- ============================================
-- FORMATTING
-- ============================================

local function formatTopItems(items, limit, itemType)
    local lines = {}
    local count = math.min(limit, #items)
    
    if count == 0 then
        return "  Aucun"
    end
    
    for i = 1, count do
        local item = items[i]
        table.insert(lines, string.format("  [%d] %s ? %s", i, item.name or "?", item.path or "?"))
    end
    
    if #items > limit then
        table.insert(lines, string.format("  ... +%d autres", #items - limit))
    end
    
    return table.concat(lines, "\n")
end

local function formatCompleteList(items, itemType)
    local lines = {}
    table.insert(lines, string.format("Total: %d %s(s)", #items, itemType))
    table.insert(lines, "")
    
    for i, item in ipairs(items) do
        table.insert(lines, string.format("[%d] %s", i, item.name or "?"))
        table.insert(lines, "    ? " .. (item.path or "?"))
    end
    
    return table.concat(lines, "\n")
end

local function formatRemotes()
    local lines = {}
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "?     ? REMOTES EXPLOITABLES            ?")
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "")
    table.insert(lines, string.format("Total: %d RemoteEvents, %d RemoteFunctions", 
        #exploitData.remotes.events, #exploitData.remotes.functions))
    table.insert(lines, "")
    
    if #exploitData.remotes.events > 0 then
        table.insert(lines, "?? REMOTE EVENTS:")
        for i, remote in ipairs(exploitData.remotes.events) do
            table.insert(lines, string.format("[%d] %s", i, remote.name))
            table.insert(lines, "    ? " .. remote.path)
        end
        table.insert(lines, "")
    end
    
    if #exploitData.remotes.functions > 0 then
        table.insert(lines, "?? REMOTE FUNCTIONS:")
        for i, remote in ipairs(exploitData.remotes.functions) do
            table.insert(lines, string.format("[%d] %s", i, remote.name))
            table.insert(lines, "    ? " .. remote.path)
        end
    end
    
    return table.concat(lines, "\n")
end

local function formatHiddenUIs()
    local lines = {}
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "?     ?? UI CACHÉS & BOUTONS             ?")
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "")
    
    if #exploitData.hiddenGuis > 0 then
        table.insert(lines, string.format("?? GUIS DÉSACTIVÉS: %d", #exploitData.hiddenGuis))
        local limit = math.min(CONFIG.maxItemsPerCategory, #exploitData.hiddenGuis)
        for i = 1, limit do
            local ui = exploitData.hiddenGuis[i]
            table.insert(lines, string.format("[%d] %s", i, ui.name))
            table.insert(lines, "    ? " .. ui.path)
        end
        if #exploitData.hiddenGuis > limit then
            table.insert(lines, string.format("... et %d autres (voir EXPORT pour tout)", #exploitData.hiddenGuis - limit))
        end
        table.insert(lines, "")
    else
        table.insert(lines, "? Aucun GUI caché détecté")
        table.insert(lines, "")
    end
    
    if #exploitData.accessibleButtons > 0 then
        table.insert(lines, string.format("?? BOUTONS: %d trouvés", #exploitData.accessibleButtons))
        table.insert(lines, "")
        
        -- PAGINATION: Afficher seulement les 50 premiers pour éviter crash
        local limit = math.min(CONFIG.paginationSize, #exploitData.accessibleButtons)
        for i = 1, limit do
            local btn = exploitData.accessibleButtons[i]
            table.insert(lines, string.format("[%d] %s", i, btn.name))
            table.insert(lines, "    ? " .. btn.path)
        end
        
        if #exploitData.accessibleButtons > limit then
            table.insert(lines, "")
            table.insert(lines, string.format("?? %d boutons cachés pour éviter crash!", #exploitData.accessibleButtons - limit))
            table.insert(lines, "?? Utilisez EXPORT pour tout sauvegarder")
        end
    end
    
    return table.concat(lines, "\n")
end

local function formatInteractions()
    local lines = {}
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "?     ?? INTERACTIONS EXPLOITABLES       ?")
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "")
    
    if #exploitData.clickDetectors > 0 then
        table.insert(lines, string.format("?? CLICK DETECTORS: %d", #exploitData.clickDetectors))
        for i, click in ipairs(exploitData.clickDetectors) do
            table.insert(lines, string.format("[%d] %s (Dist: %d)", i, click.name, click.maxDistance))
            table.insert(lines, "    ? " .. click.path)
            table.insert(lines, "    ?? fireclickdetector(obj)")
        end
        table.insert(lines, "")
    end
    
    if #exploitData.proximityPrompts > 0 then
        table.insert(lines, string.format("?? PROXIMITY PROMPTS: %d", #exploitData.proximityPrompts))
        for i, prompt in ipairs(exploitData.proximityPrompts) do
            table.insert(lines, string.format("[%d] %s", i, prompt.name))
            table.insert(lines, "    ? " .. prompt.path)
        end
        table.insert(lines, "")
    end
    
    if #exploitData.tools > 0 then
        table.insert(lines, string.format("?? TOOLS DISPONIBLES: %d", #exploitData.tools))
        for i, tool in ipairs(exploitData.tools) do
            table.insert(lines, string.format("[%d] %s", i, tool.name))
            table.insert(lines, "    ? " .. tool.path)
        end
    end
    
    return table.concat(lines, "\n")
end

local function formatAntiCheat()
    local lines = {}
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "?     ??? DÉTECTION ANTI-CHEAT           ?")
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "")
    
    if #exploitData.antiCheatScripts > 0 then
        table.insert(lines, string.format("?? SCRIPTS SUSPECTS: %d", #exploitData.antiCheatScripts))
        for i, script in ipairs(exploitData.antiCheatScripts) do
            table.insert(lines, string.format("[%d] [%s] %s", i, script.type, script.name))
            table.insert(lines, "    ? " .. script.path)
        end
        table.insert(lines, "")
        table.insert(lines, "?? ATTENTION: Ces scripts peuvent vous détecter!")
    else
        table.insert(lines, "? Aucun anti-cheat évident détecté")
        table.insert(lines, "?? Mais restez prudent!")
    end
    
    return table.concat(lines, "\n")
end

local function formatReport()
    local lines = {}
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "?     ?? RAPPORT COMPLET D'EXPLOITATION  ?")
    table.insert(lines, "????????????????????????????????????????????")
    table.insert(lines, "")
    table.insert(lines, "?? STATISTIQUES GLOBALES:")
    table.insert(lines, string.format("  • Objets scannés: %d", exploitData.stats.totalScanned))
    table.insert(lines, string.format("  • Remotes exploitables: %d ?", exploitData.stats.exploitableRemotes))
    table.insert(lines, string.format("  • UI cachés: %d ??", exploitData.stats.hiddenUIs))
    table.insert(lines, string.format("  • Click Detectors: %d ??", exploitData.stats.clickDetectors))
    table.insert(lines, string.format("  • Scripts suspects: %d ???", exploitData.stats.suspiciousScripts))
    table.insert(lines, "")
    table.insert(lines, "?? VECTEURS D'ATTAQUE PRINCIPAUX:")
    table.insert(lines, string.format("  1. RemoteEvents sans validation: %d", #exploitData.remotes.events))
    table.insert(lines, string.format("  2. Click Detectors à distance: %d", #exploitData.clickDetectors))
    table.insert(lines, string.format("  3. UI activables: %d", #exploitData.hiddenGuis))
    table.insert(lines, string.format("  4. Tools accessibles: %d", #exploitData.tools))
    table.insert(lines, "")
    table.insert(lines, "?? RECOMMANDATIONS:")
    table.insert(lines, "  • Tester chaque Remote avec différents args")
    table.insert(lines, "  • Fire tous les ClickDetectors")
    table.insert(lines, "  • Activer les UI cachés")
    table.insert(lines, "  • Bypass l'anti-cheat si détecté")
    
    return table.concat(lines, "\n")
end

-- ============================================
-- EXPLOIT FUNCTIONS
-- ============================================

local function fireAllClickDetectors()
    local count = 0
    for _, click in ipairs(exploitData.clickDetectors) do
        pcall(function()
            fireclickdetector(click.obj)
            count = count + 1
        end)
    end
    return count
end

local function activateHiddenUIs()
    local count = 0
    for _, ui in ipairs(exploitData.hiddenGuis) do
        pcall(function()
            ui.obj.Enabled = true
            count = count + 1
        end)
    end
    return count
end

-- ============================================
-- INIT
-- ============================================

local function init()
    local sg, frames, scanBtn, spyBtn, fireBtn, copyBtn, exportBtn, closeBtn = createGui()
    
    -- Setup remote spy
    pcall(setupRemoteSpy)
    
    -- Scan button
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "? SCAN..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        
        for _, frame in ipairs(frames) do
            frame.Label.Text = "Scanning..."
        end
        
        task.wait(0.1)
        performFullScan()
        
        -- Update displays
        frames[1].Label.Text = formatRemotes()
        frames[2].Label.Text = formatHiddenUIs()
        frames[3].Label.Text = formatInteractions()
        frames[4].Label.Text = formatAntiCheat()
        frames[5].Label.Text = formatReport()
        
        -- Adjust sizes
        for _, frame in ipairs(frames) do
            local textSize = game:GetService("TextService"):GetTextSize(
                frame.Label.Text, 12, Enum.Font.Code,
                Vector2.new(frame.AbsoluteSize.X - 20, math.huge)
            )
            frame.Label.Size = UDim2.new(1, -10, 0, textSize.Y + 10)
            frame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
        end
        
        scanBtn.Text = "?? SCAN"
        scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    -- Spy toggle
    spyBtn.MouseButton1Click:Connect(function()
        remoteSpyActive = not remoteSpyActive
        if remoteSpyActive then
            spyBtn.Text = "?? SPY OFF"
            spyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            print("[SPY] Remote spy activé! Surveillez la console...")
        else
            spyBtn.Text = "?? SPY ON"
            spyBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            print("[SPY] Remote spy désactivé")
        end
    end)
    
    -- Fire all
    fireBtn.MouseButton1Click:Connect(function()
        fireBtn.Text = "?..."
        local count = fireAllClickDetectors()
        fireBtn.Text = string.format("? FIRED %d", count)
        task.wait(2)
        fireBtn.Text = "? FIRE ALL"
    end)
    
    -- Copy
    copyBtn.MouseButton1Click:Connect(function()
        if exploitData.stats.totalScanned == 0 then
            copyBtn.Text = "?? SCAN!"
            task.wait(1)
            copyBtn.Text = "?? COPIER"
            return
        end
        
        -- VERSION LÉGÈRE pour éviter crash
        local lightReport = table.concat({
            "=== RAPPORT LÉGER (Anti-Crash) ===",
            "",
            string.format("?? Stats: %d objets | %d remotes | %d UI | %d clicks", 
                exploitData.stats.totalScanned,
                exploitData.stats.exploitableRemotes,
                exploitData.stats.hiddenUIs,
                exploitData.stats.clickDetectors),
            "",
            "?? TOP REMOTES:",
            formatTopItems(exploitData.remotes.events, 20, "RemoteEvent"),
            formatTopItems(exploitData.remotes.functions, 20, "RemoteFunction"),
            "",
            "?? TOP UI CACHÉS:",
            formatTopItems(exploitData.hiddenGuis, 10, "GUI"),
            "",
            "?? Pour le rapport COMPLET, utilisez EXPORT (fichier)"
        }, "\n")
        
        -- Vérifier la taille AVANT de copier
        if #lightReport > CONFIG.maxTextSize then
            copyBtn.Text = "?? TROP GROS!"
            print("[ERREUR] Rapport trop volumineux pour copie!")
            print("Utilisez EXPORT à la place")
            task.wait(2)
            copyBtn.Text = "?? COPIER"
            return
        end
        
        local success = false
        
        -- Méthode 1: setclipboard
        pcall(function()
            if setclipboard then
                setclipboard(lightReport)
                success = true
            end
        end)
        
        if success then
            copyBtn.Text = "? COPIÉ! (" .. #lightReport .. ")"
            print("[COPIE] Rapport léger copié (anti-crash)")
        else
            -- Méthode 2: Console
            print("========== RAPPORT LÉGER ==========")
            print(lightReport)
            print("========== FIN ==========")
            copyBtn.Text = "?? CONSOLE (F9)"
        end
        
        task.wait(2)
        copyBtn.Text = "?? COPIER"
    end)
    
    -- Export
    exportBtn.MouseButton1Click:Connect(function()
        if exploitData.stats.totalScanned == 0 then
            exportBtn.Text = "?? SCAN!"
            task.wait(1)
            exportBtn.Text = "?? EXPORT"
            return
        end
        
        -- EXPORT COMPLET (tous les détails)
        local fullReport = table.concat({
            formatReport(),
            "\n\n",
            formatRemotes(),
            "\n\n",
            "=== UI CACHÉS (COMPLET) ===",
            formatCompleteList(exploitData.hiddenGuis, "GUI"),
            "\n\n",
            "=== BOUTONS (COMPLET) ===",
            formatCompleteList(exploitData.accessibleButtons, "Bouton"),
            "\n\n",
            formatInteractions(),
            "\n\n",
            formatAntiCheat()
        }, "")
        
        local success = false
        pcall(function()
            if writefile then
                local fileName = "exploit_report_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
                writefile(fileName, fullReport)
                exportBtn.Text = "?? SAUVÉ!"
                print("[EXPORT] Fichier créé: " .. fileName)
                print("[EXPORT] Taille: " .. #fullReport .. " caractères")
                success = true
            end
        end)
        
        if not success then
            exportBtn.Text = "? INDISPO"
            -- Fallback: Print en plusieurs parties pour éviter crash console
            print("========== EXPORT (PARTIE 1/3) ==========")
            print(formatReport())
            print(formatRemotes())
            print("========== PARTIE 2/3 ==========")
            print(formatHiddenUIs())
            print(formatInteractions())
            print("========== PARTIE 3/3 ==========")
            print(formatAntiCheat())
            print("========== FIN ==========")
        end
        
        task.wait(3)
        exportBtn.Text = "?? EXPORT"
    end)
    
    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
    
    -- Auto-scan on load
    if CONFIG.autoScan then
        task.wait(1)
        scanBtn.MouseButton1Click:Fire()
    end
end

init()

print("? EXPLOIT TOOLKIT PRO chargé!")
print("?? Fonctionnalités:")
print("  • Scanner de Remotes exploitables")
print("  • Détecteur d'UI cachés")
print("  • Fire automatique de ClickDetectors")
print("  • Remote Spy en temps réel")
print("  • Détection Anti-Cheat")
print("  • Export complet des données")
print("")
print("?? Utilisez les onglets pour naviguer!")
print("?? Utilisez de manière éthique!")