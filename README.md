# DRAXUI Library for Roblox

![DRAXUI Banner](https://raw.githubusercontent.com/DRAXOSERVICES/DRAXUI/refs/heads/main/banner.svg)

## Overview

DRAXUI is an enhanced Roblox UI Library inspired by ImGui and Rayfield, designed to create beautiful, responsive, and feature-rich user interfaces for your Roblox games and exploit scripts with minimal effort. The library follows an immediate-mode GUI paradigm, making it intuitive and easy to use.

## Features

- **Immediate-mode GUI**: Simple and intuitive API inspired by ImGui
- **Responsive Design**: Automatically adapts to different screen sizes
- **Animated Particles**: Beautiful background particle effects with pulsing and varied colors
- **Customizable Themes**: Easily change colors with preset themes (Dark, Light, Neon)
- **Visual Enhancements**:
  - Gradient backgrounds for UI elements
  - Drop shadows for depth effect
  - Ripple effects for interactive elements
  - Watermark display with customization
  - Blur effect for improved focus
- **Sound Effects**: Customizable sounds for interactions
- **Rich Component Library**:
  - Windows with draggable title bars, minimize and close buttons
  - Tabs for organized content
  - Buttons with hover effects and ripple animations
  - Toggles for boolean settings
  - Dropdowns for selection menus
  - Sliders for numeric input
  - Keybinds for custom shortcuts
  - Text Labels for displaying information
  - Separators for visual organization
  - Tooltips for additional information
  - Notifications for temporary messages
  - Color Picker for selecting colors
  - Progress Bars for displaying progress
  - InputBox for text entry with validation
  - Accordion for collapsible sections
  - GridLayout for organizing elements in columns
  - SearchBar with dynamic filtering

## Installation

### Method 1: Roblox Studio

1. Download the `UI.lua` file
2. In Roblox Studio, insert a ModuleScript into ReplicatedStorage
3. Name it "DRAXUI" or your preferred name
4. Copy and paste the contents of `UI.lua` into the ModuleScript

### Method 2: Roblox Model

1. Import the DRAXUI model from the Roblox Toolbox
2. Place it in ReplicatedStorage

### Method 3: Exploit Scripts (Xeno, AWP, Synapse X, etc.)

1. Host the `UI.lua` file on GitHub or another raw file hosting service
2. Use loadstring to load the library directly in your exploit script:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/DRAXOSERVICES/DRAXUI/main/UI.lua'))()

-- The library automatically initializes and creates a global UI variable
-- You can access it directly as 'UI'

-- Create a window
UI:Window("My Exploit GUI")

-- Add components
UI:Tab("Main")
UI:Button("Click Me", function()
    print("Button clicked!")
end)

-- Connect to start rendering
UI:Connect()
```

## Quick Start

```lua
-- Require the module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DRAXUI = require(ReplicatedStorage.DRAXUI)

-- Initialize the UI
local UI = DRAXUI.Init()

-- Create a simple UI
UI:Connect(function()
    DRAXUI.Window("My First Window")
    
    DRAXUI.Tab("General")
    
    if DRAXUI.Button("Click Me") then
        print("Button clicked!")
    end
    
    local toggleValue = DRAXUI.Toggle("Enable Feature", false)
    if toggleValue then
        -- Feature is enabled
    end
    
    local sliderValue = DRAXUI.Slider("Speed", 0, 100, 50)
    -- Use sliderValue in your game logic
    
    DRAXUI.End()
end)
```

## Customization

You can customize the appearance of DRAXUI by passing a settings table when initializing:

```lua
local UI = DRAXUI.Init(nil, {
    Theme = {
        PrimaryColor = Color3.fromRGB(255, 0, 0),  -- Red theme
        SecondaryColor = Color3.fromRGB(40, 40, 40),
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(70, 70, 70),
        WindowTransparency = 0.95,
        AnimationSpeed = 0.2,
        CornerRadius = 10,
    },
    Font = Enum.Font.GothamBold,
    FontSize = 14,
})
```

## Executor Compatibility

DRAXUI now includes built-in support for various Roblox executors, making it ideal for creating exploit GUIs:

### Features

- **Automatic Executor Detection**: Identifies the current executor environment (Synapse X, KRNL, Xeno, AWP, ScriptWare, etc.)
- **Protected GUI Handling**: Automatically uses the appropriate method to protect your UI from detection
- **Global Instance**: When loaded via loadstring, creates a global `UI` variable for easy access
- **ExecutorInfo Property**: Access information about the current execution environment

```lua
-- Check if running in an exploit environment
if UI.ExecutorInfo.IsExploit then
    print("Running in " .. UI.ExecutorInfo.Executor)
end
```

## API Reference

### Core Functions

- `DRAXUI.Init([parent], [settings])` - Initialize the UI library
- `DRAXUI:Connect(renderFunction)` - Connect a function to render the UI
- `DRAXUI.Window(name, [options])` - Create a window
- `DRAXUI.Tab(name)` - Create a tab in the current window
- `DRAXUI.End()` - End the current window
- `DRAXUI.GetVersion()` - Returns the current version of DRAXUI

### Components

- `DRAXUI.Button(name)` - Create a button, returns true when clicked
- `DRAXUI.Toggle(name, default)` - Create a toggle, returns current state
- `DRAXUI.Dropdown(name, options, default)` - Create a dropdown, returns selected option
- `DRAXUI.Slider(name, min, max, default)` - Create a slider, returns current value
- `DRAXUI.Keybind(name, defaultKey, callback)` - Create a keybind, returns current key

## Examples

### Creating a Settings Menu

```lua
UI:Connect(function()
    DRAXUI.Window("Settings")
    
    DRAXUI.Tab("Video")
    local quality = DRAXUI.Dropdown("Quality", {"Low", "Medium", "High"}, "Medium")
    local fullscreen = DRAXUI.Toggle("Fullscreen", false)
    local brightness = DRAXUI.Slider("Brightness", 0, 100, 70)
    
    DRAXUI.Tab("Audio")
    local volume = DRAXUI.Slider("Master Volume", 0, 100, 80)
    local sfxVolume = DRAXUI.Slider("SFX Volume", 0, 100, 90)
    local musicVolume = DRAXUI.Slider("Music Volume", 0, 100, 70)
    local muteAudio = DRAXUI.Toggle("Mute All", false)
    
    DRAXUI.Tab("Controls")
    DRAXUI.Keybind("Jump", Enum.KeyCode.Space, function()
        -- Handle jump action
    end)
    
    DRAXUI.End()
end)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

DRAXUI is developed and maintained by DRAXO.dev. Inspired by ImGui and Rayfield UI libraries.
