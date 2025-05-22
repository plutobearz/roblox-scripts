if not getgenv()._GAG_TAB_SHOP then
    getgenv()._GAG_TAB_SHOP = true

    local CoreGui = game:GetService("CoreGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Egg spots mapping
    local eggItems = {"Egg Spot 1", "Egg Spot 2", "Egg Spot 3"}
    local eggNameToId = {
        ["Egg Spot 1"] = 1,
        ["Egg Spot 2"] = 2,
        ["Egg Spot 3"] = 3,
    }

    -- Helper to get all item names from a folder (supports nested)
    local function getNames(folder)
        local names = {}
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                table.insert(names, v.Name)
            end
            table.sort(names)
        end
        return names
    end

    -- Get the actual folders
    local seedFolder = ReplicatedStorage:FindFirstChild("Seed_Models")
    local eggFolder = ReplicatedStorage:FindFirstChild("Assets")
    eggFolder = eggFolder and eggFolder:FindFirstChild("Models")
    eggFolder = eggFolder and eggFolder:FindFirstChild("EggModels")
    local toolFolder = ReplicatedStorage:FindFirstChild("ObjectModels")

    -- Build tool list, add custom tools, and fix Watering Can
    local toolItems = getNames(toolFolder)
    for i = #toolItems, 1, -1 do
        if toolItems[i] == "WateringCan" then
            table.remove(toolItems, i)
        end
    end
    local customTools = {"Watering Can", "Recall Wrench", "Trowel"}
    for _, tool in ipairs(customTools) do
        local found = false
        for _, t in ipairs(toolItems) do
            if t:lower() == tool:lower() then
                found = true
                break
            end
        end
        if not found then
            table.insert(toolItems, tool)
        end
    end
    table.sort(toolItems)

    -- Data for all tabs (now with correct remotes)
    local tabs = {
        {Name="Seeds",   Folder=seedFolder, Remote="BuySeedStock", Items=getNames(seedFolder), IsEgg=false},
        {Name="Eggs",    Folder=eggFolder,  Remote="BuyPetEgg",    Items=eggItems,            IsEgg=true, EggNameToId=eggNameToId},
        {Name="Tools",   Folder=toolFolder, Remote="BuyGearStock", Items=toolItems,           IsEgg=false},
    }

    -- GUI setup
    local gui = Instance.new("ScreenGui")
    gui.Name = "TabbedShopGUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 480, 0, 500)
    frame.Position = UDim2.new(0.5, -240, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    local UICorner = Instance.new("UICorner", frame)
    UICorner.CornerRadius = UDim.new(0, 14)

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0.11,0)
    title.Position = UDim2.new(0,0,0,0)
    title.Text = "Shop"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32

    -- Close Button
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -44, 0, 8)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeBtn.TextColor3 = Color3.new(1,0.4,0.4)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 22
    closeBtn.AutoButtonColor = true
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 10)

    -- Tab buttons
    local tabButtons = {}
    local currentTab = 1

    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.3, 0, 0.08, 0)
        btn.Position = UDim2.new(0.035 + (i-1)*0.32, 0, 0.12, 0)
        btn.Text = tab.Name
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(70,130,200) or Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.AutoButtonColor = true
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 8)
        tabButtons[i] = btn
    end

    -- Status label
    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Size = UDim2.new(1,0,0.06,0)
    statusLabel.Position = UDim2.new(0,0,0.95,0)
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.new(1,1,1)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 18

    -- Buy All button
    local buyAllBtn = Instance.new("TextButton", frame)
    buyAllBtn.Size = UDim2.new(0.38,0,0.08,0)
    buyAllBtn.Position = UDim2.new(0.56,0,0.78,0)
    buyAllBtn.Text = "Buy All (40x Each)"
    buyAllBtn.BackgroundColor3 = Color3.fromRGB(200,150,50)
    buyAllBtn.TextColor3 = Color3.new(1,1,1)
    buyAllBtn.Font = Enum.Font.GothamBold
    buyAllBtn.TextSize = 20
    local buyAllCorner = Instance.new("UICorner", buyAllBtn)
    buyAllCorner.CornerRadius = UDim.new(0, 8)

    -- Buy button
    local buyBtn = Instance.new("TextButton", frame)
    buyBtn.Size = UDim2.new(0.38,0,0.08,0)
    buyBtn.Position = UDim2.new(0.06,0,0.78,0)
    buyBtn.Text = "Buy"
    buyBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
    buyBtn.TextColor3 = Color3.new(1,1,1)
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 20
    local buyCorner = Instance.new("UICorner", buyBtn)
    buyCorner.CornerRadius = UDim.new(0, 8)

    -- Discord button (under Buy and Buy All, left side)
    local discordBtn = Instance.new("TextButton", frame)
    discordBtn.Size = UDim2.new(0.38, 0, 0.08, 0)
    discordBtn.Position = UDim2.new(0.06, 0, 0.87, 0)
    discordBtn.Text = "Discord"
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.TextColor3 = Color3.new(1,1,1)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 20
    discordBtn.AutoButtonColor = true
    local discordCorner = Instance.new("UICorner", discordBtn)
    discordCorner.CornerRadius = UDim.new(0, 10)

    discordBtn.MouseButton1Click:Connect(function()
        local url = "https://discord.gg/y65eQedbgu"
        setclipboard(url)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Discord Link",
                Text = "Link copied to clipboard!",
                Duration = 5
            })
        end)
    end)

    -- Autofarm button (right of Discord button)
    local autofarmBtn = Instance.new("TextButton", frame)
    autofarmBtn.Size = UDim2.new(0.38, 0, 0.08, 0)
    autofarmBtn.Position = UDim2.new(0.56, 0, 0.87, 0)
    autofarmBtn.Text = "Start Autofarm"
    autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
    autofarmBtn.TextColor3 = Color3.new(1,1,1)
    autofarmBtn.Font = Enum.Font.GothamBold
    autofarmBtn.TextSize = 20
    autofarmBtn.AutoButtonColor = true
    local autofarmCorner = Instance.new("UICorner", autofarmBtn)
    autofarmCorner.CornerRadius = UDim.new(0, 10)

    -- Autofarm logic
    local autofarmActive = false
    local autofarmThread = nil

    local function doBuyAll(tab)
        for _, item in ipairs(tab.Items) do
            spawn(function()
                for i = 1, 40 do
                    local args
                    if tab.IsEgg then
                        local eggId = tab.EggNameToId[item]
                        if eggId then
                            args = {eggId}
                        end
                    else
                        args = {item}
                    end
                    if args then
                        pcall(function()
                            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(tab.Remote):FireServer(unpack(args))
                        end)
                    end
                end
            end)
        end
    end

    autofarmBtn.MouseButton1Click:Connect(function()
        autofarmActive = not autofarmActive
        if autofarmActive then
            autofarmBtn.Text = "Stop Autofarm"
            autofarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
            autofarmThread = task.spawn(function()
                while autofarmActive do
                    statusLabel.Text = "Autofarm: Buying all 40x..."
                    doBuyAll(tabs[currentTab])
                    for i = 180,1,-1 do
                        if not autofarmActive then break end
                        statusLabel.Text = "Autofarm: Next buy in "..i.."s"
                        task.wait(1)
                    end
                end
                statusLabel.Text = ""
            end)
        else
            autofarmBtn.Text = "Start Autofarm"
            autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
            statusLabel.Text = "Autofarm stopped."
        end
    end)

    -- Scrolling frames for each tab (smaller height)
    local scrollFrames = {}
    local itemButtons = {}
    local selectedItem = {}

    for i, tab in ipairs(tabs) do
        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(0.9, 0, 0.52, 0)
        scroll.Position = UDim2.new(0.05, 0, 0.21, 0)
        scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 12
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ClipsDescendants = true
        scroll.Visible = (i == 1)
        local scrollCorner = Instance.new("UICorner", scroll)
        scrollCorner.CornerRadius = UDim.new(0, 8)
        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        scrollFrames[i] = scroll
        itemButtons[i] = {}

        -- Populate with item buttons
        for _, itemName in ipairs(tab.Items) do
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -8, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 18
            btn.Text = itemName
            btn.AutoButtonColor = true
            btn.MouseButton1Click:Connect(function()
                selectedItem[i] = itemName
                for _, b in ipairs(itemButtons[i]) do
                    if b.Text == itemName then
                        b.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
                        b.TextColor3 = Color3.new(1, 1, 1)
                    else
                        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        b.TextColor3 = Color3.new(1, 1, 1)
                    end
                end
                statusLabel.Text = "Selected: " .. itemName
            end)
            table.insert(itemButtons[i], btn)
        end
    end

    -- Tab switching logic
    local function showTab(idx)
        for i, scroll in ipairs(scrollFrames) do
            scroll.Visible = (i == idx)
            tabButtons[i].BackgroundColor3 = i == idx and Color3.fromRGB(70,130,200) or Color3.fromRGB(50,50,50)
        end
        statusLabel.Text = ""
    end
    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            currentTab = i
            showTab(i)
        end)
    end

    -- Buy logic
    buyBtn.MouseButton1Click:Connect(function()
        local tab = tabs[currentTab]
        local item = selectedItem[currentTab]
        if not item then
            statusLabel.Text = "Please select an item!"
            return
        end
        statusLabel.Text = "Buying " .. item .. "..."
        local args
        if tab.IsEgg then
            local eggId = tab.EggNameToId[item]
            if not eggId then
                statusLabel.Text = "Egg ID not found!"
                return
            end
            args = {eggId}
        else
            args = {item}
        end
        local success, err = pcall(function()
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(tab.Remote):FireServer(unpack(args))
        end)
        if success then
            statusLabel.Text = "Bought: " .. item .. "!"
        else
            statusLabel.Text = "Error: " .. tostring(err)
        end
        wait(2)
        statusLabel.Text = ""
    end)

    -- Buy All logic (spams each item 40x, in parallel)
    buyAllBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "Buying all " .. tabs[currentTab].Name:lower() .. "s 40x each..."
        doBuyAll(tabs[currentTab])
        statusLabel.Text = "Tried to buy all " .. tabs[currentTab].Name:lower() .. "s 40x!"
        wait(2)
        statusLabel.Text = ""
    end)

    -- Draggable
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
