local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.F3
local KILL_KEY = Enum.KeyCode.F5
local SHOW_DISTANCE = 1000
local DRAWING_THICKNESS = 2
local PLAYER_COLOR = Color3.fromRGB(255, 255, 255)

local pairsToConnect = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"}, {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"}, {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"}
}

local espEnabled = false
local running = true
local tracked = {}
local conRender

local function newLine(color)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = DRAWING_THICKNESS
    l.Color = color
    return l
end

local function makeSkeleton(color, model)
    local tbl = {}
    for _,pair in ipairs(pairsToConnect) do
        local fromP = model:FindFirstChild(pair[1])
        local toP = model:FindFirstChild(pair[2])
        if fromP and toP then
            table.insert(tbl, {from=fromP, to=toP, line=newLine(color)})
        end
    end
    return tbl
end

local function cleanup(model)
    if tracked[model] then
        for _,seg in ipairs(tracked[model].segments) do
            if seg.line.Destroy then seg.line:Destroy() end
        end
        tracked[model] = nil
    end
end

local function addModel(model)
    if tracked[model] then return end
    if model:IsA("Model") then
        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local player = Players:GetPlayerFromCharacter(model)
            if not player then return end -- Only track player skeletons
            local color = PLAYER_COLOR
            tracked[model] = {
                model = model,
                segments = makeSkeleton(color, model),
                color = color,
                humanoid = hum,
                root = root
            }
        end
    end
end

local function scanChildren(parent)
    for _,child in pairs(parent:GetChildren()) do
        addModel(child)
    end
end

scanChildren(workspace)
workspace.ChildAdded:Connect(scanChildren)

local function worldToScreen(pos)
    local p, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X, p.Y), on
end

local function updateESP()
    local lpChar = Players.LocalPlayer.Character
    local lpRoot = lpChar and (lpChar:FindFirstChild("HumanoidRootPart") or lpChar:FindFirstChild("LowerTorso"))
    local lpPos = lpRoot and lpRoot.Position or Vector3.new()

    for model,data in pairs(tracked) do
        if not model.Parent then cleanup(model) continue end
        if data.humanoid.Health <= 0 then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        local dist = (data.root.Position - lpPos).Magnitude
        if SHOW_DISTANCE and dist > SHOW_DISTANCE then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        local screenCache = {}
        for _,seg in ipairs(data.segments) do
            local f, t = seg.from, seg.to
            if not f or not t then
                seg.line.Visible = false
                continue
            end
            screenCache[f] = screenCache[f] or {worldToScreen(f.Position)}
            screenCache[t] = screenCache[t] or {worldToScreen(t.Position)}

            local s1,on1 = screenCache[f][1], screenCache[f][2]
            local s2,on2 = screenCache[t][1], screenCache[t][2]

            if on1 and on2 then
                seg.line.Visible = espEnabled
                seg.line.From = s1
                seg.line.To = s2
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

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        espEnabled = not espEnabled
        if not espEnabled then
            for _,data in pairs(tracked) do
                for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            end
        end
    elseif input.KeyCode == KILL_KEY then
        running = false
        espEnabled = false
        if conRender then conRender:Disconnect() end
        for model,data in pairs(tracked) do
            for _,seg in ipairs(data.segments) do
                if seg.line.Destroy then seg.line:Destroy() end
            end
        end
        tracked = {}
    end
end)

for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        plr.CharacterAdded:Connect(addModel)
        if plr.Character then addModel(plr.Character) end
    end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        plr.CharacterAdded:Connect(addModel)
    end
end)
