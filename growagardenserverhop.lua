-- Gentle, event-aware serverhop script for Grow a Garden
if getgenv()._GAG_GENTLE_SERVERHOP then return end
getgenv()._GAG_GENTLE_SERVERHOP = true

local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local JobId = game.JobId

-- List of known event attribute names and pretty names
local eventAttributes = {
    BloodMoonEvent = "Bloodmoon",
    RainEvent = "Rain",
    NightEvent = "Night",
    StormEvent = "Storm",
    MeteorEvent = "Meteor Shower",
    SolarEclipseEvent = "Solar Eclipse",
    -- Add more as needed
}

-- Returns event name if any event is active, or nil
local function getActiveEvent()
    for attr, pretty in pairs(eventAttributes) do
        local val = workspace:GetAttribute(attr)
        if val == true then
            return pretty
        end
    end
    return nil
end

-- Simple GUI popup, returns true if confirmed, false if canceled
local function showConfirmationPopup(eventName)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ServerhopPopup"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 340, 0, 170)
    frame.Position = UDim2.new(0.5, -170, 0.5, -85)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    local UICorner = Instance.new("UICorner", frame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0.55, -10)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = "A special event is happening: "..eventName.."\nAre you sure you want to serverhop?"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextWrapped = true

    local yesBtn = Instance.new("TextButton", frame)
    yesBtn.Size = UDim2.new(0.42, 0, 0.22, 0)
    yesBtn.Position = UDim2.new(0.07, 0, 0.7, 0)
    yesBtn.Text = "Yes"
    yesBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    yesBtn.TextColor3 = Color3.new(1,1,1)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextSize = 17
    local yesBtnCorner = Instance.new("UICorner", yesBtn)
    yesBtnCorner.CornerRadius = UDim.new(0, 8)

    local noBtn = Instance.new("TextButton", frame)
    noBtn.Size = UDim2.new(0.42, 0, 0.22, 0)
    noBtn.Position = UDim2.new(0.51, 0, 0.7, 0)
    noBtn.Text = "No"
    noBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    noBtn.TextColor3 = Color3.new(1,1,1)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextSize = 17
    local noBtnCorner = Instance.new("UICorner", noBtn)
    noBtnCorner.CornerRadius = UDim.new(0, 8)

    local result = nil
    yesBtn.MouseButton1Click:Connect(function()
        result = true
        gui:Destroy()
    end)
    noBtn.MouseButton1Click:Connect(function()
        result = false
        gui:Destroy()
    end)
    repeat task.wait() until result ~= nil or not frame.Parent
    return result == true
end

-- Shows a GUI for HTTP error and waits 30 seconds
local function showHTTPErrorPopup()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ServerhopHTTPErr"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 320, 0, 100)
    frame.Position = UDim2.new(0.5, -160, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    local UICorner = Instance.new("UICorner", frame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = "HTTP Error: Retrying in 30 seconds..."
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextWrapped = true

    task.wait(30)
    gui:Destroy()
end

-- Gentle serverhop logic
local function serverhop()
    -- Check for active event
    local eventName = getActiveEvent()
    if eventName then
        local confirmed = showConfirmationPopup(eventName)
        if not confirmed then
            warn("Serverhop cancelled by user due to active event: "..eventName)
            return
        end
    end

    -- Try to get a server list
    local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then
        showHTTPErrorPopup()
        return serverhop()
    end
    local data = HttpService:JSONDecode(response)
    local servers = {}
    for _, server in ipairs(data.data) do
        if server.id ~= JobId and server.playing < server.maxPlayers then
            table.insert(servers, server.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
    else
        warn("No servers found to hop to! Waiting 30 seconds before retrying...")
        task.wait(30)
        serverhop()
    end
end

-- Wait for loading screen to finish
local function waitForGameLoad()
    local args = {
        [1] = Players.LocalPlayer
    }
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("LoadScreenEvent"):FireServer(unpack(args))
    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Finish_Loading"):FireServer()
    task.wait(10) -- Wait 10 seconds for everything to load
end

waitForGameLoad()
serverhop()
