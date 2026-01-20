-- // SYLON AUTO FARM - WINDUI LIBRARY (SELF-CONTAINED)
-- // NO EXTERNAL DEPENDENCIES - 100% LOCAL
local user_input_service = game:GetService("UserInputService")
local http_service = game:GetService("HttpService")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer
local gui_parent = gethui and gethui() or game:GetService("CoreGui")
local old_gui = gui_parent:FindFirstChild("SYLON_Gui")
if old_gui then old_gui:Destroy() end

-- // WindUI Framework (EMBEDDED - NO EXTERNAL REQUESTS)
local Wind = {}
do
    local UI = {}
    local Objects = {}
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil
    local LastMousePos = nil
    local LastDragTime = 0

    function UI:CreateWindow(Config)
        local Window = {}
        Window.Title = Config.Title or "Window"
        Window.Size = Config.Size or UDim2.new(0, 400, 0, 450)
        Window.AutoShow = Config.AutoShow or false
        Window.Menu = Config.Menu or {
            Visible = true,
            Color = Color3.fromRGB(41, 41, 53),
            Items = {
                { Text = "TAB1", Callback = function() end, Active = true },
                { Text = "TAB2", Callback = function() end }
            }
        }
        Window.Visible = false
        Window.Tabs = {}
        Window.Main = nil

        -- Create main window frame
        local Main = Instance.new("ScreenGui")
        Main.Name = "SYLON_Gui"
        Main.Parent = gui_parent
        Main.ResetOnSpawn = false
        Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        Main.Enabled = Window.AutoShow

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = Main        MainFrame.Size = Window.Size
        MainFrame.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.ClipsDescendants = true
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 80)

        -- Header
        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Parent = MainFrame
        Header.Size = UDim2.new(1, 0, 0, 40)
        Header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Parent = Header
        Title.Size = UDim2.new(0.7, 0, 1, 0)
        Title.Position = UDim2.new(0, 20, 0, 0)
        Title.Text = Window.Title
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Name = "CloseButton"
        CloseBtn.Parent = Header
        CloseBtn.Size = UDim2.new(0, 24, 0, 24)
        CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 14
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

        -- Menu
        local MenuFrame = nil
        if Window.Menu.Visible then
            MenuFrame = Instance.new("Frame")
            MenuFrame.Name = "MenuFrame"
            MenuFrame.Parent = MainFrame
            MenuFrame.Size = UDim2.new(1, 0, 0, 35)
            MenuFrame.Position = UDim2.new(0, 0, 0, 40)            MenuFrame.BackgroundColor3 = Window.Menu.Color
            Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)

            local MenuLayout = Instance.new("UIListLayout")
            MenuLayout.Name = "MenuLayout"
            MenuLayout.Parent = MenuFrame
            MenuLayout.FillDirection = Enum.FillDirection.Horizontal
            MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            MenuLayout.SortingOrder = Enum.SortingOrder.LayoutOrder
            MenuLayout.Padding = UDim.new(0, 5)

            for i, item in ipairs(Window.Menu.Items) do
                local Tab = Instance.new("TextButton")
                Tab.Name = "Tab" .. i
                Tab.Parent = MenuFrame
                Tab.Size = UDim2.new(0.333, 0, 1, 0)
                Tab.BackgroundTransparency = 1
                Tab.Text = item.Text
                Tab.TextColor3 = item.Active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
                Tab.Font = Enum.Font.GothamBold
                Tab.TextSize = 12
                Tab.BorderSizePixel = 0

                local Underline = Instance.new("Frame")
                Underline.Name = "Underline"
                Underline.Parent = Tab
                Underline.Size = UDim2.new(1, -20, 0, 2)
                Underline.Position = UDim2.new(0.5, 0, 1, -1)
                Underline.BackgroundColor3 = item.Active and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
                Instance.new("UICorner", Underline).CornerRadius = UDim.new(0, 1)
            end
        end

        -- Content Area
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = MainFrame
        ContentFrame.Size = UDim2.new(1, 0, 1, -110)
        ContentFrame.Position = UDim2.new(0, 0, 0, 75)
        ContentFrame.BackgroundTransparency = 1

        -- Footer
        local Footer = Instance.new("Frame")
        Footer.Name = "Footer"
        Footer.Parent = MainFrame
        Footer.Size = UDim2.new(1, 0, 0, 35)
        Footer.Position = UDim2.new(0, 0, 1, -35)
        Footer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 12)
        local StatusText = Instance.new("TextLabel")
        StatusText.Name = "Status"
        StatusText.Parent = Footer
        StatusText.Size = UDim2.new(0.6, 0, 1, 0)
        StatusText.Position = UDim2.new(0, 15, 0, 0)
        StatusText.Text = "● IDLE"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 220)
        StatusText.BackgroundTransparency = 1
        StatusText.Font = Enum.Font.GothamMedium
        StatusText.RichText = true
        StatusText.TextSize = 12
        StatusText.TextXAlignment = Enum.TextXAlignment.Left

        local ClockText = Instance.new("TextLabel")
        ClockText.Name = "Clock"
        ClockText.Parent = Footer
        ClockText.Size = UDim2.new(0.4, 0, 1, 0)
        ClockText.Position = UDim2.new(0.6, 0, 0, 0)
        ClockText.Text = "TIME: 00:00:00"
        ClockText.TextColor3 = Color3.fromRGB(150, 150, 170)
        ClockText.BackgroundTransparency = 1
        ClockText.Font = Enum.Font.GothamBold
        ClockText.TextSize = 11
        ClockText.TextXAlignment = Enum.TextXAlignment.Right

        -- Tab System
        function Window:CreateTab(name, active)
            local Tab = {}
            Tab.Name = name
            Tab.Active = active
            Tab.Container = nil

            -- Create tab container
            local TabContainer = Instance.new("ScrollingFrame")
            TabContainer.Name = name .. "Tab"
            TabContainer.Parent = ContentFrame
            TabContainer.Size = UDim2.new(1, -20, 1, -10)
            TabContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            TabContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            TabContainer.BackgroundTransparency = 1
            TabContainer.BorderSizePixel = 0
            TabContainer.ScrollBarThickness = 4
            TabContainer.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            TabContainer.Visible = active

            local Layout = Instance.new("UIListLayout")
            Layout.Name = "TabLayout"
            Layout.Parent = TabContainer            Layout.Padding = UDim.new(0, 8)
            Layout.FillDirection = Enum.FillDirection.Vertical
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Layout.SortingOrder = Enum.SortingOrder.LayoutOrder

            Tab.Container = TabContainer

            -- Add to window tabs
            table.insert(Window.Tabs, Tab)

            -- Update menu if visible
            if Window.Menu.Visible then
                local menu_item = Window.Menu.Items[#Window.Tabs]
                if menu_item then
                    menu_item.Callback = function()
                        Window:SwitchTab(name)
                    end
                end
            end

            return Tab
        end

        -- Switch between tabs
        function Window:SwitchTab(name)
            for _, tab in ipairs(Window.Tabs) do
                tab.Container.Visible = (tab.Name == name)
                if tab.Name == name and Window.Menu.Visible then
                    -- Update menu item
                    for i, item in ipairs(Window.Menu.Items) do
                        item.Active = (i == _)
                        local underline = tab.Container.Parent:FindFirstChild("MenuFrame"):FindFirstChild("Tab" .. i):FindFirstChild("Underline")
                        if underline then
                            underline.BackgroundColor3 = item.Active and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
                        end
                    end
                end
            end
        end

        -- Toggle window visibility
        function Window:Toggle()
            Window.Visible = not Window.Visible
            Main.Enabled = Window.Visible
        end

        -- Close button functionality
        CloseBtn.MouseButton1Click:Connect(function()
            Window:Toggle()
        end)
        -- Drag functionality
        local function update_drag(input)
            if Dragging and input == DragInput and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - DragStart
                MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
            end
        end

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                DragInput = input
                DragStart = input.Position
                StartPos = MainFrame.Position
            end
        end)

        user_input_service.InputChanged:Connect(function(input)
            if input == DragInput then
                update_drag(input)
            end
        end)

        user_input_service.InputEnded:Connect(function(input)
            if input == DragInput then
                Dragging = false
                DragInput = nil
            end
        end)

        -- Hotkey support
        user_input_service.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.LeftAlt then
                Window:Toggle()
            end
        end)

        Window.Main = MainFrame
        Window.StatusText = StatusText
        Window.ClockText = ClockText

        return Window
    end

    Wind = {
        CreateWindow = function(config)
            return UI:CreateWindow(config)
        end
    }end

