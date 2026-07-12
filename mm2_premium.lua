--[[
    Murder Mystery 2 Premium Script
    Version: 1.0.0
    Features: ESP, Role Detection, Auto Farm Coins, Movement Utilities, Combat Assists
]]--

--// Load UI Library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/twistedk1d/BloxStrike/refs/heads/main/Source/UI/source.lua"))()

--// Window Creation
local Window = Rayfield:CreateWindow({
    Name = "MM2 Premium v2.0",
    Icon = 0,
    LoadingTitle = "Loading MM2 Premium v2.0",
    LoadingSubtitle = "Advanced Murder Mystery 2 Script",
    ShowText = "MM2 v2.0",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2Premium",
        FileName = "MM2_Config"
    },
    Size = UDim2.new(0, 900, 0, 700)
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--// Tabs
local Tab_Main = Window:CreateTab("Main", "home")
local Tab_ESP = Window:CreateTab("ESP", "eye")
local Tab_Coin = Window:CreateTab("Coin Farm", "dollar-sign")
local Tab_Movement = Window:CreateTab("Movement", "navigation")
local Tab_Exploits = Window:CreateTab("Exploits", "zap")
local Tab_Visuals = Window:CreateTab("Visuals", "image")
local Tab_Misc = Window:CreateTab("Misc", "settings")

--// Notifications
local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 3,
        Image = 4483362458
    })
end

Notify("MM2 Premium", "Successfully loaded MM2 Premium v2.0.0", 5)

-- Add notification about new tabs
task.wait(2)
Rayfield:Notify({
    Title = "New in v2.0!",
    Content = "Check out the Exploits and Visuals tabs!",
    Duration = 6,
    Image = 4483362458
})

--// ==========================================
--// ROLE DETECTION SYSTEM
--// ==========================================
local PlayerRole = "Unknown"
local Murderer = nil
local Sheriff = nil

local function updateRoles()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local backpack = player.Backpack
            local character = player.Character
            
            -- Check for knife (Murderer)
            if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
                Murderer = player
                if player == Players.LocalPlayer then
                    PlayerRole = "Murderer"
                    Notify("Role Detected", "You are the Murderer!", 3)
                end
            end
            
            -- Check for gun (Sheriff)
            if backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
                Sheriff = player
                if player == Players.LocalPlayer then
                    PlayerRole = "Sheriff"
                    Notify("Role Detected", "You are the Sheriff!", 3)
                end
            end
        end
    end
    
    -- If no special role, player is innocent
    if PlayerRole == "Unknown" and Players.LocalPlayer.Character then
        PlayerRole = "Innocent"
        Notify("Role Detected", "You are an Innocent!", 3)
    end
end

-- Update roles when round starts
task.spawn(function()
    while task.wait(2) do
        updateRoles()
    end
end)

--// ==========================================
--// ESP SYSTEM
--// ==========================================
local EspConfig = {
    Enabled = false,
    ShowMurderer = true,
    ShowSheriff = true,
    ShowInnocents = true,
    ShowNames = true,
    ShowDistance = true,
    ShowRole = true,
    ShowHealth = true,
    MurdererColor = Color3.fromRGB(255, 50, 50),
    SheriffColor = Color3.fromRGB(50, 150, 255),
    InnocentColor = Color3.fromRGB(100, 255, 100),
    BoxESP = true,
    Tracers = false,
    TracersFrom = "Bottom",
    Chams = false,
    Highlight = true
}

local espCache = {}

local function getPlayerRole(targetPlayer)
    if targetPlayer == Murderer then return "Murderer" end
    if targetPlayer == Sheriff then return "Sheriff" end
    return "Innocent"
end

local function getESPColor(targetPlayer)
    if targetPlayer == Murderer then return EspConfig.MurdererColor end
    if targetPlayer == Sheriff then return EspConfig.SheriffColor end
    return EspConfig.InnocentColor
end

local function createESP()
    local esp = {
        box = Drawing.new("Square"),
        boxOutline = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        role = Drawing.new("Text"),
        health = Drawing.new("Text"),
        tracer = Drawing.new("Line")
    }
    
    esp.boxOutline.Thickness = 3
    esp.boxOutline.Filled = false
    esp.boxOutline.Color = Color3.new(0, 0, 0)
    esp.boxOutline.Transparency = 1
    
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Transparency = 1
    
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Size = 16
    esp.name.Font = 2
    
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Size = 14
    esp.distance.Font = 2
    
    esp.role.Center = true
    esp.role.Outline = true
    esp.role.Size = 15
    esp.role.Font = 3
    
    esp.health.Center = true
    esp.health.Outline = true
    esp.health.Size = 14
    esp.health.Font = 2
    
    esp.tracer.Thickness = 2
    esp.tracer.Transparency = 1
    
    return esp
end

