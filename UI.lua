-- DRAXUI: Enhanced Roblox UI Library inspired by ImGui and Rayfield
-- Version: 1.1.0
-- Features: Immediate-mode GUI, tabs, custom fonts, particle effects, sliders, keybinds, and more
-- Usage: local DRAXUI = require(path.to.DRAXUI).Init()
--
-- Compatible with multiple Roblox executors (Xeno, AWP, Synapse X, etc.)
-- For exploit scripts usage: loadstring(game:HttpGet('https://raw.githubusercontent.com/yourusername/DRAXUI/main/UI.lua'))()
--
-- GitHub: https://github.com/yourusername/DRAXUI
-- Documentation: See README.md for full documentation and examples

-- Detect executor environment
local executorDetected = "Unknown"
local isExploitEnvironment = false

-- Check for common exploit globals
if getgenv or syn or KRNL_LOADED or XENO_LOADED or is_sirhurt_closure or PROTOSMASHER_LOADED then
    isExploitEnvironment = true
    
    -- Detect specific executors
    if getgenv and getgenv().executor then
        executorDetected = getgenv().executor
    elseif XENO_LOADED then
        executorDetected = "Xeno"
    elseif KRNL_LOADED then
        executorDetected = "KRNL"
    elseif syn and syn.protect_gui then
        executorDetected = "Synapse X"
    elseif secure_load then
        executorDetected = "Sentinel"
    elseif is_sirhurt_closure then
        executorDetected = "SirHurt"
    elseif PROTOSMASHER_LOADED then
        executorDetected = "ProtoSmasher"
    elseif Shadow_Check then
        executorDetected = "Shadow"
    elseif getexecutorname then
        executorDetected = getexecutorname()
    end
    
    print("DRAXUI: Running in exploit environment - " .. executorDetected)
end

-- Safe service access function
local function GetService(serviceName)
    return game:GetService(serviceName)
end

local UserInputService = GetService("UserInputService")
local TweenService = GetService("TweenService")
local RunService = GetService("RunService")
local Players = GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DRAXUI = {}
DRAXUI.__index = DRAXUI

-- Version info
DRAXUI.Version = "1.1.0"
DRAXUI.ExecutorInfo = {
    IsExploit = isExploitEnvironment,
    Executor = executorDetected
}

-- Configuration
local Config = {
    Theme = {
        PrimaryColor = Color3.fromRGB(30, 144, 255),
        SecondaryColor = Color3.fromRGB(50, 50, 50),
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(80, 80, 80),
        ErrorColor = Color3.fromRGB(255, 0, 0),
        SuccessColor = Color3.fromRGB(0, 255, 0),
        WarningColor = Color3.fromRGB(255, 255, 0),
        InfoColor = Color3.fromRGB(0, 191, 255),
        GradientStart = Color3.fromRGB(30, 144, 255),
        GradientEnd = Color3.fromRGB(70, 73, 240),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        WindowTransparency = 0.9,
        AnimationSpeed = 0.15,
        CornerRadius = 8,
        ButtonHoverBrightness = 0.1,
        ElementSpacing = 10,
    },
    DefaultWindowSize = Vector2.new(400, 500),
    DefaultFont = Enum.Font.GothamSemibold,  -- More modern font
    FontSize = 14,
    ParticleCount = 30,  -- More particles for better effect
    ParticleSpeed = 0.5,
    TooltipDelay = 0.5,
    NotificationDuration = 3,
    WatermarkText = "DRAXUI",
    WatermarkTransparency = 0.7,
    EnableSounds = true,
    EnableAnimations = true,
    EnableBlur = true,
    BlurSize = 10,
    RippleEffectEnabled = true,
    DropShadowEnabled = true,
}

-- Internal state
local State = {
    Windows = {},
    CurrentWindow = nil,
    CurrentTab = nil,
    ZIndex = 100,
    Keybinds = {},
    Tooltips = {},
    Notifications = {},
    DraggingWindow = nil,
    DragOffset = Vector2.new(0, 0),
    LastHoveredElement = nil,
    TooltipTimer = 0,
    MousePosition = Vector2.new(0, 0),
    Sounds = {},
    Watermark = nil,
    Blur = nil,
    ActiveRipples = {},
    DropShadows = {},
    InputBoxes = {},
    Accordions = {},
    GridLayouts = {},
    SearchResults = {},
    ThemePresets = {
        Dark = {
            PrimaryColor = Color3.fromRGB(30, 144, 255),
            BackgroundColor = Color3.fromRGB(20, 20, 20),
            SecondaryColor = Color3.fromRGB(50, 50, 50),
            TextColor = Color3.fromRGB(255, 255, 255),
            AccentColor = Color3.fromRGB(80, 80, 80),
        },
        Light = {
            PrimaryColor = Color3.fromRGB(0, 120, 215),
            BackgroundColor = Color3.fromRGB(240, 240, 240),
            SecondaryColor = Color3.fromRGB(200, 200, 200),
            TextColor = Color3.fromRGB(0, 0, 0),
            AccentColor = Color3.fromRGB(160, 160, 160),
        },
        Neon = {
            PrimaryColor = Color3.fromRGB(0, 255, 157),
            BackgroundColor = Color3.fromRGB(10, 10, 10),
            SecondaryColor = Color3.fromRGB(30, 30, 30),
            TextColor = Color3.fromRGB(255, 255, 255),
            AccentColor = Color3.fromRGB(50, 50, 50),
            GradientStart = Color3.fromRGB(0, 255, 157),
            GradientEnd = Color3.fromRGB(0, 183, 255),
        },
    },
}

-- Helper function to create UI elements
local function CreateUIElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

-- Helper function to create a gradient
local function CreateGradient(parent, startColor, endColor, rotation)
    local gradient = CreateUIElement("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor),
            ColorSequenceKeypoint.new(1, endColor)
        }),
        Rotation = rotation or 90,
    })
    return gradient
end

-- Helper function to create a drop shadow
local function CreateDropShadow(parent, size, position, transparency)
    if not Config.DropShadowEnabled then return nil end
    
    local shadow = CreateUIElement("Frame", {
        Parent = parent.Parent,
        Size = UDim2.new(size.X.Scale, size.X.Offset + 10, size.Y.Scale, size.Y.Offset + 10),
        Position = UDim2.new(position.X.Scale, position.X.Offset - 5, position.Y.Scale, position.Y.Offset - 5),
        BackgroundColor3 = Config.Theme.ShadowColor,
        BackgroundTransparency = transparency or 0.7,
        BorderSizePixel = 0,
        ZIndex = parent.ZIndex - 1,
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = shadow,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius + 2),
    })
    
    -- Keep shadow in sync with parent
    local connection = RunService.RenderStepped:Connect(function()
        if parent and parent.Parent then
            shadow.Position = UDim2.new(
                parent.Position.X.Scale, parent.Position.X.Offset - 5,
                parent.Position.Y.Scale, parent.Position.Y.Offset - 5
            )
        else
            shadow:Destroy()
            connection:Disconnect()
        end
    end)
    
    table.insert(State.DropShadows, {Shadow = shadow, Connection = connection})
    return shadow
end

