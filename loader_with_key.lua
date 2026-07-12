--[[
    MM2 Premium Loader with Key System
    Version: 2.0.0
    
    Get your key at: https://work.ink/2JiA/d653afbe-06a3-4fc9-ba5f-674b59ebcbbd
    
    Features:
    ✅ Secure key validation with work.ink v2 API
    ✅ Modern UI with animations
    ✅ Auto-save validated keys
    ✅ Discord integration
]]

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local Config = {
    LinkId = "2JiA", -- work.ink link ID
    FullLink = "https://work.ink/2JiA/d653afbe-06a3-4fc9-ba5f-674b59ebcbbd", -- Full work.ink link
    ValidateEndpoint = "https://work.ink/_api/v2/token/isValid/",
    
    ScriptName = "MM2 Premium",
    ScriptVersion = "v2.0.0",
    DiscordInvite = "https://discord.gg/t9xNXQzSvs", -- Discord server
    
    SaveKey = true,
    DeleteToken = false,
    MaxAttempts = 5,
    CooldownTime = 30,
}

-- Variables
local LocalPlayer = Players.LocalPlayer
local KeyValidated = false
local FailedAttempts = 0
local LastAttemptTime = 0

-- Storage Functions
local function SaveKey(key)
    if not Config.SaveKey then return end
    pcall(function()
        writefile("mm2_premium_key.txt", key)
    end)
end

local function LoadKey()
    if not Config.SaveKey then return nil end
    local success, key = pcall(function()
        return readfile("mm2_premium_key.txt")
    end)
    return success and key or nil
end

-- Validation Function
local function ValidateKey(key)
    -- Cooldown check
    if tick() - LastAttemptTime < Config.CooldownTime and FailedAttempts >= Config.MaxAttempts then
        local remainingTime = math.ceil(Config.CooldownTime - (tick() - LastAttemptTime))
        return false, "Too many failed attempts. Wait " .. remainingTime .. "s"
    end
    
    -- Basic validation
    if not key or key == "" or #key < 10 then
        return false, "Please enter a valid key"
    end
    
    -- Clean the key
    key = key:gsub("%s+", "")
    
    -- Build API URL
    local apiUrl = Config.ValidateEndpoint .. key
    if Config.DeleteToken then
        apiUrl = apiUrl .. "?deleteToken=1"
    end
    
    -- Make API request
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)
    
    if not success then
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Connection error. Check your internet."
    end
    
    -- Parse JSON response
    local decoded
    success, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Invalid response from server"
    end
    
    -- Check if key is valid
    if decoded.valid == true then
        KeyValidated = true
        SaveKey(key)
        FailedAttempts = 0
        return true, "Key validated successfully!"
    else
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Invalid key. Please get a new one."
    end
end

