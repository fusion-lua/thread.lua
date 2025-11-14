local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.F3
local KILL_KEY = Enum.KeyCode.F5
local SHOW_DISTANCE = 2000
local DRAWING_THICKNESS = 2
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 0)

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
local npcBoxes = {}
local conRender

local function newLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new()
    l.To = Vector2.new()
    l.Thickness = DRAWING_THICKNESS
    l.Color = DEFAULT_COLOR
    return l
end

local function makeSkeletonForModel(model)
    local tbl = {}
    for _,pair in ipairs(pairsToConnect) do
        local line = newLine()
        table.insert(tbl,{fromName=pair[1],toName=pair[2],line=line})
    end
    return tbl
end

local function cleanupNPC(model)
    local data = npcBoxes[model]
    if data then
        for _,seg in ipairs(data.segments) do
            if seg.line and seg.line.Destroy then
                seg.line:Destroy()
            end
        end
        npcBoxes[model] = nil
    end
end

local function validPart(model,name)
    local p = model and model:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
    return nil
end

local function worldToScreen(pos)
    local p,on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X,p.Y),on
end

local function addNPC(model)
    if not model:FindFirstChild("HumanoidRootPart") then return end
    if not model:FindFirstChildOfClass("Humanoid") then return end
    if Players:GetPlayerFromCharacter(model) then return end
    if npcBoxes[model] then return end

    local segments = makeSkeletonForModel(model)
    npcBoxes[model] = {model = model, segments = segments}
end

local function scanWorkspace(parent)
    for _,child in pairs(parent:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") and child:FindFirstChildOfClass("Humanoid") then
            if not Players:GetPlayerFromCharacter(child) then
                addNPC(child)
            end
        end
        scanWorkspace(child)
    end
end

scanWorkspace(workspace)
workspace.ChildAdded:Connect(function(child)
    scanWorkspace(child)
end)

local function updateESP()
    for model,data in pairs(npcBoxes) do
        if not model.Parent then
            cleanupNPC(model)
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
            if not p1 or not p2 then
                seg.line.Visible = false
            else
                local s1,on1 = worldToScreen(p1.Position)
                local s2,on2 = worldToScreen(p2.Position)
                if on1 and on2 then
                    seg.line.Visible = espEnabled
                    seg.line.From = s1
                    seg.line.To = s2
                    seg.line.Color = DEFAULT_COLOR
                else
                    seg.line.Visible = false
                end
            end
        end
    end
end

conRender = RunService.RenderStepped:Connect(function()
    if not running then return end
    if espEnabled then updateESP() end
end)

UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode == TOGGLE_KEY then
        espEnabled = not espEnabled
        if not espEnabled then
            for _,data in pairs(npcBoxes) do
                for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            end
        end
    elseif inp.KeyCode == KILL_KEY then
        running = false
        espEnabled = false
        if conRender then conRender:Disconnect() end
        for model,data in pairs(npcBoxes) do
            for _,seg in ipairs(data.segments) do
                if seg.line and seg.line.Destroy then seg.line:Destroy() end
            end
        end
        npcBoxes = {}
    end
end)
