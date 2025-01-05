-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Constants
local DEFAULT_SETTINGS = {
    WalkSpeed = 16,
    JumpPower = 50,
    Health = 100,
    MaxHealth = 100,
    HipHeight = 2,
    CameraMaxZoomDistance = 400,
    CameraMinZoomDistance = 0.5
}

-- Variables
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local mouse = player:GetMouse()
local connections = {}
local states = {
    isAutoJumping = false,
    isSpeedBoostActive = false,
    isInfinitJumpEnabled = false,
    isAntiAFKEnabled = false,
    isFlyEnabled = false,
    isESPEnabled = false,
    isInvisible = false,
    isAutoClickEnabled = false,
    isTPWalkEnabled = false,
    isSpinEnabled = false,
    isHeadlessEnabled = false,
    isGodModeEnabled = false
}
local settings = {
    flySpeed = 50,
    spinSpeed = 10,
    clickInterval = 1,
    tpWalkSpeed = 5
}

-- Helper Functions
local function updateHumanoid(property, value)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        OrionLib:MakeNotification({
            Name = "Hastumi Error",
            Content = "Character or Humanoid not found. Please respawn.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        return false
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    
    if type(value) == "string" then
        value = tonumber(value) or DEFAULT_SETTINGS[property]
    end
    
    if property == "WalkSpeed" then
        value = math.clamp(value, 0, 1000)
    elseif property == "JumpPower" then
        value = math.clamp(value, 0, 500)
    elseif property == "Health" or property == "MaxHealth" then
        value = math.clamp(value, 0, 10000)
    elseif property == "HipHeight" then
        value = math.clamp(value, 0, 100)
    end
    
    pcall(function()
        humanoid[property] = value
    end)
    
    return true
end

-- Enhanced Functions
local function setInvisible(enabled)
    if not player.Character then return end
    
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
            part.Transparency = enabled and 1 or 0
        end
    end
end

local function toggleHeadless(enabled)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if head then
        head.Transparency = enabled and 1 or 0
        local face = head:FindFirstChild("face")
        if face then
            face.Transparency = enabled and 1 or 0
        end
    end
end

local function spinCharacter()
    if not player.Character then return end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.Name = "HatsumiSpin"
    bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, settings.spinSpeed, 0)
    bodyAngularVelocity.Parent = humanoidRootPart
    return bodyAngularVelocity
end

local function tpWalk(enabled)
    if enabled then
        connections.tpWalk = RunService.RenderStepped:Connect(function()
            if player.Character and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + (camera.CFrame.LookVector * settings.tpWalkSpeed)
                end
            end
        end)
    else
        if connections.tpWalk then
            connections.tpWalk:Disconnect()
            connections.tpWalk = nil
        end
    end
end

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "Hastumi v1 - Advanced",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Hastumi",
    IntroEnabled = true,
    IntroText = "Hastumi v1 Loading...",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Character Tab
local CharacterTab = Window:MakeTab({
    Name = "Character",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Movement Settings
local MovementSection = CharacterTab:AddSection({
    Name = "Movement Settings"
})

MovementSection:AddSlider({
    Name = "WalkSpeed",
    Min = 0,
    Max = 500,
    Default = DEFAULT_SETTINGS.WalkSpeed,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        updateHumanoid("WalkSpeed", Value)
    end    
})

MovementSection:AddSlider({
    Name = "JumpPower",
    Min = 0,
    Max = 350,
    Default = DEFAULT_SETTINGS.JumpPower,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        updateHumanoid("JumpPower", Value)
    end    
})

MovementSection:AddSlider({
    Name = "Hip Height",
    Min = 0,
    Max = 50,
    Default = DEFAULT_SETTINGS.HipHeight,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.5,
    ValueName = "Height",
    Callback = function(Value)
        updateHumanoid("HipHeight", Value)
    end    
})

-- Avatar Section
local AvatarSection = CharacterTab:AddSection({
    Name = "Avatar Customization"
})

AvatarSection:AddToggle({
    Name = "Invisible",
    Default = false,
    Callback = function(Value)
        states.isInvisible = Value
        setInvisible(Value)
    end
})

AvatarSection:AddToggle({
    Name = "Headless",
    Default = false,
    Callback = function(Value)
        states.isHeadlessEnabled = Value
        toggleHeadless(Value)
    end
})

AvatarSection:AddToggle({
    Name = "Spin",
    Default = false,
    Callback = function(Value)
        states.isSpinEnabled = Value
        if Value then
            connections.spin = spinCharacter()
        else
            if connections.spin then
                connections.spin:Destroy()
                connections.spin = nil
            end
        end
    end
})

AvatarSection:AddSlider({
    Name = "Spin Speed",
    Min = 1,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        settings.spinSpeed = Value
        if connections.spin then
            connections.spin.AngularVelocity = Vector3.new(0, Value, 0)
        end
    end    
})

-- Combat Tab
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddToggle({
    Name = "Auto Click",
    Default = false,
    Callback = function(Value)
        states.isAutoClickEnabled = Value
        if Value then
            connections.autoClick = RunService.Heartbeat:Connect(function()
                VirtualUser:Button1Down(Vector2.new(0,0))
                wait(settings.clickInterval)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        else
            if connections.autoClick then
                connections.autoClick:Disconnect()
                connections.autoClick = nil
            end
        end
    end
})

CombatTab:AddSlider({
    Name = "Click Interval",
    Min = 0.1,
    Max = 2,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "Seconds",
    Callback = function(Value)
        settings.clickInterval = Value
    end    
})

-- Enhanced Movement Tab
local EnhancedTab = Window:MakeTab({
    Name = "Enhanced",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

EnhancedTab:AddToggle({
    Name = "TP Walk",
    Default = false,
    Callback = function(Value)
        states.isTPWalkEnabled = Value
        tpWalk(Value)
    end
})

EnhancedTab:AddSlider({
    Name = "TP Walk Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.5,
    ValueName = "Speed",
    Callback = function(Value)
        settings.tpWalkSpeed = Value
    end    
})

-- Camera Tab
local CameraTab = Window:MakeTab({
    Name = "Camera",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CameraTab:AddSlider({
    Name = "FOV",
    Min = 1,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        camera.FieldOfView = Value
    end    
})

CameraTab:AddSlider({
    Name = "Max Zoom Distance",
    Min = 0,
    Max = 1000,
    Default = DEFAULT_SETTINGS.CameraMaxZoomDistance,
    Color = Color3.fromRGB(255,255,255),
    Increment = 10,
    ValueName = "Distance",
    Callback = function(Value)
        player.CameraMaxZoomDistance = Value
    end    
})

CameraTab:AddSlider({
    Name = "Min Zoom Distance",
    Min = 0,
    Max = 10,
    Default = DEFAULT_SETTINGS.CameraMinZoomDistance,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.5,
    ValueName = "Distance",
    Callback = function(Value)
        player.CameraMinZoomDistance = Value
    end    
})

-- Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddButton({
    Name = "Click TP Tool",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "Click Teleport"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local position = mouse.Hit.Position
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
            end
        end)
        
        tool.Parent = player.Backpack
    end    
})

local playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        table.insert(playerList, plr.Name)
    end
end

TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = playerList,
    Callback = function(Value)
        local targetPlayer = Players:FindFirstChild(Value)
        if targetPlayer and targetPlayer.Character and player.Character then
            player.Character:MoveTo(targetPlayer.Character.HumanoidRootPart.Position)
        end
    end    
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        -- Reset all toggles and states
        for key, _ in pairs(states) do
            states[key] = false
        end
        
        -- Reset all modifications
        if player.Character then
            updateHumanoid("WalkSpeed", DEFAULT_SETTINGS.WalkSpeed)
            updateHumanoid("JumpPower", DEFAULT_SETTINGS.JumpPower)
            updateHumanoid("HipHeight", DEFAULT_SETTINGS.HipHeight)
            setInvisible(false)
            toggleHeadless(false)
        end
        
        -- Reset camera settings
        camera.FieldOfView = 70
        player.CameraMaxZoomDistance = DEFAULT_SETTINGS.CameraMaxZoomDistance
        player.CameraMinZoomDistance = DEFAULT_SETTINGS.CameraMinZoomDistance
        
        -- Clean up all connections
        for _, connection in pairs(connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            elseif typeof(connection) == "Instance" then
                connection:Destroy()
            end
        end
        connections = {}
        
        OrionLib:MakeNotification({
            Name = "Settings Reset",
            Content = "All settings have been reset to default",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

SettingsTab:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end    
})

-- Credits Section
local CreditsSection = SettingsTab:AddSection({
    Name = "Credits"
})

CreditsSection:AddLabel("Created by: z4trox")
CreditsSection:AddLabel("Version: 1.0.0")
CreditsSection:AddLabel("Discord: z4trox")

-- Information Tab
local InfoTab = Window:MakeTab({
    Name = "Information",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Game Info Section
local GameInfoSection = InfoTab:AddSection({
    Name = "Game Information"
})

GameInfoSection:AddLabel("Game ID: " .. game.PlaceId)
GameInfoSection:AddLabel("Server Job ID: " .. game.JobId)
GameInfoSection:AddLabel("Server Time: " .. os.date("%H:%M:%S"))

-- Player Info Section
local PlayerInfoSection = InfoTab:AddSection({
    Name = "Player Information"
})

-- Update Player Stats
local playerStatsLabel
local function updatePlayerStats()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local stats = string.format(
            "Health: %.0f/%.0f\nWalkSpeed: %.0f\nJumpPower: %.0f",
            player.Character.Humanoid.Health,
            player.Character.Humanoid.MaxHealth,
            player.Character.Humanoid.WalkSpeed,
            player.Character.Humanoid.JumpPower
        )
        if playerStatsLabel then
            playerStatsLabel:Set(stats)
        else
            playerStatsLabel = PlayerInfoSection:AddLabel(stats)
        end
    end
end

-- Update player stats every second
connections.statsUpdate = RunService.Heartbeat:Connect(function()
    updatePlayerStats()
end)

-- Server Info Section
local ServerInfoSection = InfoTab:AddSection({
    Name = "Server Information"
})

ServerInfoSection:AddLabel("Players Online: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)

-- Update server info periodically
connections.serverInfoUpdate = RunService.Heartbeat:Connect(function()
    ServerInfoSection:AddLabel("Players Online: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
end)

-- Tools Tab
local ToolsTab = Window:MakeTab({
    Name = "Tools",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Basic Tools Section
local BasicToolsSection = ToolsTab:AddSection({
    Name = "Basic Tools"
})

BasicToolsSection:AddButton({
    Name = "Give All Basic Tools",
    Callback = function()
        local tools = {
            {Name = "Teleport Tool", Code = [[
                local tool = Instance.new("Tool")
                tool.Name = "Teleport Tool"
                tool.RequiresHandle = false
                tool.Activated:Connect(function()
                    local pos = mouse.Hit.Position
                    if player.Character then
                        player.Character:MoveTo(pos + Vector3.new(0, 3, 0))
                    end
                end)
                tool.Parent = player.Backpack
            ]]},
            {Name = "Speed Tool", Code = [[
                local tool = Instance.new("Tool")
                tool.Name = "Speed Boost"
                tool.RequiresHandle = false
                local enabled = false
                tool.Activated:Connect(function()
                    enabled = not enabled
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = enabled and 50 or 16
                    end
                end)
                tool.Parent = player.Backpack
            ]]},
            {Name = "Jump Tool", Code = [[
                local tool = Instance.new("Tool")
                tool.Name = "Super Jump"
                tool.RequiresHandle = false
                local enabled = false
                tool.Activated:Connect(function()
                    enabled = not enabled
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.JumpPower = enabled and 100 or 50
                    end
                end)
                tool.Parent = player.Backpack
            ]]}
        }
        
        for _, toolInfo in ipairs(tools) do
            loadstring(toolInfo.Code)()
        end
        
        OrionLib:MakeNotification({
            Name = "Tools Given",
            Content = "Basic tools have been added to your backpack!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

-- Advanced Tools Section
local AdvancedToolsSection = ToolsTab:AddSection({
    Name = "Advanced Tools"
})

AdvancedToolsSection:AddButton({
    Name = "Give Building Tools",
    Callback = function()
        local InsertService = game:GetService("InsertService")
        local buildingTools = InsertService:LoadLocalAsset("rbxassetid://142785488")
        buildingTools.Parent = player.Backpack
    end    
})

-- Keybinds Tab
local KeybindsTab = Window:MakeTab({
    Name = "Keybinds",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Keybinds Section
local KeybindsSection = KeybindsTab:AddSection({
    Name = "Custom Keybinds"
})

KeybindsSection:AddBind({
    Name = "Toggle Fly",
    Default = Enum.KeyCode.F,
    Hold = false,
    Callback = function()
        states.isFlyEnabled = not states.isFlyEnabled
        if states.isFlyEnabled then
            enableFly()
        else
            disableFly()
        end
    end    
})

KeybindsSection:AddBind({
    Name = "Toggle Speed Boost",
    Default = Enum.KeyCode.LeftShift,
    Hold = true,
    Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if not states.isSpeedBoostActive then
                states.isSpeedBoostActive = true
                updateHumanoid("WalkSpeed", player.Character.Humanoid.WalkSpeed * 2)
            else
                states.isSpeedBoostActive = false
                updateHumanoid("WalkSpeed", DEFAULT_SETTINGS.WalkSpeed)
            end
        end
    end    
})

-- Save/Load Settings
local function saveSettings()
    local saveData = {
        states = states,
        settings = settings
    }
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(saveData)
    end)
    
    if success then
        writefile("HatsumiSettings.json", encoded)
        OrionLib:MakeNotification({
            Name = "Settings Saved",
            Content = "Your settings have been saved successfully!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

local function loadSettings()
    if isfile("HatsumiSettings.json") then
        local success, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("HatsumiSettings.json"))
        end)
        
        if success then
            states = decoded.states
            settings = decoded.settings
            OrionLib:MakeNotification({
                Name = "Settings Loaded",
                Content = "Your settings have been loaded successfully!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
end

-- Add Save/Load buttons
SettingsTab:AddButton({
    Name = "Save Settings",
    Callback = function()
        saveSettings()
    end    
})

SettingsTab:AddButton({
    Name = "Load Settings",
    Callback = function()
        loadSettings()
    end    
})

-- Final cleanup
game.Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        saveSettings() -- Auto save on exit
        for _, connection in pairs(connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            elseif typeof(connection) == "Instance" then
                connection:Destroy()
            end
        end
        OrionLib:Destroy()
    end
end)

-- Initialize
loadSettings() -- Load settings on startup

-- Welcome Message
OrionLib:MakeNotification({
    Name = "Welcome to Hastumi v1",
    Content = "Made with ❤️ by z4trox | Press F to toggle fly",
    Image = "rbxassetid://4483345998",
    Time = 5
})
