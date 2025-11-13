local UserInputService = game:GetService("UserInputService")
local Camera = workspace:FindFirstChild("Camera")
if not Camera then
    warn("Camera not found in workspace, press F5 and reload the script.")
    return
end

local toggled = false
local descendantConnection
local inputConnection
local cameraChangeConnection
local stopped = false

local function cleanseCamera(obj)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("SurfaceAppearance") then
            child:Destroy()
        end
        if child:IsA("BasePart") then
            child.Material = Enum.Material.ForceField
            child.Color = Color3.new(1,1,1)
        end
        if child:IsA("MeshPart") then
            child.TextureID = ""
        end
        if child:IsA("SpecialMesh") then
            child.TextureId = ""
        end
        cleanseCamera(child)
    end
end

local function toggleEffect()
    if stopped then return end
    toggled = not toggled
    if toggled and Camera then
        cleanseCamera(Camera)
    end
end

local function monitorCamera(cam)
    if stopped then return end
    if descendantConnection then
        descendantConnection:Disconnect()
    end
    descendantConnection = cam.DescendantAdded:Connect(function(desc)
        if toggled and not stopped then
            cleanseCamera(desc)
        end
    end)
end

monitorCamera(Camera)

inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or stopped then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        toggleEffect()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        stopped = true
        toggled = false
        if descendantConnection then
            descendantConnection:Disconnect()
            descendantConnection = nil
        end
        if inputConnection then
            inputConnection:Disconnect()
            inputConnection = nil
        end
        if cameraChangeConnection then
            cameraChangeConnection:Disconnect()
            cameraChangeConnection = nil
        end
    end
end)

cameraChangeConnection = workspace:GetPropertyChangedSignal("Camera"):Connect(function()
    if stopped then return end
    Camera = workspace:FindFirstChild("Camera")
    if Camera then
        monitorCamera(Camera)
        if toggled then
            cleanseCamera(Camera)
        end
    end
end)
