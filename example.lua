-- Example usage of DRAXUI Library
-- This example creates a complete settings menu for a game

-- Require the module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DRAXUI = require(ReplicatedStorage.DRAXUI) -- Adjust path as needed

-- Game settings (would normally be saved/loaded from DataStore)
local GameSettings = {
    -- Video settings
    Quality = "Medium",
    Fullscreen = false,
    Brightness = 70,
    ShowFPS = true,
    
    -- Audio settings
    MasterVolume = 80,
    SFXVolume = 90,
    MusicVolume = 70,
    MuteAll = false,
    
    -- Gameplay settings
    Sensitivity = 50,
    InvertY = false,
    AutoSprint = true,
    
    -- Keybinds
    JumpKey = Enum.KeyCode.Space,
    SprintKey = Enum.KeyCode.LeftShift,
    CrouchKey = Enum.KeyCode.LeftControl,
    InteractKey = Enum.KeyCode.E,
}

-- Initialize the UI with custom theme
local UI = DRAXUI.Init(nil, {
    Theme = {
        PrimaryColor = Color3.fromRGB(0, 120, 215),  -- Blue theme
        SecondaryColor = Color3.fromRGB(40, 40, 40),
        BackgroundColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(60, 60, 60),
        WindowTransparency = 0.95,
        AnimationSpeed = 0.2,
        CornerRadius = 8,
    },
    Font = Enum.Font.GothamSemibold,
    FontSize = 14,
})

-- Function to apply settings
local function ApplySettings()
    -- This would normally update game settings
    print("Applying settings:")
    for setting, value in pairs(GameSettings) do
        print("  " .. setting .. ": " .. tostring(value))
    end
    
    -- Example of how you might apply some settings
    if GameSettings.MuteAll then
        -- Mute all sounds
        game:GetService("SoundService").Volume = 0
    else
        -- Apply volume settings
        game:GetService("SoundService").Volume = GameSettings.MasterVolume / 100
    end
    
    -- You would add more code here to apply other settings
 end

-- Create the UI
UI:Connect(function()
    -- Main settings window
    DRAXUI.Window("Game Settings", {position = UDim2.new(0.5, -250, 0.5, -300), size = Vector2.new(500, 600)})
    
    -- Video Settings Tab
    DRAXUI.Tab("Video")
    
    GameSettings.Quality = DRAXUI.Dropdown("Quality", {"Low", "Medium", "High", "Ultra"}, GameSettings.Quality)
    GameSettings.Fullscreen = DRAXUI.Toggle("Fullscreen", GameSettings.Fullscreen)
    GameSettings.Brightness = DRAXUI.Slider("Brightness", 0, 100, GameSettings.Brightness)
    GameSettings.ShowFPS = DRAXUI.Toggle("Show FPS Counter", GameSettings.ShowFPS)
    
    if DRAXUI.Button("Apply Video Settings") then
        ApplySettings()
    end
    
    -- Audio Settings Tab
    DRAXUI.Tab("Audio")
    
    GameSettings.MasterVolume = DRAXUI.Slider("Master Volume", 0, 100, GameSettings.MasterVolume)
    GameSettings.SFXVolume = DRAXUI.Slider("SFX Volume", 0, 100, GameSettings.SFXVolume)
    GameSettings.MusicVolume = DRAXUI.Slider("Music Volume", 0, 100, GameSettings.MusicVolume)
    GameSettings.MuteAll = DRAXUI.Toggle("Mute All", GameSettings.MuteAll)
    
    if DRAXUI.Button("Apply Audio Settings") then
        ApplySettings()
    end
    
    -- Gameplay Settings Tab
    DRAXUI.Tab("Gameplay")
    
    GameSettings.Sensitivity = DRAXUI.Slider("Mouse Sensitivity", 1, 100, GameSettings.Sensitivity)
    GameSettings.InvertY = DRAXUI.Toggle("Invert Y-Axis", GameSettings.InvertY)
    GameSettings.AutoSprint = DRAXUI.Toggle("Auto Sprint", GameSettings.AutoSprint)
    
    if DRAXUI.Button("Apply Gameplay Settings") then
        ApplySettings()
    end
    
    -- Controls Tab
    DRAXUI.Tab("Controls")
    
    GameSettings.JumpKey = DRAXUI.Keybind("Jump", GameSettings.JumpKey, function()
        -- This would normally trigger the jump action
        print("Jump key pressed!")
    end)
    
    GameSettings.SprintKey = DRAXUI.Keybind("Sprint", GameSettings.SprintKey, function()
        -- This would normally trigger the sprint action
        print("Sprint key pressed!")
    end)
    
    GameSettings.CrouchKey = DRAXUI.Keybind("Crouch", GameSettings.CrouchKey, function()
        -- This would normally trigger the crouch action
        print("Crouch key pressed!")
    end)
    
    GameSettings.InteractKey = DRAXUI.Keybind("Interact", GameSettings.InteractKey, function()
        -- This would normally trigger the interact action
        print("Interact key pressed!")
    end)
    
    if DRAXUI.Button("Reset to Default Controls") then
        GameSettings.JumpKey = Enum.KeyCode.Space
        GameSettings.SprintKey = Enum.KeyCode.LeftShift
        GameSettings.CrouchKey = Enum.KeyCode.LeftControl
        GameSettings.InteractKey = Enum.KeyCode.E
    end
    
    -- Apply All Button at the bottom of each tab
    if DRAXUI.Button("Apply All Settings") then
        ApplySettings()
    end
    
    DRAXUI.End()
end)

-- You can also create additional windows
UI:Connect(function()
    DRAXUI.Window("Help", {position = UDim2.new(0.8, 0, 0.5, -150), size = Vector2.new(300, 300)})
    
    DRAXUI.Tab("Controls")
    
    -- Just display some help text
    -- Note: This is just for demonstration, DRAXUI doesn't have a text component yet
    -- You would need to implement this with TextLabels
    
    if DRAXUI.Button("Visit Wiki") then
        -- This would normally open a link or show more help
        print("Opening wiki...")
    end
    
    if DRAXUI.Button("Report Bug") then
        -- This would normally open a bug report form
        print("Opening bug report...")
    end
    
    DRAXUI.End()
end)

-- Example of how to toggle the UI visibility with a key
local UserInputService = game:GetService("UserInputService")
local isUIVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        isUIVisible = not isUIVisible
        UI.ScreenGui.Enabled = isUIVisible
    end
end)

print("DRAXUI Example loaded! Press F1 to toggle UI visibility.")