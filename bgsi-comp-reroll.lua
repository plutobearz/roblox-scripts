-- CONFIGURATION
local KEYWORDS = {"mythic", "golden", "shiny"}
local CHECK_INTERVAL = 1 -- seconds

local player = game.Players.LocalPlayer
local guiRoot = player.PlayerGui.ScreenGui.Competitive.Frame.Content.Tasks
local remote = game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.RemoteEvent

-- Draggable GUI function
local function makeDraggable(frame)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Create GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RerollBotUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0.5, -110, 0.7, 0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
makeDraggable(frame)
local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.23,0)
title.Position = UDim2.new(0,0,0,0)
title.Text = "Reroll Bot"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9,0,0.22,0)
toggleBtn.Position = UDim2.new(0.05,0,0.27,0)
toggleBtn.Text = "START"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
local UICornerBtn = Instance.new("UICorner", toggleBtn)
UICornerBtn.CornerRadius = UDim.new(0, 8)

-- Slot toggles
local slot1Toggle = Instance.new("TextButton", frame)
slot1Toggle.Size = UDim2.new(0.42, 0, 0.22, 0)
slot1Toggle.Position = UDim2.new(0.05, 0, 0.55, 0)
slot1Toggle.Text = "Slot 1: ON"
slot1Toggle.BackgroundColor3 = Color3.fromRGB(50,200,50)
slot1Toggle.TextColor3 = Color3.new(1,1,1)
slot1Toggle.Font = Enum.Font.GothamBold
slot1Toggle.TextSize = 16
Instance.new("UICorner", slot1Toggle).CornerRadius = UDim.new(0, 8)

local slot2Toggle = Instance.new("TextButton", frame)
slot2Toggle.Size = UDim2.new(0.42, 0, 0.22, 0)
slot2Toggle.Position = UDim2.new(0.53, 0, 0.55, 0)
slot2Toggle.Text = "Slot 2: ON"
slot2Toggle.BackgroundColor3 = Color3.fromRGB(50,200,50)
slot2Toggle.TextColor3 = Color3.new(1,1,1)
slot2Toggle.Font = Enum.Font.GothamBold
slot2Toggle.TextSize = 16
Instance.new("UICorner", slot2Toggle).CornerRadius = UDim.new(0, 8)

-- Main logic
local running = false
local rerollThread
local slot1Enabled = true
local slot2Enabled = true

local function isRepeatable(template)
    local content = template:FindFirstChild("Content")
    if not content then return false end
    local typeLabel = content:FindFirstChild("Type")
    return typeLabel and typeLabel:IsA("TextLabel") and typeLabel.Text:lower() == "repeatable"
end

local function isDesiredQuest(template)
    local content = template:FindFirstChild("Content")
    if not content then return false end
    local label = content:FindFirstChild("Label")
    if not label or not label:IsA("TextLabel") then return false end
    local text = label.Text:lower()
    for _, keyword in ipairs(KEYWORDS) do
        if text:find(keyword) then
            return true
        end
    end
    return false
end

local function reroll(slot)
    remote:FireServer("CompetitiveReroll", slot)
end

local function checkAndReroll()
    local repeatableCount = 0
    for _, template in ipairs(guiRoot:GetChildren()) do
        if template.Name == "Template" and isRepeatable(template) then
            repeatableCount = repeatableCount + 1
            local slotNumber = repeatableCount + 2 -- 1st repeatable is slot 3, 2nd is slot 4
            if (slotNumber == 3 and slot1Enabled) or (slotNumber == 4 and slot2Enabled) then
                if not isDesiredQuest(template) then
                    reroll(slotNumber)
                end
            end
        end
    end
end

local function updateButton()
    if running then
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    else
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
    end
end

local function updateSlotToggles()
    if slot1Enabled then
        slot1Toggle.Text = "Slot 1: ON"
        slot1Toggle.BackgroundColor3 = Color3.fromRGB(50,200,50)
    else
        slot1Toggle.Text = "Slot 1: OFF"
        slot1Toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
    end
    if slot2Enabled then
        slot2Toggle.Text = "Slot 2: ON"
        slot2Toggle.BackgroundColor3 = Color3.fromRGB(50,200,50)
    else
        slot2Toggle.Text = "Slot 2: OFF"
        slot2Toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
    end
end

slot1Toggle.MouseButton1Click:Connect(function()
    slot1Enabled = not slot1Enabled
    updateSlotToggles()
end)
slot2Toggle.MouseButton1Click:Connect(function()
    slot2Enabled = not slot2Enabled
    updateSlotToggles()
end)

toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    updateButton()
    if running then
        rerollThread = task.spawn(function()
            while running do
                pcall(checkAndReroll)
                task.wait(CHECK_INTERVAL)
            end
        end)
    end
end)

updateButton()
updateSlotToggles()
print("[Reroll Bot] Script loaded. Use the button to start/stop. Use Slot toggles to enable/disable rerolling for each slot.")
