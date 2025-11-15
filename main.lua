local StarterGui = game:GetService("StarterGui")

local function sendNotification(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadaim.lua"))()
sendNotification("thread.lua", "Aimbot loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadsight.lua"))()
sendNotification("thread.lua", "Primary & ESP Loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadskel.lua"))()
sendNotification("thread.lua", "Skeleton + Drawing loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/invchecker.lua"))()
sendNotification("thread.lua", "Inventory checking loaded!", 3)
sendNotification("thread.lua", "Loading complete! Press F9 to view controls.", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadcleanseview.lua"))()

print([[

=============================================
              	 THREAD.LUA
=============================================
          EVERY EXECUTOR SUPPORTED

Open source uni/pd script
join the Discord for updates, devlog, detection and more:
https://discord.gg/P24XGuvQ4u

------------------------------------------
Version: 1.4.1  |  Status: Stable
------------------------------------------

F1 - Toggle Aimbot FOV
F2 - Toggle Aimbot
F3 - Toggle Player & NPC ESP
F4 - Toggle Player Visibility Through Walls
F5 - Stop / Remove All ESP
F6 - List all bosses and their status
F7 - Toggle inventory checker
F8 - Toggle viewmodel cleanse (transparent viewmodel)
`  - Hold to zoom
Scroll Wheel - Aimbot (Toggle)
	
---------------------------------------------
© 2025 Fusion | Paid distribution restricted.
=============================================

]])

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui
screenGui.IgnoreGuiInset = true

local bg = Instance.new("Frame")
bg.Position = UDim2.new(0, 0, 0, 0)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 1
bg.Parent = screenGui
bg.ZIndex = 0

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, 0, 0, 0)
shadow.Position = UDim2.new(0.5, 5, 0.5, 5)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = 1
shadow.Parent = screenGui
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 20)
shadowCorner.Parent = shadow

local stroke = Instance.new("Frame")
stroke.Size = UDim2.new(0, 0, 0, 0)
stroke.Position = UDim2.new(0.5, 0, 0.5, 0)
stroke.AnchorPoint = Vector2.new(0.5, 0.5)
stroke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
stroke.BackgroundTransparency = 1
stroke.ZIndex = 2
stroke.Parent = screenGui
local strokeCorner = Instance.new("UICorner")
strokeCorner.CornerRadius = UDim.new(0, 20)
strokeCorner.Parent = stroke

local image = Instance.new("ImageLabel")
image.Image = "rbxassetid://134225845123500"
image.Size = UDim2.new(0, 0, 0, 0)
image.Position = UDim2.new(0.5, 0, 0.5, 0)
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.BackgroundTransparency = 1
image.ZIndex = 3
image.Parent = stroke
local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 20)
imageCorner.Parent = image

TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 205, 0, 205), BackgroundTransparency = 0}):Play()
TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 205, 0, 205)}):Play()
TweenService:Create(image, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 200)}):Play()

task.delay(1.5, function()
    local zoomOutStroke = TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
    local zoomOutShadow = TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
    local zoomOutImage = TweenService:Create(image, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
    local fadeOutBg = TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    
    zoomOutStroke:Play()
    zoomOutShadow:Play()
    zoomOutImage:Play()
    fadeOutBg:Play()
    
    zoomOutStroke.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)
