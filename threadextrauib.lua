local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenEffects = PlayerGui:WaitForChild("NoInsetGui"):WaitForChild("MainFrame"):WaitForChild("ScreenEffects")

local textSize = 10.5
local padding = 12
local buttonSpacing = 5
local buttons = {}
local menuVisible = true
local stopped = false
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomButtonGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local PLAYER_ESP_STORAGE = {}
local DROPPED_ESP_STORAGE = {}
local ESP_STORAGE = {}
local running = true
local playerESPEnabled = false
local droppedESPEnabled = false
local connections = {}

local function getTextSize(message)
	local temp = Instance.new("TextLabel")
	temp.Text = message
	temp.Font = Enum.Font.Code
	temp.TextSize = textSize
	temp.TextTransparency = 1
	temp.Size = UDim2.new(0,0,0,0)
	temp.Parent = screenGui
	local width = temp.TextBounds.X + padding*2
	local height = temp.TextBounds.Y + padding*2
	temp:Destroy()
	return width, height
end

local function flashOnClick(gui)
	if gui:FindFirstChild("BlackBox") then
		local blackBox = gui.BlackBox
		local tweenUp = TweenService:Create(blackBox, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(1,1,1)})
		local tweenDown = TweenService:Create(blackBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(0,0,0)})
		tweenUp:Play()
		tweenUp.Completed:Connect(function() tweenDown:Play() end)
	end
end

local buttonPadding = 10
local screenWidth = workspace.CurrentCamera.ViewportSize.X
local screenHeight = workspace.CurrentCamera.ViewportSize.Y

local function repositionButtons()
	local totalHeight = 0
	for _, btn in ipairs(buttons) do
		totalHeight = totalHeight + btn.Size.Y.Offset + buttonSpacing
	end
	totalHeight = totalHeight - buttonSpacing
	local startY = screenHeight/2 - totalHeight/2
	for i, btn in ipairs(buttons) do
		local posY = startY
		for j=1,i-1 do posY = posY + buttons[j].Size.Y.Offset + buttonSpacing end
		btn.Position = UDim2.new(0, screenWidth + 300, 0, posY)
	end
end

local function slideButtons(show)
	for _, btn in ipairs(buttons) do
		local targetX = show and screenWidth - btn.Size.X.Offset - buttonPadding or screenWidth + 300
		TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, targetX, btn.Position.Y.Scale, btn.Position.Y.Offset)}):Play()
	end
	menuVisible = show
end

local function createButton(text, callback)
	local w,h = getTextSize(text)
	h = h * 0.8
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(0, w+8, 0, h+8)
	container.Position = UDim2.new(0, screenWidth + 300, 0, screenHeight/2 - (h+8)/2)
	container.Parent = screenGui

	local blackOutline = Instance.new("Frame")
	blackOutline.Size = UDim2.new(1,0,1,0)
	blackOutline.Position = UDim2.new(0,0,0,0)
	blackOutline.BackgroundColor3 = Color3.new(0,0,0)
	blackOutline.BorderSizePixel = 0
	blackOutline.Parent = container

	local whiteOutline = Instance.new("Frame")
	whiteOutline.Size = UDim2.new(0, w+4, 0, h+4)
	whiteOutline.Position = UDim2.new(0,2,0,2)
	whiteOutline.BackgroundColor3 = Color3.new(1,1,1)
	whiteOutline.BorderSizePixel = 0
	whiteOutline.Parent = container

	local blackBox = Instance.new("Frame")
	blackBox.Name = "BlackBox"
	blackBox.Size = UDim2.new(0, w, 0, h)
	blackBox.Position = UDim2.new(0,4,0,4)
	blackBox.BackgroundColor3 = Color3.new(0,0,0)
	blackBox.BorderSizePixel = 0
	blackBox.Parent = container

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Position = UDim2.new(0,0,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = textSize
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.Active = true
	lbl.Parent = blackBox

	lbl.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			callback()
			flashOnClick(container)
		end
	end)

	table.insert(buttons, container)
	local newW = lbl.TextBounds.X + padding*2
	blackBox.Size = UDim2.new(0, newW, 0, h)
	container.Size = UDim2.new(0, newW+8, 0, h+8)
	whiteOutline.Size = UDim2.new(0, newW+4, 0, h+4)
	repositionButtons()
	return container
