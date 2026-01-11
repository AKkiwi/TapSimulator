-- ============================================
-- TAPSIM AUTO-FARM AFK - VERSION COMPLETE
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- CHEAT LOGIC MODULE
-- ============================================

local CheatLogic = {}

CheatLogic.Config = {
    AutoClick = false,
    AutoRebirth = false,
    AutoClaimPacks = false,
    AutoPetFarm = false,
    AutoBuyEggs = false,
    
    ClickSpeed = 0.1,
    RebirthDelay = 1,
    ClaimDelay = 5,
    
    clickRemote = nil,
    rebirthRemote = nil,
    purchaseRemote = nil,
    foreverPackRequest = nil,
    foreverPackClaim = nil,
    petAttackEvent = nil,
}

CheatLogic.Stats = {
    clicks = 0,
    rebirths = 0,
    packsClaimed = 0,
    eggsHatched = 0,
    runtime = 0
}

CheatLogic.Callbacks = {
    onNotify = nil,
    onStatsUpdate = nil,
    onRemoteFound = nil,
}

function CheatLogic:Notify(title, content, duration)
    if self.Callbacks.onNotify then
        self.Callbacks.onNotify(title, content, duration or 3)
    else
        print(string.format("[%s] %s", title, content))
    end
end

function CheatLogic:UpdateStats()
    if player:FindFirstChild("leaderstats") then
        local clicks = player.leaderstats:FindFirstChild("Clicks")
        local rebirths = player.leaderstats:FindFirstChild("Rebirths")
        
        if clicks then
            self.Stats.clicks = tonumber(clicks.Value) or 0
        end
        
        if rebirths then
            self.Stats.rebirths = tonumber(rebirths.Value) or 0
        end
    end
    
    if self.Callbacks.onStatsUpdate then
        self.Callbacks.onStatsUpdate(self.Stats)
    end
end

function CheatLogic:FindObfuscatedRemotes()
    self:Notify("🔍 Recherche", "Scan des remotes obfusqués...", 3)
    
    local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
    if not obfFolder then
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            if child.Name:match("%x+-%x+-%x+-%x+-%x+") then
                obfFolder = child
                break
            end
        end
    end
    
    if obfFolder then
        local eventsFolder = obfFolder:FindFirstChild("Events")
        
        if eventsFolder then
            local allEvents = eventsFolder:GetChildren()
            if #allEvents >= 1 then
                self.Config.clickRemote = allEvents[1]
                self:Notify("✅ Click Remote", "Trouvé: " .. self.Config.clickRemote.Name, 3)
            end
            if #allEvents >= 2 then
                self.Config.rebirthRemote = allEvents[2]
                self:Notify("✅ Rebirth Remote", "Trouvé: " .. self.Config.rebirthRemote.Name, 3)
            end
        end
    end
    
    if not self.Config.clickRemote then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                
                if name:find("tap") or text:find("tap") or name == "Tap" then
                    self.Config.clickRemote = ui
                    self:Notify("✅ Click Button", "Trouvé: " .. ui.Name, 3)
                    break
                end
            end
        end
    end
    
    if not self.Config.rebirthRemote then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                
                if name:find("rebirth") or text:find("rebirth") or name:find("prestige") then
                    self.Config.rebirthRemote = ui
                    self:Notify("✅ Rebirth Button", "Trouvé: " .. ui.Name, 3)
                    break
                end
            end
        end
    end
    
    self.Config.purchaseRemote = ReplicatedStorage:FindFirstChild("PurchasePack")
    self.Config.foreverPackRequest = ReplicatedStorage:FindFirstChild("ForeverPackRequest")
    self.Config.foreverPackClaim = ReplicatedStorage:FindFirstChild("ForeverPackClaim")
    self.Config.petAttackEvent = ReplicatedStorage:FindFirstChild("PetAttackEvent")
end

function CheatLogic:ExecuteRemote(remote)
    if not remote then return false end
    
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer()
        elseif remote:IsA("TextButton") then
            for _, connection in pairs(getconnections(remote.MouseButton1Click)) do
                connection:Fire()
            end
        end
    end)
    
    return true
end

function CheatLogic:StartAutoClick()
    self.Config.AutoClick = true
    
    task.spawn(function()
        while self.Config.AutoClick do
            self:ExecuteRemote(self.Config.clickRemote)
            task.wait(self.Config.ClickSpeed)
        end
    end)
end

function CheatLogic:StopAutoClick()
    self.Config.AutoClick = false
end

function CheatLogic:StartAutoRebirth()
    self.Config.AutoRebirth = true
    
    task.spawn(function()
        while self.Config.AutoRebirth do
            self:ExecuteRemote(self.Config.rebirthRemote)
            task.wait(self.Config.RebirthDelay)
        end
    end)
end

function CheatLogic:StopAutoRebirth()
    self.Config.AutoRebirth = false
end