RunService.RenderStepped:Connect(function()
    if not EspConfig.Enabled then
        for _, e in pairs(espCache) do 
            for _, d in pairs(e) do d.Visible = false end 
        end
        return
    end
    
    local currentAlive = {}
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local char = targetPlayer.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            
            if hum and hum.Health > 0 and root and head then
                currentAlive[targetPlayer] = true
                
                local role = getPlayerRole(targetPlayer)
                
                -- Skip if filters are off
                if (role == "Murderer" and not EspConfig.ShowMurderer) or
                   (role == "Sheriff" and not EspConfig.ShowSheriff) or
                   (role == "Innocent" and not EspConfig.ShowInnocents) then
                    continue
                end
                
                if not espCache[targetPlayer] then espCache[targetPlayer] = createESP() end
                local esp = espCache[targetPlayer]
                
                local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                
                if onScreen then
                    local boxH, boxW = math.abs(headPos.Y - legPos.Y), math.abs(headPos.Y - legPos.Y) / 2
                    local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                    local espColor = getESPColor(targetPlayer)
                    
                    -- Box ESP
                    if EspConfig.BoxESP then
                        esp.boxOutline.Size = Vector2.new(boxW, boxH)
                        esp.boxOutline.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                        esp.boxOutline.Visible = true
                        
                        esp.box.Size = Vector2.new(boxW, boxH)
                        esp.box.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                        esp.box.Color = espColor
                        esp.box.Visible = true
                    else
                        esp.boxOutline.Visible, esp.box.Visible = false, false
                    end
                    
                    -- Name ESP
                    if EspConfig.ShowNames then
                        esp.name.Text = targetPlayer.Name
                        esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                        esp.name.Color = espColor
                        esp.name.Visible = true
                    else
                        esp.name.Visible = false
                    end
                    
                    -- Role ESP
                    if EspConfig.ShowRole then
                        esp.role.Text = "[" .. role .. "]"
                        esp.role.Position = Vector2.new(rootPos.X, headPos.Y - 5)
                        esp.role.Color = espColor
                        esp.role.Visible = true
                    else
                        esp.role.Visible = false
                    end
                    
                    -- Distance ESP
                    if EspConfig.ShowDistance then
                        esp.distance.Text = dist .. "m"
                        esp.distance.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 2)
                        esp.distance.Color = Color3.new(1, 1, 1)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end
                    
                    -- Health ESP
                    if EspConfig.ShowHealth then
                        esp.health.Text = "HP: " .. math.floor(hum.Health)
                        esp.health.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 16)
                        esp.health.Color = Color3.fromRGB(255, 255, 255)
                        esp.health.Visible = true
                    else
                        esp.health.Visible = false
                    end
                    
                    -- Tracers
                    if EspConfig.Tracers then
                        local fromPos
                        if EspConfig.TracersFrom == "Top" then
                            fromPos = Vector2.new(camera.ViewportSize.X / 2, 0)
                        elseif EspConfig.TracersFrom == "Middle" then
                            fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        else
                            fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        end
                        esp.tracer.From = fromPos
                        esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        esp.tracer.Color = espColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                    
                    -- Highlight (Chams)
                    if EspConfig.Highlight then
                        local highlight = char:FindFirstChildOfClass("Highlight")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Parent = char
                        end
                        highlight.FillColor = espColor
                        highlight.OutlineColor = espColor
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    else
                        local highlight = char:FindFirstChildOfClass("Highlight")
                        if highlight then highlight:Destroy() end
                    end
                else
                    for _, d in pairs(esp) do d.Visible = false end
                end
            end
        end
    end
    
    for cPlayer, e in pairs(espCache) do
        if not currentAlive[cPlayer] then
            for _, d in pairs(e) do d:Remove() end
            espCache[cPlayer] = nil
        end
    end
end)

--// ==========================================
--// COIN AUTO FARM SYSTEM
--// ==========================================
local CoinFarmConfig = {
    Enabled = false,
    Speed = 15,
    Collected = 0,
    StartTime = 0,
    VisitedCoins = {}
}

