-- ============================================
-- TAPSIM AUTO-FARM AFK - RAYFIELD EDITION
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================

local Config = {
    AutoClick = false,
    AutoRebirth = false,
    AutoClaimPacks = false,
    AutoPetFarm = false,
    AutoBuyEggs = false,
    
    ClickSpeed = 0.1,
    RebirthDelay = 1,
    ClaimDelay = 5,
    
    -- Detected remotes
    clickRemote = nil,
    rebirthRemote = nil,
    purchaseRemote = ReplicatedStorage:FindFirstChild("PurchasePack"),
    foreverPackRequest = ReplicatedStorage:FindFirstChild("ForeverPackRequest"),
    foreverPackClaim = ReplicatedStorage:FindFirstChild("ForeverPackClaim"),
    petAttackEvent = ReplicatedStorage:FindFirstChild("PetAttackEvent"),
}

-- Stats tracking
local Stats = {
    clicks = 0,
    rebirths = 0,
    packsClaimed = 0,
    eggsHatched = 0,
    runtime = 0
}

-- ============================================
-- LOAD RAYFIELD
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🚀 TapSim Auto-Farm AFK",
    LoadingTitle = "TapSim Exploit",
    LoadingSubtitle = "by maxoupixo4",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "TapSimConfig"
    }
})

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458
    })
end

local function updateStats()
    if player:FindFirstChild("leaderstats") then
        local clicks = player.leaderstats:FindFirstChild("Clicks")
        local rebirths = player.leaderstats:FindFirstChild("Rebirths")
        
        if clicks then
            local clickValue = tonumber(clicks.Value) or 0
            Stats.clicks = clickValue
        end
        
        if rebirths then
            local rebirthValue = tonumber(rebirths.Value) or 0
            Stats.rebirths = rebirthValue
        end
    end
end

-- ============================================
-- REMOTE FINDER
-- ============================================

local function findObfuscatedRemotes()
    notify("🔍 Recherche", "Scan des remotes obfusqués...", 3)
    
    -- Search in obfuscated folder
    local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
    if not obfFolder then
        -- Try other GUIDs
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            if child.Name:match("%x+-%x+-%x+-%x+-%x+") then
                obfFolder = child
                break
            end
        end
    end
    
    if obfFolder then
        local eventsFolder = obfFolder:FindFirstChild("Events")
        local functionsFolder = obfFolder:FindFirstChild("Functions")
        
        if eventsFolder then
            local allEvents = eventsFolder:GetChildren()
            -- Heuristique: premier event = click, deuxième = rebirth
            if #allEvents >= 1 then
                Config.clickRemote = allEvents[1]
                notify("✅ Click Remote", "Trouvé: " .. Config.clickRemote.Name, 3)
            end
            if #allEvents >= 2 then
                Config.rebirthRemote = allEvents[2]
                notify("✅ Rebirth Remote", "Trouvé: " .. Config.rebirthRemote.Name, 3)
            end
        end
    end
    
    -- Fallback: Search in GUI buttons
    if not Config.clickRemote then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                
                if name:find("tap") or text:find("tap") or name == "Tap" then
                    Config.clickRemote = ui
                    notify("✅ Click Button", "Trouvé: " .. ui.Name, 3)
                    break
                end
            end
        end
    end
    
    if not Config.rebirthRemote then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                
                if name:find("rebirth") or text:find("rebirth") or name:find("prestige") then
                    Config.rebirthRemote = ui
                    notify("✅ Rebirth Button", "Trouvé: " .. ui.Name, 3)
                    break
                end
            end
        end
    end
end

-- ============================================
-- AUTO FUNCTIONS
-- ============================================

local function autoClick()
    while Config.AutoClick do
        pcall(function()
            if Config.clickRemote then
                if Config.clickRemote:IsA("RemoteEvent") then
                    Config.clickRemote:FireServer()
                elseif Config.clickRemote:IsA("RemoteFunction") then
                    Config.clickRemote:InvokeServer()
                elseif Config.clickRemote:IsA("TextButton") then
                    for _, connection in pairs(getconnections(Config.clickRemote.MouseButton1Click)) do
                        connection:Fire()
                    end
                end
            end
        end)
        task.wait(Config.ClickSpeed)
    end
end

local function autoRebirth()
    while Config.AutoRebirth do
        pcall(function()
            if Config.rebirthRemote then
                if Config.rebirthRemote:IsA("RemoteEvent") then
                    Config.rebirthRemote:FireServer()
                elseif Config.rebirthRemote:IsA("RemoteFunction") then
                    Config.rebirthRemote:InvokeServer()
                elseif Config.rebirthRemote:IsA("TextButton") then
                    for _, connection in pairs(getconnections(Config.rebirthRemote.MouseButton1Click)) do
                        connection:Fire()
                    end
                end
            end
        end)
        task.wait(Config.RebirthDelay)
    end
