-- NOTE: This script REQUIRES WindUI to be loaded first in your executor.
-- Execute the WindUI loading line before this script:
-- local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then
    print("Error: WindUI library not found! Please load WindUI first.")
    return -- Stop execution if WindUI isn't available
end

local user_input_service = game:GetService("UserInputService")
local http_service = game:GetService("HttpService")
local local_player = game.Players.LocalPlayer
local gui_parent = gethui and gethui() or game:GetService("CoreGui")
local old_gui = gui_parent:FindFirstChild("TDSGui") -- Clean up old GUI if it exists
if old_gui then old_gui:Destroy() end
local CONFIG_FILE = "ADS_Config.json"

-- Settings Management (unchanged logic)
local function save_settings()
    local data = {
        AutoSkip = _G.AutoSkip,
        AutoPickups = _G.AutoPickups,
        AutoChain = _G.AutoChain,
        AutoDJ = _G.AutoDJ,
        AntiLag = _G.AntiLag,
        ClaimRewards = _G.ClaimRewards,
        SendWebhook = _G.SendWebhook,
        WebhookURL = _G.WebhookURL
    }
    writefile(CONFIG_FILE, http_service:JSONEncode(data))
end

local function load_settings()
    local default = {
        AutoSkip = false,
        AutoPickups = false,
        AutoChain = false,
        AutoDJ = false,
        AntiLag = false,
        ClaimRewards = false,
        SendWebhook = false,
        WebhookURL = ""
    }
    if isfile(CONFIG_FILE) then
        local success, decoded = pcall(function()
            return http_service:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success then
            for k, v in pairs(decoded) do
                _G[k] = v
            end
            return
        end
    end
    for k, v in pairs(default) do
        _G[k] = v
    end
end

load_settings()

-- Create Main Window using WindUI (Corrected API usage from docs)
local window = WindUI:CreateWindow({
    Title = "SYLON - AFK Defense Simulator", -- Updated title with SYLON
    Size = UDim2.fromOffset(380, 320),
    Folder = "SylonTDS", -- Updated folder name
    Resizable = false, -- Match original fixed size
    HideSearchBar = true, -- No search bar needed
    ScrollBarEnabled = false, -- Disable scroll bar for the main window content
    Theme = "Dark", -- Use a dark theme similar to original
})

-- Create Tabs using WindUI (Corrected API usage)
local logger_tab = window:Tab({
    Title = "LOGGER",
    Icon = "terminal" -- Icon for the tab
})

local settings_tab = window:Tab({
    Title = "SETTINGS",
    Icon = "settings" -- Icon for the tab
})

-- Logger Page Content (Scrolling Frame for logs)
-- We need to create the ScrollingFrame for the logger within the logger tab.
-- Get the container for the logger tab where we can add our custom ScrollingFrame.
-- WindUI usually manages its own containers for each tab.
-- We'll create our ScrollingFrame and add it to the logger tab's content area.
local logger_content_frame = logger_tab:GetContainer() -- Attempt to get the internal container

-- Create a holder frame for the logger ScrollingFrame within the tab's container
local console_holder = Instance.new("Frame")
console_holder.Size = UDim2.new(1, -24, 1, -10)
console_holder.Position = UDim2.new(0, 12, 0, 5)
console_holder.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
console_holder.BorderSizePixel = 0
console_holder.Parent = logger_content_frame -- Parent to the tab's container

-- Create the actual ScrollingFrame for the console logs
local console_scrolling = Instance.new("ScrollingFrame")
console_scrolling.Name = "ConsoleLog" -- Name for easy reference if needed later
console_scrolling.Size = UDim2.new(1, 0, 1, 0)
console_scrolling.Position = UDim2.new(0, 5, 0, 5) -- Slight inner padding
console_scrolling.BackgroundTransparency = 1
console_scrolling.BorderSizePixel = 0
console_scrolling.ScrollBarThickness = 2
console_scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
console_scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
console_scrolling.Parent = console_holder -- Parent to the holder frame

-- Add UIListLayout for log entries
local log_list_layout = Instance.new("UIListLayout")
log_list_layout.SortOrder = Enum.SortOrder.LayoutOrder
log_list_layout.Padding = UDim.new(0, 4)
log_list_layout.Parent = console_scrolling

-- Add UICorner for rounded edges on the holder
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = console_holder


-- Settings Page Content (Adding elements to the settings tab using WindUI)
-- Add Toggles using WindUI
settings_tab:Toggle({
    Title = "Auto Skip Waves",
    Desc = "", -- No description needed
    Default = _G.AutoSkip,
    Callback = function(state)
        _G.AutoSkip = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Auto Collect Pickups",
    Desc = "",
    Default = _G.AutoPickups,
    Callback = function(state)
        _G.AutoPickups = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Auto Chain",
    Desc = "",
    Default = _G.AutoChain,
    Callback = function(state)
        _G.AutoChain = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Auto DJ Booth",
    Desc = "",
    Default = _G.AutoDJ,
    Callback = function(state)
        _G.AutoDJ = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Enable Anti-Lag",
    Desc = "",
    Default = _G.AntiLag,
    Callback = function(state)
        _G.AntiLag = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Claim Rewards",
    Desc = "",
    Default = _G.ClaimRewards,
    Callback = function(state)
        _G.ClaimRewards = state
        save_settings()
    end
})

settings_tab:Toggle({
    Title = "Send Discord Webhook",
    Desc = "",
    Default = _G.SendWebhook,
    Callback = function(state)
        _G.SendWebhook = state
        save_settings()
    end
})

-- Add Webhook URL TextBox using WindUI
settings_tab:TextBox({
    Title = "WEBHOOK URL",
    Desc = "", -- No description needed
    Placeholder = "Paste Discord Webhook Link...",
    Default = _G.WebhookURL,
    Callback = function(text)
        _G.WebhookURL = text
        save_settings()
    end
})


-- Footer Status and Clock (Using original logic, added to main window frame)
-- Create a simple frame at the bottom of the main window.
local footer_frame = Instance.new("Frame")
footer_frame.Size = UDim2.new(1, 0, 0, 35)
footer_frame.Position = UDim2.new(0, 0, 1, -35)
footer_frame.BackgroundTransparency = 1
-- Parent this to the main window's internal frame if possible, or try the main ScreenGui
-- WindUI windows usually have an internal structure. Let's try adding it to the main window's parent container if accessible.
-- If not, we might need to add it to the ScreenGui created by WindUI.
-- Let's assume we can access the root frame of the window created by WindUI.
-- This part might be tricky depending on how WindUI structures its windows internally.
-- A common approach if direct access is hard is to create the footer elements within one of the tabs, perhaps the logger tab, at the very bottom.
-- However, the original design had it fixed at the window bottom.
-- Let's try adding it to the main window's container, assuming WindUI allows it or it's parented correctly by default.
-- If this doesn't appear correctly, it might need adjustment based on WindUI's internal structure.
footer_frame.Parent = window:GetWindowFrame() -- Attempt to get the main window's frame and add footer to it


local status_label = Instance.new("TextLabel")
status_label.Size = UDim2.new(0.5, -15, 1, 0)
status_label.Position = UDim2.new(0, 15, 0, 0)
status_label.BackgroundTransparency = 1
status_label.Text = "● Idle"
status_label.TextColor3 = Color3.fromRGB(200, 200, 200)
status_label.Font = Enum.Font.GothamMedium
status_label.TextSize = 11
status_label.TextXAlignment = Enum.TextXAlignment.Left
status_label.RichText = true
status_label.Parent = footer_frame

local clock_label = Instance.new("TextLabel")
clock_label.Size = UDim2.new(0.5, -15, 1, 0)
clock_label.Position = UDim2.new(0.5, 0, 0, 0)
clock_label.BackgroundTransparency = 1
clock_label.Text = "TIME: 00:00:00"
clock_label.TextColor3 = Color3.fromRGB(120, 120, 130)
clock_label.Font = Enum.Font.GothamBold
clock_label.TextSize = 10
clock_label.TextXAlignment = Enum.TextXAlignment.Right
clock_label.Parent = footer_frame


-- Handle GUI Visibility Toggle (Delete or LeftAlt key - using original logic adapted)
-- WindUI windows usually have their own close buttons, but the original script used keybinds.
-- We can still add the keybind logic alongside the WindUI window.
local isVisible = true -- Track visibility state

local function toggleVisibility()
    isVisible = not isVisible
    -- Use WindUI's built-in open/close methods
    if isVisible then
        window:Open() -- Open the window
    else
        window:Close() -- Close the window
    end
end

user_input_service.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Don't process if another UI already handled it
    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleVisibility()
    end
end)


-- Update Clock Loop (using original logic adapted)
local sessionStart = tick()
spawn(function()
    while wait(1) do
        if not window.Instance or not window.Instance.Parent then -- Check if window still exists
            break
        end
        local elapsed = tick() - sessionStart
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        local timeString = string.format("%02d:%02d:%02d", h, m, s)
        clock_label.Text = "TIME: " .. timeString -- Update the clock label
    end
end)


-- Provide the required interface for the main script ([Idk])
-- This is the crucial part. The main script expects:
-- shared.AutoStratGUI.Console -> A ScrollingFrame instance where it can add TextLabels
-- shared.AutoStratGUI.Status -> A function that takes a string and updates a status TextLabel
shared.AutoStratGUI = {
    -- Use the ScrollingFrame we created for the logger tab
    Console = console_scrolling,
    -- Use the function that updates the status label we created
    Status = function(newStatus)
        status_label.Text = "● " .. tostring(newStatus)
    end
}
