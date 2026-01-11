--[[
    TapSim Auto-Farm - Complete Version
    Structure copiée du code qui fonctionne
]]

local start_tick = tick()

-- Services (charger AVANT Rayfield)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Configuration
local flags = {
    auto_click = false,
    auto_rebirth = false,
    auto_claim_packs = false,
    auto_pet_farm = false,
    auto_buy_eggs = false,
    
    click_speed = 0.1,
    rebirth_delay = 1,
    claim_delay = 5,
}

local stats = {
    clicks = 0,
    rebirths = 0,
    packs_claimed = 0,
    eggs_hatched = 0,
    runtime = 0
}

local remotes = {
    click = nil,
    rebirth = nil,
    purchase = nil,
    forever_pack_request = nil,
    forever_pack_claim = nil,
    pet_attack = nil,
}

local connections = {}

-- Utility Functions
local function safe_call(func)
    local success, result = pcall(func)
    if not success then
        warn("[Script Error]:", result)
        return false, result
    end
    return true, result
end

local function update_stats()
    if player:FindFirstChild("leaderstats") then
        local clicks = player.leaderstats:FindFirstChild("Clicks")
        local rebirths = player.leaderstats:FindFirstChild("Rebirths")
        
        if clicks then
            stats.clicks = tonumber(clicks.Value) or 0
        end
        
        if rebirths then
            stats.rebirths = tonumber(rebirths.Value) or 0
        end
    end
end

local function find_obfuscated_remotes()
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
                remotes.click = allEvents[1]
                print("✅ Click Remote:", remotes.click.Name)
            end
            if #allEvents >= 2 then
                remotes.rebirth = allEvents[2]
                print("✅ Rebirth Remote:", remotes.rebirth.Name)
            end
        end
    end
    
    if not remotes.click then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                if name:find("tap") or text:find("tap") then
                    remotes.click = ui
                    print("✅ Click Button:", ui.Name)
                    break
                end
            end
        end
    end
    
    if not remotes.rebirth then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                if name:find("rebirth") or text:find("rebirth") then
                    remotes.rebirth = ui
                    print("✅ Rebirth Button:", ui.Name)
                    break
                end
            end
        end
    end
    
    remotes.purchase = ReplicatedStorage:FindFirstChild("PurchasePack")
    remotes.forever_pack_request = ReplicatedStorage:FindFirstChild("ForeverPackRequest")
    remotes.forever_pack_claim = ReplicatedStorage:FindFirstChild("ForeverPackClaim")
    remotes.pet_attack = ReplicatedStorage:FindFirstChild("PetAttackEvent")
end

local function execute_remote(remote)
    if not remote then return false end
    
    safe_call(function()
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

-- Chercher les remotes AVANT de charger Rayfield
task.wait(2)
find_obfuscated_remotes()

-- MAINTENANT on charge Rayfield
print("🎨 Chargement de Rayfield...")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🚀 TapSim Auto-Farm AFK",
    LoadingTitle = "TapSim Exploit",
    LoadingSubtitle = "by maxoupixo4",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TapSimWare",
        FileName = "TapSim_Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Créer le bouton mobile
local function create_toggle_button()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "TapSimToggleButton"
    screen_gui.ResetOnSpawn = false
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.Parent = game:GetService("CoreGui")
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -70, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = "🚀"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 30
    button.Parent = screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 150, 200)
    stroke.Thickness = 3
    stroke.Parent = button
    
    button.Activated:Connect(function()
        Rayfield:Toggle()
        button.Size = UDim2.new(0, 55, 0, 55)
        task.wait(0.1)
        button.Size = UDim2.new(0, 60, 0, 60)
    end)
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 170, 230)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    local dragging = false
    local drag_input, drag_start, start_pos
    
    local function update(input)
        local delta = input.Position - drag_start
        button.Position = UDim2.new(
            start_pos.X.Scale,
            start_pos.X.Offset + delta.X,
            start_pos.Y.Scale,
            start_pos.Y.Offset + delta.Y
        )
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            update(input)
        end
    end)
    
    return screen_gui
end

local toggle_button_gui = create_toggle_button()

