-- DRAXUI: Enhanced Roblox UI Library inspired by ImGui and Rayfield
-- Version: 1.0.0
-- Features: Immediate-mode GUI, tabs, custom fonts, particle effects, sliders, keybinds, and more
-- Usage: local DRAXUI = require(path.to.DRAXUI).Init()
--
-- GitHub: https://github.com/yourusername/DRAXUI
-- Documentation: See README.md for full documentation and examples

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DRAXUI = {}
DRAXUI.__index = DRAXUI

-- Version info
DRAXUI.Version = "1.0.0"

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
        WindowTransparency = 0.9,
        AnimationSpeed = 0.15,
        CornerRadius = 8,
    },
    DefaultWindowSize = Vector2.new(400, 500),
    DefaultFont = Enum.Font.SourceSansPro,
    FontSize = 16,
    ParticleCount = 20,
    ParticleSpeed = 0.5,
    TooltipDelay = 0.5,
    NotificationDuration = 3,
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
}

-- Helper function to create UI elements
local function CreateUIElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
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
    self.ScreenGui = CreateUIElement("ScreenGui", {
        Parent = parent or game.Players.LocalPlayer.PlayerGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    self.Connections = {}
    
    -- Apply custom settings
    if settings then
        Config.DefaultFont = settings.Font or Config.DefaultFont
        Config.FontSize = settings.FontSize or Config.FontSize
        Config.Theme = settings.Theme or Config.Theme
    end
    
    -- Create particle background
    self.Particles = {}
    for i = 1, Config.ParticleCount do
        local particle = CreateUIElement("Frame", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, 5, 0, 5),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = Config.Theme.PrimaryColor,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = particle,
            CornerRadius = UDim.new(0, 5),
        })
        self.Particles[i] = {Frame = particle, Velocity = Vector2.new(math.random(-1, 1) * Config.ParticleSpeed, math.random(-1, 1) * Config.ParticleSpeed)}
    end
    
    -- Animate particles
    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt)
        for _, particle in ipairs(self.Particles) do
            local pos = particle.Frame.Position
            local newX = pos.X.Scale + particle.Velocity.X * dt
            local newY = pos.Y.Scale + particle.Velocity.Y * dt
            if newX > 1 or newX < 0 then particle.Velocity.X = -particle.Velocity.X end
            if newY > 1 or newY < 0 then particle.Velocity.Y = -particle.Velocity.Y end
            particle.Frame.Position = UDim2.new(newX, 0, newY, 0)
        end
    end))
    
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
    }
    State.Windows[name] = windowState

    if not windowState.IsOpen then
        return
    end

    State.CurrentWindow = name
    local frame = windowState.Frame
    if not frame then
        frame = CreateUIElement("Frame", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, windowState.Size.X, 0, windowState.Size.Y),
            Position = windowState.Position,
            BackgroundColor3 = Config.Theme.BackgroundColor,
            BackgroundTransparency = Config.Theme.WindowTransparency,
            BorderSizePixel = 0,
            ZIndex = State.ZIndex,
        })
        local corner = CreateUIElement("UICorner", {
            Parent = frame,
            CornerRadius = UDim.new(0, Config.Theme.CornerRadius),
        })
        CreateTween(frame, {BackgroundTransparency = Config.Theme.WindowTransparency}, Config.Theme.AnimationSpeed)
        
        local titleBar = CreateUIElement("Frame", {
            Parent = frame,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Config.Theme.PrimaryColor,
            BorderSizePixel = 0,
            ZIndex = State.ZIndex + 1,
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
            Text = name,
            TextColor3 = Config.Theme.TextColor,
            Font = Config.DefaultFont,
            TextSize = Config.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = State.ZIndex + 2,
        })
        
        windowState.Frame = frame
        windowState.TitleBar = titleBar
        windowState.NextY = 70 -- Space for tabs
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

-- Get library version
function DRAXUI.GetVersion()
    return DRAXUI.Version
end

return DRAXUI