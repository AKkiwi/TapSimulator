--[[
    TapSim Auto-Farm - Main Entry Point
    Ce script charge la logique puis l'UI
]]

print("=" .. string.rep("=", 60))
print("🚀 TapSim Auto-Farm - Initialisation...")
print("=" .. string.rep("=", 60))

-- ============================================
-- CHARGER LA LOGIQUE
-- ============================================

print("📦 Chargement de la logique...")

local success, Logic = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/AKkiwi/TapSimulator/refs/heads/master/CheatLogic.lua'))()
end)

if not success or not Logic then
    return warn("❌ ERREUR : Impossible de charger la logique depuis GitHub!")
end

if not getgenv().TapSimLogic then
    return warn("❌ ERREUR : La logique n'a pas été exposée correctement!")
end

print("✅ Logique chargée avec succès!")

local Flags = Logic.Flags
local Funcs = Logic.Functions
local Stats = Logic.Stats

-- ============================================
-- CHARGER RAYFIELD
-- ============================================

print("🎨 Chargement de l'interface Rayfield...")

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
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ============================================
-- MOBILE BUTTON
-- ============================================

local function create_toggle_button()
    if game.CoreGui:FindFirstChild("TapSimToggleButton") then
        game.CoreGui.TapSimToggleButton:Destroy()
    end
    
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "TapSimToggleButton"
    screen_gui.Parent = game:GetService("CoreGui")
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = UDim2.new(1, -60, 0.5, -25)
    button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    button.Text = "🚀"
    button.TextSize = 25
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Parent = screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.ZIndex = 0
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.Parent = button

    -- Drag Logic
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    button.Activated:Connect(function()
        Rayfield:Toggle()
    end)
    
    return screen_gui
end

create_toggle_button()

-- ============================================
-- TABS
-- ============================================

local MainTab = Window:CreateTab("🏠 Main", "home")
local FarmTab = Window:CreateTab("🌾 Farm", "sprout")
local ShopTab = Window:CreateTab("🛒 Shop", "shopping-cart")
local MiscTab = Window:CreateTab("⚙️ Misc", "settings")

-- ============================================
-- MAIN TAB
-- ============================================

local ClickSection = MainTab:CreateSection("Auto Click")

MainTab:CreateToggle({
    Name = "🖱️ Auto Click",
    CurrentValue = Flags.auto_click,
    Flag = "AutoClick",
    Callback = function(v)
        Flags.auto_click = v
        if v then
            Funcs:StartAutoClick()
            Rayfield:Notify({Title="✅ Auto Click", Content="Activé", Duration=2, Image="check"})
        else
            Funcs:StopAutoClick()
            Rayfield:Notify({Title="❌ Auto Click", Content="Désactivé", Duration=2, Image="x"})
        end
    end,
})

MainTab:CreateSlider({
    Name = "⚡ Click Speed",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = Flags.click_speed,
    Flag = "ClickSpeed",
    Callback = function(v)
        Flags.click_speed = v
    end,
})

local RebirthSection = MainTab:CreateSection("Auto Rebirth")

MainTab:CreateToggle({
    Name = "♻️ Auto Rebirth",
    CurrentValue = Flags.auto_rebirth,
    Flag = "AutoRebirth",
    Callback = function(v)
        Flags.auto_rebirth = v
        if v then
            Funcs:StartAutoRebirth()
            Rayfield:Notify({Title="✅ Auto Rebirth", Content="Activé", Duration=2, Image="check"})
        else
            Funcs:StopAutoRebirth()
            Rayfield:Notify({Title="❌ Auto Rebirth", Content="Désactivé", Duration=2, Image="x"})
        end
    end,
})

MainTab:CreateSlider({
    Name = "⏱️ Rebirth Delay",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = Flags.rebirth_delay,
    Flag = "RebirthDelay",
    Callback = function(v)
        Flags.rebirth_delay = v
    end,
})

MainTab:CreateDivider()

local StatsLabel = MainTab:CreateLabel("📊 Stats: Loading...")

-- Update stats label in real-time
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            StatsLabel:Set(string.format(
                "📊 Clicks: %s | Rebirths: %s | Packs: %s | Runtime: %ds",
                tostring(Stats.clicks),
                tostring(Stats.rebirths),
                tostring(Stats.packs_claimed),
                Stats.runtime
            ))
        end)
    end
end)

-- ============================================
-- FARM TAB
-- ============================================

local PetSection = FarmTab:CreateSection("Pet Farm")

FarmTab:CreateToggle({
    Name = "🐾 Auto Pet Farm",
    CurrentValue = Flags.auto_pet_farm,
    Flag = "AutoPetFarm",
    Callback = function(v)
        Flags.auto_pet_farm = v
        if v then
            Funcs:StartAutoPetFarm()
            Rayfield:Notify({Title="✅ Pet Farm", Content="Activé", Duration=2, Image="check"})
        else
            Funcs:StopAutoPetFarm()
            Rayfield:Notify({Title="❌ Pet Farm", Content="Désactivé", Duration=2, Image="x"})
        end
    end,
})

local PackSection = FarmTab:CreateSection("Packs & Rewards")

