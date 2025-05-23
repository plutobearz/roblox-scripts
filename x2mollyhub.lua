print("Script started")
local plr = game.Players.LocalPlayer
if not plr then
    warn("LocalPlayer not found!")
    return
end
print("LocalPlayer found")

local gui = Instance.new("ScreenGui")
gui.Name = "DiscordCopyGui"
gui.Parent = plr:FindFirstChild("PlayerGui")
if not gui.Parent then
    warn("PlayerGui not found!")
    return
end
print("ScreenGui parented")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 110)
frame.Position = UDim2.new(0.5, -170, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
frame.AnchorPoint = Vector2.new(0.5,0.5)
print("Frame created")

local msg = Instance.new("TextLabel", frame)
msg.Size = UDim2.new(1, -20, 0, 40)
msg.Position = UDim2.new(0, 10, 0, 10)
msg.BackgroundTransparency = 1
msg.Text = "This script is outdated!\nJoin the Discord for updates."
msg.Font = Enum.Font.GothamBold
msg.TextSize = 15
msg.TextColor3 = Color3.fromRGB(200,100,100)
msg.TextWrapped = true
print("TextLabel created")

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0, 180, 0, 28)
box.Position = UDim2.new(0, 10, 0, 60)
box.BackgroundColor3 = Color3.fromRGB(20,20,30)
box.TextColor3 = Color3.fromRGB(180,180,220)
box.TextSize = 13
box.Font = Enum.Font.Code
box.ClearTextOnFocus = false
box.TextEditable = false
box.Text = "https://discord.gg/y65eQedbgu"
print("TextBox created")

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 120, 0, 28)
btn.Position = UDim2.new(0, 200, 0, 60)
btn.BackgroundColor3 = Color3.fromRGB(80,120,255)
btn.Text = "Copy Discord"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.TextColor3 = Color3.fromRGB(255,255,255)
print("Button created")

btn.MouseButton1Click:Connect(function()
    print("Button clicked")
    if setclipboard then
        setclipboard(box.Text)
        btn.Text = "Copied!"
        wait(1)
        btn.Text = "Copy Discord"
    else
        box:CaptureFocus()
        box.SelectionStart = 1
        box.CursorPosition = #box.Text + 1
        btn.Text = "Select & Ctrl+C!"
        wait(1)
        btn.Text = "Copy Discord"
    end
end)
print("Script finished")