-- // Configuration
_G.WaveSkipper = _G.WaveSkipper or false
_G.CommanderBooster = _G.CommanderBooster or false
_G.BeatMaster = _G.BeatMaster or false
_G.MercenaryAuto = _G.MercenaryAuto or false
_G.FarmLiquidation = _G.FarmLiquidation or false
_G.FarmLiquidationWave = _G.FarmLiquidationWave or 24
_G.OptimalPathing = _G.OptimalPathing or 0
_G.ItemCollector = _G.ItemCollector or false
_G.RewardClaimer = _G.RewardClaimer or false
_G.DiscordNotifier = _G.DiscordNotifier or false
_G.DiscordWebhook = _G.DiscordWebhook or ""
_G.MapFilter = _G.MapFilter or true

local ConfigFile = "SYLON_Config.json"

-- // Save/Load Configuration
local function SaveConfig()
    local ConfigData = {
        WaveSkipper = _G.WaveSkipper,
        CommanderBooster = _G.CommanderBooster,
        BeatMaster = _G.BeatMaster,
        MercenaryAuto = _G.MercenaryAuto,
        FarmLiquidation = _G.FarmLiquidation,
        FarmLiquidationWave = _G.FarmLiquidationWave,
        OptimalPathing = _G.OptimalPathing,
        ItemCollector = _G.ItemCollector,
        RewardClaimer = _G.RewardClaimer,
        DiscordNotifier = _G.DiscordNotifier,
        DiscordWebhook = _G.DiscordWebhook,
        MapFilter = _G.MapFilter
    }
    
    pcall(function()
        writefile(ConfigFile, http_service:JSONEncode(ConfigData))
    end)