function CheatLogic:StartAutoClaimPacks()
    self.Config.AutoClaimPacks = true
    
    task.spawn(function()
        while self.Config.AutoClaimPacks do
            pcall(function()
                if self.Config.foreverPackClaim then
                    self.Config.foreverPackClaim:FireServer()
                    self.Stats.packsClaimed = self.Stats.packsClaimed + 1
                end
                
                if self.Config.foreverPackRequest then
                    self.Config.foreverPackRequest:FireServer()
                end
                
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
            task.wait(self.Config.ClaimDelay)
        end
    end)
end

function CheatLogic:StopAutoClaimPacks()
    self.Config.AutoClaimPacks = false
end

function CheatLogic:StartAutoPetFarm()
    self.Config.AutoPetFarm = true
    
    task.spawn(function()
        while self.Config.AutoPetFarm do
            self:ExecuteRemote(self.Config.petAttackEvent)
            task.wait(0.1)
        end
    end)
end

function CheatLogic:StopAutoPetFarm()
    self.Config.AutoPetFarm = false
end

function CheatLogic:StartAutoBuyEggs()
    self.Config.AutoBuyEggs = true
    
    task.spawn(function()
        while self.Config.AutoBuyEggs do
            pcall(function()
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
                                self.Stats.eggsHatched = self.Stats.eggsHatched + 1
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

function CheatLogic:StopAutoBuyEggs()
    self.Config.AutoBuyEggs = false
end

function CheatLogic:ClaimForeverPack()
    if self.Config.foreverPackClaim then
        self.Config.foreverPackClaim:FireServer()
        return true
    end
    return false
end

function CheatLogic:RequestForeverPack()
    if self.Config.foreverPackRequest then
        self.Config.foreverPackRequest:FireServer()
        return true
    end
    return false
end

function CheatLogic:ClaimAllVisibleRewards()
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
    return claimed
end

function CheatLogic:ShowHiddenUIs()
    local count = 0
    for _, ui in ipairs(gui:GetChildren()) do
        if ui:IsA("ScreenGui") and not ui.Enabled then
            ui.Enabled = true
            count = count + 1
        end
    end
    return count
end

function CheatLogic:FireAllPurchaseRemotes()
    if self.Config.purchaseRemote then
        self.Config.purchaseRemote:FireServer("Free", 0)
        self.Config.purchaseRemote:FireServer("ForeverPack", 0)
        return true
    end
    return false
end

function CheatLogic:SpamAllObfuscatedRemotes()
    local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
    if obfFolder then
        local eventsFolder = obfFolder:FindFirstChild("Events")
        if eventsFolder then
            for _, remote in ipairs(eventsFolder:GetChildren()) do
                self:ExecuteRemote(remote)
                task.wait(0.1)
            end
            return true
        end
    end
    return false
end

function CheatLogic:Initialize()
    self:Notify("🚀 TapSim Auto-Farm", "Initialisation...", 3)
    
    task.wait(2)
    self:FindObfuscatedRemotes()
    
    task.spawn(function()
        while task.wait(1) do
            self.Stats.runtime = self.Stats.runtime + 1
            self:UpdateStats()
        end
    end)
    
    self:Notify("✅ Loaded", "TapSim Auto-Farm ready!", 3)
    
    print("=" .. string.rep("=", 60))
    print("TapSim Auto-Farm - Loaded Successfully")
    print("Remotes found:")
    print("  Click:", self.Config.clickRemote and self.Config.clickRemote.Name or "NOT FOUND")
    print("  Rebirth:", self.Config.rebirthRemote and self.Config.rebirthRemote.Name or "NOT FOUND")
    print("  Purchase:", self.Config.purchaseRemote and "OK" or "NOT FOUND")
    print("  ForeverPack:", self.Config.foreverPackClaim and "OK" or "NOT FOUND")
    print("  PetAttack:", self.Config.petAttackEvent and "OK" or "NOT FOUND")
    print("=" .. string.rep("=", 60))
end

-- ============================================
-- RAYFIELD UI
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🚀 TapSim Auto-Farm AFK",
    Icon = 0,
    LoadingTitle = "TapSim Exploit",
    LoadingSubtitle = "by maxoupixo4",
    ShowText = "TapSim",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "TapSimConfig"
    }
})

-- Setup callbacks
CheatLogic.Callbacks.onNotify = function(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = "activity"
    })
end

local StatsLabel = nil

CheatLogic.Callbacks.onStatsUpdate = function(stats)
    if StatsLabel then
        pcall(function()
            StatsLabel:Set(string.format(
                "📊 Clicks: %s | Rebirths: %s | Runtime: %ds",
                tostring(stats.clicks),
                tostring(stats.rebirths),
                stats.runtime
            ))
        end)
    end
end

-- ============================================
-- MAIN TAB
-- ============================================

local MainTab = Window:CreateTab("🏠 Main", "home")

MainTab:CreateToggle({
    Name = "🖱️ Auto Click",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
        if Value then
            CheatLogic:StartAutoClick()
            CheatLogic:Notify("✅ Auto Click", "Activé", 2)
        else
            CheatLogic:StopAutoClick()
            CheatLogic:Notify("❌ Auto Click", "Désactivé", 2)
        end
    end
})

