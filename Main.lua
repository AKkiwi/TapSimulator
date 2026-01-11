-- RNG GAME - CLIENT FULL DUMP (TRICHEUR VIEW)
-- Génère un rapport texte + UI + sauvegarde locale

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--------------------------------------------------
-- UTIL
--------------------------------------------------
local dump = {}

local function log(text)
	table.insert(dump, text)
end

local function header(text)
	log("")
	log("==== " .. text .. " ====")
end

--------------------------------------------------
-- DUMP START
--------------------------------------------------
log("RNG GAME - CLIENT SECURITY DUMP")
log("Player: " .. player.Name)
log("")

--------------------------------------------------
-- 1?? REMOTES
--------------------------------------------------
header("REMOTES ACCESSIBLES")
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
	if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
		log(obj.ClassName .. " | " .. obj:GetFullName())
	end
end

--------------------------------------------------
-- 2?? UI INTERACTIVE
--------------------------------------------------
header("UI INTERACTIVE ELEMENTS")
for _, obj in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
	if obj:IsA("TextButton")
	or obj:IsA("ImageButton")
	or obj:IsA("TextBox") then
		log(obj.ClassName .. " | " .. obj:GetFullName())
	end
end

--------------------------------------------------
-- 3?? WORKSPACE INTERACTIONS
--------------------------------------------------
header("WORKSPACE INTERACTIONS")
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("ClickDetector")
	or obj:IsA("ProximityPrompt")
	or obj:IsA("TouchTransmitter") then
		log(obj.ClassName .. " | " .. obj:GetFullName())
	end
end

--------------------------------------------------
-- 4?? LOCAL VALUES
--------------------------------------------------
header("LOCAL VALUES (MANIPULABLES)")
for _, obj in ipairs(player:GetDescendants()) do
	if obj:IsA("BoolValue")
	or obj:IsA("IntValue")
	or obj:IsA("NumberValue")
	or obj:IsA("StringValue") then
		log(obj.ClassName .. " | " .. obj:GetFullName() .. " = " .. tostring(obj.Value))
	end
end

--------------------------------------------------
-- 5?? MODULES VISIBLES
--------------------------------------------------
header("MODULES ACCESSIBLES")
for _, obj in ipairs(game:GetDescendants()) do
	if obj:IsA("ModuleScript")
	and (obj:IsDescendantOf(ReplicatedStorage)
	or obj:IsDescendantOf(workspace)
	or obj:IsDescendantOf(player.PlayerGui)) then
		log("ModuleScript | " .. obj:GetFullName())
	end
end

--------------------------------------------------
-- FINAL TEXT
--------------------------------------------------
local finalText = table.concat(dump, "\n")

--------------------------------------------------
-- 6?? SAVE LOCAL (StringValue)
--------------------------------------------------
local dumpValue = Instance.new("StringValue")
dumpValue.Name = "ClientSecurityDump"
dumpValue.Value = finalText
dumpValue.Parent = player

--------------------------------------------------
-- 7?? UI AFFICHAGE (COPIABLE)
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "DumpViewer"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9, 0.8)
frame.Position = UDim2.fromScale(0.05, 0.1)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(1, 1)
box.TextWrapped = false
box.ClearTextOnFocus = false
box.TextXAlignment = Left
box.TextYAlignment = Top
box.TextSize = 14
box.Font = Enum.Font.Code
box.MultiLine = true
box.TextEditable = false
box.Text = finalText
box.BackgroundTransparency = 1
box.TextColor3 = Color3.fromRGB(200, 200, 200)

--------------------------------------------------
-- DONE
--------------------------------------------------
print("CLIENT DUMP GENERATED (UI + StringValue)")
