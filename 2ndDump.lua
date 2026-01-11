-- ============================================
-- ADVANCED RECON - TAPSIM DATA COLLECTOR
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- ============================================
-- DATA COLLECTION
-- ============================================

local reconData = {
    -- Player stats/values
    playerStats = {},
    leaderstats = {},
    currencies = {},
    
    -- Remotes catégorisés
    remotesByCategory = {
        purchase = {},
        claim = {},
        rebirth = {},
        pet = {},
        upgrade = {},
        other = {}
    },
    
    -- UI structure
    mainGameUI = {},
    shopStructure = {},
    inventoryStructure = {},
    
    -- Fonctions importantes
    clickFunction = nil,
    rebirthFunction = nil,
    purchaseFunction = nil
}

-- ============================================
-- SCAN PLAYER DATA
-- ============================================

local function scanPlayerData()
    print("[RECON] Scanning player data...")
    
    -- Leaderstats
    if player:FindFirstChild("leaderstats") then
        for _, stat in ipairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                table.insert(reconData.leaderstats, {
                    name = stat.Name,
                    value = tostring(stat.Value),
                    class = stat.ClassName,
                    path = stat:GetFullName()
                })
            end
        end
    end
    
    -- Tous les values dans player
    for _, child in ipairs(player:GetDescendants()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("BoolValue") then
            local name = child.Name:lower()
            if name:find("gem") or name:find("coin") or name:find("click") or 
               name:find("rebirth") or name:find("currency") or name:find("money") then
                table.insert(reconData.currencies, {
                    name = child.Name,
                    value = tostring(child.Value),
                    class = child.ClassName,
                    path = child:GetFullName()
                })
            end
        end
    end
    
    -- Player attributes
    for name, value in pairs(player:GetAttributes()) do
        table.insert(reconData.playerStats, {
            name = name,
            value = tostring(value),
            path = "Player:GetAttribute('" .. name .. "')"
        })
    end
end

-- ============================================
-- CATEGORIZE REMOTES
-- ============================================

local function categorizeRemotes()
    print("[RECON] Categorizing remotes...")
    
    local function categorize(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            local info = {
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj.ClassName
            }
            
            if name:find("purchase") or name:find("buy") or name:find("shop") or name:find("pack") then
                table.insert(reconData.remotesByCategory.purchase, info)
            elseif name:find("claim") or name:find("reward") or name:find("collect") then
                table.insert(reconData.remotesByCategory.claim, info)
            elseif name:find("rebirth") or name:find("prestige") or name:find("rank") then
                table.insert(reconData.remotesByCategory.rebirth, info)
            elseif name:find("pet") or name:find("egg") or name:find("hatch") then
                table.insert(reconData.remotesByCategory.pet, info)
            elseif name:find("upgrade") or name:find("level") or name:find("boost") then
                table.insert(reconData.remotesByCategory.upgrade, info)
            else
                table.insert(reconData.remotesByCategory.other, info)
            end
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            categorize(child)
        end
    end
    
    categorize(ReplicatedStorage)
end

-- ============================================
-- SCAN UI STRUCTURE
-- ============================================

local function scanUIStructure()
    print("[RECON] Scanning UI structure...")
    
    -- Find main game UI
    for _, ui in ipairs(gui:GetChildren()) do
        if ui:IsA("ScreenGui") and (ui.Name:find("Game") or ui.Name:find("Main") or ui.Name:find("HUD")) then
            local structure = {
                name = ui.Name,
                enabled = ui.Enabled,
                buttons = {},
                textLabels = {}
            }
            
            for _, desc in ipairs(ui:GetDescendants()) do
                if desc:IsA("TextButton") and desc.Visible then
                    local btnName = desc.Name:lower()
                    if btnName:find("tap") or btnName:find("click") or btnName:find("rebirth") or btnName:find("auto") then
                        table.insert(structure.buttons, {
                            name = desc.Name,
                            text = desc.Text,
                            path = desc:GetFullName()
                        })
                    end
                elseif desc:IsA("TextLabel") and desc.Visible then
                    local lblName = desc.Name:lower()
                    if lblName:find("click") or lblName:find("gem") or lblName:find("coin") or lblName:find("rebirth") then
                        table.insert(structure.textLabels, {
                            name = desc.Name,
                            text = desc.Text,
                            path = desc:GetFullName()
                        })
                    end
                end
            end
            
            table.insert(reconData.mainGameUI, structure)
        end
    end
    
    -- Scan shop structure
    local shopUI = gui:FindFirstChild("Store") or gui:FindFirstChild("Shop") or gui.Tabs and gui.Tabs:FindFirstChild("Store")
    if shopUI then
        reconData.shopStructure = {
            name = shopUI.Name,
            path = shopUI:GetFullName(),
            items = {}
        }
        
        for _, desc in ipairs(shopUI:GetDescendants()) do
            if desc:IsA("TextButton") and (desc.Name:find("Buy") or desc.Name:find("Purchase")) then
                table.insert(reconData.shopStructure.items, {
                    name = desc.Name,
                    text = desc.Text,
                    path = desc:GetFullName(),
                    parent = desc.Parent.Name
                })
            end
        end
    end
    
    -- Scan inventory
    local invUI = gui:FindFirstChild("Inventory") or gui.Tabs and gui.Tabs:FindFirstChild("Inventory")
    if invUI then
        reconData.inventoryStructure = {
            name = invUI.Name,
            path = invUI:GetFullName(),
            petSlots = {}
        }
        
        for _, desc in ipairs(invUI:GetDescendants()) do
            if desc:IsA("Frame") and (desc.Name:find("Pet") or desc.Name:find("Slot")) then
                table.insert(reconData.inventoryStructure.petSlots, {
                    name = desc.Name,
                    path = desc:GetFullName()
                })
            end
        end
    end
end

-- ============================================
-- FIND CLICK/REBIRTH FUNCTIONS
-- ============================================

local function findKeyFunctions()
    print("[RECON] Searching for key functions...")
    
    -- Search for click/tap remotes
    local possibleClick = {
        ReplicatedStorage:FindFirstChild("ClickEvent"),
        ReplicatedStorage:FindFirstChild("TapEvent"),
        ReplicatedStorage:FindFirstChild("Click"),
        ReplicatedStorage:FindFirstChild("Tap")
    }
    
    for _, remote in ipairs(possibleClick) do
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            reconData.clickFunction = {
                name = remote.Name,
                path = remote:GetFullName(),
                type = remote.ClassName
            }
            break
        end
    end
    
    -- Search in GUI buttons
    for _, ui in ipairs(gui:GetDescendants()) do
        if ui:IsA("TextButton") then
            local name = ui.Name:lower()
            local text = ui.Text:lower()
            
            if (name:find("tap") or text:find("tap") or name:find("click")) and not reconData.clickFunction then
                reconData.clickFunction = {
                    name = ui.Name,
                    path = ui:GetFullName(),
                    type = "TextButton"
                }
            end
            
            if (name:find("rebirth") or text:find("rebirth") or name:find("prestige")) and not reconData.rebirthFunction then
                reconData.rebirthFunction = {
                    name = ui.Name,
                    path = ui:GetFullName(),
                    type = "TextButton"
                }
            end
        end
    end
end

-- ============================================
-- FORMAT OUTPUT
-- ============================================

local function formatOutput()
    local lines = {}
    
    table.insert(lines, "=" .. string.rep("=", 60))
    table.insert(lines, "ADVANCED RECON - TAPSIM DATA COLLECTOR")
    table.insert(lines, "Date: " .. os.date("%d/%m/%Y %H:%M:%S"))
    table.insert(lines, "=" .. string.rep("=", 60))
    table.insert(lines, "")
    
    -- Player currencies
    table.insert(lines, "[ CURRENCIES & STATS ]")
    table.insert(lines, "")
    if #reconData.leaderstats > 0 then
        table.insert(lines, "Leaderstats:")
        for _, stat in ipairs(reconData.leaderstats) do
            table.insert(lines, string.format("  %s = %s (%s)", stat.name, stat.value, stat.class))
            table.insert(lines, "    Path: " .. stat.path)
        end
        table.insert(lines, "")
    end
    
    if #reconData.currencies > 0 then
        table.insert(lines, "Currencies found:")
        for _, curr in ipairs(reconData.currencies) do
            table.insert(lines, string.format("  %s = %s (%s)", curr.name, curr.value, curr.class))
            table.insert(lines, "    Path: " .. curr.path)
        end
        table.insert(lines, "")
    end
    
    if #reconData.playerStats > 0 then
        table.insert(lines, "Player Attributes:")
        for _, attr in ipairs(reconData.playerStats) do
            table.insert(lines, string.format("  %s = %s", attr.name, attr.value))
        end
        table.insert(lines, "")
    end
    
    -- Remotes catégorisés
    table.insert(lines, "")
    table.insert(lines, "[ REMOTES BY CATEGORY ]")
    table.insert(lines, "")
    
    for category, remotes in pairs(reconData.remotesByCategory) do
        if #remotes > 0 then
            table.insert(lines, string.format("%s (%d):", category:upper(), #remotes))
            for i, remote in ipairs(remotes) do
                if i <= 10 then -- Limit pour éviter overflow
                    table.insert(lines, string.format("  [%d] %s (%s)", i, remote.name, remote.type))
                    table.insert(lines, "      " .. remote.path)
                end
            end
            if #remotes > 10 then
                table.insert(lines, string.format("  ... +%d autres", #remotes - 10))
            end
            table.insert(lines, "")
        end
    end
    
    -- Key functions
    table.insert(lines, "")
    table.insert(lines, "[ KEY FUNCTIONS ]")
    table.insert(lines, "")
    
    if reconData.clickFunction then
        table.insert(lines, "CLICK/TAP Function:")
        table.insert(lines, "  Name: " .. reconData.clickFunction.name)
        table.insert(lines, "  Type: " .. reconData.clickFunction.type)
        table.insert(lines, "  Path: " .. reconData.clickFunction.path)
        table.insert(lines, "")
    else
        table.insert(lines, "CLICK/TAP Function: NOT FOUND")
        table.insert(lines, "")
    end
    
    if reconData.rebirthFunction then
        table.insert(lines, "REBIRTH Function:")
        table.insert(lines, "  Name: " .. reconData.rebirthFunction.name)
        table.insert(lines, "  Type: " .. reconData.rebirthFunction.type)
        table.insert(lines, "  Path: " .. reconData.rebirthFunction.path)
        table.insert(lines, "")
    else
        table.insert(lines, "REBIRTH Function: NOT FOUND")
        table.insert(lines, "")
    end
    
    -- UI Structure
    table.insert(lines, "")
    table.insert(lines, "[ UI STRUCTURE ]")
    table.insert(lines, "")
    
    if #reconData.mainGameUI > 0 then
        table.insert(lines, "Main Game UI:")
        for _, ui in ipairs(reconData.mainGameUI) do
            table.insert(lines, string.format("  %s (Enabled: %s)", ui.name, tostring(ui.enabled)))
            if #ui.buttons > 0 then
                table.insert(lines, "  Important Buttons:")
                for _, btn in ipairs(ui.buttons) do
                    table.insert(lines, string.format("    - %s: '%s'", btn.name, btn.text))
                    table.insert(lines, "      " .. btn.path)
                end
            end
        end
        table.insert(lines, "")
    end
    
    if reconData.shopStructure.name then
        table.insert(lines, "Shop Structure:")
        table.insert(lines, "  Name: " .. reconData.shopStructure.name)
        table.insert(lines, "  Path: " .. reconData.shopStructure.path)
        table.insert(lines, string.format("  Items found: %d", #reconData.shopStructure.items))
        if #reconData.shopStructure.items > 0 then
            table.insert(lines, "  Sample items:")
            for i = 1, math.min(5, #reconData.shopStructure.items) do
                local item = reconData.shopStructure.items[i]
                table.insert(lines, string.format("    [%d] %s - %s", i, item.name, item.text))
            end
        end
        table.insert(lines, "")
    end
    
    if reconData.inventoryStructure.name then
        table.insert(lines, "Inventory Structure:")
        table.insert(lines, "  Name: " .. reconData.inventoryStructure.name)
        table.insert(lines, "  Path: " .. reconData.inventoryStructure.path)
        table.insert(lines, string.format("  Pet slots: %d", #reconData.inventoryStructure.petSlots))
        table.insert(lines, "")
    end
    
    table.insert(lines, "")
    table.insert(lines, "=" .. string.rep("=", 60))
    table.insert(lines, "END OF RECON")
    table.insert(lines, "=" .. string.rep("=", 60))
    
    return table.concat(lines, "\n")
end

-- ============================================
-- MAIN EXECUTION
-- ============================================

print("=" .. string.rep("=", 60))
print("ADVANCED RECON SCRIPT STARTED")
print("=" .. string.rep("=", 60))

task.wait(2) -- Wait for game to load

scanPlayerData()
task.wait(0.5)

categorizeRemotes()
task.wait(0.5)

scanUIStructure()
task.wait(0.5)

findKeyFunctions()
task.wait(0.5)

local output = formatOutput()

-- Export to file
local success, err = pcall(function()
    if writefile then
        local timestamp = os.date("%d%m%Y_%H%M")
        local filename = "recon_" .. timestamp .. ".txt"
        writefile(filename, output)
        print("[SUCCESS] Recon data saved to: " .. filename)
    else
        print("[WARNING] writefile not available, printing to console...")
        print(output)
    end
end)

if not success then
    print("[ERROR] " .. tostring(err))
    print("[FALLBACK] Printing to console...")
    print(output)
end

print("")
print("=" .. string.rep("=", 60))
print("RECON COMPLETE - Check your executor folder or console (F9)")
print("=" .. string.rep("=", 60))