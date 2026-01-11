-- ============================================
-- TAPSIM AUTO-FARM AFK - VERSION ANDROID
-- Sans dépendance externe (pas besoin de Rayfield)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- CHEAT LOGIC
-- ============================================

local CheatLogic = {
    Config = {
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
    },
    
    Stats = {
        clicks = 0,
        rebirths = 0,
        packsClaimed = 0,
        eggsHatched = 0,
        runtime = 0
    }
}

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
end

function CheatLogic:FindObfuscatedRemotes()
    print("🔍 Recherche des remotes...")
    
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
                print("✅ Click Remote:", self.Config.clickRemote.Name)
            end
            if #allEvents >= 2 then
                self.Config.rebirthRemote = allEvents[2]
                print("✅ Rebirth Remote:", self.Config.rebirthRemote.Name)
            end
        end
    end
    
    if not self.Config.clickRemote then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                if name:find("tap") or text:find("tap") then
                    self.Config.clickRemote = ui
                    print("✅ Click Button:", ui.Name)
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
                if name:find("rebirth") or text:find("rebirth") then
                    self.Config.rebirthRemote = ui
                    print("✅ Rebirth Button:", ui.Name)
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
                    if ui:IsA("TextButton") and ui.Visible then
                        local name = ui.Name:lower()
                        local text = ui.Text:lower()
                        if name:find("claim") or text:find("claim") then
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
                        if desc:IsA("TextButton") and desc.Visible then
                            local name = desc.Name:lower()
                            if name:find("buy") then
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

-- ============================================
-- SIMPLE UI (pas besoin de Rayfield)
-- ============================================

print("🚀 TapSim Auto-Farm - Chargement...")

-- Chercher les remotes
task.wait(2)
CheatLogic:FindObfuscatedRemotes()

-- Stats update loop
task.spawn(function()
    while task.wait(1) do
        CheatLogic.Stats.runtime = CheatLogic.Stats.runtime + 1
        CheatLogic:UpdateStats()
    end
end)

print("=" .. string.rep("=", 60))
print("✅ TapSim Auto-Farm - Chargé avec succès!")
print("=" .. string.rep("=", 60))
print("Remotes trouvés:")
print("  Click:", CheatLogic.Config.clickRemote and CheatLogic.Config.clickRemote.Name or "NOT FOUND")
print("  Rebirth:", CheatLogic.Config.rebirthRemote and CheatLogic.Config.rebirthRemote.Name or "NOT FOUND")
print("  Purchase:", CheatLogic.Config.purchaseRemote and "OK" or "NOT FOUND")
print("  ForeverPack:", CheatLogic.Config.foreverPackClaim and "OK" or "NOT FOUND")
print("  PetAttack:", CheatLogic.Config.petAttackEvent and "OK" or "NOT FOUND")
print("=" .. string.rep("=", 60))
print("")
print("📋 COMMANDES DISPONIBLES:")
print("=" .. string.rep("=", 60))
print("_G.StartAutoClick()       -- Démarrer auto click")
print("_G.StopAutoClick()        -- Arrêter auto click")
print("_G.StartAutoRebirth()     -- Démarrer auto rebirth")
print("_G.StopAutoRebirth()      -- Arrêter auto rebirth")
print("_G.StartAutoClaimPacks()  -- Démarrer auto claim")
print("_G.StopAutoClaimPacks()   -- Arrêter auto claim")
print("_G.StartAutoPetFarm()     -- Démarrer pet farm")
print("_G.StopAutoPetFarm()      -- Arrêter pet farm")
print("_G.StartAutoBuyEggs()     -- Démarrer auto buy eggs")
print("_G.StopAutoBuyEggs()      -- Arrêter auto buy eggs")
print("")
print("_G.SetClickSpeed(0.05)    -- Changer vitesse (en secondes)")
print("_G.SetRebirthDelay(2)     -- Changer délai rebirth")
print("_G.ClaimForeverPack()     -- Claim forever pack")
print("_G.ShowStats()            -- Afficher les stats")
print("_G.RescanRemotes()        -- Re-scanner les remotes")
print("=" .. string.rep("=", 60))

-- ============================================
-- FONCTIONS GLOBALES (accessibles via _G)
-- ============================================

_G.StartAutoClick = function()
    CheatLogic:StartAutoClick()
    print("✅ Auto Click activé")
end

_G.StopAutoClick = function()
    CheatLogic:StopAutoClick()
    print("❌ Auto Click désactivé")
end

_G.StartAutoRebirth = function()
    CheatLogic:StartAutoRebirth()
    print("✅ Auto Rebirth activé")
end

_G.StopAutoRebirth = function()
    CheatLogic:StopAutoRebirth()
    print("❌ Auto Rebirth désactivé")
end

_G.StartAutoClaimPacks = function()
    CheatLogic:StartAutoClaimPacks()
    print("✅ Auto Claim Packs activé")
end

_G.StopAutoClaimPacks = function()
    CheatLogic:StopAutoClaimPacks()
    print("❌ Auto Claim Packs désactivé")
end

_G.StartAutoPetFarm = function()
    CheatLogic:StartAutoPetFarm()
    print("✅ Auto Pet Farm activé")
end

_G.StopAutoPetFarm = function()
    CheatLogic:StopAutoPetFarm()
    print("❌ Auto Pet Farm désactivé")
end

_G.StartAutoBuyEggs = function()
    CheatLogic:StartAutoBuyEggs()
    print("✅ Auto Buy Eggs activé")
end

_G.StopAutoBuyEggs = function()
    CheatLogic:StopAutoBuyEggs()
    print("❌ Auto Buy Eggs désactivé")
end

_G.SetClickSpeed = function(speed)
    CheatLogic.Config.ClickSpeed = speed
    print("⚡ Click speed défini à", speed, "secondes")
end

_G.SetRebirthDelay = function(delay)
    CheatLogic.Config.RebirthDelay = delay
    print("⏱️ Rebirth delay défini à", delay, "secondes")
end

_G.ClaimForeverPack = function()
    if CheatLogic.Config.foreverPackClaim then
        CheatLogic.Config.foreverPackClaim:FireServer()
        print("💎 Forever Pack réclamé!")
    else
        print("❌ Forever Pack remote non trouvé")
    end
end

_G.ShowStats = function()
    print("=" .. string.rep("=", 60))
    print("📊 STATISTIQUES")
    print("=" .. string.rep("=", 60))
    print("Clicks:", CheatLogic.Stats.clicks)
    print("Rebirths:", CheatLogic.Stats.rebirths)
    print("Packs Claimed:", CheatLogic.Stats.packsClaimed)
    print("Eggs Hatched:", CheatLogic.Stats.eggsHatched)
    print("Runtime:", CheatLogic.Stats.runtime, "secondes")
    print("=" .. string.rep("=", 60))
end

_G.RescanRemotes = function()
    CheatLogic:FindObfuscatedRemotes()
    print("🔄 Remotes re-scannés")
end

-- ============================================
-- AUTO-START (optionnel)
-- ============================================

-- Décommenter pour démarrer automatiquement:
-- _G.StartAutoClick()
-- _G.StartAutoRebirth()