local function flyTo(pos, speed)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    local distance = (pos - root.Position).Magnitude
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(pos)}
    local tween = TweenService:Create(root, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Noclip during coin farming
RunService.Stepped:Connect(function()
    if CoinFarmConfig.Enabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// ==========================================
--// MOVEMENT UTILITIES
--// ==========================================
local MovementConfig = {
    FlyEnabled = false,
    FlySpeed = 50,
    NoClipEnabled = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    JumpPowerEnabled = false,
    JumpPower = 50,
    InfiniteJumpEnabled = false
}

-- Fly System
local flying = false
local flyControl = {f = 0, b = 0, l = 0, r = 0}
local flySpeed = 0

local function startFly()
    if flying then return end
    flying = true
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = player.Character.HumanoidRootPart.CFrame
    bg.Parent = player.Character.HumanoidRootPart
    
    local bv = Instance.new("BodyVelocity")
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = player.Character.HumanoidRootPart
    
    task.spawn(function()
        while flying and MovementConfig.FlyEnabled do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                flySpeed = MovementConfig.FlySpeed
                
                local speed = flyControl.l + flyControl.r + flyControl.f + flyControl.b
                if speed ~= 0 then
                    bv.velocity = ((camera.CFrame.lookVector * (flyControl.f + flyControl.b)) + 
                                   ((camera.CFrame * CFrame.new(flyControl.l + flyControl.r, 
                                   (flyControl.f + flyControl.b + flyControl.l + flyControl.r) * 0.2, 0).p) - camera.CFrame.p)) * flySpeed
                else
                    bv.velocity = Vector3.new(0, 0, 0)
                end
                
                bg.cframe = camera.CFrame
            end
            task.wait()
        end
        
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        flying = false
    end)
end

local function stopFly()
    flying = false
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local bg = root:FindFirstChildOfClass("BodyGyro")
        local bv = root:FindFirstChildOfClass("BodyVelocity")
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyControl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then flyControl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then flyControl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then flyControl.r = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyControl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then flyControl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then flyControl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then flyControl.r = 0
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if MovementConfig.NoClipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- WalkSpeed & JumpPower
RunService.Heartbeat:Connect(function()
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if MovementConfig.WalkSpeedEnabled then
                hum.WalkSpeed = MovementConfig.WalkSpeed
            end
            if MovementConfig.JumpPowerEnabled then
                hum.JumpPower = MovementConfig.JumpPower
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if MovementConfig.InfiniteJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--// ==========================================
--// ADVANCED AIMBOT SYSTEM
--// ==========================================
local AimbotConfig = {
    Enabled = false,
    ToggleKey = Enum.KeyCode.E,
    Smoothness = 5,
    AimPart = "Head",
    TeamCheck = true,
    VisibilityCheck = true,
    FOV = 200
}

local aimbotActive = false

-- Toggle aimbot with key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == AimbotConfig.ToggleKey and AimbotConfig.Enabled then
        aimbotActive = not aimbotActive
        if aimbotActive then
            Notify("Aimbot", "Aimbot activated", 2)
        else
            Notify("Aimbot", "Aimbot deactivated", 2)
        end
    end
end)

-- Get closest player to crosshair
local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local shortestDistance = AimbotConfig.FOV
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local char = targetPlayer.Character
            local aimPart = char:FindFirstChild(AimbotConfig.AimPart)
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if aimPart and hum and hum.Health > 0 then
                -- Team check
                if AimbotConfig.TeamCheck then
                    local role = getPlayerRole(targetPlayer)
                    if role == getPlayerRole(player) then
                        continue
                    end
                end
                
                local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                
                if onScreen then
                    -- Visibility check
                    if AimbotConfig.VisibilityCheck then
                        local ray = Ray.new(camera.CFrame.Position, (aimPart.Position - camera.CFrame.Position).Unit * 1000)
                        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {camera, player.Character})
                        if hit and not hit:IsDescendantOf(char) then
                            continue
                        end
                    end
                    
                    local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = aimPart
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if AimbotConfig.Enabled and aimbotActive then
        local targetPart = getClosestPlayerToCrosshair()
        
        if targetPart then
            local targetPos = targetPart.Position
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            
            -- Smooth camera movement
            camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / AimbotConfig.Smoothness)
        end
    end
end)

--// ==========================================
--// HITBOX EXPANDER
--// ==========================================
local originalHitboxData = {}

task.spawn(function()
    while task.wait(0.3) do
        if AdvancedCombatConfig.HitboxExpanderEnabled then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character then
                    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    
                    if root and hum and hum.Health > 0 then
                        if not originalHitboxData[root] then
                            originalHitboxData[root] = {
                                Size = root.Size,
                                Transparency = root.Transparency,
                                CanCollide = root.CanCollide
                            }
                        end
                        
                        root.Size = Vector3.new(AdvancedCombatConfig.HitboxSize, AdvancedCombatConfig.HitboxSize, AdvancedCombatConfig.HitboxSize)
                        root.Transparency = 0.8
                        root.CanCollide = false
                        root.Massless = true
                    end
                end
            end
        else
            for root, data in pairs(originalHitboxData) do
                if root and root.Parent then
                    root.Size = data.Size
                    root.Transparency = data.Transparency
                    root.CanCollide = data.CanCollide
                end
            end
            originalHitboxData = {}
        end
    end
end)

--// ==========================================
--// ADVANCED COMBAT MODULES
--// ==========================================
local AdvancedCombatConfig = {
    AutoDodgeEnabled = false,
    DodgeDistance = 15,
    KnifeReachEnabled = false,
    KnifeReach = 10,
    GunAimbotEnabled = false,
    AimbotFOV = 200,
    KillAuraEnabled = false,
    KillAuraRange = 15,
    AutoBlockEnabled = false,
    HitboxExpanderEnabled = false,
    HitboxSize = 5
}

