-- ============================================
-- TAPSIM UI - RAYFIELD EDITION
-- ============================================

-- Charger la logique de triche
local CheatLogic = loadstring(game:HttpGet('YOUR_CHEATLOGIC_URL_HERE'))()
-- OU si vous utilisez un module local:
-- local CheatLogic = require(script.Parent.CheatLogic)

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
-- SETUP CALLBACKS
-- ============================================

CheatLogic.Callbacks.onNotify = function(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458
    })
end

local StatsLabel = nil  -- Sera créé plus tard

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
-- UI TABS
-- ============================================

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

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
    Name = "⚡ Click Speed (s)",
    Range = {0.01, 1},
    Increment = 0.01,
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
    Name = "⏱️ Rebirth Delay (s)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "RebirthDelay",
    Callback = function(Value)
        CheatLogic.Config.RebirthDelay = Value
    end
})

MainTab:CreateDivider()

StatsLabel = MainTab:CreateLabel("📊 Stats: Loading...")

-- Farm Tab
local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)

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

-- Shop Tab
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)

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

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

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