-- Helper function to create a ripple effect
local function CreateRippleEffect(parent, inputPosition)
    if not Config.RippleEffectEnabled then return end
    
    local parentAbsoluteSize = parent.AbsoluteSize
    local parentAbsolutePosition = parent.AbsolutePosition
    
    local ripple = CreateUIElement("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, inputPosition.X - parentAbsolutePosition.X, 0, inputPosition.Y - parentAbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = parent.ZIndex + 1,
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = ripple,
        CornerRadius = UDim.new(1, 0),
    })
    
    local maxSize = math.max(parentAbsoluteSize.X, parentAbsoluteSize.Y) * 2
    local rippleTween = CreateTween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5)
    
    rippleTween.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    table.insert(State.ActiveRipples, ripple)
    return ripple
end

-- Helper function to play a sound
local function PlaySound(soundType)
    if not Config.EnableSounds then return end
    
    local soundId
    if soundType == "Click" then
        soundId = "rbxassetid://6333717580"
    elseif soundType == "Hover" then
        soundId = "rbxassetid://6333716356"
    elseif soundType == "Toggle" then
        soundId = "rbxassetid://6333716942"
    elseif soundType == "Notification" then
        soundId = "rbxassetid://6518811702"
    elseif soundType == "Error" then
        soundId = "rbxassetid://6518812078"
    else
        return
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    return sound
end

-- Tween helper for animations
local function CreateTween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Initialize DRAXUI
function DRAXUI.Init(parent, settings)
    local self = setmetatable({}, DRAXUI)
    
    -- Create ScreenGui
    self.ScreenGui = CreateUIElement("ScreenGui", {
        Name = "DRAXUI_" .. math.random(100000, 999999), -- Random name to avoid detection
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999, -- Ensure UI is on top
    })
    
    -- Handle different executor environments for GUI protection
    if isExploitEnvironment then
        -- Determine parent based on executor
        if not parent then
            -- Default parent handling for exploits
            if executorDetected == "Synapse X" and syn and syn.protect_gui then
                -- Synapse X protection
                syn.protect_gui(self.ScreenGui)
                self.ScreenGui.Parent = game:GetService("CoreGui")
            elseif executorDetected == "Krnl" and KRNL_LOADED and get_hidden_gui then
                -- KRNL protection
                self.ScreenGui.Parent = get_hidden_gui()
            elseif executorDetected == "Xeno" and XENO_LOADED then
                -- Xeno protection
                self.ScreenGui.Parent = game:GetService("CoreGui")
            elseif executorDetected == "ScriptWare" and identifyexecutor and identifyexecutor() == "ScriptWare" then
                -- ScriptWare protection
                self.ScreenGui.Parent = game:GetService("CoreGui")
            else
                -- Fallback for other executors - try CoreGui first, then PlayerGui
                local success, err = pcall(function()
                    self.ScreenGui.Parent = game:GetService("CoreGui")
                end)
                
                if not success then
                    self.ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    warn("DRAXUI: Failed to parent to CoreGui, using PlayerGui instead. Error: " .. tostring(err))
                end
            end
        else
            -- Use specified parent if provided
            self.ScreenGui.Parent = parent
        end
    else
        -- Normal Roblox environment
        self.ScreenGui.Parent = parent or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    self.Connections = {}
    
    -- Apply custom settings
    if settings then
        -- Deep merge settings with Config
        for key, value in pairs(settings) do
            if key == "Theme" and type(value) == "table" then
                for themeKey, themeValue in pairs(value) do
                    Config.Theme[themeKey] = themeValue
                end
            else
                Config[key] = value
            end
        end
    end
    
    -- Create blur effect if enabled
    if Config.EnableBlur then
        State.Blur = CreateUIElement("BlurEffect", {
            Parent = game:GetService("Lighting"),
            Size = 0,
        })
        
        -- Animate blur in
        CreateTween(State.Blur, {Size = Config.BlurSize}, Config.Theme.AnimationSpeed * 2)
    end
    
    -- Create watermark
    if Config.WatermarkText and Config.WatermarkText ~= "" then
        State.Watermark = CreateUIElement("TextLabel", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, 150, 0, 30),
            Position = UDim2.new(1, -160, 0, 10),
            BackgroundColor3 = Config.Theme.BackgroundColor,
            BackgroundTransparency = Config.WatermarkTransparency,
            Text = Config.WatermarkText .. " v" .. DRAXUI.Version,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Center,
            BorderSizePixel = 0,
            ZIndex = 9999,
        })
        
        local corner = CreateUIElement("UICorner", {
            Parent = State.Watermark,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        -- Add gradient to watermark
        CreateGradient(
            State.Watermark, 
            Config.Theme.GradientStart or Config.Theme.PrimaryColor, 
            Config.Theme.GradientEnd or Config.Theme.PrimaryColor:Lerp(Color3.new(1, 1, 1), 0.2),
            45
        )
        
        -- Add shadow to watermark
        if Config.DropShadowEnabled then
            CreateDropShadow(State.Watermark, State.Watermark.Size, State.Watermark.Position, 0.8)
        end
        
        -- Animate watermark in
        State.Watermark.Position = UDim2.new(1, 0, 0, 10)
        CreateTween(State.Watermark, {Position = UDim2.new(1, -160, 0, 10)}, Config.Theme.AnimationSpeed)
    end
    
    -- Create particle background with improved visuals
    self.Particles = {}
    for i = 1, Config.ParticleCount do
        local size = math.random(3, 7) -- Varied sizes
        local particle = CreateUIElement("Frame", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = Config.Theme.PrimaryColor:Lerp(Color3.new(1, 1, 1), math.random() * 0.3), -- Varied colors
            BackgroundTransparency = 0.7 + (math.random() * 0.2), -- Varied transparency
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        
        local corner = CreateUIElement("UICorner", {
            Parent = particle,
            CornerRadius = UDim.new(1, 0), -- Perfect circle
        })
        
        -- Add glow effect to some particles
        if math.random() > 0.7 then
            local glow = CreateUIElement("UIStroke", {
                Parent = particle,
                Color = Config.Theme.PrimaryColor,
                Transparency = 0.5,
                Thickness = 1,
            })
        end
        
        self.Particles[i] = {
            Frame = particle, 
            Velocity = Vector2.new(math.random(-10, 10) / 10 * Config.ParticleSpeed, math.random(-10, 10) / 10 * Config.ParticleSpeed),
            Size = size,
            OriginalSize = size,
            PulseDirection = math.random() > 0.5 and 1 or -1,
            PulseSpeed = math.random(5, 15) / 10,
        }
    end
    
    -- Animate particles with improved effects
    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt)
        for _, particle in ipairs(self.Particles) do
            -- Move particle
            local pos = particle.Frame.Position
            local newX = pos.X.Scale + particle.Velocity.X * dt
            local newY = pos.Y.Scale + particle.Velocity.Y * dt
            
            -- Bounce off edges
            if newX > 1 or newX < 0 then 
                particle.Velocity.X = -particle.Velocity.X 
                -- Slightly change velocity on bounce for more natural movement
                particle.Velocity.X = particle.Velocity.X * (0.9 + math.random() * 0.2)
            end
            if newY > 1 or newY < 0 then 
                particle.Velocity.Y = -particle.Velocity.Y 
                particle.Velocity.Y = particle.Velocity.Y * (0.9 + math.random() * 0.2)
            end
            
            particle.Frame.Position = UDim2.new(newX, 0, newY, 0)
            
            -- Pulse size effect for some particles
            if Config.EnableAnimations and math.random() > 0.95 then
                particle.Size = particle.Size + (particle.PulseDirection * particle.PulseSpeed * dt)
                
                -- Reverse direction if size gets too big or small
                if particle.Size > particle.OriginalSize * 1.5 or particle.Size < particle.OriginalSize * 0.7 then
                    particle.PulseDirection = -particle.PulseDirection
                end
                
                particle.Frame.Size = UDim2.new(0, particle.Size, 0, particle.Size)
            end
        end
    end))
    
    -- Track mouse position for effects
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            State.MousePosition = input.Position
        end
    end))
    
    -- Play initialization sound
    PlaySound("Notification")
    
    return self
