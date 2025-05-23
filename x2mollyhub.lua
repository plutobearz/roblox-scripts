-- Place this in StarterGui as a LocalScript

local discordInvite = "https://discord.gg/y65eQedbgu"

local gui = Instance.new("ScreenGui")
gui.Name = "DiscordCopyGui"
gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 440, 0, 200)
main.Position = UDim2.new(0.5, -220, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Parent = gui

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -40, 0, 60)
message.Position = UDim2.new(0, 20, 0, 18)
message.BackgroundTransparency = 1
message.TextWrapped = true
message.TextYAlignment = Enum.TextYAlignment.Top
message.Text = "This script is outdated and probably broken.\nJoin the Discord if you want something that actually works."
message.Font = Enum.Font.GothamBold
message.TextSize = 18
message.TextColor3 = Color3.fromRGB(200, 100, 100)
message.Parent = main

local discordBox = Instance.new("TextBox")
discordBox.Size = UDim2.new(1, -40, 0, 36)
discordBox.Position = UDim2.new(0, 20, 0, 88)
discordBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
discordBox.TextColor3 = Color3.fromRGB(180, 180, 220)
discordBox.TextSize = 17
discordBox.Font = Enum.Font.Code
discordBox.ClearTextOnFocus = false
discordBox.TextEditable = false
discordBox.Text = discordInvite
discordBox.TextWrapped = true
discordBox.Parent = main

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 220, 0, 38)
copyBtn.Position = UDim2.new(0.5, -110, 1, -50)
copyBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
copyBtn.Text = "Copy Discord (If You Care)"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 17
copyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
copyBtn.BorderSizePixel = 0
copyBtn.Parent = main

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordInvite)
        copyBtn.Text = "Copied! Go join or don't."
        wait(1.5)
        copyBtn.Text = "Copy Discord (If You Care)"
    else
        discordBox:CaptureFocus()
        discordBox.SelectionStart = 1
        discordBox.CursorPosition = #discordBox.Text + 1
        copyBtn.Text = "Select & Ctrl+C, genius."
        wait(2)
        copyBtn.Text = "Copy Discord (If You Care)"
    end
end)