end

local function LoadConfig()
    local DefaultConfig = {
        WaveSkipper = false,
        CommanderBooster = false,
        BeatMaster = false,
        MercenaryAuto = false,
        FarmLiquidation = false,
        FarmLiquidationWave = 24,
        OptimalPathing = 0,
        ItemCollector = false,        RewardClaimer = false,
        DiscordNotifier = false,
        DiscordWebhook = "",
        MapFilter = true
    }
    
    pcall(function()
        if isfile(ConfigFile) then
            local DecodedData = http_service:JSONDecode(readfile(ConfigFile))
            for Key, Value in pairs(DecodedData) do
                if _G[Key] ~= nil then
                    _G[Key] = Value
                end
            end
            return
        end
    end)
    
    for Key, Value in pairs(DefaultConfig) do
        _G[Key] = Value
    end
end

LoadConfig()

-- // Create WindUI Window
local MainWindow = Wind:CreateWindow({
    Title = "SYLON AUTO FARM",
    Size = UDim2.new(0, 420, 0, 480),
    AutoShow = true,
    Menu = {
        Visible = true,
        Color = Color3.fromRGB(41, 41, 53),
        Items = {
            {
                Text = "LOGGER",
                Callback = function() end,
                Active = true
            },
            {
                Text = "MAIN",
                Callback = function() end
            },
            {
                Text = "MISC",
                Callback = function() end
            }
        }
    }
})
-- // Global References
local ConsoleScrolling = nil
local ConsoleLayout = nil
local StartTime = os.time()