end

-- Connect to RenderStepped for immediate-mode rendering
function DRAXUI:Connect(renderFunction)
    local connection = RunService.RenderStepped:Connect(function()
        State.ZIndex = 100
        State.CurrentWindow = nil
        State.CurrentTab = nil
        renderFunction()
    end)
    table.insert(self.Connections, connection)
end

-- Create a window
function DRAXUI.Window(name, options)
    options = options or {}
    local windowState = State.Windows[name] or {
        Position = options.position or UDim2.new(0, 100, 0, 100),
        Size = options.size or Config.DefaultWindowSize,
        IsOpen = true,
        Tabs = {},
        Elements = {},
        Theme = options.theme or "Default",
    }
    State.Windows[name] = windowState

    if not windowState.IsOpen then
        return
    end

    -- Apply theme preset if specified
    local currentTheme = Config.Theme
    if windowState.Theme ~= "Default" and State.ThemePresets[windowState.Theme] then
        for key, value in pairs(State.ThemePresets[windowState.Theme]) do
            currentTheme[key] = value
        end
    end

    State.CurrentWindow = name
    local frame = windowState.Frame
    if not frame then
        -- Create window with drop shadow if enabled
        frame = CreateUIElement("Frame", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, windowState.Size.X, 0, windowState.Size.Y),
            Position = windowState.Position,
            BackgroundColor3 = currentTheme.BackgroundColor,
            BackgroundTransparency = Config.Theme.WindowTransparency,
            BorderSizePixel = 0,
            ZIndex = State.ZIndex,
            ClipsDescendants = true, -- For ripple effects
        })
        
        -- Add rounded corners
        local corner = CreateUIElement("UICorner", {
            Parent = frame,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        -- Add drop shadow
        if Config.DropShadowEnabled then
            CreateDropShadow(frame, frame.Size, frame.Position)
        end
        
        -- Create title bar with gradient
        local titleBar = CreateUIElement("Frame", {
            Parent = frame,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = currentTheme.PrimaryColor,
            BorderSizePixel = 0,
            ZIndex = State.ZIndex + 1,
        })
        
        -- Add rounded corners to title bar
        local titleCorner = CreateUIElement("UICorner", {
            Parent = titleBar,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        -- Add gradient to title bar
        CreateGradient(
            titleBar, 
            currentTheme.GradientStart or currentTheme.PrimaryColor, 
            currentTheme.GradientEnd or currentTheme.PrimaryColor:Lerp(Color3.new(1, 1, 1), 0.2),
            45
        )
        
        -- Add title text
        local titleText = CreateUIElement("TextLabel", {
            Parent = titleBar,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = currentTheme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = State.ZIndex + 2,
        })
        
        -- Add window controls (close, minimize, etc.)
        local closeButton = CreateUIElement("TextButton", {
            Parent = titleBar,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0, 5),
            BackgroundColor3 = Color3.fromRGB(255, 70, 70),
            Text = "",
            ZIndex = State.ZIndex + 2,
        })
        
        local closeCorner = CreateUIElement("UICorner", {
            Parent = closeButton,
            CornerRadius = UDim.new(1, 0),
        })
        
        local minimizeButton = CreateUIElement("TextButton", {
            Parent = titleBar,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -50, 0, 5),
            BackgroundColor3 = Color3.fromRGB(255, 200, 50),
            Text = "",
            ZIndex = State.ZIndex + 2,
        })
        
        local minimizeCorner = CreateUIElement("UICorner", {
            Parent = minimizeButton,
            CornerRadius = UDim.new(1, 0),
        })
        
        -- Make window draggable
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                State.DraggingWindow = name
                State.DragOffset = frame.Position - UDim2.new(0, input.Position.X, 0, input.Position.Y)
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and State.DraggingWindow == name then
                State.DraggingWindow = nil
            end
        end)
        
        -- Handle window dragging
        table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and State.DraggingWindow == name then
                frame.Position = State.DragOffset + UDim2.new(0, input.Position.X, 0, input.Position.Y)
                windowState.Position = frame.Position
            end
        end))
        
        -- Handle close button
        closeButton.MouseButton1Click:Connect(function()
            PlaySound("Click")
            CreateRippleEffect(closeButton, State.MousePosition)
            windowState.IsOpen = false
            CreateTween(frame, {Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, 1.5, 0)}, Config.Theme.AnimationSpeed).Completed:Connect(function()
                frame.Visible = false
            end)
        end)
        
        -- Handle minimize button
        minimizeButton.MouseButton1Click:Connect(function()
            PlaySound("Click")
            CreateRippleEffect(minimizeButton, State.MousePosition)
            if frame.Size.Y.Offset > 30 then
                -- Store original size and minimize
                windowState.OriginalSize = frame.Size
                CreateTween(frame, {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 30)}, Config.Theme.AnimationSpeed)
            else
                -- Restore original size
                CreateTween(frame, {Size = windowState.OriginalSize}, Config.Theme.AnimationSpeed)
            end
        end)
        
        -- Add hover effects to buttons
        closeButton.MouseEnter:Connect(function()
            PlaySound("Hover")
            CreateTween(closeButton, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -26, 0, 4)}, Config.Theme.AnimationSpeed / 2)
        end)
        
        closeButton.MouseLeave:Connect(function()
            CreateTween(closeButton, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0, 5)}, Config.Theme.AnimationSpeed / 2)
        end)
        
        minimizeButton.MouseEnter:Connect(function()
            PlaySound("Hover")
            CreateTween(minimizeButton, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -51, 0, 4)}, Config.Theme.AnimationSpeed / 2)
        end)
        
        minimizeButton.MouseLeave:Connect(function()
            CreateTween(minimizeButton, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -50, 0, 5)}, Config.Theme.AnimationSpeed / 2)
        end)
        
        -- Store references
        windowState.Frame = frame
        windowState.TitleBar = titleBar
        windowState.CloseButton = closeButton
        windowState.MinimizeButton = minimizeButton
        windowState.NextY = 70 -- Space for tabs
        
        -- Animate window in
        frame.Position = UDim2.new(windowState.Position.X.Scale, windowState.Position.X.Offset, -0.5, 0)
        CreateTween(frame, {Position = windowState.Position}, Config.Theme.AnimationSpeed)
    end
    
    frame.ZIndex = State.ZIndex
    State.ZIndex = State.ZIndex + 10
end