end

local function autoClaimPacks()
    while Config.AutoClaimPacks do
        pcall(function()
            -- Claim ForeverPack
            if Config.foreverPackClaim then
                Config.foreverPackClaim:FireServer()
                Stats.packsClaimed = Stats.packsClaimed + 1
            end
            
            -- Request ForeverPack
            if Config.foreverPackRequest then
                Config.foreverPackRequest:FireServer()
            end
            
            -- Try to claim all rewards
            for _, ui in ipairs(gui:GetDescendants()) do
                if ui:IsA("TextButton") then
                    local name = ui.Name:lower()
                    local text = ui.Text:lower()
                    
                    if (name:find("claim") or text:find("claim")) and ui.Visible then
                        for _, connection in pairs(getconnections(ui.MouseButton1Click)) do
                            connection:Fire()
                        end
                    end
                end
            end
        end)
        task.wait(Config.ClaimDelay)
    end
end

local function autoPetFarm()
    while Config.AutoPetFarm do
        pcall(function()
            if Config.petAttackEvent then
                Config.petAttackEvent:FireServer()
            end
        end)
        task.wait(0.1)
    end
end

local function autoBuyEggs()
    while Config.AutoBuyEggs do
        pcall(function()
            -- Find and click egg buy buttons
            local storeUI = gui.Tabs and gui.Tabs:FindFirstChild("Store")
            if storeUI then
                for _, desc in ipairs(storeUI:GetDescendants()) do
                    if desc:IsA("TextButton") then
                        local name = desc.Name:lower()
                        local text = desc.Text:lower()
                        
                        if name:find("buy") and desc.Visible then
                            for _, connection in pairs(getconnections(desc.MouseButton1Click)) do
                                connection:Fire()
                            end
                            Stats.eggsHatched = Stats.eggsHatched + 1
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
        task.wait(2)
    end
end

-- ============================================
-- UI TABS
-- ============================================

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

local AutoClickToggle = MainTab:CreateToggle({
    Name = "🖱️ Auto Click",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
        Config.AutoClick = Value
        if Value then
            notify("✅ Auto Click", "Activé", 2)
            task.spawn(autoClick)
        else
            notify("❌ Auto Click", "Désactivé", 2)
        end
    end
})

local ClickSpeedSlider = MainTab:CreateSlider({
    Name = "⚡ Click Speed (s)",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Flag = "ClickSpeed",
    Callback = function(Value)
        Config.ClickSpeed = Value
    end
})

local AutoRebirthToggle = MainTab:CreateToggle({
    Name = "♻️ Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        Config.AutoRebirth = Value
        if Value then
            notify("✅ Auto Rebirth", "Activé", 2)
            task.spawn(autoRebirth)
        else
            notify("❌ Auto Rebirth", "Désactivé", 2)
        end
    end
})

local RebirthDelaySlider = MainTab:CreateSlider({
    Name = "⏱️ Rebirth Delay (s)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "RebirthDelay",
    Callback = function(Value)
        Config.RebirthDelay = Value
    end
})

MainTab:CreateDivider()

local StatsLabel = MainTab:CreateLabel("📊 Stats: Loading...")

-- Farm Tab
local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)

local AutoPetFarmToggle = FarmTab:CreateToggle({
    Name = "🐾 Auto Pet Farm",
    CurrentValue = false,
    Flag = "AutoPetFarm",
    Callback = function(Value)
        Config.AutoPetFarm = Value
        if Value then
            notify("✅ Pet Farm", "Activé", 2)
            task.spawn(autoPetFarm)
        else
            notify("❌ Pet Farm", "Désactivé", 2)
        end
    end
})

local AutoClaimPacksToggle = FarmTab:CreateToggle({
    Name = "🎁 Auto Claim Packs",
    CurrentValue = false,
    Flag = "AutoClaimPacks",
    Callback = function(Value)
        Config.AutoClaimPacks = Value
        if Value then
            notify("✅ Auto Claim", "Activé", 2)
            task.spawn(autoClaimPacks)
        else
            notify("❌ Auto Claim", "Désactivé", 2)
        end
    end
})