print("🚀 TAPSIM WARE LOADED! Tap the blue button to toggle UI!")

-- Tabs
local MainTab = Window:CreateTab("🎯 Main", 4483362458)
local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- Main Tab
local ClickSection = MainTab:CreateSection("Auto Click")

MainTab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(value)
        flags.auto_click = value
        
        if connections.auto_click then
            connections.auto_click:Disconnect()
            connections.auto_click = nil
        end
        
        if flags.auto_click then
            local last_click_time = 0
            connections.auto_click = RunService.Heartbeat:Connect(function()
                if tick() - last_click_time < flags.click_speed then
                    return
                end
                
                execute_remote(remotes.click)
                last_click_time = tick()
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Click Speed (seconds)",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Flag = "ClickSpeed",
    Callback = function(value)
        flags.click_speed = value
    end,
})

local RebirthSection = MainTab:CreateSection("Auto Rebirth")

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(value)
        flags.auto_rebirth = value
        
        if connections.auto_rebirth then
            connections.auto_rebirth:Disconnect()
            connections.auto_rebirth = nil
        end
        
        if flags.auto_rebirth then
            local last_rebirth_time = 0
            connections.auto_rebirth = RunService.Heartbeat:Connect(function()
                if tick() - last_rebirth_time < flags.rebirth_delay then
                    return
                end
                
                execute_remote(remotes.rebirth)
                last_rebirth_time = tick()
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Rebirth Delay (seconds)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "RebirthDelay",
    Callback = function(value)
        flags.rebirth_delay = value
    end,
})

MainTab:CreateDivider()

local StatsLabel = MainTab:CreateLabel("📊 Stats: Loading...")

-- Stats update loop
task.spawn(function()
    while task.wait(1) do
        stats.runtime = stats.runtime + 1
        update_stats()
        
        safe_call(function()
            StatsLabel:Set(string.format(
                "📊 Clicks: %s | Rebirths: %s | Runtime: %ds",
                tostring(stats.clicks),
                tostring(stats.rebirths),
                stats.runtime
            ))
        end)
    end
end)

-- Farm Tab
local PetSection = FarmTab:CreateSection("Pet Farm")

FarmTab:CreateToggle({
    Name = "Auto Pet Farm",
    CurrentValue = false,
    Flag = "AutoPetFarm",
    Callback = function(value)
        flags.auto_pet_farm = value
        
        if connections.auto_pet_farm then
            connections.auto_pet_farm:Disconnect()
            connections.auto_pet_farm = nil
        end
        
        if flags.auto_pet_farm then
            connections.auto_pet_farm = RunService.Heartbeat:Connect(function()
                execute_remote(remotes.pet_attack)
                task.wait(0.1)
            end)
        end
    end,
})

local PackSection = FarmTab:CreateSection("Packs & Rewards")