-- Create a tab
function DRAXUI.Tab(name)
    if not State.CurrentWindow then return end
    local windowState = State.Windows[State.CurrentWindow]
    local tabId = name .. "_Tab"
    windowState.Tabs[tabId] = windowState.Tabs[tabId] or {
        IsActive = windowState.Tabs[tabId] and windowState.Tabs[tabId].IsActive or false,
        Elements = {},
        NextY = 70,
    }
    
    if not windowState.TabBar then
        windowState.TabBar = CreateUIElement("Frame", {
            Parent = windowState.Frame,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Config.Theme.SecondaryColor,
            BorderSizePixel = 0,
            ZIndex = windowState.Frame.ZIndex + 1,
        })
        windowState.TabLayout = CreateUIElement("UIListLayout", {
            Parent = windowState.TabBar,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
    end
    
    local tabButton = windowState.Tabs[tabId].Button
    if not tabButton then
        tabButton = CreateUIElement("TextButton", {
            Parent = windowState.TabBar,
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = windowState.Tabs[tabId].IsActive and Config.Theme.PrimaryColor or Config.Theme.AccentColor,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            ZIndex = windowState.TabBar.ZIndex,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = tabButton,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        windowState.Tabs[tabId].Button = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            for id, tab in pairs(windowState.Tabs) do
                tab.IsActive = (id == tabId)
                tab.Button.BackgroundColor3 = tab.IsActive and Config.Theme.PrimaryColor or Config.Theme.AccentColor
                if tab.Frame then
                    tab.Frame.Visible = tab.IsActive
                end
            end
        end)
    end
    
    if windowState.Tabs[tabId].IsActive then
        State.CurrentTab = tabId
        local tabFrame = windowState.Tabs[tabId].Frame
        if not tabFrame then
            tabFrame = CreateUIElement("Frame", {
                Parent = windowState.Frame,
                Size = UDim2.new(1, 0, 1, -70),
                Position = UDim2.new(0, 0, 0, 70),
                BackgroundTransparency = 1,
                ZIndex = windowState.Frame.ZIndex,
            })
            windowState.Tabs[tabId].Frame = tabFrame
        end
        tabFrame.Visible = true
    else
        if windowState.Tabs[tabId].Frame then
            windowState.Tabs[tabId].Frame.Visible = false
        end
    end
end

-- End the current window
function DRAXUI.End()
    State.CurrentWindow = nil
    State.CurrentTab = nil
end

-- Create a button
function DRAXUI.Button(name, options)
    if not State.CurrentWindow or not State.CurrentTab then return false end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local buttonId = name .. "_Button"
    local button = tabState.Elements[buttonId]
    
    if not button then
        button = CreateUIElement("TextButton", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundColor3 = Config.Theme.AccentColor,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = button,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        tabState.Elements[buttonId] = button
        tabState.NextY = tabState.NextY + 40
        
        button.MouseEnter:Connect(function()
            CreateTween(button, {BackgroundColor3 = Config.Theme.PrimaryColor}, Config.Theme.AnimationSpeed)
        end)
        button.MouseLeave:Connect(function()
            CreateTween(button, {BackgroundColor3 = Config.Theme.AccentColor}, Config.Theme.AnimationSpeed)
        end)
    end
    
    local clicked = false
    if button.MouseButton1Click then
        local connection
        connection = button.MouseButton1Click:Connect(function()
            clicked = true
            connection:Disconnect()
        end)
    end
    return clicked
end

-- Create a toggle
function DRAXUI.Toggle(name, default, options)
    if not State.CurrentWindow or not State.CurrentTab then return default end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local toggleId = name .. "_Toggle"
    local toggleState = tabState.Elements[toggleId] and tabState.Elements[toggleId].Value or default
    
    local toggleFrame = tabState.Elements[toggleId] and tabState.Elements[toggleId].Frame
    if not toggleFrame then
        toggleFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = toggleFrame,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = toggleFrame.ZIndex,
        })
        
        local toggle = CreateUIElement("TextButton", {
            Parent = toggleFrame,
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0, 5),
            BackgroundColor3 = toggleState and Config.Theme.PrimaryColor or Config.Theme.AccentColor,
            Text = "",
            ZIndex = toggleFrame.ZIndex,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = toggle,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        tabState.Elements[toggleId] = {Frame = toggleFrame, Button = toggle, Value = toggleState}
        tabState.NextY = tabState.NextY + 40
        
        toggle.MouseButton1Click:Connect(function()
            toggleState = not toggleState
            tabState.Elements[toggleId].Value = toggleState
            CreateTween(toggle, {BackgroundColor3 = toggleState and Config.Theme.PrimaryColor or Config.Theme.AccentColor}, Config.Theme.AnimationSpeed)
        end)
    end
    
    return toggleState
end

-- Create a dropdown
function DRAXUI.Dropdown(name, options, default)
    if not State.CurrentWindow or not State.CurrentTab then return default end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local dropdownId = name .. "_Dropdown"
    local dropdownState = tabState.Elements[dropdownId] and tabState.Elements[dropdownId].Value or default
    local isOpen = tabState.Elements[dropdownId] and tabState.Elements[dropdownId].IsOpen or false
    
    local dropdownFrame = tabState.Elements[dropdownId] and tabState.Elements[dropdownId].Frame
    if not dropdownFrame then
        dropdownFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = dropdownFrame,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = dropdownFrame.ZIndex,
        })
        
        local dropdownButton = CreateUIElement("TextButton", {
            Parent = dropdownFrame,
            Size = UDim2.new(0, 100, 0, 20),
            Position = UDim2.new(1, -100, 0, 5),
            BackgroundColor3 = Config.Theme.AccentColor,
            Text = dropdownState or "Select",
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            ZIndex = dropdownFrame.ZIndex,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = dropdownButton,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local dropdownList = CreateUIElement("Frame", {
            Parent = dropdownFrame,
            Size = UDim2.new(1, 0, 0, #options * 30),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Config.Theme.BackgroundColor,
            BackgroundTransparency = Config.Theme.WindowTransparency,
            Visible = false,
            ZIndex = dropdownFrame.ZIndex + 1,
        })
        local listCorner = CreateUIElement("UICorner", {
            Parent = dropdownList,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local listLayout = CreateUIElement("UIListLayout", {
            Parent = dropdownList,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        tabState.Elements[dropdownId] = {Frame = dropdownFrame, Button = dropdownButton, List = dropdownList, Value = dropdownState, IsOpen = isOpen}
        tabState.NextY = tabState.NextY + 40
        
        dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            tabState.Elements[dropdownId].IsOpen = isOpen
            dropdownList.Visible = isOpen
            CreateTween(dropdownList, {BackgroundTransparency = isOpen and Config.Theme.WindowTransparency or 1}, Config.Theme.AnimationSpeed)
        end)
        
        for i, option in ipairs(options) do
            local optionButton = CreateUIElement("TextButton", {
                Parent = dropdownList,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Config.Theme.AccentColor,
                Text = tostring(option),
                TextColor3 = Config.Theme.TextColor,
                Font = Config.DefaultFont,
                TextSize = Config.FontSize,
                ZIndex = dropdownList.ZIndex,
            })
            local optionCorner = CreateUIElement("UICorner", {
                Parent = optionButton,
                CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
            })
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownState = option
                tabState.Elements[dropdownId].Value = dropdownState
                dropdownButton.Text = tostring(option)
                isOpen = false
                tabState.Elements[dropdownId].IsOpen = isOpen
                dropdownList.Visible = false
            end)
            
            optionButton.MouseEnter:Connect(function()
                CreateTween(optionButton, {BackgroundColor3 = Config.Theme.PrimaryColor}, Config.Theme.AnimationSpeed)
            end)
            optionButton.MouseLeave:Connect(function()
                CreateTween(optionButton, {BackgroundColor3 = Config.Theme.AccentColor}, Config.Theme.AnimationSpeed)
            end)
        end
    end
    
    return dropdownState
end

-- Create a slider
function DRAXUI.Slider(name, min, max, default, options)
    if not State.CurrentWindow or not State.CurrentTab then return default end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local sliderId = name .. "_Slider"
    local sliderState = tabState.Elements[sliderId] and tabState.Elements[sliderId].Value or default
    
    local sliderFrame = tabState.Elements[sliderId] and tabState.Elements[sliderId].Frame
    if not sliderFrame then
        sliderFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name .. ": " .. tostring(sliderState),
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = sliderFrame.ZIndex,
        })
        
        local sliderBar = CreateUIElement("Frame", {
            Parent = sliderFrame,
            Size = UDim2.new(0, 100, 0, 10),
            Position = UDim2.new(1, -100, 0, 10),
            BackgroundColor3 = Config.Theme.AccentColor,
            ZIndex = sliderFrame.ZIndex,
        })
        local barCorner = CreateUIElement("UICorner", {
            Parent = sliderBar,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local sliderKnob = CreateUIElement("Frame", {
            Parent = sliderBar,
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new((sliderState - min) / (max - min), 0, 0, 0),
            BackgroundColor3 = Config.Theme.PrimaryColor,
            ZIndex = sliderBar.ZIndex + 1,
        })
        local knobCorner = CreateUIElement("UICorner", {
            Parent = sliderKnob,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        tabState.Elements[sliderId] = {Frame = sliderFrame, Bar = sliderBar, Knob = sliderKnob, Value = sliderState, Label = label}
        tabState.NextY = tabState.NextY + 40
        
        local isDragging = false
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
            end
        end)
        
        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = input.Position.X
                local barPos = sliderBar.AbsolutePosition.X
                local barWidth = sliderBar.AbsoluteSize.X
                local t = math.clamp((mouseX - barPos) / barWidth, 0, 1)
                sliderState = min + t * (max - min)
                tabState.Elements[sliderId].Value = sliderState
                sliderKnob.Position = UDim2.new(t, 0, 0, 0)
                label.Text = name .. ": " .. string.format("%.2f", sliderState)
            end
        end)
    end
    
    return sliderState
end

-- Create a keybind
function DRAXUI.Keybind(name, defaultKey, callback)
    if not State.CurrentWindow or not State.CurrentTab then return end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local keybindId = name .. "_Keybind"
    local keybindState = tabState.Elements[keybindId] and tabState.Elements[keybindId].Key or defaultKey
    
    local keybindFrame = tabState.Elements[keybindId] and tabState.Elements[keybindId].Frame
    if not keybindFrame then
        keybindFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = keybindFrame,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = keybindFrame.ZIndex,
        })
        
        local keybindButton = CreateUIElement("TextButton", {
            Parent = keybindFrame,
            Size = UDim2.new(0, 100, 0, 20),
            Position = UDim2.new(1, -100, 0, 5),
            BackgroundColor3 = Config.Theme.AccentColor,
            Text = keybindState.Name or "None",
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            ZIndex = keybindFrame.ZIndex,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = keybindButton,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        tabState.Elements[keybindId] = {Frame = keybindFrame, Button = keybindButton, Key = keybindState}
        tabState.NextY = tabState.NextY + 40
        
        local isBinding = false
        keybindButton.MouseButton1Click:Connect(function()
            isBinding = true
            keybindButton.Text = "Press a key..."
        end)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                keybindState = input.KeyCode
                tabState.Elements[keybindId].Key = keybindState
                keybindButton.Text = keybindState.Name
                isBinding = false
                connection:Disconnect()
            end
        end)
        
        State.Keybinds[keybindId] = {Key = keybindState, Callback = callback}
    end
    
    return keybindState
end

-- Handle keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for id, keybind in pairs(State.Keybinds) do
        if input.KeyCode == keybind.Key then
            keybind.Callback()
        end
    end
end)

-- Create a text label
function DRAXUI.Label(text, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local labelId = text .. "_Label"
    options = options or {}
    
    local labelFrame = tabState.Elements[labelId] and tabState.Elements[labelId].Frame
    if not labelFrame then
        labelFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = labelFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = options.color or Config.Theme.TextColor,
            Font = options.font or Config.DefaultFont,
            TextSize = options.textSize or Config.FontSize,
            TextXAlignment = options.alignment or Enum.TextXAlignment.Left,
            TextWrapped = options.wrap or false,
            ZIndex = labelFrame.ZIndex,
        })
        
        tabState.Elements[labelId] = {Frame = labelFrame, Label = label}
        tabState.NextY = tabState.NextY + (options.height or 40)
    else
        -- Update text if it changed
        tabState.Elements[labelId].Label.Text = text
    end
end

-- Create a separator line
function DRAXUI.Separator(options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local separatorId = "Separator_" .. tabState.NextY
    options = options or {}
    
    local separatorFrame = tabState.Elements[separatorId] and tabState.Elements[separatorId].Frame
    if not separatorFrame then
        separatorFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -20, 0, 2),
            Position = UDim2.new(0, 10, 0, tabState.NextY + 10),
            BackgroundColor3 = options.color or Config.Theme.AccentColor,
            BorderSizePixel = 0,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        tabState.Elements[separatorId] = {Frame = separatorFrame}
        tabState.NextY = tabState.NextY + (options.spacing or 30)
    end
end

-- Create a tooltip
function DRAXUI.Tooltip(element, text)
    if not element then return end
    
    local tooltipId = tostring(element) .. "_Tooltip"
    State.Tooltips[tooltipId] = {
        Element = element,
        Text = text,
    }
    
    -- Show tooltip when hovering
    element.MouseEnter:Connect(function()
        State.LastHoveredElement = element
        State.TooltipTimer = tick()
    end)
    
    element.MouseLeave:Connect(function()
        if State.LastHoveredElement == element then
            State.LastHoveredElement = nil
        end
    end)
    
    -- The actual tooltip display is handled in the RenderStepped connection
end

-- Show a notification
function DRAXUI:Notification(title, message, type, duration)
    type = type or "info" -- info, success, warning, error
    duration = duration or Config.NotificationDuration
    
    local notificationColor
    if type == "success" then
        notificationColor = Config.Theme.SuccessColor
    elseif type == "warning" then
        notificationColor = Config.Theme.WarningColor
    elseif type == "error" then
        notificationColor = Config.Theme.ErrorColor
    else
        notificationColor = Config.Theme.PrimaryColor
    end
    
    local notification = CreateUIElement("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, -100),
        BackgroundColor3 = Config.Theme.BackgroundColor,
        BackgroundTransparency = Config.Theme.WindowTransparency,
        BorderSizePixel = 0,
        ZIndex = 1000, -- Always on top
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = notification,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
    })
    
    local titleBar = CreateUIElement("Frame", {
        Parent = notification,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = notificationColor,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    
    local titleCorner = CreateUIElement("UICorner", {
        Parent = titleBar,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
    })
    
    local titleText = CreateUIElement("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1002,
    })
    
    local messageText = CreateUIElement("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize - 2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1001,
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, 0, 1, -100)
    CreateTween(notification, {Position = UDim2.new(1, -320, 1, -100)}, Config.Theme.AnimationSpeed)
    
    -- Remove after duration
    delay(duration, function()
        CreateTween(notification, {Position = UDim2.new(1, 0, 1, -100)}, Config.Theme.AnimationSpeed).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
    
    return notification
end

-- Create a color picker
function DRAXUI.ColorPicker(name, default)
    if not State.CurrentWindow or not State.CurrentTab then return default end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local colorPickerId = name .. "_ColorPicker"
    local colorState = tabState.Elements[colorPickerId] and tabState.Elements[colorPickerId].Value or default or Color3.fromRGB(255, 255, 255)
    local isOpen = tabState.Elements[colorPickerId] and tabState.Elements[colorPickerId].IsOpen or false
    
    local colorFrame = tabState.Elements[colorPickerId] and tabState.Elements[colorPickerId].Frame
    if not colorFrame then
        colorFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = colorFrame,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = colorFrame.ZIndex,
        })
        
        local colorDisplay = CreateUIElement("TextButton", {
            Parent = colorFrame,
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(1, -40, 0, 5),
            BackgroundColor3 = colorState,
            Text = "",
            ZIndex = colorFrame.ZIndex,
        })
        local displayCorner = CreateUIElement("UICorner", {
            Parent = colorDisplay,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local colorPicker = CreateUIElement("Frame", {
            Parent = colorFrame,
            Size = UDim2.new(0, 200, 0, 200),
            Position = UDim2.new(1, -220, 0, 30),
            BackgroundColor3 = Config.Theme.BackgroundColor,
            BackgroundTransparency = Config.Theme.WindowTransparency,
            Visible = isOpen,
            ZIndex = colorFrame.ZIndex + 10,
        })
        local pickerCorner = CreateUIElement("UICorner", {
            Parent = colorPicker,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        -- Simple color grid (this is a basic implementation)
        local colors = {
            {255, 0, 0}, {255, 127, 0}, {255, 255, 0}, {127, 255, 0},
            {0, 255, 0}, {0, 255, 127}, {0, 255, 255}, {0, 127, 255},
            {0, 0, 255}, {127, 0, 255}, {255, 0, 255}, {255, 0, 127},
            {255, 255, 255}, {200, 200, 200}, {150, 150, 150}, {100, 100, 100},
            {50, 50, 50}, {0, 0, 0}, {255, 0, 0}, {0, 255, 0},
        }
        
        for i, rgb in ipairs(colors) do
            local row = math.ceil(i / 5)
            local col = (i - 1) % 5 + 1
            
            local colorButton = CreateUIElement("TextButton", {
                Parent = colorPicker,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(0, 10 + (col - 1) * 40, 0, 10 + (row - 1) * 40),
                BackgroundColor3 = Color3.fromRGB(rgb[1], rgb[2], rgb[3]),
                Text = "",
                ZIndex = colorPicker.ZIndex + 1,
            })
            local buttonCorner = CreateUIElement("UICorner", {
                Parent = colorButton,
                CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
            })
            
            colorButton.MouseButton1Click:Connect(function()
                colorState = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
                tabState.Elements[colorPickerId].Value = colorState
                colorDisplay.BackgroundColor3 = colorState
                isOpen = false
                colorPicker.Visible = false
            end)
        end
        
        tabState.Elements[colorPickerId] = {Frame = colorFrame, Display = colorDisplay, Picker = colorPicker, Value = colorState, IsOpen = isOpen}
        tabState.NextY = tabState.NextY + 40
        
        colorDisplay.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            tabState.Elements[colorPickerId].IsOpen = isOpen
            colorPicker.Visible = isOpen
        end)
    end
    
    return colorState
end

-- Create a progress bar
function DRAXUI.ProgressBar(name, value, max, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    local progressId = name .. "_ProgressBar"
    options = options or {}
    
    local progressFrame = tabState.Elements[progressId] and tabState.Elements[progressId].Frame
    if not progressFrame then
        progressFrame = CreateUIElement("Frame", {
            Parent = tabState.Frame,
            Size = UDim2.new(1, -10, 0, 40),
            Position = UDim2.new(0, 5, 0, tabState.NextY),
            BackgroundTransparency = 1,
            ZIndex = tabState.Frame.ZIndex + 1,
        })
        
        local label = CreateUIElement("TextLabel", {
            Parent = progressFrame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = progressFrame.ZIndex,
        })
        
        local progressBg = CreateUIElement("Frame", {
            Parent = progressFrame,
            Size = UDim2.new(1, 0, 0, 15),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundColor3 = Config.Theme.AccentColor,
            BorderSizePixel = 0,
            ZIndex = progressFrame.ZIndex,
        })
        local bgCorner = CreateUIElement("UICorner", {
            Parent = progressBg,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local progressFill = CreateUIElement("Frame", {
            Parent = progressBg,
            Size = UDim2.new(value / max, 0, 1, 0),
            BackgroundColor3 = options.color or Config.Theme.PrimaryColor,
            BorderSizePixel = 0,
            ZIndex = progressBg.ZIndex + 1,
        })
        local fillCorner = CreateUIElement("UICorner", {
            Parent = progressFill,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        local valueLabel = CreateUIElement("TextLabel", {
            Parent = progressBg,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(value) .. "/" .. tostring(max),
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize - 2,
            ZIndex = progressFill.ZIndex + 1,
        })
        
        tabState.Elements[progressId] = {Frame = progressFrame, Background = progressBg, Fill = progressFill, Label = valueLabel}
        tabState.NextY = tabState.NextY + 50
    else
        -- Update progress
        local fill = tabState.Elements[progressId].Fill
        local label = tabState.Elements[progressId].Label
        
        fill.Size = UDim2.new(value / max, 0, 1, 0)
        label.Text = tostring(value) .. "/" .. tostring(max)
    end
end

-- Get DRAXUI version
function DRAXUI.GetVersion()
    return DRAXUI.Version
end

-- Create an input box for text entry
function DRAXUI.InputBox(label, placeholder, callback, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    
    options = options or {}
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    
    local container = CreateUIElement("Frame", {
        Parent = tabState.Container,
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, windowState.NextY),
        BackgroundColor3 = Config.Theme.SecondaryColor,
        BorderSizePixel = 0,
        ZIndex = State.ZIndex,
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = container,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
    })
    
    -- Add drop shadow
    if Config.DropShadowEnabled then
        CreateDropShadow(container, container.Size, container.Position)
    end
    
    local labelText = CreateUIElement("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = State.ZIndex + 1,
    })
    
    local inputBox = CreateUIElement("TextBox", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Config.Theme.BackgroundColor,
        BorderSizePixel = 0,
        Text = options.defaultText or "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Config.Theme.TextColor:Lerp(Config.Theme.BackgroundColor, 0.5),
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize,
        ClearTextOnFocus = options.clearOnFocus ~= false,
        ZIndex = State.ZIndex + 1,
    })
    
    local inputCorner = CreateUIElement("UICorner", {
        Parent = inputBox,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius - 2),
    })
    
    -- Add focus highlight
    local focusHighlight = CreateUIElement("UIStroke", {
        Parent = inputBox,
        Color = Config.Theme.PrimaryColor,
        Transparency = 1,
        Thickness = 2,
    })
    
    -- Add events
    inputBox.Focused:Connect(function()
        PlaySound("Click")
        CreateTween(focusHighlight, {Transparency = 0}, Config.Theme.AnimationSpeed / 2)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        CreateTween(focusHighlight, {Transparency = 1}, Config.Theme.AnimationSpeed / 2)
        if callback then
            callback(inputBox.Text, enterPressed)
        end
    end)
    
    -- Add to state for tracking
    table.insert(State.InputBoxes, {
        Container = container,
        InputBox = inputBox,
        Label = labelText,
    })
    
    windowState.NextY = windowState.NextY + 70
    return inputBox
end

-- Create an accordion (collapsible section)
function DRAXUI.Accordion(title, defaultOpen, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    
    options = options or {}
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    
    -- Create accordion container
    local container = CreateUIElement("Frame", {
        Parent = tabState.Container,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, windowState.NextY),
        BackgroundColor3 = Config.Theme.SecondaryColor,
        BorderSizePixel = 0,
        ZIndex = State.ZIndex,
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = container,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
    })
    
    -- Add drop shadow
    if Config.DropShadowEnabled then
        CreateDropShadow(container, container.Size, container.Position)
    end
    
    -- Add gradient
    CreateGradient(
        container, 
        Config.Theme.SecondaryColor, 
        Config.Theme.SecondaryColor:Lerp(Config.Theme.PrimaryColor, 0.1),
        45
    )
    
    -- Create header
    local header = CreateUIElement("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = State.ZIndex + 1,
    })
    
    local titleText = CreateUIElement("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize + 2,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = State.ZIndex + 2,
    })
    
    -- Create arrow indicator
    local arrow = CreateUIElement("TextLabel", {
        Parent = header,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0, 10),
        BackgroundTransparency = 1,
        Text = defaultOpen and "▼" or "▶",
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize,
        ZIndex = State.ZIndex + 2,
    })
    
    -- Create content container
    local content = CreateUIElement("Frame", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = State.ZIndex + 1,
    })
    
    -- Set initial state
    local isOpen = defaultOpen or false
    local contentHeight = 0
    local accordionState = {
        Container = container,
        Content = content,
        Header = header,
        Arrow = arrow,
        IsOpen = isOpen,
        ContentHeight = contentHeight,
        Elements = {},
    }
    
    -- Toggle function
    local function toggleAccordion()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        
        -- Calculate content height based on elements
        contentHeight = 0
        for _, element in ipairs(accordionState.Elements) do
            contentHeight = contentHeight + element.Size.Y.Offset + Config.Theme.ElementSpacing
        end
        
        -- Adjust container size
        if isOpen then
            CreateTween(container, {Size = UDim2.new(1, -20, 0, 40 + contentHeight)}, Config.Theme.AnimationSpeed)
            CreateTween(content, {Size = UDim2.new(1, -20, 0, contentHeight)}, Config.Theme.AnimationSpeed)
        else
            CreateTween(container, {Size = UDim2.new(1, -20, 0, 40)}, Config.Theme.AnimationSpeed)
            CreateTween(content, {Size = UDim2.new(1, -20, 0, 0)}, Config.Theme.AnimationSpeed)
        end
        
        -- Update window layout
        windowState.NextY = windowState.NextY + (isOpen and contentHeight or -contentHeight)
        
        accordionState.IsOpen = isOpen
        accordionState.ContentHeight = contentHeight
    end
    
    -- Set initial state
    if isOpen then
        content.Size = UDim2.new(1, -20, 0, contentHeight)
        container.Size = UDim2.new(1, -20, 0, 40 + contentHeight)
    end
    
    -- Connect events
    header.MouseButton1Click:Connect(function()
        PlaySound("Click")
        CreateRippleEffect(header, State.MousePosition)
        toggleAccordion()
    end)
    
    header.MouseEnter:Connect(function()
        PlaySound("Hover")
    end)
    
    -- Add to state
    table.insert(State.Accordions, accordionState)
    
    -- Update window layout
    windowState.NextY = windowState.NextY + 50
    
    -- Return functions to add elements to the accordion
    return {
        AddElement = function(element)
            element.Parent = content
            table.insert(accordionState.Elements, element)
            
            -- Update heights if open
            if isOpen then
                contentHeight = contentHeight + element.Size.Y.Offset + Config.Theme.ElementSpacing
                accordionState.ContentHeight = contentHeight
                CreateTween(container, {Size = UDim2.new(1, -20, 0, 40 + contentHeight)}, Config.Theme.AnimationSpeed)
                CreateTween(content, {Size = UDim2.new(1, -20, 0, contentHeight)}, Config.Theme.AnimationSpeed)
                windowState.NextY = windowState.NextY + element.Size.Y.Offset + Config.Theme.ElementSpacing
            end
            
            return element
        end,
        Toggle = toggleAccordion,
        GetState = function() return isOpen end
    }
end

-- Create a grid layout for organizing elements
function DRAXUI.GridLayout(columns, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    
    options = options or {}
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    
    -- Create grid container
    local container = CreateUIElement("Frame", {
        Parent = tabState.Container,
        Size = UDim2.new(1, -20, 0, options.height or 200),
        Position = UDim2.new(0, 10, 0, windowState.NextY),
        BackgroundColor3 = options.showBackground and Config.Theme.SecondaryColor or Color3.new(0,0,0),
        BackgroundTransparency = options.showBackground and 0 or 1,
        BorderSizePixel = 0,
        ZIndex = State.ZIndex,
    })
    
    if options.showBackground then
        local corner = CreateUIElement("UICorner", {
            Parent = container,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        
        -- Add drop shadow
        if Config.DropShadowEnabled then
            CreateDropShadow(container, container.Size, container.Position)
        end
    end
    
    -- Create grid layout
    local gridLayout = CreateUIElement("UIGridLayout", {
        Parent = container,
        CellSize = UDim2.new(1/columns, -(options.padding or 10) * (columns-1)/columns, 0, options.cellHeight or 40),
        CellPadding = UDim2.new(0, options.padding or 10, 0, options.padding or 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        StartCorner = Enum.StartCorner.TopLeft,
        FillDirection = Enum.FillDirection.Horizontal,
        FillDirectionMaxCells = columns,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
    
    -- Add to state
    local gridState = {
        Container = container,
        Layout = gridLayout,
        Columns = columns,
        Elements = {},
        CurrentIndex = 0,
    }
    
    table.insert(State.GridLayouts, gridState)
    
    -- Update window layout
    windowState.NextY = windowState.NextY + container.Size.Y.Offset + 10
    
    -- Return functions to add elements to the grid
    return {
        AddElement = function(element)
            element.Parent = container
            element.LayoutOrder = gridState.CurrentIndex
            gridState.CurrentIndex = gridState.CurrentIndex + 1
            table.insert(gridState.Elements, element)
            return element
        end,
        Clear = function()
            for _, element in ipairs(gridState.Elements) do
                element:Destroy()
            end
            gridState.Elements = {}
            gridState.CurrentIndex = 0
        end,
        GetContainer = function() return container end
    }
end

-- Create a search bar with results
function DRAXUI.SearchBar(placeholder, dataSource, onSelect, options)
    if not State.CurrentWindow or not State.CurrentTab then return end
    
    options = options or {}
    local windowState = State.Windows[State.CurrentWindow]
    local tabState = windowState.Tabs[State.CurrentTab]
    
    -- Create search container
    local container = CreateUIElement("Frame", {
        Parent = tabState.Container,
        Size = UDim2.new(1, -20, 0, options.showResults and 200 or 40),
        Position = UDim2.new(0, 10, 0, windowState.NextY),
        BackgroundColor3 = Config.Theme.SecondaryColor,
        BorderSizePixel = 0,
        ZIndex = State.ZIndex,
        ClipsDescendants = true,
    })
    
    local corner = CreateUIElement("UICorner", {
        Parent = container,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
    })
    
    -- Add drop shadow
    if Config.DropShadowEnabled then
        CreateDropShadow(container, container.Size, container.Position)
    end
    
    -- Create search box
    local searchBox = CreateUIElement("TextBox", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundColor3 = Config.Theme.BackgroundColor,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder or "Search...",
        PlaceholderColor3 = Config.Theme.TextColor:Lerp(Config.Theme.BackgroundColor, 0.5),
        TextColor3 = Config.Theme.TextColor,
        Font = Config.DefaultFont,
        TextSize = Config.FontSize,
        ClearTextOnFocus = false,
        ZIndex = State.ZIndex + 1,
    })
    
    local searchCorner = CreateUIElement("UICorner", {
        Parent = searchBox,
        CornerRadius = UDim.new(0, Config.Theme.CornerRadius - 2),
    })
    
    -- Create search icon
    local searchIcon = CreateUIElement("ImageLabel", {
        Parent = searchBox,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -25, 0, 7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904", -- Roblox search icon
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Config.Theme.TextColor,
        ZIndex = State.ZIndex + 2,
    })
    
    -- Create results container
    local resultsContainer = CreateUIElement("ScrollingFrame", {
        Parent = container,
        Size = UDim2.new(1, -20, 1, -45),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.PrimaryColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = State.ZIndex + 1,
        Visible = options.showResults,
    })
    
    local listLayout = CreateUIElement("UIListLayout", {
        Parent = resultsContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
    })
    
    -- Function to update results
    local function updateResults(query)
        -- Clear previous results
        for _, child in ipairs(resultsContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Reset canvas size
        resultsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        if query == "" then return end
        
        -- Filter data source
        local results = {}
        local maxResults = options.maxResults or 5
        
        if type(dataSource) == "function" then
            results = dataSource(query)
        elseif type(dataSource) == "table" then
            for _, item in ipairs(dataSource) do
                local text = type(item) == "table" and (item.text or item.name or item[1]) or tostring(item)
                if string.find(string.lower(text), string.lower(query)) then
                    table.insert(results, item)
                    if #results >= maxResults then break end
                end
            end
        end
        
        -- Create result items
        for i, result in ipairs(results) do
            local resultText = type(result) == "table" and (result.text or result.name or result[1]) or tostring(result)
            
            local resultItem = CreateUIElement("Frame", {
                Parent = resultsContainer,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Config.Theme.BackgroundColor,
                BorderSizePixel = 0,
                ZIndex = State.ZIndex + 2,
                LayoutOrder = i,
            })
            
            local resultCorner = CreateUIElement("UICorner", {
                Parent = resultItem,
                CornerRadius = UDim.new(0, Config.Theme.CornerRadius - 2),
            })
            
            local resultLabel = CreateUIElement("TextButton", {
                Parent = resultItem,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = resultText,
                TextColor3 = Config.Theme.TextColor,
                Font = Config.DefaultFont,
                TextSize = Config.FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = State.ZIndex + 3,
            })
            
            -- Highlight matching text
            local textHighlight = CreateUIElement("TextLabel", {
                Parent = resultItem,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = resultText,
                TextColor3 = Config.Theme.PrimaryColor,
                Font = Config.DefaultFont,
                TextSize = Config.FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1,
                ZIndex = State.ZIndex + 3,
            })
            
            -- Add hover effect
            resultLabel.MouseEnter:Connect(function()
                PlaySound("Hover")
                CreateTween(resultItem, {BackgroundColor3 = Config.Theme.SecondaryColor}, Config.Theme.AnimationSpeed / 2)
                CreateTween(textHighlight, {TextTransparency = 0}, Config.Theme.AnimationSpeed / 2)
            end)
            
            resultLabel.MouseLeave:Connect(function()
                CreateTween(resultItem, {BackgroundColor3 = Config.Theme.BackgroundColor}, Config.Theme.AnimationSpeed / 2)
                CreateTween(textHighlight, {TextTransparency = 1}, Config.Theme.AnimationSpeed / 2)
            end)
            
            -- Add click event
            resultLabel.MouseButton1Click:Connect(function()
                PlaySound("Click")
                CreateRippleEffect(resultItem, State.MousePosition)
                if onSelect then
                    onSelect(result)
                end
                searchBox.Text = resultText
            end)
        end
        
        -- Update canvas size
        resultsContainer.CanvasSize = UDim2.new(0, 0, 0, #results * 35)
    end
    
    -- Connect events
    searchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            updateResults(searchBox.Text)
        end
    end)
    
    searchBox.Focused:Connect(function()
        PlaySound("Click")
        if options.expandOnFocus then
            CreateTween(container, {Size = UDim2.new(1, -20, 0, 200)}, Config.Theme.AnimationSpeed)
            resultsContainer.Visible = true
        end
    end)
    
    searchBox.FocusLost:Connect(function()
        if options.collapseOnFocusLost and not options.showResults then
            CreateTween(container, {Size = UDim2.new(1, -20, 0, 40)}, Config.Theme.AnimationSpeed)
            resultsContainer.Visible = false
        end
    end)
    
    -- Add to state
    local searchState = {
        Container = container,
        SearchBox = searchBox,
        ResultsContainer = resultsContainer,
        UpdateResults = updateResults,
    }
    
    table.insert(State.SearchResults, searchState)
    
    -- Update window layout
    windowState.NextY = windowState.NextY + container.Size.Y.Offset + 10
    
    return {
        SetText = function(text)
            searchBox.Text = text
        end,
        GetText = function()
            return searchBox.Text
        end,
        UpdateDataSource = function(newDataSource)
            dataSource = newDataSource
            updateResults(searchBox.Text)
        end,
        Focus = function()
            searchBox:CaptureFocus()
        end
    }
end

-- Add loadstring compatibility for exploit scripts
if isExploitEnvironment then
    -- Create a global instance for direct access in exploit scripts
    getgenv = getgenv or function() return _G end
    getgenv().DRAXUI = DRAXUI
    
    -- Auto-initialize if loaded via loadstring
    if not DRAXUI._LoadedViaRequire then
        local autoInit = DRAXUI.Init()
        autoInit:Connect()
        getgenv().UI = autoInit
        print("DRAXUI " .. DRAXUI.Version .. " initialized automatically in " .. executorDetected .. " environment")
        print("Access the UI via the global 'UI' variable")
    end
end

-- Module return for require() usage
DRAXUI._LoadedViaRequire = true
return DRAXUI