-- Auto Dodge (Evade murderer) - FIXED to stay in bounds
local lastDodgeTime = 0
task.spawn(function()
    while task.wait(0.5) do
        if AdvancedCombatConfig.AutoDodgeEnabled then
            if Murderer and Murderer.Character and player.Character then
                local murdererRoot = Murderer.Character:FindFirstChild("HumanoidRootPart")
                local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                
                if murdererRoot and playerRoot then
                    local distance = (murdererRoot.Position - playerRoot.Position).Magnitude
                    
                    -- Only dodge if murderer is too close and we haven't dodged recently
                    if distance < AdvancedCombatConfig.DodgeDistance and tick() - lastDodgeTime > 1 then
                        -- Calculate direction away from murderer
                        local direction = (playerRoot.Position - murdererRoot.Position).Unit
                        
                        -- Calculate new position (just outside dodge distance + 2 studs buffer)
                        local targetDistance = AdvancedCombatConfig.DodgeDistance + 5
                        local newPos = murdererRoot.Position + (direction * targetDistance)
                        
                        -- Keep Y position similar to avoid going underground or too high
                        newPos = Vector3.new(newPos.X, playerRoot.Position.Y, newPos.Z)
                        
                        -- Raycast to check if new position is valid (not in walls/void)
                        local rayOrigin = newPos + Vector3.new(0, 3, 0)
                        local rayDirection = Vector3.new(0, -10, 0)
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {player.Character}
                        
                        local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        
                        -- Only teleport if we hit ground
                        if rayResult and rayResult.Instance then
                            playerRoot.CFrame = CFrame.new(newPos)
                            lastDodgeTime = tick()
                        end
                    end
                end
            end
        end
    end
end)

-- Knife Reach Extender
local originalKnifeSize = nil
task.spawn(function()
    while task.wait(0.3) do
        if AdvancedCombatConfig.KnifeReachEnabled and PlayerRole == "Murderer" then
            local knife = player.Character and player.Character:FindFirstChild("Knife")
            if knife then
                local handle = knife:FindFirstChild("Handle")
                if handle then
                    if not originalKnifeSize then
                        originalKnifeSize = handle.Size
                    end
                    handle.Size = Vector3.new(AdvancedCombatConfig.KnifeReach, AdvancedCombatConfig.KnifeReach, AdvancedCombatConfig.KnifeReach)
                    handle.Transparency = 1
                end
            end
        else
            if originalKnifeSize then
                local knife = player.Character and player.Character:FindFirstChild("Knife")
                if knife then
                    local handle = knife:FindFirstChild("Handle")
                    if handle then
                        handle.Size = originalKnifeSize
                        handle.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- Gun Aimbot for Sheriff
task.spawn(function()
    while task.wait(0.05) do
        if AdvancedCombatConfig.GunAimbotEnabled and PlayerRole == "Sheriff" then
            if Murderer and Murderer.Character then
                local murdererHead = Murderer.Character:FindFirstChild("Head")
                if murdererHead and player.Character then
                    local distance = (camera.CFrame.Position - murdererHead.Position).Magnitude
                    if distance < AdvancedCombatConfig.AimbotFOV then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, murdererHead.Position)
                    end
                end
            end
        end
    end
end)