-- UI Creation
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2PremiumKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Top Bar (Red gradient for MM2)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red for MM2
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 12)
    TopBarFix.Position = UDim2.new(0, 0, 1, -12)
    TopBarFix.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "🔪 " .. Config.ScriptName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Size = UDim2.new(1, -20, 0, 20)
    Version.Position = UDim2.new(0, 10, 0, 35)
    Version.BackgroundTransparency = 1
    Version.Text = Config.ScriptVersion .. " • Key System"
    Version.TextColor3 = Color3.fromRGB(255, 230, 230)
    Version.TextSize = 13
    Version.Font = Enum.Font.Gotham
    Version.TextXAlignment = Enum.TextXAlignment.Left
    Version.Parent = TopBar

    -- Description
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Size = UDim2.new(1, -40, 0, 40)
    Description.Position = UDim2.new(0, 20, 0, 75)
    Description.BackgroundTransparency = 1
    Description.Text = "Please enter your key to access MM2 Premium"
    Description.TextColor3 = Color3.fromRGB(180, 180, 180)
    Description.TextSize = 14
    Description.Font = Enum.Font.Gotham
    Description.TextWrapped = true
    Description.Parent = MainFrame
    
    -- Key Input Container
    local InputContainer = Instance.new("Frame")
    InputContainer.Name = "InputContainer"
    InputContainer.Size = UDim2.new(1, -40, 0, 45)
    InputContainer.Position = UDim2.new(0, 20, 0, 125)
    InputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = MainFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputContainer
    
    -- Key Input
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(1, -20, 1, -10)
    KeyInput.Position = UDim2.new(0, 10, 0, 5)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = InputContainer
    
    -- Get Key Button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(1, -40, 0, 45)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 185)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Text = "🔑 Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 15
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.Parent = MainFrame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyButton
    
    -- Validate Button
    local ValidateButton = Instance.new("TextButton")
    ValidateButton.Name = "ValidateButton"
    ValidateButton.Size = UDim2.new(1, -40, 0, 45)
    ValidateButton.Position = UDim2.new(0, 20, 0, 245)
    ValidateButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    ValidateButton.BorderSizePixel = 0
    ValidateButton.Text = "✓ Validate Key"
    ValidateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValidateButton.TextSize = 15
    ValidateButton.Font = Enum.Font.GothamBold
    ValidateButton.AutoButtonColor = false
    ValidateButton.Parent = MainFrame
    
    local ValidateCorner = Instance.new("UICorner")
    ValidateCorner.CornerRadius = UDim.new(0, 8)
    ValidateCorner.Parent = ValidateButton

    -- Discord Button
    local DiscordButton = Instance.new("TextButton")
    DiscordButton.Name = "DiscordButton"
    DiscordButton.Size = UDim2.new(1, -40, 0, 35)
    DiscordButton.Position = UDim2.new(0, 20, 1, -45)
    DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordButton.BorderSizePixel = 0
    DiscordButton.Text = "💬 Join Discord"
    DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordButton.TextSize = 14
    DiscordButton.Font = Enum.Font.GothamBold
    DiscordButton.AutoButtonColor = false
    DiscordButton.Parent = MainFrame
    
    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 8)
    DiscordCorner.Parent = DiscordButton
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 300)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame
    
    -- Dragging Logic
    local dragging = false
    local dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Button Animations
    local function ButtonHover(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    ButtonHover(GetKeyButton, Color3.fromRGB(220, 70, 70), Color3.fromRGB(200, 50, 50))
    ButtonHover(ValidateButton, Color3.fromRGB(60, 210, 110), Color3.fromRGB(50, 200, 100))
    ButtonHover(DiscordButton, Color3.fromRGB(98, 111, 252), Color3.fromRGB(88, 101, 242))

    -- Discord Button Logic
    DiscordButton.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(Config.DiscordInvite)
                StatusLabel.Text = "Discord invite copied to clipboard!"
                StatusLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
            end
        end)
        
        task.wait(3)
        if StatusLabel.Text == "Discord invite copied to clipboard!" then
            StatusLabel.Text = ""
        end
    end)
    
    -- Get Key Button Logic
    GetKeyButton.MouseButton1Click:Connect(function()
        StatusLabel.Text = "Opening key link..."
        StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        
        pcall(function()
            if setclipboard then
                setclipboard(Config.FullLink)
                StatusLabel.Text = "Link copied to clipboard!"
            end
        end)
        
        task.wait(2)
        StatusLabel.Text = ""
    end)
    
    -- Validate Button Logic
    ValidateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        StatusLabel.Text = "Validating..."
        StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        ValidateButton.Text = "Validating..."
        
        task.wait(0.5)
        
        local success, message = ValidateKey(key)
        
        if success then
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            ValidateButton.Text = "Success! ✓"
            ValidateButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
            
            task.wait(0.5)
            
            -- Complete fade out animation
            local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            for _, obj in ipairs(MainFrame:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    TweenService:Create(obj, fadeInfo, {TextTransparency = 1}):Play()
                end
                if obj:IsA("Frame") or obj:IsA("ImageButton") then
                    TweenService:Create(obj, fadeInfo, {BackgroundTransparency = 1}):Play()
                end
                if obj:IsA("ImageLabel") then
                    TweenService:Create(obj, fadeInfo, {ImageTransparency = 1}):Play()
                end
                if obj:IsA("UICorner") then
                    obj.Parent.BackgroundTransparency = 1
                end
            end
            
            TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(Shadow, fadeInfo, {ImageTransparency = 1}):Play()
            
            task.wait(0.3)
            ScreenGui:Destroy()
        else
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ValidateButton.Text = "✓ Validate Key"
            
            -- Shake animation
            local originalPos = ValidateButton.Position
            for i = 1, 3 do
                ValidateButton.Position = originalPos + UDim2.new(0, 5, 0, 0)
                task.wait(0.05)
                ValidateButton.Position = originalPos - UDim2.new(0, 5, 0, 0)
                task.wait(0.05)
            end
            ValidateButton.Position = originalPos
        end
    end)
    
    -- Enter key to validate
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ValidateButton.MouseButton1Click:Fire()
        end
    end)
    
    return ScreenGui
end

-- Main Execution
print("[MM2 Premium] Initializing key system...")

-- Check saved key first
local savedKey = LoadKey()
if savedKey then
    print("[MM2 Premium] Checking saved key...")
    local success, message = ValidateKey(savedKey)
    
    if success then
        print("[MM2 Premium] Saved key valid! Loading MM2 Premium...")
        task.wait(0.3)
        
        -- Load the main script
        local scriptSuccess, scriptError = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/mm2_premium.lua"))()
        end)
        
        if not scriptSuccess then
            warn("[MM2 Premium] Failed to load main script:", scriptError)
        end
        return
    else
        print("[MM2 Premium] Saved key invalid: " .. message)
    end
end

-- Show UI
print("[MM2 Premium] Showing key system UI...")
local ui = CreateUI()

-- Wait for validation
while not KeyValidated do
    task.wait(0.1)
end

print("[MM2 Premium] Key validated! Loading MM2 Premium...")
task.wait(0.5)

-- Load the main script
local scriptSuccess, scriptError = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/mm2_premium.lua"))()
end)

if scriptSuccess then
    print("[MM2 Premium] MM2 Premium loaded successfully!")
else
    warn("[MM2 Premium] Failed to load main script:", scriptError)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "MM2 Premium Error",
        Text = "Failed to load script. Check console for details.",
        Duration = 5
    })
end