FarmTab:CreateToggle({
    Name = "Auto Claim Packs",
    CurrentValue = false,
    Flag = "AutoClaimPacks",
    Callback = function(value)
        flags.auto_claim_packs = value
        
        if connections.auto_claim_packs then
            connections.auto_claim_packs:Disconnect()
            connections.auto_claim_packs = nil
        end
        
        if flags.auto_claim_packs then
            local last_claim_time = 0
            connections.auto_claim_packs = RunService.Heartbeat:Connect(function()
                if tick() - last_claim_time < flags.claim_delay then
                    return
                end
                
                safe_call(function()
                    if remotes.forever_pack_claim then
                        remotes.forever_pack_claim:FireServer()
                        stats.packs_claimed = stats.packs_claimed + 1
                    end
                    
                    if remotes.forever_pack_request then
                        remotes.forever_pack_request:FireServer()
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
                
                last_claim_time = tick()
            end)
        end
    end,
})

FarmTab:CreateSlider({
    Name = "Claim Delay (seconds)",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        flags.claim_delay = value
    end,
})

local EggSection = FarmTab:CreateSection("Eggs")

FarmTab:CreateToggle({
    Name = "Auto Buy Eggs",
    CurrentValue = false,
    Flag = "AutoBuyEggs",
    Callback = function(value)
        flags.auto_buy_eggs = value
        
        if connections.auto_buy_eggs then
            connections.auto_buy_eggs:Disconnect()
            connections.auto_buy_eggs = nil
        end
        
        if flags.auto_buy_eggs then
            local last_buy_time = 0
            connections.auto_buy_eggs = RunService.Heartbeat:Connect(function()
                if tick() - last_buy_time < 2 then
                    return
                end
                
                safe_call(function()
                    local storeUI = gui.Tabs and gui.Tabs:FindFirstChild("Store")
                    if storeUI then
                        for _, desc in ipairs(storeUI:GetDescendants()) do
                            if desc:IsA("TextButton") and desc.Visible then
                                local name = desc.Name:lower()
                                if name:find("buy") then
                                    for _, connection in pairs(getconnections(desc.MouseButton1Click)) do
                                        connection:Fire()
                                    end
                                    stats.eggs_hatched = stats.eggs_hatched + 1
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end)
                
                last_buy_time = tick()
            end)
        end
    end,
})

-- Shop Tab
ShopTab:CreateButton({
    Name = "Claim Forever Pack",
    Callback = function()
        if remotes.forever_pack_claim then
            remotes.forever_pack_claim:FireServer()
            Rayfield:Notify({
                Title = "Success",
                Content = "Forever Pack claimed!",
                Duration = 2,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Remote not found",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

ShopTab:CreateButton({
    Name = "Request Forever Pack",
    Callback = function()
        if remotes.forever_pack_request then
            remotes.forever_pack_request:FireServer()
            Rayfield:Notify({
                Title = "Success",
                Content = "Request sent!",
                Duration = 2,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Remote not found",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

ShopTab:CreateButton({
    Name = "Claim All Visible Rewards",
    Callback = function()
        local claimed = 0
        safe_call(function()
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
        Rayfield:Notify({
            Title = "Success",
            Content = claimed .. " rewards claimed!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Re-scan Remotes",
    Callback = function()
        find_obfuscated_remotes()
        Rayfield:Notify({
            Title = "Scan Complete",
            Content = "Remotes rescanned",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Show Hidden UIs",
    Callback = function()
        local count = 0
        for _, ui in ipairs(gui:GetChildren()) do
            if ui:IsA("ScreenGui") and not ui.Enabled then
                ui.Enabled = true
                count = count + 1
            end
        end
        Rayfield:Notify({
            Title = "Success",
            Content = count .. " UIs unlocked",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Fire All Purchase Remotes",
    Callback = function()
        if remotes.purchase then
            remotes.purchase:FireServer("Free", 0)
            remotes.purchase:FireServer("ForeverPack", 0)
            Rayfield:Notify({
                Title = "Success",
                Content = "Remotes fired!",
                Duration = 2,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Remote not found",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

MiscTab:CreateDivider()

MiscTab:CreateLabel("⚠️ Experimental Features")

MiscTab:CreateButton({
    Name = "Spam All Obfuscated Remotes",
    Callback = function()
        Rayfield:Notify({
            Title = "Warning",
            Content = "Spamming all remotes...",
            Duration = 3,
            Image = 4483362458,
        })
        
        local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
        if obfFolder then
            local eventsFolder = obfFolder:FindFirstChild("Events")
            if eventsFolder then
                for _, remote in ipairs(eventsFolder:GetChildren()) do
                    execute_remote(remote)
                    task.wait(0.1)
                end
            end
        end
        
        Rayfield:Notify({
            Title = "Done",
            Content = "All remotes fired!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateDivider()

MiscTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        for _, conn in pairs(connections) do
            if conn then conn:Disconnect() end
        end
        
        if toggle_button_gui then toggle_button_gui:Destroy() end
        Rayfield:Destroy()
    end,
})

-- Load notification
Rayfield:Notify({
    Title = "✅ Loaded Successfully",
    Content = "Script loaded in " .. string.format("%.2f", tick() - start_tick) .. " seconds",
    Duration = 5,
    Image = 4483362458,
})

print("=" .. string.rep("=", 60))
print("✅ TapSim Auto-Farm - Loaded Successfully!")
print("=" .. string.rep("=", 60))