FarmTab:CreateToggle({
    Name = "🎁 Auto Claim Packs",
    CurrentValue = Flags.auto_claim_packs,
    Flag = "AutoClaimPacks",
    Callback = function(v)
        Flags.auto_claim_packs = v
        if v then
            Funcs:StartAutoClaimPacks()
            Rayfield:Notify({Title="✅ Auto Claim", Content="Activé", Duration=2, Image="check"})
        else
            Funcs:StopAutoClaimPacks()
            Rayfield:Notify({Title="❌ Auto Claim", Content="Désactivé", Duration=2, Image="x"})
        end
    end,
})

FarmTab:CreateSlider({
    Name = "Claim Delay",
    Range = {1, 30},
    Increment = 1,
    Suffix = "s",
    CurrentValue = Flags.claim_delay,
    Callback = function(v)
        Flags.claim_delay = v
    end,
})

local EggSection = FarmTab:CreateSection("Eggs")

FarmTab:CreateToggle({
    Name = "🥚 Auto Buy Eggs",
    CurrentValue = Flags.auto_buy_eggs,
    Flag = "AutoBuyEggs",
    Callback = function(v)
        Flags.auto_buy_eggs = v
        if v then
            Funcs:StartAutoBuyEggs()
            Rayfield:Notify({Title="✅ Auto Buy Eggs", Content="Activé", Duration=2, Image="check"})
        else
            Funcs:StopAutoBuyEggs()
            Rayfield:Notify({Title="❌ Auto Buy Eggs", Content="Désactivé", Duration=2, Image="x"})
        end
    end,
})

-- ============================================
-- SHOP TAB
-- ============================================

ShopTab:CreateButton({
    Name = "💎 Claim Forever Pack",
    Callback = function()
        if Funcs:ClaimForeverPack() then
            Rayfield:Notify({Title="✅ Forever Pack", Content="Claimed!", Duration=2, Image="gift"})
        else
            Rayfield:Notify({Title="❌ Error", Content="Remote not found", Duration=2, Image="alert-circle"})
        end
    end,
})

ShopTab:CreateButton({
    Name = "📦 Request Forever Pack",
    Callback = function()
        if Funcs:RequestForeverPack() then
            Rayfield:Notify({Title="✅ Request", Content="Envoyé!", Duration=2, Image="send"})
        else
            Rayfield:Notify({Title="❌ Error", Content="Remote not found", Duration=2, Image="alert-circle"})
        end
    end,
})

ShopTab:CreateButton({
    Name = "🎁 Claim All Visible Rewards",
    Callback = function()
        local claimed = Funcs:ClaimAllVisibleRewards()
        Rayfield:Notify({
            Title="✅ Claimed", 
            Content=claimed .. " rewards claimed!", 
            Duration=3, 
            Image="gift"
        })
    end,
})

-- ============================================
-- MISC TAB
-- ============================================

MiscTab:CreateButton({
    Name = "🔄 Re-scan Remotes",
    Callback = function()
        Funcs:FindObfuscatedRemotes()
        Rayfield:Notify({Title="🔍 Scan", Content="Remotes re-scannés", Duration=2, Image="search"})
    end,
})

MiscTab:CreateButton({
    Name = "👁️ Show Hidden UIs",
    Callback = function()
        local count = Funcs:ShowHiddenUIs()
        Rayfield:Notify({
            Title="✅ UI Unlocked", 
            Content=count .. " UIs activés", 
            Duration=3, 
            Image="eye"
        })
    end,
})

MiscTab:CreateButton({
    Name = "🔥 Fire All Purchase Remotes",
    Callback = function()
        if Funcs:FireAllPurchaseRemotes() then
            Rayfield:Notify({Title="✅ Purchase", Content="Remotes fired!", Duration=2, Image="zap"})
        else
            Rayfield:Notify({Title="❌ Error", Content="Remote not found", Duration=2, Image="alert-circle"})
        end
    end,
})

MiscTab:CreateDivider()

MiscTab:CreateLabel("⚠️ Experimental Features")

MiscTab:CreateButton({
    Name = "💣 Spam All Obfuscated Remotes",
    Callback = function()
        Rayfield:Notify({Title="⚠️ Warning", Content="Spamming all remotes...", Duration=3, Image="alert-triangle"})
        task.wait(0.5)
        if Funcs:SpamAllObfuscatedRemotes() then
            Rayfield:Notify({Title="✅ Done", Content="All remotes fired!", Duration=2, Image="check"})
        else
            Rayfield:Notify({Title="❌ Error", Content="Could not find remotes", Duration=2, Image="alert-circle"})
        end
    end,
})

MiscTab:CreateDivider()

MiscTab:CreateButton({
    Name = "🗑️ Destroy UI & Logic",
    Callback = function()
        -- Clean mobile button
        if game.CoreGui:FindFirstChild("TapSimToggleButton") then
            game.CoreGui.TapSimToggleButton:Destroy()
        end
        
        -- Stop all loops
        if Logic and Logic.Loops then
            for k, v in pairs(Logic.Loops) do
                if type(v) == "thread" then
                    pcall(function() task.cancel(v) end)
                end
            end
        end
        
        -- Clear global
        getgenv().TapSimLogic = nil
        
        -- Destroy UI
        Rayfield:Destroy()
        
        print("🗑️ TapSim destroyed successfully")
    end,
})

-- ============================================
-- FINALIZATION
-- ============================================

print("=" .. string.rep("=", 60))
print("✅ TapSim UI - Chargé avec succès!")
print("📱 Utilisez le bouton 🚀 pour afficher/cacher l'UI")
print("=" .. string.rep("=", 60))