-- // LOGGER TAB
do
    local LoggerTab = MainWindow:CreateTab("LOGGER", true)
    
    -- Create container that mimics original logger structure
    local LoggerContainer = Instance.new("Frame")
    LoggerContainer.Name = "LoggerContainer"
    LoggerContainer.Parent = LoggerTab.Container
    LoggerContainer.Size = UDim2.new(1, -20, 1, -50)
    LoggerContainer.Position = UDim2.new(0.5, 0, 0, 10)
    LoggerContainer.AnchorPoint = Vector2.new(0.5, 0)
    LoggerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    LoggerContainer.BorderSizePixel = 0
    Instance.new("UICorner", LoggerContainer).CornerRadius = UDim.new(0, 8)
    
    -- ScrollingFrame for logs
    ConsoleScrolling = Instance.new("ScrollingFrame")
    ConsoleScrolling.Name = "Console"
    ConsoleScrolling.Parent = LoggerContainer
    ConsoleScrolling.Size = UDim2.new(1, -10, 1, -10)
    ConsoleScrolling.Position = UDim2.new(0, 5, 0, 5)
    ConsoleScrolling.BackgroundTransparency = 1
    ConsoleScrolling.BorderSizePixel = 0
    ConsoleScrolling.ScrollBarThickness = 4
    ConsoleScrolling.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
    ConsoleScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    ConsoleScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    ConsoleLayout = Instance.new("UIListLayout")
    ConsoleLayout.Name = "ConsoleLayout"
    ConsoleLayout.Parent = ConsoleScrolling
    ConsoleLayout.Padding = UDim.new(0, 4)
    ConsoleLayout.FillDirection = Enum.FillDirection.Vertical
    ConsoleLayout.SortingOrder = Enum.SortingOrder.LayoutOrder
    ConsoleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    
    -- Initial log
    local function AddLog(Text, Color)
        if not ConsoleScrolling or not ConsoleLayout then return end
        
        local ColorMap = {
            red = "#ff4d4d",
            orange = "#ff9f43", 
            yellow = "#feca57",            green = "#00ff96"
        }
        
        local DefaultColor = "green"
        if Text:lower():find("error") or Text:lower():find("failed") then
            DefaultColor = "red"
        elseif Text:lower():find("warning") or Text:lower():find("issue") then
            DefaultColor = "orange"
        end
        
        Color = Color or DefaultColor
        local HexColor = ColorMap[Color] or ColorMap.green
        local Timestamp = os.date("%H:%M:%S")
        local FormattedText = string.format("<font color='#555564'>[%s]</font> <font color='%s'>%s</font>", Timestamp, HexColor, Text)
        
        local LogEntry = Instance.new("TextLabel")
        LogEntry.Name = "LogEntry"
        LogEntry.BackgroundTransparency = 1
        LogEntry.Size = UDim2.new(1, -8, 0, 0)
        LogEntry.Font = Enum.Font.SourceSansSemibold
        LogEntry.RichText = true
        LogEntry.Text = FormattedText
        LogEntry.TextSize = 14
        LogEntry.TextWrapped = true
        LogEntry.TextXAlignment = Enum.TextXAlignment.Left
        LogEntry.TextColor3 = Color3.fromRGB(255, 255, 255)
        LogEntry.AutomaticSize = Enum.AutomaticSize.Y
        LogEntry.Parent = ConsoleScrolling
        
        task.wait()
        ConsoleScrolling.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y)
        ConsoleScrolling.CanvasPosition = Vector2.new(0, ConsoleScrolling.CanvasSize.Y.Offset)
    end
    
    AddLog("SYLON System initialized", "green")
end