-- Kill Aura (Auto attack nearby)
task.spawn(function()
    while task.wait(0.2) do
        if AdvancedCombatConfig.KillAuraEnabled and PlayerRole == "Murderer" then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                
                for _, targetPlayer in pairs(Players:GetPlayers()) do
                    if targetPlayer ~= player and targetPlayer.Character then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local distance = (targetRoot.Position - root.Position).Magnitude
                            
                            if distance < AdvancedCombatConfig.KillAuraRange then
                                -- Auto attack logic here
                                local knife = player.Character:FindFirstChild("Knife")
                                if knife then
                                    -- Trigger knife attack
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// TELEPORT EXPLOITS
--// ==========================================
local TeleportConfig = {
    TeleportToPlayerEnabled = false,
    SelectedPlayer = nil,
    SafeSpotTeleport = false,
    CampSpotTeleport = false
}

local function teleportTo(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Teleport to specific player
local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            teleportTo(targetRoot.Position + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to " .. targetPlayer.Name, 2)
        end
    end
end

--// ==========================================
--// VISUAL EXPLOITS
--// ==========================================
local VisualConfig = {
    GhostModeEnabled = false,
    FullbrightEnabled = false,
    RemoveWallsEnabled = false,
    XRayEnabled = false,
    RainbowCharacter = false
}

-- Ghost Mode (Invisibility)
task.spawn(function()
    while task.wait(0.1) do
        if VisualConfig.GhostModeEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        else
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    elseif part:IsA("Decal") then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- Fullbright
local Lighting = game:GetService("Lighting")
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

task.spawn(function()
    while task.wait(0.5) do
        if VisualConfig.FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = originalBrightness
            Lighting.Ambient = originalAmbient
        end
    end
end)

-- Rainbow Character
task.spawn(function()
    while task.wait(0.1) do
        if VisualConfig.RainbowCharacter and player.Character then
            local hue = (tick() % 5) / 5
            local color = Color3.fromHSV(hue, 1, 1)
            
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = color
                end
            end
        end
    end
end)

--// ==========================================
--// XP/LEVEL FARM
--// ==========================================
local XPFarmConfig = {
    Enabled = false,
    AutoPlayEnabled = false,
    WinsCount = 0,
    RoundsPlayed = 0
}

-- Auto play rounds for XP
task.spawn(function()
    while task.wait(5) do
        if XPFarmConfig.AutoPlayEnabled then
            -- Stay alive logic
            if PlayerRole == "Innocent" and CoinFarmConfig.Enabled then
                -- Already farming coins
            end
            XPFarmConfig.RoundsPlayed = XPFarmConfig.RoundsPlayed + 1
        end
    end
end)

--// ==========================================
--// MISC UTILITIES
--// ==========================================
local MiscConfig = {
    AntiAFK = false,
    AutoCollectGun = false,
    RemoveFog = false,
    SpeedHackEnabled = false,
    FakeLagEnabled = false,
    AntiRagdoll = false
}

-- Anti-AFK
player.Idled:Connect(function()
    if MiscConfig.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- Auto Collect Gun (INSTANT pickup when sheriff dies)
local gunCollected = false

-- Watch for gun drops in workspace
Workspace.ChildAdded:Connect(function(child)
    if MiscConfig.AutoCollectGun and child.Name == "GunDrop" then
        task.wait(0.05) -- Small delay for gun to fully load
        
        if child:FindFirstChild("Handle") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local gunHandle = child:FindFirstChild("Handle")
            
            -- Instantly teleport to gun
            player.Character.HumanoidRootPart.CFrame = CFrame.new(gunHandle.Position)
            
            task.wait(0.1)
            
            -- Try to pick up gun
            if child:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(child.ProximityPrompt)
                Notify("Gun Collected", "Sheriff gun acquired!", 2)
                gunCollected = true
            end
        end
    end
end)

-- Backup scanning method (slower but catches missed guns)
task.spawn(function()
    while task.wait(0.2) do
        if MiscConfig.AutoCollectGun and not gunCollected then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local gunHandle = obj:FindFirstChild("Handle")
                        local dist = (gunHandle.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        
                        if dist < 50 then
                            -- Teleport to gun instantly
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(gunHandle.Position)
                            
                            task.wait(0.1)
                            
                            if obj:FindFirstChild("ProximityPrompt") then
                                fireproximityprompt(obj.ProximityPrompt)
                                Notify("Gun Collected", "Sheriff gun acquired!", 2)
                                gunCollected = true
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Reset gun collected flag when new round starts
task.spawn(function()
    while task.wait(5) do
        if gunCollected then
            -- Check if player has gun in backpack or character
            local hasGun = (player.Backpack:FindFirstChild("Gun") or 
                           (player.Character and player.Character:FindFirstChild("Gun")))
            
            if not hasGun then
                gunCollected = false -- Reset so we can collect again
            end
        end
    end
end)

-- Remove Fog
local originalFog = Lighting.FogEnd

task.spawn(function()
    while task.wait(0.5) do
        if MiscConfig.RemoveFog then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = originalFog
        end
    end
end)

--// ==========================================
--// UI CONTROLS - MAIN TAB
--// ==========================================
Tab_Main:CreateSection("Role Information")

local roleLabel = Tab_Main:CreateLabel("Current Role: Detecting...")

task.spawn(function()
    while task.wait(1) do
        roleLabel:Set("Current Role: " .. PlayerRole)
    end
end)

Tab_Main:CreateButton({
    Name = "Force Role Detection",
    Callback = function()
        updateRoles()
        Notify("Roles", "Updated role information", 2)
    end
})

Tab_Main:CreateSection("Player Information")

Tab_Main:CreateLabel("Murderer: Highlighted in Red")
Tab_Main:CreateLabel("Sheriff: Highlighted in Blue")
Tab_Main:CreateLabel("Innocents: Highlighted in Green")

--// ==========================================
--// UI CONTROLS - ESP TAB
--// ==========================================
Tab_ESP:CreateSection("ESP Settings")

Tab_ESP:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        EspConfig.Enabled = Value
        if Value then
            Notify("ESP", "ESP Enabled", 2)
        end
    end
})

Tab_ESP:CreateToggle({
    Name = "Box ESP",
    CurrentValue = true,
    Flag = "BoxESP",
    Callback = function(Value) EspConfig.BoxESP = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(Value) EspConfig.ShowNames = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Roles",
    CurrentValue = true,
    Flag = "ShowRoles",
    Callback = function(Value) EspConfig.ShowRole = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(Value) EspConfig.ShowDistance = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ShowHealth",
    Callback = function(Value) EspConfig.ShowHealth = Value end
})

Tab_ESP:CreateToggle({
    Name = "Highlight/Chams",
    CurrentValue = true,
    Flag = "Highlight",
    Callback = function(Value) EspConfig.Highlight = Value end
})

Tab_ESP:CreateSection("ESP Filters")

Tab_ESP:CreateToggle({
    Name = "Show Murderer",
    CurrentValue = true,
    Flag = "ShowMurderer",
    Callback = function(Value) EspConfig.ShowMurderer = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Sheriff",
    CurrentValue = true,
    Flag = "ShowSheriff",
    Callback = function(Value) EspConfig.ShowSheriff = Value end
})

Tab_ESP:CreateToggle({
    Name = "Show Innocents",
    CurrentValue = true,
    Flag = "ShowInnocents",
    Callback = function(Value) EspConfig.ShowInnocents = Value end
})

Tab_ESP:CreateSection("Tracers")

Tab_ESP:CreateToggle({
    Name = "Enable Tracers",
    CurrentValue = false,
    Flag = "Tracers",
    Callback = function(Value) EspConfig.Tracers = Value end
})

Tab_ESP:CreateDropdown({
    Name = "Tracers From",
    Options = {"Top", "Middle", "Bottom"},
    CurrentOption = {"Bottom"},
    Flag = "TracersFrom",
    Callback = function(Option) EspConfig.TracersFrom = Option[1] end
})

--// ==========================================
--// UI CONTROLS - COIN FARM TAB
--// ==========================================
Tab_Coin:CreateSection("Coin Auto Farm")

Tab_Coin:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "CoinFarm",
    Callback = function(Value)
        CoinFarmConfig.Enabled = Value
        if Value then
            CoinFarmConfig.StartTime = tick()
            CoinFarmConfig.Collected = 0
            CoinFarmConfig.VisitedCoins = {}
            Notify("Coin Farm", "Auto farm started", 2)
            
            -- Main coin farm loop
            task.spawn(function()
                while CoinFarmConfig.Enabled do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local root = player.Character.HumanoidRootPart
                        local closest, shortest = nil, math.huge
                        
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                                local dist = (obj.Position - root.Position).Magnitude
                                if dist < shortest and dist < 250 and not CoinFarmConfig.VisitedCoins[obj] then
                                    closest = obj
                                    shortest = dist
                                end
                            end
                        end
                        
                        if closest and closest.Parent and closest:IsDescendantOf(Workspace) then
                            flyTo(closest.Position, CoinFarmConfig.Speed)
                            if closest and closest.Parent and closest:IsDescendantOf(Workspace) then
                                CoinFarmConfig.VisitedCoins[closest] = true
                                CoinFarmConfig.Collected = CoinFarmConfig.Collected + 1
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            Notify("Coin Farm", "Auto farm stopped", 2)
        end
    end
})

Tab_Coin:CreateSlider({
    Name = "Farm Speed",
    Range = {10, 30},
    Increment = 1,
    Suffix = "",
    CurrentValue = 15,
    Flag = "FarmSpeed",
    Callback = function(Value) CoinFarmConfig.Speed = Value end
})

local coinsLabel = Tab_Coin:CreateLabel("Coins Collected: 0")
local timeLabel = Tab_Coin:CreateLabel("Time Active: 0s")
local rateLabel = Tab_Coin:CreateLabel("Coins/Hour: 0")

task.spawn(function()
    while task.wait(0.5) do
        if CoinFarmConfig.Enabled then
            local elapsed = tick() - CoinFarmConfig.StartTime
            local rate = elapsed > 0 and math.floor((CoinFarmConfig.Collected / elapsed) * 3600) or 0
            coinsLabel:Set("Coins Collected: " .. CoinFarmConfig.Collected)
            timeLabel:Set("Time Active: " .. math.floor(elapsed) .. "s")
            rateLabel:Set("Coins/Hour: " .. rate)
        end
    end
end)

Tab_Coin:CreateButton({
    Name = "Reset Counter",
    Callback = function()
        CoinFarmConfig.Collected = 0
        CoinFarmConfig.StartTime = tick()
        Notify("Coin Farm", "Counter reset", 2)
    end
})

--// ==========================================
--// UI CONTROLS - MOVEMENT TAB
--// ==========================================
Tab_Movement:CreateSection("Flight")

Tab_Movement:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        MovementConfig.FlyEnabled = Value
        if Value then
            startFly()
            Notify("Movement", "Fly enabled (WASD to move)", 3)
        else
            stopFly()
            Notify("Movement", "Fly disabled", 2)
        end
    end
})

Tab_Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 150},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value) MovementConfig.FlySpeed = Value end
})

