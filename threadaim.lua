task.wait(1.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotAvailable = false -- f2 toggle primary (availibility)
local Locking = false         -- m3 toggle
local FOVVisible = true       -- f1 to toggle
local FOVSize = 150
local SmoothSpeed = 0.2       -- higher = MORE SMOOTHING!

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Filled = true
FOVCircle.Transparency = 0.15
FOVCircle.Color = Color3.new(1,1,1)
FOVCircle.Radius = FOVSize

local FOVStroke = Drawing.new("Circle")
FOVStroke.Visible = true
FOVStroke.Filled = false
FOVStroke.Transparency = 1
FOVStroke.Color = Color3.new(1,1,1)
FOVStroke.Radius = FOVSize
FOVStroke.Thickness = 1

spawn(function()
    while FOVCircle and FOVStroke do
        local mousePos = UserInputService:GetMouseLocation()
        if FOVVisible then
            FOVCircle.Visible = true
            FOVStroke.Visible = true
            FOVCircle.Position = mousePos
            FOVStroke.Position = mousePos
        else
            FOVCircle.Visible = false
            FOVStroke.Visible = false
        end
        wait(0.025)
    end
end)

local function getClosestPlayer()
    local closestHead
    local shortestDistance = FOVCircle.Radius
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("Head") then
                local head = char.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestHead = head
                    end
                end
            end
        end
    end

    return closestHead
end

RunService.RenderStepped:Connect(function()
    if AimbotAvailable and Locking then
        local target = getClosestPlayer()
        if target then
            local direction = (target.Position - Camera.CFrame.Position).Unit
            local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, SmoothSpeed)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F1 then
        FOVVisible = not FOVVisible 
    elseif input.KeyCode == Enum.KeyCode.F2 then
        AimbotAvailable = not AimbotAvailable
    elseif input.KeyCode == Enum.KeyCode.F5 then
        FOVCircle:Remove()
        FOVStroke:Remove()
        script:Destroy()
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        if AimbotAvailable then
            Locking = not Locking
        end
    end
end)
