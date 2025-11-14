local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.F3
local KILL_KEY = Enum.KeyCode.F5
local SHOW_DISTANCE = 1000
local DRAWING_THICKNESS = 2
local PLAYER_COLOR = Color3.fromRGB(255, 255, 255)
local NPC_COLOR = Color3.fromRGB(255, 255, 0)

local pairsToConnect = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"}
}

local espEnabled = false
local running = true
local trackedModels = {}
local conRender

local function newLine(color)
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new()
    l.To = Vector2.new()
    l.Thickness = DRAWING_THICKNESS
    l.Color = color
    return l
end

local function makeSkeleton(model, color)
    local tbl = {}
    for _,pair in ipairs(pairsToConnect) do
        table.insert(tbl, {fromName=pair[1], toName=pair[2], line=newLine(color)})
    end
    return tbl
end

local function cleanup(model)
    local data = trackedModels[model]
    if data then
        for _,seg in ipairs(data.segments) do
            if seg.line and seg.line.Destroy then
                seg.line:Destroy()
            end
        end
        trackedModels[model] = nil
    end
end

local function validPart(model, name)
    local p = model and model:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
end

local function worldToScreen(pos)
    local p, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X, p.Y), on
end

local function addModel(model)
    if trackedModels[model] then return end
    if model:IsA("Model") then
        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        local color = NPC_COLOR
        if Players:GetPlayerFromCharacter(model) then color = PLAYER_COLOR end
        if hum and root then
            trackedModels[model] = {model=model, segments=makeSkeleton(model, color)}
        end
    end
end

local function scanWorkspace(parent)
    for _,child in pairs(parent:GetChildren()) do
        addModel(child)
        scanWorkspace(child)
    end
end

scanWorkspace(workspace)
workspace.ChildAdded:Connect(scanWorkspace)

local function updateESP()
    for model,data in pairs(trackedModels) do
        if not model.Parent then
            cleanup(model)
            continue
        end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("LowerTorso")
        if not root then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end
        if SHOW_DISTANCE and (root.Position - (Players.LocalPlayer.Character and (Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or Players.LocalPlayer.Character:FindFirstChild("LowerTorso")).Position or Vector3.new())).Magnitude > SHOW_DISTANCE then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end
        for _,seg in ipairs(data.segments) do
            local p1 = validPart(model, seg.fromName)
            local p2 = validPart(model, seg.toName)
            if p1 and p2 then
                local s1, on1 = worldToScreen(p1.Position)
                local s2, on2 = worldToScreen(p2.Position)
                if on1 and on2 then
                    seg.line.Visible = espEnabled
                    seg.line.From = s1
                    seg.line.To = s2
                else
                    seg.line.Visible = false
                end
            else
                seg.line.Visible = false
            end
        end
    end
end

conRender = RunService.RenderStepped:Connect(function()
    if running and espEnabled then
        updateESP()
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        espEnabled = not espEnabled
        if not espEnabled then
            for _,data in pairs(trackedModels) do
                for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            end
        end
    elseif input.KeyCode == KILL_KEY then
        running = false
        espEnabled = false
        if conRender then conRender:Disconnect() end
        for model,data in pairs(trackedModels) do
            for _,seg in ipairs(data.segments) do
                if seg.line and seg.line.Destroy then seg.line:Destroy() end
            end
        end
        trackedModels = {}
    end
end)

for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then addModel(plr.Character) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        plr.CharacterAdded:Connect(function()
            addModel(plr.Character)
        end)
    end
end)