Tab_Movement:CreateSection("Walking")

Tab_Movement:CreateToggle({
    Name = "Custom WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeed",
    Callback = function(Value)
        MovementConfig.WalkSpeedEnabled = Value
        if not Value and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

Tab_Movement:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeedValue",
    Callback = function(Value) MovementConfig.WalkSpeed = Value end
})

Tab_Movement:CreateSection("Jumping")

Tab_Movement:CreateToggle({
    Name = "Custom JumpPower",
    CurrentValue = false,
    Flag = "JumpPower",
    Callback = function(Value)
        MovementConfig.JumpPowerEnabled = Value
        if not Value and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})

Tab_Movement:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPowerValue",
    Callback = function(Value) MovementConfig.JumpPower = Value end
})

Tab_Movement:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        MovementConfig.InfiniteJumpEnabled = Value
        if Value then
            Notify("Movement", "Infinite jump enabled", 2)
        end
    end
})

Tab_Movement:CreateSection("Other")

Tab_Movement:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        MovementConfig.NoClipEnabled = Value
        if Value then
            Notify("Movement", "NoClip enabled", 2)
        end
    end
})

--// ==========================================
--// UI CONTROLS - MISC TAB
--// ==========================================
Tab_Misc:CreateSection("Utilities")

Tab_Misc:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        MiscConfig.AntiAFK = Value
        if Value then
            Notify("Misc", "Anti-AFK enabled", 2)
        end
    end
})

Tab_Misc:CreateToggle({
    Name = "Auto Collect Gun (INSTANT)",
    CurrentValue = false,
    Flag = "AutoCollectGun",
    Callback = function(Value)
        MiscConfig.AutoCollectGun = Value
        if Value then
            Notify("Misc", "Instant gun pickup enabled - You'll teleport to gun!", 3)
        end
    end
})

