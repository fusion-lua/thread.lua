local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")

local function Notify(title, text, duration)
	duration = duration or 3
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title;
			Text = text;
			Duration = duration;
		})
	end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local enabled = false
local visibilityThroughWalls = true
local connections = {}
local originalFOV = Camera.FieldOfView
local fovActive = false

local PLAYER_MAX_DIST = 70000
local NPC_MAX_DIST = 70000
local HIDE_LOCALPLAYER = true

local Team = {"example1"}
local Enemy = {"example1","example2"}

local Colors = {
	Team = Color3.fromRGB(0,255,0),
	Enemy = Color3.fromRGB(255,0,0),
	Neutral = Color3.fromRGB(255,255,255),
	NPCDefault = Color3.fromRGB(255,255,0),
	NPCDanger = Color3.fromRGB(255,0,0)
}

local DangerNPCs = {"Death","Dozer","Anton","Whisper","BTR"}
local NPC_IGNORE_NAMES = {"playermodel","viewmodel", LocalPlayer.Name, "mikhel"}
local SpecialNPCs = {"SportBagGrayPlaceholder"}

local function getColorForPlayer(plr)
	local name = plr.Name
	for _, t in ipairs(Team) do
		if t == name then return Colors.Team end
	end
	for _, e in ipairs(Enemy) do
		if e == name then return Colors.Enemy end
	end
	return Colors.Neutral
end

local function isNPCDanger(name)
	local lname = string.lower(name)
	for _, s in ipairs(SpecialNPCs) do
		if lname == s then return false end
	end
	for _, s in ipairs(DangerNPCs) do
		if string.find(lname,string.lower(s)) then return true end
	end
	return false
end

local function getHPColor(humanoid)
	local ratio = humanoid.Health / humanoid.MaxHealth
	if ratio > 0.7 then
		return Color3.fromRGB(0,255,0)
	elseif ratio > 0.3 then
		return Color3.fromRGB(255,255,0)
	else
		return Color3.fromRGB(255,0,0)
	end
end

local function removeHighlight(char)
	if char then
		local h = char:FindFirstChildOfClass("Highlight")
		if h then h:Destroy() end
		local gui1 = char:FindFirstChild("HeadTag")
		if gui1 then gui1:Destroy() end
		local gui2 = char:FindFirstChild("FeetTag")
		if gui2 then gui2:Destroy() end
	end
end

local function createHighlight(char, plr, isNPC)
	if not char or char:FindFirstChildOfClass("Highlight") then return end
	if plr == LocalPlayer then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
	if not rootPart then return end

	local isSpecial = false
	for _, s in ipairs(SpecialNPCs) do
		if string.lower(char.Name) == s then
			isSpecial = true
			break
		end
	end

	local color
	local depthMode
	if isNPC then
		color = (isNPCDanger(char.Name) and not isSpecial) and Colors.NPCDanger or Colors.NPCDefault
		depthMode = Enum.HighlightDepthMode.AlwaysOnTop
	else
		color = getColorForPlayer(plr)
		depthMode = visibilityThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	end

	local h = Instance.new("Highlight")
	h.Adornee = char
	h.DepthMode = depthMode
	h.FillTransparency = 0.5
	h.OutlineTransparency = 1
	h.FillColor = color
	h.Parent = char

	local headGui = Instance.new("BillboardGui")
headGui.Name = "HeadTag"
headGui.Adornee = rootPart
headGui.Size = UDim2.new(0,140,0,30) -- smaller overall height
headGui.StudsOffset = Vector3.new(0,3,0)
headGui.AlwaysOnTop = true

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1,0,0.55,0) -- slightly bigger than half
nameLabel.Position = UDim2.new(0,0,0,0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextScaled = false
nameLabel.TextSize = 13
nameLabel.Font = Enum.Font.Code
nameLabel.TextStrokeTransparency = 0
nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
nameLabel.Text = isNPC and char.Name or plr.Name
nameLabel.TextColor3 = color
nameLabel.Parent = headGui

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1,0,0.45,0) -- smaller than half to reduce gap
hpLabel.Position = UDim2.new(0,0,0.55,0)
hpLabel.BackgroundTransparency = 1
hpLabel.TextScaled = false
hpLabel.TextSize = 13
hpLabel.Font = Enum.Font.Code
hpLabel.TextStrokeTransparency = 0
hpLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
if humanoid then
	hpLabel.TextColor3 = getHPColor(humanoid)
	hpLabel.Text = math.floor(humanoid.Health)
end
hpLabel.Parent = headGui

	headGui.Parent = char

	if not isNPC then
		local feetGui = Instance.new("BillboardGui")
		feetGui.Name = "FeetTag"
		feetGui.Adornee = rootPart
		feetGui.Size = UDim2.new(0,140,0,20)
		feetGui.StudsOffset = Vector3.new(0,-3,0)
		feetGui.AlwaysOnTop = true

		local distLabel = Instance.new("TextLabel")
		distLabel.Size = UDim2.new(1,0,1,0)
		distLabel.Position = UDim2.new(0,0,0,0)
		distLabel.BackgroundTransparency = 1
		distLabel.TextScaled = false
		distLabel.TextSize = 13
		distLabel.Font = Enum.Font.Code
		distLabel.TextStrokeTransparency = 0
		distLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
		distLabel.TextColor3 = Color3.fromRGB(255,255,255)
		distLabel.Text = ""
		distLabel.Parent = feetGui

		feetGui.Parent = char

		RunService.Heartbeat:Connect(function()
			if not char.Parent or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
			local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if dist > PLAYER_MAX_DIST then
				feetGui.Enabled = false
				h.Enabled = false
				headGui.Enabled = false
			else
				feetGui.Enabled = true
				h.Enabled = true
				headGui.Enabled = true
				distLabel.Text = math.floor(dist).." studs"
			end
		end)
	end

	if humanoid then
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			hpLabel.TextColor3 = getHPColor(humanoid)
			hpLabel.Text = math.floor(humanoid.Health)
		end)
	end

	if isNPC then
		RunService.Heartbeat:Connect(function()
			if not char.Parent or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
			local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			local visible = dist <= NPC_MAX_DIST
			h.Enabled = visible
			headGui.Enabled = visible
		end)
	end
