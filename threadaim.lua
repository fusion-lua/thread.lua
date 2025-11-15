local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotAvailable = false
local Locking = false
local FOVVisible = false
local FOVSize = 150
local SmoothSpeed = 0.2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = true
FOVCircle.Transparency = 0.15
FOVCircle.Color = Color3.new(1,1,1)
FOVCircle.Radius = FOVSize
FOVCircle.Visible = FOVVisible

local FOVStroke = Drawing.new("Circle")
FOVStroke.Filled = false
FOVStroke.Transparency = 1
FOVStroke.Color = Color3.new(1,1,1)
FOVStroke.Radius = FOVSize
FOVStroke.Thickness = 1
FOVStroke.Visible = FOVVisible

local connections = {}

connections.fovLoop = RunService.RenderStepped:Connect(function()
    if not FOVCircle or not FOVStroke then return end
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
end)

local function getClosestPlayer()
    local mousePos = UserInputService:GetMouseLocation()
    local shortestDistance = FOVCircle.Radius
    local bestTarget
    local bestIsPlayer = false

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
                        bestTarget = head
                        bestIsPlayer = true
                    end
                end
            end
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local root = obj.Parent:FindFirstChild("HumanoidRootPart")
            local head = obj.Parent:FindFirstChild("Head")
            if root and head and obj.Parent ~= LocalPlayer.Character then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        if not bestIsPlayer then
                            shortestDistance = distance
                            bestTarget = head
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end


connections.aimbotLoop = RunService.RenderStepped:Connect(function()
    if AimbotAvailable and Locking then
        local target = getClosestPlayer()
        if target then
            local direction = (target.Position - Camera.CFrame.Position).Unit
            local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, SmoothSpeed)
        end
    end
end)

local function sendNotification(desc)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "thread.lua",
        Text = desc,
        Duration = 2
    })
end

connections.input = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F1 then
        FOVVisible = not FOVVisible
    elseif input.KeyCode == Enum.KeyCode.F2 then
        AimbotAvailable = not AimbotAvailable
    elseif input.KeyCode == Enum.KeyCode.F5 then
        for _, conn in pairs(connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        if FOVCircle then FOVCircle:Remove() end
        if FOVStroke then FOVStroke:Remove() end
        script:Destroy()
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        if AimbotAvailable then
            Locking = not Locking
        end
    end
end)