local AutoBuyEggsToggle = FarmTab:CreateToggle({
    Name = "🥚 Auto Buy Eggs",
    CurrentValue = false,
    Flag = "AutoBuyEggs",
    Callback = function(Value)
        Config.AutoBuyEggs = Value
        if Value then
            notify("✅ Auto Buy Eggs", "Activé", 2)
            task.spawn(autoBuyEggs)
        else
            notify("❌ Auto Buy Eggs", "Désactivé", 2)
        end
    end
})

-- Shop Tab
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)

ShopTab:CreateButton({
    Name = "💎 Claim Forever Pack",
    Callback = function()
        pcall(function()
            if Config.foreverPackClaim then
                Config.foreverPackClaim:FireServer()
                notify("✅ Forever Pack", "Claimed!", 2)
            end
        end)
    end
})

ShopTab:CreateButton({
    Name = "📦 Request Forever Pack",
    Callback = function()
        pcall(function()
            if Config.foreverPackRequest then
                Config.foreverPackRequest:FireServer()
                notify("✅ Request", "Envoyé!", 2)
            end
        end)
    end
})

ShopTab:CreateButton({
    Name = "🎁 Claim All Visible Rewards",
    Callback = function()
        local claimed = 0
        pcall(function()
            for _, ui in ipairs(gui:GetDescendants()) do
                if ui:IsA("TextButton") and ui.Visible then
                    local name = ui.Name:lower()
                    local text = ui.Text:lower()
                    
                    if name:find("claim") or text:find("claim") then
                        for _, connection in pairs(getconnections(ui.MouseButton1Click)) do
                            connection:Fire()
                            claimed = claimed + 1
                        end
                    end
                end
            end
        end)
        notify("✅ Claimed", claimed .. " rewards!", 3)
    end
})

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateButton({
    Name = "🔄 Re-scan Remotes",
    Callback = function()
        findObfuscatedRemotes()
    end
})

MiscTab:CreateButton({
    Name = "👁️ Show Hidden UIs",
    Callback = function()
        local count = 0
        for _, ui in ipairs(gui:GetChildren()) do
            if ui:IsA("ScreenGui") and not ui.Enabled then
                ui.Enabled = true
                count = count + 1
            end
        end
        notify("✅ UI Unlocked", count .. " UIs activés", 3)
    end
})

MiscTab:CreateButton({
    Name = "🔥 Fire All Purchase Remotes",
    Callback = function()
        pcall(function()
            if Config.purchaseRemote then
                Config.purchaseRemote:FireServer("Free", 0)
                Config.purchaseRemote:FireServer("ForeverPack", 0)
                notify("✅ Purchase", "Remotes fired!", 2)
            end
        end)
    end
})

MiscTab:CreateDivider()

MiscTab:CreateLabel("⚠️ Experimental Features")

MiscTab:CreateButton({
    Name = "💣 Spam All Obfuscated Remotes",
    Callback = function()
        notify("⚠️ Warning", "Spamming all remotes...", 3)
        local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
        if obfFolder then
            local eventsFolder = obfFolder:FindFirstChild("Events")
            if eventsFolder then
                for _, remote in ipairs(eventsFolder:GetChildren()) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer()
                        end
                    end)
                    task.wait(0.1)
                end
            end
        end
        notify("✅ Done", "All remotes fired!", 2)
    end
})

-- ============================================
-- INIT
-- ============================================

notify("🚀 TapSim Auto-Farm", "Chargement...", 3)

-- Find remotes on startup
task.wait(2)
findObfuscatedRemotes()

-- Stats update loop
task.spawn(function()
    while task.wait(1) do
        Stats.runtime = Stats.runtime + 1
        updateStats()
        
        -- Update stats label
        pcall(function()
            StatsLabel:Set(string.format(
                "📊 Clicks: %s | Rebirths: %s | Runtime: %ds",
                tostring(Stats.clicks),
                tostring(Stats.rebirths),
                Stats.runtime
            ))
        end)
    end
end)

notify("✅ Loaded", "TapSim Auto-Farm ready!", 3)
print("=" .. string.rep("=", 60))
print("TapSim Auto-Farm AFK - Loaded Successfully")
print("Remotes found:")
print("  Click:", Config.clickRemote and Config.clickRemote.Name or "NOT FOUND")
print("  Rebirth:", Config.rebirthRemote and Config.rebirthRemote.Name or "NOT FOUND")
print("  Purchase:", Config.purchaseRemote and "OK" or "NOT FOUND")
print("  ForeverPack:", Config.foreverPackClaim and "OK" or "NOT FOUND")
print("  PetAttack:", Config.petAttackEvent and "OK" or "NOT FOUND")
print("=" .. string.rep("=", 60))