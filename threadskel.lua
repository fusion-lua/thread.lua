local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.F3
local KILL_KEY = Enum.KeyCode.F5
local SHOW_TEAM = true -- shows their team color. does not affect pd.
local SHOW_DISTANCE = 1000
local DRAWING_THICKNESS = 2
local DEFAULT_COLOR = Color3.fromRGB(255, 0, 0)

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
local playerBoxes = {}
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

local function makeSkeletonForCharacter(char)
    local tbl = {}
    for _,pair in ipairs(pairsToConnect) do
        local line = newLine()
        table.insert(tbl,{fromName=pair[1],toName=pair[2],line=line})
    end
    return tbl
end

local function cleanupPlayer(name)
    local data = playerBoxes[name]
    if data then
        for _,seg in ipairs(data.segments) do
            if seg.line and seg.line.Destroy then
                seg.line:Destroy()
            end
        end
        playerBoxes[name] = nil
    end
end

local function onPlayerAdded(plr)
    local function make()
        if not plr.Character then return end
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local segments = makeSkeletonForCharacter(plr.Character)
        playerBoxes[plr.Name] = {player = plr, segments = segments}
    end
    plr.CharacterAdded:Connect(function() make() end)
    if plr.Character then make() end
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        onPlayerAdded(plr)
    end
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(plr) cleanupPlayer(plr.Name) end)

local function worldToScreen(pos)
    local p,on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X,p.Y),on
end

local function validPart(char,name)
    local p = char and char:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
    return nil
end

local function updateESP()
    for name,data in pairs(playerBoxes) do
        local plr = data.player
        if not plr or not plr.Character or not plr.Character.Parent then
            cleanupPlayer(name)
            continue
        end
        if plr == Players.LocalPlayer then
            cleanupPlayer(name)
            continue
        end

        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        if not SHOW_TEAM and plr.Team == Players.LocalPlayer.Team and plr.Team ~= nil then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("LowerTorso")
        if not root then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        if SHOW_DISTANCE and (root.Position - (Players.LocalPlayer.Character and (Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or Players.LocalPlayer.Character:FindFirstChild("LowerTorso")).Position or Vector3.new())).Magnitude > SHOW_DISTANCE then
            for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            continue
        end

        for _,seg in ipairs(data.segments) do
            local p1 = validPart(plr.Character, seg.fromName)
            local p2 = validPart(plr.Character, seg.toName)
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
            for _,data in pairs(playerBoxes) do
                for _,seg in ipairs(data.segments) do seg.line.Visible = false end
            end
        end
    elseif inp.KeyCode == KILL_KEY then
        running = false
        espEnabled = false
        if conRender then conRender:Disconnect() end
        for name,data in pairs(playerBoxes) do
            for _,seg in ipairs(data.segments) do
                if seg.line and seg.line.Destroy then seg.line:Destroy() end
            end
            playerBoxes[name] = nil
        end
    end
end)