MainTab:CreateSlider({
    Name = "⚡ Click Speed",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "ClickSpeed",
    Callback = function(Value)
        CheatLogic.Config.ClickSpeed = Value
    end
})

MainTab:CreateToggle({
    Name = "♻️ Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        if Value then
            CheatLogic:StartAutoRebirth()
            CheatLogic:Notify("✅ Auto Rebirth", "Activé", 2)
        else
            CheatLogic:StopAutoRebirth()
            CheatLogic:Notify("❌ Auto Rebirth", "Désactivé", 2)
        end
    end
})

MainTab:CreateSlider({
    Name = "⏱️ Rebirth Delay",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "RebirthDelay",
    Callback = function(Value)
        CheatLogic.Config.RebirthDelay = Value
    end
})

MainTab:CreateDivider()

StatsLabel = MainTab:CreateLabel("📊 Stats: Loading...")

-- ============================================
-- FARM TAB
-- ============================================

local FarmTab = Window:CreateTab("🌾 Farm", "sprout")

FarmTab:CreateToggle({
    Name = "🐾 Auto Pet Farm",
    CurrentValue = false,
    Flag = "AutoPetFarm",
    Callback = function(Value)
        if Value then
            CheatLogic:StartAutoPetFarm()
            CheatLogic:Notify("✅ Pet Farm", "Activé", 2)
        else
            CheatLogic:StopAutoPetFarm()
            CheatLogic:Notify("❌ Pet Farm", "Désactivé", 2)
        end
    end
})

FarmTab:CreateToggle({
    Name = "🎁 Auto Claim Packs",
    CurrentValue = false,
    Flag = "AutoClaimPacks",
    Callback = function(Value)
        if Value then
            CheatLogic:StartAutoClaimPacks()
            CheatLogic:Notify("✅ Auto Claim", "Activé", 2)
        else
            CheatLogic:StopAutoClaimPacks()
            CheatLogic:Notify("❌ Auto Claim", "Désactivé", 2)
        end
    end
})

FarmTab:CreateToggle({
    Name = "🥚 Auto Buy Eggs",
    CurrentValue = false,
    Flag = "AutoBuyEggs",
    Callback = function(Value)
        if Value then
            CheatLogic:StartAutoBuyEggs()
            CheatLogic:Notify("✅ Auto Buy Eggs", "Activé", 2)
        else
            CheatLogic:StopAutoBuyEggs()
            CheatLogic:Notify("❌ Auto Buy Eggs", "Désactivé", 2)
        end
    end
})

-- ============================================
-- SHOP TAB
-- ============================================

local ShopTab = Window:CreateTab("🛒 Shop", "shopping-cart")

ShopTab:CreateButton({
    Name = "💎 Claim Forever Pack",
    Callback = function()
        if CheatLogic:ClaimForeverPack() then
            CheatLogic:Notify("✅ Forever Pack", "Claimed!", 2)
        else
            CheatLogic:Notify("❌ Error", "Remote not found", 2)
        end
    end
})

ShopTab:CreateButton({
    Name = "📦 Request Forever Pack",
    Callback = function()
        if CheatLogic:RequestForeverPack() then
            CheatLogic:Notify("✅ Request", "Envoyé!", 2)
        else
            CheatLogic:Notify("❌ Error", "Remote not found", 2)
        end
    end
})

ShopTab:CreateButton({
    Name = "🎁 Claim All Visible Rewards",
    Callback = function()
        local claimed = CheatLogic:ClaimAllVisibleRewards()
        CheatLogic:Notify("✅ Claimed", claimed .. " rewards!", 3)
    end
})

-- ============================================
-- MISC TAB
-- ============================================

local MiscTab = Window:CreateTab("⚙️ Misc", "settings")

MiscTab:CreateButton({
    Name = "🔄 Re-scan Remotes",
    Callback = function()
        CheatLogic:FindObfuscatedRemotes()
    end
})

MiscTab:CreateButton({
    Name = "👁️ Show Hidden UIs",
    Callback = function()
        local count = CheatLogic:ShowHiddenUIs()
        CheatLogic:Notify("✅ UI Unlocked", count .. " UIs activés", 3)
    end
})

MiscTab:CreateButton({
    Name = "🔥 Fire All Purchase Remotes",
    Callback = function()
        if CheatLogic:FireAllPurchaseRemotes() then
            CheatLogic:Notify("✅ Purchase", "Remotes fired!", 2)
        else
            CheatLogic:Notify("❌ Error", "Remote not found", 2)
        end
    end
})

MiscTab:CreateDivider()

MiscTab:CreateLabel("⚠️ Experimental Features")

MiscTab:CreateButton({
    Name = "💣 Spam All Obfuscated Remotes",
    Callback = function()
        CheatLogic:Notify("⚠️ Warning", "Spamming all remotes...", 3)
        if CheatLogic:SpamAllObfuscatedRemotes() then
            CheatLogic:Notify("✅ Done", "All remotes fired!", 2)
        else
            CheatLogic:Notify("❌ Error", "Could not find remotes", 2)
        end
    end
})

-- ============================================
-- INITIALIZATION
-- ============================================

CheatLogic:Initialize()