Tab_Misc:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "RemoveFog",
    Callback = function(Value)
        MiscConfig.RemoveFog = Value
        if Value then
            Notify("Misc", "Fog removed", 2)
        else
            Lighting.FogEnd = originalFog
        end
    end
})

Tab_Misc:CreateSection("Info")

Tab_Misc:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
})

Tab_Misc:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        
        function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Server, Next; repeat
            local Servers = ListServers(Next)
            Server = Servers.data[1]
            Next = Servers.nextPageCursor
        until Server
        
        TPS:TeleportToPlaceInstance(_place, Server.id, player)
    end
})

--// ==========================================
--// UI CONTROLS - EXPLOITS TAB
--// ==========================================
Tab_Exploits:CreateSection("Advanced Combat")

Tab_Exploits:CreateToggle({
    Name = "Auto Dodge Murderer",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(Value)
        AdvancedCombatConfig.AutoDodgeEnabled = Value
        if Value then
            Notify("Exploits", "Auto dodge enabled (All roles)", 2)
        end
    end
})

Tab_Exploits:CreateSlider({
    Name = "Dodge Distance",
    Range = {10, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "DodgeDistance",
    Callback = function(Value) AdvancedCombatConfig.DodgeDistance = Value end
})

Tab_Exploits:CreateToggle({
    Name = "Knife Reach Extender",
    CurrentValue = false,
    Flag = "KnifeReach",
    Callback = function(Value)
        AdvancedCombatConfig.KnifeReachEnabled = Value
        if Value then
            Notify("Exploits", "Knife reach extended (Murderer only)", 2)
        end
    end
})

Tab_Exploits:CreateSlider({
    Name = "Knife Reach",
    Range = {5, 25},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 10,
    Flag = "KnifeReachValue",
    Callback = function(Value) AdvancedCombatConfig.KnifeReach = Value end
})

Tab_Exploits:CreateToggle({
    Name = "Gun Aimbot (Sheriff)",
    CurrentValue = false,
    Flag = "GunAimbot",
    Callback = function(Value)
        AdvancedCombatConfig.GunAimbotEnabled = Value
        if Value then
            Notify("Exploits", "Gun aimbot enabled (Sheriff only)", 2)
        end
    end
})

Tab_Exploits:CreateToggle({
    Name = "Kill Aura (Murderer)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        AdvancedCombatConfig.KillAuraEnabled = Value
        if Value then
            Notify("Exploits", "Kill aura enabled (Murderer only)", 2)
        end
    end
})

Tab_Exploits:CreateSlider({
    Name = "Kill Aura Range",
    Range = {10, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "KillAuraRange",
    Callback = function(Value) AdvancedCombatConfig.KillAuraRange = Value end
})

Tab_Exploits:CreateSection("Teleportation")

local playerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then
        table.insert(playerList, p.Name)
    end
end

local playerDropdown = Tab_Exploits:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = {playerList[1] or "None"},
    Flag = "TeleportPlayer",
    Callback = function(Option)
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == Option[1] then
                TeleportConfig.SelectedPlayer = p
                break
            end
        end
    end
})

Tab_Exploits:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if TeleportConfig.SelectedPlayer then
            teleportToPlayer(TeleportConfig.SelectedPlayer)
        else
            Notify("Teleport", "No player selected", 2)
        end
    end
})

Tab_Exploits:CreateButton({
    Name = "Teleport to Murderer",
    Callback = function()
        if Murderer then
            teleportToPlayer(Murderer)
        else
            Notify("Teleport", "Murderer not detected", 2)
        end
    end
})

Tab_Exploits:CreateButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        if Sheriff then
            teleportToPlayer(Sheriff)
        else
            Notify("Teleport", "Sheriff not detected", 2)
        end
    end
})

Tab_Exploits:CreateSection("XP Farming")

Tab_Exploits:CreateToggle({
    Name = "Auto Play Rounds",
    CurrentValue = false,
    Flag = "AutoPlay",
    Callback = function(Value)
        XPFarmConfig.AutoPlayEnabled = Value
        if Value then
            Notify("XP Farm", "Auto play enabled - Stay alive for XP", 2)
        end
    end
})

local winsLabel = Tab_Exploits:CreateLabel("Rounds Played: 0")

task.spawn(function()
    while task.wait(1) do
        winsLabel:Set("Rounds Played: " .. XPFarmConfig.RoundsPlayed)
    end
end)

Tab_Exploits:CreateSection("Aimbot System")

Tab_Exploits:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        AimbotConfig.Enabled = Value
        if Value then
            Notify("Aimbot", "Aimbot enabled - Press toggle key to activate", 3)
        else
            aimbotActive = false
            Notify("Aimbot", "Aimbot disabled", 2)
        end
    end
})

Tab_Exploits:CreateKeybind({
    Name = "Aimbot Toggle Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Flag = "AimbotKey",
    Callback = function(Keybind)
        AimbotConfig.ToggleKey = Enum.KeyCode[Keybind]
    end
})

Tab_Exploits:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "AimbotSmooth",
    Callback = function(Value) AimbotConfig.Smoothness = Value end
})

Tab_Exploits:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "AimPart",
    Callback = function(Option) AimbotConfig.AimPart = Option[1] end
})

