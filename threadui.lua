local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local textSize = 15
local padding = 5
local extraWidth = 50
local spacing = 5
local listening = true
local activeNotifications = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local function getTextSize(message)
	local tempLabel = Instance.new("TextLabel")
	tempLabel.Text = message
	tempLabel.Font = Enum.Font.Code
	tempLabel.TextSize = textSize
	tempLabel.TextTransparency = 1
	tempLabel.Size = UDim2.new(0,0,0,0)
	tempLabel.Parent = screenGui
	local width = tempLabel.TextBounds.X + padding*2 + extraWidth
	local height = tempLabel.TextBounds.Y + padding*2
	tempLabel:Destroy()
	return width, height
end

local function createLayeredFrame(message)
	local textWidth, textHeight = getTextSize(message)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, textWidth + 8, 0, textHeight + 8)
	container.Position = UDim2.new(0.5, -(textWidth + 8)/2, 0, -50)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local blackOutline = Instance.new("Frame")
	blackOutline.Size = UDim2.new(1,0,1,0)
	blackOutline.Position = UDim2.new(0,0,0,0)
	blackOutline.BackgroundColor3 = Color3.new(0,0,0)
	blackOutline.BorderSizePixel = 0
	blackOutline.Parent = container

	local whiteOutline = Instance.new("Frame")
	whiteOutline.Size = UDim2.new(0, textWidth + 4, 0, textHeight + 4)
	whiteOutline.Position = UDim2.new(0, 2, 0, 2)
	whiteOutline.BackgroundColor3 = Color3.new(1,1,1)
	whiteOutline.BorderSizePixel = 0
	whiteOutline.Parent = container

	local blackBox = Instance.new("Frame")
	blackBox.Size = UDim2.new(0, textWidth, 0, textHeight)
	blackBox.Position = UDim2.new(0, 4, 0, 4)
	blackBox.BackgroundColor3 = Color3.new(0,0,0)
	blackBox.BorderSizePixel = 0
	blackBox.Parent = container

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0, textWidth, 0, textHeight)
	textLabel.Position = UDim2.new(0,4,0,4)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = message
	textLabel.TextColor3 = Color3.new(1,1,1)
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = textSize
	textLabel.Parent = container

	return container, textHeight + 8
end

local function repositionNotifications()
	local _, topHeight = getTextSize("thread loaded.")
	local currentY = topHeight + spacing
	for _, notif in ipairs(activeNotifications) do
		if notif.frame and notif.frame.Parent then
			local tween = TweenService:Create(notif.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(0.5, -(notif.frame.Size.X.Offset)/2, 0, currentY)})
			tween:Play()
			currentY = currentY + notif.height + spacing
		end
	end
end

local topNotification, topHeight = createLayeredFrame("thread loaded.")
TweenService:Create(topNotification, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{Position = UDim2.new(0.5, -(topNotification.Size.X.Offset)/2, 0, 0)}):Play()

local function addNotification(message, duration)
	local container, notifHeight = createLayeredFrame(message)
	table.insert(activeNotifications, {frame = container, height = notifHeight})
	repositionNotifications()
	task.delay(duration or 3, function()
		for i, notif in ipairs(activeNotifications) do
			if notif.frame == container then
				local tween = TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{Position = UDim2.new(0.5, -(container.Size.X.Offset)/2, 0, -50)})
				tween:Play()
				tween.Completed:Connect(function()
					container:Destroy()
				end)
				table.remove(activeNotifications, i)
				repositionNotifications()
				break
			end
		end
	end)
end

local function sendNotification(key, text)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not listening then return end
		if input.KeyCode == key then
			addNotification(text)
		end
	end)
end

sendNotification(Enum.KeyCode.F1, "Aimbot FOV toggled")
sendNotification(Enum.KeyCode.F2, "Aimbot toggled")
sendNotification(Enum.KeyCode.F3, "ESP toggled")
sendNotification(Enum.KeyCode.F4, "Chams style toggled")
sendNotification(Enum.KeyCode.F7, "Inventory checker toggled")
sendNotification(Enum.KeyCode.F8, "Viewmodel changer toggled. Re-equip item to apply.")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not listening then return end
	if input.KeyCode == Enum.KeyCode.F5 then
		listening = false
		local allNotifications = {topNotification}
		for _, v in ipairs(activeNotifications) do
			table.insert(allNotifications, v.frame)
		end
		for _, frame in ipairs(allNotifications) do
			if frame and frame.Parent then
				local tween = TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -(frame.Size.X.Offset)/2, 0, -50)})
				tween:Play()
				tween.Completed:Connect(function()
					if frame then frame:Destroy() end
				end)
			end
		end
		activeNotifications = {}
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not listening then return end
	if input.KeyCode == Enum.KeyCode.F6 then
		local DangerNPCs = {"Death","Dozer","Anton","Whisper","BTR"}
		local aiZones = workspace:FindFirstChild("AiZones")
		if not aiZones then
			addNotification("AiZones not found")
			return
		end
		for _, dangerName in ipairs(DangerNPCs) do
			local found = false
			for _, obj in ipairs(aiZones:GetDescendants()) do
				if obj:IsA("Model") and string.find(obj.Name, dangerName) then
					if dangerName == "Anton" and string.find(obj.Name, "Guard") then break end
					found = true
					local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
					local healthText = "Not found"
					if humanoid then
						healthText = humanoid.Health > 0 and tostring(math.floor(humanoid.Health)) or "Dead"
					end
					addNotification(obj.Name .. " HP: " .. healthText)
				end
			end
			if not found then
				addNotification(dangerName .. " Not found")
			end
		end
	end
end)