end

local function setupCharacter(plr, char)
	if enabled then
		removeHighlight(char)
		createHighlight(char, plr, false)
	end
end

local function getAllNPCs()
	local npcs = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			local isPlayer = false
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character == obj then
					isPlayer = true
					break
				end
			end
			if not isPlayer and obj ~= LocalPlayer.Character then
				local ignoreModel = false
				for _, name in ipairs(NPC_IGNORE_NAMES) do
					if string.find(string.lower(obj.Name), string.lower(name)) then
						ignoreModel = true
						break
					end
				end
				if not ignoreModel then table.insert(npcs,obj) end
			end
		end
	end
	return npcs
end

local function setupNPC(char)
	if enabled then
		removeHighlight(char)
		createHighlight(char, nil, true)
	end
end

local function refreshHighlights()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			removeHighlight(plr.Character)
			if enabled then
				setupCharacter(plr, plr.Character)
			end
		end
	end
	for _, npc in ipairs(getAllNPCs()) do
		removeHighlight(npc)
		if enabled then
			setupNPC(npc)
		end
	end
end

if HIDE_LOCALPLAYER and LocalPlayer.Character then
	wait(0.1)
end
LocalPlayer.CharacterAdded:Connect(function(char)
	if HIDE_LOCALPLAYER then
		wait(0.1)
	end
end)

connections.PlayerAdded = Players.PlayerAdded:Connect(function(plr)
	connections[plr] = plr.CharacterAdded:Connect(function(char)
		setupCharacter(plr, char)
	end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	connections[plr] = plr.CharacterAdded:Connect(function(char)
		setupCharacter(plr, char)
	end)
end

-- MI24V logic: shows distance in studs
local function setupMI24VModel(miModel)
	if not miModel or miModel:FindFirstChildOfClass("Highlight") then return end
	local rootPart = miModel:FindFirstChild("HumanoidRootPart") or miModel:FindFirstChildWhichIsA("BasePart")
	if not rootPart then return end

	local h = Instance.new("Highlight")
	h.Adornee = miModel
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillTransparency = 0.5
	h.OutlineTransparency = 1
	h.FillColor = Colors.NPCDanger
	h.Parent = miModel

	local headGui = Instance.new("BillboardGui")
	headGui.Name = "HeadTag"
	headGui.Adornee = rootPart
	headGui.Size = UDim2.new(0,140,0,40)
	headGui.StudsOffset = Vector3.new(0,3,0)
	headGui.AlwaysOnTop = true

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1,0,0.5,0)
	nameLabel.Position = UDim2.new(0,0,0,0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.Code
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameLabel.Text = miModel.Name
	nameLabel.TextColor3 = Colors.NPCDanger
	nameLabel.Parent = headGui

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1,0,0.5,0)
	distLabel.Position = UDim2.new(0,0,0.5,0)
	distLabel.BackgroundTransparency = 1
	distLabel.TextScaled = true
	distLabel.Font = Enum.Font.Code
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	distLabel.TextColor3 = Color3.fromRGB(255,255,255)
	distLabel.Text = "0 studs"
	distLabel.Parent = headGui

	headGui.Parent = miModel

	RunService.Heartbeat:Connect(function()
		if not miModel.Parent or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
		local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		local visible = enabled and dist <= NPC_MAX_DIST
		h.Enabled = visible
		headGui.Enabled = visible
		distLabel.Text = math.floor(dist).." studs"
	end)
end

-- Recursive scan for MI24V
local function scanForMI24V(parent)
	for _, obj in ipairs(parent:GetChildren()) do
		if obj.Name == "MI24V" and obj:IsA("Model") then
			setupMI24VModel(obj)
		else
			scanForMI24V(obj)
		end
	end
end
scanForMI24V(workspace)

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Model") and obj.Name == "MI24V" then
		setupMI24VModel(obj)
	end
end)

connections.InputBegan = UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F3 then
		enabled = not enabled
		refreshHighlights()
	elseif input.KeyCode == Enum.KeyCode.F4 then
		visibilityThroughWalls = not visibilityThroughWalls
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				local h = plr.Character:FindFirstChildOfClass("Highlight")
				if h then
					h.DepthMode = visibilityThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
				end
			end
		end
	elseif input.KeyCode == Enum.KeyCode.F5 then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") then
				removeHighlight(obj)
			end
		end
		for _, conn in pairs(connections) do
			if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
		end
	elseif input.KeyCode == Enum.KeyCode.F6 then
		for _, npc in ipairs(getAllNPCs()) do
			if isNPCDanger(npc.Name) then
				local humanoid = npc:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					print(string.format("NPC: %s | HP: %d", npc.Name, math.floor(humanoid.Health)))
				end
			end
		end
	elseif input.KeyCode == Enum.KeyCode.Backquote then
		if not fovActive then
			originalFOV = Camera.FieldOfView
			Camera.FieldOfView = 10
			fovActive = true
		end
	end
end)

connections.InputEnded = UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Backquote then
		if fovActive then
			Camera.FieldOfView = originalFOV
			fovActive = false
		end
	end
end)