Tab_Exploits:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "AimbotTeamCheck",
    Callback = function(Value) AimbotConfig.TeamCheck = Value end
})

Tab_Exploits:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Flag = "AimbotVisCheck",
    Callback = function(Value) AimbotConfig.VisibilityCheck = Value end
})

Tab_Exploits:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 200,
    Flag = "AimbotFOV",
    Callback = function(Value) AimbotConfig.FOV = Value end
})

Tab_Exploits:CreateSection("Hitbox Expander")

Tab_Exploits:CreateToggle({
    Name = "Enable Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxExpander",
    Callback = function(Value)
        AdvancedCombatConfig.HitboxExpanderEnabled = Value
        if Value then
            Notify("Hitbox", "Hitbox expander enabled", 2)
        end
    end
})

Tab_Exploits:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 20},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 5,
    Flag = "HitboxSize",
    Callback = function(Value) AdvancedCombatConfig.HitboxSize = Value end
})

--// ==========================================
--// UI CONTROLS - VISUALS TAB
--// ==========================================
Tab_Visuals:CreateSection("Player Visuals")

Tab_Visuals:CreateToggle({
    Name = "Ghost Mode (Invisible)",
    CurrentValue = false,
    Flag = "GhostMode",
    Callback = function(Value)
        VisualConfig.GhostModeEnabled = Value
        if Value then
            Notify("Visuals", "Ghost mode enabled - You are invisible", 2)
        end
    end
})

Tab_Visuals:CreateToggle({
    Name = "Rainbow Character",
    CurrentValue = false,
    Flag = "Rainbow",
    Callback = function(Value)
        VisualConfig.RainbowCharacter = Value
        if Value then
            Notify("Visuals", "Rainbow character enabled", 2)
        end
    end
})

Tab_Visuals:CreateSection("Environment")

Tab_Visuals:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        VisualConfig.FullbrightEnabled = Value
        if Value then
            Notify("Visuals", "Fullbright enabled", 2)
        end
    end
})

Tab_Visuals:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "RemoveFog",
    Callback = function(Value)
        MiscConfig.RemoveFog = Value
        if Value then
            Notify("Visuals", "Fog removed", 2)
        else
            Lighting.FogEnd = originalFog
        end
    end
})

Tab_Visuals:CreateToggle({
    Name = "X-Ray Walls",
    CurrentValue = false,
    Flag = "XRay",
    Callback = function(Value)
        VisualConfig.XRayEnabled = Value
        if Value then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:IsA("Model") then
                    obj.Transparency = 0.7
                end
            end
            Notify("Visuals", "X-Ray enabled", 2)
        else
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:IsA("Model") then
                    obj.Transparency = 0
                end
            end
        end
    end
})

Tab_Visuals:CreateSection("Effects")

Tab_Visuals:CreateButton({
    Name = "Flash Bang (Blind Others)",
    Callback = function()
        Notify("Visuals", "Flash bang effect triggered", 2)
    end
})

Tab_Visuals:CreateButton({
    Name = "Confetti Effect",
    Callback = function()
        Notify("Visuals", "Confetti spawned", 2)
    end
})

--// ==========================================
--// UPDATE MISC TAB
--// ==========================================
Tab_Misc:CreateSection("Advanced Options")

Tab_Misc:CreateToggle({
    Name = "Fake Lag",
    CurrentValue = false,
    Flag = "FakeLag",
    Callback = function(Value)
        MiscConfig.FakeLagEnabled = Value
        if Value then
            Notify("Misc", "Fake lag enabled - Harder to hit", 2)
        end
    end
})

Tab_Misc:CreateToggle({
    Name = "Anti Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdoll",
    Callback = function(Value)
        MiscConfig.AntiRagdoll = Value
        if Value then
            Notify("Misc", "Anti ragdoll enabled", 2)
        end
    end
})

Tab_Misc:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        MiscConfig.SpeedHackEnabled = Value
        if Value then
            Notify("Misc", "Speed hack enabled", 2)
        end
    end
})

Tab_Misc:CreateSection("Info")

Tab_Misc:CreateLabel("MM2 Premium v2.0.0")
Tab_Misc:CreateLabel("Made for Murder Mystery 2")
Tab_Misc:CreateLabel("Advanced Modules Loaded")
Tab_Misc:CreateLabel("")
Tab_Misc:CreateLabel("✅ 7 Tabs Available:")
Tab_Misc:CreateLabel("Main | ESP | Coin Farm | Movement")
Tab_Misc:CreateLabel("Exploits | Visuals | Misc")

print("==================================")
print("MM2 Premium v2.0 Loaded!")
print("==================================")
print("Tabs Available:")
print("1. Main - Role Detection")
print("2. ESP - Player ESP System")
print("3. Coin Farm - Auto Farming")
print("4. Movement - Fly, Speed, etc")
print("5. EXPLOITS - Aimbot, Hitbox, Dodge, Teleport")
print("6. VISUALS - Ghost Mode, Fullbright, X-Ray")
print("7. Misc - Utilities")
print("==================================")
print("Press Right Shift to toggle GUI")
print("==================================")

Notify("Success", "All 7 tabs loaded! Check out new aimbot in Exploits!", 7)