end

local function makeESP(model, isDead)
	if ESP_STORAGE[model] then return end
	local parts = {}
	for _, d in ipairs(model:GetChildren()) do
		if d:IsA("BasePart") then table.insert(parts,d) end
	end
	if #parts==0 then return end
	local folder = Instance.new("Folder")
	folder.Name = isDead and "DeadESP" or "DroppedESP"
	folder.Parent = model
	ESP_STORAGE[model] = folder

	local gui = Instance.new("BillboardGui")
	gui.Size = isDead and UDim2.new(0,60,0,20) or UDim2.new(0,40,0,12)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.ExtentsOffset = Vector3.new(0,isDead and 1.5 or 1.2,0)
	gui.Parent = folder

	local text = Instance.new("TextLabel")
	text.Size = isDead and UDim2.new(1,0,1,0) or UDim2.new(1.6,0,1.6,0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.TextStrokeTransparency = isDead and 0.5 or 0.7
	text.TextStrokeColor3 = Color3.new(0,0,0)
	text.TextScaled = true
	text.Font = Enum.Font.Code
	text.Text = isDead and (model.Name.."\n[Dead]") or model.Name
	text.TextSize = isDead and 14 or 5
	text.Parent = gui
	gui.Adornee = parts[1]

	for _, p in ipairs(parts) do
		local box = Instance.new("BoxHandleAdornment")
		box.Size = p.Size
		box.Adornee = p
		box.AlwaysOnTop = true
		box.ZIndex = 2
		box.Color3 = Color3.new(1,1,1)
		box.Transparency = isDead and 0.6 or 0.8
		box.Parent = folder
	end
end

local function clearESP(type)
	for model, folder in pairs(ESP_STORAGE) do
		if folder and ((type == "DeadESP" and folder.Name == "DeadESP") or (type == "DroppedESP" and folder.Name == "DroppedESP")) then
			folder:Destroy()
			ESP_STORAGE[model] = nil
		end
	end
end

local function scanDroppedItems()
	local droppedFolder = workspace:FindFirstChild("DroppedItems")
	if droppedFolder then
		for _, item in ipairs(droppedFolder:GetChildren()) do
			if item:IsA("Model") then
				local isDead = false
				for _, plr in ipairs(Players:GetPlayers()) do
					if string.find(item.Name:lower(), plr.Name:lower()) then isDead = true break end
				end
				if isDead and playerESPEnabled and not ESP_STORAGE[item] then
					makeESP(item, true)
				elseif not isDead and droppedESPEnabled and not ESP_STORAGE[item] then
					makeESP(item, false)
				end
			end
		end
	end

	local heliWreck = workspace:FindFirstChild("AiZones") 
		and workspace.AiZones:FindFirstChild("HeliAirfield") 
		and workspace.AiZones.HeliAirfield:FindFirstChild("Mi24V_Wreck") 
		and workspace.AiZones.HeliAirfield.Mi24V_Wreck:FindFirstChild("Mi24_Hull")
	if heliWreck and playerESPEnabled and not ESP_STORAGE[heliWreck] then
		makeESP(heliWreck, true)
	end
end

task.spawn(function()
	while running do
		scanDroppedItems()
		task.wait(1)
	end
end)

connections["input"] = UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F10 then
		slideButtons(not menuVisible)
	elseif input.KeyCode == Enum.KeyCode.F5 then
		running = false
		slideButtons(false)
		task.wait(0.5)
		clearESP("DeadESP")
		clearESP("DroppedESP")
		for _, c in pairs(connections) do
			if c and c.Disconnect then c:Disconnect() end
		end
		for _, btn in ipairs(buttons) do btn:Destroy() end
		script:Destroy()
	end
end)

createButton("Dead ESP", function()
	playerESPEnabled = not playerESPEnabled
	if not playerESPEnabled then
		clearESP("DeadESP")
	end
end)

createButton("Dropped ESP", function()
	droppedESPEnabled = not droppedESPEnabled
	if not droppedESPEnabled then
		clearESP("DroppedESP")
	end
end)

repositionButtons()
slideButtons(true)
