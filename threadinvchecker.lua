local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local listening = true
local enabled = false
local activeTags = {}
local textSize = 14
local lineHeight = textSize + 4
local charWidth = 8
local offset = Vector3.new(0, 0, 0)

local targetItems = {"r700","tfz9","altyn","m4","val","hspv","jpc","zsh","tors","crown","6b47","6b45","6b5","kulon","mosin","saiga","Mp5","svd","fal","Scavking","6b27","6b23","sks","izh","akm","motor","6b2","spsh","flare","adar","vz","bandolier","recon","dozer","tanker","concealed","makarov","pm","tokarev","tt","fast","ppsh","ssh","uno"}

local function formatItems(itemList)
    if #itemList == 0 then return {"none"} end
    local lines = {}
    for i = 1, #itemList, 3 do
        local chunk = {}
        for j = i, math.min(i + 2, #itemList) do
            table.insert(chunk, itemList[j])
        end
        table.insert(lines, table.concat(chunk, ","))
    end
    return lines
end

local function calculateWidth(lines)
    local maxLength = 0
    for _, line in ipairs(lines) do
        if #line > maxLength then
            maxLength = #line
        end
    end
    return math.max(80, maxLength * charWidth)
end

local function createOrUpdateTag(character, itemList)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local lines = formatItems(itemList)
    local text = table.concat(lines, "\n")
    local height = lineHeight * #lines
    local width = calculateWidth(lines)
    local tag = activeTags[character.Name]
    if tag then tag:Destroy() end
    tag = Instance.new("BillboardGui")
    tag.Name = "Item_Checker_Billboard_GUI"
    tag.Size = UDim2.new(0, width, 0, height)
    tag.Adornee = head
    tag.AlwaysOnTop = true
    tag.StudsOffset = offset
    tag.Enabled = enabled
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.6
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.Code
    textLabel.TextScaled = false
    textLabel.TextSize = textSize
    textLabel.Text = text
    textLabel.Parent = tag
    tag.Parent = workspace
    activeTags[character.Name] = tag
end

local function scanPlayers()
    if activeTags[LocalPlayer.Name] then
        local tag = activeTags[LocalPlayer.Name]
        if tag and tag.Parent then tag:Destroy() end
        activeTags[LocalPlayer.Name] = nil
    end
    local playersFolder = ReplicatedStorage:FindFirstChild("Players")
    if not playersFolder then return end
    for _, player in ipairs(playersFolder:GetChildren()) do
        if player.Name ~= LocalPlayer.Name then
            local inventory = player:FindFirstChild("Inventory")
            local matchedItems = {}
            if inventory then
                for _, item in ipairs(inventory:GetChildren()) do
                    local itemNameUpper = string.upper(item.Name)
                    for _, target in ipairs(targetItems) do
                        if string.find(itemNameUpper, string.upper(target)) then
                            table.insert(matchedItems, item.Name)
                            break
                        end
                    end
                end
            end
            local character = workspace:FindFirstChild(player.Name)
            if character then
                createOrUpdateTag(character, matchedItems)
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F5 then
        listening = false
        for _, tag in pairs(activeTags) do
            if tag and tag.Parent then tag:Destroy() end
        end
        activeTags = {}
    end
end)

spawn(function()
    local lastF7 = false
    while listening do
        local f7Down = UserInputService:IsKeyDown(Enum.KeyCode.F7)
        if f7Down and not lastF7 then
            enabled = not enabled
        end
        lastF7 = f7Down
        RunService.RenderStepped:Wait()
    end
end)

spawn(function()
    while listening do
        scanPlayers()
        wait(1)
    end
end)