-- // MAIN TAB
do
    local MainTab = MainWindow:CreateTab("MAIN", false)
    
    -- Wave Skipper
    local WaveSkipperFrame = MainTab:CreateSection("Wave Skipper")
    WaveSkipperFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local WaveSkipperToggle = Instance.new("TextButton")
    WaveSkipperToggle.Name = "ToggleButton"
    WaveSkipperToggle.Parent = WaveSkipperFrame
    WaveSkipperToggle.Size = UDim2.new(0, 40, 0, 20)
    WaveSkipperToggle.Position = UDim2.new(1, -50, 0.5, -10)    WaveSkipperToggle.BackgroundColor3 = _G.WaveSkipper and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    WaveSkipperToggle.Text = ""
    WaveSkipperToggle.BorderSizePixel = 0
    Instance.new("UICorner", WaveSkipperToggle).CornerRadius = UDim.new(0, 10)
    
    local WaveSkipperCircle = Instance.new("Frame")
    WaveSkipperCircle.Name = "ToggleCircle"
    WaveSkipperCircle.Parent = WaveSkipperToggle
    WaveSkipperCircle.Size = UDim2.new(0, 14, 0, 14)
    WaveSkipperCircle.Position = _G.WaveSkipper and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    WaveSkipperCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", WaveSkipperCircle).CornerRadius = UDim.new(1, 0)
    
    WaveSkipperToggle.MouseButton1Click:Connect(function()
        _G.WaveSkipper = not _G.WaveSkipper
        WaveSkipperToggle.BackgroundColor3 = _G.WaveSkipper and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        WaveSkipperCircle:TweenPosition(_G.WaveSkipper and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Commander Booster
    local CommanderBoosterFrame = MainTab:CreateSection("Commander Booster")
    CommanderBoosterFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local CommanderBoosterToggle = Instance.new("TextButton")
    CommanderBoosterToggle.Name = "ToggleButton"
    CommanderBoosterToggle.Parent = CommanderBoosterFrame
    CommanderBoosterToggle.Size = UDim2.new(0, 40, 0, 20)
    CommanderBoosterToggle.Position = UDim2.new(1, -50, 0.5, -10)
    CommanderBoosterToggle.BackgroundColor3 = _G.CommanderBooster and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    CommanderBoosterToggle.Text = ""
    CommanderBoosterToggle.BorderSizePixel = 0
    Instance.new("UICorner", CommanderBoosterToggle).CornerRadius = UDim.new(0, 10)
    
    local CommanderBoosterCircle = Instance.new("Frame")
    CommanderBoosterCircle.Name = "ToggleCircle"
    CommanderBoosterCircle.Parent = CommanderBoosterToggle
    CommanderBoosterCircle.Size = UDim2.new(0, 14, 0, 14)
    CommanderBoosterCircle.Position = _G.CommanderBooster and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    CommanderBoosterCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", CommanderBoosterCircle).CornerRadius = UDim.new(1, 0)
    
    CommanderBoosterToggle.MouseButton1Click:Connect(function()
        _G.CommanderBooster = not _G.CommanderBooster
        CommanderBoosterToggle.BackgroundColor3 = _G.CommanderBooster and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        CommanderBoosterCircle:TweenPosition(_G.CommanderBooster and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Beat Master    local BeatMasterFrame = MainTab:CreateSection("Beat Master")
    BeatMasterFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local BeatMasterToggle = Instance.new("TextButton")
    BeatMasterToggle.Name = "ToggleButton"
    BeatMasterToggle.Parent = BeatMasterFrame
    BeatMasterToggle.Size = UDim2.new(0, 40, 0, 20)
    BeatMasterToggle.Position = UDim2.new(1, -50, 0.5, -10)
    BeatMasterToggle.BackgroundColor3 = _G.BeatMaster and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    BeatMasterToggle.Text = ""
    BeatMasterToggle.BorderSizePixel = 0
    Instance.new("UICorner", BeatMasterToggle).CornerRadius = UDim.new(0, 10)
    
    local BeatMasterCircle = Instance.new("Frame")
    BeatMasterCircle.Name = "ToggleCircle"
    BeatMasterCircle.Parent = BeatMasterToggle
    BeatMasterCircle.Size = UDim2.new(0, 14, 0, 14)
    BeatMasterCircle.Position = _G.BeatMaster and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    BeatMasterCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", BeatMasterCircle).CornerRadius = UDim.new(1, 0)
    
    BeatMasterToggle.MouseButton1Click:Connect(function()
        _G.BeatMaster = not _G.BeatMaster
        BeatMasterToggle.BackgroundColor3 = _G.BeatMaster and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        BeatMasterCircle:TweenPosition(_G.BeatMaster and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Mercenary Auto-Deploy
    local MercenaryAutoFrame = MainTab:CreateSection("Mercenary Auto-Deploy")
    MercenaryAutoFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local MercenaryAutoToggle = Instance.new("TextButton")
    MercenaryAutoToggle.Name = "ToggleButton"
    MercenaryAutoToggle.Parent = MercenaryAutoFrame
    MercenaryAutoToggle.Size = UDim2.new(0, 40, 0, 20)
    MercenaryAutoToggle.Position = UDim2.new(1, -50, 0.5, -10)
    MercenaryAutoToggle.BackgroundColor3 = _G.MercenaryAuto and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    MercenaryAutoToggle.Text = ""
    MercenaryAutoToggle.BorderSizePixel = 0
    Instance.new("UICorner", MercenaryAutoToggle).CornerRadius = UDim.new(0, 10)
    
    local MercenaryAutoCircle = Instance.new("Frame")
    MercenaryAutoCircle.Name = "ToggleCircle"
    MercenaryAutoCircle.Parent = MercenaryAutoToggle
    MercenaryAutoCircle.Size = UDim2.new(0, 14, 0, 14)
    MercenaryAutoCircle.Position = _G.MercenaryAuto and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    MercenaryAutoCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", MercenaryAutoCircle).CornerRadius = UDim.new(1, 0)
        MercenaryAutoToggle.MouseButton1Click:Connect(function()
        _G.MercenaryAuto = not _G.MercenaryAuto
        MercenaryAutoToggle.BackgroundColor3 = _G.MercenaryAuto and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        MercenaryAutoCircle:TweenPosition(_G.MercenaryAuto and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Farm Liquidation
    local FarmLiquidationFrame = MainTab:CreateSection("Farm Liquidation")
    FarmLiquidationFrame.Size = UDim2.new(1, -10, 0, 80)
    
    local FarmLiquidationToggle = Instance.new("TextButton")
    FarmLiquidationToggle.Name = "ToggleButton"
    FarmLiquidationToggle.Parent = FarmLiquidationFrame
    FarmLiquidationToggle.Size = UDim2.new(0, 40, 0, 20)
    FarmLiquidationToggle.Position = UDim2.new(1, -50, 0.5, -10)
    FarmLiquidationToggle.BackgroundColor3 = _G.FarmLiquidation and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    FarmLiquidationToggle.Text = ""
    FarmLiquidationToggle.BorderSizePixel = 0
    Instance.new("UICorner", FarmLiquidationToggle).CornerRadius = UDim.new(0, 10)
    
    local FarmLiquidationCircle = Instance.new("Frame")
    FarmLiquidationCircle.Name = "ToggleCircle"
    FarmLiquidationCircle.Parent = FarmLiquidationToggle
    FarmLiquidationCircle.Size = UDim2.new(0, 14, 0, 14)
    FarmLiquidationCircle.Position = _G.FarmLiquidation and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    FarmLiquidationCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", FarmLiquidationCircle).CornerRadius = UDim.new(1, 0)
    
    FarmLiquidationToggle.MouseButton1Click:Connect(function()
        _G.FarmLiquidation = not _G.FarmLiquidation
        FarmLiquidationToggle.BackgroundColor3 = _G.FarmLiquidation and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        FarmLiquidationCircle:TweenPosition(_G.FarmLiquidation and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    local WaveInput = Instance.new("TextBox")
    WaveInput.Name = "WaveInput"
    WaveInput.Parent = FarmLiquidationFrame
    WaveInput.Size = UDim2.new(0, 75, 0, 22)
    WaveInput.Position = UDim2.new(0.5, -110, 0.5, 35)
    WaveInput.AnchorPoint = Vector2.new(0.5, 0)
    WaveInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    WaveInput.Text = "Wave: " .. tostring(_G.FarmLiquidationWave)
    WaveInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    WaveInput.Font = Enum.Font.GothamBold
    WaveInput.TextSize = 10
    WaveInput.PlaceholderText = "Wave number"
    Instance.new("UICorner", WaveInput).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", WaveInput).Color = Color3.fromRGB(70, 70, 90)    
    WaveInput.Focused:Connect(function()
        WaveInput.Text = ""
    end)
    
    WaveInput.FocusLost:Connect(function()
        local Value = tonumber(WaveInput.Text:match("%d+"))
        if Value then
            _G.FarmLiquidationWave = Value
            SaveConfig()
        end
        WaveInput.Text = "Wave: " .. tostring(_G.FarmLiquidationWave)
    end)
    
    -- Optimal Pathing
    local OptimalPathingFrame = MainTab:CreateSection("Optimal Pathing")
    OptimalPathingFrame.Size = UDim2.new(1, -10, 0, 60)
    
    local PathingLabel = Instance.new("TextLabel")
    PathingLabel.Name = "PathingLabel"
    PathingLabel.Parent = OptimalPathingFrame
    PathingLabel.Size = UDim2.new(1, -20, 0, 20)
    PathingLabel.Position = UDim2.new(0, 10, 0, 5)
    PathingLabel.BackgroundTransparency = 1
    PathingLabel.Text = "Path Distance: " .. tostring(_G.OptimalPathing)
    PathingLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    PathingLabel.Font = Enum.Font.GothamSemibold
    PathingLabel.TextSize = 11
    PathingLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local PathingBar = Instance.new("Frame")
    PathingBar.Name = "PathingBar"
    PathingBar.Parent = OptimalPathingFrame
    PathingBar.Size = UDim2.new(1, -20, 0, 4)
    PathingBar.Position = UDim2.new(0, 10, 0, 35)
    PathingBar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Instance.new("UICorner", PathingBar).CornerRadius = UDim.new(1, 0)
    
    local PathingFill = Instance.new("Frame")
    PathingFill.Name = "PathingFill"
    PathingFill.Parent = PathingBar
    PathingFill.Size = UDim2.new(_G.OptimalPathing/300, 0, 1, 0)
    PathingFill.BackgroundColor3 = Color3.fromRGB(50, 200, 150)
    Instance.new("UICorner", PathingFill).CornerRadius = UDim.new(1, 0)
    
    local PathingKnob = Instance.new("Frame")
    PathingKnob.Name = "PathingKnob"
    PathingKnob.Parent = PathingBar
    PathingKnob.Size = UDim2.new(0, 12, 0, 12)
    PathingKnob.Position = UDim2.new(_G.OptimalPathing/300, -6, 0.5, -6)    PathingKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", PathingKnob).CornerRadius = UDim.new(1, 0)
    
    local Sliding = false
    PathingKnob.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Sliding = true
        end
    end)
    
    user_input_service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Sliding = false
        end
    end)
    
    user_input_service.InputChanged:Connect(function(Input)
        if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Position = math.clamp((Input.Position.X - PathingBar.AbsolutePosition.X) / PathingBar.AbsoluteSize.X, 0, 1)
            local Value = math.floor(300 * Position)
            _G.OptimalPathing = Value
            PathingLabel.Text = "Path Distance: " .. tostring(Value)
            PathingFill.Size = UDim2.new(Position, 0, 1, 0)
            PathingKnob.Position = UDim2.new(Position, -6, 0.5, -6)
            SaveConfig()
        end
    end)
end

-- // MISC TAB
do
    local MiscTab = MainWindow:CreateTab("MISC", false)
    
    -- Item Collector
    local ItemCollectorFrame = MiscTab:CreateSection("Item Collector")
    ItemCollectorFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local ItemCollectorToggle = Instance.new("TextButton")
    ItemCollectorToggle.Name = "ToggleButton"
    ItemCollectorToggle.Parent = ItemCollectorFrame
    ItemCollectorToggle.Size = UDim2.new(0, 40, 0, 20)
    ItemCollectorToggle.Position = UDim2.new(1, -50, 0.5, -10)
    ItemCollectorToggle.BackgroundColor3 = _G.ItemCollector and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    ItemCollectorToggle.Text = ""
    ItemCollectorToggle.BorderSizePixel = 0
    Instance.new("UICorner", ItemCollectorToggle).CornerRadius = UDim.new(0, 10)
    
    local ItemCollectorCircle = Instance.new("Frame")
    ItemCollectorCircle.Name = "ToggleCircle"
    ItemCollectorCircle.Parent = ItemCollectorToggle    ItemCollectorCircle.Size = UDim2.new(0, 14, 0, 14)
    ItemCollectorCircle.Position = _G.ItemCollector and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    ItemCollectorCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ItemCollectorCircle).CornerRadius = UDim.new(1, 0)
    
    ItemCollectorToggle.MouseButton1Click:Connect(function()
        _G.ItemCollector = not _G.ItemCollector
        ItemCollectorToggle.BackgroundColor3 = _G.ItemCollector and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        ItemCollectorCircle:TweenPosition(_G.ItemCollector and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Reward Claimer
    local RewardClaimerFrame = MiscTab:CreateSection("Reward Claimer")
    RewardClaimerFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local RewardClaimerToggle = Instance.new("TextButton")
    RewardClaimerToggle.Name = "ToggleButton"
    RewardClaimerToggle.Parent = RewardClaimerFrame
    RewardClaimerToggle.Size = UDim2.new(0, 40, 0, 20)
    RewardClaimerToggle.Position = UDim2.new(1, -50, 0.5, -10)
    RewardClaimerToggle.BackgroundColor3 = _G.RewardClaimer and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    RewardClaimerToggle.Text = ""
    RewardClaimerToggle.BorderSizePixel = 0
    Instance.new("UICorner", RewardClaimerToggle).CornerRadius = UDim.new(0, 10)
    
    local RewardClaimerCircle = Instance.new("Frame")
    RewardClaimerCircle.Name = "ToggleCircle"
    RewardClaimerCircle.Parent = RewardClaimerToggle
    RewardClaimerCircle.Size = UDim2.new(0, 14, 0, 14)
    RewardClaimerCircle.Position = _G.RewardClaimer and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    RewardClaimerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", RewardClaimerCircle).CornerRadius = UDim.new(1, 0)
    
    RewardClaimerToggle.MouseButton1Click:Connect(function()
        _G.RewardClaimer = not _G.RewardClaimer
        RewardClaimerToggle.BackgroundColor3 = _G.RewardClaimer and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        RewardClaimerCircle:TweenPosition(_G.RewardClaimer and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Discord Notifier
    local DiscordNotifierFrame = MiscTab:CreateSection("Discord Notifier")
    DiscordNotifierFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local DiscordNotifierToggle = Instance.new("TextButton")
    DiscordNotifierToggle.Name = "ToggleButton"
    DiscordNotifierToggle.Parent = DiscordNotifierFrame
    DiscordNotifierToggle.Size = UDim2.new(0, 40, 0, 20)
    DiscordNotifierToggle.Position = UDim2.new(1, -50, 0.5, -10)    DiscordNotifierToggle.BackgroundColor3 = _G.DiscordNotifier and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    DiscordNotifierToggle.Text = ""
    DiscordNotifierToggle.BorderSizePixel = 0
    Instance.new("UICorner", DiscordNotifierToggle).CornerRadius = UDim.new(0, 10)
    
    local DiscordNotifierCircle = Instance.new("Frame")
    DiscordNotifierCircle.Name = "ToggleCircle"
    DiscordNotifierCircle.Parent = DiscordNotifierToggle
    DiscordNotifierCircle.Size = UDim2.new(0, 14, 0, 14)
    DiscordNotifierCircle.Position = _G.DiscordNotifier and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    DiscordNotifierCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", DiscordNotifierCircle).CornerRadius = UDim.new(1, 0)
    
    DiscordNotifierToggle.MouseButton1Click:Connect(function()
        _G.DiscordNotifier = not _G.DiscordNotifier
        DiscordNotifierToggle.BackgroundColor3 = _G.DiscordNotifier and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        DiscordNotifierCircle:TweenPosition(_G.DiscordNotifier and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
    
    -- Discord Webhook URL
    local WebhookFrame = MiscTab:CreateSection("Webhook URL")
    WebhookFrame.Size = UDim2.new(1, -10, 0, 80)
    
    local WebhookLabel = Instance.new("TextLabel")
    WebhookLabel.Name = "WebhookLabel"
    WebhookLabel.Parent = WebhookFrame
    WebhookLabel.Size = UDim2.new(1, 0, 0, 20)
    WebhookLabel.Position = UDim2.new(0, 10, 0, 8)
    WebhookLabel.Text = "DISCORD WEBHOOK URL"
    WebhookLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    WebhookLabel.Font = Enum.Font.GothamBold
    WebhookLabel.TextSize = 11
    WebhookLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local WebhookBox = Instance.new("TextBox")
    WebhookBox.Name = "WebhookBox"
    WebhookBox.Parent = WebhookFrame
    WebhookBox.Size = UDim2.new(1, -20, 0, 30)
    WebhookBox.Position = UDim2.new(0.5, 0, 0, 32)
    WebhookBox.AnchorPoint = Vector2.new(0.5, 0)
    WebhookBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    WebhookBox.Text = _G.DiscordWebhook
    WebhookBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    WebhookBox.Font = Enum.Font.Gotham
    WebhookBox.TextSize = 12
    WebhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    WebhookBox.ClearTextOnFocus = false
    Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", WebhookBox).Color = Color3.fromRGB(70, 70, 90)    
    WebhookBox.FocusLost:Connect(function()
        _G.DiscordWebhook = WebhookBox.Text
        SaveConfig()
    end)
    
    -- Map Filter (RTL replacement)
    local MapFilterFrame = MiscTab:CreateSection("Map Filter")
    MapFilterFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local MapFilterToggle = Instance.new("TextButton")
    MapFilterToggle.Name = "ToggleButton"
    MapFilterToggle.Parent = MapFilterFrame
    MapFilterToggle.Size = UDim2.new(0, 40, 0, 20)
    MapFilterToggle.Position = UDim2.new(1, -50, 0.5, -10)
    MapFilterToggle.BackgroundColor3 = _G.MapFilter and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    MapFilterToggle.Text = ""
    MapFilterToggle.BorderSizePixel = 0
    Instance.new("UICorner", MapFilterToggle).CornerRadius = UDim.new(0, 10)
    
    local MapFilterCircle = Instance.new("Frame")
    MapFilterCircle.Name = "ToggleCircle"
    MapFilterCircle.Parent = MapFilterToggle
    MapFilterCircle.Size = UDim2.new(0, 14, 0, 14)
    MapFilterCircle.Position = _G.MapFilter and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    MapFilterCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", MapFilterCircle).CornerRadius = UDim.new(1, 0)
    
    MapFilterToggle.MouseButton1Click:Connect(function()
        _G.MapFilter = not _G.MapFilter
        MapFilterToggle.BackgroundColor3 = _G.MapFilter and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        MapFilterCircle:TweenPosition(_G.MapFilter and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), "Out", "Quad", 0.15, true)
        SaveConfig()
    end)
end

-- // SESSION TIMER
task.spawn(function()
    while true do
        task.wait(1)
        if not MainWindow.Main.Parent then break end
        
        local ElapsedTime = os.time() - StartTime
        local Hours = math.floor(ElapsedTime / 3600)
        local Minutes = math.floor((ElapsedTime % 3600) / 60)
        local Seconds = math.floor(ElapsedTime % 60)
        
        MainWindow.ClockText.Text = string.format("TIME: %02d:%02d:%02d", Hours, Minutes, Seconds)
    end
end)
-- // STATUS UPDATE
function UpdateStatus(text)
    if MainWindow.StatusText then
        MainWindow.StatusText.Text = "● " .. tostring(text)
    end
end

-- // SHARE WITH OTHER FILES
shared.SYLON_GUI = {
    Console = ConsoleScrolling,
    Status = UpdateStatus
}

-- // INITIAL LOG
UpdateStatus("SYSTEM IDLE")
