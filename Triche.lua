--[[
    Test Rayfield - Interface vide pour tester
    Aucune logique, juste des boutons
]]

print("🎨 Test Rayfield - Chargement...")

-- Charger Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

print("✅ Rayfield chargé!")

-- Créer la fenêtre
local Window = Rayfield:CreateWindow({
    Name = "🧪 Test Rayfield",
    Icon = 0,
    LoadingTitle = "Test Interface",
    LoadingSubtitle = "Vérification Rayfield",
    ShowText = "Test",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = { Enabled = false },
    KeySystem = false
})

print("✅ Fenêtre créée!")

-- ============================================
-- BOUTON MOBILE (optionnel)
-- ============================================

local function create_toggle_button()
    if game.CoreGui:FindFirstChild("TestToggleButton") then
        game.CoreGui.TestToggleButton:Destroy()
    end
    
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "TestToggleButton"
    screen_gui.Parent = game:GetService("CoreGui")
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = UDim2.new(1, -60, 0.5, -25)
    button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    button.Text = "🧪"
    button.TextSize = 25
    button.Parent = screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    button.Activated:Connect(function()
        Rayfield:Toggle()
    end)
end

create_toggle_button()

-- ============================================
-- CRÉER DES TABS
-- ============================================

local Tab1 = Window:CreateTab("🏠 Test 1", "home")
local Tab2 = Window:CreateTab("⚙️ Test 2", "settings")

-- ============================================
-- TAB 1 - BOUTONS ET TOGGLES
-- ============================================

Tab1:CreateLabel("Test des éléments Rayfield")

Tab1:CreateButton({
    Name = "🔘 Test Button",
    Callback = function()
        Rayfield:Notify({
            Title = "✅ Succès",
            Content = "Le bouton fonctionne!",
            Duration = 2,
            Image = "check"
        })
        print("✅ Bouton cliqué!")
    end,
})

Tab1:CreateToggle({
    Name = "🔄 Test Toggle",
    CurrentValue = false,
    Flag = "TestToggle",
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Toggle ON",
                Content = "Activé",
                Duration = 2,
                Image = "toggle-right"
            })
            print("✅ Toggle activé")
        else
            Rayfield:Notify({
                Title = "Toggle OFF",
                Content = "Désactivé",
                Duration = 2,
                Image = "toggle-left"
            })
            print("❌ Toggle désactivé")
        end
    end,
})

Tab1:CreateSlider({
    Name = "📊 Test Slider",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "TestSlider",
    Callback = function(Value)
        print("📊 Slider valeur:", Value)
    end,
})

Tab1:CreateDivider()

Tab1:CreateInput({
    Name = "📝 Test Input",
    PlaceholderText = "Tapez quelque chose...",
    RemoveTextAfterFocusLost = false,
    Flag = "TestInput",
    Callback = function(Text)
        Rayfield:Notify({
            Title = "📝 Input",
            Content = "Vous avez tapé: " .. Text,
            Duration = 3,
            Image = "edit"
        })
        print("📝 Input:", Text)
    end,
})

-- ============================================
-- TAB 2 - AUTRES ÉLÉMENTS
-- ============================================

Tab2:CreateSection("Test Section")

Tab2:CreateLabel("Ceci est un label de test")

Tab2:CreateParagraph({
    Title = "Test Paragraph",
    Content = "Ceci est un paragraphe de test pour vérifier que Rayfield fonctionne correctement."
})

Tab2:CreateDropdown({
    Name = "📋 Test Dropdown",
    Options = {"Option 1", "Option 2", "Option 3"},
    CurrentOption = {"Option 1"},
    MultipleOptions = false,
    Flag = "TestDropdown",
    Callback = function(Option)
        Rayfield:Notify({
            Title = "📋 Dropdown",
            Content = "Sélectionné: " .. tostring(Option[1]),
            Duration = 2,
            Image = "list"
        })
        print("📋 Dropdown:", Option[1])
    end,
})

Tab2:CreateDivider()

Tab2:CreateColorPicker({
    Name = "🎨 Test Color Picker",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "TestColor",
    Callback = function(Value)
        print("🎨 Couleur:", Value)
    end
})

Tab2:CreateDivider()

Tab2:CreateButton({
    Name = "🗑️ Détruire l'UI",
    Callback = function()
        Rayfield:Notify({
            Title = "🗑️ Destruction",
            Content = "UI détruite dans 2 secondes...",
            Duration = 2,
            Image = "trash"
        })
        
        task.wait(2)
        
        if game.CoreGui:FindFirstChild("TestToggleButton") then
            game.CoreGui.TestToggleButton:Destroy()
        end
        
        Rayfield:Destroy()
        print("🗑️ UI détruite")
    end,
})

-- ============================================
-- FIN
-- ============================================

print("=" .. string.rep("=", 60))
print("✅ Test Rayfield - Chargé avec succès!")
print("📱 Utilisez le bouton 🧪 pour afficher/cacher")
print("=" .. string.rep("=", 60))

Rayfield:Notify({
    Title = "✅ Chargé",
    Content = "Interface de test prête!",
    Duration = 3,
    Image = "check-circle"
})