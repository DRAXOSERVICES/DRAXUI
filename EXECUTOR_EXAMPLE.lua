--[[  
    DRAXUI Exploit Script Example
    Compatible with: Synapse X, KRNL, Xeno, AWP, ScriptWare, and other Roblox executors
    
    This example demonstrates how to use DRAXUI in an exploit environment
]]--

-- Load DRAXUI library (replace with your actual raw GitHub URL when you upload it)
loadstring(game:HttpGet('https://raw.githubusercontent.com/DRAXOSERVICES/DRAXUI/main/UI.lua'))()

-- The library automatically initializes and creates a global UI variable
-- You can access it directly as 'UI'

-- Create a window for our exploit
local window = UI:Window("DRAXUI Exploit Example", {
    size = Vector2.new(500, 400),
    position = Vector2.new(100, 100),
    theme = "Dark" -- You can use "Dark", "Light", or "Neon"
})

-- Create tabs
UI:Tab("Main")
    -- Add a label with executor info
    UI:Label("Running on: " .. UI.ExecutorInfo.Executor)
    
    -- Add a button to teleport the player
    UI:Button("Teleport to Random Player", function()
        local players = game:GetService("Players"):GetPlayers()
        local randomPlayer = players[math.random(1, #players)]
        
        if randomPlayer and randomPlayer.Character and game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(
                randomPlayer.Character:GetPrimaryPartCFrame()
            )
        end
    end)
    
    -- Add a toggle for ESP
    local espEnabled = false
    UI:Toggle("Player ESP", espEnabled, function(value)
        espEnabled = value
        
        if espEnabled then
            -- Simple ESP implementation
            local function createESP(player)
                local highlight = Instance.new("Highlight")
                highlight.Name = "DRAXUI_ESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character
            end
            
            -- Apply ESP to all players
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    createESP(player)
                end
            end
        else
            -- Remove ESP
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    local esp = player.Character:FindFirstChild("DRAXUI_ESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end)
    
    -- Add a slider for walkspeed
    UI:Slider("WalkSpeed", 16, 16, 100, function(value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end)

UI:Tab("Visuals")
    -- Add a color picker for changing character color
    UI:ColorPicker("Character Color", Color3.fromRGB(255, 255, 255), function(color)
        if game.Players.LocalPlayer.Character then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Color = color
                end
            end
        end
    end)
    
    -- Add a dropdown for time of day
    UI:Dropdown("Time of Day", {"Day", "Night", "Sunset"}, function(option)
        if option == "Day" then
            game:GetService("Lighting").TimeOfDay = "12:00:00"
        elseif option == "Night" then
            game:GetService("Lighting").TimeOfDay = "00:00:00"
        elseif option == "Sunset" then
            game:GetService("Lighting").TimeOfDay = "18:00:00"
        end
    end)
    
    -- Add a toggle for fullbright
    UI:Toggle("Fullbright", false, function(value)
        if value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").ClockTime = game:GetService("Lighting").TimeOfDay
            game:GetService("Lighting").FogEnd = 10000
            game:GetService("Lighting").GlobalShadows = true
        end
    end)

UI:Tab("Settings")
    -- Add a keybind to toggle UI visibility
    UI:Keybind("Toggle UI", Enum.KeyCode.RightShift, function()
        UI.ScreenGui.Enabled = not UI.ScreenGui.Enabled
    end)
    
    -- Add a button to destroy the UI
    UI:Button("Unload Script", function()
        UI.ScreenGui:Destroy()
        for _, connection in pairs(UI.Connections) do
            connection:Disconnect()
        end
        UI = nil
        getgenv().UI = nil
    end)
    
    -- Show version info
    UI:Label("DRAXUI Version: " .. DRAXUI.GetVersion())
    
    -- Add a notification example
    UI:Button("Show Notification", function()
        UI:Notification("DRAXUI Notification", "This is an example notification from the exploit script!", "Success")
    end)

-- Connect the UI to start rendering
UI:Connect()

-- Send a welcome notification
UI:Notification("DRAXUI Loaded", "Welcome to DRAXUI Exploit Example!", "Info")

-- Print instructions to console
print("DRAXUI Exploit Example loaded successfully!")
print("Press RightShift to toggle the UI visibility")
